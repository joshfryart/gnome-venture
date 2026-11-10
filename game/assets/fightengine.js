/* Fight engine, rough pass. See claude/fight-anim-engine.md.
 * Data first: RIGS (what an actor is), MOVES (timed poses), ATTACK (which move a creature uses).
 * Engine: FightEngine.create(host, {cols, rows, speed}) -> {add, play, setSpeed}
 *   add(id, {rig:'gnome'|<creature slug>, img, col, row, side:'me'|'foe', name, hp, max, dir})
 *   play([{from,to,move,dmg,miss,crit}, {from,move:'guard'}, {from,move:'flee'}])  -> Promise
 * The server rolls the fight; this only plays the log back. No game logic here.
 * Motion: x = fraction of the reach to the target, dx = cells, y = cells (up is negative), sx/sy scale, r deg, b brightness, o opacity.
 * Positive x/dx/r mean "toward the opponent", so one move works for both sides. */
(function (root) {
  'use strict';
  var E = { out: 'cubic-bezier(.2,.7,.3,1)', 'in': 'cubic-bezier(.6,0,.9,.4)', io: 'ease-in-out' };
  var MOVES = {
    pluck: { dur: 940, atk: 1, hit: 440, fx: 'pow', swoosh: 415, dust: [250, 430], pose: 'pluck', keys: [      // gnome, bare-handed: Gnome Pluck (wind up, run in, swing the arm)
      [0, {}], [160, { dx: -.15, sx: 1.06, sy: .92, r: -8 }, E.out], [240, { dx: -.2, sx: 1.08, sy: .9, r: -10 }, E.io],
      [420, { x: .97, y: -.12, sx: .92, sy: 1.1, r: 12 }, E['in']], [470, { x: 1, sx: 1.14, sy: .88, r: 5 }, E.out],
      [660, { x: .95 }, E.out], [760, { x: .5, y: -.42, r: -7, sx: .95, sy: 1.06 }, E.out], [860, { sx: 1.1, sy: .9, dx: -.04 }, E['in']], [940, {}, E.out]] },
    attack: { dur: 740, atk: 1, hit: 330, fx: 'pow', swoosh: 305, dust: [150, 330], pose: 'attack', keys: [      // gnome, plain Attack: a quick step in and one swing (Pluck stays the long ability swing)
      [0, {}], [120, { dx: -.12, sx: 1.05, sy: .93, r: -6 }, E.out], [310, { x: .97, y: -.08, sx: .94, sy: 1.08, r: 10 }, E['in']], [350, { x: 1, sx: 1.12, sy: .9, r: 4 }, E.out],
      [500, { x: .96 }, E.out], [590, { x: .5, y: -.34, r: -6, sx: .95, sy: 1.06 }, E.out], [670, { sx: 1.09, sy: .91, dx: -.04 }, E['in']], [740, {}, E.out]] },
    snack: { dur: 1000, pose: 'snack', keys: [[0, {}], [200, { sx: 1.04, sy: .96 }, E.out], [420, { y: -.06 }, E.io], [560, { sy: .97 }, E.io], [700, { y: -.06 }, E.io], [1000, {}, E.io]] },
    charge: { dur: 900, atk: 1, hit: 430, pose: 'charge', fx: 'pow', keys: [
      [0, {}], [200, { dx: -.25, sx: 1.1, sy: .9, r: -4 }, E.out], [260, { dx: -.25, y: -.08 }], [320, { dx: -.25 }],
      [430, { x: 1, sx: 1.12, sy: .92, r: 6 }, E['in']], [480, { x: 1, sx: .85, sy: 1.1 }, E.out], [700, { x: .7 }, E.out], [900, {}, E.io]] },
    pounce: { dur: 850, atk: 1, hit: 410, pose: 'pounce', fx: 'pow', keys: [
      [0, {}], [220, { dx: -.1, sx: 1.15, sy: .78 }, E.out], [330, { x: .5, y: -1.1, sx: .9, sy: 1.15, r: -10 }, E.out],
      [410, { x: 1, y: -.2, sx: 1.1, sy: .9, r: 10 }, E['in']], [470, { x: 1, sx: 1.12, sy: .85 }, E.out], [850, {}, E.io]] },
    hop: { dur: 800, atk: 1, hit: 360, pose: 'hop', fx: 'pow', keys: [
      [0, {}], [120, { sx: 1.12, sy: .85 }, E.out], [220, { x: .45, y: -.5, sy: 1.1, sx: .94 }, E.out], [300, { x: .5, sx: 1.1, sy: .88 }, E['in']],
      [360, { x: 1, y: -.45, sx: .9, sy: 1.12 }, E.out], [440, { x: 1, sx: 1.12, sy: .85 }, E['in']], [800, {}, E.io]] },
    slam: { dur: 1100, atk: 1, hit: 620, pose: 'slam', fx: 'pow', keys: [
      [0, {}], [300, { y: -.3, sy: 1.2, sx: .92, r: -8 }, E.out], [480, { y: -.3, sy: 1.22, sx: .9, r: -10 }], [620, { x: .85, y: .05, sy: .8, sx: 1.2, r: 10 }, E['in']],
      [720, { x: .85, sy: .86, sx: 1.14 }, E.out], [1100, {}, E.io]] },
    peck: { dur: 820, atk: 1, hit: 400, pose: 'peck', fx: 'pow', dust: [120, 300], keys: [   // birds: two quick hops in, a stab with the beak, flutter back
      [0, {}], [90, { sx: 1.08, sy: .9 }, E.out], [200, { x: .45, y: -.35, sx: .95, sy: 1.06 }, E.out], [280, { x: .7, sx: 1.08, sy: .92 }, E['in']], [370, { x: .95, y: -.2, r: 8 }, E.out], [410, { x: 1, r: 16, sx: 1.1, sy: .92 }, E['in']],
      [520, { x: .9, r: -6 }, E.out], [680, { x: .35, y: -.5, r: -8 }, E.out], [760, { sx: 1.08, sy: .9 }, E['in']], [820, {}, E.out]] },
    swoop: { dur: 950, atk: 1, hit: 470, pose: 'swoop', fx: 'pow', keys: [   // flyers: lift off, dive along an arc, pull out
      [0, {}], [160, { sx: 1.1, sy: .86 }, E.out], [330, { dx: -.3, y: -1.5, r: -14, sx: .94, sy: 1.08 }, E.out], [470, { x: 1, y: -.25, r: 22, sx: .9, sy: 1.12 }, E['in']], [530, { x: .96, y: -.5, r: -6, sx: 1.1, sy: .9 }, E.out],
      [720, { x: .4, y: -1.1, r: -12 }, E.io], [880, { sx: 1.08, sy: .9 }, E['in']], [950, {}, E.out]] },
    strike: { dur: 900, atk: 1, hit: 430, pose: 'strike', fx: 'pow', keys: [   // snakes and worms: coil back (long hold), whip out and back: the body stretches, it does not travel
      [0, {}], [220, { dx: -.25, sx: .92, sy: 1.06 }, E.out], [370, { dx: -.3, sx: .9, sy: 1.08 }], [430, { x: 1, sx: 1.16, sy: .92 }, E['in']], [490, { x: .98, sx: 1.1, sy: .94 }, E.out], [640, { x: .3, sx: .96, sy: 1.03 }, E.io], [780, { sx: 1.05, sy: .96 }, E.io], [900, {}, E.io]] },
    smash: { dur: 1150, atk: 1, hit: 640, pose: 'smash', fx: 'pow', dust: [600, 760], keys: [   // golems and the like: two heavy steps, a long overhead wind-up, the ground shakes
      [0, {}], [200, { x: .3, y: -.06, r: 3 }, E.io], [400, { x: .7, y: -.06, r: -3 }, E.io], [540, { x: .78, y: -.12, r: -9, sy: 1.08, sx: .96 }, E.out], [640, { x: .9, r: 12, sy: .86, sx: 1.14 }, E['in']], [740, { x: .9, sy: .92, sx: 1.08, r: 6 }, E.out],
      [900, { x: .5, r: -2 }, E.io], [1150, {}, E.io]] },
    hit: { dur: 380, pose: 'hit', keys: [[0, {}], [60, { dx: -.18, sx: .9, sy: 1.1, b: 2.2, r: -8 }, E.out], [160, { dx: -.1, sx: 1.06, sy: .94, b: 1.3, r: 3 }], [380, {}, E.io]] },
    dodge: { dur: 520, pose: 'dodge', keys: [[0, {}], [120, { y: -.5, dx: -.3, sy: 1.1, sx: .92 }, E.out], [300, { dx: -.25, sx: 1.08, sy: .9 }, E['in']], [520, {}, E.io]] },
    ko: { dur: 900, keep: 1, pose: 'ko', keys: [[0, {}], [120, { dx: -.2, b: 2, r: -10 }, E.out], [500, { dx: -.5, y: .15, r: -60 }, E['in']], [900, { dx: -.6, y: .35, r: -90, o: 0 }, E.out]] },
    guard: { dur: 400, pose: 'guard', keys: [[0, {}], [120, { sx: 1.1, sy: .88 }, E.out], [400, { sx: 1.06, sy: .92 }, E.io]] },
    flee: { dur: 700, keep: 1, dust: [150, 600], pose: { use: 'run', dur: 350, loops: 2 }, keys: [[0, {}], [150, { dx: -.1, sx: 1.08, sy: .9 }, E.out], [700, { dx: -6, o: 0 }, E['in']]] },
    enter: { dur: 800, dust: [90, 600], pose: { use: 'run', dur: 320, loops: 2 }, keys: [[0, { dx: -3.5, o: 0 }], [90, { dx: -3.1, o: 1 }, E.out], [620, { dx: -.25, sx: 1.05, sy: .96 }, E.out], [800, {}, E.io]] },
    koL: { dur: 900, keep: 1, pose: 'ko', keys: [[0, {}], [120, { dx: -.2, b: 2, r: -10 }, E.out], [500, { dx: -.5, y: -.15, r: -60 }, E['in']], [900, { dx: -.75, y: -.5, r: -90 }, E.out]] },   // lies on its back: the pivot is lifted so the body rests on the ground, not in it
    cheer: { dur: 1000, pose: 'cheer', keys: [[0, {}], [140, { sx: 1.1, sy: .86 }, E.out], [300, { y: -.55, sx: .92, sy: 1.12 }, E.out], [450, { sx: 1.12, sy: .86 }, E['in']], [620, { y: -.45, sx: .93, sy: 1.1 }, E.out], [780, { sx: 1.1, sy: .88 }, E['in']], [1000, {}, E.io]] },
    fixhat: { dur: 1500, pose: 'fixhat', keys: [[0, {}], [600, { sy: .96, sx: 1.03 }, E.io], [800, {}], [1500, {}, E.io]] },
    idle: { dur: 1600, keys: [[0, {}], [800, { y: -.04, sy: 1.02, sx: .99 }, E.io], [1600, {}, E.io]] }
  };
  /* Limb poses for the gnome: per part [ms, {r deg (clockwise +), x px, y px, sx, sy, o}, ease-in-to-next]. The gnome faces right, so for a hanging limb positive r swings it BACK, negative forward.
   * Bones: legs stand alone; body (tunic) turns at the hips and carries scarf, arms and head; armF/armB turn at the shoulder and carry foreF/foreB (the elbow only bends forward: r from 0 to -140);
   * head turns at the neck (positive r = nod down, negative = chin up) and carries beard, eyelid and hat. Beard, scarf, hat and curl are springs: never key them, they follow.
   * Timing rules used below: the body leads, the head counters it a beat later, the forearm trails the upper arm (overlap), every big action ends in a small overshoot before it settles. */
  var POSES = {
    idle: { dur: 1600, loops: Infinity, tracks: {   // breathing: chest lifts, head settles a beat later, hands drift
      body: [[0, {}], [800, { y: -1, r: .6 }, E.io], [1600, {}, E.io]], head: [[0, { r: -1 }], [950, { r: 2, y: .4 }, E.io], [1600, { r: -1 }, E.io]],
      armF: [[0, { r: 2 }], [800, { r: 6 }, E.io], [1600, { r: 2 }, E.io]], foreF: [[0, { r: -6 }], [950, { r: -13 }, E.io], [1600, { r: -6 }, E.io]],
      armB: [[0, { r: -2 }], [800, { r: -6 }, E.io], [1600, { r: -2 }, E.io]], foreB: [[0, { r: -8 }], [950, { r: -3 }, E.io], [1600, { r: -8 }, E.io]] } },
    blink: { dur: 170, tracks: { lid: [[0, { o: 0 }], [30, { o: 1 }], [130, { o: 1 }], [170, { o: 0 }]] } },
    run: { dur: 480, loops: Infinity, tracks: {   // leaning sprint: elbows bent, head held level against the lean
      body: [[0, { r: 9 }], [120, { r: 10, y: -2 }], [240, { r: 9 }], [360, { r: 10, y: -2 }], [480, { r: 9 }]],
      head: [[0, { r: -7 }], [120, { r: -4, y: .5 }], [240, { r: -7 }], [360, { r: -4, y: .5 }], [480, { r: -7 }]],
      legF: [[0, { r: -40 }], [120, { r: 0, y: -3 }], [240, { r: 40 }], [360, { r: 0, y: -3 }], [480, { r: -40 }]],
      legB: [[0, { r: 40 }], [120, { r: 0, y: -3 }], [240, { r: -40 }], [360, { r: 0, y: -3 }], [480, { r: 40 }]],
      armF: [[0, { r: 55 }], [240, { r: -55 }, E.io], [480, { r: 55 }, E.io]], foreF: [[0, { r: -60 }], [240, { r: -95 }, E.io], [480, { r: -60 }, E.io]],
      armB: [[0, { r: -55 }], [240, { r: 55 }, E.io], [480, { r: -55 }, E.io]], foreB: [[0, { r: -95 }], [240, { r: -60 }, E.io], [480, { r: -95 }, E.io]] } },
    walk: { dur: 720, loops: Infinity, tracks: {
      body: [[0, { r: 3 }], [180, { r: 4, y: -1 }], [360, { r: 3 }], [540, { r: 4, y: -1 }], [720, { r: 3 }]], head: [[0, { r: -2 }], [180, { r: 1 }], [360, { r: -2 }], [540, { r: 1 }], [720, { r: -2 }]],
      legF: [[0, { r: -22 }], [360, { r: 22 }, E.io], [720, { r: -22 }, E.io]], legB: [[0, { r: 22 }], [360, { r: -22 }, E.io], [720, { r: 22 }, E.io]],
      armF: [[0, { r: 28 }], [360, { r: -28 }, E.io], [720, { r: 28 }, E.io]], foreF: [[0, { r: -10 }], [360, { r: -35 }, E.io], [720, { r: -10 }, E.io]],
      armB: [[0, { r: -28 }], [360, { r: 28 }, E.io], [720, { r: -28 }, E.io]], foreB: [[0, { r: -35 }], [360, { r: -10 }, E.io], [720, { r: -35 }, E.io]] } },
    pluck: { dur: 940, tracks: {   // shimmy and wind up (0-240), rush (240-420), whip (420-470): shoulder first, forearm snaps through a beat later; then a hop back (660-860) and a settle
      body: [[0, {}], [45, { r: -5 }], [90, { r: 4 }], [135, { r: -7 }], [180, { r: 3 }], [210, { r: -10 }], [240, { r: -13 }], [330, { r: 6, y: -1 }], [420, { r: 10 }], [470, { r: 14 }, E.out], [560, { r: 8 }], [660, { r: 4 }], [760, { r: -8 }, E.out], [860, { r: 5 }, E['in']], [940, {}, E.io]],
      head: [[0, {}], [70, { r: 6 }], [160, { r: -9 }, E.out], [240, { r: -15 }], [330, { r: -2 }], [420, { r: -10 }], [470, { r: 15 }, E.out], [560, { r: -5 }, E.io], [660, { r: 3 }], [760, { r: 9 }], [860, { r: -6 }], [940, {}, E.io]],
      armF: [[0, {}], [160, { r: 112 }, E.out], [240, { r: 136 }], [330, { r: 126 }], [420, { r: 114 }], [445, { r: -64 }, E['in']], [500, { r: -112 }, E.out], [600, { r: -84 }], [660, { r: -55 }], [760, { r: -30 }], [860, { r: 12 }], [940, {}, E.io]],
      foreF: [[0, {}], [160, { r: -92 }, E.out], [240, { r: -122 }], [420, { r: -112 }], [445, { r: -70 }], [480, { r: -4 }, E['in']], [560, { r: -24 }, E.out], [660, { r: -40 }], [860, { r: -18 }], [940, {}, E.io]],
      armB: [[0, {}], [160, { r: -32 }], [240, { r: -50 }], [330, { r: 48 }], [420, { r: -42 }], [470, { r: 72 }, E.out], [660, { r: 30 }], [760, { r: -40 }], [860, { r: 10 }], [940, {}, E.io]],
      foreB: [[0, {}], [240, { r: -70 }], [330, { r: -80 }], [470, { r: -15 }], [760, { r: -60 }], [940, {}, E.io]],
      legF: [[0, {}], [45, { r: 10 }], [90, { r: -10 }], [135, { r: 12 }], [180, { r: -9 }], [240, { r: -10 }], [285, { r: -40 }], [330, { r: 0, y: -3 }], [375, { r: 40 }], [420, { r: -25 }], [470, { r: -15 }], [660, { r: -8 }], [760, { r: 30, y: -3 }, E.out], [860, { r: -6 }], [940, {}, E.io]],
      legB: [[0, {}], [45, { r: -10 }], [90, { r: 10 }], [135, { r: -12 }], [180, { r: 9 }], [240, { r: 10 }], [285, { r: 40 }], [330, { r: 0, y: -3 }], [375, { r: -40 }], [420, { r: 25 }], [470, { r: 15 }], [660, { r: 8 }], [760, { r: 42, y: -4 }, E.out], [860, { r: 6 }], [940, {}, E.io]] } },
    attack: { dur: 740, tracks: {   // quick step in, one swing, hop back
      body: [[0, {}], [120, { r: -8 }, E.out], [250, { r: -11 }], [330, { r: 13 }, E.out], [500, { r: 5 }], [590, { r: -7 }, E.out], [670, { r: 4 }, E['in']], [740, {}, E.io]],
      head: [[0, {}], [120, { r: -6 }, E.out], [250, { r: -12 }], [345, { r: 14 }, E.out], [430, { r: -4 }], [500, { r: 2 }], [590, { r: 8 }], [670, { r: -5 }], [740, {}, E.io]],
      armF: [[0, {}], [120, { r: 98 }, E.out], [250, { r: 120 }], [320, { r: -58 }, E['in']], [380, { r: -104 }, E.out], [500, { r: -55 }], [590, { r: -25 }], [670, { r: 10 }], [740, {}, E.io]],
      foreF: [[0, {}], [120, { r: -85 }, E.out], [250, { r: -112 }], [320, { r: -75 }], [355, { r: -4 }, E['in']], [430, { r: -22 }, E.out], [590, { r: -35 }], [740, {}, E.io]],
      armB: [[0, {}], [120, { r: -25 }], [250, { r: -40 }], [345, { r: 62 }, E.out], [500, { r: 25 }], [590, { r: -35 }], [740, {}, E.io]], foreB: [[0, {}], [250, { r: -60 }], [345, { r: -15 }], [590, { r: -55 }], [740, {}, E.io]],
      legF: [[0, {}], [120, { r: -25 }, E.out], [220, { r: 25 }], [330, { r: -18 }], [500, { r: -8 }], [590, { r: 28, y: -3 }, E.out], [670, { r: -5 }], [740, {}, E.io]],
      legB: [[0, {}], [120, { r: 25 }, E.out], [220, { r: -25 }], [330, { r: 18 }], [500, { r: 8 }], [590, { r: 40, y: -4 }, E.out], [670, { r: 5 }], [740, {}, E.io]] } },
    snack: { dur: 1000, tracks: {   // hand to mouth, three munches (the head does the chewing), a satisfied settle
      body: [[0, {}], [200, { r: -3 }, E.out], [560, { r: 2 }, E.io], [1000, {}, E.io]],
      head: [[0, {}], [220, { r: 7 }, E.out], [380, { r: -3 }], [460, { r: 5 }], [540, { r: -3 }], [620, { r: 5 }], [700, { r: -3 }], [800, { r: -9 }, E.out], [1000, {}, E.io]],
      armF: [[0, {}], [220, { r: -58 }, E.out], [800, { r: -52 }], [1000, {}, E.io]], foreF: [[0, {}], [220, { r: -118 }, E.out], [380, { r: -126 }], [460, { r: -112 }], [540, { r: -126 }], [620, { r: -112 }], [700, { r: -126 }], [800, { r: -90 }], [1000, {}, E.io]],
      armB: [[0, {}], [220, { r: -18 }], [1000, {}, E.io]], foreB: [[0, {}], [220, { r: -40 }], [1000, {}, E.io]] } },
    hit: { dur: 380, tracks: {   // the body goes back, the head whips after it, arms fly, then a head-shake settle
      body: [[0, {}], [60, { r: -15 }, E.out], [220, { r: 3 }, E.io], [380, {}, E.io]], head: [[0, {}], [50, { r: 10 }], [110, { r: -24 }, E.out], [230, { r: 9 }, E.io], [310, { r: -4 }], [380, {}, E.io]],
      armF: [[0, {}], [60, { r: 78 }, E.out], [200, { r: 25 }], [380, {}, E.io]], foreF: [[0, {}], [90, { r: -70 }, E.out], [240, { r: -20 }], [380, {}, E.io]],
      armB: [[0, {}], [60, { r: -68 }, E.out], [200, { r: -20 }], [380, {}, E.io]], foreB: [[0, {}], [90, { r: -85 }, E.out], [380, {}, E.io]],
      legF: [[0, {}], [60, { r: -16 }, E.out], [380, {}, E.io]], legB: [[0, {}], [60, { r: 12 }, E.out], [380, {}, E.io]] } },
    dodge: { dur: 520, tracks: {   // knees up, arms out for balance, lands and wobbles
      body: [[0, {}], [120, { r: 9 }, E.out], [300, { r: -6 }], [420, { r: 3 }], [520, {}, E.io]], head: [[0, {}], [120, { r: -12 }, E.out], [300, { r: 10 }], [420, { r: -4 }], [520, {}, E.io]],
      armF: [[0, {}], [120, { r: -75 }, E.out], [300, { r: 25 }], [520, {}, E.io]], foreF: [[0, {}], [120, { r: -30 }], [300, { r: -50 }], [520, {}, E.io]],
      armB: [[0, {}], [120, { r: 70 }, E.out], [300, { r: -20 }], [520, {}, E.io]], foreB: [[0, {}], [120, { r: -30 }], [520, {}, E.io]],
      legF: [[0, {}], [120, { r: -42, y: -5 }, E.out], [300, { r: 10 }], [520, {}, E.io]], legB: [[0, {}], [120, { r: -28, y: -5 }, E.out], [300, { r: 5 }], [520, {}, E.io]] } },
    ko: { dur: 900, keep: 1, tracks: {   // arms flop, legs buckle, the head lolls back last; one boot keeps twitching in the air
      body: [[0, {}], [120, { r: -10 }, E.out], [500, { r: -12 }], [900, { r: -6 }, E.out]], head: [[0, {}], [120, { r: 14 }], [500, { r: -20 }, E.out], [760, { r: -34 }], [900, { r: -28 }, E.out]],
      armF: [[0, {}], [120, { r: 70 }, E.out], [500, { r: 135 }], [900, { r: 150 }, E.out]], foreF: [[0, {}], [300, { r: -60 }], [700, { r: -10 }], [900, { r: -25 }]],
      armB: [[0, {}], [120, { r: -70 }, E.out], [500, { r: -120 }], [900, { r: -135 }, E.out]], foreB: [[0, {}], [300, { r: -70 }], [900, { r: -30 }]],
      legF: [[0, {}], [500, { r: -25 }], [700, { r: -52 }], [800, { r: -34 }], [900, { r: -42 }, E.out]], legB: [[0, {}], [500, { r: 20 }], [900, { r: 35 }, E.out]] } },
    cheer: { dur: 1000, tracks: {   // two hops: fist pump on the first, both arms on the second, heels kick
      body: [[0, {}], [140, { r: 4 }], [300, { r: -7 }, E.out], [450, { r: 3 }], [620, { r: -6 }], [780, { r: 3 }], [1000, {}, E.io]], head: [[0, {}], [140, { r: 8 }], [300, { r: -14 }, E.out], [450, { r: 6 }], [620, { r: -16 }, E.out], [780, { r: 6 }], [1000, {}, E.io]],
      armF: [[0, {}], [140, { r: 30 }], [300, { r: -158 }, E.out], [450, { r: -120 }], [620, { r: -172 }, E.out], [780, { r: -90 }], [1000, {}, E.io]], foreF: [[0, {}], [140, { r: -90 }], [300, { r: -10 }, E.out], [450, { r: -70 }], [620, { r: -5 }, E.out], [1000, {}, E.io]],
      armB: [[0, {}], [300, { r: -40 }], [450, { r: -30 }], [620, { r: -165 }, E.out], [780, { r: -80 }], [1000, {}, E.io]], foreB: [[0, {}], [300, { r: -80 }], [620, { r: -8 }, E.out], [1000, {}, E.io]],
      legF: [[0, {}], [300, { r: -20, y: -1 }], [450, { r: 0 }], [620, { r: 34, y: -3 }, E.out], [780, { r: 0 }], [1000, {}, E.io]], legB: [[0, {}], [300, { r: 20, y: -1 }], [450, { r: 0 }], [620, { r: 44, y: -4 }, E.out], [780, { r: 0 }], [1000, {}, E.io]] } },
    fixhat: { dur: 1500, tracks: {   // watches it land (chin up), ducks under it, pats it down twice
      body: [[0, {}], [500, { r: -4 }, E.io], [900, { r: 3 }], [1500, {}, E.io]], head: [[0, {}], [350, { r: -14 }, E.out], [620, { r: 9 }, E['in']], [830, { r: 4 }], [930, { r: 8 }], [1030, { r: 3 }], [1500, {}, E.io]],
      armF: [[0, {}], [450, {}], [680, { r: -150 }, E.out], [830, { r: -160 }], [930, { r: -146 }], [1030, { r: -160 }], [1500, {}, E.io]], foreF: [[0, {}], [450, {}], [680, { r: -48 }, E.out], [830, { r: -30 }], [930, { r: -58 }], [1030, { r: -30 }], [1500, {}, E.io]],
      armB: [[0, {}], [500, { r: 30 }], [1500, {}, E.io]], foreB: [[0, {}], [500, { r: -40 }], [1500, {}, E.io]], legF: [[0, {}], [1500, {}]], legB: [[0, {}], [1500, {}]] } },
    guard: { dur: 300, keep: 1, tracks: {   // forearms up in front of the face, chin tucked behind them
      body: [[0, {}], [300, { r: -5 }, E.out]], head: [[0, {}], [300, { r: 9, y: 1 }, E.out]],
      armF: [[0, {}], [300, { r: -62 }, E.out]], foreF: [[0, {}], [300, { r: -112 }, E.out]], armB: [[0, {}], [300, { r: -48 }, E.out]], foreB: [[0, {}], [300, { r: -118 }, E.out]],
      legF: [[0, {}], [300, { r: -12 }, E.out]], legB: [[0, {}], [300, { r: 12 }, E.out]] } },
    // fidgets: played now and then while he waits (RIGS.gnome.fidgets). Short, and any move cancels them.
    beardstroke: { dur: 1500, tracks: {
      head: [[0, {}], [300, { r: 6 }, E.io], [1150, { r: 5 }], [1500, {}, E.io]], body: [[0, {}], [300, { r: 2 }, E.io], [1150, { r: 2 }], [1500, {}, E.io]],
      armF: [[0, {}], [300, { r: -38 }, E.out], [1150, { r: -34 }], [1500, {}, E.io]], foreF: [[0, {}], [300, { r: -122 }, E.out], [520, { r: -92 }, E.io], [720, { r: -124 }, E.io], [940, { r: -92 }, E.io], [1150, { r: -118 }, E.io], [1500, {}, E.io]] } },
    lookback: { dur: 1700, tracks: {   // something up there? no. down there? no.
      head: [[0, {}], [260, { r: -20 }, E.out], [700, { r: -22 }], [900, { r: 13 }, E.io], [1300, { r: 12 }], [1700, {}, E.io]], body: [[0, {}], [260, { r: -4 }, E.out], [700, { r: -4 }], [900, { r: 3 }, E.io], [1300, { r: 3 }], [1700, {}, E.io]],
      armF: [[0, {}], [260, { r: 14 }], [900, { r: -10 }], [1700, {}, E.io]], armB: [[0, {}], [260, { r: -14 }], [900, { r: 10 }], [1700, {}, E.io]] } },
    toetap: { dur: 1500, tracks: {   // hands on hips, one boot taps
      armF: [[0, {}], [250, { r: 34 }, E.out], [1250, { r: 34 }], [1500, {}, E.io]], foreF: [[0, {}], [250, { r: -108 }, E.out], [1250, { r: -108 }], [1500, {}, E.io]],
      armB: [[0, {}], [250, { r: 30 }, E.out], [1250, { r: 30 }], [1500, {}, E.io]], foreB: [[0, {}], [250, { r: -104 }, E.out], [1250, { r: -104 }], [1500, {}, E.io]],
      head: [[0, {}], [250, { r: 5 }], [1250, { r: 5 }], [1500, {}, E.io]],
      legF: [[0, {}], [300, {}], [400, { r: -22 }, E.out], [500, {}, E['in']], [600, { r: -22 }, E.out], [700, {}, E['in']], [800, { r: -22 }, E.out], [900, {}, E['in']], [1000, { r: -22 }, E.out], [1100, {}, E['in']], [1500, {}]] } },
    hattug: { dur: 1300, hat: 1, tracks: {   // a tug on the brim
      armF: [[0, {}], [320, { r: -146 }, E.out], [900, { r: -150 }], [1300, {}, E.io]], foreF: [[0, {}], [320, { r: -52 }, E.out], [520, { r: -30 }], [640, { r: -56 }], [760, { r: -30 }], [900, { r: -50 }], [1300, {}, E.io]],
      head: [[0, {}], [320, { r: -5 }], [520, { r: 8 }, E.out], [640, { r: 2 }], [760, { r: 9 }, E.out], [900, { r: 2 }], [1300, {}, E.io]] } },
    stretch: { dur: 1900, tracks: {   // arms up, a long lean back, a yawn, flop
      body: [[0, {}], [500, { r: -9, sy: 1.05 }, E.io], [1100, { r: -11, sy: 1.06 }], [1450, { r: 5, sy: .97 }, E['in']], [1900, {}, E.io]], head: [[0, {}], [500, { r: -16 }, E.io], [1100, { r: -22 }], [1450, { r: 12 }, E['in']], [1900, {}, E.io]],
      armF: [[0, {}], [500, { r: -168 }, E.io], [1100, { r: -176 }], [1450, { r: 20 }, E['in']], [1650, { r: -8 }], [1900, {}, E.io]], foreF: [[0, {}], [300, { r: -90 }], [500, { r: -12 }], [1100, { r: -4 }], [1450, { r: -30 }], [1900, {}, E.io]],
      armB: [[0, {}], [500, { r: -160 }, E.io], [1100, { r: -170 }], [1450, { r: 16 }, E['in']], [1650, { r: -6 }], [1900, {}, E.io]], foreB: [[0, {}], [300, { r: -90 }], [500, { r: -14 }], [1100, { r: -6 }], [1450, { r: -30 }], [1900, {}, E.io]] } }
  };
  /* A rig = how to draw and size an actor. parts: a SHEET (one column per part, row 0 paint, row 1 ink) and a bone tree. still: one picture (mini art, faces right). w/h are in board cells.
   * Part: id, img (sheet column name; default = id), px = pivot (frame px), parent (bone it hangs from; none = stands on its own), under (drawn behind its parent's picture),
   * ink:false (no outline of its own), dim (brightness, far limbs), lag (ms, drag), ox (x shift, frame px), hide (shown only by a pose, e.g. the eyelid),
   * phys (the hat: its own physics), spring {k stiffness, d damping, g how hard the bone's acceleration swings it, w how hard its speed drags it, max deg, dir rest direction [x, y] from the pivot, y down}. */
  var RIGS = {
    // the gnome: sheet cut by includes/gnome_rig.php (tools/gnome_rig_parts.php writes the default colours). Legs stand on their own so a lean never lifts the boots.
    gnome: { kind: 'parts', w: 2, h: 2.5, fw: 64, fh: 80, attack: 'pluck', unarmed: 1, lingers: 1, hat: 1,
      cols: ['legB', 'legF', 'body', 'scarf', 'armU', 'armL', 'head', 'beard', 'lid', 'hat', 'tip'],
      fidgets: ['beardstroke', 'lookback', 'toetap', 'hattug', 'stretch'],
      parts: [
        { id: 'legB', px: [28, 64], dim: .82 }, { id: 'legF', px: [36, 64] },
        { id: 'body', px: [32, 63] },
        { id: 'scarf', parent: 'body', under: 1, px: [29, 46], spring: { k: 110, d: 7, g: .12, w: .5, max: 55, dir: [-.8, .6] } },
        { id: 'armB', img: 'armU', parent: 'body', under: 1, px: [33, 48], ox: 4, dim: .72, lag: 20, ink: false }, { id: 'foreB', img: 'armL', parent: 'armB', px: [33, 56], dim: .72, lag: 30, ink: false },
        { id: 'head', parent: 'body', px: [33, 46], lag: 15 },
        { id: 'beard', parent: 'head', px: [33, 44], spring: { k: 150, d: 9, g: .1, w: .35, max: 40, dir: [-.25, 1] } },
        { id: 'lid', parent: 'head', px: [38, 39], ink: false, hide: 1 },
        { id: 'hat', parent: 'head', px: [32, 37], phys: 1 }, { id: 'tip', px: [28, 11], phys: 1, parent: 'hat' },
        { id: 'armF', img: 'armU', parent: 'body', px: [33, 48], lag: 35, ink: false }, { id: 'foreF', img: 'armL', parent: 'armF', px: [33, 56], lag: 55, ink: false }] },
    creature: { kind: 'still', w: 2.3, h: 2.3, attack: 'charge' }
  };
  /* Creature rigs: bones and sheets are GENERATED from the mini archetypes (assets/fightrigs.js, tools/fight/rig_minis.lua); the motion of each archetype is in assets/fightarch.js.
   * A creature with no row there is a single still picture. */
  var DATA = root.FE_RIGS || { skel: {}, rigs: {} }, ARCH = root.FE_ARCH || {}, PXC = 2.3 / 80, rigCache = {};   // PXC: board cells per frame px
  function archOf(key) { return ARCH[key] || ARCH[key.split('.')[0].replace(/\d+$/, '')] || {}; }
  function pick(map, id) { if (!map) return null; if (map[id]) return map[id]; for (var k in map) if (k.indexOf('*') >= 0 && new RegExp('^' + k.replace(/\*/g, '.*') + '$').test(id)) return map[k]; return null; }
  function rigFor(id, sheet) {
    if (id === 'gnome') return RIGS.gnome;
    var d = DATA.rigs[id];
    if (!d || !sheet) { var st = Object.assign({}, RIGS.creature); if (d) st.w = st.h = Math.max(d[1], d[2]) * PXC; return st; }
    if (rigCache[id]) return rigCache[id];
    var sk = DATA.skel[d[0]], A = archOf(d[0]), over = (ARCH.slug || {})[id] || {}, ids = d[4].split(','), u = d[3], cx = (d[1] - 1) / 2, by = d[2] - 5, z = (over.size || A.size || 1) * PXC;
    var parts = ids.map(function (pid) { var j = sk[pid]; return { id: pid, px: [cx + j[1] * u + .5, by - j[2] * u + .5], parent: j[0] || null, under: j[3], ink: pid !== 'eyes', spring: pick(A.springs, pid), dim: (A.dim || {})[pid], lag: (A.lag || {})[pid], hide: (A.hide || {})[pid] }; });
    return rigCache[id] = { kind: 'parts', arch: d[0], cols: ids, fw: d[1], fh: d[2], u: u, w: d[1] * z, h: d[2] * z, parts: parts, poses: A.poses || {}, attack: over.attack || A.attack || 'charge', fidgets: A.fidgets };
  }
  function kfs(move, a, reach, c) {   // MOVES entry -> Web Animations keyframes for actor a
    var out = [], k = move.keys;
    for (var i = 0; i < k.length; i++) {
      var s = k[i][1], x = ((s.x || 0) * reach + (s.dx || 0)) * c * a.dir, y = (s.y || 0) * c;
      out.push({
        offset: k[i][0] / move.dur,
        transform: 'translate(' + x + 'px,' + y + 'px) rotate(' + ((s.r || 0) * a.dir) + 'deg) scale(' + (s.sx == null ? 1 : s.sx) + ',' + (s.sy == null ? 1 : s.sy) + ')',
        filter: 'drop-shadow(0 6px 3px rgba(0,0,0,.35)) brightness(' + (s.b || 1) + ')',
        opacity: s.o == null ? 1 : s.o,
        easing: k[i + 1] && k[i + 1][2] ? k[i + 1][2] : 'linear',
        _x: x, _y: y
      });
    }
    return out;
  }
  function create(host, opts) {
    opts = opts || {};
    var cols = opts.cols || 11, rows = opts.rows || 7, speed = opts.speed || 1, c = 30, acts = {}, live = new Set(), sc = opts.scale || 1;   // sc: actor size on the board (the fight over a map draws them small, about a tile)
    var reduce = root.matchMedia && root.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var terrain = opts.terrain || function (x, y) { return y === (rows >> 1) ? 'p' : ((x + y) % 5 === 0 ? 'f' : (x * y % 7 === 3 ? 'r' : '')); };
    host.classList.add('fe-stage'); if (opts.flat) host.classList.add('fe-flat');   // flat: no tilt, transparent tiles, cells = the tiles of the map picture under the host
    host.innerHTML = '<div class="fe-view"><div class="fe-board"><div class="fe-grid"></div></div><div class="fe-actors"></div></div><div class="fe-hud"></div><div class="fe-fx"></div>';
    var view = host.children[0], board = view.children[0], actorsEl = view.children[1], grid = board.children[0], hud = host.children[1], fx = host.children[2];
    var t = '', dead = false, busy = 0;
    for (var y = 0; y < rows; y++) for (var x = 0; x < cols; x++) t += '<div class="fe-t ' + terrain(x, y) + '"></div>';
    grid.innerHTML = t; grid.style.gridTemplateColumns = 'repeat(' + cols + ',1fr)';

    function sp() { return reduce ? 40 : speed; }
    function sleep(ms) { return new Promise(function (r) { setTimeout(r, ms / sp()); }); }
    function layout() {
      lastW = host.clientWidth;
      var w = host.clientWidth - (opts.flat ? 0 : 16); c = opts.flat ? w / cols - 1 : (w - (cols - 1)) / cols;
      board.style.width = w + 'px'; view.style.paddingTop = opts.flat ? '0px' : (.5 * c) + 'px';
      Object.keys(acts).forEach(function (k) { place(acts[k]); });
    }
    /* Actors are NOT 3D objects: the board is tilted with one perspective transform, and each actor is an upright, screen-aligned picture put at the projected
     * position of its feet, scaled by the local perspective scale. No depth sorting, so a body can lie down, rotate or fly without vanishing behind tiles. */
    var TILT = opts.flat ? '' : 'perspective(520px) rotateX(42deg) scale(.96)';
    function proj(x, y) {   // board-local px -> [x, y, scale] in the view
      var W = board.offsetWidth, H = board.offsetHeight, m = new DOMMatrix('translate(' + (W / 2) + 'px,' + H + 'px) ' + TILT + ' translate(' + (-W / 2) + 'px,' + (-H) + 'px)');
      var p = m.transformPoint(new DOMPoint(x, y, 0, 1)), q = m.transformPoint(new DOMPoint(x + 10, y, 0, 1));
      return [board.offsetLeft + p.x / p.w, board.offsetTop + p.y / p.w, Math.abs(q.x / q.w - p.x / p.w) / 10];
    }
    function place(a) {
      var r = a.rig, px = a.col * (c + 1), py = a.row * (c + 1), w = r.w * sc * c, h = r.h * sc * c;
      var P = proj(px + c / 2, py + c * .86);
      a.el.style.cssText = 'left:' + (P[0] - c / 2) + 'px;top:' + (P[1] - c) + 'px;width:' + c + 'px;height:' + c + 'px;transform:scale(' + P[2] + ');z-index:' + (a.row + 1);
      a.body.style.cssText = 'left:' + ((c - w) / 2) + 'px;width:' + w + 'px;height:' + h + 'px';
      if (a.ghost) { a.ghost.style.cssText = a.el.style.cssText; a.ghost.firstChild.style.cssText = a.body.style.cssText; }
      if (a.hb && opts.flat) { var hw = a.hb.offsetWidth || 54; a.hb.style.cssText = 'left:' + (P[0] - hw / 2) + 'px;top:' + (P[1] + 3) + 'px;right:auto;bottom:auto'; }   // health sits right under the feet
      a.sh.style.cssText = 'left:' + (px + c / 2 - w * .35) + 'px;top:' + (py + c * .62) + 'px;width:' + (w * .7) + 'px;height:' + (c * .36) + 'px';
      if (a.emoji) a.spr.style.fontSize = (h * .72) + 'px';
      if (r.kind === 'strip') { a.spr.style.backgroundSize = (r.frames * 100) + '% 100%'; a.spr.style.backgroundPosition = '0 0'; }
    }
    function run(a, name, target) {   // play MOVES[name] on actor a; reach = cells to the target
      var m = MOVES[name], reach = 0;
      (a.fid || []).forEach(function (x) { x.cancel(); }); a.fid = null; a.nextFid = root.performance.now() + 4000 / sp();
      if (target) reach = Math.max(0, Math.abs(target.col - a.col) - 1.0 * sc * (a.rig.w + target.rig.w) / 2);
      var k = kfs(m, a, reach, c), dur = m.dur / sp();
      var o = { duration: dur, fill: m.keep ? 'forwards' : 'none' };
      var anim = a.body.animate(k.map(function (f) { return { offset: f.offset, transform: f.transform, filter: f.filter, opacity: f.opacity, easing: f.easing }; }), o);
      a.sh.animate(k.map(function (f) { return { offset: f.offset, transform: 'translate(' + f._x + 'px,0) scale(' + (1 - Math.min(.5, Math.max(0, -f._y / c) * .4)) + ')', opacity: f.opacity, easing: f.easing }; }), o);
      var P = m.pose && a.rig.kind === 'parts' ? (typeof m.pose === 'string' ? poseOf(a, m.pose) : (poseOf(a, m.pose.use) ? Object.assign({}, poseOf(a, m.pose.use), { len: poseOf(a, m.pose.use).dur }, m.pose) : null)) : null;
      if (P) {
        var pa = poseRun(a, P); if (m.keep || P.keep) a.held = (a.held || []).concat(pa);
        pa.forEach(function (x) { live.add(x); x.finished.then(function () { live.delete(x); }, function () { live.delete(x); }); });
      }
      if (m.clip && a.rig.kind === 'strip') {   // the walk strip plays while the gnome rushes in
        var wpx = a.rig.w * sc * c;
        a.spr.animate([{ backgroundPosition: '0 0' }, { backgroundPosition: (-a.rig.frames * wpx) + 'px 0' }], { duration: m.clip[1] / sp(), delay: m.clip[0] / sp(), easing: 'steps(' + a.rig.frames + ')' });
      }
      if (m.dust) for (var dt = m.dust[0]; dt < m.dust[1]; dt += 95) setTimeout(function () { puff(a); }, dt / sp());
      if (m.keep) anim.finished.then(function () { try { anim.commitStyles(); anim.cancel(); } catch (e) {} });   // a held end pose becomes plain style (a forwards-filled animation vanishes behind the tiles in a 3D board)
      live.add(anim); anim.finished.then(function () { live.delete(anim); }, function () { live.delete(anim); });
      return anim;
    }
    function poseOf(a, name) {   // the gnome's poses, or the creature's archetype poses ('atk' stands in for whichever attack move it uses)
      if (a.rig === RIGS.gnome) return POSES[name];
      var P = a.rig.poses; return P ? (P[name] || (MOVES[name] && MOVES[name].atk ? P.atk : null)) : null;
    }
    function poseRun(a, P, delay) {   // limb animation for a part rig; returns the animations. Keys: r deg, x/y (frame px, times the rig's scale u), sx/sy scale, o opacity
      var out = [], k = a.rig.w * sc * c / a.rig.fw * (a.rig.u || 1);
      a.rig.parts.forEach(function (pt) {
        var tr = P.tracks[pt.id]; if (!tr || !a.pel[pt.id]) return;
        var fade = tr.some(function (q) { return q[1].o != null; });
        var f = tr.map(function (q, i) {
          var s = q[1], o = { offset: q[0] / (P.len || P.dur), transform: 'translate(' + ((s.x || 0) * k) + 'px,' + ((s.y || 0) * k) + 'px) rotate(' + (s.r || 0) + 'deg) scale(' + (s.sx == null ? 1 : s.sx) + ',' + (s.sy == null ? 1 : s.sy) + ')', easing: tr[i + 1] && tr[i + 1][2] ? tr[i + 1][2] : 'linear' };
          if (fade) o.opacity = s.o == null ? 1 : s.o;
          return o;
        });
        a.pel[pt.id].forEach(function (e) { out.push(e.animate(f, { duration: P.dur / sp(), delay: ((delay || 0) + (pt.lag || 0)) / sp(), iterations: P.loops || 1, fill: P.keep ? 'forwards' : 'none' })); });
      });
      return out;
    }
    function hitstop(ms) {
      var l = []; live.forEach(function (x) { l.push(x); x.pause(); });
      return sleep(ms).then(function () { l.forEach(function (x) { x.play(); }); });
    }
    function shake(amp, crit) {   // the whole view shakes; a crit also pushes the camera in for a beat
      var z = crit ? ' scale(1.03)' : '';
      view.animate([{ transform: 'none' }, { transform: 'translate(' + amp + 'px,' + (-amp / 2) + 'px)' + z }, { transform: 'translate(' + (-amp) + 'px,0)' + z }, { transform: 'none' }], { duration: (crit ? 320 : 220) / sp(), easing: 'ease-out' });
    }
    function spot(a) { var r = a.body.getBoundingClientRect(), h = host.getBoundingClientRect(); return [r.left - h.left + r.width / 2, r.top - h.top + r.height * .35]; }
    function pop(a, txt, cls) {
      var p = spot(a), d = document.createElement('div');
      d.className = 'fe-dmg ' + (cls || ''); d.textContent = txt; d.style.left = (p[0] + 10) + 'px'; d.style.top = Math.max(6, p[1] - 46) + 'px'; fx.appendChild(d);
      d.animate([{ transform: 'translateY(8px) scale(.6)', opacity: 0 }, { transform: 'translateY(-4px) scale(1.25)', opacity: 1, offset: .2 }, { transform: 'translateY(-34px) scale(1)', opacity: 0 }], { duration: 950 / sp() }).finished.then(function () { d.remove(); });
    }
    function burst(a) {
      var p = spot(a), d = document.createElement('div'); d.className = 'fe-pow'; d.style.left = p[0] + 'px'; d.style.top = p[1] + 'px'; fx.appendChild(d);
      d.animate([{ transform: 'scale(.2) rotate(0)', opacity: 1 }, { transform: 'scale(1.3) rotate(25deg)', opacity: 0 }], { duration: 300 / sp() }).finished.then(function () { d.remove(); });
    }
    function swoosh(a) {   // arm-swing arc in front of the puncher
      var p = spot(a), d = document.createElement('div'); d.className = 'fe-swoosh';
      d.style.left = (p[0] + a.dir * 18) + 'px'; d.style.top = (p[1] - 4) + 'px'; if (a.dir < 0) d.style.transform = 'scaleX(-1)'; fx.appendChild(d);
      d.animate([{ opacity: .9, transform: 'scale(.5) rotate(-60deg)' }, { opacity: 0, transform: 'scale(1.25) rotate(40deg)' }], { duration: 260 / sp() }).finished.then(function () { d.remove(); });
    }
    function setHp(a, hp) { a.hp = Math.max(0, hp); if (a.bar) { a.bar.style.width = (100 * a.hp / a.max) + '%'; a.num.textContent = a.hp + '/' + a.max; } }

    function add(id, d) {
      var rig = rigFor(d.rig || id, d.sheet); if (d.size) rig = Object.assign({}, rig, { w: d.size, h: d.size });   // d.size: a small still picture (a pal beside the gnome)
      var a = { id: id, rig: rig, col: d.col, row: d.row == null ? rows >> 1 : d.row, dir: d.dir || 1, hp: d.hp || 10, max: d.max || d.hp || 10, flip: d.flip, springs: [], nextBlink: 0, nextFid: 0, fidN: 0 };
      var el = document.createElement('div'); el.className = 'fe-act';
      var body = document.createElement('div'); body.className = 'fe-body';
      var spr = document.createElement('i'); spr.className = 'fe-spr'; spr.style.transform = 'scaleX(' + (d.flip ? -1 : 1) + ')';
      var pel = {}, phys = {};
      function mk(cls) { var e = document.createElement('i'); e.className = cls; return e; }
      if (rig.kind === 'parts') [1, 0].forEach(function (row) {   // two copies of the bone tree: every ink (row 1) behind every paint (row 0), so the figure keeps ONE outline however the parts move
        var layer = mk('fe-part'), joint = {}, n = rig.cols.length; spr.appendChild(layer);
        rig.parts.forEach(function (pt) {
          if (row && pt.ink === false) return;
          var org = (pt.px[0] / rig.fw * 100) + '% ' + (pt.px[1] / rig.fh * 100) + '%', j = mk('fe-part'), pic = mk('fe-part'), top = j, col = rig.cols.indexOf(pt.img || pt.id);
          pic.style.backgroundImage = 'url("' + d.sheet + '")'; pic.style.backgroundSize = (n * 100) + '% 200%'; pic.style.backgroundPosition = (n > 1 ? col / (n - 1) * 100 : 0) + '% ' + (row * 100) + '%';
          if (!row && pt.dim) pic.style.filter = 'brightness(' + pt.dim + ')';
          j.style.transformOrigin = org; if (pt.ox) j.style.translate = (pt.ox / rig.fw * 100) + '% 0'; if (pt.hide) j.style.opacity = 0;
          j.appendChild(pic); j._pic = pic;
          var host = pt.parent && joint[pt.parent] ? joint[pt.parent] : layer;
          if (pt.phys || pt.spring) {   // top: the physics layer (set by the loop each frame); j: scripted poses
            top = mk('fe-part'); top.style.transformOrigin = org; top.appendChild(j); (phys[pt.id] = phys[pt.id] || []).push(top);
            if (pt.spring && !row) { var m = mk('fe-mk'); m.style.left = (pt.px[0] / rig.fw * 100) + '%'; m.style.top = (pt.px[1] / rig.fh * 100) + '%'; host.appendChild(m); a.springs.push({ id: pt.id, cfg: pt.spring, mk: m, r: 0, vr: 0, p: null, v: [0, 0], warm: 0 }); }
          }
          top._home = host;
          if (pt.under && host !== layer) host.insertBefore(top, host._pic); else host.appendChild(top);
          joint[pt.id] = j; (pel[pt.id] = pel[pt.id] || []).push(j);
        });
      }); else if (d.emoji) { spr.className += ' fe-emo'; spr.textContent = d.emoji; a.emoji = 1; }   // a prop that is not a creature (an event or a riddle): one big emoji standing opposite the gnome
      else spr.style.backgroundImage = 'url("' + d.img + '")';
      body.appendChild(spr); el.appendChild(body);
      var sh = document.createElement('div'); sh.className = 'fe-sh';
      board.appendChild(sh); actorsEl.appendChild(el);
      a.el = el; a.body = body; a.spr = spr; a.sh = sh; a.pel = pel; a.phys = phys; a.springs.forEach(function (q) { q.els = phys[q.id]; }); if (rig.hat) a.hat = { mode: 'worn', x: 0, y: 0, vx: 0, vy: 0, r: 0, vr: 0, tr: 0, tvr: 0, hold: 0, px: null, pvx: 0, pvy: 0, warm: 0 };
      if (d.side) {
        var hb = document.createElement('div'); hb.className = 'fe-hb ' + d.side;
        hb.innerHTML = '<b></b> <span></span><div class="fe-hp"><i></i></div>';
        hb.children[0].textContent = d.name || id; hud.appendChild(hb); a.hb = hb; a.num = hb.children[1]; a.bar = hb.children[2].children[0];
      }
      acts[id] = a; place(a); setHp(a, a.hp);
      var ip = rig.kind === 'parts' ? poseOf(a, 'idle') : null; if (ip) a.idleParts = poseRun(a, ip, -Math.random() * ip.dur);
      a.idle = body.animate(kfs(MOVES.idle, a, 0, c).map(function (f) { return { offset: f.offset, transform: f.transform, easing: f.easing }; }), { duration: 1600, iterations: Infinity, delay: -Math.random() * 1600 });
      return a;
    }
    /* Hat physics (rAF): the hat and its curl are springs driven by how the head moves, so every lunge, hit and hop gives follow-through for free.
     * worn = springs; free = flies off (hit hard), bounces, lies on the ground; fixing = the gnome puts it back, crooked, then straightens it. Units: gnome-frame px. */
    function headPos(a) { var r = a.pel.head[0].getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height * .2]; }
    function stepHat(a, dt) {
      var h = a.hat, k = a.rig.w * sc * c / 64, f = a.flip ? -1 : 1, p = headPos(a), ax = 0, ay = 0, n = 2, i, prevVr = h.vr;
      if (h.px && dt > 0) {
        var vx = (p[0] - h.px[0]) / dt / k * f, vy = (p[1] - h.px[1]) / dt / k;
        if (h.warm > 1) { ax = Math.max(-9000, Math.min(9000, (vx - h.pvx) / dt)); ay = Math.max(-9000, Math.min(9000, (vy - h.pvy) / dt)); }
        h.pvx = vx; h.pvy = vy; h.warm++;
        if (sp() > 4) { ax = 0; ay = 0; }   // skipping (tap, reduced motion): the body runs far faster than real time, so its movement would whip the hat; let the springs just settle
      }
      h.px = p; var q = dt / n;
      for (i = 0; i < n; i++) {
        if (h.mode === 'worn') {
          h.vx += (-220 * h.x - 14 * h.vx - .3 * ax) * q; h.vy += (-240 * h.y - 15 * h.vy - .3 * ay) * q;
          h.vr += (-260 * (h.r - h.hold) - 12 * h.vr - .2 * ax) * q;
          h.x = Math.max(-9, Math.min(9, h.x + h.vx * q)); h.y = Math.max(-7, Math.min(7, h.y + h.vy * q)); h.r = Math.max(-50, Math.min(50, h.r + h.vr * q));
        } else if (h.mode === 'free') {
          if (!h.rest) {
            h.vy += 900 * q; h.x += h.vx * q; h.y += h.vy * q; h.r += h.vr * q;
            if (h.y > 33) { h.y = 33; if (Math.abs(h.vy) > 70) { h.vy *= -.38; h.vx *= .6; h.vr *= .45; } else { h.rest = 1; h.vx = h.vy = h.vr = 0; } }
          } else h.r += (-82 - h.r) * Math.min(1, q * 14);
        } else if (h.mode === 'fixing') {
          h.ft += q; var u = Math.min(1, h.ft / .62), e = 1 - Math.pow(1 - u, 3);
          h.x = h.x0 * (1 - e); h.y = h.y0 * (1 - e) - 46 * Math.sin(Math.PI * u); h.r = h.r0 * (1 - e) - 22 * e; h.vr = 0;
          if (u >= 1) { h.mode = 'worn'; h.y = -4; h.vy = 70; h.x = 0; h.vx = 0; h.r = -22; h.hold = -22; }
        }
      }
      var acc = dt > 0 ? (h.vr - prevVr) / dt : 0;
      h.tvr += (-320 * h.tr - 9 * h.tvr - .45 * acc - .05 * ax) * dt; h.tr = Math.max(-60, Math.min(60, h.tr + h.tvr * dt));
      setT(a.phys.hat, 'translate(' + (h.x * k) + 'px,' + (h.y * k) + 'px) rotate(' + h.r + 'deg)');
      setT(a.phys.tip, 'rotate(' + h.tr + 'deg)');
      tapStep(a);
    }
    var last = 0;
    function tick(now) {
      if (dead) return;
      var dt = Math.min(.08, Math.min(.033, (now - (last || now)) / 1000) * sp()); last = now;   // capped: at skip speed (x40) a huge step would blow the hat springs up
      Object.keys(acts).forEach(function (k) { var a = acts[k]; if (a.hat) stepHat(a, dt); if (a.springs.length) stepSprings(a, dt); life(a, now); });
      root.requestAnimationFrame(tick);
    }
    function setT(list, t) { for (var i = 0; i < list.length; i++) list[i].style.transform = t; }
    function hatTo(a, world) {   // move the hat layers (ink and paint) between the gnome's head (worn) and a fixed ghost frame (fallen), keeping the hat where it is on screen
      var ws = a.phys.hat, w = ws[ws.length - 1], h = a.hat, k = a.rig.w * sc * c / 64, f = a.flip ? -1 : 1, b = w.getBoundingClientRect(), b0 = [b.left + b.width / 2, b.top + b.height / 2];
      if (world) {
        if (!a.ghost) {
          var g = a.el.cloneNode(false), gb = a.body.cloneNode(false), gs = a.spr.cloneNode(false);
          gb.appendChild(gs); g.appendChild(gb); actorsEl.appendChild(g); a.ghost = g; a.gspr = gs;
        }
        ws.forEach(function (x) { a.gspr.appendChild(x); });
        if (!a.mark) { a.mark = document.createElement('i'); a.mark.className = 'fe-hatmark'; w.appendChild(a.mark); }   // a point on the hat's brim: where the tap target goes
      } else {
        dropTap(a); ws.forEach(function (x) { x._home.appendChild(x); }); if (a.ghost) { a.ghost.remove(); a.ghost = a.gspr = null; }
      }
      setT(ws, 'translate(' + (h.x * k) + 'px,' + (h.y * k) + 'px) rotate(' + h.r + 'deg)');
      b = w.getBoundingClientRect(); h.x -= (b.left + b.width / 2 - b0[0]) * f / k; h.y -= (b.top + b.height / 2 - b0[1]) / k;
    }
    /* Springs: any part with a spring (beard, scarf, tails, ears, feelers, the segments of a worm) swings from how its bone moves on screen, so every lunge, hop and hit
     * gives follow-through for free. Acceleration whips it (g), speed drags it (w), the spring pulls it back (k) and damps it (d). Units: frame px and degrees. */
    function stepSprings(a, dt) {
      var k = a.rig.w * sc * c / a.rig.fw, f = a.flip ? -1 : 1, fast = sp() > 4, i, s, r, vx, vy, ax, ay, cf, d, tq, n;
      for (i = 0; i < a.springs.length; i++) { s = a.springs[i]; r = s.mk.getBoundingClientRect(); s.q = [r.left, r.top]; }   // read everything first, then write
      for (i = 0; i < a.springs.length; i++) {
        s = a.springs[i]; vx = vy = ax = ay = 0;
        if (s.p && dt > 0) {
          vx = (s.q[0] - s.p[0]) / dt / k * f; vy = (s.q[1] - s.p[1]) / dt / k;
          if (s.warm > 1 && !fast) { ax = Math.max(-9000, Math.min(9000, (vx - s.v[0]) / dt)); ay = Math.max(-9000, Math.min(9000, (vy - s.v[1]) / dt)); }
          s.v = [vx, vy]; s.warm++; if (fast) vx = vy = 0;
        }
        s.p = s.q; cf = s.cfg; d = cf.dir || [0, 1];
        tq = cf.g * (ax * d[1] - ay * d[0]) + (cf.w || 0) * (Math.max(-400, Math.min(400, vx)) * d[1] - Math.max(-400, Math.min(400, vy)) * d[0]);
        for (n = 0; n < 2; n++) { s.vr += (-cf.k * s.r - cf.d * s.vr + tq) * dt / 2; s.r = Math.max(-(cf.max || 40), Math.min(cf.max || 40, s.r + s.vr * dt / 2)); }
        setT(s.els, 'rotate(' + s.r + 'deg)');
      }
    }
    /* Life while standing: a blink every few seconds, and now and then a fidget (rig.fidgets, in turn) when nothing else is playing. */
    function life(a, now) {
      if (reduce || a.hp <= 0 || a.gone || a.rig.kind !== 'parts') return;
      if (now > a.nextBlink) { var first = !a.nextBlink; a.nextBlink = now + (1800 + Math.random() * 3600) / sp(); var B = poseOf(a, 'blink'); if (B && !first) poseRun(a, B); }
      if (!a.nextFid) a.nextFid = now + (2500 + Math.random() * 4000) / sp();
      if (busy || (a.held && a.held.length) || now < a.nextFid) return;
      a.nextFid = now + (4500 + Math.random() * 5000) / sp();
      var l = a.rig.fidgets, P = l && l.length ? poseOf(a, l[a.fidN++ % l.length]) : null;
      if (P && !(P.hat && a.hat && a.hat.mode !== 'worn')) a.fid = poseRun(a, P);
    }
    /* Tap the fallen hat (between turns) to put it back on: the host decides what that is worth (opts.onHatTap(id) -> ask the server); with no callback the engine plays a local +5 heal. */
    function dropTap(a) { if (a.tap) { a.tap.remove(); a.tap = null; } }
    function tapHat(a) {
      if (busy || a.hp <= 0 || !a.hat || a.hat.mode !== 'free') return;
      if (opts.onHatTap) opts.onHatTap(a.id); else play([{ from: a.id, move: 'fixhat', heal: 5 }]);
    }
    function tapStep(a) {   // make, show, hide and place the tap target
      var h = a.hat, ok = h.mode === 'free' && h.rest && a.hp > 0;
      if (!ok) { dropTap(a); return; }
      if (!a.tap) {
        var b = document.createElement('button'); b.type = 'button'; b.className = 'fe-hattap'; b.setAttribute('aria-label', 'Pick up the hat');
        b.onclick = function () { tapHat(a); }; host.appendChild(b); a.tap = b;
      }
      a.tap.style.display = busy ? 'none' : '';
      if (!busy && a.mark) { var r = a.mark.getBoundingClientRect(), hr = host.getBoundingClientRect(); a.tap.style.left = (r.left - hr.left) + 'px'; a.tap.style.top = (r.top - hr.top) + 'px'; }
    }
    function popHat(a, away) {   // the hat comes off: up, back, spinning
      var h = a.hat; if (!h || h.mode !== 'worn') return;
      hatTo(a, true); h.mode = 'free'; h.rest = 0; h.hold = 0; h.vy = -300; h.vx = -50 * (away || 1); h.vr = -520; h.tvr += 400;
    }
    function dropHat(a, away) {   // v2.6.07: the hat is already on the ground (an earlier turn): lay it down at once, no flight
      var h = a.hat; if (!h || h.mode !== 'worn') return;
      popHat(a, away); h.rest = 1; h.vx = h.vy = h.vr = 0; h.y = 33; h.r = -82; h.tvr = 0; h.tr = 0;
    }
    function fixHat(a) {   // run the 'fixhat' move: hat hops back on crooked, a pat or two straightens it
      var h = a.hat; if (!h || h.mode === 'worn') return Promise.resolve();
      hatTo(a, false); h.mode = 'fixing'; h.ft = 0; h.x0 = h.x; h.y0 = h.y; h.r0 = h.r;
      var an = run(a, 'fixhat');
      sleep(830).then(function () { h.hold = 0; h.tvr -= 260; });
      return an.finished;
    }
    function puff(a) {   // a little dust at the feet
      var b = a.body.getBoundingClientRect(), h = host.getBoundingClientRect(), d = document.createElement('div');
      d.className = 'fe-dust'; d.style.left = (b.left - h.left + b.width / 2 - a.dir * 8) + 'px'; d.style.top = (b.bottom - h.top - 4) + 'px'; fx.appendChild(d);
      d.animate([{ transform: 'translate(-50%,-50%) scale(.4)', opacity: .8 }, { transform: 'translate(' + (-a.dir * 10 - 50) + '%,-120%) scale(1.5)', opacity: 0 }], { duration: 420 / sp() }).finished.then(function () { d.remove(); });
    }
    function stars(a) {   // dizzy stars circle the head
      var p = spot(a), o = document.createElement('div'); o.className = 'fe-stars'; o.style.left = p[0] + 'px'; o.style.top = (p[1] - 12) + 'px';
      o.innerHTML = '<i>★</i><i>★</i><i>★</i>'; fx.appendChild(o); a.starsEl = o;
      o.animate([{ transform: 'rotate(0)' }, { transform: 'rotate(360deg)' }], { duration: 1100 / sp(), iterations: Infinity });
    }
    function stopIdle(a) { a.idle.cancel(); (a.idleParts || []).forEach(function (x) { x.cancel(); }); }
    function face() {   // everyone looks at the other side
      var l = Object.keys(acts).map(function (k) { return acts[k]; });
      l.forEach(function (a) { var o = l.filter(function (b) { return b !== a; })[0]; if (o) a.dir = o.col > a.col ? 1 : -1; });
    }
    function step(ev) {
      var a = acts[ev.from], tg = ev.to ? acts[ev.to] : null; face();
      if (ev.move === 'fixhat') {   // pick the hat up: it hops back on; a heal (decided by the server) ticks the bar
        var heal = Math.max(0, Math.min(ev.heal || 0, a.max - a.hp));
        if (heal) sleep(620).then(function () { setHp(a, a.hp + heal); pop(a, '+' + heal, 'heal'); });
        return fixHat(a);
      }
      if (ev.end || ev.move === 'end') return Promise.resolve();
      if (!a) return Promise.resolve();
      if (ev.move === 'hurt') {   // damage with no attacker (poison, a pal's strike): number pops, bar drops, target flinches
        var wasH = a.hp; pop(a, '-' + (ev.dmg || 0)); setHp(a, a.hp - (ev.dmg || 0)); var hh = run(a, 'hit');
        return hh.finished.then(function () { if (a.hp <= 0 && wasH > 0) { stopIdle(a); if (a.rig.lingers) return run(a, 'koL').finished; a.sh.style.opacity = 0; return run(a, 'ko').finished; } });
      }
      if (ev.move === 'heal' || ev.move === 'snack') { var hl = Math.max(0, Math.min(ev.heal || 0, a.max - a.hp)), sa = run(a, ev.move === 'snack' ? 'snack' : 'cheer'); if (hl) sleep(ev.move === 'snack' ? 650 : 200).then(function () { setHp(a, a.hp + hl); pop(a, '+' + hl, 'heal'); }); return sa.finished; }
      if (ev.move === 'mend') { var ml = Math.max(0, Math.min(ev.heal || 0, a.max - a.hp)); if (ml) { setHp(a, a.hp + ml); pop(a, '+' + ml, 'heal'); } return sleep(450); }   // health back with no pose of the gnome's own (a pal did it)
      if (ev.move === 'stumble') { pop(a, 'trips!', 'miss'); return run(a, 'dodge').finished; }
      if (ev.move === 'charm' || ev.move === 'dazed' || ev.move === 'note') { pop(a, ev.text || (ev.move === 'charm' ? (ev.ok === false ? 'no charm' : 'charmed!') : ev.move === 'dazed' ? 'dazed' : '...'), ev.move === 'charm' && ev.ok !== false ? 'heal' : 'miss'); return sleep(350); }
            if (ev.move === 'guard') { var g = document.createElement('div'); g.className = 'fe-guard'; a.body.appendChild(g); a.guardEl = g; return run(a, 'guard').finished; }
      if (ev.move === 'flee') { if (a.guardEl) { a.guardEl.remove(); a.guardEl = null; } (a.held || []).forEach(function (x) { x.cancel(); }); a.held = []; stopIdle(a); a.gone = 1; a.sh.style.opacity = 0; return run(a, 'flee').finished; }
      var name = ev.move || a.rig.attack, m = MOVES[name], atk = run(a, name, tg);
      if (m.swoosh) sleep(m.swoosh).then(function () { swoosh(a); });
      if (!tg) return atk.finished;
      return sleep(m.hit).then(function () {
        if (ev.miss) { pop(tg, 'miss', 'miss'); run(tg, 'dodge'); return; }
        if (tg.guardEl) { tg.guardEl.remove(); tg.guardEl = null; (tg.held || []).forEach(function (x) { x.cancel(); }); tg.held = []; pop(tg, 'block', 'miss'); }
        if (m.fx) burst(tg);
        var was = tg.hp; pop(tg, '-' + ev.dmg); setHp(tg, tg.hp - ev.dmg);
        var h = run(tg, 'hit'); shake(ev.crit ? 6 : 3, ev.crit);
        if (tg.hat && (ev.pop || tg.hp <= 0 || (was >= tg.max * .25 && tg.hp < tg.max * .25))) popHat(tg, tg.dir);   // hat comes off when a hit takes him below 25% (or KO, or the server says so)
        return hitstop(ev.crit ? 110 : 70).then(function () { return h.finished; }).then(function () { if (tg.hp <= 0) { stopIdle(tg); if (tg.hb) tg.hb.style.opacity = 0; if (tg.rig.lingers) { var kl = run(tg, 'koL'); sleep(750).then(function () { stars(tg); }); return kl.finished; } tg.sh.style.opacity = 0; return run(tg, 'ko').finished; } });
      }).then(function () { return atk.finished; }).then(function () { if (a.hat && tg.hp <= 0 && !ev.miss && !holdCheer) return sleep(200).then(function () { return run(a, 'cheer').finished; }); });
    }
    var holdCheer = false;   // host has a reward scene coming: it does the victory jump itself
    function together(list) { busy++; return Promise.all(list.map(step)).then(function () { busy--; }); }
    function finish() {   // fight over: anyone still standing with a hat on the ground puts it back on (no heal)
      return Promise.all(Object.keys(acts).map(function (k) { var a = acts[k]; return a.hat && a.hp > 0 ? sleep(250).then(function () { return fixHat(a); }) : null; }));
    }
    function play(list) {   // the hat stays down between turns (tap it); when someone is KO'd or flees, the fight is over and the survivor refits it
      busy++;
      return list.reduce(function (p, ev) { return p.then(function () { return step(ev); }).then(function () { return sleep(150); }); }, Promise.resolve()).then(function () {
        busy--;
        var over = list.some(function (ev) { return ev.move === 'flee' || !!ev.end; }) || Object.keys(acts).some(function (k) { return acts[k].hp <= 0; });
        return over ? finish() : null;
      });
    }
    /* The end scene: after the last blow the foe's XP and loot drop on the ground (a little hop), rest a moment with their names, then are slowly drawn into the gnome.
     * rw = {xp, lvl, loot:[{name, qty, img}]}. Returns a promise that resolves when the last one is in (the host then lets the player move again). */
    function reward(rw) {
      var me = acts.me, foe = acts.foe;
      holdCheer = false;
      if (!me || !foe || me.hp <= 0) return Promise.resolve();
      var drops = [], fp = spot(foe), list = [];
      if (rw.xp) list.push({ xp: 1, label: '+' + rw.xp + ' XP' });
      (rw.loot || []).forEach(function (l) { list.push({ img: l.img, label: (l.qty > 1 ? l.qty + ' × ' : '') + l.name }); });
      if (!list.length) return run(me, 'cheer').finished;
      var br = me.body.getBoundingClientRect(), hr = host.getBoundingClientRect(), n = list.length;
      var vl = Math.max(0, -hr.left) + 8, vr = Math.min(hr.width, (root.innerWidth || hr.width) - hr.left) - 8;   // the part of the stage actually on screen
      var gap = Math.max(34, Math.min(70, (vr - vl) / Math.max(1, n))), half = gap * (n - 1) / 2;
      var cx = Math.max(vl + half + 26, Math.min(vr - half - 26, br.left - hr.left + br.width / 2));   // centred over the head, kept on screen
      var ty = Math.max(54, br.top - hr.top - br.height * .62 - 16);   // above where he jumps to, so he never covers them
      list.forEach(function (d, i) {
        var el = document.createElement('div'); el.className = 'fe-drop' + (d.xp ? ' xp' : '');
        if (d.img) { var im = document.createElement('img'); im.src = d.img; im.alt = ''; el.appendChild(im); } else el.textContent = d.xp ? '✦' : '🎁';
        var lb = document.createElement('span'); lb.className = 'fe-droplbl' + (i % 2 && gap < 64 ? ' hi' : ''); lb.style.maxWidth = Math.max(60, gap * 1.9) + 'px'; lb.textContent = d.label; el.appendChild(lb);
        d.tx = cx + (i - (n - 1) / 2) * gap; d.ty = ty;
        el.style.left = fp[0] + 'px'; el.style.top = fp[1] + 'px'; el.style.opacity = 0; fx.appendChild(el);
        d.el = el; drops.push(d);
      });
      if (reduce) {   // reduced motion: no flying. The rewards sit still over the gnome's head with their names for a moment (a tap skips), then are counted in
        drops.forEach(function (d) { d.el.style.left = d.tx + 'px'; d.el.style.top = d.ty + 'px'; d.el.style.transform = 'translate(-50%,-50%)'; d.el.style.opacity = 1; d.el.classList.add('show'); });
        return new Promise(function (res) { var t = setTimeout(res, 1800); host.addEventListener('click', function () { clearTimeout(t); res(); }, { once: true }); }).then(function () {
          drops.forEach(function (d) { d.el.remove(); pop(me, d.label, d.xp ? 'xp' : 'heal'); });
          return sleep(rw.lvl ? 0 : 250).then(function () { if (rw.lvl) { pop(me, 'LEVEL UP!', 'xp'); return sleep(900); } });
        });
      }
      var cheer = run(me, 'cheer');
      return Promise.all(drops.map(function (d, i) {   // 1: hop out of the foe and arc up over the gnome's head
        return sleep(i * 140).then(function () {
          return d.el.animate([
            { transform: 'translate(-50%,-50%) scale(.3)', opacity: 0 },
            { transform: 'translate(calc(-50% + ' + ((d.tx - fp[0]) * .5) + 'px),calc(-50% + ' + ((d.ty - fp[1]) * .5 - 40) + 'px)) scale(1.15)', opacity: 1, offset: .5, easing: 'ease-in' },
            { transform: 'translate(calc(-50% + ' + (d.tx - fp[0]) + 'px),calc(-50% + ' + (d.ty - fp[1]) + 'px)) scale(1)', opacity: 1 }
          ], { duration: 640 / sp(), fill: 'forwards', easing: 'ease-out' }).finished;
        });
      })).then(function () { d_show(drops); return cheer.finished; })   // 2: he jumps for joy underneath, names showing
        .then(function () { return sleep(500); })
        .then(function () {   // 3: slowly drawn down into him, one after another
          var m2 = spot(me);
          return Promise.all(drops.map(function (d, i) {
            return sleep(i * 240).then(function () {
              d.el.classList.remove('show');
              var a = d.el.animate([
                { transform: 'translate(calc(-50% + ' + (d.tx - fp[0]) + 'px),calc(-50% + ' + (d.ty - fp[1]) + 'px)) scale(1)', opacity: 1 },
                { transform: 'translate(calc(-50% + ' + (m2[0] - fp[0]) + 'px),calc(-50% + ' + (m2[1] - fp[1]) + 'px)) scale(.2)', opacity: .2 }
              ], { duration: 900 / sp(), fill: 'forwards', easing: 'ease-in' });
              return a.finished.then(function () {
                d.el.remove();
                var bump = me.body.animate([{ transform: 'scale(1)' }, { transform: 'scale(1.1,.92)' }, { transform: 'scale(1)' }], { duration: 260 / sp() });
                pop(me, d.label, d.xp ? 'xp' : 'heal');
                return bump.finished;
              });
            });
          }));
        }).then(function () { if (rw.lvl) { pop(me, 'LEVEL UP!', 'xp'); return sleep(900); } return sleep(250); });
    }
    function d_show(drops) { drops.forEach(function (d) { d.el.classList.add('show'); }); }
    var ro = root.ResizeObserver ? new root.ResizeObserver(function () { if (!dead && host.clientWidth !== lastW) layout(); }) : null, lastW = 0;   // the stage itself can change width with no window resize (a grid settling, a panel opening)
    function destroy() { dead = true; if (ro) ro.disconnect(); root.removeEventListener('resize', layout); host.innerHTML = ''; acts = {}; }   // stop the physics loop and the resize hook (call before re-creating on the same host)
    layout(); root.addEventListener('resize', layout); if (ro) ro.observe(host); root.requestAnimationFrame(tick);
    function fidget(id, name) { var a = acts[id], P = a && poseOf(a, name); if (!P || busy) return; (a.fid || []).forEach(function (x) { x.cancel(); }); a.fid = poseRun(a, P); a.nextFid = root.performance.now() + (P.dur + 3000) / sp(); }   // play one fidget now (demo, tests)
    return { destroy: destroy, fidget: fidget, pose: function (id, name) { var a = acts[id], P = a && poseOf(a, name); return P ? poseRun(a, P) : []; }, finish: finish, reward: reward, add: add, play: play, popHat: popHat, dropHat: dropHat, fixHat: fixHat, together: together, acts: acts, layout: layout, setSpeed: function (s) { speed = s; }, holdCheer: function (v) { holdCheer = !!v; }, MOVES: MOVES };
  }
  /* Data lint: returns a list of problems (empty = fine). Run by tools/fight/smoke.js; catches the mistakes that used to crash animate() at play time. */
  function validate() {
    var bad = [], partIds = RIGS.gnome.parts.map(function (p) { return p.id; });
    function times(list, dur, where) {
      list.forEach(function (k, i) {
        if (typeof k[0] !== 'number') bad.push(where + ': key ' + i + ' has no time');
        else if (k[0] > dur) bad.push(where + ': key at ' + k[0] + ' is past dur ' + dur);
        if (i && k[0] < list[i - 1][0]) bad.push(where + ': times go backwards at ' + k[0]);
      });
    }
    RIGS.gnome.parts.forEach(function (p) { if (RIGS.gnome.cols.indexOf(p.img || p.id) < 0) bad.push('RIGS.gnome: no sheet column for ' + p.id); if (p.parent && partIds.indexOf(p.parent) < 0) bad.push('RIGS.gnome: ' + p.id + ' hangs from unknown ' + p.parent); });
    (RIGS.gnome.fidgets || []).forEach(function (n) { if (!POSES[n]) bad.push('RIGS.gnome: no fidget pose ' + n); });
    var archPose = {}, seen = {}, anyBone = {};   // an archetype's pose set is shared by its kinds, so a track may name a bone only some of them have
    Object.keys(DATA.skel).forEach(function (k) { Object.keys(DATA.skel[k]).forEach(function (b) { anyBone[b] = 1; }); });
    Object.keys(DATA.rigs).forEach(function (slug) {   // every creature: bones known, parents drawn, its attack exists; its archetype's poses only name bones of that archetype
      var d = DATA.rigs[slug], sk = DATA.skel[d[0]], ids = d[4].split(','), A = archOf(d[0]), w = 'rig ' + slug;
      if (!sk) { bad.push(w + ': no skeleton ' + d[0]); return; }
      ids.forEach(function (id) { if (!sk[id]) bad.push(w + ': no bone ' + id); else if (sk[id][0] && ids.indexOf(sk[id][0]) < 0) bad.push(w + ': ' + id + ' hangs from ' + sk[id][0] + ', which is not drawn'); });
      var atk = ((ARCH.slug || {})[slug] || {}).attack || A.attack || 'charge';
      if (!MOVES[atk]) bad.push(w + ': no move ' + atk);
      if (seen[d[0]]) return; seen[d[0]] = 1;
      if (!A.poses) { bad.push('arch ' + d[0] + ': no poses'); return; }
      Object.keys(A.poses).forEach(function (pn) {
        archPose[pn] = 1; var P = A.poses[pn];
        Object.keys(P.tracks).forEach(function (part) { if (!anyBone[part]) bad.push('arch ' + d[0] + ' pose ' + pn + ': unknown part ' + part); times(P.tracks[part], P.dur, 'arch ' + d[0] + '.' + pn + '.' + part); });
      });
      (A.fidgets || []).forEach(function (n) { if (!A.poses[n]) bad.push('arch ' + d[0] + ': no fidget pose ' + n); });
    });
    Object.keys(MOVES).forEach(function (n) {
      var m = MOVES[n], w = 'MOVES.' + n; times(m.keys, m.dur, w);
      if (m.hit > m.dur) bad.push(w + ': hit past dur');
      var known = function (q) { return POSES[q] || archPose[q] || m.atk; };
      if (m.pose && typeof m.pose === 'string' && !known(m.pose)) bad.push(w + ': unknown pose ' + m.pose);
      if (m.pose && m.pose.use && !known(m.pose.use)) bad.push(w + ': unknown pose.use ' + m.pose.use);
      if (m.keys[m.keys.length - 1][0] !== m.dur) bad.push(w + ': last key is not at dur (the move would snap)');
    });
    Object.keys(POSES).forEach(function (n) {
      var p = POSES[n]; Object.keys(p.tracks).forEach(function (part) {
        if (partIds.indexOf(part) < 0) bad.push('POSES.' + n + ': unknown part ' + part);
        times(p.tracks[part], p.dur, 'POSES.' + n + '.' + part);
      });
    });
    return bad;
  }
  root.FightEngine = { validate: validate, create: create, MOVES: MOVES, POSES: POSES, RIGS: RIGS, DATA: DATA, ARCH: ARCH, hasRig: function (slug) { return !!DATA.rigs[slug]; } };
})(window);
