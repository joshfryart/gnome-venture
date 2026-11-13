/* v1 playable demo: the deck model (JS port of game/includes/pfdeck.php, the pure part and the POST actions) over a sample gnome kept in memory.
   The data tables (pieces, classes, creature decks) are the game's own, dumped by tools/pfdemo_v1/dump_data.php at build time. No DOM: also used by tools/pfdemo_v1/bot.js in node. */
(function (root, factory) {
  var isNode = typeof module === 'object' && module && module.exports;
  var api = factory(isNode ? require(process.env.PFE_PATH) : root.PFE, isNode ? JSON.parse(require('fs').readFileSync(process.env.PFD_DATA, 'utf8')) : root.__DATA);
  if (isNode) module.exports = api; else root.PFD = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function (PFE, D) {
  'use strict';
  var C = D.consts, FAM = ['body', 'mind', 'craft'], PLAYER_SRC = ['basic', 'knack', 'calling', 'tool', 'crop', 'craft', 'region'];
  var SRC_FAM = { pal: 'body', tool: 'craft', crop: 'mind', craft: 'craft' }, UP = { hurt: 1, charm: 1, trick: 1 }, HOLE = PFE.HOLE;
  var PFB_LIFE = 3, TEAM_SRC = ['pal', 'tool', 'crop'];

  function piece(key) { return D.catalog[String(key).split('#')[0]] || null; }
  function durMax(tier) { return C.durBase + C.durRank * (Math.max(1, Math.min(4, tier)) - 1); }
  function offerKeys(calling, home, list) {
    var cal = D.callingTile[calling] || 'taunt', reg = D.catalog['r:' + home] ? 'r:' + home : 'r:NA';
    return (list || C.offer).map(function (k) { return k === 'CALLING' ? cal : (k === 'r:HOME' ? reg : k); });
  }
  function starterCheck(picks, calling, home) {
    var offer = offerKeys(calling, home);
    if (picks.length !== C.picks || new Set(picks).size !== C.picks) return 'Pick exactly ' + C.picks + ' pieces.';
    for (var i = 0; i < picks.length; i++) if (offer.indexOf(picks[i]) < 0) return 'Pick from the pieces on offer.';
    var hurt = 0; C.core.concat(picks).forEach(function (k) { if ((piece(k) || {}).t === 'hurt') hurt++; });
    return hurt < 3 ? 'Bring at least three Hurt pieces.' : null;
  }
  /** The sample gnome's sources (the shape of pfd_sources_blank): what it owns. level = the level its pieces were unlocked at (values use the fight's level). */
  function blank() {
    return { level: 14, calling: 'thornblade', ctier: 1, home: 'NA', starter: null, state: {}, tools: { till: 3, staff: 2, lantern: 4, rod: 1, axe: 2, net: 1, prune: 3 }, belt: null, slots: 2, wear: { lantern: 6, axe: 14 },
      pals: [{ n: 'Bark Badger', t: 'guard', v: 8, r: 'craft', rank: 2, ref: 'badger' }, { n: 'Acorn Nip', t: 'heal', v: 6, r: 'mind', rank: 1, ref: 'acorn' }],
      crops: { grain: 2, herb: 1, fruit: 2, spice: 3, nut: 1, legume: 2 }, crafts: { cooking: 2, garden: 3, potions: 2 }, regions: { NA: 2, SE: 2, MENA: 2 }, auto: false, repair: 3, beltTier: 1 };
  }
  function belt(src) {
    var b = src.belt;
    if (b === null || b === undefined) {   // never set: the best tools the gnome has, as many as the belt holds
      var types = Object.keys(src.tools), order = {}; types.forEach(function (t, i) { order[t] = i; });
      types.sort(function (a, c) { return (src.tools[c] - src.tools[a]) || (order[a] - order[c]); });
      b = types.filter(function (t) { return durMax(src.tools[t]) > (src.wear[t] || 0); }).slice(0, src.slots);
    }
    return b.map(function (type, i) {
      var tier = src.tools[type] || 0, max = durMax(Math.max(1, tier)), wear = Math.min(max, Math.max(0, src.wear[type] || 0));
      return { type: type, tier: tier, max: max, wear: wear, left: max - wear, state: tier < 1 ? 'none' : (wear >= max ? 'broken' : (i >= src.slots ? 'over' : 'ok')) };
    });
  }
  function validate(c) {
    if (c.kit < C.kitMin) return 'Pack at least ' + C.kitMin + ' kit pieces.';
    if (c.hurt < 1) return 'Bring at least one Hurt piece (the great creatures cannot be charmed).';
    if (c.rare > C.rareCap) return 'At most ' + C.rareCap + ' Rare pieces a deck. Take one out first.';
    if (c.mw > C.mwCap) return 'At most ' + C.mwCap + ' Masterwork piece a deck. Take the other one out first.';
    return null;
  }
  /** pfd_build: every piece the gnome could bring (kit first, then gear), the deck a fight uses, counts, the error. */
  function build(src) {
    var lvl = src.level, cal = src.calling, chosen = Array.isArray(src.starter);
    var starter = chosen ? src.starter.slice() : C.core.concat(offerKeys(cal, src.home, C.kits.bold));
    var rankOf = function (p) {
      if (p.rar !== 'src') return +p.rar;
      var have = { crop: src.crops, craft: src.crafts, region: src.regions, tool: src.tools }[p.src] || {};
      return Math.max(1, Math.min(4, have[p.ref] || 1));
    };
    var owned = function (p) {
      switch (p.src) {
        case 'basic': return p.k !== 'breather'; case 'knack': return lvl >= +p.ref; case 'calling': return p.ref !== '' && p.ref === cal;
        case 'crop': return !!src.crops[p.ref]; case 'craft': return !!src.crafts[p.ref]; case 'region': return !!src.regions[p.ref];
      }
      return false;
    };
    var entry = function (key, p, rank, x) {
      var e = { key: key, k: p.k, n: p.n, t: p.t, v: +p.v, r: p.r, tag: p.tag || '', src: p.src, ref: p.ref || '', rank: rank,
        life: (p.life | 0) || (rank >= 4 ? 4 : (p.tag === 'quick' ? 2 : (p.tag === 'hold' ? 4 : PFB_LIFE))), blurb: p.blurb || '', gear: false, tool: '', starter: false, core: false, on: false, out: '' };
      if (p.col !== undefined && p.col !== null) e.col = p.col; if (p.up !== undefined && p.up !== null) e.up = p.up;
      for (var f in x) e[f] = x[f]; return e;
    };
    var pieces = [], seen = {};
    starter.forEach(function (key) {
      var p = piece(key); if (!p || seen[key] || p.src === 'tool') return; seen[key] = 1;
      pieces.push(entry(key, p, rankOf(p), { starter: true, core: C.core.indexOf(key) >= 0, on: src.state[key] === undefined ? true : !!src.state[key] }));
    });
    Object.keys(D.catalog).forEach(function (key) {
      var p = D.catalog[key]; if (seen[key] || PLAYER_SRC.indexOf(p.src) < 0 || !owned(p)) return;
      pieces.push(entry(key, p, rankOf(p), { on: src.state[key] === undefined ? ['crop', 'craft', 'region'].indexOf(p.src) >= 0 : !!src.state[key] }));
    });
    var bl = belt(src);
    bl.forEach(function (b) { var p = D.catalog['t:' + b.type]; if (!p || b.state !== 'ok') return; pieces.push(entry('t:' + b.type, p, rankOf(p), { gear: true, tool: b.type, on: true })); });
    src.pals.forEach(function (q) {
      var key = 'pal:' + q.n; if (seen[key]) return; seen[key] = 1;
      pieces.push(entry(key, { k: key, n: q.n, t: q.t, v: q.v, r: q.r || null, tag: 'pal', src: 'pal', ref: q.ref || '', life: 0 }, Math.max(1, Math.min(3, q.rank || 1)), { gear: true, on: true }));
    });
    var cnt = { n: 0, kit: 0, belt: 0, pals: 0, hurt: 0, rare: 0, mw: 0, src: { pal: 0, tool: 0, crop: 0 } };
    pieces.forEach(function (e) {
      if (!e.on) return;
      if (e.rank === 3 && ++cnt.rare > C.rareCap) e.out = 'cap'; if (e.rank === 4 && ++cnt.mw > C.mwCap) e.out = 'cap';
      cnt.n++; if (!e.gear) cnt.kit++; if (e.t === 'hurt') cnt.hurt++; if (e.src === 'tool') cnt.belt++; if (e.src === 'pal') cnt.pals++;
      if (cnt.src[e.src] !== undefined) cnt.src[e.src]++;
    });
    cnt.team = TEAM_SRC.filter(function (k) { return cnt.src[k]; }).length;
    return { pieces: pieces, deck: pieces.filter(function (e) { return e.on && e.out === ''; }), counts: cnt, err: validate(cnt), starter: chosen, offer: offerKeys(cal, src.home),
      kits: { bold: offerKeys(cal, src.home, C.kits.bold), steady: offerKeys(cal, src.home, C.kits.steady), kind: offerKeys(cal, src.home, C.kits.kind) }, belt: bl, slots: src.slots, auto: !!src.auto };
  }
  function fightEntries(src) {
    var b = build(src);
    if (b.counts.kit >= C.kitMin && b.counts.hurt >= 1) return b.deck;
    var s2 = Object.assign({}, src, { starter: null, state: {} }); return build(s2).deck;
  }
  function authorEdges(t, r, col, up) {
    if (up === undefined || up === null) up = !!UP[t];
    var fam = HOLE[t] || 'body';
    return { L: ['hole', fam], R: ['knob', r || fam], T: [up ? 'knob' : 'hole', col], B: [up ? 'hole' : 'knob', col] };
  }
  function edges(e) { return authorEdges(e.t, e.r, e.col || SRC_FAM[e.src] || HOLE[e.t] || 'body', e.up !== undefined && e.up !== null ? !!e.up : null); }
  /** Engine tiles from deck entries (pfd_tiles). */
  function tiles(entries, stats, typeBonus, calling, ctier) {
    typeBonus = typeBonus || {};
    return entries.map(function (e) {
      var b = (typeBonus[e.t] || 0) + (calling === 'bloomcaller' && (e.t === 'charm' || e.t === 'soothe') ? 2 : 0);
      if (e.src === 'calling') b += Math.max(0, ctier - 1) * 2;
      if (e.src !== 'pal') b += C.rankBonus[e.rank] || 0;
      var over = { n: e.n, t: e.t, v: e.v, r: e.r, tag: e.tag, src: e.src, life: e.life, rank: e.rank };
      if (e.col !== undefined) over.col = e.col; if (e.up !== undefined) over.up = e.up; if (e.tool) over.tool = e.tool;
      return PFE.makeTile(e.k, stats, b, over);
    });
  }
  // ---- the gnome in memory (the demo's "database"): sources + the deck + locks
  var Beltslots = [2, 3, 4];
  function wearAll(src) {
    var out = {}; Object.keys(src.tools).concat(Object.keys(src.wear)).forEach(function (type) {
      if (out[type]) return; var tier = src.tools[type] || 0, max = durMax(Math.max(1, tier)), w = Math.min(max, Math.max(0, src.wear[type] || 0));
      out[type] = { tier: tier, max: max, wear: w, left: max - w, broken: w >= max };
    });
    return out;
  }
  function deck(src) { var b = build(src); b.belt_tier = src.beltTier || 1; return b; }
  /** The POST actions (pfd_post). Returns [ok, message]. $in = {kit, pick[], key, on, tool, slot}. */
  function post(src, locked, doo, input) {
    var err = null;
    if (doo === 'pfd_auto') { src.auto = String(input.on) === '1'; return [true, 'Saved.']; }
    if (locked) return [false, 'You are in a fight. The deck is locked until it is over.'];
    if (doo === 'pfd_starter') {
      var picks = input.kit ? (C.kits[input.kit] ? offerKeys(src.calling, src.home, C.kits[input.kit]) : null) : (input.pick || []).map(String);
      if (Array.isArray(src.starter)) err = 'You have already packed your first Puzzle box.';
      else if (!picks) err = 'There is no such kit.';
      else if (!(err = starterCheck(picks, src.calling, src.home))) { src.starter = C.core.concat(picks); src.state = {}; src.starter.forEach(function (k) { src.state[k] = true; }); }
    } else if (doo === 'pfd_toggle') {
      var b = build(src), e = null; b.pieces.forEach(function (x) { if (x.key === input.key) e = x; });
      if (!e) err = 'You do not own that piece.';
      else if (e.gear) err = e.src === 'tool' ? 'Tool pieces follow your fight belt.' : 'Pal pieces follow your party.';
      else {
        var on = input.on === undefined || input.on === '' ? !e.on : String(input.on) === '1';
        if (on !== e.on) { var s2 = Object.assign({}, src, { state: Object.assign({}, src.state) }); s2.state[input.key] = on; var nb = build(s2); if (nb.err !== null && (b.err === null || !on)) err = nb.err; else src.state[input.key] = on; }
      }
    } else if (doo === 'pfd_equip') {
      var type = input.tool, slots = src.slots;
      if (!D.catalog['t:' + type]) err = 'That is not a fight tool.';
      else if ((src.tools[type] || 0) < 1) err = 'You do not have that tool.';
      else if (durMax(src.tools[type]) <= (src.wear[type] || 0)) err = 'That tool is worn out. Fix it with a Tool Repair Kit first.';
      else {
        var bt = belt(src).map(function (x) { return x.type; }).slice(0, slots);
        if (bt.indexOf(type) < 0) {
          if (bt.length >= slots) err = 'Your belt is full (' + slots + ' tools). Take one off first.';
          else { bt.push(type); var s3 = Object.assign({}, src, { belt: bt }), nb2 = build(s3); if (nb2.err !== null && build(src).err === null) err = nb2.err; else src.belt = bt; }
        }
      }
    } else if (doo === 'pfd_unequip') {
      var cur = belt(src).map(function (x) { return x.type; });
      if (cur.indexOf(input.tool) < 0) err = 'That tool is not on your belt.'; else src.belt = cur.filter(function (t) { return t !== input.tool; });
    } else if (doo === 'pfd_fix') {
      var w = wearAll(src)[input.tool];
      if (!w || w.wear < 1) err = 'That tool needs no fixing.';
      else if ((src.repair || 0) < 1) err = 'You need a Tool Repair Kit (craft one from flint, pine resin and coir fibre).';
      else { src.repair--; src.wear[input.tool] = 0; }
    } else err = 'Unknown action.';
    var ok = { pfd_starter: 'Puzzle box packed.', pfd_toggle: 'Deck changed.', pfd_equip: 'Tool on your belt.', pfd_unequip: 'Tool off your belt.', pfd_fix: 'Tool fixed.' };
    return [err === null, err === null ? (ok[doo] || 'Done.') : err];
  }
  /** A fight is over: its tool wear is saved (pfd_wear_add). Returns the tool types that broke. */
  function wearAdd(src, wear) {
    var broke = [], before = wearAll(src);
    Object.keys(wear || {}).forEach(function (type) {
      var n = +wear[type]; if (n <= 0 || !D.catalog['t:' + type]) return;
      var b = before[type] || { max: durMax(1), wear: 0 }, nw = Math.min(b.max, b.wear + n); src.wear[type] = nw; if (b.wear < b.max && nw >= b.max) broke.push(type);
    });
    return broke;
  }
  function wearRows(src, s) {   // pfv_wear_rows: after the wear was saved
    var rows = [], w = wearAll(src);
    Object.keys(s.wear || {}).forEach(function (type) {
      var pts = +s.wear[type]; if (pts <= 0 || !D.catalog['t:' + type]) return;
      var x = w[type] || { max: durMax(1), left: 0, broken: true, tier: 1 };
      rows.push({ type: type, n: D.catalog['t:' + type].n, plays: Math.floor(pts / Math.max(1, C.toolWear)), cost: pts, left: x.left, max: x.max, broke: !!x.broken, tier: Math.max(1, x.tier) });
    });
    return rows;
  }
  /** The fight's gnome (the sim's default gnome at a level: flat stats, health 20 + 3 x level + 5 x stat). */
  function gnome(lv) { lv = Math.max(1, lv); var m = Math.max(0, Math.floor((lv + 3) / 14)); return { level: lv, max: 20 + 3 * lv + 5 * m, stats: { grit: m, nimble: m, hardiness: m, charm: m, lore: m, luck: m, level: lv } }; }
  function creature(slug) { for (var i = 0; i < D.creatures.length; i++) if (D.creatures[i].slug === slug) return D.creatures[i]; return D.creatures[0]; }

  return { D: D, C: C, piece: piece, durMax: durMax, offerKeys: offerKeys, starterCheck: starterCheck, blank: blank, belt: belt, build: build, deck: deck, fightEntries: fightEntries, edges: edges, tiles: tiles, harmony: harmony,
    post: post, wearAll: wearAll, wearAdd: wearAdd, wearRows: wearRows, gnome: gnome, creature: creature, validate: validate };
});
