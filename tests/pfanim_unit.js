// 2.7.55 piece effects: node tests/pfanim_unit.js ROOT   (no DOM: assets/pfanim.js runs with stubs)
// 1) the compact pfanim-data.json gives back, through the engine's own look-up, exactly the look claude/pf-anim/<size>-creatures.json authored for every creature piece
//    (themed: motif, layout, speed, size, extra, carrier, colours, sound, personality; generic: family, lift, sound, colours);
// 2) the perimeter (the chain's outer edge) for single, I, L, T, S, 2x2, U, a ring of 8, a diagonal pair, a 3x3 block and a bent chain of 5 on a 5x5 board;
// 3) every player / shared piece name resolves to one of the 16 families; an unknown piece falls back by type and tag.
const fs = require('fs'), vm = require('vm'), path = require('path');
const root = process.argv[2] || path.join(__dirname, '..');
let fails = 0, oks = 0; const ok = (what, c, got) => { if (c) oks++; else { fails++; console.log('FAIL ' + what + (got !== undefined ? ' ' + JSON.stringify(got).slice(0, 400) : '')); } };
const win = { performance: { now: () => 0 }, localStorage: { getItem: () => null, setItem() {}, removeItem() {} }, matchMedia: () => ({ matches: false }) };
const sb = { window: win, document: { currentScript: null }, performance: win.performance, Math, JSON, console };
vm.runInNewContext(fs.readFileSync(path.join(root, 'game/assets/pfanim.js'), 'utf8'), sb);
const A = win.PFAnim; ok('engine loads (window.PFAnim)', !!A && typeof A.fire === 'function');
const data = JSON.parse(fs.readFileSync(path.join(root, 'game/assets/pfanim-data.json'), 'utf8')); A._prep(data); ok('data prepared', A.ready());
const size = fs.statSync(path.join(root, 'game/assets/pfanim-data.json')).size;
let n = 0, nt = 0;
for (const sz of ['small', 'medium', 'large', 'boss']) {
  const f = path.join(root, 'claude/pf-anim', sz + '-creatures.json'); if (!fs.existsSync(f)) continue;
  const J = JSON.parse(fs.readFileSync(f, 'utf8')), seen = {};
  for (const e of J.entries) {
    const k = e.creature + '/' + e.name; if (seen[k]) continue; seen[k] = 1; n++;
    const p = { by: 'foe', n: e.name, t: e.type, tag: e.tag === '-' ? '' : e.tag, v: e.v };
    const L = A.look(p, e.creature);
    if (e.th) { nt++; const t = e.th;
      const got = [L.th && L.th.mp.lay, L.th && L.th.mp.spd, L.th && L.th.mp.z, L.th && L.th.mp.x, L.th && L.th.carrier, L.col, L.acc, L.hi, L.snd, L.pz, L.fam, L.lift];
      const want = [t.mp.lay, t.mp.spd, t.mp.z, t.mp.x, t.carrier, t.col, t.acc, t.hi, t.snd, t.place.pers, e.family, e.place.lift];
      ok(`${sz} ${k}: themed look`, JSON.stringify(got) === JSON.stringify(want), { got, want });
      ok(`${sz} ${k}: motif`, L.M && L.M.g === J.motifs[t.motif].g && L.M.mo === J.motifs[t.motif].mo && L.M.gap === J.motifs[t.motif].gap);
    } else {
      const got = [L.fam, L.lift, L.snd, L.col, L.acc, L.th], want = [e.family, e.place.lift, e.place.snd, e.col, e.accent, null];
      ok(`${sz} ${k}: generic look`, JSON.stringify(got) === JSON.stringify(want), { got, want });
    }
  }
}
console.log(`looks: ${n} creature pieces checked (${nt} themed); data ${size} bytes`);
ok('data under 250 KB', size < 250000, size);
const FAM = ['slash', 'bite', 'thrust', 'shock', 'buzz', 'bash', 'shield', 'thorn', 'puff', 'mend', 'drip', 'web', 'ripple', 'sparkle', 'ember', 'leaf'];
for (const nm of Object.keys(data.pp)) { const L = A.look({ by: 'me', n: nm, t: 'hurt', tag: '' }); ok('player piece ' + nm, FAM.includes(L.fam) && /^#[0-9a-f]{6}$/.test(L.col), L); }
ok('pilot: Swing slash, Dodge shield, Rest mend, Jab shock, Pierce thrust, Brace shield/thud, Soothe ripple', ['Swing', 'Dodge', 'Rest', 'Jab', 'Pierce', 'Brace', 'Soothe'].map(x => A.look({ by: 'me', n: x, t: 'hurt' }).fam).join() === 'slash,shield,mend,shock,thrust,shield,ripple' && A.look({ by: 'me', n: 'Brace', t: 'guard', tag: 'hold' }).snd === 'thud');
for (const [t, tag, want] of [['hurt', 'poison', 'drip'], ['hurt', 'quick', 'shock'], ['guard', 'hold', 'shield'], ['guard', 'thorns', 'thorn'], ['heal', '', 'mend'], ['charm', '', 'sparkle'], ['trick', 'trip', 'web'], ['item', 'snack', 'sparkle'], ['soothe', '', 'ripple'], ['hurt', 'pierce', 'thrust']])
  ok(`fallback ${t}/${tag} -> ${want}`, A.look({ by: 'me', n: 'No Such Piece ' + t + tag, t, tag }).fam === want && A.look({ by: 'foe', n: 'No Such', t, tag }, 'no-such-creature').fam === want);
ok('a creature piece with no data is heavy (creature variant)', A.look({ by: 'foe', n: 'Zzz', t: 'hurt', tag: '' }, 'nobody').h === true);
ok('the environment: Sun sparkles, Bramble thorns', A.look({ by: 'env', kind: 'sun', n: 'Sun', t: 'env' }).fam === 'sparkle' && A.look({ by: 'env', kind: 'bramble', n: 'Bramble', t: 'env' }).fam === 'thorn' && A.look({ by: 'env', kind: 'sun', n: 'Sun' }).env === true);
// ---- 2.7.56 the environment's eight pieces: each kind has its own place motion, place effect and fire effect; they draw on a 2D context without errors or NaN
//      at several times, on a 3x3 board and a 5x5 one (390 px wide page = the same art pixels), in every arrow direction, with and without a target / push / falls
const KINDS = ['sun', 'bramble', 'rain', 'wind', 'mud', 'thorn', 'quake', 'spring'];
ok('every environment kind has an effect module (' + A.envKinds().join(',') + ')', JSON.stringify(A.envKinds()) === JSON.stringify(KINDS.slice().sort()), A.envKinds());
function stubCtx(bad) {
  const num = (fn, a) => { for (const v of a) if (typeof v === 'number' && !isFinite(v)) bad.push(fn + ' ' + JSON.stringify(a)); };
  const c = { n: 0, _a: 1, set globalAlpha(v) { if (typeof v !== 'number' || !isFinite(v)) bad.push('alpha ' + v); this._a = v; }, get globalAlpha() { return this._a; }, fillStyle: '', strokeStyle: '', lineWidth: 1 };
  for (const fn of ['fillRect', 'strokeRect', 'rect', 'translate', 'rotate', 'drawImage', 'moveTo', 'lineTo']) c[fn] = function (...a) { num(fn, a); if (fn === 'fillRect' || fn === 'strokeRect') c.n++; };
  for (const fn of ['save', 'restore', 'beginPath', 'clip', 'stroke', 'fill']) c[fn] = () => {};
  c.createPattern = () => null; return c;
}
for (const kind of KINDS) {
  let errs = [], bad = [], drawnPl = 0, drawnFi = 0, maxN = 0, motionOk = true;
  for (const [w, x, y, tg, dir] of [[3, 1, 1, { x: 0, y: 1, id: 2 }, 'R'], [5, 2, 2, { x: 2, y: 1, id: 3 }, 'T'], [5, 0, 4, null, 'L'], [5, 4, 0, { x: 4, y: 1, id: 4 }, 'B']]) {
    const o = { w, x, y, tg, dir, fr: x % 2 ? 'me' : 'foe', mv: kind === 'wind' && tg ? { id: 9, fx: x + 1, fy: y, tx: x + 2, ty: y } : null, falls: kind === 'quake' ? [{ id: 7, x: Math.max(0, x - 1), y }] : [] };
    for (const ms of [0, 1, 150, 240, 300, 450, 599, 600]) {
      try { const ps = A.envDraw(kind, 'ps', ms, null, o); if (!ps || !['s', 'q', 'x', 'y', 'r', 'sh', 'a'].every(k => isFinite(ps[k] || 0))) motionOk = false;
        const c = stubCtx(bad), n = A.envDraw(kind, 'pl', ms, c, o); drawnPl += c.n; maxN = Math.max(maxN, n); } catch (e) { errs.push('pl ' + ms + ' ' + e.message); } }
    for (const ms of [0, 1, 100, 300, 500, 700, 900, 1100, 1199, 1200]) {
      try { const c = stubCtx(bad), n = A.envDraw(kind, 'fi', ms, c, o); drawnFi += c.n; maxN = Math.max(maxN, n); } catch (e) { errs.push('fi ' + ms + ' ' + e.message); } }
  }
  ok(`env ${kind}: place motion, place effect and fire effect draw with no error`, errs.length === 0, errs.slice(0, 3));
  ok(`env ${kind}: no NaN / Infinity reaches the canvas`, bad.length === 0, bad.slice(0, 3));
  ok(`env ${kind}: the place motion is a finite transform at every time`, motionOk);
  ok(`env ${kind}: the place effect draws (${drawnPl}) and the fire effect draws (${drawnFi})`, drawnPl > 0 && drawnFi > 0, [drawnPl, drawnFi]);
  ok(`env ${kind}: stays in the glyph budget (max ${maxN} particles a frame of 220)`, maxN <= 220, maxN);
}
// ---- perimeter
const F = { L: 'f', R: 'f', T: 'f', B: 'f' }, cells = a => a.map(([x, y], i) => ({ id: i, x, y, e: F }));
const BW = 56, BH = 47;
function shape(name, a, edgesOut, noRun) {
  const P = A.perimeter(cells(a));
  const len = edgesOut.h * BW + edgesOut.v * BH;
  ok(`perimeter ${name}: outer length ${len}`, Math.abs(P.len - len) < 1e-6, P.len);
  ok(`perimeter ${name}: an anchor for every piece`, P.anchor.length === a.length && P.anchor.every(s => s >= 0 && s <= P.len + 1e-6), P.anchor);
  ok(`perimeter ${name}: runs for every piece on the edge` + (noRun ? ' (piece ' + noRun + ' has none)' : ''), P.runs.every((r, i) => (noRun !== undefined && noRun.includes(i)) ? r.length === 0 : r.length > 0), P.runs.map(r => r.length));
  const q = P.at(P.len * .37); ok(`perimeter ${name}: at() gives a point and a unit normal`, Math.abs(Math.hypot(q.nx, q.ny) - 1) < 1e-6);
  const P2 = A.perimeter(a.map(([x, y], i) => ({ id: i, x: x + 1, y: y + 1, e: F })));
  ok(`perimeter ${name}: moved one cell = same path moved`, P2.pts.length === P.pts.length && P2.pts.every((p, i) => Math.abs(p[0] - P.pts[i][0] - BW) < 1e-6 && Math.abs(p[1] - P.pts[i][1] - BH) < 1e-6));
  return P;
}
shape('single', [[0, 0]], { h: 2, v: 2 });
shape('I of 3', [[0, 0], [1, 0], [2, 0]], { h: 6, v: 2 });
shape('L of 3', [[0, 0], [0, 1], [1, 1]], { h: 4, v: 4 });
shape('T of 4', [[0, 0], [1, 0], [2, 0], [1, 1]], { h: 6, v: 4 });
shape('S of 4', [[1, 0], [2, 0], [0, 1], [1, 1]], { h: 6, v: 4 });
shape('2x2', [[0, 0], [1, 0], [1, 1], [0, 1]], { h: 4, v: 4 });
shape('U of 5', [[0, 0], [0, 1], [1, 1], [2, 1], [2, 0]], { h: 6, v: 6 });   // the notch is part of the outer loop
shape('ring of 8 (the hole is not walked)', [[0, 0], [1, 0], [2, 0], [2, 1], [2, 2], [1, 2], [0, 2], [0, 1]], { h: 6, v: 6 });
shape('3x3 block (the centre has no outer edge)', [[0, 0], [1, 0], [2, 0], [0, 1], [1, 1], [2, 1], [0, 2], [1, 2], [2, 2]], { h: 6, v: 6 }, [4]);
shape('bent chain of 5 on 5x5', [[0, 0], [1, 0], [2, 0], [2, 1], [2, 2]], { h: 6, v: 6 });
const Pd = A.perimeter(cells([[0, 0], [1, 1]])); ok('perimeter diagonal pair: one loop walked, both anchored', Math.abs(Pd.len - 2 * BW - 2 * BH) < 1e-6 && Pd.anchor.length === 2 && Pd.anchor.every(s => s >= 0), [Pd.len, Pd.anchor]);
const Pk = A.perimeter([{ id: 0, x: 0, y: 0, e: { L: 'h', R: 'k', T: 'k', B: 'h' } }]); ok('perimeter: free knobs bump out, holes notch in (longer path)', Pk.len > 2 * BW + 2 * BH && Pk.pts.length === 20, [Pk.len, Pk.pts.length]);
console.log(fails ? `pfanim_unit: ${fails} FAILED (${oks} ok)` : `pfanim_unit: ${oks} ok`);
process.exit(fails ? 1 : 0);
