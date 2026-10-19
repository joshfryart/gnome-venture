/* Gnome Venture v1.4.0: Worm Hunting polish. Vanilla JS, no libraries.
   The server still does every dig (and moves the worms); the page it sends back is swapped in by site.js. This file only adds
   feel: a puff of dirt the moment you tap, a burst where the new square opens (gold sparks for rare finds), wriggling worms,
   and it stops a fast second tap from turning into a full page reload while the first is still being dug. */
(function () {
  'use strict';
  var rmq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };

  function burst(x, y, kind, n) {
    if (rmq.matches) return;
    for (var i = 0; i < n; i++) {
      var p = document.createElement('span');
      p.className = 'dirtbit ' + kind;
      var a = Math.random() * Math.PI * 2, d = 18 + Math.random() * 26;
      p.style.left = x + 'px'; p.style.top = y + 'px';
      p.style.setProperty('--dx', Math.round(Math.cos(a) * d) + 'px');
      p.style.setProperty('--dy', Math.round(Math.sin(a) * d - 14) + 'px');
      p.style.setProperty('--sz', (3 + Math.random() * 4).toFixed(1) + 'px');
      document.body.appendChild(p);
      setTimeout(function (q) { return function () { if (q.parentNode) q.parentNode.removeChild(q); }; }(p), 800);
    }
  }
  function centre(el) { var r = el.getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height / 2]; }

  function init(board) {
    board.classList.add('on');
    var fresh = board.querySelector('.dug.fresh, .soil.loose.fresh');
    if (fresh) {
      var c = centre(fresh);
      var rare = /k-(fossil|gem|geode)/.test(fresh.className) || fresh.classList.contains('loose');
      burst(c[0], c[1], rare ? 'spark' : 'dirt', rare ? 14 : 8);
      if (/k-(worm|night)/.test(fresh.className)) fresh.classList.add('wig');
    }
    // a found worm wriggles now and then
    var worms = board.querySelectorAll('.dug.k-worm, .dug.k-night');
    if (worms.length && !rmq.matches) {
      var t = setInterval(function () {
        if (!board.isConnected) { clearInterval(t); return; }
        var w = worms[Math.floor(Math.random() * worms.length)];
        w.classList.add('wig');
        setTimeout(function () { w.classList.remove('wig'); }, 900);
      }, 2200);
    }
    var guard = 0;
    board.addEventListener('click', function (ev) {
      var b = ev.target.closest ? ev.target.closest('button.soil') : null;
      if (!b) return;
      if (board.getAttribute('data-wait') === '1' && Date.now() - guard < 8000) { ev.preventDefault(); return; }   // still digging the last one
      board.setAttribute('data-wait', '1'); guard = Date.now();
      board.classList.add('digging');
      b.classList.add('pressed');
      var c = centre(b);
      burst(c[0], c[1], 'dirt', 5);
    });
  }

  function scan() { document.querySelectorAll('.digboard:not(.on)').forEach(init); }
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.body, { childList: true, subtree: true });
})();
