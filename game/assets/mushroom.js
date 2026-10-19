/* Gnome Venture v1.4.6: Mushroom Sweeper polish. Vanilla JS, no libraries.
   The server still decides every pick and flag; the page it sends back is swapped in by site.js. This file only adds feel:
   a rustle of leaves where you tap, newly opened squares popping outward from that spot, flags dropping in, toadstools
   popping up at the end (the one you stepped on shakes the board), petals on a clean sweep, and it stops a fast second tap
   from turning into a full page reload while the first is still being sent. */
(function () {
  'use strict';
  var rmq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };
  var prev = null;      // the last live board: { open:{i:1}, flags:{i:1} }
  var lastTap = -1;     // the square you last tapped

  function burst(x, y, kind, n) {
    if (rmq.matches) return;
    for (var i = 0; i < n; i++) {
      var p = document.createElement('span');
      p.className = 'dirtbit ' + kind;
      var a = Math.random() * Math.PI * 2, d = 16 + Math.random() * 24;
      p.style.left = x + 'px'; p.style.top = y + 'px';
      p.style.setProperty('--dx', Math.round(Math.cos(a) * d) + 'px');
      p.style.setProperty('--dy', Math.round(Math.sin(a) * d - 14) + 'px');
      p.style.setProperty('--sz', (4 + Math.random() * 4).toFixed(1) + 'px');
      document.body.appendChild(p);
      setTimeout(function (q) { return function () { if (q.parentNode) q.parentNode.removeChild(q); }; }(p), 800);
    }
  }
  function centre(el) { var r = el.getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height / 2]; }
  function petals() {
    if (rmq.matches) return;
    for (var i = 0; i < 34; i++) {
      var p = document.createElement('span');
      p.className = 'petal p' + (i % 4);
      p.style.setProperty('--x', Math.round(Math.random() * 100) + 'vw');
      p.style.setProperty('--dx', Math.round(Math.random() * 120 - 60) + 'px');
      p.style.setProperty('--r', Math.round(240 + Math.random() * 420) + 'deg');
      p.style.setProperty('--t', (2.2 + Math.random() * 1.6).toFixed(2) + 's');
      p.style.setProperty('--dl', (Math.random() * 0.7).toFixed(2) + 's');
      document.body.appendChild(p);
      setTimeout(function (q) { return function () { if (q.parentNode) q.parentNode.removeChild(q); }; }(p), 4600);
    }
  }

  function init(board) {
    board.classList.add('on');
    var size = parseInt(board.getAttribute('data-size'), 10) || 6;
    var cells = board.querySelectorAll('[data-i]');

    if (board.classList.contains('last')) {   // the walk is over: show where the toadstools were
      prev = null; lastTap = -1;
      if (rmq.matches) return;
      var k = 0;
      cells.forEach(function (c) {
        if (!c.classList.contains('mushtoad')) return;
        c.style.setProperty('--d', (k++ * 70) + 'ms');
        c.classList.add('toadin');
        if (c.classList.contains('boom')) {
          board.classList.add('shake');
          setTimeout(function () { if (!c.isConnected) return; var m = centre(c); burst(m[0], m[1], 'spore', 12); }, 120);
        }
      });
      return;
    }

    var open = {}, flags = {}, nOpen = 0;
    cells.forEach(function (c) {
      var i = c.getAttribute('data-i');
      if (c.classList.contains('mushopen')) { open[i] = 1; nOpen++; }
      if (c.classList.contains('mushflag')) flags[i] = 1;
    });
    var cont = prev && Object.keys(prev.open).length <= nOpen;   // same walk, carrying on
    if (cont && !rmq.matches) {
      var tx = lastTap % size, ty = Math.floor(lastTap / size);
      cells.forEach(function (c) {
        var i = c.getAttribute('data-i');
        if (c.classList.contains('mushopen') && !prev.open[i]) {
          var dx = (i % size) - tx, dy = Math.floor(i / size) - ty;
          c.style.setProperty('--d', Math.round(Math.sqrt(dx * dx + dy * dy) * 55) + 'ms');
          c.classList.add('rev');
        } else if (c.classList.contains('mushflag') && !prev.flags[i]) {
          c.classList.add('pin');
        }
      });
    }
    prev = { open: open, flags: flags };

    var guard = 0;
    board.addEventListener('click', function (ev) {
      var b = ev.target.closest ? ev.target.closest('button.mushcell') : null;
      if (!b) return;
      if (board.getAttribute('data-wait') === '1' && Date.now() - guard < 8000) { ev.preventDefault(); return; }   // still sending the last one
      board.setAttribute('data-wait', '1'); guard = Date.now();
      board.classList.add('rustling');
      lastTap = parseInt(b.getAttribute('data-i'), 10);
      b.classList.add('pressed');
      var c = centre(b);
      burst(c[0], c[1], 'leaf', 6);
    });
  }

  function scan() {
    var boards = document.querySelectorAll('.mushboard:not(.on)');
    if (!document.querySelector('.mushboard')) { prev = null; lastTap = -1; }
    boards.forEach(init);
    var won = false;   // a win shows as a prize box, or as a new line in the message log
    document.querySelectorAll('.prizebox:not(.cele), li.ml.prize.new:not(.cele)').forEach(function (b) {
      b.classList.add('cele');
      if (b.textContent.trim().indexOf('🏆') === 0) won = true;
    });
    if (won && document.querySelector('.mushboard')) petals();
  }
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.body, { childList: true, subtree: true });
})();
