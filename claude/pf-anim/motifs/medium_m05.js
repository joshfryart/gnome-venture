/* Motif module, medium batch m05 (shore-crab, ghost-crab, land-crab-march, palm-thief-crab, hermit-crab-hoarder, coconut-hermit,
   rock-crab-pincher, mud-crab-brawler, tide-crab-squire). TEMPLATE.md section 10.3.
   29 motifs (all crabs and their things), each with its own pixel glyph (ids prefixed m05-); new motions where the built-in ones did not fit;
   four motifs bring their own chain effect (carDraw: the red migration column, the ghost crab's afterimage dash, a rock crack the wedge crab
   squeezes along, a coconut house rolling to the next piece). Every crab gets its own signature motif; crab-clamp (one big claw) and
   surf-foam are shared secondaries tinted by each creature's palette.
   Crabs are drawn top-down from small sprite tables compiled ONCE at load (flat [dx, dy, colour] arrays); claws, fronds, fibres and cracks are
   drawn along the edge tangent / outward normal. Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation
   in the frame loops (scratch H.Q / H.G only). Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule,
   visual-only sound lines and the creature-heavy default are untouched (they live in the page). */
(function () {
  /* fixed accent colours (not palette tones): W white, N coconut, M milk, G gold, L leaf, R rock, K eye black, B cap red, U button blue,
     S sea glass, O hermit leg orange, P pool water, F coir fibre, Y regrowth green */
  var XC = [null, null, null, null, '#ffffff', '#9a6436', '#f6f2e6', '#f0c840', '#5aa844', '#8c8c94', '#121214', '#d8402e', '#4a7ad8', '#7ae0c8',
            '#f08a3a', '#4a90c8', '#c8a070', '#b8e078'];
  var CH = '.CAHWNMGLRKBUSOPFY';

  /* sprite compiler (load time only): rows of chars -> flat [dx, dy, ci, ...] */
  function S(rows) {
    var out = [], w = rows[0].length, h = rows.length, i, j, ci;
    for (j = 0; j < h; j++) for (i = 0; i < w; i++) { ci = CH.indexOf(rows[j].charAt(i)); if (ci > 0) out.push(i - (w >> 1), j - (h >> 1), ci); }
    return out;
  }
  function spr(c, s, x, y, C, A, Hi, K) {
    var i, ci;
    for (i = 0; i < s.length; i += 3) { ci = s[i + 2]; K.px(c, x + s[i], y + s[i + 1], ci === 1 ? C : ci === 2 ? A : ci === 3 ? Hi : XC[ci]); }
  }
  /* one pixel at (d along the outward normal, t along the tangent) from (x, y) */
  function at(c, K, x, y, nx, ny, tx, ty, d, t, col) { K.px(c, x + nx * d + tx * t, y + ny * d + ty * t, col); }
  /* a crab claw pointing outward: palm (3 wide), two fingers that open by `gap`, dark tips curving in */
  function claw(c, K, x, y, nx, ny, tx, ty, L, gap, C, A, Hi) {
    var d, t;
    for (d = 0; d < 3; d++) for (t = -1; t <= 1; t++) at(c, K, x, y, nx, ny, tx, ty, d, t, d === 1 && t === -1 ? Hi : C);
    for (d = 3; d < 3 + L; d++) { at(c, K, x, y, nx, ny, tx, ty, d, -1 - gap, C); at(c, K, x, y, nx, ny, tx, ty, d, 1 + gap, C); }
    at(c, K, x, y, nx, ny, tx, ty, 3 + L, -gap, A); at(c, K, x, y, nx, ny, tx, ty, 3 + L, gap, A);
  }

  /* ---------- sprite tables (built once) ---------- */
  var CRAB0 = S(['CC.....CC', '.C.A.A.C.', '..CCCCC..', 'A.CCHCC.A', '.ACCCCCA.', 'A.A...A.A']),
      CRAB1 = S(['C.C...C.C', '.C.A.A.C.', '..CCCCC..', '.ACCHCCA.', 'A.CCCCC.A', '.A.....A.']),
      DUG0 = S(['.A...A.', '.A...A.', '.CCCCC.', 'HHCHCHH', 'HHHHHHH']),
      DUG1 = S(['.......', '.A...A.', '.HCCCH.', 'HHHCHHH', 'HHHHHHH']),
      CLK0 = S(['C.C.C.C', 'C.C.C.C', 'CCC.CCC', '.C...C.', '.A...A.']),
      CLK1 = S(['.CC.CC.', 'CCC.CCC', 'CCC.CCC', '.C...C.', '.A...A.']),
      FOAM0 = S(['...WW..', '..W..W.', '.C.....', 'CC.....', 'CCCCCCC']),
      FOAM1 = S(['..WWW..', '.W...WW', 'C......', 'CC....W', 'CCCCCCC']),
      FOAM2 = S(['W.W..W.', '.WWW...', 'CC.W...', 'CCC....', 'CCCCCCC']),
      GHO0 = S(['KK...KK', '.A...A.', '.C...C.', 'CCCCCCC', '.CCHCC.', 'C.C.C.C']),
      GHO1 = S(['KK...KK', '.A...A.', '.C...C.', 'CCCCCCC', 'CCCHCCC', '.C.C.C.']),
      HOLE0 = S(['.......', '.......', '.K...K.', '.A...A.', 'AAAAAAA', '.AAAAA.']),
      HOLE1 = S(['.K...K.', '.A...A.', '.C...C.', 'CCCCCCC', 'AAAAAAA', '.AAAAA.']),
      HOLE2 = S(['C.K.K.C', 'CCA.ACC', '.CC.CC.', 'CCCCCCC', 'AAAAAAA', '.AAAAA.']),
      MIG0 = S(['CC.......CC', '.CC.K.K.CC.', '..CCCCCCC..', 'A.CCCHCCC.A', '.ACCCCCCCA.', 'A..A...A..A']),
      MIG1 = S(['CC.......CC', '.CC.K.K.CC.', '..CCCCCCC..', '.ACCCHCCCA.', 'A.CCCCCCC.A', '.A..A.A..A.']),
      CAR0 = S(['..CCCCC..', '.CHHCCCC.', 'CCCCACCCC', 'CCCCCCCCC', '.AAAAAAA.']),
      CAR1 = S(['..CCCCC..', '.CCCCHHC.', 'CCCCACCCC', 'CCCCCCCCC', '.AAAAAAA.']),
      SPW0 = S(['..WWW..', '.WCCCW.', 'WCCKCC.', 'CCKCCKC']),
      SPW1 = S(['.WWW...', 'WCCCWW.', 'CCKCCCW', 'CKCCKCC']),
      LEAF0 = S(['.......', '.LLLLL.', 'LLAAALL', '.LLLLL.', '..KKK..']),
      LEAF1 = S(['.LLLL..', 'LLAALL.', '.LLLL.C', '..KKKC.', '.KKKKK.']),
      ROB0 = S(['CC.......CC', 'C.C.....C.C', '.CC.K.K.CC.', '...CCCCC...', '.O.CCHCC.O.', 'O..CCCCC..O', '..O.O.O.O..']),
      ROB1 = S(['.CC.....CC.', 'CCC.....CCC', '.CC.K.K.CC.', '...CCCCC...', '.O.CCHCC.O.', 'O..CCCCC..O', '..O.O.O.O..']),
      COCO = [S(['..FNF..', '.NNNNN.', 'NNANANN', 'NNNANNN', '.NNNNN.', '..NNN..']),
              S(['..FNF..', '.NNWNN.', 'NNAWANN', 'NNNWNNN', '.NNWNN.', '..NNN..']),
              S(['.FN.NF.', 'NNM.MNN', 'NAM.MAN', 'NNM.MNN', '.NM.MN.', '..N.N..']),
              S(['FN...NF', 'NM...MN', 'NM.W.MN', 'NM...MN', '.N...N.', '.......'])],
      HRD0 = S(['.B..S.G..', 'BBUSSGG..', '.CCCCCC..', 'CCAAACCC.', 'CCACCACCO', 'CCCAACCOO', '.CCCCC.O.', '..O.O....']),
      HRD1 = S(['..B.S.G..', '.BBUSSGG.', '..CCCCCC.', '.CCAAACCC', '.CCACCACC', 'OCCCAACCO', '..CCCCCOO', '.O..O..O.']),
      VAC0 = S(['...CCC..', '..CAAC..', '.CCACCC.', 'OCCCACC.', 'OOCCCC..', '.O.O....']),
      VAC1 = S(['.....CC.', '....CAAC', 'OO.CCACC', 'OOOCCCAC', '.O..CCC.', '........']),
      JUNK = [S(['.BBB.', 'BWBWB', 'BBBBB', '.B.B.']), S(['.UUU.', 'UWUWU', 'UUUUU', '.UUU.']), S(['..S..', '.SSW.', 'SSSS.', '.SS..']), S(['.GGG.', 'GGWGG', 'GGGGG', '.GGG.'])],
      HOUSE0 = S(['..FFFFF..', '.NNFNFNN.', 'NNNNNNNNN', 'NNNNNNNNN', 'MMMMMMMMM', 'CC.C.C.CC']),
      HOUSE1 = S(['..FFFFF..', '.NFNNFNN.', 'NNNNNNNNN', 'NNNNNNNNN', 'MMMMMMMMM', '.CC.C.CC.']),
      SQ0 = S(['CW.....CC', '.C.K.K.C.', '..CCCCC..', 'A.CHHCC.A', '.ACHACCA.', 'A.A...A.A']),
      SQ1 = S(['CC.....WC', '.C.K.K.C.', '..CCCCC..', '.ACHHCCA.', 'A.CHACC.A', '.A.....A.']),
      LIM0 = S(['...H...', '..CHC..', '.CACAC.', 'CACHCAC', 'AAAAAAA']),
      LIM1 = S(['...W...', '..CWC..', '.CACAC.', 'CACHCAC', 'AAAAAAA']);

  /* ---------- glyphs (tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step; fr from the motion) ---------- */
  PFA.glyph('m05-sidler', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* green shore crab from above, claws snipping, legs ticking */
    spr(c, fr & 1 ? CRAB1 : CRAB0, x, y, C, A, Hi, K); if (z > 1) { K.px(c, x - 5, y + 1, A); K.px(c, x + 5, y + 1, A); }
  });
  PFA.glyph('m05-dugin', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* crab half sunk in sand, eyestalks up then ducking */
    spr(c, fr & 1 ? DUG1 : DUG0, x, y, C, A, Hi, K);
  });
  PFA.glyph('m05-clack', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* two claws raised high, clacking shut, click marks */
    spr(c, fr & 1 ? CLK1 : CLK0, x, y, C, A, Hi, K);
    if (fr & 1) { K.px(c, x - 4, y - 4, K.WHITE); K.px(c, x + 4, y - 4, K.WHITE); K.px(c, x - 5, y - 1, Hi); K.px(c, x + 5, y - 1, Hi); }
  });
  PFA.glyph('m05-foam', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a curling wavelet, white crest breaking into spray */
    spr(c, fr === 2 ? FOAM2 : fr === 1 ? FOAM1 : FOAM0, x, y, C, A, Hi, K); if (z > 0) K.px(c, x + 3, y - 3 - fr, K.WHITE);
  });
  PFA.glyph('m05-ghost', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* pale ghost crab, huge black eyes on stalks, two afterimage specks behind */
    spr(c, fr & 1 ? GHO1 : GHO0, x, y, C, A, Hi, K);
    K.px(c, x - tx * 6, y - ty * 6 + 1, Hi); K.px(c, x - tx * 9, y - ty * 9 + 1, Hi);
  });
  PFA.glyph('m05-hole', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* burrow mouth: eyestalks rise out, then the claws snap */
    spr(c, fr === 2 ? HOLE2 : fr === 1 ? HOLE1 : HOLE0, x, y, C, A, Hi, K); K.px(c, x - 4, y + 1, Hi); K.px(c, x + 4, y + 2, Hi);
  });
  PFA.glyph('m05-pellet', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a rolled sand ball, its light spot turning, grains trailing */
    var o = fr & 3;
    K.sq(c, x, y, 3 + (z >> 1), C); K.px(c, x + (o === 1 || o === 2 ? 1 : -1), y + (o >= 2 ? 1 : -1), K.WHITE);
    K.px(c, x - tx * 3, y - ty * 3, Hi); K.px(c, x - tx * 5 + nx, y - ty * 5 + ny, A);
  });
  PFA.glyph('m05-redcrab', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* broad red land crab front-on, black eyes, legs stepping */
    spr(c, fr & 1 ? MIG1 : MIG0, x, y, C, A, Hi, K);
  });
  PFA.glyph('m05-carapace', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a broad red back with a centre ridge, shine sliding */
    spr(c, fr & 1 ? CAR1 : CAR0, x, y, C, A, Hi, K); if (z > 1) { K.px(c, x - 5, y, C); K.px(c, x + 5, y, C); }
  });
  PFA.glyph('m05-spawn', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* surf crest with dark egg specks shaken into it */
    spr(c, fr & 1 ? SPW1 : SPW0, x, y, C, A, Hi, K); K.px(c, x - 2 + fr, y - 3, Hi);
  });
  PFA.glyph('m05-leafhole', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* a fallen leaf over a burrow; it lifts and a red claw peeks out */
    spr(c, fr & 1 ? LEAF1 : LEAF0, x, y, C, A, Hi, K);
  });
  PFA.glyph('m05-robber', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* blue-purple robber crab, oversized claws reaching then closing, orange legs */
    spr(c, fr & 1 ? ROB1 : ROB0, x, y, C, A, Hi, K); if (fr & 1) K.px(c, x, y - 4, K.WHITE);
  });
  PFA.glyph('m05-coconut', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* coconut: whole, crack, split showing white flesh, halves apart */
    spr(c, COCO[fr & 3], x, y, C, A, Hi, K);
    if ((fr & 3) === 3) { K.px(c, x - 1, y - 4, XC[6]); K.px(c, x + 1, y - 5, XC[6]); }
  });
  PFA.glyph('m05-seal', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* coconut halves closing up, a stitch of light along the seam */
    var f = fr & 3; spr(c, COCO[f], x, y, C, A, Hi, K);
    if (f === 0) { K.plus(c, x, y - 4, 1, 1, K.WHITE); K.px(c, x + 3, y, Hi); }
  });
  PFA.glyph('m05-frond', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a palm frond: midrib outward, leaflets drooping both sides */
    var L = 6 + z, j, sw = fr & 1 ? 1 : -1, cv;
    for (j = 0; j <= L; j++) { cv = j * j / (L * 5) * sw;
      at(c, K, x, y, nx, ny, tx, ty, j, cv, j < 2 ? XC[5] : XC[8]);
      if (j > 1 && j < L) { at(c, K, x, y, nx, ny, tx, ty, j - 1, cv - 2, XC[8]); at(c, K, x, y, nx, ny, tx, ty, j - 1, cv + 2, j & 1 ? Hi : XC[8]); } }
  });
  PFA.glyph('m05-fibre', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* coir husk fibres bristling outward from a brown husk knot */
    var L = 5 + z, j, s, cv;
    K.sq(c, x, y, 3, XC[5]);
    for (s = -1; s <= 1; s++) for (j = 1; j <= L; j++) { cv = s * j * .6 + (fr & 1 ? j * j / 20 : -j * j / 20);
      at(c, K, x, y, nx, ny, tx, ty, j + 1, cv, j === L ? Hi : XC[16]); }
  });
  PFA.glyph('m05-hoard', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* hermit shell piled with a bottle cap, sea glass and a coin, staggering */
    spr(c, fr & 1 ? HRD1 : HRD0, x, y, C, A, Hi, K);
  });
  PFA.glyph('m05-vacant', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* empty spiral shell; the soft hermit pops out beside it and back in */
    spr(c, fr & 1 ? VAC1 : VAC0, x, y, C, A, Hi, K); if (z > 1) K.px(c, x + 1, y - 3, K.WHITE);
  });
  PFA.glyph('m05-junk', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* tossed hoard: bottle cap, button, sea glass, coin turning over */
    spr(c, JUNK[fr & 3], x, y, C, A, Hi, K);
  });
  PFA.glyph('m05-cochouse', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {  /* half a coconut worn as a house, a white cut rim, crab legs below */
    spr(c, fr & 1 ? HOUSE1 : HOUSE0, x, y, C, A, Hi, K); if (z > 1) { K.px(c, x - 5, y + 2, C); K.px(c, x + 5, y + 2, C); }
  });
  PFA.glyph('m05-milk', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a coconut-milk drop, white with a cream rim */
    K.sq(c, x, y, 3 + (z >> 1), XC[6]); K.px(c, x, y - 2 - (z >> 1), XC[6]); K.px(c, x - 1, y - 1, K.WHITE); K.px(c, x + 1, y + 1 + (z >> 1), Hi);
    if (fr & 1) K.px(c, x + 2, y - 2, K.WHITE);
  });
  PFA.glyph('m05-wedge', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a rock crack; a flat wedge-shaped crab slides out of it, claws first */
    var t, e = fr === 0 ? 1 : fr === 1 ? 3 : 5, w;
    for (t = -4; t <= 4; t++) at(c, K, x, y, nx, ny, tx, ty, (t & 1) ? 0 : -1, t, A);
    for (w = 0; w < 3; w++) for (t = -(3 - w); t <= 3 - w; t++) at(c, K, x, y, nx, ny, tx, ty, e - 3 + w, t, w === 1 && t === 0 ? Hi : C);
    at(c, K, x, y, nx, ny, tx, ty, e, -2, C); at(c, K, x, y, nx, ny, tx, ty, e, 2, C); at(c, K, x, y, nx, ny, tx, ty, e + 1, -2, A); at(c, K, x, y, nx, ny, tx, ty, e + 1, 2, A);
    at(c, K, x, y, nx, ny, tx, ty, e - 1, -1, XC[10]); at(c, K, x, y, nx, ny, tx, ty, e - 1, 1, XC[10]);
  });
  PFA.glyph('m05-pool', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a rock pool: grey stones round blue water, weed swaying, claw tips peek */
    K.sq(c, x, y, 5, XC[15]); K.ringpx(c, x, y, 3, XC[9]);
    K.px(c, x - 1 + (fr & 1), y - 1, XC[8]); K.px(c, x - 1, y, XC[8]);
    if (fr === 1) { K.px(c, x + 1, y - 1, K.WHITE); K.px(c, x - 2, y + 1, K.WHITE); }
    else if (fr === 2) { K.px(c, x - 1, y - 4, C); K.px(c, x + 1, y - 4, C); K.px(c, x - 1, y - 5, A); K.px(c, x + 1, y - 5, A); }
  });
  PFA.glyph('m05-mitts', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* two heavy blunt crusher claws like boxing mitts, jabbing in turn */
    var s, d, j, t, b = 3 + (z >> 1);
    for (s = -1; s <= 1; s += 2) { j = (fr & 1) === (s > 0 ? 1 : 0) ? 3 : 0;
      for (d = 0; d < b; d++) for (t = 0; t < b; t++) at(c, K, x, y, nx, ny, tx, ty, d + j, s * (1 + t), d === b - 1 ? A : d === 1 && t === 0 ? Hi : C);
      if (j) at(c, K, x, y, nx, ny, tx, ty, b + j + 1, s * 2, K.WHITE); }
  });
  PFA.glyph('m05-mudball', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* a fat mud ball, dripping, then a splat */
    var f = fr % 3;
    if (f < 2) { K.sq(c, x, y, 4 + (z >> 1), C); K.px(c, x - 1, y - 1, Hi); K.px(c, x + 1, y + 3, A); if (f) K.px(c, x - 1, y + 4, A); }
    else { K.bx(c, x - 4, y, 9, 2, C); K.px(c, x - 5, y - 2, C); K.px(c, x + 5, y - 2, C); K.px(c, x, y - 2, A); K.px(c, x - 2, y + 2, A); }
  });
  PFA.glyph('m05-regrow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a new claw budding green and growing to full size */
    var f = Math.min(2, fr);
    if (f === 0) { at(c, K, x, y, nx, ny, tx, ty, 0, 0, XC[17]); at(c, K, x, y, nx, ny, tx, ty, 1, 0, XC[17]); at(c, K, x, y, nx, ny, tx, ty, 2, 0, K.WHITE); }
    else claw(c, K, x, y, nx, ny, tx, ty, f === 1 ? 1 : 2 + (z >> 1), f === 1 ? 0 : 1, f === 1 ? XC[17] : C, A, XC[17]);
  });
  PFA.glyph('m05-squire', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* small crab, stitched shell patch, polished claws with a gleam that swaps */
    spr(c, fr & 1 ? SQ1 : SQ0, x, y, C, A, Hi, K);
  });
  PFA.glyph('m05-limpet', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* a ridged limpet cone used as a little buckler, gleam at the peak */
    spr(c, fr & 1 ? LIM1 : LIM0, x, y, C, A, Hi, K); if (z > 1) { K.px(c, x - 4, y + 1, A); K.px(c, x + 4, y + 1, A); }
  });
  PFA.glyph('m05-clamp', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* one big crab claw pointing outward, fingers opening then snapping shut */
    claw(c, K, x, y, nx, ny, tx, ty, 2 + (z >> 1), fr & 1 ? 0 : 1, C, A, Hi); if (fr & 1) at(c, K, x, y, nx, ny, tx, ty, 6 + (z >> 1), 2, K.WHITE);
  });

  /* ---------- motions (mutate the scratch G; pp = time x speed, k = glyph index, ph = hash phase) ---------- */
  PFA.motion('m05-sidle', function (G, pp, k, ph) { var w = (pp * 2.4 + ph) % 1; G.t += (w < .5 ? w * 2 : 2 - w * 2) * 6 - 3; G.fr = (Math.floor(pp * 14) + k) & 1; });   /* sideways shuffle */
  PFA.motion('m05-duck', function (G, pp, k, ph) { G.fr = ((pp * 2 + ph) % 1) < .4 ? 1 : 0; G.d -= 1; });
  PFA.motion('m05-clack', function (G, pp, k, ph) { G.fr = ((pp * 3.5 + ph) % 1) > .6 ? 1 : 0; G.up += G.fr; });
  PFA.motion('m05-curl', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2.5 + ph) % 1) * 3); G.t += Math.sin(pp * 5 + k) * 1.5; });
  PFA.motion('m05-ghost', function (G, pp, k, ph, H) { G.s += pp * .5; G.fr = (Math.floor(pp * 20) + k) & 1; if (H.hash(k * 3.3 + Math.floor(pp * 14)) < .3) G.vis *= .35; });   /* fast run, flickering out */
  PFA.motion('m05-peek', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 1.8 + ph) % 1) * 3); G.d -= 1; });
  PFA.motion('m05-flick', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.up += Math.sin(w * Math.PI) * 7; G.fr = Math.floor(pp * 14) & 3; });
  PFA.motion('m05-migrate', function (G, pp, k) { G.s += pp * .3; G.fr = (Math.floor(pp * 12) + k) & 1; G.up += G.fr ? 0 : 1; });
  PFA.motion('m05-shine', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 1; });
  PFA.motion('m05-surge', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 9) + k) & 1; G.d += Math.sin(pp * 7 + ph * 4) * 2; });
  PFA.motion('m05-lift', function (G, pp, k, ph) { G.fr = ((pp * 1.6 + ph) % 1) > .5 ? 1 : 0; });
  PFA.motion('m05-sneak', function (G, pp, k, ph) { var w = (pp * 1.5 + ph) % 1; G.t += (w < .7 ? w / .7 : 1) * 5 - 2.5; G.fr = w > .7 ? 1 : 0; G.d += G.fr * 2; });   /* creep, stop, grab */
  PFA.motion('m05-crack', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.4 + ph) % 1) * 5)); });
  PFA.motion('m05-seal', function (G, pp, k, ph) { G.fr = 3 - Math.min(3, Math.floor(((pp * 1.2 + ph) % 1) * 5)); G.up += 1; });
  PFA.motion('m05-lug', function (G, pp, k) { G.s += pp * .07; G.fr = (Math.floor(pp * 5) + k) & 1; G.t += G.fr ? 1 : -1; G.up += G.fr; });   /* staggering under the load */
  PFA.motion('m05-swap', function (G, pp, k, ph) { G.fr = ((pp * 1.8 + ph) % 1) > .55 ? 1 : 0; });
  PFA.motion('m05-wedge', function (G, pp, k, ph) { var w = (pp * 2 + ph) % 1; G.fr = w < .3 ? 0 : w < .65 ? 1 : 2; });
  PFA.motion('m05-ripple', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2.2 + ph) % 1) * 3); });
  PFA.motion('m05-jab', function (G, pp, k) { G.fr = (Math.floor(pp * 8) + k) & 1; G.t += G.fr ? .5 : -.5; });
  PFA.motion('m05-lob', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; G.up += Math.sin(Math.min(1, w / .7) * Math.PI) * 8; G.fr = w < .7 ? (Math.floor(pp * 10) & 1) : 2; });
  PFA.motion('m05-grow', function (G, pp, k, ph) { G.fr = Math.min(2, Math.floor(((pp * 1.2 + ph * .3) % 1.2) * 3)); });
  PFA.motion('m05-strut', function (G, pp, k) { G.s += pp * .12; G.fr = (Math.floor(pp * 7) + k) & 1; G.up += G.fr ? 1 : 0; });   /* proud little march, gleam swapping claws */

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ---------- */
  function carMigrate(c, e, H) {        /* the red migration: a column of five crabs streams along the edge to the next piece, the leader biggest */
    var P = e.P, k, u, f;
    for (k = 4; k >= 0; k--) { u = e.hh - k * .07; if (u < 0) continue; f = (Math.floor(e.p * 14) + k) & 1;
      H.carHead(c, P, e.a + e.d * u, 'm05-redcrab', k ? 0 : e.z, f, 0, f ? -1 : 0, e.col, e.acc, e.hi); }
  }
  function carGhost(c, e, H) {          /* the ghost crab blurs to the next piece: three fading afterimages, only pale dots, then the crab */
    var P = e.P, Q = H.Q, k, u;
    for (k = 3; k >= 1; k--) { u = e.hh - k * .06; if (u < 0) continue; P.atq(e.a + e.d * u);
      if (H.stip(1 - k * .28, k, e.p)) { H.sq(c, Q.x + Q.nx * 5, Q.y + Q.ny * 5, 3, k === 1 ? e.hi : e.acc); H.px(c, Q.x + Q.nx * 5 - 2, Q.y + Q.ny * 5 - 3, e.acc); H.px(c, Q.x + Q.nx * 5 + 2, Q.y + Q.ny * 5 - 3, e.acc); } }
    H.carHead(c, P, e.a + e.d * e.hh, 'm05-ghost', e.z, Math.floor(e.p * 20) & 1, 0, 0, e.col, e.acc, e.hi);
  }
  function carCrack(c, e, H) {          /* a crack runs through the rock along the edge; the wedge crab squeezes along it to the next piece */
    var P = e.P, Q = H.Q, u, j = 0;
    for (u = 0; u < e.hh; u += .025) { P.atq(e.a + e.d * u); j++; H.px(c, Q.x + Q.nx * (2 + (j & 1)), Q.y + Q.ny * (2 + (j & 1)), e.acc); if (!(j % 6)) H.px(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4, e.hi); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm05-wedge', e.z, 2, 0, 0, e.col, e.acc, e.hi);
  }
  function carCoconut(c, e, H) {        /* the coconut house rolls to the next piece, husk bits flicking off behind */
    var P = e.P, Q = H.Q, k, u;
    for (k = 1; k <= 3; k++) { u = e.hh - k * .05; if (u < 0) break; P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 3, Q.y + Q.ny * 3 - k, '#c8a070'); }
    H.carHead(c, P, e.a + e.d * e.hh, 'm05-cochouse', e.z, Math.floor(e.p * 12) & 1, 0, -Math.abs(Math.sin(e.hh * Math.PI * 4)) * 2, e.col, e.acc, e.hi);
  }

  /* ---------- per-run decorations ---------- */
  function decoTicks(c, e, H, s0, len, ri, pp) {          /* sideways crabs: tiny paired leg-tick marks left in the sand behind them */
    var k, u, Q = H.Q; if (e.p > .9) return;
    for (k = 0; k < 4; k++) { u = (k + .5) / 4; if (e.p * 1.4 < u) break; e.P.atq(s0 + len * u); H.px(c, Q.x + Q.nx * 2 - Q.ny, Q.y + Q.ny * 2 + Q.nx, e.acc); H.px(c, Q.x + Q.nx * 2 + Q.ny, Q.y + Q.ny * 2 - Q.nx, e.acc); }
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
  function ticks(c, e, H) { comp(c, e, H, decoTicks); }

  /* ---------- motifs ---------- */
  function M(name, draw, meta) { PFA.motif(name, draw, meta); }
  M('shore-sidle', ticks, { nm: 'sidling shore crabs', desc: 'olive shore crabs seen from above shuffling sideways, claws snipping open and shut, leg ticks left in the sand', fam: 'bite', gap: 16, g: 'm05-sidler', mo: 'm05-sidle', x: '-', car: 'hop' });
  M('crab-dugin', plain, { nm: 'dug-in crabs', desc: 'crabs half sunk in wet sand, only the eyestalks up, ducking under when watched', fam: 'shield', gap: 14, g: 'm05-dugin', mo: 'm05-duck', x: '-', car: 'tunnel' });
  M('clack-warn', plain, { nm: 'clack warnings', desc: 'two claws raised high and clacked shut together, white click marks at the tips', fam: 'shock', gap: 14, g: 'm05-clack', mo: 'm05-clack', x: 'click', car: 'blink' });
  M('surf-foam', plain, { nm: 'surf foam', desc: 'small wavelets curling over, the white crest breaking into spray', fam: 'puff', gap: 14, g: 'm05-foam', mo: 'm05-curl', x: '-', car: 'trail' });
  M('ghost-eyestalk', plain, { nm: 'ghost crabs', desc: 'pale sand-coloured crabs with huge black eyes on stalks, running so fast they flicker out, afterimage specks behind; the chain is an afterimage dash', fam: 'bash', gap: 16, g: 'm05-ghost', mo: 'm05-ghost', x: '-', car: 'custom', carDraw: carGhost });
  M('ghost-burrow', plain, { nm: 'burrow mouths', desc: 'dark burrow mouths in pale sand: eyestalks rise out, then the claws snap', fam: 'bite', gap: 16, g: 'm05-hole', mo: 'm05-peek', x: '-', car: 'tunnel' });
  M('sand-pellet', plain, { nm: 'sand pellets', desc: 'rolled sand balls flicked out in little arcs, a light spot turning, grains trailing', fam: 'puff', gap: 10, g: 'm05-pellet', mo: 'm05-flick', x: 'dust', car: 'hop' });
  M('red-migration', plain, { nm: 'red migration', desc: 'broad scarlet land crabs front-on in a long stepping line; the chain is the migration column streaming on', fam: 'bash', gap: 14, g: 'm05-redcrab', mo: 'm05-migrate', x: '-', car: 'custom', carDraw: carMigrate });
  M('red-carapace', plain, { nm: 'red carapaces', desc: 'broad red backs with a centre ridge set edge to edge like a wall, a shine sliding across', fam: 'shield', gap: 12, g: 'm05-carapace', mo: 'm05-shine', x: '-', car: 'train' });
  M('spawn-surf', plain, { nm: 'spawning surf', desc: 'surf crests with dark egg specks shaken into them, surging in and out', fam: 'ripple', gap: 12, g: 'm05-spawn', mo: 'm05-surge', x: 'bubbles', car: 'rings' });
  M('leaf-burrow', plain, { nm: 'leaf burrows', desc: 'fallen rainforest leaves lying over burrow mouths; a leaf lifts and a red claw peeks out', fam: 'leaf', gap: 14, g: 'm05-leafhole', mo: 'm05-lift', x: '-', car: 'tunnel' });
  M('robber-claw', plain, { nm: 'robber crabs', desc: 'big blue-purple robber crabs with oversized claws and orange legs, creeping, stopping, then snatching', fam: 'bite', gap: 18, g: 'm05-robber', mo: 'm05-sneak', x: '-', car: 'comet' });
  M('coconut-crack', plain, { nm: 'cracking coconuts', desc: 'hairy brown coconuts with three eyes: a white crack opens, they split to show the flesh, milk flicks out', fam: 'bash', gap: 14, g: 'm05-coconut', mo: 'm05-crack', x: '-', car: 'hop' });
  M('coconut-seal', plain, { nm: 'sealing coconuts', desc: 'split coconut halves closing back together, a stitch of light along the seam', fam: 'mend', gap: 14, g: 'm05-seal', mo: 'm05-seal', x: '-', car: 'hop' });
  M('palm-frond', plain, { nm: 'palm fronds', desc: 'green palm fronds with a brown stalk and drooping leaflets, swaying out from the edge', fam: 'leaf', gap: 12, g: 'm05-frond', mo: 'sway', x: '-', car: 'flutter' });
  M('husk-fibre', plain, { nm: 'husk fibres', desc: 'tan coir fibres bristling out from a brown husk knot, the tips curling', fam: 'thorn', gap: 10, g: 'm05-fibre', mo: 'pulse', x: '-', car: 'train' });
  M('hoard-shell', plain, { nm: 'hoard shells', desc: 'hermit shells piled high with a bottle cap, sea glass and a coin, staggering on orange legs under the load', fam: 'shield', gap: 18, g: 'm05-hoard', mo: 'm05-lug', x: '-', car: 'train' });
  M('vacant-shell', plain, { nm: 'shell swaps', desc: 'empty spiral shells; the soft orange hermit pops out beside one and back in', fam: 'mend', gap: 14, g: 'm05-vacant', mo: 'm05-swap', x: '-', car: 'hop' });
  M('hoard-junk', plain, { nm: 'tossed hoard', desc: 'a red bottle cap, a blue button, green sea glass and a gold coin turning over as they are tossed', fam: 'bash', gap: 12, g: 'm05-junk', mo: 'tumble', x: 'glint', car: 'hop' });
  M('coconut-house', plain, { nm: 'coconut houses', desc: 'half coconuts worn as houses, a white cut rim, orange crab legs and claws stepping below; the chain is the house rolling on', fam: 'shield', gap: 16, g: 'm05-cochouse', mo: 'trundle', x: '-', car: 'custom', carDraw: carCoconut });
  M('coconut-milk', plain, { nm: 'coconut milk', desc: 'white coconut-milk drops with a cream rim, wobbling', fam: 'drip', gap: 12, g: 'm05-milk', mo: 'bounce', x: '-', car: 'trail' });
  M('wedge-crab', plain, { nm: 'wedge crabs', desc: 'flat dark-red wedge-shaped crabs sliding out of rock cracks claws first and back in; the chain squeezes along a crack', fam: 'thrust', gap: 16, g: 'm05-wedge', mo: 'm05-wedge', x: '-', car: 'custom', carDraw: carCrack });
  M('tide-pool', plain, { nm: 'tide pools', desc: 'little rock pools, grey stones round blue water, weed swaying, ripples and two claw tips peeking', fam: 'ripple', gap: 14, g: 'm05-pool', mo: 'm05-ripple', x: '-', car: 'rings' });
  M('brawler-claws', plain, { nm: 'crusher mitts', desc: 'two heavy blunt crusher claws like boxing mitts jabbing in turn, white impact pips', fam: 'bash', gap: 14, g: 'm05-mitts', mo: 'm05-jab', x: '-', car: 'comet' });
  M('mud-bomb', plain, { nm: 'mud bombs', desc: 'fat dripping mud balls lobbed in arcs that land in a splat', fam: 'drip', gap: 14, g: 'm05-mudball', mo: 'm05-lob', x: '-', car: 'hop' });
  M('regrow-claw', plain, { nm: 'regrowing claws', desc: 'a pale green bud swelling into a small claw and then a full one', fam: 'mend', gap: 14, g: 'm05-regrow', mo: 'm05-grow', x: '-', car: 'trail' });
  M('squire-polish', plain, { nm: 'crab squires', desc: 'small crabs with a stitched patch on the shell and polished claws, a white gleam swapping claw to claw as they strut', fam: 'slash', gap: 16, g: 'm05-squire', mo: 'm05-strut', x: '-', car: 'train' });
  M('limpet-buckler', plain, { nm: 'limpet bucklers', desc: 'ridged limpet cones carried like little round shields, a gleam at the peak', fam: 'shield', gap: 12, g: 'm05-limpet', mo: 'm05-shine', x: '-', car: 'train' });
  M('crab-clamp', plain, { nm: 'big claws', desc: 'one big crab claw pointing outward, fingers opening then snapping shut, white snap pip', fam: 'bite', gap: 12, g: 'm05-clamp', mo: 'snap', x: '-', car: 'comet' });
})();
