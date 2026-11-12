/* Sim 4 runner on the demo's v1 engine (JS port of the board rules + v1 bundle) with the demo's decks and layered creatures.
   node tools/pfdemo_v1/sim4.js ENGINE.js BOT OFFSETS N [SHARD/NSHARDS]     env: PF_EDGES=hash|auth, PF_FLIP=0|1, FOE='{"small":1,...}' (factor on the per-size creature values), DECK=starter|built
   BOT: chain (longest chain) | look (best state after the full round, one turn) | smart (top 6 by look, then the best own chain next turn). Prints one JSON line of sums per size and offset. */
process.env.PFE_PATH = require('path').resolve(process.argv[2]);
var PFE = require(process.env.PFE_PATH), PFD = require('./data.js');
var BOT = process.argv[3] || 'chain', OFFS = (process.argv[4] || '0').split(',').map(Number), N = +(process.argv[5] || 50), SH = (process.argv[6] || '0/1').split('/').map(Number);
var FOE = JSON.parse(process.env.FOE || '{}'), DECK = process.env.DECK || 'starter';
function save() {
  var sv = PFD.freshSave(); sv.started = true;
  if (DECK === 'built') { sv.kit = PFD.CORE.concat(['thorn', 'jab', 'pierce', 'oat', 'herb', 'pepper', 'berry', 'juicy']); sv.beltTier = 2; sv.belt = ['spade', 'hatchet', 'rod', 'staff']; sv.dur.staff = 24; sv.party = ['badger', 'acorn']; }
  else sv.kit = PFD.CORE.concat(PFD.KITS.bold);
  return sv;
}
function value(s) {   // run.php: progress share + 1.2 x health share, a little for guard, big for the result
  var p = s.fh.now / s.fh.max; if (s.cm > 0) p = Math.max(p, s.bar.now / s.bar.max);
  var v = Math.min(1, p) + 1.2 * s.me.hp / s.me.max + 0.3 * Math.min(s.me.block + s.me.keep, 0.3 * s.me.max) / s.me.max - 0.15 * s.foe.block / s.fh.max;
  if (s.over) v += s.over === 'defeat' ? -3 : (s.over === 'stall' ? -1 : 3);
  return v;
}
/** Every placement open to the player: [handIdx, x, y, flip]. With flip on, each piece may also go down flipped (one flip a turn, and one piece is placed a turn). */
function moves(s) {
  var o = [];
  s.me.hand.forEach(function (t, i) {
    PFE.cells(s, t, 'me').forEach(function (c) { o.push([i, c[0], c[1], 0]); });
    if (s.canflip && t.ed) { t.flip = !t.flip; PFE.cells(s, t, 'me').forEach(function (c) { o.push([i, c[0], c[1], 1]); }); t.flip = !t.flip; }
  });
  return o;
}
function withFlip(s, m, fn) { var t = s.me.hand[m[0]]; if (m[3]) t.flip = !t.flip; var r = fn(); if (m[3] && s.me.hand[m[0]] === t) t.flip = !t.flip; return r; }
function dry(s, m) { return withFlip(s, m, function () { return PFE.preview(s, m[0], m[1], m[2]); }); }
function full(s, m) { var w = PFE.clone(s); if (m[3]) w.me.hand[m[0]].flip = !w.me.hand[m[0]].flip; var r = PFE.play(w, [[m[0], m[1], m[2]]], w.turn); return r.err ? null : w; }
function pick(s, mv) {
  if (BOT === 'chain') { var b = null, bn = -1; mv.forEach(function (m) { var p = dry(s, m); if (p && (p.n > bn || (p.n === bn && p.fh + p.bar > b[1]))) { bn = p.n; b = [m, p.fh + p.bar]; } }); return b[0]; }
  var ranked = []; mv.forEach(function (m) { var w = full(s, m); if (w) ranked.push([value(w), m, w]); });
  ranked.sort(function (a, b) { return b[0] - a[0]; });
  if (BOT === 'look') return ranked[0][1];
  var best = null, bs = -1e9;
  ranked.slice(0, 6).forEach(function (r) {
    var w = r[2], v2 = r[0];
    if (!w.over) { v2 = r[0] - 0.02; var keep = s.me.hand.length - 1; 
      var mv2 = []; w.me.hand.forEach(function (t, i) { if (i >= keep) return; PFE.cells(w, t, 'me').forEach(function (c) { mv2.push([i, c[0], c[1], 0]); }); if (w.canflip && t.ed) { t.flip = !t.flip; PFE.cells(w, t, 'me').forEach(function (c) { mv2.push([i, c[0], c[1], 1]); }); t.flip = !t.flip; } });
      mv2.forEach(function (m) { var ww = PFE.clone(w); ww.spent = []; PFE.begin(ww, 'me'); if (m[3]) ww.me.hand[m[0]].flip = !ww.me.hand[m[0]].flip; if (PFE.place(ww, 'me', m[0], m[1], m[2]) !== null) v2 = Math.max(v2, value(ww)); }); }
    var sc = 0.35 * r[0] + 0.65 * v2; if (sc > bs) { bs = sc; best = r[1]; }
  });
  return best;
}
/** Link statistics of one turn (before the move): every hand piece on every free cell next to a piece. */
function linkStats(s, A) {
  var anyLink = false, cells = {};
  for (var id in s.pcs) { var p = s.pcs[id]; for (var sd in PFE.SIDE) { var x = p.x + PFE.SIDE[sd][0], y = p.y + PFE.SIDE[sd][1]; if (x >= 0 && y >= 0 && x < s.w && y < s.h && !s.cell[x + ',' + y]) cells[x + ',' + y] = [x, y]; } }
  s.me.hand.forEach(function (t) {
    var orient = s.canflip && t.ed ? [0, 1] : [0], tl = false, either = {};
    orient.forEach(function (f) {
      if (f) t.flip = !t.flip;
      for (var k in cells) {
        var j = PFE.check(s, t, cells[k][0], cells[k][1]), link = !!j && j.some(function (q) { return q[2]; });
        if (!f) { ['all', 't:' + t.t, 's:' + (t.src || '-')].forEach(function (g) { var a = A[g] = A[g] || { cand: 0, legal: 0, link: 0 }; a.cand++; if (j) a.legal++; if (link) a.link++; }); }
        if (link) tl = true;
        either[k] = Math.max(either[k] || 0, link ? 2 : j ? 1 : 0);
      }
      if (f) t.flip = !t.flip;
    });
    if (tl) anyLink = true;
    for (var k2 in either) { var a2 = A['flip-incl'] = A['flip-incl'] || { cand: 0, legal: 0, link: 0 }; a2.cand++; if (either[k2] >= 1) a2.legal++; if (either[k2] === 2) a2.link++; }
  });
  A.turns = (A.turns || 0) + 1; if (anyLink) A.linkturns = (A.linkturns || 0) + 1;
}
var out = {}, n = 0;
OFFS.forEach(function (off) {
  PFD.CREATURES.forEach(function (c, ci) {
    var per = { small: 2, medium: 3, large: 3, boss: 1 }[c.size], cnt = Math.ceil(N / per);
    for (var k = 0; k < cnt; k++) {
      if ((n++) % SH[1] !== SH[0]) continue;
      var seed = 5000 + ci * 977 + k * 7919 + off * 13, tune = { lvl: off }; if (FOE[c.size]) tune.foe_x = FOE[c.size];
      var f = PFD.newFight(save(), c, seed, tune), s = f.s, key = c.size + '|' + off, o = out[key] = out[key] || { n: 0, win: 0, lost: 0, turns: 0, L: {} };
      PFE.start(s, seed % s.me.hand.length, 'LRTB'[seed % 4]);
      var guard = 0;
      while (!s.over && guard++ < 60) {
        if (off === 0) linkStats(s, o.L);
        var mv = moves(s);
        if (!mv.length) { PFE.pass(s, s.turn); continue; }
        var m = pick(s, mv); if (m[3]) s.me.hand[m[0]].flip = !s.me.hand[m[0]].flip;
        var r = PFE.play(s, [[m[0], m[1], m[2]]], s.turn); if (r.err) throw new Error(r.err);
      }
      o.n++; if (s.over === 'seen_off' || s.over === 'charmed') o.win++; o.lost += 1 - Math.max(0, s.me.hp) / s.me.max; o.turns += s.turn;
    }
  });
});
console.log(JSON.stringify({ bot: BOT, edges: PFD.EDGE_MODE, out: out }));
