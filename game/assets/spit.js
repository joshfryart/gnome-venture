/* Gnome Venture v1.4.0: Seed Spitting. Vanilla JS, no libraries.
   The server makes the round (wind, token, start time) and works the distance out itself from the angle and power you hand in.
   This file only draws the field, lets you drag a slingshot (or use the sliders), and animates the flight with the SAME steps as
   spit_sim() in includes/games.php (constants come from the page's data-phys), so what you see matches what is scored. */
(function () {
  'use strict';
  /* v2.0.24: the gnome on the canvas is our icon when it has loaded (emoji until then) */
  var gnomeImg = null;
  function gnomeIco() { if (!gnomeImg && window.gvIcoNode) gnomeImg = gvIcoNode('ico-gnome-gardener'); return gnomeImg && gnomeImg.complete ? gnomeImg : null; }
  var rmq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };
  var W = 400, H = 220, GY = 188, X0 = 40, PXCM = 4, MAXPULL = 120, MINPULL = 10;
  var RAF = window.requestAnimationFrame || function (f) { return setTimeout(function () { f(Date.now()); }, 16); };

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
    cv.setAttribute('aria-label', 'Seed spitting field. Drag back from anywhere like a slingshot and let go, or use the angle and power sliders below.');
    game.insertBefore(cv, form);
    game.classList.add('js');
    if (how) how.textContent = 'Drag back like a slingshot (anywhere on the field), watch the dotted guide, let go to spit. The sliders do the same.';
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
    function gnomePose(t) {   // [lean radians, squash x, squash y]: winds back while you pull, springs forward on release
      if (kickAt) {
        var e = (t - kickAt) / 380;
        if (e < 1) { var s = Math.sin(e * Math.PI * 2.2) * (1 - e); return [0.22 * s, 1 - 0.1 * s, 1 + 0.16 * s]; }
      }
      if (drag && drag.len) { var f = drag.len / MAXPULL; return [-0.32 * f, 1 + 0.08 * f, 1 - 0.14 * f]; }
      return [0.02 * Math.sin(t / 700), 1, 1 + 0.015 * Math.sin(t / 350)];   // idle: a slow breath
    }
    function drawGnome(c, t, k) {
      var gi = gnomeIco(), ps = gnomePose(t), gx = sn(X0 - 17 - cam), gy = GY + 2;
      c.fillStyle = 'rgba(42,26,16,.28)'; c.fillRect(gx - 12, GY, 24, 3);   // its shadow
      c.save(); c.translate(gx, gy); c.rotate(ps[0]); c.scale(ps[1], ps[2]);
      if (gi) { try { c.drawImage(gi, -17, -34, 34, 34); } catch (e) { c.font = '34px system-ui, "Apple Color Emoji", sans-serif'; c.textAlign = 'center'; c.fillText('🧑‍🌾', 0, 0); } }
      else { c.font = '34px system-ui, "Apple Color Emoji", sans-serif'; c.textAlign = 'center'; c.fillText('🧑‍🌾', 0, 0); }
      c.restore(); c.textAlign = 'left';
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
      drawGnome(c, t, k);
      if (state === 'ready') {
        guide(c, k);
        if (drag) {
          c.setLineDash([4, 3]); c.strokeStyle = k.accent; c.lineWidth = 2;   // the sling is gold thread
          c.beginPath(); c.moveTo(sn(drag.sx), sn(drag.sy)); c.lineTo(sn(drag.cx), sn(drag.cy)); c.stroke(); c.setLineDash([]);
          c.fillStyle = k.ink; c.fillRect(sn(drag.cx) - 4, sn(drag.cy) - 4, 8, 8); c.fillStyle = k.danger; c.fillRect(sn(drag.cx) - 3, sn(drag.cy) - 3, 6, 6);
          // power pips over the gnome
          var gx0 = 6, on = Math.round(power / 10);
          for (var pp = 0; pp < 10; pp++) { c.fillStyle = k.ink; c.fillRect(gx0 + pp * 5, GY - 50, 5, 6); c.fillStyle = pp < on ? (pp > 7 ? k.danger : k.accent) : k.line; c.fillRect(gx0 + pp * 5 + 1, GY - 49, 3, 4); }
          pxText(c, angle + '°  ' + power + '%', clamp(drag.cx + 10, 4, W - 80), clamp(drag.cy - 10, 14, H - 4), k.ink, 12);
        } else {
          pxText(c, '← drag back, then let go', 70, 30, k.muted, 12);
        }
      }
      if (fly) {
        var el = (t - fly.t0) / 1000, idx = Math.max(0, el * RATE), pts = fly.pts, n = pts.length, cur, i2;
        var upto = Math.min(n - 1, Math.floor(idx));
        for (i2 = fly.seen + 1; i2 <= upto; i2++) {   // bounces and the landing kick up dust
          var pt = pts[i2], prev = pts[i2 - 1], nxt = pts[i2 + 1];
          if (i2 === n - 1 || (pt[1] < 3 && prev && prev[1] > pt[1] && nxt && nxt[1] > pt[1])) puff(X0 + pt[0] * PXCM, GY - 1, i2 === n - 1 ? 12 : 7, i2 % 2 ? k.ground : k.grass, true);
        }
        fly.seen = Math.max(fly.seen, upto);
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
        // follow camera: keeps the seed about 60% across so long spits never leave the field
        var want = Math.max(0, X0 + cur[0] * PXCM - W * 0.6);
        cam += (want - cam) * Math.min(1, 6 * dt);
        // shadow on the grass, smaller the higher the seed is
        var sh = Math.max(2, Math.round(10 / (1 + cur[1] / 25)));
        c.fillStyle = 'rgba(42,26,16,.35)'; c.fillRect(sn(px(cur[0])) - (sh >> 1), GY + 1, sh, 2);
        // the seed: dark with a cream edge, tumbling
        c.save(); c.translate(sn(px(cur[0])), sn(py(cur[1])) - 3); c.rotate(el * 14);
        c.fillStyle = '#f6efd8'; c.fillRect(-4, -3, 8, 6); c.fillStyle = '#2b2118'; c.fillRect(-3, -2, 6, 4); c.fillStyle = '#7a5a30'; c.fillRect(-2, -2, 2, 1);
        c.restore();
        var shown = idx >= n - 1 ? fly.mm / 10 : Math.max(0, cur[0]);
        var pop = landAt ? Math.max(0, 1 - (t - landAt) / 260) : 0;
        pxText(c, shown.toFixed(1) + ' cm', 14, 30 + Math.round(pop * -4), pop ? k.accent : k.ink, 20 + Math.round(pop * 6));
        if (idx >= n - 1) {
          if (!landAt) { landAt = t; }
          var fxp = sx(fly.mm / 10), ft = (t - landAt) / 1000, drop = Math.max(0, 1 - ft / 0.22) * 36, bnc = ft > 0.22 && ft < 0.4 ? Math.round(Math.sin((ft - 0.22) / 0.18 * Math.PI) * 4) : 0;
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
    cv.addEventListener('pointerdown', function (ev) {
      if (state !== 'ready' || (ev.button != null && ev.button > 0)) return;
      ev.preventDefault();
      var p = pos(ev);
      drag = { id: ev.pointerId, sx: p[0], sy: p[1], cx: p[0], cy: p[1], len: 0 };
      try { cv.setPointerCapture(ev.pointerId); } catch (e) { /* fine */ }
      if (reduce) RAF(frame);
    });
    cv.addEventListener('pointermove', function (ev) {
      if (!drag || ev.pointerId !== drag.id) return;
      ev.preventDefault(); aim(ev); redraw();
    });
    function up(ev) {
      if (!drag || ev.pointerId !== drag.id) return;
      aim(ev);
      var ok = drag.len >= MINPULL && ev.type === 'pointerup';
      drag = null;
      if (ok) { try { go(); } catch (e) { state = 'fly'; send(); } } else redraw();
    }
    cv.addEventListener('pointerup', up);
    cv.addEventListener('pointercancel', up);
    cv.style.touchAction = 'none';

    /* ---- fire ---- */
    function go() {
      if (state !== 'ready') return;
      state = 'fly';
      form.classList.add('flying');
      angS.value = angle; powS.value = power; sync(true);
      var r = sim(P, angle, power, wind, grit, nim, true);
      var n = r.pts.length;
      kickAt = performance.now(); puff(X0, GY - 22, 6, '#f6efd8', false);   // a puff from the gnome's cheeks
      fly = { pts: r.pts, mm: r.mm, t0: reduce ? performance.now() - 60000 : performance.now(), end: reduce ? 1 : (n / RATE) * 1000 + 800, sent: false, seen: 0 };   // 800 ms hold so the landing and prize show before the page updates
      if (reduce) { cam = Math.max(0, X0 + r.mm / 10 * PXCM - W * 0.6); draw(performance.now() + 5, 0.016); }
      RAF(frame);
      setTimeout(function () { if (state === 'fly' && fly && !fly.sent) { fly.sent = true; send(); } }, fly.end + 2500);   // v1.4.1: watchdog if frames stall
    }
    function send() {
      if (state === 'done') return;
      var wait = (+(P.minms || 1000) + 250) - (Date.now() - born);   // v1.4.1: never fire before the server's minimum (fast taps, reduced motion)
      if (wait > 0) { setTimeout(send, wait); return; }
      state = 'done';
      form.setAttribute('data-fired', '1');
      var b = form.querySelector('button');
      try { if (form.requestSubmit) form.requestSubmit(b || undefined); else form.submit(); } catch (e) { form.submit(); }
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
