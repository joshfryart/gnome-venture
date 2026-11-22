/* Motif module, large batch L08 (desert-gila-dragon, dune-wyrmling, desert-tortoise, sand-viper-matriarch, glass-wyrm, spurred-tortoise, rock-python,
   grass-snake, emerald-python): desert lizards, wyrms, tortoises, vipers and pythons. TEMPLATE.md sections 9 and 10.3.
   35 motifs, each with its own pixel glyph (ids prefixed L08-); the nine signature motifs bring their own chain effect (carDraw): the gila dragon plodding with a
   tail groove, the wyrm breaching through the dunes in humps, the hollow glass serpent with a prism glint, the tortoise trundling on its track, the spurred
   tortoise charging, the viper mother with her brood in file, the barrel-thick python creeping in a straight line, the collared grass snake swimming,
   the emerald python flowing along a liana that grows to the next piece.
   Glyph coordinates are (a, b): a along the edge tangent, b outward along the normal, so every sprite turns with its edge. fr0() stores the frame in module
   scratch variables (glyph draws never nest). Lookup tables are built once at load; nothing is allocated per frame, there is no Math.random / Date: every
   effect is a stateless function of p. Glyphs go through H.glyph so the MAXG budget counts them. Wiggle, outer-edge chain rule, visual-only sound lines and
   the creature-heavy default live in the page and are untouched. Large sprites reach up to ~14 px out and stay within ~22 px of the edge. */
