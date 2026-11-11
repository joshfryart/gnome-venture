// node tests/pfboard_js.js CASES.json : the real game/assets/pfboard.js legality against the PHP engine's legal cells, on 400 random boards.
const fs = require('fs'); const D = JSON.parse(fs.readFileSync(process.argv[2]));
const src = fs.readFileSync(__dirname + '/../game/assets/pfboard.js', 'utf8');
let legal = null;
const mk = () => ({ dataset: { mode: 'board', redraws: '0' }, textContent: JSON.stringify({ w: D.w, h: D.h, pcs: [], hand: [], icons: {} }), insertBefore() {}, removeChild() {}, classList: { add() {}, remove() {}, toggle() {} }, appendChild() {}, setAttribute() {}, addEventListener() {}, querySelectorAll() { return []; }, hidden: false, style: {}, getBoundingClientRect() { return { width: 300, height: 200, left: 0, top: 0 }; }, disabled: false, focus() {} });
global.document = { addEventListener() {}, getElementById: () => mk(), createElement: () => mk() };
global.window = { addEventListener() {}, set pfbLegal(f) { legal = f; }, get pfbLegal() { return legal; } };
new Function('window', 'document', src)(global.window, global.document);
let bad = 0;
for (const c of D.cases) {
  const b = { map: {}, count: c.pcs.length }; c.pcs.forEach(p => { b.map[p.x + ',' + p.y] = { x: p.x, y: p.y, e: p.e }; });
  const js = []; for (let y = 0; y < D.h; y++) for (let x = 0; x < D.w; x++) if (legal(b, c.e, x, y)) js.push(x + ',' + y);
  const php = c.legal.map(l => l.join(','));
  if (JSON.stringify(js.sort()) !== JSON.stringify(php.sort())) { bad++; if (bad < 4) console.log('FAIL MISMATCH', JSON.stringify(c).slice(0, 300), '\n js', js.join(' '), '\n php', php.join(' ')); }
}
console.log(bad ? 'FAIL ' + bad + ' of ' + D.cases.length + ' legality mismatches' : 'ok: ' + D.cases.length + ' boards match');
process.exit(bad ? 1 : 0);
