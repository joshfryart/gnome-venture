/* Motif module, medium batch m09 (horned-viper, rock-viper, vine-snake, camel-calf, outback-dingo, savanna-hyena, striped-hyena, warthog,
   bison-calf-stampede, ratel-pair). TEMPLATE.md section 10.3.
   34 motifs, each with its own pixel glyph (ids prefixed m09-) and its own motion. Every creature has its own signature motif and its own chain
   effect (carDraw): a sand ridge with two horns showing, a rock-blotched viper with pebbles kicked aside, a stiff vine-thin snake bridging the gap,
   a wobbling camel calf leaving two-toed pad prints, a loping dingo in red dust, a spotted hyena carrying a bone, a maned striped hyena dragging one,
   a warthog trotting with its tail up like a flag, three big-headed bison calves thundering in a row, and a ratel pair trotting nose to tail.
   One motif is shared by the two hyenas (bone-snap); the rest are one creature's own.
   The mammals share one side-view routine (quad: torso + four legs in a 4-step gait) so the batch reads as one family of drawings, but every
   animal gets its own head, tail, coat pattern and proportions: spots and a sloping back, stripes and a mane, a grey barrel with tusks, a woolly
   oversized head, a grey-white mantle over a black body. Snakes use one wave routine with three skins (sand saddles, rock blotches, vine-thin).
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation in the frame loops (scratch H.Q / H.G only).
   Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy
   default are untouched. Effects reach at most ~20 px from the edge. */
