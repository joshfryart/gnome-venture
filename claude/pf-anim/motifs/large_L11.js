/* Motif module, large batch L11 (moray-lurker, reef-eel-lord, reef-eel-tyrant, conger-brute, bog-pike, elephant-seal-bull, salt-sea-lion,
   giant-otter-gang, deep-octopus, kraken-spawn). TEMPLATE.md sections 9 and 10.3. 52 motifs, each with its own pixel glyph (ids prefixed L11-) and one of
   eleven motions; seven have their own chain effect (carDraw): a moray sliding under a rock ridge and poking out of the next crack, a rusted anchor chain
   dragged to the next piece, a bog pike torpedoing through reeds that bend after it, a striped ball bounced nose to nose in three hops, giant otters
   porpoising in a line, an octopus arm reaching along the edge with a curling tip, a kraken tentacle arching out of the sea and slapping down.
   Glyph coordinates are (a, b): a along the edge tangent, b outward along the normal, so every sprite turns with the edge it sits on. fr0() stores the
   frame in module scratch variables, p()/s()/row()/cl()/lin() plot in (a, b). Glyph draws never nest, so the scratch is safe; nothing is allocated per
   frame (the constant tables below are built once at load), there is no Math.random / Date, every effect is a stateless function of p.
   Glyphs go through H.glyph so the MAXG budget counts them; the own-edge composition caps them at 7 per run (large creatures: slightly richer sprites,
   same budget). The wiggle (x 2.6 px, rot .06), the outer-edge chain rule, visual-only sound lines and the creature-heavy default are untouched (they
   live in the page). Glyphs reach at most ~15 px out and stay within ~22 px of the edge with their layout offset. */
