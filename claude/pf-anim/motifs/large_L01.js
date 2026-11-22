/* Motif module, large batch L01 (alpha-dingo, red-fox, silver-fox, arctic-fox, tundra-fox, bramble-wolf, elder-bramble-wolf, wolverine, badger, old-brock).
   TEMPLATE.md sections 9 and 10.3. 17 motifs, each with its own pixel glyph (ids prefixed L01-) and motion; four have their own chain effect (carDraw).
   Glyph coordinates are written as (a, b): a along the edge tangent, b outward along the normal, so every sprite turns with the edge it sits on.
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation inside the frame loops (scratch H.Q / H.G,
   static tables built once at load). Glyphs go through H.glyph so the MAXG budget counts them; per-run decorations are capped at a few dozen pixels.
   The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy default are untouched (they live in the page). */
(function () {
  var BUR_C = [], BUR_S = [], i0;                 /* burr spike directions (8, plus the half-step set for the turned frame), built once */
  for (i0 = 0; i0 < 16; i0++) { BUR_C.push(Math.cos(i0 * Math.PI / 8)); BUR_S.push(Math.sin(i0 * Math.PI / 8)); }
  var DIVE_A = [1, .71, .99, .35], DIVE_B = [0, .71, .15, -.94];      /* mouse-dive body direction per frame: crouch, rise, top of arc, nose-down */
  var BRUSH_W = [1, 2, 2, 3, 3, 3, 3, 3, 2, 2];                       /* fox brush thickness from root to white tip */
  var BROCK = [                                                        /* badger face rows (b = 0 at the brow, nose outward): 0 cheek, 1 stripe, 2 blaze */
    [0, 1, 1, 2, 1, 1, 0], [0, 1, 1, 2, 1, 1, 0], [-1, 0, 1, 2, 1, 0, -1], [-1, 0, 1, 2, 1, 0, -1], [-1, -1, 1, 2, 1, -1, -1], [-1, -1, -1, 2, -1, -1, -1]];

  /* (a, b) -> screen helpers: no closures, no allocation */
  function pt(c, K, x, y, tx, ty, nx, ny, a, b, col) { K.px(c, x + tx * a + nx * b, y + ty * a + ny * b, col); }
  function st(c, K, x, y, tx, ty, nx, ny, a, b, w, col) { K.sq(c, x + tx * a + nx * b, y + ty * a + ny * b, w, col); }

  /* ---------- shared own-edge composition: the page's themedOwn() with this module's glyph / motion, plus optional per-run decoration ---------- */
  function comp(c, e, H, deco) {
    var runs = e.runs, mp = e.mp, M = e.M, z = e.z, p = e.p, pp = p * mp.spd, Q = H.Q, G = H.G, P = e.P,
      tie = mp.x === 'thread' || mp.lay === 'snare', ri, k, r, len, n, f, ph, sf, bx0, by0, nx, ny, x, y, lx = 0, ly = 0, has;
    for (ri = 0; ri < runs.length; ri++) {
      r = runs[ri]; len = r[1] - r[0]; n = Math.max(1, Math.min(7, Math.round(len / (M.gap || 12)))); if (mp.lay === 'lance') n = Math.min(n, 4); has = false;
      if (deco) deco(c, e, H, r[0], len, ri, pp);                     /* decoration first: glyphs sit on top of it */
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
    }
  }
  function plain(c, e, H) { comp(c, e, H, null); }

  /* ---------- per-run decorations ---------- */
  function decoVine(c, e, H, s0, len, ri, pp) {                       /* briar-vine: a wavy bramble cane creeps along the edge, hooked thorns and leaves on it */
    var s, i = 0, u = H.eo(Math.min(1, e.p * 1.5)), Q = H.Q, b;
    if (e.p > .93) return;
    for (s = 0; s < len * u; s += 2, i++) {
      if (e.p > .8 && H.hash(s + Math.floor(e.p * 40)) > (1 - e.p) / .2) continue;
      e.P.atq(s0 + s); b = 3 + Math.sin(s * .45 + ri) * 1.5; H.px(c, Q.x + Q.nx * b, Q.y + Q.ny * b, e.col);
      if (i % 5 === 2) { H.px(c, Q.x + Q.nx * (b + 1), Q.y + Q.ny * (b + 1), e.hi); H.px(c, Q.x + Q.nx * (b + 2) - Q.ny, Q.y + Q.ny * (b + 2) + Q.nx, e.hi); }
      else if (i % 7 === 5) { H.px(c, Q.x + Q.nx * (b - 1) + Q.ny, Q.y + Q.ny * (b - 1) - Q.nx, e.col); H.px(c, Q.x + Q.nx * (b - 2) + Q.ny * 2, Q.y + Q.ny * (b - 2) - Q.nx * 2, e.col); }
    }
  }
  function decoSnowBank(c, e, H, s0, len, ri, pp) {                   /* snow-curl: a snow bank heaps up along the edge for the fox to curl into */
    var s, h, j, u = H.eo(Math.min(1, e.p * 1.6)), Q = H.Q;
    if (e.p > .92) return;
    for (s = 0; s < len; s += 2) { h = Math.round((Math.sin(s * .35 + ri * 2) > .2 ? 2 : 1) * u); e.P.atq(s0 + s);
      for (j = 1; j <= h; j++) H.px(c, Q.x + Q.nx * j, Q.y + Q.ny * j, j === h && ((s >> 1) + Math.floor(pp * 6)) % 9 === 0 ? e.hi : H.WHITE); }
  }

  /* ---------- glyphs (pixel sprites at the demo resolution; tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step) ---------- */
  PFA.glyph('L01-dingo', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* alpha dingo face: thick neck ruff, a notched (scarred) ear, jaws that open and snap */
    var a, b, w = z > 1 ? 1 : 0, op = fr === 1 ? 1 : fr === 2 ? 2 : 0;
    for (a = -4 - w; a <= 4 + w; a++) { pt(c, K, x, y, tx, ty, nx, ny, a, -3, C); if (a & 1) pt(c, K, x, y, tx, ty, nx, ny, a, -4, Hi); }
    pt(c, K, x, y, tx, ty, nx, ny, -4 - w, -2, Hi); pt(c, K, x, y, tx, ty, nx, ny, -3 - w, -2, C); pt(c, K, x, y, tx, ty, nx, ny, 3 + w, -2, C); pt(c, K, x, y, tx, ty, nx, ny, 4 + w, -2, Hi);
    for (a = -2; a <= 2; a++) for (b = -1; b <= 2; b++) pt(c, K, x, y, tx, ty, nx, ny, a, b, C);
    if (z > 0) { pt(c, K, x, y, tx, ty, nx, ny, -3, 0, C); pt(c, K, x, y, tx, ty, nx, ny, 3, 0, C); }
    pt(c, K, x, y, tx, ty, nx, ny, -2, 3, C); pt(c, K, x, y, tx, ty, nx, ny, -1, 3, C); pt(c, K, x, y, tx, ty, nx, ny, -2, 4, C);   /* left ear, pointed */
    pt(c, K, x, y, tx, ty, nx, ny, 2, 3, C); pt(c, K, x, y, tx, ty, nx, ny, 1, 3, A);                                                  /* right ear: tip torn off, a scar mark */
    pt(c, K, x, y, tx, ty, nx, ny, -1, 1, A); pt(c, K, x, y, tx, ty, nx, ny, 1, 1, A);
    pt(c, K, x, y, tx, ty, nx, ny, -1, -1, Hi); pt(c, K, x, y, tx, ty, nx, ny, 1, -1, Hi); pt(c, K, x, y, tx, ty, nx, ny, 0, 0, A);    /* pale muzzle, dark nose */
    if (op) for (b = 1; b <= op + 1; b++) for (a = -1; a <= 1; a++) pt(c, K, x, y, tx, ty, nx, ny, a, -1 - b, A);
    if (op) { pt(c, K, x, y, tx, ty, nx, ny, -1, -2, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 1, -2, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, -1, -2 - op, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 1, -2 - op, K.WHITE); }
    else pt(c, K, x, y, tx, ty, nx, ny, 0, -2, A);
    if (fr === 3) { pt(c, K, x, y, tx, ty, nx, ny, -5, 1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, -6, 2, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 5, 1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 6, 2, K.WHITE); }
  });
  PFA.glyph('L01-runner', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a lean canine at full lope, side on: legs stretch and gather, tail streams */
    var a;
    for (a = -2; a <= 2; a++) { pt(c, K, x, y, tx, ty, nx, ny, a, 3, C); pt(c, K, x, y, tx, ty, nx, ny, a, 2, a === 0 || a === -1 ? Hi : C); }
    if (z > 1) for (a = -1; a <= 1; a++) pt(c, K, x, y, tx, ty, nx, ny, a, 4, C);
    st(c, K, x, y, tx, ty, nx, ny, 3.5, 3.5, 2, C); pt(c, K, x, y, tx, ty, nx, ny, 3, 5, C); pt(c, K, x, y, tx, ty, nx, ny, 5, 3, C); pt(c, K, x, y, tx, ty, nx, ny, 6, 3, A); pt(c, K, x, y, tx, ty, nx, ny, 4, 4, A);
    pt(c, K, x, y, tx, ty, nx, ny, -3, 4, C); pt(c, K, x, y, tx, ty, nx, ny, -4, 5 - fr, C); pt(c, K, x, y, tx, ty, nx, ny, -5, 5 - fr, Hi);
    if (fr === 0) { pt(c, K, x, y, tx, ty, nx, ny, 3, 1, C); pt(c, K, x, y, tx, ty, nx, ny, 4, 0, C); pt(c, K, x, y, tx, ty, nx, ny, -3, 1, C); pt(c, K, x, y, tx, ty, nx, ny, -4, 0, C); pt(c, K, x, y, tx, ty, nx, ny, -6, 0, A); }
    else { pt(c, K, x, y, tx, ty, nx, ny, 1, 1, C); pt(c, K, x, y, tx, ty, nx, ny, 0, 0, C); pt(c, K, x, y, tx, ty, nx, ny, -1, 1, C); pt(c, K, x, y, tx, ty, nx, ny, -1, 0, A); }
  });
  PFA.glyph('L01-burr', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a hooked seed burr: round core, eight hooked spikes, turning a half step per frame */
    var i, j = fr & 1, R = 3 + (z > 1 ? 1 : 0), cx = x + nx * 2, cy = y + ny * 2;
    K.sq(c, cx, cy, 3, C); K.px(c, cx, cy, A);
    for (i = 0; i < 8; i++) { var d = i * 2 + j; K.px(c, cx + BUR_C[d] * (R - 1), cy + BUR_S[d] * (R - 1), C); K.px(c, cx + BUR_C[d] * R, cy + BUR_S[d] * R, Hi);
      if ((i & 1) === 0) K.px(c, cx + BUR_C[(d + 1) & 15] * (R + 1), cy + BUR_S[(d + 1) & 15] * (R + 1), Hi); }
  });
  PFA.glyph('L01-brush', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a red fox brush: thick plume along the edge, swishing, the white tip flicking */
    var j, a, b, amp = 2 + (fr & 1) + (fr === 2 ? 1 : 0), flick = fr === 0 ? 0 : fr === 2 ? 2 : 1, w;
    for (j = 0; j < 10; j++) { a = j - 5; b = 2 + Math.sin(j * .35) * amp * .6 + (j > 6 ? (j - 6) * flick * .7 : 0); w = BRUSH_W[j] + (z > 1 && j > 2 && j < 8 ? 1 : 0);
      st(c, K, x, y, tx, ty, nx, ny, a, b, w, j >= 8 ? K.WHITE : C);
      if (j > 1 && j < 7 && (j & 1)) pt(c, K, x, y, tx, ty, nx, ny, a, b - (w >> 1) - 1, A);
      if (j === 7) pt(c, K, x, y, tx, ty, nx, ny, a, b + 1, Hi); }
  });
  PFA.glyph('L01-diver', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* mousing fox: crouch, arc up, top of the leap, nose-first dive; paws together on the way down */
    var da = DIVE_A[fr], db = DIVE_B[fr], qa = -db, qb = da, i, b0 = fr === 0 ? 1 : 3, w = 2 + (z > 1 ? 1 : 0);
    for (i = -2; i <= 1; i++) st(c, K, x, y, tx, ty, nx, ny, da * i, b0 + db * i, w, C);
    st(c, K, x, y, tx, ty, nx, ny, da * 3, b0 + db * 3, 3, C);
    pt(c, K, x, y, tx, ty, nx, ny, da * 3 + qa * 2, b0 + db * 3 + qb * 2, C); pt(c, K, x, y, tx, ty, nx, ny, da * 2.5 + qa * 2.5, b0 + db * 2.5 + qb * 2.5, C);   /* tall ears */
    pt(c, K, x, y, tx, ty, nx, ny, da * 4.6, b0 + db * 4.6, A); pt(c, K, x, y, tx, ty, nx, ny, da * 3 + qa, b0 + db * 3 + qb, A);
    pt(c, K, x, y, tx, ty, nx, ny, -da * 3 + qa, b0 - db * 3 + qb, C); pt(c, K, x, y, tx, ty, nx, ny, -da * 4 + qa * 1.6, b0 - db * 4 + qb * 1.6, C); pt(c, K, x, y, tx, ty, nx, ny, -da * 5 + qa * 2, b0 - db * 5 + qb * 2, Hi);
    if (fr === 0) { pt(c, K, x, y, tx, ty, nx, ny, -1, 0, A); pt(c, K, x, y, tx, ty, nx, ny, 1, 0, A); }
    else if (fr === 3) { pt(c, K, x, y, tx, ty, nx, ny, da * 4 - qa, b0 + db * 4 - qb, C); pt(c, K, x, y, tx, ty, nx, ny, da * 4.5 - qa * .5, b0 + db * 4.5 - qb * .5, C);
      pt(c, K, x, y, tx, ty, nx, ny, -2, 0, Hi); pt(c, K, x, y, tx, ty, nx, ny, 2, 0, Hi); pt(c, K, x, y, tx, ty, nx, ny, -3, 1, Hi); pt(c, K, x, y, tx, ty, nx, ny, 3, 1, Hi); }
    else { pt(c, K, x, y, tx, ty, nx, ny, -da - qa * 2, b0 - db - qb * 2, C); pt(c, K, x, y, tx, ty, nx, ny, da - qa * 2, b0 + db - qb * 2, C); }
  });
  PFA.glyph('L01-tipfur', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* silver fox guard hairs: a black tuft fanning out, every hair tipped silver, the tips glinting */
    var h, j, L = 5 + z, ang, sa, col;
    st(c, K, x, y, tx, ty, nx, ny, 0, 0, 3, A);
    for (h = -2; h <= 2; h++) { ang = h * .32 + (fr - 1.5) * .07; sa = Math.sin(ang);
      for (j = 1; j <= L - Math.abs(h); j++) { col = j < 3 ? A : j < L - Math.abs(h) ? C : (((fr + h + 4) & 3) === 0 ? K.WHITE : Hi); pt(c, K, x, y, tx, ty, nx, ny, sa * j * 1.4, j, col); } }
    if (fr === 1) { pt(c, K, x, y, tx, ty, nx, ny, 0, L + 2, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, -1, L + 1, Hi); pt(c, K, x, y, tx, ty, nx, ny, 1, L + 1, Hi); }
  });
  PFA.glyph('L01-coin', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a toll coin spinning upright: full face, three-quarter, edge-on, back again */
    var w = fr === 0 ? 5 : fr === 2 ? 1 : 3, h = 5 + (z > 1 ? 2 : 0), x0 = x - (w >> 1), y0 = y - (h >> 1);
    if (w === 1) { K.bx(c, x0, y0, 1, h, Hi); K.px(c, x0, y, K.WHITE); return; }
    K.bx(c, x0, y0 + 1, w, h - 2, C); K.bx(c, x0 + 1, y0, w - 2, 1, C); K.bx(c, x0 + 1, y0 + h - 1, w - 2, 1, A);
    K.px(c, x0 + w - 1, y0 + h - 2, A); K.px(c, x, y - 1, Hi); K.px(c, x, y, Hi); K.px(c, x, y + 1, Hi); K.px(c, x0 + 1, y0 + 1, K.WHITE);
  });
  PFA.glyph('L01-curl', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* arctic fox curled into a white ball, tail over the nose, an eye opening, ears pricking */
    var a, w = z > 1 ? 1 : 0;
    for (a = -3 - w; a <= 3 + w; a++) { pt(c, K, x, y, tx, ty, nx, ny, a, 0, C); pt(c, K, x, y, tx, ty, nx, ny, a, 1, C); }
    for (a = -2 - w; a <= 2 + w; a++) pt(c, K, x, y, tx, ty, nx, ny, a, 2, C);
    for (a = -1; a <= 1; a++) pt(c, K, x, y, tx, ty, nx, ny, a, 3, C);
    for (a = -3; a <= 1; a++) pt(c, K, x, y, tx, ty, nx, ny, a, 0, Hi);                    /* the tail wrapped round the front */
    pt(c, K, x, y, tx, ty, nx, ny, -4 - w, 0, A); pt(c, K, x, y, tx, ty, nx, ny, 4 + w, 1, A); pt(c, K, x, y, tx, ty, nx, ny, 2, 0, A);   /* outline flecks, nose over the tail */
    if (fr === 0) pt(c, K, x, y, tx, ty, nx, ny, 2, 2, A); else { pt(c, K, x, y, tx, ty, nx, ny, 2, 2, A); pt(c, K, x, y, tx, ty, nx, ny, 2, 3, K.WHITE); }
    if (fr >= 2) { pt(c, K, x, y, tx, ty, nx, ny, 1, 4, C); pt(c, K, x, y, tx, ty, nx, ny, 2, 4, C); pt(c, K, x, y, tx, ty, nx, ny, 2, 5, A); }
    if (fr === 3) { pt(c, K, x, y, tx, ty, nx, ny, -2, 5, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, -1, 6, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 0, 5, K.WHITE); }
    pt(c, K, x, y, tx, ty, nx, ny, -1, 3, Hi);
  });
  PFA.glyph('L01-jaw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* canine jaws seen head-on: open wide, half, shut, shut with a snap flash; four white fangs */
    var g = fr === 0 ? 3 : fr === 1 ? 2 : 0, gu = (g + 1) >> 1, gl = g >> 1, a, m, b0 = 3, W = 2 + (z > 1 ? 1 : 0);
    for (a = -W - 1; a <= W + 1; a++) { m = Math.abs(a) > W ? 0 : 1;
      pt(c, K, x, y, tx, ty, nx, ny, a, b0 + gu + m, C); pt(c, K, x, y, tx, ty, nx, ny, a, b0 + gu + m + 1, C);
      pt(c, K, x, y, tx, ty, nx, ny, a, b0 - gl - m, C); if (m) pt(c, K, x, y, tx, ty, nx, ny, a, b0 - gl - m - 1, A); }
    if (g) for (a = -1; a <= 1; a++) for (m = b0 - gl; m <= b0 + gu; m++) pt(c, K, x, y, tx, ty, nx, ny, a, m, A);
    pt(c, K, x, y, tx, ty, nx, ny, -W, b0 + gu, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, W, b0 + gu, K.WHITE);
    pt(c, K, x, y, tx, ty, nx, ny, -1, b0 - gl, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 1, b0 - gl, K.WHITE);
    if (fr === 3) { pt(c, K, x, y, tx, ty, nx, ny, -W - 3, b0, Hi); pt(c, K, x, y, tx, ty, nx, ny, W + 3, b0, Hi); pt(c, K, x, y, tx, ty, nx, ny, -W - 2, b0 + 2, Hi); pt(c, K, x, y, tx, ty, nx, ny, W + 2, b0 + 2, Hi); pt(c, K, x, y, tx, ty, nx, ny, 0, b0 + 5, Hi); }
  });
  PFA.glyph('L01-vine', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a bramble cane with a big hooked thorn, a leaf, and a berry ripening on it */
    var a, hk = (fr & 1) ? 1 : -1, L = 2 + (z > 1 ? 1 : 0);
    for (a = -3; a <= 3; a++) pt(c, K, x, y, tx, ty, nx, ny, a, ((a + 4) & 1) * .5, C);
    pt(c, K, x, y, tx, ty, nx, ny, 0, 1, C); for (a = 2; a <= L + 1; a++) pt(c, K, x, y, tx, ty, nx, ny, 0, a, Hi); pt(c, K, x, y, tx, ty, nx, ny, hk, L + 1, Hi);
    pt(c, K, x, y, tx, ty, nx, ny, -2, 1, C); pt(c, K, x, y, tx, ty, nx, ny, -3, 1, C); pt(c, K, x, y, tx, ty, nx, ny, -3, 2, C);
    pt(c, K, x, y, tx, ty, nx, ny, 3, 1, Hi); pt(c, K, x, y, tx, ty, nx, ny, 2, -1, Hi);
    if (fr >= 2) { st(c, K, x, y, tx, ty, nx, ny, 2.5, 2, 2, A); pt(c, K, x, y, tx, ty, nx, ny, 2, 3, Hi); }
  });
  PFA.glyph('L01-howl', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* head thrown back, muzzle to the sky, howl arcs rolling out from it */
    var r, lift = fr > 0 ? 1 : 0;
    st(c, K, x, y, tx, ty, nx, ny, -1, 0, 2 + (z > 1 ? 1 : 0), C); st(c, K, x, y, tx, ty, nx, ny, -.5, 2, 2, C);
    st(c, K, x, y, tx, ty, nx, ny, 0, 4, 3, C); pt(c, K, x, y, tx, ty, nx, ny, -2, 5, C); pt(c, K, x, y, tx, ty, nx, ny, -2, 6, C);
    pt(c, K, x, y, tx, ty, nx, ny, 1, 5 + lift, C); pt(c, K, x, y, tx, ty, nx, ny, 2, 6 + lift, C); pt(c, K, x, y, tx, ty, nx, ny, 3, 7 + lift, A);
    pt(c, K, x, y, tx, ty, nx, ny, 0, 4, A); pt(c, K, x, y, tx, ty, nx, ny, 1, 3, Hi);
    for (r = 1; r <= fr; r++) { pt(c, K, x, y, tx, ty, nx, ny, 4 + r * 1.4, 8 + r * .5, Hi); pt(c, K, x, y, tx, ty, nx, ny, 4 + r, 8 + r, Hi); pt(c, K, x, y, tx, ty, nx, ny, 4 + r * .5, 8 + r * 1.4, Hi); }
  });
  PFA.glyph('L01-elder', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* old wolf face: grey, white muzzle, a scar, ringed by a thick ruff of green thorns */
    var i, a, b, ang, r0 = 4, r1 = 6 + (fr & 1) + (z > 1 ? 1 : 0), ca, sa;
    for (i = 0; i < 9; i++) { ang = Math.PI * (1.05 + i * .1125) + ((fr >> 1) & 1) * .05; ca = Math.cos(ang); sa = Math.sin(ang);
      pt(c, K, x, y, tx, ty, nx, ny, ca * r0, 1 + sa * r0, C); pt(c, K, x, y, tx, ty, nx, ny, ca * (r0 + 1), 1 + sa * (r0 + 1), Hi);
      if (i & 1) pt(c, K, x, y, tx, ty, nx, ny, ca * r1, 1 + sa * r1, Hi); else pt(c, K, x, y, tx, ty, nx, ny, ca * (r1 - 1), 1 + sa * (r1 - 1), Hi); }
    for (a = -2; a <= 2; a++) for (b = -1; b <= 2; b++) pt(c, K, x, y, tx, ty, nx, ny, a, b, C);
    pt(c, K, x, y, tx, ty, nx, ny, -2, 3, C); pt(c, K, x, y, tx, ty, nx, ny, -2, 4, C); pt(c, K, x, y, tx, ty, nx, ny, 2, 3, C); pt(c, K, x, y, tx, ty, nx, ny, 2, 4, C);
    pt(c, K, x, y, tx, ty, nx, ny, -1, -1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 0, -1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 1, -1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 0, -2, A);
    pt(c, K, x, y, tx, ty, nx, ny, -1, 1, A); pt(c, K, x, y, tx, ty, nx, ny, 1, 1, A); pt(c, K, x, y, tx, ty, nx, ny, 2, 2, A); pt(c, K, x, y, tx, ty, nx, ny, 2, 0, A);
    if (fr === 2) { pt(c, K, x, y, tx, ty, nx, ny, -4, 6, Hi); pt(c, K, x, y, tx, ty, nx, ny, 4, 6, Hi); }   /* a loose leaf shaken off */
  });
  PFA.glyph('L01-grump', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* grumpy wolverine face: squat, pale headband, slanted brows, a snarl, grumble scribbles */
    var a, b, w = z > 1 ? 1 : 0, s;
    for (a = -3 - w; a <= 3 + w; a++) for (b = -2; b <= 2; b++) pt(c, K, x, y, tx, ty, nx, ny, a, b, C);
    for (a = -3 - w; a <= 3 + w; a++) pt(c, K, x, y, tx, ty, nx, ny, a, 3, Hi);
    pt(c, K, x, y, tx, ty, nx, ny, -4 - w, 2, Hi); pt(c, K, x, y, tx, ty, nx, ny, 4 + w, 2, Hi); pt(c, K, x, y, tx, ty, nx, ny, -4 - w, 1, Hi); pt(c, K, x, y, tx, ty, nx, ny, 4 + w, 1, Hi);
    pt(c, K, x, y, tx, ty, nx, ny, -3, 4, C); pt(c, K, x, y, tx, ty, nx, ny, 3, 4, C);
    pt(c, K, x, y, tx, ty, nx, ny, -3, 2, A); pt(c, K, x, y, tx, ty, nx, ny, -2, 1, A); pt(c, K, x, y, tx, ty, nx, ny, -1, 1, A);
    pt(c, K, x, y, tx, ty, nx, ny, 3, 2, A); pt(c, K, x, y, tx, ty, nx, ny, 2, 1, A); pt(c, K, x, y, tx, ty, nx, ny, 1, 1, A);
    pt(c, K, x, y, tx, ty, nx, ny, -2, 0, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 2, 0, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 0, -1, A);
    if (fr >= 2) { for (a = -2; a <= 2; a++) pt(c, K, x, y, tx, ty, nx, ny, a, -2, A); pt(c, K, x, y, tx, ty, nx, ny, -1, -2, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 1, -2, K.WHITE); }
    else { pt(c, K, x, y, tx, ty, nx, ny, -1, -2, A); pt(c, K, x, y, tx, ty, nx, ny, 0, -2, A); pt(c, K, x, y, tx, ty, nx, ny, 1, -2, A); }
    if (fr & 1) { s = fr === 1 ? 0 : 1; for (a = -2; a <= 2; a++) pt(c, K, x, y, tx, ty, nx, ny, a + s, 5 + ((a + 2 + s) & 1), Hi); }
  });
  PFA.glyph('L01-shag', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* shaggy fur: thick locks hanging off a root band, a pale band across them, swaying */
    var a, l, j, la, sw = (fr - 1.5) * .35;
    for (a = -4; a <= 4; a++) pt(c, K, x, y, tx, ty, nx, ny, a, 6, C);
    for (l = -1; l <= 1; l++) { la = l * 3;
      for (j = 0; j <= 5; j++) { var o = la + sw * j * .5, col = j === 2 || j === 3 ? Hi : C; pt(c, K, x, y, tx, ty, nx, ny, o, 5 - j, col); pt(c, K, x, y, tx, ty, nx, ny, o + 1, 5 - j, j > 4 ? A : col); }
      if (z > 1) pt(c, K, x, y, tx, ty, nx, ny, la + sw * 3 - 1, 2, C); }
  });
  PFA.glyph('L01-spade', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* badger fore-paw with three long pale digging claws that curl and scoop */
    var a, k, b, cl = fr === 1 ? 1 : fr === 2 ? 2 : 0, L = 4 + (z > 1 ? 1 : 0);
    for (a = -2; a <= 2; a++) { pt(c, K, x, y, tx, ty, nx, ny, a, 0, C); pt(c, K, x, y, tx, ty, nx, ny, a, 1, C); }
    pt(c, K, x, y, tx, ty, nx, ny, -3, 0, A); pt(c, K, x, y, tx, ty, nx, ny, 3, 0, A); pt(c, K, x, y, tx, ty, nx, ny, 0, 0, A);
    for (k = -1; k <= 1; k++) for (b = 2; b <= L + 1; b++) pt(c, K, x, y, tx, ty, nx, ny, k * 2 + (b > L - cl ? (b - (L - cl)) : 0), b - (b > L - cl ? (b - (L - cl)) * .6 : 0), b === L + 1 ? K.WHITE : Hi);
    if (fr === 2) { pt(c, K, x, y, tx, ty, nx, ny, 4, L + 2, A); pt(c, K, x, y, tx, ty, nx, ny, 5, L + 3, A); }
  });
  PFA.glyph('L01-brock', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* old badger face, nose out: white blaze, black stripes through the eyes, grizzled cheeks, a scar on the snout */
    var b, a, v, col, w = z > 1 ? 1 : 0;
    for (b = 0; b < 6; b++) for (a = -3; a <= 3; a++) { v = BROCK[b][a + 3]; if (v < 0) continue; col = v === 2 ? K.WHITE : v === 1 ? A : C; pt(c, K, x, y, tx, ty, nx, ny, a, b, col); }
    if (w) { pt(c, K, x, y, tx, ty, nx, ny, -4, 0, C); pt(c, K, x, y, tx, ty, nx, ny, 4, 0, C); pt(c, K, x, y, tx, ty, nx, ny, -4, 1, C); pt(c, K, x, y, tx, ty, nx, ny, 4, 1, C); }
    pt(c, K, x, y, tx, ty, nx, ny, -4 - w, -1, C); pt(c, K, x, y, tx, ty, nx, ny, 4 + w, -1, C); pt(c, K, x, y, tx, ty, nx, ny, -4 - w, -2, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 4 + w, -2, K.WHITE);
    for (a = -1; a <= 1; a++) pt(c, K, x, y, tx, ty, nx, ny, a, 6, A);
    pt(c, K, x, y, tx, ty, nx, ny, -1, 2, Hi); pt(c, K, x, y, tx, ty, nx, ny, 0, 3, Hi); pt(c, K, x, y, tx, ty, nx, ny, 1, 4, Hi);    /* the old scar across the snout */
    if (fr === 2) { pt(c, K, x, y, tx, ty, nx, ny, 0, 7, A); pt(c, K, x, y, tx, ty, nx, ny, -2, 8, Hi); pt(c, K, x, y, tx, ty, nx, ny, 2, 8, Hi); }   /* a snort */
  });
  PFA.glyph('L01-arch', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a sett entrance: an earth arch round a dark hole, a striped face peering out */
    var a, b, w = z > 1 ? 1 : 0;
    for (b = 0; b <= 2; b++) for (a = 2; a <= 4 + w; a++) { pt(c, K, x, y, tx, ty, nx, ny, -a, b, C); pt(c, K, x, y, tx, ty, nx, ny, a, b, C); }
    for (a = -3; a <= 3; a++) pt(c, K, x, y, tx, ty, nx, ny, a, 3, C); for (a = -2; a <= 2; a++) pt(c, K, x, y, tx, ty, nx, ny, a, 4, C);
    for (b = 0; b <= 2; b++) for (a = -1; a <= 1; a++) pt(c, K, x, y, tx, ty, nx, ny, a, b, A);
    pt(c, K, x, y, tx, ty, nx, ny, -2, 5, Hi); pt(c, K, x, y, tx, ty, nx, ny, 1, 5, Hi); pt(c, K, x, y, tx, ty, nx, ny, 3, 4, Hi);   /* grass on the spoil heap */
    if (fr >= 2) { pt(c, K, x, y, tx, ty, nx, ny, -1, 1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 1, 1, K.WHITE); }
    if (fr === 3) { pt(c, K, x, y, tx, ty, nx, ny, 0, 0, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 0, 1, K.WHITE); pt(c, K, x, y, tx, ty, nx, ny, 0, 2, K.WHITE); }
  });

  /* ---------- motions (mutate the scratch G; pp = time x speed) ---------- */
  PFA.motion('L01-lunge', function (G, pp, k, ph) { var u = (pp * 2 + ph) % 1; if (u < .4) { G.fr = 1; G.d -= 1; } else if (u < .6) { G.fr = 2; G.d += 3; } else G.fr = u < .7 ? 3 : 0; });   /* cock back, lunge open, snap */
  PFA.motion('L01-gallop', function (G, pp, k) { G.s += pp * .35; G.fr = (Math.floor(pp * 14) + k) & 1; if (G.fr) G.up += 1.5; });                                            /* a lope: stretch, gather, lift */
  PFA.motion('L01-cling', function (G, pp, k, ph) { G.fr = Math.floor(pp * 6 + ph * 3) & 1; if ((Math.floor(pp * 20) + k) % 5 === 0) G.t += 1; });                         /* burrs turn and twitch on the fur */
  PFA.motion('L01-swish', function (G, pp, k) { G.fr = (Math.floor(pp * 7) + k) & 3; G.t += Math.sin(pp * 7 + k) * 2; });                                                     /* the brush swishes side to side */
  PFA.motion('L01-arcdive', function (G, pp, k, ph) { var u = (pp * 1.2 + ph) % 1, v = Math.min(1, u / .8);                                                                     /* mousing leap: crouch, arc, dive in */
    G.fr = u < .15 ? 0 : u < .4 ? 1 : u < .55 ? 2 : 3; G.up += Math.sin(v * Math.PI) * 9; G.s += v * .06; if (u > .8) G.d -= 2; });
  PFA.motion('L01-glint', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 10 + ph * 4) + k) & 3; G.t += Math.sin(pp * 3 + k) * .8; });                                      /* the tips catch the light in turn */
  PFA.motion('L01-flip', function (G, pp, k) { G.fr = (Math.floor(pp * 12) + k) & 3; G.up += Math.sin(pp * 6 + k) * 1.5; });                                                  /* coins spin as they go */
  PFA.motion('L01-nestle', function (G, pp, k, ph) { G.fr = Math.floor(pp * 4 + ph * 2) & 3; G.d -= 1; G.up += G.fr === 3 ? 1 : 0; });                                        /* curled tight, an eye and ear show, a shake of snow */
  PFA.motion('L01-chomp', function (G, pp, k) { G.fr = (Math.floor(pp * 9) + k) & 3; });                                                                                     /* open, half, shut, snap */
  PFA.motion('L01-creep', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; G.t += Math.sin(pp * 4 + k) * 1; G.s += pp * .05; });                                  /* the cane creeps on, the berry ripens */
  PFA.motion('L01-howlup', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.5 + ph) % 1) * 4.5)); G.up += G.fr * .5; });                                   /* head goes back, arcs roll out */
  PFA.motion('L01-ruffle', function (G, pp, k) { G.fr = (Math.floor(pp * 12) + k) & 3; G.t += ((Math.floor(pp * 24) + k) & 1) ? 1 : -1; });                               /* the thorn ruff shakes */
  PFA.motion('L01-grumble', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; if (G.fr === 3) G.t += ((Math.floor(pp * 30) + k) & 1) ? 1.5 : -1.5; if (G.fr === 2) G.up += 1; });   /* scowl, scribble, snarl, stamp */
  PFA.motion('L01-sway', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; G.t += Math.sin(pp * 5 + k) * 1; });                                                     /* heavy fur sways */
  PFA.motion('L01-scoop', function (G, pp, k, ph) { var u = (pp * 3 + ph) % 1; G.fr = u < .45 ? 0 : u < .7 ? 1 : u < .85 ? 2 : 3; if (u < .45) G.d -= u * 3; });            /* claws dig down, curl, fling */
  PFA.motion('L01-nod', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; G.up += G.fr & 1; G.s += pp * .04; });                                                    /* a slow old nod and a snort */
  PFA.motion('L01-peek', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.3 + ph) % 1) * 4.5)); G.d = Math.min(G.d, 4 + G.d * .4); });                     /* the hole sits low, a face comes up to look */

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ---------- */
  function carPack(c, e, H) {           /* the alpha's ruffed head leads, two dingoes lope behind it, sand puffing at each footfall */
    var P = e.P, Q = H.Q, k, u, sd = e.d < 0 ? -1 : 1, fr;
    for (k = 2; k >= 1; k--) { u = e.hh - k * .1; if (u < 0) continue; P.atq(e.a + e.d * u); fr = (Math.floor(e.p * 14) + k) & 1;
      H.glyph(c, 'L01-runner', Q.x + Q.nx * 3, Q.y + Q.ny * 3 - fr, e.z > 1 ? 1 : e.z, fr, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
      if (fr === 0) { H.px(c, Q.x + Q.nx * 2 + Q.ny * sd * 7, Q.y + Q.ny * 2 - Q.nx * sd * 7, e.acc); H.px(c, Q.x + Q.nx * 3 + Q.ny * sd * 8, Q.y + Q.ny * 3 - Q.nx * sd * 8 - 1, e.hi); } }
    H.carHead(c, P, e.a + e.d * e.hh, 'L01-dingo', e.z, (Math.floor(e.p * 10) & 1) ? 2 : 3, 0, 0, e.col, e.acc, e.hi);
  }
  function carBrush(c, e, H) {          /* the brush sweeps over to the next piece, leaving a two-tone swish of russet and white */
    var P = e.P, Q = H.Q, k, u, b, sd = e.d < 0 ? -1 : 1;
    for (k = 1; k <= 9; k++) { u = e.hh - k * .028; if (u < 0) break; P.atq(e.a + e.d * u); b = 4 + Math.sin(k * .7 + e.p * 9) * 1.5;
      H.px(c, Q.x + Q.nx * b, Q.y + Q.ny * b, k < 4 ? H.WHITE : e.col); if (k < 7) H.px(c, Q.x + Q.nx * (b + 2), Q.y + Q.ny * (b + 2), k < 3 ? e.hi : e.col); }
    P.atq(e.a + e.d * e.hh); H.glyph(c, 'L01-brush', Q.x + Q.nx * 3, Q.y + Q.ny * 3, e.z, Math.floor(e.p * 14) & 3, e.col, e.acc, e.hi, Q.ny * sd, -Q.nx * sd, Q.nx, Q.ny);
  }
  function carLeap(c, e, H) {           /* one long mousing arc to the next piece: a dotted flight path, the fox on it, a puff where it lands */
    var P = e.P, Q = H.Q, i, u, sd = e.d < 0 ? -1 : 1, fr = e.hh < .25 ? 1 : e.hh < .6 ? 2 : 3;
    for (i = 1; i <= 10; i++) { u = i / 10 * e.hh; if (((i + Math.floor(e.p * 12)) & 1) === 0) continue; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * (4 + Math.sin(u * Math.PI) * 12), Q.y + Q.ny * (4 + Math.sin(u * Math.PI) * 12), e.hi); }
    P.atq(e.a + e.d * e.hh); u = 2 + Math.sin(e.hh * Math.PI) * 12;
    H.glyph(c, 'L01-diver', Q.x + Q.nx * u, Q.y + Q.ny * u, e.z > 1 ? 1 : e.z, fr, e.col, e.acc, e.hi, -Q.ny * sd, Q.nx * sd, Q.nx, Q.ny);
    if (e.p > .78) { P.atq(e.a + e.d); u = (e.p - .78) / .22; H.plus(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, 1 + Math.round(u * 3), 1, e.hi); }
  }
  function carVine(c, e, H) {           /* a bramble cane grows along the outer edge to the next piece, thorns and leaves sprouting as it goes */
    var P = e.P, Q = H.Q, u, i = 0, b;
    for (u = 0; u <= e.hh; u += .02, i++) { P.atq(e.a + e.d * u); b = 4 + Math.sin(i * .9) * 1.5; H.px(c, Q.x + Q.nx * b, Q.y + Q.ny * b, e.col);
      if (i % 6 === 3) H.px(c, Q.x + Q.nx * (b + 2), Q.y + Q.ny * (b + 2), e.hi); else if (i % 9 === 7) { H.px(c, Q.x + Q.nx * (b - 1), Q.y + Q.ny * (b - 1) + 1, e.col); H.px(c, Q.x + Q.nx * (b - 2), Q.y + Q.ny * (b - 2) + 1, e.col); } }
    H.carHead(c, P, e.a + e.d * e.hh, 'L01-vine', e.z, Math.floor(e.p * 8) & 3, 0, 0, e.col, e.acc, e.hi);
  }

  /* ---------- motifs ---------- */
  PFA.motif('ruff-jaw', plain, { nm: 'ruffed jaws', desc: 'a ginger dingo face with a thick neck ruff and a torn ear: it cocks back, lunges with the jaws wide and snaps them shut', fam: 'bite', gap: 18, g: 'L01-dingo', mo: 'L01-lunge', x: 'dust', car: 'custom', carDraw: carPack });
  PFA.motif('lope-file', plain, { nm: 'loping pack', desc: 'lean canines side-on at full lope, legs stretching and gathering, tails streaming, running in file', fam: 'slash', gap: 18, g: 'L01-runner', mo: 'L01-gallop', x: 'dust', car: 'train' });
  PFA.motif('burr-hitch', plain, { nm: 'hooked burrs', desc: 'round seed burrs with eight hooked spikes caught in the fur, turning and twitching', fam: 'thorn', gap: 12, g: 'L01-burr', mo: 'L01-cling', x: '-', car: 'hop' });
  PFA.motif('brush-sweep', plain, { nm: 'fox brushes', desc: 'a thick russet fox brush with a white tip, swishing along the edge, the tip flicking', fam: 'slash', gap: 20, g: 'L01-brush', mo: 'L01-swish', x: '-', car: 'custom', carDraw: carBrush });
  PFA.motif('mousing-arc', plain, { nm: 'mousing dives', desc: 'a fox crouches, arcs high and dives nose-first with its paws together, the classic mousing pounce', fam: 'thrust', gap: 18, g: 'L01-diver', mo: 'L01-arcdive', x: '-', car: 'custom', carDraw: carLeap });
  PFA.motif('silver-tip', plain, { nm: 'silver tips', desc: 'tufts of black guard hairs fanning out, each hair tipped silver, the tips glinting one after another', fam: 'sparkle', gap: 14, g: 'L01-tipfur', mo: 'L01-glint', x: '-', car: 'blink' });
  PFA.motif('toll-penny', plain, { nm: 'toll coins', desc: 'upright coins spinning face, three-quarter, edge-on and back, a glint on the rim', fam: 'sparkle', gap: 12, g: 'L01-coin', mo: 'L01-flip', x: '-', car: 'roll' });
  PFA.motif('snow-curl', function (c, e, H) { comp(c, e, H, decoSnowBank); }, { nm: 'curled snow foxes', desc: 'white foxes curled into balls with the tail over the nose in a heaped snow bank, an eye opening, ears pricking, snow shaken off', fam: 'puff', gap: 16, g: 'L01-curl', mo: 'L01-nestle', x: '-', car: 'roll' });
  PFA.motif('canine-jaws', plain, { nm: 'snapping jaws', desc: 'canine jaws seen head-on, four white fangs, opening wide and snapping shut with a flash', fam: 'bite', gap: 14, g: 'L01-jaw', mo: 'L01-chomp', x: '-', car: 'comet' });
  PFA.motif('briar-vine', function (c, e, H) { comp(c, e, H, decoVine); }, { nm: 'briar canes', desc: 'a bramble cane creeps along the edge with big hooked thorns, leaves and ripening berries', fam: 'thorn', gap: 14, g: 'L01-vine', mo: 'L01-creep', x: '-', car: 'custom', carDraw: carVine });
  PFA.motif('muzzle-howl', plain, { nm: 'howls', desc: 'a head thrown back with the muzzle to the sky, howl arcs rolling out of it one after another', fam: 'ripple', gap: 18, g: 'L01-howl', mo: 'L01-howlup', x: '-', car: 'rings' });
  PFA.motif('thorn-ruff', plain, { nm: 'thorn ruffs', desc: 'a grey old wolf face with a white muzzle and a scar, ringed by a thick ruff of green thorns that shakes and bristles', fam: 'thorn', gap: 18, g: 'L01-elder', mo: 'L01-ruffle', x: '-', car: 'trail' });
  PFA.motif('grump-scowl', plain, { nm: 'grumpy scowls', desc: 'a squat dark face with a pale headband and slanted brows, snarling and stamping, grumble scribbles over its head', fam: 'bash', gap: 16, g: 'L01-grump', mo: 'L01-grumble', x: '-', car: 'zig' });
  PFA.motif('shag-locks', plain, { nm: 'shaggy fur', desc: 'thick locks of fur hanging off a root band with a pale band across them, swaying heavily', fam: 'shield', gap: 14, g: 'L01-shag', mo: 'L01-sway', x: '-', car: 'comet' });
  PFA.motif('badger-claw', plain, { nm: 'digging claws', desc: 'a badger fore-paw with three long pale claws digging in, curling and flinging soil', fam: 'slash', gap: 14, g: 'L01-spade', mo: 'L01-scoop', x: 'clods', car: 'tunnel' });
  PFA.motif('brock-face', plain, { nm: 'old brock faces', desc: 'a wide old badger face, nose out: white blaze, black eye stripes, grizzled cheeks, a scar across the snout, nodding and snorting', fam: 'bash', gap: 18, g: 'L01-brock', mo: 'L01-nod', x: '-', car: 'hop' });
  PFA.motif('sett-hole', plain, { nm: 'sett mouths', desc: 'earth arches round dark holes with grass on the spoil heap, a striped face coming up to peer out', fam: 'shield', gap: 16, g: 'L01-arch', mo: 'L01-peek', x: '-', car: 'tunnel' });
})();
