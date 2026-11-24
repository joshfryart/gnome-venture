/* Motif module (mock-up only, not in the game yet): the five shortlisted Luck pieces' own-edge effects and chain effects, written like motifs/stat_pieces.js.
   Hedge Rummage (Trick, mind, Pluck): hedge sprigs poking out of the edge and rustling, loose leaves dropping, now and then a glint in the leaves. Chain: a bramble runner grows along the link.
   Long Shot (Hurt, body): pebbles flung out from the edge on long high arcs with a dotted flight trail. Chain: a pebble skips twice along the link.
   Magpie's Pinch (Item, body): black-and-white feathers fluttering off the edge, a stolen glint winking. Chain: a little magpie flies the link with a glint in its beak.
   Turn of the Coin (Trick, mind): gold coins standing on edge, spinning (face, three-quarter, edge, three-quarter). Chain: a coin rolls along the link on its rim.
   Lucky Streak (Trick, body): a row of bulbs round the edge, lights chasing, a clover popping on the lit bulb. Chain: the bulbs light one after another along the link.
   Every draw is a stateless function of p (hash noise only); glyphs go through H.glyph (MAXG budget); (a, b) = along the tangent, out along the normal. */
(function () {
  var INK = '#2a1a10', WH = '#ffffff', LEAF = '#5f9a4a', LEAFD = '#2f5a24', LEAFL = '#b8e08a', BERRY = '#b8442c', OFF = '#6d5a40';

  /* ---------- shared own-edge composition (as stat_pieces.js): layout x motion per glyph, then optional per-glyph and per-run extras ---------- */
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
        if (per) per(c, e, H, x, y, -ny, nx, nx, ny, fr, k, bx0, by0, n);
        H.glyph(c, M.g, x, y, z, fr, e.col, e.acc, e.hi, -ny, nx, nx, ny);
      }
      if (deco) deco(c, e, H, r[0], len, ri, pp);
    }
  }
  function P2(c, K, x, y, tx, ty, nx, ny, a, b, col) { K.px(c, x + tx * a + nx * b, y + ty * a + ny * b, col); }

  /* ---------- glyphs ---------- */
  PFA.glyph('gv-sprig', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a hedge sprig poking out: a stem along the normal, two leaves that rustle (fr bit 0 = leaves tipped), a berry on bit 1 */
    var i, L = 4 + (z > 0 ? 1 : 0), s = fr & 1 ? 1 : -1;
    for (i = 0; i <= L; i++) P2(c, K, x, y, tx, ty, nx, ny, 0, -i + 2, A);
    P2(c, K, x, y, tx, ty, nx, ny, -1 * s, 1, C); P2(c, K, x, y, tx, ty, nx, ny, -2 * s, 0, C); P2(c, K, x, y, tx, ty, nx, ny, -2 * s, 1, Hi);
    P2(c, K, x, y, tx, ty, nx, ny, 1 * s, -1, C); P2(c, K, x, y, tx, ty, nx, ny, 2 * s, -2, C); P2(c, K, x, y, tx, ty, nx, ny, 2 * s, -1, Hi);
    P2(c, K, x, y, tx, ty, nx, ny, 0, 3, C); P2(c, K, x, y, tx, ty, nx, ny, -1, 3, C); P2(c, K, x, y, tx, ty, nx, ny, 1, 3, Hi);
    if (fr & 2) { K.px(c, x + nx * 2 + tx, y + ny * 2 + ty, BERRY); }
  });
  PFA.glyph('gv-pebble', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a round pebble: ink rim, flat stone body, one light band, one shade band (fr bit 0 squashes it on a bounce) */
    var r = 2 + (z > 0 ? 1 : 0), sq = fr & 1;
    K.bx(c, x - r, y - r - 1 + sq, 2 * r + 1, 2 * r + 3 - sq * 2, A); K.bx(c, x - r - 1, y - r + sq, 2 * r + 3, 2 * r + 1 - sq * 2, A);
    K.bx(c, x - r, y - r + sq, 2 * r + 1, 2 * r + 1 - sq * 2, C); K.bx(c, x - r + 1, y - r + sq, r, 1, Hi); K.bx(c, x - 1, y + r - 1 - sq, r + 1, 1, OFF);
  });
  PFA.glyph('gv-feather', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a magpie feather tumbling: black vane with a white base and a blue sheen tip, quill along fr's lean */
    var i, l = 5 + (z > 0 ? 1 : 0), s = fr & 1 ? 1 : -1, a, b;
    for (i = 0; i < l; i++) { a = i - (l >> 1); b = (i * s) >> 1; K.px(c, x + a, y + b, A); K.px(c, x + a, y + b - 1, i < 2 ? WH : C); K.px(c, x + a, y + b + 1, i < 2 ? WH : C); }
    a = l - (l >> 1); b = (l * s) >> 1; K.px(c, x + a, y + b, Hi); K.px(c, x + a - 1, y + b - 1, Hi);
  });
  PFA.glyph('gv-coin', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a gold coin standing on its rim, spinning: fr 0 face, 1 three-quarter, 2 edge, 3 three-quarter (mirrored) */
    var r = 3 + (z > 0 ? 1 : 0), w = [r, r - 1, 0, r - 1][fr & 3], i, h;
    for (i = -r; i <= r; i++) { h = Math.round(Math.sqrt(Math.max(0, r * r - i * i)) * (w + .5) / (r + .5)); K.bx(c, x - h - 1, y + i, 2 * h + 3, 1, A); }
    K.bx(c, x - w, y - r - 1, 2 * w + 1, 1, A); K.bx(c, x - w, y + r + 1, 2 * w + 1, 1, A);
    for (i = -r; i <= r; i++) { h = Math.round(Math.sqrt(Math.max(0, r * r - i * i)) * (w + .5) / (r + .5)); K.bx(c, x - h, y + i, 2 * h + 1, 1, i < 0 ? Hi : C); }
    if (w >= r - 1 && w > 1) { K.px(c, x, y - 1, A); K.px(c, x, y + 1, A); K.px(c, x - 1, y, A); K.px(c, x + 1, y, A); }   /* the clover stamp, a four-dot cross */
    if (fr & 1) K.bx(c, x + (fr === 1 ? w : -w), y - r + 1, 1, 2 * r - 1, '#a8741a');                                       /* the rim showing on the turn */
  });
  PFA.glyph('gv-bulb', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a marquee bulb on a little socket: fr 0 off (dull), 1 lit (bright, white core, glow pixels) */
    var r = 2 + (z > 0 ? 1 : 0);
    K.bx(c, x - r, y - r - 1, 2 * r + 1, 2 * r + 3, A); K.bx(c, x - r - 1, y - r, 2 * r + 3, 2 * r + 1, A);
    K.bx(c, x - r, y - r, 2 * r + 1, 2 * r + 1, fr & 1 ? C : OFF); P2(c, K, x, y, tx, ty, nx, ny, 0, -r - 1, '#8a8a8a');
    if (fr & 1) { K.px(c, x - 1, y - 1, WH); K.px(c, x, y - 1, Hi); K.px(c, x - r - 2, y, Hi); K.px(c, x + r + 2, y, Hi); K.px(c, x, y - r - 2, Hi); K.px(c, x, y + r + 2, Hi); }
  });
  PFA.glyph('gv-clover', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a four-leaf clover popping (fr 0 small bud, 1 open) */
    var o = fr & 1 ? 2 : 1, d = [[0, -1], [1, 0], [0, 1], [-1, 0]], i, X, Y;
    for (i = 0; i < 4; i++) { X = x + d[i][0] * o; Y = y + d[i][1] * o; K.bx(c, X - 1, Y - 1, 3, 3, LEAFD); K.px(c, X, Y, i === 0 ? LEAFL : LEAF); if (o > 1) { K.px(c, X + d[i][1], Y - d[i][0], LEAF); } }
    K.px(c, x, y, LEAFD); K.px(c, x + 1, y + o + 2, LEAFD);
  });
  PFA.glyph('gv-bird', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a tiny magpie in flight facing +a: black body, white belly patch, long tail; fr bit 0 = wings up / down */
    var up = fr & 1 ? -1 : 1, i;
    for (i = -4; i <= 2; i++) P2(c, K, x, y, tx, ty, nx, ny, i, 0, C);
    P2(c, K, x, y, tx, ty, nx, ny, -5, 1, C); P2(c, K, x, y, tx, ty, nx, ny, -6, 1, C); P2(c, K, x, y, tx, ty, nx, ny, -7, 2, Hi);
    P2(c, K, x, y, tx, ty, nx, ny, -1, -1, WH); P2(c, K, x, y, tx, ty, nx, ny, 0, -1, WH);
    P2(c, K, x, y, tx, ty, nx, ny, 3, 0, '#3a3a3a'); P2(c, K, x, y, tx, ty, nx, ny, 2, 1, C);
    for (i = 1; i <= 3; i++) P2(c, K, x, y, tx, ty, nx, ny, -1 + (i >> 1), up * i, i === 3 ? Hi : C);
  });

  /* ---------- motions ---------- */
  PFA.motion('gv-rustle', function (G, pp, k, ph) { var w = Math.floor(pp * 9 + ph * 5); G.t += ((w + k) & 1 ? 1 : -1) * (1 + (ph > .5 ? 1 : 0)); G.fr = ((w + k) & 1) | (ph > .7 ? 2 : 0); });   /* sprigs shake left-right, a berry on some */
  PFA.motion('gv-lob', function (G, pp, k, ph) { var u = G.u; G.t += u * 10 * (ph > .5 ? 1 : -1); G.up += Math.sin(Math.PI * Math.min(1, u)) * 12; G.fr = u > .9 ? 1 : 0; });                 /* flung out on a high arc and dropping */
  PFA.motion('gv-tumblef', function (G, pp, k, ph) { G.t += Math.sin(pp * 6 + k * 1.9) * 3; G.up += Math.sin(pp * 4 + k) * 2 - pp * 3; G.fr = (Math.floor(pp * 7) + k) & 1; });               /* feathers see-saw down */
  PFA.motion('gv-spin', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 12 + ph * 4) + k) & 3; G.up += G.fr === 2 ? 1 : 0; });                                                                   /* coins spin on their rims */
  PFA.motion('gv-chase', function (G, pp, k, ph) { G.d = 4; G.vis = 1; G.t = 0; G.up = 0; G.fr = ((k - Math.floor(pp * 14)) % 3 + 3) % 3 === 0 ? 1 : 0; });                                   /* fixed bulbs, every third lit, the lit ones run along */

  /* ---------- per-glyph and per-run extras ---------- */
  function decoLeaves(c, e, H, s0, len, ri, pp) {                     /* loose leaves dropping off the hedge, and one glint in the leaves now and then (the Pluck's prize) */
    var k, u, Q = H.Q, X, Y;
    for (k = 0; k < 3; k++) { u = (pp * 1.2 + H.hash(e.seed + k * 7 + ri)) % 1; e.P.atq(s0 + len * H.hash(e.seed + k * 3 + ri * 5)); X = Q.x + Q.nx * (5 + 4 * u) + Math.sin(u * 9 + k) * 2; Y = Q.y + Q.ny * (5 + 4 * u) + 10 * u; H.px(c, X, Y, k & 1 ? LEAF : LEAFL); H.px(c, X + 1, Y, LEAFD); }
    if (ri === 0 && Math.floor(pp * 7) % 4 === 1) { e.P.atq(s0 + len * .5); H.plus(c, Q.x + Q.nx * 7, Q.y + Q.ny * 7, 2, 1, '#f6d878'); H.px(c, Q.x + Q.nx * 7, Q.y + Q.ny * 7, WH); }
  }
  function perArc(c, e, H, x, y, tx, ty, nx, ny, fr, k, bx0, by0) {   /* a dotted flight trail from the edge to the pebble */
    var i, u, X, Y; for (i = 1; i < 6; i++) { u = i / 6; X = bx0 + (x - bx0) * u; Y = by0 + (y - by0) * u - Math.sin(u * Math.PI) * 4; if (i & 1) H.px(c, X, Y, e.hi); }
  }
  function decoShot(c, e, H, s0, len, ri, pp) {                       /* the nock: a thin long arrow line laid along the first run, flashing on the release */
    if (ri !== 0 || e.p > .85) return; var Q = H.Q, s, X, Y; e.P.atq(s0 + len * .5); X = Q.x + Q.nx * 2; Y = Q.y + Q.ny * 2;
    for (s = -6; s <= 6; s++) H.px(c, X - Q.ny * s, Y + Q.nx * s, (s + Math.floor(pp * 10)) % 4 === 0 ? WH : e.acc);
    H.px(c, X - Q.ny * 7 + Q.nx, Y + Q.nx * 7 + Q.ny, e.acc); H.px(c, X - Q.ny * 7 - Q.nx, Y + Q.nx * 7 - Q.ny, e.acc);
  }
  function decoGlint(c, e, H, s0, len, ri, pp) {                      /* a stolen shiny winking where the feathers fall from */
    var Q = H.Q, w = Math.floor(pp * 8 + ri * 3) % 5, L = [0, 1, 3, 1, 0][w]; if (!L || e.p > .9) return;
    e.P.atq(s0 + len * H.hash(e.seed + ri * 7)); H.plus(c, Q.x + Q.nx * 9, Q.y + Q.ny * 9, L, 1, '#f6d878'); H.px(c, Q.x + Q.nx * 9, Q.y + Q.ny * 9, WH);
  }
  function decoSpark(c, e, H, s0, len, ri, pp) {                      /* a gold dotted rim under the coins, crawling */
    var s, Q = H.Q, ph = Math.floor(pp * 6);
    for (s = 0; s < len; s += 4) { if (((s >> 2) + ph) % 2) continue; e.P.atq(s0 + s); H.px(c, Q.x + Q.nx * 1, Q.y + Q.ny * 1, e.hi); }
  }
  function perClover(c, e, H, x, y, tx, ty, nx, ny, fr, k) {          /* a clover pops out beyond each lit bulb */
    if (!(fr & 1)) return; H.glyph(c, 'gv-clover', x + nx * 6, y + ny * 6, 0, Math.floor(e.p * 20 + k) & 1, e.col, e.acc, e.hi, tx, ty, nx, ny);
  }

  /* ---------- chain effects (carDraw: along the path from e.a over e.d, eased e.hh) ---------- */
  function carBramble(c, e, H) {                                      /* a bramble runner grows along the link, leaves budding off it, the sprig at its head */
    var P = e.P, Q = H.Q, u, X = 0, Y = 0, i = 0;
    for (u = 0; u <= e.hh; u += .02) { P.atq(e.a + e.d * u); X = Q.x + Q.nx * (3 + Math.sin(u * 22) * 1.5); Y = Q.y + Q.ny * (3 + Math.sin(u * 22) * 1.5); H.px(c, X, Y, LEAFD); if (++i % 6 === 0) { H.px(c, X, Y - 1, LEAF); H.px(c, X + 1, Y - 2, LEAFL); } if (i % 11 === 0) H.px(c, X, Y + 1, BERRY); }
    H.glyph(c, 'gv-sprig', X, Y, 0, Math.floor(e.p * 12) & 1, LEAF, LEAFD, LEAFL, 1, 0, 0, -1);
  }
  function carSkip(c, e, H) {                                         /* a pebble skips twice along the link (two arcs: the double shot), a dust tick where it touches */
    var P = e.P, Q = H.Q, h = e.hh, seg = h < .5 ? 0 : 1, u = seg ? (h - .5) / .5 : h / .5, s = e.a + e.d * h, k;
    for (k = 1; k <= 2; k++) if (h >= k * .5 - .01) { P.atq(e.a + e.d * k * .5); H.px(c, Q.x + Q.nx * 2 - 2, Q.y + Q.ny * 2, e.hi); H.px(c, Q.x + Q.nx * 2 + 2, Q.y + Q.ny * 2, e.hi); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3 - 1, e.hi); }
    H.carHead(c, P, s, 'gv-pebble', e.z, u > .92 ? 1 : 0, 0, -Math.sin(Math.PI * u) * (seg ? 8 : 12), e.col, e.acc, e.hi);
  }
  function carMagpie(c, e, H) {                                       /* a little magpie flies the link, a glint in its beak, two feathers left behind */
    var P = e.P, Q = H.Q, k, u;
    for (k = 1; k <= 2; k++) { u = e.hh - k * .22; if (u < 0) break; P.atq(e.a + e.d * u); H.glyph(c, 'gv-feather', Q.x + Q.nx * 6, Q.y + Q.ny * 6 + k * 2, 0, k & 1, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny); }
    P.atq(e.a + e.d * e.hh); var X = Q.x + Q.nx * 8, Y = Q.y + Q.ny * 8 - Math.sin(e.p * 18) * 2, dir = e.d >= 0 ? 1 : -1;
    H.glyph(c, 'gv-bird', X, Y, 0, Math.floor(e.p * 14) & 1, e.col, e.acc, e.hi, dir, 0, 0, -1);
    H.px(c, X + dir * 4, Y + 1, '#f6d878'); H.px(c, X + dir * 5, Y + 1, WH);
  }
  function carRoll(c, e, H) {                                         /* a coin rolls along the link on its rim, spinning, a gold track behind it */
    var P = e.P, Q = H.Q, u;
    for (u = 0; u < e.hh - .04; u += .05) { P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, e.hi); }
    H.carHead(c, P, e.a + e.d * e.hh, 'gv-coin', e.z, Math.floor(e.p * 20) & 3, 0, -Math.abs(Math.sin(e.hh * Math.PI * 2)) * 3, e.col, e.acc, e.hi);
  }
  function carBulbs(c, e, H) {                                        /* bulbs along the link light one after another, the latest the brightest, a clover at the end */
    var P = e.P, Q = H.Q, k, u, n = 6;
    for (k = 0; k <= n; k++) { u = k / n; P.atq(e.a + e.d * u); H.glyph(c, 'gv-bulb', Q.x + Q.nx * 4, Q.y + Q.ny * 4, 0, e.hh >= u ? 1 : 0, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny); }
    if (e.hh > .97) { P.atq(e.a + e.d); H.glyph(c, 'gv-clover', Q.x + Q.nx * 11, Q.y + Q.ny * 11, 0, 1, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny); }
  }

  PFA.motif('gv-hedge-rummage', function (c, e, H) { comp(c, e, H, null, decoLeaves); }, { nm: 'hedge sprigs', desc: 'hedge sprigs poking out and rustling, leaves dropping, a glint in the leaves', fam: 'sprout', gap: 16, g: 'gv-sprig', mo: 'gv-rustle', x: '-', car: 'custom', carDraw: carBramble });
  PFA.motif('gv-long-shot', function (c, e, H) { comp(c, e, H, perArc, decoShot); }, { nm: 'long shots', desc: 'pebbles flung out on long high arcs with a dotted trail, a thin nock line on the edge', fam: 'strike', gap: 24, g: 'gv-pebble', mo: 'gv-lob', x: '-', car: 'custom', carDraw: carSkip });
  PFA.motif('gv-magpie-pinch', function (c, e, H) { comp(c, e, H, null, decoGlint); }, { nm: 'magpie feathers', desc: 'black-and-white feathers fluttering off the edge, a stolen glint winking', fam: 'flutter', gap: 20, g: 'gv-feather', mo: 'gv-tumblef', x: '-', car: 'custom', carDraw: carMagpie });
  PFA.motif('gv-turn-coin', function (c, e, H) { comp(c, e, H, null, decoSpark); }, { nm: 'spinning coins', desc: 'gold coins standing on their rims, spinning, over a gold dotted rim', fam: 'sparkle', gap: 22, g: 'gv-coin', mo: 'gv-spin', x: '-', car: 'custom', carDraw: carRoll });
  PFA.motif('gv-lucky-streak', function (c, e, H) { comp(c, e, H, perClover, null); }, { nm: 'marquee bulbs', desc: 'a row of bulbs round the edge, lights chasing, a clover popping by each lit one', fam: 'pulse', gap: 10, g: 'gv-bulb', mo: 'gv-chase', x: '-', car: 'custom', carDraw: carBulbs });
})();
