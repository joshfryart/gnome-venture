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
    pluck: { dur: 860, hit: 440, fx: 'pow', swoosh: 415, dust: [250, 430], pose: 'pluck', keys: [      // gnome, bare-handed: Gnome Pluck (wind up, run in, swing the arm)
      [0, {}], [160, { dx: -.15, sx: 1.06, sy: .92, r: -8 }, E.out], [240, { dx: -.2, sx: 1.08, sy: .9, r: -10 }, E.io],
      [420, { x: .97, y: -.12, sx: .92, sy: 1.1, r: 12 }, E['in']], [470, { x: 1, sx: 1.14, sy: .88, r: 5 }, E.out],
      [660, { x: .95 }, E.out], [860, {}, E.io]] },
    charge: { dur: 900, hit: 430, fx: 'pow', keys: [
      [0, {}], [200, { dx: -.25, sx: 1.1, sy: .9, r: -4 }, E.out], [260, { dx: -.25, y: -.08 }], [320, { dx: -.25 }],
      [430, { x: 1, sx: 1.12, sy: .92, r: 6 }, E['in']], [480, { x: 1, sx: .85, sy: 1.1 }, E.out], [700, { x: .7 }, E.out], [900, {}, E.io]] },
    pounce: { dur: 850, hit: 410, fx: 'pow', keys: [
      [0, {}], [220, { dx: -.1, sx: 1.15, sy: .78 }, E.out], [330, { x: .5, y: -1.1, sx: .9, sy: 1.15, r: -10 }, E.out],
      [410, { x: 1, y: -.2, sx: 1.1, sy: .9, r: 10 }, E['in']], [470, { x: 1, sx: 1.12, sy: .85 }, E.out], [850, {}, E.io]] },
    hop: { dur: 800, hit: 360, fx: 'pow', keys: [
      [0, {}], [120, { sx: 1.12, sy: .85 }, E.out], [220, { x: .45, y: -.5, sy: 1.1, sx: .94 }, E.out], [300, { x: .5, sx: 1.1, sy: .88 }, E['in']],
      [360, { x: 1, y: -.45, sx: .9, sy: 1.12 }, E.out], [440, { x: 1, sx: 1.12, sy: .85 }, E['in']], [800, {}, E.io]] },
    slam: { dur: 1100, hit: 620, fx: 'pow', keys: [
      [0, {}], [300, { y: -.3, sy: 1.2, sx: .92, r: -8 }, E.out], [480, { y: -.3, sy: 1.22, sx: .9, r: -10 }], [620, { x: .85, y: .05, sy: .8, sx: 1.2, r: 10 }, E['in']],
      [720, { x: .85, sy: .86, sx: 1.14 }, E.out], [1100, {}, E.io]] },
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
  /* Limb poses for part rigs: per part [ms, {r deg (clockwise +), x px, y px}, ease-in-to-next]. Positive r = limb swings BACK (the gnome faces right); forward = negative.
   * Parts: arms hang from the shoulder, legs from the hip, torso (hat, head, beard, body) from the hips. px are gnome-frame pixels (64x80). */
  var POSES = {
    idle: { dur: 1600, loops: Infinity, tracks: { torso: [[0, {}], [800, { y: -1 }, E.io], [1600, {}, E.io]], armF: [[0, {}], [800, { r: 3 }, E.io], [1600, {}, E.io]], armB: [[0, {}], [800, { r: -3 }, E.io], [1600, {}, E.io]] } },
    run: { dur: 480, loops: Infinity, tracks: {
      torso: [[0, { r: 7 }], [120, { r: 7, y: -2 }], [240, { r: 7 }], [360, { r: 7, y: -2 }], [480, { r: 7 }]],
      legF: [[0, { r: -38 }], [120, { r: 0, y: -3 }], [240, { r: 38 }], [360, { r: 0, y: -3 }], [480, { r: -38 }]],
      legB: [[0, { r: 38 }], [120, { r: 0, y: -3 }], [240, { r: -38 }], [360, { r: 0, y: -3 }], [480, { r: 38 }]],
      armF: [[0, { r: 50 }], [240, { r: -50 }, E.io], [480, { r: 50 }, E.io]], armB: [[0, { r: -50 }], [240, { r: 50 }, E.io], [480, { r: -50 }, E.io]] } },
    pluck: { dur: 860, tracks: {
      torso: [[0, {}], [45, { r: -5 }], [90, { r: 4 }], [135, { r: -7 }], [180, { r: 3 }], [210, { r: -10 }], [240, { r: -12 }], [330, { r: 6, y: -1 }], [420, { r: 10 }], [470, { r: 13 }, E.out], [660, { r: 6 }], [860, {}, E.io]],
      armF: [[0, {}], [160, { r: 115 }, E.out], [240, { r: 128 }], [330, { r: 120 }], [420, { r: 112 }], [445, { r: -70 }, E['in']], [500, { r: -105 }, E.out], [660, { r: -60 }], [860, {}, E.io]],
      armB: [[0, {}], [160, { r: -30 }], [240, { r: -45 }], [330, { r: 50 }], [420, { r: -40 }], [470, { r: -70 }], [860, {}, E.io]],
      legF: [[0, {}], [45, { r: 10 }], [90, { r: -10 }], [135, { r: 12 }], [180, { r: -9 }], [240, { r: -10 }], [285, { r: -38 }], [330, { r: 0, y: -3 }], [375, { r: 38 }], [420, { r: -25 }], [470, { r: -15 }], [860, {}, E.io]],
      legB: [[0, {}], [45, { r: -10 }], [90, { r: 10 }], [135, { r: -12 }], [180, { r: 9 }], [240, { r: 10 }], [285, { r: 38 }], [330, { r: 0, y: -3 }], [375, { r: -38 }], [420, { r: 25 }], [470, { r: 15 }], [860, {}, E.io]] } },
    hit: { dur: 380, tracks: { torso: [[0, {}], [60, { r: -14 }, E.out], [380, {}, E.io]], armF: [[0, {}], [60, { r: 75 }, E.out], [200, { r: 25 }], [380, {}, E.io]], armB: [[0, {}], [60, { r: -65 }, E.out], [200, { r: -20 }], [380, {}, E.io]], legF: [[0, {}], [60, { r: -14 }, E.out], [380, {}, E.io]], legB: [[0, {}], [60, { r: 10 }, E.out], [380, {}, E.io]] } },
    dodge: { dur: 520, tracks: { torso: [[0, {}], [120, { r: 8 }, E.out], [300, { r: -4 }], [520, {}, E.io]], armF: [[0, {}], [120, { r: -50 }, E.out], [300, { r: 20 }], [520, {}, E.io]], armB: [[0, {}], [120, { r: 40 }, E.out], [520, {}, E.io]], legF: [[0, {}], [120, { r: -35, y: -4 }, E.out], [300, { r: 10 }], [520, {}, E.io]], legB: [[0, {}], [120, { r: -25, y: -4 }, E.out], [300, { r: 5 }], [520, {}, E.io]] } },
    ko: { dur: 900, keep: 1, tracks: { torso: [[0, {}], [120, { r: -10 }, E.out], [500, { r: -12 }], [900, { r: -6 }, E.out]], armF: [[0, {}], [120, { r: 70 }, E.out], [500, { r: 135 }], [900, { r: 150 }, E.out]], armB: [[0, {}], [120, { r: -70 }, E.out], [500, { r: -120 }], [900, { r: -135 }, E.out]], legF: [[0, {}], [500, { r: -25 }], [900, { r: -40 }, E.out]], legB: [[0, {}], [500, { r: 20 }], [900, { r: 35 }, E.out]] } },
    cheer: { dur: 1000, tracks: { torso: [[0, {}], [300, { r: -6 }, E.out], [620, { r: 5 }], [1000, {}, E.io]], armF: [[0, {}], [220, { r: -150 }, E.out], [330, { r: -168 }], [450, { r: -150 }], [620, { r: -170 }], [1000, {}, E.io]], armB: [[0, {}], [300, { r: -40 }], [620, { r: -55 }], [1000, {}, E.io]], legF: [[0, {}], [300, { r: -18 }], [620, { r: -14 }], [1000, {}, E.io]], legB: [[0, {}], [300, { r: 18 }], [620, { r: 14 }], [1000, {}, E.io]] } },
    fixhat: { dur: 1500, tracks: { torso: [[0, {}], [500, { r: -4 }, E.io], [900, { r: 3 }], [1500, {}, E.io]], armF: [[0, {}], [450, {}], [680, { r: -155 }, E.out], [830, { r: -170 }], [930, { r: -150 }], [1030, { r: -170 }], [1500, {}, E.io]], armB: [[0, {}], [500, { r: 30 }], [1500, {}, E.io]], legF: [[0, {}], [1500, {}]], legB: [[0, {}], [1500, {}]] } },
    walk: { dur: 720, loops: Infinity, tracks: { torso: [[0, { r: 3 }], [180, { r: 3, y: -1 }], [360, { r: 3 }], [540, { r: 3, y: -1 }], [720, { r: 3 }]], legF: [[0, { r: -22 }], [360, { r: 22 }, E.io], [720, { r: -22 }, E.io]], legB: [[0, { r: 22 }], [360, { r: -22 }, E.io], [720, { r: 22 }, E.io]], armF: [[0, { r: 28 }], [360, { r: -28 }, E.io], [720, { r: 28 }, E.io]], armB: [[0, { r: -28 }], [360, { r: 28 }, E.io], [720, { r: -28 }, E.io]] } },
    guard: { dur: 300, keep: 1, tracks: { torso: [[0, {}], [300, { r: -4 }, E.out]], armF: [[0, {}], [300, { r: -95 }, E.out]], armB: [[0, {}], [300, { r: -80 }, E.out]] } }
  };
  /* A rig = how to draw and size an actor. strip: sheet of equal frames (gnome25, 8 of 64x80). still: one picture (mini art, faces right).
   * Later: per-creature 'sheet' rigs with clips, same shape as the gnome. w/h are in board cells. */
  var RIGS = {
    // parts rig: cut by tools/gnome_rig_parts.php. id = limb name, img = file key, px = pivot, ox = x shift, dim = brightness (the far arm).
    gnome: { kind: 'parts', w: 2, h: 2.5, attack: 'pluck', unarmed: 1, parts: [
      { id: 'armB', img: 'arm', px: [33, 48], ox: 4, dim: .72, lag: 20 }, { id: 'legB', img: 'legB', px: [28, 63], dim: .82 }, { id: 'torso', img: 'torso', px: [32, 64] },
      { id: 'legF', img: 'legF', px: [36, 63] }, { id: 'armF', img: 'arm', px: [33, 48], lag: 35 },
      { id: 'hat', img: 'hat', px: [32, 37], phys: 1 }, { id: 'tip', img: 'tip', px: [28, 11], phys: 1, parent: 'hat' }], lingers: 1, hat: 1 },
    creature: { kind: 'still', w: 2.3, h: 2.3, attack: 'charge' }
  };
  var ATTACK = { 'wild-boar': 'charge', 'bramble-wolf': 'pounce', 'bullfrog': 'hop', 'black-bear': 'slam', 'cliff-ram': 'charge', 'dune-scorpion': 'pounce' };
  var SIZE = { 'black-bear': 2.8, 'bullfrog': 1.8, 'dune-scorpion': 2.2 };

  function rigFor(id) {
    if (id === 'gnome') return RIGS.gnome;
    var r = Object.assign({}, RIGS.creature);
    r.attack = ATTACK[id] || r.attack;
    if (SIZE[id]) r.w = r.h = SIZE[id];
    return r;
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
    var cols = opts.cols || 11, rows = opts.rows || 7, speed = opts.speed || 1, c = 30, acts = {}, live = new Set();
    var reduce = root.matchMedia && root.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var terrain = opts.terrain || function (x, y) { return y === (rows >> 1) ? 'p' : ((x + y) % 5 === 0 ? 'f' : (x * y % 7 === 3 ? 'r' : '')); };
    host.classList.add('fe-stage');
    host.innerHTML = '<div class="fe-view"><div class="fe-board"><div class="fe-grid"></div></div><div class="fe-actors"></div></div><div class="fe-hud"></div><div class="fe-fx"></div>';
    var view = host.children[0], board = view.children[0], actorsEl = view.children[1], grid = board.children[0], hud = host.children[1], fx = host.children[2];
    var t = '', dead = false;
    for (var y = 0; y < rows; y++) for (var x = 0; x < cols; x++) t += '<div class="fe-t ' + terrain(x, y) + '"></div>';
    grid.innerHTML = t; grid.style.gridTemplateColumns = 'repeat(' + cols + ',1fr)';

    function sp() { return reduce ? 40 : speed; }
    function sleep(ms) { return new Promise(function (r) { setTimeout(r, ms / sp()); }); }
    function layout() {
      var w = host.clientWidth - 16; c = (w - (cols - 1)) / cols;
      board.style.width = w + 'px'; view.style.paddingTop = (.5 * c) + 'px';
      Object.keys(acts).forEach(function (k) { place(acts[k]); });
    }
    /* Actors are NOT 3D objects: the board is tilted with one perspective transform, and each actor is an upright, screen-aligned picture put at the projected
     * position of its feet, scaled by the local perspective scale. No depth sorting, so a body can lie down, rotate or fly without vanishing behind tiles. */
    var TILT = 'perspective(520px) rotateX(42deg) scale(.96)';
    function proj(x, y) {   // board-local px -> [x, y, scale] in the view
      var W = board.offsetWidth, H = board.offsetHeight, m = new DOMMatrix('translate(' + (W / 2) + 'px,' + H + 'px) ' + TILT + ' translate(' + (-W / 2) + 'px,' + (-H) + 'px)');
      var p = m.transformPoint(new DOMPoint(x, y, 0, 1)), q = m.transformPoint(new DOMPoint(x + 10, y, 0, 1));
      return [board.offsetLeft + p.x / p.w, board.offsetTop + p.y / p.w, Math.abs(q.x / q.w - p.x / p.w) / 10];
    }
    function place(a) {
      var r = a.rig, px = a.col * (c + 1), py = a.row * (c + 1), w = r.w * c, h = r.h * c;
      var P = proj(px + c / 2, py + c * .86);
      a.el.style.cssText = 'left:' + (P[0] - c / 2) + 'px;top:' + (P[1] - c) + 'px;width:' + c + 'px;height:' + c + 'px;transform:scale(' + P[2] + ');z-index:' + (a.row + 1);
      a.body.style.cssText = 'left:' + ((c - w) / 2) + 'px;width:' + w + 'px;height:' + h + 'px';
      if (a.ghost) { a.ghost.style.cssText = a.el.style.cssText; a.ghost.firstChild.style.cssText = a.body.style.cssText; }
      a.sh.style.cssText = 'left:' + (px + c / 2 - w * .35) + 'px;top:' + (py + c * .62) + 'px;width:' + (w * .7) + 'px;height:' + (c * .36) + 'px';
      if (r.kind === 'strip') { a.spr.style.backgroundSize = (r.frames * 100) + '% 100%'; a.spr.style.backgroundPosition = '0 0'; }
    }
    function run(a, name, target) {   // play MOVES[name] on actor a; reach = cells to the target
      var m = MOVES[name], reach = 0;
      if (target) reach = Math.max(0, Math.abs(target.col - a.col) - 1.0 * (a.rig.w + target.rig.w) / 2);
      var k = kfs(m, a, reach, c), dur = m.dur / sp();
      var o = { duration: dur, fill: m.keep ? 'forwards' : 'none' };
      var anim = a.body.animate(k.map(function (f) { return { offset: f.offset, transform: f.transform, filter: f.filter, opacity: f.opacity, easing: f.easing }; }), o);
      a.sh.animate(k.map(function (f) { return { offset: f.offset, transform: 'translate(' + f._x + 'px,0) scale(' + (1 - Math.min(.5, Math.max(0, -f._y / c) * .4)) + ')', opacity: f.opacity, easing: f.easing }; }), o);
      if (m.pose && a.rig.kind === 'parts') {
        var P = typeof m.pose === 'string' ? POSES[m.pose] : Object.assign({}, POSES[m.pose.use], { len: POSES[m.pose.use].dur }, m.pose);
        var pa = poseRun(a, P); if (m.keep || P.keep) a.held = (a.held || []).concat(pa);
        pa.forEach(function (x) { live.add(x); x.finished.then(function () { live.delete(x); }, function () { live.delete(x); }); });
      }
      if (m.clip && a.rig.kind === 'strip') {   // the walk strip plays while the gnome rushes in
        var wpx = a.rig.w * c;
        a.spr.animate([{ backgroundPosition: '0 0' }, { backgroundPosition: (-a.rig.frames * wpx) + 'px 0' }], { duration: m.clip[1] / sp(), delay: m.clip[0] / sp(), easing: 'steps(' + a.rig.frames + ')' });
      }
      if (m.dust) for (var dt = m.dust[0]; dt < m.dust[1]; dt += 95) setTimeout(function () { puff(a); }, dt / sp());
      if (m.keep) anim.finished.then(function () { try { anim.commitStyles(); anim.cancel(); } catch (e) {} });   // a held end pose becomes plain style (a forwards-filled animation vanishes behind the tiles in a 3D board)
      live.add(anim); anim.finished.then(function () { live.delete(anim); }, function () { live.delete(anim); });
      return anim;
    }
    function poseRun(a, P, delay) {   // limb animation for a part rig; returns the animations
      var out = [], k = a.rig.w * c / 64;
      a.rig.parts.forEach(function (pt) {
        var tr = P.tracks[pt.id]; if (!tr) return;
        var f = tr.map(function (q, i) {
          var s = q[1];
          return { offset: q[0] / (P.len || P.dur), transform: 'translate(' + (((s.x || 0) + (pt.ox || 0)) * k) + 'px,' + ((s.y || 0) * k) + 'px) rotate(' + (s.r || 0) + 'deg)', easing: tr[i + 1] && tr[i + 1][2] ? tr[i + 1][2] : 'linear' };
        });
        out.push(a.pel[pt.id].animate(f, { duration: P.dur / sp(), delay: ((delay || 0) + (pt.lag || 0)) / sp(), iterations: P.loops || 1, fill: P.keep ? 'forwards' : 'none' }));
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
      var rig = rigFor(d.rig || id), a = { id: id, rig: rig, col: d.col, row: d.row == null ? rows >> 1 : d.row, dir: d.dir || 1, hp: d.hp || 10, max: d.max || d.hp || 10, flip: d.flip };
      var el = document.createElement('div'); el.className = 'fe-act';
      var body = document.createElement('div'); body.className = 'fe-body';
      var spr = document.createElement('i'); spr.className = 'fe-spr'; spr.style.transform = 'scaleX(' + (d.flip ? -1 : 1) + ')';
      var pel = {}, phys = {};
      if (rig.kind === 'parts') rig.parts.forEach(function (pt) {   // one stacked, pivoted layer per limb
        var q = document.createElement('i'); q.className = 'fe-part'; q.style.backgroundImage = 'url("' + d.parts[pt.img] + '")';
        var org = (pt.px[0] / 64 * 100) + '% ' + (pt.px[1] / 80 * 100) + '%'; q.style.transformOrigin = org; if (pt.dim) q.style.filter = 'brightness(' + pt.dim + ')';
        var host = pt.parent ? pel[pt.parent] : spr;
        if (pt.phys) { var w = document.createElement('i'); w.className = 'fe-part'; w.style.transformOrigin = org; w.appendChild(q); host.appendChild(w); phys[pt.id] = w; }   // w: the physics layer (set by the loop), q: scripted poses
        else host.appendChild(q);
        pel[pt.id] = q;
      }); else spr.style.backgroundImage = 'url("' + d.img + '")';
      body.appendChild(spr); el.appendChild(body);
      var sh = document.createElement('div'); sh.className = 'fe-sh';
      board.appendChild(sh); actorsEl.appendChild(el);
      a.el = el; a.body = body; a.spr = spr; a.sh = sh; a.pel = pel; a.phys = phys; if (rig.hat) a.hat = { mode: 'worn', x: 0, y: 0, vx: 0, vy: 0, r: 0, vr: 0, tr: 0, tvr: 0, hold: 0, px: null, pvx: 0, pvy: 0, warm: 0 };
      if (d.side) {
        var hb = document.createElement('div'); hb.className = 'fe-hb ' + d.side;
        hb.innerHTML = '<b></b> <span></span><div class="fe-hp"><i></i></div>';
        hb.children[0].textContent = d.name || id; hud.appendChild(hb); a.num = hb.children[1]; a.bar = hb.children[2].children[0];
      }
      acts[id] = a; place(a); setHp(a, a.hp);
      if (rig.kind === 'parts') a.idleParts = poseRun(a, POSES.idle, -Math.random() * 1600);
      a.idle = body.animate(kfs(MOVES.idle, a, 0, c).map(function (f) { return { offset: f.offset, transform: f.transform, easing: f.easing }; }), { duration: 1600, iterations: Infinity, delay: -Math.random() * 1600 });
      return a;
    }
    /* Hat physics (rAF): the hat and its curl are springs driven by how the head moves, so every lunge, hit and hop gives follow-through for free.
     * worn = springs; free = flies off (hit hard), bounces, lies on the ground; fixing = the gnome puts it back, crooked, then straightens it. Units: gnome-frame px. */
    function headPos(a) { var r = a.pel.torso.getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height * .2]; }
    function stepHat(a, dt) {
      var h = a.hat, k = a.rig.w * c / 64, f = a.flip ? -1 : 1, p = headPos(a), ax = 0, ay = 0, n = 2, i, prevVr = h.vr;
      if (h.px && dt > 0) {
        var vx = (p[0] - h.px[0]) / dt / k * f, vy = (p[1] - h.px[1]) / dt / k;
        if (h.warm > 1) { ax = Math.max(-9000, Math.min(9000, (vx - h.pvx) / dt)); ay = Math.max(-9000, Math.min(9000, (vy - h.pvy) / dt)); }
        h.pvx = vx; h.pvy = vy; h.warm++;
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
      a.phys.hat.style.transform = 'translate(' + (h.x * k) + 'px,' + (h.y * k) + 'px) rotate(' + h.r + 'deg)';
      a.phys.tip.style.transform = 'rotate(' + h.tr + 'deg)';
    }
    var last = 0;
    function tick(now) {
      if (dead) return;
      var dt = Math.min(.033, (now - (last || now)) / 1000) * sp(); last = now;
      Object.keys(acts).forEach(function (k) { if (acts[k].hat) stepHat(acts[k], dt); });
      root.requestAnimationFrame(tick);
    }
    function hatTo(a, world) {   // move the hat layer between the gnome (worn) and a fixed ghost frame (fallen), keeping it where it is on screen
      var w = a.phys.hat, h = a.hat, k = a.rig.w * c / 64, f = a.flip ? -1 : 1, b = w.getBoundingClientRect(), b0 = [b.left + b.width / 2, b.top + b.height / 2];
      if (world) {
        if (!a.ghost) {
          var g = a.el.cloneNode(false), gb = a.body.cloneNode(false), gs = a.spr.cloneNode(false);
          gb.appendChild(gs); g.appendChild(gb); actorsEl.appendChild(g); a.ghost = g; a.gspr = gs;
        }
        a.gspr.appendChild(w);
      } else {
        a.spr.appendChild(w); if (a.ghost) { a.ghost.remove(); a.ghost = a.gspr = null; }
      }
      w.style.transform = 'translate(' + (h.x * k) + 'px,' + (h.y * k) + 'px) rotate(' + h.r + 'deg)';
      b = w.getBoundingClientRect(); h.x -= (b.left + b.width / 2 - b0[0]) * f / k; h.y -= (b.top + b.height / 2 - b0[1]) / k;
    }
    function popHat(a, away) {   // the hat comes off: up, back, spinning
      var h = a.hat; if (!h || h.mode !== 'worn') return;
      hatTo(a, true); h.mode = 'free'; h.rest = 0; h.hold = 0; h.vy = -300; h.vx = -50 * (away || 1); h.vr = -520; h.tvr += 400;
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
      if (ev.move === 'guard') { var g = document.createElement('div'); g.className = 'fe-guard'; a.body.appendChild(g); a.guardEl = g; return run(a, 'guard').finished; }
      if (ev.move === 'flee') { if (a.guardEl) { a.guardEl.remove(); a.guardEl = null; } (a.held || []).forEach(function (x) { x.cancel(); }); a.held = []; stopIdle(a); a.sh.style.opacity = 0; return run(a, 'flee').finished; }
      var name = ev.move || a.rig.attack, m = MOVES[name], atk = run(a, name, tg);
      if (m.swoosh) sleep(m.swoosh).then(function () { swoosh(a); });
      if (!tg) return atk.finished;
      return sleep(m.hit).then(function () {
        if (ev.miss) { pop(tg, 'miss', 'miss'); run(tg, 'dodge'); return; }
        if (tg.guardEl) { tg.guardEl.remove(); tg.guardEl = null; (tg.held || []).forEach(function (x) { x.cancel(); }); tg.held = []; pop(tg, 'block', 'miss'); }
        if (m.fx) burst(tg);
        pop(tg, '-' + ev.dmg); setHp(tg, tg.hp - ev.dmg);
        var h = run(tg, 'hit'); shake(ev.crit ? 6 : 3, ev.crit);
        if (tg.hat && (ev.pop || ev.crit || tg.hp <= 0)) popHat(tg, tg.dir);
        return hitstop(ev.crit ? 110 : 70).then(function () { return h.finished; }).then(function () { if (tg.hp <= 0) { stopIdle(tg); if (tg.rig.lingers) { var kl = run(tg, 'koL'); sleep(750).then(function () { stars(tg); }); return kl.finished; } tg.sh.style.opacity = 0; return run(tg, 'ko').finished; } });
      }).then(function () { return atk.finished; }).then(function () { if (a.hat && tg.hp <= 0 && !ev.miss) return sleep(200).then(function () { return run(a, 'cheer').finished; }); });
    }
    function together(list) { return Promise.all(list.map(step)); }
    function play(list) {   // then anyone whose hat is on the ground and who is still standing puts it back on
      return list.reduce(function (p, ev) { return p.then(function () { return step(ev); }).then(function () { return sleep(150); }); }, Promise.resolve()).then(function () {
        return Promise.all(Object.keys(acts).map(function (k) { var a = acts[k]; return a.hat && a.hp > 0 ? sleep(250).then(function () { return fixHat(a); }) : null; }));
      });
    }
    function destroy() { dead = true; root.removeEventListener('resize', layout); host.innerHTML = ''; acts = {}; }   // stop the physics loop and the resize hook (call before re-creating on the same host)
    layout(); root.addEventListener('resize', layout); root.requestAnimationFrame(tick);
    return { destroy: destroy, add: add, play: play, popHat: popHat, fixHat: fixHat, together: together, acts: acts, layout: layout, setSpeed: function (s) { speed = s; }, MOVES: MOVES };
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
    Object.keys(MOVES).forEach(function (n) {
      var m = MOVES[n], w = 'MOVES.' + n; times(m.keys, m.dur, w);
      if (m.hit > m.dur) bad.push(w + ': hit past dur');
      if (m.pose && typeof m.pose === 'string' && !POSES[m.pose]) bad.push(w + ': unknown pose ' + m.pose);
      if (m.pose && m.pose.use && !POSES[m.pose.use]) bad.push(w + ': unknown pose.use ' + m.pose.use);
      if (m.keys[m.keys.length - 1][0] !== m.dur) bad.push(w + ': last key is not at dur (the move would snap)');
    });
    Object.keys(POSES).forEach(function (n) {
      var p = POSES[n]; Object.keys(p.tracks).forEach(function (part) {
        if (partIds.indexOf(part) < 0) bad.push('POSES.' + n + ': unknown part ' + part);
        times(p.tracks[part], p.dur, 'POSES.' + n + '.' + part);
      });
    });
    Object.keys(ATTACK).forEach(function (s) { if (!MOVES[ATTACK[s]]) bad.push('ATTACK.' + s + ': no move ' + ATTACK[s]); });
    return bad;
  }
  root.FightEngine = { validate: validate, create: create, MOVES: MOVES, POSES: POSES, RIGS: RIGS, ATTACK: ATTACK };
})(window);
