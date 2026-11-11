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
  var heldEl = document.getElementById('pf-held'), optsEl = document.getElementById('pf-opts'), connectBtn = document.getElementById('pf-connect');
  var tiles = Array.prototype.slice.call(handEl.querySelectorAll('.pf-tile'));
  var moves = [], selected = null, submitted = false, redrawMode = false, connectMode = false, conA = null, picked = null, playing = false, replayed = false;   // moves: at most one planned action {k:'p'|'c'|'j'|'h', ...}
  var glows = [], fxOn = !(data.replay && data.replay.length), glowTimer = 0, frame = 0;
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
  function working() {   // the board as it stands with my planned piece (or group) on it
    var m = {}, n = 0;
    data.pcs.forEach(function (p) { m[p.x + ',' + p.y] = p; n++; });
    var mv = moves[0];
    if (mv && mv.k === 'p') { m[mv.x + ',' + mv.y] = { x: mv.x, y: mv.y, by: 'me', t: data.hand[mv.i].t, e: data.hand[mv.i].e, tag: data.hand[mv.i].tag, m: data.hand[mv.i].m, ghost: true, n: tiles[mv.i].dataset.name, v: tiles[mv.i].dataset.v }; n++; }
    if (mv && mv.k === 'c' && data.held) {
      var d = groupDims(data.held);
      data.held.pcs.forEach(function (p) { m[(mv.x + p.x - d[2]) + ',' + (mv.y + p.y - d[3])] = { x: mv.x + p.x - d[2], y: mv.y + p.y - d[3], by: 'me', t: p.t, e: p.e, tag: p.tag, m: p.m, ghost: true, n: p.n, v: p.v }; n++; });
    }
    return { map: m, count: n };
  }
  function baseBoard() { var m = {}; data.pcs.forEach(function (p) { m[p.x + ',' + p.y] = p; }); return { map: m, count: data.pcs.length }; }
  function legal(b, e, x, y) {
    if (x < 0 || y < 0 || x >= W || y >= H || b.map[x + ',' + y]) return false;
    if (!b.count) return x === Math.floor(W / 2) && y === Math.floor(H / 2);
    var touch = false;
    for (var s in SIDE) {
      var n = b.map[(x + SIDE[s][0]) + ',' + (y + SIDE[s][1])];
      if (!n) continue;
      if (!joint(e[s], n.e[SIDE[s][2]])[0]) return false;
      touch = true;
    }
    return touch;
  }
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
    var b = baseBoard(), e = data.hand[sel].e;
    for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) if (legal(b, e, x, y)) out[x + ',' + y] = true;
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
  function joinOptions(i) {   // where hand piece i can join: [{anc, side, label}]
    var out = [];
    if (data.held) {
      data.held.pcs.forEach(function (a, ai) { for (var s in SIDE) if (groupFit(data.held, data.hand[i].e, a.x + SIDE[s][0], a.y + SIDE[s][1])) out.push({ k: 'h', b: i, anc: ai, side: s, ref: a.n }); });
    } else if (conA !== null) {
      var g = { pcs: [{ x: 0, y: 0, e: data.hand[conA].e }] };
      for (var s2 in SIDE) if (groupFit(g, data.hand[i].e, SIDE[s2][0], SIDE[s2][1])) out.push({ k: 'j', a: conA, b: i, side: s2, ref: tiles[conA].dataset.name });
    }
    return out;
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
    if (selected === null || playing || submitted) return;
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
    boardEl.style.maxWidth = art ? Math.round(TW * 1.5) + 'px' : '';   // a small play area: pieces at most 1.5x
    function put(el, x, y, cw, ch) {
      x -= x0; y -= y0; cw = cw || 1; ch = ch || 1;
      if (art) { el.style.left = (x * S.pitch[0] * 100 / TW) + '%'; el.style.top = (y * S.pitch[1] * 100 / TH) + '%'; el.style.width = (((cw - 1) * S.pitch[0] + S.piece[0]) * 100 / TW) + '%'; el.style.height = (((ch - 1) * S.pitch[1] + S.piece[1]) * 100 / TH) + '%'; }
      else { el.style.left = (x * 100 / VW) + '%'; el.style.top = (y * 100 / VH) + '%'; el.style.width = (cw * 100 / VW) + '%'; el.style.height = (ch * 100 / VH) + '%'; }
      world.appendChild(el);
    }
    for (var y = y0; y <= y1; y++) for (var x = x0; x <= x1; x++) {
      var key = x + ',' + y, p = b.map[key], cell;
      if (p) {
        cell = document.createElement('div'); cell.className = 'pfb-cell' + (p.ghost ? ' pfb-planned' : '');
        if (p.id !== undefined && !p.ghost) { cell.dataset.id = String(p.id); cell.classList.add('pfb-tap'); cell.setAttribute('role', 'button'); cell.tabIndex = 0; cell.setAttribute('aria-label', (p.by === 'foe' ? 'Creature piece: ' : 'Your piece: ') + p.n + ', ' + p.t + ' ' + p.v + '. Press for details.'); }
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
        if (selected === 'group') { cell.dataset.cw = String(gd[0]); cell.dataset.ch = String(gd[1]); }
        if (art && selected === 'group') {
          var gcv = document.createElement('canvas'); gcv.width = (gd[0] - 1) * S.pitch[0] + S.piece[0]; gcv.height = (gd[1] - 1) * S.pitch[1] + S.piece[1];
          var gx2 = gcv.getContext('2d'); data.held.pcs.forEach(function (hp) { gx2.drawImage(P.ghost({ size: 'strip', owner: 'me', edges: hp.e }), (hp.x - gd[2]) * S.pitch[0], (hp.y - gd[3]) * S.pitch[1]); });
          gcv.className = 'pfb-cv'; gcv.setAttribute('aria-hidden', 'true'); cell.appendChild(gcv);
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
    if (art && fxOn && data.fx && data.fx.length) {
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
    fan(); renderHeld(); planAsk();
    var busy = playing || submitted;
    undo.disabled = busy || (moves.length === 0 && !connectMode && selected === null); go.disabled = busy || moves.length === 0;
    if (connectBtn) { connectBtn.disabled = busy || (data.held && data.held.pcs.length >= 3) || tiles.filter(function (t) { return !t.hidden; }).length < (data.held ? 1 : 2); connectBtn.setAttribute('aria-pressed', connectMode ? 'true' : 'false'); connectBtn.classList.toggle('pf-on', connectMode); }
    var fits = anyFits();
    if (pform) pform.hidden = !(moves.length === 0 && !fits && selected === null && !connectMode);
    prev.textContent = playing ? 'Watch the chain: each piece is scored in turn.' : redrawMode ? 'Tap the piece to swap for a fresh one.' : connectMode
      ? (data.held ? 'Tap the piece to add to your group (it has to link to a piece in it).' : (conA === null ? 'Connect: tap the first piece.' : 'Now tap the piece to join to it.'))
      : moves.length === 0 ? (fits ? 'Pick a piece, then a lit spot. One piece a turn. Or Connect pieces to play together later.' : 'Nothing in your hand fits anywhere. You can pass, or connect pieces.')
      : moves[0].k === 'j' ? 'Set aside: the two joined pieces wait for a later turn. End turn when you are ready.'
      : moves[0].k === 'h' ? 'Added to the group. End turn when you are ready (a group of three cannot take more).'
      : 'Placed. End turn when you are ready.';
    if (!replayed) maybeReplay();
  }

  // ---- the set-aside group, Connect, and the option list
  function renderHeld() {
    if (!heldEl) return;
    heldEl.textContent = '';
    var g = data.held;
    if (!g) { heldEl.hidden = true; return; }
    heldEl.hidden = false;
    var P = window.PFParts, bt = document.createElement('button'); bt.type = 'button'; bt.className = 'pf-held-btn' + (selected === 'group' ? ' pf-picked' : '');
    bt.setAttribute('aria-pressed', selected === 'group' ? 'true' : 'false');
    bt.setAttribute('aria-label', 'Your set-aside group: ' + g.pcs.map(function (p) { return p.n; }).join(', ') + '. Press to place it.');
    if (P && P.ok) {
      var S = P.atlas.sizes.strip, d = groupDims(g), cv = document.createElement('canvas');
      cv.width = (d[0] - 1) * S.pitch[0] + S.piece[0]; cv.height = (d[1] - 1) * S.pitch[1] + S.piece[1]; var cx = cv.getContext('2d');
      g.pcs.forEach(function (p) { cx.drawImage(P.piece({ size: 'strip', owner: 'me', type: p.t, tag: p.tag, m: p.m, rar: modRar(p.m), edges: p.e, num: p.v }), (p.x - d[2]) * S.pitch[0], (p.y - d[3]) * S.pitch[1]); });
      cv.className = 'pf-held-cv'; cv.setAttribute('aria-hidden', 'true'); bt.appendChild(cv);
    }
    var tx = document.createElement('span'); tx.className = 'pf-held-tx'; tx.textContent = 'Set aside (' + g.pcs.length + '): ' + g.pcs.map(function (p) { return p.n; }).join(' + ') + (g.pcs.length === 3 ? ' \u2014 full strength' : ''); bt.appendChild(tx);
    bt.addEventListener('click', function () { if (playing || submitted || redrawMode) return; connectMode = false; conA = null; hideOpts(); moves = []; clearPicks(); selected = selected === 'group' ? null : 'group'; if (selected) showText(g.pcs.map(function (p) { return p.n; }).join(' + '), 'Your set-aside group. Pick a lit spot to place all of it; the newest piece scores first.'); render(); });
    heldEl.appendChild(bt);
  }
  function clearPicks() { tiles.forEach(function (t) { t.classList.remove('pf-picked'); t.classList.remove('pf-con'); t.setAttribute('aria-pressed', 'false'); }); }
  function hideOpts() { if (optsEl) { optsEl.hidden = true; optsEl.textContent = ''; } }
  var SIDE_TXT = { L: 'on the left of', R: 'on the right of', T: 'above', B: 'below' };
  function showOpts(list) {
    optsEl.textContent = ''; optsEl.hidden = false;
    var h = document.createElement('p'); h.className = 'pf-opts-h'; h.textContent = 'Where does it join?'; optsEl.appendChild(h);
    list.forEach(function (o) {
      var bt = document.createElement('button'); bt.type = 'button'; bt.className = 'btn';
      bt.textContent = tiles[o.b].dataset.name + ' ' + SIDE_TXT[o.side] + ' ' + o.ref;
      bt.addEventListener('click', function () { hideOpts(); moves = [o.k === 'j' ? { k: 'j', a: o.a, b: o.b, side: o.side } : { k: 'h', b: o.b, anc: o.anc, side: o.side }]; connectMode = false; conA = null; clearPicks(); selected = null; render(); });
      optsEl.appendChild(bt);
    });
  }
  function connectTap(i) {
    if (!data.held && conA === null) { conA = i; tiles[i].classList.add('pf-con'); render(); return; }
    if (conA === i) { conA = null; clearPicks(); render(); return; }
    var opts = joinOptions(i);
    if (!opts.length) { prev.textContent = 'Those two cannot be joined: their edges must fit, and at least one joint has to link (a knob in a matching hole).'; return; }
    if (opts.length === 1) { var o = opts[0]; moves = [o.k === 'j' ? { k: 'j', a: o.a, b: o.b, side: o.side } : { k: 'h', b: o.b, anc: o.anc, side: o.side }]; connectMode = false; conA = null; clearPicks(); selected = null; render(); return; }
    showOpts(opts);
  }
  function toggleConnect() {
    if (playing || submitted) return;
    connectMode = !connectMode; conA = null; moves = []; selected = null; clearPicks(); hideOpts(); render();
  }

  // ---- tap a piece on the board (or watch it being scored): what it is and how long it stays
  function pieceById(id) { var r = null; data.pcs.forEach(function (p) { if (p.id === id) r = p; }); return r; }
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

  // ---- the replay: after a turn, each piece that scored is lit in turn with its line, the bar and health following
  var playEl = document.getElementById('pf-play'), skipBtn = document.getElementById('pf-skip'), playTimers = [];
  function setBar(now, max) {
    var h = root.querySelector('.pfx-fill.hurt'), c = root.querySelector('.pfx-fill.charm'); if (!max) return;
    var fin = data.bar || 0, f = Math.max(0, Math.min(1, now / max)), k = fin > 0 ? f / (fin / max) : 0;
    [h, c].forEach(function (el) { if (!el) return; if (el.dataset.w0 === undefined) el.dataset.w0 = el.getAttribute('data-w') || '0'; el.style.width = Math.min(100, (+el.dataset.w0) * k) + '%'; });
    var pr = root.querySelector('.pf-bar progress'); if (pr) pr.value = now;
  }
  function setHp(v) { var pr = root.querySelector('.pfc-top .pf-hp progress'); if (pr) pr.value = v; }
  function stopPlay() {
    playTimers.forEach(clearTimeout); playTimers = []; playing = false; replayed = true;
    if (playEl) { playEl.hidden = true; } if (skipBtn) skipBtn.hidden = true;
    Array.prototype.forEach.call(boardEl.querySelectorAll('.pfb-scoring'), function (c) { c.classList.remove('pfb-scoring'); });
    if (data.bar !== undefined) setBar(data.bar, data.barmax); if (data.hp !== undefined) setHp(data.hp);
    root.classList.remove('pf-playing'); fxOn = true; render();
  }
  function maybeReplay() {
    var P = window.PFParts;
    if (replayed || playing || !data.replay || !data.replay.length) { replayed = true; return; }
    if (data.parts && !(P && P.ok)) return;   // wait for the art so the pieces are there to light up
    var key = 'pfr:' + (form.querySelector('[name=nonce]') || {}).value + ':' + (form.querySelector('[name=turn]') || {}).value;
    try { if (window.sessionStorage.getItem(key)) { replayed = true; return; } window.sessionStorage.setItem(key, '1'); } catch (e) {}
    replayed = true; playing = true; fxOn = false; root.classList.add('pf-playing');
    if (playEl) { playEl.textContent = ''; playEl.hidden = false; } if (skipBtn) skipBtn.hidden = false;
    if (data.replay0) { setBar(data.replay0.bar, data.barmax); setHp(data.replay0.hp); }
    var step = 950;
    data.replay.forEach(function (ev, k) {
      playTimers.push(setTimeout(function () {
        Array.prototype.forEach.call(boardEl.querySelectorAll('.pfb-scoring'), function (c) { c.classList.remove('pfb-scoring'); });
        if (ev.id) { var c = boardEl.querySelector('.pfb-cell[data-id="' + ev.id + '"]'); if (c) c.classList.add('pfb-scoring'); var pc = pieceById(ev.id); if (pc) { picked = ev.id; showText(pc.n, pieceInfo(pc), pc); } }
        if (playEl) { var li = document.createElement('li'); li.textContent = ev.ln; li.className = ev.by === 'me' ? 'you' : 'foe'; playEl.appendChild(li); li.scrollIntoView && li.scrollIntoView({ block: 'nearest' }); }
        if (ev.bar !== null && ev.bar !== undefined) setBar(ev.bar, data.barmax); if (ev.hp !== null && ev.hp !== undefined) setHp(ev.hp);
      }, (k + 1) * step));
    });
    playTimers.push(setTimeout(stopPlay, (data.replay.length + 1) * step));
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
          li2.textContent = 'Resolve ' + Math.round(j.bar[0]) + ' \u2192 ' + Math.round(j.bar[1]) + ' of ' + Math.round(j.bar[2]) + (j.over ? ' (this ends the fight)' : '') + '. The creature answers after you end your turn.';
          planEl.appendChild(li2); planEl.hidden = false;
        }).catch(function () {});
    }, 180);
  }
  function fan() {   // overlap the hand's pieces just enough to fit one row; the picked piece is lifted by CSS and comes to the front
    var vis = tiles.filter(function (t) { return !t.hidden; }), n = vis.length; if (!n) return;
    var avail = handEl.clientWidth, w = vis[0].offsetWidth || 112, m = 6;
    if (avail > 0 && n * w + (n - 1) * m > avail) m = n > 1 ? (avail - n * w) / (n - 1) : 0;
    vis.forEach(function (t, k) { t.style.marginLeft = k ? Math.floor(m) + 'px' : '0'; t.style.zIndex = t.classList.contains('pf-picked') ? '6' : String(k + 1); });
  }
  window.addEventListener('resize', fan);
  function select(i) {
    if (playing || submitted) return;
    if (connectMode) { connectTap(i); return; }
    if (!usable(i)) return;
    clearPicks(); hideOpts(); moves = [];
    selected = selected === i ? null : i;
    if (selected !== null) { tiles[i].classList.add('pf-picked'); tiles[i].setAttribute('aria-pressed', 'true'); showInspect(tiles[i]); }
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
    var i = tiles.indexOf(b); if (!usable(i) || connectMode || playing) { ev.preventDefault(); return; }
    if (selected !== i) select(i);
    try { ev.dataTransfer.setData('text/plain', String(i)); ev.dataTransfer.effectAllowed = 'move'; } catch (e) {}
  });
  boardEl.addEventListener('dragover', function (ev) { if (ev.target.closest('.pfb-lit')) { ev.preventDefault(); ev.dataTransfer.dropEffect = 'move'; } });
  boardEl.addEventListener('drop', function (ev) {
    var c = ev.target.closest('.pfb-lit'); if (!c) return; ev.preventDefault();
    place(parseInt(c.dataset.x, 10), parseInt(c.dataset.y, 10));
  });
  undo.addEventListener('click', function () { if (playing) return; moves = []; selected = null; connectMode = false; conA = null; hideOpts(); clearPicks(); render(); });
  form.addEventListener('submit', function (e) {
    if (submitted || playing || !moves.length) { e.preventDefault(); return; }
    submitted = true; go.disabled = true; undo.disabled = true;
    movesIn.value = actToken(moves[0]);
  });
  if (rbtn && parseInt(root.dataset.redraws || '0', 10) > 0) {
    rbtn.hidden = false;
    rbtn.addEventListener('click', function () { redrawMode = !redrawMode; moves = []; selected = null; connectMode = false; conA = null; hideOpts(); rbtn.setAttribute('aria-pressed', redrawMode ? 'true' : 'false'); rbtn.classList.toggle('pf-on', redrawMode); render(); });
  }
  if (connectBtn) connectBtn.addEventListener('click', toggleConnect);
  if (skipBtn) skipBtn.addEventListener('click', stopPlay);
  window.addEventListener('pageshow', function (e) { if (e.persisted) location.reload(); });
  if (window.__pfbOff) window.__pfbOff();   // a swapped-in copy of this script: let go of the old one's listeners and timer
  document.addEventListener('pfparts-ready', render);
  window.__pfbOff = function () { document.removeEventListener('pfparts-ready', render); window.removeEventListener('resize', fan); clearInterval(glowTimer); playTimers.forEach(clearTimeout); };
  window.pfbLegal = legal;   // for the parity test
  render();
})();
