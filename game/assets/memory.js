/* Gnome Venture v1.4.6: Seed Memory polish. Vanilla JS, no libraries.
   The server still decides every flip; the page it sends back is swapped in by site.js. This file only adds feel: a packet
   that turns over as you tap, a flip-in for the new face, a leafy glint when a pair settles, a shake on a miss, petals when
   you win, and it stops a fast second tap from turning into a full page reload while the first is still being sent. */
(function () {
  'use strict';
  var rmq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };
  var prev = null;   // what the last board looked like: { total, up:{i:1}, matched:{i:1} }

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
    var cards = board.querySelectorAll('.card');
    var total = cards.length, up = {}, matched = {}, n = 0;
    cards.forEach(function (c) {
      var i = c.getAttribute('data-i');
      if (c.classList.contains('up')) { up[i] = 1; n++; }
      if (c.classList.contains('matched')) matched[i] = 1;
    });
    var same = prev && prev.total === total;
    cards.forEach(function (c) {
      var i = c.getAttribute('data-i'), isUp = c.classList.contains('up');
      if (isUp) {
        var isNew = same ? !prev.up[i] : c.classList.contains('fresh');
        if (isNew && !rmq.matches) c.classList.add('flipin');
        if (same && c.classList.contains('matched') && !prev.matched[i]) {
          c.classList.add('settle');
          setTimeout(function () { if (!c.isConnected) return; var m = centre(c); burst(m[0], m[1], 'leaf', 7); }, 420);
        }
      } else if (same && prev.up[i] && !rmq.matches) {
        c.classList.add('flipback');   // a miss turning back over
      }
    });
    prev = { total: total, up: up, matched: matched };

    var guard = 0;
    board.addEventListener('click', function (ev) {
      var b = ev.target.closest ? ev.target.closest('button.card') : null;
      if (!b) return;
      if (board.getAttribute('data-wait') === '1' && Date.now() - guard < 8000) { ev.preventDefault(); return; }   // still sending the last one
      board.setAttribute('data-wait', '1'); guard = Date.now();
      board.classList.add('turning');
      b.classList.add('pressed');
      var c = centre(b);
      burst(c[0], c[1], 'leaf', 3);
    });
  }

  function scan() {
    var boards = document.querySelectorAll('.memboard:not(.on)');
    if (!boards.length && !document.querySelector('.memboard')) prev = null;   // game over or not started
    boards.forEach(init);
    var won = false;   // a win shows as a prize box, or as a new line in the message log
    document.querySelectorAll('.prizebox:not(.cele), li.ml.prize.new:not(.cele)').forEach(function (b) {
      b.classList.add('cele');
      if (b.textContent.trim().indexOf('🃏') === 0) won = true;
    });
    if (won) petals();
  }
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.body, { childList: true, subtree: true });
})();
