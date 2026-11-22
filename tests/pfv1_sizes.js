// 2.7.55 board sizes: node tests/pfv1_sizes.js BASE GAME TESTSDIR SHOTDIR   (see tests/pfv1_sizes.sh)
// A small (3x3), a large (5x5) and a boss fight with its AOE marked, at phone width (390 x 844, deviceScaleFactor 1): the board has W x H cells, nothing scrolls sideways,
// the cells are at least 44 px, the boss's marked cells are on the board with the AOE chip. A screenshot of each goes to SHOTDIR.
const { chromium } = require('playwright');
const { execSync } = require('child_process');
const [base, game, here, shots] = process.argv.slice(2);
const php = (...a) => execSync(`php -d display_errors=1 ${a.join(' ')}`).toString().trim();
let fails = 0;
const ok = (what, cond, got) => { if (cond) console.log('ok   ' + what); else { console.log(`FAIL ${what}` + (got !== undefined ? ` (got ${JSON.stringify(got).slice(0, 600)})` : '')); fails++; } };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const c = await b.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 1 }); const p = await c.newPage(); const errs = [];
  p.on('pageerror', e => errs.push(String(e)));
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  for (const [name, slug, aoe] of [['small-3x3', 'leopard-slug', ''], ['large-5x5', 'grey-heron', ''], ['boss-aoe', 'coconut-crab-titan', 'aoe']]) {
    const sd = JSON.parse(php(`${here}/pfv1_sizes_seed.php`, game, slug, aoe));
    if (sd.err) { ok(`${name}: seeded`, false, sd); continue; }
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.evaluate(() => { try { localStorage.setItem('pfvspd', '0'); } catch (e) {} });
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(1200);
    const L = await p.evaluate(() => {
      const d = JSON.parse(document.getElementById('pf-data').textContent), bd = document.getElementById('pfb-board'), r = bd ? bd.getBoundingClientRect() : null;
      const marks = [...document.querySelectorAll('#pfb-board .mk.aoe')].length, chip = (document.querySelector('#pfv-row .tg.aoe') || {}).textContent || '';
      return { w: d.w, h: d.h, aoe: d.aoe || null, marks, chip, sw: document.documentElement.scrollWidth, cw: document.documentElement.clientWidth, bw: r ? Math.round(r.width) : 0, bh: r ? Math.round(r.height) : 0 };
    });
    console.log(`[${name}] ${slug} seed ${sd.seed}: board ${L.w}x${L.h} ${L.bw}x${L.bh}px, aoe marks ${L.marks} chip "${L.chip}"`);
    ok(`${name}: board ${sd.w}x${sd.h} in the page`, L.w === sd.w && L.h === sd.h, L);
    ok(`${name}: no sideways scroll at 390 px`, L.sw <= L.cw, [L.sw, L.cw]);
    ok(`${name}: cells at least 44 px wide`, L.bw / L.w >= 44, L.bw / L.w);
    if (aoe) { ok(`${name}: the AOE cells are marked (${sd.aoe.length})`, L.marks === sd.aoe.length && L.marks > 0, L); ok(`${name}: the AOE chip names it`, /Husk Crush/.test(L.chip), L.chip); }
    await p.screenshot({ path: `${shots}/${name}.png` });
  }
  ok('no page errors', errs.length === 0, errs);
  await b.close();
  console.log(fails ? `sizes: ${fails} FAILED` : 'sizes: done');
  process.exit(fails ? 1 : 0);
})();
