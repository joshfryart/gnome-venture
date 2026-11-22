/* Motif module, large batch L07 (grey-heron, goliath-heron, pelican-parliament, frigatebird, albatross, fern-cassowary).
   TEMPLATE.md sections 9 and 10.3. 26 motifs, each with its own pixel glyph (ids prefixed L07-) and motion; five have their own chain effect (carDraw):
   a grey heron flapping slowly to the next piece, a pelican vote passing bill by bill, a frigatebird chasing a dropped fish, an albatross dynamic-soaring
   in S-curves, a cassowary dashing through ferns that part and spring back.
   Glyph coordinates are (a, b): a along the edge tangent, b outward along the normal, so every sprite turns with the edge it sits on. fr0() stores the
   frame in module scratch variables, p()/s()/row()/cl()/lin() plot in (a, b). Glyph draws never nest, so the scratch is safe; nothing is allocated per
   frame (the constant tables below are built once at load), there is no Math.random / Date, every effect is a stateless function of p.
   Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy
   default are untouched (they live in the page). Glyphs reach at most ~17 px out and stay within ~22 px of the edge with their layout offset. */
(function () {
  var X0 = 0, Y0 = 0, TX = 1, TY = 0, NX = 0, NY = -1, KK = null;
  var LEG = '#c8b070', WATER = '#7aa6b8', STEEL = '#5c616a', FISH = '#d2dce4', BILLY = '#f0c850', BILLP = '#f2b4a0', SQUID = '#f0c8d4',
    RED = '#e0402e', CASQ = '#b88a52', BLUE = '#4cc4e8', CLAW = '#f2ecd8', DFW = '#e8f4ff', DARKB = '#1a181e';
  var STAB_L = [5, 4, 10, 10], GOL_L = [5, 4, 9, 9], FOOT_A = [1, 3, 5, 4], FOOT_B = [2, 5, 3, 0], KNEE_A = [2, 4, 4, 3], KNEE_B = [6, 7, 6, 4],
    DF_B = [9, 6, 3, 7], DF_A = [2, 0, -2, 1], TILT = [0, 1, 0, -1], FAN = [.15, .3, .45, .55], RUN_A = [-3, -1, 2, 1], RUN_B = [0, 2, 0, 1], RUN2_A = [2, 1, -2, -1], RUN2_B = [0, 1, 0, 2];
  var DIR = [], CUP = [], i0;                                            /* tables built once: fish tumble directions, 12 ring directions */
  for (i0 = 0; i0 < 4; i0++) { DIR.push(Math.cos(i0 * Math.PI / 4)); DIR.push(Math.sin(i0 * Math.PI / 4)); }
  for (i0 = 0; i0 < 12; i0++) { CUP.push(Math.cos(i0 * Math.PI / 6)); CUP.push(Math.sin(i0 * Math.PI / 6)); }

  function fr0(x, y, tx, ty, nx, ny, K) { X0 = x; Y0 = y; TX = tx; TY = ty; NX = nx; NY = ny; KK = K; }
  function p(c, a, b, col) { KK.px(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, col); }
  function s(c, a, b, w, col) { KK.sq(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, w, col); }
  function row(c, a0, a1, b, col) { for (var a = a0; a <= a1; a++) p(c, a, b, col); }
  function cl(c, a, b0, b1, col) { for (var b = b0; b <= b1; b++) p(c, a, b, col); }
  function lin(c, a0, b0, a1, b1, col) { var n = Math.max(Math.abs(a1 - a0), Math.abs(b1 - b0)), i; if (n < 1) { p(c, a0, b0, col); return; }
    for (i = 0; i <= n; i++) p(c, a0 + (a1 - a0) * i / n, b0 + (b1 - b0) * i / n, col); }
  function zee(c, a, b, col) { row(c, a, a + 2, b + 2, col); p(c, a + 1, b + 1, col); row(c, a, a + 2, b, col); }

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
  /* --- grey heron: grey neck, black crest stripe and plume, yellow dagger bill --- */
  PFA.glyph('L07-heronstab', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* the S-necked heron head: coiled, drawn back, shot out straight, the strike star and spray */
    fr0(x, y, tx, ty, nx, ny, K); var b, a, L = STAB_L[fr] + (z > 1 ? 1 : 0), bend = fr === 0 ? 1.6 : fr === 1 ? -2 : 0, ah;
    for (b = 0; b <= L; b++) { a = Math.sin(b / L * Math.PI) * bend; p(c, a, b, C); p(c, a + 1, b, (b & 1) ? K.WHITE : C); if (b > 1 && b % 3 === 0) p(c, a + 1, b, A); }
    ah = Math.sin(1 * Math.PI) * bend; s(c, ah, L + 1, 3, C); p(c, ah + 1, L + 2, K.WHITE); p(c, ah - 1, L + 1, A); p(c, ah - 1, L + 2, A);   /* head, white face, black stripe */
    p(c, ah - 2, L + 1, A); p(c, ah - 3, L, A); p(c, ah - 4, L - 1, A);                                    /* the trailing black plume */
    cl(c, ah, L + 3, L + 6, Hi); p(c, ah + 1, L + 3, Hi); p(c, ah, L + 7, K.WHITE);                       /* yellow dagger bill */
    if (fr === 3) { p(c, ah, L + 9, K.WHITE); p(c, ah - 2, L + 8, K.DEW); p(c, ah + 2, L + 8, K.DEW); p(c, ah - 3, L + 6, K.DEW); p(c, ah + 3, L + 6, K.DEW); }
  });
  PFA.glyph('L07-onelegs', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a heron hunched on one leg in the shallows, grey mantle folded, ripple rings widening round the foot */
    fr0(x, y, tx, ty, nx, ny, K); var i, r = 1.5 + fr * 1.2 + (z > 1 ? .5 : 0), w = z > 1 ? 1 : 0;
    for (i = 0; i < 12; i++) if (CUP[i * 2 + 1] > -.4) p(c, CUP[i * 2] * r * 1.7, CUP[i * 2 + 1] * r * .5, i & 1 ? WATER : K.DEW);
    cl(c, 0, 0, 5, LEG); p(c, 1, 6, LEG); p(c, 2, 6, LEG); p(c, 2, 7, LEG);                                /* the standing leg, the other tucked */
    row(c, -3 - w, 3, 7, C); row(c, -3 - w, 3, 8, C); row(c, -2 - w, 3, 9, C); row(c, -1, 2, 10, C);      /* hunched body */
    row(c, -3 - w, 0, 7, A); p(c, -2, 9, A); p(c, -1, 9, A); p(c, 3, 8, K.WHITE); p(c, 3, 9, K.WHITE);     /* folded wing edge, black shoulder patch, pale breast */
    s(c, 2, 11, 2, C); p(c, 1, 12, A); p(c, 0, 12, A); p(c, -1, 11, A); row(c, 3, 6, 11, Hi);             /* neck tucked, crest, bill level */
    if (fr === 3) p(c, 7, 11, K.WHITE);
  });
  PFA.glyph('L07-wadeleg', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a heron wading: one stilt leg planted, the other lifted high at the knee and set down without a splash */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0;
    row(c, -5, 5, 0, WATER); p(c, -6, 1, K.DEW); p(c, 6, 1, K.DEW);
    cl(c, -1, 1, 8, LEG); lin(c, 0, 8, KNEE_A[fr], KNEE_B[fr], LEG); lin(c, KNEE_A[fr], KNEE_B[fr], FOOT_A[fr], FOOT_B[fr], LEG);   /* planted leg, stepping leg */
    row(c, -3 - w, 3, 9, C); row(c, -3 - w, 3, 10, C); row(c, -2, 2, 11, C); row(c, -3 - w, -1, 10, A);
    lin(c, 2, 12, 3, 15, C); p(c, 4, 13, K.WHITE); s(c, 3, 16, 2, C); p(c, 2, 17, A); p(c, 1, 17, A); row(c, 4, 7, 16, Hi);   /* neck, head, crest, bill */
    if (fr === 3) { p(c, FOOT_A[3] - 2, 1, K.WHITE); p(c, FOOT_A[3] + 2, 1, K.WHITE); }
    if (fr === 1) p(c, FOOT_A[1] + 1, FOOT_B[1] - 2, K.DEW);
  });
  PFA.glyph('L07-minnow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the bill snapping shut on a silver minnow, the catch flicked up in a spray */
    fr0(x, y, tx, ty, nx, ny, K); var op = fr === 0 ? 2 : fr === 1 ? 1 : 0, L = 9 + (z > 1 ? 1 : 0), b;
    s(c, 0, 1, 3, C); p(c, -1, 2, A); p(c, -2, 2, A); p(c, -3, 1, A); p(c, 1, 2, K.WHITE);
    for (b = 3; b <= L; b++) { p(c, -op * (b - 3) / (L - 3), b, Hi); p(c, op * (b - 3) / (L - 3) + (op ? 0 : 1), b, b < L ? Hi : K.WHITE); }
    if (fr === 2) { row(c, -3, 3, L - 1, FISH); p(c, -4, L - 2, FISH); p(c, -4, L, FISH); p(c, 2, L - 1, A); p(c, 0, L, K.WHITE); }
    if (fr === 3) { cl(c, 0, L + 2, L + 6, FISH); p(c, -1, L + 7, FISH); p(c, 1, L + 7, FISH); p(c, 0, L + 3, A); p(c, -3, L + 3, K.DEW); p(c, 3, L + 4, K.DEW); p(c, -2, L + 6, K.DEW); }
    if (fr === 0) { p(c, 0, L + 2, FISH); p(c, 1, L + 2, FISH); p(c, -1, L + 3, FISH); }
  });
  PFA.glyph('L07-heronfly', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a heron in flight: neck folded back, legs trailing, big bowed wings beating slowly */
    fr0(x, y, tx, ty, nx, ny, K); var up = fr === 0 || fr === 3, w = z > 1 ? 1 : 0;
    row(c, -3, 3, 6, C); row(c, -2, 3, 5, C); s(c, 4, 7, 2, C); p(c, 4, 8, A); row(c, 5, 8, 7, Hi);       /* body, tucked head, bill */
    row(c, -9 - w, -4, 6, LEG); p(c, -9 - w, 5, LEG); p(c, -9 - w, 7, LEG);                              /* trailing legs */
    if (up) { lin(c, -1, 7, -3, 11 + w, C); lin(c, 1, 7, 0, 12 + w, C); lin(c, -3, 11 + w, 0, 12 + w, A); p(c, -2, 9, C); p(c, -1, 10, C); }
    else { lin(c, -1, 4, -3, 0 - w, C); lin(c, 1, 4, 0, -1 - w, C); lin(c, -3, 0 - w, 0, -1 - w, A); p(c, -1, 2, C); p(c, -2, 1, C); }
    if (fr === 1 || fr === 2) { p(c, -3, 8, A); p(c, 0, 8, C); }
  });
  /* --- goliath heron: chestnut head and neck, grey back, a huge dark bill --- */
  PFA.glyph('L07-goliath', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* the giant heron's head and thick chestnut neck behind a heavy dark bill: coiled, drawn back, driven out, the hit */
    fr0(x, y, tx, ty, nx, ny, K); var b, a, L = GOL_L[fr] + (z > 1 ? 1 : 0), bend = fr === 0 ? 1.4 : fr === 1 ? -1.8 : 0, ah = 0;
    row(c, -3, 3, 0, Hi); row(c, -2, 2, 1, Hi);                                                           /* grey shoulders */
    for (b = 1; b <= L; b++) { a = Math.sin(b / L * Math.PI) * bend; p(c, a - 1, b, C); p(c, a, b, C); p(c, a + 1, b, (b % 3 === 1) ? K.WHITE : C); }   /* thick neck, streaked throat */
    s(c, ah, L + 1, 3, C); p(c, ah - 1, L + 2, C); p(c, ah - 2, L + 1, C); p(c, ah + 1, L + 2, Hi); p(c, ah - 1, L + 1, A);   /* bushy chestnut crown, yellow-grey eye */
    for (b = L + 3; b <= L + 8; b++) { p(c, ah, b, STEEL); if (b < L + 6) p(c, ah + 1, b, STEEL); }
    p(c, ah - 1, L + 3, STEEL); p(c, ah, L + 9, Hi);
    if (fr === 3) { p(c, ah, L + 11, K.WHITE); p(c, ah - 1, L + 10, K.WHITE); p(c, ah + 1, L + 10, K.WHITE); p(c, ah - 3, L + 9, Hi); p(c, ah + 3, L + 9, Hi); p(c, ah - 4, L + 6, K.DEW); p(c, ah + 4, L + 7, K.DEW); }
  });
  PFA.glyph('L07-gulp', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a big fish swallowed whole: held across the bill, turned head first, the bulge sliding down the long neck */
    fr0(x, y, tx, ty, nx, ny, K); var b, bb = fr === 2 ? 7 : fr === 3 ? 3 : -9, L = 9 + (z > 1 ? 1 : 0);
    row(c, -3, 3, 0, Hi);
    for (b = 1; b <= L; b++) { var bw = Math.abs(b - bb) <= 1 ? 2 : 1; row(c, -bw, bw - 1 + (bw > 1 ? 1 : 0), b, C); if (b === bb) p(c, 0, b, FISH); }
    s(c, 0, L + 1, 3, C); p(c, -1, L + 1, A); p(c, 1, L + 2, Hi);
    cl(c, 0, L + 3, L + 7, STEEL); p(c, 1, L + 3, STEEL); p(c, 1, L + 4, STEEL);
    if (fr === 0) { row(c, -4, 3, L + 6, FISH); p(c, -5, L + 5, FISH); p(c, -5, L + 7, FISH); p(c, 2, L + 6, A); }
    if (fr === 1) { cl(c, 1, L + 7, L + 9, FISH); p(c, 0, L + 9, FISH); p(c, 2, L + 9, FISH); p(c, 2, L + 10, FISH); p(c, 0, L + 10, FISH); }
    if (fr === 3) { p(c, -3, L + 4, K.WHITE); p(c, 3, L + 5, K.WHITE); }
  });
  PFA.glyph('L07-reflect', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* the very tall heron standing in shallow water, its reflection broken by a slow shimmer */
    fr0(x, y, tx, ty, nx, ny, K); var sh = fr & 1, w = z > 1 ? 1 : 0;
    row(c, -6, 6, 2, WATER); p(c, -7 + fr, 1, K.DEW); p(c, 5 - fr, 1, K.DEW);
    p(c, -1 + sh, 1, C); p(c, 1 - sh, 1, C); p(c, -1, 0, Hi); p(c, 1, 0, Hi); p(c, 2 - sh, 0, C);          /* the broken reflection */
    cl(c, -1, 3, 7 + w, STEEL); cl(c, 1, 3, 7 + w, STEEL);                                               /* long legs */
    row(c, -3, 2, 8 + w, Hi); row(c, -3, 3, 9 + w, Hi); row(c, -2, 3, 10 + w, Hi); p(c, 3, 8 + w, C); p(c, 3, 10 + w, C);   /* grey back, chestnut breast */
    cl(c, 3, 11 + w, 13 + w, C); p(c, 2, 12 + w, C); s(c, 3, 14 + w, 2, C); p(c, 2, 15 + w, A); row(c, 4, 7, 14 + w, STEEL);
    if (fr === 3) { p(c, -5, 3, K.WHITE); p(c, 5, 3, K.WHITE); }
  });
  PFA.glyph('L07-dragonfly', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* the long wait: a darter dragonfly hovers, settles on the motionless bill tip and lifts away */
    fr0(x, y, tx, ty, nx, ny, K); var db = DF_B[fr], da = DF_A[fr], wf = fr & 1;
    row(c, -7, 1, 1, STEEL); row(c, -7, -2, 0, STEEL); p(c, 2, 1, Hi);                                   /* the still bill tip */
    row(c, da - 3, da + 2, db, C); p(c, da + 3, db, A); p(c, da + 3, db + 1, A);                          /* body and big eyes */
    p(c, da - 1, db + 1 + wf, DFW); p(c, da - 2, db + 2, DFW); p(c, da + 1, db + 1 + wf, DFW); p(c, da + 1, db + 2, DFW);
    p(c, da - 1, db - 1 - wf, DFW); p(c, da - 2, db - 2, DFW); p(c, da + 1, db - 1 - wf, DFW); p(c, da + 1, db - 2, DFW);
    if (fr === 2) { p(c, -4, 3, Hi); p(c, 4, 3, Hi); }
    if (fr === 3) p(c, da + 5, db + 2, K.WHITE);
  });
  PFA.glyph('L07-plume', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* long grey back plumes fanning up off a chestnut back, white tips */
    fr0(x, y, tx, ty, nx, ny, K); var i, sp = FAN[fr], L = 7 + (z > 1 ? 1 : 0), an, ea, eb;
    row(c, -4, 4, 0, C); row(c, -3, 3, 1, C); p(c, 0, 1, A);
    for (i = -2; i <= 2; i++) { an = i * sp; ea = Math.sin(an) * (L - Math.abs(i)); eb = 1 + Math.cos(an) * (L - Math.abs(i)); lin(c, i * .5, 1, ea, eb, Hi); p(c, ea, eb + 1, K.WHITE); if (i) p(c, ea * .6 + (i > 0 ? 1 : -1), eb * .6, Hi); }
  });
  /* --- pelican parliament: white pelicans, yellow bills, orange pouches, black wing tips --- */
  PFA.glyph('L07-pouch', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a pelican bill pointing out, the pouch slack, scooping, bulging with water, tipping it out */
    fr0(x, y, tx, ty, nx, ny, K); var L = 10 + (z > 1 ? 1 : 0), b;
    s(c, 0, 1, 3, C); p(c, -1, 2, A); p(c, -1, 0, C); p(c, -2, 1, C);
    cl(c, 0, 3, L, BILLY); p(c, 0, L + 1, Hi);
    if (fr === 0) { for (b = 4; b < L; b++) p(c, 1, b, Hi); }
    else if (fr === 1) { for (b = 4; b < L; b++) p(c, 1 + (b - 4) * .4, b, Hi); p(c, 2, 6, Hi); p(c, 3, 8, Hi); }
    else { for (b = 4; b < L; b++) { var bw = Math.round(3.2 * Math.sin((b - 3) / (L - 3) * Math.PI)) + (fr === 2 ? 1 : 0); row(c, 1, bw, b, Hi); if (bw > 2) p(c, 2, b, K.DEW); } p(c, 3, 7, K.WHITE); }
    if (fr === 3) { p(c, 5, L, K.DEW); p(c, 6, L - 2, K.DEW); p(c, 4, L + 2, K.DEW); p(c, 7, L - 4, K.WHITE); }
  });
  PFA.glyph('L07-wingwall', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a pelican standing broadside with both wings opening wide, black flight feathers at the ends */
    fr0(x, y, tx, ty, nx, ny, K); var W = 3 + fr * 1.5 + (z > 1 ? 1 : 0), a;
    p(c, -1, 0, LEG); p(c, 1, 0, LEG); row(c, -2, 2, 1, C); row(c, -2, 2, 2, C); row(c, -2, 2, 3, C); row(c, -1, 1, 4, C);
    for (a = 1; a <= W; a++) { var tip = a > W - 2; p(c, -1 - a, 4 + a * .25, tip ? A : C); p(c, 1 + a, 4 + a * .25, tip ? A : C); p(c, -1 - a, 3 + a * .25, tip ? A : C); p(c, 1 + a, 3 + a * .25, tip ? A : C); }
    cl(c, 0, 5, 6, C); s(c, 0, 7, 2, C); p(c, -1, 7, A); row(c, 1, 4, 7, BILLY); row(c, 1, 3, 6, Hi);
  });
  PFA.glyph('L07-vote', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a pelican raising its bill like a hand in a vote: down, rising, straight up, counted (a tick) */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0;
    row(c, -2, 2, 0, C); row(c, -1, 1, 1, C); cl(c, 0, 2, 4, C); s(c, 0, 5, 2, C); p(c, -1, 5, A);
    if (fr === 0) { row(c, 1, 7 + w, 5, BILLY); row(c, 1, 6 + w, 4, Hi); }
    else if (fr === 1) { lin(c, 1, 6, 5 + w, 10 + w, BILLY); lin(c, 1, 5, 5, 9, Hi); }
    else { cl(c, 0, 7, 12 + w, BILLY); cl(c, 1, 7, 11 + w, Hi); p(c, 0, 13 + w, Hi); }
    if (fr === 3) { p(c, -3, 14 + w, K.WHITE); p(c, -2, 15 + w, K.WHITE); p(c, -1, 14 + w, K.WHITE); p(c, 0, 13 + w + 3, K.WHITE); p(c, 1, 17 + w, K.WHITE); p(c, -1, 15 + w, K.WHITE); }
  });
  PFA.glyph('L07-pelfly', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a pelican flying in line: neck folded, the long bill resting on the chest, broad wings gliding with black tips */
    fr0(x, y, tx, ty, nx, ny, K); var wb = fr === 1 ? -2 : fr === 3 ? 2 : 0, w = z > 1 ? 1 : 0;
    row(c, -4, 3, 6, C); row(c, -3, 2, 7, C); row(c, -3, 2, 5, C); s(c, 4, 7, 2, C); p(c, 4, 8, A);
    row(c, 5, 11 + w, 7, BILLY); row(c, 5, 10, 6, Hi);
    row(c, -2, 1, 8 + (wb > 0 ? 1 : 0), C); row(c, -3, 0, 9 + wb * .5, C); row(c, -4, -1, 10 + wb, C); row(c, -5, -3, 11 + wb, A); p(c, -6, 11 + wb, A);
    row(c, -6, -5, 6, C); p(c, -7, 6, A);
  });
  /* --- frigatebird: glossy black, a red throat balloon, a deep forked tail --- */
  PFA.glyph('L07-balloon', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a male frigatebird puffing up its red throat balloon until it shines */
    fr0(x, y, tx, ty, nx, ny, K); var r = 1 + fr + (z > 1 ? 1 : 0), cb = 3 + r;
    row(c, -4, 2, 0, DARKB); row(c, -4, 1, 1, DARKB); row(c, -3, 1, 2, DARKB); row(c, -2, 0, 3, DARKB); p(c, -4, 2, Hi); p(c, -3, 3, Hi); p(c, -5, 0, Hi);
    s(c, 2, cb, r * 2 + 1, C); p(c, 2 - r + 1, cb + r - 1, K.WHITE); p(c, 2 - r + 2, cb + r - 1, K.WHITE); p(c, 2 + r, cb, A);
    s(c, -1, cb + r + 2, 2, DARKB); row(c, 0, 3, cb + r + 2, Hi); p(c, 3, cb + r + 1, Hi); p(c, -2, cb + r + 2, Hi);
  });
  PFA.glyph('L07-frigate', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a frigatebird swooping: long crooked wings, the deep forked tail scissoring, a red throat, a stolen fish dropping */
    fr0(x, y, tx, ty, nx, ny, K); var o = fr & 1, w = z > 1 ? 1 : 0;
    row(c, -2, 3, 5, DARKB); row(c, -1, 2, 6, DARKB); row(c, -2, 2, 7, Hi); s(c, 4, 6, 2, DARKB); row(c, 5, 7, 6, Hi); p(c, 7, 5, Hi); s(c, 3, 4, 2, C); p(c, 2, 4, C); p(c, 3, 3, K.WHITE);   /* glossy back, red pouch */
    lin(c, -3, 5, -7 - w, 3 - o, DARKB); lin(c, -3, 6, -7 - w, 8 + o, DARKB);                              /* forked tail, scissoring */
    if (o) { lin(c, 0, 7, -2, 10 + w, DARKB); lin(c, -2, 10 + w, 2, 13 + w, DARKB); lin(c, 1, 7, -1, 10 + w, Hi); lin(c, -1, 11 + w, 2, 13 + w, Hi); }   /* crooked wing up, sheen on the leading edge */
    else { lin(c, 0, 4, -2, 1, DARKB); lin(c, -2, 1, 2, -1, DARKB); lin(c, 1, 4, -1, 1, Hi); lin(c, 1, 7, 2, 10, DARKB); lin(c, 2, 10, 5, 12 + w, DARKB); lin(c, 2, 8, 3, 10, Hi); lin(c, 3, 10, 5, 11 + w, Hi); }
    if (fr === 3) { row(c, 1, 3, 2, FISH); p(c, 0, 1, FISH); p(c, 0, 3, FISH); }
  });
  PFA.glyph('L07-stormsoar', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a frigatebird hanging high on storm wind: a crooked black silhouette over curling wind streaks */
    fr0(x, y, tx, ty, nx, ny, K); var i, o = fr * 2, w = z > 1 ? 1 : 0, t = TILT[fr] * .3;
    row(c, -5 + o, -1 + o, 2, K.WHITE); p(c, o, 3, K.WHITE); row(c, 2 - o, 6 - o, 4, Hi); p(c, 7 - o, 5, Hi); row(c, -4 + fr, 0 + fr, 13, Hi);
    for (i = 1; i <= 6 + w; i++) { p(c, -i, 8 + (i < 4 ? i * .5 : 3 - (i - 4) * .7) + i * t, DARKB); p(c, i, 8 + (i < 4 ? i * .5 : 3 - (i - 4) * .7) - i * t, DARKB); }
    for (i = 2; i <= 5 + w; i++) { p(c, -i, 9 + (i < 4 ? i * .5 : 3 - (i - 4) * .7) + i * t, Hi); p(c, i, 9 + (i < 4 ? i * .5 : 3 - (i - 4) * .7) - i * t, Hi); }
    row(c, -1, 1, 8, DARKB); s(c, 0, 9, 2, C); p(c, 0, 10, DARKB); p(c, -1, 6, DARKB); p(c, 1, 6, DARKB); p(c, -2, 5, DARKB); p(c, 2, 5, DARKB); p(c, -3, 9, Hi); p(c, 3, 9, Hi);
  });
  PFA.glyph('L07-fishrob', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a robbed silver fish tumbling through the air, spray flying off it, the pirate's hooked bill snapping at its tail */
    fr0(x, y, tx, ty, nx, ny, K); var da = DIR[fr * 2], db = DIR[fr * 2 + 1], i, L = 3 + (z > 1 ? 1 : 0);
    for (i = -L; i <= L - 1; i++) { p(c, i * da, 5 + i * db, FISH); p(c, i * da - db * .9, 5 + i * db + da * .9, i > -L + 1 && i < L - 1 ? K.WHITE : FISH); }
    p(c, (L - 1) * da, 5 + (L - 1) * db, A); p(c, -L * da - db * 1.5, 5 - L * db + da * 1.5, FISH); p(c, -L * da + db * 1.5, 5 - L * db - da * 1.5, FISH);   /* eye, tail fork */
    if (fr < 2) { p(c, -L * da - 2 * da, 5 - (L + 2) * db, Hi); p(c, -L * da - 3 * da, 5 - (L + 3) * db, Hi); p(c, -L * da - 3 * da + db, 5 - (L + 3) * db - da, C); }
    p(c, 3 - fr, 10, K.DEW); p(c, -3 + fr, 1, K.DEW);
  });
  /* --- albatross: white, long narrow black-tipped wings, a pink hooked bill --- */
  PFA.glyph('L07-albatross', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* an albatross on its huge narrow wings, banking one tip down to the wave and up again */
    fr0(x, y, tx, ty, nx, ny, K); var W = 9 + (z > 1 ? 2 : z), i, sl = TILT[fr] * .32, bb;
    s(c, 0, 5, 3, C); p(c, 1, 6, C); row(c, 2, 4, 6, BILLP); p(c, 4, 7, BILLP); p(c, 1, 7, A);
    for (i = 2; i <= W; i++) { bb = 5 + sl * i + (i > W - 4 ? .4 * (i - W + 4) * .4 : 0);
      p(c, i, bb, i > W - 2 ? A : C); p(c, -i, 5 - sl * i, i > W - 2 ? A : C); if (i < W - 2) { p(c, i, bb - 1, A); p(c, -i, 4 - sl * i, A); } }
    p(c, -1, 4, C); p(c, -2, 3, Hi);
  });
  PFA.glyph('L07-floatbird', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* an albatross resting on the swell, riding the wave crest and down the trough */
    fr0(x, y, tx, ty, nx, ny, K); var a, w = z > 1 ? 1 : 0, ph = fr * 1.57;
    for (a = -7; a <= 7; a++) p(c, a, 1 + Math.sin(a * .6 + ph) * 1.2, (a + fr) % 4 ? WATER : K.DEW);
    row(c, -4 - w, 3, 3, C); row(c, -4 - w, 4, 4, C); row(c, -3, 3, 5, C); row(c, -4 - w, 0, 5, A); p(c, -5 - w, 5, A);
    cl(c, 3, 6, 7, C); s(c, 4, 8, 2, C); p(c, 4, 9, A); row(c, 5, 7, 8, BILLP); p(c, 7, 7, BILLP);
    if (fr === 2) { p(c, -6, 2, K.WHITE); p(c, 6, 3, K.WHITE); }
  });
  PFA.glyph('L07-squid', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* the hooked pink bill snatching a squid off the surface at night, the tentacles thrashing */
    fr0(x, y, tx, ty, nx, ny, K); var L = 7 + (z > 1 ? 1 : 0), sb = fr === 0 ? L + 4 : L + 1, wr = fr & 1, i;
    s(c, 0, 1, 3, C); p(c, -1, 2, A); p(c, -2, 1, A);
    cl(c, 0, 3, L, BILLP); p(c, 1, 3, BILLP); p(c, 1, L + 1, BILLP); p(c, 1, L, A);                       /* bill with its hooked tip */
    row(c, 1, 5, sb, SQUID); row(c, 2, 5, sb + 1, SQUID); p(c, 6, sb, SQUID); p(c, 6, sb + 1, Hi); p(c, 3, sb, A);   /* mantle, fin, eye */
    for (i = 0; i < 4; i++) p(c, -1 - i, sb + (i & 1 ? wr : -wr) + (i > 1 ? 1 : 0), SQUID);
    p(c, -1, sb + 2, SQUID); p(c, -2, sb + 3 - wr, SQUID); p(c, -3, sb - 2 + wr, SQUID);
    if (fr === 3) { p(c, 3, sb - 2, A); p(c, 4, sb - 3, A); }
    if (fr === 0) { p(c, 4, sb - 2, WATER); p(c, 2, sb - 2, WATER); }
  });
  PFA.glyph('L07-nap', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* an albatross asleep on the wing: head down, eye shut, little z marks drifting up */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0;
    row(c, -7 - w, 7 + w, 1, C); row(c, -7 - w, -6, 1, A); row(c, 6 + w, 7 + w, 1, A); row(c, -5, 5, 0, A);   /* the long wings held still */
    s(c, 0, 3, 3, C); row(c, -1, 1, 4, C); p(c, 0, 4, A); p(c, -1, 4, A); row(c, 2, 4, 3, BILLP); p(c, 4, 2, BILLP);
    zee(c, -2 + fr, 7 + fr * 2, Hi); if (fr > 1) zee(c, -5 + fr, 6 + (fr - 2) * 2, K.WHITE);
  });
  /* --- fern cassowary: fern-frond plumage, blue neck, red wattles, a tall casque, dagger toes --- */
  PFA.glyph('L07-casque', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the cassowary head lowered under its tall horn casque: blue neck, red wattles, the butt and its star */
    fr0(x, y, tx, ty, nx, ny, K); var lean = fr === 1 ? -1 : fr === 2 ? 1 : 0, b, w = z > 1 ? 1 : 0;
    row(c, -4, -1, 0, C); p(c, -5, 1, C); p(c, -3, 1, C); p(c, -4, 2, C); p(c, -2, 1, A);                  /* frond plumage at the base */
    for (b = 0; b <= 5; b++) { p(c, b * lean * .3, b, BLUE); p(c, b * lean * .3 + 1, b, b > 3 ? Hi : BLUE); }
    p(c, 2, 3, RED); p(c, 2, 2, RED); p(c, 3, 2, RED);                                                   /* wattles */
    s(c, lean * 1.5, 7, 3, BLUE); p(c, lean * 1.5 + 1, 7, A); row(c, lean * 1.5 + 2, lean * 1.5 + 4, 7, A);   /* head, eye, beak */
    row(c, lean * 2 - 1, lean * 2 + 1, 9, CASQ); row(c, lean * 2 - 1, lean * 2 + 1, 10, CASQ); row(c, lean * 2 - 1, lean * 2, 11, CASQ); p(c, lean * 2 - 1, 12 + w, CASQ); p(c, lean * 2 + 1, 9, A); p(c, lean * 2 + 1, 10, A);
    if (fr === 3) { p(c, -1, 14 + w, K.WHITE); p(c, -2, 15 + w, Hi); p(c, 0, 15 + w, Hi); p(c, -1, 16 + w, Hi); p(c, -3, 13 + w, K.WHITE); p(c, 1, 13 + w, K.WHITE); }
  });
  PFA.glyph('L07-dagger', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the cassowary foot kicking out: a scaly leg, three toes and the long dagger claw on the inner toe, a slash streak */
    fr0(x, y, tx, ty, nx, ny, K); var e = fr === 1 || fr === 2 ? 2 : 0, w = z > 1 ? 1 : 0;
    row(c, -2, 2, 0, C); p(c, -3, 1, C); p(c, 3, 1, C); p(c, 0, 1, A);                                    /* fronds over the thigh */
    cl(c, 0, 1, 4 + e, STEEL); cl(c, 1, 1, 4 + e, STEEL); p(c, 0, 2, LEG);
    cl(c, 0, 5 + e, 8 + e, STEEL); lin(c, 1, 5 + e, 3, 7 + e, STEEL); lin(c, -1, 5 + e, -2, 7 + e, STEEL);   /* toes */
    lin(c, -2, 8 + e, -3, 11 + e + w, CLAW); p(c, -2, 9 + e, CLAW); p(c, -3, 12 + e + w, K.WHITE);        /* the dagger claw */
    if (fr === 2) { lin(c, -6, 9 + e, -3, 14 + e, K.WHITE); p(c, -7, 8 + e, Hi); p(c, -2, 15 + e, Hi); }
    if (fr === 3) { p(c, 3, 9, Hi); p(c, -4, 6, Hi); }
  });
  PFA.glyph('L07-fronds', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the cassowary crouched under its fern-frond plumage: drooping fronds, pinnae, the casque tip peeking through */
    fr0(x, y, tx, ty, nx, ny, K); var i, b, a, sw = (fr - 1.5) * .25, L = 6 + (z > 1 ? 1 : 0);
    row(c, -4, 4, 0, A); row(c, -3, 3, 1, A);
    for (i = -2; i <= 2; i++) for (b = 1; b <= L - Math.abs(i); b++) { a = i * 1.8 + (i * .25 + sw) * b; p(c, a, b, b < 2 ? A : C); if (b > 1 && b & 1) { p(c, a - 1, b - 1, C); p(c, a + 1, b - 1, C); } }
    if (fr >= 2) { cl(c, 0, L - 1, L + 1, CASQ); p(c, 1, L - 1, BLUE); p(c, -1, L - 1, RED); }
    else p(c, 0, L - 1, CASQ);
  });
  PFA.glyph('L07-ferndash', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a cassowary sprinting side-on: frond plumage streaming back, blue neck stretched, casque forward, legs pounding */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0;
    lin(c, -1, 4, RUN_A[fr], RUN_B[fr], STEEL); lin(c, 1, 4, RUN2_A[fr], RUN2_B[fr], STEEL); p(c, RUN_A[fr] + 1, RUN_B[fr], STEEL); p(c, RUN2_A[fr] + 1, RUN2_B[fr], STEEL);
    row(c, -4 - w, 2, 5, A); row(c, -4 - w, 2, 6, C); row(c, -3, 2, 7, C); row(c, -2, 1, 8, C); p(c, -5 - w, 6, C); p(c, -6 - w, 7, C); p(c, -7 - w, 6, C); p(c, -6 - w, 5, A);
    lin(c, 2, 8, 4, 10, BLUE); p(c, 3, 8, Hi); p(c, 4, 9, RED); s(c, 5, 11, 2, BLUE); p(c, 6, 11, A); p(c, 7, 11, A); cl(c, 5, 12, 13, CASQ); p(c, 4, 13, CASQ);
    if (fr & 1) { p(c, -7, 2, C); p(c, -8, 3, C); }
  });

  /* ================= motions (mutate the scratch G; pp = time x speed) ================= */
  PFA.motion('L07-stab', function (G, pp, k, ph) { var u = (pp * 1.6 + ph) % 1;                                                                                    /* frozen, drawn back, shot out, recoil */
    if (u < .45) { G.fr = 0; G.d -= .5; } else if (u < .6) { G.fr = 1; G.d -= 1.5; } else if (u < .78) { G.fr = 2; G.d += 3; } else if (u < .88) { G.fr = 3; G.d += 3; } else G.fr = 0; });
  PFA.motion('L07-stand', function (G, pp, k, ph) { G.fr = Math.floor(pp * 3 + ph * 4 + k) & 3; });                                                                 /* motionless, only the rings move */
  PFA.motion('L07-wade', function (G, pp, k, ph) { var u = pp * 2.2 + ph; G.fr = Math.floor(u * 4) & 3; G.t += (u % 1) * 2 - 1; });                                 /* high slow steps */
  PFA.motion('L07-snap', function (G, pp, k, ph) { var u = (pp * 2.6 + ph) % 1; G.fr = u < .3 ? 0 : u < .45 ? 1 : u < .75 ? 2 : 3; G.up += G.fr === 3 ? 2 : 0; });
  PFA.motion('L07-flap', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 4) + k) & 3; G.up += Math.sin(pp * 6 + k) * 1.2; });                           /* slow deep wingbeats */
  PFA.motion('L07-heave', function (G, pp, k, ph) { var u = (pp * 1.3 + ph) % 1;                                                                                     /* the giant's slow coil and heavy drive */
    if (u < .5) G.fr = 0; else if (u < .65) { G.fr = 1; G.d -= 1; } else if (u < .82) { G.fr = 2; G.d += 3; } else { G.fr = 3; G.d += 3; } });
  PFA.motion('L07-swallow', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4.2 + ph * .8)); });                                                       /* hold, turn, gulp, gone */
  PFA.motion('L07-still', function (G, pp, k, ph) { G.fr = Math.floor(pp * 2.5 + ph * 4) & 3; });                                                                   /* barely moves, the water shimmers */
  PFA.motion('L07-settle', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4 + ph)); G.t += Math.sin(pp * 5 + k) * .6; });                            /* hover, settle, land, lift */
  PFA.motion('L07-fan', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 5 + ph * 1.5)); });
  PFA.motion('L07-scoop', function (G, pp, k, ph) { var u = (pp * 1.8 + ph) % 1; G.fr = u < .25 ? 0 : u < .45 ? 1 : u < .8 ? 2 : 3; G.d += G.fr === 1 ? 2 : 0; });
  PFA.motion('L07-spread', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 5 + ph)); G.t += Math.sin(pp * 3 + k) * .5; });
  PFA.motion('L07-vote', function (G, pp, k) { var u = pp * 2.2 - k * .22; G.fr = u < 0 ? 0 : u < .2 ? 1 : u < .6 ? 2 : 3; });                                        /* bills go up one after another */
  PFA.motion('L07-glide', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .7 ? 0 : u < .8 ? 1 : u < .9 ? 3 : 2; G.up += Math.sin(pp * 4 + k) * 1; });   /* long glide, a few beats */
  PFA.motion('L07-inflate', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4.5 + ph)); if (G.fr === 3) G.d += Math.sin(pp * 40) * .6; });           /* swells and throbs */
  PFA.motion('L07-swoop', function (G, pp, k, ph) { var u = (pp * 1.8 + ph) % 1; G.t += (u - .5) * 6; G.up += (1 - Math.abs(u - .5) * 2) * 3; G.fr = u > .75 ? 3 : (Math.floor(pp * 10) + k) & 1; });
  PFA.motion('L07-hang', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 4) + k) & 3; G.t += Math.sin(pp * 3 + k) * 2.5; G.up += Math.sin(pp * 2 + ph) * 1.5; });   /* hangs on the wind */
  PFA.motion('L07-tumblefish', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 12 + ph * 4) + k) & 3; G.up += Math.abs(Math.sin((pp * 3 + ph) * Math.PI)) * 3; });
  PFA.motion('L07-dyn', function (G, pp, k, ph) { var sn = Math.sin(pp * 5 + k + ph * 6); G.fr = sn > .5 ? 1 : sn < -.5 ? 3 : (sn > 0 ? 0 : 2); G.up += sn * 2.5; G.t += Math.cos(pp * 5 + k) * 1.5; });
  PFA.motion('L07-float', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 4) + k) & 3; G.up += Math.sin(pp * 5 + k + ph * 6) * 1.2; });
  PFA.motion('L07-grab', function (G, pp, k, ph) { var u = (pp * 1.8 + ph) % 1; G.fr = u < .3 ? 0 : u < .45 ? 1 : (Math.floor(pp * 10) & 1) ? 2 : 3; });
  PFA.motion('L07-doze', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 4) + k) & 3; G.up += Math.sin(pp * 2 + k) * .8; });
  PFA.motion('L07-butt', function (G, pp, k, ph) { var u = (pp * 1.8 + ph) % 1;                                                                                     /* lower the casque, drive in, star, back */
    if (u < .35) { G.fr = 1; G.d -= 1.5; } else if (u < .55) { G.fr = 2; G.d += 4 * (u - .35) / .2; } else if (u < .7) { G.fr = 3; G.d += 4; } else { G.fr = 0; G.d += 4 * (1 - (u - .7) / .3); } });
  PFA.motion('L07-kick', function (G, pp, k, ph) { var u = (pp * 2.2 + ph) % 1; G.fr = u < .3 ? 0 : u < .5 ? 1 : u < .7 ? 2 : 3; if (G.fr === 1 || G.fr === 2) G.d += 2; });
  PFA.motion('L07-droop', function (G, pp, k) { G.fr = (Math.floor(pp * 3) + k) & 3; G.t += Math.sin(pp * 2 + k) * .5; });
  PFA.motion('L07-dash', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 18) + k) & 3; G.t += Math.sin(pp * 6 + ph * 6) * 2; G.up += (Math.floor(pp * 18) & 1) * .8; });

  /* ================= custom chain effects (along the OUTER loop from e.a over e.d, eased e.hh) ================= */
  function carHeronFly(c, e, H) {       /* the grey heron flaps slowly to the next piece, its shadow sliding along the edge under it */
    var P = e.P, Q = H.Q, i, u, b, sd = e.d < 0 ? -1 : 1, fr = Math.floor(e.p * 7) & 3;
    for (i = 1; i <= 4; i++) { u = e.hh - i * .05; if (u < 0) break; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, e.acc); H.px(c, Q.x + Q.nx * 2 - Q.ny * sd, Q.y + Q.ny * 2 + Q.nx * sd, e.acc); }
    P.atq(e.a + e.d * e.hh); b = 6 + Math.sin(e.hh * Math.PI) * 4 + Math.sin(e.p * 14) * 1;
    H.glyph(c, 'L07-heronfly', Q.x + Q.nx * b, Q.y + Q.ny * b, e.z > 1 ? 1 : e.z, fr, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
  }
  function carVote(c, e, H) {           /* the vote passes along the outer edge: bill after bill goes up, the earliest already counted with a tick */
    var P = e.P, Q = H.Q, i, u, ag, n = 6;
    for (i = 0; i < n; i++) { u = (i + .5) / n; if (u > e.hh) break; ag = e.hh - u; P.atq(e.a + e.d * u);
      H.glyph(c, 'L07-vote', Q.x + Q.nx * 3, Q.y + Q.ny * 3, 0, ag < .08 ? 1 : ag < .3 ? 2 : 3, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny); }
  }
  function carSwoop(c, e, H) {          /* the frigatebird chases a dropped fish along the outer edge: the fish tumbles ahead, the pirate swoops after it on speed lines */
    var P = e.P, Q = H.Q, i, u, sd = e.d < 0 ? -1 : 1, uf = Math.min(1, e.hh + .12), b;
    for (i = 1; i <= 3; i++) { u = e.hh - i * .06; if (u < 0) break; P.atq(e.a + e.d * u); b = 7 + i; H.ln(c, Q.x + Q.nx * b, Q.y + Q.ny * b, Q.x + Q.nx * b - Q.ny * sd * 3, Q.y + Q.ny * b + Q.nx * sd * 3, 1, i === 1 ? e.hi : e.acc); }
    P.atq(e.a + e.d * uf); H.glyph(c, 'L07-fishrob', Q.x + Q.nx * 3, Q.y + Q.ny * 3, 0, 2 + (Math.floor(e.p * 12) & 1), e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
    P.atq(e.a + e.d * e.hh); b = 7 + Math.sin(e.hh * Math.PI) * 3;
    H.glyph(c, 'L07-frigate', Q.x + Q.nx * b, Q.y + Q.ny * b, e.z > 1 ? 1 : e.z, e.hh > .9 ? 3 : Math.floor(e.p * 10) & 1, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
  }
  function carSoar(c, e, H) {           /* the albatross dynamic-soars to the next piece: an S-curve of dots up into the wind and down to the wave, a wingtip skim mark at each low point */
    var P = e.P, Q = H.Q, i, u, b, sd = e.d < 0 ? -1 : 1, cs;
    for (i = 1; i <= 16; i++) { u = i / 16 * e.hh; if (i & 1) continue; P.atq(e.a + e.d * u); b = 8 + Math.sin(u * 19) * 4; H.px(c, Q.x + Q.nx * b, Q.y + Q.ny * b, b < 5.5 ? e.hi : H.WHITE);
      if (b < 4.6) H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, H.DEW); }
    P.atq(e.a + e.d * e.hh); b = 8 + Math.sin(e.hh * 19) * 4; cs = Math.cos(e.hh * 19);
    H.glyph(c, 'L07-albatross', Q.x + Q.nx * (b - 4), Q.y + Q.ny * (b - 4), e.z > 1 ? 1 : e.z, cs > .4 ? 1 : cs < -.4 ? 3 : 0, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
  }
  function carFernDash(c, e, H) {       /* the cassowary dashes through ferns along the outer edge: fronds part as it passes and spring back behind it */
    var P = e.P, Q = H.Q, i, u, ag, n = 5, sd = e.d < 0 ? -1 : 1;
    for (i = 0; i < n; i++) { u = (i + .5) / n; ag = e.hh - u; if (ag < -.15) break; P.atq(e.a + e.d * u);
      H.glyph(c, 'L07-fronds', Q.x + Q.nx * 2, Q.y + Q.ny * 2, 0, ag < 0 ? 1 : ag < .1 ? 3 : 0, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny); }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'L07-ferndash', Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.z > 1 ? 1 : e.z, Math.floor(e.p * 18) & 3, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
  }

  /* ================= motifs ================= */
  function M(name, meta) { PFA.motif(name, comp, meta); }
  /* grey heron */
  M('heron-stab', { nm: 'heron stabs', desc: 'a grey heron head on an S neck (black crest stripe and plume, yellow dagger bill) frozen coiled, drawn back, then shot out straight with a white strike star and spray', fam: 'thrust', gap: 16, g: 'L07-heronstab', mo: 'L07-stab', x: '-', car: 'comet' });
  M('still-stance', { nm: 'one-leg stands', desc: 'a grey heron hunched motionless on one leg in the shallows, mantle folded and bill level, ripple rings widening round its foot', fam: 'shield', gap: 18, g: 'L07-onelegs', mo: 'L07-stand', x: '-', car: 'rings' });
  M('wade-step', { nm: 'wading steps', desc: 'a heron wading: one stilt leg planted, the other lifted high at the knee and set down without a splash, a water line round its legs', fam: 'ripple', gap: 18, g: 'L07-wadeleg', mo: 'L07-wade', x: '-', car: 'hop' });
  M('minnow-snap', { nm: 'minnow snaps', desc: 'a yellow bill snapping shut on a silver minnow and flicking the catch up in a spray of drops', fam: 'bite', gap: 14, g: 'L07-minnow', mo: 'L07-snap', x: '-', car: 'comet' });
  M('heron-flight', { nm: 'heron flight', desc: 'a grey heron in flight, neck folded back and legs trailing, big bowed wings beating slowly; the chain is the heron flapping to the next piece with its shadow sliding along the edge', fam: 'puff', gap: 18, g: 'L07-heronfly', mo: 'L07-flap', x: '-', car: 'custom', carDraw: carHeronFly });
  /* goliath heron */
  M('goliath-bill', { nm: 'goliath bills', desc: 'the giant heron head on a thick chestnut neck with a streaked white throat behind a huge dark bill: a long still coil, then a heavy drive and a hit star', fam: 'thrust', gap: 18, g: 'L07-goliath', mo: 'L07-heave', x: '-', car: 'comet' });
  M('big-gulp', { nm: 'whole-fish gulps', desc: 'a big fish held across the dark bill, turned head first and swallowed whole, a bulge sliding down the long chestnut neck', fam: 'bite', gap: 16, g: 'L07-gulp', mo: 'L07-swallow', x: '-', car: 'hop' });
  M('long-reflection', { nm: 'tall reflections', desc: 'the very tall heron standing in shallow water on long dark legs, grey back and chestnut breast, its reflection broken by a slow shimmer', fam: 'shield', gap: 18, g: 'L07-reflect', mo: 'L07-still', x: '-', car: 'rings' });
  M('patience-fly', { nm: 'patient darters', desc: 'a red darter dragonfly hovering, settling on the motionless dark bill tip and lifting away again: the heron has not moved', fam: 'mend', gap: 16, g: 'L07-dragonfly', mo: 'L07-settle', x: '-', car: 'flutter' });
  M('plume-fan', { nm: 'plume fans', desc: 'long grey back plumes with white tips fanning up off a chestnut back', fam: 'shield', gap: 14, g: 'L07-plume', mo: 'L07-fan', x: 'sheen', car: 'flutter' });
  /* pelican parliament */
  M('pouch-scoop', { nm: 'pouch scoops', desc: 'a white pelican head with a long yellow bill, the orange pouch slack, scooping, bulging with water and tipping it out in drops', fam: 'bite', gap: 16, g: 'L07-pouch', mo: 'L07-scoop', x: '-', car: 'hop' });
  M('wing-wall', { nm: 'wing walls', desc: 'white pelicans standing broadside, wings opening wide with black flight feathers at the ends, side by side like a wall', fam: 'shield', gap: 16, g: 'L07-wingwall', mo: 'L07-spread', x: '-', car: 'train' });
  M('vote-bills', { nm: 'raised bills', desc: 'pelicans raising their long bills straight up like hands in a vote, one after another, the counted ones ticked; the chain is the vote passing bill by bill along the outer edge', fam: 'shield', gap: 14, g: 'L07-vote', mo: 'L07-vote', x: '-', car: 'custom', carDraw: carVote });
  M('pelican-line', { nm: 'pelican lines', desc: 'pelicans flying in a line, necks folded and bills resting on their chests, broad black-tipped wings gliding with a beat now and then', fam: 'puff', gap: 18, g: 'L07-pelfly', mo: 'L07-glide', x: '-', car: 'train' });
  /* frigatebird */
  M('pouch-balloon', { nm: 'red balloons', desc: 'a glossy black frigatebird puffing up its red throat balloon until it shines and throbs', fam: 'bash', gap: 16, g: 'L07-balloon', mo: 'L07-inflate', x: '-', car: 'hop' });
  M('fork-swoop', { nm: 'pirate swoops', desc: 'a black frigatebird swooping on long crooked wings, the deep forked tail scissoring, a red throat, a stolen fish dropping; the chain is the pirate chasing a tumbling fish to the next piece on speed lines', fam: 'shock', gap: 18, g: 'L07-frigate', mo: 'L07-swoop', x: '-', car: 'custom', carDraw: carSwoop });
  M('storm-soar', { nm: 'storm kites', desc: 'a crooked black frigatebird silhouette hanging high on the storm wind over curling white wind streaks', fam: 'puff', gap: 18, g: 'L07-stormsoar', mo: 'L07-hang', x: '-', car: 'flutter' });
  M('fish-rob', { nm: 'robbed fish', desc: 'a silver fish tumbling end over end through the air, spray flying off, a hooked bill snapping at its tail', fam: 'web', gap: 14, g: 'L07-fishrob', mo: 'L07-tumblefish', x: '-', car: 'hop' });
  /* albatross */
  M('wingspan-soar', { nm: 'dynamic soaring', desc: 'a white albatross on huge narrow black-tipped wings banking one tip down to the wave and up again; the chain is an S-curve of dots up into the wind and down to the water, a skim mark at every low point', fam: 'puff', gap: 22, g: 'L07-albatross', mo: 'L07-dyn', x: '-', car: 'custom', carDraw: carSoar });
  M('wave-float', { nm: 'swell rest', desc: 'an albatross resting on the swell, riding up the wave crest and down the trough, pink bill tucked', fam: 'mend', gap: 18, g: 'L07-floatbird', mo: 'L07-float', x: '-', car: 'roll' });
  M('squid-snatch', { nm: 'squid snatches', desc: 'a hooked pink bill snatching a pale squid off the surface, tentacles thrashing, an ink fleck', fam: 'bite', gap: 16, g: 'L07-squid', mo: 'L07-grab', x: '-', car: 'comet' });
  M('wing-nap', { nm: 'sleep on the wing', desc: 'an albatross asleep on its outstretched wings, head down, eye shut, little z marks drifting up', fam: 'mend', gap: 18, g: 'L07-nap', mo: 'L07-doze', x: '-', car: 'flutter' });
  /* fern cassowary */
  M('casque-head', { nm: 'casque butts', desc: 'a cassowary head lowered under its tall horn casque, blue neck and red wattles over fern-frond plumage, driving in with a white star', fam: 'bash', gap: 16, g: 'L07-casque', mo: 'L07-butt', x: '-', car: 'comet' });
  M('dagger-toe', { nm: 'dagger kicks', desc: 'a scaly cassowary foot kicking out, three toes and the long pale dagger claw on the inner toe, a white slash streak', fam: 'thrust', gap: 16, g: 'L07-dagger', mo: 'L07-kick', x: '-', car: 'comet' });
  M('fern-cloak', { nm: 'frond plumage', desc: 'the cassowary crouched under drooping fern-frond plumage, pinnae on every frond, the casque tip, a blue and red flash peeking through', fam: 'leaf', gap: 14, g: 'L07-fronds', mo: 'L07-droop', x: '-', car: 'train' });
  M('fern-dash', { nm: 'fern dashes', desc: 'a cassowary sprinting side-on, frond plumage streaming back, blue neck stretched and casque forward, legs pounding; the chain is the dash through ferns that part as it passes and spring back', fam: 'leaf', gap: 18, g: 'L07-ferndash', mo: 'L07-dash', x: 'clods', car: 'custom', carDraw: carFernDash });
})();
