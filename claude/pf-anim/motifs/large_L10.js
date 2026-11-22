/* Motif module, large batch L10 (tide-crab-knight, tide-crab-paladin, mangrove-crab-king, mangrove-crab-emperor, coconut-crab-youngster, clam-lurker,
   giant-clam): armoured shore crabs, mangrove crab royalty, a coconut-crab youngster and two clams. TEMPLATE.md sections 9 and 10.3.
   37 motifs, each with its own pixel glyph (ids prefixed L10-); the seven signature motifs bring their own chain effect (carDraw): the knight advancing in
   fencing footwork, the paladin marching under its banner, the mangrove king's procession sprouting prop-root arches, the emperor trailing a train of roots,
   the youngster tottering under its husk hat, the clam lurker ploughing a sand bulge, the giant clam's clap sending a wave crest along.
   Glyph coordinates are (a, b): a along the edge tangent, b outward along the normal, so every sprite turns with its edge. fr0() stores the frame in module
   scratch variables (glyph draws never nest). Lookup tables are built once at load; nothing is allocated per frame, there is no Math.random / Date: every
   effect is a stateless function of p. Glyphs go through H.glyph so the MAXG budget counts them. Wiggle, outer-edge chain rule, visual-only sound lines and
   the creature-heavy default live in the page and are untouched. Large sprites reach up to ~14 px out and stay within ~22 px of the edge. */