(function () {
  var X0 = 0, Y0 = 0, TX = 1, TY = 0, NX = 0, NY = -1, KK = null;
  var VEN = '#d8f070', SAND = '#e6cc94', SANDD = '#b8955c', CACT = '#6aae4a', CACTD = '#2f5a24', FRUIT = '#e0405a', SUN = '#f6c840', CLOUD = '#dfe8f2',
    RAIN = '#7cc0f0', ROCK = '#9a9284', ROCKD = '#4c463e', BARK = '#8a643e', BARKD = '#3e2c1a', COLLAR = '#f6dc3a', BELLY = '#eeeadc', TONGUE = '#e0403a',
    PR = '#ff6a6a', PG = '#7cf08a', PB = '#7ab0ff', HEAT = '#ff9a40', WATER = '#9ad4f0', IVORY = '#f4f0e0';
  var ARA = [], ARB = [], CA = [], CB = [], i0, t0;                     /* 13-point unit half ring (arches) and a 12-point unit circle (rings) */
  for (i0 = 0; i0 < 13; i0++) { t0 = i0 / 12 * Math.PI; ARA.push(Math.cos(t0)); ARB.push(Math.sin(t0)); }
  for (i0 = 0; i0 < 12; i0++) { t0 = i0 / 12 * Math.PI * 2; CA.push(Math.cos(t0)); CB.push(Math.sin(t0)); }
  var DOME = [0, 0, 0, 0, 0, 0, 0, 0, 0];                              /* half widths of a tortoise dome, filled per radius on demand (no per-frame arrays) */

  function fr0(x, y, tx, ty, nx, ny, K) { X0 = x; Y0 = y; TX = tx; TY = ty; NX = nx; NY = ny; KK = K; }
  function p(c, a, b, col) { KK.px(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, col); }
  function row(c, a0, a1, b, col) { for (var a = a0; a <= a1; a++) p(c, a, b, col); }
  function cl(c, a, b0, b1, col) { for (var b = b0; b <= b1; b++) p(c, a, b, col); }
  function arch(c, ca, cb, r, h, col, step) { for (var i = 0; i < 13; i += step) p(c, Math.round(ca + ARA[i] * r), Math.round(cb + ARB[i] * r * h), col); }
  function ring(c, ca, cb, r, col, step) { for (var i = 0; i < 12; i += step) p(c, Math.round(ca + CA[i] * r), Math.round(cb + CB[i] * r), col); }
  function dome(R) { for (var b = 0; b <= R; b++) DOME[b] = Math.round(Math.sqrt(R * R - b * b) * 1.35); }

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
  function G8(name, fn) { PFA.glyph('L08-' + name, function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { fr0(x, y, tx, ty, nx, ny, K); fn(c, z > 1 ? 1 : 0, fr, C, A, Hi, K); }); }

  /* ================= glyphs ================= */
  /* --- gila dragon --- */
  G8('gilahead', function (c, w, fr, C, A, Hi, K) {     /* a huge beaded lizard head side-on, snout along +a: jaw open, clamped shut, grinding, venom welling out of the jaw grooves */
    var a, b, sh = fr === 2 ? 1 : 0, jo = fr === 0 ? 2 : 0, top;
    for (a = -6 - w; a <= 4; a++) {
      top = a > 2 ? 5 - (a - 2) : 6;
      for (b = 3; b <= top; b++) p(c, a + sh, b + jo, (a * 3 + b * 5 + 40) % 4 === 0 ? A : C);   /* upper head, bead rows */
      if (a < 4) for (b = 0; b <= 2; b++) p(c, a + sh, b, (a * 5 + b * 3 + 40) % 4 === 1 ? A : C); /* heavy lower jaw */
    }
    p(c, 1 + sh, 5 + jo, Hi); p(c, 1 + sh, 6 + jo, A);                                           /* small beady eye */
    if (jo) { row(c, -2, 3, 3, A); p(c, 0, 3, Hi); p(c, 2, 4, K.WHITE); }                        /* open: pink gape */
    else { row(c, -3 + sh, 3 + sh, 2, A); p(c, 3 + sh, 3, K.WHITE); }                             /* clamped: the jaw seam */
    if (fr === 2) { p(c, -7, 1, Hi); p(c, 6, 3, Hi); }                                           /* grinding tick */
    if (fr === 3) { p(c, 0, -1, VEN); p(c, 2, -1, VEN); p(c, 1, -2, VEN); p(c, 2, -3, VEN); }   /* venom runs down the grooves */
  });
  G8('bitemark', function (c, w, fr, C, A, Hi, K) {     /* a lingering bite: two arcs of tooth punctures and ache rings that throb out and out */
    var a, r = 4 + fr + w;
    for (a = -4; a <= 4; a += 2) { p(c, a, 7 - ((a * a) >> 3), A); p(c, a, 1 + ((a * a) >> 3), A); p(c, a, 8 - ((a * a) >> 3), C); p(c, a, ((a * a) >> 3), C); }
    p(c, -1, 4, VEN); p(c, 1, 4, VEN);
    ring(c, 0, 4, r, fr & 1 ? Hi : C, fr > 1 ? 2 : 1);
    if (fr === 3) ring(c, 0, 4, r - 3, Hi, 3);
  });
  G8('gilafoot', function (c, w, fr, C, A, Hi, K) {     /* a fat five-clawed beaded foot from above: lifted, slammed down, cracks run out, dust jumps */
    var lf = fr === 0 ? 3 : 0, a, b;
    for (b = 1; b <= 4; b++) row(c, -3 - w, 3 + w, b + lf, (b & 1) ? C : Hi);
    for (a = -4; a <= 4; a += 2) { cl(c, a, 5 + lf, 6 + lf, C); p(c, a, 7 + lf, A); }
    p(c, -1, 2 + lf, A); p(c, 1, 3 + lf, A); p(c, 2, 1 + lf, A);
    if (fr === 2) { for (a = 5; a <= 9; a++) { p(c, a, (a & 1), A); p(c, -a, (a & 1) ^ 1, A); } }
    if (fr === 3) { p(c, -7, 2, Hi); p(c, 7, 3, Hi); p(c, -6, 4, A); p(c, 8, 1, A); p(c, 5, 5, Hi); }
  });
  G8('quake', function (c, w, fr, C, A, Hi, K) {        /* the ground splits: a zigzag crack runs outward, chunks of crust jump, dust */
    var L = 3 + fr * 3 + w, b, j = 0;
    for (b = 0; b <= L; b++) { j = (b >> 1) & 1 ? 1 : -1; p(c, j, b, A); p(c, j + 1, b, (b & 1) ? C : A); }
    if (fr >= 1) { p(c, 3, L - 2, C); p(c, 4, L - 2, C); p(c, 3, L - 1, Hi); }
    if (fr >= 2) { p(c, -4, L - 3, C); p(c, -3, L - 3, C); p(c, -4, L - 2, Hi); cl(c, 3, 1, 2, A); }
    if (fr === 3) { p(c, -6, L, Hi); p(c, 6, L - 1, Hi); p(c, 0, L + 2, Hi); }
  });
  /* --- dune wyrmling --- */
  G8('dunewyrm', function (c, w, fr, C, A, Hi, K) {     /* a sand-coloured wyrm coil breaching out of a dune and diving back: ripple, half out, full arch with spray, diving */
    var h = [.25, .7, 1, .75][fr], r = 5 + w;
    row(c, -r - 2, -r + 1, 0, SANDD); row(c, r - 1, r + 2, 0, SANDD);
    arch(c, 0, 0, r, h, C, 1); arch(c, 0, 0, r - 1, h, C, 1); arch(c, 0, 1, r - 1, h, Hi, 3);
    p(c, 0, Math.round(r * h) - 1, A); p(c, -2, Math.round(r * h * .9) - 1, A); p(c, 2, Math.round(r * h * .9) - 1, A);
    if (fr === 1) { cl(c, r, 1, 3, C); p(c, r + 1, 3, A); cl(c, r + 1, 4, 5, K.WHITE); }       /* head first, a thin fang */
    if (fr === 2) { p(c, -r - 2, 2, SAND); p(c, -r - 3, 4, SAND); p(c, r + 2, 3, SAND); p(c, r + 3, 1, SAND); p(c, 0, Math.round(r * h) + 2, SAND); }
    if (fr === 3) { p(c, -r - 1, 1, SAND); p(c, -r, 2, SANDD); }
  });
  G8('needlefang', function (c, w, fr, C, A, Hi, K) {   /* the wyrm's head facing out: closed, gaping, two long thin needle fangs stabbing, a venom bead at each tip */
    var a, b, L = fr === 2 ? 6 : fr === 0 ? 0 : 4;
    for (b = 0; b <= 4; b++) row(c, -3 - w + (b > 3 ? 1 : 0), 3 + w - (b > 3 ? 1 : 0), b, C);
    p(c, -2, 3, A); p(c, 2, 3, A); p(c, -2, 4, Hi); p(c, 2, 4, Hi); p(c, 0, 1, Hi);
    if (!L) { row(c, -2, 2, 5, C); row(c, -1, 1, 6, C); }
    else { row(c, -2, 2, 5, A); for (b = 6; b < 6 + L; b++) { p(c, -1 - w, b, K.WHITE); p(c, 1 + w, b, K.WHITE); } }
    if (fr === 3) { p(c, -1 - w, 10, VEN); p(c, 1 + w, 10, VEN); p(c, -1 - w, 11, VEN); }
    for (a = -3; a <= 3; a += 3) p(c, a, 0, A);
  });
  G8('sandhiss', function (c, w, fr, C, A, Hi, K) {     /* a gaping wyrm head with an S of hiss blowing out and sand grains swept along in it */
    var b, aa;
    row(c, -2 - w, 2 + w, 0, C); row(c, -3 - w, 3 + w, 1, C); row(c, -3 - w, -1, 2, C); row(c, 1, 3 + w, 2, C); row(c, -2, -1, 3, C); row(c, 1, 2, 3, C);
    p(c, 0, 2, A); p(c, 0, 3, A); p(c, -2, 1, Hi); p(c, 2, 1, Hi);
    for (b = 5; b <= 11; b++) { aa = Math.round(Math.sin(b * 1.1 - fr * 1.57) * 2); p(c, aa, b, Hi); if (b === 7 || b === 10) p(c, aa + 3, b, SAND); }
    p(c, -3 + fr, 8 + (fr & 1), SANDD); p(c, 4 - fr, 12, SAND);
  });
  /* --- glass wyrm --- */
  G8('glasscoil', function (c, w, fr, C, A, Hi, K) {    /* a hollow glass serpent: only the outline of an S-curved body, a light glint and a little rainbow travelling through it */
    var a, bc, g = -7 + ((fr * 4) % 15), j;
    for (a = -8 - w; a <= 6; a++) {
      bc = 5 + Math.round(Math.sin(a * .45 + fr * 1.57) * 2);
      p(c, a, bc - 2, C); p(c, a, bc + 2, C); if ((a & 3) === 0) p(c, a, bc, A);
      if (a === g) { p(c, a, bc + 1, K.WHITE); p(c, a, bc - 1, Hi); }
      if (a === g + 2) { p(c, a, bc - 1, PR); p(c, a, bc, PG); p(c, a, bc + 1, PB); }
    }
    bc = 5 + Math.round(Math.sin(7 * .45 + fr * 1.57) * 2);
    for (j = -1; j <= 1; j++) { p(c, 7, bc + j * 2, C); } p(c, 8, bc - 1, C); p(c, 8, bc + 1, C); p(c, 9, bc, C); p(c, 7, bc, Hi);
  });
  G8('shatter', function (c, w, fr, C, A, Hi, K) {      /* a glass tail tip lashing: whole, cracked, flying apart into shards, shards glinting as they scatter */
    var a;
    if (fr < 2) { for (a = -6; a <= 3; a++) { p(c, a, 3, C); if (a < 1) p(c, a, 2, C); } p(c, 4, 3, Hi); p(c, -3, 2, Hi);
      if (fr === 1) { p(c, 0, 1, A); p(c, 1, 2, A); p(c, 0, 3, A); p(c, 1, 4, A); p(c, 2, 5, Hi); } }
    else {
      var s = fr === 2 ? 1 : 2;
      for (a = -6; a <= -1; a++) { p(c, a, 3, C); p(c, a, 2, C); }
      p(c, 2 * s, 3 + 2 * s, C); p(c, 2 * s + 1, 3 + 2 * s, Hi); p(c, 4 * s, 2 + s, C); p(c, 4 * s, 3 + s, C);
      p(c, 3 * s, 5 + 3 * s, C); p(c, 1 + s, 1, A); p(c, 5 * s - 1, 6 + s, Hi);
      if (fr === 3) { KK.plus(c, X0 + TX * 7 + NX * 9, Y0 + TY * 7 + NY * 9, 1, 1, K.WHITE); p(c, 2, 11, Hi); }
    }
  });
  G8('prism', function (c, w, fr, C, A, Hi, K) {        /* a hexagonal glass scale, hollow, a rainbow band sweeping across it */
    var b, a0 = -3 + fr * 2;
    row(c, -2, 2, 1, C); row(c, -2, 2, 9 + w, C); p(c, -3, 2, C); p(c, 3, 2, C); p(c, -3, 8 + w, C); p(c, 3, 8 + w, C);
    for (b = 3; b <= 7 + w; b++) { p(c, -4, b, C); p(c, 4, b, C); }
    for (b = 2; b <= 8 + w; b++) { if (a0 > -4 && a0 < 4) p(c, a0, b, PR); if (a0 + 1 > -4 && a0 + 1 < 4) p(c, a0 + 1, b, PG); if (a0 + 2 > -4 && a0 + 2 < 4) p(c, a0 + 2, b, PB); }
    p(c, -2, 3, K.WHITE); p(c, -1, 2, Hi); p(c, 0, 5, A);
  });
  G8('glasseye', function (c, w, fr, C, A, Hi, K) {     /* a glass eye waking in the sun: shut, half open, open with a slit pupil and a glint, warm rays */
    var a;
    for (a = -5; a <= 5; a++) p(c, a, 4, fr ? A : C);
    if (fr === 0) { p(c, -3, 3, Hi); p(c, 0, 3, Hi); p(c, 3, 3, Hi); return; }
    for (a = -4; a <= 4; a++) { p(c, a, 4 + (fr === 1 ? 1 : 2) - (Math.abs(a) > 2 ? 1 : 0), C); p(c, a, 4 - 2 + (Math.abs(a) > 2 ? 1 : 0), C); }
    if (fr === 1) { row(c, -1, 1, 4, Hi); p(c, 0, 4, A); return; }
    row(c, -2, 2, 3, Hi); row(c, -2, 2, 4, Hi); row(c, -2, 2, 5, Hi); cl(c, 0, 3, 5, A); p(c, -1, 5, K.WHITE);
    if (fr === 3) { p(c, 0, 9, SUN); p(c, -6, 7, SUN); p(c, 6, 7, SUN); p(c, -3, 9, SUN); p(c, 3, 9, SUN); }
  });
  /* --- tortoises --- */
  function shell(c, R, sh, C, A, Hi, saw) {             /* a high dome side-on with scute seams and growth rings, standing at b = 2 */
    var a, b, hw;
    dome(R);
    for (b = 0; b <= R; b++) { hw = DOME[b]; for (a = -hw; a <= hw; a++) p(c, a + sh, b + 2, (a === -hw || a === hw || b === R) ? A : ((a + 30) % 3 === 0 && b < R - 1) ? A : ((a + b + 31) % 3 === 1 ? Hi : C)); }
    row(c, -DOME[0] + sh, DOME[0] + sh, 2, saw ? A : A);
    if (saw) for (a = -DOME[0]; a <= DOME[0]; a += 2) p(c, a + sh, 1, A);                         /* serrated rim */
    return DOME[0];
  }
  G8('tortoise', function (c, w, fr, C, A, Hi, K) {     /* a desert tortoise side-on: a high dome of ringed scutes, stumpy elephant legs stepping, head out with a horny beak */
    var R = 5 + w, hw = shell(c, R, 0, C, A, Hi, false), st = fr & 1, ho = fr === 1 ? 1 : 0;
    cl(c, hw - 1 - st, 0, 1, C); cl(c, -hw + 1 + st, 0, 1, C); p(c, hw - st, 0, A); p(c, -hw + 2 + st, 0, A);
    row(c, hw + 1, hw + 2 + ho, 2, C); row(c, hw + 2, hw + 3 + ho, 3, C); p(c, hw + 3 + ho, 2, Hi); p(c, hw + 2 + ho, 3, A); p(c, -hw - 1, 2, A);
  });
  G8('cactus', function (c, w, fr, C, A, Hi, K) {       /* a prickly-pear pad with a red fruit; a tortoise beak gapes, crunches a notch out, chews */
    var a, b, hw;
    for (b = 2; b <= 10; b++) { hw = b < 4 || b > 8 ? 2 : 3; for (a = -hw; a <= hw; a++) { if (fr >= 2 && a <= -2 && b >= 5 && b <= 7) continue; p(c, a + 2, b, (a + b) % 4 === 0 ? CACTD : CACT); } }
    p(c, 6, 5, K.WHITE); p(c, 6, 8, K.WHITE); p(c, 2, 11, FRUIT); p(c, 3, 11, FRUIT); p(c, 2, 12, FRUIT); p(c, -1, 9, K.WHITE);
    var hx = fr === 2 ? -2 : -3;
    row(c, hx - 4, hx, 5, C); row(c, hx - 4, hx - 1, 6, C); p(c, hx - 2, 6, A);
    if (fr === 1) { p(c, hx + 1, 7, Hi); p(c, hx + 1, 4, Hi); } else { p(c, hx + 1, 5, Hi); p(c, hx + 1, 6, Hi); }
    if (fr === 3) { p(c, hx - 1, 8, CACT); p(c, hx + 2, 9, FRUIT); p(c, hx, 3, CACT); }
  });
  G8('flop', function (c, w, fr, C, A, Hi, K) {         /* the tortoise flipped onto its back like a boulder: rocking, stumpy legs waving, then thumping back over in dust */
    var R = 4 + w, a, b, hw, sh = fr === 1 ? 1 : fr === 2 ? -1 : 0;
    if (fr === 3) { hw = shell(c, R, 0, C, A, Hi, false); p(c, -hw - 2, 1, A); p(c, hw + 2, 1, A); p(c, -hw - 3, 3, Hi); p(c, hw + 3, 2, Hi); p(c, 0, R + 4, Hi); return; }
    dome(R);
    for (b = 0; b <= R; b++) { hw = DOME[b]; for (a = -hw; a <= hw; a++) p(c, a + sh, R - b + 1, (a === -hw || a === hw || b === R) ? A : (a === 0 && b > 0) ? A : ((a + b + 31) % 4 === 1 ? Hi : C)); }
    row(c, -DOME[0] + 1 + sh, DOME[0] - 1 + sh, R + 2, Hi);                                         /* the flat belly plate on top */
    for (a = -4; a <= 4; a += 8) { cl(c, a + sh + (fr === 1 ? 1 : 0), R + 3, R + 4, C); cl(c, a / 2 + sh - (fr === 2 ? 1 : 0), R + 3, R + 5, C); }
    p(c, DOME[0] + 1 + sh, R, C); p(c, DOME[0] + 2 + sh, R + 1, C);
  });
  G8('shellin', function (c, w, fr, C, A, Hi, K) {      /* pulling in: head out, head half in, the scaly forelegs fold over the opening, shut tight with a tink */
    var R = 5 + w, hw = shell(c, R, 0, C, A, Hi, false);
    if (fr === 0) { row(c, hw + 1, hw + 3, 2, C); row(c, hw + 2, hw + 4, 3, C); p(c, hw + 3, 3, A); cl(c, hw - 1, 0, 1, C); cl(c, -hw + 1, 0, 1, C); }
    else if (fr === 1) { row(c, hw + 1, hw + 2, 2, C); p(c, hw + 2, 3, A); cl(c, hw - 1, 1, 1, C); }
    else { cl(c, hw, 1, 4, fr === 2 ? Hi : A); cl(c, hw + 1, 2, 3, A); p(c, hw + 1, 2, Hi); p(c, -hw, 2, A); p(c, -hw, 3, A); }
    if (fr === 3) KK.plus(c, X0 + TX * (hw + 3) + NX * (R + 4), Y0 + TY * (hw + 3) + NY * (R + 4), 1, 1, K.WHITE);
  });
  G8('dig', function (c, w, fr, C, A, Hi, K) {          /* shovel forelegs digging a burrow: the dome sinks a little each beat, sand arcs thrown back */
    var R = 4 + w, sk = fr >> 1, a, b, hw;
    dome(R);
    for (b = sk; b <= R; b++) { hw = DOME[b]; for (a = -hw; a <= hw; a++) p(c, a, b + 2 - sk, (a === -hw || a === hw || b === R) ? A : (a + b) % 3 === 0 ? Hi : C); }
    row(c, -DOME[0] - 2, DOME[0] + 2, 1, SANDD);
    p(c, DOME[0] + 1, 1 + (fr & 1), Hi); p(c, DOME[0] + 2, 2 - (fr & 1), Hi);                      /* shovel claws */
    for (a = 0; a < 3; a++) p(c, -DOME[0] - 2 - a - fr, 3 + a + (fr & 1) * 2, SAND);
    p(c, -DOME[0] - 4 - fr, 7, SANDD);
  });
  G8('rain', function (c, w, fr, C, A, Hi, K) {         /* the long wait for rain: blazing sun, a cloud gathers, rain falls, a puddle and the beak sipping */
    if (fr === 0) { row(c, -1, 1, 6, SUN); row(c, -2, 2, 7, SUN); row(c, -1, 1, 8, SUN); p(c, 0, 10, SUN); p(c, 0, 4, SUN); p(c, -4, 7, SUN); p(c, 4, 7, SUN); return; }
    row(c, -3, 3, 7, CLOUD); row(c, -4, 4, 8, CLOUD); row(c, -2, 1, 9, CLOUD); p(c, -3, 7, A); p(c, 2, 7, Hi);
    if (fr >= 2) { p(c, -2, 5, RAIN); p(c, 1, 4, RAIN); p(c, 3, 5, RAIN); p(c, -1, 3, RAIN); p(c, 2, 2, RAIN); }
    if (fr === 3) { row(c, -3, 3, 0, RAIN); p(c, -2, 1, K.WHITE); row(c, -7, -5, 1, C); p(c, -4, 1, Hi); p(c, -6, 2, A); }
  });
  G8('sulcata', function (c, w, fr, C, A, Hi, K) {      /* a stout spurred tortoise ramming: serrated yellow shell, forked gular horn, conical thigh spurs; set, lunge, crash, recoil */
    var sh = fr === 1 ? 2 : fr === 2 ? 3 : fr === 3 ? -1 : 0, R = 4 + w, hw = shell(c, R, sh, C, A, Hi, true);
    row(c, hw + 1 + sh, hw + 3 + sh, 2, C); row(c, hw + 2 + sh, hw + 3 + sh, 3, C); p(c, hw + 3 + sh, 3, A);
    p(c, hw + sh, 1, Hi); p(c, hw + 1 + sh, 0, Hi); p(c, hw + 1 + sh, 1, Hi);                     /* forked gular horn under the chin */
    cl(c, -hw + 1 + sh, 0, 1, C); cl(c, hw - 2 + sh, 0, 1, C);
    p(c, -hw + sh, 1, A); p(c, -hw - 1 + sh, 1, Hi); p(c, -hw + sh, 0, A);                         /* the big thigh spur */
    if (fr === 2) { p(c, hw + 5 + sh, 1, K.WHITE); p(c, hw + 6 + sh, 2, K.WHITE); p(c, hw + 5 + sh, 3, K.WHITE); p(c, hw + 6 + sh, 4, K.WHITE); p(c, hw + 5 + sh, 5, Hi); }
    if (fr === 1) { p(c, -hw - 2, 1, SANDD); p(c, -hw - 3, 2, SANDD); }
  });
  G8('spur', function (c, w, fr, C, A, Hi, K) {         /* a thick scaly foreleg pointing out with three conical spurs that jut and jab */
    var b, k, L = 1 + (fr === 2 ? 2 : fr === 1 || fr === 3 ? 1 : 0), sb;
    for (b = 0; b <= 8 + w; b++) row(c, -2, 2, b, C);
    for (b = 2; b <= 8 + w; b += 3) { p(c, -2, b, A); p(c, 0, b, A); }                              /* scattered leg scales */
    p(c, -1, 1, Hi); p(c, 1, 4, Hi); p(c, -1, 7, Hi);
    for (k = 0; k < 3; k++) { sb = 2 + k * 3; p(c, 3, sb, Hi); p(c, 3, sb + 1, C); for (b = 1; b <= L; b++) p(c, 3 + b, sb, b === L ? K.WHITE : Hi); }
    row(c, -2, 2, 9 + w, A); p(c, -2, 10 + w, A); p(c, 0, 10 + w, A); p(c, 2, 10 + w, A);
  });
  /* --- sand viper matriarch --- */
  function babyhead(c, a, b, C, A, Hi, tongue) { cl(c, a, b - 2, b, C); p(c, a - 1, b + 1, C); p(c, a, b + 1, C); p(c, a + 1, b + 1, C); p(c, a, b + 2, C); p(c, a + 1, b + 1, A); if (tongue) { p(c, a, b + 3, TONGUE); p(c, a - 1, b + 4, TONGUE); p(c, a + 1, b + 4, TONGUE); } }
  G8('brood', function (c, w, fr, C, A, Hi, K) {        /* the mother viper's heavy coils with her live-born brood peeking up out of them one, two, three, tongues flicking */
    var a, b;
    for (a = -6 - w; a <= 6 + w; a++) { for (b = 1; b <= 5; b++) { if ((b === 1 || b === 5) && Math.abs(a) > 5 + w) continue; p(c, a, b, b === 3 ? A : ((a * 3 + b + 40) % 5 === 0 ? A : (b === 5 ? Hi : C))); } }
    row(c, 7 + w, 8 + w, 3, C); row(c, 7 + w, 9 + w, 4, C); p(c, 8 + w, 5, Hi); p(c, 9 + w, 5, Hi); p(c, 8 + w, 4, A);        /* her horned head */
    if (fr >= 0) babyhead(c, 0, 8, C, A, Hi, fr === 3);
    if (fr >= 1) babyhead(c, -4, 7, C, A, Hi, false);
    if (fr >= 2) babyhead(c, 4, 7, C, A, Hi, fr === 2);
  });
  G8('broodhiss', function (c, w, fr, C, A, Hi, K) {    /* three tiny viper heads in a row, mouths gaping, small S hiss lines puffing above */
    var k, a, b, aa;
    for (k = -1; k <= 1; k++) {
      a = k * 5; cl(c, a, 0, 3, C); row(c, a - 1, a + 1, 4, C); p(c, a - 1, 5, C); p(c, a + 1, 5, C); p(c, a, 5, A); p(c, a + 1, 4, A);
      for (b = 7; b <= 10; b++) { aa = a + Math.round(Math.sin(b * 1.4 + fr * 1.57 + k) * 1.2); if ((b + fr + k) % 4 !== 0) p(c, aa, b, Hi); }
    }
  });
  G8('ambush', function (c, w, fr, C, A, Hi, K) {       /* buried in sand: two horn tips and eyes, the sand bulges, the head erupts in a spray, sand rains back */
    var a;
    for (a = -6; a <= 6; a++) p(c, a, (a & 3) === 0 && fr === 1 ? 1 : 0, SAND);
    if (fr === 0) { p(c, -2, 1, A); p(c, 2, 1, A); p(c, -3, 2, Hi); p(c, 3, 2, Hi); return; }
    if (fr === 1) { row(c, -3, 3, 1, SANDD); row(c, -2, 2, 2, SAND); p(c, -1, 2, A); p(c, 1, 2, A); return; }
    if (fr === 2) {
      row(c, -4, 4, 2, C); row(c, -4, 4, 3, C); row(c, -3, 3, 4, C); row(c, -2, 2, 5, C); p(c, -2, 4, Hi); p(c, 2, 4, Hi); p(c, -3, 5, Hi); p(c, 3, 5, Hi);
      row(c, -1, 1, 6, A); p(c, -1, 7, K.WHITE); p(c, 1, 7, K.WHITE); p(c, -1, 8, K.WHITE); p(c, 1, 8, K.WHITE);
      p(c, -6, 4, SAND); p(c, -7, 6, SAND); p(c, 6, 5, SAND); p(c, 7, 3, SAND); p(c, -5, 7, SANDD); return;
    }
    row(c, -3, 3, 1, C); row(c, -2, 2, 2, C); p(c, -6, 2, SAND); p(c, -4, 4, SAND); p(c, 5, 3, SAND); p(c, 7, 1, SAND); p(c, 2, 5, SANDD);
  });
  G8('arrowhead', function (c, w, fr, C, A, Hi, K) {    /* a broad arrowhead viper head pointing out, heat pits glowing; it rears, strikes with the fangs out, a venom drop falls */
    var sb = fr === 1 ? -1 : fr === 2 ? 2 : 0, b, hw;
    cl(c, -1, 0, 1 + sb, C); cl(c, 1, 0, 1 + sb, C); cl(c, 0, 0, 1 + sb, A);
    for (b = 0; b <= 5 + w; b++) { hw = b < 2 ? 4 + w : 5 + w - b; if (hw < 0) break; row(c, -hw, hw, b + 2 + sb, C); p(c, -hw, b + 2 + sb, A); p(c, hw, b + 2 + sb, A); }
    p(c, -2, 4 + sb, A); p(c, 2, 4 + sb, A); p(c, -2, 5 + sb, Hi); p(c, 2, 5 + sb, Hi); p(c, 0, 3 + sb, A); p(c, 0, 4 + sb, A);
    p(c, -1, 6 + sb, fr === 3 ? Hi : HEAT); p(c, 1, 6 + sb, fr === 3 ? Hi : HEAT);
    if (fr === 2) { p(c, -1, 9 + sb + w, K.WHITE); p(c, 1, 9 + sb + w, K.WHITE); p(c, -1, 10 + sb + w, K.WHITE); p(c, 1, 10 + sb + w, K.WHITE); }
    if (fr === 3) { p(c, -3, 1, VEN); p(c, -3, 0, VEN); p(c, 3, -1, VEN); }
  });
  /* --- rock python --- */
  G8('barrel', function (c, w, fr, C, A, Hi, K) {       /* three barrel-thick blotched coils stacked, tightening and creaking; the head rests on top */
    var L, a, b, hw, tg = fr === 2 ? 1 : fr === 1 || fr === 3 ? 0 : -1, cb;
    for (L = 0; L < 3; L++) {
      cb = 1 + L * (3 - (tg > 0 ? 0 : 0)) - (tg > 0 ? L : 0); hw = 7 + w - L - tg;
      for (a = -hw; a <= hw; a++) for (b = 0; b <= 2; b++) { if (b !== 1 && Math.abs(a) === hw) continue; p(c, a, cb + b, ((a * 7 + L * 5 + b + 60) % 6 === 0 || (a * 3 + L + 60) % 7 === 0) ? A : b === 2 && (a & 1) ? Hi : C); }
    }
    hw = 5 + w - tg; cb = 1 + 2 * 3 - (tg > 0 ? 2 : 0);
    row(c, hw, hw + 2, cb + 1, C); row(c, hw + 1, hw + 3, cb + 2, C); p(c, hw + 2, cb + 2, A); p(c, hw + 3, cb + 1, Hi);
    if (fr === 2) { p(c, -9 - w, 2, A); p(c, 9 + w, 2, A); p(c, -9 - w, 4, A); p(c, 9 + w, 5, A); }
  });
  G8('gape', function (c, w, fr, C, A, Hi, K) {         /* a python head side-on opening wide: rows of small hooked teeth, then the snap */
    var o = [0, 1, 3, 0][fr], a, b;
    for (a = -5 - w; a <= 0; a++) for (b = 1; b <= 5; b++) p(c, a, b, (a * 5 + b * 3 + 30) % 7 === 0 ? A : C);
    p(c, -1, 4, Hi); p(c, -1, 5, A);
    for (a = 1; a <= 6 + w; a++) {
      b = 4 + Math.round(o * a / 6); p(c, a, b, C); p(c, a, b + 1, C); if (o && (a & 1)) p(c, a, b - 1, IVORY);
      b = 2 - Math.round(o * a / 12); p(c, a, b, C); if (o && !(a & 1) && a < 6) p(c, a, b + 1, IVORY);
    }
    if (o) row(c, 0, 2, 3, A);
    if (fr === 3) { p(c, 8 + w, 3, Hi); p(c, 8 + w, 5, Hi); p(c, 9 + w, 4, Hi); }
  });
  G8('sunrock', function (c, w, fr, C, A, Hi, K) {      /* a sun-warmed boulder with a fat python loop draped over it, heat shimmer rising, the sun turning */
    var a, b, r = 5 + w, i;
    for (b = 0; b <= r; b++) { var hw = Math.round(Math.sqrt(r * r - b * b) * 1.2); for (a = -hw; a <= hw; a++) p(c, a, b, (a * 3 + b * 7 + 40) % 9 === 0 ? ROCKD : ROCK); }
    for (i = 1; i < 12; i++) { a = Math.round(ARA[i] * (r + 1) * 1.2); b = Math.round(ARB[i] * (r + 1)); p(c, a, b, (i % 4 === 0) ? A : C); p(c, a, b + 1, i % 3 === 0 ? Hi : C); }
    for (b = r + 4; b <= r + 7; b++) p(c, Math.round(Math.sin(b + fr * 1.57) * 1.5) - 2, b, Hi);
    for (b = r + 5; b <= r + 7; b++) p(c, Math.round(Math.sin(b + fr * 1.57 + 2) * 1.5) + 2, b, Hi);
    p(c, 8, r + 6, SUN); p(c, 9, r + 6, SUN); p(c, 8, r + 7, SUN); p(c, 9, r + 7, SUN); p(c, 8 + (fr & 1), r + 9 - (fr >> 1), SUN);
  });
  G8('rockblend', function (c, w, fr, C, A, Hi, K) {    /* three blotchy rocks; the middle one opens an eye and slides: it was the python all along */
    var k, a, b, ca, r, mv = fr === 3 ? 1 : 0;
    for (k = -1; k <= 1; k++) {
      ca = k * 6 + (k === 0 ? mv : 0); r = k === 0 ? 3 + w : 2;
      for (b = 0; b <= r; b++) for (a = -r - 1 + b; a <= r + 1 - b; a++) p(c, ca + a, b, k === 0 ? ((a * 3 + b * 5 + 40) % 4 === 0 ? A : C) : ((a + b * 3 + 40) % 4 === 0 ? ROCKD : ROCK));
    }
    if (fr >= 2) { p(c, -1 + mv, 2, Hi); p(c, 1 + mv, 2, Hi); p(c, mv, 2, A); p(c, mv, 3, Hi); }
    if (fr === 1) { p(c, mv, 2, A); }
  });
  G8('lippits', function (c, w, fr, C, A, Hi, K) {      /* a long python head with a row of heat pits along the lip lighting up one by one, then the warm shimmer of prey ahead */
    var a, k;
    for (a = -7 - w; a <= 5; a++) { p(c, a, 3, C); p(c, a, 4, C); if (a < 4) p(c, a, 5, C); p(c, a, 2, Hi); }
    p(c, 6, 3, C); p(c, 6, 4, C); p(c, 2, 5, A); p(c, 2, 6, C);
    for (k = 0; k < 4; k++) p(c, -4 + k * 2, 2, k <= fr ? (k === fr ? HEAT : SUN) : A);
    if (fr === 3) { for (k = 0; k < 3; k++) { p(c, 9 + w, 2 + k, PR); p(c, 10 + w, 3 + k, HEAT); } }
  });
  /* --- grass snake --- */
  G8('collarswim', function (c, w, fr, C, A, Hi, K) {   /* an olive grass snake swimming the surface in an S, head up, the bright yellow and black collar behind it */
    var a, bb;
    for (a = -8 - w; a <= 3; a++) { bb = 2 + Math.round(Math.sin(a * .6 + fr * 1.57) * 1.5); p(c, a, bb, C); p(c, a, bb + 1, (a & 3) === 1 ? A : C); if (a % 3 === 0) p(c, a, bb - 1, WATER); }
    p(c, 4, 3, A); p(c, 4, 4, A); p(c, 5, 3, COLLAR); p(c, 5, 4, COLLAR); p(c, 5, 5, COLLAR);
    row(c, 6, 8, 4, C); row(c, 6, 8, 5, C); p(c, 9, 4, C); p(c, 7, 5, A); p(c, 8, 6, Hi);
    p(c, 10, 2, WATER); p(c, 11, 1, WATER); p(c, 10, 6, WATER);
  });
  G8('collarhead', function (c, w, fr, C, A, Hi, K) {   /* a grass snake head rising out, the yellow collar flashing; it strikes, then flicks its tongue */
    var sb = fr === 0 ? -2 : fr === 2 ? 2 : 0;
    cl(c, 0, 0, 3 + sb, C); cl(c, 1, 0, 3 + sb, C); p(c, -1, 1, A);
    row(c, -1, 2, 4 + sb, A); row(c, -1, 2, 5 + sb, COLLAR); row(c, -1, 2, 6 + sb, COLLAR);
    row(c, -1, 2, 7 + sb, C); row(c, -1, 2, 8 + sb, C); row(c, 0, 1, 9 + sb, C); p(c, -1, 8 + sb, A); p(c, 2, 8 + sb, A);
    if (fr === 2) { p(c, 0, 10 + sb, A); p(c, 1, 10 + sb, Hi); }
    if (fr === 3) { cl(c, 0, 10, 11, TONGUE); p(c, -1, 12, TONGUE); p(c, 1, 12, TONGUE); }
  });
  G8('deadsnake', function (c, w, fr, C, A, Hi, K) {    /* the grass snake playing dead: writhing, rolling belly up (chequered belly), limp with the tongue lolling, one eye peeking */
    var a, bb, amp = fr < 2 ? 1.5 : 0;
    for (a = -8 - w; a <= 4; a++) { bb = 3 + Math.round(Math.sin(a * .7 + fr * 2) * amp); p(c, a, bb, fr ? ((a & 1) ? A : BELLY) : C); p(c, a, bb + 1, fr ? C : ((a & 3) === 0 ? A : C)); }
    row(c, 5, 7, 3, fr ? BELLY : C); row(c, 5, 7, 4, C); p(c, 6, 4, A);
    if (fr >= 2) { p(c, 8, 2, TONGUE); p(c, 9, 1, TONGUE); p(c, 8, 3, A); }
    if (fr === 3) { p(c, 6, 5, Hi); p(c, 6, 6, K.WHITE); }
    if (fr === 1) { p(c, -2, 6, Hi); p(c, 2, 6, Hi); }
  });
  /* --- emerald python --- */
  G8('saddle', function (c, w, fr, C, A, Hi, K) {       /* coils saddled over a branch in loose loops, white flecks down the back, the head resting in the middle */
    var a, i, dl = fr === 2 ? 1 : 0;
    for (a = -9 - w; a <= 9 + w; a++) { p(c, a, 5, BARK); p(c, a, 4, (a & 3) ? BARK : BARKD); }
    for (i = -1; i <= 1; i += 2) {
      arch(c, i * 5, 5, 3, -1.2 - dl * .3, C, 1); arch(c, i * 5, 5, 2, -1.1 - dl * .3, C, 2);
      p(c, i * 5, 1 - dl, Hi); p(c, i * 5 + 2, 2, K.WHITE);
      row(c, i * 5 - 3, i * 5 + 3, 6, C); p(c, i * 5 - 1, 6, K.WHITE);
    }
    row(c, -2, 2, 7, C); row(c, -1, 2, 8, C); p(c, 1, 8, A); p(c, 2, 7, Hi); p(c, -1, 7, K.WHITE);
    if (fr === 3) { p(c, 3, 8, TONGUE); p(c, 4, 9, TONGUE); p(c, 4, 7, TONGUE); }
  });
  G8('hang', function (c, w, fr, C, A, Hi, K) {         /* the python hanging down from a branch stub, swinging; the head lunges with long front teeth bared */
    var sw = [-2, 0, 2, 0][fr], b, a;
    row(c, -3, 3, 14 + w, BARK); p(c, -3, 13 + w, BARKD);
    for (b = 4; b <= 13 + w; b++) { a = Math.round(sw * (13 + w - b) / 9); p(c, a, b, C); p(c, a + 1, b, b % 3 === 0 ? K.WHITE : C); }
    a = sw; row(c, a - 1, a + 2, 3, C); row(c, a - 1, a + 2, 2, C); row(c, a, a + 1, 1, C); p(c, a - 1, 3, Hi); p(c, a + 2, 3, Hi);
    if (fr === 2) { p(c, a - 1, 1, IVORY); p(c, a + 2, 1, IVORY); p(c, a - 1, 0, IVORY); p(c, a + 2, 0, IVORY); row(c, a, a + 1, 1, A); }
  });
  G8('liana', function (c, w, fr, C, A, Hi, K) {        /* a liana with the python's tail wound round it: coiled, uncoiling, whipping straight with a crack, curling back */
    var a, b;
    for (a = -9; a <= 9; a++) p(c, a, 4 + Math.round(Math.sin(a * .5)), (a & 3) ? BARK : BARKD);
    if (fr === 0 || fr === 3) { for (a = -3; a <= 3; a++) { p(c, a, 3 + ((a + 3) & 1) * 3, C); } p(c, 4, 5, C); p(c, -1, 6, Hi); if (fr === 3) { p(c, 3, 7, C); p(c, 2, 8, C); } }
    else if (fr === 1) { for (b = 5; b <= 9; b++) p(c, Math.round((b - 5) * .6), b, C); p(c, 3, 10, C); p(c, 1, 7, Hi); }
    else { for (b = 5; b <= 12 + w; b++) p(c, 0, b, b % 3 === 0 ? Hi : C); p(c, -1, 14 + w, K.WHITE); p(c, 1, 14 + w, K.WHITE); p(c, 0, 15 + w, K.WHITE); p(c, -2, 13 + w, Hi); p(c, 2, 13 + w, Hi); }
  });
  G8('swallow', function (c, w, fr, C, A, Hi, K) {      /* a long python with a fat lump of a meal sliding slowly down its body, head content */
    var a, l0 = -5 + fr * 3;
    for (a = -9 - w; a <= 7; a++) { p(c, a, 2, C); p(c, a, 3, (a % 4 === 0) ? K.WHITE : C); if (a % 5 === 0) p(c, a, 2, A); }
    for (a = l0 - 1; a <= l0 + 1; a++) { p(c, a, 1, C); p(c, a, 4, C); } p(c, l0, 5, C); p(c, l0, 0, C); p(c, l0, 4, Hi);
    row(c, 8, 9, 2, C); row(c, 8, 10, 3, C); p(c, 9, 3, A); p(c, 10, 2, Hi);
  });

  /* ================= motions ================= */
  function cyc(n) { return function (G, pp, k) { G.fr = (Math.floor(pp * n) + k) & 3; }; }
  function beat(rate, cuts, dpush) { return function (G, pp, k, ph) { var w = (pp * rate + ph) % 1, f = w < cuts[0] ? 0 : w < cuts[1] ? 1 : w < cuts[2] ? 2 : 3; G.fr = f; G.d += dpush[f]; }; }
  function once(G, pp, k, ph) { var u = Math.min(.999, Math.max(0, G.u * 1.1 + ph * .1)); G.fr = Math.floor(u * 4); }   /* runs through its 4 frames once over the layout */
  PFA.motion('L08-grind', function (G, pp, k, ph) { var w = (pp * 2.4 + ph) % 1; G.fr = w < .25 ? 0 : w < .4 ? 1 : w < .8 ? 2 : 3; if (G.fr === 2) G.t += (Math.floor(pp * 24) & 1) ? .7 : -.7; });   /* gape, clamp, grind, venom */
  PFA.motion('L08-throb', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 2) + k) & 3; });
  PFA.motion('L08-stomp', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .4 ? 0 : w < .55 ? 1 : w < .8 ? 2 : 3; G.up += G.fr === 0 ? 2 : 0; });
  PFA.motion('L08-once', once);
  PFA.motion('L08-breach', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 1.8 + ph) % 1) * 4); G.t += Math.sin(pp * 3 + k) * 1.5; });            /* ripple, emerge, arch, dive */
  PFA.motion('L08-stab', beat(2.6, [.35, .5, .75], [0, 0, 2, 0]));
  PFA.motion('L08-cyc7', cyc(7));
  PFA.motion('L08-glassslide', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; G.t += Math.sin(pp * 3 + k) * 2; });
  PFA.motion('L08-cyc5', cyc(5));
  PFA.motion('L08-plod', function (G, pp, k) { var st = Math.floor(pp * 4) + k; G.fr = st & 3; G.t += (st & 1) * .6; });
  PFA.motion('L08-chomp', beat(3, [.3, .5, .75], [0, 0, 0, 0]));
  PFA.motion('L08-rockflop', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.fr = w < .15 ? 0 : w < .8 ? 1 + ((Math.floor(pp * 8) + k) & 1) : 3; });   /* rocking on its back, then right side up */
  PFA.motion('L08-cyc6', cyc(6));
  PFA.motion('L08-ram', function (G, pp, k, ph) { var w = (pp * 2.2 + ph) % 1; G.fr = w < .4 ? 0 : w < .55 ? 1 : w < .75 ? 2 : 3; });
  PFA.motion('L08-jab', beat(2.8, [.3, .45, .7], [0, 0, 1, 0]));
  PFA.motion('L08-broodpop', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 3 + ph * 2) + k) & 3; });
  PFA.motion('L08-strike4', beat(2.4, [.3, .45, .7], [0, -1, 2, 0]));
  PFA.motion('L08-squeeze', function (G, pp, k) { G.fr = (Math.floor(pp * 3) + k) & 3; G.t += Math.sin(pp * 2 + k) * .6; });
  PFA.motion('L08-gape', beat(2.2, [.25, .5, .8], [0, 0, 1, 0]));
  PFA.motion('L08-cyc4', cyc(4));
  PFA.motion('L08-blend', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 2.5 + ph * 3) + k) & 3; });
  PFA.motion('L08-sswim', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; G.t += Math.sin(pp * 4 + k) * 1.5; });
  PFA.motion('L08-collar', beat(2.4, [.3, .5, .75], [0, 0, 2, 0]));
  PFA.motion('L08-drape', function (G, pp, k) { G.fr = (Math.floor(pp * 2.5) + k) & 3; G.up += Math.sin(pp * 2 + k) * .8; });
  PFA.motion('L08-whip', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2.4 + ph) % 1) * 4); });
  PFA.motion('L08-cyc3', cyc(3));

  /* ================= custom chain effects (along the OUTER loop from e.a over e.d, eased e.hh) ================= */
  function at(e, H, u, h) { e.P.atq(e.a + e.d * u); H.Q.x += H.Q.nx * h; H.Q.y += H.Q.ny * h; return H.Q; }
  function head(c, e, H, g, u, h, fr, z) { var P = e.P, Q = H.Q, sd = e.d < 0 ? -1 : 1; P.atq(e.a + e.d * u); H.glyph(c, g, Q.x + Q.nx * h, Q.y + Q.ny * h, z, fr, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny); }
  function carGila(c, e, H) {           /* the gila dragon plods to the next piece: a beaded body behind its head, the fat tail scoring a groove, claw prints left and right */
    var k, u, Q, st = Math.floor(e.p * 10);
    for (k = 1; k <= 8; k++) { u = e.hh - k * .025; if (u < 0) break; Q = at(e, H, u, 4); H.sq(c, Q.x, Q.y, 3, (k + st) % 3 === 0 ? e.acc : e.col); }
    for (u = Math.max(0, e.hh - .5); u < e.hh - .2; u += .03) { Q = at(e, H, u, 2); H.px(c, Q.x, Q.y, e.acc); }
    for (k = 1; k <= 4; k++) { u = e.hh - k * .09; if (u < 0) break; Q = at(e, H, u, k & 1 ? 1 : 7); H.px(c, Q.x - 1, Q.y, e.acc); H.px(c, Q.x + 1, Q.y, e.acc); H.px(c, Q.x, Q.y - 1, e.acc); }
    head(c, e, H, 'L08-gilahead', e.hh, 2, st & 1 ? 1 : 2, 0);
  }
  function carDune(c, e, H) {           /* the wyrm swims through the dunes to the next piece: humps breach and sink behind the head, sand spits up */
    var k, u, Q, r, ht, j;
    for (k = 0; k < 4; k++) { u = e.hh - k * .09; if (u < 0) break; ht = Math.max(0, Math.sin(e.p * 9 - k * 1.3)) * (4 - k * .6);
      for (j = -3; j <= 3; j++) { r = Math.round(Math.sqrt(Math.max(0, 9 - j * j)) / 3 * ht); e.P.atq(e.a + e.d * u + j); Q = H.Q; H.px(c, Q.x + Q.nx * (2 + r), Q.y + Q.ny * (2 + r), j === 0 ? e.hi : e.col); }
      Q = at(e, H, u, 1); H.px(c, Q.x - 2, Q.y, SANDD); H.px(c, Q.x + 2, Q.y, SANDD); }
    head(c, e, H, 'L08-dunewyrm', e.hh, 2, 1, e.z > 1 ? 1 : e.z);
    if (e.hh > .9) { Q = at(e, H, e.hh, 9); H.px(c, Q.x - 2, Q.y, SAND); H.px(c, Q.x + 3, Q.y - 1, SAND); }
  }
  function carGlass(c, e, H) {          /* a hollow glass serpent slides to the next piece: two outline rails, nothing inside, a white glint and a tiny rainbow riding along it */
    var u, Q, g = (e.p * 3) % 1, i = 0, u0 = Math.max(0, e.hh - .3), o;
    for (u = u0; u <= e.hh; u += .02, i++) { o = Math.sin(i * .5 + e.p * 10) * 1.5; Q = at(e, H, u, 4 + o); H.px(c, Q.x, Q.y, e.col); Q = at(e, H, u, 8 + o); H.px(c, Q.x, Q.y, e.col); }
    u = u0 + (e.hh - u0) * g; Q = at(e, H, u, 6); H.px(c, Q.x, Q.y, '#ffffff'); Q = at(e, H, u, 5); H.px(c, Q.x, Q.y, PR); Q = at(e, H, u, 6.5); H.px(c, Q.x - 1, Q.y, PG); Q = at(e, H, u, 7.5); H.px(c, Q.x, Q.y, PB);
    head(c, e, H, 'L08-glasscoil', e.hh, 1, Math.floor(e.p * 8) & 3, 0);
  }
  function carTortoise(c, e, H) {       /* the tortoise trundles to the next piece leaving its track: two dotted foot rows and the tail drag line between */
    var u, Q, i = 0;
    for (u = 0; u < e.hh - .05; u += .03, i++) { Q = at(e, H, u, 1); if (i & 1) H.px(c, Q.x, Q.y, e.acc); Q = at(e, H, u, 6); if (!(i & 1)) H.px(c, Q.x, Q.y, e.acc); if (i % 3 === 0) { Q = at(e, H, u, 3.5); H.px(c, Q.x, Q.y, SANDD); } }
    head(c, e, H, 'L08-tortoise', e.hh, 1, Math.floor(e.p * 8) & 3, e.z > 1 ? 1 : e.z);
  }
  function carSulcata(c, e, H) {        /* the spurred tortoise charges to the next piece: speed dashes and kicked dust behind, a crash burst on arrival */
    var k, u, Q, v = Math.min(1, e.hh * 1.15);
    for (k = 1; k <= 4; k++) { u = v - k * .06; if (u < 0) break; Q = at(e, H, u, 3 + k * 2); H.px(c, Q.x, Q.y, e.hi); Q = at(e, H, u - .02, 3 + k * 2); H.px(c, Q.x, Q.y, e.hi); Q = at(e, H, u, 1); H.sq(c, Q.x, Q.y - (k & 1), 2, SANDD); }
    head(c, e, H, 'L08-sulcata', v, 1, v >= 1 ? 2 : 1, e.z > 1 ? 1 : e.z);
    if (v >= 1) { Q = at(e, H, 1, 6); H.plus(c, Q.x, Q.y, 3, 1, '#ffffff'); }
  }
  function carBrood(c, e, H) {          /* the viper mother sidewinds to the next piece and her brood follows in a file of little S shapes */
    var k, u, Q, j, o;
    for (k = 1; k <= 3; k++) { u = e.hh - k * .1; if (u < 0) break;
      for (j = -3; j <= 3; j++) { o = Math.sin(j * 1.2 + e.p * 20 + k) * 1.5; e.P.atq(e.a + e.d * u + j); Q = H.Q; H.px(c, Q.x + Q.nx * (4 + o), Q.y + Q.ny * (4 + o), j === 3 ? e.acc : e.col); } }
    for (j = -7; j <= 7; j++) { o = Math.sin(j * .8 + e.p * 16) * 2; e.P.atq(e.a + e.d * e.hh + j); Q = H.Q; H.sq(c, Q.x + Q.nx * (5 + o), Q.y + Q.ny * (5 + o), 2, (j + 40) % 4 === 0 ? e.acc : e.col); }
    for (k = 0; k < 4; k++) { u = e.hh - .05 - k * .07; if (u < 0) break; Q = at(e, H, u, 1); H.px(c, Q.x, Q.y, SANDD); H.px(c, Q.x + 1, Q.y + 1, SANDD); }
  }
  function carPython(c, e, H) {         /* the barrel-thick python creeps dead straight to the next piece: a thick blotched body, the blotches fixed to it, belly scutes ticking */
    var u, Q, u0 = Math.max(0, e.hh - .35), s, i, step = Math.floor(e.p * 12);
    for (u = u0, i = 0; u <= e.hh; u += .018, i++) {
      s = Math.floor((u - e.hh) * 55);
      Q = at(e, H, u, 3); H.px(c, Q.x, Q.y, (s & 3) === 0 ? e.acc : e.col); Q = at(e, H, u, 4); H.px(c, Q.x, Q.y, (s % 5 === 0) ? e.acc : e.col);
      Q = at(e, H, u, 5); H.px(c, Q.x, Q.y, (s & 1) ? e.hi : e.col); if (((i + step) & 3) === 0) { Q = at(e, H, u, 2); H.px(c, Q.x, Q.y, e.acc); }
    }
    head(c, e, H, 'L08-gape', e.hh, 1, 0, 0);
  }
  function carCollar(c, e, H) {         /* the grass snake swims to the next piece in an S, collar flashing, a V of ripples opening behind */
    var k, u, Q;
    for (k = 1; k <= 5; k++) { u = e.hh - k * .04; if (u < 0) break; Q = at(e, H, u, 4 + k * 1.2); H.px(c, Q.x, Q.y, WATER); if (k > 1) { Q = at(e, H, u, 4 - k * .6); H.px(c, Q.x, Q.y, WATER); } }
    head(c, e, H, 'L08-collarswim', e.hh, 1, Math.floor(e.p * 12) & 3, 0);
  }
  function carSaddle(c, e, H) {         /* a liana grows along the edge to the next piece and the emerald python flows along it, loops hanging */
    var u, Q, i = 0;
    for (u = 0; u <= e.hh; u += .02, i++) { Q = at(e, H, u, 9 + Math.sin(i * .6)); H.px(c, Q.x, Q.y, (i & 3) ? BARK : BARKD); }
    head(c, e, H, 'L08-saddle', e.hh, 1, Math.floor(e.p * 6) & 3, 0);
  }

  /* ================= motifs ================= */
  function M(name, meta) { PFA.motif(name, comp, meta); }
  /* gila dragon */
  M('gila-grind', { nm: 'grinding gila jaws', desc: 'a huge pink-and-black beaded lizard head side-on that gapes, clamps on, grinds its jaws and lets venom run down the grooves; the chain is the gila dragon plodding along with its fat tail scoring a groove and claw prints left and right', fam: 'bite', gap: 18, g: 'L08-gilahead', mo: 'L08-grind', x: '-', car: 'custom', carDraw: carGila });
  M('lingering-bite', { nm: 'lingering bite', desc: 'two arcs of tooth punctures with venom in the middle and ache rings throbbing out and out from them', fam: 'drip', gap: 18, g: 'L08-bitemark', mo: 'L08-throb', x: '-', car: 'rings' });
  M('gila-stomp', { nm: 'beaded stomp', desc: 'a fat five-clawed beaded foot lifted and slammed down, cracks running out to the sides, dust jumping', fam: 'bash', gap: 16, g: 'L08-gilafoot', mo: 'L08-stomp', x: 'dust', car: 'hop' });
  M('quake-crack', { nm: 'quake cracks', desc: 'zigzag cracks splitting outward from the edge, crust chunks jumping and dust puffing', fam: 'ripple', gap: 14, g: 'L08-quake', mo: 'L08-once', x: '-', car: 'zig' });
  /* dune wyrmling */
  M('dune-breach', { nm: 'dune breach', desc: 'a pale sand wyrm coil breaching out of a dune in an arch and diving back, sand spraying, a needle fang showing; the chain is the wyrm swimming through the sand in humps that rise and sink', fam: 'thrust', gap: 18, g: 'L08-dunewyrm', mo: 'L08-breach', x: '-', car: 'custom', carDraw: carDune });
  M('needle-fangs', { nm: 'needle fangs', desc: 'a wyrm head facing out that gapes and stabs with two long thin needle fangs, a venom bead at each tip', fam: 'thrust', gap: 14, g: 'L08-needlefang', mo: 'L08-stab', x: '-', car: 'comet' });
  M('sand-hiss', { nm: 'sand hiss', desc: 'a gaping head with an S of hiss blowing out of it and sand grains carried along in the breath', fam: 'puff', gap: 16, g: 'L08-sandhiss', mo: 'L08-cyc7', x: '-', car: 'cloud' });
  /* glass wyrm */
  M('glass-coil', { nm: 'glass serpent', desc: 'a hollow glass serpent: only the outline of an S-curved body, a white glint and a tiny rainbow travelling through it; the chain is the glass serpent sliding along on two outline rails with the prism glint riding it', fam: 'bash', gap: 20, g: 'L08-glasscoil', mo: 'L08-glassslide', x: '-', car: 'custom', carDraw: carGlass });
  M('glass-shatter', { nm: 'shattering tail', desc: 'a glass tail tip that cracks and flies apart into shards that glint as they scatter', fam: 'slash', gap: 16, g: 'L08-shatter', mo: 'L08-once', x: '-', car: 'comet' });
  M('prism-scale', { nm: 'prism scales', desc: 'hollow hexagonal glass scales with a rainbow band sweeping across them', fam: 'shield', gap: 14, g: 'L08-prism', mo: 'L08-cyc5', x: '-', car: 'train' });
  M('glass-wake', { nm: 'waking glass eye', desc: 'a glass eye warming in the sun: shut, half open, open with a slit pupil and a glint, warm rays round it', fam: 'mend', gap: 16, g: 'L08-glasseye', mo: 'L08-once', x: '-', car: 'blink' });
  /* desert tortoise */
  M('ringed-scute', { nm: 'ringed dome', desc: 'a desert tortoise side-on: a high dome of scutes with growth rings, stumpy elephant legs stepping, a horny beak; the chain is the tortoise trundling along leaving two dotted foot rows and a tail drag line', fam: 'shield', gap: 20, g: 'L08-tortoise', mo: 'L08-plod', x: '-', car: 'custom', carDraw: carTortoise });
  M('cactus-chomp', { nm: 'cactus chomp', desc: 'a prickly-pear pad with a red fruit; a tortoise beak gapes, crunches a notch out of it and chews', fam: 'bite', gap: 16, g: 'L08-cactus', mo: 'L08-chomp', x: '-', car: 'hop' });
  M('boulder-flop', { nm: 'flipped tortoise', desc: 'a tortoise flipped onto its back like a boulder, rocking with its legs waving, then thumping right side up in dust', fam: 'bash', gap: 18, g: 'L08-flop', mo: 'L08-rockflop', x: 'dust', car: 'roll' });
  M('shell-in', { nm: 'shell in', desc: 'a tortoise pulling in: head out, head half in, the scaly forelegs folding over the opening, shut tight with a tink', fam: 'shield', gap: 18, g: 'L08-shellin', mo: 'L08-once', x: '-', car: 'train' });
  M('gopher-dig', { nm: 'burrow dig', desc: 'shovel forelegs digging a burrow, the dome sinking a little each beat, sand arcs thrown back', fam: 'puff', gap: 18, g: 'L08-dig', mo: 'L08-cyc6', x: 'dust', car: 'tunnel' });
  M('rain-wait', { nm: 'waiting for rain', desc: 'a blazing sun, a cloud gathering, rain falling, a puddle with a beak sipping: the long desert wait', fam: 'mend', gap: 18, g: 'L08-rain', mo: 'L08-once', x: '-', car: 'flutter' });
  /* spurred tortoise */
  M('spur-ram', { nm: 'spur ram', desc: 'a stout yellow tortoise with a serrated shell rim, a forked gular horn and conical thigh spurs: set, lunge, crash, recoil; the chain is the tortoise charging with speed dashes and kicked dust, a crash burst on arrival', fam: 'bash', gap: 20, g: 'L08-sulcata', mo: 'L08-ram', x: '-', car: 'custom', carDraw: carSulcata });
  M('thigh-spur', { nm: 'thigh spurs', desc: 'a thick scaly leg with three conical spurs jutting out and jabbing', fam: 'thorn', gap: 14, g: 'L08-spur', mo: 'L08-jab', x: '-', car: 'train' });
  /* sand viper matriarch */
  M('viper-brood', { nm: 'viper brood', desc: 'the mother viper\'s heavy horned coils with her live-born young peeking up out of them one by one, tongues flicking; the chain is the mother sidewinding with her brood following in a file of little S shapes', fam: 'web', gap: 22, g: 'L08-brood', mo: 'L08-broodpop', x: '-', car: 'custom', carDraw: carBrood });
  M('brood-hiss', { nm: 'brood hiss', desc: 'three tiny viper heads in a row, mouths gaping, little S hiss lines puffing above them', fam: 'web', gap: 18, g: 'L08-broodhiss', mo: 'L08-cyc4', x: '-', car: 'cloud' });
  M('sand-ambush', { nm: 'sand ambush', desc: 'horn tips and eyes showing in the sand, the sand bulging, the head erupting open-mouthed in a spray, sand raining back', fam: 'slash', gap: 18, g: 'L08-ambush', mo: 'L08-once', x: '-', car: 'tunnel' });
  M('arrow-head', { nm: 'arrowhead strike', desc: 'a broad arrowhead viper head pointing out with glowing heat pits that rears, strikes with the fangs out and drips venom', fam: 'drip', gap: 16, g: 'L08-arrowhead', mo: 'L08-strike4', x: '-', car: 'comet' });
  /* rock python */
  M('barrel-coil', { nm: 'barrel coils', desc: 'three barrel-thick blotched coils stacked and tightening, creak marks at the sides, the head resting on top; the chain is the python creeping dead straight with its blotches fixed to the body', fam: 'bash', gap: 20, g: 'L08-barrel', mo: 'L08-squeeze', x: '-', car: 'custom', carDraw: carPython });
  M('python-gape', { nm: 'python gape', desc: 'a python head side-on opening wide on rows of small hooked teeth, then snapping shut', fam: 'bite', gap: 16, g: 'L08-gape', mo: 'L08-gape', x: '-', car: 'comet' });
  M('sun-rock', { nm: 'sun rock', desc: 'a warm boulder with a fat python loop draped over it, heat shimmer rising and a small sun turning', fam: 'mend', gap: 20, g: 'L08-sunrock', mo: 'L08-cyc4', x: '-', car: 'hop' });
  M('rock-blend', { nm: 'rock blend', desc: 'three blotchy rocks in a row; the middle one opens an eye and slides: it was the python all along', fam: 'puff', gap: 20, g: 'L08-rockblend', mo: 'L08-blend', x: '-', car: 'blink' });
  M('lip-pits', { nm: 'heat pits', desc: 'a long python head with heat pits along the lip lighting up one by one, then the warm shimmer of prey ahead', fam: 'thrust', gap: 18, g: 'L08-lippits', mo: 'L08-cyc5', x: '-', car: 'comet' });
  /* grass snake */
  M('collar-swim', { nm: 'collared swimmer', desc: 'an olive grass snake swimming the surface in an S with the head up and a bright yellow and black collar behind it; the chain is the snake swimming on with a V of ripples opening behind', fam: 'ripple', gap: 20, g: 'L08-collarswim', mo: 'L08-sswim', x: '-', car: 'custom', carDraw: carCollar });
  M('collar-flash', { nm: 'collar flash', desc: 'a grass snake head rising out with its yellow collar flashing, striking, then flicking a red forked tongue', fam: 'bite', gap: 14, g: 'L08-collarhead', mo: 'L08-collar', x: '-', car: 'comet' });
  M('play-dead', { nm: 'playing dead', desc: 'the grass snake writhing, rolling belly up to show its chequered belly, going limp with the tongue lolling, one eye peeking', fam: 'shield', gap: 20, g: 'L08-deadsnake', mo: 'L08-once', x: '-', car: 'roll' });
  /* emerald python */
  M('branch-saddle', { nm: 'branch saddle', desc: 'emerald coils saddled over a branch in loose loops with white flecks down the back and the head resting in the middle; the chain is a liana growing along the edge with the python flowing along it', fam: 'shield', gap: 22, g: 'L08-saddle', mo: 'L08-drape', x: '-', car: 'custom', carDraw: carSaddle });
  M('hang-strike', { nm: 'hanging strike', desc: 'a python hanging down from a branch stub, swinging, then lunging with its long front teeth bared', fam: 'bite', gap: 16, g: 'L08-hang', mo: 'L08-cyc5', x: '-', car: 'thread' });
  M('liana-tail', { nm: 'liana tail', desc: 'a prehensile tail wound round a liana that uncoils and whips straight with a crack, then curls back', fam: 'slash', gap: 18, g: 'L08-liana', mo: 'L08-whip', x: '-', car: 'comet' });
  M('slow-swallow', { nm: 'slow swallow', desc: 'a long python with the fat lump of a meal sliding slowly down its body', fam: 'mend', gap: 22, g: 'L08-swallow', mo: 'L08-cyc3', x: '-', car: 'trail' });
})();
