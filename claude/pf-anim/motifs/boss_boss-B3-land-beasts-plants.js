/* Motif module, boss batch B3-land-beasts-plants (old-bramblehorn, dune-wyrm, jade-jaguar). TEMPLATE.md sections 9 and 10.3.
   19 motifs, each with its own pixel glyph (ids prefixed B3-) and motion; the three signature motifs have their own chain effect (carDraw):
   a bramble runner creeping along the outer loop with the antler growing at its tip, a sand ridge racing under the edge until the wyrm breaches
   at the next piece, and the jade spirit jaguar bounding along the outer loop with two fading afterimages behind it.
   Glyph coordinates are (a, b): a along the edge tangent, b outward along the normal, so every sprite turns with the edge it sits on
   (the canopy drop is the one exception: it falls straight down the screen, so it is drawn in screen axes).
   fr0() stores the glyph frame in module scratch variables; p()/row()/cl()/sg() then plot in (a, b). Glyph draws never nest, so the scratch is safe.
   Nothing is allocated per frame (lookup tables are built once at load); no Math.random / Date: every effect is a stateless function of p.
   Glyphs go through H.glyph so the MAXG budget counts them; chain bodies are capped at ~40 small blocks. Boss sprites reach ~11 px from their
   anchor so the effect stays within ~22 px of the edge. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy
   default are untouched (they live in the page). */
