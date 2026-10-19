// v1.6.3: Admin menu — find box and remembered open sections. Nothing here is needed to use the menu.
(function () {
  'use strict';
  var menu = document.getElementById('amenu');
  if (!menu) return;
  var KEY = 'gv-admin-open';
  var secs = Array.prototype.slice.call(menu.querySelectorAll('details.asec'));
  var saved = null;
  try { saved = JSON.parse(localStorage.getItem(KEY) || 'null'); } catch (e) { saved = null; }
  if (saved && typeof saved === 'object') {
    secs.forEach(function (d) { var id = d.getAttribute('data-sec'); if (id in saved) d.open = !!saved[id]; });
  }
  function store() {
    var o = {};
    secs.forEach(function (d) { o[d.getAttribute('data-sec')] = d.open ? 1 : 0; });
    try { localStorage.setItem(KEY, JSON.stringify(o)); } catch (e) { /* storage may be off */ }
  }
  var filtering = false;
  secs.forEach(function (d) { d.addEventListener('toggle', function () { if (!filtering) store(); }); });
  // coming from a breadcrumb (#sec-players): open that section
  if (location.hash.indexOf('#sec-') === 0) {
    var t = document.getElementById(location.hash.slice(1));
    if (t && t.tagName === 'DETAILS') t.open = true;
  }
  var wrap = document.getElementById('afindwrap'), box = document.getElementById('afind'), none = document.getElementById('anone');
  if (!wrap || !box) return;
  wrap.hidden = false;
  var before = null;
  function run() {
    var q = box.value.toLowerCase().trim().split(/\s+/).filter(Boolean);
    if (q.length && !filtering) { filtering = true; before = secs.map(function (d) { return d.open; }); }
    var shown = 0;
    secs.forEach(function (d, i) {
      var hit = 0;
      Array.prototype.forEach.call(d.querySelectorAll('.choice'), function (a) {
        var f = a.getAttribute('data-find') || '';
        var ok = q.every(function (w) { return f.indexOf(w) !== -1; });
        a.hidden = !ok; if (ok) hit++;
      });
      d.classList.toggle('is-empty', q.length > 0 && hit === 0);
      if (q.length) d.open = hit > 0;
      shown += hit;
    });
    if (!q.length && filtering) {
      secs.forEach(function (d, i) { d.open = before ? before[i] : d.open; });
      filtering = false; before = null;
    }
    if (none) none.hidden = !(q.length && shown === 0);
  }
  box.addEventListener('input', run);
  box.addEventListener('search', run);
  box.addEventListener('keydown', function (e) {
    if (e.key !== 'Enter') return;
    var first = menu.querySelector('.choice:not([hidden])');
    if (first && box.value.trim()) { e.preventDefault(); first.click(); }
  });
})();
