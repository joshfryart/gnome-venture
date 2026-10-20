/* v2.0.11: Treks camp pop-over. PHP builds <dialog class="tkcamp"> on the Map tab; this opens it (the Camp button, or by itself when the page says so),
   runs the Talk bubble and the "open at camps" switch. Everything inside that changes the game is an ordinary POST form. Text goes in with textContent only. */
(function () {
  var timer = 0;
  function dlg() { return document.querySelector('dialog.tkcamp'); }
  function autoOk() { try { return localStorage.getItem('gvCampAuto') !== '0'; } catch (e) { return true; } }

  function openCamp() {
    var d = dlg();
    if (d && typeof gvOpenDlg === 'function') gvOpenDlg(d);
  }

  /* a story pop-over or an Auto replay is still on screen (or about to be): the camp waits for it */
  function busy() {
    return !!document.querySelector('dialog.tkscene[open], dialog.tkr[open], .trekscene:not([data-seen])');
  }

  function scan() {
    var d = document.querySelector('dialog.tkcamp[data-auto]:not([data-done])');
    if (!d) return;
    if (d.getAttribute('data-auto') === 'arrive' && !autoOk()) { d.setAttribute('data-done', '1'); return; }
    if (busy()) {
      if (!timer) {
        var tries = 0;
        timer = setInterval(function () {
          tries++;
          if (!busy() || tries > 80) { clearInterval(timer); timer = 0; scan(); }
        }, 300);
      }
      return;
    }
    d.setAttribute('data-done', '1');
    openCamp();
  }

  function talk(btn) {
    var d = btn.closest('dialog'), bub = d && d.querySelector('[data-tkcamp-bubble]');
    var lines = [];
    try { lines = JSON.parse(btn.getAttribute('data-lines') || '[]'); } catch (e) { lines = []; }
    if (!bub || !lines.length) return;
    var i = parseInt(btn.getAttribute('data-i') || '0', 10) % lines.length;
    btn.setAttribute('data-i', String((i + 1) % lines.length));
    Array.prototype.forEach.call(d.querySelectorAll('.tkcmem.talking'), function (n) { n.classList.remove('talking'); });
    if (btn.parentNode) btn.parentNode.classList.add('talking');
    bub.querySelector('b').textContent = btn.getAttribute('data-who') || '';
    bub.querySelector('p').textContent = lines[i];
    bub.querySelector('small').textContent = lines.length > 1 ? (i + 1) + ' / ' + lines.length + ' · tap Talk again' : '';
    bub.hidden = false;
  }

  document.addEventListener('click', function (ev) {
    var t = ev.target.closest ? ev.target.closest('[data-tkcamp-open],[data-tkcamp-close],[data-tkcamp-talk]') : null;
    if (!t) return;
    if (t.hasAttribute('data-tkcamp-open')) { ev.preventDefault(); openCamp(); }
    else if (t.hasAttribute('data-tkcamp-close')) { ev.preventDefault(); if (typeof gvCloseDlg === 'function') gvCloseDlg(t.closest('dialog')); }
    else { ev.preventDefault(); talk(t); }
  });

  document.addEventListener('change', function (ev) {
    var c = ev.target;
    if (!c || !c.hasAttribute || !c.hasAttribute('data-tkcamp-auto')) return;
    try { localStorage.setItem('gvCampAuto', c.checked ? '1' : '0'); } catch (e) { /* storage blocked: stays on */ }
  });

  /* the page is swapped in place after every POST: keep the switch in step and look for a fresh auto-open */
  function sync() {
    var c = document.querySelector('[data-tkcamp-auto]');
    if (c) c.checked = autoOk();
    scan();
  }
  sync();
  var main = document.querySelector('main') || document.body;
  if (window.MutationObserver) new MutationObserver(function () { sync(); }).observe(main, { childList: true, subtree: true });
})();
