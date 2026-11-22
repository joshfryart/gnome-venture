/* 2.7.57 Creature Codex (includes/pfcodex.php, CSS .cx in assets/pfv1.css). Only adds to a page that works without it:
   draws each seen creature piece with the game's renderer (assets/pfparts47.js: PFParts.piece, the creature's own icons and colour, its number and edges);
   if the renderer does not load, the text card stays. The open sheet takes the focus, keeps Tab inside it, and Esc closes it (the close link, as without script).
   Runs again when the page content is swapped in place (data-rerun). */
(function () {
  function all(sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); }
  function draw() {
    var P = window.PFParts; if (!P || !P.ok) return;
    var list = all('.cx-pcs i.cxp'); if (!list.length) return;
    var host = document.querySelector('.cx-pcs[data-pico]'); if (host && !P.picoBase) P.picoBase = host.getAttribute('data-pico');
    var drawn = [], iks = [];
    list.forEach(function (h) {
      var o = null; try { o = JSON.parse(h.getAttribute('data-p')); } catch (e) { return; }
      if (!o || !o.e || !o.t) return;
      var opts = { size: 'hand', owner: 'foe', ik: o.ik || '', type: o.t, edges: o.e, tag: o.tag || '', num: String(o.v), tint: o.tint, old: false };
      var c; try { c = P.piece(opts); } catch (e) { return; }   // a piece the kit cannot draw keeps its text card
      c.className = 'cx-cv'; c.setAttribute('aria-hidden', 'true');
      var li = h.closest('.cx-pc'); h.parentNode.replaceChild(c, h); if (li) li.classList.add('cx-drawn');
      if (opts.ik) { drawn.push([c, opts]); iks.push(opts.ik); }
    });
    if (iks.length && P.picoBase && P.cicoLoad) P.cicoLoad(P.picoBase, iks, 'hand', function () {   // the creature's own piece icons: redraw once they arrive
      drawn.forEach(function (d) { if (!d[0].parentNode) return; var n; try { n = P.piece(d[1]); } catch (e) { return; } n.className = d[0].className; n.setAttribute('aria-hidden', 'true'); d[0].parentNode.replaceChild(n, d[0]); d[0] = n; });
    });
  }
  document.addEventListener('pfparts-ready', draw);
  draw();

  var sheet = document.getElementById('cx-sheet');
  if (!sheet) document.documentElement.classList.remove('cx-open');
  if (!sheet || sheet.getAttribute('data-cx-on') === '1') return;
  sheet.setAttribute('data-cx-on', '1');
  var x = sheet.querySelector('.cx-x');
  try { sheet.focus({ preventScroll: true }); } catch (e) { sheet.focus(); }
  document.documentElement.classList.add('cx-open');   // the page under the sheet does not scroll
  sheet.addEventListener('keydown', function (ev) {
    if (ev.key === 'Escape' && x) { ev.preventDefault(); x.click(); return; }
    if (ev.key !== 'Tab') return;
    var f = all('a[href], button:not([disabled]), [tabindex="0"]', sheet).filter(function (el) { return el.offsetParent !== null; });
    if (!f.length) return;
    var first = f[0], last = f[f.length - 1];
    if (ev.shiftKey && (document.activeElement === first || document.activeElement === sheet)) { ev.preventDefault(); last.focus(); }
    else if (!ev.shiftKey && document.activeElement === last) { ev.preventDefault(); first.focus(); }
  });
  document.addEventListener('keydown', function (ev) { if (ev.key === 'Escape' && x && document.contains(sheet) && !sheet.contains(document.activeElement)) { ev.preventDefault(); x.click(); } });
})();
