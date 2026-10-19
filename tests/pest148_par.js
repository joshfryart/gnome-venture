// v1.4.8: the page's rules machine (assets/pest.js, SIM block) against the server's pest_sim() on the same rounds and taps.
const fs = require('fs');
const src = fs.readFileSync(process.argv[2], 'utf8');
const d = JSON.parse(fs.readFileSync(process.argv[3], 'utf8'));
const R = JSON.parse(fs.readFileSync(process.argv[4], 'utf8'));
const m = src.match(/\/\*SIM-BEGIN\*\/([\s\S]*?)\/\*SIM-END\*\//);
const makeMachine = new Function(m[1] + ';return makeMachine;')();
let bad = 0;
for (const c of d) {
  const M = makeMachine(c.round, R);
  for (const [t, g] of c.taps) M.tap(t, g);
  const r = M.finish();
  for (const k of Object.keys(c.sim)) {
    const a = r[k], b = c.sim[k];
    if (a !== b && !(typeof b === 'boolean' && a === b)) { bad++; if (bad < 5) console.log('MISMATCH', k, a, b); break; }
  }
}
const tot = d.reduce((a, c) => a + c.sim.score, 0) / d.length;
console.log('rounds', d.length, 'mismatches', bad, 'avg score', tot.toFixed(1), 'max', Math.max(...d.map(c => c.sim.score)));
