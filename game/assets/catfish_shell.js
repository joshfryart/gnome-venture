/* Cat Fish room2 shell (setting catfish_room2): the shop drawer and a one-time "turn your phone" chip.
   Without this script the drawer is just a normal block under the room (CSS only slides it once .cfr2.js is set). No inline script (CSP). */
(function () {
  var page = document.querySelector('.cfpage.cfr2'), drawer = document.getElementById('cf-drawer'); if (!page || !drawer) return;
  var btn = document.getElementById('cf-shopbtn'), scrim = document.getElementById('cf-scrim'), x = document.getElementById('cf-dclose');
  var wide = window.matchMedia ? window.matchMedia('(min-width: 1000px)') : { matches: false };
  function store(k, v) { try { if (v === undefined) return window.localStorage.getItem(k); window.localStorage.setItem(k, v); } catch (e) {} return null; }
  page.classList.add('js');
  /* drawer tabs: Shop (upgrades), Shelter (adopt), More (the hub). The panels are the .cfdp blocks; without this script they are all shown. */
  var panels = [].slice.call(drawer.querySelectorAll('.cfdp')), head = document.createElement('div'), tl = document.createElement('div');
  head.className = 'cfdhead'; tl.className = 'cfdtabs'; tl.setAttribute('role', 'tablist'); tl.setAttribute('aria-label', 'Shop sections');
  var tabs = panels.map(function (pn, i) {
    var b = document.createElement('button'); b.type = 'button'; b.setAttribute('role', 'tab'); b.id = 'cf-dt-' + pn.getAttribute('data-tab'); b.textContent = pn.getAttribute('data-label') || pn.getAttribute('data-tab');
    pn.setAttribute('role', 'tabpanel'); pn.setAttribute('aria-labelledby', b.id); b.addEventListener('click', function () { pick(pn.getAttribute('data-tab')); }); tl.appendChild(b); return b;
  });
  function pick(name) {
    if (!panels.some(function (pn) { return pn.getAttribute('data-tab') === name; })) name = 'shop';
    panels.forEach(function (pn, i) { var on = pn.getAttribute('data-tab') === name; pn.hidden = !on; tabs[i].setAttribute('aria-selected', on ? 'true' : 'false'); tabs[i].tabIndex = on ? 0 : -1; });
    store('cf_dtab', name);
  }
  tl.addEventListener('keydown', function (e) {
    if (e.key !== 'ArrowRight' && e.key !== 'ArrowLeft') return;
    var i = tabs.indexOf(document.activeElement); if (i < 0) return; var n = tabs[(i + (e.key === 'ArrowRight' ? 1 : tabs.length - 1)) % tabs.length]; n.focus(); n.click(); e.preventDefault();
  });
  if (panels.length > 1) { head.appendChild(tl); drawer.insertBefore(head, drawer.firstChild); pick(store('cf_dtab') || 'shop'); }
  else if (panels.length) head.appendChild(tl);
  head.appendChild(x); if (panels.length <= 1) drawer.insertBefore(head, drawer.firstChild);
  btn.hidden = false; x.hidden = false;
  var lastFocus = null;
  function open(on) {
    if (wide.matches) on = true;
    var was = page.classList.contains('shop-open');
    page.classList.toggle('shop-open', on);
    btn.setAttribute('aria-expanded', on ? 'true' : 'false'); scrim.hidden = !on || wide.matches;
    if (on && !was && !wide.matches) { lastFocus = document.activeElement; drawer.setAttribute('tabindex', '-1'); drawer.focus({ preventScroll: true }); }
    if (!on && was && lastFocus && lastFocus.focus) { lastFocus.focus({ preventScroll: true }); lastFocus = null; }
    drawer.inert = !on && !wide.matches;   // closed drawer: nothing inside is focusable or read out
  }
  btn.addEventListener('click', function () { open(!page.classList.contains('shop-open')); });
  x.addEventListener('click', function () { open(false); });
  scrim.addEventListener('click', function () { open(false); });
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && page.classList.contains('shop-open') && !wide.matches) open(false); });
  var go = function () { open(wide.matches); };
  if (wide.addEventListener) wide.addEventListener('change', go); else if (wide.addListener) wide.addListener(go);
  open(wide.matches);
  if (/[?&]shop=1\b/.test(location.search)) open(true);
  /* portrait phone: one chip, once (a bigger room is sideways) */
  var pm = window.matchMedia ? window.matchMedia('(orientation: portrait) and (max-width: 700px)') : null;
  if (pm && pm.matches && !store('cf_turn')) {
    var c = document.createElement('div'); c.className = 'cfturn'; c.setAttribute('role', 'note');
    var t = document.createElement('span'); t.textContent = '📱 Turn your phone sideways for a bigger room';
    var b = document.createElement('button'); b.type = 'button'; b.textContent = '✕'; b.setAttribute('aria-label', 'Dismiss');
    b.addEventListener('click', function () { store('cf_turn', '1'); c.remove(); });
    c.appendChild(t); c.appendChild(b); page.insertBefore(c, page.firstChild);
    var gone = function () { if (!pm.matches) { store('cf_turn', '1'); c.remove(); } };
    if (pm.addEventListener) pm.addEventListener('change', gone);
  }
})();
