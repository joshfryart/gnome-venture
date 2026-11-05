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
    pluck: { dur: 860, hit: 440, fx: 'pow', pose: 'pluck', keys: [      // gnome, bare-handed: Gnome Pluck (wind up, run in, swing the arm)
      [0, {}], [160, { dx: -.15, sx: 1.06, sy: .92, r: -8 }, E.out], [240, { dx: -.2, sx: 1.08, sy: .9, r: -10 }, E.io],
      [420, { x: .97, y: -.12, sx: .92, sy: 1.1, r: 12 }, E['in']], [470, { x: 1, sx: 1.14, sy: .88, r: 8 }, E.out],
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
    hit: { dur: 380, keys: [[0, {}], [60, { dx: -.18, sx: .9, sy: 1.1, b: 2.2, r: -8 }, E.out], [160, { dx: -.1, sx: 1.06, sy: .94, b: 1.3, r: 3 }], [380, {}, E.io]] },
    dodge: { dur: 520, keys: [[0, {}], [120, { y: -.5, dx: -.3, sy: 1.1, sx: .92 }, E.out], [300, { dx: -.25, sx: 1.08, sy: .9 }, E['in']], [520, {}, E.io]] },
    ko: { dur: 900, keep: 1, keys: [[0, {}], [120, { dx: -.2, b: 2, r: -10 }, E.out], [500, { dx: -.5, y: .15, r: -60 }, E['in']], [900, { dx: -.6, y: .35, r: -90, o: 0 }, E.out]] },
    guard: { dur: 400, pose: 'guard', keys: [[0, {}], [120, { sx: 1.1, sy: .88 }, E.out], [400, { sx: 1.06, sy: .92 }, E.io]] },
    flee: { dur: 700, keep: 1, pose: { use: 'run', dur: 350, loops: 2 }, keys: [[0, {}], [150, { dx: -.1, sx: 1.08, sy: .9 }, E.out], [700, { dx: -6, o: 0 }, E['in']]] },
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
      torso: [[0, {}], [160, { r: -9 }, E.out], [240, { r: -12 }], [330, { r: 6, y: -1 }], [420, { r: 14 }], [470, { r: 20 }, E.out], [660, { r: 8 }], [860, {}, E.io]],
      armF: [[0, {}], [160, { r: 115 }, E.out], [240, { r: 128 }], [330, { r: 120 }], [420, { r: 112 }], [445, { r: -70 }, E['in']], [500, { r: -105 }, E.out], [660, { r: -60 }], [860, {}, E.io]],
      armB: [[0, {}], [160, { r: -30 }], [240, { r: -45 }], [330, { r: 50 }], [420, { r: -40 }], [470, { r: -70 }], [860, {}, E.io]],
      legF: [[0, {}], [240, { r: -10 }], [285, { r: -38 }], [330, { r: 0, y: -3 }], [375, { r: 38 }], [420, { r: -25 }], [470, { r: -15 }], [860, {}, E.io]],
      legB: [[0, {}], [240, { r: 10 }], [285, { r: 38 }], [330, { r: 0, y: -3 }], [375, { r: -38 }], [420, { r: 25 }], [470, { r: 15 }], [860, {}, E.io]] } },
    guard: { dur: 300, keep: 1, tracks: { torso: [[0, {}], [300, { r: -4 }, E.out]], armF: [[0, {}], [300, { r: -95 }, E.out]], armB: [[0, {}], [300, { r: -80 }, E.out]] } }
  };
  /* A rig = how to draw and size an actor. strip: sheet of equal frames (gnome25, 8 of 64x80). still: one picture (mini art, faces right).
   * Later: per-creature 'sheet' rigs with clips, same shape as the gnome. w/h are in board cells. */
  var RIGS = {
    // parts rig: cut by tools/gnome_rig_parts.php. id = limb name, img = file key, px = pivot, ox = x shift, dim = brightness (the far arm).
    gnome: { kind: 'parts', w: 2, h: 2.5, attack: 'pluck', unarmed: 1, parts: [
      { id: 'armB', img: 'arm', px: [33, 48], ox: 4, dim: .72 }, { id: 'legB', img: 'legB', px: [28, 63] }, { id: 'torso', img: 'torso', px: [32, 64] },
      { id: 'legF', img: 'legF', px: [36, 63] }, { id: 'armF', img: 'arm', px: [33, 48] }] },
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
    host.innerHTML = '<div class="fe-view"><div class="fe-board"><div class="fe-grid"></div></div></div><div class="fe-hud"></div><div class="fe-fx"></div>';
    var view = host.children[0], board = view.children[0], grid = board.children[0], hud = host.children[1], fx = host.children[2];
    var t = '';
    for (var y = 0; y < rows; y++) for (var x = 0; x < cols; x++) t += '<div class="fe-t ' + terrain(x, y) + '"></div>';
    grid.innerHTML = t; grid.style.gridTemplateColumns = 'repeat(' + cols + ',1fr)';

    function sp() { return reduce ? 40 : speed; }
    function sleep(ms) { return new Promise(function (r) { setTimeout(r, ms / sp()); }); }
    function layout() {
      var w = host.clientWidth - 16; c = (w - (cols - 1)) / cols;
      board.style.width = w + 'px'; view.style.paddingTop = (.8 * c) + 'px';
      Object.keys(acts).forEach(function (k) { place(acts[k]); });
    }
    function place(a) {
      var r = a.rig, px = a.col * (c + 1), py = a.row * (c + 1), w = r.w * c, h = r.h * c;
      a.el.style.cssText = 'left:' + px + 'px;top:' + py + 'px;width:' + c + 'px;height:' + c + 'px';
      a.body.style.cssText = 'left:' + ((c - w) / 2) + 'px;width:' + w + 'px;height:' + h + 'px';
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
        var P = typeof m.pose === 'string' ? POSES[m.pose] : Object.assign({}, POSES[m.pose.use], m.pose);
        var pa = poseRun(a, P); if (m.keep || P.keep) a.held = (a.held || []).concat(pa);
        pa.forEach(function (x) { live.add(x); x.finished.then(function () { live.delete(x); }, function () { live.delete(x); }); });
      }
      if (m.clip && a.rig.kind === 'strip') {   // the walk strip plays while the gnome rushes in
        var wpx = a.rig.w * c;
        a.spr.animate([{ backgroundPosition: '0 0' }, { backgroundPosition: (-a.rig.frames * wpx) + 'px 0' }], { duration: m.clip[1] / sp(), delay: m.clip[0] / sp(), easing: 'steps(' + a.rig.frames + ')' });
      }
      live.add(anim); anim.finished.then(function () { live.delete(anim); }, function () { live.delete(anim); });
      return anim;
    }
    function poseRun(a, P, delay) {   // limb animation for a part rig; returns the animations
      var out = [], k = a.rig.w * c / 64;
      a.rig.parts.forEach(function (pt) {
        var tr = P.tracks[pt.id]; if (!tr) return;
        var f = tr.map(function (q, i) {
          var s = q[1];
          return { offset: q[0] / P.dur, transform: 'translate(' + (((s.x || 0) + (pt.ox || 0)) * k) + 'px,' + ((s.y || 0) * k) + 'px) rotate(' + (s.r || 0) + 'deg)', easing: tr[i + 1] && tr[i + 1][2] ? tr[i + 1][2] : 'linear' };
        });
        out.push(a.pel[pt.id].animate(f, { duration: P.dur / sp(), delay: (delay || 0) / sp(), iterations: P.loops || 1, fill: P.keep ? 'forwards' : 'none' }));
      });
      return out;
    }
    function hitstop(ms) {
      var l = []; live.forEach(function (x) { l.push(x); x.pause(); });
      return sleep(ms).then(function () { l.forEach(function (x) { x.play(); }); });
    }
    function shake(amp) {
      var s = 'rotateX(42deg) scale(.96)';
      board.animate([{ transform: s }, { transform: 'translate(' + amp + 'px,' + (-amp / 2) + 'px) ' + s }, { transform: 'translate(' + (-amp) + 'px,0) ' + s }, { transform: s }], { duration: 220 / sp() });
    }
    function spot(a) { var r = a.body.getBoundingClientRect(), h = host.getBoundingClientRect(); return [r.left - h.left + r.width / 2, r.top - h.top + r.height * .35]; }
    function pop(a, txt, cls) {
      var p = spot(a), d = document.createElement('div');
      d.className = 'fe-dmg ' + (cls || ''); d.textContent = txt; d.style.left = (p[0] - 12) + 'px'; d.style.top = (p[1] - 20) + 'px'; fx.appendChild(d);
      d.animate([{ transform: 'translateY(0)', opacity: 1 }, { transform: 'translateY(-30px)', opacity: 0 }], { duration: 900 / sp() }).finished.then(function () { d.remove(); });
    }
    function burst(a) {
      var p = spot(a), d = document.createElement('div'); d.className = 'fe-pow'; d.style.left = p[0] + 'px'; d.style.top = p[1] + 'px'; fx.appendChild(d);
      d.animate([{ transform: 'scale(.2) rotate(0)', opacity: 1 }, { transform: 'scale(1.3) rotate(25deg)', opacity: 0 }], { duration: 300 / sp() }).finished.then(function () { d.remove(); });
    }
    function setHp(a, hp) { a.hp = Math.max(0, hp); if (a.bar) { a.bar.style.width = (100 * a.hp / a.max) + '%'; a.num.textContent = a.hp + '/' + a.max; } }

    function add(id, d) {
      var rig = rigFor(d.rig || id), a = { id: id, rig: rig, col: d.col, row: d.row == null ? rows >> 1 : d.row, dir: d.dir || 1, hp: d.hp || 10, max: d.max || d.hp || 10, flip: d.flip };
      var el = document.createElement('div'); el.className = 'fe-act';
      var body = document.createElement('div'); body.className = 'fe-body';
      var spr = document.createElement('i'); spr.className = 'fe-spr'; spr.style.transform = 'scaleX(' + (d.flip ? -1 : 1) + ')';
      var pel = {};
      if (rig.kind === 'parts') rig.parts.forEach(function (pt) {   // one stacked, pivoted layer per limb
        var q = document.createElement('i'); q.className = 'fe-part'; q.style.backgroundImage = 'url("' + d.parts[pt.img] + '")';
        q.style.transformOrigin = (pt.px[0] / 64 * 100) + '% ' + (pt.px[1] / 80 * 100) + '%'; if (pt.dim) q.style.filter = 'brightness(' + pt.dim + ')';
        spr.appendChild(q); pel[pt.id] = q;
      }); else spr.style.backgroundImage = 'url("' + d.img + '")';
      body.appendChild(spr); el.appendChild(body);
      var sh = document.createElement('div'); sh.className = 'fe-sh';
      board.appendChild(sh); board.appendChild(el);
      a.el = el; a.body = body; a.spr = spr; a.sh = sh; a.pel = pel;
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
    function stopIdle(a) { a.idle.cancel(); (a.idleParts || []).forEach(function (x) { x.cancel(); }); }
    function face() {   // everyone looks at the other side
      var l = Object.keys(acts).map(function (k) { return acts[k]; });
      l.forEach(function (a) { var o = l.filter(function (b) { return b !== a; })[0]; if (o) a.dir = o.col > a.col ? 1 : -1; });
    }
    function step(ev) {
      var a = acts[ev.from], tg = ev.to ? acts[ev.to] : null; face();
      if (ev.move === 'guard') { var g = document.createElement('div'); g.className = 'fe-guard'; a.body.appendChild(g); a.guardEl = g; return run(a, 'guard').finished; }
      if (ev.move === 'flee') { stopIdle(a); a.sh.style.opacity = 0; return run(a, 'flee').finished; }
      var name = ev.move || a.rig.attack, m = MOVES[name], atk = run(a, name, tg);
      if (!tg) return atk.finished;
      return sleep(m.hit).then(function () {
        if (ev.miss) { pop(tg, 'miss', 'miss'); run(tg, 'dodge'); return; }
        if (tg.guardEl) { tg.guardEl.remove(); tg.guardEl = null; (tg.held || []).forEach(function (x) { x.cancel(); }); tg.held = []; pop(tg, 'block', 'miss'); }
        if (m.fx) burst(tg);
        pop(tg, '-' + ev.dmg); setHp(tg, tg.hp - ev.dmg);
        var h = run(tg, 'hit'); shake(ev.crit ? 6 : 3);
        return hitstop(ev.crit ? 110 : 70).then(function () { return h.finished; }).then(function () { if (tg.hp <= 0) { stopIdle(tg); tg.sh.style.opacity = 0; return run(tg, 'ko').finished; } });
      }).then(function () { return atk.finished; });
    }
    function play(list) { return list.reduce(function (p, ev) { return p.then(function () { return step(ev); }).then(function () { return sleep(150); }); }, Promise.resolve()); }
    layout(); root.addEventListener('resize', layout);
    return { add: add, play: play, acts: acts, layout: layout, setSpeed: function (s) { speed = s; }, MOVES: MOVES };
  }
  root.FightEngine = { create: create, MOVES: MOVES, POSES: POSES, RIGS: RIGS, ATTACK: ATTACK };
})(window);
