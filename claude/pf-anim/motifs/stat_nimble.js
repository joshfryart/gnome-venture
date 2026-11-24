/* Motif module: the five Nimble tier pieces' own-edge effects and chain effects, written like motifs/stat_pieces.js (engine2).
   Footwork language shared with Sidestep: prints, dust flicks, speed ticks, afterimages. Each piece gets its own glyph, motion and run extra:
   Skitter (Guard, Evade, body): scuffed little prints skittering in quick hops with skid streaks; chain = a print darting in four zigzag hops, dust at each landing.
   Wrong Turn (Trick, Quick, mind): crooked signposts whose boards spin like weathervanes; chevrons run along the edge and take a sudden wrong turn; chain = an arrow that jogs off the path and back.
   Pinning Stance (Guard, Hold, mind): planted boots stamping in turn, push-pins driven into the edge; chain = a taut line pinned down at its head.
   Shadow Step (Guard, Keeper, mind): a dark drop-outline hugging the edge, little hooded shadows rising out of it and sinking back; chain = a shadow puddle sliding, the figure popping up at the end.
   Phantom Footing (Guard, Evade, body): misty pale prints appearing in step and fading, mist curls lifting off; the fire version adds a ghostly hand sliding an aim ring along the edge;
   chain = misty prints walking the path, fading behind.
   Every draw is a stateless function of p (hash noise only); glyphs go through H.glyph (MAXG budget); coordinates (a, b) = along the tangent, out along the normal. */