(function () {
  /* fixed accent colours (not palette tones) */
  var EYE = '#141418', WHITE = '#ffffff', SAND = '#e8d8a8', SANDD = '#b89a68', STONE = '#a09888', STONED = '#5e5850', RDUST = '#d0703c',
    MUD = '#6a4a2a', MUDL = '#94703e', HONEY = '#f0a820', HONEYL = '#ffd870', LEAF = '#62c050', LEAFD = '#3e7a30', BARK = '#7a5030',
    EMBER = '#ff8a3a', HEAT = '#ffd070', CUD = '#a8bc4c', RED = '#d0283c', LICHEN = '#c4d070', BONE = '#f2ead6', BONED = '#b8a88a', DUST = '#c8b090';

  function face(tx, nx, ny) { return Math.abs(nx) > Math.abs(ny) ? (nx > 0 ? 1 : -1) : (tx >= 0 ? 1 : -1); }
  function H0(n) { n = Math.sin(n * 127.1 + 311.7) * 43758.5453; return n - Math.floor(n); }

  /* ---------- shared drawing routines ---------- */
  /* one leg from (X,Y) down len px, the foot swung sideways by sw; knob = knee colour (null = none) */
  function leg(c, K, X, Y, len, sw, col, foot, knob) {
    var i; for (i = 0; i < len; i++) K.px(c, X + (i >= len - 1 ? sw : i >= (len >> 1) ? (sw > 0 ? 1 : sw < 0 ? -1 : 0) * (len > 3 ? 1 : 0) : 0), Y + i, i === len - 1 && foot ? foot : (knob && i === (len >> 1) ? knob : col));
  }
  /* side-view quadruped torso + 4 legs, screen axes, facing fl. L half length, tt extra rows on top, sl 1 = shoulders high / hips low,
     lg leg length, pat 0 plain + pale belly, 1 spots, 2 stripes, 3 mantle (C top, A body), 4 wool front; sock = foot colour (null = leg colour) */
  function quad(c, K, x, y, fl, fr, L, tt, sl, lg, C, A, Hi, pat, sock) {
    var i, Y, t, col, f = fr & 3, sF = f === 0 ? 1 : f === 2 ? -1 : 0;
    for (i = -L; i <= L; i++) {
      t = y - 1 - tt - (sl && i > 0 ? 1 : 0) + (sl && i < -1 ? 1 : 0);
      for (Y = t; Y <= y + 1; Y++) {
        col = C;
        if (pat === 0) { if (Y === y + 1 && i > -L && i < L - 1) col = Hi; }
        else if (pat === 1) { if (Y > t && H0(i * 3.1 + Y * 1.7) < .3) col = A; }
        else if (pat === 2) { if (Y > t && ((i + 9) % 2) === 0) col = A; }
        else if (pat === 3) { col = Y <= t + (i > -L && i < L ? 1 : 0) ? (Y === t && (i & 1) ? Hi : C) : A; }
        else if (pat === 4) { if (i >= 0) col = ((i + Y) & 1) ? A : C; }
        K.px(c, x + fl * i, Y, col);
      }
    }
    /* far legs first (dark), then near legs (main colour) */
    leg(c, K, x + fl * (L - 2), y + 2, lg, -sF * fl, A, null, null); leg(c, K, x - fl * (L - 1), y + 2, lg, sF * fl, A, null, null);
    leg(c, K, x + fl * (L - 1), y + 2, lg, sF * fl, pat === 3 ? A : C, sock, null); leg(c, K, x - fl * L, y + 2, lg, -sF * fl, pat === 3 ? A : C, sock, null);
  }
  /* snake wave along the edge tangent; skin 0 sand saddles, 1 rock blotches, 2 vine-thin (one pixel); returns nothing, head drawn by caller */
  function sn(c, K, x, y, tx, ty, nx, ny, n, amp, ph, C, A, Hi, skin) {
    var i, w, X, Y, a, b;
    for (i = -n; i <= n; i++) { w = Math.sin(i * .7 + ph) * amp * (i < -n + 3 ? .5 : 1); X = x + tx * i + nx * w; Y = y + ty * i + ny * w;
      if (skin === 0) { a = ((i + n) & 3) === 1 ? A : C; b = ((i + n) & 3) === 1 ? A : Hi; }
      else if (skin === 1) { a = H0(i * 3.7) < .3 ? A : H0(i * 1.3 + 5) < .3 ? Hi : C; b = H0(i * 2.9 + 1) < .35 ? A : C; }
      else { a = (i % 4) === 3 ? Hi : C; b = null; }
      K.px(c, X, Y, a); if (b && i > -n + 1) K.px(c, X - nx, Y - ny, b); }
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

  /* ================= glyphs (tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step; fr from the motion) ================= */

  /* --- horned viper --- */
  PFA.glyph('m09-hornsink', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a sand viper shimmying down into the sand (fr 0 coiled on top .. 3 only horns and eyes show) */
    var fl = face(tx, nx, ny), s = fr & 3, top = y + 3 - s, i, Y, hx = x + fl * 4, hy = y - 1 + (s > 1 ? s - 1 : 0), ey;
    for (i = -5; i <= 3; i++) { Y = y + Math.round(Math.sin(i * .9 + s) * 1.2); if (Y < top) K.px(c, x + fl * i, Y, ((i + 5) & 3) === 1 ? A : C); if (Y + 1 < top) K.px(c, x + fl * i, Y + 1, (i & 1) ? C : Hi); }
    if (hy < top) { K.px(c, hx, hy, C); K.px(c, hx + fl, hy, C); K.px(c, hx + fl * 2, hy, A); }
    if (hy + 1 < top) { K.px(c, hx, hy + 1, C); K.px(c, hx + fl, hy + 1, C); }
    for (i = -6 - z; i <= 6 + z; i++) for (Y = top; Y <= y + 3; Y++) K.px(c, x + i, Y, ((i * 7 + Y * 3) & 7) === 0 ? SANDD : SAND);
    ey = Math.min(hy, top) - 1;
    K.px(c, hx + fl, ey + 1, EYE); K.px(c, hx, ey, Hi); K.px(c, hx, ey - 1, Hi); K.px(c, hx + fl * 2, ey, Hi); K.px(c, hx + fl * 2, ey - 1, Hi);
    if (s === 3) { K.px(c, hx - fl, ey + 1, SANDD); K.px(c, hx + fl * 3, ey + 1, SANDD); }
  });
  PFA.glyph('m09-rasp', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* two C-shaped coils rubbing their saw-edged scales together, rasp ticks flying off the open side */
    var fl = face(tx, nx, ny), r = 3 + (z > 1 ? 1 : 0), o = (fr & 1) ? 1 : -1, i, a;
    for (i = 0; i < 12; i++) { a = .7 + i * .44; K.px(c, x + fl * Math.cos(a) * r, y + Math.sin(a) * r * .8, (i & 1) ? A : C);
      K.px(c, x + fl * (Math.cos(a) * (r - 2) + o * .6), y + Math.sin(a) * (r - 2) * .8, (i & 1) ? C : Hi); }
    K.px(c, x + fl * (r - 1), y - r + 1, C); K.px(c, x + fl * r, y - r + 1, C); K.px(c, x + fl * r, y - r, EYE);
    K.px(c, x + fl * (r - 1), y - r, Hi); K.px(c, x + fl * (r - 1), y - r - 1, Hi);
    if (fr & 1) for (i = 0; i < 3; i++) { K.px(c, x + fl * (r + 2), y - 2 + i * 2, Hi); K.px(c, x + fl * (r + 3), y - 3 + i * 2, Hi); }
    else for (i = 0; i < 2; i++) K.px(c, x + fl * (r + 2 + i), y - 1 + i * 2, A);
  });

  /* --- rock viper --- */
  PFA.glyph('m09-scree', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a rock-blotched viper coiled among pebbles, its flat head lifting (fr 1) and tasting the air (fr 2) */
    var fl = face(tx, nx, ny), i, a, hx = x + fl, hy = y - 3 - (fr ? 1 : 0), r = 3.5 + (z > 1 ? .5 : 0);
    K.bx(c, x - 7, y + 1, 3, 2, STONE); K.px(c, x - 7, y + 2, STONED); K.bx(c, x + 5, y + 1, 2, 2, STONE); K.px(c, x + 6, y + 2, STONED); K.px(c, x - 1, y + 3, STONED); K.px(c, x, y + 3, STONE);
    for (i = 0; i < 14; i++) { a = i * .449; K.px(c, x + Math.cos(a) * r, y + Math.sin(a) * r * .68, H0(i * 3.7) < .3 ? A : H0(i * 1.3 + 5) < .3 ? Hi : C);
      K.px(c, x + Math.cos(a) * (r - 1.4), y + Math.sin(a) * (r - 1.4) * .62, (i & 1) ? C : A); }
    for (i = 0; i < 4; i++) K.px(c, hx + fl * i, hy, i === 3 ? A : C);
    for (i = 0; i < 3; i++) K.px(c, hx + fl * i, hy + 1, i === 1 ? Hi : C);
    K.px(c, hx, hy + 2, C); K.px(c, hx + fl * 2, hy, EYE);
    if (fr === 2) { K.px(c, hx + fl * 4, hy + 1, RED); K.px(c, hx + fl * 5, hy, RED); K.px(c, hx + fl * 5, hy + 2, RED); }
  });
  PFA.glyph('m09-ledge', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* three stacked stone slabs like a ledge wall; on fr 2 a flat viper head slides out of the crack */
    var i;
    for (i = -6; i <= 1; i++) { K.px(c, x + i, y - 3, i === -6 ? A : Hi); K.px(c, x + i, y - 2, C); }
    for (i = -3; i <= 5; i++) { K.px(c, x + i, y, i === 5 ? A : (i === -1 ? LICHEN : C)); K.px(c, x + i, y + 1, C); }
    for (i = -5; i <= 3; i++) { K.px(c, x + i, y + 3, C); K.px(c, x + i, y + 4, i & 1 ? A : C); }
    K.px(c, x + 2, y - 2, A); K.px(c, x - 4, y + 1, A); K.px(c, x + 4, y + 4, A); K.px(c, x - 4, y + 3, LICHEN);
    if (fr === 2 || fr === 3) { var o = fr === 3 ? 1 : 0;
      K.px(c, x + 2 + o, y - 1, A); K.px(c, x + 3 + o, y - 1, A); K.px(c, x + 4 + o, y - 1, A); K.px(c, x + 5 + o, y - 1, A); K.px(c, x + 4 + o, y - 1, EYE);
      K.px(c, x + 3 + o, y + 2, A); K.px(c, x + 4 + o, y + 2, A); }
  });
  PFA.glyph('m09-hotscree', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a sun-hot rock glowing at its base, a viper draped over it, heat wiggles rising off in 4 phases */
    var i, j, k;
    for (i = -4; i <= 4; i++) { K.px(c, x + i, y + 1, STONE); K.px(c, x + i, y + 2, (i & 1) ? STONE : STONED); if (Math.abs(i) < 4) K.px(c, x + i, y, STONE); K.px(c, x + i, y + 3, (i + fr) & 1 ? EMBER : HEAT); }
    for (i = -3; i <= 3; i++) K.px(c, x + i, y - 1 + Math.round(Math.sin(i * 1.1 + fr * .4) * .6), H0(i * 2.3) < .35 ? A : (i === 0 ? Hi : C));
    K.px(c, x + 4, y - 1, C); K.px(c, x + 5, y - 1, A); K.px(c, x + 4, y - 2, EYE);
    for (j = 0; j < 3; j++) for (k = 0; k < 3; k++) K.px(c, x - 3 + j * 3 + (((k + fr + j) & 1) ? 1 : 0), y - 3 - k - (fr & 1), k === 0 ? EMBER : HEAT);
  });
  PFA.glyph('m09-satrock', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a flat rock pressed down from above (fr 1), then cracking as the viper under it bites up, white fangs out (fr 2) */
    var d = fr === 1 ? 1 : 0, i;
    for (i = -5; i <= 5; i++) { K.px(c, x + i, y - 1 + d, i === -5 || i === 5 ? A : Hi); K.px(c, x + i, y + d, C); K.px(c, x + i, y + 1 + d, (i & 1) ? C : A); }
    if (fr === 1) { for (i = -3; i <= 3; i++) K.px(c, x + i, y - 3, A); K.px(c, x - 6, y - 1, Hi); K.px(c, x + 6, y - 1, Hi); K.px(c, x - 7, y - 2, Hi); K.px(c, x + 7, y - 2, Hi); }
    if (fr >= 2) { K.px(c, x - 1, y - 1, A); K.px(c, x, y, A); K.px(c, x - 1, y + 1, A); K.px(c, x + 1, y - 2, A);
      K.px(c, x + 5, y - 3, C); K.px(c, x + 6, y - 3, C); K.px(c, x + 7, y - 3, A); K.px(c, x + 6, y - 4, EYE); K.px(c, x + 5, y - 2, C);
      K.px(c, x + 6, y - 2, WHITE); K.px(c, x + 7, y - 1, WHITE); if (fr === 3) { K.px(c, x + 8, y - 5, Hi); K.px(c, x + 9, y - 3, Hi); } }
  });

  /* --- vine snake --- */
  PFA.glyph('m09-vinesway', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a vine-thin green snake held out stiff from the edge like a twig, swaying, pointed snout and keyhole eye, tongue on fr 3 */
    var L = 9 + z * 2, sw = ((fr & 3) - 1.5) * .12, i, o, X = x, Y = y;
    for (i = 0; i <= L; i++) { o = sw * i * i / L; X = x - nx * 2 + nx * i + tx * o; Y = y - ny * 2 + ny * i + ty * o; K.px(c, X, Y, (i % 4) === 3 ? Hi : C); }
    K.px(c, X + nx, Y + ny, C); K.px(c, X + nx * 2, Y + ny * 2, A); K.px(c, X + tx, Y + ty, C);
    K.px(c, X + tx, Y + ty, EYE); K.px(c, X + tx - nx, Y + ty - ny, Hi);
    if ((fr & 3) === 3) { K.px(c, X + nx * 3, Y + ny * 3, A); K.px(c, X + nx * 4 + tx, Y + ny * 4 + ty, A); K.px(c, X + nx * 4 - tx, Y + ny * 4 - ty, A); }
  });
  PFA.glyph('m09-keyhole', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a big golden snake eye with a horizontal keyhole pupil sliding to look (fr 1 / 2), a sighting groove ahead of it */
    var fl = face(tx, nx, ny), o = fr === 1 ? -fl : fr === 2 ? fl : 0, i;
    K.bx(c, x - 4, y - 3, 9, 7, C);
    for (i = -2; i <= 2; i++) { K.px(c, x + i, y - 2, A); K.px(c, x + i, y + 2, A); K.px(c, x + i, y - 1, Hi); K.px(c, x + i, y + 1, Hi); }
    K.px(c, x - 3, y - 1, A); K.px(c, x - 3, y, A); K.px(c, x - 3, y + 1, A); K.px(c, x + 3, y - 1, A); K.px(c, x + 3, y, A); K.px(c, x + 3, y + 1, A);
    for (i = -2; i <= 2; i++) K.px(c, x + i, y, (fr === 3 && Math.abs(i) === 2) ? Hi : EYE);
    K.px(c, x + o, y + 1, EYE); K.px(c, x - 1 + o, y - 1, WHITE);
    for (i = 4; i <= 7; i++) K.px(c, x + fl * i, y - 1 + (i > 5 ? 1 : 0), A);
  });
  PFA.glyph('m09-tendril', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a vine stem with a curled tendril and two leaves; a snake lies along it, its eye showing only on fr 1 / 3 */
    var i, X, Y;
    for (i = -6; i <= 6; i++) K.px(c, x + tx * i, y + ty * i, BARK);
    K.ringpx(c, x + tx * 7 + nx * 2, y + ty * 7 + ny * 2, 1, LEAFD); K.px(c, x + tx * 6 + nx, y + ty * 6 + ny, LEAFD);
    for (i = 0; i < 2; i++) { X = x + tx * (i ? 3 : -3) + nx * 2; Y = y + ty * (i ? 3 : -3) + ny * 2;
      K.px(c, X, Y, LEAF); K.px(c, X + nx, Y + ny, LEAF); K.px(c, X + tx, Y + ty, LEAF); K.px(c, X + nx + tx, Y + ny + ty, LEAFD); K.px(c, X + nx * 2 + tx * ((fr + i) & 1), Y + ny * 2 + ty * ((fr + i) & 1), LEAF); }
    for (i = -5; i <= 4; i++) K.px(c, x + tx * i + nx, y + ty * i + ny, (i % 4) === 2 ? Hi : C);
    K.px(c, x + tx * 5 + nx, y + ty * 5 + ny, C); K.px(c, x + tx * 6 + nx, y + ty * 6 + ny, A);
    if (fr & 1) { K.px(c, x + tx * 5 + nx * 2, y + ty * 5 + ny * 2, EYE); K.px(c, x + tx * 4 + nx * 2, y + ty * 4 + ny * 2, Hi); }
  });

  /* --- camel calf --- */
  PFA.glyph('m09-camel', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a gangly camel calf: fluffy hump, stilt legs with knobbly knees splaying (fr odd), long neck, a long-lashed eye */
    var fl = face(tx, nx, ny), w = fr & 1, i, Y, lg = 4 + (z > 0 ? 1 : 0), hb = w ? 1 : 0, b = y - 2;
    for (i = -3; i <= 2; i++) for (Y = b - 1; Y <= b + 1; Y++) K.px(c, x + fl * i, Y, Y === b - 1 && (i & 1) ? Hi : C);
    K.px(c, x - fl, b - 2, C); K.px(c, x, b - 2, C); K.px(c, x - fl, b - 3, Hi); K.px(c, x, b - 3, (fr & 2) ? Hi : C);
    leg(c, K, x + fl * 1, b + 2, lg, w ? -fl : 0, A, null, null); leg(c, K, x - fl * 2, b + 2, lg, w ? fl : 0, A, null, null);
    leg(c, K, x + fl * 2, b + 2, lg, w ? fl : 0, C, A, A); leg(c, K, x - fl * 3, b + 2, lg, w ? -fl : 0, C, A, A);
    K.px(c, x + fl * 3, b - 1, C); K.px(c, x + fl * 3, b - 2, C); K.px(c, x + fl * 4, b - 3, C); K.px(c, x + fl * 4, b - 4 + hb, C);
    K.px(c, x + fl * 5, b - 5 + hb, C); K.px(c, x + fl * 6, b - 5 + hb, C); K.px(c, x + fl * 7, b - 4 + hb, A); K.px(c, x + fl * 6, b - 4 + hb, C);
    K.px(c, x + fl * 5, b - 6 + hb, EYE); K.px(c, x + fl * 4, b - 7 + hb, Hi); K.px(c, x + fl * 5, b - 7 + hb, Hi);
    K.px(c, x - fl * 4, b - 1, A); K.px(c, x - fl * 4, b, A);
  });
  PFA.glyph('m09-hump', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a fluffy hump mound with knobbly bumps; fluff tufts on top waving (fr) */
    var i, h, Y, w = 4 + (z > 1 ? 1 : 0);
    for (i = -w; i <= w; i++) { h = Math.round(3.5 * Math.sqrt(Math.max(0, 1 - (i / (w + .5)) * (i / (w + .5))))); for (Y = y + 2 - h; Y <= y + 2; Y++) K.px(c, x + i, Y, Y === y + 2 - h ? Hi : C); }
    K.px(c, x - 2, y + 1, A); K.px(c, x + 2, y, A); K.px(c, x + 1, y + 2, A);
    K.px(c, x + ((fr & 1) ? -1 : 1), y - 2, Hi); K.px(c, x + 2 - (fr & 1), y - 1, Hi); K.px(c, x - 2 + ((fr >> 1) & 1), y - 1, Hi);
  });
  PFA.glyph('m09-lash', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a big calf eye with long lashes on a fluffy patch: open, half shut, shut against streaming sand */
    var j, s = fr % 3;
    K.bx(c, x - 4, y - 3, 9, 6, C); K.px(c, x - 4, y - 3, Hi); K.px(c, x + 4, y + 2, Hi);
    if (s === 2) { for (j = -2; j <= 2; j++) K.px(c, x + j, y, A); for (j = -2; j <= 1; j++) { K.px(c, x + j, y + 1, A); K.px(c, x + j - 1, y + 2, A); } }
    else { for (j = -1; j <= 1; j++) { K.px(c, x + j, y - 1, s ? C : A); K.px(c, x + j, y + 1, A); }
      K.px(c, x - 2, y, A); K.px(c, x + 2, y, A); K.px(c, x - 1, y, s ? A : WHITE); K.px(c, x, y, EYE); K.px(c, x + 1, y, EYE);
      for (j = -2; j <= 1; j++) { K.px(c, x + j, y - 2 + s, A); K.px(c, x + j - 1, y - 3 + s, A); } }
    for (j = 0; j < 3; j++) K.px(c, x + 5 - ((fr * 3 + j * 4) % 11), y - 4 + j * 3, SAND);
  });
  PFA.glyph('m09-cud', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* floppy calf lips spitting a green cud blob: pucker, fly with a dribble, splat flat */
    var s = fr & 3, d, i;
    K.px(c, x - tx, y - ty, C); K.px(c, x + tx, y + ty, C); K.px(c, x - nx, y - ny, C); K.px(c, x + nx - tx, y + ny - ty, s ? A : C); K.px(c, x + nx + tx, y + ny + ty, s ? A : C);
    if (s === 1) { K.sq(c, x + nx * 4, y + ny * 4, 2, CUD); K.px(c, x + nx * 2, y + ny * 2, CUD); }
    if (s === 2) { d = 7 + z; K.sq(c, x + nx * d, y + ny * d, 3, CUD); K.px(c, x + nx * d + tx, y + ny * d + ty, Hi); K.px(c, x + nx * 3, y + ny * 3, CUD); K.px(c, x + nx * 5 - tx, y + ny * 5 - ty, CUD); }
    if (s === 3) { d = 10 + z; for (i = -3; i <= 3; i++) K.px(c, x + nx * d + tx * i, y + ny * d + ty * i, (i & 1) ? A : CUD); K.px(c, x + nx * (d - 1), y + ny * (d - 1), CUD);
      K.px(c, x + nx * (d + 1) + tx * 4, y + ny * (d + 1) + ty * 4, CUD); K.px(c, x + nx * (d + 1) - tx * 4, y + ny * (d + 1) - ty * 4, CUD); }
  });

  /* --- outback dingo --- */
  PFA.glyph('m09-dingo', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a lean ginger dingo loping: pale belly and socks, pricked ears, a bushy tail with a white tip */
    var fl = face(tx, nx, ny), f = fr & 3, hb = f === 1 ? -1 : 0;
    quad(c, K, x, y, fl, f, 3, 0, 0, 3, C, A, Hi, 0, Hi);
    K.px(c, x + fl * 4, y - 1 + hb, C); K.px(c, x + fl * 4, y - 2 + hb, C); K.px(c, x + fl * 5, y - 2 + hb, C); K.px(c, x + fl * 5, y - 3 + hb, C);
    K.px(c, x + fl * 6, y - 2 + hb, C); K.px(c, x + fl * 7, y - 2 + hb, Hi); K.px(c, x + fl * 7, y - 1 + hb, Hi); K.px(c, x + fl * 6, y - 3 + hb, EYE);
    K.px(c, x + fl * 4, y - 4 + hb, C); K.px(c, x + fl * 5, y - 4 + hb, A); K.px(c, x + fl * 4, y - 3 + hb, C);
    K.px(c, x - fl * 4, y - 1, C); K.px(c, x - fl * 5, y - (f & 1), C); K.px(c, x - fl * 6, y + 1 - (f & 1), C); K.px(c, x - fl * 6, y - (f & 1), C); K.px(c, x - fl * 7, y + 1 - (f & 1), Hi);
  });
  PFA.glyph('m09-dsnap', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a ginger dingo muzzle in close-up: jaws gape with white teeth (fr 0), snap shut with snap ticks (fr 1) */
    var fl = face(tx, nx, ny), g = fr & 1 ? 0 : 2, i;
    for (i = -3; i <= 3; i++) { K.px(c, x + fl * i, y - 2 - (i < 2 ? g : g - 1), C); K.px(c, x + fl * i, y - 1 - (i < 2 ? g : g - 1), i > 1 ? Hi : C); K.px(c, x + fl * i, y + 1, i > 1 ? Hi : C); K.px(c, x + fl * i, y + 2, C); }
    K.px(c, x + fl * 4, y - 2 - g, A); K.px(c, x - fl * 1, y - 3 - g, EYE); K.px(c, x - fl * 2, y - 4 - g, C); K.px(c, x - fl * 3, y - 5 - g, C); K.px(c, x - fl * 2, y - 5 - g, A);
    if (g) { K.px(c, x + fl * 2, y - 2, WHITE); K.px(c, x + fl * 3, y - 2, WHITE); K.px(c, x + fl * 2, y, WHITE); K.px(c, x + fl * 3, y, WHITE); K.px(c, x + fl * 1, y - 1, RED); }
    else { K.px(c, x + fl * 5, y - 3, Hi); K.px(c, x + fl * 6, y - 1, Hi); K.px(c, x + fl * 5, y + 1, Hi); K.px(c, x + fl * 3, y, WHITE); }
  });
  PFA.glyph('m09-howl', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a sitting dingo, muzzle raised to the sky, howl arcs rising one more per frame */
    var fl = face(tx, nx, ny), i, s = fr & 3;
    for (i = -2; i <= 1; i++) { K.px(c, x + fl * i, y + 1, C); K.px(c, x + fl * i, y + 2, i === 1 ? Hi : C); if (i > -2) K.px(c, x + fl * i, y, C); }
    K.px(c, x - fl * 3, y + 2, C); K.px(c, x - fl * 4, y + 2, Hi); K.px(c, x + fl, y + 3, Hi); K.px(c, x - fl, y + 3, Hi);
    K.px(c, x + fl, y - 1, C); K.px(c, x + fl, y - 2, C); K.px(c, x + fl * 2, y - 3, C); K.px(c, x + fl * 2, y - 2, Hi); K.px(c, x + fl * 3, y - 4, C); K.px(c, x + fl * 3, y - 5, Hi);
    K.px(c, x + fl * 1, y - 3, EYE); K.px(c, x, y - 3, C); K.px(c, x, y - 4, A);
    for (i = 1; i <= s; i++) { K.px(c, x + fl * (3 + i), y - 6 - i * 2, Hi); K.px(c, x + fl * (4 + i), y - 5 - i * 2, Hi); K.px(c, x + fl * (2 + i), y - 6 - i * 2, i === s ? WHITE : Hi); }
  });
  PFA.glyph('m09-dustroll', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a dingo rolling on its back in red dust, paws up on fr odd, a red dust ring around */
    var i, a, s = fr & 3, r = 5 + (z > 1 ? 1 : 0);
    for (i = -3; i <= 3; i++) { K.px(c, x + i, y, C); K.px(c, x + i, y + 1, (i > -2 && i < 2) ? Hi : C); if (Math.abs(i) < 3) K.px(c, x + i, y - 1, C); }
    K.px(c, x + 4, y, C); K.px(c, x + 4, y - 1, EYE); K.px(c, x + 5, y, Hi); K.px(c, x - 4, y + 1, C); K.px(c, x - 5, y + 1, Hi);
    if (s & 1) { K.px(c, x - 1, y - 2, Hi); K.px(c, x + 1, y - 2, Hi); K.px(c, x - 2, y - 3, Hi); K.px(c, x + 2, y - 3, Hi); }
    for (i = 0; i < 10; i++) { a = i * .628 + s * .3; if ((i + s) % 3) K.px(c, x + Math.cos(a) * r, y + 1 + Math.sin(a) * r * .45, i & 1 ? RDUST : DUST); }
  });

  /* --- savanna hyena + striped hyena (bone shared) --- */
  PFA.glyph('m09-spothyena', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a spotted hyena: sloping back, big head with round ears and a dark muzzle, a short dark tail */
    var fl = face(tx, nx, ny), f = fr & 3, hb = (f & 1) ? 1 : 0;
    quad(c, K, x, y, fl, f, 3, 0, 1, 3, C, A, Hi, 1, A);
    K.px(c, x + fl * 4, y - 2 + hb, C); K.px(c, x + fl * 4, y - 1 + hb, C); K.px(c, x + fl * 5, y - 2 + hb, C); K.px(c, x + fl * 5, y - 1 + hb, C); K.px(c, x + fl * 5, y - 3 + hb, C);
    K.px(c, x + fl * 6, y - 1 + hb, A); K.px(c, x + fl * 6, y - 2 + hb, A); K.px(c, x + fl * 7, y - 1 + hb, A); K.px(c, x + fl * 5, y - 2 + hb, EYE);
    K.px(c, x + fl * 4, y - 4 + hb, C); K.px(c, x + fl * 3, y - 4 + hb, A);
    K.px(c, x - fl * 4, y, A); K.px(c, x - fl * 5, y + 1, A);
  });
  PFA.glyph('m09-giggle', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a grinning hyena head, mouth open on a laugh, little "hee" carets bouncing up beside it */
    var fl = face(tx, nx, ny), s = fr & 3, b = (s & 1) ? -1 : 0, i, h;
    for (i = -2; i <= 2; i++) { K.px(c, x + fl * i, y - 2 + b, C); K.px(c, x + fl * i, y - 1 + b, i > 0 ? A : C); K.px(c, x + fl * i, y + 1 + b, i > 0 ? A : C); }
    K.px(c, x - fl * 2, y + b, C); K.px(c, x - fl * 1, y + b, C); K.px(c, x, y + b, RED); K.px(c, x + fl, y + b, WHITE); K.px(c, x + fl * 2, y + b, WHITE);
    K.px(c, x - fl, y - 2 + b, EYE); K.px(c, x - fl * 2, y - 3 + b, C); K.px(c, x - fl * 2, y - 4 + b, A); K.px(c, x - fl * 3, y - 3 + b, C);
    for (i = 0; i < 3; i++) { h = ((s + i) & 3); K.px(c, x + fl * (4 + i * 2), y - 3 - h - i, Hi); K.px(c, x + fl * (3 + i * 2), y - 2 - h - i, Hi); K.px(c, x + fl * (5 + i * 2), y - 2 - h - i, Hi); }
  });
  PFA.glyph('m09-bone', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a knobbed bone across the edge: whole (fr 0), bent and cracking (fr 1), snapped in two with splinters (fr 2 / 3) */
    var s = fr & 3, o = s >= 2 ? 1 + (s - 2) : 0, i, X, Y, L = 3 + (z > 0 ? 1 : 0);
    for (i = -L; i <= L; i++) { if (o && i === 0) continue; X = x + tx * (i + (i > 0 ? o : i < 0 ? -o : 0)); Y = y + ty * (i + (i > 0 ? o : i < 0 ? -o : 0)) + (s === 1 && Math.abs(i) < 2 ? -ny : 0) * (s === 1 ? 1 : 0);
      if (s === 1 && Math.abs(i) < 2) X -= nx; K.px(c, X, Y, BONE); K.px(c, X - nx, Y - ny, Math.abs(i) === L ? BONE : BONED); }
    for (i = -1; i <= 1; i += 2) { X = x + tx * i * (L + 1 + o); Y = y + ty * i * (L + 1 + o); K.px(c, X + nx, Y + ny, BONE); K.px(c, X - nx * 2, Y - ny * 2, BONE); K.px(c, X, Y, BONE); K.px(c, X - nx, Y - ny, BONED); }
    if (s === 1) { K.px(c, x + nx * 2, y + ny * 2, Hi); K.px(c, x, y, A); }
    if (s >= 2) { K.px(c, x + nx * (1 + s), y + ny * (1 + s), BONE); K.px(c, x + tx + nx * (2 + s), y + ty + ny * (2 + s), Hi); K.px(c, x - tx + nx * s, y - ty + ny * s, C); }
  });
  PFA.glyph('m09-stripehyena', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a grey striped hyena, its long black-tipped mane lying flat (fr 0) or raised tall along the back (fr 1 / 2) */
    var fl = face(tx, nx, ny), f = fr & 3, m = f === 0 ? 1 : f === 3 ? 2 : f + 1, i, j, t, hb = (f & 1) ? 1 : 0;
    quad(c, K, x, y, fl, f, 3, 0, 1, 3, C, A, Hi, 2, A);
    for (i = -2; i <= 4; i++) { t = y - 1 - (i > 0 ? 1 : 0) + (i < -1 ? 1 : 0); for (j = 1; j <= m - (i === -2 || i === 4 ? 1 : 0); j++) K.px(c, x + fl * i, t - j, j === m ? A : Hi); }
    K.px(c, x + fl * 4, y - 1 + hb, C); K.px(c, x + fl * 5, y - 1 + hb, C); K.px(c, x + fl * 5, y + hb, C); K.px(c, x + fl * 6, y + hb, A); K.px(c, x + fl * 5, y - 2 + hb, C);
    K.px(c, x + fl * 5, y - 1 + hb, EYE); K.px(c, x + fl * 4, y - 3 + hb, C); K.px(c, x + fl * 4, y - 4 + hb, A);
    K.px(c, x - fl * 4, y, Hi); K.px(c, x - fl * 5, y + 1, A);
  });
  PFA.glyph('m09-crest', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a row of long mane hairs rising out of the edge, grey with black tips, growing as it bristles (fr 0..3) */
    var k, i, h, X, Y;
    for (k = -3; k <= 3; k++) { h = 2 + (fr & 3) + (k & 1) - (Math.abs(k) === 3 ? 1 : 0) + (z > 1 ? 1 : 0);
      for (i = 0; i < h; i++) { X = x + tx * k + nx * (i - 1) + tx * (i > 2 ? (k > 0 ? 1 : k < 0 ? -1 : 0) : 0); Y = y + ty * k + ny * (i - 1) + ty * (i > 2 ? (k > 0 ? 1 : k < 0 ? -1 : 0) : 0);
        K.px(c, X, Y, i === h - 1 ? A : ((k + 9) % 3 === 0 ? Hi : C)); } }
  });

  /* --- warthog --- */
  PFA.glyph('m09-warthog', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a grey warthog trotting: barrel body, flat warty head with upturned tusks, bristle mane, tail straight up with a tuft */
    var fl = face(tx, nx, ny), f = fr & 3, hb = (f & 1) ? 1 : 0, i;
    quad(c, K, x, y, fl, f, 3, 1, 0, 2, C, A, Hi, 0, A);
    for (i = -1; i <= 3; i++) K.px(c, x + fl * i, y - 3 - ((i + f) & 1), Hi);
    K.px(c, x + fl * 4, y - 1 + hb, C); K.px(c, x + fl * 4, y + hb, C); K.px(c, x + fl * 5, y + hb, C); K.px(c, x + fl * 5, y - 1 + hb, A); K.px(c, x + fl * 6, y + hb, C); K.px(c, x + fl * 6, y + 1 + hb, A);
    K.px(c, x + fl * 4, y - 2 + hb, EYE); K.px(c, x + fl * 6, y - 1 + hb, Hi); K.px(c, x + fl * 7, y - 2 + hb, Hi);
    K.px(c, x - fl * 4, y - 2, A); K.px(c, x - fl * 4, y - 3, A); K.px(c, x - fl * 4, y - 4, A); K.px(c, x - fl * (4 + (f >> 1)), y - 5, A); K.px(c, x - fl * (5 - (f >> 1)), y - 5, Hi);
  });
  PFA.glyph('m09-tusk', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a warty warthog face close-up, curved tusks hooking up and out: down (fr 0), hooked up (fr 1), lifted with lift ticks (fr 2) */
    var fl = face(tx, nx, ny), s = fr % 3, u = s ? 1 : 0, i;
    for (i = -3; i <= 2; i++) { K.px(c, x + fl * i, y - 2 - u, C); K.px(c, x + fl * i, y - 1 - u, C); K.px(c, x + fl * i, y - u, i > 0 ? A : C); }
    K.px(c, x + fl * 3, y - 1 - u, A); K.px(c, x + fl * 3, y - u, A); K.px(c, x - fl * 2, y - 3 - u, EYE); K.px(c, x - fl * 1, y - 3 - u, Hi); K.px(c, x, y - 3 - u, Hi);
    K.px(c, x - fl * 3, y - 3 - u, C); K.px(c, x - fl * 3, y - 4 - u, A);
    K.px(c, x + fl * 1, y + 1 - u, Hi); K.px(c, x + fl * 2, y + 1 - u, Hi); K.px(c, x + fl * 3, y - u - (s ? 1 : -1), WHITE); K.px(c, x + fl * 4, y - u - (s ? 2 : 0), WHITE); if (s) K.px(c, x + fl * 4, y - u - 3, WHITE);
    if (s === 2) { K.px(c, x + fl * 6, y - 5, Hi); K.px(c, x + fl * 5, y - 6, Hi); K.px(c, x + fl * 2, y - 6, Hi); }
  });
  PFA.glyph('m09-mud', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a warthog snout shoving mud: the snout at the edge, mud clods flung outward in an arc, further each frame */
    var s = fr & 3, i, d;
    K.px(c, x - nx, y - ny, C); K.px(c, x - nx * 2, y - ny * 2, C); K.px(c, x, y, A); K.px(c, x + tx, y + ty, A); K.px(c, x - tx, y - ty, A); K.px(c, x - nx + tx * 2, y - ny + ty * 2, WHITE);
    for (i = -2; i <= 2; i++) { d = 2 + s * 2 + (i & 1); K.sq(c, x + nx * d + tx * i * (1 + s * .6), y + ny * d + ty * i * (1 + s * .6) + (s > 1 ? 1 : 0), (i === 0 ? 2 : 1) + (s === 0 ? 1 : 0), (i & 1) ? MUDL : MUD); }
    if (s === 3) { K.px(c, x + nx * 9 + tx * 4, y + ny * 9 + ty * 4 + 2, MUD); K.px(c, x + nx * 9 - tx * 4, y + ny * 9 - ty * 4 + 2, MUD); }
  });
  PFA.glyph('m09-wire', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a tuft of long wiry bristles springing out of the edge, tawny forked tips, wart bumps at the base */
    var k, i, h, X, Y, s = fr & 3;
    K.px(c, x - tx * 3 - nx, y - ty * 3 - ny, C); K.px(c, x + tx * 3 - nx, y + ty * 3 - ny, C); K.px(c, x - nx, y - ny, A);
    for (k = -2; k <= 2; k++) { h = 3 + s + (k & 1 ? 0 : 1) - (Math.abs(k) === 2 ? 1 : 0);
      for (i = 0; i < h; i++) { X = x + tx * (k * 1.5 + k * i * .25) + nx * i; Y = y + ty * (k * 1.5 + k * i * .25) + ny * i; K.px(c, X, Y, i >= h - 2 ? Hi : C); }
      K.px(c, X + tx + nx, Y + ty + ny, Hi); K.px(c, X - tx + nx, Y - ty + ny, Hi); }
  });

  /* --- bison calf stampede --- */
  PFA.glyph('m09-bison', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a rust bison calf galloping head-down: shoulder hump, an oversized dark woolly head, horn nubs */
    var fl = face(tx, nx, ny), f = fr & 3, hb = (f & 1) ? 1 : 0, i;
    quad(c, K, x, y, fl, f, 3, 1, 1, 2, C, A, Hi, 4, A);
    for (i = 0; i < 3; i++) { K.px(c, x + fl * (4 + i), y - 2 + hb, A); K.px(c, x + fl * (4 + i), y - 1 + hb, (i & 1) ? C : A); K.px(c, x + fl * (4 + i), y + hb, A); }
    K.px(c, x + fl * 5, y + 1 + hb, A); K.px(c, x + fl * 7, y + hb, C); K.px(c, x + fl * 6, y - 1 + hb, Hi); K.px(c, x + fl * 5, y - 3 + hb, Hi); K.px(c, x + fl * 4, y - 3 + hb, A);
    K.px(c, x - fl * 4, y - 1, A); K.px(c, x - fl * 4, y, A);
  });
  PFA.glyph('m09-headplant', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a huge woolly calf head lowered nose to the ground, front hooves planted, dust kicked from the hooves (fr 2) */
    var fl = face(tx, nx, ny), s = fr % 3, sh = s === 1 ? fl : 0, i, Y;
    for (i = -3; i <= 3; i++) for (Y = -3; Y <= 1; Y++) if (Math.abs(i) + Math.abs(Y + 1) < 5) K.px(c, x + i + sh, y + Y, ((i + Y) & 1) ? A : C);
    K.px(c, x + fl * 3 + sh, y + 1, C); K.px(c, x + fl * 4 + sh, y + 1, A); K.px(c, x + fl * 2 + sh, y - 1, Hi); K.px(c, x + sh - fl * 3, y - 4, Hi); K.px(c, x + sh + fl * 1, y - 4, Hi);
    K.px(c, x - fl * 4 + sh, y - 1, C); K.px(c, x - fl * 5 + sh, y - 2, C); K.px(c, x - fl * 6 + sh, y - 2, C);
    K.px(c, x - fl * 2, y + 2, A); K.px(c, x - fl * 2, y + 3, A); K.px(c, x - fl * 4, y + 2, A); K.px(c, x - fl * 4, y + 3, A);
    if (s === 2) { K.px(c, x - fl * 6, y + 3, DUST); K.px(c, x - fl * 7, y + 2, DUST); K.px(c, x, y + 3, DUST); K.px(c, x - fl * 8, y + 3, DUST); }
  });
  PFA.glyph('m09-hoofdust', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a churned dust cloud blooming, dark hooves and a calf's tail kicking out of it */
    var s = fr & 3, r = 2 + s + (z > 1 ? 1 : 0), i, a;
    for (i = 0; i < 12; i++) { a = i * .524 + s * .2; K.px(c, x + Math.cos(a) * r, y + Math.sin(a) * r * .7, i & 1 ? DUST : Hi); if (i & 1) K.px(c, x + Math.cos(a) * (r - 1.5), y + Math.sin(a) * (r - 1.5) * .7, C); }
    K.px(c, x - 1 + (s & 1), y + r * .7 + 1, A); K.px(c, x - 1 + (s & 1), y + r * .7, A); K.px(c, x + 2 - (s & 1), y + r * .7 + 1, A);
    K.px(c, x - r - 1, y - 1, A); K.px(c, x - r - 2, y - 2 + (s & 1), A);
  });
  PFA.glyph('m09-bellow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a calf head thrown up bellowing, a puff of breath and bellow arcs swelling out of its open mouth */
    var fl = face(tx, nx, ny), s = fr & 3, i, a;
    for (i = -2; i <= 1; i++) { K.px(c, x + fl * i, y, A); K.px(c, x + fl * i, y + 1, (i & 1) ? C : A); K.px(c, x + fl * i, y - 1, A); }
    K.px(c, x + fl * 2, y - 2, A); K.px(c, x + fl * 2, y - 1, C); K.px(c, x + fl * 3, y - 3, C); K.px(c, x + fl * 3, y - 1, C); K.px(c, x + fl * 1, y - 2, Hi); K.px(c, x - fl * 1, y - 2, Hi);
    K.px(c, x + fl * 4, y - 3, Hi); K.px(c, x + fl * 4, y - 2, WHITE);
    for (i = 1; i <= 3; i++) if (i <= s + 1) for (a = -2; a <= 2; a++) K.px(c, x + fl * (4 + i * 2) + (Math.abs(a) === 2 ? -fl : 0), y - 2 + a + (i > 2 && Math.abs(a) > 1 ? (a > 0 ? 1 : -1) : 0), i === s + 1 ? WHITE : Hi);
  });

  /* --- ratel pair --- */
  function ratel(c, K, x, y, fl, f, C, A, Hi) {   /* low long honey badger: a grey-white mantle from crown to tail over a black body, long pale front claws */
    quad(c, K, x, y, fl, f, 4, 1, 0, 2, C, A, Hi, 3, null);
    K.px(c, x + fl * 5, y - 2, C); K.px(c, x + fl * 5, y - 1, C); K.px(c, x + fl * 6, y - 1, Hi); K.px(c, x + fl * 5, y, A); K.px(c, x + fl * 6, y, A); K.px(c, x + fl * 6, y + 1, A); K.px(c, x + fl * 5, y + 1, EYE);
    K.px(c, x + fl * 4, y + 4, Hi); K.px(c, x + fl * 5, y + 4, Hi); K.px(c, x - fl * 5, y - 1, C); K.px(c, x - fl * 5, y, A);
  }
  PFA.glyph('m09-ratel', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* the ratel pair: two honey badgers trotting nose to tail, the rear one bumping along a step behind */
    var fl = face(tx, nx, ny), f = fr & 3;
    ratel(c, K, x - fl * 6, y - 1 + ((f + 1) & 1), fl, f + 1, C, A, Hi);
    ratel(c, K, x + fl * 5, y + (f & 1), fl, f, C, A, Hi);
  });
  PFA.glyph('m09-ratel1', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* chain-only: one ratel (the chain draws the pair one after the other) */
    ratel(c, K, x, y, face(tx, nx, ny), fr & 3, C, A, Hi);
  });
  PFA.glyph('m09-skin', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a ratel twisting round inside its loose skin: the mantle stays put while the black body turns under it, wrinkle folds */
    var s = fr & 3, i, sh = s === 1 ? 1 : s === 3 ? -1 : 0;
    for (i = -5; i <= 5; i++) { K.px(c, x + i, y - 2, (i & 1) ? Hi : C); K.px(c, x + i, y - 1, C); K.px(c, x + i + sh, y, A); K.px(c, x + i + sh, y + 1, A); }
    K.px(c, x - 3, y - 1, A); K.px(c, x + 2, y - 1, A); K.px(c, x - 4, y - 2, A);
    K.px(c, x + 6 + sh, y, A); K.px(c, x + 7 + sh, y, A); K.px(c, x + 6 + sh, y + 1, EYE); K.px(c, x + 6 + sh, y - 1, C);
    K.px(c, x - 3 + sh * 2, y + 2, A); K.px(c, x + 4 + sh * 2, y + 2, A); K.px(c, x + 4 + sh * 2, y + 3, Hi);
    if (s) { K.px(c, x - 6, y - 2 - (s & 1), Hi); K.px(c, x + 7, y - 3 + (s & 1), Hi); }
  });
  PFA.glyph('m09-claw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* three long pale digging claws raking out of the edge on a black paw, soil flecks flying */
    var s = fr & 3, k, i, L = 3 + Math.min(2, s) + (z > 1 ? 1 : 0), X, Y;
    K.px(c, x - nx, y - ny, A); K.px(c, x - nx + tx * 2, y - ny + ty * 2, A); K.px(c, x - nx - tx * 2, y - ny - ty * 2, A); K.px(c, x - nx * 2, y - ny * 2, C);
    for (k = -1; k <= 1; k++) for (i = 0; i < L; i++) { X = x + tx * (k * 2 + (i > L - 2 ? 1 : 0)) + nx * i; Y = y + ty * (k * 2 + (i > L - 2 ? 1 : 0)) + ny * i; K.px(c, X, Y, i === L - 1 ? WHITE : Hi); }
    if (s >= 2) { K.px(c, x + nx * (L + 2) - tx * 3, y + ny * (L + 2) - ty * 3, MUD); K.px(c, x + nx * (L + 3) + tx, y + ny * (L + 3) + ty, MUDL); K.px(c, x + nx * (L + 1) + tx * 4, y + ny * (L + 1) + ty * 4, MUD); }
  });
  PFA.glyph('m09-honeydig', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a torn chunk of wild comb, honey welling and dripping off it, a ratel claw hooked in and two bees buzzing round */
    var s = fr & 3, i, j;
    for (i = -3; i <= 2; i++) for (j = -1; j <= 1; j++) K.px(c, x + i + (j & 1), y + j, ((i + j) & 1) ? HONEYL : HONEY);
    K.px(c, x - 1, y, BONED); K.px(c, x + 1, y - 1, BONED);
    K.px(c, x - 2, y + 2, HONEY); K.px(c, x - 2, y + 2 + (s & 1), HONEY); if (s >= 2) K.px(c, x - 2, y + 3 + s - 1, HONEYL); K.px(c, x + 1, y + 2, HONEY);
    K.px(c, x + 3, y - 2, A); K.px(c, x + 4, y - 2, A); K.px(c, x + 3, y - 1, Hi); K.px(c, x + 2, y - 1, Hi); K.px(c, x + 5, y - 3, C);
    K.px(c, x - 5 + s, y - 4 + (s & 1), EYE); K.px(c, x - 4 + s, y - 4 + (s & 1), HONEY); K.px(c, x + 4 - s, y - 5 - (s & 1), EYE); K.px(c, x + 5 - s, y - 5 - (s & 1), HONEY);
  });

  /* ================= motions (mutate the scratch G; pp = time x speed) ================= */
  PFA.motion('m09-sink', function (G, pp, k, ph) { var w = (pp * 1.3 + ph) % 1; G.fr = w < .25 ? 0 : w < .45 ? 1 : w < .7 ? 2 : 3; G.t += w < .45 ? Math.sin(pp * 30 + k) * .8 : 0; });   /* side-to-side shimmy down */
  PFA.motion('m09-rasp', function (G, pp, k) { G.fr = (Math.floor(pp * 14) + k) & 1; G.t += G.fr ? .6 : -.6; });
  PFA.motion('m09-coil', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; G.fr = w < .45 ? 0 : w < .75 ? 1 : 2; });
  PFA.motion('m09-ledge', function (G, pp, k, ph) { var w = (pp * 1.4 + ph) % 1; G.fr = w < .5 ? 0 : w < .65 ? 2 : w < .85 ? 3 : 2; });
  PFA.motion('m09-heat', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 3; });
  PFA.motion('m09-press', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.fr = w < .3 ? 0 : w < .6 ? 1 : w < .8 ? 2 : 3; G.d += G.fr >= 2 ? 1 : 0; });
  PFA.motion('m09-sway', function (G, pp, k, ph) { G.fr = Math.floor((Math.sin(pp * 5 + ph * 6) + 1) * 1.99); if (((pp * 2 + ph) % 1) > .82) G.fr = 3; });
  PFA.motion('m09-gaze', function (G, pp, k, ph) { var w = (pp * 1.2 + ph) % 1; G.fr = w < .3 ? 0 : w < .5 ? 1 : w < .7 ? 2 : w < .85 ? 0 : 3; });
  PFA.motion('m09-tendril', function (G, pp, k) { G.fr = (Math.floor(pp * 4) + k) & 3; G.t += Math.sin(pp * 6 + k) * .6; });
  PFA.motion('m09-wobble', function (G, pp, k) { var w = Math.sin(pp * 7 + k); G.t += w * 1.2; G.up += Math.abs(w); G.fr = (Math.floor(pp * 7) + k) & 3; });
  PFA.motion('m09-fluff', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 3; });
  PFA.motion('m09-blink', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.fr = (w < .45 ? 0 : w < .55 ? 1 : w < .85 ? 2 : 1) + (Math.floor(pp * 9) & 1 ? 3 : 0); });
  PFA.motion('m09-spit', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.6 + ph) % 1) * 4)); });
  PFA.motion('m09-lope', function (G, pp, k) { G.s += pp * .22; G.fr = (Math.floor(pp * 10) + k) & 3; G.up += G.fr === 1 ? 1 : 0; });
  PFA.motion('m09-snap', function (G, pp, k, ph) { var w = (pp * 2.6 + ph) % 1; G.fr = w < .6 ? 0 : 1; G.d += G.fr ? 2 : 0; });
  PFA.motion('m09-howl', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.1 + ph) % 1) * 4.5)); });
  PFA.motion('m09-roll', function (G, pp, k) { G.fr = (Math.floor(pp * 7) + k) & 3; G.t += (G.fr & 1) ? 1 : -1; });
  PFA.motion('m09-hlope', function (G, pp, k) { G.s += pp * .18; G.fr = (Math.floor(pp * 8) + k) & 3; G.up += (G.fr & 1); });
  PFA.motion('m09-giggle', function (G, pp, k) { G.fr = (Math.floor(pp * 12) + k) & 3; G.up += (G.fr & 1); });
  PFA.motion('m09-crunch', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; G.fr = w < .4 ? 0 : w < .55 ? 1 : w < .8 ? 2 : 3; });
  PFA.motion('m09-mane', function (G, pp, k, ph) { var w = (pp * 1.2 + ph) % 1; G.fr = w < .25 ? 0 : w < .45 ? 1 : 2; G.s += pp * .05; });
  PFA.motion('m09-crest', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.3 + ph * .5) % 1) * 5)); });
  PFA.motion('m09-trot', function (G, pp, k) { G.s += pp * .26; G.fr = (Math.floor(pp * 14) + k) & 3; G.up += (G.fr & 1); });
  PFA.motion('m09-hook', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .45 ? 0 : w < .7 ? 1 : 2; G.d += G.fr === 1 ? 2 : 0; });
  PFA.motion('m09-fling', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.8 + ph) % 1) * 4)); });
  PFA.motion('m09-bristle', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.2 + ph * .4) % 1) * 5)); G.t += (Math.floor(pp * 16) & 1) ? .5 : -.5; });
  PFA.motion('m09-gallop', function (G, pp, k) { G.s += pp * .3; G.fr = (Math.floor(pp * 12) + k) & 3; G.up += G.fr === 1 ? 2 : G.fr === 2 ? 1 : 0; });
  PFA.motion('m09-plant', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.fr = w < .4 ? 0 : w < .7 ? 1 : 2; });
  PFA.motion('m09-churn', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.8 + ph) % 1) * 4)); G.t += Math.sin(pp * 9 + k) * .8; });
  PFA.motion('m09-bellow', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.2 + ph) % 1) * 4.4)); });
  PFA.motion('m09-pair', function (G, pp, k) { G.s += pp * .2; G.fr = (Math.floor(pp * 10) + k) & 3; });
  PFA.motion('m09-twist', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; });
  PFA.motion('m09-rake', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 2.2 + ph) % 1) * 4)); });
  PFA.motion('m09-honey', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; });

  /* ================= custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ================= */
  /* head glyph at distance s, facing the way of travel on the top / bottom edges (screen-axis animals) */
  function head(c, e, H, s, g, fr, oy) {
    var Q = H.Q, sg = e.d >= 0 ? 1 : -1; e.P.atq(s);
    H.glyph(c, g, Q.x + Q.nx * 5, Q.y + Q.ny * 5 + oy, e.z, fr, e.col, e.acc, e.hi, -Q.ny * sg, Q.nx * sg, Q.nx, Q.ny);
    return face(-Q.ny * sg, Q.nx, Q.ny);
  }
  /* snakes: kind 1 = sand ridge with horns (horned viper), 2 = rock-blotched body with pebbles (rock viper), 3 = vine-thin stiff body (vine snake) */
  function snakeCar(kind) {
    return function (c, e, H) {
      var P = e.P, Q = H.Q, D = Math.max(24, Math.abs(e.d)), st = 1.2 / D, sg = e.d >= 0 ? 1 : -1, k, u, w, X, Y, tx, ty, n = kind === 3 ? 24 : 16 + e.z * 2, a;
      for (k = n; k >= 0; k--) { u = e.hh - k * st; if (u < 0) continue; P.atq(e.a + e.d * u);
        if (kind === 1) { X = Q.x + Q.nx * 4; Y = Q.y + Q.ny * 4; H.px(c, X, Y, k < 5 ? SAND : (k & 1) ? SANDD : SAND); if (k < 9) H.px(c, X + Q.nx, Y + Q.ny, k < 3 ? SANDD : SAND); continue; }
        w = Math.sin(k * .55 - e.p * 20) * (kind === 3 ? .4 : 1.4) * (k < 2 ? .3 : 1); X = Q.x + Q.nx * (5 + w); Y = Q.y + Q.ny * (5 + w);
        if (kind === 2) { a = H0(k * 3.7) < .3 ? e.acc : H0(k * 1.3 + 5) < .3 ? e.hi : e.col; H.px(c, X, Y, a); if (k < n - 1) H.px(c, X - Q.nx, Y - Q.ny, H0(k * 2.9 + 1) < .35 ? e.acc : e.col);
          if ((k % 7) === 5 && k > 3) { H.px(c, X + Q.nx * 3 - Q.ny * 2, Y + Q.ny * 3 + Q.nx * 2, STONE); H.px(c, X + Q.nx * 4 - Q.ny * 2, Y + Q.ny * 4 + Q.nx * 2, STONED); } }
        else H.px(c, X, Y, (k % 4) === 3 ? e.hi : e.col); }
      P.atq(e.a + e.d * e.hh); tx = -Q.ny * sg; ty = Q.nx * sg;
      if (kind === 1) { X = Q.x + Q.nx * 5 + tx; Y = Q.y + Q.ny * 5 + ty;
        H.px(c, X, Y, EYE); H.px(c, X - tx + Q.nx, Y - ty + Q.ny, e.hi); H.px(c, X - tx + Q.nx * 2, Y - ty + Q.ny * 2, e.hi); H.px(c, X + tx + Q.nx, Y + ty + Q.ny, e.hi); H.px(c, X + tx + Q.nx * 2, Y + ty + Q.ny * 2, e.hi);
        if (Math.floor(e.p * 12) & 1) H.px(c, X + tx * 3 + Q.nx, Y + ty * 3 + Q.ny, SANDD); return; }
      X = Q.x + Q.nx * 5; Y = Q.y + Q.ny * 5;
      if (kind === 2) { H.px(c, X + tx, Y + ty, e.col); H.px(c, X + tx * 2, Y + ty * 2, e.col); H.px(c, X + tx + Q.nx, Y + ty + Q.ny, e.col); H.px(c, X + tx - Q.nx, Y + ty - Q.ny, e.col);
        H.px(c, X + tx * 3, Y + ty * 3, e.acc); H.px(c, X + tx * 2 + Q.nx, Y + ty * 2 + Q.ny, EYE);
        if (Math.floor(e.p * 10) % 3 === 0) { H.px(c, X + tx * 4, Y + ty * 4, RED); H.px(c, X + tx * 5 + Q.nx, Y + ty * 5 + Q.ny, RED); } }
      else { H.px(c, X + tx, Y + ty, e.col); H.px(c, X + tx * 2, Y + ty * 2, e.col); H.px(c, X + tx * 3, Y + ty * 3, e.acc); H.px(c, X + tx + Q.nx, Y + ty + Q.ny, EYE); H.px(c, X + Q.nx, Y + Q.ny, e.hi); }
    };
  }
  /* walking animals: kind 1 camel (two-toed pads), 2 dingo (red dust), 3 savanna hyena (carries a bone), 4 striped hyena (drags a bone),
     5 warthog (tail-up trot, hoof dots), 6 bison (three calves + dust), 7 ratel (pair + claw scratches) */
  function walker(g, kind) {
    return function (c, e, H) {
      var P = e.P, Q = H.Q, f = Math.floor(e.p * 12) & 3, k, u, X, Y, fl, s = e.a + e.d * e.hh, i;
      for (k = 1; k < 8; k++) { u = k / 8 * e.hh * .92; if (e.hh < .08) break; P.atq(e.a + e.d * u); X = Q.x + Q.nx * (3 + (k & 1)); Y = Q.y + Q.ny * (3 + (k & 1));
        if (kind === 1) { H.px(c, X - 1, Y, e.acc); H.px(c, X + 1, Y, e.acc); }
        else if (kind === 2) { H.px(c, X, Y, e.acc); H.px(c, X - 1, Y - 1, e.acc); H.px(c, X + 1, Y - 1, e.acc); if (k > 5 && ((k + f) & 1)) H.px(c, X + Q.nx * 3, Y + Q.ny * 3 - 1, RDUST); }
        else if (kind === 3 || kind === 4) { H.px(c, X, Y, e.acc); H.px(c, X, Y - 1, e.acc); }
        else if (kind === 5) { if (k & 1) { H.px(c, X, Y, e.acc); H.px(c, X + 1, Y, e.acc); } }
        else if (kind === 6) { if (k > 3) { H.px(c, X + ((k + f) & 1), Y - 1, DUST); H.px(c, X + Q.nx * 2, Y + Q.ny * 2 - ((k + f) & 1), DUST); H.px(c, X - 1, Y, e.acc); } }
        else if (kind === 7) { if (k & 1) for (i = -1; i <= 1; i++) { H.px(c, X - Q.ny * i * 2, Y + Q.nx * i * 2, e.hi); H.px(c, X - Q.ny * i * 2 + Q.nx, Y + Q.nx * i * 2 + Q.ny, e.acc); } } }
      if (kind === 2 && e.hh > .1) { P.atq(e.a + e.d * (e.hh - .06)); for (i = 0; i < 5; i++) H.px(c, Q.x + Q.nx * (5 + (i & 1) * 2) + ((i * 3 + f) % 5) - 2, Q.y + Q.ny * (5 + (i & 1) * 2) - (i >> 1), i & 1 ? RDUST : DUST); }
      if (kind === 4 && e.hh > .12) { P.atq(e.a + e.d * (e.hh - .1)); H.glyph(c, 'm09-bone', Q.x + Q.nx * 3, Q.y + Q.ny * 3, 0, 0, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
        for (u = e.hh - .13; u > Math.max(0, e.hh - .4); u -= .03) { P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, BONED); } }
      if (kind === 6) { if (e.hh > .2) head(c, e, H, e.a + e.d * (e.hh - .18), g, (f + 2) & 3, -((f + 1) & 1));
        if (e.hh > .1) head(c, e, H, e.a + e.d * (e.hh - .09), g, (f + 1) & 3, -(f & 1)); }
      if (kind === 7 && e.hh > .1) head(c, e, H, e.a + e.d * (e.hh - .08), g, (f + 1) & 3, -((f + 1) & 1));
      fl = head(c, e, H, s, g, f, kind === 1 ? -(f & 1) : kind === 5 ? -((f >> 1) & 1) : -(f === 1 ? 1 : 0));
      if (kind === 3) { P.atq(s); H.glyph(c, 'm09-bone', Q.x + Q.nx * 5 + fl * 9, Q.y + Q.ny * 5, 0, 0, e.col, e.acc, e.hi, 1, 0, 0, -1); }
    };
  }

  /* ================= motifs ================= */
  function M(name, meta) { PFA.motif(name, comp, meta); }
  /* horned viper */
  M('horn-sink', { nm: 'sinking horned vipers', desc: 'sand vipers shimmying side to side down into the sand until only the two little horns and the eyes show; the chain is a sand ridge running under the sand with the horns poking up', fam: 'thrust', gap: 18, g: 'm09-hornsink', mo: 'm09-sink', x: '-', car: 'custom', carDraw: snakeCar(1) });
  M('scale-rasp', { nm: 'rasping coils', desc: 'C-shaped coils rubbing their saw-edged scales together, rasp ticks flying off the open side', fam: 'shock', gap: 14, g: 'm09-rasp', mo: 'm09-rasp', x: '-', car: 'zig' });
  /* rock viper */
  M('scree-viper', { nm: 'scree vipers', desc: 'rock-blotched grey vipers coiled among pebbles, the flat head lifting to taste the air; the chain slithers a blotched body along the edge, pebbles kicked aside', fam: 'bash', gap: 18, g: 'm09-scree', mo: 'm09-coil', x: '-', car: 'custom', carDraw: snakeCar(2) });
  M('ledge-slab', { nm: 'ledge slabs', desc: 'three stacked stone slabs like a ledge wall with lichen flecks, a flat viper head sliding out of the crack', fam: 'shield', gap: 16, g: 'm09-ledge', mo: 'm09-ledge', x: '-', car: 'train' });
  M('hot-scree', { nm: 'hot rocks', desc: 'sun-hot rocks glowing at the base with a viper draped over them, heat wiggles rising', fam: 'ember', gap: 14, g: 'm09-hotscree', mo: 'm09-heat', x: '-', car: 'trail' });
  M('sat-rock', { nm: 'sat-upon rocks', desc: 'a flat rock pressed down from above, then cracking as the viper hidden under it bites up, white fangs out', fam: 'bash', gap: 18, g: 'm09-satrock', mo: 'm09-press', x: '-', car: 'hop' });
  /* vine snake */
  M('vine-sway', { nm: 'vine snakes', desc: 'vine-thin green snakes held out stiff from the edge like twigs, swaying in a breeze, pointed snout and keyhole eye, a tongue flick; the chain is a thin stiff body bridging the gap', fam: 'thrust', gap: 12, g: 'm09-vinesway', mo: 'm09-sway', x: '-', car: 'custom', carDraw: snakeCar(3) });
  M('keyhole-gaze', { nm: 'keyhole eyes', desc: 'big golden snake eyes with a horizontal keyhole pupil sliding to look, a sighting groove ahead', fam: 'shock', gap: 14, g: 'm09-keyhole', mo: 'm09-gaze', x: '-', car: 'blink' });
  M('tendril-hide', { nm: 'tendril hides', desc: 'vine stems with curled tendrils and leaves; a thin snake lies along each, its eye showing now and then', fam: 'leaf', gap: 16, g: 'm09-tendril', mo: 'm09-tendril', x: '-', car: 'thread' });
  /* camel calf */
  M('calf-wobble', { nm: 'wobbly camel calves', desc: 'gangly camel calves with fluffy humps, stilt legs and knobbly knees splaying as they wobble; the chain wobble-walks leaving two-toed pad prints', fam: 'bash', gap: 20, g: 'm09-camel', mo: 'm09-wobble', x: '-', car: 'custom', carDraw: walker('m09-camel', 1) });
  M('hump-fluff', { nm: 'fluffy humps', desc: 'fluffy hump mounds with knobbly bumps, fluff tufts waving on top', fam: 'shield', gap: 14, g: 'm09-hump', mo: 'm09-fluff', x: '-', car: 'train' });
  M('lash-blink', { nm: 'lash blinks', desc: 'big calf eyes with long lashes closing against streaming sand', fam: 'puff', gap: 14, g: 'm09-lash', mo: 'm09-blink', x: '-', car: 'blink' });
  M('cud-spit', { nm: 'cud spit', desc: 'floppy lips spitting a green cud blob that flies with a dribble and splats flat', fam: 'drip', gap: 14, g: 'm09-cud', mo: 'm09-spit', x: '-', car: 'comet' });
  /* outback dingo */
  M('dingo-lope', { nm: 'loping dingoes', desc: 'lean ginger dingoes with pale socks, pricked ears and white-tipped bushy tails, loping; the chain lopes along in a puff of red dust, paw prints behind', fam: 'slash', gap: 20, g: 'm09-dingo', mo: 'm09-lope', x: '-', car: 'custom', carDraw: walker('m09-dingo', 2) });
  M('dingo-snap', { nm: 'dingo snaps', desc: 'a ginger muzzle in close-up gaping with white teeth, then snapping shut with snap ticks', fam: 'bite', gap: 14, g: 'm09-dsnap', mo: 'm09-snap', x: '-', car: 'comet' });
  M('howl-rise', { nm: 'howls', desc: 'sitting dingoes with muzzles raised, howl arcs rising one after another', fam: 'ripple', gap: 16, g: 'm09-howl', mo: 'm09-howl', x: '-', car: 'rings' });
  M('red-dust-roll', { nm: 'red dust rolls', desc: 'a dingo rolling on its back in red dust, paws up, a ring of red dust around', fam: 'puff', gap: 16, g: 'm09-dustroll', mo: 'm09-roll', x: '-', car: 'roll' });
  /* savanna hyena */
  M('spot-lope', { nm: 'spotted hyenas', desc: 'spotted hyenas with sloping backs, big round-eared heads and dark muzzles, loping; the chain lopes along carrying a bone, paw prints behind', fam: 'slash', gap: 20, g: 'm09-spothyena', mo: 'm09-hlope', x: '-', car: 'custom', carDraw: walker('m09-spothyena', 3) });
  M('giggle-burst', { nm: 'hyena giggles', desc: 'grinning hyena heads with mouths open on a laugh, little hee carets bouncing up beside them', fam: 'shock', gap: 16, g: 'm09-giggle', mo: 'm09-giggle', x: '-', car: 'zig' });
  M('bone-snap', { nm: 'bone snaps', desc: 'knobbed bones bending, cracking and snapping in two with splinters (hyenas crush bone)', fam: 'bite', gap: 14, g: 'm09-bone', mo: 'm09-crunch', x: '-', car: 'comet' });
  /* striped hyena */
  M('mane-raise', { nm: 'maned striped hyenas', desc: 'grey striped hyenas whose long black-tipped mane rises tall along the back, doubling their size; the chain trots along dragging a bone, a drag line behind', fam: 'bash', gap: 20, g: 'm09-stripehyena', mo: 'm09-mane', x: '-', car: 'custom', carDraw: walker('m09-stripehyena', 4) });
  M('mane-crest', { nm: 'mane crests', desc: 'rows of long grey mane hairs with black tips rising out of the edge as they bristle', fam: 'thorn', gap: 12, g: 'm09-crest', mo: 'm09-crest', x: '-', car: 'train' });
  /* warthog */
  M('tail-trot', { nm: 'tail-up warthogs', desc: 'grey barrel warthogs with warty heads, upturned tusks and a bristle mane, trotting with the tail straight up and its tuft flicking; the chain trots with the tail flag up', fam: 'bash', gap: 20, g: 'm09-warthog', mo: 'm09-trot', x: '-', car: 'custom', carDraw: walker('m09-warthog', 5) });
  M('tusk-hook', { nm: 'tusk hooks', desc: 'a warty face close-up, curved tusks hooking up and out, then lifting with lift ticks', fam: 'thrust', gap: 14, g: 'm09-tusk', mo: 'm09-hook', x: '-', car: 'comet' });
  M('mud-fling', { nm: 'mud flings', desc: 'a snout shoving mud, clods flung outward in a widening arc', fam: 'drip', gap: 14, g: 'm09-mud', mo: 'm09-fling', x: '-', car: 'hop' });
  M('wire-bristle', { nm: 'wire bristles', desc: 'tufts of long wiry bristles springing out of the edge with tawny forked tips, wart bumps at the base', fam: 'thorn', gap: 12, g: 'm09-wire', mo: 'm09-bristle', x: '-', car: 'train' });
  /* bison calf stampede */
  M('calf-stampede', { nm: 'stampeding bison calves', desc: 'rust bison calves galloping head-down with shoulder humps and oversized woolly heads; the chain is three calves thundering in a row with a dust cloud behind', fam: 'bash', gap: 20, g: 'm09-bison', mo: 'm09-gallop', x: '-', car: 'custom', carDraw: walker('m09-bison', 6) });
  M('head-plant', { nm: 'head plants', desc: 'a huge woolly calf head lowered nose to the ground, front hooves planted, dust kicked up', fam: 'shield', gap: 16, g: 'm09-headplant', mo: 'm09-plant', x: '-', car: 'roll' });
  M('hoof-dust', { nm: 'hoof dust', desc: 'churned dust clouds blooming with dark hooves and a tail kicking out of them', fam: 'puff', gap: 14, g: 'm09-hoofdust', mo: 'm09-churn', x: '-', car: 'cloud' });
  M('bellow-call', { nm: 'bellows', desc: 'calf heads thrown up bellowing, a breath puff and bellow arcs swelling out of the open mouth', fam: 'ripple', gap: 16, g: 'm09-bellow', mo: 'm09-bellow', x: '-', car: 'rings' });
  /* ratel pair */
  M('ratel-duo', { nm: 'ratel pairs', desc: 'two honey badgers, grey-white mantle over a black body, trotting nose to tail; the chain is the pair trotting one after the other leaving claw scratches', fam: 'bash', gap: 24, g: 'm09-ratel', mo: 'm09-pair', x: '-', car: 'custom', carDraw: walker('m09-ratel1', 7) });
  M('loose-skin', { nm: 'loose skins', desc: 'a ratel twisting round inside its loose skin, the mantle staying put while the black body turns under it', fam: 'shield', gap: 16, g: 'm09-skin', mo: 'm09-twist', x: '-', car: 'train' });
  M('dig-claw', { nm: 'digging claws', desc: 'three long pale digging claws raking out of the edge on a black paw, soil flecks flying', fam: 'slash', gap: 12, g: 'm09-claw', mo: 'm09-rake', x: '-', car: 'comet' });
  M('honey-dig', { nm: 'honey digs', desc: 'torn chunks of wild comb with honey welling and dripping, a ratel claw hooked in, bees buzzing round', fam: 'mend', gap: 14, g: 'm09-honeydig', mo: 'm09-honey', x: '-', car: 'trail' });
})();
