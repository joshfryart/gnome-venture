/* Motif module, boss batch B2-birds (great-hawk, snow-owl-monarch, frost-owl-regent, storm-eagle): the four boss birds.
   TEMPLATE.md sections 9 and 10.3. 22 motifs, each with its own pixel glyph (ids prefixed B2-) and motion; the four signature motifs have their own
   chain effect (carDraw): the hawk circling high and stooping onto the next piece, the snowy monarch gliding low and dusting snow off its wingtips,
   rime creeping along the edge under the regent's silver circlet, the storm eagle flying over and dropping a lightning bolt on the next piece.
   Glyph coordinates are (a, b): a along the edge tangent, b outward along the normal, so every sprite turns with the edge it sits on.
   fr0() stores the glyph frame in module scratch variables; p()/row()/cl() then plot in (a, b). Glyph draws never nest, so the scratch is safe.
   Nothing is allocated per frame (lookup tables are built once at load); no Math.random / Date: every effect is a stateless function of p.
   Glyphs go through H.glyph so the MAXG budget counts them. Boss birds are drawn a little bigger than small ones (wingspans up to ~23 px) but the
   sprites stay within ~12 px of their anchor so the effect stays within ~22 px of the edge. The wiggle, the outer-edge chain rule, visual-only sound
   lines and the creature-heavy default are untouched (they live in the page). */
