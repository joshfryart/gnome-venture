/* Motif module, medium batch m04 (snow-owl-fledgling, carrion-crow, magpie-mob, raven-pair, jungle-crow, kestrel-hoverer, cloud-kite,
   ptarmigan-flock, rock-partridge-covey, night-heron, egret-flock, emu-mob). TEMPLATE.md section 10.3.
   32 motifs (all birds), each with its own pixel glyph (ids prefixed m04-); new motions where the built-in ones did not fit; four motifs bring
   their own chain effect (carDraw: hat carried off, kestrel hover-and-stoop, banking kite with wingtip trails, emu stampede file).
   Birds are drawn upright in screen space from small sprite tables compiled ONCE at load (flat [dx, dy, colour] arrays) and mirrored to face
   outward / along the edge. Every draw is a stateless function of p: hash noise only, no Math.random / Date, no allocation in the frame loops
   (scratch H.Q / H.G only). Glyphs go through H.glyph so the MAXG budget counts them. The wiggle, the outer-edge chain rule, visual-only sound
   lines and the creature-heavy default are untouched (they live in the page). */
(function () {
  /* fixed accent colours (not palette tones): leaf green + rib, fish silver, trinket gold / silver, emu leg grey */
  var XC = [null, null, null, null, '#ffffff', '#cfeeff', '#5aa844', '#c8d8e2', '#f0c840', '#d4d8e0', '#8a8a80'], RIB = '#2e6a30';

  /* sprite compiler (load time only): rows of chars -> flat [dx, dy, ci, ...]; . none, C main, A dark, H hi, W white, D dew, L leaf, F fish, G gold, S silver, Y leg grey */
  function S(rows) {
    var out = [], w = rows[0].length, h = rows.length, i, j, ci;
    for (j = 0; j < h; j++) for (i = 0; i < w; i++) { ci = '.CAHWDLFGSY'.indexOf(rows[j].charAt(i)); if (ci > 0) out.push(i - (w >> 1), j - (h >> 1), ci); }
    return out;
  }
  function spr(c, s, x, y, fl, C, A, Hi, K) {
    var i, ci;
    for (i = 0; i < s.length; i += 3) { ci = s[i + 2]; K.px(c, x + s[i] * fl, y + s[i + 1], ci === 1 ? C : ci === 2 ? A : ci === 3 ? Hi : XC[ci]); }
  }
  /* facing: on the side edges look outward, on top / bottom edges look along the edge */
  function face(tx, nx, ny) { return Math.abs(nx) > Math.abs(ny) ? (nx > 0 ? 1 : -1) : (tx >= 0 ? 1 : -1); }

  /* ---------- sprite tables (built once) ---------- */
  var OWL0 = S(['.C...C.', 'CCCCCCC', 'CHACAHC', 'CCCACCC', 'CWCCCWC', 'CCCCCCC', '.A...A.']),
      OWL1 = S(['.C...C.', 'CCCCCCC', 'CAACAAC', 'CCCACCC', 'CWCCCWC', 'CCCCCCC', '.A...A.']),
      DOWN0 = S(['..C..', '.CWC.', 'CWWWC', '.CWC.', '..C..']),
      DOWN1 = S(['C...C', '.CWC.', '..W..', '.CWC.', 'C...C']),
      OWLHEAD = S(['C...C', 'CHCHC', 'CCACC', '.CCC.']),
      FOOT0 = S(['.CCC.', 'CCWCC', 'CCCCC', 'A.A.A']),
      FOOT1 = S(['.CCC.', 'CCWCC', 'CCCCC', 'A.A.A', 'A...A']),
      CROW0 = S(['....CC..', '...CWCAA', 'ACCCCC..', '.ACCCA..', '...A.A..']),
      CROW1 = S(['........', '....CC..', 'ACCCCWAA', '.ACCCC..', '..A..A..']),
      HAT = S(['..A.A..', '..HHH..', '..AAA..', 'HHHHHHH']),
      MAG0 = S(['......AA..', 'HH...AAWAA', '.HHACCCA..', '...ACCA...', '....A.A...']),
      MAG1 = S(['H.....AA..', '.H...AAWAA', '..HACCCA..', '...ACCA...', '....A.A...']),
      RAV = S(['...CCC.', '..CWCAA', 'ACCCCA.', 'AACCCC.', '...A.A.']),
      BILL0 = S(['..CCC...', '.CCWCWA.', '.CCCAAAA', '..CCCAA.', '..CC....']),
      BILL1 = S(['..CCC...', '.CCWCWAA', '.CCCC...', '..CCCAAA', '..CC....']),
      KES0 = S(['A.......A', '.CC.H.CC.', '..CCCCC..', '....C....', '...ACA...', '..AHHHA..']),
      KES1 = S(['....H....', '...CCC...', '.CCCCCCC.', 'A...C...A', '...ACA...', '..AHHHA..']),
      KITE0 = S(['.....H.....', 'ACWCCCCCWCA', '....CCC....', '....C.C....', '...C...C...']),
      KITE1 = S(['A....H.....', '.CWCCC.....', '....CCCCWCA', '....C.C....', '...C...C...']),
      CLOUD = S(['..HH.HH..', '.HHHHHHH.', 'HHHHWHHHH', '.AAAAAAA.']),
      PTA0 = S(['....HH.', '...CACA', '.CCCCC.', 'ACCCCCC', '.CCCCC.', '..CC.C.']),
      PTA1 = S(['.......', '....HH.', '...CACA', '.CCCCC.', 'WWWWWWW', '.WWWWW.']),
      CHU0 = S(['.....CC.', '....CACH', '.CCCCAC.', 'CCAWAWC.', '.CCCCC..', '..H..H..']),
      CHU1 = S(['.....CC.', '....CACH', '.CCCCAC.', 'CCAWAWC.', '.CCCCC..', '.H....H.']),
      NH0 = S(['..AAA....', 'W.AAHAA..', 'W.ACCC...', '.CCCCC...', 'CCCCCC...', '.CCCC....', '..A.A....', '..A.A....']),
      NH1 = S(['...AAA...', 'W..AAHAAA', 'W.ACCC...', '.CCCCC...', 'CCCCCC...', '.CCCC....', '..A.A....', '..A.A....']),
      EG0 = S(['....CC..', '....CHHH', '...CC...', '...C....', '..CC....', 'CCCCC...', 'DCCCC...', '...A....', '...A....', '..A.A...']),
      EG1 = S(['....CC..', '....CHHH', '...CC...', '...C....', '..CC....', 'CCCCC...', 'DCCCC...', '...A....', '..A.A...', '.A...A..']),
      EMU0 = S(['......CC', '......HA', '......H.', '.....C..', '..CCCC..', 'CACACCC.', 'CCACACC.', '..A..A..', '.AA.AA..']),
      EMU1 = S(['......CC', '......HA', '......H.', '.....C..', '..CCCC..', 'CACACCC.', 'CCACACC.', '..A...A.', '.AA...AA']);

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
  function decoWind(c, e, H, s0, len, ri, pp) {          /* kestrel: two short wind lines stream past the hovering birds */
    var k, u, Q = H.Q, X, Y; if (e.p > .9) return;
    for (k = 0; k < 2; k++) { u = (pp * 1.6 + k * .5 + ri * .3) % 1; e.P.atq(s0 + len * u); X = Q.x + Q.nx * (11 + k * 3); Y = Q.y + Q.ny * (11 + k * 3);
      H.px(c, X - Q.ny * 0, Y, e.hi); H.px(c, X - Q.ny * 2, Y + Q.nx * 2, e.hi); H.px(c, X - Q.ny * 4, Y + Q.nx * 4, H.WHITE); }
  }
  function decoFeathers(c, e, H, s0, len, ri, pp) {      /* stampede / scatter: two loose feathers drift down behind the birds */
    var k, u, Q = H.Q, X, Y; if (e.p > .92) return;
    for (k = 0; k < 2; k++) { u = (pp * .9 + H.hash(e.seed + k * 5 + ri)) % 1; e.P.atq(s0 + len * H.hash(e.seed + k * 3 + ri * 7));
      X = Q.x + Q.nx * 7 + Math.sin(u * 6 + k) * 3; Y = Q.y + Q.ny * 7 + 12 * u; H.px(c, X, Y, e.col); H.px(c, X + 1, Y + 1, e.col); H.px(c, X + 2, Y + 1, e.acc); }
  }
  function decoRipple(c, e, H, s0, len, ri, pp) {        /* wading birds: a flat ripple line widens round each leg spot */
    var k, u, Q = H.Q, w, i; if (e.p > .9) return;
    for (k = 0; k < 2; k++) { u = (pp * 1.2 + k * .5) % 1; e.P.atq(s0 + len * (k + .5) / 2); w = 1 + Math.round(5 * u);
      for (i = -w; i <= w; i += 2) H.px(c, Q.x + Q.nx * 4 + i, Q.y + Q.ny * 4 + 6, u < .6 ? e.hi : e.col); }
  }

  /* ---------- glyphs (tx,ty = edge tangent, nx,ny = outward normal; z 0..2 size step; fr from the motion) ---------- */
  PFA.glyph('m04-owlet', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* big grey ball of down, two huge yellow eyes that blink, tiny beak, ear nubs */
    spr(c, fr & 1 ? OWL1 : OWL0, x, y, 1, C, A, Hi, K); if (z > 1) { K.px(c, x - 4, y, C); K.px(c, x + 4, y, C); }
  });
  PFA.glyph('m04-down', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* one tuft of down, turning plus / cross as it drifts */
    spr(c, fr & 1 ? DOWN1 : DOWN0, x, y, 1, C, A, Hi, K);
  });
  PFA.glyph('m04-screech', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* owlet head, beak open, jagged screech marks pushing outward */
    var i, r = 4 + fr * 2, o;
    spr(c, OWLHEAD, x, y, 1, C, A, Hi, K);
    for (i = -2; i <= 2; i++) { o = (i & 1) ? 1 : 0; K.px(c, x + nx * (r + o) + tx * i * 1.5, y + ny * (r + o) + ty * i * 1.5, Hi); }
    if (fr >= 2) for (i = -3; i <= 3; i += 2) { o = (i & 2) ? 1 : -1; K.px(c, x + nx * (r + 3 + o) + tx * i * 1.5, y + ny * (r + 3 + o) + ty * i * 1.5, K.WHITE); }
  });
  PFA.glyph('m04-owlfoot', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* fluffy feathered foot, dark talons opening to grab */
    spr(c, fr & 1 ? FOOT1 : FOOT0, x, y, 1, C, A, Hi, K); if (z > 0) K.px(c, x, y + 2 + (fr & 1), A);
  });
  PFA.glyph('m04-crow', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* side-view crow, sly white eye, stout dark bill; head bobs on the hop */
    spr(c, fr & 1 ? CROW1 : CROW0, x, y, face(tx, nx, ny), C, A, Hi, K);
  });
  PFA.glyph('m04-quill', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a long black flight feather standing out of the edge, curving as it sways */
    var L = 6 + z, j, cv, X, Y, sd = fr & 1 ? 1 : -1;
    for (j = 0; j <= L; j++) { cv = j * j / (L * 4) * sd; X = x + nx * j + tx * cv; Y = y + ny * j + ty * cv;
      K.px(c, X, Y, A); if (j > 0 && j < L) { K.px(c, X + tx, Y + ty, j === 2 ? Hi : C); if (j < L - 1) K.px(c, X - tx, Y - ty, C); } }
    K.px(c, x + nx * L + tx * (L / 4) * sd, y + ny * L + ty * (L / 4) * sd, K.WHITE);
  });
  PFA.glyph('m04-caw', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* crow head, bill gaping outward, a three-ray caw burst */
    var i, o = fr ? .6 : 0, a, r;
    K.sq(c, x, y, 3, C); K.px(c, x - tx, y - ty - 1, K.WHITE);
    for (i = 0; i < 3; i++) { K.px(c, x + nx * (2 + i) + tx * i * o, y + ny * (2 + i) + ty * i * o, A); K.px(c, x + nx * (2 + i) - tx * i * o, y + ny * (2 + i) - ty * i * o, A); }
    if (fr) { r = 5 + fr * 2; for (a = -1; a <= 1; a++) { K.px(c, x + (nx + tx * a * .7) * r, y + (ny + ty * a * .7) * r, fr > 1 ? K.WHITE : Hi); K.px(c, x + (nx + tx * a * .7) * (r + 1), y + (ny + ty * a * .7) * (r + 1), Hi); } }
  });
  PFA.glyph('m04-hat', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a little straw hat with a dark band, two crow toes hooked over the crown */
    spr(c, HAT, x, y, 1, C, A, Hi, K); if (fr & 1) K.px(c, x + 3, y - 1, Hi);
  });
  PFA.glyph('m04-magpie', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* pied magpie: black head and back, white belly, long teal tail that cocks up */
    spr(c, fr & 1 ? MAG1 : MAG0, x, y, face(tx, nx, ny), C, A, Hi, K);
  });
  PFA.glyph('m04-trinket', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* stolen trinkets: a gold ring and a silver coin, a glint hopping between them */
    K.ringpx(c, x - 3, y, 2, XC[8]); K.sq(c, x + 2, y, 3, XC[9]); K.px(c, x + 2, y, A); if (z > 0) K.px(c, x - 3, y - 3, XC[8]);
    if (fr === 1) K.plus(c, x - 4, y - 2, 1, 1, K.WHITE); else if (fr === 3) K.plus(c, x + 3, y - 2, 1, 1, K.WHITE); else K.px(c, x + 1, y - 1, K.WHITE);
  });
  PFA.glyph('m04-ravens', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* the pair: two big ravens face to face, wedge tails, heavy bills, bowing in turn */
    var d = fr & 1;
    spr(c, RAV, x - 4, y + d, 1, C, A, Hi, K); spr(c, RAV, x + 4, y + 1 - d, -1, C, A, Hi, K);
  });
  PFA.glyph('m04-croak', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* hoarse croak: rough broken arcs swelling outward from a dark bill */
    var a, i, r, an, o, dx, dy;
    K.px(c, x, y, A); K.px(c, x + nx, y + ny, A);
    for (a = 0; a <= fr; a++) { r = 3 + a * 3;
      for (i = -2; i <= 2; i++) { if (((i + a) & 3) === 3) continue; an = i * .4; o = (i & 1) ? .8 : 0;
        dx = nx * Math.cos(an) + tx * Math.sin(an); dy = ny * Math.cos(an) + ty * Math.sin(an); K.px(c, x + dx * (r + o), y + dy * (r + o), a === 0 ? C : a === fr ? K.WHITE : Hi); } }
  });
  PFA.glyph('m04-wing', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* one great spread wing along the edge, fingered primaries lifting */
    var i, f, j, L;
    for (i = -4; i <= 3; i++) { K.px(c, x + tx * i, y + ty * i, C); K.px(c, x + tx * i + nx, y + ty * i + ny, C); K.px(c, x + tx * i - nx, y + ty * i - ny, A); }
    K.px(c, x - tx * 2 + nx, y - ty * 2 + ny, Hi);
    for (f = 0; f < 4; f++) { L = 2 + (f === 1 || f === 2 ? 1 : 0) + (fr & 1) + (z > 0 ? 1 : 0);
      for (j = 2; j <= L + 1; j++) K.px(c, x + tx * (3 + f * (1 + (fr & 1) * .4)) + nx * j, y + ty * (3 + f * (1 + (fr & 1) * .4)) + ny * j, j === L + 1 ? Hi : C); }
  });
  PFA.glyph('m04-bigbill', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* glossy blue-black head with a massive arched bill that chomps */
    spr(c, fr & 1 ? BILL1 : BILL0, x, y, face(tx, nx, ny), C, A, K.WHITE, K);
  });
  PFA.glyph('m04-fig', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* ripe jungle fruit on a stalk, leaf, glint; a bite taken and juice drips */
    var w = 4 + (z > 1 ? 1 : 0);
    K.sq(c, x, y, w, Hi); K.px(c, x, y - 3, A); K.px(c, x + 1, y - 3, XC[6]); K.px(c, x + 2, y - 4, XC[6]); K.px(c, x - 1, y - 1, K.WHITE);
    if (fr & 1) { K.px(c, x + 1, y - 1, C); K.px(c, x + 2, y, C); K.px(c, x + 1, y + 3 + (fr >> 1), Hi); }
  });
  PFA.glyph('m04-leaf', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* a broad rainforest leaf held as a mantle, the glossy crow head peeking out */
    var i, w, j, o = (fr & 1) ? 1 : 0;
    for (i = -4; i <= 4; i++) { w = Math.round(2 * Math.sqrt(1 - (i / 4.6) * (i / 4.6))); for (j = -w; j <= w; j++) K.px(c, x + tx * i + nx * (j + o * (i / 4)), y + ty * i + ny * (j + o * (i / 4)), j === 0 ? RIB : XC[6]); }
    if (fr & 1) { K.sq(c, x + tx * 4 + nx * 3, y + ty * 4 + ny * 3, 3, C); K.px(c, x + tx * 6 + nx * 3, y + ty * 6 + ny * 3, A); K.px(c, x + tx * 4 + nx * 3, y + ty * 4 + ny * 3 - 1, K.WHITE); }
  });
  PFA.glyph('m04-kestrel', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* hovering kestrel head-on: russet wings flicking up / down, grey head, fanned barred tail */
    spr(c, fr & 1 ? KES1 : KES0, x, y, 1, C, A, Hi, K);
  });
  PFA.glyph('m04-fan', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* a kestrel tail spread as a shield: grey feathers, black band, white tip */
    var r, j, an, dx, dy, half = .35 + .25 * Math.min(2, fr), L = 5 + (z > 0 ? 1 : 0);
    K.sq(c, x, y, 3, C);
    for (r = 0; r < 5; r++) { an = (r - 2) / 2 * half; dx = nx * Math.cos(an) + tx * Math.sin(an); dy = ny * Math.cos(an) + ty * Math.sin(an);
      for (j = 2; j <= L; j++) K.px(c, x + dx * j, y + dy * j, j === L ? K.WHITE : j === L - 1 ? A : Hi); }
  });
  PFA.glyph('m04-kite', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* long-winged red kite, pale head, deep forked tail; banks on frame 1 */
    spr(c, fr & 1 ? KITE1 : KITE0, x, y, face(tx, nx, ny), C, A, Hi, K);
  });
  PFA.glyph('m04-curl', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* an updraft curl: a pale wind spiral turning */
    var i, a, r;
    for (i = 0; i < 8; i++) { a = i * .8 + fr * 1.57; r = 1 + i * .65; K.px(c, x + Math.cos(a) * r, y + Math.sin(a) * r, i < 5 ? Hi : C); }
    K.px(c, x + Math.cos(fr * 1.57 + 6.4) * 6.5, y + Math.sin(fr * 1.57 + 6.4) * 6.5, K.WHITE);
  });
  PFA.glyph('m04-cloud', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a pale storm cloud, dark belly; rain and a flicker of lightning */
    spr(c, CLOUD, x, y, 1, C, A, Hi, K);
    if (fr & 1) { K.px(c, x - 2, y + 3, K.DEW); K.px(c, x + 2, y + 4, K.DEW); }
    if (fr === 2) { K.px(c, x, y + 3, K.WHITE); K.px(c, x + 1, y + 4, K.WHITE); K.px(c, x, y + 5, K.WHITE); }
  });
  PFA.glyph('m04-ptarm', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* round white ptarmigan, black eye bar, red comb, black tail; sinks into snow on frame 1 */
    spr(c, fr & 1 ? PTA1 : PTA0, x, y, face(tx, nx, ny), C, A, Hi, K);
  });
  PFA.glyph('m04-roost', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* a snow roost: a drift with two ptarmigan heads, red combs; heads duck in on frame 1 */
    K.bx(c, x - 4, y + 1, 9, 2, K.WHITE); K.bx(c, x - 3, y, 7, 1, K.WHITE); K.px(c, x - 4, y + 2, K.DEW); K.px(c, x + 4, y + 2, K.DEW);
    if (fr & 1) { K.px(c, x - 2, y - 1, Hi); K.px(c, x + 2, y - 1, Hi); }
    else { K.sq(c, x - 2, y - 2, 3, C); K.sq(c, x + 2, y - 2, 3, C); K.px(c, x - 1, y - 2, A); K.px(c, x + 3, y - 2, A); K.px(c, x - 2, y - 4, Hi); K.px(c, x + 2, y - 4, Hi); }
  });
  PFA.glyph('m04-chukar', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* grey rock partridge: black eye-line necklace, barred flanks, red bill and running red legs */
    spr(c, fr & 1 ? CHU1 : CHU0, x, y, face(tx, nx, ny), C, A, Hi, K);
  });
  PFA.glyph('m04-scrape', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* claw scrape: three raked grooves in grit, red toe tips, grit flung out */
    var i, j, L = 3 + Math.min(2, fr);
    for (i = -1; i <= 1; i++) { for (j = 0; j < L; j++) K.px(c, x + tx * i * 2 + nx * j, y + ty * i * 2 + ny * j, C); K.px(c, x + tx * i * 2 + nx * L, y + ty * i * 2 + ny * L, Hi); }
    if (fr) { K.px(c, x + nx * (L + 2) + tx * 3, y + ny * (L + 2) + ty * 3 - fr, A); K.px(c, x + nx * (L + 3) - tx * 2, y + ny * (L + 3) - ty * 2 - fr, C); }
  });
  PFA.glyph('m04-nheron', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {    /* stout hunched night heron: black cap, glowing red eye, white plume; neck shoots out on frame 1 */
    spr(c, fr & 1 ? NH1 : NH0, x, y, face(tx, nx, ny), C, A, Hi, K);
  });
  PFA.glyph('m04-cloak', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* the heron hunched inside its wings: a grey hood, dark inside, one red eye glowing */
    var i, a;
    for (i = 0; i <= 8; i++) { a = Math.PI + i * Math.PI / 8; K.px(c, x + Math.cos(a) * 4, y + 1 + Math.sin(a) * 4, C); if (i > 0 && i < 8) K.px(c, x + Math.cos(a) * 3, y + 1 + Math.sin(a) * 3, C); }
    K.bx(c, x - 2, y - 1, 5, 3, A); K.px(c, x + (fr & 1 ? -1 : 1), y, fr === 2 ? A : Hi); K.px(c, x - 2, y - 3, K.WHITE);
  });
  PFA.glyph('m04-gulp', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {      /* heron bill with a silver fish crosswise, tail flapping; frame 3 = gulped, throat bulge */
    var i, b = 4, fx, fy;
    K.sq(c, x, y, 3, C); K.px(c, x - nx, y - ny - 1, A); K.px(c, x + tx, y + ty - 1, Hi);
    for (i = 2; i <= b + 1; i++) K.px(c, x + nx * i, y + ny * i, A);
    if (fr < 3) { fx = x + nx * (b + 1); fy = y + ny * (b + 1);
      for (i = -2; i <= 1; i++) K.px(c, fx + tx * i, fy + ty * i, XC[7]); K.px(c, fx + tx * -3 + nx * (fr & 1 ? 1 : -1), fy + ty * -3 + ny * (fr & 1 ? 1 : -1), XC[7]); K.px(c, fx + tx, fy + ty, K.WHITE); }
    else { K.px(c, x - nx * 2 + tx, y - ny * 2 + ty, C); K.px(c, x - nx * 2 - tx, y - ny * 2 - ty, C); }
  });
  PFA.glyph('m04-egret', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* tall slim white egret, S neck, yellow dagger bill, black legs striding */
    spr(c, fr & 1 ? EG1 : EG0, x, y, face(tx, nx, ny), C, A, Hi, K);
  });
  PFA.glyph('m04-plume', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {     /* aigrette: three long lacy breeding plumes curling out and swaying, barbs glinting */
    var s, j, L = 7 + z, bend, X, Y;
    for (s = -1; s <= 1; s++) for (j = 0; j <= L; j++) { bend = s * j * .45 + Math.sin(j * .5 + fr * 1.57) * 1.2;
      X = x + nx * j + tx * bend; Y = y + ny * j + ty * bend; K.px(c, X, Y, j === L ? K.WHITE : C); if ((j & 1) && j > 1) K.px(c, X + tx * ((j & 2) ? 1 : -1), Y + ty * ((j & 2) ? 1 : -1), K.DEW); }
  });
  PFA.glyph('m04-emu', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {       /* shaggy brown emu: mop body, long neck, blue throat, thick trotting legs */
    spr(c, fr & 1 ? EMU1 : EMU0, x, y, face(tx, nx, ny), C, A, Hi, K);
  });
  PFA.glyph('m04-emufoot', function (c, x, y, z, fr, C, A, Hi, tx, ty, nx, ny, K) {   /* the kick: shaggy thigh, grey leg shooting out, three thick clawed toes */
    var L = 1 + fr * 2, i, fx = x + nx * (L + 2), fy = y + ny * (L + 2);
    K.sq(c, x - nx, y - ny, 3, C); K.px(c, x - nx * 2 + tx, y - ny * 2 + ty, A);
    for (i = 0; i <= L + 1; i++) K.px(c, x + nx * i, y + ny * i, XC[10]);
    K.px(c, fx + nx, fy + ny, XC[10]); K.px(c, fx + nx * 2, fy + ny * 2, A);
    K.px(c, fx + tx * 1.5 + nx, fy + ty * 1.5 + ny, XC[10]); K.px(c, fx + tx * 2 + nx * 2, fy + ty * 2 + ny * 2, A);
    K.px(c, fx - tx * 1.5 + nx, fy - ty * 1.5 + ny, XC[10]); K.px(c, fx - tx * 2 + nx * 2, fy - ty * 2 + ny * 2, A);
    if (fr === 2) { K.px(c, fx + nx * 4 + tx * 2, fy + ny * 4 + ty * 2, C); K.px(c, fx + nx * 4 - tx * 3, fy + ny * 4 - ty * 3, C); }
  });

  /* ---------- motions (mutate the scratch G; pp = time x speed) ---------- */
  PFA.motion('m04-wobble', function (G, pp, k, ph) { G.t += Math.sin(pp * 10 + k) * 1.5; G.up += Math.abs(Math.sin(pp * 5 + ph * 3)) * 2; G.fr = (Math.floor(pp * 7 + ph * 5) % 5) === 0 ? 1 : 0; });   /* teeter, blink */
  PFA.motion('m04-shriek', function (G, pp, k, ph) { G.fr = Math.floor(pp * 8 + ph * 3) & 3; G.t += ((Math.floor(pp * 30) + k) & 1) ? .5 : -.5; });
  PFA.motion('m04-grab', function (G, pp, k, ph) { G.fr = ((pp * 3 + ph) % 1) > .55 ? 1 : 0; G.d += G.fr; });
  PFA.motion('m04-strut', function (G, pp, k, ph) { G.s += pp * .12; G.fr = (Math.floor(pp * 8) + k) & 1; G.up += G.fr ? 0 : 2; });        /* hop-hop, head bob */
  PFA.motion('m04-caw', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 3 + ph) % 1) * 3); });
  PFA.motion('m04-swing', function (G, pp, k, ph) { G.t += Math.sin(pp * 7 + k) * 2; G.up += 2; G.fr = (Math.floor(pp * 7) + k) & 1; });
  PFA.motion('m04-tailcock', function (G, pp, k, ph) { G.fr = (Math.floor(pp * 6 + ph * 2) + k) & 1; G.s += pp * .08; G.up += G.fr; });
  PFA.motion('m04-mirror', function (G, pp, k) { G.fr = (Math.floor(pp * 5) + k) & 1; G.up += Math.sin(pp * 4 + k); });
  PFA.motion('m04-chomp', function (G, pp, k) { G.fr = (Math.floor(pp * 9) + k) & 1; G.d += G.fr * 2; });
  PFA.motion('m04-hover', function (G, pp, k) { G.up += 4 + Math.sin(pp * 3 + k); G.fr = (Math.floor(pp * 22) + k) & 1; });                /* hang in the wind, wings flicker */
  PFA.motion('m04-bank', function (G, pp, k) { var w = pp * 4 + k; G.t += Math.sin(w) * 5; G.up += Math.cos(w) * 2 + 2; G.fr = Math.sin(w) > 0 ? 1 : 0; });
  PFA.motion('m04-swirl', function (G, pp, k) { G.fr = (Math.floor(pp * 10) + k) & 3; G.up += pp * 5; });
  PFA.motion('m04-peek', function (G, pp, k, ph) { G.fr = ((pp * 2 + ph) % 1) < .45 ? 1 : 0; G.up += G.fr ? -1 : 0; });                  /* sink into snow, pop out */
  PFA.motion('m04-dash', function (G, pp, k) { G.s += pp * .45; G.fr = (Math.floor(pp * 18) + k) & 1; G.up += pp * 2; });              /* run uphill */
  PFA.motion('m04-scratch', function (G, pp, k, ph) { G.fr = Math.floor(((pp * 2.5 + ph) % 1) * 3); });
  PFA.motion('m04-stalk', function (G, pp, k, ph) { var w = (pp * 1.6 + ph) % 1; G.fr = w > .8 ? 1 : 0; G.d += G.fr * 5; });           /* frozen, then the stab */
  PFA.motion('m04-gulp', function (G, pp, k, ph) { G.fr = Math.min(3, Math.floor(((pp * 1.6 + ph) % 1) * 4.5)); });
  PFA.motion('m04-wade', function (G, pp, k) { G.s += pp * .1; G.fr = (Math.floor(pp * 5) + k) & 1; G.up += G.fr; });
  PFA.motion('m04-plumesway', function (G, pp, k) { G.fr = (Math.floor(pp * 6) + k) & 3; G.t += Math.sin(pp * 5 + k) * 1.5; });
  PFA.motion('m04-trot', function (G, pp, k) { G.s += pp * .55; G.fr = (Math.floor(pp * 14) + k) & 1; G.up += G.fr; G.t += Math.sin(pp * 7 + k) * .8; });
  PFA.motion('m04-kick', function (G, pp, k, ph) { var w = (pp * 2.2 + ph) % 1; G.fr = w < .4 ? 0 : w < .6 ? 1 : 2; G.d += G.fr * 2; });

  /* ---------- custom chain effects (carDraw: along the OUTER loop from e.a over e.d, eased e.hh) ---------- */
  function carHat(c, e, H) {            /* a crow flaps off along the edge with a snatched straw hat dangling from its feet, dotted flight path */
    var P = e.P, Q = H.Q, u, s = e.a + e.d * e.hh, sw = Math.sin(e.p * 14) * 2;
    for (u = e.hh - .04; u > 0 && u > e.hh - .4; u -= .06) { P.atq(e.a + e.d * u); H.px(c, Q.x + Q.nx * 6, Q.y + Q.ny * 6, e.hi); }
    H.carHead(c, P, s, 'm04-crow', e.z, e.fr, 0, -3, e.col, e.acc, e.hi);
    P.atq(s); H.glyph(c, 'm04-hat', Q.x + Q.nx * 5 + sw, Q.y + Q.ny * 5 + 3, e.z, e.fr, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
  }
  function carHover(c, e, H) {          /* the kestrel hangs over its own piece, wings flickering, then stoops along the edge to the next one */
    var P = e.P, Q = H.Q, u = e.p < .4 ? 0 : H.eo((e.p - .4) / .6), s = e.a + e.d * u, k, hgt = 10 - 5 * u;
    if (e.p >= .4) for (k = 1; k <= 3; k++) { if (u - k * .05 < 0) break; P.atq(e.a + e.d * (u - k * .05)); H.px(c, Q.x + Q.nx * (hgt + k), Q.y + Q.ny * (hgt + k), k === 1 ? H.WHITE : e.hi); H.px(c, Q.x + Q.nx * (hgt + k + 1), Q.y + Q.ny * (hgt + k + 1), e.hi); }
    P.atq(s); H.glyph(c, 'm04-kestrel', Q.x + Q.nx * hgt, Q.y + Q.ny * hgt + (e.p < .4 ? Math.sin(e.p * 30) : 0), e.z, e.p < .4 ? Math.floor(e.p * 44) & 1 : 1, e.col, e.acc, e.hi, -Q.ny, Q.nx, Q.nx, Q.ny);
    if (e.p > .9) { P.atq(e.a + e.d); H.plus(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4, 2, 1, H.WHITE); }
  }
  function carKite(c, e, H) {           /* a red kite glides the outer edge, banking, two thin wingtip trails behind it */
    var P = e.P, Q = H.Q, u, lo = Math.max(0, e.hh - .4), b = Math.sin(e.p * 9);
    for (u = lo; u < e.hh - .03; u += .03) { P.atq(e.a + e.d * u); if (H.hash(u * 50) < (u - lo) / .4) { H.px(c, Q.x + Q.nx * (4 + b), Q.y + Q.ny * (4 + b), e.hi); H.px(c, Q.x + Q.nx * (10 - b), Q.y + Q.ny * (10 - b), e.hi); } }
    H.carHead(c, P, e.a + e.d * e.hh, 'm04-kite', e.z, b > 0 ? 1 : 0, 0, -2, e.col, e.acc, e.hi);
  }
  function carEmu(c, e, H) {            /* the mob stampedes: a file of four emus pounding along the edge, dust kicked behind each */
    var P = e.P, Q = H.Q, k, u, f;
    for (k = 0; k < 4; k++) { u = e.hh - k * .08; if (u < 0) break; f = (Math.floor(e.p * 16) + k) & 1;
      P.atq(e.a + e.d * Math.max(0, u - .03)); H.sq(c, Q.x + Q.nx * 2, Q.y + Q.ny * 2 + 1, 2, e.acc); H.px(c, Q.x + Q.nx * 4, Q.y + Q.ny * 4 - f, e.col);
      H.carHead(c, P, e.a + e.d * u, 'm04-emu', e.z, f, 0, -2 - f, e.col, e.acc, e.hi); }
  }

  /* ---------- motifs ---------- */
  function M(name, draw, meta) { PFA.motif(name, draw, meta); }
  M('owlet-fluffball', plain, { nm: 'owlet fluffballs', desc: 'big grey balls of down with two huge yellow eyes that blink, teetering clumsily', fam: 'bash', gap: 16, g: 'm04-owlet', mo: 'm04-wobble', x: '-', car: 'hop' });
  M('owlet-down', plain, { nm: 'down tufts', desc: 'soft grey-white down tufts drifting and turning, snow caught among them', fam: 'puff', gap: 10, g: 'm04-down', mo: 'drift', x: 'snow', car: 'flutter' });
  M('owlet-screech', plain, { nm: 'owlet screech', desc: 'an owlet head with its beak wide open, jagged screech marks pushing outward in waves', fam: 'shock', gap: 16, g: 'm04-screech', mo: 'm04-shriek', x: '-', car: 'rings' });
  M('owlet-talon', plain, { nm: 'feathered feet', desc: 'fluffy feathered owl feet stamping, dark talons opening to grab', fam: 'slash', gap: 14, g: 'm04-owlfoot', mo: 'm04-grab', x: '-', car: 'hop' });
  M('crow-strut', plain, { nm: 'strutting crows', desc: 'side-view black crows with a sly pale eye hopping two-footed, heads bobbing', fam: 'slash', gap: 16, g: 'm04-crow', mo: 'm04-strut', x: '-', car: 'hop' });
  M('crow-quill', plain, { nm: 'black quills', desc: 'long black flight feathers standing out of the edge like a canopy, curving as they sway, a white tip glint', fam: 'shield', gap: 9, g: 'm04-quill', mo: 'sway', x: '-', car: 'flutter' });
  M('corvid-caw', plain, { nm: 'caw bursts', desc: 'crow heads with bills gaping outward and a three-ray caw burst that grows', fam: 'shock', gap: 16, g: 'm04-caw', mo: 'm04-caw', x: '-', car: 'rings' });
  M('hat-snatch', plain, { nm: 'snatched hats', desc: 'little straw hats with a dark band swinging from hooked crow toes; the chain is a crow flying off with one', fam: 'web', gap: 16, g: 'm04-hat', mo: 'm04-swing', x: '-', car: 'custom', carDraw: carHat });
  M('magpie-pied', plain, { nm: 'pied magpies', desc: 'black-and-white magpies with long teal tails that cock up and down as they hop', fam: 'slash', gap: 18, g: 'm04-magpie', mo: 'm04-tailcock', x: '-', car: 'hop' });
  M('magpie-trinket', plain, { nm: 'stolen trinkets', desc: 'a gold ring and a silver coin side by side, a glint hopping between them', fam: 'sparkle', gap: 12, g: 'm04-trinket', mo: 'glitter', x: 'glint', car: 'blink' });
  M('raven-duo', plain, { nm: 'raven pair', desc: 'two big ravens face to face with wedge tails and heavy bills, bowing in turn', fam: 'bite', gap: 22, g: 'm04-ravens', mo: 'm04-mirror', x: '-', car: 'comet' });
  M('raven-croak', plain, { nm: 'hoarse croaks', desc: 'rough broken arcs swelling out from a dark bill, the newest arc white', fam: 'ripple', gap: 14, g: 'm04-croak', mo: 'pulse', x: '-', car: 'rings' });
  M('raven-crag-wing', plain, { nm: 'crag wings', desc: 'one great black wing spread along the edge, fingered primaries lifting', fam: 'shield', gap: 14, g: 'm04-wing', mo: 'wave', x: 'dust', car: 'flutter' });
  M('jungle-bigbill', plain, { nm: 'big bills', desc: 'glossy blue-black crow heads with a massive arched bill that chomps, a white sheen on the bill', fam: 'bite', gap: 16, g: 'm04-bigbill', mo: 'm04-chomp', x: 'sheen', car: 'comet' });
  M('jungle-fig', plain, { nm: 'ripe fruit', desc: 'orange jungle fruit on stalks with a leaf and a glint; a bite taken, juice dripping', fam: 'mend', gap: 12, g: 'm04-fig', mo: 'bounce', x: '-', car: 'hop' });
  M('jungle-leaf-mantle', plain, { nm: 'leaf mantles', desc: 'broad green rainforest leaves held up as a mantle, swaying, a glossy crow head peeking out', fam: 'leaf', gap: 14, g: 'm04-leaf', mo: 'sway', x: '-', car: 'flutter' });
  M('kestrel-windhover', function (c, e, H) { comp(c, e, H, decoWind); }, { nm: 'windhovers', desc: 'kestrels hanging head-on in the wind, russet wings flicking, grey fanned tail, wind lines streaming past; the chain hovers then stoops', fam: 'thrust', gap: 18, g: 'm04-kestrel', mo: 'm04-hover', x: '-', car: 'custom', carDraw: carHover });
  M('kestrel-fantail', plain, { nm: 'fanned tails', desc: 'kestrel tails spread like a fan shield: grey feathers, black band, white tips, opening wider', fam: 'shield', gap: 14, g: 'm04-fan', mo: 'bloom', x: '-', car: 'flutter' });
  M('kite-forktail', plain, { nm: 'fork-tailed kites', desc: 'long-winged red kites with pale heads and deep forked tails, banking in slow circles; the chain glides with wingtip trails', fam: 'slash', gap: 20, g: 'm04-kite', mo: 'm04-bank', x: '-', car: 'custom', carDraw: carKite });
  M('kite-updraft', plain, { nm: 'updraft curls', desc: 'pale wind spirals turning and climbing, a haze band above', fam: 'puff', gap: 12, g: 'm04-curl', mo: 'm04-swirl', x: 'haze', car: 'loop' });
  M('kite-stormcloud', plain, { nm: 'storm clouds', desc: 'pale storm clouds with dark bellies drifting, rain spots and a flicker of lightning', fam: 'shield', gap: 16, g: 'm04-cloud', mo: 'drift', x: '-', car: 'cloud' });
  M('ptarmigan-snowbird', plain, { nm: 'snow ptarmigans', desc: 'round white ptarmigans with a black eye bar and red comb, sinking into the snow and popping out', fam: 'bite', gap: 16, g: 'm04-ptarm', mo: 'm04-peek', x: 'snow', car: 'hop' });
  M('ptarmigan-roost', plain, { nm: 'snow roosts', desc: 'snow drifts with two ptarmigan heads poking out, ducking in until only the red combs show', fam: 'shield', gap: 16, g: 'm04-roost', mo: 'm04-peek', x: 'snow', car: 'tunnel' });
  M('chukar-runner', plain, { nm: 'running partridges', desc: 'grey rock partridges with a black necklace, barred flanks and red legs racing uphill', fam: 'thrust', gap: 16, g: 'm04-chukar', mo: 'm04-dash', x: 'dust', car: 'train' });
  M('chukar-scrape', plain, { nm: 'claw scrapes', desc: 'three raked grooves scratched into grit with red toe tips, grit flung out', fam: 'slash', gap: 12, g: 'm04-scrape', mo: 'm04-scratch', x: 'clods', car: 'zig' });
  M('nightheron-stalk', plain, { nm: 'night herons', desc: 'stout hunched herons with a black cap, glowing red eye and white plume, frozen then stabbing out', fam: 'thrust', gap: 18, g: 'm04-nheron', mo: 'm04-stalk', x: 'moon', car: 'comet' });
  M('nightheron-cloak', plain, { nm: 'night hoods', desc: 'grey wing hoods hunched over a dark inside where one red eye glows and blinks', fam: 'shield', gap: 16, g: 'm04-cloak', mo: 'pulse', x: '-', car: 'blink' });
  M('nightheron-gulp', plain, { nm: 'fish gulps', desc: 'a heron bill holding a silver fish crosswise, the tail flapping, then gulped down with a throat bulge', fam: 'bite', gap: 16, g: 'm04-gulp', mo: 'm04-gulp', x: 'bubbles', car: 'hop' });
  M('egret-wade', function (c, e, H) { comp(c, e, H, decoRipple); }, { nm: 'wading egrets', desc: 'tall slim white egrets with S necks and yellow dagger bills stepping high, ripples round their legs', fam: 'thrust', gap: 18, g: 'm04-egret', mo: 'm04-wade', x: '-', car: 'train' });
  M('egret-aigrette', plain, { nm: 'aigrette plumes', desc: 'three long lacy white breeding plumes curling out and swaying, barbs glinting', fam: 'sparkle', gap: 12, g: 'm04-plume', mo: 'm04-plumesway', x: 'sheen', car: 'flutter' });
  M('emu-shag', function (c, e, H) { comp(c, e, H, decoFeathers); }, { nm: 'shaggy emus', desc: 'shaggy brown emus with long necks and blue throats trotting fast, loose feathers drifting; the chain is a stampede file', fam: 'bash', gap: 18, g: 'm04-emu', mo: 'm04-trot', x: 'dust', car: 'custom', carDraw: carEmu });
  M('emu-kick', plain, { nm: 'emu kicks', desc: 'a shaggy thigh and grey leg shooting out, three thick clawed toes, footprints left', fam: 'thrust', gap: 16, g: 'm04-emufoot', mo: 'm04-kick', x: 'prints', car: 'hop' });
})();
