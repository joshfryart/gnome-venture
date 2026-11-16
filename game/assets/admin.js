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

// 2.7.04: Recent and Pinned pages (this browser only), and "Changed" marks on the settings form. Nothing here is needed to use the admin.
(function () {
  'use strict';
  var RK = 'gv-admin-recent', PK = 'gv-admin-pins';
  function load(k) { try { var v = JSON.parse(localStorage.getItem(k) || '[]'); return Array.isArray(v) ? v : []; } catch (e) { return []; } }
  function save(k, v) { try { localStorage.setItem(k, JSON.stringify(v)); } catch (e) { /* storage may be off */ } }
  var path = location.pathname + location.search;
  var isHome = /\/admin\/(index\.php)?$/.test(location.pathname);
  var h1 = document.querySelector('main h1');
  var name = h1 ? h1.textContent.replace(/\s+/g, ' ').trim() : document.title;
  function esc(s) { return String(s).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }
  // remember this page
  if (!isHome && name) {
    var r = load(RK).filter(function (x) { return x.u !== path; });
    r.unshift({ u: path, n: name });
    save(RK, r.slice(0, 8));
  }
  // pin button in the breadcrumb bar
  var crumbs = document.querySelector('.acrumbs');
  if (crumbs && !isHome) {
    var b = document.createElement('button');
    b.type = 'button'; b.className = 'apin';
    var paint = function () {
      var on = load(PK).some(function (x) { return x.u === path; });
      b.setAttribute('aria-pressed', on ? 'true' : 'false');
      b.textContent = on ? 'Pinned' : 'Pin this page';
    };
    b.addEventListener('click', function () {
      var p = load(PK), i = p.findIndex(function (x) { return x.u === path; });
      if (i >= 0) p.splice(i, 1); else p.unshift({ u: path, n: name });
      save(PK, p.slice(0, 12)); paint();
    });
    paint(); crumbs.appendChild(b);
  }
  // dashboard lists
  var host = document.getElementById('aquick');
  if (host) {
    var pins = load(PK), rec = load(RK).filter(function (x) { return !pins.some(function (p) { return p.u === x.u; }); }).slice(0, 6);
    var list = function (id, title, items) {
      if (!items.length) return '';
      return '<div class="aqcol"><h3 id="' + id + '">' + title + '</h3><ul aria-labelledby="' + id + '">' + items.map(function (x) {
        return '<li><a href="' + esc(x.u) + '">' + esc(x.n) + '</a></li>';
      }).join('') + '</ul></div>';
    };
    var html = list('aq-pins', 'Pinned', pins) + list('aq-rec', 'Recent', rec);
    if (html) { host.innerHTML = '<div class="aph"><h2>Jump back in</h2></div><div class="aqbody">' + html + '</div>'; host.hidden = false; }
  }
  // settings: mark changed fields, count them in the sticky save bar
  var form = document.querySelector('form.form'), bar = form && form.querySelector('.savebar');
  if (form && bar && document.querySelector('.setsec')) {
    var count = document.createElement('span'); count.className = 'savecount'; count.setAttribute('aria-live', 'polite');
    bar.insertBefore(count, bar.firstChild);
    var changed = {};
    var update = function () { var n = Object.keys(changed).length; count.textContent = n ? n + ' unsaved change' + (n === 1 ? '' : 's') : 'No changes yet'; bar.classList.toggle('dirty', n > 0); };
    var init = {};
    Array.prototype.forEach.call(form.querySelectorAll('[name^="s["]'), function (el) {
      init[el.name] = el.type === 'checkbox' ? el.checked : el.value;
      var onch = function () {
        var cur = el.type === 'checkbox' ? el.checked : el.value, lab = el.closest('label');
        if (cur !== init[el.name]) changed[el.name] = 1; else delete changed[el.name];
        if (lab) lab.classList.toggle('chg', cur !== init[el.name]);
        update();
      };
      el.addEventListener('input', onch); el.addEventListener('change', onch);
    });
    update();
    window.addEventListener('beforeunload', function (e) { if (Object.keys(changed).length && !form.dataset.sub) { e.preventDefault(); e.returnValue = ''; } });
    form.addEventListener('submit', function () { form.dataset.sub = '1'; });
  }
})();
