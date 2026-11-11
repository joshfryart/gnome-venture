/* Puzzle Combat playable example (artifact). The game's own UI scripts (pfparts.js, pfboard.js, pfx.js) run unchanged; this file plays the part of the server:
   it holds the fight state (the JS engine, tools/pfengine.js, which is checked against the PHP one), builds the same page markup pfight_board_html() builds,
   answers the "preview" request locally, and handles End turn / End fight / Try again. Built by tools/build_pf_artifact.py. */
(function () {
  'use strict';
  var ART = window.__ART, C = window.__CONSTS, PFE = window.PFE, root = document.getElementById('pfroot'), stage = document.getElementById('pfstage');
  var SRC = window.__SRC;   // the text of pfx.js, pfparts.js, pfboard.js (run again after every swap, like the site's in-place update)
  var CREATURES = [
    { slug: 'leopard-slug', name: 'Leopard Slug', size: 'small', level: 2, dmg_die: 4, dmg_bonus: 0, temper: 'gentle', blurb: 'Small and gentle. A relaxed first fight.' },
    { slug: 'thistle-beast', name: 'Thistle Beast', size: 'medium', level: 12, dmg_die: 6, dmg_bonus: 3, temper: 'hostile', blurb: 'Medium and wary. Hurt works best; Charm is slow.' },
    { slug: 'grass-snake', name: 'Grass Snake', size: 'large', level: 14, dmg_die: 8, dmg_bonus: 3, temper: 'gentle', blurb: 'Large and gentle. Charm it, or wear it down.' },
    { slug: 'black-bear', name: 'Black Bear', size: 'large', level: 25, dmg_die: 8, dmg_bonus: 6, temper: 'hostile', blurb: 'Large and wary. Hits hard; bring guard.' }
  ];
  var PLAYER = { level: 9, hp: 64, stats: { level: 9, grit: 1, nimble: 1, hardiness: 1, charm: 1, lore: 1, luck: 1 },
    box: ['swing', 'jab', 'pierce', 'sting', 'bash', 'dodge', 'brace', 'rest', 'charm', 'offer', 'hum'], mods: { swing: 'leech', charm: 'warm', dodge: 'hardy' } };
  var fight = null, selectedCreature = 0, seedN = (Date.now() % 100000) | 0, result = null, startMode = 'blank', pickedStart = null;

  // ---- the page asks for files and the preview over fetch(): answer from here (nothing else is reachable inside an artifact anyway)
  var realFetch = window.fetch;
  window.fetch = function (url, init) {
    url = String(url);
    if (url.indexOf('art/atlas.json') >= 0) return Promise.resolve({ ok: true, json: function () { return Promise.resolve(window.__ATLAS); } });
    if (url.indexOf('art/rim.json') >= 0) return Promise.resolve({ ok: true, json: function () { return Promise.resolve(window.__RIM); } });
    if (init && init.body && typeof init.body.get === 'function' && init.body.get('do') === 'pfb_preview') {
      var out = preview(init.body.get('moves'), +init.body.get('turn'));
      return Promise.resolve({ ok: true, json: function () { return Promise.resolve(out); } });
    }
    return realFetch ? realFetch.apply(window, arguments) : Promise.reject(new Error('blocked'));
  };

  function parseMoves(raw) {   // the same tokens the site posts: "i,x,y" "c,x,y" "j,a,b,SIDE" "h,b,anc,SIDE"
    var p = String(raw || '').split(','), n = function (x) { return /^\d+$/.test(x); };
    if (p.length === 3 && n(p[0]) && n(p[1]) && n(p[2])) return [[+p[0], +p[1], +p[2]]];
    if (p.length === 3 && p[0] === 'c' && n(p[1]) && n(p[2])) return [['c', +p[1], +p[2]]];
    if (p.length === 4 && (p[0] === 'j' || p[0] === 'h') && n(p[1]) && n(p[2]) && 'LRTB'.indexOf(p[3]) >= 0) return [[p[0], +p[1], +p[2], p[3]]];
    return null;
  }
  function preview(raw, turn) {
    var mv = parseMoves(raw); if (!mv || !fight) return { ok: false };
    if (fight.state.start) { var sd = typeof mv[0][0] === 'number' ? sideAt(mv[0][1], mv[0][2]) : null, st = fight.state; return sd ? { ok: true, lines: ['Start piece on the ' + SIDENAME[sd] + ' of the blank. Nothing fires; the creature picks its side too, hidden.'], bar: [st.bar.now, st.bar.now, st.bar.max], fh: [st.fh.now, st.fh.now, st.fh.max], over: null } : { ok: false }; }
    var s = JSON.parse(JSON.stringify(fight.state)), before = s.bar.now, fh0 = s.fh.now, r = PFE.play(s, mv, turn, true);
    if (r.err) return { ok: false, err: r.err };
    return { ok: true, lines: r.ev.map(function (e) { return PFE.line(e, fight.creature.name); }), bar: [before, r.bar, r.max], fh: [fh0, r.fh, r.fhmax], over: r.over || null };
  }

  function newFight(ci) {
    var cr = CREATURES[ci], seed = ++seedN * 7919 + ci;
    var deck = PFE.playerDeck(PLAYER.stats, { box: PLAYER.box });
    deck.forEach(function (t) { if (PLAYER.mods[t.k]) t.m = PLAYER.mods[t.k]; });
    var state = PFE.newFight({ hp: PLAYER.hp, max_hp: PLAYER.hp, stats: PLAYER.stats, deck: deck, luck: PLAYER.stats.luck }, cr, seed, startMode === 'blank' ? { blank: true } : {});
    pickedStart = null;
    fight = { nonce: Math.random().toString(36).slice(2, 10), state: state, creature: cr, enc: { hist: [], replay: [], snaps: {}, snapn: 0, snaplast: null, histnew: 0 } };
    result = null; render();
  }

  // ---- what pfight_do() does after pfb_play(): history chips, snapshots, replay lines
  function afterPlay(r) {
    var enc = fight.enc, s = fight.state; enc.replay = []; enc.histnew = 0;
    r.ev.forEach(function (e) {
      if (e.snap) { enc.snaps[++enc.snapn] = e.snap; enc.snaplast = enc.snapn; }
      var chip = PFE.chipEvent(e, enc.snaplast); enc.hist.push(chip);
      enc.replay.push({ id: e.id !== undefined ? e.id : null, by: e.by, ta: e.ta || e.by, ln: PFE.line(e, fight.creature.name), bar: e.barnow !== undefined ? e.barnow : null, fh: e.fhnow !== undefined ? e.fhnow : null, hp: e.hpnow !== undefined ? e.hpnow : null, g: e.gnow !== undefined ? e.gnow : null, n: e.n || '', t: e.t || '' });
    });
    enc.histnew = r.ev.length; enc.hist = enc.hist.slice(-30);
    var keep = Object.keys(enc.snaps).map(Number).sort(function (a, b) { return a - b; }).slice(-14), ns = {}; keep.forEach(function (k) { ns[k] = enc.snaps[k]; }); enc.snaps = ns;
    if (s.over === 'seen_off' || s.over === 'charmed') enc.won = s.over;
  }

  function submit(kind, raw) {
    var s = fight.state; if (s.over && kind !== 'finish') return;
    if (kind === 'play') {
      if (s.start) { doStart(raw); return; }
      var mv = parseMoves(raw); if (!mv) return;
      fight.enc.replay0 = { bar: Math.round(s.bar.now * 10) / 10, fh: Math.round(s.fh.now * 10) / 10, hp: s.me.hp, g: s.me.block };
      var r = PFE.play(s, mv, s.turn); if (r.err) { flash(r.err); return; }
      afterPlay(r); render();
    } else if (kind === 'pass') {
      fight.enc.replay0 = { bar: Math.round(s.bar.now * 10) / 10, fh: Math.round(s.fh.now * 10) / 10, hp: s.me.hp, g: s.me.block };
      var r2 = PFE.pass(s, s.turn); if (r2.err) { flash(r2.err); return; }
      afterPlay(r2); render();
    } else if (kind === 'finish') { result = { kind: s.over, turns: s.turn }; render(); }
  }
  function flash(t) { var p = document.getElementById('pf-preview'); if (p) p.textContent = t; }

  // ---- markup (a port of pfight_board_html / pfight_bar_html / pfight_board_piece_html)
  function esc(x) { return String(x === null || x === undefined ? '' : x).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; }); }
  var ICON = { hurt: '⚔️', guard: '🛡️', heal: '💚', charm: '🌸', soothe: '😌', trick: '🎭', item: '🎒' };
  function img(file, cls) { return ART[file] ? '<img class="' + cls + '" src="' + ART[file] + '" alt="">' : null; }
  function sm(t) { return img('ico-' + t + '-s.png', 'pfh-ico') || '<span class="pfh-emo" aria-hidden="true">' + ICON[t] + '</span>'; }
  function edgeSpan(edge, side) { var fam = { body: 'B', mind: 'M', craft: 'C' }; return '<span class="pfe s' + side + ' ' + (edge[0] === 'flat' ? 'flat f-flat' : edge[0] + ' f-' + edge[1]) + '" aria-hidden="true">' + (fam[edge[1]] || '·') + '</span>'; }
  function pieceHtml(t, i) {
    var tg = C.tags[t.tag] || null, md = C.mods[t.m] || null, ed = '';
    ['L', 'R', 'T', 'B'].forEach(function (sd) { ed += edgeSpan(t.e[sd], sd); });
    var label = t.n + ', ' + t.t + ' ' + t.v + '; edges: ' + ['L', 'R', 'T', 'B'].map(function (sd) { return sd + ' ' + (t.e[sd][0] === 'flat' ? 'flat' : t.e[sd][0] + ' ' + t.e[sd][1]); }).join(', ') + (tg ? '; ' + tg[1] : '') + (md ? '; upgrade ' + md[0] + ': ' + md[2] : '');
    var desc = t.t.charAt(0).toUpperCase() + t.t.slice(1) + ' ' + t.v + (tg ? '. ' + tg[1] : '') + (md ? '. Upgrade ' + md[0] + ': ' + md[2] : '');
    return '<button type="button" class="pf-tile pf-h pf-bp pf-' + esc(t.t) + '" data-i="' + i + '" data-t="' + esc(t.t) + '" data-tag="' + esc(t.tag || '') + '" data-mod="' + esc(t.m || '') + '" data-v="' + t.v + '" data-name="' + esc(t.n) + '" data-desc="' + esc(desc) + '" aria-label="' + esc(label) + '" aria-pressed="false" draggable="true">'
      + ed + '<span class="pf-ico" aria-hidden="true">' + ICON[t.t] + '</span><span class="pf-nm">' + esc(t.n) + '</span><span class="pf-val">' + t.v + '</span></button>';
  }
  function guardHtml(g) { return '<span class="pf-guard' + (g > 0 ? '' : ' pf-guard-0') + '" role="img" aria-label="Guard ' + g + ': blocks the creature\u2019s hits until your next turn" title="Guard: blocks the creature\u2019s hits until your next turn"><span class="pfx-fill gfill" data-w="' + Math.min(100, Math.round(g * 100 / 16)) + '"></span><b>' + g + '</b></span>'; }
  function barHtml(v) {
    var b = v.bar, max = Math.max(0.1, b.max), now = b.now, fm = Math.max(0.1, v.fh.max), left = Math.max(0, fm - v.fh.now);
    var hpLabel = 'Creature health: ' + Math.ceil(left) + ' of ' + Math.ceil(fm) + ' left. Hurt pieces take it down; at 0 it backs off.';
    var h = '<div class="pf-bars"><span class="pf-fhp" role="img" aria-label="' + esc(hpLabel) + '" title="Creature health. Hurt pieces take it down; at 0 it backs off."><span class="pfx-fill fhfill" data-w="' + (Math.round(1000 * left / fm) / 10) + '"></span><b>' + Math.ceil(left) + '</b></span>';
    if (v.charmable) {
      var label = 'Charm bar: fill it to win the creature over for a better reward. Only Charm pieces fill it. ' + Math.round(now) + ' of ' + Math.round(max);
      h += '<div class="pf-bar pfx-bar" role="img" aria-label="' + esc(label) + '"><span class="pfx-fill charm" data-w="' + (Math.round(1000 * Math.min(1, now / max)) / 10) + '"></span><img class="pfx-frame" src="' + ART['resolve-frame.png'] + '" alt=""></div>';
    }
    return h + '</div>';
  }
  function who(by, cr) { return by === 'me' ? '<span class="pfh-gn pfh-gn25" aria-hidden="true"><img src="' + ART['gnome-side.png'] + '" alt=""></span>' : '<img class="pfh-cr" src="' + ART['mini-' + cr.slug + '.png'] + '" alt="">'; }

  function build() {
    var s = fight.state, cr = fight.creature, enc = fight.enc, v = PFE.view(s);
    var h = '<div class="pfight pf-screen pf-boardmode pfx-art" id="pfight" data-turn="' + v.turn + '" data-mode="board" data-redraws="0">';
    var hist = enc.hist, nNew = enc.histnew || 0, total = hist.length, pending = !!(enc.replay && enc.replay.length), usedSn = {}, hh = '';
    for (var hi = total - 1; hi >= 0; hi--) {
      var chip = hist[hi], evIdx = hi - (total - nNew), isNew = nNew > 0 && evIdx >= 0, sn = chip.sn !== null && chip.sn !== undefined && enc.snaps[chip.sn] ? chip.sn : null;
      if (sn !== null) usedSn[sn] = enc.snaps[sn];
      var nm = 'the ' + cr.name, tgw = chip.tg === 'me' ? 'you' : nm;
      var label = (chip.by === 'me' ? 'You' : nm.charAt(0).toUpperCase() + nm.slice(1)) + ': ' + chip.types.join(', ') + ', ' + chip.txt + (chip.tg ? ', on ' + tgw : '') + (sn !== null ? '. Press to see the board then.' : '');
      hh += '<li class="pf-chip ' + (chip.by === 'me' ? 'you' : 'foe') + (isNew ? ' pf-chip-new' : '') + (sn !== null ? ' pf-chip-rw' : '') + '"' + (isNew ? ' data-ev="' + evIdx + '"' + (pending ? ' hidden' : '') : '')
        + (sn !== null ? ' data-sn="' + sn + '" data-id="' + (chip.id || 0) + '" data-bar="' + esc(chip.bar === null || chip.bar === undefined ? '' : chip.bar) + '" data-fh="' + esc(chip.fh === null || chip.fh === undefined ? '' : chip.fh) + '" data-hp="' + esc(chip.hp === null || chip.hp === undefined ? '' : chip.hp) + '" role="button" tabindex="0"' : '') + ' aria-label="' + esc(label) + '">' + who(chip.by, cr);
      chip.types.forEach(function (t, ci) { var tg = chip.tags[ci] || '', ti = C.tagIcon[tg] ? img('ico-' + C.tagIcon[tg] + '-s.png', 'pfh-ico') : null; hh += ti || sm(t); });
      hh += ' <span class="pfh-txt">' + esc(chip.txt) + '</span>' + (chip.tg ? who(chip.tg, cr) : '') + '</li>';
    }
    if (!hist.length) hh = '<li class="pf-chip empty">' + esc(enc.note || (s.start ? 'Opening: the blank \u2726 is in the middle. The creature picks its side too, hidden.' : 'Pieces are on the board. Place one next to them.')) + '</li>';
    var mini = function (cls, name, n) { return '<span class="pfc-pile ' + cls + '" role="img" aria-label="' + name + ': ' + n + ' pieces"><img src="' + ART[cls === 'deck' ? 'deck-book.png' : 'discard-bin.png'] + '" alt=""><b>' + n + '</b></span>'; };
    var top = '<div class="pfc-top"><div class="pfc-me"><span class="pfc-meav"><span class="pfc-av pfc-g25"><img src="' + ART['gnome-side.png'] + '" alt="Your gnome"></span>' + guardHtml(v.block) + '</span><span class="pf-hp" role="img" aria-label="Your health ' + v.hp + ' of ' + v.max + '' + '">❤️ <progress max="' + v.max + '" value="' + v.hp + '"></progress> ' + v.hp + '' + '</span></div>'
      + barHtml(v)
      + '<div class="pfc-foe"><span class="pfc-fname"><b>' + esc(cr.name) + '</b><small>lv ' + cr.level + ' · ' + (s.temper === 'gentle' ? 'gentle' : 'wary') + ' · 🃏 ' + v.foe.hand + (v.foe.calm ? ' · 😌 ' + v.foe.calm : '') + '</small></span><span class="pfc-av"><img src="' + ART['mini-' + cr.slug + '.png'] + '" alt="' + esc(cr.name) + '"><span class="pf-intent-bubble" title="Likely next move" aria-label="Likely next move: ' + esc(v.foe.intent) + '">' + (v.foe.intent ? sm(v.foe.intent) : '') + '</span></span></div></div>';
    h += top + '<div class="pfc-histrow"><ol class="pf-hist" aria-label="What has been played" aria-live="polite">' + hh + '</ol><button type="button" class="btn" id="pf-skip" hidden>Skip</button><span class="pfc-piles">' + mini('deck', 'Puzzle book', v.piles.draw) + mini('disc', 'Discard', v.piles.discard) + '</span></div>';
    h += '<div class="pf-rewind" id="pf-rewind" role="status" hidden><span id="pf-rw-t"></span><button type="button" class="btn" id="pf-rw-back">Back to now</button></div>';
    h += '<div class="pfb-board" id="pfb-board" role="group" aria-label="The play area: pick a piece from your hand, then a lit spot. Scroll, pinch or use the zoom buttons to zoom"></div>';
    h += '<div class="pf-opts" id="pf-opts" hidden></div><p class="pf-preview help" id="pf-preview" aria-live="polite">' + (s.start ? 'Opening: pick a piece, then a side of \u2726. Nothing fires.' : blankOut(s) ? 'The blank \u2726 connects to everything but fires nothing. It is gone after this turn. Pick a piece, then a lit spot.' : 'Pick a piece, then a lit spot.') + '</p><ol class="pf-plan" id="pf-plan" aria-live="polite" hidden></ol>';
    h += '<form class="pf-form" id="pf-form"><input type="hidden" name="do" value="pfb_play"><input type="hidden" name="nonce" value="' + fight.nonce + '"><input type="hidden" name="turn" value="' + v.turn + '"><input type="hidden" name="moves" id="pf-moves" value=""></form>';
    var won = !!enc.won && (s.over === 'seen_off' || s.over === 'charmed'), lost = s.over === 'defeat' || s.over === 'stall';
    if (won) h += '<div class="pf-won" role="status"><b>' + (s.over === 'charmed' ? 'The ' + esc(cr.name) + ' is charmed!' : 'The ' + esc(cr.name) + ' has had enough.') + '</b> <form class="inline pf-endform"><button class="btn primary" id="pf-end">End fight</button></form></div><button type="button" class="btn" id="pf-undo" hidden></button><button class="btn" id="pf-go" form="pf-form" hidden></button>';
    else if (lost) h += '<div class="pf-won pf-lost" role="status"><b>' + (s.over === 'defeat' ? 'The ' + esc(cr.name) + ' knocks you flat.' : 'The ' + esc(cr.name) + ' loses interest and wanders off.') + '</b> <button type="button" class="btn primary" id="pf-again">Try again</button></div><button type="button" class="btn" id="pf-undo" hidden></button><button class="btn" id="pf-go" form="pf-form" hidden></button>';
    else h += '<div class="pf-buttons"><button type="button" class="btn" id="pf-undo" disabled>Undo</button><button class="btn primary" id="pf-go" form="pf-form" disabled>' + (s.start ? 'Confirm start' : 'End turn') + '</button></div>';
    h += '<div class="pf-tray"><div class="pf-hand" id="pf-hand" role="group" aria-label="Your hand">';
    v.hand.forEach(function (t, i) { h += pieceHtml(t, i); });
    h += '</div></div><div class="pf-inspect" id="pf-inspect" aria-live="polite" hidden><span class="pfi-art" id="pfi-art" aria-hidden="true"></span><span class="pf-itext"><b id="pfi-name"></b><br><span id="pfi-desc"></span></span><button type="button" class="pfi-x" id="pfi-x" aria-label="Close">✕</button></div>';
    h += '<div class="pf-extra"><form class="inline" id="pf-pform" hidden><button class="btn" id="pf-pass">Pass (nothing fits)</button></form></div>';
    var seen = {}; v.hand.forEach(function (t) { if (C.tags[t.tag]) seen[t.tag] = 1; });
    if (Object.keys(seen).length) { h += '<details class="pfc-more"><summary>More: piece tips</summary><ul class="pf-tags help">'; Object.keys(seen).forEach(function (x) { h += '<li>' + C.tags[x][0] + ' ' + esc(C.tags[x][1]) + '</li>'; }); h += '</ul></details>'; }
    var data = { foe: cr.name, won: won ? s.over : null, life: C.life, tags: C.tags, held: v.held || null, gone: v.gone || [], snaps: usedSn, bar: v.bar.now, barmax: v.bar.max, fh: v.fh.now, fhmax: v.fh.max, charmable: !!v.charmable, hp: v.hp, guard: v.block, replay: enc.replay || [], replay0: enc.replay0 || null,
      mods: Object.keys(C.mods).reduce(function (o, k) { o[k] = [C.mods[k][1], C.mods[k][0], C.mods[k][3], C.mods[k][2]]; return o; }, {}), art: 'art/', fx: v.fx || [], tint: tintOf(cr.slug), parts: 'art/', w: v.w, h: v.h, pcs: v.pcs,
      hand: v.hand.map(function (t) { return { e: t.e, t: t.t, tag: t.tag, m: t.m }; }), combos: v.combos, icons: ICON };
    h += '<script type="application/json" id="pf-data">' + JSON.stringify(data).replace(/</g, '\\u003c') + '</script></div>';
    return h;
  }
  function tintOf(slug) { var c = 0xFFFFFFFF, i, k; var tb = crcTable(); for (i = 0; i < slug.length; i++) c = tb[(c ^ slug.charCodeAt(i)) & 255] ^ (c >>> 8); return ((c ^ 0xFFFFFFFF) >>> 0) % 360; }
  var _crc; function crcTable() { if (_crc) return _crc; _crc = []; for (var n = 0; n < 256; n++) { var c = n; for (var k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1; _crc[n] = c >>> 0; } return _crc; }

  function runScripts() {
    ['pfx', 'pfparts', 'pfboard'].forEach(function (k) {   // the game's own scripts, run again after every swap (inline script elements: no eval)
      var sc = document.createElement('script'); sc.textContent = '(function(){try{' + SRC[k] + '\n}catch(e){console.error("' + k + '",e)}})();'; document.body.appendChild(sc); document.body.removeChild(sc);
    });
    var form = document.getElementById('pf-form');
    if (form) form.addEventListener('submit', function (e) { e.preventDefault(); var m = document.getElementById('pf-moves'); if (m && m.value) submit('play', m.value); });   // runs after pfboard.js's own handler, which has filled in the move
    var pf = document.getElementById('pf-pform'); if (pf) pf.addEventListener('submit', function (e) { e.preventDefault(); submit('pass'); });
    var en = document.querySelector('.pf-endform'); if (en) en.addEventListener('submit', function (e) { e.preventDefault(); submit('finish'); });
    var ag = document.getElementById('pf-again'); if (ag) ag.addEventListener('click', function () { newFight(selectedCreature); });
  }

  // ---- blank-centre start (the variant under test): the normal fight screen with only the blank on the board; the four sides of the blank are the lit spots
  function blankOut(s) { return !!(s.pcs && s.pcs[1] && s.pcs[1].by === 'none'); }
  var SIDENAME = { L: 'left', R: 'right', T: 'top', B: 'bottom' };
  function sideAt(x, y) { var cx = PFE.W >> 1, cy = PFE.H >> 1, dx = x - cx, dy = y - cy; if (Math.abs(dx) + Math.abs(dy) !== 1) return null; return dx < 0 ? 'L' : dx > 0 ? 'R' : dy < 0 ? 'T' : 'B'; }
  function doStart(raw) {   // the move the page posts ("hand,x,y") becomes the hidden start: that hand piece on that side of the blank
    var s = fight.state, mv = parseMoves(raw), side = mv && typeof mv[0][0] === 'number' ? sideAt(mv[0][1], mv[0][2]) : null;
    if (!side) { flash('Pick a spot next to the blank.'); return; }
    var mine = s.me.hand[mv[0][0]], err = PFE.start(s, mv[0][0], side); if (err) { flash(err); return; }
    var cx = PFE.W >> 1, cy = PFE.H >> 1, sideOf = function (p) { var dx = p.x - cx, dy = p.y - cy; return dx < 0 ? 'left' : dx > 0 ? 'right' : dy < 0 ? 'top' : 'bottom'; }, foe = [];
    Object.keys(s.pcs).forEach(function (id) { var q = s.pcs[id]; if (q.by === 'foe') foe.push('the ' + fight.creature.name + ' put ' + q.tile.n + ' (' + q.tile.t + ' ' + q.tile.v + ') on the ' + sideOf(q)); });
    fight.enc.note = 'You put ' + mine.n + ' on the ' + SIDENAME[side] + '; ' + foe.join(', ') + '. Turn 1: place a piece.';
    render();
  }

  function render() {
    if (result) { stage.innerHTML = resultHtml(); bindResult(); return; }
    stage.innerHTML = build(); runScripts();
    if (fight.state.start) {   // the game's own hint says "End turn"; in the opening the button reads "Confirm start"
      var pv = document.getElementById('pf-preview'), fixing = false;
      if (pv && window.MutationObserver) new MutationObserver(function () { if (fixing || pv.textContent.indexOf('End turn') < 0) return; fixing = true; pv.textContent = pv.textContent.replace('End turn', 'Confirm start'); fixing = false; }).observe(pv, { childList: true, characterData: true, subtree: true });
    }
  }
  function resultHtml() {
    var cr = fight.creature, s = fight.state, charmed = result.kind === 'charmed';
    return '<div class="pfresult"><img src="' + ART['mini-' + cr.slug + '.png'] + '" alt="" class="pfr-cr"><h2>' + (charmed ? 'You won the ' + esc(cr.name) + ' over.' : 'You saw off the ' + esc(cr.name) + '.') + '</h2>'
      + '<p>' + (charmed ? 'Charmed: full experience and a gift from the creature.' : 'Seen off: experience, and whatever it dropped.') + ' It took ' + (result.turns - 1) + ' turns.</p>'
      + '<p class="muted">In the real game the chest scene plays here and the loot is drawn into your satchel.</p><div class="pfr-btns"><button class="btn primary" id="pfr-again">Fight again</button><button class="btn" id="pfr-pick">Pick another creature</button></div></div>';
  }
  function bindResult() { document.getElementById('pfr-again').addEventListener('click', function () { newFight(selectedCreature); }); document.getElementById('pfr-pick').addEventListener('click', function () { result = null; window.scrollTo(0, 0); newFight(selectedCreature); }); }

  // ---- the page around the fight: creature picker, how it works
  var pick = document.getElementById('pfpick');
  CREATURES.forEach(function (c, i) {
    var b = document.createElement('button'); b.type = 'button'; b.className = 'pfpick-b' + (i === 0 ? ' on' : ''); b.setAttribute('aria-pressed', i === 0 ? 'true' : 'false');
    b.innerHTML = '<img src="' + ART['mini-' + c.slug + '.png'] + '" alt=""><span><b>' + esc(c.name) + '</b><small>' + esc(c.blurb) + '</small></span>';
    b.addEventListener('click', function () { selectedCreature = i; Array.prototype.forEach.call(pick.children, function (x, j) { x.classList.toggle('on', j === i); x.setAttribute('aria-pressed', j === i ? 'true' : 'false'); }); newFight(i); });
    pick.appendChild(b);
  });
  document.getElementById('pfrestart').addEventListener('click', function () { newFight(selectedCreature); });
  Array.prototype.forEach.call(document.querySelectorAll('input[name=pfstart]'), function (r) { r.addEventListener('change', function () { if (r.checked) { startMode = r.value; newFight(selectedCreature); } }); });
  newFight(0);
})();
