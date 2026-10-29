/* Cat Fish: keeps the Kibble counter ticking and syncs with the server every 30 s. The server is the only authority; this only draws.
   Active play: a tap on a dangling fish (button.cfsdrop) counts one pending tap (cap 40, per-fish cooldown 600 ms, untrusted events ignored), shows '+v' at once
   (v = the last server value, view.play.v) and fires 'cftap' on the stage for the animation below. The pending count rides the next 30 s tick as play=n and seq=batch id
   (the same seq is resent until the server answers, so a lost reply never pays twice); pagehide sends it with sendBeacon. The server decides what is paid. */
(function () {
  var el = document.getElementById('cf-data'); if (!el) return;
  var d = JSON.parse(el.textContent); if (!d.has) return;
  var kibble = document.getElementById('cf-kibble'), kph = document.getElementById('cf-kph');
  var shown = d.kibble, rate = d.kph, frac = 0;
  function st() { return document.querySelector('.cfstage'); }   // the stage is swapped in place after a buy (swapScene), so it is looked up each time
  var play = d.play || { v: 1, left: 0, ever: 0 };
  var pending = 0, pendV = 0, seq = 0, busy = false, lastSeq = 0, combo = 0, lastTap = 0, comboTimer = 0, cool = {}, buying = {}, queue = [], reloaded = false, popTimer = 0;
  function nextSeq() { lastSeq = Math.max(lastSeq + 1, Date.now()); return lastSeq; }   // ms clock: increasing across page loads and tabs
  function draw() { kibble.textContent = Math.floor(shown).toLocaleString(); kph.textContent = rate; refreshButtons(); }
  function refreshButtons() {
    document.querySelectorAll('button[data-cost]').forEach(function (b) {
      var f = b.closest('form.cfup');   // a buy in flight keeps its own button off until the reply
      b.disabled = Math.floor(shown) < +b.getAttribute('data-cost') || !!(f && buying[f.getAttribute('data-key')]);
    });
  }
  function form(data) { var fd = new FormData(); fd.append('csrf', d.csrf); Object.keys(data).forEach(function (k) { fd.append(k, data[k]); }); return fd; }
  function post(data, done, fail) {
    fetch(d.api, { method: 'POST', body: form(data), credentials: 'same-origin' }).then(function (r) { return r.json(); }).then(done, fail || function () {});
  }
  /* one request at a time: a buy waits for a tick in flight (and the other way round), so the same pending taps and seq are never in two requests at once */
  function free() { busy = false; var n = queue.shift(); if (n) n(); }
  function whenFree(fn) { if (busy) queue.push(fn); else fn(); }
  function setPending() { var stage = st(); if (stage) stage.setAttribute('data-play-pending', pending); }
  function setCombo() { var stage = st(), comboEl = document.getElementById('cf-combo'); if (stage) stage.setAttribute('data-combo', combo); if (comboEl) comboEl.textContent = combo >= 2 ? '\u00d7' + combo : ''; }
  function playView(p) { var hint = document.getElementById('cf-hint'); if (!p) return; play = p; if ((p.ever > 0 || pending > 0) && hint) hint.hidden = true; }
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
  /* 2.1.07 live scene: the API sends stage_html (the markup catfish.php prints) when the scene key changed, e.g. after a buy that adds a room overlay or a new fish kind.
     It is parsed with DOMParser (nothing in it runs), the .cfstagewrap is replaced, and the animation block below is told ('cfscene') to bind to the new nodes. */
  function swapScene(html, fresh) {
    var old = document.querySelector('.cfstagewrap'); if (!old || !old.parentNode) return false;
    var nu = new DOMParser().parseFromString(html, 'text/html').querySelector('.cfstagewrap'); if (!nu) return false;
    old.parentNode.replaceChild(document.importNode(nu, true), old);
    setPending(); setCombo(); playView(play);   // taps in flight stay counted on the new nodes
    document.dispatchEvent(new CustomEvent('cfscene'));
    if (fresh) { var ns = st(); if (ns) { ns.classList.add('is-new'); setTimeout(function () { var t = st(); if (t) t.classList.remove('is-new'); }, 700); } }   // 2.1.08: a quick flash when a buy changes the room
    return true;
  }
  function newScene(r, fresh) { if (r.stage_html) swapScene(r.stage_html, fresh); if (r.scene) d.scene = r.scene; }
  function spendPop(n) {   // the small '-N' by the Kibble counter
    var el = document.getElementById('cf-spend'); if (!el || n < 1) return;
    el.textContent = '\u2212' + n.toLocaleString(); el.classList.remove('go'); void el.offsetWidth; el.classList.add('go');
    clearTimeout(popTimer); popTimer = setTimeout(function () { el.classList.remove('go'); }, 1200);
  }
  setInterval(function () { shown += rate / 3600; draw(); }, 1000);
  function sync() {
    if (document.hidden || busy) return;
    var data = { do: 'tick', scene: d.scene }, sentN = 0, sentV = 0;
    if (pending > 0) { if (!seq) seq = nextSeq(); sentN = pending; sentV = pendV; data.play = sentN; data.seq = seq; }
    busy = true;
    post(data, function (r) {
      free();
      if (!r.ok) { say(r.error, true); return; }   // 429 and the like: keep the pending taps and the same seq, resend next tick
      if (sentN) { pending = Math.max(0, pending - sentN); pendV = Math.max(0, pendV - sentV); seq = 0; setPending(); }
      if (r.view.cat && r.view.cat.id !== d.cat && !reloaded) { reloaded = true; location.reload(); return; }   // another tab switched the cat: the card below the stage is stale, so start over
      apply(r.view); newScene(r);
      var live = document.getElementById('cf-playlive');
      if (sentN && live && r.view.play && r.view.play.paid > 0) {
        live.textContent = ''; setTimeout(function () { live.textContent = '+' + r.view.play.paid + ' Kibble from play'; }, 50);
      }
    }, function () { free(); });
  }
  window.addEventListener('pagehide', function () {
    if (pending < 1 || !navigator.sendBeacon) return;
    if (!seq) seq = nextSeq();
    navigator.sendBeacon(d.api, form({ do: 'tick', play: pending, seq: seq }));
  });
  document.addEventListener('click', function (ev) {
    var b = ev.target.closest ? ev.target.closest('.cfstage button.cfsdrop') : null, stage = b && b.closest('.cfstage');
    if (!b || !stage || !ev.isTrusted) return;
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
    var hint = document.getElementById('cf-hint'); if (hint) hint.hidden = true;
    stage.dispatchEvent(new CustomEvent('cftap', { detail: { btn: b, fish: +f, combo: combo } }));
  });
  setInterval(sync, 30000);
  document.addEventListener('visibilitychange', function () { if (!document.hidden) sync(); });
  /* Buy (2.1.07): the cost leaves the counter at once, the pressed button stays off until the reply, and the request carries the pending taps (play, seq as in a tick) so the server pays
     them before it checks the cost. A reply with a view means the server handled the taps and the buy: pending is cleared and the view (kibble, rate, rows, run) replaces the guess, a refusal
     restores the number. No reply at all gives the cost back and keeps the taps and seq for the next tick. */
  document.getElementById('cf-ups').addEventListener('submit', function (ev) {
    var f = ev.target; if (!f.matches('form.cfup')) return;
    ev.preventDefault();
    var key = f.getAttribute('data-key'), b = f.querySelector('button[data-cost]'); if (!b || b.disabled || buying[key]) return;
    var cost = +b.getAttribute('data-cost') || 0;
    buying[key] = true; shown -= cost; spendPop(cost); say('', false); draw();
    whenFree(function () {
      var data = { do: 'buy', key: key, scene: d.scene }, sentN = 0, sentV = 0;
      if (pending > 0) { if (!seq) seq = nextSeq(); sentN = pending; sentV = pendV; data.play = sentN; data.seq = seq; }
      busy = true;
      post(data, function (r) {
        delete buying[key]; free();
        if (r.view) {
          if (sentN) { pending = Math.max(0, pending - sentN); pendV = Math.max(0, pendV - sentV); seq = 0; setPending(); }
          apply(r.view); newScene(r, true);
        } else { shown += cost; draw(); }
        say(r.message || r.error, !r.ok);
      }, function () { delete buying[key]; free(); shown += cost; draw(); say('Could not reach the game. Try again.', true); });
    });
  });
})();

