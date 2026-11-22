/* Motif module, large batch L09 (saltwater-gharial, delta-gharial, alligator-snapper, mire-toad, elder-mire-toad, goliath-frog, reef-turtle, leatherback).
   TEMPLATE.md sections 9 and 10.3. 32 motifs, each with its own pixel glyph (ids prefixed L09-) and a motion; five have their own chain effect (carDraw):
   a gharial cruising with only its eyes above water and a V wake, a little fish lured along by the snapper's pink worm, a goliath frog crossing in one
   huge leap with a splash, a hawksbill swimming over a strip of coral, a leatherback diving under and resurfacing at the next piece.
   Glyph coordinates are (a, b): a along the edge tangent, b outward along the normal, so every sprite turns with the edge it sits on. fr0() stores the
   frame in module scratch variables, p()/s()/row()/cl()/lin() plot in (a, b). Glyph draws never nest, so the scratch is safe; nothing is allocated per
   frame (the constant tables below are built once at load), there is no Math.random / Date, every effect is a stateless function of p.
   Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy
   default are untouched (they live in the page). Glyphs reach at most ~16 px out and stay within ~22 px of the edge with their layout offset. */
(function () {
  var X0 = 0, Y0 = 0, TX = 1, TY = 0, NX = 0, NY = -1, KK = null;
  var WATER = '#7aa6b8', TOOTH = '#f2ecd8', BELLY = '#e6e2c4', MUD = '#6a5232', WEED = '#6a9a3a', PINK = '#f07a9a', FISH = '#d2dce4', SLIME = '#d4ecdc',
    GAS = '#b4c860', GOLD = '#e8c050', MOSS = '#a8d060', CRAB = '#d8643a', STONE = '#a49c8c', FLIP = '#c8b890', SPOT = '#f0d080', YFISH = '#f4d040',
    BEAK = '#e8d8a8', SPONGE = '#e8845a', JELLY = '#e8b4e0', GLOW = '#7ae0ff';
  var CORAL = ['#f07a6a', '#f0b040', '#c070e0', '#f07a6a', '#60d0b0', '#f0b040'];
  var SW = [-3, 3, 0, 0], GROW = [0, 1, 2, 1], TB = [-5, -1, 5, 3], GL = [7, 6, 10, 10], SL = [2, 4, 6, 3], TL = [0, 5, 10, 6], SR = [1, 3, 0, 0],
    MG = [0, 1, 2, 1], BUL = [0, 2, 4, 1], FA = [2, 6, 10, 7], FB = [10, 8, 1, 5], TFA = [-8, -9, -8, -9], TFB = [10, 7, 3, 7],
    LFA = [-10, -11, -9, -11], LFB = [11, 7, 2, 6], OA = [-11, -5, 5, 11], OB = [3, 10, 10, 3], AR = [4, 3, 2, 0], TW = [2, 3, 4, 4, 4, 3, 2];
  var CUP = [], i0;                                                       /* 12 ring directions, built once */
  for (i0 = 0; i0 < 12; i0++) { CUP.push(Math.cos(i0 * Math.PI / 6)); CUP.push(Math.sin(i0 * Math.PI / 6)); }

  function fr0(x, y, tx, ty, nx, ny, K) { X0 = x; Y0 = y; TX = tx; TY = ty; NX = nx; NY = ny; KK = K; }
  function p(c, a, b, col) { KK.px(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, col); }
  function s(c, a, b, w, col) { KK.sq(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, w, col); }
  function row(c, a0, a1, b, col) { for (var a = a0; a <= a1; a++) p(c, a, b, col); }
  function cl(c, a, b0, b1, col) { for (var b = b0; b <= b1; b++) p(c, a, b, col); }
  function lin(c, a0, b0, a1, b1, col) { var n = Math.max(Math.abs(a1 - a0), Math.abs(b1 - b0)), i; if (n < 1) { p(c, a0, b0, col); return; }
    for (i = 0; i <= n; i++) p(c, a0 + (a1 - a0) * i / n, b0 + (b1 - b0) * i / n, col); }
  function ring(c, ac, bc, r, col, every) { for (var i = 0; i < 12; i += every) p(c, ac + CUP[i * 2] * r, bc + CUP[i * 2 + 1] * r, col); }
  function star(c, a, b, col) { p(c, a, b, col); p(c, a - 1, b - 1, col); p(c, a + 1, b - 1, col); p(c, a - 1, b + 1, col); p(c, a + 1, b + 1, col); }

  /* ---------- shared own-edge composition: the page's themedOwn() with this module's glyph / motion (glyphs capped at 7 per run) ---------- */
  function comp(c, e, H) {
    var runs = e.runs, mp = e.mp, M = e.M, z = e.z, pr = e.p, pp = pr * mp.spd, Q = H.Q, G = H.G, P = e.P,
      tie = mp.x === 'thread' || mp.lay === 'snare', ri, k, r, len, n, ph, sf, bx0, by0, nx, ny, x, y, lx = 0, ly = 0, has;
    for (ri = 0; ri < runs.length; ri++) {
      r = runs[ri]; len = r[1] - r[0]; n = Math.max(1, Math.min(7, Math.round(len / (M.gap || 12)))); if (mp.lay === 'lance') n = Math.min(n, 4); has = false;
      for (k = 0; k < n; k++) {
        ph = H.hash(e.seed * 13 + k * 7 + ri * 31);
        H.lay(mp.lay, pr, (k + .5) / n, ph, k); H.mot(M.mo, pp, k, ph);
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
  /* --- saltwater gharial: grey-green, salt crust, a very long thin snout lined with needle teeth --- */
  PFA.glyph('L09-saltsnout', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* the long snout swung sideways through the water, open, snapped shut, the spray */
    fr0(x, y, tx, ty, nx, ny, K); var L = 10 + (z > 1 ? 1 : 0), sw = SW[fr], op = fr === 1 ? 2 : 0, b, a, q;
    row(c, -3, 3, 0, C); row(c, -2, 2, 1, C); p(c, -2, 2, C); p(c, 2, 2, C); p(c, -2, 3, A); p(c, 2, 3, A); p(c, -3, 1, Hi); p(c, 3, 1, Hi);   /* head, raised eyes, salt crust */
    for (b = 2; b <= L; b++) { q = (b - 2) / (L - 2); a = sw * q * q; p(c, a, b, C); p(c, a + 1 + op * q, b, C);
      if (b & 1) { p(c, a - 1, b, TOOTH); p(c, a + 2 + op * q, b, TOOTH); } if (b % 4 === 0) p(c, a, b, Hi); }
    p(c, sw, L + 1, A); p(c, sw + 1 + op, L + 1, A);                                                       /* nostril knob */
    if (fr === 2) { star(c, sw, L + 3, K.WHITE); }
    if (fr === 3) { p(c, sw - 3, L, K.DEW); p(c, sw + 4, L - 1, K.DEW); p(c, sw - 2, L + 2, Hi); p(c, sw + 3, L + 2, Hi); }
  });
  PFA.glyph('L09-scute', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* three keeled bony scutes rising from the back, salt crystals glittering on the keels */
    fr0(x, y, tx, ty, nx, ny, K); var g = GROW[fr] + (z > 1 ? 1 : 0), i, h, a0, b, w;
    row(c, -6, 6, 0, C); row(c, -5, 5, 1, A);
    for (i = -1; i <= 1; i++) { a0 = i * 4; h = 2 + g + (i === 0 ? 1 : 0);
      for (b = 1; b <= h; b++) { w = Math.max(0, Math.round((h - b) * .6)); row(c, a0 - w, a0 + w, b, C); }
      p(c, a0, h + 1, A); p(c, a0 + 1, h, Hi); if (((i + fr) & 1) === 0) p(c, a0, h + 2, K.WHITE); }
    if (fr === 3) { p(c, -7, 2, Hi); p(c, 7, 3, Hi); }
  });
  PFA.glyph('L09-spin', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* the death roll: the long body spinning, dark back and pale belly turning over, spray flung round it */
    fr0(x, y, tx, ty, nx, ny, K); var a, b, r, w = z > 1 ? 1 : 0, i, ix;
    for (b = 3; b <= 7; b++) { r = (b - 3 + fr) % 5; for (a = -5 - w; a <= 5 + w; a++) { if ((b === 3 || b === 7) && (a < -4 - w || a > 4 + w)) continue;
      p(c, a, b, r < 3 ? (((a + r) & 3) === 0 ? A : C) : BELLY); } }
    row(c, 6 + w, 9 + w, 5, C); row(c, 6 + w, 9 + w, 6, fr & 2 ? BELLY : C); p(c, 7 + w, 4, TOOTH); p(c, 9 + w, 7, TOOTH);   /* the snout spinning with it */
    row(c, -9 - w, -6 - w, 5, C); p(c, -10 - w, 5 + (fr & 1), C);                                        /* tail */
    for (i = 0; i < 4; i++) { ix = (i * 3 + fr * 2) % 12; p(c, CUP[ix * 2] * 8, 5 + CUP[ix * 2 + 1] * 5, i & 1 ? K.DEW : K.WHITE); }
  });
  PFA.glyph('L09-eyes', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* only the raised eyes and the nostril tip above the water line, the snout a dashed shadow under it */
    fr0(x, y, tx, ty, nx, ny, K); var a, r = 2 + fr * 1.5;
    for (a = -7; a <= 12; a++) if (((a + fr) & 3) !== 0) p(c, a, 1, WATER);
    s(c, -2, 3, 2, C); s(c, 2, 3, 2, C); p(c, -2, 4, Hi); p(c, 2, 4, Hi);
    if (fr === 3) { p(c, -2, 3, C); p(c, 2, 3, C); } else { p(c, -2, 3, A); p(c, 2, 3, A); }                /* slit pupils, a slow blink */
    for (a = 5; a <= 10; a += 2) p(c, a, 2, C); s(c, 12, 2, 2, C); p(c, 12, 3, A);                        /* snout under the surface, nostril knob above */
    p(c, -r * 1.6, 1, K.DEW); p(c, r * 1.6, 0, K.DEW); p(c, 12 + r, 1, K.DEW);
  });
  PFA.glyph('L09-brine', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a brine drop flung off, splashing and drying to a cube of salt */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0;
    if (fr === 0) { s(c, 0, 1, 2 + w, C); p(c, 0, 3, C); p(c, -1, 0, Hi); }
    else if (fr === 1) { cl(c, 0, 0, 3, C); p(c, 1, 1, C); p(c, 0, 4, K.WHITE); }
    else if (fr === 2) { row(c, -1, 1, 0, C); p(c, -2, 1, C); p(c, 2, 1, C); p(c, -3, 2, K.DEW); p(c, 3, 2, K.DEW); p(c, 0, 2, K.WHITE); }
    else { s(c, 0, 1, 3 + w, Hi); p(c, 1, 2, K.WHITE); p(c, -1, 0, C); p(c, -3, 3, K.WHITE); p(c, 3, 4, Hi); }
  });
  PFA.glyph('L09-tail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a heavy tail with a double row of crests swept from side to side, spray off the tip */
    fr0(x, y, tx, ty, nx, ny, K); var L = 9 + (z > 1 ? 1 : 0), bend = TB[fr], b, a, q, w;
    for (b = 0; b <= L; b++) { q = b / L; a = bend * q * q; w = b < 4 ? 1 : 0; row(c, a - w, a + 1, b, C);
      if (b > 1 && !(b & 1)) { p(c, a - 1 - w, b, A); p(c, a + 2, b, Hi); } }
    if (fr === 2) { p(c, bend + 3, L + 1, K.DEW); p(c, bend - 2, L, K.DEW); p(c, bend + 4, L - 2, K.WHITE); p(c, bend + 1, L + 3, K.WHITE); }
    if (fr === 3) { p(c, bend + 4, L, K.DEW); p(c, bend + 6, L - 1, K.DEW); }
  });
  /* --- delta gharial: olive-tan, a thin snout with the ghara knob on the tip --- */
  PFA.glyph('L09-ghara', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the thin snout ending in the round ghara knob, buzzing bubbles out of it, then driven out with a strike star */
    fr0(x, y, tx, ty, nx, ny, K); var L = GL[fr] + (z > 1 ? 1 : 0), b;
    row(c, -3, 3, 0, C); row(c, -2, 2, 1, C); p(c, -2, 2, C); p(c, 2, 2, C); p(c, -2, 3, A); p(c, 2, 3, A);
    for (b = 2; b <= L; b++) { p(c, 0, b, C); p(c, 1, b, C); if (b % 3 === 0) { p(c, -1, b, TOOTH); p(c, 2, b, TOOTH); } }
    row(c, -1, 2, L + 1, Hi); row(c, -1, 2, L + 2, Hi); row(c, 0, 1, L + 3, Hi); p(c, 0, L + 2, A); p(c, 1, L + 2, MUD);   /* the pot-shaped ghara */
    if (fr === 0) { p(c, -2, L + 4, K.DEW); }
    if (fr === 1) { p(c, -3, L + 2, K.DEW); p(c, 4, L + 3, K.DEW); p(c, 0, L + 5, K.DEW); }
    if (fr === 2) star(c, 0, L + 5, K.WHITE);
    if (fr === 3) ring(c, .5, L + 2, 4, K.DEW, 2);
  });
  PFA.glyph('L09-logeye', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a log drifting on the water... then two eyes open on it: it was never a log */
    fr0(x, y, tx, ty, nx, ny, K); var a, w = z > 1 ? 1 : 0, eb = fr === 3 ? 4 : 5;
    for (a = -8; a <= 8; a++) if ((a + fr) & 1) p(c, a, 1, WATER);
    row(c, -7 - w, 6 + w, 2, A); row(c, -7 - w, 6 + w, 3, C); row(c, -7 - w, 6 + w, 4, C);
    for (a = -5; a <= 5; a += 3) p(c, a, 3, A);                                                           /* bark grain */
    p(c, -8 - w, 3, Hi); p(c, -8 - w, 4, Hi); p(c, -9 - w, 3, A);                                         /* cut end */
    if (fr === 0) p(c, 1, 5, A);                                                                          /* only a knot... */
    else { s(c, 2, eb, 2, C); s(c, 5, eb, 2, C); if (fr === 2) { p(c, 2, eb, GOLD); p(c, 5, eb, GOLD); } else if (fr === 1) { p(c, 2, eb, A); p(c, 5, eb, A); } }
    if (fr === 3) { p(c, 0, 5, K.DEW); p(c, 7, 5, K.DEW); }
  });
  /* --- alligator snapper: spiked mossy shell, hooked beak, pink worm lure --- */
  PFA.glyph('L09-lure', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* jaws gaping, the pink worm tongue wriggling inside; a fish comes close; snap */
    fr0(x, y, tx, ty, nx, ny, K); var op = fr === 3 ? 0 : 3, b, w;
    for (b = 1; b <= 8; b++) { w = op * (b - 1) / 7; p(c, -w, b, C); p(c, -w - 1, b, C); p(c, 1 + w, b, C); p(c, 2 + w, b, C); if (op && b > 1 && b < 8) row(c, -w + 1, w, b, A); }
    p(c, -op, 9, C); p(c, -op + 1, 9, A);                                                                 /* the hooked upper beak tip */
    if (op) { p(c, (fr & 1) ? 0 : 1, 4, Hi); p(c, (fr & 1) ? 1 : 0, 5, Hi); p(c, (fr & 1) ? 0 : 1, 6, Hi); p(c, 0, 3, Hi); p(c, 1, 3, Hi); }
    if (fr === 2) { row(c, -1, 2, 12, FISH); p(c, 3, 11, FISH); p(c, 3, 13, FISH); p(c, -1, 12, A); }
    if (fr === 3) { p(c, -2, 10, K.WHITE); p(c, 3, 10, K.WHITE); p(c, 0, 11, K.WHITE); p(c, 1, 12, FISH); p(c, 2, 13, FISH); }
  });
  PFA.glyph('L09-hookjaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the huge head side-on: a hooked beak that gapes, slams shut with a star and cracks */
    fr0(x, y, tx, ty, nx, ny, K); var op = fr === 1 ? 3 : 0, b, w = z > 1 ? 1 : 0, o;
    row(c, -4 - w, 4 + w, 0, C); row(c, -4 - w, 4 + w, 1, C); row(c, -4, 3, 2, C); row(c, -3, 3, 3, C); p(c, -4, 3, A); p(c, -3, 2, A); p(c, -2, 1, A);   /* rough head, ridged eye */
    for (b = 4; b <= 8; b++) { row(c, -3 + (b > 6 ? 1 : 0), -1, b, C); o = op * (b - 4) / 4; row(c, 1 + o, 2 + o, b, C); }
    p(c, 0, 9, C); p(c, 1, 9, C); p(c, 1, 10, A);                                                         /* the hook */
    if (op) { for (b = 5; b <= 8; b++) row(c, 0, op * (b - 4) / 4, b, Hi); }                                /* pink mouth */
    if (fr === 2) star(c, 0, 12 + w, K.WHITE);
    if (fr === 3) { lin(c, -3, 11, -1, 13, K.WHITE); lin(c, 3, 11, 2, 14, K.WHITE); p(c, 0, 12, Hi); }
  });
  PFA.glyph('L09-keel', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* the shell with three spiked keels like a mountain range, weed strands waving off it */
    fr0(x, y, tx, ty, nx, ny, K); var i, a0, q, j, sw, w = z > 1 ? 1 : 0;
    row(c, -7 - w, 7 + w, 0, C); row(c, -7 - w, 7 + w, 1, C); row(c, -6, 6, 2, C); row(c, -5, 5, 3, C); row(c, -3, 3, 4, C);
    for (i = -1; i <= 1; i++) { a0 = i * 4; cl(c, a0, i ? 3 : 4, i ? 5 : 7, A); p(c, a0, i ? 6 : 8, TOOTH); p(c, a0 - 2, 1, A); p(c, a0 + 2, 2, A); }
    for (j = 0; j < 4; j++) { sw = ((fr + j) & 3) - 1.5; for (q = 1; q <= 4; q++) p(c, -7 + j * 4.6 + sw * q * .5, 1 + q + (j === 1 || j === 2 ? 3 : 0), WEED); }
  });
  PFA.glyph('L09-mudnap', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* dozing half sunk in the mud, only the spiked shell top showing, bubbles rising from the nostrils */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0;
    row(c, -8 - w, 8 + w, 0, MUD); row(c, -7, 7, 1, MUD); p(c, -5, 1, A); p(c, 3, 0, A);
    row(c, -4, 4, 2, C); row(c, -3, 3, 3, C); p(c, -2, 4, C); p(c, 0, 4, C); p(c, 2, 4, C); p(c, 0, 5, A);
    s(c, 6, 2, 2, C); p(c, 6, 3, A); p(c, 7, 3, A);                                                       /* head resting, eye shut */
    p(c, 8 + (fr & 1), 3 + fr * 2, K.DEW); if (fr > 0) p(c, 8, 2 + fr, K.DEW); if (fr === 3) { p(c, 7, 11, K.WHITE); p(c, 10, 10, K.DEW); }
  });
  PFA.glyph('L09-weed', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a coat of weed strands waving off the spiked shell: the snapper vanishes into the pond bottom */
    fr0(x, y, tx, ty, nx, ny, K); var j, q, a0, L;
    row(c, -5, 5, 0, A); p(c, -4, 1, A); p(c, 0, 1, A); p(c, 4, 1, A);
    for (j = 0; j < 5; j++) { a0 = -5 + j * 2.5; L = 5 + ((j * 3) & 3); for (q = 1; q <= L; q++) p(c, a0 + Math.sin(q * .7 + fr * 1.57 + j) * 1.5, q, (q + j) & 1 ? C : WEED); }
  });
  /* --- mire toad: teal-green, warty, yellow glands, a sticky tongue --- */
  PFA.glyph('L09-slime', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a warty back with yellow glands, strings of slime stretching off the warts and snapping */
    fr0(x, y, tx, ty, nx, ny, K); var j, q, a0, len = SL[fr] + (z > 1 ? 1 : 0);
    row(c, -6, 6, 0, C); row(c, -6, 6, 1, C); row(c, -5, 5, 2, C); row(c, -3, 3, 3, C);
    p(c, -4, 1, A); p(c, -1, 2, A); p(c, 3, 1, A); p(c, 2, 3, A); p(c, -3, 2, Hi); p(c, -2, 2, Hi); p(c, 4, 2, Hi);
    for (j = 0; j < 3; j++) { a0 = -4 + j * 4; for (q = 1; q <= len; q++) p(c, a0 + (j - 1) * q * .3, 3 + q - (j === 1 ? 0 : 1), q === len ? K.DEW : SLIME); }
    if (fr === 3) { p(c, -5, 9, K.DEW); p(c, 0, 10, K.DEW); p(c, 5, 9, K.DEW); }
  });
  function toad(c, b0, w, C, A, Hi) {   /* a fat toad seen from behind/above, body centred at b0, half-width w */
    row(c, -w + 1, w - 1, b0 - 1, C); row(c, -w, w, b0, C); row(c, -w, w, b0 + 1, C); row(c, -w + 1, w - 1, b0 + 2, C);
    p(c, -2, b0 + 3, Hi); p(c, 2, b0 + 3, Hi); p(c, -2, b0 + 2, A); p(c, 2, b0 + 2, A); p(c, -1, b0, A); p(c, 1, b0 + 1, A);
  }
  PFA.glyph('L09-bellyflop', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a fat toad up in the air, legs spread, then flat on its belly with mud splashing out */
    fr0(x, y, tx, ty, nx, ny, K);
    if (fr === 0) { toad(c, 8, 3, C, A, Hi); lin(c, -4, 8, -7, 6, C); lin(c, 4, 8, 7, 6, C); lin(c, -3, 10, -5, 12, C); lin(c, 3, 10, 5, 12, C); }
    else if (fr === 1) { toad(c, 4, 4, C, A, Hi); lin(c, -5, 4, -7, 2, C); lin(c, 5, 4, 7, 2, C); }
    else if (fr === 2) { row(c, -6, 6, 1, C); row(c, -6, 6, 2, C); row(c, -4, 4, 3, C); p(c, -2, 4, Hi); p(c, 2, 4, Hi); p(c, -1, 2, A); p(c, 2, 2, A);
      p(c, -8, 1, MUD); p(c, 8, 1, MUD); p(c, -9, 3, MUD); p(c, 9, 3, MUD); p(c, -7, 4, K.DEW); p(c, 7, 4, K.DEW); p(c, 0, 6, MUD); }
    else { toad(c, 2, 5, C, A, Hi); p(c, -10, 1, MUD); p(c, 10, 1, MUD); p(c, -8, 5, MUD); p(c, 8, 5, MUD); }
  });
  PFA.glyph('L09-gas', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* a bog-gas bubble welling up out of the mud, swelling, bursting into stink curls */
    fr0(x, y, tx, ty, nx, ny, K); var r = fr === 0 ? 1.5 : 3 + (z > 1 ? 1 : 0);
    if (fr < 2) { ring(c, 0, 1 + r, r, C, 1); p(c, -1, 2 + r, GAS); p(c, 0, 1 + r, GAS); p(c, -1, 1 + r * 1.6, K.WHITE); }
    else if (fr === 2) { ring(c, 0, 4, 5, C, 2); ring(c, 0, 4, 3, GAS, 3); p(c, 0, 4, Hi); }
    else { p(c, -2, 3, C); p(c, -1, 4, C); p(c, -2, 5, GAS); p(c, -1, 6, C); p(c, -2, 7, C); p(c, 2, 4, C); p(c, 3, 5, GAS); p(c, 2, 6, C); p(c, 3, 7, C); p(c, 2, 8, Hi); }
  });
  PFA.glyph('L09-tongue', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* the toad head, its sticky pink tongue shooting out at a fly and reeling it in */
    fr0(x, y, tx, ty, nx, ny, K); var L = TL[fr] + (z > 1 ? 1 : 0);
    row(c, -4, 4, 0, C); row(c, -4, 4, 1, C); row(c, -3, 3, 2, C); s(c, -3, 3, 2, C); s(c, 3, 3, 2, C); p(c, -3, 3, A); p(c, 3, 3, A); p(c, -3, 4, Hi); p(c, 3, 4, Hi);
    row(c, -2, 2, 2, A);
    if (L) { cl(c, 0, 3, 2 + L, PINK); row(c, -1, 1, 3 + L, PINK); }
    if (fr === 1 || fr === 2) { p(c, 0, 13, A); p(c, -1, 14, K.DEW); p(c, 1, 14, K.DEW); }
    if (fr === 3) { p(c, 0, 4 + L, A); p(c, -1, 5 + L, K.DEW); p(c, 1, 5 + L, K.DEW); }
  });
  /* --- elder mire toad: mossy back, huge warts, half-closed eyes --- */
  PFA.glyph('L09-mossback', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* the elder's huge mossy back, big warts, moss sprigs growing and a half-closed golden eye */
    fr0(x, y, tx, ty, nx, ny, K); var j, h, a, w = z > 1 ? 1 : 0;
    row(c, -7 - w, 7 + w, 0, C); row(c, -7 - w, 7 + w, 1, C); row(c, -6, 6, 2, C); row(c, -5, 5, 3, C); row(c, -3, 3, 4, C);
    p(c, -4, 2, A); p(c, -3, 2, A); p(c, -4, 1, A); p(c, 2, 3, A); p(c, 3, 3, A); p(c, 5, 1, A); p(c, -1, 1, A);   /* big warts */
    for (j = 0; j < 3; j++) { a = -2 + j * 2.5; h = MG[(fr + j) & 3]; cl(c, a, 5, 5 + h, MOSS); if (h) { p(c, a - 1, 4 + h, MOSS); p(c, a + 1, 5 + h, Hi); } }
    row(c, 5, 7, 3, A); p(c, 6, 4, C); p(c, 6, 3, fr === 3 ? GOLD : A); p(c, 7, 4, C);                    /* heavy lid, a crack of gold */
  });
  PFA.glyph('L09-belch', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the throat sac swelling, then a ring of foul belch bursting out with spit flecks */
    fr0(x, y, tx, ty, nx, ny, K); var r = SR[fr] + (z > 1 && fr < 2 ? 1 : 0), b;
    row(c, -4, 4, 0, C); row(c, -3, 3, 1, C);
    if (fr < 2) { for (b = -r; b <= r; b++) row(c, -Math.round(Math.sqrt(r * r - b * b + .3)), Math.round(Math.sqrt(r * r - b * b + .3)), 2 + r + b, b === r ? C : Hi); p(c, -1, 2 + r, K.WHITE); }
    else if (fr === 2) { ring(c, 0, 4, 5, GAS, 1); ring(c, 0, 4, 3, C, 2); p(c, -6, 9, C); p(c, 5, 10, C); }
    else { ring(c, 0, 5, 8, GAS, 2); p(c, -7, 12, C); p(c, 6, 13, C); p(c, 0, 13, Hi); }
  });
  PFA.glyph('L09-fog', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* low marsh fog rolling out in three bands, the old toad's half-shut eye fading into it */
    fr0(x, y, tx, ty, nx, ny, K); var r, a, b;
    for (r = 0; r < 3; r++) { b = 2 + r * 2; for (a = -7; a <= 7; a++) if (((a + fr * 2 + r * 3) & 3) !== 0) p(c, a, b + (Math.sin(a * .6 + fr * 1.57 + r) > .3 ? 1 : 0), r === 1 ? C : Hi); }
    if (fr < 2) { row(c, -1, 1, 4, A); p(c, 0, 4, GOLD); }
  });
  /* --- goliath frog: huge, sandy brown, a wide flat head --- */
  function frog(c, ob, legs, C, A, Hi) {   /* the giant frog from above, wide flat head pointing out; legs 0 folded, 1 pushing, 2 trailing, 3 splayed flat */
    row(c, -4, 4, ob + 1, C); row(c, -5, 5, ob + 2, C); row(c, -5, 5, ob + 3, C); row(c, -6, 6, ob + 4, C); row(c, -6, 6, ob + 5, C); row(c, -5, 5, ob + 6, C);
    row(c, -4, 4, ob + 7, A); s(c, -4, ob + 6, 2, C); s(c, 4, ob + 6, 2, C); p(c, -4, ob + 6, Hi); p(c, 4, ob + 6, Hi); p(c, -4, ob + 7, A); p(c, 4, ob + 7, A);
    p(c, -2, ob + 3, A); p(c, 1, ob + 2, A); p(c, 2, ob + 4, A);
    if (legs === 0) { lin(c, -4, ob + 1, -7, ob + 2, C); lin(c, -7, ob + 2, -6, ob + 4, C); lin(c, 4, ob + 1, 7, ob + 2, C); lin(c, 7, ob + 2, 6, ob + 4, C); p(c, -7, ob + 6, C); p(c, 7, ob + 6, C); }
    else if (legs === 1) { lin(c, -3, ob + 1, -5, ob - 3, C); lin(c, 3, ob + 1, 5, ob - 3, C); p(c, -6, ob - 3, A); p(c, 6, ob - 3, A); }
    else if (legs === 2) { lin(c, -2, ob + 1, -3, ob - 5, C); lin(c, 2, ob + 1, 3, ob - 5, C); lin(c, -6, ob + 6, -7, ob + 9, C); lin(c, 6, ob + 6, 7, ob + 9, C); }
    else { lin(c, -5, ob + 2, -9, ob, C); lin(c, 5, ob + 2, 9, ob, C); lin(c, -6, ob + 5, -9, ob + 7, C); lin(c, 6, ob + 5, 9, ob + 7, C); }
  }
  PFA.glyph('L09-goliath', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the giant crouched, launching, flying flat-headed, landing in a splash */
    fr0(x, y, tx, ty, nx, ny, K);
    if (fr === 0) frog(c, 0, 0, C, A, Hi);
    else if (fr === 1) frog(c, 3, 1, C, A, Hi);
    else if (fr === 2) frog(c, 5, 2, C, A, Hi);
    else { frog(c, 0, 3, C, A, Hi); p(c, -11, 1, K.DEW); p(c, 11, 1, K.DEW); p(c, -10, 4, K.WHITE); p(c, 10, 4, K.WHITE); p(c, 0, 10, K.DEW); }
  });
  PFA.glyph('L09-crab', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* the wide flat mouth swallowing a crab whole, the eyes pressed down to push it in */
    fr0(x, y, tx, ty, nx, ny, K); var cb = fr === 0 ? 7 : 5;
    row(c, -6, 6, 0, C); row(c, -6, 6, 1, C); row(c, -5, 5, 2, C);
    if (fr === 3) { p(c, -4, 2, A); p(c, 4, 2, A); p(c, -4, 1, A); p(c, 4, 1, A); } else { s(c, -4, 2, 2, C); s(c, 4, 2, 2, C); p(c, -4, 2, Hi); p(c, 4, 2, Hi); p(c, -4, 3, A); p(c, 4, 3, A); }
    if (fr === 1) { row(c, -5, 5, 3, A); row(c, -4, 4, 4, A); row(c, -5, 5, 5, C); }
    else row(c, -5, 5, 3, A);
    if (fr < 2) { row(c, -2, 2, cb, CRAB); row(c, -1, 1, cb + 1, CRAB); p(c, -3, cb + 1, CRAB); p(c, 3, cb + 1, CRAB); p(c, -3, cb + 2, CRAB); p(c, 3, cb + 2, CRAB);
      p(c, -3, cb - 1, CRAB); p(c, 3, cb - 1, CRAB); p(c, -1, cb + 2, A); p(c, 1, cb + 2, A); }
    if (fr === 2) { p(c, -1, 1, Hi); p(c, 0, 1, Hi); p(c, 1, 1, Hi); p(c, 5, 4, CRAB); }
    if (fr === 3) { p(c, 0, 6, Hi); p(c, -1, 7, Hi); p(c, 1, 7, Hi); p(c, 0, 8, K.WHITE); }
  });
  PFA.glyph('L09-rubber', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a patch of thick granular skin that bulges out under a blow and springs back */
    fr0(x, y, tx, ty, nx, ny, K); var a, top, bul = BUL[fr] + (z > 1 ? 1 : 0);
    for (a = -6; a <= 6; a++) { top = 2 + Math.round(bul * (1 - a * a / 36)); cl(c, a, 0, top - 1, C); p(c, a, top, (a & 1) ? C : Hi); if (((a * 7 + fr) & 3) === 0) p(c, a, 1, A); }
    if (fr === 2) { star(c, 0, bul + 5, K.WHITE); }
    if (fr === 3) { p(c, -7, 3, Hi); p(c, 7, 3, Hi); }
  });
  PFA.glyph('L09-rocknest', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a round river stone shoved into a nest ring by a big hand, a pool filling, the frog sitting heavy on top */
    fr0(x, y, tx, ty, nx, ny, K); var o = fr === 1 ? -1 : 0;
    row(c, -2 + o, 2 + o, 0, A); row(c, -2 + o, 2 + o, 1, STONE); row(c, -3 + o, 3 + o, 2, STONE); row(c, -3 + o, 3 + o, 3, STONE); row(c, -2 + o, 2 + o, 4, STONE); p(c, -1 + o, 3, K.WHITE); p(c, 2 + o, 1, A);
    if (fr < 2) { row(c, 4 + o, 5 + o, 2, C); row(c, 4 + o, 5 + o, 3, C); p(c, 4 + o, 4, C); row(c, 6 + o, 9, 3, C); p(c, 6 + o, 2, Hi); }
    if (fr >= 2) { row(c, -7, -4, 1, WATER); row(c, 4, 7, 1, WATER); p(c, -5, 2, K.DEW); p(c, 6, 2, K.DEW); }
    if (fr === 3) { row(c, -3, 3, 5, C); row(c, -4, 4, 6, C); row(c, -3, 3, 7, C); p(c, -2, 8, Hi); p(c, 2, 8, Hi); p(c, -5, 5, C); p(c, 5, 5, C); }
  });
  /* --- reef turtle: hawksbill, amber tortoiseshell, a pointed beak --- */
  PFA.glyph('L09-turtle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a hawksbill from above, mottled amber scutes, front flippers stroking like wings */
    fr0(x, y, tx, ty, nx, ny, K); var b;
    for (b = 2; b <= 8; b++) row(c, -TW[b - 2], TW[b - 2], b, C);
    cl(c, 0, 3, 7, A); p(c, -2, 4, A); p(c, 2, 4, A); p(c, -2, 6, A); p(c, 2, 6, A); p(c, -3, 5, SPOT); p(c, 1, 7, SPOT); p(c, 3, 4, SPOT); p(c, -1, 3, SPOT);
    row(c, -1, 1, 9, FLIP); row(c, -1, 1, 10, FLIP); p(c, 0, 11, BEAK); p(c, -1, 10, A); p(c, 1, 10, A);
    lin(c, -4, 7, TFA[fr], TFB[fr], FLIP); lin(c, 4, 7, -TFA[fr], TFB[fr], FLIP); lin(c, -4, 6, TFA[fr] + 1, TFB[fr] - 1, FLIP); lin(c, 4, 6, -TFA[fr] - 1, TFB[fr] - 1, FLIP);
    p(c, -3, 1, FLIP); p(c, -4, 0, FLIP); p(c, 3, 1, FLIP); p(c, 4, 0, FLIP); p(c, 0, 1, C);
  });
  PFA.glyph('L09-flipslap', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* one broad front flipper raised, swung and slapped flat on the water in a burst of spray */
    fr0(x, y, tx, ty, nx, ny, K); var ta = FA[fr], tb = FB[fr];
    lin(c, 0, 0, ta, tb, C); lin(c, 1, 0, ta + 1, tb - (fr === 2 ? 0 : 1), C); lin(c, -1, 1, ta * .6 - 1, tb * .6 + 1, C); p(c, ta * .5, tb * .5, A); p(c, ta * .8, tb * .8, Hi);
    if (fr === 2) { p(c, 11, 3, K.WHITE); p(c, 9, 4, K.DEW); p(c, 12, 1, K.DEW); p(c, 7, 3, K.DEW); p(c, 13, 4, K.WHITE); p(c, 10, 6, K.DEW); }
    if (fr === 3) { p(c, 9, 2, K.DEW); p(c, 12, 3, K.DEW); }
  });
  PFA.glyph('L09-scutes', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* overlapping tortoiseshell scutes like roof tiles, amber streaks shimmering, a cleaner fish nibbling along */
    fr0(x, y, tx, ty, nx, ny, K); var r, t, a, b, fa = -6 + fr * 4;
    for (r = 0; r < 3; r++) { b = 1 + r * 3; for (t = -2; t <= 2; t++) { a = t * 3 + (r & 1) * 1.5; if (r === 2 && (t === -2 || t === 2)) continue;
      row(c, a - 1, a + 1, b, C); row(c, a - 1, a + 1, b + 1, C); row(c, a - 1, a + 1, b + 2, A); if (((t + r + fr) & 3) === 0) p(c, a, b + 1, SPOT); } }
    row(c, fa - 1, fa + 1, 11, YFISH); p(c, fa - 2, 10, YFISH); p(c, fa - 2, 12, YFISH); p(c, fa + 1, 11, A);
  });
  PFA.glyph('L09-hawkbeak', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* the pointed hawksbill beak nipping a sponge off the reef, bits flying */
    fr0(x, y, tx, ty, nx, ny, K); var op = fr === 1 ? 2 : 0, w = z > 1 ? 1 : 0;
    row(c, -3 - w, 3 + w, 0, C); row(c, -3 - w, 3 + w, 1, C); row(c, -2, 2, 2, C); row(c, -2, 2, 3, C); p(c, -2, 1, A); p(c, 2, 1, A); p(c, 0, 2, A); p(c, -2, 3, A);
    cl(c, -1, 4, 7, BEAK); cl(c, 0, 4, 8, BEAK); p(c, 1, 8, BEAK); p(c, 1, 9, A);                         /* hooked upper beak */
    lin(c, 1, 4, 1 + op, 7, BEAK);
    if (fr < 2) { row(c, -1, 2, 10 + op, SPONGE); row(c, -2, 3, 11 + op, SPONGE); p(c, 0, 11 + op, A); }
    if (fr === 2) { star(c, 1, 11, K.WHITE); p(c, -3, 12, SPONGE); p(c, 4, 13, SPONGE); p(c, -1, 14, SPONGE); }
    if (fr === 3) { p(c, -4, 10, SPONGE); p(c, 5, 11, SPONGE); }
  });
  /* --- leatherback: black ridged leathery shell, white spots, huge flippers --- */
  PFA.glyph('L09-leather', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the leatherback from above: a long ridged teardrop with white spots, enormous front flippers beating */
    fr0(x, y, tx, ty, nx, ny, K); var b, w, a;
    for (b = 1; b <= 9; b++) { w = b < 3 ? b : b > 7 ? 11 - b : 4; row(c, -w, w, b, C); for (a = -2; a <= 2; a += 2) if (Math.abs(a) < w) p(c, a, b, A); if (((b * 3 + w) & 3) === 0) p(c, w - 1, b, Hi); }
    p(c, -1, 5, Hi); p(c, 3, 7, Hi); p(c, -3, 3, Hi);
    row(c, -1, 1, 10, C); row(c, -1, 1, 11, C); p(c, 0, 12, C); p(c, -1, 11, Hi); p(c, 1, 11, A);
    lin(c, -3, 8, LFA[fr], LFB[fr], C); lin(c, -3, 7, LFA[fr] + 1, LFB[fr] - 1, C); lin(c, 3, 8, -LFA[fr], LFB[fr], C); lin(c, 3, 7, -LFA[fr] - 1, LFB[fr] - 1, C);
    p(c, LFA[fr], LFB[fr], Hi); p(c, -LFA[fr], LFB[fr], Hi);
    p(c, -2, 1, C); p(c, -3, 0, C); p(c, 2, 1, C); p(c, 3, 0, C);
  });
  PFA.glyph('L09-abyss', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* slipping down into the deep: the shell outline shrinks into a dark ring and glowing specks */
    fr0(x, y, tx, ty, nx, ny, K); var r = AR[fr];
    if (r) { ring(c, 0, 6, r, C, 1); cl(c, 0, 6 - r + 1, 6 + r - 1, A); p(c, 0, 6 + r + 1, C); }
    if (fr > 0) ring(c, 0, 6, 6, A, 2);
    if (fr > 1) { p(c, -4, 2, GLOW); p(c, 5, 4, GLOW); p(c, -3, 10, Hi); p(c, 4, 11, GLOW); if (fr === 3) { p(c, 0, 6, GLOW); p(c, -6, 7, Hi); } }
  });
  PFA.glyph('L09-oar', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* one enormous front flipper rowing round like an oar, white spots along it, a swirl off the tip */
    fr0(x, y, tx, ty, nx, ny, K); var ta = OA[fr], tb = OB[fr];
    row(c, -2, 2, 0, C); lin(c, 0, 0, ta, tb, C); lin(c, 1, 1, ta + (ta < 0 ? 1 : -1), tb, C); lin(c, -1, 1, ta * .7, tb * .7 + 1, C);
    p(c, ta * .4, tb * .4, Hi); p(c, ta * .7, tb * .7, Hi); p(c, ta * .55, tb * .55 + 1, A);
    if (fr === 2) { ring(c, ta, tb, 3, K.DEW, 3); }
    if (fr === 3) { p(c, ta + 1, tb + 2, K.DEW); p(c, ta - 2, tb + 1, K.WHITE); }
  });
  PFA.glyph('L09-jelly', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a pale jellyfish drifting in and gulped, the spiny throat showing */
    fr0(x, y, tx, ty, nx, ny, K); var jb = fr === 0 ? 9 : fr === 1 ? 7 : 4, op = fr === 1 ? 2 : 0;
    row(c, -2, 2, 0, C); row(c, -2, 2, 1, C); p(c, -1 - op, 2, C); p(c, 1 + op, 2, C); p(c, -1 - op, 3, C); p(c, 1 + op, 3, C); p(c, -1, 1, Hi);
    if (fr < 3) { row(c, -3, 3, jb, JELLY); row(c, -2, 2, jb + 1, JELLY); p(c, 0, jb + 1, K.WHITE); p(c, -2, jb - 1, JELLY); p(c, 0, jb - 2, JELLY); p(c, 2, jb - 1, JELLY); if (fr < 2) p(c, -1, jb - 3, JELLY); }
    if (fr === 3) { p(c, -1, 2, Hi); p(c, 1, 2, Hi); p(c, -1, 3, Hi); p(c, 1, 3, Hi); p(c, 0, 5, K.DEW); }
  });

  /* ================= motions (mutate the scratch G; pp = time x speed) ================= */
  PFA.motion('L09-sweep', function (G, pp, k, ph) { var u = (pp * 1.5 + ph) % 1;                                    /* swing, open, snap, spray */
    if (u < .35) { G.fr = 0; G.t -= 1; } else if (u < .55) { G.fr = 1; G.t += 1; } else if (u < .75) { G.fr = 2; G.d += 2; } else { G.fr = 3; G.d += 1; } });
  PFA.motion('L09-pulse', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 4) + k) & 3; });
  PFA.motion('L09-roll', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 10 + ph * 4) + k) & 3; G.t += Math.sin(pp * 6 + k) * 1; });
  PFA.motion('L09-wait', function (G, pp, k, ph) { G.fr = Math.floor(pp * 2.5 + ph * 4) & 3; G.up += Math.sin(pp * 3 + k) * .5; });
  PFA.motion('L09-drip', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 5 + ph * 2)); });
  PFA.motion('L09-swish', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = Math.min(3, Math.floor(u * 4)); G.t += (u - .5) * 3; });
  PFA.motion('L09-thrust', function (G, pp, k, ph) { var u = (pp * 1.6 + ph) % 1;
    if (u < .4) { G.fr = 0; G.d -= .5; } else if (u < .55) { G.fr = 1; G.d -= 1.5; } else if (u < .75) { G.fr = 2; G.d += 3; } else if (u < .9) { G.fr = 3; G.d += 3; } else G.fr = 0; });
  PFA.motion('L09-drift', function (G, pp, k, ph) { G.fr = Math.floor(pp * 3 + ph * 4) & 3; G.t += Math.sin(pp * 3 + k + ph * 6) * 2.5; });
  PFA.motion('L09-lurewig', function (G, pp, k, ph) { var u = (pp * 1.4 + ph) % 1;                                  /* wriggle, wriggle, the fish comes, snap */
    if (u < .6) G.fr = (Math.floor(pp * 14) + k) & 1; else if (u < .78) G.fr = 2; else { G.fr = 3; G.d += 1; } });
  PFA.motion('L09-chomp', function (G, pp, k, ph) { var u = (pp * 1.8 + ph) % 1;
    if (u < .35) G.fr = 0; else if (u < .6) { G.fr = 1; G.d -= 1; } else if (u < .75) { G.fr = 2; G.d += 3; } else { G.fr = 3; G.d += 2; } });
  PFA.motion('L09-sway', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 4) + k) & 3; });
  PFA.motion('L09-bubble', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 4) + k) & 3; G.up += Math.sin(pp * 2 + k) * .5; });
  PFA.motion('L09-wave', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 4) + k) & 3; });
  PFA.motion('L09-ooze', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 3.5 + ph * 4) + k) & 3; });
  PFA.motion('L09-flop', function (G, pp, k, ph) { var u = (pp * 1.8 + ph) % 1; G.fr = u < .35 ? 0 : u < .5 ? 1 : u < .75 ? 2 : 3; });
  PFA.motion('L09-burp', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4.5 + ph * 1.2)); });
  PFA.motion('L09-flick', function (G, pp, k, ph) { var u = (pp * 2.2 + ph) % 1; G.fr = u < .3 ? 0 : u < .45 ? 1 : u < .7 ? 2 : 3; });
  PFA.motion('L09-slow', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 2 + ph * 4) + k) & 3; });
  PFA.motion('L09-swell', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4 + ph)); });
  PFA.motion('L09-fogdrift', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 3 + ph * 4) + k) & 3; G.t += Math.sin(pp * 2 + k + ph * 6) * 3; });
  PFA.motion('L09-leap', function (G, pp, k, ph) { var u = (pp * 1.5 + ph) % 1; G.fr = u < .4 ? 0 : u < .55 ? 1 : u < .75 ? 2 : 3; if (G.fr === 2) G.d += 2; });
  PFA.motion('L09-swallow', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4.2 + ph * .8)); });
  PFA.motion('L09-boing', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 4) + k) & 3; });
  PFA.motion('L09-push', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 3.2 + ph * 4) + k) & 3; if (G.fr < 2) G.t -= G.fr; });
  PFA.motion('L09-tile', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 4) + k) & 3; G.up += Math.sin(pp * 3 + k) * .4; });
  PFA.motion('L09-swim', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 8 + ph * 4) + k) & 3; G.t += Math.sin(pp * 4 + k) * 1.5; });
  PFA.motion('L09-slap', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .35 ? 0 : u < .55 ? 1 : u < .75 ? 2 : 3; if (G.fr === 2) G.d += 1; });
  PFA.motion('L09-stroke', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 4) + k) & 3; G.up += Math.sin(pp * 5 + k) * .8; });
  PFA.motion('L09-sink', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4 + ph)); });
  PFA.motion('L09-row', function (G, pp, k, ph) { var u = (pp * 1.6 + ph) % 1; G.fr = Math.min(3, Math.floor(u * 4)); G.t += (u - .5) * 2; });

  /* ================= custom chain effects (along the OUTER loop from e.a over e.d, eased e.hh) ================= */
  function carCruise(c, e, H) {         /* the saltwater gharial cruises to the next piece: only eyes and nostril knob above the water, a V wake spreading behind */
    var P = e.P, Q = H.Q, i, u, sp, sd = e.d < 0 ? -1 : 1, b = 5;
    for (i = 1; i <= 6; i++) { u = e.hh - i * .045; if (u < 0) break; P.atq(e.a + e.d * u); sp = Math.min(4, i * .8);
      H.px(c, Q.x + Q.nx * (b + sp), Q.y + Q.ny * (b + sp), i & 1 ? H.DEW : e.hi); if (b - sp >= 1.5) H.px(c, Q.x + Q.nx * (b - sp), Q.y + Q.ny * (b - sp), H.DEW); }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'L09-eyes', Q.x + Q.nx * (b - 2), Q.y + Q.ny * (b - 2), 0, Math.floor(e.p * 6) & 3, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
  }
  function carLure(c, e, H) {           /* a little silver fish swims along the outer edge to the next piece, drawn on by a pink worm wriggling there */
    var P = e.P, Q = H.Q, i, u, sd = e.d < 0 ? -1 : 1, tx, ty, b, x, y, wf = Math.floor(e.p * 14) & 1;
    P.atq(e.a + e.d); for (i = 0; i < 4; i++) H.px(c, Q.x + Q.nx * (2 + i) - Q.ny * (((i + wf) & 1) ? 1 : 0), Q.y + Q.ny * (2 + i) + Q.nx * (((i + wf) & 1) ? 1 : 0), PINK);
    for (i = 1; i <= 3; i++) { u = e.hh - i * .08; if (u < 0) break; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * (7 + i), Q.y + Q.ny * (7 + i), H.DEW); }
    P.atq(e.a + e.d * e.hh); tx = -Q.ny * sd; ty = Q.nx * sd; b = 6 + Math.sin(e.p * 20) * .8; x = Q.x + Q.nx * b; y = Q.y + Q.ny * b;
    for (i = -2; i <= 1; i++) H.px(c, x + tx * i, y + ty * i, FISH); H.px(c, x + tx * 1, y + ty * 1, e.acc);
    H.px(c, x - tx * 3 + Q.nx, y - ty * 3 + Q.ny, FISH); H.px(c, x - tx * 3 - Q.nx, y - ty * 3 - Q.ny, FISH); H.px(c, x + Q.nx, y + Q.ny, FISH);
  }
  function carGiantLeap(c, e, H) {      /* the goliath frog crosses in one huge leap: a dotted arc behind it, a splash ring where it lands */
    var P = e.P, Q = H.Q, i, u, b, sd = e.d < 0 ? -1 : 1, r, fr;
    for (i = 2; i <= 12; i += 2) { u = i / 12 * e.hh; P.atq(e.a + e.d * u); b = 4 + Math.sin(u * Math.PI) * 11; H.px(c, Q.x + Q.nx * b, Q.y + Q.ny * b, e.acc); }
    P.atq(e.a + e.d * e.hh); b = 2 + Math.sin(e.hh * Math.PI) * 11; fr = e.hh < .15 ? 1 : e.hh > .9 ? 3 : 2;
    H.glyph(c, 'L09-goliath', Q.x + Q.nx * b, Q.y + Q.ny * b, 0, fr, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
    if (e.hh > .82) { P.atq(e.a + e.d); r = 2 + (e.hh - .82) / .18 * 6;
      for (i = 0; i < 12; i++) if (CUP[i * 2 + 1] > -.2) H.px(c, Q.x + (-Q.ny) * CUP[i * 2] * r + Q.nx * (1 + CUP[i * 2 + 1] * r * .6), Q.y + Q.nx * CUP[i * 2] * r + Q.ny * (1 + CUP[i * 2 + 1] * r * .6), i & 1 ? H.DEW : H.WHITE); }
  }
  function carReefSwim(c, e, H) {       /* the hawksbill swims over a strip of coral tufts along the outer edge, bubbles rising off it */
    var P = e.P, Q = H.Q, i, u, sd = e.d < 0 ? -1 : 1, x, y, fr = Math.floor(e.p * 10) & 3;
    for (i = 0; i < 6; i++) { u = (i + .5) / 6; if (u > e.hh + .15) break; P.atq(e.a + e.d * u);
      H.px(c, Q.x + Q.nx, Q.y + Q.ny, CORAL[i]); H.px(c, Q.x + Q.nx * 2 - Q.ny, Q.y + Q.ny * 2 + Q.nx, CORAL[i]); H.px(c, Q.x + Q.nx * 2 + Q.ny, Q.y + Q.ny * 2 - Q.nx, CORAL[i]); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, CORAL[i]); }
    P.atq(e.a + e.d * e.hh); x = Q.x + Q.nx * 11; y = Q.y + Q.ny * 11;
    H.glyph(c, 'L09-turtle', x - Q.ny * sd * -6, y + Q.nx * sd * -6, 0, fr, e.col, e.acc, e.hi, Q.nx, Q.ny, -Q.ny * sd, Q.nx * sd);
    H.px(c, x + Q.nx * 8, y + Q.ny * 8 - (e.p * 30 % 4), H.DEW); H.px(c, x + Q.nx * 10 - Q.ny * 2, y + Q.ny * 10 + Q.nx * 2, H.DEW);
  }
  function carDeepDive(c, e, H) {       /* the leatherback dives under and comes up at the next piece: a dark dashed depth line and rising bubbles while it is down */
    var P = e.P, Q = H.Q, i, u, sd = e.d < 0 ? -1 : 1, b, fr = Math.floor(e.p * 8) & 3;
    for (i = 0; i < 8; i++) { u = .2 + i * .075; if (u > Math.min(e.hh, .8)) break; if (i & 1) continue; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, e.acc); H.px(c, Q.x + Q.nx * 2 - Q.ny * sd, Q.y + Q.ny * 2 + Q.nx * sd, e.acc); }
    P.atq(e.a + e.d * e.hh);
    if (e.hh < .22 || e.hh > .78) { b = e.hh < .22 ? 6 - e.hh * 12 : 6 - (1 - e.hh) * 12;
      H.glyph(c, 'L09-leather', Q.x + Q.nx * b - Q.ny * sd * -6, Q.y + Q.ny * b + Q.nx * sd * -6, 0, fr, e.col, e.acc, e.hi, Q.nx, Q.ny, -Q.ny * sd, Q.nx * sd); }
    else { b = 3 + ((e.p * 40) % 6); H.px(c, Q.x + Q.nx * b, Q.y + Q.ny * b, H.DEW); H.px(c, Q.x + Q.nx * (b + 3) - Q.ny, Q.y + Q.ny * (b + 3) + Q.nx, H.WHITE); }
  }

  /* ================= motifs ================= */
  function M(name, meta) { PFA.motif(name, comp, meta); }
  /* saltwater gharial */
  M('salt-snout', { nm: 'salt snouts', desc: 'a very long thin gharial snout lined with needle teeth and crusted with salt, swung sideways through the water, open, snapped shut with a star; the chain is the gharial cruising with only its eyes above water and a V wake', fam: 'thrust', gap: 18, g: 'L09-saltsnout', mo: 'L09-sweep', x: '-', car: 'custom', carDraw: carCruise });
  M('brine-scute', { nm: 'brine scutes', desc: 'three keeled bony scutes rising off a grey-green back, salt crystals glittering on the keels', fam: 'thorn', gap: 14, g: 'L09-scute', mo: 'L09-pulse', x: '-', car: 'train' });
  M('death-spin', { nm: 'death rolls', desc: 'a long crocodilian body spinning over and over, dark back and pale belly turning, snout and tail with it, spray flung round', fam: 'slash', gap: 18, g: 'L09-spin', mo: 'L09-roll', x: '-', car: 'roll' });
  M('eye-float', { nm: 'floating eyes', desc: 'only two raised eyes and a nostril knob above a water line, the long snout a dashed shadow beneath, a slow blink and ripples', fam: 'ripple', gap: 18, g: 'L09-eyes', mo: 'L09-wait', x: '-', car: 'rings' });
  M('brine-spray', { nm: 'brine drops', desc: 'brine drops flung off, splashing and drying into small white salt cubes', fam: 'drip', gap: 12, g: 'L09-brine', mo: 'L09-drip', x: '-', car: 'comet' });
  M('tail-sweep', { nm: 'crested tails', desc: 'a heavy tail with a double row of crests swept from one side to the other, spray off the tip', fam: 'slash', gap: 16, g: 'L09-tail', mo: 'L09-swish', x: '-', car: 'comet' });
  /* delta gharial */
  M('ghara-snout', { nm: 'ghara snouts', desc: 'a thin gharial snout ending in the round pot-shaped ghara knob, buzzing bubbles out of it, then driven out with a strike star', fam: 'thrust', gap: 18, g: 'L09-ghara', mo: 'L09-thrust', x: '-', car: 'rings' });
  M('log-mimic', { nm: 'logs with eyes', desc: 'a log drifting on the water line, bark grain and a cut end; then two eyes open on it and sink again', fam: 'ripple', gap: 20, g: 'L09-logeye', mo: 'L09-drift', x: '-', car: 'roll' });
  /* alligator snapper */
  M('worm-lure', { nm: 'worm lures', desc: 'gaping hooked jaws with a pink worm tongue wriggling inside, a fish drawing close, then the snap with crack marks; the chain is a little fish swimming to the next piece towards a wriggling pink worm', fam: 'bite', gap: 16, g: 'L09-lure', mo: 'L09-lurewig', x: '-', car: 'custom', carDraw: carLure });
  M('hook-jaw', { nm: 'hook jaws', desc: 'a huge rough head side-on, the hooked beak gaping on a pink mouth, slamming shut with a star and crack lines', fam: 'bash', gap: 16, g: 'L09-hookjaw', mo: 'L09-chomp', x: '-', car: 'comet' });
  M('keel-shell', { nm: 'keeled shells', desc: 'a shell with three spiked keels like a little mountain range, weed strands waving off it', fam: 'shield', gap: 18, g: 'L09-keel', mo: 'L09-sway', x: '-', car: 'roll' });
  M('mud-doze', { nm: 'mud dozes', desc: 'half sunk in mud, only the spiked shell top and a resting head showing, eye shut, bubbles rising from the nostrils', fam: 'mend', gap: 18, g: 'L09-mudnap', mo: 'L09-bubble', x: '-', car: 'rings' });
  M('weed-coat', { nm: 'weed coats', desc: 'long weed strands waving off a spiked shell so the animal vanishes into the pond bottom', fam: 'leaf', gap: 14, g: 'L09-weed', mo: 'L09-wave', x: '-', car: 'flutter' });
  /* mire toad */
  M('toad-slime', { nm: 'slime strings', desc: 'a warty teal back with yellow glands, strings of slime stretching off the warts and snapping into drops', fam: 'drip', gap: 14, g: 'L09-slime', mo: 'L09-ooze', x: '-', car: 'trail' });
  M('belly-flop', { nm: 'belly flops', desc: 'a fat toad up in the air with its legs spread, then flat on its belly with mud splashing out and squashing back', fam: 'bash', gap: 18, g: 'L09-bellyflop', mo: 'L09-flop', x: '-', car: 'hop' });
  M('bog-breath', { nm: 'bog gas', desc: 'a bog-gas bubble welling up, swelling with a sheen, bursting into wavy stink curls', fam: 'puff', gap: 14, g: 'L09-gas', mo: 'L09-burp', x: '-', car: 'cloud' });
  M('fly-tongue', { nm: 'fly tongues', desc: 'a toad head with golden eyes, its sticky pink tongue shooting out at a fly and reeling it in', fam: 'thrust', gap: 16, g: 'L09-tongue', mo: 'L09-flick', x: '-', car: 'comet' });
  /* elder mire toad */
  M('moss-back', { nm: 'mossy backs', desc: 'a huge old toad back with big warts, moss sprigs growing up off it and a heavy-lidded eye that opens a crack of gold', fam: 'leaf', gap: 18, g: 'L09-mossback', mo: 'L09-slow', x: '-', car: 'train' });
  M('belch-blast', { nm: 'belches', desc: 'a pale throat sac swelling, then a ring of foul green belch bursting out with spit flecks', fam: 'puff', gap: 18, g: 'L09-belch', mo: 'L09-swell', x: '-', car: 'rings' });
  M('fog-hush', { nm: 'marsh fog', desc: 'three bands of low marsh fog rolling sideways, a half-shut golden eye fading into them', fam: 'puff', gap: 18, g: 'L09-fog', mo: 'L09-fogdrift', x: '-', car: 'cloud' });
  /* goliath frog */
  M('goliath-leap', { nm: 'giant leaps', desc: 'the giant flat-headed frog crouched, launching, flying flat out with legs trailing, landing splayed in a splash; the chain is one huge leap along a dotted arc with a splash ring at the next piece', fam: 'bash', gap: 20, g: 'L09-goliath', mo: 'L09-leap', x: '-', car: 'custom', carDraw: carGiantLeap });
  M('crab-gulp', { nm: 'crab gulps', desc: 'a wide flat frog mouth swallowing a red crab whole, the eyes pressed down into the head to push it in', fam: 'bite', gap: 18, g: 'L09-crab', mo: 'L09-swallow', x: '-', car: 'hop' });
  M('rubber-hide', { nm: 'rubber skin', desc: 'a patch of thick granular skin bulging out under a blow and springing back', fam: 'shield', gap: 16, g: 'L09-rubber', mo: 'L09-boing', x: '-', car: 'train' });
  M('rock-nest', { nm: 'rock nests', desc: 'round river stones shoved into a nest ring by a big hand, a pool filling, the frog sitting heavy on top', fam: 'bash', gap: 18, g: 'L09-rocknest', mo: 'L09-push', x: '-', car: 'train' });
  /* reef turtle */
  M('reef-glide', { nm: 'reef swimmers', desc: 'a hawksbill from above, mottled amber scutes and a pointed beak, front flippers stroking like wings; the chain is the turtle swimming over a strip of coral tufts to the next piece', fam: 'ripple', gap: 20, g: 'L09-turtle', mo: 'L09-swim', x: '-', car: 'custom', carDraw: carReefSwim });
  M('flipper-slap', { nm: 'flipper slaps', desc: 'one broad front flipper raised, swung and slapped flat on the water in a burst of spray', fam: 'slash', gap: 16, g: 'L09-flipslap', mo: 'L09-slap', x: '-', car: 'hop' });
  M('scute-tiles', { nm: 'tortoiseshell', desc: 'overlapping tortoiseshell scutes like roof tiles, amber streaks shimmering, a yellow cleaner fish nibbling along', fam: 'shield', gap: 16, g: 'L09-scutes', mo: 'L09-tile', x: '-', car: 'train' });
  M('hawk-beak', { nm: 'hawk beaks', desc: 'a pointed hooked hawksbill beak nipping an orange sponge off the reef, bits flying', fam: 'bite', gap: 16, g: 'L09-hawkbeak', mo: 'L09-chomp', x: '-', car: 'comet' });
  /* leatherback */
  M('ridge-dive', { nm: 'ridged divers', desc: 'a leatherback from above: a long ridged teardrop with white spots and enormous front flippers beating; the chain is a dive under the edge (dark dashed depth line, bubbles) and back up at the next piece', fam: 'puff', gap: 20, g: 'L09-leather', mo: 'L09-stroke', x: '-', car: 'custom', carDraw: carDeepDive });
  M('abyss-sink', { nm: 'deep sinks', desc: 'a shell outline shrinking into a dark ring as it sinks, glowing deep-sea specks left behind', fam: 'puff', gap: 16, g: 'L09-abyss', mo: 'L09-sink', x: '-', car: 'blink' });
  M('great-flipper', { nm: 'oar flippers', desc: 'one enormous front flipper rowing round like an oar, white spots along it, a swirl of water off the tip', fam: 'slash', gap: 20, g: 'L09-oar', mo: 'L09-row', x: '-', car: 'comet' });
  M('jelly-snatch', { nm: 'jelly gulps', desc: 'a pale jellyfish drifting in and gulped by a spotted beak, the spiny throat showing', fam: 'bite', gap: 16, g: 'L09-jelly', mo: 'L09-swallow', x: '-', car: 'hop' });
})();
