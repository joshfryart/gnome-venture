/* Motif module, medium batch m14 (thistle-beast, nettle-lurker, cactus-beast, will-o-wisp, foxfire-wisp, storm-wisp). TEMPLATE.md section 10.3.
   35 motifs, each with its own pixel glyph (ids prefixed m14-). All six creatures get their own signature motif with its own chain effect (carDraw):
   a thistle head tumbling in the wind shedding down, a hunched nettle lurker creeping through parting stalks, a barrel cactus waddling on stubby feet,
   a marsh light bobbing ahead of a line of sinking footprints, glowing mycelium creeping over the ground, and ball lightning drifting with a bolt
   flickering back to where it started. The two wisps are not siblings: the will-o'-wisp is a cold marsh light (flame / lantern), the foxfire wisp is
   fungal glow on rotten wood (stump / caps / mycelium); the storm wisp is ball lightning. They share no motif.
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation in the frame loops (scratch H.Q / H.G only).
   Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy
   default are untouched. Medium glyphs are a little larger than small ones (up to ~13 px) but stay within ~22 px of the edge. */
(function () {
  /* fixed accent colours (not palette tones): 4 white, 5 thistle green, 6 thistle light green, 7 soil, 8 root tan, 9 eye yellow, 10 welt red,
     11 stink yellow-green, 12 spine cream, 13 spine tip, 14 water blue, 15 cactus flesh, 16 flower yellow, 17 sand, 18 bog mud, 19 stump wood,
     20 punk wood, 21 mushroom stem, 22 rain, 23 dim glow, 24 nettle hair */
  var XC = [null, null, null, null, '#ffffff', '#6e9c3a', '#a8cc6a', '#5a3e26', '#c8a878', '#f0e060', '#e05a5a', '#c4cc60', '#f4ecc0', '#b88a40',
    '#7ec8f0', '#c8e8a0', '#f8d850', '#e0c080', '#4a3a24', '#7a5a38', '#a8825a', '#ece0c4', '#d8ecff', '#4a7a3a', '#e4f4cc'];
  var PI = Math.PI;

  function face(tx, nx, ny) { return Math.abs(nx) > Math.abs(ny) ? (nx > 0 ? 1 : -1) : (tx >= 0 ? 1 : -1); }

  /* ---------- body routines ---------- */
  /* thistle head: spiny green bulb (cross-hatched bracts, side spikes), a purple brush tuft on top that sways (s), a stub of stem */
  function thistle(c, K, x, y, fr, C, A, Hi, z) {
    var s = [0, 1, 0, -1][fr & 3], w = z > 1 ? 3 : 2, i;
    K.bx(c, x - 2, y - 1, 5, 4, XC[5]); K.px(c, x - 1, y, XC[6]); K.px(c, x + 1, y + 1, XC[6]); K.px(c, x, y + 2, A); K.px(c, x - 1, y + 2, XC[6]); K.px(c, x + 1, y - 1, XC[6]);
    K.px(c, x - 3, y, XC[6]); K.px(c, x + 3, y, XC[6]); K.px(c, x - 3, y + 2, XC[6]); K.px(c, x + 3, y + 2, XC[6]); K.px(c, x - 4, y - 1, Hi); K.px(c, x + 4, y - 1, Hi);
    K.px(c, x, y + 3, A); K.px(c, x, y + 4, A);
    K.bx(c, x - w, y - 2, 2 * w + 1, 1, C); K.bx(c, x - w + s, y - 3, 2 * w + 1, 1, C);
    for (i = -w; i <= w; i += 2) K.px(c, x + i + s, y - 4, C);
    K.px(c, x + s, y - 5, C); K.px(c, x + s, y - 4, Hi);
    if ((fr & 3) === 2) { K.px(c, x + 3 + s, y - 6, K.WHITE); K.px(c, x + 4 + s, y - 7, K.WHITE); K.px(c, x + 4 + s, y - 6, Hi); }
  }
  /* hunched nettle lurker: a low green hump, three stalks with serrated leaves standing up from the back, two yellow eyes low at the front */
  function lurker(c, K, x, y, fl, fr, C, A, Hi) {
    var i, s, sw = (fr & 1) ? 1 : 0, X;
    K.bx(c, x - 3, y - 1, 7, 3, C); K.bx(c, x - 2, y - 2, 5, 1, C); K.bx(c, x - 1, y - 3, 3, 1, C); K.bx(c, x - 3, y + 2, 7, 1, A);
    K.px(c, x - fl * 3, y + 3, A); K.px(c, x + fl * 2, y + 3, A);
    for (i = -1; i <= 1; i++) { X = x - fl * (i * 2); s = i === 0 ? 4 : 3;
      K.px(c, X, y - 3 - (i === 0 ? 0 : -1), A); K.px(c, X + sw * fl, y - 4 - (i === 0 ? 0 : -1), C); K.px(c, X + sw * fl, y - 1 - s - 1, C);
      K.px(c, X + sw * fl - 1, y - 3 - s + 1, C); K.px(c, X + sw * fl + 1, y - 3 - s + 1, XC[6]); K.px(c, X + sw * fl, y - 3 - s, Hi); }
    if ((fr & 3) !== 3) { K.px(c, x + fl * 1, y, XC[9]); K.px(c, x + fl * 3, y, XC[9]); } else { K.px(c, x + fl * 1, y, A); K.px(c, x + fl * 3, y, A); }
    K.px(c, x - fl, y - 1, XC[24]); K.px(c, x + fl * 2, y - 2, XC[24]);
  }
  /* barrel cactus: round ribbed barrel, cream spine clusters round the rim, a pink flower crown, stubby feet stepping (fr & 1) */
  function barrel(c, K, x, y, fr, C, A, Hi, z) {
    var g = fr & 1, e = z > 1 ? 1 : 0;
    K.bx(c, x - 2, y - 3 - e, 5, 1, C); K.bx(c, x - 3, y - 2 - e, 7, 5 + e, C); K.bx(c, x - 2, y + 3, 5, 1, C);
    K.px(c, x - 1, y - 2 - e, A); K.px(c, x - 1, y, A); K.px(c, x - 1, y + 2, A); K.px(c, x + 1, y - 1, A); K.px(c, x + 1, y + 1, A); K.px(c, x - 2, y - 1, XC[15]);
    K.px(c, x - 4, y - 1, XC[12]); K.px(c, x - 4, y + 1, XC[12]); K.px(c, x + 4, y - 1, XC[12]); K.px(c, x + 4, y + 1, XC[12]); K.px(c, x - 3, y - 4 - e, XC[12]); K.px(c, x + 3, y - 4 - e, XC[12]);
    K.px(c, x - 1, y - 4 - e, Hi); K.px(c, x + 1, y - 4 - e, Hi); K.px(c, x, y - 5 - e, Hi); K.px(c, x, y - 4 - e, XC[16]);
    K.px(c, x - 2 + g, y + 4, A); K.px(c, x + 1 + g, y + 4, A);
  }
  /* marsh light: a pale teardrop flame with a white core, the tail flicking (s); fr 1 = the tail curls like a beckoning finger; halo motes on odd frames */
  function lure(c, K, x, y, fr, C, A, Hi, z) {
    var s = [0, 1, 0, -1][fr & 3];
    K.sq(c, x, y, 3 + (z > 1 ? 1 : 0), C); K.px(c, x - 1, y - 2, C); K.px(c, x + 1, y - 2, C); K.px(c, x, y - 2, Hi); K.px(c, x + s, y - 3, C); K.px(c, x + s, y - 4, Hi);
    K.px(c, x, y, K.WHITE); K.px(c, x, y - 1, K.WHITE);
    if ((fr & 3) === 1) { K.px(c, x + 2, y - 5, Hi); K.px(c, x + 3, y - 4, Hi); }
    if (fr & 1) { K.px(c, x - 3, y + 1, A); K.px(c, x + 3, y + 1, A); K.px(c, x, y + 3, Hi); }
  }
  /* ball lightning: a blue-white ball with a white core and four crackling zig tendrils turning by fr */
  function ball(c, K, x, y, fr, C, A, Hi, z) {
    var i, a, r = 2 + (z > 1 ? 1 : 0);
    K.sq(c, x, y, 2 * r + 1, C); K.sq(c, x, y, 2, K.WHITE); K.px(c, x - r, y - r, A); K.px(c, x + r, y + r, A);
    for (i = 0; i < 4; i++) { if ((i + fr) % 4 === 3) continue; a = i * 1.571 + fr * .39;
      K.px(c, x + Math.cos(a) * (r + 1), y + Math.sin(a) * (r + 1), Hi); K.px(c, x + Math.cos(a + .35) * (r + 2), y + Math.sin(a + .35) * (r + 2), C);
      K.px(c, x + Math.cos(a - .1) * (r + 3), y + Math.sin(a - .1) * (r + 3), K.WHITE); }
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
  function decoDown(c, e, H, s0, len, ri, pp) {          /* grassland wind: two thistle-down seeds lift off and drift sideways */
    var k, u, Q = H.Q, X, Y; if (e.p > .92) return;
    for (k = 0; k < 2; k++) { u = (pp * .7 + k * .5) % 1; e.P.atq(s0 + len * H.hash(e.seed + k * 5 + ri)); X = Q.x + Q.nx * (5 + 8 * u) + 6 * u; Y = Q.y + Q.ny * (5 + 8 * u) - 6 * u - Math.sin(u * 7) * 1.5;
      H.px(c, X, Y, H.WHITE); H.px(c, X - 1, Y - 1, H.WHITE); H.px(c, X + 1, Y - 1, H.WHITE); H.px(c, X, Y + 1, e.acc); }
  }
  function decoHair(c, e, H, s0, len, ri, pp) {          /* stinging hairs: tiny white glints blink along the run */
    var k, Q = H.Q; if (e.p > .92) return;
    for (k = 0; k < 3; k++) if ((Math.floor(pp * 9) + k) % 3 === 0) { e.P.atq(s0 + len * H.hash(e.seed + k * 7 + ri)); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, H.WHITE); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, XC[24]); }
  }
  function decoSand(c, e, H, s0, len, ri, pp) {          /* desert: sand grains blow along, a heat shimmer wobbles above */
    var k, u, Q = H.Q; if (e.p > .9) return;
    for (k = 0; k < 3; k++) { u = (pp * 1.1 + k * .33) % 1; e.P.atq(s0 + len * u); H.px(c, Q.x + Q.nx * (2 + k), Q.y + Q.ny * (2 + k) + Math.sin(u * 9) * .8, XC[17]); }
    if (ri === 0) { e.P.atq(s0 + len * .5); for (k = -3; k <= 3; k += 2) H.px(c, Q.x + Q.nx * 12 + k, Q.y + Q.ny * 12 + Math.round(Math.sin(pp * 12 + k)), XC[17]); }
  }
  function decoBog(c, e, H, s0, len, ri, pp) {           /* marsh: a low mist band breathes in and out near the edge */
    var s, Q = H.Q, v = .4 * Math.sin(PI * e.p);
    for (s = 0; s < len; s += 3) if (H.hash(s * .7 + Math.floor(pp * 8) + ri) < v) { e.P.atq(s0 + s); H.px(c, Q.x + Q.nx * (2 + H.hash(s) * 3), Q.y + Q.ny * (2 + H.hash(s) * 3), e.hi); }
  }
  function decoGlow(c, e, H, s0, len, ri, pp) {          /* rotten wood: three glow motes rise slowly off the run */
    var k, u, Q = H.Q; if (e.p > .93) return;
    for (k = 0; k < 3; k++) { u = (pp * .6 + k * .33) % 1; e.P.atq(s0 + len * (k + .5) / 3); H.px(c, Q.x + Q.nx * 4 + Math.sin(u * 6 + k) * 2, Q.y + Q.ny * 4 - 12 * u, u < .5 ? e.col : e.hi); }
  }
  function decoRain(c, e, H, s0, len, ri, pp) {          /* coast squall: three slanted rain streaks fall past the run */
    var k, u, Q = H.Q, X, Y; if (e.p > .92) return;
    for (k = 0; k < 3; k++) { u = (pp * 1.6 + k * .33) % 1; e.P.atq(s0 + len * H.hash(e.seed + k * 3 + ri)); X = Q.x + Q.nx * 7 - 4 + 6 * u; Y = Q.y + Q.ny * 7 - 8 + 16 * u;
      H.px(c, X, Y, XC[22]); H.px(c, X - 1, Y - 2, XC[22]); }
  }

  /* ---------- glyphs (tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step; fr from the motion) ---------- */
  /* thistle beast */
  PFA.glyph('m14-thistle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a thistle head: spiny green bulb with a swaying purple brush, a down seed lifting on fr 2 */
    thistle(c, K, x, y, fr, C, A, Hi, z);
  });
  PFA.glyph('m14-down', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* a thistle-down seed: dark seed under a white parachute of hairs that spread and close */
    var o = fr & 1;
    K.px(c, x, y + 2, A); K.px(c, x, y + 1, A); K.px(c, x, y, C);
    K.px(c, x - 1, y - 1, K.WHITE); K.px(c, x - 2 - o, y - 2 + o, K.WHITE); K.px(c, x + 1, y - 1, K.WHITE); K.px(c, x + 2 + o, y - 2 + o, K.WHITE);
    K.px(c, x, y - 2, K.WHITE); K.px(c, x - 1, y - 3, Hi); K.px(c, x + 1, y - 3, Hi); if (z > 1) { K.px(c, x - 3 - o, y - 3 + o, Hi); K.px(c, x + 3 + o, y - 3 + o, Hi); }
  });
  PFA.glyph('m14-needle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a spiny leaf dart falling point first: purple shaft, green side spikes, white point */
    var i, L = 5 + (z > 1 ? 1 : 0), o = fr & 1;
    for (i = 0; i < L; i++) K.px(c, x, y - 3 + i, C);
    K.px(c, x - 1, y - 2 + o, XC[6]); K.px(c, x + 1, y - 1 + o, XC[6]); K.px(c, x - 1, y + o, XC[5]); K.px(c, x + 1, y + 1 - o, XC[5]);
    K.px(c, x, y - 3 + L, Hi); K.px(c, x, y - 2 + L, K.WHITE); K.px(c, x, y - 4, A);
  });
  PFA.glyph('m14-sprout', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* Root Deep: forked tan roots dig down under a soil line while a green shoot pushes up, a purple bud on top (fr = growth) */
    var i, g = fr & 3, h = 2 + g;
    K.bx(c, x - 3, y + 2, 7, 1, XC[7]); K.px(c, x - 1, y + 3, XC[8]); K.px(c, x + 1, y + 3, XC[8]); K.px(c, x - 2, y + 4, XC[8]); K.px(c, x + 2, y + 4, XC[8]);
    if (g > 1) { K.px(c, x - 3, y + 5, XC[8]); K.px(c, x + 3, y + 5, XC[8]); K.px(c, x, y + 4, XC[8]); }
    for (i = 0; i < h; i++) K.px(c, x, y + 1 - i, XC[5]);
    K.px(c, x - 1, y + 2 - h, XC[6]); K.px(c, x - 2, y + 1 - h, XC[6]); K.px(c, x + 1, y + 1 - h, XC[5]); K.px(c, x + 2, y - h, XC[6]);
    if (g >= 2) { K.px(c, x, y - h, C); K.px(c, x, y - h - 1, C); K.px(c, x - 1, y - h - 1, C); K.px(c, x + 1, y - h - 1, Hi); }
  });
  PFA.glyph('m14-heap', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* Spine Heap: a mound of crossed spiny leaves, two purple heads on top, the spine tips bristling (fr 1) */
    var i, o = fr & 1;
    K.bx(c, x - 4, y + 1, 9, 2, XC[5]); K.bx(c, x - 3, y, 7, 1, XC[5]);
    for (i = -3; i <= 3; i += 2) { K.px(c, x + i - 1, y - 1, XC[6]); K.px(c, x + i + 1, y - 1, XC[6]); K.px(c, x + i, y, XC[6]); K.px(c, x + i - 1 - o, y - 2 - o, Hi); K.px(c, x + i + 1 + o, y - 2 - o, Hi); }
    K.bx(c, x - 3, y - 3, 2, 2, C); K.bx(c, x + 1, y - 2, 2, 2, C); K.px(c, x - 2, y - 4, C); K.px(c, x + 2, y - 3, Hi);
    K.px(c, x - 5, y + 2, A); K.px(c, x + 5, y + 2, A);
  });
  PFA.glyph('m14-whip', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* Prickly Whip: a spiny stem lashing in an arc (fr = swing phase), a purple head on the tip */
    var j, a, X = x, Y = y, L = 8 + (z > 1 ? 2 : 0), b = Math.atan2(ny, nx) + [-.9, -.3, .3, .9][fr & 3];
    for (j = 1; j <= L; j++) { a = b + j * .09; X = x + Math.cos(a) * j; Y = y + Math.sin(a) * j; K.px(c, X, Y, XC[5]); if (j & 1) K.px(c, X - Math.sin(a) * ((j & 2) ? 1 : -1), Y + Math.cos(a) * ((j & 2) ? 1 : -1), Hi); }
    K.sq(c, X, Y, 3, C); K.px(c, X + Math.cos(a) * 2, Y + Math.sin(a) * 2, C);
  });
  /* nettle lurker */
  PFA.glyph('m14-lurker', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the hunched green lurker: stalks on its back, yellow eyes low at the front (blink on fr 3) */
    lurker(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi);
  });
  PFA.glyph('m14-hairs', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* Sting Curtain: a serrated leaf strip with a fringe of fine stinging hairs hanging off it, glinting tips */
    var i, j, L, sw = (fr & 2) ? 1 : 0;
    K.bx(c, x - 4, y - 3, 9, 1, C); for (i = -4; i <= 4; i += 2) K.px(c, x + i, y - 4, C); K.px(c, x - 5, y - 3, A); K.px(c, x + 5, y - 3, A);
    for (i = -3; i <= 3; i += 2) { L = 4 + ((i + fr) & 1) + (z > 1 ? 1 : 0);
      for (j = 0; j < L; j++) K.px(c, x + i + (j > 2 ? sw : 0), y - 2 + j, XC[24]); K.px(c, x + i + sw, y - 2 + L, ((i + fr) & 2) ? K.WHITE : Hi); }
  });
  PFA.glyph('m14-stem', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* Stem Wall: a square nettle stem with paired serrated leaves at two nodes, hairs on the stem */
    var o = fr & 1, h = 5 + (z > 1 ? 1 : 0), n;
    K.bx(c, x - 1, y - h, 2, 2 * h, C); K.px(c, x - 1, y - h, Hi);
    for (n = -2; n <= 2; n += 4) { K.bx(c, x - 1, y + n, 2, 1, A);
      K.px(c, x - 2, y + n, C); K.px(c, x - 3, y + n - 1, C); K.px(c, x - 4, y + n - 1 - o, C); K.px(c, x - 3, y + n, XC[6]);
      K.px(c, x + 1, y + n, C); K.px(c, x + 2, y + n - 1, C); K.px(c, x + 3, y + n - 1 + o, C); K.px(c, x + 2, y + n, XC[6]); }
    K.px(c, x - 2, y - 4, XC[24]); K.px(c, x + 1, y + 1, XC[24]); K.px(c, x - 2, y + 4, XC[24]);
  });
  PFA.glyph('m14-noose', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* Stem Snare: a nettle stem bent into a loop that pulls tight (fr 1), leaves on the loop, hairs bristling */
    var r = 3 - (fr & 1) + (z > 1 ? 1 : 0);
    K.ringpx(c, x, y, r, C); K.px(c, x + r, y + r + 1, C); K.px(c, x + r + 1, y + r + 2, C); K.px(c, x + r + 2, y + r + 2, A);
    K.px(c, x - r - 1, y - 1, C); K.px(c, x - r - 2, y - 2, XC[6]); K.px(c, x + 1, y - r - 1, C); K.px(c, x + 2, y - r - 2, XC[6]);
    K.px(c, x - r, y + r, Hi); K.px(c, x + r, y - r, Hi); if (fr & 1) { K.px(c, x - 1, y + r + 1, K.WHITE); K.px(c, x + r + 1, y, K.WHITE); }
  });
  PFA.glyph('m14-welt', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* Brush Sting: a serrated nettle leaf brushes past and white welts on red rings pop up behind it (fr = how many) */
    var i, g = fr % 3;
    for (i = 0; i < 5; i++) { K.px(c, x - 4 + i, y - 3 - (i >> 1), C); K.px(c, x - 4 + i, y - 2 - (i >> 1), (i & 1) ? XC[6] : C); }
    K.px(c, x - 3, y - 4, C); K.px(c, x - 1, y - 5, C); K.px(c, x + 1, y - 6, Hi);
    for (i = 0; i <= g; i++) { K.ringpx(c, x - 2 + i * 3, y + 2, 1, XC[10]); K.px(c, x - 2 + i * 3, y + 2, K.WHITE); }
  });
  PFA.glyph('m14-stench', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* Cut-Stalk Stench: a cut stalk with a pale wound, two wavy yellow-green stink lines curling up out of it */
    var i, w, g = fr & 3;
    K.bx(c, x - 1, y, 3, 4, C); K.bx(c, x - 1, y, 3, 1, XC[15]); K.px(c, x + 2, y + 2, C); K.px(c, x + 3, y + 1, XC[6]); K.px(c, x - 1, y + 4, A); K.px(c, x + 1, y + 4, A);
    for (w = -1; w <= 1; w += 2) for (i = 0; i < 5; i++) if ((i + g) % 5 !== 4) K.px(c, x + w * 2 + Math.round(Math.sin(i * 1.4 + g * 1.57 + w) * 1.2), y - 2 - i - (g & 1), i < 2 ? XC[11] : Hi);
  });
  PFA.glyph('m14-eyes', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* Stalk-Shadow Lurk: a pocket of shadow between two nettle stalks, a pair of yellow eyes in it (shut on fr 3) */
    var i, sw = fr & 1;
    K.bx(c, x - 3, y - 1, 7, 3, A); K.bx(c, x - 2, y - 2, 5, 1, A);
    if ((fr & 3) !== 3) { K.px(c, x - 1, y, XC[9]); K.px(c, x + 1, y, XC[9]); } else { K.px(c, x - 1, y + 1, C); K.px(c, x + 1, y + 1, C); }
    for (i = 0; i < 7; i++) { K.px(c, x - 4 + (i > 4 ? sw : 0), y + 2 - i, C); K.px(c, x + 4 - (i > 4 ? sw : 0), y + 2 - i, C); }
    K.px(c, x - 5, y - 2, C); K.px(c, x + 5, y - 1, C); K.px(c, x - 4 + sw, y - 5, Hi); K.px(c, x + 4 - sw, y - 5, Hi);
  });
  /* cactus beast */
  PFA.glyph('m14-barrel', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the walking barrel: round ribbed cactus, cream spines, pink crown, stubby feet stepping */
    barrel(c, K, x, y, fr, C, A, Hi, z);
  });
  PFA.glyph('m14-cspine', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a long cream cactus spine pointing out of a green areole, a gold point, trembling */
    var j, L = 5 + z, o = (fr & 1) ? .5 : -.5;
    K.sq(c, x - nx, y - ny, 3, C); K.px(c, x - nx, y - ny, K.WHITE);
    for (j = 1; j <= L; j++) K.px(c, x + nx * j + tx * o * (j > 3 ? 1 : 0), y + ny * j + ty * o * (j > 3 ? 1 : 0), j === L ? XC[13] : XC[12]);
    K.px(c, x + nx * 2 + tx * 2, y + ny * 2 + ty * 2, XC[12]); K.px(c, x + nx * 2 - tx * 2, y + ny * 2 - ty * 2, XC[12]);
  });
  PFA.glyph('m14-water', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* Water Store: a cut wedge of cactus, pale wet flesh on top, a blue drop welling up out of it (fr = how far) */
    var g = fr & 3;
    K.bx(c, x - 3, y, 7, 3, C); K.bx(c, x - 2, y, 5, 1, XC[15]); K.bx(c, x - 3, y + 3, 7, 1, A); K.px(c, x - 4, y + 1, XC[12]); K.px(c, x + 4, y + 1, XC[12]);
    K.sq(c, x, y - 1 - g, 2 + (g > 1 ? 1 : 0), XC[14]); K.px(c, x - (g > 1 ? 1 : 0), y - 2 - g, K.WHITE); if (g >= 2) K.px(c, x, y - 3 - g, XC[14]);
    if (g === 3) { K.px(c, x - 2, y - 1, XC[14]); K.px(c, x + 2, y - 2, K.WHITE); }
  });
  PFA.glyph('m14-roll', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* Barrel Roll: the barrel on its side, ribs and spines turning round with it (fr 0..7), the pink crown going over */
    var i, a = (fr & 7) * .785, r = 3 + (z > 1 ? 1 : 0), ca, sa;
    K.bx(c, x - r + 1, y - r, 2 * r - 1, 2 * r + 1, C); K.bx(c, x - r, y - r + 1, 2 * r + 1, 2 * r - 1, C);
    for (i = 0; i < 4; i++) { ca = Math.cos(a + i * 1.571); sa = Math.sin(a + i * 1.571);
      K.px(c, x + ca * (r - 1), y + sa * (r - 1), A); K.px(c, x + ca * (r + 1), y + sa * (r + 1), XC[12]); K.px(c, x + ca * (r + 2), y + sa * (r + 2), i & 1 ? XC[13] : XC[12]); }
    K.px(c, x + Math.cos(a + .785) * (r - 1), y + Math.sin(a + .785) * (r - 1), Hi); K.px(c, x + Math.cos(a + .785) * r, y + Math.sin(a + .785) * r, Hi); K.px(c, x, y, A);
  });
  PFA.glyph('m14-bloom', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* Pink-Crown Spores: a pink crown flower opening on a green knob (fr 0..2), gold pollen puffing out when open */
    var i, g = fr % 3, r = 1 + g;
    K.px(c, x, y + 2, C); K.px(c, x - 1, y + 3, C); K.px(c, x + 1, y + 3, C); K.bx(c, x - 2, y + 4, 5, 1, C);
    for (i = 0; i < 6; i++) K.px(c, x + Math.cos(i * 1.047 + g * .3) * r, y + Math.sin(i * 1.047 + g * .3) * r, Hi);
    if (g > 0) for (i = 0; i < 6; i++) K.px(c, x + Math.cos(i * 1.047 + .5) * (r - .5), y + Math.sin(i * 1.047 + .5) * (r - .5), Hi);
    K.sq(c, x, y, 2, XC[16]);
    if (g === 2) for (i = 0; i < 4; i++) K.px(c, x + Math.cos(i * 1.571 + .785) * 5, y + Math.sin(i * 1.571 + .785) * 5 - 1, i & 1 ? XC[16] : K.WHITE);
  });
  PFA.glyph('m14-buried', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* Barrel Hide: the barrel sunk into sand to the middle, only the ribbed top and its spines showing, spines bristling (fr 1) */
    var o = fr & 1;
    K.bx(c, x - 5, y + 1, 11, 2, XC[17]); K.px(c, x - 6, y + 2, XC[17]); K.px(c, x + 6, y + 2, XC[17]);
    K.bx(c, x - 2, y - 3, 5, 1, C); K.bx(c, x - 3, y - 2, 7, 3, C); K.px(c, x - 1, y - 2, A); K.px(c, x + 1, y - 1, A); K.px(c, x - 1, y, A);
    K.px(c, x - 4, y - 1 - o, XC[12]); K.px(c, x - 3, y - 4 - o, XC[12]); K.px(c, x, y - 4 - o, Hi); K.px(c, x, y - 5 - o, XC[12]); K.px(c, x + 3, y - 4 - o, XC[12]); K.px(c, x + 4, y - 1 - o, XC[12]);
    if (o) { K.px(c, x - 5, y - 2, XC[13]); K.px(c, x + 5, y - 2, XC[13]); }
  });
  /* will-o'-wisp */
  PFA.glyph('m14-lure', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* the marsh light: a pale cold teardrop flame, white core, tail flicking and curling like a beckoning finger */
    lure(c, K, x, y, fr, C, A, Hi, z);
  });
  PFA.glyph('m14-flame', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* Wisp Burn: three tongues of cold flame licking up, heights cycling, white tips, a dark scorch underneath */
    var i, j, h, s = (fr & 1) ? 1 : -1;
    K.bx(c, x - 3, y + 2, 7, 1, A);
    for (i = -1; i <= 1; i++) { h = 3 + ((i + 1 + fr) % 3) + (z > 1 ? 1 : 0);
      for (j = 0; j < h; j++) K.px(c, x + i * 2 + (j > h - 3 ? s * (i === 0 ? 0 : 1) : 0), y + 1 - j, j === 0 ? Hi : C);
      K.px(c, x + i * 2 + (i === 0 ? 0 : s), y + 1 - h, K.WHITE); }
    K.px(c, x - 1, y + 1, Hi); K.px(c, x + 1, y + 1, Hi);
  });
  PFA.glyph('m14-lantern', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* Bog Lantern: a little dark-framed lantern with a handle, cold light inside, a glow ring pulsing out (fr 2) */
    var g = fr % 3;
    K.px(c, x - 1, y - 5, A); K.px(c, x, y - 6, A); K.px(c, x + 1, y - 5, A);
    K.bx(c, x - 2, y - 4, 5, 7, A); K.bx(c, x - 1, y - 3, 3, 5, C); K.px(c, x, y - 1, K.WHITE); K.px(c, x, y - 2, Hi); K.bx(c, x - 3, y + 3, 7, 1, A);
    if (g === 1) { K.px(c, x - 4, y - 1, Hi); K.px(c, x + 4, y - 1, Hi); K.px(c, x, y - 8, Hi); }
    if (g === 2) K.ringpx(c, x, y - 1, 5 + (z > 1 ? 1 : 0), C);
  });
  PFA.glyph('m14-tendril', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* Ghostlight Tendril: a wavering filament of pale light reaching out of the edge, curling at the tip, half see-through */
    var j, w, X = x, Y = y, L = 8 + 2 * (z > 1 ? 1 : 0);
    for (j = 0; j <= L; j++) { w = Math.sin(j * .7 + fr * 1.57) * 2; X = x + nx * j + tx * w; Y = y + ny * j + ty * w;
      if ((j + fr) % 4 === 0) continue; K.px(c, X, Y, j > L - 3 ? Hi : C); }
    K.px(c, X + tx * 2, Y + ty * 2, K.WHITE); K.px(c, X + tx * 2 - nx, Y + ty * 2 - ny, Hi);
  });
  PFA.glyph('m14-spores', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* Lantern Spore Cloud: three glowing spores circling each other, little halos winking */
    var i, a, X, Y;
    for (i = 0; i < 3; i++) { a = i * 2.094 + fr * .5; X = x + Math.cos(a) * 3; Y = y + Math.sin(a) * 2.5; K.sq(c, X, Y, 2, C);
      if ((i + fr) & 1) { K.px(c, X - 1, Y - 2, Hi); K.px(c, X + 2, Y + 1, Hi); } else K.px(c, X, Y, K.WHITE); }
  });
  /* foxfire wisp */
  PFA.glyph('m14-stump', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a rotten stump with a jagged top, green foxfire patches pulsing in turn on the wood (fr) */
    var i, PX = [-2, 1, 2, -1], PY = [0, -1, 2, 2];
    K.bx(c, x - 3, y - 2, 7, 5, XC[19]); K.px(c, x - 3, y - 3, XC[19]); K.px(c, x - 1, y - 4, XC[19]); K.px(c, x, y - 3, XC[19]); K.px(c, x + 2, y - 4, XC[19]); K.px(c, x + 3, y - 3, XC[19]);
    K.bx(c, x - 1, y - 2, 3, 1, A); K.px(c, x - 4, y + 2, XC[19]); K.px(c, x + 4, y + 2, XC[19]); K.px(c, x - 5, y + 3, XC[19]); K.bx(c, x - 3, y + 3, 7, 1, A);
    for (i = 0; i < 4; i++) { if ((i + fr) % 3 === 0) K.px(c, x + PX[i], y + PY[i], XC[23]); else { K.sq(c, x + PX[i], y + PY[i], 2, C); if ((i + fr) % 3 === 2) K.px(c, x + PX[i], y + PY[i], Hi); } }
    if ((fr % 3) === 2) { K.px(c, x - 5, y - 1, Hi); K.px(c, x + 5, y, Hi); K.px(c, x + 1, y - 6, Hi); }
  });
  PFA.glyph('m14-punk', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* a crumb of soft rotten punkwood with a glowing green rim, tumbling (fr) */
    var o = fr & 1, w = 3 + (z > 1 ? 1 : 0);
    if (o) K.bx(c, x - 1, y - 1, w - 1, w, XC[20]); else K.bx(c, x - 1, y - 1, w, w - 1, XC[20]);
    K.px(c, x - 2, y - 1 + o, C); K.px(c, x + w - 1, y + o, C); K.px(c, x, y + w - 1 - o, C); K.px(c, x + 1, y - 2, C); K.px(c, x, y, A);
    if (o) K.px(c, x - 2, y - 2, Hi); else K.px(c, x + w, y - 1, Hi);
  });
  PFA.glyph('m14-caps', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* Glow Cap Shell: a clump of three glowing mushroom caps on pale stems, gills lighting up one cap at a time */
    var i, X, h;
    K.bx(c, x - 5, y + 2, 11, 1, XC[19]);
    for (i = -1; i <= 1; i++) { X = x + i * 3; h = i === 0 ? 4 : 2 + (z > 1 ? 1 : 0);
      K.bx(c, X, y + 2 - h, 1, h, XC[21]); K.bx(c, X - 1, y + 1 - h, 3, 1, (i + 1) === (fr % 3) ? Hi : C); K.bx(c, X - 2, y + 2 - h, 5, 1, C); K.px(c, X, y + 1 - h - 1, C); }
  });
  PFA.glyph('m14-sporepuff', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a puff of glowing spores swelling (fr 0..2); fully open it curls a beckoning wisp */
    var i, g = fr % 3, r = 1 + g;
    if (g === 0) K.sq(c, x, y, 3, C);
    for (i = 0; i < 8; i++) K.px(c, x + Math.cos(i * .785) * r * 1.4, y + Math.sin(i * .785) * r, (i & 1) ? C : Hi);
    if (g === 2) { K.px(c, x + 5, y - 1, C); K.px(c, x + 6, y - 2, C); K.px(c, x + 6, y - 3, Hi); K.px(c, x + 5, y - 4, Hi); K.px(c, x, y, K.WHITE); }
  });
  PFA.glyph('m14-hypha', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a glowing mycelium knot: three forked threads spreading from a bright node (fr 1 = longer) */
    var i, j, a, L = 4 + (fr & 1) + (z > 1 ? 1 : 0), b = Math.atan2(ny, nx), X, Y;
    for (i = -1; i <= 1; i++) { a = b + i * 1.2; for (j = 2; j <= L; j++) { X = x + Math.cos(a) * j; Y = y + Math.sin(a) * j; K.px(c, X, Y, j === L ? Hi : C); }
      K.px(c, X + Math.cos(a + .8) * 1.5, Y + Math.sin(a + .8) * 1.5, C); K.px(c, X + Math.cos(a - .8) * 1.5, Y + Math.sin(a - .8) * 1.5, C); }
    K.sq(c, x, y, 3, C); K.px(c, x, y, Hi);
  });
  /* storm wisp */
  PFA.glyph('m14-ball', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* ball lightning: a blue-white ball, white core, crackling zig tendrils turning */
    ball(c, K, x, y, fr, C, A, Hi, z);
  });
  PFA.glyph('m14-bolt', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* Storm Zap: a forked zigzag bolt striking outward, white core, the jag pattern shifting each frame */
    var j, L = 7 + 2 * (z > 1 ? 1 : 0), O = [0, 1, 2, 1, 0, -1, -2, -1], o, X = x, Y = y;
    for (j = 0; j <= L; j++) { o = O[(j + fr * 2) & 7] * .9; X = x + nx * j + tx * o; Y = y + ny * j + ty * o; K.px(c, X, Y, (j & 1) ? K.WHITE : C); if (j === 4) { K.px(c, X + tx * 2, Y + ty * 2, C); K.px(c, X + tx * 3 + nx, Y + ty * 3 + ny, Hi); } }
    K.px(c, X + nx, Y + ny, Hi); K.px(c, x - tx, y - ty, C); K.px(c, x + tx, y + ty, C);
  });
  PFA.glyph('m14-rain', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* Rain Sip: a raindrop drawn upward, a streak trailing below it, a white glint (fr flickers the streak) */
    var o = fr & 1;
    K.px(c, x, y - 2, C); K.bx(c, x - 1, y - 1, 3, 3, C); K.px(c, x, y + 2, C); K.px(c, x - 1, y - 1, K.WHITE); K.px(c, x + 1, y + 1, A);
    K.px(c, x, y + 4 + o, XC[22]); K.px(c, x, y + 6 + o, Hi);
  });
  PFA.glyph('m14-squall', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* Squall Veil: a small grey-blue cloud with a slanting curtain of rain streaks driven under it (fr shifts the streaks) */
    var i, j, o = fr & 1, d = (fr >> 1) & 1;
    K.bx(c, x - 3, y - 4, 7, 2, C); K.bx(c, x - 2, y - 5, 4, 1, C); K.px(c, x + 2, y - 5, Hi); K.bx(c, x - 3, y - 2, 7, 1, A);
    for (i = -3; i <= 3; i += 2) for (j = 0; j < 3; j++) K.px(c, x + i - j + o, y - 1 + j * 2 + d, XC[22]);
  });
  PFA.glyph('m14-spark', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* Spark Shed: a crackling spark that changes shape every frame: plus, cross, jag, wink */
    var g = fr & 3;
    if (g === 0) { K.plus(c, x, y, 2 + (z > 1 ? 1 : 0), 1, C); K.px(c, x + 3, y - 3, Hi); }
    else if (g === 1) { K.px(c, x - 1, y - 1, C); K.px(c, x + 1, y + 1, C); K.px(c, x - 1, y + 1, C); K.px(c, x + 1, y - 1, C); K.px(c, x - 2, y - 2, Hi); K.px(c, x + 2, y + 2, Hi); K.px(c, x - 2, y + 2, Hi); K.px(c, x + 2, y - 2, Hi); }
    else if (g === 2) { K.px(c, x - 3, y + 1, Hi); K.px(c, x - 2, y, C); K.px(c, x - 1, y - 1, C); K.px(c, x + 1, y + 1, C); K.px(c, x + 2, y, C); K.px(c, x + 3, y - 1, Hi); }
    else { K.sq(c, x, y, 3, C); }
    K.px(c, x, y, K.WHITE);
  });

  /* ---------- motions (mutate the scratch G; stateless in pp) ---------- */
  PFA.motion('m14-nod', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 4) + k) & 3; G.t += Math.sin(pp * 4 + k) * .8; });
  PFA.motion('m14-drift', function (G, pp, k, ph) { G.t += Math.sin(pp * 3 + ph * 6) * 3; G.up += Math.sin(pp * 4 + k) * 2; G.fr = (Math.floor(pp * 6) + k) & 1; });
  PFA.motion('m14-darts', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 10) + k) & 1; G.t += Math.sin(pp * 6 + ph * 5) * .7; });
  PFA.motion('m14-grow', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.2 + ph * .3) % 1) * 5)); });
  PFA.motion('m14-pile', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 3) + k) & 1; });
  PFA.motion('m14-lash', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2 + ph) % 1) * 4); });
  PFA.motion('m14-creep', function (G, pp, k) { G.s += pp * .08; G.fr = (Math.floor(pp * 6) + k) & 3; });
  PFA.motion('m14-hang', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; });
  PFA.motion('m14-rustle', function (G, pp, k) { G.fr = (Math.floor(pp * 7) + k) & 1; G.t += G.fr ? .5 : -.5; });
  PFA.motion('m14-cinch', function (G, pp, k, ph) { G.fr = ((pp * 2.2 + ph) % 1) > .55 ? 1 : 0; });
  PFA.motion('m14-welt', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.5 + ph) % 1) * 4)); });
  PFA.motion('m14-stink', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; });
  PFA.motion('m14-peer', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w > .85 ? 3 : (Math.floor(pp * 4) + k) & 1; });
  PFA.motion('m14-waddle', function (G, pp, k) { G.s += pp * .1; G.fr = (Math.floor(pp * 8) + k) & 1; G.up += G.fr; });
  PFA.motion('m14-tremble', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 12 + ph * 4) + k) & 1; });
  PFA.motion('m14-well', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 1.6 + ph) % 1) * 4); });
  PFA.motion('m14-barrelroll', function (G, pp, k) { G.s += pp * .3; G.fr = (Math.floor(pp * 16) + k) & 7; });
  PFA.motion('m14-bloom', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.1 + ph * .4) % 1) * 4)); });
  PFA.motion('m14-bristle', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 3) + k) & 1; });
  PFA.motion('m14-bob', function (G, pp, k, ph) { G.up += Math.sin(pp * 6 + ph * 6) * 2.5; G.t += Math.sin(pp * 3 + k) * 1.5; G.fr = (Math.floor(pp * 10) + k) & 3; });
  PFA.motion('m14-blinkout', function (G, pp, k, ph, H) { var w = Math.floor(pp * 7 + ph * 3); if (H.hash(k * 4.1 + w) < .3) G.vis = 0; G.t += (H.hash(k * 2.3 + w) - .5) * 8; G.fr = (Math.floor(pp * 12) + k) & 3; });
  PFA.motion('m14-flick', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 14 + ph * 4) + k) & 3; G.t += Math.sin(pp * 9 + k) * .6; });
  PFA.motion('m14-swing', function (G, pp, k, ph) { G.t += Math.sin(pp * 5 + ph * 4) * 2; G.fr = (Math.floor(pp * 6) + k) % 3; });
  PFA.motion('m14-waver', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; });
  PFA.motion('m14-motes', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; G.t += Math.sin(pp * 4 + k) * 2; });
  PFA.motion('m14-glowpulse', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 3) + k) % 3; });
  PFA.motion('m14-crumble', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 1; G.t += Math.sin(pp * 6 + k) * 1.5; });
  PFA.motion('m14-puff', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 1.4 + ph) % 1) * 3); });
  PFA.motion('m14-spread', function (G, pp, k) { G.fr = (Math.floor(pp * 4) + k) & 1; });
  PFA.motion('m14-crackle', function (G, pp, k, ph, H) { var w = Math.floor(pp * 20); G.fr = Math.floor(H.hash(k * 1.7 + w) * 4); G.t += (H.hash(k * 3.3 + w) - .5) * 2; });
  PFA.motion('m14-zap', function (G, pp, k) { G.fr = (Math.floor(pp * 16) + k) & 3; });
  PFA.motion('m14-sip', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 1; G.t += Math.sin(pp * 5 + k); });
  PFA.motion('m14-gust', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; G.t += Math.sin(pp * 3) * 1.5; });
  PFA.motion('m14-spit', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 12 + ph * 4) + k) & 3; });

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ---------- */
  function dirGlyph(c, e, H, g, u, off, up, fr) {   /* a glyph at fraction u of the chain path, facing the way it travels */
    var P = e.P, Q = H.Q, sgn = e.d >= 0 ? 1 : -1;
    P.atq(e.a + e.d * u);
    H.glyph(c, g, Q.x + Q.nx * off, Q.y + Q.ny * off - up, e.z, fr, e.col, e.acc, e.hi, -Q.ny * sgn, Q.nx * sgn, Q.nx, Q.ny);
  }
  function carThistle(c, e, H) {         /* a thistle head tumbles along in the wind in small hops, down seeds lifting off behind it and drifting up */
    var P = e.P, Q = H.Q, k, u, w;
    for (k = 0; k < 4; k++) { u = e.hh - .06 - k * .07; if (u < 0) break; P.atq(e.a + e.d * u); w = Math.sin(e.p * 9 + k * 2) * 2;
      H.glyph(c, 'm14-down', Q.x + Q.nx * (7 + k * 2) + w, Q.y + Q.ny * (7 + k * 2) - 2 - k * 3, 0, (Math.floor(e.p * 8) + k) & 1, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny); }
    dirGlyph(c, e, H, 'm14-thistle', e.hh, 6, Math.abs(Math.sin(e.hh * PI * 4)) * 4, Math.floor(e.p * 12) & 3);
  }
  function carNettle(c, e, H) {          /* the hunched lurker creeps low along the edge; three nettle stalks stand on the way and lean aside as it passes */
    var P = e.P, Q = H.Q, k, u, b, j;
    for (k = 1; k <= 3; k++) { u = k / 4; P.atq(e.a + e.d * u); b = Math.abs(e.hh - u) < .12 ? (e.hh < u ? -2 : 2) * (e.d >= 0 ? 1 : -1) : 0;
      for (j = 2; j <= 9; j++) H.px(c, Q.x + Q.nx * j - Q.ny * b * (j / 9), Q.y + Q.ny * j + Q.nx * b * (j / 9), j > 7 ? XC[6] : '#5a9a3e');
      H.px(c, Q.x + Q.nx * 6 - Q.ny * (b * .66 + 1), Q.y + Q.ny * 6 + Q.nx * (b * .66 + 1), XC[24]); }
    dirGlyph(c, e, H, 'm14-lurker', e.hh, 5, 0, (Math.floor(e.p * 10) & 1) | (e.hh > .9 ? 2 : 0));
  }
  function carCactus(c, e, H) {          /* the barrel cactus waddles along on stubby feet, two-dot prints in the sand behind it, a spine dropped at the start */
    var P = e.P, Q = H.Q, k, u;
    P.atq(e.a + e.d * .03); H.ln(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, Q.x + Q.nx * 3 + 4, Q.y + Q.ny * 3 + 1, 1, XC[12]);
    for (k = 1; k <= 6; k++) { u = e.hh - k * .07; if (u < 0) break; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * (3 + (k & 1)) - 1, Q.y + Q.ny * (3 + (k & 1)), XC[17]); H.px(c, Q.x + Q.nx * (3 + (k & 1)) + 1, Q.y + Q.ny * (3 + (k & 1)), XC[17]); }
    dirGlyph(c, e, H, 'm14-barrel', e.hh, 7, (Math.floor(e.p * 14) & 1), Math.floor(e.p * 14) & 1);
  }
  function carWillo(c, e, H) {           /* the marsh light bobs on ahead; a line of muddy footprints follows it and sinks back into the bog */
    var P = e.P, Q = H.Q, k, u, f, X, Y;
    for (k = 1; k <= 6; k++) { u = e.hh - .05 - k * .07; if (u < 0) break; f = k / 6; if (H.hash(k * 3.7) < f * .6) continue; P.atq(e.a + e.d * u);
      X = Q.x + Q.nx * (3 + (k & 1) * 2); Y = Q.y + Q.ny * (3 + (k & 1) * 2); H.bx(c, X - 1, Y, 2, 1, XC[18]); if (f < .6) { H.px(c, X - 1, Y - 1, XC[18]); H.px(c, X + 1, Y - 1, e.hi); } }
    dirGlyph(c, e, H, 'm14-lure', Math.min(1, e.hh + .02), 7, Math.sin(e.p * 14) * 2.5, (Math.floor(e.p * 12) & 3));
  }
  function carFoxfire(c, e, H) {         /* glowing mycelium creeps along the ground from piece to piece, short side branches lighting up, a cap clump at the growing tip */
    var P = e.P, Q = H.Q, u, k = 0, on;
    for (u = 0; u < e.hh; u += .03) { P.atq(e.a + e.d * u); k++; on = ((k + Math.floor(e.p * 10)) % 4) !== 0;
      H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, on ? e.col : XC[23]);
      if (k % 5 === 0) { H.px(c, Q.x + Q.nx * 4 - Q.ny, Q.y + Q.ny * 4 + Q.nx, e.col); H.px(c, Q.x + Q.nx * 5 - Q.ny * 2, Q.y + Q.ny * 5 + Q.nx * 2, on ? e.hi : e.col); } }
    dirGlyph(c, e, H, 'm14-caps', e.hh, 5, 0, Math.floor(e.p * 9) % 3);
  }
  function carStorm(c, e, H) {           /* ball lightning drifts along; every few frames a jagged bolt flickers from it back to where it started */
    var P = e.P, Q = H.Q, k, N = 6, w = Math.floor(e.p * 14), X0, Y0, X, Y, o;
    if (w % 3 !== 2 && e.hh > .05) { P.atq(e.a); X0 = Q.x + Q.nx * 4; Y0 = Q.y + Q.ny * 4;
      for (k = 1; k <= N; k++) { P.atq(e.a + e.d * e.hh * k / N); o = k === N ? 6 : 3 + (H.hash(k * 2.9 + w) - .5) * 8; X = Q.x + Q.nx * o; Y = Q.y + Q.ny * o; H.ln(c, X0, Y0, X, Y, 1, (k & 1) ? H.WHITE : e.col); X0 = X; Y0 = Y; } }
    dirGlyph(c, e, H, 'm14-ball', e.hh, 6, Math.sin(e.p * 10) * 1.5, w & 3);
  }

  /* ---------- motifs ---------- */
  function M(name, draw, meta) { PFA.motif(name, draw, meta); }
  function down(c, e, H) { comp(c, e, H, decoDown); }
  function hair(c, e, H) { comp(c, e, H, decoHair); }
  function sand(c, e, H) { comp(c, e, H, decoSand); }
  function bog(c, e, H) { comp(c, e, H, decoBog); }
  function glow(c, e, H) { comp(c, e, H, decoGlow); }
  function rain(c, e, H) { comp(c, e, H, decoRain); }
  /* thistle beast */
  M('thistle-head', down, { nm: 'thistle heads', desc: 'thistle heads: spiny green bulbs with a swaying purple brush, down seeds lifting off; the chain is a thistle head tumbling in the wind shedding down', fam: 'thorn', gap: 14, g: 'm14-thistle', mo: 'm14-nod', x: '-', car: 'custom', carDraw: carThistle });
  M('thistle-down', down, { nm: 'thistle down', desc: 'thistle-down seeds: a dark seed under a white parachute of hairs, drifting and opening', fam: 'puff', gap: 10, g: 'm14-down', mo: 'm14-drift', x: '-', car: 'flutter' });
  M('thistle-needle', plain, { nm: 'spine darts', desc: 'spiny leaf darts with purple shafts and green side spikes, white point first', fam: 'drip', gap: 9, g: 'm14-needle', mo: 'm14-darts', x: '-', car: 'comet' });
  M('thistle-sprout', plain, { nm: 'deep roots', desc: 'forked tan roots digging down under a soil line while a green shoot pushes up and opens a purple bud', fam: 'mend', gap: 14, g: 'm14-sprout', mo: 'm14-grow', x: '-', car: 'tunnel' });
  M('thistle-heap', down, { nm: 'spine heaps', desc: 'a mound of crossed spiny thistle leaves with purple heads on top, the spine tips bristling', fam: 'thorn', gap: 16, g: 'm14-heap', mo: 'm14-pile', x: '-', car: 'train' });
  M('thistle-whip', plain, { nm: 'prickly whips', desc: 'a spiny thistle stem lashing in an arc with a purple head on the tip', fam: 'slash', gap: 14, g: 'm14-whip', mo: 'm14-lash', x: '-', car: 'comet' });
  /* nettle lurker */
  M('nettle-lurk', hair, { nm: 'nettle lurkers', desc: 'a hunched green lurker with nettle stalks on its back and yellow eyes low at the front; the chain creeps low past three stalks that lean aside', fam: 'thorn', gap: 16, g: 'm14-lurker', mo: 'm14-creep', x: '-', car: 'custom', carDraw: carNettle });
  M('nettle-hairs', hair, { nm: 'sting curtains', desc: 'a serrated leaf strip with a fringe of fine stinging hairs hanging off it, glinting tips swaying', fam: 'web', gap: 12, g: 'm14-hairs', mo: 'm14-hang', x: '-', car: 'thread' });
  M('nettle-stem', plain, { nm: 'nettle stems', desc: 'square nettle stems with paired serrated leaves at the nodes and hairs on the stem, rustling', fam: 'leaf', gap: 10, g: 'm14-stem', mo: 'm14-rustle', x: '-', car: 'train' });
  M('nettle-noose', plain, { nm: 'stem nooses', desc: 'a nettle stem bent into a loop that pulls tight, leaves on the loop, hairs glinting', fam: 'web', gap: 14, g: 'm14-noose', mo: 'm14-cinch', x: '-', car: 'thread' });
  M('nettle-welt', plain, { nm: 'nettle welts', desc: 'a serrated nettle leaf brushing past and white welts on red rings popping up behind it', fam: 'thorn', gap: 14, g: 'm14-welt', mo: 'm14-welt', x: '-', car: 'zig' });
  M('nettle-stench', plain, { nm: 'cut-stalk stench', desc: 'a cut nettle stalk with a pale wound, two wavy yellow-green stink lines curling up out of it', fam: 'puff', gap: 14, g: 'm14-stench', mo: 'm14-stink', x: '-', car: 'cloud' });
  M('nettle-eyes', plain, { nm: 'stalk shadows', desc: 'a pocket of shadow between two nettle stalks with a pair of yellow eyes in it, blinking', fam: 'mend', gap: 16, g: 'm14-eyes', mo: 'm14-peer', x: '-', car: 'blink' });
  /* cactus beast */
  M('cactus-walk', sand, { nm: 'walking barrels', desc: 'round ribbed barrel cacti with cream spines and a pink flower crown, waddling on stubby feet; the chain waddles along leaving two-dot prints in the sand', fam: 'bash', gap: 16, g: 'm14-barrel', mo: 'm14-waddle', x: '-', car: 'custom', carDraw: carCactus });
  M('cactus-spine', plain, { nm: 'cactus spines', desc: 'long cream cactus spines with a gold point jutting out of green areoles, trembling', fam: 'thrust', gap: 9, g: 'm14-cspine', mo: 'm14-tremble', x: '-', car: 'comet' });
  M('cactus-water', sand, { nm: 'stored water', desc: 'a cut wedge of cactus with pale wet flesh, a blue water drop welling up out of it', fam: 'mend', gap: 14, g: 'm14-water', mo: 'm14-well', x: '-', car: 'trail' });
  M('cactus-roll', sand, { nm: 'rolling barrels', desc: 'a barrel cactus on its side, ribs, spines and pink crown turning round as it rolls', fam: 'bash', gap: 16, g: 'm14-roll', mo: 'm14-barrelroll', x: 'dust', car: 'roll' });
  M('cactus-bloom', plain, { nm: 'pink crowns', desc: 'a pink crown flower opening on a green knob, gold pollen puffing out when it is fully open', fam: 'leaf', gap: 12, g: 'm14-bloom', mo: 'm14-bloom', x: 'pollen', car: 'cloud' });
  M('cactus-hide', sand, { nm: 'buried barrels', desc: 'a barrel cactus sunk into the sand to its middle, only the ribbed top and its spines showing, the spines bristling', fam: 'shield', gap: 16, g: 'm14-buried', mo: 'm14-bristle', x: '-', car: 'train' });
  /* will-o'-wisp */
  M('willo-lure', bog, { nm: 'marsh lights', desc: 'pale cold teardrop flames with a white core bobbing over the bog, the tail curling like a beckoning finger; the chain bobs ahead of a line of footprints that sink into the mud', fam: 'sparkle', gap: 14, g: 'm14-lure', mo: 'm14-bob', x: '-', car: 'custom', carDraw: carWillo });
  M('willo-flicker', bog, { nm: 'flickering lights', desc: 'marsh lights that wink out and come back a little to the side, never where you look', fam: 'sparkle', gap: 14, g: 'm14-lure', mo: 'm14-blinkout', x: '-', car: 'blink' });
  M('willo-flame', plain, { nm: 'cold flames', desc: 'three tongues of pale cold flame licking up over a dark scorch, white tips flickering', fam: 'ember', gap: 12, g: 'm14-flame', mo: 'm14-flick', x: 'embers', car: 'comet' });
  M('willo-lantern', bog, { nm: 'bog lanterns', desc: 'little dark-framed lanterns with a cold light inside, swinging, a glow ring pulsing out', fam: 'mend', gap: 16, g: 'm14-lantern', mo: 'm14-swing', x: '-', car: 'rings' });
  M('willo-tendril', plain, { nm: 'ghostlight tendrils', desc: 'wavering half see-through filaments of pale light reaching out of the edge and curling at the tip', fam: 'slash', gap: 12, g: 'm14-tendril', mo: 'm14-waver', x: '-', car: 'trail' });
  M('willo-spores', bog, { nm: 'lantern spores', desc: 'clusters of three glowing spores circling each other, little halos winking', fam: 'leaf', gap: 12, g: 'm14-spores', mo: 'm14-motes', x: '-', car: 'cloud' });
  /* foxfire wisp */
  M('foxfire-stump', glow, { nm: 'foxfire stumps', desc: 'rotten stumps with jagged tops, green foxfire patches pulsing on the wood in turn; the chain is glowing mycelium creeping along the ground with a cap clump at its tip', fam: 'sparkle', gap: 16, g: 'm14-stump', mo: 'm14-glowpulse', x: '-', car: 'custom', carDraw: carFoxfire });
  M('foxfire-punk', glow, { nm: 'punkwood crumbs', desc: 'crumbs of soft rotten punkwood with glowing green rims, tumbling', fam: 'drip', gap: 10, g: 'm14-punk', mo: 'm14-crumble', x: '-', car: 'roll' });
  M('foxfire-caps', glow, { nm: 'glow caps', desc: 'clumps of three glowing mushroom caps on pale stems, the gills lighting up one cap at a time', fam: 'shield', gap: 16, g: 'm14-caps', mo: 'm14-glowpulse', x: '-', car: 'train' });
  M('foxfire-spores', plain, { nm: 'glow spore puffs', desc: 'puffs of glowing spores swelling open, curling a beckoning wisp when fully open', fam: 'puff', gap: 14, g: 'm14-sporepuff', mo: 'm14-puff', x: 'haze', car: 'cloud' });
  M('foxfire-mycel', glow, { nm: 'glowing mycelium', desc: 'glowing mycelium knots: forked threads spreading from a bright node', fam: 'web', gap: 14, g: 'm14-hypha', mo: 'm14-spread', x: '-', car: 'thread' });
  /* storm wisp */
  M('stormwisp-ball', rain, { nm: 'ball lightning', desc: 'blue-white balls of lightning with a white core and crackling zig tendrils, drifting; the chain drifts along with a jagged bolt flickering back to the start', fam: 'shock', gap: 16, g: 'm14-ball', mo: 'm14-crackle', x: '-', car: 'custom', carDraw: carStorm });
  M('stormwisp-bolt', plain, { nm: 'forked bolts', desc: 'forked zigzag bolts with a white core striking outward, the jags shifting each frame', fam: 'shock', gap: 12, g: 'm14-bolt', mo: 'm14-zap', x: '-', car: 'zig' });
  M('stormwisp-rain', rain, { nm: 'sipped rain', desc: 'raindrops drawn upward with a streak trailing below them, a white glint', fam: 'mend', gap: 10, g: 'm14-rain', mo: 'm14-sip', x: '-', car: 'trail' });
  M('stormwisp-squall', rain, { nm: 'squall curtains', desc: 'a small grey-blue cloud with a slanting curtain of rain streaks driven under it', fam: 'shield', gap: 14, g: 'm14-squall', mo: 'm14-gust', x: '-', car: 'train' });
  M('stormwisp-spark', plain, { nm: 'shed sparks', desc: 'crackling sparks that change shape every frame: plus, cross, jag, wink', fam: 'sparkle', gap: 9, g: 'm14-spark', mo: 'm14-spit', x: '-', car: 'blink' });
})();
