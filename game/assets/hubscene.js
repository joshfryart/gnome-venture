/* Graphical navigation: the picture pages (includes/hub_scene.php). A tap on a hotspot opens its card as a <dialog>; without this script
   the hotspot is still a link (?o=<id>) and the card shows under the picture. Hover or focus on a hotspot lights its legend chip and back.
   Esc, the X and a tap outside close the card; focus goes back to the hotspot. No inline styles or scripts (CSP), no body scroll lock. */
(function () {
  'use strict';
  var back = null;
  function plain(ev) { return !ev.ctrlKey && !ev.metaKey && !ev.shiftKey && ev.button === 0; }
  document.addEventListener('click', function (ev) {
    var t = ev.target;
    if (!t.closest) return;
    var hs = t.closest('[data-pop]');
    if (hs && hs.closest('.hubscene, .gnavtools, .trailui') && plain(ev)) {
      var d = document.getElementById(hs.getAttribute('data-pop'));
      if (d && window.gvOpenDlg) {
        ev.preventDefault();
        document.querySelectorAll('dialog.hubpop[open]').forEach(function (o) { if (o !== d) { if (o.close) o.close(); else o.removeAttribute('open'); } });   // one card at a time
        if (d.hasAttribute('open') && !d.matches(':modal')) d.removeAttribute('open');   // a no-JS card shown inline: reopen it as a real modal
        document.querySelectorAll('.hubscene .on').forEach(function (o) { o.classList.remove('on'); });
        hs.classList.add('on');   // tapped state: gold brackets + lit tag (chrome pictures)
        back = hs; gvOpenDlg(d); lazyLoad(d);
      }
      return;
    }
    var dlg = t.closest('dialog.hubpop');
    if (!dlg) return;
    if (t.closest('[data-pop-close]')) { ev.preventDefault(); gvCloseDlg(dlg); return; }
    if (t === dlg) gvCloseDlg(dlg);   // the dimmed area around the box
  });
  function link(ev, on) {
    var t = ev.target;
    if (!t.closest) return;
    var a = t.closest('a.hs, a.hubchip');
    if (!a) return;
    var id = a.classList.contains('hs') ? a.id : a.getAttribute('data-for');
    var other = a.classList.contains('hs') ? document.querySelector('a.hubchip[data-for="' + id + '"]') : document.getElementById(id);
    if (other && other.classList) other.classList.toggle('lit', on);
  }
  document.addEventListener('mouseover', function (ev) { link(ev, true); });
  document.addEventListener('mouseout', function (ev) { link(ev, false); });
  document.addEventListener('focusin', function (ev) { link(ev, true); });
  document.addEventListener('focusout', function (ev) { link(ev, false); });
  document.addEventListener('close', function (ev) {   // 'close' does not bubble: capture phase
    if (ev.target.classList && ev.target.classList.contains('hubpop') && back) { back.classList.remove('on'); try { back.focus(); } catch (e) {} back = null; }
  }, true);
  /* The encounter on a Trail walk is a popover that cannot be dismissed until it is settled: open it as a real modal on load and after an in-place page swap. */
  function trailPops() {
    document.querySelectorAll('dialog.trailpop').forEach(function (d) {
      if (d.getAttribute('data-up')) return;
      d.setAttribute('data-up', '1');
      d.addEventListener('cancel', function (ev) { ev.preventDefault(); });   // Esc does nothing
      if (d.showModal && !d.matches(':modal')) { try { d.close(); d.showModal(); } catch (e) {} }
      d.setAttribute('tabindex', '-1'); try { d.focus({ preventScroll: true }); } catch (e) {}   // no stray focus ring on the first fold
    });
  }
  // the Trail map is the page: centre it on screen after a load or an in-place swap
  function centreMap() {
    var t = document.querySelector('.trailstrip');
    if (!t || !document.querySelector('.tmwrap')) return;
    var r = t.getBoundingClientRect(), m = document.querySelector('.tmwrap').getBoundingClientRect();
    if (r.top < 0 || r.top > 120 || m.bottom > window.innerHeight - 70) t.scrollIntoView({ block: 'start' });   // strip + map in view (scroll-margin-top clears the header)
  }
  document.addEventListener('DOMContentLoaded', centreMap);
  document.addEventListener('gv:swapped', centreMap);
  window.addEventListener('load', function () { centreMap(); setTimeout(centreMap, 250); });
  document.addEventListener('DOMContentLoaded', trailPops);
  document.addEventListener('gv:swapped', trailPops);
  trailPops();

  /* A villager's popover: the villager panel (chat, gift picker, trade) loads into the card when it opens; its forms post in place (same JSON as villagers.php). */
  function ask(url, init) {
    return fetch(url, init).then(function (r) { return r.json(); }).catch(function () { return { ok: false, msg: 'Could not reach the server. Check your connection and try again.', html: '' }; });
  }
  function fill(box, res) {
    box.innerHTML = res.html || '';
    if (!res.html) { var p = document.createElement('p'); p.className = 'vmsg err'; p.textContent = res.msg || 'Could not load.'; box.appendChild(p); }
  }
  /* A shop's popover: the shop page (counter, Buy / Sell, volunteer) is fetched and its main is shown in the card; its links and forms stay in place. */
  function pageFill(box, html, url) {
    var doc = new DOMParser().parseFromString(html, 'text/html'), m = doc.querySelector('main#main');
    if (!m) { box.innerHTML = '<p class="vmsg err">Could not load.</p>'; return; }
    m.querySelectorAll('.crumbs, header.ph, h1, script, .newpages').forEach(function (n) { n.remove(); });
    box.setAttribute('data-cur', url);
    box.innerHTML = m.innerHTML;
    if (box.hasAttribute('data-list') || box._list) {
      var p = document.createElement('p'); p.className = 'vmore';
      p.innerHTML = '<a href="#" data-shback>\u2039 All shops</a>';
      box.insertBefore(p, box.firstChild);
    }
  }
  function loadPage(box, url, init) {
    fetch(url, init || { credentials: 'same-origin' }).then(function (r) {
      if (!/\/shop\.php/.test(r.url)) { window.location.href = r.url; return null; }
      return r.text().then(function (t) { pageFill(box, t, r.url); });
    }).catch(function () { box.innerHTML = '<p class="vmsg err">Could not reach the server. Check your connection and try again.</p>'; });
  }
  document.addEventListener('click', function (ev) {
    var a = ev.target.closest ? ev.target.closest('.shpage a[href], .shpage a[data-shback]') : null;
    if (!a || ev.button !== 0 || ev.ctrlKey || ev.metaKey) return;
    var box = a.closest('.shpage');
    if (a.hasAttribute('data-shback')) { ev.preventDefault(); ev.stopPropagation(); if (box._list != null) { box.innerHTML = box._list; box._list = null; } return; }
    if (!/\/shop\.php(\?|$)/.test(a.getAttribute('href'))) return;   // other links leave the card as normal
    ev.preventDefault(); ev.stopPropagation();
    if (box.hasAttribute('data-list') && box._list == null) box._list = box.innerHTML;
    loadPage(box, a.href);
  }, true);
  function lazyLoad(d) {
    var pg = d && d.querySelector ? d.querySelector('.vlazy[data-page]') : null;
    if (pg && !pg.getAttribute('data-ready')) { pg.setAttribute('data-ready', '1'); loadPage(pg, pg.getAttribute('data-page')); return; }
    var box = d && d.querySelector ? d.querySelector('.vlazy[data-get]') : null;
    if (!box || box.getAttribute('data-ready')) return;
    box.setAttribute('data-ready', '1');
    ask(box.getAttribute('data-get'), { credentials: 'same-origin', headers: { 'X-Requested-With': 'fetch' } }).then(function (res) { fill(box, res); });
  }
  document.addEventListener('submit', function (ev) {
    var sf = ev.target.closest ? ev.target.closest('.shpage form') : null;
    if (sf) {
      ev.preventDefault(); ev.stopPropagation();
      var sb = sf.closest('.shpage'), sbtn = sf.querySelector('button'); if (sbtn) sbtn.disabled = true;
      var fd2 = new FormData(sf);
      loadPage(sb, sf.getAttribute('action') || sb.getAttribute('data-cur') || window.location.href, { method: 'POST', body: fd2, credentials: 'same-origin' });
      return;
    }
    var f = ev.target.closest ? ev.target.closest('.vlazy [data-vform], .vlazy [data-sform]') : null;
    if (!f) return;
    ev.preventDefault(); ev.stopPropagation();   // capture phase, after the seed/food picker handler: nothing else swaps the page
    var box = f.closest('.vlazy');
    var fd = new FormData(f); fd.set('csrf', box.getAttribute('data-csrf'));
    var b = f.querySelector('button'); if (b) b.disabled = true;
    ask(f.hasAttribute('data-sform') ? f.getAttribute('action') : box.getAttribute('data-url'), { method: 'POST', body: fd, credentials: 'same-origin', headers: { 'X-Requested-With': 'fetch' } }).then(function (res) { fill(box, res); });
  }, true);
  /* a face in a place card opens that villager's popover when they are standing in the street line, else their page */
  document.addEventListener('click', function (ev) {
    var a = ev.target.closest ? ev.target.closest('a.sface[data-nid]') : null;
    if (!a || !(ev.button === 0) || ev.ctrlKey || ev.metaKey) return;
    var link = document.getElementById('sp-n' + a.getAttribute('data-nid'));
    if (link && link.click) { ev.preventDefault(); var dlg = a.closest('dialog.hubpop'); if (dlg && window.gvCloseDlg) gvCloseDlg(dlg); link.click(); }
  });
  document.addEventListener('DOMContentLoaded', function () { document.querySelectorAll('dialog.hubpop[open]').forEach(lazyLoad); });

  /* Routes card: a pin on the little map picks that route's row (opens it, closes the others); the first row starts open */
  document.addEventListener('click', function (ev) {
    var pin = ev.target.closest ? ev.target.closest('a.rmpin[data-route]') : null;
    if (!pin) return;
    ev.preventDefault();
    var card = pin.closest('.hubcard');
    var row = card && card.querySelector('#hroute-' + pin.getAttribute('data-route'));
    if (!row) return;
    card.querySelectorAll('details.hroute[open]').forEach(function (d) { if (d !== row) d.removeAttribute('open'); });
    row.setAttribute('open', '');
    card.querySelectorAll('a.rmpin.sel').forEach(function (a) { a.classList.remove('sel'); });
    pin.classList.add('sel');
    if (row.scrollIntoView) row.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
  });
  document.addEventListener('toggle', function (ev) {   // opening a row by hand moves the ring to its pin
    var d = ev.target;
    if (!d.classList || !d.classList.contains('hroute') || !d.open) return;
    var card = d.closest('.hubcard'); if (!card) return;
    var id = (d.id || '').replace('hroute-', '');
    card.querySelectorAll('a.rmpin').forEach(function (a) { a.classList.toggle('sel', a.getAttribute('data-route') === id); });
  }, true);
})();
