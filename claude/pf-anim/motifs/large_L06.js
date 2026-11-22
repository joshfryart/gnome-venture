/* Motif module, large batch L06 (tawny-owl, eagle-owl, condor, lammergeier, griffon-vulture, marsh-harrier): owls, vultures and a harrier.
   TEMPLATE.md sections 9 and 10.3. 27 motifs, each with its own pixel glyph (ids prefixed L06-) and motion; five have their own chain effect (carDraw):
   the silent tawny glide, the soaring condor with its shadow, the bone carried and dropped, the circling kettle of griffons, the harrier quartering the reeds.
   Glyph coordinates are written as (a, b): a along the edge tangent, b outward along the normal, so every sprite turns with the edge it sits on.
   fr0() stores the glyph's frame in module scratch variables; p()/s() then plot in (a, b). Glyph draws never nest, so the scratch is safe. Nothing is
   allocated per frame (lookup tables are built once at load), there is no Math.random / Date, every effect is a stateless function of p.
   Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy
   default are untouched (they live in the page). Large birds are drawn a little bigger than small ones (up to ~13 px) but stay within ~22 px of the edge. */
(function () {
  var X0 = 0, Y0 = 0, TX = 1, TY = 0, NX = 0, NY = -1, KK = null;
  var BONE = '#eee4cc', MARROW = '#f2c040', MOUSE = '#bdb3a6', ROCK = '#8c8579', RED = '#b03a2e', NECK = '#c9c4cc', AMBER = '#f0a020',
    YEL = '#e8c020', REED = '#a0b464', CATTAIL = '#7a5232', CERE = '#e8c040', BEAK = '#b8b2a6', EYERING = '#e0402c';
  var ARA = [], ARB = [], KCA = [], KCB = [], i0, t0;                     /* unit half-ring (11 points) for hoot rings; 8-point circle for the kettle */
  for (i0 = 0; i0 < 11; i0++) { t0 = (.1 + .08 * i0) * Math.PI; ARA.push(Math.cos(t0)); ARB.push(Math.sin(t0)); }
  for (i0 = 0; i0 < 8; i0++) { t0 = i0 / 8 * Math.PI * 2; KCA.push(Math.cos(t0)); KCB.push(Math.sin(t0)); }
  var BDIR = [[1, 0], [.7, .7], [0, 1], [-.7, .7]];                        /* bone spin directions, frames 0..3 */

  function fr0(x, y, tx, ty, nx, ny, K) { X0 = x; Y0 = y; TX = tx; TY = ty; NX = nx; NY = ny; KK = K; }
  function p(c, a, b, col) { KK.px(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, col); }
  function row(c, a0, a1, b, col) { for (var a = a0; a <= a1; a++) p(c, a, b, col); }
  function cl(c, a, b0, b1, col) { for (var b = b0; b <= b1; b++) p(c, a, b, col); }
  function arc(c, r, cb, sa, sb, col, step) { for (var i = 0; i < 11; i += step) p(c, Math.round(ARA[i] * r * sa), Math.round(cb + ARB[i] * r * sb), col); }

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
  /* --- tawny owl --- */
  PFA.glyph('L06-tawny', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* round-headed tawny owl seen head-on, wings spread in a silent glide: level, up, down, talons out */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, W = 6 + w, a, b = 3;
    cl(c, -1, 1, 3, C); cl(c, 0, 0, 3, C); cl(c, 1, 1, 3, C); p(c, 0, 2, A);
    row(c, -2, 2, 4, C); row(c, -2, 2, 5, Hi); row(c, -2, 2, 6, C); row(c, -1, 1, 7, C);
    p(c, -1, 5, A); p(c, 1, 5, A); p(c, 0, 4, A);
    for (a = 2; a <= W; a++) {
      b = fr === 1 ? 3 + ((a - 2) >> 1) : fr === 2 ? 3 - ((a - 2) >> 1) : 3;
      p(c, a, b, a % 3 === 0 ? A : C); p(c, -a, b, a % 3 === 0 ? A : C);
      if (a < W - 1) { p(c, a, b + 1, C); p(c, -a, b + 1, C); }
      if ((a & 1) === 0) { p(c, a, b - 1, Hi); p(c, -a, b - 1, Hi); }               /* soft fringed trailing edge: why it flies silent */
    }
    p(c, W + 1, b, A); p(c, -W - 1, b, A);
    if (fr === 3) { p(c, -1, 0, Hi); p(c, 1, 0, Hi); p(c, -2, -1, A); p(c, -1, -1, A); p(c, 1, -1, A); p(c, 2, -1, A); }
  });
  PFA.glyph('L06-hoot', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a small owl head hooting: the short "twit" tick, then the long "twoo" rings widening */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0;
    row(c, -1, 1, 0, C); row(c, -2, 2, 1, C); row(c, -2, 2, 2, Hi); row(c, -1, 1, 3, C); p(c, -1, 2, A); p(c, 1, 2, A); p(c, 0, 1, A);
    if (fr === 0) { cl(c, 0, 5, 6, K.WHITE); p(c, -1, 7, Hi); p(c, 1, 7, Hi); }
    else if (fr === 1) arc(c, 4 + w, 2, 1, 1, Hi, 1);
    else if (fr === 2) { arc(c, 4 + w, 2, 1, 1, C, 1); arc(c, 6 + w, 2, 1, 1, Hi, 2); }
    else { arc(c, 7 + w, 2, 1, 1, Hi, 2); arc(c, 9 + w, 2, 1, 1, C, 3); }
  });
  PFA.glyph('L06-fluffball', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* the tawny owl fluffed up into a barred round ball, eyes shut to slits, feathers bristling */
    fr0(x, y, tx, ty, nx, ny, K); var r = 4 + (z > 1 ? 1 : 0) + (fr === 2 ? 1 : 0), rr = r * r, a, b, d, i;
    for (b = -r; b <= r; b++) for (a = -r; a <= r; a++) { d = a * a + b * b; if (d > rr) continue; p(c, a, b + r, (b + r) % 3 === 1 && (a & 1) && d < rr - r ? A : C); }
    row(c, -2, 2, r + 1, Hi); row(c, -1, 1, r + 2, Hi); p(c, 0, r + 1, A);
    if (fr === 3) { p(c, -1, r + 2, A); p(c, 1, r + 2, A); p(c, -1, r + 3, K.WHITE); } else { p(c, -2, r + 2, A); p(c, -1, r + 2, A); p(c, 1, r + 2, A); p(c, 2, r + 2, A); }
    if (fr >= 2) for (i = 0; i < 8; i++) p(c, Math.round(KCA[i] * (r + 1)), Math.round(r + KCB[i] * (r + 1)), Hi);
  });
  PFA.glyph('L06-mouse', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a wood mouse frozen stiff under the owl's gaze: tail rigid, a shiver, a "!" */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, a;
    row(c, -2, 1, 1, MOUSE); row(c, -3 - w, 2, 2, MOUSE); row(c, -2, 1, 3, MOUSE); if (w) row(c, -2, 0, 4, MOUSE);
    p(c, 3, 2, MOUSE); p(c, 4, 2, MOUSE); p(c, 2, 3, MOUSE); p(c, 3, 3, MOUSE); p(c, 1, 4, MOUSE); p(c, 2, 4, Hi);
    p(c, 3, 3, A); p(c, 5, 2, A); p(c, -2, 0, A); p(c, 1, 0, A);
    for (a = -8 - w; a <= -4 - w; a++) p(c, a, 2, A);
    if (fr === 2) { cl(c, 0, 7, 9, K.WHITE); p(c, 0, 5, K.WHITE); }
    else if (fr === 3 || fr === 1) { p(c, -6, 4, Hi); p(c, -6, 5, Hi); p(c, 6, 4, Hi); p(c, 6, 5, Hi); }
  });
  PFA.glyph('L06-plume', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a soft owl feather with a comb-fringed edge, swaying without a sound */
    fr0(x, y, tx, ty, nx, ny, K); var L = 7 + (z > 1 ? 1 : 0), sw = fr === 1 ? 1 : fr === 3 ? -1 : 0, b, k, half, aa;
    for (b = 0; b <= L; b++) {
      aa = Math.round(sw * b / L * 2); half = b < 1 ? 0 : b < L - 1 ? 2 : 1; p(c, aa, b, A);
      for (k = 1; k <= half; k++) { p(c, aa - k, b, C); p(c, aa + k, b, k === half && (b & 1) ? Hi : C); }
      if (b % 3 === 2 && half) p(c, aa - 1, b, A);
      if (fr === 2 && (b & 1) && half) p(c, aa + half + 1, b, Hi);
    }
    p(c, sw * 2, L + 1, Hi);
  });
  /* --- eagle owl --- */
  PFA.glyph('L06-lamps', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* the two great orange lamp eyes under feathered brows: wide, pupils shrinking, lids lowering, a slow blink */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, e, ca;
    for (e = -1; e <= 1; e += 2) {
      ca = e * (3 + w);
      row(c, ca - 1, ca + 1, 1, Hi); row(c, ca - 2, ca + 2, 2, Hi); row(c, ca - 2, ca + 2, 3, Hi); row(c, ca - 2, ca + 2, 4, Hi); row(c, ca - 1, ca + 1, 5, Hi);
      p(c, ca - 3, 3, A); p(c, ca + 3, 3, A);
      if (fr === 1) p(c, ca, 3, A); else { p(c, ca, 3, A); p(c, ca, 4, A); p(c, ca - e, 3, A); p(c, ca - e, 4, A); }
      p(c, ca + e, 4, K.WHITE);
      if (fr === 2) { row(c, ca - 2, ca + 2, 5, C); row(c, ca - 2, ca + 2, 4, C); }
      if (fr === 3) { row(c, ca - 1, ca + 1, 1, C); row(c, ca - 2, ca + 2, 2, C); row(c, ca - 2, ca + 2, 3, A); row(c, ca - 2, ca + 2, 4, C); row(c, ca - 1, ca + 1, 5, C); }
      row(c, ca - 2, ca + 2, 6, C); p(c, ca + e * 3, 7, C); p(c, ca + e * 4, 8, A); p(c, ca, 6, A);
    }
    p(c, 0, 2, A); p(c, 0, 1, A); p(c, 0, 3, C);
  });
  PFA.glyph('L06-earhorn', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* mottled eagle-owl head with two big ear tufts: up, flicked tall, flattened back, one cocked */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, b, e, tt;
    for (b = 0; b <= 6; b++) row(c, -3 - (b > 0 && b < 6 ? 1 : 0) - w, 3 + (b > 0 && b < 6 ? 1 : 0) + w, b, C);
    p(c, -2, 1, A); p(c, 3, 5, A); p(c, -3, 5, A); p(c, 3, 2, A); p(c, -4, 3, A); p(c, 0, 6, A);
    row(c, -2, -1, 4, Hi); row(c, 1, 2, 4, Hi); p(c, -2, 3, Hi); p(c, 2, 3, Hi); p(c, -1, 4, A); p(c, 1, 4, A);
    p(c, 0, 2, A); p(c, 0, 1, A); row(c, -1, 1, 0, K.WHITE);
    for (e = -1; e <= 1; e += 2) {
      tt = fr === 1 ? 1 : 0;
      if (fr === 2 || (fr === 3 && e > 0)) { p(c, e * (4 + w), 6, C); p(c, e * (5 + w), 6, C); p(c, e * (6 + w), 5, A); }
      else { p(c, e * 3, 7, C); p(c, e * 3, 8, C); p(c, e * 4, 8, C); p(c, e * 4, 9, C); p(c, e * 4, 9 + tt, A); p(c, e * 5, 10 + tt, A); if (tt) p(c, e * 4, 10, C); }
    }
  });
  PFA.glyph('L06-nightowl', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a huge eagle owl in flight, ear tufts up, lamp eyes: wings spread, stooping, braking, talons thrown forward */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, W = 7 + w, a, b, k;
    for (b = 1; b <= 5; b++) row(c, -1, 1, b, C); p(c, 0, 3, A);
    row(c, -2, 2, 6, C); row(c, -2, 2, 7, C); p(c, -2, 8, A); p(c, -3, 9, A); p(c, 2, 8, A); p(c, 3, 9, A); p(c, -1, 7, Hi); p(c, 1, 7, Hi);
    if (fr === 1) { for (k = 0; k < 5; k++) { b = 5 - k; a = 2 + Math.round(k * .6); p(c, a, b, C); p(c, -a, b, C); p(c, a + 1, b, k & 1 ? A : C); p(c, -a - 1, b, k & 1 ? A : C); } }
    else for (a = 2; a <= W; a++) {
      b = fr === 2 ? 5 + Math.round((a - 2) * .6) : 4;
      p(c, a, b, (a & 1) ? A : C); p(c, -a, b, (a & 1) ? A : C);
      if (a < W - 1) { p(c, a, b + 1, C); p(c, -a, b + 1, C); }
      if (a === W) { p(c, a + 1, b - 1, A); p(c, -a - 1, b - 1, A); }
    }
    if (fr === 3) { p(c, -1, 0, Hi); p(c, 1, 0, Hi); p(c, -2, -1, A); p(c, 0, -1, A); p(c, 2, -1, A); }
  });
  PFA.glyph('L06-boohoo', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the deep "BOO-hoo": white throat puffs out under the tufted head, wide flat rings roll away */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, r;
    row(c, -2, 2, 2, C); row(c, -2, 2, 3, C); row(c, -2, 2, 4, C); p(c, -2, 5, A); p(c, -3, 6, A); p(c, 2, 5, A); p(c, 3, 6, A);
    p(c, -1, 4, Hi); p(c, 1, 4, Hi); p(c, 0, 3, A);
    row(c, -1, 1, 1, K.WHITE); if (fr >= 1) row(c, -2, 2, 0, K.WHITE); if (fr === 2) p(c, 0, -1, K.WHITE);
    r = fr === 1 ? 3 : fr === 2 ? 5 : fr === 3 ? 7 : 0;
    if (r) { arc(c, r + w, 5, 1.6, .55, Hi, 1); if (r > 3) arc(c, r - 2 + w, 5, 1.6, .55, C, 2); }
  });
  /* --- condor --- */
  PFA.glyph('L06-condor', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the condor soaring on flat black wings with a white band and fingered tips, bald red head on a white ruff; it rocks */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, W = 8 + w, tl = fr === 1 ? 1 : fr === 3 ? -1 : 0, a, b, e;
    cl(c, 0, 1, 3, A); p(c, -1, 2, A); p(c, 1, 2, A); row(c, -1, 1, 0, A);
    row(c, -1, 1, 4, C); p(c, 0, 5, Hi); p(c, 0, 6, Hi); p(c, 0, 7, BONE);
    for (e = -1; e <= 1; e += 2) {
      for (a = 2; a <= W; a++) {
        b = 3 + Math.round(tl * e * a / W * 2);
        p(c, e * a, b - 1, A); p(c, e * a, b, a >= 3 && a <= W - 2 ? C : A);
        if (a < W - 2) p(c, e * a, b + 1, A);
      }
      p(c, e * (W + 1), b, A); p(c, e * (W + 1), b - 2, A); p(c, e * (W + 2), b - 1, A); p(c, e * (W + 2), b + 1, A);
    }
  });
  PFA.glyph('L06-beat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* one great condor wing in a downstroke: raised, sweeping, down, the shoved air bursting out in gust lines */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, L = 8 + w, ang = [.9, .35, -.25, -.25][fr & 3], i, b = 2, k;
    for (i = 0; i <= L; i++) { b = 2 + Math.round(i * ang); p(c, i, b, A); p(c, i, b - 1, A); if (i >= 2 && i <= L - 3) p(c, i, b + 1, C); }
    p(c, L + 1, b + 1, A); p(c, L + 1, b - 1, A); p(c, L + 2, b, A); p(c, L, b - 2, A);
    cl(c, -1, 1, 3, A); p(c, -1, 4, C); p(c, -1, 5, Hi);
    if (fr >= 2) for (k = 0; k < 3; k++) { p(c, 2 + k * 3, b - 3 - (k & 1), K.WHITE); p(c, 3 + k * 3, b - 3 - (k & 1), K.WHITE); if (fr === 3) { p(c, 3 + k * 3, b - 5 - (k & 1), Hi); p(c, 4 + k * 3, b - 5 - (k & 1), Hi); } }
  });
  PFA.glyph('L06-baldhead', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* the bald red head on a white ruff, wrinkled, hooked ivory beak: rest, stretch, peck, tear a scrap */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, st = fr === 1 ? 1 : fr === 2 ? 2 : 0, a;
    row(c, -3 - w, 3 + w, 0, C); row(c, -2, 2, 1, C); for (a = -3; a <= 3; a += 2) p(c, a, 1 + (a & 2 ? 0 : 1), C); p(c, -2, 0, A); p(c, 2, 0, A);
    cl(c, 0, 2, 3 + st, Hi); p(c, -1, 2, Hi);
    row(c, -1, 1, 4 + st, Hi); row(c, -1, 1, 5 + st, Hi); p(c, 0, 6 + st, Hi); p(c, -1, 4 + st, A); p(c, 1, 5 + st, A);
    p(c, 0, 7 + st, BEAK); p(c, 1, 7 + st, BEAK); p(c, 1, 8 + st, BEAK);
    if (fr === 2) { p(c, 2, 9 + st, K.WHITE); p(c, -2, 8 + st, Hi); }
    if (fr === 3) { p(c, 2, 8, Hi); p(c, 3, 7, Hi); p(c, 3, 9, A); }
  });
  /* --- lammergeier --- */
  PFA.glyph('L06-bone', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a long knobbed bone spinning end over end (frames 0..3); frame 4 = shattered into splinters */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, L = 3 + w, i, da, db, e;
    if (fr >= 4) {
      p(c, -4, 1, BONE); p(c, -3, 2, BONE); p(c, -2, 1, BONE); p(c, 3, 1, BONE); p(c, 4, 2, BONE); p(c, 2, 3, BONE); p(c, 0, 4, BONE); p(c, -1, 5, BONE);
      p(c, -5, 3, Hi); p(c, 5, 4, Hi); p(c, 1, 6, Hi); p(c, 0, 1, A); p(c, 1, 2, A); p(c, -1, 3, MARROW); return;
    }
    da = BDIR[fr & 3][0]; db = BDIR[fr & 3][1];
    for (i = -L; i <= L; i++) p(c, Math.round(da * i), Math.round(3 + db * i), BONE);
    p(c, Math.round(-db), Math.round(3 + da), A);
    for (e = -1; e <= 1; e += 2) { p(c, Math.round(da * e * (L + 1) - db), Math.round(3 + db * e * (L + 1) + da), BONE); p(c, Math.round(da * e * (L + 1) + db), Math.round(3 + db * e * (L + 1) - da), BONE); }
  });
  PFA.glyph('L06-marrow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a bone cracks and splits, the golden marrow inside glows and a bead of it floats up */
    fr0(x, y, tx, ty, nx, ny, K); var g = fr >= 2 ? 1 : 0;
    row(c, -4 - g, -1 - g, 2, BONE); row(c, 1 + g, 4 + g, 2, BONE); if (!g) p(c, 0, 2, BONE);
    p(c, -5 - g, 1, BONE); p(c, -5 - g, 3, BONE); p(c, 5 + g, 1, BONE); p(c, 5 + g, 3, BONE); p(c, -3, 1, A); p(c, 3, 1, A);
    if (fr === 1) { p(c, 0, 2, A); p(c, 0, 3, A); p(c, 1, 3, MARROW); }
    if (g) { p(c, 0, 2, MARROW); p(c, 0, 3, MARROW); p(c, -1, 2, MARROW); p(c, 1, 2, MARROW); p(c, 0, 1, Hi); }
    if (fr === 3) { p(c, 0, 6, MARROW); p(c, 0, 7, MARROW); p(c, 1, 6, MARROW); p(c, 0, 8, K.WHITE); p(c, -2, 7, Hi); p(c, 2, 8, Hi); }
    if (z > 1) { p(c, -2, 3, BONE); p(c, 2, 3, BONE); }
  });
  PFA.glyph('L06-perch', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* the lammergeier perched upright on a rock ledge: orange chest, black beard, long wedge tail hanging over */
    fr0(x, y, tx, ty, nx, ny, K); var hb = fr === 3 ? 1 : 0, bd = fr === 2 ? -1 : 0, ey = fr === 1 ? 1 : -1;
    row(c, -4, 5, 3, ROCK); row(c, -3, 4, 2, A); p(c, -5, 2, ROCK);
    cl(c, 3, 0, 3, A); p(c, 2, 1, A); p(c, 4, 1, A); p(c, 3, -1, A);
    cl(c, 0, 4, 9, C); cl(c, -1, 5, 8, C); cl(c, 1, 4, 10 + hb, A); cl(c, 2, 4, 9, A);
    row(c, -1, 1, 10, Hi); row(c, -1, 0, 11, Hi); p(c, -1, 10, A); p(c, ey > 0 ? 0 : -1, 11, EYERING);
    p(c, -2, 10, BEAK); p(c, -3, 10, BEAK); p(c, -3, 9, BEAK);
    p(c, -2 + bd, 9, A); p(c, -2 + bd, 8, A); p(c, -3 + bd, 8, A);
  });
  PFA.glyph('L06-wedgetail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* lammergeier silhouette: long narrow swept wings, orange body, black beard, the long diamond wedge tail */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, W = 8 + w, fl = fr & 1, a, b;
    cl(c, 0, 3, 6, C); p(c, -1, 4, C); p(c, 1, 4, C); p(c, 0, 7, Hi); p(c, 0, 8, Hi); p(c, -1, 6, A);
    row(c, -1, 1, 2, A); row(c, -2, 2, 1, A); row(c, -1, 1, 0, A); p(c, 0, -1, A);
    for (a = 1; a <= W; a++) { b = 5 - (a >> 2) - (fl && a > W - 3 ? 1 : 0); p(c, a, b, A); p(c, -a, b, A); if (a < W - 2) { p(c, a, b + 1, a < 4 ? C : A); p(c, -a, b + 1, a < 4 ? C : A); } }
  });
  PFA.glyph('L06-beard', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* bearded head side-on picking a carcass clean: pale head, black mask, red eye ring, bristle beard, bone flecks */
    fr0(x, y, tx, ty, nx, ny, K); var st = fr === 1 ? -2 : 0, w = z > 1 ? 1 : 0;
    cl(c, 1, 0, 3 + st, C); cl(c, 2, 0, 2 + st, C); if (w) cl(c, 3, 0, 1, C);
    row(c, -1, 2, 4 + st, Hi); row(c, -1, 2, 5 + st, Hi); row(c, 0, 1, 6 + st, Hi);
    p(c, -1, 5 + st, A); p(c, 0, 5 + st, EYERING); p(c, 1, 5 + st, A);
    p(c, -2, 5 + st, BEAK); p(c, -3, 5 + st, BEAK); p(c, -3, 4 + st, BEAK);
    p(c, -2, 4 + st, A); p(c, -2, 3 + st, A); p(c, -1, 3 + st, A);
    if (fr === 2) { p(c, -4, 2, BONE); p(c, -5, 3, BONE); }
    if (fr === 3) { p(c, -5, 6, BONE); p(c, -6, 7, BONE); p(c, 3, 2, C); }
  });
  /* --- griffon vulture --- */
  PFA.glyph('L06-kettle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a kettle: three griffons circling on broad dark-tipped wings round one point (fr 0..7 = turn) */
    fr0(x, y, tx, ty, nx, ny, K); var r = 4 + (z > 1 ? 1 : 0), i, idx, ca, cb, fl;
    for (i = 0; i < 3; i++) {
      idx = (fr + i * 3) & 7; ca = Math.round(KCA[idx] * r); cb = Math.round(5 + KCB[idx] * r * .6); fl = idx & 1;
      row(c, ca - 3, ca - 1, cb, A); row(c, ca + 1, ca + 3, cb, A); p(c, ca, cb, C); p(c, ca - 2, cb, C); p(c, ca + 2, cb, C);
      p(c, ca - 3, cb + 1 - fl, A); p(c, ca + 3, cb + 1 - fl, A); p(c, ca, cb + 1, Hi); p(c, ca, cb - 1, A);
    }
  });
  PFA.glyph('L06-ruff', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the white downy ruff like a shawl, dark wings drawn round it, the bare neck pulled in or stretched */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, nk = fr === 1 ? 1 : fr === 3 ? -1 : 0, a;
    cl(c, -5 - w, 0, 4, A); cl(c, 5 + w, 0, 4, A); cl(c, -4 - w, 0, 5, A); cl(c, 4 + w, 0, 5, A);
    row(c, -3, 3, 0, C); row(c, -3, 3, 1, C); row(c, -3, 3, 2, C);
    row(c, -4, 4, 3, Hi); for (a = -4; a <= 4; a += 2) p(c, a, 4, Hi); p(c, -3, 2, Hi); p(c, 3, 2, Hi);
    cl(c, 0, 4, 6 + nk, NECK); row(c, -1, 1, 7 + nk, NECK); p(c, 1, 7 + nk, A); p(c, -1, 8 + nk, BEAK); p(c, -2, 8 + nk, BEAK);
    if (fr === 2) { p(c, -5, 6, Hi); p(c, 5, 6, Hi); p(c, -6, 5, Hi); p(c, 6, 5, Hi); }
  });
  PFA.glyph('L06-rake', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a long bare neck plunging out of the ruff into a carcass, the hooked beak tearing, dark gore dripping */
    fr0(x, y, tx, ty, nx, ny, K); var hb = [8, 5, 6, 4][fr & 3], ha = [0, 1, -1, 2][fr & 3], b;
    row(c, -2, 2, 0, Hi); row(c, -1, 1, 1, Hi); p(c, -3, 0, C); p(c, 3, 0, C);
    for (b = 2; b < hb; b++) p(c, Math.round(ha * b / hb), b, NECK);
    p(c, ha, hb, NECK); p(c, ha + 1, hb, NECK); p(c, ha, hb + 1, NECK); p(c, ha + 1, hb + 1, A);
    p(c, ha, hb + 2, BEAK); p(c, ha - 1, hb + 2, BEAK); p(c, ha - 1, hb + 1, BEAK);
    if (fr >= 2) { p(c, ha + 1, hb + 2, RED); p(c, ha - 2, hb + 1, RED); }
    if (fr === 3) { p(c, ha - 2, hb - 1, RED); p(c, ha - 2, hb - 2, RED); p(c, ha - 3, hb - 4, RED); }
    if (z > 1) { p(c, -4, 0, C); p(c, 4, 0, C); }
  });
  PFA.glyph('L06-hunch', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a gorged griffon hunched on its perch, shoulders up, head sunk in the ruff, nodding off: open, half, shut, zz */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, b;
    cl(c, -3 - w, 0, 5, A); cl(c, 3 + w, 0, 5, A); cl(c, -2, 0, 6, A); cl(c, 2, 0, 6, A);
    for (b = 0; b <= 4; b++) row(c, -1, 1, b, C);
    row(c, -2, 2, 5, Hi); row(c, -1, 1, 6, Hi);
    row(c, -1, 0, 7, NECK); p(c, 0, 8, NECK); p(c, -2, 7, BEAK);
    if (fr === 0) { p(c, 0, 7, A); p(c, 1, 8, K.WHITE); } else if (fr === 1) p(c, 0, 7, A);
    if (fr >= 2) { p(c, 2, 9, Hi); p(c, 3, 9, Hi); p(c, 2, 10, Hi); }
    if (fr === 3) { row(c, 4, 6, 11, Hi); p(c, 5, 12, Hi); row(c, 4, 6, 13, Hi); }
  });
  PFA.glyph('L06-glare', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a pale bald head on a long thin neck, one fierce amber eye: glancing left, right, then a hard glare */
    fr0(x, y, tx, ty, nx, ny, K); var tn = fr === 1 ? -1 : fr === 2 ? 1 : 0, ey = tn < 0 ? -1 : 1;
    row(c, -2, 2, 0, Hi); row(c, -1, 1, 1, Hi); cl(c, 0, 2, 5, NECK);
    row(c, tn - 1, tn + 1, 6, NECK); row(c, tn - 1, tn + 1, 7, NECK); p(c, tn, 8, NECK);
    p(c, tn + ey, 7, AMBER); p(c, tn + ey, 6, A);
    p(c, tn + ey * 2, 7, BEAK); p(c, tn + ey * 3, 6, BEAK);
    if (fr === 3) { p(c, tn + ey, 8, A); p(c, tn, 8, A); p(c, tn + ey * 2, 8, AMBER); p(c, -3, 9, K.WHITE); p(c, 3, 9, K.WHITE); p(c, 0, 10, K.WHITE); }
  });
  /* --- marsh harrier --- */
  PFA.glyph('L06-harrier', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* marsh harrier quartering low: long narrow wings held in a shallow V, cream head and shoulders, tilting side to side */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, W = 7 + w, tl = fr === 1 ? 1 : fr === 3 ? -1 : 0, a, b, e;
    cl(c, 0, 0, 3, C); p(c, 0, -1, A); row(c, -1, 1, 4, Hi); p(c, 0, 5, Hi);
    for (e = -1; e <= 1; e += 2) for (a = 1; a <= W; a++) {
      b = 3 + Math.round(a * .45) + Math.round(tl * e * a / W * 1.5);
      p(c, e * a, b, a > W - 2 ? A : C); if (a < W - 1) p(c, e * a, b - 1, a < 3 ? Hi : C);
    }
  });
  PFA.glyph('L06-dangle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the harrier drops its long yellow legs: talons closed, spread, raking through the reeds, a grab */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, a, rk = fr === 2 ? -1 : 0;
    row(c, -2, 2, 8, C); row(c, -1, 1, 9, C); p(c, 0, 10, Hi); p(c, -1, 10, Hi);
    for (a = 3; a <= 6 + w; a++) { p(c, a, 8 + ((a - 3) >> 1), a > 5 ? A : C); p(c, -a, 8 + ((a - 3) >> 1), a > 5 ? A : C); }
    cl(c, -1, 5, 7, YEL); cl(c, 1, 5, 7, YEL); cl(c, -1 + rk, 2, 4, YEL); cl(c, 1 + rk, 2, 4, YEL);
    if (fr === 0) { p(c, -1, 1, A); p(c, 1, 1, A); }
    else if (fr === 1) { p(c, -3, 1, A); p(c, -2, 1, A); p(c, 0, 1, A); p(c, 2, 1, A); p(c, 3, 1, A); }
    else if (fr === 2) { p(c, -3, 1, A); p(c, -2, 0, A); p(c, 0, 1, A); p(c, 1, 0, A); row(c, -6, -4, 0, Hi); row(c, -5, -3, -1, Hi); }
    else { p(c, -1, 1, A); p(c, 1, 1, A); row(c, -1, 1, 0, REED); p(c, -2, -1, REED); p(c, 2, 0, CATTAIL); }
  });
  PFA.glyph('L06-reeds', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a reed bed: stems part, the harrier folds its wings and drops in, the reeds close over and sway */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, i, a0, h, tip, b;
    for (i = -1; i <= 1; i++) {
      a0 = i * 3; h = 6 + w + (i === 0 ? 2 : i > 0 ? 1 : 0);
      tip = fr === 0 ? i : fr === 2 ? -i : fr === 3 ? 1 : 0;
      for (b = 0; b <= h; b++) p(c, a0 + Math.round(tip * b / h), b, REED);
      p(c, a0 + tip, h + 1, CATTAIL); p(c, a0 + tip, h + 2, CATTAIL);
    }
    if (fr === 1) { p(c, 0, 9, Hi); p(c, 0, 8, C); p(c, -1, 10, C); p(c, -2, 11, A); p(c, 1, 10, C); p(c, 2, 11, A); }
    if (fr === 2) p(c, 0, 5, Hi);
  });
  PFA.glyph('L06-vshadow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* the harrier's narrow V shadow flitting over marsh water, glints rippling where it passes */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, a, b;
    for (a = -6 - w; a <= 6 + w; a++) { b = 2 + Math.round(Math.abs(a) * .35); p(c, a, b, A); if (Math.abs(a) < 4) p(c, a, b - 1, A); if ((a + fr + 9) % 3 === 0) p(c, a, b + 1, C); }
    p(c, 0, 0, A); p(c, 0, 4, Hi);
    p(c, -5 + fr * 2, -1, K.DEW); p(c, -4 + fr * 2, -1, K.DEW); p(c, 4 - fr, 0, K.DEW); p(c, 5 - fr, 0, K.WHITE);
  });
  /* --- shared: hooked raptor beak --- */
  PFA.glyph('L06-beak', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a raptor head side-on, the hooked beak: closed, gaping, snapping shut with flecks, tearing a shred */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0;
    row(c, -3 - w, 1, 1, C); row(c, -3 - w, 2, 2, C); row(c, -3 - w, 2, 3, C); row(c, -2, 1, 4, C); p(c, -1, 2, A);
    p(c, 0, 3, A); p(c, -1, 3, Hi); p(c, 2, 3, CERE);
    p(c, 3, 3, BEAK); p(c, 4, 3, BEAK); p(c, 4, 2, BEAK); p(c, 5, 2, BEAK); p(c, 5, 1, A);
    if (fr === 1) { p(c, 3, 1, BEAK); p(c, 4, 0, BEAK); } else p(c, 3, 2, BEAK);
    if (fr === 2) { p(c, 6, 4, K.WHITE); p(c, 7, 2, Hi); p(c, 6, 0, Hi); }
    if (fr === 3) { p(c, 5, 0, Hi); p(c, 6, -1, Hi); p(c, 6, 0, C); }
  });

  /* ================= motions (mutate the scratch G; fr picks the glyph frame) ================= */
  PFA.motion('L06-glide', function (G, pp, k) { G.t += Math.sin(pp * 4 + k) * 2; G.up += Math.sin(pp * 3 + k); G.fr = G.u > .55 && G.u < 1 ? 3 : [0, 0, 1, 2][(Math.floor(pp * 5) + k) & 3]; });   /* silent glide, a rare beat, talons at the end */
  PFA.motion('L06-hootpulse', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 3) + k) & 3; });                                                                         /* twit ... twoo */
  PFA.motion('L06-puffup', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; G.d += G.fr === 2 ? 1 : 0; });                                                              /* fluffs up and settles */
  PFA.motion('L06-freeze', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; G.t += G.fr === 1 ? 1 : G.fr === 3 ? -1 : 0; });                                            /* frozen, a shiver */
  PFA.motion('L06-hushsway', function (G, pp, k) { G.t += Math.sin(pp * 4 + k * 1.3) * 2; G.up += Math.sin(pp * 2.5 + k) * 1.2; G.fr = (Math.floor(pp * 3) + k) & 3; });          /* soft feathers sway */
  PFA.motion('L06-lampstare', function (G, pp, k, ph) { G.fr = [0, 1, 0, 0, 2, 0, 3, 1][(Math.floor(pp * 6 + ph * 4) + k) & 7]; G.t += Math.sin(pp * 2 + k) * .6; });                /* wide, narrow, lids, a slow blink */
  PFA.motion('L06-tuftflick', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; G.up += G.fr === 1 ? 1 : 0; });                                                          /* tufts flick up and flatten */
  PFA.motion('L06-nightdive', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; G.fr = w < .35 ? 0 : w < .65 ? 1 : w < .85 ? 3 : 2; G.d += G.fr === 1 ? 2 : 0; G.up += Math.sin(w * Math.PI) * 2; });   /* spread, stoop, strike, brake */
  PFA.motion('L06-boom', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 2) + k) & 3; });                                                                              /* throat swells, rings roll */
  PFA.motion('L06-soar', function (G, pp, k) { G.t += Math.sin(pp * 2 + k) * 2.5; G.up += Math.sin(pp * 1.5 + k * 1.7) * 1.5; G.fr = (Math.floor(pp * 3) + k) & 3; });             /* slow soaring, rocking on the wind */
  PFA.motion('L06-downstroke', function (G, pp, k, ph) { var w = (pp * 2.2 + ph) % 1; G.fr = w < .3 ? 0 : w < .5 ? 1 : w < .7 ? 2 : 3; G.d += G.fr >= 2 ? 1 : 0; });               /* raise, sweep, down, gust */
  PFA.motion('L06-peck', function (G, pp, k, ph) { var w = (pp * 3 + ph) % 1; G.fr = w < .4 ? 0 : w < .6 ? 1 : w < .8 ? 2 : 3; G.d += G.fr === 1 ? 2 : G.fr === 2 ? 3 : 0; });     /* stretch, peck, tear */
  PFA.motion('L06-bonespin', function (G, pp, k) { G.fr = G.u > .82 ? 4 : (Math.floor(pp * 12) + k) & 3; });                                                                     /* spins end over end, shatters at the end */
  PFA.motion('L06-crack', function (G, pp, k, ph) { var u = (G.u + ph * .15) % 1; G.fr = u < .25 ? 0 : u < .45 ? 1 : u < .75 ? 2 : 3; });                                          /* crack, split, marrow rises */
  PFA.motion('L06-perch', function (G, pp, k) { G.fr = (Math.floor(pp * 3) + k) & 3; });                                                                                          /* looks about, beard sways, shrugs */
  PFA.motion('L06-wedgeglide', function (G, pp, k) { G.t += Math.sin(pp * 3 + k) * 2; G.up += Math.sin(pp * 2 + k) * 1.5; G.fr = (Math.floor(pp * 4) + k) & 1; });               /* long glide, wingtips flexing */
  PFA.motion('L06-pick', function (G, pp, k, ph) { var w = (pp * 2.6 + ph) % 1; G.fr = w < .5 ? 0 : w < .7 ? 1 : w < .85 ? 2 : 3; });                                              /* dip, pick, toss a fleck, swallow */
  PFA.motion('L06-circle', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k * 2) & 7; G.t += Math.sin(pp * 2 + k); });                                                       /* the kettle turns */
  PFA.motion('L06-ruffle', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 2) + k) & 3; });                                                                            /* neck in, out, ruff fluffed */
  PFA.motion('L06-rakedown', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .25 ? 0 : w < .5 ? 1 : w < .75 ? 2 : 3; });                                          /* plunge, tear, drip */
  PFA.motion('L06-doze', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 3 + ph * 2) + k) & 3; G.up += (Math.floor(pp * 4) + k) & 1; });                                       /* nodding off, breathing */
  PFA.motion('L06-glance', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 3) + k) & 3; G.t += G.fr === 1 ? -1 : G.fr === 2 ? 1 : 0; });                              /* glance, glance, glare */
  PFA.motion('L06-quarter', function (G, pp, k) { var s = Math.sin(pp * 5 + k); G.t += s * 3; G.fr = s > .5 ? 1 : s < -.5 ? 3 : 0; G.up += Math.sin(pp * 2.5 + k); });           /* quartering side to side, tilting */
  PFA.motion('L06-dangling', function (G, pp, k, ph) { var w = (pp * 2.4 + ph) % 1; G.fr = w < .3 ? 0 : w < .55 ? 1 : w < .8 ? 2 : 3; G.d += G.fr === 2 ? 1 : 0; });              /* legs down, spread, rake, grab */
  PFA.motion('L06-reedfold', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 2) + k) & 3; G.t += Math.sin(pp * 3 + k) * .8; });                                       /* part, drop in, close, sway */
  PFA.motion('L06-shadowskim', function (G, pp, k) { G.s += pp * .25; G.fr = (Math.floor(pp * 12) + k) & 3; G.d -= 1; });                                                       /* the shadow slides low and fast */
  PFA.motion('L06-tear', function (G, pp, k, ph) { var w = (pp * 2.5 + ph) % 1; G.fr = w < .3 ? 0 : w < .5 ? 1 : w < .7 ? 2 : 3; G.d += G.fr === 1 ? 1 : G.fr === 3 ? -1 : 0; });  /* gape, snap, tug back */

  /* ================= custom chain effects (along the OUTER loop from e.a over e.d, eased e.hh) ================= */
  function carTawny(c, e, H) {          /* the tawny owl glides to the next piece without a sound: no trail, just a few soft feather motes; talons drop on arrival */
    var P = e.P, Q = H.Q, k, u, h, fr;
    for (k = 1; k <= 4; k++) { u = e.hh - k * .05; if (u < 0) break; if ((k + Math.floor(e.p * 20)) & 1) continue; P.atq(e.a + e.d * u); h = 5 + Math.sin(u * Math.PI) * 4; H.px(c, Q.x + Q.nx * h, Q.y + Q.ny * h, e.hi); }
    P.atq(e.a + e.d * e.hh); h = 6 + Math.sin(e.hh * Math.PI) * 4; fr = e.hh > .88 ? 3 : (Math.floor(e.p * 6) & 3) === 1 ? 1 : 0;
    H.glyph(c, 'L06-tawny', Q.x + Q.nx * h, Q.y + Q.ny * h, e.z > 1 ? 1 : e.z, fr, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  function carSoar(c, e, H) {           /* the condor soars high over the outer edge to the next piece, rocking, its cross-shaped shadow sliding along the edge below */
    var P = e.P, Q = H.Q, j, h;
    P.atq(e.a + e.d * e.hh);
    for (j = -5; j <= 5; j++) H.px(c, Q.x + Q.nx * 2 - Q.ny * j, Q.y + Q.ny * 2 + Q.nx * j, e.acc);
    H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.acc); H.px(c, Q.x + Q.nx * 1, Q.y + Q.ny * 1, e.acc);
    h = 11 + Math.sin(e.p * 5) * 2;
    H.glyph(c, 'L06-condor', Q.x + Q.nx * h, Q.y + Q.ny * h, e.z > 1 ? 1 : e.z, Math.floor(e.p * 4) & 3, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  function carBone(c, e, H) {           /* the lammergeier carries a bone high along the edge, lets it fall onto the next piece and it shatters */
    var P = e.P, Q = H.Q, sd = e.d < 0 ? -1 : 1, v = Math.min(1, e.hh / .7), t, hb, fr;
    P.atq(e.a + e.d * v);
    H.glyph(c, 'L06-wedgetail', Q.x + Q.nx * 14, Q.y + Q.ny * 14, e.z > 1 ? 1 : e.z, Math.floor(e.p * 8) & 1, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
    if (e.hh < .7) { hb = 9; fr = 0; }
    else { t = (e.hh - .7) / .3; hb = 9 * (1 - t * t) + 1; fr = t > .9 ? 4 : Math.floor(e.p * 12) & 3; }
    H.glyph(c, 'L06-bone', Q.x + Q.nx * hb, Q.y + Q.ny * hb, 0, fr, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  function carKettle(c, e, H) {         /* a kettle of griffons circles along the outer edge to the next piece, warm-air specks rising behind */
    var P = e.P, Q = H.Q, j, u, h;
    for (j = 1; j <= 5; j++) { u = e.hh - j * .05; if (u < 0) break; P.atq(e.a + e.d * u); h = 3 + ((e.p * 30 + j * 3) % 9); H.px(c, Q.x + Q.nx * h, Q.y + Q.ny * h, e.hi); }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'L06-kettle', Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.z > 1 ? 1 : e.z, Math.floor(e.p * 24) & 7, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  function carQuarter(c, e, H) {        /* the harrier quarters low over a strip of reeds along the outer edge, tilting as it zigzags */
    var P = e.P, Q = H.Q, u, i = 0, j, sw, u0 = Math.max(0, e.hh - .35), h, sd = e.d < 0 ? -1 : 1, sn;
    for (u = u0; u <= e.hh; u += .035, i++) {
      P.atq(e.a + e.d * u); sw = Math.sin(e.p * 12 + i);
      for (j = 1; j <= 3; j++) H.px(c, Q.x + Q.nx * (1 + j) - Q.ny * sw * j / 3, Q.y + Q.ny * (1 + j) + Q.nx * sw * j / 3, REED);
      H.px(c, Q.x + Q.nx * 5 - Q.ny * sw, Q.y + Q.ny * 5 + Q.nx * sw, CATTAIL);
    }
    sn = Math.cos(e.hh * Math.PI * 4); h = 7 + Math.abs(Math.sin(e.hh * Math.PI * 4)) * 4;
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'L06-harrier', Q.x + Q.nx * h, Q.y + Q.ny * h, e.z > 1 ? 1 : e.z, sn * sd > .3 ? 1 : sn * sd < -.3 ? 3 : 0, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }

  /* ================= motifs ================= */
  function M(name, meta) { PFA.motif(name, comp, meta); }
  /* tawny owl */
  M('tawny-glide', { nm: 'silent tawny glide', desc: 'a round-headed tawny owl head-on with dark eyes and a pale facial disc, wings spread and fringed, gliding without a sound and dropping its talons; the chain is the owl gliding to the next piece with no trail at all', fam: 'thrust', gap: 18, g: 'L06-tawny', mo: 'L06-glide', x: '-', car: 'custom', carDraw: carTawny });
  M('twit-twoo', { nm: 'twit-twoo', desc: 'a small owl head hooting: a short white "twit" tick, then the long "twoo" rings widening out of it', fam: 'ripple', gap: 16, g: 'L06-hoot', mo: 'L06-hootpulse', x: '-', car: 'rings' });
  M('tawny-fluffball', { nm: 'fluffed owl', desc: 'the tawny owl puffed into a round barred ball of feathers, eyes shut to slits, feather tips bristling as it swells', fam: 'shield', gap: 16, g: 'L06-fluffball', mo: 'L06-puffup', x: '-', car: 'hop' });
  M('mouse-freeze', { nm: 'frozen mice', desc: 'grey wood mice frozen stiff with rigid tails, shivering, a white "!" popping over them', fam: 'shield', gap: 14, g: 'L06-mouse', mo: 'L06-freeze', x: '-', car: 'train' });
  M('hush-plume', { nm: 'hush feathers', desc: 'soft barred owl feathers with comb-fringed edges swaying without a sound', fam: 'shield', gap: 12, g: 'L06-plume', mo: 'L06-hushsway', x: '-', car: 'flutter' });
  /* eagle owl */
  M('lamp-eyes', { nm: 'lamp eyes', desc: 'two great orange eyes under feathered brows: wide, pupils shrinking, lids lowering, a slow blink', fam: 'sparkle', gap: 18, g: 'L06-lamps', mo: 'L06-lampstare', x: '-', car: 'blink' });
  M('ear-horns', { nm: 'ear horns', desc: 'a mottled eagle-owl head with orange eyes and two big ear tufts flicking up, flattening back, one cocked', fam: 'slash', gap: 16, g: 'L06-earhorn', mo: 'L06-tuftflick', x: '-', car: 'comet' });
  M('night-stoop', { nm: 'night stoop', desc: 'a huge tufted owl in flight against the moon: wings spread, folded into a stoop, talons thrown forward, braking', fam: 'thrust', gap: 20, g: 'L06-nightowl', mo: 'L06-nightdive', x: 'moon', car: 'comet' });
  M('boom-hoot', { nm: 'deep hoot', desc: 'a tufted head whose white throat puffs out for a deep hoot, wide flat rings rolling away low', fam: 'ripple', gap: 18, g: 'L06-boohoo', mo: 'L06-boom', x: '-', car: 'rings' });
  /* condor */
  M('condor-span', { nm: 'condor span', desc: 'the condor soaring on huge flat black wings with a white band and fingered tips, a bald red head on a white ruff, rocking on the wind; the chain is the condor soaring high with its shadow sliding along the edge', fam: 'bash', gap: 22, g: 'L06-condor', mo: 'L06-soar', x: '-', car: 'custom', carDraw: carSoar });
  M('wing-gust', { nm: 'wing gusts', desc: 'one great black-and-white wing in a downstroke, the shoved air bursting out in white gust lines', fam: 'puff', gap: 16, g: 'L06-beat', mo: 'L06-downstroke', x: 'puff', car: 'flutter' });
  M('bald-peck', { nm: 'bald pecks', desc: 'a wrinkled bald red head on a white ruff stretching out, pecking with a hooked ivory beak and tearing a scrap', fam: 'bite', gap: 14, g: 'L06-baldhead', mo: 'L06-peck', x: '-', car: 'hop' });
  /* lammergeier */
  M('ossifrage-bone', { nm: 'dropped bones', desc: 'long knobbed bones spinning end over end and shattering into splinters with a fleck of marrow; the chain is the bird carrying a bone high and dropping it onto the next piece', fam: 'bash', gap: 16, g: 'L06-bone', mo: 'L06-bonespin', x: '-', car: 'custom', carDraw: carBone });
  M('marrow-split', { nm: 'marrow', desc: 'a bone cracking and splitting open, the golden marrow inside glowing, a bead of it floating up', fam: 'mend', gap: 16, g: 'L06-marrow', mo: 'L06-crack', x: '-', car: 'trail' });
  M('ledge-perch', { nm: 'ledge perch', desc: 'the lammergeier perched upright on a rock ledge: orange chest, black beard, red eye ring, long wedge tail hanging over the ledge', fam: 'shield', gap: 18, g: 'L06-perch', mo: 'L06-perch', x: '-', car: 'hop' });
  M('wedge-glide', { nm: 'wedge tail', desc: 'a long narrow-winged silhouette with an orange body and a long diamond wedge tail, gliding with flexing wingtips', fam: 'slash', gap: 18, g: 'L06-wedgetail', mo: 'L06-wedgeglide', x: '-', car: 'comet' });
  M('beard-pick', { nm: 'beard picks', desc: 'a pale bearded head side-on with a black mask and red eye ring dipping to pick a carcass clean, bone flecks flicked away', fam: 'mend', gap: 14, g: 'L06-beard', mo: 'L06-pick', x: 'crumbs', car: 'hop' });
  /* griffon vulture */
  M('griffon-kettle', { nm: 'kettle', desc: 'three broad-winged griffons with pale heads circling round one point; the chain is the kettle circling along the edge with warm-air specks rising', fam: 'puff', gap: 20, g: 'L06-kettle', mo: 'L06-circle', x: '-', car: 'custom', carDraw: carKettle });
  M('down-ruff', { nm: 'down ruff', desc: 'a white downy ruff worn like a shawl, dark wings drawn round it, the bare neck pulled in or stretched up', fam: 'shield', gap: 16, g: 'L06-ruff', mo: 'L06-ruffle', x: '-', car: 'train' });
  M('carrion-rake', { nm: 'carrion rake', desc: 'a long bare neck plunging out of a white ruff, the hooked beak tearing, dark gore dripping', fam: 'drip', gap: 16, g: 'L06-rake', mo: 'L06-rakedown', x: '-', car: 'comet' });
  M('patient-hunch', { nm: 'patient hunch', desc: 'a gorged vulture hunched with shoulders up and head sunk in its ruff, eyes closing, nodding off with little z marks', fam: 'mend', gap: 16, g: 'L06-hunch', mo: 'L06-doze', x: '-', car: 'hop' });
  M('bald-glare', { nm: 'bald glare', desc: 'a pale bald head on a long thin neck with one fierce amber eye, glancing left and right, then glaring', fam: 'web', gap: 16, g: 'L06-glare', mo: 'L06-glance', x: '-', car: 'blink' });
  /* marsh harrier */
  M('v-quarter', { nm: 'quartering harrier', desc: 'a harrier with long narrow wings held in a shallow V, cream head and shoulders, tilting side to side low over the ground; the chain is the harrier quartering in a zigzag over a strip of reeds', fam: 'thrust', gap: 20, g: 'L06-harrier', mo: 'L06-quarter', x: '-', car: 'custom', carDraw: carQuarter });
  M('leg-dangle', { nm: 'dangling legs', desc: 'the harrier dropping its long yellow legs, talons closed, spread, raking through the reeds, grabbing', fam: 'slash', gap: 14, g: 'L06-dangle', mo: 'L06-dangling', x: '-', car: 'comet' });
  M('reed-drop', { nm: 'reed drop', desc: 'reed stems with brown cattail heads parting, a harrier folding its wings and dropping in, the reeds closing over and swaying', fam: 'puff', gap: 14, g: 'L06-reeds', mo: 'L06-reedfold', x: '-', car: 'flutter' });
  M('v-shadow', { nm: 'V shadow', desc: 'a narrow V-shaped shadow flitting low over marsh water, glints rippling where it passes', fam: 'ripple', gap: 18, g: 'L06-vshadow', mo: 'L06-shadowskim', x: '-', car: 'blink' });
  /* shared by the batch's beak class pieces */
  M('hook-tear', { nm: 'hooked beaks', desc: 'a raptor head side-on with a yellow cere and a hooked beak gaping, snapping shut with flecks and tearing a shred', fam: 'bite', gap: 14, g: 'L06-beak', mo: 'L06-tear', x: '-', car: 'comet' });
})();
