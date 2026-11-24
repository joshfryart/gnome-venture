/* Cat Fish room2 engine (setting catfish_room2). One 480x270 canvas draws the whole room: wall, floor, furniture, the cats and the rod from the top.
   Depth: a floor point (u,d) maps to screen y = 268 - 158*d^0.8, x = 240 + (u-.5)*720*(1-.45*d); a cat is drawn at scale 1 - .58*d (snapped to 1/16).
   Tap the floor: the wand casts, the lure flies down the room and the cat chases it (CATCH pays through window.CFPlay, x1.25 when far). Tap a dangling fish: pays x1.5.
   Idle cats wander; the active cat sometimes has the zoomies (runs sideways off the screen and back); the others sometimes chase each other.
   Art: assets/img/catfish/room2/ (tools/catfish_room2_pack.py). Cat layers are composed once per cat into strips (body, erase mask, ears/tail part, pattern, eyes).
   No inline script or style (CSP): data comes from the .cfr2data JSON block of the stage. prefers-reduced-motion: no wandering, no zoomies, the cat steps to the lure. ?cffast=1 shortens the idle waits (tests). */
(function () {
  var inst = null;
  var FAST = /[?&]cffast=1\b/.test(location.search);
  var mqR = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : null;
  function reduced() { return !!(mqR && mqR.matches); }
  function clamp(v, a, b) { return v < a ? a : (v > b ? b : v); }
  function mk(seed) { var a = seed >>> 0; return function () { a = (a + 0x6D2B79F5) >>> 0; var t = a; t = Math.imul(t ^ (t >>> 15), t | 1); t ^= t + Math.imul(t ^ (t >>> 7), t | 61); return ((t ^ (t >>> 14)) >>> 0) / 4294967296; }; }
  var rnd = mk((Date.now() & 0xffffff) | 1);
  function between(a, b) { return a + rnd() * (b - a); }

  /* ---- depth model ---- */
  function yOf(d) { return 268 - 158 * Math.pow(d, 0.8); }
  function dOf(y) { return Math.pow(clamp((268 - y) / 158, 0.0001, 1.2), 1.25); }
  function sOf(d) { return Math.round((1 - 0.58 * d) * 16) / 16; }
  function xOf(u, d) { return 240 + (u - 0.5) * 720 * (1 - 0.45 * d); }
  function uOf(x, d) { return 0.5 + (x - 240) / (720 * (1 - 0.45 * d)); }
  var FLOOR_TOP = 112, FLOOR_MIN_Y = 118, FLOOR_MAX_Y = 262;

  function start() {
    var wrap = document.querySelector('.cfr2wrap'); if (!wrap) return null;
    var cv = wrap.querySelector('canvas.cfr2cv'), dEl = wrap.querySelector('.cfr2data'); if (!cv || !dEl) return null;
    var D; try { D = JSON.parse(dEl.textContent); } catch (e) { return null; }
    var ctx = cv.getContext('2d'); if (!ctx) return null;
    ctx.imageSmoothingEnabled = false;
    var dead = false, M = null, imgs = {}, pendingLoads = 0;
    var t0 = 0, last = 0, raf = 0, now = 0;

    /* ---- assets ---- */
    function img(url) {
      if (imgs[url]) return imgs[url];
      var im = new Image(), o = { im: im, ok: false, bad: false }; imgs[url] = o; pendingLoads++;
      im.onload = function () { o.ok = true; pendingLoads--; }; im.onerror = function () { o.bad = true; pendingLoads--; };
      im.src = url; return o;
    }
    function U(path) { return D.base + path + '?v=' + D.v; }
    function okImg(path) { var o = imgs[U(path)]; return o && o.ok ? o.im : null; }
    function want(path) { return img(U(path)); }

    /* ---- cats ---- */
    var CS = { run: { w: 80, h: 64, n: 12, ms: 60 }, zoom: { w: 80, h: 64, n: 6, ms: 50 }, toward: { w: 64, h: 64, n: 8, ms: 70 }, away: { w: 64, h: 64, n: 8, ms: 70 }, idle: { w: 64, h: 64, n: 7, ms: 600 } };
    var IDLE = { idleA: 0, idleB: 1, stalk: 2, pounce: 3, nap: 4, wiggle: 5, catch: 6 };
    function layerNames(a, set) {
      var cat = a.c, c = cat.coat, o = { body: 'cat-' + c, erase: [], parts: [], pat: '', eyes: set === 'away' ? '' : 'eyes-' + cat.eyes };
      if (cat.fold) { o.erase.push('ears-clear'); o.parts.push('ears-folded-' + c); }
      if (cat.bob) { o.erase.push('tail-clear'); o.parts.push('tail-bobtail-' + c); }
      if (cat.pat) o.pat = 'pat-' + cat.pat + '-' + c + (cat.fold && set !== 'idle' ? '-fold' : '');
      return o;
    }
    function allLayers(L) { return [L.body].concat(L.erase, L.parts, L.pat ? [L.pat] : [], L.eyes ? [L.eyes] : []); }
    function sheetFor(cat, set) {   // the composed strip (a canvas) once every layer has loaded, else null; starts the loads
      var key = set, sh = cat.sheets[key]; if (sh) return sh.c || null;
      var L = layerNames(cat, set), names = allLayers(L), ready = true;
      names.forEach(function (n) { var p = 'cat/' + set + '/' + n + '.png'; want(p); if (!okImg(p)) ready = false; });
      var bad = names.some(function (n) { var o = imgs[U('cat/' + set + '/' + n + '.png')]; return o && o.bad && (n === L.body); });
      if (bad) { cat.sheets[key] = { c: null }; return null; }
      var anyPending = names.some(function (n) { var o = imgs[U('cat/' + set + '/' + n + '.png')]; return o && !o.ok && !o.bad; });
      if (anyPending) return null;
      var spec = CS[set], c = document.createElement('canvas'); c.width = spec.w * spec.n; c.height = spec.h;
      var g = c.getContext('2d'); g.imageSmoothingEnabled = false;
      function put(n, op) { var im = okImg('cat/' + set + '/' + n + '.png'); if (!im) return; g.globalCompositeOperation = op || 'source-over'; g.drawImage(im, 0, 0); g.globalCompositeOperation = 'source-over'; }
      put(L.body);
      if (set === 'idle') { if (L.pat) put(L.pat); L.erase.forEach(function (n) { put(n, 'destination-out'); }); L.parts.forEach(function (n) { put(n); }); }
      else { L.erase.forEach(function (n) { put(n, 'destination-out'); }); L.parts.forEach(function (n) { put(n); }); if (L.pat) put(L.pat); }
      if (L.eyes) put(L.eyes);
      cat.sheets[key] = { c: c }; return c;
    }

    var keep = (window.__cfr2keep || {}), cushionTaken = false;
    var cats = D.cats.map(function (c, i) {
      var k = keep[c.id], a = { c: c, id: c.id, active: c.id === D.active, sheets: {}, st: 'idle', t: 0, x: 0, y: 0, face: 1, home: null, nx: 0, ny: 0, tx: 0, ty: 0, tgt: null, wait: 0, blink: 0, frame: 0, anim: 0, vis: true, next: 0, caught: 0, rnd: mk((c.seed | 0) + 7), set: 'idle', fi: 0, sleepZ: 0 };
      a.home = c.id === D.active ? { u: 0.5, d: 0.1 } : { u: [0.3, 0.7, 0.62, 0.38][i % 4], d: [0.55, 0.3, 0.5, 0.42][i % 4] };
      if (k) { a.x = k.x; a.y = k.y; a.st = k.st === 'chase' ? 'idle' : k.st; a.face = k.face; } else { a.x = xOf(a.home.u, a.home.d); a.y = yOf(a.home.d); }
      if (a.active && D.nap && !k) a.st = 'nap';
      if (!a.active && c.mood === 'lazy' && !cushionTaken && !k) { cushionTaken = true; a.st = 'nap'; a.onCushion = true; a.x = 64; a.y = 226; }
      if (k && k.cush) a.onCushion = true;
      return a;
    });
    var act = cats.filter(function (a) { return a.active; })[0] || cats[0];
    if (!cats.length) return null;

    /* ---- room ---- */
    var owned = D.owned || {};
    function manifest(cb) {
      if (!window.fetch) return;   // the manifest is plain JSON read with fetch (same origin, so the strict CSP allows it)
      fetch(U('manifest.json')).then(function (r) { return r.json(); }).then(function (m) { M = m; cb(); });
    }
    function hourPhase() { var h = new Date().getHours(); return h >= 8 && h < 18 ? 0 : ((h >= 6 && h < 8) || (h >= 18 && h < 21) ? 1 : 2); }
    function furnVisible(k, f) {
      if (f.upgrade === 'pets') return false;
      if (f.upgrade !== 'base' && !(owned[f.upgrade] > 0)) return false;
      if (k === 'bowl-plain' && owned.bowl > 0) return false;
      if (k === 'yarnpatch' && owned.rug > 0) return false;
      return true;
    }
    var PLATES = ['room/cf-room2-p0-sky.png', 'room/cf-room2-p0n-night-sky.png', 'room/cf-room2-p1-wall.png', 'room/cf-room2-p2-floor.png', 'room/cf-room2-p5-sunbeam.png', 'room/cf-room2-window.png', 'room/cf-room2-window-nobird.png', 'room/cf-room2-p4-front.png', 'room/cf-room2-p5b-night.png'];
    function loadRoom() {
      PLATES.forEach(want);
      Object.keys(M.furn).forEach(function (k) { if (furnVisible(k, M.furn[k])) want('furn/' + M.furn[k].file); });
      ['cf-wand-cast-1', 'cf-wand-cast-2', 'cf-wand-cast-3', 'cf-wand-cast-4', 'cf-wand-cast-5', 'cf-wand-cast-6'].forEach(function (n) { want('props/' + n + '.png'); });
      ['near', 'mid', 'far'].forEach(function (s) { for (var i = 1; i <= 6; i++) want('props/cf-lure-' + s + '-' + i + '.png'); });
      for (var i = 1; i <= 4; i++) { want('props/cf-shadow-' + i + '.png'); want('props/cf-dust-' + i + '.png'); }
      for (i = 1; i <= 3; i++) want('props/cf-streak-' + i + '.png');
      D.fish.forEach(function (k) { img(D.fishUrl + 'cf-fish-' + k + '.png?v=' + D.v); });
    }
    function fishImg(k) { var o = imgs[D.fishUrl + 'cf-fish-' + k + '.png?v=' + D.v]; return o && o.ok ? o.im : null; }

    /* ---- wand, fish, lure ---- */
    var wand = { fr: 1, t: 0, seq: [], hold: 0 };   // fr 1..6 = cf-wand-cast-N
    var WAND_X = 216;                                 // wand image x (centre 240)
    function wandAttach() { var f = M && M.wand.frames[wand.fr - 1]; return f ? { x: WAND_X + f.attach[0], y: f.attach[1] } : { x: 240, y: 52 }; }
    var fish = D.fish.map(function (k, i) { return { k: k, i: i, ang: 0, vel: 0, len: [26, 34, 28][i], dx: [-26, 0, 26][i], cool: 0, pop: 0, popV: 0, x: 0, y: 0 }; });
    var lure = null;       // { x0,y0,x1,y1,u,d,t,T,state:'fly'|'land'|'idle'|'reel', fr, ft, size }
    var pops = [], dusts = [], zs = [];
    var lastThrow = 0, catchesIn20 = [], nextZoom = FAST ? 6000 : between(40000, 80000), nextTag = FAST ? 5000 : between(20000, 40000);
    function lureSize(d) { return d < 0.3 ? 'near' : (d < 0.6 ? 'mid' : 'far'); }
    var LURE = { near: { w: 32, px: 16, py: 28 }, mid: { w: 20, px: 10, py: 17 }, far: { w: 12, px: 6, py: 10 } };

    function castTo(x, y) {
      if (now - lastThrow < 420 || !M) return;
      lastThrow = now;
      var d = clamp(dOf(y), 0.05, 0.9), u = clamp(uOf(x, d), 0.06, 0.94), yy = yOf(d), xx = xOf(u, d);
      if (lure) lure.dead = true;
      var seq = [[2, 120], [u < 0.4 ? 3 : (u > 0.6 ? 5 : 4), 110], [6, 290], [1, 0]];
      wand.seq = seq; wand.t = now; wand.fr = 2; wand.launched = false; wand.pend = { x: xx, y: yy, u: u, d: d };
      if (!/^zoom/.test(act.st)) act.st = 'alert';
      var hint = document.getElementById('cf-hint'); if (hint) hint.hidden = true;
      if (reduced()) { wand.seq = [[1, 0]]; wand.fr = 1; launch(); }
    }
    function launch() {
      var p = wand.pend; if (!p) return; wand.pend = null; wand.launched = true;
      var a = wandAttach(), dist = Math.hypot(p.x - a.x, p.y - a.y);
      lure = { x0: a.x, y0: a.y, x1: p.x, y1: p.y, u: p.u, d: p.d, t: now, T: reduced() ? 1 : clamp(300 + dist * 1.1, 360, 760), H: 30 + dist * 0.18, state: 'fly', ft: 0, fr: 1, size: lureSize(p.d), far: p.d >= 0.55 };
      cats.forEach(function (c) { if (c === act) { c.vis = true; c.zoomRun = false; c.st = 'chase'; c.tgt = lure; } });
      // the other cats sometimes join in (never faster than the active cat)
      cats.forEach(function (c) { if (c !== act && (c.st === 'idle' || c.st === 'wander') && rnd() < 0.22) { c.st = 'chase'; c.tgt = lure; c.slow = 0.7; } });
    }
    function lurePos(l) {
      if (l.state === 'fly') { var t = clamp((now - l.t) / l.T, 0, 1); return { x: l.x0 + (l.x1 - l.x0) * t, y: l.y0 + (l.y1 - l.y0) * t - 4 * l.H * t * (1 - t), t: t }; }
      return { x: l.x1, y: l.y1, t: 1 };
    }

    /* ---- cat brains ---- */
    function setOf(c, dx, dy) {
      if (c.zoomRun) return 'zoom';
      if (Math.abs(dy) > Math.abs(dx) * 0.9) return dy > 0 ? 'toward' : 'away';
      return 'run';
    }
    function moveTo(c, tx, ty, speed, dt) {   // returns true on arrival
      var dx = tx - c.x, dy = ty - c.y, dist = Math.hypot(dx, dy), s = sOf(dOf(c.y)), step = speed * (0.55 + 0.45 * s) * dt / 1000;
      if (dist <= Math.max(step, 2)) { c.x = tx; c.y = ty; return true; }
      c.x += dx / dist * step; c.y += dy / dist * step;
      c.set = setOf(c, dx, dy * 1.6); if (c.set === 'run' || c.set === 'zoom') c.face = dx >= 0 ? 1 : -1;
      c.moving = true; return false;
    }
    function dust(c) { dusts.push({ x: c.x, y: c.y, t: now, s: sOf(dOf(c.y)) }); }
    function pop(x, y, v, txt) { pops.push({ x: x, y: y, t: now, v: txt || ('+' + v) }); }
    function catchLure(c, l) {
      c.st = 'catch'; c.t = now; l.state = 'caught'; l.t = now; c.set = 'idle'; c.fi = IDLE.catch;
      var v = window.CFPlay ? window.CFPlay.tap(l.far ? 'far' : 'catch') : 0;
      pop(c.x, c.y - 60 * sOf(dOf(c.y)), v, v > 0 ? '+' + v + (l.far ? ' far!' : '') : (window.CFPlay && window.CFPlay.left() <= 0 ? 'rest a moment' : ''));
      c.caught++; catchesIn20.push(now);
    }
    function think(c, dt) {
      c.moving = false; c.set = 'idle';
      var st = c.st;
      if (!c.vis && st !== 'zoomhide') c.vis = true;
      if (st === 'nap') { c.fi = IDLE.nap; if (c.active && !D.nap && now - (c.t || 0) > 0) { /* naps only until the first tap */ } return; }
      if (st === 'alert') { c.fi = IDLE.stalk; return; }
      if (st === 'chase') {
        var l = c.tgt; if (!l || l.dead || l.state === 'reel' || l.state === 'caught') { c.st = 'return'; c.slow = 0; return; }
        if (l.state === 'fly') { var prog = (now - l.t) / l.T; c.face = l.x1 >= c.x ? 1 : -1; if (prog < 0.4) { c.fi = IDLE.stalk; c.set = 'idle'; } else moveTo(c, l.x1, l.y1, 200 * (c.slow || 1), dt); return; }
        var sp = (reduced() ? 5000 : 330) * (c.slow || 1);
        if (moveTo(c, l.x1, l.y1, sp, dt)) {
          if (c.active) { c.st = 'pounce'; c.t = now; dust(c); c.set = 'idle'; c.fi = IDLE.pounce; }
          else { c.st = 'return'; }
        }
        return;
      }
      if (st === 'pounce') { c.fi = IDLE.pounce; if (now - c.t > 180) { if (c.tgt && !c.tgt.dead && c.tgt.state !== 'caught') catchLure(c, c.tgt); else c.st = 'return'; } return; }
      if (st === 'catch') { c.fi = IDLE.catch; if (now - c.t > 520) { c.st = 'return'; c.tgt = null; } return; }
      if (st === 'return') {
        var h = c.home, hx = xOf(h.u, h.d), hy = yOf(h.d);
        if (moveTo(c, hx, hy, reduced() ? 5000 : 200, dt)) { c.st = 'idle'; c.wait = now + (FAST ? between(800, 2000) : between(3000, 7000)); c.slow = 0; }
        return;
      }
      if (st === 'wander') {
        if (moveTo(c, c.nx, c.ny, 120, dt)) { c.st = 'idle'; c.wait = now + (FAST ? between(1500, 3000) : between(4000, 9000)); }
        return;
      }
      if (st === 'tagged') { if (moveTo(c, c.nx, c.ny, 300, dt)) { c.st = 'idle'; c.wait = now + 2000; } return; }
      if (st === 'tag') {   // chase another cat, then pounce and wiggle
        var o = c.other; if (!o) { c.st = 'idle'; return; }
        if (moveTo(c, o.x, o.y + 4, 260, dt)) { c.st = 'play'; c.t = now; o.st = 'tagged'; var tx = clamp(o.x + (o.x > 240 ? -1 : 1) * between(80, 160), 60, 420), ty = clamp(o.y + between(-30, 30), FLOOR_MIN_Y + 14, FLOOR_MAX_Y - 6); o.nx = tx; o.ny = ty; }
        return;
      }
      if (st === 'play') { c.fi = now - c.t < 300 ? IDLE.pounce : IDLE.wiggle; if (now - c.t > 900) { c.st = 'idle'; c.wait = now + 3000; } return; }
      if (st === 'zoom') {   // the zoomies: out of the screen along a row, then in from the other side
        c.zoomRun = true; var tx2 = c.zDir > 0 ? 540 : -60;
        if (moveTo(c, tx2, c.y, 560, dt)) { c.st = 'zoomhide'; c.t = now; c.vis = false; c.zoomRun = false; }
        return;
      }
      if (st === 'zoomhide') {
        if (now - c.t > 650) { c.vis = true; c.zDir = -c.zDir; c.x = c.zDir > 0 ? -60 : 540; c.y = yOf(between(0.12, 0.45)); c.st = 'zoomin'; }
        return;
      }
      if (st === 'zoomin') {
        c.zoomRun = true; var hx2 = xOf(c.home.u, c.home.d), hy2 = yOf(c.home.d);
        if (moveTo(c, hx2, hy2, 520, dt)) { c.zoomRun = false; c.st = 'return'; dust(c); }
        return;
      }
      // idle: sit, blink, wiggle, now and then wander
      c.fi = IDLE.idleA;
      if (now > c.blink && now < c.blink + 160) c.fi = IDLE.idleB;
      else if (now >= c.blink + 160) c.blink = now + (FAST ? between(700, 1600) : between(2200, 5200));
      if (c.wiggle && now < c.wiggle + 450) c.fi = IDLE.wiggle;
      if (!c.wait) c.wait = now + (FAST ? between(1200, 3000) : between(3500, 8000));
      if (now > c.wait && !reduced()) {
        var r = rnd();
        if (c.active && r < 0.18) { c.wiggle = now; c.wait = now + 2500; }
        else {
          c.st = 'wander'; var d2 = between(0.08, c.active ? 0.5 : 0.62), u2 = between(0.3, 0.7);
          c.nx = xOf(u2, d2); c.ny = yOf(d2);
        }
      }
    }
    function pickEvents() {
      if (reduced()) return;
      if (now > nextZoom && act.st === 'idle') {
        nextZoom = now + (FAST ? between(9000, 15000) : between(45000, 90000));
        act.st = 'zoom'; act.zDir = rnd() < 0.5 ? 1 : -1; act.y = yOf(between(0.12, 0.4)); act.moving = true;
      }
      if (now > nextTag && cats.length > 1) {
        nextTag = now + (FAST ? between(6000, 10000) : between(25000, 50000));
        var free = cats.filter(function (c) { return c.st === 'idle' && !c.onCushion; });
        if (free.length > 1) { var a = free[Math.floor(rnd() * free.length)], b = free.filter(function (c) { return c !== a; })[Math.floor(rnd() * (free.length - 1))]; a.st = 'tag'; a.other = b; }
      }
    }

    /* ---- drawing ---- */
    function draw1(path, x, y, w, h) { var im = okImg(path); if (im) ctx.drawImage(im, Math.round(x), Math.round(y), w || im.naturalWidth, h || im.naturalHeight); return !!im; }
    function drawCat(c) {
      if (!c.vis) return;
      var d = dOf(c.y), s = sOf(d), set = c.set, sh = null;
      if (c.zoomRun) set = 'zoom';
      if (!c.moving && set !== 'idle') set = 'idle';
      if (set !== 'idle' && !(sh = sheetFor(c, set))) { set = c.set === 'toward' || c.set === 'away' ? 'run' : set; sh = set !== 'idle' ? sheetFor(c, set) : null; if (!sh) { set = 'idle'; } }
      if (set === 'idle') sh = sheetFor(c, 'idle');
      if (!sh) { sheetFor(c, 'idle'); return; }
      var sp = CS[set], fi = 0;
      if (set === 'idle') fi = c.fi | 0; else fi = Math.floor(now / sp.ms) % sp.n;
      var ax = sp.w / 2, ay = sp.h - 3, dw = sp.w * s, dh = sp.h * s, dx = c.x - ax * s, dy = c.y - ay * s;
      // shadow
      var si = s >= 0.88 ? 1 : (s >= 0.7 ? 2 : (s >= 0.46 ? 3 : 4)), sim = okImg('props/cf-shadow-' + si + '.png');
      if (sim) { ctx.globalAlpha = 0.35; ctx.drawImage(sim, Math.round(c.x - sim.naturalWidth / 2), Math.round(c.y - sim.naturalHeight / 2 - 1)); ctx.globalAlpha = 1; }
      if (set === 'zoom' && !reduced()) { var st = okImg('props/cf-streak-' + (1 + Math.floor(now / 70) % 3) + '.png'); if (st) ctx.drawImage(st, Math.round(c.x - (c.face > 0 ? 56 : -16) * s), Math.round(c.y - 30 * s), Math.round(st.naturalWidth * s), Math.round(st.naturalHeight * s)); }
      ctx.save();
      if ((set === 'run' || set === 'zoom') && c.face < 0) { ctx.translate(Math.round(c.x * 2) / 2, 0); ctx.scale(-1, 1); ctx.drawImage(sh, fi * sp.w, 0, sp.w, sp.h, Math.round(-ax * s), Math.round(dy), Math.round(dw), Math.round(dh)); }
      else ctx.drawImage(sh, fi * sp.w, 0, sp.w, sp.h, Math.round(dx), Math.round(dy), Math.round(dw), Math.round(dh));
      ctx.restore();
      if (c.st === 'nap' && !reduced()) { var zy = (now / 40) % 60; ctx.fillStyle = '#fff8e2'; ctx.font = '700 ' + Math.round(9 + zy / 12) + 'px monospace'; ctx.globalAlpha = 1 - zy / 60; ctx.fillText('z', Math.round(c.x + 14 * s + zy / 6), Math.round(c.y - 46 * s - zy)); ctx.globalAlpha = 1; }
    }
    function drawLure() {
      if (!lure) return;
      var l = lure, p = lurePos(l), sz = LURE[l.size], fr = 1, name;
      if (l.state === 'fly') { fr = 2 + Math.floor(now / 90) % 2; }
      else if (l.state === 'land' || l.state === 'idle') { var age = now - l.landT; fr = age < 60 ? 1 : (age < 140 ? 2 : (age < 220 ? 3 : (age < 320 ? 4 : 5 + Math.floor(now / 300) % 2))); }
      else if (l.state === 'caught') fr = 4;
      var lx = p.x, ly = p.y;
      if (l.state === 'reel') { var tr = clamp((now - l.t) / 380, 0, 1), a2 = wandAttach(); lx = l.x1 + (a2.x - l.x1) * tr; ly = l.y1 + (a2.y - l.y1) * tr - 20 * Math.sin(tr * Math.PI); }
      var im = okImg('props/cf-lure-' + l.size + '-' + fr + '.png');
      var wa = wandAttach();
      // line from the wand tip to the lure's string loop
      ctx.strokeStyle = '#74462a'; ctx.lineWidth = 1; ctx.beginPath(); ctx.moveTo(Math.round(wa.x) + 0.5, Math.round(wa.y) + 0.5); ctx.lineTo(Math.round(lx) + 0.5, Math.round(ly - sz.py + 6) + 0.5); ctx.stroke();
      if (im) ctx.drawImage(im, Math.round(lx - sz.px), Math.round(ly - sz.py));
    }
    function drawWand() {
      var im = okImg('props/cf-wand-cast-' + wand.fr + '.png'); if (im) ctx.drawImage(im, WAND_X, 0);
      var a = wandAttach(), t = now / 1000;
      fish.forEach(function (f) {
        f.vel += (-f.ang * 14 - f.vel * 1.6) * 0.016; f.ang += f.vel * 0.016 + Math.sin(t * 1.3 + f.i * 2) * 0.0012;
        var bx = a.x + f.dx * 0.5, by = a.y + 2, ang = f.ang + (wand.fr === 3 ? -0.25 : (wand.fr === 5 ? 0.25 : 0)), fx = bx + Math.sin(ang) * f.len + f.dx * 0.6, fy = by + Math.cos(ang) * f.len;
        f.x = fx; f.y = fy;
        ctx.strokeStyle = '#74462a'; ctx.lineWidth = 1; ctx.beginPath(); ctx.moveTo(Math.round(bx) + 0.5, Math.round(by) + 0.5); ctx.lineTo(Math.round(fx) + 0.5, Math.round(fy - 10) + 0.5); ctx.stroke();
        var fi = fishImg(f.k); if (fi) ctx.drawImage(fi, Math.round(fx - 12), Math.round(fy - 12), 24, 24);
      });
    }
    function drawPops() {
      pops = pops.filter(function (p) { return now - p.t < 1100; });
      pops.forEach(function (p) {
        if (!p.v) return; var k = (now - p.t) / 1100, y = p.y - k * 26; ctx.globalAlpha = 1 - k * k; ctx.font = '700 13px sans-serif'; ctx.textAlign = 'center';
        ctx.lineWidth = 3; ctx.strokeStyle = '#2a1a10'; ctx.strokeText(p.v, Math.round(p.x), Math.round(y)); ctx.fillStyle = '#ffe9a8'; ctx.fillText(p.v, Math.round(p.x), Math.round(y)); ctx.globalAlpha = 1; ctx.textAlign = 'left';
      });
      dusts = dusts.filter(function (d) { return now - d.t < 360; });
      dusts.forEach(function (d) { var im = okImg('props/cf-dust-' + (1 + Math.floor((now - d.t) / 90)) + '.png'); if (im) ctx.drawImage(im, Math.round(d.x - im.naturalWidth / 2), Math.round(d.y - im.naturalHeight)); });
    }
    function render() {
      ctx.clearRect(0, 0, 480, 270);
      var ph = hourPhase(), night = ph === 2;
      draw1(night ? 'room/cf-room2-p0n-night-sky.png' : 'room/cf-room2-p0-sky.png', 0, 0);
      draw1('room/cf-room2-p1-wall.png', 0, 0); draw1('room/cf-room2-p2-floor.png', 0, 0);
      if (owned.sunbeam > 0 && ph === 0) { ctx.globalAlpha = 0.9; draw1('room/cf-room2-p5-sunbeam.png', 0, 0); ctx.globalAlpha = 1; }
      var items = [];
      Object.keys(M.furn).forEach(function (k) {
        var f = M.furn[k]; if (!furnVisible(k, f)) return;
        if (f.kind === 'wall' || f.kind === 'floor-decal') draw1('furn/' + f.file, f.origin[0], f.origin[1]);
        else items.push({ z: f.z, f: f, k: k });
      });
      var vis = cats.filter(function (c) { return c.vis; });
      var all = items.map(function (i) { return { z: i.z - 0.01, fn: function () { draw1('furn/' + i.f.file, i.f.origin[0], i.f.origin[1]); } }; })
        .concat(vis.map(function (c) { return { z: c.y, fn: function () { drawCat(c); } }; }));
      all.sort(function (a, b) { return a.z - b.z; });
      all.forEach(function (o) { o.fn(); });
      draw1(owned.window > 0 ? 'room/cf-room2-window.png' : 'room/cf-room2-window-nobird.png', 0, 0);
      draw1('room/cf-room2-p4-front.png', 0, 0);
      if (ph) { ctx.globalAlpha = ph === 2 ? M.layout.night.opacity_night : M.layout.night.opacity_dusk; ctx.fillStyle = M.layout.night.tint; ctx.fillRect(0, 0, 480, 270); ctx.globalAlpha = 1; }
      if (night) draw1('room/cf-room2-p5b-night.png', 0, 0);
      drawLure(); drawWand(); drawPops();
    }

    /* ---- loop ---- */
    function tick(ts) {
      if (dead) return; raf = requestAnimationFrame(tick);
      if (document.hidden) { last = ts; return; }
      now = ts; var dt = clamp(ts - (last || ts), 0, 50); last = ts;
      // wand sequence: [frame, ms] steps, the last step [1, 0] is the rest pose; the lure leaves on the flick (frames 3 to 5)
      if (wand.seq.length) {
        var cur = wand.seq[0];
        if (cur[1] > 0 && now - wand.t >= cur[1]) { wand.seq.shift(); wand.t = now; cur = wand.seq[0]; }
        if (!cur || cur[1] === 0) { wand.fr = 1; wand.seq = []; if (wand.pend) launch(); }
        else { wand.fr = cur[0]; if (!wand.launched && wand.pend && cur[0] >= 3 && cur[0] <= 5) launch(); }
      }
      if (lure) {
        if (lure.dead) { lure = null; }
        else if (lure.state === 'fly' && now - lure.t >= lure.T) { lure.state = 'land'; lure.landT = now; dust({ x: lure.x1, y: lure.y1 }); }
        else if (lure.state === 'caught' && now - lure.t > 520) { lure.state = 'reel'; lure.t = now; }
        else if (lure.state === 'reel' && now - lure.t > 380) lure = null;
      }
      cats.forEach(function (c) { think(c, dt); });
      pickEvents();
      catchesIn20 = catchesIn20.filter(function (t) { return now - t < 20000; });
      render();
    }

    /* ---- input ---- */
    function toCanvas(ev) { var r = cv.getBoundingClientRect(); return { x: (ev.clientX - r.left) * 480 / r.width, y: (ev.clientY - r.top) * 270 / r.height }; }
    function swatFish(f, p) {
      var t = Date.now(); if (f.cool && t - f.cool < 600) return; f.cool = t;
      f.vel += (p && p.x < f.x ? 1 : -1) * 3.2;
      var v = window.CFPlay ? window.CFPlay.tap('rod') : 0; pop(f.x, f.y - 14, v, v > 0 ? '+' + v : '');
      if (act.st === 'nap') { act.st = 'idle'; act.wait = 0; }
    }
    function onDown(ev) {
      if (!M) return; var p = toCanvas(ev), hit = null;
      fish.forEach(function (f) { if (Math.hypot(p.x - f.x, p.y - f.y) < 17) hit = f; });
      if (hit) { swatFish(hit, p); return; }
      if (p.y >= FLOOR_MIN_Y && p.y <= 268) castTo(p.x, clamp(p.y, FLOOR_MIN_Y, FLOOR_MAX_Y));
    }
    cv.addEventListener('pointerdown', onDown);
    var keys = wrap.querySelectorAll('.cfr2key');
    [].forEach.call(keys, function (b) {
      b.addEventListener('click', function (ev) {
        if (ev.detail !== 0 || !M) return;   // a real pointer click is handled on the canvas; this is the keyboard / screen reader path
        var a = b.getAttribute('data-act');
        if (a === 'floor') castTo(between(180, 300), between(150, 200));
        else { var f = fish[(+b.getAttribute('data-fish') || 1) - 1]; if (f) swatFish(f, null); }
      });
    });
    window.CFRoom = { zoom: function () { nextZoom = 0; }, state: function () { return { cats: cats.map(function (c) { return { id: c.id, st: c.st, x: Math.round(c.x), y: Math.round(c.y), set: c.set, vis: c.vis, caught: c.caught }; }), lure: lure ? lure.state : null, M: !!M, pending: pendingLoads }; }, cast: castTo };

    manifest(function () { loadRoom(); raf = requestAnimationFrame(tick); });
    return {
      stop: function () { dead = true; cancelAnimationFrame(raf); cv.removeEventListener('pointerdown', onDown); },
      keep: function () { var k = {}; cats.forEach(function (c) { k[c.id] = { x: c.x, y: c.y, st: c.st, face: c.face, cush: !!c.onCushion }; }); return k; }
    };
  }
  function boot() { if (inst) { window.__cfr2keep = inst.keep(); inst.stop(); inst = null; } inst = start(); }
  document.addEventListener('cfscene', boot);
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot); else boot();
})();
