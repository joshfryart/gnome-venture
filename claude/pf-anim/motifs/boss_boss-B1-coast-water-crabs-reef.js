/* Motif module, boss batch B1 (coconut-crab-titan, robber-crab-baron, reef-leviathan, ancient-snapper). TEMPLATE.md sections 9 and 10.3.
   12 motifs, each with its own pixel glyph (ids prefixed bossB1-) and motion; three have their own chain effect (carDraw): the titan's legs
   striding over the edge, the baron's red sash streaming behind him, and the leviathan's humps breaching along the outer loop behind its head.
   Boss pieces sit on a 5x5 board (cells 40 x 34), so the sprites are a little bigger and richer than the small ones, but still cheap:
   glyph coordinates are written as (a, b): a along the edge tangent, b outward along the normal, so every sprite turns with its edge.
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation inside the frame loops (scratch H.Q / H.G,
   static tables built once at load). Glyphs go through H.glyph so the MAXG budget counts them; chain bodies are capped at ~40 small blocks.
   The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy default are untouched (they live in the page). */
(function () {
  var SASH = '#d04444', GOLD = '#ecc85a', RUBY = '#e0303e', MOSS = '#5f8c3c', BARN = '#e8e4d4', FLESH = '#fbf6ea';
  /* titan leg pose per frame: knee (a, b) and tip (a, b); the base sits at (-4, 0). 0 planted, 1 lifting, 2 swinging over, 3 stabbing down */
  var KNEE_A = [-1, 0, 1, 1], KNEE_B = [6, 7, 8, 6], TIP_A = [3, 3, 5, 6], TIP_B = [0, 3, 4, 0];
  var COIL_H = [5, 4, 3, 4];                       /* leviathan hump height per frame: the hump rolls as it breaches */
  var SCROLL_W = [1, 3, 6, 6];                     /* decree scroll: paper width per frame (rolled, unrolling, open, sealed) */
  var RING_W = [5, 3, 1, 3];                       /* signet ring seen turning: face, three-quarter, edge-on, back */
  var MAW_O = [0, 1, 3, 0];                        /* leviathan maw: lower jaw drop per frame (shut, opening, unhinged, gulped) */
  var BEAK_G = [0, 1, 2, 0];                       /* moss beak: gape per frame */

  /* (a, b) -> screen helpers: no closures, no allocation */
  function pt(c, K, x, y, tx, ty, nx, ny, a, b, col) { K.px(c, x + tx * a + nx * b, y + ty * a + ny * b, col); }
  function st(c, K, x, y, tx, ty, nx, ny, a, b, w, col) { K.sq(c, x + tx * a + nx * b, y + ty * a + ny * b, w, col); }
  function seg(c, K, x, y, tx, ty, nx, ny, a0, b0, a1, b1, col) {           /* a 1 px segment between two (a, b) points */
    var n = Math.max(1, Math.round(Math.max(Math.abs(a1 - a0), Math.abs(b1 - b0)))), i, u;
    for (i = 0; i <= n; i++) { u = i / n; pt(c, K, x, y, tx, ty, nx, ny, a0 + (a1 - a0) * u, b0 + (b1 - b0) * u, col); }
  }

  /* ---------- shared own-edge composition: the page's themedOwn() with this module's glyph / motion ---------- */
  function comp(c, e, H) {
    var runs = e.runs, mp = e.mp, M = e.M, z = e.z, p = e.p, pp = p * mp.spd, Q = H.Q, G = H.G, P = e.P,
      tie = mp.x === 'thread' || mp.lay === 'snare', ri, k, r, len, n, f, ph, sf, bx0, by0, nx, ny, x, y, lx = 0, ly = 0, has;
    for (ri = 0; ri < runs.length; ri++) {
      r = runs[ri]; len = r[1] - r[0]; n = Math.max(1, Math.min(7, Math.round(len / (M.gap || 12)))); if (mp.lay === 'lance') n = Math.min(n, 4); has = false;
      for (k = 0; k < n; k++) {
        f = (k + .5) / n; ph = H.hash(e.seed * 13 + k * 7 + ri * 31);
        H.lay(mp.lay, p, f, ph, k); H.mot(M.mo, pp, k, ph);
        if (G.d > 20) G.d = 20;                                            /* stay within ~22 px of the edge */
        if (G.vis <= 0 || !H.stip(G.vis, k + ri * 9, p)) { has = false; continue; }
        sf = G.s - Math.floor(G.s); P.atq(r[0] + len * sf); bx0 = Q.x; by0 = Q.y; nx = Q.nx; ny = Q.ny;
        x = bx0 + nx * G.d - ny * G.t; y = by0 + ny * G.d + nx * G.t - G.up;
        if (mp.x === 'threads') H.ln(c, bx0 + nx, by0 + ny, x, y, 1, e.hi);
        else if (mp.x === 'silk') H.ln(c, bx0 + ny * 9 + nx, by0 - nx * 9 + ny, x, y, 1, e.hi);
        if (tie && has && Math.abs(x - lx) + Math.abs(y - ly) < 30) H.ln(c, lx, ly, x, y, 1, e.hi);
        H.glyph(c, M.g, x, y, z, G.fr, e.col, e.acc, e.hi, -ny, nx, nx, ny); lx = x; ly = y; has = true;
      }
      H.ext(c, mp.x, P, r[0], len, ri, p, pp, e.col, e.acc, e.hi, e.seed);
    }
  }

  /* ================= coconut crab titan ================= */
  PFA.glyph('bossB1-leg', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* one colossal spiky walking leg arching over the edge: lift, swing over, stab down */
    var f = fr & 3, ka = KNEE_A[f], kb = KNEE_B[f] + (z > 1 ? 1 : 0), ta = TIP_A[f], tb = TIP_B[f], i, u;
    seg(c, K, x, y, tx, ty, nx, ny, -4, 0, ka, kb, C); seg(c, K, x, y, tx, ty, nx, ny, -3, 0, ka + 1, kb, C);          /* thick upper segment */
    if (z > 0) seg(c, K, x, y, tx, ty, nx, ny, -5, 0, ka - 1, kb, C);
    seg(c, K, x, y, tx, ty, nx, ny, ka + 1, kb, ta, tb + 1, C);                                                          /* lower segment */
    pt(c, K, x, y, tx, ty, nx, ny, ka, kb, A); pt(c, K, x, y, tx, ty, nx, ny, ka + 1, kb - 1, A);                       /* purple-dark knee joint */
    for (i = 1; i <= 3; i++) { u = i / 4; pt(c, K, x, y, tx, ty, nx, ny, -4 + (ka + 4) * u - 1, kb * u + 1, Hi); }   /* cream bristles along the top */
    pt(c, K, x, y, tx, ty, nx, ny, ta, tb, A);                                                                           /* dark claw tip */
    if (f === 3) { pt(c, K, x, y, tx, ty, nx, ny, ta - 2, 0, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, ta + 2, 0, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, ta, 2, K.WHITE); }
  });
  PFA.glyph('bossB1-coconut', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a coconut plummeting, bonk, split white, halves rocking apart */
    var f = fr & 3, R = 2 + (z > 1 ? 1 : 0), a, b, g, sa;
    if (f < 2) {
      for (a = -R; a <= R; a++) for (b = -R; b <= R; b++) if (a * a + b * b <= R * R + 1) pt(c, K, x, y, tx, ty, nx, ny, a + (f === 1 && a > 0 ? 1 : 0), b - (f === 1 && b > 0 ? 1 : 0), C);
      pt(c, K, x, y, tx, ty, nx, ny, -1, 1, A); pt(c, K, x, y, tx, ty, nx, ny, 1, 1, A); pt(c, K, x, y, tx, ty, nx, ny, 0, -1, A);   /* the three eyes */
      pt(c, K, x, y, tx, ty, nx, ny, -R, 0, Hi); pt(c, K, x, y, tx, ty, nx, ny, R - 1, -R + 1, Hi);                                     /* hairy husk flecks */
      if (f === 0) { pt(c, K, x, y, tx, ty, nx, ny, 0, R + 2, Hi); pt(c, K, x, y, tx, ty, nx, ny, 0, R + 4, Hi); pt(c, K, x, y, tx, ty, nx, ny, 1, R + 6, Hi); }   /* fall streak */
      else { pt(c, K, x, y, tx, ty, nx, ny, -R - 2, 1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, R + 3, 1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, -R - 1, 3, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, R + 2, 3, K.WHITE); }   /* bonk */
      return;
    }
    g = f === 3 ? 2 : 1;
    for (a = -R; a <= R; a++) for (b = -R; b <= R; b++) { if (a * a + b * b > R * R + 1) continue; sa = a < 0 ? -g : a > 0 ? g : 0;
      if (a === 0) { pt(c, K, x, y, tx, ty, nx, ny, -g, b, FLESH); pt(c, K, x, y, tx, ty, nx, ny, g, b, FLESH); }
      else pt(c, K, x, y, tx, ty, nx, ny, a + sa, b - (f === 3 ? Math.abs(a) * .3 : 0), Math.abs(a) === 1 && Math.abs(b) < R ? Hi : C); }
    if (f === 3) { pt(c, K, x, y, tx, ty, nx, ny, -1, R + 2, FLESH); pt(c, K, x, y, tx, ty, nx, ny, 1, R + 3, FLESH); }                   /* milk flecks */
  });
  PFA.glyph('bossB1-plate', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* the titan's vast ridged back plate: grooves, knobs, a rim of short spines, a sheen sliding over */
    var w = 5 + (z > 1 ? 1 : 0), a, b, h;
    for (a = -w; a <= w; a++) { h = Math.abs(a) >= w - 1 ? 1 : 2;
      for (b = 0; b <= h; b++) pt(c, K, x, y, tx, ty, nx, ny, a, b, (a === -2 || a === 2) && b > 0 ? A : C);
      if (((a + w) % 3) === 0) { pt(c, K, x, y, tx, ty, nx, ny, a, h + 1, C); pt(c, K, x, y, tx, ty, nx, ny, a, h + 2, A); } }
    pt(c, K, x, y, tx, ty, nx, ny, -4, 1, Hi); pt(c, K, x, y, tx, ty, nx, ny, 0, 1, Hi); pt(c, K, x, y, tx, ty, nx, ny, 4, 1, Hi);    /* knobs */
    pt(c, K, x, y, tx, ty, nx, ny, -w - 1, 0, A); pt(c, K, x, y, tx, ty, nx, ny, w + 1, 0, A);
    pt(c, K, x, y, tx, ty, nx, ny, -w + 1 + (fr & 3) * 3, 2, K.WHITE);                                                                    /* sheen */
  });
  PFA.motion('bossB1-stride', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 7 + ph * 4) + k) & 3; if (G.fr === 3) G.d -= 1; });   /* lift, swing, stab, plant */
  PFA.motion('bossB1-plummet', function (G, pp, k, ph) { var u = (pp * 1.4 + ph) % 1, v;                                              /* falls in from far out, bonk, split */
    if (u < .45) { v = u / .45; G.d += 14 * (1 - v * v); G.fr = 0; } else G.fr = u < .6 ? 1 : u < .85 ? 2 : 3; });
  PFA.motion('bossB1-brace', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; if (G.fr === 1) G.d -= 1; });                  /* the plate braces, the sheen slides */
  function carStride(c, e, H) {         /* the colossus walks to the next piece: three legs stepping along the outer loop, footfall pips, a shadow below */
    var P = e.P, Q = H.Q, k, u, fr, sd = e.d < 0 ? -1 : 1;
    for (u = 0; u <= e.hh; u += .04) { if (((u * 25) | 0) & 1) continue; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, e.acc); }
    for (k = 0; k < 3; k++) { u = e.hh - k * .11; if (u < 0) break; P.atq(e.a + e.d * u); fr = (Math.floor(e.p * 10) + k * 2) & 3;
      H.glyph(c, 'bossB1-leg', Q.x + Q.nx * 2, Q.y + Q.ny * 2, e.z > 1 ? 1 : e.z, fr, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
      if (fr === 3) H.sq(c, Q.x + Q.nx * 3 + Q.ny * sd * -6, Q.y + Q.ny * 3 - Q.nx * sd * -6, 2, e.hi); }
  }
  PFA.motif('titan-stride', comp, { nm: 'titan legs', desc: 'one colossal orange-red walking leg with a purple knee and cream bristles arching over the edge: it lifts, swings over and stabs its dark tip down with a white impact; the chain is the titan stepping along on three legs', fam: 'thrust', gap: 18, g: 'bossB1-leg', mo: 'bossB1-stride', x: '-', car: 'custom', carDraw: carStride });
  PFA.motif('coconut-plummet', comp, { nm: 'falling coconuts', desc: 'hairy coconuts with three eyes plummeting in from far out with a fall streak, landing with a bonk, splitting white and rocking apart', fam: 'bash', gap: 14, g: 'bossB1-coconut', mo: 'bossB1-plummet', x: '-', car: 'hop' });
  PFA.motif('titan-plate', comp, { nm: 'titan plates', desc: 'a vast ridged armour plate with dark grooves, cream knobs and a rim of short spines, bracing as a white sheen slides across', fam: 'shield', gap: 16, g: 'bossB1-plate', mo: 'bossB1-brace', x: '-', car: 'train' });

  /* ================= robber crab baron ================= */
  PFA.glyph('bossB1-baron', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the baron front-on: blue-grey shell, a red sash across it, a gold ring on one claw, strutting */
    var f = fr & 3, l = f === 1 ? 1 : 0, a, b, w = z > 1 ? 1 : 0;
    for (a = -3 - w; a <= 3 + w; a++) for (b = 1; b <= 3; b++) pt(c, K, x, y, tx, ty, nx, ny, a, b, C);
    pt(c, K, x, y, tx, ty, nx, ny, -4 - w, 2, C); pt(c, K, x, y, tx, ty, nx, ny, 4 + w, 2, C);
    for (a = -3; a <= 2; a++) pt(c, K, x, y, tx, ty, nx, ny, a, 1 + ((a + 3) >> 1), SASH);                                                 /* the stolen sash */
    pt(c, K, x, y, tx, ty, nx, ny, 0, 2, GOLD);                                                                                           /* sash pin */
    pt(c, K, x, y, tx, ty, nx, ny, -1, 4, C); pt(c, K, x, y, tx, ty, nx, ny, 1, 4, C); pt(c, K, x, y, tx, ty, nx, ny, -1, 5, A); pt(c, K, x, y, tx, ty, nx, ny, 1, 5, A);   /* eyestalks */
    pt(c, K, x, y, tx, ty, nx, ny, -5 - w, 2 + l, C); pt(c, K, x, y, tx, ty, nx, ny, -6 - w, 3 + l, C); pt(c, K, x, y, tx, ty, nx, ny, -6 - w, 4 + l, C); pt(c, K, x, y, tx, ty, nx, ny, -5 - w, 5 + l, C);   /* left claw */
    pt(c, K, x, y, tx, ty, nx, ny, 5 + w, 2 + l, C); pt(c, K, x, y, tx, ty, nx, ny, 6 + w, 3 + l, C); pt(c, K, x, y, tx, ty, nx, ny, 6 + w, 4 + l, C); pt(c, K, x, y, tx, ty, nx, ny, 5 + w, 5 + l, C);    /* right claw */
    pt(c, K, x, y, tx, ty, nx, ny, 5 + w, 3 + l, f === 3 ? K.WHITE : GOLD);                                                              /* the gold ring, glinting */
    pt(c, K, x, y, tx, ty, nx, ny, -4, 0, A); pt(c, K, x, y, tx, ty, nx, ny, 4, 0, A); pt(c, K, x, y, tx, ty, nx, ny, (f & 1) ? -3 : -5, -1, A); pt(c, K, x, y, tx, ty, nx, ny, (f & 1) ? 5 : 3, -1, A);   /* legs */
    if (f === 2) { pt(c, K, x, y, tx, ty, nx, ny, 3, 4, SASH); pt(c, K, x, y, tx, ty, nx, ny, 4, 5, SASH); }                              /* the sash end flaps */
  });
  PFA.glyph('bossB1-sash', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a silk sash whipping in S-curves, a gold fringe on the end */
    var j, a, b, ph = (fr & 3) * 1.2;
    for (j = 0; j < 10; j++) { a = j - 5; b = 3 + Math.sin(j * .7 + ph) * 2;
      st(c, K, x, y, tx, ty, nx, ny, a, b, 2, C); if (j & 1) pt(c, K, x, y, tx, ty, nx, ny, a, b - 1, A); if (j === 3 && z > 1) pt(c, K, x, y, tx, ty, nx, ny, a, b + 1, Hi); }
    b = 3 + Math.sin(9 * .7 + ph) * 2; pt(c, K, x, y, tx, ty, nx, ny, 5, b - 1, GOLD); pt(c, K, x, y, tx, ty, nx, ny, 5, b + 1, GOLD); pt(c, K, x, y, tx, ty, nx, ny, 6, b, GOLD);
  });
  PFA.glyph('bossB1-ring', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a gold signet ring with a ruby, turning: face, three-quarter, edge-on, back */
    var w = RING_W[fr & 3], h = 5 + (z > 1 ? 2 : 0), x0, y0;
    x = x + nx * 2; y = y + ny * 2; x0 = Math.round(x - (w >> 1)); y0 = Math.round(y - (h >> 1));
    if (w === 1) { K.bx(c, x0, y0, 1, h, Hi); K.px(c, x0, y0 - 1, RUBY); K.px(c, x0, y0 + 2, K.WHITE); return; }
    K.bx(c, x0 + 1, y0, w - 2, 1, C); K.bx(c, x0 + 1, y0 + h - 1, w - 2, 1, A); K.bx(c, x0, y0 + 1, 1, h - 2, C); K.bx(c, x0 + w - 1, y0 + 1, 1, h - 2, Hi);
    K.bx(c, x0 + (w >> 1) - (w > 3 ? 1 : 0), y0 - 2, w > 3 ? 3 : 1, 2, RUBY); K.px(c, x0 + (w >> 1), y0 - 2, K.WHITE);
  });
  PFA.glyph('bossB1-lid', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* looted armour: a dented pot lid with a knob, a fork stuck through, a bottle cap glint */
    var f = fr & 3, a, j = (f & 1) ? 1 : 0, w = 4 + (z > 1 ? 1 : 0);
    for (a = -w; a <= w; a++) { pt(c, K, x, y, tx, ty, nx, ny, a, 0, C); if (Math.abs(a) < w) pt(c, K, x, y, tx, ty, nx, ny, a, 1, C); if (Math.abs(a) < w - 1) pt(c, K, x, y, tx, ty, nx, ny, a, 2, Hi); }
    pt(c, K, x, y, tx, ty, nx, ny, 2, 1, A); pt(c, K, x, y, tx, ty, nx, ny, 1, 2, A);                                                   /* the dent */
    pt(c, K, x, y, tx, ty, nx, ny, -1, 3, A); pt(c, K, x, y, tx, ty, nx, ny, -1, 4, C);                                                 /* knob */
    seg(c, K, x, y, tx, ty, nx, ny, 3 + j, 2, 4 + j, 6, BARN);                                                                         /* fork handle and tines */
    pt(c, K, x, y, tx, ty, nx, ny, 3 + j, 7, BARN); pt(c, K, x, y, tx, ty, nx, ny, 5 + j, 7, BARN); pt(c, K, x, y, tx, ty, nx, ny, 4 + j, 8, BARN);
    pt(c, K, x, y, tx, ty, nx, ny, -4, 2, f === 2 ? K.WHITE : RUBY); pt(c, K, x, y, tx, ty, nx, ny, -3, 3, RUBY);                       /* bottle cap */
  });
  PFA.glyph('bossB1-scroll', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a decree scroll unrolling between its two rolled ends, then the red wax seal */
    var f = fr & 3, w = SCROLL_W[f] + (z > 1 && f > 1 ? 1 : 0), h = w >> 1, a, b;
    for (a = -h; a <= w - h - 1; a++) for (b = 1; b <= 3; b++) pt(c, K, x, y, tx, ty, nx, ny, a, b, C);
    for (a = -h + 1; a < w - h - 1; a += 2) pt(c, K, x, y, tx, ty, nx, ny, a, 2, A);                                                   /* lines of the decree */
    for (b = 0; b <= 4; b++) { pt(c, K, x, y, tx, ty, nx, ny, -h - 1, b, Hi); pt(c, K, x, y, tx, ty, nx, ny, w - h, b, Hi); }          /* rolled ends */
    pt(c, K, x, y, tx, ty, nx, ny, -h - 1, 2, A); pt(c, K, x, y, tx, ty, nx, ny, w - h, 2, A);
    if (f === 3) { st(c, K, x, y, tx, ty, nx, ny, 0, 1, 2, RUBY); pt(c, K, x, y, tx, ty, nx, ny, -1, -1, RUBY); pt(c, K, x, y, tx, ty, nx, ny, 1, -1, RUBY); pt(c, K, x, y, tx, ty, nx, ny, 0, 5, K.WHITE); }
  });
  PFA.motion('bossB1-strut', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; G.up += G.fr & 1; G.t += Math.sin(pp * 6 + k) * 1.5; });   /* a pompous strut */
  PFA.motion('bossB1-whip', function (G, pp, k) { G.fr = (Math.floor(pp * 12) + k) & 3; G.t += Math.sin(pp * 9 + k) * 2; });                       /* the sash cracks like a whip */
  PFA.motion('bossB1-flick', function (G, pp, k) { G.fr = (Math.floor(pp * 12) + k) & 3; G.up += Math.abs(Math.sin(pp * 5 + k)) * 3; });          /* rings flicked and spinning */
  PFA.motion('bossB1-rattle', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; G.t += ((Math.floor(pp * 24) + k) & 1) ? 1 : -1; });    /* stolen tin rattling */
  PFA.motion('bossB1-unroll', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.4 + ph) % 1) * 4.5)); });                         /* unroll, read, seal */
  function carSash(c, e, H) {           /* the baron struts to the next piece, his long red sash streaming behind him, a gold fringe at the tail */
    var P = e.P, Q = H.Q, u, i = 0, b, u0 = Math.max(0, e.hh - .4), sd = e.d < 0 ? -1 : 1;
    for (u = u0; u <= e.hh; u += .02, i++) { P.atq(e.a + e.d * u); b = 5 + Math.sin(i * .6 + e.p * 18) * 2;
      H.sq(c, Q.x + Q.nx * b, Q.y + Q.ny * b, 2, i === 0 ? GOLD : SASH); if ((i & 3) === 1) H.px(c, Q.x + Q.nx * (b - 1), Q.y + Q.ny * (b - 1), e.acc); }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'bossB1-baron', Q.x + Q.nx * 4, Q.y + Q.ny * 4 - ((Math.floor(e.p * 12) & 1)), e.z > 1 ? 1 : e.z, Math.floor(e.p * 12) & 3, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
  }
  PFA.motif('baron-sash', comp, { nm: 'sashed barons', desc: 'a blue-grey robber crab front-on wearing a stolen red sash with a gold pin and a gold ring on one claw, strutting pompously, the ring glinting; the chain is the baron strutting on with his sash streaming behind', fam: 'bash', gap: 18, g: 'bossB1-baron', mo: 'bossB1-strut', x: '-', car: 'custom', carDraw: carSash });
  PFA.motif('sash-ribbon', comp, { nm: 'whipping sashes', desc: 'a red silk sash whipping off the edge in S-curves, a gold fringe flicking at its end', fam: 'slash', gap: 16, g: 'bossB1-sash', mo: 'bossB1-whip', x: '-', car: 'comet' });
  PFA.motif('ruby-signet', comp, { nm: 'ruby signets', desc: 'gold signet rings with a ruby turning in the air: full face, three-quarter, edge-on, a white glint on the stone', fam: 'sparkle', gap: 12, g: 'bossB1-ring', mo: 'bossB1-flick', x: '-', car: 'blink' });
  PFA.motif('plunder-lid', comp, { nm: 'plunder armour', desc: 'stolen armour: a dented pot lid with a knob, a fork stuck through it and a red bottle cap, rattling', fam: 'thorn', gap: 16, g: 'bossB1-lid', mo: 'bossB1-rattle', x: '-', car: 'train' });
  PFA.motif('baron-decree', comp, { nm: 'decrees', desc: 'a parchment scroll unrolling between its rolled ends, lines of writing, then a red wax seal stamped on with a white flash', fam: 'sparkle', gap: 16, g: 'bossB1-scroll', mo: 'bossB1-unroll', x: '-', car: 'hop' });

  /* ================= reef leviathan ================= */
  PFA.glyph('bossB1-coil', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a sea-serpent hump breaching: thick mottled body, yellow fin crest, dark belly, foam at the water line */
    var f = fr & 3, hh = COIL_H[f] + (z > 1 ? 1 : 0), a, b, t;
    for (a = -5; a <= 5; a++) { t = Math.sin(Math.PI * (a + 5) / 10); b = Math.round(t * hh);
      pt(c, K, x, y, tx, ty, nx, ny, a, b, ((a + f) & 3) === 0 ? Hi : C); pt(c, K, x, y, tx, ty, nx, ny, a, b + 1, C);
      if (t > .3) pt(c, K, x, y, tx, ty, nx, ny, a, b - 1, A);
      if (!(a & 1) && t > .45) pt(c, K, x, y, tx, ty, nx, ny, a, b + 2, Hi); }
    if (!(f & 1)) { pt(c, K, x, y, tx, ty, nx, ny, -6, 1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 6, 1, K.WHITE); }
    else { pt(c, K, x, y, tx, ty, nx, ny, -7, 0, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 7, 0, K.WHITE); }
  });
  PFA.glyph('bossB1-maw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* the leviathan head pointing out, lower jaw unhinging wide, needle teeth, a fish sucked in, gulp */
    var f = fr & 3, o = MAW_O[f], L = 7 + (z > 1 ? 1 : 0), b, ua, la, q;
    for (b = 0; b <= 2; b++) { pt(c, K, x, y, tx, ty, nx, ny, -2, b, C); pt(c, K, x, y, tx, ty, nx, ny, -1, b, C); pt(c, K, x, y, tx, ty, nx, ny, 0, b, C); pt(c, K, x, y, tx, ty, nx, ny, 1, b, f === 3 ? C : A); }
    for (b = 3; b <= L; b++) { q = (b - 3) / (L - 3); ua = -1 - Math.round(o * .4 * q); la = 1 + Math.round(o * q);
      pt(c, K, x, y, tx, ty, nx, ny, ua - 1, b, C); pt(c, K, x, y, tx, ty, nx, ny, ua, b, C);
      if (b < L) pt(c, K, x, y, tx, ty, nx, ny, la, b, C);
      for (q = ua + 1; q < la; q++) pt(c, K, x, y, tx, ty, nx, ny, q, b, A);
      if (o && (b & 1) && la - ua > 2) { pt(c, K, x, y, tx, ty, nx, ny, ua + 1, b, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, la - 1, b, K.WHITE); } }
    pt(c, K, x, y, tx, ty, nx, ny, -3, 5, Hi); pt(c, K, x, y, tx, ty, nx, ny, -2, 6, Hi);                                                   /* yellow eye, mottle */
    pt(c, K, x, y, tx, ty, nx, ny, -1 - Math.round(o * .4), L + 1, C);                                                                      /* snout tip */
    if (f === 2) { pt(c, K, x, y, tx, ty, nx, ny, 1, L + 2, K.DEW); pt(c, K, x, y, tx, ty, nx, ny, 2, L + 2, K.DEW); pt(c, K, x, y, tx, ty, nx, ny, 3, L + 3, K.DEW); pt(c, K, x, y, tx, ty, nx, ny, 3, L + 1, K.DEW); }   /* a fish sucked in */
    if (f === 3) { pt(c, K, x, y, tx, ty, nx, ny, -4, L + 1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 3, L + 1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 0, 1, Hi); pt(c, K, x, y, tx, ty, nx, ny, 0, 2, Hi); }   /* gulp: the lump goes down */
  });
  PFA.motion('bossB1-breach', function (G, pp, k) { G.s += pp * .22; G.fr = (Math.floor(pp * 10) + k) & 3; G.d += Math.sin(pp * 8 + k) - 1; });   /* humps rolling on through the water */
  PFA.motion('bossB1-gulp', function (G, pp, k, ph) { var u = (pp * 1.8 + ph) % 1;                                                                  /* draw back, unhinge, lunge, gulp */
    if (u < .3) { G.fr = 1; G.d -= 1; } else if (u < .6) { G.fr = 2; G.d += 3; } else G.fr = u < .8 ? 3 : 0; });
  function carSerpent(c, e, H) {        /* the leviathan swims to the next piece: humps breach along the outer loop behind its head, foam where they cut the water */
    var P = e.P, Q = H.Q, k, u, b, sd = e.d < 0 ? -1 : 1, s;
    for (k = 1; k <= 16; k++) { u = e.hh - k * .025; if (u < 0) break; P.atq(e.a + e.d * u); s = Math.sin(k * .5 - e.p * 9);
      b = 3 + Math.max(0, s) * 6; H.sq(c, Q.x + Q.nx * b, Q.y + Q.ny * b, 2, s > .6 && (k & 1) ? e.hi : e.col);
      if (s > .5 && !(k & 1)) H.px(c, Q.x + Q.nx * (b + 2), Q.y + Q.ny * (b + 2), e.hi);
      else if (s < -.2 && (k & 3) === 0) H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, H.WHITE); }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'bossB1-maw', Q.x + Q.nx * 2, Q.y + Q.ny * 2, e.z > 1 ? 1 : e.z, e.hh > .92 ? 3 : (Math.floor(e.p * 8) & 1) ? 2 : 1, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
  }
  PFA.motif('leviathan-coil', comp, { nm: 'breaching coils', desc: 'thick mottled sea-serpent humps breaching out of the water along the edge, a yellow fin crest on top, dark belly, foam where they cut the surface; the chain is the whole leviathan swimming on, humps rolling behind its head', fam: 'slash', gap: 18, g: 'bossB1-coil', mo: 'bossB1-breach', x: '-', car: 'custom', carDraw: carSerpent });
  PFA.motif('leviathan-maw', comp, { nm: 'unhinged maws', desc: 'a huge serpent head pointing out: the lower jaw unhinges wide on white needle teeth, a fish is sucked in and the lump goes down the throat', fam: 'bite', gap: 18, g: 'bossB1-maw', mo: 'bossB1-gulp', x: '-', car: 'comet' });

  /* ================= ancient snapping turtle ================= */
  PFA.glyph('bossB1-mossbeak', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* an ancient head front-on: barnacled brow, moss growing on top, the hooked beak gaping like a trap and slamming shut */
    var f = fr & 3, g = BEAK_G[f], w = 4 + (z > 1 ? 1 : 0), a, b, sw = (f & 1) ? 1 : -1;
    for (a = -w; a <= w; a++) { pt(c, K, x, y, tx, ty, nx, ny, a, 0, C); if (Math.abs(a) < w) pt(c, K, x, y, tx, ty, nx, ny, a, 1, C); }   /* lower jaw */
    for (b = 2; b < 2 + g; b++) for (a = -w + 1; a <= w - 1; a++) pt(c, K, x, y, tx, ty, nx, ny, a, b, A);                              /* the dark gape */
    if (g) { pt(c, K, x, y, tx, ty, nx, ny, -1, 2, Hi); pt(c, K, x, y, tx, ty, nx, ny, 1, 2, Hi); }                                       /* pink lure on the tongue */
    for (a = -w; a <= w; a++) { pt(c, K, x, y, tx, ty, nx, ny, a, 2 + g, C); if (Math.abs(a) < w) pt(c, K, x, y, tx, ty, nx, ny, a, 3 + g, C); }   /* upper jaw */
    for (a = -w + 2; a <= w - 2; a++) { pt(c, K, x, y, tx, ty, nx, ny, a, 4 + g, C); pt(c, K, x, y, tx, ty, nx, ny, a, 5 + g, C); }    /* brow */
    pt(c, K, x, y, tx, ty, nx, ny, 0, 1 + g, C); pt(c, K, x, y, tx, ty, nx, ny, 0, g, A);                                                 /* the hook, hanging into the gape */
    pt(c, K, x, y, tx, ty, nx, ny, -2, 4 + g, A); pt(c, K, x, y, tx, ty, nx, ny, 2, 4 + g, A);                                            /* small deep-set eyes */
    pt(c, K, x, y, tx, ty, nx, ny, 1, 5 + g, BARN); pt(c, K, x, y, tx, ty, nx, ny, -3, 3 + g, BARN);                                      /* barnacles */
    for (b = 1; b <= 2 + (z > 1 ? 1 : 0); b++) { pt(c, K, x, y, tx, ty, nx, ny, -2 + sw * b * .5, 5 + g + b, MOSS); pt(c, K, x, y, tx, ty, nx, ny, 1 + sw * b * .5, 5 + g + b, MOSS); }   /* moss tufts */
    if (f === 3) { pt(c, K, x, y, tx, ty, nx, ny, -w - 2, 1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, -w - 3, 3, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, w + 2, 1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, w + 3, 3, K.WHITE); }
  });
  PFA.glyph('bossB1-scute', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a shell scute gaining growth rings one by one: the years it waited */
    var n = Math.min(3, (fr & 3) + 1), r, cx = x + nx * 2, cy = y + ny * 2, o = z > 1 ? 1 : 0;
    K.sq(c, cx, cy, 3, Hi); K.px(c, cx, cy, A);
    for (r = 2; r <= n + 1; r++) K.ringpx(c, cx, cy, r + o, (r & 1) ? Hi : C);
    if (n === 3) K.px(c, cx - 2 - o, cy - 2 - o, K.WHITE);
  });
  PFA.motion('bossB1-trap', function (G, pp, k, ph) { var u = (pp * 1.3 + ph) % 1;                                                    /* patient gape, then the trap slams */
    if (u < .6) G.fr = u < .25 ? 1 : 2; else if (u < .72) { G.fr = 3; G.d += 3; } else G.fr = 0; });
  PFA.motion('bossB1-years', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 5 + ph * 2)); });                          /* rings added slowly */
  PFA.motif('moss-beak', comp, { nm: 'mossy beaks', desc: 'an ancient snapping turtle head front-on, barnacles on the brow and moss tufts growing on top, gaping patiently on a pink lure, then the hooked beak slams shut with white crack marks', fam: 'bite', gap: 18, g: 'bossB1-mossbeak', mo: 'bossB1-trap', x: '-', car: 'trail' });
  PFA.motif('age-scute', comp, { nm: 'growth rings', desc: 'shell scutes gaining concentric growth rings one by one, a glint on the last: centuries of waiting', fam: 'mend', gap: 14, g: 'bossB1-scute', mo: 'bossB1-years', x: '-', car: 'rings' });
})();
