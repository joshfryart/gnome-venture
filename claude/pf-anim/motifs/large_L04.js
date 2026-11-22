/* Motif module, large batch L04 (desert-camel, wild-bactrian, wild-boar, cliff-ram, thunder-yak, ibex-patriarch, musk-ox, wood-bison, prairie-bison, caribou-bull).
   TEMPLATE.md sections 9 and 10.3. 28 motifs, each with its own pixel glyph (ids prefixed L04-) and motion; four have their own chain effect (carDraw).
   Glyph coordinates are written as (a, b): a along the edge tangent, b outward along the normal, so every sprite turns with the edge it sits on.
   A glyph first stores its frame (origin, tangent, normal, helpers) in module scratch variables with fr0(); p()/s() then plot in (a, b). Glyph draws
   never nest, so the scratch is safe; nothing is allocated per frame, there is no Math.random / Date, every effect is a stateless function of p.
   Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy
   default are untouched (they live in the page). Large beasts are drawn a little bigger than small ones (up to ~12 px) but stay within ~22 px of the edge. */
(function () {
  var X0 = 0, Y0 = 0, TX = 1, TY = 0, NX = 0, NY = -1, KK = null;
  var VRED = '#c4423a', HORNP = '#efe4c8', SNOW = '#f4f8ff';          /* raw antler under shed velvet, pale horn, snow */
  var HUMP = [1, 2, 3, 4, 4, 4, 3, 2, 1];                              /* dromedary hump heights, a = -4..4 */
  var SHUMP = [2, 3, 4, 5, 6, 6, 5, 4, 3, 2];                          /* wood bison hump heights, a = -5..4 (high at the shoulder) */
  var RUNB = [2, 2, 3, 3, 4, 5, 5, 4, 3];                              /* running bison back line, a = -4..4, head end high */
  var WOOL = [3, 5, 4, 6, 4, 5, 3];                                    /* moulting wool lock lengths, a = -3..3 */
  var SPA = [], SPB = [], i0, t0;                                      /* ram horn spiral, 13 points, built once */
  for (i0 = 0; i0 < 13; i0++) { t0 = i0 / 12; SPA.push(Math.cos(t0 * 7) * (.8 + t0 * 2.4)); SPB.push(Math.sin(t0 * 7) * (.8 + t0 * 2.4)); }

  function fr0(x, y, tx, ty, nx, ny, K) { X0 = x; Y0 = y; TX = tx; TY = ty; NX = nx; NY = ny; KK = K; }
  function p(c, a, b, col) { KK.px(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, col); }
  function s(c, a, b, w, col) { KK.sq(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, w, col); }
  function row(c, a0, a1, b, col) { for (var a = a0; a <= a1; a++) p(c, a, b, col); }
  function cl(c, a, b0, b1, col) { for (var b = b0; b <= b1; b++) p(c, a, b, col); }

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

  /* ================= glyphs (fr 0..3, z 0..2) ================= */
  /* --- camels --- */
  PFA.glyph('L04-spit', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a glob of cud spit: flying with a tail, stretched, splatted flat, hanging on strings */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0;
    if (fr === 0) { s(c, 0, 2, 3 + w, C); p(c, -1, 3, Hi); p(c, 1, 1, A); p(c, 0, 0, C); p(c, 0, -2, Hi); }
    else if (fr === 1) { cl(c, 0, -1, 4, C); cl(c, 1, 1, 3, C); p(c, -1, 2, C); p(c, 0, 4, Hi); p(c, -2, 3, Hi); p(c, 2, 4, Hi); p(c, 1, 2, A); }
    else if (fr === 2) { row(c, -3 - w, 3 + w, 0, C); row(c, -2, 2, 1, C); p(c, 0, 1, A); p(c, -4 - w, 1, Hi); p(c, 4 + w, 1, Hi); p(c, -3, 2, Hi); p(c, 3, 2, Hi); p(c, 0, 2, K.WHITE); }
    else { s(c, 0, 3, 3 + w, C); p(c, -1, 4, Hi); cl(c, -1, 0, 1, Hi); cl(c, 1, -1, 1, Hi); p(c, 1, -2, C); }
  });
  PFA.glyph('L04-hump', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a dromedary hump filling up: a water bead rises inside it and pops out of the top */
    fr0(x, y, tx, ty, nx, ny, K); var a, h, w = z > 1 ? 1 : 0;
    for (a = -4; a <= 4; a++) { h = HUMP[a + 4] + w; cl(c, a, 0, h - 1, C); p(c, a, h, a < -1 || a > 1 ? A : Hi); }
    if (w) { p(c, -5, 0, C); p(c, 5, 0, C); }
    if (fr < 3) { s(c, 0, 1 + fr, 2, K.DEW); p(c, 0, 1 + fr, K.WHITE); }
    else { p(c, 0, 6 + w, K.DEW); p(c, 0, 7 + w, K.DEW); p(c, -1, 7 + w, K.DEW); p(c, 1, 7 + w, K.DEW); p(c, 0, 8 + w, K.WHITE); p(c, -2, 8 + w, K.WHITE); p(c, 2, 8 + w, K.WHITE); }
  });
  PFA.glyph('L04-kick', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a long camel leg: folded, half out, kicked straight, splayed two-toed foot with a dust flare */
    fr0(x, y, tx, ty, nx, ny, K); var L = [3, 5, 7, 7][fr] + (z > 1 ? 1 : 0), bend = [2.5, 1.2, 0, 0][fr], b, a;
    for (b = 0; b <= L; b++) { a = bend * Math.sin(b / L * Math.PI); p(c, a, b, C); if (b < 3) p(c, a + 1, b, C); }
    p(c, bend * Math.sin(Math.PI * .5), Math.round(L / 2), Hi);
    row(c, -2, -1, L + 1, C); row(c, 1, 2, L + 1, C); p(c, 0, L + 1, A); p(c, -2, L + 2, A); p(c, 2, L + 2, A);
    if (fr === 3) { p(c, -4, L + 2, Hi); p(c, 4, L + 2, Hi); p(c, -3, L + 3, Hi); p(c, 3, L + 3, Hi); p(c, 0, L + 3, K.WHITE); }
  });
  PFA.glyph('L04-eye', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a heavy-lidded camel eye with long lashes: half shut, lower, a slow blink, a glint */
    fr0(x, y, tx, ty, nx, ny, K); var lid = [4, 3, 2, 4][fr], b, a;
    for (b = lid; b <= 5; b++) row(c, b === 5 ? -2 : -3, b === 5 ? 2 : 3, b, C);
    for (b = 2; b < lid; b++) { row(c, -2, 2, b, Hi); p(c, 0, b, A); p(c, 1, b, A); }
    row(c, -2, 2, 1, C); p(c, -4, 3, A); p(c, 4, 3, A);
    if (lid === 2) row(c, -3, 3, 2, A);
    for (a = -3; a <= 3; a += 2) p(c, a, 6 + (a === -3 || a === 3 ? 0 : 1), A);
    if (z > 1) { p(c, -4, 4, C); p(c, 4, 4, C); }
    if (fr === 3) p(c, -1, 3, K.WHITE);
  });
  PFA.glyph('L04-bactrian', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* two-humped camel side-on: rocking gait (bit 0), humps swelling (bit 1), wool tufts on top */
    fr0(x, y, tx, ty, nx, ny, K); var g = fr & 1, sw = fr >> 1, a;
    row(c, -4, 3, 3, C); row(c, -4, 3, 4, C);
    for (a = -3; a <= -1; a++) cl(c, a, 5, a === -2 ? 6 + sw : 5 + sw, C);
    for (a = 1; a <= 3; a++) cl(c, a, 5, a === 2 ? 6 + sw : 5 + sw, C);
    p(c, -2, 7 + sw, Hi); p(c, 2, 7 + sw, Hi); p(c, -3, 6 + sw, Hi); p(c, 3, 6 + sw, Hi);
    p(c, 4, 4, C); p(c, 5, 5, C); p(c, 5, 6, C); row(c, 6, 7, 6, C); p(c, 6, 7, A); p(c, 7, 5, A); p(c, 4, 3, Hi); p(c, 5, 4, Hi);
    p(c, -5, 4, A); p(c, -6, 3, A);
    if (g) { cl(c, -4, 0, 2, C); cl(c, -2, 0, 2, C); cl(c, 1, 0, 2, C); cl(c, 3, 0, 2, C); }
    else { p(c, -3, 2, C); p(c, -4, 1, C); p(c, -5, 0, A); p(c, -3, 1, C); p(c, -2, 0, A); p(c, 2, 2, C); p(c, 1, 1, C); p(c, 0, 0, A); p(c, 3, 1, C); p(c, 4, 0, A); }
    if (z > 1) row(c, -3, 2, 2, C);
  });
  PFA.glyph('L04-moult', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a shaggy clump of moulting camel wool, a loose tuft peeling away and drifting off */
    fr0(x, y, tx, ty, nx, ny, K); var a, L;
    row(c, -3, 3, 0, A);
    for (a = -3; a <= 3; a++) { L = WOOL[a + 3] + (z > 1 ? 1 : 0); cl(c, a, 1, L - 1, C); p(c, a, L, (a + fr) & 1 ? Hi : C); }
    if (fr < 3) { s(c, 3 + fr, 5 + fr * 2, 2, Hi); p(c, 2 + fr, 4 + fr * 2, C); } else { p(c, 6, 11, Hi); p(c, 7, 12, Hi); }
  });
  /* --- boar --- */
  PFA.glyph('L04-tusk', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* boar head, snout out: bristle crest, pricked ears, two ivory tusks that hook up as it gores */
    fr0(x, y, tx, ty, nx, ny, K); var b, t = fr === 1 || fr === 2 ? 1 : 0, w = z > 1 ? 1 : 0;
    for (b = 0; b <= 3; b++) row(c, -3 - (b < 2 ? w : 0), 3 + (b < 2 ? w : 0), b, C);
    row(c, -2, 2, 4, C); row(c, -1, 1, 5, C); row(c, -1, 1, 6, Hi); p(c, -1, 6, A); p(c, 1, 6, A);
    p(c, -2, 2, A); p(c, 2, 2, A);
    p(c, -3, -1, C); p(c, -4, -2, A); p(c, 3, -1, C); p(c, 4, -2, A);
    p(c, -1, -1, A); p(c, 0, -2, A); p(c, 1, -1, A); p(c, 0, -1, A);
    p(c, -2, 4, K.WHITE); p(c, -3, 5, K.WHITE); p(c, -3, 6 + t, HORNP); p(c, 2, 4, K.WHITE); p(c, 3, 5, K.WHITE); p(c, 3, 6 + t, HORNP);
    if (t) { p(c, -2, 7 + t, K.WHITE); p(c, 2, 7 + t, K.WHITE); }
    if (fr === 3) { p(c, -5, 8, Hi); p(c, 5, 8, Hi); p(c, -4, 9, A); p(c, 4, 9, A); }
  });
  PFA.glyph('L04-wallow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a mud wallow: a dark pool with a gloss, bubbles swelling and popping, a boar's back and ears breaking the surface */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0;
    row(c, -5 - w, 5 + w, 0, A); row(c, -4 - w, 4 + w, 1, C); p(c, -2, 1, Hi); p(c, -1, 1, Hi);
    if (fr === 0) { p(c, 2, 2, Hi); }
    else if (fr === 1) { p(c, 2, 2, Hi); p(c, 1, 3, Hi); p(c, 3, 3, Hi); p(c, 2, 4, Hi); }
    else if (fr === 2) { row(c, -3, 1, 2, C); p(c, -2, 3, A); p(c, 0, 3, A); p(c, -3, 2, A); p(c, 1, 2, A); }
    else { p(c, 1, 4, Hi); p(c, 3, 4, Hi); p(c, 2, 5, K.WHITE); p(c, -5, 2, A); p(c, 5, 3, A); }
  });
  PFA.glyph('L04-snout', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* rooting: a pig snout shoves up out of a turf mound and drags a curling root up after it */
    fr0(x, y, tx, ty, nx, ny, K); var up = fr === 0 ? 0 : 1 + (fr > 1 ? 1 : 0);
    row(c, -4, 4, 0, A); row(c, -3, 3, 1, A); p(c, -3, 1, Hi); p(c, 2, 1, Hi);
    if (up > 0) cl(c, -1, 2, 1 + up, C), cl(c, 1, 2, 1 + up, C), cl(c, 0, 2, 1 + up, C);
    row(c, -1, 1, 2 + up, C); p(c, -1, 2 + up, A); p(c, 1, 2 + up, A); p(c, 0, 3 + up, Hi);
    if (fr >= 2) { p(c, 2, 2, Hi); p(c, 3, 3, Hi); p(c, 4, 4, Hi); p(c, 3, 5, Hi); p(c, 5, 4, Hi); }
    if (fr === 3) { s(c, -4, 6, 2, A); p(c, -3, 7, Hi); }
  });
  /* --- ram, ibex --- */
  PFA.glyph('L04-ramhorn', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* ram head-on: narrow face, two thick curled horns, a clash star and cracks when it butts */
    fr0(x, y, tx, ty, nx, ny, K); var i, sc = z > 1 ? 1.25 : 1, b;
    for (b = 1; b <= 5; b++) row(c, -1, 1, b, C);
    p(c, 0, 6, Hi); p(c, -1, 3, A); p(c, 1, 3, A); p(c, 0, 0, Hi);
    for (i = 0; i < 13; i++) { p(c, -3 - SPA[i] * sc, 3 + SPB[i] * sc, i % 4 === 3 ? A : HORNP); p(c, 3 + SPA[i] * sc, 3 + SPB[i] * sc, i % 4 === 3 ? A : HORNP); }
    s(c, -3, 3, 2, Hi); s(c, 3, 3, 2, Hi);
    if (fr === 1) { p(c, -2, -1, A); p(c, -2, -2, A); p(c, 2, -1, A); p(c, 2, -2, A); }
    if (fr === 2) { p(c, 0, 8, K.WHITE); p(c, -1, 9, K.WHITE); p(c, 1, 9, K.WHITE); p(c, -2, 8, K.WHITE); p(c, 2, 8, K.WHITE); p(c, -3, 9, Hi); p(c, -4, 10, Hi); p(c, 3, 9, Hi); p(c, 4, 10, Hi); p(c, 0, 10, Hi); }
  });
  PFA.glyph('L04-ledgehoof', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a rock ledge with a cloven hoof gripping its lip; chips break off and fall */
    fr0(x, y, tx, ty, nx, ny, K); var sp = fr === 1 ? 1 : 0;
    row(c, -5, 5, 0, A); row(c, -5, 5, 1, C); row(c, -4, 5, 2, C); p(c, -2, 1, A); p(c, -1, 2, A); p(c, 3, 1, A);
    cl(c, -1 - sp, 3, 4, A); cl(c, 1 + sp, 3, 4, A); cl(c, 0, 5, 6 + (z > 1 ? 1 : 0), C); p(c, -1, 6, C); p(c, 1, 6, C); p(c, 0, 7 + (z > 1 ? 1 : 0), Hi);
    if (fr === 2) { p(c, 6, 0, Hi); p(c, 7, -1, C); }
    if (fr === 3) { p(c, 6, -2, Hi); p(c, 7, -4, C); p(c, -6, 2, Hi); }
  });
  PFA.glyph('L04-ibexhorn', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* ibex head with a huge backswept scimitar horn, knobbed ridges along it, sweeping through */
    fr0(x, y, tx, ty, nx, ny, K); var i, ang, R = 5.5 + (z > 1 ? 1 : 0), a0 = (fr - 1.5) * .14, a, b;
    row(c, -1, 1, 0, C); row(c, -1, 1, 1, C); row(c, -1, 1, 2, C); p(c, 0, -1, Hi); p(c, -1, -2, Hi); p(c, 1, 1, A);
    for (i = 0; i <= 11; i++) { ang = a0 + i * .2; a = -R + R * Math.cos(ang); b = 3 + R * Math.sin(ang);
      p(c, a, b, i > 9 ? Hi : C); if (i < 7) p(c, a + 1, b, C); if (i % 2 === 1 && i < 10) p(c, a + Math.cos(ang) * 1.6, b + Math.sin(ang) * 1.6, A); }
  });
  PFA.glyph('L04-leaper', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a rock pinnacle with an ibex on it: crouch, spring, tucked in the air, landing in a puff */
    fr0(x, y, tx, ty, nx, ny, K); var hb = [3, 6, 8, 4][fr];
    row(c, -3, 3, 0, A); row(c, -2, 2, 1, A); row(c, -1, 1, 2, C); p(c, -2, 0, C);
    row(c, -2, 2, hb, C); row(c, -1, 2, hb + 1, C); p(c, 3, hb + 2, C); p(c, 3, hb + 1, C); p(c, 2, hb + 3, A); p(c, 1, hb + 3, A); p(c, 0, hb + 3, A);
    if (fr === 0 || fr === 3) { p(c, -2, hb - 1, C); p(c, 2, hb - 1, C); }
    else if (fr === 1) { p(c, -3, hb - 1, C); p(c, -4, hb - 2, C); p(c, 3, hb - 1, C); p(c, 4, hb - 2, C); }
    else { p(c, -1, hb - 1, C); p(c, 1, hb - 1, C); }
    p(c, -3, hb + 1, Hi);
    if (fr === 3) { p(c, -4, 3, Hi); p(c, 4, 3, Hi); p(c, -5, 2, Hi); p(c, 5, 2, Hi); }
  });
  PFA.glyph('L04-beard', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* an old goat face: knobbed horn bases, slotted yellow eyes that glance and narrow, a pale beard */
    fr0(x, y, tx, ty, nx, ny, K); var b, sh = fr === 1 ? 1 : fr === 3 ? -1 : 0;
    for (b = 1; b <= 5; b++) row(c, -2, 2, b, C);
    p(c, -2, 6, A); p(c, -3, 7, A); p(c, -4, 7, Hi); p(c, 2, 6, A); p(c, 3, 7, A); p(c, 4, 7, Hi);
    if (fr === 2) { row(c, -2, -1, 4, A); row(c, 1, 2, 4, A); }
    else { p(c, -2, 4, '#e8c040'); p(c, -1, 4, '#e8c040'); p(c, 1, 4, '#e8c040'); p(c, 2, 4, '#e8c040'); p(c, (sh < 0 ? -2 : -1), 4, A); p(c, (sh > 0 ? 2 : 1), 4, A); }
    p(c, 0, 1, A); cl(c, -1, -2, 0, Hi); cl(c, 0, -3, 0, Hi); cl(c, 1, -2, 0, Hi);
    if (z > 1) { p(c, -3, 3, C); p(c, 3, 3, C); }
    if (fr === 3) p(c, 3, 6, K.WHITE);
  });
  /* --- yak --- */
  PFA.glyph('L04-yak', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* thunder yak head-on: shaggy mass with a dark fringe, wide pale horns, static crackling off them */
    fr0(x, y, tx, ty, nx, ny, K); var b, a, w = z > 1 ? 1 : 0;
    for (b = 0; b <= 4; b++) row(c, -3 - w, 3 + w, b, C);
    for (a = -3 - w; a <= 3 + w; a += 2) p(c, a, -1, A);
    p(c, -1, 3, A); p(c, 1, 3, A); p(c, 0, 1, A); row(c, -2, 2, 5, Hi);
    p(c, -4 - w, 4, HORNP); p(c, -5 - w, 4, HORNP); p(c, -6 - w, 5, HORNP); p(c, -6 - w, 6, HORNP); p(c, -5 - w, 7, A);
    p(c, 4 + w, 4, HORNP); p(c, 5 + w, 4, HORNP); p(c, 6 + w, 5, HORNP); p(c, 6 + w, 6, HORNP); p(c, 5 + w, 7, A);
    if (fr === 1 || fr === 3) { p(c, -7, 8, Hi); p(c, -6, 9, Hi); p(c, -7, 10, Hi); }
    if (fr >= 2) { p(c, 0, 6, Hi); p(c, 1, 7, Hi); p(c, 0, 8, Hi); p(c, 1, 9, K.WHITE); }
    if (fr === 3) { p(c, 7, 8, Hi); p(c, 6, 9, Hi); p(c, 7, 10, K.WHITE); }
  });
  PFA.glyph('L04-skirt', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a long shaggy yak skirt: five strands swaying, static sparks jumping between them */
    fr0(x, y, tx, ty, nx, ny, K); var a, b, sw = (fr - 1.5) * .3, L = 7 + (z > 1 ? 1 : 0);
    row(c, -4, 4, L, C);
    for (a = -4; a <= 4; a += 2) for (b = 0; b < L; b++) p(c, a + sw * (L - b) * .4, b, b === 0 ? A : C);
    p(c, -3 + (fr & 1) * 2, 2 + fr, Hi); p(c, 1 + (fr >> 1), 4 - fr, Hi); p(c, -1 + fr, 1 + fr, K.WHITE);
  });
  PFA.glyph('L04-hoof', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a big cloven hoof stamping: raised, falling with speed lines, impact cracks running out, settling */
    fr0(x, y, tx, ty, nx, ny, K); var b, w = z > 1 ? 1 : 0;
    for (b = 1; b <= 3; b++) row(c, -2 - w, 2 + w, b, A);
    p(c, 0, 1, C); p(c, 0, 2, C);
    for (b = 4; b <= 6; b++) row(c, -2, 2, b, C);
    p(c, -3, 4, C); p(c, 3, 4, C); p(c, -2, 7, C); p(c, 0, 7, C); p(c, 2, 7, C);
    if (fr === 1) { cl(c, -4, 5, 7, Hi); cl(c, 4, 5, 7, Hi); }
    if (fr >= 2) { p(c, -3, 0, Hi); p(c, -4, -1, Hi); p(c, -5, 0, Hi); p(c, 3, 0, Hi); p(c, 4, -1, Hi); p(c, 5, 0, Hi); }
    if (fr === 2) { p(c, -6, -1, K.WHITE); p(c, 6, -1, K.WHITE); p(c, -7, 0, Hi); p(c, 7, 0, Hi); }
  });
  /* --- musk ox --- */
  PFA.glyph('L04-boss', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* musk ox head-on: a pale horn boss across the brow, horns hooking down and out, long hair */
    fr0(x, y, tx, ty, nx, ny, K); var b, w = z > 1 ? 1 : 0;
    for (b = 1; b <= 4; b++) row(c, -2, 2, b, C);
    cl(c, -3, -1, 4, A); cl(c, 3, -1, 4, A); p(c, -2, 0, A); p(c, 0, 0, A); p(c, 2, 0, A); p(c, -1, -1, C); p(c, 1, -1, C);
    p(c, -1, 3, A); p(c, 1, 3, A); p(c, 0, 1, A);
    row(c, -3 - w, 3 + w, 5, HORNP); row(c, -2, 2, 6, HORNP); p(c, 0, 6, Hi);
    p(c, -4 - w, 4, HORNP); p(c, -5 - w, 3, HORNP); p(c, -5 - w, 2, HORNP); p(c, -6 - w, 2, HORNP); p(c, -7 - w, 3, K.WHITE);
    p(c, 4 + w, 4, HORNP); p(c, 5 + w, 3, HORNP); p(c, 5 + w, 2, HORNP); p(c, 6 + w, 2, HORNP); p(c, 7 + w, 3, K.WHITE);
    if (fr === 1) { p(c, -2, -3, A); p(c, 2, -3, A); }
    if (fr === 2) { p(c, 0, 8, K.WHITE); p(c, -2, 8, K.WHITE); p(c, 2, 8, K.WHITE); p(c, -1, 9, Hi); p(c, 1, 9, Hi); p(c, -4, 8, Hi); p(c, 4, 8, Hi); }
  });
  PFA.glyph('L04-qiviut', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the qiviut skirt: long dark guard hairs, soft pale underwool puffing out between them */
    fr0(x, y, tx, ty, nx, ny, K); var a, b, L = 7 + (z > 1 ? 1 : 0), sw = (fr & 1) ? .2 : -.2, r = 1 + (fr >> 1) + (fr & 1);
    for (a = -4; a <= 4; a += 3) for (b = 0; b <= L; b++) { p(c, a + sw * (L - b), b, b < 2 ? A : C); if (b > 2) p(c, a + 1 + sw * (L - b), b, A); }
    s(c, -2.5, 3 + (fr & 1), r + 1, Hi); s(c, 1.5, 4 - (fr & 1), r, Hi); p(c, -2, 5 + r, K.WHITE);
  });
  PFA.glyph('L04-ringox', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a musk ox seen head-on, skirt to the ground, horns out, stamping in the ring */
    fr0(x, y, tx, ty, nx, ny, K); var b, a, st = fr & 1;
    for (b = 1; b <= 6; b++) row(c, -3, 3, b, C);
    for (a = -3; a <= 3; a += 2) p(c, a, 0, A);
    row(c, -1, 1, 7, C); p(c, 0, 7, A); row(c, -2, 2, 8, HORNP); p(c, -3, 8, HORNP); p(c, -3, 7, HORNP); p(c, -4, 6, K.WHITE); p(c, 3, 8, HORNP); p(c, 3, 7, HORNP); p(c, 4, 6, K.WHITE);
    p(c, -2, 5, A); p(c, 2, 5, A);
    if (st) { p(c, -2, -1, A); p(c, -3, -1, Hi); } else { p(c, 2, -1, A); p(c, 3, -1, Hi); }
    if (fr >> 1) p(c, 0, 9, K.WHITE);
    if (z > 1) { cl(c, -4, 1, 4, C); cl(c, 4, 1, 4, C); }
  });
  /* --- bison --- */
  PFA.glyph('L04-snowhump', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a dark shaggy bison hump with snow lying on it, the snow sliding, shaken off, gone */
    fr0(x, y, tx, ty, nx, ny, K); var a, h, w = z > 1 ? 1 : 0, sn;
    for (a = -5; a <= 4; a++) { h = SHUMP[a + 5] + w; cl(c, a, 0, h - 1, C); if (a & 1) p(c, a, 0, A);
      sn = fr === 0 ? 2 : fr === 1 ? (a > 0 ? 0 : a > -3 ? 1 : 2) : 0;
      if (sn) { p(c, a, h, SNOW); if (sn > 1) p(c, a, h + 1, K.WHITE); } else p(c, a, h, (a & 1) ? A : C); }
    if (fr === 1) { p(c, 5, 3, SNOW); p(c, 6, 2, SNOW); }
    if (fr === 2) { p(c, -4, 9 + w, SNOW); p(c, -1, 10 + w, K.WHITE); p(c, 2, 9 + w, SNOW); p(c, 4, 8 + w, K.WHITE); p(c, -6, 6, SNOW); p(c, 6, 5, SNOW); }
    if (fr === 3) { p(c, -2, 11 + w, SNOW); p(c, 3, 11 + w, SNOW); }
  });
  PFA.glyph('L04-plough', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a bison head down in the snow, shoving a curling snow wave ahead of it */
    fr0(x, y, tx, ty, nx, ny, K); var a, h, b, w = z > 1 ? 1 : 0;
    for (b = 0; b <= 3; b++) row(c, -5 - w, -1, b, C);
    row(c, -4, -2, 4, C); p(c, -3, 5, Hi); p(c, -1, 4, A); p(c, 0, 5, A); p(c, -2, 2, K.WHITE); p(c, -4, -1, A); p(c, -2, -1, A);
    for (a = 0; a <= 4; a++) { h = Math.min(a + 1, 1 + fr + (a === 4 ? -1 : 0)); for (b = 0; b < h; b++) p(c, a, b, b === h - 1 ? K.WHITE : SNOW); }
    p(c, 4, 2 + fr, K.WHITE); p(c, 5, 1 + fr, SNOW);
    if (fr >= 2) { p(c, 6, 4 + fr, K.WHITE); p(c, 3, 5 + fr, SNOW); p(c, 7, 2 + fr, SNOW); }
  });
  PFA.glyph('L04-brow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a bison head-on: huge woolly brow, short black up-hooked horns, white-rimmed glare, a snort */
    fr0(x, y, tx, ty, nx, ny, K); var b, a, w = z > 1 ? 1 : 0, sh = fr === 1 ? 1 : fr === 2 ? -1 : 0;
    row(c, -1, 1, 1, A); p(c, -1, 0, C); p(c, 1, 0, C);
    for (b = 2; b <= 5; b++) row(c, -3 - w, 3 + w, b, C);
    row(c, -2, 2, 6, C); for (a = -2; a <= 2; a += 2) p(c, a, 7, Hi);
    p(c, -2, 3, K.WHITE); p(c, 2, 3, K.WHITE);
    p(c, -4 - w + sh, 4, A); p(c, -5 - w + sh, 5, A); p(c, -5 - w + sh, 6, Hi); p(c, 4 + w + sh, 4, A); p(c, 5 + w + sh, 5, A); p(c, 5 + w + sh, 6, Hi);
    if (fr === 2) { p(c, -2, -1, Hi); p(c, -3, -2, Hi); p(c, 2, -1, Hi); p(c, 3, -2, Hi); }
    if (fr === 3) { p(c, -2, 4, K.WHITE); p(c, 2, 4, K.WHITE); }
  });
  PFA.glyph('L04-runbison', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a bison side-on at full gallop: high hump, low head, legs reaching and gathering */
    fr0(x, y, tx, ty, nx, ny, K); var a, g = fr & 1;
    for (a = -4; a <= 4; a++) cl(c, a, 2, 2 + RUNB[a + 4] + (z > 1 && a > -2 ? 1 : 0), C);
    p(c, 1, 7, Hi); p(c, 2, 7, Hi);
    row(c, 5, 6, 2, C); row(c, 5, 6, 3, C); p(c, 7, 2, C); p(c, 6, 4, A); p(c, 7, 5, Hi); p(c, 5, 1, A); p(c, 6, 1, A); p(c, 6, 3, K.WHITE);
    p(c, -5, 5, A); p(c, -6, 5, A);
    if (g) { p(c, -4, 1, C); p(c, -5, 0, A); p(c, -3, 1, C); p(c, -3, 0, A); p(c, 3, 1, C); p(c, 4, 0, A); p(c, 4, 1, C); p(c, 5, 0, A); p(c, -7, 1, Hi); p(c, -8, 2, Hi); }
    else { p(c, -2, 1, C); p(c, -1, 0, A); p(c, -1, 1, C); p(c, 0, 0, A); p(c, 1, 1, C); p(c, 1, 0, A); p(c, 2, 1, C); p(c, 2, 0, A); }
  });
  PFA.glyph('L04-dustball', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a rolling dust cloud kicked up off the prairie, grass stalks flying out of it */
    fr0(x, y, tx, ty, nx, ny, K); var i, r = 2 + fr * .8 + (z > 1 ? 1 : 0), ang;
    s(c, 0, r + 1, Math.max(2, Math.round(r)), C);
    for (i = 0; i < 10; i++) { ang = i * .628 + fr * .3; p(c, Math.cos(ang) * r, r + 1 + Math.sin(ang) * r, (i + fr) % 3 ? C : Hi); }
    p(c, r + 2, r + 2 + (fr & 1), Hi); p(c, r + 3, r + 3 + (fr & 1), Hi); p(c, -r - 2, r + (fr >> 1), Hi); p(c, -r - 1, 1, A);
  });
  /* --- caribou --- */
  PFA.glyph('L04-rack', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* caribou antlers in velvet: two sweeping beams with tines, a brow shovel, shaking */
    fr0(x, y, tx, ty, nx, ny, K); var sh = [0, 1, 0, -1][fr] * .15, i, b, la, L = 9 + (z > 1 ? 1 : 0);
    row(c, -1, 1, 0, C); row(c, -1, 1, 1, C); p(c, -1, 1, A); p(c, 1, 1, A);
    p(c, 0, 2, Hi); p(c, -1, 3, Hi); p(c, 1, 3, Hi); p(c, 0, 3, Hi);
    for (b = 2; b <= L; b++) { la = 1.4 + Math.sin(b * .33) * 2.6 + sh * b; p(c, -la, b, C); p(c, la, b, C); }
    for (i = 0; i < 2; i++) { b = 5 + i * 2; la = 1.4 + Math.sin(b * .33) * 2.6 + sh * b; p(c, -la - 1, b + 1, C); p(c, -la - 2, b + 2, Hi); p(c, la + 1, b + 1, C); p(c, la + 2, b + 2, Hi); }
    la = 1.4 + Math.sin(L * .33) * 2.6 + sh * L; p(c, -la + 1, L + 1, Hi); p(c, la - 1, L + 1, Hi);
    if (fr === 1 || fr === 3) { p(c, -la - 1, L, K.WHITE); p(c, la + 1, L, K.WHITE); }
  });
  PFA.glyph('L04-velvet', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* an antler beam shedding its velvet: a strip peels away raw red underneath and flaps */
    fr0(x, y, tx, ty, nx, ny, K); var i, d = [1, 1.3, .7, 1][fr], L = 7 + (z > 1 ? 1 : 0);
    cl(c, 0, 0, L, C); p(c, 1, 0, C); p(c, -1, 4, C); p(c, -2, 5, C); p(c, -3, 6, Hi); p(c, 0, L + 1, Hi);
    p(c, 1, L - 1, VRED); p(c, 1, L - 3, VRED);
    for (i = 1; i <= 4; i++) p(c, 1 + i * d, L - 1 - i * (1.2 - d * .3), (i & 1) ? VRED : C);
    if (fr === 2) { p(c, 3, 2, VRED); p(c, 4, 1, C); }
  });
  PFA.glyph('L04-clickhoof', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* two caribou legs walking on wide crescent hooves, the knees clicking with each step */
    fr0(x, y, tx, ty, nx, ny, K); var g = fr & 1, la = g ? -2 : -1, lb = g ? 1 : 2;
    row(c, -3, 3, 8, Hi); row(c, -2, 2, 7, C);
    cl(c, la, 1, 6, C); cl(c, lb, 1, 6, C); p(c, la, 4, Hi); p(c, lb, 4, Hi);
    row(c, la - 1, la + 1, 0, A); row(c, lb - 1, lb + 1, 0, A); p(c, la - 1, 1, A); p(c, lb + 1, 1, A);
    if (fr === 1 || fr === 3) { var kx = fr === 1 ? la : lb; p(c, kx - 2, 5, K.WHITE); p(c, kx - 3, 6, K.WHITE); p(c, kx + 2, 5, K.WHITE); p(c, kx + 3, 6, K.WHITE); }
  });

  /* ================= motions (mutate the scratch G; pp = time x speed) ================= */
  PFA.motion('L04-fling', function (G, pp, k, ph) { var u = (pp * 1.6 + ph) % 1; G.up += Math.sin(u * Math.PI) * 5; G.fr = u < .2 ? 3 : u < .6 ? 0 : u < .85 ? 1 : 2; });   /* hang, fly, stretch, splat */
  PFA.motion('L04-fill', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 4) + k) & 3; G.up += G.fr === 3 ? 1 : 0; });                                       /* the bead rises and pops out */
  PFA.motion('L04-kickout', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .35 ? 0 : u < .5 ? 1 : u < .8 ? 2 : 3; if (G.fr >= 2) G.d += 2; });          /* fold, then kick straight out */
  PFA.motion('L04-stare', function (G, pp, k, ph) { var w = Math.floor(pp * 5 + ph * 3); G.fr = (w + k) % 5 === 4 ? 2 : (w + k) % 7 === 3 ? 3 : (w & 1); G.t += Math.sin(pp * 2 + k) * .8; });   /* slow lids, a rare blink */
  PFA.motion('L04-rock', function (G, pp, k) { G.fr = ((Math.floor(pp * 8) + k) & 1) | (((Math.floor(pp * 3) + k) & 1) << 1); G.t += Math.sin(pp * 8 + k); G.up += G.fr & 1; });   /* rolling camel gait */
  PFA.motion('L04-shed', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; G.t += Math.sin(pp * 4 + k); });                                                    /* tufts let go one by one */
  PFA.motion('L04-gore', function (G, pp, k, ph) { var u = (pp * 2.4 + ph) % 1; G.fr = u < .4 ? 0 : u < .6 ? 1 : u < .8 ? 2 : 3; if (u >= .4 && u < .8) { G.d += 3; G.t += (u - .4) * 8; } });   /* lunge and hook up */
  PFA.motion('L04-wallow', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 4) + k) & 3; G.d -= 2; });                                                         /* sits low in the mud, bubbling */
  PFA.motion('L04-root', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 2) + k) & 3; G.up += G.fr === 1 ? 1 : 0; });                                        /* shove, lift, drag a root up */
  PFA.motion('L04-butt', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1;                                                                                              /* rear back, charge, clash, recoil */
    if (u < .4) { G.fr = 1; G.d -= 2 * u / .4; } else if (u < .55) { G.fr = 0; G.d += 6 * (u - .4) / .15 - 2; } else if (u < .7) { G.fr = 2; G.d += 4; } else { G.fr = 3; G.d += 4 * (1 - (u - .7) / .3); } });
  PFA.motion('L04-grip', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; G.t += G.fr === 1 ? 1 : 0; });                                                       /* hooves shift their grip, chips fall */
  PFA.motion('L04-crackle', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 9 + ph * 3) + k) & 3; if (G.fr === 3) G.t += ((Math.floor(pp * 30) + k) & 1) ? 1 : -1; });   /* static crackles off the horns */
  PFA.motion('L04-static', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; G.t += Math.sin(pp * 3 + k) * .8; });                                             /* sparks jump between swaying strands */
  PFA.motion('L04-stomp', function (G, pp, k, ph) { var u = (pp * 2.2 + ph) % 1;                                                                                           /* lift, drop, crack, settle */
    if (u < .5) { G.fr = 0; G.d += 4 * Math.sin(u / .5 * Math.PI / 2); } else if (u < .6) { G.fr = 1; G.d += 4 * (1 - (u - .5) / .1); } else { G.fr = u < .85 ? 2 : 3; G.d -= 1; } });
  PFA.motion('L04-sweep', function (G, pp, k) { G.fr = (Math.floor(pp * 7) + k) & 3; G.t += (G.fr - 1.5) * 1.2; });                                                      /* the long horn sweeps through */
  PFA.motion('L04-crag', function (G, pp, k, ph) { var u = (pp * 1.8 + ph) % 1; G.fr = u < .2 ? 0 : u < .5 ? 1 : u < .8 ? 2 : 3; G.up += Math.sin(Math.min(1, u / .8) * Math.PI) * 3; });   /* crouch, spring, tuck, land */
  PFA.motion('L04-glare', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 3) + k) & 3; G.t += G.fr === 1 ? 1 : G.fr === 3 ? -1 : 0; });                       /* the old eyes glance and narrow */
  PFA.motion('L04-bossram', function (G, pp, k, ph) { var u = (pp * 1.6 + ph) % 1;                                                                                         /* head drops, a heavy ram, the boss rings */
    if (u < .45) { G.fr = 1; G.d -= 2 * u / .45; } else if (u < .6) { G.fr = 0; G.d += 7 * (u - .45) / .15 - 2; } else if (u < .75) { G.fr = 2; G.d += 5; } else { G.fr = 3; G.d += 5 * (1 - (u - .75) / .25); } });
  PFA.motion('L04-billow', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; G.t += Math.sin(pp * 3 + k * 1.3) * 1.2; });                                        /* the underwool puffs out between the hairs */
  PFA.motion('L04-stand', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; G.up += (G.fr & 1) ? 1 : 0; });                                                       /* shoulder to shoulder, stamping */
  PFA.motion('L04-shrug', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 2) + k) & 3; if (G.fr === 2) G.t += ((Math.floor(pp * 24) + k) & 1) ? 1 : -1; });    /* the hump shrugs the snow off */
  PFA.motion('L04-push', function (G, pp, k) { G.s += pp * .2; G.fr = (Math.floor(pp * 8) + k) & 3; });                                                                  /* ploughs on, the wave growing */
  PFA.motion('L04-toss', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; G.t += G.fr === 1 ? 1.5 : G.fr === 2 ? -1.5 : 0; });                                 /* head tossed side to side, a snort */
  PFA.motion('L04-stampede', function (G, pp, k) { G.s += pp * .5; G.fr = (Math.floor(pp * 16) + k) & 1; G.up += G.fr; });                                                /* full gallop along the edge */
  PFA.motion('L04-billowroll', function (G, pp, k, ph) { G.s += pp * .15; G.fr = (Math.floor(pp * 6 + ph * 4) + k) & 3; G.up += Math.sin(pp * 4 + k); });                 /* a dust cloud rolling and swelling */
  PFA.motion('L04-rackshake', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; });                                                                            /* the rack shakes */
  PFA.motion('L04-flap', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; G.t += Math.sin(pp * 6 + k) * 1.2; });                                                /* velvet strips flapping */
  PFA.motion('L04-trek', function (G, pp, k) { G.s += pp * .3; G.fr = (Math.floor(pp * 10) + k) & 3; G.up += (G.fr & 1) ? 1 : 0; });                                       /* migration walk, knees clicking */

  /* ================= custom chain effects (along the OUTER loop from e.a over e.d, eased e.hh) ================= */
  function carSpit(c, e, H) {           /* a spit glob lobbed in one arc to the next piece: dotted flight path, splat on arrival */
    var P = e.P, Q = H.Q, i, u, h;
    for (i = 1; i <= 10; i++) { u = i / 10 * e.hh; if (((i + Math.floor(e.p * 12)) & 1) === 0) continue; P.atq(e.a + e.d * u); h = 4 + Math.sin(u * Math.PI) * 12; H.px(c, Q.x + Q.nx * h, Q.y + Q.ny * h, e.hi); }
    if (e.hh < .94) { P.atq(e.a + e.d * e.hh); h = 3 + Math.sin(e.hh * Math.PI) * 12; H.glyph(c, 'L04-spit', Q.x + Q.nx * h, Q.y + Q.ny * h, e.z > 1 ? 1 : e.z, e.hh < .6 ? 0 : 1, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny); }
    else { P.atq(e.a + e.d); H.glyph(c, 'L04-spit', Q.x + Q.nx * 2, Q.y + Q.ny * 2, e.z, 2, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny); }
  }
  function carBolt(c, e, H) {           /* a forked lightning bolt flickers along the outer edge to the next piece, the yak's head riding its front */
    var P = e.P, Q = H.Q, u, i = 0, b, fl = (Math.floor(e.p * 20) & 3) === 0, col, u0 = Math.max(0, e.hh - .4);
    for (u = u0; u <= e.hh; u += .025, i++) { P.atq(e.a + e.d * u); b = 4 + ((i % 4) < 2 ? (i % 2) * 3 : 3 - (i % 2) * 3); col = fl ? H.WHITE : (i & 1 ? e.hi : H.WHITE);
      H.px(c, Q.x + Q.nx * b, Q.y + Q.ny * b, col); H.px(c, Q.x + Q.nx * (b + 1), Q.y + Q.ny * (b + 1), e.hi);
      if (i % 7 === 5) { H.px(c, Q.x + Q.nx * (b + 3) + Q.ny * 2, Q.y + Q.ny * (b + 3) - Q.nx * 2, e.hi); H.px(c, Q.x + Q.nx * (b + 4) + Q.ny * 3, Q.y + Q.ny * (b + 4) - Q.nx * 3, e.hi); } }
    H.carHead(c, P, e.a + e.d * e.hh, 'L04-yak', e.z > 1 ? 1 : e.z, 3, 0, 0, e.col, e.acc, e.hi);
  }
  function carDrift(c, e, H) {          /* a snow wave rolls along the outer edge, flecks spraying off its crest, the ploughing head at the front */
    var P = e.P, Q = H.Q, u, i = 0, h, j, sd = e.d < 0 ? -1 : 1, u0 = Math.max(0, e.hh - .3);
    for (u = u0; u <= e.hh; u += .03, i++) { P.atq(e.a + e.d * u); h = 1 + Math.round((u - u0) / Math.max(.01, e.hh - u0) * 3);
      for (j = 1; j <= h; j++) H.px(c, Q.x + Q.nx * (1 + j), Q.y + Q.ny * (1 + j), j === h ? H.WHITE : SNOW);
      if ((i + Math.floor(e.p * 10)) % 4 === 0) H.px(c, Q.x + Q.nx * (h + 4), Q.y + Q.ny * (h + 4) - 1, SNOW); }
    P.atq(e.a + e.d * e.hh); H.glyph(c, 'L04-plough', Q.x + Q.nx * 2, Q.y + Q.ny * 2, e.z > 1 ? 1 : e.z, Math.floor(e.p * 8) & 3, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
  }
  function carHerd(c, e, H) {           /* three bison gallop in file along the outer edge to the next piece, a dust cloud rolling behind them */
    var P = e.P, Q = H.Q, k, u, sd = e.d < 0 ? -1 : 1, fr, j;
    for (k = 2; k >= 0; k--) { u = e.hh - k * .11; if (u < 0) continue; P.atq(e.a + e.d * u); fr = (Math.floor(e.p * 16) + k) & 1;
      H.glyph(c, 'L04-runbison', Q.x + Q.nx * 2, Q.y + Q.ny * 2 - fr, e.z > 1 ? 1 : e.z, fr, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
      for (j = 0; j < 3; j++) { P.atq(e.a + e.d * Math.max(0, u - .04 - j * .02)); H.sq(c, Q.x + Q.nx * (2 + j * 2 + ((j + fr) & 1)), Q.y + Q.ny * (2 + j * 2) - j, 2, j === 1 ? e.hi : e.acc); } }
  }

  /* ================= motifs ================= */
  function M(name, meta) { PFA.motif(name, comp, meta); }
  /* camels */
  M('spit-glob', { nm: 'cud spit', desc: 'a glob of green-white cud spit: flies with a tail, stretches, splats flat with flecks, hangs on slimy strings; the chain lobs one glob in an arc and splats it on the next piece', fam: 'drip', gap: 14, g: 'L04-spit', mo: 'L04-fling', x: '-', car: 'custom', carDraw: carSpit });
  M('hump-well', { nm: 'water humps', desc: 'a dromedary hump outline with a water bead rising inside it and popping out of the top in a sparkle', fam: 'mend', gap: 16, g: 'L04-hump', mo: 'L04-fill', x: 'dewrun', car: 'trail' });
  M('splay-kick', { nm: 'long kicks', desc: 'a long camel leg folding and kicking straight out, the splayed two-toed foot flaring a puff of sand', fam: 'slash', gap: 14, g: 'L04-kick', mo: 'L04-kickout', x: 'dust', car: 'hop' });
  M('lidded-stare', { nm: 'lidded stares', desc: 'a heavy-lidded camel eye with long lashes, half shut and unimpressed, a slow blink, a rare glint', fam: 'puff', gap: 14, g: 'L04-eye', mo: 'L04-stare', x: '-', car: 'blink' });
  M('twin-hump', { nm: 'two-humped camels', desc: 'a two-humped camel side-on with wool tufts on both humps, rocking along in its rolling gait, the humps swelling and settling', fam: 'bash', gap: 18, g: 'L04-bactrian', mo: 'L04-rock', x: 'prints', car: 'train' });
  M('wool-moult', { nm: 'moulting wool', desc: 'a shaggy clump of moulting wool along the edge, loose tufts peeling off and drifting away', fam: 'shield', gap: 12, g: 'L04-moult', mo: 'L04-shed', x: '-', car: 'flutter' });
  /* boar */
  M('boar-tusk', { nm: 'hooking tusks', desc: 'a boar head snout-out with a bristle crest and pricked ears, two ivory tusks hooking upward as it lunges and gores', fam: 'thrust', gap: 16, g: 'L04-tusk', mo: 'L04-gore', x: '-', car: 'comet' });
  M('mud-wallow', { nm: 'mud wallows', desc: 'a dark glossy mud pool, bubbles swelling and popping, a boar\'s back and ears breaking the surface', fam: 'ripple', gap: 16, g: 'L04-wallow', mo: 'L04-wallow', x: '-', car: 'rings' });
  M('snout-root', { nm: 'rooting snouts', desc: 'a pig snout shoving up out of a turf mound and dragging a curling root up after it, clods flying', fam: 'leaf', gap: 14, g: 'L04-snout', mo: 'L04-root', x: 'clods', car: 'tunnel' });
  /* ram, ibex */
  M('curl-horn', { nm: 'curled horns', desc: 'a ram head-on with two thick curled horns: it rears back, charges and clashes in a white star with cracks', fam: 'bash', gap: 16, g: 'L04-ramhorn', mo: 'L04-butt', x: 'dust', car: 'hop' });
  M('cloven-ledge', { nm: 'ledge hooves', desc: 'a rock ledge with a cloven hoof gripping its lip, the toes shifting, chips breaking off and falling', fam: 'shield', gap: 14, g: 'L04-ledgehoof', mo: 'L04-grip', x: '-', car: 'hop' });
  M('scimitar-horn', { nm: 'scimitar horns', desc: 'an ibex head with one huge backswept horn ridged with knobs, sweeping through the air', fam: 'slash', gap: 16, g: 'L04-ibexhorn', mo: 'L04-sweep', x: '-', car: 'comet' });
  M('crag-leap', { nm: 'crag leaps', desc: 'a rock pinnacle with an ibex crouched on it, springing up, tucked in the air, landing in a puff', fam: 'puff', gap: 16, g: 'L04-leaper', mo: 'L04-crag', x: '-', car: 'hop' });
  M('beard-stare', { nm: 'bearded stares', desc: 'an old goat face with knobbed horn bases, slotted yellow eyes that glance and narrow, and a pale beard', fam: 'sparkle', gap: 16, g: 'L04-beard', mo: 'L04-glare', x: '-', car: 'blink' });
  /* yak */
  M('storm-yak', { nm: 'thunder yaks', desc: 'a shaggy yak head-on with a dark fringe and wide pale horns, static crackling off the horn tips; the chain is a lightning bolt flickering along the outer edge', fam: 'shock', gap: 18, g: 'L04-yak', mo: 'L04-crackle', x: '-', car: 'custom', carDraw: carBolt });
  M('static-skirt', { nm: 'static skirts', desc: 'a long shaggy yak skirt of five strands swaying, static sparks jumping between them', fam: 'shield', gap: 14, g: 'L04-skirt', mo: 'L04-static', x: '-', car: 'zig' });
  M('thunder-hoof', { nm: 'thunder hooves', desc: 'a big cloven hoof raised, dropped with speed lines and stamped, cracks running out from the impact', fam: 'bash', gap: 16, g: 'L04-hoof', mo: 'L04-stomp', x: 'dust', car: 'rings' });
  /* musk ox */
  M('horn-boss', { nm: 'horn bosses', desc: 'a musk ox head-on: a pale horn boss across the brow, horns hooking down and out, long dark hair; the head drops and rams, the boss ringing white', fam: 'bash', gap: 18, g: 'L04-boss', mo: 'L04-bossram', x: '-', car: 'comet' });
  M('qiviut-skirt', { nm: 'qiviut skirts', desc: 'long dark guard hairs to the ground with soft pale underwool puffing out between them', fam: 'shield', gap: 14, g: 'L04-qiviut', mo: 'L04-billow', x: 'snow', car: 'flutter' });
  M('ring-stand', { nm: 'defence ring', desc: 'musk oxen head-on, skirts to the ground and horns out, standing shoulder to shoulder and stamping', fam: 'bash', gap: 14, g: 'L04-ringox', mo: 'L04-stand', x: 'prints', car: 'train' });
  /* bison */
  M('snow-hump', { nm: 'snowy humps', desc: 'a dark shaggy bison hump with snow lying on it, the snow sliding off one side and then shrugged off in a flurry', fam: 'shield', gap: 18, g: 'L04-snowhump', mo: 'L04-shrug', x: 'snow', car: 'roll' });
  M('plough-spray', { nm: 'snow ploughs', desc: 'a bison head down in the snow shoving a curling snow wave ahead; the chain is the snow wave rolling along the outer edge', fam: 'bash', gap: 16, g: 'L04-plough', mo: 'L04-push', x: 'snow', car: 'custom', carDraw: carDrift });
  M('bison-brow', { nm: 'bison brows', desc: 'a bison head-on: huge woolly brow, short black up-hooked horns, white-rimmed glaring eyes, tossing and snorting', fam: 'bash', gap: 16, g: 'L04-brow', mo: 'L04-toss', x: '-', car: 'comet' });
  M('stampede-dust', { nm: 'stampede', desc: 'bison side-on at full gallop, high humps and low heads, in a rolling dust cloud; the chain is three bison galloping in file along the outer edge', fam: 'bash', gap: 18, g: 'L04-runbison', mo: 'L04-stampede', x: 'dust', car: 'custom', carDraw: carHerd });
  M('prairie-dust', { nm: 'prairie dust', desc: 'a rolling, swelling dust cloud kicked up off the prairie, grass stalks flying out of it', fam: 'puff', gap: 14, g: 'L04-dustball', mo: 'L04-billowroll', x: 'pollen', car: 'cloud' });
  /* caribou */
  M('velvet-rack', { nm: 'velvet racks', desc: 'caribou antlers in velvet: two sweeping beams with tines and a brow shovel over a small head, shaking, the tips catching the light', fam: 'thrust', gap: 18, g: 'L04-rack', mo: 'L04-rackshake', x: '-', car: 'comet' });
  M('velvet-shed', { nm: 'shedding velvet', desc: 'an antler beam with a strip of velvet peeling away raw red underneath and flapping', fam: 'puff', gap: 12, g: 'L04-velvet', mo: 'L04-flap', x: '-', car: 'flutter' });
  M('knee-click', { nm: 'clicking knees', desc: 'two caribou legs walking on wide crescent hooves under a pale mane, white click marks at the knees with each step', fam: 'slash', gap: 14, g: 'L04-clickhoof', mo: 'L04-trek', x: 'prints', car: 'train' });
})();
