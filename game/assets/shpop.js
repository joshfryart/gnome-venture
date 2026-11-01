/* v2.5.0: Satchel tiles (includes/satchel_view.php). A tile opens a <dialog> sheet with that group's things: search, chips and sort run here,
   tapping a thing opens its panel in place (site.js shelves handler: the sheets sit inside .shelves). Without script the tiles are links (?cat=) to the plain list.
   Typing in the page search counts matches on each tile; Enter still searches on the server. No inline styles (CSP). */
(function () {
  'use strict';
  var back = null;
  function dlgOf(t) { return t.closest ? t.closest('dialog.shbagpop') : null; }
  function pairs(d) {   // [pill, panel] in the sheet
    var out = [];
    d.querySelectorAll('a.shpill').forEach(function (p, i) {
      if (p.getAttribute('data-i') === null) p.setAttribute('data-i', String(i));
      out.push([p, document.getElementById(p.getAttribute('data-pick'))]);
    });
    return out;
  }
  function apply(d) {   // search text + chip -> hide what does not match
    var q = (d.querySelector('[data-shpd-filter]') || {}).value || '';
    q = q.trim().toLowerCase();
    var chipEl = d.querySelector('.shpdchip.on'), chip = chipEl ? chipEl.getAttribute('data-shpd-chip') : '', n = 0;
    pairs(d).forEach(function (pr) {
      var p = pr[0], pan = pr[1];
      var hit = (q === '' || (p.getAttribute('data-hay') || '').indexOf(q) >= 0) &&
        (!chip || (chip === '*untasted' ? p.getAttribute('data-un') === '1' : p.getAttribute('data-cat') === chip));
      p.hidden = !hit;
      if (!hit && pan) { pan.hidden = true; p.classList.remove('sel'); p.setAttribute('aria-expanded', 'false'); }
      if (hit) n++;
    });
    d.querySelectorAll('details.shshelf').forEach(function (sh) { sh.hidden = false; sh.open = true; });
    var none = d.querySelector('.shpdnone'); if (none) none.hidden = n > 0;
  }
  function sortSheet(d, how) {
    var host = d.querySelector('.shpills'); if (!host) return;
    var prs = pairs(d), key = function (p) {
      var o = { qty: +p.getAttribute('data-qty') || 0, name: p.getAttribute('data-name') || '', got: p.getAttribute('data-got') || '', i: +p.getAttribute('data-i') || 0 };
      return o;
    };
    prs.sort(function (a, b) {
      var x = key(a[0]), y = key(b[0]);
      if (how === 'az') return x.name < y.name ? -1 : x.name > y.name ? 1 : 0;
      if (how === 'za') return x.name < y.name ? 1 : x.name > y.name ? -1 : 0;
      if (how === 'most') return y.qty - x.qty || (x.name < y.name ? -1 : 1);
      if (how === 'least') return x.qty - y.qty || (x.name < y.name ? -1 : 1);
      if (how === 'new') return x.got < y.got ? 1 : x.got > y.got ? -1 : 0;
      return x.i - y.i;
    });
    prs.forEach(function (pr) { host.appendChild(pr[0]); if (pr[1]) host.appendChild(pr[1]); });
  }
  document.addEventListener('click', function (ev) {
    var t = ev.target; if (!t.closest) return;
    var tile = t.closest('a.shtile[data-shpop]');
    if (tile && !ev.ctrlKey && !ev.metaKey && !ev.shiftKey && ev.button === 0) {
      var d0 = document.getElementById(tile.getAttribute('data-shpop'));
      if (d0 && window.gvOpenDlg) { ev.preventDefault(); back = tile; gvOpenDlg(d0); }
      return;
    }
    var d = dlgOf(t); if (!d) return;
    if (t.closest('[data-shpd-close]') || t === d) { gvCloseDlg(d); return; }
    var chip = t.closest('.shpdchip');
    if (chip) { d.querySelectorAll('.shpdchip').forEach(function (c) { c.classList.toggle('on', c === chip); }); apply(d); }
  });
  document.addEventListener('input', function (ev) {
    var t = ev.target, d = dlgOf(t);
    if (d && t.matches('[data-shpd-filter]')) { apply(d); return; }
    if (t.matches && t.matches('.shbagtiles input[data-shfilter]')) {   // the page search: count matches per tile
      var v = t.value.trim().toLowerCase();
      document.querySelectorAll('a.shtile[data-shpop]').forEach(function (tile) {
        var dd = document.getElementById(tile.getAttribute('data-shpop')); if (!dd) return;
        var n = 0; dd.querySelectorAll('a.shpill').forEach(function (p) { if (v !== '' && (p.getAttribute('data-hay') || '').indexOf(v) >= 0) n++; });
        var b = tile.querySelector('.shtm');
        if (v === '') { tile.classList.remove('dim'); if (b) b.remove(); return; }
        tile.classList.toggle('dim', n === 0);
        if (!b) { b = document.createElement('i'); b.className = 'shtm'; tile.appendChild(b); }
        b.textContent = String(n);
      });
    }
  });
  document.addEventListener('change', function (ev) {
    var t = ev.target, d = dlgOf(t);
    if (d && t.matches('[data-shpd-sort]')) sortSheet(d, t.value);
  });
  document.addEventListener('close', function (ev) {
    if (ev.target.classList && ev.target.classList.contains('shbagpop') && back) { try { back.focus(); } catch (e) {} back = null; }
  }, true);
  document.querySelectorAll('dialog.shbagpop[data-autoopen]').forEach(function (d) { if (window.gvOpenDlg) gvOpenDlg(d); });   // back from using an item: reopen its sheet
})();
