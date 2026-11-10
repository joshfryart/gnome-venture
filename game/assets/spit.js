/* Gnome Venture v1.4.0: Seed Spitting. Vanilla JS, no libraries.
   The server makes the round (wind, token, start time) and works the distance out itself from the angle and power you hand in.
   This file only draws the field, lets you drag a slingshot (or use the sliders), and animates the flight with the SAME steps as
   spit_sim() in includes/games.php (constants come from the page's data-phys), so what you see matches what is scored. */
(function () {
  'use strict';
  var rmq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };
  var W = 400, H = 220, GY = 188, X0 = 56, PXCM = 4, MAXPULL = 120, MINPULL = 10;
  var RAF = window.requestAnimationFrame || function (f) { return setTimeout(function () { f(performance.now()); }, 16); };

  function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }

  /* Same steps as spit_sim() in PHP. Returns {mm, pts} where pts are [x cm, y cm] every 4th step (1/30 s) plus the roll. */
  function sim(P, angle, power, wind, grit, nim, path) {
    angle = clamp(angle, P.amin, P.amax); power = clamp(power, 0, 100);
    var v = (P.vmin + (P.vmax - P.vmin) * power / 100) * (1 + P.grit * Math.max(0, grit));
    var a = angle * Math.PI / 180, vx = v * Math.cos(a), vy = v * Math.sin(a);
    var w = wind * Math.max(0.5, 1 - P.nim * Math.max(0, nim));
    var x = 0, y = P.h0, dt = P.dt, b = 0, pts = path ? [[0, y]] : [];
    for (var i = 0; i < 6000; i++) {
      var ax = -P.k * (vx - w), ay = -P.g - P.k * vy;
      vx += ax * dt; vy += ay * dt; x += vx * dt; y += vy * dt;
      if (y <= 0) {
        y = 0;
        if (vy < -P.bmin && b < 2) { vy = -vy * P.rest; vx *= P.fric; b++; }
        else { x += (vx > 0 ? 1 : -1) * vx * vx / (2 * P.roll); if (path) pts.push([x, 0]); break; }
      }
      if (path && i % 4 === 3) pts.push([x, y]);
    }
    return { mm: Math.max(0, Math.round(x * 10)), pts: pts };
  }

  function init(game) {
    game.classList.add('on');
    var P, form = game.querySelector('form.spitform');
    try { P = JSON.parse(game.getAttribute('data-phys')); } catch (e) { return; }
    if (!form || !P) return;
    var wind = +game.getAttribute('data-wind') || 0, gust = game.getAttribute('data-gust') === '1';
    var grit = +game.getAttribute('data-grit') || 0, nim = +game.getAttribute('data-nim') || 0;
    var wmax = +game.getAttribute('data-wmax') || 60;
    var angS = form.querySelector('input[name=angle]'), powS = form.querySelector('input[name=power]');
    var outs = form.querySelectorAll('output');
    var how = game.querySelector('.spithow');
    var cv = document.createElement('canvas');
    cv.width = W * 2; cv.height = H * 2; cv.className = 'spitcv';
    cv.setAttribute('role', 'img');
    cv.setAttribute('aria-label', 'Seed spitting field. Drag back from the left side like a slingshot and let go, or use the angle and power sliders below.');
    var wrap = document.createElement('div'), grab = document.createElement('div');   // v2.6.45: on a phone only the left of the field grabs a touch, so the rest still scrolls the page
    wrap.className = 'spitwrap'; grab.className = 'spitgrab';
    wrap.appendChild(cv); wrap.appendChild(grab); game.insertBefore(wrap, form);
    if (game.getAttribute('data-minms') !== null) P.minms = +game.getAttribute('data-minms') || 0;   // the server's real wait (spit_min_ms), not a guess
    game.classList.add('js');
    if (how) how.textContent = 'Drag back like a slingshot (start on the left half of the field), watch the dotted guide, let go to spit. The sliders do the same.';
    var ctx = cv.getContext('2d');
    var state = 'ready';   // ready -> fly -> done
    var born = Date.now();   // v1.4.1: the server wants a breath (spit_min_ms) between loading and spitting
    var drag = null;       // {id, sx, sy, cx, cy} in canvas units
    var fly = null;        // {pts, mm, t0, trail}
    var pal = null, palAt = 0;
    var angle = +angS.value, power = +powS.value;
    var landed = null;

    function colors() {
      var now = Date.now();
      if (pal && now - palAt < 800) return pal;
      var cs = getComputedStyle(document.body);
      function g(n, d) { var v = cs.getPropertyValue(n).trim(); return v || d; }
      var bg = g('--bg', '#f6f4ec'), m = /^#([0-9a-f]{6})$/i.exec(bg), dark = false;
      if (m) { var n = parseInt(m[1], 16); dark = (0.3 * (n >> 16) + 0.59 * ((n >> 8) & 255) + 0.11 * (n & 255)) < 110; }
      pal = { dark: dark, ink: g('--ink', '#1f2a1c'), muted: g('--muted', '#5f6a5a'), brand: g('--brand', '#2f6f3e'), accent: g('--accent', '#b8862b'),
        line: g('--line-2', '#c6c1ad'), danger: g('--danger', '#a7332a'),
        sky0: dark ? '#14233a' : '#cfe6f7', sky1: dark ? '#22403a' : '#eef6e6', hill: dark ? '#1f3a2a' : '#b9d6a0', hill2: dark ? '#1a2f33' : '#cfe3c2', cloud: dark ? '#2f4a63' : '#ffffff',
        ground: dark ? '#4a3a26' : '#8a6a42', grass: dark ? '#2f6a3c' : '#6fae4a', seed: dark ? '#f1e6c8' : '#2b2118' };
      palAt = now;
      return pal;
    }

    function sync(fromSliders) {
      angle = Math.round(clamp(angle, P.amin, P.amax)); power = Math.round(clamp(power, 0, 100));
      if (!fromSliders) { angS.value = angle; powS.value = power; }
      if (outs[0]) outs[0].textContent = angle + '°';
      if (outs[1]) outs[1].textContent = power + '%';
    }
    sync(true);
    angS.addEventListener('input', function () { if (state !== 'ready') return; angle = +angS.value; power = +powS.value; sync(true); });
    powS.addEventListener('input', function () { if (state !== 'ready') return; angle = +angS.value; power = +powS.value; sync(true); });

    /* ---- drawing (v2.6.45: stitched-toy pixel look, drawn at 2x so one art pixel is 2 device pixels) ---- */
    var cam = 0, parts = [], seenBounce = {}, landAt = 0, kickAt = 0;
    var CLOUDS = [[20, 26, 5], [150, 14, 7], [260, 38, 4], [340, 20, 6]];
    var RATE = 45;   // path points per second (the path has one every 1/30 s of flight, so this plays it a bit fast and snappy)
    function sx(cm) { return Math.round(X0 + cm * PXCM - cam); }
    function px(cm) { return X0 + cm * PXCM - cam; }
    function py(cm) { return GY - cm * PXCM; }
    function sn(v) { return Math.round(v); }
    function pxText(c, s, x, y, col, size, align) {
      c.font = 'bold ' + size + 'px system-ui, sans-serif'; c.textAlign = align || 'left';
      c.fillStyle = 'rgba(42,26,16,.55)'; c.fillText(s, x + 1, y + 1);
      c.fillStyle = col; c.fillText(s, x, y);
    }
    function puff(wx, y, n, col, up) {
      for (var i = 0; i < n; i++) parts.push({ x: wx, y: y, vx: (Math.random() - 0.5) * 60, vy: -(up ? 30 : 10) - Math.random() * 40, life: 0, max: 380 + Math.random() * 260, col: col, s: 2 + (Math.random() < 0.4 ? 2 : 0) });
    }
    function drawParts(c, dt) {
      for (var i = parts.length - 1; i >= 0; i--) {
        var p = parts[i]; p.life += dt * 1000;
        if (p.life >= p.max) { parts.splice(i, 1); continue; }
        p.x += p.vx * dt; p.y += p.vy * dt; p.vy += 110 * dt;
        c.globalAlpha = 1 - p.life / p.max; c.fillStyle = p.col;
        c.fillRect(sn(p.x - cam), sn(p.y), p.s, p.s);
      }
      c.globalAlpha = 1;
    }
    function drawWind(c, t, k) {
      var fx = W - 46, fy = 58, len = 6 + 34 * Math.min(1, Math.abs(wind) / wmax), dir = wind >= 0 ? 1 : -1;
      c.fillStyle = k.ink; c.fillRect(fx - 1, fy - 6, 2, 36); c.fillRect(fx - 3, fy + 28, 6, 2);
      if (wind === 0) { pxText(c, 'calm', fx, fy + 44, k.muted, 11, 'center'); return; }
      var seg = 6, amp = 3 + 3 * Math.min(1, Math.abs(wind) / wmax);
      c.fillStyle = gust ? k.accent : k.brand;
      for (var i = 0; i < seg; i++) {   // the windsock: stepped bands that ripple
        var bx = fx + dir * len * i / seg, bw = Math.max(2, Math.round(len / seg)), oy = Math.round(amp * Math.sin(t / 160 - i * 0.9) * (i / seg));
        c.fillRect(dir > 0 ? sn(bx) : sn(bx - bw), fy - 6 + oy + i, bw, 14 - i);
        if (i % 2) { c.fillStyle = k.ink; c.fillRect(dir > 0 ? sn(bx) : sn(bx - bw), fy - 6 + oy + i, 1, 14 - i); c.fillStyle = gust ? k.accent : k.brand; }
      }
      c.fillStyle = k.muted; c.globalAlpha = 0.5;   // drifting streaks
      for (var s = 0; s < 6; s++) {
        var sp = (Math.abs(wind) / wmax) * 0.06 + 0.02, xx = ((s * 83 + t * sp * dir) % W + W) % W, yy = 24 + (s * 37) % 110;
        c.fillRect(sn(xx), yy, sn(8 + 12 * Math.abs(wind) / wmax), 1);
      }
      c.globalAlpha = 1;
      pxText(c, Math.abs(wind) + ' cm/s', fx, fy + 44, k.muted, 11, 'center');
    }
    function guide(c, k) {
      var p = sim(P, angle, power, wind, grit, nim, true).pts, n = Math.min(p.length, 8 + 5 * nim);
      for (var i = 1; i < n; i++) {
        c.globalAlpha = 0.9 - 0.65 * i / n; c.fillStyle = k.ink;
        c.fillRect(sn(px(p[i][0])) - 1, sn(py(p[i][1])) - 1, 3, 3);
        c.fillStyle = k.accent; c.fillRect(sn(px(p[i][0])), sn(py(p[i][1])), 1, 1);
      }
      c.globalAlpha = 1;
    }
    /* ---- the player's 2.5D gnome (v2.6.45): the same sheet and bone tree as the fight engine (RIGS.gnome in fightengine.js),
       drawn on the canvas with spit poses: breathing idle, a wind-up that follows your pull, a head-snap "ptoo" on release, a hop or a slump on landing.
       Beard, scarf, hat and its tip are springs driven by how the bones turn, so they lag and whip on their own. ---- */
    var COL = { legB: 0, legF: 1, body: 2, scarf: 3, armU: 4, armL: 5, head: 6, beard: 7, lid: 8, hat: 9, tip: 10 };
    var BONES = {
      legB: { px: [28, 64], dim: .82 }, legF: { px: [36, 64] },
      body: { px: [32, 63], kids: ['scarf', 'armB', 'head', 'armF'] },
      scarf: { img: 'scarf', px: [29, 46], under: 1, spring: { k: 110, d: 7, g: .12, max: 55, wind: 16 } },
      armB: { img: 'armU', px: [33, 48], ox: 4, dim: .72, under: 1, ink: 0, kids: ['foreB'] }, foreB: { img: 'armL', px: [33, 56], dim: .72, ink: 0 },
      head: { img: 'head', px: [33, 46], kids: ['beard', 'lid', 'hat'] },
      beard: { img: 'beard', px: [33, 44], spring: { k: 150, d: 9, g: .1, max: 40, wind: 8 } },
      lid: { img: 'lid', px: [38, 39], ink: 0, hide: 1 },
      hat: { img: 'hat', px: [32, 37], spring: { k: 110, d: 7, g: .07, max: 14, wind: 4 }, kids: ['tip'] }, tip: { img: 'tip', px: [28, 11], spring: { k: 80, d: 6, g: .1, max: 26, wind: 8 } },
      armF: { img: 'armU', px: [33, 48], ink: 0, kids: ['foreF'] }, foreF: { img: 'armL', px: [33, 56], ink: 0 }
    };
    var ROOTS = ['legB', 'legF', 'body'], MOUTH = [44, 42], FEET = [32, 71], GS = 1.5;   // GS: one art pixel = 3 device pixels at the 2x backing
    var sheet = new Image(), sheetOk = false, sheetTried = 0;
    sheet.onload = function () { sheetOk = sheet.naturalWidth > 0; };
    sheet.onerror = function () { var f = game.getAttribute('data-sheet0'); if (!sheetTried && f) { sheetTried = 1; sheet.src = f; } };
    sheet.src = game.getAttribute('data-sheet') || '';
    if (sheet.complete && sheet.naturalWidth > 0) sheetOk = true;
    var mats = {}, spr = {}, blinkAt = 0, nextBlink = 1800, relAt = 0, relF = 0, fEase = 0, lastRot = {}, lastOm = {};
    for (var bn in BONES) if (BONES[bn].spring) spr[bn] = { a: 0, v: 0 };
    function mmul(m, n) { return [m[0] * n[0] + m[2] * n[1], m[1] * n[0] + m[3] * n[1], m[0] * n[2] + m[2] * n[3], m[1] * n[2] + m[3] * n[3], m[0] * n[4] + m[2] * n[5] + m[4], m[1] * n[4] + m[3] * n[5] + m[5]]; }
    function mpt(m, p) { return [m[0] * p[0] + m[2] * p[1] + m[4], m[1] * p[0] + m[3] * p[1] + m[5]]; }
    function env(e, tau, w) { return e < 0 ? 0 : Math.exp(-e / tau) * Math.sin(e / w); }   // a damped wobble: 0 at the start, a peak, then settles
    function gnomeOrigin() { return [X0 - 18 - cam, GY]; }   // where the feet centre stands (the rest-pose mouth sits on the 0 cm line)
    /* Pose: per bone {r deg (clockwise +, forward is negative on a limb), x, y px, sx, sy}. Sums of idle + wind-up + release + landing. */
    function posing(t) {
      var p = {}; function A(b, r, x, y, sx, sy) { var o = p[b] || (p[b] = { r: 0, x: 0, y: 0, sx: 1, sy: 1 }); o.r += r || 0; o.x += x || 0; o.y += y || 0; o.sx *= sx || 1; o.sy *= sy || 1; }
      var u = reduce ? 0 : (1 - Math.cos(t / 1600 * 2 * Math.PI)) / 2, u2 = reduce ? 0 : (1 - Math.cos((t - 150) / 1600 * 2 * Math.PI)) / 2;
      A('body', .6 * u, 0, -u); A('head', -1 + 3 * u2, 0, .4 * u2);
      A('armF', 2 + 4 * u, 0, 0); A('foreF', -6 - 7 * u2); A('armB', -2 - 4 * u); A('foreB', -8 + 5 * u2);
      var f = drag ? drag.len / MAXPULL : 0, e = relAt ? t - relAt : -1;
      if (!reduce) fEase += (f - fEase) * Math.min(1, 16 * 0.016);
      else fEase = f;
      var w = fEase, hold = relAt && e >= 0 ? relF * Math.exp(-e / 55) : 0, F = Math.max(w, hold);   // the wind-up, then it lets go fast
      A('body', -9 * F, 0, 1.2 * F, 1 + .03 * F, 1 - .06 * F);
      A('head', -7 * F, 0, 0, 1 + .09 * F, 1 + .09 * F);   // cheeks puff
      A('armF', 38 * F); A('foreF', -26 * F); A('armB', 28 * F); A('foreB', -18 * F);
      A('legF', -9 * F); A('legB', 9 * F);
      if (!reduce && F > .8) A('head', 0, .5 * Math.sin(t / 38), 0);   // straining
      if (relAt && e >= 0 && !reduce) {   // release: head snaps forward, body follows, arms fling
        var k1 = env(e, 170, 62) * relF;
        A('head', 26 * k1, 0, 0, 1 - .08 * relF * Math.exp(-e / 120), 1 - .08 * relF * Math.exp(-e / 120)); A('body', 13 * k1); A('armF', -34 * k1); A('foreF', -20 * k1); A('armB', -22 * k1);
      }
      if (landAt && fly) {   // landing: a hop and cheer for a prize, a slump for a dribble
        var le = reduce ? 1000 : t - landAt, cm = fly.mm / 10, ramp = Math.min(1, le / 220);
        if (cm >= 30) {
          var hop = reduce ? 0 : Math.abs(Math.sin(le / 190)) * (le < 1100 ? 1 : 0) * (cm >= 60 ? 5 : 3);
          var pump = reduce ? 0 : 12 * Math.sin(le / 95);   // arms flung out and swinging, with the hop (the shoulder sits under the chin, so straight up would hide the face)
          A('body', 0, 0, -hop); A('armF', -(72 + pump) * ramp); A('foreF', -14 * ramp); A('armB', (74 - pump) * ramp); A('foreB', -12 * ramp); A('head', -5 * ramp);
          A('legF', (reduce ? 0 : 6 * Math.sin(le / 95))); A('legB', (reduce ? 0 : -6 * Math.sin(le / 95)));
        } else { A('head', 14 * ramp); A('body', 5 * ramp, 0, 1 * ramp); A('armF', 10 * ramp); A('armB', -6 * ramp); A('foreF', 6 * ramp); }
      }
      return p;
    }
    var DRAW = [];
    (function order(id) { var b = BONES[id], kids = b.kids || []; kids.forEach(function (k) { if (BONES[k].under) order(k); }); DRAW.push(id); kids.forEach(function (k) { if (!BONES[k].under) order(k); }); })('body');
    DRAW = ['legB', 'legF'].concat(DRAW);   // roots: boots stand alone, so a lean never lifts them
    function stepRig(t, dt) {
      var p = posing(t), rot = {};
      if (!reduce && t >= nextBlink) { blinkAt = t; nextBlink = t + 2600 + Math.random() * 2800; }
      function walk(id, M, pr) {
        var b = BONES[id], q = p[id] || { r: 0, x: 0, y: 0, sx: 1, sy: 1 }, s = spr[id], r = q.r;
        if (s) r += s.a + (wind / wmax) * -(b.spring.wind || 0);   // the wind leans scarf, beard and hat
        var a = r * Math.PI / 180, ca = Math.cos(a), sa = Math.sin(a), px = b.px;
        var T = mmul(mmul([1, 0, 0, 1, px[0] + q.x + (b.ox || 0), px[1] + q.y], [ca * q.sx, sa * q.sx, -sa * q.sy, ca * q.sy, 0, 0]), [1, 0, 0, 1, -px[0], -px[1]]);
        var m = mmul(M, T); mats[id] = m; rot[id] = pr + q.r;
        (b.kids || []).forEach(function (k) { walk(k, m, rot[id]); });
      }
      ROOTS.forEach(function (id) { walk(id, [1, 0, 0, 1, 0, 0], 0); });
      if (!reduce) for (var id in spr) {   // springs: pushed by how fast the bone they hang from is turning, pulled home and damped
        var par = id === 'tip' ? 'hat' : (id === 'hat' || id === 'beard') ? 'head' : 'body', R = rot[par] || 0, d = Math.min(Math.max(dt, .001), .033);
        var om = (R - (lastRot[id] === undefined ? R : lastRot[id])) / d, al = (om - (lastOm[id] || 0)) / d, S = spr[id], sp = BONES[id].spring;
        lastRot[id] = R; lastOm[id] = om;
        S.v += (-sp.k * S.a - sp.d * S.v - sp.g * 5 * al) * d; S.a = Math.max(-sp.max, Math.min(sp.max, S.a + S.v * d));
      }
      return blinkAt && t - blinkAt < 140;
    }
    function mouthXY() { var m = mats.head; if (!m) return [X0 - cam, GY - 40]; var q = mpt(m, MOUTH), o = gnomeOrigin(); return [o[0] + (q[0] - FEET[0]) * GS, o[1] + (q[1] - FEET[1]) * GS]; }
    function drawGnome(c, t, dt, k) {
      var o = gnomeOrigin(), ox = sn(o[0]), oy = sn(o[1]);
      c.fillStyle = 'rgba(42,26,16,.28)'; c.fillRect(ox - 16, GY, 32, 3);   // its shadow
      var blink = stepRig(t, dt);
      if (!sheetOk) { if (sheet.complete && sheet.naturalWidth > 0) sheetOk = true; else return; }
      for (var pass = 0; pass < 2; pass++) for (var i = 0; i < DRAW.length; i++) {   // all ink first, then all paint: one outline however the parts move
        var id = DRAW[i], b = BONES[id], m = mats[id]; if (!m) continue;
        if (b.hide && !(id === 'lid' && blink)) continue;
        if (pass === 0 && b.ink === 0) continue;
        c.setTransform(2, 0, 0, 2, 0, 0); c.translate(ox, oy); c.scale(GS, GS); c.translate(-FEET[0], -FEET[1]); c.transform(m[0], m[1], m[2], m[3], m[4], m[5]);
        if (pass === 1 && b.dim && 'filter' in c) c.filter = 'brightness(' + b.dim + ')';
        c.drawImage(sheet, COL[b.img || id] * 64, pass === 0 ? 80 : 0, 64, 80, 0, 0, 64, 80);
        if ('filter' in c) c.filter = 'none';
      }
      c.setTransform(2, 0, 0, 2, 0, 0); c.textAlign = 'left';
    }
    function draw(t, dt) {
      var c = ctx, k = colors();
      c.setTransform(2, 0, 0, 2, 0, 0); c.globalAlpha = 1; c.setLineDash([]); c.imageSmoothingEnabled = false; c.textBaseline = 'alphabetic';
      var gr = c.createLinearGradient(0, 0, 0, GY); gr.addColorStop(0, k.sky0); gr.addColorStop(1, k.sky1);
      c.fillStyle = gr; c.fillRect(0, 0, W, H);
      // clouds (slow parallax, blown by the wind)
      c.fillStyle = k.cloud;
      for (var ci = 0; ci < CLOUDS.length; ci++) {
        var cl = CLOUDS[ci], cx = ((cl[0] - cam * 0.12 + t * 0.004 * (wind >= 0 ? 1 : -1) * (1 + Math.abs(wind) / wmax)) % (W + 80) + W + 80) % (W + 80) - 40, w = cl[2] * 6;
        c.fillRect(sn(cx), cl[1], w, 6); c.fillRect(sn(cx) + 6, cl[1] - 4, w - 12, 4); c.fillRect(sn(cx) + 3, cl[1] + 6, w - 6, 3);
      }
      // two stepped hill layers
      for (var layer = 0; layer < 2; layer++) {
        c.fillStyle = layer ? k.hill : k.hill2; var par = layer ? 0.3 : 0.15, base = layer ? 26 : 44;
        for (var x = 0; x < W; x += 4) {
          var wx = x + cam * par, h = sn(base + (layer ? 14 : 10) * Math.sin(wx / (layer ? 55 : 80)) + 6 * Math.sin(wx / 23));
          c.fillRect(x, GY - h, 4, h);
        }
      }
      c.fillStyle = k.ground; c.fillRect(0, GY, W, H - GY);
      c.fillStyle = k.grass; c.fillRect(0, GY, W, 5);
      c.fillStyle = k.ink; c.globalAlpha = 0.35; c.fillRect(0, GY + 5, W, 1); c.globalAlpha = 1;
      var lean = wind === 0 ? 0 : (wind > 0 ? 1 : -1) * Math.min(2, Math.round(Math.abs(wind) / wmax * 3));
      c.fillStyle = k.grass;
      for (var gxp = -((cam | 0) % 10); gxp < W; gxp += 10) {   // grass tufts that lean with the wind
        var tw = Math.round(1 + 1.2 * Math.sin(t / 380 + (gxp + cam) * 0.7));
        c.fillRect(gxp, GY - 3, 2, 3); c.fillRect(gxp + lean + tw, GY - 5, 2, 2);
      }
      // distance ticks and the prize stakes
      c.font = '10px system-ui, sans-serif'; c.textAlign = 'center';
      var d0 = Math.max(10, Math.floor(cam / PXCM / 10) * 10);
      for (var d = d0; d <= d0 + 100; d += 10) {
        var X = sx(d); if (X < 0) continue; if (X > W - 14) break;
        c.fillStyle = k.line; c.fillRect(X, GY + 5, 1, 4);
        c.fillStyle = k.ink; c.globalAlpha = 0.8; c.fillText(String(d), X, GY + 19); c.globalAlpha = 1;
      }
      var PR = [30, 45, 60], got = fly && landAt ? fly.mm / 10 : -1;
      for (var pi = 0; pi < 3; pi++) {
        var PX = sx(PR[pi]); if (PX < -8 || PX > W + 8) continue;
        var hit = got >= PR[pi];
        for (var yy = GY - 4; yy > GY - 66; yy -= 8) { c.fillStyle = k.accent; c.globalAlpha = hit ? 1 : 0.7; c.fillRect(PX, yy, 2, 4); }
        c.globalAlpha = 1; c.fillStyle = hit ? k.accent : k.ink; c.fillRect(PX - 4, GY - 70, 10, 5);   // a little pennant
        c.fillStyle = hit ? k.ink : k.accent; c.fillRect(PX - 3, GY - 69, 8, 3);
        pxText(c, String(PR[pi]), PX + 1, GY - 74, k.accent, 10, 'center');
      }
      c.fillStyle = k.muted; c.font = '10px system-ui, sans-serif'; c.textAlign = 'right'; c.fillText('cm', W - 4, GY + 19); c.textAlign = 'left';
      drawWind(c, t, k);
      drawGnome(c, t, dt, k);
      if (state === 'ready') {
        guide(c, k);
        if (drag) {
          c.setLineDash([4, 3]); c.strokeStyle = k.accent; c.lineWidth = 2;   // the sling is gold thread
          c.beginPath(); c.moveTo(sn(drag.sx), sn(drag.sy)); c.lineTo(sn(drag.cx), sn(drag.cy)); c.stroke(); c.setLineDash([]);
          c.fillStyle = k.ink; c.fillRect(sn(drag.cx) - 4, sn(drag.cy) - 4, 8, 8); c.fillStyle = k.danger; c.fillRect(sn(drag.cx) - 3, sn(drag.cy) - 3, 6, 6);
          // power pips over the gnome
          var gx0 = clamp(sn(gnomeOrigin()[0]) - 25, 4, W - 56), on = Math.round(power / 10);
          for (var pp = 0; pp < 10; pp++) { c.fillStyle = k.ink; c.fillRect(gx0 + pp * 5, GY - 104, 5, 6); c.fillStyle = pp < on ? (pp > 7 ? k.danger : k.accent) : k.line; c.fillRect(gx0 + pp * 5 + 1, GY - 103, 3, 4); }
          pxText(c, angle + '°  ' + power + '%', clamp(drag.cx + 10, 4, W - 80), clamp(drag.cy - 10, 14, H - 4), k.ink, 12);
        } else {
          pxText(c, '← drag back, then let go', 70, 30, k.muted, 12);
        }
      }
      if (fly) {
        var el = (t - fly.t0) / 1000, wI = Math.max(0, 1 - el / 0.18), idx = Math.max(0, el * RATE), pts = fly.pts, n = pts.length, cur, i2;
        var upto = Math.min(n - 1, Math.floor(idx));
        for (i2 = fly.seen + 1; i2 <= upto; i2++) {   // bounces and the landing kick up dust
          var pt = pts[i2], prev = pts[i2 - 1], nxt = pts[i2 + 1];
          if (i2 === n - 1 || (pt[1] < 3 && prev && prev[1] > pt[1] && nxt && nxt[1] > pt[1])) puff(X0 + pt[0] * PXCM, GY - 1, i2 === n - 1 ? 12 : 7, i2 % 2 ? k.ground : k.grass, true);
        }
        fly.seen = Math.max(fly.seen, upto);
        if (el >= 0 && !fly.puffed) { fly.puffed = 1; puff(fly.mx + cam, fly.my, 7, '#f6efd8', false); }   // the ptoo
        c.fillStyle = k.ink; c.globalAlpha = 0.22;
        for (i2 = 0; i2 <= upto; i2++) c.fillRect(sn(px(pts[i2][0])), sn(py(pts[i2][1])), 2, 2);
        c.globalAlpha = 1;
        if (idx >= n - 1) cur = pts[n - 1];
        else { var f = idx - Math.floor(idx), a = pts[Math.floor(idx)], b = pts[Math.floor(idx) + 1]; cur = [a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f]; }
        for (i2 = 1; i2 <= 9; i2++) {   // a bright comet tail
          var tp = pts[Math.max(0, Math.floor(idx) - i2)];
          if (!tp || idx >= n - 1) break;
          c.globalAlpha = 0.6 * (1 - i2 / 10); c.fillStyle = k.accent; c.fillRect(sn(px(tp[0])), sn(py(tp[1])), 3, 3);
        }
        c.globalAlpha = 1;
        // follow camera: pans only when the seed nears the right edge, so the gnome stays in view for a normal spit
        var want = Math.max(0, X0 + cur[0] * PXCM - (W - 70));
        cam += (want - cam) * Math.min(1, 6 * dt);
        // shadow on the grass, smaller the higher the seed is
        var sh = Math.max(2, Math.round(10 / (1 + cur[1] / 25)));
        c.fillStyle = 'rgba(42,26,16,.35)'; c.fillRect(sn(px(cur[0])) - (sh >> 1), GY + 1, sh, 2);
        // the seed: dark with a cream edge, tumbling
        if (el >= 0) { c.save(); c.translate(sn(px(cur[0]) + fly.ox * wI), sn(py(cur[1]) + fly.oy * wI)); c.rotate(el * 14);
        c.fillStyle = '#f6efd8'; c.fillRect(-4, -3, 8, 6); c.fillStyle = '#2b2118'; c.fillRect(-3, -2, 6, 4); c.fillStyle = '#7a5a30'; c.fillRect(-2, -2, 2, 1);
        c.restore(); }
        var shown = idx >= n - 1 ? fly.mm / 10 : Math.max(0, cur[0]);
        var pop = landAt ? Math.max(0, 1 - (t - landAt) / 260) : 0;
        pxText(c, shown.toFixed(1) + ' cm', 14, 30 + Math.round(pop * -4), pop ? k.accent : k.ink, 20 + Math.round(pop * 6));
        if (idx >= n - 1) {
          if (!landAt) { landAt = t; }
          var fxp = sx(fly.mm / 10), ft = reduce ? 1 : (t - landAt) / 1000, drop = Math.max(0, 1 - ft / 0.22) * 36, bnc = ft > 0.22 && ft < 0.4 ? Math.round(Math.sin((ft - 0.22) / 0.18 * Math.PI) * 4) : 0;
          var ry = GY - 28 - Math.round(drop) - bnc;
          c.fillStyle = k.ink; c.fillRect(fxp, ry, 2, 28 + bnc + Math.round(drop)); c.fillRect(fxp, ry, 14, 10);   // flag pole + banner
          c.fillStyle = k.accent; c.fillRect(fxp + 2, ry + 2, 10, 6);
          c.fillStyle = k.ink; c.globalAlpha = Math.max(0, 0.6 - ft * 1.2);   // a ring of dust
          var rr = Math.round(ft * 60); c.fillRect(fxp - rr, GY + 2, 4, 1); c.fillRect(fxp + rr, GY + 2, 4, 1); c.globalAlpha = 1;
          var prize = got >= 60 ? 60 : got >= 45 ? 45 : got >= 30 ? 30 : 0;
          if (prize && ft > 0.25) {   // twinkling stars and a label for the best line passed
            for (var sp = 0; sp < 6; sp++) {
              var ang = sp * 1.05 + ft * 2, rad = 14 + 10 * Math.sin(ft * 5 + sp), stx = fxp + 7 + Math.round(Math.cos(ang) * rad), sty = ry - 6 + Math.round(Math.sin(ang) * rad * 0.7), sz = (Math.floor(ft * 8 + sp) % 2) ? 3 : 1;
              c.fillStyle = k.accent; c.fillRect(stx - sz, sty, 2 * sz + 1, 1); c.fillRect(stx, sty - sz, 1, 2 * sz + 1);
            }
            pxText(c, '★ ' + prize + ' cm prize!', 14, 52, k.accent, 14);
          }
        }
      }
      drawParts(c, dt || 0.016);
    }

    /* ---- the loop ---- */
    var reduce = !!rmq.matches;
    var lastTs = 0;
    function frame(ts) {
      if (!game.isConnected) return;
      var dt = lastTs ? Math.min(0.05, (ts - lastTs) / 1000) : 0.016; lastTs = ts;
      draw(ts, dt);
      if (fly && ts - fly.t0 >= fly.end && !fly.sent) { fly.sent = true; setTimeout(send, reduce ? 100 : 250); }
      if (!reduce || state === 'fly' || drag) RAF(frame);
    }
    function redraw() { if (reduce && state === 'ready' && !drag) draw(performance.now(), 0.016); }
    RAF(frame);
    if (reduce) { angS.addEventListener('input', redraw); powS.addEventListener('input', redraw); }

    /* ---- input: a slingshot. The pull is measured from where the finger went down; the seed goes the opposite way. ---- */
    function pos(ev) {
      var r = cv.getBoundingClientRect();
      return [(ev.clientX - r.left) * W / r.width, (ev.clientY - r.top) * H / r.height];
    }
    function aim(ev) {
      var p = pos(ev), dx = p[0] - drag.sx, dy = p[1] - drag.sy, len = Math.min(MAXPULL, Math.hypot(dx, dy));
      var k = Math.hypot(dx, dy) > 0 ? len / Math.hypot(dx, dy) : 0;
      drag.cx = drag.sx + dx * k; drag.cy = drag.sy + dy * k; drag.len = len;
      angle = Math.round(clamp(Math.atan2(dy, -dx) * 180 / Math.PI, P.amin, P.amax));
      power = Math.round(100 * len / MAXPULL);
      sync(false);
    }
    function down(ev) {
      if (state !== 'ready' || (ev.button != null && ev.button > 0)) return;
      if (ev.currentTarget === cv && ev.pointerType === 'touch') return;   // a touch off the grab zone is the page's: let it scroll
      ev.preventDefault();
      var p = pos(ev);
      drag = { id: ev.pointerId, sx: p[0], sy: p[1], cx: p[0], cy: p[1], len: 0 };
      try { ev.currentTarget.setPointerCapture(ev.pointerId); } catch (e) { /* fine */ }
      if (reduce) RAF(frame);
    }
    function move(ev) {
      if (!drag || ev.pointerId !== drag.id) return;
      ev.preventDefault(); aim(ev); redraw();
    }
    cv.addEventListener('pointerdown', down); grab.addEventListener('pointerdown', down);
    cv.addEventListener('pointermove', move); grab.addEventListener('pointermove', move);
    function up(ev) {
      if (!drag || ev.pointerId !== drag.id) return;
      aim(ev);
      var ok = drag.len >= MINPULL && ev.type === 'pointerup';
      drag = null;
      if (ok) { try { go(); } catch (e) { state = 'fly'; send(); } } else redraw();
    }
    cv.addEventListener('pointerup', up); grab.addEventListener('pointerup', up);
    cv.addEventListener('pointercancel', up); grab.addEventListener('pointercancel', up);
    cv.style.touchAction = 'pan-y'; grab.style.touchAction = 'none';

    /* ---- fire ---- */
    function go() {
      if (state !== 'ready') return;
      state = 'fly';
      form.classList.add('flying');
      angS.value = angle; powS.value = power; sync(true);
      var r = sim(P, angle, power, wind, grit, nim, true);
      var n = r.pts.length;
      var nowT = performance.now(), mo = mouthXY(), D = reduce ? 0 : 110;   // the seed leaves the mouth 110 ms after you let go, as the head snaps forward
      relAt = nowT; relF = Math.max(fEase, power / 100);
      fly = { pts: r.pts, mm: r.mm, t0: reduce ? nowT - 60000 : nowT + D, end: reduce ? 1 : (n / RATE) * 1000 + 800 + D, sent: false, seen: 0, mx: mo[0], my: mo[1], ox: mo[0] - px(0), oy: mo[1] - py(P.h0) };   // 800 ms hold so the landing and prize show before the page updates
      if (reduce) { cam = Math.max(0, X0 + r.mm / 10 * PXCM - (W - 70)); draw(performance.now() + 5, 0.016); }
      RAF(frame);
      setTimeout(function () { if (state === 'fly' && fly && !fly.sent) { fly.sent = true; send(); } }, fly.end + 2500);   // v1.4.1: watchdog if frames stall
    }
    function send() {
      if (state === 'done') return;
      var wait = ((P.minms !== undefined ? +P.minms : 1000) + 250) - (Date.now() - born);   // v1.4.1: never fire before the server's minimum (fast taps, reduced motion)
      if (wait > 0) { setTimeout(send, wait); return; }
      state = 'done';
      form.setAttribute('data-fired', '1');
      var b = form.querySelector('button');
      try { if (form.requestSubmit) form.requestSubmit(b || undefined); else form.submit(); } catch (e) { form.submit(); }
      setTimeout(function () {   // v2.6.45: if the page never updates (a dropped connection), unfreeze the form and let the shot be sent again
        if (!game.isConnected || state !== 'done') return;
        state = 'retry'; form.removeAttribute('data-fired'); form.classList.remove('flying');
        if (how) how.textContent = 'The Hollow did not answer. Tap Spit! to send your shot again.';
      }, 9000);
    }
    form.addEventListener('submit', function (ev) {
      if (form.getAttribute('data-fired') === '1') return;   // the real one: let site.js send it in place
      // v1.4.1: never swallow a tap. If the animation is stuck or throws (seen on Firefox for Android), send the shot as it is.
      if (state !== 'ready') { if (state === 'fly' && !(fly && fly.sent)) { ev.preventDefault(); send(); } return; }
      ev.preventDefault();
      angle = +angS.value; power = +powS.value;
      try { go(); } catch (e) { state = 'fly'; send(); }
    });
  }

  function scan() { document.querySelectorAll('.spitgame:not(.on)').forEach(init); }
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.body, { childList: true, subtree: true });
})();
