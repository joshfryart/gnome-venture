  // ================= v1 (2.6.74 stage C): state, texts and drawing helpers. Ported from the approved demo (tools/pfdemo_v1/app.js); the texts mirror claude/design-board-strategy.md, "Player-facing terrain text".
  var V1 = data.v1 || {}, PREV = data.prev || null, phase = 'now', terOver = {}, movedBack = {}, usedGone = {}, leavingUsed = {}, flashEnv = null, flashIds = {}, aimHide = false, stepNow = 0, stepNote = '';
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
    aim: '<circle cx="8" cy="8" r="5.2" stroke="currentColor" stroke-width="1.8" fill="none"/><circle cx="8" cy="8" r="1.6" fill="currentColor"/><path d="M8 0v3.4M8 12.6V16M0 8h3.4M12.6 8H16" stroke="currentColor" stroke-width="1.8"/>'
  };
  function esc(x) { return String(x).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }
  function svg(k, rot) { return '<svg viewBox="0 0 16 16" aria-hidden="true"' + (rot ? ' class="pfv-r' + rot + '"' : '') + '>' + SVG[k] + '</svg>'; }
  function svgEl(k, rot) { var h = document.createElement('span'); h.innerHTML = svg(k, 0); var el = h.firstChild; if (rot) el.style.transform = 'rotate(' + rot + 'deg)'; return el; }
  function pc100(x) { return Math.round(x * 100) + '%'; }
  function times(x) { return x === 2 ? 'double' : x === 3 ? 'triple' : x === 1 ? 'as normal' : '×' + x; }
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
    h += '<span class="tg step on" title="Every round goes: you, the creature, then the terrain">R' + (data.round || 1) + ' \u00B7 ' + (data.won ? 'over' : stepNow === 1 ? '<span class="fn">' + esc(foe) + '</span>' : stepNow === 2 ? 'Terrain' : 'You') + '</span>';
    for (i = 1; i <= Math.max(lim, 3); i++) dots += '<i class="' + (n >= i ? (lim > 0 && n >= lim ? 'over' : 'on') : '') + '"></i>';
    h += '<span class="tg" role="img" aria-label="Pieces that fire in your chain: ' + n + '. ' + (lim > 0 ? lim + ' or more: every piece that fired is used up.' : '') + '" title="' + (lim > 0 ? 'A chain of ' + lim + ' or more uses up every piece that fired.' : 'Chain') + '">chain <span class="dots">' + dots + '</span></span>';
    h += '<span class="tg team' + (tw > 1 ? ' on' : '') + '" title="Pal, tool and crop pieces in one chain: 2 kinds +30%, all 3 +60%">' + (tw > 1 ? 'Teamwork +' + Math.round((tw - 1) * 100) + '%' : 'Teamwork') + '</span>';
    if (!data.won) {
      var aim = dispAim();
      if (!data.start) h += st.foe_slow && phase !== 'pre' ? '<span class="tg good">' + esc(foe) + ' is slowed: no move</span>' : aim ? '<span class="tg aim">' + svg('aim') + 'Aims ' + esc(aim.n) + ' ' + esc(aim.t) + ' ' + aim.v + (data.reaim && phase !== 'pre' ? ' (picked again)' : '') + '</span>' : '<span class="tg aim">no aim</span>';
      dispEnvs().forEach(function (e, k) { if (phase === 'pre' && envDone[k]) return; h += '<button type="button" class="tg ev" data-ev="' + k + '">' + svg(EVG[e.kind]) + (e.kind === 'gust' && e.on ? 'Gust: pushes ' + esc(e.on.n) : EVN[e.kind]) + '</button>'; });
      if (st.poison) h += '<span class="tg bad">poisoned ' + st.poison + '</span>';
      if (st.slowdraw) h += '<span class="tg bad">tripped: draw −1</span>';
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
  function drawLegend() {
    if (!legendEl) return;
    legendEl.innerHTML = [['sun', '\u00d7' + V1.sun, 'Sunny: counts ' + times(V1.sun)], ['br', '\u2212' + pc100(V1.bramble || 0), 'Bramble: \u2212' + pc100(V1.bramble || 0) + ' a round'], ['mud', 'no links', 'Mud: no links']].map(function (q) { return '<button type="button" class="tg lg-' + q[0] + '" data-ter="' + q[0] + '" aria-label="' + q[2] + '. Press for more" title="' + q[2] + '">' + svg(q[0]) + q[1] + '</button>'; }).join('')
      + '<button type="button" class="tg" data-a="turn" aria-label="Terrain turn: what happens in a round">Turn</button><button type="button" class="tg qm" data-a="help" aria-label="Help: how the board works">?</button>'
      + '<button type="button" class="tg spd" data-a="spd" aria-label="Animation speed: ' + (SPD === 2 ? 'double' : SPD === 0 ? 'skip' : 'normal') + '. Press to change">' + spdLabel() + '</button>';
  }

  // ---- popover over the board (a ground cell, a forecast mark, a legend chip) and the help sheet
  function closePop() { if (popEl && popEl.parentNode) popEl.parentNode.removeChild(popEl); popEl = null; }
  function popHtml(pt, rot) { return '<span class="pfv-popi">' + svg(pt.g, 0) + '</span><span class="pfv-popt"><b>' + esc(pt.n) + '</b>' + pt.l.map(function (x) { return '<span>' + esc(x) + '</span>'; }).join('') + '<i>' + esc(pt.who) + '</i></span>'; }
  function showPop(o) {
    var same = popEl && popEl.dataset.k === o.t + ':' + o.k; closePop(); if (same) return;
    var pt = o.t === 'ter' ? terrText(o.k) : o.t === 'turn' ? turnText() : evText2(o.k); if (!pt) return;
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
    var row = function (t) { return '<li><span class="pfv-popi">' + svg(t.g, 0) + '</span><span class="pfv-popt"><b>' + esc(t.n) + '</b>' + t.l.filter(function (x) { return x !== WHEN; }).map(function (x) { return '<span>' + esc(x) + '</span>'; }).join('') + (t.who ? '<i>' + esc(t.who) + '</i>' : '') + '</span></li>'; };
    var lim = V1.limit || 0;
    sheetEl = document.createElement('div');
    sheetEl.innerHTML = '<button type="button" class="pfv-sheetbg" data-x="1" aria-label="Close"></button><div class="pfv-sheet" role="dialog" aria-label="How the board works"><div class="pfv-sheet-in">'
      + '<div class="hrow"><h2>How the board works</h2><button type="button" class="btn small" data-x="1">Done</button></div>'
      + '<div class="sl">The round</div><ul class="helpl">' + row(turnText())
      + row({ n: 'The creature’s aim', g: 'aim', l: ['The red mark is where its next piece goes. Take the cell and it has to pick again.'], who: '' })
      + row({ n: 'Chains', g: 'gust', l: ['A piece you place fires, then every piece linked to it.' + (lim ? ' A chain of ' + lim + ' or more uses up every piece that fired.' : '') + ' Pal, tool and crop pieces in one chain: 2 kinds +30%, all 3 +60%.'], who: '' })
      + row({ n: 'Flip', g: 'gust', l: ['Once a turn, free: Flip swaps the top and bottom edges of the piece you picked. A faded piece cannot be played right now; tap it to see why.'], who: '' })
      + '</ul><div class="sl">Terrain <span>tap a ground cell</span></div><ul class="helpl">' + ['sun', 'br', 'mud'].map(function (k) { return row(terrText(k)); }).join('') + '</ul>'
      + '<div class="sl">Events <span>marked a round ahead</span></div><p class="hint">' + WHEN + '</p><ul class="helpl">' + ['sunbeam', 'creep', 'puddle', 'gust', 'thorn'].map(function (k) { return row(evText2(k)); }).join('') + '</ul>'
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
    if (PREV) phase = 'pre';
    terOver = {}; movedBack = {}; usedGone = {}; leavingUsed = {}; envDone = {}; flashEnv = null; flashIds = {}; aimHide = false; stepNow = 0; stepNote = '';
    (data.replay || []).forEach(function (ev) { if (ev.env === 'gust' && ev.moved && ev.moved.id !== undefined && typeof ev.x === 'number') movedBack[ev.moved.id] = { x: ev.x, y: ev.y }; });
  }
  function replayDone() { phase = 'now'; terOver = {}; movedBack = {}; usedGone = {}; leavingUsed = {}; envDone = {}; flashEnv = null; flashIds = {}; aimHide = false; stepNow = 0; stepNote = ''; }
  function envStep(ev) {
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

  function v1Boot() {
    drawLegend();
    if (rowEl) rowEl.addEventListener('click', function (ev) { var b = ev.target.closest('[data-ev]'); if (!b) return; var e = dispEnvs()[+b.dataset.ev]; if (e) showPop({ t: 'ev', k: e.kind, rot: e.kind === 'gust' ? ROT[e.dir] : 0, y: e.y }); });
    if (legendEl) legendEl.addEventListener('click', function (ev) {
      var b = ev.target.closest('button'); if (!b) return;
      if (b.dataset.ter) showPop({ t: 'ter', k: b.dataset.ter, y: null });
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
    if (window.pfvSizes) window.pfvSizes();
  }
  function v1Off() { closeSheet(); closePop(); document.removeEventListener('keydown', onKey); window.removeEventListener('resize', refit); if (wrapObs) wrapObs.disconnect(); }

  /** The board is as big as the room between the rows above and under it allows (its cells scale); never wider than the fight. */
  function fitBoard() {
    if (!wrapEl || !fitTW || !root.classList.contains('pfv-fit')) return;
    var r = wrapEl.getBoundingClientRect(); if (r.height < 30 || r.width < 30) return;
    var ar = fitTW / fitTH, w = Math.floor(Math.min(r.width, r.height * ar, fitTW * 1.7));
    boardEl.style.maxWidth = 'none'; boardEl.style.aspectRatio = 'auto'; boardEl.style.width = w + 'px'; boardEl.style.height = Math.floor(w / ar) + 'px';
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
