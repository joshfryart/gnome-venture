/* Motif module, medium batch m13 (fox-kit-pair, fennec, frost-hare, mountain-hare, jackrabbit, grumpy-lemming, pika-sentry, marmot-bruiser,
   glacier-cub, reindeer-calf-herd). TEMPLATE.md section 10.3.
   38 motifs, glyph and motion ids prefixed m13-. Every creature of the batch has its own signature motif with its own chain effect (carDraw):
   two fox kits leapfrogging, a fennec trotting with its ears bobbing, a frost hare bounding with Y-shaped tracks, a mountain hare loping uphill,
   a jackrabbit sprinting low, a grumpy lemming stomping under its own rain cloud, a pika scampering with a mouthful of hay, a marmot waddle-rolling,
   a glacier cub belly-sliding on ice, and a line of reindeer calves trotting with clicking knees.
   One motif is shared by the three hares (hare-hind-kick, the big hind foot kicking), each with its own palette and layout.
   The three hares are drawn by one side-view routine (hare) so they read as relatives; the frost hare has black ear tips, the mountain hare
   big pale feet, the jackrabbit a lean long-legged body and sail ears.
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation in the frame loops (scratch H.Q / H.G only).
   Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy
   default are untouched. */
(function () {
  /* fixed accent colours: 0 white, 1 eye black, 2 nose pink, 3 grass green, 4 clover green, 5 flower yellow, 6 flower purple, 7 stone grey,
     8 lichen, 9 sand, 10 soil, 11 dark soil, 12 anger red, 13 ice blue, 14 storm grey, 15 moon cream, 16 steam, 17 sage, 18 straw, 19 vein red */
  var XC = ['#ffffff', '#141418', '#f0a0a8', '#62a040', '#4a9a40', '#f2d43a', '#b080d0', '#9a9aa4', '#c8d070', '#e8d8a8', '#8a6a44', '#4a3220',
    '#ff4a3a', '#bfe8ff', '#5a5e6e', '#f4f0c0', '#e8eef4', '#9ab08a', '#d8c070', '#d04a4a'];

  function face(tx, nx, ny) { return Math.abs(nx) > Math.abs(ny) ? (nx > 0 ? 1 : -1) : (tx >= 0 ? 1 : -1); }
  function sgnOf(d) { return d >= 0 ? 1 : -1; }

  /* ---------- shared drawing routines ---------- */
  /* fox kit head, front view: tall pointed ears with dark tips, russet face, white muzzle and cheeks, black nose and eyes; e = eyes shut */
  function kit(c, K, x, y, C, A, Hi, e) {
    K.px(c, x - 3, y - 5, A); K.bx(c, x - 3, y - 4, 1, 2, C); K.bx(c, x - 2, y - 4, 1, 2, C); K.px(c, x - 2, y - 3, Hi);
    K.px(c, x + 3, y - 5, A); K.bx(c, x + 3, y - 4, 1, 2, C); K.bx(c, x + 2, y - 4, 1, 2, C); K.px(c, x + 2, y - 3, Hi);
    K.bx(c, x - 3, y - 2, 7, 3, C); K.bx(c, x - 2, y + 1, 5, 1, C);
    K.bx(c, x - 1, y, 3, 2, Hi); K.px(c, x - 3, y, Hi); K.px(c, x + 3, y, Hi);
    K.px(c, x, y, XC[1]);
    if (e) { K.px(c, x - 2, y - 1, A); K.px(c, x - 1, y - 1, A); K.px(c, x + 1, y - 1, A); K.px(c, x + 2, y - 1, A); }
    else { K.px(c, x - 2, y - 1, XC[1]); K.px(c, x + 2, y - 1, XC[1]); }
  }
  /* fennec face, front view: huge cream ears with pink insides that swivel (s -1 / 0 / 1), tiny face, big black eyes */
  function fennec(c, K, x, y, s, C, A, Hi) {
    var i, j, L, ox, oy;
    for (j = 0; j < 2; j++) { L = j ? 1 : -1;
      for (i = 0; i < 6; i++) { ox = x + L * (2 + Math.round(i * (s === L ? .8 : s === -L ? .3 : .5))); oy = y - 2 - i;
        K.px(c, ox + L, oy, i < 5 ? C : A); K.px(c, ox, oy, i > 0 && i < 5 ? Hi : C); } }
    K.bx(c, x - 2, y - 2, 5, 3, C); K.px(c, x - 1, y + 1, C); K.px(c, x + 1, y + 1, C);
    K.px(c, x - 1, y - 1, XC[1]); K.px(c, x + 1, y - 1, XC[1]); K.px(c, x, y + 1, XC[1]); K.px(c, x - 1, y - 2, A); K.px(c, x + 1, y - 2, A);
  }
  /* side-view hare facing fl. pose 0 = sitting (ears up), 1 = full stretch in the air, 2 = landing crouch (ears back), 3 = lean low sprint (long legs).
     T = ear-tip colour, F = foot colour; o = 1 for sail ears (jackrabbit: taller, pink veined) */
  function hare(c, K, x, y, fl, pose, C, A, Hi, T, F, o) {
    var i, X, eh = o ? 7 : 5;
    if (pose === 1 || pose === 3) {
      for (i = -4; i <= 3; i++) { X = x + fl * i; K.px(c, X, y - 1, C); K.px(c, X, y, i > -3 && i < 3 ? C : A); }
      K.px(c, x + fl * 4, y - 2, C); K.px(c, x + fl * 5, y - 2, XC[1]); K.px(c, x + fl * 4, y - 1, C); K.px(c, x + fl * 5, y - 1, C); K.px(c, x + fl * 6, y - 1, XC[2]);
      for (i = 0; i < eh - 1; i++) K.px(c, x + fl * (3 - i), y - 3 - (i >> 2), i > eh - 3 ? T : (o && (i & 1) ? Hi : C));
      K.px(c, x + fl * 5, y + 1, C); K.px(c, x + fl * 6 + (pose === 3 ? fl : 0), y + 1, A);
      K.px(c, x - fl * 5, y + 1, C); K.px(c, x - fl * 6, y + 1, F); K.px(c, x - fl * 7, y + 1, F); if (pose === 3) K.px(c, x - fl * 8, y + 1, F);
      K.px(c, x - fl * 5, y - 1, Hi);
      return;
    }
    K.bx(c, x - 3, y - 1, 6, 3, C); K.px(c, x - fl * 3, y - 1, C); K.px(c, x - fl * 4, y - 1, Hi); K.px(c, x - fl * 4, y, Hi);
    K.bx(c, x + fl * 2 - (fl < 0 ? 2 : 0), y - 3, 3, 2, C); K.px(c, x + fl * 3, y - 3, XC[1]); K.px(c, x + fl * 4, y - 2, A);
    if (pose === 2) { for (i = 0; i < eh - 1; i++) K.px(c, x + fl * (1 - i), y - 4 - (i > 2 ? 1 : 0), i > eh - 3 ? T : (o && (i & 1) ? Hi : C)); }
    else for (i = 0; i < eh; i++) { K.px(c, x + fl * 2, y - 4 - i, i > eh - 3 ? T : C); K.px(c, x + fl * 1, y - 4 - i, i > eh - 3 ? T : (o ? (i > 0 ? Hi : C) : C)); if (o && i === 3) K.px(c, x + fl * 1, y - 4 - i, XC[19]); }
    for (i = -4; i <= -1; i++) K.px(c, x + fl * i, y + 2, F);
    K.px(c, x + fl * 2, y + 2, A); K.px(c, x + fl * 3, y + 2, A);
  }
  /* round lemming: black cap, orange back, scowling brows, buck teeth; m = mouth open, r = anger mark */
  function lemming(c, K, x, y, C, A, Hi, m, r) {
    K.bx(c, x - 3, y - 2, 7, 5, C); K.bx(c, x - 2, y - 3, 5, 1, A); K.bx(c, x - 3, y - 2, 7, 1, A); K.px(c, x - 4, y, C); K.px(c, x + 4, y, C);
    K.px(c, x - 3, y - 3, A); K.px(c, x + 3, y - 3, A);
    K.px(c, x - 2, y - 1, XC[1]); K.px(c, x - 1, y - 1, XC[1]); K.px(c, x + 1, y - 1, XC[1]); K.px(c, x + 2, y - 1, XC[1]);
    K.px(c, x - 2, y, XC[1]); K.px(c, x + 2, y, XC[1]);
    K.px(c, x, y + 1, XC[2]); K.px(c, x, y + 2, m ? XC[1] : Hi); K.px(c, x - 1, y + 2, Hi); K.px(c, x + 1, y + 2, Hi);
    if (r) { K.px(c, x + 4, y - 4, XC[12]); K.px(c, x + 6, y - 4, XC[12]); K.px(c, x + 5, y - 5, XC[12]); K.px(c, x + 5, y - 3, XC[12]); }
  }
  /* round pika on a rock: no tail, round ears; m = calling (mouth open), lk = look -1 / 0 / 1 */
  function pika(c, K, x, y, C, A, Hi, m, lk) {
    K.bx(c, x - 3, y - 2, 7, 4, C); K.bx(c, x - 2, y - 3, 5, 1, C); K.bx(c, x - 2, y + 2, 5, 1, C);
    K.sq(c, x - 3, y - 4, 2, C); K.sq(c, x + 3, y - 4, 2, C); K.px(c, x - 3, y - 5, Hi); K.px(c, x + 3, y - 5, Hi);
    K.px(c, x - 1 + lk, y - 1, XC[1]); K.px(c, x + 1 + lk, y - 1, XC[1]); K.px(c, x + lk, y, A);
    if (m) { K.px(c, x + lk, y + 1, XC[1]); K.px(c, x + lk * 4 + 4, y - 2, Hi); K.px(c, x + lk * 4 + 5, y - 3, Hi); K.px(c, x + lk * 4 + 5, y - 1, Hi); }
    K.px(c, x - 2, y + 2, Hi); K.px(c, x + 2, y + 2, Hi);
  }
  /* fat marmot standing tall: dark face mask, pale belly, paws tucked; st 0 stand, 1 whistle, 2 squashed sit */
  function marmot(c, K, x, y, C, A, Hi, st) {
    var sh = st === 2 ? 2 : 0, w = st === 2 ? 9 : 7;
    K.bx(c, x - (w >> 1), y - 3 + sh, w, 6 - sh, C); K.bx(c, x - (w >> 1) + 1, y - 4 + sh, w - 2, 1, C); K.bx(c, x - 1, y - 2 + sh, 3, 4 - sh, Hi);
    K.bx(c, x - 2, y - 7 + sh, 5, 3, C); K.bx(c, x - 1, y - 6 + sh, 3, 2, A); K.px(c, x - 1, y - 6 + sh, XC[1]); K.px(c, x + 1, y - 6 + sh, XC[1]);
    K.px(c, x - 2, y - 8 + sh, A); K.px(c, x + 2, y - 8 + sh, A); K.px(c, x, y - 4 + sh, st === 1 ? XC[1] : Hi);
    K.px(c, x - 2, y - 3 + sh, A); K.px(c, x + 2, y - 3 + sh, A);
    K.px(c, x - (w >> 1), y + 3, A); K.px(c, x + (w >> 1), y + 3, A);
    if (st === 1) { K.px(c, x + 3, y - 7, XC[0]); K.px(c, x + 4, y - 8, XC[0]); K.px(c, x + 5, y - 9, XC[0]); K.px(c, x + 4, y - 6, XC[0]); K.px(c, x + 6, y - 6, XC[0]); }
  }
  /* round glacier cub face: white-blue fur, small round ears, black eyes and nose, frost crystals on the crown; b = blink */
  function icecub(c, K, x, y, C, A, Hi, b) {
    K.bx(c, x - 3, y - 2, 7, 5, C); K.bx(c, x - 2, y - 3, 5, 1, C); K.bx(c, x - 2, y + 3, 5, 1, C);
    K.sq(c, x - 3, y - 3, 2, C); K.sq(c, x + 4, y - 3, 2, C); K.px(c, x - 3, y - 3, A); K.px(c, x + 3, y - 3, A);
    K.px(c, x - 1, y - 1, b ? A : XC[1]); K.px(c, x + 1, y - 1, b ? A : XC[1]); K.bx(c, x - 1, y + 1, 3, 1, Hi); K.px(c, x, y + 1, XC[1]);
    K.px(c, x - 1, y - 4, Hi); K.px(c, x + 1, y - 5, Hi); K.px(c, x + 1, y - 3, XC[0]);
  }
  /* reindeer calf head, front view: fuzzy velvet antler buds, big dark eyes, cream muzzle; l = head lowered (butting), m = bleating */
  function calf(c, K, x, y, C, A, Hi, l, m) {
    var dy = l ? 2 : 0;
    K.bx(c, x - 2, y - 2 + dy, 5, 4, C); K.bx(c, x - 1, y + 2 + dy, 3, 2, Hi); K.px(c, x - 1, y + 2 + dy, XC[1]); K.px(c, x + 1, y + 2 + dy, XC[1]);
    K.px(c, x - 3, y - 2 + dy, C); K.px(c, x - 4, y - 3 + dy, C); K.px(c, x + 3, y - 2 + dy, C); K.px(c, x + 4, y - 3 + dy, C);
    K.px(c, x - 1, y - 1 + dy, XC[1]); K.px(c, x + 1, y - 1 + dy, XC[1]); K.px(c, x - 1, y - 2 + dy, XC[0]);
    K.bx(c, x - 2, y - 4 + dy, 2, 2, A); K.bx(c, x + 1, y - 4 + dy, 2, 2, A); K.px(c, x - 2, y - 5 + dy, Hi); K.px(c, x + 2, y - 5 + dy, Hi);
    if (m) { K.px(c, x, y + 4 + dy, XC[1]); K.px(c, x - 1, y + 4 + dy, A); K.px(c, x + 1, y + 4 + dy, A); }
  }

  /* ---------- own-edge composition with a per-run decoration (the page's themedOwn() plus deco) ---------- */
  function comp(c, e, H, deco) {
    var runs = e.runs, mp = e.mp, M = e.M, z = e.z, p = e.p, pp = p * mp.spd, Q = H.Q, G = H.G, P = e.P,
      tie = mp.x === 'thread' || mp.lay === 'snare', ri, k, r, len, n, f, ph, sf, bx0, by0, nx, ny, x, y, lx = 0, ly = 0, has;
    for (ri = 0; ri < runs.length; ri++) {
      r = runs[ri]; len = r[1] - r[0]; n = Math.max(1, Math.min(7, Math.round(len / (M.gap || 12)))); if (mp.lay === 'lance') n = Math.min(n, 4); has = false;
      for (k = 0; k < n; k++) {
        f = (k + .5) / n; ph = H.hash(e.seed * 13 + k * 7 + ri * 31);
        H.lay(mp.lay, p, f, ph, k); H.mot(M.mo, pp, k, ph);
        if (G.vis <= 0 || !H.stip(G.vis, k + ri * 9, p)) { has = false; continue; }
        sf = G.s - Math.floor(G.s); P.atq(r[0] + len * sf); bx0 = Q.x; by0 = Q.y; nx = Q.nx; ny = Q.ny;
        x = bx0 + nx * G.d - ny * G.t; y = by0 + ny * G.d + nx * G.t - G.up;
        if (mp.x === 'threads') H.ln(c, bx0 + nx, by0 + ny, x, y, 1, e.hi);
        else if (mp.x === 'silk') H.ln(c, bx0 + ny * 9 + nx, by0 - nx * 9 + ny, x, y, 1, e.hi);
        if (tie && has && Math.abs(x - lx) + Math.abs(y - ly) < 30) H.ln(c, lx, ly, x, y, 1, e.hi);
        H.glyph(c, M.g, x, y, z, G.fr, e.col, e.acc, e.hi, -ny, nx, nx, ny); lx = x; ly = y; has = true;
      }
      H.ext(c, mp.x, P, r[0], len, ri, p, pp, e.col, e.acc, e.hi, e.seed);
      if (deco) deco(c, e, H, r[0], len, ri, pp);
    }
  }
  function decoSnow(c, e, H, s0, len, ri, pp) {          /* tundra: a snow line along the run with three flakes sifting down */
    var s, k, u, Q = H.Q; if (e.p > .92) return;
    for (s = 2; s < len; s += 5) { e.P.atq(s0 + s); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, H.WHITE); }
    for (k = 0; k < 3; k++) { u = (pp * .9 + k * .33) % 1; e.P.atq(s0 + len * H.hash(e.seed + k * 3 + ri)); H.px(c, Q.x + Q.nx * (4 + 4 * u) + Math.sin(u * 9 + k) * 2, Q.y + Q.ny * (4 + 4 * u) - 8 + u * 12, H.WHITE); }
  }
  function decoSand(c, e, H, s0, len, ri, pp) {          /* desert: a drifting sand ripple just outside the run */
    var s, Q = H.Q; if (e.p > .9) return;
    for (s = (pp * 6) % 4; s < len; s += 4) { e.P.atq(s0 + s); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, XC[9]); }
  }
  function decoScree(c, e, H, s0, len, ri, pp) {         /* mountain: grey scree pebbles lying along the run, one rattling */
    var k, Q = H.Q, j; if (e.p > .92) return;
    for (k = 0; k < 4; k++) { e.P.atq(s0 + len * (k + .5) / 4); j = (k === (Math.floor(pp * 6) & 3)) ? 1 : 0; H.bx(c, Q.x + Q.nx * 3 - 1, Q.y + Q.ny * 3 - j, 2, 1, k & 1 ? XC[7] : '#b8b8c0'); }
  }
  function plain(c, e, H) { comp(c, e, H, null); }
  function snow(c, e, H) { comp(c, e, H, decoSnow); }
  function sand(c, e, H) { comp(c, e, H, decoSand); }
  function scree(c, e, H) { comp(c, e, H, decoScree); }

  /* ---------- glyphs (tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step; fr from the motion) ---------- */
  /* fox kit pair */
  PFA.glyph('m13-kits', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* two fox kits: side by side (0), one crouches (1), pounces onto the other (2), both tumble (3) */
    var f = fr & 3;
    if (f === 2) { kit(c, K, x + 3, y + 2, C, A, Hi, 1); kit(c, K, x - 1, y - 3, C, A, Hi, 0); K.px(c, x - 6, y - 6, Hi); K.px(c, x - 7, y - 7, Hi); }
    else if (f === 3) { kit(c, K, x - 3, y + 1, C, A, Hi, 1); kit(c, K, x + 3, y, C, A, Hi, 1); K.px(c, x, y - 6, Hi); K.px(c, x - 1, y - 7, A); K.px(c, x + 1, y - 7, A); }
    else { kit(c, K, x - 4, y + (f === 1 ? 1 : 0), C, A, Hi, 0); kit(c, K, x + 4, y, C, A, Hi, 0); }
  });
  PFA.glyph('m13-kitden', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a den mouth in an earth bank: two pairs of ear tips and eyes peering out of the dark (blinking on fr) */
    var i;
    for (i = -5; i <= 5; i++) { K.px(c, x + i, y + 3, XC[10]); if (Math.abs(i) > 2) K.px(c, x + i, y + 2 - (Math.abs(i) === 3 ? 2 : Math.abs(i) === 4 ? 1 : 0), XC[11]); }
    K.bx(c, x - 2, y - 2, 5, 1, XC[11]); K.bx(c, x - 3, y - 1, 7, 4, XC[1]); K.bx(c, x - 2, y - 2, 5, 1, XC[1]);
    K.px(c, x - 3, y - 3, A); K.px(c, x - 1, y - 3, A); K.px(c, x + 1, y - 3, A); K.px(c, x + 3, y - 3, A);
    K.px(c, x - 3, y - 2, C); K.px(c, x - 1, y - 2, C); K.px(c, x + 1, y - 2, C); K.px(c, x + 3, y - 2, C);
    if (fr !== 1) { K.px(c, x - 3, y, Hi); K.px(c, x - 1, y, Hi); } if (fr !== 2) { K.px(c, x + 1, y + 1, Hi); K.px(c, x + 3, y + 1, Hi); }
    K.px(c, x - 4, y + 3, C); K.px(c, x + 4, y + 3, C);
  });
  PFA.glyph('m13-brushtail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a bushy fox-kit tail curled over the edge, white tip, the fur fluffing out (fr 1) */
    var i, a, r = 3 + (z > 1 ? 1 : 0), f = fr & 1, X, Y;
    for (i = 0; i < 9; i++) { a = 3.6 + i * .42; X = x + Math.cos(a) * r; Y = y + Math.sin(a) * r;
      K.sq(c, X, Y, 2 + (i > 2 && i < 7 ? 1 : 0) + f, i > 6 ? Hi : C); }
    K.px(c, x - r - 1, y + 2, A);
    if (f) { K.px(c, x - r - 2, y - 1, C); K.px(c, x, y - r - 3, C); K.px(c, x + r + 1, y - 3, Hi); K.px(c, x + 2, y - r - 2, C); }
  });
  PFA.glyph('m13-earnip', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a kit nipping its sibling's ear: one kit face, the other's ear tip in its mouth; tug (fr 1) with a tiny yelp mark */
    var f = fr & 1;
    kit(c, K, x - 1, y, C, A, Hi, f);
    K.px(c, x + 3, y + 2, C); K.px(c, x + 4, y + 1 - f, C); K.px(c, x + 5, y - f, A); K.px(c, x - 1, y + 2, XC[0]); K.px(c, x + 1, y + 2, XC[0]);
    if (f) { K.px(c, x + 6, y - 4, Hi); K.px(c, x + 6, y - 5, Hi); K.px(c, x + 6, y - 2, Hi); }
  });
  /* fennec */
  PFA.glyph('m13-fennec', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the fennec's huge pink-lined ears swivelling to listen (fr 0 up, 1 left, 2 right, 3 up) */
    var f = fr & 3; fennec(c, K, x, y + 2, f === 1 ? -1 : f === 2 ? 1 : 0, C, A, Hi);
  });
  PFA.glyph('m13-fenneccurl', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a fennec curled asleep in its burrow mouth: ears folded flat, the black-tipped tail over its nose, a Z rising (fr) */
    var i, a, X, Y;
    for (i = 0; i < 14; i++) { a = i * .45; K.px(c, x + Math.cos(a) * 3.5, y + Math.sin(a) * 2.5, C); }
    K.bx(c, x - 2, y - 1, 5, 3, C); K.px(c, x - 3, y - 3, C); K.px(c, x - 4, y - 3, Hi); K.px(c, x - 5, y - 2, C); K.px(c, x - 4, y - 2, Hi);
    K.px(c, x + 3, y + 1, A); K.px(c, x + 4, y + 1, A); K.px(c, x - 1, y, XC[1]); K.px(c, x, y, XC[1]);
    X = x + 3 + (fr & 1); Y = y - 5 - (fr % 3) * 2; K.bx(c, X, Y, 3, 1, XC[15]); K.px(c, X + 1, Y + 1, XC[15]); K.bx(c, X, Y + 2, 3, 1, XC[15]);
  });
  PFA.glyph('m13-sandfan', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a curtain of sand flung up by digging forepaws: grains fan out along the normal and hang (fr grows it) */
    var i, j, a, r, f = fr & 3;
    K.px(c, x - tx * 2, y - ty * 2, C); K.px(c, x + tx * 2, y + ty * 2, C); K.px(c, x - tx * 2 - nx, y - ty * 2 - ny, A); K.px(c, x + tx * 2 - nx, y + ty * 2 - ny, A);
    for (j = 0; j < 3; j++) for (i = -2; i <= 2; i++) { a = i * .35; r = 2 + j * 2 + f;
      K.px(c, x + (nx * Math.cos(a) - ny * Math.sin(a)) * r, y + (ny * Math.cos(a) + nx * Math.sin(a)) * r - j, (i + j) & 1 ? XC[9] : C); }
  });
  PFA.glyph('m13-earping', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* ears snap up at a sound: listening arcs spread from both ear tips (fr 0..2) */
    var f = fr % 3, r = 2 + f * 2, i, a;
    fennec(c, K, x, y + 3, 0, C, A, Hi);
    for (i = -2; i <= 2; i++) { a = i * .4; K.px(c, x - 5 - Math.cos(a) * r, y - 5 + Math.sin(a) * r, Hi); K.px(c, x + 5 + Math.cos(a) * r, y - 5 + Math.sin(a) * r, Hi); }
  });
  /* hares */
  PFA.glyph('m13-frosthare', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a white frost hare with black ear tips: sit (0), stretch (1), land in a frost spray (2) */
    var f = fr % 3; hare(c, K, x, y, face(tx, nx, ny), f, C, A, Hi, A, C, 0);
    if (f === 2) { K.px(c, x - 4, y + 3, Hi); K.px(c, x + 3, y + 3, Hi); K.px(c, x - 6, y + 1, Hi); K.px(c, x + 5, y + 1, Hi); K.px(c, x - 5, y + 2, K.WHITE); }
  });
  PFA.glyph('m13-hindkick', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a hare's big hind foot kicking straight out along the normal (fr 1), a puff where it lands */
    var f = fr & 1, L = f ? 6 + z : 2, i, X, Y;
    K.sq(c, x - nx * 2, y - ny * 2, 4, C); K.px(c, x - nx * 3 - tx, y - ny * 3 - ty, Hi);
    for (i = 0; i < L; i++) { X = x + nx * i; Y = y + ny * i; K.px(c, X, Y, C); K.px(c, X + tx, Y + ty, i > L - 3 ? A : C); }
    X = x + nx * L; Y = y + ny * L; K.px(c, X + tx * 2, Y + ty * 2, A); K.px(c, X - tx, Y - ty, A);
    if (f) { K.px(c, X + nx * 2, Y + ny * 2, K.WHITE); K.px(c, X + nx * 2 + tx * 2, Y + ny * 2 + ty * 2, Hi); K.px(c, X + nx * 2 - tx * 2, Y + ny * 2 - ty * 2, Hi); K.px(c, X + nx * 3, Y + ny * 3, Hi); }
  });
  PFA.glyph('m13-thump', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a hind foot stamps flat (fr 1 down) and shock rings spread on the snow either side */
    var f = fr % 3, i, r;
    K.bx(c, x - 3, y - 4 + (f ? 2 : 0), 3, 3, C); K.bx(c, x - 4, y - 1 + (f ? 1 : 0), 7, 2, C); K.px(c, x + 3, y + (f ? 1 : 0), A);
    if (f) for (i = 1; i <= f; i++) { r = 3 + i * 3; K.px(c, x - r, y + 2, Hi); K.px(c, x + r, y + 2, Hi); K.px(c, x - r + 1, y + 1, Hi); K.px(c, x + r - 1, y + 1, Hi); K.px(c, x - r - 1, y + 3, K.WHITE); K.px(c, x + r + 1, y + 3, K.WHITE); }
  });
  PFA.glyph('m13-breath', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a hare's twitching nose breathing out a frost cloud that blooms (fr 0..3) with an ice crystal in it */
    var fl = face(tx, nx, ny), f = fr & 3, r = 1 + f, X = x + fl * (3 + f);
    K.bx(c, x - fl * 2 - (fl < 0 ? 2 : 0), y - 1, 3, 3, C); K.px(c, x + fl, y, C); K.px(c, x + fl * 2, y, XC[2]); K.px(c, x - fl, y - 1, XC[1]);
    K.px(c, x - fl * 2, y - 3, C); K.px(c, x - fl * 3, y - 4, A);
    K.ringpx(c, X, y - 1, r, Hi); if (f > 1) K.plus(c, X, y - 1, 1, 1, K.WHITE);
  });
  PFA.glyph('m13-form', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a mountain hare pressed into its form (a scraped hollow), ears laid back; grass tufts each side; the eye blinks (fr 0) */
    var fl = face(tx, nx, ny);
    K.bx(c, x - 5, y + 2, 11, 1, XC[10]); K.px(c, x - 5, y + 1, XC[3]); K.px(c, x - 6, y, XC[3]); K.px(c, x - 4, y, XC[3]); K.px(c, x + 5, y + 1, XC[3]); K.px(c, x + 6, y, XC[3]); K.px(c, x + 4, y - 1, XC[3]);
    K.bx(c, x - 3, y - 1, 6, 3, C); K.bx(c, x + fl * 2 - (fl < 0 ? 2 : 0), y - 2, 3, 2, C); K.px(c, x + fl * 4, y - 1, A);
    K.px(c, x + fl * 3, y - 2, fr ? XC[1] : A); K.px(c, x + fl * 1, y - 2, C); K.px(c, x, y - 2, C); K.px(c, x - fl * 1, y - 2, C); K.px(c, x - fl * 2, y - 2, Hi);
    K.px(c, x - fl * 3, y + 1, Hi); K.px(c, x - fl * 4, y + 1, Hi);
  });
  PFA.glyph('m13-lopehare', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a grey-brown mountain hare with big pale feet, loping (fr 0 sit, 1 stretch, 2 crouch) */
    hare(c, K, x, y, face(tx, nx, ny), fr % 3, C, A, Hi, A, Hi, 0);
  });
  PFA.glyph('m13-clover', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a three-leaf clover on its stem; a hare's mouth nibbles one leaf away (fr 0..2), the bitten bits float up */
    var f = fr % 3;
    K.px(c, x, y + 1, XC[3]); K.px(c, x, y + 2, XC[3]); K.px(c, x, y + 3, XC[3]);
    if (f < 2) K.sq(c, x - 2, y - 1, 2, XC[4]); K.sq(c, x + 2, y - 1, 2, XC[4]); K.sq(c, x, y - 3, 2, XC[4]); K.px(c, x, y, XC[4]); K.px(c, x + 2, y - 2, '#8ad070');
    if (f === 1 || f === 2) { K.px(c, x - 5, y - 1, C); K.px(c, x - 4, y - 2, C); K.px(c, x - 4, y, C); K.px(c, x - 3, y - 1, XC[2]); }
    if (f === 2) { K.px(c, x - 3, y - 5, XC[4]); K.px(c, x - 1, y - 7, Hi); }
  });
  PFA.glyph('m13-hareloaf', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a hare napping as a round loaf in a hollow: ears folded flat along the back, eye a shut line, breathing (fr) */
    var b = fr & 1, i;
    K.bx(c, x - 4, y + 2, 9, 1, XC[10]); K.bx(c, x - 3, y - 1 - b, 7, 3 + b, C); K.bx(c, x - 2, y - 2 - b, 5, 1, C);
    for (i = -2; i <= 2; i++) K.px(c, x + i, y - 3 - b, i > 1 ? A : Hi);
    K.px(c, x + 2, y - 1 - b, A); K.px(c, x + 3, y - 1 - b, A); K.px(c, x + 4, y, XC[2]); K.px(c, x - 4, y, Hi);
    if (fr > 1) { K.px(c, x + 4, y - 6, XC[15]); K.px(c, x + 5, y - 6, XC[15]); K.px(c, x + 5, y - 7, XC[15]); K.px(c, x + 4, y - 8, XC[15]); K.px(c, x + 5, y - 8, XC[15]); }
  });
  /* jackrabbit */
  PFA.glyph('m13-sailears', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* the jackrabbit's huge sail ears, sunlit pink with red veins; one ear flicks over (fr 1), a lean face below */
    var i, f = fr & 1, X;
    K.bx(c, x - 2, y + 1, 5, 3, C); K.px(c, x - 1, y + 2, XC[1]); K.px(c, x + 1, y + 2, XC[1]); K.px(c, x, y + 3, A);
    for (i = 0; i < 8 + z; i++) { K.px(c, x - 2, y - i, C); K.px(c, x - 1, y - i, i > 1 && i < 7 ? Hi : C); if (i === 3 || i === 5) K.px(c, x - 1, y - i, XC[19]); }
    K.px(c, x - 2, y - 8 - z, A);
    for (i = 0; i < 8 + z; i++) { X = x + 1 + (f ? Math.round(i * i / 10) : 0); K.px(c, X, y - i + (f ? (i >> 2) : 0), Hi); K.px(c, X + 1, y - i + (f ? (i >> 2) : 0), C); if (i === 4) K.px(c, X, y - i + (f ? 1 : 0), XC[19]); }
    if (f) { K.px(c, x + 7, y - 5, Hi); K.px(c, x + 8, y - 4, Hi); }
  });
  PFA.glyph('m13-scrub', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a grey-green desert scrub bush, thorny twigs; two tall ear tips poke up behind it and twitch (fr 0..3) */
    var i, e = fr & 3;
    for (i = -4; i <= 4; i++) { K.px(c, x + i, y + 1 - (4 - Math.abs(i)) * .6, XC[17]); K.px(c, x + i, y + 2, XC[17]); if (!(i & 1)) K.px(c, x + i, y - 1 - (4 - Math.abs(i)) * .7, A); }
    K.px(c, x - 3, y - 2, '#c8d8b0'); K.px(c, x + 2, y - 3, '#c8d8b0'); K.px(c, x, y + 3, A); K.px(c, x - 2, y + 3, A);
    K.px(c, x - 1, y - 4 - (e === 1 ? 1 : 0), C); K.px(c, x - 1, y - 5 - (e === 1 ? 1 : 0), C); K.px(c, x - 1, y - 6 - (e === 1 ? 1 : 0), Hi);
    K.px(c, x + 1, y - 4 - (e === 3 ? 1 : 0), C); K.px(c, x + 1 + (e === 2 ? 1 : 0), y - 5, C); K.px(c, x + 1 + (e === 2 ? 1 : 0), y - 6, Hi);
  });
  PFA.glyph('m13-jacksprint', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a lean jackrabbit at full stretch, long legs out, ears laid back, a dust puff off the hind feet (fr 1) */
    var fl = face(tx, nx, ny);
    hare(c, K, x, y, fl, 3, C, A, Hi, A, C, 1);
    if (fr & 1) { K.px(c, x - fl * 9, y, XC[9]); K.px(c, x - fl * 10, y - 1, XC[9]); K.px(c, x - fl * 9, y + 2, XC[9]); }
  });
  /* grumpy lemming */
  PFA.glyph('m13-grump', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a round black-capped lemming scowling with puffed cheeks, buck teeth bared (fr 1), an anger mark popping (fr 2..3) */
    var f = fr & 3; lemming(c, K, x, y, C, A, Hi, f === 1 || f === 3, f > 1);
  });
  PFA.glyph('m13-cloud', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a small dark storm cloud muttering: a rumble zigzag under it (fr 1) and two rain dots falling (fr 0..2) */
    var f = fr % 3;
    K.bx(c, x - 3, y - 1, 7, 2, XC[14]); K.bx(c, x - 2, y - 2, 3, 1, XC[14]); K.bx(c, x + 1, y - 3, 2, 2, XC[14]); K.px(c, x - 1, y - 2, '#8a8ea0'); K.px(c, x + 1, y - 3, '#8a8ea0');
    if (f === 1) { K.px(c, x - 1, y + 2, Hi); K.px(c, x, y + 3, Hi); K.px(c, x + 1, y + 2, Hi); K.px(c, x + 2, y + 3, Hi); }
    else { K.px(c, x - 2, y + 2 + f * 2, K.DEW); K.px(c, x + 2, y + 3 + f, K.DEW); }
    K.px(c, x + 4, y - 4, C); K.px(c, x + 5, y - 3, C);
  });
  PFA.glyph('m13-snowdig', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a lemming bum-up, head buried in snow, stubby tail; snow chunks flung back (fr 0..3) */
    var f = fr & 3, i;
    K.bx(c, x - 4, y + 1, 9, 2, K.WHITE); K.bx(c, x - 3, y, 7, 1, K.WHITE);
    K.bx(c, x - 2, y - 3, 5, 3, C); K.px(c, x - 1, y - 4, C); K.px(c, x, y - 4, C); K.px(c, x + 1, y - 4, C); K.px(c, x, y - 5, A);
    K.px(c, x - 2, y, A); K.px(c, x + 2, y, A);
    for (i = 0; i < 2; i++) K.bx(c, x - 4 + i * 8 + (i ? f : -f), y - 3 - f - i, 2, 2, K.WHITE);
  });
  PFA.glyph('m13-stare', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* two narrowed slit eyes glaring out of a fur ball, glare dashes reaching out along the normal (fr 0..2) */
    var i, f = fr % 3;
    K.bx(c, x - 3, y - 2, 7, 5, C); K.bx(c, x - 2, y - 3, 5, 1, A); K.bx(c, x - 3, y - 2, 7, 1, A);
    K.bx(c, x - 2, y, 2, 1, XC[1]); K.bx(c, x + 1, y, 2, 1, XC[1]); K.px(c, x - 2, y - 1, XC[1]); K.px(c, x + 2, y - 1, XC[1]); K.px(c, x - 1, y, Hi); K.px(c, x + 2, y, Hi);
    for (i = 0; i <= f; i++) { K.px(c, x + nx * (5 + i * 3) - tx * 2, y + ny * (5 + i * 3) - ty * 2, XC[12]); K.px(c, x + nx * (5 + i * 3) + tx * 2, y + ny * (5 + i * 3) + ty * 2, XC[12]); }
  });
  /* pika sentry */
  PFA.glyph('m13-pika', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a round tailless pika with round ears, calling "eep" (fr 1, call marks) */
    pika(c, K, x, y, C, A, Hi, fr & 1, 0);
  });
  PFA.glyph('m13-pebble', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a rounded scree stone with a lichen spot, spinning (fr turns the spot), a dotted flight line behind */
    var f = fr & 3, s = 3 + (z > 0 ? 1 : 0);
    K.bx(c, x - (s >> 1), y - (s >> 1), s, s, XC[7]); K.px(c, x - (s >> 1), y - (s >> 1), '#b8b8c0'); K.px(c, x + (f & 1 ? 1 : -1), y + (f & 2 ? 1 : 0), XC[8]);
    K.px(c, x - nx * 4, y - ny * 4, A); K.px(c, x - nx * 6, y - ny * 6, A);
  });
  PFA.glyph('m13-haypile', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a pika haypile: grass stalks and flower heads bunched and bristling outward along the normal, a flower nodding (fr) */
    var i, L, X, Y, f = fr & 1;
    for (i = -2; i <= 2; i++) { L = 5 + (i & 1) + z; X = x + tx * i * 1.5; Y = y + ty * i * 1.5;
      K.ln(c, X, Y, X + nx * L + tx * i * .5, Y + ny * L + ty * i * .5, 1, (i & 1) ? XC[18] : XC[3]); }
    K.px(c, x + nx * 6 + tx * (f ? 1 : 0), y + ny * 6 + ty * (f ? 1 : 0), XC[6]); K.px(c, x + nx * 5 - tx * 3, y + ny * 5 - ty * 3, XC[5]);
    K.bx(c, x - 2, y - 1, 5, 2, XC[18]);
  });
  PFA.glyph('m13-pikarock', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a pika sitting on top of a lichen-spotted boulder, turning its head left, front, right (fr 0..2) */
    var f = fr % 3;
    K.bx(c, x - 5, y + 1, 11, 4, XC[7]); K.bx(c, x - 4, y, 9, 1, XC[7]); K.px(c, x - 3, y + 2, XC[8]); K.px(c, x + 3, y + 3, XC[8]); K.px(c, x - 4, y, '#b8b8c0');
    pika(c, K, x, y - 4, C, A, Hi, 0, f - 1);
  });
  /* marmot bruiser */
  PFA.glyph('m13-marmot', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a fat golden marmot standing tall (0), whistling (1), dropping its whole weight into a squashed sit (2) */
    marmot(c, K, x, y, C, A, Hi, fr % 3);
  });
  PFA.glyph('m13-bellyflop', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a marmot belly-flopped flat, limbs splayed; on impact (fr 1) dust puffs out both sides */
    var f = fr & 1;
    K.bx(c, x - 4, y - 1, 9, 3, C); K.bx(c, x - 3, y - 2, 7, 1, C); K.bx(c, x - 2, y, 5, 1, Hi); K.bx(c, x + 4, y - 2, 2, 2, C); K.px(c, x + 5, y - 2, A); K.px(c, x + 6, y - 1, XC[1]);
    K.px(c, x - 5, y - 2, A); K.px(c, x - 5, y + 2, A); K.px(c, x + 3, y + 2, A); K.px(c, x + 3, y - 3, A); K.px(c, x - 5, y, C);
    if (f) { K.px(c, x - 7, y, XC[9]); K.px(c, x - 8, y - 1, XC[9]); K.px(c, x - 7, y + 2, XC[9]); K.px(c, x + 8, y, XC[9]); K.px(c, x + 9, y - 1, XC[9]); K.px(c, x + 8, y + 2, XC[9]); }
  });
  PFA.glyph('m13-turf', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a slab of turf shoved by two fat paws: grass on top, soil under, a crack opening behind it (fr 0..2) */
    var f = fr % 3, o = f;
    K.bx(c, x - 3 + o, y - 1, 7, 3, XC[10]); K.bx(c, x - 3 + o, y - 2, 7, 1, XC[3]); K.px(c, x - 2 + o, y - 3, XC[3]); K.px(c, x + o, y - 3, XC[3]); K.px(c, x + 2 + o, y - 3, XC[3]);
    K.bx(c, x - 6 + o, y - 1, 2, 2, C); K.bx(c, x - 6 + o, y + 1, 2, 1, C); K.px(c, x - 4 + o, y - 1, A); K.px(c, x - 4 + o, y + 1, A);
    if (f) { K.px(c, x - 7, y + 3, XC[11]); K.px(c, x - 6, y + 2, XC[11]); K.px(c, x - 5, y + 3, XC[11]); if (f > 1) K.px(c, x - 4, y + 2, XC[11]); }
  });
  /* glacier cub */
  PFA.glyph('m13-icecub', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a round blue-white cub face with frost crystals on its crown, blinking (fr 1) */
    icecub(c, K, x, y, C, A, Hi, fr & 1);
  });
  PFA.glyph('m13-bellyslide', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a round cub sliding on its belly, front paws stretched forward, ice streak lines behind (fr shifts the streak) */
    var fl = face(tx, nx, ny), i;
    K.bx(c, x - 3, y - 1, 7, 3, C); K.bx(c, x - 2, y - 2, 5, 1, C); K.px(c, x + fl * 4, y, C); K.px(c, x + fl * 5, y + 1, C);
    K.bx(c, x + fl * 2 - (fl < 0 ? 1 : 0), y - 3, 2, 2, C); K.px(c, x + fl * 3, y - 2, XC[1]); K.px(c, x + fl * 4, y - 1, XC[1]); K.px(c, x + fl * 1, y - 4, A);
    K.px(c, x - fl * 4, y + 1, C); K.px(c, x - fl * 5, y + 1, A);
    for (i = 0; i < 3; i++) K.px(c, x - fl * (6 + i * 2 + (fr & 1)), y + 2 - (i & 1), i ? Hi : K.WHITE);
  });
  PFA.glyph('m13-skid', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a cub skidding on all fours, legs splayed, ice chips spraying (fr 0..3) */
    var fl = face(tx, nx, ny), f = fr & 3;
    K.bx(c, x - 3, y - 2, 7, 3, C); K.bx(c, x + fl * 3 - (fl < 0 ? 2 : 0), y - 3, 3, 3, C); K.px(c, x + fl * 4, y - 2, XC[1]); K.px(c, x + fl * 5, y - 1, XC[1]);
    K.px(c, x - 4, y + 1, C); K.px(c, x - 5, y + 2, A); K.px(c, x + 4, y + 1, C); K.px(c, x + 5, y + 2, A); K.px(c, x - 1, y + 1, C); K.px(c, x + 1, y + 1, C);
    K.px(c, x + fl * (6 + f), y + 1 - f, Hi); K.px(c, x + fl * (5 + f), y - f, K.WHITE); K.px(c, x + fl * (7 + (f >> 1)), y + 2, XC[13]);
  });
  PFA.glyph('m13-fluffball', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* the cub fluffed into a round fur ball, frosty tufts bristling all round (fr turns them), two eyes peeking */
    var i, a, r = 4 + (z > 1 ? 1 : 0);
    K.sq(c, x, y, r * 2 - 1, C); K.px(c, x - 1, y - 1, XC[1]); K.px(c, x + 1, y - 1, XC[1]); K.px(c, x, y + 1, A);
    for (i = 0; i < 6; i++) { a = i * 1.047 + (fr & 3) * .26; K.px(c, x + Math.cos(a) * (r + 1), y + Math.sin(a) * (r + 1), Hi); K.px(c, x + Math.cos(a) * (r + 2), y + Math.sin(a) * (r + 2), K.WHITE); }
  });
  /* reindeer calf herd */
  PFA.glyph('m13-calf', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a reindeer calf face with fuzzy velvet antler buds; head up (0), lowered to butt (1), bleating (2) */
    var f = fr % 3; calf(c, K, x, y, C, A, Hi, f === 1, f === 2);
  });
  PFA.glyph('m13-huddle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* three calves huddled rump to rump, cream rumps and fuzzy backs, a puff of warm breath steaming up (fr 0..2) */
    var f = fr % 3, i;
    for (i = -1; i <= 1; i++) { K.bx(c, x + i * 4 - 2, y - 1 - (i === 0 ? 1 : 0), 4, 3, C); K.px(c, x + i * 4 - 1, y - 2 - (i === 0 ? 1 : 0), A); K.px(c, x + i * 4, y + 1, Hi); }
    K.px(c, x - 6, y - 2, A); K.px(c, x + 6, y - 2, A);
    K.px(c, x - 1, y - 4 - f, XC[16]); K.px(c, x, y - 5 - f, XC[16]); K.px(c, x + 1, y - 4 - f * 2, XC[16]);
  });
  PFA.glyph('m13-bleat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a calf muzzle bleating, soft "mm" arcs and a warm breath puff rising from it (fr 0..2) */
    var f = fr % 3, i;
    calf(c, K, x, y + 2, C, A, Hi, 0, f > 0);
    for (i = 0; i < f; i++) { K.px(c, x - 2 + i * 4, y - 5 - i * 2, Hi); K.px(c, x - 1 + i * 4, y - 6 - i * 2, Hi); K.px(c, x + i * 4, y - 5 - i * 2, Hi); K.px(c, x + 1 + i * 4, y - 6 - i * 2, Hi); K.px(c, x + 2 + i * 4, y - 5 - i * 2, Hi); }
  });

  /* ---------- motions (mutate the scratch G; pp = time x speed) ---------- */
  PFA.motion('m13-romp', function (G, pp, k) { G.fr = (Math.floor(pp * 7) + k) & 3; G.up += G.fr === 2 ? 2 : 0; G.t += G.fr === 3 ? Math.sin(pp * 20) : 0; });
  PFA.motion('m13-peer', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2 + ph) % 1) * 3); });
  PFA.motion('m13-fluff', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 1; G.t += Math.sin(pp * 5 + k) * .8; });
  PFA.motion('m13-tug', function (G, pp, k) { G.fr = (Math.floor(pp * 9) + k) & 1; G.t += G.fr ? 1 : -1; });
  PFA.motion('m13-swivel', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 1.6 + ph) % 1) * 4); });
  PFA.motion('m13-doze', function (G, pp, k) { G.fr = (Math.floor(pp * 3) + k) % 3; G.up += Math.sin(pp * 4 + k) * .6; });
  PFA.motion('m13-fling', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; });
  PFA.motion('m13-ping', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2.4 + ph) % 1) * 3); });
  PFA.motion('m13-bound', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.up += Math.sin(w * Math.PI) * 6; G.fr = w < .15 ? 0 : w < .8 ? 1 : 2; G.s += pp * .12; });
  PFA.motion('m13-kick', function (G, pp, k, ph) { G.fr = ((pp * 2.2 + ph) % 1) < .45 ? 0 : 1; });
  PFA.motion('m13-zigzag', function (G, pp, k) { var w = Math.floor(pp * 8 + k); G.t += (w & 1) ? 4 : -4; G.up += Math.abs(Math.sin(pp * 25)) * 3; G.fr = 1 + (w & 1); G.s += pp * .15; });
  PFA.motion('m13-stamp', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .3 ? 0 : w < .6 ? 1 : 2; });
  PFA.motion('m13-breathe', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 1.8 + ph) % 1) * 4); G.t += Math.sin(pp * 30) * .5; });
  PFA.motion('m13-blink', function (G, pp, k, ph) { G.fr = ((pp * 1.2 + ph) % 1) < .85 ? 1 : 0; });
  PFA.motion('m13-lope', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.up += Math.sin(w * Math.PI) * 4; G.fr = w < .2 ? 2 : w < .75 ? 1 : 0; G.s += pp * .1; });
  PFA.motion('m13-nibble', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) % 3; });
  PFA.motion('m13-flick', function (G, pp, k, ph) { G.fr = ((pp * 3 + ph) % 1) < .3 ? 1 : 0; });
  PFA.motion('m13-peek', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2 + ph) % 1) * 4); });
  PFA.motion('m13-sprint', function (G, pp, k) { G.s += pp * .5; G.fr = (Math.floor(pp * 16) + k) & 1; G.up += G.fr; });
  PFA.motion('m13-grumble', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; G.t += (G.fr === 2) ? Math.sin(pp * 40) : 0; });
  PFA.motion('m13-mutter', function (G, pp, k) { G.fr = (Math.floor(pp * 7) + k) % 3; G.t += Math.sin(pp * 3 + k) * 1.5; });
  PFA.motion('m13-glare', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 1.4 + ph) % 1) * 3); });
  PFA.motion('m13-call', function (G, pp, k, ph) { G.fr = ((pp * 3 + ph) % 1) < .4 ? 1 : 0; G.up += G.fr; });
  PFA.motion('m13-spin', function (G, pp, k) { G.fr = (Math.floor(pp * 12) + k) & 3; });
  PFA.motion('m13-look', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 1.2 + ph) % 1) * 3); });
  PFA.motion('m13-heft', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; G.fr = w < .55 ? 0 : 2; G.up += G.fr ? 0 : 1; });
  PFA.motion('m13-whistle', function (G, pp, k, ph) { G.fr = ((pp * 2.5 + ph) % 1) < .5 ? 1 : 0; });
  PFA.motion('m13-flop', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w > .55 && w < .8 ? 1 : 0; G.up += w < .55 ? Math.sin(w / .55 * Math.PI) * 3 : 0; });
  PFA.motion('m13-shove', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 1.8 + ph) % 1) * 3); G.d += G.fr; });
  PFA.motion('m13-slide', function (G, pp, k) { G.s += pp * .3; G.fr = (Math.floor(pp * 10) + k) & 1; });
  PFA.motion('m13-skid', function (G, pp, k) { G.s += pp * .15; G.fr = (Math.floor(pp * 10) + k) & 3; G.t += Math.sin(pp * 18 + k) * .8; });
  PFA.motion('m13-puff', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; G.up += Math.sin(pp * 5 + k) * .8; });
  PFA.motion('m13-butt', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .5 ? 0 : 1; G.d += G.fr ? 2 : 0; });
  PFA.motion('m13-steam', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) % 3; G.t += Math.sin(pp * 3 + k) * .6; });
  PFA.motion('m13-bleat', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2 + ph) % 1) * 3); });

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ---------- */
  function hd(c, e, H, g, u, off, up, fr, z) {   /* glyph at distance u of the hop, off px out from the edge, raised by up, facing the travel direction */
    var Q = H.Q, s = sgnOf(e.d); e.P.atq(e.a + e.d * u);
    H.glyph(c, g, Q.x + Q.nx * off, Q.y + Q.ny * off - up, z, fr, e.col, e.acc, e.hi, -Q.ny * s, Q.nx * s, Q.nx, Q.ny);
  }
  function carKits(c, e, H) {            /* two fox kits chase along the edge, leapfrogging: the back kit arcs over the front one in turn, tiny paw dots behind */
    var Q = H.Q, k, u, w, a, b;
    for (k = 1; k <= 4; k++) { u = e.hh * k / 5; e.P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.acc); }
    w = (e.p * 3) % 1; a = Math.max(0, e.hh - .06); b = e.hh;
    if (Math.floor(e.p * 3) & 1) { u = a; a = b; b = u; }
    hd(c, e, H, 'm13-earnip', a, 5, 0, 0, 0);
    hd(c, e, H, 'm13-earnip', b, 5, Math.sin(w * Math.PI) * 7, 1, 0);
  }
  function carFennec(c, e, H) {          /* a fennec trots over the dunes, its big ears bobbing and swivelling; a sand ripple behind and a moon glint above it */
    var Q = H.Q, u, k = 0;
    for (u = Math.max(0, e.hh - .4); u < e.hh; u += .03) { e.P.atq(e.a + e.d * u); if ((k++ & 1) === 0) H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3 + (k & 2 ? 1 : 0), XC[9]); }
    hd(c, e, H, 'm13-fennec', e.hh, 6, Math.abs(Math.sin(e.p * 18)) * 2, Math.floor(e.p * 6) & 3, e.z);
    e.P.atq(e.a + e.d * e.hh); H.px(c, Q.x + Q.nx * 14 + 4, Q.y + Q.ny * 14 - 8, XC[15]); H.px(c, Q.x + Q.nx * 14 + 5, Q.y + Q.ny * 14 - 7, XC[15]); H.px(c, Q.x + Q.nx * 14 + 5, Q.y + Q.ny * 14 - 9, XC[15]);
  }
  function hareTrack(c, e, H, u, big, col) {   /* a hare track: two long hind prints ahead, two small fore prints behind (the Y shape) */
    var Q = H.Q, s = sgnOf(e.d), tx, ty, X, Y; e.P.atq(e.a + e.d * u); tx = -Q.ny * s; ty = Q.nx * s; X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3;
    H.px(c, X + tx * 2 + Q.nx * 2, Y + ty * 2 + Q.ny * 2, col); H.px(c, X + tx * 3 + Q.nx * 2, Y + ty * 3 + Q.ny * 2, col); if (big) H.px(c, X + tx * 4 + Q.nx * 2, Y + ty * 4 + Q.ny * 2, col);
    H.px(c, X + tx * 2 - Q.nx, Y + ty * 2 - Q.ny, col); H.px(c, X + tx * 3 - Q.nx, Y + ty * 3 - Q.ny, col); if (big) H.px(c, X + tx * 4 - Q.nx, Y + ty * 4 - Q.ny, col);
    H.px(c, X - tx, Y - ty + 1, col); H.px(c, X - tx * 2, Y - ty * 2, col);
  }
  function carFrostHare(c, e, H) {       /* the frost hare bounds in three big arcs; at every landing a Y-shaped hare track and a little frost sparkle */
    var n = Math.floor(e.hh * 3), w = (e.hh * 3) % 1, k;
    for (k = 1; k <= n && k < 3; k++) { hareTrack(c, e, H, k / 3, 1, e.acc); if (k === n && w < .4) { e.P.atq(e.a + e.d * k / 3); H.plus(c, H.Q.x + H.Q.nx * 8, H.Q.y + H.Q.ny * 8, 1, 1, e.hi); } }
    hd(c, e, H, 'm13-frosthare', e.hh, 6, e.hh < .98 ? Math.sin(w * Math.PI) * 9 : 0, e.hh > .97 ? 0 : w < .15 || w > .85 ? 2 : 1, e.z);
  }
  function carLope(c, e, H) {            /* the mountain hare lopes in five low strides, leaving pale big-foot prints and nipped grass tufts behind */
    var Q = H.Q, n = Math.floor(e.hh * 5), w = (e.hh * 5) % 1, k;
    for (k = 1; k <= n && k < 5; k++) { hareTrack(c, e, H, k / 5, 0, e.hi); if (k & 1) { e.P.atq(e.a + e.d * k / 5); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2 - 1, XC[3]); H.px(c, Q.x + Q.nx * 2 + 1, Q.y + Q.ny * 2 - 2, XC[3]); } }
    hd(c, e, H, 'm13-lopehare', e.hh, 6, Math.sin(w * Math.PI) * 4, e.hh > .97 ? 0 : w < .2 ? 2 : 1, e.z);
  }
  function carSprint(c, e, H) {          /* the jackrabbit sprints low and straight, a long dust streak behind; at the end it sits up and its sail ears flick */
    var Q = H.Q, u, k = 0;
    for (u = Math.max(0, e.hh - .5); u < e.hh - .04; u += .025) { e.P.atq(e.a + e.d * u); k++; if ((k + Math.floor(e.p * 30)) % 3) H.px(c, Q.x + Q.nx * (4 + (k & 1)), Q.y + Q.ny * (4 + (k & 1)), (k % 4) ? XC[9] : e.acc); }
    if (e.hh > .95) hd(c, e, H, 'm13-sailears', e.hh, 9, 0, Math.floor(e.p * 10) & 1, 0);
    else hd(c, e, H, 'm13-jacksprint', e.hh, 5, Math.floor(e.p * 20) & 1, Math.floor(e.p * 20) & 1, e.z);
  }
  function carGrump(c, e, H) {           /* the grumpy lemming stomps along under its own little rain cloud, rain dots falling on it, stomp marks left behind */
    var Q = H.Q, k, u, X, Y;
    for (k = 1; k <= 5; k++) { u = e.hh * k / 6; e.P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 3 - 1, Q.y + Q.ny * 3, e.acc); H.px(c, Q.x + Q.nx * 3 + 1, Q.y + Q.ny * 3, e.acc); }
    e.P.atq(e.a + e.d * e.hh); X = Q.x + Q.nx * 6; Y = Q.y + Q.ny * 6;
    H.glyph(c, 'm13-grump', X, Y - (Math.floor(e.p * 12) & 1), e.z, (Math.floor(e.p * 8) & 3), e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
    H.glyph(c, 'm13-cloud', X, Y - 11, 0, Math.floor(e.p * 9) % 3, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  function carHay(c, e, H) {             /* the pika scampers along the scree with a bunch of hay and a flower in its mouth, dropping a stalk now and then */
    var Q = H.Q, k, X, Y;
    for (k = 1; k <= 4; k++) { if (e.hh < k / 5) break; e.P.atq(e.a + e.d * k / 5); X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3; H.px(c, X, Y, k & 1 ? XC[18] : XC[3]); H.px(c, X + 1, Y - 1, k & 1 ? XC[18] : XC[3]); }
    e.P.atq(e.a + e.d * e.hh); X = Q.x + Q.nx * 6; Y = Q.y + Q.ny * 6 - (Math.floor(e.p * 16) & 1);
    H.glyph(c, 'm13-pika', X, Y, e.z, e.hh > .95 ? 1 : 0, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
    H.ln(c, X - 2, Y + 2, X + 4, Y + 1, 1, XC[18]); H.px(c, X + 4, Y, XC[6]); H.px(c, X + 3, Y + 2, XC[3]);
  }
  function carMarmot(c, e, H) {          /* the fat marmot waddles along like a barrel, side to side; each heavy step leaves a dust thud */
    var Q = H.Q, k, w;
    for (k = 1; k <= 3; k++) { if (e.hh < k / 4) break; e.P.atq(e.a + e.d * k / 4); w = e.hh - k / 4; if (w < .2) { H.px(c, Q.x + Q.nx * 2 - 3 - w * 10, Q.y + Q.ny * 2, XC[9]); H.px(c, Q.x + Q.nx * 2 + 3 + w * 10, Q.y + Q.ny * 2, XC[9]); }
      H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.acc); }
    e.P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'm13-marmot', Q.x + Q.nx * 8 + Math.sin(e.p * 16) * 1.5, Q.y + Q.ny * 8, e.z, e.hh > .95 ? 2 : 0, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  function carSlide(c, e, H) {           /* the glacier cub belly-slides along the ice: a long glossy ice streak behind it, sparkles popping on the streak */
    var Q = H.Q, u, k = 0;
    for (u = Math.max(0, e.hh - .6); u < e.hh; u += .025) { e.P.atq(e.a + e.d * u); k++; H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, k % 6 === 0 ? H.WHITE : e.hi); }
    e.P.atq(e.a + e.d * Math.max(0, e.hh - .25)); if (Math.floor(e.p * 10) & 1) H.plus(c, Q.x + Q.nx * 6, Q.y + Q.ny * 6, 1, 1, H.WHITE);
    hd(c, e, H, 'm13-bellyslide', e.hh, 5, 0, Math.floor(e.p * 10) & 1, e.z);
  }
  function carCalves(c, e, H) {          /* three reindeer calves trot nose to tail; cloven hoof prints behind, and a click mark at each step (reindeer knees click) */
    var Q = H.Q, k, u, X, Y;
    for (k = 1; k <= 5; k++) { u = e.hh * k / 6; e.P.atq(e.a + e.d * u); X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3; H.px(c, X - 1, Y, e.acc); H.px(c, X + 1, Y, e.acc); }
    for (k = 2; k >= 0; k--) { u = e.hh - k * .1; if (u < 0) continue; e.P.atq(e.a + e.d * u);
      X = Q.x + Q.nx * 6; Y = Q.y + Q.ny * 6 - ((Math.floor(e.p * 12) + k) & 1);
      H.glyph(c, 'm13-calf', X, Y, 0, 0, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
      if (((Math.floor(e.p * 12) + k) & 3) === 0) { H.px(c, X - 5, Y + 4, H.WHITE); H.px(c, X - 6, Y + 3, H.WHITE); H.px(c, X + 5, Y + 4, H.WHITE); H.px(c, X + 6, Y + 3, H.WHITE); } }
  }

  /* ---------- motifs ---------- */
  function M(name, draw, meta) { PFA.motif(name, draw, meta); }
  /* fox kit pair */
  M('kit-pair-romp', snow, { nm: 'fox kits', desc: 'two russet fox kits with tall dark-tipped ears play-fighting: side by side, one crouches, pounces on the other, both tumble; snow sifts on the run; the chain is the two kits leapfrogging along the edge', fam: 'bash', gap: 18, g: 'm13-kits', mo: 'm13-romp', x: '-', car: 'custom', carDraw: carKits });
  M('kit-den', plain, { nm: 'kit dens', desc: 'den mouths in an earth bank, two pairs of ear tips and blinking eyes peering out of the dark', fam: 'shield', gap: 16, g: 'm13-kitden', mo: 'm13-peer', x: '-', car: 'tunnel' });
  M('kit-brush-tail', plain, { nm: 'brush tails', desc: 'bushy white-tipped fox-kit tails curled over the edge, the fur fluffing out', fam: 'puff', gap: 14, g: 'm13-brushtail', mo: 'm13-fluff', x: '-', car: 'flutter' });
  M('kit-ear-nip', plain, { nm: 'ear nips', desc: 'a kit nipping its sibling\'s ear tip and tugging, a tiny yelp mark', fam: 'bite', gap: 14, g: 'm13-earnip', mo: 'm13-tug', x: '-', car: 'hop' });
  /* fennec */
  M('fennec-ears', sand, { nm: 'fennec ears', desc: 'a tiny cream fennec face under two huge pink-lined ears that swivel to listen; a sand ripple drifts along the run; the chain trots over the dunes with the ears bobbing under a moon glint', fam: 'thrust', gap: 16, g: 'm13-fennec', mo: 'm13-swivel', x: '-', car: 'custom', carDraw: carFennec });
  M('fennec-curl', plain, { nm: 'fennec naps', desc: 'a fennec curled asleep, ears folded flat, the black-tipped tail over its nose, Zs rising', fam: 'mend', gap: 14, g: 'm13-fenneccurl', mo: 'm13-doze', x: '-', car: 'flutter' });
  M('fennec-sand-curtain', plain, { nm: 'sand curtains', desc: 'curtains of sand fanned up by two digging forepaws, the grains hanging in arcs', fam: 'puff', gap: 12, g: 'm13-sandfan', mo: 'm13-fling', x: 'dust', car: 'cloud' });
  M('fennec-ear-ping', plain, { nm: 'ear pings', desc: 'fennec ears snapping up at a sound, listening arcs spreading from both ear tips', fam: 'shock', gap: 16, g: 'm13-earping', mo: 'm13-ping', x: '-', car: 'blink' });
  /* hares */
  M('frost-hare-bound', snow, { nm: 'frost hares', desc: 'white hares with black ear tips bounding: sit, stretch, land in a frost spray; snow sifts on the run; the chain bounds in three arcs leaving Y-shaped hare tracks with a frost sparkle', fam: 'thrust', gap: 18, g: 'm13-frosthare', mo: 'm13-bound', x: '-', car: 'custom', carDraw: carFrostHare });
  M('hare-hind-kick', plain, { nm: 'hind kicks', desc: 'a hare\'s big hind foot kicking straight out of the edge, a snow puff where it strikes', fam: 'thrust', gap: 14, g: 'm13-hindkick', mo: 'm13-kick', x: '-', car: 'comet' });
  M('hare-zigzag', plain, { nm: 'zigzag hares', desc: 'a white hare jinking left and right in sharp zigzags, snow kicked up', fam: 'shock', gap: 16, g: 'm13-frosthare', mo: 'm13-zigzag', x: 'snow', car: 'zig' });
  M('hare-thump', snow, { nm: 'thumps', desc: 'a hind foot stamping flat on the snow, shock rings spreading on both sides', fam: 'ripple', gap: 16, g: 'm13-thump', mo: 'm13-stamp', x: '-', car: 'rings' });
  M('hare-frost-breath', plain, { nm: 'frost breath', desc: 'a twitching hare nose breathing out a ring of frost that blooms, an ice crystal in it', fam: 'puff', gap: 14, g: 'm13-breath', mo: 'm13-breathe', x: '-', car: 'cloud' });
  M('hare-form', plain, { nm: 'hare forms', desc: 'a grey-brown mountain hare pressed into its form (a scraped hollow), ears laid back, grass tufts each side, the eye blinking; the chain lopes uphill leaving pale big-foot prints and nipped grass', fam: 'shield', gap: 16, g: 'm13-form', mo: 'm13-blink', x: '-', car: 'custom', carDraw: carLope });
  M('hare-clover', plain, { nm: 'clover', desc: 'three-leaf clovers on their stems, a hare mouth nibbling a leaf away, bits floating up', fam: 'leaf', gap: 12, g: 'm13-clover', mo: 'm13-nibble', x: '-', car: 'hop' });
  M('hare-hollow-nap', plain, { nm: 'hollow naps', desc: 'a hare napping as a round loaf in a hollow, ears folded flat along its back, breathing, a Z rising', fam: 'mend', gap: 16, g: 'm13-hareloaf', mo: 'm13-doze', x: '-', car: 'flutter' });
  M('hare-lope', plain, { nm: 'loping hares', desc: 'grey-brown mountain hares with big pale feet, loping in low strides', fam: 'slash', gap: 18, g: 'm13-lopehare', mo: 'm13-lope', x: '-', car: 'hop' });
  /* jackrabbit */
  M('sail-ears', sand, { nm: 'sail ears', desc: 'huge sunlit jackrabbit ears, pink with red veins, one flicking over above a lean face; the chain sprints low and straight with a dust streak and the ears flick up at the end', fam: 'slash', gap: 14, g: 'm13-sailears', mo: 'm13-flick', x: '-', car: 'custom', carDraw: carSprint });
  M('jackrabbit-scrub', plain, { nm: 'scrub hides', desc: 'grey-green thorny desert scrub with two tall ear tips poking up behind it, twitching', fam: 'thorn', gap: 14, g: 'm13-scrub', mo: 'm13-peek', x: '-', car: 'train' });
  M('jack-sprint', plain, { nm: 'jack sprints', desc: 'a lean long-legged jackrabbit at full stretch, ears laid back, dust off its hind feet', fam: 'thrust', gap: 18, g: 'm13-jacksprint', mo: 'm13-sprint', x: 'dust', car: 'comet' });
  /* grumpy lemming */
  M('grump-face', snow, { nm: 'grumpy lemmings', desc: 'round black-capped orange lemmings scowling with puffed cheeks, teeth bared, an anger mark popping; the chain stomps along under its own little rain cloud', fam: 'bite', gap: 14, g: 'm13-grump', mo: 'm13-grumble', x: '-', car: 'custom', carDraw: carGrump });
  M('grumble-cloud', plain, { nm: 'grumble clouds', desc: 'small dark storm clouds muttering, a rumble zigzag under them, rain dots falling', fam: 'shock', gap: 14, g: 'm13-cloud', mo: 'm13-mutter', x: '-', car: 'cloud' });
  M('lemming-snow-dig', plain, { nm: 'snow digs', desc: 'a lemming bum-up with its head buried in snow, snow chunks flung back', fam: 'puff', gap: 14, g: 'm13-snowdig', mo: 'm13-fling', x: 'snow', car: 'tunnel' });
  M('sulk-stare', plain, { nm: 'sulk stares', desc: 'two narrowed slit eyes glaring out of a black-capped fur ball, red glare dashes reaching out', fam: 'shock', gap: 14, g: 'm13-stare', mo: 'm13-glare', x: '-', car: 'blink' });
  /* pika sentry */
  M('pika-call', scree, { nm: 'pikas', desc: 'round tailless grey-brown pikas with round ears calling "eep", call marks flying; scree pebbles along the run; the chain scampers with a mouthful of hay and a flower, dropping stalks', fam: 'shock', gap: 14, g: 'm13-pika', mo: 'm13-call', x: '-', car: 'custom', carDraw: carHay });
  M('pebble-pitch', plain, { nm: 'pitched pebbles', desc: 'rounded scree stones with a lichen spot, spinning, a dotted flight line behind', fam: 'bash', gap: 10, g: 'm13-pebble', mo: 'm13-spin', x: 'dust', car: 'hop' });
  M('pika-haypile', plain, { nm: 'haypiles', desc: 'bunches of grass stalks and flower heads (the pika\'s winter hay) bristling out of the edge, a flower nodding', fam: 'leaf', gap: 12, g: 'm13-haypile', mo: 'm13-fluff', x: '-', car: 'train' });
  M('pika-rock', scree, { nm: 'sentry rocks', desc: 'a pika sitting on a lichen-spotted boulder, turning its head left, front, right', fam: 'shield', gap: 18, g: 'm13-pikarock', mo: 'm13-look', x: '-', car: 'train' });
  /* marmot bruiser */
  M('marmot-stand', plain, { nm: 'marmots', desc: 'a fat golden marmot standing tall with a dark face mask and pale belly, then dropping its whole weight into a squashed sit; the chain waddles like a barrel with a dust thud at each step', fam: 'bash', gap: 16, g: 'm13-marmot', mo: 'm13-heft', x: '-', car: 'custom', carDraw: carMarmot });
  M('marmot-whistle', plain, { nm: 'marmot whistles', desc: 'a standing marmot with its mouth open in a sharp whistle, white whistle marks flying', fam: 'shock', gap: 16, g: 'm13-marmot', mo: 'm13-whistle', x: '-', car: 'blink' });
  M('marmot-belly-flop', plain, { nm: 'belly flops', desc: 'a marmot belly-flopped flat with its limbs splayed, dust puffing out both sides on impact', fam: 'bash', gap: 18, g: 'm13-bellyflop', mo: 'm13-flop', x: 'dust', car: 'roll' });
  M('marmot-turf-shove', plain, { nm: 'turf shoves', desc: 'slabs of turf shoved along by two fat paws, a crack opening in the ground behind', fam: 'bash', gap: 16, g: 'm13-turf', mo: 'm13-shove', x: 'clods', car: 'train' });
  /* glacier cub */
  M('glacier-cub-face', snow, { nm: 'glacier cubs', desc: 'round blue-white cub faces with tiny round ears and frost crystals on the crown, blinking; snow sifts on the run; the chain belly-slides along a glossy ice streak with sparkles', fam: 'thrust', gap: 14, g: 'm13-icecub', mo: 'm13-blink', x: '-', car: 'custom', carDraw: carSlide });
  M('cub-belly-slide', plain, { nm: 'belly slides', desc: 'a round cub sliding on its belly, paws stretched forward, white ice streak lines behind', fam: 'slash', gap: 16, g: 'm13-bellyslide', mo: 'm13-slide', x: '-', car: 'trail' });
  M('cub-ice-skid', plain, { nm: 'ice skids', desc: 'a cub skidding on all fours with its legs splayed, ice chips spraying ahead', fam: 'sparkle', gap: 16, g: 'm13-skid', mo: 'm13-skid', x: '-', car: 'zig' });
  M('cub-frost-fluff', plain, { nm: 'frost fluff', desc: 'the cub fluffed into a round fur ball, frosty tufts bristling all round, two eyes peeking', fam: 'puff', gap: 16, g: 'm13-fluffball', mo: 'm13-puff', x: '-', car: 'roll' });
  /* reindeer calf herd */
  M('velvet-bud', plain, { nm: 'reindeer calves', desc: 'fuzzy brown reindeer calf faces with two velvet antler buds and a cream muzzle, lowering to butt; the chain is three calves trotting nose to tail with cloven prints and knee-click marks', fam: 'bash', gap: 14, g: 'm13-calf', mo: 'm13-butt', x: '-', car: 'custom', carDraw: carCalves });
  M('calf-huddle', snow, { nm: 'calf huddles', desc: 'three calves huddled rump to rump in the snow, cream rumps, warm breath steaming up', fam: 'shield', gap: 18, g: 'm13-huddle', mo: 'm13-steam', x: '-', car: 'train' });
  M('calf-bleat', plain, { nm: 'calf bleats', desc: 'a calf muzzle bleating, soft arcs and warm breath rising from it', fam: 'mend', gap: 16, g: 'm13-bleat', mo: 'm13-bleat', x: '-', car: 'flutter' });
})();
