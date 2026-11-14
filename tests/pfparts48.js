// The piece renderer with the beauty-pass kit, in a real browser (run by tests/pfparts48.sh on a bare page that only loads assets/pfparts47.js): node tests/pfparts48.js BASE
const { chromium } = require('playwright');
const base = process.argv[2];
let fails = 0;
const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { console.log(`FAIL ${what} (got ${g}, want ${w})`); fails++; } };
const E = { L: ['hole', 'body'], R: ['knob', 'mind'], T: ['flat'], B: ['knob', 'craft'] };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const open = async (kit, dpr) => { const c = await b.newContext({ viewport: { width: 900, height: 700 }, deviceScaleFactor: dpr }); const p = await c.newPage(); const errs = []; p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
    await p.goto(`${base}/k${kit}.html`, { waitUntil: 'networkidle' }); await p.waitForFunction(() => window.PFParts && window.PFParts.ok, null, { timeout: 8000 }); return { c, p, errs }; };
  let { c, p, errs } = await open(48, 1);
  ck('kit 48 loads: version 47, art 48, the fight gets pf-jig', await p.evaluate(() => [PFParts.atlas.version, PFParts.atlas.art, document.getElementById('pfight').classList.contains('pf-jig')]), [47, 48, true]);
  const r = await p.evaluate((E) => { const P = PFParts, T = P.atlas.order.types, out = {};
    const px = (cv) => HTMLCanvasElement.prototype.getContext.call(cv, '2d').getImageData(0, 0, cv.width, cv.height).data;
    const centre = (cv, z) => { const s = P.atlas.sizes[z], d = px(cv), set = new Set(), cx = Math.round(s.glyph_centre[0]), cy = Math.round(s.glyph_centre[1]), h = z === 'hand' ? 12 : 7; for (let y = cy - h; y <= cy + h; y++) for (let x = cx - h; x <= cx + h; x++) { const q = (y * cv.width + x) * 4; set.add(d[q] + ',' + d[q + 1] + ',' + d[q + 2]); } return set.size; };
    const plate = (cv, z) => { const s = P.atlas.sizes[z], d = px(cv); let n = 0; for (let y = s.plate.at[1]; y < s.plate.at[1] + s.plate.size[1]; y++) for (let x = s.plate.at[0]; x < s.plate.at[0] + s.plate.size[0]; x++) { const q = (y * cv.width + x) * 4; if (d[q] > 230 && d[q + 1] > 220) n++; } return n; };
    for (const z of ['strip', 'hand']) {
      const foe = T.map(t => P.piece({ size: z, owner: 'foe', type: t, edges: E, num: 7, tint: 11 })), me = T.map(t => P.piece({ size: z, owner: 'me', type: t, edges: E, num: 7 }));
      out[z] = { foeDistinct: new Set(foe.map(c => c.toDataURL())).size, meDistinct: new Set(me.map(c => c.toDataURL())).size, foeNotMine: foe.every((c, i) => c.toDataURL() !== me[i].toDataURL()),
        foeGlyph: foe.every(c => centre(c, z) >= 3), meGlyph: me.every(c => centre(c, z) >= 3), foeNum: foe.every(c => plate(c, z) > 10), meNum: me.every(c => plate(c, z) > 10),
        size: [foe[0].width, foe[0].height], hole: px(me[0])[(Math.round(P.atlas.sizes[z].piece[1] / 2) * me[0].width + P.atlas.sizes[z].body_at[0] + 3) * 4 + 3] };
      const HUE = { sun: 46, bramble: 105, rain: 200, wind: 220, mud: 28, thorn: 8 }, env = Object.keys(HUE).map(k => { const cv = P.piece({ size: z, owner: 'foe', type: 'soothe', tint: HUE[k], edges: E, old: false, num: '' }); const before = cv.toDataURL();
        const g = cv.getContext('2d'); g.fillStyle = '#f0f'; g.fillRect(0, 0, cv.width, cv.height);   // what the board's envCv does next: paint over it
        return [before, cv.toDataURL(), P.env({ size: z, kind: k, edges: E }).toDataURL()]; });
      out[z].env = { distinct: new Set(env.map(e => e[0])).size, kept: env.every(e => e[0] === e[1]), same: env.every(e => e[0] === e[2]), noNum: env.every(e => true) };
      out[z].oldDimmer = P.piece({ size: z, owner: 'foe', type: 'hurt', edges: E, num: 7, old: true }).toDataURL() !== foe[0].toDataURL();
      out[z].tag = P.piece({ size: z, owner: 'me', type: 'hurt', tag: 'pierce', edges: E, num: 7 }).toDataURL() !== me[0].toDataURL();
      out[z].ghost = P.ghost({ size: z, owner: 'me', edges: E }).width;
    }
    return out; }, E);
  for (const z of ['strip', 'hand']) {
    ck(`${z}: the creature's 7 types are 7 different pictures, each with a glyph in the centre and its number on the plate; none is my piece`, [r[z].foeDistinct, r[z].foeGlyph, r[z].foeNum, r[z].foeNotMine], [7, true, true, true]);
    ck(`${z}: my 7 types are 7 pictures with glyph and number; a named piece shows its own icon; an old creature piece is dimmer; a hole is a real cut-out; the size is the v47 size`, [r[z].meDistinct, r[z].meGlyph, r[z].meNum, r[z].tag, r[z].oldDimmer, r[z].hole, r[z].size, r[z].ghost], [7, true, true, true, true, 0, z === 'strip' ? [82, 73] : [140, 124], z === 'strip' ? 82 : 140]);
    ck(`${z}: the 6 environment kinds are 6 pictures (asked the way the board asks: a numberless foe piece tinted with the kind's hue), paint put on them afterwards is dropped, P.env gives the same picture`, [r[z].env.distinct, r[z].env.kept, r[z].env.same], [6, true, true]);
  }
  // crisp: shown at 98.7 css px (x 1.2) the bitmap becomes 99 px wide, at 139.4 (x 1.7) the hand art 140, at 82 and 246 (whole) the strip art; the box on the page does not move; a canvas sized by its own bitmap is left alone
  const cr = async (pg) => pg.evaluate(async (E) => { const P = PFParts, st = document.getElementById('stage'), out = []; st.textContent = '';
    const mk = (w) => { const d = document.createElement('div'); d.style.cssText = 'display:inline-block;vertical-align:top;' + (w ? 'width:' + w + 'px' : ''); const cv = P.piece({ size: 'strip', owner: 'foe', type: 'guard', edges: E, num: 12 }); if (w) cv.style.cssText = 'display:block;width:100%;height:auto;image-rendering:pixelated'; d.appendChild(cv); st.appendChild(d); return cv; };
    const cvs = [98.72, 139.39, 82, 246, 62, 0].map(mk); const boxes = cvs.map(c => c.getBoundingClientRect().width);
    await new Promise(r => setTimeout(r, 400));
    return cvs.map((c, i) => [c.width, c.height, Math.abs(c.getBoundingClientRect().width - boxes[i]) < .01, !!c._pfFixed]); }, E);
  ck('crisp at 1 screen pixel per css pixel: x1.2 -> 99 px, x1.7 -> the hand art 140, whole scales keep the strip art, x0.76 -> 62; no box moved; the canvas without a css size keeps 82', await cr(p), [[99, 88, true, false], [140, 124, true, false], [82, 73, true, false], [82, 73, true, false], [62, 55, true, false], [82, 73, true, false]]);
  ck('kit 48: no console error', errs, []); await c.close();
  ({ c, p, errs } = await open(48, 1.5));
  const c15 = await cr(p);
  ck('crisp at 1.5 screen pixels per css pixel: every bitmap is as wide as its box in screen pixels (or whole art); the canvas sized by its bitmap got its bitmap back and keeps its place', [c15.map(x => x[0]), c15.every(x => x[2]), c15[5][3]], [[148, 209, 123, 369, 93, 82], true, true]);
  ck('kit 48 at 1.5: no console error', errs, []); await c.close();
  ({ c, p, errs } = await open(47, 1));
  const k47 = await p.evaluate(async (E) => { const P = PFParts, d = document.createElement('div'); d.style.width = '98.72px'; const cv = P.piece({ size: 'strip', owner: 'me', type: 'hurt', edges: E, num: 12 }); cv.style.cssText = 'display:block;width:100%'; d.appendChild(cv); document.body.appendChild(d); await new Promise(r => setTimeout(r, 300)); return [P.atlas.version, P.atlas.art === undefined, cv.width, typeof P.env]; }, E);
  ck('kit 47 (pfight_jigsaw = 47): still loads and draws as before (no art flag, the bitmap is not touched)', k47, [47, true, 82, 'function']);
  ck('kit 47: no console error', errs, []); await c.close();
  await b.close();
  console.log(fails ? `${fails} failed` : 'parts48: done');
})();
