/* Cat Fish: keeps the Kibble counter ticking and syncs with the server every 30 s. The server is the only authority; this only draws.
   Active play: a tap on a dangling fish (button.cfsdrop) counts one pending tap (cap 40, per-fish cooldown 600 ms, untrusted events ignored), shows '+v' at once
   (v = the last server value, view.play.v) and fires 'cftap' on the stage for the animation below. The pending count rides the next 30 s tick as play=n and seq=batch id
   (the same seq is resent until the server answers, so a lost reply never pays twice); pagehide sends it with sendBeacon. The server decides what is paid. */
(function () {
  var el = document.getElementById('cf-data'); if (!el) return;
  var d = JSON.parse(el.textContent); if (!d.has) return;
  var kibble = document.getElementById('cf-kibble'), kph = document.getElementById('cf-kph');
  var shown = d.kibble, rate = d.kph, frac = 0;
  var stage = document.querySelector('.cfstage'), live = document.getElementById('cf-playlive'), hint = document.getElementById('cf-hint'), comboEl = document.getElementById('cf-combo');
  var play = d.play || { v: 1, left: 0, ever: 0 };
  var pending = 0, pendV = 0, seq = 0, busy = false, lastSeq = 0, combo = 0, lastTap = 0, comboTimer = 0, cool = {};
  function nextSeq() { lastSeq = Math.max(lastSeq + 1, Date.now()); return lastSeq; }   // ms clock: increasing across page loads and tabs
  function draw() { kibble.textContent = Math.floor(shown).toLocaleString(); kph.textContent = rate; refreshButtons(); }
  function refreshButtons() {
    document.querySelectorAll('button[data-cost]').forEach(function (b) { b.disabled = Math.floor(shown) < +b.getAttribute('data-cost'); });
  }
  function form(data) { var fd = new FormData(); fd.append('csrf', d.csrf); Object.keys(data).forEach(function (k) { fd.append(k, data[k]); }); return fd; }
  function post(data, done, fail) {
    fetch(d.api, { method: 'POST', body: form(data), credentials: 'same-origin' }).then(function (r) { return r.json(); }).then(done).catch(fail || function () {});
  }
  function setPending() { if (stage) stage.setAttribute('data-play-pending', pending); }
  function setCombo() { if (stage) stage.setAttribute('data-combo', combo); if (comboEl) comboEl.textContent = combo >= 2 ? '\u00d7' + combo : ''; }
  function playView(p) { if (!p) return; play = p; if (p.ever > 0 && hint) hint.hidden = true; }
  function apply(view) {
    shown = view.kibble + pendV; rate = view.kph; draw(); playView(view.play);
    view.ups.forEach(function (u) {
      var f = document.querySelector('#cf-ups form[data-key="' + u.key + '"]'); if (!f) return;
      f.querySelector('small.muted').textContent = '×' + u.owned;
      f.querySelector('.cfgives').textContent = u.gives + (u.mult > 1 ? ' · ×' + u.mult + ' bonus' : '');
      var b = f.querySelector('button'); b.setAttribute('data-cost', u.cost); b.textContent = 'Buy · ' + u.cost.toLocaleString();
    });
    var run = document.getElementById('cf-run'); if (run) {
      run.textContent = view.run.toLocaleString(); document.getElementById('cf-napyarn').textContent = view.nap_yarn;
      document.getElementById('cf-napform').hidden = view.nap_yarn < 1; document.getElementById('cf-napneed').hidden = view.nap_yarn >= 1;
    }
    refreshButtons();
  }
  function say(text, bad) { var m = document.getElementById('cf-msg'); if (!m) return; m.textContent = text || ''; m.className = bad ? 'flash err' : 'flash ok'; }
  setInterval(function () { shown += rate / 3600; draw(); }, 1000);
  function sync() {
    if (document.hidden || busy) return;
    var data = { do: 'tick' }, sentN = 0, sentV = 0;
    if (pending > 0) { if (!seq) seq = nextSeq(); sentN = pending; sentV = pendV; data.play = sentN; data.seq = seq; }
    busy = true;
    post(data, function (r) {
      busy = false;
      if (!r.ok) { say(r.error, true); return; }   // 429 and the like: keep the pending taps and the same seq, resend next tick
      if (sentN) { pending = Math.max(0, pending - sentN); pendV = Math.max(0, pendV - sentV); seq = 0; setPending(); }
      apply(r.view);
      if (sentN && live && r.view.play && r.view.play.paid > 0) {
        live.textContent = ''; setTimeout(function () { live.textContent = '+' + r.view.play.paid + ' Kibble from play'; }, 50);
      }
    }, function () { busy = false; });
  }
  window.addEventListener('pagehide', function () {
    if (pending < 1 || !navigator.sendBeacon) return;
    if (!seq) seq = nextSeq();
    navigator.sendBeacon(d.api, form({ do: 'tick', play: pending, seq: seq }));
  });
  if (stage) stage.addEventListener('click', function (ev) {
    var b = ev.target.closest ? ev.target.closest('button.cfsdrop') : null;
    if (!b || !ev.isTrusted) return;
    var now = Date.now(), f = b.getAttribute('data-fish');
    if (cool[f] && now - cool[f] < 600) return;
    cool[f] = now;
    var v = play.left - pending > 0 ? play.v : 0;
    if (v > 0 && pending < 40) { pending++; pendV += v; setPending(); shown += v; draw(); }
    if (v > 0) {
      var pop = stage.querySelector('.cfpop.p' + f);
      if (pop) { pop.textContent = '+' + v; pop.classList.remove('go'); void pop.offsetWidth; pop.classList.add('go'); }
    }
    combo = (lastTap && now - lastTap < 2000) ? Math.min(10, Math.max(combo, 1) + 1) : 1; lastTap = now;
    clearTimeout(comboTimer); comboTimer = setTimeout(function () { combo = 0; setCombo(); }, 2000);
    setCombo();
    if (hint) hint.hidden = true;
    stage.dispatchEvent(new CustomEvent('cftap', { detail: { btn: b, fish: +f } }));
  });
  setInterval(sync, 30000);
  document.addEventListener('visibilitychange', function () { if (!document.hidden) sync(); });
  document.getElementById('cf-ups').addEventListener('submit', function (ev) {
    var f = ev.target; if (!f.matches('form.cfup')) return;
    ev.preventDefault();
    post({ do: 'buy', key: f.getAttribute('data-key') }, function (r) { if (r.view) apply(r.view); say(r.message || r.error, !r.ok); });
  });
})();

