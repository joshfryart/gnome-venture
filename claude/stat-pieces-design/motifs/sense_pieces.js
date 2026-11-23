/* Motif module (mock-up only, not in the game yet): own-edge effects and chain effects of five Sense tier pieces, written like engine2's stat_pieces.js.
   Soft Spot (Hurt, Pierce): chalk X marks drawing themselves stroke by stroke and thrust along the edge, a chalk ring and little bark cracks on fire.
   Not Fooled (Guard, mind): narrow eyes under a raised eyebrow, glancing left and right; the slots shake "no" together; small crossed-out sparks pop off.
   Saw It Coming (Guard, Hold): little shields with an open eye on the rim that blink, a steady guard rim, crack shards thrown off on fire.
   Snare Field (Soothe, craft): coiled loops of twine along the edge that tighten and spring; a dry leaf now and then, a glint where a loop snaps.
   Eyes of the Wood (Item, Keeper): leaf eyes peeking out of the edge, opening one after another, gold irises glancing; leaves drifting.
   Every draw is a stateless function of p (hash noise only); glyphs go through H.glyph (MAXG budget); coordinates (a, b) = along the tangent, out along the normal. */
(function () {
  var INK = '#2a1a10', WH = '#ffffff', SHIM = '#f2c9b8', LEAF = '#6a8f3c', LEAFD = '#3d5a1e';

  /* ---------- shared own-edge composition (as engine2's stat_pieces.js) ---------- */
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
  /* a small open / half / shut eye, upright so it reads (st 0 open, 1 half, 2 shut); gx = glance -1, 0, 1 */
  function eye(c, K, x, y, w, st, gx, iris, rim) {
    if (st === 0) {
      K.bx(c, x - w + 1, y - 2, 2 * w - 1, 1, rim); K.bx(c, x - w + 1, y + 2, 2 * w - 1, 1, rim); K.px(c, x - w, y - 1, rim); K.px(c, x + w, y - 1, rim); K.px(c, x - w, y + 1, rim); K.px(c, x + w, y + 1, rim); K.px(c, x - w - 1, y, rim); K.px(c, x + w + 1, y, rim);
      K.bx(c, x - w + 1, y - 1, 2 * w - 1, 3, WH); K.bx(c, x - w, y, 2 * w + 1, 1, WH); K.bx(c, x - 1 + gx, y - 1, 3, 3, iris); K.px(c, x + gx, y, INK); K.px(c, x - 1 + gx, y - 1, WH);
    } else if (st === 1) { K.bx(c, x - w, y - 1, 2 * w + 1, 1, rim); K.bx(c, x - w + 1, y, 2 * w - 1, 1, WH); K.bx(c, x - 1 + gx, y, 3, 1, iris); K.bx(c, x - w, y + 1, 2 * w + 1, 1, rim); }
    else { K.bx(c, x - w - 1, y, 2 * w + 3, 1, rim); K.px(c, x - 2, y + 1, rim); K.px(c, x, y + 1, rim); K.px(c, x + 2, y + 1, rim); }
  }

  /* ---------- glyphs ---------- */
  PFA.glyph('gv-chalkx', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* Soft Spot: a chalk X drawn stroke by stroke (fr 0: first stroke half, 1: first stroke, 2: both, 3: both + a pale ring tick) */
    var L = 2 + (z > 0 ? 1 : 0), i;
    for (i = -L; i <= L; i++) { if (fr === 0 && i > 0) break; K.px(c, x + i, y + i, C); K.px(c, x + i + 1, y + i, A); }
    if (fr >= 2) for (i = -L; i <= L; i++) { K.px(c, x + i, y - i, C); K.px(c, x + i + 1, y - i, A); }
    if (fr === 3) { K.px(c, x - L - 2, y, Hi); K.px(c, x + L + 2, y, Hi); K.px(c, x, y - L - 2, Hi); K.px(c, x, y + L + 2, Hi); }
  });
  PFA.glyph('gv-brow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* Not Fooled: a narrowed eye under one raised eyebrow; fr bit 0 = brow up, bits 1-2 = glance (0 centre, 1 left, 2 right) */
    var g = (fr >> 1) & 3, gx = g === 1 ? -1 : g === 2 ? 1 : 0, up = fr & 1 ? 2 : 0, w = 3 + (z > 0 ? 1 : 0);
    K.bx(c, x - w, y, 2 * w + 1, 1, A); K.bx(c, x - w + 1, y + 1, 2 * w - 1, 1, WH); K.bx(c, x - 1 + gx, y + 1, 3, 1, C); K.px(c, x + gx, y + 1, INK); K.bx(c, x - w + 1, y + 2, 2 * w - 1, 1, A);   /* the narrowed eye */
    K.px(c, x - w - 1, y - 2 - up, A); K.px(c, x - w, y - 3 - up, A); K.bx(c, x - w + 1, y - 4 - up, w, 1, A); K.px(c, x + 1, y - 3 - up, A); K.px(c, x + 2, y - 2 - (up >> 1), A); K.px(c, x + 3, y - 2, Hi);   /* the arched brow */
  });
  PFA.glyph('gv-nox', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a tiny crossed-out spark (a combo called off) */
    K.px(c, x - 1, y - 1, C); K.px(c, x + 1, y + 1, C); K.px(c, x + 1, y - 1, C); K.px(c, x - 1, y + 1, C); K.px(c, x, y, Hi);
    if (fr & 1) { K.px(c, x - 2, y - 2, A); K.px(c, x + 2, y + 2, A); K.px(c, x + 2, y - 2, A); K.px(c, x - 2, y + 2, A); }
  });
  PFA.glyph('gv-shieldeye', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) { /* Saw It Coming: a small heater shield, an eye on its rim (fr 0 open, 1 half, 2 shut) */
    var w = 3 + (z > 0 ? 1 : 0), i;
    for (i = 0; i <= w + 3; i++) { var hw = i < w ? w : w - (i - w + 1); if (hw < 0) break; K.bx(c, x - hw - 1, y - 2 + i, 2 * hw + 3, 1, A); }
    for (i = 0; i <= w + 2; i++) { var hv = i < w ? w : w - (i - w + 1); if (hv < 0) break; K.bx(c, x - hv, y - 1 + i, 2 * hv + 1, 1, i === 0 ? Hi : C); }
    eye(c, K, x, y - 3, 2, fr % 3, 0, INK, A);
  });
  PFA.glyph('gv-shard', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a crack shard (a creature piece knocked off) */
    K.px(c, x, y, C); K.px(c, x + 1, y, C); K.px(c, x, y + 1, A); if (fr & 1) K.px(c, x - 1, y - 1, Hi); else K.px(c, x + 2, y - 1, Hi);
  });
  PFA.glyph('gv-loop', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* Snare Field: a coiled loop of twine, open (fr 0), tightening (1), snapped shut with a glint (2), springing out (3) */
    var r = [3, 2, 1, 4][fr & 3] + (z > 0 ? 1 : 0), k, a, X, Y;
    for (k = 0; k < 16; k++) { a = k / 16 * Math.PI * 2; X = Math.round(x + Math.cos(a) * r); Y = Math.round(y - r + Math.sin(a) * r * .8); K.px(c, X, Y, k % 4 === 0 ? A : C); }
    P2(c, K, x, y, tx, ty, nx, ny, 0, 0, C); P2(c, K, x, y, tx, ty, nx, ny, -1, -1, A); P2(c, K, x, y, tx, ty, nx, ny, 1, -1, C); P2(c, K, x, y, tx, ty, nx, ny, 2, -2, A);   /* the knot and its tail into the edge */
    if ((fr & 3) === 2) { K.px(c, x + r + 1, y - r - 1, WH); K.px(c, x + r + 2, y - r - 2, Hi); }
  });
  PFA.glyph('gv-leafeye', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* Eyes of the Wood: a leaf whose middle opens as an eye; fr 0 shut, 1 half, 2 open, 3 open glancing */
    var L = 4 + (z > 0 ? 1 : 0), i, hw;
    for (i = -L; i <= L; i++) { hw = Math.round((L - Math.abs(i)) * .6) + 1; K.bx(c, x + i, y - hw, 1, 2 * hw + 1, C); }
    K.px(c, x - L - 1, y, A); K.px(c, x + L + 1, y - 1, A); K.px(c, x + L + 2, y - 2, A);   /* tip and stalk */
    var st = fr & 3;
    if (st === 0) K.bx(c, x - 2, y, 5, 1, A);
    else if (st === 1) { K.bx(c, x - 2, y, 5, 1, WH); K.px(c, x, y, A); K.bx(c, x - 2, y - 1, 5, 1, A); }
    else { K.bx(c, x - 2, y - 1, 5, 3, WH); K.px(c, x - 3, y, A); K.px(c, x + 3, y, A); var gx = st === 3 ? -1 : 0; K.bx(c, x - 1 + gx, y - 1, 2, 3, Hi); K.px(c, x + gx, y, INK); }
  });

  /* ---------- motions ---------- */
  PFA.motion('gv-mark', function (G, pp, k, ph) { var q = (pp * 2.2 + ph) % 1; G.fr = q < .18 ? 0 : q < .36 ? 1 : q < .8 ? 2 : 3; G.t += Math.sin(pp * 3 + k) * 1; });   /* each X draws in, holds, rings */
  PFA.motion('gv-headshake', function (G, pp, k, ph) {                                   /* every eye glances left, right, left together ("no"), the brow up while it does */
    var q = (pp * 1.1) % 1, sh = q > .5 && q < .8;
    G.t += sh ? (Math.floor(pp * 26) & 1 ? 2 : -2) : 0; G.fr = (sh ? 1 : 0) | ((sh ? (Math.floor(pp * 13) & 1 ? 1 : 2) : 0) << 1);
  });
  PFA.motion('gv-wink', function (G, pp, k, ph) { var w = (pp * .8 + ph) % 1; G.fr = w < .82 ? 0 : w < .87 ? 1 : w < .93 ? 2 : 1; G.t += Math.sin(pp * 2 + k) * .8; });   /* steady watch, a blink now and then */
  PFA.motion('gv-coil', function (G, pp, k, ph) { var q = (pp * 1.6 + ph) % 1; G.fr = q < .45 ? 0 : q < .6 ? 1 : q < .7 ? 2 : 3; if (G.fr === 3) G.d += 3; });   /* loops tighten, snap, spring */
  PFA.motion('gv-peek', function (G, pp, k, ph) {                                        /* leaf eyes open one after another, glance, close */
    var q = (pp * .9 + k * .17 + ph * .2) % 1; G.fr = q < .2 ? 0 : q < .3 ? 1 : q < .6 ? 2 : q < .8 ? 3 : q < .9 ? 1 : 0; G.t += Math.sin(pp * 3 + k * 1.3) * 1.2;
  });

  /* ---------- per-run extras ---------- */
  function decoSoft(c, e, H, s0, len, ri, pp) {                      /* fire: a chalk ring scratched on the edge, three bark cracks running out from it */
    var Q = H.Q, env = Math.sin(Math.PI * Math.min(1, e.p)), k, j, X, Y, u;
    if (ri !== 0 || e.z < 1) return;
    e.P.atq(s0 + len * .5); X = Q.x + Q.nx * 9; Y = Q.y + Q.ny * 9; u = H.eo(Math.min(1, e.p * 1.6));
    for (k = 0; k < 20 * u; k++) H.px(c, X + Math.cos(k * .33) * 5, Y + Math.sin(k * .33) * 4, e.col);
    if (e.p > .45) for (k = 0; k < 3; k++) for (j = 0; j < 6 * env; j++) H.px(c, X + Math.cos(k * 2.1 + .4) * (5 + j) + (j & 1), Y + Math.sin(k * 2.1 + .4) * (4 + j), e.acc);
  }
  function perNo(c, e, H, x, y, tx, ty, nx, ny, fr, k) {             /* on fire, crossed-out sparks pop off the odd slots */
    if (e.z < 1 || !(k & 1)) return; var u = (e.p * 1.4 + k * .1) % 1; H.glyph(c, 'gv-nox', x + nx * (6 + 8 * u), y + ny * (6 + 8 * u) - 3 * u, 0, Math.floor(u * 6) & 1, e.hi, e.acc, WH, tx, ty, nx, ny);
  }
  function decoHold(c, e, H, s0, len, ri, pp) {                      /* the guard rim, steady (Hold); on fire, shards thrown off where the eye blinked */
    var s, Q = H.Q, ph = Math.floor(pp * 4), env = Math.min(1, Math.sin(Math.PI * Math.min(1, e.p)) * 3), k, u;
    for (s = 0; s < len; s += 3) { if (((s / 3 | 0) + ph) % 4 === 0 || !H.stip(env, s, e.p)) continue; e.P.atq(s0 + s); H.px(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2, SHIM); }
    if (e.z < 1) return;
    for (k = 0; k < 4; k++) { u = H.eo(Math.min(1, e.p * 1.3 - k * .05)); if (u <= 0 || e.p > .9) continue; e.P.atq(s0 + len * H.hash(e.seed + k * 7 + ri)); H.glyph(c, 'gv-shard', Q.x + Q.nx * (4 + 12 * u), Q.y + Q.ny * (4 + 12 * u) + 6 * u * u, 0, k, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny); }
  }
  function decoTwine(c, e, H, s0, len, ri, pp) {                     /* a twine line hugging the edge between the loops, and a dry leaf drifting off */
    var s, Q = H.Q, u, X, Y;
    for (s = 0; s < len; s += 2) if ((((s / 2) | 0) + Math.floor(pp * 6)) % 5) { e.P.atq(s0 + s); H.px(c, Q.x + Q.nx * (1 + Math.sin(s * .4) * .6), Q.y + Q.ny * (1 + Math.sin(s * .4) * .6), e.col); }
    if (ri) return; u = (pp * .7 + H.hash(e.seed)) % 1; e.P.atq(s0 + len * (.2 + .6 * H.hash(e.seed + 3)));
    X = Q.x + Q.nx * (6 + 10 * u) + Math.sin(u * 9) * 2; Y = Q.y + Q.ny * (6 + 10 * u) + 6 * u; H.bx(c, X - 1, Y, 3, 1, u < .5 ? '#a8792e' : '#7d5a22'); H.px(c, X, Y - 1, '#c9a26a');
  }
  function decoWood(c, e, H, s0, len, ri, pp) {                      /* leaves drifting down past the edge; on fire, a gold glint over each open eye */
    var k, u, Q = H.Q;
    for (k = 0; k < 2; k++) { u = (pp * .6 + H.hash(e.seed + k * 5 + ri)) % 1; e.P.atq(s0 + len * H.hash(e.seed + k * 9 + ri)); H.bx(c, Q.x + Q.nx * (8 + 4 * u) + Math.sin(u * 7 + k) * 3, Q.y + Q.ny * (8 + 4 * u) + 10 * u, 3, 1, k ? LEAF : LEAFD); }
    if (e.z < 1 || e.p > .85) return;
    for (k = 0; k < 3; k++) if ((Math.floor(pp * 10) + k) % 3 === 0) { e.P.atq(s0 + len * (k + .5) / 3); H.plus(c, Q.x + Q.nx * 12, Q.y + Q.ny * 12, 2, 1, e.hi); }
  }

  /* ---------- custom chain effects (carDraw: along the path from e.a over e.d, eased e.hh) ---------- */
  function carSoft(c, e, H) {                                        /* a chalk line scratches along, an X stamps at its head and rings when it arrives */
    var P = e.P, Q = H.Q, u, X = 0, Y = 0;
    for (u = 0; u <= e.hh; u += .02) { if (((u * 50) | 0) % 3 === 2) continue; P.atq(e.a + e.d * u); X = Q.x + Q.nx * 4; Y = Q.y + Q.ny * 4; H.px(c, X, Y, e.col); }
    H.glyph(c, 'gv-chalkx', X, Y, e.z, e.hh > .92 ? 3 : 2, e.col, e.acc, e.hi, 1, 0, 0, -1);
  }
  function carNo(c, e, H) {                                          /* a dotted eye-line runs out, a crossed spark at its head */
    var P = e.P, Q = H.Q, u, X = 0, Y = 0;
    for (u = 0; u <= e.hh; u += .03) { P.atq(e.a + e.d * u); X = Q.x + Q.nx * 4; Y = Q.y + Q.ny * 4; if ((((u * 33) | 0) + Math.floor(e.p * 12)) % 2) H.px(c, X, Y, e.col); }
    H.glyph(c, 'gv-brow', X, Y - 2, e.z, 1 | ((Math.floor(e.p * 10) & 1 ? 1 : 2) << 1), e.col, e.acc, e.hi, 1, 0, 0, -1);
  }
  function carEye(c, e, H) {                                         /* the shield-eye blinks its way along in three hops, crack ticks where it lands */
    var P = e.P, Q = H.Q, k, u;
    for (k = 1; k <= 3; k++) { u = k / 3; if (e.hh < u - .02) break; P.atq(e.a + e.d * u); H.glyph(c, 'gv-shard', Q.x + Q.nx * 3, Q.y + Q.ny * 3, 0, k, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny); }
    H.carHead(c, P, e.a + e.d * e.hh, 'gv-shieldeye', e.z, Math.floor(e.p * 9) % 3 === 2 ? 2 : 0, 0, -Math.abs(Math.sin(e.hh * Math.PI * 3)) * 6, e.col, e.acc, e.hi);
  }
  function carTwine(c, e, H) {                                       /* a twine line springs out with a slight sag and a loop at its head that snaps and glints on arrival */
    var P = e.P, Q = H.Q, u, X = 0, Y = 0;
    for (u = 0; u <= e.hh; u += .015) { P.atq(e.a + e.d * u); X = Q.x + Q.nx * (2 - Math.sin(u * Math.PI) * 3); Y = Q.y + Q.ny * (2 - Math.sin(u * Math.PI) * 3); H.px(c, X, Y, e.col); }
    H.glyph(c, 'gv-loop', X, Y, e.z, e.hh > .95 ? 2 : 3, e.col, e.acc, e.hi, 1, 0, 0, -1);
  }
  function carGaze(c, e, H) {                                        /* a leaf eye drifts along the path, leaves in its wake */
    var P = e.P, Q = H.Q, k, u;
    for (k = 1; k <= 4; k++) { u = e.hh - k * .06; if (u < 0) break; P.atq(e.a + e.d * u); H.bx(c, Q.x + Q.nx * 4 + Math.sin(e.p * 20 + k) * 2, Q.y + Q.ny * 4 + k, 3, 1, k & 1 ? LEAF : LEAFD); }
    H.carHead(c, P, e.a + e.d * e.hh, 'gv-leafeye', e.z, e.hh < .15 ? 1 : 2 + (Math.floor(e.p * 8) & 1), 0, 0, e.col, e.acc, e.hi);
  }

  PFA.motif('gv-soft-spot', function (c, e, H) { comp(c, e, H, null, decoSoft); }, { nm: 'chalk marks', desc: 'chalk X marks drawing themselves along the edge and thrusting out; on fire a chalk ring and bark cracks', fam: 'slash', gap: 20, g: 'gv-chalkx', mo: 'gv-mark', x: '-', car: 'custom', carDraw: carSoft });
  PFA.motif('gv-not-fooled', function (c, e, H) { comp(c, e, H, perNo, null); }, { nm: 'raised brows', desc: 'narrowed eyes under a raised eyebrow glancing left and right together (a no); crossed-out sparks pop off on fire', fam: 'shield', gap: 24, g: 'gv-brow', mo: 'gv-headshake', x: '-', car: 'custom', carDraw: carNo });
  PFA.motif('gv-saw-it-coming', function (c, e, H) { comp(c, e, H, null, decoHold); }, { nm: 'watching shields', desc: 'small shields with an eye on the rim, blinking now and then, over a steady guard rim; crack shards thrown off on fire', fam: 'shield', gap: 24, g: 'gv-shieldeye', mo: 'gv-wink', x: '-', car: 'custom', carDraw: carEye });
  PFA.motif('gv-snare-field', function (c, e, H) { comp(c, e, H, null, decoTwine); }, { nm: 'twine snares', desc: 'coiled loops of twine along the edge that tighten, snap with a glint and spring out; a dry leaf drifting', fam: 'web', gap: 20, g: 'gv-loop', mo: 'gv-coil', x: '-', car: 'custom', carDraw: carTwine });
  PFA.motif('gv-eyes-of-the-wood', function (c, e, H) { comp(c, e, H, null, decoWood); }, { nm: 'leaf eyes', desc: 'leaves along the border whose middles open as eyes, one after another, gold irises glancing; leaves drifting down', fam: 'leaf', gap: 20, g: 'gv-leafeye', mo: 'gv-peek', x: '-', car: 'custom', carDraw: carGaze });
})();
