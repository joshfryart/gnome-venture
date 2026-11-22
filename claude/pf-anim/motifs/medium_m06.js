/* Motif module, medium batch m06 (seal-pup-raft, ice-floe-seal, river-otter, ship-rat-crew, sea-otter-bandit, bog-leech, giant-mire-leech,
   tiger-leech, saltmarsh-leech, garfish). TEMPLATE.md section 10.3.
   26 motifs, each with its own pixel glyph (ids prefixed m06-) and, where the built-in ones did not fit, its own motion; five signature motifs
   bring their own chain effect (carDraw: drifting pup raft, otter belly slide, rats running a hawser, inch-looping leech, skipping garfish).
   Side-view animals come from small sprite tables compiled ONCE at load (flat [dx, dy, colour] arrays) and are mirrored to face outward /
   along the edge; long bodies (leeches, garfish, plank) are drawn along the edge tangent / normal. Every draw is a stateless function of p:
   hash noise only, no Math.random / Date, no allocation in the frame loops (scratch H.Q / H.G only). Glyphs go through H.glyph so the MAXG
   budget counts them. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy default are untouched. */
(function () {
  /* fixed accent colours (not palette tones): 4 white, 5 dew, 6 kelp, 7 blood red, 8 rat-tail pink, 9 stone, 10 wood, 11 silver, 12 leaf, 13 eye black */
  var XC = [null, null, null, null, '#ffffff', '#cfeeff', '#4e8a3a', '#d0283c', '#ec9aa4', '#948c80', '#b07a40', '#d6dee6', '#58b048', '#141418'];

  /* sprite compiler (load time only): rows of chars -> flat [dx, dy, ci, ...]; . none, C main, A dark, H hi, W white, D dew, K kelp, R red, P pink, S stone, B wood, V silver, L leaf, E eye */
  function S(rows) {
    var out = [], w = rows[0].length, h = rows.length, i, j, ci;
    for (j = 0; j < h; j++) for (i = 0; i < w; i++) { ci = '.CAHWDKRPSBVLE'.indexOf(rows[j].charAt(i)); if (ci > 0) out.push(i - (w >> 1), j - (h >> 1), ci); }
    return out;
  }
  function spr(c, s, x, y, fl, C, A, Hi, K) {
    var i, ci;
    for (i = 0; i < s.length; i += 3) { ci = s[i + 2]; K.px(c, x + s[i] * fl, y + s[i + 1], ci === 1 ? C : ci === 2 ? A : ci === 3 ? Hi : XC[ci]); }
  }
  /* facing: on the side edges look outward, on top / bottom edges look along the edge */
  function face(tx, nx, ny) { return Math.abs(nx) > Math.abs(ny) ? (nx > 0 ? 1 : -1) : (tx >= 0 ? 1 : -1); }

  /* ---------- sprite tables (built once) ---------- */
  var PUP0 = S(['..CCC..', '.CCCCC.', 'CECCCEC', 'CCCACCC', 'ACCCCCA', '.CCCCC.']),
      PUP1 = S(['..CCC..', '.CCCCC.', 'CCCCCCC', 'CCCACCC', 'ACCCCCA', 'CCCCCCC', 'A.....A']),
      GSEAL0 = S(['.......CCC.', '.....CCCECA', 'CCCCCCHCCC.', 'ACCCCCCCC..', '.AA..AA....']),
      GSEAL1 = S(['...CCC.CCC.', '..CCHCCCECA', '.CCCCCCCC..', 'ACCCCCCC...', '.A....A....']),
      OT0 = S(['.......CCC.', 'ACCCCCCCECA', '.CCCCCCCCH.', '..A....A...']),
      OT1 = S(['.......CCC.', 'AACCCCCCECA', '..CCCCCCCH.', '...........']),
      RAT0 = S(['......C...', '.PP.CCCCE.', 'P..PCCCCCP', '....A..A..']),
      RAT1 = S(['......C...', 'PP..CCCCE.', '..PPCCCCCP', '...A....A.']),
      RATH = S(['.C.C.', 'CCCCC', 'CECEC', '.CPC.']),
      BO0 = S(['...WW......', '..C..C.....', '...SSS..HH.', 'ACCCCCCCAEA', '.CCCCCCCCC.']),
      BO1 = S(['...........', '..CWWC.....', '...SSS..HH.', 'ACCCCCCCAEA', '.CCCCCCCCC.']),
      OTH = S(['C...C', 'CHHHC', 'AEAEA', '.HAH.']);

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
  function decoSwell(c, e, H, s0, len, ri, pp) {          /* floating animals: two short swell lines rock under them */
    var k, u, Q = H.Q, i, X, Y; if (e.p > .92) return;
    for (k = 0; k < 2; k++) { u = (pp * 1.1 + k * .5) % 1; e.P.atq(s0 + len * (k + .5) / 2); X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3 + 5 + Math.round(Math.sin(u * 6.28));
      for (i = -3; i <= 3; i++) if ((i + k) & 1) H.px(c, X + i, Y + (Math.abs(i) === 3 ? 1 : 0), i === 0 ? H.WHITE : H.DEW); }
  }
  function decoSlime(c, e, H, s0, len, ri, pp) {          /* leeches: a slime string sags between the edge and the nearest body, glistening */
    var k, Q = H.Q, j, X, Y, sg; if (e.p > .9) return;
    for (k = 0; k < 2; k++) { e.P.atq(s0 + len * (.25 + k * .5)); sg = 2 + Math.sin(pp * 4 + k) * 1.5;
      for (j = 1; j < 6; j++) { X = Q.x + Q.nx * j; Y = Q.y + Q.ny * j + Math.sin(j / 6 * Math.PI) * sg; H.px(c, X, Y, j === 3 && ((Math.floor(pp * 8) + k) & 1) ? H.WHITE : e.hi); } }
  }

  /* ---------- glyphs (tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step; fr from the motion) ---------- */
  PFA.glyph('m06-pup', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* round white fluffball seal pup, two huge dark eyes, black nose; flippers flap on frame 1 */
    spr(c, fr & 1 ? PUP1 : PUP0, x, y, 1, C, A, Hi, K); K.px(c, x - 1, y - 2, Hi); if (z > 1) { K.px(c, x - 4, y, C); K.px(c, x + 4, y, C); }
  });
  PFA.glyph('m06-whisker', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* pup muzzle, whiskers fanning out wider each frame, a squeak burst of three short rays */
    var i, w = 3 + fr, r;
    K.sq(c, x, y, 4, C); K.px(c, x - 1, y - 1, XC[13]); K.px(c, x + 1, y - 1, XC[13]); K.px(c, x, y + 1, A);
    for (i = -1; i <= 1; i++) { K.ln(c, x - 2, y + 1 + i, x - 2 - w, y + 1 + i * (1 + fr * .5), 1, Hi); K.ln(c, x + 2, y + 1 + i, x + 2 + w, y + 1 + i * (1 + fr * .5), 1, Hi); }
    if (fr) { r = 5 + fr * 2; for (i = -1; i <= 1; i++) { K.px(c, x + (nx + tx * i * .6) * r, y + (ny + ty * i * .6) * r, K.WHITE); K.px(c, x + (nx + tx * i * .6) * (r + 1), y + (ny + ty * i * .6) * (r + 1), Hi); } }
  });
  PFA.glyph('m06-flipper', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a foreflipper raised then slapping down flat; frame 2 throws a fan of splash drops */
    var i, L = 4 + (z > 0 ? 1 : 0), lift = fr === 0 ? 3 : fr === 1 ? 0 : -1, X, Y;
    for (i = 0; i < L; i++) { X = x + tx * (i - 1) + nx * (lift * (i / L)); Y = y + ty * (i - 1) + ny * (lift * (i / L)); K.px(c, X, Y, C); K.px(c, X - nx, Y - ny, i === L - 1 ? A : C); }
    K.px(c, x + tx * (L - 1) + nx * lift, y + ty * (L - 1) + ny * lift, A); K.px(c, x - tx * 2, y - ty * 2, A);
    if (fr === 2) for (i = -2; i <= 2; i++) { K.px(c, x + tx * (1 + i * 2) + nx * (3 + (i & 1)), y + ty * (1 + i * 2) + ny * (3 + (i & 1)) - 2, K.DEW); K.px(c, x + tx * (1 + i * 3) + nx * 5, y + ty * (1 + i * 3) + ny * 5 - 3, i === 0 ? K.WHITE : K.DEW); }
  });
  PFA.glyph('m06-greyseal', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* side-view grey seal: thick scarred neck, dark eye and nose; the back humps on frame 1 (galumph) */
    spr(c, fr & 1 ? GSEAL1 : GSEAL0, x, y, face(tx, nx, ny), C, A, Hi, K);
  });
  PFA.glyph('m06-floe', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a white ice floe slab tilting, a blue crack running through it, a dark waterline under */
    var w = 7 + z, i, tl = (fr & 3) === 1 ? 1 : (fr & 3) === 3 ? -1 : 0, h;
    for (i = -(w >> 1); i <= (w >> 1); i++) { h = Math.round(i * tl * .35); K.px(c, x + i, y - 1 + h, K.WHITE); K.px(c, x + i, y + h, Hi); K.px(c, x + i, y + 1 + h, i & 1 ? Hi : K.WHITE); K.px(c, x + i, y + 2 + h, A); }
    K.px(c, x - 1, y - 1, K.DEW); K.px(c, x, y, A); K.px(c, x + 1, y + 1 + Math.round(tl * .35), A);
    if (fr === 2) { K.px(c, x - (w >> 1) - 1, y - 2, K.WHITE); K.px(c, x + (w >> 1) + 1, y - 3, K.DEW); }
  });
  PFA.glyph('m06-otter', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* sleek brown river otter stretched flat on its belly, whiskers, long tapering tail */
    var fl = face(tx, nx, ny);
    spr(c, fr & 1 ? OT1 : OT0, x, y, fl, C, A, Hi, K); K.px(c, x + fl * 6, y, Hi); K.px(c, x + fl * 6, y - 1, Hi);
    if (z > 0) K.px(c, x - fl * 6, y, A);
  });
  PFA.glyph('m06-dam', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a bank dam: crossed sticks over grey stones, mud between; an otter head peeks over on frame 1 */
    K.bx(c, x - 4, y + 1, 9, 2, XC[9]); K.px(c, x - 2, y + 1, A); K.px(c, x + 2, y + 2, A);
    K.ln(c, x - 4, y, x + 4, y - 2, 1, XC[10]); K.ln(c, x - 4, y - 2, x + 3, y, 1, XC[10]); K.px(c, x, y - 1, A);
    if (fr & 1) { K.sq(c, x + 1, y - 4, 3, C); K.px(c, x, y - 5, C); K.px(c, x + 2, y - 5, C); K.px(c, x + 1, y - 4, XC[13]); K.px(c, x + 2, y - 3, Hi); }
  });
  PFA.glyph('m06-tossfish', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a silver fish flipping end over end in the air, a glint on its flank */
    var a = (fr & 3) * Math.PI / 4 + .3, dx = Math.cos(a), dy = Math.sin(a), i;
    for (i = -2; i <= 2; i++) K.px(c, x + dx * i, y + dy * i, XC[11]);
    K.px(c, x + dx * 2 - dy, y + dy * 2 + dx, XC[11]); K.px(c, x - dx * 3 + dy, y - dy * 3 - dx, A); K.px(c, x - dx * 3 - dy, y - dy * 3 + dx, A);
    K.px(c, x + dx * 2, y + dy * 2, XC[13]); K.px(c, x, y, fr & 1 ? K.WHITE : Hi);
  });
  PFA.glyph('m06-rat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* black ship rat side-on: round ear, bead eye, pink nose and long pink tail, legs scurrying */
    spr(c, fr & 1 ? RAT1 : RAT0, x, y, face(tx, nx, ny), C, A, Hi, K);
  });
  PFA.glyph('m06-ratswing', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a rope hanging from a spar, a rat clinging at the end and swinging (fr = swing step 0..4) */
    var sw = (fr - 2) * 1.6, L = 6 + z, i, ex = x + sw, ey = y + L - 3;
    K.bx(c, x - 3, y - 4, 7, 1, XC[10]);
    for (i = 0; i <= L; i++) K.px(c, x + sw * i / L, y - 3 + i, i & 1 ? XC[10] : A);
    spr(c, RATH, ex, ey + 2, 1, C, A, Hi, K); K.px(c, ex - 1, ey + 4, XC[8]); K.px(c, ex - 2, ey + 5, XC[8]);
  });
  PFA.glyph('m06-rigging', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* tarred ratlines: a rope net square, two pairs of rat eyes glinting through the mesh */
    var i;
    for (i = -4; i <= 4; i += 2) { K.bx(c, x - 4, y + i, 9, 1, A); K.bx(c, x + i, y - 4, 1, 9, XC[10]); }
    K.px(c, x - 3 + (fr & 1), y - 1, Hi); K.px(c, x - 1 + (fr & 1), y - 1, Hi);
    if (fr !== 1) { K.px(c, x + 1, y + 3, XC[8]); K.px(c, x + 3, y + 3, XC[8]); }
    K.px(c, x + (fr & 1 ? 2 : -2), y - 3, C); K.px(c, x + (fr & 1 ? 3 : -3), y - 3, C);
  });
  PFA.glyph('m06-plank', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a gangplank shoved out of the edge: wood boards, nail heads, a rat riding the far end */
    var L = 8 + z * 2, i, X, Y, tip = fr & 1 ? 1 : 0;
    for (i = 0; i <= L; i++) { X = x + nx * (i - 3) + tx * tip * (i / L) * 2; Y = y + ny * (i - 3) + ty * tip * (i / L) * 2;
      K.px(c, X - tx, Y - ty, XC[10]); K.px(c, X, Y, (i % 3) === 0 ? A : XC[10]); K.px(c, X + tx, Y + ty, (i % 4) === 1 ? XC[4] : A); }
    X = x + nx * (L - 2) + tx * tip * 2; Y = y + ny * (L - 2) + ty * tip * 2 - 3;
    K.sq(c, X, Y, 3, C); K.px(c, X + 1, Y - 2, C); K.px(c, X + 1, Y, XC[13]);
  });
  PFA.glyph('m06-backotter', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* sea otter floating on its back: pale masked face, a stone on its tummy, paws bringing a clam down on it */
    var fl = face(tx, nx, ny);
    spr(c, fr & 1 ? BO1 : BO0, x, y, fl, C, A, Hi, K);
    if (fr & 1) { K.px(c, x - fl * 2, y - 3, K.WHITE); K.px(c, x - fl * 5, y - 2, K.WHITE); K.px(c, x - fl * 3, y - 4, Hi); }
  });
  PFA.glyph('m06-clam', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a ridged clam: shut, gaping, then cracked in two with white shards flying */
    var g = fr === 0 ? 0 : 1, i;
    for (i = -3; i <= 3; i++) { K.px(c, x + i, y - 1 - g - (Math.abs(i) < 3 ? 1 : 0), Hi); K.px(c, x + i, y + 1 + (Math.abs(i) < 3 ? 1 : 0), Hi); }
    K.px(c, x - 1, y - 2 - g, A); K.px(c, x + 1, y - 2 - g, A); K.px(c, x - 4, y, A);
    if (fr === 1) K.bx(c, x - 2, y - 1, 5, 2, XC[8]);
    if (fr >= 2) { K.px(c, x + 1, y - 1, K.WHITE); K.px(c, x, y, K.WHITE); K.px(c, x + 1, y + 1, K.WHITE);
      K.px(c, x + 4 + fr, y - 3 - fr, K.WHITE); K.px(c, x - 4 - fr, y - 4, K.WHITE); K.px(c, x + 2, y - 5 - fr, Hi); }
  });
  PFA.glyph('m06-kelpwrap', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a kelp frond looped round a sleeping sea otter's head, air bladders bobbing */
    var i, a, X, Y;
    for (i = 0; i < 12; i++) { a = i * .55 + fr * .4; X = x + Math.cos(a) * (3 + i * .2); Y = y + Math.sin(a) * 2.5 + 1; K.px(c, X, Y, XC[6]); }
    K.sq(c, x + Math.cos(fr * .4 + 6) * 5, y + 1 + Math.sin(fr * .4 + 6) * 2.5, 2, XC[12]); K.px(c, x - 4, y - 1, XC[12]);
    spr(c, OTH, x, y - 1, 1, C, A, Hi, K);
  });
  PFA.glyph('m06-pebble', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a smooth favourite pebble; on frame 1 a furry armpit fold closes over it (the pocket) */
    K.bx(c, x - 2, y - 1, 5, 3, XC[9]); K.bx(c, x - 1, y - 2, 3, 1, XC[9]); K.px(c, x - 1, y - 1, K.WHITE); K.px(c, x + 2, y + 1, A);
    if (fr & 1) { K.ln(c, x - 3, y - 2, x + 3, y - 2, 1, C); K.px(c, x - 3, y - 1, C); K.px(c, x + 3, y - 1, C); K.px(c, x, y - 3, C); }
    else if (fr === 2) K.plus(c, x + 3, y - 3, 1, 1, K.WHITE);
  });
  PFA.glyph('m06-leech', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a segmented leech along the edge, arching into an inchworm loop (fr 0 flat, 1 half, 2 high); suckers at both ends */
    var n = 4 + (z > 1 ? 1 : 0), i, h, sp = fr === 2 ? .7 : 1, X, Y;
    for (i = -n; i <= n; i++) { h = fr ? (fr === 2 ? 4 : 2) * Math.cos(i / n * 1.57) : 0; X = x + tx * i * sp + nx * h; Y = y + ty * i * sp + ny * h;
      K.px(c, X, Y, (i & 1) ? A : C); K.px(c, X - nx, Y - ny, C); if (i === 0) K.px(c, X + nx, Y + ny, Hi); }
    K.px(c, x - tx * n * sp - nx, y - ty * n * sp - ny, A); K.px(c, x + tx * n * sp - nx, y + ty * n * sp - ny, A);
  });
  PFA.glyph('m06-sucker', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the leech mouth head-on: a fleshy sucker ring opening, a white Y of three tiny jaws inside */
    var r = 2 + (fr === 1 ? 1 : 0) + (z > 1 ? 1 : 0);
    K.sq(c, x, y, 2 * r + 1, C); K.ringpx(c, x, y, r, A); K.ringpx(c, x, y, r + 1, fr === 2 ? Hi : C);
    K.px(c, x, y, A); K.px(c, x, y - 1, K.WHITE); K.px(c, x - 1, y + 1, K.WHITE); K.px(c, x + 1, y + 1, K.WHITE);
    if (fr === 2) { K.px(c, x + nx * (r + 3), y + ny * (r + 3), XC[7]); }
  });
  PFA.glyph('m06-gorged', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a leech swelling fat with blood (fr 0..3), a red belly showing through, a drop welling at the tail */
    var w = 3 + Math.min(3, fr) + (z > 1 ? 1 : 0), h = 2 + (fr >> 1), i, j;
    for (i = -w; i <= w; i++) for (j = -h; j <= h; j++) if ((i * i) / (w * w) + (j * j) / (h * h) <= 1.05) K.px(c, x + i, y + j, j > 0 && Math.abs(i) < w - 1 && fr > 0 ? XC[7] : (i & 1) && j < 0 ? A : C);
    K.px(c, x - 1, y - h, Hi); K.px(c, x + w, y, A); K.px(c, x - w - 1, y, A);
    if (fr >= 2) { K.px(c, x - w, y + h + fr - 1, XC[7]); K.px(c, x - w, y + h + fr, XC[7]); }
  });
  PFA.glyph('m06-mire', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a boot-length black mire leech heaving its ridged back out of the bog, a wet gloss line on top */
    var w = 6 + z, i, h, hh = fr & 1 ? 5 : 3, X, Y;
    for (i = -w; i <= w; i++) { h = Math.round(hh * Math.sqrt(Math.max(0, 1 - (i / w) * (i / w)))); X = x + tx * i; Y = y + ty * i;
      for (var j = 0; j <= h; j++) K.px(c, X + nx * j, Y + ny * j, (i % 3) === 0 && j < h ? A : C);
      if (h > 1 && (i & 1)) K.px(c, X + nx * (h + 1), Y + ny * (h + 1), (i % 4) === 1 ? K.WHITE : Hi); }
    K.px(c, x - tx * (w + 1), y - ty * (w + 1), A); K.px(c, x + tx * (w + 1), y + ty * (w + 1), A);
  });
  PFA.glyph('m06-tigerleech', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a rainforest leaf tip with an orange-brown striped leech dangling and stretching below it */
    var L = 4 + (fr & 1) * 2 + z, i, sw = fr & 1 ? 1 : 0;
    K.ln(c, x - 4, y - 3, x + 2, y - 1, 1, XC[12]); K.ln(c, x - 3, y - 4, x + 2, y - 2, 1, XC[12]); K.px(c, x - 4, y - 4, XC[6]);
    for (i = 0; i < L; i++) { K.px(c, x + 1 + (i > L / 2 ? sw : 0), y + i, (i % 2) ? A : C); K.px(c, x + 2 + (i > L / 2 ? sw : 0), y + i, (i % 2) ? C : Hi); }
    if (fr === 2 || fr === 3) { K.px(c, x - 2, y + 2, A); K.px(c, x - 2, y + 3, C); K.px(c, x - 2, y + 4, A); }   /* the twin */
  });
  PFA.glyph('m06-brineleech', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a flat grey-green leech swimming in an S wave, white salt grains caught on its back */
    var n = 5 + z, i, w, X, Y;
    for (i = -n; i <= n; i++) { w = Math.sin(i * .9 + fr * 1.57) * 1.6; X = x + tx * i + nx * w; Y = y + ty * i + ny * w;
      K.px(c, X, Y, C); K.px(c, X + nx, Y + ny, (i & 1) ? A : C); if ((i + fr) % 4 === 0) K.px(c, X - nx, Y - ny, K.WHITE); }
    K.px(c, x + tx * (n + 1), y + ty * (n + 1), A);
  });
  PFA.glyph('m06-saltcrust', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a crust of cubic salt crystals pushing out of the edge, one corner flashing */
    var g = fr;
    K.bx(c, x - 3, y - 1, 3, 3, K.WHITE); K.px(c, x - 1, y + 1, Hi);
    K.bx(c, x + 1, y - 2 - g, 2, 2 + g, K.WHITE); K.px(c, x + 2, y - 1, Hi);
    K.bx(c, x - 1, y - 3 - g, 2, 2, Hi); K.px(c, x - 4, y + 2, A); K.px(c, x + 3, y + 1, A);
    if (fr === 2) K.plus(c, x + 1, y - 5, 1, 1, K.WHITE);
  });
  PFA.glyph('m06-gar', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a long slim garfish along the edge: needle jaws with a tooth row, dark back line, silver belly, forked tail flicking */
    var n = 5 + z, i, X, Y, ft = fr & 1 ? 1 : -1;
    for (i = -n; i <= n; i++) { X = x + tx * i; Y = y + ty * i; K.px(c, X, Y, C); K.px(c, X + nx, Y + ny, A); if (i > -n && i < n - 1) K.px(c, X - nx, Y - ny, i & 1 ? Hi : K.WHITE); }
    K.px(c, x + tx * (n - 1) + nx * 0, y + ty * (n - 1), XC[13]);
    for (i = 1; i <= 5; i++) { X = x + tx * (n + i); Y = y + ty * (n + i); K.px(c, X, Y, A); if (i & 1) K.px(c, X - nx, Y - ny, K.WHITE); }
    X = x - tx * (n + 1); Y = y - ty * (n + 1); K.px(c, X + nx * ft, Y + ny * ft, A); K.px(c, X - tx + nx * 2 * ft, Y - ty + ny * 2 * ft, A); K.px(c, X - tx - nx * ft, Y - ty - ny * ft, A);
  });
  PFA.glyph('m06-ganoid', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* bony diamond scale plates, dark-rimmed, a white shine walking across them */
    var k, cx;
    for (k = -1; k <= 1; k++) { cx = x + k * 4;
      K.px(c, cx, y - 2, A); K.px(c, cx - 1, y - 1, A); K.px(c, cx + 1, y - 1, A); K.px(c, cx - 2, y, A); K.px(c, cx + 2, y, A); K.px(c, cx - 1, y + 1, A); K.px(c, cx + 1, y + 1, A); K.px(c, cx, y + 2, A);
      K.px(c, cx, y - 1, C); K.px(c, cx - 1, y, C); K.px(c, cx + 1, y, C); K.px(c, cx, y + 1, C); K.px(c, cx, y, (fr & 3) === k + 1 ? K.WHITE : Hi); }
  });
  PFA.glyph('m06-garleap', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a garfish arcing out of the water: nose up, level, nose down; a splash ring at the waterline on take-off and re-entry */
    var a = fr === 0 ? -.6 : fr === 1 ? 0 : .6, fl = face(tx, nx, ny), dx = Math.cos(a) * fl, dy = Math.sin(a), i, n = 5;
    for (i = -n; i <= n; i++) { K.px(c, x + dx * i, y + dy * i, C); K.px(c, x + dx * i - dy * 0, y + dy * i + 1, i & 1 ? Hi : K.WHITE); }
    for (i = 1; i <= 4; i++) K.px(c, x + dx * (n + i), y + dy * (n + i), A);
    K.px(c, x - dx * (n + 1), y - dy * (n + 1) - 1, A); K.px(c, x - dx * (n + 1), y - dy * (n + 1) + 2, A);
    if (fr !== 1) { K.px(c, x - 4, y + 6, K.DEW); K.px(c, x - 2, y + 7, K.WHITE); K.px(c, x + 2, y + 7, K.WHITE); K.px(c, x + 4, y + 6, K.DEW); K.px(c, x, y + 5, K.DEW); }
    else K.plus(c, x + dx * 2, y - 3, 1, 1, K.WHITE);
  });

  /* ---------- motions (mutate the scratch G; pp = time x speed) ---------- */
  PFA.motion('m06-bob', function (G, pp, k, ph) { G.up += Math.sin(pp * 6 + k * 1.3) * 1.5; G.fr = (Math.floor(pp * 5 + ph * 3) + k) & 1; });          /* float, flippers flap */
  PFA.motion('m06-squeak', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 3 + ph) % 1) * 3); G.up += G.fr ? 1 : 0; });
  PFA.motion('m06-slap', function (G, pp, k, ph) { var w = (pp * 2.5 + ph) % 1; G.fr = w < .45 ? 0 : w < .6 ? 1 : 2; G.d -= G.fr === 1 ? 1 : 0; });
  PFA.motion('m06-galumph', function (G, pp, k) { G.s += pp * .1; G.fr = (Math.floor(pp * 6) + k) & 1; G.up += G.fr * 2; });                       /* hump along on the belly */
  PFA.motion('m06-tilt', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 4) + k) & 3; G.up += (G.fr & 1) ? 1 : 0; });
  PFA.motion('m06-bellyslide', function (G, pp, k) { G.s += pp * .5; G.fr = (Math.floor(pp * 10) + k) & 1; });
  PFA.motion('m06-toss', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.up += Math.sin(w * Math.PI) * 9; G.t += (w - .5) * 6; G.fr = Math.floor(w * 8) & 3; });
  PFA.motion('m06-scurry', function (G, pp, k, ph) { G.s += pp * .5; G.fr = (Math.floor(pp * 20) + k) & 1; G.t += (H0(k * 3.1 + Math.floor(pp * 10)) - .5) * 2; });
  PFA.motion('m06-pendulum', function (G, pp, k) { G.fr = Math.round((Math.sin(pp * 7 + k) + 1) * 2); });                                           /* swing step 0..4 */
  PFA.motion('m06-plank', function (G, pp, k, ph) { G.fr = ((pp * 2 + ph) % 1) > .5 ? 1 : 0; });
  PFA.motion('m06-whack', function (G, pp, k, ph) { G.fr = ((pp * 3 + ph) % 1) > .6 ? 1 : 0; G.up += G.fr ? 0 : 1; G.t += Math.sin(pp * 4 + k) * .8; });
  PFA.motion('m06-crack', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 2 + ph) % 1) * 4)); });
  PFA.motion('m06-tuck', function (G, pp, k, ph) { var w = (pp * 2.5 + ph) % 1; G.fr = w < .4 ? 0 : w < .55 ? 2 : 1; });
  PFA.motion('m06-inch', function (G, pp, k) { var w = pp * 4 + k * .7, st = Math.floor(w); G.fr = st % 3; G.s += st * .018; G.up += G.fr === 2 ? 1 : 0; });   /* loop step by step */
  PFA.motion('m06-suck', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) % 3; G.d -= 1; });
  PFA.motion('m06-swell', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.2 + ph * .3) % 1) * 5)); });
  PFA.motion('m06-heave', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.fr = w < .5 ? 0 : 1; G.up += Math.sin(w * Math.PI) * 2; });
  PFA.motion('m06-undulate', function (G, pp, k) { G.s += pp * .25; G.fr = (Math.floor(pp * 12) + k) & 3; G.t += Math.sin(pp * 10 + k) * 1.5; });
  PFA.motion('m06-skim', function (G, pp, k) { G.s += pp * .45; G.fr = (Math.floor(pp * 14) + k) & 1; G.d += Math.abs(Math.sin(pp * 8 + k)); });
  PFA.motion('m06-leap', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; G.up += Math.sin(w * Math.PI) * 10; G.fr = w < .35 ? 0 : w < .65 ? 1 : 2; });
  function H0(n) { n = Math.sin(n * 127.1 + 311.7) * 43758.5453; return n - Math.floor(n); }   /* same hash as the page (motions get no H argument in older pages) */

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ---------- */
  function carRaft(c, e, H) {           /* a little ice raft drifts along the edge with two fluffy pups riding it, rocking, swell dashes behind */
    var P = e.P, Q = H.Q, s = e.a + e.d * e.hh, k, u, X, Y, rk = Math.round(Math.sin(e.p * 12));
    for (k = 1; k <= 4; k++) { u = e.hh - k * .06; if (u < 0) break; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4 + 3, k & 1 ? H.DEW : H.WHITE); H.px(c, Q.x + Q.nx * 4 + 1, Q.y + Q.ny * 4 + 3, H.DEW); }
    P.atq(s); X = Q.x + Q.nx * 6; Y = Q.y + Q.ny * 6;
    H.bx(c, X - 6, Y + 3 + rk, 6, 2, H.WHITE); H.bx(c, X, Y + 3 - rk, 6, 2, H.WHITE); H.bx(c, X - 5, Y + 5, 10, 1, e.hi);
    H.glyph(c, 'm06-pup', X - 3, Y - 1 + rk, 0, e.fr, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
    H.glyph(c, 'm06-pup', X + 3, Y - 1 - rk, 0, 1 - e.fr, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  function carSlide(c, e, H) {          /* the otter belly-slides the edge: a glossy wet mud streak behind it, a splash where it lands */
    var P = e.P, Q = H.Q, u, k;
    for (u = 0; u <= e.hh; u += .03) { P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, ((u * 33) | 0) % 4 === 0 ? H.WHITE : e.acc); if (u > e.hh - .25) H.px(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4, e.hi); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm06-otter', e.z, e.fr, 0, -1, e.col, e.acc, e.hi);
    if (e.p > .82) { u = (e.p - .82) / .18; P.atq(e.a + e.d); for (k = -2; k <= 2; k++) H.px(c, Q.x + Q.nx * 5 + k * (2 + 3 * u), Q.y + Q.ny * 5 - 2 - Math.abs(k) * 2 * (1 - u) - 4 * u, Math.abs(k) === 1 ? H.WHITE : H.DEW); }
  }
  function carRope(c, e, H) {           /* a tarred hawser runs along the edge and the crew scurries along it nose to tail */
    var P = e.P, Q = H.Q, u, k, X, Y;
    for (u = 0; u <= e.hh; u += .02) { P.atq(e.a + e.d * u); X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3; H.px(c, X, Y, ((u * 50) | 0) & 1 ? '#b07a40' : e.acc); }
    for (k = 0; k < 3; k++) { u = e.hh - k * .07; if (u < 0) break; H.carHead(c, P, e.a + e.d * u, 'm06-rat', e.z, (e.fr + k) & 1, 0, -2 - ((e.fr + k) & 1), e.col, e.acc, e.hi); }
  }
  function carInch(c, e, H) {           /* the leech loops along the edge one inchworm step at a time, a slime sheen left on each foothold */
    var P = e.P, Q = H.Q, st = Math.floor(e.p * 9), ph = e.p * 9 - st, u = Math.min(1, (st + H.eo(ph)) / 9), k;
    for (k = 1; k <= st && k <= 8; k++) { P.atq(e.a + e.d * k / 9); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.hi); H.px(c, Q.x + Q.nx * 3 + 1, Q.y + Q.ny * 3, e.hi); }
    H.carHead(c, P, e.a + e.d * u, 'm06-leech', e.z, ph < .5 ? 2 : ph < .8 ? 1 : 0, 0, 0, e.col, e.acc, e.hi);
  }
  function carSkip(c, e, H) {           /* the garfish skips across the surface in three long leaps, a splash ring left at every touch-down */
    var P = e.P, Q = H.Q, k, u, l = e.hh * 3, j = Math.min(2, Math.floor(l)), w = l - j, r;
    for (k = 1; k <= j; k++) { P.atq(e.a + e.d * k / 3); r = 1 + Math.min(4, (l - k) * 5); H.ringpx(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5 + 3, r, r > 3 ? e.hi : H.WHITE); }
    u = e.hh; H.carHead(c, P, e.a + e.d * u, 'm06-gar', e.z, e.fr, 0, -Math.sin(w * Math.PI) * 9, e.col, e.acc, e.hi);
  }

  /* ---------- motifs ---------- */
  function M(name, draw, meta) { PFA.motif(name, draw, meta); }
  function swell(c, e, H) { comp(c, e, H, decoSwell); }
  function slime(c, e, H) { comp(c, e, H, decoSlime); }
  /* seals */
  M('pup-raft', swell, { nm: 'pup raft', desc: 'round white fluffball seal pups with huge dark eyes bobbing together on the swell, flippers flapping; the chain is an ice raft drifting with two pups aboard', fam: 'ripple', gap: 14, g: 'm06-pup', mo: 'm06-bob', x: '-', car: 'custom', carDraw: carRaft });
  M('whisker-squeak', plain, { nm: 'whisker squeaks', desc: 'a pup muzzle with whiskers fanning wider and a three-ray squeak burst popping out', fam: 'puff', gap: 16, g: 'm06-whisker', mo: 'm06-squeak', x: '-', car: 'rings' });
  M('flipper-splash', plain, { nm: 'flipper slaps', desc: 'a foreflipper raised then slapped flat on the water, a fan of splash drops thrown up', fam: 'ripple', gap: 14, g: 'm06-flipper', mo: 'm06-slap', x: '-', car: 'hop' });
  M('scar-neck-seal', plain, { nm: 'scarred bull seals', desc: 'side-view grey seals with a thick pale-scarred neck humping along on their bellies (galumph)', fam: 'bash', gap: 18, g: 'm06-greyseal', mo: 'm06-galumph', x: 'snow', car: 'hop' });
  M('ice-floe-slab', plain, { nm: 'ice floes', desc: 'white ice floe slabs with a blue crack tilting on dark water, ice chips flicking off', fam: 'shield', gap: 14, g: 'm06-floe', mo: 'm06-tilt', x: '-', car: 'roll' });
  /* otters */
  M('otter-slide', plain, { nm: 'belly-sliding otters', desc: 'sleek brown otters stretched flat on their bellies, whiskers forward, shooting along; the chain is a belly slide down a wet mud streak with a splash at the end', fam: 'slash', gap: 18, g: 'm06-otter', mo: 'm06-bellyslide', x: '-', car: 'custom', carDraw: carSlide });
  M('otter-dam', plain, { nm: 'bank dams', desc: 'crossed sticks over grey stones built up one by one, an otter head peeking over the top', fam: 'shield', gap: 14, g: 'm06-dam', mo: 'build', x: '-', car: 'train' });
  M('fish-toss', plain, { nm: 'tossed fish', desc: 'silver fish flipped end over end through the air in arcs, a glint on the flank', fam: 'web', gap: 14, g: 'm06-tossfish', mo: 'm06-toss', x: '-', car: 'hop' });
  M('tummy-anvil', swell, { nm: 'tummy anvils', desc: 'sea otters floating on their backs with a stone on the tummy, bringing a clam down on it, crack marks; swell under them', fam: 'bash', gap: 18, g: 'm06-backotter', mo: 'm06-whack', x: '-', car: 'roll' });
  M('clam-crack', plain, { nm: 'cracked clams', desc: 'ridged clams shut, gaping pink, then cracked in two with white shards flying', fam: 'bite', gap: 14, g: 'm06-clam', mo: 'm06-crack', x: '-', car: 'hop' });
  M('kelp-raft', swell, { nm: 'kelp wraps', desc: 'kelp fronds looped round a masked sea otter head, air bladders bobbing as it drifts', fam: 'leaf', gap: 14, g: 'm06-kelpwrap', mo: 'sway', x: 'kelp', car: 'flutter' });
  M('pebble-pocket', plain, { nm: 'pocket pebbles', desc: 'smooth favourite pebbles with a glint, a furry armpit fold closing over each one', fam: 'sparkle', gap: 12, g: 'm06-pebble', mo: 'm06-tuck', x: '-', car: 'blink' });
  /* ship rats */
  M('ship-rat', plain, { nm: 'ship rats', desc: 'black ship rats with bead eyes and long pink tails scurrying nose to tail; the chain is the crew running a tarred hawser', fam: 'bite', gap: 13, g: 'm06-rat', mo: 'm06-scurry', x: '-', car: 'custom', carDraw: carRope });
  M('rat-rope-swing', plain, { nm: 'rope swings', desc: 'ropes hanging from a spar with a rat clinging at the end, swinging out and back', fam: 'bash', gap: 16, g: 'm06-ratswing', mo: 'm06-pendulum', x: '-', car: 'thread' });
  M('ship-rigging', plain, { nm: 'tarred ratlines', desc: 'a square of tarred rope net with rat eyes glinting through the mesh', fam: 'shield', gap: 14, g: 'm06-rigging', mo: 'sway', x: '-', car: 'train' });
  M('gangplank', plain, { nm: 'gangplanks', desc: 'a nailed wooden gangplank shoved straight out of the edge, tipping, a rat riding the far end', fam: 'bash', gap: 18, g: 'm06-plank', mo: 'm06-plank', x: '-', car: 'roll' });
  /* leeches */
  M('leech-loop', slime, { nm: 'looping leeches', desc: 'segmented leeches arching into inchworm loops sucker to sucker, slime strings sagging; the chain loops along step by step', fam: 'drip', gap: 14, g: 'm06-leech', mo: 'm06-inch', x: '-', car: 'custom', carDraw: carInch });
  M('leech-sucker', plain, { nm: 'leech suckers', desc: 'a leech mouth head-on: a fleshy sucker ring opening, a white Y of three tiny jaws inside, a red bead when it bites', fam: 'bite', gap: 14, g: 'm06-sucker', mo: 'm06-suck', x: '-', car: 'rings' });
  M('leech-gorge', plain, { nm: 'gorged leeches', desc: 'leeches swelling fat with blood, a red belly showing through, a drop welling at the tail', fam: 'mend', gap: 16, g: 'm06-gorged', mo: 'm06-swell', x: '-', car: 'trail' });
  M('mire-ridge', plain, { nm: 'mire leech backs', desc: 'a boot-length black ridged leech back heaving up out of the bog with a wet white gloss line; the chain surfaces in mud mounds', fam: 'bash', gap: 18, g: 'm06-mire', mo: 'm06-heave', x: 'bubbles', car: 'tunnel' });
  M('tiger-drop', plain, { nm: 'leaf-drop leeches', desc: 'striped orange-brown leeches dangling and stretching from rainforest leaf tips, a twin dropping beside', fam: 'drip', gap: 14, g: 'm06-tigerleech', mo: 'dangle', x: 'dew', car: 'thread' });
  M('brine-swim', plain, { nm: 'brine swimmers', desc: 'flat grey-green leeches swimming in an S wave, white salt grains caught on their backs', fam: 'ripple', gap: 14, g: 'm06-brineleech', mo: 'm06-undulate', x: 'glint', car: 'trail' });
  M('salt-crust', plain, { nm: 'salt crusts', desc: 'clusters of cubic white salt crystals pushing out of the edge, a corner flashing', fam: 'thorn', gap: 10, g: 'm06-saltcrust', mo: 'pulse', x: '-', car: 'blink' });
  /* garfish */
  M('needle-gar', plain, { nm: 'needle gars', desc: 'long slim silver-green garfish with needle jaws and a tooth row, skimming the surface; the chain skips across in three leaps leaving splash rings', fam: 'thrust', gap: 22, g: 'm06-gar', mo: 'm06-skim', x: '-', car: 'custom', carDraw: carSkip });
  M('gar-scale', plain, { nm: 'ganoid scales', desc: 'bony diamond scale plates with dark rims, a white shine walking across them', fam: 'shield', gap: 14, g: 'm06-ganoid', mo: 'shimmer', x: '-', car: 'train' });
  M('gar-leap', plain, { nm: 'gar leaps', desc: 'a garfish arcing out of the water nose up, level, nose down, splash rings on take-off and re-entry', fam: 'sparkle', gap: 18, g: 'm06-garleap', mo: 'm06-leap', x: '-', car: 'hop' });
})();
