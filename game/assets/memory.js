/* Gnome Venture v1.4.6: Seed Memory polish. Vanilla JS, no libraries.
   The server still decides every flip; the page it sends back is swapped in by site.js. This file only adds feel: a packet
   that turns over as you tap, a flip-in for the new face, a leafy glint when a pair settles, a shake on a miss, petals when
   you win, and it stops a fast second tap from turning into a full page reload while the first is still being sent. */
(function () {
  'use strict';
  var rmq = window.gvFx.rmq;
  var prev = null;   // what the last board looked like: { total, up:{i:1}, matched:{i:1} }

  var burst = window.gvFx.burst, petals = window.gvFx.petals;

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
          setTimeout(function () { if (!c.isConnected) return; var m = window.gvFx.centre(c); burst(m[0], m[1], 'leaf', 7); }, 420);
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
      var c = window.gvFx.centre(b);
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
