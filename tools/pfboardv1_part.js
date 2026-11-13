  // ================= v1 (2.6.74 stage C): state, texts and drawing helpers. Ported from the approved demo (tools/pfdemo_v1/app.js); the texts mirror claude/design-board-strategy.md, "Player-facing terrain text".
  var V1 = data.v1 || {}, PREV = data.prev || null, phase = 'now', terOver = {}, movedBack = {}, usedGone = {}, leavingUsed = {}, flashEnv = null, flashIds = {}, aimHide = false, stepNow = 0, stepNote = '';
  var ENV = !!V1.env, ENVD = data.env || { next: [] }, envLit = {}, slideIds = {}, fadeIds = {}, fxPop = null, stripRem = [], stripNew = false, stripBad = false, lastLegend = '';
  var flipBusy = false, wrapObs = null, wrapEl = null, fitTW = 0, fitTH = 0;
  var planQ = null, offMsg = '', popEl = null, sheetEl = null, rowEl = document.getElementById('pfv-row'), legendEl = document.getElementById('pfv-legend'), flipBtn = document.getElementById('pf-flip');
  var SPD = 1; try { var sp0 = window.localStorage.getItem('pfvspd'); SPD = sp0 === '2' ? 2 : sp0 === '0' ? 0 : 1; } catch (e) {}
  var FOETAG = { quick: 'Quick: it plays one more piece this turn', evade: 'Evade: your next hit on it misses', bash: 'Bash: adds its guard to its next hit', poison: 'Poison: 2 ticks on your health',
    trip: 'Trip: you draw 1 fewer next round', heal: 'Recovers a little', thorns: 'Thorns: hitting its guard pricks you', hold: 'Hold: this guard lasts a turn longer', pierce: 'Pierce: ignores your guard' };
  var EVN = { sunbeam: 'Sunbeam', creep: 'Bramble creep', puddle: 'Puddle', gust: 'Gust', thorn: 'Thorn burst' }, EVW = { sunbeam: 'sunny', creep: 'bramble', puddle: 'mud', gust: 'push', thorn: 'burst' };
  var EVG = { sunbeam: 'sun', creep: 'br', puddle: 'mud', gust: 'gust', thorn: 'thorn' }, EVT = { sunbeam: 'sun', creep: 'br', puddle: 'mud' }, GRN = { sun: 'Sunny patch', br: 'Bramble', mud: 'Mud' }, ROT = { R: 0, B: 90, L: 180, T: 270 };
  var SRCI = { tool: '🔧', pal: '🐾', crop: '🌾' };
  var SVG = {
    sun: '<circle cx="8" cy="8" r="3.2" fill="currentColor"/><path d="M8 1v2.4M8 12.6V15M1 8h2.4M12.6 8H15M3 3l1.7 1.7M11.3 11.3L13 13M13 3l-1.7 1.7M4.7 11.3L3 13" stroke="currentColor" stroke-width="1.6" fill="none"/>',
    br: '<path d="M2 13C5 11 6 6 9 5s4-2 5-3" stroke="currentColor" stroke-width="1.8" fill="none"/><path d="M5 10l-3-2M7 7L5 3M10 5l3 3M12 3l-1-2" stroke="currentColor" stroke-width="1.6" fill="none"/>',
    mud: '<path d="M1 5c2-2 3 2 5 0s3 2 5 0 3 1 4 0M1 9c2-2 3 2 5 0s3 2 5 0 3 1 4 0M1 13c2-2 3 2 5 0s3 2 5 0 3 1 4 0" stroke="currentColor" stroke-width="1.6" fill="none"/>',
    gust: '<path d="M2 8h10M8 3.5L12.5 8 8 12.5" stroke="currentColor" stroke-width="2.2" fill="none"/>',
    thorn: '<path d="M8 0l1.8 5L15 3l-3 4.6L16 9l-4.6 1L13 15l-4.2-3L8 16l-1-4-4 3 1.6-5L0 9l4-1.4L1 3l5.2 2z" fill="currentColor"/>',
    rain: '<path d="M4.4 9.2A2.9 2.9 0 0 1 4.9 3.6a3.6 3.6 0 0 1 6.9 1.1 2.5 2.5 0 0 1-.5 4.5z" stroke="currentColor" stroke-width="1.5" fill="none"/><path d="M5 11.2v2.6M8 11v3.4M11 11.2v2.6" stroke="currentColor" stroke-width="1.6" fill="none"/>',
    wind: '<path d="M1.5 5.5h8.2a2 2 0 1 0-2-2" stroke="currentColor" stroke-width="1.7" fill="none"/><path d="M1.5 8.6h11.2a2 2 0 1 1-2 2" stroke="currentColor" stroke-width="1.7" fill="none"/><path d="M1.5 11.7h5.5" stroke="currentColor" stroke-width="1.7" fill="none"/>',
    env: '<path d="M1 13.5l4.6-7.6 3 4.6 2-2.9L15 13.5z" fill="currentColor"/><circle cx="12" cy="3.6" r="1.8" fill="currentColor"/>',
    aim: '<circle cx="8" cy="8" r="5.2" stroke="currentColor" stroke-width="1.8" fill="none"/><circle cx="8" cy="8" r="1.6" fill="currentColor"/><path d="M8 0v3.4M8 12.6V16M0 8h3.4M12.6 8H16" stroke="currentColor" stroke-width="1.8"/>'
  };
  function esc(x) { return String(x).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }
  function svg(k, rot) { return '<svg viewBox="0 0 16 16" aria-hidden="true"' + (rot ? ' class="pfv-r' + rot + '"' : '') + '>' + SVG[k] + '</svg>'; }
  function svgEl(k, rot) { var h = document.createElement('span'); h.innerHTML = svg(k, 0); var el = h.firstChild; if (rot) el.style.transform = 'rotate(' + rot + 'deg)'; return el; }
  function pc100(x) { return Math.round(x * 100) + '%'; }
  function times(x) { return x === 2 ? 'double' : x === 3 ? 'triple' : x === 1 ? 'as normal' : '×' + x; }
  // ---- 2.6.75 ENVIRONMENT PIECES (design-board-strategy.md, "Sim 5"): a third player that puts pieces on the board. Texts and numbers come from the fight's own rule values (V1).
  var EK = { sun: { n: 'Sun', s: 'Sun', c: '#ffd65a', h: 46, i: 'sun' }, bramble: { n: 'Bramble', s: 'Bramble', c: '#7ab55c', h: 105, i: 'br' }, rain: { n: 'Rain', s: 'Rain', c: '#6db4d0', h: 200, i: 'rain' },
    wind: { n: 'Wind', s: 'Wind', c: '#c3cde0', h: 220, i: 'wind' }, mud: { n: 'Mud', s: 'Mud', c: '#a67c52', h: 28, i: 'mud' }, thorn: { n: 'Thornburst', s: 'Thorn', c: '#ff6a4a', h: 8, i: 'thorn' } };
  var DIRW = { L: 'left', R: 'right', T: 'up', B: 'down' }, DXY = { L: [-1, 0], R: [1, 0], T: [0, -1], B: [0, 1] };
  var ENAME = { Sun: 'sun', Bramble: 'bramble', Rain: 'rain', Wind: 'wind', Mud: 'mud', Thornburst: 'thorn' };
  (data.gone || []).forEach(function (g) { if (g.by === 'env' && !g.kind) g.kind = ENAME[g.n] || 'mud'; });   // an older save: no kind on a piece that left
  function envKind(k) { return EK[k] || EK.mud; }
  function envBadge(kind) {
    return { sun: '×' + (V1.sun || 2), bramble: '−' + pc100(V1.bramble || 0), rain: '+' + pc100(V1.rain || 0), mud: '−' + pc100(V1.mud || 0), thorn: '−' + pc100(V1.thorn || 0) }[kind] || '';
  }
  function envText(kind, life) {
    var who = 'Goes to whoever fires it: you or the creature.', lf = life ? ' It goes after ' + life + ' rounds.' : '', N = (V1.limit || 3);
    var T = {
      sun: { l: ['Fire it in your chain: your pieces in that chain count ' + times(V1.sun || 2) + ' (damage, charm, guard and healing).'], chip: '×' + (V1.sun || 2) + ' for the chain' },
      bramble: { l: ['Fire it in your chain: the creature loses ' + pc100((V1.bramble || 0) * (V1.br_foe || 1)) + ' of its health. If the creature fires it, you lose ' + pc100(V1.bramble || 0) + ' of yours. Guard does not help.'], chip: '−' + pc100(V1.bramble || 0) + ' to the other side' },
      rain: { l: ['Fire it in your chain: you get guard worth ' + pc100(V1.rain || 0) + ' of your health. If the creature fires it, it gets the guard.'], chip: 'guard' },
      wind: { l: ['Fire it in your chain: the piece its arrow points at slides one cell along the arrow, if that cell is free.'], chip: 'pushes a piece' },
      mud: { l: ['Nothing links to it, so chains stop here. A piece next to it counts ' + pc100(V1.mud || 0) + ' less.' + lf], chip: 'no links, −' + pc100(V1.mud || 0) + ' next to it' },
      thorn: { l: ['Fire it in your chain and you lose ' + pc100(V1.thorn || 0) + ' of your health. The creature loses ' + pc100((V1.thorn || 0) * (V1.th_foe || 1)) + ' when it fires it. Link around it, or make the creature run into it.'], chip: '−' + pc100(V1.thorn || 0) + ' to you, −' + pc100((V1.thorn || 0) * (V1.th_foe || 1)) + ' to the creature' }
    }[kind];
    if (!T) return null;
    if (kind !== 'mud' && lf) T.l.push(lf.trim());
    return { n: envKind(kind).n, g: envKind(kind).i, l: T.l, who: who, chip: T.chip };
  }
  function envTurnText() {
    var n = ENVD.n || V1.envn || 2;
    return { n: 'Environment turn', g: 'env', l: ['Every round goes: you, the creature, then the environment.',
      'On its turn the environment puts ' + (n === 1 ? 'a piece' : n + ' pieces') + ' on the board. The pieces shown as NEXT are the ones it places at the end of this round, the left one first.',
      'The environment drops its pieces on empty spots away from the action, with nothing next to them, to keep fights varied. Place next to one to link to it. Its pieces belong to nobody. Link to one and it fires in your chain, for you. The creature can do the same.',
      'They count for the chain like any piece: a chain of ' + (V1.limit || 3) + ' or more uses them up.'], who: 'Same rules for you and the creature.' };
  }
  function envTurnNote() { var n = ENVD.n || V1.envn || 2; return 'Environment turn. It puts ' + (n === 1 ? 'its piece' : 'its ' + n + ' pieces') + ' on the board. Nothing fires on its turn.'; }
  function envTurnSub() { var n = ENVD.n || V1.envn || 2; return 'the environment places ' + (n === 1 ? 'a piece' : n + ' pieces') + ', not the creature'; }
  // 2.6.76: notices (Quick, a lost turn, a trip, the opening): short plain words for the banner, the message line and the row
  function foeSub() { var q = (data.replay || []).filter(function (e) { return e.note === 'quick' || e.note === 'slow'; })[0]; return q ? (q.note === 'slow' ? 'loses its turn' : (q.n ? q.n + ': ' : '') + 'Quick, plays a second piece') : ''; }
  function meSub() { return data.tripped ? 'Tripped: you drew 1 fewer piece' : (data.opened && root.dataset.turn === '1' ? 'the ' + (data.foe || 'creature') + ' opened with ' + data.opened + ' piece' + (data.opened === 1 ? '' : 's') : ''); }
  /** a piece drawn on a canvas: the vector icons above, painted with Path2D */
  function glyph(g, k, x, y, size, col) {
    var re = /<(circle|path)([^>]*)\/>/g, m, sc = size / 16;
    g.save(); g.translate(x, y); g.scale(sc, sc); g.fillStyle = col; g.strokeStyle = col; g.lineCap = 'round'; g.lineJoin = 'round';
    while ((m = re.exec(SVG[k]))) {
      var a = m[2], at = function (n) { var q = new RegExp(' ' + n + '="([^"]*)"').exec(' ' + a.trim()); return q ? q[1] : null; }, pp;
      if (m[1] === 'circle') { pp = new Path2D(); pp.arc(+at('cx'), +at('cy'), +at('r'), 0, 7); } else pp = new Path2D(at('d'));
      if (at('fill') === 'none') { g.lineWidth = +at('stroke-width') || 1.6; g.stroke(pp); } else g.fill(pp);
    }
    g.restore();
  }
  /** an environment piece: the parts kit's piece (so the edges and knobs are the real ones) in its own colour, a dark disc with the kind's icon, and a dashed cream frame no player piece has */
  function envCv(P, p, size) {
    var K = envKind(p.kind), sz = P.atlas.sizes[size], cv = P.piece({ size: size, owner: 'foe', type: 'soothe', tint: K.h, edges: p.e, old: false, num: '' }), g = cv.getContext('2d');
    g.globalCompositeOperation = 'source-atop'; g.fillStyle = K.c + 'a6'; g.fillRect(0, 0, cv.width, cv.height); g.globalCompositeOperation = 'source-over';
    var ia = sz.icon.at, is = sz.icon.size[0];
    g.fillStyle = '#2a1a10'; g.beginPath(); g.arc(ia[0] + is / 2, ia[1] + is / 2, is / 2 + 1, 0, 7); g.fill();
    glyph(g, K.i, ia[0] + 3, ia[1] + 3, is - 6, K.c);
    g.setLineDash([4, 3]); g.strokeStyle = '#f2e4c0'; g.lineWidth = size === 'hand' ? 3 : 1.6; g.strokeRect(sz.body_at[0] + 2, sz.body_at[1] + 2, sz.body[0] - 4, sz.body[1] - 4);
    return cv;
  }
  function mudNear(x, y) { return ENV && data.pcs.some(function (q) { return q.kind === 'mud' && Math.abs(q.x - x) + Math.abs(q.y - y) === 1; }); }
  /** on a board cell: an environment piece's effect badge (Wind: its arrow) and the effect it is playing now; a player piece next to a Mud: the mud mark */
  function envDeco(cell, p) {
    if (!ENV || p.ghost || p.gone || p.by === 'none') return;
    var b;
    if (p.by === 'env') {
      b = document.createElement('span'); b.className = 'pfv-eb k-' + p.kind; b.setAttribute('aria-hidden', 'true');
      if (p.kind === 'wind') b.appendChild(svgEl('gust', ROT[p.dir] || 0)); else b.textContent = envBadge(p.kind);
      cell.appendChild(b);
    } else if (mudNear(p.x, p.y)) {
      b = document.createElement('span'); b.className = 'pfv-mn'; b.title = 'Next to Mud: counts ' + pc100(V1.mud || 0) + ' less'; b.setAttribute('aria-hidden', 'true'); b.appendChild(svgEl('mud')); cell.appendChild(b);
    }
    if (fxPop && fxPop.id === p.id) { var f = document.createElement('span'); f.className = 'pfv-fx k-' + (fxPop.kind || ''); f.textContent = fxPop.t; cell.appendChild(f); }
  }
  /** which environment pieces your chain would fire from each lit spot: they glow while a piece is picked */
  function envLitSet(lit, b) {
    var out = {}; if (!ENV || selected === null || selected === 'group' || !data.hand[selected]) return out;
    var e = data.hand[selected].e;
    Object.keys(lit).forEach(function (k) {
      var q = k.split(','), seen = {}, stack = [{ x: +q[0], y: +q[1], e: e }]; seen[k] = 1;
      while (stack.length) {
        var a = stack.pop();
        for (var s in SIDE) {
          var nx = a.x + SIDE[s][0], ny = a.y + SIDE[s][1], nk = nx + ',' + ny, n = b.map[nk];
          if (!n || seen[nk] || n.by === 'none' || n.gone || n.ghost || !joint(a.e[s], n.e[SIDE[s][2]])[1]) continue;
          seen[nk] = 1; if (n.by === 'env') out[n.id] = 1; stack.push({ x: nx, y: ny, e: n.e });
        }
      }
    });
    return out;
  }
  function envPieceInfo(p) {
    var T = envText(p.kind, null), t = T.n + ' (environment piece). ';
    if (p.gone) return t + (p.used ? 'Used up by a chain of ' + (V1.limit || 3) + ' or more.' : 'It has faded.');
    return t + T.l.join(' ') + (p.kind === 'wind' && p.dir ? ' Its arrow points ' + DIRW[p.dir] + '.' : '') + ' It belongs to nobody. ' + (p.left <= 1 ? 'It leaves the board at the end of this round.' : 'It stays for ' + p.left + ' more rounds.');
  }
  var WHEN = 'Lands at the end of this round, after the creature’s move.';
  function terrText(k) {
    var foeBr = V1.br_foe !== 1 ? ' The creature’s pieces cost it ' + pc100(V1.bramble * V1.br_foe) + '.' : '';
    return { sun: { n: 'Sunny patch', g: 'sun', l: ['A Hurt or Charm piece standing here counts ' + times(V1.sun) + '.'], who: 'Works for you and the creature.' },
      br: { n: 'Bramble', g: 'br', l: ['At the end of every round, a piece standing here costs its owner ' + pc100(V1.bramble) + ' of their health.' + foeBr], who: 'Pricks you and the creature.' },
      mud: { n: 'Mud', g: 'mud', l: ['A piece here does not link. No chain runs into it or out of it.'], who: 'Stops your chains and the creature’s.' } }[k];
  }
  function evText2(k) {
    var foeEv = V1.ev_foe !== 1 ? ' The creature’s pieces cost it ' + pc100(V1.thorn * V1.ev_foe) + '.' : '';
    return { sunbeam: { n: 'Sunbeam', g: 'sun', w: 'turns sunny', l: ['This cell turns sunny. The oldest sunny patch fades.', WHEN], who: 'Good for whoever stands here.' },
      creep: { n: 'Bramble creep', g: 'br', w: 'turns to bramble', l: ['This cell turns to bramble and pricks at once (' + pc100(V1.bramble) + ' of health). The oldest bramble withers.', WHEN], who: 'Hurts whoever stands here.' },
      puddle: { n: 'Puddle', g: 'mud', w: 'turns to mud', l: ['This cell turns to mud, so links here are cut. The old mud dries up.', WHEN], who: 'Cuts chains for both sides.' },
      gust: { n: 'Gust', g: 'gust', w: 'pushes a piece', l: ['The piece here is pushed one cell along the arrow, if that cell is free.', WHEN], who: 'Moves your piece or the creature’s.' },
      thorn: { n: 'Thorn burst', g: 'thorn', w: 'hurts around it', l: ['Every piece on this cell and the 4 cells next to it costs its owner ' + pc100(V1.thorn) + ' of their health.' + foeEv, WHEN], who: 'Hits both sides.' } }[k];
  }
  function turnText() { return { n: 'Terrain turn', g: 'thorn', l: ['Every round goes: you, the creature, then the terrain.', 'On the terrain turn the marked events land in order, then bramble pricks, then old pieces expire. The next events are marked before you move.'], who: 'Same rules for you and the creature.' }; }

  function isOld(p) { return p.left !== undefined ? p.left <= 1 : (p.gone ? false : p.age >= LIFE1); }
  function mudAt(x, y) { return ((data.ter || {})[x + ',' + y] || '') === 'mud'; }   // the rules use the ground as it is now
  function terAt(x, y) { var k = x + ',' + y; return phase === 'pre' && PREV ? (terOver[k] || (PREV.ter || {})[k] || '') : ((data.ter || {})[k] || ''); }   // what is drawn (the replay starts from the ground before the turn)
  function dispEnvs() { return (phase === 'pre' && PREV ? PREV.envs : data.envs) || []; }
  function dispAim() { return phase === 'pre' && PREV ? (aimHide ? null : PREV.aim) : data.aim; }
  function pipsEl(n, max) { var s = document.createElement('span'); s.className = 'xp' + (n <= 1 && max > 1 ? ' last' : ''); s.setAttribute('aria-hidden', 'true'); for (var i = 0; i < max; i++) { var d = document.createElement('i'); if (i >= n) d.className = 'e'; s.appendChild(d); } return s; }
  function flipE(e) { return { L: e.L, R: e.R, T: e.B, B: e.T }; }

  /** Ground under every cell: a plain cell, or a button that says what the ground does. */
  function drawGround(putBody) {
    for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) {
      var k = terAt(x, y), el = document.createElement(k ? 'button' : 'div');
      el.className = 'gc' + (k ? ' g-' + k : '');
      if (k) { el.type = 'button'; el.dataset.ter = k; el.dataset.y = String(y); el.setAttribute('aria-label', GRN[k] + ', column ' + (x + 1) + ' row ' + (y + 1) + ': what it does'); }
      putBody(el, x, y);
    }
  }
  /** Over the pieces: a frame and an icon on every ground cell, the forecast marks (with a word), the creature's aim. */
  function drawMarks(putBody, b) {
    var x, y, k;
    for (y = 0; y < H; y++) for (x = 0; x < W; x++) { k = terAt(x, y); if (!k) continue; var gf = document.createElement('div'); gf.className = 'gf g-' + k; gf.appendChild(svgEl(k)); putBody(gf, x, y); }
    if (data.won || rewind) return;
    var envs = dispEnvs();
    envs.forEach(function (e, ek) {
      if (phase === 'pre' && envDone[ek]) return;
      if (e.kind === 'thorn') [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]].forEach(function (d) { var zx = e.x + d[0], zy = e.y + d[1]; if (zx >= 0 && zy >= 0 && zx < W && zy < H) { var z = document.createElement('div'); z.className = 'mk zone'; putBody(z, zx, zy); } });
      var mk = document.createElement('div'); mk.className = 'mk ev k-' + e.kind + (flashEnv === ek ? ' evflash' : '');
      var bt = document.createElement('button'); bt.type = 'button'; bt.className = 'mkb' + (envs.some(function (o, ok) { return ok < ek && o.x === e.x && o.y === e.y; }) ? ' m2' : ''); bt.dataset.ev = String(ek);
      bt.setAttribute('aria-label', EVN[e.kind] + ', column ' + (e.x + 1) + ' row ' + (e.y + 1) + ': what it will do');
      bt.appendChild(svgEl(EVG[e.kind], e.kind === 'gust' ? ROT[e.dir] : 0)); var em = document.createElement('em'); em.textContent = EVW[e.kind]; bt.appendChild(em); mk.appendChild(bt); putBody(mk, e.x, e.y);
    });
    var aim = dispAim(), st = data.status || {};
    if (aim && !data.start && !(st.foe_slow && phase !== 'pre') && typeof aim.x === 'number') {
      var am = document.createElement('div'); am.className = 'mk aim'; am.setAttribute('role', 'img'); am.setAttribute('aria-label', 'The creature aims ' + aim.n + ' ' + aim.t + ' ' + aim.v + ' here, column ' + (aim.x + 1) + ' row ' + (aim.y + 1));
      am.appendChild(svgEl('aim')); var ab = document.createElement('b'); ab.textContent = String(aim.v); am.appendChild(ab); putBody(am, aim.x, aim.y);
    }
  }
  var envDone = {};

  // ---- the hand: life pips, Teamwork source, flipped mark; a piece that cannot be played right now is faded and says why when tapped
  function countCells(e, must) { var b = baseBoard(), n = 0; for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) { var f = fitInfo(b, e, x, y); if (f >= 0 && (!must || f === 1)) n++; } return n; }
  function handWhy(i) {
    var h = data.hand[i]; if (!h || data.start || data.won) return null;
    var b = baseBoard(), edges = handEdges(), must = mustLink(b, edges);
    if (countCells(h.e, must)) return null;
    if (h.canflip) { var e2 = edges.slice(); e2[i] = flipE(h.e); if (countCells(e2[i], mustLink(b, e2))) return null; }   // it fits once flipped: playable (the Flip button)
    if (countCells(h.e, false) || (h.canflip && countCells(flipE(h.e), false))) return 'No spot links. Another piece can link, so this one has to wait.';
    return 'No spot fits this piece' + (V1.flip && !h.canflip && data.flip && data.flip.used ? ', and your flip is used this turn.' : ', flipped or not.');
  }
  function handDeco(busy) {
    tiles.forEach(function (t, i) {
      var h = data.hand[i]; if (!h) return;
      if (!t.dataset.v1) { t.dataset.v1 = '1';
        if (h.life) t.appendChild(pipsEl(h.life, h.life));
        if (SRCI[h.src]) { var s = document.createElement('span'); s.className = 'src'; s.title = 'Teamwork source: ' + h.src; s.setAttribute('aria-hidden', 'true'); s.textContent = SRCI[h.src]; t.appendChild(s); }
        t.setAttribute('aria-label', t.getAttribute('aria-label') + '; stays ' + (h.life || 3) + ' rounds' + (SRCI[h.src] ? '; Teamwork source: ' + h.src : '') + (h.flip ? '; flipped' : ''));
      }
      t.classList.toggle('pfv-flipped', !!h.flip);
      var why = busy || redrawMode ? null : handWhy(i);
      t.classList.toggle('pfv-off', !!why); if (why) t.setAttribute('aria-disabled', 'true'); else t.removeAttribute('aria-disabled');
    });
  }

  // ---- the rows above the board: turn order, chain dots, Teamwork, the aim, the forecast (with words), what waits on each side, tool wear
  function drawRows() {
    if (!rowEl) return;
    var foe = data.foe || 'Creature', h = '', lim = V1.limit || 0, n = planQ && moves.length ? planQ.n || 0 : 0, tw = planQ && moves.length ? planQ.tw || 1 : 1, st = data.status || {}, i, dots = '';
    h += '<span class="tg step on" title="Every round goes: you, the creature, then the ' + (ENV ? 'environment' : 'terrain') + '">R' + (data.round || 1) + ' \u00B7 ' + (data.won ? 'over' : stepNow === 1 ? '<span class="fn">' + esc(foe) + '</span>' : stepNow === 2 ? (ENV ? 'Environment' : 'Terrain') : 'You') + '</span>';
    for (i = 1; i <= Math.max(lim, 3); i++) dots += '<i class="' + (n >= i ? (lim > 0 && n >= lim ? 'over' : 'on') : '') + '"></i>';
    h += '<span class="tg" role="img" aria-label="Pieces that fire in your chain: ' + n + '. ' + (lim > 0 ? lim + ' or more: every piece that fired is used up.' : '') + '" title="' + (lim > 0 ? 'A chain of ' + lim + ' or more uses up every piece that fired.' : 'Chain') + '">chain <span class="dots">' + dots + '</span></span>';
    h += '<span class="tg team' + (tw > 1 ? ' on' : '') + '" title="Pal, tool and crop pieces in one chain: 2 kinds +30%, all 3 +60%">' + (tw > 1 ? 'Teamwork +' + Math.round((tw - 1) * 100) + '%' : 'Teamwork') + '</span>';
    if (!data.won) {
      var aim = dispAim();
      if (!data.start) h += st.foe_slow && phase !== 'pre' ? '<span class="tg good">' + esc(foe) + ' is slowed: no move</span>' : aim ? '<span class="tg aim">' + svg('aim') + 'Aims ' + esc(aim.n) + ' ' + esc(aim.t) + ' ' + aim.v + (data.reaim && phase !== 'pre' ? ' (picked again)' : '') + '</span>' : '<span class="tg aim">no aim</span>';
      dispEnvs().forEach(function (e, k) { if (phase === 'pre' && envDone[k]) return; h += '<button type="button" class="tg ev" data-ev="' + k + '">' + svg(EVG[e.kind]) + (e.kind === 'gust' && e.on ? 'Gust: pushes ' + esc(e.on.n) : EVN[e.kind]) + '</button>'; });
      if (st.poison) h += '<span class="tg bad">poisoned ' + st.poison + '</span>';
      if (st.slowdraw) h += '<span class="tg bad">tripped: draw −1</span>';
      else if (data.tripped) h += '<span class="tg bad" title="The creature tripped you: you drew one fewer piece this turn">tripped: drew 1 fewer</span>';
      if (st.foe_evade) h += '<span class="tg bad">it dodges your next hit</span>';
      if (st.foe_thorns) h += '<span class="tg bad">thorny guard</span>';
      if (st.foe_bash) h += '<span class="tg bad">bash waits</span>';
      if (st.evade) h += '<span class="tg good">you dodge the next hit</span>';
    }
    var tools = data.tools || {}, wear = data.wear || {}, inHand = {}; data.hand.forEach(function (t) { if (t.tool) inHand[t.tool] = 1; });
    Object.keys(tools).forEach(function (ty) { var w = wear[ty] || 0; if (!w && !inHand[ty]) return; var left = Math.max(0, tools[ty].left - w), f = left / Math.max(1, tools[ty].max);
      h += '<span class="tg wear' + (f <= .25 ? ' crit' : f <= .5 ? ' low' : '') + '" title="Tool durability: −' + (data.toolwear || 2) + ' each time its piece is played">🔧 ' + esc(tools[ty].n) + ' ' + left + '/' + tools[ty].max + '</span>'; });
    rowEl.innerHTML = h;
    Array.prototype.forEach.call(rowEl.querySelectorAll('.tg.ev'), function (bt) { var e = dispEnvs()[+bt.dataset.ev]; if (e && e.kind === 'gust') { var sv = bt.querySelector('svg'); if (sv) sv.style.transform = 'rotate(' + ROT[e.dir] + 'deg)'; } });
  }
  function spdLabel() { return '▶ ' + (SPD === 2 ? '2×' : SPD === 0 ? 'skip' : '1×'); }
  function stripItems() {
    if (phase === 'pre' && PREV && PREV.env) return (PREV.env.next || []).map(function (it, i) { return { it: it, i: i }; }).filter(function (o) { return stripRem.indexOf(o.i) < 0; }).map(function (o) { return o.it; });
    return ENVD.next || [];
  }
  function drawStrip() {
    var items = stripItems(), h = '<button type="button" class="tg envlab" data-a="turn" aria-label="Environment turn: what happens in a round">' + svg('env') + '<span class="el">Environment</span><span class="es">Env</span></button>';
    items.forEach(function (it, i) {
      var K = envKind(it.kind), pips = '<span class="xp" aria-hidden="true">'; for (var q = 0; q < it.life; q++) pips += '<i></i>'; pips += '</span>';
      h += '<button type="button" class="tg envp k-' + it.kind + (stripNew ? ' pfv-flipup' : '') + (stripBad && i === 0 ? ' pfv-nope' : '') + '" data-en="' + i + '" aria-label="Next environment piece ' + (i + 1) + ': ' + K.n + ', stays ' + it.life + ' rounds. What it does">' + svg(K.i) + '<span class="fn">' + K.s + '</span>' + pips + '</button>';
    });
    if (!items.length) h += '<span class="tg envnone">all on the board</span>';
    h += '<button type="button" class="tg qm" data-a="help" aria-label="Help: how the board and the environment work">?</button>'
      + '<button type="button" class="tg spd" data-a="spd" aria-label="Animation speed: ' + (SPD === 2 ? 'double' : SPD === 0 ? 'skip' : 'normal') + '. Press to change">' + spdLabel() + '</button>';
    if (h !== lastLegend) { lastLegend = h; legendEl.innerHTML = h; }
  }
  function drawLegend() {
    if (!legendEl) return;
    if (ENV) { drawStrip(); return; }
    legendEl.innerHTML = [['sun', '\u00d7' + V1.sun, 'Sunny: counts ' + times(V1.sun)], ['br', '\u2212' + pc100(V1.bramble || 0), 'Bramble: \u2212' + pc100(V1.bramble || 0) + ' a round'], ['mud', 'no links', 'Mud: no links']].map(function (q) { return '<button type="button" class="tg lg-' + q[0] + '" data-ter="' + q[0] + '" aria-label="' + q[2] + '. Press for more" title="' + q[2] + '">' + svg(q[0]) + q[1] + '</button>'; }).join('')
      + '<button type="button" class="tg" data-a="turn" aria-label="Terrain turn: what happens in a round">Turn</button><button type="button" class="tg qm" data-a="help" aria-label="Help: how the board works">?</button>'
      + '<button type="button" class="tg spd" data-a="spd" aria-label="Animation speed: ' + (SPD === 2 ? 'double' : SPD === 0 ? 'skip' : 'normal') + '. Press to change">' + spdLabel() + '</button>';
  }

  // ---- popover over the board (a ground cell, a forecast mark, a legend chip) and the help sheet
  function closePop() { if (popEl && popEl.parentNode) popEl.parentNode.removeChild(popEl); popEl = null; }
  function popHtml(pt, rot) { return '<span class="pfv-popi">' + svg(pt.g, 0) + '</span><span class="pfv-popt"><b>' + esc(pt.n) + '</b>' + pt.l.map(function (x) { return '<span>' + esc(x) + '</span>'; }).join('') + '<i>' + esc(pt.who) + '</i>' + (pt.chip ? '<em class="pfv-pchip">' + esc(pt.chip) + '</em>' : '') + '</span>'; }
  function showPop(o) {
    var same = popEl && popEl.dataset.k === o.t + ':' + o.k; closePop(); if (same) return;
    var pt = o.t === 'ter' ? terrText(o.k) : o.t === 'turn' ? (ENV ? envTurnText() : turnText()) : o.t === 'envp' ? envText(o.k, o.life) : evText2(o.k); if (!pt) return;
    popEl = document.createElement('div'); popEl.className = 'pfv-pop'; popEl.setAttribute('role', 'dialog'); popEl.setAttribute('aria-label', pt.n); popEl.dataset.k = o.t + ':' + o.k;
    popEl.innerHTML = popHtml(pt) + '<button type="button" class="pfv-popx" aria-label="Close">×</button>';
    if (o.rot) { var sv = popEl.querySelector('svg'); if (sv) sv.style.transform = 'rotate(' + o.rot + 'deg)'; }
    root.appendChild(popEl);
    var top = o.y !== undefined && o.y !== null && o.y >= H / 2;
    popEl.style.top = (top ? boardEl.offsetTop + 4 : Math.max(4, boardEl.offsetTop + boardEl.offsetHeight - popEl.offsetHeight - 4)) + 'px';
    popEl.querySelector('.pfv-popx').addEventListener('click', closePop);
  }
  function boardTap(ev) {
    var m = ev.target.closest('.mkb');
    if (m) { var e = dispEnvs()[+m.dataset.ev]; if (e) showPop({ t: 'ev', k: e.kind, rot: e.kind === 'gust' ? ROT[e.dir] : 0, y: e.y }); return true; }
    var g = ev.target.closest('.gc[data-ter]');
    if (g) { showPop({ t: 'ter', k: g.dataset.ter, y: +g.dataset.y }); return true; }
    return false;
  }
  function closeSheet() { if (sheetEl && sheetEl.parentNode) sheetEl.parentNode.removeChild(sheetEl); sheetEl = null; }
  function helpSheet() {
    closeSheet(); closePop();
    var row = function (t) { return '<li><span class="pfv-popi">' + svg(t.g, 0) + '</span><span class="pfv-popt"><b>' + esc(t.n) + '</b>' + t.l.filter(function (x) { return x !== WHEN; }).map(function (x) { return '<span>' + esc(x) + '</span>'; }).join('') + (t.who ? '<i>' + esc(t.who) + '</i>' : '') + (t.chip ? '<em class="pfv-pchip">' + esc(t.chip) + '</em>' : '') + '</span></li>'; };
    var lim = V1.limit || 0;
    sheetEl = document.createElement('div');
    sheetEl.innerHTML = '<button type="button" class="pfv-sheetbg" data-x="1" aria-label="Close"></button><div class="pfv-sheet" role="dialog" aria-label="How the board works"><div class="pfv-sheet-in">'
      + '<div class="hrow"><h2>How the board works</h2><button type="button" class="btn small" data-x="1">Done</button></div>'
      + '<div class="sl">The round</div><ul class="helpl">' + row(ENV ? envTurnText() : turnText())
      + row({ n: 'The creature’s aim', g: 'aim', l: ['The red mark is where its next piece goes. Take the cell and it has to pick again.'], who: '' })
      + row({ n: 'Chains', g: 'gust', l: ['A piece you place fires, then every piece linked to it.' + (lim ? ' A chain of ' + lim + ' or more uses up every piece that fired.' : '') + ' Pal, tool and crop pieces in one chain: 2 kinds +30%, all 3 +60%.'], who: '' })
      + row({ n: 'Guard', g: 'gust', l: ['Your guard blocks the creature’s hits. It fades when your turn starts, unless Hold keeps it (what is left of a Hold guard stays up once).'], who: '' })
      + row({ n: 'Flip', g: 'gust', l: ['Once a turn, free: Flip swaps the top and bottom edges of the piece you picked. A faded piece cannot be played right now; tap it to see why.'], who: '' })
      + (ENV ? '</ul><div class="sl">Environment pieces <span>tap one in the Next strip</span></div><ul class="helpl">' + ['sun', 'bramble', 'rain', 'wind', 'mud', 'thorn'].map(function (k) { return row(envText(k, null)); }).join('') + '</ul>' : '')
      + (ENV ? '' : '</ul><div class="sl">Terrain <span>tap a ground cell</span></div><ul class="helpl">' + ['sun', 'br', 'mud'].map(function (k) { return row(terrText(k)); }).join('') + '</ul>'
      + '<div class="sl">Events <span>marked a round ahead</span></div><p class="hint">' + WHEN + '</p><ul class="helpl">' + ['sunbeam', 'creep', 'puddle', 'gust', 'thorn'].map(function (k) { return row(evText2(k)); }).join('') + '</ul>')
      + '<div class="sl">Animation speed</div><div class="spdrow">' + [['1', '1×'], ['2', '2×'], ['0', 'Skip']].map(function (o) { return '<button type="button" class="btn small' + (String(SPD) === o[0] ? ' primary' : ' ghost') + '" data-spd="' + o[0] + '">' + o[1] + '</button>'; }).join('') + '</div>'
      + '</div></div>';
    (root.closest('dialog') || document.body).appendChild(sheetEl);   // inside the Trail's popover when the fight is in one (a modal dialog covers the page)
    sheetEl.addEventListener('click', function (ev) {
      if (ev.target.closest('[data-x]')) { closeSheet(); return; }
      var sb = ev.target.closest('[data-spd]'); if (sb) { setSpd(+sb.dataset.spd); helpSheet(); }
    });
    var done = sheetEl.querySelector('.btn'); if (done) done.focus();
  }
  function setSpd(v) { SPD = v === 2 ? 2 : v === 0 ? 0 : 1; try { window.localStorage.setItem('pfvspd', String(SPD)); } catch (e) {} drawLegend(); if (!SPD && playing) stopPlay(true); }
  function onKey(ev) { if (ev.key === 'Escape') { if (sheetEl) closeSheet(); else closePop(); } }

  // ---- the replay: it starts from the ground, forecast and aim as they stood before the turn; each terrain event flashes its mark and what it hit; used-up pieces leave after their side's chain
  function replayStart() {
    if (insp) { insp.hidden = true; picked = null; Array.prototype.forEach.call(boardEl.querySelectorAll('.pfb-picked'), function (c) { c.classList.remove('pfb-picked'); }); }   // 2.6.77: the card never stays open into a replay
    if (PREV) phase = 'pre';
    terOver = {}; movedBack = {}; usedGone = {}; leavingUsed = {}; envDone = {}; flashEnv = null; flashIds = {}; aimHide = false; stepNow = 0; stepNote = '';
    stripRem = []; stripBad = false; slideIds = {}; fadeIds = {}; fxPop = null;
    if (ENV) { envPre(); drawLegend(); }
    (data.replay || []).forEach(function (ev) { if (ev.env === 'gust' && ev.moved && ev.moved.id !== undefined && typeof ev.x === 'number') movedBack[ev.moved.id] = { x: ev.x, y: ev.y }; });
  }
  var envPush = {};
  function envPre() {   // pieces the environment places this turn stay off the board until its turn plays; a piece Wind pushes starts where it stood
    var pushes = {};
    (data.replay || []).forEach(function (ev) {
      if (ev.env === 'place' && ev.id) hiddenIds[ev.id] = true;
      if (ev.env === 'fire' && ev.kind === 'wind' && ev.moved && ev.moved.id !== undefined && ev.dir && DXY[ev.dir]) { var d = DXY[ev.dir]; (pushes[ev.moved.id] = pushes[ev.moved.id] || []).push({ x: ev.moved.x - d[0], y: ev.moved.y - d[1] }); }
    });
    movedBack = {}; envPush = {};
    Object.keys(pushes).forEach(function (id) { movedBack[id] = pushes[id][0]; envPush[id] = pushes[id].slice(1); });
  }
  function replayDone() { if (ENV && PREV && phase === 'pre') { stripNew = true; stripBad = false; stripRem = []; setTimeout(function () { stripNew = false; drawLegend(); }, 900); }
    fxPop = null; fadeIds = {}; slideIds = {}; phase = 'now'; terOver = {}; movedBack = {}; usedGone = {}; leavingUsed = {}; envDone = {}; flashEnv = null; flashIds = {}; aimHide = false; stepNow = 0; stepNote = ''; }
  function envStepE(ev) {   // one step of the environment's own events: a piece fires in a chain, the environment places, finds no place, pieces fade
    var K = envKind(ev.kind);
    flashIds = {}; fxPop = null; slideIds = {}; fadeIds = {}; stripBad = false;
    if (ev.env === 'fire') {
      flashIds[ev.id] = 1;
      var t = ev.kind === 'sun' ? '\u00d7' + (V1.sun || 2) + ' for ' + (ev.for === 'me' ? 'you' : 'the creature')
        : ev.kind === 'bramble' ? (ev.for === 'me' ? 'creature \u2212' + Math.round(ev.foe || 0) : 'you \u2212' + (ev.me || 0))
        : ev.kind === 'rain' ? (ev.for === 'me' ? '+' + (ev.guard || ev.v || 0) + ' guard' : 'its guard')
        : ev.kind === 'thorn' ? (ev.for === 'me' ? 'you \u2212' + (ev.me || 0) : 'creature \u2212' + Math.round(ev.foe || 0))
        : ev.kind === 'wind' ? (ev.moved ? 'push' : 'no push') : '';
      fxPop = { id: ev.id, t: t, kind: ev.kind };
      if (ev.kind === 'wind' && ev.moved && ev.moved.id !== undefined) {
        var nxt = envPush[ev.moved.id] || []; if (nxt.length) movedBack[ev.moved.id] = nxt.shift(); else delete movedBack[ev.moved.id];
        flashIds[ev.moved.id] = 1; slideIds[ev.moved.id] = ev.dir || 'R';
      }
    } else if (ev.env === 'place') {
      var pi = (PREV && PREV.env ? PREV.env.next : []).findIndex(function (it, i) { return it.kind === ev.kind && stripRem.indexOf(i) < 0; }); if (pi >= 0) stripRem.push(pi);
      flashIds[ev.id] = 1; fxPop = { id: ev.id, t: K.n, kind: ev.kind };
    } else if (ev.env === 'pass') { stripBad = true; }
    else if (ev.env === 'expire') { (ev.ids || []).forEach(function (id) { fadeIds[id] = 1; }); }
    render(); drawLegend();
  }
  function envStep(ev) {
    if (ENV) { envStepE(ev); return; }
    var had = flashEnv !== null || Object.keys(flashIds).length > 0;
    flashEnv = null; flashIds = {};
    if (!ev.env) { if (had) render(); return; }
    var envs = (PREV && PREV.envs) || [], k, map = working().map;
    for (k = 0; k < envs.length; k++) if (!envDone[k] && envs[k].kind === ev.env && envs[k].x === ev.x && envs[k].y === ev.y) { flashEnv = k; break; }
    if (EVT[ev.env] && typeof ev.x === 'number') terOver[ev.x + ',' + ev.y] = EVT[ev.env];
    if (ev.env === 'gust' && ev.moved && ev.moved.id !== undefined) { delete movedBack[ev.moved.id]; flashIds[ev.moved.id] = 1; }
    if (ev.env === 'thorn' || ev.env === 'creep') Object.keys(map).forEach(function (key) { var p = map[key]; if (p.by !== 'none' && !p.gone && p.id !== undefined && Math.abs(p.x - ev.x) + Math.abs(p.y - ev.y) <= (ev.env === 'thorn' ? 1 : 0)) flashIds[p.id] = 1; });
    if (ev.env === 'bramble') { if (ev.ids && ev.ids.length) ev.ids.forEach(function (id) { flashIds[id] = 1; }); else Object.keys(map).forEach(function (key) { var p = map[key]; if (p.by !== 'none' && !p.gone && p.id !== undefined && terAt(p.x, p.y) === 'br') flashIds[p.id] = 1; }); }
    render();
    if (flashEnv !== null) { var done = flashEnv; playTimers.push(setTimeout(function () { envDone[done] = 1; }, 10)); }   // its mark stays for this step, then it is gone
  }
  function useUpStep(side, tt) {
    var ids = (data.gone || []).filter(function (g) { return g.used === side || (side === 'foe' && g.fell && !g.used && g.by === 'foe'); }).map(function (g) { return g.id; });
    if (!ids.length) return tt;
    playTimers.push(setTimeout(function () { ids.forEach(function (id) { leavingUsed[id] = 1; }); flashEnv = null; flashIds = {}; stepNote = side === 'me' ? 'A chain of ' + (V1.limit || 3) + ' or more: the pieces that fired are used up.' : 'Pieces that fired their last time, or in a chain of ' + (V1.limit || 3) + ', fall away.'; render(); }, tt));
    playTimers.push(setTimeout(function () { ids.forEach(function (id) { usedGone[id] = 1; delete leavingUsed[id]; }); render(); }, tt + 800 / SPD));
    return tt + 850 / SPD;
  }

  /** 2.6.78: the result card of a fight that is over waits (the server marks the fight pfv-endwait) until the last turn has been replayed in full, then it fades in. A skipped or absent replay shows it at once. */
  function endReveal() { if (!root.classList.contains('pfv-endwait')) return; root.classList.remove('pfv-endwait'); root.classList.add('pfv-endin'); }
  /** 2.6.79 (Josh: "reload still occurring on End turn"): nothing reloads (checked on an emulated phone, no navigation, no plain submit), but the turn is swapped in place and for a moment the board and hand are EMPTY until the new script has drawn them: it looks like a quick reload.
   So the old fight is snapshotted when a form is sent (canvases copied) and shown, frozen, over the new fight until the new board is drawn; then it goes. */
  function ghostSnap() {
    try {
      var r = root.getBoundingClientRect(), g = root.cloneNode(true), a = root.querySelectorAll('canvas'), b = g.querySelectorAll('canvas'), i;
      for (i = 0; i < a.length && i < b.length; i++) { try { b[i].getContext('2d').drawImage(a[i], 0, 0); } catch (e) {} }
      g.removeAttribute('id'); g.removeAttribute('data-turn'); Array.prototype.forEach.call(g.querySelectorAll('[id]'), function (x) { x.removeAttribute('id'); });
      Array.prototype.forEach.call(g.querySelectorAll('script, form, [hidden]'), function (x) { if (x.parentNode) x.parentNode.removeChild(x); });
      g.classList.add('pfv-ghost'); g.setAttribute('aria-hidden', 'true');
      var gh = window.__pfbGhost = { n: g, t: Date.now(), x: r.left, y: r.top, w: r.width, h: r.height, bg: '#2b1d14', shown: false };
      if (window.__pfbGhostObs) window.__pfbGhostObs.disconnect();
      var obs = window.__pfbGhostObs = new MutationObserver(function () {   // the moment the new fight is swapped in (before anything is painted), the frozen old one goes over it
        var n = document.getElementById('pfight'); if (!n || n === root || !n.parentNode || gh.shown) return;
        gh.shown = true; obs.disconnect(); g.style.left = gh.x + 'px'; g.style.top = gh.y + 'px'; g.style.width = gh.w + 'px'; g.style.height = gh.h + 'px'; g.style.backgroundColor = gh.bg; n.parentNode.insertBefore(g, n.nextSibling);
      });
      obs.observe(document.body, { childList: true, subtree: true }); setTimeout(function () { obs.disconnect(); }, 15000);
    } catch (e) { window.__pfbGhost = null; }
  }
  function ghostShow() {   // the new script has started: take the ghost away when the new board is drawn
    var gh = window.__pfbGhost; window.__pfbGhost = null;
    if (!gh || !gh.shown || Date.now() - gh.t > 15000) return;
    var g = gh.n, t0 = Date.now(), tm = setInterval(function () {
      var drawn = boardEl.children.length > 0 && !!boardEl.querySelector('canvas, .pfb-cell') && document.querySelectorAll('#pf-hand .pf-tile').length > 0;
      if ((drawn && Date.now() - t0 > 120) || Date.now() - t0 > 2500) { clearInterval(tm); if (g.parentNode) g.parentNode.removeChild(g); }
    }, 40);
  }
  function v1Boot() {
    root.addEventListener('submit', ghostSnap, true);
    ghostShow();
    if (data.bar !== undefined && data.barmax) setBar(data.replay0 && data.replay0.bar !== undefined ? data.replay0.bar : data.bar, data.barmax);   // 2.6.80: the N/100 number is there from the first frame
    if (willReplay && data.replay0) { setFh(data.replay0.fh || 0, data.fhmax); setHp(data.replay0.hp); setGuard(data.replay0.g); }   // 2.6.88: the page is sent with the NEW health, guard and creature health in it; until the replay reaches the piece that changes them they show what they were before the turn
    if (!willReplay || !SPD || !(data.replay && data.replay.length)) endReveal();
    else setTimeout(endReveal, 40000);   // never hold the card for ever (a replay that never ran)
    drawLegend();
    if (rowEl) rowEl.addEventListener('click', function (ev) { var b = ev.target.closest('[data-ev]'); if (!b) return; var e = dispEnvs()[+b.dataset.ev]; if (e) showPop({ t: 'ev', k: e.kind, rot: e.kind === 'gust' ? ROT[e.dir] : 0, y: e.y }); });
    if (legendEl) legendEl.addEventListener('click', function (ev) {
      var b = ev.target.closest('button'); if (!b) return;
      if (b.dataset.en !== undefined) { var it = stripItems()[+b.dataset.en]; if (it) showPop({ t: 'envp', k: it.kind, life: it.life, y: null }); }
      else if (b.dataset.ter) showPop({ t: 'ter', k: b.dataset.ter, y: null });
      else if (b.dataset.a === 'turn') showPop({ t: 'turn', k: 'turn', y: null });
      else if (b.dataset.a === 'help') helpSheet();
      else if (b.dataset.a === 'spd') setSpd(SPD === 1 ? 2 : SPD === 2 ? 0 : 1);
    });
    if (flipBtn) flipBtn.addEventListener('click', doFlip);
    wrapEl = document.createElement('div'); wrapEl.className = 'pfv-bwrap'; boardEl.parentNode.insertBefore(wrapEl, boardEl); wrapEl.appendChild(boardEl);   // the board takes the room that is left: the fight fits the window
    if (window.pfvFrame) window.pfvFrame();
    window.addEventListener('resize', refit);
    if (typeof ResizeObserver === 'function') { wrapObs = new ResizeObserver(function () { fitBoard(); }); wrapObs.observe(wrapEl); }
    document.addEventListener('keydown', onKey);
    if (insp) wrapEl.appendChild(insp);   // 2.6.76: the piece card is an overlay on the top of the board room when there is no room to dock it
    var ge0 = root.querySelector('.pf-guard'); if (ge0) { ge0.title = 'Guard: blocks the creature\u2019s hits. Your guard fades when your turn starts, unless Hold keeps it.'; ge0.setAttribute('aria-label', ge0.title); }   // 2.6.77
    dockEl = document.createElement('div'); dockEl.className = 'pfv-dock'; dockEl.id = 'pfv-dock'; if (legendEl && legendEl.parentNode) legendEl.parentNode.insertBefore(dockEl, legendEl.nextSibling);   // 2.6.77: docked card (in the flow) between the board and the hand
    if (histEl && typeof MutationObserver === 'function') { dockMo = new MutationObserver(function () { if (dockOn) dockFill(); }); dockMo.observe(histEl, { childList: true, subtree: true, attributes: true, attributeFilter: ['hidden'] }); }
    document.addEventListener('pointerdown', inspOut, true);
    if (window.pfvSizes) window.pfvSizes();
  }
  /** 2.6.76: the piece card shows the same chips, life and tag words as the Puzzle box's detail sheet (PFSheet, assets/pfv1box.js): one line under the text, the card stays slim. */
  function inspExtra(i) {
    var d = data.hand && data.hand[i], t = document.getElementById('pfi-desc'); if (!t || !d || !window.PFSheet) return;
    var old = insp.querySelector('.pfi-ch'); if (old) old.parentNode.removeChild(old);
    var TY = { hurt: 'Hurt', guard: 'Guard', heal: 'Heal', charm: 'Charm', soothe: 'Soothe', trick: 'Trick', item: 'Item' }, RN = ['', 'Common', 'Uncommon', 'Rare', 'Masterwork'];
    var pv = d.v !== undefined ? d.v : +(tiles[i] && tiles[i].dataset.v) || 0, pc = { t: d.t, ty: TY[d.t] || d.t, v: pv, rn: d.rank ? RN[d.rank] : '', rk: d.rank || 0, src: d.src && d.src !== 'knack' ? d.src : '', life: 0 };
    var el = document.createElement('div'); el.className = 'pfi-ch'; el.innerHTML = window.PFSheet.chips(pc) + (d.life ? ' <span class="ch">stays ' + d.life + '</span>' : ''); insp.querySelector('.pf-itext').appendChild(el);
  }
  function inspOut(ev) {   // a tap outside the piece card closes it
    if (!insp || insp.hidden || insp.contains(ev.target)) return;
    insp.hidden = true; picked = null; Array.prototype.forEach.call(boardEl.querySelectorAll('.pfb-picked'), function (c) { c.classList.remove('pfb-picked'); });
  }
  function v1Off() { closeSheet(); closePop(); document.removeEventListener('pointerdown', inspOut, true); document.removeEventListener('keydown', onKey); window.removeEventListener('resize', refit); if (wrapObs) wrapObs.disconnect(); if (dockMo) dockMo.disconnect(); }

  /** 2.6.77: the board keeps the art's own proportion at every size (a cell is the piece's body, 56 x 40, never stretched; the pieces scale with it). It is as large as the width and its share of the height allow. A tall phone has height to spare: it goes to the hand (larger pieces, uniformly scaled), a docked card under the board (the picked piece, or the last plays and what comes next), 44px+ buttons, bigger gaps between the rows; what is left is split above and under the whole block. Nothing here changes a piece's proportion. */
  var fitBusy = false, dockEl = null, dockOn = false, dockMo = null;
  var HAND_W = function () { return window.innerWidth <= 560 ? 74 : 112; };
  function fitVars(v) { var st = root.style; ['--pfv-gap', '--pfv-btn', '--pfv-hw', '--pfv-hh', '--pfv-dock', '--pfv-leg'].forEach(function (k) { if (v && v[k] !== undefined) st.setProperty(k, v[k]); else st.removeProperty(k); }); }
  function setDock(on) {
    if (on === dockOn || !dockEl) return; dockOn = on; root.classList.toggle('pfv-dockon', on);
    if (insp) { if (on) dockEl.insertBefore(insp, dockEl.firstChild); else if (wrapEl) wrapEl.appendChild(insp); }   // the card docks under the board (in the flow) or, with no room to spare, lies over the board room
  }
  function fitBoard() {
    if (fitBusy || !wrapEl || !fitTW || !root.classList.contains('pfv-fit')) return;
    fitBusy = true;
    try {
      var ar = fitTW / fitTH, base = {}, r, w, h, rem, hw0 = HAND_W(), hh0 = Math.round(hw0 * 52 / 74), n = tiles.length || 5, d0 = 46, rows = (data.h || 5);
      fitVars({ '--pfv-btn': '44px', '--pfv-dock': d0 + 'px' }); wrapEl.style.flex = ''; wrapEl.style.height = ''; setDock(true);   // the card is docked always, never over the board
      r = wrapEl.getBoundingClientRect(); if (r.height < 30 || r.width < 30) return;
      w = Math.floor(Math.min(r.width, r.height * ar, fitTW * 1.7)); h = Math.round(w / ar);
      if (h < 27 * rows) { d0 = 34; fitVars({ '--pfv-btn': '44px', '--pfv-dock': d0 + 'px' }); r = wrapEl.getBoundingClientRect(); w = Math.floor(Math.min(r.width, r.height * ar, fitTW * 1.7)); h = Math.round(w / ar); }   // a small screen: the card is one line high so the cells stay readable
      boardEl.style.maxWidth = 'none'; boardEl.style.aspectRatio = fitTW + ' / ' + fitTH; boardEl.style.width = w + 'px'; boardEl.style.height = h + 'px';
      rem = Math.floor(r.height - h) - 4;
      if (rem >= 10) {
        var v = { '--pfv-btn': '44px', '--pfv-dock': d0 + 'px' }, dock = d0, hs = 1, gaps = Math.max(1, root.children.length - 1);
        if (rem >= 8) { v['--pfv-btn'] = '48px'; rem -= 4; }
        var avail = handEl.clientWidth, hsW = Math.min(1.5, avail / (hw0 * (n - 0.12 * (n - 1)))), hcost = function (x) { return Math.round(hh0 * (x - 1)); };
        hsW = Math.max(1, Math.floor(hsW * 20) / 20);
        if (rem >= 12 + 20) { dock = 66; rem -= 20; }
        hs = hsW; if (hcost(hs) > rem - (dock ? 0 : 0)) hs = Math.max(1, Math.floor((1 + Math.max(0, rem) / hh0) * 20) / 20);
        rem -= hcost(hs);
        { var more = Math.min(54, rem); dock += more; rem -= more; }
        if (rem >= 8) { v['--pfv-leg'] = '34px'; rem -= 8; }
        var gx = Math.max(0, Math.min(18, Math.floor(rem / gaps))); rem -= gx * gaps;
        v['--pfv-gap'] = (3 + gx) + 'px'; v['--pfv-hw'] = Math.round(hw0 * hs) + 'px'; v['--pfv-hh'] = Math.round(hh0 * hs) + 'px';
        v['--pfv-dock'] = dock + 'px';
        fitVars(v);
        if (rem > 6) { wrapEl.style.flex = '0 1 auto'; wrapEl.style.height = h + 'px'; }   // what is left: the whole block is centred, one band over it and one under it (the rows give way first if something grows)
        // the card, the hand and the buttons must not push the board out of its room: if they did, take the extras back step by step
        var tries = 0; while (tries++ < 4 && wrapEl.getBoundingClientRect().height < h - 1 && (v['--pfv-hw'] !== hw0 + 'px' || v['--pfv-dock'] !== d0 + 'px')) {
          if (v['--pfv-dock'] !== d0 + 'px') v['--pfv-dock'] = d0 + 'px'; else { delete v['--pfv-hw']; delete v['--pfv-hh']; }
          fitVars(v);
        }
        if (wrapEl.getBoundingClientRect().height < h - 1) { fitVars({ '--pfv-btn': '44px', '--pfv-dock': d0 + 'px' }); wrapEl.style.flex = ''; wrapEl.style.height = ''; var r2 = wrapEl.getBoundingClientRect(); w = Math.floor(Math.min(r2.width, r2.height * ar, fitTW * 1.7)); h = Math.round(w / ar); boardEl.style.width = w + 'px'; boardEl.style.height = h + 'px'; }
      }
      if (dockOn) { root.classList.toggle('pfv-docks', dockEl.clientHeight < 70); if (insp && !insp.hidden && selected === null && picked === null) insp.hidden = true; dockEl.style.setProperty('--pfv-dockh', dockEl.clientHeight + 'px'); dockFill(); }
    } finally { fitBusy = false; }
    fan();
  }
  /** the dock when no piece is picked: the last plays and what comes next (the strip's two environment pieces are on the row above) */
  function dockFill() {
    if (!dockEl) return;
    var idle = dockEl.querySelector('.pfv-dockidle'); if (!idle) { idle = document.createElement('div'); idle.className = 'pfv-dockidle'; dockEl.appendChild(idle); }
    var lines = [], chips = histEl ? Array.prototype.slice.call(histEl.querySelectorAll('.pf-chip:not([hidden])')) : [];
    chips.slice(0, 4).forEach(function (c) { var t = (c.getAttribute('aria-label') || c.textContent || '').replace(/\. Press to see the board then\.?$/, '').replace(/\s+/g, ' ').trim(); if (t) lines.push(t); });
    var nx = ''; if (ENV) { var it = stripItems(); nx = it.length ? 'Next in the environment: ' + it.map(function (x) { return envKind(x.kind).n; }).join(', ') + '.' : 'Next: the environment has nothing more to place.'; }
    if (playing) { var bn = turnEl && !turnEl.hidden ? turnEl.textContent : ''; lines = [(bn ? bn + ': ' : '') + (stepNote || 'playing…')]; nx = ''; }
    var key = (playing ? 'P' : '') + lines.join('|') + '#' + nx; if (idle.dataset.k === key) return; idle.dataset.k = key;
    idle.innerHTML = '<b class="dl">' + (playing ? 'Now' : 'Last plays') + '</b><ul>' + (lines.length ? lines.map(function (t) { return '<li>' + esc(t) + '</li>'; }).join('') : '<li>Nothing played yet.</li>') + '</ul>' + (nx ? '<p class="dn">' + esc(nx) + '</p>' : '');
  }
  function refit() { if (window.pfvFrame) window.pfvFrame(); fitBoard(); fan(); }

  /** FLIP (2.6.75: no page load): the server flips the picked piece and answers with the hand; the piece turns over where it is, its lit spots and their numbers are worked out again. */
  function flipLabel() {
    if (!flipBtn) return;
    var used = !!(data.flip && data.flip.used), can = typeof selected === 'number' && data.hand[selected] && data.hand[selected].canflip;
    var why = used && !can ? 'You have flipped a piece this turn. Flip that piece back to get the flip again.' : typeof selected !== 'number' ? 'Pick a piece from your hand first.' : !can ? 'This piece cannot be flipped.' : 'Flip: swap the top and bottom edges of the piece you picked (once a turn, free)';
    flipBtn.textContent = used && !can ? '\u21C5 Flip used' : '\u21C5 Flip'; flipBtn.title = why; flipBtn.setAttribute('aria-label', why);
  }
  function redrawTile(i) {   // the hand piece is drawn again with its edges as they are now
    var t = tiles[i]; if (!t) return;
    Array.prototype.forEach.call(t.querySelectorAll('.pfh-cv, .pfb-mod, .pfe'), function (x) { x.parentNode.removeChild(x); });
    delete t.dataset.arted;
    if (!(window.PFParts && window.PFParts.ok)) ['B', 'T', 'R', 'L'].forEach(function (sd) { t.insertBefore(edgeSpan(data.hand[i].e[sd], sd), t.firstChild); });
  }
  function doFlip() {
    var i = selected;
    if (typeof i !== 'number' || playing || submitted || flipBusy || !data.hand[i] || !data.hand[i].canflip) return;
    flipBusy = true; flipBtn.disabled = true;
    var fd = new FormData(), qs = function (n) { var e = form.querySelector('[name=' + n + ']'); return e ? e.value : ''; };
    fd.append('csrf', qs('csrf')); fd.append('do', 'pfb_flip'); fd.append('nonce', qs('nonce')); fd.append('turn', qs('turn')); fd.append('hand', String(i));
    fetch(location.pathname, { method: 'POST', body: fd, credentials: 'same-origin', headers: { 'X-Requested-With': 'pfflip' } })
      .then(function (r) { return r.json(); })
      .then(function (j) {
        flipBusy = false;
        if (!j || !j.ok) { offMsg = (j && j.err) || 'The piece could not be flipped.'; render(); return; }
        (j.hand || []).forEach(function (h, k) { if (data.hand[k]) { data.hand[k].e = h.e; data.hand[k].flip = h.flip; data.hand[k].canflip = h.canflip; } });
        data.flip = j.flip || data.flip;
        redrawTile(i); nums.key = null; nums.d = null; planQ = null; offMsg = ''; moves = []; closePop();
        tiles[i].classList.add('pfv-flipping'); render();
        setTimeout(function () { if (tiles[i]) tiles[i].classList.remove('pfv-flipping'); }, 450);
      })
      .catch(function () {   // no answer (offline, an old server): the plain form post, which reloads the page
        flipBusy = false; var ff = document.getElementById('pf-fform'), fh = document.getElementById('pf-fhand');
        if (ff && fh) { submitted = true; fh.value = String(i); if (typeof ff.requestSubmit === 'function') ff.requestSubmit(); else ff.submit(); }
      });
  }
  if (ENV && willReplay) { envPre(); if (PREV) phase = 'pre'; }
