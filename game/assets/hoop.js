/* v2.0.44: the hoop map. Tap (or focus) a ring and the line under the map says what that tier is. Delegated, so it keeps working after site.js swaps the page. */
(function () {
  'use strict';
  function show(g) {
    var cap = g.closest('.mapwrap, .mapcol') ? g.closest('.mapwrap, .mapcol').querySelector('.hoopcap') : null;
    var t = g.getAttribute('data-lab');
    if (cap && t) cap.textContent = t;
  }
  document.addEventListener('click', function (e) { var g = e.target.closest ? e.target.closest('.hoopmap .hr') : null; if (g) show(g); });
  document.addEventListener('focusin', function (e) { var g = e.target.closest ? e.target.closest('.hoopmap .hr') : null; if (g) show(g); });
})();
