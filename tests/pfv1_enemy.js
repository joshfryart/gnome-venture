// After 2.6.96: see tests/pfv1_enemy.sh. node tests/pfv1_enemy.js BASE GAME TESTSDIR   (SHOTS=dir: a frame every 300 ms of each case; CASES=spawn,quick: only those)
// Every piece that lands without the player placing it must be named while it lands, with who put it there and why: the board putting a piece out for the creature (spawn),
// the creature's chain firing an environment piece, a Quick second piece, a re-pick after its aimed cell was taken, the environment keeping a NEXT piece it cannot place.
const { chromium } = require('playwright');
const { execSync } = require('child_process');
const fs = require('fs');
const [base, game, here] = process.argv.slice(2);
const php = (...a) => execSync(`php -d display_errors=1 ${a.join(' ')}`).toString().trim();
let fails = 0;
const ok = (what, cond, got) => { if (cond) console.log('ok   ' + what); else { console.log(`FAIL ${what}` + (got !== undefined ? ` (got ${JSON.stringify(got).slice(0, 300)})` : '')); fails++; } };
const SHOTS = process.env.SHOTS || '';
const CASES = (process.env.CASES || 'spawn,envfire,quick,repick,pass').split(',');
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
    return { playing: !!f && f.classList.contains('pf-playing'), turn: f ? f.dataset.turn : null, ban: t ? t.textContent.trim() : '', hint: q('#pf-preview'), dock: q('.pfv-dockidle'), row: q('#pfv-row'), cells, nope };
  });
  async function run(name) {
    const sd = JSON.parse(php(`${here}/pfv1_enemy_seed.php`, game, name, process.env.SIZE || 'medium'));
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.evaluate(() => { try { localStorage.setItem('pfvspd', '1'); } catch (e) {} });
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(900);
    const pre = await look(); const data0 = await p.evaluate(() => JSON.parse(document.getElementById('pf-data').textContent));
    if (SHOTS) await p.screenshot({ path: `${SHOTS}/${name}-0before.png` });
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
    return { sd, pre, placed, frames, data, data0 };
  }
  const foe = (d) => d.foe || 'creature';
  const said = (fr, re) => fr.some(f => re.test(f.hint) || re.test(f.dock) || re.test(f.ban));
  for (const name of CASES) {
    let R; try { R = await run(name); } catch (e) { ok(`[${name}] seeded and played`, false, String(e).slice(0, 200)); continue; }
    const { sd, frames, data, data0, pre } = R; console.log(`[${name}] seed ${sd.seed}, ${sd.turns} turns in: ${sd.why}`);
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
  }
  ok('no page error', errs.length === 0, errs);
  await b.close(); console.log('enemy: done'); process.exit(fails ? 1 : 0);
})();
