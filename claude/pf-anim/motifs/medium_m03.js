/* Motif module, medium batch m03 (ghost-slug, giant-banded-snail, herring-gull, tern-squadron, skua-raider, cormorant-line, booby-colony,
   turkey-vulture, mountain-buzzard, burrowing-owl, snowy-owl-scout). TEMPLATE.md section 10.3.
   24 motifs, each with its own pixel glyph (ids prefixed m03-) and motion; four have their own chain effect (carDraw).
   Birds are drawn upright in screen space (a bird reads only the right way up), facing along the edge tangent; molluscs, beaks, necks
   and talons are drawn along the edge (tangent / outward normal).
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation inside the frame loops (scratch H.Q / H.G,
   constant colours only). Glyphs go through H.glyph so the MAXG budget counts them; per-run decorations are capped at a few pixels.
   The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy default are untouched (they live in the page). */
(function () {
  var YEL = '#f2c81a', RED = '#d83020', GREY = '#9aa6ae', SAND = '#c8a878';   /* fixed details: owl eyes, gull bill spot, gull mantle, snail foot */

  /* ---------- shared own-edge composition: the page's themedOwn() with this module's glyph / motion ---------- */
  function comp(c, e, H) {
    var runs = e.runs, mp = e.mp, M = e.M, z = e.z, p = e.p, pp = p * mp.spd, Q = H.Q, G = H.G, P = e.P,
      tie = mp.x === 'thread' || mp.lay === 'snare', ri, k, r, len, n, f, ph, sf, bx0, by0, nx, ny, x, y, lx = 0, ly = 0, has;
    for (ri = 0; ri < runs.length; ri++) {
      r = runs[ri]; len = r[1] - r[0]; n = Math.max(1, Math.min(7, Math.round(len / (M.gap || 12)))); if (mp.lay === 'lance') n = Math.min(n, 4); has = false;
      for (k = 0; k < n; k++) {
        f = (k + .5) / n; ph = H.hash(e.seed * 13 + k * 7 + ri * 31);
        H.lay(mp.lay, p, f, ph, k); H.mot(M.mo, pp, k, ph);
        if (G.vis <= 0 || !H.stip(G.vis, k + ri * 9, p)) { has = false; continue; }
        sf = G.s - Math.floor(G.s); P.atq(r[0] + len * sf); bx0 = Q.x; by0 = Q.y; nx = Q.nx; ny = Q.ny;
        x = bx0 + nx * G.d - ny * G.t; y = by0 + ny * G.d + nx * G.t - G.up;
        if (mp.x === 'threads') H.ln(c, bx0 + nx, by0 + ny, x, y, 1, e.hi);
        else if (mp.x === 'silk') H.ln(c, bx0 + ny * 9 + nx, by0 - nx * 9 + ny, x, y, 1, e.hi);
        if (tie && has && Math.abs(x - lx) + Math.abs(y - ly) < 30) H.ln(c, lx, ly, x, y, 1, e.hi);
        H.glyph(c, M.g, x, y, z, G.fr, e.col, e.acc, e.hi, -ny, nx, nx, ny); lx = x; ly = y; has = true;
      }
      H.ext(c, mp.x, P, r[0], len, ri, p, pp, e.col, e.acc, e.hi, e.seed);
    }
  }

  /* ---------- glyphs (pixel sprites at the demo resolution; tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step) ---------- */
  PFA.glyph('m03-ghost', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* ghost slug: hollow see-through outline, a glow core drifting inside, eye stalks */
    var L = 3 + z, i, ai;
    for (i = -L; i <= L; i++) { ai = Math.abs(i);
      if (((i + L + fr) & 3) !== 0) K.px(c, x + tx * i, y + ty * i, C);                                   /* sole: gaps shimmer along it */
      if (ai < L && ((i + L + fr + 2) & 3) !== 0) K.px(c, x + tx * i + nx * 2, y + ty * i + ny * 2, C); } /* back */
    K.px(c, x + tx * L + nx, y + ty * L + ny, C); K.px(c, x - tx * L + nx, y - ty * L + ny, C);
    K.px(c, x + tx * (fr - 1.5) + nx, y + ty * (fr - 1.5) + ny, Hi); if (fr === 2) K.px(c, x + tx * .5 + nx, y + ty * .5 + ny, K.WHITE);
    K.px(c, x + tx * (L + 1) + nx * 3, y + ty * (L + 1) + ny * 3, C); K.px(c, x + tx * (L + 2) + nx * 4, y + ty * (L + 2) + ny * 4, Hi);
    K.px(c, x + tx * L + nx * 3, y + ty * L + ny * 3, C); K.px(c, x + tx * L + nx * 4, y + ty * L + ny * 4, Hi);
  });
  PFA.glyph('m03-mist', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* cold breath: a curling wisp that unrolls upward, a frost speck at its tip */
    var j, a, r;
    for (j = 0; j < 6 + z; j++) { a = fr * .8 + j * .95; r = .8 + j * .55; K.px(c, x + Math.cos(a) * r, y - j * .7 + Math.sin(a) * r * .6, j < 3 ? C : Hi); }
    if (fr === 3) K.px(c, x + 1, y - 6 - z, K.WHITE);
  });
  PFA.glyph('m03-barrel', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* giant banded snail: big glossy shell with a dark spiral band, foot and stalks */
    var o = 3 + (z > 1 ? 1 : 0), d = tx < -.3 ? -1 : 1, i = fr & 3;
    K.bx(c, x - o - 2, y + o, 2 * o + 5, 1, SAND); K.px(c, x + d * (o + 3), y + o - 1, SAND);
    K.px(c, x + d * (o + 3), y + o - 2, SAND); K.px(c, x + d * (o + 4), y + o - 3, Hi);
    K.bx(c, x - o + 1, y - o, 2 * o - 1, 1, C); K.bx(c, x - o, y - o + 1, 2 * o + 1, 2 * o - 1, C); K.bx(c, x - o + 1, y + o - 1, 2 * o - 1, 1, C);
    K.ringpx(c, x, y, o - 1, A); K.sq(c, x, y, 2, C); K.px(c, x, y, A);
    K.px(c, x + (i === 1 || i === 2 ? 2 : -2), y + (i >= 2 ? 1 : -2), K.WHITE);                       /* gloss highlight turns as it rolls */
  });
  PFA.glyph('m03-sheet', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* slime sheet: a glossy film laid on the edge, a sheen sliding, a string sagging off */
    var L = 3 + z, i, s = fr - 1.5, j;
    for (i = -L; i <= L; i++) { K.px(c, x + tx * i, y + ty * i, C); if (Math.abs(i) < L) K.px(c, x + tx * i + nx, y + ty * i + ny, C); }
    K.px(c, x + tx * s * 1.6 + nx, y + ty * s * 1.6 + ny, K.WHITE); K.px(c, x + tx * (s * 1.6 + 1) + nx, y + ty * (s * 1.6 + 1) + ny, Hi);
    for (j = 2; j <= 2 + (fr & 1) + (fr >> 1); j++) K.px(c, x + nx * j, y + ny * j, Hi);
  });
  PFA.glyph('m03-gull', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* herring gull in flight: white body, grey M wings with black tips, yellow bill, red spot */
    var d = tx < -.3 ? -1 : 1, w = fr ? 0 : -1, s = z > 1 ? 1 : 0;
    K.bx(c, x - 2, y, 4, 2, C); K.px(c, x + d * 2, y - 1, C); K.px(c, x + d * 3, y - 1, Hi); K.px(c, x + d * 3, y, RED);
    K.px(c, x - 1, y - 1, GREY); K.px(c, x - 2, y - 2 + w, GREY); K.px(c, x - 3 - s, y - 2 + w, GREY); K.px(c, x - 4 - s, y - 1 + w * 2, A);
    K.px(c, x + 1, y - 1, GREY); K.px(c, x + 2, y - 2 + w, GREY); K.px(c, x + 3 + s, y - 2 + w, GREY); K.px(c, x + 4 + s, y - 1 + w * 2, A);
    K.px(c, x - d * 3, y + 1, C);
  });
  PFA.glyph('m03-chip', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* stolen hot chip: a gold stick tumbling end over end, a salt fleck */
    var i;
    if (fr === 0) { K.bx(c, x - 2, y, 5, 2, C); K.px(c, x + 2, y, A); }
    else if (fr === 2) { K.bx(c, x, y - 2, 2, 5, C); K.px(c, x, y + 2, A); }
    else for (i = -2; i <= 2; i++) K.bx(c, x + (fr === 1 ? i : -i), y + i, 2, 1, i === 2 ? A : C);
    K.px(c, x, y - 1, K.WHITE); K.px(c, x + 1, y + 1, Hi);
  });
  PFA.glyph('m03-lid', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* bin lid: a dome lid with a handle tipping and clanging, clang marks */
    var t = fr & 1 ? 1 : 0;
    K.bx(c, x - 3, y + t, 4, 1, C); K.bx(c, x + 1, y, 3, 1, C); K.bx(c, x - 2, y - 1, 5, 1, C); K.px(c, x - 3, y + 1 + t, A); K.px(c, x + 3, y + 1, A);
    K.px(c, x, y - 2, Hi); K.px(c, x - 1, y - 1, K.WHITE);
    if (fr >= 2) { K.px(c, x - 5, y - 2, Hi); K.px(c, x - 6, y - 3, Hi); K.px(c, x + 5, y - 2, Hi); K.px(c, x + 6, y - 3, Hi); K.px(c, x, y - 4, Hi); }
  });
  PFA.glyph('m03-screech', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* gull head thrown back, beak wide open, screech wedges spreading */
    var d = tx < -.3 ? -1 : 1, j;
    K.sq(c, x, y, 3, C); K.px(c, x - d, y - 1, A); K.px(c, x, y + 2, C);
    K.px(c, x + d * 2, y - 1, Hi); K.px(c, x + d * 3, y - 2, Hi); K.px(c, x + d * 2, y + 1, Hi); K.px(c, x + d * 3, y + 2, RED);
    for (j = 1; j <= fr + 1; j++) { K.px(c, x + d * (3 + j * 2), y - j, C); K.px(c, x + d * (4 + j * 2), y, C); K.px(c, x + d * (3 + j * 2), y + j, C); }
  });
  PFA.glyph('m03-tern', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* tern: slim white body, black cap, red bill, swept wings, long forked tail */
    var d = tx < -.3 ? -1 : 1, s = z > 1 ? 1 : 0;
    K.bx(c, x - 1, y, 3, 1, C); K.px(c, x + d * 2, y - 1, C); K.px(c, x + d, y - 1, A); K.px(c, x + d * 2, y - 2, A);
    K.px(c, x + d * 3, y - 1, Hi); K.px(c, x + d * 4, y - 1, Hi);
    if (fr) { K.px(c, x - d, y - 1, C); K.px(c, x - d * 2, y - 2, C); K.px(c, x - d * 3, y - 3 - s, C); K.px(c, x - d * 4, y - 4 - s, A); }
    else { K.px(c, x, y + 1, C); K.px(c, x - d, y + 2, C); K.px(c, x - d * 2, y + 3 + s, A); }
    K.px(c, x - d * 2, y, C); K.px(c, x - d * 3, y - 1, C); K.px(c, x - d * 4, y - 2, C); K.px(c, x - d * 3, y + 1, C); K.px(c, x - d * 4, y + 1, C);
  });
  PFA.glyph('m03-splash', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* plunge: a diver folds in, a crown splash jumps up, then rings and drops */
    var h = fr === 1 ? 3 : fr === 2 ? 5 + z : fr === 3 ? 2 : 0, i;
    K.bx(c, x - 4, y + 2, 9, 1, Hi);
    if (fr === 0) { K.px(c, x, y - 1, C); K.px(c, x, y - 2, C); K.px(c, x - 1, y - 3, C); K.px(c, x + 1, y - 3, C); K.px(c, x, y - 4, A); }
    else for (i = -2; i <= 2; i++) { K.px(c, x + i * 1.5, y + 1 - h * (1 - Math.abs(i) * .25), i ? C : K.WHITE); if (fr > 1) K.px(c, x + i * 2, y - h - 1 + Math.abs(i), Hi); }
    if (fr === 3) { K.px(c, x - 5, y + 1, Hi); K.px(c, x + 5, y + 1, Hi); }
  });
  PFA.glyph('m03-skua', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* skua: heavy brown body, broad wings with white flashes, a hooked dark bill */
    var d = tx < -.3 ? -1 : 1, w = fr ? -1 : 1, s = z > 1 ? 1 : 0;
    K.sq(c, x, y, 3, C); K.px(c, x + d * 2, y - 1, C); K.px(c, x + d * 3, y - 1, A); K.px(c, x + d * 3, y, A); K.px(c, x - d * 2, y + 1, C);
    K.ln(c, x - 1, y - 1, x - 4 - s, y - 1 + w * 2, 1, C); K.ln(c, x + 1, y - 1, x + 4 + s, y - 1 + w * 2, 1, C);
    K.px(c, x - 3 - s, y - 1 + w * 2 - (w > 0 ? 1 : 0), Hi); K.px(c, x + 3 + s, y - 1 + w * 2 - (w > 0 ? 1 : 0), Hi);
  });
  PFA.glyph('m03-hook', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* hooked bill: a head jabbing out along the normal, the bill opening and tearing */
    var L = fr === 1 ? 5 + z : fr === 2 ? 4 + z : 3, j;
    K.sq(c, x, y, 3 + (z >> 1), C); K.px(c, x + tx * 1 + nx, y + ty * 1 + ny, A);
    for (j = 2; j <= L; j++) K.px(c, x + nx * j, y + ny * j, Hi);
    K.px(c, x + nx * L + tx, y + ny * L + ty, Hi); K.px(c, x + nx * (L - 1) + tx * 1.5, y + ny * (L - 1) + ty * 1.5, A);
    if (fr === 2) for (j = 2; j < L; j++) K.px(c, x + nx * j - tx * 1.4, y + ny * j - ty * 1.4, Hi);
  });
  PFA.glyph('m03-fish', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* stolen fish: a silver fish tumbling end over end, a drop flung off */
    var dx = fr === 0 ? 1 : fr === 2 ? 0 : .7, dy = fr === 0 ? 0 : fr === 2 ? 1 : (fr === 1 ? .7 : -.7), i;
    for (i = -2; i <= 1; i++) { K.px(c, x + dx * i, y + dy * i, C); K.px(c, x + dx * i - dy, y + dy * i + dx, i === 1 ? A : C); }
    K.px(c, x - dx * 3 + dy, y - dy * 3 - dx, Hi); K.px(c, x - dx * 3 - dy * 2, y - dy * 3 + dx * 2, Hi); K.px(c, x + dx * 2, y + dy * 2, C);
    K.px(c, x + 2, y - 3, K.WHITE);
  });
  PFA.glyph('m03-dry', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* cormorant drying: upright body, snake neck, wings hung out ragged, drips falling */
    var s = z > 1 ? 1 : 0, u = fr & 1 ? -1 : 0;
    K.bx(c, x - 1, y - 2, 2, 5, C); K.px(c, x, y - 3, C); K.px(c, x - 1, y - 4, C); K.px(c, x, y - 5, C); K.px(c, x + 1, y - 5, Hi); K.px(c, x + 2, y - 5, A);
    K.bx(c, x - 5 - s, y - 2 + u, 4 + s, 1, C); K.bx(c, x + 1, y - 2 + u, 4 + s, 1, C);
    K.px(c, x - 5 - s, y - 1 + u, C); K.px(c, x - 3 - s, y - 1 + u, C); K.px(c, x + 4 + s, y - 1 + u, C); K.px(c, x + 2 + s, y - 1 + u, C);
    K.px(c, x - 4, y - 2 + u, A); K.px(c, x + 3, y - 2 + u, A);
    if (fr >= 2) { K.px(c, x - 5 - s, y + fr - 1, K.DEW); K.px(c, x + 4 + s, y + fr, K.DEW); }
  });
  PFA.glyph('m03-neck', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* snake neck: only an S-curved neck and hooked head out of the water, ripples at its base */
    var L = 2 + fr + (z >> 1), j, o, hx, hy;
    K.px(c, x - tx * 3, y - ty * 3, Hi); K.px(c, x - tx * 2, y - ty * 2, Hi); K.px(c, x + tx * 2, y + ty * 2, Hi); K.px(c, x + tx * 3, y + ty * 3, Hi);
    for (j = 0; j <= L; j++) { o = Math.sin(j * 1.1 + fr * .5) * 1.2; K.px(c, x + nx * j + tx * o, y + ny * j + ty * o, C); }
    o = Math.sin((L + 1) * 1.1 + fr * .5) * 1.2; hx = x + nx * (L + 1) + tx * o; hy = y + ny * (L + 1) + ty * o;
    K.sq(c, hx, hy, 2, C); K.px(c, hx + tx * 2, hy + ty * 2, A); K.px(c, hx + tx * 2 - nx, hy + ty * 2 - ny, A); K.px(c, hx, hy, Hi);
  });
  PFA.glyph('m03-foot', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* blue-footed booby strut: a white body, one bright blue webbed foot lifted high */
    var a = fr ? 0 : 2, b = fr ? 2 : 0;
    K.bx(c, x - 1, y - 5, 3, 3, Hi); K.px(c, x, y - 6, Hi); K.px(c, x + 1, y - 6, A); K.px(c, x - 1, y - 2, Hi);
    K.px(c, x - 1, y - 1, C); K.px(c, x + 1, y - 1, C);
    K.bx(c, x - 3, y + 1 - a, 3, 1, C); K.px(c, x - 2, y - a, C); K.px(c, x - 1, y - a, C);
    K.bx(c, x + 1, y + 1 - b, 3, 1, C); K.px(c, x + 2, y - b, C); K.px(c, x + 1, y - b, C);
  });
  PFA.glyph('m03-wobv', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* turkey vulture: wings in a shallow V teetering, silver flight feathers, tiny red head */
    var t = fr === 1 ? 1 : fr === 3 ? -1 : 0, L = 5 + (z > 1 ? 1 : 0), i, yl, yr;
    for (i = 1; i <= L; i++) { yl = y - Math.round(i * .4) + (i > 2 ? t : 0); yr = y - Math.round(i * .4) - (i > 2 ? t : 0);
      K.px(c, x - i, yl, A); K.px(c, x + i, yr, A); K.px(c, x - i, yl + 1, C); K.px(c, x + i, yr + 1, C); }
    K.px(c, x - L - 1, y - Math.round(L * .4) + t, C); K.px(c, x + L + 1, y - Math.round(L * .4) - t, C);
    K.px(c, x, y, A); K.px(c, x, y + 1, C); K.px(c, x, y - 1, Hi);
  });
  PFA.glyph('m03-therm', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* thermal: a shimmering heat column, a tiny V circling up inside it */
    var j, cx = Math.cos(fr * 1.571) * 3, cy = -2 - fr;
    for (j = 0; j < 6; j++) if (((j + fr) & 1) === 0) K.px(c, x + Math.round(Math.sin(j * 1.3 + fr) * 1.2), y - j * 1.5, Hi);
    K.px(c, x + cx - 1, y + cy - 1, C); K.px(c, x + cx, y + cy, C); K.px(c, x + cx + 1, y + cy - 1, C);
  });
  PFA.glyph('m03-buzz', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* buzzard: very broad rounded wings, mottled, pale under-edge, fanned barred tail */
    var s = z > 1 ? 1 : 0, u = fr ? -1 : 0, W = 5 + s;
    K.sq(c, x, y, 3, C); K.px(c, x, y - 2, C);
    K.bx(c, x - W - 1, y - 1, W, 2, C); K.bx(c, x + 2, y - 1, W, 2, C);
    K.px(c, x - W - 2, y - 1 + u, C); K.px(c, x - W - 2, y + 1 + u, C); K.px(c, x + W + 2, y - 1 + u, C); K.px(c, x + W + 2, y + 1 + u, C);
    K.px(c, x - 3, y - 1, A); K.px(c, x - 5, y, A); K.px(c, x + 3, y, A); K.px(c, x + 5, y - 1, A);
    K.px(c, x - 4, y + 1, Hi); K.px(c, x - 2, y + 1, Hi); K.px(c, x + 3, y + 1, Hi); K.px(c, x + 5, y + 1, Hi);
    K.bx(c, x - 1, y + 2, 3, 1, C); K.px(c, x - 2, y + 3, C); K.px(c, x, y + 3, A); K.px(c, x + 2, y + 3, C);
  });
  PFA.glyph('m03-shadow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* soar shadow: the broad-winged cross shape lying flat on the ground, a light rim */
    var W = 6 + (z > 1 ? 1 : 0), i;
    K.bx(c, x - W, y, 2 * W + 1, 2, A); K.bx(c, x - 1, y - 2, 3, 6, A);
    for (i = -W; i <= W; i += 2) K.px(c, x + i, y - 1, C);
    K.px(c, x - W - 1, y + 1, C); K.px(c, x + W + 1, y + 1, C); K.px(c, x, y - 3, Hi); K.px(c, x - 1, y + 4, C); K.px(c, x + 1, y + 4, C);
  });
  PFA.glyph('m03-talon', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* talons: a feathered leg and three hooked toes, open, closing, clenched */
    var sp = fr === 0 ? .75 : fr === 1 ? .45 : .15, s, j, dx, dy, L = 3 + (z >> 1);
    K.sq(c, x - nx, y - ny, 3, C); K.px(c, x - nx * 3, y - ny * 3, C);
    for (s = -1; s <= 1; s++) { dx = nx * Math.cos(sp * s) + tx * Math.sin(sp * s); dy = ny * Math.cos(sp * s) + ty * Math.sin(sp * s);
      for (j = 1; j <= L; j++) K.px(c, x + dx * j, y + dy * j, C);
      K.px(c, x + dx * (L + 1) - (tx * s + nx * (s ? 0 : 1)) * .9 * (fr > 1 ? 1 : .5), y + dy * (L + 1) - (ty * s + ny * (s ? 0 : 1)) * .9 * (fr > 1 ? 1 : .5), Hi); }
  });
  PFA.glyph('m03-owl', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* burrowing owl on stilt legs: round head, white brows, yellow eyes, bobbing */
    var b = fr ? 1 : 0;
    K.bx(c, x - 2, y - 5 + b, 5, 3, C); K.bx(c, x - 1, y - 2 + b, 3, 3, C);
    K.px(c, x - 1, y - 4 + b, YEL); K.px(c, x + 1, y - 4 + b, YEL); K.px(c, x - 1, y - 5 + b, Hi); K.px(c, x + 1, y - 5 + b, Hi); K.px(c, x, y - 3 + b, A);
    K.px(c, x, y - 1 + b, Hi); K.px(c, x - 1, y + b, A); K.px(c, x + 1, y - 1 + b, A);
    K.bx(c, x - 1, y + 1 + b, 1, 3 - b, Hi); K.bx(c, x + 1, y + 1 + b, 1, 3 - b, Hi);
  });
  PFA.glyph('m03-hole', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* burrow mouth: a sandy rim around a dark hole, two yellow eyes blinking inside, dust */
    K.bx(c, x - 3, y + 1, 7, 2, C); K.bx(c, x - 2, y - 2, 5, 1, C); K.px(c, x - 3, y - 1, C); K.px(c, x + 3, y - 1, C); K.px(c, x - 3, y, C); K.px(c, x + 3, y, C);
    K.bx(c, x - 2, y - 1, 5, 2, A);
    if (fr !== 3) { K.px(c, x - 1, y - 1 + (fr === 1 ? 1 : 0), YEL); K.px(c, x + 1, y - 1 + (fr === 1 ? 1 : 0), YEL); }
    if (fr === 2) { K.px(c, x - 2, y - 4, Hi); K.px(c, x + 1, y - 5, Hi); K.px(c, x + 3, y - 4, Hi); }
  });
  PFA.glyph('m03-gaze', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* snowy owl face: white disc, black flecks, two big yellow eyes that stare and slowly blink */
    var o = fr === 1 ? 1 : 0;
    K.bx(c, x - 2, y - 3, 5, 1, C); K.bx(c, x - 3, y - 2, 7, 4, C); K.bx(c, x - 2, y + 2, 5, 1, C);
    if (fr === 3) { K.bx(c, x - 2, y - 1, 2, 1, A); K.bx(c, x + 1, y - 1, 2, 1, A); }
    else { K.bx(c, x - 2, y - 1, 2, 2, Hi); K.bx(c, x + 1, y - 1, 2, 2, Hi); K.px(c, x - 2 + o, y, A); K.px(c, x + 1 + o, y, A); }
    K.px(c, x, y + 1, A); K.px(c, x - 3, y + 1, A); K.px(c, x + 2, y + 2, A); K.px(c, x + 3, y - 2, A);
  });

  /* ---------- motions (mutate the scratch G; pp = time x speed) ---------- */
  PFA.motion('m03-ghostslide', function (G, pp, k, ph) { G.s += pp * .15; G.fr = (Math.floor(pp * 6) + k) & 3; G.vis *= .5 + .5 * Math.abs(Math.sin(pp * 4 + ph * 6)); });   /* slides, fades in and out */
  PFA.motion('m03-curl', function (G, pp, k, ph) { G.up += pp * 5 + Math.sin(pp * 4 + k) * 1.5; G.t += Math.sin(pp * 6 + ph * 6) * 3; G.fr = (Math.floor(pp * 8) + k) & 3; });
  PFA.motion('m03-barrelroll', function (G, pp, k) { G.s += pp * .12; G.fr = Math.floor(pp * 7) & 3; });                                      /* slow heavy roll */
  PFA.motion('m03-sheen', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; });
  PFA.motion('m03-swoop', function (G, pp, k, ph) { var w = ((pp * 1.6 + ph) % 1) * 6.283; G.d += Math.sin(w) * 3; G.up += Math.cos(w) * 3; G.s += .03 * Math.sin(w * .5); G.fr = (Math.floor(pp * 12) + k) & 1; });
  PFA.motion('m03-tumblechip', function (G, pp, k) { G.fr = (Math.floor(pp * 12) + k) & 3; G.up += Math.abs(Math.sin(pp * 7 + k)) * 4; });
  PFA.motion('m03-clang', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 2 + ph) % 1) * 4.5)); if (G.fr >= 2) G.t += G.fr & 1 ? 1 : -1; });
  PFA.motion('m03-screech', function (G, pp, k) { G.fr = (Math.floor(pp * 9) + k) % 3; G.t += ((Math.floor(pp * 24) + k) & 1) ? 1 : -1; });
  PFA.motion('m03-formation', function (G, pp, k) { G.d += (k % 3) * 2.5; G.s += pp * .25; G.fr = (Math.floor(pp * 14) + k) & 1; G.up += Math.sin(pp * 6 + k); });   /* flies in a staggered V */
  PFA.motion('m03-plunge', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2 + ph) % 1) * 4); });                                         /* dive, crown, high crown, rings */
  PFA.motion('m03-chase', function (G, pp, k, ph) { G.t += Math.sin(pp * 16 + k * 2) * 4; G.d += Math.abs(Math.sin(pp * 8 + ph * 4)) * 3; G.fr = (Math.floor(pp * 10) + k) & 1; });
  PFA.motion('m03-jab', function (G, pp, k, ph) { var u = (pp * 2.5 + ph) % 1; G.fr = u < .3 ? 0 : u < .5 ? 1 : u < .75 ? 2 : 3; G.d += G.fr === 1 ? 3 : G.fr === 2 ? 2 : 0; if (G.fr === 3) G.t += (Math.floor(pp * 30) & 1) ? 1 : -1; });
  PFA.motion('m03-fishtumble', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 10) + k) & 3; G.up += Math.sin(pp * 5 + ph * 6) * 3; });
  PFA.motion('m03-shake', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 3) + k) & 3; });                                         /* wings held out, shaken now and then */
  PFA.motion('m03-emerge', function (G, pp, k, ph) { var u = (pp * 1.5 + ph) % 1; G.fr = Math.min(3, Math.floor(u * 5)); G.d -= 1; });         /* neck rises out of the water */
  PFA.motion('m03-strut', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 1; G.s += pp * .12; G.t += G.fr ? 1 : -1; });                /* high-stepping strut */
  PFA.motion('m03-teeter', function (G, pp, k, ph) { G.fr = Math.floor(pp * 6 + k * .5) & 3; G.t += Math.sin(pp * 5 + k) * 2; G.d += Math.sin(pp * 3 + ph * 6) * 1.5; });
  PFA.motion('m03-thermal', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; G.up += pp * 4; });
  PFA.motion('m03-soar', function (G, pp, k) { var w = pp * 4 + k * 1.3; G.t += Math.cos(w) * 5; G.d += Math.sin(w) * 2.5 + 1; G.fr = Math.floor(pp * 4 + k) & 1; });   /* big slow circles */
  PFA.motion('m03-shadowslide', function (G, pp) { G.s += pp * .35; G.d -= 1; G.fr = 0; });
  PFA.motion('m03-clutch', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .4 ? 0 : u < .6 ? 1 : 2; G.d += G.fr === 0 ? 2 : 0; });
  PFA.motion('m03-bob', function (G, pp, k, ph) { G.fr = Math.floor(pp * 7 + ph * 2) & 1; });                                                    /* deep head bob */
  PFA.motion('m03-peek', function (G, pp, k, ph) { G.fr = Math.floor(pp * 8 + ph * 5) & 3; });
  PFA.motion('m03-stare', function (G, pp, k, ph) { var w = Math.floor(pp * 5 + ph * 3); G.fr = (w % 5 === 4) ? 3 : (w & 1); });                 /* still stare, a head turn, a slow blink */

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ---------- */
  function carGhost(c, e, H) {          /* a faint glowing slime line fades in behind the see-through slug as it slides to the next piece */
    var P = e.P, Q = H.Q, u, i = 0;
    for (u = 0; u <= e.hh; u += .025) { i++; if (H.hash(i * 1.7 + Math.floor(e.p * 20)) > .6) continue; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, i % 4 === 0 ? e.hi : e.col); }
    if (H.stip(.55 + .45 * Math.abs(Math.sin(e.p * 9)), 3, e.p)) H.carHead(c, P, e.a + e.d * e.hh, 'm03-ghost', e.z, Math.floor(e.p * 12) & 3, 0, 0, e.col, e.acc, e.hi);
  }
  function carTern(c, e, H) {           /* a V of three terns: the leader and two wingmen a step behind, offset out and in */
    var P = e.P, Q = H.Q, k, s, o;
    for (k = 2; k >= 0; k--) { s = e.a + e.d * Math.max(0, e.hh - (k ? .07 : 0)); o = k === 1 ? 5 : k === 2 ? -3 : 0; P.atq(s);
      H.carHead(c, P, s, 'm03-tern', e.z, (Math.floor(e.p * 14) + k) & 1, Q.nx * o, Q.ny * o - (k ? 1 : 0), e.col, e.acc, e.hi); }
  }
  function carStrut(c, e, H) {          /* left, right, left: bright blue webbed prints stamped along the edge, the booby strutting at the front */
    var P = e.P, Q = H.Q, k, u, o;
    for (k = 1; k <= 6; k++) { u = e.hh - k * .07; if (u < 0) break; P.atq(e.a + e.d * u); o = (k & 1) ? 3 : 6;
      H.px(c, Q.x + Q.nx * o - 1, Q.y + Q.ny * o, e.col); H.px(c, Q.x + Q.nx * o, Q.y + Q.ny * o + 1, e.col); H.px(c, Q.x + Q.nx * o + 1, Q.y + Q.ny * o, e.col); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm03-foot', e.z, Math.floor(e.p * 16) & 1, 0, -2, e.col, e.acc, e.hi);
  }
  function carSoar(c, e, H) {           /* the buzzard soars over, its cross-shaped shadow sliding along the edge under it */
    var P = e.P, Q = H.Q, s = e.a + e.d * e.hh;
    P.atq(s); H.glyph(c, 'm03-shadow', Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.z > 1 ? 1 : e.z, 0, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
    H.carHead(c, P, s, 'm03-buzz', e.z, Math.floor(e.p * 8) & 1, 0, -9 - Math.sin(e.p * 6) * 2, e.col, e.acc, e.hi);
  }

  /* ---------- motifs ---------- */
  PFA.motif('ghost-ooze', comp, { nm: 'ghost slugs', desc: 'see-through slug outlines sliding and fading in and out, a glow core drifting inside, eye stalks up', fam: 'drip', gap: 18, g: 'm03-ghost', mo: 'm03-ghostslide', x: 'trail', car: 'custom', carDraw: carGhost });
  PFA.motif('chill-mist', comp, { nm: 'cold breath', desc: 'pale wisps of cold cave air curling up off the edge, a frost speck at each tip', fam: 'puff', gap: 12, g: 'm03-mist', mo: 'm03-curl', x: 'haze', car: 'cloud' });
  PFA.motif('banded-barrel', comp, { nm: 'banded shells', desc: 'big glossy shells with a dark spiral band rolling slowly on a pale foot, the gloss highlight turning', fam: 'bash', gap: 18, g: 'm03-barrel', mo: 'm03-barrelroll', x: 'sheen', car: 'roll' });
  PFA.motif('slime-sheet', comp, { nm: 'slime sheets', desc: 'a glossy slime film laid along the edge, a sheen sliding over it, strings sagging off', fam: 'drip', gap: 14, g: 'm03-sheet', mo: 'm03-sheen', x: 'trail', car: 'trail' });
  PFA.motif('gull-snatch', comp, { nm: 'swooping gulls', desc: 'white gulls with grey M wings and black tips swooping down and up, yellow bill with a red spot', fam: 'slash', gap: 16, g: 'm03-gull', mo: 'm03-swoop', x: '-', car: 'comet' });
  PFA.motif('chip-loot', comp, { nm: 'stolen chips', desc: 'gold hot chips tumbling end over end with a salt fleck, snatched away', fam: 'web', gap: 14, g: 'm03-chip', mo: 'm03-tumblechip', x: 'crumbs', car: 'hop' });
  PFA.motif('bin-clang', comp, { nm: 'bin lids', desc: 'dome bin lids tipping and clanging down, clang marks flying', fam: 'bash', gap: 16, g: 'm03-lid', mo: 'm03-clang', x: 'click', car: 'hop' });
  PFA.motif('gull-screech', comp, { nm: 'screeches', desc: 'a gull head thrown back with the beak wide open, screech wedges spreading, the head shaking', fam: 'shock', gap: 16, g: 'm03-screech', mo: 'm03-screech', x: '-', car: 'zig' });
  PFA.motif('tern-fork', comp, { nm: 'tern squadron', desc: 'slim black-capped white terns with long forked tails flying in a staggered V, wings beating', fam: 'thrust', gap: 14, g: 'm03-tern', mo: 'm03-formation', x: '-', car: 'custom', carDraw: carTern });
  PFA.motif('plunge-splash', comp, { nm: 'plunge splashes', desc: 'a diver folds and hits the water, a crown splash jumps up, drops and rings fall back', fam: 'ripple', gap: 16, g: 'm03-splash', mo: 'm03-plunge', x: 'bubbles', car: 'rings' });
  PFA.motif('skua-pirate', comp, { nm: 'skua raiders', desc: 'heavy brown birds with white wing flashes and hooked bills chasing hard in swerves', fam: 'slash', gap: 16, g: 'm03-skua', mo: 'm03-chase', x: '-', car: 'zig' });
  PFA.motif('hook-jab', comp, { nm: 'hooked bills', desc: 'a head jabbing out of the edge, the hooked bill opening and tearing with a shake', fam: 'bite', gap: 14, g: 'm03-hook', mo: 'm03-jab', x: '-', car: 'comet' });
  PFA.motif('stolen-fish', comp, { nm: 'stolen fish', desc: 'silver fish tumbling end over end through the air, drops flung off', fam: 'web', gap: 14, g: 'm03-fish', mo: 'm03-fishtumble', x: 'dew', car: 'hop' });
  PFA.motif('wing-dry', comp, { nm: 'drying wings', desc: 'upright cormorants with snake necks holding ragged wings out to dry, shaking them, drips falling', fam: 'shield', gap: 16, g: 'm03-dry', mo: 'm03-shake', x: '-', car: 'train' });
  PFA.motif('snake-neck', comp, { nm: 'snake necks', desc: 'only an S-curved neck and hooked head rising out of the water, ripples at the base, then sinking', fam: 'thrust', gap: 14, g: 'm03-neck', mo: 'm03-emerge', x: 'bubbles', car: 'rings' });
  PFA.motif('blue-foot-strut', comp, { nm: 'blue-foot struts', desc: 'white boobies lifting one bright blue webbed foot high, then the other, blue prints stamped behind', fam: 'sparkle', gap: 14, g: 'm03-foot', mo: 'm03-strut', x: 'prints', car: 'custom', carDraw: carStrut });
  PFA.motif('wobble-v', comp, { nm: 'teetering Vs', desc: 'dark wings held in a shallow V with silver flight feathers, teetering side to side, a tiny red head', fam: 'ripple', gap: 18, g: 'm03-wobv', mo: 'm03-teeter', x: '-', car: 'flutter' });
  PFA.motif('thermal-spiral', comp, { nm: 'thermals', desc: 'a shimmering column of rising heat with a tiny bird circling up inside it', fam: 'ember', gap: 14, g: 'm03-therm', mo: 'm03-thermal', x: 'haze', car: 'loop' });
  PFA.motif('broad-soar', comp, { nm: 'broad soarers', desc: 'very broad rounded mottled wings with a pale under-edge and a fanned barred tail circling slowly', fam: 'slash', gap: 20, g: 'm03-buzz', mo: 'm03-soar', x: '-', car: 'custom', carDraw: carSoar });
  PFA.motif('soar-shadow', comp, { nm: 'soar shadows', desc: 'the cross-shaped shadow of a broad-winged bird sliding flat along the ground, a light rim on it', fam: 'bash', gap: 20, g: 'm03-shadow', mo: 'm03-shadowslide', x: '-', car: 'comet' });
  PFA.motif('talon-grip', comp, { nm: 'talons', desc: 'a feathered leg with three hooked toes reaching out open, closing and clenching', fam: 'slash', gap: 14, g: 'm03-talon', mo: 'm03-clutch', x: '-', car: 'comet' });
  PFA.motif('bob-owl', comp, { nm: 'bobbing owls', desc: 'little round-headed owls on long stilt legs, white brows and yellow eyes, bobbing deep', fam: 'bite', gap: 14, g: 'm03-owl', mo: 'm03-bob', x: '-', car: 'hop' });
  PFA.motif('burrow-hole', comp, { nm: 'burrow mouths', desc: 'sandy-rimmed dark holes with two yellow eyes blinking inside, dust spurting', fam: 'bash', gap: 16, g: 'm03-hole', mo: 'm03-peek', x: 'dust', car: 'tunnel' });
  PFA.motif('snow-gaze', comp, { nm: 'snowy stares', desc: 'round white flecked owl faces with two big yellow eyes that stare, turn and slowly blink', fam: 'sparkle', gap: 16, g: 'm03-gaze', mo: 'm03-stare', x: 'snow', car: 'blink' });
})();
