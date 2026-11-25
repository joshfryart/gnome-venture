// 2.8.63 (owner: "Played pieces sometimes revert to default icons and then back to their own icon. Seems to be stat pieces."): every piece object the fight scripts build for drawing keeps the icon key (ik).
// node tests/pf_piece_ik_unit.js [ROOT]   (no DOM: working() of assets/pfboardv1.js and assets/pfboard.js runs with stubs; every P.piece call of a piece of mine or the creature's passes ik)
const fs = require('fs'), vm = require('vm'), path = require('path');
const root = process.argv[2] || path.join(__dirname, '..');
let fails = 0, oks = 0; const ok = (what, c, got) => { if (c) oks++; else { fails++; console.log('FAIL ' + what + (got !== undefined ? ' ' + JSON.stringify(got).slice(0, 300) : '')); } };
function fnSrc(src, name) {   // the source of `function name(...) {...}` (braces matched; the scripts have no braces in strings inside these functions)
  const at = src.indexOf('function ' + name + '('); if (at < 0) return null;
  let i = src.indexOf('{', at), d = 0;
  for (; i < src.length; i++) { if (src[i] === '{') d++; else if (src[i] === '}' && --d === 0) return src.slice(at, i + 1); }
  return null;
}
const E = { L: ['knob', 'mind'], R: ['hole', 'craft'], T: ['flat', null], B: ['knob', 'mind'] };
for (const file of ['pfboardv1.js', 'pfboard.js']) {
  const src = fs.readFileSync(path.join(root, 'game/assets', file), 'utf8'), v1 = file === 'pfboardv1.js';
  const w = fnSrc(src, 'working'); ok(file + ': working() found', !!w); if (!w) continue;
  const hand = [{ t: 'item', e: E, tag: 'keep', m: '', ik: 'stat-weather-lore', st: 'lore' }];
  const held = { pcs: [{ x: 0, y: 0, t: 'guard', e: E, tag: '', m: '', n: 'Sharp Eye', v: 9, ik: 'stat-sharp-eye', st: 'sense' }, { x: 1, y: 0, t: 'hurt', e: E, tag: '', m: '', n: 'Jab', v: 4 }] };
  const sb = { data: { pcs: [], gone: [], hand, held }, tiles: [{ dataset: { name: 'Weather Lore', v: '28' } }], moves: [], rewind: null, showGone: false, hideSpawn: false, hiddenIds: {}, movedBack: {}, usedGone: {}, groupDims: () => [2, 1, 0, 0], Object, JSON };
  vm.runInNewContext(w + '; this.working = working;', sb);
  sb.moves = [{ k: 'p', i: 0, x: 2, y: 1 }];
  const p = sb.working().map['2,1'];
  ok(file + ': the planned piece keeps its icon key', p && p.ghost && p.ik === 'stat-weather-lore', p);
  if (v1) ok(file + ': the planned piece keeps its stat', p && p.st === 'lore', p);
  sb.moves = [{ k: 'c', x: 3, y: 3 }];
  const g = sb.working().map;
  ok(file + ': a planned group keeps each icon key', g['3,3'] && g['3,3'].ik === 'stat-sharp-eye' && g['4,3'] && !g['4,3'].ik, g);
  if (v1) ok(file + ': a planned group keeps each stat', g['3,3'] && g['3,3'].st === 'sense', g['3,3']);
  // every piece picture of mine or the creature's is asked for with its icon key (P.ghost is a bare outline; env pieces have none)
  const calls = src.split('P.piece({').slice(1).map(s => s.slice(0, s.indexOf('})')));
  calls.forEach((c, k) => { if (/type: 'soothe', tint: K\.h/.test(c)) return; ok(file + ': P.piece call ' + (k + 1) + ' passes ik', /\bik: /.test(c), c.slice(0, 120)); });
  if (v1) {
    ok(file + ': icons load for the held group and the draw pile', /\(data\.held && data\.held\.pcs\) \|\| \[\]/.test(src) && /\.concat\(data\.dik \|\| \[\]\)/.test(src));
  }
}
console.log(fails ? `pf_piece_ik_unit: ${fails} of ${fails + oks} FAILED` : `pf_piece_ik_unit: ${oks} ok`); process.exit(fails ? 1 : 0);
