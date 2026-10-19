/* Gnome Venture v1.4.7: Guess the Weight polish. Vanilla JS, no libraries.
   The server still takes and settles every guess (and the weight stays secret until the day ends). This file only adds feel:
   a slider with -/+ buttons that moves a guess marker on the scale as you drag, a marker that drops on the rim when you write
   your guess, the needle swinging to last time's real weight (weigh again with the button), and it stops a fast second tap on
   "Write it on the board" from turning into a full page reload. */
(function () {
  'use strict';
  var rmq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };
  var KEY = 'gvMarrowSeen';
  var hadGuess = null;   // did the last-seen scale already hold a guess? (null = first look)

  function seenGet() { try { return window.localStorage.getItem(KEY); } catch (e) { return null; } }
  function seenSet(v) { try { window.localStorage.setItem(KEY, v); } catch (e) { /* private mode */ } }
  function angle(kg) { return -120 + (Math.max(8, Math.min(40, kg)) - 8) / 32 * 240; }

  function bounceCrop(stage) {
    var c = stage.querySelector('.dcrop');
    if (c && c.animate && !rmq.matches) c.animate([{ transform: 'translateY(0) scale(1, 1)' }, { transform: 'translateY(-7px) scale(.97, 1.04)' }, { transform: 'translateY(2px) scale(1.05, .94)' }, { transform: 'translateY(0) scale(1, 1)' }], { duration: 520, easing: 'ease-out' });
  }

  /* ---- last time: the needle swings to the real weight ---- */
  function swing(stage, btn) {
    var nd = stage.querySelector('.dnd');
    if (!nd || !nd.animate || rmq.matches || stage.classList.contains('weighing')) return;
    var to = parseFloat(stage.getAttribute('data-a')) || 0;
    stage.classList.add('weighing');
    if (btn) btn.disabled = true;
    var a = nd.animate([
      { transform: 'rotate(-120deg)', offset: 0 }, { transform: 'rotate(' + (to + 10) + 'deg)', offset: .5 },
      { transform: 'rotate(' + (to - 6) + 'deg)', offset: .72 }, { transform: 'rotate(' + (to + 3) + 'deg)', offset: .88 }, { transform: 'rotate(' + to + 'deg)', offset: 1 }
    ], { duration: 2300, easing: 'cubic-bezier(.3, .7, .4, 1)', fill: 'both' });
    function done() {
      a.cancel();
      stage.classList.remove('weighing');
      stage.classList.add('marksin');
      setTimeout(function () { stage.classList.remove('marksin'); }, 900);
      bounceCrop(stage);
      if (btn) btn.disabled = false;
    }
    a.onfinish = done;
    stage.addEventListener('click', function skip() { stage.removeEventListener('click', skip); if (a.playState === 'running') a.finish(); });
  }

  function initPast(box) {
    box.classList.add('on');
    var stage = box.querySelector('.scalestage.past'), btn = box.querySelector('.marrowreplay');
    if (!stage || rmq.matches) return;
    if (btn) { btn.hidden = false; btn.addEventListener('click', function () { swing(stage, btn); }); }
    var day = box.getAttribute('data-day') || '';
    if (seenGet() !== day) { seenSet(day); swing(stage, btn); }
  }

  /* ---- today: guess marker + slider ---- */
  function placeGhost(stage, kg) {
    var g = stage.querySelector('.dmark.ghost');
    if (!g) return;
    if (!(kg >= 8 && kg <= 40)) { g.classList.remove('on'); return; }
    var a = angle(kg) * Math.PI / 180;
    g.setAttribute('cx', (120 + 43.5 * Math.sin(a)).toFixed(2));
    g.setAttribute('cy', (120 - 43.5 * Math.cos(a)).toFixed(2));
    g.classList.add('on');
  }

  function initToday(box) {
    box.classList.add('on');
    var stage = box.querySelector('.scalestage.today');
    var has = !!(stage && stage.querySelector('.dmark.you'));
    if (stage && hadGuess === false && has) {   // you just wrote your guess
      var dot = stage.querySelector('.dmark.you');
      if (dot.animate && !rmq.matches) dot.animate([{ transform: 'translateY(-30px) scale(.2)', opacity: 0 }, { transform: 'translateY(0) scale(1.6)', opacity: 1, offset: .6 }, { transform: 'translateY(0) scale(1)', opacity: 1 }], { duration: 650, easing: 'ease-out' });
      bounceCrop(stage);
    } else if (stage && hadGuess === null && !rmq.matches) {   // first look: the needle shivers awake
      var nd = stage.querySelector('.dnd');
      if (nd && nd.animate) nd.animate([{ transform: 'rotate(-120deg)' }, { transform: 'rotate(-103deg)', offset: .35 }, { transform: 'rotate(-122deg)', offset: .6 }, { transform: 'rotate(-120deg)' }], { duration: 900, easing: 'ease-in-out' });
    }
    hadGuess = has;

    var form = box.querySelector('.guessform');
    if (!form) return;
    var num = form.querySelector('input[name=kg]'), go = form.querySelector('.mgo');
    var row = document.createElement('div');
    row.className = 'gslide';
    row.innerHTML = '<button type="button" class="gstep" data-d="-1" aria-label="0.1 kg lighter">−</button>'
      + '<input type="range" class="grange" min="8" max="40" step="0.1" value="24" aria-label="Guess in kilograms">'
      + '<button type="button" class="gstep" data-d="1" aria-label="0.1 kg heavier">+</button>';
    num.closest('.gguess').insertAdjacentElement('afterend', row);
    var range = row.querySelector('.grange');
    function setKg(v, fromRange) {
      v = Math.max(8, Math.min(40, Math.round(v * 10) / 10));
      num.value = v.toFixed(1);
      if (!fromRange) range.value = v;
      placeGhost(stage, v);
    }
    range.addEventListener('input', function () { setKg(parseFloat(range.value), true); });
    num.addEventListener('input', function () {
      var v = parseFloat(String(num.value).replace(',', '.'));
      if (v >= 8 && v <= 40) { range.value = v; }
      placeGhost(stage, v);
    });
    row.querySelectorAll('.gstep').forEach(function (b) {
      var d = parseInt(b.getAttribute('data-d'), 10), timer = null, rep = null;
      function step() { var cur = parseFloat(String(num.value).replace(',', '.')); if (!(cur >= 8)) cur = parseFloat(range.value); setKg(cur + d * 0.1, false); }
      function stop() { clearTimeout(timer); clearInterval(rep); timer = rep = null; }
      b.addEventListener('pointerdown', function (ev) { if (ev.button) return; step(); timer = setTimeout(function () { rep = setInterval(step, 70); }, 420); });
      ['pointerup', 'pointerleave', 'pointercancel'].forEach(function (t) { b.addEventListener(t, stop); });
      b.addEventListener('click', function (ev) { if (ev.detail === 0) step(); });   // the keyboard
      b.addEventListener('contextmenu', function (ev) { ev.preventDefault(); });
    });
    var guard = 0;
    form.addEventListener('submit', function (ev) {
      if (form.getAttribute('data-wait') === '1' && Date.now() - guard < 8000) { ev.preventDefault(); return; }   // still sending the first tap
      form.setAttribute('data-wait', '1'); guard = Date.now();
      form.classList.add('writing');
    });
  }

  function scan() {
    document.querySelectorAll('.marrowbox:not(.on)').forEach(initToday);
    document.querySelectorAll('.marrowlast:not(.on)').forEach(initPast);
    if (!document.querySelector('.marrowbox')) hadGuess = null;
  }
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.body, { childList: true, subtree: true });
})();
