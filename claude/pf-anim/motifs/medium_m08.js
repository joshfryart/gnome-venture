/* Motif module, medium batch m08 (beaded-lizard, tree-monitor, water-monitor, spice-monitor, komodo-pup, smooth-snake, water-snake, tree-snake,
   night-adder, dust-sidewinder, dune-racer). TEMPLATE.md section 10.3.
   35 motifs, each with its own pixel glyph (ids prefixed m08-) and, where the built-in ones did not fit, its own motion. Every creature has its own
   signature motif; seven of them bring their own chain effect (carDraw: plodding beaded lizard, monitor climbing a branch, swimming monitor with a
   V wake, komodo pup scampering with its tongue out, a slithering snake body in four patterns, sidewinder J-tracks). Four batch motifs are shared
   by close relatives with their own palettes (forked tongue, venom fangs, scale shingles, venom spit).
   Lizards are drawn by one procedural side-view routine (liz) and snakes by one wave routine along the edge tangent (snk), so the batch shares a look
   but every creature gets its own pattern: beads, clove spots, sand spots, smooth gloss, olive bands, zigzag back, pale racing stripes.
   Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation in the frame loops (scratch H.Q / H.G only).
   Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule, visual-only sound lines and the creature-heavy
   default are untouched. */
(function () {
  /* fixed accent colours (not palette tones): 4 white, 5 dew, 6 dark leaf, 7 red, 8 tongue yellow, 9 stone, 10 bark, 11 venom green, 12 leaf,
     13 eye black, 14 red-eye glow, 15 mud, 16 pale sand, 17 asphalt */
  var XC = [null, null, null, null, '#ffffff', '#cfeeff', '#3e7a30', '#d0283c', '#f2d43a', '#a09888', '#7a5030', '#c4ec5a', '#62c050', '#141418', '#ff5040', '#6a5236', '#e8d8a8', '#34302e'];

  function face(tx, nx, ny) { return Math.abs(nx) > Math.abs(ny) ? (nx > 0 ? 1 : -1) : (tx >= 0 ? 1 : -1); }
  function H0(n) { n = Math.sin(n * 127.1 + 311.7) * 43758.5453; return n - Math.floor(n); }

  /* side-view lizard (screen axes, facing fl): pat 0 plain gloss, 1 beads, 2 clove spots, 3 sand spots; tl tail length, tw tail swing, th thick tail */
  function liz(c, K, x, y, fl, fr, C, A, Hi, pat, tl, tw, th) {
    var i, X, Y, b, f = fr & 1;
    for (i = -3; i <= 3; i++) { X = x + fl * i;
      b = pat === 1 ? ((i & 1) ? A : C) : pat === 2 ? (i === -2 || i === 1 ? A : i === 3 ? Hi : C) : pat === 3 ? (i === -1 || i === 2 ? A : i === 0 ? Hi : C) : (i === 0 ? Hi : C);
      K.px(c, X, y - 1, b); K.px(c, X, y, pat === 1 ? ((i & 1) ? C : A) : C); if (i > -3 && i < 3) K.px(c, X, y + 1, C); }
    for (i = 4; i <= 6; i++) K.px(c, x + fl * i, y - 1, C);
    for (i = 4; i <= 7; i++) K.px(c, x + fl * i, y, i === 7 ? A : C);
    K.px(c, x + fl * 6, y - 1, XC[13]); K.px(c, x + fl * 5, y - 2, pat === 1 ? A : C);
    K.px(c, x + fl * (2 + f), y + 2, A); K.px(c, x + fl * (3 + f), y + 2, A); K.px(c, x - fl * (2 - f), y + 2, A); K.px(c, x - fl * (3 - f), y + 2, A);
    for (i = 1; i <= tl; i++) { X = x - fl * (3 + i); Y = y + Math.round(Math.sin(i * .55 + fr * 1.3) * tw * i / tl);
      K.px(c, X, Y, pat === 1 ? (((i >> 1) & 1) ? A : C) : pat === 0 && (i % 3) === 2 ? A : C); if (i <= th) K.px(c, X, Y - 1, pat === 1 && (i & 1) ? C : pat === 1 ? A : C); }
  }
  /* snake wave along the edge tangent (tx,ty), normal (nx,ny): n half length, amp wave, ph phase; pat 0 smooth gloss, 1 olive bands, 2 zigzag back,
     3 racing stripe, 4 plain green; eye colour E; raised head when up > 0 */
  function snk(c, K, x, y, tx, ty, nx, ny, n, amp, ph, C, A, Hi, pat, E, up) {
    var i, w, X, Y, a, b, h;
    for (i = -n; i <= n; i++) { w = Math.sin(i * .75 + ph) * amp * (i < -n + 3 ? .6 : 1); X = x + tx * i + nx * w; Y = y + ty * i + ny * w;
      if (pat === 1) { a = ((i + n) >> 1) & 1 ? A : C; b = a; }
      else if (pat === 2) { a = (i & 1) ? A : C; b = (i & 1) ? C : A; }
      else if (pat === 3) { a = Hi; b = A; }
      else if (pat === 0) { a = (i % 4) === 0 ? Hi : C; b = C; }
      else { a = C; b = (i % 3) === 0 ? Hi : C; }
      K.px(c, X, Y, i < -n + 2 ? C : a); if (i > -n + 1) K.px(c, X - nx, Y - ny, b);
      if (pat === 3 && i > -n + 1) K.px(c, X + nx, Y + ny, C); }
    h = up || 0; X = x + tx * (n + 1) + nx * (Math.sin((n + 1) * .75 + ph) * amp + h); Y = y + ty * (n + 1) + ny * (Math.sin((n + 1) * .75 + ph) * amp + h);
    K.px(c, X, Y, C); K.px(c, X - nx, Y - ny, C); K.px(c, X + tx, Y + ty, C); K.px(c, X + tx - nx, Y + ty - ny, C); K.px(c, X + tx * 2, Y + ty * 2, A);
    K.px(c, X + nx, Y + ny, E); if (pat === 2) K.px(c, X + tx + nx, Y + ty + ny, A);
  }
  /* small forked tongue from (x,y) along (dx,dy) of length L, fork open by o */
  function tongue(c, K, x, y, dx, dy, L, o, col) {
    var i; for (i = 1; i <= L; i++) K.px(c, x + dx * i, y + dy * i, col);
    if (o) { K.px(c, x + dx * (L + 1) - dy, y + dy * (L + 1) + dx, col); K.px(c, x + dx * (L + 1) + dy, y + dy * (L + 1) - dx, col);
      if (o > 1) { K.px(c, x + dx * (L + 2) - dy * 2, y + dy * (L + 2) + dx * 2, col); K.px(c, x + dx * (L + 2) + dy * 2, y + dy * (L + 2) - dx * 2, col); } }
  }

  /* ---------- shared own-edge composition: the page's themedOwn() with this module's glyph / motion (+ optional per-run decoration) ---------- */
  function comp(c, e, H, deco) {
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
      if (deco) deco(c, e, H, r[0], len, ri, pp);
    }
  }
  function plain(c, e, H) { comp(c, e, H, null); }
  /* per-run decorations (a handful of pixels each) */
  function decoWater(c, e, H, s0, len, ri, pp) {          /* water animals: two short waterline dashes rock under them */
    var k, u, Q = H.Q, i, X, Y; if (e.p > .92) return;
    for (k = 0; k < 2; k++) { u = (pp * 1.1 + k * .5) % 1; e.P.atq(s0 + len * (k + .5) / 2); X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3 + 5 + Math.round(Math.sin(u * 6.28));
      for (i = -3; i <= 3; i++) if ((i + k) & 1) H.px(c, X + i, Y, i === 1 ? H.WHITE : H.DEW); }
  }
  function decoHeat(c, e, H, s0, len, ri, pp) {           /* desert: heat shimmer wiggles rising off the edge */
    var k, j, Q = H.Q, X, Y; if (e.p > .9) return;
    for (k = 0; k < 2; k++) { e.P.atq(s0 + len * (.3 + k * .4)); for (j = 0; j < 4; j++) { X = Q.x + Q.nx * (4 + j * 2) + Math.round(Math.sin(pp * 12 + j + k * 2)) * (Q.ny ? 1 : 0);
      Y = Q.y + Q.ny * (4 + j * 2) + Math.round(Math.sin(pp * 12 + j + k * 2)) * (Q.nx ? 1 : 0); if ((j + Math.floor(pp * 8)) & 1) H.px(c, X, Y, e.hi); } }
  }

  /* ---------- glyphs (tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step; fr from the motion) ---------- */
  /* beaded lizard */
  PFA.glyph('m08-gila', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* heavy side-view beaded lizard: orange and black bead rows, fat short tail, stepping legs */
    liz(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi, 1, 4 + z, 1, 3);
  });
  PFA.glyph('m08-beads', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a patch of round bead-scales (osteoderms) that flip orange / black in a warning flash */
    var i, j, X, Y, o;
    for (i = -1; i <= 1; i++) for (j = 0; j <= 1; j++) { X = x + tx * i * 3 + nx * j * 3; Y = y + ty * i * 3 + ny * j * 3; o = ((i + j + fr) & 1);
      K.bx(c, X - 1, Y - 1, 2, 2, o ? C : A); K.px(c, X - 1, Y - 1, o ? Hi : A); }
    if (fr === 2) K.plus(c, x + nx * 7, y + ny * 7, 1, 1, Hi);
  });
  PFA.glyph('m08-chew', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a blunt beaded head clamped on and chewing (fr 0 open, 1 shut, 2 shut + venom welling and dripping from the jaw groove) */
    var fl = face(tx, nx, ny), g = fr === 0 ? 2 : 0, i;
    for (i = -3; i <= 2; i++) { K.px(c, x + fl * i, y - 2 - g, (i & 1) ? A : C); K.px(c, x + fl * i, y - 1 - g, C); K.px(c, x + fl * i, y + 1, C); K.px(c, x + fl * i, y + 2, (i & 1) ? C : A); }
    K.px(c, x - fl * 1, y - 3 - g, C); K.px(c, x - fl * 2, y - 3 - g, A); K.px(c, x + fl, y - 2 - g, XC[13]);
    if (g) { K.px(c, x + fl * 2, y - 1, K.WHITE); K.px(c, x + fl * 2, y, K.WHITE); K.px(c, x, y, XC[7]); }
    else { K.px(c, x + fl * 3, y, A); K.px(c, x + fl * 2, y, Hi); }
    if (fr === 2) { K.px(c, x + fl * 1, y + 3, XC[11]); K.px(c, x + fl * 1, y + 4, XC[11]); K.px(c, x - fl * 1, y + 5, XC[11]); }
  });
  PFA.glyph('m08-fattail', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a fat sausage tail sticking out of the edge, beaded in bands, thrashing side to side (fr 0..3) */
    var L = 6 + z, sw = (fr - 1.5) * .5, i, X, Y, w;
    for (i = 0; i < L; i++) { w = i < L - 2 ? 1 : 0; X = x + nx * (i - 2) + tx * sw * i; Y = y + ny * (i - 2) + ty * sw * i;
      K.px(c, X, Y, ((i >> 1) & 1) ? A : C); if (w) { K.px(c, X + tx, Y + ty, ((i >> 1) & 1) ? C : A); K.px(c, X - tx, Y - ty, ((i >> 1) & 1) ? C : A); } }
    if (fr === 0 || fr === 3) { X = x + nx * (L - 1) + tx * sw * L; Y = y + ny * (L - 1) + ty * sw * L; K.px(c, X - tx * sw * 4, Y - ty * sw * 4, Hi); K.px(c, X - tx * sw * 6, Y - ty * sw * 6, Hi); }
  });
  /* tree monitor */
  PFA.glyph('m08-branchmon', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a bark branch with a green monitor lying flat along it, the long tail curled down round it */
    var fl = face(tx, nx, ny), i;
    for (i = -8; i <= 8; i++) { K.px(c, x + i, y + 3, XC[10]); if ((i % 5) === 0) K.px(c, x + i, y + 4, A); }
    K.px(c, x + 8, y + 2, XC[12]); K.px(c, x + 9, y + 1, XC[12]);
    liz(c, K, x + fl, y, fl, fr, C, A, Hi, 0, 5, 0, 1);
    K.px(c, x - fl * 9, y + 1, C); K.px(c, x - fl * 9, y + 2, C); K.px(c, x - fl * 9, y + 4, C); K.px(c, x - fl * 8, y + 5, C); K.px(c, x - fl * (7 + (fr & 1)), y + 5, A);
  });
  PFA.glyph('m08-bark', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a bark patch with green lichen flecks; on fr 1 / 2 a lizard eye opens in it (the monitor was there all along) */
    var i;
    for (i = -3; i <= 3; i++) { K.px(c, x + i, y - 2 + ((i + 9) % 3), XC[10]); K.px(c, x + i, y + 1 + (i & 1), XC[10]); K.px(c, x + i, y, (i % 3) === 0 ? C : A); }
    K.px(c, x - 2, y - 1, C); K.px(c, x + 3, y + 2, C);
    if (fr === 1 || fr === 2) { K.px(c, x - 1, y, Hi); K.px(c, x + 1, y, Hi); K.px(c, x, y, XC[13]); K.px(c, x, y - 1, C); K.px(c, x, y + 1, C); }
  });
  PFA.glyph('m08-tailwhip', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a long thin banded tail whipping out of the edge: coiled, uncurling, straight, then a crack spark at the tip */
    var L = 8 + z * 2, i, cu = (3 - Math.min(3, fr)) * .35, a = 0, X = x - nx * 2, Y = y - ny * 2, dx, dy;
    for (i = 0; i < L; i++) { a += cu * i / L; dx = nx * Math.cos(a) + tx * Math.sin(a); dy = ny * Math.cos(a) + ty * Math.sin(a); X += dx; Y += dy;
      K.px(c, X, Y, ((i >> 1) & 1) && i < L - 2 ? A : C); if (i < 3) K.px(c, X + tx, Y + ty, C); }
    if (fr >= 2) { K.px(c, X + dx * 2, Y + dy * 2, K.WHITE); K.px(c, X + dx * 2 + tx * 2, Y + dy * 2 + ty * 2, Hi); K.px(c, X + dx * 2 - tx * 2, Y + dy * 2 - ty * 2, Hi); }
  });
  PFA.glyph('m08-leafdrip', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a pointed canopy leaf tip with a green venom bead swelling under it */
    K.ln(c, x - 4, y - 3, x, y - 1, 1, XC[12]); K.ln(c, x - 4, y - 2, x - 1, y - 1, 1, XC[6]); K.px(c, x - 5, y - 4, XC[6]);
    K.sq(c, x, y + 1, fr ? 3 : 2, XC[11]); K.px(c, x - 1, y, K.WHITE); if (fr) K.px(c, x, y + 3, XC[11]);
  });
  /* water monitor */
  PFA.glyph('m08-swimmon', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a dark monitor swimming seen from above: legs tucked, the long tail sculling in an S, a V wake off the snout */
    var i, w, X, Y, n = 7 + z;
    for (i = -n; i <= 3; i++) { w = i < 0 ? Math.sin(i * .7 + fr * 1.57) * Math.min(2, -i * .35) : 0; X = x + tx * i + nx * w; Y = y + ty * i + ny * w;
      K.px(c, X, Y, i > -3 ? C : ((i & 1) ? A : C)); if (i > -3 && i < 3) { K.px(c, X + nx, Y + ny, (i & 1) ? Hi : C); K.px(c, X - nx, Y - ny, C); } }
    X = x + tx * 4; Y = y + ty * 4; K.px(c, X, Y, C); K.px(c, X + tx, Y + ty, A); K.px(c, X + nx, Y + ny, XC[13]); K.px(c, X - nx, Y - ny, XC[13]);
    for (i = 1; i <= 3; i++) { K.px(c, X - tx * i + nx * (i + 1), Y - ty * i + ny * (i + 1), i === 2 ? K.WHITE : K.DEW); K.px(c, X - tx * i - nx * (i + 1), Y - ty * i - ny * (i + 1), i === 2 ? K.WHITE : K.DEW); }
  });
  PFA.glyph('m08-wallow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a mud wallow plate: a flat mud slab, the monitor's eyes and nostrils just showing, a ring of ripples widening */
    var w = 5 + z, i, r = 2 + (fr % 3);
    for (i = -w; i <= w; i++) { K.px(c, x + i, y + 1, XC[15]); K.px(c, x + i, y + 2, i & 1 ? XC[15] : A); if (Math.abs(i) < w - 1) K.px(c, x + i, y, C); }
    K.px(c, x - 2, y - 1, C); K.px(c, x - 2, y - 2, XC[13]); K.px(c, x + 1, y - 1, C); K.px(c, x + 1, y - 2, XC[13]); K.px(c, x + 4, y - 1, A);
    K.px(c, x - w - r, y + 1, K.DEW); K.px(c, x + w + r, y + 1, K.DEW); if (fr === 2) { K.px(c, x - w - r - 1, y + 2, K.WHITE); K.px(c, x + w + r + 1, y + 2, K.WHITE); }
  });
  PFA.glyph('m08-hammer', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a heavy tail swung in an arc like a hammer: wind-up, swing, then the water bursts in a splash fan */
    var a = fr === 0 ? -1.1 : fr === 1 ? -.2 : .6, L = 7 + z, i, X, Y, dx = nx * Math.cos(a) + tx * Math.sin(a), dy = ny * Math.cos(a) + ty * Math.sin(a);
    for (i = 0; i < L; i++) { X = x - nx * 2 + dx * i; Y = y - ny * 2 + dy * i; K.px(c, X, Y, (i % 3) === 2 ? A : C); if (i < L - 3) K.px(c, X + tx, Y + ty, C); if (i < L - 5) K.px(c, X - tx, Y - ty, C); }
    if (fr === 1) for (i = 2; i < L; i += 2) K.px(c, x - nx * 2 + dx * i - tx * 3, y - ny * 2 + dy * i - ty * 3, Hi);
    if (fr === 2) for (i = -2; i <= 2; i++) { K.px(c, X + tx * i * 2 + nx * (2 + (i & 1)), Y + ty * i * 2 + ny * (2 + (i & 1)), i ? K.DEW : K.WHITE); K.px(c, X + tx * i + nx * 4, Y + ty * i + ny * 4, K.DEW); }
  });
  PFA.glyph('m08-silt', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a silt cloud blooming in brown water as the monitor dives, a tail tip vanishing, two bubbles */
    var r = 2 + Math.min(3, fr) + (z > 1 ? 1 : 0), i, a;
    for (i = 0; i < 10; i++) { a = i * .63; K.px(c, x + Math.cos(a) * r, y + Math.sin(a) * r * .7, i & 1 ? XC[15] : A); K.px(c, x + Math.cos(a + .3) * (r - 1), y + Math.sin(a + .3) * (r - 1) * .7, XC[15]); }
    K.px(c, x, y, A); if (fr < 2) { K.px(c, x + 1, y - 1, C); K.px(c, x + 2, y - 2, C); }
    K.ringpx(c, x - 2, y - r - 2 - fr, 1, K.DEW); K.px(c, x + 2, y - r - 1 - fr * 2, K.WHITE);
  });
  /* spice monitor */
  PFA.glyph('m08-spicemon', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a cinnamon-red monitor with clove-dark spots and a saffron neck, its tail swaying, a pinch of spice dust off the tail tip */
    var fl = face(tx, nx, ny);
    liz(c, K, x, y, fl, fr, C, A, Hi, 2, 7, 2, 1);
    K.px(c, x + fl * 4, y + 1, Hi); K.px(c, x + fl * 5, y + 1, Hi);
    if (fr & 1) { K.px(c, x - fl * 11, y - 2, Hi); K.px(c, x - fl * 12, y - 1, C); }
  });
  PFA.glyph('m08-quill', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a curled cinnamon-bark quill, seen end-on as a scroll turning; crusted ridge along it */
    var i, L = 3 + z;
    for (i = -L; i <= L; i++) { K.px(c, x + tx * i + nx, y + ty * i + ny, C); K.px(c, x + tx * i - nx, y + ty * i - ny, (i + fr) % 3 === 0 ? Hi : C); K.px(c, x + tx * i, y + ty * i, A); }
    K.px(c, x + tx * (L + 1), y + ty * (L + 1), fr & 1 ? A : C); K.px(c, x + tx * (L + 1) + nx * ((fr & 2) ? 1 : -1), y + ty * (L + 1) + ny * ((fr & 2) ? 1 : -1), C);
  });
  PFA.glyph('m08-anise', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a star-anise pod: eight brown points with shiny seeds, turning; powder puffing at the rim */
    var i, a, r = 3 + (z > 1 ? 1 : 0);
    for (i = 0; i < 8; i++) { a = i * .785 + fr * .2; K.px(c, x + Math.cos(a) * r, y + Math.sin(a) * r, A); K.px(c, x + Math.cos(a) * (r - 1), y + Math.sin(a) * (r - 1), C); if (!(i & 1)) K.px(c, x + Math.cos(a) * (r - 2), y + Math.sin(a) * (r - 2), Hi); }
    K.px(c, x, y, A);
    if (fr >= 2) { K.px(c, x + nx * (r + 2), y + ny * (r + 2), Hi); K.px(c, x + nx * (r + 3) + tx * 2, y + ny * (r + 3) + ty * 2, C); K.px(c, x + nx * (r + 3) - tx * 2, y + ny * (r + 3) - ty * 2, Hi); }
  });
  /* shared: forked tongue, venom fangs, scale shingles, venom spit */
  PFA.glyph('m08-tongue', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a snout at the edge, the forked tongue flicking out (fr 0 in, 1 half, 2 out and forked, 3 forks flicking wide) */
    var L = fr === 0 ? 0 : fr === 1 ? 3 : 5 + z;
    K.px(c, x, y, C); K.px(c, x + tx, y + ty, C); K.px(c, x - tx, y - ty, C); K.px(c, x - nx, y - ny, C); K.px(c, x + tx - nx, y + ty - ny, XC[13]);
    if (L) tongue(c, K, x + nx, y + ny, nx, ny, L, fr >= 2 ? (fr === 3 ? 2 : 1) : 0, Hi);
  });
  PFA.glyph('m08-fang', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* two curved fangs hooked outward, a venom bead swelling at each tip (fr 0 closed, 1 open, 2 bead drops) */
    var o = fr ? 2 : 1, i, L = 3 + (z > 0 ? 1 : 0);
    for (i = 0; i < L; i++) { K.px(c, x + tx * o + nx * i + tx * (i === L - 1 ? -1 : 0), y + ty * o + ny * i + ty * (i === L - 1 ? -1 : 0), K.WHITE); K.px(c, x - tx * o + nx * i + tx * (i === L - 1 ? 1 : 0), y - ty * o + ny * i + ty * (i === L - 1 ? 1 : 0), K.WHITE); }
    K.px(c, x - nx, y - ny, C); K.px(c, x + tx * (o + 1) - nx, y + ty * (o + 1) - ny, C); K.px(c, x - tx * (o + 1) - nx, y - ty * (o + 1) - ny, C); K.px(c, x - nx * 2, y - ny * 2, A);
    if (fr >= 1) { K.px(c, x + tx * (o - 1) + nx * L, y + ty * (o - 1) + ny * L, Hi); K.px(c, x - tx * (o - 1) + nx * L, y - ty * (o - 1) + ny * L, Hi); }
    if (fr === 2) { K.px(c, x + nx * (L + 2), y + ny * (L + 2), Hi); K.px(c, x + nx * (L + 3), y + ny * (L + 3), Hi); }
  });
  PFA.glyph('m08-scales', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* three overlapping keeled scales in a shingle row, a light glint sliding over them */
    var k, X, Y, i;
    for (k = -1; k <= 1; k++) { X = x + tx * k * 3; Y = y + ty * k * 3;
      for (i = -1; i <= 1; i++) K.px(c, X + tx * i, Y + ty * i, C); K.px(c, X + nx, Y + ny, C); K.px(c, X - nx - tx, Y - ny - ty, A); K.px(c, X - nx + tx, Y - ny + ty, A);
      K.px(c, X, Y, (fr & 3) === k + 1 ? K.WHITE : A); K.px(c, X + nx * 2, Y + ny * 2, (fr & 3) === k + 1 ? Hi : C); }
  });
  PFA.glyph('m08-spit', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a gaping snout spitting a fan of venom droplets that fly further out each frame */
    var i, d = 2 + fr * 2;
    K.px(c, x - nx, y - ny, C); K.px(c, x - nx + tx, y - ny + ty, C); K.px(c, x - nx - tx, y - ny - ty, C); K.px(c, x, y, A); K.px(c, x - nx * 2, y - ny * 2, XC[13]);
    for (i = -1; i <= 1; i++) { K.px(c, x + nx * d + tx * i * (1 + fr), y + ny * d + ty * i * (1 + fr), i ? Hi : K.WHITE); if (fr > 0) K.px(c, x + nx * (d - 2) + tx * i * fr * .6, y + ny * (d - 2) + ty * i * fr * .6, Hi); }
  });
  /* komodo pup */
  PFA.glyph('m08-kpup', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a gangly young komodo: sand-spotted, big head, a long yellow forked tongue flicking out on fr 1 / 3 */
    var fl = face(tx, nx, ny);
    liz(c, K, x, y, fl, fr, C, A, Hi, 3, 5, 1, 1);
    K.px(c, x + fl * 5, y - 2, C); K.px(c, x + fl * 4, y - 2, C);
    if (fr & 1) tongue(c, K, x + fl * 8, y, fl, 0, 3, fr === 3 ? 2 : 1, XC[8]);
  });
  PFA.glyph('m08-drool', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a jaw edge with a sticky drool string sagging out, beads sliding down it (fr = length 0..3) */
    var i, L = 2 + fr * 2;
    K.px(c, x - 2, y - 2, C); K.px(c, x - 1, y - 2, C); K.px(c, x, y - 2, C); K.px(c, x + 1, y - 2, A); K.px(c, x - 1, y - 3, XC[13]);
    for (i = 0; i < L; i++) K.px(c, x + Math.round(Math.sin(i * .6) * .6), y - 1 + i, i === L - 1 ? K.WHITE : Hi);
    if (fr >= 2) K.sq(c, x, y + L, 2, Hi);
  });
  PFA.glyph('m08-sandeye', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a low sand mound with a pup's eye and brow peeping out of it, blinking (fr 0 shut, 1 open, 2 looks sideways) */
    var i;
    for (i = -4; i <= 4; i++) { K.px(c, x + i, y + 1, XC[16]); if (Math.abs(i) < 3) K.px(c, x + i, y, XC[16]); }
    K.px(c, x - 2, y - 1, C); K.px(c, x - 1, y - 1, C); K.px(c, x, y - 1, C); K.px(c, x + 1, y - 1, C); K.px(c, x - 1, y - 2, A); K.px(c, x, y - 2, A);
    if (fr) { K.px(c, x - 1 + (fr === 2 ? 1 : 0), y - 1, XC[13]); K.px(c, x - 1 + (fr === 2 ? 0 : 1), y - 1, Hi); }
    else K.px(c, x - 1, y - 1, A);
    K.px(c, x - 4 + (fr & 1), y + 2, A);
  });
  /* smooth snake */
  PFA.glyph('m08-coil', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a smooth grey snake in a flat coil (two rings), tightening on each frame, round-pupilled head on top */
    var r = 4 - fr * .7 + (z > 1 ? 1 : 0), i, a;
    for (i = 0; i < 16; i++) { a = i * .39; K.px(c, x + Math.cos(a) * r, y + Math.sin(a) * r * .75, (i % 5) === 0 ? Hi : C); }
    for (i = 0; i < 10; i++) { a = i * .63 + 1; K.px(c, x + Math.cos(a) * (r - 2), y + Math.sin(a) * (r - 2) * .75, i === 3 ? A : C); }
    K.px(c, x + 1, y - 1, C); K.px(c, x + 2, y - 1, C); K.px(c, x + 2, y - 2, C); K.px(c, x + 3, y - 2, A); K.px(c, x + 2, y - 3, XC[13]);
  });
  PFA.glyph('m08-stone', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a flat sun-warmed stone, a smooth snake lying draped across it, heat shimmer lines rising */
    var i;
    for (i = -5; i <= 5; i++) { K.px(c, x + i, y + 1, XC[9]); K.px(c, x + i, y + 2, i & 1 ? XC[9] : A); }
    K.px(c, x - 4, y, XC[9]); K.px(c, x + 4, y, XC[9]);
    for (i = -4; i <= 4; i++) K.px(c, x + i, y + Math.round(Math.sin(i * .9) * .6), (i % 4) === 0 ? Hi : C);
    K.px(c, x + 5, y - 1, C); K.px(c, x + 6, y - 1, A);
    for (i = 0; i < 3; i++) K.px(c, x - 3 + i * 3 + (((fr + i) & 1) ? 1 : 0), y - 3 - ((fr + i) & 3), Hi);
  });
  /* water snake */
  PFA.glyph('m08-bandsnake', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* an olive snake with dark crossbands swimming along the surface in an S, flat head lifted */
    snk(c, K, x, y, tx, ty, nx, ny, 4 + z, 1.6, fr * .8, C, A, Hi, 1, XC[13], 1);
  });
  PFA.glyph('m08-reed', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* three reed stems standing out of the edge with the banded snake weaving in and out between them */
    var i, k, X, Y;
    for (k = -1; k <= 1; k++) for (i = 0; i < 8; i++) { X = x + tx * k * 3 + nx * (i - 2) + tx * (i > 5 ? (k + 1) & 1 : 0); Y = y + ty * k * 3 + ny * (i - 2) + ty * (i > 5 ? (k + 1) & 1 : 0); K.px(c, X, Y, i === 7 ? XC[10] : XC[12]); }
    for (i = -5; i <= 5; i++) { X = x + tx * i + nx * (1 + Math.round(Math.sin(i * 1.05 + fr * 1.57) * 2)); Y = y + ty * i + ny * (1 + Math.round(Math.sin(i * 1.05 + fr * 1.57) * 2));
      K.px(c, X, Y, ((i + 5) >> 1) & 1 ? A : C); }
  });
  /* tree snake */
  PFA.glyph('m08-vinesnake', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a slim bright-green snake draped from a bough in a loose loop, the head hanging lowest (fr 0..2 = how far it lets go) */
    var i, L = 4 + fr * 2 + z, X, Y;
    K.bx(c, x - 5, y - 4, 11, 1, XC[10]); K.px(c, x + 5, y - 5, XC[12]); K.px(c, x - 5, y - 5, XC[12]);
    for (i = -4; i <= 0; i++) K.px(c, x + i, y - 3, (i & 1) ? Hi : C);
    for (i = 0; i < L; i++) { X = x + Math.round(Math.sin(i * .5) * 1.5); Y = y - 2 + i; K.px(c, X, Y, (i % 3) === 1 ? Hi : C); }
    K.px(c, X, Y + 1, C); K.px(c, X + 1, Y + 1, C); K.px(c, X + 1, Y + 2, XC[13]);
  });
  PFA.glyph('m08-leafmimic', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* a spray of pointed green leaves; one is not a leaf (fr 3: the snake head turns, eye glinting, tongue) */
    var k, i, X, Y;
    for (k = -1; k <= 1; k++) { X = x + tx * k * 4; Y = y + ty * k * 4;
      for (i = 0; i < 4; i++) { K.px(c, X + nx * i, Y + ny * i, i === 0 ? XC[6] : XC[12]); if (i > 0 && i < 3) K.px(c, X + nx * i + tx, Y + ny * i + ty, k ? XC[6] : C); } }
    if (fr === 3) { K.px(c, x + nx * 3, y + ny * 3, C); K.px(c, x + nx * 2 + tx, y + ny * 2 + ty, XC[13]); K.px(c, x + nx * 2 - tx, y + ny * 2 - ty, Hi); K.px(c, x + nx * 5, y + ny * 5, XC[7]); }
  });
  /* night adder */
  PFA.glyph('m08-adder', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a thick short adder with a dark zigzag down its back and a red eye, drawn back in an S (fr 0) then striking (fr 1 / 2) */
    var n = fr ? 4 : 3, amp = fr ? .8 : 2;
    snk(c, K, x, y, tx, ty, nx, ny, n + (z > 1 ? 1 : 0), amp, 1.2, C, A, Hi, 2, XC[14], fr ? 0 : 2);
    if (fr === 2) { K.px(c, x + tx * (n + 5), y + ty * (n + 5), K.WHITE); K.px(c, x + tx * (n + 5) + nx, y + ty * (n + 5) + ny, Hi); }
  });
  PFA.glyph('m08-redeye', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* two red eyes glowing out of a dark coil in the night, blinking slowly; a dim halo round them */
    var i;
    for (i = -3; i <= 3; i++) { K.px(c, x + i, y + 1, A); K.px(c, x + i, y + 2, (i & 1) ? C : A); }
    if (fr) { K.px(c, x - 2, y, XC[14]); K.px(c, x + 2, y, XC[14]); K.px(c, x - 2, y - 1, fr === 2 ? Hi : A); K.px(c, x + 2, y - 1, fr === 2 ? Hi : A); if (fr === 3) { K.px(c, x - 3, y, Hi); K.px(c, x + 3, y, Hi); } }
    else { K.px(c, x - 2, y, A); K.px(c, x + 2, y, A); }
  });
  PFA.glyph('m08-road', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a strip of warm night road: asphalt, a pale centre dash, heat wiggles rising and a lying adder along it */
    var i;
    for (i = -5; i <= 5; i++) { K.px(c, x + tx * i, y + ty * i, XC[17]); K.px(c, x + tx * i + nx, y + ty * i + ny, XC[17]); K.px(c, x + tx * i - nx, y + ty * i - ny, XC[17]); }
    for (i = -1; i <= 1; i++) K.px(c, x + tx * (i + (fr & 1) * 3 - 1), y + ty * (i + (fr & 1) * 3 - 1), XC[16]);
    for (i = -4; i <= 4; i++) K.px(c, x + tx * i + nx * (2 + ((i + fr) & 1)), y + ty * i + ny * (2 + ((i + fr) & 1)), (i & 1) ? A : C);
    K.px(c, x + tx * 5 + nx * 2, y + ty * 5 + ny * 2, XC[14]);
    K.px(c, x + nx * (5 + (fr & 3)), y + ny * (5 + (fr & 3)), Hi); K.px(c, x + tx * 3 + nx * (6 + ((fr + 2) & 3)), y + ty * 3 + ny * (6 + ((fr + 2) & 3)), Hi);
  });
  /* dust sidewinder */
  PFA.glyph('m08-sidewind', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a pale sidewinder lying slanted across the edge, a row of J-shaped tracks pressed into the sand behind it */
    var i, k, X, Y;
    for (k = 0; k < 3; k++) { X = x - tx * (3 + k * 3) - nx * 2; Y = y - ty * (3 + k * 3) - ny * 2;
      for (i = 0; i < 4; i++) K.px(c, X + nx * i + tx * i * .5, Y + ny * i + ty * i * .5, k === 2 && fr ? XC[16] : A); K.px(c, X - tx, Y - ty, A); }
    for (i = -4; i <= 3; i++) { X = x + nx * (i * .7) + tx * i * .5 + tx * (fr ? 1 : 0); Y = y + ny * (i * .7) + ty * i * .5 + ty * (fr ? 1 : 0); K.px(c, X, Y, (i & 1) ? Hi : C); K.px(c, X + tx, Y + ty, C); }
    K.px(c, X + nx + tx, Y + ny + ty, C); K.px(c, X + nx + tx * 2, Y + ny + ty * 2, XC[13]);
  });
  PFA.glyph('m08-horn', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a sidewinder head peeking out of the sand, the two little horns over its eyes, sand trickling off (fr 0 sunk .. 2 up) */
    var u = fr === 0 ? 1 : 0, i;
    for (i = -4; i <= 4; i++) { K.px(c, x + i, y + 2, XC[16]); if (Math.abs(i) < 3) K.px(c, x + i, y + 1, XC[16]); }
    K.px(c, x - 1, y + u, C); K.px(c, x, y + u, C); K.px(c, x + 1, y + u, C); K.px(c, x - 1, y - 1 + u, XC[13]); K.px(c, x + 1, y - 1 + u, XC[13]);
    K.px(c, x - 2, y - 2 + u, A); K.px(c, x + 2, y - 2 + u, A); K.px(c, x - 2, y - 3 + u, Hi); K.px(c, x + 2, y - 3 + u, Hi);
    if (fr === 2) { K.px(c, x - 3, y, XC[16]); K.px(c, x + 3, y - 1, XC[16]); }
  });
  /* dune racer */
  PFA.glyph('m08-racer', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a long thin pale racer stretched dead straight, a tan stripe along its side, speed dashes flicking behind */
    var n = 6 + z;
    snk(c, K, x, y, tx, ty, nx, ny, n, .35, fr * 2, C, A, Hi, 3, XC[13], 0);
    K.px(c, x - tx * (n + 3) + nx * (fr ? 1 : -1), y - ty * (n + 3) + ny * (fr ? 1 : -1), Hi); K.px(c, x - tx * (n + 5), y - ty * (n + 5), Hi);
    K.px(c, x - tx * (n + 4) + nx * (fr ? -2 : 2), y - ty * (n + 4) + ny * (fr ? -2 : 2), C);
  });
  PFA.glyph('m08-mirage', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* heat-mirage wavy lines with a dotted ghost of the racer wavering inside them, wobbling 4 phases */
    var i, j, w;
    for (j = 0; j < 3; j++) for (i = -5; i <= 5; i++) { w = Math.round(Math.sin(i * .9 + fr * 1.57 + j)); if (((i + j) & 1) === 0) K.px(c, x + tx * i + nx * (j * 2 - 2 + w), y + ty * i + ny * (j * 2 - 2 + w), j === 1 ? Hi : C); }
    for (i = -4; i <= 4; i += 2) K.px(c, x + tx * (i + (fr & 1)) + nx * Math.round(Math.sin(i + fr) * .8), y + ty * (i + (fr & 1)) + ny * Math.round(Math.sin(i + fr) * .8), K.WHITE);
  });

  /* ---------- motions (mutate the scratch G; pp = time x speed) ---------- */
  PFA.motion('m08-plod', function (G, pp, k) { var st = Math.floor(pp * 4 + k * .5); G.s += st * .02; G.fr = st & 1; G.up += G.fr ? 0 : 1; });               /* heavy step-by-step */
  PFA.motion('m08-chew', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 3) + k) % 3; G.d -= G.fr ? 1 : 0; });
  PFA.motion('m08-flash', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) % 3; });
  PFA.motion('m08-thrash', function (G, pp, k) { G.fr = Math.round((Math.sin(pp * 11 + k) + 1) * 1.5); });
  PFA.motion('m08-cling', function (G, pp, k) { G.t += Math.sin(pp * 4 + k); G.fr = (Math.floor(pp * 3) + k) & 1; });
  PFA.motion('m08-peek', function (G, pp, k, ph) { var w = (pp * 1.8 + ph) % 1; G.fr = w < .2 ? 0 : w < .75 ? 1 : 2; });
  PFA.motion('m08-lash', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 2.2 + ph) % 1) * 4)); });
  PFA.motion('m08-scull', function (G, pp, k) { G.s += pp * .22; G.fr = (Math.floor(pp * 8) + k) & 3; G.d += Math.sin(pp * 6 + k) * .8; });
  PFA.motion('m08-ripple', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) % 3; });
  PFA.motion('m08-sweep', function (G, pp, k, ph) { var w = (pp * 1.8 + ph) % 1; G.fr = w < .35 ? 0 : w < .6 ? 1 : 2; });
  PFA.motion('m08-billow', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.5 + ph * .4) % 1) * 5)); G.t += Math.sin(pp * 5 + k); });
  PFA.motion('m08-sashay', function (G, pp, k) { G.s += pp * .15; G.fr = (Math.floor(pp * 7) + k) & 3; G.up += (G.fr & 1); });
  PFA.motion('m08-turn', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 8 + ph * 4) + k) & 3; });
  PFA.motion('m08-flick', function (G, pp, k, ph) { var w = (pp * 3 + ph) % 1; G.fr = w < .3 ? 0 : w < .45 ? 1 : w < .75 ? 2 : 3; });
  PFA.motion('m08-fangs', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .5 ? 0 : w < .7 ? 1 : 2; G.d += G.fr === 1 ? 2 : 0; });
  PFA.motion('m08-spray', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 2.5 + ph) % 1) * 4)); });
  PFA.motion('m08-scamper', function (G, pp, k) { G.s += pp * .3; G.fr = (Math.floor(pp * 12) + k) & 3; G.up += (G.fr & 1); });
  PFA.motion('m08-drool', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.4 + ph) % 1) * 4)); });
  PFA.motion('m08-squeeze', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.6 + ph) % 1) * 3)); });
  PFA.motion('m08-bask', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; });
  PFA.motion('m08-swimsnake', function (G, pp, k) { G.s += pp * .25; G.fr = (Math.floor(pp * 12) + k) & 7; });
  PFA.motion('m08-weave', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; });
  PFA.motion('m08-drape', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.4 + ph) % 1) * 3)); G.t += Math.sin(pp * 5 + k) * 1.5; });
  PFA.motion('m08-rustle', function (G, pp, k, ph) { G.t += Math.sin(pp * 10 + k) * 1.2; G.fr = (Math.floor(pp * 6 + ph * 3) + k) & 3; });
  PFA.motion('m08-sstrike', function (G, pp, k, ph) { var w = (pp * 1.8 + ph) % 1; G.fr = w < .6 ? 0 : w < .75 ? 1 : 2; G.d += G.fr === 1 ? 3 : 0; });
  PFA.motion('m08-glow', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 5 + ph * 5) + k) & 3; });
  PFA.motion('m08-heat', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; });
  PFA.motion('m08-sidewind', function (G, pp, k) { var st = Math.floor(pp * 6 + k * .4); G.s += st * .025; G.fr = st & 1; G.t += G.fr ? 1 : -1; });
  PFA.motion('m08-horn', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .3 ? 0 : w < .5 ? 2 : 1; });
  PFA.motion('m08-dart', function (G, pp, k) { G.s += pp * .9; G.fr = (Math.floor(pp * 20) + k) & 1; });
  PFA.motion('m08-mirage', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 9 + ph * 4) + k) & 3; if ((Math.floor(pp * 7) + k) % 5 === 4) G.vis = 0; });

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ---------- */
  function carGila(c, e, H) {           /* the beaded lizard plods along in heavy steps, paired claw prints and a tail drag line left behind */
    var P = e.P, Q = H.Q, st = Math.floor(e.p * 8), u = Math.min(1, (st + H.eo((e.p * 8 - st) * 1.4)) / 8), k, X, Y;
    for (k = 1; k <= st && k < 8; k++) { P.atq(e.a + e.d * k / 8); X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3;
      H.px(c, X - 1, Y + (k & 1 ? 2 : 0), e.acc); H.px(c, X + 1, Y + (k & 1 ? 2 : 0), e.acc); H.px(c, X, Y + (k & 1 ? 3 : 1), e.acc); if (k & 1) H.px(c, X, Y - 1, e.hi); }
    H.carHead(c, P, e.a + e.d * u, 'm08-gila', e.z, st & 1, 0, -1 - (st & 1), e.col, e.acc, e.hi);
  }
  function carBranch(c, e, H) {         /* a branch grows along the edge and the tree monitor climbs it, leaves popping on the bark */
    var P = e.P, Q = H.Q, u, k = 0;
    for (u = 0; u <= e.hh; u += .025) { P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3, '#7a5030'); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, ((k++) % 6) === 0 ? e.acc : '#7a5030');
      if ((k % 9) === 4) { H.px(c, Q.x + Q.nx * 4 + 1, Q.y + Q.ny * 4 - 1, '#62c050'); H.px(c, Q.x + Q.nx * 5 + 1, Q.y + Q.ny * 5 - 2, '#62c050'); } }
    H.carHead(c, P, e.a + e.d * e.hh, 'm08-climbmon', e.z, e.fr, 0, -1, e.col, e.acc, e.hi);
  }
  function carSwim(c, e, H) {           /* the water monitor swims the edge, its tail sculling; a V wake spreads behind and fades */
    var P = e.P, Q = H.Q, k, u, w;
    for (k = 1; k <= 5; k++) { u = e.hh - k * .05; if (u < 0) break; P.atq(e.a + e.d * u); w = k * 1.4;
      H.px(c, Q.x + Q.nx * (5 + w), Q.y + Q.ny * (5 + w), k < 3 ? H.WHITE : H.DEW); H.px(c, Q.x + Q.nx * (5 - w * .6), Q.y + Q.ny * (5 - w * .6), H.DEW); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm08-swimmon', e.z, Math.floor(e.p * 16) & 3, 0, 0, e.col, e.acc, e.hi);
  }
  function carPup(c, e, H) {            /* the komodo pup scampers along tongue first, a line of sand prints behind it */
    var P = e.P, Q = H.Q, k, X, Y;
    for (k = 1; k <= 6; k++) { if (e.hh < k / 7) break; P.atq(e.a + e.d * (e.hh - k / 7 * e.hh * .9)); X = Q.x + Q.nx * (3 + (k & 1) * 2); Y = Q.y + Q.ny * (3 + (k & 1) * 2);
      H.px(c, X - 1, Y, e.acc); H.px(c, X + 1, Y, e.acc); H.px(c, X, Y + 1, e.acc); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm08-kpup', e.z, Math.floor(e.p * 12) & 3, 0, -(Math.floor(e.p * 12) & 1), e.col, e.acc, e.hi);
  }
  /* slithering snake body made of segments that follow the head along the edge path; pat = snk pattern; wake 1 = water rings, 2 = road dashes, 3 = speed lines, 4 = vine */
  function slither(pat, eye, amp, wake) {
    return function (c, e, H) {
      var P = e.P, Q = H.Q, D = Math.max(24, Math.abs(e.d)), st = 1.2 / D, k, u, w, X, Y, a, b, n = 16 + e.z * 2;
      if (wake === 2 || wake === 4) for (u = 0; u <= e.hh; u += .04) { P.atq(e.a + e.d * u); if (wake === 2) { if (((u * 25) | 0) & 1) H.px(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5, '#e8d8a8'); }
        else { H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, '#7a5030'); if ((((u * 25) | 0) % 5) === 2) H.px(c, Q.x + Q.nx * 1, Q.y + Q.ny * 1, '#62c050'); } }
      for (k = n; k >= 0; k--) { u = e.hh - k * st; if (u < 0) continue; P.atq(e.a + e.d * u); w = Math.sin(k * .55 - e.p * 22) * amp * (k < 2 ? .3 : 1);
        X = Q.x + Q.nx * (5 + w); Y = Q.y + Q.ny * (5 + w);
        if (pat === 1) { a = (k >> 1) & 1 ? e.acc : e.col; b = a; } else if (pat === 2) { a = k & 1 ? e.acc : e.col; b = k & 1 ? e.col : e.acc; }
        else if (pat === 3) { a = e.hi; b = e.acc; } else { a = (k % 4) === 0 ? e.hi : e.col; b = e.col; }
        H.px(c, X, Y, k > n - 2 ? e.col : a); if (k < n - 1) H.px(c, X - Q.nx, Y - Q.ny, b);
        if (wake === 1 && (k % 6) === 3) { H.px(c, X + Q.nx * 2 + Q.ny * 2, Y + Q.ny * 2 - Q.nx * 2, H.DEW); H.px(c, X + Q.nx * 2 - Q.ny * 2, Y + Q.ny * 2 + Q.nx * 2, H.DEW); }
        if (wake === 3 && k > n - 5) { H.px(c, X - Q.ny * 3, Y + Q.nx * 3, e.hi); } }
      P.atq(e.a + e.d * e.hh); X = Q.x + Q.nx * 5; Y = Q.y + Q.ny * 5; k = e.d >= 0 ? 1 : -1;
      H.sq(c, X + Q.ny * -k, Y + Q.nx * k, 2, e.col); H.px(c, X + Q.nx - Q.ny * k, Y + Q.ny + Q.nx * k, eye);
      if (wake === 2 && (Math.floor(e.p * 12) & 1)) { H.px(c, X + Q.nx * 2 - Q.ny * k * 2, Y + Q.ny * 2 + Q.nx * k * 2, '#ff5040'); }
      if (Math.floor(e.p * 10) % 3 === 0) { H.px(c, X - Q.ny * k * 3, Y + Q.nx * k * 3, '#d0283c'); H.px(c, X - Q.ny * k * 4 + Q.nx, Y + Q.nx * k * 4 + Q.ny, '#d0283c'); }
    };
  }
  function carSidewind(c, e, H) {        /* the sidewinder loops sideways along the edge: slanted J tracks pressed in one after another, the snake at the newest one */
    var P = e.P, Q = H.Q, st = Math.floor(e.hh * 7), k, i, X, Y;
    for (k = 0; k <= st && k < 7; k++) { P.atq(e.a + e.d * k / 7); X = Q.x + Q.nx * 3; Y = Q.y + Q.ny * 3;
      for (i = 0; i < 4; i++) H.px(c, X + Q.nx * i + Q.ny * i * .6, Y + Q.ny * i - Q.nx * i * .6, k === st ? e.hi : e.acc); H.px(c, X - Q.ny, Y + Q.nx, e.acc); }
    H.carHead(c, P, e.a + e.d * Math.min(1, e.hh + .04), 'm08-sidewind', e.z, Math.floor(e.p * 14) & 1, 0, 0, e.col, e.acc, e.hi);
  }

  /* the tree-monitor chain head: a monitor without the branch (the chain draws the branch itself) */
  PFA.glyph('m08-climbmon', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* chain-only: the green tree monitor climbing, long tail trailing */
    liz(c, K, x, y, face(tx, nx, ny), fr, C, A, Hi, 0, 8, 2, 1);
  });

  /* ---------- motifs ---------- */
  function M(name, draw, meta) { PFA.motif(name, draw, meta); }
  function water(c, e, H) { comp(c, e, H, decoWater); }
  function heat(c, e, H) { comp(c, e, H, decoHeat); }
  /* beaded lizard */
  M('gila-plod', plain, { nm: 'beaded lizards', desc: 'heavy side-view lizards covered in orange and black bead rows, fat short tails, plodding step by step; the chain plods along leaving claw prints and a tail drag', fam: 'bash', gap: 18, g: 'm08-gila', mo: 'm08-plod', x: '-', car: 'custom', carDraw: carGila });
  M('bead-hide', plain, { nm: 'bead hide', desc: 'patches of round bead-scales flipping orange and black in a warning flash', fam: 'shield', gap: 12, g: 'm08-beads', mo: 'm08-flash', x: '-', car: 'train' });
  M('gila-chew', plain, { nm: 'chewing jaws', desc: 'blunt beaded jaws clamping on and chewing, venom welling along the lower-jaw grooves and dripping', fam: 'drip', gap: 14, g: 'm08-chew', mo: 'm08-chew', x: '-', car: 'comet' });
  M('fat-tail', plain, { nm: 'fat tails', desc: 'fat banded sausage tails sticking out of the edge and thrashing side to side', fam: 'bash', gap: 14, g: 'm08-fattail', mo: 'm08-thrash', x: '-', car: 'roll' });
  /* tree monitor */
  M('branch-monitor', plain, { nm: 'branch monitors', desc: 'green monitors lying flat along bark branches with long tails curled round them; the chain grows a branch along the edge and the monitor climbs it', fam: 'bite', gap: 22, g: 'm08-branchmon', mo: 'm08-cling', x: '-', car: 'custom', carDraw: carBranch });
  M('bark-blend', plain, { nm: 'bark eyes', desc: 'bark patches with lichen flecks where a lizard eye suddenly opens and shuts', fam: 'leaf', gap: 12, g: 'm08-bark', mo: 'm08-peek', x: '-', car: 'blink' });
  M('tail-lash', plain, { nm: 'tail lashes', desc: 'long thin banded tails uncoiling out of the edge and cracking straight, a spark at the tip', fam: 'slash', gap: 16, g: 'm08-tailwhip', mo: 'm08-lash', x: '-', car: 'comet' });
  M('canopy-drip', plain, { nm: 'canopy venom', desc: 'pointed canopy leaf tips with green venom beads swelling and hanging on threads', fam: 'drip', gap: 14, g: 'm08-leafdrip', mo: 'dangle', x: 'threads', car: 'thread' });
  /* water monitor */
  M('monitor-swim', water, { nm: 'swimming monitors', desc: 'dark monitors seen from above swimming with the tail sculling in an S, V wake off the snout; the chain swims the edge with a spreading wake', fam: 'ripple', gap: 20, g: 'm08-swimmon', mo: 'm08-scull', x: '-', car: 'custom', carDraw: carSwim });
  M('wallow-mud', plain, { nm: 'mud wallows', desc: 'flat mud slabs with a monitor\'s eyes and nostrils just showing, ripple rings widening', fam: 'shield', gap: 16, g: 'm08-wallow', mo: 'm08-ripple', x: '-', car: 'rings' });
  M('tail-hammer', water, { nm: 'hammer tails', desc: 'a heavy tail swung through an arc, wind-up then swing, the water bursting in a splash fan', fam: 'bash', gap: 16, g: 'm08-hammer', mo: 'm08-sweep', x: '-', car: 'hop' });
  M('silt-cloud', plain, { nm: 'silt clouds', desc: 'brown silt clouds blooming as the monitor dives, a tail tip vanishing, bubbles rising', fam: 'puff', gap: 14, g: 'm08-silt', mo: 'm08-billow', x: 'bubbles', car: 'cloud' });
  /* spice monitor */
  M('spice-monitor', plain, { nm: 'spice monitors', desc: 'cinnamon-red monitors with clove-dark spots and a saffron throat sashaying along, spice dust off the tail tip', fam: 'drip', gap: 20, g: 'm08-spicemon', mo: 'm08-sashay', x: 'powder', car: 'trail' });
  M('cinnamon-quill', plain, { nm: 'cinnamon quills', desc: 'curled cinnamon-bark quills like crusted scales, turning end over end', fam: 'shield', gap: 12, g: 'm08-quill', mo: 'm08-turn', x: '-', car: 'roll' });
  M('star-anise', plain, { nm: 'star anise', desc: 'eight-pointed star-anise pods turning, spice powder puffing off the rim', fam: 'puff', gap: 14, g: 'm08-anise', mo: 'm08-turn', x: 'powder', car: 'cloud' });
  /* shared (reptile relatives) */
  M('fork-tongue', plain, { nm: 'forked tongues', desc: 'a snout at the edge with a forked tongue flicking out, forking and flicking wide, tasting the air', fam: 'web', gap: 14, g: 'm08-tongue', mo: 'm08-flick', x: '-', car: 'blink' });
  M('venom-fang', plain, { nm: 'venom fangs', desc: 'two curved white fangs hooked outward, a venom bead swelling at each tip and dropping', fam: 'bite', gap: 12, g: 'm08-fang', mo: 'm08-fangs', x: '-', car: 'comet' });
  M('scale-shingle', plain, { nm: 'scale shingles', desc: 'overlapping keeled scales in a shingle row with a light glint sliding over them', fam: 'shield', gap: 12, g: 'm08-scales', mo: 'shimmer', x: '-', car: 'train' });
  M('venom-spit', plain, { nm: 'venom spit', desc: 'a gaping snout spitting a widening fan of venom droplets', fam: 'drip', gap: 14, g: 'm08-spit', mo: 'm08-spray', x: '-', car: 'comet' });
  /* komodo pup */
  M('komodo-pup', plain, { nm: 'komodo pups', desc: 'gangly sand-spotted young komodos with big heads and long yellow forked tongues, scampering; the chain scampers tongue-first leaving sand prints', fam: 'bite', gap: 18, g: 'm08-kpup', mo: 'm08-scamper', x: '-', car: 'custom', carDraw: carPup });
  M('drool-string', plain, { nm: 'drool strings', desc: 'jaw edges with sticky drool strings sagging out, beads sliding down and dropping', fam: 'drip', gap: 12, g: 'm08-drool', mo: 'm08-drool', x: '-', car: 'thread' });
  M('sand-eye', plain, { nm: 'sand eyes', desc: 'low sand mounds with a pup\'s eye and brow peeping out, blinking and glancing', fam: 'shield', gap: 14, g: 'm08-sandeye', mo: 'm08-peek', x: '-', car: 'blink' });
  /* smooth snake */
  M('smooth-coil', plain, { nm: 'smooth coils', desc: 'pale grey smooth snakes in flat double coils that tighten, round-pupilled heads on top; the chain is a glossy snake slithering the edge', fam: 'web', gap: 14, g: 'm08-coil', mo: 'm08-squeeze', x: '-', car: 'custom', carDraw: slither(0, '#141418', 1.6, 0) });
  M('warm-stone', plain, { nm: 'sunning stones', desc: 'flat sun-warmed stones with a smooth snake draped across, heat shimmer rising', fam: 'mend', gap: 18, g: 'm08-stone', mo: 'm08-bask', x: '-', car: 'train' });
  /* water snake */
  M('banded-swim', water, { nm: 'banded swimmers', desc: 'olive snakes with dark crossbands swimming the surface in an S, flat heads lifted; the chain slithers with little ripple marks', fam: 'ripple', gap: 18, g: 'm08-bandsnake', mo: 'm08-swimsnake', x: '-', car: 'custom', carDraw: slither(1, '#141418', 2.2, 1) });
  M('reed-weave', plain, { nm: 'reed weaves', desc: 'three reed stems standing out of the edge, the banded snake weaving in and out between them', fam: 'leaf', gap: 14, g: 'm08-reed', mo: 'm08-weave', x: '-', car: 'train' });
  /* tree snake */
  M('vine-drape', plain, { nm: 'draped tree snakes', desc: 'slim bright-green snakes draped from boughs in loose loops, letting go further each beat; the chain bridges a vine along the edge', fam: 'thrust', gap: 16, g: 'm08-vinesnake', mo: 'm08-drape', x: '-', car: 'custom', carDraw: slither(4, '#141418', 1.2, 4) });
  M('leaf-mimic', plain, { nm: 'leaf mimics', desc: 'sprays of pointed green leaves where one leaf turns out to be a snake head, eye glinting, red tongue', fam: 'leaf', gap: 14, g: 'm08-leafmimic', mo: 'm08-rustle', x: '-', car: 'flutter' });
  /* night adder */
  M('zigzag-adder', plain, { nm: 'zigzag adders', desc: 'thick short adders with a dark zigzag back and red eyes, drawn back in an S then striking; the chain crosses a night road, red eyes glinting', fam: 'thrust', gap: 16, g: 'm08-adder', mo: 'm08-sstrike', x: '-', car: 'custom', carDraw: slither(2, '#ff5040', 1.4, 2) });
  M('red-eye', plain, { nm: 'red eyes', desc: 'two red eyes glowing out of a dark coil, blinking slowly, a dim halo', fam: 'sparkle', gap: 14, g: 'm08-redeye', mo: 'm08-glow', x: '-', car: 'blink' });
  M('warm-road', plain, { nm: 'warm roads', desc: 'strips of warm night road with a pale centre dash, heat rising and an adder lying along it', fam: 'thorn', gap: 16, g: 'm08-road', mo: 'm08-heat', x: '-', car: 'train' });
  /* dust sidewinder */
  M('sidewind-track', heat, { nm: 'sidewinder tracks', desc: 'pale sidewinders lying slanted across the edge with rows of J-shaped tracks behind, stepping sideways in heat shimmer; the chain presses J-tracks one by one', fam: 'slash', gap: 18, g: 'm08-sidewind', mo: 'm08-sidewind', x: '-', car: 'custom', carDraw: carSidewind });
  M('horn-peek', plain, { nm: 'horned peeks', desc: 'a sidewinder head peeking out of the sand with two little horns over the eyes, sand trickling off', fam: 'shield', gap: 14, g: 'm08-horn', mo: 'm08-horn', x: '-', car: 'blink' });
  /* dune racer */
  M('racer-streak', heat, { nm: 'racer streaks', desc: 'long thin pale racers stretched dead straight with a tan side stripe, darting fast with speed dashes; the chain is a striped streak with speed lines', fam: 'shock', gap: 22, g: 'm08-racer', mo: 'm08-dart', x: '-', car: 'custom', carDraw: slither(3, '#141418', .5, 3) });
  M('mirage-shimmer', plain, { nm: 'mirages', desc: 'heat-mirage wavy lines with a dotted ghost racer wavering inside, flickering out', fam: 'sparkle', gap: 16, g: 'm08-mirage', mo: 'm08-mirage', x: '-', car: 'blink' });
})();
