/* Gnome Venture v1.4.0: Seed Spitting. Vanilla JS, no libraries.
   The server makes the round (wind, token, start time) and works the distance out itself from the angle and power you hand in.
   This file only draws the field, lets you drag a slingshot (or use the sliders), and animates the flight with the SAME steps as
   spit_sim() in includes/games.php (constants come from the page's data-phys), so what you see matches what is scored. */
(function () {
  'use strict';
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
    cv.width = W; cv.height = H; cv.className = 'spitcv';
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
        sky0: dark ? '#14233a' : '#cfe6f7', sky1: dark ? '#22403a' : '#eef6e6', hill: dark ? '#1f3a2a' : '#b9d6a0',
        ground: dark ? '#4a3a26' : '#8a6a42', grass: dark ? '#2f6a3c' : '#6fae4a', seed: dark ? '#f1e6c8' : '#2b2118' };
      palAt = now;
      return pal;
    }
    function px(cm) { return X0 + cm * PXCM; }
    function py(cm) { return GY - cm * PXCM; }

    function sync(fromSliders) {
      angle = Math.round(clamp(angle, P.amin, P.amax)); power = Math.round(clamp(power, 0, 100));
      if (!fromSliders) { angS.value = angle; powS.value = power; }
      if (outs[0]) outs[0].textContent = angle + '°';
      if (outs[1]) outs[1].textContent = power + '%';
    }
    sync(true);
    angS.addEventListener('input', function () { if (state !== 'ready') return; angle = +angS.value; power = +powS.value; sync(true); });
    powS.addEventListener('input', function () { if (state !== 'ready') return; angle = +angS.value; power = +powS.value; sync(true); });

    /* ---- drawing ---- */
    function drawWind(c, t) {
      var fx = W - 46, fy = 58, len = 6 + 34 * Math.min(1, Math.abs(wind) / wmax), dir = wind >= 0 ? 1 : -1;
      c.strokeStyle = c.fillStyle = c.__ink;
      c.lineWidth = 2; c.beginPath(); c.moveTo(fx, fy + 30); c.lineTo(fx, fy - 6); c.stroke();
      if (wind === 0) { c.fillStyle = c.__muted; c.font = '11px system-ui, sans-serif'; c.fillText('calm', fx - 10, fy + 44); return; }
      c.fillStyle = gust ? c.__accent : c.__brand;
      c.beginPath(); c.moveTo(fx, fy - 6);
      var seg = 6, amp = 3 + 3 * Math.min(1, Math.abs(wind) / wmax);
      for (var i = 1; i <= seg; i++) c.lineTo(fx + dir * len * i / seg, fy - 6 + amp * Math.sin(t / 160 - i * 0.9) * (i / seg) + 2 * i / seg);
      for (var j = seg; j >= 1; j--) c.lineTo(fx + dir * len * j / seg, fy + 8 + amp * Math.sin(t / 160 - j * 0.9) * (j / seg) - 3 * j / seg + 2);
      c.lineTo(fx, fy + 8); c.closePath(); c.fill();
      // little wind streaks drifting with the wind
      c.strokeStyle = c.__muted; c.globalAlpha = 0.45; c.lineWidth = 1.5;
      for (var s = 0; s < 6; s++) {
        var sp = (Math.abs(wind) / wmax) * 0.06 + 0.02, xx = ((s * 83 + t * sp * dir) % W + W) % W, yy = 24 + (s * 37) % 110;
        c.beginPath(); c.moveTo(xx, yy); c.lineTo(xx + dir * (10 + 14 * Math.abs(wind) / wmax), yy); c.stroke();
      }
      c.globalAlpha = 1;
      c.fillStyle = c.__muted; c.font = '11px system-ui, sans-serif';
      c.fillText(Math.abs(wind) + ' cm/s', fx - 22, fy + 44);
    }
    function guide(c) {
      var p = sim(P, angle, power, wind, grit, nim, true).pts, n = Math.min(p.length, 8 + 5 * nim);
      c.fillStyle = c.__ink;
      for (var i = 1; i < n; i++) { c.globalAlpha = 0.85 - 0.6 * i / n; c.beginPath(); c.arc(px(p[i][0]), py(p[i][1]) - 0, 2.2, 0, 7); c.fill(); }
      c.globalAlpha = 1;
    }
    function draw(t) {
      var c = ctx, k = colors();
      c.__ink = k.ink; c.__muted = k.muted; c.__brand = k.brand; c.__accent = k.accent;
      var gr = c.createLinearGradient(0, 0, 0, GY); gr.addColorStop(0, k.sky0); gr.addColorStop(1, k.sky1);
      c.fillStyle = gr; c.fillRect(0, 0, W, H);
      c.fillStyle = k.hill; c.beginPath(); c.moveTo(0, GY);
      for (var x = 0; x <= W; x += 20) c.lineTo(x, GY - 26 - 14 * Math.sin(x / 55) - 8 * Math.sin(x / 23));
      c.lineTo(W, GY); c.closePath(); c.fill();
      c.fillStyle = k.ground; c.fillRect(0, GY, W, H - GY);
      c.fillStyle = k.grass; c.fillRect(0, GY, W, 6);
      // distance ticks and the prize lines
      c.font = '10px system-ui, sans-serif'; c.textAlign = 'center';
      for (var d = 10; d <= 90; d += 10) {
        var prize = d === 30 || d === 60, X = px(d);
        if (X > W - 4) break;
        c.strokeStyle = k.line; c.lineWidth = 1; c.beginPath(); c.moveTo(X, GY); c.lineTo(X, GY + 6); c.stroke();
        c.fillStyle = k.ink; c.globalAlpha = 0.8; c.fillText(String(d), X, GY + 17); c.globalAlpha = 1;
        if (prize) { c.setLineDash([3, 4]); c.strokeStyle = k.accent; c.beginPath(); c.moveTo(X, GY); c.lineTo(X, GY - 70); c.stroke(); c.setLineDash([]); }
      }
      c.setLineDash([3, 4]); c.strokeStyle = k.accent; c.beginPath(); c.moveTo(px(45), GY); c.lineTo(px(45), GY - 70); c.stroke(); c.setLineDash([]);
      c.fillStyle = k.accent; c.font = 'bold 10px system-ui, sans-serif';
      c.fillText('30', px(30), GY - 73); c.fillText('45', px(45), GY - 73); c.fillText('60', px(60), GY - 73);
      c.fillStyle = k.muted; c.font = '10px system-ui, sans-serif'; c.fillText('cm', W - 12, GY + 17);
      c.textAlign = 'left';
      drawWind(c, t);
      // the gnome
      c.font = '34px system-ui, "Apple Color Emoji", "Segoe UI Emoji", sans-serif'; c.textBaseline = 'alphabetic';
      c.fillText('🧑‍🌾', X0 - 34, GY + 2);
      if (state === 'ready') {
        guide(c);
        if (drag) {
          c.strokeStyle = k.danger; c.lineWidth = 3; c.lineCap = 'round';
          c.beginPath(); c.moveTo(drag.sx, drag.sy); c.lineTo(drag.cx, drag.cy); c.stroke();
          c.fillStyle = k.danger; c.beginPath(); c.arc(drag.cx, drag.cy, 6, 0, 7); c.fill();
          c.fillStyle = k.ink; c.font = 'bold 12px system-ui, sans-serif';
          c.fillText(angle + '° · ' + power + '%', clamp(drag.cx + 10, 4, W - 80), clamp(drag.cy - 10, 14, H - 4));
        } else {
          c.fillStyle = k.muted; c.font = '12px system-ui, sans-serif';
          c.fillText('← drag back, then let go', 70, 30);
        }
      }
      if (fly) {
        var el = (t - fly.t0) / 1000, idx = el * 60, pts = fly.pts, n = pts.length, cur;
        c.fillStyle = k.ink;
        var upto = Math.min(n - 1, Math.floor(idx));
        for (var i = 0; i <= upto; i += 1) { c.globalAlpha = 0.35; c.beginPath(); c.arc(px(pts[i][0]), py(pts[i][1]), 1.6, 0, 7); c.fill(); }
        c.globalAlpha = 1;
        if (idx >= n - 1) cur = pts[n - 1];
        else { var f = idx - Math.floor(idx), a = pts[Math.floor(idx)], b = pts[Math.floor(idx) + 1]; cur = [a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f]; }
        // the seed
        c.save(); c.translate(px(cur[0]), py(cur[1]) - 3); c.rotate(el * 14); c.fillStyle = k.seed;
        c.beginPath(); c.ellipse(0, 0, 4.5, 2.6, 0, 0, 7); c.fill(); c.restore();
        var shown = idx >= n - 1 ? fly.mm / 10 : Math.max(0, cur[0]);
        c.fillStyle = k.ink; c.font = 'bold 20px system-ui, sans-serif';
        c.fillText(shown.toFixed(1) + ' cm', 14, 30);
        if (idx >= n - 1) {
          c.fillStyle = k.accent; c.beginPath(); c.moveTo(px(fly.mm / 10), GY); c.lineTo(px(fly.mm / 10), GY - 26); c.lineTo(px(fly.mm / 10) + 12, GY - 21); c.lineTo(px(fly.mm / 10), GY - 16); c.closePath(); c.fill();
          c.strokeStyle = k.ink; c.lineWidth = 2; c.beginPath(); c.moveTo(px(fly.mm / 10), GY); c.lineTo(px(fly.mm / 10), GY - 26); c.stroke();
        }
      }
    }

    /* ---- the loop ---- */
    var reduce = !!rmq.matches;
    function frame(ts) {
      if (!game.isConnected) return;
      draw(ts);
      if (fly && ts - fly.t0 >= fly.end && !fly.sent) { fly.sent = true; setTimeout(send, reduce ? 100 : 200); }
      if (!reduce || state === 'fly' || drag) RAF(frame);
    }
    function redraw() { if (reduce && state === 'ready' && !drag) draw(performance.now()); }
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
      fly = { pts: r.pts, mm: r.mm, t0: performance.now(), end: reduce ? 1 : (n / 60) * 1000 + 100, sent: false };
      if (reduce) draw(performance.now() + 5);
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
