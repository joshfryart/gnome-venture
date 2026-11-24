/* Motif module (2.7.58): whole-piece effects of the gnome's stat pieces (pfight_statpieces), registered with PFA.stat(name, { dur, fi(c, A, f) }) like the environment's
   kinds (weather_env.js): the engine (tools/pfanim_part.js) clips them to the board, scales time with the step and plays them in Full only (Light = the place motion, Off = nothing).
   Built from claude/stat-pieces-design/stat24.json (no mock-up exists, so these are the most reasonable readings of its motif lines):
   Loaded Die  "lid opens, cell-shaded cube spins out and lands on the piece": a small hatch opens on the piece, a die pops out in an arc, tumbles and lands on the linked piece
               (or the next cell on the board when it links to none); a hit lands a 5 or 6 with a gold ring, a miss a 1 or 2 with a grey puff. The hatch closes behind it.
   @trapdoor   (engine name, not a piece) a creature piece came down on a Snare Field snare: the lid of the trapdoor stands open as the piece drops in, a leaf noose cinches, the lid slams shut.
   Every draw is a stateless function of f (ms, 0 .. dur); particles go through A.put (the MAXG glyph budget); A.shake(id, dx, dy, r) moves a piece on the board (reset by the engine).
   A: cx, cy (this piece's cell centre), tg ({ x, y, id } of the piece it links to or null), roll ('hit' | 'miss' | ''), col, acc, hi, BW, BH, w, h, x, y (its cell), cxOf, cyOf, put, shake. */
