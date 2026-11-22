/* Motif module, large batch L02 (black-bear, sloth-bear, ice-bear, glacier-bear, raccoon, crab-eating-raccoon, honey-badger-brute, aardvark,
   giant-anteater, beaver-foreman). TEMPLATE.md sections 9 and 10.3.
   29 motifs, each with its own pixel glyph (ids prefixed L02-) and motion; seven have their own chain effect (carDraw).
   Large creatures fight on the 5x5 board (cells 40 x 34): glyphs reach up to ~10 px off the edge, a little bigger than small/medium, still inside ~22 px.
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation inside the frame loops (module-level scratch frame
   and constant tables built once at load). Glyphs go through H.glyph so the MAXG budget counts them; custom chain effects cap their pixels.
   The wiggle (x 2.6 px / rot .06), the outer-edge chain rule, visual-only sound lines and the creature-heavy default are untouched (they live in the page). */
(function () {
  /* ---------- constant tables and colours (built once) ---------- */
  var CRK = [0, 1, 0, -1, -1, 0, 1, 1];          /* crack zigzag (normal offsets) */
  var ICL = [3, 5, 2];                           /* icicle beard: three icicles of different length */
  var BLW = [4, 5, 4, 3], BLH = [3, 2, 3, 4];    /* blubber jiggle: width / height per frame (squash and stretch) */
  var FLAP = [0, 1, 2, 1];                       /* ear flap angle steps (ping-pong) */
  var TFL = [0, 1, 2, 3, 3, 2, 1, 0];            /* tongue flick in and out */
  var KCV = [-1, .1, .45];                       /* anteater claws: folded (knuckle walk), open, hugging */
  var TAILB = [7, 5, 2, 1];                      /* beaver tail height per slap frame */
  var HB = [0, 1, 2, 1];                         /* crew head bob */
  var TERM = '#e8b868', CRAB = '#e8583c', BEE = '#f0c838', SOIL = '#b0805a', CLAY = '#d0904e', WOOD = '#dcae74', TONGUE = '#f48cab', WATER = '#8cc8e8', DUST = '#c8b494';

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
  function decoCrevasse(c, e, H, s0, len, ri, pp) {    /* crevasse-paw: a blue crack opens along the edge under the prints */
    var t, u = H.eo(Math.min(1, e.p * 1.5)), Q = H.Q, i = 0;
    if (e.p > .9) return;
    for (t = 0; t < len * u; t += 2) { e.P.atq(s0 + t); H.px(c, Q.x + Q.nx * (2 + CRK[i++ & 7] * .7), Q.y + Q.ny * (2 + CRK[(i + 3) & 7] * .7), (t + Math.floor(pp * 16)) % 12 < 2 ? H.WHITE : e.hi); }
  }
  function decoRipple(c, e, H, s0, len, ri, pp) {      /* tail-slap / crew-heads: water rings spread along the edge */
    var k, u, Q = H.Q;
    for (k = 0; k < 2; k++) { u = (pp * 1.4 + k * .5) % 1; if (e.p > .92) break; e.P.atq(s0 + len * (k + .5) / 2);
      H.ringpx(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4, 1 + u * 5, u < .6 ? WATER : e.hi); }
  }

  /* ---------- glyphs (C main, A dark, Hi highlight; tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step) ---------- */
  PFA.glyph('L02-rake', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* four parallel claw-rake scars that lengthen stroke by stroke, pale wood at the root */
    F(c, x, y, tx, ty, nx, ny, K); var i, j, L = 3 + fr * 2 + z, a0;
    for (i = 0; i < 4; i++) { a0 = (i - 1.5) * 2.4; for (j = 0; j <= L; j++) d(a0 + j * .35, j + 1, j < 2 ? Hi : C); if (fr === 3) d(a0 + (L + 1) * .35, L + 2, K.WHITE); }
  });
  PFA.glyph('L02-rear', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a black bear reared up on its hind legs, tan muzzle, forepaws up or down */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, T = 6 + (z >> 1), up = fr & 1;
    for (b = 1; b <= T; b++) for (a = -2; a <= 2; a++) if (!(b === T && (a === -2 || a === 2))) d(a, b, C);
    for (a = -1; a <= 1; a++) { d(a, T + 1, C); d(a, T + 2, C); }
    d(-2, T + 3, C); d(2, T + 3, C); d(0, T + 1, Hi); d(0, T + 2, Hi); d(-1, T + 2, A); d(1, T + 2, A);
    if (up) { for (b = T - 2; b <= T + 2; b++) { d(-3, b, C); d(3, b, C); } d(-4, T + 3, Hi); d(-3, T + 3, Hi); d(3, T + 3, Hi); d(4, T + 3, Hi); }
    else { d(-3, 3, C); d(-3, 4, C); d(3, 3, C); d(3, 4, C); d(-3, 2, Hi); d(3, 2, Hi); }
  });
  PFA.glyph('L02-shag', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a shaggy black mane tuft fanning out, the pale chest V at its root */
    F(c, x, y, tx, ty, nx, ny, K); var i, j, a, L;
    for (i = 0; i < 5; i++) { a = (i - 2) * 2; L = 4 + ((i & 1) ? 1 : 2) + fr + z;
      for (j = 1; j <= L; j++) d(a + Math.sin(j * .9 + i + fr) * .8 + (i - 2) * j * .12, j, j === 1 ? A : C); }
    d(-2, 2, Hi); d(-1, 1, Hi); d(0, 1, Hi); d(1, 1, Hi); d(2, 2, Hi);
  });
  PFA.glyph('L02-nap', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a shaggy ball curled asleep in a hollow, pale V, a Z drifting up (screen-upright) */
    F(c, x, y, tx, ty, nx, ny, K); var zx, zy, w = fr < 2 ? 2 : 3;
    s(0, 3, 5 + (z >> 1), C); d(-3, 2, C); d(3, 2, C); d(-3, 4, C); d(3, 4, C); d(-2, 6, C); d(0, 6, C); d(2, 6, C);
    d(-1, 3, Hi); d(0, 2, Hi); d(1, 3, Hi); d(0, 4, A);
    zx = Math.round(X0 + NX * 7 + fr * 1.5); zy = Math.round(Y0 + NY * 7 - fr * 2 - 2);
    K.bx(c, zx, zy, w, 1, Hi); K.px(c, zx + w - 2, zy + 1, Hi); if (w === 3) K.px(c, zx + 1, zy + 1, Hi); K.bx(c, zx, zy + 2, w, 1, Hi);
  });
  PFA.glyph('L02-sickle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* three long ivory sickle claws curling into a hook off a shaggy paw */
    F(c, x, y, tx, ty, nx, ny, K); var i, j, a, L = 5 + z, cu = .1 + fr * .07;
    s(0, 1, 3, C); d(-2, 1, C); d(2, 1, C);
    for (i = 0; i < 3; i++) { a = (i - 1) * 2; for (j = 1; j <= L; j++) d(a + j * j * cu, 2 + j, j === L ? K.WHITE : Hi); }
  });
  PFA.glyph('L02-hoover', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* sloth-bear face: shaggy head, pale V, a pale tube snout sucking a stream of termites in */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, i, q;
    for (b = 0; b <= 3; b++) for (a = -2; a <= 2; a++) d(a, b, C);
    d(-3, 1 + (fr & 1), C); d(3, 2 - (fr & 1), C); d(-3, 3, C); d(3, 3, C); d(-2, 4, C); d(2, 4, C);
    d(-2, 1, Hi); d(-1, 0, Hi); d(1, 0, Hi); d(2, 1, Hi);
    for (b = 4; b <= 6 + (z >> 1); b++) d(0, b, Hi); d(-1, 4, Hi); d(1, 4, Hi);
    if (fr & 2) { d(-1, 7 + (z >> 1), Hi); d(1, 7 + (z >> 1), Hi); } else d(0, 7 + (z >> 1), K.WHITE);
    for (i = 0; i < 3; i++) { q = (8 - fr + i * 3) % 8; d((i - 1) * q * .45, 9 + q * 1.2, TERM); if (q < 4) d((i - 1) * q * .45 + 1, 9 + q * 1.2, TERM); }
  });
  PFA.glyph('L02-icicle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a rimed fur clump with an icicle beard growing off it, a drip at the long tip */
    F(c, x, y, tx, ty, nx, ny, K); var i, j, a, L;
    s(0, 1, 3, C); d(-2, 1, C); d(2, 1, C); d(-3, 2, C); d(3, 2, C);
    for (i = 0; i < 3; i++) { a = (i - 1) * 2; L = ICL[i] + fr + z; d(a + 1, 3, Hi);
      for (j = 0; j <= L; j++) d(a, 3 + j, j < L - 1 ? Hi : K.WHITE); }
    if (fr === 3) s(0, 3 + ICL[1] + 3 + z + 2, 2, K.DEW);
  });
  PFA.glyph('L02-drift', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a snowdrift mound heaping up, blue shadow at its foot, a sparkle on top */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, w, Hh = 1 + fr + (z >> 1), W = 4 + z, q;
    for (b = 0; b <= Hh; b++) { q = b / (Hh + 1); w = Math.round(W * (1 - q * q)); for (a = -w; a <= w; a++) d(a, b + 1, b === 0 ? Hi : C); }
    d(fr - 1, Hh + 1, K.WHITE);
  });
  PFA.glyph('L02-bigpaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a huge silver-blue paw print stamping down, blue cracks branching from the pad */
    F(c, x, y, tx, ty, nx, ny, K); var j, n, lift = fr === 0 ? 2 : 0;
    if (fr === 0) { d(-3, 8 + lift, Hi); d(-1, 9 + lift, Hi); d(1, 9 + lift, Hi); d(3, 8 + lift, Hi); s(0, 3 + lift, 3, C); return; }
    s(0, 3, 4 + (z >> 1), C); d(-2, 1, C); d(-1, 1, C); d(0, 1, C); d(1, 1, C);
    s(-3, 6, 2, C); s(-1, 7, 2, C); s(1, 7, 2, C); s(3, 6, 2, C); d(-3, 8, Hi); d(-1, 9, Hi); d(1, 9, Hi); d(3, 8, Hi);
    n = (fr - 1) * 3; for (j = 1; j <= n; j++) { d(-3 - j, 2 + (j & 1), Hi); d(3 + j, 2 + ((j >> 1) & 1), Hi); } if (fr === 3) { d(0, 0, K.WHITE); d(-6, 1, K.WHITE); }
  });
  PFA.glyph('L02-shadow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a small silver bear casting a long dark shadow stretched along the snow */
    F(c, x, y, tx, ty, nx, ny, K); var j, L = 6 + fr * 2 + z;
    for (j = 1; j <= L; j++) { d(-j - 1, 1, A); if (((j + fr) & 1) === 0) d(-j - 1, 2, C); } d(-L - 2, 2, A); d(-L - 2, 3, C);
    s(0, 2, 3, C); d(0, 4, C); d(1, 4, C); d(-1, 4, Hi); d(1, 5, C); d(-1, 5, C);
  });
  PFA.glyph('L02-roar', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a roaring bear head, jaws open, roar arcs going out and ice chunks calving off */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, R = 6 + fr * 2;
    for (b = 1; b <= 4; b++) for (a = -2; a <= 2; a++) d(a, b, C); d(-3, 4, C); d(3, 4, C); d(-1, 5, C); d(1, 5, C);
    if (fr > 0) { d(0, 5, A); d(-1, 6, C); d(1, 6, C); d(0, 6, A); d(-1, 5, Hi); d(1, 5, Hi); } else d(0, 5, C);
    d(-1, 3, A); d(1, 3, A);
    for (a = -2; a <= 2; a++) d(a * 1.3, R + 2 - Math.abs(a) * .6, Hi);
    if (fr >= 2) for (a = -2; a <= 2; a += 2) d(a * 1.6, R + 5 - Math.abs(a) * .6, K.WHITE);
    s(-4 - fr, 2 - fr * .5, 2, K.WHITE); s(4 + fr, 3 - fr * .7, 2, Hi);
  });
  PFA.glyph('L02-blubber', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a thick fat hump that squashes and stretches, a sheen on top */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, w, W = BLW[fr] + (z >> 1), Hh = BLH[fr] + (z >> 1), q;
    for (b = 1; b <= Hh; b++) { q = (b - .5) / Hh; w = Math.round(W * Math.sqrt(Math.max(0, 1 - q * q))); for (a = -w; a <= w; a++) d(a, b, b === Hh ? Hi : C); }
    d(-1, Hh, K.WHITE); d(-W, 1, A); d(W, 1, A);
  });
  PFA.glyph('L02-mask', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a raccoon face peeking up: black bandit mask, white brows and muzzle, eye glints */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, sh = fr === 0 ? -2 : 0, eye = fr === 2 ? A : K.WHITE;
    for (b = 1; b <= 4; b++) { if (b + sh < 1) continue; for (a = -3; a <= 3; a++) if (!(b === 4 && (a === -3 || a === 3))) d(a, b + sh, b === 3 ? A : C); }
    d(-2, 5 + sh, C); d(2, 5 + sh, C); d(-2, 6 + sh, A); d(2, 6 + sh, A);
    if (2 + sh >= 1) { d(-3, 2 + sh, A); d(-2, 2 + sh, A); d(2, 2 + sh, A); d(3, 2 + sh, A); }
    d(-1, 3 + sh, eye); d(1, 3 + sh, eye); d(-2, 4 + sh, Hi); d(2, 4 + sh, Hi);
    if (sh === 0) { d(-1, 1, Hi); d(0, 1, A); d(1, 1, Hi); d(0, 2, Hi); }
  });
  PFA.glyph('L02-ringtail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a bushy ringed tail swishing, dark and pale bands, dark tip */
    F(c, x, y, tx, ty, nx, ny, K); var j, ang = 0, ta = 0, tb = 1, bend = (fr - 1.5) * .2, w = 2 + (z >> 1);
    for (j = 0; j < 9; j++) { ang += bend; ta += Math.sin(ang) * 1.1; tb += Math.cos(ang) * 1.1; s(ta, tb, j > 6 ? 2 : w, j === 8 ? A : ((j >> 1) & 1) ? A : C); if (((j >> 1) & 1) === 0) d(ta, tb, Hi); }
  });
  PFA.glyph('L02-hand', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a raccoon's little five-fingered hand, spread, then closing on a grab */
    F(c, x, y, tx, ty, nx, ny, K); var f, j, fa, L, r;
    s(0, 2, 3 + (z >> 1), C); d(0, 2, A);
    for (f = 0; f < 5; f++) { fa = (f - 2) * (fr ? .3 : .45); L = (f === 0 ? 2 : 3) - (fr ? 1 : 0) + (z >> 1);
      for (j = 1; j <= L; j++) { r = 1.6 + j; d(Math.sin(fa) * r, 2 + Math.cos(fa) * r, j === L ? Hi : C); } }
  });
  PFA.glyph('L02-crabpaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a wet grey hand holding a red crab: dunk it, lift it dripping, crack the shell */
    F(c, x, y, tx, ty, nx, ny, K); var a, o = fr === 1 ? -2 : 0, sp = fr === 3 ? 1 : 0;
    s(0, 2, 3, C); d(-2, 3, C); d(2, 3, C);
    for (a = -2; a <= 2; a++) { d(a + (a < 0 ? -sp : a > 0 ? sp : 0), 5 + o, CRAB); d(a + (a < 0 ? -sp : a > 0 ? sp : 0), 6 + o, CRAB); }
    d(-3 - sp, 7 + o, CRAB); d(3 + sp, 7 + o, CRAB); d(-4 - sp, 8 + o, CRAB); d(4 + sp, 8 + o, CRAB); d(-1, 7 + o, K.WHITE); d(1, 7 + o, K.WHITE);
    d(-3, 4 + o, A); d(3, 4 + o, A);
    if (fr === 1) K.ringpx(c, X0 + NX * 5, Y0 + NY * 5, 4, Hi);
    else if (fr === 2) { d(-1, 3, K.DEW); d(1, 2, K.DEW); d(0, 0, K.DEW); }
    else if (fr === 3) { d(0, 9, K.WHITE); d(-2, 10, K.WHITE); d(2, 10, K.WHITE); d(0, 5, K.WHITE); }
  });
  PFA.glyph('L02-spray', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a spiky wet-fur clump shaking, a fan of drops flung off */
    F(c, x, y, tx, ty, nx, ny, K); var i, an, r = 4 + fr * 2.2, o = (fr & 1) ? 1 : -1;
    s(o, 2, 3, C); d(o - 2, 3, C); d(o + 2, 3, C); d(o, 4, C); d(o - 1, 4, Hi); d(o + 1, 1, C);
    for (i = 0; i < 6; i++) { an = (i - 2.5) * .45; d(Math.sin(an) * r, 2 + Math.cos(an) * r, (i & 1) ? K.DEW : Hi); if (fr < 2) d(Math.sin(an) * (r - 1), 2 + Math.cos(an) * (r - 1), K.DEW); }
  });
  PFA.glyph('L02-cape', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* honey badger side-on: black body, silver cape over back and head, jaws open on a charge */
    F(c, x, y, tx, ty, nx, ny, K); var a, st = fr & 1, bite = fr & 2;
    for (a = -4; a <= 3; a++) { d(a, 1, A); d(a, 2, A); d(a, 3, C); d(a, 4, C); }
    d(-3, 5, C); d(-1, 5, C); d(1, 5, Hi); d(4, 1, A); d(4, 2, A); d(4, 3, C); d(5, 2, A); d(5, 3, C);
    d(-5, 4, C); d(-6, 5, A); d(-3 + st, 0, A); d(-2 - st, 0, A); d(2 + st, 0, A); d(1 - st, 0, A);
    if (bite) { d(6, 3, Hi); d(6, 1, K.WHITE); d(7, 3, K.WHITE); d(1, 8, Hi); d(0, 9, Hi); d(2, 9, Hi); }
  });
  PFA.glyph('L02-shrug', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a silver cape hump with bees diving at it and bouncing off, bent stingers */
    F(c, x, y, tx, ty, nx, ny, K); var a, h, bb, ba;
    for (a = -3; a <= 3; a++) { h = Math.round(3 - a * a / 4); d(a, h + 1, C); d(a, h, C); if (h > 1) d(a, h - 1, A); }
    bb = fr === 0 ? 10 : fr === 1 ? 6 : fr === 2 ? 9 : 8; ba = fr < 2 ? 1 : fr === 2 ? 3 : 5;
    d(ba, bb, BEE); d(ba + 1, bb, BEE); d(ba, bb + 1, A); d(ba - 1, bb + 1, K.WHITE); d(ba + 1, bb + 1, K.WHITE);
    if (fr === 1) KK.plus(c, X0 + NX * 5 + TX, Y0 + NY * 5 + TY, 1, 1, K.WHITE);
    if (fr === 3) { d(ba - 1, bb - 2, A); d(ba - 2, bb - 2, Hi); }
    d(-ba, bb + 2 - fr, BEE); d(-ba - 1, bb + 2 - fr, A);
  });
  PFA.glyph('L02-snout', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* aardvark: a pink-grey tube snout poking out of a soil mound, long ears behind, nose disc snuffling */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, L = 3 + fr + (z >> 1), w = (fr & 1) ? 1 : 0;
    for (a = -3; a <= 3; a++) d(a, 1, SOIL); for (a = -2; a <= 2; a++) d(a, 2, SOIL);
    d(-3, 3, C); d(-3, 4, C); d(-3, 5, Hi); d(3, 3, C); d(3, 4, C); d(3, 5, Hi);
    for (b = 2; b <= 2 + L; b++) { d(w * (b - 2) * .2, b, C); d(1 + w * (b - 2) * .2, b, C); }
    s(.5 + w * L * .2, 3 + L, 2, Hi); d(w * L * .2, 3 + L, A);
  });
  PFA.glyph('L02-ears', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* two long pink-lined ears flapping like fans */
    F(c, x, y, tx, ty, nx, ny, K); var i, j, sg, an, L = 6 + z;
    s(0, 1, 3, C);
    for (i = 0; i < 2; i++) { sg = i ? 1 : -1; an = .2 + FLAP[fr] * .22;
      for (j = 1; j <= L; j++) { d(sg * (1 + Math.sin(an) * j), 2 + Math.cos(an) * j, C); if (j > 1 && j < L) d(sg * (2 + Math.sin(an) * j), 2 + Math.cos(an) * j, Hi); } }
  });
  PFA.glyph('L02-mound', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a clay termite mound spire that cracks and bursts, chunks and termites flying */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, w, Hh = 6 + z, top = fr >= 2 ? Hh - 2 : Hh;
    for (b = 1; b <= top; b++) { w = Math.round((Hh - b) * .45); for (a = -w; a <= w; a++) d(a, b, CLAY); }
    d(0, 3, A); d(1, 4, A); d(0, 5, A);
    if (fr >= 2) { s(-2 - fr, Hh - fr + 2, 2, CLAY); s(2 + fr, Hh - fr + 3, 2, CLAY); d(-1, top + 1 + fr, TERM); d(1, top + fr, TERM); d(0, top + 2 + fr, C); }
    if (fr === 1) { d(-1, 2, Hi); d(1, 6, Hi); }
  });
  PFA.glyph('L02-banner', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a huge shaggy fan-shaped anteater tail sweeping like a cloak */
    F(c, x, y, tx, ty, nx, ny, K); var i, j, an, L, th = (fr - 1.5) * .28;
    for (i = 0; i < 7; i++) { an = th + (i - 3) * .3; L = 7 + z - Math.abs(i - 3) * .6;
      for (j = 2; j <= L; j++) d(Math.sin(an) * j, 1 + Math.cos(an) * j, j >= L - .5 ? A : (i === 3 && j < 5) ? Hi : C); }
    d(0, 1, C); d(0, 2, C);
  });
  PFA.glyph('L02-tongue', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a long thin snout, a sticky pink tongue whipping out with ants stuck to it */
    F(c, x, y, tx, ty, nx, ny, K); var j, L = 2 + fr * 3 + z, a;
    d(0, 1, C); d(1, 1, C); d(0, 2, C); d(1, 2, C); d(0, 3, C); d(0, 4, A);
    for (j = 1; j <= L; j++) { a = Math.sin(j * .8 + fr) * .6; d(a, 4 + j, j === L ? Hi : TONGUE); if (j === L - 1 || j === L - 4) d(a + 1, 4 + j, A); }
  });
  PFA.glyph('L02-knuckle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a pale forepaw with a black band and two huge claws: folded, open, hugging */
    F(c, x, y, tx, ty, nx, ny, K); var i, j, a, sg, cv = KCV[fr], L = 4 + (z >> 1);
    s(0, 3, 4, C); d(-2, 1, A); d(-1, 1, A); d(0, 1, A); d(1, 1, A);
    for (i = 0; i < 2; i++) { sg = i ? 1 : -1; a = sg;
      if (cv < 0) { for (j = 1; j <= L; j++) d(a + sg * j * .3, 5 - j * .25, j === L ? K.WHITE : Hi); }
      else for (j = 1; j <= L; j++) d(a - sg * cv * j * j * .35, 4 + j, j === L ? K.WHITE : Hi); }
  });
  PFA.glyph('L02-paddle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a flat scaly beaver tail raised and slapped down, a splash crown */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, B0 = TAILB[fr], i;
    for (b = 0; b < B0; b++) { d(0, b, C); d(1, b, C); }
    for (b = 0; b <= 4; b++) for (a = (b === 0 || b === 4) ? -1 : -2; a <= ((b === 0 || b === 4) ? 2 : 3); a++) d(a, B0 + b, ((a + b) & 1) ? A : C);
    if (fr >= 2) { for (i = -2; i <= 2; i++) d(i * (fr === 3 ? 2 : 1.5), 2 + (2 - Math.abs(i)) * (fr === 3 ? 2 : 1.2), (i & 1) ? K.DEW : K.WHITE); }
  });
  PFA.glyph('L02-log', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a log with an hourglass notch gnawed deeper, orange teeth at it, chips flying */
    F(c, x, y, tx, ty, nx, ny, K); var a, b, w;
    for (b = 1; b <= 3; b++) { w = b === 2 ? fr : fr - 1; for (a = -4; a <= 4; a++) if (Math.abs(a) >= w || w <= 0) d(a, b, b === 2 ? WOOD : C); }
    d(-4, 2, Hi); d(4, 2, Hi);
    s(0, 6, 3, C); d(-1, 4, Hi); d(0, 4, Hi); d(-2, 7, A); d(2, 7, A);
    if (fr >= 1) { d(-2 - fr, 4 + fr, WOOD); d(2 + fr, 5 + fr, WOOD); }
  });
  PFA.glyph('L02-dam', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* sticks and logs stacked crosswise into a dam, mud dabbed between */
    F(c, x, y, tx, ty, nx, ny, K); var i, n = 1 + Math.min(2, fr), b0, b1;
    for (i = 0; i < n; i++) { b0 = 1 + i * 2; b1 = b0 + ((i & 1) ? -1 : 1);
      K.ln(c, X0 - TX * 4 + NX * b0, Y0 - TY * 4 + NY * b0, X0 + TX * 4 + NX * b1, Y0 + TY * 4 + NY * b1, 2, (i & 1) ? WOOD : C); d((i & 1) ? 3 : -3, b0 + 1, A); }
    if (fr === 3) { d(0, n * 2 + 1, Hi); d(-1, n * 2 + 2, '#6aa050'); }
  });
  PFA.glyph('L02-crewhead', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a round beaver crew head bobbing up out of a water ring, orange teeth showing */
    F(c, x, y, tx, ty, nx, ny, K); var hb = 3 + HB[fr];
    K.ringpx(c, X0 + NX * 2, Y0 + NY * 2, 3 + (fr & 1), WATER);
    s(0, hb, 4, C); d(-2, hb + 2, C); d(2, hb + 2, C); d(-1, hb + 1, A); d(1, hb + 1, A); d(0, hb - 1, A); d(0, hb - 2, Hi); d(1, hb - 2, Hi);
  });

  /* ---------- motions (mutate the scratch G; pp = time x speed) ---------- */
  PFA.motion('L02-rake', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 2.4 + ph) % 1) * 5)); G.t += G.fr * .6; });            /* stroke by stroke */
  PFA.motion('L02-rear', function (G, pp, k, ph) { G.fr = ((pp * 2 + ph) % 1) > .45 ? 1 : 0; G.up += G.fr; });                                /* drop, rear up, paws high */
  PFA.motion('L02-shag', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 1; G.t += Math.sin(pp * 7 + k) * 1.2; });                   /* the coat shakes */
  PFA.motion('L02-doze', function (G, pp, k, ph) { G.fr = Math.floor(pp * 4 + ph * 4) & 3; G.up += Math.sin(pp * 4 + k) * .8; });            /* slow breathing, Zs */
  PFA.motion('L02-hook', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .5 ? 0 : u < .75 ? 1 : 2; G.t += G.fr; });           /* claws reach, then hook */
  PFA.motion('L02-suck', function (G, pp, k) { G.fr = (Math.floor(pp * 18) + k) & 7; G.d -= 1; });                                             /* termites stream into the snout */
  PFA.motion('L02-grow', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.6 + ph) % 1) * 4.5)); });                           /* icicles grow, drip */
  PFA.motion('L02-heap', function (G, pp) { G.fr = Math.min(3, Math.floor(pp * 5)); G.d -= 1; });                                              /* drift heaps up */
  PFA.motion('L02-stamp', function (G, pp, k, ph) { var u = (pp * 1.8 + ph) % 1; G.fr = u < .3 ? 0 : u < .45 ? 1 : u < .7 ? 2 : 3; if (G.fr === 0) G.up += 2; });   /* lift, stamp, crack */
  PFA.motion('L02-stretch', function (G, pp, k) { G.fr = Math.min(3, Math.floor(pp * 5)); G.t += pp * 2; });                                   /* the shadow lengthens */
  PFA.motion('L02-roar', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 2 + ph) % 1) * 4.5)); });                               /* jaws open, arcs go out */
  PFA.motion('L02-jiggle', function (G, pp, k) { G.fr = (Math.floor(pp * 12) + k) & 3; });                                                      /* fat wobbles */
  PFA.motion('L02-peek', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .3 ? 0 : u < .8 ? 1 : 2; });                           /* duck, peek, blink */
  PFA.motion('L02-swish', function (G, pp, k) { G.fr = Math.floor((Math.sin(pp * 9 + k) + 1) * 1.99); });                                       /* tail swishes */
  PFA.motion('L02-grab', function (G, pp, k, ph) { var u = (pp * 2.5 + ph) % 1; G.fr = u > .55 ? 1 : 0; if (G.fr) G.d -= 1; });                 /* reach, grab */
  PFA.motion('L02-dunk', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .3 ? 0 : u < .5 ? 1 : u < .75 ? 2 : 3; if (G.fr === 1) G.d -= 2; });   /* hold, dunk, lift, crack */
  PFA.motion('L02-shake', function (G, pp, k, ph) { G.fr = Math.floor(pp * 10 + ph * 3) & 3; G.t += (G.fr & 1) ? 1.2 : -1.2; });              /* wet shake */
  PFA.motion('L02-charge', function (G, pp, k, ph) { var u = (pp * 2.4 + ph) % 1; G.fr = ((Math.floor(pp * 16) + k) & 1) | (u > .7 ? 2 : 0); G.t += u * 3; });   /* trot, jaws open */
  PFA.motion('L02-ping', function (G, pp, k, ph) { G.fr = Math.floor(pp * 8 + ph * 4) & 3; });                                                  /* bee dives, hits, bounces, falls */
  PFA.motion('L02-snuffle', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 2 + ph) % 1) * 4.5)); G.t += Math.sin(pp * 20 + k) * .6; });
  PFA.motion('L02-flap', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; });
  PFA.motion('L02-crumble', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.6 + ph) % 1) * 4.5)); });
  PFA.motion('L02-sweep', function (G, pp, k) { G.fr = Math.floor((Math.sin(pp * 6 + k * .7) + 1) * 1.99); });
  PFA.motion('L02-flick', function (G, pp, k, ph) { G.fr = TFL[Math.floor(((pp * 3 + ph) % 1) * 8)]; });
  PFA.motion('L02-hug', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .3 ? 0 : u < .6 ? 1 : 2; });
  PFA.motion('L02-slap', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .35 ? 0 : u < .5 ? 1 : u < .7 ? 2 : 3; });
  PFA.motion('L02-gnaw', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; G.t += (G.fr & 1) * .6; });
  PFA.motion('L02-stack', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4.5 + ph * .5)); G.d -= 1; });
  PFA.motion('L02-surface', function (G, pp, k, ph) { G.fr = Math.floor(pp * 6 + ph * 4) & 3; });

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh; pixel counts capped) ---------- */
  function fade(e, H, t) { return e.p > .85 && H.hash(t + Math.floor(e.p * 40)) > (1 - e.p) / .15; }
  function carRake(c, e, H) {           /* four parallel claw scars scored along the outer edge to the next piece, fresh and pale at the head */
    var P = e.P, Q = H.Q, i, u, t = 0;
    for (u = 0; u <= e.hh; u += .025) { t++; if (fade(e, H, t)) continue; P.atq(e.a + e.d * u);
      for (i = 0; i < 4; i++) H.px(c, Q.x + Q.nx * (3 + i * 2), Q.y + Q.ny * (3 + i * 2), e.hh - u < .1 ? e.hi : e.col); }
    H.carHead(c, P, e.a + e.d * e.hh, 'L02-rake', e.z, 3, 0, 0, e.col, e.acc, e.hi);
  }
  function carHoover(c, e, H) {         /* the snout runs to the next piece; a stream of termites ahead of it is sucked back into it */
    var P = e.P, Q = H.Q, k, q, u;
    if (e.hh < .98) for (k = 0; k < 8; k++) { q = (e.p * 2.5 + k / 8) % 1; u = e.hh + (1 - e.hh) * (1 - q); P.atq(e.a + e.d * u); H.sq(c, Q.x + Q.nx * (4 + (k & 1) * 2), Q.y + Q.ny * (4 + (k & 1) * 2), 2, TERM); }
    H.carHead(c, P, e.a + e.d * e.hh, 'L02-hoover', e.z, Math.floor(e.p * 18) & 7, 0, 0, e.col, e.acc, e.hi);
  }
  function carIcicle(c, e, H) {         /* an icicle fringe grows along the outer edge, one icicle after another, the finished ones dripping */
    var P = e.P, Q = H.Q, k, j, u, g, L;
    for (k = 0; k <= 7; k++) { u = k / 7; if (e.hh < u) break; g = Math.min(1, (e.hh - u) * 5); L = Math.round(2 + g * 5 + (k & 1) * 2); P.atq(e.a + e.d * u);
      H.px(c, Q.x + Q.nx * 2 - Q.ny, Q.y + Q.ny * 2 + Q.nx, e.hi);
      for (j = 0; j <= L; j++) H.px(c, Q.x + Q.nx * (2 + j), Q.y + Q.ny * (2 + j), j < L - 1 ? e.hi : H.WHITE);
      if (g === 1 && ((Math.floor(e.p * 10) + k) & 3) === 0) H.sq(c, Q.x + Q.nx * (L + 5), Q.y + Q.ny * (L + 5), 2, H.DEW); }
  }
  function carCrevasse(c, e, H) {       /* a blue crevasse crack runs along the outer edge, a huge paw print stamped every quarter */
    var P = e.P, Q = H.Q, u, i = 0, k;
    for (u = 0; u <= e.hh; u += .02) { i++; if (fade(e, H, i)) continue; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * (3 + CRK[i & 7]), Q.y + Q.ny * (3 + CRK[i & 7]), e.hh - u < .08 ? H.WHITE : e.hi); }
    for (k = 1; k <= 4; k++) if (e.hh >= k / 4 - .001) H.carHead(c, P, e.a + e.d * k / 4, 'L02-bigpaw', e.z, e.hh - k / 4 < .08 ? 1 : 3, 0, 0, e.col, e.acc, e.hi);
  }
  function carCape(c, e, H) {           /* the honey badger charges head-first round the outer edge, dust clods kicked up behind, jaws open on arrival */
    var P = e.P, Q = H.Q, k, u, sg = e.d < 0 ? -1 : 1, fr;
    for (k = 1; k <= 5; k++) { u = e.hh - k * .05; if (u < 0) break; P.atq(e.a + e.d * u); H.sq(c, Q.x + Q.nx * (3 + (k & 1) * 3), Q.y + Q.ny * (3 + (k & 1) * 3) - k * .6, k < 3 ? 2 : 1, DUST); }
    fr = (Math.floor(e.p * 16) & 1) | (e.hh > .9 ? 2 : 0); P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'L02-cape', Q.x + Q.nx * 4, Q.y + Q.ny * 4, e.z, fr, e.col, e.acc, e.hi, -Q.ny * sg, Q.nx * sg, Q.nx, Q.ny);
  }
  function carBanner(c, e, H) {         /* the great tail sweeps along the outer edge like a cloak, its long fringe trailing */
    var P = e.P, Q = H.Q, k, u;
    for (k = 1; k <= 7; k++) { u = e.hh - k * .035; if (u < 0) break; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * (4 + (k & 1) * 3), Q.y + Q.ny * (4 + (k & 1) * 3), k < 4 ? e.col : e.acc);
      H.px(c, Q.x + Q.nx * (6 + (k & 1)), Q.y + Q.ny * (6 + (k & 1)), e.col); }
    H.carHead(c, P, e.a + e.d * e.hh, 'L02-banner', e.z, Math.floor((Math.sin(e.p * 12) + 1) * 1.99), 0, 0, e.col, e.acc, e.hi);
  }
  function carSlap(c, e, H) {           /* the flat tail slaps the water three times on the way, each slap a splash crown and a ring */
    var P = e.P, Q = H.Q, k, i, s0, g;
    for (k = 1; k <= 3; k++) { s0 = k / 3; if (e.hh < s0 - .001) break; g = (e.hh - s0 + .001) / .3; if (g > 1) continue; P.atq(e.a + e.d * s0);
      for (i = -2; i <= 2; i++) H.px(c, Q.x + Q.nx * (3 + (2 - Math.abs(i)) * g * 3) - Q.ny * i * 1.5 * (1 + g), Q.y + Q.ny * (3 + (2 - Math.abs(i)) * g * 3) + Q.nx * i * 1.5 * (1 + g), (i & 1) ? H.DEW : H.WHITE);
      H.ringpx(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, 2 + g * 4, WATER); }
    H.carHead(c, P, e.a + e.d * e.hh, 'L02-paddle', e.z, e.hh < .95 ? Math.floor(e.p * 12) & 3 : 2, 0, 0, e.col, e.acc, e.hi);
  }

  /* ---------- motifs ---------- */
  PFA.motif('claw-rake', plain, { nm: 'claw rakes', desc: 'four parallel claw-rake scars ripped stroke by stroke, pale wood at the root, white claw tips at full length; the chain is scored with four scars', fam: 'slash', gap: 16, g: 'L02-rake', mo: 'L02-rake', x: '-', car: 'custom', carDraw: carRake });
  PFA.motif('bear-rear', plain, { nm: 'rearing bears', desc: 'a black bear rearing up on its hind legs, tan muzzle, forepaws lifted high with pale claws, then dropping', fam: 'shield', gap: 18, g: 'L02-rear', mo: 'L02-rear', x: '-', car: 'hop' });
  PFA.motif('shaggy-mane', plain, { nm: 'shaggy manes', desc: 'long shaggy black hair fanning out and shaking, the pale chest V at its root', fam: 'thorn', gap: 14, g: 'L02-shag', mo: 'L02-shag', x: '-', car: 'train' });
  PFA.motif('hollow-nap', plain, { nm: 'hollow naps', desc: 'a shaggy ball curled asleep in a hollow, slow breathing, a Z drifting up and growing', fam: 'mend', gap: 18, g: 'L02-nap', mo: 'L02-doze', x: '-', car: 'rings' });
  PFA.motif('sickle-hook', plain, { nm: 'sickle claws', desc: 'three long ivory sickle claws curling into a hook off a shaggy paw', fam: 'slash', gap: 16, g: 'L02-sickle', mo: 'L02-hook', x: '-', car: 'comet' });
  PFA.motif('termite-hoover', plain, { nm: 'termite hoovers', desc: 'a shaggy sloth-bear face with a pale tube snout, lips pursing, a stream of termites sucked into it; the chain is a termite stream pulled back into the snout', fam: 'bite', gap: 18, g: 'L02-hoover', mo: 'L02-suck', x: '-', car: 'custom', carDraw: carHoover });
  PFA.motif('icicle-beard', plain, { nm: 'icicle beards', desc: 'rimed fur clumps with an icicle beard growing off them, the long icicle dripping; the chain grows an icicle fringe along the edge', fam: 'thorn', gap: 14, g: 'L02-icicle', mo: 'L02-grow', x: 'snow', car: 'custom', carDraw: carIcicle });
  PFA.motif('snow-bank', plain, { nm: 'snow banks', desc: 'snowdrift mounds heaping up along the edge, blue shadow at the foot, a sparkle on top', fam: 'shield', gap: 14, g: 'L02-drift', mo: 'L02-heap', x: 'snow', car: 'tunnel' });
  PFA.motif('crevasse-paw', function (c, e, H) { comp(c, e, H, decoCrevasse); }, { nm: 'crevasse paws', desc: 'huge silver-blue paw prints lifting and stamping down, blue cracks branching from the pad and a crevasse opening along the edge; the chain cracks the ice print by print', fam: 'bash', gap: 18, g: 'L02-bigpaw', mo: 'L02-stamp', x: '-', car: 'custom', carDraw: carCrevasse });
  PFA.motif('long-shadow', plain, { nm: 'long shadows', desc: 'a small silver bear casting a long dark shadow that stretches along the snow', fam: 'puff', gap: 20, g: 'L02-shadow', mo: 'L02-stretch', x: '-', car: 'trail' });
  PFA.motif('calving-roar', plain, { nm: 'calving roars', desc: 'a roaring bear head, jaws opening, roar arcs going out and ice chunks calving off', fam: 'ripple', gap: 18, g: 'L02-roar', mo: 'L02-roar', x: '-', car: 'rings' });
  PFA.motif('blubber-wobble', plain, { nm: 'blubber humps', desc: 'thick round fat humps squashing and stretching in a jiggle, a sheen on top', fam: 'shield', gap: 14, g: 'L02-blubber', mo: 'L02-jiggle', x: '-', car: 'roll' });
  PFA.motif('bandit-mask', plain, { nm: 'bandit masks', desc: 'a raccoon face ducking and peeking up over the edge: black bandit mask, white brows and muzzle, eyes glinting then blinking', fam: 'web', gap: 16, g: 'L02-mask', mo: 'L02-peek', x: '-', car: 'blink' });
  PFA.motif('ringtail-swish', plain, { nm: 'ringed tails', desc: 'a bushy tail with dark and pale rings swishing side to side, dark tip', fam: 'slash', gap: 16, g: 'L02-ringtail', mo: 'L02-swish', x: '-', car: 'loop' });
  PFA.motif('nimble-hand', plain, { nm: 'nimble hands', desc: 'a raccoon\'s little five-fingered hand reaching with fingers spread, then closing on a grab', fam: 'web', gap: 14, g: 'L02-hand', mo: 'L02-grab', x: '-', car: 'hop' });
  PFA.motif('crab-dunk', plain, { nm: 'crab dunks', desc: 'a wet grey hand holding a red crab: dunked in a ring, lifted dripping, then the shell cracked with white shards', fam: 'bite', gap: 18, g: 'L02-crabpaw', mo: 'L02-dunk', x: 'bubbles', car: 'rings' });
  PFA.motif('wash-spray', plain, { nm: 'wash sprays', desc: 'a spiky wet-fur clump shaking side to side, flinging a fan of water drops', fam: 'ripple', gap: 14, g: 'L02-spray', mo: 'L02-shake', x: '-', car: 'flutter' });
  PFA.motif('cape-charge', plain, { nm: 'cape charges', desc: 'a low black honey badger with a silver cape over its back trotting head-first, jaws snapping open with anger marks; the chain is a full charge round the edge, dust kicked up', fam: 'bash', gap: 18, g: 'L02-cape', mo: 'L02-charge', x: 'dust', car: 'custom', carDraw: carCape });
  PFA.motif('sting-shrug', plain, { nm: 'sting shrugs', desc: 'a silver cape hump with bees diving at it, bouncing off with a spark and falling with bent stingers', fam: 'thorn', gap: 14, g: 'L02-shrug', mo: 'L02-ping', x: '-', car: 'cloud' });
  PFA.motif('tube-snout', plain, { nm: 'tube snouts', desc: 'a pink-grey tube snout poking out of a soil mound, long ears behind, the nose disc snuffling side to side', fam: 'thrust', gap: 16, g: 'L02-snout', mo: 'L02-snuffle', x: 'clods', car: 'tunnel' });
  PFA.motif('long-ears', plain, { nm: 'long ears', desc: 'two long pink-lined ears flapping open and shut like fans', fam: 'puff', gap: 16, g: 'L02-ears', mo: 'L02-flap', x: '-', car: 'flutter' });
  PFA.motif('mound-crumble', plain, { nm: 'mound crumbles', desc: 'a clay termite-mound spire that cracks and bursts, chunks and termites flying', fam: 'bash', gap: 16, g: 'L02-mound', mo: 'L02-crumble', x: '-', car: 'roll' });
  PFA.motif('banner-tail', plain, { nm: 'banner tails', desc: 'a huge shaggy fan-shaped tail sweeping side to side like a cloak, dark fringe; the chain is the tail swept round the edge', fam: 'shield', gap: 18, g: 'L02-banner', mo: 'L02-sweep', x: '-', car: 'custom', carDraw: carBanner });
  PFA.motif('ant-tongue', plain, { nm: 'ant tongues', desc: 'a long thin snout whipping a sticky pink tongue in and out, ants stuck along it', fam: 'web', gap: 14, g: 'L02-tongue', mo: 'L02-flick', x: '-', car: 'thread' });
  PFA.motif('knuckle-claw', plain, { nm: 'knuckle claws', desc: 'a pale forepaw with a black band and two huge claws: folded for the knuckle walk, opened, then closing in a hug', fam: 'slash', gap: 16, g: 'L02-knuckle', mo: 'L02-hug', x: '-', car: 'hop' });
  PFA.motif('tail-slap', function (c, e, H) { comp(c, e, H, decoRipple); }, { nm: 'tail slaps', desc: 'a flat scaly beaver tail raised and slapped down, a splash crown and water rings; the chain slaps the water three times on the way', fam: 'bash', gap: 18, g: 'L02-paddle', mo: 'L02-slap', x: '-', car: 'custom', carDraw: carSlap });
  PFA.motif('log-gnaw', plain, { nm: 'log gnaws', desc: 'a log with an hourglass notch gnawed deeper by orange teeth, wood chips flying', fam: 'bite', gap: 16, g: 'L02-log', mo: 'L02-gnaw', x: 'sawdust', car: 'train' });
  PFA.motif('stick-dam', plain, { nm: 'stick dams', desc: 'sticks and logs laid crosswise one on another into a dam, mud dabbed between, a green sprig on top', fam: 'shield', gap: 14, g: 'L02-dam', mo: 'L02-stack', x: '-', car: 'train' });
  PFA.motif('crew-heads', function (c, e, H) { comp(c, e, H, decoRipple); }, { nm: 'crew heads', desc: 'round beaver crew heads bobbing up out of water rings, orange teeth showing', fam: 'mend', gap: 16, g: 'L02-crewhead', mo: 'L02-surface', x: '-', car: 'rings' });
})();
