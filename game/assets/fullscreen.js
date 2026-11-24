/* Landscape full screen on phones and tablets (2.8.24+ incidental). A small corner button asks the browser for full screen; the browser only allows that on a tap,
   so the choice is remembered (localStorage "gv_fs") and the next tap on any page asks again. Portrait leaves full screen. Where the browser has no
   Fullscreen API (iPhone Safari) nothing is shown: "Add to Home Screen" gives the same through manifest.json. No inline styles (CSP): classes in dock.css. */
(function () {
  'use strict';
  var de = document.documentElement;
  var req = de.requestFullscreen || de.webkitRequestFullscreen;
  if (!req || !(window.matchMedia && matchMedia('(pointer: coarse)').matches)) return;
  var mq = matchMedia('(orientation: landscape)');
  function get() { try { return localStorage.getItem('gv_fs') === '1'; } catch (e) { return false; } }
  function set(v) { try { localStorage.setItem('gv_fs', v ? '1' : '0'); } catch (e) {} }
  function isFs() { return !!(document.fullscreenElement || document.webkitFullscreenElement); }
  function enter() {
    try {
      var p = req.call(de);
      if (p && p.then) p.then(lock, function () {}); else lock();
    } catch (e) {}
  }
  function lock() { try { if (screen.orientation && screen.orientation.lock) screen.orientation.lock('landscape').catch(function () {}); } catch (e) {} }
  function leave() {
    try { if (screen.orientation && screen.orientation.unlock) screen.orientation.unlock(); } catch (e) {}
    try { (document.exitFullscreen || document.webkitExitFullscreen).call(document); } catch (e) {}
  }
  var b = document.createElement('button');
  b.type = 'button'; b.className = 'gvfs';
  function paint() {
    var fs = isFs();
    b.textContent = fs ? '✕' : '⛶';
    b.setAttribute('aria-label', fs ? 'Leave full screen' : 'Full screen');
    b.title = b.getAttribute('aria-label');
    b.classList.toggle('on', fs);
    b.hidden = !mq.matches;
  }
  b.addEventListener('click', function () {
    if (isFs()) { set(false); leave(); } else { set(true); enter(); }
  });
  document.addEventListener('fullscreenchange', paint);
  document.addEventListener('webkitfullscreenchange', paint);
  function orient() {
    if (!mq.matches && isFs()) leave();
    paint();
  }
  if (mq.addEventListener) mq.addEventListener('change', orient); else if (mq.addListener) mq.addListener(orient);
  /* a new page drops full screen: the first tap after a load puts it back, if the player chose it */
  function again(ev) {
    if (ev.target === b) return;
    if (get() && mq.matches && !isFs()) enter();
    document.removeEventListener('pointerup', again, true);
  }
  if (get()) document.addEventListener('pointerup', again, true);
  document.body.appendChild(b);
  paint();
})();
