/* Motif module, medium batch m02 (termite-column, leafcutter-column, army-ant-column, paper-wasp, hornet-sentry, mud-dauber, carpenter-bee,
   lantern-glowworm-queen, earwig-matron, luna-moth). TEMPLATE.md section 10.3.
   19 motifs, each with its own pixel glyph (ids prefixed m02-) and, where the existing motions did not fit, its own motion.
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation inside the frame loops (scratch H.Q / H.G,
   static tables built once at load). Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule,
   visual-only sound lines and the creature-heavy default are untouched (they live in the page). */
(function () {
  /* ---------- shared own-edge composition: the page's themedOwn() with this module's glyph / motion, plus an optional per-run decoration ---------- */
  function comp(c, e, H, deco) {
    var runs = e.runs, mp = e.mp, M = e.M, z = e.z, p = e.p, pp = p * mp.spd, Q = H.Q, G = H.G, P = e.P,
      tie = mp.x === 'thread' || mp.lay === 'snare', ri, k, r, len, n, f, ph, sf, bx0, by0, nx, ny, x, y, lx = 0, ly = 0, has;
    for (ri = 0; ri < runs.length; ri++) {
      r = runs[ri]; len = r[1] - r[0]; n = Math.max(1, Math.min(8, Math.round(len / (M.gap || 12)))); if (mp.lay === 'lance') n = Math.min(n, 4); has = false;
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

  /* ---------- per-run decorations (few pixels each) ---------- */
  function decoLeafBits(c, e, H, s0, len, ri, pp) {      /* leaf-snip: cut crescents flutter down from the jaws */
    var k, u, Q = H.Q, X, Y;
    for (k = 0; k < 3; k++) { u = (pp * 1.1 + H.hash(e.seed + k * 5 + ri)) % 1; if (e.p > .92) break;
      e.P.atq(s0 + len * H.hash(e.seed + k * 3 + ri * 7)); X = Q.x + Q.nx * 6 + Math.sin(u * 7 + k) * 3; Y = Q.y + Q.ny * 6 + 14 * u;
      H.px(c, X, Y, e.col); H.px(c, X + ((Math.floor(u * 8) & 1) ? 1 : -1), Y, e.col); H.px(c, X, Y + 1, e.acc); }
  }
  function decoGloss(c, e, H, s0, len, ri, pp) {          /* bore-bee: a bright gloss streak runs along the edge once (blue-black shine) */
    var u = (pp * .9 + ri * .37) % 1, Q = H.Q; if (e.p > .9) return;
    e.P.atq(s0 + len * u); H.bx(c, Q.x + Q.nx * 3 - 1, Q.y + Q.ny * 3, 3, 1, H.WHITE); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3 - 1, e.hi);
  }
  function decoGlowPool(c, e, H, s0, len, ri, pp) {       /* lamp-queen: the lamps light a dotted pool of light on the felt below the edge */
    var k, Q = H.Q, on = Math.sin(Math.PI * Math.min(1, e.p * 1.1));
    for (k = 0; k < 6; k++) if (H.hash(k * 3.7 + ri + Math.floor(pp * 10)) < .55 * on) { e.P.atq(s0 + len * (k + .5) / 6); H.px(c, Q.x + Q.nx * 12, Q.y + Q.ny * 12 + 2, e.col); }
  }
  function decoMudDrip(c, e, H, s0, len, ri, pp) {        /* mud-pipe: wet mud beads slide down the fresh pipes */
    var k, u, Q = H.Q; if (e.p > .9) return;
    for (k = 0; k < 2; k++) { u = (pp * 1.3 + k * .5 + ri * .2) % 1; e.P.atq(s0 + len * (k + .5) / 2); H.sq(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4 + 8 * u, 2, e.hi); }
  }
  function decoEggShine(c, e, H, s0, len, ri, pp) {       /* egg-brood: tiny licked-clean shines blink on the clutch */
    var k, Q = H.Q, X, Y; if (e.p > .92) return;
    for (k = 0; k < 2; k++) if ((Math.floor(pp * 9) + k + ri) % 3 === 0) { e.P.atq(s0 + len * H.hash(e.seed + k * 11 + ri)); X = Q.x + Q.nx * 9; Y = Q.y + Q.ny * 9 - 3;
      H.px(c, X, Y, H.WHITE); H.px(c, X - 1, Y + 1, e.hi); H.px(c, X + 1, Y + 1, e.hi); H.px(c, X, Y + 2, e.hi); }
  }
  function decoTailWake(c, e, H, s0, len, ri, pp) {       /* luna-tail: a faint green wake of wing scales stays behind the sweep */
    var k, u, Q = H.Q;
    for (k = 0; k < 5; k++) { u = (pp * .7 + H.hash(e.seed + k * 9 + ri)) % 1; if (u > .7) continue; e.P.atq(s0 + len * H.hash(e.seed + k * 13 + ri * 3));
      H.px(c, Q.x + Q.nx * (6 + 4 * u) + Math.sin(u * 6 + k) * 2, Q.y + Q.ny * (6 + 4 * u) + 9 * u, k & 1 ? e.hi : e.col); }
  }

  /* ---------- glyphs: (c, x, y, z, fr, C main, A dark, Hi, tx, ty along-edge, nx, ny outward, H helpers) ---------- */
  PFA.glyph('m02-termite', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {     /* pale soft body inward, big brown head outward, dark jaws */
    var o = fr ? 1 : 2, d = fr ? 1 : 0, hx = x + nx * d, hy = y + ny * d;
    H.sq(c, x - nx * 5, y - ny * 5, 3, C); H.sq(c, x - nx * 2.5, y - ny * 2.5, 3, C); H.px(c, x - nx * 4 + tx, y - ny * 4 + ty, A);
    H.sq(c, hx, hy, 3 + (z > 0 ? 1 : 0), Hi); H.px(c, hx - tx, hy - ty, C);
    H.px(c, hx + nx * 3 + tx * o, hy + ny * 3 + ty * o, A); H.px(c, hx + nx * 3 - tx * o, hy + ny * 3 - ty * o, A);
    H.px(c, hx + nx * 4 + tx * (o - 1), hy + ny * 4 + ty * (o - 1), C); H.px(c, hx + nx * 4 - tx * (o - 1), hy + ny * 4 - ty * (o - 1), C);
  });
  PFA.glyph('m02-spire', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {       /* clay mound spire: stepped cone, vent on top, shade on the right */
    var h = 5 + z * 2, i, w;
    for (i = 0; i < h; i++) { w = 1 + 2 * Math.floor(i * 3 / h); H.bx(c, x - (w >> 1), y - h + 1 + i, w, 1, C); if (w > 1) H.px(c, x + (w >> 1), y - h + 1 + i, Hi); }
    H.px(c, x, y - h + 1, A); H.px(c, x - 1, y - (h >> 1), A);
    if (fr) { H.px(c, x - 3, y, Hi); H.px(c, x + 3, y - 1, Hi); }
  });
  PFA.glyph('m02-leafant', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {     /* rust ant under a raised green leaf piece that sways */
    var s = fr ? 1 : 0, i;
    H.bx(c, x - 3 + s, y - 2, 7, 1, C); H.bx(c, x - 3 + s, y - 3, 6, 1, C); H.bx(c, x - 2 + s, y - 4, 4, 1, C); H.px(c, x - 1 + s, y - 5, C); H.px(c, x + s, y - 3, A);
    if (z > 0) H.bx(c, x - 4 + s, y - 2, 1, 1, C);
    for (i = -1; i <= 1; i++) H.sq(c, x + tx * 2 * i, y + 1 + ty * 2 * i, 2, Hi);
    H.px(c, x, y - 1, Hi); H.px(c, x - 2, y + 2 + s, A); H.px(c, x + 2, y + 3 - s, A);
  });
  PFA.glyph('m02-snip', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {        /* half-cut leaf crescent with scissor jaws at the cut */
    H.bx(c, x - 1, y - 2, 3, 1, C); H.bx(c, x - 2, y - 1, 2, 3, C); H.bx(c, x - 1, y + 2, 3, 1, C); H.px(c, x + 1, y - 1, C); H.px(c, x + 1, y + 1, C); H.px(c, x - 1, y, A);
    if (z > 0) { H.px(c, x - 3, y, C); H.px(c, x + 2, y - 2, C); H.px(c, x + 2, y + 2, C); }
    if (fr) { H.px(c, x + 3, y - 1, Hi); H.px(c, x + 3, y + 1, Hi); H.px(c, x + 4, y - 2, Hi); H.px(c, x + 4, y + 2, Hi); }
    else { H.px(c, x + 3, y, Hi); H.px(c, x + 4, y - 1, Hi); H.px(c, x + 4, y + 1, Hi); }
  });
  PFA.glyph('m02-army', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {        /* dark-red army ant along the edge, huge pale sickle jaws ahead */
    var o = fr ? 2 : 1, hx = x + tx * 2, hy = y + ty * 2;
    H.sq(c, x - tx * 3, y - ty * 3, 3, C); H.sq(c, x, y, 2, C); H.sq(c, hx, hy, 3, C);
    H.px(c, x + nx * 2, y + ny * 2, A); H.px(c, x - nx * 2, y - ny * 2, A);
    H.px(c, hx + tx * 2 + nx * o, hy + ty * 2 + ny * o, Hi); H.px(c, hx + tx * 2 - nx * o, hy + ty * 2 - ny * o, Hi);
    H.px(c, hx + tx * 3 + nx * (o - 1), hy + ty * 3 + ny * (o - 1), Hi); H.px(c, hx + tx * 3 - nx * (o - 1), hy + ty * 3 - ny * (o - 1), Hi);
    if (z > 1) { H.px(c, hx + tx * 4, hy + ty * 4 + 1, Hi); H.px(c, hx + tx * 4, hy + ty * 4 - 1, Hi); }
  });
  PFA.glyph('m02-lattice', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {     /* bivouac wall: crossed ant bodies hooked together, jaw tips flashing */
    H.ln(c, x - 3, y - 2, x + 3, y + 2, 1, C); H.ln(c, x - 3, y + 2, x + 3, y - 2, 1, C); H.sq(c, x, y, 2, A); H.px(c, x, y, C);
    H.px(c, x - 4 - (fr ? 0 : 1), y - 3, Hi); H.px(c, x + 4 + (fr ? 1 : 0), y + 3, Hi); H.px(c, x - 4 - (fr ? 1 : 0), y + 3, Hi); H.px(c, x + 4 + (fr ? 0 : 1), y - 3, Hi);
  });
  PFA.glyph('m02-dangler', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {     /* slim paper wasp in flight, long legs hanging down, yellow feet */
    var L = 4 + z;
    H.bx(c, x - 2, y - 1, 5, 2, C); H.px(c, x - 1, y - 1, A); H.px(c, x + 1, y, A); H.px(c, x + 3, y - 1, A);
    if (fr) { H.px(c, x - 1, y - 3, Hi); H.px(c, x, y - 3, Hi); H.px(c, x + 1, y - 2, Hi); } else { H.px(c, x - 2, y - 2, Hi); H.px(c, x - 1, y - 2, Hi); H.px(c, x + 1, y - 3, Hi); }
    H.ln(c, x - 1, y + 1, x - 2, y + L, 1, A); H.ln(c, x + 1, y + 1, x + 1, y + L + 1, 1, A); H.px(c, x - 2, y + L + 1, C); H.px(c, x + 1, y + L + 2, C);
  });
  PFA.glyph('m02-papercell', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {   /* open grey paper cell, egg inside, chewed fibre streak */
    H.bx(c, x - 1, y - 3, 3, 1, C); H.bx(c, x - 1, y + 3, 3, 1, C); H.bx(c, x - 2, y - 2, 1, 5, C); H.bx(c, x + 2, y - 2, 1, 5, C);
    H.px(c, x, y + (fr ? 0 : 1), A); H.px(c, x - 1 + fr, y - 1, Hi); if (z > 0) H.px(c, x + 3, y, C);
  });
  PFA.glyph('m02-hornet', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {      /* head-on hornet sentry: orange face, big dark eyes, banded body, wings */
    var e = fr ? 1 : 0;
    H.bx(c, x - 2, y - 3, 5, 3, C); H.bx(c, x - 2 + e, y - 3, 1, 2, A); H.bx(c, x + 2 - (1 - e), y - 3, 1, 2, A);
    H.bx(c, x - 1, y, 3, 1, A); H.bx(c, x - 1, y + 1, 3, 1, C); H.bx(c, x - 1, y + 2, 3, 1, A); H.bx(c, x - 1, y + 3, 3, 1, C); H.px(c, x, y + 4, A);
    if (fr) { H.px(c, x - 3, y - 1, Hi); H.px(c, x - 4, y, Hi); H.px(c, x + 3, y - 1, Hi); H.px(c, x + 4, y, Hi); } else { H.px(c, x - 3, y, Hi); H.px(c, x - 4, y + 1, Hi); H.px(c, x + 3, y, Hi); H.px(c, x + 4, y + 1, Hi); }
    if (z > 1) H.bx(c, x - 1, y - 4, 3, 1, C);
  });
  PFA.glyph('m02-envelope', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {    /* hornet nest envelope: scalloped paper bands, round door */
    var i, j;
    for (j = 0; j < 3; j++) for (i = -3; i <= 3; i++) H.px(c, x + i, y - 3 + j * 2 + ((i + j + fr) & 1), j === 1 ? Hi : C);
    H.sq(c, x, y + 3, 2, A); H.px(c, x - 1, y + 3, C); if (z > 0) { H.px(c, x - 4, y - 1, C); H.px(c, x + 4, y + 1, C); }
  });
  PFA.glyph('m02-pipe', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {        /* organ-pipe mud tube growing ring by ring, dark mouth on top */
    var n = 1 + (fr & 3) + (z >> 1), j, yy;
    for (j = 0; j < n; j++) { yy = y - j * 2; H.bx(c, x - 1, yy - 1, 3, 2, j & 1 ? Hi : C); H.px(c, x - 2, yy, C); H.px(c, x + 2, yy - 1, A); }
    yy = y - n * 2; H.bx(c, x - 1, yy, 3, 1, Hi); H.px(c, x, yy, A);
  });
  PFA.glyph('m02-mudwasp', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {     /* slim black thread-waisted wasp hugging a mud ball */
    H.sq(c, x, y + 2, 3 + (z > 1 ? 1 : 0), C); H.px(c, x - 1, y + 1, Hi);
    H.sq(c, x, y - 2, 2, A); H.ln(c, x + 1, y - 2, x + 3, y - 2, 1, A); H.bx(c, x + 3, y - 3, 3, 2, A); H.px(c, x + 4, y - 3, C);
    H.px(c, x - 1, y, A); H.px(c, x + 1, y, A); H.px(c, x - 1, y - 3, A);
    if (fr) { H.px(c, x - 1, y - 5, Hi); H.px(c, x + 1, y - 5, Hi); } else { H.px(c, x - 2, y - 4, Hi); H.px(c, x + 2, y - 4, Hi); }
  });
  PFA.glyph('m02-borebee', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {     /* round glossy blue-black carpenter bee, white gloss spot */
    var r = z > 1 ? 1 : 0;
    H.bx(c, x - 2 - r, y - 1, 5 + 2 * r, 3, C); H.bx(c, x - 1 - r, y - 2, 3 + 2 * r, 1, C); H.bx(c, x - 1 - r, y + 2, 3 + 2 * r, 1, C);
    H.bx(c, x - 2 - r, y + 1, 5 + 2 * r, 1, A); H.px(c, x - 1, y - 1, H.WHITE); H.px(c, x, y - 1, H.WHITE); H.px(c, x + 3 + r, y, A);
    if (fr) { H.px(c, x - 2, y - 4, Hi); H.px(c, x - 1, y - 3, Hi); H.px(c, x + 2, y - 4, Hi); H.px(c, x + 1, y - 3, Hi); } else { H.px(c, x - 3, y - 3, Hi); H.px(c, x + 3, y - 3, Hi); }
  });
  var SPIN = [[4, 0], [0, 4], [-4, 0], [0, -4]];   /* static table, built once */
  PFA.glyph('m02-bore', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {        /* perfectly round bore hole: wood rim, dark core, a sawdust chip spinning out */
    var q = SPIN[fr & 3];
    H.ringpx(c, x, y, 2 + (z >> 1), C); H.sq(c, x, y, 3, A); H.px(c, x - 1, y - 2 - (z >> 1), Hi);
    H.px(c, x + q[0] + (z >> 1), y + q[1], Hi); H.px(c, x + q[0] * .5 + q[1] * .5, y + q[1] * .5 - q[0] * .5, Hi);
  });
  PFA.glyph('m02-lamp', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {        /* big glow lamp: halo ring that breathes, white-hot core, a sticky bead below */
    var r = 4 + z;
    if (fr & 1) H.ringpx(c, x, y, r, Hi); else { H.px(c, x - r + 1, y - r + 1, Hi); H.px(c, x + r - 1, y - r + 1, Hi); H.px(c, x - r + 1, y + r - 1, Hi); H.px(c, x + r - 1, y + r - 1, Hi); }
    H.sq(c, x, y, 3 + (z > 0 ? 1 : 0), C); H.px(c, x, y, H.WHITE); H.px(c, x - 1, y - 1, H.WHITE);
    if (fr) { H.px(c, x, y + r + 1, C); H.px(c, x, y + r + 2, Hi); }
  });
  PFA.glyph('m02-curtain', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {     /* one long silk thread hanging down, two glowing beads sliding */
    var L = 7 + z * 2;
    H.ln(c, x, y - 1, x, y + L, 1, Hi); H.sq(c, x, y + 2 + (fr ? 1 : 0), 2, C); H.sq(c, x, y + L - 1 - (fr ? 0 : 1), 2, C); H.px(c, x, y + L + 1, H.WHITE);
  });
  PFA.glyph('m02-eggs', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {        /* pale oval egg clutch (3, 4 when heavy), jostled; chestnut shadows */
    var j = fr === 0 ? -1 : fr === 1 ? 0 : 1;
    H.bx(c, x - 3, y - 1, 2, 3, Hi); H.px(c, x - 3, y - 1, H.WHITE); H.px(c, x - 2, y + 2, C);
    H.bx(c, x + 1, y - 1, 2, 3, Hi); H.px(c, x + 1, y - 1, H.WHITE); H.px(c, x + 2, y + 2, C);
    H.bx(c, x - 1 + j, y - 4, 2, 3, Hi); H.px(c, x - 1 + j, y - 4, H.WHITE); H.px(c, x + j, y - 1, C);
    if (z > 0) { H.bx(c, x - 1, y + 2, 2, 2, Hi); H.px(c, x, y + 4, C); }
  });
  PFA.glyph('m02-luna', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {        /* luna moth: big pale green wings, purple leading edge, eyespots, long swaying tails */
    var o = fr === 1 ? 1 : 0, s = fr === 0 ? -1 : fr === 2 ? 1 : 0, L = 5 + z;
    H.bx(c, x - 4 + o, y - 3 - o, 3, 3, C); H.bx(c, x + 2 - o, y - 3 - o, 3, 3, C); H.bx(c, x - 4 + o, y - 4 - o, 3, 1, A); H.bx(c, x + 2 - o, y - 4 - o, 3, 1, A);
    H.bx(c, x - 3, y, 2, 2, C); H.bx(c, x + 2, y, 2, 2, C); H.bx(c, x, y - 3, 1, 4, H.WHITE);
    H.px(c, x - 3 + o, y - 2 - o, Hi); H.px(c, x + 3 - o, y - 2 - o, Hi); H.px(c, x - 2, y + 1, A); H.px(c, x + 2, y + 1, A);
    H.ln(c, x - 3, y + 2, x - 3 + s - 1, y + L + 1, 1, C); H.ln(c, x + 3, y + 2, x + 3 + s + 1, y + L + 1, 1, C);
    H.px(c, x - 4 + s, y + L + 2, Hi); H.px(c, x + 4 + s, y + L + 2, Hi);
  });
  var MOON = [[0, -3], [1, -3], [-1, -2], [-2, -1], [-2, 0], [-2, 1], [-1, 2], [0, 3], [1, 3], [-1, -1], [-1, 0], [-1, 1]];   /* crescent opening right */
  PFA.glyph('m02-crescent', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, H) {    /* pale moon crescent, tips glinting */
    var i, q;
    for (i = 0; i < MOON.length; i++) { q = MOON[i]; H.px(c, x + q[0], y + q[1], C); }
    if (z > 0) { H.px(c, x - 3, y, C); H.px(c, x + 2, y - 4, C); H.px(c, x + 2, y + 4, C); }
    if (fr) { H.px(c, x + 2, y - 3, Hi); H.px(c, x + 2, y + 3, Hi); } else H.px(c, x - 2, y, H.WHITE);
  });

  /* ---------- motions (mutate the scratch G; pp = time x speed, k = glyph index, ph = per-glyph hash) ---------- */
  PFA.motion('m02-headbang', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 14 + ph * 3) + k) & 1; G.d += G.fr * 2; });          /* soldier termites drum their heads */
  PFA.motion('m02-parade', function (G, pp, k, ph) { G.s += pp * .25; G.fr = (Math.floor(pp * 12) + k) & 1; G.up += G.fr; G.t += Math.sin(pp * 10 + k) * .8; });
  PFA.motion('m02-flood', function (G, pp, k, ph) { G.s += pp * .7; G.d += Math.sin(pp * 20 + k * 1.3) * 1.5; G.fr = (Math.floor(pp * 26) + k) & 1; });
  PFA.motion('m02-dangle', function (G, pp, k, ph) { G.t += Math.sin(pp * 4 + ph * 6) * 3; G.up += Math.sin(pp * 7 + k) * 2; G.fr = (Math.floor(pp * 20) + k) & 1; });
  PFA.motion('m02-sentry', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.t += (w < .5 ? w : 1 - w) * 12 - 3; G.fr = w < .5 ? 0 : 1; });   /* pace and turn */
  PFA.motion('m02-stack', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(pp * 5 + ph * 1.5)); });
  PFA.motion('m02-haul', function (G, pp, k, ph) { G.up += Math.sin(pp * 6 + ph * 6) * 2 - 1; G.t += Math.sin(pp * 3 + k) * 2; G.fr = (Math.floor(pp * 22) + k) & 1; });
  PFA.motion('m02-hoverdart', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; if (w < .6) G.up += Math.sin(w * 30) * 1; else G.t += (w - .6) / .4 * 8; G.fr = (Math.floor(pp * 24) + k) & 1; });
  PFA.motion('m02-spin', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 12) + k) & 3; });
  PFA.motion('m02-pendulum', function (G, pp, k, ph) { G.t += Math.sin(pp * 6 + k * .9) * 4; G.up -= 4 + 3 * Math.sin(pp * 3 + k); G.fr = (Math.floor(pp * 7) + k) & 1; });
  PFA.motion('m02-jostle', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6) + k) % 3; G.t += ((Math.floor(pp * 6) + k) & 1) ? .5 : -.5; });
  PFA.motion('m02-glide', function (G, pp, k, ph) { G.t += Math.sin(pp * 3 + k) * 2; G.up += Math.sin(pp * 5 + k) * 2; G.fr = (Math.floor(pp * 6) + k) % 3; });

  /* ---------- custom chain effects (outer loop only, from piece o to the next) ---------- */
  function carArmy(c, e, H) {   /* endless file: a dotted line keeps pouring from the start, a dozen ants march ahead of it */
    var Q = H.Q, k, u;
    for (u = 0; u < e.hh - .35; u += .04) { e.P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5, ((u * 25) | 0) & 1 ? e.col : e.acc); }
    for (k = 0; k < 9; k++) { u = e.hh - k * .04; if (u < 0) break; e.P.atq(e.a + e.d * u);
      H.glyph(c, 'm02-army', Q.x + Q.nx * 5, Q.y + Q.ny * 5 - ((e.fr + k) & 1), e.z > 1 ? 1 : e.z, (e.fr + k) & 1, e.col, e.acc, e.hi, (e.d < 0 ? Q.ny : -Q.ny), (e.d < 0 ? -Q.nx : Q.nx), Q.nx, Q.ny); }
  }
  function carLuna(c, e, H) {   /* slow glide: the moth sails on, its two long tails stream behind in a waving ribbon */
    var Q = H.Q, k, u, w, X = 0, Y = 0;
    for (k = 6; k >= 1; k--) { u = e.hh - k * .03; if (u < 0) continue; e.P.atq(e.a + e.d * u); w = Math.sin(e.p * 18 - k * .9) * 2;
      H.px(c, Q.x + Q.nx * (6 + w), Q.y + Q.ny * (6 + w) + 3, k < 4 ? e.col : e.hi); H.px(c, Q.x + Q.nx * (6 - w), Q.y + Q.ny * (6 - w) + 5, k < 4 ? e.col : e.hi); }
    e.P.atq(e.a + e.d * e.hh); X = Q.x + Q.nx * 6; Y = Q.y + Q.ny * 6 + Math.sin(e.p * 10) * 2;
    H.glyph(c, 'm02-luna', X, Y, e.z, Math.floor(e.p * 9) % 3, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }

  /* ---------- motifs ---------- */
  PFA.motif('termite-soldier', plain, { nm: 'soldier termites', desc: 'pale soft-bodied termites with big brown heads drumming outward, dark jaws pinching, dust kicked up',
    fam: 'bite', gap: 12, g: 'm02-termite', mo: 'm02-headbang', x: 'dust', car: 'tunnel' });
  PFA.motif('clay-spire', plain, { nm: 'clay spires', desc: 'stepped clay mound spires built one by one along the edge, a dark vent on top, crumbs at the base',
    fam: 'shield', gap: 11, g: 'm02-spire', mo: 'build', x: '-', car: 'train' });
  PFA.motif('leaf-carry', plain, { nm: 'leaf bearers', desc: 'rust ants marching under raised green leaf pieces that sway like parasols',
    fam: 'leaf', gap: 13, g: 'm02-leafant', mo: 'm02-parade', x: '-', car: 'train' });
  PFA.motif('leaf-snip', function (c, e, H) { comp(c, e, H, decoLeafBits); }, { nm: 'leaf snips', desc: 'half-cut leaf crescents with scissor jaws working at the cut, cut bits fluttering down',
    fam: 'slash', gap: 12, g: 'm02-snip', mo: 'snap', x: '-', car: 'comet' });
  PFA.motif('army-flood', plain, { nm: 'army ant flood', desc: 'dark-red ants with huge pale sickle jaws pouring fast along the edge; the chain is an endless file',
    fam: 'bite', gap: 9, g: 'm02-army', mo: 'm02-flood', x: '-', car: 'custom', carDraw: carArmy });
  PFA.motif('jaw-wall', plain, { nm: 'living wall', desc: 'a bivouac lattice of crossed ant bodies hooked together, jaw tips flashing at the corners, click marks',
    fam: 'shield', gap: 10, g: 'm02-lattice', mo: 'pulse', x: 'click', car: 'train' });
  PFA.motif('dangle-wasp', plain, { nm: 'dangling wasps', desc: 'slim amber paper wasps hovering with their long legs hanging down, yellow feet swinging',
    fam: 'buzz', gap: 14, g: 'm02-dangler', mo: 'm02-dangle', x: '-', car: 'flutter' });
  PFA.motif('paper-cell', plain, { nm: 'paper cells', desc: 'open grey paper comb cells with an egg in each, built one by one, chewed fibre streaks',
    fam: 'shield', gap: 9, g: 'm02-papercell', mo: 'build', x: '-', car: 'blink' });
  PFA.motif('hornet-guard', plain, { nm: 'hornet sentries', desc: 'head-on orange hornets with big dark eyes and banded bodies pacing and turning on guard',
    fam: 'thrust', gap: 13, g: 'm02-hornet', mo: 'm02-sentry', x: '-', car: 'zig' });
  PFA.motif('nest-door', plain, { nm: 'nest envelope', desc: 'scalloped paper bands of a hornet nest with a round dark door, chewed wood fibre falling',
    fam: 'shield', gap: 11, g: 'm02-envelope', mo: 'sway', x: 'sawdust', car: 'trail' });
  PFA.motif('mud-pipe', function (c, e, H) { comp(c, e, H, decoMudDrip); }, { nm: 'mud pipes', desc: 'organ-pipe mud tubes growing ring by ring with dark mouths, wet mud beads sliding down',
    fam: 'bash', gap: 8, g: 'm02-pipe', mo: 'm02-stack', x: '-', car: 'hop' });
  PFA.motif('mud-wasp', plain, { nm: 'mud-ball wasps', desc: 'slim black thread-waisted wasps hauling mud balls in low heavy flight',
    fam: 'thrust', gap: 13, g: 'm02-mudwasp', mo: 'm02-haul', x: '-', car: 'comet' });
  PFA.motif('bore-bee', function (c, e, H) { comp(c, e, H, decoGloss); }, { nm: 'glossy bees', desc: 'round glossy blue-black bees hovering then darting, a white gloss streak running the edge',
    fam: 'buzz', gap: 14, g: 'm02-borebee', mo: 'm02-hoverdart', x: 'sheen', car: 'loop' });
  PFA.motif('drill-hole', plain, { nm: 'bore holes', desc: 'perfectly round bore holes with a wood rim and dark core, sawdust chips spinning out and falling',
    fam: 'thrust', gap: 12, g: 'm02-bore', mo: 'm02-spin', x: 'sawdust', car: 'roll' });
  PFA.motif('lamp-queen', function (c, e, H) { comp(c, e, H, decoGlowPool); }, { nm: 'queen lamps', desc: 'big glowing lamps with breathing halos swinging on long threads, a dotted pool of light below',
    fam: 'sparkle', gap: 16, g: 'm02-lamp', mo: 'm02-pendulum', x: 'threads', car: 'thread' });
  PFA.motif('silk-curtain', plain, { nm: 'silk curtain', desc: 'a curtain of long hanging silk threads with glowing beads sliding down them, swaying',
    fam: 'web', gap: 6, g: 'm02-curtain', mo: 'sway', x: '-', car: 'thread' });
  PFA.motif('egg-brood', function (c, e, H) { comp(c, e, H, decoEggShine); }, { nm: 'egg clutch', desc: 'pale oval egg clutches jostled and turned, licked-clean shines blinking',
    fam: 'mend', gap: 13, g: 'm02-eggs', mo: 'm02-jostle', x: '-', car: 'roll' });
  PFA.motif('luna-tail', function (c, e, H) { comp(c, e, H, decoTailWake); }, { nm: 'luna moths', desc: 'big pale green moths with purple leading edges, eyespots and long swaying tails, a scale wake behind; the chain is a slow tail-streaming glide',
    fam: 'leaf', gap: 18, g: 'm02-luna', mo: 'm02-glide', x: '-', car: 'custom', carDraw: carLuna });
  PFA.motif('moon-veil', plain, { nm: 'moon crescents', desc: 'pale moon crescents drifting with glinting tips in a thin haze band',
    fam: 'sparkle', gap: 14, g: 'm02-crescent', mo: 'drift', x: 'haze', car: 'blink' });
})();
