document.addEventListener("DOMContentLoaded",function(){
/* ===== pj JS BEGIN: proposed game/assets/paljobs.js ===== */
/* v2.3.1: Pal Jobs (paljobs.php). The page works without this; it adds:
   - the ledger countdown + bars (and a Collect button when a trip or delve is due, no reload needed: collect settles it server-side);
   - one job draft at a time (picking a pal on one post clears the others), a Cancel, and "Send <name>";
   - the first 5 pals per post with "Show all N pals";
   - a -/+ stepper on the potion count;
   - the "Back at ..." line for the chosen length. No inline styles (CSP): only classes, attributes and text. */
(function () {
  'use strict';
  var root = document.querySelector('.pjpage');
  if (!root) return;
  var SHOW = 5;
  var skew = (parseInt(root.getAttribute('data-pj-now'), 10) || 0) * 1000 - Date.now();   // server clock minus this clock
  var now = function () { return Date.now() + skew; };
  var pad = function (n) { return (n < 10 ? '0' : '') + n; };
  var hm = function (t) { var d = new Date(t); return pad(d.getHours()) + ':' + pad(d.getMinutes()); };
  var day = function (t) { var d = new Date(t); return d.getDate() + ' ' + d.toLocaleString('en', { month: 'short' }) + ', ' + hm(t); };
  function ago(secs) {   // same words as pj_ago()
    secs = Math.max(0, Math.round(secs));
    if (secs < 3600) return Math.max(1, Math.ceil(secs / 60)) + ' min';
    var h = Math.floor(secs / 3600), m = Math.floor(secs % 3600 / 60);
    return h + ' h' + (m ? ' ' + m + ' min' : '');
  }

  /* 1. the ledger ticks */
  function tick() {
    root.querySelectorAll('[data-pj-end]').forEach(function (row) {
      var t0 = +row.getAttribute('data-pj-start') * 1000, t1 = +row.getAttribute('data-pj-end') * 1000, t = now();
      var bar = row.querySelector('.pjbar'), eta = row.querySelector('[data-pj-eta]');
      var pct = Math.max(2, Math.min(100, Math.round(100 * (t - t0) / Math.max(1, t1 - t0))));
      if (bar) { bar.value = pct; }
      if (t < t1) { if (eta) eta.textContent = ago((t1 - t) / 1000); return; }
      row.removeAttribute('data-pj-end');
      row.classList.add('is-ready');
      if (eta) eta.textContent = 'Ready';
      row.querySelectorAll('[data-pj-hide-at-zero]').forEach(function (e) { e.hidden = true; });
      row.querySelectorAll('[data-pj-show-at-zero]').forEach(function (e) { e.hidden = false; });
      var who = row.querySelector('.pjwho small');
      if (who) who.textContent = who.textContent.replace(/·.*$/, '· back home');
    });
  }
  if (root.querySelector('[data-pj-end]')) { tick(); setInterval(tick, 1000); }

  /* 2-5. the job posts */
  var forms = Array.prototype.slice.call(root.querySelectorAll('form.pjform'));
  function picked(f) { return f.querySelector('input[name="pal"]:checked'); }
  function nameOf(input) { var n = input && input.closest('.pjface').querySelector('.pjnm'); return n ? n.textContent : ''; }
  function checkedVal(f, name) { var r = f.querySelector('input[name="' + name + '"]:checked'); return r ? +r.value : 0; }
  function update(f) {
    var p = picked(f), kind = f.getAttribute('data-pj-kind'), send = f.querySelector('[data-pj-send] span'), back = f.querySelector('[data-pj-back]');
    if (send) send.textContent = p ? 'Send ' + nameOf(p) : 'Send';
    if (!back) return;
    var t = now();
    if (kind === 'garden') back.textContent = 'Back on ' + day(t + checkedVal(f, 'days') * 864e5) + '.';
    else if (kind === 'trip') back.textContent = 'Back at ' + hm(t + checkedVal(f, 'hours') * 36e5) + ', sooner if HP runs out.';
    else back.textContent = 'Back at about ' + hm(t + 36e5) + '.';
  }
  forms.forEach(function (f) {
    var btn = f.querySelector('[data-pj-send]');
    if (btn) {   // "Send" + a Cancel that closes the draft
      btn.textContent = '';
      btn.appendChild(document.createElement('span')).textContent = 'Send';
      var go = document.createElement('div');
      go.className = 'pjgo';
      btn.parentNode.insertBefore(go, btn);
      go.appendChild(btn);
      var cancel = document.createElement('button');
      cancel.type = 'button';
      cancel.className = 'linkbtn';
      cancel.textContent = 'Cancel';
      cancel.addEventListener('click', function () {
        var p = picked(f);
        if (p) { p.checked = false; update(f); p.focus(); }
      });
      go.appendChild(cancel);
    }
    var faces = f.querySelectorAll('.pjfaces > li');   // the best few first; the rest behind a button
    if (faces.length > SHOW + 1) {
      for (var i = SHOW; i < faces.length; i++) faces[i].hidden = true;
      var more = document.createElement('button');
      more.type = 'button';
      more.className = 'linkbtn pjmore';
      more.textContent = 'Show all ' + faces.length + ' pals';
      more.addEventListener('click', function () {
        faces.forEach(function (li) { li.hidden = false; });
        more.remove();
        var nxt = faces[SHOW] && faces[SHOW].querySelector('input:not(:disabled)');
        if (nxt) nxt.focus();
      });
      f.querySelector('.pjfaces').after(more);
    }
    f.querySelectorAll('input[data-pj-step]').forEach(function (inp) {   // potion stepper: big targets, never past min/max
      var wrap = document.createElement('div');
      wrap.className = 'pjstepper';
      wrap.setAttribute('role', 'group');
      wrap.setAttribute('aria-label', 'Potions to pack');
      var mk = function (d, label, txt) {
        var b = document.createElement('button');
        b.type = 'button';
        b.setAttribute('aria-label', label);
        b.textContent = txt;
        b.addEventListener('click', function () {
          var v = Math.max(+inp.min || 0, Math.min(+inp.max || 0, (+inp.value || 0) + d));
          inp.value = v;
          sync();
          if (b.disabled) (d < 0 ? up : down).focus();
        });
        return b;
      };
      var down = mk(-1, 'One fewer', '−'), up = mk(1, 'One more', '+');
      var sync = function () { down.disabled = +inp.value <= (+inp.min || 0); up.disabled = +inp.value >= (+inp.max || 0); };
      inp.parentNode.insertBefore(wrap, inp);
      wrap.appendChild(down); wrap.appendChild(inp); wrap.appendChild(up);
      inp.addEventListener('input', sync);
      sync();
    });
    f.addEventListener('change', function (ev) {
      if (ev.target.name === 'pal' && ev.target.checked) {   // one draft at a time
        forms.forEach(function (o) { if (o !== f && picked(o)) { picked(o).checked = false; update(o); } });
      }
      update(f);
    });
    f.addEventListener('keydown', function (ev) {   // Esc closes the draft
      if (ev.key === 'Escape' && picked(f)) { var p = picked(f); p.checked = false; update(f); p.focus(); }
    });
    f.addEventListener('submit', function () {   // a second tap does nothing (the server is safe anyway: the pal is claimed in one UPDATE)
      if (btn) { setTimeout(function () { btn.disabled = true; }, 0); }
    });
    update(f);
  });
})();

  /* unfold: each job post shows a "Send a pal" button; the form opens under it. One open at a time. Without JS the forms stay open. */
  (function () {
    var root = document.querySelector('.pjpage');
    if (!root) return;
    var forms = [].slice.call(root.querySelectorAll('form.pjform'));
    var opens = [];
    var reset = function (f) {   // back to the first-load state: nothing picked, button live
      f.reset();
      f.querySelectorAll('[data-pj-send]').forEach(function (b) { b.disabled = false; });
      f.dispatchEvent(new Event('change', { bubbles: true }));
    };
    var close = function (f, focus) {
      var b = f.pjOpen;
      reset(f); f.hidden = true;
      if (b) { b.setAttribute('aria-expanded', 'false'); if (focus) b.focus(); }
    };
    forms.forEach(function (f) {   // an equipped pal needs the "take off my party" box ticked (it is only shown for such a pal)
      var cb = f.querySelector('input[name="unequip"]');
      if (!cb) return;
      f.addEventListener('change', function () { var p = f.querySelector('input[name="pal"]:checked'); cb.required = !!(p && p.hasAttribute('data-pj-party')); if (!cb.required) cb.checked = false; });
    });
    forms.forEach(function (f, i) {
      f.setAttribute('autocomplete', 'off');   // Firefox would restore a half-filled form after a reload or Back
      var b = document.createElement('button');
      b.type = 'button'; b.className = 'btn pjopen';
      b.setAttribute('aria-expanded', 'false'); b.setAttribute('aria-controls', f.id || (f.id = 'pjform-' + i));
      b.innerHTML = '<span>Send a pal</span>';
      f.parentNode.insertBefore(b, f);
      f.pjOpen = b; opens.push(b);
      f.hidden = true;
      b.addEventListener('click', function () {
        if (!f.hidden) { close(f); return; }
        forms.forEach(function (o) { if (o !== f && !o.hidden) close(o); });
        f.hidden = false; b.setAttribute('aria-expanded', 'true');
        var first = f.querySelector('input[name="pal"]:not(:disabled)');
        if (first) first.focus({ preventScroll: true });
        f.scrollIntoView({ block: 'nearest' });
      });
      f.addEventListener('keydown', function (ev) {   // Esc folds the form (the draft clear above runs first on the same key)
        if (ev.key === 'Escape' && !f.querySelector('input[name="pal"]:checked')) close(f, true);
      });
      f.querySelectorAll('.linkbtn').forEach(function (c) {   // Cancel folds the form too
        c.addEventListener('click', function () { setTimeout(function () { close(f, true); }, 0); });
      });
    });
    // Back/Forward or a failed post can bring the page back from the cache with a disabled Send and old picks.
    window.addEventListener('pageshow', function (ev) { if (ev.persisted) forms.forEach(function (f) { close(f); }); });
  })();

  /* tabs: Out / At home / Jobs. Without JS all three stack as before. */
  (function () {
    var root = document.querySelector('.pjpage');
    if (!root) return;
    var secs = [['out', 'Out', root.querySelector('.pjledger')], ['home', 'At home', root.querySelector('.pjathome')], ['jobs', 'Jobs', root.querySelector('#pjboard')]]
      .filter(function (x) { return x[2]; });
    if (secs.length < 3) return;
    var list = document.createElement('div');
    list.className = 'pjtabs'; list.setAttribute('role', 'tablist'); list.setAttribute('aria-label', 'Pal Jobs');
    var tabs = secs.map(function (x) {
      var b = document.createElement('button');
      b.type = 'button'; b.className = 'pjtab'; b.id = 'pjtab-' + x[0]; b.setAttribute('role', 'tab');
      b.setAttribute('aria-controls', x[2].id || (x[2].id = 'pjpanel-' + x[0]));
      b.innerHTML = '<span>' + x[1] + '</span><i class="pjtabn" data-n></i>';
      x[2].setAttribute('role', 'tabpanel'); x[2].setAttribute('aria-labelledby', b.id);
      list.appendChild(b);
      return b;
    });
    var top = root.querySelector('.pjtop');
    top.parentNode.insertBefore(list, top.nextSibling);
    root.classList.add('pj-tabbed');
    var show = function (i, focus) {
      secs.forEach(function (x, k) { x[2].hidden = k !== i; tabs[k].setAttribute('aria-selected', k === i ? 'true' : 'false'); tabs[k].tabIndex = k === i ? 0 : -1; });
      if (focus) tabs[i].focus();
    };
    var count = function () {
      var out = secs[0][2].querySelectorAll('.pjrow:not(.pjfree)').length, home = secs[1][2].querySelectorAll('.pjrow').length, ready = secs[0][2].querySelectorAll('.is-ready').length;
      tabs[0].querySelector('[data-n]').textContent = out ? out : '';
      tabs[1].querySelector('[data-n]').textContent = home ? home : '';
      tabs[0].classList.toggle('has-ready', ready > 0);
      tabs[0].setAttribute('aria-label', 'Out' + (out ? ', ' + out : '') + (ready ? ', ' + ready + ' ready to collect' : ''));
    };
    tabs.forEach(function (b, i) {
      b.addEventListener('click', function () { show(i); });
      b.addEventListener('keydown', function (ev) {
        var d = ev.key === 'ArrowRight' ? 1 : ev.key === 'ArrowLeft' ? -1 : 0;
        if (ev.key === 'Home') { ev.preventDefault(); show(0, true); } else if (ev.key === 'End') { ev.preventDefault(); show(2, true); }
        else if (d) { ev.preventDefault(); show((i + d + 3) % 3, true); }
      });
    });
    root.addEventListener('click', function (ev) {   // "Pick a job" on a free slot
      var a = ev.target.closest && ev.target.closest('a[href="#pjboard"]');
      if (a) { ev.preventDefault(); show(2); secs[2][2].scrollIntoView(); tabs[2].focus(); }
    });
    count(); setInterval(count, 1000);
    // A post redirects back here. Success: land on Out (the pal is there). Error: land on the tab you posted from, so the message sits by the form.
    var KEY = 'pj-from', from = null;
    try { from = sessionStorage.getItem(KEY); sessionStorage.removeItem(KEY); } catch (e) {}
    root.addEventListener('submit', function (ev) {
      var k = secs.findIndex(function (x) { return x[2].contains(ev.target); });
      try { if (k > -1) sessionStorage.setItem(KEY, String(k)); } catch (e) {}
    });
    var failed = !!document.querySelector('.flash.err');
    var start = location.hash === '#pjboard' || !secs[0][2].querySelector('.pjrow:not(.pjfree)') ? 2 : 0;
    if (failed && from !== null && secs[+from]) start = +from;
    show(start);
    window.addEventListener('pageshow', function (ev) { if (ev.persisted) show(start); });
  })();

/* ===== pj JS END ===== */
});
