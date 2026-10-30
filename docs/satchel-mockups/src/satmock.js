/* MOCKUP ONLY: small helpers for the three Satchel / Crafting designs (strict CSP: an external file, no inline script). */
(function () {
  // design 2: the drawer sits under the sticky search + chips bar; tell the CSS how tall that bar is
  var bar = document.querySelector('.sm2 .smbar');
  if (bar) {
    var set = function () { document.documentElement.style.setProperty('--smbar', bar.offsetHeight + 'px'); };
    set(); window.addEventListener('resize', set);
  }
  // design 2 and 3: a pick reloads the page; keep the scroll position so the grid / shelf does not jump to the top
  var keep = document.querySelectorAll('.sm2 a.smmini, .sm2 .smx, .sm2 .smscrim, .sm3 a.smpill, .sm3 .smx');
  keep.forEach(function (a) {
    a.addEventListener('click', function () { try { sessionStorage.setItem('smy', String(window.scrollY)); } catch (e) {} });
  });
  try {
    var y = sessionStorage.getItem('smy');
    if (y !== null) {
      sessionStorage.removeItem('smy');
      if (location.hash) history.replaceState(null, '', location.pathname + location.search);
      window.scrollTo(0, parseInt(y, 10) || 0);
      var p = document.getElementById('smp');   // design 3: make sure the opened panel is in view
      if (p) { var r = p.getBoundingClientRect(); if (r.bottom > window.innerHeight - 70 || r.top < 60) p.scrollIntoView({ block: 'center' }); }
    }
  } catch (e) {}
  // design 3: remember which shelves are folded (per surface)
  document.querySelectorAll('.sm3 details.smshelf').forEach(function (d) {
    var k = 'smshelf:' + d.getAttribute('data-shelf');
    try { var v = localStorage.getItem(k); if (v !== null && !d.querySelector('.smpill.sel')) d.open = v === '1'; } catch (e) {}
    d.addEventListener('toggle', function () { try { localStorage.setItem(k, d.open ? '1' : '0'); } catch (e) {} });
  });
  // Escape closes an open drawer / panel
  document.addEventListener('keydown', function (ev) {
    if (ev.key !== 'Escape') return;
    var x = document.querySelector('.sm2 .smdrawer.is-open .smx, .sm3 .smpanel .smx');
    if (x) x.click();
  });
})();
