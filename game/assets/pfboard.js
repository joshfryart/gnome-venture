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
    for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) {
      var key = x + ',' + y, p = b.map[key], cell;
      if (p) { cell = document.createElement('div'); cell.className = 'pfb-cell'; cell.appendChild(p.ghost ? pieceEl(p) : pieceEl(p)); }
      else if (lit[key]) {
        cell = document.createElement('button'); cell.type = 'button'; cell.className = 'pfb-cell pfb-lit'; cell.setAttribute('aria-label', 'Place here, column ' + (x + 1) + ' row ' + (y + 1));
        cell.dataset.x = String(x); cell.dataset.y = String(y);
      } else { cell = document.createElement('div'); cell.className = 'pfb-cell pfb-empty'; }
      boardEl.appendChild(cell);
    }
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
  window.pfbLegal = legal;   // for the parity test
  render();
})();