(function () {
  var X0 = 0, Y0 = 0, TX = 1, TY = 0, NX = 0, NY = -1, KK = null;
  var TOOTH = '#f2ecd8', ROCK = '#8a8276', ROCKD = '#3a342e', CORAL = '#f07a8a', SPARK = '#fff07a', VENOM = '#9ad04a', RIVET = '#5a3020', WEED = '#6a9a3a',
    RUSTF = '#d0703a', REED = '#b8c070', CAT = '#8a5a30', PINK = '#f08a9a', SAND = '#d8c08a', RED = '#e84a3a', BLUE = '#4a8ee0', FISH = '#d2dce4', GLOW = '#9ae8a0',
    BAND = '#b8bcc0', INK = '#2a2038';
  var HL = [2, 6, 7, 10], GROW = [0, 1, 2, 1], GP = [0, 3, 3, 0], IJ = [0, 0, 4, 0], SP = [1, 2, 4, 3], KR = [4.5, 4, 3.5, 3], HC = [0, 3, 6, 9],
    PL = [8, 7, 11, 11], SWY = [-1, 0, 1, 0], OPJ = [3, 1.5, 0, 0], SWG = [-4, -1, 4, 2], INF = [0, 1, 2, 0], RH = [6, 10, 3, 3], BB = [0, 3, 5, 3], PH = [3, 6, 9, 9],
    FEA = [0, -6, 8, 6], FEB = [9, 7, 3, 6], CU = [.12, .25, .42, .6], OS = [1, 3, 5, 2], JL = [2, 6, 10, 6], CBP = [8, 4, 2, 3], MR = [2, 3, 4, 1],
    SA = [-.94, -.57, 0, .57, .94], SB = [.34, .82, 1, .82, .34], TF = [0, 1, 0, -1],
    AD = [-1, .1, -.85, -.45, -.5, -.85, -.2, -1, .2, -1, .5, -.85, .85, -.45, 1, .1],
    CB = [0, 0, 0, 4, -3, 7, 3, 7, -4, 4, 0, 4, 3, 1, 3, 7, 0, 8, 0, 4, -3, 1, 3, 1];      /* coral chip: stem from (a,b)-(a,b), two branch tips, per frame */
  var CUP = [], i0;                                                       /* 12 ring directions, built once */
  for (i0 = 0; i0 < 12; i0++) { CUP.push(Math.cos(i0 * Math.PI / 6)); CUP.push(Math.sin(i0 * Math.PI / 6)); }

  function fr0(x, y, tx, ty, nx, ny, K) { X0 = x; Y0 = y; TX = tx; TY = ty; NX = nx; NY = ny; KK = K; }
  function p(c, a, b, col) { KK.px(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, col); }
  function s(c, a, b, w, col) { KK.sq(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, w, col); }
  function row(c, a0, a1, b, col) { for (var a = a0; a <= a1; a++) p(c, a, b, col); }
  function cl(c, a, b0, b1, col) { for (var b = b0; b <= b1; b++) p(c, a, b, col); }
  function lin(c, a0, b0, a1, b1, col) { var n = Math.max(Math.abs(a1 - a0), Math.abs(b1 - b0)), i; if (n < 1) { p(c, a0, b0, col); return; }
    for (i = 0; i <= n; i++) p(c, a0 + (a1 - a0) * i / n, b0 + (b1 - b0) * i / n, col); }
  function ring(c, ac, bc, r, col, every) { for (var i = 0; i < 12; i += every) p(c, ac + CUP[i * 2] * r, bc + CUP[i * 2 + 1] * r, col); }
  function star(c, a, b, col) { p(c, a, b, col); p(c, a - 1, b - 1, col); p(c, a + 1, b - 1, col); p(c, a - 1, b + 1, col); p(c, a + 1, b + 1, col); }
  function vee(c, a, b, col) { p(c, a - 1, b + 1, col); p(c, a, b, col); p(c, a + 1, b + 1, col); }
  function disc(c, ac, bc, r2, col) { var a, b, r = Math.ceil(Math.sqrt(r2)); for (b = -r; b <= r; b++) for (a = -r; a <= r; a++) if (a * a + b * b <= r2) p(c, ac + a, bc + b, col); }

  /* ---------- shared own-edge composition: the page's themedOwn() with this module's glyph / motion (glyphs capped at 7 per run) ---------- */
  function comp(c, e, H) {
    var runs = e.runs, mp = e.mp, M = e.M, z = e.z, pr = e.p, pp = pr * mp.spd, Q = H.Q, G = H.G, P = e.P,
      tie = mp.x === 'thread' || mp.lay === 'snare', ri, k, r, len, n, ph, sf, bx0, by0, nx, ny, x, y, lx = 0, ly = 0, has;
    for (ri = 0; ri < runs.length; ri++) {
      r = runs[ri]; len = r[1] - r[0]; n = Math.max(1, Math.min(7, Math.round(len / (M.gap || 12)))); if (mp.lay === 'lance') n = Math.min(n, 4); has = false;
      for (k = 0; k < n; k++) {
        ph = H.hash(e.seed * 13 + k * 7 + ri * 31);
        H.lay(mp.lay, pr, (k + .5) / n, ph, k); H.mot(M.mo, pp, k, ph);
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

  /* ================= glyphs (fr 0..3, z 0..2) ================= */
  /* --- moray lurker: mottled green-brown, jaws out of a rock crack --- */
  PFA.glyph('L11-crackhead', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* rock slabs, a dark crack; the head peeps, comes out, gapes on its teeth, lunges with a star */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, L = HL[fr] + w, a, b;
    row(c, -8 - w, -2, 0, ROCK); row(c, -7 - w, -2, 1, ROCK); p(c, -5, 1, ROCKD); row(c, 2, 8 + w, 0, ROCK); row(c, 2, 7 + w, 1, ROCK); p(c, 4, 1, ROCKD); row(c, -1, 1, 0, ROCKD);
    for (b = 1; b <= L; b++) for (a = -1; a <= 1; a++) { if (b === L && a !== 0) continue; p(c, a, b, ((a * 5 + b * 3 + 9) & 3) === 0 ? A : C); }
    p(c, -1, L - 1, Hi);                                                                                  /* the pale eye */
    if (fr === 2) { p(c, -2, L, C); p(c, 2, L, C); p(c, -2, L + 1, C); p(c, 2, L + 1, C); p(c, 0, L, A); p(c, 0, L + 1, A); p(c, -1, L + 1, TOOTH); p(c, 1, L + 1, TOOTH); p(c, -1, L + 2, TOOTH); p(c, 1, L + 2, TOOTH); }
    if (fr === 3) { p(c, 0, L + 1, C); p(c, -1, L, TOOTH); p(c, 1, L, TOOTH); star(c, 0, L + 3, K.WHITE); }
  });
  PFA.glyph('L11-wedge', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the thick mottled body wedged between two rock slabs, swelling to fill the gap */
    fr0(x, y, tx, ty, nx, ny, K); var g = GROW[fr], w = z > 1 ? 1 : 0, a, b, hw;
    for (b = 0; b <= 6 + w; b++) { row(c, -9 - w, -5 + (b > 3 ? 1 : 0), b, ROCK); row(c, 5 - (b > 3 ? 1 : 0), 9 + w, b, ROCK); }
    p(c, -7, 3, ROCKD); p(c, 7, 5, ROCKD); p(c, -6, 6, ROCKD);
    for (b = 0; b <= 5 + w; b++) { hw = (b >= 1 && b <= 4) ? 2 + (g > 0 ? 1 : 0) + (g > 1 && (b === 2 || b === 3) ? 1 : 0) : 2;
      for (a = -hw; a <= hw; a++) p(c, a, b, ((a * 7 + b * 5 + 21) % 5) === 0 ? A : C); }
    p(c, -1, fr + 1, Hi); p(c, 0, fr + 2, Hi);                                                            /* wet sheen sliding over it */
  });
  PFA.glyph('L11-gape', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* jaws gape on needle teeth, the hidden second jaw shoots out of the throat, snap */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, op = GP[fr], ij = IJ[fr], b, q;
    for (b = 0; b <= 5; b++) row(c, -2 - w, 2 + w, b, C); p(c, 1, 1, A); p(c, -2, 2, A); p(c, 2, 4, A); p(c, -1, 4, Hi);
    for (b = 6; b <= 10; b++) { q = (b - 6) / 4 * op;
      if (op) row(c, Math.round(-q) + 1, Math.round(q) - 1, b, A);
      p(c, -1 - q, b, C); p(c, -2 - q, b, C); p(c, 1 + q, b, C); p(c, 2 + q, b, C);
      if (op && (b & 1)) { p(c, -q, b, TOOTH); p(c, q, b, TOOTH); } }
    if (!op) { cl(c, 0, 6, 10, C); p(c, -1, 8, TOOTH); p(c, 1, 9, TOOTH); }
    if (ij) { cl(c, 0, 7, 7 + ij, PINK); p(c, -1, 7 + ij, TOOTH); p(c, 1, 7 + ij, TOOTH); p(c, 0, 8 + ij, TOOTH); }
    if (fr === 3) star(c, 0, 12, K.WHITE);
  });
  PFA.glyph('L11-mottle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* scaleless mottled leather hide, a wet sheen sliding across */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, sh = fr * 3 - 5, a, b, hw, m;
    for (b = 0; b <= 4; b++) { hw = 7 + w - (b > 2 ? (b - 2) * 2 : 0);
      for (a = -hw; a <= hw; a++) { m = (a * 7 + b * 13 + 70) % 5; p(c, a, b, a === sh + b ? Hi : m === 0 ? A : C); } }
    p(c, sh + 2, 5, K.DEW);
  });
  /* --- reef eel lord: blue ribbon eel, yellow jaw and nostril flags, coral home --- */
  PFA.glyph('L11-ribbon', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a thin blue ribbon eel waving up out of a coral hole, yellow fin, jaw and flared nostril flags */
    fr0(x, y, tx, ty, nx, ny, K); var L = 10 + (z > 1 ? 1 : 0), ph = fr * 1.57, b, a;
    row(c, -3, 3, 0, CORAL); p(c, -3, 1, CORAL); p(c, 3, 1, CORAL); row(c, -2, 2, 1, A);
    for (b = 1; b <= L; b++) { a = Math.round(Math.sin(b * .7 + ph) * 1.6); p(c, a, b, C); p(c, a + 1, b, C); if (b > 2 && !(b & 1)) p(c, a - 1, b, Hi); }
    a = Math.round(Math.sin((L + 1) * .7 + ph) * 1.6);
    p(c, a, L, A); p(c, a, L + 1, Hi); p(c, a + 1, L + 1, Hi);
    if (fr & 1) { p(c, a - 1, L + 2, Hi); p(c, a + 2, L + 2, Hi); p(c, a, L + 2, A); p(c, a + 1, L + 2, A); } else { p(c, a, L + 2, Hi); p(c, a + 1, L + 2, Hi); }
    p(c, a - 1, L + 3, Hi); p(c, a + 2, L + 3, Hi);
  });
  PFA.glyph('L11-spark', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* an arched eel crackling with yellow sparks */
    fr0(x, y, tx, ty, nx, ny, K); var a, b, i, j, a0, b0;
    for (a = -6; a <= 6; a++) { b = Math.round(5 - a * a / 9); p(c, a, b, C); p(c, a, b - 1, C); }
    p(c, 7, 1, C); p(c, 6, 2, Hi); p(c, -7, 0, C);
    for (i = 0; i < 3; i++) { if ((i + fr) % 3 === 0) continue; a0 = -4 + i * 4; b0 = Math.round(5 - a0 * a0 / 9) + 1;
      for (j = 0; j < 4; j++) p(c, a0 + ((j & 1) ? 1 : -1), b0 + 1 + j, SPARK); }
    if (fr === 3) star(c, 0, 10, K.WHITE);
  });
  PFA.glyph('L11-coin', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a gold toll-scale with a crescent bite out of it, flipping, a green venom bead on the bite */
    fr0(x, y, tx, ty, nx, ny, K); var a, b, d;
    if (fr === 1) { cl(c, 0, 1, 7, C); cl(c, 1, 1, 7, A); p(c, 0, 2, Hi); return; }
    for (b = 1; b <= 7; b++) for (a = -3; a <= 3; a++) { d = a * a + (b - 4) * (b - 4); if (d > 11) continue;
      if (fr >= 2 && (a - 3) * (a - 3) + (b - 6) * (b - 6) <= 4) continue; p(c, a, b, d > 6 ? A : C); }
    p(c, -1, 3, Hi); p(c, -2, 4, Hi); p(c, 0, 4, A);
    if (fr === 2) p(c, 2, 7, VENOM);
    if (fr === 3) { p(c, 2, 8, VENOM); p(c, 2, 10, VENOM); p(c, 1, 9, VENOM); }
  });
  PFA.glyph('L11-coralbit', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a branching coral chip turning over in the air, then breaking into bits */
    fr0(x, y, tx, ty, nx, ny, K); var o = fr * 8;
    if (fr === 3) { p(c, -2, 3, C); p(c, -1, 4, C); p(c, 2, 6, C); p(c, 3, 6, C); p(c, 0, 9, C); p(c, 0, 10, Hi); p(c, 3, 5, Hi); p(c, -2, 2, A); return; }
    lin(c, CB[o], CB[o + 1], CB[o + 2], CB[o + 3], C); lin(c, CB[o + 2], CB[o + 3], CB[o + 4], CB[o + 5], C); lin(c, CB[o + 2], CB[o + 3], CB[o + 6], CB[o + 7], C);
    p(c, CB[o + 4], CB[o + 5], Hi); p(c, CB[o + 6], CB[o + 7], Hi); p(c, CB[o], CB[o + 1], A);
  });
  PFA.glyph('L11-castle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a branching coral with a hole, the lord's blue head peeking out of it */
    fr0(x, y, tx, ty, nx, ny, K); var hl = [0, 2, 3, 2][fr], i;
    cl(c, 0, 0, 9, CORAL); cl(c, 1, 0, 8, CORAL); lin(c, 0, 4, -4, 8, CORAL); lin(c, 1, 6, 5, 10, CORAL); lin(c, 0, 8, -2, 11, CORAL); lin(c, -2, 6, -5, 5, CORAL);
    p(c, -4, 9, Hi); p(c, 5, 11, Hi); p(c, -2, 12, Hi); p(c, -6, 5, Hi);
    p(c, 0, 5, A); p(c, 1, 5, A);
    for (i = 1; i <= hl; i++) { p(c, 1 + i, 5, C); p(c, 1 + i, 6, C); }
    if (hl) { p(c, 1 + hl, 6, A); p(c, 2 + hl, 5, Hi); }
    if (fr === 3) { p(c, 3, 9, K.DEW); }
  });
  PFA.glyph('L11-holeslip', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a tail slipping back down into a coral hole, bubbles left behind */
    fr0(x, y, tx, ty, nx, ny, K); var tl = [8, 5, 2, 0][fr], b, a;
    ring(c, 0, 3, 3, CORAL, 1); row(c, -1, 1, 2, A); row(c, -2, 2, 3, A); row(c, -1, 1, 4, A);
    for (b = 3; b <= 3 + tl; b++) { a = Math.round(Math.sin(b * .9 + fr) * 1.5); p(c, a, b, C); if (b < 7) p(c, a + 1, b, C); if (b === 3 + tl && tl) { p(c, a, b + 1, Hi); p(c, a - 1, b + 1, Hi); } }
    if (fr >= 2) { p(c, -1, 7, K.DEW); p(c, 1, 9 + fr, K.DEW); }
    if (fr === 3) { p(c, 0, 13, K.DEW); p(c, 1, 3, K.DEW); }
  });
  PFA.glyph('L11-knot', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* the eel tied in an overhand knot, pulling it tight for leverage */
    fr0(x, y, tx, ty, nx, ny, K); var r = KR[fr], ix = fr * 3;
    lin(c, -7, 0, -r, 6, C); lin(c, -7, 1, -r, 7, C);
    ring(c, 0, 6, r, C, 1); ring(c, 0, 6, r - 1, C, 1);
    lin(c, r - 1, 6, 4, 11, C); lin(c, r, 6, 5, 11, C); row(c, 3, 5, 12, C); p(c, 4, 12, Hi); p(c, 4, 13, TOOTH); p(c, 6, 12, TOOTH);
    p(c, CUP[ix * 2] * r, 6 + CUP[ix * 2 + 1] * r, Hi); p(c, CUP[(ix + 6) % 12 * 2] * r, 6 + CUP[(ix + 6) % 12 * 2 + 1] * r, A);
  });
  /* --- reef eel tyrant: huge, banded grey-gold, crown of spines --- */
  PFA.glyph('L11-crown', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the banded head pointing out, a crown of five spines flaring round it, teeth bared */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, L = 7, sp = SP[fr], b, i, j, ba, bb;
    for (b = 0; b <= L; b++) { var hw = b < 6 ? 2 + w : 1; row(c, -hw, hw, b, ((b >> 1) & 1) ? BAND : C); }
    p(c, -1, L - 1, A); p(c, 1, L - 1, A); p(c, -1, L + 1, C); p(c, 1, L + 1, C); p(c, 0, L + 1, A);
    if (fr === 2) { p(c, -1, L + 2, TOOTH); p(c, 1, L + 2, TOOTH); }
    for (i = 0; i < 5; i++) { ba = SA[i] * 2.6; bb = L - 3 + SB[i] * 2.6;
      for (j = 1; j <= sp; j++) p(c, ba + SA[i] * j, bb + SB[i] * j, Hi); p(c, ba + SA[i] * (sp + 1), bb + SB[i] * (sp + 1), A); }
  });
  PFA.glyph('L11-band', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a huge grey-gold banded body undulating along the edge */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, a, bc, col;
    for (a = -8 - w; a <= 8 + w; a++) { bc = Math.round(4 + Math.sin(a * .45 + fr * 1.57) * 2); col = (((a + 16) >> 1) & 1) ? C : BAND;
      p(c, a, bc - 2, A); p(c, a, bc - 1, col); p(c, a, bc, col); p(c, a, bc + 1, col); if (!((a + 16) & 3)) p(c, a, bc + 2, Hi); }
    bc = Math.round(4 + Math.sin((9 + w) * .45 + fr * 1.57) * 2); row(c, 9 + w, 11 + w, bc, C); row(c, 9 + w, 10 + w, bc + 1, C); p(c, 10 + w, bc + 1, A); p(c, 12 + w, bc, TOOTH);
  });
  PFA.glyph('L11-sip', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* a coral polyp opening its tentacles, green nectar beads rising off it */
    fr0(x, y, tx, ty, nx, ny, K); var op = [1, 2, 3, 3][fr], i, j, da, db;
    cl(c, 0, 0, 3, C); row(c, -1, 1, 4, C); p(c, 0, 4, A);
    for (i = 0; i < 5; i++) { da = SA[i]; db = SB[i]; for (j = 1; j <= op; j++) p(c, da * j * 1.2, 4 + db * j * 1.2, C); p(c, da * (op + 1) * 1.2, 4 + db * (op + 1) * 1.2, Hi); }
    if (fr >= 2) p(c, 0, 6 + op, GLOW);
    if (fr === 3) { p(c, -1, 10, GLOW); p(c, 1, 12, K.WHITE); }
  });
  PFA.glyph('L11-swirl', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a rip-current swirl spiralling in, foam on the rim */
    fr0(x, y, tx, ty, nx, ny, K); var i, ang, r;
    for (i = 0; i < 16; i++) { ang = i * .55 + fr * 1.57; r = 1 + i * .33; p(c, Math.cos(ang) * r, 6 + Math.sin(ang) * r, i > 12 ? Hi : C); }
    p(c, Math.cos(fr * 1.57 + 9) * 6.5, 6 + Math.sin(fr * 1.57 + 9) * 6.5, K.WHITE); p(c, 0, 6, A);
  });
  /* --- conger brute: thick grey eel, shipwreck rust and weed --- */
  PFA.glyph('L11-porthole', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a rusted porthole: eyes glint inside, then the thick grey head pushes out, gapes, lunges */
    fr0(x, y, tx, ty, nx, ny, K); var hl = HC[fr] + (z > 1 && fr ? 1 : 0), b, hw, i;
    for (b = 4; b <= 8; b++) row(c, -2, 2, b, A);
    ring(c, 0, 6, 5, Hi, 1); ring(c, 0, 6, 4.4, Hi, 1); for (i = 0; i < 12; i += 3) p(c, CUP[i * 2] * 5, 6 + CUP[i * 2 + 1] * 5, RIVET);
    p(c, 5, 8, WEED); p(c, 6, 9, WEED); p(c, 5, 10, WEED); p(c, -5, 2, WEED);
    if (!fr) { p(c, -1, 6, K.WHITE); p(c, 1, 6, K.WHITE); return; }
    for (b = 5; b <= 5 + hl; b++) { hw = b >= 4 + hl ? 1 : 2; row(c, -hw, hw, b, C); }
    p(c, -1, 3 + hl, K.WHITE); p(c, 1, 3 + hl, K.WHITE);
    if (fr >= 2) { p(c, 0, 5 + hl, A); p(c, -1, 6 + hl, C); p(c, 1, 6 + hl, C); p(c, 0, 6 + hl, TOOTH); }
    if (fr === 3) star(c, 0, 8 + hl, K.WHITE);
  });
  PFA.glyph('L11-slime', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* thick slime welling up, stretching, a glossy gob coming loose */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0;
    if (fr === 0) { row(c, -2 - w, 2 + w, 0, C); row(c, -2, 2, 1, C); row(c, -1, 1, 2, C); p(c, -1, 1, Hi); }
    else if (fr === 1) { cl(c, -1, 0, 4, C); cl(c, 0, 0, 5, C); cl(c, 1, 0, 3, C); p(c, -1, 2, Hi); p(c, 0, 6, C); }
    else if (fr === 2) { cl(c, 0, 0, 2, C); p(c, 0, 3, C); row(c, -1, 1, 5, C); row(c, -1 - w, 1 + w, 6, C); row(c, -1, 1, 7, C); p(c, -1, 6, Hi); }
    else { row(c, -1, 1, 6, C); row(c, -2, 2, 7, C); row(c, -1, 1, 8, C); p(c, -1, 7, K.WHITE); p(c, 2, 5, WEED); p(c, 3, 4, WEED); }
  });
  PFA.glyph('L11-hull', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* jagged rusted hull plates with rivets, weed on one, pushed out like spikes */
    fr0(x, y, tx, ty, nx, ny, K); var g = GROW[fr] + (z > 1 ? 1 : 0), i, b, h, hw, a0;
    row(c, -7, 7, 0, A);
    for (i = -1; i <= 1; i++) { a0 = i * 5; h = 3 + g + (i ? 0 : 1);
      for (b = 1; b <= h; b++) { hw = Math.round((h - b) * .5); row(c, a0 - hw - 1, a0 + hw, b, C); }
      p(c, a0, 1, RIVET); p(c, a0 - 1, 2, ((i + fr) & 1) ? RUSTF : C); p(c, a0, h + 1, A); }
    p(c, 1, 5 + g, WEED); p(c, 2, 6 + g, WEED); p(c, 1, 7 + g, WEED);
  });
  PFA.glyph('L11-rake', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a barnacled hull plate raked: one, two, three scrape grooves, rust flakes flying */
    fr0(x, y, tx, ty, nx, ny, K); var n = Math.min(3, fr + 1), a, b, j;
    for (b = 1; b <= 6; b++) row(c, -5, 5, b, C);
    p(c, -4, 5, K.WHITE); p(c, -3, 5, K.WHITE); p(c, 3, 2, K.WHITE); p(c, 4, 6, K.WHITE);
    for (j = 0; j < n; j++) { lin(c, -4 + j * 3, 1, -1 + j * 3, 6, A); lin(c, -3 + j * 3, 1, j * 3, 6, Hi); }
    if (fr === 3) { p(c, 4, 8, Hi); p(c, -2, 9, Hi); p(c, 1, 11, Hi); p(c, -5, 8, RUSTF); p(c, 2, 9, RUSTF); }
  });
  PFA.glyph('L11-chain', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* two rusted anchor-chain links rocking, a rust flake drifting off */
    fr0(x, y, tx, ty, nx, ny, K); var o = TF[fr];
    cl(c, -1 + o, 2, 4, C); cl(c, 1 + o, 2, 4, C); p(c, o, 1, C); p(c, o, 5, C); p(c, o, 3, A);
    row(c, -1 - o, 1 - o, 6, Hi); row(c, -1 - o, 1 - o, 7, C); cl(c, -o, 8, 10, C); cl(c, -2 - o, 8, 9, C); cl(c, 2 - o, 8, 9, C); p(c, -o, 11, A);
    if (fr >= 2) p(c, 3, 5 + fr, RUSTF);
  });
  PFA.glyph('L11-slosh', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* murky bilge water curling out of the wreck, rust flakes and a weed strand in it */
    fr0(x, y, tx, ty, nx, ny, K); var a, h, pk = -4 + fr * 3, hm = 0;
    for (a = -6; a <= 6; a++) { h = Math.round(3 + Math.sin((a - pk) * .5 + 1.57) * 2.5); if (h > hm) hm = h; cl(c, a, 0, h, C); if (!((a + fr) % 3)) p(c, a, h + 1, K.WHITE); }
    p(c, pk + 1, hm + 1, Hi); p(c, pk + 2, hm, Hi); p(c, pk + 2, hm - 1, K.WHITE);
    p(c, -3, 2, RUSTF); p(c, 2, 1, RUSTF); p(c, 4 - fr, 3, WEED); p(c, 5 - fr, 4, WEED); p(c, 0, 1, A);
  });
  /* --- bog pike: olive, pale bean spots, duck-bill jaws, reeds --- */
  PFA.glyph('L11-pike', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* the spotted pike among reeds: still, bent into an S, torpedoing out, jaws snapping (z 3 = no reeds, used by the chain effect) */
    fr0(x, y, tx, ty, nx, ny, K); var w = z === 2 ? 1 : 0, L = PL[fr] + w, b, hw, a0;
    if (z < 3) { if (fr < 2) { cl(c, -4, 0, 9, REED); p(c, -4, 10, CAT); p(c, -4, 11, CAT); cl(c, 4, 0, 7, REED); p(c, 4, 8, CAT); p(c, 4, 9, CAT); }
      else { lin(c, -4, 0, -6, 9, REED); p(c, -6, 10, CAT); lin(c, 4, 0, 6, 7, REED); p(c, 6, 8, CAT); } }
    row(c, -2, 2, 0, C); p(c, -2, 1, A); p(c, 2, 1, A);
    for (b = 1; b <= L; b++) { hw = b < 2 ? 0 : b < L - 3 ? 1 : 0; a0 = fr === 1 ? Math.round(Math.sin(b * .6) * 1.5) : 0; row(c, a0 - hw, a0 + hw, b, C);
      if (b % 3 === 1 && hw) p(c, a0 + ((b & 2) ? 1 : -1), b, Hi); if (b === 5) { p(c, a0 - 2, b, A); p(c, a0 + 2, b, A); } }
    a0 = fr === 1 ? Math.round(Math.sin(L * .6) * 1.5) : 0; p(c, a0, L - 2, Hi); p(c, a0 + 1, L - 2, A);
    if (fr === 2) { p(c, a0 - 1, L + 1, C); p(c, a0 + 1, L + 1, C); p(c, a0 - 1, L + 2, C); p(c, a0 + 1, L + 2, C); p(c, a0, L + 1, A); p(c, a0 - 1, L, TOOTH); p(c, a0 + 1, L, TOOTH); }
    if (fr === 3) { p(c, a0, L + 1, C); p(c, a0 - 3, L, K.DEW); p(c, a0 + 3, L + 1, K.DEW); star(c, a0, L + 3, K.WHITE); }
  });
  PFA.glyph('L11-reeds', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* three reeds swaying, a spotted shadow with one gleaming eye lurking between them */
    fr0(x, y, tx, ty, nx, ny, K); var sw = SWY[fr], i, b, h, a0;
    for (a0 = -6; a0 <= 5; a0 += 2) { if (a0 === -2 || a0 === 2) continue; p(c, a0, 3, C); p(c, a0 + 1, 3, (a0 & 2) ? Hi : C); }
    p(c, -5, 2, C); p(c, 3, 2, C); p(c, 6, 3, (fr & 1) ? Hi : A);
    for (i = -1; i <= 1; i++) { h = 9 + (i === 0 ? 2 : i); for (b = 0; b <= h; b++) p(c, i * 4 + Math.round(sw * b / 6), b, REED);
      p(c, i * 4 + sw * 2, h + 1, CAT); p(c, i * 4 + sw * 2, h + 2, CAT); }
  });
  PFA.glyph('L11-duckbill', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* long flat duck-bill jaws open wide, closing, locked with interlocking teeth */
    fr0(x, y, tx, ty, nx, ny, K); var op = OPJ[fr], b, q, sh = fr === 3 ? 1 : 0;
    row(c, -3, 3, 0, C); row(c, -3, 3, 1, C); row(c, -2, 2, 2, C); p(c, -2, 1, Hi); p(c, -3, 2, A);
    for (b = 3; b <= 11; b++) { q = (b - 3) / 8 * op;
      if (op) { p(c, -1 - q + sh, b, C); p(c, 1 + q + sh, b, C); if (b & 1) { p(c, -q + sh, b, TOOTH); p(c, q + sh, b, TOOTH); } }
      else { p(c, -1 + sh, b, C); p(c, 1 + sh, b, C); p(c, sh, b, (b & 1) ? TOOTH : A); } }
    if (fr === 3) star(c, sh, 13, K.WHITE);
  });
  PFA.glyph('L11-boot', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* an old boot snagged on a hook tooth, swinging on its line, bubbles */
    fr0(x, y, tx, ty, nx, ny, K); var o = TF[fr];
    cl(c, 0, 0, 3, K.DEW); p(c, 1, 4, TOOTH); p(c, 0, 4, TOOTH);
    cl(c, -1 + o, 5, 10, C); cl(c, o, 5, 10, C); cl(c, 1 + o, 5, 10, C); row(c, -1 + o, 4 + o, 10, C); row(c, -1 + o, 4 + o, 11, A);
    p(c, o, 6, Hi); p(c, o, 8, Hi); p(c, 3 + o, 9, C);
    if (fr === 3) { p(c, 3, 13, K.DEW); p(c, -2, 12, K.DEW); }
  });
  PFA.glyph('L11-flank', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a slimy olive flank with rows of pale bean spots, a gloss sliding across */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, sh = fr * 4 - 6, a, b, hw;
    for (b = 0; b <= 5; b++) { hw = 7 + w - (b > 3 ? (b - 3) * 2 : 0);
      for (a = -hw; a <= hw; a++) p(c, a, b, (b & 1) && ((a + 20 + ((b >> 1) & 1) * 2) % 4 === 0) ? Hi : a === sh + b ? K.WHITE : C); }
    p(c, -hw, 0, A); p(c, hw, 0, A);
  });
  PFA.glyph('L11-forktail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a forked tail fin lashing from side to side, bog water thrown off */
    fr0(x, y, tx, ty, nx, ny, K); var sw = SWG[fr], b, a, ta = Math.round(sw * 4 / 9);
    for (b = 0; b <= 4; b++) { a = Math.round(sw * b / 9); p(c, a, b, C); p(c, a + 1, b, C); }
    lin(c, ta, 4, sw - 3, 10, C); lin(c, ta + 1, 4, sw - 2, 10, C); lin(c, ta + 1, 4, sw + 3, 10, C); lin(c, ta + 2, 4, sw + 4, 10, C);
    p(c, sw - 3, 11, A); p(c, sw + 4, 11, A); p(c, ta, 3, Hi);
    if (fr === 2) { p(c, sw + 6, 9, K.DEW); p(c, sw + 7, 11, K.DEW); p(c, sw - 5, 12, K.WHITE); }
    if (fr === 0) { p(c, sw - 6, 9, K.DEW); }
  });
  /* --- elephant seal bull: grey-brown, swollen nose, scarred neck --- */
  PFA.glyph('L11-trunk', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the big head, the swollen nose inflating over the mouth, the roar booming out in rings */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, inf = INF[fr], b, hw, t;
    for (b = 0; b <= 6; b++) { hw = (b < 5 ? 4 : 3) + w; row(c, -hw, hw, b, C); }
    p(c, -3, 1, Hi); p(c, -2, 0, Hi); p(c, 3, 2, Hi); p(c, -3, 3, A); p(c, -2, 5, A); p(c, 2, 5, A);
    for (b = 7; b <= 8 + inf; b++) row(c, -1 - (inf > 1 && b > 7 ? 1 : 0), 1 + (inf > 1 && b > 7 ? 1 : 0), b, C);
    row(c, -1, 1, 9 + inf, C); p(c, -1, 9 + inf, A); p(c, 1, 9 + inf, A);
    if (fr) { p(c, -3, 7, PINK); p(c, 3, 7, PINK); p(c, -2, 7, A); p(c, 2, 7, A); }
    if (fr === 2) for (t = .35; t < 2.9; t += .32) p(c, Math.cos(t) * 5, 10 + Math.sin(t) * 4, Hi);
    if (fr === 3) { p(c, -3, 12, K.DEW); p(c, 2, 13, K.DEW); p(c, 4, 11, K.DEW); }
  });
  PFA.glyph('L11-rear', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* the bull rears its scarred chest high, then slams down flat in a burst of sand */
    fr0(x, y, tx, ty, nx, ny, K); var ht = RH[fr] + (z > 1 ? 1 : 0), flat = fr >= 2, b, hw;
    for (b = 0; b <= ht; b++) { hw = flat ? 5 : 3 - (b > ht - 2 ? 1 : 0); row(c, -hw, hw, b, C); }
    if (!flat) { lin(c, -2, ht - 4, 1, ht - 2, Hi); lin(c, -1, ht - 6, 2, ht - 4, Hi); p(c, -1, ht, A); p(c, 1, ht, A); row(c, -1, 1, ht + 1, C); }
    else { lin(c, -3, 1, 0, 3, Hi); lin(c, 1, 1, 3, 2, Hi); row(c, -9, -7, 0, SAND); row(c, 7, 9, 0, SAND); p(c, -8, 2, SAND); p(c, 8, 2, SAND); p(c, -7, 3, SAND); p(c, 7, 3, SAND);
      if (fr === 2) star(c, 0, 6, K.WHITE); else { p(c, -10, 1, SAND); p(c, 10, 1, SAND); } }
  });
  PFA.glyph('L11-blubber', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* three fat rolls rippling one after another */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, i, bb, hw;
    for (i = 0; i < 3; i++) { bb = 1 + i * 3 + Math.round(Math.sin(fr * 1.57 + i * 1.2)); hw = 7 - i * 2 + w;
      row(c, -hw + 1, hw - 1, bb - 1, A); row(c, -hw, hw, bb, C); row(c, -hw + 1, hw - 1, bb + 1, C); p(c, -hw + 2, bb + 1, K.WHITE); }
    p(c, 3, 2, Hi); p(c, 4, 3, Hi);
  });
  PFA.glyph('L11-callus', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* the calloused chest shield, pink scar ridges standing up like spikes */
    fr0(x, y, tx, ty, nx, ny, K); var g = GROW[fr] + (z > 1 ? 1 : 0), b, hw;
    for (b = 0; b <= 3 + g; b++) { hw = 6 - Math.max(0, b - 2); row(c, -hw, hw, b, C); }
    p(c, -4, 1, A); p(c, 3, 2, A); p(c, 0, 1, A); p(c, -2, 3, A);
    lin(c, -4, 1, -2, 5 + g, Hi); lin(c, 1, 1, 3, 4 + g, Hi); lin(c, -1, 0, 0, 3 + g, Hi);
    p(c, -2, 6 + g, A); p(c, 3, 5 + g, A); p(c, 0, 4 + g, A);
  });
  PFA.glyph('L11-roar', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a gaping pink mouth blasting roar arcs outward, spit flying */
    fr0(x, y, tx, ty, nx, ny, K); var r = 3 + fr * 2.5, t;
    row(c, -3, 3, 0, C); row(c, -3, 3, 1, PINK); p(c, -3, 1, C); p(c, 3, 1, C); row(c, -3, 3, 2, C); p(c, -2, 2, TOOTH); p(c, 2, 2, TOOTH);
    for (t = .3; t < 2.9; t += .28) p(c, Math.cos(t) * r, 2 + Math.sin(t) * r, Hi);
    if (fr) for (t = .5; t < 2.7; t += .4) p(c, Math.cos(t) * (r - 2.5), 2 + Math.sin(t) * (r - 2.5), C);
    if (fr >= 2) { p(c, -2, 4 + fr * 2, K.DEW); p(c, 3, 3 + fr * 2, K.DEW); }
  });
  /* --- salt sea lion: sleek caramel, salt crust, a ball on the nose --- */
  PFA.glyph('L11-noseball', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a sleek head with whiskers, a striped ball bouncing off its nose */
    fr0(x, y, tx, ty, nx, ny, K); var bb = 9 + BB[fr], b, hw;
    for (b = 0; b <= 5; b++) { hw = b < 3 ? 3 : b < 5 ? 2 : 1; row(c, -hw, hw, b, C); }
    p(c, -1, 3, A); p(c, 1, 3, A); p(c, 0, 6, A); p(c, -2, 5, Hi); p(c, -3, 6, Hi); p(c, 2, 5, Hi); p(c, 3, 6, Hi);
    row(c, -1, 1, bb - 2, RED); row(c, -2, 2, bb - 1, RED); row(c, -2, 2, bb, K.WHITE); row(c, -2, 2, bb + 1, BLUE); row(c, -1, 1, bb + 2, RED); p(c, -1, bb - 1, K.WHITE);
    if (fr === 0) { p(c, -3, 8, Hi); p(c, 3, 8, Hi); }
  });
  PFA.glyph('L11-bark', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* the head thrown up, mouth wide, white bark marks flying */
    fr0(x, y, tx, ty, nx, ny, K); var op = fr === 0 ? 0 : 2, b, hw, vb;
    for (b = 0; b <= 4; b++) { hw = b < 3 ? 3 : 2; row(c, -hw, hw, b, C); }
    p(c, -1, 3, A); p(c, -3, 4, Hi); p(c, 3, 4, Hi);
    row(c, -2, 0, 5, C); row(c, -1, 0, 6, C); p(c, 0, 7, A);
    if (op) { row(c, 1 + op - 1, 2 + op - 1, 5, C); row(c, 2, 3, 6, C); p(c, 1, 5, PINK); p(c, 1, 6, PINK); p(c, 1, 4, A); }
    else { row(c, 1, 2, 5, C); p(c, 1, 6, C); }
    if (fr >= 2) { vb = 8 + (fr - 2) * 3; vee(c, 1, vb, Hi); vee(c, -2, vb + 2, K.WHITE); vee(c, 4, vb + 1, K.WHITE); }
  });
  PFA.glyph('L11-sleekroll', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a sleek body rolling over in the surf, pale belly up, flippers waving */
    fr0(x, y, tx, ty, nx, ny, K); var w = z > 1 ? 1 : 0, a, bl = [2, 3, 4, 3][fr], i;
    for (a = -7 - w; a <= 7 + w; a++) { var e = Math.abs(a) > 5 + w; p(c, a, 3, C); if (!e) { p(c, a, 2, C); p(c, a, 4, C); p(c, a, bl, Hi); } }
    row(c, 8 + w, 9 + w, 3, C); p(c, 8 + w, 4, A); p(c, 10 + w, 3, A); p(c, 9 + w, 5, Hi);
    if (fr === 0) { p(c, 2, 1, A); p(c, 3, 0, A); } else if (fr === 2) { p(c, 2, 5, A); p(c, 3, 6, A); } else { p(c, 2, 5, A); p(c, 2, 1, A); }
    p(c, -8 - w, 2, C); p(c, -8 - w, 4, C);
    for (i = 0; i < 3; i++) p(c, -8 + ((fr * 3 + i * 5) % 16), 0, K.DEW);
  });
  PFA.glyph('L11-flop', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* the sleek body arched up, coming down, flat in a splash, salt spray hanging */
    fr0(x, y, tx, ty, nx, ny, K); var a, b, k = fr === 0 ? .6 : fr === 1 ? .3 : 0;
    for (a = -6; a <= 6; a++) { b = Math.round((fr >= 2 ? 1 : 3) + (6 - Math.abs(a)) * k); p(c, a, b, C); p(c, a, b + 1, C); if (a > -5 && a < 5) p(c, a, b, Hi); }
    b = Math.round((fr >= 2 ? 1 : 3) + 0); p(c, 7, b + 1, C); p(c, 8, b + 1, A); p(c, -7, b, C); p(c, -7, b + 2, C);
    if (fr === 2) { p(c, -8, 3, K.DEW); p(c, 8, 4, K.DEW); p(c, -7, 5, K.WHITE); p(c, 7, 6, K.WHITE); p(c, 0, 5, K.DEW); }
    if (fr === 3) { p(c, -4, 8, Hi); p(c, 0, 10, K.WHITE); p(c, 3, 7, Hi); p(c, 5, 9, K.WHITE); }
  });
  /* --- giant otter gang: dark brown, cream throat blotches, five otters --- */
  PFA.glyph('L11-periscope', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* an otter periscoping out of the water, cream throat blotch, then the scream */
    fr0(x, y, tx, ty, nx, ny, K); var ht = PH[fr], a, b;
    for (a = -5; a <= 5; a++) if ((a + fr) & 1) p(c, a, 0, K.DEW);
    for (b = 1; b <= ht; b++) row(c, b > ht - 1 ? -1 : -2, b > ht - 1 ? 1 : 2, b, C);
    p(c, -2, ht, C); p(c, 2, ht, C); p(c, -2, ht + 1, C); p(c, 2, ht + 1, C);
    if (ht >= 6) { p(c, -1, ht - 3, Hi); p(c, 0, ht - 3, Hi); p(c, 0, ht - 4, Hi); p(c, 1, ht - 2, Hi); p(c, -1, ht - 5, Hi); }
    p(c, -1, ht, A); p(c, 1, ht, A); p(c, 0, ht + 1, A);
    if (fr === 3) { p(c, 0, ht + 2, PINK); vee(c, 0, ht + 4, Hi); vee(c, -3, ht + 3, K.WHITE); }
  });
  PFA.glyph('L11-fishslap', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a silver fish held by the tail, swung back and slapped flat, scales flying */
    fr0(x, y, tx, ty, nx, ny, K); var ea = FEA[fr], eb = FEB[fr];
    row(c, -1, 1, 0, C); row(c, -1, 1, 1, C); p(c, -1, 0, Hi);
    p(c, -1, 2, FISH); p(c, 1, 2, FISH); lin(c, 0, 2, ea, eb, FISH); lin(c, 1, 3, ea + 1, eb, FISH); lin(c, 0, 3, ea, eb - 1, Hi);
    p(c, ea, eb, A);
    if (fr === 2) star(c, ea + 2, eb + 1, K.WHITE);
    if (fr === 3) { p(c, ea + 2, eb + 2, K.WHITE); p(c, ea - 2, eb + 3, K.DEW); p(c, ea + 1, eb + 4, K.WHITE); }
  });
  PFA.glyph('L11-whisker', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* an otter muzzle bristling stiff white whiskers out like spikes */
    fr0(x, y, tx, ty, nx, ny, K); var g = GROW[fr] + 1 + (z > 1 ? 1 : 0), j;
    row(c, -3, 3, 0, C); row(c, -3, 3, 1, C); row(c, -2, 2, 2, C); row(c, -1, 1, 3, C); row(c, -2, 2, 0, Hi); p(c, 0, 4, A); p(c, -1, 4, A); p(c, 1, 4, A);
    for (j = 0; j < 3; j++) { lin(c, -2, 1 + j, -5 - g, 1 + j * 2 + g * .6, K.WHITE); lin(c, 2, 1 + j, 5 + g, 1 + j * 2 + g * .6, K.WHITE); }
  });
  PFA.glyph('L11-pile', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* otters piling on, one, two, three, four high */
    fr0(x, y, tx, ty, nx, ny, K); var n = fr + 1, i, bb, ja;
    for (i = 0; i < n; i++) { bb = 1 + i * 3; ja = (i & 1) ? 1 : -1;
      row(c, -4 + ja, 4 + ja, bb, C); row(c, -3 + ja, 3 + ja, bb + 1, C); p(c, 5 + ja, bb + 1, C); p(c, 5 + ja, bb, C); p(c, 4 + ja, bb, Hi); p(c, 5 + ja, bb + 2, A); p(c, -5 + ja, bb, C); }
    if (fr === 3) star(c, 0, 14, K.WHITE);
  });
  /* --- deep octopus: deep red, sucker arms, ink, colour mimicry --- */
  PFA.glyph('L11-arm', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* an arm reaching out and curling, pale suckers along its inner side */
    fr0(x, y, tx, ty, nx, ny, K); var k = CU[fr], ang = 0, pa = 0, pb = 0, i;
    for (i = 0; i < 14; i++) { ang += k * i / 13; pa += Math.sin(ang); pb += Math.cos(ang);
      p(c, pa, pb, C); if (i < 6) p(c, pa - Math.cos(ang), pb + Math.sin(ang), C);
      if (i > 1 && !(i & 1)) p(c, pa + Math.cos(ang) * 1.2, pb - Math.sin(ang) * 1.2, Hi); }
    p(c, pa, pb, A);
  });
  PFA.glyph('L11-octo', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* the octopus splaying all eight arms out from its mantle and pulling them in */
    fr0(x, y, tx, ty, nx, ny, K); var sp = OS[fr] + 2, i, j, da, db;
    for (i = 0; i < 8; i++) { da = AD[i * 2]; db = AD[i * 2 + 1]; for (j = 1; j <= sp; j++) p(c, da * j * 1.1 + (j === sp ? (i < 4 ? 1 : -1) : 0), 5 + db * j * .9, C); p(c, da * 2, 5 + db * 1.8, Hi); }
    row(c, -2, 2, 5, C); row(c, -3, 3, 6, C); row(c, -3, 3, 7, C); row(c, -3, 3, 8, C); row(c, -2, 2, 9, C); row(c, -1, 1, 10, C);
    p(c, -2, 6, Hi); p(c, 2, 6, Hi); p(c, -2, 7, A); p(c, 2, 7, A); p(c, 0, 9, A);
  });
  PFA.glyph('L11-suckring', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* rows of sucker discs on an arm strip, pushing out and pulsing */
    fr0(x, y, tx, ty, nx, ny, K); var g = GROW[fr], i, da, db;
    row(c, -7, 7, 0, C); row(c, -6, 6, 1, C);
    for (i = -1; i <= 1; i++) { da = i * 4; db = (i ? 3 : 5) + g;
      lin(c, da, 1, da, db - 2, C);
      row(c, da - 1, da + 1, db - 1, C); p(c, da - 1, db, C); p(c, da + 1, db, C); row(c, da - 1, da + 1, db + 1, C); p(c, da, db, A); p(c, da - 1, db + 1, Hi);
      if (g === 2 && !i) { p(c, da - 2, db, C); p(c, da + 2, db, C); p(c, da, db + 2, C); } }
  });
  PFA.glyph('L11-beak', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a hidden parrot beak opening in a ring of arm bases and biting */
    fr0(x, y, tx, ty, nx, ny, K); var op = [0, 2, 2, 0][fr], b;
    ring(c, 0, 5, 5, C, 1); ring(c, 0, 5, 4, C, 1); row(c, -3, 3, 1, C);
    for (b = 3; b <= 8; b++) { p(c, -1 - (b > 5 ? op : 0), b, A); p(c, 1 + (b > 5 ? op : 0), b, A); }
    p(c, -1 - op, 9, Hi); p(c, -op, 10, Hi); p(c, 1 + op, 9, Hi); p(c, -1 - op, 8, Hi); p(c, 1 + op, 8, Hi);
    if (op) { cl(c, 0, 6, 8, PINK); }
    if (fr === 3) star(c, 0, 12, K.WHITE);
  });
  PFA.glyph('L11-inkjet', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* the siphon jets a stream of ink that balloons into a blob */
    fr0(x, y, tx, ty, nx, ny, K); var len = JL[fr], b, r;
    row(c, -1, 1, 0, Hi); row(c, -1, 1, 1, Hi); p(c, 0, 1, A);
    for (b = 2; b <= 2 + len; b++) { p(c, -1, b, C); p(c, 0, b, INK); p(c, 1, b, C); }
    if (fr >= 2) { r = fr === 2 ? 4 : 6; disc(c, 0, 3 + len, r, C); disc(c, 0, 3 + len, r - 3, INK); p(c, -1, 2 + len, K.WHITE); }
  });
  PFA.glyph('L11-mimic', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a patch of skin flicking through stripes, spots, bumps and a pale flash */
    fr0(x, y, tx, ty, nx, ny, K); var a, b, u, v, col;
    for (b = 0; b <= 6; b++) for (a = -5; a <= 5; a++) { u = a / 5.5; v = (b - 3) / 3.6; if (u * u + v * v > 1) continue;
      col = fr === 0 ? (((a + 8) % 3 === 0) ? A : C) : fr === 1 ? (((a * 3 + b * 5 + 20) % 7 === 0) ? Hi : ((a + b * 2 + 20) % 5 === 0) ? A : C) : fr === 2 ? ((((a + b) & 1) === 0) ? Hi : C) : (u * u + v * v > .6 ? C : Hi);
      p(c, a, b, col); }
    if (fr === 2) for (a = -4; a <= 4; a += 2) p(c, a, 7, C);
  });
  /* --- kraken spawn: dark purple, small kraken arms, storm ink --- */
  PFA.glyph('L11-tentacle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a thick purple tentacle rising out of the waves, swaying, hooked tip, big suckers */
    fr0(x, y, tx, ty, nx, ny, K); var L = 11 + (z > 1 ? 1 : 0), a, b, o;
    for (a = -6; a <= 6; a++) if (((a + fr) & 3) !== 0) p(c, a, 0, K.DEW);
    for (b = 1; b <= L; b++) { o = Math.round(Math.sin(b * .35 + fr * 1.57) * (b / L) * 3);
      if (b < 7) { row(c, o - 1, o + 1, b, C); if (!(b & 1)) p(c, o - 1, b, Hi); } else if (b < 10) { row(c, o, o + 1, b, C); if (!(b & 1)) p(c, o, b, Hi); } else p(c, o, b, C); }
    o = Math.round(Math.sin((L + 1) * .35 + fr * 1.57) * 3); p(c, o + 1, L + 1, C); p(c, o + 2, L, C); p(c, o + 2, L - 1, A);
  });
  PFA.glyph('L11-stormink', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a billowing storm-ink cloud, lightning flickering inside it */
    fr0(x, y, tx, ty, nx, ny, K); var b, hw, o = TF[fr];
    for (b = 1; b <= 6; b++) { hw = [4, 5, 6, 5, 4, 2][b - 1]; row(c, -hw + o * (b & 1), hw + o * (b & 1), b, C); }
    row(c, -3, 3, 1, A); p(c, -5, 4, A); p(c, 5, 5, A); p(c, -2, 6, Hi); p(c, 3, 5, Hi);
    if (fr === 2) { p(c, 0, 5, SPARK); p(c, 1, 4, SPARK); p(c, 0, 3, SPARK); p(c, 1, 2, K.WHITE); p(c, 0, 1, K.WHITE); }
    if (fr === 3) { p(c, -6, 0, K.DEW); p(c, 6, 1, K.DEW); p(c, -4, 0, Hi); }
  });
  PFA.glyph('L11-sucker', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a big sucker cup on an arm pressing down, crushing, crack lines, a ring mark left */
    fr0(x, y, tx, ty, nx, ny, K); var cb = CBP[fr], a, b, d, fl = fr === 2 ? .5 : 1;
    cl(c, 0, cb + 3, 14, C); cl(c, -1, cb + 3, 13, C);
    for (b = -3; b <= 3; b++) for (a = -3; a <= 3; a++) { d = a * a + (b * b) / (fl * fl); if (d > 10 || Math.abs(b) > 3 * fl + .5) continue; p(c, a, cb + b, d <= 2 ? A : C); }
    p(c, -2, cb + 1, Hi); p(c, 2, cb - 1, Hi);
    if (fr === 2) { lin(c, -5, 0, -7, 3, K.WHITE); lin(c, 5, 0, 8, 2, K.WHITE); p(c, -6, 1, K.WHITE); }
    if (fr === 3) { row(c, -3, 3, 0, Hi); p(c, -4, 1, Hi); p(c, 4, 1, Hi); }
  });
  PFA.glyph('L11-jet', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* a small kraken body jetting outward, mantle pumping, arms trailing behind */
    fr0(x, y, tx, ty, nx, ny, K); var nw = (fr & 1) ? 1 : 2, b, hw, a;
    for (b = 5; b <= 10; b++) { hw = b < 8 ? nw : b < 10 ? 1 : 0; row(c, -hw, hw, b, C); }
    p(c, -2, 10, C); p(c, 2, 10, C); p(c, -1, 5, Hi); p(c, 1, 5, A);
    for (a = -2; a <= 2; a++) { if (!a) continue; for (b = 0; b <= 4; b++) p(c, a + (((b + fr) & 2) ? 1 : 0) * (a > 0 ? 1 : -1) * (b < 2 ? 1 : 0), b, C); }
    if (fr === 2) { p(c, -3, 0, K.DEW); p(c, 3, 0, K.DEW); p(c, 0, 0, K.WHITE); }
  });
  PFA.glyph('L11-maw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {        /* a round maw ringed with hooked teeth opening wide and snapping shut */
    fr0(x, y, tx, ty, nx, ny, K); var r = MR[fr], i;
    disc(c, 0, 6, (r + 2.4) * (r + 2.4), C); disc(c, 0, 6, (r + .4) * (r + .4), A);
    for (i = 0; i < 12; i += 2) { p(c, CUP[i * 2] * (r + .5), 6 + CUP[i * 2 + 1] * (r + .5), Hi); p(c, CUP[i * 2] * (r - .5), 6 + CUP[i * 2 + 1] * (r - .5), TOOTH); }
    if (fr === 3) star(c, 0, 13, K.WHITE);
  });
  PFA.glyph('L11-hood', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* the hooded mantle with a pale storm eye under it opening and blinking, arm tips curling */
    fr0(x, y, tx, ty, nx, ny, K); var b, hw, a;
    for (b = 3; b <= 10; b++) { hw = [5, 5, 5, 4, 4, 3, 2, 1][b - 3]; row(c, -hw, hw, b, C); }
    row(c, -3, 3, 8, A); p(c, -4, 6, A);
    if (fr === 0) row(c, -1, 1, 5, A);
    else if (fr === 3) row(c, -2, 2, 5, Hi);
    else { row(c, -2, 2, 5, Hi); row(c, -1, 1, 4, Hi); row(c, -1, 1, 6, Hi); p(c, 0, 5, A); if (fr === 2) { p(c, -1, 5, A); p(c, 1, 5, A); } }
    for (a = -4; a <= 4; a += 2) { p(c, a, 2, C); p(c, a + (((a + fr) & 2) ? 1 : -1), 1, C); p(c, a, 0, C); }
  });

  /* ================= motions (mutate the scratch G; pp = time x speed) ================= */
  PFA.motion('L11-cyc', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 4) + k) & 3; });
  PFA.motion('L11-fast', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 8 + ph * 4) + k) & 3; });
  PFA.motion('L11-slow', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 2.4 + ph * 4) + k) & 3; G.up += Math.sin(pp * 3 + k) * .4; });
  PFA.motion('L11-lunge', function (G, pp, k, ph) { var u = (pp * 1.6 + ph) % 1;                                    /* wait, show, gape, snap */
    if (u < .4) { G.fr = 0; G.d -= .5; } else if (u < .55) G.fr = 1; else if (u < .75) { G.fr = 2; G.d += 3; } else { G.fr = 3; G.d += 2; } });
  PFA.motion('L11-once', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 4.2 + ph)); });
  PFA.motion('L11-sway', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 4) + k) & 3; G.t += Math.sin(pp * 3 + k + ph * 6) * 2; });
  PFA.motion('L11-swim', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 7 + ph * 4) + k) & 3; G.t += Math.sin(pp * 4 + k) * 1.5; });
  PFA.motion('L11-flop', function (G, pp, k, ph) { var u = (pp * 1.8 + ph) % 1; G.fr = u < .35 ? 0 : u < .5 ? 1 : u < .75 ? 2 : 3; });
  PFA.motion('L11-bob', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 3.2 + ph * 4) + k) & 3; G.up += Math.sin(pp * 4 + k) * 1; });
  PFA.motion('L11-pile', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 5 + ph * .5)); });
  PFA.motion('L11-dash', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 4) + k) & 3; if (G.fr === 2) G.d += 2; });

  /* ================= custom chain effects (along the OUTER loop from e.a over e.d, eased e.hh) ================= */
  function carMoray(c, e, H) {          /* the moray slides under a rock ridge laid along the outer edge and pokes its head out of the crack at the next piece */
    var P = e.P, Q = H.Q, i, u;
    for (i = 0; i <= 12; i++) { u = i / 12; if (u > e.hh) break; P.atq(e.a + e.d * u);
      if (i % 3 !== 2) { H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, ROCK); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, ROCK); } else H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, ROCKD); }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'L11-crackhead', Q.x + Q.nx * 2, Q.y + Q.ny * 2, 0, e.hh > .85 ? 2 : 1, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  function carChain(c, e, H) {          /* a rusted anchor chain dragged along the outer edge, the grey anchor leading */
    var P = e.P, Q = H.Q, i, u, sd = e.d < 0 ? -1 : 1, x, y, tx, ty, j;
    for (i = 0; i < 9; i++) { u = e.hh - i * .06; if (u < 0) break; P.atq(e.a + e.d * u); x = Q.x + Q.nx * 4; y = Q.y + Q.ny * 4; tx = -Q.ny * sd; ty = Q.nx * sd;
      if (i & 1) { H.px(c, x - tx, y - ty, e.hi); H.px(c, x, y, e.hi); H.px(c, x + tx, y + ty, e.hi); }
      else { H.px(c, x + Q.nx, y + Q.ny, e.hi); H.px(c, x - Q.nx, y - Q.ny, e.hi); H.px(c, x - tx, y - ty, e.hi); H.px(c, x + tx, y + ty, e.hi); } }
    P.atq(e.a + e.d * e.hh); tx = -Q.ny * sd; ty = Q.nx * sd; x = Q.x + tx * 2; y = Q.y + ty * 2;
    for (j = 1; j <= 6; j++) H.px(c, x + Q.nx * j, y + Q.ny * j, e.col);
    for (j = -2; j <= 2; j++) H.px(c, x + Q.nx * 5 + tx * j, y + Q.ny * 5 + ty * j, e.col);
    H.px(c, x + Q.nx * 2 - tx * 2, y + Q.ny * 2 - ty * 2, e.col); H.px(c, x + Q.nx * 2 + tx * 2, y + Q.ny * 2 + ty * 2, e.col);
    H.px(c, x + Q.nx * 1 - tx * 1, y + Q.ny * 1 - ty * 1, e.col); H.px(c, x + Q.nx * 1 + tx * 1, y + Q.ny * 1 + ty * 1, e.col); H.px(c, x + Q.nx * 7, y + Q.ny * 7, e.hi);
  }
  function carPike(c, e, H) {           /* the pike torpedoes along the outer edge through a row of reeds that bend away after it passes, a short wake behind */
    var P = e.P, Q = H.Q, i, u, j, sd = e.d < 0 ? -1 : 1, bend, tx, ty;
    for (i = 0; i < 5; i++) { u = (i + .5) / 5; P.atq(e.a + e.d * u); tx = -Q.ny * sd; ty = Q.nx * sd;
      bend = e.hh > u ? Math.max(0, 3 - (e.hh - u) * 10) : 0;
      for (j = 0; j <= 8; j++) H.px(c, Q.x + Q.nx * (2 + j) + tx * bend * j / 8, Q.y + Q.ny * (2 + j) + ty * bend * j / 8, j > 6 ? CAT : REED); }
    for (i = 1; i <= 4; i++) { u = e.hh - i * .05; if (u < 0) break; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * (4 + (i & 1)), Q.y + Q.ny * (4 + (i & 1)), H.DEW); }
    P.atq(e.a + e.d * e.hh); tx = -Q.ny * sd; ty = Q.nx * sd;
    H.glyph(c, 'L11-pike', Q.x + Q.nx * 5 - tx * 8, Q.y + Q.ny * 5 - ty * 8, 3, e.hh > .85 ? 2 : 0, e.col, e.acc, e.hi, Q.nx, Q.ny, tx, ty);
  }
  function carBall(c, e, H) {           /* a striped ball bounced along in three hops from this piece's nose to the next, splash marks where it lands */
    var P = e.P, Q = H.Q, i, u, h, k, x, y, tx, ty, a, b;
    for (i = 1; i <= 6; i++) { u = e.hh - i * .035; if (u < 0) break; P.atq(e.a + e.d * u); h = 3 + Math.abs(Math.sin(u * Math.PI * 3)) * 10; H.px(c, Q.x + Q.nx * h, Q.y + Q.ny * h, e.hi); }
    for (k = 1; k <= 3; k++) { if (k / 3 > e.hh + .02) break; P.atq(e.a + e.d * k / 3); H.px(c, Q.x + Q.nx * 2 - Q.ny, Q.y + Q.ny * 2 + Q.nx, H.DEW); H.px(c, Q.x + Q.nx * 2 + Q.ny, Q.y + Q.ny * 2 - Q.nx, H.DEW); }
    P.atq(e.a + e.d * e.hh); h = 3 + Math.abs(Math.sin(e.hh * Math.PI * 3)) * 10; x = Q.x + Q.nx * h; y = Q.y + Q.ny * h; tx = -Q.ny; ty = Q.nx;
    for (b = -2; b <= 2; b++) for (a = -2; a <= 2; a++) { if (a * a + b * b > 5) continue; H.px(c, x + tx * a + Q.nx * b, y + ty * a + Q.ny * b, b === 0 ? H.WHITE : b > 0 ? RED : BLUE); }
  }
  function carPorpoise(c, e, H) {       /* three otters porpoise along the outer edge one behind the other, heads in and out of the water */
    var P = e.P, Q = H.Q, j, u, s;
    for (j = 0; j < 3; j++) { u = e.hh - j * .14; if (u < 0) break; P.atq(e.a + e.d * u); s = Math.sin(u * Math.PI * 4 + j);
      if (s > 0) H.glyph(c, 'L11-periscope', Q.x + Q.nx * 3, Q.y + Q.ny * 3, 0, s > .7 ? 1 : 0, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
      else { H.px(c, Q.x + Q.nx * 3 - Q.ny * 2, Q.y + Q.ny * 3 + Q.nx * 2, H.DEW); H.px(c, Q.x + Q.nx * 3 + Q.ny * 2, Q.y + Q.ny * 3 - Q.nx * 2, H.DEW); H.px(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4, H.WHITE); } }
  }
  function carArm(c, e, H) {            /* one long arm reaches along the outer edge to the next piece, suckers showing, the tip curling where it arrives */
    var P = e.P, Q = H.Q, i, u, sd = e.d < 0 ? -1 : 1, tx, ty, j, ang;
    for (i = 0; i <= 16; i++) { u = i / 16 * e.hh; P.atq(e.a + e.d * u);
      H.px(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4, e.col); if (i < 11) H.px(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5, e.col); if (i % 3 === 1) H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.hi); }
    P.atq(e.a + e.d * e.hh); tx = -Q.ny * sd; ty = Q.nx * sd;
    for (j = 0; j < 6; j++) { ang = j * 1.1 + e.p * 4; H.px(c, Q.x + Q.nx * (6 + Math.sin(ang) * 2) + tx * (1 + Math.cos(ang) * 2), Q.y + Q.ny * (6 + Math.sin(ang) * 2) + ty * (1 + Math.cos(ang) * 2), j ? e.col : e.hi); }
  }
  function carKraken(c, e, H) {         /* a kraken tentacle arches up out of the sea at this piece and slaps down on the next, suckers along it, a lightning flicker */
    var P = e.P, Q = H.Q, i, u, b, x, y;
    for (i = 0; i <= 18; i++) { u = i / 18 * e.hh; P.atq(e.a + e.d * u); b = 2 + Math.sin(u * Math.PI) * 13; x = Q.x + Q.nx * b; y = Q.y + Q.ny * b;
      H.px(c, x, y, e.col); if (i < 13) H.px(c, x + Q.nx, y + Q.ny, e.col); if (i % 3 === 1) H.px(c, x - Q.nx, y - Q.ny, e.hi); }
    P.atq(e.a + e.d * e.hh); b = 2 + Math.sin(e.hh * Math.PI) * 13; H.px(c, Q.x + Q.nx * (b + 2), Q.y + Q.ny * (b + 2), e.acc);
    if ((Math.floor(e.p * 10) & 3) === 1) { P.atq(e.a + e.d * e.hh * .5); x = Q.x + Q.nx * 17; y = Q.y + Q.ny * 17;
      for (i = 0; i < 4; i++) H.px(c, x + Q.nx * -i + Q.ny * ((i & 1) ? 1 : -1), y + Q.ny * -i - Q.nx * ((i & 1) ? 1 : -1), i ? SPARK : H.WHITE); }
    if (e.hh > .85) { P.atq(e.a + e.d); H.px(c, Q.x + Q.nx * 2 - Q.ny * 3, Q.y + Q.ny * 2 + Q.nx * 3, H.DEW); H.px(c, Q.x + Q.nx * 2 + Q.ny * 3, Q.y + Q.ny * 2 - Q.nx * 3, H.DEW); }
  }

  /* ================= motifs ================= */
  function M(name, meta) { PFA.motif(name, comp, meta); }
  /* moray lurker */
  M('crack-moray', { nm: 'crack morays', desc: 'a mottled green-brown moray head between two rock slabs: it peeps out of the crack, comes out, gapes on its needle teeth and lunges with a star; the chain is the moray sliding under a rock ridge and poking out of the next crack', fam: 'bite', gap: 18, g: 'L11-crackhead', mo: 'L11-lunge', x: '-', car: 'custom', carDraw: carMoray });
  M('crack-wedge', { nm: 'wedged bodies', desc: 'a thick mottled eel body wedged between two rock slabs, swelling to fill the gap, a wet sheen on it', fam: 'shield', gap: 20, g: 'L11-wedge', mo: 'L11-slow', x: 'dust', car: 'train' });
  M('moray-gape', { nm: 'second jaws', desc: 'moray jaws gaping on needle teeth while the hidden second jaw shoots out of the throat, then the snap', fam: 'bite', gap: 16, g: 'L11-gape', mo: 'L11-lunge', x: '-', car: 'comet' });
  M('moray-hide', { nm: 'mottled leather', desc: 'a patch of scaleless mottled leather hide, a wet sheen sliding over it', fam: 'shield', gap: 16, g: 'L11-mottle', mo: 'L11-cyc', x: 'sheen', car: 'trail' });
  /* reef eel lord */
  M('ribbon-eel', { nm: 'ribbon eels', desc: 'a thin blue ribbon eel waving up out of a coral hole, yellow fin, yellow gaping jaw and flared nostril flags', fam: 'thrust', gap: 14, g: 'L11-ribbon', mo: 'L11-sway', x: '-', car: 'trail' });
  M('eel-spark', { nm: 'shock eels', desc: 'an arched eel crackling with yellow zigzag sparks, a white flash', fam: 'shock', gap: 16, g: 'L11-spark', mo: 'L11-fast', x: '-', car: 'zig' });
  M('toll-coin', { nm: 'toll scales', desc: 'a gold coin-scale with a crescent bite taken out of it, flipping over, a green venom bead on the bite falling', fam: 'drip', gap: 14, g: 'L11-coin', mo: 'L11-once', x: 'glint', car: 'comet' });
  M('coral-crumb', { nm: 'coral chips', desc: 'branching coral chips turning over in the air and breaking into bits', fam: 'slash', gap: 12, g: 'L11-coralbit', mo: 'L11-cyc', x: 'dust', car: 'roll' });
  M('coral-castle', { nm: 'coral castles', desc: 'a pink branching coral with a hole, a blue eel head peeking out of it and back', fam: 'shield', gap: 18, g: 'L11-castle', mo: 'L11-slow', x: 'bubbles', car: 'train' });
  M('hole-slip', { nm: 'hole slips', desc: 'an eel tail slipping back down into a coral-rimmed hole, bubbles left behind', fam: 'ripple', gap: 16, g: 'L11-holeslip', mo: 'L11-once', x: 'bubbles', car: 'blink' });
  M('eel-knot', { nm: 'eel knots', desc: 'an eel tied in an overhand knot, pulling it tight for leverage, the head bared at the end', fam: 'bash', gap: 18, g: 'L11-knot', mo: 'L11-cyc', x: '-', car: 'loop' });
  /* reef eel tyrant */
  M('spine-crown', { nm: 'spine crowns', desc: 'a banded grey-gold eel head with a crown of five spines flaring round it, teeth bared', fam: 'thorn', gap: 16, g: 'L11-crown', mo: 'L11-lunge', x: '-', car: 'comet' });
  M('tyrant-band', { nm: 'banded coils', desc: 'a huge grey-gold banded body undulating along the edge, the head at its end', fam: 'slash', gap: 20, g: 'L11-band', mo: 'L11-swim', x: '-', car: 'train' });
  M('coral-sip', { nm: 'coral sips', desc: 'a coral polyp opening its tentacles, green nectar beads rising off it', fam: 'mend', gap: 14, g: 'L11-sip', mo: 'L11-once', x: '-', car: 'rings' });
  M('rip-pull', { nm: 'rip currents', desc: 'a rip-current swirl spiralling in on itself, foam on the rim', fam: 'web', gap: 16, g: 'L11-swirl', mo: 'L11-cyc', x: '-', car: 'loop' });
  /* conger brute */
  M('wreck-conger', { nm: 'porthole congers', desc: 'a rusted porthole with rivets and weed: eyes glint in the dark, then a thick grey conger head pushes out, gapes and lunges; the chain is a rusted anchor chain dragged to the next piece, the anchor leading', fam: 'bite', gap: 18, g: 'L11-porthole', mo: 'L11-lunge', x: '-', car: 'custom', carDraw: carChain });
  M('conger-slime', { nm: 'slime gobs', desc: 'thick slime welling up, stretching and a glossy gob coming loose, a weed fleck in it', fam: 'mend', gap: 12, g: 'L11-slime', mo: 'L11-once', x: 'trail', car: 'trail' });
  M('rust-plate', { nm: 'rusted plates', desc: 'jagged rusted hull plates with rivets and a weed strand, pushing out like spikes', fam: 'thorn', gap: 16, g: 'L11-hull', mo: 'L11-cyc', x: '-', car: 'train' });
  M('hull-rake', { nm: 'hull rakes', desc: 'a barnacled hull plate raked with one, two, three scrape grooves, rust flakes flying', fam: 'bash', gap: 16, g: 'L11-rake', mo: 'L11-once', x: '-', car: 'comet' });
  M('anchor-chain', { nm: 'anchor chains', desc: 'two rusted anchor-chain links rocking, a rust flake drifting off', fam: 'web', gap: 12, g: 'L11-chain', mo: 'L11-slow', x: '-', car: 'thread' });
  M('bilge-slosh', { nm: 'bilge sloshes', desc: 'murky bilge water curling out of a wreck, rust flakes and a weed strand in the curl, foam on top', fam: 'ripple', gap: 16, g: 'L11-slosh', mo: 'L11-cyc', x: '-', car: 'trail' });
  /* bog pike */
  M('reed-pike', { nm: 'reed pikes', desc: 'a spotted olive pike lying still between reeds, bending into an S, torpedoing out, duck-bill jaws snapping; the chain is the pike shooting through a row of reeds that bend away after it', fam: 'thrust', gap: 18, g: 'L11-pike', mo: 'L11-lunge', x: '-', car: 'custom', carDraw: carPike });
  M('reed-lurk', { nm: 'reed lurkers', desc: 'three swaying reeds with cattail heads, a spotted shadow with one gleaming eye lurking between them', fam: 'leaf', gap: 16, g: 'L11-reeds', mo: 'L11-sway', x: '-', car: 'flutter' });
  M('duckbill-jaw', { nm: 'duck-bill jaws', desc: 'long flat duck-bill jaws open wide, closing and locking with interlocking backward teeth, a shake and a star', fam: 'bite', gap: 16, g: 'L11-duckbill', mo: 'L11-lunge', x: '-', car: 'comet' });
  M('boot-snag', { nm: 'snagged boots', desc: 'an old boot snagged on a hook tooth, swinging on its line, bubbles', fam: 'web', gap: 16, g: 'L11-boot', mo: 'L11-cyc', x: 'bubbles', car: 'thread' });
  M('pike-flank', { nm: 'spotted flanks', desc: 'a slimy olive flank with rows of pale bean spots, a gloss sliding over it', fam: 'shield', gap: 16, g: 'L11-flank', mo: 'L11-cyc', x: 'sheen', car: 'trail' });
  M('fork-thrash', { nm: 'tail thrashes', desc: 'a forked tail fin lashing from side to side, bog water thrown off', fam: 'slash', gap: 16, g: 'L11-forktail', mo: 'L11-fast', x: '-', car: 'comet' });
  /* elephant seal bull */
  M('trunk-nose', { nm: 'trumpet noses', desc: 'a big grey-brown head with a swollen nose that inflates over the mouth, the roar booming out in pink-white rings, spit after', fam: 'bash', gap: 18, g: 'L11-trunk', mo: 'L11-slow', x: '-', car: 'rings' });
  M('bull-rear', { nm: 'rearing bulls', desc: 'a bull rearing its scarred chest high and slamming down flat in a burst of sand', fam: 'thrust', gap: 18, g: 'L11-rear', mo: 'L11-flop', x: 'dust', car: 'hop' });
  M('blubber-ripple', { nm: 'blubber rolls', desc: 'three fat rolls rippling one after another, a sheen on the folds', fam: 'ripple', gap: 18, g: 'L11-blubber', mo: 'L11-cyc', x: '-', car: 'roll' });
  M('bull-callus', { nm: 'scar shields', desc: 'a calloused chest shield with pink scar ridges standing up like spikes', fam: 'thorn', gap: 16, g: 'L11-callus', mo: 'L11-cyc', x: '-', car: 'train' });
  M('roar-ring', { nm: 'roar blasts', desc: 'a gaping pink mouth blasting roar arcs outward, spit flying', fam: 'puff', gap: 18, g: 'L11-roar', mo: 'L11-once', x: '-', car: 'rings' });
  /* salt sea lion */
  M('nose-bounce', { nm: 'nose balls', desc: 'a sleek whiskered sea lion head with a red-white-blue ball bouncing off its nose; the chain is the ball bounced in three hops to the next piece, splash marks where it lands', fam: 'bash', gap: 18, g: 'L11-noseball', mo: 'L11-cyc', x: '-', car: 'custom', carDraw: carBall });
  M('sea-bark', { nm: 'barks', desc: 'a sleek head thrown up, mouth wide and pink, white bark marks flying', fam: 'puff', gap: 16, g: 'L11-bark', mo: 'L11-once', x: '-', car: 'hop' });
  M('surf-roll', { nm: 'surf rolls', desc: 'a sleek body rolling over in the surf, the pale belly coming up, flippers waving, spray dots', fam: 'ripple', gap: 20, g: 'L11-sleekroll', mo: 'L11-slow', x: '-', car: 'roll' });
  M('salt-flop', { nm: 'salt flops', desc: 'a sleek body arched up, coming down and flat in a splash, white salt spray hanging after', fam: 'bash', gap: 18, g: 'L11-flop', mo: 'L11-flop', x: '-', car: 'hop' });
  /* giant otter gang */
  M('otter-periscope', { nm: 'periscoping otters', desc: 'a dark brown otter standing up out of the water with its cream throat blotch showing, then a scream; the chain is three otters porpoising in a line to the next piece', fam: 'slash', gap: 14, g: 'L11-periscope', mo: 'L11-bob', x: '-', car: 'custom', carDraw: carPorpoise });
  M('fish-club', { nm: 'fish clubs', desc: 'a silver fish held by the tail in a brown paw, swung back and slapped flat with a star, scales flying', fam: 'thrust', gap: 16, g: 'L11-fishslap', mo: 'L11-flop', x: '-', car: 'hop' });
  M('whisker-wall', { nm: 'whisker walls', desc: 'an otter muzzle with a cream chin bristling stiff white whiskers out like spikes', fam: 'thorn', gap: 14, g: 'L11-whisker', mo: 'L11-cyc', x: '-', car: 'train' });
  M('otter-pile', { nm: 'otter piles', desc: 'otters piling on one after another, four high, a star on top', fam: 'bash', gap: 16, g: 'L11-pile', mo: 'L11-pile', x: '-', car: 'hop' });
  /* deep octopus */
  M('sucker-arm', { nm: 'sucker arms', desc: 'a red arm reaching out and curling, pale suckers along its inner side; the chain is one long arm reaching along the outer edge, the tip curling at the next piece', fam: 'web', gap: 16, g: 'L11-arm', mo: 'L11-cyc', x: '-', car: 'custom', carDraw: carArm });
  M('eight-arms', { nm: 'eight arms', desc: 'an octopus mantle with eyes, all eight arms splaying out and pulling back in', fam: 'shock', gap: 18, g: 'L11-octo', mo: 'L11-cyc', x: '-', car: 'blink' });
  M('sucker-ring', { nm: 'sucker studs', desc: 'sucker discs on an arm strip pushing out and pulsing like studs', fam: 'thorn', gap: 14, g: 'L11-suckring', mo: 'L11-cyc', x: '-', car: 'train' });
  M('parrot-beak', { nm: 'parrot beaks', desc: 'a hidden dark parrot beak opening in a ring of arm bases and biting', fam: 'bite', gap: 16, g: 'L11-beak', mo: 'L11-lunge', x: '-', car: 'comet' });
  M('ink-jet', { nm: 'ink jets', desc: 'a siphon jetting a dark stream of ink that balloons into a blob', fam: 'puff', gap: 16, g: 'L11-inkjet', mo: 'L11-once', x: 'ink', car: 'comet' });
  M('mimic-flash', { nm: 'mimic skin', desc: 'a patch of skin flicking through stripes, spots, raised bumps and a pale flash', fam: 'sparkle', gap: 14, g: 'L11-mimic', mo: 'L11-cyc', x: '-', car: 'blink' });
  /* kraken spawn */
  M('kraken-arm', { nm: 'kraken arms', desc: 'a thick purple tentacle rising out of the waves and swaying, big suckers, a hooked tip; the chain is a tentacle arching out of the sea and slapping down on the next piece with a lightning flicker', fam: 'web', gap: 16, g: 'L11-tentacle', mo: 'L11-sway', x: '-', car: 'custom', carDraw: carKraken });
  M('storm-ink', { nm: 'storm ink', desc: 'a billowing storm-ink cloud with lightning flickering inside it', fam: 'puff', gap: 18, g: 'L11-stormink', mo: 'L11-sway', x: '-', car: 'cloud' });
  M('suction-crush', { nm: 'sucker crushes', desc: 'a big sucker cup on an arm pressing down and crushing, crack lines, a ring mark left', fam: 'bash', gap: 16, g: 'L11-sucker', mo: 'L11-lunge', x: '-', car: 'comet' });
  M('jet-dash', { nm: 'jet dashes', desc: 'a small kraken body jetting outward, mantle pumping, arms trailing, a puff behind', fam: 'ripple', gap: 16, g: 'L11-jet', mo: 'L11-dash', x: '-', car: 'blink' });
  M('kraken-maw', { nm: 'kraken maws', desc: 'a round maw ringed with hooked teeth opening wide and snapping shut', fam: 'bite', gap: 18, g: 'L11-maw', mo: 'L11-lunge', x: '-', car: 'comet' });
  M('kraken-hood', { nm: 'storm eyes', desc: 'a hooded mantle with a pale storm eye under it opening and blinking, arm tips curling below', fam: 'shield', gap: 18, g: 'L11-hood', mo: 'L11-slow', x: '-', car: 'rings' });
})();
