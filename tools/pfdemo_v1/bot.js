/* Crash check for the playable demo: plays N fights per bot through the demo's own deck model (pfd.js), the game's creature decks and tools/pfengine.js (no DOM), with random Tuning values,
   and checks the board invariants after every turn.   node tools/pfdemo_v1/bot.js ENGINE.js DATA.json [N=60]
   (python3 tools/build_pf_demo_v1.py OUT.html DATA.json writes DATA.json; ENGINE.js = tools/pfengine.js) */
process.env.PFE_PATH = require('path').resolve(process.argv[2]); process.env.PFD_DATA = require('path').resolve(process.argv[3]);
var PFE = require(process.env.PFE_PATH), PFD = require('./pfd.js'), N = +(process.argv[4] || 60), C = PFD.D.creatures, KITS = ['bold', 'steady', 'kind'];
function save(kit, belt) { var sv = PFD.blank(); PFD.post(sv, false, 'pfd_starter', { kit: kit }); sv.slots = belt; return sv; }
function moves(s) {
  var o = []; s.me.hand.forEach(function (t, i) {
    PFE.cells(s, t, 'me').forEach(function (c) { o.push([i, c[0], c[1], 0]); });
    if (PFE.canFlip(s, i)) { var f = PFE.clone(t); f.flip = !f.flip; PFE.cells(s, f, 'me').forEach(function (c) { o.push([i, c[0], c[1], 1]); }); }
  });
  return o;
}
function invariants(s, tag) {
  var seen = {};
  for (var id in s.pcs) { var p = s.pcs[id], k = p.x + ',' + p.y; if (p.x < 0 || p.y < 0 || p.x >= s.w || p.y >= s.h) throw new Error(tag + ': piece off the board'); if (seen[k]) throw new Error(tag + ': two pieces on a cell'); seen[k] = 1; if (s.cell[k] !== p.id) throw new Error(tag + ': cell map out of step'); }
  if (Object.keys(s.cell).length !== Object.keys(s.pcs).length) throw new Error(tag + ': cell count');
  if (!isFinite(s.me.hp) || !isFinite(s.fh.now) || !isFinite(s.bar.now)) throw new Error(tag + ': not a number');
  var v = PFE.view(s); if (!v || v.w !== s.w) throw new Error(tag + ': view');
}
function fight(bot, c, seed, kit) {
  var sv = save(kit, 2 + seed % 3), g = PFD.gnome(c.level - (seed % 5 === 0 ? 6 : 0));
  var tune = { foe_x: 0.6 + (seed % 7) * 0.15, bar_x: 0.8 + (seed % 4) * 0.2, limit: 2 + seed % 4, envn: 1 + seed % 3, sun: 1 + (seed % 3), mud: (seed % 5) / 10 };
  var me = { hp: g.max, max_hp: g.max, stats: g.stats, deck: PFD.tiles(PFD.fightEntries(sv), g.stats, {}, sv.calling, 1), luck: 0 };
  var s = PFE.newFight(me, PFE.clone(c), seed, { blank: true, v1: tune }); var tag = c.slug + ' ' + bot + ' ' + seed, guard = 0;
  var err = PFE.start(s, seed % s.me.hand.length, 'LRTB'[seed % 4]); if (err) throw new Error(tag + ': start ' + err);
  while (!s.over) {
    if (++guard > 60) throw new Error(tag + ': fight does not end');
    var mv = moves(s), r;
    if (!mv.length) r = PFE.pass(s, s.turn);
    else {
      var pick = mv[(seed * 31 + guard * 17) % mv.length];
      if (bot !== 'random') { var best = -1e9; mv.forEach(function (m) { var w = PFE.clone(s); if (m[3]) { var t = w.me.hand[m[0]]; t.flip = !t.flip; } var r0 = PFE.play(w, [[m[0], m[1], m[2]]], s.turn, true); if (r0.err) return;
        var sc = bot === 'chain' ? r0.ev.length : (s.fh.now - r0.fh) * -1 + (r0.bar - s.bar.now) * 0.6 + 0.4 * (r0.hp - s.me.hp) + (r0.over === 'seen_off' || r0.over === 'charmed' ? 60 : 0); if (sc > best) { best = sc; pick = m; } }); }
      if (pick[3]) { var f = PFE.flip(s, pick[0], s.turn); if (f) throw new Error(tag + ': flip ' + f); }
      r = PFE.play(s, [[pick[0], pick[1], pick[2]]], s.turn);
    }
    if (r.err) throw new Error(tag + ': move refused: ' + r.err);
    r.ev.forEach(function (e) { PFE.line(e, c.name); PFE.chipEvent(e, 1); });
    invariants(s, tag + ' turn ' + s.turn);
  }
  return s;
}
var out = {}, total = 0;
['random', 'chain', 'greedy'].forEach(function (bot) {
  var by = {};
  for (var i = 0; i < N; i++) {
    var c = C[i % C.length], s = fight(bot, c, 1000 + i * 7919, KITS[i % 3]), b = by[c.size] = by[c.size] || { n: 0, win: 0, turns: 0, lost: 0, wear: 0 };
    b.n++; total++; if (s.over === 'seen_off' || s.over === 'charmed') b.win++; b.turns += s.turn; b.lost += 1 - s.me.hp / s.me.max; b.wear += Object.keys(s.wear || {}).length ? 1 : 0;
  }
  out[bot] = Object.keys(by).map(function (k) { var b = by[k]; return k + ' ' + Math.round(100 * b.win / b.n) + '% / ' + Math.round(100 * b.lost / b.n) + '% lost / ' + (b.turns / b.n).toFixed(1) + ' turns (' + b.n + ')'; }).join('; ');
});
console.log(total + ' fights, no crash.'); Object.keys(out).forEach(function (k) { console.log(k + ': ' + out[k]); });
