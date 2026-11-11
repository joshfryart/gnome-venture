// node tests/pfight_js.js CASES.json : drives the real game/assets/pfight.js against a stub DOM and compares its live preview with the PHP engine's numbers.
const fs = require('fs'); const D = JSON.parse(fs.readFileSync(process.argv[2]));
const src = fs.readFileSync(__dirname + '/../game/assets/pfight.js', 'utf8');
let bad = 0, shown = 0;
for (const c of D.cases) {
  const els = {};
  const mk = () => ({ dataset: {}, attrs: {}, classList: { toggle() {} }, hidden: true, value: '', textContent: '', disabled: false, listeners: {}, addEventListener(e, f) { this.listeners[e] = f; }, setAttribute(k, v) { this.attrs[k] = v; }, getAttribute(k) { return this.attrs[k]; }, querySelector() { return null; }, appendChild() {}, querySelectorAll() { return []; }, focus() {}, submit() {} });
  const root = mk(); root.dataset = { open: (c.prev && c.prev.r) || '', opent: c.prev ? c.prev.t : '', openv: c.prev ? String(c.prev.v) : '0', openby: c.by, redraws: '0' };
  const tiles = c.hand.map((t, i) => { const b = mk(); b.dataset = { i: String(i), t: t.t, v: String(t.v), knob: t.r || '', hole: D.hole[t.t] }; b.attrs['aria-label'] = 'x, y'; return b; });
  const hand = mk(); hand.querySelectorAll = () => tiles;
  for (const id of ['pf-form', 'pf-chain', 'pf-go', 'pf-undo', 'pf-preview', 'pf-redraw', 'pf-card', 'pf-rform']) els[id] = mk();
  els.pfight = root; els['pf-hand'] = hand; els['pf-data'] = { textContent: JSON.stringify({ combos: D.combos, hole: D.hole }) };
  global.document = { getElementById: id => els[id], createElement: () => mk() }; global.window = { addEventListener() {} };
  new Function(src)();
  for (const i of c.idx) hand.listeners.click({ target: { closest: () => tiles[i] } });
  const txt = els['pf-preview'].textContent;
  const ic = { hurt: '⚔️', guard: '🛡️', heal: '💚', charm: '🌸', soothe: '😌', item: '🎒' };
  const exp = []; for (const k of Object.keys(ic)) if (c.tot[k]) exp.push(ic[k] + ' ' + c.tot[k]);
  const e = exp.join(' · ') || 'Setup only';
  if (!txt.startsWith(e)) { bad++; if (shown++ < 5) console.log('FAIL MISMATCH', JSON.stringify(c), '\n js:', txt, '\n php:', e); }
  else if (c.notes.length && !txt.includes(c.notes.join(', '))) { bad++; if (shown++ < 5) console.log('FAIL NOTES', txt, c.notes); }
}
console.log(bad ? 'FAIL ' + bad + ' of ' + D.cases.length + ' preview mismatches' : 'ok: ' + D.cases.length + ' cases match');
process.exit(bad ? 1 : 0);