(function () {
  var X0 = 0, Y0 = 0, TX = 1, TY = 0, NX = 0, NY = -1, KK = null;
  var SAND = '#dcc89c', SANDD = '#a8915e', WATER = '#9ad4f0', FOAM = '#f4fbff', ROOT = '#a8845a', ROOTD = '#5a4028', LEAF = '#7ac860', MUD = '#8a6a40',
    MUDD = '#4a3820', GOLD = '#f2cc48', HUSK = '#a87a48', HUSKD = '#5e3e1e', SLIME = '#cfeab4', PEARL = '#f4f0ff', STEEL = '#dfe8f0';
  var ARA = [], ARB = [], SWA = [], SWB = [], IRIS = ['#5ad8c0', '#6a9cf0', '#b07ae8', '#f0f0ff'], i0, j0, t0;
  for (i0 = 0; i0 < 13; i0++) { t0 = i0 / 12 * Math.PI; ARA.push(Math.cos(t0)); ARB.push(Math.sin(t0)); }      /* 13-point unit half ring (arches) */
  for (j0 = 0; j0 < 4; j0++) for (i0 = 0; i0 < 10; i0++) { t0 = i0 * .7 + j0 * 1.57; SWA.push(Math.round(Math.cos(t0) * (1 + i0 * .6))); SWB.push(Math.round(Math.sin(t0) * (1 + i0 * .6) * .7)); }   /* 4 frames of a 10-point spiral */
  var GLV = [-2, 0, -1, 0, 0, 0, 1, 0, 2, 0, -2, 1, -1, 1, 0, 1, 1, 1, 2, 1, -2, 2, -1, 2, 0, 2, 1, 2, 2, 2, -2, 3, 0, 3, 2, 3, 3, 1];   /* a gauntlet (u, v) pairs: cuff, palm, fingers, thumb */
  var DOME = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  function fr0(x, y, tx, ty, nx, ny, K) { X0 = x; Y0 = y; TX = tx; TY = ty; NX = nx; NY = ny; KK = K; }
  function p(c, a, b, col) { KK.px(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, col); }
  function row(c, a0, a1, b, col) { for (var a = a0; a <= a1; a++) p(c, a, b, col); }
  function cl(c, a, b0, b1, col) { for (var b = b0; b <= b1; b++) p(c, a, b, col); }
  function arch(c, ca, cb, r, h, col, step) { for (var i = 0; i < 13; i += step) p(c, Math.round(ca + ARA[i] * r), Math.round(cb + ARB[i] * r * h), col); }
  function plusG(c, a, b, r, col) { KK.plus(c, X0 + TX * a + NX * b, Y0 + TY * a + NY * b, r, 1, col); }
  function dome(R, k) { for (var b = 0; b <= R; b++) DOME[b] = Math.round(Math.sqrt(R * R - b * b) * k); }
  function domeFill(c, R, k, b0, C, A, rib) {            /* a filled dome (side-on shell) from b0 up, ribs every 3rd column, dark rim */
    var a, b, hw; dome(R, k);
    for (b = 0; b <= R; b++) { hw = DOME[b]; for (a = -hw; a <= hw; a++) p(c, a, b + b0, (a === -hw || a === hw || b === R) ? A : (rib && (a + 30) % 3 === 0 && b < R) ? A : C); }
    return DOME[0];
  }
  function claw(c, ca, cb, L, op, C, A, Hi) {            /* a crab claw pointing outward: palm block, two fingers that open by op px at the tips, teeth, dark tips */
    var b, i, s;
    for (b = cb; b <= cb + 3; b++) row(c, ca - 2, ca + 2, b, C);
    p(c, ca - 3, cb + 1, A); p(c, ca - 3, cb + 2, A); p(c, ca + 3, cb + 1, A); p(c, ca + 3, cb + 2, A); p(c, ca - 1, cb + 2, Hi);
    for (i = 0; i < L; i++) { s = Math.round(op * (i + 1) / L); b = cb + 4 + i; p(c, ca - 1 - s, b, C); p(c, ca + 1 + s, b, C);
      if (!op) p(c, ca, b, A); else if (i & 1) { p(c, ca - s, b, A); p(c, ca + s, b, A); } }
    p(c, ca - 1 - op + (op ? 1 : 0), cb + 4 + L, A); p(c, ca + 1 + op - (op ? 1 : 0), cb + 4 + L, A);
  }
  function crab(c, ca, cb, r, ph, C, A, Hi) {            /* a small crab from above: carapace, eye dots, three ticking legs a side, two little claws */
    var b, j, hw;
    for (b = 0; b <= 3; b++) { hw = (b === 0 || b === 3) ? r : r + 1; row(c, ca - hw, ca + hw, cb + b, C); }
    p(c, ca - 1, cb + 2, Hi); p(c, ca + 1, cb + 1, A); p(c, ca - 2, cb + 4, A); p(c, ca + 2, cb + 4, A);
    for (j = 0; j < 3; j++) { b = cb + j + ((j + ph) & 1); p(c, ca - r - 2, b, A); p(c, ca + r + 2, b, A); p(c, ca - r - 3, b - 1, A); p(c, ca + r + 3, b - 1, A); }
    p(c, ca - r, cb + 4, C); p(c, ca - r - 1, cb + 5, C); p(c, ca - r, cb + 5, A); p(c, ca + r, cb + 4, C); p(c, ca + r + 1, cb + 5, C); p(c, ca + r, cb + 5, A);
  }

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
  function G10(name, fn) { PFA.glyph('L10-' + name, function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { fr0(x, y, tx, ty, nx, ny, K); fn(c, z > 1 ? 1 : 0, fr & 3, C, A, Hi, K); }); }

  /* ================= glyphs ================= */
  /* --- tide crab knight --- */
  G10('rapier', function (c, w, fr, C, A, Hi, K) {      /* the knight's claw as a blade: a slender fixed finger, the movable finger crossed as a hilt guard; en garde, lunge, thrust with a glint, recover */
    var L = [6, 8, 10, 7][fr] + w, ta = [-3, -1, 0, -2][fr], bo = [0, 1, 2, 1][fr], i, a, b;
    cl(c, 0, 0, bo + 1, C); cl(c, 1, 0, bo + 1, A);
    for (b = bo + 2; b <= bo + 4; b++) row(c, -2, 2, b, C); p(c, -1, bo + 3, Hi); p(c, 2, bo + 4, A);
    row(c, -3, 3, bo + 5, A); p(c, -3, bo + 5, Hi); p(c, 3, bo + 6, A);
    for (i = 0; i <= L; i++) { a = Math.round(ta * i / L); b = bo + 6 + i; p(c, a, b, i === L ? K.WHITE : STEEL); if (i < L - 2) p(c, a + 1, b, C); }
    if (fr === 2) plusG(c, ta, bo + 8 + L, 1, K.WHITE);
  });
  G10('platemail', function (c, w, fr, C, A, Hi, K) {   /* overlapping shell plates in three courses like plate mail, a rivet in each, a sheen stepping across */
    var r, s, sa, da, db, bb;
    for (r = 2; r >= 0; r--) for (s = -2 - w; s <= 1 + w; s++) { sa = s * 4 + (r & 1 ? 2 : 0); bb = 1 + r * 2;
      for (da = 0; da <= 3; da++) for (db = 0; db <= 2; db++) { if ((da === 0 || da === 3) && db === 2) continue; p(c, sa + da, bb + db, db === 2 ? A : C); }
      p(c, sa + 1, bb + 1, Hi); if (((s + 4 + r) & 3) === fr) p(c, sa + 2, bb + 1, K.WHITE); }
  });
  G10('tideshield', function (c, w, fr, C, A, Hi, K) {  /* a round shell shield with a wave-crest blazon, the tide sheeting over it in drops */
    var r = 4 + w, cb = 5 + w, a, b, d;
    for (b = -r; b <= r; b++) for (a = -r; a <= r; a++) { d = a * a + b * b; if (d <= r * r) p(c, a, cb + b, d > (r - 1) * (r - 1) ? A : C); }
    for (a = -2; a <= 2; a++) p(c, a, cb + [0, 1, 1, 0, -1][(a + 2 + fr) % 5], Hi);
    p(c, -1, cb + r - 1, K.WHITE);
    p(c, -r - 1, cb + r - fr * 2, K.DEW); p(c, r + 1, cb + r - 1 - ((fr + 2) & 3) * 2, K.DEW); p(c, r, cb - r + (fr & 1), WATER);
  });
  G10('joust', function (c, w, fr, C, A, Hi, K) {       /* a crab side-on charging with its long lance claw couched and a pennant snapping on the lance */
    var a, j;
    for (a = -7; a <= -1; a++) cl(c, a, (a === -7 || a === -1) ? 2 : 1, 3 + (a > -6 && a < -2 ? 1 : 0), C);
    p(c, -5, 2, Hi); p(c, -2, 5, A); p(c, -3, 5, A); p(c, -2, 6, A);
    for (j = 0; j < 3; j++) { p(c, -6 + j * 2 + (fr & 1), 0, A); }
    cl(c, 0, 1, 5, A); row(c, 1, 10 + w, 3, STEEL); p(c, 11 + w, 3, K.WHITE); row(c, 1, 6, 2, C);
    if (fr & 1) { p(c, 3, 4, C); p(c, 4, 5, C); p(c, 5, 4, C); p(c, 6, 5, Hi); } else { p(c, 3, 4, C); p(c, 4, 4, C); p(c, 4, 5, C); p(c, 5, 5, Hi); }
    if (fr === 2) { p(c, -9, 2, Hi); p(c, -10, 3, Hi); p(c, -9, 4, Hi); }
  });
  G10('gauntlet', function (c, w, fr, C, A, Hi, K) {    /* an armoured claw fist: raised, swinging down, slamming with cracks and dust, settling */
    var up = [5, 3, 0, 1][fr], a;
    row(c, -3, 3, up, A); claw(c, 0, up + 1, 3 + w, 0, C, A, Hi); row(c, -2, 2, up + 2, A); p(c, -1, up + 2, STEEL); p(c, 1, up + 2, STEEL);
    if (fr === 2) { for (a = 4; a <= 8; a++) { p(c, a, (a & 1), A); p(c, -a, (a & 1) ^ 1, A); } p(c, 6, 3, Hi); p(c, -6, 3, Hi); p(c, 8, 2, Hi); }
    if (fr === 3) { p(c, -5, 2, Hi); p(c, 5, 1, Hi); }
  });
  G10('glove', function (c, w, fr, C, A, Hi, K) {       /* a thrown-down gauntlet tumbling end over end, a challenge mark flashing above it */
    var i, u, v, ra, rb;
    for (i = 0; i < GLV.length; i += 2) { u = GLV[i]; v = GLV[i + 1] - 1;
      ra = fr === 0 ? u : fr === 1 ? -v : fr === 2 ? -u : v; rb = fr === 0 ? v : fr === 1 ? u : fr === 2 ? -v : -u;
      p(c, ra, rb + 5, i < 10 ? A : (i === 16 || i === 24) ? STEEL : C); }
    if (!(fr & 1)) { cl(c, 0, 10 + w, 12 + w, Hi); p(c, 0, 14 + w, Hi); }
  });
  G10('sidestep', function (c, w, fr, C, A, Hi, K) {    /* a crab backing off sideways, claws raised in guard, legs ticking */
    crab(c, 0, 1, 3 + w, fr, C, A, Hi); p(c, -4 - w, 7, Hi); p(c, 4 + w, 7, Hi);
    if (fr & 1) { p(c, -7 - w, 1, SANDD); p(c, -8 - w, 2, SANDD); } else { p(c, 7 + w, 1, SANDD); p(c, 8 + w, 2, SANDD); }
  });
  /* --- tide crab paladin --- */
  G10('banner', function (c, w, fr, C, A, Hi, K) {      /* one raised claw holding a banner pole, the pennant snapping in the sea wind, a cross on it, barnacles on the claw */
    var i, bb;
    claw(c, 0, 0, 2, 0, C, A, Hi); p(c, -2, 1, K.WHITE); p(c, 2, 2, K.WHITE);
    cl(c, 0, 6, 13 + w, STEEL);
    for (i = 0; i < 5 + w; i++) { bb = 12 + w - ((i + fr) & 1) - (i > 3 ? 1 : 0); cl(c, i + 1, bb - 3, bb, C); }
    cl(c, 3, 9 + w - ((fr + 2) & 1), 11 + w - ((fr + 2) & 1), Hi); p(c, 2, 10 + w - ((fr + 1) & 1), Hi); p(c, 4, 10 + w - ((fr + 3) & 1), Hi);
    p(c, 0, 14 + w, Hi);
  });
  G10('halo', function (c, w, fr, C, A, Hi, K) {        /* a pincer snapping under a small bright halo, sparkle at the snap */
    claw(c, 0, 0, 4 + w, [2, 1, 0, 2][fr], C, A, Hi);
    var hb = 11 + w; row(c, -1, 1, hb + 1, Hi); row(c, -1, 1, hb - 1, Hi); p(c, -2, hb, Hi); p(c, 2, hb, Hi); p(c, -3, hb, GOLD); p(c, 3, hb, GOLD);
    if (fr === 2) plusG(c, 0, 9 + w, 1, K.WHITE);
  });
  G10('wrack', function (c, w, fr, C, A, Hi, K) {       /* a tideline wrack strand of kelp with a shell and a pebble caught on it, swaying */
    var a, b;
    for (a = -6 - w; a <= 6 + w; a++) { b = 3 + Math.round(Math.sin(a * .8 + fr * 1.57)); p(c, a, b, C); if ((a & 3) === 0) p(c, a, b + 1, C); }
    p(c, -2, 5, Hi); p(c, -1, 5, Hi); p(c, -2, 6, Hi); p(c, -1, 6, K.WHITE); p(c, 3, 4, A); p(c, 4, 4, A); p(c, 5, 2 + (fr & 1), LEAF);
  });
  G10('pauldron', function (c, w, fr, C, A, Hi, K) {    /* a domed shoulder plate crusted with barnacles, three spikes pushing out of it */
    var hw0 = domeFill(c, 4, 1.5, 0, C, A, false), L = [1, 3, 5, 3][fr] + w, a;
    p(c, -4, 2, Hi); p(c, 4, 1, Hi); p(c, -1, 3, K.WHITE);
    for (a = -3; a <= 3; a += 3) { cl(c, a, 5, 4 + L, STEEL); p(c, a, 5 + L, K.WHITE); }
    row(c, -hw0, hw0, 0, A);
  });
  G10('hook', function (c, w, fr, C, A, Hi, K) {        /* a small round shield, a hooked claw reaching out from behind it, curling, yanking back */
    var a, b, ex = [2, 5, 6, 1][fr];
    for (b = -3; b <= 3; b++) for (a = -3; a <= 3; a++) if (a * a + b * b <= 9) p(c, a - 3, b + 4, a * a + b * b > 4 ? A : C);
    p(c, -3, 4, Hi);
    cl(c, 2, 2, 6 + ex, C); cl(c, 3, 2, 4, A); p(c, 3, 7 + ex, C); p(c, 4, 7 + ex, C); p(c, 5, 6 + ex, C); p(c, 5, 5 + ex, Hi);
    if (fr === 3) { cl(c, 7, 3, 4, Hi); cl(c, 8, 5, 6, Hi); }
  });
  G10('oath', function (c, w, fr, C, A, Hi, K) {        /* the oath: a claw raised straight up under rays, then smashed down, rings spreading */
    if (fr < 2) { claw(c, 0, 2, 5 + w, 0, C, A, Hi); arch(c, 0, 12 + w, 3, .6, Hi, 2); if (fr === 1) { p(c, -5, 10, GOLD); p(c, 5, 10, GOLD); p(c, 0, 16 + w, GOLD); } }
    else if (fr === 2) { claw(c, 0, 0, 2, 0, C, A, Hi); plusG(c, 0, 0, 2, K.WHITE); p(c, -6, 1, Hi); p(c, 6, 1, Hi); p(c, -7, 2, Hi); p(c, 7, 2, Hi); }
    else { claw(c, 0, 0, 2, 0, C, A, Hi); arch(c, 0, 0, 7 + w, .6, Hi, 1); arch(c, 0, 0, 10 + w, .5, GOLD, 2); }
  });
  /* --- mangrove crab king and emperor --- */
  G10('throne', function (c, w, fr, C, A, Hi, K) {      /* the king under an arch of mangrove prop roots, a little gold crown, holding court with alternate claws raised */
    arch(c, 0, 0, 7 + w, 1.25, ROOT, 1); arch(c, 0, 0, 6 + w, 1.2, ROOTD, 2); p(c, -1, 9 + w, LEAF); p(c, 1, 10 + w, LEAF); p(c, 0, 10 + w, LEAF);
    crab(c, 0, 1, 2, fr, C, A, Hi);
    row(c, -2, 2, 5, Hi); p(c, -2, 6, Hi); p(c, 0, 6, Hi); p(c, 2, 6, Hi); if (fr === 3) p(c, 0, 7, K.WHITE);
    if (fr & 1) { cl(c, -4, 5, 7, C); p(c, -5, 8, C); p(c, -3, 8, C); } else { cl(c, 4, 5, 7, C); p(c, 3, 8, C); p(c, 5, 8, C); }
  });
  G10('mudplate', function (c, w, fr, C, A, Hi, K) {    /* a crab shell daubed with plates of mud, the mud running off in drips */
    var hw0 = domeFill(c, 4 + w, 1.5, 1, C, A, false), k, a;
    p(c, -3, 2, MUD); p(c, -2, 2, MUD); p(c, -2, 3, MUD); p(c, 1, 4, MUD); p(c, 2, 4, MUD); p(c, 3, 2, MUD); p(c, 0, 2, Hi);
    for (k = 0; k < 3; k++) { a = -4 + k * 4; cl(c, a, 1 - ((fr + k) & 3), 0, MUD); }
    row(c, -hw0, hw0, 1, A);
  });
  G10('hammer', function (c, w, fr, C, A, Hi, K) {      /* a huge mallet crusher claw: raised, swung, smashed down with mud clods, settled */
    var up = [5, 3, 0, 1][fr], b;
    for (b = up; b <= up + 4; b++) row(c, -3 - w, 3 + w, b, C);
    row(c, -3 - w, -1, up + 5, C); row(c, 1, 3 + w, up + 5, C); row(c, -3 - w, -1, up + 6, C); row(c, 1, 3 + w, up + 6, C); cl(c, 0, up + 5, up + 6, A);
    p(c, -2, up + 1, Hi); p(c, 0, up + 2, Hi); p(c, 2, up + 1, Hi); p(c, -1, up + 3, Hi); p(c, 1, up + 4, A); row(c, -3 - w, 3 + w, up, A);
    if (fr === 2) { p(c, -6, 1, MUD); p(c, 6, 1, MUD); p(c, -8, 3, MUD); p(c, 8, 4, MUD); p(c, -5, 5, MUDD); p(c, 5, 6, MUDD); }
  });
  G10('proproot', function (c, w, fr, C, A, Hi, K) {    /* mangrove prop roots growing out in an arch, a second root, then the tips curling down to grip, leaves on top */
    var n = [5, 9, 12, 12][fr], i;
    for (i = 0; i <= n; i++) p(c, Math.round(ARA[i] * (6 + w)), Math.round(ARB[i] * (6 + w) * 1.3), C);
    if (fr >= 2) for (i = 0; i <= 12; i += 2) p(c, Math.round(-2 + ARA[i] * 3), Math.round(ARB[i] * 4), A);
    if (fr >= 1) { p(c, 0, 9 + w, LEAF); p(c, -1, 9 + w, LEAF); p(c, 1, 10 + w, LEAF); }
    if (fr === 3) { p(c, -7 - w, 1, C); p(c, -7 - w, 0, A); p(c, 7 + w, 1, C); p(c, 8 + w, 0, A); p(c, -6 - w, -1, A); }
  });
  G10('royalclaw', function (c, w, fr, C, A, Hi, K) {   /* a big pincer with a gold signet band and a gem, opening and snapping */
    claw(c, 0, 0, 5 + w, [2, 0, 1, 0][fr], C, A, Hi); row(c, -2, 2, 2, GOLD); p(c, 0, 2, K.WHITE);
    if (fr === 3) plusG(c, 0, 11 + w, 1, Hi);
  });
  G10('mire', function (c, w, fr, C, A, Hi, K) {        /* a mud pool: bubbles, claw tips breaking the surface, the claw up and open, snapping shut with mud flicking */
    row(c, -5 - w, 5 + w, 0, MUDD); row(c, -4 - w, 4 + w, 1, MUD); p(c, -2, 1, MUDD); p(c, 3, 1, Hi);
    if (fr === 0) { p(c, -2, 2, MUD); p(c, 2, 3, MUD); p(c, 1, 2, MUD); }
    else if (fr === 1) { p(c, -1, 2, C); p(c, 1, 2, C); p(c, -1, 3, A); p(c, 1, 3, A); }
    else if (fr === 2) claw(c, 0, 1, 3, 2, C, A, Hi);
    else { claw(c, 0, 1, 3, 0, C, A, Hi); p(c, -4, 7, MUD); p(c, 4, 8, MUD); p(c, -3, 9, MUDD); }
  });
  G10('rootcrown', function (c, w, fr, C, A, Hi, K) {   /* the emperor: a broad gold-edged shell under a crown of mangrove roots that grow and twine, a glint running round the rim */
    var HW = [7, 8, 8, 7, 5], b, a, hw, k, ra, L, g = -7 + fr * 4;
    for (b = 0; b <= 4; b++) { hw = HW[b] + w; for (a = -hw; a <= hw; a++) p(c, a, b, (a === -hw || a === hw || b === 4) ? GOLD : ((a + b + 20) % 4 === 0 ? A : C)); }
    p(c, g, 4, K.WHITE); p(c, g + 1, 4, K.WHITE); p(c, -2, 5, A); p(c, 2, 5, A);
    for (k = 0; k < 4; k++) { ra = -5 + k * 3 + w * (k - 1.5 > 0 ? 1 : -1); L = 3 + ((fr + k) % 3);
      cl(c, ra, 5, 5 + L, ROOT); p(c, ra + ((k & 1) ? 1 : -1), 6 + L, ROOT); p(c, ra + ((k & 1) ? 1 : -1), 7 + L, LEAF); }
  });
  G10('lock', function (c, w, fr, C, A, Hi, K) {        /* two gold-rimmed shell halves closing, locking with a cross clasp, a glint */
    var g = [3, 1, 0, 0][fr], b;
    for (b = 0; b <= 2; b++) row(c, -5 - w + (b === 0 ? 1 : 0), 5 + w - (b === 0 ? 1 : 0), b, C);
    for (b = 3; b <= 5; b++) row(c, -5 - w + (b === 5 ? 1 : 0), 5 + w - (b === 5 ? 1 : 0), b + g, C);
    row(c, -5 - w, 5 + w, 2, GOLD); row(c, -5 - w, 5 + w, 3 + g, GOLD); row(c, -4 - w, 4 + w, 5 + g, A);
    if (fr >= 2) { cl(c, 0, 1, 5, STEEL); p(c, -1, 3, STEEL); p(c, 1, 3, STEEL); }
    if (fr === 3) p(c, 4, 4, K.WHITE);
  });
  G10('wave', function (c, w, fr, C, A, Hi, K) {        /* an imperial wave: a raised claw tilting slowly side to side, ripple rings spreading below */
    var t = [-2, -1, 1, 2][fr], i, r;
    for (i = 0; i <= 5; i++) { p(c, Math.round(t * i / 5), 1 + i, C); p(c, Math.round(t * i / 5) + 1, 1 + i, A); }
    claw(c, t, 7, 2, 1, C, A, Hi);
    r = 3 + fr * 2 + w; p(c, -r, 0, WATER); p(c, r, 0, WATER); p(c, -r + 1, 1, WATER); p(c, r - 1, 1, WATER);
    r = r - 3; if (r > 1) { p(c, -r, 0, FOAM); p(c, r, 0, FOAM); }
  });
  G10('tonic', function (c, w, fr, C, A, Hi, K) {       /* a gold-rimmed shell cup brimming with brine, bubbles rising, a mangrove leaf */
    var HW = [2, 3, 4, 4 + w], b, a, k;
    for (b = 0; b <= 3; b++) for (a = -HW[b]; a <= HW[b]; a++) p(c, a, b, (a & 1) ? C : A);
    row(c, -5 - w, 5 + w, 4, GOLD); row(c, -3, 3, 5, WATER); p(c, -1, 5, FOAM);
    for (k = 0; k < 3; k++) p(c, -2 + k * 2 + (k === 2 ? 1 : 0), 6 + ((fr * 2 + k * 3) % 7), k === 1 ? FOAM : WATER);
    p(c, 5 + w, 5, LEAF); p(c, 6 + w, 6, LEAF); p(c, 5 + w, 6, LEAF);
  });
  /* --- coconut crab youngster --- */
  G10('huskhat', function (c, w, fr, C, A, Hi, K) {     /* a half-size blue-purple crab with a coconut husk on its head that bobs, slips over its eyes and is pushed back */
    var sa = [0, 1, 0, -1][fr], sb = fr === 1 ? -1 : 0, HW = [4, 4, 3, 2], b, a;
    crab(c, 0, 0, 2 + w, fr, C, A, Hi);
    for (b = 0; b <= 3; b++) for (a = -HW[b]; a <= HW[b]; a++) p(c, a + sa, 4 + b + sb, ((a + b * 2 + 20) % 3 === 0) ? HUSKD : HUSK);
    p(c, -5 + sa, 6 + sb, HUSKD); p(c, 4 + sa, 8 + sb, HUSKD); p(c, 1 + sa, 8 + sb, Hi);
    if (fr === 3) { cl(c, -4, 4, 6, C); p(c, -4, 7, A); }
  });
  G10('huskhide', function (c, w, fr, C, A, Hi, K) {    /* a husk shell sitting on the sand; eyestalks peek up, duck, legs poke out, then all hidden */
    var HW = [5, 5, 5, 4, 3, 2], b, a;
    for (b = 0; b <= 5; b++) for (a = -HW[b] - w; a <= HW[b] + w; a++) p(c, a, b, ((a * 3 + b * 5 + 40) % 4 === 0) ? HUSKD : HUSK);
    p(c, -2, 5, Hi); p(c, 3, 4, HUSKD); p(c, -5 - w, 6, HUSKD);
    if (fr === 0) { cl(c, -1, 6, 7, C); cl(c, 1, 6, 7, C); p(c, -1, 8, A); p(c, 1, 8, A); }
    else if (fr === 1) { p(c, -1, 6, A); p(c, 1, 6, A); }
    else if (fr === 2) { p(c, -6 - w, 0, C); p(c, -7 - w, 1, C); p(c, 6 + w, 0, C); p(c, 7 + w, 1, C); }
  });
  G10('tinyclaw', function (c, w, fr, C, A, Hi, K) {    /* a small claw practising: snaps at air (whiff marks), opens wide, snaps and finally hits (pip) */
    claw(c, 0, 0, 3 + w, [2, 0, 2, 0][fr], C, A, Hi);
    if (fr === 1) { p(c, -3, 9, Hi); p(c, 3, 9, Hi); p(c, -4, 10, Hi); p(c, 4, 10, Hi); }
    if (fr === 3) plusG(c, 0, 9 + w, 1, K.WHITE);
  });
  G10('snip', function (c, w, fr, C, A, Hi, K) {        /* a husk lump with a claw snipping its coir fibres, the fibres flying off */
    var HW = [4, 4, 3, 2], b, a;
    for (b = 0; b <= 3; b++) for (a = -HW[b]; a <= HW[b]; a++) p(c, a, b, ((a + b + 20) % 3 === 0) ? HUSKD : HUSK);
    p(c, -2 + fr, 5 + fr * 2, HUSK); p(c, -1 + fr, 6 + fr * 2, HUSKD); p(c, 2 - fr, 6 + fr * 2, HUSK); p(c, 3 - fr, 7 + fr * 2, HUSKD);
    if (fr & 1) { p(c, 5, 3, C); p(c, 6, 4, C); p(c, 5, 4, A); } else { p(c, 5, 2, C); p(c, 6, 3, C); p(c, 5, 5, C); p(c, 6, 4, C); }
    row(c, 6, 7 + w, 3, C);
  });
  G10('huskball', function (c, w, fr, C, A, Hi, K) {    /* a coconut husk tossed end over end, its fibre tuft turning round */
    var a, b, r = 3 + w, ta = [0, 4, 0, -4][fr], tb = [8, 4, 0, 4][fr];
    for (b = -r; b <= r; b++) for (a = -r; a <= r; a++) if (a * a + b * b <= r * r + 1) p(c, a, 4 + b, ((a + b + fr + 20) % 3 === 0) ? HUSKD : HUSK);
    p(c, ta, tb + (tb > 4 ? w : tb < 4 ? -w : 0), HUSKD); p(c, ta + (ta ? 0 : 1), tb + (ta ? 1 : 0), HUSK); p(c, -1, 5, Hi);
  });
  /* --- clams --- */
  G10('lurk', function (c, w, fr, C, A, Hi, K) {        /* a clam half buried in sand: shut, opening a crack with blue mantle eyes peering, gaping, snapping shut in a sand puff */
    var g = [0, 1, 3, 0][fr], HW = [6, 5, 4, 2], b, a;
    row(c, -8 - w, 8 + w, 0, SAND); row(c, -7, 7, 1, SANDD);
    row(c, -5 - w, 5 + w, 2, C);
    for (b = 0; b <= 3; b++) for (a = -HW[b] - w; a <= HW[b] + w; a++) p(c, a, 3 + g + b, (b === 3 || a === -HW[b] - w || a === HW[b] + w) ? A : (b & 1) ? A : C);
    for (b = 3; b < 3 + g; b++) row(c, -5 - w, 5 + w, b, A);
    if (g) { p(c, -3, 3, Hi); p(c, -1, 3, Hi); p(c, 1, 3, Hi); p(c, 3, 3, Hi); }
    if (fr === 3) { p(c, -8, 2, SAND); p(c, -9, 3, SAND); p(c, 8, 2, SAND); p(c, 9, 3, SAND); p(c, 0, 8, SAND); }
  });
  G10('mantle', function (c, w, fr, C, A, Hi, K) {      /* a frilled clam mantle lip, slime strands stretching off it and a drop letting go */
    var a, b, k, L;
    for (a = -6 - w; a <= 6 + w; a++) { b = 3 + Math.round(Math.sin(a * .9 + fr * 1.57)); p(c, a, b, C); p(c, a, b - 1, (a & 1) ? Hi : C); p(c, a, b - 2, A); }
    for (k = 0; k < 3; k++) { a = -4 + k * 4; L = (fr + k) & 3; b = 4 + Math.round(Math.sin(a * .9 + fr * 1.57)); cl(c, a, b + 1, b + 1 + L, SLIME); if (L === 3) p(c, a, b + 7, SLIME); }
  });
  G10('gate', function (c, w, fr, C, A, Hi, K) {        /* two ridged valves swinging shut like gates: open wide, swinging, slammed with streaks, shuddering */
    var g = [6, 4, 1, 1][fr] + w, b;
    for (b = 0; b <= 6; b++) { p(c, -g, b, C); p(c, g, b, C); p(c, -g - 1, b, (b & 1) ? A : C); p(c, g + 1, b, (b & 1) ? A : C); }
    cl(c, -g - 2, 1, 5, C); cl(c, g + 2, 1, 5, C); p(c, -g - 1, 6, Hi); p(c, g + 1, 6, Hi);
    if (fr >= 2) { for (b = 0; b <= 6; b++) p(c, 0, b, (b & 1) ? K.WHITE : A); }
    if (fr === 2) { cl(c, -7 - w, 3, 4, Hi); cl(c, 7 + w, 3, 4, Hi); cl(c, -9 - w, 2, 5, Hi); cl(c, 9 + w, 2, 5, Hi); }
  });
  G10('siphon', function (c, w, fr, C, A, Hi, K) {      /* a shell lip with a siphon tube jetting a line of spray that fans out at the end */
    var jl = [0, 2, 4, 3][fr] + w, i;
    row(c, -4, 4, 0, C); row(c, -3, 3, 1, A);
    cl(c, -1, 2, 5, C); cl(c, 1, 2, 5, C); cl(c, 0, 2, 5, Hi); row(c, -2, 2, 6, C);
    for (i = 0; i < jl; i++) p(c, (i & 1) ? 0 : (i % 4 === 0 ? -1 : 1), 7 + i * 2, i & 1 ? FOAM : WATER);
    if (fr === 3) { p(c, -2, 12 + w, WATER); p(c, 2, 13 + w, WATER); p(c, -3, 14 + w, FOAM); p(c, 3, 11 + w, FOAM); }
  });
  G10('pearl', function (c, w, fr, C, A, Hi, K) {       /* an opened shell with a pearl, its glint flaring from a pinprick to a four-ray blaze */
    var HW = [3, 4, 5], b;
    for (b = 0; b <= 2; b++) row(c, -HW[b], HW[b], b, b === 2 ? A : C);
    arch(c, 0, 7 + w, 5, -.6, C, 1); arch(c, 0, 8 + w, 5, -.6, A, 2);
    row(c, -1, 1, 3, PEARL); row(c, -1, 1, 4, PEARL); p(c, 0, 5, PEARL); p(c, -1, 4, K.WHITE);
    if (fr) plusG(c, 0, 4, fr + w, K.WHITE);
    if (fr === 3) { p(c, -3, 7, Hi); p(c, 3, 7, Hi); p(c, -3, 1, Hi); p(c, 3, 1, Hi); }
  });
  G10('swirl', function (c, w, fr, C, A, Hi, K) {       /* an undertow spiral turning, sand grains being drawn into it */
    var i, o = fr * 10;
    for (i = 0; i < 10; i++) p(c, SWA[o + i] * (1 + w * .3), 5 + SWB[o + i], i < 4 ? Hi : C);
    p(c, [6, 3, -6, -3][fr], [5, 9, 5, 1][fr], SAND); p(c, [-5, -2, 5, 2][fr], [3, 8, 7, 2][fr], SANDD);
  });
  G10('sealed', function (c, w, fr, C, A, Hi, K) {      /* a clam shut tight: a ridged dome, the seam locked, pressure ticks at its ends, barnacles */
    var hw0 = domeFill(c, 5 + w, 1.3, 1, C, A, true);
    row(c, -hw0, hw0, 0, A); for (var a = -hw0; a <= hw0; a += 2) p(c, a, 0, Hi);
    p(c, -hw0 - 2 - (fr & 1), 1, Hi); p(c, hw0 + 2 + (fr & 1), 1, Hi); p(c, -hw0 - 3, 3, fr > 1 ? Hi : A); p(c, hw0 + 3, 3, fr > 1 ? Hi : A);
    p(c, -2, 5, K.WHITE); p(c, 2, 4, Hi);
  });
  G10('giant', function (c, w, fr, C, A, Hi, K) {       /* the cart-sized clam: wavy ridged grey valves gaping on a wide pale-teal mantle, clapping shut with a burst, settling */
    var g = [4, 2, 0, 1][fr], HW0 = [8, 8, 7], HW1 = [7, 8, 8], b, a, hw;
    for (b = 0; b <= 2; b++) { hw = HW0[b] + w; for (a = -hw; a <= hw; a++) p(c, a, b, ((a + 40) & 3) === 0 ? A : C); }
    for (a = -7 - w; a <= 7 + w; a++) p(c, a, 3 - (((a + 40) & 3) < 2 ? 0 : 1) + (g ? 0 : 0), C);
    for (b = 0; b < g; b++) for (a = -6 - w; a <= 6 + w; a++) p(c, a, 3 + b, (a % 3 === 0 && b === 1) ? K.WHITE : (a % 3 === 0 && b === 2) ? A : Hi);
    for (b = 0; b <= 2; b++) { hw = HW1[b] + w; for (a = -hw; a <= hw; a++) p(c, a, 3 + g + b, b === 2 ? (((a + 40) & 3) === 0 ? C : A) : ((a + 40) & 3) === 0 ? A : C); }
    if (fr === 2) { cl(c, -10 - w, 2, 4, K.WHITE); cl(c, 10 + w, 2, 4, K.WHITE); p(c, -12 - w, 3, K.WHITE); p(c, 12 + w, 3, K.WHITE); p(c, -11 - w, 6, WATER); p(c, 11 + w, 6, WATER); }
  });
  G10('iris', function (c, w, fr, C, A, Hi, K) {        /* a glossy wavy mantle band with iridescent spots shimmering blue, violet, teal and white */
    var a, b;
    for (a = -7 - w; a <= 7 + w; a++) { b = 3 + Math.round(Math.sin(a * .6 + fr * 1.2) * 1.5); p(c, a, b - 1, C); p(c, a, b, (a + 40) % 3 === 0 ? IRIS[((a + 40) / 3 + fr) & 3] : C); p(c, a, b + 1, Hi); }
  });
  G10('clapwave', function (c, w, fr, C, A, Hi, K) {    /* two valve tips smacking together, a jagged shock bursting out of the join and spray flying */
    var L = [3, 6, 9, 6][fr] + w, b;
    row(c, -4, -1, 0, C); row(c, 1, 4, 0, C); row(c, -3, -1, 1, C); row(c, 1, 3, 1, C); p(c, 0, 1, K.WHITE);
    for (b = 2; b <= L; b++) { p(c, (b & 1) ? 1 : -1, b, b === L ? K.WHITE : Hi); }
    for (b = 2; b <= L - 2; b += 2) { p(c, -2 - b / 2, b + 1, Hi); p(c, 2 + b / 2, b + 1, Hi); }
    if (fr >= 2) { p(c, -6, L - 1, WATER); p(c, 6, L - 2, WATER); p(c, -4, L + 1, FOAM); p(c, 4, L, FOAM); }
  });

  /* ================= motions ================= */
  function cyc(n) { return function (G, pp, k) { G.fr = (Math.floor(pp * n) + k) & 3; }; }
  function beat(rate, cuts, dpush) { return function (G, pp, k, ph) { var w = (pp * rate + ph) % 1, f = w < cuts[0] ? 0 : w < cuts[1] ? 1 : w < cuts[2] ? 2 : 3; G.fr = f; G.d += dpush[f]; }; }
  function once(G, pp, k, ph) { var u = Math.min(.999, Math.max(0, G.u * 1.1 + ph * .1)); G.fr = Math.floor(u * 4); }
  PFA.motion('L10-fence', function (G, pp, k, ph) { var w = (pp * 2.6 + ph) % 1; G.fr = w < .35 ? 0 : w < .5 ? 1 : w < .75 ? 2 : 3; G.d += [0, 1, 3, 0][G.fr]; G.t += Math.sin(pp * 5 + k) * 1.2; });   /* en garde, lunge, thrust, recover */
  PFA.motion('L10-cyc3', cyc(3));
  PFA.motion('L10-cyc4', cyc(4));
  PFA.motion('L10-cyc6', cyc(6));
  PFA.motion('L10-once', once);
  PFA.motion('L10-smash', beat(2.2, [.35, .5, .75], [1, 0, 0, 0]));
  PFA.motion('L10-charge', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 10) + k) & 3; G.t += ((pp * 2 + ph) % 1) * 3; });
  PFA.motion('L10-toss', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 10 + ph * 4) + k) & 3; G.up += Math.abs(Math.sin((pp * 1.6 + ph) * Math.PI)) * 5; });
  PFA.motion('L10-side', function (G, pp, k, ph) { var st = Math.floor(pp * 6) + k; G.fr = st & 3; G.t += Math.sin(pp * 3 + ph * 6) * 2.5; });
  PFA.motion('L10-flag', function (G, pp, k) { G.fr = (Math.floor(pp * 9) + k) & 3; G.up += Math.sin(pp * 4 + k) * .6; });
  PFA.motion('L10-court', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 4 + ph * 2) + k) & 3; });
  PFA.motion('L10-grow', function (G, pp, k, ph) { var u = Math.min(.999, Math.max(0, G.u * 1.4 + ph * .1)); G.fr = Math.floor(u * 4); });
  PFA.motion('L10-pinch', beat(2.6, [.3, .45, .7], [0, 0, 1, 0]));
  PFA.motion('L10-snatch', function (G, pp, k, ph) { var w = (pp * 1.8 + ph) % 1; G.fr = w < .3 ? 0 : w < .45 ? 1 : w < .7 ? 2 : 3; });
  PFA.motion('L10-regal', function (G, pp, k) { G.fr = (Math.floor(pp * 3) + k) & 3; G.up += Math.sin(pp * 3 + k) * .5; });
  PFA.motion('L10-wobble', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 3) + k) & 3; G.t += Math.sin(pp * 9 + k) * 1.2; });
  PFA.motion('L10-peek', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 3.5 + ph * 4) + k) & 3; });
  PFA.motion('L10-gape', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; G.fr = w < .3 ? 0 : w < .5 ? 1 : w < .8 ? 2 : 3; if (G.fr === 3) G.t += (Math.floor(pp * 30) & 1) ? .6 : -.6; });
  PFA.motion('L10-shut', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .35 ? 0 : w < .55 ? 1 : w < .7 ? 2 : 3; if (G.fr === 3) G.t += (Math.floor(pp * 30) & 1) ? .8 : -.8; });
  PFA.motion('L10-jet', cyc(5));
  PFA.motion('L10-glint', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 1.5 + ph) % 1) * 4); });
  PFA.motion('L10-spin', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; G.d -= ((pp * 2 + k * .3) % 1) * 2; });
  PFA.motion('L10-press', function (G, pp, k) { G.fr = (Math.floor(pp * 4) + k) & 3; });
  PFA.motion('L10-clap', function (G, pp, k, ph) { var w = (pp * 1.4 + ph) % 1; G.fr = w < .45 ? 0 : w < .6 ? 1 : w < .75 ? 2 : 3; });
  PFA.motion('L10-shimmer', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; G.t += Math.sin(pp * 2 + k) * .8; });
  PFA.motion('L10-burst', beat(3, [.3, .45, .7], [0, 0, 1, 0]));

  /* ================= custom chain effects (along the OUTER loop from e.a over e.d, eased e.hh) ================= */
  function at(e, H, u, h) { e.P.atq(e.a + e.d * u); H.Q.x += H.Q.nx * h; H.Q.y += H.Q.ny * h; return H.Q; }
  function head(c, e, H, g, u, h, fr, z) { var P = e.P, Q = H.Q, sd = e.d < 0 ? -1 : 1; P.atq(e.a + e.d * u); H.glyph(c, g, Q.x + Q.nx * h, Q.y + Q.ny * h, z, fr, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny); }
  function carKnight(c, e, H) {         /* the knight advances to the next piece in fencing footwork (advance, advance, a half step back), blade forward, sand ticks paired behind */
    var k, u, Q, v = Math.max(0, e.hh - .05 * Math.max(0, Math.sin(e.p * 22))), fr = Math.floor(e.p * 10) & 3;
    for (k = 1; k <= 6; k++) { u = v - k * .045; if (u < 0) break; Q = at(e, H, u, k & 1 ? 1 : 5); H.px(c, Q.x, Q.y, e.acc); H.px(c, Q.x + 1, Q.y, e.acc); }
    for (k = 1; k <= 3; k++) { u = v - k * .08; if (u < 0) break; Q = at(e, H, u, 8 + (k & 1)); H.px(c, Q.x, Q.y, WATER); }
    head(c, e, H, 'L10-rapier', v, 1, fr, 0);
  }
  function carBanner(c, e, H) {         /* the paladin marches to the next piece under its banner: heavy paired prints, barnacle chips, a gold flash when it plants the banner */
    var k, u, Q, st = Math.floor(e.p * 8);
    for (k = 1; k <= 5; k++) { u = e.hh - k * .06; if (u < 0) break; Q = at(e, H, u, (k + st) & 1 ? 2 : 6); H.sq(c, Q.x, Q.y, 2, e.acc); if (k & 1) { Q = at(e, H, u, 4); H.px(c, Q.x, Q.y, '#ffffff'); } }
    head(c, e, H, 'L10-banner', e.hh, 1, Math.floor(e.p * 12) & 3, 0);
    if (e.hh > .95) { Q = at(e, H, 1, 18); H.plus(c, Q.x, Q.y, 2, 1, GOLD); }
  }
  function carThrone(c, e, H) {         /* the mangrove king processes to the next piece: prop-root arches sprout behind it one after another */
    var k, u, fr;
    for (k = 1; k <= 3; k++) { u = k * .25; if (u > e.hh - .08) break; fr = Math.min(3, Math.floor((e.hh - u) * 14)); head(c, e, H, 'L10-proproot', u, 2, fr, 0); }
    head(c, e, H, 'L10-throne', e.hh, 1, Math.floor(e.p * 8) & 3, 0);
  }
  function carCrown(c, e, H) {          /* the emperor trundles to the next piece trailing a train of twisting roots, gold glints running along it */
    var u, Q, i = 0, u0 = Math.max(0, e.hh - .4), gl = Math.floor(e.p * 20);
    for (u = u0; u < e.hh - .02; u += .02, i++) { Q = at(e, H, u, 4 + Math.sin(i * .9 + e.p * 8) * 1.5); H.px(c, Q.x, Q.y, (i & 3) ? ROOT : ROOTD);
      if ((i + gl) % 7 === 0) { Q = at(e, H, u, 2); H.px(c, Q.x, Q.y, GOLD); } if (i % 6 === 3) { Q = at(e, H, u, 7); H.px(c, Q.x, Q.y, LEAF); } }
    head(c, e, H, 'L10-rootcrown', e.hh, 1, Math.floor(e.p * 6) & 3, 0);
  }
  function carHusk(c, e, H) {           /* the youngster totters to the next piece under its husk hat, bobbing, the husk slipping over its eyes halfway, tiny prints behind */
    var k, u, Q, bob = Math.abs(Math.sin(e.p * 18)) * 2, fr = (e.hh > .45 && e.hh < .6) ? 1 : (Math.floor(e.p * 10) & 1) ? 0 : 2;
    for (k = 1; k <= 5; k++) { u = e.hh - k * .05; if (u < 0) break; Q = at(e, H, u, k & 1 ? 1 : 3); H.px(c, Q.x, Q.y, e.acc); }
    head(c, e, H, 'L10-huskhat', e.hh, 1 + bob, fr, 0);
  }
  function carLurk(c, e, H) {           /* the clam lurker ploughs under the sand to the next piece: a bulge runs along, siphon bubbles pop behind, the clam surfaces at the end */
    var j, k, u, Q, ht;
    if (e.hh < .9) { for (j = -4; j <= 4; j++) { ht = Math.round(Math.sqrt(Math.max(0, 16 - j * j)) * .8); e.P.atq(e.a + e.d * e.hh + j); Q = H.Q; H.px(c, Q.x + Q.nx * (2 + ht), Q.y + Q.ny * (2 + ht), j === 0 ? SANDD : SAND); }
      Q = at(e, H, e.hh, 8 + (Math.floor(e.p * 20) & 1)); H.px(c, Q.x, Q.y, SAND); }
    for (k = 1; k <= 3; k++) { u = e.hh - k * .12; if (u < 0) break; Q = at(e, H, u, 4 + ((Math.floor(e.p * 16) + k) % 3) * 2); H.ringpx(c, Q.x, Q.y, 1, e.hi); }
    if (e.hh >= .9) head(c, e, H, 'L10-lurk', e.hh, 1, Math.min(3, Math.floor((e.hh - .9) * 40)), 0);
  }
  function carGiant(c, e, H) {          /* the giant clam claps where it sits and a wave crest runs along the edge to the next piece, foam on top, ripples behind */
    var j, k, u, Q, ht;
    head(c, e, H, 'L10-giant', 0, 1, e.p < .15 ? 0 : e.p < .25 ? 2 : 3, 0);
    for (j = -5; j <= 5; j++) { ht = Math.round(Math.cos(j / 5 * 1.57) * 4); e.P.atq(e.a + e.d * e.hh + j); Q = H.Q; H.px(c, Q.x + Q.nx * (3 + ht), Q.y + Q.ny * (3 + ht), Math.abs(j) < 2 ? FOAM : WATER); }
    for (k = 1; k <= 3; k++) { u = e.hh - k * .07; if (u < .05) break; Q = at(e, H, u, 3); H.px(c, Q.x, Q.y, WATER); Q = at(e, H, u, 5); H.px(c, Q.x, Q.y, e.hi); }
  }

  /* ================= motifs ================= */
  function M(name, meta) { PFA.motif(name, comp, meta); }
  /* tide crab knight */
  M('duel-claw', { nm: 'duelling claw', desc: 'a sea-blue crab claw held like a rapier, the slender finger as the blade and the other crossed as a hilt guard: en garde, lunge, thrust with a white glint, recover; the chain is the knight advancing in fencing footwork, a half step back between steps', fam: 'thrust', gap: 18, g: 'L10-rapier', mo: 'L10-fence', x: '-', car: 'custom', carDraw: carKnight });
  M('plate-mail', { nm: 'shell plate mail', desc: 'overlapping shell plates in three courses like plate mail, a rivet in each, a sheen stepping across', fam: 'shield', gap: 16, g: 'L10-platemail', mo: 'L10-cyc4', x: '-', car: 'train' });
  M('tide-shield', { nm: 'tide shield', desc: 'a round shell shield with a wave-crest blazon and the tide sheeting over it in drops', fam: 'shield', gap: 16, g: 'L10-tideshield', mo: 'L10-cyc3', x: '-', car: 'train' });
  M('joust-lance', { nm: 'joust', desc: 'a crab side-on charging with its long lance claw couched and a pennant snapping on the lance', fam: 'bash', gap: 22, g: 'L10-joust', mo: 'L10-charge', x: '-', car: 'comet' });
  M('gauntlet-slam', { nm: 'gauntlet slam', desc: 'an armoured claw fist raised, swung down and slammed, cracks running out and dust jumping', fam: 'bash', gap: 16, g: 'L10-gauntlet', mo: 'L10-smash', x: '-', car: 'hop' });
  M('thrown-gauntlet', { nm: 'thrown gauntlet', desc: 'a gauntlet thrown down as a challenge, tumbling end over end, a challenge mark flashing above it', fam: 'web', gap: 18, g: 'L10-glove', mo: 'L10-toss', x: '-', car: 'hop' });
  M('sidestep-crab', { nm: 'sidestepping crabs', desc: 'crabs from above backing off sideways with both claws up in guard, legs ticking, sand kicked out on the side they step from', fam: 'puff', gap: 16, g: 'L10-sidestep', mo: 'L10-side', x: '-', car: 'zig' });
  /* tide crab paladin */
  M('claw-banner', { nm: 'claw banner', desc: 'one raised barnacled claw holding a banner pole, the pennant with a cross snapping in the sea wind; the chain is the paladin marching under its banner, heavy paired prints behind, a gold flash where it plants it', fam: 'ripple', gap: 18, g: 'L10-banner', mo: 'L10-flag', x: '-', car: 'custom', carDraw: carBanner });
  M('halo-pincer', { nm: 'haloed pincer', desc: 'a pincer snapping under a small bright halo, a sparkle at the snap', fam: 'bite', gap: 16, g: 'L10-halo', mo: 'L10-pinch', x: '-', car: 'comet' });
  M('wrack-line', { nm: 'wrack line', desc: 'a tideline wrack strand of kelp with a shell and a pebble caught on it, swaying', fam: 'web', gap: 18, g: 'L10-wrack', mo: 'L10-cyc4', x: '-', car: 'thread' });
  M('pauldron-spike', { nm: 'pauldron spikes', desc: 'a domed shoulder plate crusted with barnacles, three steel spikes pushing out of it', fam: 'thorn', gap: 16, g: 'L10-pauldron', mo: 'L10-once', x: '-', car: 'train' });
  M('shield-hook', { nm: 'shield hook', desc: 'a small round shield with a hooked claw reaching out from behind it, curling round and yanking back', fam: 'slash', gap: 18, g: 'L10-hook', mo: 'L10-cyc4', x: '-', car: 'comet' });
  M('oath-strike', { nm: 'oath strike', desc: 'a claw raised straight up under gold rays as an oath, then smashed down in a white flash, rings spreading', fam: 'bash', gap: 20, g: 'L10-oath', mo: 'L10-once', x: '-', car: 'rings' });
  /* mangrove crab king */
  M('root-throne', { nm: 'root throne', desc: 'the mangrove king under an arch of prop roots, a little gold crown, holding court with alternate claws raised; the chain is the royal procession with prop-root arches sprouting behind one after another', fam: 'shield', gap: 20, g: 'L10-throne', mo: 'L10-court', x: '-', car: 'custom', carDraw: carThrone });
  M('mud-armour', { nm: 'mud armour', desc: 'a crab shell daubed with plates of mud, the mud running off in drips', fam: 'drip', gap: 16, g: 'L10-mudplate', mo: 'L10-cyc4', x: '-', car: 'train' });
  M('hammer-claw', { nm: 'hammer claw', desc: 'a huge mallet-like crusher claw with knobbly teeth: raised, swung, smashed down with mud clods, settled', fam: 'bash', gap: 18, g: 'L10-hammer', mo: 'L10-smash', x: '-', car: 'hop' });
  M('prop-root', { nm: 'prop roots', desc: 'mangrove prop roots growing out of the edge in an arch, a second root inside, the tips curling down to grip, leaves on top', fam: 'leaf', gap: 18, g: 'L10-proproot', mo: 'L10-grow', x: '-', car: 'train' });
  M('royal-pincer', { nm: 'royal pincer', desc: 'a big pincer with a gold signet band and a white gem, opening and snapping', fam: 'bite', gap: 16, g: 'L10-royalclaw', mo: 'L10-pinch', x: '-', car: 'comet' });
  M('mire-grab', { nm: 'mire grab', desc: 'a mud pool: bubbles, claw tips breaking the surface, the claw rising open and snapping shut with mud flicking', fam: 'web', gap: 16, g: 'L10-mire', mo: 'L10-snatch', x: '-', car: 'tunnel' });
  /* mangrove crab emperor */
  M('root-crown', { nm: 'root crown', desc: 'a broad gold-edged crab shell under a crown of mangrove roots that grow and twine, a glint running round the rim; the chain is the emperor trundling on with a train of twisting roots behind, gold glints and leaves along it', fam: 'bash', gap: 22, g: 'L10-rootcrown', mo: 'L10-regal', x: '-', car: 'custom', carDraw: carCrown });
  M('gold-lock', { nm: 'gold lock', desc: 'two gold-rimmed shell halves closing and locking with a steel cross clasp, a glint', fam: 'shield', gap: 16, g: 'L10-lock', mo: 'L10-press', x: '-', car: 'train' });
  M('royal-wave', { nm: 'imperial wave', desc: 'a raised claw tilting slowly side to side in a regal wave, ripple rings spreading below it', fam: 'ripple', gap: 18, g: 'L10-wave', mo: 'L10-cyc3', x: '-', car: 'rings' });
  M('brine-tonic', { nm: 'brine tonic', desc: 'a gold-rimmed shell cup brimming with brine, bubbles rising, a mangrove leaf on the rim', fam: 'mend', gap: 18, g: 'L10-tonic', mo: 'L10-cyc4', x: '-', car: 'flutter' });
  /* coconut crab youngster */
  M('husk-hat', { nm: 'husk hat', desc: 'a half-size blue-purple crab wearing a coconut husk on its head that bobs, slips over its eyes and is pushed back up; the chain is the youngster tottering along under it, the husk slipping halfway, tiny prints behind', fam: 'bash', gap: 16, g: 'L10-huskhat', mo: 'L10-wobble', x: '-', car: 'custom', carDraw: carHusk });
  M('husk-hide', { nm: 'husk hide', desc: 'a coconut husk sitting on the sand; eyestalks peek up, duck, legs poke out, then all hidden', fam: 'shield', gap: 16, g: 'L10-huskhide', mo: 'L10-peek', x: '-', car: 'roll' });
  M('practice-pinch', { nm: 'practice pinch', desc: 'a small claw practising: snapping at air with whiff marks, opening wide, snapping and finally hitting', fam: 'bite', gap: 14, g: 'L10-tinyclaw', mo: 'L10-cyc4', x: '-', car: 'comet' });
  M('husk-snip', { nm: 'husk snip', desc: 'a coconut husk lump with a small claw snipping its coir fibres, the fibres flying off', fam: 'bite', gap: 16, g: 'L10-snip', mo: 'L10-cyc4', x: '-', car: 'comet' });
  M('husk-toss', { nm: 'husk toss', desc: 'a coconut husk tossed end over end, its fibre tuft turning round', fam: 'web', gap: 16, g: 'L10-huskball', mo: 'L10-toss', x: '-', car: 'hop' });
  /* clams */
  M('lurk-gape', { nm: 'lurking clam', desc: 'a clam half buried in sand: shut, opening a crack with blue mantle eyes peering, gaping, snapping shut in a sand puff; the chain is the clam ploughing under the sand in a bulge, siphon bubbles popping behind, surfacing at the next piece', fam: 'bite', gap: 18, g: 'L10-lurk', mo: 'L10-gape', x: '-', car: 'custom', carDraw: carLurk });
  M('mantle-slime', { nm: 'slimy mantle', desc: 'a frilled clam mantle lip with slime strands stretching off it and a drop letting go', fam: 'drip', gap: 16, g: 'L10-mantle', mo: 'L10-cyc3', x: '-', car: 'trail' });
  M('shell-gate', { nm: 'shell gate', desc: 'two ridged valves swinging shut like gates: open wide, swinging, slammed with white streaks, shuddering', fam: 'slash', gap: 20, g: 'L10-gate', mo: 'L10-shut', x: '-', car: 'comet' });
  M('siphon-spray', { nm: 'siphon spray', desc: 'a shell lip with a siphon tube jetting a line of spray that fans out at the end', fam: 'puff', gap: 14, g: 'L10-siphon', mo: 'L10-jet', x: '-', car: 'comet' });
  M('pearl-glint', { nm: 'pearl glint', desc: 'an opened shell with a pearl whose glint flares from a pinprick to a four-ray blaze', fam: 'sparkle', gap: 16, g: 'L10-pearl', mo: 'L10-glint', x: '-', car: 'blink' });
  M('undertow-swirl', { nm: 'undertow', desc: 'an undertow spiral turning and drawing sand grains into it', fam: 'ripple', gap: 16, g: 'L10-swirl', mo: 'L10-spin', x: '-', car: 'loop' });
  M('sealed-valve', { nm: 'shut tight', desc: 'a clam shut tight: a ridged dome, the seam locked, pressure ticks pulsing at its ends, barnacle pips', fam: 'shield', gap: 18, g: 'L10-sealed', mo: 'L10-press', x: '-', car: 'train' });
  M('giant-clap', { nm: 'giant clap', desc: 'a cart-sized clam with wavy ridged grey valves gaping on a wide pale-teal mantle, clapping shut with a white burst, settling; the chain is the clam clapping where it sits and a wave crest running along the edge to the next piece, foam on top, ripples behind', fam: 'bash', gap: 26, g: 'L10-giant', mo: 'L10-clap', x: '-', car: 'custom', carDraw: carGiant });
  M('iris-mantle', { nm: 'iridescent mantle', desc: 'a glossy wavy mantle band with iridescent spots shimmering teal, blue, violet and white', fam: 'sparkle', gap: 18, g: 'L10-iris', mo: 'L10-shimmer', x: '-', car: 'trail' });
  M('clap-wave', { nm: 'clap shock', desc: 'two valve tips smacking together, a jagged shock bursting out of the join and spray flying', fam: 'shock', gap: 16, g: 'L10-clapwave', mo: 'L10-burst', x: '-', car: 'zig' });
})();
