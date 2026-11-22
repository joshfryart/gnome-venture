/* Motif module, medium batch m11 (tanuki, coati-band, macaque-troop, capuchin-pickpocket, wildcat, caracal, fishing-cat, jaguarundi, jaguar-cub-pair,
   bear-cub-tumble, sun-bear). TEMPLATE.md section 10.3.
   46 motifs, each with its own pixel glyph (ids prefixed m11-) and its own motion. Every creature of the batch has its own signature motif, and every
   signature brings its own chain effect (carDraw): a tanuki that poofs into a leaf and pops out at the next piece, a coati band marching tails-up,
   a macaque troop bounding on all fours, a capuchin running off with a stolen button, a wildcat stalking low with its tail lashing, a caracal leaping
   in a high arc into a burst of feathers, a fishing cat wading with ripple rings, a jaguarundi slipping along like an otter, two jaguar cubs chasing
   each other, a bear cub rolling downhill over bumps, a sun bear's long tongue unrolling along the edge.
   Shared inside the batch: cat-claw (wildcat, caracal; own palettes) and honey-paw (bear cub, sun bear). Cats are drawn by one side-view routine (cat)
   with a coat option each (tabby stripes, black ear tufts, spots + webbed feet, long low plain body, rosettes + big paws), monkeys by one front-face
   routine (ape), so relatives share a build but each keeps its own picture.
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation in the frame loops (scratch H.Q / H.G only).
   Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy
   default are untouched. */
