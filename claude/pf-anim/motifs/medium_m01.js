/* Motif module, medium batch m01 (orb-spider, fishing-spider, golden-orb-weaver, dune-scorpion, whip-scorpion, giant-centipede, cave-centipede,
   giant-millipede, scarab-roller, bombardier-beetle, ember-beetle, frost-beetle, lava-beetle). TEMPLATE.md section 10.3.
   14 motifs, each with its own pixel glyph (ids prefixed m01-) and motion; five have their own chain effect (carDraw).
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation inside the frame loops (scratch H.Q / H.G,
   static tables built once at load). Glyphs go through H.glyph so the MAXG budget counts them; per-run decorations are capped at a few dozen pixels.
   The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy default are untouched (they live in the page). */
(function () {
  var CRK = [0, 1, 0, -1, -1, 0, 1, 1];          /* magma crack zigzag (normal offsets along the plate), built once */
  var BLUE = '#5a7ac8';                         /* bombardier: the blue sheen on the black shell (art line: shiny blue-black) */

  /* ---------- shared own-edge composition: the page's themedOwn() with this module's glyph / motion, plus optional per-glyph and per-run extras ---------- */
  function comp(c, e, H, per, deco) {
    var runs = e.runs, mp = e.mp, M = e.M, z = e.z, p = e.p, pp = p * mp.spd, Q = H.Q, G = H.G, P = e.P,
      tie = mp.x === 'thread' || mp.lay === 'snare', ri, k, r, len, n, f, ph, sf, bx0, by0, nx, ny, x, y, lx = 0, ly = 0, has, fr;
    for (ri = 0; ri < runs.length; ri++) {
      r = runs[ri]; len = r[1] - r[0]; n = Math.max(1, Math.min(7, Math.round(len / (M.gap || 12)))); if (mp.lay === 'lance') n = Math.min(n, 4); has = false;
      for (k = 0; k < n; k++) {
        f = (k + .5) / n; ph = H.hash(e.seed * 13 + k * 7 + ri * 31);
        H.lay(mp.lay, p, f, ph, k); H.mot(M.mo, pp, k, ph);
        if (G.vis <= 0 || !H.stip(G.vis, k + ri * 9, p)) { has = false; continue; }
        sf = G.s - Math.floor(G.s); P.atq(r[0] + len * sf); bx0 = Q.x; by0 = Q.y; nx = Q.nx; ny = Q.ny; fr = G.fr;
        x = bx0 + nx * G.d - ny * G.t; y = by0 + ny * G.d + nx * G.t - G.up;
        if (mp.x === 'threads') H.ln(c, bx0 + nx, by0 + ny, x, y, 1, e.hi);
        else if (mp.x === 'silk') H.ln(c, bx0 + ny * 9 + nx, by0 - nx * 9 + ny, x, y, 1, e.hi);
        if (tie && has && Math.abs(x - lx) + Math.abs(y - ly) < 30) H.ln(c, lx, ly, x, y, 1, e.hi);
        if (per) per(c, e, H, x, y, -ny, nx, nx, ny, fr, k);
        H.glyph(c, M.g, x, y, z, fr, e.col, e.acc, e.hi, -ny, nx, nx, ny); lx = x; ly = y; has = true;
      }
      H.ext(c, mp.x, P, r[0], len, ri, p, pp, e.col, e.acc, e.hi, e.seed);
      if (deco) deco(c, e, H, r[0], len, ri, pp);
    }
  }
  function plain(c, e, H) { comp(c, e, H, null, null); }

  /* ---------- per-glyph / per-run extras (few pixels each) ---------- */
  function perSandKick(c, e, H, x, y, tx, ty, nx, ny, fr) {          /* sting-arc: a grain or two of sand kicks off when the tail strikes */
    if (fr === 2) { H.px(c, x - nx * 2 + tx * 3, y - ny * 2 + ty * 3 - 1, e.acc); H.px(c, x - nx * 2 - tx * 3, y - ny * 2 - ty * 3 - 1, e.acc); }
  }
  function perSkid(c, e, H, x, y, tx, ty, nx, ny, fr, k) {             /* rime-shell: a short white skid streak behind each skating shell */
    var i; for (i = 0; i < 4; i++) if (((i + fr + k) & 3) !== 3) H.px(c, x - tx * (4 + i) - nx, y - ty * (4 + i) - ny, i < 2 ? e.hi : e.col);
  }
  function decoGoldStrands(c, e, H, s0, len, ri, pp) {                /* gold-silk: two golden strands are laid along the edge, a white glint runs down them */
    var s, u = H.eo(Math.min(1, e.p * 1.6)), Q = H.Q, g;
    for (s = 0; s < len * u; s += 2) { if (e.p > .85 && H.hash(s + Math.floor(e.p * 40)) > (1 - e.p) / .15) continue;
      e.P.atq(s0 + s); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.col); if ((s & 2) === 0) H.px(c, Q.x + Q.nx * 8, Q.y + Q.ny * 8, ((s / 2) | 0) % 5 === 0 ? e.hi : e.col); }
    if (e.p < .85) { g = ((pp * .9 + ri * .3) % 1) * len * u; e.P.atq(s0 + g); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, H.WHITE); H.px(c, Q.x + Q.nx * 8, Q.y + Q.ny * 8, H.WHITE); }
  }
  function decoMagmaSeam(c, e, H, s0, len, ri, pp) {                  /* magma-crack: a glowing zigzag crack opens along the piece's own edge */
    var s, u = H.eo(Math.min(1, e.p * 1.4)), Q = H.Q, o;
    if (e.p > .9) return;
    for (s = 0; s < len * u; s += 2) { o = CRK[((s / 2) | 0) & 7]; e.P.atq(s0 + s); H.px(c, Q.x + Q.nx * (2 + o), Q.y + Q.ny * (2 + o), (s + Math.floor(pp * 20)) % 14 < 2 ? e.hi : e.col); }
  }
  function decoRimeCreep(c, e, H, s0, len, ri, pp) {                  /* rime-shell: frost needles creep along the edge and sparkle */
    var k, Q = H.Q, n = Math.min(6, Math.floor(len / 8)), g = Math.min(1, e.p * 1.8), L;
    if (e.p > .92) return;
    for (k = 0; k < n; k++) { if ((k + .5) / n > g) break; e.P.atq(s0 + len * (k + .5) / n); L = 1 + ((k + Math.floor(pp * 6)) & 1);
      H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, H.WHITE); H.px(c, Q.x + Q.nx * (2 + L), Q.y + Q.ny * (2 + L), e.hi); }
  }

  /* ---------- glyphs (pixel sprites at the demo resolution; tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step) ---------- */
  PFA.glyph('m01-orb', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* orb web wheel: 6 spokes, a dewy capture ring, the round spider at the hub */
    var R = 4 + z, a0 = fr * .26, s, j, ca, sa;
    for (s = 0; s < 6; s++) { ca = Math.cos(a0 + s * 1.047); sa = Math.sin(a0 + s * 1.047); for (j = 2; j <= R; j++) K.px(c, x + ca * j, y + sa * j, Hi); }
    for (s = 0; s < 6; s++) { ca = Math.cos(a0 + s * 1.047 + .52); sa = Math.sin(a0 + s * 1.047 + .52); K.px(c, x + ca * (R - 1), y + sa * (R - 1), (s & 1) ? K.DEW : Hi); }
    K.sq(c, x, y, 3, C); K.px(c, x - nx * 2, y - ny * 2, A); K.px(c, x - 1, y - 1, K.WHITE);
  });
  PFA.glyph('m01-bundle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* silk-wrapped catch: a white spindle with the prey showing through the wraps */
    var L = 3 + (z >> 1), i, a, o = fr ? 1 : 0;
    for (i = -L; i <= L; i++) { a = Math.abs(i); K.sq(c, x + tx * i, y + ty * i, a === L ? 1 : a >= L - 1 ? 2 : 3, Hi); }
    for (i = -L + 1; i < L; i += 2) K.px(c, x + tx * (i + o) + nx, y + ty * (i + o) + ny, C);
    K.px(c, x - tx * (L + 1), y - ty * (L + 1), A); K.px(c, x + tx * (L + 1), y + ty * (L + 1), A);
  });
  PFA.glyph('m01-fisher', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* fishing spider on the water film: banded legs splayed, a dimple under each foot */
    var L = 5 + z, s, j, ex, ey, dx, dy;
    for (s = 0; s < 4; s++) { dx = (s & 1) ? 1 : -1; dy = (s & 2) ? 1 : -1; ex = tx * dx * .85 + nx * dy * .55; ey = ty * dx * .85 + ny * dy * .55;
      for (j = 2; j <= L; j++) K.px(c, x + ex * j, y + ey * j, (j & 1) ? C : A);
      if (fr) K.ringpx(c, x + ex * (L + 1), y + ey * (L + 1), 1, Hi); else K.px(c, x + ex * (L + 1), y + ey * (L + 1), Hi); }
    K.sq(c, x, y, 3, C); K.px(c, x + tx, y + ty, A); K.px(c, x - nx, y - ny, Hi);
  });
  PFA.glyph('m01-neph', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* golden orb weaver: long gold abdomen, dark head, four very long jointed legs */
    var i, o = fr ? 1 : 0, L = 6 + z, fw, sd, ex, ey;
    for (i = -2; i <= 1; i++) K.sq(c, x + tx * i, y + ty * i, 2, C);
    K.sq(c, x + tx * 2.5, y + ty * 2.5, 2, A);
    for (i = 0; i < 4; i++) { fw = i < 2 ? 1 : -1; sd = (i & 1) ? 1 : -1;
      ex = x + tx * fw * L + nx * sd * (3 + o); ey = y + ty * fw * L + ny * sd * (3 + o);
      K.ln(c, x + tx * (fw > 0 ? 2 : -1), y + ty * (fw > 0 ? 2 : -1), ex, ey, 1, A);
      K.px(c, (x + ex) / 2 + tx * fw, (y + ey) / 2 + ty * fw, Hi); K.px(c, ex, ey, C); }
    K.px(c, x - tx, y - ty, Hi);
  });
  PFA.glyph('m01-tail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* scorpion tail: 4 segments curling over, bulb + hooked stinger; curl opens as it strikes */
    var cu = fr === 0 ? 1.05 : fr === 1 ? .7 : .3, a = 0, i, dx, dy, X = x, Y = y, st = 2 + (z >> 1) * .5;
    K.sq(c, x - nx, y - ny, 3, A); K.px(c, x - nx * 2 + tx * 3, y - ny * 2 + ty * 3, C); K.px(c, x - nx * 2 - tx * 3, y - ny * 2 - ty * 3, C);
    for (i = 0; i < 4; i++) { dx = Math.cos(a) * nx + Math.sin(a) * tx; dy = Math.cos(a) * ny + Math.sin(a) * ty; X += dx * st; Y += dy * st; K.sq(c, X, Y, 2, C); a += cu * .55; }
    dx = Math.cos(a) * nx + Math.sin(a) * tx; dy = Math.cos(a) * ny + Math.sin(a) * ty;
    K.sq(c, X + dx * 2, Y + dy * 2, 2, Hi); a += 1.2; K.px(c, X + dx * 3 + (Math.cos(a) * nx + Math.sin(a) * tx), Y + dy * 3 + (Math.cos(a) * ny + Math.sin(a) * ty), A);
  });
  PFA.glyph('m01-whip', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* vinegaroon: slim body, two feeler arms, a long thin whip tail that lifts, waves and cracks */
    var L = 8 + 2 * z, bend = fr * .35, amp = .6 + fr * .6, j, wx = x, wy = y, o;
    K.sq(c, x, y, 3, C); K.px(c, x, y, A); K.px(c, x + tx * 2, y + ty * 2, C);
    K.px(c, x + tx * 3 + nx, y + ty * 3 + ny, A); K.px(c, x + tx * 3 - nx, y + ty * 3 - ny, A); K.px(c, x + tx * 4 + nx * 2, y + ty * 4 + ny * 2, C);
    for (j = 1; j <= L; j++) { o = j * bend + Math.sin(j * .8 + fr * 1.3) * amp * .7; wx = x - tx * (1 + j * (1 - bend * .45)) + nx * o; wy = y - ty * (1 + j * (1 - bend * .45)) + ny * o; K.px(c, wx, wy, j === L ? Hi : C); }
    if (fr === 3) { K.px(c, wx + 1, wy - 1, Hi); K.px(c, wx - 1, wy + 1, Hi); K.px(c, wx + 1, wy + 1, Hi); K.px(c, wx - 1, wy - 1, Hi); }
    if (fr >= 2) for (j = 1; j <= 3; j++) K.px(c, x - tx * 2 + nx * (1 + j * 2), y - ty * 2 + ny * (1 + j * 2) - j, Hi);   /* vinegar mist puffs off the tail base */
  });
  PFA.glyph('m01-centi', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* scolopendra: 6 segments in an S-wave, a pair of legs per segment, forcipule fangs */
    var i, w, sx, sy, o, fo = (fr & 2) ? 2 : 1;
    for (i = 5; i >= 0; i--) { w = Math.sin(i * 1.1 - fr * 1.57) * 1.4; sx = x - tx * i * 2.2 + nx * w; sy = y - ty * i * 2.2 + ny * w;
      K.sq(c, sx, sy, i === 0 ? 3 + (z >> 1) : 2 + (z >> 1), C); o = ((i + fr) & 1) ? 3 : 2;
      K.px(c, sx + nx * o - tx * (o - 2), sy + ny * o - ty * (o - 2), Hi); K.px(c, sx - nx * o - tx * (o - 2), sy - ny * o - ty * (o - 2), Hi); }
    K.px(c, x + tx * 2 + nx * fo, y + ty * 2 + ny * fo, Hi); K.px(c, x + tx * 2 - nx * fo, y + ty * 2 - ny * fo, Hi); K.px(c, x, y, A);
  });
  PFA.glyph('m01-stalac', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* stalactite: a banded stone tooth pointing out, a drip forming and falling at its tip */
    var L = 5 + z, j, i, w, d;
    for (j = 0; j < L; j++) { w = Math.max(0, Math.round((L - j) * 2.2 / L) - 1); for (i = -w; i <= w; i++) K.px(c, x + nx * j + tx * i, y + ny * j + ty * i, j % 3 === 1 ? A : C); }
    d = L + fr * 2; if (fr < 3) K.sq(c, x + nx * d, y + ny * d, 2, Hi); else { K.px(c, x + nx * d + tx * 2, y + ny * d + ty * 2, Hi); K.px(c, x + nx * d - tx * 2, y + ny * d - ty * 2, Hi); }
    K.px(c, x + nx * (L - 1), y + ny * (L - 1), Hi);
  });
  PFA.glyph('m01-milli', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* giant millipede: glossy black coil fringed with red legs; it unrolls as fr rises */
    var j, a, r, st = .95 - fr * .2, gr = .5 + fr * .35, sx, sy, dx, dy, s2 = 2 + (z > 1 ? 1 : 0);
    for (j = 0; j < 8; j++) { a = j * st; r = 1 + j * gr; dx = tx * Math.cos(a) + nx * Math.sin(a); dy = ty * Math.cos(a) + ny * Math.sin(a);
      sx = x + dx * r; sy = y + dy * r; K.px(c, sx + dx * 1.8, sy + dy * 1.8, C); K.px(c, sx + dx * 1.8 - dy, sy + dy * 1.8 + dx, C);
      K.sq(c, sx, sy, s2, A); if (j % 3 === 1) K.px(c, sx, sy, Hi); }
    K.px(c, x, y, C);
  });
  PFA.glyph('m01-sun', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* sacred scarab: a rayed sun ball with a turning highlight, the gold-green beetle pushing behind */
    var o = 2 + (z > 1 ? 1 : 0), i, a, bxp = x - tx * (o + 3), byp = y - ty * (o + 3);
    K.bx(c, x - o + 1, y - o, 2 * o - 1, 1, Hi); K.bx(c, x - o, y - o + 1, 2 * o + 1, 2 * o - 1, Hi); K.bx(c, x - o + 1, y + o, 2 * o - 1, 1, A);
    for (i = 0; i < 4; i++) { a = i * 1.5708 + fr * .39; K.px(c, x + Math.cos(a) * (o + 2), y + Math.sin(a) * (o + 2), Hi); }
    K.px(c, x + (fr === 1 || fr === 2 ? 1 : -1), y + (fr >= 2 ? 1 : -1), K.WHITE);
    K.sq(c, bxp, byp, 3, C); K.px(c, bxp + tx * 2, byp + ty * 2, A); K.px(c, bxp + nx * 2, byp + ny * 2, A); K.px(c, bxp - nx * 2, byp - ny * 2, A); K.px(c, bxp - tx, byp - ty, Hi);
  });
  PFA.glyph('m01-bomb', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* bombardier: orange head, blue-black shell, the tail turret fires a boiling steam jet */
    var j, Tx = x - tx * 3, Ty = y - ty * 3, n = fr * 2;
    K.sq(c, x, y, 3, A); K.sq(c, x - tx * 2, y - ty * 2, 3, A); K.sq(c, x + tx * 2, y + ty * 2, 2 + (z >> 1), C); K.px(c, x - tx, y - ty - 1, BLUE); K.px(c, x + tx, y + ty - 1, BLUE);
    K.px(c, x + nx * 2, y + ny * 2, A); K.px(c, x - nx * 2, y - ny * 2, A);
    for (j = 1; j <= n; j++) K.sq(c, Tx + nx * (1 + j * 2.2) + tx * (j & 1), Ty + ny * (1 + j * 2.2) + ty * (j & 1), j < 3 ? 2 : 3, j === n ? K.WHITE : Hi);
    if (fr === 1) K.plus(c, Tx + nx * 2, Ty + ny * 2, 2, 1, K.WHITE);
  });
  PFA.glyph('m01-coal', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* ember beetle: a live coal of a body, a hot spot flickering, a spark lifting off */
    var i, s = (fr & 1) ? 1 : -1;
    for (i = -1; i <= 1; i++) K.sq(c, x + tx * i * 1.5, y + ty * i * 1.5, 3 + (z >> 1), C);
    K.px(c, x + tx * s, y + ty * s, Hi); if (fr === 2) K.px(c, x, y, K.WHITE); K.px(c, x - tx * 3, y - ty * 3, A); K.px(c, x + tx * 3, y + ty * 3, A);
    K.px(c, x + nx * 2 + tx * 2, y + ny * 2 + ty * 2, A); K.px(c, x - nx * 2 - tx * 2, y - ny * 2 - ty * 2, A);
    K.px(c, x + nx * (3 + fr) + tx * (fr - 1), y + ny * (3 + fr) + ty * (fr - 1) - fr, Hi);
  });
  PFA.glyph('m01-rime', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* frost beetle: pale blue dome, white glint sliding over it, rime needles on its back */
    var i, j, w;
    for (j = 0; j <= 2; j++) { w = j < 2 ? 2 + (z >> 1) : 1; for (i = -w; i <= w; i++) K.px(c, x + tx * i + nx * j, y + ty * i + ny * j, C); }
    K.px(c, x, y, A); K.px(c, x + nx, y + ny, A); K.px(c, x + tx * (fr - 1.5) + nx * 2, y + ty * (fr - 1.5) + ny * 2, K.WHITE);
    for (i = -2; i <= 2; i += 2) { w = 1 + ((fr + i + 2) & 1); for (j = 1; j <= w; j++) K.px(c, x + tx * i + nx * (2 + j), y + ty * i + ny * (2 + j), Hi); }
    K.px(c, x + tx * 3 - nx, y + ty * 3 - ny, A); K.px(c, x - tx * 3 - nx, y - ty * 3 - ny, A);
  });
  PFA.glyph('m01-magma', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* lava beetle: a black plate split by a red crack that widens, a magma bead oozing out */
    var W = 3 + (z > 0 ? 1 : 0), i, o, hz = Math.abs(tx) >= Math.abs(ty);
    if (hz) K.bx(c, x - W, y - 2, 2 * W + 1, 5, A); else K.bx(c, x - 2, y - W, 5, 2 * W + 1, A);
    for (i = -W; i <= W; i++) { o = CRK[(i + W) & 7] * .9; K.px(c, x + tx * i + nx * o, y + ty * i + ny * o, C); if (fr >= 2 && Math.abs(i) < 2) K.px(c, x + tx * i + nx * (o + 1), y + ty * i + ny * (o + 1), Hi); }
    if (fr === 3) K.sq(c, x + nx * 4, y + ny * 4, 2, Hi); K.px(c, x - tx * W + nx * 2, y - ty * W + ny * 2, C);
  });

  /* ---------- motions (mutate the scratch G; pp = time x speed) ---------- */
  PFA.motion('m01-spin', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 8) + k) & 3; G.up += Math.sin(pp * 5 + k); });                        /* wheels turn 15 degrees a step, a slow bob */
  PFA.motion('m01-twirl', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 1; G.t += Math.sin(pp * 7 + k) * 1.5; });                      /* hung bundle twirls on its thread */
  PFA.motion('m01-skate', function (G, pp, k, ph) { var q = pp * 2.5 + ph, st = Math.floor(q), f = q - st; G.s += (st + Math.min(1, f * 3)) * .05; G.fr = f > .33 ? 1 : 0; });   /* dart, rest, dart */
  PFA.motion('m01-reach', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 1; G.s += pp * .12; G.up += G.fr * .5; });                      /* slow long-legged reach */
  PFA.motion('m01-rear', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .5 ? 0 : u < .7 ? 1 : 2; if (G.fr === 2) G.d += 2; });  /* tail cocks, then strikes */
  PFA.motion('m01-lash', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 2.2 + ph) % 1) * 4.5)); });                             /* whip lifts in 3 steps and cracks */
  PFA.motion('m01-undulate', function (G, pp, k) { G.fr = (Math.floor(pp * 14) + k) & 3; G.s += pp * .2; });                                     /* body wave travels, crawls on */
  PFA.motion('m01-drip', function (G, pp, k, ph) { G.fr = Math.floor(pp * 6 + ph * 4) & 3; });                                                     /* a drip forms, falls, splashes */
  PFA.motion('m01-unroll', function (G, pp) { G.fr = Math.min(3, Math.floor(Math.sin(Math.PI * Math.min(1, pp * 1.1)) * 4)); });                  /* coil opens then closes again */
  PFA.motion('m01-fire', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; G.fr = u < .35 ? 0 : u < .55 ? 1 : u < .8 ? 2 : 3; });              /* aim, pop, jet, full jet */
  PFA.motion('m01-flicker', function (G, pp, k, ph) { G.fr = Math.floor(pp * 12 + ph * 7) & 3; G.t += Math.sin(pp * 20 + k) * .8; });            /* coal glow flickers, tiny scurry */
  PFA.motion('m01-skid', function (G, pp, k) { G.s += pp * .3; G.fr = (Math.floor(pp * 8) + k) & 3; G.t += Math.sin(pp * 6 + k) * .8; });       /* skates on, glint slides */
  PFA.motion('m01-crackle', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.5 + ph) % 1) * 4.5)); });                           /* crack widens, bead oozes, closes */

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ---------- */
  function carGold(c, e, H) {           /* two gold strands spun out to the next piece, a glint running down them, the weaver at the front */
    var P = e.P, Q = H.Q, u;
    for (u = 0; u <= e.hh; u += .02) { P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.col); H.px(c, Q.x + Q.nx * 7, Q.y + Q.ny * 7, ((u * 50) | 0) % 4 === 0 ? e.hi : e.col); }
    P.atq(e.a + e.d * e.hh * ((e.p * 3) % 1)); H.plus(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5, 1, 1, H.WHITE);
    H.carHead(c, P, e.a + e.d * e.hh, 'm01-neph', e.z, e.fr, 0, 0, e.col, e.acc, e.hi);
  }
  function carSun(c, e, H) {            /* the sun ball rolls over, leaving a dotted gold track and dust */
    var P = e.P, Q = H.Q, k, u;
    for (k = 1; k <= 6; k++) { u = e.hh - k * .04; if (u < 0) break; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, k & 1 ? e.hi : e.acc); if (k < 3) H.px(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4 + k, e.acc); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm01-sun', e.z, Math.floor(e.p * 16) & 3, 0, 0, e.col, e.acc, e.hi);
  }
  function carSteam(c, e, H) {          /* a boiling steam jet blasts along the edge; a white pop where it lands */
    var P = e.P, Q = H.Q, k, u;
    for (k = 0; k < 7; k++) { u = e.hh - k * .05; if (u < 0) break; P.atq(e.a + e.d * u); H.sq(c, Q.x + Q.nx * (4 + (k & 1)), Q.y + Q.ny * (4 + (k & 1)) - k * .5, k < 2 ? 3 : 2, k < 3 ? H.WHITE : e.hi); }
    if (e.p > .8) { P.atq(e.a + e.d); H.plus(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5, 3, 1, H.WHITE); }
    H.carHead(c, P, e.a, 'm01-bomb', e.z, 2, 0, 0, e.col, e.acc, e.hi);
  }
  function carSkid(c, e, H) {           /* a white skid line scored along the edge, frost crystals popping up on it, the shell at the front */
    var P = e.P, Q = H.Q, u, k;
    for (u = 0; u <= e.hh; u += .025) { P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.hi); }
    for (k = 1; k <= 4; k++) if (e.hh > k / 5) { P.atq(e.a + e.d * k / 5); H.plus(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5, e.hh - k / 5 < .1 ? 2 : 1, 1, k & 1 ? H.WHITE : e.col); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm01-rime', e.z, Math.floor(e.p * 16) & 3, 0, 0, e.col, e.acc, e.hi);
  }
  function carCrack(c, e, H) {          /* a glowing crack runs along the outer edge to the next piece, hottest near its head */
    var P = e.P, Q = H.Q, u, o, i = 0;
    for (u = 0; u <= e.hh; u += .02) { o = CRK[i++ & 7]; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * (3 + o), Q.y + Q.ny * (3 + o), e.hh - u < .12 ? e.hi : e.col); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm01-magma', e.z, 2 + (e.fr & 1), 0, 0, e.col, e.acc, e.hi);
  }

  /* ---------- motifs ---------- */
  PFA.motif('orb-wheel', plain, { nm: 'orb wheels', desc: 'small spoked orb webs with a dewy capture ring, the round spider at the hub; the wheels turn and bob', fam: 'web', gap: 16, g: 'm01-orb', mo: 'm01-spin', x: '-', car: 'thread' });
  PFA.motif('silk-bundle', plain, { nm: 'silk bundles', desc: 'white spindle-shaped silk-wrapped catches twirling on their threads, prey showing through the wraps', fam: 'web', gap: 14, g: 'm01-bundle', mo: 'm01-twirl', x: '-', car: 'loop' });
  PFA.motif('water-walker', plain, { nm: 'water walkers', desc: 'a banded long-legged spider standing on the water film, darting and resting, a dimple ring under each foot', fam: 'ripple', gap: 18, g: 'm01-fisher', mo: 'm01-skate', x: '-', car: 'rings' });
  PFA.motif('gold-silk', function (c, e, H) { comp(c, e, H, null, decoGoldStrands); }, { nm: 'gold silk', desc: 'two golden strands laid along the edge with a glint running down them, a huge long-legged weaver stepping on them', fam: 'web', gap: 18, g: 'm01-neph', mo: 'm01-reach', x: '-', car: 'custom', carDraw: carGold });
  PFA.motif('sting-arc', function (c, e, H) { comp(c, e, H, perSandKick, null); }, { nm: 'scorpion tails', desc: 'segmented tails curled over in a question mark that open and strike, a pale stinger bulb, sand kicked up', fam: 'drip', gap: 14, g: 'm01-tail', mo: 'm01-rear', x: '-', car: 'tunnel' });
  PFA.motif('vinegar-whip', plain, { nm: 'vinegar whips', desc: 'slim dark bodies with feeler arms and a long thin whip tail that lifts, waves and cracks, vinegar mist puffing', fam: 'slash', gap: 18, g: 'm01-whip', mo: 'm01-lash', x: '-', car: 'comet' });
  PFA.motif('fang-coil', plain, { nm: 'centipede waves', desc: 'long segmented bodies with an S-wave travelling down them, a pair of legs per segment, forcipule fangs opening', fam: 'bite', gap: 18, g: 'm01-centi', mo: 'm01-undulate', x: '-', car: 'train' });
  PFA.motif('stalactite-drip', plain, { nm: 'stalactites', desc: 'banded stone teeth pointing out of the edge, a drip forming at each tip, falling and splashing', fam: 'shield', gap: 10, g: 'm01-stalac', mo: 'm01-drip', x: '-', car: 'comet' });
  PFA.motif('millipede-curl', plain, { nm: 'millipede coils', desc: 'glossy black spiral coils fringed with red legs that unroll into a long arc and roll back up', fam: 'bash', gap: 16, g: 'm01-milli', mo: 'm01-unroll', x: '-', car: 'roll' });
  PFA.motif('sun-ball', plain, { nm: 'sun balls', desc: 'a rayed golden ball with a turning highlight, a gold-green scarab head-down pushing it from behind', fam: 'bash', gap: 18, g: 'm01-sun', mo: 'roll', x: 'dust', car: 'custom', carDraw: carSun });
  PFA.motif('boil-jet', plain, { nm: 'steam cannons', desc: 'orange-headed blue-black beetles swinging the tail turret and firing a boiling white steam jet with a pop', fam: 'puff', gap: 16, g: 'm01-bomb', mo: 'm01-fire', x: '-', car: 'custom', carDraw: carSteam });
  PFA.motif('coal-glow', plain, { nm: 'live coals', desc: 'small beetles glowing like live coals, a hot spot flickering in each, sparks lifting off', fam: 'ember', gap: 12, g: 'm01-coal', mo: 'm01-flicker', x: 'embers', car: 'trail' });
  PFA.motif('rime-shell', function (c, e, H) { comp(c, e, H, perSkid, decoRimeCreep); }, { nm: 'rime shells', desc: 'pale blue domed shells skating on, a glint sliding over them, rime needles on their backs, frost creeping along the edge', fam: 'shield', gap: 14, g: 'm01-rime', mo: 'm01-skid', x: '-', car: 'custom', carDraw: carSkid });
  PFA.motif('magma-crack', function (c, e, H) { comp(c, e, H, null, decoMagmaSeam); }, { nm: 'magma plates', desc: 'black plates split by red cracks that widen and glow yellow, magma beads oozing, a glowing seam along the edge', fam: 'ember', gap: 14, g: 'm01-magma', mo: 'm01-crackle', x: 'haze', car: 'custom', carDraw: carCrack });
})();
