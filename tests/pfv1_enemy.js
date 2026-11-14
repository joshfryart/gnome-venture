// After 2.6.96: see tests/pfv1_enemy.sh. node tests/pfv1_enemy.js BASE GAME TESTSDIR   (SHOTS=dir: a frame every 300 ms of each case; CASES=spawn,quick: only those)
// Every piece that lands without the player placing it must be named while it lands, with who put it there and why: the board putting a piece out for the creature (spawn),
// the creature's chain firing an environment piece, a Quick second piece, a re-pick after its aimed cell was taken, the environment keeping a NEXT piece it cannot place.
const { chromium } = require('playwright');
const { execSync } = require('child_process');
const fs = require('fs');
const [base, game, here] = process.argv.slice(2);
const php = (...a) => execSync(`php -d display_errors=1 ${a.join(' ')}`).toString().trim();
let fails = 0;
const ok = (what, cond, got) => { if (cond) console.log('ok   ' + what); else { console.log(`FAIL ${what}` + (got !== undefined ? ` (got ${JSON.stringify(got).slice(0, 1500)})` : '')); fails++; } };
const SHOTS = process.env.SHOTS || '';
const CASES = (process.env.CASES || 'spawn,envfire,quick,repick,pass,rings,ringsbreak').split(',');
const SEEDCASE = { rings: 'envfire', ringsbreak: 'repick' };   // after 2.6.96: the lit rings use the envfire and repick seeds
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const c = await b.newContext({ viewport: { width: 390, height: 844 } }); const p = await c.newPage(); const errs = [];
  p.on('pageerror', e => errs.push(String(e)));
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  // what the player can read at a moment: the banner, the line under the board, the dock, the chips over the board, and the cells that are arriving
  const look = () => p.evaluate(() => {
    const f = document.getElementById('pfight'), t = document.querySelector('.pf-turn:not([hidden])'), q = (s) => { const e = document.querySelector(s); return e ? e.textContent.replace(/\s+/g, ' ').trim() : ''; };
    const cells = [...document.querySelectorAll('#pfb-board .pfb-cell')].filter(x => /pfb-spawn|pfv-envin|pfb-drop|pfv-spawned/.test(x.className)).map(x => ({ id: +x.dataset.id, cls: x.className.split(' ').filter(k => /spawn|envin|drop|by-/.test(k)).join(' '), label: x.getAttribute('aria-label') || '', title: x.title || '' }));
    const nope = [...document.querySelectorAll('.pfv-legend .envp.pfv-nope')].map(x => ({ title: x.title || '', label: x.getAttribute('aria-label') || '' }));
    const rings = [...document.querySelectorAll('#pfb-board .pfb-cell.pfv-ring')].map(x => ({ id: +x.dataset.id, cls: x.className.split(' ').filter(k => /^pfv-ring/.test(k)).join(' '), badge: (x.querySelector('.pfv-rb') || {}).textContent || '', label: x.getAttribute('aria-label') || '', title: x.title || '' }));
    const chipTitle = (document.querySelector('#pfv-row .tg.aim') || {}).title || '';
    const lay = { sw: document.documentElement.scrollWidth, cw: document.documentElement.clientWidth, sh: document.documentElement.scrollHeight, ch: document.documentElement.clientHeight, b: (r => r ? [r.x, r.y, r.width, r.height].map(Math.round).join(',') : '')(document.getElementById('pfb-board') && document.getElementById('pfb-board').getBoundingClientRect()), row: (r => r ? Math.round(r.height) : 0)(document.getElementById('pfv-row') && document.getElementById('pfv-row').getBoundingClientRect()) };
    return { rings, lay, chipTitle, playing: !!f && f.classList.contains('pf-playing'), turn: f ? f.dataset.turn : null, ban: t ? t.textContent.trim() : '', hint: q('#pf-preview'), dock: q('.pfv-dockidle'), row: q('#pfv-row'), cells, nope };
  });
  async function run(name) {
    const sd = JSON.parse(php(`${here}/pfv1_enemy_seed.php`, game, SEEDCASE[name] || name, process.env.SIZE || 'medium'));
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.evaluate(() => { try { localStorage.setItem('pfvspd', '1'); } catch (e) {} });
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(900);
    const pre = await look(); let brk = null; const data0 = await p.evaluate(() => JSON.parse(document.getElementById('pf-data').textContent));
    if (SHOTS) await p.screenshot({ path: `${SHOTS}/${name}-0before.png` });
    let lays = null;
    const tcls = async (w) => { if (process.env.DBG) console.log('DBG', w, JSON.stringify(await p.evaluate(() => [...document.querySelectorAll('#pf-hand .pf-tile')].map(t => t.className.replace(/pf-(tile|h|bp|art2)/g, '').trim())))); };
    await tcls('start');
    if (name === 'rings') {   // take its aimed cell with any piece that fits there: the rings go (the aim is broken), and Undo brings them back
      const a = data0.aim; const nh = await p.locator('#pf-hand .pf-tile').count();
      for (let i = 0; i < nh && !brk; i++) {
        if (!(await p.locator('#pf-hand .pf-tile').nth(i).isVisible()) || (await p.locator('#pf-hand .pf-tile').nth(i).getAttribute('aria-disabled')) === 'true') continue;
        await p.locator('#pf-hand .pf-tile').nth(i).click({ timeout: 3000 }).catch(() => {}); await p.waitForTimeout(300);
        const cell = p.locator(`#pfb-board .pfb-lit[data-x="${a.x}"][data-y="${a.y}"]`);
        if (await cell.count()) { await cell.click(); await p.waitForTimeout(900); const m = await look(); const plan = await p.evaluate(() => (document.querySelector('#pf-planbox, #pf-plan') ? document.querySelector('#pf-plan, #pf-planbox').textContent : '') || (document.querySelector('#pf-preview') || {}).textContent || ''); await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(900); brk = { m, back: await look(), plan }; }
        else { await p.locator('#pf-hand .pf-tile').nth(i).click({ timeout: 3000 }).catch(() => {}); await p.waitForTimeout(200); }
      }
    }
    await tcls('after break');
    if (name === 'rings') {   // the rings must not change the layout or add a scroll: measure each size with the rings, then with them taken off
      lays = [];
      for (const [w, h] of [[390, 844], [360, 640], [1280, 720]]) {
        await p.setViewportSize({ width: w, height: h }); await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(900);
        const withR = await look();
        await p.evaluate(() => { document.querySelectorAll('.pfv-rb').forEach(e => e.remove()); document.querySelectorAll('.pfv-ring').forEach(e => { e.classList.remove('pfv-ring', 'pfv-ring-env', 'pfv-ring-me'); }); });
        const without = await look(); lays.push({ w, h, withR, without });
        if (SHOTS && (w === 390 || w === 1280)) { await p.reload({ waitUntil: 'networkidle' }); await p.waitForTimeout(900); await p.screenshot({ path: `${SHOTS}/rings-${w}.png` }); await p.emulateMedia({ colorScheme: 'dark' }); await p.waitForTimeout(300); await p.screenshot({ path: `${SHOTS}/rings-${w}-dark.png` }); await p.emulateMedia({ colorScheme: 'light' }); }
      }
      await p.setViewportSize({ width: 390, height: 844 }); await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(900);
    }
    await tcls('before sd move');
    await p.locator('#pf-hand .pf-tile').nth(sd.i).click(); await p.waitForTimeout(350);
    await p.locator(`#pfb-board .pfb-lit[data-x="${sd.x}"][data-y="${sd.y}"]`).click(); await p.waitForTimeout(700);
    const placed = await look();
    await p.click('#pf-go');
    const frames = []; let quiet = 0;
    for (let k = 0; k < 80; k++) {
      await p.waitForTimeout(k < 2 ? 150 : 300); let L; try { L = await look(); } catch (e) { continue; }
      L.k = k; frames.push(L);
      if (SHOTS && L.turn !== data0.turn + '') await p.screenshot({ path: `${SHOTS}/${name}-${String(k).padStart(2, '0')}.png` });
      quiet = !L.playing && L.turn !== String(data0.turn) ? quiet + 1 : 0; if (quiet >= 12) break;
    }
    const data = await p.evaluate(() => JSON.parse(document.getElementById('pf-data').textContent));
    if (SHOTS) fs.writeFileSync(`${SHOTS}/${name}.json`, JSON.stringify({ sd, pre, placed, frames, replay: data.replay, spawn: (data.pcs || []).filter(x => x.spawn), aim0: data0.aim, aim: data.aim, reaim: data.reaim }, null, 1));
    return { sd, pre, placed, frames, data, data0, lays, brk };
  }
  const foe = (d) => d.foe || 'creature';
  const said = (fr, re) => fr.some(f => re.test(f.hint) || re.test(f.dock) || re.test(f.ban));
  for (const name of CASES) {
    let R; try { R = await run(name); } catch (e) { ok(`[${name}] seeded and played`, false, String(e).slice(0, 1200)); continue; }
    const { sd, frames, data, data0, pre, placed, lays, brk } = R; console.log(`[${name}] seed ${sd.seed}, ${sd.turns} turns in: ${sd.why}`);
    if (name === 'spawn') {
      const sp = (data.pcs || []).find(x => x.spawn); ok('[spawn] the board put out a piece for the creature', !!sp);
      if (sp) {
        const re = new RegExp('puts out ' + sp.n + '.*' + foe(data), 'i');
        const shown = frames.filter(f => f.cells.some(x => x.id === sp.id));
        ok('[spawn] while it arrives, the line under the board names it and says it was put out for the creature', shown.length > 0 && shown.slice(0, 4).some(f => re.test(f.hint) || re.test(f.dock)), shown.slice(0, 4).map(f => f.hint));
        ok('[spawn] it arrives inside the replay (before your turn is back), not after it', frames.some(f => f.playing && f.cells.some(x => x.id === sp.id && /spawn/.test(x.cls))), frames.filter(f => f.cells.some(x => x.id === sp.id)).map(f => f.playing + ' ' + f.cells.map(x => x.cls).join('/')).slice(0, 3));
        const last = frames[frames.length - 1], cell = last.cells.find(x => x.id === sp.id);
        ok('[spawn] after the replay the piece still says it was put out for the creature (mark and label)', !!cell && /pfv-spawned/.test(cell.cls) && /put out/i.test(cell.label + ' ' + cell.title), cell);
      }
    }
    if (name === 'envfire') {
      const ev = (data.replay || []).filter(e => e.env === 'fire' && e.for === 'foe');
      ok('[envfire] the creature\'s chain fired an environment piece', ev.length > 0);
      const nm = ev.length ? ev[0].n : '?';
      ok('[envfire] before you move, the aim chip names the environment piece its chain fires', new RegExp(nm).test(pre.row), pre.row);
      ok('[envfire] when it fires, the line says the creature\'s chain fires it, for the creature', said(frames, new RegExp(foe(data) + '.{0,40}(chain|links).{0,40}' + nm + '|' + nm + '.{0,60}for the ' + foe(data), 'i')), [...new Set(frames.map(f => f.hint))]);
    }
    if (name === 'quick') {
      ok('[quick] before you move, the aim chip says it plays 2 pieces this round', /2 pieces/.test(pre.row), pre.row);
      ok('[quick] the second piece is named as Quick\'s extra piece when it lands', said(frames, /Quick/i), [...new Set(frames.map(f => f.hint))]);
    }
    if (name === 'repick') {
      ok('[repick] the creature\'s step says its aim was taken and it picks again', said(frames, /(aim|cell).{0,40}(taken|blocked).{0,40}pick|picks? again/i), [...new Set(frames.map(f => f.hint))]);
    }
    if (name === 'pass') {
      const pv = (data.replay || []).find(e => e.env === 'pass'); ok('[pass] the environment kept a piece', !!pv);
      const sh = frames.filter(f => f.nope.length);
      ok('[pass] the shaking NEXT piece says it could not be placed', sh.length > 0 && sh.every(f => f.nope.every(n => /no (free )?(place|spot)|could not|cannot be placed|full/i.test(n.title + ' ' + n.label))), sh.map(f => f.nope));
      ok('[pass] the line says the environment keeps it for next round', said(frames, /keeps|no place/i), [...new Set(frames.map(f => f.hint))]);
    }
    if (name === 'rings') {
      const ids = ((data0.aim || {}).tot || {}).ids || [], env = ids.filter(q => q.by === 'env'), me = ids.filter(q => q.by === 'me');
      ok('[rings] the aim before the move names an environment piece it would fire (ids in the aim total)', env.length > 0, ids);
      const re = pre.rings.filter(r => /pfv-ring-env/.test(r.cls));
      ok('[rings] every environment piece in ids has a pulsing ring (and only those)', env.length > 0 && re.length === env.length && env.every(q => re.some(r => r.id === q.id)), [pre.rings, env]);
      ok('[rings] the badge says the effect for the creature or you (Sun x2 for it, Rain +N guard for it, Bramble -N you, Thornburst -N it)', re.length > 0 && re.every(r => /^(Sun x[\d.]+ for it|Rain \+\d+ guard for it|Bramble (-\d+ )?you|Thornburst (-\d+ )?it)$/.test(r.badge)), re.map(r => r.badge));
      ok('[rings] the ring is announced (label or title says its chain would fire it)', re.every(r => /fire/i.test(r.label + ' ' + r.title)), re.map(r => r.label));
      ok('[rings] your pieces its chain would fire get the other ring style (pfv-ring-me) with an "it fires this" badge', pre.rings.filter(r => /pfv-ring-me/.test(r.cls)).length === me.length && pre.rings.filter(r => /pfv-ring-me/.test(r.cls)).every(r => /it fires this/i.test(r.badge)), pre.rings);
      ok('[rings] the aim chip says what the rings mean (tooltip "Lit rings: pieces its chain would fire")', /Lit rings: pieces its chain would fire/.test(pre.chipTitle), pre.chipTitle);
      ok('[rings] no ring while the replay plays', frames.filter(f => f.playing).every(f => f.rings.length === 0), frames.filter(f => f.playing && f.rings.length).length);
      ok('[rings] a piece of yours fits the aimed cell (so the break can be tried)', !!brk);
      if (brk) {
        ok('[rings] after you take its aimed cell no ring is left (aim broken)', brk.m.rings.length === 0 && /broken|pick again/i.test(brk.plan), [brk.m.rings, brk.plan]);
        ok('[rings] on a fresh page (nothing placed) the rings are back, as many as before', brk.back.rings.length === pre.rings.length, [brk.back.rings.length, pre.rings.length]);
      }
      (lays || []).forEach(L => {
        ok(`[rings] ${L.w}x${L.h}: rings are drawn`, L.withR.rings.length > 0, L.withR.rings.length);
        ok(`[rings] ${L.w}x${L.h}: no layout shift (board box, chip row height) and no added scroll`, L.withR.lay.b === L.without.lay.b && L.withR.lay.row === L.without.lay.row && L.withR.lay.sw === L.without.lay.sw && L.withR.lay.sh === L.without.lay.sh && L.withR.lay.sw <= L.withR.lay.cw + 1, [L.withR.lay, L.without.lay]);
      });
    }
    if (name === 'ringsbreak') {
      ok('[ringsbreak] the aim before the move is whole (no broken) and has rings for each of its environment and your pieces', !(data0.aim && data0.aim.tot && data0.aim.tot.broken) && pre.rings.length === (((data0.aim || {}).tot || {}).ids || []).filter(q => q.by !== 'foe').length, [pre.rings.length, ((data0.aim || {}).tot || {}).ids]);
      ok('[ringsbreak] placing on its aimed cell breaks the aim: no ring is left on the board', placed.rings.length === 0, placed.rings);
      ok('[ringsbreak] after the replay the new aim shows rings only for ids in the new aim', frames[frames.length - 1].rings.every(r => (((data.aim || {}).tot || {}).ids || []).some(q => q.id === r.id)), frames[frames.length - 1].rings);
    }
  }
  ok('no page error', errs.length === 0, errs);
  await b.close(); console.log('enemy: done'); process.exit(fails ? 1 : 0);
})();