(function () {
  /* fixed accent colours (not palette tones): 4 white, 5 dew, 6 dark soil, 7 soil, 8 leaf green, 9 dark leaf, 10 bark, 11 moss, 12 honey amber,
     13 eye black, 14 pink, 15 tongue red, 16 sand, 17 steam, 18 mud, 19 fruit orange, 20 fruit red, 21 button gold, 22 sun orange, 23 straw,
     24 water blue, 25 fish silver, 26 feather grey, 27 lace white, 28 snow, 29 termite, 30 stump wood */
  var XC = [null, null, null, null, '#ffffff', '#cfeeff', '#4a3220', '#8a6a44', '#62b040', '#2e6a24', '#6a4a2e', '#7aa048', '#f0a830', '#141418', '#f0a0a8',
    '#e05060', '#e8d8a8', '#e8eef2', '#6a5236', '#f08a2a', '#d8384a', '#f2c83a', '#ff9a3a', '#d8c070', '#5aa8d8', '#c8d8e4', '#d8d4cc', '#f4f0e8', '#f8fbff',
    '#c89a60', '#b88a58'];

  function face(tx, nx, ny) { return Math.abs(nx) > Math.abs(ny) ? (nx > 0 ? 1 : -1) : (tx >= 0 ? 1 : -1); }

  /* side-view cat facing fl, fr 0..3 gait. o: 0 wildcat (tabby stripes, thick ringed tail, black tip), 1 caracal (plain tawny, long black ear tufts, short tail),
     2 fishing cat (stocky, spots, short thick tail, webbed feet in Hi), 3 jaguarundi (long low plain body, small round ears, long tail along the ground),
     4 jaguar cub (round, rosettes, big paws, stubby tail) */
  function cat(c, K, x, y, fl, fr, C, A, Hi, o) {
    var i, X, st = fr & 3, fw = st === 0 ? 1 : st === 2 ? -1 : 0, lo = o === 3 ? 1 : 0, L = o === 3 ? 5 : o === 4 ? 2 : 3, hx, hy, ly;
    for (i = -L; i <= 3; i++) { X = x + fl * i; K.px(c, X, y - 1 + lo, C); K.px(c, X, y + lo, C);
      if (o === 0 && (i & 1)) K.px(c, X, y - 1, A);
      if (o === 2 && (i + 9) % 3 === 0) { K.px(c, X, y, A); K.px(c, X + fl, y - 1, A); }
      if (o === 4 && (i + 9) % 2 === 0) K.px(c, X, y - 1, A);
      if (o !== 3 && o !== 1 && i > -L && i < 3) K.px(c, X, y - 2, i === 0 && o === 4 ? A : C); }
    hx = x + fl * 4; hy = y - 2 + lo;
    K.px(c, hx, hy, C); K.px(c, hx + fl, hy, C); K.px(c, hx, hy + 1, C); K.px(c, hx + fl, hy + 1, C); K.px(c, hx + fl * 2, hy + 1, o === 3 ? C : Hi);
    K.px(c, hx + fl, hy, XC[13]); K.px(c, hx - fl, hy, C);
    if (o === 1) { K.px(c, hx, hy - 1, C); K.px(c, hx, hy - 2, A); K.px(c, hx - fl, hy - 3, A); K.px(c, hx + fl, hy - 1, C); K.px(c, hx + fl, hy - 2, A); K.px(c, hx + fl, hy - 3, A); }
    else if (o === 3) { K.px(c, hx, hy - 1, C); }
    else { K.px(c, hx - fl, hy - 1, C); K.px(c, hx + fl, hy - 1, C); if (o === 0) K.px(c, hx, hy - 1, A); }
    ly = y + 1 + lo;
    K.px(c, x + fl * (2 + fw), ly, C); K.px(c, x - fl * (L - 1 - fw), ly, C);
    if (!lo) { K.px(c, x + fl * (2 + fw * 1.5), ly + 1, o === 2 ? Hi : A); K.px(c, x - fl * (L - 1 - fw * 1.5), ly + 1, o === 2 ? Hi : A); }
    if (o === 4) { K.px(c, x + fl * (3 + fw), ly + 1, C); K.px(c, x + fl * (2 + fw), ly + 1, C); K.px(c, x - fl * (L - 2 - fw), ly + 1, C); }
    X = x - fl * (L + 1);
    if (o === 0) { for (i = 0; i < 5; i++) { K.px(c, X - fl * (i >> 1), y - 1 - i + (st & 1) * (i >> 2), i === 4 ? A : (i & 1) ? A : C); K.px(c, X - fl * (i >> 1) - fl, y - 1 - i + (st & 1) * (i >> 2), i === 4 ? A : C); } }
    else if (o === 1) { K.px(c, X, y - 1, C); K.px(c, X - fl, y, C); K.px(c, X - fl, y + 1, A); }
    else if (o === 2) { K.px(c, X, y - 1, C); K.px(c, X - fl, y, C); K.px(c, X - fl, y - 1, A); }
    else if (o === 3) { for (i = 0; i < 5; i++) K.px(c, X - fl * i, y + lo - (i === 4 ? (st & 1) : 0), C); }
    else { K.px(c, X, y - 1, C); K.px(c, X - fl, y - 2, A); }
  }
  /* monkey face, front view: fur ring C, face F, dark A. cap = dark cap on top (capuchin). m 0 calm, 1 open mouth (teeth), 2 brows up */
  function ape(c, K, x, y, C, A, F, cap, m) {
    K.bx(c, x - 3, y - 3, 7, 7, C); K.px(c, x - 3, y - 3, A); K.px(c, x + 3, y - 3, A);
    K.px(c, x - 4, y - 1, F); K.px(c, x + 4, y - 1, F);
    K.bx(c, x - 2, y - 2, 5, 4, F); K.bx(c, x - 1, y + 2, 3, 1, F);
    if (cap) { K.bx(c, x - 2, y - 4, 5, 2, A); K.px(c, x, y - 2, A); }
    K.px(c, x - 1, y - 1 - (m === 2 ? 1 : 0), XC[13]); K.px(c, x + 1, y - 1 - (m === 2 ? 1 : 0), XC[13]);
    if (m === 2) { K.px(c, x - 2, y - 3, A); K.px(c, x + 2, y - 3, A); }
    K.px(c, x, y, A);
    if (m === 1) { K.bx(c, x - 1, y + 1, 3, 2, XC[13]); K.px(c, x - 1, y + 1, K.WHITE); K.px(c, x + 1, y + 1, K.WHITE); }
    else K.px(c, x, y + 2, A);
  }
  /* tanuki face, front view: round brown head, dark mask band over the eyes, pale cheeks, little round ears, a green leaf on top (leaf 1) */
  function tanu(c, K, x, y, C, A, Hi, leaf, m) {
    K.bx(c, x - 3, y - 2, 7, 5, C); K.bx(c, x - 2, y - 3, 5, 1, C); K.px(c, x - 3, y - 3, A); K.px(c, x + 3, y - 3, A);
    K.bx(c, x - 3, y - 1, 3, 2, A); K.bx(c, x + 1, y - 1, 3, 2, A); K.px(c, x - 2, y - 1, m === 2 ? A : K.WHITE); K.px(c, x + 2, y - 1, m === 2 ? A : K.WHITE);
    K.px(c, x - 1, y + 1, XC[16]); K.px(c, x + 1, y + 1, XC[16]); K.px(c, x, y + 1, A); K.bx(c, x - 1, y + 3, 3, 1, C);
    if (m === 1) { K.px(c, x - 5, y, XC[16]); K.px(c, x - 5, y + 2, XC[16]); K.px(c, x + 5, y, XC[16]); K.px(c, x + 5, y + 2, XC[16]); }
    if (leaf) { K.px(c, x, y - 4, Hi); K.px(c, x + 1, y - 5, Hi); K.px(c, x - 1, y - 5, Hi); K.px(c, x, y - 5, XC[9]); K.px(c, x, y - 6, Hi); K.px(c, x + 1, y - 4, XC[9]); }
  }
  /* bear head, front view: round ears, muzzle M, dark nose; crescent = gold chest crescent below (sun bear) */
  function bear(c, K, x, y, C, A, M, crescent) {
    K.bx(c, x - 3, y - 2, 7, 5, C); K.bx(c, x - 2, y - 3, 5, 1, C); K.px(c, x - 3, y - 4, C); K.px(c, x + 3, y - 4, C); K.px(c, x - 3, y - 3, C); K.px(c, x + 3, y - 3, C);
    K.bx(c, x - 1, y, 3, 2, M); K.px(c, x, y, XC[13]); K.px(c, x - 2, y - 1, XC[13]); K.px(c, x + 2, y - 1, XC[13]);
    if (crescent) { K.px(c, x - 3, y + 3, M); K.px(c, x - 2, y + 4, M); K.bx(c, x - 1, y + 5, 3, 1, M); K.px(c, x + 2, y + 4, M); K.px(c, x + 3, y + 3, M); }
  }
  /* a fern frond leaning (lean -1..1) */
  function fern(c, K, x, y, lean, G1, G2) {
    var i, X, Y;
    for (i = 0; i < 7; i++) { X = x + Math.round(lean * i * .4); Y = y - i; K.px(c, X, Y, G2); if (i > 0 && i < 6) { K.px(c, X - 1, Y + (i & 1), G1); K.px(c, X + 1, Y + (i & 1), G1); if (i < 4) { K.px(c, X - 2, Y + 1, G1); K.px(c, X + 2, Y + 1, G1); } } }
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
  function decoWet(c, e, H, s0, len, ri, pp) {           /* wetland: two waterline dashes rock under the run */
    var k, u, Q = H.Q, i, X, Y; if (e.p > .92) return;
    for (k = 0; k < 2; k++) { u = (pp * 1.1 + k * .5) % 1; e.P.atq(s0 + len * (k + .5) / 2); X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3 + 5 + Math.round(Math.sin(u * 6.28));
      for (i = -2; i <= 2; i++) if ((i + k) & 1) H.px(c, X + i, Y, i === 1 ? H.WHITE : XC[24]); }
  }
  function decoLeaf(c, e, H, s0, len, ri, pp) {          /* rainforest canopy: two leaves see-saw down past the run */
    var k, u, Q = H.Q, X, Y, sw; if (e.p > .9) return;
    for (k = 0; k < 2; k++) { u = (pp * .9 + k * .5 + H.hash(e.seed + ri) * .3) % 1; e.P.atq(s0 + len * (.25 + k * .5)); sw = Math.sin(u * 12) * 3;
      X = Q.x + Q.nx * (6 + u * 6) + sw; Y = Q.y + Q.ny * (6 + u * 6) + u * 8 - 6; H.px(c, X, Y, XC[8]); H.px(c, X + (sw > 0 ? 1 : -1), Y, XC[9]); }
  }
  function decoGrass(c, e, H, s0, len, ri, pp) {         /* grassland: a fringe of straw blades along the run, swaying */
    var s, Q = H.Q, w, i = 0; if (e.p > .92) return;
    for (s = 2; s < len; s += 5) { e.P.atq(s0 + s); w = Math.round(Math.sin(pp * 5 + s * .4)); i++;
      H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, XC[23]); H.px(c, Q.x + Q.nx * 3 - Q.ny * w, Q.y + Q.ny * 3 + Q.nx * w, i & 1 ? XC[23] : XC[11]); }
  }
  function decoSteam(c, e, H, s0, len, ri, pp) {         /* hot spring: steam curls drift up off the run */
    var k, u, Q = H.Q; if (e.p > .92) return;
    for (k = 0; k < 3; k++) { u = (pp * .8 + k * .33) % 1; e.P.atq(s0 + len * (k + .5) / 3);
      H.px(c, Q.x + Q.nx * 6 + Math.sin(u * 9 + k) * 2, Q.y + Q.ny * 6 - u * 12, u < .6 ? XC[17] : XC[26]); }
  }

  /* ---------- glyphs (tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step; fr from the motion) ---------- */
  /* tanuki */
  PFA.glyph('m11-tanuki', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* round masked tanuki face with a leaf on its head; fr 1 whiskers out and a paw up, fr 2 blink */
    tanu(c, K, x, y, C, A, Hi, 1, fr);
    if (fr === 1) { K.px(c, x + 4, y + 3, C); K.px(c, x + 5, y + 2, C); K.px(c, x + 6, y + 1, K.WHITE); K.px(c, x + 6, y + 3, K.WHITE); }
  });
  PFA.glyph('m11-drum', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the round pale belly drummed by two dark paws; on the beat (fr 1) a ring and beat ticks pop out */
    var r = 3 + (z > 1 ? 1 : 0);
    K.sq(c, x, y, r * 2 + 1, C); K.sq(c, x, y, r * 2 - 1, XC[16]); K.px(c, x, y, C);
    K.px(c, x - r - 1, y - (fr ? 2 : 0), A); K.px(c, x - r - 2, y - (fr ? 2 : 1), A); K.px(c, x + r + 1, y - (fr ? 0 : 2), A); K.px(c, x + r + 2, y - (fr ? 1 : 2), A);
    if (fr) { K.ringpx(c, x, y, r + 3, Hi); K.px(c, x - r - 4, y - r - 2, K.WHITE); K.px(c, x + r + 4, y - r - 2, K.WHITE); }
  });
  PFA.glyph('m11-leafpoof', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* leaf disguise: fr 0 a leaf, 1 the leaf vanishes in a white poof, 2 the tanuki's masked face peeks out of the cloud */
    var i, a;
    if (fr === 0) { for (i = -3; i <= 3; i++) { K.px(c, x + i, y - (3 - Math.abs(i)) * .5, Hi); K.px(c, x + i, y + (3 - Math.abs(i)) * .5, Hi); K.px(c, x + i, y, XC[9]); } K.px(c, x + 4, y + 1, XC[9]); return; }
    for (i = 0; i < 8; i++) { a = i * .785 + fr * .4; K.sq(c, x + Math.cos(a) * 4, y + Math.sin(a) * 3, 3, i & 1 ? XC[17] : K.WHITE); }
    if (fr === 2) { K.bx(c, x - 2, y - 1, 5, 2, A); K.px(c, x - 1, y - 1, K.WHITE); K.px(c, x + 1, y - 1, K.WHITE); K.px(c, x, y + 1, C); K.px(c, x, y - 5, Hi); }
    else { K.px(c, x, y, Hi); K.px(c, x + 1, y - 1, Hi); }
  });
  PFA.glyph('m11-tanukiball', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* the round tanuki rolled into a furry ball, the dark mask band turning round with it (fr 0..3) */
    var a = fr * 1.571, r = 3 + (z > 0 ? 1 : 0), i, X, Y;
    K.sq(c, x, y, r * 2 + 1, C); K.px(c, x - r, y - r, A); K.px(c, x + r, y + r, A);
    for (i = -2; i <= 2; i++) { X = x + Math.cos(a) * i - Math.sin(a) * 1; Y = y + Math.sin(a) * i + Math.cos(a) * 1; K.px(c, X, Y, A); }
    K.px(c, x + Math.cos(a) * 1.5, y + Math.sin(a) * 1.5, K.WHITE); K.px(c, x + Math.cos(a + 2.4) * (r + 1), y + Math.sin(a + 2.4) * (r + 1), Hi);
    K.px(c, x - Math.cos(a) * (r + 1), y - Math.sin(a) * (r + 1), A);
  });
  PFA.glyph('m11-stump', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* stump pose: a cut tree stump with rings and a leaf on top, the tanuki's striped tail peeking out; fr 1 two eyes blink open in the bark */
    K.bx(c, x - 3, y - 2, 7, 6, XC[30]); K.bx(c, x - 3, y - 3, 7, 1, XC[16]); K.px(c, x, y - 3, XC[10]); K.px(c, x - 2, y - 3, XC[29]); K.px(c, x + 2, y - 3, XC[29]);
    K.px(c, x - 3, y + 4, XC[10]); K.px(c, x - 4, y + 4, XC[10]); K.px(c, x + 3, y + 4, XC[10]); K.px(c, x + 4, y + 4, XC[10]); K.px(c, x - 1, y + 1, XC[10]); K.px(c, x + 1, y, XC[10]);
    K.px(c, x + 1, y - 4, Hi); K.px(c, x + 2, y - 5, Hi); K.px(c, x + 1, y - 5, XC[9]);
    K.px(c, x + 4, y + 2, C); K.px(c, x + 5, y + 1, A); K.px(c, x + 5, y, C); K.px(c, x + 6, y - 1, A);
    if (fr) { K.px(c, x - 2, y, K.WHITE); K.px(c, x + 1, y - 1 + 1, K.WHITE); K.px(c, x - 2, y + 1, XC[13]); }
  });
  /* coati */
  PFA.glyph('m11-coati', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* side-view coati: long upturned snout, the ringed tail held straight up like a flag, swaying (chain body) */
    var fl = face(tx, nx, ny), i, X, w = (fr & 1) ? 1 : 0;
    for (i = -3; i <= 2; i++) { X = x + fl * i; K.px(c, X, y - 1, C); K.px(c, X, y, C); if (i > -3 && i < 2) K.px(c, X, y - 2, C); }
    K.px(c, x + fl * 3, y - 1, C); K.px(c, x + fl * 4, y - 1, C); K.px(c, x + fl * 5, y - 2, Hi); K.px(c, x + fl * 6, y - 3, A); K.px(c, x + fl * 3, y - 2, XC[13]); K.px(c, x + fl * 2, y - 3, C);
    K.px(c, x + fl * (1 + w), y + 1, A); K.px(c, x - fl * (2 - w), y + 1, A);
    for (i = 0; i < 7; i++) K.px(c, x - fl * (4 - (i > 3 ? (fr & 2 ? 1 : -1) * (i - 3) * .4 : 0)), y - 1 - i, (i & 1) ? Hi : A);
  });
  PFA.glyph('m11-tailflag', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* one upright ringed coati tail sticking out of the edge like a flag, the tip curling (fr) */
    var i, L = 7 + z, X, Y, b;
    for (i = 0; i < L; i++) { b = i > L - 3 ? (fr & 1 ? 1 : -1) * (i - L + 3) : 0; X = x + nx * (i - 3) + tx * b; Y = y + ny * (i - 3) + ty * b;
      K.px(c, X, Y, (i & 1) ? Hi : A); K.px(c, X + tx, Y + ty, (i & 1) ? Hi : C); }
  });
  PFA.glyph('m11-ringscreen', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* ringtail screen: three ringed tails crossed into a picket, bands pulsing */
    var j, i, X, Y, o = fr & 1;
    for (j = -1; j <= 1; j++) for (i = 0; i < 6 + z; i++) { X = x + tx * (j * 3 + (i > 4 ? j : 0)) + nx * (i - 2); Y = y + ty * (j * 3 + (i > 4 ? j : 0)) + ny * (i - 2);
      K.px(c, X, Y, ((i + o + j) & 1) ? Hi : A); }
    K.px(c, x + tx * -4, y + ty * -4, C); K.px(c, x + tx * 4, y + ty * 4, C);
  });
  PFA.glyph('m11-log', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* log cover: a mossy fallen log, long coati snouts poking out from under it in turn (fr 0..2) */
    K.bx(c, x - 5, y - 2, 11, 4, XC[10]); K.bx(c, x - 5, y - 3, 11, 1, XC[11]); K.px(c, x - 2, y - 4, XC[11]); K.px(c, x + 3, y - 4, XC[8]);
    K.ringpx(c, x + 5, y, 2, XC[30]); K.px(c, x + 5, y, XC[16]); K.px(c, x - 3, y, XC[6]); K.px(c, x + 1, y - 1, XC[6]);
    if (fr === 1) { K.px(c, x - 4, y + 3, C); K.px(c, x - 5, y + 3, C); K.px(c, x - 6, y + 4, Hi); K.px(c, x - 4, y + 2, XC[13]); }
    if (fr === 2) { K.px(c, x + 2, y + 3, C); K.px(c, x + 3, y + 3, C); K.px(c, x + 4, y + 4, Hi); K.px(c, x + 2, y + 2, XC[13]); }
  });
  PFA.glyph('m11-snout', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a long upturned coati snout probing outward, the tip twitching (fr), soil crumbs flicked */
    var i, L = 5 + z, w = fr & 1 ? 1 : -1;
    K.sq(c, x - nx * 2, y - ny * 2, 3, C); K.px(c, x - nx * 2 + tx, y - ny * 2 + ty, XC[13]);
    for (i = 0; i < L; i++) K.px(c, x + nx * i + tx * (i > L - 3 ? w : 0), y + ny * i + ty * (i > L - 3 ? w : 0), i < 2 ? C : Hi);
    K.px(c, x + nx * L + tx * w, y + ny * L + ty * w, A);
    if (fr & 2) { K.px(c, x + nx * (L - 1) + tx * 3, y + ny * (L - 1) + ty * 3, XC[7]); K.px(c, x + nx * (L - 2) - tx * 3, y + ny * (L - 2) - ty * 3, XC[6]); }
  });
  /* macaque */
  PFA.glyph('m11-macaque', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a macaque face: pink face in a grey-brown fur ring; fr 1 open-mouth threat, fr 2 brows up */
    ape(c, K, x, y, C, A, Hi, 0, fr);
  });
  PFA.glyph('m11-macaquerun', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* chain body: a macaque bounding on all fours, pink face forward, short tail up */
    var fl = face(tx, nx, ny), i, X, b = fr & 1;
    for (i = -3; i <= 2; i++) { X = x + fl * i; K.px(c, X, y - 1 - (i < -1 ? b : 0), C); K.px(c, X, y, C); }
    K.px(c, x + fl * 3, y - 2, C); K.px(c, x + fl * 4, y - 2, C); K.px(c, x + fl * 3, y - 1, Hi); K.px(c, x + fl * 4, y - 1, Hi); K.px(c, x + fl * 4, y - 2, XC[13]); K.px(c, x + fl * 3, y - 3, C);
    K.px(c, x + fl * (2 + b), y + 1, C); K.px(c, x + fl * (2 + b), y + 2, A); K.px(c, x - fl * (2 + b), y + 1, C); K.px(c, x - fl * (2 + b), y + 2, A);
    K.px(c, x - fl * 4, y - 2 - b, C); K.px(c, x - fl * 3, y + 1 - b, Hi);
  });
  PFA.glyph('m11-cheeks', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* cheek pouches: the face with bulging cheeks (fr 0..1), fr 2 the cheeks dump out seeds and fruit scraps */
    ape(c, K, x, y, C, A, Hi, 0, 0);
    if (fr < 2) { K.bx(c, x - 5, y, 2, 2 + fr, C); K.bx(c, x + 4, y, 2, 2 + fr, C); K.px(c, x - 5, y + 1, Hi); K.px(c, x + 5, y + 1, Hi); }
    else { K.px(c, x + nx * 5 - 1, y + ny * 5 + 3, XC[19]); K.px(c, x + nx * 6 + 1, y + ny * 6 + 4, XC[20]); K.px(c, x + nx * 4 + 2, y + ny * 4 + 4, XC[8]); K.px(c, x + nx * 7, y + ny * 7 + 2, XC[29]);
      K.bx(c, x - 1, y + 1, 3, 2, XC[13]); }
  });
  PFA.glyph('m11-onsen', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* hot-spring huddle: two macaque heads in steaming water, snow on their crowns, steam curls rising (fr) */
    var i;
    K.bx(c, x - 6, y + 2, 13, 2, XC[24]); K.px(c, x - 4, y + 2, XC[5]); K.px(c, x + 3, y + 2, XC[5]);
    K.bx(c, x - 5, y - 2, 4, 4, C); K.bx(c, x - 4, y - 1, 2, 2, Hi); K.bx(c, x - 5, y - 3, 4, 1, XC[28]);
    K.bx(c, x + 1, y - 1, 4, 3, C); K.bx(c, x + 2, y, 2, 2, Hi); K.bx(c, x + 1, y - 2, 4, 1, XC[28]); K.px(c, x - 4, y - 1, XC[13]); K.px(c, x + 2, y, XC[13]);
    for (i = 0; i < 3; i++) K.px(c, x - 3 + i * 3 + ((fr + i) & 1), y - 5 - ((fr + i) % 3), XC[17]);
  });
  PFA.glyph('m11-hand', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a quick grabbing hand: pink palm, fingers spread (fr 0) then snatched shut (fr 1) */
    var i;
    K.sq(c, x, y, 3, Hi); K.px(c, x - nx * 2, y - ny * 2, C); K.px(c, x - nx * 3, y - ny * 3, C);
    for (i = -1; i <= 1; i++) { if (fr) K.px(c, x + nx * 2 + tx * i, y + ny * 2 + ty * i, A); else { K.px(c, x + nx * 2 + tx * i * 2, y + ny * 2 + ty * i * 2, Hi); K.px(c, x + nx * 3 + tx * i * 2, y + ny * 3 + ty * i * 2, A); } }
    K.px(c, x + tx * (fr ? 2 : 3), y + ty * (fr ? 2 : 3), Hi);
  });
  /* capuchin */
  PFA.glyph('m11-capuchin', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a capuchin face: cream face and shoulders, a dark cap on top; fr 1 cheeky grin, fr 2 brows up */
    ape(c, K, x, y, C, A, C, 1, fr);
    K.px(c, x - 4, y + 2, A); K.px(c, x + 4, y + 2, A); K.px(c, x - 4, y + 3, A); K.px(c, x + 4, y + 3, A);
  });
  PFA.glyph('m11-capurun', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* chain body: a capuchin running off on all fours with a stolen gold button held up, tail curled */
    var fl = face(tx, nx, ny), i, X, b = fr & 1;
    for (i = -2; i <= 2; i++) { X = x + fl * i; K.px(c, X, y - 1, A); K.px(c, X, y, A); }
    K.px(c, x + fl * 3, y - 2, C); K.px(c, x + fl * 4, y - 2, C); K.px(c, x + fl * 3, y - 1, C); K.px(c, x + fl * 4, y - 1, C); K.px(c, x + fl * 3, y - 3, A); K.px(c, x + fl * 4, y - 3, A); K.px(c, x + fl * 4, y - 2, XC[13]);
    K.px(c, x + fl * (2 + b), y + 1, A); K.px(c, x - fl * (2 - b), y + 1, A);
    K.px(c, x + fl * 2, y - 3, A); K.px(c, x + fl * 2, y - 4, Hi); K.px(c, x + fl * 1, y - 5, Hi); K.px(c, x + fl * 2, y - 5, K.WHITE);
    K.px(c, x - fl * 3, y - 1, A); K.px(c, x - fl * 4, y - 2, A); K.px(c, x - fl * 4, y - 3, A); K.px(c, x - fl * 3, y - 4, A);
  });
  PFA.glyph('m11-pocket', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a stitched pocket; a small dark hand dips in (fr 1) and comes out with a glinting coin (fr 2) */
    var i;
    K.bx(c, x - 3, y - 1, 7, 5, XC[26]); for (i = -3; i <= 3; i += 2) K.px(c, x + i, y + 3, XC[7]); K.bx(c, x - 3, y - 2, 7, 1, XC[7]);
    if (fr === 1) { K.px(c, x, y - 2, A); K.px(c, x, y - 3, A); K.px(c, x + 1, y - 4, A); K.px(c, x + 1, y - 5, C); }
    if (fr === 2) { K.px(c, x + 2, y - 5, A); K.px(c, x + 3, y - 6, A); K.sq(c, x + 3, y - 8, 3, Hi); K.px(c, x + 2, y - 9, K.WHITE); K.px(c, x + 5, y - 9, K.WHITE); }
  });
  PFA.glyph('m11-fruit', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* fruit bomb: a round orange fruit with a leaf, spinning (fr 0..2); fr 3 it splats with juice flying */
    var i;
    if (fr === 3) { K.bx(c, x - 3, y, 7, 2, XC[19]); K.px(c, x - 4, y - 2, XC[19]); K.px(c, x + 4, y - 3, XC[20]); K.px(c, x, y - 4, XC[19]); K.px(c, x - 2, y - 3, XC[12]); K.px(c, x + 2, y + 1, XC[20]); return; }
    K.sq(c, x, y, 5 + (z > 1 ? 1 : 0), XC[19]); K.px(c, x - 1, y - 1, XC[12]); K.px(c, x + 1, y + 2, XC[20]);
    i = fr === 0 ? 1 : fr === 1 ? 0 : -1; K.px(c, x + i, y - 3, XC[10]); K.px(c, x + i + 1, y - 4, XC[8]); K.px(c, x + i + 2, y - 4, XC[8]);
  });
  PFA.glyph('m11-perch', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* canopy perch: a branch with leaves, a capuchin hanging under it by its curled tail, swinging (fr) */
    var s = (fr & 1) ? 1 : -1;
    K.bx(c, x - 5, y - 4, 11, 1, XC[10]); K.px(c, x - 4, y - 5, XC[8]); K.px(c, x - 3, y - 5, XC[9]); K.px(c, x + 4, y - 5, XC[8]); K.px(c, x + 5, y - 6, XC[8]);
    K.px(c, x, y - 3, A); K.px(c, x + 1, y - 3, A); K.px(c, x + 1, y - 2, A);
    K.bx(c, x - 1 + s, y - 1, 3, 3, A); K.bx(c, x - 1 + s, y + 2, 3, 2, C); K.px(c, x - 1 + s, y + 2, A); K.px(c, x + s, y + 3, XC[13]);
    K.px(c, x - 2 + s, y + 1, A); K.px(c, x + 2 + s, y + 1, A);
  });
  PFA.glyph('m11-button', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a shiny four-hole button on a thread, a glint crossing it (fr 0..3) */
    var r = 2 + (z > 1 ? 1 : 0);
    K.sq(c, x, y, r * 2 + 1, Hi); K.px(c, x - r, y - r, A); K.px(c, x + r, y - r, A); K.px(c, x - r, y + r, A); K.px(c, x + r, y + r, A);
    K.px(c, x - 1, y - 1, A); K.px(c, x + 1, y - 1, A); K.px(c, x - 1, y + 1, A); K.px(c, x + 1, y + 1, A);
    if ((fr & 3) === 1) { K.px(c, x - r - 1, y - r - 1, K.WHITE); K.px(c, x - r - 2, y - r, K.WHITE); } else if ((fr & 3) === 3) { K.px(c, x + r + 1, y - r - 1, K.WHITE); K.px(c, x + r + 1, y - r - 2, K.WHITE); }
  });
  /* wildcat */
  PFA.glyph('m11-wildcat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* chain body: a grey tabby wildcat stalking side-on, thick ringed tail */
    cat(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi, 0);
  });
  PFA.glyph('m11-tabbytail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* the thick blunt wildcat tail: dark rings and a black tip, lashing side to side (fr 0..3) */
    var i, L = 7 + z, b = [0, 1, 0, -1][fr & 3], X, Y, o;
    for (i = 0; i < L; i++) { o = b * i * i / (L * 1.4); X = x + nx * (i - 3) + tx * o; Y = y + ny * (i - 3) + ty * o;
      K.px(c, X, Y, i > L - 3 ? A : (i % 3 === 1 ? A : C)); K.px(c, X + tx, Y + ty, i > L - 3 ? A : (i % 3 === 1 ? A : C)); K.px(c, X - tx, Y - ty, i < L - 2 ? C : A); }
  });
  PFA.glyph('m11-hackle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* fur bristle: an arched tabby back with the fur standing up in spikes (fr 1 taller), stripes across */
    var i, h, X, Y, up = fr ? 1 : 0;
    for (i = -4; i <= 4; i++) { h = Math.round((16 - i * i) / 6); X = x + tx * i + nx * h; Y = y + ty * i + ny * h; K.px(c, X, Y, (i & 1) ? A : C); K.px(c, X - nx, Y - ny, C);
      if ((i & 1) === 0) { K.px(c, X + nx * (1 + up), Y + ny * (1 + up), C); K.px(c, X + nx * (2 + up), Y + ny * (2 + up), A); } }
  });
  PFA.glyph('m11-flatears', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a wildcat face: ears up (fr 0), half back (fr 1), flat with a hiss and fangs (fr 2); amber eyes */
    K.bx(c, x - 3, y - 2, 7, 5, C); K.bx(c, x - 2, y - 2, 1, 2, A); K.bx(c, x + 2, y - 2, 1, 2, A); K.px(c, x, y - 2, A);
    K.px(c, x - 2, y, Hi); K.px(c, x + 2, y, Hi); K.px(c, x, y + 1, XC[14]);
    if (fr === 0) { K.px(c, x - 3, y - 3, C); K.px(c, x - 3, y - 4, A); K.px(c, x + 3, y - 3, C); K.px(c, x + 3, y - 4, A); }
    else if (fr === 1) { K.px(c, x - 4, y - 3, C); K.px(c, x - 5, y - 3, A); K.px(c, x + 4, y - 3, C); K.px(c, x + 5, y - 3, A); }
    else { K.px(c, x - 4, y - 2, C); K.px(c, x - 5, y - 2, A); K.px(c, x + 4, y - 2, C); K.px(c, x + 5, y - 2, A); K.bx(c, x - 1, y + 2, 3, 2, XC[13]); K.px(c, x - 1, y + 2, K.WHITE); K.px(c, x + 1, y + 2, K.WHITE);
      K.px(c, x - 6, y + 1, A); K.px(c, x + 6, y + 1, A); }
  });
  PFA.glyph('m11-claw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a cat paw with hooked claws out, three curved slash marks trailing behind it (fr 1 claws sprung) */
    var i, j, X, Y, L = fr ? 3 : 2;
    K.sq(c, x, y, 3, C); K.px(c, x - nx * 2, y - ny * 2, C);
    for (j = -1; j <= 1; j++) { K.px(c, x + nx * 2 + tx * j * 1.5, y + ny * 2 + ty * j * 1.5, K.WHITE); if (fr) K.px(c, x + nx * 3 + tx * (j * 1.5 + 1), y + ny * 3 + ty * (j * 1.5 + 1), K.WHITE);
      for (i = 2; i < 2 + L + z; i++) { X = x - tx * (i + 1) + nx * (j * 2 + Math.round(i * i * .12)); Y = y - ty * (i + 1) + ny * (j * 2 + Math.round(i * i * .12)); K.px(c, X, Y, i === 2 ? Hi : A); } }
  });
  /* caracal */
  PFA.glyph('m11-caracal', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* chain body: a tawny caracal side-on, long black ear tufts */
    cat(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi, 1);
  });
  PFA.glyph('m11-tuft', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a caracal head with tall pointed ears ending in long black tufts, flicking in turn (fr 0..2) */
    var l = fr === 1 ? 1 : 0, r = fr === 2 ? 1 : 0;
    K.bx(c, x - 2, y - 1, 5, 4, C); K.px(c, x - 1, y, XC[13]); K.px(c, x + 1, y, XC[13]); K.px(c, x, y + 2, A); K.px(c, x - 1, y + 3, Hi); K.px(c, x + 1, y + 3, Hi);
    K.px(c, x - 2, y - 2, C); K.px(c, x - 2 - l, y - 3, C); K.px(c, x - 2 - l, y - 4, A); K.px(c, x - 3 - l * 2, y - 5, A); K.px(c, x - 3 - l * 2, y - 6, A);
    K.px(c, x + 2, y - 2, C); K.px(c, x + 2 + r, y - 3, C); K.px(c, x + 2 + r, y - 4, A); K.px(c, x + 3 + r * 2, y - 5, A); K.px(c, x + 3 + r * 2, y - 6, A);
    K.px(c, x - 1, y - 1, A); K.px(c, x + 1, y - 1, A);
  });
  PFA.glyph('m11-birdswat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a small bird flying out, a tawny paw leaping up to swat it (fr 1), feathers bursting (fr 2) */
    var i, a;
    if (fr < 2) { K.px(c, x + nx * 3, y + ny * 3 - 2, XC[26]); K.px(c, x + nx * 3 - 1, y + ny * 3 - 3 + fr, XC[26]); K.px(c, x + nx * 3 + 1, y + ny * 3 - 3 + fr, XC[26]); K.px(c, x + nx * 3, y + ny * 3 - 1, XC[13]); }
    K.sq(c, x + nx * fr * 2, y + ny * fr * 2, 3, C); K.px(c, x - nx * 2, y - ny * 2, C); K.px(c, x - nx * 3, y - ny * 3, C);
    K.px(c, x + nx * (fr * 2 + 2) + tx, y + ny * (fr * 2 + 2) + ty, K.WHITE); K.px(c, x + nx * (fr * 2 + 2) - tx, y + ny * (fr * 2 + 2) - ty, K.WHITE);
    if (fr === 2) for (i = 0; i < 6; i++) { a = i * 1.05 + .3; K.px(c, x + nx * 5 + Math.cos(a) * 4, y + ny * 5 + Math.sin(a) * 4, i & 1 ? XC[26] : K.WHITE); }
  });
  PFA.glyph('m11-duskrest', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* dusk rest: a caracal lying low in the grass before an orange half sun, ear tufts twitching (fr) */
    var i;
    for (i = -4; i <= 4; i++) K.px(c, x + i, y - 3 + Math.round(Math.abs(i) * Math.abs(i) / 8), XC[22]); K.bx(c, x - 3, y - 2, 7, 1, XC[22]);
    K.bx(c, x - 4, y, 7, 2, C); K.px(c, x + 3, y - 1, C); K.px(c, x + 4, y - 1, C); K.px(c, x + 4, y - 1, XC[13]);
    K.px(c, x + 3, y - 2 - (fr & 1), A); K.px(c, x + 5, y - 2 - ((fr >> 1) & 1), A); K.px(c, x - 5, y + 1, C);
    K.px(c, x - 2, y + 2, XC[23]); K.px(c, x + 1, y + 2, XC[23]); K.px(c, x - 5, y + 2, XC[23]);
  });
  PFA.glyph('m11-scrub', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* scrub cover: a dry thorn bush with two black ear tufts poking above it (fr 1 tufts up, 0 down) */
    var i;
    for (i = -4; i <= 4; i++) { K.px(c, x + i, y + 1 - (Math.abs(i) < 3 ? 2 : 1), (i & 1) ? XC[11] : XC[23]); K.px(c, x + i, y + 1, XC[11]); if (Math.abs(i) < 4) K.px(c, x + i, y, (i & 1) ? XC[23] : XC[11]); }
    K.px(c, x - 3, y + 2, XC[10]); K.px(c, x + 2, y + 2, XC[10]); K.px(c, x - 5, y - 1, XC[10]); K.px(c, x + 5, y - 2, XC[10]);
    if (fr) { K.px(c, x - 1, y - 2, C); K.px(c, x - 1, y - 3, A); K.px(c, x - 2, y - 4, A); K.px(c, x + 1, y - 2, C); K.px(c, x + 1, y - 3, A); K.px(c, x + 2, y - 4, A); }
  });
  /* fishing cat */
  PFA.glyph('m11-fishcat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* chain body: a stocky spotted fishing cat wading, webbed feet */
    cat(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi, 2);
  });
  PFA.glyph('m11-scoop', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* the webbed paw scoops a silver fish out of the water: fr 0 paw in the water, 1 scooping with a splash, 2 the fish flipping */
    var i;
    K.bx(c, x - 4, y + 2, 9, 1, XC[24]); K.px(c, x - 2, y + 2, Hi); K.px(c, x + 3, y + 2, Hi);
    if (fr === 0) { K.sq(c, x, y + 1, 3, C); K.px(c, x, y - 1, C); K.px(c, x - 1, y + 3, XC[25]); K.px(c, x + 1, y + 3, XC[25]); return; }
    K.sq(c, x - 2, y - 1, 3, C); K.px(c, x - 1, y - 1, A); K.px(c, x - 3, y + 1, C);
    for (i = 0; i < 4; i++) K.px(c, x - 1 + i, y - 3 - fr - (i === 1 || i === 2 ? 1 : 0), XC[25]); K.px(c, x + 3, y - 4 - fr + (fr === 2 ? 1 : -1), XC[25]); K.px(c, x, y - 4 - fr, XC[13]);
    K.px(c, x - 4, y, K.DEW); K.px(c, x + 4, y - 1, K.DEW); K.px(c, x + 2, y, K.WHITE);
  });
  PFA.glyph('m11-wetcoat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* wet plate: a stocky spotted back half under water, drops beading and running off it (fr) */
    var i;
    for (i = -4; i <= 4; i++) { K.px(c, x + i, y - 1 - (Math.abs(i) < 3 ? 1 : 0), C); K.px(c, x + i, y, C); if ((i + 6) % 3 === 0) K.px(c, x + i, y - 1, A); }
    K.px(c, x - 2, y - 2, A); K.px(c, x + 2, y - 2, A); K.bx(c, x - 5, y + 1, 11, 1, XC[24]); K.px(c, x - 3, y + 1, K.WHITE);
    K.px(c, x - 3 + fr, y - 3, K.DEW); K.px(c, x + 4 - fr, y - 2 + (fr & 1), K.DEW); K.px(c, x, y - 3 - (fr & 1), K.WHITE);
  });
  PFA.glyph('m11-spray', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* fur shake: a spotted fur tuft whipping side to side, a ring of water drops flung off it (fr 0..3 spreads) */
    var i, a, r = 3 + (fr & 3), w = (fr & 1) ? 1 : -1;
    K.sq(c, x + w, y, 3, C); K.px(c, x + w, y, A); K.px(c, x - w, y - 1, C); K.px(c, x - w, y + 1, C);
    for (i = 0; i < 6; i++) { a = i * 1.047 + fr * .3; K.px(c, x + Math.cos(a) * r, y + Math.sin(a) * r * .8, (i & 1) ? K.DEW : K.WHITE); }
  });
  PFA.glyph('m11-webpaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a webbed paw flicking outward: spread toes with the web between in water blue, claws hooked, a drop flicked off (fr 1) */
    var j;
    K.sq(c, x - nx, y - ny, 3, C); K.px(c, x - nx * 3, y - ny * 3, C);
    for (j = -2; j <= 2; j++) { K.px(c, x + nx * 2 + tx * j, y + ny * 2 + ty * j, (j & 1) ? Hi : C); if (!(j & 1)) K.px(c, x + nx * 3 + tx * j, y + ny * 3 + ty * j, K.WHITE); }
    if (fr) { K.px(c, x + nx * 6 + tx * 2, y + ny * 6 + ty * 2 - 1, K.DEW); K.px(c, x + nx * 7 - tx, y + ny * 7 - ty - 2, K.DEW); }
  });
  /* jaguarundi */
  PFA.glyph('m11-otcat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a long low plain jaguarundi slipping along like an otter, small round ears, long tail */
    cat(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi, 3);
  });
  PFA.glyph('m11-slip', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* river slip: a slick wet streak with the plain dark back slipping into water, a splash ring opening (fr 0..2) */
    var i;
    for (i = -4; i <= 3; i++) K.px(c, x + tx * i, y + ty * i, (i & 1) ? XC[24] : K.DEW);
    if (fr < 2) { K.px(c, x + nx - tx, y + ny - ty, C); K.px(c, x + nx, y + ny, C); K.px(c, x + nx + tx, y + ny + ty, C); K.px(c, x + nx * 2 + tx * 2, y + ny * 2 + ty * 2, C); }
    K.ringpx(c, x + tx * 3, y + ty * 3, 1 + fr, fr ? K.WHITE : K.DEW);
  });
  PFA.glyph('m11-grass', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* bank cover: tall blades parting (fr 1) to show a plain dark back slipping between, then closing (fr 0) */
    var i, o = fr ? 2 : 0, j;
    for (j = -1; j <= 1; j += 2) for (i = 0; i < 7; i++) { K.px(c, x + j * (1 + o + (i > 4 ? 1 : 0)), y + 2 - i, i > 4 ? XC[23] : XC[11]); K.px(c, x + j * (3 + o), y + 2 - i + 1, XC[9]); }
    if (fr) { K.bx(c, x - 1, y - 1, 3, 3, C); K.px(c, x, y - 1, A); K.px(c, x + 1, y - 2, Hi); }
  });
  PFA.glyph('m11-shadow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* unseen cross: a dark low silhouette, only two eyes glinting (fr 1) and a faint outline */
    var i;
    for (i = -4; i <= 4; i++) { K.px(c, x + i, y, (i & 1) ? A : C); if (Math.abs(i) < 3) K.px(c, x + i, y - 1, A); }
    K.px(c, x + 5, y - 1, A); K.px(c, x - 5, y + 1, A);
    if (fr) { K.px(c, x + 3, y - 2, Hi); K.px(c, x + 5, y - 2, Hi); }
  });
  /* jaguar cubs */
  PFA.glyph('m11-jcub', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a round spotted jaguar cub side-on, big paws, stubby tail (chain body and signature) */
    cat(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi, 4);
  });
  PFA.glyph('m11-jtwins', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* two spotted cubs play-wrestling: one on top, swapping (fr 0..3), paws batting */
    var t = fr & 1, s = fr & 2 ? 1 : -1;
    cat(c, K, x - 2, y + 2, 1, fr, C, A, Hi, 4); cat(c, K, x + 2, y - 1 + t, -1, fr + 1, C, A, Hi, 4);
    K.px(c, x + s * 5, y - 4 - t, C); K.px(c, x + s * 6, y - 5, A);
  });
  PFA.glyph('m11-jpaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* an oversized cub paw: a big pad and four toes with a rosette on the leg, batting out (fr 1 toes spread) */
    var s = fr ? 1 : 0, j;
    K.bx(c, x - 2, y - 1, 5, 4, C); K.bx(c, x - 1, y, 3, 2, A); K.px(c, x, y, XC[14]);
    for (j = -2; j <= 1; j++) { K.px(c, x + j + (j >= 0 ? 1 : 0) + (j < 0 ? -s : s), y - 2 - s, XC[14]); K.px(c, x + j + (j >= 0 ? 1 : 0) + (j < 0 ? -s : s), y - 3 - s, C); }
    K.px(c, x - nx * 3, y - ny * 3 + 4, C); K.px(c, x - nx * 4 - 1, y - ny * 4 + 4, A); K.px(c, x - nx * 4 + 1, y - ny * 4 + 4, A);
  });
  PFA.glyph('m11-tailchase', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a cub curled in a circle chasing its own stubby tail, spinning (fr 0..3): head and tail go round */
    var i, a, b = fr * 1.571;
    for (i = 0; i < 10; i++) { a = b + i * .55; K.px(c, x + Math.cos(a) * 4, y + Math.sin(a) * 3, (i % 3 === 1) ? A : C); }
    a = b + 5.4; K.px(c, x + Math.cos(a) * 4, y + Math.sin(a) * 3, XC[13]); K.px(c, x + Math.cos(a) * 5, y + Math.sin(a) * 4, C);
    a = b - .5; K.px(c, x + Math.cos(a) * 4, y + Math.sin(a) * 3, A); K.px(c, x + Math.cos(b - .8) * 5, y + Math.sin(b - .8) * 4, Hi);
  });
  PFA.glyph('m11-lace', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a bootlace bow with two aglets, tugged loose by a paw (fr 0 bow, 1 half, 2 untied and dangling) */
    var i;
    if (fr < 2) { K.ringpx(c, x - 2, y - 1, 1 + (fr ? 0 : 1), XC[27]); K.ringpx(c, x + 2, y - 1, 1 + (fr ? 0 : 1), XC[27]); K.px(c, x, y, XC[27]); }
    for (i = 0; i < 4; i++) { K.px(c, x - 1 - (fr === 2 ? i : 0), y + 1 + i, XC[27]); K.px(c, x + 1 + (fr === 2 ? i : 0), y + 1 + i, XC[27]); }
    K.px(c, x - 1 - (fr === 2 ? 4 : 0), y + 5, A); K.px(c, x + 1 + (fr === 2 ? 4 : 0), y + 5, A);
    if (fr) { K.sq(c, x + 4, y - 3, 3, C); K.px(c, x + 3, y - 3, A); K.px(c, x + 5, y - 4, A); }
  });
  /* bear cubs */
  PFA.glyph('m11-cubball', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a fluffy brown bear cub curled into a ball, rolling: ears, face and paws go round with it (fr 0..3) */
    var r = 3 + (z > 0 ? 1 : 0), a = fr * 1.571, i;
    K.sq(c, x, y, r * 2 + 1, C); K.px(c, x - r - 1, y, C); K.px(c, x + r + 1, y, C); K.px(c, x, y - r - 1, C); K.px(c, x, y + r + 1, C);
    for (i = 0; i < 2; i++) K.px(c, x + Math.cos(a + i * .9) * (r + 1), y + Math.sin(a + i * .9) * (r + 1), A);
    K.px(c, x + Math.cos(a + .45) * (r - 1), y + Math.sin(a + .45) * (r - 1), Hi); K.px(c, x + Math.cos(a + .45) * (r - 2), y + Math.sin(a + .45) * (r - 2), XC[13]);
    K.px(c, x + Math.cos(a + 3) * (r - 1), y + Math.sin(a + 3) * (r - 1), A); K.px(c, x + Math.cos(a + 3.6) * (r - 1), y + Math.sin(a + 3.6) * (r - 1), A);
    K.px(c, x + Math.cos(a + 4.5) * 2, y + Math.sin(a + 4.5) * 2, K.WHITE);
  });
  PFA.glyph('m11-honeypaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a paw pulled out of a honeycomb, golden honey dripping from it (fr 0..3 drip falling) */
    var d = fr & 3;
    K.ringpx(c, x - 3, y + 2, 1, XC[12]); K.ringpx(c, x, y + 3, 1, XC[12]); K.ringpx(c, x + 3, y + 2, 1, XC[12]); K.px(c, x - 3, y + 2, XC[6]); K.px(c, x + 3, y + 2, XC[6]);
    K.bx(c, x - 2, y - 3, 4, 3, C); K.px(c, x - 2, y - 4, A); K.px(c, x, y - 4, A); K.px(c, x + 1, y - 4, A); K.px(c, x - 1, y - 2, XC[13]);
    K.px(c, x - 1, y, XC[12]); K.px(c, x + 1, y, XC[12]); K.px(c, x + 1, y + 1 + d, XC[12]); K.px(c, x + 1, y + 2 + d, Hi);
  });
  PFA.glyph('m11-fern', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* tumble cover: two fern fronds parting, a round cub head with two round ears peeking between (fr 1) */
    var o = fr ? 1 : 0;
    fern(c, K, x - 2 - o, y + 3, -1, XC[8], XC[9]); fern(c, K, x + 2 + o, y + 3, 1, XC[8], XC[9]);
    if (fr) { K.bx(c, x - 1, y - 1, 3, 3, C); K.px(c, x - 1, y - 2, C); K.px(c, x + 1, y - 2, C); K.px(c, x, y + 1, A); K.px(c, x - 1, y, XC[13]); K.px(c, x + 1, y, XC[13]); }
  });
  /* sun bear */
  PFA.glyph('m11-sunbear', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a black sun bear head with a pale gold muzzle and the gold crescent on its chest glowing (fr 1 rays) */
    bear(c, K, x, y - 1, A, A, C, 1); K.px(c, x - 3, y - 5, C); K.px(c, x + 3, y - 5, C);
    if (fr) { K.px(c, x - 5, y + 2, C); K.px(c, x + 5, y + 2, C); K.px(c, x, y + 6, C); K.px(c, x - 4, y + 5, Hi); K.px(c, x + 4, y + 5, Hi); }
  });
  PFA.glyph('m11-sunbearwalk', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* chain head: the sun bear side-on, black, gold muzzle, the tongue rolling out ahead of it */
    var fl = face(tx, nx, ny), i, X, b = fr & 1;
    for (i = -3; i <= 2; i++) { X = x + fl * i; K.px(c, X, y - 2, A); K.px(c, X, y - 1, A); K.px(c, X, y, A); }
    K.px(c, x + fl * 3, y - 2, A); K.px(c, x + fl * 3, y - 1, A); K.px(c, x + fl * 4, y - 1, C); K.px(c, x + fl * 4, y - 2, C); K.px(c, x + fl * 3, y - 3, A); K.px(c, x + fl * 2, y - 3, A);
    K.px(c, x + fl * 3, y - 2, XC[13]); K.px(c, x + fl * 2, y, C); K.px(c, x + fl * 1, y, C);
    K.px(c, x + fl * (2 + b), y + 1, A); K.px(c, x - fl * (2 - b), y + 1, A); K.px(c, x + fl * (3 + b), y + 1, K.WHITE);
  });
  PFA.glyph('m11-barkclaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* long sickle claws ripping bark: a black paw with four pale hooked claws, a strip of bark peeling off (fr) */
    var j, L = 3 + z;
    K.sq(c, x - nx * 2, y - ny * 2, 3, A); K.px(c, x - nx * 4, y - ny * 4, A);
    for (j = -1; j <= 2; j++) { K.px(c, x + tx * (j * 1.3 - .6), y + ty * (j * 1.3 - .6), C); K.px(c, x + nx * 1 + tx * (j * 1.3 - .6), y + ny * 1 + ty * (j * 1.3 - .6), C);
      K.px(c, x + nx * 2 + tx * (j * 1.3 + .4), y + ny * 2 + ty * (j * 1.3 + .4), C); }
    for (j = 0; j < L; j++) K.px(c, x + nx * (3 + j) + tx * (4 + (fr & 1) * j * .5), y + ny * (3 + j) + ty * (4 + (fr & 1) * j * .5), j & 1 ? XC[30] : XC[10]);
  });
  PFA.glyph('m11-treehug', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* bark hide: a tree trunk with a black bear pressed to it, arms wrapped round, peeking out one side or the other (fr) */
    var s = fr ? 1 : -1;
    K.bx(c, x - 2, y - 6, 4, 12, XC[10]); K.px(c, x - 1, y - 4, XC[6]); K.px(c, x, y + 1, XC[6]); K.px(c, x + 1, y - 1, XC[30]);
    K.bx(c, x - 3, y - 1, 1, 2, A); K.bx(c, x + 2, y - 1, 1, 2, A); K.px(c, x - 2, y + 2, A); K.px(c, x + 1, y + 2, A);
    K.bx(c, x + s * 3 - (s < 0 ? 1 : 0), y - 4, 2, 2, A); K.px(c, x + s * 4, y - 3, C); K.px(c, x + s * 3, y - 5, A);
    K.px(c, x - 1, y - 2, C); K.px(c, x, y - 1, C);
  });
  PFA.glyph('m11-sniff', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* sniff out: the pale gold muzzle snuffling, scent lines curling in (fr), little termites scattering */
    var i, X, Y;
    K.bx(c, x - 2, y - 1, 4, 3, C); K.px(c, x - 3, y - 2, A); K.px(c, x + 2, y - 2, A); K.px(c, x - 1, y - 1, XC[13]); K.px(c, x, y - 1, XC[13]);
    for (i = 0; i < 4; i++) { X = x + nx * (3 + i) + tx * Math.round(Math.sin(i * 1.6 + fr * 1.57)); Y = y + ny * (3 + i) + ty * Math.round(Math.sin(i * 1.6 + fr * 1.57)); K.px(c, X, Y, i & 1 ? Hi : C); }
    K.px(c, x + nx * 6 + tx * 3, y + ny * 6 + ty * 3, XC[29]); K.px(c, x + nx * 5 - tx * (3 + (fr & 1)), y + ny * 5 - ty * (3 + (fr & 1)), XC[29]);
  });
  PFA.glyph('m11-tongue', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* long-tongue raid: a black muzzle at a hole in the bark, the long pink tongue reaching in and out (fr 0..2), honey on the tip */
    var i, L = 2 + fr * 2 + z;
    K.ringpx(c, x + nx * (L + 2), y + ny * (L + 2), 2, XC[10]); K.px(c, x + nx * (L + 2), y + ny * (L + 2), XC[6]);
    K.sq(c, x - nx * 2, y - ny * 2, 3, A); K.px(c, x - nx, y - ny, C);
    for (i = 0; i < L; i++) K.px(c, x + nx * i, y + ny * i, Hi);
    K.px(c, x + nx * L, y + ny * L, XC[12]);
  });

  /* ---------- motions (mutate the scratch G; stateless in pp) ---------- */
  PFA.motion('m11-pose', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; G.fr = w < .55 ? 0 : w < .8 ? 1 : 2; G.up += Math.round(Math.sin(pp * 7 + k) * .7); });
  PFA.motion('m11-drum', function (G, pp, k) { G.fr = ((Math.floor(pp * 10) + k) & 1); G.up += G.fr; });
  PFA.motion('m11-poof', function (G, pp, k, ph) { var w = (pp * 1.4 + ph) % 1; G.fr = w < .45 ? 0 : w < .65 ? 1 : 2; G.t += G.fr === 0 ? Math.sin(pp * 8 + k) * 1.5 : 0; });
  PFA.motion('m11-ballroll', function (G, pp, k) { G.s += pp * .25; G.fr = (Math.floor(pp * 14) + k) & 3; G.up += Math.abs(Math.sin(pp * 10 + k)) * 1.5; });
  PFA.motion('m11-blink', function (G, pp, k, ph) { G.fr = ((pp * 1.3 + ph) % 1) < .7 ? 0 : 1; });
  PFA.motion('m11-flag', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; G.t += Math.sin(pp * 6 + k) * 1; });
  PFA.motion('m11-picket', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 1; });
  PFA.motion('m11-peek', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 3) + k) % 3; });
  PFA.motion('m11-probe', function (G, pp, k) { G.fr = (Math.floor(pp * 12) + k) & 3; G.d += Math.sin(pp * 8 + k) * 1.5; });
  PFA.motion('m11-threat', function (G, pp, k, ph) { var w = (pp * 1.8 + ph) % 1; G.fr = w < .4 ? 0 : w < .75 ? 1 : 2; G.d += G.fr === 1 ? 1 : 0; });
  PFA.motion('m11-pouch', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.5 + ph) % 1) * 3)); });
  PFA.motion('m11-steam', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) % 3; G.up += Math.round(Math.sin(pp * 3 + k) * .6); });
  PFA.motion('m11-grab', function (G, pp, k, ph) { var w = (pp * 3 + ph) % 1; G.fr = w < .55 ? 0 : 1; G.d += G.fr ? -1 : 2; G.t += Math.sin(pp * 11 + k) * 1.5; });
  PFA.motion('m11-grin', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.fr = w < .5 ? 0 : w < .8 ? 1 : 2; G.t += Math.sin(pp * 9 + k) * .8; });
  PFA.motion('m11-dip', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.6 + ph) % 1) * 3)); });
  PFA.motion('m11-lob', function (G, pp, k, ph) { var w = (pp * 1.4 + ph) % 1; G.up += Math.sin(w * Math.PI) * 6; G.fr = w > .85 ? 3 : (Math.floor(pp * 9) + k) % 3; });
  PFA.motion('m11-swing', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 1; G.t += Math.sin(pp * 5 + k) * 2; });
  PFA.motion('m11-glint', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; });
  PFA.motion('m11-lash', function (G, pp, k) { G.fr = (Math.floor(pp * 9) + k) & 3; });
  PFA.motion('m11-bristle', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 1; G.t += G.fr ? .5 : -.5; });
  PFA.motion('m11-ears', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.4 + ph) % 1) * 3)); });
  PFA.motion('m11-swipe', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 1; G.t += G.fr ? 2 : -1; });
  PFA.motion('m11-flick', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 3) + k) % 3; });
  PFA.motion('m11-swat', function (G, pp, k, ph) { var w = (pp * 1.7 + ph) % 1; G.fr = w < .45 ? 0 : w < .7 ? 1 : 2; G.up += G.fr === 1 ? 3 : 0; });
  PFA.motion('m11-dusk', function (G, pp, k) { G.fr = (Math.floor(pp * 4) + k) & 3; });
  PFA.motion('m11-rustle', function (G, pp, k, ph) { G.fr = ((pp * 2 + ph) % 1) < .5 ? 0 : 1; G.t += G.fr ? 0 : Math.sin(pp * 20 + k) * .6; });
  PFA.motion('m11-scoop', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.7 + ph) % 1) * 3)); });
  PFA.motion('m11-bead', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) % 3; });
  PFA.motion('m11-shake', function (G, pp, k) { G.fr = (Math.floor(pp * 14) + k) & 3; G.t += (G.fr & 1) ? 1 : -1; });
  PFA.motion('m11-flickpaw', function (G, pp, k, ph) { G.fr = ((pp * 2.2 + ph) % 1) < .5 ? 0 : 1; G.d += G.fr * 2; });
  PFA.motion('m11-slink', function (G, pp, k) { G.s += pp * .3; G.fr = (Math.floor(pp * 10) + k) & 3; });
  PFA.motion('m11-slip', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.8 + ph) % 1) * 3)); G.t += pp * 3; });
  PFA.motion('m11-part', function (G, pp, k, ph) { G.fr = ((pp * 1.5 + ph) % 1) < .45 ? 0 : 1; });
  PFA.motion('m11-ghost', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) % 3 === 0 ? 1 : 0; G.t += Math.sin(pp * 4 + k) * 2; });
  PFA.motion('m11-wrestle', function (G, pp, k) { G.fr = (Math.floor(pp * 9) + k) & 3; G.up += Math.abs(Math.sin(pp * 9 + k)) * 2; });
  PFA.motion('m11-bat', function (G, pp, k, ph) { var w = (pp * 2.4 + ph) % 1; G.fr = w < .5 ? 0 : 1; G.up += G.fr * 2; });
  PFA.motion('m11-spin', function (G, pp, k) { G.fr = (Math.floor(pp * 12) + k) & 3; });
  PFA.motion('m11-tug', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.3 + ph) % 1) * 3)); G.t += G.fr === 1 ? 1 : 0; });
  PFA.motion('m11-roll', function (G, pp, k) { G.s += pp * .35; G.fr = (Math.floor(pp * 12) + k) & 3; G.up += Math.abs(Math.sin(pp * 7 + k)) * 3; });
  PFA.motion('m11-drip', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; });
  PFA.motion('m11-glow', function (G, pp, k, ph) { G.fr = ((pp * 1.2 + ph) % 1) < .5 ? 0 : 1; G.up += Math.round(Math.sin(pp * 4 + k) * .6); });
  PFA.motion('m11-rip', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 1; G.t += G.fr; });
  PFA.motion('m11-hug', function (G, pp, k, ph) { G.fr = ((pp * 1.4 + ph) % 1) < .5 ? 0 : 1; });
  PFA.motion('m11-snuffle', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; G.d += (G.fr & 1) * .8; });
  PFA.motion('m11-lap', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .33 ? 0 : w < .66 ? 1 : 2; });

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ---------- */
  function sgnOf(e) { return e.d >= 0 ? 1 : -1; }
  function body(c, e, H, g, s, lift, fr) {  /* a side-view chain body facing the travel direction, 5 px off the edge */
    var Q = H.Q, sg = sgnOf(e); e.P.atq(s);
    H.glyph(c, g, Q.x + Q.nx * 5, Q.y + Q.ny * 5 - lift, e.z, fr, e.col, e.acc, e.hi, -Q.ny * sg, Q.nx * sg, Q.nx, Q.ny);
  }
  function carPoof(c, e, H) {            /* the tanuki turns into a leaf (poof cloud at the start), the leaf flutters along the edge, and the tanuki pops out of a second poof at the end */
    var P = e.P, Q = H.Q, hh = e.hh, sw;
    if (hh < .2) { H.carHead(c, P, e.a, 'm11-leafpoof', 0, hh < .08 ? 2 : 1, 0, 0, e.col, e.acc, e.hi); return; }
    if (hh < .85) { P.atq(e.a + e.d * hh); sw = Math.sin(e.p * 30) * 3; H.glyph(c, 'm11-leafpoof', Q.x + Q.nx * (6 + Math.abs(sw)) + sw * -Q.ny, Q.y + Q.ny * (6 + Math.abs(sw)) + sw * Q.nx, 0, 0, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny); return; }
    H.carHead(c, P, e.a + e.d * hh, hh < .93 ? 'm11-leafpoof' : 'm11-tanuki', e.z, hh < .93 ? 1 : 0, 0, 0, e.col, e.acc, e.hi);
  }
  function carBand(c, e, H) {            /* a band of three coatis marching nose to tail, ringed tails up like flags */
    var k, u;
    for (k = 2; k >= 0; k--) { u = e.hh - k * .1; if (u < 0) continue; body(c, e, H, 'm11-coati', e.a + e.d * u, (Math.floor(e.p * 12) + k) & 1, (Math.floor(e.p * 12) + k) & 3); }
  }
  function carTroop(c, e, H) {           /* the macaque troop bounds along on all fours: a big one leading, two smaller ones bouncing behind */
    var k, u, b;
    for (k = 2; k >= 0; k--) { u = e.hh - k * .12; if (u < 0) continue; b = Math.abs(Math.sin(e.p * 16 + k * 1.3)) * 4; body(c, e, H, 'm11-macaquerun', e.a + e.d * u, b, (Math.floor(e.p * 16) + k) & 1); }
  }
  function carLoot(c, e, H) {            /* the capuchin runs off along the edge holding a stolen gold button up, an empty pocket left at the start */
    var P = e.P, Q = H.Q;
    P.atq(e.a); H.px(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4, XC[26]); H.px(c, Q.x + Q.nx * 4 + 1, Q.y + Q.ny * 4, XC[26]); H.px(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4 + 1, XC[7]);
    body(c, e, H, 'm11-capurun', e.a + e.d * e.hh, Math.floor(e.p * 18) & 1, Math.floor(e.p * 18) & 1);
  }
  function carStalk(c, e, H) {           /* the wildcat stalks low along the edge, pausing (tail lash) then creeping on; a pounce hop at the end */
    var hh = e.hh, u = hh < .8 ? hh - Math.sin(hh * 25) * .015 : hh, lift = hh > .82 ? Math.sin((hh - .82) / .18 * Math.PI) * 6 : 0;
    body(c, e, H, 'm11-wildcat', e.a + e.d * u, lift, Math.floor(e.p * 8) & 3);
  }
  function carLeap(c, e, H) {            /* the caracal leaps in one high arc to the next piece, its dotted flight path behind, feathers bursting where it lands */
    var P = e.P, Q = H.Q, u, k, a, X, Y;
    for (u = .1; u < e.hh - .05; u += .1) { P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * (5 + Math.sin(u * Math.PI) * 14), Q.y + Q.ny * (5 + Math.sin(u * Math.PI) * 14) - Math.sin(u * Math.PI) * 4, e.acc); }
    if (e.hh > .9) { P.atq(e.a + e.d); X = Q.x + Q.nx * 7; Y = Q.y + Q.ny * 7; for (k = 0; k < 5; k++) { a = k * 1.26 + e.p * 3; H.px(c, X + Math.cos(a) * (2 + (e.hh - .9) * 40), Y + Math.sin(a) * (2 + (e.hh - .9) * 30), k & 1 ? XC[26] : H.WHITE); } }
    body(c, e, H, 'm11-caracal', e.a + e.d * e.hh, Math.sin(e.hh * Math.PI) * 14, e.hh > .1 && e.hh < .9 ? 1 : Math.floor(e.p * 10) & 3);
  }
  function carWade(c, e, H) {            /* the fishing cat wades along the edge; a ripple ring opens under every step behind it */
    var P = e.P, Q = H.Q, k, u, r;
    for (k = 1; k <= 4; k++) { u = k / 5; if (e.hh < u) break; r = Math.min(4, (e.hh - u) * 20 + 1); P.atq(e.a + e.d * u); H.ringpx(c, Q.x + Q.nx * 6, Q.y + Q.ny * 6 + 2, r, r > 3 ? H.DEW : XC[24]); }
    body(c, e, H, 'm11-fishcat', e.a + e.d * e.hh, 0, Math.floor(e.p * 8) & 3);
  }
  function carSlide(c, e, H) {           /* the jaguarundi slips along like an otter: long low body, a short dark streak behind it */
    var P = e.P, Q = H.Q, u, k = 0;
    for (u = Math.max(0, e.hh - .3); u < e.hh - .04; u += .03) { P.atq(e.a + e.d * u); if ((k++ + Math.floor(e.p * 20)) % 3) H.px(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5 + 1, e.acc); }
    body(c, e, H, 'm11-otcat', e.a + e.d * e.hh, 0, Math.floor(e.p * 12) & 3);
  }
  function carChase(c, e, H) {           /* two jaguar cubs chase each other along the edge, the rear one pouncing at the leader's stubby tail */
    var b = Math.abs(Math.sin(e.p * 14)) * 5;
    body(c, e, H, 'm11-jcub', e.a + e.d * Math.max(0, e.hh - .14), b, Math.floor(e.p * 14) & 3);
    body(c, e, H, 'm11-jcub', e.a + e.d * e.hh, (Math.floor(e.p * 14) & 1), (Math.floor(e.p * 14) + 2) & 3);
  }
  function carCubRoll(c, e, H) {         /* the bear cub rolls along curled into a ball, bouncing over three bumps, dust kicked out at each bounce */
    var P = e.P, Q = H.Q, b = Math.abs(Math.sin(e.hh * Math.PI * 3)) * 5, k, u;
    for (k = 1; k <= 3; k++) { u = (k - .5) / 3; if (e.hh < u || e.hh > u + .2) continue; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 3 - 2, Q.y + Q.ny * 3 - 1, XC[16]); H.px(c, Q.x + Q.nx * 3 + 2, Q.y + Q.ny * 3 - 2, XC[16]); H.px(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4 - 3, XC[7]); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm11-cubball', e.z, Math.floor(e.hh * 16) & 3, 0, -b, e.col, e.acc, e.hi);
  }
  function carTongue(c, e, H) {          /* the sun bear's long pink tongue unrolls along the edge from the bear to the next piece, a honey drop on its tip */
    var P = e.P, Q = H.Q, u, k = 0, w;
    body(c, e, H, 'm11-sunbearwalk', e.a, 0, Math.floor(e.p * 6) & 1);
    for (u = .08; u <= e.hh; u += .025) { P.atq(e.a + e.d * u); w = Math.round(Math.sin(u * 30 - e.p * 10) * .7); H.px(c, Q.x + Q.nx * (4 + w), Q.y + Q.ny * (4 + w), e.hi); if (!(k++ & 3)) H.px(c, Q.x + Q.nx * (5 + w), Q.y + Q.ny * (5 + w), XC[15]); }
    P.atq(e.a + e.d * e.hh); H.sq(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4, 3, XC[12]); H.px(c, Q.x + Q.nx * 4 - 1, Q.y + Q.ny * 4 - 1, H.WHITE);
  }

  /* ---------- motifs ---------- */
  function M(name, draw, meta) { PFA.motif(name, draw, meta); }
  function wet(c, e, H) { comp(c, e, H, decoWet); }
  function leafy(c, e, H) { comp(c, e, H, decoLeaf); }
  function grassy(c, e, H) { comp(c, e, H, decoGrass); }
  function steamy(c, e, H) { comp(c, e, H, decoSteam); }
  /* tanuki */
  M('leaf-hat', plain, { nm: 'leaf-hat tanuki', desc: 'round masked tanuki faces with a green leaf on the head, whiskers bristling and blinking; the chain poofs into a leaf, flutters along and pops back out as a tanuki', fam: 'bash', gap: 14, g: 'm11-tanuki', mo: 'm11-pose', x: '-', car: 'custom', carDraw: carPoof });
  M('belly-drum', plain, { nm: 'belly drums', desc: 'a round pale tanuki belly drummed by two dark paws, a beat ring popping out on every beat', fam: 'ripple', gap: 16, g: 'm11-drum', mo: 'm11-drum', x: '-', car: 'rings' });
  M('leaf-poof', plain, { nm: 'leaf poofs', desc: 'a green leaf that vanishes in a white poof cloud, a masked face peeking out of the smoke', fam: 'leaf', gap: 14, g: 'm11-leafpoof', mo: 'm11-poof', x: '-', car: 'blink' });
  M('belly-roll', plain, { nm: 'tanuki balls', desc: 'a round tanuki rolled into a furry ball, the dark mask band turning with it', fam: 'bash', gap: 14, g: 'm11-tanukiball', mo: 'm11-ballroll', x: 'dust', car: 'roll' });
  M('stump-pose', plain, { nm: 'stump poses', desc: 'a cut tree stump with rings and a leaf on top, a striped tail peeking out and two eyes blinking open in the bark', fam: 'shield', gap: 16, g: 'm11-stump', mo: 'm11-blink', x: '-', car: 'train' });
  /* coati */
  M('tail-flag', leafy, { nm: 'ringtail flags', desc: 'upright ringed coati tails sticking out like flags, tips curling, canopy leaves falling; the chain is a band of coatis marching tails-up', fam: 'thorn', gap: 10, g: 'm11-tailflag', mo: 'm11-flag', x: '-', car: 'custom', carDraw: carBand });
  M('ring-screen', plain, { nm: 'ringtail screens', desc: 'three ringed tails crossed into a picket screen, the dark and pale bands pulsing', fam: 'thorn', gap: 14, g: 'm11-ringscreen', mo: 'm11-picket', x: '-', car: 'train' });
  M('log-cover', leafy, { nm: 'log covers', desc: 'a mossy fallen log with long coati snouts poking out from under it in turn', fam: 'shield', gap: 18, g: 'm11-log', mo: 'm11-peek', x: '-', car: 'train' });
  M('snout-probe', plain, { nm: 'snout probes', desc: 'long upturned coati snouts probing outward, the tip twitching, soil crumbs flicked', fam: 'thrust', gap: 12, g: 'm11-snout', mo: 'm11-probe', x: '-', car: 'comet' });
  /* macaque */
  M('pink-face', plain, { nm: 'macaque faces', desc: 'pink macaque faces in a grey-brown fur ring, flashing an open-mouth threat and raised brows; the chain is the troop bounding on all fours', fam: 'bash', gap: 14, g: 'm11-macaque', mo: 'm11-threat', x: '-', car: 'custom', carDraw: carTroop });
  M('cheek-pouch', plain, { nm: 'cheek pouches', desc: 'a macaque face with bulging cheek pouches that dump out seeds and fruit scraps', fam: 'leaf', gap: 16, g: 'm11-cheeks', mo: 'm11-pouch', x: '-', car: 'hop' });
  M('hot-spring-huddle', steamy, { nm: 'hot-spring huddles', desc: 'two macaque heads in steaming water with snow on their crowns, steam curls rising', fam: 'shield', gap: 18, g: 'm11-onsen', mo: 'm11-steam', x: '-', car: 'rings' });
  M('quick-hand', plain, { nm: 'quick hands', desc: 'pink-palmed monkey hands with fingers spread, snatching shut', fam: 'shock', gap: 12, g: 'm11-hand', mo: 'm11-grab', x: '-', car: 'blink' });
  /* capuchin */
  M('capuchin-cap', leafy, { nm: 'capuchin faces', desc: 'cream capuchin faces under a dark cap, grinning cheekily, canopy leaves falling; the chain runs off along the edge holding a stolen gold button up', fam: 'sparkle', gap: 14, g: 'm11-capuchin', mo: 'm11-grin', x: '-', car: 'custom', carDraw: carLoot });
  M('pocket-dip', plain, { nm: 'pocket dips', desc: 'a stitched pocket, a small dark hand dipping in and coming out with a glinting coin', fam: 'thrust', gap: 14, g: 'm11-pocket', mo: 'm11-dip', x: '-', car: 'blink' });
  M('fruit-bomb', plain, { nm: 'fruit bombs', desc: 'round orange fruit with a leaf lobbed in an arc, splatting with juice', fam: 'bash', gap: 14, g: 'm11-fruit', mo: 'm11-lob', x: '-', car: 'hop' });
  M('canopy-perch', leafy, { nm: 'canopy perches', desc: 'a leafy branch with a capuchin hanging under it by its curled tail, swinging', fam: 'leaf', gap: 16, g: 'm11-perch', mo: 'm11-swing', x: '-', car: 'flutter' });
  M('button-snatch', plain, { nm: 'snatched buttons', desc: 'shiny four-hole buttons on threads, a glint crossing them', fam: 'web', gap: 12, g: 'm11-button', mo: 'm11-glint', x: '-', car: 'thread' });
  /* wildcat */
  M('tabby-tail', grassy, { nm: 'tabby tails', desc: 'thick blunt grey tabby tails with dark rings and a black tip lashing side to side, grass fringe; the chain is the wildcat stalking low and pouncing', fam: 'slash', gap: 12, g: 'm11-tabbytail', mo: 'm11-lash', x: '-', car: 'custom', carDraw: carStalk });
  M('fur-bristle', plain, { nm: 'raised hackles', desc: 'an arched tabby back with the fur standing up in spikes', fam: 'thorn', gap: 14, g: 'm11-hackle', mo: 'm11-bristle', x: '-', car: 'train' });
  M('flat-ears', plain, { nm: 'flattened ears', desc: 'a wildcat face with amber eyes, ears going from up to flat back with a fanged hiss', fam: 'puff', gap: 14, g: 'm11-flatears', mo: 'm11-ears', x: '-', car: 'blink' });
  M('cat-claw', plain, { nm: 'cat claws', desc: 'a cat paw with hooked claws sprung, three curved slash marks trailing it', fam: 'slash', gap: 12, g: 'm11-claw', mo: 'm11-swipe', x: '-', car: 'comet' });
  /* caracal */
  M('ear-tuft', grassy, { nm: 'ear tufts', desc: 'caracal heads with tall ears ending in long black tufts, flicking in turn; the chain leaps in one high arc into a burst of feathers', fam: 'shock', gap: 14, g: 'm11-tuft', mo: 'm11-flick', x: '-', car: 'custom', carDraw: carLeap });
  M('bird-swat', plain, { nm: 'bird swats', desc: 'a small bird flying up and a tawny paw leaping to swat it, feathers bursting', fam: 'slash', gap: 14, g: 'm11-birdswat', mo: 'm11-swat', x: '-', car: 'hop' });
  M('dusk-rest', plain, { nm: 'dusk rests', desc: 'a caracal lying low in the grass before an orange half sun, ear tufts twitching', fam: 'mend', gap: 16, g: 'm11-duskrest', mo: 'm11-dusk', x: '-', car: 'flutter' });
  M('scrub-bush', plain, { nm: 'scrub bushes', desc: 'dry thorny scrub bushes with two black ear tufts poking up above them', fam: 'leaf', gap: 14, g: 'm11-scrub', mo: 'm11-rustle', x: 'dust', car: 'blink' });
  /* fishing cat */
  M('fish-scoop', wet, { nm: 'fish scoops', desc: 'a webbed paw scooping a silver fish out of the water with a splash, waterline rocking; the chain is the fishing cat wading with ripple rings at each step', fam: 'ripple', gap: 14, g: 'm11-scoop', mo: 'm11-scoop', x: '-', car: 'custom', carDraw: carWade });
  M('wet-coat', wet, { nm: 'wet coats', desc: 'a stocky spotted back half under water, drops beading and running off it', fam: 'shield', gap: 16, g: 'm11-wetcoat', mo: 'm11-bead', x: '-', car: 'train' });
  M('spray-shake', plain, { nm: 'shake sprays', desc: 'a spotted fur tuft whipping side to side, a widening ring of water drops flung off', fam: 'puff', gap: 14, g: 'm11-spray', mo: 'm11-shake', x: '-', car: 'cloud' });
  M('webbed-paw', plain, { nm: 'webbed paws', desc: 'webbed paws flicking outward, toes spread with water-blue webbing, claws hooked, a drop flicked off', fam: 'thrust', gap: 12, g: 'm11-webpaw', mo: 'm11-flickpaw', x: '-', car: 'comet' });
  /* jaguarundi */
  M('otter-cat', plain, { nm: 'otter cats', desc: 'long low plain-coated jaguarundis with small round ears and a long tail, slipping along like otters; the chain slides on with a dark streak behind', fam: 'slash', gap: 18, g: 'm11-otcat', mo: 'm11-slink', x: '-', car: 'custom', carDraw: carSlide });
  M('river-slip', wet, { nm: 'river slips', desc: 'a slick wet streak, a plain dark back slipping into the water and a splash ring opening', fam: 'ripple', gap: 14, g: 'm11-slip', mo: 'm11-slip', x: '-', car: 'rings' });
  M('grass-slip', grassy, { nm: 'grass slips', desc: 'tall bank grass parting to show a plain dark back slipping between, then closing', fam: 'leaf', gap: 14, g: 'm11-grass', mo: 'm11-part', x: '-', car: 'train' });
  M('shadow-cross', plain, { nm: 'unseen crossings', desc: 'a dark low silhouette sliding past, only two eyes glinting now and then', fam: 'shock', gap: 14, g: 'm11-shadow', mo: 'm11-ghost', x: '-', car: 'blink' });
  /* jaguar cubs */
  M('rosette-cub', grassy, { nm: 'jaguar cubs', desc: 'two round spotted jaguar cubs play-wrestling, swapping who is on top, paws batting; the chain is two cubs chasing each other', fam: 'bite', gap: 16, g: 'm11-jtwins', mo: 'm11-wrestle', x: '-', car: 'custom', carDraw: carChase });
  M('big-paw', plain, { nm: 'big cub paws', desc: 'oversized cub paws, a big pink pad and four toes spreading as they bat out, a rosette on the leg', fam: 'bash', gap: 14, g: 'm11-jpaw', mo: 'm11-bat', x: '-', car: 'hop' });
  M('tail-chase', plain, { nm: 'tail chases', desc: 'a spotted cub curled in a circle chasing its own stubby tail, spinning', fam: 'puff', gap: 14, g: 'm11-tailchase', mo: 'm11-spin', x: '-', car: 'loop' });
  M('bootlace', plain, { nm: 'bootlaces', desc: 'a white bootlace bow with dark aglets tugged loose by a spotted paw until it dangles', fam: 'web', gap: 14, g: 'm11-lace', mo: 'm11-tug', x: '-', car: 'thread' });
  /* bear cubs */
  M('cub-ball', plain, { nm: 'rolling cubs', desc: 'fluffy brown bear cubs curled into balls, ears, face and paws turning with the roll; the chain rolls downhill along the edge bouncing over bumps', fam: 'bash', gap: 16, g: 'm11-cubball', mo: 'm11-roll', x: 'dust', car: 'custom', carDraw: carCubRoll });
  M('honey-paw', plain, { nm: 'honey paws', desc: 'a paw pulled out of a honeycomb with golden honey dripping from it', fam: 'drip', gap: 14, g: 'm11-honeypaw', mo: 'm11-drip', x: '-', car: 'trail' });
  M('fern-hide', plain, { nm: 'fern hides', desc: 'two fern fronds parting to show a round cub head with round ears peeking between', fam: 'leaf', gap: 14, g: 'm11-fern', mo: 'm11-part', x: '-', car: 'train' });
  /* sun bear */
  M('sun-crescent', leafy, { nm: 'sun crescents', desc: 'black sun bear heads with a pale gold muzzle and the gold chest crescent glowing like a rising sun; the chain is the long pink tongue unrolling along the edge with a honey drop on the tip', fam: 'sparkle', gap: 16, g: 'm11-sunbear', mo: 'm11-glow', x: '-', car: 'custom', carDraw: carTongue });
  M('bark-claw', plain, { nm: 'bark-ripping claws', desc: 'a black paw with four long pale sickle claws ripping a strip of bark off', fam: 'thrust', gap: 12, g: 'm11-barkclaw', mo: 'm11-rip', x: '-', car: 'comet' });
  M('tree-hug', plain, { nm: 'tree hugs', desc: 'a tree trunk with a black bear pressed to it, arms wrapped round, peeking out one side then the other', fam: 'shield', gap: 16, g: 'm11-treehug', mo: 'm11-hug', x: '-', car: 'train' });
  M('snout-sniff', plain, { nm: 'snout sniffs', desc: 'a pale gold muzzle snuffling with scent lines curling in, termites scattering', fam: 'thorn', gap: 12, g: 'm11-sniff', mo: 'm11-snuffle', x: '-', car: 'zig' });
  M('long-tongue', plain, { nm: 'long tongues', desc: 'a black muzzle at a hole in the bark, the long pink tongue reaching in and out, honey on the tip', fam: 'drip', gap: 14, g: 'm11-tongue', mo: 'm11-lap', x: '-', car: 'trail' });
})();
