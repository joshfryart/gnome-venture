// node tests/pfengine_js.js TRACE.ndjson : replays the PHP board-engine traces from tests/pfengine_js.php with tools/pfengine.js
// and requires identical JSON: events, views, hidden-state digests, query answers, text lines, history chips and the final state.
const fs = require('fs');
const PFE = require('../tools/pfengine.js');
const lines = fs.readFileSync(process.argv[2], 'utf8').split('\n').filter(Boolean);

// JSON-roundtrip, an empty object means the same as PHP's empty array, -0 is 0. Key order is kept (PHP array order = insertion order).
function canon(v) {
  if (v === null || typeof v !== 'object') return v === 0 ? 0 : v;
  if (Array.isArray(v)) return v.map(canon);
  const k = Object.keys(v); if (!k.length) return [];
  const o = {}; for (const x of k) o[x] = canon(v[x]); return o;
}
const norm = x => canon(JSON.parse(JSON.stringify(x === undefined ? null : x)));
/** First differing path between two canonical values, or null. */
function first(a, b, p) {
  if (a === b) return null;
  if (a === null || b === null || typeof a !== 'object' || typeof b !== 'object') return { p, php: a, js: b };
  if (Array.isArray(a) !== Array.isArray(b)) return { p, php: a, js: b };
  if (Array.isArray(a)) {
    for (let i = 0; i < Math.max(a.length, b.length); i++) { if (i >= a.length || i >= b.length) return { p: p + '[' + i + ']', php: a[i], js: b[i] }; const d = first(a[i], b[i], p + '[' + i + ']'); if (d) return d; }
    return null;
  }
  const ka = Object.keys(a), kb = Object.keys(b);
  for (const k of ka) { if (!(k in b)) return { p: p + '.' + k, php: a[k], js: '(missing)' }; const d = first(a[k], b[k], p + '.' + k); if (d) return d; }
  for (const k of kb) if (!(k in a)) return { p: p + '.' + k, php: '(missing)', js: b[k] };
  if (ka.join() !== kb.join()) return { p: p + ' (key order)', php: ka.join(), js: kb.join() };
  return null;
}
let bad = 0;
function fail(ctx, php, js, label) {
  const d = first(norm(php), norm(js), label);
  if (!d) return false;
  bad++;
  if (bad <= 12) console.log('FAIL ' + ctx + ' at ' + d.p + '\n   php: ' + String(JSON.stringify(d.php)).slice(0, 300) + '\n   js:  ' + String(JSON.stringify(d.js)).slice(0, 300));
  return true;
}

// ---- header
const hdr = JSON.parse(lines[0]);
fail('header tiles', hdr.tiles, PFE.tiles(), 'tiles');
fail('header combos', hdr.combos, PFE.COMBOS, 'combos');
fail('header tags', hdr.tags, PFE.TAGS, 'tags');
fail('header mods', hdr.mods, PFE.MODS, 'mods');
hdr.rounds.forEach(([x, r1, r0]) => { if (PFE.round(x, 1) !== r1 || PFE.round(x, 0) !== r0) { bad++; if (bad <= 12) console.log('FAIL round(' + x + '): php ' + r1 + ' / ' + r0 + ', js ' + PFE.round(x, 1) + ' / ' + PFE.round(x, 0)); } });
hdr.crc.forEach(([s, c]) => { if (PFE.crc32(s) !== c) { bad++; if (bad <= 12) console.log('FAIL crc32(' + s + '): php ' + c + ' js ' + PFE.crc32(s)); } });
const deckOf = a => PFE.playerDeck(a[0], { calling: a[1], tier: a[2], pals: a[3], unlocked: a[4], typeBonus: a[5], snack: a[6], box: a[7] });
hdr.decks.forEach((d, i) => fail('header deck #' + i, d.deck, deckOf(d.args), 'deck'));

// ---- fights
const digest = s => { const k = a => a.map(t => t.k + ':' + t.v); return { rng: s.rng, md: k(s.me.draw), mx: k(s.me.discard), fh: k(s.foe.hand), fd: k(s.foe.draw), fx: k(s.foe.discard), held: s.me.held === undefined ? null : s.me.held }; };
const slim = v => { delete v.combos; return v; };
const queries = s => {
  const q = { search: PFE.search(s, 'me'), search_nh: PFE.search(s, 'me', false), foe_search: PFE.search(s, 'foe'), cells: [], edges: [] };
  s.me.hand.forEach(t => { q.cells.push(PFE.cells(s, t)); q.edges.push(PFE.edges(t)); });
  const g = s.me.held;
  if (g) { q.spots = PFE.groupSpots(s, g); q.opts = s.me.hand.map(t => PFE.groupOptions(g, t)); }
  return q;
};
let nf = 0, na = 0, done = null;
for (const ln of lines.slice(1)) {
  const rec = JSON.parse(ln);
  if (rec.done) { done = rec; continue; }
  const ctx = rec.fight + ' ' + rec.mode + ' seed=' + rec.seed;
  const before = bad; nf++;
  if (fail(ctx + ' deck build', rec.deck0, deckOf(rec.args), 'deck0')) continue;
  const s = PFE.newFight(rec.me, rec.creature, rec.seed, rec.opt);
  const ns = x => { const o = JSON.parse(JSON.stringify(x)); delete o.nonce; return o; };
  if (fail(ctx + ' newFight state', rec.init.state, ns(s), 'init.state') || fail(ctx + ' newFight view', rec.init.view, slim(PFE.view(s)), 'init.view')) continue;
  let stop = false;
  rec.steps.forEach((st, i) => {
    if (stop) return;
    const c = ctx + ' step ' + i + ' (turn ' + st.turn + ', ' + st.op + (st.dry ? ' dry' : '') + ' ' + JSON.stringify(st.moves || '') + ')'; na++;
    if (st.q && fail(c + ' queries', st.q, queries(s), 'q')) { stop = true; return; }
    const res = st.op === 'pass' ? PFE.pass(s, st.turn) : PFE.play(s, st.moves, st.turn, st.dry);
    if (fail(c + ' result', st.res, res, 'res')) { stop = true; return; }
    if (st.lines) {
      const fo = s.foe.name;
      if (fail(c + ' lines', st.lines, res.ev.map(e => PFE.line(e, fo)), 'lines') || fail(c + ' chips', st.chips, res.ev.map((e, k) => PFE.chipEvent(e, k)), 'chips') || fail(c + ' chips board', st.chipsb, PFE.chipsBoard(res.ev), 'chipsb')) { stop = true; return; }
    }
    if (fail(c + ' view', st.view, slim(PFE.view(s)), 'view') || fail(c + ' hidden state', st.dg, digest(s), 'dg') || fail(c + ' over/fx', [st.over, st.fx], [s.over, s.fx === undefined ? null : s.fx], 'over_fx')) stop = true;
  });
  if (!stop) fail(ctx + ' final state', rec.final, ns(s), 'final');
}
if (!done || done.fights !== nf) { bad++; console.log('FAIL trace incomplete (php wrote ' + (done ? done.fights : '?') + ' fights, read ' + nf + ')'); }
console.log(bad ? 'FAIL ' + bad + ' mismatches' : 'ok: ' + nf + ' fights, ' + na + ' actions (play, dry, pass, rejected moves) match the PHP engine; ' + hdr.rounds.length + ' round() and ' + hdr.crc.length + ' crc32 samples, ' + hdr.decks.length + ' deck builds');
process.exit(bad ? 1 : 0);