/* Play scene (decorative only): the active cat in the stage (.cfactive, see catfish_stage_html) swaps its frame group by moving one class (fr-<frame>)
   and mirrors it in data-frame. It never touches Kibble: the counter above and the server tick stay the only authority.
   Idle: idleA <-> idleB every 1.2-2.4 s. Every 6-9 s of idling: a play loop wiggle .6 s, stalk .8 s, pounce .4 s, catch 1.2 s (the fish toy), back to idleA;
   after the first one, one time in four it sits bored for 3 s instead. A freshly napped cat (data-nap, until the first Kibble of the new run) and the Nap button show nap.
   Tap on a fish (event 'cftap' from the sync block above): the fish gets is-hit (cfbounce 900 ms) and the cat's idle loop is interrupted: stalk 150 ms, pounce 350 ms, catch 600 ms
   (the fish gets is-caught for 240 ms when the catch lands), idleA, then idle resumes with idled = 0. The cat reacts at most once per 700 ms, faces the fish (class flip when the
   fish is left of room x 150) and wakes if napping (data-nap goes with the first paid Kibble of the run). Reduced motion: the fish only shows its outline (is-hit) for 300 ms.
   prefers-reduced-motion: idleA only, nothing moves. The random numbers come from the cat's seed, so a page load plays the same sequence every time. */