/* Play scene (decorative only): the active cat in the stage (.cfactive, see catfish_stage_html) swaps its frame group by moving one class (fr-<frame>)
   and mirrors it in data-frame (data-anim-state: rest, play, nap or bored). It never touches Kibble: the counter above and the server tick stay the only authority.
   Frames: the page carries 8 groups (idleA, idleB, wiggle, stalk, pounce, catch, nap, bored). The others (swatA, swatB, blink, jump, happy, tailflick, eartwitch, yawn, stretch, washA, washB) are built
   from the manifest block #cf-frames (frame -> layer files, already resolved to the base frame's files for alias frames) after the first interaction or 2 s; until a
   frame's pictures have loaded a close frame stands in (swatA stalk, swatB and jump pounce, the rest idleA). Same-origin pictures, no inline script.
   Idle: idleA <-> idleB every 2.4-4.2 s (head tilt); idleA blinks for 120 ms every 3-6 s; every 5-12 s a tailflick (400 ms) or an eartwitch (300 ms); never during a play loop.
   Every 6-9 s of idling a play loop: wiggle .6 s, stalk .8 s, pounce .4 s, catch 1.2 s, back to idleA; after the first one, one time in four it sits bored for 3 s instead.
   A freshly napped cat (data-nap, until the first Kibble of the new run) and the Nap button show nap, with a floating z (.cfz) over it.
   Tap on a fish (event 'cftap' from the sync block above): swatA 120 ms, swatB 200 ms (the fish bounces from here, is-hit), catch 600 ms (is-caught for 240 ms), happy 500 ms, idleA.
   A combo of 5, or the top fish tapped twice within 1.5 s: jump (5 whole-pixel steps, class is-jump, 500 ms) then the catch and happy. A glitter fish (cfk-4) and combo 10
   show 3 sparkles over the fish (200 ms). The cat reacts at most once per 700 ms, faces the fish (class flip when the fish is left of room x 150) and wakes if napping.
   Side cats (.cfside) alternate idleA <-> idleB every 4-8 s from a seeded offset, and the nearest one stalks 800 ms when the active cat swats (swatB) or pounces.
   2.1.06: every 15-30 s of idle a yawn (900 ms), a stretch (900 ms) or a wash (washA, washB, washA, washB, 600 ms each); the window bird (owned 'window') hops (150 ms) or spreads its wings (200 ms) every 6-14 s;
   a swat (swatB) or pounce rolls the yarn ball 8 px and back (1.2 s, CATFISH_YARN_ROLL) and wobbles the rug 1 px. Dust motes are CSS only. ?cffast=1 makes the variety and bird waits ten times shorter (tests).
   prefers-reduced-motion: idleA only, nothing moves, no z, no sparkles, no bird, no yarn, no wobble; the tapped fish only shows its outline (is-hit) for 300 ms.
   The random numbers come from each cat's seed, so a page load plays the same sequence every time. */