(function () {
  var X0 = 0, Y0 = 0, TX = 1, TY = 0, NX = 0, NY = -1, KK = null;
  var YEL = '#f0c838', RUF = '#c8502a', ICE = '#9fdcf4', SILVER = '#dfe6ee', BOLT = '#fff27a', GRASS = '#a4cc5e', GRASSD = '#5e7e34',
    STICK = '#8c6a42', ROCK = '#78736c', RAIN = '#a9c6e6', LEM = '#c89a64';
  var CA = [], CB = [], i0, t0;                                                /* 8-point circle (kite orbit) */
  for (i0 = 0; i0 < 8; i0++) { t0 = i0 / 8 * Math.PI * 2; CA.push(Math.cos(t0)); CB.push(Math.sin(t0)); }
  var WO = [[-4, 3], [-2, 5], [0, 2], [2, 6], [4, 4], [-3, 7], [1, 8], [3, 1], [-1, 4], [5, 6], [-5, 5], [0, 9]];   /* whiteout snow points */
  var ZB = [0, 1, 2, 3, 1, -1, 0, 1, 2, 0, -2, -1, 0];                         /* lightning zigzag: lateral offset per b step */
  var ZC = [0, 2, -1, 2, -2, 1, 0];                                            /* chain bolt: lateral offset per segment */
  var GA = [-2, 0, 2, 0];                                                      /* circlet glint position per frame */
  var TS = [[-1, 1, 0], [0, 0, 0], [1, -1, 0]];                                /* slipper talons: (spread, curl, grip) lateral shift of the tip per toe */

  function fr0(x, y, tx, ty, nx, ny, K) { X0 = x; Y0 = y; TX = tx; TY = ty; NX = nx; NY = ny; KK = K; }
  function p(c, a, b, col) { KK.px(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, col); }
  function row(c, a0, a1, b, col) { for (var a = a0; a <= a1; a++) p(c, a, b, col); }
  function cl(c, a, b0, b1, col) { for (var b = b0; b <= b1; b++) p(c, a, b, col); }
  function disc(c, ca, cb, r, col, rim) { var a, b, d, rr = r * r + 1; for (b = -r; b <= r; b++) for (a = -r; a <= r; a++) { d = a * a + b * b; if (d > rr) continue; p(c, ca + a, cb + b, rim && d >= rr - r - 1 ? rim : col); } }

  /* ---------- shared own-edge composition: the page's themedOwn() with this module's glyph / motion ---------- */
  function comp(c, e, H) {
    var runs = e.runs, mp = e.mp, M = e.M, z = e.z, pr = e.p, pp = pr * mp.spd, Q = H.Q, G = H.G, P = e.P,
      tie = mp.x === 'thread' || mp.lay === 'snare', ri, k, r, len, n, f, ph, sf, bx0, by0, nx, ny, x, y, lx = 0, ly = 0, has;
    for (ri = 0; ri < runs.length; ri++) {
      r = runs[ri]; len = r[1] - r[0]; n = Math.max(1, Math.min(7, Math.round(len / (M.gap || 12)))); if (mp.lay === 'lance') n = Math.min(n, 4); has = false;
      for (k = 0; k < n; k++) {
        f = (k + .5) / n; ph = H.hash(e.seed * 13 + k * 7 + ri * 31);
        H.lay(mp.lay, pr, f, ph, k); H.mot(M.mo, pp, k, ph);
        if (G.vis <= 0 || !H.stip(G.vis, k + ri * 9, pr)) { has = false; continue; }
        sf = G.s - Math.floor(G.s); P.atq(r[0] + len * sf); bx0 = Q.x; by0 = Q.y; nx = Q.nx; ny = Q.ny;
        x = bx0 + nx * G.d - ny * G.t; y = by0 + ny * G.d + nx * G.t - G.up;
        if (mp.x === 'threads') H.ln(c, bx0 + nx, by0 + ny, x, y, 1, e.hi);
        else if (mp.x === 'silk') H.ln(c, bx0 + ny * 9 + nx, by0 - nx * 9 + ny, x, y, 1, e.hi);
        if (tie && has && Math.abs(x - lx) + Math.abs(y - ly) < 30) H.ln(c, lx, ly, x, y, 1, e.hi);
        H.glyph(c, M.g, x, y, z, G.fr, e.col, e.acc, e.hi, -ny, nx, nx, ny); lx = x; ly = y; has = true;
      }
      H.ext(c, mp.x, P, r[0], len, ri, pr, pp, e.col, e.acc, e.hi, e.seed);
    }
  }

  /* ================= glyphs ================= */
  /* --- great hawk (red-tailed grassland hawk) --- */
  PFA.glyph('B2-hawk', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* hawk from above, head to the edge, rufous fan tail: soaring, wings half back, folded stoop, talons thrown */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, W = 8 + w, a, b = 4, sh;
    p(c, 0, 0, A); row(c, -1, 1, 1, C); row(c, -1, 1, 2, C); p(c, -1, 1, Hi); p(c, 1, 1, Hi);
    if (fr === 2) {
      for (b = 3; b <= 8; b++) { sh = b > 6 ? 1 : 0; row(c, -2 + sh, 2 - sh, b, C); }
      cl(c, -2, 3, 6, A); cl(c, 2, 3, 6, A); p(c, 0, 4, Hi); p(c, 0, 5, Hi);
      row(c, -1, 1, 9, RUF); p(c, 0, 10, RUF);
      for (b = 11; b <= 12 + w; b += 2) { p(c, -3, b, Hi); p(c, 3, b + 1, Hi); }   /* speed lines trailing the stoop */
      return;
    }
    cl(c, 0, 3, 7, C); cl(c, -1, 3, 6, C); cl(c, 1, 3, 6, C); p(c, 0, 4, Hi); p(c, -1, 6, A); p(c, 1, 6, A);
    row(c, -1, 1, 8, RUF); row(c, -2, 2, 9, RUF); p(c, -2, 10, RUF); p(c, 0, 10, RUF); p(c, 2, 10, RUF); p(c, 0, 8, A);
    for (a = 2; a <= W; a++) {
      b = fr === 1 ? 4 + ((a - 1) >> 1) : fr === 3 ? 3 + ((a - 1) >> 1) : 4 - (a > W - 2 ? 1 : 0);
      p(c, a, b, C); p(c, -a, b, C);
      if (a < W - 1) { p(c, a, b + 1, a % 3 === 0 ? A : C); p(c, -a, b + 1, a % 3 === 0 ? A : C); }
      if (a < 5 && fr !== 1) { p(c, a, b - 1, Hi); p(c, -a, b - 1, Hi); }
    }
    p(c, W + 1, b, A); p(c, -W - 1, b, A); p(c, W + 1, b + 1, A); p(c, -W - 1, b + 1, A);
    if (fr === 3) { p(c, -1, -1, YEL); p(c, 1, -1, YEL); p(c, -2, -2, A); p(c, 0, -2, A); p(c, 2, -2, A); }
  });
  PFA.glyph('B2-grass', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* meadow grass, a vole in it; talons come down, close, lift the vole out, the grass flicks */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, i, a0, h, tp, b, vb, tb;
    for (i = -1; i <= 1; i++) {
      a0 = i * 4; h = 5 + w + (i === 0 ? 1 : 0); tp = fr === 3 && i !== 0 ? i : 0;
      for (b = 0; b <= h; b++) p(c, a0 + Math.round(tp * b / h), b, b > h - 2 ? GRASS : GRASSD);
    }
    vb = [1, 2, 5, 8][fr & 3]; tb = [9, 4, 7, 10][fr & 3];
    row(c, -1, 1, vb, LEM); row(c, -2, 1, vb + 1, LEM); p(c, 1, vb + 1, A); p(c, -3, vb + 1, A); p(c, -4, vb, A);
    cl(c, 0, tb + 1, tb + 2, YEL); row(c, -1, 1, tb + 3, C); p(c, 0, tb + 4, C);
    p(c, -1, tb, YEL); p(c, 1, tb, YEL); p(c, 0, tb, YEL);
    if (fr === 0) { p(c, -2, tb - 1, A); p(c, 2, tb - 1, A); p(c, 0, tb - 1, A); } else { p(c, -1, tb - 1, A); p(c, 1, tb - 1, A); }
  });
  PFA.glyph('B2-mantle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* the hawk mantling: wings draped down like a tent over the edge, shade under it, eyes flashing over the top */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, W = 7 + w, lift = fr === 1 ? 1 : 0, a, b;
    for (a = -W + 2; a <= W - 2; a += 2) p(c, a, 1 + ((a + fr) & 1), A);
    cl(c, 0, 3, 7, C); cl(c, -1, 4, 6, C); cl(c, 1, 4, 6, C); row(c, -1, 1, 8, C); p(c, 0, 9, C); p(c, 0, 5, Hi);
    if (fr === 3) { p(c, -1, 9, YEL); p(c, 1, 9, YEL); } else { p(c, -1, 9, A); p(c, 1, 9, A); }
    for (a = 2; a <= W; a++) {
      b = Math.max(1, 7 + lift - Math.round((a - 1) * 6 / (W - 1)));
      p(c, a, b, C); p(c, -a, b, C); p(c, a, b + 1, A); p(c, -a, b + 1, A);
      if ((a & 1) === 0) { p(c, a, b - 1, C); p(c, -a, b - 1, C); }
    }
    p(c, W, 0, A); p(c, -W, 0, A); p(c, W + 1, 1, RUF); p(c, -W - 1, 1, RUF);
    if (fr === 2) { p(c, W + 1, 0, A); p(c, -W - 1, 0, A); }
  });
  PFA.glyph('B2-hfoot', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a yellow scaly hawk foot with black talons: spread wide, closing, clenched, a squeeze */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, sp = [3, 2, 1, 1][fr & 3], e;
    cl(c, 0, 4, 8, YEL); p(c, 0, 5, A); p(c, 0, 7, A);
    cl(c, -1, 8, 10 + w, C); cl(c, 1, 8, 10 + w, C); row(c, -1, 1, 11 + w, C); p(c, 0, 9, Hi);
    for (e = -1; e <= 1; e += 2) { p(c, e, 4, YEL); p(c, e * sp, 3, YEL); p(c, e * sp, 2, A); if (fr >= 1) p(c, e * (sp - 1), 1, A); else p(c, e * (sp + 1), 1, A); }
    p(c, 0, 3, YEL); p(c, 0, 2, A); p(c, 0, 1, fr >= 2 ? A : Hi);
    if (fr === 3) { p(c, -4, 3, Hi); p(c, 4, 3, Hi); p(c, -5, 2, Hi); p(c, 5, 2, Hi); }
  });
  PFA.glyph('B2-kite', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a hawk silhouette circling high on a dotted orbit, rufous tail flashing (fr 0..7 = place on the circle) */
    fr0(x, y, tx, ty, nx, ny, K); var r = 4 + (z > 1 ? 1 : 0), i, idx = fr & 7, ca = Math.round(CA[idx] * r), cb = Math.round(6 + CB[idx] * r * .6), fl = idx & 1;
    for (i = 0; i < 8; i++) if (((i + idx) & 1) === 0) p(c, Math.round(CA[i] * (r + 2)), Math.round(6 + CB[i] * (r + 2) * .6), Hi);
    row(c, ca - 3, ca + 3, cb, C); p(c, ca - 4, cb + fl, A); p(c, ca + 4, cb + fl, A); p(c, ca - 3, cb + 1, A); p(c, ca + 3, cb + 1, A);
    p(c, ca, cb + 1, C); p(c, ca, cb - 1, RUF); p(c, ca, cb + 2, A);
  });
  PFA.glyph('B2-gshadow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* the hawk passes over the meadow: its cross shadow slides over the grass, the blades bend away from it */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, a0 = -6 + (fr & 3) * 4, a, h, tp, b, dd;
    row(c, a0 - 4 - w, a0 + 4 + w, 2, A); row(c, a0 - 1, a0 + 1, 1, A); row(c, a0 - 1, a0 + 1, 3, A); p(c, a0, 4, A);
    for (a = -8; a <= 8; a += 3) {
      dd = a - a0; h = 4 + ((a + 9) % 3); tp = Math.abs(dd) < 4 ? (dd < 0 ? -2 : 2) : 0;
      for (b = 0; b <= h; b++) p(c, a + Math.round(tp * b / h), b, b >= h - 1 ? GRASS : GRASSD);
    }
    row(c, a0 - 3, a0 + 3, 9, C); p(c, a0, 10, C); p(c, a0, 8, RUF); p(c, a0 - 4, 10, A); p(c, a0 + 4, 10, A);
  });
  /* --- snow owl monarch (great white snowy owl) --- */
  PFA.glyph('B2-snowy', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the huge white snowy owl, black flecks, yellow eyes, wings spread silent: level, up, down, feathered feet out */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, W = 9 + w, a, b = 5;
    row(c, -1, 1, 0, C); row(c, -2, 2, 1, C); row(c, -2, 2, 2, C); row(c, -2, 2, 3, C); row(c, -1, 1, 4, C);
    p(c, -1, 2, YEL); p(c, 1, 2, YEL); p(c, 0, 1, A);
    row(c, -2, 2, 5, C); row(c, -2, 2, 6, C); row(c, -2, 2, 7, C); row(c, -1, 1, 8, C); p(c, -1, 6, A); p(c, 1, 7, A); p(c, 0, 8, A);
    for (a = 3; a <= W; a++) {
      b = fr === 1 ? 5 + ((a - 2) >> 1) : fr === 2 ? Math.max(2, 5 - ((a - 2) >> 1)) : 5;
      p(c, a, b, C); p(c, -a, b, C);
      if (a < W - 1) { p(c, a, b + 1, a % 3 === 1 ? A : C); p(c, -a, b + 1, a % 3 === 1 ? A : C); }
      if ((a & 1) === 0 && a < W - 2) { p(c, a, b - 1, Hi); p(c, -a, b - 1, Hi); }
    }
    p(c, W + 1, b, A); p(c, -W - 1, b, A);
    if (fr === 3) { p(c, -1, -1, C); p(c, 1, -1, C); p(c, -1, -2, A); p(c, 1, -2, A); p(c, -2, -2, A); p(c, 2, -2, A); }
  });
  PFA.glyph('B2-fwing', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* one long white barred owl wing sweeping, frost crystals shed off its trailing edge */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, L = 9 + w, ang = [.8, .3, -.1, .3][fr & 3], i, b = 2, k, ia, cb;
    cl(c, -1, 1, 4, C); p(c, -1, 5, A);
    for (i = 0; i <= L; i++) { b = 2 + Math.round(i * ang); p(c, i, b, C); p(c, i, b + 1, i % 3 === 1 ? A : C); if (i >= 2 && (i & 1)) p(c, i, b - 1, Hi); }
    p(c, L + 1, b, A); p(c, L + 1, b + 1, A);
    for (k = 0; k < 3; k++) {
      ia = 3 + k * 3; cb = 2 + Math.round(ia * ang) + 3 + ((fr + k) % 3);
      p(c, ia, cb, K.WHITE); p(c, ia - 1, cb, ICE); p(c, ia + 1, cb, ICE); p(c, ia, cb - 1, ICE); p(c, ia, cb + 1, ICE);
    }
  });
  PFA.glyph('B2-slipper', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* the owl's furry white "slipper" foot with black talons: spread, curled, raking (frost scratches), gripping */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, b, hw, k, ta, g = fr & 3, ex = g === 2 ? 1 : 0, sh;
    for (b = 3; b <= 8 + w; b++) { hw = b < 4 || b > 7 + w ? 2 : 3; row(c, -hw, hw, b, C); }
    p(c, -2, 5, Hi); p(c, 1, 6, Hi); p(c, 2, 4, Hi); p(c, -1, 7, Hi);
    for (k = 0; k < 3; k++) {
      ta = (k - 1) * 2; sh = g === 0 ? TS[k][0] : g === 1 ? TS[k][1] : g === 2 ? TS[k][0] : -TS[k][0];
      p(c, ta, 2, A); p(c, ta + sh, 1 - ex, A); if (g !== 1) p(c, ta + sh * 2, -ex, A);
    }
    if (g === 2) { row(c, -4, -2, -2, ICE); row(c, 0, 1, -2, ICE); row(c, 3, 4, -2, ICE); }
  });
  PFA.glyph('B2-hbeak', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a round feathered owl face, dark rim, yellow eyes, the small black beak nips without a sound */
    fr0(x, y, tx, ty, nx, ny, K); var r = 4 + (z > 1 ? 1 : 0), tn = fr === 3 ? 1 : 0;
    disc(c, 0, r + 1, r, C, A);
    p(c, -2 + tn, r + 2, YEL); p(c, -1 + tn, r + 2, YEL); p(c, 1 + tn, r + 2, YEL); p(c, 2 + tn, r + 2, YEL); p(c, -1 + tn, r + 2, A); p(c, 2 + tn, r + 2, A);
    p(c, tn, r + 1, A); p(c, tn, r, A);
    if (fr === 1) { p(c, tn - 1, r - 1, A); p(c, tn + 1, r - 1, A); }
    if (fr === 2) { p(c, tn, r - 1, A); p(c, -3, 1, Hi); p(c, 3, 1, Hi); p(c, -2, 0, Hi); p(c, 2, 0, Hi); }
  });
  PFA.glyph('B2-wprint', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* snow patch; the owl lifts off and leaves fanned wing prints pressed into the snow, a snow puff rising */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, g = fr & 3, e, k, t, pb;
    row(c, -7 - w, 7 + w, 0, C); row(c, -6, 6, 1, C); row(c, -4, 4, 2, C);
    if (g >= 1) for (e = -1; e <= 1; e += 2) for (k = 0; k < 4; k++) for (t = 1; t <= 3; t++) p(c, e * Math.round((2 + k * 1.3) * t / 3 + 1), t === 3 ? 1 + (k & 1) : 1, A);
    if (g === 0) { row(c, -4, 4, 5, C); p(c, 0, 6, C); p(c, -1, 6, YEL); p(c, 1, 6, YEL); }
    if (g >= 2) { pb = g === 2 ? 4 : 6; p(c, -2, pb, K.WHITE); p(c, 2, pb, K.WHITE); p(c, 0, pb + 1, K.WHITE); p(c, -1, pb - 1, Hi); p(c, 1, pb + 2, Hi); row(c, -3, 3, pb + 4, C); p(c, 0, pb + 5, C); }
  });
  PFA.glyph('B2-listen', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a snow mound with a lemming under it; the owl head cocks to listen, sound rings rise, then it plunges */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, g = fr & 3, hb = g === 3 ? 5 : 8, tl = g === 1 ? -1 : g === 2 ? 1 : 0, r;
    row(c, -5 - w, 5 + w, 0, C); row(c, -4, 4, 1, C); row(c, -3, 3, 2, C); row(c, -1, 1, 3, C);
    if (g < 3) { p(c, g - 1, 1, LEM); p(c, g, 1, LEM); }
    if (g === 1 || g === 2) { r = 3 + g; p(c, -r, 1 + g, Hi); p(c, r, 1 + g, Hi); p(c, -r + 1, 2 + g, Hi); p(c, r - 1, 2 + g, Hi); }
    row(c, -2, 2, hb, C); row(c, -2, 2, hb + 1, C); row(c, -1, 1, hb + 2, C);
    p(c, -1 + tl, hb + 1, YEL); p(c, 1 + tl, hb + 1, YEL); p(c, tl, hb, A);
    if (g === 3) { p(c, -3, 3, K.WHITE); p(c, 3, 3, K.WHITE); p(c, -4, 2, K.WHITE); p(c, 4, 4, K.WHITE); p(c, 0, 4, Hi); }
  });
  /* --- frost owl regent (smaller owl, ice-blue edge, thin silver crown) --- */
  PFA.glyph('B2-circlet', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a small round owl head rimmed in ice blue, a thin silver crown on top, a glint walking along the points */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, r = 3, cb = 2 * r + 2, g = fr & 3;
    disc(c, 0, r + 1, r, C, Hi);
    p(c, -1, r + 2, YEL); p(c, 1, r + 2, YEL); p(c, 0, r + 1, A);
    row(c, -2 - w, 2 + w, cb, SILVER); p(c, -2, cb + 1, SILVER); p(c, 0, cb + 1, SILVER); p(c, 2, cb + 1, SILVER); p(c, 0, cb + 2, SILVER);
    p(c, GA[g], cb + 1 + (g & 1), K.WHITE);
    if (g === 3) { p(c, 0, cb + 3, K.WHITE); p(c, -1, cb + 2, ICE); p(c, 1, cb + 2, ICE); }
  });
  PFA.glyph('B2-rimeclaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a frost-crusted owl talon scratching: a rime line grows along the edge where it rakes */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, g = fr & 3, a, k;
    cl(c, 0, 5, 9 + w, C); p(c, -1, 8, C); p(c, 1, 8, C); row(c, -1, 1, 9 + w, C);
    row(c, -1, 1, 4, A);
    for (k = -1; k <= 1; k++) { p(c, k * 2, 3, A); p(c, k * 2 + (g >= 2 ? 0 : k), 2, A); p(c, k * 2, 1, Hi); }
    p(c, -2, 4, ICE); p(c, 2, 4, ICE); p(c, 0, 6, ICE); p(c, -1, 7, K.WHITE);
    for (a = -4; a <= -4 + g * 3; a++) p(c, a, 0, Hi);
    if (g === 3) { p(c, -3, -1, K.WHITE); p(c, 1, -1, K.WHITE); p(c, 4, -1, ICE); }
  });
  PFA.glyph('B2-whiteout', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a pale wing that blurs into driving snow: seen, half lost, gone (only snow), back */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, g = fr & 3, a, b, k;
    if (g !== 2) for (a = -6 - w; a <= 6 + w; a++) { if (g !== 0 && (a & 1)) continue; b = 3 + Math.round(Math.abs(a) * .4); p(c, a, b, C); if (Math.abs(a) < 5) p(c, a, b + 1, a % 3 === 0 ? A : C); }
    for (k = 0; k < WO.length; k++) { if (g === 0 && k > 4) break; p(c, WO[(k + g * 3) % WO.length][0], WO[k][1], k & 1 ? K.WHITE : Hi); }
  });
  PFA.glyph('B2-iceeye', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* two pale owl eyes with ice-blue irises; the glare streams out and freezes into icicle tips that break off */
    fr0(x, y, tx, ty, nx, ny, K); var g = fr & 3, L = [2, 4, 6, 5][g] + (z > 1 ? 1 : 0), e, ca, k, tb;
    for (e = -1; e <= 1; e += 2) {
      ca = e * 3; row(c, ca - 1, ca + 1, 1, C); row(c, ca - 2, ca + 2, 2, C); row(c, ca - 2, ca + 2, 3, C); row(c, ca - 1, ca + 1, 4, C);
      p(c, ca, 2, Hi); p(c, ca + e, 2, Hi); p(c, ca, 3, Hi); p(c, ca + e, 3, A);
      for (k = 0; k < L; k++) p(c, ca + e * Math.round(k * .3), 5 + k, k & 1 ? Hi : K.WHITE);
      tb = 5 + L; if (g === 3) { p(c, ca + e * 3, tb + 1, Hi); p(c, ca - e, tb + 2, ICE); } else { p(c, ca + e * Math.round(L * .3), tb, K.WHITE); p(c, ca + e * Math.round(L * .3) - 1, tb - 1, ICE); p(c, ca + e * Math.round(L * .3) + 1, tb - 1, ICE); }
    }
  });
  PFA.glyph('B2-fern', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a frost fern spelled out on the edge: an ice stem grows with paired fronds, a white curl at the tip */
    fr0(x, y, tx, ty, nx, ny, K); var g = fr & 3, L = [3, 6, 9, 11][g] + (z > 1 ? 1 : 0), b, j, k;
    for (b = 0; b <= L; b++) p(c, 0, b, Hi);
    for (b = 2; b < L; b += 2) { k = Math.min(3, (L - b) >> 1) + 1; for (j = 1; j <= k; j++) { p(c, -j, b + j, C); p(c, j, b + j - 1, C); } p(c, -k - 1, b + k, A); }
    p(c, 0, L + 1, K.WHITE); p(c, 1, L + 1, K.WHITE); p(c, 1, L, K.WHITE);
  });
  /* --- storm eagle --- */
  PFA.glyph('B2-eagle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a storm-grey eagle on broad fingered wings, yellow hooked beak: gliding, wings up, folded dive with a crackle, talons and a spark */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, W = 10 + w, a, b = 4, f, sh;
    p(c, 0, 0, YEL); p(c, -1, 1, YEL); row(c, -1, 1, 2, C); row(c, -1, 1, 3, C); p(c, -1, 2, A); p(c, 1, 2, A);
    if (fr === 2) {
      for (b = 4; b <= 9; b++) { sh = b > 7 ? 1 : 0; row(c, -2 + sh, 2 - sh, b, C); }
      cl(c, -2, 4, 7, A); cl(c, 2, 4, 7, A); row(c, -1, 1, 10, A);
      p(c, -3, 10, Hi); p(c, -2, 11, Hi); p(c, -3, 12, Hi); p(c, 3, 11, Hi); p(c, 3, 13, Hi);   /* crackle trailing the dive */
      return;
    }
    cl(c, 0, 4, 8, C); cl(c, -1, 4, 7, C); cl(c, 1, 4, 7, C); row(c, -2, 2, 9, A); row(c, -2, 2, 10, C); p(c, 0, 10, A);
    for (a = 2; a <= W; a++) {
      b = fr === 1 ? 4 + ((a - 1) >> 1) : 4;
      p(c, a, b - 1, A); p(c, -a, b - 1, A); p(c, a, b, C); p(c, -a, b, C); p(c, a, b + 1, C); p(c, -a, b + 1, C);
      if ((a & 1) === 0 && a > 3) { p(c, a, b + 2, K.WHITE); p(c, -a, b + 2, K.WHITE); }
    }
    for (f = 0; f < 4; f += 2) { p(c, W + 1, b - 1 + f, A); p(c, -W - 1, b - 1 + f, A); p(c, W + 2, b + f, A); p(c, -W - 2, b + f, A); }
    if (fr === 3) { p(c, -1, -1, YEL); p(c, 1, -1, YEL); p(c, W, b + 3, Hi); p(c, W - 1, b + 4, Hi); p(c, W, b + 5, Hi); }
  });
  PFA.glyph('B2-gale', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* one great grey wing beating, white gale curls spinning off it, rain driven slantwise */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, L = 8 + w, g = fr & 3, ang = [.7, .3, -.1, -.1][g], i, b = 2, k, ca, cb, ra, rb;
    cl(c, -1, 2, 5, A);
    for (i = 0; i <= L; i++) { b = 2 + Math.round(i * ang); p(c, i, b, C); p(c, i, b + 1, C); if (i > 2 && (i & 1)) p(c, i, b + 2, K.WHITE); if (i % 3 === 0) p(c, i, b - 1, A); }
    p(c, L + 1, b, A); p(c, L + 1, b + 2, A); p(c, L + 2, b + 1, A);
    if (g >= 1) for (k = 0; k < 2; k++) { ca = -4 - k * 3; cb = 4 + k * 3 + g; p(c, ca, cb, K.WHITE); p(c, ca + 1, cb + 1, K.WHITE); p(c, ca + 2, cb, K.WHITE); p(c, ca + 1, cb - 1, K.WHITE); p(c, ca - 1, cb - 1, Hi); p(c, ca - 2, cb - 1, Hi); }
    for (k = 0; k < 3; k++) { ra = -6 + k * 5 + g; rb = 10 - ((g * 2 + k * 3) % 5); p(c, ra, rb, RAIN); p(c, ra + 1, rb - 1, RAIN); p(c, ra + 2, rb - 2, RAIN); }
  });
  PFA.glyph('B2-bolt', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a yellow eagle foot clutching a forked lightning bolt: dim, flash, fork, white afterglow */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, g = fr & 3, col = g === 0 ? Hi : g === 3 ? K.WHITE : BOLT, b, pa, fb = 6;
    for (b = 1; b <= 10 + w; b++) { pa = ZB[b % ZB.length]; p(c, pa, b, col); if (g === 1 || g === 2) p(c, pa + 1, b, col); }
    if (g === 2) { p(c, -1, 7, BOLT); p(c, -2, 8, BOLT); p(c, -3, 8, BOLT); p(c, 3, 3, BOLT); p(c, 4, 2, BOLT); }
    p(c, -2, fb, YEL); p(c, 3, fb, YEL); p(c, -2, fb + 1, YEL); p(c, 3, fb + 1, YEL); p(c, -1, fb + 2, YEL); p(c, 2, fb + 2, YEL); p(c, 0, fb + 3, YEL); p(c, 1, fb + 3, YEL);
    p(c, -1, fb - 1, A); p(c, 2, fb - 1, A); p(c, -3, fb, A); p(c, 4, fb, A);
    row(c, -1, 2, fb + 4, C); row(c, 0, 1, fb + 5, C); p(c, 0, fb + 6, A);
    if (g === 3) { p(c, -3, 2, Hi); p(c, 3, 9, Hi); p(c, -2, 11, Hi); }
  });
  PFA.glyph('B2-eyrie', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the eyrie: a stick nest on a crag, the eagle sitting tall gripping the rim, head turning; a twig torn off by the wind */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, g = fr & 3, hd = (g & 1) ? 1 : -1, a;
    row(c, -6 - w, 6 + w, 0, ROCK); row(c, -5, 5, 1, ROCK); p(c, -6, 1, A); p(c, 4, 0, A);
    for (a = -5; a <= 5; a++) p(c, a, 2 + ((a + 1) & 1), STICK);
    row(c, -4, 4, 3, STICK); p(c, -6, 4, STICK); p(c, 6, 3, STICK); p(c, -5, 4, STICK); p(c, 5, 4, STICK); p(c, -3, 2, A); p(c, 2, 3, A);
    cl(c, 0, 4, 9, C); cl(c, -1, 4, 8, C); cl(c, 1, 4, 8, C); cl(c, -2, 4, 7, A); cl(c, 2, 4, 7, A); p(c, 0, 6, Hi);
    row(c, -1, 1, 10, C); row(c, -1, 1, 11, C); p(c, hd * 2, 11, YEL); p(c, hd * 2, 10, YEL); p(c, hd, 11, A);
    p(c, -1, 3, YEL); p(c, 1, 3, YEL);
    if (g === 3) { p(c, 7, 6, STICK); p(c, 8, 7, STICK); row(c, -9, -6, 8, K.WHITE); row(c, -8, -6, 10, Hi); }
  });
  PFA.glyph('B2-cloud', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a rolling storm cloud, dark underside, rain slanting to the edge, a flicker of lightning inside */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, g = fr & 3, k, ra, rb;
    disc(c, -4, 7, 2, C, null); disc(c, 4, 7, 2, C, null); disc(c, 0, 8 + (g & 1), 3 + w, C, null);
    row(c, -5, 5, 5, A); row(c, -6, -3, 6, A); row(c, 3, 6, 6, A);
    for (k = 0; k < 4; k++) { ra = -5 + k * 3 + (g & 1); rb = 3 - ((g + k) % 3); p(c, ra, rb, RAIN); p(c, ra - 1, rb - 1, RAIN); }
    if (g === 2) { p(c, 0, 4, BOLT); p(c, 1, 3, BOLT); p(c, 0, 2, BOLT); p(c, 1, 1, BOLT); }
    if (g === 3) { p(c, -1, 8, K.WHITE); p(c, 1, 9, Hi); }
  });

  /* ================= motions (mutate the scratch G; fr picks the glyph frame) ================= */
  PFA.motion('B2-stoop', function (G, pp, k, ph) { var w = (pp * 1.4 + ph) % 1; G.fr = w < .35 ? 0 : w < .55 ? 1 : w < .85 ? 2 : 3; if (G.fr === 0) G.t += Math.sin(pp * 5 + k) * 2; if (G.fr === 2) G.d += (1 - (w - .55) / .3) * 4; });   /* soar, fold, stoop, strike */
  PFA.motion('B2-snatch', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .3 ? 0 : w < .5 ? 1 : w < .8 ? 2 : 3; });                                                /* talons down, close, lift, gone */
  PFA.motion('B2-mantle', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 3 + ph * 2) + k) & 3; });                                                                              /* wings tent, lift, spread fingers, eyes */
  PFA.motion('B2-grip', function (G, pp, k, ph) { var w = (pp * 2.2 + ph) % 1; G.fr = w < .3 ? 0 : w < .5 ? 1 : w < .8 ? 2 : 3; G.d += G.fr === 0 ? 1 : 0; });                  /* reach open, close, clench, squeeze */
  PFA.motion('B2-circle', function (G, pp, k) { G.fr = (Math.floor(pp * 12) + k * 3) & 7; });                                                                                     /* round and round, high up */
  PFA.motion('B2-sweep', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; G.s += pp * .15; });                                                                          /* the shadow slides over the grass */
  PFA.motion('B2-hushglide', function (G, pp, k) { G.t += Math.sin(pp * 3 + k) * 2; G.up += Math.sin(pp * 2 + k); G.fr = G.u > .6 && G.u < 1 ? 3 : [0, 1, 0, 2][(Math.floor(pp * 4) + k) & 3]; });   /* slow silent glide */
  PFA.motion('B2-sweepwing', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2 + ph) % 1) * 4); });                                                                             /* one wing sweeps through */
  PFA.motion('B2-rake', function (G, pp, k, ph) { var w = (pp * 2.4 + ph) % 1; G.fr = w < .3 ? 0 : w < .5 ? 1 : w < .8 ? 2 : 3; G.d += G.fr === 2 ? 1 : 0; });                  /* spread, curl, rake, grip */
  PFA.motion('B2-nip', function (G, pp, k, ph) { G.fr = [0, 0, 1, 2, 0, 3][(Math.floor(pp * 6 + ph * 3) + k) % 6]; });                                                            /* stare, open, nip, turn */
  PFA.motion('B2-stamp', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 2) + k) & 3; });                                                                              /* sit, lift, print, puff */
  PFA.motion('B2-listen', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.fr = w < .4 ? 0 : w < .6 ? 1 : w < .85 ? 2 : 3; });                                            /* still, cock left, right, plunge */
  PFA.motion('B2-regal', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; G.up += G.fr === 1 ? 1 : 0; });                                                               /* a small royal nod, the crown glints */
  PFA.motion('B2-scratch', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 3 + ph) % 1) * 4); });                                                                              /* rake, rake, rime grows */
  PFA.motion('B2-whirl', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 2) + k) & 3; G.t += Math.sin(pp * 6 + k) * 2; });                                            /* lost in the snow and back */
  PFA.motion('B2-glare', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 3) + k) & 3; });                                                                              /* glare grows, freezes, breaks */
  PFA.motion('B2-grow', function (G, pp, k) { G.fr = Math.min(3, Math.floor(pp * 5 + k * .3)); });                                                                                 /* the frost fern spreads and stays */
  PFA.motion('B2-thunder', function (G, pp, k, ph) { var w = (pp * 1.3 + ph) % 1; G.fr = w < .4 ? 0 : w < .55 ? 1 : w < .85 ? 2 : 3; G.d += G.fr === 2 ? 2 : 0; });             /* glide, wings up, dive, strike */
  PFA.motion('B2-gust', function (G, pp, k) { G.fr = (Math.floor(pp * 7) + k) & 3; G.t += G.fr * .5; });                                                                         /* beat after beat, the gale curls */
  PFA.motion('B2-flash', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 9 + ph * 4) + k) & 3; });                                                                              /* dim, flash, fork, afterglow */
  PFA.motion('B2-perch', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 3 + ph * 2) + k) & 3; });                                                                              /* sits tight, looks round */
  PFA.motion('B2-billow', function (G, pp, k) { G.fr = (Math.floor(pp * 4) + k) & 3; G.t += Math.sin(pp * 3 + k) * 1.5; });                                                       /* the cloud rolls */

  /* ================= custom chain effects (along the OUTER loop from e.a over e.d, eased e.hh) ================= */
  function carStoop(c, e, H) {          /* the hawk circles high over the start, then folds and stoops along the outer edge onto the next piece, speed lines behind */
    var P = e.P, Q = H.Q, s, h, j, fr, ox = 0, zz = e.z > 1 ? 1 : e.z;
    if (e.hh < .45) { P.atq(e.a + e.d * e.hh * .3); ox = Math.cos(e.p * 14) * 4; h = 13 + Math.sin(e.p * 14) * 2; fr = 0;
      H.px(c, Q.x + Q.nx * 2 - Q.ny * ox, Q.y + Q.ny * 2 + Q.nx * ox, e.acc); }
    else { s = (e.hh - .45) / .55; P.atq(e.a + e.d * (.135 + .865 * s)); h = 13 * (1 - s) + 4; fr = s > .88 ? 3 : 2;
      for (j = 1; j <= 3; j++) H.px(c, Q.x + Q.nx * (h + 6 + j * 2), Q.y + Q.ny * (h + 6 + j * 2), e.hi); }
    H.glyph(c, 'B2-hawk', Q.x + Q.nx * h - Q.ny * ox, Q.y + Q.ny * h + Q.nx * ox, zz, fr, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  function carMonarch(c, e, H) {        /* the snowy monarch glides low and silent to the next piece, its wingtips dusting a little snow off the edge; feet out on arrival */
    var P = e.P, Q = H.Q, k, u, h, fr;
    for (k = 1; k <= 4; k++) { u = e.hh - k * .06; if (u < 0) break; P.atq(e.a + e.d * u); h = 2 + ((k * 3 + Math.floor(e.p * 20)) % 5); H.px(c, Q.x + Q.nx * h, Q.y + Q.ny * h, H.WHITE); }
    P.atq(e.a + e.d * e.hh); h = 7 + Math.sin(e.hh * Math.PI) * 3; fr = e.hh > .88 ? 3 : [0, 0, 1, 2][Math.floor(e.p * 5) & 3];
    H.glyph(c, 'B2-snowy', Q.x + Q.nx * h, Q.y + Q.ny * h, e.z > 1 ? 1 : e.z, fr, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  function carRime(c, e, H) {           /* rime creeps along the outer edge from piece to piece, ice crystals every few px, the crowned regent riding the tip */
    var P = e.P, Q = H.Q, u, i = 0, b, s;
    for (u = 0; u <= e.hh; u += .03, i++) {
      P.atq(e.a + e.d * u); b = 2 + (i % 3);
      H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, e.hi);
      if (i % 3 === 0) { H.px(c, Q.x + Q.nx * b, Q.y + Q.ny * b, H.WHITE); H.px(c, Q.x + Q.nx * (b + 1) - Q.ny, Q.y + Q.ny * (b + 1) + Q.nx, e.hi); }
    }
    P.atq(e.a + e.d * e.hh); s = Math.floor(e.p * 16) & 3;
    H.glyph(c, 'B2-circlet', Q.x + Q.nx * 4, Q.y + Q.ny * 4, 0, s, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  function carThunder(c, e, H) {        /* the storm eagle flies high along the edge; on arrival a forked bolt cracks down from it onto the next piece */
    var P = e.P, Q = H.Q, h = 13, j, x0, y0, x1, y1, lo, fl, sx, sy, nx, ny, bx, by;
    P.atq(e.a + e.d * Math.min(1, e.hh * 1.1)); sx = Q.x; sy = Q.y; nx = Q.nx; ny = Q.ny;
    H.glyph(c, 'B2-eagle', sx + nx * h, sy + ny * h, e.z > 1 ? 1 : e.z, e.hh > .8 ? 3 : Math.floor(e.p * 6) & 1, e.col, e.acc, e.hi, -ny, nx, nx, ny);
    if (e.hh > .78) {
      fl = Math.floor(e.p * 20) & 1; P.atq(e.a + e.d); bx = Q.x; by = Q.y;
      x0 = sx + nx * (h - 3); y0 = sy + ny * (h - 3);
      for (j = 1; j < ZC.length; j++) {
        lo = ZC[(j + fl) % ZC.length]; x1 = x0 + (bx + nx * 2 - x0) / (ZC.length - j) - ny * lo; y1 = y0 + (by + ny * 2 - y0) / (ZC.length - j) + nx * lo;
        H.ln(c, x0, y0, x1, y1, 1, fl ? e.hi : H.WHITE); x0 = x1; y0 = y1;
      }
      if (fl) H.plus(c, bx + nx * 2, by + ny * 2, 3, 1, H.WHITE);
    }
  }

  /* ================= motifs ================= */
  function M(name, meta) { PFA.motif(name, comp, meta); }
  /* great hawk */
  M('hawk-stoop', { nm: 'hawk stoop', desc: 'a red-tailed hawk seen from above, head to the edge, rufous fan tail: soaring, folding its wings back, a teardrop stoop with speed lines, talons thrown forward; the chain is the hawk circling high and stooping onto the next piece', fam: 'thrust', gap: 20, g: 'B2-hawk', mo: 'B2-stoop', x: '-', car: 'custom', carDraw: carStoop });
  M('meadow-pluck', { nm: 'meadow pluck', desc: 'three meadow grass blades with a vole in them; yellow talons come down, close on it and lift it out, the grass flicking back', fam: 'bite', gap: 16, g: 'B2-grass', mo: 'B2-snatch', x: '-', car: 'hop' });
  M('pinion-mantle', { nm: 'mantling wings', desc: 'the hawk mantling over its catch: wings draped down like a tent to the edge, a stipple of shade under them, rufous tips, eyes flashing over the top', fam: 'shield', gap: 18, g: 'B2-mantle', mo: 'B2-mantle', x: '-', car: 'train' });
  M('hawk-talon', { nm: 'hawk talons', desc: 'a yellow scaly hawk foot with black talons spread wide, closing, clenched, squeeze marks', fam: 'web', gap: 14, g: 'B2-hfoot', mo: 'B2-grip', x: '-', car: 'comet' });
  M('sky-circle', { nm: 'high circles', desc: 'a small hawk silhouette with a rufous tail circling high on a dotted orbit', fam: 'puff', gap: 16, g: 'B2-kite', mo: 'B2-circle', x: '-', car: 'loop' });
  M('grass-shadow', { nm: 'grass shadow', desc: 'the hawk passing over the meadow: its cross-shaped shadow slides over the grass and the blades bend away from it', fam: 'puff', gap: 18, g: 'B2-gshadow', mo: 'B2-sweep', x: '-', car: 'blink' });
  /* snow owl monarch */
  M('monarch-glide', { nm: 'snowy monarch', desc: 'a huge white snowy owl with black flecks and yellow eyes, wings spread wide, gliding without a sound, feathered feet out at the end; the chain is the owl gliding low to the next piece, its wingtips dusting snow off the edge', fam: 'shield', gap: 22, g: 'B2-snowy', mo: 'B2-hushglide', x: '-', car: 'custom', carDraw: carMonarch });
  M('frost-wing', { nm: 'frost wing', desc: 'one long white barred owl wing sweeping through, frost crystals shed off its trailing edge', fam: 'sparkle', gap: 16, g: 'B2-fwing', mo: 'B2-sweepwing', x: '-', car: 'flutter' });
  M('slipper-talon', { nm: 'slipper talons', desc: 'the owl\'s furry white "slipper" foot with black talons spreading, curling, raking frost scratches, gripping', fam: 'thrust', gap: 16, g: 'B2-slipper', mo: 'B2-rake', x: '-', car: 'comet' });
  M('hush-beak', { nm: 'hush beaks', desc: 'a round feathered owl face with a dark rim and yellow eyes; the small black beak opens and nips without a sound', fam: 'bite', gap: 16, g: 'B2-hbeak', mo: 'B2-nip', x: '-', car: 'hop' });
  M('wing-print', { nm: 'wing prints', desc: 'a snow patch where the owl lifts off and leaves fanned wing prints pressed into the snow, a snow puff rising', fam: 'puff', gap: 18, g: 'B2-wprint', mo: 'B2-stamp', x: '-', car: 'hop' });
  M('snow-listen', { nm: 'listening', desc: 'a snow mound with a lemming moving under it; the owl head above cocks left and right to listen, sound rings rise, then it plunges into the snow', fam: 'ripple', gap: 18, g: 'B2-listen', mo: 'B2-listen', x: '-', car: 'blink' });
  /* frost owl regent */
  M('regent-circlet', { nm: 'silver circlet', desc: 'a small round owl head rimmed in ice blue wearing a thin silver crown, a glint walking along its points; the chain is rime creeping along the edge with the crowned head riding the tip', fam: 'sparkle', gap: 14, g: 'B2-circlet', mo: 'B2-regal', x: '-', car: 'custom', carDraw: carRime });
  M('rime-claw', { nm: 'rime claws', desc: 'a frost-crusted owl talon raking, a rime line growing along the edge where it scratches', fam: 'slash', gap: 14, g: 'B2-rimeclaw', mo: 'B2-scratch', x: '-', car: 'comet' });
  M('whiteout', { nm: 'whiteout', desc: 'a pale wing that blurs into driving snow: seen, half lost, gone into the snow, back again', fam: 'puff', gap: 16, g: 'B2-whiteout', mo: 'B2-whirl', x: 'snow', car: 'cloud' });
  M('ice-glare', { nm: 'ice glare', desc: 'two pale owl eyes with ice-blue irises; the glare streams out and freezes into icicle tips that break off', fam: 'sparkle', gap: 18, g: 'B2-iceeye', mo: 'B2-glare', x: '-', car: 'blink' });
  M('frost-fern', { nm: 'frost ferns', desc: 'frost ferns spelled along the edge like window frost: an ice stem grows with paired fronds and a white curl at the tip', fam: 'shield', gap: 10, g: 'B2-fern', mo: 'B2-grow', x: '-', car: 'trail' });
  /* storm eagle */
  M('thunder-eagle', { nm: 'thunder eagle', desc: 'a storm-grey eagle on broad fingered white-edged wings with a yellow hooked beak: gliding, wings up, a folded dive with a crackle, talons out and a spark; the chain is the eagle flying high to the next piece and a forked bolt cracking down onto it', fam: 'thrust', gap: 22, g: 'B2-eagle', mo: 'B2-thunder', x: '-', car: 'custom', carDraw: carThunder });
  M('gale-wing', { nm: 'gale wings', desc: 'one great grey wing beating, white gale curls spinning off it and rain driven slantwise', fam: 'puff', gap: 16, g: 'B2-gale', mo: 'B2-gust', x: '-', car: 'flutter' });
  M('bolt-claw', { nm: 'bolt claws', desc: 'a yellow eagle foot clutching a zigzag lightning bolt: dim, flash, fork, white afterglow', fam: 'shock', gap: 14, g: 'B2-bolt', mo: 'B2-flash', x: '-', car: 'zig' });
  M('eyrie-nest', { nm: 'eyrie', desc: 'a stick nest on a grey crag, the eagle sitting tall and gripping the rim, head turning, a twig torn away by the wind', fam: 'shield', gap: 18, g: 'B2-eyrie', mo: 'B2-perch', x: '-', car: 'train' });
  M('storm-cloud', { nm: 'storm clouds', desc: 'a rolling storm cloud with a dark underside, rain slanting to the edge and a flicker of lightning inside', fam: 'shock', gap: 16, g: 'B2-cloud', mo: 'B2-billow', x: '-', car: 'cloud' });
})();
