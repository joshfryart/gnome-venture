/* Motif module, large batch L03 (jungle-tiger, elder-tiger, black-jaguar, cloud-leopard, ghost-leopard, tufted-lynx, snow-lynx, mischief-monkey,
   mandrill-boss, bearded-pig). TEMPLATE.md sections 9 and 10.3.
   32 motifs, each with its own pixel glyph (ids prefixed L03-) and motion; eight have their own chain effect (carDraw).
   Large creatures fight on the 5x5 board (cells 40 x 34): glyphs reach up to ~10 px off the edge, a little bigger than small/medium, still inside ~22 px.
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation inside the frame loops (module-level scratch frame
   and constant tables built once at load). Glyphs go through H.glyph so the MAXG budget counts them; custom chain effects cap their pixels.
   The wiggle (x 2.6 px / rot .06), the outer-edge chain rule, visual-only sound lines and the creature-heavy default are untouched (they live in the page). */
(function () {
  /* ---------- constant tables and colours (built once) ---------- */
  var LEAF = '#7cb24e', LEAFD = '#3e6c2c', ROCK = '#a4a8b0', TONGUE = '#f08ca0', GOLD = '#f2c840', HATRED = '#d8443a', STEEL = '#c8ccd4',
    BEARD = '#f0a040', MUD = '#8e6842', NOSE = '#e4a4a0', SCAR = '#f4d4cc', DUST = '#c8b494', VINE = '#5e9a3e';
  var R8X = [], R8Y = [], R5X = [], R5Y = [], ARX = [], ARY = [], i0;
  for (i0 = 0; i0 < 8; i0++) { R8X.push(Math.cos(i0 * Math.PI / 4)); R8Y.push(Math.sin(i0 * Math.PI / 4)); }
  for (i0 = 0; i0 < 5; i0++) { R5X.push(Math.cos(i0 * Math.PI * 2 / 5 + .3)); R5Y.push(Math.sin(i0 * Math.PI * 2 / 5 + .3)); }
  for (i0 = 0; i0 <= 6; i0++) { ARX.push(Math.cos(i0 * Math.PI / 6)); ARY.push(Math.sin(i0 * Math.PI / 6)); }   /* half arc, outward */
  var NUTA = [0, -2, 2, -1, 1], NUTB = [1, 1, 1, 3, 3];                                                            /* nut pile stacking order */

  /* ---------- glyph frame: (a along the edge tangent, b outward along the normal); set once per glyph call, no allocation ---------- */
  var CV, KK, X0, Y0, TX, TY, NX, NY;
  function F(c, x, y, tx, ty, nx, ny, K) { CV = c; KK = K; X0 = x; Y0 = y; TX = tx; TY = ty; NX = nx; NY = ny; }
  function d(a, b, col) { KK.px(CV, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, col); }
  function s(a, b, w, col) { KK.sq(CV, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, w, col); }

  /* ---------- shared own-edge composition (the page's themedOwn() with this module's glyph / motion, plus an optional per-run decoration) ---------- */
  function comp(c, e, H, deco) {
    var runs = e.runs, mp = e.mp, M = e.M, z = e.z, p = e.p, pp = p * mp.spd, Q = H.Q, G = H.G, P = e.P,
      tie = mp.x === 'thread' || mp.lay === 'snare', ri, k, r, len, n, f, ph, sf, bx0, by0, nx, ny, x, y, lx = 0, ly = 0, has;
    for (ri = 0; ri < runs.length; ri++) {
      r = runs[ri]; len = r[1] - r[0]; n = Math.max(1, Math.min(7, Math.round(len / (M.gap || 12)))); if (mp.lay === 'lance') n = Math.min(n, 3); has = false;
      for (k = 0; k < n; k++) {
        f = (k + .5) / n; ph = H.hash(e.seed * 13 + k * 7 + ri * 31);
        H.lay(mp.lay, p, f, ph, k); H.mot(M.mo, pp, k, ph);
        if (G.vis <= 0 || !H.stip(G.vis, k + ri * 9, p)) { has = false; continue; }
        sf = G.s - Math.floor(G.s); P.atq(r[0] + len * sf); bx0 = Q.x; by0 = Q.y; nx = Q.nx; ny = Q.ny;
        x = bx0 + nx * G.d - ny * G.t; y = by0 + ny * G.d + nx * G.t - G.up;
        if (mp.x === 'threads') H.ln(c, bx0 + nx, by0 + ny, x, y, 1, e.hi);
        else if (mp.x === 'silk') H.ln(c, bx0 + ny * 9 + nx, by0 - nx * 9 + ny, x, y, 1, e.hi);
        if (tie && has && Math.abs(x - lx) + Math.abs(y - ly) < 34) H.ln(c, lx, ly, x, y, 1, e.hi);
        H.glyph(c, M.g, x, y, z, G.fr, e.col, e.acc, e.hi, -ny, nx, nx, ny); lx = x; ly = y; has = true;
      }
      H.ext(c, mp.x, P, r[0], len, ri, p, pp, e.col, e.acc, e.hi, e.seed);
      if (deco) deco(c, e, H, r[0], len, ri, pp);
    }
  }
  function plain(c, e, H) { comp(c, e, H, null); }

  /* ---------- per-run decorations (a few dozen pixels at most) ---------- */
  function decoLeaves(c, e, H, s0, len, ri, pp) {      /* tiger-leap: three leaves shaken loose, rocking as they fall (screen-down, outside the piece) */
    var k, u, X, Y, Q = H.Q;
    if (e.p > .92) return;
    for (k = 0; k < 3; k++) { u = (pp * .9 + k * .33 + ri * .17) % 1; e.P.atq(s0 + len * (k + .5) / 3);
      X = Q.x + Q.nx * (8 + 4 * u) + Math.sin(u * 7 + k) * 3; Y = Q.y + Q.ny * (8 + 4 * u) - 4 + 10 * u;
      H.px(c, X, Y, LEAF); H.px(c, X + 1, Y, LEAF); H.px(c, X + ((Math.floor(u * 7) & 1) ? 1 : 0), Y + 1, LEAFD); }
  }
  function decoPuddle(c, e, H, s0, len, ri, pp) {      /* rain-streak: puddle rings spread where the rain lands */
    var k, u, Q = H.Q;
    for (k = 0; k < 2; k++) { u = (pp * 1.6 + k * .5) % 1; if (e.p > .92) break; e.P.atq(s0 + len * (k * .5 + .25));
      H.ringpx(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, 1 + u * 4, u < .5 ? H.DEW : e.col); }
  }

  /* ---------- glyphs (C main, A dark, Hi highlight; tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step) ---------- */
  /* jungle-tiger */
  PFA.glyph('L03-stripe', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a low slinking tiger: orange body, slanted black stripes, white belly, head, black-tipped tail */
    F(c, x, y, tx, ty, nx, ny, K); var a, L = 4 + (z >> 1), st = fr & 1, h = L + 1;
    for (a = -L; a <= L; a++) { d(a, 1, Hi); d(a, 2, C); d(a, 3, C); }
    for (a = -L + 1; a <= L - 1; a += 3) { d(a, 3, A); d(a + 1, 2, A); }
    d(h, 2, C); d(h, 3, C); d(h, 4, C); d(h + 1, 2, C); d(h + 1, 3, C); d(h + 1, 4, A); d(h, 5, C); d(h + 2, 2, Hi); d(h + 2, 3, Hi);
    d(-L + 1 + st, 0, C); d(L - 1 - st, 0, C);
    d(-L - 1, 3, C); d(-L - 2, 4, C); d(-L - 3, 4 + st, A);
  });
  PFA.glyph('L03-leap', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a tiger crouched (fr 0) or stretched in mid-leap, forepaws reaching, stripes along the back */
    F(c, x, y, tx, ty, nx, ny, K); var a, L = 3 + (z >> 1);
    if (!(fr & 1)) {
      for (a = -L; a <= L - 1; a++) { d(a, 1, Hi); d(a, 2, C); d(a, 3, C); } d(-L, 4, C); d(-L + 1, 4, C);
      for (a = -L + 1; a <= L - 1; a += 2) d(a, 3, A);
      d(L, 2, C); d(L, 3, C); d(L + 1, 2, Hi); d(L, 4, C); d(-L - 1, 4, C); d(-L - 2, 5, A);
      return;
    }
    for (a = -L - 1; a <= L + 1; a++) { d(a, 3, Hi); d(a, 4, C); d(a, 5, C); }
    for (a = -L; a <= L; a += 2) { d(a, 5, A); d(a + 1, 4, (a & 2) ? A : C); }
    d(L + 2, 4, C); d(L + 3, 3, C); d(L + 4, 3, K.WHITE);
    d(L + 2, 5, C); d(L + 3, 5, C); d(L + 2, 6, C); d(L + 3, 6, A); d(L + 4, 5, Hi);
    d(-L - 2, 4, C); d(-L - 3, 3, C); d(-L - 4, 2, C); d(-L - 2, 6, C); d(-L - 3, 7, A);
  });
  PFA.glyph('L03-claw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a paw: claws slide out, rake, and the three scars turn into black stripes */
    F(c, x, y, tx, ty, nx, ny, K); var i, j, a0, L = 2 + (z >> 1), f = fr & 3;
    s(0, 1, 3, C); d(-2, 1, C); d(2, 1, C);
    for (i = 0; i < 4; i++) { a0 = (i - 1.5) * 1.4; d(a0, 3, C); if (f) for (j = 1; j <= L; j++) d(a0 + j * .4, 3 + j, j === L ? K.WHITE : Hi); }
    if (f >= 2) for (i = 0; i < 3; i++) { a0 = 4 + i * 2; for (j = 0; j < 5; j++) d(a0 - j * .6, 1 + j * 1.3, f === 2 ? Hi : A); }
  });
  PFA.glyph('L03-dapple', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a broad jungle leaf with a dark midrib, sun flecks blinking round it */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, w, f = fr & 3;
    for (b = 1; b <= 5; b++) { w = (b === 1 || b === 5) ? 1 : b === 3 ? 3 + (z >> 1) : 2; for (a = -w; a <= w; a++) d(a, b, C); }
    d(0, 6, C); for (b = 0; b <= 5; b++) d(0, b, A);
    d(-3 + f * 2, 7 - (f & 1), K.WHITE); d(4 - f, 2 + (f >> 1) * 3, Hi); if (f & 1) d(-4, 4, Hi);
  });
  /* elder-tiger */
  PFA.glyph('L03-elderpaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a huge old paw: lifted (shadow below), stamped with a dust burst, a pale scar across the pad */
    F(c, x, y, tx, ty, nx, ny, K); var j, f = fr & 3, w = 5 + (z >> 1);
    if (f === 0) { s(0, 6, 3, C); d(-3, 9, C); d(-1, 10, C); d(1, 10, C); d(3, 9, C); d(-1, 1, A); d(0, 1, A); d(1, 1, A); return; }
    s(0, 3, w, C); s(-3, 7, 2, C); s(-1, 8, 2, C); s(1, 8, 2, C); s(3, 7, 2, C);
    for (j = -3; j <= 3; j++) d(j, 3 + j * .7, Hi);
    d(-2, 5, Hi); d(2, 6, Hi);
    if (f === 1) { d(-5, 1, DUST); d(5, 1, DUST); d(-6, 2, DUST); d(6, 2, DUST); d(-7, 1, DUST); d(7, 1, DUST); }
  });
  PFA.glyph('L03-lick', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a stitched pale scar, a pink tongue licking along it; the scar shortens, a plus rises */
    F(c, x, y, tx, ty, nx, ny, K); var j, f = fr & 3, L = f >= 2 ? 4 : 7, t = -4 + f * 3;
    for (j = 0; j < L; j++) { d(j - 3, 2 + (j & 1), SCAR); if (!(j & 1)) { d(j - 3, 1, A); d(j - 3, 4, A); } }
    s(t, 5, 2, TONGUE); d(t + 1, 4, TONGUE); d(t - 1, 6, TONGUE);
    if (f === 3) { d(0, 7, Hi); d(0, 8, Hi); d(0, 9, Hi); d(-1, 8, Hi); d(1, 8, Hi); }
    d(-4, 3, C); d(L - 2, 3, C);
  });
  PFA.glyph('L03-limp', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a firm print and a dragged one: the hind paw smears a line behind it */
    F(c, x, y, tx, ty, nx, ny, K); var j, f = fr & 1, o = f ? 2 : -2;
    s(-o, 2, 3, C); d(-o - 1, 4, C); d(-o, 5, C); d(-o + 1, 4, C);
    s(o, 3, 2, C); for (j = 1; j <= 4; j++) d(o - j * (f ? 1 : -1), 3, j < 3 ? Hi : A);
  });
  /* black-jaguar */
  PFA.glyph('L03-eyes', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a black head in the dark: only the yellow eyes open, a faint rosette sheen */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, f = fr & 3;
    for (b = 1; b <= 5; b++) for (a = -3; a <= 3; a++) if (!((b === 1 || b === 5) && (a === -3 || a === 3))) d(a, b, A);
    d(-3, 6, A); d(3, 6, A); d(-3, 2, C); d(3, 3, C); d(0, 1, C); d(-2, 6, C);
    if (f === 0) { d(-2, 4, C); d(-1, 4, C); d(1, 4, C); d(2, 4, C); return; }
    d(-2, 4, Hi); d(-1, 4, Hi); d(1, 4, Hi); d(2, 4, Hi);
    if (f >= 2) { d(-2, 3, Hi); d(-1, 3, Hi); d(1, 3, Hi); d(2, 3, Hi); d(-1, 4, A); d(1, 4, A); }
    if (f === 3) { d(-2, 4, K.WHITE); d(2, 4, K.WHITE); }
  });
  PFA.glyph('L03-rosette', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a broken rosette ring in the coat's sheen round a dark core, a glint going round */
    F(c, x, y, tx, ty, nx, ny, K); var i, f = fr & 3, r = 2.6 + (z >> 1) * .8;
    for (i = 0; i < 5; i++) { if (i === f) continue; d(R5X[i] * r, 4 + R5Y[i] * r, C); d(R5X[i] * (r + 1), 4 + R5Y[i] * (r + 1), C); }
    s(0, 4, 2, A); d(R8X[f * 2] * (r + 2), 4 + R8Y[f * 2] * (r + 2), K.WHITE);
  });
  PFA.glyph('L03-rain', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* rain streaks falling screen-down past the edge, a splash crown and a dark puddle line where they hit */
    var i, f = fr & 3, X, Y, bx0 = x + nx * 2, by0 = y + ny * 2;
    for (i = 0; i < 3; i++) { X = bx0 + nx * 5 + (i - 1) * 3; Y = by0 + ny * 5 - 6 + ((f + i * 2) & 3) * 3;
      K.px(c, X, Y, K.DEW); K.px(c, X - 1, Y + 1, K.DEW); K.px(c, X - 2, Y + 2, C); }
    if (f === 1 || f === 2) { K.px(c, bx0 - 2, by0 - f, K.WHITE); K.px(c, bx0, by0 - f - 1, K.WHITE); K.px(c, bx0 + 2, by0 - f, K.WHITE); }
    K.bx(c, bx0 - 2, by0 + 1, 5, 1, C); K.px(c, bx0, by0 + 1, A);
  });
  PFA.glyph('L03-fang', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* dark jaws with two big white fangs: open, slam shut, crunch (crack marks), glint */
    F(c, x, y, tx, ty, nx, ny, K); var a, f = fr & 3, g = f === 1 ? 3 : f === 0 ? 1 : 0;
    for (a = -3; a <= 3; a++) { d(a, 1, C); d(a, 2, A); d(a, 5 + g, A); d(a, 6 + g, C); }
    d(-2, 3, K.WHITE); d(2, 3, K.WHITE); d(-2, 4 + g, K.WHITE); d(2, 4 + g, K.WHITE); d(-2, 3 + g, K.WHITE); d(2, 3 + g, K.WHITE);
    if (f === 2) { d(-5, 3, Hi); d(-6, 4, Hi); d(-5, 5, Hi); d(5, 4, Hi); d(6, 3, Hi); d(6, 5, Hi); }
    if (f === 3) { d(-3, 5, K.WHITE); d(-2, 6, K.WHITE); d(-1, 5, K.WHITE); }
  });
  /* cloud-leopard */
  PFA.glyph('L03-cloud', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a clouded-leopard blotch: a cloud shape with a dark rim and dark freckles, billowing */
    F(c, x, y, tx, ty, nx, ny, K); var a, f = fr & 3, w = 4 + (z >> 1), sh = f - 1.5;
    for (a = -w; a <= w; a++) { d(a, 1, A); d(a, 2, C); d(a, 3, C); }
    d(-w - 1, 2, A); d(w + 1, 2, A); d(-w, 4, A); d(w, 4, A);
    d(-2 + sh * .6, 4, C); d(-1 + sh * .6, 4, C); d(sh * .6, 4, C); d(1 + sh * .6, 4, C); d(-1 + sh, 5, C); d(sh, 5, C); d(-2 + sh, 5, A); d(1 + sh, 5, A);
    d(2 - sh * .5, 4, C); d(3 - sh * .5, 4, A); d(-2, 2, A); d(2, 3, A); d(0, 2, Hi);
  });
  PFA.glyph('L03-tail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a very long thick tail with dark rings, swaying and hooking at the tip */
    F(c, x, y, tx, ty, nx, ny, K); var j, a, sw = ((fr & 3) - 1.5) * .35, L = 7 + (z >> 1) * 2;
    for (j = 1; j <= L; j++) { a = sw * j * j * .12; s(a, j, 2, ((j >> 1) & 1) ? A : C); }
    a = sw * L * L * .12; d(a + 1, L + 1, A); d(a + 2, L, A); d(a + 2, L - 1, C); d(a, 2, Hi);
  });
  PFA.glyph('L03-grip', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* two big paws gripping a grey rock ledge, white claws hooked over, pebbles kicked off */
    F(c, x, y, tx, ty, nx, ny, K); var a, f = fr & 3, up = f === 1 ? 1 : 0;
    for (a = -5; a <= 5; a++) { d(a, 1, ROCK); d(a, 2, (a & 1) ? ROCK : A); }
    s(-2, 4 + up, 3, C); s(2, 4 + up, 3, C); d(-3, 3 + up, K.WHITE); d(-2, 3 + up, K.WHITE); d(2, 3 + up, K.WHITE); d(3, 3 + up, K.WHITE);
    d(-2, 5 + up, A); d(2, 5 + up, A);
    if (f) { d(5 + f, 2 + f, ROCK); d(-5 - f, 1 + f, ROCK); }
  });
  /* ghost-leopard */
  PFA.glyph('L03-ghost', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a pale rosette drawn only in part: near invisible, then nearly whole, a cold glint */
    F(c, x, y, tx, ty, nx, ny, K); var i, f = fr & 3, r = 3 + (z >> 1);
    for (i = 0; i < 8; i++) { if (f === 0 && (i & 1)) continue; if (f < 3 && ((i + f) & 3) === 0) continue; d(R8X[i] * r, 4 + R8Y[i] * r, C); }
    if (f >= 2) { d(0, 4, C); d(1, 4, C); }
    if (f === 3) d(r + 1, 4 + r, Hi);
  });
  PFA.glyph('L03-rime', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* three frost-stiff fur spikes fanning out, an ice crystal on each tip */
    F(c, x, y, tx, ty, nx, ny, K); var i, j, a0, L, f = fr & 3, ta;
    for (i = 0; i < 3; i++) { a0 = (i - 1) * 2.5; L = 2 + f + (i === 1 ? 1 : 0) + (z >> 1);
      for (j = 1; j <= L; j++) d(a0 + (i - 1) * j * .35, j, C);
      ta = a0 + (i - 1) * (L + 1) * .35; d(ta, L + 1, Hi);
      if (f === 3 && i === 1) { d(ta - 1, L + 1, K.WHITE); d(ta + 1, L + 1, K.WHITE); d(ta, L + 2, K.WHITE); } }
    d(-1, 1, Hi); d(1, 1, Hi);
  });
  PFA.glyph('L03-gprint', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a leopard print appearing in snow with no cat: faint, pad, full, then dithering away */
    F(c, x, y, tx, ty, nx, ny, K); var f = fr & 3;
    if (f === 0) { d(0, 3, C); d(-1, 6, C); return; }
    if (f === 3) { d(-1, 2, C); d(1, 3, C); d(0, 4, C); d(-2, 6, C); d(1, 7, C); return; }
    s(0, 3, 3, C); d(-1, 2, Hi);
    if (f === 2) { d(-2, 6, C); d(-1, 7, C); d(1, 7, C); d(2, 6, C); d(3, 8, Hi); }
  });
  /* tufted-lynx / snow-lynx */
  PFA.glyph('L03-tufts', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a lynx face with white side ruffs and tall ears, long black tufts flicking */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, f = fr & 3, lt = (f === 1 || f === 3) ? 1 : 0, rt = (f === 2 || f === 3) ? 1 : 0, up = f === 3 ? 1 : 0;
    for (b = 1; b <= 3; b++) for (a = -3; a <= 3; a++) d(a, b, C);
    d(-4, 1, Hi); d(4, 1, Hi); d(-4, 2, Hi); d(4, 2, Hi); d(0, 1, Hi); d(-1, 3, A); d(1, 3, A); d(0, 2, A);
    d(-3, 4 + up, C); d(-2, 4 + up, C); d(-3, 5 + up, C); d(-3, 6 + up - lt, A); d(-3 - lt, 7 + up - lt, A); d(-3 - lt * 2, 8 + up - lt, Hi);
    d(2, 4 + up, C); d(3, 4 + up, C); d(3, 5 + up, C); d(3, 6 + up - rt, A); d(3 + rt, 7 + up - rt, A); d(3 + rt * 2, 8 + up - rt, Hi);
  });
  PFA.glyph('L03-spring', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a lynx coiled low (fr 0) or springing on long hind legs, bobtail up, tufted ear */
    F(c, x, y, tx, ty, nx, ny, K); var a, L = 3 + (z >> 1);
    if (!(fr & 1)) {
      for (a = -L; a <= L; a++) { d(a, 1, C); d(a, 2, C); } d(-L, 3, C); d(-L + 1, 3, C); d(-L - 1, 3, A); d(-1, 2, A); d(1, 1, A);
      d(L + 1, 1, C); d(L + 1, 2, C); d(L + 2, 1, Hi); d(L + 1, 3, C); d(L + 1, 4, A);
      return;
    }
    for (a = -L; a <= L + 1; a++) { d(a, 4, C); d(a, 5, C); } d(-1, 5, A); d(1, 4, A);
    d(-L - 1, 3, C); d(-L - 2, 2, C); d(-L - 3, 1, C); d(-L - 4, 1, Hi);
    d(L + 2, 5, C); d(L + 2, 6, C); d(L + 3, 5, Hi); d(L + 3, 4, C); d(L + 4, 4, K.WHITE);
    d(L + 1, 7, C); d(L + 1, 8, A); d(-L - 1, 6, C); d(-L - 1, 7, A);
  });
  PFA.glyph('L03-hook', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* one long hooked claw off a furry paw, curling tighter, a slash line on the strike */
    F(c, x, y, tx, ty, nx, ny, K); var j, f = fr & 3, L = 4 + (z >> 1), cu = f ? .08 + (f - 1) * .06 : 0;
    s(0, 1, 3, C); d(-2, 1, C); d(2, 1, C); d(-2, 2, Hi); d(2, 2, Hi);
    for (j = 1; j <= L; j++) d(j * j * cu, 2 + j, j === L ? K.WHITE : Hi);
    if (f === 3) for (j = 0; j < 5; j++) d(4 + j * .6, 1 + j, Hi);
  });
  PFA.glyph('L03-snowshoe', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a huge furry snowshoe paw: lifted, pressed (snow puffs out sideways), sunk in the drift */
    F(c, x, y, tx, ty, nx, ny, K); var a, f = fr & 3, lb = f === 0 ? 2 : 0, w = 4 + (z >> 1);
    for (a = -w; a <= w; a++) { d(a, 2 + lb, C); d(a, 3 + lb, C); }
    if (f) for (a = -w - 1; a <= w + 1; a += 2) { d(a, 1, Hi); d(a, 4, Hi); }
    d(-3, 5 + lb, C); d(-1, 6 + lb, C); d(1, 6 + lb, C); d(3, 5 + lb, C); d(0, 3 + lb, A);
    if (f === 1) { d(-w - 2, 2, K.WHITE); d(-w - 3, 3, K.WHITE); d(w + 2, 2, K.WHITE); d(w + 3, 3, K.WHITE); }
    if (f === 2) { d(-w - 4, 4, K.WHITE); d(w + 4, 4, K.WHITE); d(-w - 3, 1, K.WHITE); d(w + 3, 1, K.WHITE); }
  });
  /* mischief-monkey */
  PFA.glyph('L03-swing', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a monkey hanging by its tail off the edge, swinging: curled tail, body, arms, peach face */
    F(c, x, y, tx, ty, nx, ny, K); var f = fr & 3, sw = (f - 1.5) * 1.1, a1 = sw * .5, a2 = sw;
    d(-1, 1, C); d(0, 1, C); d(1, 2, C); d(a1, 2, C); d(a1, 3, C);
    s(a2, 5, 3, C); d(a2 - 2, 6 - (f & 1), C); d(a2 + 2, 5 + (f & 1), C);
    s(a2 * 1.2, 8, 3, C); d(a2 * 1.2, 8, Hi); d(a2 * 1.2 - 1, 8, Hi); d(a2 * 1.2, 9, Hi); d(a2 * 1.2 - 1, 9, A); d(a2 * 1.2 + 1, 9, A);
    d(a2 * 1.2 - 2, 8, Hi); d(a2 * 1.2 + 2, 8, Hi);
  });
  PFA.glyph('L03-fruit', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a ripe round fruit spinning (highlight goes round), leaf on the stalk; fr 3 = splat */
    F(c, x, y, tx, ty, nx, ny, K); var f = fr & 3;
    if (f === 3) { s(0, 2, 2, C); d(-3, 1, C); d(3, 1, C); d(-2, 3, C); d(2, 4, C); d(0, 5, Hi); d(-4, 2, Hi); d(4, 3, A); return; }
    s(0, 3, 3 + (z >> 1), C); d(-2, 3, C); d(2, 3, C); d(0, 1, C); d(0, 5, C);
    d(R8X[f * 3 & 7] * 1.2, 3 + R8Y[f * 3 & 7] * 1.2, K.WHITE); d(0, 6, A); d(1, 7, LEAF); d(2, 7, LEAF);
  });
  PFA.glyph('L03-grin', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a cheeky monkey face: peach mask, ears; neutral, toothy grin, tongue out, eyebrows up */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, f = fr & 3;
    for (b = 1; b <= 6; b++) for (a = -3; a <= 3; a++) if (!((b === 1 || b === 6) && (a === -3 || a === 3))) d(a, b, C);
    d(-4, 4, Hi); d(4, 4, Hi);
    for (b = 2; b <= 4; b++) for (a = -2; a <= 2; a++) d(a, b, Hi);
    d(-1, 4, A); d(1, 4, A);
    if (f === 3) { d(-2, 6, A); d(-1, 6, A); d(1, 6, A); d(2, 6, A); } else { d(-1, 5, A); d(1, 5, A); }
    if (f === 1) { d(-2, 2, A); d(-1, 2, K.WHITE); d(0, 2, K.WHITE); d(1, 2, K.WHITE); d(2, 2, A); }
    else if (f === 2) { d(-1, 2, A); d(0, 2, TONGUE); d(1, 2, A); d(0, 1, TONGUE); }
    else { d(-1, 2, A); d(0, 2, A); d(1, 2, A); }
  });
  PFA.glyph('L03-loot', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a small pinching hand holding the loot of the moment: a coin, a key, a red hat, a button */
    F(c, x, y, tx, ty, nx, ny, K); var f = fr & 3;
    d(-1, 1, C); d(0, 1, C); d(1, 1, C); d(-1, 2, C); d(1, 2, C); d(0, 2, Hi);
    if (f === 0) { s(0, 4, 3, GOLD); d(-1, 3, K.WHITE); d(1, 5, A); }
    else if (f === 1) { d(0, 3, STEEL); d(0, 4, STEEL); d(0, 5, STEEL); d(-1, 6, STEEL); d(1, 6, STEEL); d(-1, 7, STEEL); d(1, 7, STEEL); d(0, 7, STEEL); d(1, 4, STEEL); }
    else if (f === 2) { d(-2, 3, HATRED); d(-1, 3, HATRED); d(0, 3, HATRED); d(1, 3, HATRED); d(2, 3, HATRED); d(-1, 4, HATRED); d(0, 4, HATRED); d(1, 4, HATRED); d(-1, 5, HATRED); d(0, 5, HATRED); d(1, 5, HATRED); d(0, 4, K.WHITE); }
    else { s(0, 4, 3, Hi); d(0, 4, A); d(-1, 3, K.WHITE); }
  });
  /* mandrill-boss */
  PFA.glyph('L03-mandrill', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a mandrill face: red nose ridge, blue ridged cheeks, orange beard; glare, brows, flared nostrils, fangs */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, f = fr & 3;
    for (a = -3; a <= 3; a++) { d(a, 1, BEARD); if (a > -3 && a < 3) d(a, 0, BEARD); }
    for (b = 2; b <= 6; b++) { d(-3, b, Hi); d(-2, b, b & 1 ? A : Hi); d(-1, b, Hi); d(1, b, Hi); d(2, b, b & 1 ? A : Hi); d(3, b, Hi); }
    for (b = 2; b <= 7; b++) d(0, b, C);
    if (f === 2) { d(-1, 2, C); d(1, 2, C); d(-1, 3, C); d(1, 3, C); }
    d(-2, 7, GOLD); d(2, 7, GOLD); d(-1, 7, A); d(1, 7, A);
    if (f === 1) { d(-2, 7, A); d(2, 7, A); }
    for (a = -2; a <= 2; a++) d(a, 8, A); d(0, 9, C);
    if (f === 3) { d(-1, 1, K.WHITE); d(1, 1, K.WHITE); d(-1, 0, K.WHITE); d(1, 0, K.WHITE); }
  });
  PFA.glyph('L03-yawn', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a threat yawn: jaws gape wider and wider, two huge white canines, a fang flash */
    F(c, x, y, tx, ty, nx, ny, K); var a, j, f = fr & 3, g = f === 0 ? 0 : f === 1 ? 2 : 4 + (z >> 1);
    for (a = -3; a <= 3; a++) { d(a, 1, C); d(a, 3 + g, C); d(a, 4 + g, A); }
    for (j = 2; j < 3 + g; j++) for (a = -2; a <= 2; a++) d(a, j, j === 2 ? TONGUE : A);
    for (j = 0; j <= Math.min(g, 3); j++) { d(-2, 2 + g - j, K.WHITE); d(2, 2 + g - j, K.WHITE); }
    d(-1, 2, K.WHITE); d(1, 2, K.WHITE);
    if (f === 3) { d(-3, g, K.WHITE); d(-4, g, K.WHITE); d(-3, g - 1, K.WHITE); d(3, 5 + g, Hi); }
  });
  PFA.glyph('L03-thump', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a chest drummed by two fists in turn, blue shock arcs pulsing out */
    F(c, x, y, tx, ty, nx, ny, K); var i, f = fr & 3, l = f & 1, r = (f >> 1) ^ l, R;
    for (i = -3; i <= 3; i++) { d(i, 1, C); d(i, 2, C); if (i > -3 && i < 3) d(i, 3, C); }
    d(-1, 2, A); d(1, 2, A);
    s(-3, 4 + l * 2, 2, A); d(-3, 5 + l * 2, C); s(3, 4 + r * 2, 2, A); d(3, 5 + r * 2, C);
    if (l !== r) { R = 6 + (z >> 1) + f; for (i = 0; i <= 6; i += (f & 1) + 1) d(ARX[i] * R, 1 + ARY[i] * R * .8, Hi); }
  });
  /* bearded-pig */
  PFA.glyph('L03-beard', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a bearded pig head side-on: long pointed snout, pink disc nose, small tusk, a long pale beard swaying */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, f = fr & 3, sw = f === 1 ? 1 : f === 3 ? -1 : 0;
    for (b = 3; b <= 6; b++) for (a = -3; a <= 0; a++) d(a, b, C);
    for (a = 1; a <= 5; a++) { d(a, 4, C); if (a <= 3) d(a, 5, C); }
    d(6, 4, NOSE); d(6, 5, NOSE); d(-1, 5, A); d(-3, 7, C); d(-2, 7, A); d(3, 3, K.WHITE);
    d(-1, 2, Hi); d(0, 2, Hi); d(1, 3, Hi); d(2, 3, Hi); d(-1 + sw, 1, Hi); d(sw, 1, Hi); d(1 + sw, 2, Hi); d(2 + sw, 2, Hi); d(sw, 0, Hi);
  });
  PFA.glyph('L03-plough', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a snout ploughing: a mud bow wave ahead, a dark furrow behind, clods flung up */
    F(c, x, y, tx, ty, nx, ny, K); var j, f = fr & 3;
    s(-3, 4, 3, C); d(-1, 3, C); d(0, 3, C); d(-2, 3, C); d(0, 2, C); d(1, 2, C); d(2, 2, NOSE); d(-3, 6, A);
    d(3, 1, MUD); d(4, 1, MUD); d(4, 2, MUD); d(5, 2, MUD); d(5, 3, MUD); d(6, 1, MUD);
    for (j = 1; j <= 5; j++) d(-j - 2, 1, A);
    d(5 + f, 4 + f, MUD); d(7 - f, 3 + f * 1.4, MUD); d(6, 5 + (f & 1) * 2, Hi);
  });
  PFA.glyph('L03-nuts', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a pile of winged forest nuts growing nut by nut */
    F(c, x, y, tx, ty, nx, ny, K); var i, n = Math.min(5, 2 + (fr & 3) + (z >> 1));
    for (i = 0; i < n; i++) { s(NUTA[i], NUTB[i] + .5, 2, C); d(NUTA[i], NUTB[i], A); }
    i = n - 1; d(NUTA[i] - 1, NUTB[i] + 2, Hi); d(NUTA[i] + 1, NUTB[i] + 2, Hi); d(NUTA[i] - 1, NUTB[i] + 3, Hi); d(NUTA[i] + 1, NUTB[i] + 3, Hi);
  });
  PFA.glyph('L03-bristle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a back ridge whose pale bristles stand up, dark at the tips */
    F(c, x, y, tx, ty, nx, ny, K); var a, i, j, L, a0, f = fr & 3;
    for (a = -4; a <= 4; a++) { d(a, 1, C); if (a > -4 && a < 4) d(a, 2, C); }
    for (i = 0; i < 5; i++) { a0 = (i - 2) * 2; L = 1 + f + (i & 1) + (z >> 1); for (j = 1; j <= L; j++) d(a0 + (i - 2) * j * .2, 2 + j, j === L ? A : Hi); }
  });

  /* ---------- motions (mutate the scratch G; pp = time x speed, k = slot, ph = slot hash) ---------- */
  PFA.motion('L03-creep', function (G, pp, k, ph) { var w = pp * 1.6 + ph, u = w % 1; G.s += (Math.floor(w) + Math.min(1, u * 2)) * .05; G.fr = u < .5 ? (Math.floor(pp * 16) + k) & 1 : 0; G.d -= 1; });   /* step, step, freeze */
  PFA.motion('L03-arc', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.up += Math.sin(w * Math.PI) * 7; G.t += w * 4; G.fr = (w > .15 && w < .85) ? 1 : 0; });             /* crouch, leap, land */
  PFA.motion('L03-swipe', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 2 + ph) % 1) * 4.5)); G.t += G.fr * 1.2; });
  PFA.motion('L03-dapple', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 4) + k) & 3; G.t += Math.sin(pp * 4 + k) * 1.5; });
  PFA.motion('L03-stomp', function (G, pp, k, ph) { var u = (pp * 1.4 + ph) % 1; G.fr = u < .35 ? 0 : u < .5 ? 1 : u < .8 ? 2 : 3; });
  PFA.motion('L03-lick', function (G, pp, k, ph) { G.fr = Math.floor(pp * 5 + ph * 2) & 3; });
  PFA.motion('L03-hobble', function (G, pp, k) { G.s += pp * .12; G.fr = (Math.floor(pp * 6) + k) & 1; G.up += G.fr; G.t += G.fr ? 0 : .8; });
  PFA.motion('L03-blink', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .12 ? 0 : u < .22 ? 1 : u < .75 ? 2 : 3; });
  PFA.motion('L03-sheen', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 10 + ph * 4) + k) & 3; G.up += Math.sin(pp * 3 + k) * .8; });
  PFA.motion('L03-pour', function (G, pp, k) { G.fr = (Math.floor(pp * 14) + k) & 3; G.d -= 1; });
  PFA.motion('L03-crunch', function (G, pp, k, ph) { var u = (pp * 2.4 + ph) % 1; G.fr = u < .4 ? 1 : u < .55 ? 0 : u < .8 ? 2 : 3; });
  PFA.motion('L03-billow', function (G, pp, k, ph) { G.t += Math.sin(pp * 4 + ph * 6) * 3; G.up += Math.sin(pp * 3 + k) * 1.5; G.fr = (Math.floor(pp * 6) + k) & 3; });
  PFA.motion('L03-flick', function (G, pp, k, ph) { G.fr = Math.floor((Math.sin(pp * 7 + k + ph * 3) + 1) * 1.99); });
  PFA.motion('L03-grip', function (G, pp, k, ph) { G.fr = Math.floor(pp * 8 + ph * 4) & 3; });
  PFA.motion('L03-fade', function (G, pp, k, ph) { G.fr = Math.floor((Math.sin(pp * 5 + ph * 6) + 1) * 1.99); });
  PFA.motion('L03-frost', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.6 + ph) % 1) * 4.5)); });
  PFA.motion('L03-appear', function (G, pp, k, ph) { var u = (pp * 1.5 + ph) % 1; G.fr = u < .15 ? 0 : u < .3 ? 1 : u < .7 ? 2 : 3; });
  PFA.motion('L03-twitch', function (G, pp, k, ph) { var u = (pp * 3 + ph) % 1; G.fr = u > .75 ? 1 + (k & 1) : (u > .6 && u < .68) ? 3 : 0; });
  PFA.motion('L03-spring', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; if (w < .35) { G.fr = 0; G.d -= 1; } else { G.fr = 1; G.up += Math.sin((w - .35) / .65 * Math.PI) * 9; G.t += (w - .35) * 6; } });
  PFA.motion('L03-hook', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .3 ? 0 : u < .55 ? 1 : u < .8 ? 2 : 3; G.t += G.fr * .8; });
  PFA.motion('L03-press', function (G, pp, k, ph) { var u = (pp * 1.5 + ph) % 1; G.fr = u < .3 ? 0 : u < .45 ? 1 : u < .8 ? 2 : 3; });
  PFA.motion('L03-swing', function (G, pp, k, ph) { var w = Math.sin(pp * 8 + ph * 6); G.fr = Math.floor((w + 1) * 1.99); G.t += w * 2; });
  PFA.motion('L03-lob', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.up += Math.sin(w * Math.PI) * 9; G.t += w * 5; G.fr = w > .88 ? 3 : (Math.floor(pp * 12) + k) % 3; });
  PFA.motion('L03-mug', function (G, pp, k, ph) { G.fr = Math.floor(pp * 6 + ph * 4) & 3; G.t += G.fr === 2 ? 1 : 0; G.up += G.fr === 3 ? 1 : 0; });
  PFA.motion('L03-pilfer', function (G, pp, k, ph) { var w = pp * 2.2 + ph, u = w % 1; G.fr = (k + Math.floor(w)) & 3; if (u > .55) { G.d -= 2; G.t -= 2; } });
  PFA.motion('L03-glare', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 7 + ph * 4) + k) & 3; });
  PFA.motion('L03-yawn', function (G, pp, k, ph) { var u = (pp * 1.8 + ph) % 1; G.fr = u < .25 ? 0 : u < .45 ? 1 : u < .8 ? 2 : 3; });
  PFA.motion('L03-drum', function (G, pp, k) { G.fr = (Math.floor(pp * 12) + k) & 3; });
  PFA.motion('L03-root', function (G, pp, k) { G.t += Math.sin(pp * 10 + k) * 1.2; G.fr = (Math.floor(pp * 8) + k) & 3; });
  PFA.motion('L03-plough', function (G, pp, k) { G.s += pp * .25; G.fr = (Math.floor(pp * 12) + k) & 3; G.d -= 1; });
  PFA.motion('L03-pile', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 5 + ph * .5)); G.d -= 1; });
  PFA.motion('L03-raise', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 2 + ph) % 1) * 4.5)); });

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh; pixel counts capped) ---------- */
  function fade(e, H, t) { return e.p > .85 && H.hash(t + Math.floor(e.p * 40)) > (1 - e.p) / .15; }
  function head(c, e, H, g, u, f, lift) {       /* draws a glyph at distance u of the path, facing the way of travel */
    var Q = H.Q, sg = e.d < 0 ? -1 : 1; e.P.atq(e.a + e.d * u);
    H.glyph(c, g, Q.x + Q.nx * (4 + lift), Q.y + Q.ny * (4 + lift), e.z, f, e.col, e.acc, e.hi, -Q.ny * sg, Q.nx * sg, Q.nx, Q.ny);
  }
  function carStalk(c, e, H) {          /* the tiger stalks round the outer edge: steps, freezes, steps; a line of dark pug marks behind it */
    var P = e.P, Q = H.Q, k, u, w = e.hh * 4, mv = (w % 1) < .6;
    for (k = 1; k <= 6; k++) { u = e.hh - k * .07; if (u < 0) break; if (fade(e, H, k)) continue; P.atq(e.a + e.d * u);
      H.px(c, Q.x + Q.nx * (2 + (k & 1) * 2), Q.y + Q.ny * (2 + (k & 1) * 2), e.acc); H.px(c, Q.x + Q.nx * (3 + (k & 1) * 2), Q.y + Q.ny * (3 + (k & 1) * 2), e.col); }
    head(c, e, H, 'L03-stripe', e.hh, mv ? Math.floor(e.p * 16) & 1 : 0, 0);
  }
  function carElder(c, e, H) {          /* four huge scarred prints stamped one by one along the outer edge, a dust burst under the newest, a dragged line between */
    var P = e.P, Q = H.Q, k, u, j;
    for (k = 1; k <= 4; k++) { u = k / 4; if (e.hh < u - .001) break;
      if (k > 1) for (j = 1; j < 6; j++) { if (fade(e, H, k * 7 + j)) continue; P.atq(e.a + e.d * (u - j * .04)); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.hi); }
      head(c, e, H, 'L03-elderpaw', u, e.hh - u < .08 ? 1 : 2, -1); }
    if (e.hh < .98) head(c, e, H, 'L03-elderpaw', e.hh, 0, -1);
  }
  function carEyes(c, e, H) {           /* only eyes travel: pairs of yellow eyes open along the outer edge, each shutting as the next one opens */
    var k, u, g;
    for (k = 1; k <= 5; k++) { u = k / 5; g = e.hh - u; if (g < -.02 || g > .3) continue;
      head(c, e, H, 'L03-eyes', u, g < .02 ? 1 : g < .2 ? 2 : g < .26 ? 1 : 0, 0); }
    if (e.hh > .97) head(c, e, H, 'L03-eyes', 1, 3, 0);
  }
  function carTail(c, e, H) {           /* the long ringed tail is draped along the outer edge to the next piece, the tip hooking at the head */
    var P = e.P, Q = H.Q, u, i = 0, t0 = Math.max(0, e.hh - .55);
    for (u = t0; u <= e.hh; u += .02) { i++; if (fade(e, H, i)) continue; P.atq(e.a + e.d * u);
      H.sq(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4, 2, ((i >> 1) & 1) ? e.acc : e.col); }
    head(c, e, H, 'L03-tail', e.hh, Math.floor((Math.sin(e.p * 14) + 1) * 1.99), -2);
  }
  function carGhost(c, e, H) {          /* paw prints appear one after another along the outer edge with nothing making them; the old ones dither away */
    var k, u, g, f;
    for (k = 1; k <= 7; k++) { u = k / 7; g = e.hh - u; if (g < 0 || g > .45) continue; if (fade(e, H, k)) continue;
      f = g < .05 ? 1 : g < .25 ? 2 : 3; head(c, e, H, 'L03-gprint', u, f, (k & 1) * 3 - 2); }
  }
  function carBrachiate(c, e, H) {      /* the monkey swings hand over hand along the outer edge, three arcs, a vine laid behind it */
    var P = e.P, Q = H.Q, u, i = 0, ar = Math.abs(Math.sin(e.hh * Math.PI * 3));
    for (u = 0; u <= e.hh; u += .03) { i++; if (fade(e, H, i)) continue; P.atq(e.a + e.d * u);
      H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, VINE); if ((i % 6) === 0) H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, LEAF); }
    head(c, e, H, 'L03-swing', e.hh, Math.floor((Math.sin(e.p * 18) + 1) * 1.99), ar * 7);
  }
  function carCharge(c, e, H) {         /* the painted face charges round the outer edge: red and blue streaks behind it, dust kicked up, a fang flash on arrival */
    var P = e.P, Q = H.Q, k, u;
    for (k = 1; k <= 8; k++) { u = e.hh - k * .03; if (u < 0) break; P.atq(e.a + e.d * u);
      H.px(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4, e.col); H.px(c, Q.x + Q.nx * 7, Q.y + Q.ny * 7, e.hi);
      if (k > 4 && (k & 1)) H.sq(c, Q.x + Q.nx * (3 + k * .5), Q.y + Q.ny * (3 + k * .5) - k * .5, 2, DUST); }
    head(c, e, H, 'L03-mandrill', e.hh, e.hh > .9 ? 3 : 1, 0);
  }
  function carFurrow(c, e, H) {         /* a dark furrow is ploughed along the outer edge, ridges of mud either side, the snout and its bow wave at the head */
    var P = e.P, Q = H.Q, u, i = 0;
    for (u = 0; u <= e.hh; u += .025) { i++; if (fade(e, H, i)) continue; P.atq(e.a + e.d * u);
      H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.acc); if (i & 1) { H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, MUD); H.px(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5, MUD); } }
    head(c, e, H, 'L03-plough', e.hh, Math.floor(e.p * 12) & 3, -1);
  }

  /* ---------- motifs ---------- */
  PFA.motif('tiger-stripe', plain, { nm: 'stalking stripes', desc: 'a low orange tiger body with slanted black stripes, white belly and black-tipped tail, stepping then freezing as it stalks; the chain is the tiger stalking round the edge, pug marks behind', fam: 'slash', gap: 18, g: 'L03-stripe', mo: 'L03-creep', x: '-', car: 'custom', carDraw: carStalk });
  PFA.motif('tiger-leap', function (c, e, H) { comp(c, e, H, decoLeaves); }, { nm: 'tiger leaps', desc: 'a striped tiger crouching, then stretched in mid-leap with forepaws reaching; jungle leaves shaken loose drift down', fam: 'slash', gap: 20, g: 'L03-leap', mo: 'L03-arc', x: '-', car: 'hop' });
  PFA.motif('tiger-claw', plain, { nm: 'stripe claws', desc: 'a paw sliding its claws out and raking; the three scars it leaves darken into black tiger stripes', fam: 'slash', gap: 16, g: 'L03-claw', mo: 'L03-swipe', x: '-', car: 'comet' });
  PFA.motif('leaf-dapple', plain, { nm: 'dappled leaves', desc: 'broad jungle leaves with a dark midrib swaying, sun flecks blinking through round them', fam: 'leaf', gap: 14, g: 'L03-dapple', mo: 'L03-dapple', x: '-', car: 'flutter' });
  PFA.motif('elder-paw', plain, { nm: 'elder paws', desc: 'a huge old paw lifting and stamping down, a pale scar across its pad, a grey dust burst; the chain stamps four great prints along the edge with a dragged line between', fam: 'bash', gap: 18, g: 'L03-elderpaw', mo: 'L03-stomp', x: '-', car: 'custom', carDraw: carElder });
  PFA.motif('scar-lick', plain, { nm: 'scar licks', desc: 'a stitched pale scar; a pink tongue licks along it, the scar shortens and a plus rises', fam: 'mend', gap: 16, g: 'L03-lick', mo: 'L03-lick', x: '-', car: 'trail' });
  PFA.motif('limp-track', plain, { nm: 'limping tracks', desc: 'uneven tracks: one firm print, one dragged hind print smearing a line behind it, hobbling along', fam: 'puff', gap: 14, g: 'L03-limp', mo: 'L03-hobble', x: '-', car: 'train' });
  PFA.motif('jaguar-eyes', plain, { nm: 'eyes in the dark', desc: 'a black head you can barely see, faint rosette sheen, only the yellow slit eyes opening and blinking; the chain is pairs of eyes opening one after another round the edge', fam: 'puff', gap: 16, g: 'L03-eyes', mo: 'L03-blink', x: '-', car: 'custom', carDraw: carEyes });
  PFA.motif('rosette-sheen', plain, { nm: 'sheen rosettes', desc: 'broken rosette rings showing in the sheen of a black coat round a dark core, a white glint going round', fam: 'shield', gap: 14, g: 'L03-rosette', mo: 'L03-sheen', x: '-', car: 'blink' });
  PFA.motif('rain-streak', function (c, e, H) { comp(c, e, H, decoPuddle); }, { nm: 'downpours', desc: 'rain streaks falling past the edge, splash crowns and puddle rings where they land', fam: 'ripple', gap: 12, g: 'L03-rain', mo: 'L03-pour', x: '-', car: 'cloud' });
  PFA.motif('jaguar-fang', plain, { nm: 'skull-crack fangs', desc: 'dark jaws with two big white fangs gaping, slamming shut and crunching, crack marks either side', fam: 'bite', gap: 16, g: 'L03-fang', mo: 'L03-crunch', x: '-', car: 'comet' });
  PFA.motif('cloud-blotch', plain, { nm: 'cloud blotches', desc: 'clouded-leopard blotches: cloud shapes with a dark rim and dark freckles, billowing and drifting like clouds', fam: 'puff', gap: 16, g: 'L03-cloud', mo: 'L03-billow', x: 'haze', car: 'cloud' });
  PFA.motif('long-tail', plain, { nm: 'long tails', desc: 'a very long thick tail with dark rings swaying out from the edge, the tip hooking; the chain drapes the ringed tail along the edge to the next piece', fam: 'web', gap: 16, g: 'L03-tail', mo: 'L03-flick', x: '-', car: 'custom', carDraw: carTail });
  PFA.motif('ledge-grip', plain, { nm: 'ledge grips', desc: 'two big paws gripping a grey rock ledge, white claws hooked over, pebbles kicked off', fam: 'slash', gap: 18, g: 'L03-grip', mo: 'L03-grip', x: '-', car: 'hop' });
  PFA.motif('ghost-rosette', plain, { nm: 'ghost rosettes', desc: 'pale rosettes drawn only in part, fading to a few pixels and back, a cold blue glint: nearly invisible', fam: 'sparkle', gap: 14, g: 'L03-ghost', mo: 'L03-fade', x: '-', car: 'blink' });
  PFA.motif('rime-pelt', plain, { nm: 'rime pelts', desc: 'frost-stiff fur spikes fanning out, an ice crystal on each tip, the middle one sparkling', fam: 'thorn', gap: 12, g: 'L03-rime', mo: 'L03-frost', x: 'snow', car: 'train' });
  PFA.motif('ghost-prints', plain, { nm: 'ghost prints', desc: 'leopard prints appearing in snow with no cat: faint, pad, full, then dithering away; the chain lays prints round the edge with nothing making them', fam: 'puff', gap: 16, g: 'L03-gprint', mo: 'L03-appear', x: '-', car: 'custom', carDraw: carGhost });
  PFA.motif('lynx-tufts', plain, { nm: 'lynx tufts', desc: 'a lynx face with white side ruffs and tall ears topped by long black tufts that flick one at a time, then both prick up', fam: 'puff', gap: 16, g: 'L03-tufts', mo: 'L03-twitch', x: '-', car: 'hop' });
  PFA.motif('lynx-spring', plain, { nm: 'lynx springs', desc: 'a lynx coiled low, then springing on long hind legs, bobtail up, forepaws reaching', fam: 'slash', gap: 20, g: 'L03-spring', mo: 'L03-spring', x: '-', car: 'hop' });
  PFA.motif('hook-claw', plain, { nm: 'hook claws', desc: 'one long claw off a furry paw curling tighter into a hook, a slash line on the strike', fam: 'thrust', gap: 14, g: 'L03-hook', mo: 'L03-hook', x: '-', car: 'comet' });
  PFA.motif('snowshoe-paw', plain, { nm: 'snowshoe paws', desc: 'a huge furry snowshoe paw lifting, pressing down with snow puffing out sideways, then sinking into the drift', fam: 'bash', gap: 18, g: 'L03-snowshoe', mo: 'L03-press', x: 'snow', car: 'hop' });
  PFA.motif('monkey-swing', plain, { nm: 'tail swings', desc: 'a monkey hanging off the edge by its curled tail, swinging, peach face, arms out; the chain swings hand over hand along the edge, a vine laid behind', fam: 'puff', gap: 16, g: 'L03-swing', mo: 'L03-swing', x: '-', car: 'custom', carDraw: carBrachiate });
  PFA.motif('fruit-lob', plain, { nm: 'lobbed fruit', desc: 'ripe round fruit with a leaf on the stalk, spinning in a lob, splatting when it lands', fam: 'bash', gap: 14, g: 'L03-fruit', mo: 'L03-lob', x: '-', car: 'roll' });
  PFA.motif('cheeky-face', plain, { nm: 'cheeky faces', desc: 'a monkey face with a peach mask pulling faces: a toothy grin, a tongue out, eyebrows up', fam: 'thorn', gap: 16, g: 'L03-grin', mo: 'L03-mug', x: '-', car: 'blink' });
  PFA.motif('pinch-loot', plain, { nm: 'pinched loot', desc: 'a small pinching hand that dips in and comes back with loot: a gold coin, a key, a little red hat, a button', fam: 'web', gap: 14, g: 'L03-loot', mo: 'L03-pilfer', x: '-', car: 'zig' });
  PFA.motif('mandrill-face', plain, { nm: 'painted faces', desc: 'a mandrill face: red nose ridge, blue ridged cheeks, orange beard; glaring, brows down, nostrils flared, fangs; the chain is the face charging round the edge in red and blue streaks', fam: 'bash', gap: 18, g: 'L03-mandrill', mo: 'L03-glare', x: '-', car: 'custom', carDraw: carCharge });
  PFA.motif('fang-yawn', plain, { nm: 'threat yawns', desc: 'a threat yawn: jaws gaping wider and wider over a pink gum, two huge white canines, a fang flash', fam: 'thrust', gap: 16, g: 'L03-yawn', mo: 'L03-yawn', x: '-', car: 'comet' });
  PFA.motif('chest-thump', plain, { nm: 'chest thumps', desc: 'a chest drummed by two fists in turn, blue shock arcs pulsing out with each blow', fam: 'thorn', gap: 16, g: 'L03-thump', mo: 'L03-drum', x: '-', car: 'rings' });
  PFA.motif('beard-snout', plain, { nm: 'bearded snouts', desc: 'a bearded pig head side-on: long pointed snout with a pink disc nose, a small tusk, a long pale beard swaying under the cheek', fam: 'bash', gap: 18, g: 'L03-beard', mo: 'L03-root', x: '-', car: 'train' });
  PFA.motif('mud-plough', plain, { nm: 'mud ploughs', desc: 'a snout ploughing the ground: a mud bow wave ahead, a dark furrow behind, clods flung up; the chain ploughs a furrow round the edge', fam: 'bash', gap: 16, g: 'L03-plough', mo: 'L03-plough', x: 'clods', car: 'custom', carDraw: carFurrow });
  PFA.motif('nut-pile', plain, { nm: 'nut piles', desc: 'winged forest nuts piling up nut by nut into a little heap', fam: 'shield', gap: 14, g: 'L03-nuts', mo: 'L03-pile', x: '-', car: 'roll' });
  PFA.motif('bristle-ridge', plain, { nm: 'bristle ridges', desc: 'a back ridge whose pale bristles stand up stroke by stroke, dark at the tips', fam: 'thorn', gap: 14, g: 'L03-bristle', mo: 'L03-raise', x: '-', car: 'train' });
})();