(function () {
  var INK = '#2a1a10', WOOD = '#a8743c', WOOD2 = '#7d5128', WOOD3 = '#c8944f', HOLE = '#1a0f0a', CREAM = '#f2e4c0', GREY = '#b9b2a6';
  function cl(u) { return Math.min(1, Math.max(0, u)); }
  function eio(u) { u = cl(u); return u * u * (3 - 2 * u); }
  function eo(u) { u = cl(u); return 1 - (1 - u) * (1 - u); }
  function lerp(a, b, u) { return a + (b - a) * u; }
  function mix(a, b, t) { var i, o = '#', A = [1, 3, 5].map(function (j) { return parseInt(a.substr(j, 2), 16); }), B = [1, 3, 5].map(function (j) { return parseInt(b.substr(j, 2), 16); });
    for (i = 0; i < 3; i++) { var v = Math.round(A[i] * (1 - t) + B[i] * t); o += (v < 16 ? '0' : '') + v.toString(16); } return o; }
  function hash(n) { var x = Math.sin(n * 127.1 + 311.7) * 43758.5453; return x - Math.floor(x); }

  /* ---------- the hatch: a wooden lid hinged on its top edge. open 0 = shut (planks, ring), 1 = standing up (seen edge-on, lighter underside) over a dark hole ---------- */
  function lid(c, A, x, y, w, h, open, a) {
    var put = A.put, lh, ly, k;
    if (a < 1) c.globalAlpha = Math.max(0, a);
    if (open > .02) { put(c, x - 1, y - 1, w + 2, h + 2, INK); put(c, x, y, w, h, HOLE); put(c, x + 2, y + h - 3, w - 4, 1, '#3a2418'); }   // the hole, a lip of light on its far wall
    lh = Math.max(3, Math.round(h * (1 - .9 * open))); ly = y - Math.round(open * 5);
    put(c, x - 1, ly - 1, w + 2, lh + 2, INK); put(c, x, ly, w, lh, open > .5 ? WOOD3 : WOOD);
    if (open <= .5) {
      put(c, x, ly, w, 1, WOOD3);
      for (k = 1; k < 3; k++) if (ly + Math.round(lh * k / 3) < ly + lh - 1) put(c, x, ly + Math.round(lh * k / 3), w, 1, WOOD2);
      put(c, x + 2, ly + 2, 2, 2, INK); put(c, x + w - 4, ly + 2, 2, 2, INK);                                   // hinge pins
      if (lh >= 8) { put(c, x + Math.round(w / 2) - 2, ly + lh - 6, 4, 3, CREAM); put(c, x + Math.round(w / 2) - 1, ly + lh - 5, 2, 1, INK); }   // pull ring
    } else put(c, x, ly + lh - 1, w, 1, WOOD2);
    c.globalAlpha = 1;
  }

  /* ---------- a die (cell-shaded): body col, light top-left rim, shade bottom-right, ink outline, pips; w x h squashes it while it tumbles ---------- */
  var PIPS = [null, [[.5, .5]], [[.2, .2], [.8, .8]], [[.2, .2], [.5, .5], [.8, .8]], [[.2, .2], [.8, .2], [.2, .8], [.8, .8]],
    [[.2, .2], [.8, .2], [.5, .5], [.2, .8], [.8, .8]], [[.2, .12], [.2, .5], [.2, .88], [.8, .12], [.8, .5], [.8, .88]]];
  function die(c, A, x, y, w, h, face, col, a) {
    var put = A.put, x0 = Math.round(x - w / 2), y0 = Math.round(y - h / 2), pp, i, ps;
    w = Math.round(w); h = Math.round(h); if (w < 3 || h < 3) return;
    if (a < 1) c.globalAlpha = Math.max(0, a);
    put(c, x0 - 1, y0 - 1, w + 2, h + 2, INK); put(c, x0, y0, w, h, col);
    put(c, x0, y0, w, 1, mix(col, '#ffffff', .6)); put(c, x0, y0, 1, h, mix(col, '#ffffff', .6));
    put(c, x0 + 1, y0 + h - 2, w - 1, 2, mix(col, INK, .3)); put(c, x0 + w - 2, y0 + 1, 2, h - 2, mix(col, INK, .3));
    ps = w >= 10 && h >= 10 ? 2 : 1; pp = PIPS[Math.max(1, Math.min(6, face))];
    if (w >= 6 && h >= 6) for (i = 0; i < pp.length; i++) put(c, x0 + Math.round(1 + pp[i][0] * (w - 2 - ps)), y0 + Math.round(1 + pp[i][1] * (h - 2 - ps)), ps, ps, INK);
    c.globalAlpha = 1;
  }
  function shadow(c, A, x, y, r, a) { var k; for (k = -1; k <= 1; k++) A.put(c, x - r + Math.abs(k) * 2, y + k * 2, 2 * (r - Math.abs(k) * 2), 2, 'rgba(26,15,10,' + (.32 * a).toFixed(2) + ')'); }
  function dust(c, A, x, y, u, col, n) {   /* a little ring of specks that flies out and falls */
    var k, v = cl(u); if (v <= 0 || v >= 1) return;
    for (k = 0; k < n; k++) { var an = Math.PI * (k + .5) / n, rr = 4 + 10 * eo(v); A.put(c, x + Math.cos(an) * rr * 1.4 - 1, y - Math.sin(an) * rr * .6 + 6 * v * v - 1, 3 - (v > .5 ? 1 : 0), 3 - (v > .5 ? 1 : 0), col); }
  }
  function sparkle(c, A, x, y, r, col) { A.put(c, x - 1, y - r, 2, 2 * r + 1, col); A.put(c, x - r, y - 1, 2 * r + 1, 2, col); }

  /* ================= LOADED DIE ================= */
  function dieSpot(A) {   /* where it lands: on the piece it links to, else the next cell along the board (toward the middle) */
    if (A.tg) return [A.cxOf(A.tg.x), A.cyOf(A.tg.y) - 3];
    var d = A.w > 1 ? (A.x * 2 < A.w - 1 ? 1 : -1) : 0, e = d ? 0 : (A.y * 2 < A.h - 1 ? 1 : -1);
    return [A.cx + d * A.BW, A.cy + e * A.BH - 3];
  }
  function loadedDie(c, A, f) {
    var cx = A.cx, cy = A.cy + 3, T = dieSpot(A), tx = T[0], ty = T[1], hit = A.roll !== 'miss', col = A.col || '#e8c84a', open, a, u, x, y, w, h, s, face, z, v, k, bx, by, tw = .5;
    var LW = 26, LH = 16, dist = Math.abs(tx - cx) + Math.abs(ty - cy), arc = 30 + dist * .14;
    /* the hatch: pops in, opens, stays open while the die is out, closes with a thump */
    a = cl(f / 90); open = f < 160 ? eio(f / 160) : f < 700 ? 1 : f < 840 ? 1 - eio((f - 700) / 140) : 0;
    if (f < 1000) lid(c, A, cx - LW / 2, cy - LH / 2, LW, LH, open, f > 900 ? cl((1000 - f) / 100) : a);
    if (f >= 830 && f < 900) A.shake(A.it.id, Math.round(Math.sin(f / 18) * 1.5 * (1 - (f - 830) / 70)), 0, 0);
    /* the die: pops out of the hole, flies, tumbles (squash by turns), lands, bounces twice, settles on its face, fades */
    if (f >= 120 && f < 1120) {
      u = cl((f - 120) / 560); face = 1 + (Math.floor(f / 55) + 2) % 6;
      if (f < 680) {   // flight
        z = Math.sin(Math.PI * Math.pow(u, .85)); x = lerp(cx, tx, u); y = lerp(cy - 2, ty, u) - arc * z;
        s = lerp(8, 15, Math.min(1, u * 4)); v = u * 2.6 * Math.PI * 2; w = Math.max(8, s * (.7 + .3 * Math.abs(Math.cos(v)))); h = Math.max(8, s * (.7 + .3 * Math.abs(Math.cos(v * .8 + 1))));
        if (f < 240) shadow(c, A, cx, cy + 6, 4, 0); else shadow(c, A, x, lerp(cy + 6, ty + 8, u), Math.round(4 + 4 * (1 - z)), .6 + .4 * u);
        die(c, A, x, y, w, h, face, col, 1);
        if (u < .3) for (k = 0; k < 3; k++) A.put(c, cx - 8 + k * 8 + Math.round(hash(k + A.seed) * 3), cy - 6 - Math.round(u * 40) - k * 2, 2, 2, mix(col, '#ffffff', .6));   // sparks out of the hatch
      } else {   // landed: two bounces, then rest
        var b1 = cl((f - 680) / 90), b2 = cl((f - 770) / 70); y = ty - Math.sin(Math.PI * b1) * 7 * (b1 < 1 ? 1 : 0) - Math.sin(Math.PI * b2) * 3 * (b2 < 1 ? 1 : 0);
        s = 16; w = s; h = s; if (f < 700) { w = s + 3; h = s - 3; }
        face = hit ? (A.seed & 1 ? 6 : 5) : (A.seed & 1 ? 2 : 1);
        if (f < 850) face = 1 + (Math.floor(f / 40) + 3) % 6;
        a = f < 1000 ? 1 : cl((1120 - f) / 120); shadow(c, A, tx, ty + 8, 7, a);
        die(c, A, tx, y, w, h, face, col, a);
      }
      /* the landing: dust, a shake of the piece under it, then a gold ring (hit) or a grey puff (miss) */
      if (f >= 680) {
        if (f < 900) dust(c, A, tx, ty + 6, (f - 680) / 220, hit ? mix(col, '#ffffff', .5) : GREY, 6);
        if (A.tg && f < 960) A.shake(A.tg.id, Math.round(Math.sin(f / 21) * 2.5 * (1 - (f - 680) / 280)), Math.round(Math.cos(f / 17) * 1 * (1 - (f - 680) / 280)), 0);
        if (hit && f >= 780 && f < 1100) { u = (f - 780) / 320; v = 8 + Math.round(14 * eo(u)); for (k = 0; k < 12; k++) { var an = k / 12 * Math.PI * 2; if (hash(k * 3 + A.seed) < u) continue; A.put(c, tx + Math.round(Math.cos(an) * v * 1.5) - 1, ty + Math.round(Math.sin(an) * v) - 1, 2, 2, k & 1 ? '#fff6dc' : col); }
          if (u < .6) { sparkle(c, A, tx - 15, ty - 9, 2, '#fff6dc'); sparkle(c, A, tx + 16, ty - 3, 3, col); } }
      }
    }
  }

  /* ================= TRAPDOOR: a creature piece came down on a Snare Field snare (engine name '@trapdoor'; its cell is A.cx, A.cy) ================= */
  function trapdoor(c, A, f) {
    var x0 = Math.round(A.cx - A.BW / 2), y0 = Math.round(A.cy - A.BH / 2), W = A.BW, H = A.BH, put = A.put, k, u, open, a, rr, LH = 12, g = 3;
    open = f < 120 ? eio(f / 120) : f < 480 ? 1 : f < 600 ? 1 - Math.pow(eio((f - 480) / 120), 1.5) : 0;   // the lid: standing open as the piece drops, slams at ~600
    a = f < 80 ? cl(f / 80) : f < 1000 ? 1 : cl((1200 - f) / 200);
    c.globalAlpha = a;
    /* the trap's frame round the cell body (a plank border with an ink line, so it shows on any piece) */
    put(c, x0 - 1, y0 - 1, W + 2, 1, INK); put(c, x0 - 1, y0 + H, W + 2, 1, INK); put(c, x0 - 1, y0, 1, H, INK); put(c, x0 + W, y0, 1, H, INK);
    put(c, x0, y0, W, g, WOOD3); put(c, x0, y0 + H - g, W, g, WOOD3); put(c, x0, y0 + g, g, H - 2 * g, WOOD3); put(c, x0 + W - g, y0 + g, g, H - 2 * g, WOOD3);
    put(c, x0 + g, y0 + g, W - 2 * g, 1, INK); put(c, x0 + g, y0 + H - g - 1, W - 2 * g, 1, INK); put(c, x0 + g, y0 + g, 1, H - 2 * g, INK); put(c, x0 + W - g - 1, y0 + g, 1, H - 2 * g, INK);
    /* the lid hinged on the top edge: up and open above the cell (underside showing), swinging down across the top with a thump */
    if (f < 760) { var lh = Math.max(4, Math.round(LH * (1 - .55 * open))), ly = y0 - Math.round(open * lh) - 1 + (open < 1 ? Math.round((1 - open) * 2) : 0);
      put(c, x0 - 1, ly - 1, W + 2, lh + 2, INK); put(c, x0, ly, W, lh, open > .5 ? WOOD : WOOD3);
      if (open <= .5) { put(c, x0, ly + 4, W, 1, WOOD2); put(c, x0, ly + 8, W, 1, WOOD2); put(c, x0 + W / 2 - 3, ly + lh - 4, 6, 3, CREAM); put(c, x0 + W / 2 - 1, ly + lh - 3, 2, 1, INK); }
      else { put(c, x0, ly + lh - 2, W, 2, WOOD2); put(c, x0 + 3, ly + 2, 3, 2, INK); put(c, x0 + W - 6, ly + 2, 3, 2, INK); } }
    if (f >= 590 && f < 720) { u = (f - 590) / 130; A.shake(A.it.id, Math.round(Math.sin(f / 15) * 2.2 * (1 - u)), Math.round((1 - u) * 1.5), 0);
      dust(c, A, A.cx, y0 + 4, u, '#d8c8a0', 6); }
    c.globalAlpha = 1;
    /* a noose of leaf-twine cinches round the piece (the snare's own loop) between 160 and 620, the knot at its foot */
    if (f >= 160 && f < 1100) { u = eio((f - 160) / 460); rr = lerp(1, .74, u); var n = 24;
      for (k = 0; k < n; k++) { var an = k / n * Math.PI * 2; if (f > 900 && hash(k + A.seed) < (f - 900) / 200) continue;
        put(c, A.cx + Math.round(Math.cos(an) * (W / 2 - 4) * rr) - 1, A.cy + Math.round(Math.sin(an) * (H / 2 - 4) * rr) - 1, 3, 3, k % 3 === 0 ? '#c8e07a' : '#5f9a4a'); }
      if (u > .8 && f < 1000) { put(c, A.cx - 4, A.cy + Math.round((H / 2 - 4) * rr) - 3, 8, 5, INK); put(c, A.cx - 3, A.cy + Math.round((H / 2 - 4) * rr) - 2, 6, 3, '#c8e07a'); } }
    if (f >= 200 && f < 520) for (k = 0; k < 5; k++) { u = cl((f - 200 - k * 25) / 260); if (u <= 0 || u >= 1) continue; put(c, x0 + 8 + k * 10 + Math.round((hash(k + 5) - .5) * 6), y0 + H - 8 - Math.round(24 * u), 3, 3, k & 1 ? '#8fb86a' : '#c8e07a'); }   // leaf bits flung up
  }

  PFA.stat('Loaded Die', { dur: 1200, fi: loadedDie });
  PFA.stat('@trapdoor', { dur: 1200, fi: trapdoor });
})();
