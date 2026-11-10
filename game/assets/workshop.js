/* The Crafting workshop picture (workshop.php): a tapped section opens its card, and the card loads the SAME section view the Satchel's Crafting tab shows
   (workshop.php?frag=<key>, html in json). Make / Collect forms post to the usual crafting.php with fetch (the redirect is not followed, so the result
   message stays for the reload), then the section is loaded again in place. Filter forms and recipe links reload the section with their query.
   No script: the card still has its link to the page. No inline styles or scripts (CSP). */
(function () {
  'use strict';
  function box(el) { return el && el.closest ? el.closest('.wsfrag') : null; }
  function load(b, qs) {
    if (!b) return Promise.resolve();
    b.setAttribute('aria-busy', 'true');
    var u = b.getAttribute('data-url') + '?frag=' + encodeURIComponent(b.getAttribute('data-frag')) + (qs ? '&' + qs : '');
    return fetch(u, { credentials: 'same-origin', headers: { 'X-Requested-With': 'fetch' } }).then(function (r) { return r.json(); }).then(function (j) {
      b.innerHTML = j && j.ok ? j.html : '<p class="flash err">That section could not be loaded. Use the page link below.</p>';
      b.setAttribute('data-loaded', '1');
    }).catch(function () {
      b.innerHTML = '<p class="flash err">That section could not be loaded. Use the page link below.</p>';
    }).then(function () { b.removeAttribute('aria-busy'); document.dispatchEvent(new Event('gv:swapped')); });
  }
  /* After an action the picture behind the card is stale (the ! badges, the chips, the card's "N recipes known" line, energy in the header).
     Fetch the page again, in the background, and copy just those parts over. The open card itself is never replaced. */
  function refreshScene() {
    var url = location.pathname + (location.search.replace(/[?&]o=[^&]*/g, '').replace(/^&/, '?') || '');
    return fetch(url, { credentials: 'same-origin', headers: { 'X-Requested-With': 'fetch' } }).then(function (r) { return r.text(); }).then(function (html) {
      var doc = new DOMParser().parseFromString(html, 'text/html');
      if (!doc.querySelector('.hubscene')) return;
      doc.querySelectorAll('.hubscene a.hs').forEach(function (n) {
        var cur = document.getElementById(n.id); if (!cur) return;
        var id = n.id.replace(/^hs-/, '');
        var bn = n.querySelector('.bang'), bc = cur.querySelector('.bang');
        if (bn && !bc) cur.appendChild(bn.cloneNode(true)); else if (!bn && bc) bc.remove();
        cur.setAttribute('aria-label', n.getAttribute('aria-label') || '');
        var chip = document.querySelector('a.hubchip[data-for="' + n.id + '"]'), nc = doc.querySelector('a.hubchip[data-for="' + n.id + '"]');
        if (chip && nc) chip.innerHTML = nc.innerHTML;
        var d = document.getElementById('hubpop-' + id), nd = doc.getElementById('hubpop-' + id);
        if (d && nd) {
          var a = d.querySelectorAll('.hubcard > p:not(:has(a.btn))'), b = nd.querySelectorAll('.hubcard > p:not(:has(a.btn))');
          for (var i = 0; i < a.length && i < b.length; i++) a[i].innerHTML = b[i].innerHTML;
        }
      });
      ['.statusstrip', '.userbar', '.advbar', '.railsrv'].forEach(function (sel) {
        var a = document.querySelector(sel), b = doc.querySelector(sel);
        if (a && b) a.innerHTML = b.innerHTML;
      });
    }).catch(function () {});
  }
  function fill(dlg) {
    var b = dlg && dlg.querySelector ? dlg.querySelector('.wsfrag:not([data-loaded])') : null;
    if (b) load(b, '');
  }
  document.addEventListener('click', function (ev) {
    var t = ev.target; if (!t.closest) return;
    var hs = t.closest('[data-pop]');
    if (hs && hs.closest('.hubscene')) { var d = document.getElementById(hs.getAttribute('data-pop')); if (d) fill(d); return; }
    var a = t.closest('.wsfrag a[href]');
    if (a && !ev.ctrlKey && !ev.metaKey && !ev.shiftKey && ev.button === 0) {
      var href = a.getAttribute('href') || '';
      if (/[?&]tab=craft/.test(href) && href.indexOf('inventory.php') !== -1) {
        ev.preventDefault();
        var p = new URLSearchParams(href.split('?')[1] || ''), c = p.get('c'), b = box(a);
        p.delete('tab'); p.delete('c');
        if (!c) { var dlg = a.closest('dialog'); if (dlg && window.gvCloseDlg) gvCloseDlg(dlg); return; }   // "All areas" = back to the picture
        b.setAttribute('data-frag', c);   // another area from the strip: the same card shows it
        load(b, p.toString());
      }
    }
  });
  document.addEventListener('submit', function (ev) {
    var f = ev.target; var b = box(f);
    if (!b) return;
    ev.preventDefault();
    var fd = new FormData(f);
    var sub = ev.submitter; if (sub && sub.name && !fd.has(sub.name)) fd.append(sub.name, sub.value);   // the button pressed (Make x5, All...) goes with the form
    if ((f.getAttribute('method') || 'get').toLowerCase() === 'post') {
      fetch(f.action, { method: 'POST', body: new URLSearchParams(fd), credentials: 'same-origin', redirect: 'manual', headers: { 'X-Requested-With': 'fetch' } })
        .then(function () { return load(b, ''); }, function () { return load(b, ''); })
        .then(refreshScene);
    } else {
      var p = new URLSearchParams(fd); p.delete('tab'); p.delete('c');
      load(b, p.toString());
    }
  });
  function boot() { document.querySelectorAll('dialog.hubpop[open]').forEach(fill); }
  document.addEventListener('DOMContentLoaded', boot);
  boot();
})();
