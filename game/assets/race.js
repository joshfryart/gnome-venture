/* Gnome Venture v1.4.7: Snail Race polish. Vanilla JS, no libraries.
   The server still runs and pays every race (the order on the page is its result). This file only adds feel: the last race
   is replayed along the lanes (tap to skip), a little confetti for the winner, a live countdown to the next race, quick-bet
   chips, and it stops a fast second tap on "Back this snail" from turning into a full page reload. */
(function () {
  'use strict';
  var rmq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };
  var KEY = 'gvRaceSeen';

  function seenGet() { try { return window.localStorage.getItem(KEY); } catch (e) { return null; } }
  function seenSet(v) { try { window.localStorage.setItem(KEY, v); } catch (e) { /* private mode: replay next time */ } }

  function hash(s) { var h = 2166136261; for (var i = 0; i < s.length; i++) { h ^= s.charCodeAt(i); h = Math.imul(h, 16777619); } return h >>> 0; }
  function rng(seed) { var a = seed >>> 0; return function () { a = (a + 0x6D2B79F5) >>> 0; var t = a; t = Math.imul(t ^ (t >>> 15), t | 1); t ^= t + Math.imul(t ^ (t >>> 7), t | 61); return ((t ^ (t >>> 14)) >>> 0) / 4294967296; }; }

  function confetti() {
    if (rmq.matches) return;
    for (var i = 0; i < 30; i++) {
      var p = document.createElement('span');
      p.className = 'petal p' + (i % 4);
      p.style.setProperty('--x', Math.round(Math.random() * 100) + 'vw');
      p.style.setProperty('--dx', Math.round(Math.random() * 120 - 60) + 'px');
      p.style.setProperty('--r', Math.round(240 + Math.random() * 420) + 'deg');
      p.style.setProperty('--t', (2 + Math.random() * 1.4).toFixed(2) + 's');
      p.style.setProperty('--dl', (Math.random() * 0.5).toFixed(2) + 's');
      document.body.appendChild(p);
      setTimeout(function (q) { return function () { if (q.parentNode) q.parentNode.removeChild(q); }; }(p), 4200);
    }
  }

  /* ---- the replay ---- */
  function play(track, btn) {
    if (track.classList.contains('playing') || rmq.matches || !track.animate) return;
    var lanes = Array.prototype.slice.call(track.querySelectorAll('.racelane'));
    var pod = track.parentNode.querySelectorAll('.racepodium, .racemine');
    var hint = track.parentNode.querySelector('.racehint');
    var rand = rng(hash(track.getAttribute('data-race') || 'race'));
    var anims = [], left = lanes.length;
    track.classList.add('playing');
    lanes.forEach(function (l) { l.classList.remove('done', 'won'); });
    pod.forEach(function (p) { p.classList.add('veil'); });
    if (btn) btn.disabled = true;
    if (hint) hint.hidden = false;
    lanes.forEach(function (lane) {
      var way = lane.querySelector('.laneway'), racer = lane.querySelector('.racer');
      var rank = parseInt(lane.getAttribute('data-rank'), 10) || 0;
      var max = Math.max(0, way.clientWidth - racer.offsetWidth);
      var fin = (1 - rank * 0.045) * max;
      var dur = 3700 + rank * 640;
      var frames = [{ left: '0px', offset: 0 }], prev = 0;
      for (var k = 1; k <= 5; k++) {
        var t = k / 6, p = Math.max(prev + 0.02, t + (rand() - 0.5) * 0.24);
        p = Math.min(p, 0.97); prev = p;
        frames.push({ left: Math.round(p * fin) + 'px', offset: t });
      }
      frames.push({ left: Math.round(fin) + 'px', offset: 1 });
      var a = racer.animate(frames, { duration: dur, easing: 'linear', fill: 'both' });
      anims.push(a);
      a.onfinish = function () {
        lane.classList.add('done');
        if (rank === 0) { lane.classList.add('won'); confetti(); }
        a.cancel();   // the lane's own finishing position (CSS) is exactly where it stopped
        if (--left === 0) end();
      };
    });
    function end() {
      track.classList.remove('playing');
      pod.forEach(function (p) { p.classList.remove('veil'); });
      if (hint) hint.hidden = true;
      if (btn) btn.disabled = false;
      track.removeEventListener('click', skip);
    }
    function skip() { anims.forEach(function (a) { if (a.playState === 'running') a.finish(); }); }
    track.addEventListener('click', skip);
  }

  function initTrack(track) {
    track.classList.add('on');
    var btn = track.parentNode.querySelector('.racereplay');
    if (rmq.matches || !track.animate) return;
    if (btn) { btn.hidden = false; btn.addEventListener('click', function () { play(track, btn); }); }
    var race = track.getAttribute('data-race') || '';
    if (seenGet() !== race && document.visibilityState !== 'hidden') { seenSet(race); play(track, btn); }
  }

  /* ---- countdown chip ---- */
  function initCountdown(chip) {
    chip.classList.add('on');
    var b = chip.querySelector('b'), end = Date.now() + (parseInt(chip.getAttribute('data-secs'), 10) || 0) * 1000;
    function tick() {
      if (!chip.isConnected) return;
      var s = Math.max(0, Math.round((end - Date.now()) / 1000));
      if (s <= 0) { b.textContent = 'racing now!'; return; }
      var h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60), r = s % 60;
      b.textContent = (h ? h + 'h ' : '') + (h || m ? (h && m < 10 ? '0' : '') + m + 'm ' + (r < 10 ? '0' : '') : '') + r + 's';
      setTimeout(tick, 1000);
    }
    tick();
  }

  /* ---- the bet form ---- */
  function initForm(form) {
    form.classList.add('on');
    var amt = form.querySelector('input[name=amount]'), go = form.querySelector('.racego'), quick = form.querySelector('.betquick');
    function sync() {
      var sel = form.querySelector('input[name=snail]:checked');
      var card = sel ? sel.closest('.snailcard') : null;
      form.querySelectorAll('.snailcard').forEach(function (c) { c.classList.toggle('sel', c === card); });
      if (card && go) go.textContent = 'Back ' + card.getAttribute('data-name');
      if (quick) quick.querySelectorAll('button').forEach(function (b) { b.classList.toggle('on', b.getAttribute('data-v') === String(amt.value)); });
    }
    if (quick && amt) {
      var max = parseInt(quick.getAttribute('data-max'), 10) || 0, vals = [5, 10, 25, 50].filter(function (v) { return v < max; });
      if (max > 0) vals.push(max);
      vals.forEach(function (v, i) {
        var b = document.createElement('button');
        b.type = 'button'; b.className = 'gmchip btnchip'; b.setAttribute('data-v', String(v));
        b.textContent = i === vals.length - 1 ? 'Max ' + v : String(v);
        b.addEventListener('click', function () { amt.value = v; sync(); });
        quick.appendChild(b);
      });
      amt.addEventListener('input', sync);
    }
    form.addEventListener('change', sync);
    sync();
    var guard = 0;
    form.addEventListener('submit', function (ev) {
      if (form.getAttribute('data-wait') === '1' && Date.now() - guard < 8000) { ev.preventDefault(); return; }   // still sending the first tap
      form.setAttribute('data-wait', '1'); guard = Date.now();
      form.classList.add('betting');
    });
  }

  function scan() {
    document.querySelectorAll('.racetrack:not(.on)').forEach(initTrack);
    document.querySelectorAll('.racecd:not(.on)').forEach(initCountdown);
    document.querySelectorAll('.raceform:not(.on)').forEach(initForm);
  }
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.body, { childList: true, subtree: true });
})();
