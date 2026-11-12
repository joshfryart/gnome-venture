/* v1 design demo: the sample content (pieces, tools, pals, creatures) and the deck builders. No DOM: also used by tools/pfdemo_v1/bot.js in node.
   Sample data only; the real catalogues are still to be authored (claude/design-deckbuilder-combat.md sections 2.2 and 3). */
(function (root, factory) {
  var api = factory(typeof module === 'object' && module && module.exports ? require(process.env.PFE_PATH) : root.PFE);
  if (typeof module === 'object' && module && module.exports) module.exports = api; else root.PFD = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function (PFE) {
  'use strict';
  var RANK_BONUS = [0, 0, 2, 4, 5], RANK_NAME = ['', 'Worn', 'Sturdy', 'Fine', 'Masterwork'], RARE_CAP = 3, MW_CAP = 1, KIT_MIN = 8;
  var TEAM_SRC = { pal: 1, tool: 1, crop: 1 };
  /* id: [name, type, base value, knob family, tag, source, rank, where it comes from, engine key (same key = same edges)] */
  function P(id, n, t, v, r, tag, src, rank, from, k) { return { id: id, n: n, t: t, v: v, r: r, tag: tag || '', src: src, rank: rank || 0, from: from || '', k: k || 'x:' + id }; }
  var PIECES = [
    P('swing', 'Swing', 'hurt', 4, 'mind', '', 'basic', 0, 'basic', 'swing'), P('dodge', 'Dodge', 'guard', 4, 'body', '', 'basic', 0, 'basic', 'dodge'),
    P('rest', 'Rest', 'heal', 3, 'craft', '', 'basic', 0, 'basic', 'rest'), P('charm', 'Charm', 'charm', 4, 'craft', '', 'basic', 0, 'basic', 'charm'),
    P('thorn', 'Thorn Cut', 'hurt', 5, 'craft', '', 'calling', 2, 'Thornblade calling', 'thorn'), P('jab', 'Jab', 'hurt', 2, 'craft', 'quick', 'knack', 0, 'knack', 'jab'),
    P('snack', 'Snack', 'item', 5, 'body', '', 'basic', 0, 'basic', 'snack'), P('hide', 'Hide', 'trick', 3, 'body', '', 'basic', 0, 'basic', 'hide'),
    P('oat', 'Oat Cake', 'guard', 3, 'craft', 'hold', 'crop', 1, 'grain crop'), P('herb', 'Herb Poultice', 'heal', 3, 'body', 'mend', 'crop', 1, 'herb crop'),
    P('brace', 'Brace', 'guard', 3, 'craft', 'hold', 'knack', 0, 'knack', 'brace'), P('soothe', 'Soothe', 'soothe', 2, 'mind', '', 'knack', 0, 'knack', 'soothe'),
    P('hum', 'Hum', 'charm', 3, 'body', 'hum', 'knack', 0, 'knack', 'hum'), P('pierce', 'Pierce', 'hurt', 3, 'mind', 'pierce', 'knack', 0, 'knack', 'pierce'),
    P('swing2', 'Swing', 'hurt', 4, 'mind', '', 'basic', 0, 'basic, 2nd copy', 'swing'), P('frost', 'Frost Bark', 'guard', 3, 'body', 'hold', 'region', 1, 'Maplewold guide'),
    /* owned beyond the starter offer */
    P('pepper', 'Pepper Puff', 'hurt', 3, 'body', 'poison', 'crop', 3, 'spice crop'), P('berry', 'Berry Burst', 'hurt', 3, 'mind', '', 'crop', 2, 'fruit crop'),
    P('juicy', 'Juicy Bite', 'item', 4, 'craft', '', 'crop', 1, 'fruit crop'), P('honey', 'Honey Glaze', 'charm', 4, 'mind', 'bond', 'crop', 4, 'flower crop'),
    P('tonic', 'Tonic', 'heal', 4, 'mind', '', 'craft', 2, 'alchemy'), P('compost', 'Compost Lob', 'hurt', 3, 'body', 'poison', 'craft', 3, 'garden craft'),
    P('handle', 'Spare Handle', 'guard', 4, 'mind', 'hold', 'craft', 2, 'tool shed'), P('mist', 'Mist Veil', 'guard', 3, 'mind', 'evade', 'region', 1, 'Mistmoor guide'),
    P('coldsnap', 'Cold Snap', 'hurt', 3, 'body', 'trip', 'region', 1, 'Maplewold guide'), P('monsoon', 'Monsoon Spice', 'hurt', 3, 'body', 'quick', 'region', 3, 'Spicepeak guide'),
    P('lull', 'Lull', 'charm', 3, 'craft', 'lull', 'knack', 0, 'knack', 'lull'), P('bash', 'Shield Bash', 'hurt', 2, 'mind', 'bash', 'knack', 0, 'knack', 'bash'),
    P('roll', 'Roll', 'guard', 2, 'body', 'evade', 'knack', 0, 'knack', 'roll')
  ];
  var CORE = ['swing', 'dodge', 'rest', 'charm'];
  var OFFER = ['thorn', 'jab', 'snack', 'hide', 'oat', 'herb', 'brace', 'soothe', 'hum', 'pierce', 'swing2', 'frost'];
  var KITS = { bold: ['thorn', 'jab', 'swing2', 'pierce', 'snack', 'oat'], steady: ['thorn', 'oat', 'herb', 'brace', 'frost', 'jab'], kind: ['hum', 'soothe', 'herb', 'snack', 'thorn', 'oat'] };
  var TOOLS = [
    { id: 'spade', ic: '⛏️', name: 'Steel Spade', tier: 3, dur0: 18, p: P('t:spade', 'Hoe Hook', 'hurt', 3, 'body', 'pierce', 'tool', 3, 'Steel Spade') },
    { id: 'lantern', ic: '🏮', name: 'Masterwork Lantern', tier: 4, dur0: 32, p: P('t:lantern', 'Glare', 'charm', 3, 'craft', 'lull', 'tool', 4, 'Masterwork Lantern') },
    { id: 'staff', ic: '🦯', name: 'Ash Staff', tier: 2, dur0: 4, p: P('t:staff', 'Sweep', 'guard', 3, 'mind', 'evade', 'tool', 2, 'Ash Staff') },
    { id: 'rod', ic: '🎣', name: 'Reed Rod', tier: 1, dur0: 20, p: P('t:rod', 'Reel In', 'trick', 3, 'body', '', 'tool', 1, 'Reed Rod') },
    { id: 'hatchet', ic: '🪓', name: 'Hatchet', tier: 2, dur0: 10, p: P('t:hatchet', 'Chop', 'hurt', 4, 'body', '', 'tool', 2, 'Hatchet') },
    { id: 'net', ic: '🦋', name: 'Bug Net', tier: 1, dur0: 0, p: P('t:net', 'Net Toss', 'hurt', 2, 'craft', 'trip', 'tool', 1, 'Bug Net') }
  ];
  var PALS = [
    { id: 'badger', name: 'Bark Badger', rar: 'uncommon', p: P('p:badger', 'Bark Badger', 'guard', 5, 'craft', '', 'pal', 2, 'uncommon pal') },
    { id: 'acorn', name: 'Acorn Nip', rar: 'common', p: P('p:acorn', 'Acorn Nip', 'heal', 4, 'mind', '', 'pal', 1, 'common pal') },
    { id: 'samara', name: 'Samara Spin', rar: 'rare', p: P('p:samara', 'Samara Spin', 'hurt', 4, 'body', 'quick', 'pal', 3, 'rare pal') },
    { id: 'moth', name: 'Moth Glow', rar: 'common', p: P('p:moth', 'Moth Glow', 'charm', 4, 'body', '', 'pal', 1, 'common pal') }
  ];
  var BELT_SLOTS = [2, 3, 4];   // belt tier I / II / III (bought)
  function toolMax(t) { return 20 + 4 * (t.tier - 1); }
  function byId(list, id) { for (var i = 0; i < list.length; i++) if (list[i].id === id) return list[i]; return null; }
  function life(p) { return p.tag === 'quick' || p.id === 'juicy' ? 2 : (p.rank === 4 || p.tag === 'hold' ? 4 : 3); }

  /** A fresh save: nothing packed yet (the starter pick comes first). */
  function freshSave() {
    var dur = {}; TOOLS.forEach(function (t) { dur[t.id] = t.dur0; });
    return { ver: 1, started: false, kit: [], belt: ['spade', 'staff'], beltTier: 0, party: ['badger', 'acorn'], dur: dur, auto: false, cr: 'badger', tune: {}, fights: 0 };
  }
  /** The pieces of the deck (catalogue entries, with gear flag): kit + belt tools that are not broken + active party pals. */
  function deckPieces(sv) {
    var out = [];
    sv.kit.forEach(function (id) { var p = byId(PIECES, id); if (p) out.push(p); });
    sv.belt.forEach(function (id) { var t = byId(TOOLS, id); if (t && sv.dur[id] > 0) out.push(Object.assign({ gear: 1, tool: t.id }, t.p)); });
    sv.party.forEach(function (id) { var q = byId(PALS, id); if (q) out.push(Object.assign({ gear: 1 }, q.p)); });
    return out;
  }
  function counts(sv) {
    var c = { n: 0, kit: sv.kit.length, belt: 0, pals: 0, hurt: 0, rare: 0, mw: 0, src: { pal: 0, tool: 0, crop: 0 } };
    deckPieces(sv).forEach(function (p) { c.n++; if (p.t === 'hurt') c.hurt++; if (p.rank === 3) c.rare++; if (p.rank === 4) c.mw++; if (TEAM_SRC[p.src]) c.src[p.src]++; if (p.src === 'tool') c.belt++; if (p.src === 'pal') c.pals++; });
    c.team = (c.src.pal ? 1 : 0) + (c.src.tool ? 1 : 0) + (c.src.crop ? 1 : 0);
    return c;
  }
  /** Why the deck cannot be used, or null. */
  function deckCheck(sv) {
    var c = counts(sv);
    if (sv.kit.length < KIT_MIN) return 'Pack at least ' + KIT_MIN + ' kit pieces.';
    if (c.hurt < 1) return 'Bring at least one Hurt piece.';
    if (c.rare > RARE_CAP) return 'At most ' + RARE_CAP + ' Rare pieces a deck.';
    if (c.mw > MW_CAP) return 'At most ' + MW_CAP + ' Masterwork piece a deck.';
    return null;
  }
  /** Would adding this piece break a rarity cap? Returns the reason or null. */
  function capBlock(sv, p) {
    var c = counts(sv);
    if (p.rank === 3 && c.rare >= RARE_CAP) return 'Rare cap: ' + RARE_CAP + ' Rare pieces a deck. Take one out first.';
    if (p.rank === 4 && c.mw >= MW_CAP) return 'Masterwork cap: ' + MW_CAP + ' a deck. Take the other one out first.';
    return null;
  }
  /** The sim's default gnome at a level (tools/pfsim/v1bundle/run.php): flat stats, health 20 + 3 x level + 5 x stat. */
  function gnome(lv) {
    lv = Math.max(1, lv); var m = Math.max(0, Math.floor((lv + 3) / 14));
    return { level: lv, max: 20 + 3 * lv + 5 * m, stats: { grit: m, nimble: m, hardiness: m, charm: m, lore: m, luck: m, level: lv } };
  }
  /** One fight piece (engine tile) from a catalogue entry at the gnome's level. */
  function tile(p, g) {
    var t = PFE.makeTile(p.k, g.stats, RANK_BONUS[p.rank] || 0, { n: p.n, t: p.t, v: p.v, r: p.r, tag: p.tag });
    t.life = life(p); t.src = p.src; t.rank = p.rank; t.id = p.id; if (p.tool) t.tool = p.tool;
    return t;
  }
  function deckTiles(sv, g) { return deckPieces(sv).map(function (p) { return tile(p, g); }); }

  // ------------------------------------------------------------------ creatures: 4 base (class) + region + size or boss + 3 unique
  var CLASSES = {
    Critter: { ic: '🐛', name: 'Critter', lean: 'mind', trick: 'quick', P: [['Nip', 'hurt', 0.9, 'mind', ''], ['Sting', 'hurt', 0.8, 'craft', ''], ['Chitin Shell', 'guard', 0.6, 'body', ''], ['Skitter', 'trick', 0.4, 'mind', 'quick', 2]] },
    Bird: { ic: '🐦', name: 'Bird', lean: 'craft', trick: 'evade', P: [['Peck', 'hurt', 1.0, 'mind', ''], ['Talon Dive', 'hurt', 1.1, 'craft', ''], ['Wing Cover', 'guard', 0.6, 'body', ''], ['Flutter Off', 'trick', 0.4, 'craft', 'evade']] },
    Beast: { ic: '🐺', name: 'Beast', lean: 'body', trick: 'bash', P: [['Claw', 'hurt', 1.0, 'body', ''], ['Maul', 'hurt', 1.1, 'mind', ''], ['Brace', 'guard', 0.7, 'body', ''], ['Shoulder Barge', 'trick', 0.5, 'craft', 'bash']] },
    Reptile: { ic: '🐍', name: 'Reptile / Amphibian', lean: 'craft', trick: 'poison', P: [['Bite', 'hurt', 0.9, 'body', ''], ['Tail Lash', 'hurt', 0.9, 'craft', ''], ['Scale Guard', 'guard', 0.7, 'mind', ''], ['Venom Spit', 'trick', 0.5, 'craft', 'poison']] },
    Water: { ic: '🦀', name: 'Water', lean: 'body', trick: 'trip', P: [['Snap', 'hurt', 1.0, 'body', ''], ['Splash', 'hurt', 0.9, 'mind', ''], ['Slick Hide', 'guard', 0.7, 'body', ''], ['Undertow', 'trick', 0.4, 'mind', 'trip']] },
    Plant: { ic: '🌿', name: 'Plant / Fungus', lean: 'mind', trick: 'heal', P: [['Lash Vine', 'hurt', 0.9, 'craft', ''], ['Spore Puff', 'hurt', 0.8, 'mind', ''], ['Bramble Coat', 'guard', 0.7, 'body', 'thorns'], ['Sap Mend', 'trick', 0.4, 'mind', 'heal']] }
  };
  /* region: [hurt piece, other piece] (large and boss carry both, small and medium only the other) */
  var REGIONS = {
    'Maizehollow': [['Ash Spit', 'hurt', 1.0, 'craft', 'pierce'], ['Dry Spell', 'trick', 0.4, 'body', '']],
    'Mistmoor': [['Bog Grip', 'hurt', 1.0, 'body', ''], ['Mist Veil', 'guard', 0.6, 'mind', 'evade']],
    'Olivewhistle Shore': [['Stone Throw', 'hurt', 1.0, 'mind', 'bash'], ['Terra Wall', 'guard', 0.7, 'craft', 'hold']],
    'Birchbramble Steppe': [['Short Fuse', 'hurt', 0.9, 'body', 'quick'], ['Black Earth', 'heal', 0.5, 'mind', '']],
    'Thornacre Savanna': [['Highland Charge', 'hurt', 1.2, 'body', ''], ['Thornbush', 'guard', 0.7, 'craft', 'thorns']],
    'The Rainroot Reaches': [['Canopy Drop', 'hurt', 1.2, 'mind', ''], ['Humus Hide', 'guard', 0.7, 'body', '']],
    'The Maplewold': [['Cold Snap', 'hurt', 1.0, 'body', 'trip'], ['Frost Bark', 'guard', 0.7, 'craft', 'hold']],
    'The Dunewhisper': [['Sandsting', 'hurt', 1.0, 'body', 'poison'], ['Heat Shimmer', 'guard', 0.6, 'mind', 'evade']]
  };
  var SIZE_EXTRA = { small: [], medium: [], large: [['Slam', 'hurt', 1.2, 'mind', '']], boss: [['Scheme', 'trick', 0.5, 'mind', ''], ['Crush', 'hurt', 1.3, 'body', '']] };
  var DIE = { small: 4, medium: 6, large: 8, boss: 10 };
  var CREATURES = [
    { slug: 'aphid-swarm', name: 'Aphid Swarm', size: 'small', level: 1, cls: 'Critter', region: 'Maizehollow', loot: ['Honeydew', 'Aphid Wings'], blurb: 'Many weak pieces, keeps coming.',
      U: [['Swarm', 'hurt', 0.6, 'mind', 'quick', 2], ['Honeydew', 'heal', 0.5, 'craft', '', 2], ['Cloud Up', 'guard', 0.5, 'body', 'evade']] },
    { slug: 'garden-snail', name: 'Garden Snail', size: 'small', level: 1, cls: 'Critter', region: 'Mistmoor', loot: ['Snail Slime', 'Spiral Shell'], blurb: 'Slow and hard to hurt. Pierce or Charm beats it.',
      U: [['Slime Trail', 'guard', 0.7, 'body', 'hold', 4], ['Shell Tuck', 'guard', 0.6, 'mind', 'evade'], ['Rasp', 'hurt', 0.8, 'craft', '']] },
    { slug: 'shore-crab', name: 'Shore Crab', size: 'medium', level: 7, cls: 'Water', region: 'Olivewhistle Shore', loot: ['Crab Claw', 'Crab Shell'], blurb: 'Pinches through your guard.',
      U: [['Pinch', 'hurt', 1.0, 'body', 'pierce'], ['Shell Up', 'guard', 0.7, 'craft', 'hold', 4], ['Sidestep', 'trick', 0.4, 'mind', 'evade']] },
    { slug: 'carrion-crow', name: 'Carrion Crow', size: 'medium', level: 9, cls: 'Bird', region: 'Birchbramble Steppe', loot: ['Black Feather', 'Shiny Trinket'], blurb: 'Hard to pin down; steals your draw.',
      U: [['Hat Snatch', 'trick', 0.4, 'mind', 'trip'], ['Dive Bomb', 'hurt', 1.1, 'craft', 'pierce'], ['Mob Caw', 'hurt', 0.8, 'body', 'quick', 2]] },
    { slug: 'thistle-beast', name: 'Thistle Beast', size: 'medium', level: 12, cls: 'Plant', region: 'Thornacre Savanna', loot: ['Thistle Spines', 'Thistle Heart'], blurb: 'Spiky and slow. Hitting its guard hurts you.',
      U: [['Needle Volley', 'hurt', 0.9, 'craft', 'poison'], ['Thistle Spines', 'guard', 0.7, 'body', 'thorns'], ['Root Deep', 'heal', 0.5, 'mind', '']] },
    { slug: 'grass-snake', name: 'Grass Snake', size: 'large', level: 14, cls: 'Reptile', region: 'The Rainroot Reaches', loot: ['Snake Skin', 'Snake Fang'], blurb: 'Poison adds up if the fight drags.',
      U: [['Coil', 'guard', 0.7, 'body', 'hold', 4], ['Strike', 'hurt', 1.0, 'mind', 'quick', 2], ['Constrict', 'hurt', 0.9, 'craft', 'trip']] },
    { slug: 'badger', name: 'Badger', size: 'large', level: 18, cls: 'Beast', region: 'Mistmoor', loot: ['Badger Pelt', 'Badger Claw'], blurb: 'Builds guard, then cashes it in.',
      U: [['Dig In', 'guard', 0.8, 'body', 'hold', 4], ['Badger Maul', 'hurt', 1.3, 'mind', ''], ['Bash Back', 'hurt', 0.9, 'craft', 'bash']] },
    { slug: 'bramble-wolf', name: 'Bramble Wolf', size: 'large', level: 22, cls: 'Beast', region: 'The Maplewold', loot: ['Bramble Pelt', 'Thorn Fang'], blurb: 'Thorny guard and trips.',
      U: [['Howl', 'trick', 0.5, 'mind', ''], ['Bramble Bite', 'hurt', 1.0, 'craft', 'bash'], ['Pack Circle', 'guard', 0.7, 'body', 'thorns']] },
    { slug: 'dune-wyrm', name: 'Dune Wyrm', size: 'boss', level: 30, cls: 'Reptile', region: 'The Dunewhisper', loot: ['Wyrm Scale', 'Wyrm Fang', 'Desert Gem'], blurb: 'Boss: cannot be charmed. Trips your draw, then big hits.',
      U: [['Burrow Under', 'guard', 0.7, 'craft', 'evade'], ['Quake', 'hurt', 1.0, 'craft', 'trip'], ['Sand Swallow', 'hurt', 1.25, 'body', '']] }
  ];
  var LAYERS = { base: 'Base (class)', reg: 'Region', rar: 'Size or boss', uni: 'Unique' };
  /** The archetype value of the creature ($v in pf_foe_deck). */
  function foeV(c) { return Math.max(1, Math.round(((DIE[c.size] + 1) / 2 + Math.floor(c.level / 4)) * (c.size === 'boss' ? 0.78 : 1.4))); }
  /** The creature's pieces by layer: [{layer, n, t, v, r, tag, life, k}] (values before the board factors). */
  function foePieces(c) {
    var v = foeV(c), out = [], big = c.size === 'large' || c.size === 'boss', i = 0;
    var add = function (layer, q) { out.push({ k: 'f:' + c.slug + ':' + (i++), n: q[0], t: q[1], v: Math.max(1, Math.round(q[2] * v)), r: q[3], tag: q[4] || '', life: q[5] || 3, layer: layer }); };
    CLASSES[c.cls].P.forEach(function (q) { add('base', q); });
    var rg = REGIONS[c.region]; if (big) add('reg', rg[0]); add('reg', rg[1]);
    SIZE_EXTRA[c.size].forEach(function (q) { add('rar', q); });
    c.U.forEach(function (q) { add('uni', q); });
    return out;
  }
  /** The engine's creature row. A boss plays its deck in a set order (trick, guard, hurts...). */
  function foeRow(c) {
    var deck = foePieces(c);
    if (c.size === 'boss') {   // one set-up piece (trick, guard, heal), then two Hurt pieces, and again
      var soft = deck.filter(function (x) { return x.t !== 'hurt'; }), hard = deck.filter(function (x) { return x.t === 'hurt'; }); deck = [];
      while (soft.length || hard.length) { if (soft.length) deck.push(soft.shift()); if (hard.length) deck.push(hard.shift()); if (hard.length) deck.push(hard.shift()); }
    }
    return { slug: c.slug, name: c.name, size: c.size, level: c.level, dmg_die: DIE[c.size], dmg_bonus: Math.floor(c.level / 4), deck: deck };
  }
  /** Start a fight. tune = the Tuning drawer's values (engine v1 overrides + lvl offset). */
  function newFight(sv, c, seed, tune) {
    tune = tune || {};
    var g = gnome(c.level + (tune.lvl || 0)), v1 = {};
    ['foe_x', 'bar_x', 'ev_unit', 'bramble', 'sun', 'limit', 'br_foe', 'nev', 'dims'].forEach(function (k) { if (tune[k] !== undefined && tune[k] !== null) v1[k] = tune[k]; });
    if (v1.nev === 0) v1.events = 0;
    var s = PFE.newFight({ hp: g.max, max_hp: g.max, stats: g.stats, deck: deckTiles(sv, g), luck: 0 }, foeRow(c), seed, { blank: true, v1: v1 });
    return { s: s, g: g, c: c };
  }
  return { PIECES: PIECES, CORE: CORE, OFFER: OFFER, KITS: KITS, TOOLS: TOOLS, PALS: PALS, BELT_SLOTS: BELT_SLOTS, CLASSES: CLASSES, REGIONS: REGIONS, CREATURES: CREATURES, LAYERS: LAYERS,
    RANK_NAME: RANK_NAME, RANK_BONUS: RANK_BONUS, RARE_CAP: RARE_CAP, MW_CAP: MW_CAP, KIT_MIN: KIT_MIN, TEAM_SRC: TEAM_SRC,
    toolMax: toolMax, byId: byId, life: life, freshSave: freshSave, deckPieces: deckPieces, counts: counts, deckCheck: deckCheck, capBlock: capBlock,
    gnome: gnome, tile: tile, deckTiles: deckTiles, foeV: foeV, foePieces: foePieces, foeRow: foeRow, newFight: newFight };
});
