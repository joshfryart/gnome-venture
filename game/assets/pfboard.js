/* Puzzle combat, board mode: ONE action a turn. Click a piece, then a lit spot (or drag it there); or play the group you set aside; or Connect two pieces (set them aside joined). Undo, End turn posts it once.
   After a turn the page plays back what happened one piece at a time (the piece being scored is highlighted and shown). Tap any piece on the board to read about it.
   The server checks every placement again. Legality here (joint) must match pfb_joint / pfb_check in includes/pfboard.php (tests/pfboard_js.js compares them). */
(function () {
  var root = document.getElementById('pfight');
  if (!root || root.dataset.mode !== 'board') return;
  var data = {}; try { data = JSON.parse(document.getElementById('pf-data').textContent); } catch (e) { return; }
  var W = data.w, H = data.h, ICON = data.icons || {}, LIFE1 = (data.life || 2) - 1;   // a piece is on its last round when its age reaches life - 1
  var SIDE = { L: [-1, 0, 'R'], R: [1, 0, 'L'], T: [0, -1, 'B'], B: [0, 1, 'T'] };
  var boardEl = document.getElementById('pfb-board'), handEl = document.getElementById('pf-hand');
  var go = document.getElementById('pf-go'), undo = document.getElementById('pf-undo'), prev = document.getElementById('pf-preview');
  var form = document.getElementById('pf-form'), movesIn = document.getElementById('pf-moves'), insp = document.getElementById('pf-inspect');
  var rbtn = document.getElementById('pf-redraw'), pform = document.getElementById('pf-pform');
  var optsEl = document.getElementById('pf-opts'), rewindEl = document.getElementById('pf-rewind'), rwT = document.getElementById('pf-rw-t'), rwBack = document.getElementById('pf-rw-back');
  var tiles = Array.prototype.slice.call(handEl.querySelectorAll('.pf-tile'));
  var moves = [], selected = null, submitted = false, redrawMode = false, rewind = null, picked = null, playing = false, replayed = false;   // moves: at most one planned action {k:'p'|'c'|'j'|'h', ...}
  var replayKey = 'pfr:' + ((form.querySelector('[name=nonce]') || {}).value) + ':' + ((form.querySelector('[name=turn]') || {}).value), willReplay = false;
  try { willReplay = !!(data.replay && data.replay.length && !window.sessionStorage.getItem(replayKey)); } catch (e) { willReplay = !!(data.replay && data.replay.length); }
  var hiddenIds = {}, revealId = null;   // the creature's pieces from this turn stay off the board until the replay reaches them (your piece resolves first, then its turn plays)
  if (willReplay) data.pcs.forEach(function (p) { if (p.fnew) hiddenIds[p.id] = true; });   // only the pieces the creature put down this turn stay off the board until the replay reaches them (not the one it started with)
  var showGone = willReplay, hideSpawn = willReplay, animateSpawn = false, histEl = root.querySelector('.pf-hist');   // pieces that left this turn stay until everything has scored; a piece the board adds for the creature waits until then too
  var glows = [], fxOn = !willReplay, glowTimer = 0, frame = 0;
  var world = null, vz = 1, vx = 0, vy = 0, viewKey = '', moved = false;
  // zoom and pan of the play area: wheel on a computer, pinch and drag on a phone, + - and reset buttons for everyone
  function clampView() {
    var r = boardEl.getBoundingClientRect(), w = r.width || 1, h = r.height || 1;
    vz = Math.max(1, Math.min(3, vz)); vx = Math.min(0, Math.max(w - w * vz, vx)); vy = Math.min(0, Math.max(h - h * vz, vy));
  }
  function applyView() {
    clampView();
    if (world) world.style.transform = vz === 1 ? '' : 'translate(' + vx + 'px,' + vy + 'px) scale(' + vz + ')';
    boardEl.classList.toggle('pfb-zoomed', vz > 1);
  }
  function zoomAt(f, cx, cy) {
    var nz = Math.max(1, Math.min(3, vz * f)), k = nz / vz;
    vx = cx - (cx - vx) * k; vy = cy - (cy - vy) * k; vz = nz; applyView();
  }
  function zoomControls() {
    var box = document.createElement('div'); box.className = 'pfb-zoom';
    [['+', 'Zoom in', function () { var r = boardEl.getBoundingClientRect(); zoomAt(1.4, r.width / 2, r.height / 2); }],
     ['\u2212', 'Zoom out', function () { var r = boardEl.getBoundingClientRect(); zoomAt(1 / 1.4, r.width / 2, r.height / 2); }],
     ['\u2922', 'Show the whole play area', function () { vz = 1; vx = 0; vy = 0; applyView(); }]].forEach(function (d) {
      var bt = document.createElement('button'); bt.type = 'button'; bt.textContent = d[0]; bt.setAttribute('aria-label', d[1]); bt.title = d[1]; bt.addEventListener('click', d[2]); box.appendChild(bt);
    });
    return box;
  }
  (function () {
    var ptr = {}, last = null;   // active pointers by id; the last pinch distance / midpoint or the last single position
    function rel(e) { var r = boardEl.getBoundingClientRect(); return { x: e.clientX - r.left, y: e.clientY - r.top }; }
    boardEl.addEventListener('wheel', function (e) { e.preventDefault(); var p = rel(e); zoomAt(e.deltaY < 0 ? 1.15 : 1 / 1.15, p.x, p.y); }, { passive: false });
    boardEl.addEventListener('pointerdown', function (e) { moved = false; if (e.target.closest && e.target.closest('.pfb-zoom')) return; ptr[e.pointerId] = rel(e); last = null; });
    boardEl.addEventListener('pointermove', function (e) {
      if (!ptr[e.pointerId]) return;
      var now = rel(e), ids = Object.keys(ptr);
      if (ids.length >= 2) {
        ptr[e.pointerId] = now;
        var a = ptr[ids[0]], b = ptr[ids[1]], d = Math.hypot(a.x - b.x, a.y - b.y), m = { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 };
        if (last && last.d) { vx += m.x - last.m.x; vy += m.y - last.m.y; zoomAt(d / last.d, m.x, m.y); moved = true; }
        last = { d: d, m: m };
      } else if (vz > 1) {
        var o = ptr[e.pointerId];
        if (moved || Math.hypot(now.x - o.x, now.y - o.y) > 5) { moved = true; vx += now.x - o.x; vy += now.y - o.y; applyView(); ptr[e.pointerId] = now; }
      }
    });
    function up(e) { delete ptr[e.pointerId]; last = null; }
    boardEl.addEventListener('pointerup', up); boardEl.addEventListener('pointercancel', up); boardEl.addEventListener('pointerleave', up);
    boardEl.addEventListener('click', function (e) { if (moved && !(e.target.closest && e.target.closest('.pfb-zoom'))) { e.stopPropagation(); e.preventDefault(); } moved = false; }, true);   // a pan or pinch is not a tap on a spot
    boardEl.addEventListener('dblclick', function (e) { if (!e.target.closest || !e.target.closest('.pfb-lit')) { vz = 1; vx = 0; vy = 0; applyView(); } });
  })();
  function startGlow() {   // 4 frames at about 8 fps for a few seconds, then the glow and stamps go (a still frame if the player prefers less motion)
    var calm = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches, ticks = 0;
    glowTimer = setInterval(function () {
      ticks++; frame = calm ? 0 : (frame + 1) % 4;
      glows.forEach(function (g) { if (!g.classList.contains('pfb-glow')) return; var w = g.getBoundingClientRect(); g.style.backgroundPosition = g.dataset.v === '1' ? (-frame * w.width) + 'px 0' : '0 ' + (-frame * w.height) + 'px'; });
      if (ticks > 40) { clearInterval(glowTimer); fxOn = false; glows.forEach(function (g) { if (g.parentNode) g.parentNode.removeChild(g); }); glows = []; }
    }, 125);
  }

  function joint(a, b) {   // [fits, linked]
    if (a[0] === 'flat' || b[0] === 'flat') return [true, false];
    var ok = a[0] !== b[0] && a[1] === b[1];
    return [ok, ok];
  }
  function groupDims(g) {   // [cols, rows, minx, miny] of the set-aside group
    var xs = g.pcs.map(function (p) { return p.x; }), ys = g.pcs.map(function (p) { return p.y; });
    var mx = Math.min.apply(null, xs), my = Math.min.apply(null, ys);
    return [Math.max.apply(null, xs) - mx + 1, Math.max.apply(null, ys) - my + 1, mx, my];
  }
  function working() {   // the board as it stands with my planned piece (or group) on it (or, rewound, as it stood after a past piece scored)
    var m = {}, n = 0;
    if (rewind) { rewind.pieces.forEach(function (p) { m[p.x + ',' + p.y] = p; n++; }); return { map: m, count: n }; }
    if (showGone) (data.gone || []).forEach(function (g) { m[g.x + ',' + g.y] = Object.assign({ gone: true }, g); n++; });
    data.pcs.forEach(function (p) { if ((hideSpawn && p.spawn) || hiddenIds[p.id]) return; m[p.x + ',' + p.y] = p; n++; });
    var mv = moves[0];
    if (mv && mv.k === 'p') { m[mv.x + ',' + mv.y] = { x: mv.x, y: mv.y, by: 'me', t: data.hand[mv.i].t, e: data.hand[mv.i].e, tag: data.hand[mv.i].tag, m: data.hand[mv.i].m, ghost: true, n: tiles[mv.i].dataset.name, v: tiles[mv.i].dataset.v }; n++; }
    if (mv && mv.k === 'c' && data.held) {
      var d = groupDims(data.held);
      data.held.pcs.forEach(function (p) { m[(mv.x + p.x - d[2]) + ',' + (mv.y + p.y - d[3])] = { x: mv.x + p.x - d[2], y: mv.y + p.y - d[3], by: 'me', t: p.t, e: p.e, tag: p.tag, m: p.m, ghost: true, n: p.n, v: p.v }; n++; });
    }
    return { map: m, count: n };
  }
  function baseBoard() { var m = {}; data.pcs.forEach(function (p) { m[p.x + ',' + p.y] = p; }); return { map: m, count: data.pcs.length }; }
  function fitInfo(b, e, x, y) {   // -1 does not fit, 0 fits but no joint links, 1 fits and at least one joint links (a knob in a matching hole)
    if (x < 0 || y < 0 || x >= W || y >= H || b.map[x + ',' + y]) return -1;
    if (!b.count) return x === Math.floor(W / 2) && y === Math.floor(H / 2) ? 0 : -1;
    var touch = false, linked = false;
    for (var s in SIDE) {
      var n = b.map[(x + SIDE[s][0]) + ',' + (y + SIDE[s][1])];
      if (!n) continue;
      var j = joint(e[s], n.e[SIDE[s][2]]);
      if (!j[0]) return -1;
      touch = true; if (j[1]) linked = true;
    }
    return touch ? (linked ? 1 : 0) : -1;
  }
  function legal(b, e, x, y) { return fitInfo(b, e, x, y) >= 0; }
  // the rule: a piece has to connect (make a linked joint) with one already out; only when nothing in your hand or set-aside group can connect anywhere may it go elsewhere that fits
  function mustLink(b, hand) {
    if (!b.count) return false;
    for (var i = 0; i < hand.length; i++) for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) if (fitInfo(b, hand[i], x, y) === 1) return true;
    return !!(data.held && data.held.link);
  }
  function handEdges() { return data.hand.map(function (h) { return h.e; }); }
  function usable(i) {
    var mv = moves[0]; if (!mv) return true;
    if (mv.k === 'p') return mv.i !== i;
    if (mv.k === 'j') return mv.a !== i && mv.b !== i;
    if (mv.k === 'h') return mv.b !== i;
    return true;
  }
  function litCells(sel) {   // key "x,y" -> true (a single piece's cell, or a group's top-left spot)
    var out = {};
    if (sel === null || moves.length && moves[0].k !== 'p' && moves[0].k !== 'c') return out;
    if (sel === 'group') { ((data.held && data.held.spots) || []).forEach(function (q) { out[q[0] + ',' + q[1]] = true; }); return out; }
    var b = baseBoard(), e = data.hand[sel].e, must = mustLink(b, handEdges());
    for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) { var f = fitInfo(b, e, x, y); if (f >= 0 && (!must || f === 1)) out[x + ',' + y] = true; }
    return out;
  }
  function anyFits() {
    var b = baseBoard();
    if (data.held && data.held.spots && data.held.spots.length) return true;
    for (var i = 0; i < tiles.length; i++) { for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) if (legal(b, data.hand[i].e, x, y)) return true; }
    return false;
  }
  // joining pieces (set aside): every touching edge must fit and at least one joint must be linked (a knob in a matching hole), like pfb_group_fit
  function groupFit(g, tileE, dx, dy) {
    if (g.pcs.length >= 3) return false;
    var touch = 0, linked = 0;
    for (var s in SIDE) {
      var q = null; g.pcs.forEach(function (p) { if (p.x === dx + SIDE[s][0] && p.y === dy + SIDE[s][1]) q = p; });
      if (g.pcs.some(function (p) { return p.x === dx && p.y === dy; })) return false;
      if (!q) continue;
      var j = joint(tileE[s], q.e[SIDE[s][2]]); if (!j[0]) return false; touch++; if (j[1]) linked++;
    }
    return touch > 0 && linked > 0;
  }
  function joinOptions(i) {   // ways hand piece i can be set aside joined: to the group already set aside, or to another hand piece
    var out = [];
    if (data.held) {
      data.held.pcs.forEach(function (a, ai) { for (var s in SIDE) if (groupFit(data.held, data.hand[i].e, a.x + SIDE[s][0], a.y + SIDE[s][1])) out.push({ k: 'h', b: i, anc: ai, side: s, ref: a.n }); });
    } else {
      var g = { pcs: [{ x: 0, y: 0, e: data.hand[i].e }] };
      tiles.forEach(function (t, p) { if (p === i || !usable(p)) return; for (var s2 in SIDE) if (groupFit(g, data.hand[p].e, SIDE[s2][0], SIDE[s2][1])) out.push({ k: 'j', a: i, b: p, side: s2, ref: t.dataset.name }); });
    }
    return out;
  }
  function plannedGroup() {   // the group as it will be after the planned join (so the panel updates at once)
    var mv = moves[0]; if (!mv || (mv.k !== 'j' && mv.k !== 'h')) return null;
    var mk = function (i, x, y) { var h = data.hand[i]; return { n: tiles[i].dataset.name, t: h.t, v: +tiles[i].dataset.v, tag: h.tag, m: h.m, e: h.e, x: x, y: y }; };
    if (mv.k === 'j') { var d = SIDE[mv.side]; return { pcs: [mk(mv.a, 0, 0), mk(mv.b, d[0], d[1])], planned: true }; }
    var a = data.held.pcs[mv.anc], d2 = SIDE[mv.side];
    return { pcs: data.held.pcs.concat([mk(mv.b, a.x + d2[0], a.y + d2[1])]), planned: true };
  }
  function modRar(m) { return m && data.mods && data.mods[m] ? data.mods[m][2] : null; }
  function modBadge(m) {   // the piece's upgrade as a small glyph (until the upgrade marks are drawn)
    var d = m && data.mods && data.mods[m]; if (!d) return null;
    if (window.PFParts && window.PFParts.marks && window.PFParts.marks['mod-' + m]) return null;   // the art mark is on the piece
    var el = document.createElement('span'); el.className = 'pfb-mod'; el.setAttribute('aria-hidden', 'true'); el.textContent = d[0]; el.title = 'Upgrade: ' + d[1]; return el;
  }
  function edgeSpan(edge, side) {
    var s = document.createElement('span');
    s.className = 'pfe s' + side + ' ' + (edge[0] === 'flat' ? 'flat f-flat' : edge[0] + ' f-' + edge[1]);
    s.setAttribute('aria-hidden', 'true');
    s.textContent = edge[1] ? { body: 'B', mind: 'M', craft: 'C' }[edge[1]] : '·';
    return s;
  }
  function pieceEl(p) {
    var el = document.createElement('span');
    el.className = 'pf-tile pf-s pfb-p pf-' + p.t + (p.by === 'foe' ? ' by-foe' : ' by-me') + (p.ghost ? ' pf-ghost' : '') + (p.age >= LIFE1 ? ' pf-old' : '');
    el.setAttribute('role', 'img');
    el.setAttribute('aria-label', (p.by === 'foe' ? 'Creature piece: ' : 'Your piece: ') + p.n + ', ' + p.t + ' ' + p.v);
    ['L', 'R', 'T', 'B'].forEach(function (s) { el.appendChild(edgeSpan(p.e[s], s)); });
    var ic = document.createElement('span'); ic.className = 'pf-ico'; ic.setAttribute('aria-hidden', 'true'); ic.textContent = ICON[p.t] || '❔'; el.appendChild(ic);
    var v = document.createElement('span'); v.className = 'pf-val'; v.textContent = String(p.v); el.appendChild(v);
    return el;
  }

  function actToken(m) {
    if (m.k === 'p') return [m.i, m.x, m.y].join(',');
    if (m.k === 'c') return ['c', m.x, m.y].join(',');
    if (m.k === 'j') return ['j', m.a, m.b, m.side].join(',');
    return ['h', m.b, m.anc, m.side].join(',');
  }
  function place(x, y) {
    if (selected === null || playing || submitted || data.won || rewind) return;
    moves = [selected === 'group' ? { k: 'c', x: x, y: y } : { k: 'p', i: selected, x: x, y: y }];
    clearPicks(); selected = null; render();
  }

  function render() {
    var lit = litCells(selected), b = working();
    boardEl.textContent = '';
    world = document.createElement('div'); world.className = 'pfb-world'; boardEl.appendChild(world);
    var P = window.PFParts, art = P && P.ok, S = art ? P.atlas.sizes.strip : null, dropN = 0;
    // the view: the pieces plus one spot around them (at least 3 x 3), so the pieces stay big and nothing is shown that cannot be used
    var x0 = W, x1 = -1, y0 = H, y1 = -1;
    Object.keys(b.map).forEach(function (k) { var q = k.split(','), qx = +q[0], qy = +q[1]; x0 = Math.min(x0, qx); x1 = Math.max(x1, qx); y0 = Math.min(y0, qy); y1 = Math.max(y1, qy); });
    var gd = selected === 'group' && data.held ? groupDims(data.held) : [1, 1, 0, 0];
    Object.keys(lit).forEach(function (k) { var q = k.split(','), qx = +q[0], qy = +q[1]; x0 = Math.min(x0, qx); x1 = Math.max(x1, qx + gd[0] - 1); y0 = Math.min(y0, qy); y1 = Math.max(y1, qy + gd[1] - 1); });
    if (x1 < 0) { x0 = x1 = Math.floor(W / 2); y0 = y1 = Math.floor(H / 2); }
    x0 -= 1; x1 += 1; y0 -= 1; y1 += 1;
    while (x1 - x0 + 1 < 3) { if (x0 > 0) x0--; if (x1 - x0 + 1 < 3 && x1 < W - 1) x1++; }
    while (y1 - y0 + 1 < 3) { if (y0 > 0) y0--; if (y1 - y0 + 1 < 3 && y1 < H - 1) y1++; }
    x0 = Math.max(0, x0); x1 = Math.min(W - 1, x1); y0 = Math.max(0, y0); y1 = Math.min(H - 1, y1);
    var VW = x1 - x0 + 1, VH = y1 - y0 + 1;
    var TW = art ? VW * S.pitch[0] + 2 * S.tab[0] : 0, TH = art ? VH * S.pitch[1] + 2 * S.tab[1] : 0;
    boardEl.style.aspectRatio = art ? TW + ' / ' + TH : (VW * 1.45) + ' / ' + VH;
    boardEl.classList.toggle('pfb-arted', !!art);
    boardEl.style.maxWidth = art ? Math.round(TW * (window.innerWidth <= 560 ? 1.1 : 1.5)) + 'px' : '';   // a small play area: pieces at most 1.1x on a phone, 1.5x elsewhere
    function put(el, x, y, cw, ch) {
      x -= x0; y -= y0; cw = cw || 1; ch = ch || 1;
      if (art) { el.style.left = (x * S.pitch[0] * 100 / TW) + '%'; el.style.top = (y * S.pitch[1] * 100 / TH) + '%'; el.style.width = (((cw - 1) * S.pitch[0] + S.piece[0]) * 100 / TW) + '%'; el.style.height = (((ch - 1) * S.pitch[1] + S.piece[1]) * 100 / TH) + '%'; }
      else { el.style.left = (x * 100 / VW) + '%'; el.style.top = (y * 100 / VH) + '%'; el.style.width = (cw * 100 / VW) + '%'; el.style.height = (ch * 100 / VH) + '%'; }
      world.appendChild(el);
    }
    for (var y = y0; y <= y1; y++) for (var x = x0; x <= x1; x++) {
      var key = x + ',' + y, p = b.map[key], cell;
      if (p) {
        cell = document.createElement('div'); cell.className = 'pfb-cell' + (p.ghost ? ' pfb-planned' : '') + (p.gone ? ' pfb-gone' : '') + (p.spawn && animateSpawn ? ' pfb-spawn' : '') + (revealId !== null && p.id === revealId ? ' pfb-drop' : '');
        if (p.id !== undefined && !p.ghost && p.gone) cell.dataset.id = String(p.id);
        else if (p.id !== undefined && !p.ghost) { cell.dataset.id = String(p.id); cell.classList.add('pfb-tap'); cell.setAttribute('role', 'button'); cell.tabIndex = 0; cell.setAttribute('aria-label', (p.by === 'foe' ? 'Creature piece: ' : 'Your piece: ') + p.n + ', ' + p.t + ' ' + p.v + '. Press for details.'); }
        if (art) {
          var cv = P.piece({ size: 'strip', owner: p.by === 'foe' ? 'foe' : 'me', type: p.t, tag: p.tag, m: p.m, rar: modRar(p.m), edges: p.e, old: p.age >= LIFE1, num: p.v, tint: data.tint });
          cv.className = 'pfb-cv'; cv.setAttribute('role', 'img'); cv.setAttribute('aria-label', (p.by === 'foe' ? 'Creature piece: ' : 'Your piece: ') + p.n + ', ' + p.t + ' ' + p.v + (p.age >= LIFE1 ? ', expires this round' : ''));
          cell.appendChild(cv);
        } else cell.appendChild(pieceEl(p));
        var mb = modBadge(p.m); if (mb && art) cell.appendChild(mb);
        if (p.age >= LIFE1 && !p.ghost) { var ob = document.createElement('span'); ob.className = 'pfb-old'; ob.setAttribute('aria-hidden', 'true'); ob.textContent = '\u231B'; ob.title = 'Leaves the board at the end of this round'; cell.appendChild(ob); }
      } else if (lit[key]) {
        cell = document.createElement('button'); cell.type = 'button'; cell.className = 'pfb-cell pfb-lit'; cell.setAttribute('aria-label', (selected === 'group' ? 'Place the group here, top left at ' : 'Place here, ') + 'column ' + (x + 1) + ' row ' + (y + 1));
        cell.dataset.x = String(x); cell.dataset.y = String(y);
        if (art && selected === 'group') { var gc0 = P.ghost({ size: 'strip', owner: 'me', edges: data.held.pcs[0].e }); gc0.className = 'pfb-cv'; gc0.setAttribute('aria-hidden', 'true'); cell.appendChild(gc0);   // one marker per spot; the whole group shows once you pick it
        } else if (art && selected !== null) { var gc = P.ghost({ size: 'strip', owner: 'me', edges: data.hand[selected].e }); gc.className = 'pfb-cv'; gc.setAttribute('aria-hidden', 'true'); cell.appendChild(gc); }
      } else continue;
      put(cell, x, y, +(cell.dataset.cw || 1), +(cell.dataset.ch || 1));
    }
    if (art) {   // a mark on every joint where the chain runs (knob in hole); a flat contact gets none
      var dirs = [['R', 1, 0, 'L', 'joint-h.png', 22, 14], ['B', 0, 1, 'T', 'joint-v.png', 14, 22]];
      for (var jy = y0; jy <= y1; jy++) for (var jx = x0; jx <= x1; jx++) {
        var a = b.map[jx + ',' + jy]; if (!a) continue;
        dirs.forEach(function (d) {
          var n = b.map[(jx + d[1]) + ',' + (jy + d[2])]; if (!n || !joint(a.e[d[0]], n.e[d[3]])[1]) return;
          var ax = jx - x0, ay = jy - y0, cx = d[1] ? (ax + 1) * S.pitch[0] + S.tab[0] : ax * S.pitch[0] + S.tab[0] + S.body[0] / 2, cy = d[1] ? ay * S.pitch[1] + S.tab[1] + S.body[1] / 2 : (ay + 1) * S.pitch[1] + S.tab[1];
          var im = document.createElement('img'); im.src = P.imgs[d[4]].src; im.alt = ''; im.className = 'pfb-joint';
          im.style.left = ((cx - d[5] / 2) * 100 / TW) + '%'; im.style.top = ((cy - d[6] / 2) * 100 / TH) + '%'; im.style.width = (d[5] * 100 / TW) + '%'; im.style.height = (d[6] * 100 / TH) + '%';
          world.appendChild(im);
        });
      }
    }
    // the last turn's chains: a glow along each linked joint of a chain, a stamp with its length on the piece that started it (a few seconds, then gone)
    glows = [];
    if (art && fxOn && !rewind && data.fx && data.fx.length) {
      var sets = data.fx.map(function (c) { var m = {}; c.ids.forEach(function (id) { m[id] = true; }); return m; });
      var byId = {}; Object.keys(b.map).forEach(function (k) { var q = b.map[k]; if (q.id !== undefined) byId[q.id] = q; });
      for (var gy = y0; gy <= y1; gy++) for (var gx = x0; gx <= x1; gx++) {
        var ga = b.map[gx + ',' + gy]; if (!ga || ga.id === undefined) continue;
        [['R', 1, 0, 'L', 'chain-glow-v.png', 8, 32, 1], ['B', 0, 1, 'T', 'chain-glow-h.png', 32, 8, 0]].forEach(function (d) {
          var gn = b.map[(gx + d[1]) + ',' + (gy + d[2])]; if (!gn || gn.id === undefined || !joint(ga.e[d[0]], gn.e[d[3]])[1]) return;
          if (!sets.some(function (st) { return st[ga.id] && st[gn.id]; })) return;
          var ax = gx - x0, ay = gy - y0, cx = d[1] ? (ax + 1) * S.pitch[0] + S.tab[0] : ax * S.pitch[0] + S.tab[0] + S.body[0] / 2, cy = d[1] ? ay * S.pitch[1] + S.tab[1] + S.body[1] / 2 : (ay + 1) * S.pitch[1] + S.tab[1];
          var ge = document.createElement('span'); ge.className = 'pfb-glow'; ge.setAttribute('aria-hidden', 'true');
          ge.style.backgroundImage = 'url(' + P.imgs[d[4]].src + ')'; ge.style.backgroundSize = d[7] ? '400% auto' : 'auto 400%';
          ge.style.left = ((cx - d[5] / 2) * 100 / TW) + '%'; ge.style.top = ((cy - d[6] / 2) * 100 / TH) + '%'; ge.style.width = (d[5] * 100 / TW) + '%'; ge.style.height = (d[6] * 100 / TH) + '%';
          ge.dataset.v = String(d[7]); world.appendChild(ge); glows.push(ge);
        });
      }
      data.fx.forEach(function (c) {
        var r = byId[c.ids[0]]; if (!r || r.x < x0 || r.x > x1 || r.y < y0 || r.y > y1) return;
        var sc = P.stamp(c.ids.length); sc.className = 'pfb-stamp'; sc.setAttribute('role', 'img'); sc.setAttribute('aria-label', 'Chain of ' + c.ids.length + ' pieces');
        sc.style.left = (((r.x - x0) * S.pitch[0] + S.tab[0] + S.body[0] - 22) * 100 / TW) + '%'; sc.style.top = (((r.y - y0) * S.pitch[1] + S.tab[1] - 14) * 100 / TH) + '%'; sc.style.width = (32 * 100 / TW) + '%'; sc.style.height = (32 * 100 / TH) + '%';
        world.appendChild(sc); glows.push(sc);
      });
      if (!glowTimer && glows.length) startGlow();
    }
    var vk = [x0, y0, x1, y1].join(',');
    if (vk !== viewKey) { viewKey = vk; vz = 1; vx = 0; vy = 0; }   // the pieces moved the view: back to the whole area
    boardEl.appendChild(zoomControls());
    applyView();
    tiles.forEach(function (t, i) { if (art && !t.dataset.arted) { t.dataset.arted = '1'; var hc = P.piece({ size: 'strip', owner: 'me', type: data.hand[i].t, tag: data.hand[i].tag, m: data.hand[i].m, rar: modRar(data.hand[i].m), edges: data.hand[i].e, num: t.dataset.v }); hc.className = 'pfh-cv'; hc.setAttribute('aria-hidden', 'true'); t.insertBefore(hc, t.firstChild); var hb = modBadge(data.hand[i].m); if (hb) t.appendChild(hb); t.classList.add('pf-art2'); } });
    tiles.forEach(function (t, i) { t.hidden = !usable(i); });
    fan(); renderHeld(); showJoinChips(); planAsk();
    var busy = playing || submitted || !!data.won || !!rewind;
    var endBtn = document.getElementById('pf-end'); if (endBtn) endBtn.disabled = playing;
    undo.disabled = busy || (moves.length === 0 && selected === null); go.disabled = busy || moves.length === 0;
    var fits = anyFits();
    if (pform) pform.hidden = !(moves.length === 0 && !fits && selected === null);
    var sel = typeof selected === 'number' ? tiles[selected] : null, hasJoin = !!(sel && joinOptions(selected).length);
    prev.textContent = rewind ? 'Rewound. Nothing can be played until you go back to now.' : playing ? 'Watch the chain: each piece is scored in turn.' : data.won ? 'It is over. End the fight to collect your reward.' : redrawMode ? 'Tap the piece to swap for a fresh one.'
      : sel ? sel.dataset.name + ': ' + sel.dataset.desc.split('. ')[0] + '. Pick a lit spot' + (hasJoin ? ' or set it aside.' : '.')
      : selected === 'group' ? hintText || 'Pick a lit spot for the group.'
      : moves.length === 0 ? (fits ? (!mustLink(baseBoard(), handEdges()) && baseBoard().count ? 'Nothing can connect, so you may place a piece anywhere it fits.' : root.dataset.turn === '1' ? 'Win two ways: Hurt empties its health, Charm fills the charm bar.' : 'Pick a piece, then a lit spot. One piece a turn.') : 'Nothing fits. You can pass.')
      : moves[0].k === 'j' || moves[0].k === 'h' ? 'Set aside for a later turn. End turn when ready.'
      : 'Placed. End turn when ready.';
    prev.title = prev.textContent;
    if (rewind) { var rc = boardEl.querySelector('.pfb-cell[data-id="' + rewind.id + '"]'); if (rc) rc.classList.add('pfb-scoring'); }
    if (!replayed) maybeReplay();
  }

  // ---- the set-aside group (a chip on the board that follows your plan), and the join choices under the board
  function renderHeld() {
    var g = plannedGroup() || data.held; if (!g) return;
    var P = window.PFParts, bt = document.createElement('button'); bt.type = 'button'; bt.className = 'pf-held-btn pf-held-chip' + (selected === 'group' ? ' pf-picked' : '') + (g.planned ? ' pf-planned' : '');
    bt.setAttribute('aria-pressed', selected === 'group' ? 'true' : 'false');
    bt.setAttribute('aria-label', (g.planned ? 'Planned group: ' : 'Your set-aside group: ') + g.pcs.map(function (p) { return p.n; }).join(', ') + (g.planned ? '' : '. Press to place it.'));
    if (P && P.ok) {
      var S = P.atlas.sizes.strip, d = groupDims(g), cv = document.createElement('canvas');
      cv.width = (d[0] - 1) * S.pitch[0] + S.piece[0]; cv.height = (d[1] - 1) * S.pitch[1] + S.piece[1]; var cx = cv.getContext('2d');
      g.pcs.forEach(function (p) { cx.drawImage(P.piece({ size: 'strip', owner: 'me', type: p.t, tag: p.tag, m: p.m, rar: modRar(p.m), edges: p.e, num: p.v }), (p.x - d[2]) * S.pitch[0], (p.y - d[3]) * S.pitch[1]); });
      cv.className = 'pf-held-cv'; cv.setAttribute('aria-hidden', 'true'); bt.appendChild(cv);
    }
    var tx = document.createElement('span'); tx.className = 'pf-held-tx'; tx.textContent = (g.planned ? 'Setting aside' : 'Set aside') + ' (' + g.pcs.length + ')' + (g.pcs.length === 3 ? ' full strength' : ''); bt.appendChild(tx);
    bt.addEventListener('click', function () {
      if (playing || submitted || redrawMode || g.planned || rewind) return;
      hideOpts(); moves = []; clearPicks(); selected = selected === 'group' ? null : 'group';
      if (selected) showHint(g.pcs.map(function (p) { return p.n; }).join(' + ') + ': pick a lit spot to place the whole group. The newest piece scores first.');
      render();
    });
    boardEl.appendChild(bt);
  }
  var hintText = '';
  function showHint(t) { hintText = t; }
  function clearPicks() { tiles.forEach(function (t) { t.classList.remove('pf-picked'); t.setAttribute('aria-pressed', 'false'); }); }
  function hideOpts() { if (optsEl) { optsEl.hidden = true; optsEl.textContent = ''; } }
  var SIDE_TXT = { L: 'to its left', R: 'to its right', T: 'above it', B: 'below it' };
  function showJoinChips() {   // under the board: set the selected piece aside with another one (or add it to the group)
    if (!optsEl) return; optsEl.textContent = '';
    if (selected === null || selected === 'group' || moves.length || playing || submitted || redrawMode) { optsEl.hidden = true; return; }
    var list = joinOptions(selected); if (!list.length) { optsEl.hidden = true; return; }
    optsEl.hidden = false;
    var h = document.createElement('span'); h.className = 'pf-opts-h'; h.textContent = data.held ? 'Add to your group:' : 'Or set aside with:'; optsEl.appendChild(h);
    list.slice(0, 6).forEach(function (o) {
      var bt = document.createElement('button'); bt.type = 'button'; bt.className = 'btn pf-chipbtn';
      bt.textContent = o.k === 'h' ? 'next to ' + o.ref + ' (' + SIDE_TXT[o.side] + ')' : '+ ' + o.ref + ', ' + SIDE_TXT[o.side];
      bt.setAttribute('aria-label', o.k === 'h' ? 'Add ' + tiles[o.b].dataset.name + ' to your group, ' + SIDE_TXT[o.side] + ' of ' + o.ref : 'Set aside ' + tiles[o.a].dataset.name + ' joined with ' + o.ref + ', ' + o.ref + ' goes ' + SIDE_TXT[o.side]);
      bt.addEventListener('click', function () { moves = [o.k === 'j' ? { k: 'j', a: o.a, b: o.b, side: o.side } : { k: 'h', b: o.b, anc: o.anc, side: o.side }]; clearPicks(); selected = null; render(); });
      optsEl.appendChild(bt);
    });
  }

  // ---- tap a piece on the board (or watch it being scored): what it is and how long it stays
  function pieceById(id) { var r = null; if (rewind) { rewind.pieces.forEach(function (p) { if (p.id === id) r = p; }); return r; } data.pcs.forEach(function (p) { if (p.id === id) r = p; }); (data.gone || []).forEach(function (g) { if (g.id === id) r = g; }); return r; }
  function pieceInfo(p) {
    var t = (p.by === 'foe' ? 'The creature\u2019s ' : 'Your ') + p.t + ' ' + p.v + '.', tg = data.tags && data.tags[p.tag], md = data.mods && data.mods[p.m], left = (data.life || 2) - p.age;
    return t + (tg ? ' ' + tg[0] + ' ' + tg[1] + '.' : '') + (md ? ' Upgrade ' + md[1] + ': ' + (md[3] || '') + '.' : '') + (left <= 1 ? ' It leaves the board at the end of this round.' : ' It stays for ' + left + ' more rounds.');
  }
  function showText(name, desc, p) {
    if (!insp) return;
    document.getElementById('pfi-name').textContent = name; document.getElementById('pfi-desc').textContent = desc;
    var slot = document.getElementById('pfi-art'), P = window.PFParts; if (slot) slot.textContent = '';
    if (slot && p && P && P.ok) { var c = P.piece({ size: 'hand', owner: p.by === 'foe' ? 'foe' : 'me', type: p.t, tag: p.tag, m: p.m, rar: modRar(p.m), edges: p.e, old: p.age >= LIFE1, num: p.v, tint: data.tint }); c.className = 'pfi-cv'; slot.appendChild(c); }
    insp.hidden = false;
  }
  function inspectPiece(id) {
    var p = pieceById(id); if (!p) return;
    picked = id; showText(p.n, pieceInfo(p), p);
    Array.prototype.forEach.call(boardEl.querySelectorAll('.pfb-tap'), function (c) { c.classList.toggle('pfb-picked', +c.dataset.id === id); });
  }

  // ---- rewind: tap a history chip to see the board (and the bar and health) as they stood after that piece scored; tap it again, the newest chip, or Back to now to return
  function newestChip() { return histEl && histEl.querySelector('.pf-chip:not([hidden])'); }
  function exitRewind() {
    if (!rewind) return;
    rewind = null; if (histEl) Array.prototype.forEach.call(histEl.querySelectorAll('.pf-chip-sel'), function (c) { c.classList.remove('pf-chip-sel'); });
    if (rewindEl) rewindEl.hidden = true; root.classList.remove('pf-rewound');
    if (data.bar !== undefined) setBar(data.bar, data.barmax); if (data.fh !== undefined) setFh(data.fh, data.fhmax); if (data.hp !== undefined) setHp(data.hp); setGuard(data.guard);
    if (insp) insp.hidden = true; fxOn = true; render();
  }
  function enterRewind(c) {
    var pcs = data.snaps && data.snaps[c.dataset.sn]; if (!pcs) return;
    exitRewind(); moves = []; selected = null; hideOpts(); clearPicks(); if (insp) insp.hidden = true;
    rewind = { sn: c.dataset.sn, id: +c.dataset.id || 0, chip: c, pieces: pcs };
    if (histEl) Array.prototype.forEach.call(histEl.querySelectorAll('.pf-chip-sel'), function (x) { x.classList.remove('pf-chip-sel'); });
    c.classList.add('pf-chip-sel');
    if (c.dataset.bar !== '' && c.dataset.bar !== undefined) setBar(+c.dataset.bar, data.barmax); if (c.dataset.fh !== '' && c.dataset.fh !== undefined) setFh(+c.dataset.fh, data.fhmax); if (c.dataset.hp !== '' && c.dataset.hp !== undefined) setHp(+c.dataset.hp); setGuard(c.dataset.g);
    var rt = c.querySelector('.pfh-txt'); if (rwT) rwT.textContent = 'Rewound to: ' + (c.classList.contains('foe') ? (data.foe || 'Creature') : 'You') + ', ' + (rt ? rt.textContent : 'a move') + '.';
    if (rewindEl) rewindEl.hidden = false; root.classList.add('pf-rewound'); render();
  }
  function chipTap(c) { if (playing || submitted) return; if (rewind && rewind.chip === c) exitRewind(); else if (c === newestChip()) exitRewind(); else enterRewind(c); }
  if (histEl) {
    histEl.addEventListener('click', function (e) { var c = e.target.closest && e.target.closest('.pf-chip-rw'); if (c) chipTap(c); });
    histEl.addEventListener('keydown', function (e) { if ((e.key === 'Enter' || e.key === ' ') && e.target.classList && e.target.classList.contains('pf-chip-rw')) { e.preventDefault(); chipTap(e.target); } });
  }
  if (rwBack) rwBack.addEventListener('click', exitRewind);

  // ---- the replay: after a turn, each piece that scored is lit in turn with its line, the bar and health following
  var skipBtn = document.getElementById('pf-skip'), playTimers = [], forceReplay = false, turnEl = null, turnTimer = 0;
  function showTurn(text, who) {   // a short banner over the play area so it is clear whose turn it is
    if (!boardEl || !boardEl.parentNode) return;
    if (!turnEl || turnEl.parentNode !== root) { turnEl = document.createElement('div'); turnEl.setAttribute('role', 'status'); root.appendChild(turnEl); }
    clearTimeout(turnTimer); turnEl.textContent = text; turnEl.className = 'pf-turn pf-turn-' + who; turnEl.hidden = false;
    turnEl.style.top = Math.max(4, boardEl.offsetTop + boardEl.offsetHeight / 2 - 18) + 'px';
    void turnEl.offsetWidth; turnEl.classList.add('pf-turn-on');
    turnTimer = setTimeout(function () { if (turnEl) turnEl.hidden = true; }, 1450);
  }
  function revealChip(k) { if (!histEl) return; var c = histEl.querySelector('.pf-chip-new[data-ev="' + k + '"]'); if (c) { c.hidden = false; c.classList.add('pf-chip-in'); } histEl.scrollLeft = 0; }
  function revealAllChips() { if (!histEl) return; Array.prototype.forEach.call(histEl.querySelectorAll('.pf-chip-new[hidden]'), function (c) { c.hidden = false; }); histEl.scrollLeft = 0; }
  function setBar(now, max) {   // the charm bar (Charm pieces only)
    var c = root.querySelector('.pfx-fill.charm'); if (!max) return;
    if (c) c.style.width = Math.max(0, Math.min(100, 100 * now / max)) + '%';
    var pr = root.querySelector('.pf-bar progress'); if (pr) pr.value = now;
  }
  function setFh(now, max) {   // the creature's health: drains as Hurt lands
    var el = root.querySelector('.pf-fhp'); if (!el || !max) return; var left = Math.max(0, max - now);
    var f = el.querySelector('.fhfill'), b = el.querySelector('b'); if (f) f.style.width = Math.min(100, 100 * left / max) + '%'; if (b) b.textContent = String(Math.ceil(left - 1e-6));
  }
  function setGuard(g) {   // the blue guard bar under your head: follows the replay as guard is built and blocks hits
    var el = root.querySelector('.pf-guard'); if (!el || g === null || g === undefined || g === '') return; g = Math.max(0, +g);
    var f = el.querySelector('.gfill'), b = el.querySelector('b'); if (f) f.style.width = Math.min(100, g * 100 / 16) + '%'; if (b) b.textContent = String(g);
    el.classList.toggle('pf-guard-0', g <= 0); el.setAttribute('aria-label', 'Guard ' + g + ': blocks the creature\u2019s hits until your next turn');
  }
  function setHp(v) { var pr = root.querySelector('.pfc-top .pf-hp progress'); if (pr) pr.value = v; }
  function afterLeave() {   // everything has scored and the old pieces are gone: the board adds a creature piece if it is short, growing into place
    showGone = false; fxOn = true; render();
    if (!data.won) showTurn('Your turn', 'me');
    if (hideSpawn) { hideSpawn = false; animateSpawn = true; render(); animateSpawn = false; }
  }
  function stopPlay(skipped) {
    playTimers.forEach(clearTimeout); playTimers = []; playing = false; replayed = true; hiddenIds = {};
    if (skipBtn) skipBtn.hidden = true;
    revealAllChips();
    Array.prototype.forEach.call(boardEl.querySelectorAll('.pfb-scoring'), function (c) { c.classList.remove('pfb-scoring'); });
    if (data.bar !== undefined) setBar(data.bar, data.barmax); if (data.fh !== undefined) setFh(data.fh, data.fhmax); if (data.hp !== undefined) setHp(data.hp); setGuard(data.guard);
    if (insp) insp.hidden = true; root.classList.remove('pf-playing');
    var gone = boardEl.querySelectorAll('.pfb-gone');
    if (gone.length && skipped !== true) { Array.prototype.forEach.call(gone, function (c) { c.classList.add('pfb-leaving'); }); playTimers.push(setTimeout(afterLeave, 800)); }
    else afterLeave();
  }
  function maybeReplay() {
    var P = window.PFParts;
    if (replayed || playing) return;
    if (!data.replay || !data.replay.length || !willReplay) { replayed = true; showGone = false; hideSpawn = false; revealAllChips(); return; }
    if (data.parts && !(P && P.ok) && !forceReplay) return;   // wait for the art so the pieces are there to light up (but not for ever)
    try { window.sessionStorage.setItem(replayKey, '1'); } catch (e) {}
    replayed = true; playing = true; fxOn = false; root.classList.add('pf-playing');
    if (skipBtn) skipBtn.hidden = false;
    if (data.replay0) { setBar(data.replay0.bar, data.barmax); setFh(data.replay0.fh || 0, data.fhmax); setHp(data.replay0.hp); setGuard(data.replay0.g); }
    var step = 950, BAN = 1500, tt = 300, lastBy = null, foeName = data.foe || 'Creature';   // each side: its banner shows, holds for a second, fades, and only then its pieces play
    data.replay.forEach(function (ev, k) {
      if (ev.by !== lastBy) {
        lastBy = ev.by;
        (function (by, at) { playTimers.push(setTimeout(function () { showTurn(by === 'me' ? 'Your turn' : foeName + "'s turn", by === 'me' ? 'me' : 'foe'); }, at)); })(ev.by, tt);
        tt += BAN;
      }
      playTimers.push(setTimeout(function () {
        if (ev.id && hiddenIds[ev.id]) { delete hiddenIds[ev.id]; revealId = ev.id; render(); revealId = null; }   // its piece is put down now, then it scores
        Array.prototype.forEach.call(boardEl.querySelectorAll('.pfb-scoring'), function (c) { c.classList.remove('pfb-scoring'); });
        if (ev.id) { var c = boardEl.querySelector('.pfb-cell[data-id="' + ev.id + '"]'); if (c) c.classList.add('pfb-scoring'); var pc = pieceById(ev.id); if (pc) { picked = ev.id; showText(pc.n, pieceInfo(pc), pc); } }
        revealChip(k);
        if (ev.bar !== null && ev.bar !== undefined) setBar(ev.bar, data.barmax); if (ev.fh !== null && ev.fh !== undefined) setFh(ev.fh, data.fhmax); if (ev.hp !== null && ev.hp !== undefined) setHp(ev.hp);
        setGuard(ev.g);
      }, tt));
      tt += step;
    });
    playTimers.push(setTimeout(stopPlay, tt));
    render();
  }

  // what the planned pieces would do: the server runs them on a copy (nothing is saved) and answers with the lines and the resolve bar
  var planEl = document.getElementById('pf-plan'), planTimer = 0, planAbort = null;
  function planAsk() {
    if (!planEl || typeof fetch !== 'function') return;
    clearTimeout(planTimer);
    if (planAbort) planAbort.abort();
    if (!moves.length || submitted || playing) { planEl.hidden = true; planEl.textContent = ''; return; }
    planTimer = setTimeout(function () {
      var fd = new FormData(), qs = function (n) { var e = form.querySelector('[name=' + n + ']'); return e ? e.value : ''; };
      fd.append('csrf', qs('csrf')); fd.append('do', 'pfb_preview'); fd.append('nonce', qs('nonce')); fd.append('turn', qs('turn'));
      fd.append('moves', actToken(moves[0]));
      planAbort = typeof AbortController === 'function' ? new AbortController() : null;
      fetch(location.pathname, { method: 'POST', body: fd, credentials: 'same-origin', signal: planAbort ? planAbort.signal : undefined, headers: { 'X-Requested-With': 'pfpreview' } })
        .then(function (r) { return r.json(); })
        .then(function (j) {
          planEl.textContent = '';
          if (!j || !j.ok) { planEl.hidden = true; return; }
          j.lines.forEach(function (t) { var li = document.createElement('li'); li.textContent = t; planEl.appendChild(li); });
          var li2 = document.createElement('li'); li2.className = 'pf-plan-bar';
          var ps = []; if (j.fh && j.fh[1] > j.fh[0]) ps.push('Creature health ' + Math.ceil(j.fh[2] - j.fh[0]) + ' \u2192 ' + Math.ceil(j.fh[2] - j.fh[1])); if (j.bar[1] > j.bar[0]) ps.push('Charm ' + Math.round(j.bar[0]) + ' \u2192 ' + Math.round(j.bar[1]) + ' of ' + Math.round(j.bar[2])); li2.textContent = (ps.length ? ps.join(' \u00B7 ') : 'No effect on the creature') + (j.over ? ' (ends the fight)' : '') + ' \u25BE';
          planEl.appendChild(li2); planEl.hidden = false;
        }).catch(function () {});
    }, 180);
  }
  function fan() {   // overlap the hand's pieces just enough to fit one row; the picked piece is lifted by CSS and comes to the front
    var vis = tiles.filter(function (t) { return !t.hidden; }), n = vis.length; if (!n) return;
    var avail = handEl.clientWidth, w = vis[0].offsetWidth || 112, m = window.innerWidth <= 560 ? 3 : 6;
    if (avail > 0 && n * w + (n - 1) * m > avail) m = n > 1 ? (avail - n * w) / (n - 1) : 0;
    vis.forEach(function (t, k) { t.style.marginLeft = k ? Math.floor(m) + 'px' : '0'; t.style.zIndex = t.classList.contains('pf-picked') ? '6' : String(k + 1); });
  }
  window.addEventListener('resize', fan);
  function select(i) {
    if (playing || submitted || data.won || rewind) return;
    if (!usable(i)) return;
    clearPicks(); hideOpts(); moves = []; if (insp) insp.hidden = true;
    selected = selected === i ? null : i;
    if (selected !== null) { tiles[i].classList.add('pf-picked'); tiles[i].setAttribute('aria-pressed', 'true'); }
    render();
  }
  function showInspect(b) {
    if (!insp) return;
    document.getElementById('pfi-name').textContent = b.dataset.name || '';
    document.getElementById('pfi-desc').textContent = b.dataset.desc || '';
    var slot = document.getElementById('pfi-art'), P = window.PFParts, i = tiles.indexOf(b);
    if (slot && P && P.ok && data.hand[i]) {   // the piece at hand size, edges and all
      slot.textContent = '';
      var c = P.piece({ size: 'hand', owner: 'me', type: data.hand[i].t, tag: data.hand[i].tag, edges: data.hand[i].e, num: b.dataset.v });
      c.className = 'pfi-cv'; slot.appendChild(c);
    }
    insp.hidden = false;
  }

  handEl.addEventListener('click', function (ev) {
    var b = ev.target.closest('.pf-tile'); if (!b) return;
    var i = tiles.indexOf(b);
    if (redrawMode) { if (submitted) return; submitted = true; tiles.forEach(function (t) { t.disabled = true; }); document.getElementById('pf-card').value = String(i); document.getElementById('pf-rform').submit(); return; }
    select(i);
  });
  boardEl.addEventListener('click', function (ev) {
    var c = ev.target.closest('.pfb-lit'); if (c) { place(parseInt(c.dataset.x, 10), parseInt(c.dataset.y, 10)); return; }
    var t = ev.target.closest('.pfb-tap'); if (t && !playing) inspectPiece(+t.dataset.id);
  });
  boardEl.addEventListener('keydown', function (ev) {
    if ((ev.key === 'Enter' || ev.key === ' ') && ev.target.classList && ev.target.classList.contains('pfb-tap') && !playing) { ev.preventDefault(); inspectPiece(+ev.target.dataset.id); }
  });
  // drag and drop (mouse); touch uses the two taps
  handEl.addEventListener('dragstart', function (ev) {
    var b = ev.target.closest('.pf-tile'); if (!b || redrawMode) { ev.preventDefault(); return; }
    var i = tiles.indexOf(b); if (!usable(i) || playing) { ev.preventDefault(); return; }
    if (selected !== i) select(i);
    try { ev.dataTransfer.setData('text/plain', String(i)); ev.dataTransfer.effectAllowed = 'move'; } catch (e) {}
  });
  boardEl.addEventListener('dragover', function (ev) { if (ev.target.closest('.pfb-lit')) { ev.preventDefault(); ev.dataTransfer.dropEffect = 'move'; } });
  boardEl.addEventListener('drop', function (ev) {
    var c = ev.target.closest('.pfb-lit'); if (!c) return; ev.preventDefault();
    place(parseInt(c.dataset.x, 10), parseInt(c.dataset.y, 10));
  });
  undo.addEventListener('click', function () { if (playing) return; moves = []; selected = null; hideOpts(); clearPicks(); render(); });
  form.addEventListener('submit', function (e) {
    if (submitted || playing || !moves.length) { e.preventDefault(); return; }
    submitted = true; go.disabled = true; undo.disabled = true;
    movesIn.value = actToken(moves[0]);
  });
  if (rbtn && parseInt(root.dataset.redraws || '0', 10) > 0) {
    rbtn.hidden = false;
    rbtn.addEventListener('click', function () { redrawMode = !redrawMode; moves = []; selected = null; hideOpts(); rbtn.setAttribute('aria-pressed', redrawMode ? 'true' : 'false'); rbtn.classList.toggle('pf-on', redrawMode); render(); });
  }
  var inspX = document.getElementById('pfi-x'); if (inspX) inspX.addEventListener('click', function () { insp.hidden = true; picked = null; Array.prototype.forEach.call(boardEl.querySelectorAll('.pfb-picked'), function (c) { c.classList.remove('pfb-picked'); }); });
  var planElX = document.getElementById('pf-plan'); if (planElX) planElX.addEventListener('click', function () { planElX.classList.toggle('open'); });
  if (skipBtn) skipBtn.addEventListener('click', function () { stopPlay(true); });
  window.addEventListener('pageshow', function (e) { if (e.persisted) location.reload(); });
  if (window.__pfbOff) window.__pfbOff();   // a swapped-in copy of this script: let go of the old one's listeners and timer
  document.addEventListener('pfparts-ready', render);
  setTimeout(function () { if (!replayed && !playing) { forceReplay = true; render(); } }, 4000);   // the art never came: play the replay with the plain pieces
  window.__pfbOff = function () { document.removeEventListener('pfparts-ready', render); window.removeEventListener('resize', fan); clearInterval(glowTimer); clearTimeout(hintTimer); playTimers.forEach(clearTimeout); };
  // the resolve bar: it glows when the fight starts with a short "fill to win" note, and explains itself on hover, focus or tap
  var barEl = root.querySelector('.pf-bars'), barTip = null, barHint = null, hintTimer = 0;
  var TIP = 'Two ways to win. Red: the creature\u2019s health. Hurt pieces take it down, and at 0 it backs off. Pink: the charm bar. Only Charm pieces fill it, and when it is full you win the creature over for a better reward. Guard and Heal keep you alive meanwhile. Great creatures cannot be charmed.';
  function placeUnderBar(el) { var b = barEl.getBoundingClientRect(), r = root.getBoundingClientRect(); el.style.top = (b.bottom - r.top + 4) + 'px'; el.style.left = (b.left + b.width / 2 - r.left) + 'px'; }
  function showBarTip(on) {
    if (!barEl) return;
    if (!on) { if (barTip) barTip.hidden = true; return; }
    if (barHint) barHint.hidden = true;
    if (!barTip || barTip.parentNode !== root) { barTip = document.createElement('div'); barTip.className = 'pf-bartip'; barTip.setAttribute('role', 'tooltip'); barTip.textContent = TIP; root.appendChild(barTip); }
    barTip.hidden = false; placeUnderBar(barTip);
  }
  if (barEl) {
    barEl.tabIndex = 0; barEl.removeAttribute('title');
    barEl.addEventListener('mouseenter', function () { showBarTip(true); }); barEl.addEventListener('mouseleave', function () { showBarTip(false); });
    barEl.addEventListener('focus', function () { showBarTip(true); }); barEl.addEventListener('blur', function () { showBarTip(false); });
    barEl.addEventListener('click', function () { showBarTip(!barTip || barTip.hidden); });
    if (root.dataset.turn === '1' && !(data.replay && data.replay.length) && !data.won) {   // a new fight: glow the bar and say what it is for
      barEl.classList.add('pf-barglow');
      var touch = window.matchMedia && window.matchMedia('(hover: none)').matches;
      barHint = document.createElement('div'); barHint.className = 'pf-barhint'; barHint.setAttribute('role', 'status'); barHint.textContent = 'Empty its health or fill the charm bar \u00B7 ' + (touch ? 'tap' : 'hover') + ' for more'; root.appendChild(barHint);
      setTimeout(function () { if (barHint) placeUnderBar(barHint); }, 300); placeUnderBar(barHint);
      hintTimer = setTimeout(function () { if (barHint) barHint.hidden = true; barEl.classList.remove('pf-barglow'); }, 7000);
    }
  }
  if (!(data.replay && data.replay.length) && root.dataset.turn === '1' && !data.won) setTimeout(function () { showTurn('Your turn', 'me'); }, 250);
  window.pfbLegal = legal;   // for the parity test
  window.pfbStrict = function (b, e, hand) { var must = mustLink(b, hand), o = []; for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) { var f = fitInfo(b, e, x, y); if (f >= 0 && (!must || f === 1)) o.push(x + ',' + y); } return o; };
  render();
})();
