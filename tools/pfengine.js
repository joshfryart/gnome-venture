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
  var PF_FOE_DMG = 1.4, PF_FOE_BOSS = 0.78;
  var PFB_W = 7, PFB_H = 5, PFB_LIFE = 3, PFB_FOE_MIN = 2, PFB_GROUP_MAX = 3;
  var PFB_GROUP_MULT = { 2: 1.0, 3: 1.25 };
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
    return { k: key, n: d.n, t: d.t, v: Math.max(1, toInt(d.v) + stat + lvl + bonus), r: nn(d.r), tag: String(d.tag), m: '' };
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
    var hm = tp === 'hostile' ? 1.0 : PF_GENTLE_HM, cm = tp === 'hostile' ? 0.4 : 1.0;
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
    if (s.fh.now >= s.fh.max) { s.over = 'seen_off'; return true; }
    if (s.cm > 0 && s.bar.now >= s.bar.max) { s.over = 'charmed'; return true; }
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
    if (m === 'finisher' && who === 'me' && s.fh.now >= 0.6 * s.fh.max) val += 3;
    switch (tile.t) {
      case 'hurt':
        dmg = val;
        if (who === 'me' && tile.tag === 'bash') { dmg += mine.block; e.bashed = mine.block; mine.block = 0; }
        if (who === 'foe') { var cut = Math.min(s.foe.agg, dmg); s.foe.agg -= cut; dmg -= cut; e.soothed = cut; }
        if (who === 'foe') {
          if (theirs.evade > 0) { theirs.evade--; e.evaded = dmg; dmg = 0; }
          abs = Math.min(theirs.block, dmg); theirs.block -= abs; dmg -= abs;
          if (abs > 0 && theirs.thorns) { pr = 2 * s.hm; s.fh.now += pr; e.pricked = round(pr, 1); }
          theirs.hp = Math.max(0, theirs.hp - dmg);
          e.dmg = dmg; e.blocked = abs;
        } else {
          abs = tile.tag === 'pierce' ? 0 : Math.min(theirs.block, dmg); theirs.block -= abs; dmg -= abs;
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

  // ------------------------------------------------------------------ board: edges and joints
  var EDGE_CACHE = {};
  function edges(t) {
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
    if (a[0] === 'flat' || b[0] === 'flat') return [true, false];
    var ok = a[0] !== b[0] && a[1] === b[1];
    return [ok, ok];
  }

  function pieceAt(s, x, y) {
    var id = s.cell[x + ',' + y];
    return (id === undefined || id === null) ? null : s.pcs[id];
  }

  function check(s, tile, x, y) {
    if (x < 0 || y < 0 || x >= PFB_W || y >= PFB_H || has(s.cell, x + ',' + y)) return null;
    if (isEmpty(s.pcs)) return (x === intdiv(PFB_W, 2) && y === intdiv(PFB_H, 2)) ? [] : null;
    var e = edges(tile), joints = [];
    for (var side in PFB_SIDE) {
      var sd = PFB_SIDE[side], n = pieceAt(s, x + sd[0], y + sd[1]);
      if (!n) continue;
      var j = joint(e[side], edges(n.tile)[sd[2]]);
      if (!j[0]) return null;
      joints.push([side, toInt(n.id), j[1]]);
    }
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
    for (var i = 0; i < hand.length; i++) for (var y = 0; y < PFB_H; y++) for (var x = 0; x < PFB_W; x++) if (hasLink(check(s, hand[i], x, y))) return true;
    var g = nn(s[who].held, null);
    if (g && !isEmpty(g)) { var all = groupCellsAll(s, g); for (var k = 0; k < all.length; k++) if (all[k][2]) return true; }
    return false;
  }

  function cells(s, tile, who) {
    var o = [], must = (who !== undefined && who !== null) && mustLink(s, who);
    for (var y = 0; y < PFB_H; y++) for (var x = 0; x < PFB_W; x++) { var j = check(s, tile, x, y); if (j !== null && (!must || hasLink(j))) o.push([x, y]); }
    return o;
  }

  function links(s, id) {
    var p = s.pcs[id], e = edges(p.tile), o = [];
    for (var side in PFB_SIDE) {
      var sd = PFB_SIDE[side], n = pieceAt(s, p.x + sd[0], p.y + sd[1]);
      if (n && joint(e[side], edges(n.tile)[sd[2]])[1]) o.push(n);
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
    for (var i = 0; i < ch.length; i++) {
      var id = ch[i][0], par = ch[i][1];
      if (s.over) break;
      var p = s.pcs[id], who = p.by, tile = p.tile;
      var pt = par !== null ? s.pcs[par] : null;
      var vv = value(pt ? pt.tile : null, tile, pt !== null && pt.by === who, false), ck = vv[2];
      var val = iround(vv[0] * Number(nn(p.cm, 1.0)));
      var isRoot = id === root;
      var e = { by: who, id: id, root: isRoot, tag: tile.tag, mod: String(nn(tile.m, '')), k: tile.k, n: tile.n, t: tile.t, v: val, fit: false, combo: ck ? PF_COMBOS[ck].name : null };
      apply(s, who, tile, val, isRoot && links(s, id).length !== 0, ck, pt ? pt.tile : null, pt ? pt.by : null, e, isRoot, false);
      e.barnow = round(Number(s.bar.now), 1); e.fhnow = round(Number(s.fh.now), 1); e.hpnow = toInt(s.me.hp); e.gnow = toInt(s.me.block);
      ev.push(e);
      checkEnd(s);
    }
    return ev;
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
    if (jt === null || (!hasLink(jt) && mustLink(s, who))) return null;   // it has to connect unless nothing can
    s[who].hand.splice(handIdx, 1);
    var id = ++s.pid; s.seq++;
    s.pcs[id] = { id: id, by: who, tile: tile, x: x, y: y, born: s.round, seq: s.seq };
    s.cell[x + ',' + y] = id;
    var joints = checkAfter(s, id);
    var ev = fire(s, id);
    if (ev.length) { ev[0].linked = joints; ev[0].snap = snap(s); }
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
      if (cx < 0 || cy < 0 || cx >= PFB_W || cy >= PFB_H || has(s.cell, cx + ',' + cy)) return null;
      var e = edges(g.pcs[gi].tile);
      for (var side in PFB_SIDE) {
        var sd = PFB_SIDE[side], nx = cx + sd[0], ny = cy + sd[1];
        if (has(mine, nx + ',' + ny)) continue;
        var n = pieceAt(s, nx, ny); if (!n) continue;
        var jt = joint(e[side], edges(n.tile)[sd[2]]);
        if (!jt[0]) return null;
        touch = true; if (jt[1]) linked = true;
      }
    }
    if (isEmpty(s.pcs)) {
      var c0 = intdiv(PFB_W, 2), c1 = intdiv(PFB_H, 2);
      for (i = 0; i < cs.length; i++) if (cs[i][0] === c0 && cs[i][1] === c1) return [cs, false];
      return null;
    }
    return touch ? [cs, linked] : null;
  }
  function groupCellsAll(s, g) {
    var o = [];
    for (var y = 0; y < PFB_H; y++) for (var x = 0; x < PFB_W; x++) { var r = groupCellsL(s, g, x, y); if (r !== null) o.push([x, y, r[1]]); }
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
    }
    s[who].held = null;
    var ev = fire(s, root);
    if (ev.length) { ev[0].linked = checkAfter(s, root); ev[0].snap = snap(s); }
    return ev;
  }

  function expire(s) {
    var gone = [], ids = Object.keys(s.pcs);
    for (var i = 0; i < ids.length; i++) {
      var p = s.pcs[ids[i]];
      if (p.born <= s.round - PFB_LIFE + 1) {
        s[p.by].discard.push(p.tile);
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
    return pick === null ? 0 : pick;
  }

  function foeCount(s) { var n = 0; for (var id in s.pcs) if (s.pcs[id].by === 'foe') n++; return n; }

  function spawn(s) {
    if (foeCount(s) >= PFB_FOE_MIN) return null;
    var pick = anchorPick(s); if (pick === null) return null;
    var tile = s.foe.hand[pick];
    var cs = !isEmpty(s.pcs) ? cells(s, tile) : [[intdiv(PFB_W, 2), intdiv(PFB_H, 2)]];
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
    if (who === 'me') return barD + 0.7 * hpD + 0.3 * (a.me.block - b.me.block) - 0.3 * (a.foe.block - b.foe.block) + (truthy(a.over) && (a.over === 'seen_off' || a.over === 'charmed') ? 50 : 0);
    return -0.8 * barD - hpD + 0.4 * (a.foe.block - b.foe.block) - 0.3 * (a.me.block - b.me.block) + (a.over === 'defeat' ? 50 : 0);
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
        if (best === null || sc > best[3] + 1e-9) best = [i, x, y, sc];
      }
    }
    return best;
  }

  function foeLen(s) { return Math.max(0, Math.min(s.foe.hand.length, 1 - toInt(s.foe.slow))); }

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
    var n = foeLen(s); s.lastfoe = [];
    for (var k = 0; k < n && !s.over; k++) {
      var m = search(s, 'foe');
      if (m === null) break;
      var r = place(s, 'foe', m[0], m[1], m[2]);
      if (r) { ev = ev.concat(r); s.lastfoe.push(s.pid); }
    }
    s.foe.agg = 0; s.foe.slow = 0;
    return ev;
  }

  function intent(s) {
    var m = search(s, 'foe');
    s.foe.intent = m ? s.foe.hand[m[0]].t : null;
  }

  // ------------------------------------------------------------------ the whole fight
  function newFight(me, c, seed, opt) {
    var s = pfNew(me, c, seed, opt);
    ['hand', 'draw', 'discard'].forEach(function (z) { s.foe[z].forEach(function (t) { t.v = Math.max(1, iround(t.v * PFB_FOE_MULT)); }); });
    s.bar.max = round(s.bar.max * PFB_BAR_MULT, 1); s.fh.max = s.bar.max;
    s.mode = 'board'; s.strip = []; s.pcs = {}; s.cell = {}; s.pid = 0; s.seq = 0; s.round = 1;
    var n = s.size === 'boss' ? 2 : 1;
    for (var k = 0; k < n; k++) {
      var pick = anchorPick(s); if (pick === null) continue;
      var hand = s.foe.hand;
      var cs = isEmpty(s.pcs) ? [[intdiv(PFB_W, 2), intdiv(PFB_H, 2)]] : null;
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
    var gone = expire(s);
    draw(s, 'foe', s.foe.hsize);
    s.turn++; s.round++;
    s.me.block = s.me.keep; s.me.keep = 0; s.me.thorns = false; s.me.evade = 0;
    draw(s, 'me', Math.min(PF_HAND_CAP, s.me.hand.length + PF_DRAW));
    s.gone = gone.map(function (p) { return { id: p.id, by: p.by, x: p.x, y: p.y, tile: p.tile, age: s.round - 1 - p.born }; });
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
    if (turn !== s.turn) return { ev: [], err: 'stale' };
    if (!Array.isArray(moves) || moves.length !== 1) return { ev: [], err: 'One action a turn.' };
    var mv = moves[0];
    if (!Array.isArray(mv) || !mv.length) return bad();
    var w = clone(s);
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
      ev = [{ snap: snap(w), by: 'me', connect: true, n: pcs.map(function (gp) { return String(gp.tile.n); }).join(' + '), types: pcs.map(function (gp) { return String(gp.tile.t); }), size: pcs.length }];
    } else return bad();
    ev.forEach(function (e0) { e0.ta = 'me'; });
    if (dry) return { ev: ev, err: null, bar: round(w.bar.now, 1), max: w.bar.max, fh: round(w.fh.now, 1), fhmax: w.fh.max, hp: w.me.hp, block: w.me.block, over: w.over };
    if (!w.over) { var fe = foeTurn(w); fe.forEach(function (e0) { e0.ta = 'foe'; }); ev = ev.concat(fe); }
    if (!w.over) endRound(w);
    w.fx = fx(ev);
    w.log.push({ turn: s.turn, n: 1 });
    assignInto(s, w);
    return { ev: ev, err: null };
  }

  /** Pass the turn with nothing to place. */
  function pass(s, turn) {
    if (s.over || turn !== s.turn) return { ev: [], err: s.over ? 'The fight is over.' : 'stale' };
    var i;
    for (i = 0; i < s.me.hand.length; i++) if (cells(s, s.me.hand[i]).length) return { ev: [], err: 'You still have a piece that fits somewhere.' };
    if (truthy(s.me.held) && !isEmpty(s.me.held) && groupSpots(s, s.me.held).length) return { ev: [], err: 'Your set-aside group still fits somewhere.' };
    var w = clone(s); begin(w, 'me');
    var ev = foeTurn(w); ev.forEach(function (e0) { e0.ta = 'foe'; });
    w.fx = fx(ev);
    if (!w.over) endRound(w);
    assignInto(s, w);
    return { ev: ev, err: null };
  }

  /** What the client may see: no draw pile, no foe hand, no rng, no nonce. */
  function view(s) {
    var v = pfView(s), i;
    v.mode = 'board'; v.w = PFB_W; v.h = PFB_H; v.fx = clone(nn(s.fx, []));
    var g = nn(s.me.held, null);
    v.held = g ? {
      pcs: g.pcs.map(function (p) { return { n: p.tile.n, t: p.tile.t, v: p.tile.v, tag: p.tile.tag, m: String(nn(p.tile.m, '')), e: edges(p.tile), x: p.x, y: p.y }; }),
      spots: groupSpots(s, g),
      link: groupCellsAll(s, g).some(function (o) { return o[2]; })
    } : null;
    v.pcs = [];
    for (var id in s.pcs) { var p = s.pcs[id]; v.pcs.push({ id: p.id, by: p.by, x: p.x, y: p.y, n: p.tile.n, t: p.tile.t, v: p.tile.v, tag: p.tile.tag, m: String(nn(p.tile.m, '')), e: edges(p.tile), age: s.round - p.born, seq: p.seq, spawn: nn(s.spawn, null) === p.id, fnew: nn(s.lastfoe, []).indexOf(p.id) >= 0 }); }
    v.gone = nn(s.gone, []).map(function (q) { return { id: q.id, by: q.by, x: q.x, y: q.y, n: q.tile.n, t: q.tile.t, v: q.tile.v, tag: q.tile.tag, m: String(nn(q.tile.m, '')), e: edges(q.tile), age: q.age }; });
    for (i = 0; i < v.hand.length; i++) v.hand[i].e = edges(s.me.hand[i]);
    delete v.strip; delete v.open; delete v.open_t; delete v.open_v; delete v.open_by;
    return v;
  }

  // ------------------------------------------------------------------ text lines and history chips (pfight_game.php)
  function line(e, foe) {
    if (truthy(e.connect)) return '🧩 You set ' + e.n + ' aside, joined (' + toInt(e.size) + ' pieces).';
    if (truthy(e.tick)) return '🧪 The poison works on the ' + foe + ' (+' + toInt(e.v) + ').';
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
    return (e.by === 'me' ? '🧩 ' : '💥 ') + who + ' ' + e.n + tail + (bits.length ? ' · ' + bits.join(', ') : '') + '.';
  }

  /** One history chip for one scored event (board mode). snapId = the snapshot index the page keeps for the rewind. */
  function chipEvent(e, snapId) {
    if (snapId === undefined) snapId = null;
    var base = { id: (e.id !== undefined && e.id !== null) ? toInt(e.id) : null, sn: snapId, bar: nn(e.barnow, null), fh: nn(e.fhnow, null), hp: nn(e.hpnow, null), g: nn(e.gnow, null), chain: false };
    var ext = function (o) { for (var k in o) base[k] = o[k]; return base; };
    if (truthy(e.connect)) return ext({ by: 'me', types: e.types, tags: [], txt: 'joined ' + toInt(e.size), tg: null });
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
      if (truthy(e.tick)) continue;
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
    tiles: tiles, playerDeck: playerDeck, newFight: newFight, play: play, pass: pass, view: view,
    cells: cells, edges: edges, joint: joint, groupSpots: groupSpots, groupFit: groupFit, groupOptions: groupOptions, search: search,
    line: line, chipEvent: chipEvent, chipsBoard: chipsBoard,
    // more of the PHP functions
    check: check, chain: chain, links: links, place: place, placeGroup: placeGroup, connect: connect, groupCells: groupCells, score: score, expire: expire,
    spawn: spawn, endRound: endRound, foeTurn: foeTurn, intent: intent, snap: snap, fx: fx, begin: begin, fire: fire,
    makeTile: makeTile, foeDeck: foeDeck, temper: temper, value: value, apply: apply, checkEnd: checkEnd, draw: draw, rand: rand, shuffle: shuffle,
    collection: collection, box: box, boxCheck: boxCheck, boxCapacity: boxCapacity, unlocks: unlocks,
    round: round, crc32: crc32, clone: clone,
    // data
    W: PFB_W, H: PFB_H, LIFE: PFB_LIFE, SIDE: PFB_SIDE, HOLE: PF_HOLE, STAT: PF_STAT, COMBOS: PF_COMBOS, TAGS: PF_TAGS, MODS: PF_MODS,
    CALLING_TILE: PF_CALLING_TILE, BASE_KEYS: PF_BASE_KEYS, GENTLE: PF_GENTLE, SIGNATURE: PF_SIGNATURE, TURN_CAP: PF_TURN_CAP, HAND_CAP: PF_HAND_CAP
  };
});
