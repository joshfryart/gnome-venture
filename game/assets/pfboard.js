/* Puzzle combat, board mode: plan up to 4 placements (click a piece, then a lit cell; or drag it there), Undo, End turn posts them once.
   The server checks every placement again. Legality here (joint) must match pfb_joint / pfb_check in includes/pfboard.php (tests/pfboard_js.js compares them). */
(function () {
  var root = document.getElementById('pfight');
  if (!root || root.dataset.mode !== 'board') return;
  var data = {}; try { data = JSON.parse(document.getElementById('pf-data').textContent); } catch (e) { return; }
  var W = data.w, H = data.h, ICON = data.icons || {};
  var SIDE = { L: [-1, 0, 'R'], R: [1, 0, 'L'], T: [0, -1, 'B'], B: [0, 1, 'T'] };
  var boardEl = document.getElementById('pfb-board'), handEl = document.getElementById('pf-hand');
  var go = document.getElementById('pf-go'), undo = document.getElementById('pf-undo'), prev = document.getElementById('pf-preview');
  var form = document.getElementById('pf-form'), movesIn = document.getElementById('pf-moves'), insp = document.getElementById('pf-inspect');
  var rbtn = document.getElementById('pf-redraw'), pform = document.getElementById('pf-pform');
  var tiles = Array.prototype.slice.call(handEl.querySelectorAll('.pf-tile'));
  var moves = [], selected = null, submitted = false, redrawMode = false;
  var glows = [], fxOn = true, glowTimer = 0, frame = 0;
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
  function working() {   // the board as it stands with my planned pieces on it
    var m = {}, n = 0;
    data.pcs.forEach(function (p) { m[p.x + ',' + p.y] = p; n++; });
    moves.forEach(function (mv) { m[mv.x + ',' + mv.y] = { x: mv.x, y: mv.y, by: 'me', t: data.hand[mv.i].t, e: data.hand[mv.i].e, ghost: true, n: tiles[mv.i].dataset.name, v: tiles[mv.i].dataset.v }; n++; });
    return { map: m, count: n };
  }
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
  function heavyDone() { return moves.some(function (m) { var t = tiles[m.i].dataset; return t.tag === 'heavy' && t.mod !== 'steady'; }); }
  function usable(i) { return !moves.some(function (m) { return m.i === i; }); }
  function litCells(i) {
    var out = {};
    if (i === null || moves.length >= 4 || heavyDone()) return out;
    var b = working(), e = data.hand[i].e;
    for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) if (legal(b, e, x, y)) out[x + ',' + y] = true;
    return out;
  }
  function anyFits() {
    var b = working();
    for (var i = 0; i < tiles.length; i++) { if (!usable(i)) continue; for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) if (legal(b, data.hand[i].e, x, y)) return true; }
    return false;
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
    el.className = 'pf-tile pf-s pfb-p pf-' + p.t + (p.by === 'foe' ? ' by-foe' : ' by-me') + (p.ghost ? ' pf-ghost' : '') + (p.age >= 1 ? ' pf-old' : '');
    el.setAttribute('role', 'img');
    el.setAttribute('aria-label', (p.by === 'foe' ? 'Creature piece: ' : 'Your piece: ') + p.n + ', ' + p.t + ' ' + p.v);
    ['L', 'R', 'T', 'B'].forEach(function (s) { el.appendChild(edgeSpan(p.e[s], s)); });
    var ic = document.createElement('span'); ic.className = 'pf-ico'; ic.setAttribute('aria-hidden', 'true'); ic.textContent = ICON[p.t] || '❔'; el.appendChild(ic);
    var v = document.createElement('span'); v.className = 'pf-val'; v.textContent = String(p.v); el.appendChild(v);
    return el;
  }

  function place(x, y) {
    if (selected === null) return;
    moves.push({ i: selected, x: x, y: y });
    tiles[selected].classList.remove('pf-picked'); tiles[selected].setAttribute('aria-pressed', 'false');
    selected = null; render();
  }

  function render() {
    var lit = litCells(selected), b = working();
    boardEl.textContent = '';
    var P = window.PFParts, art = P && P.ok, S = art ? P.atlas.sizes.strip : null;
    // the view: the pieces plus one spot around them (at least 3 x 3), so the pieces stay big and nothing is shown that cannot be used
    var x0 = W, x1 = -1, y0 = H, y1 = -1;
    Object.keys(b.map).forEach(function (k) { var q = k.split(','), qx = +q[0], qy = +q[1]; x0 = Math.min(x0, qx); x1 = Math.max(x1, qx); y0 = Math.min(y0, qy); y1 = Math.max(y1, qy); });
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
    function put(el, x, y) {
      x -= x0; y -= y0;
      if (art) { el.style.left = (x * S.pitch[0] * 100 / TW) + '%'; el.style.top = (y * S.pitch[1] * 100 / TH) + '%'; el.style.width = (S.piece[0] * 100 / TW) + '%'; el.style.height = (S.piece[1] * 100 / TH) + '%'; }
      else { el.style.left = (x * 100 / VW) + '%'; el.style.top = (y * 100 / VH) + '%'; el.style.width = (100 / VW) + '%'; el.style.height = (100 / VH) + '%'; }
      boardEl.appendChild(el);
    }
    for (var y = y0; y <= y1; y++) for (var x = x0; x <= x1; x++) {
      var key = x + ',' + y, p = b.map[key], cell;
      if (p) {
        cell = document.createElement('div'); cell.className = 'pfb-cell' + (p.ghost ? ' pfb-planned' : '');
        if (art) {
          var cv = P.piece({ size: 'strip', owner: p.by === 'foe' ? 'foe' : 'me', type: p.t, edges: p.e, old: p.age >= 1, num: p.v, tint: data.tint });
          cv.className = 'pfb-cv'; cv.setAttribute('role', 'img'); cv.setAttribute('aria-label', (p.by === 'foe' ? 'Creature piece: ' : 'Your piece: ') + p.n + ', ' + p.t + ' ' + p.v + (p.age >= 1 ? ', expires this round' : ''));
          cell.appendChild(cv);
        } else cell.appendChild(pieceEl(p));
        if (p.age >= 1 && !p.ghost) { var ob = document.createElement('span'); ob.className = 'pfb-old'; ob.setAttribute('aria-hidden', 'true'); ob.textContent = '\u231B'; ob.title = 'Leaves the board at the end of this round'; cell.appendChild(ob); }
      } else if (lit[key]) {
        cell = document.createElement('button'); cell.type = 'button'; cell.className = 'pfb-cell pfb-lit'; cell.setAttribute('aria-label', 'Place here, column ' + (x + 1) + ' row ' + (y + 1));
        cell.dataset.x = String(x); cell.dataset.y = String(y);
        if (art) { var gc = P.ghost({ size: 'strip', owner: 'me', edges: data.hand[selected].e }); gc.className = 'pfb-cv'; gc.setAttribute('aria-hidden', 'true'); cell.appendChild(gc); }
      } else continue;
      put(cell, x, y);
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
          boardEl.appendChild(im);
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
          ge.dataset.v = String(d[7]); boardEl.appendChild(ge); glows.push(ge);
        });
      }
      data.fx.forEach(function (c) {
        var r = byId[c.ids[0]]; if (!r || r.x < x0 || r.x > x1 || r.y < y0 || r.y > y1) return;
        var sc = P.stamp(c.ids.length); sc.className = 'pfb-stamp'; sc.setAttribute('role', 'img'); sc.setAttribute('aria-label', 'Chain of ' + c.ids.length + ' pieces');
        sc.style.left = (((r.x - x0) * S.pitch[0] + S.tab[0] + S.body[0] - 22) * 100 / TW) + '%'; sc.style.top = (((r.y - y0) * S.pitch[1] + S.tab[1] - 14) * 100 / TH) + '%'; sc.style.width = (32 * 100 / TW) + '%'; sc.style.height = (32 * 100 / TH) + '%';
        boardEl.appendChild(sc); glows.push(sc);
      });
      if (!glowTimer && glows.length) startGlow();
    }
    tiles.forEach(function (t, i) { if (art && !t.dataset.arted) { t.dataset.arted = '1'; var hc = P.piece({ size: 'strip', owner: 'me', type: data.hand[i].t, edges: data.hand[i].e, num: t.dataset.v }); hc.className = 'pfh-cv'; hc.setAttribute('aria-hidden', 'true'); t.insertBefore(hc, t.firstChild); t.classList.add('pf-art2'); } });
    tiles.forEach(function (t, i) { t.hidden = !usable(i); });
    undo.disabled = moves.length === 0; go.disabled = moves.length === 0;
    var fits = anyFits();
    if (pform) pform.hidden = !(moves.length === 0 && !fits && selected === null);
    var heavy = heavyDone();
    prev.textContent = redrawMode ? 'Tap the piece to swap for a fresh one.' : moves.length === 0
      ? (fits ? 'Pick a piece, then a lit cell. Up to 4 pieces a turn. The newest piece plays first, then the pieces linked to it.' : 'Nothing in your hand fits anywhere. You can pass.')
      : moves.length + ' placed' + (heavy ? ' (a heavy piece ends your turn)' : moves.length >= 4 ? ' (the most you can place)' : '') + '. End turn when you are ready.' + (moves.length === 4 ? ' A full turn gives the creature an extra move.' : '');
  }

  function select(i) {
    if (!usable(i)) return;
    if (selected !== null) { tiles[selected].classList.remove('pf-picked'); tiles[selected].setAttribute('aria-pressed', 'false'); }
    selected = selected === i ? null : i;
    if (selected !== null) { tiles[i].classList.add('pf-picked'); tiles[i].setAttribute('aria-pressed', 'true'); showInspect(tiles[i]); }
    render();
  }
  function showInspect(b) {
    if (!insp) return;
    document.getElementById('pfi-name').textContent = b.dataset.name || '';
    document.getElementById('pfi-desc').textContent = b.dataset.desc || '';
    insp.hidden = false;
  }

  handEl.addEventListener('click', function (ev) {
    var b = ev.target.closest('.pf-tile'); if (!b) return;
    var i = tiles.indexOf(b);
    if (redrawMode) { if (submitted) return; submitted = true; tiles.forEach(function (t) { t.disabled = true; }); document.getElementById('pf-card').value = String(i); document.getElementById('pf-rform').submit(); return; }
    select(i);
  });
  boardEl.addEventListener('click', function (ev) {
    var c = ev.target.closest('.pfb-lit'); if (c) place(parseInt(c.dataset.x, 10), parseInt(c.dataset.y, 10));
  });
  // drag and drop (mouse); touch uses the two taps
  handEl.addEventListener('dragstart', function (ev) {
    var b = ev.target.closest('.pf-tile'); if (!b || redrawMode) { ev.preventDefault(); return; }
    var i = tiles.indexOf(b); if (!usable(i)) { ev.preventDefault(); return; }
    if (selected !== i) select(i);
    try { ev.dataTransfer.setData('text/plain', String(i)); ev.dataTransfer.effectAllowed = 'move'; } catch (e) {}
  });
  boardEl.addEventListener('dragover', function (ev) { if (ev.target.closest('.pfb-lit')) { ev.preventDefault(); ev.dataTransfer.dropEffect = 'move'; } });
  boardEl.addEventListener('drop', function (ev) {
    var c = ev.target.closest('.pfb-lit'); if (!c) return; ev.preventDefault();
    place(parseInt(c.dataset.x, 10), parseInt(c.dataset.y, 10));
  });
  undo.addEventListener('click', function () { moves.pop(); selected = null; tiles.forEach(function (t) { t.classList.remove('pf-picked'); t.setAttribute('aria-pressed', 'false'); }); render(); if (undo.disabled && tiles[0]) { var f = tiles.filter(function (t) { return !t.hidden; })[0]; if (f) f.focus(); } });
  form.addEventListener('submit', function (e) {
    if (submitted || !moves.length) { e.preventDefault(); return; }
    submitted = true; go.disabled = true; undo.disabled = true;
    movesIn.value = moves.map(function (m) { return [m.i, m.x, m.y].join(','); }).join(';');
  });
  if (rbtn && parseInt(root.dataset.redraws || '0', 10) > 0) {
    rbtn.hidden = false;
    rbtn.addEventListener('click', function () { redrawMode = !redrawMode; moves = []; selected = null; rbtn.setAttribute('aria-pressed', redrawMode ? 'true' : 'false'); rbtn.classList.toggle('pf-on', redrawMode); render(); });
  }
  window.addEventListener('pageshow', function (e) { if (e.persisted) location.reload(); });
  document.addEventListener('pfparts-ready', render);
  window.pfbLegal = legal;   // for the parity test
  render();
})();
