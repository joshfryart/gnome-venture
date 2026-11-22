/* Motif module (2.7.56): the ENVIRONMENT's eight pieces (game/includes/data/pf_env.txt), each with its own place (~600 ms) and fire (~1200 ms) effect.
   Approved look: claude/mockups/pf-weather-anim.html (sun, rain, wind, mud; contrast raised as its author flagged: thicker rain and a bigger shield, fewer wind specks
   with one clear gust, a brighter tan rim and bigger drips for mud). Bramble, Thornburst, Tremor and Spring are new, in the same pixel-square style.
   Registered with PFA.env(kind, { ps(dt, A) place motion of the piece, pl(c, A, dt) place effect, fi(c, A, f) fire effect }). The engine (tools/pfanim_part.js) clips
   everything to the board (+ its knob margin), runs it under the resolve effects, scales time with the step, and plays: Full = place motion + place effect + fire effect,
   Light = the place motion only, Off = nothing. Every draw is a stateless function of time (hash noise only); particles go through A.put (the MAXG glyph budget).
   Purely visual: a Wind push or a Tremor fall is shown as an afterimage / shake of the piece; nothing here changes the board or the rules. */
(function () {
  function cl(u) { return Math.min(1, Math.max(0, u)); }
  function eio(u) { u = cl(u); return u * u * (3 - 2 * u); }
  function bell(u) { return Math.sin(Math.PI * cl(u)); }
  var DITH = {};   // 2 px checker patterns per colour (one fill instead of hundreds of squares); plain translucent fill when no canvas can be made
  function dith(c, x, y, w, h, col, a) {
    if (w <= 0 || h <= 0 || a <= 0) return;
    var p = DITH[col];
    if (p === undefined) { p = null; try { var t = document.createElement('canvas'); t.width = t.height = 4; var q = t.getContext('2d'); q.fillStyle = col; q.fillRect(0, 0, 2, 2); q.fillRect(2, 2, 2, 2); p = c.createPattern(t, 'repeat'); } catch (e) { p = null; } DITH[col] = p; }
    c.globalAlpha = cl(a); c.fillStyle = p || col; if (!p) c.globalAlpha = cl(a) * .5;
    c.fillRect(Math.round(x), Math.round(y), Math.round(w), Math.round(h)); c.globalAlpha = 1;
  }
  function ell(c, A, cx, cy, rx, ry, col) { for (var y = -ry; y <= ry; y += 2) { var hw = Math.round(rx * Math.sqrt(Math.max(0, 1 - (y / ry) * (y / ry))) / 2) * 2; if (hw > 0) A.put(c, cx - hw, cy + y, hw * 2, 2, col); } }
  function frame(c, A, cx, cy, g, col, lw) { c.strokeStyle = col; c.lineWidth = lw || 2; c.strokeRect(Math.round(cx - A.BW / 2 - g), Math.round(cy - A.BH / 2 - g), A.BW + 2 * g, A.BH + 2 * g); }
  function sq(c, A, x, y, w, col) { return A.put(c, x - w / 2, y - w / 2, w, w, col); }
  function sparkle(c, A, x, y, r, col) { A.put(c, x - 1, y - r, 2, 2 * r + 1, col); A.put(c, x - r, y - 1, 2 * r + 1, 2, col); }
  function tgc(A) { return A.tg ? [A.cxOf(A.tg.x), A.cyOf(A.tg.y)] : null; }
  var DIR = { R: [1, 0], L: [-1, 0], T: [0, -1], B: [0, 1] };

  /* ---------- place motion (stateless): raise, click, settle; heavy = mud and quake, lean = wind (away from its arrow) ---------- */
  function placeMo(heavy, lean) {
    return function (dt, A) {
      var o = { s: 1, q: 0, x: 0, y: 0, r: 0, sh: 0, a: 1, hit: 0 }, u, d = lean ? (DIR[A.dir] || DIR.R) : null, lr = d ? -(d[0] || d[1] * .4) : 0;
      if (dt < 0) { o.a = 0; return o; }
      if (dt < 220) { u = eo(dt / 220); o.s = (heavy ? .86 : .90) + (heavy ? .30 : .22) * u; o.y = -(heavy ? 6 : 4) * u; o.sh = u; o.a = Math.min(1, dt / 70); o.r = .09 * lr * u; }
      else if (dt < 280) { u = (dt - 220) / 60; o.s = (heavy ? 1.16 : 1.12) - (heavy ? .20 : .16) * u; o.y = -(heavy ? 6 : 4) * (1 - u); o.sh = 1 - u; o.hit = 1; o.r = lr * (.09 * (1 - u) - .03 * u); if (heavy) o.q = .085 * u; }
      else if (dt < 600) { u = (dt - 280) / 320; var dd = Math.pow(1 - u, 1.6), w = Math.sin(u * Math.PI * 3);
        o.s = .96 + .04 * eo(u); o.x = (heavy ? 1 : 1.6) * Math.sin(u * Math.PI * 3 + 1) * dd; o.r = (lean ? .045 : .03) * w * dd; if (heavy) o.q = .085 * dd; o.hit = dt < 320 ? 1 : 0; }
      return o;
    };
  }

  /* ================= SUN: warm pop and four ray clusters; fire: turning rays, a glint sweeps to the chain piece, gold shimmer on it (counts double) ================= */
  PFA.env('sun', { ps: placeMo(false, false),
    pl: function (c, A, dt) {
      if (dt < 200 || dt > 560) return; var u = (dt - 200) / 360, cx = A.cx, cy = A.cy, k;
      c.globalAlpha = 1 - u;
      [[-1, -1], [1, -1], [-1, 1], [1, 1]].forEach(function (q) { for (k = 0; k < 3; k++) sq(c, A, cx + q[0] * (30 + 5 * k + 12 * eo(u)), cy + q[1] * (25 + 4 * k + 10 * eo(u)), k ? 3 : 4, k === 0 ? '#fff3a0' : '#ffc23a'); });
      frame(c, A, cx, cy, 2 + 10 * eo(u), '#ffd24a', 2); c.globalAlpha = 1;
    },
    fi: function (c, A, f) {
      var cx = A.cx, cy = A.cy, env = bell(f / 1200), k, j, T = tgc(A);
      c.save(); A.clipOut(c, A.tg ? [[A.x, A.y], [A.tg.x, A.tg.y]] : [[A.x, A.y]]); var gr = 8 + 26 * env; dith(c, cx - A.BW / 2 - gr, cy - A.BH / 2 - gr * .8, A.BW + 2 * gr, A.BH + 1.6 * gr, '#ffb52e', .5 * env); c.restore();
      var n = Math.round(5 * Math.min(1, env * 1.6));
      for (k = 0; k < 8; k++) { var ang = k * Math.PI / 4 + f * .0006 + (k % 2) * .08, lg = k % 2 ? 0 : 1;
        for (j = 0; j < n; j++) { var r = 33 + j * 8 + 8 * env + lg * 8; sq(c, A, cx + Math.cos(ang) * r * 1.1, cy + Math.sin(ang) * r * .95, j < 2 ? 4 : 3, j < 2 ? '#fff3a0' : j < 4 ? '#ffc23a' : '#ff9a1e'); } }
      if (!T) return;
      var sw = cl((f - 120) / 560), dx = T[0] - cx, dy = T[1] - cy, hz = Math.abs(dx) >= Math.abs(dy), sx = dx > 0 ? 1 : -1, sy = dy > 0 ? 1 : -1;
      if (sw > 0 && sw < 1) { var bx = cx + dx * eio(sw), by = cy + dy * eio(sw);
        for (k = 0; k < 4; k++) for (j = -4; j <= 4; j++) { var col = k === 0 ? '#fffbe0' : k < 3 ? '#ffd24a' : '#e8a317';
          if (hz) sq(c, A, bx - sx * k * 5 + j * 1.5 * sx, by + j * 6, k === 0 ? 3 : 2, col); else sq(c, A, bx + j * 6, by - sy * k * 5 + j * 1.5 * sy, k === 0 ? 3 : 2, col); } }
      var tl = f - 560;
      if (tl > 0 && tl < 640) { var pu = Math.max(0, Math.sin(tl / 320 * Math.PI * 2 - .3)) * (1 - cl((tl - 460) / 180));
        dith(c, T[0] - A.BW / 2, T[1] - A.BH / 2, A.BW, A.BH, '#ffe27a', .6 * pu); c.globalAlpha = pu; frame(c, A, T[0], T[1], -1, '#ffe27a', 2); c.globalAlpha = 1;
        for (k = 0; k < 5; k++) { var u = cl((tl - k * 70) / 260); if (u <= 0 || u >= 1) continue; sparkle(c, A, T[0] - 22 + hash(k + 20) * 44, T[1] - 18 + hash(k + 30) * 36, 1 + Math.round(3 * Math.sin(Math.PI * u)), '#fffbe0'); } }
    } });

  /* ================= RAIN: drops fall on and splash; fire: thick streaks through the 3x3 cells around it, a big pixel shield rises (guard) ================= */
  function shield(c, A, x, y, a) {   // 4 px squares, 28 x 32, outlined dark blue: x, y = top left
    var rows = [7, 7, 7, 7, 7, 5, 3, 1], k, q = 4; c.globalAlpha = cl(a);
    for (k = 0; k < rows.length; k++) A.put(c, x + (7 - rows[k]) * q / 2 - 2, y + k * q - 2, rows[k] * q + 4, q + 2, '#0f2c4d');
    for (k = 0; k < rows.length; k++) A.put(c, x + (7 - rows[k]) * q / 2, y + k * q, rows[k] * q, q, k < 2 ? '#9fd4fa' : '#5aa6e6');
    A.put(c, x + 12, y + 4, 4, 16, '#ffffff'); A.put(c, x + 6, y + 8, 16, 4, '#ffffff'); c.globalAlpha = 1;
  }
  PFA.env('rain', { ps: placeMo(false, false),
    pl: function (c, A, dt) {
      var cx = A.cx, cy = A.cy, k, u;
      if (dt < 230) for (k = 0; k < 6; k++) { var ph = dt / 230 + k * .13; if (ph > 1.05) continue; var x = cx - 22 + k * 9 + (hash(k) - .5) * 4, y = cy - 52 + (ph % 1) * 36; A.put(c, x, y, 3, 8, '#8cc8f0'); A.put(c, x, y + 8, 3, 3, '#ffffff'); }
      if (dt > 220 && dt < 480) { u = (dt - 220) / 260; c.globalAlpha = 1 - u;
        for (k = 0; k < 7; k++) { var sd = k % 2 ? 1 : -1, off = (k >> 1) * 8 + 4; sq(c, A, cx + sd * (off + 10 * eo(u)), cy - A.BH / 2 - 3 - 8 * Math.sin(Math.PI * u), 4, k % 3 ? '#8cc8f0' : '#ffffff'); } c.globalAlpha = 1; }
    },
    fi: function (c, A, f) {
      var x0 = A.PAD + (A.x - 1) * A.BW, y0 = A.PAD + (A.y - 1) * A.BH, rw = 3 * A.BW, rh = 3 * A.BH, i, n = 16, T = tgc(A);
      for (i = 0; i < n; i++) {
        var st = hash(i + 3) * 240, en = 1170 - hash(i + 7) * 140; if (f < st || f > en) continue;
        var PER = 330 + hash(i + 11) * 120, fr = (((f - st) + hash(i) * PER) % PER) / PER, x = x0 + 4 + i * (rw - 8) / n, y = y0 + fr * (rh + 14) - 14;
        if (y + 13 <= y0 + rh) { var yt = Math.max(y0, y); A.put(c, x - 1, yt, 5, Math.max(1, y + 13 - yt), '#1d4f7a'); A.put(c, x, yt, 3, Math.max(1, y + 13 - yt), '#8cc8f0'); if (y + 9 >= yt) A.put(c, x, y + 9, 3, 4, '#ffffff'); }
        else { var u = cl((y - (y0 + rh - 13)) / 14); if (u < 1) { var sp = 2 + 7 * u, sy = y0 + rh - 4 - 6 * Math.sin(Math.PI * u); sq(c, A, x - sp, sy, 4, '#cfe8fa'); sq(c, A, x + 3 + sp, sy, 4, '#8cc8f0'); } }
      }
      var su = cl((f - 300) / 600), top = A.PAD - 11;
      if (su > 0) shield(c, A, A.cx - 14, Math.max(top, A.cy - 12 - 24 * eo(su)), Math.min(1, su * 3) * (1 - cl((f - 1050) / 150)));
      if (T && f > 500 && f < 1100) { c.globalAlpha = bell((f - 500) / 600); frame(c, A, T[0], T[1], 1, '#0f2c4d', 5); frame(c, A, T[0], T[1], 1, '#6fb8f0', 3); c.globalAlpha = 1; }
    } });

  /* ================= WIND: leans back, dust blows off; fire: one clear gust in the arrow's direction, a few leaves; the pushed piece leaves an afterimage trail ================= */
  function gustFrame(c, A, cx, cy, d) { c.translate(Math.round(cx), Math.round(cy)); if (d[0] < 0) c.rotate(Math.PI); else if (d[1] > 0) c.rotate(Math.PI / 2); else if (d[1] < 0) c.rotate(-Math.PI / 2); }
  PFA.env('wind', { ps: placeMo(false, true),
    pl: function (c, A, dt) {
      if (dt < 180 || dt > 600) return; var u = (dt - 180) / 420, d = DIR[A.dir] || DIR.R, k, sd;
      c.save(); gustFrame(c, A, A.cx, A.cy, d); c.globalAlpha = 1 - u;
      for (k = 0; k < 6; k++) { sd = k % 2 ? 1 : -1; sq(c, A, 24 + (16 + hash(k + 4) * 22) * eo(u), sd * (6 + hash(k + 9) * 14) - 4 * u, k % 3 ? 3 : 4, k % 3 ? '#f4efdc' : '#c9b48a'); }
      for (k = 0; k < 2; k++) { A.put(c, 30 + 8 * eo(u), -7 + k * 12, 14 + 8 * eo(u), 3, '#2c3e66'); A.put(c, 30 + 8 * eo(u), -8 + k * 12, 14 + 8 * eo(u), 2, '#f4efdc'); }
      c.restore();
    },
    fi: function (c, A, f) {
      var d = DIR[A.dir] || DIR.R, hz = d[1] === 0, k, mv = A.mv;
      var reach = hz ? (d[0] > 0 ? (A.w - A.x - .5) : (A.x + .5)) * A.BW : (d[1] > 0 ? (A.h - A.y - .5) : (A.y + .5)) * A.BH, across = (hz ? A.BH : A.BW) * .9;
      if (mv) {   // the pushed piece: dashed outline where it lands, its afterimages from the old cell, dust left behind
        var dx = A.PAD + mv.tx * A.BW, dy = A.PAD + mv.ty * A.BH, oa = f < 360 ? cl((f - 60) / 200) : 1 - cl((f - 700) / 200);
        if (oa > 0) { c.globalAlpha = oa; for (k = 0; k < A.BW; k += 8) { A.put(c, dx + k, dy + 1, 4, 2, '#ffe27a'); A.put(c, dx + k, dy + A.BH - 3, 4, 2, '#ffe27a'); } for (k = 0; k < A.BH; k += 8) { A.put(c, dx + 1, dy + k, 2, 4, '#ffe27a'); A.put(c, dx + A.BW - 3, dy + k, 2, 4, '#ffe27a'); } c.globalAlpha = 1; }
        var fx = A.cxOf(mv.fx), fy = A.cyOf(mv.fy), tx = A.cxOf(mv.tx), ty = A.cyOf(mv.ty);
        for (k = 3; k >= 0; k--) { var g = eio((f - 40 - k * 70) / 520); if (g > .02 && g < .97) A.ghost(c, mv.id, fx + (tx - fx) * g, fy + (ty - fy) * g, (.5 - .1 * k) * (1 - cl((f - 800) / 200))); }
        var du = cl((f - 120) / 600); if (du > 0 && du < 1) { c.globalAlpha = 1 - du; for (k = 0; k < 5; k++) sq(c, A, fx + (k - 2) * 7 + d[0] * du * 8, fy + A.BH / 2 - 6 - du * 8 - hash(k) * 8 + d[1] * du * 8, 3, '#c9b48a'); c.globalAlpha = 1; }
      }
      c.save(); gustFrame(c, A, A.cx, A.cy, d);
      var lanes = [-.55, 0, .55], L0 = A.BW * .45;   // one clear gust: three thick lanes moving together, white with a dark underside, a curl at the head
      for (k = 0; k < 3; k++) {
        var ph = cl((f - 40 - k * 50) / 760), head = L0 + ph * (reach + 40), len = 30 + 26 * bell(ph), tail = Math.max(L0 - 6, head - len), y = Math.round(lanes[k] * across * .8), a = 1 - cl((ph - .85) / .15);
        if (head - tail < 2 || a <= 0) continue; c.globalAlpha = a;
        A.put(c, tail, y + 3, head - tail, 2, '#2c3e66'); A.put(c, tail, y - 1, head - tail, 4, '#ffffff'); A.put(c, tail - 8, y, 6, 2, '#dfe9f6');
        if (k !== 1) { A.put(c, head - 4, y - 5 * (k ? 1 : -1) * -1 - 2, 6, 3, '#ffffff'); A.put(c, head + 1, y - 7 * (k ? 1 : -1) * -1 - 2, 3, 3, '#dfe9f6'); }
        else { A.put(c, head, y - 4, 4, 3, '#ffffff'); A.put(c, head + 3, y - 7, 3, 3, '#ffffff'); }
      }
      for (k = 0; k < 5; k++) { var p2 = cl((f - 80 - hash(k + 40) * 300) / 700); if (p2 <= 0 || p2 >= 1) continue; c.globalAlpha = 1 - cl((p2 - .8) / .2);   // a few leaves and specks
        var x2 = L0 + p2 * reach, y2 = (hash(k + 50) - .5) * across * 1.6 + Math.sin(p2 * 9 + k) * 5;
        if (k % 2 === 0) { A.put(c, x2, y2, 7, 4, '#3f6a22'); A.put(c, x2 + 1, y2, 5, 3, '#a8d45a'); A.put(c, x2 + 4, y2 - 3, 3, 3, '#6f9a3a'); } else A.put(c, x2, y2, 4, 4, '#f4efdc'); }
      c.restore();
      if (f < 700) A.shake(A.it.id, Math.sin(f / 35) * 1.4 * (1 - f / 700), 0, 0);
    } });

  /* ================= MUD: heavy squash, a splat; fire (a piece next to it fires): a pool spreads, big drips, the piece it weakens gets a dark ring (a quarter less) ================= */
  PFA.env('mud', { ps: placeMo(true, false),
    pl: function (c, A, dt) {
      var cx = A.cx, cy = A.cy, k, u;
      if (dt > 220 && dt < 600) { u = (dt - 220) / 380; c.save(); A.clipOut(c, [[A.x, A.y]]); c.globalAlpha = 1 - cl((dt - 450) / 150);
        ell(c, A, cx, cy + 14, 16 + 22 * eo(u), 7 + 5 * eo(u), '#e0b070'); ell(c, A, cx, cy + 14, 13 + 22 * eo(u), 5 + 5 * eo(u), '#3a2210'); c.restore(); }
      if (dt > 220 && dt < 560) { u = (dt - 220) / 340; c.globalAlpha = 1 - u * u;
        for (k = 0; k < 8; k++) { var mx = cx + (k - 3.5) * 8 * (1 + eo(u)), my = cy + 6 - Math.sin(Math.PI * u) * (14 + hash(k + 2) * 10) + 14 * u; sq(c, A, mx, my, k % 3 ? 6 : 5, '#e0b070'); sq(c, A, mx, my, k % 3 ? 4 : 3, '#5a3418'); } c.globalAlpha = 1; }
    },
    fi: function (c, A, f) {
      var cx = A.cx, cy = A.cy, k, e = eo(f / 650), fade = 1 - cl((f - 1000) / 200), T = tgc(A), out = [[A.x, A.y]];
      if (A.tg) out.push([A.tg.x, A.tg.y]);
      c.save(); A.clipOut(c, out); c.globalAlpha = fade; var rx = 16 + 46 * e, ry = 10 + 26 * e;
      ell(c, A, cx, cy + 6, rx + 3, ry + 3, '#e0b070'); ell(c, A, cx, cy + 6, rx, ry, '#3a2210');
      for (k = 0; k < 6; k++) sq(c, A, cx + (hash(k + 60) - .5) * rx * 1.5, cy + 6 + (hash(k + 70) - .5) * ry * 1.4, 3, '#8a5a30'); c.restore();
      c.globalAlpha = fade;
      for (k = 0; k < 4; k++) { var u = cl((f - k * 120) / 420); if (u <= 0) continue; var x = cx - 18 + k * 12, y0 = cy + A.BH / 2 - 2;   // big drips off its bottom edge
        if (u < .75) { var y = y0 + 1 + 14 * (u / .75) * (u / .75); A.put(c, x - 4, y, 8, 9, '#1a0e06'); A.put(c, x - 3, y + 9, 6, 2, '#1a0e06'); A.put(c, x - 3, y + 1, 6, 8, '#b07a44'); A.put(c, x - 2, y + 9, 4, 1, '#b07a44'); A.put(c, x - 2, y + 2, 2, 3, '#f0c890'); }
        else { var v = (u - .75) / .25; ell(c, A, x, y0 + 20, 5 + 5 * v, 2, '#e0b070'); ell(c, A, x, y0 + 20, 4 + 5 * v, 1, '#3a2210'); } }
      c.globalAlpha = 1;
      if (!T) return;
      var ra = cl((f - 330) / 220) * fade, x0 = Math.round(T[0] - A.BW / 2), y1 = Math.round(T[1] - A.BH / 2);
      if (ra <= 0) return;
      dith(c, x0, y1, A.BW, A.BH, '#180c06', .7 * ra); c.globalAlpha = ra; frame(c, A, T[0], T[1], 1, '#1a0e06', 3); frame(c, A, T[0], T[1], 4, '#e0b070', 2); c.globalAlpha = 1;
      for (k = 0; k < 3; k++) { var u2 = cl((f - 420 - k * 120) / 420); if (u2 <= 0 || u2 >= 1) continue; c.globalAlpha = bell(u2) * ra;   // three down-arrows: it counts less
        var yy = T[1] - 10 + 22 * u2, xx = T[0] - 12 + k * 12; A.put(c, xx - 1, yy, 3, 5, '#ffd27a'); A.put(c, xx - 4, yy + 5, 9, 2, '#ffd27a'); A.put(c, xx - 2, yy + 7, 5, 2, '#ffd27a'); A.put(c, xx, yy + 9, 1, 1, '#ffd27a'); c.globalAlpha = 1; }
    } });

  /* ================= BRAMBLE: shoots sprout at its corners; fire: prickly vines creep along its edge toward the chain piece and prick it
     (yours: gold pricks, the creature's Yield bar fills a tenth; the creature's chain: red pricks, you lose a tenth of your health) ================= */
  function edgePt(A, cx, cy, s) {   // walk a cell's border clockwise from the top-left corner, s in px (0..2BW+2BH): [x, y, outward nx, ny]
    var W = A.BW, H = A.BH, L = 2 * W + 2 * H, x0 = cx - W / 2, y0 = cy - H / 2; s = ((s % L) + L) % L;
    if (s < W) return [x0 + s, y0, 0, -1]; s -= W; if (s < H) return [x0 + W, y0 + s, 1, 0]; s -= H; if (s < W) return [x0 + W - s, y0 + H, 0, 1]; s -= W; return [x0, y0 + H - s, -1, 0];
  }
  PFA.env('bramble', { ps: placeMo(false, false),
    pl: function (c, A, dt) {
      if (dt < 200) return; var u = cl((dt - 200) / 300), a = 1 - cl((dt - 480) / 120), cx = A.cx, cy = A.cy, k, j;
      c.globalAlpha = a;
      for (k = 0; k < 4; k++) { var sx = k % 2 ? 1 : -1, sy = k < 2 ? 1 : -1, n = Math.round(6 * eo(u));   // a short curling shoot out of each corner
        for (j = 0; j < n; j++) { var x = cx + sx * (A.BW / 2 + j * 2), y = cy + sy * (A.BH / 2 - j * 3 + (j > 3 ? (j - 3) * 3 : 0)); A.put(c, x - 2, y - 2, 5, 5, '#1f3d12'); A.put(c, x - 1, y - 1, 3, 3, '#7cc04a');
          if (j === 3 || j === 5) { A.put(c, x + sx * 4 - 1, y - 3, 3, 3, '#f2e4c0'); } } }
      c.globalAlpha = 1;
    },
    fi: function (c, A, f) {
      var T = tgc(A), cx = A.cx, cy = A.cy, W = A.BW, H = A.BH, L = 2 * W + 2 * H, k, s0 = 0, me = A.fr === 'me';
      if (T) { var dx = T[0] - cx, dy = T[1] - cy; s0 = Math.abs(dx) >= Math.abs(dy) ? (dx > 0 ? W + H / 2 : 2 * W + H + H / 2) : (dy > 0 ? W + H + W / 2 : W / 2); }   // the vines meet on the side facing the chain piece
      var grow = eio(f / 620) * L / 2, fade = 1 - cl((f - 1050) / 150), N = 0;
      c.globalAlpha = fade;
      for (k = 0; k < 2; k++) {   // two vines from the far side, one each way round, meeting at s0
        var from = s0 + L / 2, sg = k ? 1 : -1, s, st = 3;
        for (s = 0; s < grow; s += st) { var q = edgePt(A, cx, cy, from + sg * s), wob = Math.round(Math.sin((s + k * 9) * .35) * 2);
          A.put(c, q[0] - 3 + q[2] * (wob + 2), q[1] - 3 + q[3] * (wob + 2), 6, 6, '#1f3d12'); A.put(c, q[0] - 1 + q[2] * (wob + 2), q[1] - 1 + q[3] * (wob + 2), 3, 3, '#8fd456');
          if (Math.round(s / st) % 4 === 2 && N++ < 16) { A.put(c, q[0] + q[2] * 7 - 2, q[1] + q[3] * 7 - 2, 4, 4, '#1f3d12'); A.put(c, q[0] + q[2] * 10 - 1, q[1] + q[3] * 10 - 1, 3, 3, '#f2e4c0'); } } }
      c.globalAlpha = 1;
      if (!T) return;
      var pr = f - 640; if (pr < 0 || pr > 520) return;   // the prick: thorns jab into the chain piece's facing edge, a flash on it
      var hx = (T[0] + cx) / 2, hy = (T[1] + cy) / 2, hz = Math.abs(T[0] - cx) >= Math.abs(T[1] - cy), dirv = hz ? (T[0] > cx ? 1 : -1) : (T[1] > cy ? 1 : -1), col = me ? '#ffd24a' : '#ff4a3a', u = cl(pr / 160);
      dith(c, T[0] - W / 2, T[1] - H / 2, W, H, me ? '#ffd24a' : '#ff3a2a', .5 * bell(pr / 520)); c.globalAlpha = bell(pr / 520); frame(c, A, T[0], T[1], -1, col, 2); c.globalAlpha = 1;
      for (k = 0; k < 4; k++) { var o = (k - 1.5) * (hz ? 10 : 12), dep = 4 + 8 * u * (k % 2 ? .8 : 1);
        if (hz) { A.put(c, hx, hy + o - 1, dirv * dep, 3, '#1f3d12'); A.put(c, hx + dirv * dep - (dirv > 0 ? 2 : 0), hy + o - 1, 2, 3, '#f2e4c0'); }
        else { A.put(c, hx + o - 1, hy, 3, dirv * dep, '#1f3d12'); A.put(c, hx + o - 1, hy + dirv * dep - (dirv > 0 ? 2 : 0), 3, 2, '#f2e4c0'); } }
      for (k = 0; k < 4; k++) { var v = cl((pr - 80 - k * 50) / 240); if (v <= 0 || v >= 1) continue; sparkle(c, A, T[0] - 16 + hash(k + A.seed) * 32, T[1] - 14 + hash(k + 7 + A.seed) * 28, 1 + Math.round(3 * bell(v)), col); }
    } });

  /* ================= THORNBURST: thorns poke out; fire: a radial burst of thorns and a red flash (whoever fires it loses a tenth of its health) ================= */
  PFA.env('thorn', { ps: placeMo(false, false),
    pl: function (c, A, dt) {
      if (dt < 220 || dt > 560) return; var u = (dt - 220) / 340, k, a = bell(u);
      c.globalAlpha = Math.min(1, a * 1.5);
      for (k = 0; k < 8; k++) { var an = k * Math.PI / 4 + Math.PI / 8, r0 = 26, r = r0 + 9 * a, x = A.cx + Math.cos(an) * r * 1.1, y = A.cy + Math.sin(an) * r * .95;
        sq(c, A, x, y, 5, '#5a1a0a'); sq(c, A, x, y, 3, '#d8a060'); sq(c, A, x + Math.cos(an) * 4, y + Math.sin(an) * 4, 3, '#fff0dc'); }
      c.globalAlpha = 1;
    },
    fi: function (c, A, f) {
      var cx = A.cx, cy = A.cy, k, j, T = tgc(A), fl = bell((f - 120) / 420);
      if (fl > 0) { dith(c, cx - A.BW / 2, cy - A.BH / 2, A.BW, A.BH, '#ff2a1a', .85 * fl); if (T) dith(c, T[0] - A.BW / 2, T[1] - A.BH / 2, A.BW, A.BH, '#ff2a1a', .6 * fl);
        c.globalAlpha = fl; frame(c, A, cx, cy, 1 + 9 * eo((f - 120) / 420), '#5a0a06', 5); frame(c, A, cx, cy, 1 + 9 * eo((f - 120) / 420), '#ff5a3a', 3); c.globalAlpha = 1; }
      for (k = 0; k < 12; k++) {   // thorns fly out: dark shaft, pale point, fading after ~0.9 s
        var an = k * Math.PI / 6 + (A.seed % 7) * .05, u = cl((f - 60 - (k % 3) * 30) / 700), r = 18 + 58 * eo(u), a = 1 - cl((u - .7) / .3); if (u <= 0 || a <= 0) continue;
        c.globalAlpha = a; var ca = Math.cos(an), sa = Math.sin(an);
        for (j = 3; j >= 0; j--) { var tx = cx + ca * (r - j * 4) * 1.1, ty = cy + sa * (r - j * 4) * .95; sq(c, A, tx, ty, j ? 5 : 5, '#4a1206'); sq(c, A, tx, ty, 3, j ? '#d8a060' : '#fff0dc'); }
        sq(c, A, cx + ca * (r - 6) * 1.1 - sa * 4, cy + sa * (r - 6) * .95 + ca * 4, 2, '#7a5a2a'); }
      c.globalAlpha = 1;
      var dr = f - 380; if (dr > 0 && dr < 600) for (k = 0; k < 6; k++) { var v = cl((dr - k * 40) / 380); if (v <= 0 || v >= 1) continue;   // red drops: health lost
        var x = cx - 20 + k * 8, y = cy - 6 + 26 * eo(v); c.globalAlpha = 1 - v; A.put(c, x - 2, y - 2, 5, 6, '#5a0a06'); A.put(c, x - 1, y - 1, 3, 4, '#ff4a3a'); c.globalAlpha = 1; }
    } });

  /* ================= TREMOR: drops heavy, the ground cracks; fire: crack lines run out from it, it shakes, the other side's pieces touching it shake and tumble (afterimage + dust) ================= */
  function crack(c, A, cx, cy, ang, len, seed) {   // a zig-zag crack of 3 px squares: dark line with a light lip
    var x = cx, y = cy, st = 5, n = Math.round(len / st), k, dx = Math.cos(ang), dy = Math.sin(ang);
    for (k = 0; k < n; k++) { var jog = (hash(seed + k) - .5) * 5; x += dx * st - dy * jog * .5; y += dy * st + dx * jog * .5;
      A.put(c, x - 2, y - 1, 4, 4, '#140a04'); A.put(c, x - 2, y - 3, 4, 2, '#f0dca8'); }
  }
  PFA.env('quake', { ps: placeMo(true, false),
    pl: function (c, A, dt) {
      if (dt < 230) return; var u = cl((dt - 230) / 250), a = 1 - cl((dt - 470) / 130), k;
      c.globalAlpha = a; c.save(); A.clipOut(c, [[A.x, A.y]]);
      crack(c, A, A.cx - A.BW / 2 + 4, A.cy + A.BH / 2 - 2, Math.PI * .8, 8 + 24 * u, A.seed); crack(c, A, A.cx + A.BW / 2 - 4, A.cy + A.BH / 2 - 2, Math.PI * .2, 8 + 24 * u, A.seed + 9); c.restore();
      for (k = 0; k < 6; k++) sq(c, A, A.cx + (k - 2.5) * 10 * (1 + u), A.cy + A.BH / 2 - 2 - 12 * bell(u) * (.5 + hash(k) * .5), 4, '#f0e0b8');
      c.globalAlpha = 1;
    },
    fi: function (c, A, f) {
      var cx = A.cx, cy = A.cy, k, u = eo(f / 520), fade = 1 - cl((f - 1000) / 200), sh = f < 900 ? (1 - f / 900) : 0;
      c.save(); A.clipOut(c, [[A.x, A.y]].concat(A.falls.map(function (q) { return [q.x, q.y]; }))); c.globalAlpha = fade;
      for (k = 0; k < 6; k++) crack(c, A, cx, cy, k * Math.PI / 3 + .4 + hash(A.seed + k) * .5, 20 + (34 + hash(k + 3) * 30) * u, A.seed + k * 17);
      c.restore(); c.globalAlpha = 1;
      if (sh > 0) A.shake(A.it.id, Math.round(Math.sin(f / 28) * 3 * sh), Math.round(Math.cos(f / 23) * 1.5 * sh), 0);
      A.falls.forEach(function (q, i) {   // a piece that falls off: it shakes hard, slips down as an afterimage, small dust
        var fx = A.cxOf(q.x), fy = A.cyOf(q.y), s2 = f > 150 && f < 1000 ? Math.min(1, (f - 150) / 200) : 0, tu = cl((f - 600 - i * 60) / 500);
        if (s2 > 0) A.shake(q.id, Math.round(Math.sin(f / 22 + i) * 4 * s2), Math.round(Math.cos(f / 19) * 2 * s2), Math.sin(f / 40 + i) * .06 * s2);
        if (tu > 0 && tu < 1) A.ghost(c, q.id, fx + 5 * tu, fy + 22 * tu * tu, .6 * (1 - tu));
        var du = cl((f - 250 - i * 60) / 700); if (du > 0 && du < 1) { c.globalAlpha = 1 - du; for (k = 0; k < 6; k++) sq(c, A, fx + (k - 2.5) * 9 * (1 + du * .6), fy + A.BH / 2 - 4 - (6 + hash(k + i * 5) * 10) * bell(du), k % 2 ? 4 : 5, k % 2 ? '#f0e0b8' : '#c8a870'); c.globalAlpha = 1; }
      });
    } });

  /* ================= SPRING: water wells up; fire: rising green / white ripples and sparkles, the side that fires it heals (a tenth) ================= */
  function rip(c, A, cx, cy, rx, ry, col, a, seed) {   // a stippled ellipse ring of 2 px squares
    var n = Math.min(28, Math.max(10, Math.round(rx * .9))), k; c.globalAlpha = cl(a);
    for (k = 0; k < n; k++) { if (hash(seed + k) < .18) continue; var an = k * Math.PI * 2 / n; A.put(c, cx + Math.cos(an) * rx - 2, cy + Math.sin(an) * ry - 1, 4, 3, col); }
    c.globalAlpha = 1;
  }
  PFA.env('spring', { ps: placeMo(false, false),
    pl: function (c, A, dt) {
      if (dt < 220) return; var u = cl((dt - 220) / 360), k;
      rip(c, A, A.cx, A.cy + 10, 14 + 22 * eo(u), 5 + 9 * eo(u), '#0e4a2c', 1 - u, A.seed); rip(c, A, A.cx, A.cy + 8, 14 + 22 * eo(u), 5 + 9 * eo(u), '#bff5d8', 1 - u, A.seed);
      for (k = 0; k < 5; k++) { var v = cl(u * 1.4 - k * .1); if (v <= 0 || v >= 1) continue; c.globalAlpha = 1 - v; sq(c, A, A.cx - 16 + k * 8, A.cy + 8 - 26 * eo(v), 4, k % 2 ? '#ffffff' : '#7ee0a8'); }
      c.globalAlpha = 1;
    },
    fi: function (c, A, f) {
      var cx = A.cx, cy = A.cy, k, T = tgc(A), fade = 1 - cl((f - 1000) / 200);
      for (k = 0; k < 3; k++) { var u = cl((f - k * 220) / 700); if (u <= 0 || u >= 1) continue;   // ripples rise and widen
        var ry = 6 + 14 * eo(u), rx = 14 + 34 * eo(u), y = cy + 12 - 22 * eo(u), a = (1 - u) * fade;
        rip(c, A, cx, y + 2, rx, ry, '#0e4a2c', a, A.seed + k * 31); rip(c, A, cx, y, rx, ry, k === 1 ? '#ffffff' : '#a8f0c8', a, A.seed + k * 31); }
      for (k = 0; k < 8; k++) { var v = cl((f - 120 - k * 80) / 520); if (v <= 0 || v >= 1) continue;   // droplets jump and sparkle
        var x = cx - 20 + hash(k + A.seed) * 40, y2 = cy + 10 - 40 * Math.sin(Math.PI * v * .9) * (.6 + hash(k + 5) * .4); c.globalAlpha = fade * (1 - cl((v - .8) / .2));
        if (k % 3 === 0) sparkle(c, A, x, y2, 3, '#ffffff'); else { A.put(c, x - 2, y2 - 2, 4, 4, '#0e4a2c'); A.put(c, x - 1, y2 - 1, 3, 3, k % 2 ? '#bff5d8' : '#7ee0a8'); } }
      c.globalAlpha = 1;
      var H = T || [cx, cy], hu = f - 520;   // the heal: a green glow and rising plus signs on the chain piece (or on itself)
      if (hu > 0 && hu < 640) { var hb = bell(hu / 640); dith(c, H[0] - A.BW / 2, H[1] - A.BH / 2, A.BW, A.BH, '#d8ffe8', .55 * hb); c.globalAlpha = hb; frame(c, A, H[0], H[1], -1, '#bff5d8', 2); c.globalAlpha = 1;
        for (k = 0; k < 3; k++) { var w = cl((hu - k * 110) / 420); if (w <= 0 || w >= 1) continue; var px = H[0] - 14 + k * 14, py = H[1] + 8 - 22 * eo(w); c.globalAlpha = bell(w);
          A.put(c, px - 4, py - 1, 9, 3, '#0e4a2c'); A.put(c, px - 1, py - 4, 3, 9, '#0e4a2c'); A.put(c, px - 3, py, 7, 1, '#ffffff'); A.put(c, px, py - 3, 1, 7, '#ffffff'); c.globalAlpha = 1; } }
    } });
})();
