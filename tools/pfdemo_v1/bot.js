/* Crash check for the v1 demo rules: plays N fights per bot with the demo's own engine and data (no DOM).
   node tools/pfdemo_v1/bot.js ENGINE.js [N=50]    (ENGINE.js = second argument of tools/build_pf_demo_v1.py) */
process.env.PFE_PATH = require('path').resolve(process.argv[2]);
var PFE = require(process.env.PFE_PATH), PFD = require('./data.js'), N = +(process.argv[3] || 50);
function save() { var sv = PFD.freshSave(); sv.kit = PFD.CORE.concat(PFD.KITS.bold); sv.started = true; return sv; }
function moves(s) { var o = []; s.me.hand.forEach(function (t, i) { PFE.cells(s, t, 'me').forEach(function (c) { o.push([i, c[0], c[1]]); }); }); return o; }
function invariants(s, tag) {
  var seen = {};
  for (var id in s.pcs) { var p = s.pcs[id], k = p.x + ',' + p.y; if (p.x < 0 || p.y < 0 || p.x >= s.w || p.y >= s.h) throw new Error(tag + ': piece off the board'); if (seen[k]) throw new Error(tag + ': two pieces on a cell'); seen[k] = 1; if (s.cell[k] !== p.id) throw new Error(tag + ': cell map out of step'); }
  if (Object.keys(s.cell).length !== Object.keys(s.pcs).length) throw new Error(tag + ': cell count');
  if (!isFinite(s.me.hp) || !isFinite(s.fh.now) || !isFinite(s.bar.now)) throw new Error(tag + ': not a number');
  var n = s.me.hand.length + s.me.draw.length + s.me.discard.length; for (id in s.pcs) if (s.pcs[id].by === 'me') n++;
  if (n !== s.decksize) throw new Error(tag + ': deck pieces lost or doubled (' + n + ' of ' + s.decksize + ')');
  PFE.view(s);
}
function fight(bot, c, seed) {
  var f = PFD.newFight(save(), c, seed, {}), s = f.s; s.decksize = s.me.hand.length + s.me.draw.length;
  var err = PFE.start(s, seed % s.me.hand.length, 'LRTB'[seed % 4]); if (err) throw new Error(err);
  var guard = 0;
  while (!s.over) {
    if (++guard > 60) throw new Error('fight does not end');
    var mv = moves(s), r;
    if (!mv.length) r = PFE.pass(s, s.turn);
    else {
      var pick = mv[(seed * 31 + guard * 17) % mv.length];
      if (bot !== 'random') { var best = -1e9; mv.forEach(function (m) { var p = PFE.preview(s, m[0], m[1], m[2]); if (!p) return; var sc = bot === 'chain' ? p.n : p.fh + p.bar + 0.7 * p.hp + 0.3 * p.block + (p.over ? 50 : 0); if (sc > best) { best = sc; pick = m; } }); }
      r = PFE.play(s, [pick], s.turn);
    }
    if (r.err) throw new Error('move refused: ' + r.err);
    invariants(s, c.slug + ' seed ' + seed + ' turn ' + s.turn);
  }
  return s;
}
var out = {};
['random', 'chain', 'greedy'].forEach(function (bot) {
  var by = {};
  for (var i = 0; i < N; i++) {
    var c = PFD.CREATURES[i % PFD.CREATURES.length], s = fight(bot, c, 1000 + i * 7919);
    var b = by[c.size] = by[c.size] || { n: 0, win: 0, turns: 0, lost: 0, wear: 0 };
    b.n++; if (s.over === 'seen_off' || s.over === 'charmed') b.win++; b.turns += s.turn; b.lost += 1 - s.me.hp / s.me.max; b.wear += Object.keys(s.wear).length ? 1 : 0;
  }
  out[bot] = Object.keys(by).map(function (k) { var b = by[k]; return k + ' ' + Math.round(100 * b.win / b.n) + '% / ' + Math.round(100 * b.lost / b.n) + '% lost / ' + (b.turns / b.n).toFixed(1) + ' turns (' + b.n + ')'; }).join('; ');
});
console.log(N + ' fights per bot, no crash.'); Object.keys(out).forEach(function (k) { console.log(k + ': ' + out[k]); });
