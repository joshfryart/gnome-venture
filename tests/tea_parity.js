// The Hovel tea kettle: assets/tea.js (gvTeaCup, the live preview) against includes/tea.php (tea_cup, the function that brews).
// Usage: node tests/tea_parity.js GAME PARITY.json   (PARITY.json is written by tests/tea.php)
const path = require('path'), fs = require('fs');
const { gvTeaCup } = require(path.resolve(process.argv[2], 'assets/tea.js'));
const P = JSON.parse(fs.readFileSync(process.argv[3], 'utf8'));
let bad = 0, legal = 0;
for (const c of P.cups) {
  const got = gvTeaCup(P.data[c.tier + ':' + c.caps.join(',')], c.slugs);
  if (!got.err) legal++;
  const a = JSON.stringify(Object.keys(got).sort().map(k => [k, got[k]])), b = JSON.stringify(Object.keys(c.want).sort().map(k => [k, c.want[k]]));
  if (a !== b) { if (bad++ < 8) console.log('  FAIL cup ' + JSON.stringify(c.slugs) + ' kettle ' + c.tier + ' caps ' + c.caps + '\n       js  ' + a + '\n       php ' + b); }
}
console.log((bad ? '  FAIL ' : '  ok   ') + 'JS twin = PHP on ' + P.cups.length + ' cups (' + legal + ' legal)' + (bad ? ': ' + bad + ' differ' : ''));
process.exit(bad ? 1 : 0);