(function () {
  var inst = null;
  /* init binds the whole machine to the current .cfactive stage and returns {snap, stop}. 2.1.07: after a buy swaps the stage (event 'cfscene' from the sync block) the old instance
     is stopped (every timer it started checks `dead`, listeners are removed) and a new one starts on the new nodes with the old cat's frame, nap state and facing kept. */
  function init(keep) {
  var cat = document.querySelector('.cfactive'); if (!cat) return null;
  var dead = false, stage = cat.parentNode;
  function T(fn, ms) { return setTimeout(function () { if (!dead) fn(); }, ms); }
  var have = {}, groups = {}; [].forEach.call(cat.querySelectorAll('.cfframe'), function (f) { have[f.getAttribute('data-f')] = true; });
  var cur = cat.getAttribute('data-frame'), timer = 0, napping = cat.getAttribute('data-nap') === '1', mode = 'rest', rest = 'idleA';
  function mk(seed) {
    var a = seed >>> 0;
    return function () { a = (a + 0x6D2B79F5) >>> 0; var t = a; t = Math.imul(t ^ (t >>> 15), t | 1); t ^= t + Math.imul(t ^ (t >>> 7), t | 61); return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
  }
  var seed = parseInt(cat.getAttribute('data-seed'), 10) || 1, rnd = mk(seed);
  function between(lo, hi) { return lo + rnd() * (hi - lo); }
  var mq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : null;
  function reduced() { return !!(mq && mq.matches); }
  var zEl = stage.querySelector('.cfz-a'), spark = stage.querySelector('.cfspark');
  var man = null; try { var me = document.getElementById('cf-frames'); if (me) man = JSON.parse(me.textContent); } catch (e) { man = null; }
  var FB = { swatA: 'stalk', swatB: 'pounce', jump: 'pounce', happy: 'idleA', blink: 'idleA', tailflick: 'idleA', eartwitch: 'idleA', yawn: 'idleA', stretch: 'idleA', washA: 'idleA', washB: 'idleA' };
  function build(f) {
    if (have[f] || !man || !man.frames || !man.frames[f]) return;
    var g = document.createElement('span'), art = document.createElement('span');
    g.className = 'cfframe ff-' + f; g.setAttribute('data-f', f); art.className = 'cfart cf-s64'; art.setAttribute('aria-hidden', 'true');
    man.frames[f].forEach(function (l) {
      var im = new Image(); im.alt = ''; im.width = 64; im.height = 64; im.src = man.p + l[0] + man.s;
      var n = im, c;
      if (l[2]) { c = document.createElement('span'); c.className = 'cfclip cfclip-' + l[2]; c.appendChild(n); n = c; }
      (l[1] || []).forEach(function (m) { c = document.createElement('span'); c.className = 'cfmk cfmk-' + m; c.appendChild(n); n = c; });
      art.appendChild(n);
    });
    g.appendChild(art); cat.appendChild(g); groups[f] = g; have[f] = true;
  }
  function ready(f) {
    if (!have[f]) return false;
    if (!groups[f]) return true;
    return [].every.call(groups[f].querySelectorAll('img'), function (im) { return im.complete && im.naturalWidth > 0; });
  }
  function resolve(f) {
    for (var n = 0; n < 3; n++) { if (ready(f)) return f; build(f); if (ready(f)) return f; f = FB[f] || 'idleA'; }
    return have.idleA ? 'idleA' : cur;
  }
  var preloaded = false;
  function preload() {
    if (preloaded || reduced() || !man || !man.frames) return; preloaded = true;
    var seen = {};
    Object.keys(man.frames).forEach(function (f) {
      build(f);
      man.frames[f].forEach(function (l) { var u = man.p + l[0] + man.s; if (!seen[u]) { seen[u] = 1; new Image().src = u; } });
    });
  }
  T(preload, 2000);
  ['pointerdown', 'pointerover', 'touchstart', 'keydown'].forEach(function (t) { stage.addEventListener(t, preload, { once: true, passive: true }); });
  function setMode(m) { mode = m; cat.setAttribute('data-anim-state', m); }
  function put(f) {
    if (f === cur) return;
    cat.classList.remove('fr-' + cur); cat.classList.add('fr-' + f); cat.setAttribute('data-frame', f); cur = f;
    if (zEl) zEl.classList.toggle('is-on', f === 'nap');
  }
  function show(f) { put(resolve(f)); }
  function later(ms, fn) { timer = T(fn, ms); }
  var idled = 0, plays = 0, nextPlay = between(6000, 9000);
  var PLAY = [['wiggle', 600], ['stalk', 800], ['pounce', 400], ['catch', 1200]];
  function back() { rest = 'idleA'; setMode('rest'); show('idleA'); }
  function play(i) {
    if (i >= PLAY.length) { back(); return later(between(1200, 2400), idle); }
    setMode('play'); show(PLAY[i][0]); if (PLAY[i][0] === 'pounce') { sideStalk(); landed(); }
    later(PLAY[i][1], function () { play(i + 1); });
  }
  function idle() {
    if (varying && mode === 'rest') return later(300, idle);
    if (napping) { setMode('nap'); show('nap'); return later(1000, idle); }
    setMode('rest');
    if (idled >= nextPlay) {
      idled = 0; nextPlay = between(6000, 9000);
      if (plays++ > 0 && rnd() < 0.25) { setMode('bored'); show('bored'); return later(3000, function () { back(); later(between(1200, 2400), idle); }); }
      return play(0);
    }
    var ms = between(2400, 4200);
    rest = rest === 'idleA' ? 'idleB' : 'idleA'; show(rest);
    idled += ms; later(ms, idle);
  }
  /* blink, tailflick and eartwitch ride on idleA only, on their own timers, and never while a loop, a nap or boredom runs */
  var bt = 0, et = 0;
  function flick(f, ms) {
    if (mode !== 'rest' || cur !== 'idleA') return false;
    build(f); if (!ready(f)) return false;
    put(f); T(function () { if (cur === f) put(mode === 'rest' ? 'idleA' : cur); }, ms); return true;
  }
  function schedBlink(wait) { clearTimeout(bt); bt = T(function () { schedBlink(flick('blink', 120) ? 0 : 400); }, wait || between(3000, 6000)); }
  function schedExtra(wait) {
    clearTimeout(et);
    et = T(function () { var tail = rnd() < 0.5; schedExtra(flick(tail ? 'tailflick' : 'eartwitch', tail ? 400 : 300) ? 0 : 500); }, wait || between(5000, 12000));
  }
  /* idle variety (2.1.06): every 15-30 s a yawn (900 ms), a stretch (900 ms) or a wash (washA, washB, washA, washB, 600 ms each) from idleA; never during a play loop, a nap or boredom.
     A tap or a play loop cancels it at once (vtok). ?cffast=1 on the page URL makes the waits and the bird ten times shorter (test hook; nothing else reads it). */
  var FAST = /[?&]cffast=1(&|$)/.test(location.search), vt = 0, vtok = 0, varying = false;
  function vwait() { return between(15000, 30000) * (FAST ? 0.1 : 1); }
  function vend(tok) { if (tok !== vtok) return; varying = false; put(mode === 'rest' ? 'idleA' : cur); }
  function vstep(seq, i, tok) {
    if (tok !== vtok) return;
    if (i >= seq.length) return vend(tok);
    put(seq[i][0]); T(function () { vstep(seq, i + 1, tok); }, seq[i][1]);
  }
  function schedVariety(wait) {
    clearTimeout(vt);
    vt = T(function () {
      if (mode !== 'rest' || cur !== 'idleA' || varying) return schedVariety(500);
      var r = rnd(), seq = r < 0.34 ? [['yawn', 900]] : r < 0.67 ? [['stretch', 900]] : [['washA', 600], ['washB', 600], ['washA', 600], ['washB', 600]];
      seq.forEach(function (st) { build(st[0]); });
      if (!seq.every(function (st) { return ready(st[0]); })) return schedVariety(500);
      varying = true; vtok++; vstep(seq, 0, vtok);
      schedVariety();
    }, wait || vwait());
  }
  function vcancel() { vtok++; varying = false; }
  /* side cats */
  var sides = [].map.call(stage.querySelectorAll('.cfside'), function (el) {
    var s = { el: el, cur: el.getAttribute('data-frame'), base: 'idleA', busy: false, t: 0, r: mk((parseInt(el.getAttribute('data-seed'), 10) || 1) + 977) };
    s.has = {}; [].forEach.call(el.querySelectorAll('.cfframe'), function (f) { s.has[f.getAttribute('data-f')] = true; });
    return s;
  });
  function sideShow(s, f) {
    if (!s.has[f] || f === s.cur) return;
    s.el.classList.remove('fr-' + s.cur); s.el.classList.add('fr-' + f); s.el.setAttribute('data-frame', f); s.cur = f;
  }
  function sideTick(s, first) {
    s.t = T(function () {
      if (!s.busy) { s.base = s.base === 'idleA' ? 'idleB' : 'idleA'; sideShow(s, s.base); }
      sideTick(s);
    }, first ? 500 + s.r() * 7500 : 4000 + s.r() * 4000);
  }
  function sideStart() { sides.forEach(function (s) { clearTimeout(s.t); sideTick(s, true); }); }
  function sideStop() { sides.forEach(function (s) { clearTimeout(s.t); s.busy = false; sideShow(s, 'idleA'); s.base = 'idleA'; }); }
  function sideStalk() {
    if (reduced()) return;
    var best = null, d = 1e9, cx = cat.offsetLeft;
    sides.forEach(function (s) { var x = Math.abs(s.el.offsetLeft - cx); if (s.has.stalk && !s.busy && x < d) { d = x; best = s; } });
    if (!best) return;
    best.busy = true; sideShow(best, 'stalk');
    T(function () { best.busy = false; sideShow(best, best.base); }, 800);
  }
  /* window bird (owned 'window'): the cf-room-window robin is swapped for the 12 x 10 sprite drawn at 2x on the perch; f1 perched, f2 hop (150 ms), f3 wings (200 ms), every 6-14 s.
     Without JS, or under reduced motion, the overlay with the robin stays. */
  var bird = stage.querySelector('.cfbird'), bt2 = 0, birdOn = false, br = mk(seed + 4242), birdTries = 0;
  function birdOk() { return [].every.call(bird.querySelectorAll('img'), function (im) { return im.complete && im.naturalWidth > 0; }); }
  function birdFrame(n) { bird.className = 'cfbird f' + n; }
  function birdNext() {
    clearTimeout(bt2);
    bt2 = T(function () {
      var hop = br() < 0.5; birdFrame(hop ? 2 : 3);
      T(function () { birdFrame(1); birdNext(); }, hop ? 150 : 200);
    }, (6000 + br() * 8000) * (FAST ? 0.1 : 1));
  }
  function birdStop() { clearTimeout(bt2); if (bird) { birdFrame(1); stage.classList.remove('is-bird'); } birdOn = false; }
  function birdStart() {
    if (!bird) return;
    clearTimeout(bt2); birdOn = false; stage.classList.remove('is-bird'); birdFrame(1);
    if (reduced()) return;
    if (!birdOk()) { if (birdTries++ < 20) bt2 = T(birdStart, 500); return; }
    birdOn = true; stage.classList.add('is-bird'); birdNext();
  }
  /* yarn roll (the ball at the left of the floor): when the cat swats (swatB) or pounces the ball rolls 8 px right and back in 1.2 s (8 steps of 150 ms), then the base ball is shown again.
     Set CATFISH_YARN_ROLL to false to turn it off. */
  var CATFISH_YARN_ROLL = true, yarn = stage.querySelector('.cfyarn'), yarnT = 0, rug = stage.querySelector('.cfl-rug'), rugT = 0;
  function landed() {
    if (reduced()) return;
    if (CATFISH_YARN_ROLL && yarn && !yarn.classList.contains('is-roll')) {
      yarn.classList.add('is-roll'); clearTimeout(yarnT); yarnT = T(function () { yarn.classList.remove('is-roll'); }, 1250);
    }
    if (rug) {   // rug wobble: 1 px right, back, 1 px, back (4 steps of 60 ms)
      rug.classList.remove('is-wobble'); void rug.offsetWidth; rug.classList.add('is-wobble');
      clearTimeout(rugT); rugT = T(function () { rug.classList.remove('is-wobble'); }, 300);
    }
  }
  var first = null;   // frame to show first after a scene swap (an inline frame of the old cat), else idleA
  function start() {
    clearTimeout(timer); clearTimeout(bt); clearTimeout(et); clearTimeout(vt); vcancel(); sideStop(); cat.classList.remove('is-jump');
    if (reduced()) { birdStop(); setMode(napping ? 'nap' : 'rest'); show(napping ? 'nap' : 'idleA'); first = null; return; }
    rest = 'idleA'; setMode(napping ? 'nap' : 'rest'); show(napping ? 'nap' : first || 'idleA'); first = null; later(between(1200, 2400), idle);
    schedBlink(); schedExtra(); schedVariety(); sideStart(); birdStart();
  }
  cat.setAttribute('data-anim-state', mode);
  if (keep) {   // scene swap: same nap state, same frame (when the new cat carries it inline), same facing
    napping = keep.napping; if (napping) cat.setAttribute('data-nap', '1'); else cat.removeAttribute('data-nap');
    if (have[keep.frame] && keep.frame !== 'nap') first = keep.frame;
    cat.classList.toggle('flip', keep.flip);
  }
  start();
  if (mq && mq.addEventListener) mq.addEventListener('change', start);
  var lastReact = 0, hitT = {}, lastTop = 0, lastCombo = 0;
  function hit(b) {
    var f = b.getAttribute('data-fish'), ms = reduced() ? 300 : 900;
    b.classList.remove('is-hit'); void b.offsetWidth; b.classList.add('is-hit');
    clearTimeout(hitT[f]); hitT[f] = T(function () { b.classList.remove('is-hit'); }, ms);
  }
  function caught(b) { b.classList.add('is-caught'); T(function () { b.classList.remove('is-caught'); }, 240); }
  function sparkle(b) {
    if (!spark || reduced()) return;
    spark.className = 'cfspark at' + b.getAttribute('data-fish'); void spark.offsetWidth; spark.classList.add('go');
    T(function () { spark.classList.remove('go'); }, 200);
  }
  function topFish(b) {
    var best = null, y = 1e9;
    [].forEach.call(stage.querySelectorAll('button.cfsdrop'), function (x) { var im = x.querySelector('img'), t = im ? im.offsetTop : 0; if (t < y) { y = t; best = x; } });
    return best === b;
  }
  function finish() { cat.classList.remove('flip', 'is-jump'); idled = 0; back(); later(between(1200, 2400), idle); }
  function react(b, jump) {
    var now = Date.now(); if (now - lastReact < 700) return false; lastReact = now;
    clearTimeout(timer); vcancel(); napping = false; cat.classList.remove('is-jump'); setMode('play'); preload();
    cat.classList.toggle('flip', b.offsetLeft + 24 < 150);
    function land() { show('catch'); caught(b); later(600, function () { show('happy'); later(500, finish); }); }
    if (jump) {
      show('jump'); cat.classList.add('is-jump');
      later(250, function () { hit(b); later(250, function () { cat.classList.remove('is-jump'); land(); }); });
    } else {
      show('swatA');
      later(120, function () { show('swatB'); hit(b); sideStalk(); landed(); later(200, land); });
    }
    return true;
  }
  stage.addEventListener('cftap', function (ev) {
    var b = ev.detail.btn, c = ev.detail.combo || 0, now = Date.now();
    if (reduced()) { hit(b); return; }
    var jump = c === 5 || (topFish(b) && (lastTop && now - lastTop < 1500 ? (lastTop = 0, true) : (lastTop = now, false)));
    if (b.classList.contains('cfk-4') || (c === 10 && lastCombo < 10)) sparkle(b);
    lastCombo = c;
    if (!react(b, jump)) hit(b);
  });
  var nf = document.getElementById('cf-napform'), onNap = function () { napping = true; vcancel(); setMode('nap'); show('nap'); };
  if (nf) nf.addEventListener('submit', onNap);
  var run = document.getElementById('cf-run'), mo = null;
  if (run && window.MutationObserver) {
    mo = new MutationObserver(function () {
      if (parseInt(run.textContent.replace(/\D/g, ''), 10) > 0) {
        cat.removeAttribute('data-nap');
        if (napping) { napping = false; idled = 0; start(); }
      }
    });
    mo.observe(run, { childList: true, characterData: true, subtree: true });
  }
  return {
    snap: function () { return { frame: cur, napping: napping, flip: cat.classList.contains('flip') }; },
    stop: function () {
      dead = true; clearTimeout(timer); clearTimeout(bt); clearTimeout(et); clearTimeout(vt); clearTimeout(bt2); clearTimeout(yarnT); clearTimeout(rugT);
      sides.forEach(function (s) { clearTimeout(s.t); });
      if (mq && mq.removeEventListener) mq.removeEventListener('change', start);
      if (nf) nf.removeEventListener('submit', onNap);
      if (mo) mo.disconnect();
    }
  };
  }
  inst = init(null);
  document.addEventListener('cfscene', function () {
    var keep = inst ? inst.snap() : null; if (inst) inst.stop();
    inst = init(keep);
  });
})();
