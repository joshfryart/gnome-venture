/* v1 design demo: the screens. Starter pick -> Puzzle box -> creature and pre-fight -> the fight (v1 board rules) -> result -> box.
   State lives in one save object (localStorage, try/catch); the fight itself is the patched engine's plain state object. */
(function () {
  'use strict';
  var PFE = window.PFE, PFD = window.PFD, ART = window.__ART, EMO = window.__EMO, TAGS = window.__TAGS, PP = null;
  var KEY = 'pfdemo_v1', root = document.documentElement, main = document.getElementById('main'), nav = document.getElementById('nav'), sheet = document.getElementById('sheet');
  var TYPE = { hurt: 'Hurt', guard: 'Guard', heal: 'Heal', charm: 'Charm', soothe: 'Soothe', trick: 'Trick', item: 'Item' };
  var SRCN = { basic: 'basic', knack: 'knack', calling: 'calling', crop: 'crop', craft: 'craft', region: 'region', tool: 'tool', pal: 'pal' };
  var SRCI = { tool: '🔧', pal: '🐾', crop: '🌾' };
  var FOETAG = { quick: 'Quick: it plays one more piece this turn', evade: 'Evade: your next hit on it misses', bash: 'Bash: adds its guard to its next hit', poison: 'Poison: 2 ticks on your health',
    trip: 'Trip: you draw 1 fewer next round', heal: 'Recovers a little', thorns: 'Thorns: hitting its guard pricks you', hold: 'Hold: this guard lasts a turn longer', pierce: 'Pierce: ignores your guard' };
  var EVN = { sunbeam: 'Sunbeam', creep: 'Bramble creep', puddle: 'Puddle', gust: 'Gust', thorn: 'Thorn burst' };
  var EVT = { sunbeam: 'this cell turns sunny (Hurt and Charm play double); the oldest sunny cell fades', creep: 'this cell turns to bramble and pricks at once; the oldest bramble withers',
    puddle: 'this cell turns to mud (no links in or out); the old mud dries', gust: 'the piece here is pushed one cell along the arrow', thorn: 'every piece on this cell and its 4 neighbours costs its owner health' };
  var GRN = { sun: 'Sunny', br: 'Bramble', mud: 'Mud' }, EVW = { sunbeam: 'sunny', creep: 'bramble', puddle: 'mud', gust: 'push', thorn: 'burst' };
  var TUNE0 = { foe_x: 1, bar_x: 1, ev_unit: 0.10, bramble: 0.10, sun: 2, limit: 3, br_half: false, nev: 'auto', big: false, lvl: 0, anim: '1' };

  // ------------------------------------------------------------------ small helpers
  function safe(f) { try { return f(); } catch (e) { return null; } }
  function esc(x) { return String(x).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }
  var EK = Object.keys(EMO).sort(function (a, b) { return b.length - a.length; });
  var ERE = EK.length ? new RegExp(EK.map(function (k) { return k.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); }).join('|'), 'g') : null;
  /** Emoji become the game's drawn icons (as the game does on every page). */
  function ico(s) { return ERE ? String(s).replace(/️/g, '').replace(ERE, function (m) { return '<img class="ico" src="' + EMO[m] + '" alt="">'; }) : s; }
  function pct(n) { return (Math.round(n * 1000) / 10) + '%'; }
  var SVG = {
    sun: '<circle cx="8" cy="8" r="3.2" fill="currentColor"/><path d="M8 1v2.4M8 12.6V15M1 8h2.4M12.6 8H15M3 3l1.7 1.7M11.3 11.3L13 13M13 3l-1.7 1.7M4.7 11.3L3 13" stroke="currentColor" stroke-width="1.6" fill="none"/>',
    br: '<path d="M2 13C5 11 6 6 9 5s4-2 5-3" stroke="currentColor" stroke-width="1.8" fill="none"/><path d="M5 10l-3-2M7 7L5 3M10 5l3 3M12 3l-1-2" stroke="currentColor" stroke-width="1.6" fill="none"/>',
    mud: '<path d="M1 5c2-2 3 2 5 0s3 2 5 0 3 1 4 0M1 9c2-2 3 2 5 0s3 2 5 0 3 1 4 0M1 13c2-2 3 2 5 0s3 2 5 0 3 1 4 0" stroke="currentColor" stroke-width="1.6" fill="none"/>',
    gust: '<path d="M2 8h10M8 3.5L12.5 8 8 12.5" stroke="currentColor" stroke-width="2.2" fill="none"/>',
    thorn: '<path d="M8 0l1.8 5L15 3l-3 4.6L16 9l-4.6 1L13 15l-4.2-3L8 16l-1-4-4 3 1.6-5L0 9l4-1.4L1 3l5.2 2z" fill="currentColor"/>',
    aim: '<circle cx="8" cy="8" r="5.2" stroke="currentColor" stroke-width="1.8" fill="none"/><circle cx="8" cy="8" r="1.6" fill="currentColor"/><path d="M8 0v3.4M8 12.6V16M0 8h3.4M12.6 8H16" stroke="currentColor" stroke-width="1.8"/>'
  };
  // ---- player-facing terrain text (mirrored in claude/design-board-strategy.md "Player-facing terrain text"). Numbers are read from the fight's own values.
  function pc100(x) { return Math.round(x * 100) + '%'; }
  function times(x) { return x === 2 ? 'double' : x === 3 ? 'triple' : x === 1 ? 'as normal' : '×' + x; }
  function v1now() { if (F) return F.s.v1; var t = engineTune(); return { sun: t.sun, bramble: t.bramble, br_foe: t.br_foe, ev_unit: t.ev_unit, ev_foe: 0.5, limit: t.limit }; }
  var WHEN = 'Lands at the end of this round, after the creature\'s move.';
  function terrText(k) {
    var c = v1now(), foeBr = c.br_foe !== 1 ? ' The creature\'s pieces cost it ' + pc100(c.bramble * c.br_foe) + '.' : '';
    return { sun: { n: 'Sunny patch', g: 'sun', l: ['A Hurt or Charm piece standing here counts ' + times(c.sun) + '.'], who: 'Works for you and the creature.' },
      br: { n: 'Bramble', g: 'br', l: ['At the end of every round, a piece standing here costs its owner ' + pc100(c.bramble) + ' of their health.' + foeBr], who: 'Pricks you and the creature.' },
      mud: { n: 'Mud', g: 'mud', l: ['A piece here does not link. No chain runs into it or out of it.'], who: 'Stops your chains and the creature\'s.' } }[k];
  }
  function evText2(k) {
    var c = v1now(), foeEv = ' The creature\'s pieces cost it ' + pc100(c.ev_unit * c.ev_foe) + '.';
    return { sunbeam: { n: 'Sunbeam', g: 'sun', w: 'turns sunny', l: ['This cell turns sunny. The oldest sunny patch fades.', WHEN], who: 'Good for whoever stands here.' },
      creep: { n: 'Bramble creep', g: 'br', w: 'turns to bramble', l: ['This cell turns to bramble and pricks at once (' + pc100(c.bramble) + ' of health). The oldest bramble withers.', WHEN], who: 'Hurts whoever stands here.' },
      puddle: { n: 'Puddle', g: 'mud', w: 'turns to mud', l: ['This cell turns to mud, so links here are cut. The old mud dries up.', WHEN], who: 'Cuts chains for both sides.' },
      gust: { n: 'Gust', g: 'gust', w: 'pushes a piece', l: ['The piece here is pushed one cell along the arrow, if that cell is free.', WHEN], who: 'Moves your piece or the creature\'s.' },
      thorn: { n: 'Thorn burst', g: 'thorn', w: 'hurts around it', l: ['Every piece on this cell and the 4 cells next to it costs its owner ' + pc100(c.ev_unit) + ' of their health.' + foeEv, WHEN], who: 'Hits both sides.' } }[k];
  }
  function turnText() { var c = v1now(); return { n: 'Terrain turn', g: 'thorn', l: ['Every round goes: you, the creature, then the terrain.', 'On the terrain turn the marked events land in order, then bramble pricks, then old pieces expire. The next events are marked before you move.'], who: 'Same rules for you and the creature.' }; }
  var ROT = { R: 0, B: 90, L: 180, T: 270 };
  function svg(k, rot) { return '<svg viewBox="0 0 16 16" aria-hidden="true"' + (rot ? ' style="transform:rotate(' + rot + 'deg)"' : '') + '>' + SVG[k] + '</svg>'; }
  var EVG = { sunbeam: 'sun', creep: 'br', puddle: 'mud', gust: 'gust', thorn: 'thorn' };

  // ------------------------------------------------------------------ save
  function loadSave() {
    var d = PFD.freshSave(), raw = safe(function () { return JSON.parse(localStorage.getItem(KEY)); });
    if (!raw || typeof raw !== 'object' || raw.ver !== d.ver) return d;
    var ids = function (a, list, max) { var o = []; (Array.isArray(a) ? a : []).forEach(function (id) { if (PFD.byId(list, id) && o.indexOf(id) < 0) o.push(id); }); return max ? o.slice(0, max) : o; };
    d.started = !!raw.started; d.kit = ids(raw.kit, PFD.PIECES); d.beltTier = Math.max(0, Math.min(2, raw.beltTier | 0));
    d.belt = ids(raw.belt, PFD.TOOLS, PFD.BELT_SLOTS[d.beltTier]); d.party = ids(raw.party, PFD.PALS, 2);
    PFD.TOOLS.forEach(function (t) { var v = raw.dur && raw.dur[t.id]; if (typeof v === 'number' && isFinite(v)) d.dur[t.id] = Math.max(0, Math.min(PFD.toolMax(t), v)); });
    d.belt = d.belt.filter(function (id) { return d.dur[id] > 0; });
    d.auto = !!raw.auto; d.fights = raw.fights | 0; if (PFD.byId2(raw.cr)) d.cr = raw.cr;
    if (raw.tune && typeof raw.tune === 'object') for (var k in TUNE0) if (typeof raw.tune[k] === typeof TUNE0[k]) d.tune[k] = raw.tune[k];
    if (d.started && PFD.deckCheck(d)) d.started = d.kit.length >= PFD.KIT_MIN;
    return d;
  }
  PFD.byId2 = function (slug) { for (var i = 0; i < PFD.CREATURES.length; i++) if (PFD.CREATURES[i].slug === slug) return PFD.CREATURES[i]; return null; };
  function save() { safe(function () { localStorage.setItem(KEY, JSON.stringify(sv)); }); }
  function tune() { var t = {}; for (var k in TUNE0) t[k] = sv.tune[k] !== undefined ? sv.tune[k] : TUNE0[k]; return t; }
  function engineTune() { var t = tune(); return { foe_x: t.foe_x, bar_x: t.bar_x, ev_unit: t.ev_unit, bramble: t.bramble, sun: t.sun, limit: t.limit, br_foe: t.br_half ? 0.5 : 1, nev: t.nev === 'auto' ? null : +t.nev, dims: t.big ? [7, 5] : null, lvl: t.lvl }; }

  var sv = loadSave(), screen = sv.started ? 'box' : 'starter', F = null, RES = null;
  var ui = { picked: [], tab: 'kit', filt: 'all', info: '', cinfo: '', sheet: null, fast: false, seed: (Date.now() % 100000) | 0 };

  // ------------------------------------------------------------------ pieces as the game draws them (pfparts.js)
  var pend = [];
  function cv(o) { pend.push(o); return '<i class="cvh" data-i="' + (pend.length - 1) + '"></i>'; }
  function mount(el) {
    Array.prototype.forEach.call(el.querySelectorAll('i.cvh'), function (h) {
      var o = pend[+h.getAttribute('data-i')], c = o.stamp ? PP.stamp(o.stamp) : o.ghost ? PP.ghost(o) : PP.piece(o);
      if (o.stamp) { c.className = 'pfb-stamp'; c.setAttribute('role', 'img'); c.setAttribute('aria-label', 'Chain of ' + o.stamp + ' pieces'); c.setAttribute('style', o.style); } else { c.className = 'pfb-cv'; c.setAttribute('aria-hidden', 'true'); } h.parentNode.replaceChild(c, h);
    });
    pend = [];
  }
  function art(p, owner) { return cv({ size: 'strip', owner: owner || 'me', type: p.t, edges: PFE.edges({ k: p.k, t: p.t, r: p.r, ed: p.ed }), tag: p.tag && TAGS[p.tag] ? p.tag : '', num: '' }); }
  function pips(n, max, cls) { var h = ''; for (var i = 0; i < max; i++) h += '<i' + (i < n ? '' : ' class="e"') + '></i>'; return '<span class="' + cls + (n <= 1 && max > 1 ? ' last' : '') + '" aria-hidden="true">' + h + '</span>'; }
  function curCreature() { return PFD.byId2(sv.cr) || PFD.CREATURES[0]; }
  function curGnome() { var c = curCreature(); return PFD.gnome(c.level + tune().lvl); }
  function pv(p) { return PFD.tile(p, curGnome()).v; }
  /** What a creature piece plays for on the board (the engine's per-size factors and the Tuning drawer applied). */
  function foeV(c, v) { var t = tune(), sz = c.size; return Math.max(1, Math.round(v * PFE.V1.foe[sz] * t.foe_x * (sz === 'boss' ? 1.2 : 1) * 1.15)); }
  /** One piece cell of a list (the mockup's .pc): art, value, name, expiry pips; border = rank, dashed = gear. */
  function pc(p, o) {
    o = o || {}; var life = p.life || PFD.life(p), v = o.v !== undefined ? o.v : pv(p), px = '';
    for (var i = 0; i < life; i++) px += '<i></i>';
    return '<li><button type="button" class="pc' + (p.rank ? ' r' + p.rank : '') + (p.gear ? ' gear' : '') + (o.cls ? ' ' + o.cls : '') + '"' + (o.a ? ' data-a="' + o.a + '" data-arg="' + esc(o.arg === undefined ? p.id : o.arg) + '"' : '')
      + ' aria-label="' + esc(p.n + ', ' + TYPE[p.t] + ' ' + v + (p.tag ? ', ' + p.tag : '') + (p.rank ? ', ' + PFD.RANK_NAME[p.rank] : '') + ', stays ' + life + ' rounds') + '">'
      + art(p, o.owner) + '<span class="pc-v" aria-hidden="true">' + v + '</span>' + (o.name === false ? '' : '<span class="pc-n">' + esc(p.n) + '</span>') + '<span class="pc-x' + (life < 3 ? ' few' : '') + '" aria-hidden="true">' + px + '</span></button></li>';
  }
  function slot(txt) { return '<li><div class="slot">' + txt + '</div></li>'; }
  function tagText(p, foe) { if (!p.tag) return ''; var t = foe ? FOETAG[p.tag] : (TAGS[p.tag] && TAGS[p.tag][1]); return t ? '<br>' + esc(t) : ''; }
  function desc(p, extra, v) {
    var life = p.life || PFD.life(p);
    return '<span><b>' + esc(p.n) + '</b> ' + TYPE[p.t] + ' ' + (v !== undefined ? v : pv(p)) + (p.rank ? ' · ' + PFD.RANK_NAME[p.rank] : '') + ' · stays ' + life + ' rounds' + (p.from ? ' · ' + esc(p.from) : '')
      + (PFD.TEAM_SRC[p.src] ? ' · Teamwork source' : '') + (extra ? ' · ' + extra : '') + tagText(p) + '</span>';
  }
  function durbar(t) { var m = PFD.toolMax(t), d = sv.dur[t.id], f = d / m; return '<span class="dur' + (d <= 0 ? ' zero' : f <= .25 ? ' crit' : f <= .5 ? ' low' : '') + '" role="img" aria-label="Durability ' + d + ' of ' + m + '"><i style="width:' + Math.round(f * 100) + '%"></i></span>'; }
  function capPips(n, max, cls, lab) { var h = ''; for (var i = 0; i < max; i++) h += '<i' + (i < n ? ' class="on"' : '') + '></i>'; return '<span class="capp ' + cls + '" role="img" aria-label="' + lab + ' ' + n + ' of ' + max + '" title="' + lab + ' ' + n + ' of ' + max + '">' + h + '</span>'; }
  function deckbar() {
    var c = PFD.counts(sv);
    return '<div class="meter" role="img" aria-label="Deck ' + c.n + ': kit ' + c.kit + ', belt ' + c.belt + ', pals ' + c.pals + '"><b>' + c.n + '</b><span class="stack"><span class="k" style="flex:' + Math.max(1, c.kit) + '">🧩 ' + c.kit + '</span>'
      + (c.belt ? '<span class="b" style="flex:' + c.belt + '">🔧 ' + c.belt + '</span>' : '') + (c.pals ? '<span class="p" style="flex:' + c.pals + '">🐾 ' + c.pals + '</span>' : '') + '</span></div>'
      + '<div class="teamrow"><b>Teamwork</b>' + ['pal', 'tool', 'crop'].map(function (k) { return '<span class="chip' + (c.src[k] ? '' : ' off') + '">' + SRCI[k] + ' ' + k + ' ' + c.src[k] + '</span>'; }).join('')
      + '<span>' + (c.team >= 3 ? '2 in a chain +30%, all 3 +60%' : c.team === 2 ? 'both in one chain: +30%' : 'needs 2 of 3 sources') + '</span></div>' + harmonyRow();
  }

  /** Deck harmony: link rate meter, chance a hand links, the knob families, and the trade-off against Teamwork. */
  function harmonyRow() {
    var hm = PFD.harmony(sv), f = hm.fam, tot = Math.max(1, f.body + f.mind + f.craft), top = Math.max(f.body, f.mind, f.craft) / tot, lk = Math.round(hm.link * 100), hd = Math.round(hm.hand * 100);
    var seg = ['body', 'mind', 'craft'].map(function (k) { return f[k] ? '<span class="' + k + '" style="flex:' + f[k] + '">' + k + ' ' + Math.round(100 * f[k] / tot) + '%</span>' : ''; }).join('');
    return '<div class="harm" role="img" aria-label="Deck harmony: link rate ' + lk + ' percent, a hand links ' + hd + ' percent of the time"><b>Link rate</b><span class="hmeter' + (lk >= 30 ? ' good' : lk >= 22 ? '' : ' low') + '"><i style="width:' + Math.min(100, lk * 2) + '%"></i><span>' + lk + '%</span></span><span class="chip" title="Chance that a hand of 5 has a piece that links">hand links ' + hd + '%</span></div>'
      + '<div class="harm"><b>Knobs</b><span class="stack fam">' + seg + '</span></div>'
      + '<p class="hint harmhint">' + (top >= 0.5 ? 'One family leads: easy chains, less Teamwork.' : 'Mixed families: more Teamwork, fewer links.') + ' Pals are body, tools craft, crops mind.</p>';
  }

  // ------------------------------------------------------------------ 1. starter deck
  function starter() {
    var n = ui.picked.length, hurt = 1, tray = '', off = '', gear = '';
    PFD.CORE.forEach(function (id) { tray += pc(PFD.byId(PFD.PIECES, id), { cls: 'lock', name: false, a: 'sinfo' }); });
    for (var i = 0; i < 6; i++) { var q = ui.picked[i] ? PFD.byId(PFD.PIECES, ui.picked[i]) : null; if (q) { if (q.t === 'hurt') hurt++; tray += pc(q, { name: false, a: 'spick' }); } else tray += slot(i + 5); }
    PFD.OFFER.forEach(function (id) { var on = ui.picked.indexOf(id) >= 0; off += pc(PFD.byId(PFD.PIECES, id), { cls: on ? 'sel' : (n >= 6 ? 'off' : ''), a: 'spick' }); });
    PFD.deckPieces({ kit: [], belt: sv.belt, party: sv.party, dur: sv.dur }).forEach(function (p) { gear += pc(p, { a: 'sgear', arg: p.id }); });
    var pp = ''; for (i = 0; i < 6; i++) pp += '<i' + (i < n ? ' class="on"' : '') + '></i>';
    return '<div class="box pbox"><div class="hrow"><h2>🧩 Pack your box</h2><span class="chip ' + (hurt >= 2 ? 'good' : 'warn') + '" title="Hurt pieces (at least 2)">⚔️ ' + hurt + '</span><span class="chip">' + (4 + n) + '/10</span></div>'
      + '<ul class="pcg c5" aria-label="Your box: 10 slots">' + tray + '</ul>'
      + '<div class="kits" role="group" aria-label="Quick kits"><button type="button" class="btn" data-a="kit" data-arg="bold">⚔️ Bold</button><button type="button" class="btn" data-a="kit" data-arg="steady">🛡️ Steady</button><button type="button" class="btn" data-a="kit" data-arg="kind">💗 Kind</button></div>'
      + '<div class="sl">Pick 6 <span class="pips" role="img" aria-label="' + n + ' of 6">' + pp + '</span></div><ul class="pcg">' + off + '</ul>'
      + '<div class="sl">+ Gear <span>belt · pals, added free</span></div><ul class="pcg">' + gear + '</ul>'
      + '<p class="pinfo" aria-live="polite">' + (ui.info || 'Tap a piece to pick it, or take a kit.') + '</p>'
      + '<div class="actrow"><button type="button" class="btn primary grow" data-a="sgo"' + (n === 6 && hurt >= 2 ? '' : ' disabled') + '>🧩 Pack the box</button></div></div>';
  }

  // ------------------------------------------------------------------ 2. puzzle box
  function box() {
    var c = PFD.counts(sv), h = '<div class="box pbox"><div class="hrow"><h2>🧩 Puzzle box</h2>' + capPips(c.rare, PFD.RARE_CAP, '', 'Rare') + capPips(c.mw, PFD.MW_CAP, 'mw', 'Masterwork') + '</div>'
      + '<nav class="tabs" role="tablist" aria-label="Puzzle box">' + [['kit', 'Kit'], ['belt', 'Belt'], ['pals', 'Pals']].map(function (t) { return '<a href="#" role="tab" data-a="tab" data-arg="' + t[0] + '"' + (ui.tab === t[0] ? ' class="on" aria-selected="true"' : '') + '>' + t[1] + '</a>'; }).join('') + '</nav>' + deckbar();
    if (ui.tab === 'kit') {
      var F2 = [['all', 'All'], ['basic', '🧩'], ['crop', '🌾'], ['craft', '🛠️'], ['region', '🗺️']], inK = '', col = '';
      h += '<nav class="chips fbar" aria-label="Filter by source">' + F2.map(function (f) { return '<button type="button" data-a="filt" data-arg="' + f[0] + '"' + (ui.filt === f[0] ? ' class="on"' : '') + ' aria-label="' + f[0] + '">' + f[1] + '</button>'; }).join('') + '</nav>';
      var grp = function (p) { return p.src === 'knack' || p.src === 'calling' ? 'basic' : p.src; };
      PFD.PIECES.forEach(function (p) {
        if (ui.filt !== 'all' && grp(p) !== ui.filt) return;
        if (sv.kit.indexOf(p.id) >= 0) inK += pc(p, { cls: 'sel', a: 'kout' }); else col += pc(p, { cls: PFD.capBlock(sv, p) ? 'off' : '', a: 'kin' });
      });
      h += '<div class="sl">In the kit <span>' + (sv.kit.length < PFD.KIT_MIN ? sv.kit.length + ' · need ' + PFD.KIT_MIN : sv.kit.length + ' · no maximum') + '</span></div><ul class="pcg">' + (inK || slot('none')) + '</ul>'
        + '<div class="sl">Collection <span>tap to pack</span></div><ul class="pcg">' + (col || slot('none')) + '</ul>';
    } else if (ui.tab === 'belt') {
      var slots = PFD.BELT_SLOTS[sv.beltTier], bs = '', tl = '';
      h += '<nav class="chips seg" aria-label="Belt tier (bought)">' + ['Belt I · 2', 'Belt II · 3', 'Belt III · 4'].map(function (t, i) { return '<button type="button" data-a="btier" data-arg="' + i + '"' + (sv.beltTier === i ? ' class="on"' : '') + '>' + t + '</button>'; }).join('') + '</nav>';
      for (var i = 0; i < 4; i++) {
        var t = sv.belt[i] ? PFD.byId(PFD.TOOLS, sv.belt[i]) : null;
        if (i >= slots) bs += slot('locked<br>Belt ' + (i === 2 ? 'II' : 'III'));
        else if (!t) bs += slot('＋');
        else bs += pc(Object.assign({ gear: 1 }, t.p), { a: 'tinfo', arg: t.id }).replace('<li>', '<li class="bslot">').replace('</li>', durbar(t) + '<small>' + sv.dur[t.id] + '/' + PFD.toolMax(t) + '</small></li>');
      }
      PFD.TOOLS.forEach(function (t) {
        var on = sv.belt.indexOf(t.id) >= 0, bk = sv.dur[t.id] <= 0, blk = !on && (sv.belt.length >= slots ? 'Belt full' : PFD.capBlock(sv, t.p) ? 'Rarity cap' : '');
        tl += '<li class="toolrow t' + t.tier + (bk ? ' broken' : '') + '"><span class="ti">' + t.ic + '</span><span class="tx"><b>' + esc(t.name) + '<small>' + sv.dur[t.id] + '/' + PFD.toolMax(t) + '</small></b>' + durbar(t) + '</span>'
          + (bk ? '<button type="button" class="btn gold" data-a="fix" data-arg="' + t.id + '" aria-label="Fix ' + esc(t.name) + '">🔧 Fix</button>'
            : '<button type="button" class="btn' + (on ? ' ghost' : '') + '" data-a="tool" data-arg="' + t.id + '"' + (blk ? ' disabled title="' + blk + '"' : '') + ' aria-label="' + (on ? 'Take off ' : 'Put on ') + esc(t.name) + '">' + (on ? 'Take off' : blk || 'Put on') + '</button>') + '</li>';
      });
      h += '<div class="sl">On the belt <span>each adds its piece · −2 durability a play</span></div><ul class="pcg">' + bs + '</ul><div class="sl">Tools <span>20 durability, +4 a rank</span></div><ul class="tools">' + tl + '</ul>';
    } else {
      var pl = '';
      PFD.PALS.forEach(function (q) { var on = sv.party.indexOf(q.id) >= 0; pl += pc(Object.assign({ gear: 1 }, q.p), { cls: on ? 'sel' : (sv.party.length >= 2 || PFD.capBlock(sv, q.p) ? 'off' : ''), a: 'pal', arg: q.id }); });
      h += '<div class="sl">Puzzle Pals <span>active party: ' + sv.party.length + ' of 2 · 1 piece each</span></div><ul class="pcg">' + pl + '</ul>';
    }
    var bad = PFD.deckCheck(sv);
    return h + '<p class="pinfo" aria-live="polite">' + (ui.info || (bad ? '<span><b>' + esc(bad) + '</b></span>' : 'Tap a piece to pack it or take it out.')) + '</p>'
      + '<div class="actrow"><button type="button" class="btn ghost" data-a="restart" title="Pick the starter deck again">↺ Starter</button><button type="button" class="btn primary grow" data-a="go" data-arg="pre"' + (bad ? ' disabled' : '') + '>⚔️ Find a creature</button></div></div>';
  }

  // ------------------------------------------------------------------ 3. creature and pre-fight
  function pre() {
    var c = curCreature(), cls = PFD.CLASSES[c.cls], dims = tune().big ? [7, 5] : PFE.V1.dims[c.size], g = curGnome(), temper = c.size === 'boss' ? 'cannot be charmed' : PFE.temper(c);
    var grid = PFD.CREATURES.map(function (q) {
      return '<li><button type="button" class="crb' + (q.slug === c.slug ? ' on' : '') + '" data-a="cr" data-arg="' + q.slug + '" aria-pressed="' + (q.slug === c.slug) + '"><img src="' + ART['mini-' + q.slug + '.png'] + '" alt=""><b>' + esc(q.name) + '</b>'
        + '<small><i class="szd ' + q.size + '"></i>' + q.size + ' ' + PFD.CLASSES[q.cls].ic + '</small></button></li>';
    }).join('');
    var fp = PFD.foePieces(c), tally = '', cells = '', by = {};
    fp.forEach(function (p, i) { by[p.layer] = (by[p.layer] || 0) + 1; cells += pc(p, { owner: 'foe', cls: 'L-' + p.layer, a: 'finfo', arg: i, v: foeV(c, p.v) }); });
    ['base', 'reg', 'rar', 'uni'].forEach(function (L) { if (by[L]) tally += '<span style="flex:' + by[L] + ';background:var(--L-' + L + ')" title="' + PFD.LAYERS[L] + ' ' + by[L] + '">' + (by[L] < 2 ? '+' + by[L] : PFD.LAYERS[L].split(' ')[0] + ' ' + by[L]) + '</span>'; });
    var deck = '', bench = '', dp = PFD.deckPieces(sv);
    dp.forEach(function (p) { deck += pc(p, { cls: sv.auto ? 'fixed lock' : '', a: sv.auto ? 'dlock' : (p.gear ? 'dgear' : 'kout'), arg: p.id }); });
    PFD.PIECES.forEach(function (p) { if (sv.kit.indexOf(p.id) < 0) bench += pc(p, { cls: PFD.capBlock(sv, p) ? 'off' : '', a: 'kin' }); });
    var bad = PFD.deckCheck(sv);
    return '<div class="box"><ul class="crgrid" aria-label="Pick a creature">' + grid + '</ul>'
      + '<div class="foecard"><div class="pic"><img src="' + ART['mini-' + c.slug + '.png'] + '" alt="' + esc(c.name) + '"></div><div class="fx"><h3>' + esc(c.name) + ' <small>lv ' + c.level + '</small></h3>'
      + '<div class="chips small"><span class="chip">' + cls.ic + ' ' + cls.name + '</span><span class="chip">' + esc(c.region) + '</span><span class="chip">' + c.size + ' · ' + dims[0] + '×' + dims[1] + '</span><span class="chip">' + temper + '</span></div></div></div>'
      + '<div class="tally" role="img" aria-label="' + fp.length + ' pieces in layers">' + tally + '</div><ul class="pcg c5">' + cells + '</ul>'
      + '<p class="pinfo" aria-live="polite">' + (ui.cinfo || '<span>' + esc(c.blurb) + ' Each piece plays up to 2 times.</span>') + '</p>'
      + '<label class="sw"><input type="checkbox" id="autouse" data-a="auto"' + (sv.auto ? ' checked' : '') + '>Auto-use my current deck<span class="chip">' + (sv.auto ? 'locked' : 'free swaps') + '</span></label>'
      + '<div class="sl">Your deck <span>' + dp.length + ' pieces · you fight at lv ' + g.level + ' · ❤️ ' + g.max + '</span></div><ul class="pcg c5">' + deck + '</ul>'
      + (sv.auto ? '' : '<div class="sl">Bench <span>tap to add</span></div><ul class="pcg c5">' + (bench || slot('none')) + '</ul>')
      + '<p class="pinfo" aria-live="polite">' + (ui.info || (bad ? '<span><b>' + esc(bad) + '</b></span>' : sv.auto ? '<span><b>Auto deck on.</b> Your saved deck goes in as it is.</span><button type="button" class="btn ghost" data-a="autooff">Edit</button>' : 'Tap a deck piece to take it out, a bench piece to add it. Nothing changes once the fight starts.')) + '</p>'
      + '<div class="actrow"><button type="button" class="btn ghost" data-a="go" data-arg="box">🧩 Box</button><button type="button" class="btn primary grow" data-a="fight"' + (bad ? ' disabled' : '') + '>⚔️ Let\'s fight</button></div></div>';
  }

  // ------------------------------------------------------------------ 4. the fight
  function startFight() {
    var c = curCreature(), f = PFD.newFight(sv, c, (++ui.seed) * 7919 + 13, engineTune());
    stopQ(); F = { s: f.s, g: f.g, c: c, log: [], chips: [], chipn: 0, sel: null, cell: null, pv: null, insp: null, show: null, fx: null, busy: false, cache: null }; ui.barPrev = {};
    lg('sys', 'Opening: put one piece next to the blank centre. Nothing fires yet.');
    RES = null; screen = 'fight'; ui.info = ''; draw();
  }
  function lg(cls, txt) { F.log.unshift({ r: F.s.round, cls: cls, txt: txt }); if (F.log.length > 60) F.log.pop(); }
  function evText(e, foeName) {
    var n = esc(e.n), x = '';
    if (e.tick) return 'poison −' + e.v;
    if (e.t === 'hurt') {
      if (e.by === 'me') x = n + ' −' + Math.round(e.fh || 0) + (e.evaded ? ' (it dodged)' : '') + (e.blocked ? ' (' + e.blocked + ' blocked)' : '') + (e.pricked ? ' (thorns −' + e.pricked + ' you)' : '');
      else x = n + ' −' + (e.dmg || 0) + ' hp' + (e.evaded ? ' (dodged)' : '') + (e.blocked ? ' (' + e.blocked + ' blocked)' : '') + (e.bashed ? ' (bash +' + e.bashed + ')' : '');
    } else if (e.t === 'guard') x = n + ' +' + e.v + ' guard';
    else if (e.t === 'heal' || e.t === 'item') x = n + ' +' + e.v + (e.by === 'me' ? ' hp' : ' health');
    else if (e.t === 'charm') x = n + ' +' + Math.round(e.bar || 0) + ' charm';
    else if (e.t === 'soothe') x = n + ' calms ' + e.v;
    else x = n + (e.by === 'foe' && e.tag && FOETAG[e.tag] ? ' (' + e.tag + ')' : '');
    if (e.combo) x += ' ✦' + esc(e.combo);
    if (e.sun) x += ' ☀';
    return x;
  }
  function logTurn(r, before) {
    var s = F.s, name = F.c.name, mine = [], foes = [], tw = 1;
    r.ev.forEach(function (e) { if (e.connect) return; (e.ta === 'me' ? mine : foes).push(evText(e, name)); if (e.ta === 'me' && e.tw) tw = e.tw; });
    var used = {}; (s.uselog || []).forEach(function (u) { used[u.by] = u.used.length; });
    if (mine.length) lg('me', 'You: ' + mine.join(', ') + (tw > 1 ? ' · Teamwork +' + Math.round((tw - 1) * 100) + '%' : '') + (used.me ? ' · chain of ' + used.me + ': used up' : ''));
    Object.keys(s.wear || {}).forEach(function (id) { var d = s.wear[id] - (before.wear[id] || 0); if (d > 0) { var t = PFD.byId(PFD.TOOLS, id); lg('sys', t.name + ' −' + 2 * d + ' durability (' + Math.max(0, sv.dur[id] - 2 * s.wear[id]) + '/' + PFD.toolMax(t) + ')'); } });
    if (foes.length) lg('foe', esc(name) + ': ' + foes.join(', ') + (s.reaim ? ' · its aim was blocked, it picked again' : '') + (used.foe ? ' · chain of ' + used.foe + ': used up' : ''));
    else if (!s.over || s.over === 'defeat') lg('foe', esc(name) + ' makes no move.');
    var env = [];
    (s.envlog || []).forEach(function (L) {
      if (L.k === 'gust') env.push(L.moved ? 'gust pushes ' + esc(L.moved.n) : 'gust finds nothing to push');
      else if (L.k === 'thorn') env.push('thorn burst' + (L.me ? ' −' + L.me + ' hp' : '') + (L.foe ? ' −' + Math.round(L.foe) + ' ' + esc(name) : '') + (!L.me && !L.foe ? ' hits nothing' : ''));
      else if (L.k === 'bramble') env.push('bramble' + (L.me ? ' −' + L.me + ' hp' : '') + (L.foe ? ' −' + Math.round(L.foe) + ' ' + esc(name) : ''));
      else if (L.k === 'poison') env.push('poison −' + L.me + ' hp');
      else env.push(EVN[L.k].toLowerCase() + (L.on ? ' under ' + esc(L.on.n) : ''));
    });
    var gone = (s.gone || []).filter(function (q) { return !q.fell && q.by !== 'none'; }).map(function (q) { return esc(q.tile.n); });
    if (env.length || gone.length) lg('env', 'Ground: ' + env.concat(gone.length ? ['expired: ' + gone.join(', ')] : []).join('; '));
  }
  function geom(v) { var BW = v.w * 56 + 18, BH = v.h * 40 + 12; return { BW: BW, BH: BH,
    piece: function (x, y) { return 'left:' + pct(x * 56 / BW) + ';top:' + pct(y * 40 / BH) + ';width:' + pct(74 / BW) + ';height:' + pct(52 / BH); },
    body: function (x, y) { return 'left:' + pct((x * 56 + 9) / BW) + ';top:' + pct((y * 40 + 6) / BH) + ';width:' + pct(56 / BW) + ';height:' + pct(40 / BH); } }; }
  function litCells() {
    var s = F.s; if (F.sel === null || F.busy || s.over) return [];
    if (F.cache && F.cache.sel === F.sel && F.cache.turn === s.turn && F.cache.start === !!s.start && F.cache.flip === !!s.me.hand[F.sel].flip) return F.cache.cells;
    var out = [], tile = s.me.hand[F.sel];
    if (s.start) { var cx = Math.floor(s.w / 2), cy = Math.floor(s.h / 2); ['L', 'R', 'T', 'B'].forEach(function (sd) { var d = PFE.SIDE[sd]; out.push({ x: cx + d[0], y: cy + d[1], side: sd, pv: null }); }); }
    else PFE.cells(s, tile, 'me').forEach(function (c) { out.push({ x: c[0], y: c[1], pv: PFE.preview(s, F.sel, c[0], c[1]) }); });
    F.cache = { sel: F.sel, turn: s.turn, start: !!s.start, flip: !!tile.flip, cells: out };
    return out;
  }
  /** Flip: once a turn, free, the selected hand piece swaps its top and bottom edges. Flipping the same piece back gives the flip back. */
  function flipFree(k) { var s = F.s; return !!s.canflip && !!s.me.hand[k] && !!s.me.hand[k].ed && (F.flipTurn !== s.turn || F.flipK === k || F.flipK === null); }
  function cellsFlipped(t) { t.flip = !t.flip; var c = PFE.cells(F.s, t, 'me'); t.flip = !t.flip; return c; }
  /** Why each hand piece cannot be played right now (null = it can). Recomputed on every draw, so it follows every change of the board. */
  function handWhy() {
    var s = F.s, out = [], any = false;
    if (F.busy || F.show || s.over) return s.me.hand.map(function () { return s.over ? 'The fight is over.' : 'Wait: the turn is still playing.'; });
    s.me.hand.forEach(function (t, i) {
      var why = null;
      if (!s.start && !PFE.cells(s, t, 'me').length && !(flipFree(i) && cellsFlipped(t).length)) why = PFE.cells(s, t).length ? 'No spot links. Another piece can link, so this one has to wait.' : 'No spot fits this piece' + (s.canflip && t.ed && !flipFree(i) ? ', and your flip is used this turn.' : ', flipped or not.');
      out.push(why); if (!why && !(t.tool && toolLeft(t.tool) <= 0)) any = true;
    });
    s.me.hand.forEach(function (t, i) { if (!out[i] && t.tool && toolLeft(t.tool) <= 0 && any) out[i] = 'Tool broken: Fix in the box.'; });
    return out;
  }
  function toolLeft(id) { return sv.dur[id] - 2 * ((F.s.wear || {})[id] || 0); }
  function flipBtn() { if (F.sel === null || !F.s.canflip || !F.s.me.hand[F.sel].ed) return ''; var ok = flipFree(F.sel) && !F.busy; return '<button type="button" class="btn ghost flipb" data-a="flip"' + (ok ? '' : ' disabled title="One flip a turn"') + ' aria-label="Flip: swap this piece\'s top and bottom edges' + (ok ? '' : ' (used this turn)') + '">⇅ Flip</button>'; }
  function pvLabel(p) {
    if (!p) return '<span class="n">start</span>';
    var a = [];
    if (p.fh > 0.4) a.push('<span class="h">−' + Math.round(p.fh) + '</span>');
    if (p.bar > 0.4) a.push('<span class="c">+' + Math.round(p.bar) + '</span>');
    if (p.block > 0 && a.length < 2) a.push('<span class="g">+' + p.block + '</span>');
    if (p.hp > 0 && a.length < 2) a.push('<span class="l">+' + p.hp + '</span>');
    if (p.hp < 0 && a.length < 2) a.push('<span class="u">−' + (-p.hp) + ' hp</span>');
    if (!a.length) a.push('<span class="n">·</span>');
    if (p.used) a.push('<span class="u">×' + p.n + ' used</span>'); else if (p.tw > 1) a.push('<span class="t">team</span>');
    return a.join('');
  }
  function pvText(tile, p) {
    if (!p) return '<span><b>' + esc(tile.n) + '</b> as your start piece. Nothing fires; the ' + esc(F.c.name) + ' puts one out too.</span>';
    var a = [];
    if (p.fh > 0.4) a.push(esc(F.c.name) + ' −' + Math.round(p.fh)); if (p.bar > 0.4) a.push('charm +' + Math.round(p.bar)); if (p.block) a.push('guard ' + (p.block > 0 ? '+' : '') + p.block);
    if (p.hp) a.push('you ' + (p.hp > 0 ? '+' : '') + p.hp + ' hp'); if (!a.length) a.push('sets up');
    return '<span><b>' + esc(tile.n) + '</b> here: ' + a.join(' · ') + ' · ' + p.n + (p.n === 1 ? ' piece fires' : ' pieces fire') + (p.used ? ', <b>all used up</b>' : '') + (p.tw > 1 ? ' · <b>Teamwork +' + Math.round((p.tw - 1) * 100) + '%</b>' : '') + (p.sun ? ' · sunny ×' + F.s.v1.sun : '')
      + (p.over ? ' · <b>this ends it</b>' : '') + '</span>';
  }
  function fight() {
    var sh = F.show || { s: F.s }, s = sh.s, v = PFE.view(s), c = F.c, G = geom(v), h = '', i, name = esc(c.name), start = !!F.s.start;
    if (sh.bars) { v.hp = sh.bars.hp; v.block = sh.bars.g; v.fh.now = sh.bars.fh; v.bar.now = sh.bars.bar; }
    var hpF = v.hp / v.max, fhLeft = Math.max(0, v.fh.max - v.fh.now), step = F.show ? (sh.who === 'foe' ? 1 : sh.who === 'env' ? 2 : 0) : 0, hide = sh.hide || {};
    var bw = function (k, f) { var t = pct(Math.max(0, Math.min(1, f))), p0 = ui.barPrev[k] === undefined ? t : ui.barPrev[k]; return ' data-bk="' + k + '" data-bw="' + t + '" style="width:' + p0 + '"'; };
    // who is who
    h += '<div class="fb-top"><div class="fb-who"><span class="fb-av"><img src="' + ART['gnome.png'] + '" alt="Your gnome"></span><span class="fb-st"><b>You <small>lv ' + F.g.level + '</small></b>'
      + '<span class="fbar b-hp" role="img" aria-label="Your health ' + v.hp + ' of ' + v.max + '"><i' + bw('hp', hpF) + '></i><span>' + v.hp + '/' + v.max + '</span></span>'
      + '<span class="fbar b-gd sm" role="img" aria-label="Your guard ' + v.block + '"><i' + bw('g', v.block / Math.max(1, v.max * .4)) + '></i><span>guard ' + v.block + '</span></span></span></div>'
      + '<div class="fb-who foe"><span class="fb-av"><img src="' + ART['mini-' + c.slug + '.png'] + '" alt="' + name + '"></span><span class="fb-st"><b>' + name + ' <small>lv ' + c.level + '</small></b>'
      + '<span class="fbar b-fh" role="img" aria-label="Creature health ' + Math.ceil(fhLeft) + ' of ' + Math.round(v.fh.max) + '"><i' + bw('fh', fhLeft / v.fh.max) + '></i><span>' + Math.ceil(fhLeft) + '/' + Math.round(v.fh.max) + (v.foe.block ? ' · guard ' + v.foe.block : '') + '</span></span>'
      + (v.charmable ? '<span class="fbar b-ch sm" role="img" aria-label="Charm ' + Math.round(v.bar.now) + ' of ' + Math.round(v.bar.max) + '"><i' + bw('ch', v.bar.now / v.bar.max) + '></i><span>charm ' + Math.round(v.bar.now) + '/' + Math.round(v.bar.max) + '</span></span>'
        : '<span class="fbar sm"><span>cannot be charmed</span></span>') + '</span></div></div>';
    // what has been played: the site's history chips, newest first, and its Skip button while a turn plays back
    h += '<div class="pfight pf-boardmode pfx-art fb-hist"><div class="pfc-histrow"><ol class="pf-hist" aria-label="What has been played">' + (F.chips.slice(0, 12).map(function (ch, k) {
      return '<li class="pf-chip ' + (ch.by === 'me' ? 'you' : ch.by === 'env' ? 'env' : 'foe') + (k < F.chipn ? ' pf-chip-in' : '') + '">' + ch.html + '</li>'; }).join('') || '<li class="pf-chip empty">Nothing played yet</li>')
      + '</ol><button type="button" class="btn" id="pf-skip" data-a="skip"' + (Q.on ? '' : ' hidden') + '>Skip</button></div></div>';
    F.chipn = 0;
    // turn order, aim, forecast
    var pvw = F.pv, lim = v.limit, dots = '';
    for (i = 1; i <= Math.max(lim, 3); i++) dots += '<i class="' + (pvw && pvw.n >= i ? (lim > 0 && i >= lim && pvw.n >= lim ? 'over' : 'on') : '') + '"></i>';
    h += '<div class="fb-row"><span class="tg step">R' + v.round + '</span>' + ['You', name, 'Terrain'].map(function (t, k) { return '<span class="tg step' + (k === step && !s.over ? ' on' : '') + '">' + t + '</span>'; }).join('<span class="tg step">›</span>')
      + '<span class="tg" title="Pieces that fire in your chain. ' + (lim > 0 ? lim + ' or more: every piece that fired is used up.' : 'Use-up is off.') + '">chain <span class="dots">' + dots + '</span></span>'
      + '<span class="tg team' + (pvw && pvw.tw > 1 ? ' on' : '') + '" title="Pal, tool and crop pieces in one chain: 2 sources +30%, all 3 +60%">' + (pvw && pvw.tw > 1 ? 'Teamwork +' + Math.round((pvw.tw - 1) * 100) + '%' : 'Teamwork') + '</span></div>';
    var at0 = {}; v.pcs.forEach(function (p) { at0[p.x + ',' + p.y] = p; });
    h += '<div class="fb-row">';
    if (!start && !s.over) h += v.status.foe_slow ? '<span class="tg good">' + name + ' is slowed: no move</span>' : v.plan ? '<span class="tg aim">' + svg('aim') + 'Aims ' + esc(v.plan.n) + ' ' + TYPE[v.plan.t].toLowerCase() + ' ' + v.plan.v + '</span>' : '<span class="tg aim">no aim</span>';
    v.envs.forEach(function (e, k) { var on = at0[e.x + ',' + e.y]; h += '<button type="button" class="tg ev" data-a="evinfo" data-arg="' + k + '">' + svg(EVG[e.kind], e.kind === 'gust' ? ROT[e.dir] : 0) + EVN[e.kind] + ': ' + (e.kind === 'gust' && on ? 'pushes ' + esc(on.n) : evText2(e.kind).w) + '</button>'; });
    if (v.status.poison) h += '<span class="tg bad">poisoned ' + v.status.poison + '</span>';
    if (v.status.slowdraw) h += '<span class="tg bad">tripped: draw −1</span>';
    if (v.status.foe_evade) h += '<span class="tg bad">it dodges your next hit</span>';
    if (v.status.foe_thorns) h += '<span class="tg bad">thorny guard</span>';
    if (v.status.evade) h += '<span class="tg good">you dodge the next hit</span>';
    h += '</div>';
    // the board
    var cx, cy, k, key, xy, fires = {}, B = '';
    if (pvw) pvw.ev.forEach(function (e) { if (e.id) fires[e.id] = 1; });
    for (cy = 0; cy < v.h; cy++) for (cx = 0; cx < v.w; cx++) { key = cx + ',' + cy; B += v.ter[key] ? '<button type="button" class="gc g-' + v.ter[key] + '" style="' + G.body(cx, cy) + '" data-a="ter" data-arg="' + v.ter[key] + '" data-y="' + cy + '" aria-label="' + GRN[v.ter[key]] + ' ground: what it does"></button>' : '<div class="gc" style="' + G.body(cx, cy) + '"></div>'; }
    var at = {}; v.pcs.forEach(function (p) { at[p.x + ',' + p.y] = p; });
    v.pcs.forEach(function (p) {
      if (hide[p.id]) return;
      if (p.by === 'none') { B += '<div class="bp blank" style="' + G.piece(p.x, p.y) + '" title="The blank centre: pieces connect to it, nothing fires through it. Gone after round 1."><span>✦</span></div>'; return; }
      var tagged = p.tag && TAGS[p.tag] ? p.tag : '';
      B += '<button type="button" class="bp pfb-cell by-' + p.by + (p.fnew && !F.show ? ' fnew' : '') + (fires[p.id] ? ' glow' : '') + (F.insp === p.id ? ' insp' : '') + (sh.drop === p.id ? ' pfb-drop' : '') + (sh.score === p.id || (sh.scores && sh.scores[p.id]) ? ' pfb-scoring' : '') + (ui.spawn && p.spawn ? ' pfb-spawn' : '') + '" style="' + G.piece(p.x, p.y) + '" data-a="insp" data-arg="' + p.id + '" aria-label="' + (p.by === 'me' ? 'Your piece: ' : 'Creature piece: ') + esc(p.n) + ', ' + p.t + ' ' + p.v + ', ' + p.left + ' rounds left">'
        + cv({ size: 'strip', owner: p.by, type: p.t, edges: p.e, tag: tagged, num: '' }) + '<b class="bv">' + p.v + '</b>' + pips(p.left, p.life, 'xp') + (p.fl !== null && p.fl !== undefined ? '<em class="fl">×' + p.fl + '</em>' : '') + '</button>';
      [['R', 1, 0, 'L'], ['B', 0, 1, 'T']].forEach(function (d) {   // the stitch mark on a linked joint (a chain runs through it)
        var n = at[(p.x + d[1]) + ',' + (p.y + d[2])]; if (!n || n.by === 'none') return;
        if (!PFE.joint(p.e[d[0]], n.e[d[3]])[1] || v.ter[p.x + ',' + p.y] === 'mud' || v.ter[n.x + ',' + n.y] === 'mud') return;
        if (d[0] === 'R') B += '<img class="jt" src="' + ART['joint-h.png'] + '" alt="" style="left:' + pct(((p.x + 1) * 56 + 9 - 11) / G.BW) + ';top:' + pct((p.y * 40 + 6 + 13) / G.BH) + ';width:' + pct(22 / G.BW) + ';height:' + pct(14 / G.BH) + '">';
        else B += '<img class="jt" src="' + ART['joint-v.png'] + '" alt="" style="left:' + pct((p.x * 56 + 9 + 21) / G.BW) + ';top:' + pct(((p.y + 1) * 40 + 6 - 11) / G.BH) + ';width:' + pct(14 / G.BW) + ';height:' + pct(22 / G.BH) + '">';
      });
    });
    (sh.ghosts || []).forEach(function (q) {   // pieces that were used up, fell away or expired stay until everything has scored, then leave (the site's pfb-gone / pfb-leaving)
      if (at[q.x + ',' + q.y]) return; var qt = q.tile;
      B += '<div class="bp pfb-cell pfb-gone by-' + q.by + (sh.leaving ? ' pfb-leaving' : '') + (sh.score === q.id ? ' pfb-scoring' : '') + '" style="' + G.piece(q.x, q.y) + '">' + cv({ size: 'strip', owner: q.by, type: qt.t, edges: PFE.edges(qt), tag: qt.tag && TAGS[qt.tag] ? qt.tag : '', num: '' }) + '<b class="bv">' + qt.v + '</b></div>';
    });
    if (F.fx && !F.show) {   // the last turn's chains: a glow along each linked joint, a stamp with its length on the piece that started it (as the site draws them)
      var sets = F.fx.map(function (ch) { var m = {}; ch.ids.forEach(function (id) { m[id] = true; }); return m; }), byId = {};
      v.pcs.forEach(function (p) { byId[p.id] = p; });
      v.pcs.forEach(function (ga) {
        [['R', 1, 0, 'L', 'chain-glow-v.png', 8, 32, 1], ['B', 0, 1, 'T', 'chain-glow-h.png', 32, 8, 0]].forEach(function (d) {
          var gn = at[(ga.x + d[1]) + ',' + (ga.y + d[2])]; if (!gn || ga.by === 'none' || gn.by === 'none' || !PFE.joint(ga.e[d[0]], gn.e[d[3]])[1]) return;
          if (!sets.some(function (st) { return st[ga.id] && st[gn.id]; })) return;
          var gx = d[1] ? (ga.x + 1) * 56 + 9 : ga.x * 56 + 9 + 28, gy = d[1] ? ga.y * 40 + 6 + 20 : (ga.y + 1) * 40 + 6;
          B += '<span class="pfb-glow" aria-hidden="true" data-v="' + d[7] + '" style="background-image:url(' + ART[d[4]] + ');background-size:' + (d[7] ? '400% auto' : 'auto 400%') + ';left:' + pct((gx - d[5] / 2) / G.BW) + ';top:' + pct((gy - d[6] / 2) / G.BH) + ';width:' + pct(d[5] / G.BW) + ';height:' + pct(d[6] / G.BH) + '"></span>';
        });
      });
      F.fx.forEach(function (ch) { var r0 = byId[ch.ids[0]]; if (r0) B += cv({ stamp: ch.ids.length, style: 'left:' + pct((r0.x * 56 + 9 + 56 - 22) / G.BW) + ';top:' + pct((r0.y * 40 + 6 - 14) / G.BH) + ';width:' + pct(32 / G.BW) + ';height:' + pct(32 / G.BH) }); });
    }
    for (key in v.ter) { xy = key.split(','); B += '<div class="gf g-' + v.ter[key] + '" style="' + G.body(+xy[0], +xy[1]) + '">' + svg(v.ter[key]) + '</div>'; }
    if (!s.over) {
      v.envs.forEach(function (e, ek) {
        if (e.kind === 'thorn') [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]].forEach(function (d) { var zx = e.x + d[0], zy = e.y + d[1]; if (zx >= 0 && zy >= 0 && zx < v.w && zy < v.h) B += '<div class="mk zone" style="' + G.body(zx, zy) + '"></div>'; });
        B += '<div class="mk ev k-' + e.kind + (sh.flash === ek ? ' pfb-cell pfb-scoring evflash' : '') + '" style="' + G.body(e.x, e.y) + '"><button type="button" class="mkb' + (v.envs.some(function (o, ok) { return ok < ek && o.x === e.x && o.y === e.y; }) ? ' m2' : '') + '" data-a="evinfo" data-arg="' + ek + '" aria-label="' + EVN[e.kind] + ': what it will do">' + svg(EVG[e.kind], e.kind === 'gust' ? ROT[e.dir] : 0) + '<em>' + EVW[e.kind] + '</em></button></div>';
      });
      if (v.plan && !start && !v.status.foe_slow && sh.aim !== false) B += '<div class="mk aim" style="' + G.body(v.plan.x, v.plan.y) + '">' + svg('aim') + '<b>' + v.plan.v + '</b></div>';
    }
    var lit = litCells(), tile = F.sel !== null ? F.s.me.hand[F.sel] : null;
    lit.forEach(function (q) {
      var on = F.cell && F.cell[0] === q.x && F.cell[1] === q.y;
      B += '<button type="button" class="lit' + (on ? ' sel' : '') + '" style="' + G.piece(q.x, q.y) + '" data-a="cell" data-x="' + q.x + '" data-y="' + q.y + '" aria-label="Place here, column ' + (q.x + 1) + ' row ' + (q.y + 1) + '">'
        + cv({ ghost: 1, size: 'strip', owner: 'me', edges: PFE.edges(tile) }) + '<span class="ln">' + pvLabel(q.pv) + '</span></button>';
    });
    var pop = '';
    if (F.pop) { var pt = F.pop.t === 'ter' ? terrText(F.pop.k) : F.pop.t === 'turn' ? turnText() : evText2(F.pop.k);
      pop = '<div class="pop' + (F.pop.y !== undefined && F.pop.y !== null && F.pop.y >= v.h / 2 ? ' top' : '') + '" role="dialog" aria-label="' + pt.n + '"><span class="popi">' + svg(pt.g, F.pop.rot || 0) + '</span><span class="popt"><b>' + pt.n + '</b>' + pt.l.map(function (x) { return '<span>' + esc(x) + '</span>'; }).join('') + '<i>' + esc(pt.who) + '</i></span><button type="button" class="popx" data-a="popx" aria-label="Close">×</button></div>'; }
    h += '<div class="bwrap"><div class="board" style="aspect-ratio:' + G.BW + '/' + G.BH + ';max-width:' + Math.round(G.BW * 1.25) + 'px" role="group" aria-label="The board, ' + v.w + ' by ' + v.h + '"' + (Q.on ? ' data-a="skip" title="Tap to skip"' : '') + '>' + B + '</div>' + pop + '</div>';
    var c1 = s.v1;
    h += '<div class="fb-row legend" role="group" aria-label="Terrain legend">' + [['sun', 'Sunny: counts ' + times(c1.sun)], ['br', 'Bramble: −' + pc100(c1.bramble) + ' a round'], ['mud', 'Mud: no links']].map(function (q) {
      return '<button type="button" class="tg lg-' + q[0] + '" data-a="ter" data-arg="' + q[0] + '">' + svg(q[0]) + q[1] + '</button>'; }).join('')
      + '<button type="button" class="tg" data-a="turninfo">Terrain turn</button><button type="button" class="tg qm" data-a="help" aria-label="Help: terrain and events">?</button></div>';
    // what is selected
    var info, canPass = false;
    if (s.over && !F.show) info = '<span><b>The fight is over.</b></span>';
    else if (F.show) info = '<span>' + (sh.note || 'Playing the turn…') + '</span>';
    else if (F.busy) info = '<span>…</span>';
    else if (F.cell && tile) info = pvText(tile, F.pv) + flipBtn() + '<button type="button" class="btn primary" data-a="play">Play</button>';
    else if (ui.info) info = ui.info;
    else if (tile) info = (lit.length ? '<span><b>' + esc(tile.n) + '</b> ' + TYPE[tile.t] + ' ' + tile.v + ': tap a lit cell. The number is what your own chain does.' + (tile.tool ? ' Tool piece: −2 durability when played.' : '') + '</span>' : '<span><b>' + esc(tile.n) + '</b> fits nowhere this way up. Flip it.</span>') + flipBtn();
    else {
      canPass = !start && !F.s.me.hand.some(function (t) { return PFE.cells(F.s, t).length > 0; });
      info = canPass ? '<span>Nothing in your hand fits.</span><button type="button" class="btn primary" data-a="pass">Pass</button>' : '<span>' + (start ? 'Pick a piece, then a side of the blank centre ✦.' : 'Pick a piece from your hand.') + '</span>';
    }
    h += '<div class="fb-info" aria-live="polite">' + info + '</div>';
    // the hand
    var hand = '', why = F.show ? v.hand.map(function () { return 'Wait: the turn is still playing.'; }) : handWhy();
    v.hand.forEach(function (t, k) {
      var tagged = t.tag && TAGS[t.tag] ? t.tag : '';
      hand += '<button type="button" class="hc' + (F.sel === k ? ' sel' : '') + (why[k] ? ' off' : '') + (ui.flipAnim === k ? ' flipping' : '') + (s.me.hand[k] && s.me.hand[k].flip ? ' flipped' : '') + '" data-a="hand" data-arg="' + k + '" aria-pressed="' + (F.sel === k) + '"' + (why[k] ? ' aria-disabled="true"' : '') + ' aria-label="' + esc(t.n) + ', ' + t.t + ' ' + t.v + ', stays ' + t.life + ' rounds' + (why[k] ? '. Cannot be played: ' + esc(why[k]) : '') + '">'
        + cv({ size: 'strip', owner: 'me', type: t.t, edges: t.e, tag: tagged, num: '' }) + '<b class="bv">' + t.v + '</b>' + (SRCI[t.src] ? '<span class="src" title="Teamwork source: ' + t.src + '">' + SRCI[t.src] + '</span>' : '')
        + '<span class="hn">' + esc(t.n) + '</span>' + pips(t.life, t.life, 'xp') + '</button>';
    });
    for (k = v.hand.length; k < 5; k++) hand += '<span class="hc none" aria-hidden="true"></span>';
    h += '<div class="hand" role="group" aria-label="Your hand">' + hand + '</div>';
    h += '<div class="piles"><span>draw ' + v.piles.draw + ' · discard ' + v.piles.discard + '</span><span>turn ' + v.turn + ' of ' + PFE.TURN_CAP + '</span></div>';
    h += '<div class="fb-log" role="log" aria-label="Turn log">' + F.log.slice(0, 14).map(function (L) { return '<div class="' + L.cls + '"><b>' + L.r + '</b> ' + L.txt + '</div>'; }).join('') + '</div>';
    return '<div class="fb">' + ico(h).replace(/☀/g, '<span style="color:#ffd65a">☀</span>') + '</div>';
  }
  // ---- the playback queue (ported from the site's replay in game/assets/pfboard.js: maybeReplay / showTurn / stopPlay / afterLeave).
  // Each side: its banner shows, holds, fades (BAN), and only then its pieces play, one event every STEP: the piece is put down (pfb-drop), it scores (pfb-scoring),
  // its history chip slides in and the bars follow. Then the pieces that left go (pfb-leaving), the chain glow and stamps show, and "Your turn" comes up.
  var Q = { on: false, timer: 0, steps: [], done: null }, STEP = 950, BAN = 1500, LEAVE = 800, turnEl = null, turnTimer = 0, glowTimer = 0;
  function speed() { var a = tune().anim; return ui.fast || a === 'skip' ? 0 : a === '2' ? 2 : 1; }
  function calm() { return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches); }
  function showTurn(text, who, sub) {   // a short banner over the play area so it is clear whose turn it is
    var app = document.getElementById('app'), bd = main.querySelector('.board'); if (!bd) return;
    if (!turnEl) { turnEl = document.createElement('div'); turnEl.setAttribute('role', 'status'); app.appendChild(turnEl); }
    clearTimeout(turnTimer); turnEl.textContent = text; if (sub) { var sm = document.createElement('small'); sm.textContent = sub; turnEl.appendChild(sm); } turnEl.className = 'pf-turn pf-turn-' + who; turnEl.hidden = false;
    var r = bd.getBoundingClientRect(), ar = app.getBoundingClientRect();
    turnEl.style.top = Math.max(4, r.top - ar.top + r.height / 2 - 18) + 'px';
    turnEl.style.animationDuration = (1.4 / Math.max(1, speed())) + 's';
    void turnEl.offsetWidth; turnEl.classList.add('pf-turn-on');
    turnTimer = setTimeout(function () { if (turnEl) turnEl.hidden = true; }, 1450 / Math.max(1, speed()));
  }
  function hideTurn() { clearTimeout(turnTimer); if (turnEl) turnEl.hidden = true; }
  function stopQ() { clearTimeout(Q.timer); Q.on = false; Q.steps = []; Q.done = null; hideTurn(); clearInterval(glowTimer); glowTimer = 0; }
  function nextStep() {
    if (!Q.on) return;
    var st = Q.steps.shift(); if (!st) { var d = Q.done; Q.on = false; Q.done = null; d(false); return; }
    st.fn(); Q.timer = setTimeout(nextStep, st.d / speed());
  }
  function skipPlay() { if (!Q.on) return; clearTimeout(Q.timer); var d = Q.done; Q.on = false; Q.steps = []; Q.done = null; hideTurn(); d(true); }
  function startGlow() {   // 4 frames at about 8 fps for a few seconds, then the glow and stamps go (a still frame if the player prefers less motion)
    var ticks = 0, frame = 0, still = calm(); clearInterval(glowTimer);
    glowTimer = setInterval(function () {
      ticks++; if (!still) frame = (frame + 1) % 4;
      Array.prototype.forEach.call(main.querySelectorAll('.pfb-glow'), function (g) { var w = g.getBoundingClientRect(); g.style.backgroundPosition = g.getAttribute('data-v') === '1' ? (-frame * w.width) + 'px 0' : '0 ' + (-frame * w.height) + 'px'; });
      if (ticks > 40 || !F) { clearInterval(glowTimer); glowTimer = 0; if (F) F.fx = null; Array.prototype.forEach.call(main.querySelectorAll('.pfb-glow,.pfb-stamp'), function (g) { if (g.parentNode) g.parentNode.removeChild(g); }); }
    }, 125);
  }
  /** One history chip (the site's markup: who, the piece's icon, what it did, on whom). */
  function chipOf(e) {
    var ch = PFE.chipEvent(e), gn = '<img class="pfh-gn" src="' + ART['gnome.png'] + '" alt="">', cr = '<img class="pfh-cr" src="' + ART['mini-' + F.c.slug + '.png'] + '" alt="">', t = ch.types[0];
    var tagIc = ch.tags && ch.tags[0] && ART['ico-' + ({ quick: 'jab', heavy: 'smash', pierce: 'pierce', poison: 'sting', trip: 'trip', bash: 'bash', hold: 'brace', evade: 'roll', thorns: 'thornhide', mend: 'mending', hum: 'hum', lull: 'lull', bond: 'bond' }[ch.tags[0]] || '-') + '-s.png'];
    return { by: ch.by, html: (ch.by === 'me' ? gn : cr) + '<img class="pfh-ico" src="' + (tagIc || ART['ico-' + t + '-s.png'] || ART['ico-trick-s.png']) + '" alt="' + esc(t) + '"> <span class="pfh-txt">' + esc(String(ch.txt).replace(/✨/g, '✦ ')) + '</span>' + (ch.tg === 'me' ? gn : ch.tg === 'foe' ? cr : '') };
  }
  function envChip(L, name) {
    var k = L.k === 'bramble' ? 'br' : L.k === 'poison' ? 'thorn' : EVG[L.k], txt;
    if (L.k === 'gust') txt = L.moved ? 'pushes ' + L.moved.n : 'no push'; else if (L.k === 'poison') txt = 'poison -' + L.me + ' hp';
    else if (L.k === 'thorn' || L.k === 'bramble') txt = ((L.me ? '-' + L.me + ' hp ' : '') + (L.foe ? '-' + Math.round(L.foe) + ' ' + name : '')) || 'nothing hit';
    else txt = EVN[L.k].toLowerCase();
    return { by: 'env', txt: txt, html: svg(k) + ' <span class="pfh-txt">' + esc(txt) + '</span>' };
  }
  /** Your move (mv = [handIdx, x, y]) or a pass (null): the engine plays the whole round at once; the stages are replayed from copies. */
  function runTurn(mv) {
    var s = F.s, S0 = PFE.clone(s), before = { wear: PFE.clone(s.wear || {}) }, name = F.c.name;
    var A = PFE.clone(s); A.spent = []; A.uselog = []; PFE.begin(A, 'me');
    if (mv && PFE.place(A, 'me', mv[0], mv[1], mv[2]) === null) { ui.info = '<span>That piece does not fit there.</span>'; F.cell = null; draw(); return; }
    var myId = mv ? A.pid : null, B = null, C = null;
    if (!A.over) { B = PFE.clone(A); PFE.foeTurn(B); if (!B.over) { C = PFE.clone(B); PFE.endRound(C); } }
    var r = mv ? PFE.play(s, [mv], s.turn) : PFE.pass(s, s.turn);
    if (r.err) { ui.info = '<span>' + esc(r.err) + '</span>'; draw(); return; }
    F.sel = null; F.cell = null; F.pv = null; F.cache = null; F.insp = null; F.fx = null; F.busy = true; ui.info = ''; clearInterval(glowTimer); glowTimer = 0;
    var evMe = r.ev.filter(function (e) { return e.ta === 'me' && !e.connect; }), evFoe = r.ev.filter(function (e) { return e.ta === 'foe'; });
    var bars = { hp: S0.me.hp, g: S0.me.block, fh: S0.fh.now, bar: S0.bar.now }, steps = [], pending = [];
    var snapBars = function () { return { hp: bars.hp, g: bars.g, fh: bars.fh, bar: bars.bar }; };
    var take = function (e) { if (e.hpnow !== undefined) { bars.hp = e.hpnow; bars.g = e.gnow; bars.fh = e.fhnow; bars.bar = e.barnow; } return snapBars(); };
    var frame = function (o, d, chip, banner) { steps.push({ d: d, fn: function () { if (chip) { F.chips.unshift(chip); F.chipn = 1; } F.show = o; F.pop = null; draw(); if (banner) showTurn(banner[0], banner[1], banner[2]); } }); if (chip) pending.push(chip); };
    var spentA = (A.spent || []).slice(), b0 = snapBars();
    // your turn
    frame({ s: S0, who: 'me', bars: b0, note: mv ? 'Your piece goes down…' : 'You pass.' }, mv ? BAN : 400, null, mv ? ['Your turn', 'me'] : null);
    evMe.forEach(function (e, k) { frame({ s: A, who: 'me', bars: take(e), ghosts: spentA, drop: k === 0 ? myId : null, score: e.id, aim: false, note: evText(e, name) }, STEP, chipOf(e)); });
    if (spentA.length) frame({ s: A, who: 'me', bars: snapBars(), ghosts: spentA, leaving: true, aim: false, note: 'A chain of ' + (s.v1.limit || 3) + ' or more: the pieces that fired are used up.' }, LEAVE);
    // the creature's turn: its aim is on the board while the banner shows, then its piece goes down and its chain scores
    if (B) {
      var hid = {}, spentB = (B.spent || []).filter(function (q) { return !spentA.some(function (a) { return a.id === q.id; }); }); (B.lastfoe || []).forEach(function (id) { hid[id] = true; });
      frame({ s: A, who: 'foe', bars: snapBars(), note: S0.foe.plan ? 'The ' + esc(name) + ' aims ' + esc(S0.foe.plan.n) + ' at the marked cell.' : 'The ' + esc(name) + ' looks for a spot.' }, BAN, null, [name + "'s turn", 'foe']);
      if (!evFoe.length) frame({ s: B, who: 'foe', bars: snapBars(), aim: false, note: 'The ' + esc(name) + ' makes no move.' }, STEP);
      evFoe.forEach(function (e) {
        var drop = null; if (e.id && hid[e.id]) { delete hid[e.id]; drop = e.id; }
        frame({ s: B, who: 'foe', bars: take(e), hide: PFE.clone(hid), ghosts: spentB, drop: drop, score: e.id, aim: false, note: (e.tick ? 'Your ' : esc(name) + ': ') + evText(e, name) + (drop && s.reaim ? ' (its aim was blocked, it picked again)' : '') }, STEP, chipOf(e));
      });
      if (spentB.length) frame({ s: B, who: 'foe', bars: snapBars(), ghosts: spentB, leaving: true, aim: false, note: 'Pieces that fired twice, or in a chain of 3, fall away.' }, LEAVE);
    }
    // the environment turn: the announced events land in order, then bramble pricks (v1 design; the site has no environment turn yet)
    if (C) {
      var el = C.envlog || [];
      if (el.length) frame({ s: B, who: 'env', bars: snapBars(), aim: false, note: '<b>Terrain turn.</b> The marked events land in order, then bramble pricks, then old pieces expire.' }, BAN, null, ['Terrain turn', 'env', 'events land, then bramble pricks']);
      el.forEach(function (L) {
        var fl = null, sc = {}; (B.envs || []).forEach(function (e, k) { if (fl === null && e.kind === L.k && e.x === L.x && e.y === L.y) fl = k; });
        if (L.k === 'bramble') for (var id in B.pcs) { var p = B.pcs[id]; if (PFE.ter(C, p.x, p.y) === 'br' && p.by !== 'none') sc[id] = 1; }
        if (L.k === 'thorn') for (var id2 in B.pcs) { var p2 = B.pcs[id2]; if (Math.abs(p2.x - L.x) + Math.abs(p2.y - L.y) <= 1 && p2.by !== 'none') sc[id2] = 1; }
        if (L.me) bars.hp = Math.max(0, bars.hp - L.me); if (L.foe) bars.fh += L.foe;
        var ch = envChip(L, name);
        frame({ s: B, who: 'env', bars: snapBars(), flash: fl, scores: sc, aim: false, note: '<b>' + (L.k === 'bramble' ? 'Bramble' : L.k === 'poison' ? 'Poison' : EVN[L.k]) + '</b>: ' + esc(ch.txt) }, STEP, ch);
      });
      var exp = (s.gone || []).filter(function (q) { return !q.fell && q.by !== 'none'; });
      if (exp.length || el.length) frame({ s: s, who: 'env', ghosts: exp, leaving: true, aim: false, note: exp.length ? 'Expired: ' + exp.map(function (q) { return esc(q.tile.n); }).join(', ') + '.' : 'The ground has changed.' }, exp.length ? LEAVE : 500);
    }
    Q.steps = steps; Q.on = true;
    Q.done = function (skipped) {
      if (skipped) { pending.forEach(function (ch) { if (F.chips.indexOf(ch) < 0) F.chips.unshift(ch); }); F.chipn = 0; }
      F.show = null; F.busy = false; F.fx = s.over ? null : (s.fx || []).filter(function (ch) { return ch.ids.every(function (id) { return !!s.pcs[id]; }); });
      if (!mv) lg('me', 'You pass.');
      logTurn(r, before);
      var sp = speed(); if (!sp || !F.fx || !F.fx.length) F.fx = null;
      ui.spawn = !skipped && !!sp; draw(); ui.spawn = false;
      if (F.fx) startGlow();
      if (s.over) { F.busy = true; if (sp) Q.timer = setTimeout(function () { if (F) finish(F.s.over); }, 900 / sp); else finish(s.over); }
      else if (sp) showTurn('Your turn', 'me');
    };
    if (!speed()) { skipPlay(); return; }
    nextStep();
  }
  function doPlay() {
    var s = F.s, i = F.sel, x = F.cell[0], y = F.cell[1];
    if (s.start) {
      var q = litCells().filter(function (c) { return c.x === x && c.y === y; })[0], nm = s.me.hand[i].n, err = PFE.start(s, i, q.side);
      if (err) { ui.info = '<span>' + esc(err) + '</span>'; draw(); return; }
      var fp = []; for (var id in s.pcs) if (s.pcs[id].by === 'foe') fp.push(s.pcs[id].tile.n);
      lg('sys', 'You put out ' + esc(nm) + '; the ' + esc(F.c.name) + ' puts out ' + esc(fp.join(' and ')) + '.');
      F.sel = null; F.cell = null; F.pv = null; F.cache = null; draw();
      if (speed()) showTurn('Your turn', 'me');
      return;
    }
    runTurn([i, x, y]);
  }
  function doPass() { runTurn(null); }
  /** The fight is over: tool wear is applied (2 durability a play; a broken tool leaves the belt), then the result card. */
  function finish(how) {
    var s = F.s, wear = [];
    Object.keys(s.wear || {}).forEach(function (id) {
      var t = PFD.byId(PFD.TOOLS, id), b = sv.dur[id], a = Math.max(0, b - 2 * s.wear[id]); sv.dur[id] = a;
      if (a <= 0) sv.belt = sv.belt.filter(function (q) { return q !== id; });
      wear.push({ t: t, plays: s.wear[id], before: b, after: a });
    });
    sv.fights++; save();
    stopQ(); RES = { how: how, c: F.c, hp: s.me.hp, max: s.me.max, turns: s.turn, wear: wear, st: s.st || {}, fh: Math.max(0, s.fh.max - s.fh.now), fhmax: s.fh.max, bar: s.bar.now, barmax: s.bar.max, log: F.log.slice(0, 40) };
    F = null; screen = 'result'; ui.info = ''; draw();
  }

  // ------------------------------------------------------------------ 5. result
  function result() {
    var R = RES, c = R.c, name = esc(c.name), T = { seen_off: ['win', 'You won', 'The ' + name + ' backs off.'], charmed: ['charm', 'Charmed', 'You won the ' + name + ' over: a better reward.'],
      defeat: ['lose', 'Worn out', 'The ' + name + ' sends you home to rest.'], stall: ['lose', 'It slipped away', 'The fight ran out of turns.'], fled: ['lose', 'You walked away', 'No reward this time.'] }[R.how] || ['lose', 'Over', ''];
    var loot = R.how === 'charmed' ? c.loot.slice(0, 2).concat(['Friendship token']) : R.how === 'seen_off' ? c.loot.slice(0, 1) : [];
    var w = R.wear.map(function (x) { return '<li class="toolrow t' + x.t.tier + (x.after <= 0 ? ' broken' : '') + '"><span class="ti">' + x.t.ic + '</span><span class="tx"><b>' + esc(x.t.name) + '<small>' + x.before + ' → ' + x.after + '/' + PFD.toolMax(x.t) + '</small></b>' + durbar(x.t)
      + '</span><span class="chip">' + (x.after <= 0 ? 'broke · off the belt' : x.plays + ' × −2') + '</span></li>'; }).join('');
    var team = (R.st.team2 || 0) + (R.st.team3 || 0);
    return '<div class="box res"><span class="resbadge badge-' + T[0] + '">' + (T[0] === 'lose' ? 'lost' : T[0]) + '</span><h2>' + T[1] + '</h2><div class="pic"><img src="' + ART['mini-' + c.slug + '.png'] + '" alt="' + name + '"></div><p class="big">' + T[2] + '</p>'
      + '<div class="rows"><div class="row"><b>You</b><span class="gvbar"><i style="width:' + pct(R.hp / R.max) + '"></i><span>' + R.hp + '/' + R.max + '</span></span></div>'
      + '<div class="row"><b>Creature</b><span>' + Math.ceil(R.fh) + '/' + Math.round(R.fhmax) + ' health left' + (c.size !== 'boss' ? ' · charm ' + Math.round(R.bar) + '/' + Math.round(R.barmax) : '') + '</span></div>'
      + '<div class="row"><b>Fight</b><span>' + R.turns + ' turns' + (team ? ' · Teamwork ' + team + '×' : '') + (R.st.spend_me ? ' · ' + R.st.spend_me + ' chains used up' : '') + '</span></div>'
      + '<div class="row"><b>Loot</b><span>' + (loot.length ? loot.map(function (l) { return '<span class="chip">' + esc(l) + '</span>'; }).join(' ') + ' <small class="muted">placeholder</small>' : '<small class="muted">none</small>') + '</span></div></div>'
      + '<div class="sl" style="width:100%">Tool wear <span>2 durability each time its piece is played</span></div>' + (w ? '<ul class="tools" style="width:100%;text-align:left">' + w + '</ul>' : '<p class="hint" style="margin:0">No tool piece was played.</p>')
      + '<div class="actrow" style="width:100%"><button type="button" class="btn ghost" data-a="fight">↺ Again</button><button type="button" class="btn primary grow" data-a="go" data-arg="box">🧩 Back to the box</button></div></div>';
  }

  // ------------------------------------------------------------------ tuning drawer and deck sheet
  var TR = [['foe_x', 'Creature hits', 0.5, 1.6, 0.05, function (v) { return '×' + v.toFixed(2); }, 'Factor on the creature\'s piece values (sim 3: small 0.65, medium 0.56, large 0.53, boss 0.64 of the old values).'],
    ['bar_x', 'Creature bars', 0.5, 2, 0.05, function (v) { return '×' + v.toFixed(2); }, 'Health and charm bars. Sim 3 already has them ×1.6 (boss ×1.25) for 6-8 turns.'],
    ['ev_unit', 'Event strength', 0, 0.3, 0.01, function (v) { return Math.round(v * 100) + '%'; }, 'Thorn burst: share of max health per piece in the zone (creature pieces: half).'],
    ['bramble', 'Bramble damage', 0, 0.25, 0.01, function (v) { return Math.round(v * 100) + '%'; }, 'Share of max health a piece on bramble costs its owner each round.'],
    ['sun', 'Ground strength', 1, 3, 0.25, function (v) { return '×' + v.toFixed(2); }, 'Sunny cell: factor on a Hurt or Charm piece standing on it.'],
    ['limit', 'Use-up limit', 0, 5, 1, function (v) { return v ? v + '+' : 'off'; }, 'A chain that fires this many pieces uses them all up (both sides).'],
    ['lvl', 'Your level', -8, 4, 1, function (v) { return (v > 0 ? '+' : '') + v; }, 'Gnome level against the creature\'s level (0 = at level).']];
  function tuneSheet() {
    var t = tune(), h = '<div class="hrow"><h2>Tuning</h2><button type="button" class="btn ghost small" data-a="treset">Reset</button><button type="button" class="btn small" data-a="sclose">Done</button></div>'
      + '<p class="note"><b>Provisional.</b> These are the sim 3 numbers. Changes apply to the next fight.</p>';
    TR.forEach(function (r) { h += '<div class="tune"><label for="tu-' + r[0] + '">' + r[1] + '</label><output id="to-' + r[0] + '" for="tu-' + r[0] + '">' + r[5](t[r[0]]) + '</output><input type="range" id="tu-' + r[0] + '" data-k="' + r[0] + '" min="' + r[2] + '" max="' + r[3] + '" step="' + r[4] + '" value="' + t[r[0]] + '"><small>' + r[6] + '</small></div>'; });
    h += '<label class="tsel" for="tu-anim">Animation speed <select id="tu-anim" data-k="anim">' + [['1', '1× (as the site)'], ['2', '2×'], ['skip', 'skip']].map(function (o) { return '<option value="' + o[0] + '"' + (String(t.anim) === o[0] ? ' selected' : '') + '>' + o[1] + '</option>'; }).join('') + '</select></label>';
    h += '<label class="tsel" for="tu-nev">Events a round <select id="tu-nev" data-k="nev">' + [['auto', 'by size (1 small, 2 others)'], ['0', 'none'], ['1', '1'], ['2', '2'], ['3', '3']].map(function (o) { return '<option value="' + o[0] + '"' + (String(t.nev) === o[0] ? ' selected' : '') + '>' + o[1] + '</option>'; }).join('') + '</select></label>'
      + '<label class="tchk" for="tu-br_half"><input type="checkbox" id="tu-br_half" data-k="br_half"' + (t.br_half ? ' checked' : '') + '>Halve bramble on creature pieces</label>'
      + '<label class="tchk" for="tu-big"><input type="checkbox" id="tu-big" data-k="big"' + (t.big ? ' checked' : '') + '>Every board 7×5 (size is only a look)</label>'
      + '<div class="sl">Open questions from sim 3</div><ol><li>Tougher creature bars for 6-8 turn fights, or today\'s bars and 4-5 turns?</li><li>Board size changes nothing in the numbers: keep it as a look?</li><li>Events cost little to ignore: make them hit harder?</li><li>Bramble gives away 14-21% of the creature\'s bar: halve it on creatures?</li></ol>'
      + (F && !F.s.over ? '<div class="actrow"><button type="button" class="btn primary grow" data-a="refight">↺ Restart this fight with these numbers</button></div>' : '');
    return h;
  }
  function deckSheet() {
    var s = F.s, rows = {}, add = function (t, w) { var r = rows[t.n] = rows[t.n] || { n: t.n, t: t.t, v: t.v, w: {} }; r.w[w] = (r.w[w] || 0) + 1; };
    s.me.hand.forEach(function (t) { add(t, 'hand'); }); s.me.draw.forEach(function (t) { add(t, 'draw'); }); s.me.discard.forEach(function (t) { add(t, 'discard'); });
    for (var id in s.pcs) if (s.pcs[id].by === 'me') add(s.pcs[id].tile, 'board');
    return '<div class="hrow"><h2>🧩 Your deck</h2><button type="button" class="btn small" data-a="sclose">Done</button></div><p class="note">Locked for this fight. Change it in the Puzzle box or before the next fight.</p><ul class="decklist">'
      + Object.keys(rows).sort().map(function (k) { var r = rows[k]; return '<li><span>' + esc(r.n) + ' <small>' + TYPE[r.t] + ' ' + r.v + '</small></span><small>' + Object.keys(r.w).map(function (w) { return w + (r.w[w] > 1 ? ' ×' + r.w[w] : ''); }).join(', ') + '</small></li>'; }).join('') + '</ul>';
  }
  function helpSheet() {
    var row = function (t, rot) { return '<li class="hrow2"><span class="popi">' + svg(t.g, rot || 0) + '</span><span class="popt"><b>' + t.n + '</b>' + t.l.filter(function (x) { return x !== WHEN; }).map(function (x) { return '<span>' + esc(x) + '</span>'; }).join('') + '<i>' + esc(t.who) + '</i></span></li>'; };
    var c = v1now();
    return '<div class="hrow"><h2>How the board works</h2><button type="button" class="btn small" data-a="sclose">Done</button></div>'
      + '<div class="sl">The round</div><ul class="helpl">' + row(turnText()) + '<li class="hrow2"><span class="popi">' + svg('aim') + '</span><span class="popt"><b>The creature\'s aim</b><span>The red mark is where its next piece goes. Take the cell and it has to pick again.</span></span></li>'
      + '<li class="hrow2"><span class="popi">' + svg('gust') + '</span><span class="popt"><b>Chains</b><span>A piece you place fires, then every piece linked to it.' + (c.limit ? ' A chain of ' + c.limit + ' or more uses up every piece that fired.' : '') + ' Pal, tool and crop pieces in one chain: 2 kinds +30%, all 3 +60%.</span></span></li></ul>'
      + '<div class="sl">Terrain <span>tap a ground cell</span></div><ul class="helpl">' + ['sun', 'br', 'mud'].map(function (k) { return row(terrText(k)); }).join('') + '</ul>'
      + '<div class="sl">Events <span>marked a round ahead</span></div><p class="hint" style="margin:0 0 4px">' + WHEN + '</p><ul class="helpl">' + ['sunbeam', 'creep', 'puddle', 'gust', 'thorn'].map(function (k) { return row(evText2(k)); }).join('') + '</ul>';
  }
  function drawSheet() {
    if (!ui.sheet) { sheet.hidden = true; sheet.innerHTML = ''; return; }
    sheet.hidden = false;
    sheet.innerHTML = '<button type="button" class="sheetbg" data-a="sclose" aria-label="Close"></button><div class="sheet" role="dialog" aria-label="' + (ui.sheet === 'tune' ? 'Tuning' : ui.sheet === 'help' ? 'Help' : 'Your deck') + '"><div class="sheet-in">' + (ui.sheet === 'help' ? helpSheet() : ico(ui.sheet === 'tune' ? tuneSheet() : deckSheet())) + '</div></div>';
  }
  sheet.addEventListener('input', function (ev) {
    var el = ev.target, k = el.getAttribute('data-k'); if (!k) return;
    if (el.type === 'range') { sv.tune[k] = +el.value; var r = TR.filter(function (x) { return x[0] === k; })[0], o = document.getElementById('to-' + k); if (o && r) o.textContent = r[5](+el.value); }
    else if (el.type === 'checkbox') sv.tune[k] = el.checked;
    else sv.tune[k] = el.value;
    save();
  });
  sheet.addEventListener('change', function (ev) { if (ev.target.getAttribute('data-k') && screen !== 'fight') draw(); });

  // ------------------------------------------------------------------ drawing and actions
  var SCREENS = { starter: starter, box: box, pre: pre, fight: fight, result: result };
  function draw() {
    pend = [];
    main.innerHTML = screen === 'fight' ? fight() : ico(SCREENS[screen]());
    mount(main);
    var bl = main.querySelectorAll('[data-bk]');
    if (bl.length) { var set = function () { Array.prototype.forEach.call(bl, function (b) { b.style.width = b.getAttribute('data-bw'); }); };
      Array.prototype.forEach.call(bl, function (b) { ui.barPrev[b.getAttribute('data-bk')] = b.getAttribute('data-bw'); });
      if (speed()) { void main.offsetWidth; requestAnimationFrame(set); } else set(); }
    var items = screen === 'fight' ? [['🧩', 'Deck', 'deck', 0], ['⚠️', 'Give up', 'giveup', 0], ['🔧', 'Tuning', 'tune', 0]]
      : [['🧩', 'Box', 'nbox', screen === 'box' || screen === 'starter'], ['⚔️', 'Creatures', 'npre', screen === 'pre'], ['🔧', 'Tuning', 'tune', 0]];
    nav.innerHTML = ico(items.map(function (it) { return '<a href="#" role="button" data-a="' + it[2] + '"' + (it[3] ? ' class="on" aria-current="page"' : '') + '><span aria-hidden="true">' + it[0] + '</span>' + it[1] + '</a>'; }).join(''));
    drawSheet();
  }
  function say(h) { ui.info = h; }
  var ACT = {
    // starter
    sinfo: function (id) { say(desc(PFD.byId(PFD.PIECES, id), 'core, always in')); },
    spick: function (id) { var i = ui.picked.indexOf(id); if (i >= 0) ui.picked.splice(i, 1); else if (ui.picked.length < 6) ui.picked.push(id); say(desc(PFD.byId(PFD.PIECES, id))); },
    sgear: function (id) { var p = gearPiece(id); if (p) say(desc(p, 'gear, added free')); },
    kit: function (k) { ui.picked = PFD.KITS[k].slice(); say('<span><b>' + k.charAt(0).toUpperCase() + k.slice(1) + ' kit</b> packed. Tap pieces to change it.</span>'); },
    sgo: function () { sv.kit = PFD.CORE.concat(ui.picked); sv.started = true; save(); screen = 'box'; say('<span><b>Box packed.</b> 10 kit pieces, plus your gear. Change anything here, then find a creature.</span>'); },
    restart: function () { ui.picked = sv.kit.filter(function (id) { return PFD.OFFER.indexOf(id) >= 0; }).slice(0, 6); screen = 'starter'; say(''); },
    // box and pre-fight
    tab: function (t) { ui.tab = t; say(''); },
    filt: function (f) { ui.filt = f; },
    kin: function (id) { var p = PFD.byId(PFD.PIECES, id), b = PFD.capBlock(sv, p); if (b) { say('<span><b>' + esc(b) + '</b></span>'); return; } sv.kit.push(id); save(); say(desc(p, 'packed')); },
    kout: function (id) { var p = PFD.byId(PFD.PIECES, id); sv.kit = sv.kit.filter(function (q) { return q !== id; }); save(); say(desc(p, 'taken out')); },
    dgear: function (id) { var p = gearPiece(id); if (p) say(desc(p, 'gear: change it in the box')); },
    dlock: function (id) { var p = gearPiece(id) || PFD.byId(PFD.PIECES, id); if (p) say(desc(p, 'locked (Auto deck)')); },
    btier: function (i) { sv.beltTier = +i; sv.belt = sv.belt.slice(0, PFD.BELT_SLOTS[sv.beltTier]); save(); say('<span><b>Belt ' + ['I', 'II', 'III'][sv.beltTier] + '</b>: ' + PFD.BELT_SLOTS[sv.beltTier] + ' tool slots. Belts are bought, not crafted.</span>'); },
    tool: function (id) {
      var t = PFD.byId(PFD.TOOLS, id), i = sv.belt.indexOf(id);
      if (i >= 0) { sv.belt.splice(i, 1); say(desc(t.p, 'off the belt')); }
      else { var b = PFD.capBlock(sv, t.p); if (b) { say('<span><b>' + esc(b) + '</b></span>'); return; } if (sv.belt.length >= PFD.BELT_SLOTS[sv.beltTier]) return; sv.belt.push(id); say(desc(t.p, 'on the belt')); }
      save();
    },
    tinfo: function (id) { var t = PFD.byId(PFD.TOOLS, id); say(desc(Object.assign({ gear: 1 }, t.p), t.name + ' ' + sv.dur[id] + '/' + PFD.toolMax(t))); },
    fix: function (id) { var t = PFD.byId(PFD.TOOLS, id); sv.dur[id] = PFD.toolMax(t); save(); say('<span><b>' + esc(t.name) + '</b> fixed with a crafted repair kit. Put it back on the belt.</span>'); },
    pal: function (id) {
      var q = PFD.byId(PFD.PALS, id), i = sv.party.indexOf(id);
      if (i >= 0) { sv.party.splice(i, 1); say(desc(q.p, 'left the party')); }
      else { var b = PFD.capBlock(sv, q.p); if (b) { say('<span><b>' + esc(b) + '</b></span>'); return; } if (sv.party.length >= 2) { say('<span><b>The active party holds 2 pals.</b> Take one out first.</span>'); return; } sv.party.push(id); say(desc(q.p, 'in the active party')); }
      save();
    },
    go: function (to) { screen = to; say(''); ui.cinfo = ''; },
    nbox: function () { screen = sv.started ? 'box' : 'starter'; say(''); },
    npre: function () { if (!sv.started) { say('<span><b>Pack your first box</b> before you look for a creature.</span>'); return; } screen = 'pre'; say(''); ui.cinfo = ''; },
    cr: function (slug) { sv.cr = slug; save(); ui.cinfo = ''; say(''); },
    finfo: function (i) { var c = curCreature(), p = PFD.foePieces(c)[+i]; ui.cinfo = '<span><b>' + esc(p.n) + '</b> ' + TYPE[p.t] + ' ' + foeV(c, p.v) + ' · ' + PFD.LAYERS[p.layer] + ' · stays ' + p.life + ' rounds · plays ×2' + tagText(p, true) + '</span>'; },
    auto: function () { sv.auto = !sv.auto; save(); say(''); },
    autooff: function () { sv.auto = false; save(); say(''); },
    fight: function () { if (PFD.deckCheck(sv)) { screen = 'box'; return; } startFight(); return true; },
    // fight
    hand: function (k) { if (Q.on) return true; F.pop = null; k = +k; var w = handWhy()[k]; if (w) { F.sel = null; F.cell = null; F.pv = null; F.insp = null; say('<span><b>' + esc(F.s.me.hand[k].n) + '</b> cannot be played: ' + esc(w) + '</span>'); return; } F.sel = F.sel === k ? null : k; F.cell = null; F.pv = null; F.insp = null; say(''); },
    cell: function (_, el) {
      if (F.busy || F.sel === null) return; var x = +el.getAttribute('data-x'), y = +el.getAttribute('data-y');
      if (F.cell && F.cell[0] === x && F.cell[1] === y) { doPlay(); return true; }
      var q = litCells().filter(function (c) { return c.x === x && c.y === y; })[0]; if (!q) return;
      F.cell = [x, y]; F.pv = q.pv; F.pop = null; say('');
    },
    play: function () { if (F.busy || !F.cell) return; doPlay(); return true; },
    flip: function () {
      if (F.busy || Q.on || F.sel === null || !flipFree(F.sel)) return; var t = F.s.me.hand[F.sel]; t.flip = !t.flip;
      if (F.flipTurn === F.s.turn && F.flipK === F.sel) { F.flipK = null; } else { F.flipTurn = F.s.turn; F.flipK = F.sel; }
      F.cache = null; F.cell = null; F.pv = null; say(''); ui.flipAnim = F.sel; draw(); ui.flipAnim = null; return true;
    },
    pass: function () { if (F.busy) return; doPass(); return true; },
    insp: function (id) {
      if (Q.on) { skipPlay(); return true; }
      var s = F.s, p = s.pcs[id]; if (!p) return; F.insp = +id; F.cell = null; F.pv = null; F.pop = null;
      var t = p.tile, left = p.born + (t.life || 3) - s.round, g = PFE.ter(s, p.x, p.y);
      say('<span><b>' + esc(t.n) + '</b> ' + TYPE[t.t] + ' ' + t.v + ' · ' + (p.by === 'me' ? 'yours' : esc(F.c.name) + (t.layer ? ', ' + PFD.LAYERS[t.layer].toLowerCase() : '')) + ' · ' + left + (left === 1 ? ' round left' : ' rounds left')
        + (p.by === 'foe' ? ' · plays left ' + Math.max(0, 2 - (p.f || 0)) : '') + tagText(t, p.by === 'foe') + (g ? '<br>On ' + GRN[g].toLowerCase() + ': ' + esc(terrText(g).l[0]) : '') + '</span>');
    },
    evinfo: function (k) { if (Q.on) { skipPlay(); return true; } var e = F.s.envs[+k]; if (e) F.pop = { t: 'ev', k: e.kind, rot: e.kind === 'gust' ? ROT[e.dir] : 0, y: e.y }; },
    ter: function (k, el) { if (Q.on) { skipPlay(); return true; } var y = el.getAttribute('data-y'); F.pop = { t: 'ter', k: k, y: y === null ? null : +y }; },
    turninfo: function () { F.pop = F.pop && F.pop.t === 'turn' ? null : { t: 'turn' }; },
    popx: function () { F.pop = null; },
    help: function () { ui.sheet = 'help'; },
    giveup: function () { if (!F) return; if (Q.on) { skipPlay(); if (!F) return true; } if (F.busy) return true; finish('fled'); return true; },
    skip: function () { skipPlay(); return true; },
    deck: function () { ui.sheet = 'deck'; },
    refight: function () { ui.sheet = null; stopQ(); startFight(); return true; },
    // sheets
    tune: function () { ui.sheet = 'tune'; },
    sclose: function () { ui.sheet = null; },
    treset: function () { sv.tune = {}; save(); }
  };
  function gearPiece(id) { var o = null; PFD.TOOLS.forEach(function (t) { if (t.p.id === id) o = Object.assign({ gear: 1 }, t.p); }); PFD.PALS.forEach(function (q) { if (q.p.id === id) o = Object.assign({ gear: 1 }, q.p); }); return o; }
  function onAct(ev) {
    var el = ev.target.closest('[data-a]'); if (!el || el.disabled) return;
    if (el.tagName === 'A') ev.preventDefault();
    var a = el.getAttribute('data-a'), fn = ACT[a]; if (!fn) return;
    if (el.type === 'checkbox') ev.stopPropagation();
    if (fn(el.getAttribute('data-arg'), el) !== true) draw();
  }
  document.getElementById('app').addEventListener('click', onAct);
  sheet.addEventListener('click', onAct);
  document.getElementById('b-tune').addEventListener('click', function () { ui.sheet = ui.sheet === 'tune' ? null : 'tune'; drawSheet(); });
  document.getElementById('b-theme').addEventListener('click', function () {
    var dark = root.getAttribute('data-theme') === 'dark' || (!root.getAttribute('data-theme') && matchMedia('(prefers-color-scheme: dark)').matches);
    root.setAttribute('data-theme', dark ? 'light' : 'dark');
  });
  document.addEventListener('keydown', function (ev) { if (ev.key === 'Escape' && ui.sheet) { ui.sheet = null; drawSheet(); } });

  function boot() {
    PP = window.PFParts;
    if (!PP || !PP.ok) { main.innerHTML = '<div class="box"><p class="hint">The piece art did not load.</p></div>'; return; }
    draw();
  }
  if (window.PFParts && window.PFParts.ok) boot(); else { document.addEventListener('pfparts-ready', boot); setTimeout(function () { if (!PP) boot(); }, 4000); }
  window.__demo = { Q: Q, ui: ui, save: function () { return sv; }, fight: function () { return F; }, result: function () { return RES; }, draw: draw, lit: litCells, PFE: PFE, PFD: PFD };
})();