(function () {
  var WH = '#ffffff', PIN = '#c8402c';

  /* shared own-edge composition (as stat_pieces.js comp): layout x motion per glyph, optional per-glyph and per-run extras */
  function comp(c, e, H, per, deco) {
    var runs = e.runs, mp = e.mp, M = e.M, z = e.z, p = e.p, pp = p * mp.spd, Q = H.Q, G = H.G, P = e.P, ri, k, r, len, n, f, ph, sf, bx0, by0, nx, ny, x, y, fr;
    for (ri = 0; ri < runs.length; ri++) {
      r = runs[ri]; len = r[1] - r[0]; n = Math.max(1, Math.min(8, Math.round(len / (M.gap || 12))));
      for (k = 0; k < n; k++) {
        f = (k + .5) / n; ph = H.hash(e.seed * 13 + k * 7 + ri * 31);
        H.lay(mp.lay, p, f, ph, k); H.mot(M.mo, pp, k, ph);
        if (G.vis <= 0 || !H.stip(G.vis, k + ri * 9, p)) continue;
        sf = G.s - Math.floor(G.s); P.atq(r[0] + len * sf); bx0 = Q.x; by0 = Q.y; nx = Q.nx; ny = Q.ny; fr = G.fr;
        x = bx0 + nx * G.d - ny * G.t; y = by0 + ny * G.d + nx * G.t - G.up;
        if (per) per(c, e, H, x, y, -ny, nx, nx, ny, fr, k, bx0, by0);
        H.glyph(c, M.g, x, y, z, fr, e.col, e.acc, e.hi, -ny, nx, nx, ny);
      }
      if (deco) deco(c, e, H, r[0], len, ri, pp);
    }
  }
  function P2(c, K, x, y, tx, ty, nx, ny, a, b, col) { K.px(c, x + tx * a + nx * b, y + ty * a + ny * b, col); }
  function env(p) { return Math.sin(Math.PI * Math.min(1, Math.max(0, p))); }

  /* ---------- glyphs ---------- */
  PFA.glyph('gv-scuff', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* Skitter: a small scuffed print, a skid streak behind it; bit 0 = skid direction, bit 1 = fresh (bigger, dust) */
    var sd = fr & 1 ? 1 : -1, fresh = !!(fr & 2), a, b;
    for (a = -1; a <= 1; a++) for (b = -1; b <= 1; b++) if (Math.abs(a) + Math.abs(b) < 2 || fresh) P2(c, K, x, y, tx, ty, nx, ny, a, b, C);
    P2(c, K, x, y, tx, ty, nx, ny, 2, -1, C); P2(c, K, x, y, tx, ty, nx, ny, 2, 1, C); P2(c, K, x, y, tx, ty, nx, ny, 0, 0, A);
    for (a = 2; a <= 4 + z; a++) P2(c, K, x, y, tx, ty, nx, ny, -sd * a, a & 1 ? 0 : 1, a > 3 ? Hi : A);   /* the skid */
    if (fresh) { P2(c, K, x, y, tx, ty, nx, ny, sd * 3, 2, Hi); P2(c, K, x, y, tx, ty, nx, ny, sd * 4, -2, Hi); }
  });
  PFA.glyph('gv-sign', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* Wrong Turn: a crooked signpost (upright on screen); bit 0 = board points left, bit 1 = board edge-on mid-spin */
    var i, d = fr & 1 ? -1 : 1, w = 4 + (z > 0 ? 1 : 0);
    K.bx(c, x, y - 2, 1, 6, A); K.px(c, x - 1, y + 3, A); K.px(c, x + 1, y + 3, A);   /* the post, feet splayed */
    if (fr & 2) { K.bx(c, x - 1, y - 5, 3, 3, Hi); K.bx(c, x, y - 5, 1, 3, C); return; }   /* edge-on */
    for (i = 0; i < w; i++) { K.bx(c, x + d * i, y - 5 + (i > 2 ? 1 : 0), 1, 3, C); }   /* the board, drooping (crooked) */
    K.px(c, x + d * w, y - 4 + 1, C); K.px(c, x + d * (w + 1), y - 3 + 0, Hi);           /* the arrow tip */
    K.px(c, x + d, y - 4, Hi);
  });
  PFA.glyph('gv-chev', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a small chevron pointing along the tangent (or out, fr 1) */
    var ax = fr ? nx : tx, ay = fr ? ny : ty, bxn = fr ? tx : nx, byn = fr ? ty : ny;
    K.px(c, x + ax * 1, y + ay * 1, C); K.px(c, x - bxn - ax * 0, y - byn, C); K.px(c, x + bxn, y + byn, C); K.px(c, x - 2 * bxn - ax, y - 2 * byn - ay, Hi); K.px(c, x + 2 * bxn - ax, y + 2 * byn - ay, Hi);
  });
  PFA.glyph('gv-boot', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* Pinning Stance: a planted boot (upright); bit 0 = just stamped (dust both sides) */
    var s = z > 0 ? 1 : 0;
    K.bx(c, x - 1, y - 4 - s, 3, 4 + s, C); K.bx(c, x - 1, y, 5 + s, 2, C); K.bx(c, x - 1, y + 2, 5 + s, 1, A);   /* shaft, foot, sole */
    K.px(c, x, y - 4 - s, Hi); K.px(c, x + 3 + s, y, Hi); K.px(c, x, y + 2, Hi); K.px(c, x + 2, y + 2, Hi);
    if (fr & 1) { K.px(c, x - 3, y + 2, A); K.px(c, x - 4, y + 1, Hi); K.px(c, x + 6 + s, y + 2, A); K.px(c, x + 7 + s, y + 1, Hi); }
  });
  PFA.glyph('gv-pin', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a push-pin pointing in along -normal: red head, silver needle (fr = needle length showing) */
    var L = 1 + (fr & 3), i;
    for (i = 0; i < L; i++) K.px(c, x - nx * i, y - ny * i, Hi);
    K.sq(c, x + nx * 1, y + ny * 1, 3, PIN); K.px(c, x + nx * 1 - 1, y + ny * 1 - 1, WH);
  });
  PFA.glyph('gv-shade', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* Shadow Step: a hooded shadow figure (upright); fr 0 = risen, 1 = half sunk, 2 = only the eyes over a puddle */
    var s = z > 0 ? 1 : 0;
    K.bx(c, x - 3 - s, y + 2, 7 + 2 * s, 1, A);                                       /* puddle */
    if (fr === 2) { K.px(c, x - 1, y + 1, Hi); K.px(c, x + 1, y + 1, Hi); return; }
    var top = fr === 1 ? y - 1 : y - 5 - s;
    K.bx(c, x - 2, top + 1, 5, y + 2 - top - 1, C); K.bx(c, x - 1, top, 3, 1, C);   /* hood and body */
    K.px(c, x - 1, top + 2, Hi); K.px(c, x + 1, top + 2, Hi);                         /* eyes */
    if (fr === 0) { K.px(c, x - 3, y, C); K.px(c, x + 3, y - 1, C); }                 /* ragged hem */
  });
  PFA.glyph('gv-mist', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* Phantom Footing: a misty print; fr 0 solid pale, 1 dotted, 2 a last few pixels; bit 2 = right foot */
    var st = fr & 3, sd = fr & 4 ? 1 : -1, a, b, n = 0;
    for (a = -2; a <= 2; a++) for (b = -1; b <= 1; b++) {
      if ((a === -2 || a === 2) && b !== 0) continue; n++;
      if (st === 1 && (n & 1)) continue; if (st === 2 && n % 4) continue;
      P2(c, K, x, y, tx, ty, nx, ny, a, b * sd + sd, a === 2 ? Hi : C);
    }
    if (st === 0) { P2(c, K, x, y, tx, ty, nx, ny, 3, sd - 1, A); P2(c, K, x, y, tx, ty, nx, ny, 3, sd + 1, A); }   /* toes */
  });
  PFA.glyph('gv-ghand', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a ghostly hand (upright, palm down, fingers to the right), pushing; fr bit 0 = fingers flexed */
    var f = fr & 1;
    K.bx(c, x - 3, y - 1, 5, 4, C); K.bx(c, x - 4, y, 1, 2, A);                       /* palm, wrist edge */
    K.bx(c, x + 2, y - 1, 3 - f, 1, C); K.bx(c, x + 2, y + 1, 4 - f, 1, C); K.bx(c, x + 2, y + 3, 3 - f, 1, C);   /* fingers */
    K.px(c, x - 1, y - 2, C); K.px(c, x - 2, y - 2, Hi); K.px(c, x, y, Hi);
  });

  /* ---------- motions ---------- */
  PFA.motion('gv-scurry', function (G, pp, k, ph) {                                   /* quick hops: each print darts a short way, skids, darts back the other way */
    var q = pp * 4 + ph * 3, st = Math.floor(q), f = q - st, dir = (st + k) & 1;
    G.s += (dir ? 1 : -1) * .05 * Math.min(1, f * 3); G.t += (dir ? 1 : -1) * 2 * Math.min(1, f * 3);
    G.fr = (dir ? 1 : 0) | (f < .3 ? 2 : 0); if (f < .2) G.up += (1 - f / .2) * 2;
  });
  PFA.motion('gv-vane', function (G, pp, k, ph) {                                     /* the boards spin: right, edge-on, left, edge-on, with a little wobble */
    var w = Math.floor(pp * 8 + ph * 4 + k), st = w & 3;
    G.fr = st === 0 ? 0 : st === 2 ? 1 : 2; G.t += Math.sin(pp * 6 + k) * 1;
  });
  PFA.motion('gv-plant', function (G, pp, k, ph) {                                    /* each boot lifts and stamps in turn, then stands planted */
    var q = (pp * 1.6 + k * .27 + ph * .1) % 1;
    if (q < .18) { G.up += Math.sin(q / .18 * Math.PI) * 3; G.fr = 0; } else G.fr = q < .3 ? 1 : 0;
  });
  PFA.motion('gv-sink', function (G, pp, k, ph) {                                     /* rise out of the shadow, look about, sink back */
    var q = (pp * 1.2 + ph) % 1; G.fr = q < .2 ? 2 : q < .3 ? 1 : q < .75 ? 0 : q < .85 ? 1 : 2; G.t += q > .3 && q < .75 ? Math.sin(pp * 8 + k) * 1 : 0; G.d -= 2;
  });
  PFA.motion('gv-wander', function (G, pp, k, ph) {                                   /* prints appear one after another (a walk along the edge) and fade as the next lands */
    var q = (pp * 1.4 - k * .14 + 10) % 1; G.fr = (q < .35 ? 0 : q < .6 ? 1 : q < .8 ? 2 : 3) | ((k & 1) << 2); if ((G.fr & 3) === 3) G.vis = 0; G.up += q * 2; G.d -= 1;
  });

  /* ---------- per-glyph and per-run extras ---------- */
  function perKick(c, e, H, x, y, tx, ty, nx, ny, fr, k) {           /* a dust kick off each fresh scuff */
    if (!(fr & 2)) return; var i, sd = fr & 1 ? 1 : -1; for (i = 0; i < 3; i++) H.px(c, x + tx * sd * (5 + i * 2) + nx * (1 + i), y + ty * sd * (5 + i * 2) + ny * (1 + i) - i, i ? e.hi : e.acc);
  }
  function decoSkid(c, e, H, s0, len, ri, pp) {                      /* skid lines sliding sideways fast, flashing; dust specks thrown out */
    var k, s, j, Q = H.Q, fl = Math.floor(pp * 18), en = env(e.p);
    for (k = 0; k < 3; k++) { if ((fl + k) % 4 === 0) continue; s = s0 + ((H.hash(e.seed + k * 13 + ri) * len + (k & 1 ? 1 : -1) * pp * 90) % len + len) % len;
      for (j = 0; j < 4; j++) { e.P.atq(s - j * (k & 1 ? 1 : -1)); H.px(c, Q.x + Q.nx * (9 + k * 2), Q.y + Q.ny * (9 + k * 2), j < 2 ? e.hi : e.col); } }
    for (k = 0; k < 4; k++) { var u = (pp * 2 + H.hash(e.seed + k * 3 + ri)) % 1; if (!H.stip(en * (1 - u), k + 30, e.p)) continue; e.P.atq(s0 + len * H.hash(e.seed + k * 5 + ri + 1));
      H.px(c, Q.x + Q.nx * (3 + 12 * u), Q.y + Q.ny * (3 + 12 * u) - Math.sin(u * Math.PI) * 3, e.hi); }
  }
  function decoTurn(c, e, H, s0, len, ri, pp) {                      /* chevrons march along the edge; at one point they swerve out (the wrong turn) and come back */
    var k, u, Q = H.Q, kink = H.hash(e.seed + ri * 3) * .6 + .2, d, off;
    for (k = 0; k < 4; k++) { u = (pp * .9 + k * .25) % 1; d = Math.abs(u - kink); off = d < .08 ? (1 - d / .08) * 7 : 0;
      e.P.atq(s0 + len * u); H.glyph(c, 'gv-chev', Q.x + Q.nx * (8 + off), Q.y + Q.ny * (8 + off), 0, off > 3 ? 1 : 0, e.hi, e.acc, e.col, -Q.ny, Q.nx, Q.nx, Q.ny); }
  }
  function decoPins(c, e, H, s0, len, ri, pp) {                      /* push-pins at fixed points, driven in on the fire (needle shrinks as it sinks) */
    var k, n = Math.max(1, Math.round(len / 30)), Q = H.Q, drive = e.z > 0 ? Math.min(1, e.p * 2.2) : .7, d;
    for (k = 0; k < n; k++) { e.P.atq(s0 + len * (k + .5) / n); d = 1 + 6 * (1 - H.eo(drive)); H.glyph(c, 'gv-pin', Q.x + Q.nx * d, Q.y + Q.ny * d, 0, d > 4 ? 3 : d > 2 ? 2 : 1, e.col, e.acc, '#d9dde4', -Q.ny, Q.nx, Q.nx, Q.ny);
      if (e.z > 0 && e.p > .42 && e.p < .6) { H.px(c, Q.x + Q.nx * 4 - Q.ny * 3, Q.y + Q.ny * 4 + Q.nx * 3, WH); H.px(c, Q.x + Q.nx * 4 + Q.ny * 3, Q.y + Q.ny * 4 - Q.nx * 3, WH); } }
  }
  function decoShadow(c, e, H, s0, len, ri, pp) {                    /* a dark drop-outline hugging the edge (offset down-right), dithered at its fringe, drips sliding off */
    var s, Q = H.Q, en = Math.min(1, env(e.p) * 2.5), k, u;
    for (s = 0; s < len; s += 1) { if (!H.stip(en, s, e.p)) continue; e.P.atq(s0 + s); H.px(c, Q.x + Q.nx * 2 + 1, Q.y + Q.ny * 2 + 1, e.acc); if ((s + Math.floor(pp * 6)) % 3 === 0) H.px(c, Q.x + Q.nx * 3 + 1, Q.y + Q.ny * 3 + 1, e.col); }
    for (k = 0; k < 2; k++) { u = (pp * .8 + H.hash(e.seed + k * 7 + ri)) % 1; e.P.atq(s0 + len * H.hash(e.seed + k * 11 + ri)); H.bx(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3 + 8 * u, 1, 2, e.acc); }
  }
  function decoMist(c, e, H, s0, len, ri, pp) {                      /* mist curls lifting off; on the fire a ghostly hand slides an aim ring along the first run */
    var k, u, Q = H.Q, X, Y, j;
    for (k = 0; k < 3; k++) { u = (pp * .7 + H.hash(e.seed + k * 5 + ri)) % 1; e.P.atq(s0 + len * H.hash(e.seed + k * 9 + ri + 4)); X = Q.x + Q.nx * (4 + 8 * u); Y = Q.y + Q.ny * (4 + 8 * u) - 6 * u;
      for (j = 0; j < 5; j++) if (H.hash(j + k * 7 + Math.floor(pp * 10)) < 1 - u * .8) H.px(c, X + j - 2, Y + Math.round(Math.sin(j * 1.3 + pp * 6) * 1), j & 1 ? e.hi : e.col); }
    if (e.z > 0 && ri === 0) {
      u = H.eo(Math.min(1, e.p * 1.3)); e.P.atq(s0 + len * (.15 + .7 * u)); X = Q.x + Q.nx * 9; Y = Q.y + Q.ny * 9;
      if (e.p < .9) { H.ringpx(c, X + 7, Y, 3, PIN); H.px(c, X + 7, Y, PIN); H.glyph(c, 'gv-ghand', X, Y, 0, Math.floor(e.p * 10) & 1, e.col, e.acc, e.hi, 1, 0, 0, -1); }
    }
  }

  /* ---------- custom chain effects (carDraw: along the path from e.a over e.d, eased e.hh) ---------- */
  function carSkitter(c, e, H) {                                     /* a scuff darts along in four zigzag hops, dust where it lands each time */
    var P = e.P, Q = H.Q, k, u, hop = Math.min(3, Math.floor(e.hh * 4)), f = e.hh * 4 - hop;
    for (k = 1; k <= hop; k++) { u = k / 4; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 2 - 2, Q.y + Q.ny * 2, e.hi); H.px(c, Q.x + Q.nx * 2 + 2, Q.y + Q.ny * 2, e.hi); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3 - 1, e.acc); }
    H.carHead(c, P, e.a + e.d * e.hh, 'gv-scuff', e.z, (hop & 1) | (f < .3 ? 2 : 0), 0, (hop & 1 ? 3 : -3) - Math.sin(f * Math.PI) * 4, e.col, e.acc, e.hi);
  }
  function carTurn(c, e, H) {                                        /* an arrow runs the path, jogs off it at 55% (the wrong turn) and back on; chevrons behind */
    var P = e.P, Q = H.Q, k, u, off, hh = e.hh;
    function jog(u) { var d = Math.abs(u - .55); return d < .12 ? (1 - d / .12) * 9 : 0; }
    for (k = 1; k <= 4; k++) { u = hh - k * .06; if (u < 0) break; P.atq(e.a + e.d * u); off = jog(u); H.glyph(c, 'gv-chev', Q.x + Q.nx * (4 + off), Q.y + Q.ny * (4 + off), 0, 0, e.hi, e.acc, e.col, -Q.ny, Q.nx, Q.nx, Q.ny); }
    P.atq(e.a + e.d * hh); off = jog(hh); H.glyph(c, 'gv-sign', Q.x + Q.nx * (5 + off), Q.y + Q.ny * (5 + off), e.z, (Math.floor(e.p * 12) & 1) ? 2 : (off > 2 ? 1 : 0), e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  function carPin(c, e, H) {                                         /* a taut line draws along the path, cross-stitched; a pin is driven in at its head */
    var P = e.P, Q = H.Q, u, X = 0, Y = 0, i = 0;
    for (u = 0; u <= e.hh; u += .02) { P.atq(e.a + e.d * u); X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3; H.px(c, X, Y, e.hi); if (i++ % 6 === 0) { H.px(c, X - 1, Y - 1, e.col); H.px(c, X + 1, Y + 1, e.col); } }
    H.glyph(c, 'gv-pin', X, Y - 1, 0, e.p > .85 ? 1 : 3, e.col, e.acc, '#d9dde4', 0, 1, 0, -1);
  }
  function carShadow(c, e, H) {                                      /* a shadow puddle slides along; at the end the hooded figure pops up out of it */
    var P = e.P, Q = H.Q, u;
    for (u = Math.max(0, e.hh - .25); u <= e.hh; u += .03) { P.atq(e.a + e.d * u); H.bx(c, Q.x + Q.nx * 3 - 2, Q.y + Q.ny * 3, 4, 1, e.acc); }
    H.carHead(c, P, e.a + e.d * e.hh, 'gv-shade', e.z, e.p > .8 ? 0 : e.p > .7 ? 1 : 2, 0, 0, e.col, e.acc, e.hi);
  }
  function carMist(c, e, H) {                                        /* misty prints step along the path, left and right, fading behind the newest */
    var P = e.P, Q = H.Q, k, n = 6, u, age;
    for (k = 0; k < n; k++) { u = (k + .5) / n; if (u > e.hh + .02) break; age = (e.hh - u) * 4; if (age > 1.2) continue; P.atq(e.a + e.d * u);
      H.glyph(c, 'gv-mist', Q.x + Q.nx * (4 + (k & 1 ? 3 : 0)), Q.y + Q.ny * (4 + (k & 1 ? 3 : 0)), e.z, (age < .35 ? 0 : age < .8 ? 1 : 2) | ((k & 1) << 2), e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny); }
  }

  PFA.motif('gv-skitter', function (c, e, H) { comp(c, e, H, perKick, decoSkid); }, { nm: 'skittering scuffs', desc: 'scuffed little prints skittering in quick hops with skid streaks, dust kicked off', fam: 'puff', gap: 18, g: 'gv-scuff', mo: 'gv-scurry', x: '-', car: 'custom', carDraw: carSkitter });
  PFA.motif('gv-wrong-turn', function (c, e, H) { comp(c, e, H, null, decoTurn); }, { nm: 'crooked signposts', desc: 'crooked signposts spinning like weathervanes, chevrons on the edge swerving off course', fam: 'shock', gap: 22, g: 'gv-sign', mo: 'gv-vane', x: '-', car: 'custom', carDraw: carTurn });
  PFA.motif('gv-pinning-stance', function (c, e, H) { comp(c, e, H, null, decoPins); }, { nm: 'planted boots', desc: 'planted boots stamping in turn, push-pins driven into the edge', fam: 'shield', gap: 24, g: 'gv-boot', mo: 'gv-plant', x: '-', car: 'custom', carDraw: carPin });
  PFA.motif('gv-shadow-step', function (c, e, H) { comp(c, e, H, null, decoShadow); }, { nm: 'shadow outline', desc: 'a dark outline hugging the edge, little hooded shadows rising out of it and sinking back', fam: 'puff', gap: 24, g: 'gv-shade', mo: 'gv-sink', x: '-', car: 'custom', carDraw: carShadow });
  PFA.motif('gv-phantom-footing', function (c, e, H) { comp(c, e, H, null, decoMist); }, { nm: 'misty footprints', desc: 'misty pale prints appearing in step and fading, mist curls lifting; on the fire a ghostly hand slides an aim ring', fam: 'ripple', gap: 16, g: 'gv-mist', mo: 'gv-wander', x: '-', car: 'custom', carDraw: carMist });
})();
