/* Motif module (mock-up only, not in the game yet): the five Lore tier pieces' own-edge effects and chain effects, written like claude/pf-anim/motifs/medium_m01.js
   and engine2-src/stat_pieces.js (same composition helper, same glyph / motion / motif registration).
   Knot of Twine (Trick, craft): loose twine loops along the edge that cinch into knots; a twisted cord runs the edge. Chain: a strand pulls taut along the link, a knot glows at the far end.
   Lantern Chain (Trick, craft): a string of paper lanterns along the edge that light one by one and sway. Chain: lanterns light one after another along the link.
   Weather Lore (Item, mind): a weathervane cockerel spinning among small clouds that part into suns, wind streaks. Chain: a cloud runs the link and bursts into a sun.
   Copybook (Trick, craft): ruled copybook lines along the edge; letters traced in pencil, then inked, the pencil at the head. Chain: a pencil traces the link, ink follows, a tag box is stamped.
   Turn of the Tale (Trick, mind): storybook pages turning one after another along the edge, old brown ink giving way to your blue. Chain: a page flips along the link, re-inking it blue.
   Every draw is a stateless function of p (hash noise only); glyphs go through H.glyph (MAXG budget); (a, b) = along the tangent, out along the normal. */
(function () {
  var WH = '#ffffff', PEN = '#e8b840', LEAD = '#4a4a4a', RUB = '#e08a8a', GREY = '#8d8d8d', RULE = '#8fb6dc', MARGIN = '#c0503a', OLD = '#7a3b2e', CLOUD = '#e8eef4';
  var LET = ['010101111101101', '110101110101110', '011100100100011', '010101101101010', '011100010001110', '101101111111101', '101101010010010', '110101110101101'];   // A B C O S W Y R (3 x 5)

  /* the shared own-edge composition (as engine2-src/stat_pieces.js): layout x motion per glyph, optional per-glyph and per-run extras */
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

  /* ================= Knot of Twine ================= */
  PFA.glyph('gv-loop', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* fr 0 loose loop, 1 half cinched, 2 knot, 3 knot glowing; the loop leans out from the edge along the normal */
    var i, t, ra, rb, s = z > 0 ? 1 : 0;
    if (fr < 2) {
      ra = (fr ? 2 : 3) + s; rb = (fr ? 1.6 : 2.6) + s * .5;
      for (i = 0; i < 18; i++) { t = i / 18 * Math.PI * 2; P2(c, K, x, y, tx, ty, nx, ny, Math.cos(t) * ra, rb + Math.sin(t) * rb, (i % 6) < 3 ? C : A); }
      for (i = -2; i <= 0; i++) P2(c, K, x, y, tx, ty, nx, ny, (i & 1) ? -1 : 0, i, C);   /* the strand back to the edge */
      P2(c, K, x, y, tx, ty, nx, ny, 0, 2 * rb, Hi);
    } else {
      for (i = -1 - s; i <= 1 + s; i++) { P2(c, K, x, y, tx, ty, nx, ny, i, i, A); P2(c, K, x, y, tx, ty, nx, ny, i, -i, A); }
      P2(c, K, x, y, tx, ty, nx, ny, 0, 0, C); P2(c, K, x, y, tx, ty, nx, ny, 1, 0, C); P2(c, K, x, y, tx, ty, nx, ny, -1, 0, C); P2(c, K, x, y, tx, ty, nx, ny, 0, 1, Hi);
      P2(c, K, x, y, tx, ty, nx, ny, -3 - s, 2, C); P2(c, K, x, y, tx, ty, nx, ny, 3 + s, 2, C);   /* the two tails */
      if (fr === 3) { K.px(c, x - 3 - s, y - 3 - s, Hi); K.px(c, x + 3 + s, y - 3 - s, Hi); K.px(c, x - 3 - s, y + 3 + s, Hi); K.px(c, x + 3 + s, y + 3 + s, Hi); K.px(c, x, y - 4 - s, WH); }
    }
  });
  PFA.motion('gv-cinch', function (G, pp, k, ph) {   /* each loop hangs loose and swings, then pulls tight into a knot, one after another */
    var q = (pp * 1.4 + ph * .35 + k * .09) % 1;
    G.fr = q < .5 ? 0 : q < .66 ? 1 : q < .9 ? 2 : 3;
    if (G.fr === 0) G.t += Math.sin(pp * 7 + k * 1.3) * 1.6; else G.d -= 1;
  });
  function decoCord(c, e, H, s0, len, ri, pp) {   /* a twisted cord along the edge: two-tone pixels in a slow twist */
    var s, Q = H.Q, v = Math.min(1, env(e.p) * 2.5), d;
    for (s = 0; s < len; s += 1) { if (!H.stip(v, s + ri * 50, e.p)) continue; e.P.atq(s0 + s); d = 2 + Math.round(Math.sin(s * .55 + pp * 9)); H.px(c, Q.x + Q.nx * d, Q.y + Q.ny * d, ((s + Math.floor(pp * 10)) & 3) < 2 ? e.col : e.acc); }
  }
  function carKnot(c, e, H) {   /* the strand pulls taut along the path (its wave flattens as it goes), then a knot glows where it lands */
    var P = e.P, Q = H.Q, u, w = (1 - e.hh) * 3, X = 0, Y = 0;
    for (u = 0; u <= e.hh; u += .012) { P.atq(e.a + e.d * u); var o = 3 + Math.sin(u * 30 - e.p * 12) * w; X = Q.x + Q.nx * o; Y = Q.y + Q.ny * o; H.px(c, X, Y, ((u * 80) | 0) % 4 < 2 ? e.col : e.acc); }
    if (e.hh > .8) H.glyph(c, 'gv-loop', X, Y, e.z, e.p > .9 ? 3 : 2, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
    else H.glyph(c, 'gv-loop', X, Y, e.z, 0, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  PFA.motif('gv-knot-twine', function (c, e, H) { comp(c, e, H, null, decoCord); }, { nm: 'twine knots', desc: 'loose twine loops that cinch into knots on a twisted cord; chain: a strand pulled taut, a knot glowing on the linked piece', fam: 'thread', gap: 20, g: 'gv-loop', mo: 'gv-cinch', x: '-', car: 'custom', carDraw: carKnot });

  /* ================= Lantern Chain ================= */
  PFA.glyph('gv-lantern', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* an upright paper lantern hanging from its string; fr 0 unlit, 1 lit, 2 lit with a halo */
    var w = 2 + (z > 0 ? 1 : 0), lit = fr > 0, body = lit ? C : A, rib = lit ? A : C, i;
    K.px(c, x, y - w - 3, A); K.bx(c, x - 1, y - w - 2, 3, 1, A);
    K.bx(c, x - w + 1, y - w - 1, 2 * w - 1, 1, body); K.bx(c, x - w, y - w, 2 * w + 1, 2 * w, body); K.bx(c, x - w + 1, y + w, 2 * w - 1, 1, body);
    for (i = -w; i < w; i++) { K.px(c, x - w + 1, y + i, rib); K.px(c, x + w - 1, y + i, rib); }
    K.bx(c, x - 1, y + w + 1, 3, 1, A); K.px(c, x, y + w + 2, A);
    if (lit) { K.px(c, x, y, Hi); K.px(c, x, y - 1, Hi); if (z > 0) K.px(c, x, y + 1, WH); }
    if (fr === 2) { K.px(c, x - w - 2, y, Hi); K.px(c, x + w + 2, y, Hi); K.px(c, x, y - w - 5, Hi); K.px(c, x - w - 1, y - w - 1, Hi); K.px(c, x + w + 1, y - w - 1, Hi); K.px(c, x - w - 1, y + w + 1, Hi); K.px(c, x + w + 1, y + w + 1, Hi); }
  });
  PFA.motion('gv-swing', function (G, pp, k, ph) {   /* they sway on the string; lit one after another along the edge, a flicker now and then */
    G.t += Math.sin(pp * 4 + k * .9) * 1.4; G.d += 7; G.up -= 3;
    var on = pp * 2.2 - k * .16 - ph * .05;
    G.fr = on < 0 ? 0 : ((Math.floor(pp * 9) + k * 3) % 7 === 0 ? 2 : 1);
    if (on >= 0 && on < .12) G.fr = 2;
  });
  function decoString(c, e, H, s0, len, ri, pp) {   /* the string they hang from: a dotted line a little off the edge */
    var s, Q = H.Q, v = Math.min(1, env(e.p) * 3);
    for (s = 0; s < len; s += 2) { if (!H.stip(v, s + ri * 30, e.p)) continue; e.P.atq(s0 + s); var d = 6 + Math.abs(Math.sin((s / len) * Math.PI * 3)) * 2; H.px(c, Q.x + Q.nx * d, Q.y + Q.ny * d - 3, e.acc); }
  }
  function carLantern(c, e, H) {   /* lanterns light one by one along the link, a string between them */
    var P = e.P, Q = H.Q, k, u, n = 4;
    for (u = 0; u <= Math.min(1, e.hh + .02); u += .03) { P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 7, Q.y + Q.ny * 7 - 3, e.acc); }
    for (k = 0; k < n; k++) { u = (k + .5) / n; P.atq(e.a + e.d * u); H.glyph(c, 'gv-lantern', Q.x + Q.nx * 8, Q.y + Q.ny * 8, e.z, e.hh >= u ? (e.hh - u < .12 ? 2 : 1) : 0, e.col, e.acc, e.hi, 1, 0, 0, -1); }
  }
  PFA.motif('gv-lantern-chain', function (c, e, H) { comp(c, e, H, null, decoString); }, { nm: 'paper lanterns', desc: 'a string of paper lanterns along the edge, lighting one by one and swaying; chain: lanterns lighting down the link', fam: 'sparkle', gap: 22, g: 'gv-lantern', mo: 'gv-swing', x: '-', car: 'custom', carDraw: carLantern });

  /* ================= Weather Lore ================= */
  PFA.glyph('gv-wl', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* fr >> 2: 0 weathervane (fr & 3 = heading), 1 cloud (fr & 3 = how far it has parted), 2 sun (fr & 1 = ray phase) */
    var t = fr >> 2, s = fr & 3, i, L = 3 + (z > 0 ? 1 : 0);
    if (t === 0) {   /* the cockerel on its rod, the arrow below it turning */
      K.bx(c, x, y - 2, 1, 6, A);
      var D = [[1, 0], [1, -1], [0, -1], [-1, -1]][s], f = s === 2 ? 1 : L;
      for (i = -f; i <= f; i++) K.px(c, x + D[0] * i, y + 2 + D[1] * i * (s === 2 ? 1 : .5), C);
      K.px(c, x + D[0] * (f + 1), y + 2 + D[1] * (f + 1) * .5, Hi);
      K.bx(c, x - 2, y - 5, 4, 2, A); K.px(c, x + 2, y - 6, A); K.px(c, x - 3, y - 6, A); K.px(c, x - 3, y - 7, A); K.px(c, x + 2, y - 7, '#c0503a');   /* body, head, tail, comb */
    } else if (t === 1) {
      var o = s;   /* the two halves part */
      K.bx(c, x - 4 - o, y - 1, 4, 3, CLOUD); K.bx(c, x - 3 - o, y - 2, 2, 1, CLOUD); K.bx(c, x + o, y - 1, 4, 3, CLOUD); K.bx(c, x + 1 + o, y - 3, 2, 2, CLOUD);
      K.bx(c, x - 4 - o, y + 2, 4, 1, A); K.bx(c, x + o, y + 2, 4, 1, A); K.px(c, x - 2 - o, y - 1, WH); K.px(c, x + 2 + o, y - 2, WH);
      if (o > 0) K.px(c, x, y, C);
    } else {
      K.bx(c, x - 1, y - 1, 3, 3, C); K.px(c, x, y, WH);
      if (s & 1) { K.px(c, x - 3, y - 3, C); K.px(c, x + 3, y - 3, C); K.px(c, x - 3, y + 3, C); K.px(c, x + 3, y + 3, C); }
      else { K.bx(c, x, y - L - 1, 1, 2, C); K.bx(c, x, y + L, 1, 2, C); K.bx(c, x - L - 1, y, 2, 1, C); K.bx(c, x + L, y, 2, 1, C); }
      K.px(c, x - 2, y - 2, Hi);
    }
  });
  PFA.motion('gv-wl', function (G, pp, k, ph) {   /* slot 0 of every three is the vane (spinning), the rest clouds that part and turn into suns as the effect runs */
    G.t += Math.sin(pp * 3 + k) * 1.2;
    if (k % 3 === 0) { G.d += 5; G.fr = (Math.floor(pp * 12) + k) & 3; return; }
    var q = pp * 1.1 - ph * .15;
    G.d += 4 + Math.sin(pp * 2 + k) * 1.5;
    G.fr = q < .35 ? 4 : q < .45 ? 5 : q < .55 ? 6 : 8 | (Math.floor(pp * 8) & 1);
  });
  function decoWind(c, e, H, s0, len, ri, pp) {   /* wind streaks sliding along the edge */
    var k, s, j, Q = H.Q;
    if (e.p > .95) return;
    for (k = 0; k < 3; k++) { if ((Math.floor(pp * 10) + k) % 4 === 0) continue; s = s0 + ((H.hash(e.seed + k * 13 + ri) * len + pp * 70) % len);
      for (j = 0; j < 4; j++) { e.P.atq(Math.min(s0 + len, s + j)); H.px(c, Q.x + Q.nx * (12 + k * 2), Q.y + Q.ny * (12 + k * 2), j < 2 ? e.hi : CLOUD); } }
  }
  function carWeather(c, e, H) {   /* a cloud runs the link, wind streaks behind it, and bursts into a sun where it lands */
    var P = e.P, Q = H.Q, k, u;
    for (k = 1; k <= 3; k++) { u = e.hh - k * .06; if (u < 0) break; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5, e.hi); H.px(c, Q.x + Q.nx * 5 + 1, Q.y + Q.ny * 5, CLOUD); }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'gv-wl', Q.x + Q.nx * 6, Q.y + Q.ny * 6, e.z, e.hh < .75 ? 4 : e.hh < .85 ? 6 : 8 | (Math.floor(e.p * 12) & 1), e.col, e.acc, e.hi, 1, 0, 0, -1);
  }
  PFA.motif('gv-weather-lore', function (c, e, H) { comp(c, e, H, null, decoWind); }, { nm: 'weathervane', desc: 'a spinning weathervane cockerel among clouds that part into suns, wind streaks along the edge; chain: a cloud runs the link and bursts into a sun', fam: 'sparkle', gap: 18, g: 'gv-wl', mo: 'gv-wl', x: '-', car: 'custom', carDraw: carWeather });

  /* ================= Copybook ================= */
  PFA.glyph('gv-cb-letter', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* one upright letter; fr bit 0 = still pencil (grey), fr >> 1 = which letter */
    var bits = LET[(fr >> 1) % LET.length], col = fr & 1 ? GREY : C, i;
    for (i = 0; i < 15; i++) if (bits.charAt(i) === '1') K.px(c, x - 1 + (i % 3), y - 2 + ((i / 3) | 0), col);
  });
  PFA.glyph('gv-pencil', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a pencil leaning back from its lead tip (x, y), screen up-right */
    var i; K.px(c, x, y, LEAD); K.px(c, x + 1, y - 1, '#d8b088');
    for (i = 2; i < 8; i++) { K.px(c, x + i, y - i, PEN); K.px(c, x + i + 1, y - i, i & 1 ? '#b88a20' : PEN); }
    K.px(c, x + 8, y - 8, RUB); K.px(c, x + 9, y - 8, RUB); K.px(c, x + 8, y - 9, RUB);
    if (fr & 1) K.px(c, x - 1, y + 1, GREY);
  });
  function copyDraw(c, e, H) {   /* ruled lines on the edge; letters written left to right in pencil, then inked; the pencil rides the head */
    var runs = e.runs, P = e.P, Q = H.Q, ri, r, len, k, n, f, s, w = Math.min(1, e.p * 1.5), v = Math.min(1, env(e.p) * 3), X, Y;
    for (ri = 0; ri < runs.length; ri++) {
      r = runs[ri]; len = r[1] - r[0]; n = Math.max(1, Math.min(9, Math.round(len / 7)));
      for (s = 0; s < len; s += 2) { if (!H.stip(v, s + ri * 40, e.p)) continue; P.atq(r[0] + s); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, RULE); H.px(c, Q.x + Q.nx * 9, Q.y + Q.ny * 9, RULE); }
      if (H.stip(v, ri, e.p)) { P.atq(r[0] + 3); H.px(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4, MARGIN); H.px(c, Q.x + Q.nx * 6, Q.y + Q.ny * 6, MARGIN); H.px(c, Q.x + Q.nx * 8, Q.y + Q.ny * 8, MARGIN); }
      for (k = 0; k < n; k++) {
        f = (k + .5) / n; if (f > w || !H.stip(v, k + ri * 9, e.p)) continue;
        P.atq(r[0] + len * f); X = Q.x + Q.nx * 5.5; Y = Q.y + Q.ny * 5.5;
        H.glyph(c, 'gv-cb-letter', X, Y, e.z, (((k + ri * 3 + Math.floor(e.seed)) % 8) << 1) | (w - f < .22 ? 1 : 0), e.col, e.acc, e.hi, 1, 0, 0, -1);
      }
      if (ri === 0 && w < 1 && e.p < .9) { P.atq(r[0] + len * w); H.glyph(c, 'gv-pencil', Q.x + Q.nx * 5 + 2, Q.y + Q.ny * 5 + 2, 0, Math.floor(e.p * 20) & 1, e.col, e.acc, e.hi, 1, 0, 0, -1); }
    }
  }
  function carCopy(c, e, H) {   /* the pencil traces the link in grey, the ink follows a quarter behind; a little tag box is stamped where it ends */
    var P = e.P, Q = H.Q, u, X = 0, Y = 0, ink = e.hh - .28;
    for (u = 0; u <= e.hh; u += .02) { P.atq(e.a + e.d * u); X = Q.x + Q.nx * 4; Y = Q.y + Q.ny * 4; H.px(c, X, Y, u < ink ? e.col : GREY); if (u < ink && ((u * 50) | 0) % 3 === 0) H.px(c, X, Y - 1, e.hi); }
    if (e.p < .92) H.glyph(c, 'gv-pencil', X, Y, 0, Math.floor(e.p * 20) & 1, e.col, e.acc, e.hi, 1, 0, 0, -1);
    if (e.hh > .85) { P.atq(e.a + e.d); X = Q.x + Q.nx * 9; Y = Q.y + Q.ny * 9; H.ringpx(c, X, Y, 3, e.col); H.bx(c, X - 2, Y - 2, 5, 5, e.hi); H.bx(c, X - 1, Y, 3, 1, e.col); H.px(c, X + 1, Y - 1, e.col); H.px(c, X + 1, Y + 1, e.col); }
  }
  PFA.motif('gv-copybook', function (c, e, H) { copyDraw(c, e, H); }, { nm: 'copybook lines', desc: 'ruled copybook lines on the edge, letters traced in pencil then inked, the pencil at the head; chain: pencil then ink along the link, a tag box stamped at the end', fam: 'ripple', gap: 8, g: 'gv-cb-letter', mo: 'snap', x: '-', car: 'custom', carDraw: carCopy });

  /* ================= Turn of the Tale ================= */
  PFA.glyph('gv-page', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a storybook page turning on its spine (x - 3): fr 0 flat (old brown ink), 1 lifting, 2 edge-on, 3 over (your blue ink on its back) */
    var h = 7 + (z > 0 ? 1 : 0), sx = x - 3, W = [6, 4, 1, 5][fr & 3], i, back = (fr & 3) === 3, x0 = back ? sx - W : sx + 1, ink = back ? A : OLD;
    K.bx(c, sx, y - h / 2 - 1, 1, h + 2, A);
    K.bx(c, x0, y - h / 2, W, h, back ? Hi : C);
    if (W > 2) for (i = 1; i < h - 1; i += 2) K.bx(c, x0 + 1, Math.round(y - h / 2 + i), W - 2, 1, ink);
    if ((fr & 3) === 1) K.px(c, x0 + W, y - h / 2 - 1, Hi);
    if ((fr & 3) === 2) { K.bx(c, sx + 1, y - h / 2 - 2, 1, h + 3, Hi); }
  });
  PFA.motion('gv-turn', function (G, pp, k, ph) {   /* the pages turn one after another along the edge and stay over */
    var q = pp * 2.4 - k * .16 - ph * .08, fr = q < 0 ? 0 : Math.min(3, Math.floor(q * 6));
    G.fr = fr; G.d += 3; if (fr === 1 || fr === 2) G.up += 2;
  });
  function decoReink(c, e, H, s0, len, ri, pp) {   /* the edge re-inked: old brown ink ahead of the head, your blue behind it */
    var s, Q = H.Q, head = Math.min(1, pp * 1.2) * len, v = Math.min(1, env(e.p) * 2.5);
    for (s = 0; s < len; s += 2) { if (!H.stip(v, s + ri * 20, e.p)) continue; e.P.atq(s0 + s); H.px(c, Q.x + Q.nx * 1, Q.y + Q.ny * 1, s < head ? e.acc : OLD); }
    e.P.atq(s0 + Math.min(len, head)); if (head < len) H.sq(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, 2, e.hi);
  }
  function carPage(c, e, H) {   /* a page flips along the link, leaving it inked in your blue; a ring where it lands */
    var P = e.P, Q = H.Q, u;
    for (u = 0; u <= e.hh; u += .025) { P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.acc); }
    P.atq(e.a + e.d * e.hh);
    H.glyph(c, 'gv-page', Q.x + Q.nx * 7, Q.y + Q.ny * 7 - Math.sin(e.hh * Math.PI) * 6, e.z, Math.floor(e.p * 14) & 3, e.col, e.acc, e.hi, 1, 0, 0, -1);
    if (e.hh > .88) { P.atq(e.a + e.d); H.ringpx(c, Q.x + Q.nx * 6, Q.y + Q.ny * 6, 2 + Math.round((e.hh - .88) * 40), e.acc); }
  }
  PFA.motif('gv-turn-tale', function (c, e, H) { comp(c, e, H, null, decoReink); }, { nm: 'turning pages', desc: 'storybook pages turning one after another along the edge, old brown ink giving way to your blue; chain: a page flipping down the link', fam: 'ripple', gap: 18, g: 'gv-page', mo: 'gv-turn', x: '-', car: 'custom', carDraw: carPage });
})();
