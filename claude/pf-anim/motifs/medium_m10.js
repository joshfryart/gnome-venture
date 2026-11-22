/* Motif module, medium batch m10 (badger-cub-gang, stink-badger, tunnel-mole, star-nosed-mole, mole-rat-gang, golden-mole, barn-rat, marsh-rat,
   pack-rat, bramble-pup-pack, thorn-jackal). TEMPLATE.md section 10.3.
   36 motifs, each with its own pixel glyph (ids prefixed m10-) and its own motion. Every creature of the batch has its own signature motif; eight of them
   bring their own chain effect (carDraw: a heap of badger cubs rolling, a stink badger leaving a reek trail, a mole run heaving up molehills, a conga of
   naked mole-rats, a golden mole swimming under the sand, a barn rat dropping grain, a wet marsh rat shaking off at each stop, a pack rat swapping its
   trinket, a jackal loping with paw prints). Two motifs are shared by relatives with their own palettes (burr clumps: badger cubs and bramble pups;
   spade claws: tunnel mole and star-nosed mole).
   Rats are drawn by one side-view routine (rat) and badger cubs by one front-face routine (cub), so the relatives share a look while each keeps its own
   picture: grain in the mouth, wet spiky fur, big ears and a stuffed cheek.
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation in the frame loops (scratch H.Q / H.G only).
   Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy
   default are untouched. */
