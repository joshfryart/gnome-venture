/* v2.0.40: Trek drawers. Party, Pack and Log open in a side drawer over the map instead of replacing it, so the map and stage stay where they are.
   The drawer shows the same server page (?t=party etc.), loaded in the background. Forms in a drawer post in place; the map behind refreshes through
   the ordinary Map tab link. Without script the tabs are plain links, as before. */
(function () {
  'use strict';
  if (!window.fetch || !window.DOMParser) return;
  var drawer = null, current = '', syncing = false;
  document.body.classList.add('tkpage');

  function tabOf(a) {
    var u;
    try { u = new URL(a.href, location.href); } catch (e) { return ''; }
    if (u.origin !== location.origin || u.pathname !== location.pathname) return '';
    var t = u.searchParams.get('t') || 'map';
    return t === 'party' || t === 'pack' || t === 'log' ? t : '';
  }
  function ensure() {
    if (drawer) return drawer;
    drawer = document.createElement('aside');
    drawer.className = 'tkdrawer';
    drawer.hidden = true;
    drawer.setAttribute('role', 'dialog');
    var head = document.createElement('div');
    head.className = 'tkdhead';
    var title = document.createElement('b');
    title.className = 'tkdtitle';
    var x = document.createElement('button');
    x.type = 'button'; x.className = 'btn small alt tkdx'; x.setAttribute('aria-label', 'Close'); x.textContent = '✕';
    x.addEventListener('click', close);
    head.appendChild(title); head.appendChild(x);
    var body = document.createElement('div');
    body.className = 'tkdbody';
    drawer.appendChild(head); drawer.appendChild(body);
    drawer.addEventListener('submit', onSubmit);
    document.body.appendChild(drawer);
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !drawer.hidden && !document.querySelector('dialog[open]')) close(); });
    return drawer;
  }
  function fill(doc, tab) {
    var d = ensure();
    var main = doc.querySelector('main');
    var body = d.querySelector('.tkdbody');
    body.textContent = '';
    if (!main) return;
    [].forEach.call(main.children, function (n) {
      if (n.matches('h1, nav.tabs, .tksmuterow, .msglog, .flash')) return;
      body.appendChild(document.importNode(n, true));
    });
    d.querySelector('.tkdtitle').textContent = { party: '🧑‍🤝‍🧑 Party', pack: '🎒 Pack', log: '📜 Log' }[tab];
    d.setAttribute('aria-label', tab);
  }
  function get(tab) {
    return fetch(location.pathname + '?t=' + tab, { credentials: 'same-origin', headers: { 'X-Requested-With': 'fetch' } })
      .then(function (r) { return r.text(); })
      .then(function (html) { return new DOMParser().parseFromString(html, 'text/html'); });
  }
  function open(tab) {
    current = tab;
    return get(tab).then(function (doc) {
      fill(doc, tab);
      ensure().hidden = false;
      document.body.classList.add('tkdopen');
      markTabs();
    }).catch(function () { location.href = location.pathname + '?t=' + tab; });
  }
  function close() {
    if (!drawer) return;
    drawer.hidden = true;
    current = '';
    document.body.classList.remove('tkdopen');
    markTabs();
  }
  function markTabs() {
    [].forEach.call(document.querySelectorAll('main nav.tabs a'), function (a) {
      var t = tabOf(a) || ((new URL(a.href, location.href).searchParams.get('t') || 'map') === 'map' ? 'map' : '');
      if (current) a.classList.toggle('on', t === current);
      else if (t === 'map') a.classList.add('on');
    });
  }
  function refreshMap() {
    var m = document.querySelector('main nav.tabs a');   // the first tab is Map / Rest stop; site.js swaps the page in place
    if (!m || syncing) return;
    syncing = true;
    m.click();
    setTimeout(function () { syncing = false; }, 400);
  }
  function onSubmit(e) {
    var f = e.target;
    if ((f.method || '').toLowerCase() !== 'post') return;
    e.preventDefault();
    var fd = new FormData(f);
    var sub = e.submitter;
    if (sub && sub.name && !fd.has(sub.name)) fd.append(sub.name, sub.value);
    f.classList.add('sending');
    fetch(f.getAttribute('action') || location.href, { method: 'POST', body: new URLSearchParams(fd), credentials: 'same-origin', headers: { 'X-Requested-With': 'fetch' } })
      .then(function () { return get(current); })
      .then(function (doc) { fill(doc, current); refreshMap(); })
      .catch(function () { f.classList.remove('sending'); f.submit(); });
  }

  /* capture phase: runs before site.js's tab handler, which skips a click that is already handled */
  document.addEventListener('click', function (e) {
    if (syncing) return;
    var a = e.target.closest ? e.target.closest('main nav.tabs a') : null;
    if (!a || e.button !== 0 || e.ctrlKey || e.metaKey || e.shiftKey || e.altKey) return;
    var t = tabOf(a);
    if (t) { e.preventDefault(); e.stopPropagation(); open(t); }
    else if (drawer && !drawer.hidden) close();   // Map tab: close the drawer, then let the page do its usual in-place load
  }, true);
})();
