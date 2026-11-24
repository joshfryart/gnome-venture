/* Motif module: the four stat pieces' own-edge effects and chain effects, written like claude/pf-anim/motifs/medium_m01.js.
   Loaded Die (Item): gold glints twinkling on the edge (the die itself pops out of the piece: motifs/stat_fx.js).
   Sidestep (Trick, Quick): footprints stamping left-right along the edge, dust flicks off each stamp, speed ticks sliding past.
   Old Saying (Trick, Lore): ink letters lifting off the edge, a quill flourish curling out, a faint dithered ink-glow hugging the edge.
   Sharp Eye (Guard, Keeper): gold glint stars and slow-blinking eyes drifting along the edge over a steady guard-hold shimmer.
   Every draw is a stateless function of p (hash noise only); glyphs go through H.glyph (MAXG budget); coordinates (a, b) = along the tangent, out along the normal. */
(function () {
  var INKC = '#2a1a10', SHIM = '#a9d6ea', WH = '#ffffff';
  /* 3 x 5 pixel letters for the Saying (rows top to bottom, 3 bits each) */
  var LET = ['010101111101101', '110101110101110', '011100100100011', '010101101101010', '011100010001110', '101101111111101', '101101010010010', '110101110101101'];   // A B C O S W Y R

  /* ---------- shared own-edge composition: the page's themedOwn() with this module's glyph / motion, plus optional per-glyph and per-run extras (as medium_m01.js) ---------- */
  function comp(c, e, H, per, deco) {
    var runs = e.runs, mp = e.mp, M = e.M, z = e.z, p = e.p, pp = p * mp.spd, Q = H.Q, G = H.G, P = e.P,
      ri, k, r, len, n, f, ph, sf, bx0, by0, nx, ny, x, y, fr;
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

  /* ---------- glyphs ---------- */
  PFA.glyph('gv-glint', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a 4-point glint star that swells and shrinks (fr 0..3) */
    var L = [1, 2, 3 + (z > 0 ? 1 : 0), 2][fr & 3];
    K.bx(c, x - L, y, 2 * L + 1, 1, C); K.bx(c, x, y - L, 1, 2 * L + 1, C); K.px(c, x, y, WH);
    if (L > 2) { K.px(c, x - 1, y - 1, Hi); K.px(c, x + 1, y + 1, Hi); }
  });
  PFA.glyph('gv-foot', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a little footprint pointing along the edge; fr bit 1 = left / right foot, bit 0 = just stamped (bigger, dust ring) */
    var sd = fr & 2 ? 1 : -1, big = !(fr & 1), a, b, s = big ? 1 : 0;
    for (a = -2 - s; a <= 1; a++) for (b = -1; b <= 1; b++) { if ((a === -2 - s || a === 1) && b !== 0) continue; P2(c, K, x, y, tx, ty, nx, ny, a, b * sd, C); }
    P2(c, K, x, y, tx, ty, nx, ny, 3, -1 * sd, C); P2(c, K, x, y, tx, ty, nx, ny, 3, 1 * sd, C); P2(c, K, x, y, tx, ty, nx, ny, 3 + s, 0, C);
    P2(c, K, x, y, tx, ty, nx, ny, 0, 2 * sd, Hi); P2(c, K, x, y, tx, ty, nx, ny, -1, 2 * sd, Hi);
    if (big) { P2(c, K, x, y, tx, ty, nx, ny, -5, -2, A); P2(c, K, x, y, tx, ty, nx, ny, -5, 2, A); P2(c, K, x, y, tx, ty, nx, ny, 5, -2, A); P2(c, K, x, y, tx, ty, nx, ny, 5, 2, A); }
  });
  PFA.glyph('gv-letter', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* one ink letter (upright, so it reads), a pale glow pixel behind; fr >> 1 picks the letter, bit 0 wobbles it */
    var bits = LET[(fr >> 1) % LET.length], i, ox = x - 1 + (fr & 1 ? 1 : 0), oy = y - 2;
    for (i = 0; i < 15; i++) if (bits.charAt(i) === '1') { K.px(c, ox + (i % 3), oy + ((i / 3) | 0), C); if (z > 0) K.px(c, ox + (i % 3) + 1, oy + ((i / 3) | 0), A); }
    K.px(c, ox - 1, oy + 5, Hi); K.px(c, ox + 3, oy - 1, Hi);
  });
  PFA.glyph('gv-quill', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a quill feather leaning back from its nib (screen up-right), barbs on one side */
    var i;
    for (i = 0; i < 7; i++) { K.px(c, x + i, y - i, i < 2 ? A : Hi); if (i > 1) { K.px(c, x + i + 1, y - i + 1 + (fr & 1), C); if (i > 3) K.px(c, x + i - 1, y - i - 1, C); } }
    K.px(c, x - 1, y + 1, A);
  });
  PFA.glyph('gv-watch', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* Sharp Eye: fr bit 2 = an eye (bits 0-1: open, half, shut), else a glint star (bits 0-1: size) */
    if (!(fr & 4)) { K.glyph(c, 'gv-glint', x, y, z, fr & 3, C, A, Hi, tx, ty, nx, ny); return; }
    var st = fr & 3, w = 3 + (z > 0 ? 1 : 0);
    if (st === 0) {
      K.bx(c, x - w + 1, y - 2, 2 * w - 1, 1, A); K.bx(c, x - w + 1, y + 2, 2 * w - 1, 1, A); K.px(c, x - w, y - 1, A); K.px(c, x + w, y - 1, A); K.px(c, x - w, y + 1, A); K.px(c, x + w, y + 1, A); K.px(c, x - w - 1, y, A); K.px(c, x + w + 1, y, A);
      K.bx(c, x - w + 1, y - 1, 2 * w - 1, 3, WH); K.bx(c, x - w, y, 2 * w + 1, 1, WH); K.bx(c, x - 1, y - 1, 3, 3, C); K.px(c, x, y, A); K.px(c, x - 1, y - 1, WH);
    } else if (st === 1) { K.bx(c, x - w, y - 1, 2 * w + 1, 1, A); K.bx(c, x - w + 1, y, 2 * w - 1, 1, WH); K.bx(c, x - 1, y, 3, 1, C); K.bx(c, x - w, y + 1, 2 * w + 1, 1, A); }
    else { K.bx(c, x - w - 1, y, 2 * w + 3, 1, A); K.px(c, x - 2, y + 1, A); K.px(c, x, y + 1, A); K.px(c, x + 2, y + 1, A); }
  });

  /* ---------- motions ---------- */
  PFA.motion('gv-twinkle', function (G, pp, k, ph) { G.s += pp * .04; G.t += Math.sin(pp * 3 + k * 1.7) * 1.5; G.fr = (Math.floor(pp * 7 + ph * 6) + k) & 3; });   /* the glints swell and shrink in turn, drifting a little */
  PFA.motion('gv-skip', function (G, pp, k, ph) {                                     /* step, step: each print stamps, holds, and the next lands one stride on, left and right in turn */
    var q = pp * 3 + ph * 2, st = Math.floor(q), f = q - st, lr = (st + k) & 1;
    G.s += st * .07; G.d += lr ? 3 : 0; G.fr = (f < .22 ? 0 : 1) | (lr << 1); if (f < .12) G.up += (1 - f / .12) * 2;
  });
  PFA.motion('gv-write', function (G, pp, k, ph) { G.t += Math.sin(pp * 5 + k) * 2; G.up += pp * 2; G.fr = (((k * 3 + Math.floor(ph * 8)) % 8) << 1) | ((Math.floor(pp * 8) + k) & 1); });   /* letters float up, swaying */
  PFA.motion('gv-watch', function (G, pp, k, ph) {                                    /* slow drift; odd slots are eyes that blink now and then, even slots glint stars that twinkle */
    G.s += pp * .06; G.t += Math.sin(pp * 2 + k) * 1.5;
    if (k & 1) { var w = (pp * .9 + ph) % 1; G.fr = 4 | (w < .78 ? 0 : w < .84 ? 1 : w < .9 ? 2 : 1); }
    else G.fr = [0, 1, 2, 3, 2, 1][(Math.floor(pp * 7 + ph * 6)) % 6];
  });

  /* ---------- per-glyph and per-run extras ---------- */
  function decoDie(c, e, H, s0, len, ri, pp) {                       /* gold glints twinkling just off the edge */
    var k, u, Q = H.Q;
    for (k = 0; k < 4; k++) { u = (pp * 1.3 + H.hash(e.seed + k * 5)) % 1; e.P.atq(s0 + len * H.hash(e.seed + k * 11 + ri)); H.glyph(c, 'gv-glint', Q.x + Q.nx * 7, Q.y + Q.ny * 7, 0, Math.floor(u * 4) & 3, e.hi, e.acc, H.WHITE, -Q.ny, Q.nx, Q.nx, Q.ny); }
  }
  function perDust(c, e, H, x, y, tx, ty, nx, ny, fr, k) {           /* a dust flick kicked back off each fresh stamp */
    if (fr & 1) return; var i; for (i = 0; i < 3; i++) H.px(c, x - tx * (5 + i * 2) + nx * (1 + i), y - ty * (5 + i * 2) + ny * (1 + i) - i, i ? e.acc : e.hi);
  }
  function decoTicks(c, e, H, s0, len, ri, pp) {                     /* speed ticks sliding along the edge, flashing every other frame */
    var k, s, j, Q = H.Q, fl = Math.floor(pp * 14);
    if (e.p > .94) return;
    for (k = 0; k < 3; k++) { if ((fl + k) % 3 === 0) continue; s = s0 + ((H.hash(e.seed + k * 13 + ri) * len - pp * 60) % len + len) % len;
      for (j = 0; j < 5; j++) { e.P.atq(s - j); H.px(c, Q.x + Q.nx * (11 + (k & 1) * 3), Q.y + Q.ny * (11 + (k & 1) * 3), j < 2 ? e.hi : e.acc); } }
  }
  function decoInk(c, e, H, s0, len, ri, pp) {                       /* faint ink-glow dithered along the edge; on the first run a quill flourish curls out and the quill rides its tip */
    var s, Q = H.Q, env = Math.sin(Math.PI * Math.min(1, e.p)), k, u, X, Y, a, r;
    for (s = 0; s < len; s += 2) if (H.hash(s * .37 + ri * 5 + Math.floor(pp * 6)) < .5 * env) { e.P.atq(s0 + s); H.px(c, Q.x + Q.nx * (1 + (s & 2 ? 1 : 0)), Q.y + Q.ny * (1 + (s & 2 ? 1 : 0)), e.hi); }
    if (ri !== 0) return;
    u = H.eo(Math.min(1, e.p * 1.4)); e.P.atq(s0 + len * .3); X = Q.x + Q.nx * 5; Y = Q.y + Q.ny * 5;
    for (k = 0; k < 26 * u; k++) { a = k * .32; r = 1 + k * .38; if (e.p > .85 && H.hash(k + Math.floor(e.p * 40)) > (1 - e.p) / .15) continue; H.px(c, X + Math.cos(a) * r + k * .5, Y - Math.sin(a) * r * .8 - k * .3, k > 22 ? e.acc : e.col); }
    if (e.p < .9) { k = Math.max(0, Math.floor(26 * u) - 1); a = k * .32; r = 1 + k * .38; H.glyph(c, 'gv-quill', X + Math.cos(a) * r + k * .5, Y - Math.sin(a) * r * .8 - k * .3, 0, Math.floor(pp * 10) & 1, e.col, e.acc, e.hi, 1, 0, 0, -1); }
  }
  function decoShimmer(c, e, H, s0, len, ri, pp) {                   /* guard-hold: a steady dotted rim that crawls slowly, one white spark running round it */
    var s, Q = H.Q, ph = Math.floor(pp * 5), env = Math.min(1, Math.sin(Math.PI * Math.min(1, e.p)) * 3);
    for (s = 0; s < len; s += 3) { if (((s / 3 | 0) + ph) % 3 === 0 || !H.stip(env, s, e.p)) continue; e.P.atq(s0 + s); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, SHIM); }
    e.P.atq(s0 + ((pp * .35) % 1) * len); H.sq(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, 2, WH);
  }

  /* ---------- custom chain effects (carDraw: along the path from e.a over e.d, eased e.hh) ---------- */
  function carDie(c, e, H) {                                         /* a glint hops three times to the linked piece (the die itself is the piece's own effect, stat_fx.js) */
    var P = e.P, Q = H.Q, k, u;
    for (k = 1; k <= 3; k++) { u = k / 3; if (e.hh < u - .02) break; P.atq(e.a + e.d * u); H.glyph(c, 'gv-glint', Q.x + Q.nx * 3, Q.y + Q.ny * 3, 0, Math.min(3, Math.floor((e.hh - u + .1) * 20)) & 3, e.hi, e.acc, H.WHITE, -Q.ny, Q.nx, Q.nx, Q.ny); }
    H.carHead(c, P, e.a + e.d * e.hh, 'gv-glint', e.z, Math.floor(e.p * 16) & 3, 0, -Math.abs(Math.sin(e.hh * Math.PI * 3)) * 12, e.col, e.acc, e.hi);
  }
  function carInk(c, e, H) {                                         /* an ink line writes itself along the path, the quill at its head */
    var P = e.P, Q = H.Q, u, X = 0, Y = 0;
    for (u = 0; u <= e.hh; u += .015) { P.atq(e.a + e.d * u); X = Q.x + Q.nx * (4 + Math.sin(u * 18) * 1.5); Y = Q.y + Q.ny * (4 + Math.sin(u * 18) * 1.5); H.px(c, X, Y, e.col); if (((u * 66) | 0) % 5 === 0) H.px(c, X, Y - 1, e.hi); }
    if (e.p < .95) H.glyph(c, 'gv-quill', X, Y, 0, Math.floor(e.p * 20) & 1, e.col, e.acc, e.hi, 1, 0, 0, -1);
  }

  PFA.motif('gv-loaded-die', function (c, e, H) { comp(c, e, H, null, decoDie); }, { nm: 'loaded dice', desc: 'gold glints twinkling on the edge (the die pops out of the piece: stat_fx.js)', fam: 'sparkle', gap: 26, g: 'gv-glint', mo: 'gv-twinkle', x: '-', car: 'custom', carDraw: carDie });
  PFA.motif('gv-sidestep', function (c, e, H) { comp(c, e, H, perDust, decoTicks); }, { nm: 'quick feet', desc: 'little footprints stamping left-right along the edge, dust flicks off each stamp, speed ticks sliding past', fam: 'puff', gap: 22, g: 'gv-foot', mo: 'gv-skip', x: '-', car: 'zig' });
  PFA.motif('gv-old-saying', function (c, e, H) { comp(c, e, H, null, decoInk); }, { nm: 'ink letters', desc: 'ink letters lifting off the edge, a quill flourish curling out, a faint ink-glow on the edge', fam: 'ripple', gap: 22, g: 'gv-letter', mo: 'gv-write', x: '-', car: 'custom', carDraw: carInk });
  PFA.motif('gv-sharp-eye', function (c, e, H) { comp(c, e, H, null, decoShimmer); }, { nm: 'watchful glints', desc: 'glint stars and slow-blinking eyes drifting along the edge over a steady guard shimmer', fam: 'shield', gap: 24, g: 'gv-watch', mo: 'gv-watch', x: '-', car: 'blink' });
})();
