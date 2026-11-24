/* Cat Fish room2 shell (setting catfish_room2): the shop drawer and a one-time "turn your phone" chip.
   Without this script the drawer is just a normal block under the room (CSS only slides it once .cfr2.js is set). No inline script (CSP). */
(function () {
  var page = document.querySelector('.cfpage.cfr2'), drawer = document.getElementById('cf-drawer'); if (!page || !drawer) return;
  var btn = document.getElementById('cf-shopbtn'), scrim = document.getElementById('cf-scrim'), x = document.getElementById('cf-dclose');
  var wide = window.matchMedia ? window.matchMedia('(min-width: 1000px)') : { matches: false };
  function store(k, v) { try { if (v === undefined) return window.localStorage.getItem(k); window.localStorage.setItem(k, v); } catch (e) {} return null; }
  page.classList.add('js');
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
