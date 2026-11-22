/* Motif module, medium batch m07 (muskrat-crew, capybara-herd, desert-spadefoot, bullfrog, cane-toad, poison-dart-frog, golden-mantella,
   snapper-hatchling-bask, sun-lizard, rock-agama, basilisk-runner, frilled-lizard). TEMPLATE.md section 10.3.
   38 motifs, each with its own pixel glyph (ids prefixed m07-) and its own motion; four signature motifs bring their own chain effect
   (carDraw: muskrat swimming with a V wake, capybara plodding with its bird riding and hopping, bullfrog leaping in three big hops with
   landing rings, basilisk sprinting on the water with a splash at every footfall). Side-view animals are small sprite tables compiled ONCE
   at load (flat [dx, dy, colour] arrays), mirrored to face outward / along the edge. Every draw is a stateless function of p: hash noise only,
   no Math.random / Date, no allocation in the frame loops (scratch H.Q / H.G only). Glyphs go through H.glyph so the MAXG budget counts them.
   The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy default are untouched. */
(function () {
  /* fixed accent colours (not palette tones): 4 white, 5 dew, 6 tongue pink, 7 reed straw, 8 stone, 9 wood, 10 moss, 11 bird yellow, 12 mud, 13 eye black, 14 sand */
  var XC = [null, null, null, null, '#ffffff', '#cfeeff', '#e86a7a', '#c8b070', '#948c80', '#8a6038', '#4e9a3a', '#f4d060', '#5a4630', '#141418', '#e0c890'];

  /* sprite compiler (load time only): rows of chars -> flat [dx, dy, ci, ...]; . none, C main, A dark, H hi, W white, D dew, P pink, R reed, S stone, B wood, M moss, Y yellow, U mud, E eye, N sand */
  function S(rows) {
    var out = [], w = rows[0].length, h = rows.length, i, j, ci;
    for (j = 0; j < h; j++) for (i = 0; i < w; i++) { ci = '.CAHWDPRSBMYUEN'.indexOf(rows[j].charAt(i)); if (ci > 0) out.push(i - (w >> 1), j - (h >> 1), ci); }
    return out;
  }
  function spr(c, s, x, y, fl, C, A, Hi, K) {
    var i, ci;
    for (i = 0; i < s.length; i += 3) { ci = s[i + 2]; K.px(c, x + s[i] * fl, y + s[i + 1], ci === 1 ? C : ci === 2 ? A : ci === 3 ? Hi : XC[ci]); }
  }
  /* facing: on the side edges look outward, on top / bottom edges look along the edge */
  function face(tx, nx, ny) { return Math.abs(nx) > Math.abs(ny) ? (nx > 0 ? 1 : -1) : (tx >= 0 ? 1 : -1); }
  function H0(n) { n = Math.sin(n * 127.1 + 311.7) * 43758.5453; return n - Math.floor(n); }

  /* ---------- sprite tables (built once) ---------- */
  var MUSK0 = S(['.....CC..', '...CCCECA', '.DCCCCCC.', 'D.D.DD.D.']),
      MUSK1 = S(['.....CC..', '...CCCECA', 'D.CCCCCC.', '.D.D..D.D']),
      CAPY0 = S(['......CAC..', '.CCCCCCCCEC', 'CCCCCCCCCCA', 'CCCCCCCCCC.', '.CCCCCCCC..', '.A.A..A.A..']),
      CAPY1 = S(['......CAC..', '.CCCCCCCCEC', 'CCCCCCCCCCA', 'CCCCCCCCCC.', '.CCCCCCCC..', 'A...A..A..A']),
      BULLH = S(['CEC.CEC', 'CCCCCCC', 'AAAAAAA', 'CHHHHHC', '.CCCCC.']),
      GTOAD0 = S(['...HHC...', '..CHHCEC.', '.CCCCCCCA', 'CCACCACC.', '.A.....A.']),
      GTOAD1 = S(['...HHC...', '..CHHCEC.', '.CCCCCCCA', 'CCACCACC.', 'A.......A']),
      RTOAD0 = S(['...CEC.', '.CCCCCA', 'CCACCC.', 'A.A..A.']),
      RTOAD1 = S(['...CEC..', '.CCCCCA.', 'ACCACC..', '.......A']),
      JEW0 = S(['.C.C.', 'CHCHC', 'CACCC', 'CCCAC', 'C.C.C']),
      JEW1 = S(['C...C', '.CHC.', 'CACCC', 'CCCAC', 'C...C']),
      MANT0 = S(['ECCE', 'CCHC', 'CCCC', 'A..A']),
      MANT1 = S(['ECCE', 'CHCC', 'CCCC', '.AA.']),
      SNAP0 = S(['..AAA...', '.ACACA..', 'ACACACCE', '.CCCCCA.', '.A...A..']),
      SNAP1 = S(['..AAA....', '.ACACA...', 'ACACACCCE', '.CCCCCCCA', '.A...A...']),
      AGAMA0 = S(['......HH.', 'CCCCCCHHE', '..CCCCCH.', '..A..A...']),
      AGAMA1 = S(['.......HH', '......HHE', 'CCCCCCHH.', '..CCCC.A.', '..A.....A']),
      BASI0 = S(['..A.......', '..AA...CE.', '..AAA.CCC.', '.CCCCCC...', 'C...C.C...', '...C...C..', '..AA...AA.']),
      BASI1 = S(['..A.......', '..AA...CE.', '..AAA.CCC.', '.CCCCCC...', 'C....CC...', '....C.C...', '...AA..AA.']),
      GAPE = S(['..CCCCC.', '.CCECCC.', 'CCCCCAAA', 'CCHHHHH.', 'CCCCAAAA', '.CCCCCC.']);

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
  function decoWater(c, e, H, s0, len, ri, pp) {        /* swimmers / floaters: two short water lines rock just outside the edge */
    var k, u, Q = H.Q, i, X, Y; if (e.p > .92) return;
    for (k = 0; k < 2; k++) { u = (pp * 1.2 + k * .5) % 1; e.P.atq(s0 + len * (k + .5) / 2); X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3 + 5 + Math.round(Math.sin(u * 6.28));
      for (i = -3; i <= 3; i++) if ((i + k) & 1) H.px(c, X + i, Y, i === 0 ? H.WHITE : H.DEW); }
  }
  function decoHeat(c, e, H, s0, len, ri, pp) {         /* sun lizards: a wavy heat shimmer of 3 short columns over the run */
    var k, Q = H.Q, j, X, Y; if (e.p > .9) return;
    for (k = 0; k < 3; k++) { e.P.atq(s0 + len * (k + .5) / 3);
      for (j = 0; j < 3; j++) { X = Q.x + Q.nx * (6 + j * 2) + Math.round(Math.sin(pp * 9 + j + k * 2)); Y = Q.y + Q.ny * (6 + j * 2) - j;
        if (((j + k + Math.floor(pp * 6)) % 3) !== 0) H.px(c, X, Y, e.hi); } }
  }
  function decoSand(c, e, H, s0, len, ri, pp) {         /* spadefoot: grains of sand thrown out and falling back */
    var k, Q = H.Q, u, X, Y; if (e.p > .9) return;
    for (k = 0; k < 4; k++) { u = (pp * 1.5 + H0(k * 4.3 + ri)) % 1; e.P.atq(s0 + len * H0(k * 2.7 + ri * 1.3));
      X = Q.x + Q.nx * (3 + u * 8) + (k - 1.5) * u * 2; Y = Q.y + Q.ny * (3 + u * 8) - Math.sin(u * Math.PI) * 4;
      H.px(c, X, Y, k & 1 ? XC[14] : e.acc); }
  }

  /* ---------- glyphs (tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step; fr from the motion) ---------- */
  /* muskrat crew */
  PFA.glyph('m07-muskrat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a dark muskrat head swimming low with a V wake, the thin scaly tail sculling behind */
    var fl = face(tx, nx, ny), i;
    spr(c, fr & 1 ? MUSK1 : MUSK0, x, y, fl, C, A, Hi, K);
    for (i = 1; i <= 4 + z; i++) K.px(c, x - fl * (4 + i), y + 1 + ((i + fr) & 1 ? 0 : 1) * (i > 2 ? 1 : 0), i & 1 ? A : C);
  });
  PFA.glyph('m07-lodge', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a reed lodge dome built up in layers (fr 0..2), mud packed between, a muskrat peeking from the door */
    var h = 1 + Math.min(2, fr) + (z > 1 ? 1 : 0), j, w, i;
    for (j = 0; j <= h; j++) { w = 5 - j; for (i = -w; i <= w; i++) K.px(c, x + i, y + 2 - j, ((i + j) % 3) === 0 ? XC[12] : (j & 1 ? XC[7] : Hi)); }
    K.px(c, x - 1, y + 3, A); K.px(c, x, y + 3, A); K.px(c, x + 1, y + 3, A);
    if (fr >= 2) { K.px(c, x, y + 2, C); K.px(c, x + 1, y + 2, XC[13]); }
    K.px(c, x - 2, y - h, XC[7]); K.px(c, x + 2, y - h - 1, XC[7]);
  });
  PFA.glyph('m07-chisel', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* two orange chisel incisors biting through a reed stem; frame 2 the cut top tips over */
    var i, g = fr === 0 ? 2 : 0;
    for (i = -4; i <= (fr === 2 ? 0 : 4); i++) K.px(c, x + tx * 3 + nx * i, y + ty * 3 + ny * i, i & 1 ? XC[7] : Hi);
    if (fr === 2) for (i = 1; i <= 4; i++) K.px(c, x + tx * (3 + i) + nx * (1 + i * .5), y + ty * (3 + i) + ny * (1 + i * .5), i & 1 ? XC[7] : Hi);
    K.bx(c, x - 2, y - 2 - g, 2, 3, '#f0902a'); K.bx(c, x - 2, y + 1 + g, 2, 3, '#f0902a'); K.px(c, x - 3, y - 2 - g, A); K.px(c, x - 3, y + 3 + g, A);
    K.sq(c, x - 5, y, 3, C); K.px(c, x - 5, y - 1, XC[13]);
  });
  PFA.glyph('m07-reedmat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a woven reed mat: over-under straw strips, the weave shifting one step each frame */
    var i, j, w = 3 + (z > 1 ? 1 : 0);
    for (i = -w; i <= w; i++) for (j = -2; j <= 2; j++) K.px(c, x + i, y + j, ((i + j + fr) & 1) ? XC[7] : (j & 1 ? A : Hi));
    K.px(c, x - w - 1, y - 2, XC[7]); K.px(c, x + w + 1, y + 2, XC[7]);
  });
  /* capybara herd */
  PFA.glyph('m07-capy', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a calm barrel-bodied capybara side-on, blunt nose, a little yellow bird on its back hopping up on frame 1 */
    var fl = face(tx, nx, ny), by = y - 4 - (fr & 1 ? 2 : 0), bx = x - fl * 1;
    spr(c, fr & 1 ? CAPY1 : CAPY0, x, y, fl, C, A, Hi, K);
    K.px(c, bx, by, XC[11]); K.px(c, bx + fl, by, XC[11]); K.px(c, bx + fl * 2, by, A); K.px(c, bx - fl, by + 1, A);
    if (fr & 1) { K.px(c, bx, by - 1, XC[11]); K.px(c, bx - fl, by - 1, XC[11]); }
  });
  PFA.glyph('m07-capyfloat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* only eyes, ears and nostrils above the water, a calm ring spreading (fr 0..2) */
    var r = 3 + fr, i;
    K.bx(c, x - 3, y - 1, 7, 2, C); K.px(c, x - 3, y - 2, A); K.px(c, x + 2, y - 2, A); K.px(c, x - 1, y - 1, XC[13]); K.px(c, x + 3, y, A);
    for (i = -r; i <= r; i++) if ((i + fr) & 1) K.px(c, x + i, y + 1 + (Math.abs(i) > r - 2 ? 1 : 0), Math.abs(i) < 2 ? K.WHITE : K.DEW);
  });
  PFA.glyph('m07-bird', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a little yellow tyrant bird: perched (fr 0), wings up (fr 1); a tick in its beak */
    var fl = face(tx, nx, ny);
    K.px(c, x, y, Hi); K.px(c, x + fl, y, Hi); K.px(c, x - fl, y + 1, A); K.px(c, x + fl * 2, y - 1, A); K.px(c, x + fl, y - 1, XC[13]);
    if (fr & 1) { K.px(c, x - 1, y - 2, Hi); K.px(c, x - 2, y - 3, A); K.px(c, x + 1, y - 2, Hi); K.px(c, x + 2, y - 3, A); }
    else { K.px(c, x, y + 1, Hi); K.px(c, x, y + 2, A); }
    if (fr === 2) K.px(c, x + fl * 3, y - 1, '#5a2a20');
  });
  /* desert spadefoot */
  PFA.glyph('m07-spade', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a round tan hind leg ending in a black spade, shovelling (fr 0..2) and flicking sand out */
    var a = (fr - 1) * .6, ex = x + nx * 3 + tx * a * 3, ey = y + ny * 3 + ty * a * 3, i;
    K.sq(c, x, y, 3 + (z > 1 ? 1 : 0), C); K.ln(c, x, y, ex, ey, 1, C);
    for (i = -1; i <= 1; i++) { K.px(c, ex + tx * i, ey + ty * i, XC[13]); K.px(c, ex + tx * i + nx, ey + ty * i + ny, i === 0 ? XC[13] : A); }
    if (fr === 2) for (i = 0; i < 3; i++) K.px(c, ex + nx * (3 + i * 2) + tx * (i - 1) * 2, ey + ny * (3 + i * 2) + ty * (i - 1) * 2 - i, XC[14]);
  });
  PFA.glyph('m07-rainwake', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* raindrops falling, a round tan toad head pushing up out of the sand (fr 0 mound, 1 eyes, 2 head) */
    var i;
    for (i = -3; i <= 3; i++) K.px(c, x + i, y + 2, XC[14]);
    if (fr === 0) { K.bx(c, x - 2, y + 1, 5, 1, XC[14]); K.px(c, x, y, XC[14]); }
    else { K.bx(c, x - 2, y + 2 - fr, 5, fr, C); K.px(c, x - 2, y + 1 - fr, C); K.px(c, x + 2, y + 1 - fr, C); K.px(c, x - 2, y + 1 - fr, XC[13]); K.px(c, x + 2, y + 1 - fr, XC[13]);
      if (fr === 2) K.ln(c, x - 1, y + 1, x + 1, y + 1, 1, A); }
    for (i = 0; i < 3; i++) { K.px(c, x - 3 + i * 3, y - 5 - ((fr + i) % 3) * 2, Hi); K.px(c, x - 3 + i * 3, y - 4 - ((fr + i) % 3) * 2, Hi); }
  });
  /* bullfrog */
  PFA.glyph('m07-bulltongue', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a broad bullfrog head, a long pink tongue whipping out along the normal (fr 0..2 length) and a sticky tip */
    var L = fr === 0 ? 0 : fr === 1 ? 5 : 9 + z * 2, i, X, Y;
    spr(c, BULLH, x, y, 1, C, A, Hi, K);
    for (i = 1; i <= L; i++) { X = x + nx * (2 + i); Y = y + ny * (2 + i); K.px(c, X, Y, XC[6]); }
    if (L) { X = x + nx * (3 + L); Y = y + ny * (3 + L); K.sq(c, X, Y, 2, XC[6]); K.px(c, X + nx, Y + ny, K.WHITE); }
  });
  PFA.glyph('m07-throat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a frog face with a huge yellow throat sac swelling (fr 0..3), deep croak bars rolling out */
    var r = 1 + fr + (z > 1 ? 1 : 0), i, j;
    K.bx(c, x - 3, y - 3, 7, 2, C); K.px(c, x - 2, y - 4, C); K.px(c, x + 2, y - 4, C); K.px(c, x - 2, y - 4, XC[13]); K.px(c, x + 2, y - 4, XC[13]); K.bx(c, x - 3, y - 1, 7, 1, A);
    for (i = -r; i <= r; i++) for (j = 0; j <= r; j++) if (i * i + j * j * 1.6 <= r * r + 1) K.px(c, x + i, y + j, (i + j) % 4 === 0 ? K.WHITE : Hi);
    if (fr >= 2) for (j = 0; j < fr - 1; j++) for (i = -2; i <= 2; i++) K.px(c, x + nx * (r + 3 + j * 2) + tx * i, y + ny * (r + 3 + j * 2) + ty * i, j ? A : C);
  });
  PFA.glyph('m07-bullpuff', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a bullfrog body puffing up round (fr 0..2), warts dark, eyes on top, yellow throat */
    var r = 2 + fr + (z > 1 ? 1 : 0), i, j;
    for (i = -r; i <= r; i++) for (j = -r; j <= r; j++) if (i * i + j * j <= r * r + 1) K.px(c, x + i, y + j, j > r - 2 ? Hi : ((i * 3 + j * 5) % 7 === 0 ? A : C));
    K.px(c, x - 2, y - r - 1, C); K.px(c, x + 2, y - r - 1, C); K.px(c, x - 2, y - r, XC[13]); K.px(c, x + 2, y - r, XC[13]); K.px(c, x - 1, y - r + 1, K.WHITE);
  });
  PFA.glyph('m07-gulp', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a huge frog mouth head-on opening and gulping shut (fr 0 shut, 1 gape, 2 gulp), bog bubbles */
    var g = fr === 1 ? 3 : fr === 2 ? 1 : 0, w = 5 + (z > 1 ? 1 : 0), i;
    for (i = -w; i <= w; i++) { K.px(c, x + i, y - 1 - g, C); K.px(c, x + i, y - 2 - g, Math.abs(i) === 3 ? XC[13] : C); K.px(c, x + i, y + g, Hi); K.px(c, x + i, y + 1 + g, C); }
    if (g > 1) { K.bx(c, x - w + 1, y - g, 2 * w - 1, 2 * g - 1, '#5a1e22'); K.px(c, x, y, XC[6]); }
    K.px(c, x - w - 1, y - 1, A); K.px(c, x + w + 1, y - 1, A);
    if (fr === 2) { K.ringpx(c, x + nx * 7, y + ny * 7 - 2, 1, K.DEW); K.px(c, x + nx * 9 + 2, y + ny * 9 - 5, K.WHITE); }
  });
  PFA.glyph('m07-kick', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a long hind leg folded then kicked straight out, webbed foot spread */
    var L = fr ? 8 + z : 3, i, X, Y, k = fr ? 0 : 2;
    for (i = 0; i < L; i++) { X = x + nx * i + tx * (i < L / 2 ? i * k * .3 : (L - i) * k * .3); Y = y + ny * i + ty * (i < L / 2 ? i * k * .3 : (L - i) * k * .3); K.px(c, X, Y, C); K.px(c, X + tx, Y + ty, i & 1 ? A : C); }
    X = x + nx * L; Y = y + ny * L;
    for (i = -2; i <= 2; i++) K.px(c, X + tx * i + nx * (Math.abs(i) === 2 ? 1 : 0), Y + ty * i + ny * (Math.abs(i) === 2 ? 1 : 0), Math.abs(i) === 2 ? A : C);
    K.px(c, X + nx * 2, Y + ny * 2, Hi);
  });
  /* cane toad */
  PFA.glyph('m07-glandtoad', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a dry warty toad side-on with a big bulging gland behind the eye; frame 2 squirts a milky jet */
    var fl = face(tx, nx, ny), i;
    spr(c, fr === 2 ? GTOAD1 : GTOAD0, x, y, fl, C, A, Hi, K);
    if (fr >= 1) K.px(c, x - fl * 0, y - 4, Hi);
    if (fr === 2) for (i = 1; i <= 6; i++) K.px(c, x + nx * (3 + i) - fl * 0, y - 3 + ny * (3 + i) - (i < 4 ? i * .5 : 2), i & 1 ? K.WHITE : Hi);
  });
  PFA.glyph('m07-warts', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a patch of dry warts swelling (fr 0..2), each a bump with a dark rim and a pale crown */
    var k, bx, by, s = 1 + (fr > 1 ? 1 : 0);
    for (k = 0; k < 4; k++) { bx = x + (k & 1 ? 2 : -2) + (k > 1 ? 1 : 0); by = y + (k > 1 ? 2 : -1);
      K.bx(c, bx - s + 1, by - s + 1, s + 1, s, C); K.px(c, bx - s, by, A); K.px(c, bx + s + 1, by, A); K.px(c, bx, by - s, (k + fr) & 1 ? Hi : C); }
    if (fr === 2) { K.px(c, x + nx * 5, y + ny * 5, Hi); K.px(c, x + nx * 6 + tx * 2, y + ny * 6 + ty * 2, A); }
  });
  PFA.glyph('m07-roadtoad', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a squat toad hopping over a dashed night road (fr 1 legs out in the air), a dull headlight glint */
    var fl = face(tx, nx, ny), i;
    spr(c, fr & 1 ? RTOAD1 : RTOAD0, x, y, fl, C, A, Hi, K);
    for (i = -4; i <= 4; i++) if (((i + 8) % 4) < 2) K.px(c, x + i, y + 4 + (fr & 1 ? 2 : 0), '#e8e0b0');
    if (fr & 1) K.px(c, x - fl * 5, y - 2, Hi);
  });
  /* poison dart frog */
  PFA.glyph('m07-jewel', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a tiny jewel-bright frog seen from above: black spots, bright eyes; fr 1 legs splayed mid-hop */
    spr(c, fr & 1 ? JEW1 : JEW0, x, y, 1, C, XC[13], Hi, K);
    if (z > 1) { K.px(c, x - 3, y + 1, C); K.px(c, x + 3, y + 1, C); }
    if (fr === 2) K.px(c, x + 1, y - 1, K.WHITE);
  });
  PFA.glyph('m07-warnflash', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a warning ring flashing main / bright colour round a black core */
    var r = 2 + (fr & 1) + (z > 1 ? 1 : 0);
    K.ringpx(c, x, y, r, fr & 1 ? Hi : C); K.ringpx(c, x, y, r - 1, fr & 1 ? C : Hi); K.sq(c, x, y, 1 + (r > 3 ? 2 : 0), XC[13]);
    if (fr & 1) { K.px(c, x - r - 2, y, Hi); K.px(c, x + r + 2, y, Hi); K.px(c, x, y - r - 2, Hi); }
  });
  PFA.glyph('m07-dart', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a gnome-length blowpipe dart pointing out: fluff tuft, wooden shaft, a glistening poison tip */
    var i, L = 6 + z;
    K.px(c, x - nx * 2 + tx, y - ny * 2 + ty, K.WHITE); K.px(c, x - nx * 2 - tx, y - ny * 2 - ty, K.WHITE); K.px(c, x - nx * 3, y - ny * 3, K.WHITE);
    for (i = -1; i < L - 2; i++) K.px(c, x + nx * i, y + ny * i, XC[9]);
    K.px(c, x + nx * (L - 2), y + ny * (L - 2), C); K.px(c, x + nx * (L - 1), y + ny * (L - 1), C); K.px(c, x + nx * L, y + ny * L, fr & 1 ? K.WHITE : Hi);
  });
  /* golden mantella */
  PFA.glyph('m07-mantella', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a tiny golden-orange frog from above, black eye dots, a white gleam sliding over its back */
    spr(c, fr & 1 ? MANT1 : MANT0, x, y, 1, C, XC[13], C, K);
    K.px(c, x - 1 + (fr & 3) % 3, y - 1 + (fr >> 1), K.WHITE);
  });
  PFA.glyph('m07-moss', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a moss cushion swelling up (fr 0..2), pale green tips, a dew bead */
    var h = 1 + fr, w = 4 + (z > 1 ? 1 : 0), i, hh;
    for (i = -w; i <= w; i++) { hh = Math.round(h * Math.cos(i / (w + 1) * 1.57)); K.bx(c, x + i, y + 2 - hh, 1, hh + 1, (i & 1) ? XC[10] : '#3c7a2c'); if ((i + fr) % 3 === 0) K.px(c, x + i, y + 1 - hh, Hi); }
    if (fr === 2) K.px(c, x + 1, y - h - 1, K.DEW);
  });
  PFA.glyph('m07-marmalade', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a glossy orange marmalade blob stretching a sticky string out along the normal (fr 0..3), peel shreds */
    var L = fr * 2, i;
    K.sq(c, x, y, 3, C); K.px(c, x - 1, y - 1, K.WHITE); K.px(c, x + 1, y, A); K.px(c, x - 2, y + 1, A);
    for (i = 1; i <= L; i++) K.px(c, x + nx * (1 + i), y + ny * (1 + i) + (i > 2 ? 1 : 0), i === L ? C : '#f8c060');
    if (fr === 3) K.sq(c, x + nx * (2 + L), y + ny * (2 + L) + 1, 2, C);
  });
  /* snapper hatchling */
  PFA.glyph('m07-snapper', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a walnut-sized soft-shelled hatchling side-on, ridged shell, hooked beak; frame 1 the neck shoots out and snaps */
    var fl = face(tx, nx, ny);
    spr(c, fr & 1 ? SNAP1 : SNAP0, x, y, fl, C, A, Hi, K);
    K.px(c, x - fl * 1, y - 2, Hi);
    if (fr & 1) { K.px(c, x + fl * 5, y + 1, A); K.px(c, x + fl * 6, y - 2, K.WHITE); }
  });
  PFA.glyph('m07-log', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a basking log with bark rings, a hatchling dome sitting on top (slides off on frame 1) */
    var i, w = 5 + (z > 1 ? 1 : 0), hx = fr & 1 ? 3 : 0;
    for (i = -w; i <= w; i++) { K.px(c, x + i, y, XC[9]); K.px(c, x + i, y + 1, (i % 3) === 0 ? A : XC[9]); K.px(c, x + i, y + 2, A); }
    K.ringpx(c, x + w + 1, y + 1, 1, '#c89860');
    K.bx(c, x - 2 + hx, y - 2, 4, 2, C); K.px(c, x - 1 + hx, y - 3, C); K.px(c, x + hx, y - 3, C); K.px(c, x - 1 + hx, y - 2, A); K.px(c, x + 2 + hx, y - 1, A); K.px(c, x + hx, y - 3, Hi);
  });
  PFA.glyph('m07-eggtooth', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a hatchling head pointing out, a white egg tooth on the beak tip, eggshell crumbs breaking off */
    var i;
    for (i = -1; i <= 2; i++) { K.px(c, x + nx * i + tx, y + ny * i + ty, C); K.px(c, x + nx * i - tx, y + ny * i - ty, C); K.px(c, x + nx * i, y + ny * i, i === 1 ? XC[13] : C); }
    K.px(c, x + nx * 3, y + ny * 3, A); K.px(c, x + nx * 4, y + ny * 4, K.WHITE);
    K.px(c, x + nx * (5 + fr) + tx * 2, y + ny * (5 + fr) + ty * 2, '#f0ece0'); K.px(c, x + nx * (4 + fr) - tx * 2, y + ny * (4 + fr) - ty * 2 + fr, '#f0ece0');
  });
  PFA.glyph('m07-mud', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a stirred mud swirl turning (fr 0..3), murk specks thrown off */
    var i, a, r;
    for (i = 0; i < 10; i++) { a = i * .75 + fr * 1.57; r = 1 + i * .35; K.px(c, x + Math.cos(a) * r, y + Math.sin(a) * r * .8, i < 4 ? A : i & 1 ? XC[12] : C); }
    K.px(c, x + Math.cos(fr * 1.57 + 9) * 5, y + Math.sin(fr * 1.57 + 9) * 4, XC[12]);
  });
  /* sun lizard */
  PFA.glyph('m07-sunliz', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a slim sand lizard from above darting along the edge, legs in a sprawl stride, long tail, a glare flick behind */
    var i, X, Y, L = 4 + (z > 1 ? 1 : 0), s = fr & 1 ? 1 : -1;
    for (i = -L; i <= 2; i++) { X = x + tx * i; Y = y + ty * i; K.px(c, X, Y, i === 2 ? A : C); }
    K.px(c, x + tx * 2 + nx, y + ty * 2 + ny, XC[13]);
    for (i = 1; i <= 5; i++) K.px(c, x - tx * (L + i) + nx * (Math.sin(i * .9 + fr) * 1), y - ty * (L + i) + ny * (Math.sin(i * .9 + fr) * 1), i > 3 ? A : C);
    K.px(c, x + tx + nx * s * 2, y + ty + ny * s * 2, C); K.px(c, x - tx * 2 - nx * s * 2, y - ty * 2 - ny * s * 2, C);
    K.px(c, x + tx - nx * s * 1, y + ty - ny * s * 1, A); K.px(c, x - tx * 2 + nx * s * 1, y - ty * 2 + ny * s * 1, A);
    K.px(c, x - tx * 3 + nx * 2, y - ty * 3 + ny * 2 - 1, Hi);
  });
  PFA.glyph('m07-sunrays', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a half sun with rays (long / short each frame) over a lizard lying flat to bask */
    var i, a, r = fr & 1 ? 6 : 5;
    K.sq(c, x, y - 2, 3, Hi); K.px(c, x, y - 4, Hi);
    for (i = 0; i < 5; i++) { a = Math.PI + (i + .5) * Math.PI / 5; K.px(c, x + Math.cos(a) * r, y - 2 + Math.sin(a) * r, (i + fr) & 1 ? Hi : K.WHITE); K.px(c, x + Math.cos(a) * (r - 1), y - 2 + Math.sin(a) * (r - 1), Hi); }
    K.bx(c, x - 4, y + 2, 7, 1, C); K.px(c, x + 3, y + 2, A); K.px(c, x - 2, y + 3, A); K.px(c, x + 1, y + 3, A);
  });
  PFA.glyph('m07-tail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a dropped lizard tail wriggling on its own in an S, the broken stump end pale */
    var i, w, n = 4 + (z > 1 ? 1 : 0);
    for (i = -n; i <= n; i++) { w = Math.sin(i * .9 + fr * 1.57) * 1.8; K.px(c, x + tx * i + nx * w, y + ty * i + ny * w, i > n - 2 ? A : (i & 1 ? C : Hi)); }
    K.px(c, x - tx * (n + 1), y - ty * (n + 1), '#f0d0c0');
  });
  /* rock agama */
  PFA.glyph('m07-agama', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a blue-grey agama with an orange head doing push-ups (fr 1 up on its front legs, head high) */
    spr(c, fr & 1 ? AGAMA1 : AGAMA0, x, y, face(tx, nx, ny), C, A, Hi, K);
  });
  PFA.glyph('m07-slab', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a warm rock slab with a lizard pressed flat on it, orange head, a heat glint on the stone */
    var w = 5 + (z > 1 ? 1 : 0);
    K.bx(c, x - w, y, 2 * w + 1, 3, XC[8]); K.bx(c, x - w + 1, y + 3, 2 * w - 1, 1, A); K.px(c, x - w + 2, y + 1, A);
    K.bx(c, x - 3, y - 1, 5, 1, C); K.px(c, x + 2, y - 1, Hi); K.px(c, x + 3, y - 1, Hi); K.px(c, x - 4, y - 1, C); K.px(c, x - 5 + (fr & 1), y, C);
    if (fr & 1) K.px(c, x + w - 1, y, K.WHITE);
  });
  /* basilisk runner */
  PFA.glyph('m07-basilisk', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a green basilisk upright on its hind legs, tall crest, long toes slapping the water */
    var fl = face(tx, nx, ny);
    spr(c, fr & 1 ? BASI1 : BASI0, x, y, fl, C, A, Hi, K);
    K.px(c, x - fl * 3, y + 4, K.DEW); K.px(c, x + fl * (fr & 1 ? 1 : 3), y + 4, K.WHITE);
  });
  PFA.glyph('m07-crest', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a tall crest sail of three fins rippling (fr 0..2), the fin rays dark */
    var k, h, j, X;
    for (k = -1; k <= 1; k++) { h = 3 + (k === 0 ? 2 : 0) + ((k + 1 + fr) % 3 === 0 ? 1 : 0) + (z > 1 ? 1 : 0); X = x + k * 3;
      for (j = 0; j <= h; j++) { K.px(c, X + nx * j, y + ny * j, j === h ? A : C); if (j < h - 1) K.px(c, X + tx + nx * j, y + ty + ny * j, j & 1 ? A : C); } }
    K.bx(c, x - 4, y, 9, 1, A);
  });
  PFA.glyph('m07-toesplash', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* long splayed toes slapping the water and a fan of splash drops kicked up (fr 0..2) */
    var i, r = 2 + fr * 2;
    for (i = -2; i <= 2; i++) K.ln(c, x, y, x + tx * i * 1.5 + nx * 3, y + ty * i * 1.5 + ny * 3, 1, i === 0 ? A : C);
    for (i = -2; i <= 2; i++) K.px(c, x + nx * (3 + r) + tx * i * (1 + fr), y + ny * (3 + r) + ty * i * (1 + fr) - (2 - Math.abs(i)), Math.abs(i) === 1 ? K.WHITE : K.DEW);
  });
  /* frilled lizard */
  PFA.glyph('m07-frill', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* head-on frilled lizard: the huge collar snaps open like an umbrella (fr 0 folded, 1 half, 2 full), ribs dark, mouth gaping */
    var R = fr === 0 ? 2 : fr === 1 ? 4 : 6 + (z > 1 ? 1 : 0), i, a, r;
    if (fr) for (i = 0; i < 13; i++) { a = i * Math.PI * 2 / 13; for (r = 2; r <= R; r++) K.px(c, x + Math.cos(a) * r, y + Math.sin(a) * r * .85, (i & 1) && r > 2 ? A : (r === R ? Hi : C)); }
    else { K.px(c, x - 2, y, A); K.px(c, x + 2, y, A); }
    K.bx(c, x - 1, y - 2, 3, 2, C); K.px(c, x - 1, y - 2, XC[13]); K.px(c, x + 1, y - 2, XC[13]);
    K.bx(c, x - 1, y, 3, fr ? 2 : 1, fr ? '#f4d060' : A); if (fr === 2) K.px(c, x, y, '#e8848a');
  });
  PFA.glyph('m07-dustfan', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a half-open collar fanning a brown dust cloud outward (fr 0..2 arcs travel out) */
    var i, a, r = 3 + fr * 2;
    for (i = -3; i <= 3; i++) K.px(c, x + tx * i, y + ty * i, Math.abs(i) === 3 ? A : C);
    for (i = -2; i <= 2; i++) { a = i * .45; K.px(c, x + (nx * Math.cos(a) + tx * Math.sin(a)) * r, y + (ny * Math.cos(a) + ty * Math.sin(a)) * r, (i + fr) & 1 ? XC[14] : '#a08060');
      if (fr) K.px(c, x + (nx * Math.cos(a) + tx * Math.sin(a)) * (r - 2), y + (ny * Math.cos(a) + ty * Math.sin(a)) * (r - 2), '#c8b090'); }
  });
  PFA.glyph('m07-gape', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a frilled-lizard head side-on with the mouth gaping yellow, an S hiss line coming out on frame 1 */
    var fl = face(tx, nx, ny), i;
    spr(c, GAPE, x, y, fl, C, A, Hi, K);
    if (fr & 1) for (i = 0; i < 5; i++) K.px(c, x + fl * (5 + i), y + 1 + Math.round(Math.sin(i * 1.5) * 1.2), i & 1 ? K.WHITE : Hi);
  });

  /* ---------- motions (mutate the scratch G; pp = time x speed) ---------- */
  PFA.motion('m07-paddle', function (G, pp, k) { G.s += pp * .3; G.fr = (Math.floor(pp * 8) + k) & 1; G.up += Math.sin(pp * 7 + k) * .7; });
  PFA.motion('m07-stack', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.5 + ph) % 1) * 3.4)); });
  PFA.motion('m07-gnaw', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 3.5 + ph) % 1) * 3); G.t += G.fr === 1 ? .6 : 0; });
  PFA.motion('m07-weave', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 1; });
  PFA.motion('m07-plod', function (G, pp, k) { G.s += pp * .08; G.fr = (Math.floor(pp * 4) + k) & 1; G.up += G.fr ? 1 : 0; });
  PFA.motion('m07-calm', function (G, pp, k, ph) { G.up += Math.sin(pp * 4 + k) * .8; G.fr = Math.floor(((pp * 1.5 + ph) % 1) * 3); });
  PFA.motion('m07-flyup', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .25 ? 0 : (Math.floor(w * 12) & 1) ? 1 : 2; G.up += w * 3; });
  PFA.motion('m07-shovel', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 3 + ph) % 1) * 3); });
  PFA.motion('m07-popup', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; G.fr = w < .3 ? 0 : w < .55 ? 1 : 2; });
  PFA.motion('m07-lash', function (G, pp, k, ph) { var w = (pp * 2.5 + ph) % 1; G.fr = w < .35 ? 0 : w < .5 ? 1 : w < .72 ? 2 : 1; });
  PFA.motion('m07-swell', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.4 + ph) % 1) * 4.5)); });
  PFA.motion('m07-inflate', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.2 + ph * .4) % 1) * 3.5)); });
  PFA.motion('m07-gulp', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .4 ? 0 : w < .7 ? 1 : 2; });
  PFA.motion('m07-kick', function (G, pp, k, ph) { G.fr = ((pp * 3 + ph) % 1) > .55 ? 1 : 0; G.d += G.fr; });
  PFA.motion('m07-squirt', function (G, pp, k, ph) { var w = (pp * 1.8 + ph) % 1; G.fr = w < .45 ? 0 : w < .65 ? 1 : 2; });
  PFA.motion('m07-bump', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 3 + ph * 3) + k) % 3; });
  PFA.motion('m07-roadhop', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.up += Math.sin(w * Math.PI) * 5; G.t += (w - .5) * 4; G.fr = w > .15 && w < .85 ? 1 : 0; });
  PFA.motion('m07-jewelhop', function (G, pp, k, ph) { var w = (pp * 2.6 + ph) % 1; G.up += Math.sin(w * Math.PI) * 3; G.fr = w > .2 && w < .8 ? 1 : ((Math.floor(pp * 4) + k) % 3 === 0 ? 2 : 0); });
  PFA.motion('m07-flash', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 2) + k) & 1; });
  PFA.motion('m07-shoot', function (G, pp, k, ph) { G.d += ((pp * 2 + ph) % 1) * 4; G.fr = (Math.floor(pp * 8) + k) & 1; });
  PFA.motion('m07-gleam', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; G.up += (G.fr === 1 ? 1 : 0) + Math.abs(Math.sin(pp * 9 + k)) * 1.5; });
  PFA.motion('m07-sprout', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.2 + ph) % 1) * 3.4)); });
  PFA.motion('m07-stretch', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.6 + ph) % 1) * 4.5)); });
  PFA.motion('m07-snap', function (G, pp, k, ph) { var w = (pp * 2.4 + ph) % 1; G.fr = w < .6 ? 0 : 1; G.d += G.fr; });
  PFA.motion('m07-bask', function (G, pp, k) { G.fr = (Math.floor(pp * 2) + k) & 1; G.t += G.fr ? 2 : 0; });
  PFA.motion('m07-spin', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; });
  PFA.motion('m07-dash', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.s += w < .5 ? 0 : (w - .5) * .5; G.fr = (Math.floor(pp * 16) + k) & 1; });
  PFA.motion('m07-rays', function (G, pp, k) { G.fr = (Math.floor(pp * 4) + k) & 1; });
  PFA.motion('m07-wriggle', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; G.t += Math.sin(pp * 12 + k) * .8; });
  PFA.motion('m07-pushup', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 2)) & 1; G.up += G.fr; });
  PFA.motion('m07-sprint', function (G, pp, k) { G.s += pp * .7; G.fr = (Math.floor(pp * 18) + k) & 1; });
  PFA.motion('m07-ripple', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) % 3; });
  PFA.motion('m07-splash', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 3 + ph) % 1) * 3); });
  PFA.motion('m07-flare', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.fr = w < .25 ? 0 : w < .4 ? 1 : 2; });
  PFA.motion('m07-fan', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2 + ph) % 1) * 3); });
  PFA.motion('m07-hiss', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 3)) & 1; G.t += G.fr ? .5 : 0; });

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ---------- */
  function carSwim(c, e, H) {           /* the muskrat swims the edge, a V wake spreading behind its head, the scaly tail sculling */
    var P = e.P, Q = H.Q, k, u, sp;
    for (k = 1; k <= 6; k++) { u = e.hh - k * .035; if (u < 0) break; P.atq(e.a + e.d * u); sp = k * .9;
      H.px(c, Q.x + Q.nx * (5 + sp), Q.y + Q.ny * (5 + sp), k & 1 ? H.WHITE : H.DEW); H.px(c, Q.x + Q.nx * (5 - sp * .6), Q.y + Q.ny * (5 - sp * .6) + 1, H.DEW); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm07-muskrat', e.z, e.fr, 0, 0, e.col, e.acc, e.hi);
  }
  function carCapy(c, e, H) {           /* a capybara plods the edge, its bird riding then hopping ahead and landing back on its back; prints behind */
    var P = e.P, Q = H.Q, k, u, w;
    for (k = 1; k <= 4; k++) { u = e.hh - k * .1; if (u < 0) break; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3 + 4, e.acc); H.px(c, Q.x + Q.nx * 3 + 2, Q.y + Q.ny * 3 + 4, e.acc); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm07-capy', e.z, Math.floor(e.p * 6) & 1 ? 2 : 0, 0, 0, e.col, e.acc, e.hi);
    w = (e.p * 2) % 1; u = Math.min(1, e.hh + .12 * Math.sin(w * Math.PI));
    H.carHead(c, P, e.a + e.d * u, 'm07-bird', 0, w > .15 && w < .85 ? 1 : 0, 0, -9 - Math.sin(w * Math.PI) * 6, e.col, e.acc, e.hi);
  }
  function carLeap(c, e, H) {           /* the bullfrog crosses in three big leaps, a ring spreading at every landing */
    var P = e.P, Q = H.Q, k, l = e.hh * 3, j = Math.min(2, Math.floor(l)), w = l - j, r;
    for (k = 1; k <= j; k++) { P.atq(e.a + e.d * k / 3); r = 1 + Math.min(4, (l - k) * 5); H.ringpx(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5 + 3, r, r > 3 ? e.acc : H.DEW); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm07-bullpuff', 0, w > .2 && w < .8 ? 0 : 1, 0, -Math.sin(w * Math.PI) * 10, e.col, e.acc, e.hi);
  }
  function carRun(c, e, H) {            /* the basilisk sprints along the water, a splash left at each footfall, fading behind */
    var P = e.P, Q = H.Q, k, u, a;
    for (k = 1; k <= 7; k++) { u = e.hh - k * .045; if (u < 0) break; P.atq(e.a + e.d * u); a = 1 - k / 8;
      if (a > .3) { H.px(c, Q.x + Q.nx * 5 + (k & 1 ? -1 : 1), Q.y + Q.ny * 5 + 4 - (k < 3 ? 2 : 1), H.WHITE); H.px(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5 + 5, H.DEW); }
      else H.px(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5 + 5, e.hi); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm07-basilisk', e.z, Math.floor(e.p * 20) & 1, 0, -2, e.col, e.acc, e.hi);
  }

  /* ---------- motifs ---------- */
  function M(name, draw, meta) { PFA.motif(name, draw, meta); }
  function water(c, e, H) { comp(c, e, H, decoWater); }
  function heat(c, e, H) { comp(c, e, H, decoHeat); }
  function sand(c, e, H) { comp(c, e, H, decoSand); }
  /* muskrat crew */
  M('muskrat-wake', water, { nm: 'swimming muskrats', desc: 'dark muskrat heads swimming low with a V wake, the thin scaly tail sculling behind; the chain is a muskrat swimming the edge with its wake spreading', fam: 'ripple', gap: 16, g: 'm07-muskrat', mo: 'm07-paddle', x: '-', car: 'custom', carDraw: carSwim });
  M('reed-lodge', plain, { nm: 'reed lodges', desc: 'reed lodge domes built up layer by layer with mud packed between, a muskrat peeking from the door', fam: 'shield', gap: 14, g: 'm07-lodge', mo: 'm07-stack', x: '-', car: 'train' });
  M('reed-chisel', plain, { nm: 'reed chisels', desc: 'two orange chisel incisors biting through a reed stem, the cut top tipping over', fam: 'bite', gap: 14, g: 'm07-chisel', mo: 'm07-gnaw', x: '-', car: 'hop' });
  M('reed-mat', plain, { nm: 'reed mats', desc: 'woven over-under reed mats, the weave shifting', fam: 'leaf', gap: 14, g: 'm07-reedmat', mo: 'm07-weave', x: '-', car: 'flutter' });
  /* capybara herd */
  M('capy-bird', plain, { nm: 'capybaras with birds', desc: 'calm barrel-bodied capybaras plodding side-on with a little yellow bird on each back; the chain is a capybara plodding along while its bird hops ahead and lands back on it', fam: 'bash', gap: 20, g: 'm07-capy', mo: 'm07-plod', x: 'prints', car: 'custom', carDraw: carCapy });
  M('capy-float', plain, { nm: 'floating capybaras', desc: 'only eyes, ears and nostrils above the water, a calm ring spreading round each', fam: 'ripple', gap: 16, g: 'm07-capyfloat', mo: 'm07-calm', x: '-', car: 'rings' });
  M('bird-perch', plain, { nm: 'riding birds', desc: 'little yellow birds hopping up and fluttering, a tick in the beak', fam: 'mend', gap: 12, g: 'm07-bird', mo: 'm07-flyup', x: '-', car: 'flutter' });
  /* desert spadefoot */
  M('spade-dig', sand, { nm: 'spade feet', desc: 'round tan hind legs ending in a black spade, shovelling backwards and flicking sand out; the chain digs along under the sand', fam: 'bash', gap: 14, g: 'm07-spade', mo: 'm07-shovel', x: '-', car: 'tunnel' });
  M('rain-wake', plain, { nm: 'rain wakers', desc: 'rain falling on sand and round tan toad heads pushing up out of it: a mound, then the eyes, then the head', fam: 'mend', gap: 14, g: 'm07-rainwake', mo: 'm07-popup', x: '-', car: 'hop' });
  /* bullfrog */
  M('bull-tongue', plain, { nm: 'bullfrog tongues', desc: 'broad bullfrog heads whipping a long pink tongue out with a sticky tip; the chain is the bullfrog crossing in three big leaps with a ring at each landing', fam: 'slash', gap: 16, g: 'm07-bulltongue', mo: 'm07-lash', x: '-', car: 'custom', carDraw: carLeap });
  M('bull-throat', plain, { nm: 'croak sacs', desc: 'a frog face with a huge yellow throat sac swelling, deep croak bars rolling outward', fam: 'ripple', gap: 16, g: 'm07-throat', mo: 'm07-swell', x: '-', car: 'rings' });
  M('bull-puff', plain, { nm: 'puffed bullfrogs', desc: 'bullfrog bodies puffing up round with dark warts and a yellow throat', fam: 'puff', gap: 14, g: 'm07-bullpuff', mo: 'm07-inflate', x: '-', car: 'hop' });
  M('bog-gulp', plain, { nm: 'bog gulps', desc: 'a huge frog mouth head-on opening wide and gulping shut, bog bubbles rising', fam: 'bite', gap: 16, g: 'm07-gulp', mo: 'm07-gulp', x: '-', car: 'comet' });
  M('bull-kick', plain, { nm: 'hind-leg kicks', desc: 'a long frog hind leg folded, then kicked straight out with the webbed foot spread', fam: 'slash', gap: 14, g: 'm07-kick', mo: 'm07-kick', x: '-', car: 'hop' });
  /* cane toad */
  M('gland-squirt', plain, { nm: 'gland squirts', desc: 'dry warty toads side-on with a big bulging gland behind the eye that squirts a milky toxin jet', fam: 'drip', gap: 16, g: 'm07-glandtoad', mo: 'm07-squirt', x: '-', car: 'comet' });
  M('wart-hide', plain, { nm: 'dry warts', desc: 'patches of dry warts swelling up, dark rims and pale crowns', fam: 'thorn', gap: 12, g: 'm07-warts', mo: 'm07-bump', x: '-', car: 'train' });
  M('road-hop', plain, { nm: 'road hoppers', desc: 'squat toads hopping over a dashed night road line, a dull headlight glint', fam: 'puff', gap: 16, g: 'm07-roadtoad', mo: 'm07-roadhop', x: '-', car: 'hop' });
  /* poison dart frog */
  M('jewel-frog', plain, { nm: 'jewel frogs', desc: 'tiny jewel-bright frogs from above with black spots, hopping with legs splayed', fam: 'drip', gap: 12, g: 'm07-jewel', mo: 'm07-jewelhop', x: '-', car: 'hop' });
  M('warning-flash', plain, { nm: 'warning rings', desc: 'warning rings flashing between the frog colour and bright yellow round a black core', fam: 'sparkle', gap: 14, g: 'm07-warnflash', mo: 'm07-flash', x: '-', car: 'blink' });
  M('gnome-dart', plain, { nm: 'poison darts', desc: 'gnome-length blowpipe darts with a white fluff tuft and a glistening poison tip, shooting out', fam: 'thrust', gap: 12, g: 'm07-dart', mo: 'm07-shoot', x: '-', car: 'comet' });
  /* golden mantella */
  M('mantella-gleam', plain, { nm: 'golden mantellas', desc: 'tiny golden-orange frogs with black eye dots, a white gleam sliding over their backs as they skip', fam: 'sparkle', gap: 11, g: 'm07-mantella', mo: 'm07-gleam', x: '-', car: 'hop' });
  M('moss-cushion', plain, { nm: 'moss cushions', desc: 'rainforest moss cushions swelling up, pale green tips and a dew bead', fam: 'leaf', gap: 14, g: 'm07-moss', mo: 'm07-sprout', x: '-', car: 'train' });
  M('marmalade-spill', plain, { nm: 'marmalade blobs', desc: 'glossy orange marmalade blobs stretching sticky strings out, peel shreds', fam: 'drip', gap: 13, g: 'm07-marmalade', mo: 'm07-stretch', x: '-', car: 'trail' });
  /* snapper hatchling */
  M('snapper-snap', plain, { nm: 'snapper hatchlings', desc: 'walnut-sized soft-shelled hatchlings side-on with ridged shells and hooked beaks, necks shooting out to snap', fam: 'bite', gap: 14, g: 'm07-snapper', mo: 'm07-snap', x: '-', car: 'roll' });
  M('bask-log', plain, { nm: 'basking logs', desc: 'a basking log with bark rings and a hatchling sitting on top that slides off', fam: 'shield', gap: 16, g: 'm07-log', mo: 'm07-bask', x: '-', car: 'roll' });
  M('egg-tooth', plain, { nm: 'egg teeth', desc: 'a hatchling head pointing out with a white egg tooth on the beak tip, eggshell crumbs breaking off', fam: 'thrust', gap: 12, g: 'm07-eggtooth', mo: 'm07-snap', x: '-', car: 'comet' });
  M('mud-stir', plain, { nm: 'mud swirls', desc: 'stirred mud swirls turning, murk specks thrown off', fam: 'ripple', gap: 14, g: 'm07-mud', mo: 'm07-spin', x: '-', car: 'cloud' });
  /* sun lizard */
  M('sun-dart', heat, { nm: 'darting sun lizards', desc: 'slim sand lizards from above darting along the edge in a sprawl stride, a glare flick behind, heat shimmer over the run', fam: 'shock', gap: 16, g: 'm07-sunliz', mo: 'm07-dash', x: '-', car: 'zig' });
  M('sun-bask', heat, { nm: 'sun baskers', desc: 'a half sun with rays pulsing long and short over a lizard lying flat to bask, heat shimmer rising', fam: 'mend', gap: 16, g: 'm07-sunrays', mo: 'm07-rays', x: '-', car: 'blink' });
  M('tail-drop', plain, { nm: 'dropped tails', desc: 'a dropped lizard tail wriggling on its own in an S, the broken stump pale', fam: 'puff', gap: 14, g: 'm07-tail', mo: 'm07-wriggle', x: '-', car: 'trail' });
  /* rock agama */
  M('agama-pushup', plain, { nm: 'push-up agamas', desc: 'blue-grey agamas with orange heads doing push-ups, head bobbing high on the front legs', fam: 'thrust', gap: 16, g: 'm07-agama', mo: 'm07-pushup', x: '-', car: 'hop' });
  M('rock-flat', plain, { nm: 'flattened on rock', desc: 'warm grey rock slabs with a lizard pressed flat on each, orange head, a heat glint on the stone', fam: 'shield', gap: 16, g: 'm07-slab', mo: 'm07-bask', x: '-', car: 'train' });
  /* basilisk runner */
  M('basilisk-run', plain, { nm: 'water runners', desc: 'green basilisks upright on their hind legs with a tall crest, long toes slapping the water; the chain is a basilisk sprinting along the water with a splash at each footfall', fam: 'slash', gap: 16, g: 'm07-basilisk', mo: 'm07-sprint', x: '-', car: 'custom', carDraw: carRun });
  M('crest-sail', plain, { nm: 'crest sails', desc: 'a tall crest sail of three fins rippling, dark fin rays', fam: 'shield', gap: 14, g: 'm07-crest', mo: 'm07-ripple', x: '-', car: 'flutter' });
  M('toe-splash', plain, { nm: 'toe splashes', desc: 'long splayed toes slapping the water, a fan of splash drops kicked up', fam: 'ripple', gap: 14, g: 'm07-toesplash', mo: 'm07-splash', x: '-', car: 'hop' });
  /* frilled lizard */
  M('frill-flare', plain, { nm: 'frill flares', desc: 'a frilled lizard head-on, the huge ribbed collar snapping open like an umbrella round a gaping yellow mouth', fam: 'thorn', gap: 18, g: 'm07-frill', mo: 'm07-flare', x: '-', car: 'hop' });
  M('dust-fan', plain, { nm: 'dust fans', desc: 'a half-open collar fanning arcs of brown dust outward', fam: 'puff', gap: 14, g: 'm07-dustfan', mo: 'm07-fan', x: '-', car: 'cloud' });
  M('hiss-gape', plain, { nm: 'hissing gapes', desc: 'a frilled-lizard head side-on with the mouth gaping yellow and an S hiss line coming out', fam: 'bite', gap: 16, g: 'm07-gape', mo: 'm07-hiss', x: '-', car: 'comet' });
})();
