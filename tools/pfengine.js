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
      jab: { n: 'Jab', t: 'hurt', v: 3, r: 'craft', tag: 'quick' },
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
    var hm = tp === 'hostile' ? 1.0 : PF_GENTLE_HM, cm = tp === 'hostile' ? PF_HOSTILE_CM : 1.0;
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

  /** 2.7.06: Luck redraw (pf_redraw): swap one hand piece for a fresh draw; costs one of the redraws. A flipped piece goes back the right way up. */
  function redraw(s, handIdx, turn) {
    if (truthy(s.over) || turn !== s.turn || s.me.redraws < 1 || handIdx < 0 || handIdx >= s.me.hand.length) return false;
    var t = clone(s.me.hand.splice(handIdx, 1)[0]);
    delete t.flip; delete t.ft;
    s.me.discard.push(t);
    s.me.redraws--;
    draw(s, 'me', s.me.hand.length + 1);
    return true;
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
    if (hasAb(s)) abEnrage(s);   // 2.7.01 Enrage
    var v1 = !!s.v1, fn = v1 ? round(s.fh.now, 1) : s.fh.now, bn = v1 ? round(s.bar.now, 1) : s.bar.now;   // 2.6.78 (v1): compared as shown (one decimal)
    if (v1 && truthy(s.v1.onebar)) {   // 2.6.95 (one shared bar): the larger share names the ending (bosses are always seen off)
      if (round(Number(s.fh.now) + Number(s.bar.now), 1) >= s.fh.max) { s.over = (s.cm > 0 && !s.boss && s.bar.now > s.fh.now) ? 'charmed' : 'seen_off'; return true; }
      if (s.me.hp <= 0) { s.over = 'defeat'; return true; }
      return false;
    }
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
          abs = (ft && tile.tag === 'pierce') || truthy(e.ambp) ? 0 : Math.min(theirs.block, dmg); theirs.block -= abs; dmg -= abs;
          if (abs > 0 && theirs.thorns) { pr = 2 * s.hm; s.fh.now += pr; e.pricked = round(pr, 1); }
          theirs.hp = Math.max(0, theirs.hp - dmg);
          e.dmg = dmg; e.blocked = abs;
          if (hasAb(s)) abHit(s, e, dmg);   // 2.7.01 Drain, Stagger
          if (ft) {
            if (tile.tag === 'poison') { theirs.poison = Math.min(PF_POISON_CAP, toInt(nn(theirs.poison, 0)) + 2); theirs.poison_v = Math.max(toInt(nn(theirs.poison_v, 0)), Math.max(1, toInt(Math.ceil((s.v1 ? toInt(tile.v) : val) / 3)))); e.poisoned = theirs.poison; }
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
          if (tile.tag === 'poison') { s.foe.poison = 2; s.foe.poison_v = Math.max(toInt(s.foe.poison_v), Math.max(1, toInt(Math.ceil((s.v1 ? toInt(tile.v) : val) / 2)))); }
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
        if (tile.tag === 'evade') { mine.evade = 1; if (who === 'me') mine.evd = 1; }   // 2.7.01: evd = you played an Evade this round
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
        else e.healed = round(foeHeal(s, Number(val)), 1);
        break;
      case 'charm':
        if (who === 'me') {
          add = val * s.cm; if (hasAb(s)) { var wy = abOf(s, 'wary'); if (wy) add *= Number(wy.mult); }   // 2.7.01 Wary
          s.bar.now += add; s.bar.charm += add; e.bar = round(add, 1);
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
          if (tile.tag === 'poison') { theirs.poison = Math.min(PF_POISON_CAP, toInt(nn(theirs.poison, 0)) + 2); theirs.poison_v = Math.max(toInt(nn(theirs.poison_v, 0)), Math.max(1, toInt(Math.ceil((s.v1 ? toInt(tile.v) : val) / 2)))); e.poisoned = theirs.poison; }
          if (tile.tag === 'trip') { theirs.slowdraw = 1; e.tripped = 1; }
          if (tile.tag === 'heal') e.healed = round(foeHeal(s, Number(val)), 1);
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
    if (root && who === 'me' && ft) { if (tile.tag === 'plenty') mine.more = 1; if (tile.tag === 'simmer') mine.regen = 2; }   // 2.6.990
    if (root && who === 'me' && m === 'sticky' && fit) draw(s, 'me', Math.min(PF_HAND_CAP, s.me.hand.length + 1));
    if (root && who === 'me' && m === 'lucky' && !(s.lucky_used && truthy(s.lucky_used[tile.k]))) {
      if (!s.lucky_used) s.lucky_used = {};
      s.lucky_used[tile.k] = 1; mine.redraws = Math.min(3, mine.redraws + 1);
    }
    if (truthy(ck) && truthy(PF_COMBOS[ck].barPct) && who === 'me') {
      add = val * PF_COMBOS[ck].barPct / 100 * s.cm; if (hasAb(s)) { var wy2 = abOf(s, 'wary'); if (wy2) add *= Number(wy2.mult); } s.bar.now += add; s.bar.charm += add; e.bar = round(Number(nn(e.bar, 0)) + add, 1);
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
  var PFB_USEUP = 3, PFB_SUN_MULT = 2.0, PFB_BRAMBLE = 0.10, PFB_BRAMBLE_FOE = 0.5, PFB_THORN = 0.10, PFB_EVENT_FOE = 0.7, PFB_TEAM2 = 1.3, PFB_TEAM3 = 1.6;
  var PFB_TEAM_SRC = ['pal', 'tool', 'crop', 'craft', 'region', 'knack', 'calling'], PFB_SRC = ['basic', 'knack', 'calling', 'tool', 'crop', 'craft', 'pal', 'region', 'wear', 'creature', 'env'];
  var PFB_SRC_FAM = { pal: 'body', tool: 'craft', crop: 'mind', craft: 'craft', wear: 'body' }, PFB_UP = { hurt: 1, charm: 1, trick: 1 };
  var PFB_CLASS_LEAN = { critter: 'mind', insect: 'mind', water: 'body', bird: 'craft', plant: 'mind', fungus: 'mind', reptile: 'craft', amphibian: 'craft', beast: 'body' };
  var PFB_LIFE_MIN = 2, PFB_LIFE_MAX = 4, PFB_TOOL_WEAR = 2;
  var PFB_V1_FOE_MULT = { small: 0.93, medium: 0.735, large: 0.428, boss: 0.60 }, PFB_V1_BAR_MULT = { small: 1.378, medium: 1.7743, large: 1.7193, boss: 0.9158 };   // 2.7.01 policy D (balance-report.md): was 0.855 / 0.48 / 0.378 / 0.585 and 1.325 / 1.491 / 1.495 / 0.825;   // week-1 retune (T13): was 0.95 / 0.60 / 0.42 / 0.585 and 0.828 / 0.994 / 1.15 / 0.611;   // after 2.6.94 (AIMSTICK): boss x1.3 with its bar x0.8 (was 0.45 / 0.764)
  // after 2.6.94: the LEVEL CURVE (PFB_V1_LEVEL in pfboard.php, where the why is): f = clamp(1 + slope x (level - ref), lo, hi) as [slope, ref, lo, hi]; piece values x f, bar x min(1, f)
  var PFB_V1_LEVEL = { small: [0.05, 6, 1.0, 1.8], medium: [0.05, 12, 0.85, 1.25], large: [0.025, 22, 0.85, 1.10], boss: [0.0, 1, 1.0, 1.0] };
  // the compat rules (PFB_V1_PRE in pfboard.php, where the keys are explained): a saved fight without a key plays by the 2.6.94 value
  var PF_HOSTILE_CM = 0.8;
  var PFB_V1_ONEBAR_BAR = 1.15;   // 2.6.95: the shared bar is this much longer than the old creature health
  var PFB_V1_PRE = { aside: 1, must: 1, freepass: 0, flip1: 1, nowm: 0, nothorn: 0, redraw: 0, onebar: 0, aimtot: 0, keepmine: 0, aimhit: 0, useroot: 0, kinds: 0, blankrand: 0, order: 0, spawn: 0, abil: 0, style: 0, cset: 0, envopen: 0, tagfx: 0, paltgt: 0 };   // paltgt (2.7.08): pal targeting (pfb_pal_target)
  var PFB_KIND_SWARM_ADD = 1, PFB_KIND_SWARM_MAX = 2, PFB_KIND_GRUDGE = 0.25, PFB_KIND_GRUDGE_MAX = 3, PFB_KIND_VENOM_RNDS = 2, PFB_KIND_VENOM_POISON = 2;   // 2.6.98 class rules (pfb_kind_of ...)
  function kindOf(c, size) {
    if (size === 'boss') return 'boss';
    var cl = String(nn(c['class'], '')).toLowerCase(), ks = ['critter', 'bird', 'beast', 'water', 'plant', 'reptile'];
    for (var i = 0; i < ks.length; i++) if (cl.indexOf(ks[i]) === 0) return ks[i];
    return '';
  }
  function kindNow(s) { return v1r(s, 'kinds') === 1 ? String(nn(s.foe.kind, '')) : ''; }
  function venom(s, p) { if (p.by === 'foe' && kindNow(s) === 'reptile') { if (!s.ven) s.ven = {}; s.ven[p.x + ',' + p.y] = toInt(abp(s, 'vrnds', PFB_KIND_VENOM_RNDS)) + 1; } }
  var PFB_ABIL = {
    'swarm': ["E", "critter", 0, [], "Swarm", "Its Hurt hits +1 for every 2 of its other pieces on board, up to +2"],
    'swarm-dense': ["E", "critter", 1, {"smax": 3}, "Dense Swarm", "Its Hurt hits +1 for every 2 of its other pieces on board, up to +3"],
    'two-aims': ["E", "bird", 0, [], "Two aims", "It shows two cells; take the first and it plays the second"],
    'grudge': ["E", "beast", 0, [], "Grudge", "Each block of its aim makes its Hurt 25% harder, up to 3 times"],
    'grudge-fury': ["E", "beast", 1, {"gpct": 0.35, "gmax": 2}, "Fury grudge", "Each block of its aim makes its Hurt 35% harder, up to 2 times"],
    'grudge-slow': ["E", "beast", 1, {"gpct": 0.15, "gmax": 5}, "Slow grudge", "Each block of its aim makes its Hurt 15% harder, up to 5 times"],
    'current': ["E", "water", 0, [], "Current", "After its piece lands, one of your touching pieces slides 1 cell"],
    'current-hard': ["E", "water", 1, {"slide": 2}, "Strong current", "After its piece lands, one of your touching pieces slides up to 2 cells"],
    'grows': ["E", "plant", 0, [], "Grows", "After its turn a Bramble grows beside its piece (one of its own at a time)"],
    'grows-twin': ["E", "plant", 1, {"gcap": 2}, "Twin growth", "After its turn a Bramble grows beside its piece (up to 2 of its own)"],
    'venom-trail': ["E", "reptile", 0, [], "Venom trail", "Where its piece leaves is venom 2 rounds; your piece there poisons you 2 a round"],
    'venom-long': ["E", "reptile", 1, {"vrnds": 3, "vpoison": 1}, "Long venom", "Where its piece leaves is venom 3 rounds; your piece there poisons you 1 a round"],
    'two-turns': ["E", "boss", 0, [], "Two turns", "It also shows the piece it plays next round; that piece is forced"],
    'drain1': ["N", "drain", 1, {"pct": 0.25}, "Drain", "A hit that lands heals it by a quarter of the damage"],
    'drain2': ["N", "drain", 2, {"pct": 0.5}, "Drain", "A hit that lands heals it by half of the damage"],
    'plated1': ["N", "plated", 1, {"pct": 0.03}, "Plated", "Starts each turn with some guard"],
    'plated2': ["N", "plated", 2, {"pct": 0.05}, "Plated", "Starts each turn with a good deal of guard"],
    'enrage1': ["N", "enrage", 1, {"at": 0.5, "mult": 1.15}, "Enrage", "Past half its resolve, its Hurt hits 15% harder"],
    'enrage2': ["N", "enrage", 2, {"at": 0.4, "mult": 1.25}, "Enrage", "Past 40% of its resolve, its Hurt hits 25% harder"],
    'wary1': ["N", "wary", 1, {"mult": 0.85}, "Wary", "Your Charm fills 15% less"],
    'wary2': ["N", "wary", 2, {"mult": 0.75}, "Wary", "Your Charm fills 25% less"],
    'toughhide1': ["N", "toughhide", 1, {"cut": 2}, "Tough hide", "Your first Hurt each turn is 2 weaker"],
    'toughhide2': ["N", "toughhide", 2, {"cut": 3}, "Tough hide", "Your first Hurt each turn is 3 weaker"],
    'ambush1': ["N", "ambush", 1, {"mult": 1.4, "pierce": 0}, "Ambush", "Its first hit of the fight is 40% harder"],
    'ambush2': ["N", "ambush", 2, {"mult": 1.7, "pierce": 1}, "Ambush", "Its first hit of the fight is 70% harder and ignores guard"],
    'stagger1': ["N", "stagger", 1, {"pct": 0.2}, "Stagger", "A big hit leaves you one piece short next round"],
    'stagger2': ["N", "stagger", 2, {"pct": 0.12}, "Stagger", "Even a middling hit leaves you one piece short next round"],
    'regrow1': ["N", "regrow", 1, {"pct": 0.02, "turns": 5}, "Regrow", "Heals a little each turn at the start of a fight"],
    'regrow2': ["N", "regrow", 2, {"pct": 0.03, "turns": 5}, "Regrow", "Heals some each turn at the start of a fight"],
    'D1': ["D", "", 0, [], "Sharp", "Its hits go through guard"],
    'D2': ["D", "", 0, [], "Venom spit", "Its hits keep working"],
    'D3': ["D", "", 0, [], "Snare", "It makes you lose pieces"],
    'D4': ["D", "", 0, [], "Flurry", "It often plays twice"],
    'D5': ["D", "", 0, [], "Ram", "Its guard becomes damage"],
    'D6': ["D", "", 0, [], "Shell", "Its guard lasts"],
    'D7': ["D", "", 0, [], "Prickles", "Blocked hits prick you"],
    'D8': ["D", "", 0, [], "Slip", "It dodges your first hits"],
    'D9': ["D", "", 0, [], "Mender", "It heals itself"],
    'D10': ["D", "", 0, [], "Bruiser", "Heavy hits"],
    'D11': ["D", "", 0, [], "Wall", "Lots of guard"],
    'D12': ["D", "", 0, [], "Mixed", "A bit of everything"]
  };   // = PFB_ABIL in pfboard.php (tests/pfengine_js.sh compares the two)
  var PFB_AB_RANGE = {"critter": {"smax": [1, 4]}, "beast": {"gpct": [0.05, 0.5], "gmax": [1, 6]}, "water": {"slide": [1, 2]}, "plant": {"gcap": [1, 3]}, "reptile": {"vrnds": [1, 4], "vpoison": [1, 3]}, "drain": {"pct": [0.15, 0.6]}, "plated": {"pct": [0.02, 0.07]}, "enrage": {"at": [0.35, 0.7], "mult": [1.1, 1.35]}, "wary": {"mult": [0.65, 0.92]}, "toughhide": {"cut": [1, 4]}, "ambush": {"mult": [1.2, 2.0], "pierce": [0, 1]}, "stagger": {"pct": [0.08, 0.25]}, "regrow": {"pct": [0.01, 0.04], "turns": [3, 6]}};
  /** The resolved numbers of an N ability in this fight (pfb_ab), or null. Off unless the fight has the `abil` rule. */
  function abOf(s, fx) {
    if (!s.foe.ab || !s.foe.ab.length || v1r(s, 'abil') !== 1) return null;
    for (var i = 0; i < s.foe.ab.length; i++) { var id = s.foe.ab[i]; if (PFB_ABIL[id][1] === fx && PFB_ABIL[id][0] === 'N') return has(s.foe.abp, id) ? s.foe.abp[id] : PFB_ABIL[id][3]; }
    return null;
  }
  /** One number of the class-rule ability (E) of this fight, else d (pfb_abp). */
  function abp(s, k, d) {
    if (!s.foe.ab || !s.foe.ab.length || v1r(s, 'abil') !== 1) return d;
    for (var i = 0; i < s.foe.ab.length; i++) { var id = s.foe.ab[i]; if (PFB_ABIL[id][0] === 'E' && has(s.foe.abp, id) && s.foe.abp[id][k] !== undefined) return s.foe.abp[id][k]; }
    return d;
  }
  function hasAb(s) { return !!(s.foe.ab && s.foe.ab.length); }
  function clampAb(kind, k, v) { var r = PFB_AB_RANGE[kind] && PFB_AB_RANGE[kind][k]; return r ? Math.max(r[0], Math.min(r[1], v)) : v; }
  /** newFight: the creature's abilities into the state (pfb_ab_init). */
  function abInit(s, c) {
    var ids = [], abpm = {}, po = nn(c.abp, {});
    (Array.isArray(c.ab) ? c.ab : []).forEach(function (id) {
      if (!has(PFB_ABIL, id) || ids.indexOf(id) >= 0) return;
      ids.push(id); var a = PFB_ABIL[id];
      if (a[0] === 'D') return;
      abpm[id] = {}; for (var k0 in a[3]) abpm[id][k0] = a[3][k0];
      var ov = (po && !Array.isArray(po) && has(po, id)) ? po[id] : {};
      for (var k in ov) if (has(a[3], k)) abpm[id][k] = clampAb(a[1], k, Number(ov[k]));
      if (a[0] === 'E' && truthy(s.v1.kinds)) s.foe.kind = a[1];
    });
    if (!ids.length) return;
    s.foe.ab = ids; s.foe.abp = abpm; s.foe.enr = 0; s.foe.amb = abOf(s, 'ambush') ? 1 : 0; s.foe.turns = 0; s.me.tough = 0;
  }
  function abNote(s, kind, n) {
    var e = note(kind, n); e.barnow = round(Number(s.bar.now), 1); e.fhnow = round(Number(s.fh.now), 1); e.hpnow = toInt(s.me.hp); e.gnow = toInt(s.me.block);
    return e;
  }
  /** After one of its Hurt pieces landed dmg on you: Drain, Stagger (pfb_ab_hit). */
  function abHit(s, e, dmg) {
    if (dmg <= 0) return;
    var d = abOf(s, 'drain'); if (d) { var h = dmg * Number(d.pct); foeHeal(s, h); e.drained = round(h, 1); }
    var g = abOf(s, 'stagger'); if (g && dmg >= Number(g.pct) * Number(s.me.max)) { s.me.slowdraw = 1; e.staggered = 1; }
  }
  /** The start of its turn, after the poison tick: its turn count, Regrow, Plated (pfb_ab_turn). */
  function abTurn(s, ev) {
    s.foe.turns = toInt(nn(s.foe.turns, 0)) + 1;
    var y = Number(s.fh.max), r = abOf(s, 'regrow');
    if (r && s.foe.turns <= toInt(r.turns)) {
      var b = Number(s.fh.now) + Number(s.bar.now); foeHeal(s, y * Number(r.pct)); var a = Number(s.fh.now) + Number(s.bar.now);
      if (a < b) ev.push(abNote(s, 'regrow', String(round(b - a, 1))));
    }
    var pl = abOf(s, 'plated');
    if (pl) { var g = toInt(Math.ceil(y * Number(pl.pct))); if (g > toInt(s.foe.block)) { s.foe.block = g; ev.push(abNote(s, 'plated', String(g))); } }
  }
  /** Enrage: set (once) the first time the bar is at or past its share (pfb_ab_enrage). */
  function abEnrage(s) {
    if (truthy(s.foe.enr)) return; var en = abOf(s, 'enrage'); if (!en) return;
    var prog = (s.v1 && truthy(s.v1.onebar)) ? Number(s.fh.now) + Number(s.bar.now) : Number(s.fh.now);
    if (prog >= Number(en.at) * Number(s.fh.max)) s.foe.enr = 1;
  }
  function v1r(s, k) { var v = s.v1 && s.v1[k] !== undefined && s.v1[k] !== null ? s.v1[k] : PFB_V1_PRE[k]; return toInt(v === undefined ? 0 : v); }
  function v1Lvx(c, lv) { return round(Math.max(Number(c[2]), Math.min(Number(c[3]), 1 + Number(c[0]) * (lv - toInt(c[1])))), 4); }   // 2.6.79 retune for isolated environment pieces   // 2.6.75 retune for environment pieces
  // 2.6.75 ENVIRONMENT PIECES: the environment is a third player; after the creature's turn it places one piece from its own deck, its next piece lies face up a round ahead.
  // PFB_ENV_ROWS is a copy of game/includes/data/pf_env.txt (key, name, kind, edges L,R,T,B, life, copies small/medium/large/boss, blurb); tests/pfengine_js.sh compares the two.
  var PFB_ENV_KINDS = ['sun', 'bramble', 'rain', 'wind', 'mud', 'thorn'], PFB_ENV_N = { small: 2, medium: 2, large: 2, boss: 2 }, PFB_RAIN = 0.20, PFB_THORN_FOE = 0.5, PFB_ENV_CAP = 0.7, PFB_MUD = 0.25;
  var PFB_ENV_EDGE = { h: 'hole', k: 'knob', b: 'body', m: 'mind', c: 'craft' };
  var PFB_ENV_ROWS = [
    ['sun', 'Sun', 'sun', 'hb,km,kc,hc', 3, [2, 2, 2, 2], 'Fire it in your chain: your pieces in that chain count double.'],
    ['bramble', 'Bramble', 'bramble', 'hm,kc,kb,hb', 3, [1, 2, 2, 3], 'Fire it in your chain: the creature\'s Yield bar fills a tenth. If the creature fires it, you lose a tenth of your health.'],
    ['rain', 'Rain', 'rain', 'hc,kb,km,hm', 3, [2, 2, 2, 2], 'Fire it in your chain: you get guard.'],
    ['wind', 'Wind', 'wind', 'hb,kc,hm,km', 2, [1, 1, 1, 1], 'Fire it in your chain: the piece its arrow points at slides one cell.'],
    ['mud', 'Mud', 'mud', 'f,f,f,f', 3, [1, 1, 1, 1], 'Nothing links to it, and a piece next to it counts a quarter less.'],
    ['thorn', 'Thornburst', 'thorn', 'hm,kb,hc,kc', 3, [1, 2, 2, 2], 'Fire it in your chain and you lose a tenth of your health. The creature loses half as much.']
  ];
  var PFB_ENV_REGIONS = { NA: { wind: 1 }, CA: { sun: 1 }, CB: { sun: 1 }, SA: { rain: 1 }, NWE: { rain: 1 }, SE: { sun: 1 }, EE: { bramble: 1 }, MENA: { wind: 1 }, WCA: { bramble: 1 }, ESA: { thorn: 1 }, CSA: { mud: 1 }, EA: { rain: 1 }, SEA: { rain: 1, mud: 1 }, OC: { wind: 1 } };
  var KIND_GROUND = { sunbeam: 'sun', creep: 'br', puddle: 'mud' }, GROUND_N = { sun: 'nsun', br: 'nbr', mud: 'nmud' };

  function isNumeric(v) { return (typeof v === 'number' && isFinite(v)) || (typeof v === 'string' && v.trim() !== '' && isFinite(Number(v))); }
  var PFB_V1_BAR_EASE_MEDIUM = [0.30, 12, 26];   // 2.7.01 (policy D): [floor, level it starts to rise, level it is 1.0]
  var PFB_V1_BAR_EASE_SMALL = [0.30, 14, 30];     // 2.7.01 balance pass 2: the same ease for the small creatures
  function barEase(size, lv) {
    if ((size !== 'medium' && size !== 'small') || lv <= 0) return 1.0;
    var e = size === 'small' ? PFB_V1_BAR_EASE_SMALL : PFB_V1_BAR_EASE_MEDIUM, f = e[0], a = e[1], b = e[2];
    return round(Math.max(f, Math.min(1.0, f + (1.0 - f) * (lv - a) / (b - a))), 4);
  }
  // 2.7.01 (policy D): data/pf_creature_tune.txt, slug -> [foe_x, bar_x] (rebuild this line from the file when it changes; tests/pfengine_js.sh fails on a drift)
  var PFB_V1_TUNE = {'aardvark':[0.769,0.992],'albatross':[0.691,1],'alligator-snapper':[0.761,0.981],'alpha-dingo':[1.083,1],'ancient-snapper':[0.758,0.992],'ant-scouts':[2.909,1.203],'aphid-swarm':[3.035,1.155],'arctic-fox-kit':[2.088,1],'army-ant-column':[0.781,1],'badger':[0.839,1.01],'badger-cub-gang':[2.56,1],'banana-slug':[3.077,1.218],'bark-scorpion':[0.861,1],'barn-rat':[2.073,1],'basilisk-runner':[0.886,1],'beach-hopper-horde':[1.269,0.992],'beaded-lizard':[0.654,1],'bearded-pig':[0.922,1],'beaver-foreman':[0.902,1],'bison-calf-stampede':[0.755,1],'black-bear':[1.118,0.991],'black-jaguar':[1.034,1],'blue-ring-octopus':[1.047,1],'bog-leech':[2.362,1],'bog-pike':[1.07,0.981],'bombardier-beetle':[0.904,1],'booby-colony':[0.727,0.992],'bramble-pup-pack':[1.198,1],'bramble-wolf':[0.82,1],'bullfrog':[3.1,1.064],'burrowing-owl':[0.749,0.992],'cactus-beast':[1.381,1.01],'camel-calf':[0.941,1.01],'cane-toad':[0.904,1],'capuchin-pickpocket':[2.295,0.987],'capybara-herd':[0.878,1.008],'caracal':[0.62,1],'caribou-bull':[1.153,0.991],'carpenter-ant-gang':[1.28,0.993],'carpenter-bee':[0.752,1],'carrion-beetle-crew':[1.685,1],'carrion-crow':[1.664,1],'cassowary-chick-creche':[0.824,1.01],'cave-centipede':[0.931,1],'cave-glowworm':[2.686,1],'clam-lurker':[1.088,1.009],'cliff-ram':[0.85,1.009],'cloud-kite':[0.783,0.991],'cloud-leopard':[1.078,1],'coati-band':[1.059,1.01],'cockle-bed':[2.222,0.991],'coconut-crab-titan':[0.796,1],'coconut-crab-youngster':[1.04,1.003],'condor':[0.781,1],'conger-brute':[1.077,0.991],'coral-golem':[1.31,1.009],'cormorant-line':[0.621,1.017],'crab-eating-raccoon':[0.635,0.992],'croc-hatchling-scatter':[1.247,1],'dawn-skipper-flutter':[2.902,0.992],'deep-octopus':[0.962,1.009],'delta-gharial':[0.896,1.013],'desert-camel':[1.069,0.989],'desert-gila-dragon':[1.041,1],'desert-spadefoot':[0.767,1.01],'desert-tortoise':[1.11,1],'dingo-pup-pack':[1.073,1],'dune-racer':[0.652,0.993],'dune-scorpion':[2.874,1],'dune-snail':[2.194,1],'dung-beetle':[2.798,1.02],'dusk-moth':[3.098,1.009],'eagle-owl':[0.631,0.991],'earwig':[2.988,1.035],'earwig-matron':[0.962,1],'egret-flock':[0.762,0.993],'elder-bramble-wolf':[0.68,1],'elder-mire-toad':[1.223,1],'elder-tiger':[0.897,0.986],'elephant-seal-bull':[1.043,1],'ember-beetle':[2.676,1],'emerald-python':[1.333,1],'emperor-scorpion':[1.108,0.991],'emu-mob':[0.649,0.989],'fennec':[0.905,0.992],'fern-cassowary':[0.721,1.01],'fiddler-crab-band':[2.739,1.02],'fire-ant-raiders':[2.27,1],'firefly-flicker':[2.01,1],'fisher':[0.744,1.008],'fishing-cat':[0.67,0.993],'fishing-spider':[2.796,1],'fly-swarm':[2.879,1.026],'fox-kit-pair':[2.842,1.063],'foxfire-wisp':[1.101,0.992],'frigatebird':[0.859,0.981],'frilled-lizard':[0.894,1],'frost-beetle':[2.226,1],'frost-hare':[1.897,0.989],'frost-owl-regent':[0.433,0.909],'garden-eel-colony':[1.171,0.992],'garden-snail':[2.917,1.168],'ghost-leopard':[0.907,1],'ghost-slug':[1.119,0.991],'giant-anteater':[0.876,1],'giant-banded-snail':[1.14,0.992],'giant-bumblebee':[1.344,0.991],'giant-centipede':[2.297,0.99],'giant-clam':[1.219,0.992],'giant-millipede':[0.866,1.009],'giant-mire-leech':[0.945,1],'glacier-bear':[1.07,1.014],'glacier-cub':[1.731,1],'glass-frog':[1.346,1],'glass-wyrm':[0.655,1.003],'glow-grub-cluster':[1.229,1],'gnat-cloud':[2.63,1.009],'goat-kid-gang':[2.251,1],'golden-mantella':[0.679,0.992],'golden-mole':[0.648,1],'golden-orb-weaver':[0.945,1],'goliath-frog':[0.935,1],'goliath-heron':[0.846,0.992],'gorse-beast':[1.479,1.009],'grass-snake':[0.892,0.981],'great-hawk':[0.856,0.987],'grey-heron':[1.098,1],'griffon-vulture':[0.955,1],'grumpy-lemming':[2.043,1.01],'gyrfalcon':[0.733,1],'hermit-crab-convoy':[3.1,1.633],'hermit-crab-hoarder':[2.77,0.992],'herring-gull':[2.092,0.99],'honey-badger-brute':[0.937,1.01],'honeybee-swarm':[1.401,1],'horned-viper':[0.669,1],'hornet-sentry':[0.731,1],'house-centipede-skitter':[3.1,2.15],'hyena-pup-cackle':[1.092,1],'ibex-patriarch':[1.073,1],'ice-floe-seal':[1.588,0.992],'jackrabbit':[0.764,1],'jade-jaguar':[0.763,1.01],'jaguar-cub-pair':[1.871,0.992],'jaguarundi':[0.695,0.991],'jumping-spider':[2.776,1.896],'jungle-crow':[0.692,1.01],'jungle-tiger':[0.895,0.982],'kelp-fly-swarm':[1.157,1],'kestrel-hoverer':[1.14,1],'komodo-pup':[0.877,0.992],'kraken-spawn':[1.381,0.992],'lammergeier':[1.136,1],'land-crab-march':[1.04,1],'lantern-glowworm-queen':[0.922,1],'lava-beetle':[0.777,1],'leafcutter-column':[2.235,1.009],'lemming-kit-scurry':[2.315,1.01],'leopard-slug':[2.82,1.024],'lichen-golem':[1.806,1.008],'luna-moth':[0.842,1.01],'magpie-mob':[0.937,0.992],'mangrove-crab-court':[1.077,1],'mangrove-crab-emperor':[0.947,0.991],'mangrove-crab-king':[1.21,0.992],'marmot-bruiser':[0.816,0.989],'marsh-harrier':[0.811,1.01],'marsh-rat':[0.906,1],'marsh-spark-swarm':[2.187,1],'midge-cloud':[2.953,2.15],'mire-toad':[1.087,0.981],'mischief-monkey':[1.115,1],'mite-swarm':[2.935,1],'mole-rat-gang':[0.586,0.989],'moray-lurker':[0.643,1],'mosquito-storm':[1.228,1],'moss-golem':[1.908,0.991],'mountain-buzzard':[0.641,1],'mud-crab-brawler':[0.763,1],'mud-dauber':[2.498,1],'mudskipper-troop':[1.497,1],'musk-ox':[1.076,1],'muskrat-crew':[2.669,0.991],'natterjack-chorus':[2.3,1],'nettle-lurker':[3.019,0.999],'night-adder':[0.706,1],'night-heron':[0.586,1.01],'ocelot':[1.042,1],'old-bramblehorn':[0.951,1],'old-brock':[0.782,0.991],'orb-spider':[2.025,1.01],'outback-dingo':[0.529,0.991],'pack-rat':[1.055,1],'palm-thief-crab':[1.13,1],'pangolin':[0.803,1],'paper-wasp':[1.866,1.008],'peat-golem':[1.93,1.015],'pelican-parliament':[1.125,1],'piglet-squeal':[3.081,1.102],'pika-sentry':[2.43,1.009],'poison-dart-frog':[1.317,1.008],'prairie-bison':[1.099,0.993],'ptarmigan-flock':[0.755,0.992],'raccoon':[1.23,1],'ramshorn-pond-snail':[2.953,1.459],'ratel-pair':[0.706,1.008],'raven-pair':[2.21,0.986],'red-fox':[0.949,1],'red-stag':[1.255,0.992],'reef-eel-tyrant':[1.101,1],'reef-leviathan':[0.785,1],'reef-turtle':[1.1,1],'reindeer-calf-herd':[2.147,1],'river-otter':[0.931,1],'robber-crab-baron':[0.645,1],'rock-agama':[1.641,1],'rock-crab-pincher':[0.799,0.992],'rock-earwig':[2.929,1.022],'rock-partridge-covey':[0.613,1.008],'rock-python':[0.845,1],'rock-viper':[0.676,0.991],'roebuck':[2.155,0.991],'salt-mite-swarm':[2.015,1],'salt-sea-lion':[1.36,0.981],'saltmarsh-leech':[1.053,0.982],'saltwater-gharial':[1.05,1],'sand-fleas':[2.424,1],'sand-viper-matriarch':[1.161,0.981],'sandfish-skink-shoal':[3.077,1.548],'sandfly-cloud':[2.931,1.701],'savanna-hyena':[0.66,0.992],'scarab-roller':[1.217,1],'sea-otter-bandit':[2.826,1],'sea-slug-drift':[2.204,0.992],'sea-urchin-bed':[2.978,1.296],'seal-pup-raft':[1.331,0.992],'ship-rat-crew':[0.519,0.991],'shore-crab':[2.605,1.046],'shore-earwig':[3.1,1.316],'skua-raider':[0.811,1],'sloth-bear':[0.614,0.981],'smooth-snake':[0.903,0.991],'snapper-hatchling-bask':[2.392,1.012],'snow-bunting-flurry':[2.573,1],'snow-flea-swarm':[2.524,1.093],'snow-leopard-cub':[0.775,0.991],'snow-lynx':[0.74,1.009],'snow-moth':[2.813,1.008],'snow-owl-fledgling':[0.709,0.989],'snow-owl-monarch':[0.798,0.991],'snowshoe-leveret-dash':[3.025,1.123],'snowy-owl-scout':[1.14,1],'spice-monitor':[0.818,0.992],'star-nosed-mole':[2.959,1],'stickleback-shoal':[2.537,1.028],'stink-badger':[0.559,0.992],'stoat':[2.095,1],'storm-eagle':[0.613,1],'storm-wisp':[1.052,1],'striped-hyena':[0.847,0.991],'sun-bear':[0.816,0.992],'sun-lizard':[1.404,1],'tamandua':[0.663,1.012],'tanuki':[0.884,1.01],'tawny-owl':[0.888,0.992],'termite-column':[1.344,1],'tern-squadron':[0.628,1.01],'thistle-beast':[2.55,1.01],'thorn-jackal':[0.664,1.009],'thorny-devil':[1.511,1.008],'thunder-yak':[0.594,1],'tide-crab-paladin':[1.449,0.992],'tide-crab-squire':[1.625,0.981],'tiger-leech':[2.447,1.004],'tortoise-hatchling-trundle':[2.522,1],'tree-frog-chorus':[2.091,1],'tree-monitor':[0.8,0.989],'tree-snake':[0.572,1],'tufted-lynx':[0.84,1.01],'tumblebug-troupe':[1.118,1],'tundra-vole-swarm':[2.26,1],'tunnel-mole':[1.925,0.991],'turkey-vulture':[0.84,1],'turtle-hatchling-dash':[2.822,1.122],'vine-snake':[0.722,0.991],'warthog':[0.85,1],'water-monitor':[0.744,0.991],'water-snake':[0.904,1],'weaver-ant-nest':[1.912,1],'whiteout-fox':[2.121,1],'wild-bactrian':[0.845,0.985],'wild-boar':[0.766,0.991],'wildcat':[0.798,0.992],'will-o-wisp':[3.029,1.078],'willow-grouse-covey':[2.408,1],'wolverine-cub':[1.818,1],'yak-calf-herd':[0.784,0.992],'yellowjacket-mob':[0.94,1],'zorilla-stink-squad':[0.81,1]};
  function v1Over(c, over) {   // pfb_v1_over: the creature's tune row multiplies foe_x / bar_x
    var t = PFB_V1_TUNE[String((c && c.slug) || '')];
    over = over || {};
    if (!t) return over;
    var o = {}; for (var k in over) o[k] = over[k];
    o.foe_x = Number(over.foe_x !== undefined && over.foe_x !== null ? over.foe_x : 1.0) * t[0];
    o.bar_x = Number(over.bar_x !== undefined && over.bar_x !== null ? over.bar_x : 1.0) * t[1];
    return o;
  }
  function v1Cfg(size, over, level) {
    if (!has(PFB_SIZE, size)) size = 'medium';
    var g = PFB_GROUND[size];
    var cfg = { w: PFB_SIZE[size][0], h: PFB_SIZE[size][1], ground: 0, nsun: g[0], nbr: g[1], nmud: g[2], sun: PFB_SUN_MULT, bramble: PFB_BRAMBLE, br_foe: PFB_BRAMBLE_FOE,
      events: 0, nev: PFB_EVENTS[size], thorn: PFB_THORN, ev_foe: PFB_EVENT_FOE, limit: PFB_USEUP, aim: 1, team2: PFB_TEAM2, team3: PFB_TEAM3,   // 2.7.06: Teamwork on again
      edges: 1, flip: 1, life: 0, tags: 1, foe: PFB_V1_FOE_MULT[size], bar: PFB_V1_BAR_MULT[size],
      env: 1, envn: PFB_ENV_N[size], rain: PFB_RAIN, th_foe: PFB_THORN_FOE, mud: PFB_MUD, envcap: PFB_ENV_CAP, nowm: 0, nothorn: 0, aside: 0, must: 0, freepass: 1, flip1: 0, onebar: 1, redraw: 1, aimtot: 1, aimhit: 0, kinds: 1, blankrand: 1, order: 1, spawn: 0, abil: 1, style: 1, cset: 1, envopen: 0, tagfx: 1, paltgt: 1 };   // 2.6.95: the aim carries its total; one shared bar; no set-aside, a piece need not link (you), passing is free   // 2.6.75: environment pieces; env 0 with ground 1, events 1 gives the 2.6.74 terrain
    for (var pk in PFB_V1_PRE) if (cfg[pk] === undefined) cfg[pk] = PFB_V1_PRE[pk];
    var INTS = { aside: 1, must: 1, freepass: 1, flip1: 1, nowm: 1, nothorn: 1, redraw: 1, onebar: 1, aimtot: 1, keepmine: 1, aimhit: 1, useroot: 1, kinds: 1, blankrand: 1, blankrand: 1, order: 1, spawn: 1, abil: 1, style: 1, cset: 1, envopen: 1, tagfx: 1, paltgt: 1, w: 1, h: 1, ground: 1, nsun: 1, nbr: 1, nmud: 1, events: 1, nev: 1, limit: 1, aim: 1, edges: 1, flip: 1, life: 1, tags: 1, env: 1, envn: 1 };
    over = over || {};
    for (var k in over) if (has(cfg, k) && isNumeric(over[k])) cfg[k] = INTS[k] ? toInt(over[k]) : Number(over[k]);
    if (over.foe_x !== undefined && over.foe_x !== null) cfg.foe = round(cfg.foe * Number(over.foe_x), 4);
    if (over.bar_x !== undefined && over.bar_x !== null) cfg.bar = round(cfg.bar * Number(over.bar_x), 4);
    level = toInt(level || 0);
    cfg.lvx = level > 0 ? v1Lvx(Array.isArray(over.lv) ? over.lv : PFB_V1_LEVEL[size], level) : 1.0;   // the level curve: piece values x f, bar x min(1, f)
    cfg.foe = round(cfg.foe * cfg.lvx, 4); cfg.bar = round(cfg.bar * Math.min(1.0, cfg.lvx), 4);
    if (over.ease === undefined || over.ease === null || Number(over.ease)) cfg.bar = round(cfg.bar * barEase(size, level), 4);   // 2.7.01: the medium low-level bar ease (PFB_V1_BAR_EASE_MEDIUM)
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
  function envDeck(size, region, nowm, nothorn) {
    if (!has(PFB_SIZE, size)) size = 'medium';
    var T = envTable(), bias = (region && has(T.regions, region)) ? T.regions[region] : {}, deck = [];
    for (var key in T.pieces) {
      var p = T.pieces[key];
      if (nothorn && p.env === 'thorn') continue;
      if (nowm && (p.env === 'wind' || p.env === 'mud')) continue;
      var n = Math.max(0, toInt(p.w[size]) + toInt(nn(bias[p.env], 0)));
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
    var base = (s.v1 && truthy(s.v1.life)) ? toInt(nn(p.tile.life, PFB_LIFE)) : PFB_LIFE;
    return base + (v1r(s, 'tagfx') === 1 && p.by === 'me' && nn(p.tile.m, '') === 'sticky' ? 1 : 0);
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
    var dropped = null;
    while (have.length > cap) { dropped = have.shift(); delete s.ter[dropped]; }
    return dropped;   // 2.7.05: the cell whose oldest patch faded (the replay event carries it as drop)
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
        var gone = groundSet(s, e.x, e.y, KIND_GROUND[e.kind]); if (gone !== null) L.drop = gone;
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
      ['dir', 'moved', 'on', 'ids', 'id', 'kind', 'full', 'drop'].forEach(function (k) { if (L[k] !== undefined && L[k] !== null) e[k] = clone(L[k]); });
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
    if (!v1r(s, 'flip1')) return true;   // 2.6.95: no limit, any piece with edges, any number of times
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
    if (!v1r(s, 'flip1')) { /* 2.6.95: unlimited, nothing to remember */ }
    else if (toInt(nn(t.ft, 0)) === toInt(s.turn)) { delete t.ft; s.me.flipt = 0; }
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
    if (isEmpty(s.pcs) || (who === 'me' && !v1r(s, 'must'))) return false;   // 2.6.95: v1 'must' 0 = the player may put a piece on any cell where it fits
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

  // next release (Josh's vote): the order a chain's pieces take effect in: environment, defence (guard, soothe), augments (trick), hurt / charm, healing. Same rank keeps the link order; fights from before keep the link order.
  function rank(p, tagfx) {
    if (p.by === 'env') return 1;
    if (tagfx && p.by === 'me') { var tg0 = nn(p.tile.tag, ''); if (tg0 === 'quick') return 0; if (tg0 === 'heavy') return 6; }
    var t = nn(p.tile.t, '');
    return t === 'guard' || t === 'soothe' ? 2 : t === 'trick' ? 3 : (t === 'heal' || t === 'item') ? 5 : 4;
  }
  function fireOrder(s, root) {
    var ch = chain(s, root);
    if (v1r(s, 'order') !== 1) return ch;
    var idx = ch.map(function (c, i) { return i; });
    var tfx = v1r(s, 'tagfx') === 1;
    idx.sort(function (a, b) { var ra = rank(s.pcs[ch[a][0]], tfx), rb = rank(s.pcs[ch[b][0]], tfx); return ra !== rb ? ra - rb : a - b; });
    return idx.map(function (i) { return ch[i]; });
  }

  /** 2.7.06 (Josh) set combos: the partner anywhere in the same chain (own side); same type (Double Swing): the partner must fire before. Best resulting value wins (ties: table order). [value, key|null] */
  function setCombo(s, ch, ci, who, tile) {
    var v = Number(tile.v), best = null, bk = null;
    Object.keys(PF_COMBOS).forEach(function (key) {
      var ab = key.split('>'), a = ab[0], b = ab[1];
      if (b !== tile.t) return;
      var pv = null;
      for (var cj = 0; cj < ch.length; cj++) {
        var q = s.pcs[ch[cj][0]];
        if (!q || q.by !== who || nn(q.tile.t, '') !== a) continue;
        if (a === b && cj >= ci) continue;
        pv = Math.max(pv === null ? 0 : pv, toInt(q.tile.v));
      }
      if (pv === null) return;
      var cb = PF_COMBOS[key], r = v * cb.mul / 100 + (cb.flat === 'prev' ? pv : toInt(cb.flat));
      if (best === null || r > best + 1e-9) { best = r; bk = key; }
    });
    return [iround(best === null ? v : best), bk];
  }

  function fire(s, root) {
    var ev = [], ch = fireOrder(s, root);
    var v1 = nn(s.v1, null), rb = s.pcs[root].by, tw = 1.0;
    if (v1) {   // v1: what fired (for use-up) and Teamwork
      s.fired = []; s.firedby = rb; s.firedroot = root; var srcs = {};
      ch.forEach(function (c) { var cp = s.pcs[c[0]]; if (cp.by === rb && PFB_TEAM_SRC.indexOf(nn(cp.tile.src, '')) >= 0) srcs[cp.tile.src] = 1; });
      var ns = Object.keys(srcs).length;
      if (rb === 'me' && ns >= 3) tw = Number(v1.team3); else if (rb === 'me' && ns === 2) tw = Number(v1.team2);
    }
    var cset = !!(v1 && v1r(s, 'cset') === 1);
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
      if (cset) { var sc = setCombo(s, ch, i, who, tile); vv = [sc[0]]; ck = sc[1]; }   // 2.7.06 set combos
      var val = iround(vv[0] * Number(nn(p.cm, 1.0)));
      if (who === 'foe' && tile.t === 'hurt' && toInt(nn(s.foe.grudge, 0)) > 0 && kindNow(s) === 'beast') val = iround(val * (1 + Number(abp(s, 'gpct', PFB_KIND_GRUDGE)) * toInt(s.foe.grudge)));   // 2.6.98 Grudge
      if (who === 'foe' && tile.t === 'hurt' && kindNow(s) === 'critter') { var others = 0; Object.keys(s.pcs).forEach(function (qk) { var q = s.pcs[qk]; if (q.by === 'foe' && toInt(q.id) !== toInt(id)) others++; }); val += Math.min(toInt(abp(s, 'smax', PFB_KIND_SWARM_MAX)), Math.floor(others / 2)) * PFB_KIND_SWARM_ADD; }   // 2.6.988 Swarm grows
      var ambp = false, ambd = false;
      if (who === 'foe' && tile.t === 'hurt' && hasAb(s)) {   // 2.7.01 Enrage and Ambush
        var en = abOf(s, 'enrage'); if (truthy(s.foe.enr) && en) val = iround(val * Number(en.mult));
        var am = abOf(s, 'ambush'); if (truthy(s.foe.amb) && truthy(s.infoe) && am) { val = iround(val * Number(am.mult)); s.foe.amb = 0; ambd = true; ambp = truthy(am.pierce); }
      }
      var sunny = !!v1 && (tile.t === 'hurt' || tile.t === 'charm') && ter(s, p.x, p.y) === 'sun';
      if (sunny) val = iround(val * Number(v1.sun));
      if (esun > 1 && who === rb) { val = iround(val * esun); sunny = true; }
      var muddy = !!v1 && truthy(v1.env) && Number(nn(v1.mud, 0)) > 0 && mudNear(s, p.x, p.y);   // Mud's teeth
      if (muddy) val = iround(val * (1 - Number(v1.mud)));
      if (tw > 1 && who === rb) val = iround(val * tw);
      var toughed = false;
      if (who === 'me' && rb === 'me' && tile.t === 'hurt' && !truthy(s.me.tough) && hasAb(s)) { var th = abOf(s, 'toughhide'); if (th) { val = Math.max(1, val - toInt(th.cut)); s.me.tough = 1; toughed = true; } }   // 2.7.01 Tough hide
      if (v1) s.fired.push(id);
      var isRoot = id === root;
      var e = { by: who, id: id, root: isRoot, tag: tile.tag, mod: String(nn(tile.m, '')), k: tile.k, n: tile.n, t: tile.t, v: val, fit: false, combo: ck ? PF_COMBOS[ck].name : null };
      if (sunny) e.sun = 1;
      if (muddy) e.mud = 1;
      if (tw > 1 && who === rb) e.tw = tw;
      if (ambd) e.amb = 1;
      if (ambp) e.ambp = 1;
      if (toughed) e.tough = 1;
      apply(s, who, tile, val, isRoot && links(s, id).length !== 0, ck, pt ? pt.tile : null, pt ? pt.by : null, e, isRoot, false);
      s.pcs[id].f = toInt(nn(s.pcs[id].f, 0)) + 1;   // fire budget: one more firing used
      e.barnow = round(Number(s.bar.now), 1); e.fhnow = round(Number(s.fh.now), 1); e.hpnow = toInt(s.me.hp); e.gnow = toInt(s.me.block);
      ev.push(e);
      if (truthy(e.drained)) ev.push(abNote(s, 'drain', String(e.drained)));   // 2.7.01 notices
      if (truthy(e.staggered)) ev.push(abNote(s, 'stagger', ''));
      checkEnd(s);
    }
    return ev;
  }

  function fireLimit(p, tagfx) { if (tagfx && p.by === 'me' && nn(p.tile.tag, '') === 'heavy') return 1; return p.by === 'foe' ? Math.max(0, PFB_FOE_FIRES) : 0; }
  function goneEntry(s, p, fell) {
    var e = { id: p.id, by: p.by, x: p.x, y: p.y, tile: p.tile, age: s.round - 1 - p.born };
    if (fell) e.fell = true;
    if (p.used !== undefined && p.used !== null) e.used = p.used;
    if (s.v1 && p.by === 'foe' && (s.lastfoe || []).indexOf(p.id) >= 0) e.fnew = true;   // 2.6.986 (v1 fights only: a flag-off page stays as it was)
    return e;
  }
  // Fire budget: after a chain has finished, creature pieces that have fired their limit fall away (to their discard); never mid-chain.
  function spend(s) {
    var fired = nn(s.fired, []), by = nn(s.firedby, 'me'), froot = has(s, 'firedroot') ? s.firedroot : null, used = []; delete s.fired; delete s.firedby; delete s.firedroot;
    if (s.over) return used;
    var lim3 = s.v1 ? toInt(nn(s.v1.limit, 0)) : 0;
    if (lim3 > 0 && fired.length >= lim3) {   // v1 USE-UP: a chain of 3 or more uses up every piece that fired
      var keepMine = v1r(s, 'keepmine') === 1, onlyRoot = v1r(s, 'useroot') === 1;   // 2.6.98
      fired.forEach(function (fid) {
        if (!has(s.pcs, fid)) return; var q = s.pcs[fid];
        if (keepMine && q.by === 'me') return;
        if (onlyRoot && froot !== null && fid !== froot) return;
        discardPiece(s, q); q.used = by;
        if (!Array.isArray(s.spent)) s.spent = [];
        s.spent.push(q); used.push(fid); venom(s, q);
        delete s.cell[q.x + ',' + q.y]; delete s.pcs[fid];
      });
    }
    var ids = Object.keys(s.pcs);
    for (var i = 0; i < ids.length; i++) {
      var p = s.pcs[ids[i]], lim = fireLimit(p, v1r(s, 'tagfx') === 1);
      if (lim > 0 && toInt(nn(p.f, 0)) >= lim) {
        discardPiece(s, p);
        if (!Array.isArray(s.spent)) s.spent = [];
        s.spent.push(p); venom(s, p);
        delete s.cell[p.x + ',' + p.y]; delete s.pcs[ids[i]];
      }
    }
    return used;
  }

  function begin(s, who) {
    if (who === 'me') { if (hasAb(s)) s.me.tough = 0; return; }   // 2.7.01 Tough hide
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
    if (ev.length) { ev[0].linked = joints; ev[0].snap = snap(s); ev[0].cs = 1; ev[0].rid = id; }
    var used = spend(s);
    if (used.length && ev.length) ev[0].used = used;
    if (ev.length && who === 'me' && !truthy(s.over) && v1r(s, 'paltgt') === 1 && srcOf(tile) === 'pal') { var tid = palTarget(s, x, y); if (tid !== null) ev.push(palNip(s, tid, String(tile.n))); }   // 2.7.08 pal targeting
    if (ev.length && who === 'me' && s.ven && has(s.ven, x + ',' + y) && kindNow(s) === 'reptile' && truthy(s.v1.tags)) {   // 2.6.98 Venom trail
      var vr = toInt(abp(s, 'vrnds', PFB_KIND_VENOM_RNDS)), vp = toInt(abp(s, 'vpoison', PFB_KIND_VENOM_POISON));
      s.me.poison = Math.min(PF_POISON_CAP, toInt(s.me.poison) + vr); s.me.poison_v = Math.max(toInt(s.me.poison_v), vp);
      var vn = note('venom', String(tile.n)); vn.by = 'me'; if (vr !== PFB_KIND_VENOM_RNDS || vp !== PFB_KIND_VENOM_POISON) { vn.pr = vr; vn.pv = vp; } ev.push(vn);
    }
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
    if (ev.length) { ev[0].linked = checkAfter(s, root); ev[0].snap = snap(s); ev[0].cs = 1; ev[0].rid = root; }
    var used = spend(s);
    if (used.length && ev.length) ev[0].used = used;
    return ev;
  }

  function expire(s) {
    var gone = [], ids = Object.keys(s.pcs);
    for (var i = 0; i < ids.length; i++) {
      var p = s.pcs[ids[i]];
      if (p.born <= s.round - lifeOf(s, p) + 1) {
        discardPiece(s, p); venom(s, p);
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

  // ------------------------------------------------------------------ 2.7.01 creature AI (PFB_AI, pfb_ai_make, pfb_feat, pfb_ai_score, pfb_why in pfboard.php; SPEC sec 3)
  var PFB_AI_KEYS = ['dmg', 'bar', 'heal', 'guard', 'strip', 'setup', 'tempo', 'control', 'deny', 'force', 'early', 'late'];
  var PFB_AI = {
    balanced: [1.0, -0.8, 0.0, 0.4, 0.3, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0, 1.0, 'Balanced', 'Plays the best trade each turn'],
    crowd: [0.8, -0.6, 0.0, 0.2, 0.2, 0.6, 0.8, 1.2, 1.0, 0.8, 1.0, 1.0, 'Crowd', 'Fills the board and shrinks your cells'],
    blocker: [0.6, -0.8, 0.0, 1.0, 0.6, 0.8, 0.6, 0.3, 1.2, 0.2, 1.0, 1.0, 'Blocker', 'Sits where you want to play and strips your guard'],
    burst: [1.5, -0.5, 0.0, 0.1, 0.1, 0.3, 0.5, 0.0, 0.0, 1.0, 1.6, 0.8, 'Burst', 'Biggest hit now, and pushes you into its pieces'],
    stall: [0.5, -1.0, 0.3, 0.8, 0.5, 1.0, 2.0, 0.2, 0.6, 0.0, 0.6, 1.0, 'Stall', 'Delays you: a short draw, an extra piece, guard'],
    healer: [0.7, -1.0, 1.2, 0.5, 0.3, 0.6, 0.6, 0.0, 0.0, 0.0, 1.0, 1.0, 'Healer', 'Prefers to recover and trades slowly'],
    trickster: [0.8, -0.8, 0.0, 0.3, 0.3, 1.8, 1.8, 0.2, 0.4, 0.2, 1.0, 1.0, 'Trickster', 'Trips, dodges and bashes before it hurts'],
    poisoner: [0.9, -0.8, 0.0, 0.3, 0.2, 2.0, 1.0, 0.3, 0.0, 0.3, 1.0, 1.0, 'Poisoner', 'Poison and long set-ups first'],
    guardian: [0.5, -0.9, 0.4, 1.5, 0.8, 0.8, 0.5, 0.1, 0.6, 0.0, 1.0, 1.0, 'Guardian', 'Big guard, Thorns and Hold, slow trades'],
    ambusher: [0.9, -0.7, 0.0, 0.2, 0.1, 0.8, 0.6, 0.4, 0.2, 1.2, 0.4, 1.6, 'Ambusher', 'Quiet first turns, then hits hard']
  };
  function aiMake(id, o) {
    if (!has(PFB_AI, id)) return null;
    var w = { id: id }; PFB_AI_KEYS.forEach(function (k, i) { w[k] = Number(PFB_AI[id][i]); });
    var n = 0; o = o || {};
    for (var k in o) { if (n >= 2) break; if (PFB_AI_KEYS.indexOf(k) < 0 || !isNumeric(o[k])) continue; w[k] = Math.max(-2.5, Math.min(2.5, Number(o[k]))); n++; }
    return (id === 'balanced' && n === 0) ? null : w;
  }
  function myMoves(s) {
    var o = [], must = mustLink(s, 'me');
    s.me.hand.forEach(function (t, i) { for (var y = 0; y < pfbH(s); y++) for (var x = 0; x < pfbW(s); x++) { var j = check(s, t, x, y); if (j !== null && (!must || hasLink(j))) o.push([i, x, y, j]); } });
    return o;
  }
  function reach(s) { var c = {}; myMoves(s).forEach(function (m) { c[m[1] + ',' + m[2]] = 1; }); return Object.keys(c).length; }
  function foeCount4(z) { var n = 0; for (var id in z.pcs) if (z.pcs[id].by === 'foe') n++; return Math.min(4, n); }
  function feat(b, a, ctx) {
    var w = nn(ctx.w, null), barD = (a.bar.now - b.bar.now) + (a.fh.now - b.fh.now);
    var u = 0.05 * a.me.max, setup = 0.0, tempo = 0.0, dPz = 0, dEv = 0, dTh = 0, dBa = 0, dSl = 0, dAg = 0;
    var I = function (x) { return x === true ? 1 : toInt(nn(x, 0)); };
    if (a.v1 && truthy(a.v1.tags)) {
      var pz = function (z) { return toInt(nn(z.me.poison, 0)) * toInt(nn(z.me.poison_v, 0)); };
      dPz = pz(a) - pz(b); dEv = I(a.foe.evade) - I(b.foe.evade); dTh = I(a.foe.thorns) - I(b.foe.thorns);
      dBa = I(a.foe.bashnext) - I(b.foe.bashnext); dSl = I(a.me.slowdraw) - I(b.me.slowdraw); dAg = I(a.foe.again) - I(b.foe.again);
      setup = dPz + u * (1.5 * dEv + 0.6 * dTh + dBa * Math.max(1.0, Number(nn(a.foe.block, 0)) / Math.max(1.0, u))); tempo = u * (1.0 * dSl + 1.5 * dAg);
    }
    var deny = 0.0, force = 0.0, dReach = 0;
    if (w !== null && nn(w.deny, 0) != 0) { if (ctx.rb === undefined) ctx.rb = reach(b); dReach = ctx.rb - reach(a); deny = 0.1 * a.me.max * dReach / Math.max(1, ctx.rb); }
    if (w !== null && nn(w.force, 0) != 0) {
      var mv = myMoves(a), k = 0;
      mv.forEach(function (m) { for (var q = 0; q < m[3].length; q++) { var j = m[3][q], pc = a.pcs[j[1]]; if (j[2] && pc && pc.by === 'foe' && pc.tile.t === 'hurt') { k++; break; } } });
      force = 0.1 * a.me.max * k / Math.max(1, mv.length);
    }
    return { dmg: b.me.hp - a.me.hp, bar: barD, heal: Math.max(0.0, -barD), guard: a.foe.block - b.foe.block, strip: -(a.me.block - b.me.block), setup: setup, tempo: tempo,
      control: u * (foeCount4(a) - foeCount4(b)), deny: deny, force: force, x_pz: dPz, x_ev: dEv, x_th: dTh, x_ba: dBa, x_sl: dSl, x_ag: dAg, x_reach: dReach, x_n: foeCount4(a) };
  }
  function aiScore(b, a, w, ctx) {
    ctx.w = w; var f = feat(b, a, ctx), ramp = toInt(b.round) <= 2 ? w.early : w.late;
    return w.dmg * ramp * f.dmg + w.bar * f.bar + w.heal * f.heal + w.guard * f.guard + w.strip * f.strip + w.setup * f.setup + w.tempo * f.tempo
      + w.control * f.control + w.deny * f.deny + w.force * f.force + (a.over === 'defeat' ? 50 : 0);
  }
  function foeBase(s) {
    if (!s.foe.ai) return s;
    s = clone(s); begin(s, 'foe');
    if (hasAb(s)) abTurn(s, []);
    return s;
  }
  function why(s, m) {
    var name = has(PFB_AI, String(nn(s.foe.aid, 'balanced'))) ? PFB_AI[String(nn(s.foe.aid, 'balanced'))][12] : 'Balanced', w = nn(s.foe.ai, null);
    if (!w) { w = { id: 'balanced' }; PFB_AI_KEYS.forEach(function (k, i) { w[k] = Number(PFB_AI.balanced[i]); }); }
    var b = foeBase(s), a = clone(b); if (hasAb(b)) a.infoe = 1;
    if (place(a, 'foe', toInt(m[0]), toInt(m[1]), toInt(m[2])) === null) return name + ': no move';
    if (a.over === 'defeat') return name + ': finishes you';
    var ctx = { w: w }, f = feat(b, a, ctx), ramp = toInt(b.round) <= 2 ? w.early : w.late, c = {}, ck = [];
    ['dmg', 'heal', 'guard', 'strip', 'setup', 'tempo', 'control', 'deny', 'force'].forEach(function (k) { var v = w[k] * f[k] * (k === 'dmg' ? ramp : 1.0); if (v > 1e-9) { c[k] = v; ck.push(k); } });
    var tx = {
      dmg: 'hits you for ' + iround(f.dmg), heal: 'recovers ' + iround(f.heal), guard: 'builds ' + iround(f.guard) + ' guard', strip: 'strips ' + iround(f.strip) + ' of your guard',
      setup: f.x_pz > 0 ? 'poisons you' : (f.x_ev > 0 ? 'readies a dodge' : (f.x_th > 0 ? 'raises thorns' : (f.x_ba > 0 ? 'lends its guard to a bash' : 'sets up a lasting effect'))),
      tempo: f.x_sl > 0 ? 'leaves you a piece short' : 'plays again', control: 'takes ground, ' + toInt(f.x_n) + ' out', deny: 'fills ' + toInt(f.x_reach) + ' of your cells', force: 'pushes you into its Hurt pieces' };
    if (!ck.length) return name + ': ' + (f.bar > 0.05 ? 'the safest play, it gives ' + iround(f.bar) : 'the safest play');
    var k1 = null, k2 = null;
    ck.forEach(function (k) { if (k1 === null || c[k] > c[k1]) k1 = k; });
    ck.forEach(function (k) { if (k !== k1 && (k2 === null || c[k] > c[k2])) k2 = k; });
    return name + ': ' + tx[k1] + (k2 !== null && c[k2] >= 0.5 * c[k1] ? ', ' + tx[k2] : '');
  }

  function score(b, a, who, ctx) {
    if (who === 'foe' && a.foe.ai) { if (ctx === undefined || ctx === null) ctx = {}; return aiScore(b, a, a.foe.ai, ctx); }   // 2.7.01: a creature with a play style
    var barD = (a.bar.now - b.bar.now) + (a.fh.now - b.fh.now), hpD = a.me.hp - b.me.hp;
    var tg = 0.0;
    if (a.v1 && truthy(a.v1.tags)) {
      var u = 0.05 * a.me.max, pz = function (z) { return toInt(nn(z.me.poison, 0)) * toInt(nn(z.me.poison_v, 0)); }, I = function (x) { return x === true ? 1 : toInt(nn(x, 0)); };
      tg = (pz(a) - pz(b)) + u * (1.0 * (I(a.me.slowdraw) - I(b.me.slowdraw)) + 1.5 * (I(a.foe.evade) - I(b.foe.evade)) + 0.6 * (I(a.foe.thorns) - I(b.foe.thorns))
        + (I(a.foe.bashnext) - I(b.foe.bashnext)) * Math.max(1.0, Number(nn(a.foe.block, 0)) / Math.max(1.0, u)) + 1.5 * (I(a.foe.again) - I(b.foe.again)));
    }
    if (who === 'me') return -0.7 * tg + barD + 0.7 * hpD + 0.3 * (a.me.block - b.me.block) - 0.3 * (a.foe.block - b.foe.block) + (truthy(a.over) && (a.over === 'seen_off' || a.over === 'charmed') ? 50 : 0);
    return tg - 0.8 * barD - hpD + 0.4 * (a.foe.block - b.foe.block) - 0.3 * (a.me.block - b.me.block) + (a.over === 'defeat' ? 50 : 0);
  }

  /** The best single placement for who: [handIdx, x, y, score] or null. */
  function search(s, who, allowHeavy, onlyK, avoid) {
    if (allowHeavy === undefined) allowHeavy = true;
    if (onlyK === undefined) onlyK = null; if (avoid === undefined) avoid = null;
    var best = null, ctx = {}, infoe = false;
    if (who === 'foe') { s = foeBase(s); infoe = hasAb(s); }   // 2.7.01: with a play style it searches the turn it will play; Ambush is live in its first turn
    var hand = s[who].hand;
    for (var i = 0; i < hand.length; i++) {
      var tile = hand[i];
      if (!allowHeavy && tile.tag === 'heavy' && nn(tile.m, '') !== 'steady') continue;
      if (onlyK !== null && tile.k !== onlyK) continue;
      var cs = cells(s, tile, who);
      for (var c = 0; c < cs.length; c++) {
        var x = cs[c][0], y = cs[c][1];
        if (avoid !== null && x === avoid[0] && y === avoid[1]) continue;
        var w = clone(s); if (infoe) w.infoe = 1;
        if (place(w, who, i, x, y) === null) continue;
        delete w.infoe;
        var sc = score(s, w, who, ctx);
        if (s.v1 && has(w.cell, x + ',' + y)) {   // v1: bramble under a piece that stays out, and what the announced events will do to it
          if (ter(s, x, y) === 'br') sc -= 2 * Number(s.v1.bramble) * (who === 'foe' ? Number(s.v1.br_foe) * 0.8 * s.fh.max : 0.7 * s.me.max);
          sc += envBias(s, who, x, y, tile);
        }
        if (best === null || sc > best[3] + 1e-9) best = [i, x, y, sc];
      }
    }
    return best;
  }

  /** 2.6.989: the creature recovers val. One shared bar: the Yield bar goes down, the Hurt part first, then the Charm part; two bars: only the health bar. */
  function foeHeal(s, val) {   // returns what it actually took back (never more than the bar held)
    if (!(s.v1 && truthy(s.v1.onebar))) { var d0 = Math.min(Number(s.fh.now), val); s.fh.now = Math.max(0.0, s.fh.now - val); return Math.max(0.0, d0); }
    var d = Math.min(Number(s.fh.now), val); s.fh.now -= d; var rest = val - d, c = 0.0;
    if (rest > 0) { c = Math.min(Number(s.bar.now), rest); s.bar.now -= c; s.bar.charm = Math.max(0.0, Number(s.bar.charm) - c); }
    return Math.max(0.0, d + c);
  }
  function foeLen(s) { return Math.max(0, Math.min(s.foe.hand.length, 1 - toInt(s.foe.slow))); }

  function guardNotes(s, ev) {   // 2.6.77 (pfb_guard_notes)
    if (!s.v1 || s.over) return;
    var ta = ev.length ? String(nn(ev[ev.length - 1].ta, 'foe')) : 'foe';
    [['fade', toInt(nn(s.me.faded, 0))], ['hold', toInt(nn(s.me.kept, 0))], ['simmer', toInt(nn(s.me.simmer, 0))]].forEach(function (q) {
      if (q[1] <= 0) return;
      var e = note(q[0], String(q[1])); e.by = 'me'; e.ta = ta; e.barnow = round(Number(s.bar.now), 1); e.fhnow = round(Number(s.fh.now), 1); e.hpnow = toInt(s.me.hp); e.gnow = toInt(s.me.block); ev.push(e);
    });
  }
  function note(kind, n) { return { by: 'foe', note: kind, k: 'note', n: n === undefined ? '' : n, t: 'note', tag: '', v: 0, fit: false, combo: null }; }   // 2.6.76: a notice event (pfb_note)

  /** 2.7.08 pal targeting (pfb_pal_target): the creature's strongest piece out, ties by fewest steps from (x, y), then the oldest; null when it has none. */
  function palTarget(s, x, y) {
    var best = null, bv = 0, bd = 0;
    for (var k in s.pcs) {
      var p = s.pcs[k]; if (p.by !== 'foe') continue;
      var id = toInt(p.id), v = toInt(p.tile.v), d = Math.abs(toInt(p.x) - x) + Math.abs(toInt(p.y) - y);
      if (best === null || v > bv || (v === bv && (d < bd || (d === bd && id < best)))) { best = id; bv = v; bd = d; }
    }
    return best;
  }
  /** pfb_pal_nip: the target leaves the board (used by you) and the notice. */
  function palNip(s, tid, pal) {
    var p = s.pcs[tid];
    discardPiece(s, p); p.used = 'me'; if (!Array.isArray(s.spent)) s.spent = []; s.spent.push(p); venom(s, p);
    delete s.cell[p.x + ',' + p.y]; delete s.pcs[tid];
    var e = note('palaim', String(p.tile.n)); e.by = 'me'; e.tid = tid; e.x = toInt(p.x); e.y = toInt(p.y); e.pal = pal; e.tv = toInt(p.tile.v);
    return e;
  }
  function strike(s, hi, cid) {   // 2.6.98 (aimhit): its Hurt piece strikes YOUR piece; a Guard at least as strong holds, anything else breaks; you take nothing
    var ft = s.foe.hand[hi]; s.foe.hand.splice(hi, 1); s.foe.discard.push(ft); s.nospawn = 1;
    var p = s.pcs[cid], hit = toInt(ft.v), g = p.tile.t === 'guard' ? toInt(p.tile.v) : 0, broke = g < hit;
    if (broke) { discardPiece(s, p); p.used = 'foe'; if (!Array.isArray(s.spent)) s.spent = []; s.spent.push(p); delete s.cell[p.x + ',' + p.y]; delete s.pcs[cid]; }
    return { by: 'foe', strike: true, id: cid, broke: broke, guard: g, x: toInt(p.x), y: toInt(p.y), k: ft.k, n: ft.n, t: 'hurt', tag: '', v: hit, hit: hit, mine: String(nn(p.tile.n, '')), fit: false, combo: null };
  }
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
    if (hasAb(s)) { abTurn(s, ev); s.infoe = 1; }   // 2.7.01: its turn count, Regrow, Plated; Ambush is live for this turn
    if (s.v1 && truthy(s.v1.tags) && toInt(s.foe.slow) > 0 && s.foe.hand.length) ev.push(note('slow'));
    var n = foeLen(s), again = false, hp0 = toInt(s.me.hp), kind = kindNow(s); s.lastfoe = [];
    if (s.v1 && truthy(s.v1.tags)) s.foe.again = 0;
    if (s.v1) s.reaim = 0;
    for (var k = 0; k < n && !s.over; k++) {
      var r = null, plan = (s.v1 && truthy(s.v1.aim) && k === 0) ? nn(s.foe.plan, null) : null;
      if (plan && plan.t === 'hurt' && v1r(s, 'aimhit') === 1) {   // 2.6.98 AIMHIT: your piece on its aimed cell is struck instead of it picking again
        var cid = nn(s.cell[plan.x + ',' + plan.y], null);
        if (cid !== null && s.pcs[cid].by === 'me') {
          for (var sh = 0; sh < s.foe.hand.length; sh++) if (s.foe.hand[sh].k === plan.k) { ev.push(strike(s, sh, cid)); r = []; if (kind === 'beast') s.foe.grudge = Math.min(toInt(abp(s, 'gmax', PFB_KIND_GRUDGE_MAX)), toInt(nn(s.foe.grudge, 0)) + 1); break; }
          if (r !== null) continue;
        }
      }
      if (plan && has(s.cell, plan.x + ',' + plan.y) && s.cell[plan.x + ',' + plan.y] !== null) {   // its cell is taken
        if (kind === 'bird' && plan.alt && !(has(s.cell, plan.alt.x + ',' + plan.alt.y) && s.cell[plan.alt.x + ',' + plan.alt.y] !== null)) plan = plan.alt;   // 2.6.98 Two aims
        else if (kind === 'beast') s.foe.grudge = Math.min(toInt(abp(s, 'gmax', PFB_KIND_GRUDGE_MAX)), toInt(nn(s.foe.grudge, 0)) + 1);   // Grudge
      }
      var whyS = '';
      if (plan) for (var hi = 0; hi < s.foe.hand.length; hi++) if (s.foe.hand[hi].k === plan.k) { s.aimforce = true; r = place(s, 'foe', hi, plan.x, plan.y); delete s.aimforce; whyS = String(nn(plan.why, '')); break; }   // v1 AIM
      if (r === null) {   // no fumble: it picks again at full value
        if (plan) s.reaim = 1;
        var m = search(s, 'foe');
        if (m === null) break;
        if (v1r(s, 'style') === 1) { whyS = why(s, m); if (plan) whyS = whyS.replace(/^([^:]+): /, '$1: re-aim, '); }   // 2.7.01: the reason of the move it picks
        r = place(s, 'foe', m[0], m[1], m[2]);
      }
      if (r && r.length && whyS !== '') r[0].why = whyS;
      if (r) { ev = ev.concat(r); s.lastfoe.push(s.pid); if (kind === 'water') current(s, s.pid, ev); }
      if (truthy(s.foe.again)) { if (!again) { again = true; n++; if (s.v1 && truthy(s.v1.tags) && r && r.length) ev.push(note('quick', String(r[0].rid && s.pcs[r[0].rid] ? s.pcs[r[0].rid].tile.n : nn(r[0].n, '')))); } s.foe.again = 0; }   // a Quick piece: one more piece this turn (once)
    }
    if (kind === 'beast' && toInt(s.me.hp) < hp0) s.foe.grudge = 0;   // Grudge: a hit that lands clears it
    if (kind === 'plant' && !truthy(s.over)) grow(s, ev);
    s.foe.agg = 0; s.foe.slow = 0;
    if (hasAb(s)) { delete s.infoe; s.foe.amb = 0; }   // 2.7.01: Ambush is for its first turn only
    return ev;
  }

  /** 2.6.98 Water "Current" (pfb_current). */
  function current(s, id, ev) {
    var p = has(s.pcs, id) ? s.pcs[id] : null; if (!p || truthy(s.over)) return;
    var sides = Object.keys(PFB_SIDE);
    for (var i = 0; i < sides.length; i++) {
      var dx = PFB_SIDE[sides[i]][0], dy = PFB_SIDE[sides[i]][1], q = pieceAt(s, p.x + dx, p.y + dy);
      if (!q || q.by !== 'me') continue;
      var nx = q.x + dx, ny = q.y + dy;
      if (nx < 0 || ny < 0 || nx >= pfbW(s) || ny >= pfbH(s) || has(s.cell, nx + ',' + ny)) continue;
      if (toInt(abp(s, 'slide', 1)) >= 2) { var x2 = nx + dx, y2 = ny + dy; if (x2 >= 0 && y2 >= 0 && x2 < pfbW(s) && y2 < pfbH(s) && !has(s.cell, x2 + ',' + y2)) { nx = x2; ny = y2; } }   // 2.7.01 Strong current
      var ox = toInt(q.x), oy = toInt(q.y);
      delete s.cell[q.x + ',' + q.y]; s.cell[nx + ',' + ny] = q.id; s.pcs[q.id].x = nx; s.pcs[q.id].y = ny;
      var e = note('current', String(q.tile.n)); e.moved = { id: q.id, by: 'me', n: q.tile.n, x: nx, y: ny, fx: ox, fy: oy }; ev.push(e);
      return;
    }
  }
  /** 2.6.98 Plant "Grows" (pfb_grow). */
  function grow(s, ev) {
    if (!truthy(s.v1.env)) return;
    var own = 0, ks = Object.keys(s.pcs); for (var i = 0; i < ks.length; i++) { var q = s.pcs[ks[i]]; if (q.by === 'env' && q.tile.own) own++; }
    if (own >= toInt(abp(s, 'gcap', 1))) return;   // 2.7.01 Twin growth
    var last = s.lastfoe.length ? s.lastfoe[s.lastfoe.length - 1] : null, p = last && has(s.pcs, last) ? s.pcs[last] : null; if (!p) return;
    var tile = null, deck = envDeck('boss'); for (var d = 0; d < deck.length; d++) if (deck[d].env === 'bramble') { tile = clone(deck[d]); break; } if (!tile) return;
    tile.ed = { L: ['wild', null], R: ['wild', null], T: ['wild', null], B: ['wild', null] }; tile.own = 1;
    var sides = Object.keys(PFB_SIDE);
    for (var k = 0; k < sides.length; k++) {
      var x = p.x + PFB_SIDE[sides[k]][0], y = p.y + PFB_SIDE[sides[k]][1];
      if (x < 0 || y < 0 || x >= pfbW(s) || y >= pfbH(s) || has(s.cell, x + ',' + y) || check(s, tile, x, y) === null) continue;
      var id = ++s.pid; s.seq++;
      s.pcs[id] = { id: id, by: 'env', tile: tile, x: x, y: y, born: s.round + 1, seq: s.seq };
      s.cell[x + ',' + y] = id;
      var e = note('grows', String(tile.n)); e.id = id; e.x = x; e.y = y; ev.push(e);
      return;
    }
  }

  function intent(s) {
    if (s.v1) forecast(s);
    var kind = kindNow(s), m = null;
    if (kind === 'boss' && s.foe.nextk) m = search(s, 'foe', true, String(s.foe.nextk));   // 2.6.98 Two turns
    s.foe.nextk = null;
    if (m === null) m = search(s, 'foe');
    s.foe.intent = m ? s.foe.hand[m[0]].t : null;
    if (s.v1 && truthy(s.v1.aim)) { var h = m ? s.foe.hand[m[0]] : null; s.foe.plan = h && foeLen(s) > 0 ? { k: h.k, n: h.n, t: h.t, v: h.v, tag: h.tag, x: m[1], y: m[2] } : null; if (s.foe.plan && v1r(s, 'style') === 1) s.foe.plan.why = why(s, m); }
    if (kind !== '' && s.foe.plan) {   // 2.6.98 class rules that add to the aim
      if (kind === 'bird') { var am = search(s, 'foe', true, null, [toInt(m[1]), toInt(m[2])]); if (am) { var ah = s.foe.hand[am[0]]; s.foe.plan.alt = { k: ah.k, n: ah.n, t: ah.t, v: ah.v, tag: ah.tag, x: am[1], y: am[2] }; if (v1r(s, 'style') === 1) s.foe.plan.alt.why = why(s, am); } }
      if (kind === 'boss') {
        var w2 = clone(s);
        if (place(w2, 'foe', m[0], toInt(m[1]), toInt(m[2])) !== null) { var nm = search(w2, 'foe'); if (nm) { var nh = w2.foe.hand[nm[0]]; s.foe.plan.next = { k: nh.k, n: nh.n, t: nh.t, v: nh.v, tag: nh.tag }; s.foe.nextk = nh.k; } }
      }
    }
    if (s.foe.plan && v1r(s, 'aimtot')) s.foe.plan.tot = aimTotal(s);   // 2.6.95: what its committed move would do now (one dry run; stored with the aim)
  }

  /** 2.6.95 (aim total): what the creature's committed move would do to you if it played now (pfb_aim_total): { hp, g, bait, heal, n, why, ids }, null (no aim) or { broken: 'cell' | 'edge' | 'slow' }. */
  function aimTotal(s) {
    var plan = nn(s.foe.plan, null);
    if (!plan || truthy(s.over)) return null;
    if (foeLen(s) < 1) return { broken: 'slow' };
    var x = toInt(plan.x), y = toInt(plan.y), usedAlt = false;
    if (has(s.cell, x + ',' + y) && s.cell[x + ',' + y] !== null) {
      var scid = s.cell[x + ',' + y], smp = has(s.pcs, scid) ? s.pcs[scid] : null;   // 2.6.98 (aimhit): your piece on its Hurt cell is struck: the aim says STRIKE, it is not broken
      if (v1r(s, 'aimhit') === 1 && plan.t === 'hurt' && smp && smp.by === 'me') {
        var sg = smp.tile.t === 'guard' ? toInt(smp.tile.v) : 0, shit = toInt(nn(plan.v, 0));
        return { hp: 0, g: 0, bait: 0, heal: 0, n: 1, why: [], ids: [], strike: { id: toInt(scid), n: String(nn(smp.tile.n, '')), broke: sg < shit, hit: shit, guard: sg } };
      }
      if (kindNow(s) === 'bird' && plan.alt && !(has(s.cell, plan.alt.x + ',' + plan.alt.y) && s.cell[plan.alt.x + ',' + plan.alt.y] !== null)) { plan = plan.alt; x = toInt(plan.x); y = toInt(plan.y); usedAlt = true; }   // 2.6.98 Two aims
      else return { broken: 'cell' };
    }
    var hi = -1; for (var i = 0; i < s.foe.hand.length; i++) if (s.foe.hand[i].k === plan.k) { hi = i; break; }
    if (hi < 0) return { broken: 'edge' };
    var w = clone(s); w.spent = []; w.lastfoe = []; w.gone = []; begin(w, 'foe'); if (hasAb(w)) abTurn(w, []);
    var hp0 = toInt(w.me.hp); w.aimforce = true; if (hasAb(w)) w.infoe = 1; var ev = place(w, 'foe', hi, x, y); delete w.aimforce; delete w.infoe;   // 2.7.01: Ambush shows in the number
    if (ev === null) return { broken: 'edge' };
    var g = 0, bait = 0, heal = 0, n = 0, sun = false, mud = false, combo = [], fires = [], quick = truthy(w.foe.again), ids = [];
    ev.forEach(function (e) {
      if (e.id === undefined || e.id === null) return;
      n++;
      if (!truthy(e.root)) { var q = { id: toInt(e.id), by: e.by === 'foe' ? 'foe' : (e.by === 'env' ? 'env' : 'me') };   // after 2.6.96: which pieces fire, in order
        if (q.by === 'env') { q.kind = String(nn(e.kind, '')); q.v = q.kind === 'sun' ? round(Number(s.v1.sun), 2) : (q.kind === 'rain' ? toInt(nn(e.guard, 0)) : (q.kind === 'bramble' ? toInt(e.me) : (q.kind === 'thorn' ? iround(Number(e.foe)) : 0))); }
        ids.push(q); }
      if (e.by === 'env') { if (e.kind !== 'sun') fires.push('fires ' + e.n); return; }
      if (e.by === 'foe') {
        if (e.t === 'hurt') g += toInt(nn(e.blocked, 0));
        if (e.t === 'heal' || (e.t === 'trick' && e.tag === 'heal')) heal += iround(Number(e.healed !== undefined ? e.healed : e.v));
        if (truthy(e.sun)) sun = true;
        if (truthy(e.mud)) mud = true;
        if (truthy(e.combo) && combo.indexOf(e.combo) < 0) combo.push(e.combo);
      } else { bait += Number(nn(e.fh, 0)); fires.push('fires your ' + e.n); }
    });
    var why = [];
    if (sun) why.push('Sun x' + String(Number(Number(s.v1.sun).toFixed(2))));
    combo.forEach(function (c) { why.push('combo ' + c); });
    fires.forEach(function (f) { why.push(f); });
    if (quick) why.push('Quick: plays again');
    if (mud) why.push('Mud -' + Math.round(100 * Number(nn(s.v1.mud, 0))) + '%');
    if (usedAlt) why.unshift('its second aim');
    var hpTot = hp0 - toInt(w.me.hp);
    if (quick) { var w3 = clone(s), h3 = toInt(w3.me.hp); foeTurn(w3); var more = h3 - toInt(w3.me.hp); if (more !== hpTot) { hpTot = more; why.push('Quick: its second piece is in the number'); } }   // 2.6.986
    return { hp: hpTot, g: g, bait: round(bait, 1), heal: heal, n: n, why: why, ids: ids };
  }

  // ------------------------------------------------------------------ the whole fight
  function newFight(me, c, seed, opt) {
    var s = pfNew(me, c, seed, opt);
    var v1 = (opt && truthy(opt.v1)) ? v1Cfg(s.size, v1Over(c, (typeof opt.v1 === 'object' && !Array.isArray(opt.v1)) ? opt.v1 : {}), Math.max(1, toInt(nn(c.level, 1)))) : null;
    ['hand', 'draw', 'discard'].forEach(function (z) { s.foe[z].forEach(function (t) { t.v = Math.max(1, iround(t.v * (v1 ? v1.foe : PFB_FOE_MULT) * (s.size === 'boss' ? PFB_BOSS_MULT : 1.0) * (truthy(opt && opt.blank) ? PFB_BLANK_FOE_MULT : 1.0) * (PFB_FOE_FIRES > 0 ? PFB_FOE_FIRE_MULT : 1.0))); }); });
    s.bar.max = round(s.bar.max * (v1 ? v1.bar : PFB_BAR_MULT), 1);
    if (v1 && truthy(v1.onebar)) { s.bar.max = round(s.bar.max * PFB_V1_ONEBAR_BAR, 1); if (s.cm <= 0 && s.boss) s.cm = PF_HOSTILE_CM; }   // 2.6.95 (one shared bar): 1.15 x as long; a boss takes Charm too (it still ends seen off)
    s.fh.max = s.bar.max;
    s.mode = 'board'; s.strip = []; s.pcs = {}; s.cell = {}; s.pid = 0; s.seq = 0; s.round = 1;
    if (v1) {
      s.w = v1.w; s.h = v1.h; delete v1.w; delete v1.h; s.v1 = v1;
      s.foe.kind = truthy(v1.kinds) ? kindOf(c, s.size) : ''; s.foe.grudge = 0; s.foe.nextk = null; s.ven = {};   // 2.6.98 class rules
      v1Tiles(s, c); seedGround(s); s.envs = []; s.envlog = []; s.reaim = 0; s.me.flipt = 0;
      if (v1.env) { s.env = { draw: shuffle(s, envDeck(s.size, String(nn(c.region, '')), !!v1r(s, 'nowm'), !!v1r(s, 'nothorn'))), discard: [], next: [] }; envDraw(s); if (v1r(s, 'envopen') === 1) { s.v1.envn++; envDraw(s); s.v1.envn--; } }   // 2.6.75: the environment's deck
      s.me.slowdraw = 0; s.me.tripped = 0;
      if (v1.tags) { s.me.poison = 0; s.me.poison_v = 0; s.foe.bashnext = 0; s.foe.again = 0; }
      if (Array.isArray(c.ab) && c.ab.length && v1r(s, 'abil') === 1) abInit(s, c);   // 2.7.01 abilities (an E id replaces the class rule)
      if (v1r(s, 'style') === 1 && truthy(c.ai) && has(PFB_AI, String(c.ai))) { s.foe.aid = String(c.ai); var aiw = aiMake(String(c.ai), nn(c.aip, {})); if (aiw) s.foe.ai = aiw; }   // 2.7.01 play style
    }
    if (opt && truthy(opt.blank)) {   // variant: a blank wild piece in the centre; both sides put a start piece next to it, hidden (see start)
      s.pid = 1; s.seq = 1; var cx = intdiv(pfbW(s), 2), cy = intdiv(pfbH(s), 2);
      if (v1r(s, 'blankrand') === 1) { var iw = Math.max(1, pfbW(s) - 2), ih = Math.max(1, pfbH(s) - 2), kk = rand(s, iw * ih); cx = 1 + kk % iw; cy = 1 + intdiv(kk, iw); }   // 2.6.98: the inert Blank starts on a random inner cell
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
    var cx = has(s.pcs, 1) ? toInt(s.pcs[1].x) : intdiv(pfbW(s), 2), cy = has(s.pcs, 1) ? toInt(s.pcs[1].y) : intdiv(pfbH(s), 2), sides = ['L', 'R', 'T', 'B'], fs = sides[rand(s, 4)];
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
        var pv = Math.max(1, toInt(s.me.poison_v)); if (toInt(s.me.evade) > 0 || truthy(s.me.evd)) pv = 0;   // 2.6.988: Evade stops the poison tick; 2.7.01: also when its Hurt already used the Evade up (evd)
        s.me.hp = Math.max(0, s.me.hp - pv); s.me.poison--;
        s.envlog.push({ k: 'poison', x: null, y: null, me: pv, foe: 0.0 });
        if (s.me.poison === 0) s.me.poison_v = 0;
        if (checkEnd(s)) return;
      }
      s.me.simmer = 0;
      if (toInt(nn(s.me.regen, 0)) > 0) { var hh = Math.min(2, toInt(s.me.max) - toInt(s.me.hp)); s.me.hp += Math.max(0, hh); s.me.regen--; s.me.simmer = Math.max(0, hh); }   // 2.6.990 Simmer
    }
    slow = truthy(s.me.slowdraw) ? 1 : 0; s.me.slowdraw = 0; s.me.tripped = slow;   // 2.7.06: also in learner fights (tags 0)
    var gone = expire(s);
    if (s.ven) Object.keys(s.ven).forEach(function (vk) { if (s.ven[vk] <= 1) delete s.ven[vk]; else s.ven[vk] = s.ven[vk] - 1; });   // 2.6.98 venom fades
    if (s.v1 && truthy(s.v1.env)) { var eg = gone.filter(function (p) { return p.by === 'env'; }).map(function (p) { return p.id; }); if (eg.length) s.envlog.push({ k: 'expire', x: null, y: null, me: 0, foe: 0.0, ids: eg }); }   // 2.6.75
    draw(s, 'foe', s.foe.hsize);
    s.turn++; s.round++;
    if (s.v1 && truthy(s.v1)) { var kept = Math.min(toInt(s.me.keep), toInt(s.me.block)); s.me.faded = Math.max(0, toInt(s.me.block) - kept); s.me.kept = kept; s.me.block = kept; s.me.keep = 0; }   // 2.6.77: your guard fades when your turn starts; only a Hold guard still standing carries over, once
    else { s.me.block = s.me.keep; s.me.keep = 0; }
    s.me.thorns = false; s.me.evade = 0; delete s.me.evd;
    var more = toInt(nn(s.me.more, 0)); s.me.more = 0;   // 2.6.990 Plenty
    if (v1r(s, 'redraw')) { var kept = []; s.me.hand.forEach(function (ht) { if (nn(ht.tag, '') === 'keep') { kept.push(ht); return; } var c = clone(ht); delete c.flip; delete c.ft; s.me.discard.push(c); }); s.me.hand = kept; draw(s, 'me', PF_HAND_CAP - slow + more); }   // 2.6.990 Keeper   // 2.6.95: every unplayed piece goes to the discard (flip cleared), then a fresh hand of 5 (4 when tripped)
    else draw(s, 'me', Math.min(PF_HAND_CAP + more, s.me.hand.length + PF_DRAW - slow));
    s.gone = nn(s.spent, []).map(function (p) { return goneEntry(s, p, true); }).concat(gone.map(function (p) { return goneEntry(s, p, false); }));
    s.spawn = (truthy(s.nospawn) || !v1r(s, 'spawn')) ? null : spawn(s); delete s.nospawn;   // 2.6.99: a strike spent its turn: no free piece
    if (s.turn > PF_TURN_CAP) { s.over = s.boss ? 'defeat' : 'stall'; return; }
    intent(s);
  }

  /**
   * The player's turn: ONE action (see the move shapes at the top). Mutates s like the PHP (by reference); returns {ev, err}.
   * dry = true: report what a place would do (on a copy; no creature turn). canPlay(tile) -> reason|null is the optional PHP hook.
   */
  function play(s, moves, turn, dry, canPlay, withAim) {
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
      if ((!truthy(w.me.held) || isEmpty(w.me.held)) && !v1r(w, 'aside')) return bad();
      if (!truthy(w.me.held) || isEmpty(w.me.held)) return { ev: [], err: 'You have no group set aside.' };
      if (canPlay) for (var gi = 0; gi < w.me.held.pcs.length; gi++) if ((why = canPlay(w.me.held.pcs[gi].tile)) !== null && why !== undefined) return { ev: [], err: why };
      r = placeGroup(w, 'me', mv[1], mv[2]);
      if (r === null) return { ev: [], err: 'The group does not fit there.' };
      ev = r;
    } else if (mv[0] === 'j' || mv[0] === 'h') {
      if (!v1r(w, 'aside') && (!truthy(w.me.held) || isEmpty(w.me.held))) return bad();   // 2.6.95: no setting aside in a new fight
      if (mv.length !== 4 || !isInt(mv[1]) || !isInt(mv[2]) || typeof mv[3] !== 'string') return bad();
      err = mv[0] === 'j' ? connect(w, 'me', mv[1], mv[2], mv[3]) : connect(w, 'me', null, mv[1], mv[3], mv[2]);
      if (err) return { ev: [], err: err };
      var pcs = w.me.held.pcs;
      w.me.block += Math.ceil(toInt(pcs[mv[0] === 'j' ? 1 : pcs.length - 1].tile.v) * PFB_SETASIDE_GUARD);   // 2.6.66: setting a piece aside braces you
      ev = [{ snap: snap(w), by: 'me', connect: true, n: pcs.map(function (gp) { return String(gp.tile.n); }).join(' + '), types: pcs.map(function (gp) { return String(gp.tile.t); }), size: pcs.length }];
    } else return bad();
    ev.forEach(function (e0) { e0.ta = 'me'; });
    if (dry) { var dr = { ev: ev, err: null, bar: round(w.bar.now, 1), max: w.bar.max, fh: round(w.fh.now, 1), fhmax: w.fh.max, hp: w.me.hp, block: w.me.block, over: w.over }; if (withAim && v1r(w, 'aimtot')) dr.aim = aimTotal(w); return dr; }
    if (!w.over) { var fe = foeTurn(w); fe.forEach(function (e0) { e0.ta = 'foe'; }); ev = ev.concat(fe); }
    var trip = !w.over && w.v1 && truthy(w.v1) && truthy(w.me.slowdraw);
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
    if (!v1r(s, 'freepass')) for (i = 0; i < s.me.hand.length; i++) {   // 2.6.95: passing is free in a new fight
      if (cells(s, s.me.hand[i]).length) return { ev: [], err: 'You still have a piece that fits somewhere.' };
      if (canFlip(s, i) && cells(s, flipped(s.me.hand[i])).length) return { ev: [], err: 'You still have a piece that fits somewhere when you flip it.' };
    }
    if (!v1r(s, 'freepass') && truthy(s.me.held) && !isEmpty(s.me.held) && groupSpots(s, s.me.held).length) return { ev: [], err: 'Your set-aside group still fits somewhere.' };
    var w = clone(s); w.spent = []; w.lastfoe = []; w.gone = []; begin(w, 'me');   // 2.6.95: a pass is a turn like a play: last round's news is not this turn's
    if (w.v1) w.envlog = [];
    var ev = foeTurn(w); ev.forEach(function (e0) { e0.ta = 'foe'; });
    w.fx = fx(ev);
    var trip = !w.over && w.v1 && truthy(w.v1) && truthy(w.me.slowdraw);
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
      var n = 0, tw = 1.0, sun = 0, mud = 0, hw = [], hpp = hp0;
      r.ev.forEach(function (e) { if (e.barnow === undefined) return; n++; if (e.tw !== undefined) tw = Number(e.tw); if (truthy(e.sun) && e.by === 'me') sun++; if (truthy(e.mud) && e.by === 'me') mud++;
        if (toInt(e.hpnow) < hpp) hw.push([String(e.n), String(e.by), hpp - toInt(e.hpnow)]); hpp = toInt(e.hpnow); });   // 2.7.01 costly cell (pfb_cell_preview)
      o[c[0] + ',' + c[1]] = { dmg: iround(r.fh - fh0), ch: iround(r.bar - b0), hp: Math.max(0, hp0 - toInt(r.hp)), n: n, used: !!(r.ev[0] && r.ev[0].used && r.ev[0].used.length), tw: tw, sun: sun, end: truthy(r.over) };
      if (truthy(s.v1.env)) o[c[0] + ',' + c[1]].mud = mud;
      if (hp0 > toInt(r.hp) && hw.length) o[c[0] + ',' + c[1]].hw = hw;
      r.ev.forEach(function (e) { if (e.note === 'palaim') o[c[0] + ',' + c[1]].pal = { id: toInt(e.tid), n: String(e.n), x: toInt(e.x), y: toInt(e.y) }; });   // 2.7.08 pal targeting
    });
    return o;
  }

  /** What the client may see: no draw pile, no foe hand, no rng, no nonce. */
  function view(s) {
    var v = pfView(s), i;
    if (s.v1 && truthy(s.v1.onebar)) { v.onebar = 1; v.charmable = s.cm > 0 && !s.boss; }   // 2.6.95: one shared bar
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
      if (truthy(c.env)) v.env = { next: s.env.next.map(function (nx) { return { k: nx.k, n: nx.n, kind: nx.env, life: truthy(nn(s.v1.life, 0)) ? toInt(nx.life) : PFB_LIFE, e: edges(nx) }; }), deck: s.env.draw.length, used: s.env.discard.length, n: toInt(c.envn) };   // 2.6.75: next is a list
      v.aim = clone(nn(s.foe.plan, null));
      if (kindNow(s) !== '') { v.kind = kindNow(s); v.grudge = toInt(nn(s.foe.grudge, 0)); v.ven = Object.keys(nn(s.ven, {})).map(function (k) { var a = k.split(','); return { x: toInt(a[0]), y: toInt(a[1]), r: s.ven[k] - 1 }; }); }   // 2.6.98 class rules
      if (nn(s.foe.aid, '') !== '') v.ai = { id: s.foe.aid, n: PFB_AI[s.foe.aid][12], t: PFB_AI[s.foe.aid][13] };   // 2.7.01: its play style for the card
      if (hasAb(s)) v.abil = s.foe.ab.map(function (id) { return { id: id, n: PFB_ABIL[id][4], t: PFB_ABIL[id][5] }; });   // 2.7.01: the creature's abilities for its card
      v.reaim = truthy(s.reaim);
      v.flip = { on: truthy(c.flip), used: toInt(nn(s.me.flipt, 0)) === toInt(s.turn) };
      if (truthy(c.tags)) v.status = { poison: toInt(s.me.poison), poison_v: toInt(s.me.poison_v), slowdraw: toInt(s.me.slowdraw), evade: toInt(s.me.evade),
        foe_evade: toInt(s.foe.evade), foe_thorns: truthy(s.foe.thorns), foe_bash: toInt(s.foe.bashnext), foe_slow: toInt(s.foe.slow), foe_poison: toInt(s.foe.poison) };
      if (v1r(s, 'aimtot') && v.status) v.status.foe_block = toInt(s.foe.block);
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
    if (truthy(e.strike)) return '💥 STRUCK: its ' + e.n + ' hit your ' + nn(e.mine, 'piece') + ' (' + toInt(e.hit) + ')' + (truthy(e.broke) ? ' and it breaks.' : ' but your guard ' + toInt(e.guard) + ' holds.');   // 2.6.98 aimhit
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
      case 'hurt': tail = e.by === 'me' ? ' for ' + toInt(nn(e.dmg, e.v)) + (toInt(nn(e.blocked, 0)) > 0 ? ' (' + toInt(e.blocked) + ' blocked by its guard)' : '') :' for ' + toInt(nn(e.dmg, e.v)) + ' damage'; break;
      case 'guard': tail = ' (+' + toInt(e.v) + ' guard)'; break;
      case 'heal': case 'item': tail = (e.by === 'foe' && e.healed !== undefined) ? ' (its yield bar back ' + String(Number(e.healed)) + ')' : ' (+' + toInt(e.v) + ' health)'; break;
      case 'charm': tail = ' (' + toInt(e.v) + ')'; break;
      default: tail = '';
    }
    if (e.ta && e.ta !== e.by && (e.ta === 'me' || e.ta === 'foe') && (e.by === 'me' || e.by === 'foe')) who = e.ta === 'me' ? 'Your chain fires the ' + foe + '\u2019s' : 'The ' + foe + '\u2019s chain fires your';   // 2.6.76: a chain through the other side's piece
    else if (e.root === false && (e.by === 'me' || e.by === 'foe')) who = e.by === 'me' ? 'Your chain fires your' : 'The ' + foe + '\u2019s chain fires its';   // after 2.6.96 (owner: "random plays"): a piece already on the board that fires in its own side's chain is not played again
    return (e.by === 'me' ? '🧩 ' : '💥 ') + who + ' ' + e.n + tail + (bits.length ? ' · ' + bits.join(', ') : '') + '.';
  }
  function noteLine(e, foe) {
    switch (e.note) {
      case 'quick': return '\u26A1 ' + (e.n ? e.n + ': ' : '') + 'Quick. The ' + foe + ' plays a second piece.';
      case 'slow': return '\u23F3 The ' + foe + ' loses its turn.';
      case 'fade': return '\uD83D\uDEE1\uFE0F Your guard fades (-' + toInt(e.n) + ') as your turn starts.';
      case 'hold': return '\uD83D\uDEE1\uFE0F Hold: ' + toInt(e.n) + ' guard stays up into your turn.';
      case 'simmer': return '\uD83C\uDF75 Simmer: you heal ' + toInt(e.n) + ' as your turn starts.';
      case 'current': return '\uD83C\uDF0A The current pushes your ' + e.n + ' one cell.';
      case 'grows': return '\uD83C\uDF3F The ' + foe + ' grows a Bramble beside its piece.';
      case 'venom': return '\u2620\uFE0F Venom: your ' + e.n + ' poisons you (' + (e.pv !== undefined && e.pv !== null ? toInt(e.pv) : 2) + ' a round, ' + (e.pr !== undefined && e.pr !== null ? toInt(e.pr) : 2) + ' rounds).';
      case 'drain': return '\uD83E\uDE78 Drain: the ' + foe + ' heals ' + Number(e.n) + ' from the hit.';
      case 'stagger': return '\uD83D\uDCAB Stagger: the hit leaves you one piece short next round.';
      case 'regrow': return '\uD83C\uDF31 Regrow: the ' + foe + ' heals ' + Number(e.n) + '.';
      case 'plated': return '\uD83D\uDEE1\uFE0F Plated: the ' + foe + ' starts its turn with ' + toInt(e.n) + ' guard.';
      case 'palaim': return '\uD83D\uDC3E ' + String(nn(e.pal, 'Your pal')) + ' goes for the ' + foe + '\u2019s strongest piece: its ' + e.n + ' is knocked off the board.';
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
    if (e.note !== undefined && e.note !== null) return ext({ by: String(e.by), types: ['note'], tags: [String(e.note)], txt: e.note === 'quick' ? '\u26A1 Quick: plays 2' : e.note === 'slow' ? '\u23F3 loses its turn' : e.note === 'fade' ? '\uD83D\uDEE1\uFE0F guard fades -' + toInt(e.n) : e.note === 'hold' ? '\uD83D\uDEE1\uFE0F Hold kept ' + toInt(e.n) : e.note === 'simmer' ? '\uD83C\uDF75 Simmer +' + toInt(e.n) : e.note === 'current' ? '\uD83C\uDF0A pushed ' + e.n : e.note === 'grows' ? '\uD83C\uDF3F grows a Bramble' : e.note === 'venom' ? '\u2620\uFE0F venom: poisoned' : e.note === 'drain' ? '\uD83E\uDE78 drains ' + Number(e.n) : e.note === 'stagger' ? '\uD83D\uDCAB staggered: 1 fewer' : e.note === 'regrow' ? '\uD83C\uDF31 regrows ' + Number(e.n) : e.note === 'plated' ? '\uD83D\uDEE1\uFE0F plated +' + toInt(e.n) : e.note === 'palaim' ? '\uD83D\uDC3E knocks off ' + e.n : '\uD83E\uDDB6 you draw 1 fewer', tg: null });
    var parts = [], tg = 'foe', by = String(nn(e.by, 'me')), t = String(nn(e.t, 'hurt'));
    if (truthy(e.tick)) parts.push('-' + toInt(e.v) + ' hp');
    else if (by === 'me') {
      var bar = Number(nn(e.bar, 0)), fhh = Number(nn(e.fh, 0));
      if (fhh > 0) parts.push('-' + iround(fhh) + ' hp');
      if (bar > 0) parts.push('+' + iround(bar) + ' charm');
      if (t === 'hurt' && toInt(nn(e.blocked, 0)) > 0) parts.push(toInt(e.blocked) + ' blocked');   // 2.7.08: what its guard soaked
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
    envTable: envTable, envDeck: envDeck, tiles: tiles, playerDeck: playerDeck, newFight: newFight, start: start, play: play, pass: pass, redraw: redraw, view: view,
    cells: cells, edges: edges, joint: joint, groupSpots: groupSpots, groupFit: groupFit, groupOptions: groupOptions, search: search,
    line: line, chipEvent: chipEvent, chipsBoard: chipsBoard,
    // more of the PHP functions
    check: check, chain: chain, links: links, place: place, placeGroup: placeGroup, connect: connect, groupCells: groupCells, score: score, expire: expire,
    flip: flip, canFlip: canFlip, cellPreview: cellPreview, v1Cfg: v1Cfg, v1r: v1r, PFB_V1_PRE: PFB_V1_PRE, ABIL: PFB_ABIL, AB_RANGE: PFB_AB_RANGE, ter: ter, envLine: envLine, forecast: forecast, envTurn: envTurn, lifeOf: lifeOf,
    spawn: spawn, aiMake: aiMake, AI: PFB_AI, AI_KEYS: PFB_AI_KEYS, why: why, feat: feat, myMoves: myMoves, endRound: endRound, foeTurn: foeTurn, intent: intent, snap: snap, fx: fx, begin: begin, fire: fire,
    makeTile: makeTile, foeDeck: foeDeck, temper: temper, value: value, apply: apply, checkEnd: checkEnd, draw: draw, rand: rand, shuffle: shuffle,
    collection: collection, box: box, boxCheck: boxCheck, boxCapacity: boxCapacity, unlocks: unlocks,
    round: round, crc32: crc32, clone: clone,
    // data
    W: PFB_W, H: PFB_H, LIFE: PFB_LIFE, SIDE: PFB_SIDE, HOLE: PF_HOLE, STAT: PF_STAT, COMBOS: PF_COMBOS, TAGS: PF_TAGS, MODS: PF_MODS,
    CALLING_TILE: PF_CALLING_TILE, BASE_KEYS: PF_BASE_KEYS, GENTLE: PF_GENTLE, SIGNATURE: PF_SIGNATURE, TURN_CAP: PF_TURN_CAP, HAND_CAP: PF_HAND_CAP
  };
});
