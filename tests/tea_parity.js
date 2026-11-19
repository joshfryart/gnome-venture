// The Hovel tea kettle: assets/tea.js (gvTeaCup, the live preview) against includes/tea.php (tea_cup, the function that brews).
// Usage: node tests/tea_parity.js GAME PARITY.json   (PARITY.json is written by tests/tea.php)
// 2.7.21: also the order rule (a side-stat tie goes to Charm, Lore, Sense, Nimble, Grit, Hardiness, Luck in that order, so shuffled
// extras give the same cup) and gvTeaPick against tea_pick().
const path = require('path'), fs = require('fs');
const { gvTeaCup, gvTeaPick, SIDE_ORDER } = require(path.resolve(process.argv[2], 'assets/tea.js'));
const P = JSON.parse(fs.readFileSync(process.argv[3], 'utf8'));
let bad = 0, legal = 0, fails = 0;
const norm = o => JSON.stringify(Object.keys(o).sort().map(k => [k, o[k]]));
for (const c of P.cups) {
  const got = gvTeaCup(P.data[c.tier + ':' + c.caps.join(',')], c.slugs);
  if (!got.err) legal++;
  const a = norm(got), b = norm(c.want);
  if (a !== b) { if (bad++ < 8) console.log('  FAIL cup ' + JSON.stringify(c.slugs) + ' kettle ' + c.tier + ' caps ' + c.caps + '\n       js  ' + a + '\n       php ' + b); }
}
console.log((bad ? '  FAIL ' : '  ok   ') + 'JS twin = PHP on ' + P.cups.length + ' cups (' + legal + ' legal)' + (bad ? ': ' + bad + ' differ' : ''));
fails += bad ? 1 : 0;
// order independence in the twin: every legal cup, its extras shuffled 8 times (seeded), gives the same cup
let seed = 20261119; const rnd = () => (seed = (seed * 1103515245 + 12345) % 2147483648) / 2147483648;
let shuffled = 0, odd = 0;
for (const c of P.cups) {
  const D = P.data[c.tier + ':' + c.caps.join(',')], s = c.slugs.filter(x => x);
  if (c.want.err || s.length < 3) continue;
  const want = norm(gvTeaCup(D, s));
  for (let k = 0; k < 8; k++) {
    const r = s.slice(1); for (let i = r.length - 1; i > 0; i--) { const j = Math.floor(rnd() * (i + 1)); [r[i], r[j]] = [r[j], r[i]]; }
    shuffled++;
    if (norm(gvTeaCup(D, [s[0]].concat(r))) !== want) { if (odd++ < 4) console.log('  FAIL order matters: ' + JSON.stringify(s) + ' vs ' + JSON.stringify([s[0]].concat(r))); }
  }
}
console.log((odd || shuffled < 500 ? '  FAIL ' : '  ok   ') + 'JS twin: ' + shuffled + ' shuffles of the extras give the same cup' + (odd ? ': ' + odd + ' differ' : ''));
fails += odd || shuffled < 500 ? 1 : 0;
const tieOk = JSON.stringify(SIDE_ORDER) === JSON.stringify(['charm', 'lore', 'sense', 'nimble', 'grit', 'hardiness', 'luck']);
console.log((tieOk ? '  ok   ' : '  FAIL ') + 'JS twin: the side tie order is Charm, Lore, Sense, Nimble, Grit, Hardiness, Luck');
fails += tieOk ? 0 : 1;
// gvTeaPick = tea_pick (full data: tier 0, caps 3,2)
const Dall = P.data['0:3,2']; let pb = 0;
for (const k of P.picks || []) {
  const got = gvTeaPick(Dall, k.c, k.base);
  if (JSON.stringify(got) !== JSON.stringify(k.want)) { if (pb++ < 4) console.log('  FAIL pick ' + JSON.stringify(k) + ' js ' + JSON.stringify(got)); }
}
console.log((pb || !(P.picks || []).length ? '  FAIL ' : '  ok   ') + 'gvTeaPick = tea_pick on ' + (P.picks || []).length + ' sets' + (pb ? ': ' + pb + ' differ' : ''));
fails += pb || !(P.picks || []).length ? 1 : 0;
process.exit(fails ? 1 : 0);