(function () {
  /* fixed accent colours (not palette tones): 4 white, 5 dew, 6 dark soil, 7 soil, 8 grain gold, 9 straw, 10 stick brown, 11 leaf green, 12 blackberry,
     13 eye black, 14 pink, 15 tooth cream, 16 sand, 17 cactus green, 18 burr tan, 19 mud, 20 tongue red, 21 cap red, 22 coin gold, 23 silver, 24 plank,
     25 bramble cane, 26 velvet black-brown */
  var XC = [null, null, null, null, '#ffffff', '#cfeeff', '#4a3220', '#8a6a44', '#e8c860', '#d8c070', '#7a5030', '#62a040', '#4a2a5a', '#141418', '#f0a0a8',
    '#fff4d0', '#e8d8a8', '#5aa050', '#b08a40', '#6a5236', '#e05060', '#d0283c', '#f2d43a', '#d8dce4', '#a07848', '#8a3a40', '#3a2a26'];

  function face(tx, nx, ny) { return Math.abs(nx) > Math.abs(ny) ? (nx > 0 ? 1 : -1) : (tx >= 0 ? 1 : -1); }

  /* badger cub face, front view: white face, black stripes over the eyes to the ears, grey cheeks; s 0 small (5 wide) / 1 full (7 wide); m mouth open */
  function cub(c, K, x, y, s, C, A, m) {
    var w = s ? 3 : 2;
    K.bx(c, x - w, y - 2, w * 2 + 1, 4, K.WHITE); K.bx(c, x - w, y - 2, 1, 4, C); K.bx(c, x + w, y - 2, 1, 4, C);
    K.bx(c, x - w + 1, y - 3, 1, 4, A); K.bx(c, x + w - 1, y - 3, 1, 4, A); K.px(c, x - w, y - 3, A); K.px(c, x + w, y - 3, A);
    K.px(c, x - w + 1, y - 1, K.WHITE); K.px(c, x + w - 1, y - 1, K.WHITE);
    K.px(c, x, y + 1, A); K.bx(c, x - w + 1, y + 2, w * 2 - 1, 1, C);
    if (m) K.px(c, x, y + 2, XC[20]);
  }
  /* side-view rat facing fl: o = 0 plain, 1 grain in mouth, 2 wet spiky fur, 3 big ears + stuffed cheek; tail colour T; fr leg step */
  function rat(c, K, x, y, fl, fr, C, A, T, o) {
    var i, X, f = fr & 1;
    for (i = -3; i <= 2; i++) { X = x + fl * i; K.px(c, X, y - 1, C); K.px(c, X, y, C); if (i > -3) K.px(c, X, y - 2, o === 2 && (i & 1) ? A : C); }
    K.px(c, x + fl * 3, y - 1, C); K.px(c, x + fl * 3, y, C); K.px(c, x + fl * 4, y, C); K.px(c, x + fl * 5, y, T);
    K.px(c, x + fl * 3, y - 2, XC[13]);
    if (o === 3) { K.bx(c, x + fl * 1 - (fl < 0 ? 1 : 0), y - 5, 2, 2, C); K.px(c, x + fl * 1, y - 4, T); K.px(c, x + fl * 2, y - 3, C);
      K.px(c, x + fl * 3, y + 1, C); K.px(c, x + fl * 2, y + 1, C); }
    else { K.px(c, x + fl * 1, y - 3, C); K.px(c, x + fl * 2, y - 3, T); }
    if (o === 1) { K.px(c, x + fl * 6, y, XC[8]); K.px(c, x + fl * 6, y - 1, XC[8]); }
    if (o === 2) { K.px(c, x - fl * 1, y - 3, A); K.px(c, x + fl * 1, y - 3, A); K.px(c, x - fl * 2, y + 1, K.DEW); }
    K.px(c, x + fl * (1 + f), y + 1, A); K.px(c, x - fl * (2 - f), y + 1, A);
    for (i = 1; i <= 6; i++) K.px(c, x - fl * (3 + i), y + Math.round(Math.sin(i * .7 + fr * 1.4) * (i > 2 ? 1 : 0)) - (i > 4 ? 1 : 0), T);
  }
  /* side-view naked mole-rat (pink sausage, wrinkle lines, two incisors) */
  function molerat(c, K, x, y, fl, fr, C, A, Hi) {
    var i, X;
    for (i = -4; i <= 3; i++) { X = x + fl * i; K.px(c, X, y - 1, (i & 1) && i < 2 ? A : C); K.px(c, X, y, C); }
    K.px(c, x + fl * 4, y, C); K.px(c, x + fl * 5, y, Hi); K.px(c, x + fl * 5, y + 1, Hi); K.px(c, x + fl * 3, y - 2, C); K.px(c, x + fl * 3, y - 1, XC[13]);
    K.px(c, x + fl * (2 - (fr & 1)), y + 1, A); K.px(c, x - fl * (3 - (fr & 1)), y + 1, A); K.px(c, x - fl * 5, y, C); K.px(c, x - fl * 6, y + 1, C);
  }
  /* side-view rangy jackal, fr 0..3 lope gait; thorns along the back in Hi */
  function jackal(c, K, x, y, fl, fr, C, A, Hi) {
    var i, X, st = fr & 3, fw = st === 0 ? 2 : st === 1 ? 1 : st === 2 ? -1 : 0, bw = -fw;
    for (i = -3; i <= 3; i++) { X = x + fl * i; K.px(c, X, y - 1, i > -2 && i < 2 ? A : C); K.px(c, X, y, C); }
    K.px(c, x - fl * 1, y - 2, Hi); K.px(c, x + fl * 1, y - 2, Hi);
    K.px(c, x + fl * 4, y - 2, C); K.px(c, x + fl * 5, y - 2, C); K.px(c, x + fl * 4, y - 1, C); K.px(c, x + fl * 6, y - 1, C); K.px(c, x + fl * 7, y - 1, A);
    K.px(c, x + fl * 4, y - 3, C); K.px(c, x + fl * 4, y - 4, C); K.px(c, x + fl * 5, y - 4, A); K.px(c, x + fl * 5, y - 2, XC[13]);
    K.px(c, x + fl * (3 + fw), y + 1, C); K.px(c, x + fl * (3 + fw * 1.5), y + 2, A); K.px(c, x + fl * (2 - fw * .5), y + 1, C); K.px(c, x + fl * (2 - fw), y + 2, A);
    K.px(c, x - fl * (3 - bw), y + 1, C); K.px(c, x - fl * (3 - bw * 1.5), y + 2, A); K.px(c, x - fl * (2 + bw * .5), y + 1, C); K.px(c, x - fl * (2 + bw), y + 2, A);
    K.px(c, x - fl * 4, y - 1, C); K.px(c, x - fl * 5, y, C); K.px(c, x - fl * 6, y + (st & 1), C); K.px(c, x - fl * 7, y + (st & 1), A);
  }
  /* hooked burr ball (fixed burr tan, dark hooks), turning by fr */
  function burr(c, K, x, y, fr, A, r) {
    var i, a, X, Y;
    K.sq(c, x, y, 3, XC[18]); K.px(c, x - 1, y - 1, '#d8b870');
    for (i = 0; i < 8; i++) { a = i * .785 + fr * .39; X = x + Math.cos(a) * r; Y = y + Math.sin(a) * r; K.px(c, X, Y, XC[18]); K.px(c, X + Math.cos(a + 1.6), Y + Math.sin(a + 1.6), A); }
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
  function decoSoil(c, e, H, s0, len, ri, pp) {          /* diggers: three soil crumbs kicked up and falling back along the run */
    var k, u, Q = H.Q; if (e.p > .9) return;
    for (k = 0; k < 3; k++) { u = (pp * 1.3 + k * .33) % 1; e.P.atq(s0 + len * H.hash(e.seed + k * 5 + ri)); H.px(c, Q.x + Q.nx * (3 + 5 * u), Q.y + Q.ny * (3 + 5 * u) - Math.sin(u * Math.PI) * 6, k & 1 ? XC[7] : XC[6]); }
  }
  function decoWet(c, e, H, s0, len, ri, pp) {           /* wetland: two waterline dashes rock under the run */
    var k, u, Q = H.Q, i, X, Y; if (e.p > .92) return;
    for (k = 0; k < 2; k++) { u = (pp * 1.1 + k * .5) % 1; e.P.atq(s0 + len * (k + .5) / 2); X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3 + 5 + Math.round(Math.sin(u * 6.28));
      for (i = -2; i <= 2; i++) if ((i + k) & 1) H.px(c, X + i, Y, i === 1 ? H.WHITE : H.DEW); }
  }
  function decoSand(c, e, H, s0, len, ri, pp) {          /* desert: a sand ripple line just outside the run, drifting */
    var s, Q = H.Q; if (e.p > .9) return;
    for (s = (pp * 6) % 4; s < len; s += 4) { e.P.atq(s0 + s); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, XC[16]); }
  }

  /* ---------- glyphs (tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step; fr from the motion) ---------- */
  /* badger cub gang */
  PFA.glyph('m10-cub', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a badger cub's striped face, jostling, chirring with the mouth open on fr 1 */
    cub(c, K, x, y, z > 0 ? 1 : 0, C, A, fr & 1);
    if (fr & 1) { K.px(c, x - 4, y - 4, Hi); K.px(c, x + 4, y - 4, Hi); }
  });
  PFA.glyph('m10-cubpile', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* three cubs in a wobbling heap, the top one tipping over (fr 0..3) */
    var t = (fr & 3) === 1 ? 1 : (fr & 3) === 3 ? -1 : 0;
    cub(c, K, x - 3, y + 3, 0, C, A, 0); cub(c, K, x + 3, y + 3, 0, C, A, fr === 2);
    cub(c, K, x + t, y - 3 + (fr === 2 ? 1 : 0), 0, C, A, 0);
    if (t) { K.px(c, x + t * 5, y - 6, Hi); K.px(c, x + t * 6, y - 5, Hi); }
  });
  PFA.glyph('m10-sett', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a dug-in sett mouth: a soil arch with a cub face peering out, claws on the rim */
    var i;
    for (i = -5; i <= 5; i++) { K.px(c, x + i, y + 3, XC[7]); if (Math.abs(i) > 2) K.px(c, x + i, y + 2 - (Math.abs(i) === 3 ? 2 : Math.abs(i) === 4 ? 1 : 0), XC[6]); }
    K.bx(c, x - 2, y - 3, 5, 1, XC[6]); K.bx(c, x - 3, y + 2, 7, 1, XC[13]);
    cub(c, K, x, y + (fr ? 0 : 1), 0, C, A, 0);
    K.px(c, x - 3, y + 3, K.WHITE); K.px(c, x - 2, y + 3, K.WHITE); K.px(c, x + 2, y + 3, K.WHITE); K.px(c, x + 3, y + 3, K.WHITE);
  });
  PFA.glyph('m10-burr', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a hooked burr ball snagged with a tuft of fur, hooks turning */
    burr(c, K, x, y, fr, A, 3 + (z > 1 ? 1 : 0));
    K.px(c, x - nx * 3 + tx, y - ny * 3 + ty, C); K.px(c, x - nx * 4, y - ny * 4, C); K.px(c, x - nx * 4 - tx, y - ny * 4 - ty, C);
  });
  /* stink badger */
  PFA.glyph('m10-stink', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a dark stink badger side-on, white stripe down the back; rump up (fr 1) then a musk jet sprays off the rear (fr 2) */
    var fl = face(tx, nx, ny), i, X, u = fr ? 1 : 0;
    for (i = -4; i <= 3; i++) { X = x + fl * i; K.px(c, X, y, C); K.px(c, X, y + 1, A); K.px(c, X, y - 1 - (i < -1 ? u : 0), i > -4 ? K.WHITE : C); if (i < -1 && u) K.px(c, X, y - 1, C); }
    K.px(c, x + fl * 4, y, C); K.px(c, x + fl * 5, y + 1, C); K.px(c, x + fl * 4, y - 1, K.WHITE); K.px(c, x + fl * 4, y + 1, XC[13]); K.px(c, x + fl * 6, y + 1, XC[14]);
    K.px(c, x + fl * (2 + (fr & 1)), y + 2, A); K.px(c, x - fl * (3 - (fr & 1)), y + 2, A);
    if (fr === 2) for (i = 1; i <= 4; i++) { K.px(c, x - fl * (4 + i), y - 2 - (i >> 1), Hi); if (i > 2) K.px(c, x - fl * (4 + i), y - 1 - i, Hi); }
  });
  PFA.glyph('m10-reek', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* three wavy stench lines rising in yellow-green, a fly circling them */
    var i, j, a;
    for (j = -1; j <= 1; j++) for (i = 0; i < 6 + z; i++) K.px(c, x + j * 3 + Math.round(Math.sin(i * .9 + fr * 1.57 + j) * 1), y + 3 - i, i > 4 ? C : Hi);
    a = fr * 1.57; K.px(c, x + Math.cos(a) * 5, y - 2 + Math.sin(a) * 2, XC[13]); K.px(c, x + Math.cos(a) * 5, y - 3 + Math.sin(a) * 2, K.WHITE);
  });
  PFA.glyph('m10-snore', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a stink badger curled asleep, white stripe curving round, a Z drifting up (fr = which Z) */
    var i, a, X, Y;
    for (i = 0; i < 14; i++) { a = i * .45; K.px(c, x + Math.cos(a) * 3.5, y + Math.sin(a) * 2.5, i > 9 ? A : C); }
    for (i = 1; i < 9; i++) { a = i * .45 - .2; K.px(c, x + Math.cos(a) * 2.2, y + Math.sin(a) * 1.4, K.WHITE); }
    K.bx(c, x - 1, y - 1, 3, 2, C); K.px(c, x + 3, y + 1, XC[14]);
    X = x + 3 + (fr & 1); Y = y - 5 - fr * 2; K.bx(c, X, Y, 3, 1, Hi); K.px(c, X + 1, Y + 1, Hi); K.bx(c, X, Y + 2, 3, 1, Hi);
  });
  /* tunnel mole */
  PFA.glyph('m10-molehill', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a molehill heaving: fr 0 soil only, 1 a pink snout pushes up, 2 the velvet head and two pink spade hands out */
    var i, w = 4 + (z > 1 ? 1 : 0);
    for (i = -w; i <= w; i++) { K.px(c, x + i, y + 2, XC[6]); if (Math.abs(i) < w) K.px(c, x + i, y + 1, (i & 1) ? XC[7] : XC[6]); if (Math.abs(i) < w - 2) K.px(c, x + i, y, XC[7]); }
    if (fr === 0) { K.px(c, x, y - 1, XC[7]); K.px(c, x - 1, y - 2, XC[6]); return; }
    K.bx(c, x - 1, y - 1 - fr, 3, 1 + fr, C); K.px(c, x, y - 2 - fr, Hi); K.px(c, x - 1, y - 1 - fr, A);
    if (fr === 2) { K.px(c, x - 3, y - 2, Hi); K.px(c, x - 4, y - 3, Hi); K.px(c, x - 3, y - 3, K.WHITE); K.px(c, x + 3, y - 2, Hi); K.px(c, x + 4, y - 3, Hi); K.px(c, x + 3, y - 3, K.WHITE);
      K.px(c, x - 5, y - 1, XC[7]); K.px(c, x + 5, y - 2, XC[7]); }
  });
  PFA.glyph('m10-spade', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a big pink spade hand raking outward, five white claws, soil flicked behind */
    var i, L = 2 + (fr & 1), X, Y;
    for (i = -2; i <= 2; i++) { X = x + tx * i; Y = y + ty * i; K.px(c, X, Y, Hi); K.px(c, X - nx, Y - ny, Hi); K.px(c, X - nx * 2, Y - ny * 2, (i === 0) ? C : Hi);
      K.px(c, X + nx * L, Y + ny * L, K.WHITE); if (L > 2) K.px(c, X + nx * (L - 1), Y + ny * (L - 1), K.WHITE); else K.px(c, X + nx, Y + ny, Hi); }
    K.px(c, x - nx * 3, y - ny * 3, C); K.px(c, x - nx * 3 + tx, y - ny * 3 + ty, C); K.px(c, x - nx * 3 - tx, y - ny * 3 - ty, C);
    if (fr & 1) { K.px(c, x - nx * 2 + tx * 4, y - ny * 2 + ty * 4, XC[7]); K.px(c, x - nx * 3 - tx * 4, y - ny * 3 - ty * 4, XC[6]); }
  });
  PFA.glyph('m10-clod', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a lump of soil flung in an arc, crumbling (fr 0..3 shape), a root thread hanging off */
    var s = 2 + (z > 0 ? 1 : 0);
    K.bx(c, x - 1, y - 1, s, s, XC[7]); K.px(c, x - 1, y - 1, XC[16]); K.px(c, x + s - 2, y + s - 2, XC[6]);
    if (fr & 1) K.px(c, x + s - 1, y, XC[6]); else K.px(c, x - 2, y, XC[7]);
    if (fr & 2) { K.px(c, x - 3, y + 2, XC[6]); K.px(c, x + 2, y + 3, XC[7]); } else { K.px(c, x, y + s, A); K.px(c, x + 1, y + s + 1, A); }
  });
  /* star-nosed mole */
  PFA.glyph('m10-starnose', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* the pink star of 22 feelers round a dark snout, twitching open and shut very fast (fr 0..2) */
    var i, a, r = 2 + fr * .7 + (z > 1 ? .7 : 0), X = x + nx * 2, Y = y + ny * 2;
    K.sq(c, x - nx, y - ny, 3, XC[26]); K.px(c, x - nx * 2 + tx, y - ny * 2 + ty, XC[26]); K.px(c, x - nx * 2 - tx, y - ny * 2 - ty, XC[26]);
    for (i = 0; i < 11; i++) { a = i * .571 + (fr & 1) * .28; K.px(c, X + Math.cos(a) * r, Y + Math.sin(a) * r, C); if (i & 1) K.px(c, X + Math.cos(a) * (r - 1), Y + Math.sin(a) * (r - 1), Hi); }
    K.px(c, X, Y, XC[26]);
  });
  PFA.glyph('m10-bubble', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the star nose underwater blowing a bubble (fr 1 big) and sniffing it back in (fr 2 small) */
    var r = fr === 1 ? 3 : fr === 2 ? 1 : 2, X = x + nx * (3 + r), Y = y + ny * (3 + r);
    K.px(c, x, y, C); K.px(c, x + tx, y + ty, C); K.px(c, x - tx, y - ty, C); K.px(c, x + nx, y + ny, C); K.px(c, x - nx, y - ny, XC[26]); K.px(c, x - nx * 2, y - ny * 2, XC[26]);
    K.px(c, x + tx * 2 + nx, y + ty * 2 + ny, Hi); K.px(c, x - tx * 2 + nx, y - ty * 2 + ny, Hi);
    K.ringpx(c, X, Y, r, K.DEW); K.px(c, X - 1, Y - 1, K.WHITE);
  });
  /* mole-rat gang */
  PFA.glyph('m10-teeth', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a wrinkled pink mole-rat face, front view, with two huge cream incisors out over the lips, chattering */
    var g = fr & 1;
    K.bx(c, x - 3, y - 3, 7, 5, C); K.bx(c, x - 2, y - 4, 5, 1, C);
    K.bx(c, x - 2, y - 2, 5, 1, A); K.px(c, x - 3, y, A); K.px(c, x + 3, y, A); K.px(c, x - 2, y - 3, XC[13]); K.px(c, x + 2, y - 3, XC[13]);
    K.bx(c, x - 1, y + 2 - g, 1, 3, Hi); K.bx(c, x + 1, y + 2 - g, 1, 3, Hi); K.px(c, x, y + 1, A);
    K.bx(c, x - 1, y + 5 + g, 3, 1, Hi);
    if (g) { K.px(c, x - 3, y + 5, Hi); K.px(c, x + 3, y + 5, Hi); }
  });
  PFA.glyph('m10-molerat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* chain body: a naked mole-rat side-on, nose to tail */
    molerat(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi);
  });
  PFA.glyph('m10-heap', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the colony in a warm heap: three pink mole-rats piled, the top one shuffling round */
    molerat(c, K, x - 1, y + 2, 1, 0, C, A, Hi); molerat(c, K, x + 1, y - 1, -1, fr, C, A, Hi);
    molerat(c, K, x + (fr === 1 ? 1 : fr === 2 ? -1 : 0), y - 4, (fr & 1) ? 1 : -1, fr, C, A, Hi);
  });
  PFA.glyph('m10-hole', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a tunnel hole with a pink snout and incisors poking out and chirp marks rising (fr 0..2) */
    var i;
    K.bx(c, x - 3, y, 7, 3, XC[6]); K.bx(c, x - 2, y + 1, 5, 2, XC[13]); K.px(c, x - 4, y + 2, XC[7]); K.px(c, x + 4, y + 2, XC[7]);
    if (fr) { K.bx(c, x - 1, y - fr + 1, 3, fr, C); K.px(c, x, y - fr, A); K.px(c, x - 1, y + 2 - fr, Hi); K.px(c, x + 1, y + 2 - fr, Hi); }
    for (i = 0; i < fr; i++) { K.px(c, x - 3 + i * 6, y - 4 - i * 2, Hi); K.px(c, x - 2 + i * 6, y - 3 - i * 2, Hi); K.px(c, x - 1 + i * 6, y - 4 - i * 2, Hi); }
  });
  /* golden mole */
  PFA.glyph('m10-goldmole', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* an eyeless gold mole half sunk in sand, leathery nose pad in front, an iridescent sheen sweeping over its back (fr 0..3) */
    var fl = face(tx, nx, ny), i, X;
    for (i = -3; i <= 3; i++) { X = x + fl * i; K.px(c, X, y, C); if (Math.abs(i) < 3) K.px(c, X, y - 1, C); if (Math.abs(i) < 2) K.px(c, X, y - 2, C); }
    K.px(c, x + fl * (-2 + fr), y - 1, Hi); K.px(c, x + fl * (-1 + fr), y - 2 + (fr === 3 ? 1 : 0), K.WHITE);
    K.px(c, x + fl * 4, y, XC[16]); K.px(c, x + fl * 4, y - 1, XC[16]); K.px(c, x + fl * 5, y, A);
    for (i = -5; i <= 5; i++) K.px(c, x + i, y + 1, (i + fr) % 3 ? XC[16] : A);
  });
  PFA.glyph('m10-goldcurl', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* the golden mole curled in a velvet ball, a rainbow-gold sheen running round it, a sparkle */
    var i, a;
    for (i = 0; i < 12; i++) { a = i * .524; K.px(c, x + Math.cos(a) * 3, y + Math.sin(a) * 2.5, (i === fr * 3 || i === fr * 3 + 1) ? Hi : C); }
    K.bx(c, x - 2, y - 1, 5, 3, C); K.px(c, x + 1, y, XC[16]); K.px(c, x + 2, y, A);
    K.px(c, x - 1 + (fr & 1), y - 1, K.WHITE);
    if (fr === 2) K.plus(c, x + 4, y - 4, 1, 1, Hi);
  });
  PFA.glyph('m10-lunge', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a blind gold wedge head lunging nose-pad first, vibration arcs it feels ahead (fr 1 / 2) */
    var i, X, Y, d;
    for (i = 0; i < 4; i++) { X = x - nx * i; Y = y - ny * i; K.px(c, X, Y, C); K.px(c, X + tx * Math.min(2, i), Y + ty * Math.min(2, i), C); K.px(c, X - tx * Math.min(2, i), Y - ty * Math.min(2, i), C); }
    K.px(c, x + nx, y + ny, XC[16]); K.px(c, x + nx + tx, y + ny + ty, A); K.px(c, x - nx * 2 + tx, y - ny * 2 + ty, Hi);
    if (fr) for (d = 0; d < fr; d++) for (i = -2; i <= 2; i++) K.px(c, x + nx * (4 + d * 3) + tx * i - nx * (Math.abs(i) >> 1), y + ny * (4 + d * 3) + ty * i - ny * (Math.abs(i) >> 1), d ? Hi : K.WHITE);
  });
  /* barn rat */
  PFA.glyph('m10-grainrat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a brown barn rat scurrying, long pink tail, a grain kernel in its teeth */
    rat(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi, 1);
  });
  PFA.glyph('m10-kernel', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a gold grain kernel nipped: whole, a bite notch, then split with chaff flying (fr 0..2) */
    K.bx(c, x - 1, y - 2, 3, 4, XC[8]); K.px(c, x, y - 3, XC[8]); K.px(c, x, y + 2, XC[9]); K.px(c, x - 1, y - 1, K.WHITE); K.px(c, x + 1, y + 1, XC[10]);
    if (fr >= 1) { K.px(c, x + 1, y - 2, A); K.px(c, x + 1, y - 1, A); }
    if (fr === 2) { K.px(c, x - 3, y - 3, XC[9]); K.px(c, x + 3, y - 4, XC[9]); K.px(c, x + 4, y - 1, C); }
  });
  PFA.glyph('m10-squeeze', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* two barn planks with a gap; the rat flattens through it (fr 0 nose in, 1 squeezed thin, 2 out the other side, tail last) */
    var i;
    for (i = -4; i <= 4; i++) { K.px(c, x - 2, y + i, XC[24]); K.px(c, x - 3, y + i, (i % 3) ? XC[24] : XC[10]); K.px(c, x + 2, y + i, XC[24]); K.px(c, x + 3, y + i, (i % 3) ? XC[10] : XC[24]); }
    if (fr === 0) { K.px(c, x - 4, y, C); K.px(c, x - 5, y, C); K.px(c, x - 1, y, C); K.px(c, x - 6, y - 1, C); }
    else if (fr === 1) { for (i = -4; i <= 4; i++) K.px(c, x + i, y, Math.abs(i) < 2 ? C : (i > 0 ? C : Hi)); K.px(c, x + 4, y - 1, XC[13]); }
    else { K.bx(c, x + 4, y - 1, 3, 2, C); K.px(c, x + 7, y, C); K.px(c, x + 6, y - 2, XC[13]); for (i = -1; i <= 3; i++) K.px(c, x - i, y + 1, Hi); }
  });
  PFA.glyph('m10-hay', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a little haystack, straws sticking out, a pink rat tail swishing from under it */
    var i;
    for (i = -4; i <= 4; i++) { K.px(c, x + i, y + 2, XC[9]); if (Math.abs(i) < 4) K.px(c, x + i, y + 1, (i & 1) ? XC[9] : XC[8]); if (Math.abs(i) < 3) K.px(c, x + i, y, XC[9]); if (Math.abs(i) < 2) K.px(c, x + i, y - 1, XC[8]); }
    K.px(c, x, y - 2, XC[9]); K.px(c, x - 3, y - 2, XC[9]); K.px(c, x + 2, y - 3, XC[8]); K.px(c, x + 4, y - 1, XC[9]);
    for (i = 1; i <= 3; i++) K.px(c, x + 4 + i, y + 2 - ((fr + i) & 1), Hi);
  });
  /* marsh rat */
  PFA.glyph('m10-wetrat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a shaggy wet marsh rat, blunt snout, fur in dark spikes, shaking off a spray of drops (fr 2 / 3) */
    var fl = face(tx, nx, ny);
    rat(c, K, x, y, fl, fr, C, A, XC[14], 2);
    if (fr >= 2) { K.px(c, x - 3, y - 5, Hi); K.px(c, x + 2, y - 6, K.WHITE); K.px(c, x - fl * 6, y - 3, Hi); K.px(c, x + fl * 5, y - 4, Hi); K.px(c, x + (fr & 1 ? 4 : -4), y - 3, K.DEW); }
  });
  PFA.glyph('m10-bank', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a muddy bank with a round burrow at the waterline, water lapping (fr 0..2), eyes glinting inside on fr 1 */
    var i;
    for (i = -5; i <= 5; i++) { K.px(c, x + i, y - 1 + (i < 0 ? 0 : (i > 3 ? -1 : 0)), XC[19]); K.px(c, x + i, y, XC[19]); }
    K.bx(c, x - 1, y - 1, 3, 2, XC[13]); K.px(c, x - 2, y - 2, XC[11]); K.px(c, x + 3, y - 3, XC[11]);
    if (fr === 1) { K.px(c, x - 1, y - 1, Hi); K.px(c, x + 1, y - 1, Hi); }
    for (i = -5; i <= 5; i++) if (((i + fr) % 3) !== 0) K.px(c, x + i, y + 1, i === fr * 2 - 2 ? K.WHITE : K.DEW);
  });
  PFA.glyph('m10-reedgnaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* two reed stems cut at a slant by gnawing, straw chips flying off, the cut top falling over on fr 2 */
    var i;
    for (i = 0; i < 7; i++) { K.px(c, x - 2 + tx * 0, y - i + 3, XC[11]); }
    for (i = 0; i < 3; i++) K.px(c, x + 2, y + 3 - i, XC[11]);
    K.px(c, x + 2, y, XC[9]); K.px(c, x + 3, y, XC[9]);
    if (fr < 2) for (i = 0; i < 4; i++) K.px(c, x + 2, y - 1 - i, XC[11]);
    else for (i = 0; i < 4; i++) K.px(c, x + 3 + i, y - 1 - (i >> 1), XC[11]);
    if (fr & 1) { K.px(c, x + 5, y - 2, XC[9]); K.px(c, x + 4, y + 2, XC[9]); K.px(c, x - 4, y - 1, XC[9]); }
    K.px(c, x - 2, y - 4, XC[10]); K.px(c, x - 2, y - 5, XC[10]);
  });
  PFA.glyph('m10-reedbend', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* three reeds with brown cattail heads leaning outward as they are shoved over (fr 0..3 lean) */
    var k, i, b = fr * .35, X, Y;
    for (k = -1; k <= 1; k++) for (i = 0; i < 7; i++) { X = x + tx * k * 3 + nx * i + tx * Math.round(b * i * i / 7 * (k === 0 ? 1 : k)); Y = y + ty * k * 3 + ny * i + ty * Math.round(b * i * i / 7 * (k === 0 ? 1 : k));
      K.px(c, X, Y, i > 4 ? XC[10] : XC[11]); if (i > 4) K.px(c, X + tx, Y + ty, XC[10]); }
    if (fr === 3) { K.px(c, x + nx * 2 + tx * 5, y + ny * 2 + ty * 5, Hi); K.px(c, x + nx * 3 - tx * 5, y + ny * 3 - ty * 5, Hi); }
  });
  /* pack rat */
  PFA.glyph('m10-packrat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a big-eared pack rat with a stuffed cheek, carrying a shiny trinket in its mouth that glints */
    var fl = face(tx, nx, ny);
    rat(c, K, x, y, fl, fr, C, A, XC[14], 3);
    K.px(c, x + fl * 6, y + 1, Hi); K.px(c, x + fl * 7, y + 1, Hi); K.px(c, x + fl * 6, y + 2, XC[22]);
    if (fr & 2) K.plus(c, x + fl * 7, y - 1, 1, 1, K.WHITE);
  });
  PFA.glyph('m10-trinket', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* one stolen trinket (fr & 3: coin, key, bottle cap, spoon), a glint on fr & 4 */
    var t = fr & 3;
    if (t === 0) { K.sq(c, x, y, 3, XC[22]); K.px(c, x - 1, y - 2, XC[22]); K.px(c, x + 1, y + 2, XC[22]); K.px(c, x, y, '#b89020'); }
    else if (t === 1) { K.ringpx(c, x - 2, y, 1, XC[23]); K.bx(c, x, y, 4, 1, XC[23]); K.px(c, x + 2, y + 1, XC[23]); K.px(c, x + 3, y + 1, XC[23]); }
    else if (t === 2) { K.bx(c, x - 2, y - 1, 5, 2, XC[21]); K.px(c, x - 2, y + 1, XC[21]); K.px(c, x, y + 1, XC[21]); K.px(c, x + 2, y + 1, XC[21]); K.px(c, x - 1, y - 1, K.WHITE); }
    else { K.bx(c, x - 3, y, 4, 1, XC[23]); K.bx(c, x + 1, y - 1, 2, 3, XC[23]); K.px(c, x + 1, y - 1, K.WHITE); }
    if (fr & 4) K.plus(c, x + 2, y - 3, 1, 1, K.WHITE);
  });
  PFA.glyph('m10-cheeks', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a pack rat face, front view, big round ears; cheeks stuffing out wider each frame (fr 0..2), whiskers */
    var w = 2 + fr;
    K.bx(c, x - 4, y - 6, 3, 3, C); K.bx(c, x + 2, y - 6, 3, 3, C); K.px(c, x - 3, y - 5, XC[14]); K.px(c, x + 3, y - 5, XC[14]);
    K.bx(c, x - 2, y - 3, 5, 3, C); K.bx(c, x - w, y, w * 2 + 1, 2 + (fr > 1 ? 1 : 0), C); K.px(c, x - 1, y - 2, XC[13]); K.px(c, x + 1, y - 2, XC[13]);
    K.px(c, x, y - 1, XC[14]); K.px(c, x - w, y, Hi); K.px(c, x + w, y, Hi);
    K.px(c, x - w - 1, y - 1, A); K.px(c, x - w - 2, y - 2, A); K.px(c, x + w + 1, y - 1, A); K.px(c, x + w + 2, y - 2, A);
  });
  PFA.glyph('m10-midden', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a packrat midden: a criss-cross heap of sticks with a cactus bit and a shiny thing on top, the glint wandering (fr 0..3) */
    var i;
    for (i = -5; i <= 5; i++) { K.px(c, x + i, y + 2 - Math.round(i * .3), XC[10]); K.px(c, x + i, y + 2 + Math.round(i * .3), XC[10]); if (Math.abs(i) < 4) K.px(c, x + i, y + Math.round(i * .5) - 1, A); }
    K.px(c, x - 3, y - 2, XC[17]); K.px(c, x - 3, y - 3, XC[17]); K.px(c, x - 4, y - 3, K.WHITE);
    K.px(c, x + 1, y - 3, XC[22]); K.px(c, x + 2, y - 3, XC[23]);
    K.px(c, x - 4 + fr * 3, y - 4 - (fr & 1), K.WHITE); K.px(c, x - 4 + fr * 3, y - 5 - (fr & 1), Hi);
  });
  /* bramble pup pack */
  PFA.glyph('m10-burrpup', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a fluffy grey pup curled in a ball, burrs stuck all over it, tumbling (the burrs go round with fr 0..3) */
    var i, a, r = 3 + (z > 1 ? 1 : 0);
    K.sq(c, x, y, r * 2 - 1, C); K.px(c, x - r + 1, y - r, A); K.px(c, x + r - 1, y - r, A); K.px(c, x - r, y - r + 1, C); K.px(c, x + r, y - r + 1, C);
    if (!(fr & 1)) { K.px(c, x - 1, y - 1, XC[13]); K.px(c, x + 1, y - 1, XC[13]); K.px(c, x, y + 1, A); }
    for (i = 0; i < 3; i++) { a = i * 2.09 + fr * 1.57; K.px(c, x + Math.cos(a) * r, y + Math.sin(a) * r, Hi); K.px(c, x + Math.cos(a) * (r + 1), y + Math.sin(a) * (r + 1), A); }
  });
  PFA.glyph('m10-bramble', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a bramble cane arching over the edge, thorns and blackberries; pup eyes blink underneath on fr 1 / 2 */
    var i, Y;
    for (i = -5; i <= 5; i++) { Y = y - 3 + Math.round(i * i / 9); K.px(c, x + i, Y, XC[25]); if ((i & 3) === 1) K.px(c, x + i, Y - 1, K.WHITE); }
    K.px(c, x - 4, y - 3, XC[11]); K.px(c, x + 3, y - 4, XC[11]); K.px(c, x + 4, y - 4, XC[11]);
    K.sq(c, x - 2, y - 1, 2, XC[12]); K.sq(c, x + 3, y, 2, XC[12]); K.px(c, x - 2, y - 2, '#a070b0');
    if (fr === 1 || fr === 2) { K.px(c, x - 1, y + 1, Hi); K.px(c, x + 1, y + 1, Hi); K.px(c, x - 1 + (fr - 1), y + 1, XC[13]); K.px(c, x + 1 + (fr - 1), y + 1, XC[13]); K.px(c, x, y + 2, C); }
  });
  /* thorn jackal */
  PFA.glyph('m10-jackal', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a rangy sandy jackal loping, tall ears, dark saddle, pale thorns caught along the back */
    jackal(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi);
  });
  PFA.glyph('m10-lick', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a jackal muzzle side-on licking: the pink tongue laps out and back (fr 0..3), scrub leaf bits lift off */
    var fl = face(tx, nx, ny), i, L = fr === 0 ? 0 : fr === 3 ? 1 : fr + 1;
    for (i = -2; i <= 2; i++) { K.px(c, x + fl * i, y - 1, C); K.px(c, x + fl * i, y, i > 0 ? A : C); }
    K.px(c, x + fl * 3, y - 1, C); K.px(c, x + fl * 4, y - 1, XC[13]); K.px(c, x - fl * 1, y - 3, C); K.px(c, x - fl * 1, y - 2, C); K.px(c, x, y - 2, XC[13]);
    for (i = 0; i < L; i++) K.px(c, x + fl * (3 + i), y + 1 + (i >> 1), XC[14]);
    if (fr >= 2) { K.px(c, x + fl * 2, y - 5, XC[11]); K.px(c, x - fl * 2, y - 6 - (fr & 1), XC[11]); K.px(c, x + fl * 1, y - 7, Hi); }
  });
  PFA.glyph('m10-thornjaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a long narrow jackal jaw, thorn-pale teeth, open (fr 0), snapping (fr 1), shut with a crack spark (fr 2) */
    var o = fr === 0 ? 2 : fr === 1 ? 1 : 0, L = 6 + z, i, X, Y;
    for (i = 0; i < L; i++) { X = x + nx * (i - 2); Y = y + ny * (i - 2);
      K.px(c, X + tx * (o + 1), Y + ty * (o + 1), C); K.px(c, X - tx * (o + 1), Y - ty * (o + 1), C);
      if (i > 1 && (i & 1)) { K.px(c, X + tx * o, Y + ty * o, Hi); K.px(c, X - tx * o, Y - ty * o, Hi); } }
    K.px(c, x - nx * 2 + tx * (o + 2), y - ny * 2 + ty * (o + 2), A); K.px(c, x + nx * (L - 2) + tx * (o + 1), y + ny * (L - 2) + ty * (o + 1), A);
    if (fr === 2) { X = x + nx * (L - 1); Y = y + ny * (L - 1); K.px(c, X + nx, Y + ny, K.WHITE); K.px(c, X + tx * 2, Y + ty * 2, Hi); K.px(c, X - tx * 2, Y - ty * 2, Hi); }
  });
  PFA.glyph('m10-cactus', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a prickly-pear pad with spine dots; the jackal's ear tips show over it, dodging side to side (fr 0..3) */
    var i, e = (fr & 2) ? 2 : -2;
    K.bx(c, x - 2, y - 3, 5, 7, XC[17]); K.bx(c, x - 3, y - 2, 7, 5, XC[17]); K.px(c, x - 1, y - 2, '#8ac870');
    for (i = 0; i < 5; i++) K.px(c, x - 2 + ((i * 3) % 5), y - 2 + ((i * 2) % 5), K.WHITE);
    K.px(c, x + 1, y - 4, XC[21]); K.px(c, x + 1, y - 5, XC[21]);
    K.px(c, x + e - 1, y - 5, C); K.px(c, x + e - 1, y - 6, C); K.px(c, x + e + 1, y - 5, C); K.px(c, x + e + 1, y - 6, C); K.px(c, x + e - 1, y - 7, A); K.px(c, x + e + 1, y - 7, A);
  });
  PFA.glyph('m10-sitjackal', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a jackal sitting tall and still, watching; the eyes open (fr 1) and close slowly (fr 0), tail wrapped round the feet */
    K.bx(c, x - 1, y - 4, 3, 3, C); K.px(c, x - 1, y - 6, C); K.px(c, x - 1, y - 5, C); K.px(c, x + 1, y - 6, C); K.px(c, x + 1, y - 5, C); K.px(c, x - 1, y - 7, A); K.px(c, x + 1, y - 7, A);
    K.px(c, x, y - 2, C); K.px(c, x, y - 1, A);
    K.bx(c, x - 2, y - 1, 5, 4, C); K.bx(c, x - 1, y - 1, 3, 2, A); K.px(c, x - 1, y + 3, A); K.px(c, x + 1, y + 3, A);
    K.px(c, x - 3, y + 3, C); K.px(c, x - 4, y + 2, C); K.px(c, x - 4, y + 3, A);
    if (fr) { K.px(c, x - 1, y - 3, Hi); K.px(c, x + 1, y - 3, Hi); } else { K.px(c, x - 1, y - 3, A); K.px(c, x + 1, y - 3, A); }
  });

  /* ---------- motions (mutate the scratch G; pp = time x speed) ---------- */
  PFA.motion('m10-scrum', function (G, pp, k) { G.t += Math.sin(pp * 14 + k * 2) * 1.5; G.up += Math.abs(Math.sin(pp * 9 + k)) * 1.5; G.fr = (Math.floor(pp * 8) + k) & 1; });
  PFA.motion('m10-heap', function (G, pp, k) { G.fr = (Math.floor(pp * 7) + k) & 3; G.up += (G.fr & 1); });
  PFA.motion('m10-peer', function (G, pp, k, ph) { G.fr = ((pp * 2 + ph) % 1) < .35 ? 0 : 1; });
  PFA.motion('m10-burrspin', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; });
  PFA.motion('m10-rump', function (G, pp, k, ph) { var w = (pp * 1.7 + ph) % 1; G.fr = w < .45 ? 0 : w < .6 ? 1 : 2; G.s += pp * .05; });
  PFA.motion('m10-reek', function (G, pp, k) { G.t += Math.sin(pp * 4 + k) * 1.5; G.up += pp * 3; G.fr = (Math.floor(pp * 8) + k) & 3; });
  PFA.motion('m10-snore', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 3 + ph * 3) + k) % 3; G.up += Math.sin(pp * 4 + k) * .8; });
  PFA.motion('m10-heave', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; G.fr = w < .3 ? 0 : w < .55 ? 1 : 2; G.up += G.fr ? 0 : Math.round(Math.sin(pp * 20) * .6); });
  PFA.motion('m10-rake', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 1; G.d += G.fr; });
  PFA.motion('m10-fling', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; });
  PFA.motion('m10-feel', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 20 + ph * 7) + k) % 3; G.t += ((Math.floor(pp * 16) + k) & 1) ? .6 : -.6; });
  PFA.motion('m10-sniff', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 2 + ph) % 1) * 3)); });
  PFA.motion('m10-chatter', function (G, pp, k) { G.fr = (Math.floor(pp * 14) + k) & 1; });
  PFA.motion('m10-huddle', function (G, pp, k) { G.fr = (Math.floor(pp * 4) + k) % 3; G.t += Math.sin(pp * 3 + k) * .6; });
  PFA.motion('m10-call', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 3) + k) % 3; });
  PFA.motion('m10-sandswim', function (G, pp, k) { G.s += pp * .25; G.d += Math.sin(pp * 9 + k) * 1.2 - 1; G.fr = (Math.floor(pp * 10) + k) & 3; });
  PFA.motion('m10-curl', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; });
  PFA.motion('m10-lunge', function (G, pp, k, ph) { var w = (pp * 1.8 + ph) % 1; G.fr = w < .5 ? 0 : w < .7 ? 1 : 2; G.d += G.fr === 1 ? 3 : 0; });
  PFA.motion('m10-scurry', function (G, pp, k) { G.s += pp * .45; G.fr = (Math.floor(pp * 18) + k) & 1; G.up += G.fr; });
  PFA.motion('m10-nibble', function (G, pp, k) { G.fr = (Math.floor(pp * 9) + k) % 3; });
  PFA.motion('m10-squeeze', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.5 + ph) % 1) * 3)); });
  PFA.motion('m10-swish', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; });
  PFA.motion('m10-shake', function (G, pp, k) { G.t += ((Math.floor(pp * 24) + k) & 1) ? 1.2 : -1.2; G.fr = (Math.floor(pp * 12) + k) & 3; });
  PFA.motion('m10-lap', function (G, pp, k) { G.fr = (Math.floor(pp * 7) + k) % 3; });
  PFA.motion('m10-bend', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 2 + ph) % 1) * 4)); });
  PFA.motion('m10-carry', function (G, pp, k) { G.s += pp * .2; G.fr = (Math.floor(pp * 10) + k) & 3; G.up += G.fr & 1; });
  PFA.motion('m10-glint', function (G, pp, k) { G.fr = (k & 3) + ((Math.floor(pp * 10) + k) % 4 === 0 ? 4 : 0); });
  PFA.motion('m10-stuff', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.8 + ph) % 1) * 3)); });
  PFA.motion('m10-wander', function (G, pp, k) { G.fr = (Math.floor(pp * 7) + k) & 3; });
  PFA.motion('m10-tumble', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; G.up += Math.abs(Math.sin(pp * 8 + k)) * 2; });
  PFA.motion('m10-peek', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.fr = w < .4 ? 0 : w < .8 ? 1 : 2; });
  PFA.motion('m10-lope', function (G, pp, k) { G.s += pp * .3; G.fr = (Math.floor(pp * 10) + k) & 3; G.up += G.fr === 1 ? 1 : 0; });
  PFA.motion('m10-lick', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 2.5 + ph) % 1) * 4)); });
  PFA.motion('m10-snap', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .45 ? 0 : w < .6 ? 1 : 2; });
  PFA.motion('m10-dodge', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 3) + k) & 3; G.t += Math.sin(pp * 6 + k); });
  PFA.motion('m10-watch', function (G, pp, k, ph) { G.fr = ((pp * .9 + ph) % 1) < .85 ? 1 : 0; });

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ---------- */
  function carCubs(c, e, H) {            /* three badger cubs roll along in a jostling heap, the last one hurrying, small paw prints behind */
    var P = e.P, Q = H.Q, k, u, b;
    for (k = 1; k <= 4; k++) { u = e.hh * k / 5; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 3 - 1, Q.y + Q.ny * 3 + (k & 1), e.acc); H.px(c, Q.x + Q.nx * 3 + 1, Q.y + Q.ny * 3 + (k & 1), e.acc); }
    for (k = 2; k >= 0; k--) { u = Math.max(0, e.hh - k * .06); P.atq(e.a + e.d * u); b = Math.abs(Math.sin(e.p * 18 + k * 2)) * 3;
      H.carHead(c, P, e.a + e.d * u, 'm10-cub', 0, (Math.floor(e.p * 10) + k) & 1, 0, -b, e.col, e.acc, e.hi); }
  }
  function carReek(c, e, H) {            /* the stink badger trundles along; a yellow-green reek line wavers up behind it and fades */
    var P = e.P, Q = H.Q, u, k = 0, w;
    for (u = Math.max(0, e.hh - .45); u <= e.hh; u += .03) { P.atq(e.a + e.d * u); w = Math.sin(u * 40 - e.p * 18) * 1.5; k++;
      if ((k + Math.floor(e.p * 20)) % 3) H.px(c, Q.x + Q.nx * (8 + w + (e.hh - u) * 10), Q.y + Q.ny * (8 + w + (e.hh - u) * 10), k & 1 ? e.hi : e.col); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm10-stink', e.z, (e.p > .55 && e.p < .75) ? 2 : Math.floor(e.p * 8) & 1, 0, 0, e.col, e.acc, e.hi);
  }
  function carMoleRun(c, e, H) {         /* a mole run: a ridge of raised soil pushes along the edge, molehills left behind at each third, crumbs flying at the head */
    var P = e.P, Q = H.Q, u, k = 0, X, Y;
    for (u = 0; u <= e.hh; u += .03) { P.atq(e.a + e.d * u); X = Q.x + Q.nx * 4; Y = Q.y + Q.ny * 4; H.px(c, X, Y, (k++ & 1) ? XC[7] : XC[6]); H.px(c, X + Q.nx, Y + Q.ny, XC[6]); }
    for (k = 1; k <= 2; k++) if (e.hh > k / 3) H.carHead(c, P, e.a + e.d * k / 3, 'm10-molehill', 0, 0, 0, -1, e.col, e.acc, e.hi);
    P.atq(e.a + e.d * e.hh); for (k = 0; k < 3; k++) { u = (e.p * 6 + k * .33) % 1; H.px(c, Q.x + Q.nx * (6 + 4 * u) + (k - 1) * 3 * u, Q.y + Q.ny * (6 + 4 * u) - Math.sin(u * 3.14) * 5, XC[7]); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm10-molehill', e.z, e.hh > .9 ? 2 : 1, 0, -1, e.col, e.acc, e.hi);
  }
  function carConga(c, e, H) {           /* a conga of naked mole-rats nose to tail along the tunnel edge, the lead one chattering its teeth */
    var P = e.P, Q = H.Q, k, u, sgn = e.d >= 0 ? 1 : -1;
    for (k = 4; k >= 0; k--) { u = e.hh - k * .09; if (u < 0) continue; P.atq(e.a + e.d * u);
      H.glyph(c, 'm10-molerat', Q.x + Q.nx * 5, Q.y + Q.ny * 5 - ((Math.floor(e.p * 14) + k) & 1), 0, (Math.floor(e.p * 14) + k) & 1, e.col, e.acc, e.hi, -Q.ny * sgn, Q.nx * sgn, Q.nx, Q.ny); }
  }
  function carGoldSwim(c, e, H) {        /* the golden mole swims under the sand: a ridge of sand ripples behind, its gold back breaking the surface with a sheen */
    var P = e.P, Q = H.Q, u, k = 0, w;
    for (u = Math.max(0, e.hh - .5); u <= e.hh; u += .025) { P.atq(e.a + e.d * u); w = (k++ & 1); H.px(c, Q.x + Q.nx * (4 + w), Q.y + Q.ny * (4 + w), XC[16]);
      if ((k % 5) === 0) H.px(c, Q.x + Q.nx * 6, Q.y + Q.ny * 6, e.acc); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm10-goldmole', e.z, Math.floor(e.p * 12) & 3, 0, 1, e.col, e.acc, e.hi);
  }
  function carGrain(c, e, H) {           /* the barn rat scurries the edge dropping grain kernels one by one behind it */
    var P = e.P, Q = H.Q, k, sgn = e.d >= 0 ? 1 : -1;
    for (k = 1; k <= 5; k++) { if (e.hh < k / 6) break; P.atq(e.a + e.d * k / 6); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, XC[8]); H.px(c, Q.x + Q.nx * 3 + 1, Q.y + Q.ny * 3, XC[9]); }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'm10-grainrat', Q.x + Q.nx * 5, Q.y + Q.ny * 5 - (Math.floor(e.p * 18) & 1), e.z, Math.floor(e.p * 18) & 1, e.col, e.acc, e.hi, -Q.ny * sgn, Q.nx * sgn, Q.nx, Q.ny);
  }
  function carShake(c, e, H) {           /* the wet marsh rat swims stop to stop; at every stop it shakes and a ring of drops flies off, a wet trail between */
    var P = e.P, Q = H.Q, k, u, i, r, X, Y, sgn = e.d >= 0 ? 1 : -1;
    for (u = 0; u <= e.hh; u += .05) { P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, H.DEW); }
    for (k = 1; k <= 2; k++) { u = e.hh * 3 - k; if (u < 0 || u > 1) continue; P.atq(e.a + e.d * k / 3); X = Q.x + Q.nx * 5; Y = Q.y + Q.ny * 5; r = 2 + u * 5;
      for (i = 0; i < 6; i++) H.px(c, X + Math.cos(i * 1.05) * r, Y + Math.sin(i * 1.05) * r * .7 - u * 2, i & 1 ? H.WHITE : e.hi); }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'm10-wetrat', Q.x + Q.nx * 5, Q.y + Q.ny * 5, e.z, (Math.floor(e.p * 12) & 1) + ((e.hh * 3) % 1 < .25 ? 2 : 0), e.col, e.acc, e.hi, -Q.ny * sgn, Q.nx * sgn, Q.nx, Q.ny);
  }
  function carSwap(c, e, H) {            /* the pack rat trades: it drops the trinket it carried at the start and runs off with a shinier one (glint at the head) */
    var P = e.P, Q = H.Q, sgn = e.d >= 0 ? 1 : -1;
    P.atq(e.a + e.d * .12); H.glyph(c, 'm10-trinket', Q.x + Q.nx * 4, Q.y + Q.ny * 4, 0, 1, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
    if (e.hh > .2) { P.atq(e.a + e.d * Math.min(e.hh, .55)); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.acc); }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'm10-packrat', Q.x + Q.nx * 5, Q.y + Q.ny * 5 - (Math.floor(e.p * 14) & 1), e.z, (Math.floor(e.p * 14) & 1) + (Math.floor(e.p * 8) % 3 === 0 ? 2 : 0), e.col, e.acc, e.hi, -Q.ny * sgn, Q.nx * sgn, Q.nx, Q.ny);
  }
  function carLope(c, e, H) {            /* the jackal lopes along the edge in long strides: paired paw prints at each stride, a dust puff at the last one */
    var P = e.P, Q = H.Q, k, st = Math.floor(e.hh * 6), X, Y, sgn = e.d >= 0 ? 1 : -1;
    for (k = 1; k <= st && k < 6; k++) { P.atq(e.a + e.d * k / 6); X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3; H.px(c, X - 1, Y, e.acc); H.px(c, X + 1, Y + 1, e.acc);
      if (k === st) { H.px(c, X - 2, Y - 2, XC[16]); H.px(c, X + 2, Y - 2, XC[16]); H.px(c, X, Y - 3, XC[16]); } }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'm10-jackal', Q.x + Q.nx * 6, Q.y + Q.ny * 6 - (Math.floor(e.p * 20) % 4 === 1 ? 1 : 0), e.z, Math.floor(e.p * 20) & 3, e.col, e.acc, e.hi, -Q.ny * sgn, Q.nx * sgn, Q.nx, Q.ny);
  }

  /* ---------- motifs ---------- */
  function M(name, draw, meta) { PFA.motif(name, draw, meta); }
  function soil(c, e, H) { comp(c, e, H, decoSoil); }
  function wet(c, e, H) { comp(c, e, H, decoWet); }
  function sand(c, e, H) { comp(c, e, H, decoSand); }
  /* badger cub gang */
  M('cub-stripe-face', plain, { nm: 'badger cubs', desc: 'little striped badger-cub faces (white face, black stripes over the eyes) jostling and chirring; the chain is three cubs rolling along in a heap', fam: 'bash', gap: 14, g: 'm10-cub', mo: 'm10-scrum', x: '-', car: 'custom', carDraw: carCubs });
  M('cub-pile', plain, { nm: 'cub piles', desc: 'three badger cubs piled in a wobbling heap, the top cub tipping over', fam: 'bash', gap: 18, g: 'm10-cubpile', mo: 'm10-heap', x: '-', car: 'roll' });
  M('sett-mouth', soil, { nm: 'sett mouths', desc: 'dug-in sett entrances, a cub face peering out of the dark arch, claws on the rim, soil crumbs kicked up', fam: 'shield', gap: 16, g: 'm10-sett', mo: 'm10-peer', x: '-', car: 'tunnel' });
  M('burr-clump', plain, { nm: 'burr clumps', desc: 'hooked tan burr balls snagged with tufts of fur, the hooks turning', fam: 'thorn', gap: 12, g: 'm10-burr', mo: 'm10-burrspin', x: '-', car: 'roll' });
  /* stink badger */
  M('stink-rump', plain, { nm: 'stink badgers', desc: 'dark stink badgers with a white back stripe that raise the rump and fire a musk jet; the chain trundles leaving a wavering reek line', fam: 'drip', gap: 18, g: 'm10-stink', mo: 'm10-rump', x: '-', car: 'custom', carDraw: carReek });
  M('reek-haze', plain, { nm: 'reek', desc: 'three wavy yellow-green stench lines rising with a fly circling them', fam: 'puff', gap: 12, g: 'm10-reek', mo: 'm10-reek', x: '-', car: 'cloud' });
  M('snore-curl', plain, { nm: 'snoozing badgers', desc: 'a badger curled asleep, white stripe curving round, Zs drifting up', fam: 'mend', gap: 16, g: 'm10-snore', mo: 'm10-snore', x: '-', car: 'flutter' });
  /* tunnel mole */
  M('molehill-heave', soil, { nm: 'molehills', desc: 'molehills heaving up and a velvet mole pushing out snout and pink spade hands; the chain is a mole run ridging along the edge, leaving molehills', fam: 'bash', gap: 16, g: 'm10-molehill', mo: 'm10-heave', x: '-', car: 'custom', carDraw: carMoleRun });
  M('spade-claw', soil, { nm: 'spade claws', desc: 'big pink spade hands with five white claws raking outward, soil flicked behind', fam: 'slash', gap: 12, g: 'm10-spade', mo: 'm10-rake', x: '-', car: 'comet' });
  M('soil-clod', plain, { nm: 'soil clods', desc: 'lumps of soil flung out, crumbling, root threads hanging off', fam: 'bash', gap: 10, g: 'm10-clod', mo: 'm10-fling', x: 'clods', car: 'hop' });
  /* star-nosed mole */
  M('star-nose', wet, { nm: 'star noses', desc: 'the pink star of 22 feelers round a dark snout, twitching open and shut very fast, waterline dashes under it', fam: 'shock', gap: 12, g: 'm10-starnose', mo: 'm10-feel', x: '-', car: 'tunnel' });
  M('bubble-sniff', plain, { nm: 'bubble sniffs', desc: 'the star nose underwater blowing a bubble and sniffing it back in', fam: 'ripple', gap: 14, g: 'm10-bubble', mo: 'm10-sniff', x: 'bubbles', car: 'blink' });
  /* mole-rat gang */
  M('buck-teeth', plain, { nm: 'buck teeth', desc: 'wrinkled pink mole-rat faces with two huge cream incisors over the lips, chattering; the chain is a conga of naked mole-rats nose to tail', fam: 'bite', gap: 12, g: 'm10-teeth', mo: 'm10-chatter', x: '-', car: 'custom', carDraw: carConga });
  M('molerat-rush', soil, { nm: 'mole-rat rush', desc: 'naked mole-rats side-on running nose to tail, teeth first', fam: 'thrust', gap: 14, g: 'm10-molerat', mo: 'm10-scurry', x: '-', car: 'train' });
  M('colony-heap', plain, { nm: 'colony heaps', desc: 'three pink mole-rats huddled in a warm heap, the top one shuffling round', fam: 'shield', gap: 16, g: 'm10-heap', mo: 'm10-huddle', x: '-', car: 'train' });
  M('tunnel-call', plain, { nm: 'tunnel calls', desc: 'tunnel holes with a pink snout and incisors poking out and chirp marks rising', fam: 'puff', gap: 14, g: 'm10-hole', mo: 'm10-call', x: '-', car: 'tunnel' });
  /* golden mole */
  M('gold-sand-swim', sand, { nm: 'golden moles', desc: 'eyeless gold moles half sunk in sand, leathery nose pad first, an iridescent sheen sweeping their backs; the chain swims under the sand with its back breaking the surface', fam: 'ripple', gap: 16, g: 'm10-goldmole', mo: 'm10-sandswim', x: '-', car: 'custom', carDraw: carGoldSwim });
  M('gold-curl', plain, { nm: 'velvet curls', desc: 'a golden mole curled in a velvet ball with a rainbow-gold sheen running round it', fam: 'mend', gap: 14, g: 'm10-goldcurl', mo: 'm10-curl', x: '-', car: 'roll' });
  M('blind-lunge', sand, { nm: 'blind lunges', desc: 'a blind gold wedge head lunging nose-pad first with vibration arcs spreading ahead', fam: 'thrust', gap: 14, g: 'm10-lunge', mo: 'm10-lunge', x: '-', car: 'comet' });
  /* barn rat */
  M('grain-rat', plain, { nm: 'barn rats', desc: 'brown barn rats with long pink tails scurrying, a grain kernel in the teeth; the chain runs the edge dropping kernels', fam: 'bite', gap: 16, g: 'm10-grainrat', mo: 'm10-scurry', x: '-', car: 'custom', carDraw: carGrain });
  M('grain-nip', plain, { nm: 'grain nips', desc: 'gold grain kernels nipped: a bite notch, then split with chaff flying', fam: 'slash', gap: 10, g: 'm10-kernel', mo: 'm10-nibble', x: 'crumbs', car: 'hop' });
  M('plank-squeeze', plain, { nm: 'plank squeezes', desc: 'a rat flattening itself through the gap between two barn planks and out the other side', fam: 'puff', gap: 16, g: 'm10-squeeze', mo: 'm10-squeeze', x: '-', car: 'blink' });
  M('hay-stack', plain, { nm: 'haystacks', desc: 'little haystacks with straws sticking out and a pink rat tail swishing from under them', fam: 'leaf', gap: 14, g: 'm10-hay', mo: 'm10-swish', x: '-', car: 'train' });
  /* marsh rat */
  M('wet-fur-shake', wet, { nm: 'wet marsh rats', desc: 'shaggy wet marsh rats with blunt snouts and spiky fur, shaking off a spray of drops; the chain swims stop to stop, shaking a ring of drops at each', fam: 'ripple', gap: 16, g: 'm10-wetrat', mo: 'm10-shake', x: '-', car: 'custom', carDraw: carShake });
  M('bank-burrow', wet, { nm: 'bank burrows', desc: 'muddy banks with a round burrow at the waterline, water lapping, eyes glinting inside', fam: 'shield', gap: 16, g: 'm10-bank', mo: 'm10-lap', x: '-', car: 'rings' });
  M('reed-gnaw', plain, { nm: 'gnawed reeds', desc: 'reed stems cut at a slant by gnawing, straw chips flying, the cut top falling over', fam: 'bite', gap: 12, g: 'm10-reedgnaw', mo: 'm10-nibble', x: '-', car: 'hop' });
  M('reed-shove', wet, { nm: 'shoved reeds', desc: 'three reeds with brown cattail heads leaning outward as they are shoved over', fam: 'leaf', gap: 14, g: 'm10-reedbend', mo: 'm10-bend', x: '-', car: 'train' });
  /* pack rat */
  M('trinket-trade', plain, { nm: 'pack rats', desc: 'big-eared pack rats with a stuffed cheek carrying a glinting trinket; the chain drops one trinket and runs off with a shinier one', fam: 'sparkle', gap: 18, g: 'm10-packrat', mo: 'm10-carry', x: '-', car: 'custom', carDraw: carSwap });
  M('trinket-hoard', plain, { nm: 'trinkets', desc: 'stolen trinkets (coin, key, bottle cap, spoon) glinting in turn', fam: 'sparkle', gap: 12, g: 'm10-trinket', mo: 'm10-glint', x: '-', car: 'hop' });
  M('stuffed-cheek', plain, { nm: 'stuffed cheeks', desc: 'a big-eared pack rat face with its cheeks stuffing out wider and wider', fam: 'puff', gap: 16, g: 'm10-cheeks', mo: 'm10-stuff', x: '-', car: 'blink' });
  M('stick-midden', plain, { nm: 'middens', desc: 'criss-cross stick middens with a cactus bit and a shiny thing on top, a glint wandering over them', fam: 'shield', gap: 16, g: 'm10-midden', mo: 'm10-wander', x: '-', car: 'train' });
  /* bramble pup pack */
  M('burr-pup', plain, { nm: 'burr pups', desc: 'fluffy grey pups curled into balls with burrs stuck all over, tumbling', fam: 'thorn', gap: 14, g: 'm10-burrpup', mo: 'm10-tumble', x: '-', car: 'roll' });
  M('bramble-arch', plain, { nm: 'bramble arches', desc: 'bramble canes arching over the edge with thorns, leaves and blackberries, pup eyes blinking underneath', fam: 'leaf', gap: 14, g: 'm10-bramble', mo: 'm10-peek', x: '-', car: 'train' });
  /* thorn jackal */
  M('jackal-lope', sand, { nm: 'thorn jackals', desc: 'rangy sandy jackals with tall ears and a dark saddle, pale thorns in the coat, loping; the chain lopes along leaving paired paw prints', fam: 'slash', gap: 18, g: 'm10-jackal', mo: 'm10-lope', x: '-', car: 'custom', carDraw: carLope });
  M('scrub-lick', plain, { nm: 'scrub licks', desc: 'a jackal muzzle lapping with a pink tongue, scrub leaf bits lifting off', fam: 'mend', gap: 14, g: 'm10-lick', mo: 'm10-lick', x: '-', car: 'hop' });
  M('thorn-jaw', plain, { nm: 'thorn jaws', desc: 'long narrow jaws with thorn-pale teeth opening and snapping shut with a crack spark', fam: 'thrust', gap: 14, g: 'm10-thornjaw', mo: 'm10-snap', x: '-', car: 'comet' });
  M('cactus-dodge', sand, { nm: 'cactus pads', desc: 'prickly-pear pads with spine dots and a red fruit, jackal ear tips dodging behind them', fam: 'thorn', gap: 14, g: 'm10-cactus', mo: 'm10-dodge', x: '-', car: 'blink' });
  M('jackal-sit', plain, { nm: 'watching jackals', desc: 'jackals sitting tall and still, tail round the feet, eyes closing slowly and opening again', fam: 'shield', gap: 14, g: 'm10-sitjackal', mo: 'm10-watch', x: '-', car: 'train' });
})();
