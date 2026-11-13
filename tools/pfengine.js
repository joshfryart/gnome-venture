/*
 * Puzzle Combat BOARD-mode engine, ported from PHP (game/includes/pfight.php, pfboard.php, pfight_data.php and the line/chip
 * helpers of pfight_game.php). One self-contained file, plain ES2017, no dependencies. Works in a browser <script>
 * (sets globalThis.PFE) and in node (module.exports).
 *
 * Behaviour is meant to be bit-for-bit the PHP engine's: tests/pfengine_js.sh replays PHP fights and compares every view,
 * event list and the final state as JSON. State is a plain JSON object with the PHP state's keys (an empty PHP array [] may
 * come back as {} for the maps pcs / cell / lucky_used; both mean "empty").
 *
 * Move shapes (same as PHP pfb_play):  [handIdx, x, y] | ['c', x, y] | ['j', a, b, side] | ['h', b, anc, side]
 */
(function (root, factory) {
  var api = factory();
  if (typeof module === 'object' && module && module.exports) module.exports = api;
  else root.PFE = api;
})(typeof globalThis !== 'undefined' ? globalThis : (typeof self !== 'undefined' ? self : this), function () {
  'use strict';

  // ------------------------------------------------------------------ constants (pfight.php, pfboard.php, pfight_data.php)
  var PF_HAND_CAP = 5, PF_DRAW = 3, PF_CHAIN_MAX = 4, PF_TURN_CAP = 24;
  var PF_GENTLE_HM = 0.8;
  var PF_BAR_K = 1.7, PF_BAR_BOSS = 2.0, PF_BAR_BASE = 5, PF_BAR_SLOPE = 0.4;
  var PF_FOE_DMG = 1.4, PF_FOE_BOSS = 0.78, PF_POISON_CAP = 3;
  var PFB_W = 7, PFB_H = 5, PFB_LIFE = 3, PFB_FOE_MIN = 2, PFB_GROUP_MAX = 3;
  var PFB_GROUP_MULT = { 2: 1.0, 3: 2.0 }, PFB_SETASIDE_GUARD = 1.0;
  var PFB_FOE_FIRES = 2, PFB_FOE_FIRE_MULT = 1.15;   // fire budget: a creature piece falls away after this many firings (its placement is the first)
  var PFB_BOSS_MULT = 1.2, PFB_BLANK_FOE_MULT = 1.0;
  var PFB_BAR_MULT = 0.7, PFB_FOE_MULT = 0.62;
  var PFB_SIDE = { L: [-1, 0, 'R'], R: [1, 0, 'L'], T: [0, -1, 'B'], B: [0, 1, 'T'] };
  var PF_BOX_MIN = 6;

  var PF_HOLE = { hurt: 'body', guard: 'body', heal: 'mind', charm: 'mind', soothe: 'mind', trick: 'craft', item: 'craft' };
  var PF_STAT = { hurt: 'grit', guard: 'nimble', heal: 'hardiness', charm: 'charm', soothe: 'charm', trick: 'lore', item: 'lore' };

  var PF_COMBOS = {
    'trick>hurt': { name: 'Ambush', mul: 150, flat: 'prev' },
    'guard>hurt': { name: 'Riposte', mul: 150, flat: 0 },
    'hurt>hurt': { name: 'Double Swing', mul: 100, flat: 2 },
    'soothe>charm': { name: 'Calm Charm', mul: 150, flat: 0 },
    'charm>item': { name: 'Win Over', mul: 100, flat: 0, barPct: 50 },
    'trick>guard': { name: 'Bait', mul: 100, flat: 'prev' }
  };

  var PF_TAGS = {
    quick: ['⚡', 'Quick: draw a tile when played'],
    heavy: ['🪨', 'Heavy: has to be the last tile of a chain'],
    pierce: ['📌', 'Pierce: ignores the creature\'s guard'],
    poison: ['🧪', 'Poison: keeps working for 2 more turns'],
    trip: ['🪢', 'Trip: the creature plays one tile fewer next turn'],
    bash: ['🛡️', 'Bash: adds the guard you built earlier in this chain to the hit'],
    hold: ['⚓', 'Hold: this guard lasts through your next turn too'],
    thorns: ['🌵', 'Thorns: while this guard is up, a blocked hit pricks the creature'],
    evade: ['💨', 'Evade: the creature\'s first Hurt next turn misses completely'],
    mend: ['🩹', 'Mend: heals you 2 as well'],
    hum: ['🎵', 'Hum: also calms the creature (Soothe 2)'],
    lull: ['🌙', 'Lull: the creature plays one tile fewer next turn'],
    bond: ['🤝', 'Bond: the creature warms to Charm for the rest of the fight'],
    pluck: ['🤏', 'Pluck: a small chance to lift an item the creature could drop (Luck helps; once a fight)']
  };

  var ALL7 = ['hurt', 'guard', 'heal', 'charm', 'soothe', 'trick', 'item'];
  var PF_MODS = {
    sticky: ['Sticky', '🧲', 'A snug fit also draws you a tile', 0, ALL7],
    swift: ['Swift', '🪶', 'Does not count towards a four-tile chain (no extra foe move)', 0, ALL7],
    hardy: ['Hardy', '🧱', '+2 guard', 0, ['guard']],
    tender: ['Tender', '💗', 'Heals 2 more', 0, ['heal', 'item']],
    leech: ['Leech', '🩸', 'Heals you a little when it hits', 1, ['hurt']],
    spiky: ['Spiky', '🦔', 'Also pricks the creature for 2 when played', 1, ['guard']],
    soft: ['Soft touch', '🪽', 'Also calms the creature (Soothe 2)', 1, ['charm', 'heal', 'item']],
    warm: ['Warm', '🔥', 'A quarter of its damage also counts as Charm', 2, ['hurt']],
    finisher: ['Finisher', '🎯', '+3 when the creature is past 60% resolve', 2, ['hurt']],
    lucky: ['Lucky', '🍀', 'Gives you one extra redraw this fight', 2, ALL7],
    steady: ['Steady', '⚖️', 'A Heavy tile can go anywhere in the chain', 2, ['hurt']]
  };

  var PF_CALLING_TILE = { rootwarden: 'bark', bloomcaller: 'bloom', thornblade: 'thorn', seedkeeper: 'sow', wayfinder: 'wayfind', brewroot: 'brew' };
  var PF_BASE_KEYS = ['swing', 'dodge', 'rest', 'charm', 'snack', 'hide'];

  var PF_GENTLE = ['garden-snail', 'dusk-moth', 'cave-glowworm', 'dung-beetle', 'leopard-slug', 'aphid-swarm', 'grumpy-lemming', 'sun-lizard', 'bullfrog', 'shore-crab',
    'tunnel-mole', 'frost-hare', 'will-o-wisp', 'grass-snake', 'grey-heron', 'tawny-owl', 'mire-toad', 'sea-otter-bandit', 'hermit-crab-hoarder', 'reef-turtle',
    'ptarmigan-flock', 'beaver-foreman', 'giant-anteater', 'giant-bumblebee', 'desert-tortoise', 'pelican-parliament', 'lichen-reindeer', 'desert-camel', 'prairie-bison', 'cliff-ram'];

  var PF_SIGNATURE = {
    'garden-snail': [{ n: 'Slime Trail', t: 'guard', v: 3, r: 'body' }],
    'paper-wasp': [{ n: 'Sting', t: 'hurt', v: 4, r: 'craft' }],
    'tunnel-mole': [{ n: 'Burrow', t: 'guard', v: 3, r: 'mind' }],
    'red-fox': [{ n: 'Sly Pounce', t: 'trick', v: 3, r: 'body' }],
    'bramble-wolf': [{ n: 'Howl', t: 'trick', v: 4, r: 'body' }]
  };

  // ------------------------------------------------------------------ PHP-behaviour helpers
  function has(o, k) { return Object.prototype.hasOwnProperty.call(o, k); }
  function nn(x, def) { return (x === undefined || x === null) ? (def === undefined ? null : def) : x; }   // PHP ??
  function toInt(x) { x = Number(x); if (!isFinite(x)) return 0; return Math.trunc(x) + 0; }   // PHP (int)
  function isInt(x) { return typeof x === 'number' && isFinite(x) && Math.floor(x) === x; }
  function intdiv(a, b) { return Math.trunc(a / b) + 0; }
  function isEmpty(o) { if (Array.isArray(o)) return o.length === 0; for (var k in o) return false; return true; }
  function truthy(x) { return !(x === undefined || x === null || x === false || x === 0 || x === '' || x === '0'); }   // PHP !empty()
  function clone(v) {
    if (v === null || typeof v !== 'object') return v;
    if (Array.isArray(v)) { var a = new Array(v.length); for (var i = 0; i < v.length; i++) a[i] = clone(v[i]); return a; }
    var o = {}; for (var k in v) o[k] = clone(v[k]); return o;
  }
  /** Replace the contents of object a with those of b (PHP "$s = $w" through a reference). */
  function assignInto(a, b) { var k; for (k in a) delete a[k]; for (k in b) a[k] = b[k]; return a; }

  function pow10(n) { return n < 0 || n > 22 ? Math.pow(10, n) : [1, 1e1, 1e2, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9, 1e10, 1e11, 1e12, 1e13, 1e14, 1e15, 1e16, 1e17, 1e18, 1e19, 1e20, 1e21, 1e22][n]; }
  function roundHelper(v) { return v >= 0 ? Math.floor(v + 0.5) : Math.ceil(v - 0.5); }
  /** PHP 8.0-8.3 round() (half away from zero, with PHP's pre-rounding to 15 significant digits). */
  function round(value, places) {
    places = places | 0;
    if (!isFinite(value) || value === 0) return value;
    var precisionPlaces = 14 - Math.floor(Math.log10(Math.abs(value)));
    var f1 = pow10(Math.abs(places)), tmp;
    if (precisionPlaces > places && precisionPlaces - 15 < places) {
      var use = precisionPlaces < -60 ? -60 : precisionPlaces;
      tmp = use >= 0 ? value * pow10(use) : value / pow10(-use);
      tmp = roundHelper(tmp);
      use = places - use; if (use < -60) use = -60;
      tmp = tmp / pow10(Math.abs(use));
    } else {
      tmp = places >= 0 ? value * f1 : value / f1;
      if (Math.abs(tmp) >= 1e15) return value;
    }
    tmp = roundHelper(tmp);
    if (places > 0) tmp = tmp / f1; else tmp = tmp * f1;
    return tmp;
  }
  function iround(v) { return toInt(round(v, 0)); }   // (int)round($v)

  function crc32(str) {   // standard CRC-32 of the UTF-8 bytes, unsigned (PHP crc32)
    var t = crc32.t;
    if (!t) { t = crc32.t = new Array(256); for (var n = 0; n < 256; n++) { var c = n; for (var k = 0; k < 8; k++) c = (c & 1) ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1); t[n] = c >>> 0; } }
    var b = unescape(encodeURIComponent(str)), crc = 0xFFFFFFFF;
    for (var i = 0; i < b.length; i++) crc = t[(crc ^ b.charCodeAt(i)) & 0xFF] ^ (crc >>> 8);
    return (crc ^ 0xFFFFFFFF) >>> 0;
  }

  // ------------------------------------------------------------------ tiles
  var TILES = null;
  function tiles() {
    if (TILES) return TILES;
    return TILES = {
      swing: { n: 'Swing', t: 'hurt', v: 4, r: 'mind' },
      dodge: { n: 'Dodge', t: 'guard', v: 4, r: 'body' },
      rest: { n: 'Rest', t: 'heal', v: 3, r: 'craft' },
      charm: { n: 'Charm', t: 'charm', v: 4, r: 'craft' },
      snack: { n: 'Snack', t: 'item', v: 5, r: 'body', tag: 'snack' },
      hide: { n: 'Hide', t: 'trick', v: 3, r: 'body' },
      soothe: { n: 'Soothe', t: 'soothe', v: 2, r: 'mind' },
      offer: { n: 'Offer', t: 'charm', v: 6, r: null },
      taunt: { n: 'Taunt', t: 'trick', v: 3, r: 'body' },
      jab: { n: 'Jab', t: 'hurt', v: 2, r: 'craft', tag: 'quick' },
      pierce: { n: 'Pierce', t: 'hurt', v: 3, r: 'mind', tag: 'pierce' },
      sting: { n: 'Sting', t: 'hurt', v: 2, r: 'body', tag: 'poison' },
      trip: { n: 'Trip', t: 'hurt', v: 2, r: 'craft', tag: 'trip' },
      bash: { n: 'Shield Bash', t: 'hurt', v: 2, r: 'mind', tag: 'bash' },
      smash: { n: 'Smash', t: 'hurt', v: 6, r: 'body', tag: 'heavy' },
      brace: { n: 'Brace', t: 'guard', v: 3, r: 'craft', tag: 'hold' },
      roll: { n: 'Roll', t: 'guard', v: 2, r: 'body', tag: 'evade' },
      thornhide: { n: 'Thorn Hide', t: 'guard', v: 3, r: 'mind', tag: 'thorns' },
      mending: { n: 'Mending', t: 'guard', v: 2, r: 'craft', tag: 'mend' },
      hum: { n: 'Hum', t: 'charm', v: 3, r: 'body', tag: 'hum' },
      lull: { n: 'Lull', t: 'charm', v: 3, r: 'craft', tag: 'lull' },
      bond: { n: 'Bond', t: 'charm', v: 3, r: 'mind', tag: 'bond' },
      pluck: { n: 'Pluck', t: 'trick', v: 2, r: 'body', tag: 'pluck' },
      breather: { n: 'Breather', t: 'heal', v: 2, r: 'body' },
      bark: { n: 'Bark Wall', t: 'guard', v: 6, r: 'body' },
      bloom: { n: 'Bloom', t: 'charm', v: 8, r: 'mind' },
      thorn: { n: 'Thorn Cut', t: 'hurt', v: 7, r: 'craft' },
      sow: { n: 'Sow Doubt', t: 'trick', v: 5, r: 'mind' },
      wayfind: { n: 'Slip Past', t: 'trick', v: 5, r: 'body' },
      brew: { n: 'Steep', t: 'heal', v: 6, r: 'craft' }
    };
  }

  // ------------------------------------------------------------------ RNG
  function rand(s, max) {
    var x = (Number(s.rng) >>> 0); if (x === 0) x = 0x9E3779B9;
    x = (x ^ (x << 13)) >>> 0; x = (x ^ (x >>> 17)) >>> 0; x = (x ^ (x << 5)) >>> 0;
    s.rng = x;
    return max <= 1 ? 0 : x % max;
  }
  function shuffle(s, a) {
    a = a.slice();
    for (var i = a.length - 1; i > 0; i--) { var j = rand(s, i + 1); var t = a[i]; a[i] = a[j]; a[j] = t; }
    return a;
  }

  // ------------------------------------------------------------------ tile instances and decks
  function makeTile(key, stats, bonus, over) {
    bonus = bonus || 0;
    var T = tiles();
    var d = Object.assign({ tag: '' }, has(T, key) ? T[key] : T.swing);
    if (over) d = Object.assign({}, d, over);
    var stat = Math.max(0, toInt(nn(stats[PF_STAT[d.t]], 0)));
    var lvl = intdiv(Math.max(1, toInt(nn(stats.level, 1))), 3);
    var t = { k: key, n: d.n, t: d.t, v: Math.max(1, toInt(d.v) + stat + lvl + bonus), r: nn(d.r), tag: String(d.tag), m: '' };
    ['src', 'life', 'col', 'up', 'edges', 'rank', 'tool'].forEach(function (k) { if (d[k] !== undefined && d[k] !== null) t[k] = d[k]; });   // v1 board rules (v1Tile): source, life, authored edges
    return t;
  }

  function callingKeys() { var o = []; for (var k in PF_CALLING_TILE) o.push(PF_CALLING_TILE[k]); return o; }

  /** opts: {calling, tier, pals, unlocked, typeBonus, snack, box} (the PHP positional args after $stats). */
  function playerDeck(stats, opts) {
    opts = opts || {};
    var calling = nn(opts.calling, ''), tier = nn(opts.tier, 1), pals = nn(opts.pals, []), unlocked = nn(opts.unlocked, []),
      typeBonus = nn(opts.typeBonus, {}), snack = opts.snack === undefined ? true : !!opts.snack, box = nn(opts.box);
    var T = tiles(), keys, i, k;
    if (box !== null) keys = box;
    else {
      keys = PF_BASE_KEYS.slice();
      if (has(PF_CALLING_TILE, calling)) keys.push(PF_CALLING_TILE[calling]);
      for (i = 0; i < unlocked.length; i++) { k = unlocked[i]; if (has(T, k) && keys.indexOf(k) < 0) keys.push(k); }
    }
    var ct = callingKeys(), deck = [];
    for (i = 0; i < keys.length; i++) {
      k = keys[i];
      if (k === 'snack' && !snack) k = 'breather';
      var t = has(T, k) ? T[k] : null; if (!t) continue;
      var b = toInt(nn(typeBonus[t.t], 0)) + (calling === 'bloomcaller' && (t.t === 'charm' || t.t === 'soothe') ? 2 : 0);
      if (ct.indexOf(k) >= 0) b += Math.max(0, tier - 1) * 2;
      deck.push(makeTile(k, stats, b));
    }
    var ps = pals.slice(0, 2);
    for (var pi = 0; pi < ps.length; pi++) {
      var p = ps[pi], hurts = deck.filter(function (x) { return x.t === 'hurt'; }).length, at = null, j;
      for (j = 0; j < deck.length; j++) if (deck[j].k === nn(p.swap, '')) { at = j; break; }
      if (at === null) for (j = 0; j < deck.length; j++) if (deck[j].t === nn(p.t, '') && ct.indexOf(deck[j].k) < 0 && deck[j].k.indexOf('pal:') !== 0) { at = j; break; }
      if (at === null || (deck[at].t === 'hurt' && hurts < 2 && nn(p.t, '') !== 'hurt')) continue;
      deck[at] = makeTile('pal:' + p.n, stats, toInt(nn(typeBonus[String(p.t)], 0)), { n: String(p.n), t: String(p.t), v: toInt(p.v), r: nn(p.r), tag: 'pal' });
    }
    return deck;
  }

  function unlocks(level) {
    var out = [], L = [['soothe', 4], ['jab', 5], ['brace', 6], ['hum', 6], ['pluck', 7], ['pierce', 8], ['roll', 9], ['taunt', 10], ['lull', 10], ['trip', 11], ['offer', 12], ['thornhide', 12],
      ['sting', 13], ['bond', 13], ['bash', 14], ['mending', 15], ['smash', 16]];
    for (var i = 0; i < L.length; i++) if (level >= L[i][1]) out.push(L[i][0]);
    return out;
  }
  function boxCapacity(level) { return Math.min(14, 8 + intdiv(Math.max(1, level), 3)); }
  function collection(level, calling) {
    var keys = PF_BASE_KEYS.slice();
    if (has(PF_CALLING_TILE, calling || '')) keys.push(PF_CALLING_TILE[calling]);
    unlocks(level).forEach(function (k) { if (keys.indexOf(k) < 0) keys.push(k); });
    return keys;
  }
  function boxCheck(keys, cap) {
    if (keys.length > cap) return 'The box only holds ' + cap + ' tiles.';
    if (keys.length < PF_BOX_MIN) return 'Bring at least ' + PF_BOX_MIN + ' tiles.';
    var hurt = false, T = tiles();
    keys.forEach(function (k) { if ((has(T, k) ? T[k].t : '') === 'hurt') hurt = true; });
    if (!hurt) return 'Bring at least one Hurt tile (the great creatures cannot be charmed).';
    return null;
  }
  function box(level, calling, saved) {
    var own = collection(level, calling), cap = boxCapacity(level), b = [];
    (saved || []).forEach(function (k) { if (typeof k === 'string' && own.indexOf(k) >= 0 && b.indexOf(k) < 0) b.push(k); });
    b = b.slice(0, cap);
    if (boxCheck(b, cap) !== null) b = own.slice(0, cap);
    return b;
  }

  function temper(c) {
    if (truthy(c.temper)) return String(c.temper);
    return PF_GENTLE.indexOf(String(nn(c.slug, ''))) >= 0 ? 'gentle' : 'hostile';
  }

  function foeDeck(c) {
    if (Array.isArray(c.deck) && c.deck.length) return clone(c.deck);   // 2.6.74 (v1 deck model): the creature row carries its layered deck
    var size = String(nn(c.size, 'small')), tp = temper(c), boss = size === 'boss';
    var v = Math.max(1, iround(((toInt(nn(c.dmg_die, 4)) + 1) / 2 + toInt(nn(c.dmg_bonus, 0))) * (boss ? PF_FOE_BOSS : PF_FOE_DMG)));
    var mk = function (k, n, t, val, r, tag) { return { k: 'f:' + k, n: n, t: t, v: Math.max(1, val), r: nn(r), tag: tag === undefined ? '' : tag }; };
    var deck = [
      mk('hit1', 'Lunge', 'hurt', v, 'mind'), mk('hit2', 'Snap', 'hurt', v, 'body'),
      mk('guard', 'Brace', 'guard', Math.max(1, intdiv(v * 2, 3)), 'craft'),
      mk('feint', 'Feint', 'trick', Math.max(1, intdiv(v, 2)), 'body'),
      mk('rest', 'Recover', 'heal', Math.max(1, intdiv(v, 2)), 'mind')
    ];
    if (tp === 'hostile') deck.push(mk('hit3', 'Rend', 'hurt', v + 1, 'craft'));
    else deck.push(mk('guard2', 'Shy Back', 'guard', Math.max(1, intdiv(v * 2, 3)), 'body'));
    if (size === 'large' || boss) { deck.push(mk('hit4', 'Slam', 'hurt', v + 2, 'mind')); deck.push(mk('guard3', 'Bulk', 'guard', Math.max(1, v - 1), 'craft')); }
    if (boss) { deck.push(mk('hit5', 'Crush', 'hurt', v + 3, 'body')); deck.push(mk('feint2', 'Scheme', 'trick', Math.max(1, intdiv(v, 2)), 'mind')); }
    if (boss) {
      var order = ['f:feint', 'f:guard', 'f:hit1', 'f:feint2', 'f:hit2', 'f:guard3', 'f:hit3', 'f:hit4', 'f:rest', 'f:hit5'];
      var rank = function (k) { var i = order.indexOf(k); return i < 0 ? 99 : i; };
      deck = deck.map(function (x, i) { return [x, i]; }).sort(function (a, b) { return (rank(a[0].k) - rank(b[0].k)) || (a[1] - b[1]); }).map(function (x) { return x[0]; });   // stable, like PHP 8
    }
    var sigs = c.signature !== undefined && c.signature !== null ? c.signature : (has(PF_SIGNATURE, String(nn(c.slug, ''))) ? PF_SIGNATURE[String(nn(c.slug, ''))] : []);
    for (var i = 0; i < sigs.length; i++) { var sg = sigs[i]; deck.push(mk('sig' + deck.length, String(sg.n), String(sg.t), toInt(sg.v), nn(sg.r), 'sig')); }
    return deck;
  }

  function pace(size) { var m = { small: 2.5, medium: 3.5, large: 4.5, boss: 7.0 }; return has(m, size) ? m[size] : 3.5; }

  function randNonce() {
    var o = '';
    for (var i = 0; i < 8; i++) o += Math.floor(Math.random() * 16).toString(16);
    return o;
  }

  // ------------------------------------------------------------------ pf_new / pf_draw
  function pfNew(me, c, seed, opt) {
    opt = opt || {};
    var size = String(nn(c.size, 'small')), boss = size === 'boss', tp = temper(c);
    var hm = tp === 'hostile' ? 1.0 : PF_GENTLE_HM, cm = tp === 'hostile' ? 0.6 : 1.0;
    if (boss && !truthy(opt.boss_charm)) { hm = 1.0; cm = 0.0; }
    var luck = toInt(nn(me.luck, 0));
    var s = {
      rng: seed || 1, nonce: randNonce(), turn: 1, over: null, strip: [], log: [],
      hm: hm, cm: cm, boss: boss, temper: tp, size: size,
      me: { hp: toInt(me.hp), max: toInt(me.max_hp), block: 0, hand: [], draw: [], discard: [], keep: 0, thorns: false, evade: 0, luckmod: Math.max(0, luck), redraws: Math.max(0, Math.min(3, intdiv(luck, 3))) },
      plucked: 0, can_pluck: truthy(opt.can_pluck), bond: 0,
      foe: { hand: [], draw: [], discard: [], block: 0, keep: 0, thorns: false, evade: 0, agg: 0, poison: 0, poison_v: 0, slow: 0, hsize: boss ? 4 : 3, name: String(nn(c.name, 'Creature')), intent: null },
      bar: { now: 0.0, max: 1.0, hurt: 0.0, charm: 0.0 },
      fh: { now: 0.0, max: 1.0 },
      run_ok: !boss
    };
    s.me.draw = shuffle(s, clone(Object.keys(me.deck).map(function (k) { return me.deck[k]; })));
    var fd = foeDeck(c);
    s.foe.ordered = boss;
    s.foe.draw = boss ? fd.slice().reverse() : shuffle(s, fd);
    s.bar.max = Math.max(6.0, round(pace(size) * (boss ? PF_BAR_BOSS : PF_BAR_K) * (PF_BAR_BASE + PF_BAR_SLOPE * Math.max(1, toInt(nn(c.level, 1)))), 1));
    s.fh.max = s.bar.max;
    draw(s, 'me', PF_HAND_CAP);
    draw(s, 'foe', s.foe.hsize);
    // PHP also calls pf_intent here (strip mode); pfb_new overwrites the intent at the end, and it uses no RNG, so it is skipped.
    return s;
  }

  function draw(s, who, upTo) {
    var p = s[who];
    while (p.hand.length < upTo) {
      if (!p.draw.length) {
        if (!p.discard.length) return;
        p.draw = (who === 'foe' && truthy(p.ordered)) ? p.discard.slice().reverse() : shuffle(s, p.discard);
        p.discard = [];
      }
      p.hand.push(p.draw.pop());
    }
  }

  function fits(a, b) {
    if (!a) return false;
    if (a.r === null || a.r === undefined) return true;
    return a.r === nn(PF_HOLE[b.t], null);
  }
  function combo(a, b) { return a ? nn(PF_COMBOS[a.t + '>' + b.t], null) : null; }

  /** [value, fit, comboKey|null] of tile b played after a. */
  function value(a, b, cmb, fitBonus) {
    if (cmb === undefined) cmb = true; if (fitBonus === undefined) fitBonus = true;
    var v = Number(b.v);
    var fit = fits(a, b);
    if (fit && fitBonus) v += Math.max(1, iround(b.v * 0.25));
    var ck = null;
    var cb = cmb ? combo(a, b) : null;
    if (cb) { ck = a.t + '>' + b.t; v = v * cb.mul / 100 + (cb.flat === 'prev' ? toInt(a.v) : toInt(cb.flat)); }
    return [iround(v), fit, ck];
  }

  function checkEnd(s) {
    if (s.over) return true;
    var v1 = !!s.v1, fn = v1 ? round(s.fh.now, 1) : s.fh.now, bn = v1 ? round(s.bar.now, 1) : s.bar.now;   // 2.6.78 (v1): compared as shown (one decimal)
    if (fn >= s.fh.max) { s.over = 'seen_off'; return true; }
    if (s.cm > 0 && bn >= s.bar.max) { s.over = 'charmed'; return true; }
    if (s.me.hp <= 0) { s.over = 'defeat'; return true; }
    return false;
  }

  /** What one tile does when it fires for who (pf_apply). e is its event, filled in. */
  function apply(s, who, tile, val, fit, ck, prev, prevBy, e, root, seam) {
    if (root === undefined) root = true; if (seam === undefined) seam = true;
    var other = who === 'me' ? 'foe' : 'me';
    var mine = s[who], theirs = s[other];
    var m = String(nn(tile.m, ''));
    var dmg, abs, add, pr;
    var ft = !!(s.v1 && truthy(s.v1.tags));   // 2.6.74: creature-side tags work
    if (m === 'finisher' && who === 'me' && s.fh.now >= 0.6 * s.fh.max) val += 3;
    switch (tile.t) {
      case 'hurt':
        dmg = val;
        if (who === 'me' && tile.tag === 'bash') { dmg += mine.block; e.bashed = mine.block; mine.block = 0; }
        if (ft && who === 'foe' && (tile.tag === 'bash' || truthy(mine.bashnext))) { dmg += mine.block; e.bashed = mine.block; if (tile.tag === 'bash') mine.block = 0; mine.bashnext = 0; }
        if (who === 'foe') { var cut = Math.min(s.foe.agg, dmg); s.foe.agg -= cut; dmg -= cut; e.soothed = cut; }
        if (who === 'foe') {
          if (theirs.evade > 0) { theirs.evade--; e.evaded = dmg; dmg = 0; }
          abs = ft && tile.tag === 'pierce' ? 0 : Math.min(theirs.block, dmg); theirs.block -= abs; dmg -= abs;
          if (abs > 0 && theirs.thorns) { pr = 2 * s.hm; s.fh.now += pr; e.pricked = round(pr, 1); }
          theirs.hp = Math.max(0, theirs.hp - dmg);
          e.dmg = dmg; e.blocked = abs;
          if (ft) {
            if (tile.tag === 'poison') { theirs.poison = Math.min(PF_POISON_CAP, toInt(nn(theirs.poison, 0)) + 2); theirs.poison_v = Math.max(toInt(nn(theirs.poison_v, 0)), Math.max(1, toInt(Math.ceil(val / 3)))); e.poisoned = theirs.poison; }
            if (tile.tag === 'trip') { theirs.slowdraw = 1; e.tripped = 1; }
            if (root && tile.tag === 'quick') s.foe.again = 1;
          }
        } else {
          if (ft && theirs.evade > 0) { theirs.evade--; e.evaded = dmg; dmg = 0; }
          abs = tile.tag === 'pierce' ? 0 : Math.min(theirs.block, dmg); theirs.block -= abs; dmg -= abs;
          if (ft && abs > 0 && theirs.thorns) { pr = Math.max(2, iround(0.04 * mine.max)); mine.hp = Math.max(0, mine.hp - pr); e.pricked = pr; }
          add = dmg * s.hm;
          s.fh.now += add;
          e.dmg = dmg; e.blocked = abs; e.fh = round(add, 1);
          if (tile.tag === 'poison') { s.foe.poison = 2; s.foe.poison_v = Math.max(toInt(s.foe.poison_v), Math.max(1, toInt(Math.ceil(val / 2)))); }
          if (tile.tag === 'trip') s.foe.slow = 1;
          if (root && tile.tag === 'quick') { draw(s, 'me', Math.min(PF_HAND_CAP, s.me.hand.length + 1)); e.drew = 1; }
          if (m === 'leech' && dmg > 0) { mine.hp = Math.min(mine.max, mine.hp + 1 + intdiv(val, 6)); e.leeched = 1; }
          if (m === 'warm' && dmg > 0) { var w = 0.25 * dmg * s.cm; s.bar.now += w; s.bar.charm += w; }
        }
        break;
      case 'guard':
        mine.block += val + (m === 'hardy' ? 2 : 0);
        if (tile.tag === 'hold') mine.keep += val + (m === 'hardy' ? 2 : 0);
        if (tile.tag === 'thorns') mine.thorns = true;
        if (tile.tag === 'evade') mine.evade = 1;
        if (tile.tag === 'mend' && who === 'me') mine.hp = Math.min(mine.max, mine.hp + 2);
        if (m === 'spiky' && who === 'me') { pr = 2 * s.hm; s.fh.now += pr; }
        if (seam && prev && prev.t === 'hurt' && prevBy === other) {
          var refl = intdiv(val, 2);
          e.combo = truthy(e.combo) ? e.combo : 'Riposte';
          if (who === 'me') { add = refl * s.hm; s.fh.now += add; e.fh = round(add, 1); }
          else {
            abs = Math.min(theirs.block, refl); theirs.block -= abs; refl -= abs;
            e.reflect = Math.min(refl, theirs.hp); theirs.hp = Math.max(0, theirs.hp - refl);
          }
        }
        break;
      case 'heal':
        if (who === 'me') { mine.hp = Math.max(mine.hp, Math.min(mine.max, mine.hp + val + (m === 'tender' ? 2 : 0))); if (m === 'soft') s.foe.agg += 2; }
        else s.fh.now = Math.max(0.0, s.fh.now - val);
        break;
      case 'charm':
        if (who === 'me') {
          add = val * s.cm; s.bar.now += add; s.bar.charm += add; e.bar = round(add, 1);
          if (tile.tag === 'hum') s.foe.agg += 2;
          if (tile.tag === 'lull') s.foe.slow = 1;
          if (tile.tag === 'bond' && s.cm > 0 && s.bond < 3) { s.bond++; s.cm = Math.min(1.0, s.cm + 0.1); e.bonded = 1; }
          if (m === 'soft') s.foe.agg += 2;
        }
        break;
      case 'soothe':
        if (who === 'me') s.foe.agg += val;
        break;
      case 'trick':
        if (ft && who === 'foe') {   // the creature's class tricks
          if (root && tile.tag === 'quick') s.foe.again = 1;
          if (tile.tag === 'evade') mine.evade = 1;
          if (tile.tag === 'bash') mine.bashnext = 1;
          if (tile.tag === 'thorns') mine.thorns = true;
          if (tile.tag === 'poison') { theirs.poison = Math.min(PF_POISON_CAP, toInt(nn(theirs.poison, 0)) + 2); theirs.poison_v = Math.max(toInt(nn(theirs.poison_v, 0)), Math.max(1, toInt(Math.ceil(val / 2)))); e.poisoned = theirs.poison; }
          if (tile.tag === 'trip') { theirs.slowdraw = 1; e.tripped = 1; }
          if (tile.tag === 'heal') s.fh.now = Math.max(0.0, s.fh.now - val);
        }
        if (root && who === 'me' && tile.tag === 'pluck') {
          if (!s.can_pluck || truthy(s.plucked)) e.pluck = 'none';
          else {
            var ch = Math.min(35, 8 + 3 * mine.luckmod) / (s.boss ? 2 : 1);
            if (rand(s, 1000) < ch * 10) { s.plucked = 1; e.pluck = 'got'; } else e.pluck = 'missed';
          }
        }
        break;
      case 'item':
        if (who === 'me') { mine.hp = Math.max(mine.hp, Math.min(mine.max, mine.hp + val + (m === 'tender' ? 2 : 0))); if (m === 'soft') s.foe.agg += 2; }
        break;
    }
    if (root && who === 'me' && m === 'sticky' && fit) draw(s, 'me', Math.min(PF_HAND_CAP, s.me.hand.length + 1));
    if (root && who === 'me' && m === 'lucky' && !(s.lucky_used && truthy(s.lucky_used[tile.k]))) {
      if (!s.lucky_used) s.lucky_used = {};
      s.lucky_used[tile.k] = 1; mine.redraws = Math.min(3, mine.redraws + 1);
    }
    if (truthy(ck) && truthy(PF_COMBOS[ck].barPct) && who === 'me') {
      add = val * PF_COMBOS[ck].barPct / 100 * s.cm; s.bar.now += add; s.bar.charm += add; e.bar = round(Number(nn(e.bar, 0)) + add, 1);
    }
  }

  // ------------------------------------------------------------------ pf_view
  function open(s) {
    if (!s.strip.length) return [null, null];
    var x = s.strip[s.strip.length - 1];
    return [x.tile, x.by];
  }
  function pfView(s) {
    var strip = s.strip.slice(-4).map(function (x) { return { by: x.by, n: x.tile.n, t: x.tile.t, v: x.tile.v, r: x.tile.r }; });
    var o = open(s), ot = o[0], oby = o[1];
    var openR = ot ? nn(ot.r, null) : null;
    return {
      turn: s.turn, over: s.over,
      hp: s.me.hp, max: s.me.max, block: s.me.block,
      hand: s.me.hand.map(function (t) { return { n: t.n, t: t.t, v: t.v, r: t.r, hole: PF_HOLE[t.t], tag: t.tag, m: String(nn(t.m, '')) }; }),
      redraws: s.me.redraws,
      bar: { now: round(s.bar.now, 1), max: s.bar.max, hurt: 0, charm: round(s.bar.charm, 1) },
      fh: { now: round(s.fh.now, 1), max: s.fh.max }, charmable: s.cm > 0,
      foe: { name: s.foe.name, hand: s.foe.hand.length, intent: s.foe.intent, block: s.foe.block, calm: s.foe.agg },
      piles: { draw: s.me.draw.length, discard: s.me.discard.length }, strip: strip, open: openR, open_t: ot ? nn(ot.t, null) : null, open_v: ot ? nn(ot.v, 0) : 0, open_by: oby, can_run: s.run_ok, combos: clone(PF_COMBOS)
    };
  }

  // ------------------------------------------------------------------ v1 board rules (pfboard.php "v1 board rules"; a fight started with opt.v1 carries s.v1, every other fight plays as before)
  var PFB_SIZE = { small: [4, 4], medium: [4, 4], large: [4, 4], boss: [4, 4] };
  var PFB_GROUND = { small: [2, 2, 1], medium: [3, 2, 1], large: [3, 3, 1], boss: [4, 3, 1] }, PFB_GROUND_DIST = [1, 2];
  var PFB_EVENTS = { small: 1, medium: 2, large: 2, boss: 2 }, PFB_EVENT_KINDS = ['sunbeam', 'creep', 'gust', 'thorn', 'puddle'];
  var PFB_EVENT_NAME = { sunbeam: 'Sunbeam', creep: 'Bramble creep', puddle: 'Puddle', gust: 'Gust', thorn: 'Thorn burst', bramble: 'Bramble', poison: 'Poison', place: 'Environment', pass: 'Environment', expire: 'Environment' };
  var PFB_USEUP = 3, PFB_SUN_MULT = 2.0, PFB_BRAMBLE = 0.10, PFB_BRAMBLE_FOE = 1.0, PFB_THORN = 0.10, PFB_EVENT_FOE = 0.5, PFB_TEAM2 = 1.3, PFB_TEAM3 = 1.6;
  var PFB_TEAM_SRC = ['pal', 'tool', 'crop'], PFB_SRC = ['basic', 'knack', 'calling', 'tool', 'crop', 'craft', 'pal', 'region', 'creature', 'env'];
  var PFB_SRC_FAM = { pal: 'body', tool: 'craft', crop: 'mind', craft: 'craft' }, PFB_UP = { hurt: 1, charm: 1, trick: 1 };
  var PFB_CLASS_LEAN = { critter: 'mind', insect: 'mind', water: 'body', bird: 'craft', plant: 'mind', fungus: 'mind', reptile: 'craft', amphibian: 'craft', beast: 'body' };
  var PFB_LIFE_MIN = 2, PFB_LIFE_MAX = 4, PFB_TOOL_WEAR = 2;
  var PFB_V1_FOE_MULT = { small: 0.95, medium: 0.60, large: 0.42, boss: 0.585 }, PFB_V1_BAR_MULT = { small: 0.828, medium: 0.994, large: 1.15, boss: 0.611 };   // after 2.6.94 (AIMSTICK): boss x1.3 with its bar x0.8 (was 0.45 / 0.764)
  // after 2.6.94: the LEVEL CURVE (PFB_V1_LEVEL in pfboard.php, where the why is): f = clamp(1 + slope x (level - ref), lo, hi) as [slope, ref, lo, hi]; piece values x f, bar x min(1, f)
  var PFB_V1_LEVEL = { small: [0.0, 1, 1.0, 1.0], medium: [0.05, 12, 0.85, 1.35], large: [0.025, 22, 0.85, 1.10], boss: [0.0, 1, 1.0, 1.0] };
  // the compat rules (PFB_V1_PRE in pfboard.php, where the keys are explained): a saved fight without a key plays by the 2.6.94 value
  var PFB_V1_PRE = { aside: 1, must: 1, freepass: 0, flip1: 1, nowm: 0, redraw: 0, onebar: 0, aimtot: 0, keepmine: 0, aimhit: 0, useroot: 0, kinds: 0 };
  function v1r(s, k) { var v = s.v1 && s.v1[k] !== undefined && s.v1[k] !== null ? s.v1[k] : PFB_V1_PRE[k]; return toInt(v === undefined ? 0 : v); }
  function v1Lvx(c, lv) { return round(Math.max(Number(c[2]), Math.min(Number(c[3]), 1 + Number(c[0]) * (lv - toInt(c[1])))), 4); }   // 2.6.79 retune for isolated environment pieces   // 2.6.75 retune for environment pieces
  // 2.6.75 ENVIRONMENT PIECES: the environment is a third player; after the creature's turn it places one piece from its own deck, its next piece lies face up a round ahead.
  // PFB_ENV_ROWS is a copy of game/includes/data/pf_env.txt (key, name, kind, edges L,R,T,B, life, copies small/medium/large/boss, blurb); tests/pfengine_js.sh compares the two.
  var PFB_ENV_KINDS = ['sun', 'bramble', 'rain', 'wind', 'mud', 'thorn'], PFB_ENV_N = { small: 2, medium: 2, large: 2, boss: 2 }, PFB_RAIN = 0.15, PFB_THORN_FOE = 0.5, PFB_ENV_CAP = 0.7, PFB_MUD = 0.25;
  var PFB_ENV_EDGE = { h: 'hole', k: 'knob', b: 'body', m: 'mind', c: 'craft' };
  var PFB_ENV_ROWS = [
    ['sun', 'Sun', 'sun', 'hb,km,kc,hc', 2, [2, 2, 2, 2], 'Fire it in your chain: your pieces in that chain count double.'],
    ['bramble', 'Bramble', 'bramble', 'hm,kc,kb,hb', 3, [1, 2, 2, 3], 'Fire it in your chain: the other side loses a tenth of its health.'],
    ['rain', 'Rain', 'rain', 'hc,kb,km,hm', 2, [2, 2, 2, 2], 'Fire it in your chain: you get guard.'],
    ['wind', 'Wind', 'wind', 'hb,kc,hm,km', 2, [1, 1, 1, 1], 'Fire it in your chain: the piece its arrow points at slides one cell.'],
    ['mud', 'Mud', 'mud', 'f,f,f,f', 3, [1, 1, 1, 1], 'Nothing links to it, and a piece next to it counts a quarter less.'],
    ['thorn', 'Thornburst', 'thorn', 'hm,kb,hc,kc', 3, [1, 2, 2, 2], 'Fire it in your chain and you lose a tenth of your health. The creature loses half as much.']
  ];
  var PFB_ENV_REGIONS = { NA: { wind: 1 }, CA: { sun: 1 }, CB: { sun: 1 }, SA: { rain: 1 }, NWE: { rain: 1 }, SE: { sun: 1 }, EE: { bramble: 1 }, MENA: { wind: 1 }, WCA: { bramble: 1 }, ESA: { thorn: 1 }, CSA: { mud: 1 }, EA: { rain: 1 }, SEA: { rain: 1, mud: 1 }, OC: { wind: 1 } };
  var KIND_GROUND = { sunbeam: 'sun', creep: 'br', puddle: 'mud' }, GROUND_N = { sun: 'nsun', br: 'nbr', mud: 'nmud' };

  function isNumeric(v) { return (typeof v === 'number' && isFinite(v)) || (typeof v === 'string' && v.trim() !== '' && isFinite(Number(v))); }
  function v1Cfg(size, over, level) {
    if (!has(PFB_SIZE, size)) size = 'medium';
    var g = PFB_GROUND[size];
    var cfg = { w: PFB_SIZE[size][0], h: PFB_SIZE[size][1], ground: 0, nsun: g[0], nbr: g[1], nmud: g[2], sun: PFB_SUN_MULT, bramble: PFB_BRAMBLE, br_foe: PFB_BRAMBLE_FOE,
      events: 0, nev: PFB_EVENTS[size], thorn: PFB_THORN, ev_foe: PFB_EVENT_FOE, limit: PFB_USEUP, aim: 1, team2: PFB_TEAM2, team3: PFB_TEAM3,
      edges: 1, flip: 1, life: 1, tags: 1, foe: PFB_V1_FOE_MULT[size], bar: PFB_V1_BAR_MULT[size],
      env: 1, envn: PFB_ENV_N[size], rain: PFB_RAIN, th_foe: PFB_THORN_FOE, mud: PFB_MUD, envcap: PFB_ENV_CAP };   // 2.6.75: environment pieces; env 0 with ground 1, events 1 gives the 2.6.74 terrain
    for (var pk in PFB_V1_PRE) cfg[pk] = PFB_V1_PRE[pk];
    var INTS = { aside: 1, must: 1, freepass: 1, flip1: 1, nowm: 1, redraw: 1, onebar: 1, aimtot: 1, keepmine: 1, aimhit: 1, useroot: 1, kinds: 1, w: 1, h: 1, ground: 1, nsun: 1, nbr: 1, nmud: 1, events: 1, nev: 1, limit: 1, aim: 1, edges: 1, flip: 1, life: 1, tags: 1, env: 1, envn: 1 };
    over = over || {};
    for (var k in over) if (has(cfg, k) && isNumeric(over[k])) cfg[k] = INTS[k] ? toInt(over[k]) : Number(over[k]);
    if (over.foe_x !== undefined && over.foe_x !== null) cfg.foe = round(cfg.foe * Number(over.foe_x), 4);
    if (over.bar_x !== undefined && over.bar_x !== null) cfg.bar = round(cfg.bar * Number(over.bar_x), 4);
    level = toInt(level || 0);
    cfg.lvx = level > 0 ? v1Lvx(Array.isArray(over.lv) ? over.lv : PFB_V1_LEVEL[size], level) : 1.0;   // the level curve: piece values x f, bar x min(1, f)
    cfg.foe = round(cfg.foe * cfg.lvx, 4); cfg.bar = round(cfg.bar * Math.min(1.0, cfg.lvx), 4);
    if (!cfg.edges) cfg.flip = 0;
    return cfg;
  }
  // ------------------------------------------------------------------ 2.6.75 environment pieces (pfb_env_* in pfboard.php)
  function envEdge(c) {
    if (c === 'w') return ['wild', null];
    if (c.length === 2 && (c[0] === 'h' || c[0] === 'k') && has(PFB_ENV_EDGE, c[1]) && c[1] !== 'h' && c[1] !== 'k') return [PFB_ENV_EDGE[c[0]], PFB_ENV_EDGE[c[1]]];
    return ['flat', null];
  }
  var ENV_TABLE = null;
  function envTable() {
    if (ENV_TABLE) return ENV_TABLE;
    var T = { pieces: {}, regions: clone(PFB_ENV_REGIONS) }, sizes = Object.keys(PFB_SIZE);
    PFB_ENV_ROWS.forEach(function (r) {
      var ed = r[3].split(','), w = {}; sizes.forEach(function (z, i) { w[z] = r[5][i]; });
      T.pieces[r[0]] = { k: 'e:' + r[0], n: r[1], env: r[2], ed: { L: envEdge(ed[0]), R: envEdge(ed[1]), T: envEdge(ed[2]), B: envEdge(ed[3]) }, life: Math.max(PFB_LIFE_MIN, Math.min(PFB_LIFE_MAX, r[4])), w: w, blurb: r[6] };
    });
    return ENV_TABLE = T;
  }
  function envDeck(size, region) {
    if (!has(PFB_SIZE, size)) size = 'medium';
    var T = envTable(), bias = (region && has(T.regions, region)) ? T.regions[region] : {}, deck = [];
    for (var key in T.pieces) {
      var p = T.pieces[key], n = Math.max(0, toInt(p.w[size]) + toInt(nn(bias[p.env], 0)));
      for (var i = 0; i < n; i++) deck.push({ k: p.k, n: p.n, t: 'env', v: 0, r: null, tag: '', m: '', src: 'env', env: p.env, life: p.life, ed: clone(p.ed) });
    }
    return deck;
  }
  function envDraw(s) {
    while (s.env.next.length < toInt(s.v1.envn)) {
      if (!s.env.draw.length && s.env.discard.length) { s.env.draw = shuffle(s, s.env.discard); s.env.discard = []; }
      if (!s.env.draw.length) break;
      s.env.next.push(s.env.draw.pop());
    }
  }
  function mudNear(s, x, y) {
    for (var d in PFB_SIDE) { var n = pieceAt(s, x + PFB_SIDE[d][0], y + PFB_SIDE[d][1]); if (n && n.by === 'env' && n.tile.env === 'mud') return true; }
    return false;
  }
  function envCells(s, tile) {   // 2.6.79: isolated empty cells, the 3 farthest from every piece (farthest first); else a fitting cell that links to nothing, else any fitting cell
    var iso = [], x, y, k, d, p, ok, sd;
    if (Object.keys(s.pcs).length) for (y = 0; y < pfbH(s); y++) for (x = 0; x < pfbW(s); x++) {
      if (s.cell[x + ',' + y] !== undefined) continue;
      ok = true; for (k in PFB_SIDE) { sd = PFB_SIDE[k]; if (pieceAt(s, x + sd[0], y + sd[1])) { ok = false; break; } }
      if (!ok) continue;
      d = 99; for (k in s.pcs) { p = s.pcs[k]; d = Math.min(d, Math.abs(p.x - x) + Math.abs(p.y - y)); }
      iso.push([d, y, x]);
    }
    if (iso.length) { iso.sort(function (a, b) { return b[0] - a[0] || a[1] - b[1] || a[2] - b[2]; }); return iso.slice(0, 3).map(function (o) { return [o[2], o[1]]; }); }
    var fit = [], link = [];
    for (y = 0; y < pfbH(s); y++) for (x = 0; x < pfbW(s); x++) { var j = check(s, tile, x, y); if (j === null) continue; fit.push([x, y]); if (hasLink(j)) link.push([x, y]); }
    var seen = {}; link.forEach(function (c) { seen[c[0] + ',' + c[1]] = 1; });
    var free = fit.filter(function (c) { return !seen[c[0] + ',' + c[1]]; });
    return free.length ? free : fit;
  }
  function envWindDir(s, x, y) {
    var ok = [];
    for (var d in PFB_SIDE) {
      var sd = PFB_SIDE[d], n = pieceAt(s, x + sd[0], y + sd[1]), bx = x + 2 * sd[0], by = y + 2 * sd[1];
      if (n && n.by !== 'none' && inb(s, bx, by) && !has(s.cell, bx + ',' + by)) ok.push(d);
    }
    if (!ok.length) ok = Object.keys(PFB_SIDE);
    return ok[rand(s, ok.length)];
  }
  /** The environment's turn: it puts its face-up pieces on the board, one after the other, then turns new ones face up. Nothing fires. */
  function envPlace(s) {
    s.envlog = []; var keep = [];
    if (!s.env.next.length) s.envlog.push({ k: 'pass', x: null, y: null, me: 0, foe: 0.0 });
    s.env.next.forEach(function (tile) {
      var full = Object.keys(s.cell).length >= Number(nn(s.v1.envcap, 1)) * pfbW(s) * pfbH(s);
      var cs = full ? [] : envCells(s, tile);
      if (!cs.length) { var P = { k: 'pass', x: null, y: null, me: 0, foe: 0.0, kind: tile.env, n: tile.n }; if (full) P.full = 1; s.envlog.push(P); keep.push(tile); return; }
      var c = cs[rand(s, cs.length)], x = c[0], y = c[1];
      if (tile.env === 'wind') tile.dir = envWindDir(s, x, y);
      var id = ++s.pid; s.seq++;
      s.pcs[id] = { id: id, by: 'env', tile: tile, x: x, y: y, born: s.round + 1, seq: s.seq };
      s.cell[x + ',' + y] = id;
      var L = { k: 'place', x: x, y: y, me: 0, foe: 0.0, id: id, kind: tile.env, n: tile.n };
      if (tile.dir !== undefined && tile.dir !== null) L.dir = tile.dir;
      s.envlog.push(L);
    });
    s.env.next = keep;
    envDraw(s);
  }
  function envCost(s, who, frac) {
    if (frac <= 0) return 0.0;
    if (who === 'me') { var d = Math.max(1, iround(frac * s.me.max)); s.me.hp = Math.max(0, s.me.hp - d); return d; }
    var a = frac * s.fh.max; s.fh.now += a; return a;
  }
  /** An environment piece fires in a chain started by rb: its effect goes to that side. Returns its event. */
  function envFire(s, p, rb) {
    var t = p.tile, kind = String(t.env), ot = rb === 'me' ? 'foe' : 'me', v1 = s.v1;
    var e = { by: 'env', id: p.id, root: false, tag: '', mod: '', k: t.k, n: t.n, t: 'env', v: 0, fit: false, combo: null, env: 'fire', kind: kind, 'for': rb, x: p.x, y: p.y, me: 0, foe: 0.0 };
    if (kind === 'bramble') e[ot] = envCost(s, ot, Number(v1.bramble) * (ot === 'foe' ? Number(v1.br_foe) : 1.0));
    else if (kind === 'thorn') e[rb] = envCost(s, rb, Number(v1.thorn) * (rb === 'foe' ? Number(v1.th_foe) : 1.0));
    else if (kind === 'rain') { var g = Math.max(1, iround(Number(v1.rain) * (rb === 'me' ? s.me.max : s.fh.max))); s[rb].block += g; e.guard = g; e.v = g; }
    else if (kind === 'wind') {
      var d = String(nn(t.dir, 'R')), sd = PFB_SIDE[d]; e.dir = d;
      var x = p.x + sd[0], y = p.y + sd[1], nx = x + sd[0], ny = y + sd[1], q = pieceAt(s, x, y);
      if (!truthy(v1.nowind) && q && q.by !== 'none' && inb(s, nx, ny) && !has(s.cell, nx + ',' + ny)) {
        delete s.cell[x + ',' + y]; s.cell[nx + ',' + ny] = q.id; s.pcs[q.id].x = nx; s.pcs[q.id].y = ny;
        e.moved = { id: q.id, by: q.by, n: q.tile.n, x: nx, y: ny };
      }
    }
    e.me = toInt(e.me); e.foe = round(Number(e.foe), 1);
    return e;
  }

  function pfbW(s) { return nn(s.w, PFB_W); }
  function pfbH(s) { return nn(s.h, PFB_H); }
  function ter(s, x, y) { return (s.ter && s.ter[x + ',' + y]) || ''; }
  function noTer(s) { return !s.ter || isEmpty(s.ter); }
  function inb(s, x, y) { return x >= 0 && y >= 0 && x < pfbW(s) && y < pfbH(s); }
  function srcOf(t) {
    if (t.src !== undefined && t.src !== null && PFB_SRC.indexOf(t.src) >= 0) return t.src;
    var k = String(nn(t.k, ''));
    if (k.indexOf('pal:') === 0) return 'pal';
    if (k.indexOf('f:') === 0) return 'creature';
    if (PF_BASE_KEYS.indexOf(k) >= 0 || k === 'breather') return 'basic';
    if (callingKeys().indexOf(k) >= 0) return 'calling';
    return 'knack';
  }
  function authorEdges(t, col, up) {
    if (up === undefined || up === null) up = has(PFB_UP, t.t);
    var fam = nn(PF_HOLE[t.t], 'body');
    return { L: ['hole', fam], R: ['knob', nn(t.r, fam)], T: [up ? 'knob' : 'hole', col], B: [up ? 'hole' : 'knob', col] };
  }
  function lean(c) {
    var fam = ['body', 'mind', 'craft'];
    if (fam.indexOf(nn(c.lean, '')) >= 0) return c.lean;
    var cl = String(nn(c['class'], '')).toLowerCase();
    for (var k in PFB_CLASS_LEAN) if (cl !== '' && cl.indexOf(k) >= 0) return PFB_CLASS_LEAN[k];
    return fam[crc32(String(nn(c.slug, nn(c.name, '')))) % 3];
  }
  function v1Tile(t, cfg, col) {
    t.src = srcOf(t);
    if (cfg.life) t.life = Math.max(PFB_LIFE_MIN, Math.min(PFB_LIFE_MAX, toInt(nn(t.life, t.tag === 'quick' ? 2 : (t.tag === 'hold' ? 4 : PFB_LIFE)))));
    else delete t.life;
    delete t.ed;
    if (!cfg.edges || t.edges === false) return t;
    t.ed = (t.edges && typeof t.edges === 'object') ? clone(t.edges) : authorEdges(t, String(nn(t.col, nn(PFB_SRC_FAM[t.src], nn(col, nn(PF_HOLE[t.t], 'body'))))), (t.up !== undefined && t.up !== null) ? truthy(t.up) : null);
    return t;
  }
  function v1Tiles(s, c) {
    var order = {}, ln = lean(c);
    foeDeck(c).forEach(function (t, i) { order[t.k] = i; });
    ['hand', 'draw', 'discard'].forEach(function (z) {
      s.me[z].forEach(function (t) { v1Tile(t, s.v1); });
      s.foe[z].forEach(function (t) { v1Tile(t, s.v1, nn(order[t.k], 0) % 5 < 3 ? ln : null); });
    });
  }
  function lifeOf(s, p) {
    if (p.by === 'none') return 1;
    return (s.v1 && truthy(s.v1.life)) ? toInt(nn(p.tile.life, PFB_LIFE)) : PFB_LIFE;
  }
  function discardPiece(s, p) {
    if (p.by === 'none') return;
    var t = clone(p.tile); delete t.flip; delete t.ft; delete t.dir;
    s[p.by].discard.push(t);
  }
  function seedGround(s) {
    s.ter = {}; if (!s.v1.ground) return;
    var cx = intdiv(pfbW(s), 2), cy = intdiv(pfbH(s), 2), cand = [];
    for (var y = 0; y < pfbH(s); y++) for (var x = 0; x < pfbW(s); x++) { var d = Math.abs(x - cx) + Math.abs(y - cy); if (d >= PFB_GROUND_DIST[0] && d <= PFB_GROUND_DIST[1]) cand.push(x + ',' + y); }
    cand = shuffle(s, cand);
    [['sun', s.v1.nsun], ['br', s.v1.nbr], ['mud', s.v1.nmud]].forEach(function (g) { for (var i = 0; i < g[1] && cand.length; i++) s.ter[cand.pop()] = g[0]; });
  }
  function groundSet(s, x, y, kind) {
    delete s.ter[x + ',' + y]; s.ter[x + ',' + y] = kind;
    var cap = Math.max(1, toInt(s.v1[GROUND_N[kind]]));
    var have = Object.keys(s.ter).filter(function (k) { return s.ter[k] === kind; });
    while (have.length > cap) delete s.ter[have.shift()];
  }
  function envHurt(s, who, frac, tag) {
    if (frac <= 0) return 0.0;
    if (who === 'me') { var d = Math.max(1, iround(frac * s.me.max)); s.me.hp = Math.max(0, s.me.hp - d); return d; }
    if (who === 'foe') { var a = frac * Number(s.v1[tag === 'thorn' ? 'ev_foe' : 'br_foe']) * s.fh.max; s.fh.now += a; return a; }
    return 0.0;
  }
  function zone(e) { var z = [[e.x, e.y]]; for (var sd in PFB_SIDE) z.push([e.x + PFB_SIDE[sd][0], e.y + PFB_SIDE[sd][1]]); return z; }
  /** The terrain turn (after the creature's): the announced events land in order, then bramble pricks. s.envlog = one note per event. */
  function envTurn(s) {
    s.envlog = [];
    if (s.v1.events) nn(s.envs, []).forEach(function (e) {
      var on = pieceAt(s, e.x, e.y), ob = on && on.by !== 'none' ? on.by : null, L = { k: e.kind, x: e.x, y: e.y, me: 0, foe: 0.0 };
      if (e.kind === 'gust') {
        var id = s.cell[e.x + ',' + e.y], d = PFB_SIDE[e.dir], nx = e.x + d[0], ny = e.y + d[1]; L.dir = e.dir;
        if (id !== undefined && id !== null && ob && inb(s, nx, ny) && !has(s.cell, nx + ',' + ny)) {
          delete s.cell[e.x + ',' + e.y]; s.cell[nx + ',' + ny] = id; s.pcs[id].x = nx; s.pcs[id].y = ny;
          L.moved = { id: id, by: ob, n: on.tile.n, x: nx, y: ny };
        }
      } else if (e.kind === 'thorn') {
        zone(e).forEach(function (z) { var p = pieceAt(s, z[0], z[1]); if (p && p.by !== 'none') L[p.by] += envHurt(s, p.by, Number(s.v1.thorn), 'thorn'); });
      } else {
        groundSet(s, e.x, e.y, KIND_GROUND[e.kind]);
        if (ob) L.on = { id: on.id, by: ob, n: on.tile.n };
      }
      L.me = toInt(L.me); L.foe = round(L.foe, 1);
      s.envlog.push(L);
    });
    if (s.v1.ground) {
      var B = { k: 'bramble', x: null, y: null, me: 0, foe: 0.0, ids: [] };
      for (var pid in s.pcs) { var q = s.pcs[pid]; if (q.by !== 'none' && ter(s, q.x, q.y) === 'br') { B[q.by] += envHurt(s, q.by, Number(s.v1.bramble), 'br'); B.ids.push(q.id); } }
      B.me = toInt(B.me); B.foe = round(B.foe, 1);
      if (B.ids.length) s.envlog.push(B);
    }
    checkEnd(s);
  }
  /** The terrain turn as events for the replay (by and ta 'env'). */
  function envEvents(s) {
    return nn(s.envlog, []).map(function (L) {
      var e = { by: 'env', ta: 'env', env: L.k, tag: '', k: 'env:' + L.k, n: nn(PFB_EVENT_NAME[L.k], 'Terrain'), t: 'env', v: 0, fit: false, combo: null, x: L.x, y: L.y, me: L.me, foe: L.foe };
      ['dir', 'moved', 'on', 'ids', 'id', 'kind', 'full'].forEach(function (k) { if (L[k] !== undefined && L[k] !== null) e[k] = clone(L[k]); });
      if (L.n !== undefined && L.n !== null) e.n = L.n;   // 2.6.75: an environment piece placed (or kept back): its name
      e.barnow = round(Number(s.bar.now), 1); e.fhnow = round(Number(s.fh.now), 1); e.hpnow = toInt(s.me.hp); e.gnow = toInt(s.me.block);
      return e;
    });
  }
  function envLine(e, foe) {
    var cost = [];
    if (truthy(e.me)) cost.push('you lose ' + toInt(e.me) + ' health');
    if (truthy(e.foe)) cost.push('the ' + foe + ' loses ' + iround(Number(e.foe)));
    var c = cost.length ? ': ' + cost.join(', ') : '';
    var whose = function (p) { return (p.by === 'me' ? 'your ' : 'the ' + foe + '’s ') + p.n; };
    switch (e.env) {
      case 'fire':   // 2.6.75: an environment piece fired in a chain
        var mine = nn(e['for'], 'me') === 'me';
        switch (nn(e.kind, '')) {
          case 'sun': return '☀️ Sun: ' + (mine ? 'your pieces in this chain count double.' : 'the ' + foe + '’s pieces in this chain count double.');
          case 'bramble': return '🌿 Bramble' + (c !== '' ? c : ': nothing happens') + '.';
          case 'thorn': return '🌵 Thornburst' + (c !== '' ? c : ': nothing happens') + '.';
          case 'rain': return '🌧️ Rain: ' + (mine ? 'you get ' : 'the ' + foe + ' gets ') + toInt(nn(e.guard, 0)) + ' guard.';
          case 'wind': return e.moved ? '💨 Wind: ' + whose(e.moved) + ' is pushed one cell.' : '💨 Wind: nothing moves.';
          default: return '🟫 ' + String(e.n) + '.';
        }
      case 'place': return '🍃 The environment places ' + String(e.n) + '.';
      case 'pass': return (e.kind !== undefined && e.kind !== null) ? (truthy(e.full) ? '🍃 The board is full: the environment keeps ' + String(e.n) + '.' : '🍃 The environment finds no place for ' + String(e.n) + '.') : '🍃 The environment has no piece to place.';
      case 'expire': return '🍂 ' + (nn(e.ids, []).length === 1 ? 'An environment piece fades.' : nn(e.ids, []).length + ' environment pieces fade.');
      case 'sunbeam': return '☀️ Sunbeam: a cell turns sunny' + (e.on ? ' under ' + whose(e.on) : '') + '.';
      case 'creep': return '🌿 Bramble creep: a cell turns to bramble' + (e.on ? ' under ' + whose(e.on) : '') + '.';
      case 'puddle': return '💧 Puddle: a cell turns to mud' + (e.on ? ', and ' + whose(e.on) + ' no longer links' : '') + '.';
      case 'gust': return e.moved ? '💨 Gust: ' + whose(e.moved) + ' is pushed one cell.' : '💨 Gust: nothing moves.';
      case 'thorn': return '🌵 Thorn burst' + (c !== '' ? c : ': nothing in reach') + '.';
      case 'poison': return '🧪 The poison works on you' + c + '.';
      default: return '🌿 Bramble pricks' + c + '.';
    }
  }
  function envBias(s, who, x, y, tile) {
    var b = 0.0, m = who === 'foe' ? 0.8 * s.fh.max : 0.7 * s.me.max;
    nn(s.envs, []).forEach(function (e) {
      if (e.kind === 'thorn') { zone(e).forEach(function (z) { if (z[0] === x && z[1] === y) b -= Number(s.v1.thorn) * (who === 'foe' ? Number(s.v1.ev_foe) : 1.0) * m; }); }
      else if (e.x === x && e.y === y) {
        if (e.kind === 'creep') b -= Number(s.v1.bramble) * (who === 'foe' ? Number(s.v1.br_foe) : 1.0) * m;
        else if (e.kind === 'sunbeam' && tile && (tile.t === 'hurt' || tile.t === 'charm')) b += 0.3 * tile.v;
      }
    });
    return b;
  }
  function forecast(s) {
    s.envs = []; if (!s.v1.events) return;
    var cand = {}, pcs = [], id, sd;
    for (id in s.pcs) {
      var p = s.pcs[id]; if (p.by !== 'none') pcs.push(p.x + ',' + p.y); cand[p.x + ',' + p.y] = 1;
      for (sd in PFB_SIDE) { var x = p.x + PFB_SIDE[sd][0], y = p.y + PFB_SIDE[sd][1]; if (inb(s, x, y)) cand[x + ',' + y] = 1; }
    }
    var keys = Object.keys(cand);
    for (var i = 0; i < toInt(s.v1.nev) && keys.length; i++) {
      var kind = PFB_EVENT_KINDS[rand(s, PFB_EVENT_KINDS.length)], dir = null, key;
      if (kind === 'gust') {
        if (!pcs.length) continue;
        key = pcs[rand(s, pcs.length)]; var xy = key.split(',').map(Number), dirs = [];
        for (sd in PFB_SIDE) { var nx = xy[0] + PFB_SIDE[sd][0], ny = xy[1] + PFB_SIDE[sd][1]; if (inb(s, nx, ny) && !has(s.cell, nx + ',' + ny)) dirs.push(sd); }
        if (!dirs.length) dirs = Object.keys(PFB_SIDE);
        dir = dirs[rand(s, dirs.length)];
        if (keys.indexOf(key) < 0) continue;
      } else {
        var gk = nn(KIND_GROUND[kind], null);
        var ok = keys.filter(function (k) { return gk === null || nn(s.ter[k], '') !== gk; }); if (!ok.length) continue;
        key = ok[rand(s, ok.length)];
      }
      keys = keys.filter(function (k) { return k !== key; });
      var c = key.split(',').map(Number);
      s.envs.push({ kind: kind, x: c[0], y: c[1], dir: dir });
    }
  }
  function canFlip(s, handIdx) {
    var t = isInt(handIdx) ? nn(s.me.hand[handIdx], null) : null;
    if (!s.v1 || !truthy(s.v1.flip) || truthy(s.over) || !t || !t.ed) return false;
    return toInt(nn(s.me.flipt, 0)) !== toInt(s.turn) || toInt(nn(t.ft, 0)) === toInt(s.turn);
  }
  /** v1 FLIP: swap the top and bottom edges of a hand piece (free, once a turn). Returns an error or null. */
  function flip(s, handIdx, turn) {
    if (truthy(s.over)) return 'The fight is over.';
    if (turn !== s.turn) return 'stale';
    if (!s.v1 || !truthy(s.v1.flip)) return 'Pieces cannot be flipped in this fight.';
    var t = isInt(handIdx) ? nn(s.me.hand[handIdx], null) : null; if (!t) return 'No such piece in your hand.';
    if (!t.ed) return 'That piece cannot be flipped.';
    if (!canFlip(s, handIdx)) return 'You have already flipped a piece this turn.';
    if (toInt(nn(t.ft, 0)) === toInt(s.turn)) { delete t.ft; s.me.flipt = 0; }
    else { t.ft = toInt(s.turn); s.me.flipt = toInt(s.turn); }
    if (truthy(t.flip)) delete t.flip; else t.flip = true;
    return null;
  }
  function flipped(t) { var f = clone(t); if (truthy(f.flip)) delete f.flip; else f.flip = true; return f; }

  // ------------------------------------------------------------------ board: edges and joints
  var EDGE_CACHE = {};
  function edges(t) {
    if (t.k === 'blank') return { L: ['wild', null], R: ['wild', null], T: ['wild', null], B: ['wild', null] };   // the blank centre piece (opt blank): fits and links with everything
    if (t.ed) return truthy(t.flip) ? { L: t.ed.L, R: t.ed.R, T: t.ed.B, B: t.ed.T } : t.ed;   // v1: authored edges (a flipped piece swaps top and bottom)
    var key = t.k + '|' + t.t + '|' + (t.r === null || t.r === undefined ? '' : t.r);
    if (has(EDGE_CACHE, key)) return EDGE_CACHE[key];
    var fam = ['body', 'mind', 'craft'];
    var mk = function (salt) {
      var h = crc32(t.k + salt);
      if (h % 4 === 0) return ['flat', null];
      return [Math.floor(h / 4) % 2 ? 'knob' : 'hole', fam[Math.floor(h / 8) % 3]];
    };
    return EDGE_CACHE[key] = { L: ['hole', nn(PF_HOLE[t.t], 'body')], R: truthy(t.r) ? ['knob', t.r] : ['flat', null], T: mk('|T'), B: mk('|B') };
  }

  function joint(a, b) {
    if (a[0] === 'wild' || b[0] === 'wild') return [true, true];
    if (a[0] === 'flat' || b[0] === 'flat') return [true, false];
    var ok = a[0] !== b[0] && a[1] === b[1];
    return [ok, ok];
  }

  function pieceAt(s, x, y) {
    var id = s.cell[x + ',' + y];
    return (id === undefined || id === null) ? null : s.pcs[id];
  }

  function check(s, tile, x, y) {
    if (x < 0 || y < 0 || x >= pfbW(s) || y >= pfbH(s) || has(s.cell, x + ',' + y)) return null;
    if (isEmpty(s.pcs)) return (x === intdiv(pfbW(s), 2) && y === intdiv(pfbH(s), 2)) ? [] : null;
    var e = edges(tile), joints = [];
    for (var side in PFB_SIDE) {
      var sd = PFB_SIDE[side], n = pieceAt(s, x + sd[0], y + sd[1]);
      if (!n) continue;
      var j = joint(e[side], edges(n.tile)[sd[2]]);
      if (!j[0]) return null;
      joints.push([side, toInt(n.id), j[1] && (noTer(s) || (ter(s, x, y) !== 'mud' && ter(s, x + sd[0], y + sd[1]) !== 'mud'))]);   // v1: mud blocks links
    }
    if (!joints.length && truthy(s.aimforce)) return [];   // AIMSTICK (v1 aim): the shown aim lands even when its cell now touches nothing
    return joints.length ? joints : null;
  }

  function hasLink(joints) {
    if (joints) for (var i = 0; i < joints.length; i++) if (joints[i][2]) return true;
    return false;
  }

  /** A piece has to connect (make a linked joint) with one already out; only when nothing in the hand or the set-aside group can connect anywhere may it go elsewhere that fits. */
  function mustLink(s, who) {
    if (isEmpty(s.pcs)) return false;
    var hand = s[who].hand;
    for (var i = 0; i < hand.length; i++) for (var y = 0; y < pfbH(s); y++) for (var x = 0; x < pfbW(s); x++) if (hasLink(check(s, hand[i], x, y))) return true;
    var g = nn(s[who].held, null);
    if (g && !isEmpty(g)) { var all = groupCellsAll(s, g); for (var k = 0; k < all.length; k++) if (all[k][2]) return true; }
    return false;
  }

  function cells(s, tile, who) {
    var o = [], must = (who !== undefined && who !== null) && mustLink(s, who);
    for (var y = 0; y < pfbH(s); y++) for (var x = 0; x < pfbW(s); x++) { var j = check(s, tile, x, y); if (j !== null && (!must || hasLink(j))) o.push([x, y]); }
    return o;
  }

  function links(s, id) {
    var p = s.pcs[id], e = edges(p.tile), o = [];
    for (var side in PFB_SIDE) {
      var sd = PFB_SIDE[side], n = pieceAt(s, p.x + sd[0], p.y + sd[1]);
      if (n && n.by !== 'none' && joint(e[side], edges(n.tile)[sd[2]])[1] && (noTer(s) || (ter(s, p.x, p.y) !== 'mud' && ter(s, n.x, n.y) !== 'mud'))) o.push(n);   // the blank centre piece lets a piece connect (placement) but a chain never runs through it
    }
    o.sort(function (a, b) { return b.seq - a.seq; });
    return o.map(function (n) { return toInt(n.id); });
  }

  function chain(s, root) {
    var order = [], seen = {};
    var walk = function (id, par) {
      seen[id] = true; order.push([id, par]);
      var l = links(s, id);
      for (var i = 0; i < l.length; i++) if (!seen[l[i]]) walk(l[i], id);
    };
    walk(root, null);
    return order;
  }

  function fire(s, root) {
    var ev = [], ch = chain(s, root);
    var v1 = nn(s.v1, null), rb = s.pcs[root].by, tw = 1.0;
    if (v1) {   // v1: what fired (for use-up) and Teamwork
      s.fired = []; s.firedby = rb; var srcs = {};
      ch.forEach(function (c) { var cp = s.pcs[c[0]]; if (cp.by === rb && PFB_TEAM_SRC.indexOf(nn(cp.tile.src, '')) >= 0) srcs[cp.tile.src] = 1; });
      var ns = Object.keys(srcs).length;
      if (rb === 'me' && ns >= 3) tw = Number(v1.team3); else if (rb === 'me' && ns === 2) tw = Number(v1.team2);
    }
    var esun = 1.0;   // 2.6.75: a Sun piece in the chain: the pieces of the side that started it count x sun
    if (v1 && truthy(v1.env)) ch.forEach(function (c) { var cp = s.pcs[c[0]]; if (cp.by === 'env' && cp.tile.env === 'sun') esun = Number(v1.sun); });
    for (var i = 0; i < ch.length; i++) {
      var id = ch[i][0], par = ch[i][1];
      if (s.over) break;
      var p = s.pcs[id], who = p.by, tile = p.tile;
      if (who === 'none') continue;   // the blank centre piece does nothing itself; the chain runs through it
      if (who === 'env') {   // 2.6.75: an environment piece: its effect goes to the side whose chain this is
        var ee = envFire(s, p, rb); s.fired.push(id);
        s.pcs[id].f = toInt(nn(s.pcs[id].f, 0)) + 1;
        ee.barnow = round(Number(s.bar.now), 1); ee.fhnow = round(Number(s.fh.now), 1); ee.hpnow = toInt(s.me.hp); ee.gnow = toInt(s.me.block);
        ev.push(ee); checkEnd(s); continue;
      }
      var pt = par !== null ? s.pcs[par] : null;
      if (pt && (pt.by === 'none' || pt.by === 'env')) pt = null;   // and a piece after it (or after an environment piece) has no combo parent
      var vv = value(pt ? pt.tile : null, tile, pt !== null && pt.by === who, false), ck = vv[2];
      var val = iround(vv[0] * Number(nn(p.cm, 1.0)));
      var sunny = !!v1 && (tile.t === 'hurt' || tile.t === 'charm') && ter(s, p.x, p.y) === 'sun';
      if (sunny) val = iround(val * Number(v1.sun));
      if (esun > 1 && who === rb) { val = iround(val * esun); sunny = true; }
      var muddy = !!v1 && truthy(v1.env) && Number(nn(v1.mud, 0)) > 0 && mudNear(s, p.x, p.y);   // Mud's teeth
      if (muddy) val = iround(val * (1 - Number(v1.mud)));
      if (tw > 1 && who === rb) val = iround(val * tw);
      if (v1) s.fired.push(id);
      var isRoot = id === root;
      var e = { by: who, id: id, root: isRoot, tag: tile.tag, mod: String(nn(tile.m, '')), k: tile.k, n: tile.n, t: tile.t, v: val, fit: false, combo: ck ? PF_COMBOS[ck].name : null };
      if (sunny) e.sun = 1;
      if (muddy) e.mud = 1;
      if (tw > 1 && who === rb) e.tw = tw;
      apply(s, who, tile, val, isRoot && links(s, id).length !== 0, ck, pt ? pt.tile : null, pt ? pt.by : null, e, isRoot, false);
      s.pcs[id].f = toInt(nn(s.pcs[id].f, 0)) + 1;   // fire budget: one more firing used
      e.barnow = round(Number(s.bar.now), 1); e.fhnow = round(Number(s.fh.now), 1); e.hpnow = toInt(s.me.hp); e.gnow = toInt(s.me.block);
      ev.push(e);
      checkEnd(s);
    }
    return ev;
  }

  function fireLimit(p) { return p.by === 'foe' ? Math.max(0, PFB_FOE_FIRES) : 0; }
  function goneEntry(s, p, fell) {
    var e = { id: p.id, by: p.by, x: p.x, y: p.y, tile: p.tile, age: s.round - 1 - p.born };
    if (fell) e.fell = true;
    if (p.used !== undefined && p.used !== null) e.used = p.used;
    return e;
  }
  // Fire budget: after a chain has finished, creature pieces that have fired their limit fall away (to their discard); never mid-chain.
  function spend(s) {
    var fired = nn(s.fired, []), by = nn(s.firedby, 'me'), used = []; delete s.fired; delete s.firedby;
    if (s.over) return used;
    var lim3 = s.v1 ? toInt(nn(s.v1.limit, 0)) : 0;
    if (lim3 > 0 && fired.length >= lim3) {   // v1 USE-UP: a chain of 3 or more uses up every piece that fired
      fired.forEach(function (fid) {
        if (!has(s.pcs, fid)) return; var q = s.pcs[fid];
        discardPiece(s, q); q.used = by;
        if (!Array.isArray(s.spent)) s.spent = [];
        s.spent.push(q); used.push(fid);
        delete s.cell[q.x + ',' + q.y]; delete s.pcs[fid];
      });
    }
    var ids = Object.keys(s.pcs);
    for (var i = 0; i < ids.length; i++) {
      var p = s.pcs[ids[i]], lim = fireLimit(p);
      if (lim > 0 && toInt(nn(p.f, 0)) >= lim) {
        discardPiece(s, p);
        if (!Array.isArray(s.spent)) s.spent = [];
        s.spent.push(p);
        delete s.cell[p.x + ',' + p.y]; delete s.pcs[ids[i]];
      }
    }
    return used;
  }

  function begin(s, who) {
    if (who === 'me') return;
    var p = s[who];
    p.block = p.keep; p.keep = 0; p.thorns = false; p.evade = 0;
  }

  function snap(s) {
    var o = [];
    for (var id in s.pcs) { var p = s.pcs[id]; o.push({ id: p.id, by: p.by, x: p.x, y: p.y, n: p.tile.n, t: p.tile.t, v: p.tile.v, tag: p.tile.tag, m: String(nn(p.tile.m, '')), e: edges(p.tile), age: s.round - p.born }); }
    return o;
  }

  function checkAfter(s, id) { return links(s, id).length; }

  function place(s, who, handIdx, x, y) {
    var tile = isInt(handIdx) ? nn(s[who].hand[handIdx], null) : null;
    if (!tile) return null;
    var jt = check(s, tile, x, y);
    if (jt === null || (!hasLink(jt) && !truthy(s.aimforce) && mustLink(s, who))) return null;   // it has to connect unless nothing can (v1: the creature's committed aim plays anyway)
    s[who].hand.splice(handIdx, 1);
    var id = ++s.pid; s.seq++;
    s.pcs[id] = { id: id, by: who, tile: tile, x: x, y: y, born: s.round, seq: s.seq };
    s.cell[x + ',' + y] = id;
    if (who === 'me' && tile.tool !== undefined && tile.tool !== null) { if (!s.wear) s.wear = {}; s.wear[tile.tool] = toInt(nn(s.wear[tile.tool], 0)) + PFB_TOOL_WEAR; }   // tool wear
    var joints = checkAfter(s, id);
    var ev = fire(s, id);
    if (ev.length) { ev[0].linked = joints; ev[0].snap = snap(s); }
    var used = spend(s);
    if (used.length && ev.length) ev[0].used = used;
    return ev;
  }

  // ------------------------------------------------------------------ set-aside groups
  function groupAt(g, dx, dy) {
    for (var i = 0; i < g.pcs.length; i++) if (g.pcs[i].x === dx && g.pcs[i].y === dy) return i;
    return null;
  }
  /** true, or a reason it does not fit. */
  function groupFit(g, tile, dx, dy) {
    if (g.pcs.length >= PFB_GROUP_MAX) return 'A group of three cannot take another piece.';
    if (groupAt(g, dx, dy) !== null) return 'That spot is taken.';
    var e = edges(tile), touch = 0, linked = 0;
    for (var side in PFB_SIDE) {
      var sd = PFB_SIDE[side], ni = groupAt(g, dx + sd[0], dy + sd[1]); if (ni === null) continue;
      var j = joint(e[side], edges(g.pcs[ni].tile)[sd[2]]);
      if (!j[0]) return 'Those edges do not fit.';
      touch++; if (j[1]) linked++;
    }
    if (!touch) return 'It has to touch the group.';
    if (!linked) return 'The pieces have to link (a knob in a matching hole), or their chain would not run.';
    return true;
  }
  function groupOptions(g, tile) {
    var o = [], seen = {};
    for (var ai = 0; ai < g.pcs.length; ai++) {
      var a = g.pcs[ai];
      for (var side in PFB_SIDE) {
        var sd = PFB_SIDE[side], dx = a.x + sd[0], dy = a.y + sd[1];
        if (seen[dx + ',' + dy]) continue; seen[dx + ',' + dy] = true;
        if (groupFit(g, tile, dx, dy) === true) o.push([ai, side, dx, dy]);
      }
    }
    return o;
  }

  /** Set pieces aside, joined. Returns an error string or null. */
  function connect(s, who, a, b, side, anc) {
    if (anc === undefined) anc = null;
    if (typeof side !== 'string' || !has(PFB_SIDE, side)) return 'Those moves are not valid.';
    var hand = s[who].hand;
    if (!isInt(b) || b < 0 || b >= hand.length) return 'Those moves are not valid.';
    var g, r, sd;
    if (anc !== null) {
      g = nn(s[who].held, null);
      if (!g) return 'There is no set-aside group to add to.';
      if (!isInt(anc) || anc < 0 || anc >= g.pcs.length) return 'Those moves are not valid.';
      sd = PFB_SIDE[side]; var dx = g.pcs[anc].x + sd[0], dy = g.pcs[anc].y + sd[1];
      r = groupFit(g, hand[b], dx, dy); if (r !== true) return r;
      g.pcs.push({ tile: hand[b], x: dx, y: dy });
      s[who].hand.splice(b, 1); s[who].held = g; return null;
    }
    if (truthy(s[who].held) && !isEmpty(s[who].held)) return 'You already have a group set aside. Add to it or play it.';
    if (a === null || a === b || !isInt(a) || a < 0 || a >= hand.length) return 'Those moves are not valid.';
    g = { pcs: [{ tile: hand[a], x: 0, y: 0 }] };
    sd = PFB_SIDE[side];
    r = groupFit(g, hand[b], sd[0], sd[1]); if (r !== true) return r;
    g.pcs.push({ tile: hand[b], x: sd[0], y: sd[1] });
    [Math.max(a, b), Math.min(a, b)].forEach(function (i) { s[who].hand.splice(i, 1); });
    s[who].held = g; return null;
  }

  /** The cells a group would fill with its top-left at (ox,oy), or null. [[x, y, groupIdx], ...] */
  function groupCells(s, g, ox, oy) {
    var r = groupCellsL(s, g, ox, oy);
    return r === null ? null : r[0];
  }

  /** [cells, linked] or null. */
  function groupCellsL(s, g, ox, oy) {
    var mx = Infinity, my = Infinity, i;
    g.pcs.forEach(function (p) { mx = Math.min(mx, p.x); my = Math.min(my, p.y); });
    var cs = [], mine = {};
    for (i = 0; i < g.pcs.length; i++) { var p = g.pcs[i], x = ox + p.x - mx, y = oy + p.y - my; cs.push([x, y, i]); mine[x + ',' + y] = i; }
    var touch = false, linked = false;
    for (var ci = 0; ci < cs.length; ci++) {
      var cx = cs[ci][0], cy = cs[ci][1], gi = cs[ci][2];
      if (cx < 0 || cy < 0 || cx >= pfbW(s) || cy >= pfbH(s) || has(s.cell, cx + ',' + cy)) return null;
      var e = edges(g.pcs[gi].tile);
      for (var side in PFB_SIDE) {
        var sd = PFB_SIDE[side], nx = cx + sd[0], ny = cy + sd[1];
        if (has(mine, nx + ',' + ny)) continue;
        var n = pieceAt(s, nx, ny); if (!n) continue;
        var jt = joint(e[side], edges(n.tile)[sd[2]]);
        if (!jt[0]) return null;
        touch = true; if (jt[1] && (noTer(s) || (ter(s, cx, cy) !== 'mud' && ter(s, nx, ny) !== 'mud'))) linked = true;
      }
    }
    if (isEmpty(s.pcs)) {
      var c0 = intdiv(pfbW(s), 2), c1 = intdiv(pfbH(s), 2);
      for (i = 0; i < cs.length; i++) if (cs[i][0] === c0 && cs[i][1] === c1) return [cs, false];
      return null;
    }
    return touch ? [cs, linked] : null;
  }
  function groupCellsAll(s, g) {
    var o = [];
    for (var y = 0; y < pfbH(s); y++) for (var x = 0; x < pfbW(s); x++) { var r = groupCellsL(s, g, x, y); if (r !== null) o.push([x, y, r[1]]); }
    return o;
  }
  function groupSpots(s, g, who) {
    var o = [], must = mustLink(s, who === undefined ? 'me' : who), all = groupCellsAll(s, g);
    for (var i = 0; i < all.length; i++) if (!must || all[i][2]) o.push([all[i][0], all[i][1]]);
    return o;
  }

  function placeGroup(s, who, ox, oy) {
    var g = nn(s[who].held, null); if (!g) return null;
    var r = groupCellsL(s, g, ox, oy); if (r === null) return null;
    if (!r[1] && mustLink(s, who)) return null;   // it has to connect unless nothing can
    var cs = r[0];
    var cm = nn(PFB_GROUP_MULT[g.pcs.length], 1.0), root = null;
    for (var i = 0; i < cs.length; i++) {
      var x = cs[i][0], y = cs[i][1], gi = cs[i][2];
      var id = ++s.pid; s.seq++;
      s.pcs[id] = { id: id, by: who, tile: g.pcs[gi].tile, x: x, y: y, born: s.round, seq: s.seq, cm: cm };
      s.cell[x + ',' + y] = id; root = id;
      var gt = g.pcs[gi].tile; if (who === 'me' && gt.tool !== undefined && gt.tool !== null) { if (!s.wear) s.wear = {}; s.wear[gt.tool] = toInt(nn(s.wear[gt.tool], 0)) + PFB_TOOL_WEAR; }
    }
    s[who].held = null;
    var ev = fire(s, root);
    if (ev.length) { ev[0].linked = checkAfter(s, root); ev[0].snap = snap(s); }
    var used = spend(s);
    if (used.length && ev.length) ev[0].used = used;
    return ev;
  }

  function expire(s) {
    var gone = [], ids = Object.keys(s.pcs);
    for (var i = 0; i < ids.length; i++) {
      var p = s.pcs[ids[i]];
      if (p.born <= s.round - lifeOf(s, p) + 1) {
        discardPiece(s, p);
        gone.push(p);
        delete s.cell[p.x + ',' + p.y]; delete s.pcs[ids[i]];
      }
    }
    return gone;
  }

  function anchorPick(s) {
    var hand = s.foe.hand; if (!hand.length) return null;
    var pick = null;
    for (var i = 0; i < hand.length; i++) if (hand[i].t !== 'hurt' && (pick === null || hand[i].v < hand[pick].v)) pick = i;
    if (pick !== null) return pick;
    for (var di = s.foe.draw.length - 1; di >= 0; di--) if (s.foe.draw[di].t !== 'hurt') { s.foe.hand.push(s.foe.draw[di]); s.foe.draw.splice(di, 1); return s.foe.hand.length - 1; }
    return 0;
  }

  function foeCount(s) { var n = 0; for (var id in s.pcs) if (s.pcs[id].by === 'foe') n++; return n; }

  function spawn(s) {
    if (foeCount(s) >= PFB_FOE_MIN) return null;
    var pick = anchorPick(s); if (pick === null) return null;
    var tile = s.foe.hand[pick];
    var cs = !isEmpty(s.pcs) ? cells(s, tile) : [[intdiv(pfbW(s), 2), intdiv(pfbH(s), 2)]];
    if (!cs.length) return null;
    var xy = cs[rand(s, cs.length)], x = xy[0], y = xy[1];
    s.foe.hand.splice(pick, 1);
    var id = ++s.pid; s.seq++;
    s.pcs[id] = { id: id, by: 'foe', tile: tile, x: x, y: y, born: s.round, seq: s.seq };
    s.cell[x + ',' + y] = id;
    return id;
  }

  // ------------------------------------------------------------------ the creature's play
  function score(b, a, who) {
    var barD = (a.bar.now - b.bar.now) + (a.fh.now - b.fh.now), hpD = a.me.hp - b.me.hp;
    var tg = 0.0;
    if (a.v1 && truthy(a.v1.tags)) {
      var u = 0.05 * a.me.max, pz = function (z) { return toInt(nn(z.me.poison, 0)) * toInt(nn(z.me.poison_v, 0)); }, I = function (x) { return x === true ? 1 : toInt(nn(x, 0)); };
      tg = (pz(a) - pz(b)) + u * (1.0 * (I(a.me.slowdraw) - I(b.me.slowdraw)) + 1.5 * (I(a.foe.evade) - I(b.foe.evade)) + 0.6 * (I(a.foe.thorns) - I(b.foe.thorns))
        + 1.0 * (I(a.foe.bashnext) - I(b.foe.bashnext)) + 1.5 * (I(a.foe.again) - I(b.foe.again)));
    }
    if (who === 'me') return -0.7 * tg + barD + 0.7 * hpD + 0.3 * (a.me.block - b.me.block) - 0.3 * (a.foe.block - b.foe.block) + (truthy(a.over) && (a.over === 'seen_off' || a.over === 'charmed') ? 50 : 0);
    return tg - 0.8 * barD - hpD + 0.4 * (a.foe.block - b.foe.block) - 0.3 * (a.me.block - b.me.block) + (a.over === 'defeat' ? 50 : 0);
  }

  /** The best single placement for who: [handIdx, x, y, score] or null. */
  function search(s, who, allowHeavy) {
    if (allowHeavy === undefined) allowHeavy = true;
    var best = null, hand = s[who].hand;
    for (var i = 0; i < hand.length; i++) {
      var tile = hand[i];
      if (!allowHeavy && tile.tag === 'heavy' && nn(tile.m, '') !== 'steady') continue;
      var cs = cells(s, tile, who);
      for (var c = 0; c < cs.length; c++) {
        var x = cs[c][0], y = cs[c][1], w = clone(s);
        if (place(w, who, i, x, y) === null) continue;
        var sc = score(s, w, who);
        if (s.v1 && has(w.cell, x + ',' + y)) {   // v1: bramble under a piece that stays out, and what the announced events will do to it
          if (ter(s, x, y) === 'br') sc -= 2 * Number(s.v1.bramble) * (who === 'foe' ? Number(s.v1.br_foe) * 0.8 * s.fh.max : 0.7 * s.me.max);
          sc += envBias(s, who, x, y, tile);
        }
        if (best === null || sc > best[3] + 1e-9) best = [i, x, y, sc];
      }
    }
    return best;
  }

  function foeLen(s) { return Math.max(0, Math.min(s.foe.hand.length, 1 - toInt(s.foe.slow))); }

  function guardNotes(s, ev) {   // 2.6.77 (pfb_guard_notes)
    if (!s.v1 || s.over) return;
    var ta = ev.length ? String(nn(ev[ev.length - 1].ta, 'foe')) : 'foe';
    [['fade', toInt(nn(s.me.faded, 0))], ['hold', toInt(nn(s.me.kept, 0))]].forEach(function (q) {
      if (q[1] <= 0) return;
      var e = note(q[0], String(q[1])); e.by = 'me'; e.ta = ta; e.barnow = round(Number(s.bar.now), 1); e.fhnow = round(Number(s.fh.now), 1); e.hpnow = toInt(s.me.hp); e.gnow = toInt(s.me.block); ev.push(e);
    });
  }
  function note(kind, n) { return { by: 'foe', note: kind, k: 'note', n: n === undefined ? '' : n, t: 'note', tag: '', v: 0, fit: false, combo: null }; }   // 2.6.76: a notice event (pfb_note)

  function foeTurn(s) {
    var ev = [];
    begin(s, 'foe');
    if (s.foe.poison > 0) {
      var add = s.foe.poison_v * s.hm;
      s.fh.now += add; s.foe.poison--;
      if (s.foe.poison === 0) s.foe.poison_v = 0;
      ev.push({ by: 'me', tag: 'poison', k: 'poison', n: 'Poison', t: 'hurt', v: iround(add), fit: false, combo: null, tick: true });
      if (checkEnd(s)) return ev;
    }
    if (s.v1 && truthy(s.v1.tags) && toInt(s.foe.slow) > 0 && s.foe.hand.length) ev.push(note('slow'));
    var n = foeLen(s), again = false; s.lastfoe = [];
    if (s.v1 && truthy(s.v1.tags)) s.foe.again = 0;
    if (s.v1) s.reaim = 0;
    for (var k = 0; k < n && !s.over; k++) {
      var r = null, plan = (s.v1 && truthy(s.v1.aim) && k === 0) ? nn(s.foe.plan, null) : null;
      if (plan) for (var hi = 0; hi < s.foe.hand.length; hi++) if (s.foe.hand[hi].k === plan.k) { s.aimforce = true; r = place(s, 'foe', hi, plan.x, plan.y); delete s.aimforce; break; }   // v1 AIM
      if (r === null) {   // no fumble: it picks again at full value
        if (plan) s.reaim = 1;
        var m = search(s, 'foe');
        if (m === null) break;
        r = place(s, 'foe', m[0], m[1], m[2]);
      }
      if (r) { ev = ev.concat(r); s.lastfoe.push(s.pid); }
      if (truthy(s.foe.again)) { if (!again) { again = true; n++; if (s.v1 && truthy(s.v1.tags) && r && r.length) ev.push(note('quick', String(nn(r[0].n, '')))); } s.foe.again = 0; }   // a Quick piece: one more piece this turn (once)
    }
    s.foe.agg = 0; s.foe.slow = 0;
    return ev;
  }

  function intent(s) {
    if (s.v1) forecast(s);
    var m = search(s, 'foe');
    s.foe.intent = m ? s.foe.hand[m[0]].t : null;
    if (s.v1 && truthy(s.v1.aim)) { var h = m ? s.foe.hand[m[0]] : null; s.foe.plan = h && foeLen(s) > 0 ? { k: h.k, n: h.n, t: h.t, v: h.v, tag: h.tag, x: m[1], y: m[2] } : null; }
  }

  // ------------------------------------------------------------------ the whole fight
  function newFight(me, c, seed, opt) {
    var s = pfNew(me, c, seed, opt);
    var v1 = (opt && truthy(opt.v1)) ? v1Cfg(s.size, (typeof opt.v1 === 'object' && !Array.isArray(opt.v1)) ? opt.v1 : {}, Math.max(1, toInt(nn(c.level, 1)))) : null;
    ['hand', 'draw', 'discard'].forEach(function (z) { s.foe[z].forEach(function (t) { t.v = Math.max(1, iround(t.v * (v1 ? v1.foe : PFB_FOE_MULT) * (s.size === 'boss' ? PFB_BOSS_MULT : 1.0) * (truthy(opt && opt.blank) ? PFB_BLANK_FOE_MULT : 1.0) * (PFB_FOE_FIRES > 0 ? PFB_FOE_FIRE_MULT : 1.0))); }); });
    s.bar.max = round(s.bar.max * (v1 ? v1.bar : PFB_BAR_MULT), 1); s.fh.max = s.bar.max;
    s.mode = 'board'; s.strip = []; s.pcs = {}; s.cell = {}; s.pid = 0; s.seq = 0; s.round = 1;
    if (v1) {
      s.w = v1.w; s.h = v1.h; delete v1.w; delete v1.h; s.v1 = v1;
      v1Tiles(s, c); seedGround(s); s.envs = []; s.envlog = []; s.reaim = 0; s.me.flipt = 0;
      if (v1.env) { s.env = { draw: shuffle(s, envDeck(s.size, String(nn(c.region, '')))), discard: [], next: [] }; envDraw(s); }   // 2.6.75: the environment's deck
      if (v1.tags) { s.me.poison = 0; s.me.poison_v = 0; s.me.slowdraw = 0; s.me.tripped = 0; s.foe.bashnext = 0; s.foe.again = 0; }
    }
    if (opt && truthy(opt.blank)) {   // variant: a blank wild piece in the centre; both sides put a start piece next to it, hidden (see start)
      s.pid = 1; s.seq = 1; var cx = intdiv(pfbW(s), 2), cy = intdiv(pfbH(s), 2);
      s.pcs[1] = { id: 1, by: 'none', tile: { k: 'blank', n: 'Blank', t: 'blank', v: 0, tag: '', r: null }, x: cx, y: cy, born: 1, seq: 1 };
      s.cell[cx + ',' + cy] = 1; s.start = true;
      draw(s, 'foe', s.foe.hsize); intent(s);
      return s;
    }
    var n = s.size === 'boss' ? 2 : 1;
    for (var k = 0; k < n; k++) {
      var pick = anchorPick(s); if (pick === null) continue;
      var hand = s.foe.hand;
      var cs = isEmpty(s.pcs) ? [[intdiv(pfbW(s), 2), intdiv(pfbH(s), 2)]] : null;
      var tile = hand[pick]; if (cs === null) cs = cells(s, tile);
      if (!cs.length) continue;
      var xy = cs[rand(s, cs.length)], x = xy[0], y = xy[1];
      s.foe.hand.splice(pick, 1);
      var id = ++s.pid; s.seq++;
      s.pcs[id] = { id: id, by: 'foe', tile: tile, x: x, y: y, born: 1, seq: s.seq };
      s.cell[x + ',' + y] = id;
    }
    draw(s, 'foe', s.foe.hsize);
    intent(s);
    return s;
  }

  // Blank-centre variant: your hidden start. Pick a hand piece and a side of the blank (L, R, T, B); the creature picked its piece and side already, without seeing yours
  // (its gentlest non-Hurt piece, a side by the seeded roll). Same side: yours stays and its piece takes the next free side. Nothing fires. A boss puts out two.
  function start(s, handIdx, side) {
    if (!truthy(s.start)) return 'The fight has already started.';
    if (!has(PFB_SIDE, side)) return 'Pick a side: L, R, T or B.';
    var tile = s.me.hand[handIdx]; if (!tile) return 'No such piece in your hand.';
    var cx = intdiv(pfbW(s), 2), cy = intdiv(pfbH(s), 2), sides = ['L', 'R', 'T', 'B'], fs = sides[rand(s, 4)];
    var put = function (who, idx, sd) {
      var d = PFB_SIDE[sd], x = cx + d[0], y = cy + d[1], t = s[who].hand[idx];
      s[who].hand.splice(idx, 1);
      var id = ++s.pid; s.seq++;
      s.pcs[id] = { id: id, by: who, tile: t, x: x, y: y, born: 1, seq: s.seq };
      s.cell[x + ',' + y] = id;
    };
    put('me', handIdx, side);
    var n = s.size === 'boss' ? 2 : 1, free = sides.filter(function (q) { return q !== side; }), st = free.indexOf(fs); if (st < 0) st = 0;
    for (var k = 0; k < n; k++) { var pick = anchorPick(s); if (pick === null) break; put('foe', pick, free[(st + k) % free.length]); }
    draw(s, 'foe', s.foe.hsize); intent(s);
    s.start = false;
    return null;
  }

  function fx(ev) {
    var o = [];
    for (var i = 0; i < ev.length; i++) {
      var e = ev[i];
      if (e.id === undefined || e.id === null) continue;
      if (truthy(e.root) || !o.length) o.push({ by: e.by, ids: [] });
      o[o.length - 1].ids.push(toInt(e.id));
    }
    return o.filter(function (c) { return c.ids.length >= 2; });
  }

  function endRound(s) {
    if (s.v1) { if (truthy(s.v1.env)) envPlace(s); else envTurn(s); if (s.over) return; }   // v1: the environment's turn (2.6.75: it places a piece; a 2.6.74 fight: the terrain turn)
    var slow = 0;
    if (s.v1 && truthy(s.v1.tags)) {   // creature tags: its poison works on you, a trip costs you one draw
      if (toInt(s.me.poison) > 0) {
        var pv = Math.max(1, toInt(s.me.poison_v)); s.me.hp = Math.max(0, s.me.hp - pv); s.me.poison--;
        s.envlog.push({ k: 'poison', x: null, y: null, me: pv, foe: 0.0 });
        if (s.me.poison === 0) s.me.poison_v = 0;
        if (checkEnd(s)) return;
      }
      slow = truthy(s.me.slowdraw) ? 1 : 0; s.me.slowdraw = 0; s.me.tripped = slow;
    }
    var gone = expire(s);
    if (s.v1 && truthy(s.v1.env)) { var eg = gone.filter(function (p) { return p.by === 'env'; }).map(function (p) { return p.id; }); if (eg.length) s.envlog.push({ k: 'expire', x: null, y: null, me: 0, foe: 0.0, ids: eg }); }   // 2.6.75
    draw(s, 'foe', s.foe.hsize);
    s.turn++; s.round++;
    if (s.v1 && truthy(s.v1)) { var kept = Math.min(toInt(s.me.keep), toInt(s.me.block)); s.me.faded = Math.max(0, toInt(s.me.block) - kept); s.me.kept = kept; s.me.block = kept; s.me.keep = 0; }   // 2.6.77: your guard fades when your turn starts; only a Hold guard still standing carries over, once
    else { s.me.block = s.me.keep; s.me.keep = 0; }
    s.me.thorns = false; s.me.evade = 0;
    draw(s, 'me', Math.min(PF_HAND_CAP, s.me.hand.length + PF_DRAW - slow));
    s.gone = nn(s.spent, []).map(function (p) { return goneEntry(s, p, true); }).concat(gone.map(function (p) { return goneEntry(s, p, false); }));
    s.spawn = spawn(s);
    if (s.turn > PF_TURN_CAP) { s.over = s.boss ? 'defeat' : 'stall'; return; }
    intent(s);
  }

  /**
   * The player's turn: ONE action (see the move shapes at the top). Mutates s like the PHP (by reference); returns {ev, err}.
   * dry = true: report what a place would do (on a copy; no creature turn). canPlay(tile) -> reason|null is the optional PHP hook.
   */
  function play(s, moves, turn, dry, canPlay) {
    var bad = function () { return { ev: [], err: 'Those moves are not valid.' }; };
    if (s.over) return { ev: [], err: 'The fight is over.' };
    if (truthy(s.start)) return { ev: [], err: 'Pick your start piece first.' };
    if (turn !== s.turn) return { ev: [], err: 'stale' };
    if (!Array.isArray(moves) || moves.length !== 1) return { ev: [], err: 'One action a turn.' };
    var mv = moves[0];
    if (!Array.isArray(mv) || !mv.length) return bad();
    if (mv[0] === 'f' && s.v1 && truthy(s.v1.flip)) {   // v1 FLIP: free, the turn goes on
      if (mv.length !== 2 || !isInt(mv[1])) return bad();
      return { ev: [], err: flip(dry ? clone(s) : s, mv[1], turn), free: true };
    }
    var w = clone(s); w.spent = []; w.lastfoe = []; w.gone = [];   // 2.6.88: what the creature put down and what left LAST round is not this turn's news (PHP pfb_play does the same)
    if (w.v1) w.envlog = [];
    begin(w, 'me');
    var ev = [], why, r, err;
    if (isInt(mv[0])) {
      if (mv.length !== 3 || !isInt(mv[1]) || !isInt(mv[2]) || mv[0] < 0 || mv[0] >= w.me.hand.length) return bad();
      if (canPlay && (why = canPlay(w.me.hand[mv[0]])) !== null && why !== undefined) return { ev: [], err: why };
      r = place(w, 'me', mv[0], mv[1], mv[2]);
      if (r === null) return { ev: [], err: 'That piece does not fit there.' };
      ev = r;
    } else if (mv[0] === 'c') {
      if (mv.length !== 3 || !isInt(mv[1]) || !isInt(mv[2])) return bad();
      if (!truthy(w.me.held) || isEmpty(w.me.held)) return { ev: [], err: 'You have no group set aside.' };
      if (canPlay) for (var gi = 0; gi < w.me.held.pcs.length; gi++) if ((why = canPlay(w.me.held.pcs[gi].tile)) !== null && why !== undefined) return { ev: [], err: why };
      r = placeGroup(w, 'me', mv[1], mv[2]);
      if (r === null) return { ev: [], err: 'The group does not fit there.' };
      ev = r;
    } else if (mv[0] === 'j' || mv[0] === 'h') {
      if (mv.length !== 4 || !isInt(mv[1]) || !isInt(mv[2]) || typeof mv[3] !== 'string') return bad();
      err = mv[0] === 'j' ? connect(w, 'me', mv[1], mv[2], mv[3]) : connect(w, 'me', null, mv[1], mv[3], mv[2]);
      if (err) return { ev: [], err: err };
      var pcs = w.me.held.pcs;
      w.me.block += Math.ceil(toInt(pcs[mv[0] === 'j' ? 1 : pcs.length - 1].tile.v) * PFB_SETASIDE_GUARD);   // 2.6.66: setting a piece aside braces you
      ev = [{ snap: snap(w), by: 'me', connect: true, n: pcs.map(function (gp) { return String(gp.tile.n); }).join(' + '), types: pcs.map(function (gp) { return String(gp.tile.t); }), size: pcs.length }];
    } else return bad();
    ev.forEach(function (e0) { e0.ta = 'me'; });
    if (dry) return { ev: ev, err: null, bar: round(w.bar.now, 1), max: w.bar.max, fh: round(w.fh.now, 1), fhmax: w.fh.max, hp: w.me.hp, block: w.me.block, over: w.over };
    if (!w.over) { var fe = foeTurn(w); fe.forEach(function (e0) { e0.ta = 'foe'; }); ev = ev.concat(fe); }
    var trip = !w.over && w.v1 && truthy(w.v1.tags) && truthy(w.me.slowdraw);
    if (!w.over) endRound(w);
    if (w.v1) ev = ev.concat(envEvents(w));
    if (trip && !w.over) { var tn = note('trip'); tn.ta = ev.length ? String(nn(ev[ev.length - 1].ta, 'foe')) : 'foe'; ev.push(tn); }
    guardNotes(w, ev);
    w.fx = fx(ev);
    w.log.push({ turn: s.turn, n: 1 });
    assignInto(s, w);
    return { ev: ev, err: null };
  }

  /** Pass the turn with nothing to place. */
  function pass(s, turn) {
    if (s.over || turn !== s.turn) return { ev: [], err: s.over ? 'The fight is over.' : 'stale' };
    if (truthy(s.start)) return { ev: [], err: 'Pick your start piece first.' };
    var i;
    for (i = 0; i < s.me.hand.length; i++) {
      if (cells(s, s.me.hand[i]).length) return { ev: [], err: 'You still have a piece that fits somewhere.' };
      if (canFlip(s, i) && cells(s, flipped(s.me.hand[i])).length) return { ev: [], err: 'You still have a piece that fits somewhere when you flip it.' };
    }
    if (truthy(s.me.held) && !isEmpty(s.me.held) && groupSpots(s, s.me.held).length) return { ev: [], err: 'Your set-aside group still fits somewhere.' };
    var w = clone(s); w.spent = []; begin(w, 'me');
    if (w.v1) w.envlog = [];
    var ev = foeTurn(w); ev.forEach(function (e0) { e0.ta = 'foe'; });
    w.fx = fx(ev);
    var trip = !w.over && w.v1 && truthy(w.v1.tags) && truthy(w.me.slowdraw);
    if (!w.over) endRound(w);
    if (w.v1) ev = ev.concat(envEvents(w));
    if (trip && !w.over) { var tn = note('trip'); tn.ta = ev.length ? String(nn(ev[ev.length - 1].ta, 'foe')) : 'foe'; ev.push(tn); }
    guardNotes(w, ev);
    assignInto(s, w);
    return { ev: ev, err: null };
  }

  /** v1: the numbers on the lit cells of a hand piece (or 'c' = the set-aside group): your own chain only (pfb_cell_preview, v1 branch). flipIt: with the piece flipped. */
  function cellPreview(s, handIdx, flipIt) {
    if (truthy(s.over) || truthy(s.start) || !s.v1) return {};
    if (flipIt) { if (handIdx === 'c' || !canFlip(s, handIdx)) return {}; s = clone(s); s.me.hand[handIdx] = flipped(s.me.hand[handIdx]); }
    var cs, o = {};
    if (handIdx === 'c') { if (!truthy(s.me.held) || isEmpty(s.me.held)) return {}; cs = groupSpots(s, s.me.held); }
    else { var tile = nn(s.me.hand[handIdx], null); if (!tile) return {}; cs = cells(s, tile, 'me'); }
    var fh0 = Number(s.fh.now), b0 = Number(s.bar.now), hp0 = toInt(s.me.hp);
    cs.forEach(function (c) {
      var r = play(clone(s), [[handIdx === 'c' ? 'c' : handIdx, c[0], c[1]]], s.turn, true);
      if (r.err) return;
      var n = 0, tw = 1.0, sun = 0, mud = 0;
      r.ev.forEach(function (e) { if (e.barnow === undefined) return; n++; if (e.tw !== undefined) tw = Number(e.tw); if (truthy(e.sun) && e.by === 'me') sun++; if (truthy(e.mud) && e.by === 'me') mud++; });
      o[c[0] + ',' + c[1]] = { dmg: iround(r.fh - fh0), ch: iround(r.bar - b0), hp: Math.max(0, hp0 - toInt(r.hp)), n: n, used: !!(r.ev[0] && r.ev[0].used && r.ev[0].used.length), tw: tw, sun: sun, end: truthy(r.over) };
      if (truthy(s.v1.env)) o[c[0] + ',' + c[1]].mud = mud;
    });
    return o;
  }

  /** What the client may see: no draw pile, no foe hand, no rng, no nonce. */
  function view(s) {
    var v = pfView(s), i;
    v.start = truthy(s.start); v.mode = 'board'; v.w = pfbW(s); v.h = pfbH(s); v.fx = clone(nn(s.fx, []));
    var g = nn(s.me.held, null);
    v.held = g ? {
      pcs: g.pcs.map(function (p) { return { n: p.tile.n, t: p.tile.t, v: p.tile.v, tag: p.tile.tag, m: String(nn(p.tile.m, '')), e: edges(p.tile), x: p.x, y: p.y }; }),
      spots: groupSpots(s, g),
      link: groupCellsAll(s, g).some(function (o) { return o[2]; })
    } : null;
    v.pcs = [];
    for (var id in s.pcs) { var p = s.pcs[id]; v.pcs.push({ id: p.id, by: p.by, x: p.x, y: p.y, n: p.tile.n, t: p.tile.t, v: p.tile.v, tag: p.tile.tag, m: String(nn(p.tile.m, '')), e: edges(p.tile), age: s.round - p.born, seq: p.seq, fl: fireLimit(p) > 0 ? Math.max(0, fireLimit(p) - toInt(nn(p.f, 0))) : null, spawn: nn(s.spawn, null) === p.id, fnew: nn(s.lastfoe, []).indexOf(p.id) >= 0 }); }
    v.gone = nn(s.gone, []).map(function (q) { return { id: q.id, by: q.by, x: q.x, y: q.y, n: q.tile.n, t: q.tile.t, v: q.tile.v, tag: q.tile.tag, m: String(nn(q.tile.m, '')), e: edges(q.tile), age: q.age, fell: truthy(q.fell) }; });
    nn(s.gone, []).forEach(function (q, i) { if (q.by === 'env') { v.gone[i].kind = String(q.tile.env); v.gone[i].dir = q.tile.dir === undefined ? null : q.tile.dir; } });   // 2.6.75: an environment piece that left: its kind and Wind's arrow
    for (i = 0; i < v.hand.length; i++) v.hand[i].e = edges(s.me.hand[i]);
    delete v.strip; delete v.open; delete v.open_t; delete v.open_v; delete v.open_by;
    if (s.v1) {   // v1: ground, forecast, the aim, use-up, Teamwork, flip and piece life
      var c = s.v1;
      v.v1 = { limit: toInt(c.limit), sun: c.sun, bramble: c.bramble, br_foe: c.br_foe, thorn: c.thorn, ev_foe: c.ev_foe, team2: c.team2, team3: c.team3,
        env: truthy(c.env), envn: toInt(nn(c.envn, 0)), rain: Number(nn(c.rain, 0)), th_foe: Number(nn(c.th_foe, 1)), mud: Number(nn(c.mud, 0)), envcap: Number(nn(c.envcap, 1)),
        ground: truthy(c.ground), events: truthy(c.events), aim: truthy(c.aim), flip: truthy(c.flip), life: truthy(c.life), edges: truthy(c.edges) };
      for (var pk in PFB_V1_PRE) v.v1[pk] = v1r(s, pk);   // the compat rules, resolved
      v.round = toInt(s.round);
      v.ter = clone(nn(s.ter, {}));
      v.envs = nn(s.envs, []).map(function (e) { var o = clone(e), q = pieceAt(s, e.x, e.y); o.n = PFB_EVENT_NAME[e.kind]; o.on = q && q.by !== 'none' ? { id: q.id, by: q.by, n: q.tile.n } : null; return o; });
      v.envlog = clone(nn(s.envlog, []));
      if (truthy(c.env)) v.env = { next: s.env.next.map(function (nx) { return { k: nx.k, n: nx.n, kind: nx.env, life: toInt(nx.life), e: edges(nx) }; }), deck: s.env.draw.length, used: s.env.discard.length, n: toInt(c.envn) };   // 2.6.75: next is a list
      v.aim = clone(nn(s.foe.plan, null));
      v.reaim = truthy(s.reaim);
      v.flip = { on: truthy(c.flip), used: toInt(nn(s.me.flipt, 0)) === toInt(s.turn) };
      if (truthy(c.tags)) v.status = { poison: toInt(s.me.poison), poison_v: toInt(s.me.poison_v), slowdraw: toInt(s.me.slowdraw), evade: toInt(s.me.evade),
        foe_evade: toInt(s.foe.evade), foe_thorns: truthy(s.foe.thorns), foe_bash: toInt(s.foe.bashnext), foe_slow: toInt(s.foe.slow), foe_poison: toInt(s.foe.poison) };
      v.wear = clone(nn(s.wear, {}));
      v.pcs.forEach(function (q) { var p = s.pcs[q.id], life = lifeOf(s, p); q.life = life; q.left = p.born + life - toInt(s.round); q.src = String(nn(p.tile.src, '')); q.flip = truthy(p.tile.flip); q.ter = ter(s, p.x, p.y); q.rank = toInt(nn(p.tile.rank, 0)); q.layer = String(nn(p.tile.layer, '')); if (p.by === 'env') { q.kind = String(p.tile.env); q.dir = nn(p.tile.dir, null); } });
      for (i = 0; i < v.hand.length; i++) { var ht = s.me.hand[i]; v.hand[i].life = toInt(nn(ht.life, PFB_LIFE)); v.hand[i].src = String(nn(ht.src, '')); v.hand[i].flip = truthy(ht.flip); v.hand[i].canflip = canFlip(s, i); v.hand[i].rank = toInt(nn(ht.rank, 0)); v.hand[i].tool = String(nn(ht.tool, '')); }
      if (v.held) v.held.pcs.forEach(function (q, gi) { var gt = g.pcs[gi].tile; q.life = toInt(nn(gt.life, PFB_LIFE)); q.src = String(nn(gt.src, '')); q.flip = truthy(gt.flip); });
      v.gone.forEach(function (q, gi) { var u = s.gone[gi].used; if (u !== undefined && u !== null) q.used = u; });
    }
    return v;
  }

  // ------------------------------------------------------------------ text lines and history chips (pfight_game.php)
  function line(e, foe) {
    if (e.env !== undefined && e.env !== null) return envLine(e, foe);   // v1: a terrain event
    if (truthy(e.connect)) return '🧩 You set ' + e.n + ' aside, joined (' + toInt(e.size) + ' pieces).';
    if (truthy(e.tick)) return '🧪 The poison works on the ' + foe + ' (+' + toInt(e.v) + ').';
    if (e.note !== undefined && e.note !== null) return noteLine(e, foe);
    var who = e.by === 'me' ? 'You play' : 'The ' + foe + ' plays';
    var bits = [];
    if (truthy(e.combo)) bits.push('✨ ' + e.combo);
    if (truthy(e.fit)) bits.push('snug fit');
    if (nn(e.pluck, '') === 'missed') return '🤏 You try to pluck something from the ' + foe + ', but it notices.';
    if (nn(e.pluck, '') === 'none') return '🤏 You reach for the ' + foe + ', but it has nothing to lift (or you already took something).';
    var tail;
    switch (e.t) {
      case 'hurt': tail = e.by === 'me' ? ' for ' + toInt(nn(e.dmg, e.v)) : ' for ' + toInt(nn(e.dmg, e.v)) + ' damage'; break;
      case 'guard': tail = ' (+' + toInt(e.v) + ' guard)'; break;
      case 'heal': case 'item': tail = ' (+' + toInt(e.v) + ' health)'; break;
      case 'charm': tail = ' (' + toInt(e.v) + ')'; break;
      default: tail = '';
    }
    if (e.ta && e.ta !== e.by && (e.ta === 'me' || e.ta === 'foe') && (e.by === 'me' || e.by === 'foe')) who = e.ta === 'me' ? 'Your chain fires the ' + foe + '\u2019s' : 'The ' + foe + '\u2019s chain fires your';   // 2.6.76: a chain through the other side's piece
    return (e.by === 'me' ? '🧩 ' : '💥 ') + who + ' ' + e.n + tail + (bits.length ? ' · ' + bits.join(', ') : '') + '.';
  }
  function noteLine(e, foe) {
    switch (e.note) {
      case 'quick': return '\u26A1 ' + (e.n ? e.n + ': ' : '') + 'Quick. The ' + foe + ' plays a second piece.';
      case 'slow': return '\u23F3 The ' + foe + ' loses its turn.';
      case 'fade': return '\uD83D\uDEE1\uFE0F Your guard fades (-' + toInt(e.n) + ') as your turn starts.';
      case 'hold': return '\uD83D\uDEE1\uFE0F Hold: ' + toInt(e.n) + ' guard stays up into your turn.';
      default: return '\uD83E\uDDB6 Tripped: you draw 1 fewer piece next turn.';
    }
  }

  /** One history chip for one scored event (board mode). snapId = the snapshot index the page keeps for the rewind. */
  function chipEvent(e, snapId) {
    if (snapId === undefined) snapId = null;
    var base = { id: (e.id !== undefined && e.id !== null) ? toInt(e.id) : null, sn: snapId, bar: nn(e.barnow, null), fh: nn(e.fhnow, null), hp: nn(e.hpnow, null), g: nn(e.gnow, null), chain: false };
    var ext = function (o) { for (var k in o) base[k] = o[k]; return base; };
    if (truthy(e.connect)) return ext({ by: 'me', types: e.types, tags: [], txt: 'joined ' + toInt(e.size), tg: null });
    if (e.env !== undefined && e.env !== null) {   // v1: a terrain event
      var ep = []; if (truthy(e.me)) ep.push('you -' + toInt(e.me) + ' hp'); if (truthy(e.foe)) ep.push('creature -' + iround(Number(e.foe)) + ' hp');
      return ext({ by: 'env', types: ['env'], tags: [String(nn(e.kind, e.env))], txt: String(e.n) + (ep.length ? ': ' + ep.join(' · ') : ''), tg: truthy(e.me) ? 'me' : (truthy(e.foe) ? 'foe' : null) });
    }
    if (e.note !== undefined && e.note !== null) return ext({ by: String(e.by), types: ['note'], tags: [String(e.note)], txt: e.note === 'quick' ? '\u26A1 Quick: plays 2' : e.note === 'slow' ? '\u23F3 loses its turn' : e.note === 'fade' ? '\uD83D\uDEE1\uFE0F guard fades -' + toInt(e.n) : e.note === 'hold' ? '\uD83D\uDEE1\uFE0F Hold kept ' + toInt(e.n) : '\uD83E\uDDB6 you draw 1 fewer', tg: null });
    var parts = [], tg = 'foe', by = String(nn(e.by, 'me')), t = String(nn(e.t, 'hurt'));
    if (truthy(e.tick)) parts.push('-' + toInt(e.v) + ' hp');
    else if (by === 'me') {
      var bar = Number(nn(e.bar, 0)), fhh = Number(nn(e.fh, 0));
      if (fhh > 0) parts.push('-' + iround(fhh) + ' hp');
      if (bar > 0) parts.push('+' + iround(bar) + ' charm');
      if (t === 'guard') { parts.push('+' + toInt(e.v) + ' guard'); tg = 'me'; }
      if (t === 'heal' || t === 'item') { parts.push('+' + toInt(e.v) + ' hp'); tg = 'me'; }
    } else {
      var dmg = toInt(nn(e.dmg, 0));
      if (t === 'hurt') { tg = 'me'; parts.push(dmg > 0 ? '-' + dmg + ' hp' : (truthy(e.blocked) ? 'blocked' : 'missed')); }
      else if (t === 'guard') parts.push('+' + toInt(e.v) + ' guard');
      else if (t === 'heal' || t === 'item') parts.push('+' + toInt(e.v) + ' hp');
    }
    if (truthy(e.combo)) parts.push('✨' + e.combo);
    return ext({ by: by, types: [t], tags: [String(nn(e.tag, ''))], txt: parts.length ? parts.join(' · ') : String(nn(e.n, 'piece')), tg: tg });
  }

  /** Chips grouped by chain (pfight_chips_board). */
  function chipsBoard(events) {
    var groups = [], g = null, i, j;
    for (i = 0; i < events.length; i++) {
      var e = events[i];
      if (truthy(e.tick) || (e.env !== undefined && e.env !== null)) continue;
      if (truthy(e.connect)) { if (g) groups.push(g); g = null; groups.push([e]); continue; }
      if (truthy(e.root)) { if (g) groups.push(g); g = [e]; } else if (g) g.push(e);
    }
    if (g) groups.push(g);
    var chips = [];
    for (i = 0; i < groups.length; i++) {
      g = groups[i];
      if (truthy(g[0].connect)) { chips.push({ by: 'me', types: g[0].types, tags: [], txt: 'joined ' + toInt(g[0].size), chain: false }); continue; }
      var by = String(g[0].by), bar = 0.0, fhs = 0.0, guard = 0, heal = 0, dmg = 0, types = [], tags = [];
      for (j = 0; j < g.length; j++) {
        var f = g[j];
        types.push(String(f.t)); tags.push(String(nn(f.tag, '')));
        if (f.by === 'me') { bar += Number(nn(f.bar, 0)); fhs += Number(nn(f.fh, 0)); if (f.t === 'guard') guard += toInt(f.v); if (f.t === 'heal' || f.t === 'item') heal += toInt(f.v); }
        else dmg += toInt(nn(f.dmg, 0));
      }
      var parts = [];
      if (fhs > 0) parts.push('-' + iround(fhs) + ' hp'); if (bar > 0) parts.push('+' + iround(bar) + ' charm'); if (guard) parts.push('+' + guard + ' guard'); if (heal) parts.push('+' + heal + ' hp'); if (dmg) parts.push('-' + dmg + ' hp');
      chips.push({ by: by, types: types, tags: tags, txt: parts.length ? parts.join(' · ') : 'setup', chain: g.length > 1 });
    }
    return chips;
  }

  return {
    // the public API
    envTable: envTable, envDeck: envDeck, tiles: tiles, playerDeck: playerDeck, newFight: newFight, start: start, play: play, pass: pass, view: view,
    cells: cells, edges: edges, joint: joint, groupSpots: groupSpots, groupFit: groupFit, groupOptions: groupOptions, search: search,
    line: line, chipEvent: chipEvent, chipsBoard: chipsBoard,
    // more of the PHP functions
    check: check, chain: chain, links: links, place: place, placeGroup: placeGroup, connect: connect, groupCells: groupCells, score: score, expire: expire,
    flip: flip, canFlip: canFlip, cellPreview: cellPreview, v1Cfg: v1Cfg, v1r: v1r, PFB_V1_PRE: PFB_V1_PRE, ter: ter, envLine: envLine, forecast: forecast, envTurn: envTurn, lifeOf: lifeOf,
    spawn: spawn, endRound: endRound, foeTurn: foeTurn, intent: intent, snap: snap, fx: fx, begin: begin, fire: fire,
    makeTile: makeTile, foeDeck: foeDeck, temper: temper, value: value, apply: apply, checkEnd: checkEnd, draw: draw, rand: rand, shuffle: shuffle,
    collection: collection, box: box, boxCheck: boxCheck, boxCapacity: boxCapacity, unlocks: unlocks,
    round: round, crc32: crc32, clone: clone,
    // data
    W: PFB_W, H: PFB_H, LIFE: PFB_LIFE, SIDE: PFB_SIDE, HOLE: PF_HOLE, STAT: PF_STAT, COMBOS: PF_COMBOS, TAGS: PF_TAGS, MODS: PF_MODS,
    CALLING_TILE: PF_CALLING_TILE, BASE_KEYS: PF_BASE_KEYS, GENTLE: PF_GENTLE, SIGNATURE: PF_SIGNATURE, TURN_CAP: PF_TURN_CAP, HAND_CAP: PF_HAND_CAP
  };
});