(function () {
  var X0 = 0, Y0 = 0, TX = 1, TY = 0, NX = 0, NY = -1, KK = null;
  var THORN = '#d8583a', BERRY = '#5a2462', LEAF = '#7cc05a', BARK = '#8a6a42', SPORE = '#b89a62', AMBER = '#f0b030',
    MAW = '#a8323a', SANDL = '#f4dca0', ACID = '#c8e05a', JADEL = '#b8f4d0', GOLD = '#f4d070', INK = '#08261a';
  var CA = [], CB = [], i0, t0;                                                 /* 12-point circle, built once */
  for (i0 = 0; i0 < 12; i0++) { t0 = i0 / 12 * Math.PI * 2; CA.push(Math.cos(t0)); CB.push(Math.sin(t0)); }
  var ANT_L = [4, 7, 9, 9];                                                     /* bramble antler: stem length per grow frame */
  var JET = [1, 6, 10, 5];                                                      /* sand geyser: jet height per frame */
  var IRIS = [2, 1, 0, 0];                                                      /* ring maw: open throat radius per frame */
  var RAKE = [2, 5, 8, 8];                                                      /* claw rake: gouge length per frame */

  function fr0(x, y, tx, ty, nx, ny, K) { X0 = x; Y0 = y; TX = tx; TY = ty; NX = nx; NY = ny; KK = K; }
  function p(c, a, b, col) { KK.px(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, col); }
  function row(c, a0, a1, b, col) { for (var a = a0; a <= a1; a++) p(c, a, b, col); }
  function cl(c, a, b0, b1, col) { for (var b = b0; b <= b1; b++) p(c, a, b, col); }
  function sg(c, a0, b0, a1, b1, col) {                                         /* 1 px segment between two (a, b) points */
    var n = Math.max(1, Math.round(Math.max(Math.abs(a1 - a0), Math.abs(b1 - b0)))), i, u;
    for (i = 0; i <= n; i++) { u = i / n; p(c, Math.round(a0 + (a1 - a0) * u), Math.round(b0 + (b1 - b0) * u), col); }
  }

  /* ---------- shared own-edge composition: the page's themedOwn() with this module's glyph / motion ---------- */
  function comp(c, e, H) {
    var runs = e.runs, mp = e.mp, M = e.M, z = e.z, pr = e.p, pp = pr * mp.spd, Q = H.Q, G = H.G, P = e.P,
      tie = mp.x === 'thread' || mp.lay === 'snare', ri, k, r, len, n, f, ph, sf, bx0, by0, nx, ny, x, y, lx = 0, ly = 0, has;
    for (ri = 0; ri < runs.length; ri++) {
      r = runs[ri]; len = r[1] - r[0]; n = Math.max(1, Math.min(7, Math.round(len / (M.gap || 12)))); if (mp.lay === 'lance') n = Math.min(n, 4); has = false;
      for (k = 0; k < n; k++) {
        f = (k + .5) / n; ph = H.hash(e.seed * 13 + k * 7 + ri * 31);
        H.lay(mp.lay, pr, f, ph, k); H.mot(M.mo, pp, k, ph);
        if (G.d > 20) G.d = 20;                                                 /* stay within ~22 px of the edge */
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
  function grow(G) { return Math.min(3, Math.floor(G.u * 5)); }                /* frame from the layout's own progress: grow, grow, full, flash */

  /* ================= old bramblehorn (ancient thicket stag: antlers of bramble cane) ================= */
  PFA.glyph('B3-antler', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a bramble-cane antler growing out of the edge: thorny stem, tines tipped in pale bone, a leaf and a blackberry */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, L = ANT_L[f] + (z > 1 ? 1 : 0), b, a;
    for (b = 0; b <= L; b++) { a = b > 5 ? 1 : 0; p(c, a, b, C); if (b < 3) p(c, a + 1, b, A);
      if (b & 1) p(c, a + ((b & 2) ? 1 : -1), b, THORN); }                     /* hooked red thorns alternating sides */
    if (f >= 1) { sg(c, 0, 3, -3, 6, C); p(c, -4, 7, Hi); p(c, -2, 4, LEAF); p(c, -3, 4, LEAF); }       /* first tine + leaf */
    if (f >= 1) { sg(c, 1, 5, 3, 7, C); p(c, 4, 8, Hi); }                                               /* second tine */
    if (f >= 2) { sg(c, 1, 7, -1, 9, C); p(c, -2, 10, Hi); p(c, 2, L + 1, Hi);                         /* crown tine, bone tip */
      p(c, 4, 6, BERRY); p(c, 5, 6, BERRY); p(c, 4, 5, BERRY); p(c, 5, 5, f === 3 ? K.WHITE : BERRY); } /* blackberry on the tine */
    if (f === 3) { p(c, -5, 8, K.WHITE); p(c, 5, 9, K.WHITE); p(c, 2, L + 3, K.WHITE); }                /* gore flash at the tips */
  });
  PFA.glyph('B3-cane', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* an arched bramble cane with hooked red thorns on top and blackberries hanging under it */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, w = z > 1 ? 5 : 4, a, b, j = f & 1;
    for (a = -w; a <= w; a++) { b = Math.round((6 + j) * Math.sin(Math.PI * (a + w) / (2 * w + 2))); p(c, a, b, C); if (Math.abs(a) > w - 2) p(c, a, b - 1, A);
      if (((a + w) % 2) === 0 && a > -w) { p(c, a, b + 1, THORN); if (f === 3) p(c, a + 1, b + 2, K.WHITE); } }
    p(c, -2, 2, BERRY); p(c, -1, 2, BERRY); p(c, -2, 1, BERRY); p(c, -1, 1, f === 2 ? K.WHITE : BERRY);
    p(c, 2, 3, BERRY); p(c, 3, 3, BERRY); p(c, 2, 2, BERRY); p(c, 3, 2, f === 0 ? K.WHITE : BERRY);
    p(c, -3, 4 + j, LEAF); p(c, -4, 5 + j, LEAF); p(c, 1, 7 + j, LEAF); p(c, 0, 7 + j, Hi);
  });
  PFA.glyph('B3-root', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a gnarled old root knuckle arching out of the earth; a fresh green shoot unfurls from it, a bead of golden sap */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, w = z > 1 ? 5 : 4, a, b, sh = 1 + f * 2;
    for (a = -w; a <= w; a++) { b = Math.round(3 - Math.abs(a) * 3 / w); p(c, a, b, BARK); p(c, a, b - 1, BARK); if (b > 0) p(c, a, b - 2, A); }
    p(c, -2, 2, Hi); p(c, 2, 2, Hi); p(c, -w - 1, 0, BARK); p(c, w + 1, 0, BARK); p(c, -w - 2, -1, A); p(c, w + 2, -1, A);   /* knots, rootlets */
    cl(c, 0, 4, 3 + sh, C);
    if (f >= 1) { p(c, -1, 5, C); p(c, -2, 5, LEAF); p(c, 1, 6, C); p(c, 2, 6, LEAF); }
    if (f >= 2) { p(c, -1, 8, C); p(c, -2, 9, LEAF); p(c, 1, 8, LEAF); p(c, 0, 10, Hi); }
    if (f === 3) { p(c, 1, 4, AMBER); p(c, 2, 4, AMBER); p(c, 1, 3, K.WHITE); }
  });
  PFA.glyph('B3-lattice', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* two mossy antler crowns locked together into a wall, pale bone tips, a sheen at the crossing */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, s = f === 1 ? 1 : 0, w = z > 1 ? 6 : 5;
    sg(c, -w, 0, 1 - s, 8, C); sg(c, -w + 1, 0, 2 - s, 8, C); sg(c, w, 0, -1 + s, 8, C); sg(c, w - 1, 0, -2 + s, 8, C);
    sg(c, -3, 3, -6, 6, C); sg(c, 3, 3, 6, 6, C); sg(c, -1, 6, -3, 9, C); sg(c, 1, 6, 3, 9, C);
    p(c, -7, 7, Hi); p(c, 7, 7, Hi); p(c, -4, 10, Hi); p(c, 4, 10, Hi); p(c, 1 - s, 9, Hi); p(c, -1 + s, 9, Hi);
    row(c, -w - 1, -w + 2, 0, A); row(c, w - 2, w + 1, 0, A); p(c, -w, 1, LEAF); p(c, w, 1, LEAF); p(c, -w + 1, 1, LEAF);   /* moss at the base */
    if (f === 3) { p(c, 0, 5, K.WHITE); p(c, 0, 6, K.WHITE); }
  });
  PFA.glyph('B3-whip', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a thorny bramble lash curling through the air, thorns on its back, a hooked tip */
    fr0(x, y, tx, ty, nx, ny, K); var j, a, b, ph = (fr & 3) * 1.3, n = z > 1 ? 11 : 10;
    for (j = 0; j < n; j++) { a = j - 5; b = Math.round(3 + Math.sin(j * .7 + ph) * 2.5); p(c, a, b, C); if (j < 3) p(c, a, b - 1, C);
      if (j % 3 === 1) p(c, a, b + 1, THORN); }
    b = Math.round(3 + Math.sin((n - 1) * .7 + ph) * 2.5); p(c, n - 5, b + 1, C); p(c, n - 6, b + 2, Hi);
    if ((fr & 3) === 3) { p(c, n - 3, b + 1, K.WHITE); p(c, n - 3, b + 3, K.WHITE); }      /* crack */
  });
  PFA.glyph('B3-puffball', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a pale puffball on a moss tuft: pressed, then a brown spore cloud bursts out of its top */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, r = f === 1 ? 2 : 3, a, b, i, R;
    row(c, -3, 3, 0, C); p(c, -4, 1, C); p(c, 4, 1, C);
    for (a = -r; a <= r; a++) for (b = 0; b <= 4; b++) if (a * a + (b - 2) * (b - 2) * (f === 1 ? 2 : 1) <= r * r) p(c, a, b + 1, Hi);
    p(c, -1, 3, A); p(c, 1, 2, A); p(c, 0, 5 - (f === 1 ? 1 : 0), A);
    if (f >= 2) { R = f === 2 ? 3 : 5;
      for (i = 0; i < 12; i += (f === 2 ? 2 : 1)) p(c, Math.round(CA[i] * R), Math.round(7 + CB[i] * R * .8), (i & 1) ? SPORE : A);
      p(c, 0, 7, SPORE); p(c, -1, 8, SPORE); }
  });
  PFA.glyph('B3-bush', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a leafy thicket mound with two amber eyes peering out of it, blinking; leaves rustle */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, r = z > 1 ? 6 : 5, a, b, rs = f === 3 ? 1 : 0;
    for (a = -r; a <= r; a++) for (b = 0; b <= r; b++) if (a * a + b * b * 1.6 <= r * r) p(c, a + (b > 3 ? rs : 0), b, ((a * 3 + b * 5) & 7) === 0 ? A : (((a + b) & 3) === 0 ? LEAF : C));
    if (f !== 2) { p(c, -2, 2, AMBER); p(c, 2, 2, AMBER); p(c, -2, 3, AMBER); p(c, 2, 3, AMBER); p(c, -2, 2, f === 1 ? K.WHITE : AMBER); }
    else { p(c, -2, 2, A); p(c, -1, 2, A); p(c, 2, 2, A); p(c, 3, 2, A); }                /* blink */
    if (rs) { p(c, r + 1, 3, LEAF); p(c, -r - 1, 2, LEAF); }
  });
  PFA.motion('B3-grow', function (G, pp, k) { G.fr = grow(G); G.t += Math.sin(pp * 5 + k) * .6; });
  PFA.motion('B3-flex', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; });
  PFA.motion('B3-sprout', function (G) { G.fr = grow(G); });
  PFA.motion('B3-brace', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; if (G.fr === 1) G.d -= 1; });
  PFA.motion('B3-lash', function (G, pp, k) { G.fr = (Math.floor(pp * 14) + k) & 3; G.t += Math.sin(pp * 9 + k) * 2; });
  PFA.motion('B3-squeeze', function (G) { G.fr = Math.min(3, Math.floor(G.u * 4.5)); });
  PFA.motion('B3-peek', function (G, pp, k) { G.fr = (Math.floor(pp * 9) + k) & 3; });
  function carBramble(c, e, H) {        /* a bramble runner creeps along the outer loop to the next piece: cane, alternating thorns, leaves, the antler growing at its tip */
    var P = e.P, Q = H.Q, u, i = 0, s;
    for (u = 0; u <= e.hh && i < 36; u += .03, i++) { P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, e.col);
      if (i % 3 === 0) { s = (i & 1) ? 3 : 1; H.px(c, Q.x + Q.nx * s, Q.y + Q.ny * s, THORN); }
      if (i % 6 === 4) { H.px(c, Q.x + Q.nx * 3 - Q.ny, Q.y + Q.ny * 3 + Q.nx, LEAF); H.px(c, Q.x + Q.nx * 4 - Q.ny, Q.y + Q.ny * 4 + Q.nx, LEAF); } }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'B3-antler', Q.x + Q.nx * 2, Q.y + Q.ny * 2, e.z > 1 ? 1 : e.z, e.hh > .9 ? 3 : e.hh > .5 ? 2 : 1, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }

  /* ================= dune wyrm (colossal ringed sand wyrm with a round toothed maw) ================= */
  PFA.glyph('B3-wyrm', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* the wyrm breaching: sand mound bulges, the ringed head bursts out, the round maw opens on white teeth, it sinks in a sand spray */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, w = z > 1 ? 3 : 2, a, b, H = f === 3 ? 3 : 6 + (z > 1 ? 1 : 0);
    for (a = -6; a <= 6; a++) { b = Math.round(2 - Math.abs(a) / 3); if (b >= 0) { p(c, a, b, SANDL); if (b > 0) p(c, a, b - 1, Hi); } }   /* the sand mound */
    if (f === 0) { p(c, -1, 3, SANDL); p(c, 0, 3, SANDL); p(c, 1, 3, SANDL); p(c, -3, 3, Hi); p(c, 3, 4, Hi); return; }
    for (b = 1; b <= H; b++) { row(c, -w, w, b, (b & 1) ? C : A); p(c, -w, b, A); p(c, w, b, A); }      /* ringed body: banded segments */
    if (f === 1) { row(c, -w + 1, w - 1, H + 1, C); p(c, -w - 2, H - 1, SANDL); p(c, w + 2, H, SANDL); p(c, -w - 1, H + 1, SANDL); return; }
    if (f === 2) { row(c, -w - 1, w + 1, H + 1, C); row(c, -w, w, H + 2, MAW); p(c, -w - 1, H + 2, C); p(c, w + 1, H + 2, C);   /* the round maw seen from the side */
      for (a = -w; a <= w; a += 2) p(c, a, H + 2, K.WHITE); row(c, -w, w, H + 3, C); p(c, -w - 3, H, SANDL); p(c, w + 3, H + 1, SANDL); p(c, -w - 2, H + 3, SANDL); return; }
    row(c, -w + 1, w - 1, H + 1, C);                                                                    /* sinking: sand spray thrown off */
    for (a = -5; a <= 5; a += 2) p(c, a, H + 2 + ((a + 5) % 3), SANDL);
  });
  PFA.glyph('B3-funnel', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a sinkhole: sand rings slide in toward a dark centre, then the round maw snaps up out of it */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, i, R, rr, sh = (f & 1) ? .6 : 0;
    for (rr = 0; rr < 2; rr++) { R = (rr ? 3 : 6) - sh + (z > 1 ? 1 : 0);
      for (i = 0; i < 12; i++) p(c, Math.round(CA[i] * R), Math.round(4 + CB[i] * R * .6), rr ? C : ((i + f) & 1 ? Hi : SANDL)); }
    p(c, 0, 4, A); p(c, -1, 4, A); p(c, 1, 4, A); p(c, 0, 5, A); p(c, 0, 3, A);
    if (f === 3) { p(c, -1, 5, MAW); p(c, 1, 5, MAW); p(c, -2, 5, K.WHITE); p(c, 2, 5, K.WHITE); p(c, 0, 6, K.WHITE); p(c, 0, 7, C); }
  });
  PFA.glyph('B3-geyser', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a sand spout: a jet of sand shoots up, crowns into spray and rains back down */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, h = JET[f] + (z > 1 && f === 2 ? 1 : 0), b;
    row(c, -2, 2, 0, A); row(c, -3, 3, 0 + (f === 0 ? 1 : 0), f === 0 ? SANDL : A);
    for (b = 1; b <= h; b++) { p(c, 0, b, C); if (b < h - 1) { p(c, (b & 1) ? -1 : 1, b, SANDL); } }
    if (f === 2) { p(c, -1, h + 1, C); p(c, 1, h + 1, C); p(c, -3, h, Hi); p(c, 3, h, Hi); p(c, -4, h - 2, SANDL); p(c, 4, h - 2, SANDL); p(c, 0, h + 2, K.WHITE); }
    if (f === 3) { p(c, -3, 6, Hi); p(c, 3, 5, Hi); p(c, -4, 4, SANDL); p(c, 4, 3, SANDL); p(c, -5, 2, C); p(c, 5, 2, C); }
  });
  PFA.glyph('B3-ringmaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* the wyrm's mouth face-on: a ringed rim, rows of white teeth pointing in, the red throat irising shut, a snap */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, R = 4 + (z > 1 ? 1 : 0), i, a, b, o = IRIS[f];
    for (i = 0; i < 12; i++) { p(c, Math.round(CA[i] * R), Math.round(5 + CB[i] * R), (i & 1) ? C : A); p(c, Math.round(CA[i] * (R + 1)), Math.round(5 + CB[i] * (R + 1)), (i % 3) ? C : Hi); }
    for (a = -2; a <= 2; a++) for (b = -2; b <= 2; b++) if (a * a + b * b <= 5) p(c, a, 5 + b, a * a + b * b <= o * o ? MAW : A);
    for (i = 0; i < 12; i += 2) p(c, Math.round(CA[i] * (R - 1.5)), Math.round(5 + CB[i] * (R - 1.5)), K.WHITE);
    if (f === 3) { p(c, -R - 3, 5, K.WHITE); p(c, R + 3, 5, K.WHITE); p(c, 0, R + 8, K.WHITE); }
  });
  PFA.glyph('B3-tail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* the ringed tail whipping round, tapering to a pale bone spike that cracks */
    fr0(x, y, tx, ty, nx, ny, K); var j, a, b, ph = (fr & 3) * 1.1, n = z > 1 ? 11 : 10;
    for (j = 0; j < n; j++) { a = j - 5; b = Math.round(2 + Math.sin(j * .55 + ph) * 2 + j * .3); p(c, a, b, (j & 1) ? C : A); if (j < 6) p(c, a, b + 1, C); if (j < 3) p(c, a, b - 1, C); }
    b = Math.round(2 + Math.sin((n - 1) * .55 + ph) * 2 + (n - 1) * .3); p(c, n - 5, b + 1, Hi); p(c, n - 4, b + 1, K.WHITE); p(c, n - 4, b + 2, Hi);
    if ((fr & 3) === 2) { p(c, n - 2, b + 1, K.WHITE); p(c, n - 3, b + 3, K.WHITE); p(c, n - 3, b - 1, K.WHITE); }
  });
  PFA.glyph('B3-plate', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* overlapping ring plates of the wyrm's hide, dark seams, a sand-white sheen walking over them */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, k, a, b, a0, w = z > 1 ? 1 : 0;
    for (k = -1; k <= 1; k++) { a0 = k * 4;
      for (a = a0 - 2 - w; a <= a0 + 2 + w; a++) { b = Math.abs(a - a0) > 1 + w ? 2 : 3; cl(c, a, 0, b, C); p(c, a, b + 1, a === a0 - 2 - w ? A : Hi); }
      cl(c, a0 + 2 + w, 0, 2, A); }
    p(c, (f - 1) * 4, 3, K.WHITE); p(c, (f - 1) * 4 + 1, 2, K.WHITE);
  });
  PFA.motion('B3-erupt', function (G, pp, k, ph) { var u = (pp * 1.5 + ph) % 1; G.fr = Math.floor(u * 4); if (G.fr === 0) G.d -= 1; });
  PFA.motion('B3-swirl', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; });
  PFA.motion('B3-jet', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 1.8 + ph) % 1) * 4); });
  PFA.motion('B3-snap', function (G, pp, k, ph) { var u = (pp * 1.8 + ph) % 1; G.fr = Math.floor(u * 4); if (G.fr === 3) G.d += 2; });
  PFA.motion('B3-whip', function (G, pp, k) { G.fr = (Math.floor(pp * 12) + k) & 3; G.t += Math.sin(pp * 9 + k) * 2; });
  PFA.motion('B3-shimmer', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; });
  function carWyrm(c, e, H) {           /* a sand ridge races under the outer loop to the next piece, spray flicking off its crest; the wyrm breaches at the end */
    var P = e.P, Q = H.Q, u, i = 0, b, s, u0 = Math.max(0, e.hh - .35);
    for (u = u0; u <= e.hh && i < 16; u += .025, i++) { P.atq(e.a + e.d * u); s = (u - u0) / Math.max(.01, e.hh - u0); b = 1 + Math.round(Math.sin(s * Math.PI * .5) * 3);
      H.px(c, Q.x + Q.nx * b, Q.y + Q.ny * b, SANDL); H.px(c, Q.x + Q.nx * (b - 1), Q.y + Q.ny * (b - 1), e.col);
      if ((i + Math.floor(e.p * 20)) % 4 === 0) H.px(c, Q.x + Q.nx * (b + 2) + Q.ny, Q.y + Q.ny * (b + 2) - Q.nx, e.hi); }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'B3-wyrm', Q.x + Q.nx, Q.y + Q.ny, e.z > 1 ? 1 : e.z, e.hh > .93 ? 2 : e.hh > .8 ? 1 : 0, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }

  /* ================= jade jaguar spirit (a jaguar of living jade, gold rosettes, a ghost of the canopy) ================= */
  PFA.glyph('B3-jag', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the jade jaguar side-on, running along the edge: crouch, stretched leap, tucked flight, landing; frames 4-7 = spirit outline only */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, gh = fr > 3, lf = f === 1 ? 2 : f === 2 ? 3 : 0, a, b, top, col, bc = gh ? JADEL : C;
    for (a = -5; a <= 4; a++) { top = 4 + lf - (a < -3 || a > 2 ? 1 : 0) - (f === 0 ? 1 : 0);
      for (b = 2 + lf; b <= top; b++) { if (gh && b !== top && b !== 2 + lf && a !== -5 && a !== 4) continue; if (gh && ((a + b) & 1)) continue; p(c, a, b, bc); } }
    for (a = 5; a <= 7; a++) for (b = 3 + lf; b <= 5 + lf; b++) if (!gh || b !== 4 + lf || a === 7) p(c, a, b, bc);                    /* head */
    p(c, 5, 6 + lf, bc); p(c, 7, 6 + lf, bc); p(c, 7, 4 + lf, gh ? K.WHITE : GOLD);                                                    /* ears, glowing eye */
    sg(c, -6, 4 + lf, -8, 7 + lf - (f & 1), bc); p(c, -9, 7 + lf - (f & 1), gh ? JADEL : A);                                            /* tail */
    if (!gh) { p(c, -3, 4 + lf, Hi); p(c, -1, 3 + lf, Hi); p(c, 1, 4 + lf, Hi); p(c, 3, 3 + lf, Hi); p(c, -2, 3 + lf, A); p(c, 2, 4 + lf, A); }   /* gold rosettes */
    if (f === 0) { p(c, -4, 1, bc); p(c, -3, 1, bc); p(c, 3, 1, bc); p(c, 4, 1, bc); }                                                 /* crouched paws */
    else if (f === 1) { sg(c, 4, 2 + lf, 7, 1 + lf, bc); sg(c, -4, 2 + lf, -7, 0 + lf, bc); }                                         /* stretched legs */
    else if (f === 2) { p(c, 2, 1 + lf, bc); p(c, -2, 1 + lf, bc); }                                                                   /* tucked */
    else { sg(c, 4, 2, 6, 0, bc); sg(c, -3, 2, -4, 0, bc); if (!gh) { p(c, 7, 0, GOLD); p(c, 5, -1, GOLD); } }                         /* landing, gold paw sparks */
  });
  PFA.glyph('B3-gaze', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* two floating almond jaguar eyes, gold irises with black slits, jade glow rings pulsing out of them */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, s, e, R = 2 + f;
    for (s = -1; s <= 1; s += 2) { e = s * 4;
      if (f === 2) { row(c, e - 2, e + 2, 4, C); continue; }                                                                             /* blink */
      row(c, e - 1, e + 1, 6, C); row(c, e - 1, e + 1, 2, C); p(c, e - 2, 5, C); p(c, e + 2, 5, C); p(c, e - 2, 3, C); p(c, e + 2, 3, C); p(c, e - 3, 4, C); p(c, e + 3, 4, C);
      row(c, e - 1, e + 1, 3, Hi); row(c, e - 2, e + 2, 4, Hi); row(c, e - 1, e + 1, 5, Hi); cl(c, e, 3, 5, INK); }
    if (z > 1 || f === 3) for (s = 0; s < 12; s += 2) p(c, Math.round(CA[s] * (R + 5)), Math.round(4 + CB[s] * (R + 2)), JADEL);
    else for (s = 1; s < 12; s += 3) p(c, Math.round(CA[s] * (R + 5)), Math.round(4 + CB[s] * (R + 2)), JADEL);
  });
  PFA.glyph('B3-mask', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a carved jade jaguar mask front-on: round ears, step-fret carving, a gold rosette on the brow, slit eyes glowing, white fangs */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, w = z > 1 ? 5 : 4, a, b;
    for (b = 1; b <= 8; b++) row(c, -w + (b === 1 || b === 8 ? 1 : 0), w - (b === 1 || b === 8 ? 1 : 0), b, C);
    p(c, -w, 9, C); p(c, -w + 1, 9, C); p(c, w, 9, C); p(c, w - 1, 9, C); p(c, -w + 1, 10, C); p(c, w - 1, 10, C);                    /* ears */
    row(c, -w + 1, -1, 4, A); p(c, -1, 3, A); row(c, 1, w - 1, 4, A); p(c, 1, 3, A);                                                    /* step-fret carving */
    p(c, -2, 6, f === 3 ? K.WHITE : INK); p(c, -3, 6, Hi); p(c, 2, 6, f === 3 ? K.WHITE : INK); p(c, 3, 6, Hi);                        /* slit eyes */
    p(c, 0, 8, Hi); p(c, -1, 7, Hi); p(c, 1, 7, Hi); p(c, 0, 7, A);                                                                     /* gold brow rosette */
    p(c, -1, 1, K.WHITE); p(c, 1, 1, K.WHITE); p(c, -1, 2, K.WHITE); p(c, 1, 2, K.WHITE);                                               /* fangs */
    p(c, -w + 1 + f * 2, 8, JADEL); p(c, -w + 2 + f * 2, 7, JADEL);                                                                     /* a glint walking over the stone */
  });
  PFA.glyph('B3-canopy', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* drawn in screen axes: the jade jaguar drops head-first out of the canopy, forepaws spread, claws out, leaves fluttering round it */
    var f = fr & 3, s = f & 1, i;
    K.bx(c, x - 1, y - 6, 3, 6, C); K.bx(c, x - 2, y, 5, 3, C); K.px(c, x - 2, y + 3, C); K.px(c, x + 2, y + 3, C);                   /* body, head, ears down */
    K.px(c, x - 1, y + 1, GOLD); K.px(c, x + 1, y + 1, GOLD); K.px(c, x, y - 3, Hi); K.px(c, x - 1, y - 5, Hi); K.px(c, x + 1, y - 2, Hi);
    K.px(c, x - 3 - s, y - 1, C); K.px(c, x - 4 - s, y, C); K.px(c, x + 3 + s, y - 1, C); K.px(c, x + 4 + s, y, C);                    /* forepaws spread */
    K.px(c, x - 4 - s, y + 1, K.WHITE); K.px(c, x + 4 + s, y + 1, K.WHITE);                                                             /* claws */
    for (i = 7; i <= 9 - s; i++) K.px(c, x + (i & 1), y - i, C); K.px(c, x + 1, y - 10 + s, A);                                       /* tail up */
    K.px(c, x - 5 + f, y - 6, LEAF); K.px(c, x - 4 + f, y - 7, LEAF); K.px(c, x + 5 - f, y - 3 + s, LEAF); K.px(c, x + 6 - f, y - 4 + s, LEAF);
  });
  PFA.glyph('B3-rake', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* four parallel claw gouges tearing out diagonally, gold at the leading tips, jade sparks */
    fr0(x, y, tx, ty, nx, ny, K); var f = fr & 3, L = RAKE[f] + (z > 1 ? 1 : 0), i, a0;
    for (i = 0; i < 4; i++) { a0 = -4 + i * 2; sg(c, a0, 1, a0 + Math.round(L * .5), 1 + L, f === 3 ? JADEL : C); p(c, a0 + Math.round(L * .5), 2 + L, f === 3 ? K.WHITE : Hi); }
    if (f === 3) { p(c, -5, L, Hi); p(c, 6, L - 1, Hi); p(c, 2, L + 4, JADEL); }
  });
  PFA.motion('B3-bound', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = Math.floor(u * 4); if (G.fr === 1 || G.fr === 2) G.up += Math.sin((u - .25) * 2 * Math.PI) * 3 + 2; });
  PFA.motion('B3-phase', function (G, pp, k, ph) { G.fr = ((Math.floor(pp * 5 + ph * 2) & 1) ? 4 : 0) + ((Math.floor(pp * 10) + k) & 3); G.t += Math.sin(pp * 4 + k) * 2; });
  PFA.motion('B3-stare', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; });
  PFA.motion('B3-poise', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; G.up += Math.sin(pp * 6 + k) * .8; });
  PFA.motion('B3-drop', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; G.t += Math.sin(pp * 7 + k); });
  PFA.motion('B3-claw', function (G) { G.fr = grow(G); });
  function carSpirit(c, e, H) {         /* the jade spirit jaguar bounds along the outer loop to the next piece: two fading outline afterimages behind it, gold pips where it lands */
    var P = e.P, Q = H.Q, k, u, h, ph, fr, sd = e.d < 0 ? -1 : 1, zz = e.z > 1 ? 1 : e.z;
    for (k = 1; k <= 3; k++) { u = k / 3; if (e.hh < u) break; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 2 - Q.ny * 2, Q.y + Q.ny * 2 + Q.nx * 2, GOLD); H.px(c, Q.x + Q.nx * 2 + Q.ny * 2, Q.y + Q.ny * 2 - Q.nx * 2, GOLD); }
    for (k = 2; k >= 0; k--) { u = e.hh - k * .12; if (u < 0) continue; ph = (u * 3) % 1; h = 2 + Math.sin(ph * Math.PI) * 7;
      fr = ph < .2 ? 0 : ph < .45 ? 1 : ph < .8 ? 2 : 3; if (k) fr += 4; if (k === 2 && (Math.floor(e.p * 20) & 1)) continue;
      P.atq(e.a + e.d * u);
      H.glyph(c, 'B3-jag', Q.x + Q.nx * h, Q.y + Q.ny * h, zz, fr, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny); }
  }

  /* ================= motifs ================= */
  function M(name, meta) { PFA.motif(name, comp, meta); }
  /* old bramblehorn */
  M('bramble-antler', { nm: 'bramble antlers', desc: 'an antler grown of bramble cane rising out of the edge: a thorny stem with hooked red thorns, tines tipped in pale bone, a leaf and a blackberry, the tips flashing white as it gores; the chain is a bramble runner creeping along the outer loop with the antler growing at its tip', fam: 'thrust', gap: 18, g: 'B3-antler', mo: 'B3-grow', x: '-', car: 'custom', carDraw: carBramble });
  M('berry-cane', { nm: 'berry canes', desc: 'arched bramble canes with hooked red thorns along the top and ripe blackberries hanging beneath, flexing, a glint on the berries', fam: 'thorn', gap: 14, g: 'B3-cane', mo: 'B3-flex', x: '-', car: 'train' });
  M('root-sprout', { nm: 'root sprouts', desc: 'a gnarled old root knuckle arching out of the earth; a fresh green shoot unfurls from it in three steps and a bead of golden sap wells up', fam: 'mend', gap: 16, g: 'B3-root', mo: 'B3-sprout', x: '-', car: 'train' });
  M('antler-lattice', { nm: 'antler lattice', desc: 'two mossy antler crowns locked tine through tine into a wall, pale bone tips, moss at the base, a sheen flashing at the crossing', fam: 'shield', gap: 16, g: 'B3-lattice', mo: 'B3-brace', x: '-', car: 'train' });
  M('bramble-whip', { nm: 'bramble lash', desc: 'a thorny bramble lash curling through the air in S-bends, red thorns on its back, a hooked tip cracking', fam: 'slash', gap: 14, g: 'B3-whip', mo: 'B3-lash', x: '-', car: 'comet' });
  M('puffball-spore', { nm: 'puffballs', desc: 'a pale puffball on a moss tuft is squeezed flat and bursts a ring of brown spore dust out of its top', fam: 'puff', gap: 14, g: 'B3-puffball', mo: 'B3-squeeze', x: '-', car: 'cloud' });
  M('thicket-eyes', { nm: 'eyes in the thicket', desc: 'a leafy thicket mound with two amber eyes peering out of it, blinking, the leaves rustling', fam: 'leaf', gap: 16, g: 'B3-bush', mo: 'B3-peek', x: '-', car: 'blink' });
  /* dune wyrm */
  M('wyrm-erupt', { nm: 'erupting wyrm', desc: 'a sand mound bulges, the ringed banded head of the wyrm bursts out of it, its round maw opens on a ring of white teeth, then it sinks in a spray of sand; the chain is a sand ridge racing under the outer loop and the wyrm breaching at the next piece', fam: 'bash', gap: 18, g: 'B3-wyrm', mo: 'B3-erupt', x: '-', car: 'custom', carDraw: carWyrm });
  M('sand-funnel', { nm: 'sinkholes', desc: 'a sinkhole: sand rings slide inward toward a dark centre, then the round red maw snaps up out of the bottom on white teeth', fam: 'bite', gap: 16, g: 'B3-funnel', mo: 'B3-swirl', x: '-', car: 'rings' });
  M('sand-geyser', { nm: 'sand spouts', desc: 'a jet of sand shoots up out of a dark vent, crowns into spray at the top and rains back down at the sides', fam: 'puff', gap: 12, g: 'B3-geyser', mo: 'B3-jet', x: '-', car: 'hop' });
  M('ring-maw', { nm: 'ring maws', desc: 'the wyrm mouth seen face-on: a ringed rim, a ring of white teeth pointing inward, the red throat irising shut, then a snap', fam: 'bite', gap: 16, g: 'B3-ringmaw', mo: 'B3-snap', x: '-', car: 'comet' });
  M('spike-tail', { nm: 'spike tails', desc: 'a banded ringed tail whipping round in a curve and tapering to a pale bone spike that cracks the air', fam: 'slash', gap: 14, g: 'B3-tail', mo: 'B3-whip', x: '-', car: 'comet' });
  M('ring-plate', { nm: 'ring plates', desc: 'three overlapping armour rings of the wyrm hide with dark seams, a sand-white sheen walking across them', fam: 'shield', gap: 14, g: 'B3-plate', mo: 'B3-shimmer', x: '-', car: 'train' });
  /* jade jaguar spirit */
  M('spirit-leap', { nm: 'jade spirit jaguar', desc: 'a jaguar of translucent jade with gold rosettes and a glowing eye running and leaping along the edge: crouch, stretched leap, tucked flight, landing with gold paw sparks; the chain is the spirit jaguar bounding along the outer loop with two fading outline afterimages behind it', fam: 'thrust', gap: 20, g: 'B3-jag', mo: 'B3-bound', x: '-', car: 'custom', carDraw: carSpirit });
  M('spirit-fade', { nm: 'fading spirit', desc: 'the jade jaguar flickering between solid jade and a pale dotted spirit outline as it drifts, never quite there', fam: 'puff', gap: 20, g: 'B3-jag', mo: 'B3-phase', x: '-', car: 'blink' });
  M('spirit-gaze', { nm: 'spirit gaze', desc: 'two floating almond jaguar eyes with gold irises and black slits staring, pale jade glow rings pulsing out round them, a slow blink', fam: 'web', gap: 18, g: 'B3-gaze', mo: 'B3-stare', x: '-', car: 'blink' });
  M('jade-mask', { nm: 'jade masks', desc: 'a carved jade jaguar mask front-on: round ears, step-fret carving, a gold rosette on the brow, white fangs, slit eyes that flash white, a glint walking over the stone', fam: 'shield', gap: 16, g: 'B3-mask', mo: 'B3-poise', x: '-', car: 'train' });
  M('canopy-drop', { nm: 'canopy drop', desc: 'the jade jaguar dropping head-first out of the canopy, forepaws spread with white claws out, tail up, leaves fluttering round it', fam: 'thrust', gap: 18, g: 'B3-canopy', mo: 'B3-drop', x: '-', car: 'comet' });
  M('jade-rake', { nm: 'jade rakes', desc: 'four parallel claw gouges tearing out of the edge diagonally, gold at the leading tips, flaring pale jade with sparks', fam: 'slash', gap: 14, g: 'B3-rake', mo: 'B3-claw', x: '-', car: 'comet' });
})();
