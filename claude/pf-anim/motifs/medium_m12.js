/* Motif module, medium batch m12 (fisher, wolverine-cub, pangolin, tamandua, roebuck, goat-kid-gang, yak-calf-herd, snow-leopard-cub, arctic-fox-kit,
   whiteout-fox). TEMPLATE.md section 10.3.
   40 motifs, each with its own pixel glyph (ids prefixed m12-) and its own motion. Every creature of the batch has its own signature motif, and each
   signature brings its own chain effect (carDraw): a fisher bounding in arcs, a wolverine cub charging through snow, a pangolin rolling as a scale ball
   and uncurling, a tamandua clambering with its tail curling, a roebuck bounding with its white rump flashing, a goat kid boinging ledge to ledge, a
   file of shaggy yak calves puffing breath, a snow leopard cub streaming its huge ringed tail, two fox kits tumbling out of the den, and a blizzard band
   in which only two eyes and a nose travel. The two foxes are relatives: they keep separate signatures but share the mouse-dive pounce (own palettes).
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation in the frame loops (scratch H.Q / H.G only).
   Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy
   default are untouched. */
(function () {
  /* fixed accent colours (not palette tones): 4 white, 5 dew, 6 snow shadow, 7 eye black, 8 pink, 9 soil, 10 bark, 11 leaf green, 12 quill cream,
     13 quill tip, 14 rock grey, 15 rock light, 16 ant red, 17 termite mound, 18 bracken russet, 19 bracken gold-green, 20 mouth red, 21 boot leather,
     22 lace, 23 breath, 24 horn / claw cream, 25 fawn spot, 26 ice blue, 27 porcupine brown, 28 dark mouth */
  var XC = [null, null, null, null, '#ffffff', '#cfeeff', '#cfdcec', '#141418', '#f0a0a8', '#6a4a2c', '#6a4a30', '#5aa050', '#f0e6cc', '#2a2018', '#8a8c94',
    '#b4b6bc', '#c8402a', '#c09060', '#c8642a', '#a0b048', '#e05060', '#7a5030', '#e8d8a8', '#e8eef4', '#ece0c4', '#f8f0e0', '#bcd4ec', '#6a5644', '#3a1a20'];
  var PI = Math.PI;

  function face(tx, nx, ny) { return Math.abs(nx) > Math.abs(ny) ? (nx > 0 ? 1 : -1) : (tx >= 0 ? 1 : -1); }

  /* ---------- body routines (side views face fl; fr = gait / pose step) ---------- */
  /* fisher: long low dark-brown marten, grizzled pale head, arched back when bounding (fr odd), long bushy tail */
  function fisher(c, K, x, y, fl, fr, C, A, Hi) {
    var i, X, u, g = fr & 3, Y;
    for (i = -4; i <= 4; i++) { X = x + fl * i; u = (fr & 1) && i > -3 && i < 3 ? 1 : 0; K.px(c, X, y - 1 - u, C); K.px(c, X, y - u, i > 1 || i < -2 ? C : A); }
    K.px(c, x + fl * 5, y - 1, Hi); K.px(c, x + fl * 5, y, Hi); K.px(c, x + fl * 6, y, Hi); K.px(c, x + fl * 7, y, XC[7]); K.px(c, x + fl * 6, y - 1, XC[7]); K.px(c, x + fl * 5, y - 2, Hi);
    K.px(c, x + fl * (g === 1 ? 5 : g === 2 ? 2 : 3), y + 1, A); K.px(c, x - fl * (g === 1 ? 5 : g === 2 ? 2 : 3), y + 1, A);
    for (i = 1; i <= 5; i++) { X = x - fl * (4 + i); Y = y - 1 + Math.round(Math.sin(i * .8 + fr * 1.57) * .8) - (i > 3 ? 1 : 0); K.px(c, X, Y, C); K.px(c, X, Y + 1, A); if (i > 1 && i < 5) K.px(c, X, Y - 1, A); }
  }
  /* wolverine cub: stout dark body, cream stripe along the flank, pale brow, big paws with claws, short bushy tail; snarl (teeth) on fr 2 */
  function wolverine(c, K, x, y, fl, fr, C, A, Hi) {
    var i, X, g = fr & 1;
    for (i = -3; i <= 3; i++) { X = x + fl * i; if (i > -3 && i < 3) K.px(c, X, y - 2, C); K.px(c, X, y - 1, i < 3 ? Hi : C); K.px(c, X, y, C); K.px(c, X, y + 1, i === 0 ? C : A); }
    K.px(c, x + fl * 4, y - 2, Hi); K.px(c, x + fl * 4, y - 1, C); K.px(c, x + fl * 5, y - 1, C); K.px(c, x + fl * 4, y, C); K.px(c, x + fl * 5, y, C); K.px(c, x + fl * 6, y, XC[7]);
    K.px(c, x + fl * 5, y - 2, XC[7]); K.px(c, x + fl * 3, y - 3, C);
    K.px(c, x + fl * (3 + g), y + 2, A); K.px(c, x + fl * (4 + g), y + 2, K.WHITE); K.px(c, x - fl * (3 - g), y + 2, A); K.px(c, x - fl * (2 - g), y + 2, K.WHITE);
    K.px(c, x - fl * 4, y - 1, C); K.px(c, x - fl * 5, y - 1, A); K.px(c, x - fl * 5, y, A);
    if (fr === 2) { K.px(c, x + fl * 6, y + 1, K.WHITE); K.px(c, x + fl * 5, y + 1, XC[28]); }
  }
  /* pangolin walking on its hind legs: domed body of overlapping scales (checker of main / dark with light tips), small pointed head low, long scaly tail */
  function pangolin(c, K, x, y, fl, fr, C, A, Hi) {
    var i, r, h, X, g = fr & 1;
    for (i = -3; i <= 3; i++) { X = x + fl * i; h = 3 - (Math.abs(i) > 1 ? Math.abs(i) - 1 : 0);
      for (r = 0; r <= h; r++) K.px(c, X, y - r, r === h ? Hi : ((i + r) & 1) ? A : C); }
    K.px(c, x + fl * 4, y, C); K.px(c, x + fl * 5, y + 1, C); K.px(c, x + fl * 6, y + 1, XC[7]); K.px(c, x + fl * 4, y - 1, XC[7]);
    for (i = 1; i <= 5; i++) { X = x - fl * (3 + i); K.px(c, X, y - 1 + (i >> 1), (i & 1) ? C : A); if (i < 4) K.px(c, X, y + (i >> 1), C); }
    K.px(c, x - fl * (1 + g), y + 1, A); K.px(c, x - fl * (1 + g), y + 2, A); K.px(c, x + fl * (2 - g), y + 1, A);
  }
  /* pangolin rolled into a ball: a ring of scales round a spiral, tips flaring out on fl (0/1), turning by rot */
  function pball(c, K, x, y, rot, fl, r, C, A, Hi) {
    var i, a, X, Y;
    K.sq(c, x, y, 2 * r - 1, C);
    for (i = 0; i < 10; i++) { a = i * .628 + rot; X = x + Math.cos(a) * r; Y = y + Math.sin(a) * r; K.px(c, X, Y, (i & 1) ? A : C);
      K.px(c, x + Math.cos(a + .3) * (r + 1 + (fl && (i & 1) ? 1 : 0)), y + Math.sin(a + .3) * (r + 1 + (fl && (i & 1) ? 1 : 0)), (i & 1) ? Hi : A); }
    K.px(c, x + Math.cos(rot) * 1, y + Math.sin(rot) * 1, A); K.px(c, x + Math.cos(rot + 2) * 1.5, y + Math.sin(rot + 2) * 1.5, Hi);
  }
  /* tamandua: pale body with a black vest over the shoulders and belly, long tube snout, prehensile tail curled up behind (curl phase by fr) */
  function tamandua(c, K, x, y, fl, fr, C, A, Hi) {
    var i, X, g = fr & 1;
    for (i = -3; i <= 2; i++) { X = x + fl * i; K.px(c, X, y - 2, i < 0 ? C : A); K.px(c, X, y - 1, i < -1 ? C : A); K.px(c, X, y, i < -2 ? C : (i === 2 ? C : A)); }
    K.px(c, x - fl * 3, y - 2, C);
    K.px(c, x + fl * 3, y - 2, C); K.px(c, x + fl * 3, y - 3, C); K.px(c, x + fl * 4, y - 2, C); K.px(c, x + fl * 5, y - 1, C); K.px(c, x + fl * 6, y - 1, C); K.px(c, x + fl * 7, y, XC[7]);
    K.px(c, x + fl * 4, y - 3, XC[7]);
    K.px(c, x + fl * (2 + g), y + 1, C); K.px(c, x + fl * (3 + g), y + 1, XC[24]); K.px(c, x - fl * (2 - g), y + 1, C);
    K.px(c, x - fl * 4, y - 2, C); K.px(c, x - fl * 5, y - 3, A); K.px(c, x - fl * 5, y - 4, C); K.px(c, x - fl * (4 + (fr & 2 ? 1 : 0)), y - 5, A); K.px(c, x - fl * 3, y - 5 + (fr & 2 ? 1 : 0), C);
  }
  /* roebuck: slim russet deer, white rump patch, short three-point antlers in cream; fr 0 stand, 1 bound (legs tucked), 2 stretch */
  function roe(c, K, x, y, fl, fr, C, A, Hi) {
    var i, X, g = fr % 3;
    for (i = -2; i <= 2; i++) { X = x + fl * i; K.px(c, X, y - 1, C); K.px(c, X, y, i === 0 ? Hi : C); }
    K.px(c, x - fl * 3, y - 1, K.WHITE); K.px(c, x - fl * 3, y, K.WHITE);
    K.px(c, x + fl * 3, y - 2, C); K.px(c, x + fl * 3, y - 3, C); K.px(c, x + fl * 4, y - 4, C); K.px(c, x + fl * 5, y - 4, C); K.px(c, x + fl * 6, y - 3, XC[7]); K.px(c, x + fl * 3, y - 5, C);
    K.px(c, x + fl * 4, y - 5, XC[24]); K.px(c, x + fl * 4, y - 6, XC[24]); K.px(c, x + fl * 4, y - 7, K.WHITE); K.px(c, x + fl * 5, y - 6, XC[24]); K.px(c, x + fl * 3, y - 7, XC[24]);
    if (g === 0) { K.px(c, x + fl * 2, y + 1, C); K.px(c, x + fl * 2, y + 2, A); K.px(c, x - fl * 2, y + 1, C); K.px(c, x - fl * 2, y + 2, A); }
    else if (g === 1) { K.px(c, x + fl * 3, y + 1, C); K.px(c, x + fl * 2, y + 1, A); K.px(c, x - fl * 3, y + 1, C); K.px(c, x - fl * 2, y + 1, A); }
    else { K.px(c, x + fl * 3, y + 1, C); K.px(c, x + fl * 4, y + 2, A); K.px(c, x - fl * 3, y + 1, C); K.px(c, x - fl * 4, y + 2, A); }
  }
  /* goat kid: small white body, horn buds, stiff legs (fr 0 straight, 1 pronk together, 2 splayed), tail flicked up */
  function kid(c, K, x, y, fl, fr, C, A, Hi) {
    var i, X, g = fr % 3;
    for (i = -2; i <= 2; i++) { X = x + fl * i; K.px(c, X, y - 1, C); K.px(c, X, y, C); }
    K.px(c, x - fl * 3, y - 2, C); K.px(c, x + fl * 3, y - 2, C); K.px(c, x + fl * 3, y - 3, C); K.px(c, x + fl * 4, y - 3, C); K.px(c, x + fl * 4, y - 2, Hi);
    K.px(c, x + fl * 3, y - 4, Hi); K.px(c, x + fl * 2, y - 3, A); K.px(c, x + fl * 4, y - 4, XC[7]);
    if (g === 2) { K.px(c, x + fl * 3, y + 1, C); K.px(c, x + fl * 4, y + 2, A); K.px(c, x - fl * 3, y + 1, C); K.px(c, x - fl * 4, y + 2, A); }
    else { X = g === 1 ? 1 : 2; K.px(c, x + fl * X, y + 1, C); K.px(c, x + fl * X, y + 2, A); K.px(c, x - fl * X, y + 1, C); K.px(c, x - fl * X, y + 2, A);
      if (g === 0) { K.px(c, x + fl * (X - 1), y + 1, C); K.px(c, x - fl * (X - 1), y + 1, C); } }
  }
  /* yak calf: boxy shaggy body, a long fur fringe swaying to the ground, small hump, pale face, wide cream horns */
  function yak(c, K, x, y, fl, fr, C, A, Hi) {
    var i, X, s;
    for (i = -3; i <= 3; i++) { X = x + fl * i; K.px(c, X, y - 3, C); K.px(c, X, y - 2, C); K.px(c, X, y - 1, (i & 1) ? A : C); s = ((fr + i) & 1) ? 0 : ((fr & 2) ? 1 : -1);
      K.px(c, X + s * (i & 1), y, C); K.px(c, X + s, y + 1, (i & 1) ? C : A); if (!(i & 1)) K.px(c, X + s, y + 2, C); }
    K.px(c, x - fl * 1, y - 4, C); K.px(c, x, y - 4, C);
    K.px(c, x + fl * 4, y - 2, C); K.px(c, x + fl * 4, y - 1, Hi); K.px(c, x + fl * 5, y - 1, Hi); K.px(c, x + fl * 5, y, A); K.px(c, x + fl * 5, y - 2, XC[7]);
    K.px(c, x + fl * 3, y - 4, XC[24]); K.px(c, x + fl * 2, y - 5, XC[24]); K.px(c, x + fl * 5, y - 4, XC[24]); K.px(c, x + fl * 6, y - 5, XC[24]); K.px(c, x + fl * 6, y - 6, K.WHITE);
  }
  /* snow leopard cub: chubby smoky body with dark rosettes, round head, big paws, pink nose, a huge thick tail curling up with rings; fr 1 = leap stretch */
  function leocub(c, K, x, y, fl, fr, C, A, Hi) {
    var i, X, L = fr & 1;
    for (i = -3; i <= 3; i++) { X = x + fl * i; K.px(c, X, y - 1, (i === -1 || i === 2) ? A : C); K.px(c, X, y, i === 0 ? A : C); }
    K.px(c, x + fl * 4, y - 2, C); K.px(c, x + fl * 5, y - 2, C); K.px(c, x + fl * 4, y - 1, C); K.px(c, x + fl * 5, y - 1, Hi); K.px(c, x + fl * 6, y - 1, XC[8]);
    K.px(c, x + fl * 4, y - 3, C); K.px(c, x + fl * 5, y - 2, XC[7]);
    if (L) { K.px(c, x + fl * 5, y, C); K.px(c, x + fl * 6, y, C); K.px(c, x - fl * 4, y + 1, C); K.px(c, x - fl * 5, y + 1, C); }
    else { K.px(c, x + fl * 3, y + 1, C); K.px(c, x + fl * 4, y + 1, C); K.px(c, x - fl * 2, y + 1, C); K.px(c, x - fl * 3, y + 1, C); }
    K.px(c, x - fl * 4, y - 1, C); K.px(c, x - fl * 5, y - 2, C); K.px(c, x - fl * 6, y - 3, A); K.px(c, x - fl * 6, y - 4, C); K.px(c, x - fl * 5, y - 5, Hi);
    K.px(c, x - fl * 5, y - 1, C); K.px(c, x - fl * 6, y - 2, C);
  }
  /* round-eared fox kit head (front): m = mouth open */
  function kithead(c, K, x, y, C, A, Hi, m) {
    K.bx(c, x - 2, y - 1, 5, 3, C); K.px(c, x - 2, y - 2, C); K.px(c, x + 2, y - 2, C); K.px(c, x - 2, y - 3, A); K.px(c, x + 2, y - 3, A);
    K.px(c, x - 1, y, XC[7]); K.px(c, x + 1, y, XC[7]); K.px(c, x - 2, y + 1, Hi); K.px(c, x + 2, y + 1, Hi); K.px(c, x, y + 1, XC[7]);
    if (m) K.px(c, x, y + 2, XC[20]);
  }
  /* fox in a mouse pounce: fr 0 crouch, 1 arc up, 2/3 nose-down in the snow with hind legs and the bushy tail sticking up, snow spraying */
  function dive(c, K, x, y, fl, fr, C, A, Hi) {
    var i, g = fr & 3;
    if (g === 0) { for (i = -2; i <= 2; i++) K.px(c, x + fl * i, y, C); K.px(c, x - fl * 2, y - 1, C); K.px(c, x + fl * 3, y - 1, C); K.px(c, x + fl * 4, y - 1, C); K.px(c, x + fl * 3, y - 2, A);
      K.px(c, x + fl * 5, y - 1, XC[7]); K.px(c, x - fl * 3, y - 1, C); K.px(c, x - fl * 4, y - 2, Hi); return; }
    if (g === 1) { for (i = -2; i <= 2; i++) K.px(c, x + fl * i, y - i - 1, C); K.px(c, x + fl * 3, y - 4, C); K.px(c, x + fl * 3, y - 5, A); K.px(c, x + fl * 4, y - 4, XC[7]);
      K.px(c, x - fl * 3, y + 2, C); K.px(c, x - fl * 4, y + 2, Hi); return; }
    for (i = -5; i <= 5; i++) K.px(c, x + i, y + 1, Math.abs(i) < 3 ? K.WHITE : XC[6]);
    for (i = 0; i < 4; i++) K.px(c, x, y - i, C); K.px(c, x - 1, y - 4, A); K.px(c, x + 1, y - 4, A);
    K.px(c, x - fl, y - 2, C); K.px(c, x - fl * 2, y - 3, C); K.px(c, x - fl * 3, y - 4, C); K.px(c, x - fl * 3, y - 5, Hi);
    K.px(c, x + 2 + g - 2, y - 1 - (g - 2) * 2, K.WHITE); K.px(c, x - 2 - (g - 2), y - 2 - (g - 2), K.WHITE); K.px(c, x + 3, y - 2 - g, XC[26]);
  }

  /* ---------- shared own-edge composition: the page's themedOwn() with this module's glyph / motion (+ optional per-run decoration) ---------- */
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
  function plain(c, e, H) { comp(c, e, H, null); }
  /* per-run decorations (a handful of pixels each) */
  function decoSnow(c, e, H, s0, len, ri, pp) {          /* tundra / high mountain: three flakes drift down past the run */
    var k, u, Q = H.Q; if (e.p > .92) return;
    for (k = 0; k < 3; k++) { u = (pp * .9 + k * .33) % 1; e.P.atq(s0 + len * H.hash(e.seed + k * 3 + ri)); H.px(c, Q.x + Q.nx * 6 + Math.sin(u * 6 + k) * 2, Q.y + Q.ny * 6 - 6 + 12 * u, H.WHITE); }
  }
  function decoLitter(c, e, H, s0, len, ri, pp) {        /* forest: two russet leaves tumble down past the run */
    var k, u, Q = H.Q, X, Y; if (e.p > .9) return;
    for (k = 0; k < 2; k++) { u = (pp * .8 + k * .5) % 1; e.P.atq(s0 + len * (k + .5) / 2); X = Q.x + Q.nx * 7 + Math.sin(u * 7 + k) * 3; Y = Q.y + Q.ny * 7 - 5 + 12 * u;
      H.px(c, X, Y, XC[18]); H.px(c, X + ((Math.floor(u * 8) & 1) ? 1 : -1), Y, XC[19]); }
  }
  function decoScree(c, e, H, s0, len, ri, pp) {         /* mountain: two pebbles knocked loose bounce down */
    var k, u, Q = H.Q; if (e.p > .9) return;
    for (k = 0; k < 2; k++) { u = (pp * 1.2 + k * .5) % 1; e.P.atq(s0 + len * H.hash(e.seed + k * 7 + ri)); H.bx(c, Q.x + Q.nx * (4 + 3 * u), Q.y + Q.ny * (4 + 3 * u) + 12 * u * u - Math.abs(Math.sin(u * 9)) * 2, 2, 1, k ? XC[15] : XC[14]); }
  }

  /* ---------- glyphs (tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step; fr from the motion) ---------- */
  /* fisher */
  PFA.glyph('m12-fisher', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a long dark fisher bounding, back arching, bushy tail streaming */
    fisher(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi);
  });
  PFA.glyph('m12-quills', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a fan of cream porcupine quills with dark tips bristling out, the fisher's nose sliding under it (fr 2/3) */
    var i, j, a, L, b = Math.atan2(ny, nx);
    K.sq(c, x - nx, y - ny, 3, XC[27]);
    for (i = -2; i <= 2; i++) { a = b + i * .4; L = 4 + (fr & 1) + (i === 0 ? 1 : 0) + (z > 1 ? 1 : 0);
      for (j = 1; j <= L; j++) K.px(c, x + Math.cos(a) * j, y + Math.sin(a) * j, j === L ? XC[13] : XC[12]); }
    if (fr & 2) { K.px(c, x + tx * 4 - nx, y + ty * 4 - ny, C); K.px(c, x + tx * 5 - nx, y + ty * 5 - ny, Hi); K.px(c, x + tx * 6 - nx, y + ty * 6 - ny, XC[7]); }
  });
  PFA.glyph('m12-treedrop', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a bark trunk with the fisher coming down it head first, hind feet turned back gripping (fr = how far down) */
    var i, d = fr & 3;
    K.bx(c, x - 1, y - 7, 3, 14, XC[10]); for (i = -6; i < 7; i += 3) K.px(c, x - 1 + ((i / 3) & 1) * 2, y + i, XC[13]);
    K.px(c, x + 2, y - 6, XC[11]); K.px(c, x + 3, y - 7, XC[11]);
    for (i = 0; i < 5; i++) K.px(c, x + 2, y - 4 + d + i, i === 4 ? Hi : C);
    K.px(c, x + 3, y + 1 + d, Hi); K.px(c, x + 2, y + 2 + d, XC[7]); K.px(c, x + 3, y - 4 + d, A); K.px(c, x + 1, y - 4 + d, A); K.px(c, x + 1, y - 1 + d, A);
    K.px(c, x + 2, y - 5 + d, C); K.px(c, x + 3, y - 6 + d, C); K.px(c, x + 3, y - 7 + d, A);
  });
  PFA.glyph('m12-quillball', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a quill-ball porcupine flipped over: upright, tipping, belly-up (fr 2: pale belly, four little feet), tipping back */
    var i, a, rot = [0, .9, PI, -.9][fr & 3], up = rot - PI / 2, r = 3 + (z > 1 ? 1 : 0);
    K.sq(c, x, y, 5, XC[27]);
    for (i = -4; i <= 4; i++) { a = up + i * .35; K.px(c, x + Math.cos(a) * r, y + Math.sin(a) * r, XC[12]); K.px(c, x + Math.cos(a) * (r + 1), y + Math.sin(a) * (r + 1), XC[13]); }
    a = up + PI; K.px(c, x + Math.cos(a) * 2, y + Math.sin(a) * 2, '#e0c8a8'); K.px(c, x + Math.cos(a + .5) * 2, y + Math.sin(a + .5) * 2, '#e0c8a8');
    if ((fr & 3) === 2) { K.px(c, x - 2, y + 3, '#e0c8a8'); K.px(c, x + 2, y + 3, '#e0c8a8'); K.px(c, x - 1, y + 4, XC[13]); K.px(c, x + 1, y + 4, XC[13]); K.plus(c, x + 5, y - 3, 1, 1, Hi); }
  });
  /* wolverine cub */
  PFA.glyph('m12-wolverine', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a stout wolverine cub, cream stripe down the flank, claws out, snarling on fr 2 */
    wolverine(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi);
  });
  PFA.glyph('m12-snowball', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the cub rolled up in a snowball: snow round it, a paw, the striped back and the tail poking out as it turns */
    var a = (fr & 3) * 1.57, r = 3 + (z > 1 ? 1 : 0);
    K.sq(c, x, y, 2 * r + 1, K.WHITE); K.ringpx(c, x, y + 1, r, XC[6]); K.sq(c, x, y, 2 * r - 1, K.WHITE);
    K.px(c, x + Math.cos(a) * (r + 1), y + Math.sin(a) * (r + 1), A); K.px(c, x + Math.cos(a) * (r + 1) + 1, y + Math.sin(a) * (r + 1), K.WHITE);
    K.px(c, x + Math.cos(a + 1.6) * r, y + Math.sin(a + 1.6) * r, C); K.px(c, x + Math.cos(a + 1.9) * r, y + Math.sin(a + 1.9) * r, Hi);
    K.px(c, x + Math.cos(a + PI) * (r + 1), y + Math.sin(a + PI) * (r + 1), C); K.px(c, x + Math.cos(a + PI) * (r + 2), y + Math.sin(a + PI) * (r + 2), A);
  });
  PFA.glyph('m12-snarl', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a wolverine cub face: pale brow band, small round ears, snapping open to show white teeth (fr 1) */
    K.bx(c, x - 2, y - 3, 5, 6, C); K.bx(c, x - 3, y - 2, 7, 4, C); K.bx(c, x - 3, y - 2, 7, 1, Hi);
    K.px(c, x - 3, y - 4, C); K.px(c, x + 3, y - 4, C); K.px(c, x - 1, y - 1, XC[7]); K.px(c, x + 1, y - 1, XC[7]); K.px(c, x, y, XC[7]);
    if (fr & 1) { K.bx(c, x - 2, y + 2, 5, 2, XC[28]); K.px(c, x - 2, y + 2, K.WHITE); K.px(c, x + 2, y + 2, K.WHITE); K.px(c, x - 1, y + 3, K.WHITE); K.px(c, x + 1, y + 3, K.WHITE); }
    else { K.px(c, x - 1, y + 2, A); K.px(c, x + 1, y + 2, A); }
  });
  PFA.glyph('m12-boot', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* a stolen boot being shaken: brown leather, cream laces, bite holes, a cub head gripping the shaft */
    var o = [0, 1, 0, -1][fr & 3], fl = face(tx, nx, ny);
    K.bx(c, x - 1 + o, y - 4, 3, 5, XC[21]); K.px(c, x + o, y - 3, XC[22]); K.px(c, x + o, y - 1, XC[22]);
    K.bx(c, x - 1 + o + (fl < 0 ? -3 : 0), y + 1, 6, 2, XC[21]); K.bx(c, x - 1 + o + (fl < 0 ? -3 : 0), y + 3, 6, 1, XC[13]);
    K.px(c, x + o + fl * 2, y + 1, XC[13]); K.px(c, x + o + fl * 4, y + 2, XC[13]);
    K.px(c, x - 2 + o, y - 4, C); K.px(c, x - 3 + o, y - 4, C); K.px(c, x - 3 + o, y - 5, Hi); K.px(c, x - 4 + o, y - 4, XC[7]);
    K.px(c, x + 2 + o, y - 4 + (fr & 1), XC[22]); K.px(c, x + 3 + o, y - 3 + (fr & 1), XC[22]);
  });
  /* pangolin */
  PFA.glyph('m12-pangolin', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a pangolin walking upright on its hind legs, scales overlapping, tail held out behind */
    pangolin(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi);
  });
  PFA.glyph('m12-pball', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* the pangolin rolled into a scale ball, scale tips flaring out on odd frames */
    pball(c, K, x, y, (fr & 3) * .4, fr & 1, 3 + (z > 1 ? 1 : 0), C, A, Hi);
  });
  PFA.glyph('m12-ptail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a thick scaly tail swinging out from the edge and whacking (fr = swing angle) */
    var j, a, b = Math.atan2(ny, nx), sw = [-.9, -.3, .3, .9][fr & 3], X, Y, L = 6 + (z > 1 ? 1 : 0);
    for (j = 0; j <= L; j++) { a = b + sw * j / L; X = x - nx * 2 + Math.cos(a) * j * 1.2; Y = y - ny * 2 + Math.sin(a) * j * 1.2;
      K.px(c, X, Y, C); if (j < L - 1) { K.px(c, X - Math.sin(a), Y + Math.cos(a), (j & 1) ? A : C); K.px(c, X + Math.sin(a), Y - Math.cos(a), (j & 1) ? Hi : C); } }
    if ((fr & 3) === 3 || (fr & 3) === 0) K.plus(c, x - nx * 2 + Math.cos(b + sw) * (L + 3), y - ny * 2 + Math.sin(b + sw) * (L + 3), 1, 1, K.WHITE);
  });
  PFA.glyph('m12-mound', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a termite mound with holes, a long pink tongue flicking into one (fr = reach), red ants scattering */
    var r, w, k = fr % 3;
    for (r = 0; r < 7; r++) { w = Math.max(0, 3 - (r >> 1)); K.bx(c, x - w, y + 3 - r, 2 * w + 1, 1, (r & 1) ? XC[17] : '#a87848'); }
    K.px(c, x - 1, y + 1, XC[7]); K.px(c, x + 1, y - 1, XC[7]); K.px(c, x, y - 3, '#d8b080');
    K.px(c, x + 5, y + 2, C); K.px(c, x + 6, y + 2, C); K.px(c, x + 7, y + 3, C);
    if (k) { K.px(c, x + 4, y + 1, XC[8]); K.px(c, x + 3, y, XC[8]); if (k > 1) K.px(c, x + 2, y - 1, XC[8]); }
    K.px(c, x - 4 + fr, y + 3, XC[16]); K.px(c, x + 3 - fr, y - 2, XC[16]); K.px(c, x - 3, y - 1 - (fr & 1), XC[16]);
  });
  /* tamandua */
  PFA.glyph('m12-tamandua', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a pale tamandua in its black vest, tube snout first, tail curling */
    tamandua(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi);
  });
  PFA.glyph('m12-hook', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* a forepaw with three cream claws, the middle one a huge hook, raking outward (fr 1 reach) */
    var j, L = 4 + (fr & 1) + (z > 1 ? 1 : 0), X, Y;
    K.sq(c, x - nx * 2, y - ny * 2, 3, C); K.px(c, x - nx * 3 + tx, y - ny * 3 + ty, A); K.px(c, x - nx * 3 - tx, y - ny * 3 - ty, A);
    for (j = 0; j <= L; j++) { X = x + nx * j + tx * (j > L - 2 ? j - L + 2 : 0); Y = y + ny * j + ty * (j > L - 2 ? j - L + 2 : 0); K.px(c, X, Y, j === L ? K.WHITE : XC[24]); }
    for (j = 0; j < 2; j++) { K.px(c, x + nx * j + tx * 2, y + ny * j + ty * 2, XC[24]); K.px(c, x + nx * j - tx * 2, y + ny * j - ty * 2, XC[24]); }
    K.px(c, x + nx * 2 + tx * 3, y + ny * 2 + ty * 3, XC[24]); K.px(c, x + nx * 2 - tx * 3, y + ny * 2 - ty * 3, XC[24]);
  });
  PFA.glyph('m12-hug', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {         /* a tamandua hugging a vertical branch, vest showing, snout up, tail wrapped below, arms squeezing (fr) */
    var s = fr & 1;
    K.bx(c, x - 1, y - 7, 2, 14, XC[10]); K.px(c, x - 2, y - 6, XC[11]); K.px(c, x - 3, y - 7, XC[11]);
    K.bx(c, x + 1, y - 3, 3, 5, C); K.bx(c, x + 1, y - 1, 3, 2, A); K.px(c, x + 4, y - 2, C);
    K.px(c, x + 2, y - 4, C); K.px(c, x + 2, y - 5, C); K.px(c, x + 3, y - 6, C); K.px(c, x + 3, y - 7, XC[7]); K.px(c, x + 3, y - 4, XC[7]);
    K.px(c, x - 1 - s, y - 2, A); K.px(c, x - 2 - s, y - 2, XC[24]); K.px(c, x - 1 - s, y + 1, A); K.px(c, x - 2 - s, y + 1, XC[24]);
    K.px(c, x + 2, y + 2, C); K.px(c, x + 1, y + 3, C); K.px(c, x - 2, y + 4, C); K.px(c, x, y + 4, A);
  });
  PFA.glyph('m12-tongue', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a tube snout tip with a long thin pink tongue flicking out and back, ants stuck on it */
    var j, L = [2, 7, 10, 5][fr & 3] + (z > 1 ? 1 : 0), w;
    K.px(c, x - nx, y - ny, C); K.px(c, x - nx * 2, y - ny * 2, C); K.px(c, x - nx * 3, y - ny * 3, C); K.px(c, x - nx * 2 + tx, y - ny * 2 + ty, C); K.px(c, x, y, XC[7]);
    for (j = 1; j <= L; j++) { w = ((j >> 1) & 1) ? 1 : 0; K.px(c, x + nx * j + tx * w, y + ny * j + ty * w, Hi); }
    if (L > 5) { K.px(c, x + nx * 5 + tx * 1, y + ny * 5 + ty * 1 - 1, XC[16]); } if (L > 8) K.px(c, x + nx * 8, y + ny * 8 - 1, XC[16]);
  });
  PFA.glyph('m12-tailhang', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* hanging by the tail from a branch, arms spread wide in the tamandua threat pose, claws out (fr 1 / 2 spread) */
    var s = fr % 3;
    K.bx(c, x - 6, y - 7, 13, 1, XC[10]); K.px(c, x + 4, y - 8, XC[11]); K.px(c, x - 5, y - 8, XC[11]);
    K.px(c, x - 1, y - 8, C); K.px(c, x + 1, y - 8, C); K.px(c, x + 1, y - 6, C); K.px(c, x, y - 5, C);
    K.bx(c, x - 1, y - 4, 3, 6, C); K.bx(c, x - 1, y - 2, 3, 2, A); K.px(c, x, y + 2, C); K.px(c, x, y + 3, C); K.px(c, x + 1, y + 4, XC[7]);
    K.px(c, x - 2, y - 2 - s, A); K.px(c, x - 3, y - 2 - s * 2, C); K.px(c, x - 4, y - 2 - s * 2, XC[24]);
    K.px(c, x + 2, y - 2 - s, A); K.px(c, x + 3, y - 2 - s * 2, C); K.px(c, x + 4, y - 2 - s * 2, XC[24]);
  });
  /* roebuck */
  PFA.glyph('m12-roe', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {         /* a slim russet roebuck bounding, short antlers, white rump flashing */
    roe(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi);
  });
  PFA.glyph('m12-antler', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a russet head lowered, two short three-point antlers jabbing outward, pearled bases (fr 1 = jab) */
    var j, s, d = fr & 1, L = 4 + (z > 1 ? 1 : 0), X, Y;
    K.sq(c, x - nx * 2, y - ny * 2, 3, C); K.px(c, x - nx * 2 + tx * 2, y - ny * 2 + ty * 2, XC[7]);
    for (s = -1; s <= 1; s += 2) { for (j = 0; j <= L; j++) { X = x + nx * (j + d) + tx * s; Y = y + ny * (j + d) + ty * s; K.px(c, X, Y, j === 0 ? A : j === L ? K.WHITE : XC[24]); }
      K.px(c, x + nx * (2 + d) + tx * s * 2, y + ny * (2 + d) + ty * s * 2, XC[24]); K.px(c, x + nx * (3 + d) - tx * s * 0, y + ny * (3 + d), XC[24]); }
  });
  PFA.glyph('m12-antlerlock', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* two bucks with antlers locked, heads pushing against each other, straining back and forth (fr) */
    var s, j, o = (fr & 1) ? 1 : -1, X, Y;
    for (s = -1; s <= 1; s += 2) { X = x + tx * (5 * s + o); Y = y + ty * (5 * s + o); K.sq(c, X, Y, 3, C); K.px(c, X + tx * s * 2, Y + ty * s * 2, C);
      for (j = 1; j <= 4; j++) K.px(c, X - tx * s * j - nx * (j >> 1), Y - ty * s * j - ny * (j >> 1), XC[24]);
      K.px(c, X - tx * s * 2 + nx, Y - ty * s * 2 + ny, XC[24]); K.px(c, X - tx * s * 3 - nx * 2, Y - ty * s * 3 - ny * 2, K.WHITE); }
    if ((fr & 3) === 3) K.plus(c, x + tx * o + nx * 3, y + ty * o + ny * 3, 1, 1, Hi);
  });
  PFA.glyph('m12-bracken', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a russet bracken frond: pinnae either side, the fiddlehead uncurling (fr 0..2), a hoof stamping on it (fr 3) */
    var j, L = 6 + (z > 1 ? 1 : 0), g = fr & 3, X, Y;
    for (j = 0; j <= L - (g < 2 ? 2 - g : 0); j++) { X = x + nx * (j - 2); Y = y + ny * (j - 2); K.px(c, X, Y, XC[19]);
      if (j > 1 && j < L) { K.px(c, X + tx * (1 + (j & 1)), Y + ty * (1 + (j & 1)), (j & 1) ? XC[18] : C); K.px(c, X - tx * (1 + ((j + 1) & 1)), Y - ty * (1 + ((j + 1) & 1)), (j & 1) ? C : XC[18]); } }
    if (g < 2) { X = x + nx * (L - 4 + g); Y = y + ny * (L - 4 + g); K.ringpx(c, X + tx, Y + ty, 1, XC[19]); }
    if (g === 3) { X = x + nx * (L - 1); Y = y + ny * (L - 1); K.bx(c, X - 1, Y - 1, 3, 2, XC[13]); K.px(c, X, Y - 2, A); K.px(c, X, Y - 3, A); }
  });
  PFA.glyph('m12-fawns', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* twin spotted fawns curled side by side in the bracken, ears twitching in turn */
    var s, X;
    for (s = -1; s <= 1; s += 2) { X = x + s * 3; K.bx(c, X - 2, y - 1, 4, 3, C); K.px(c, X - 1, y - 1, XC[25]); K.px(c, X + 1, y, XC[25]); K.px(c, X, y + 1, XC[25]);
      K.px(c, X + s * 2, y - 2, C); K.px(c, X + s * 2, y - 3 - (((fr & 1) ? 1 : 0) === (s > 0 ? 1 : 0) ? 1 : 0), A); K.px(c, X + s * 3, y - 1, XC[7]); }
    K.px(c, x, y + 2, XC[18]); K.px(c, x - 6, y + 2, XC[19]); K.px(c, x + 6, y + 1, XC[19]);
  });
  /* goat kid gang */
  PFA.glyph('m12-kid', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {         /* a small white goat kid, horn buds, legs stiff: standing, pronking with all four together, splayed */
    kid(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi);
  });
  PFA.glyph('m12-kidheap', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* one kid standing on another kid's back, wobbling (fr) */
    var w = [0, 1, 0, -1][fr & 3];
    kid(c, K, x, y + 3, 1, 0, C, A, Hi); kid(c, K, x + w, y - 3, -1, w ? 2 : 0, C, A, Hi);
  });
  PFA.glyph('m12-ledge', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a grey rock ledge with a kid perched on top, a pebble falling off (fr) */
    K.bx(c, x - 5, y + 2, 11, 3, XC[14]); K.bx(c, x - 5, y + 2, 11, 1, XC[15]); K.px(c, x - 2, y + 3, XC[13]); K.px(c, x + 3, y + 4, XC[13]);
    kid(c, K, x, y - 1, face(tx, nx, ny), (fr & 3) === 2 ? 1 : 0, C, A, Hi);
    K.px(c, x + 6, y + 3 + (fr & 3) * 2, XC[15]);
  });
  PFA.glyph('m12-butt', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* two kid heads butting, horn buds meeting, an impact star on contact (fr 1) */
    var o = (fr & 1) ? 0 : 1;
    K.bx(c, x - 5 - o, y - 2, 3, 3, C); K.px(c, x - 6 - o, y + 1, C); K.px(c, x - 3 - o, y - 3, Hi); K.px(c, x - 4 - o, y - 3, A); K.px(c, x - 4 - o, y - 1, XC[7]);
    K.bx(c, x + 3 + o, y - 2, 3, 3, C); K.px(c, x + 6 + o, y + 1, C); K.px(c, x + 3 + o, y - 3, Hi); K.px(c, x + 4 + o, y - 3, A); K.px(c, x + 4 + o, y - 1, XC[7]);
    if (!o) { K.plus(c, x, y - 4, 1, 1, K.WHITE); K.px(c, x - 2, y - 5, Hi); K.px(c, x + 2, y - 5, Hi); }
  });
  /* yak calf herd */
  PFA.glyph('m12-yak', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {         /* a shaggy yak calf plodding, fur fringe swaying to the ground, wide cream horns */
    yak(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi);
  });
  PFA.glyph('m12-skirt', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a curtain of long shaggy fur strands swaying, frost on the tips */
    var i, j, L, t;
    K.bx(c, x - 4, y - 3, 9, 1, C);
    for (i = -4; i <= 4; i++) { L = 4 + (i & 1) + (z > 1 ? 1 : 0); t = Math.sin(fr * 1.57 + i * .5);
      for (j = 1; j <= L; j++) K.px(c, x + i + Math.round(t * j / L), y - 3 + j, j === L && !(i % 3) ? K.WHITE : (i & 1) ? A : C); }
  });
  PFA.glyph('m12-breath', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a muzzle blowing a steaming breath cloud in the cold, bleat marks rising */
    var g = fr % 3, d = 3 + g * 2, X = x + nx * d, Y = y + ny * d - g;
    K.px(c, x - nx, y - ny, C); K.px(c, x - nx + tx, y - ny + ty, C); K.px(c, x - nx - tx, y - ny - ty, C); K.px(c, x, y, A);
    K.ringpx(c, X, Y, 1 + g, XC[23]); if (g) K.px(c, X - 1, Y - 1, K.WHITE);
    if (g > 0) { K.px(c, X - 3, Y - 4 - g, Hi); K.px(c, X - 2, Y - 3 - g, Hi); K.px(c, X - 1, Y - 4 - g, Hi); }
  });
  PFA.glyph('m12-horns', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a shaggy calf head front-on, wide cream horns curving out, lowered and shoving (fr 1) */
    var o = fr & 1, X = x + nx * o, Y = y + ny * o;
    K.bx(c, X - 2, Y - 1, 5, 4, C); K.px(c, X - 2, Y + 3, A); K.px(c, X, Y + 3, A); K.px(c, X + 2, Y + 3, A); K.px(c, X - 1, Y, XC[7]); K.px(c, X + 1, Y, XC[7]); K.px(c, X, Y + 2, Hi);
    K.px(c, X - 3, Y - 1, XC[24]); K.px(c, X - 4, Y - 2, XC[24]); K.px(c, X - 5, Y - 2, XC[24]); K.px(c, X - 6, Y - 3, XC[24]); K.px(c, X - 6, Y - 4, K.WHITE);
    K.px(c, X + 3, Y - 1, XC[24]); K.px(c, X + 4, Y - 2, XC[24]); K.px(c, X + 5, Y - 2, XC[24]); K.px(c, X + 6, Y - 3, XC[24]); K.px(c, X + 6, Y - 4, K.WHITE);
    if (o) { K.px(c, X - 3, Y + 4, Hi); K.px(c, X + 3, Y + 4, Hi); }
  });
  /* snow leopard cub */
  PFA.glyph('m12-tail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* a huge thick tail in a swishing S, dark rings every few pixels, pale tip */
    var j, X, Y, L = 10 + (z > 1 ? 2 : 0), w;
    for (j = 0; j < L; j++) { w = Math.sin(j * .6 + fr * 1.57) * 2.5; X = x + tx * (j - L / 2) + nx * w; Y = y + ty * (j - L / 2) + ny * w;
      K.sq(c, X, Y, 2, j === L - 1 ? Hi : (j % 3 === 1) ? A : C); }
  });
  PFA.glyph('m12-leocub', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a chubby snow leopard cub with rosettes, crouched (fr 0) then stretched in the leap (fr 1) */
    leocub(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi);
  });
  PFA.glyph('m12-crag', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* a grey crag with the cub curled flat on it, the thick tail wrapped over its nose, an ear flicking (fr) */
    var i;
    K.bx(c, x - 5, y + 1, 11, 3, XC[14]); K.bx(c, x - 4, y + 1, 9, 1, XC[15]); K.px(c, x + 2, y + 2, XC[13]);
    K.bx(c, x - 3, y - 2, 7, 3, C); K.px(c, x - 2, y - 2, A); K.px(c, x + 1, y - 1, A);
    for (i = -3; i <= 4; i++) K.px(c, x + i, y, (i & 1) ? A : Hi);
    K.px(c, x + 3, y - 3 - (fr & 1), C); K.px(c, x + 4, y - 1, XC[7]);
  });
  PFA.glyph('m12-paw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {         /* a huge fluffy paw swatting out, dark toe pads, claws out on the swing (fr 1) */
    var o = fr & 1, X = x + nx * o * 2, Y = y + ny * o * 2, s;
    K.sq(c, X, Y, 5, C); K.px(c, X - nx * 3, Y - ny * 3, C); K.sq(c, X - nx * 2, Y - ny * 2, 3, C);
    K.px(c, X, Y, A); for (s = -1; s <= 1; s++) { K.px(c, X + nx * 2 + tx * s * 1.5, Y + ny * 2 + ty * s * 1.5, A); if (o) K.px(c, X + nx * 4 + tx * s * 1.5, Y + ny * 4 + ty * s * 1.5, K.WHITE); }
    K.px(c, X + tx * 3, Y + ty * 3, Hi); K.px(c, X - tx * 3, Y - ty * 3, Hi);
  });
  /* arctic fox kit */
  PFA.glyph('m12-den', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {         /* a den mound with a dark hole, round-eared kits popping up (fr 0 ears, 1 one kit, 2 two kits) */
    var g = fr % 3;
    K.bx(c, x - 6, y + 2, 13, 2, XC[9]); K.bx(c, x - 5, y + 1, 11, 1, K.WHITE); K.bx(c, x - 2, y, 5, 3, XC[7]);
    if (g === 0) { K.px(c, x - 1, y - 1, C); K.px(c, x + 1, y - 1, C); K.px(c, x - 1, y - 2, A); K.px(c, x + 1, y - 2, A); }
    else if (g === 1) kithead(c, K, x, y - 2, C, A, Hi, 0);
    else { kithead(c, K, x - 3, y - 2, C, A, Hi, 1); kithead(c, K, x + 3, y - 3, C, A, Hi, 0); }
  });
  PFA.glyph('m12-kit', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {         /* chain body: a grey-brown kit side-on, round ears, fluffy tail (for the tumble) */
    var fl = face(tx, nx, ny), i, g = fr & 1;
    if (fr & 2) { K.sq(c, x, y, 5, C); K.px(c, x + (g ? 2 : -2), y - 3, A); K.px(c, x + (g ? -3 : 3), y + 1, Hi); K.px(c, x, y, XC[7]); return; }
    for (i = -2; i <= 2; i++) { K.px(c, x + fl * i, y - 1, C); K.px(c, x + fl * i, y, C); }
    K.px(c, x + fl * 3, y - 2, C); K.px(c, x + fl * 3, y - 1, C); K.px(c, x + fl * 4, y - 1, XC[7]); K.px(c, x + fl * 3, y - 3, A);
    K.px(c, x + fl * (1 + g), y + 1, A); K.px(c, x - fl * (1 + g), y + 1, A); K.px(c, x - fl * 3, y - 1, C); K.px(c, x - fl * 4, y - 1, C); K.px(c, x - fl * 4, y - 2, Hi);
  });
  PFA.glyph('m12-dive', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* the mouse pounce: crouch, arc up, nose-dive into the snow with legs and tail sticking up */
    dive(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi);
  });
  PFA.glyph('m12-yip', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {         /* a round-eared kit face yipping, mouth open, chirp marks rising one by one (fr) */
    var i, X, Y, g = fr % 3;
    kithead(c, K, x, y, C, A, Hi, g > 0);
    for (i = 0; i < g; i++) { X = x - 4 + i * 8; Y = y - 5 - i * 2; K.px(c, X - 1, Y - 1, Hi); K.px(c, X, Y, Hi); K.px(c, X + 1, Y - 1, Hi); }
  });
  /* whiteout fox */
  PFA.glyph('m12-white', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* almost invisible: only two black eyes and a black nose, a white fox outline flickering in and out of the snow */
    var i, a, OX = [-4, -3, -2, 2, 3, 4, 4, 3, -3, -4, -5, 5], OY = [-4, -3, -2, -2, -3, -4, -1, 2, 2, -1, 1, 1];
    for (i = 0; i < 12; i++) if ((i + fr) % 3) K.px(c, x + OX[i], y + OY[i], (i & 1) ? C : Hi);
    K.px(c, x - 1, y - 1, XC[7]); K.px(c, x + 1, y - 1, XC[7]); K.px(c, x, y + 1, XC[7]);
    a = (fr & 3) * 2; K.bx(c, x - 6 + a, y + 4, 2, 1, K.WHITE); K.bx(c, x + 1 + a, y - 6, 2, 1, Hi);
  });
  PFA.glyph('m12-jaws', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* jaws snapping out of a snow mound: only the dark mouth, white teeth and two black eyes show */
    var g = fr % 3;
    K.bx(c, x - 4, y + 1, 9, 3, C); K.bx(c, x - 3, y, 7, 1, C); K.px(c, x - 4, y + 3, XC[6]); K.px(c, x + 4, y + 3, XC[6]);
    K.px(c, x - 2, y - 3, XC[7]); K.px(c, x + 2, y - 3, XC[7]); K.px(c, x, y - 1, XC[7]);
    if (g) { K.bx(c, x - 2, y + 1, 5, g * 2, XC[28]); K.px(c, x - 2, y + 1, K.WHITE); K.px(c, x + 2, y + 1, K.WHITE); K.px(c, x - 1, y + g * 2, K.WHITE); K.px(c, x + 1, y + g * 2, K.WHITE); }
    else K.bx(c, x - 2, y + 1, 5, 1, A);
  });
  PFA.glyph('m12-drift', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a snow drift ridge with two ear tips and a black nose cutting through it like a fin, snow spraying ahead */
    var i, h, fl = face(tx, nx, ny);
    for (i = -5; i <= 5; i++) { h = Math.round(2 - Math.abs(i) * .35); K.bx(c, x + i, y + 2 - h, 1, h + 1, i * fl < 0 ? XC[6] : C); }
    K.px(c, x + fl, y - 2, C); K.px(c, x + fl, y - 3, A); K.px(c, x + fl * 2, y - 2, C); K.px(c, x + fl * 2, y - 3, A);
    K.px(c, x + fl * 3, y - 1, XC[7]); K.px(c, x + fl * 4, y, XC[7]);
    K.px(c, x + fl * (5 + (fr & 1)), y - 1 - (fr & 2 ? 1 : 0), K.WHITE); K.px(c, x + fl * (6 + (fr & 1)), y - 2 - (fr & 1), Hi); K.px(c, x + fl * 5, y - 3 - (fr & 1), K.WHITE);
  });

  /* ---------- motions (mutate the scratch G; stateless in pp) ---------- */
  PFA.motion('m12-bound', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.up += Math.sin(w * PI) * 6; G.s += pp * .12; G.fr = (Math.floor(pp * 12) + k) & 3; });
  PFA.motion('m12-quill', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 4) + k) & 3; });
  PFA.motion('m12-climbdown', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 1.5 + ph) % 1) * 4); });
  PFA.motion('m12-flip', function (G, pp, k, ph) { var w = (pp * 1.4 + ph) % 1; G.fr = w < .3 ? 0 : w < .45 ? 1 : w < .85 ? 2 : 3; G.up += (G.fr === 1 || G.fr === 3) ? 2 : 0; });
  PFA.motion('m12-scrap', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .25 ? 0 : w < .5 ? 1 : w < .7 ? 2 : 3; G.d += w < .7 && w > .5 ? 2 : 0; G.t += Math.sin(pp * 18 + k) * .7; });
  PFA.motion('m12-snowroll', function (G, pp, k) { G.s += pp * .25; G.fr = (Math.floor(pp * 10) + k) & 3; G.up += Math.abs(Math.sin(pp * 9 + k)) * 2; });
  PFA.motion('m12-nip', function (G, pp, k, ph) { var w = (pp * 3 + ph) % 1; G.fr = w > .55 && w < .8 ? 1 : 0; G.d += G.fr * 3; });
  PFA.motion('m12-shakeboot', function (G, pp, k) { G.fr = (Math.floor(pp * 16) + k) & 3; G.t += ((Math.floor(pp * 16) + k) & 1) ? 1 : -1; });
  PFA.motion('m12-pwalk', function (G, pp, k) { G.s += pp * .12; G.fr = (Math.floor(pp * 6) + k) & 1; G.up += G.fr ? 0 : 1; });
  PFA.motion('m12-flare', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 3) + k) & 3; });
  PFA.motion('m12-whack', function (G, pp, k, ph) { var w = (pp * 1.8 + ph) % 1; G.fr = w < .4 ? 0 : w < .55 ? 1 : w < .7 ? 2 : 3; });
  PFA.motion('m12-lick', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 9 + ph * 3) + k) % 3; });
  PFA.motion('m12-clamber', function (G, pp, k) { G.s += pp * .14; G.fr = (Math.floor(pp * 6) + k) & 3; G.up += (G.fr & 1); });
  PFA.motion('m12-hookrake', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 1; G.d += G.fr; });
  PFA.motion('m12-squeeze', function (G, pp, k) { G.fr = (Math.floor(pp * 4) + k) & 1; });
  PFA.motion('m12-flick', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2.4 + ph) % 1) * 4); });
  PFA.motion('m12-spread', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.2 + ph) % 1) * 4)); G.t += Math.sin(pp * 5 + k) * .8; });
  PFA.motion('m12-roebound', function (G, pp, k, ph) { var w = (pp * 1.7 + ph) % 1; G.up += Math.sin(w * PI) * 8; G.fr = w < .15 || w > .85 ? 0 : w < .5 ? 1 : 2; });
  PFA.motion('m12-jab', function (G, pp, k, ph) { G.fr = ((pp * 3 + ph) % 1) > .6 ? 1 : 0; G.d += G.fr * 2; });
  PFA.motion('m12-strain', function (G, pp, k) { G.fr = (Math.floor(pp * 7) + k) & 3; });
  PFA.motion('m12-unfurl', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.3 + ph * .5) % 1) * 4)); });
  PFA.motion('m12-twitch', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 1; });
  PFA.motion('m12-boing', function (G, pp, k, ph) { var w = (pp * 2.2 + ph) % 1; G.up += Math.sin(w * PI) * 9; G.fr = w < .1 || w > .9 ? 0 : w < .5 ? 1 : 2; });
  PFA.motion('m12-wobble', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; });
  PFA.motion('m12-perch', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 4) + k) & 3; });
  PFA.motion('m12-butt', function (G, pp, k, ph) { G.fr = ((pp * 2.5 + ph) % 1) > .55 ? 1 : 0; G.up += G.fr; });
  PFA.motion('m12-plod', function (G, pp, k) { G.s += pp * .08; G.fr = (Math.floor(pp * 5) + k) & 3; G.up += (G.fr === 1) ? 1 : 0; });
  PFA.motion('m12-sway', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; });
  PFA.motion('m12-steam', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 1.6 + ph) % 1) * 3); });
  PFA.motion('m12-shove', function (G, pp, k, ph) { G.fr = ((pp * 2 + ph) % 1) > .5 ? 1 : 0; G.d += G.fr * 2; });
  PFA.motion('m12-swish', function (G, pp, k) { G.fr = (Math.floor(pp * 7) + k) & 3; });
  PFA.motion('m12-leap', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; G.fr = w > .45 && w < .85 ? 1 : 0; G.up += G.fr ? Math.sin((w - .45) / .4 * PI) * 9 : 0; G.s += G.fr * .04; });
  PFA.motion('m12-curl', function (G, pp, k, ph) { G.fr = ((pp * 1.5 + ph) % 1) < .8 ? 0 : 1; });
  PFA.motion('m12-swat', function (G, pp, k, ph) { var w = (pp * 2.6 + ph) % 1; G.fr = w > .6 ? 1 : 0; G.d += G.fr * 2; });
  PFA.motion('m12-peep', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.fr = w < .35 ? 0 : w < .7 ? 1 : 2; });
  PFA.motion('m12-mousedive', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; G.fr = w < .3 ? 0 : w < .55 ? 1 : w < .8 ? 2 : 3; G.up += G.fr === 1 ? Math.sin((w - .3) / .25 * PI) * 9 : 0; });
  PFA.motion('m12-yip', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2 + ph) % 1) * 3); });
  PFA.motion('m12-blizz', function (G, pp, k, ph) { G.t += Math.sin(pp * 7 + ph * 6) * 2.5; G.fr = (Math.floor(pp * 9) + k) & 3; if (((Math.floor(pp * 11) + k) % 5) === 4) G.vis = 0; });
  PFA.motion('m12-snapjaw', function (G, pp, k, ph) { var w = (pp * 2.5 + ph) % 1; G.fr = w < .5 ? 0 : w < .7 ? 2 : 1; });
  PFA.motion('m12-driftcut', function (G, pp, k) { G.s += pp * .3; G.fr = (Math.floor(pp * 12) + k) & 3; });

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ---------- */
  function dirGlyph(c, e, H, g, u, off, up, fr) {   /* a side-view glyph at fraction u of the chain path, facing the way it travels */
    var P = e.P, Q = H.Q, sgn = e.d >= 0 ? 1 : -1;
    P.atq(e.a + e.d * u);
    H.glyph(c, g, Q.x + Q.nx * off, Q.y + Q.ny * off - up, e.z, fr, e.col, e.acc, e.hi, -Q.ny * sgn, Q.nx * sgn, Q.nx, Q.ny);
  }
  function carFisher(c, e, H) {          /* the fisher bounds along in three long arcs; paired prints at each landing */
    var P = e.P, Q = H.Q, k, st = Math.floor(e.hh * 3);
    for (k = 1; k <= st && k < 3; k++) { P.atq(e.a + e.d * k / 3); H.px(c, Q.x + Q.nx * 3 - 1, Q.y + Q.ny * 3, e.acc); H.px(c, Q.x + Q.nx * 3 + 1, Q.y + Q.ny * 3, e.acc); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3 + 1, e.acc); }
    dirGlyph(c, e, H, 'm12-fisher', e.hh, 6, Math.abs(Math.sin(e.hh * PI * 3)) * 8, (Math.floor(e.p * 14) & 3) | (Math.sin(e.hh * PI * 3) > .4 ? 1 : 0));
  }
  function carWolverine(c, e, H) {       /* the cub charges stoutly; snow clods kick up behind it, three claw scratches left at the start */
    var P = e.P, Q = H.Q, k, u;
    P.atq(e.a + e.d * .05); for (k = -1; k <= 1; k++) H.ln(c, Q.x + Q.nx * 2 + k * 2, Q.y + Q.ny * 2 - 2, Q.x + Q.nx * 5 + k * 2 + 1, Q.y + Q.ny * 5 + 1, 1, e.hi);
    for (k = 0; k < 4; k++) { u = e.hh - .03 - k * .04; if (u < 0) break; P.atq(e.a + e.d * u); H.sq(c, Q.x + Q.nx * (5 + k), Q.y + Q.ny * (5 + k) - Math.sin(k * 1.1 + e.p * 9) * 3 - k, 2, H.WHITE); }
    dirGlyph(c, e, H, 'm12-wolverine', e.hh, 6, (Math.floor(e.p * 16) & 1), e.hh > .85 ? 2 : Math.floor(e.p * 14) & 1);
  }
  function carPangolin(c, e, H) {        /* rolled into a scale ball it rolls along the edge, scale clicks behind; at the end it uncurls and stands */
    var P = e.P, Q = H.Q, k, u;
    for (k = 1; k <= 3; k++) { u = e.hh - k * .1; if (u < 0) break; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 9 - 1, Q.y + Q.ny * 9 - 1, H.WHITE); H.px(c, Q.x + Q.nx * 9 + 1, Q.y + Q.ny * 9 + 1, H.WHITE); }
    if (e.hh < .88) { P.atq(e.a + e.d * e.hh); pball(c, H, Q.x + Q.nx * 5, Q.y + Q.ny * 5, e.hh * 18 * (e.d >= 0 ? 1 : -1), 0, 3 + (e.z > 1 ? 1 : 0), e.col, e.acc, e.hi); }
    else dirGlyph(c, e, H, 'm12-pangolin', e.hh, 5, 0, Math.floor(e.p * 8) & 1);
  }
  function carTamandua(c, e, H) {        /* the tamandua clambers along, tail curling; a faint musk haze drifts up behind it (the stinker of the forest) */
    var P = e.P, Q = H.Q, u, k = 0;
    for (u = Math.max(0, e.hh - .3); u < e.hh - .04; u += .04) { P.atq(e.a + e.d * u); k++; if ((k + Math.floor(e.p * 16)) % 3) H.px(c, Q.x + Q.nx * (9 + Math.sin(u * 30 + e.p * 12) * 1.5), Q.y + Q.ny * (9 + Math.sin(u * 30 + e.p * 12) * 1.5) - (e.hh - u) * 12, k & 1 ? e.hi : '#d8d890'); }
    dirGlyph(c, e, H, 'm12-tamandua', e.hh, 6, (Math.floor(e.p * 10) & 1), Math.floor(e.p * 10) & 3);
  }
  function carRoe(c, e, H) {             /* the roebuck bounds in two high arcs, slot prints at each landing, the white rump flashing at the top of each bound */
    var P = e.P, Q = H.Q, k, st = Math.floor(e.hh * 2), arc = Math.sin(e.hh * PI * 2), X, Y;
    for (k = 1; k <= st && k < 2; k++) { P.atq(e.a + e.d * k / 2); X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3; H.px(c, X - 2, Y, e.acc); H.px(c, X - 1, Y, e.acc); H.px(c, X + 1, Y + 1, e.acc); H.px(c, X + 2, Y + 1, e.acc); }
    dirGlyph(c, e, H, 'm12-roe', e.hh, 6, Math.abs(arc) * 11, Math.abs(arc) > .3 ? 1 : 2);
    if (Math.abs(arc) > .8) { P.atq(e.a + e.d * e.hh); H.plus(c, Q.x + Q.nx * 6 - (e.d >= 0 ? 4 : -4), Q.y + Q.ny * 6 - Math.abs(arc) * 11 - 3, 1, 1, H.WHITE); }
  }
  function carKid(c, e, H) {             /* the kid boings from rock ledge to rock ledge: three little grey ledges along the way */
    var P = e.P, Q = H.Q, k, f = e.hh * 3 - Math.floor(e.hh * 3);
    for (k = 1; k <= 3; k++) { P.atq(e.a + e.d * k / 3); H.bx(c, Q.x + Q.nx * 4 - 3, Q.y + Q.ny * 4 + 2, 7, 2, '#8a8c94'); H.bx(c, Q.x + Q.nx * 4 - 3, Q.y + Q.ny * 4 + 2, 7, 1, '#b4b6bc'); }
    dirGlyph(c, e, H, 'm12-kid', e.hh, 4, Math.sin(f * PI) * 10, f < .12 || f > .88 ? 0 : 1);
  }
  function carYak(c, e, H) {             /* a little herd: three calves plod in file, the leader blowing a puff of breath */
    var P = e.P, Q = H.Q, k, u, g;
    for (k = 2; k >= 0; k--) { u = e.hh - k * .13; if (u < 0) continue; dirGlyph(c, e, H, 'm12-yak', u, 6, 0, (Math.floor(e.p * 8) + k) & 3); }
    g = (e.p * 3) % 1; if (g < .6) { P.atq(e.a + e.d * Math.min(1, e.hh + .05)); H.ringpx(c, Q.x + Q.nx * (7 + g * 4), Q.y + Q.ny * (7 + g * 4) - 3 - g * 3, 1 + g * 3, '#e8eef4'); }
  }
  function carLeo(c, e, H) {             /* the cub dashes along with its huge ringed tail streaming behind it in a long wave */
    var P = e.P, Q = H.Q, u, j = 0, w;
    for (u = Math.max(0, e.hh - .3); u < e.hh - .03; u += .022) { P.atq(e.a + e.d * u); w = Math.sin(u * 40 - e.p * 20) * 2; j++;
      H.sq(c, Q.x + Q.nx * (6 + w), Q.y + Q.ny * (6 + w), 2, j === 1 ? e.hi : (j % 3 === 0 ? e.acc : e.col)); }
    dirGlyph(c, e, H, 'm12-leocub', e.hh, 6, (Math.floor(e.p * 12) & 1) * 2, Math.floor(e.p * 12) & 1);
  }
  function carKits(c, e, H) {            /* two fox kits tumble out of the den and roll along over each other */
    var P = e.P, Q = H.Q, k, u;
    P.atq(e.a + e.d * .04); H.bx(c, Q.x + Q.nx * 4 - 2, Q.y + Q.ny * 4, 5, 2, '#141418'); H.bx(c, Q.x + Q.nx * 4 - 3, Q.y + Q.ny * 4 - 1, 7, 1, H.WHITE);
    for (k = 1; k >= 0; k--) { u = Math.max(0, e.hh - k * .07); dirGlyph(c, e, H, 'm12-kit', u, 5, Math.abs(Math.sin(e.p * 16 + k * 1.6)) * 4, (Math.floor(e.p * 10) + k * 2) & 3); }
  }
  function carWhiteout(c, e, H) {        /* a blizzard band blows along the edge; inside it only two black eyes and a black nose travel, the outline flickering */
    var P = e.P, Q = H.Q, k, u, X, Y;
    for (k = 0; k < 14; k++) { u = e.hh - .02 - H.hash(k * 3.1) * .35; if (u < 0) continue; P.atq(e.a + e.d * u); X = Q.x + Q.nx * (4 + H.hash(k * 5.7 + Math.floor(e.p * 12)) * 8); Y = Q.y + Q.ny * (4 + H.hash(k * 2.3) * 8);
      H.bx(c, X, Y, 2, 1, k & 1 ? H.WHITE : e.hi); }
    dirGlyph(c, e, H, 'm12-white', e.hh, 7, 0, Math.floor(e.p * 9) & 3);
  }

  /* ---------- motifs ---------- */
  function M(name, draw, meta) { PFA.motif(name, draw, meta); }
  function snow(c, e, H) { comp(c, e, H, decoSnow); }
  function litter(c, e, H) { comp(c, e, H, decoLitter); }
  function scree(c, e, H) { comp(c, e, H, decoScree); }
  /* fisher */
  M('fisher-bound', litter, { nm: 'fishers', desc: 'long dark-brown fishers with grizzled heads and long bushy tails bounding in arcs, back arching; the chain bounds in three arcs leaving paired prints', fam: 'bite', gap: 18, g: 'm12-fisher', mo: 'm12-bound', x: '-', car: 'custom', carDraw: carFisher });
  M('fisher-quillslide', plain, { nm: 'porcupine quills', desc: 'fans of cream porcupine quills with dark tips bristling, a fisher nose sliding in underneath', fam: 'thorn', gap: 12, g: 'm12-quills', mo: 'm12-quill', x: '-', car: 'train' });
  M('fisher-treedrop', litter, { nm: 'tree drops', desc: 'bark trunks with a fisher coming down head first, hind feet turned back to grip', fam: 'leaf', gap: 14, g: 'm12-treedrop', mo: 'm12-climbdown', x: '-', car: 'thread' });
  M('fisher-quillflip', plain, { nm: 'flipped quill balls', desc: 'a quill-ball porcupine tipped over onto its back, pale belly and little feet up, then back again', fam: 'bash', gap: 14, g: 'm12-quillball', mo: 'm12-flip', x: '-', car: 'roll' });
  /* wolverine cub */
  M('wolverine-stripe', snow, { nm: 'wolverine cubs', desc: 'stout dark wolverine cubs with a cream stripe down the flank and a pale brow, shoving and snarling; the chain charges through snow, clods flying', fam: 'bash', gap: 16, g: 'm12-wolverine', mo: 'm12-scrap', x: '-', car: 'custom', carDraw: carWolverine });
  M('wolverine-snowball', plain, { nm: 'snowball tumbles', desc: 'a cub rolled up in a snowball, a paw, the striped back and the tail poking out as it turns', fam: 'puff', gap: 14, g: 'm12-snowball', mo: 'm12-snowroll', x: 'snow', car: 'roll' });
  M('wolverine-snarl', plain, { nm: 'snarling cubs', desc: 'a wolverine cub face with a pale brow band and round ears snapping open on white teeth', fam: 'bite', gap: 12, g: 'm12-snarl', mo: 'm12-nip', x: '-', car: 'comet' });
  M('wolverine-boot', plain, { nm: 'stolen boots', desc: 'a stolen camp boot shaken side to side, laces flapping, bite holes in the leather', fam: 'slash', gap: 14, g: 'm12-boot', mo: 'm12-shakeboot', x: '-', car: 'hop' });
  /* pangolin */
  M('pangolin-walk', plain, { nm: 'pangolins', desc: 'pangolins walking upright on their hind legs, domed bodies of overlapping scales, tails held out; the chain rolls as a scale ball and uncurls at the end', fam: 'shield', gap: 18, g: 'm12-pangolin', mo: 'm12-pwalk', x: '-', car: 'custom', carDraw: carPangolin });
  M('pangolin-ball', plain, { nm: 'scale balls', desc: 'a pangolin rolled into a ball of overlapping scales, the scale tips flaring out sharp', fam: 'thorn', gap: 14, g: 'm12-pball', mo: 'm12-flare', x: '-', car: 'roll' });
  M('pangolin-tail', plain, { nm: 'scaly tails', desc: 'a thick scaly tail swinging out from the edge and whacking, an impact star at the end of the swing', fam: 'bash', gap: 16, g: 'm12-ptail', mo: 'm12-whack', x: '-', car: 'comet' });
  M('pangolin-mound', plain, { nm: 'termite mounds', desc: 'termite mounds with holes, a long pink tongue flicking into one, red ants scattering', fam: 'web', gap: 16, g: 'm12-mound', mo: 'm12-lick', x: '-', car: 'hop' });
  /* tamandua */
  M('tamandua-vest', litter, { nm: 'tamanduas', desc: 'pale tamanduas in a black vest, long tube snout first, prehensile tail curling; the chain clambers along leaving a faint musk haze', fam: 'slash', gap: 18, g: 'm12-tamandua', mo: 'm12-clamber', x: '-', car: 'custom', carDraw: carTamandua });
  M('tamandua-hook', plain, { nm: 'hook claws', desc: 'a forepaw with three cream claws, the middle one a huge hook, raking outward', fam: 'thrust', gap: 12, g: 'm12-hook', mo: 'm12-hookrake', x: '-', car: 'comet' });
  M('tamandua-hug', plain, { nm: 'branch hugs', desc: 'a tamandua hugging a vertical branch, vest showing, snout up, tail wrapped round below', fam: 'shield', gap: 14, g: 'm12-hug', mo: 'm12-squeeze', x: '-', car: 'train' });
  M('tamandua-tongue', plain, { nm: 'tongue flicks', desc: 'a long thin pink tongue flicking out of a tube snout and back, ants stuck to it', fam: 'web', gap: 12, g: 'm12-tongue', mo: 'm12-flick', x: '-', car: 'zig' });
  M('tamandua-tailhang', litter, { nm: 'tail hangs', desc: 'a tamandua hanging from a branch by its tail with its arms spread wide in the threat pose, claws out', fam: 'leaf', gap: 16, g: 'm12-tailhang', mo: 'm12-spread', x: '-', car: 'thread' });
  /* roebuck */
  M('roe-bound', litter, { nm: 'roebucks', desc: 'slim russet roebucks with short three-point antlers bounding, white rump patch flashing; the chain bounds in two high arcs leaving slot prints', fam: 'thrust', gap: 18, g: 'm12-roe', mo: 'm12-roebound', x: '-', car: 'custom', carDraw: carRoe });
  M('roe-antler', plain, { nm: 'short antlers', desc: 'a russet head lowered, two short three-point antlers with pearled bases jabbing outward', fam: 'thrust', gap: 12, g: 'm12-antler', mo: 'm12-jab', x: '-', car: 'comet' });
  M('roe-antlerlock', plain, { nm: 'locked antlers', desc: 'two bucks with antlers locked, heads pushing against each other, straining to and fro', fam: 'shield', gap: 18, g: 'm12-antlerlock', mo: 'm12-strain', x: '-', car: 'train' });
  M('roe-bracken', litter, { nm: 'bracken fronds', desc: 'russet bracken fronds with the fiddlehead uncurling, a hoof stamping down on them', fam: 'thorn', gap: 12, g: 'm12-bracken', mo: 'm12-unfurl', x: '-', car: 'train' });
  M('roe-twinfawn', plain, { nm: 'twin fawns', desc: 'twin white-spotted fawns curled side by side in the bracken, ears twitching in turn', fam: 'mend', gap: 16, g: 'm12-fawns', mo: 'm12-twitch', x: '-', car: 'hop' });
  /* goat kid gang */
  M('goatkid-boing', scree, { nm: 'goat kids', desc: 'small white goat kids with horn buds boinging straight up on stiff legs, pebbles knocked loose; the chain boings from rock ledge to rock ledge', fam: 'bash', gap: 14, g: 'm12-kid', mo: 'm12-boing', x: '-', car: 'custom', carDraw: carKid });
  M('goatkid-heap', plain, { nm: 'kid heaps', desc: 'one goat kid standing on another kid\'s back, wobbling', fam: 'shield', gap: 16, g: 'm12-kidheap', mo: 'm12-wobble', x: '-', car: 'train' });
  M('goatkid-ledge', scree, { nm: 'rock ledges', desc: 'grey rock ledges with a kid perched on top, a pebble falling off', fam: 'puff', gap: 16, g: 'm12-ledge', mo: 'm12-perch', x: '-', car: 'hop' });
  M('goatkid-butt', plain, { nm: 'head butts', desc: 'two kid heads butting, horn buds meeting, an impact star on contact', fam: 'bash', gap: 16, g: 'm12-butt', mo: 'm12-butt', x: '-', car: 'hop' });
  /* yak calf herd */
  M('yakcalf-shag', snow, { nm: 'yak calves', desc: 'shaggy yak calves plodding, a long fur fringe swaying to the ground, wide cream horns; the chain is three calves in file, the leader puffing breath', fam: 'bash', gap: 18, g: 'm12-yak', mo: 'm12-plod', x: '-', car: 'custom', carDraw: carYak });
  M('yakcalf-skirt', snow, { nm: 'fur skirts', desc: 'curtains of long shaggy fur strands swaying, frost on the tips', fam: 'puff', gap: 12, g: 'm12-skirt', mo: 'm12-sway', x: '-', car: 'cloud' });
  M('yakcalf-breath', plain, { nm: 'breath clouds', desc: 'a muzzle blowing a steaming breath cloud into the cold, bleat marks rising', fam: 'ripple', gap: 14, g: 'm12-breath', mo: 'm12-steam', x: '-', car: 'rings' });
  M('yakcalf-horns', plain, { nm: 'wide horns', desc: 'a shaggy calf head front-on with wide cream horns curving out, lowered and shoving', fam: 'bash', gap: 16, g: 'm12-horns', mo: 'm12-shove', x: '-', car: 'comet' });
  /* snow leopard cub */
  M('snowleo-tail', snow, { nm: 'ringed tails', desc: 'huge thick smoky tails swishing in an S, dark rings and a pale tip; the chain dashes along with the tail streaming behind in a long wave', fam: 'ripple', gap: 16, g: 'm12-tail', mo: 'm12-swish', x: '-', car: 'custom', carDraw: carLeo });
  M('snowleo-cub', plain, { nm: 'leopard cubs', desc: 'chubby rosetted snow leopard cubs crouching, then stretching out in a leap', fam: 'thrust', gap: 16, g: 'm12-leocub', mo: 'm12-leap', x: '-', car: 'hop' });
  M('snowleo-crag', snow, { nm: 'crag naps', desc: 'a grey crag with the cub curled flat on it, the thick tail wrapped over its nose, an ear flicking', fam: 'shield', gap: 16, g: 'm12-crag', mo: 'm12-curl', x: '-', car: 'train' });
  M('snowleo-paw', plain, { nm: 'big paws', desc: 'huge fluffy paws swatting out, dark toe pads, claws out on the swing', fam: 'slash', gap: 12, g: 'm12-paw', mo: 'm12-swat', x: '-', car: 'comet' });
  /* arctic fox kit */
  M('foxkit-den', snow, { nm: 'den kits', desc: 'a snowy den mound with a dark hole, round-eared fox kits popping up one and two at a time; the chain is two kits tumbling out and rolling over each other', fam: 'bash', gap: 16, g: 'm12-den', mo: 'm12-peep', x: '-', car: 'custom', carDraw: carKits });
  M('foxkit-dive', snow, { nm: 'mouse dives', desc: 'an arctic fox mouse-pouncing: crouch, arc up, nose-dive into the snow with hind legs and tail sticking up', fam: 'thrust', gap: 14, g: 'm12-dive', mo: 'm12-mousedive', x: '-', car: 'hop' });
  M('foxkit-yip', plain, { nm: 'yips', desc: 'a round-eared kit face yipping, mouth open, chirp marks rising one by one', fam: 'ripple', gap: 14, g: 'm12-yip', mo: 'm12-yip', x: '-', car: 'rings' });
  /* whiteout fox */
  M('whiteout-eyes', snow, { nm: 'whiteout eyes', desc: 'almost invisible white foxes: only two black eyes and a black nose show, the outline flickering in the snow; the chain is a blizzard band with the three dots travelling inside', fam: 'puff', gap: 16, g: 'm12-white', mo: 'm12-blizz', x: '-', car: 'custom', carDraw: carWhiteout });
  M('whiteout-jaws', plain, { nm: 'snow jaws', desc: 'jaws snapping out of a snow mound: only the dark mouth, white teeth and black eyes show', fam: 'bite', gap: 14, g: 'm12-jaws', mo: 'm12-snapjaw', x: '-', car: 'comet' });
  M('whiteout-drift', plain, { nm: 'drift fins', desc: 'a snow drift ridge with two ear tips and a black nose cutting through it like a fin, snow spraying ahead', fam: 'thrust', gap: 16, g: 'm12-drift', mo: 'm12-driftcut', x: 'snow', car: 'trail' });
})();
