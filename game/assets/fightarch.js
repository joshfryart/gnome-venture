/* Fight engine: how each creature ARCHETYPE moves. Loaded before assets/fightengine.js (which reads window.FE_ARCH); bones and sheets come from assets/fightrigs.js.
 * One entry per archetype (or 'arch.kind' when a kind needs its own): { attack: move name, poses: {name: {dur, loops, keep, tracks}}, springs: {part or 'pat*': {...}}, fidgets: [pose names], size }.
 * Poses a creature needs: idle, run, hit, dodge, ko, blink, and one per attack move it can use (named like the move: charge, pounce, hop, slam, peck, swoop, strike, smash). Durations match the move.
 * Track key: [ms, {r deg clockwise, x, y (figure units: 1 = one design px, up is negative), sx, sy}, ease]. Creatures face RIGHT: a leg swings back with +r, a head nods down with +r.
 * Springs are never keyed for follow-through: tails, feelers, eye stalks, tentacles and worm segments swing by themselves from how their bone moves.
 * FE_ARCH.slug: per-creature exceptions ({attack, size}). See claude/animating-2-5d-sprites.md. */
(function (root) {
  'use strict';
  var O = 'cubic-bezier(.2,.7,.3,1)', I = 'cubic-bezier(.6,0,.9,.4)', S = 'ease-in-out';
  /* t([ms, r, {more}, ease], ...) -> a track. r 0 may be left as 0; `more` and `ease` are optional. */
  function t() {
    return [].map.call(arguments, function (q) {
      var o = {}, e = q[3], k; if (q[1]) o.r = q[1];
      if (q[2] && typeof q[2] === 'object') { for (k in q[2]) o[k] = q[2][k]; } else if (q[2]) e = q[2];
      return e ? [q[0], o, e] : [q[0], o];
    });
  }
  /* wave(dur, amp, phase, {prop, base, lift, n}): a looping sine on one property, sampled n times. lift: the part also rises (y) on the forward half: a step. */
  function wave(dur, amp, ph, o) {
    o = o || {}; var n = o.n || 8, out = [], i, a, k;
    for (i = 0; i <= n; i++) { a = 2 * Math.PI * (i / n + (ph || 0)); k = {}; k[o.prop || 'r'] = (o.base || 0) + amp * Math.sin(a); if (o.lift) k.y = -o.lift * Math.max(0, Math.cos(a)); out.push([Math.round(dur * i / n), k]); }
    return out;
  }
  function mix(a, b) { return a.map(function (q, i) { var o = {}, k; for (k in q[1]) o[k] = q[1][k]; for (k in b[i][1]) o[k] = b[i][1][k]; return [q[0], o]; }); }
  function each(ids, fn) { var o = {}; ids.forEach(function (id, i) { o[id] = fn(i, id); }); return o; }
  function join() { var o = {}, i, k; for (i = 0; i < arguments.length; i++) for (k in arguments[i]) o[k] = arguments[i][k]; return o; }
  function loop(dur, tracks) { return { dur: dur, loops: Infinity, tracks: tracks }; }
  function once(dur, tracks, keep) { var p = { dur: dur, tracks: tracks }; if (keep) p.keep = 1; return p; }
  var BLINK = once(170, { eyes: t([0, 0, { sy: 1 }], [40, 0, { sy: .12 }], [120, 0, { sy: .12 }], [170, 0, { sy: 1 }]) });
  var BLINK2 = once(190, { eyeL: t([0, 0, { sy: 1 }], [50, 0, { sy: .35 }], [130, 0, { sy: .35 }], [190, 0, { sy: 1 }]), eyeR: t([0, 0, { sy: 1 }], [50, 0, { sy: .35 }], [130, 0, { sy: .35 }], [190, 0, { sy: 1 }]) });
  var A = {};

  /* ---------- quadrupeds (side view): body, head (+eyes, mane), tail, four legs: legBN/legFN near, legBF/legFF far ---------- */
  var QL = ['legBN', 'legFF', 'legFN', 'legBF'];   // trot: diagonal pairs move together
  var QUAD = {
    idle: loop(1800, join({ body: t([0, 0], [900, .6, { y: -.7 }, S], [1800, 0, S]), head: t([0, -1], [1050, 3, { y: .4 }, S], [1800, -1, S]), tail: wave(1800, 5, 0, { n: 4 }) },
      each(QL, function () { return t([0, 0], [900, 0, { y: .7 }, S], [1800, 0, S]); }))),   // legs counter the chest lift: feet stay planted
    run: loop(400, join({ body: mix(wave(400, 5, 0), wave(400, 1.5, .25, { prop: 'y' })), head: wave(400, -6, .1), tail: wave(400, 12, .3, { base: 14 }) },
      { legBN: wave(400, 40, 0, { lift: 2 }), legBF: wave(400, 40, .08, { lift: 2 }), legFN: wave(400, 40, .5, { lift: 2 }), legFF: wave(400, 40, .58, { lift: 2 }) })),   // gallop: back pair, then front pair
    charge: once(900, {   // paws the ground twice, head down, gallops in, tosses the head up on contact, backs off
      body: t([0, 0], [200, -5, O], [430, 6, I], [480, 2], [700, -3], [900, 0, S]), head: t([0, 0], [200, 26, O], [320, 30], [430, 14, I], [480, -22, O], [640, 6], [900, 0, S]),
      tail: t([0, 0], [200, 25, O], [430, -10, I], [900, 0, S]),
      legFN: t([0, 0], [110, 46, O], [170, -8], [230, 46], [290, -8], [360, 40], [430, -40, I], [560, 20], [700, -25], [800, 20], [900, 0, S]), legFF: t([0, 0], [200, -6], [330, -36], [430, 34, I], [560, -20], [700, 25], [800, -20], [900, 0, S]),
      legBN: t([0, 0], [200, -12, O], [330, 34], [430, -30, I], [560, 16], [700, -25], [800, 20], [900, 0, S]), legBF: t([0, 0], [200, -10, O], [330, -30], [430, 36, I], [560, -14], [700, 25], [800, -20], [900, 0, S]) }),
    pounce: once(850, {   // crouch (rump up, head low), spring: front legs reach, back legs trail; lands on the foe, hops back
      body: t([0, 0], [220, 9, O], [330, -16, O], [410, 10, I], [470, 4], [650, -6], [850, 0, S]), head: t([0, 0], [220, 14, O], [330, -14], [410, 22, I], [470, -8, O], [850, 0, S]),
      tail: t([0, 0], [220, 30, O], [330, -25], [410, -10], [850, 0, S]),
      legFN: t([0, 0], [220, 24, O], [330, -70, O], [410, -45], [470, 10], [650, -30], [850, 0, S]), legFF: t([0, 0], [220, 20, O], [330, -60, O], [410, -55], [470, 6], [650, 20], [850, 0, S]),
      legBN: t([0, 0], [220, -20, O], [330, 58, O], [410, 40], [470, -5], [650, 30], [850, 0, S]), legBF: t([0, 0], [220, -16, O], [330, 50, O], [410, 46], [470, -8], [650, -20], [850, 0, S]) }),
    hop: once(800, {   // two bounds: legs tuck in the air, stretch to land
      body: t([0, 0], [120, 8, O], [220, -12, O], [300, 8, I], [360, -12, O], [440, 10, I], [600, -4], [800, 0, S]), head: t([0, 0], [120, 10], [220, -10], [300, 12], [360, -12], [440, 18, I], [520, -6], [800, 0, S]),
      legFN: t([0, 0], [120, 20], [220, -50, O], [300, 10], [360, -55, O], [440, 12], [800, 0, S]), legFF: t([0, 0], [120, 16], [220, -42, O], [300, 8], [360, -48, O], [440, 10], [800, 0, S]),
      legBN: t([0, 0], [120, -24], [220, 55, O], [300, -10], [360, 60, O], [440, -10], [800, 0, S]), legBF: t([0, 0], [120, -20], [220, 48, O], [300, -8], [360, 52, O], [440, -8], [800, 0, S]), tail: t([0, 0], [220, 20], [440, -10], [800, 0, S]) }),
    slam: once(1100, {   // rears up on the back legs, front paws high, comes down with all its weight
      body: t([0, 0], [300, -26, O], [480, -30], [620, 8, I], [720, 3], [1100, 0, S]), head: t([0, 0], [300, -8, O], [480, -14], [620, 28, I], [720, 12], [900, -4], [1100, 0, S]),
      legFN: t([0, 0], [300, -70, O], [390, -50], [480, -84], [620, 16, I], [720, 6], [1100, 0, S]), legFF: t([0, 0], [300, -52, O], [390, -76], [480, -60], [620, 12, I], [1100, 0, S]),
      legBN: t([0, 0], [300, 24, O], [480, 28], [620, -8, I], [1100, 0, S]), legBF: t([0, 0], [300, 28, O], [480, 32], [620, -6, I], [1100, 0, S]), tail: t([0, 0], [300, -20, O], [620, 25, I], [1100, 0, S]) }),
    hit: once(380, { body: t([0, 0], [60, -7, O], [230, 2, S], [380, 0, S]), head: t([0, 0], [50, 8], [110, -28, O], [240, 8, S], [380, 0, S]), tail: t([0, 0], [60, 28, O], [380, 0, S]),
      legFN: t([0, 0], [60, 22, O], [380, 0, S]), legFF: t([0, 0], [60, 14, O], [380, 0, S]), legBN: t([0, 0], [60, -16, O], [380, 0, S]), legBF: t([0, 0], [60, -10, O], [380, 0, S]), eyes: t([0, 0, { sy: 1 }], [60, 0, { sy: .25, sx: 1.2 }], [260, 0, { sy: .25, sx: 1.2 }], [380, 0, { sy: 1 }]) }),
    dodge: once(520, { body: t([0, 0], [120, -8, O], [300, 5], [520, 0, S]), head: t([0, 0], [120, -14, O], [300, 8], [520, 0, S]), legFN: t([0, 0], [120, -40, { y: -2 }, O], [300, 8], [520, 0, S]), legFF: t([0, 0], [120, -30, { y: -2 }, O], [300, 6], [520, 0, S]),
      legBN: t([0, 0], [120, 36, { y: -2 }, O], [300, -6], [520, 0, S]), legBF: t([0, 0], [120, 28, { y: -2 }, O], [300, -4], [520, 0, S]), tail: t([0, 0], [120, 30, O], [520, 0, S]) }),
    ko: once(900, { body: t([0, 0], [900, 0]), head: t([0, 0], [120, -22, O], [500, -30], [900, -40, O]), tail: t([0, 0], [500, 30], [900, -20, O]),
      legFN: t([0, 0], [120, 20, O], [500, -70], [700, -92], [800, -78], [900, -84, O]), legFF: t([0, 0], [120, 14, O], [500, -60], [900, -70, O]), legBN: t([0, 0], [120, -20, O], [500, 60], [900, 72, O]), legBF: t([0, 0], [120, -14, O], [500, 52], [900, 60, O]),
      eyes: t([0, 0, { sy: 1 }], [200, 0, { sy: .2 }], [900, 0, { sy: .2 }]) }, 1),
    blink: BLINK,
    sniff: once(1500, { head: t([0, 0], [300, 24, S], [450, 19], [600, 26], [750, 20], [900, 26], [1100, 22], [1500, 0, S]), body: t([0, 0], [300, 3, S], [1100, 3], [1500, 0, S]), tail: t([0, 0], [300, 14], [1100, 14], [1500, 0, S]) }),
    scratch: once(1400, { legBN: t([0, 0], [250, -78, O], [350, -52], [450, -80], [550, -52], [650, -80], [750, -52], [850, -80], [1050, -70], [1400, 0, S]), body: t([0, 0], [250, -5, O], [1050, -5], [1400, 0, S]), head: t([0, 0], [250, -12, O], [450, -8], [650, -14], [850, -8], [1050, -12], [1400, 0, S]),
      eyes: t([0, 0, { sy: 1 }], [250, 0, { sy: .3 }], [1050, 0, { sy: .3 }], [1400, 0, { sy: 1 }]) }),
    paw: once(1300, { legFN: t([0, 0], [200, -40, O], [380, 30, I], [520, -40, O], [700, 30, I], [840, -40, O], [1020, 30, I], [1300, 0, S]), head: t([0, 0], [200, 16, O], [1020, 20], [1300, 0, S]), tail: t([0, 0], [200, 24], [1020, 24], [1300, 0, S]) }),
    wag: once(1200, { tail: wave(1200, 22, 0, { n: 12 }), body: wave(1200, 2, .5, { n: 12 }), head: t([0, 0], [300, -8, S], [900, -8], [1200, 0, S]) })
  };
  var TAIL = { k: 120, d: 8, g: .1, w: .4, max: 38, dir: [-.65, -.75] }, STUB = { k: 200, d: 10, g: .08, w: .2, max: 25, dir: [-1, -.3] };
  A['quad.canid'] = { attack: 'pounce', poses: QUAD, springs: { tail: TAIL }, fidgets: ['sniff', 'wag', 'scratch'] };
  A['quad.feline'] = { attack: 'pounce', poses: QUAD, springs: { tail: { k: 80, d: 6, g: .12, w: .5, max: 45, dir: [-.6, -.8] } }, fidgets: ['wag', 'scratch', 'sniff'] };
  A['quad.rodent'] = { attack: 'pounce', poses: QUAD, springs: { tail: { k: 80, d: 6, g: .12, w: .5, max: 45, dir: [-.6, -.8] } }, fidgets: ['sniff', 'scratch'] };
  A['quad.bear'] = { attack: 'charge', poses: QUAD, springs: { tail: STUB }, fidgets: ['sniff', 'paw', 'scratch'] };
  A['quad.ungulate'] = { attack: 'charge', poses: QUAD, springs: { tail: STUB }, fidgets: ['paw', 'sniff'] };
  A['quad.hare'] = { attack: 'hop', poses: QUAD, springs: { tail: STUB }, fidgets: ['sniff', 'scratch'] };

  /* ---------- birds (side view): body, wing (+r lifts it), tail, legB/legF, head (+eyes), neck on the long-legged ones ---------- */
  var FLAP = function (dur, n) { return wave(dur, 38, 0, { base: 26, n: n || 8 }); };
  var BIRD = {
    idle: loop(1500, { body: t([0, 0], [750, 0, { y: -.6 }, S], [1500, 0, S]), legB: t([0, 0], [750, 0, { y: .6 }, S], [1500, 0, S]), legF: t([0, 0], [750, 0, { y: .6 }, S], [1500, 0, S]),
      head: t([0, 0], [300, 0, { x: 1.2 }, O], [750, 3, { x: 1.2 }], [1050, 0, { x: 0 }, O], [1500, 0]), neck: t([0, 0], [750, 3, S], [1500, 0, S]), wing: t([0, 0], [750, 3, S], [1500, 0, S]) }),
    run: loop(360, { body: mix(wave(360, 4, 0), wave(360, 1.2, .25, { prop: 'y' })), legB: wave(360, 42, 0, { lift: 2 }), legF: wave(360, 42, .5, { lift: 2 }), head: wave(360, 2, .25, { prop: 'x', base: 1 }), neck: wave(360, 5, .3), wing: FLAP(360), tail: wave(360, 8, .2) }),
    peck: once(820, {   // two hops, wings out for balance, the head cocks back and stabs
      body: t([0, 0], [200, -8, O], [280, 4], [370, -10, O], [410, 14, I], [520, -4, O], [680, -8], [820, 0, S]), head: t([0, 0], [200, -10], [330, -30, O], [370, -34], [410, 44, I], [470, 30], [560, -12, O], [820, 0, S]), neck: t([0, 0], [330, -18, O], [410, 26, I], [560, -6], [820, 0, S]),
      wing: t([0, 0], [120, 50, O], [200, 10], [280, 55, O], [370, 30], [410, -10, I], [520, 60, O], [600, 5], [680, 60], [760, 10], [820, 0, S]),
      legB: t([0, 0], [200, 40, O], [280, 0], [370, 40, O], [440, 0], [680, 45, O], [820, 0, S]), legF: t([0, 0], [200, -40, O], [280, 0], [370, -40, O], [440, 0], [680, -35, O], [820, 0, S]), tail: t([0, 0], [410, -30, I], [520, 20], [820, 0, S]) }),
    swoop: once(950, {   // beats up, folds the wings to dive, talons forward at the hit, beats back out
      body: t([0, 0], [330, -6, O], [470, 10, I], [720, -6], [950, 0, S]), head: t([0, 0], [330, -12, O], [470, 20, I], [530, -10, O], [950, 0, S]), neck: t([0, 0], [330, -10], [470, 16, I], [950, 0, S]),
      wing: t([0, 0], [80, 62, O], [160, -12, I], [240, 66, O], [330, -6, I], [400, 72, O], [470, 16], [530, 70, O], [610, -10, I], [690, 66, O], [770, -10, I], [850, 50, O], [950, 0, S]),
      legB: t([0, 0], [330, 55, O], [470, -60, I], [530, -30], [950, 0, S]), legF: t([0, 0], [330, 45, O], [470, -72, I], [530, -40], [950, 0, S]), tail: t([0, 0], [330, 25], [470, -25, I], [950, 0, S]) }),
    hit: once(380, { body: t([0, 0], [60, -8, O], [380, 0, S]), head: t([0, 0], [50, 10], [110, -30, O], [240, 10, S], [380, 0, S]), neck: t([0, 0], [80, -18, O], [380, 0, S]), wing: t([0, 0], [60, 70, O], [200, 20], [290, 45], [380, 0, S]),
      legB: t([0, 0], [60, 20, O], [380, 0, S]), legF: t([0, 0], [60, -20, O], [380, 0, S]), eyes: t([0, 0, { sy: 1 }], [60, 0, { sy: .25, sx: 1.2 }], [260, 0, { sy: .25, sx: 1.2 }], [380, 0, { sy: 1 }]) }),
    dodge: once(520, { wing: t([0, 0], [70, 65, O], [140, -5, I], [210, 65, O], [280, -5, I], [360, 50], [520, 0, S]), legB: t([0, 0], [120, 50, O], [300, 10], [520, 0, S]), legF: t([0, 0], [120, 40, O], [300, 5], [520, 0, S]), head: t([0, 0], [120, -14, O], [520, 0, S]), body: t([0, 0], [120, -8, O], [520, 0, S]) }),
    ko: once(900, { head: t([0, 0], [120, -20, O], [500, 20], [900, 38, O]), neck: t([0, 0], [500, 14], [900, 24]), wing: t([0, 0], [120, 70, O], [500, 80], [900, 64, O]), legB: t([0, 0], [500, 60], [760, 88], [900, 78, O]), legF: t([0, 0], [500, -50], [760, -80], [900, -70, O]),
      eyes: t([0, 0, { sy: 1 }], [200, 0, { sy: .2 }], [900, 0, { sy: .2 }]) }, 1),
    blink: BLINK,
    preen: once(1500, { head: t([0, 0], [300, 55, { x: -3, y: 2 }, S], [450, 48, { x: -3, y: 2 }], [600, 58, { x: -3, y: 2 }], [750, 48, { x: -3, y: 2 }], [900, 58, { x: -3, y: 2 }], [1100, 50, { x: -3, y: 2 }], [1500, 0, S]),
      neck: t([0, 0], [300, 20, S], [1100, 20], [1500, 0, S]), wing: t([0, 0], [300, 22, S], [600, 30], [900, 22], [1100, 28], [1500, 0, S]) }),
    stretch: once(1300, { wing: t([0, 0], [350, 75, S], [800, 80], [900, 60], [1000, 78], [1300, 0, S]), legB: t([0, 0], [350, 30, S], [800, 34], [1300, 0, S]), head: t([0, 0], [350, -12, S], [800, -14], [1300, 0, S]), tail: t([0, 0], [350, 16], [800, 20], [1300, 0, S]) }),
    look: once(1400, { head: t([0, 0], [150, -16, O], [550, -16], [650, 12, O], [1050, 12], [1150, -6, O], [1400, 0, S]), neck: t([0, 0], [150, -8, O], [550, -8], [650, 6, O], [1050, 6], [1400, 0, S]) })
  };
  A.bird = { attack: 'peck', poses: BIRD, springs: { tail: { k: 160, d: 9, g: .08, w: .3, max: 30, dir: [-1, -.2] } }, fidgets: ['look', 'preen', 'stretch'] };

  /* ---------- crawling bugs (side view): body, [abdo], head (+eyes, antL/antR feelers), leg1-3, [wingB, wingF] ---------- */
  var FEEL = { k: 90, d: 5, g: .14, w: .4, max: 50, dir: [-.2, -1] };
  var BUG = {
    idle: loop(1400, { body: t([0, 0], [700, 0, { y: -.5 }, S], [1400, 0, S]), leg1: t([0, 0], [700, 0, { y: .5 }, S], [1400, 0, S]), leg2: t([0, 0], [700, 0, { y: .5 }, S], [1400, 0, S]), leg3: t([0, 0], [700, 0, { y: .5 }, S], [1400, 0, S]),
      head: t([0, 0], [800, 3, S], [1400, 0, S]), abdo: t([0, 0], [700, -4, S], [1400, 0, S]), antL: wave(1400, 7, 0, { n: 4 }), antR: wave(1400, 7, .3, { n: 4 }) }),
    run: loop(260, { body: mix(wave(260, 2, 0), wave(260, .8, .25, { prop: 'y' })), leg1: wave(260, 32, 0, { lift: 1.5 }), leg2: wave(260, 32, .5, { lift: 1.5 }), leg3: wave(260, 32, 0, { lift: 1.5 }), head: wave(260, 3, .2), abdo: wave(260, 5, .4),
      wingB: wave(260, 12, 0, { base: 8 }), wingF: wave(260, 12, .5, { base: 8 }) }),   // tripod gait: first and last leg together, the middle one opposite
    charge: once(900, {   // rears its head, feelers flat, scuttles in on blurred legs, butts
      body: t([0, 0], [200, -6, O], [430, 6, I], [480, 0], [900, 0, S]), head: t([0, 0], [200, -18, O], [320, -20], [430, 22, I], [480, -10, O], [900, 0, S]), abdo: t([0, 0], [200, 10, O], [430, -12, I], [900, 0, S]),
      leg1: [[0, {}]].concat(wave(520, 34, 0, { n: 16 }).map(function (q) { return [q[0] + 180, q[1]]; }), [[900, {}]]), leg2: [[0, {}]].concat(wave(520, 34, .5, { n: 16 }).map(function (q) { return [q[0] + 180, q[1]]; }), [[900, {}]]),
      leg3: [[0, {}]].concat(wave(520, 34, 0, { n: 16 }).map(function (q) { return [q[0] + 180, q[1]]; }), [[900, {}]]),
      antL: t([0, 0], [200, -35, O], [430, 30, I], [900, 0, S]), antR: t([0, 0], [200, -30, O], [430, 34, I], [900, 0, S]), wingB: t([0, 0], [200, 30, O], [430, 0], [900, 0]), wingF: t([0, 0], [200, 36, O], [430, 0], [900, 0]) }),
    hit: once(380, { body: t([0, 0], [60, -8, O], [380, 0, S]), head: t([0, 0], [110, -22, O], [240, 6, S], [380, 0, S]), abdo: t([0, 0], [60, 14, O], [380, 0, S]), leg1: t([0, 0], [60, 30, O], [380, 0, S]), leg2: t([0, 0], [60, -18, O], [380, 0, S]), leg3: t([0, 0], [60, -34, O], [380, 0, S]),
      eyes: t([0, 0, { sy: 1 }], [60, 0, { sy: .25, sx: 1.2 }], [260, 0, { sy: .25, sx: 1.2 }], [380, 0, { sy: 1 }]) }),
    dodge: once(520, { body: t([0, 0], [120, 8, O], [520, 0, S]), leg1: t([0, 0], [120, 40, O], [520, 0, S]), leg2: t([0, 0], [120, -30, O], [520, 0, S]), leg3: t([0, 0], [120, -45, O], [520, 0, S]), head: t([0, 0], [120, -12, O], [520, 0, S]) }),
    ko: once(900, { leg1: t([0, 0], [300, 50], [500, -30], [650, -62], [760, -44], [900, -56, O]), leg2: t([0, 0], [300, -40], [500, 20], [650, -8], [900, 6, O]), leg3: t([0, 0], [300, -50], [500, 30], [650, 60], [760, 44], [900, 54, O]),
      head: t([0, 0], [500, 16], [900, 26, O]), abdo: t([0, 0], [500, -14], [900, -20]), antL: t([0, 0], [500, 40], [900, 70, O]), antR: t([0, 0], [500, 50], [900, 84, O]), eyes: t([0, 0, { sy: 1 }], [200, 0, { sy: .2 }], [900, 0, { sy: .2 }]) }, 1),
    blink: BLINK,
    clean: once(1500, { head: t([0, 0], [250, 12, S], [1200, 12], [1500, 0, S]), leg3: t([0, 0], [250, -70, O], [400, -55], [550, -72], [700, -55], [850, -72], [1000, -55], [1200, -66], [1500, 0, S]),
      antR: t([0, 0], [250, 60, O], [400, 45], [550, 62], [700, 45], [850, 62], [1000, 45], [1200, 55], [1500, 0, S]), antL: t([0, 0], [250, 20], [1200, 20], [1500, 0, S]) }),
    wiggle: once(1100, { abdo: wave(1100, 12, 0, { n: 12 }), body: wave(1100, 3, .5, { n: 12 }), wingB: wave(1100, 16, 0, { n: 12, base: 10 }), wingF: wave(1100, 16, .5, { n: 12, base: 10 }) })
  };
  A.bug = { attack: 'charge', poses: BUG, springs: { 'ant*': FEEL }, fidgets: ['clean', 'wiggle'] };

  /* ---------- flying bugs (moth, wasp): they hover: the idle holds the body up and the wings never stop ---------- */
  function fly(big) {
    var beat = big ? 220 : 110, up = big ? 4 : 6;
    function wings(dur, lean) {   // moth: big paper wings fold and open; wasp: small wings blur
      var n = Math.max(1, Math.round(dur / beat)) * 4, o = {};
      if (big) { o.wingF = mix(wave(dur, 16, 0, { n: n, base: 6 }), wave(dur, .32, 0, { n: n, prop: 'sx', base: .7 })); o.wingH = mix(wave(dur, 12, .1, { n: n, base: 4 }), wave(dur, .3, .1, { n: n, prop: 'sx', base: .72 })); o.wingB = mix(wave(dur, -14, 0, { n: n }), wave(dur, .3, .5, { n: n, prop: 'sx', base: .72 })); }
      else { o.wingF = wave(dur, 34, 0, { n: n, base: 10 }); o.wingB = wave(dur, 34, .5, { n: n, base: 10 }); }
      return o;
    }
    function hover(dur, bob, r) { return mix(wave(dur, bob, 0, { prop: 'y', base: -up }), wave(dur, r || 0, .25)); }
    return {
      idle: loop(880, join(wings(880), { body: hover(880, 1.4, 2), leg1: wave(880, 8, .2), leg2: wave(880, 8, .4), leg3: wave(880, 8, .6), abdo: wave(880, 6, .3), head: wave(880, 3, .5), antL: wave(880, 6, 0), antR: wave(880, 6, .3) })),
      run: loop(440, join(wings(440), { body: mix(wave(440, 1.6, 0, { prop: 'y', base: -up }), wave(440, 2, .25, { base: 12 })), leg1: wave(440, 6, .2, { base: 25 }), leg2: wave(440, 6, .4, { base: 25 }), leg3: wave(440, 6, .6, { base: 25 }), abdo: wave(440, 5, .3, { base: 10 }) })),
      swoop: once(950, join(wings(950), {   // legs trail on the climb, the sting swings under and forward on the dive
        abdo: t([0, 0], [330, 20, O], [440, 10], [470, -62, I], [560, -30, O], [950, 0, S]), head: t([0, 0], [330, -12, O], [470, 18, I], [950, 0, S]),
        leg1: t([0, 0], [330, 40, O], [470, -30, I], [950, 0, S]), leg2: t([0, 0], [330, 40, O], [470, -40, I], [950, 0, S]), leg3: t([0, 0], [330, 40, O], [470, -50, I], [950, 0, S]) })),
      hit: once(380, { body: t([0, -6, { y: -up }], [60, -18, { y: -up - 2 }, O], [220, 6, { y: -up + 2 }, S], [380, 0, { y: -up }, S]), head: t([0, 0], [110, -22, O], [380, 0, S]), abdo: t([0, 0], [60, 24, O], [380, 0, S]),
        leg1: t([0, 0], [60, 30, O], [380, 0, S]), leg2: t([0, 0], [60, -24, O], [380, 0, S]), leg3: t([0, 0], [60, -36, O], [380, 0, S]), eyes: t([0, 0, { sy: 1 }], [60, 0, { sy: .25, sx: 1.2 }], [260, 0, { sy: .25, sx: 1.2 }], [380, 0, { sy: 1 }]) }),
      dodge: once(520, { body: t([0, 0, { y: -up }], [120, -14, { y: -up - 4 }, O], [300, 8, { y: -up + 1 }], [520, 0, { y: -up }, S]), abdo: t([0, 0], [120, 20, O], [520, 0, S]) }),
      ko: once(900, { wingF: t([0, 0], [120, 40, O], [500, -20], [900, -34, O]), wingB: t([0, 0], [120, 30, O], [500, -10], [900, -24, O]), wingH: t([0, 0], [500, -20], [900, -30, O]),
        leg1: t([0, 0], [500, -40], [900, -60, O]), leg2: t([0, 0], [500, 20], [900, 10, O]), leg3: t([0, 0], [500, 40], [900, 56, O]), abdo: t([0, 0], [500, -20], [900, -30]), head: t([0, 0], [500, 16], [900, 26, O]),
        antL: t([0, 0], [900, 70, O]), antR: t([0, 0], [900, 84, O]), eyes: t([0, 0, { sy: 1 }], [200, 0, { sy: .2 }], [900, 0, { sy: .2 }]) }, 1),
      blink: BLINK,
      rub: once(1200, { leg1: t([0, 0], [200, -50, O], [350, -30], [500, -52], [650, -30], [800, -52], [950, -30], [1200, 0, S]), leg2: t([0, 0], [200, 40, O], [350, 22], [500, 42], [650, 22], [800, 42], [950, 22], [1200, 0, S]), head: t([0, 0], [200, 10], [950, 10], [1200, 0, S]) }),
      dip: once(1100, { body: t([0, 0, { y: -up }], [300, 8, { y: -up + 3 }, S], [550, -8, { y: -up - 3 }, S], [800, 6, { y: -up + 2 }, S], [1100, 0, { y: -up }, S]), abdo: t([0, 0], [300, -14], [550, 14], [800, -8], [1100, 0, S]) })
    };
  }
  A['bug.moth'] = { attack: 'swoop', poses: fly(true), springs: { 'ant*': FEEL }, fidgets: ['dip', 'rub'] };
  A['bug.wasp'] = { attack: 'swoop', poses: fly(false), springs: { 'ant*': FEEL }, fidgets: ['rub', 'dip'] };

  /* ---------- worms and centipedes (side view): s1 (behind the head) .. sN (tail), a leg l1..lN under each, head (+eyes) on s1 ---------- */
  var SEG = ['s1', 's2', 's3', 's4', 's5', 's6', 's7'], LEG = ['l1', 'l2', 'l3', 'l4', 'l5', 'l6', 'l7'];
  function crawl(dur, amp, legAmp) {   // a wave runs from head to tail; the legs ripple one after another
    return join(each(SEG, function (i) { return wave(dur, i ? amp : amp * .4, -i * .16); }), each(LEG, function (i) { return wave(dur, legAmp, -i * .2, { lift: 1 }); }), { head: wave(dur, -amp * .8, .1) });
  }
  var WORM = {
    idle: loop(1700, crawl(1700, 3.5, 7)),
    run: loop(480, crawl(480, 9, 30)),
    strike: once(900, join(   // bunches up like a spring (every other joint folds), then snaps straight
      each(SEG, function (i) { var f = (i % 2 ? 1 : -1) * (i ? 20 : 8); return t([0, 0], [220, f, O], [370, f * 1.25], [430, -f * .25, I], [490, f * .2, O], [640, -f * .1], [900, 0, S]); }),
      each(LEG, function (i) { return t([0, 0], [220, 30, O], [370, 36], [430, -44, I], [640, 16], [900, 0, S]); }),
      { head: t([0, 0], [220, -26, O], [370, -32], [430, 30, I], [490, -12, O], [900, 0, S]), eyes: t([0, 0, { sy: 1, sx: 1 }], [220, 0, { sy: 1.25, sx: 1.25 }], [370, 0, { sy: 1.3, sx: 1.3 }], [430, 0, { sy: .6, sx: 1 }], [640, 0, { sy: 1, sx: 1 }], [900, 0, { sy: 1, sx: 1 }]) })),
    hit: once(380, join(each(SEG, function (i) { return t([0, 0], [60 + i * 14, (i % 2 ? -1 : 1) * 14, O], [380, 0, S]); }), { head: t([0, 0], [110, -26, O], [240, 8, S], [380, 0, S]), eyes: t([0, 0, { sy: 1 }], [60, 0, { sy: .25, sx: 1.2 }], [260, 0, { sy: .25, sx: 1.2 }], [380, 0, { sy: 1 }]) })),
    dodge: once(520, join(each(SEG, function (i) { return t([0, 0], [120, i ? -12 : -6, O], [300, i ? 6 : 2], [520, 0, S]); }), { head: t([0, 0], [120, -16, O], [520, 0, S]) })),
    ko: once(900, join(each(SEG, function (i) { return t([0, 0], [300, (i % 2 ? 10 : -10)], [900, i ? 6 : 0, O]); }), each(LEG, function (i) { return t([0, 0], [400 + i * 40, 40], [900, (i % 2 ? 60 : -60), O]); }),
      { head: t([0, 0], [120, -18, O], [900, 34, O]), eyes: t([0, 0, { sy: 1 }], [200, 0, { sy: .2 }], [900, 0, { sy: .2 }]) }), 1),
    blink: BLINK,
    peek: once(1600, { head: t([0, 0], [300, -26, S], [600, -30], [800, -8, S], [1000, -30, S], [1250, -26], [1600, 0, S]), s1: t([0, 0], [300, -10, S], [1250, -10], [1600, 0, S]), s2: t([0, 0], [300, -6, S], [1250, -6], [1600, 0, S]) }),
    ripple: once(1200, join(each(SEG, function (i) { return [[0, {}]].concat(wave(900, i ? 10 : 4, -i * .16, { n: 12 }).map(function (q) { return [q[0] + 150, q[1]]; }), [[1200, {}]]); }), each(LEG, function (i) { return [[0, {}]].concat(wave(900, 34, -i * .2, { n: 12 }).map(function (q) { return [q[0] + 150, q[1]]; }), [[1200, {}]]); })))
  };
  A.worm = { attack: 'strike', poses: WORM, springs: { 's[2-7]': { k: 150, d: 9, g: .05, w: .1, max: 22, dir: [-1, 0] } }, fidgets: ['peek', 'ripple'] };

  /* ---------- snakes, lizards, eels (side view): s1 (tail, on the ground) .. s6 (neck), head (+eyes, hood) ---------- */
  var SN = ['s2', 's3', 's4', 's5', 's6'];
  function sway(dur, amp) { return join(each(SN, function (i) { return wave(dur, amp * (.4 + i * .25), -i * .14); }), { head: wave(dur, -amp * 2.2, -.55) }); }   // the sway grows toward the head; the head stays level
  var SNAKE = {
    idle: loop(2200, sway(2200, 2.2)),
    run: loop(520, join(sway(520, 5), { s1: wave(520, 6, .2) })),
    strike: once(900, join(   // rears back and up, hood wide, eyes big; whips forward; recoils past rest and settles
      each(SN, function (i) { var f = 4 + i * 2.5; return t([0, 0], [220, -f, O], [370, -f * 1.3], [430, f * 1.5, I], [490, f * 1.1, O], [640, -f * .4, S], [780, f * .15], [900, 0, S]); }),
      { head: t([0, 0], [220, -10, O], [370, -16], [430, 30, I], [490, 10, O], [640, -8], [900, 0, S]), hood: t([0, 0, { sx: 1, sy: 1 }], [220, 0, { sx: 1.35, sy: 1.25 }, O], [370, 0, { sx: 1.45, sy: 1.3 }], [430, 0, { sx: .9, sy: 1 }, I], [640, 0, { sx: 1.1, sy: 1.05 }], [900, 0, { sx: 1, sy: 1 }, S]),
        eyes: t([0, 0, { sy: 1, sx: 1 }], [220, 0, { sy: 1.3, sx: 1.3 }], [370, 0, { sy: 1.35, sx: 1.35 }], [430, 0, { sy: .5, sx: 1 }], [640, 0, { sy: 1, sx: 1 }], [900, 0, { sy: 1, sx: 1 }]) })),
    hit: once(380, join(each(SN, function (i) { return t([0, 0], [60 + i * 12, -(5 + i * 2.5), O], [240, 3 + i, S], [380, 0, S]); }), { head: t([0, 0], [120, -20, O], [260, 8, S], [380, 0, S]), eyes: t([0, 0, { sy: 1 }], [60, 0, { sy: .25, sx: 1.2 }], [260, 0, { sy: .25, sx: 1.2 }], [380, 0, { sy: 1 }]) })),
    dodge: once(520, join(each(SN, function (i) { return t([0, 0], [120, -(3 + i * 3), O], [300, 2 + i, S], [520, 0, S]); }), { head: t([0, 0], [120, 16, O], [520, 0, S]) })),
    ko: once(900, join(each(SN, function (i) { return t([0, 0], [120, -(3 + i * 2), O], [500, 6 + i * 3, I], [900, 8 + i * 4, O]); }), { head: t([0, 0], [500, 20], [900, 32, O]), hood: t([0, 0, { sx: 1 }], [900, 0, { sx: .7 }]), eyes: t([0, 0, { sy: 1 }], [200, 0, { sy: .2 }], [900, 0, { sy: .2 }]) }), 1),
    blink: BLINK,
    hypno: once(2000, join(each(SN, function (i) { return [[0, {}]].concat(wave(1600, 3 + i * 2.4, -i * .1, { n: 16 }).map(function (q) { return [q[0] + 200, q[1]]; }), [[2000, {}]]); }), { hood: t([0, 0, { sx: 1 }], [300, 0, { sx: 1.3 }, S], [1700, 0, { sx: 1.3 }], [2000, 0, { sx: 1 }, S]) })),
    taste: once(1100, { head: t([0, 0], [200, 14, O], [320, 6], [440, 16], [560, 6], [680, 16], [800, 8], [1100, 0, S]), s6: t([0, 0], [200, 8, O], [800, 8], [1100, 0, S]) })
  };
  A.snake = { attack: 'strike', poses: SNAKE, springs: { 's[4-6]': { k: 170, d: 10, g: .04, w: .08, max: 16, dir: [.4, -1] } }, fidgets: ['taste', 'hypno'] };

  /* ---------- snails, turtles, clams (side view): body (foot), shell, head (+eyes, antL/antR eye stalks). Shy: the head goes into the shell ---------- */
  var HIDE = { x: -7, sx: .35, sy: .8 };
  var SNAIL = {
    idle: loop(2400, { head: t([0, 0], [1200, 4, { y: -.5 }, S], [2400, 0, S]), shell: t([0, 0], [1200, -2, S], [2400, 0, S]), antL: wave(2400, 8, 0, { n: 4 }), antR: wave(2400, 8, .35, { n: 4 }) }),
    run: loop(900, { body: wave(900, .07, 0, { prop: 'sx', base: 1 }), head: mix(wave(900, 1.6, 0, { prop: 'x' }), wave(900, 4, .2)), shell: wave(900, 5, .3), antL: wave(900, 10, .1), antR: wave(900, 10, .4) }),
    charge: once(900, {   // ducks into the shell, rolls in shell first, pops back out
      head: t([0, 0], [200, 0, HIDE, O], [430, 0, HIDE], [520, 0, { x: 2, sx: 1.15, sy: 1.05 }, O], [700, 6], [900, 0, S]), shell: t([0, 0], [200, -8, O], [320, -10], [430, 30, I], [480, 16, O], [700, -4], [900, 0, S]),
      body: t([0, 0, { sx: 1 }], [200, 0, { sx: .9 }, O], [430, 0, { sx: 1.12 }, I], [900, 0, { sx: 1 }, S]), antL: t([0, 0, { sy: 1 }], [200, 0, { sy: .3 }], [430, 0, { sy: .3 }], [560, 0, { sy: 1.2 }, O], [900, 0, { sy: 1 }]), antR: t([0, 0, { sy: 1 }], [200, 0, { sy: .3 }], [430, 0, { sy: .3 }], [600, 0, { sy: 1.2 }, O], [900, 0, { sy: 1 }]) }),
    hit: once(380, { head: t([0, 0], [60, 0, HIDE, O], [240, 0, HIDE], [380, 0, S]), shell: t([0, 0], [60, -12, O], [220, 5, S], [380, 0, S]), antL: t([0, 0, { sy: 1 }], [60, 0, { sy: .3 }], [240, 0, { sy: .3 }], [380, 0, { sy: 1 }]), antR: t([0, 0, { sy: 1 }], [60, 0, { sy: .3 }], [260, 0, { sy: .3 }], [380, 0, { sy: 1 }]) }),
    dodge: once(520, { head: t([0, 0], [100, 0, HIDE, O], [360, 0, HIDE], [520, 0, S]), shell: t([0, 0], [120, 8, O], [520, 0, S]) }),
    ko: once(900, { head: t([0, 0], [200, 0, HIDE, O], [900, 0, { x: -9, sx: .2, sy: .7 }]), shell: t([0, 0], [300, -14, O], [600, 8], [900, 0, S]), antL: t([0, 0, { sy: 1 }], [200, 0, { sy: .2 }], [900, 0, { sy: .2 }]), antR: t([0, 0, { sy: 1 }], [200, 0, { sy: .2 }], [900, 0, { sy: .2 }]) }, 1),
    blink: BLINK,
    shy: once(2000, { head: t([0, 0], [250, 0, HIDE, O], [1000, 0, HIDE], [1300, 0, { x: -3, sx: .7 }, S], [1500, 0, { x: -3, sx: .7 }], [2000, 0, S]), antL: t([0, 0, { sy: 1 }], [250, 0, { sy: .3 }], [1300, 0, { sy: .3 }], [1500, 0, { sy: 1 }], [2000, 0, { sy: 1 }]), antR: t([0, 0, { sy: 1 }], [250, 0, { sy: .3 }], [1500, 0, { sy: .3 }], [1750, 0, { sy: 1 }], [2000, 0, { sy: 1 }]) }),
    stalks: once(1400, { antL: t([0, 0, { sy: 1 }], [250, -14, { sy: .5 }, S], [500, 0, { sy: 1.15 }, S], [900, 0, { sy: 1 }], [1400, 0, { sy: 1 }]), antR: t([0, 0, { sy: 1 }], [500, 0, { sy: 1 }], [750, 14, { sy: .5 }, S], [1000, 0, { sy: 1.15 }, S], [1400, 0, { sy: 1 }]), head: t([0, 0], [500, -6, S], [1000, 6, S], [1400, 0, S]) })
  };
  A.snail = { attack: 'charge', poses: SNAIL, springs: { 'ant*': { k: 100, d: 6, g: .12, w: .3, max: 45, dir: [.15, -1] } }, fidgets: ['stalks', 'shy'] };

  /* ---------- crabs and scorpions (front view): body, leg1-4 (1, 2 on the left), clawL/clawR (+r lifts the left claw, -r the right), eyeL/eyeR on stalks, [shell], [tail = scorpion sting] ---------- */
  var CL = ['leg1', 'leg2', 'leg3', 'leg4'];
  var CRAB = {
    idle: loop(1500, join({ body: t([0, 0], [750, 0, { y: -.6 }, S], [1500, 0, S]), clawL: t([0, 0], [750, 6, S], [1500, 0, S]), clawR: t([0, 0], [900, -6, S], [1500, 0, S]), tail: wave(1500, 5, 0, { n: 4 }), shell: t([0, 0], [750, -2, S], [1500, 0, S]) },
      each(CL, function () { return t([0, 0], [750, 0, { y: .6 }, S], [1500, 0, S]); }))),
    run: loop(320, join({ body: mix(wave(320, 1, 0, { prop: 'x' }), wave(320, .8, .25, { prop: 'y' })), clawL: wave(320, 8, 0, { base: 18 }), clawR: wave(320, 8, .5, { base: -18 }), tail: wave(320, 8, .2) },
      each(CL, function (i) { return wave(320, i < 2 ? 22 : -22, i % 2 ? .5 : 0, { lift: 1.5 }); }))),
    pounce: once(850, {   // claws high and wide, a snap from both sides; the scorpion's tail cocks back and stabs over its head
      body: t([0, 0], [220, -4, O], [410, 4, I], [850, 0, S]), clawL: t([0, 0], [220, 46, O], [330, 52], [410, -26, I], [470, -34, O], [600, 10], [850, 0, S]), clawR: t([0, 0], [220, -46, O], [330, -52], [410, 26, I], [470, 34, O], [600, -10], [850, 0, S]),
      tail: t([0, 0], [220, -28, O], [330, -34], [410, 62, I], [470, 48, O], [650, -8], [850, 0, S]), eyeL: t([0, 0, { sy: 1 }], [220, -8, { sy: 1.2 }, O], [410, 6, { sy: .8 }], [850, 0, { sy: 1 }, S]), eyeR: t([0, 0, { sy: 1 }], [220, 8, { sy: 1.2 }, O], [410, -6, { sy: .8 }], [850, 0, { sy: 1 }, S]),
      leg1: t([0, 0], [220, 14], [330, -20], [410, 10], [850, 0, S]), leg2: t([0, 0], [220, 10], [330, -14], [410, 8], [850, 0, S]), leg3: t([0, 0], [220, -10], [330, 14], [410, -8], [850, 0, S]), leg4: t([0, 0], [220, -14], [330, 20], [410, -10], [850, 0, S]) }),
    hit: once(380, { body: t([0, 0], [60, -6, O], [380, 0, S]), clawL: t([0, 0], [60, -24, O], [220, 8], [380, 0, S]), clawR: t([0, 0], [60, 24, O], [220, -8], [380, 0, S]), tail: t([0, 0], [60, -30, O], [380, 0, S]),
      eyeL: t([0, 0, { sy: 1 }], [60, -14, { sy: .5 }, O], [240, 0, { sy: 1.15 }], [380, 0, { sy: 1 }]), eyeR: t([0, 0, { sy: 1 }], [60, 14, { sy: .5 }, O], [260, 0, { sy: 1.15 }], [380, 0, { sy: 1 }]) }),
    dodge: once(520, join({ clawL: t([0, 0], [120, 36, O], [520, 0, S]), clawR: t([0, 0], [120, -36, O], [520, 0, S]), tail: t([0, 0], [120, -24, O], [520, 0, S]) }, each(CL, function (i) { return t([0, 0], [120, i < 2 ? 26 : -26, { y: -2 }, O], [300, 0], [520, 0, S]); }))),
    ko: once(900, join({ clawL: t([0, 0], [120, 30, O], [500, -45], [900, -58, O]), clawR: t([0, 0], [120, -30, O], [500, 45], [900, 58, O]), tail: t([0, 0], [500, -40], [900, -70, O]),
      eyeL: t([0, 0, { sy: 1 }], [500, -30, { sy: .7 }], [900, -44, { sy: .6 }, O]), eyeR: t([0, 0, { sy: 1 }], [500, 30, { sy: .7 }], [900, 44, { sy: .6 }, O]) }, each(CL, function (i) { return t([0, 0], [500, i < 2 ? 30 : -30], [900, i < 2 ? 46 : -46, O]); })), 1),
    blink: BLINK2,
    snap: once(1200, { clawL: t([0, 0], [200, 34, O], [300, 18, I], [400, 36, O], [500, 18, I], [700, 0, S], [1200, 0]), clawR: t([0, 0], [500, 0], [700, -34, O], [800, -18, I], [900, -36, O], [1000, -18, I], [1200, 0, S]),
      eyeL: t([0, 0], [200, -10], [500, -10], [700, 0], [1200, 0]), eyeR: t([0, 0], [500, 0], [700, 10], [1000, 10], [1200, 0]) }),
    sidle: once(1300, join({ body: t([0, 0], [325, 0, { x: -3 }, S], [975, 0, { x: 3 }, S], [1300, 0, S]) }, each(CL, function (i) { return [[0, {}]].concat(wave(1040, i < 2 ? 18 : -18, i % 2 ? .5 : 0, { n: 16, lift: 1 }).map(function (q) { return [q[0] + 130, q[1]]; }), [[1300, {}]]); })))
  };
  A.crab = { attack: 'pounce', poses: CRAB, springs: { 'eye*': { k: 130, d: 7, g: .1, w: .25, max: 30, dir: [0, -1] }, tail: { k: 140, d: 8, g: .06, w: .2, max: 25, dir: [-.2, -1] } }, fidgets: ['snap', 'sidle'] };

  /* ---------- frogs and toads (front view): body (squashes from the ground), footL/footR, eyeL/eyeR bumps ---------- */
  function jelly(dur, a) { return t([0, 0, { sx: 1, sy: 1 }], [dur * .16, 0, { sx: 1 + a, sy: 1 - a }, O], [dur * .42, 0, { sx: 1 - a * .6, sy: 1 + a * .6 }, S], [dur * .66, 0, { sx: 1 + a * .3, sy: 1 - a * .3 }, S], [dur * .84, 0, { sx: 1 - a * .12, sy: 1 + a * .12 }, S], [dur, 0, { sx: 1, sy: 1 }, S]); }
  var FROG = {
    idle: loop(1700, { body: t([0, 0, { sx: 1, sy: 1 }], [850, 0, { sx: 1.03, sy: 1.04 }, S], [1700, 0, { sx: 1, sy: 1 }, S]), eyeL: t([0, 0], [850, 0, { y: -.5 }, S], [1700, 0, S]), eyeR: t([0, 0], [950, 0, { y: -.5 }, S], [1700, 0, S]) }),
    run: loop(440, { body: t([0, 0, { sx: 1.1, sy: .86 }], [150, 0, { sx: .92, sy: 1.14, y: -3 }, O], [300, 0, { sx: .96, sy: 1.08, y: -1 }, I], [440, 0, { sx: 1.1, sy: .86 }, O]), footL: t([0, 0], [150, 40, { y: -2 }, O], [300, 10], [440, 0]), footR: t([0, 0], [150, -40, { y: -2 }, O], [300, -10], [440, 0]),
      eyeL: t([0, 0], [150, 0, { y: -2 }], [300, 0, { y: 1 }], [440, 0]), eyeR: t([0, 0], [150, 0, { y: -2 }], [300, 0, { y: 1 }], [440, 0]) }),
    hop: once(800, {   // gathers (wide and low), two leaps with the legs trailing, a wobble on landing
      body: t([0, 0, { sx: 1, sy: 1 }], [120, 0, { sx: 1.16, sy: .78 }, O], [220, 0, { sx: .88, sy: 1.2 }, O], [300, 0, { sx: 1.14, sy: .82 }, I], [360, 0, { sx: .88, sy: 1.2 }, O], [440, 0, { sx: 1.2, sy: .74 }, I], [560, 0, { sx: .94, sy: 1.1 }, S], [680, 0, { sx: 1.04, sy: .96 }, S], [800, 0, { sx: 1, sy: 1 }, S]),
      footL: t([0, 0], [120, -10], [220, 50, { y: 2 }, O], [300, 0], [360, 50, { y: 2 }, O], [440, -10], [800, 0, S]), footR: t([0, 0], [120, 10], [220, -50, { y: 2 }, O], [300, 0], [360, -50, { y: 2 }, O], [440, 10], [800, 0, S]),
      eyeL: t([0, 0], [120, 0, { y: 2 }, O], [220, 0, { y: -3 }, O], [360, 0, { y: -2 }], [440, 0, { y: 3 }, I], [560, 0, { y: -1 }], [800, 0, S]), eyeR: t([0, 0], [120, 0, { y: 2 }, O], [220, 0, { y: -3 }, O], [360, 0, { y: -2 }], [440, 0, { y: 3 }, I], [600, 0, { y: -1 }], [800, 0, S]) }),
    hit: once(380, { body: jelly(380, .2), eyeL: t([0, 0, { sy: 1 }], [60, -16, { y: 2, sy: .4 }, O], [240, 0, { sy: 1.1 }], [380, 0, { sy: 1 }, S]), eyeR: t([0, 0, { sy: 1 }], [60, 16, { y: 2, sy: .4 }, O], [260, 0, { sy: 1.1 }], [380, 0, { sy: 1 }, S]) }),
    dodge: once(520, { body: t([0, 0, { sx: 1, sy: 1 }], [120, 0, { sx: .86, sy: 1.2 }, O], [300, 0, { sx: 1.14, sy: .84 }, I], [420, 0, { sx: .97, sy: 1.04 }], [520, 0, { sx: 1, sy: 1 }, S]), footL: t([0, 0], [120, 40, O], [300, 0], [520, 0]), footR: t([0, 0], [120, -40, O], [300, 0], [520, 0]),
      eyeL: t([0, 0], [120, 0, { y: -3 }, O], [520, 0, S]), eyeR: t([0, 0], [120, 0, { y: -3 }, O], [520, 0, S]) }),
    ko: once(900, { body: t([0, 0, { sx: 1, sy: 1 }], [120, 0, { sx: .9, sy: 1.15 }, O], [500, 0, { sx: 1.25, sy: .6 }, I], [650, 0, { sx: 1.15, sy: .72 }], [900, 0, { sx: 1.22, sy: .62 }, O]), footL: t([0, 0], [500, -40], [900, -60, O]), footR: t([0, 0], [500, 40], [900, 60, O]),
      eyeL: t([0, 0, { sy: 1 }], [500, 30, { y: 3, sy: .5 }], [900, 40, { y: 4, sy: .4 }, O]), eyeR: t([0, 0, { sy: 1 }], [500, -30, { y: 3, sy: .5 }], [900, -40, { y: 4, sy: .4 }, O]) }, 1),
    blink: BLINK2,
    croak: once(1300, { body: t([0, 0, { sx: 1, sy: 1 }], [200, 0, { sx: 1.18, sy: 1.1 }, O], [420, 0, { sx: .98, sy: .98 }, I], [650, 0, { sx: 1.22, sy: 1.12 }, O], [900, 0, { sx: .97, sy: .97 }, I], [1300, 0, { sx: 1, sy: 1 }, S]),
      eyeL: t([0, 0], [200, 0, { y: -2 }, O], [420, 0], [650, 0, { y: -2.5 }, O], [900, 0], [1300, 0]), eyeR: t([0, 0], [200, 0, { y: -2 }, O], [420, 0], [650, 0, { y: -2.5 }, O], [900, 0], [1300, 0]) }),
    eyes: once(1300, { eyeL: t([0, 0, { sy: 1 }], [250, 0, { y: 2, sy: .5 }, S], [550, 0, { y: -2, sy: 1.2 }, S], [900, 0, { sy: 1 }], [1300, 0, { sy: 1 }]), eyeR: t([0, 0, { sy: 1 }], [400, 0, { sy: 1 }], [650, 0, { y: 2, sy: .5 }, S], [950, 0, { y: -2, sy: 1.2 }, S], [1300, 0, { sy: 1 }, S]) })
  };
  A.frog = { attack: 'hop', poses: FROG, fidgets: ['croak', 'eyes'] };

  /* ---------- spiders (side view): body (abdomen), head (+eyes), leg1-4 (1, 2 behind; 3, 4 in front) ---------- */
  var SP = ['leg1', 'leg2', 'leg3', 'leg4'];
  var SPIDER = {
    idle: loop(1300, join({ body: t([0, 0], [650, -3, { y: -.6 }, S], [1300, 0, S]), head: t([0, 0], [750, 3, S], [1300, 0, S]) }, each(SP, function (i) { return t([0, 0], [650, i < 2 ? -2 : 2, { y: .6 }, S], [1300, 0, S]); }))),
    run: loop(220, join({ body: mix(wave(220, 5, 0), wave(220, .8, .25, { prop: 'y' })), head: wave(220, -4, .2) }, each(SP, function (i) { return wave(220, 24, i % 2 ? .5 : 0, { lift: 1.5 }); }))),
    pounce: once(850, {   // rears: front legs high and wide, drops on the foe
      body: t([0, 0], [220, -22, O], [330, -26], [410, 14, I], [470, 6], [850, 0, S]), head: t([0, 0], [220, -10, O], [410, 20, I], [470, -6, O], [850, 0, S]),
      leg4: t([0, 0], [220, -58, O], [275, -44], [330, -62], [410, 22, I], [470, 8], [850, 0, S]), leg3: t([0, 0], [220, -40, O], [275, -56], [330, -42], [410, 16, I], [470, 6], [850, 0, S]),
      leg2: t([0, 0], [220, 18, O], [410, -12, I], [850, 0, S]), leg1: t([0, 0], [220, 24, O], [410, -16, I], [850, 0, S]), eyes: t([0, 0, { sy: 1, sx: 1 }], [220, 0, { sy: 1.3, sx: 1.3 }], [410, 0, { sy: .6, sx: 1 }], [850, 0, { sy: 1, sx: 1 }, S]) }),
    hit: once(380, join({ body: t([0, 0], [60, -12, O], [220, 4, S], [380, 0, S]), head: t([0, 0], [110, -20, O], [380, 0, S]), eyes: t([0, 0, { sy: 1 }], [60, 0, { sy: .25, sx: 1.2 }], [260, 0, { sy: .25, sx: 1.2 }], [380, 0, { sy: 1 }]) }, each(SP, function (i) { return t([0, 0], [60, i < 2 ? 22 : -22, O], [380, 0, S]); }))),
    dodge: once(520, join({ body: t([0, 0], [120, 10, O], [520, 0, S]) }, each(SP, function (i) { return t([0, 0], [120, i < 2 ? -30 : 30, { y: -2 }, O], [300, 0], [520, 0, S]); }))),
    ko: once(900, join({ body: t([0, 0], [900, 0]), head: t([0, 0], [500, 14], [900, 22, O]), eyes: t([0, 0, { sy: 1 }], [200, 0, { sy: .2 }], [900, 0, { sy: .2 }]) }, each(SP, function (i) { var f = i < 2 ? -1 : 1; return t([0, 0], [300, -f * 20, O], [600, f * 36], [760, f * 26], [900, f * 34, O]); })), 1),
    blink: BLINK,
    tap: once(1200, { leg4: t([0, 0], [200, -40, O], [300, 0, I], [400, -40, O], [500, 0, I], [600, -40, O], [700, 0, I], [1200, 0]), head: t([0, 0], [200, 8], [700, 8], [1200, 0, S]) }),
    bob: once(1100, { body: wave(1100, 8, 0, { n: 12 }), head: wave(1100, -5, .1, { n: 12 }) })
  };
  A.spider = { attack: 'pounce', poses: SPIDER, fidgets: ['tap', 'bob'] };

  /* ---------- golems (front view, two legs): legL/legR, body, armL/armR (+r lifts the left arm out, -r the right), head (+eyes). Heavy: slow in, sudden stop ---------- */
  var GOLEM = {
    idle: loop(2600, { body: t([0, 0], [1300, 0, { y: -.8 }, S], [2600, 0, S]), head: t([0, 0], [1500, 0, { y: -.5 }, S], [2600, 0, S]), armL: t([0, 0], [1300, 3, S], [2600, 0, S]), armR: t([0, 0], [1300, -3, S], [2600, 0, S]) }),
    run: loop(760, { legL: t([0, 0], [190, 0, { y: -3 }, O], [380, 0, I], [760, 0]), legR: t([0, 0], [380, 0], [570, 0, { y: -3 }, O], [760, 0, I]), body: t([0, 5, { y: 0 }], [190, 6, { y: -1.5 }, O], [380, -5, { y: 0 }, I], [570, -6, { y: -1.5 }, O], [760, 5, { y: 0 }, I]),
      head: t([0, -3], [380, 3, S], [760, -3, S]), armL: t([0, 16], [380, -6, S], [760, 16, S]), armR: t([0, 6], [380, -16, S], [760, 6, S]) }),
    smash: once(1150, {   // two stomps, both fists up and back (it leans away), down like a hammer, the head jolts; a slow straighten
      legL: t([0, 0], [100, 0, { y: -3 }, O], [200, 0, I], [1150, 0]), legR: t([0, 0], [200, 0], [300, 0, { y: -3 }, O], [400, 0, I], [1150, 0]),
      body: t([0, 0], [200, 5], [400, -5], [540, 0, { y: -2 }, O], [640, 0, { y: 2 }, I], [740, 0, { y: 1 }], [900, 0, S], [1150, 0, S]), head: t([0, 0], [540, 0, { y: -1 }, O], [640, 8, { y: 2 }, I], [700, -5, { y: -1 }, O], [800, 3], [1150, 0, S]),
      armL: t([0, 0], [400, 40, S], [540, 168, O], [600, 172], [640, 14, I], [700, -10, O], [900, 8], [1150, 0, S]), armR: t([0, 0], [400, -40, S], [540, -168, O], [600, -172], [640, -14, I], [700, 10, O], [900, -8], [1150, 0, S]),
      eyes: t([0, 0, { sy: 1 }], [540, 0, { sy: 1.3 }], [640, 0, { sy: .4 }], [800, 0, { sy: 1 }], [1150, 0, { sy: 1 }]) }),
    hit: once(380, { body: t([0, 0], [60, -6, O], [220, 2, S], [380, 0, S]), head: t([0, 0], [60, -12, { y: -2 }, O], [200, 6, { y: 1 }, I], [290, -2], [380, 0, S]), armL: t([0, 0], [60, 44, O], [240, -6, I], [380, 0, S]), armR: t([0, 0], [60, -44, O], [240, 6, I], [380, 0, S]),
      eyes: t([0, 0, { sy: 1 }], [60, 0, { sy: .25, sx: 1.2 }], [260, 0, { sy: .25, sx: 1.2 }], [380, 0, { sy: 1 }]) }),
    dodge: once(520, { body: t([0, 0], [120, -10, O], [300, 4], [520, 0, S]), head: t([0, 0], [120, 12, O], [300, -4], [520, 0, S]), armL: t([0, 0], [120, 60, O], [520, 0, S]), armR: t([0, 0], [120, -30, O], [520, 0, S]), legL: t([0, 0], [120, 0, { y: -3 }, O], [300, 0], [520, 0]) }),
    ko: once(900, {   // comes apart: the arms drop, the head slides off its shoulders
      head: t([0, 0], [120, -8, { y: -2 }, O], [500, 20, { y: 3, x: 3 }, I], [700, 34, { y: 9, x: 7 }, I], [780, 28, { y: 8, x: 7 }], [900, 32, { y: 9, x: 7 }]), armL: t([0, 0], [120, 50, O], [500, -8, I], [600, 6], [900, -4, O]), armR: t([0, 0], [120, -50, O], [560, 8, I], [660, -6], [900, 4, O]),
      body: t([0, 0], [500, 4, { y: 1 }], [900, 6, { y: 2 }, O]), eyes: t([0, 0, { sy: 1 }], [200, 0, { sy: .2 }], [900, 0, { sy: .2 }]) }, 1),
    blink: BLINK,
    headspin: once(1700, { head: t([0, 0], [250, -20, S], [1250, 380, S], [1450, 355, S], [1700, 360, S]), eyes: t([0, 0, { sx: 1 }], [250, 0, { sx: 1.2 }], [1250, 0, { sx: 1.2 }], [1700, 0, { sx: 1 }]) }),
    shrug: once(1300, { armL: t([0, 0], [300, 34, O], [800, 34], [1300, 0, S]), armR: t([0, 0], [300, -34, O], [800, -34], [1300, 0, S]), head: t([0, 0], [300, 8, { y: 1.5 }, O], [800, 8, { y: 1.5 }], [1300, 0, S]), body: t([0, 0], [300, 0, { y: -1 }, O], [800, 0, { y: -1 }], [1300, 0, S]) })
  };
  A.golem = { attack: 'smash', poses: GOLEM, fidgets: ['shrug', 'headspin'] };

  /* ---------- wisps (a flame): body (the flame, licks from its base), core (face, +eyes), base ---------- */
  function lick(dur, a, lean) { return mix(mix(wave(dur, a, 0, { prop: 'sy', base: 1 }), wave(dur, -a * .5, 0, { prop: 'sx', base: 1 })), wave(dur, 3, .3, { base: lean || 0 })); }
  var WISP = {
    idle: loop(620, { body: lick(620, .07), core: wave(620, .7, .2, { prop: 'y' }), base: wave(620, .05, .5, { prop: 'sx', base: 1 }) }),
    run: loop(360, { body: lick(360, .1, 14), core: wave(360, 1, .2, { prop: 'y' }) }),
    swoop: once(950, { body: t([0, 0, { sx: 1, sy: 1 }], [160, 0, { sx: 1.2, sy: .7 }, O], [330, -10, { sx: .8, sy: 1.4 }, O], [470, 24, { sx: .7, sy: 1.6 }, I], [530, 0, { sx: 1.4, sy: .7 }, O], [720, -8, { sx: .9, sy: 1.2 }], [950, 0, { sx: 1, sy: 1 }, S]),
      core: t([0, 0], [330, 0, { y: -1 }], [470, 0, { y: 2 }, I], [950, 0, S]), eyes: t([0, 0, { sy: 1, sx: 1 }], [330, 0, { sy: 1.3, sx: 1.3 }], [470, 0, { sy: .5, sx: 1 }], [950, 0, { sy: 1, sx: 1 }, S]), base: t([0, 0, { sx: 1 }], [160, 0, { sx: 1.3 }], [330, 0, { sx: .7 }], [950, 0, { sx: 1 }, S]) }),
    hit: once(380, { body: t([0, 0, { sx: 1, sy: 1 }], [60, -14, { sx: 1.35, sy: .55 }, O], [200, 6, { sx: .8, sy: 1.35 }, S], [300, 0, { sx: 1.08, sy: .94 }], [380, 0, { sx: 1, sy: 1 }, S]), eyes: t([0, 0, { sy: 1 }], [60, 0, { sy: .25, sx: 1.2 }], [260, 0, { sy: .25, sx: 1.2 }], [380, 0, { sy: 1 }]) }),
    dodge: once(520, { body: t([0, 0, { sx: 1, sy: 1 }], [120, -22, { sx: .8, sy: 1.25 }, O], [300, 10, { sx: 1.1, sy: .9 }], [520, 0, { sx: 1, sy: 1 }, S]) }),
    ko: once(900, { body: t([0, 0, { sx: 1, sy: 1 }], [120, 0, { sx: .8, sy: 1.3 }, O], [400, 0, { sx: 1.1, sy: .5 }, I], [520, 0, { sx: .8, sy: .8 }], [700, 0, { sx: .7, sy: .3 }, I], [900, 0, { sx: .5, sy: .12 }]), core: t([0, 0, { sx: 1, sy: 1 }], [400, 0, { y: 4, sx: .9, sy: .8 }], [900, 0, { y: 9, sx: .5, sy: .4 }]),
      eyes: t([0, 0, { sy: 1 }], [200, 0, { sy: .2 }], [900, 0, { sy: .2 }]) }, 1),
    blink: BLINK,
    flare: once(1000, { body: t([0, 0, { sx: 1, sy: 1 }], [200, 0, { sx: 1.15, sy: .8 }, O], [380, 0, { sx: .85, sy: 1.5 }, O], [560, 0, { sx: 1.1, sy: .9 }, I], [760, 0, { sx: .95, sy: 1.1 }], [1000, 0, { sx: 1, sy: 1 }, S]), base: t([0, 0, { sx: 1 }], [380, 0, { sx: 1.4 }, O], [1000, 0, { sx: 1 }, S]) }),
    waver: once(1200, { body: wave(1200, 14, 0, { n: 12 }), core: wave(1200, 1.2, .1, { n: 12, prop: 'x' }) })
  };
  A.wisp = { attack: 'swoop', poses: WISP, fidgets: ['flare', 'waver'] };

  /* ---------- octopuses (front view): body (head), eyes, t1..t7 arms (t1 left .. t7 right): springs, so they trail whatever the head does ---------- */
  var TN = ['t1', 't2', 't3', 't4', 't5', 't6', 't7'];
  var OCTO = {
    idle: loop(1900, join({ body: mix(wave(1900, 1.2, 0, { prop: 'y', base: -1 }), wave(1900, .03, .25, { prop: 'sy', base: 1 })) }, each(TN, function (i) { return wave(1900, 9, -i * .13); }))),
    run: loop(560, join({ body: mix(wave(560, 1.5, 0, { prop: 'y', base: -2 }), wave(560, .09, .25, { prop: 'sy', base: 1 })) }, each(TN, function (i) { return wave(560, (i - 3) * -7 - 4, 0); }))),   // jet: the arms close and open together
    slam: once(1100, join({   // rises, three arms curl up high on the foe's side, whip down one after another
      body: t([0, 0, { sy: 1 }], [300, -6, { y: -3, sy: 1.08 }, O], [480, -8, { y: -4, sy: 1.1 }], [620, 8, { y: 1, sy: .9 }, I], [720, 3, { sy: .96 }], [1100, 0, { sy: 1 }, S]),
      t7: t([0, 0], [300, -95, O], [480, -110], [600, 30, I], [700, 10, O], [1100, 0, S]), t6: t([0, 0], [300, -80, O], [480, -96], [620, 34, I], [720, 10, O], [1100, 0, S]), t5: t([0, 0], [300, -60, O], [480, -76], [640, 30, I], [740, 8, O], [1100, 0, S]),
      eyes: t([0, 0, { sy: 1, sx: 1 }], [300, 0, { sy: 1.25, sx: 1.25 }], [480, 0, { sy: 1.3, sx: 1.3 }], [620, 0, { sy: .5, sx: 1 }], [1100, 0, { sy: 1, sx: 1 }, S]) },
      each(['t1', 't2', 't3', 't4'], function (i) { return t([0, 0], [300, 20 - i * 4, O], [620, -16 + i * 3, I], [1100, 0, S]); }))),
    hit: once(380, join({ body: jelly(380, .16), eyes: t([0, 0, { sy: 1 }], [60, 0, { sy: .25, sx: 1.2 }], [260, 0, { sy: .25, sx: 1.2 }], [380, 0, { sy: 1 }]) }, each(TN, function (i) { return t([0, 0], [60 + i * 10, (i % 2 ? -1 : 1) * 40, O], [240, (i % 2 ? 1 : -1) * 14, S], [380, 0, S]); }))),
    dodge: once(520, join({ body: t([0, 0, { sy: 1 }], [120, 0, { y: -4, sy: 1.14 }, O], [300, 0, { y: 1, sy: .92 }], [520, 0, { sy: 1 }, S]) }, each(TN, function (i) { return t([0, 0], [120, (i - 3) * -10, O], [300, (i - 3) * 6], [520, 0, S]); }))),
    ko: once(900, join({ body: t([0, 0, { sx: 1, sy: 1 }], [500, 0, { y: 4, sx: 1.12, sy: .78 }, I], [650, 0, { y: 3, sx: 1.06, sy: .86 }], [900, 0, { y: 4, sx: 1.12, sy: .76 }, O]), eyes: t([0, 0, { sy: 1 }], [200, 0, { sy: .2 }], [900, 0, { sy: .2 }]) },
      each(TN, function (i) { return t([0, 0], [300, (i - 3) * 8], [900, (i - 3) * -17, O]); })), 1),
    blink: BLINK,
    curl: once(1700, each(TN, function (i) { return t([0, 0], [100 + i * 120, 0], [300 + i * 120, i < 3 ? 46 : -46, O], [520 + i * 120, 0, S], [1700, 0]); })),
    pulse: once(1200, { body: t([0, 0, { sx: 1, sy: 1 }], [300, 0, { sx: 1.1, sy: .9 }, S], [600, 0, { sx: .93, sy: 1.1, y: -2 }, O], [900, 0, { sx: 1.03, sy: .98 }, S], [1200, 0, { sx: 1, sy: 1 }, S]) })
  };
  A.octo = { attack: 'slam', poses: OCTO, springs: { 't*': { k: 80, d: 5, g: .1, w: .35, max: 45, dir: [0, 1] } }, fidgets: ['curl', 'pulse'] };

  /* ---------- folk (front view, two legs: the crew): footL/footR, body, armL/armR (+r lifts the left arm out, -r the right), head (+eyes, hat), [wingL, wingR, back] ---------- */
  var FOLK = {
    idle: loop(1700, { body: t([0, 0], [850, 0, { y: -.7 }, S], [1700, 0, S]), head: t([0, -1.5], [1000, 2, { y: -.3 }, S], [1700, -1.5, S]), armL: t([0, 0], [850, 5, S], [1700, 0, S]), armR: t([0, 0], [850, -5, S], [1700, 0, S]),
      wingL: wave(1700, .12, 0, { prop: 'sx', base: .92, n: 4 }), wingR: wave(1700, .12, 0, { prop: 'sx', base: .92, n: 4 }) }),
    run: loop(380, { footL: t([0, 0], [95, -14, { y: -2.5 }, O], [190, 0, I], [380, 0]), footR: t([0, 0], [190, 0], [285, 14, { y: -2.5 }, O], [380, 0, I]), body: mix(wave(380, 4, 0), wave(380, 1.2, .25, { prop: 'y', n: 8 })), head: wave(380, -5, .15),
      armL: wave(380, 30, 0, { base: 20 }), armR: wave(380, 30, 0, { base: -20 }), wingL: wave(380, .3, 0, { prop: 'sx', base: .75 }), wingR: wave(380, .3, 0, { prop: 'sx', base: .75 }), hat: wave(380, 4, .4) }),
    charge: once(900, {   // rolls up its sleeves (arms wind back), runs in, both fists forward, a little proud bounce after
      body: t([0, 0], [200, -8, O], [320, -9], [430, 12, I], [480, 4, O], [700, -3], [900, 0, S]), head: t([0, 0], [200, -6, O], [430, 14, I], [500, -8, O], [700, 4], [900, 0, S]),
      armL: t([0, 0], [200, 70, O], [320, 84], [430, -40, I], [480, -20, O], [700, 20], [900, 0, S]), armR: t([0, 0], [200, -30, O], [320, -40], [430, -110, I], [480, -96, O], [700, -20], [900, 0, S]),
      footL: t([0, 0], [250, -16, { y: -2 }], [330, 0], [410, -16, { y: -2 }], [480, 0], [900, 0]), footR: t([0, 0], [210, 0], [290, 16, { y: -2 }], [370, 0], [450, 16, { y: -2 }], [520, 0], [900, 0]), hat: t([0, 0], [200, -8], [430, 14, I], [520, -8, O], [900, 0, S]) }),
    hit: once(380, { body: t([0, 0], [60, -9, O], [220, 3, S], [380, 0, S]), head: t([0, 0], [50, 6], [110, -20, O], [240, 8, S], [380, 0, S]), armL: t([0, 0], [60, 90, O], [240, 20], [380, 0, S]), armR: t([0, 0], [60, -90, O], [240, -20], [380, 0, S]),
      hat: t([0, 0], [110, 16, { y: -2 }, O], [250, -6], [380, 0, S]), eyes: t([0, 0, { sy: 1 }], [60, 0, { sy: .25, sx: 1.2 }], [260, 0, { sy: .25, sx: 1.2 }], [380, 0, { sy: 1 }]) }),
    dodge: once(520, { body: t([0, 0], [120, 10, O], [300, -5], [520, 0, S]), head: t([0, 0], [120, -10, O], [300, 6], [520, 0, S]), armL: t([0, 0], [120, 100, O], [520, 0, S]), armR: t([0, 0], [120, -100, O], [520, 0, S]), footL: t([0, 0], [120, -20, { y: -3 }, O], [300, 0], [520, 0]), footR: t([0, 0], [120, 20, { y: -3 }, O], [300, 0], [520, 0]) }),
    ko: once(900, { body: t([0, 0], [900, 0]), head: t([0, 0], [120, -14, O], [500, 16], [900, 24, O]), armL: t([0, 0], [120, 100, O], [500, 130], [900, 120, O]), armR: t([0, 0], [120, -100, O], [500, -130], [900, -120, O]), footL: t([0, 0], [500, -30], [900, -44, O]), footR: t([0, 0], [500, 30], [900, 44, O]),
      hat: t([0, 0], [500, 20, { y: 1 }], [900, 34, { y: 2, x: 2 }, O]), eyes: t([0, 0, { sy: 1 }], [200, 0, { sy: .2 }], [900, 0, { sy: .2 }]) }, 1),
    blink: BLINK,
    wave: once(1400, { armR: t([0, 0], [250, -150, O], [400, -120], [550, -155], [700, -120], [850, -155], [1000, -125], [1400, 0, S]), head: t([0, 0], [250, 8, O], [1000, 8], [1400, 0, S]), body: t([0, 0], [250, 3, O], [1000, 3], [1400, 0, S]) }),
    bounce: once(1000, { body: t([0, 0], [150, 0, { y: 1 }], [320, 0, { y: -3 }, O], [480, 0, { y: 1 }, I], [640, 0, { y: -2.5 }, O], [800, 0, { y: .6 }, I], [1000, 0, S]), footL: t([0, 0], [320, 0, { y: -2.5 }, O], [480, 0, I], [640, 0, { y: -2 }, O], [800, 0, I], [1000, 0]), footR: t([0, 0], [320, 0, { y: -2.5 }, O], [480, 0, I], [640, 0, { y: -2 }, O], [800, 0, I], [1000, 0]),
      armL: t([0, 0], [320, 60, O], [480, 10], [640, 50, O], [800, 0], [1000, 0]), armR: t([0, 0], [320, -60, O], [480, -10], [640, -50, O], [800, 0], [1000, 0]), hat: t([0, 0], [320, 0, { y: -1.5 }], [480, 0, { y: 1 }], [640, 0, { y: -1 }], [800, 0], [1000, 0]) })
  };
  A.folk = { attack: 'charge', poses: FOLK, fidgets: ['wave', 'bounce'] };

  /* per-creature exceptions */
  A.slug = {
    'black-bear': { attack: 'slam' }, 'gloomtooth': { attack: 'slam' }, 'giant-anteater': { attack: 'slam' },
    'great-hawk': { attack: 'swoop' }, 'storm-eagle': { attack: 'swoop' }, 'snow-owl-monarch': { attack: 'swoop' }, 'tawny-owl': { attack: 'swoop' }, 'griffon-vulture': { attack: 'swoop' }, 'echo-bat': { attack: 'swoop' }, 'carrion-crow': { attack: 'swoop' }
  };
  root.FE_ARCH = A;
})(window);