(function () {
  var cat = document.querySelector('.cfactive'); if (!cat) return;
  var have = {}; [].forEach.call(cat.querySelectorAll('.cfframe'), function (f) { have[f.getAttribute('data-f')] = true; });
  var cur = cat.getAttribute('data-frame'), timer = 0, napping = cat.getAttribute('data-nap') === '1';
  var a = (parseInt(cat.getAttribute('data-seed'), 10) || 1) >>> 0;
  function rnd() { a = (a + 0x6D2B79F5) >>> 0; var t = a; t = Math.imul(t ^ (t >>> 15), t | 1); t ^= t + Math.imul(t ^ (t >>> 7), t | 61); return ((t ^ (t >>> 14)) >>> 0) / 4294967296; }
  function between(lo, hi) { return lo + rnd() * (hi - lo); }
  function show(f) {
    if (!have[f]) f = have.idleA ? 'idleA' : cur;
    if (f === cur) return;
    cat.classList.remove('fr-' + cur); cat.classList.add('fr-' + f); cat.setAttribute('data-frame', f); cur = f;
  }
  function later(ms, fn) { timer = setTimeout(fn, ms); }
  var idled = 0, plays = 0, nextPlay = between(6000, 9000);
  var PLAY = [['wiggle', 600], ['stalk', 800], ['pounce', 400], ['catch', 1200]];
  function play(i) {
    if (i >= PLAY.length) { show('idleA'); return later(between(1200, 2400), idle); }
    show(PLAY[i][0]); later(PLAY[i][1], function () { play(i + 1); });
  }
  function idle() {
    if (napping) { show('nap'); return later(1000, idle); }
    if (idled >= nextPlay) {
      idled = 0; nextPlay = between(6000, 9000);
      if (plays++ > 0 && rnd() < 0.25) { show('bored'); return later(3000, function () { show('idleA'); later(between(1200, 2400), idle); }); }
      return play(0);
    }
    var ms = between(1200, 2400);
    show(cur === 'idleA' ? 'idleB' : 'idleA');
    idled += ms; later(ms, idle);
  }
  var mq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : null;
  function start() {
    clearTimeout(timer);
    if (mq && mq.matches) { show(napping ? 'nap' : 'idleA'); return; }
    show(napping ? 'nap' : 'idleA'); later(between(1200, 2400), idle);
  }
  start();
  if (mq && mq.addEventListener) mq.addEventListener('change', start);
  var stage = cat.parentNode, lastReact = 0, hitT = {};
  function hit(b) {
    var f = b.getAttribute('data-fish'), ms = mq && mq.matches ? 300 : 900;
    b.classList.remove('is-hit'); void b.offsetWidth; b.classList.add('is-hit');
    clearTimeout(hitT[f]); hitT[f] = setTimeout(function () { b.classList.remove('is-hit'); }, ms);
  }
  function caught(b) { b.classList.add('is-caught'); setTimeout(function () { b.classList.remove('is-caught'); }, 240); }
  function react(b) {
    var now = Date.now(); if (now - lastReact < 700) return; lastReact = now;
    clearTimeout(timer); napping = false;
    cat.classList.toggle('flip', b.offsetLeft + 24 < 150);
    show('stalk');
    later(150, function () { show('pounce'); later(350, function () { show('catch'); caught(b); later(600, function () {
      show('idleA'); cat.classList.remove('flip'); idled = 0; later(between(1200, 2400), idle);
    }); }); });
  }
  stage.addEventListener('cftap', function (ev) {
    var b = ev.detail.btn; hit(b);
    if (!(mq && mq.matches)) react(b);
  });
  var nf = document.getElementById('cf-napform');
  if (nf) nf.addEventListener('submit', function () { napping = true; show('nap'); });
  var run = document.getElementById('cf-run');
  if (run && window.MutationObserver) new MutationObserver(function () {
    if (parseInt(run.textContent.replace(/\D/g, ''), 10) > 0) {
      cat.removeAttribute('data-nap');
      if (napping) { napping = false; idled = 0; start(); }
    }
  }).observe(run, { childList: true, characterData: true, subtree: true });
})();
