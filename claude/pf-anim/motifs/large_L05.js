/* Motif module, large batch L05 (lichen-reindeer, red-stag, gorse-beast, moss-golem, lichen-golem, peat-golem, coral-golem, emperor-scorpion, giant-bumblebee).
   TEMPLATE.md sections 9 and 10.3. 31 motifs, each with its own pixel glyph (ids prefixed L05-) and motion; four have their own chain effect (carDraw):
   a gorse fuse that flares bloom by bloom, a stag's bellow rolling along in rings, a drifting bank of bog steam, a bumblebee's wobbly flight path.
   Glyph coordinates are (a, b): a along the edge tangent, b outward along the normal, so every sprite turns with the edge it sits on. A glyph stores its
   frame in module scratch variables with fr0(); p()/s() then plot in (a, b). Glyph draws never nest, so the scratch is safe; nothing is allocated per
   frame (the constant tables below are built once at load), there is no Math.random / Date, every effect is a stateless function of p.
   Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy
   default are untouched (they live in the page). Large creatures are drawn a little bigger than small ones (up to ~12 px) and stay within ~22 px of the edge. */
(function () {
  var X0 = 0, Y0 = 0, TX = 1, TY = 0, NX = 0, NY = -1, KK = null;
  var SNOW = '#f4f8ff', STONE = '#a29e92', STONED = '#5e5a52', CAPS = '#a8703a', GORSEG = '#6f8f34', CHAR = '#3a2a1a', FLAME = '#f08a2a',
    REEDG = '#93a856', WATER = '#5c7a70', BARN = '#ece4d2', VENOM = '#c8f0a8', HONEY = '#e8a317', POLL = '#f0a030', BEEBK = '#1a1408';
  var T0 = [0, -.16, .16, 0], T1 = [6, 3, 7, 7], T2 = [0, .5, -.5, 0], T3 = [0, 1, 0, -1], T4 = [0, 1, 2, 1], T5 = [1, 3, 5, 4], T6 = [6, 9, 7], T7 = [3, 2, 0, 1], T8 = [.4, .8, 1.15, .9], T9 = [3, 2.5, 2, 1.5], T10 = [2, 3, 3, 2];   /* per-frame lookup tables (built once, never allocated in a draw) */
  var CUP = [], SINT = [], i0;                                          /* tables built once: lichen rosette lobe offsets, a sine table for sway */
  for (i0 = 0; i0 < 12; i0++) { CUP.push(Math.cos(i0 * Math.PI / 6)); CUP.push(Math.sin(i0 * Math.PI / 6)); }
  for (i0 = 0; i0 < 16; i0++) SINT.push(Math.sin(i0 * Math.PI / 8));

  function fr0(x, y, tx, ty, nx, ny, K) { X0 = x; Y0 = y; TX = tx; TY = ty; NX = nx; NY = ny; KK = K; }
  function p(c, a, b, col) { KK.px(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, col); }
  function s(c, a, b, w, col) { KK.sq(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, w, col); }
  function row(c, a0, a1, b, col) { for (var a = a0; a <= a1; a++) p(c, a, b, col); }
  function cl(c, a, b0, b1, col) { for (var b = b0; b <= b1; b++) p(c, a, b, col); }

  /* ---------- shared own-edge composition: the page's themedOwn() with this module's glyph / motion (glyphs capped at 7 per run) ---------- */
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

  /* ================= glyphs (fr 0..3, z 0..2) ================= */
  /* --- lichen reindeer --- */
  PFA.glyph('L05-lichrack', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* reindeer head under a lichen-crusted rack: two long beams, a brow shovel, crust spots, flakes coming off */
    fr0(x, y, tx, ty, nx, ny, K); var b, la, sw = T0[fr], L = 9 + (z > 1 ? 1 : 0);
    row(c, -1, 1, 0, C); row(c, -1, 1, 1, C); row(c, -1, 1, 2, C); p(c, -1, 1, A); p(c, 1, 1, A); p(c, 0, -1, A);
    for (b = 3; b <= L; b++) { la = 1.4 + Math.sin((b - 3) / (L - 3) * 2.3) * 3.2; p(c, -la + sw * b, b, C); p(c, la + sw * b, b, C); }
    p(c, -1 + sw * 3, 4, C); p(c, -2 + sw * 4, 5, C); p(c, -1 + sw * 5, 5, C);                         /* the brow shovel */
    la = 1.4 + Math.sin(3 / (L - 3) * 2.3) * 3.2; p(c, -la - 1 + sw * 6, 7, C); p(c, la + 1 + sw * 6, 7, C); p(c, -la - 2 + sw * 6, 8, Hi); p(c, la + 2 + sw * 6, 8, Hi);
    la = 1.4 + Math.sin(1 / (L - 3) * 2.3) * 3.2; p(c, -la + sw * 4, 4, Hi); p(c, la + sw * 4, 4, Hi); p(c, -la - 1 + sw * 4, 4, Hi);   /* lichen crust */
    la = 1.4 + Math.sin(4 / (L - 3) * 2.3) * 3.2; p(c, la + sw * 7, 7, Hi); p(c, la + 1 + sw * 7, 6, Hi);
    if (fr === 3) { p(c, -5, L + 1, Hi); p(c, 4, L + 2, Hi); p(c, 6, L - 2, Hi); p(c, -6, L - 3, Hi); }
  });
  PFA.glyph('L05-reinrun', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a reindeer side-on trotting in the herd wheel: pale neck ruff, small rack, legs reaching and gathering */
    fr0(x, y, tx, ty, nx, ny, K); var g = fr & 1, w = z > 1 ? 1 : 0;
    row(c, -4, 2, 3, C); row(c, -4, 3, 4, C); row(c, -3, 3, 5, C); p(c, -5, 5, A);
    row(c, 3, 4, 6, Hi); row(c, 4, 5, 7, C); p(c, 6, 7, C); p(c, 6, 6, A); p(c, 5, 8, A);              /* ruff, head, muzzle */
    p(c, 4, 9, C); p(c, 3, 10, C); p(c, 5, 10, C); p(c, 3, 11 + w, Hi); p(c, 6, 11, Hi);             /* small rack */
    if (g) { cl(c, -4, 0, 2, C); cl(c, -2, 0, 2, A); cl(c, 1, 0, 2, C); cl(c, 3, 0, 2, A); }
    else { p(c, -3, 2, C); p(c, -4, 1, C); p(c, -5, 0, A); p(c, 2, 2, C); p(c, 3, 1, C); p(c, 4, 0, A); p(c, -1, 2, C); p(c, 0, 1, A); }
    if (fr >> 1) { p(c, -6, 1, SNOW); p(c, -7, 2, SNOW); }
  });
  PFA.glyph('L05-crater', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a hoof paws a crater in the snow crust: raised, scraping (snow flying), the crater open on green-grey lichen, a sprig lifted */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, hb = T1[fr];
    row(c, -5 - w, -2, 0, SNOW); row(c, 2, 5 + w, 0, SNOW); row(c, -5 - w, -3, 1, SNOW); row(c, 3, 5 + w, 1, SNOW); p(c, -5, 2, K.WHITE); p(c, 5, 2, K.WHITE);
    if (fr >= 2) { row(c, -1, 1, 0, Hi); p(c, -2, 1, Hi); p(c, 2, 1, Hi); p(c, 0, 1, A); } else row(c, -1, 1, 0, SNOW);
    cl(c, -1, hb, hb + 3, C); cl(c, 1, hb, hb + 3, C); p(c, -1, hb - 1, A); p(c, 1, hb - 1, A); p(c, 0, hb + 3, C);   /* cloven hoof and leg */
    if (fr === 1) { p(c, -4, 4, SNOW); p(c, 4, 5, K.WHITE); p(c, -6, 6, K.WHITE); p(c, 5, 3, SNOW); }
    if (fr === 3) { p(c, 3, 3, Hi); p(c, 4, 4, Hi); p(c, 3, 5, Hi); p(c, 5, 5, Hi); }
  });
  /* --- lichen rosette (lichen golem, lent to the reindeer) --- */
  PFA.glyph('L05-rosette', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a foliose lichen rosette spreading ring by ring: lobed rim, a darker centre, little fruiting cups */
    fr0(x, y, tx, ty, nx, ny, K); var i, r = 2 + fr * .8 + (z > 1 ? .7 : 0), cb = r + 1;
    s(c, 0, cb, Math.max(2, Math.round(r * 1.4)), C);
    for (i = 0; i < 12; i++) { p(c, CUP[i * 2] * r, cb + CUP[i * 2 + 1] * r, (i & 1) ? Hi : C); if ((i + fr) % 3 === 0) p(c, CUP[i * 2] * (r + 1), cb + CUP[i * 2 + 1] * (r + 1), Hi); }
    p(c, 0, cb, A); p(c, -1, cb + 1, A);
    if (fr >= 2) { p(c, 1, cb - 1, K.WHITE); p(c, -1, cb - 1, A); }
  });
  /* --- red stag --- */
  PFA.glyph('L05-royal', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a red stag head-on under a wide royal rack: two arching beams, three tines each, a crown at the tops, a clash star */
    fr0(x, y, tx, ty, nx, ny, K); var b, la, sh = T2[fr], w = z > 1 ? 1 : 0;
    row(c, -1, 1, 0, C); row(c, -1, 1, 1, C); row(c, -1, 1, 2, C); p(c, 0, -1, A); p(c, -1, 2, A); p(c, 1, 2, A); p(c, -2, 2, C); p(c, 2, 2, C);
    for (b = 3; b <= 9 + w; b++) { la = 2 + Math.sin((b - 3) / (6 + w) * 2.0) * (4 + w) + sh * (b - 3) * .3; p(c, -la, b, C); p(c, la, b, C);
      if (b === 4 || b === 6) { p(c, -la - 1, b + 1, Hi); p(c, la + 1, b + 1, Hi); } }
    p(c, -3 - w + sh, 10 + w, Hi); p(c, -4 - w + sh, 11 + w, Hi); p(c, 3 + w + sh, 10 + w, Hi); p(c, 4 + w + sh, 11 + w, Hi); p(c, -2 + sh, 10 + w, Hi); p(c, 2 + sh, 10 + w, Hi);
    if (fr === 3) { p(c, 0, 12 + w, K.WHITE); p(c, -1, 13 + w, K.WHITE); p(c, 1, 13 + w, K.WHITE); p(c, 0, 14 + w, Hi); p(c, -2, 12 + w, Hi); p(c, 2, 12 + w, Hi); }
  });
  PFA.glyph('L05-roar', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a stag bellowing side-on: thick neck stretched up, mane, jaw dropped open, breath steam and roar arcs ahead */
    fr0(x, y, tx, ty, nx, ny, K); var o = fr & 1 ? 1 : 0, w = z > 1 ? 1 : 0;
    row(c, -2, 1, 0, C); row(c, -2, 1, 1, C); row(c, -1, 2, 2, C); row(c, -1, 2, 3, C); row(c, 0, 3, 4, C); p(c, -2, 2, A); p(c, -1, 4, A);   /* shaggy neck */
    row(c, 1, 4, 5, C); row(c, 2, 5, 6, C); p(c, 3, 6, A); p(c, 1, 7, C); p(c, 0, 8, Hi); p(c, 2, 8, Hi);     /* head, short rack stubs */
    p(c, 6, 6, C); p(c, 6, 5 - o, A); p(c, 5, 4 - o, A);                                               /* muzzle and dropped jaw */
    if (fr >= 1) { p(c, 8, 6, K.WHITE); p(c, 9, 5, Hi); p(c, 8, 4, Hi); }
    if (fr >= 2) { p(c, 10, 8, Hi); p(c, 11, 6, Hi); p(c, 10, 3, Hi); p(c, 12, 5, K.WHITE); }
    if (fr === 3) { p(c, 13, 9 + w, Hi); p(c, 14, 6, Hi); p(c, 13, 2, Hi); }
  });
  PFA.glyph('L05-bracken', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* an autumn bracken frond unrolling: a crozier that uncurls into golden pinnae */
    fr0(x, y, tx, ty, nx, ny, K); var b, L = 6 + fr + (z > 1 ? 1 : 0);
    for (b = 0; b <= L; b++) p(c, (fr < 2 ? .15 : .05) * b, b, b < 2 ? A : C);
    for (b = 2; b < L; b += 2) { p(c, -1, b, Hi); p(c, -2, b + 1, Hi); p(c, 1, b, Hi); p(c, 2, b + 1, Hi); if (fr >= 2) { p(c, -3, b + 1, C); p(c, 3, b + 1, C); } }
    if (fr < 3) { p(c, 1, L + 1, C); p(c, 2, L, C); p(c, 2, L - 1, Hi); p(c, 1, L - 1, A); }
    else { p(c, 0, L + 1, Hi); p(c, -1, L + 2, Hi); }
  });
  /* --- gorse beast --- */
  PFA.glyph('L05-gorse', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a spiny gorse sprig whose yellow pea flowers flare up like flame, then char and spit seed sparks */
    fr0(x, y, tx, ty, nx, ny, K); var b, L = 6 + (z > 1 ? 1 : 0);
    for (b = 0; b <= L; b++) { p(c, 0, b, GORSEG); if (b > 0 && (b & 1)) { p(c, -2, b + 1, GORSEG); p(c, 2, b, GORSEG); } }
    if (fr === 0) { p(c, -1, 3, C); p(c, 1, 5, C); p(c, 0, L + 1, C); }
    else if (fr === 1) { s(c, -1, 3, 2, C); s(c, 1, 5, 2, C); s(c, 0, L + 1, 2, C); p(c, 0, L + 2, Hi); }
    else if (fr === 2) { s(c, -1, 3, 2, C); s(c, 1, 5, 2, C); s(c, 0, L + 2, 3, C); cl(c, 0, L + 3, L + 5, Hi); p(c, -1, L + 4, FLAME); p(c, 1, L + 3, FLAME); p(c, -2, 5, Hi); p(c, 2, 7, FLAME); p(c, 0, L + 6, K.WHITE); }
    else { p(c, -1, 3, CHAR); p(c, 1, 5, CHAR); p(c, 0, L + 1, CHAR); p(c, -2, L + 4, FLAME); p(c, 2, L + 6, Hi); p(c, 1, L + 8, FLAME); p(c, -1, L + 3, A); }
  });
  PFA.glyph('L05-spinebush', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a dense gorse clump: green spines bristling in a fan, yellow flowers tucked between them */
    fr0(x, y, tx, ty, nx, ny, K); var i, b, a, L = 5 + (z > 1 ? 1 : 0) + (fr & 1);
    row(c, -3, 3, 0, A);
    for (i = -3; i <= 3; i++) for (b = 1; b <= L - (i < 0 ? -i : i) * .5; b++) { a = i * b / L * 1.2; p(c, a, b, b > L - 2 ? A : GORSEG); }
    p(c, -2, 3, C); p(c, 1, 2, C); p(c, 2, 4, C); p(c, -1, 5, C); p(c, 0, 3, Hi);
    if (fr >= 2) { p(c, -3, 2, C); p(c, 3, 3, Hi); }
  });
  PFA.glyph('L05-sunbloom', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a gorse pea flower opening in the sun: bud, banner petal up, sun rays, a bee landing */
    fr0(x, y, tx, ty, nx, ny, K); var o = fr >= 1 ? 1 : 0;
    cl(c, 0, 0, 2, GORSEG); p(c, -1, 1, GORSEG);
    if (fr === 0) { s(c, 0, 4, 2, C); p(c, 0, 5, A); }
    else { row(c, -2, 2, 5, C); row(c, -2, 2, 6, C); row(c, -1, 1, 7, C); p(c, 0, 8, Hi); row(c, -1, 1, 4, C); p(c, -3, 4, C); p(c, 3, 4, C); p(c, 0, 5, FLAME); }
    if (fr >= 2) { p(c, -4, 8, Hi); p(c, -5, 9, Hi); p(c, 4, 8, Hi); p(c, 5, 9, Hi); p(c, 0, 10, Hi); p(c, 0, 11, K.WHITE); p(c, -5, 6, Hi); p(c, 5, 6, Hi); }
    if (fr === 3) { p(c, 3, 10, BEEBK); p(c, 4, 10, C); p(c, 5, 10, BEEBK); p(c, 4, 11, K.WHITE); }
    if (o && z > 1) { p(c, -3, 6, C); p(c, 3, 6, C); }
  });
  /* --- moss golem --- */
  PFA.glyph('L05-boulder', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a stone fist with a cap of moss: knuckles out, moss hanging off it, impact cracks on the punch */
    fr0(x, y, tx, ty, nx, ny, K); var b, w = z > 1 ? 1 : 0;
    for (b = 1; b <= 5 + w; b++) row(c, -3 - w, 3 + w, b, STONE);
    row(c, -3 - w, 3 + w, 6 + w, STONED); p(c, -1, 6 + w, STONE); p(c, 1, 6 + w, STONE); p(c, -3 - w, 1, STONED); p(c, 3 + w, 1, STONED);   /* knuckle line */
    row(c, -2, 2, 0, STONED); p(c, -4 - w, 3, STONED); p(c, -4 - w, 4, STONE);                         /* wrist, thumb */
    row(c, -3 - w, 1, 5 + w, C); row(c, -2, 0, 4 + w, C); p(c, 2, 5 + w, C); p(c, -3 - w, 4, C); p(c, -3 - w, 3, C); p(c, -1, 3, Hi); p(c, -4 - w, 2, C);   /* moss cap */
    if (fr === 1) { p(c, 4 + w, 4, STONED); p(c, 3 + w, 3, STONED); }
    if (fr === 2) { p(c, 0, 8 + w, K.WHITE); p(c, -2, 8 + w, Hi); p(c, 2, 8 + w, Hi); p(c, -1, 9 + w, Hi); p(c, 1, 9 + w, Hi); p(c, -4, 8 + w, STONE); p(c, 4, 9 + w, STONE); }
    if (fr === 3) { p(c, -5, 7, STONE); p(c, 5, 6, C); }
  });
  PFA.glyph('L05-mosscloak', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a thick moss mat hanging off the golem: cushion tufts, spore stalks with brown capsules nodding */
    fr0(x, y, tx, ty, nx, ny, K); var a, h, sw = (fr - 1.5) * .4, L = 4 + (z > 1 ? 1 : 0);
    for (a = -4; a <= 4; a++) { h = L - ((a + 4) % 3 === 1 ? 0 : 1); cl(c, a, 0, h - 1, C); p(c, a, h, (a + fr) % 3 ? C : Hi); }
    row(c, -4, 4, 0, A);
    for (a = -3; a <= 3; a += 3) { cl(c, a + sw, L + 1, L + 4, CAPS); p(c, a + sw * 1.6, L + 5, CAPS); p(c, a + sw * 1.6 + 1, L + 5, A); }
  });
  PFA.glyph('L05-sprout', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* moss regrowing: a green cushion, three spore stalks shooting up, a capsule popping a puff of spores */
    fr0(x, y, tx, ty, nx, ny, K); var a, h = 2 + fr * 1.5 + (z > 1 ? 1 : 0), w = z > 1 ? 1 : 0;
    row(c, -3 - w, 3 + w, 0, C); row(c, -2 - w, 2 + w, 1, C); p(c, -1, 1, Hi); p(c, 2, 1, Hi); p(c, -3, 0, A);
    for (a = -2; a <= 2; a += 2) { cl(c, a, 2, Math.round(h - (a === 0 ? 0 : 1)), CAPS); p(c, a, Math.round(h - (a === 0 ? 0 : 1)) + 1, a === 0 ? Hi : CAPS); }
    if (fr === 3) { p(c, -1, h + 3, Hi); p(c, 1, h + 4, Hi); p(c, 0, h + 5, K.WHITE); p(c, -2, h + 5, Hi); p(c, 2, h + 3, Hi); }
  });
  /* --- lichen golem --- */
  PFA.glyph('L05-scree', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* an angular scree slab with lichen spots, tumbling end over end (four orientations) */
    fr0(x, y, tx, ty, nx, ny, K); var b, w = z > 1 ? 1 : 0, sk = T3[fr], hw = fr & 1 ? 2 : 3;
    for (b = 0; b <= 4 + w; b++) row(c, -hw - w + Math.round(sk * b * .5), hw + w + Math.round(sk * b * .5) - (b > 3 ? 1 : 0), b, C);
    row(c, -hw - w, hw + w, 0, A); p(c, hw + w + sk * 2, 3, A); p(c, -hw - w + sk * 2, 4 + w, A);
    p(c, -1 + sk, 2, Hi); p(c, 0 + sk, 2, Hi); p(c, -1 + sk, 3, Hi); p(c, 2 + sk, 1, Hi); p(c, 1 + sk * 2, 4, STONED);
  });
  PFA.glyph('L05-flake', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a sharp flake of crusted rock flipping as it flies, point first, crust on one face */
    fr0(x, y, tx, ty, nx, ny, K); var b, L = 6 + (z > 1 ? 1 : 0), wd;
    for (b = 0; b <= L; b++) { wd = fr & 1 ? 1 : Math.round((L - b) * .35); row(c, -wd, wd, b, (fr === 2 && b < 3) ? A : C); }
    p(c, 0, L + 1, K.WHITE); p(c, 0, 2, Hi); if (!(fr & 1)) { p(c, -1, 1, Hi); p(c, 1, 3, Hi); }
    if (fr === 3) { p(c, -2, L, Hi); p(c, 2, L - 1, Hi); }
  });
  PFA.glyph('L05-cup', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a pixie-cup lichen: grey stalk, a cup on top filling with rain drops, brimming over in a glint */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0;
    cl(c, 0, 0, 4, C); p(c, -1, 0, A); p(c, 1, 0, A);
    p(c, -3 - w, 7, C); p(c, -2 - w, 6, C); p(c, -1, 5, C); p(c, 1, 5, C); p(c, 2 + w, 6, C); p(c, 3 + w, 7, C); p(c, 0, 5, A);
    if (fr >= 1) row(c, -1, 1, 6, K.DEW);
    if (fr >= 2) row(c, -2 - w, 2 + w, 7, K.DEW);
    if (fr < 3) { p(c, 0, 10 - fr, K.DEW); p(c, 0, 11 - fr, K.WHITE); }
    else { p(c, -4 - w, 8, K.WHITE); p(c, 4 + w, 8, K.WHITE); p(c, 0, 9, Hi); p(c, -5 - w, 6, K.DEW); p(c, 5 + w, 6, K.DEW); }
  });
  /* --- peat golem --- */
  PFA.glyph('L05-turf', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a stack of cut peat turves, fibres and root threads in them, the top turf slumping sideways */
    fr0(x, y, tx, ty, nx, ny, K); var o = T4[fr], w = z > 1 ? 1 : 0;
    row(c, -4 - w, 4 + w, 0, A); row(c, -4 - w, 4 + w, 1, C); row(c, -4 - w, 4 + w, 2, C); p(c, -2, 1, A); p(c, 2, 2, A);
    row(c, -4 + o, 3 + o, 3, A); row(c, -4 + o, 3 + o, 4, C); row(c, -3 + o, 3 + o, 5, C); p(c, -1 + o, 4, A); p(c, 1 + o, 5, A);
    p(c, -5 - w, 2, Hi); p(c, -6 - w, 3, Hi); p(c, 5 + w, 1, Hi); p(c, 4 + o, 5, Hi);
    if (fr === 2) { p(c, 5 + w, 4, C); p(c, 6 + w, 3, A); }
  });
  PFA.glyph('L05-bogfist', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a fist of wet peat heaving up out of a bog pool, fingers clawing, mud dripping back */
    fr0(x, y, tx, ty, nx, ny, K); var h = T5[fr] + (z > 1 ? 1 : 0), b, w = z > 1 ? 1 : 0;
    row(c, -5 - w, 5 + w, 0, WATER); p(c, -3, 0, Hi); p(c, 4, 0, Hi); row(c, -4, 4, -1, A);
    for (b = 1; b <= h; b++) row(c, -2, 2, b, C);
    p(c, -1, Math.max(1, h - 1), A);
    if (fr === 3) { row(c, -2, 2, h + 1, C); p(c, -1, h + 1, A); p(c, 1, h + 1, A); }
    else { cl(c, -2, h + 1, h + 2, C); cl(c, 0, h + 1, h + 3, C); cl(c, 2, h + 1, h + 2, C); p(c, -3, h, C); }
    p(c, 3, Math.max(1, h - 2), C); p(c, 3, Math.max(0, h - 4), C); p(c, -3, 1, C);
    if (fr >= 2) { p(c, -4, 2, Hi); p(c, 4, 1, C); }
  });
  PFA.glyph('L05-reed', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the golem's reed hair: three reeds of different height, brown seed heads, swaying and bristling */
    fr0(x, y, tx, ty, nx, ny, K); var i, b, a0, L, sw = (fr - 1.5) * .22;
    for (i = 0; i < 3; i++) { a0 = (i - 1) * 2.5; L = T6[i] + (z > 1 ? 1 : 0);
      for (b = 0; b <= L; b++) p(c, a0 + sw * b, b, b < 1 ? A : REEDG);
      cl(c, a0 + sw * (L + 2), L + 1, L + 3, C); p(c, a0 + sw * (L + 2) + 1, L + 2, C); p(c, a0 + sw * (L + 4), L + 4, A); }
    if (fr === 3) p(c, 4, 11, Hi);
  });
  PFA.glyph('L05-steam', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a crack in the peat breathing steam: curling wisps rising and thinning */
    fr0(x, y, tx, ty, nx, ny, K); var i, b, a;
    row(c, -3, -1, 0, C); row(c, 1, 3, 0, C); p(c, 0, 0, A); p(c, 0, -1, A); p(c, -4, 0, A); p(c, 4, 0, A);
    for (i = 0; i < 8; i++) { b = 1 + i * 1.4; a = Math.sin(i * .9 + fr * 1.57) * (1 + i * .3); p(c, a, b, i < 3 ? K.WHITE : Hi); if (i > 2 && (i + fr) % 2) p(c, a + 1, b, Hi); }
    if (z > 1) { p(c, 2, 9, Hi); p(c, -2, 10, Hi); }
  });
  /* --- coral golem --- */
  PFA.glyph('L05-coral', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a branching pink coral, white polyps extending and retracting at the tips */
    fr0(x, y, tx, ty, nx, ny, K); var e = fr === 1 || fr === 2 ? 1 : 0, w = z > 1 ? 1 : 0;
    cl(c, 0, 0, 4, C); cl(c, 1, 0, 1, C);
    p(c, -1, 4, C); p(c, -2, 5, C); p(c, -3, 6, C); cl(c, -3, 7, 8 + w, C); p(c, -1, 6, C); cl(c, -1, 7, 7 + w, C);
    p(c, 1, 5, C); p(c, 2, 6, C); cl(c, 2, 7, 9 + w, C); p(c, 3, 7, C); p(c, 4, 8, C);
    p(c, -3, 9 + w + e, Hi); p(c, -1, 8 + w + e, Hi); p(c, 2, 10 + w + e, Hi); p(c, 5, 9 + e, Hi);
    if (e) { p(c, -4, 10 + w, K.WHITE); p(c, -2, 10 + w, K.WHITE); p(c, 1, 11 + w, K.WHITE); p(c, 3, 11 + w, K.WHITE); }
    p(c, 0, 2, A); p(c, 2, 8, A);
  });
  PFA.glyph('L05-anemone', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a sea anemone: a stout column, a crown of tentacles swaying in the swell, a sting flash at a tip */
    fr0(x, y, tx, ty, nx, ny, K); var i, b, a0, sw = SINT[(fr * 4) & 15] * .35, L = 5 + (z > 1 ? 1 : 0);
    row(c, -2, 2, 0, A); row(c, -2, 2, 1, C); row(c, -2, 2, 2, C); row(c, -3, 3, 3, C); p(c, -1, 2, Hi);
    for (i = -3; i <= 3; i++) { a0 = i * 1.1; for (b = 1; b <= L - (i < 0 ? -i : i) * .4; b++) p(c, a0 + i * b * .25 + sw * b, 3 + b, b > L - 2 ? Hi : C); }
    if (fr === 3) { p(c, 3 + sw * 4, 9, K.WHITE); p(c, 4 + sw * 4, 10, K.WHITE); p(c, 2 + sw * 4, 10, Hi); }
  });
  PFA.glyph('L05-barnacle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a barnacle cone welded to the coral: wall plates, the lid opening and feathery cirri combing out, snapping shut */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, i;
    row(c, -4 - w, 4 + w, 0, BARN); row(c, -3 - w, 3 + w, 1, BARN); row(c, -3, 3, 2, BARN); row(c, -2, 2, 3, BARN); p(c, -2, 1, A); p(c, 1, 2, A); p(c, -4, 0, C);
    if (fr === 0 || fr === 3) { row(c, -1, 1, 4, A); if (fr === 3) { p(c, -2, 4, K.WHITE); p(c, 2, 4, K.WHITE); } }
    else { p(c, -1, 4, A); p(c, 1, 4, A); for (i = 0; i < 4; i++) { p(c, -1 - i * .7 * fr, 5 + i, C); p(c, 1 + i * .7 * fr, 5 + i, C); p(c, 0, 5 + i, i === 3 ? Hi : C); } }
    p(c, 5 + w, 0, C); p(c, -5 - w, 1, C);
  });
  /* --- emperor scorpion: black glossy bodies outlined in their pale UV glow --- */
  PFA.glyph('L05-eclaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* the thick knobbly pedipalp claw: black, glowing rim, granules; open, closing, clamped shut with a star, recoiling */
    fr0(x, y, tx, ty, nx, ny, K); var b, op = T7[fr], w = z > 1 ? 1 : 0;
    for (b = 0; b <= 5 + w; b++) row(c, -2 - (b > 1 && b < 5 ? 1 : 0), 2 + (b > 1 && b < 5 ? 1 : 0), b, A);
    cl(c, -4, 2, 4, C); cl(c, 4, 2, 4, C); p(c, -3, 1, C); p(c, 3, 1, C); p(c, -3, 5, C); p(c, 3, 5, C); row(c, -1, 1, -1, C);   /* glowing rim of the hand */
    p(c, -1, 2, Hi); p(c, 1, 3, Hi); p(c, 0, 4, Hi);
    for (b = 6 + w; b <= 10 + w; b++) { p(c, -1 - op * .5 - (b === 10 + w ? 0 : 1), b, C); p(c, 1 + op * .5 + (b === 6 + w ? 1 : 0), b, C); }   /* fixed and moving finger */
    p(c, -1 - op * .5, 11 + w, Hi); p(c, 1 + op * .5, 11 + w, Hi);
    if (fr === 2) { p(c, 0, 12 + w, K.WHITE); p(c, -2, 12 + w, Hi); p(c, 2, 12 + w, Hi); p(c, 0, 13 + w, Hi); p(c, -1, 11 + w, K.WHITE); p(c, 1, 11 + w, K.WHITE); }
  });
  PFA.glyph('L05-tail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the metasoma arching over: five glowing segments, a bulb and curved sting, a venom bead swelling and dropping */
    fr0(x, y, tx, ty, nx, ny, K); var i, ang, a, b, R = 5 + (z > 1 ? 1 : 0), arch = T8[fr];
    for (i = 0; i < 5; i++) { ang = Math.PI * .5 - i * arch * .45; a = -2 + Math.cos(ang) * R * (i ? 1 : .2) * .9; b = Math.sin(ang) * R * .3 + i * 1.6;
      s(c, a, b, 2, A); p(c, a - 1, b, C); p(c, a + 1, b + 1, C); }
    ang = Math.PI * .5 - 5 * arch * .45; a = -2 + Math.cos(ang) * R * .9; b = Math.sin(ang) * R * .3 + 8;
    s(c, a, b, 3, C); p(c, a, b, A); p(c, a + 2, b - 1, Hi); p(c, a + 3, b - 2, K.WHITE);
    if (fr === 2) { p(c, a + 3, b - 3, VENOM); }
    if (fr === 3) { p(c, a + 3, b - 4, VENOM); p(c, a + 3, b - 6, VENOM); p(c, a + 4, b - 6, K.WHITE); }
  });
  PFA.glyph('L05-plates', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* glossy armour plates folding over each other like shingles, a glint sliding across them */
    fr0(x, y, tx, ty, nx, ny, K); var i, a, bb, sp = T9[fr], hw = 4 + (z > 1 ? 1 : 0);
    for (i = 0; i < 4; i++) { bb = i * sp; row(c, -hw + i * .5, hw - i * .5, bb + 1, A); row(c, -hw + i * .5, hw - i * .5, bb + 2, A); row(c, -hw + i * .5 + 1, hw - i * .5 - 1, bb + 3, C);
      p(c, -hw + i * .5, bb + 2, C); p(c, hw - i * .5, bb + 2, C); }
    a = -hw + fr * 2.5; p(c, a, 3 + fr, K.WHITE); p(c, a + 1, 3 + fr, Hi);
  });
  PFA.glyph('L05-scorp', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a whole emperor scorpion from above, black with a glowing outline: claws forward, tail curled, legs scuttling */
    fr0(x, y, tx, ty, nx, ny, K); var g = fr & 1, w = z > 1 ? 1 : 0;
    row(c, -1, 1, 0, A); row(c, -2, 2, 1, A); row(c, -2, 2, 2, A); row(c, -1, 1, 3, A); p(c, -3, 1, C); p(c, 3, 1, C); p(c, -3, 2, C); p(c, 3, 2, C);
    p(c, -2, 4, C); p(c, -3, 5, C); p(c, -4, 6, C); p(c, -3, 7, Hi); p(c, -5, 7, Hi); p(c, 2, 4, C); p(c, 3, 5, C); p(c, 4, 6, C); p(c, 3, 7, Hi); p(c, 5, 7, Hi);   /* claws */
    p(c, 0, -1, C); p(c, 0, -2, C); p(c, 1, -3, C); p(c, 2, -3, C); p(c, 2, -2, Hi);                              /* curled tail */
    p(c, -3 - g, 0, C); p(c, 3 + g, 0, C); p(c, -3 + g, 3, C); p(c, 3 - g, 3, C);                                 /* legs */
    if (w) { p(c, -4, 3, C); p(c, 4, 3, C); }
    if (fr >> 1) p(c, 0, 2, Hi);
  });
  /* --- giant bumblebee --- */
  PFA.glyph('L05-bumble', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a huge round furry bumblebee: yellow band, black band, white tail, fuzz, tiny blurred wings; squashed flat on a bump */
    fr0(x, y, tx, ty, nx, ny, K); var sq = fr === 3 ? 1 : 0, w = z > 1 ? 1 : 0, b, hw;
    for (b = 1; b <= 6 + w - sq; b++) { hw = (b === 1 || b === 6 + w - sq) ? 2 + sq : 3 + sq + w;
      row(c, -hw, -2, b, Hi); row(c, -1, 1, b, BEEBK); row(c, 2, hw, b, C); }
    row(c, 4 + sq + w, 5 + sq + w, 3, BEEBK); row(c, 4 + sq + w, 5 + sq + w, 4, BEEBK); p(c, 6 + sq + w, 3, A);                 /* head */
    p(c, -4 - sq - w, 2, Hi); p(c, 2, 7 + w - sq, C); p(c, -2, 0, Hi); p(c, 3, 0, C);                       /* fuzz */
    if (fr === 1 || fr === 2) { p(c, -1, 8 + w, K.WHITE); p(c, 0, 9 + w, K.WHITE); p(c, 1, 8 + w, K.WHITE); } else { p(c, -2, 7 + w, K.WHITE); p(c, 1, 8 + w, K.WHITE); }
    if (sq) { p(c, -6 - w, 1, Hi); p(c, 6 + w, 1, Hi); p(c, -7 - w, 3, Hi); p(c, 7 + w, 5, Hi); }
  });
  PFA.glyph('L05-fuzz', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the thick fuzz coat: banded pile standing up, then smoothing flat, pollen grains clinging */
    fr0(x, y, tx, ty, nx, ny, K); var a, b, L = (fr & 1 ? 4 : 5) + (z > 1 ? 1 : 0), lean = (fr >> 1) ? .3 : -.3;
    for (a = -4; a <= 4; a++) for (b = 0; b <= L - ((a + 9) % 2); b++) p(c, a + lean * b * .5, b, (a === -1 || a === 0) ? BEEBK : (a > 0 ? C : Hi));
    p(c, -3, L + 1, POLL); p(c, 2, L, POLL); p(c, 4, L - 1, POLL);
  });
  PFA.glyph('L05-pollen', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a hind leg with a fat orange pollen basket, puffing grains that hang in the air */
    fr0(x, y, tx, ty, nx, ny, K); var r = T10[fr] + (z > 1 ? 1 : 0), i;
    cl(c, 0, 0, 3, BEEBK); p(c, 1, 3, BEEBK); s(c, 0, 4 + r * .5, r + 1, POLL); p(c, -1, 4, C); cl(c, 1, 4 + r, 6 + r, BEEBK);
    for (i = 0; i < 5; i++) if ((i + fr) % 2 === 0 || fr === 2) p(c, CUP[i * 4] * (r + 2 + fr), 5 + r * .5 + CUP[i * 4 + 1] * (r + 2 + fr), i & 1 ? C : POLL);
  });
  PFA.glyph('L05-barb', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a barbed sting with an amber bead of honey on the point, swelling and dropping off */
    fr0(x, y, tx, ty, nx, ny, K); var b, L = 6 + (z > 1 ? 1 : 0);
    row(c, -2, 2, 0, C); row(c, -1, 1, 1, BEEBK); row(c, -2, 2, 2, C); row(c, -1, 1, 3, BEEBK);          /* banded tip of the abdomen */
    for (b = 4; b <= L + 3; b++) p(c, 0, b, BEEBK);
    p(c, -1, 6, BEEBK); p(c, 1, 7, BEEBK); p(c, -1, 8, A); p(c, 1, 9, A); p(c, 0, L + 4, Hi);          /* barbs */
    if (fr === 1) s(c, 0, L + 5, 2, HONEY);
    if (fr === 2) { s(c, 0, L + 5, 3, HONEY); p(c, -1, L + 5, K.WHITE); }
    if (fr === 3) { p(c, 0, L + 5, HONEY); s(c, 0, L + 8, 2, HONEY); }
  });

  /* ================= motions (mutate the scratch G; pp = time x speed) ================= */
  PFA.motion('L05-antlersweep', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .35 ? 0 : u < .55 ? 1 : u < .8 ? 2 : 3; G.t += (u < .55 ? -1 : 1) * 1.5; });   /* the rack swings left then right, shedding crust */
  PFA.motion('L05-wheel', function (G, pp, k, ph) { var an = pp * 6 + k * 1.3 + ph; G.t += Math.cos(an) * 3; G.d += Math.sin(an) * 2; G.fr = (Math.floor(pp * 12) + k) & 3; });   /* the herd circles round */
  PFA.motion('L05-paw', function (G, pp, k, ph) { var u = (pp * 2.4 + ph) % 1; G.fr = u < .3 ? 0 : u < .55 ? 1 : u < .8 ? 2 : 3; });                                         /* raise, scrape, open, lift a sprig */
  PFA.motion('L05-spread', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4 + ph * 1.5 + (k & 1))) & 3; G.t += Math.sin(pp * 2 + k) * .5; });              /* the rosette grows ring by ring */
  PFA.motion('L05-clash', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1;                                                                                              /* lower the rack, toss, clash */
    if (u < .4) { G.fr = u < .2 ? 1 : 2; G.d -= 1.5; } else if (u < .6) { G.fr = 0; G.d += 5 * (u - .4) / .2 - 1.5; } else if (u < .75) { G.fr = 3; G.d += 4; } else { G.fr = 0; G.d += 4 * (1 - (u - .75) / .25); } });
  PFA.motion('L05-bellow', function (G, pp, k, ph) { var u = (pp * 1.5 + ph) % 1; G.fr = u < .25 ? 0 : u < .5 ? 1 : u < .75 ? 2 : 3; G.up += u > .25 ? 1 : 0; });              /* neck stretches, the roar rolls out */
  PFA.motion('L05-unfurl', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4.5 + ph)); G.t += Math.sin(pp * 4 + k) * 1.2; });                                    /* crozier uncurls, frond sways */
  PFA.motion('L05-flare', function (G, pp, k, ph) { var u = (pp * 2.2 + ph + k * .13) % 1; G.fr = u < .25 ? 0 : u < .45 ? 1 : u < .75 ? 2 : 3; G.up += G.fr === 2 ? 1 : 0; });  /* bud, bloom, flare, char */
  PFA.motion('L05-prickle', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; });                                                                                   /* the clump bristles */
  PFA.motion('L05-bask', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 5 + ph * 1.5)); G.up += Math.sin(pp * 3 + k) * .8; });                               /* opens to the sun, a bee lands */
  PFA.motion('L05-punch', function (G, pp, k, ph) { var u = (pp * 1.8 + ph) % 1;                                                                                            /* wind up, punch, crack, settle */
    if (u < .35) { G.fr = 1; G.d -= 2 * u / .35; } else if (u < .5) { G.fr = 0; G.d += 7 * (u - .35) / .15 - 2; } else if (u < .7) { G.fr = 2; G.d += 5; } else { G.fr = 3; G.d += 5 * (1 - (u - .7) / .3); } });
  PFA.motion('L05-drape', function (G, pp, k) { G.fr = (Math.floor(pp * 4) + k) & 3; G.t += Math.sin(pp * 2.5 + k) * .6; });                                              /* the mat sways, capsules nod */
  PFA.motion('L05-grow', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4 + ph * 1.2 + (k % 2) * .5)); });                                                     /* stalks shoot up, a capsule pops */
  PFA.motion('L05-tumble', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 9 + ph * 4) + k) & 3; G.up += Math.abs(Math.sin((pp * 4.5 + ph) * Math.PI)) * 3; G.t += Math.sin(pp * 9 + k) * .6; });   /* end over end */
  PFA.motion('L05-spin', function (G, pp, k) { G.fr = (Math.floor(pp * 14) + k) & 3; });                                                                                    /* the flake flips as it flies */
  PFA.motion('L05-fillcup', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4.5 + ph * 1.2)); });                                                               /* rain falls in, the cup brims */
  PFA.motion('L05-slump', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 3.5 + ph)); G.up -= G.fr === 2 ? 1 : 0; });                                           /* the top turf slides and settles */
  PFA.motion('L05-grab', function (G, pp, k, ph) { var u = (pp * 1.7 + ph) % 1; G.fr = u < .25 ? 0 : u < .5 ? 1 : u < .8 ? 2 : 3; });                                      /* heaves up out of the bog and closes */
  PFA.motion('L05-reedsway', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; G.t += Math.sin(pp * 3 + k * .7) * .7; });                                         /* reeds sway in the wind */
  PFA.motion('L05-vent', function (G, pp, k) { G.fr = (Math.floor(pp * 7) + k) & 3; G.up += (pp * 6 + k) % 1 * 2; });                                                       /* steam curls up */
  PFA.motion('L05-polyp', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k * 2) & 3; G.t += Math.sin(pp * 2 + k) * .5; });                                            /* polyps open and close */
  PFA.motion('L05-swell', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; G.t += Math.sin(pp * 3 + k * 1.1) * 1.4; });                                           /* tentacles sway in the swell */
  PFA.motion('L05-comb', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 3) + k) & 3; });                                                                         /* lid opens, cirri comb, shut */
  PFA.motion('L05-clamp', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .35 ? 0 : u < .5 ? 1 : u < .75 ? 2 : 3; if (G.fr === 2) G.d += 2; });            /* open wide, snap shut */
  PFA.motion('L05-arch', function (G, pp, k, ph) { var u = (pp * 1.6 + ph) % 1; G.fr = u < .3 ? 0 : u < .55 ? 1 : u < .8 ? 2 : 3; });                                        /* the tail arches over, venom drips */
  PFA.motion('L05-fold', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4 + ph)); });                                                                          /* plates fold shut */
  PFA.motion('L05-scurry', function (G, pp, k) { G.fr = (Math.floor(pp * 14) + k) & 3; G.t += Math.sin(pp * 7 + k * 1.7) * 2; });                                          /* quick sideways scuttle */
  PFA.motion('L05-bumble', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.t += Math.sin(pp * 9 + k) * 2; G.up += Math.sin(pp * 13 + k * 2) * 1.5;                  /* wobbly flight, then a bump */
    G.fr = u > .82 ? 3 : (Math.floor(pp * 16) + k) & 1 ? 1 : 0; });
  PFA.motion('L05-ruffle', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; });                                                                                  /* pile stands up and flattens */
  PFA.motion('L05-puffpollen', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 3) + k) & 3; G.up += Math.sin(pp * 4 + k) * .8; });                             /* the basket puffs grains */
  PFA.motion('L05-jab', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .3 ? 0 : u < .55 ? 1 : u < .8 ? 2 : 3; if (u >= .3 && u < .55) G.d += 3; });       /* jab, bead swells, drops */

  /* ================= custom chain effects (along the OUTER loop from e.a over e.d, eased e.hh) ================= */
  function carFuse(c, e, H) {           /* the gorse catches like a fuse: blooms flare one by one along the outer edge, the ones behind charred with a smoke fleck */
    var P = e.P, Q = H.Q, i, u, n = 9, fr;
    for (i = 0; i <= n; i++) { u = i / n; if (u > e.hh) break; P.atq(e.a + e.d * u);
      fr = e.hh - u < .12 ? 2 : e.hh - u < .3 ? 1 : 3;
      H.glyph(c, 'L05-gorse', Q.x + Q.nx * 2, Q.y + Q.ny * 2, e.z > 1 ? 1 : 0, fr, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
      if (fr === 3 && ((i + Math.floor(e.p * 10)) & 1)) H.px(c, Q.x + Q.nx * 14, Q.y + Q.ny * 14 - 1, e.acc); }
  }
  function carBellow(c, e, H) {         /* the stag's roar rolls along the outer edge as widening arcs, the bellowing head at the front */
    var P = e.P, Q = H.Q, i, j, u, r, b;
    for (i = 1; i <= 4; i++) { u = e.hh - i * .09; if (u < 0) continue; P.atq(e.a + e.d * u); r = 2 + i * 1.5;
      for (j = -2; j <= 2; j++) { b = 6 + r - Math.abs(j) * .6; H.px(c, Q.x + Q.nx * b - Q.ny * j * (r * .5), Q.y + Q.ny * b + Q.nx * j * (r * .5), i === 1 ? H.WHITE : e.hi); } }
    H.carHead(c, P, e.a + e.d * e.hh, 'L05-roar', e.z > 1 ? 1 : e.z, 1 + (Math.floor(e.p * 8) & 1) * 2, 0, 0, e.col, e.acc, e.hi);
  }
  function carSteam(c, e, H) {          /* a bank of bog steam drifts along the outer edge, older puffs higher and thinner */
    var P = e.P, Q = H.Q, k, u, h;
    for (k = 0; k < 6; k++) { u = e.hh - k * .06; if (u < 0) break; P.atq(e.a + e.d * u); h = 4 + k * 2 + Math.sin(e.p * 8 + k) ;
      H.sq(c, Q.x + Q.nx * h, Q.y + Q.ny * h - k * .5, k < 2 ? 3 : k < 4 ? 2 : 1, k & 1 ? e.hi : H.WHITE); }
  }
  function carBumble(c, e, H) {         /* the big bumblebee bumbles to the next piece on a wobbly dotted flight path */
    var P = e.P, Q = H.Q, i, u, b, sd = e.d < 0 ? -1 : 1;
    for (i = 1; i <= 14; i++) { u = i / 14 * e.hh; if (i & 1) continue; P.atq(e.a + e.d * u); b = 7 + Math.sin(u * 22) * 3; H.px(c, Q.x + Q.nx * b, Q.y + Q.ny * b, e.hi); }
    P.atq(e.a + e.d * e.hh); b = 7 + Math.sin(e.hh * 22) * 3;
    H.glyph(c, 'L05-bumble', Q.x + Q.nx * (b - 3), Q.y + Q.ny * (b - 3), e.z > 1 ? 1 : e.z, e.hh > .95 ? 3 : (Math.floor(e.p * 16) & 1), e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
  }

  /* ================= motifs ================= */
  function M(name, meta) { PFA.motif(name, comp, meta); }
  /* lichen reindeer */
  M('lichen-antler', { nm: 'lichen racks', desc: 'a reindeer head under a long rack crusted with grey-green lichen, a brow shovel forward; the rack swings side to side and flakes of crust fly off', fam: 'slash', gap: 18, g: 'L05-lichrack', mo: 'L05-antlersweep', x: '-', car: 'comet' });
  M('herd-wheel', { nm: 'wheeling herd', desc: 'reindeer side-on with pale neck ruffs and small racks, trotting round in the herd wheel, snow kicked up behind', fam: 'puff', gap: 16, g: 'L05-reinrun', mo: 'L05-wheel', x: 'snow', car: 'loop' });
  M('snow-crater', { nm: 'snow cratering', desc: 'a cloven hoof pawing through the snow crust, snow flying, the crater opening on grey-green lichen and a sprig lifted out', fam: 'mend', gap: 16, g: 'L05-crater', mo: 'L05-paw', x: '-', car: 'hop' });
  /* red stag */
  M('royal-rack', { nm: 'royal racks', desc: 'a red stag head-on under a wide royal rack: arching beams, three tines a side and a crown cup at each top; lowered, tossed and clashed in a white star', fam: 'bash', gap: 18, g: 'L05-royal', mo: 'L05-clash', x: 'clods', car: 'comet' });
  M('rut-roar', { nm: 'rut roar', desc: 'a stag bellowing side-on, shaggy neck stretched up and jaw dropped, breath steam and roar arcs rolling ahead; the chain is the roar rolling along the outer edge in widening arcs', fam: 'ripple', gap: 18, g: 'L05-roar', mo: 'L05-bellow', x: '-', car: 'custom', carDraw: carBellow });
  M('bracken-curl', { nm: 'bracken fronds', desc: 'autumn bracken croziers unrolling into golden-brown fronds and swaying', fam: 'leaf', gap: 12, g: 'L05-bracken', mo: 'L05-unfurl', x: '-', car: 'flutter' });
  /* gorse beast */
  M('gorse-flare', { nm: 'gorse flare', desc: 'a spiny gorse sprig whose yellow pea flowers bud, bloom, flare up like flame and char, spitting seed sparks; the chain is a fuse of blooms flaring one by one along the outer edge', fam: 'ember', gap: 12, g: 'L05-gorse', mo: 'L05-flare', x: 'embers', car: 'custom', carDraw: carFuse });
  M('gorse-spine', { nm: 'gorse spines', desc: 'a dense gorse clump: green spines bristling in a fan with yellow flowers tucked between them', fam: 'thorn', gap: 12, g: 'L05-spinebush', mo: 'L05-prickle', x: '-', car: 'train' });
  M('sun-bloom', { nm: 'sun blooms', desc: 'a gorse pea flower opening in the sun: bud, banner petal up, sun rays, then a bee landing on it', fam: 'mend', gap: 14, g: 'L05-sunbloom', mo: 'L05-bask', x: 'glint', car: 'flutter' });
  /* moss golem */
  M('moss-boulder', { nm: 'mossy fists', desc: 'a stone fist with a cap of moss: wound up, punched out knuckles first, impact cracks, moss shaken loose', fam: 'bash', gap: 16, g: 'L05-boulder', mo: 'L05-punch', x: 'dust', car: 'roll' });
  M('moss-cloak', { nm: 'moss mats', desc: 'a thick moss mat hanging off the golem: cushion tufts and spore stalks with brown capsules nodding', fam: 'shield', gap: 14, g: 'L05-mosscloak', mo: 'L05-drape', x: '-', car: 'train' });
  M('moss-sprout', { nm: 'regrowing moss', desc: 'a green moss cushion with three spore stalks shooting up, a capsule popping a puff of spores', fam: 'mend', gap: 12, g: 'L05-sprout', mo: 'L05-grow', x: '-', car: 'flutter' });
  /* lichen golem */
  M('scree-slab', { nm: 'scree slabs', desc: 'angular grey-green scree slabs spotted with lichen tumbling end over end', fam: 'bash', gap: 14, g: 'L05-scree', mo: 'L05-tumble', x: 'dust', car: 'roll' });
  M('lichen-rosette', { nm: 'lichen rosettes', desc: 'round leafy lichen rosettes spreading ring by ring, lobed rims, a dark centre and little fruiting cups', fam: 'mend', gap: 14, g: 'L05-rosette', mo: 'L05-spread', x: '-', car: 'rings' });
  M('lichen-flake', { nm: 'crust flakes', desc: 'sharp flakes of lichen-crusted rock flipping point first as they fly', fam: 'thrust', gap: 12, g: 'L05-flake', mo: 'L05-spin', x: '-', car: 'comet' });
  M('rain-cup', { nm: 'pixie cups', desc: 'pixie-cup lichens on grey stalks catching rain drops, filling and brimming over in a glint', fam: 'mend', gap: 14, g: 'L05-cup', mo: 'L05-fillcup', x: '-', car: 'rings' });
  /* peat golem */
  M('peat-slab', { nm: 'peat turves', desc: 'a stack of cut peat turves with fibres and root threads, the top turf slumping sideways and settling', fam: 'shield', gap: 16, g: 'L05-turf', mo: 'L05-slump', x: '-', car: 'roll' });
  M('bog-fist', { nm: 'bog fists', desc: 'a fist of wet peat heaving up out of a dark bog pool, fingers clawing, then clenching shut', fam: 'drip', gap: 16, g: 'L05-bogfist', mo: 'L05-grab', x: 'splat', car: 'tunnel' });
  M('reed-hair', { nm: 'reed hair', desc: 'three reeds of different height with brown seed heads, swaying and bristling like hair', fam: 'thorn', gap: 12, g: 'L05-reed', mo: 'L05-reedsway', x: '-', car: 'train' });
  M('steam-vent', { nm: 'bog steam', desc: 'a crack in the peat breathing curling wisps of steam that rise and thin; the chain is a bank of steam drifting along the outer edge', fam: 'mend', gap: 14, g: 'L05-steam', mo: 'L05-vent', x: '-', car: 'custom', carDraw: carSteam });
  /* coral golem */
  M('coral-branch', { nm: 'coral branches', desc: 'branching pink coral with white polyps extending and retracting at every tip', fam: 'thorn', gap: 14, g: 'L05-coral', mo: 'L05-polyp', x: 'bubbles', car: 'train' });
  M('anemone-sway', { nm: 'anemones', desc: 'sea anemones on stout columns, crowns of tentacles swaying in the swell, a white sting flash at a tip', fam: 'ripple', gap: 14, g: 'L05-anemone', mo: 'L05-swell', x: '-', car: 'flutter' });
  M('barnacle-cone', { nm: 'barnacle cones', desc: 'pale barnacle cones welded to the coral: lids opening, feathery cirri combing out, snapping shut', fam: 'shield', gap: 12, g: 'L05-barnacle', mo: 'L05-comb', x: '-', car: 'train' });
  /* emperor scorpion */
  M('emperor-claw', { nm: 'emperor claws', desc: 'a thick knobbly black pincer outlined in pale glow: opened wide, snapped shut with a star, recoiling', fam: 'bite', gap: 16, g: 'L05-eclaw', mo: 'L05-clamp', x: '-', car: 'comet' });
  M('stinger-arch', { nm: 'arched stings', desc: 'the glowing segmented tail arching over, a curved sting with a pale venom bead swelling and dropping', fam: 'drip', gap: 16, g: 'L05-tail', mo: 'L05-arch', x: '-', car: 'trail' });
  M('plate-fold', { nm: 'folding plates', desc: 'glossy black armour plates folding over each other like shingles, glowing rims, a glint sliding across', fam: 'shield', gap: 14, g: 'L05-plates', mo: 'L05-fold', x: 'glint', car: 'train' });
  M('glow-scuttle', { nm: 'glowing scuttlers', desc: 'whole emperor scorpions from above, black with glowing outlines, claws forward and tails curled, scuttling sideways', fam: 'puff', gap: 14, g: 'L05-scorp', mo: 'L05-scurry', x: 'prints', car: 'train' });
  /* giant bumblebee */
  M('bumble-bump', { nm: 'bumble bumps', desc: 'a huge round furry bumblebee (yellow band, black band, white tail, tiny blurred wings) wobbling in flight and squashing flat on a bump; the chain is its wobbly dotted flight path to the next piece', fam: 'bash', gap: 16, g: 'L05-bumble', mo: 'L05-bumble', x: '-', car: 'custom', carDraw: carBumble });
  M('fuzz-coat', { nm: 'fuzz coat', desc: 'a thick banded fuzz pile standing up and smoothing flat, orange pollen grains clinging to it', fam: 'shield', gap: 12, g: 'L05-fuzz', mo: 'L05-ruffle', x: '-', car: 'flutter' });
  M('pollen-basket', { nm: 'pollen baskets', desc: 'a hind leg with a fat orange pollen basket puffing grains that hang in the air', fam: 'puff', gap: 14, g: 'L05-pollen', mo: 'L05-puffpollen', x: 'pollen', car: 'cloud' });
  M('honey-barb', { nm: 'honey barbs', desc: 'a banded abdomen tip with a barbed sting, an amber honey bead swelling on the point and dropping off', fam: 'drip', gap: 14, g: 'L05-barb', mo: 'L05-jab', x: '-', car: 'comet' });
})();
