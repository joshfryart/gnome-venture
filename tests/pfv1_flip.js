// after 2.6.94 (Josh): flip a piece, pick a different one: the flip is taken back by itself (a 2.6.94 fight). T12: in a new fight (flip any number of times) every flip stays. node tests/pfv1_flip.js BASE GAME TESTSDIR
const { chromium } = require('playwright');
const { execSync } = require('child_process');
const [base, game, here] = process.argv.slice(2);
const seed = (...a) => execSync(`php -d display_errors=1 ${here}/pbox_v1_seed.php ${game} ${a.join(' ')}`).toString().trim();
const seedNew = (...a) => execSync(`PBOX_RULES=new php -d display_errors=1 ${here}/pbox_v1_seed.php ${game} ${a.join(' ')}`).toString().trim();   // T12: a fight with the rules a new fight has
let fails = 0;
const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { console.log(`FAIL ${what} (got ${g}, want ${w})`); fails++; } };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const p = await (await b.newContext({ viewport: { width: 390, height: 844 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  seed('fight', 'medium'); seed('midfight', '3', '0', 'soft');
  await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(600);
  // the page keeps the live state in memory (pf-data is only the first load): read the tiles' flipped mark and the Flip button
  const hand = () => p.evaluate(() => [...document.querySelectorAll('#pf-hand .pf-tile')].map(t => ({ f: t.classList.contains('pfv-flipped'), c: true })));
  const used = () => p.evaluate(() => /used/i.test(document.getElementById('pf-flip').textContent));
  const tiles = p.locator('#pf-hand .pf-tile');
  const n = await tiles.count(); ck('hand has 2+ pieces', n >= 2, true);
  const h0 = await hand(); const idx = h0.map((h, i) => h.c ? i : -1).filter(i => i >= 0);
  ck('two pieces can flip', idx.length >= 2, true);
  const [a, c] = idx; const was = h0[a].f;
  await tiles.nth(a).click(); await p.waitForTimeout(200); await p.click('#pf-flip'); await p.waitForTimeout(700);
  let h = await hand(); ck('piece A is flipped', h[a].f, !was);
  await tiles.nth(c).click(); await p.waitForTimeout(900);
  h = await hand(); ck('picking piece B took A\'s flip back, flip free again', [h[a].f, await used()], [was, false]);
  ck('piece B is picked and not flipped', [await tiles.nth(c).evaluate(t => t.classList.contains('pf-picked')), h[c].f], [true, h0[c].f]);
  await p.reload({ waitUntil: 'networkidle' }); await p.waitForTimeout(600);
  h = await hand(); ck('after a reload (server state) A is not flipped', h[a].f, was);
  await tiles.nth(c).click(); await p.waitForTimeout(250);
  await p.click('#pf-flip'); await p.waitForTimeout(700);
  h = await hand(); ck('B can now be flipped', h[c].f, !h0[c].f);
  await tiles.nth(c).click(); await p.waitForTimeout(500);   // deselect B: its flip stays
  h = await hand(); ck('deselecting does not take the flip back', [h[c].f, await used()], [!h0[c].f, true]);
  // ---- T12: a new fight: flip A, pick B, flip B: both stay flipped; the button never says "used"
  console.log('-- new rules');
  seedNew('fight', 'medium'); seedNew('midfight', '3', '0', 'soft');
  await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(600);
  const lab = () => p.evaluate(() => document.getElementById('pf-flip').textContent + '|' + document.getElementById('pf-flip').title);
  const n2 = await tiles.count(); const g0 = await hand(); const fl = [];
  for (let k = 0; k < n2 && fl.length < 2; k++) { await tiles.nth(k).click(); await p.waitForTimeout(250); if (!(await p.isDisabled('#pf-flip'))) fl.push(k); }
  ck('new fight: two pieces can flip', fl.length, 2);
  const [a2, b2] = fl;
  await tiles.nth(a2).click(); await p.waitForTimeout(250);
  if (await tiles.nth(a2).evaluate(t => !t.classList.contains('pf-picked'))) { await tiles.nth(a2).click(); await p.waitForTimeout(250); }
  await p.click('#pf-flip'); await p.waitForTimeout(800);
  let g = await hand(); ck('new fight: piece A is flipped', g[a2].f, !g0[a2].f);
  await tiles.nth(b2).click(); await p.waitForTimeout(900);
  g = await hand(); ck('new fight: picking piece B does not take A\'s flip back', g[a2].f, !g0[a2].f);
  ck('new fight: the button is free for B and never says used', [await p.isDisabled('#pf-flip'), /used/i.test(await lab()), /once a turn/i.test(await lab())], [false, false, false]);
  await p.click('#pf-flip'); await p.waitForTimeout(800);
  g = await hand(); ck('new fight: B is flipped and A stays flipped', [g[a2].f, g[b2].f], [!g0[a2].f, !g0[b2].f]);
  await p.reload({ waitUntil: 'networkidle' }); await p.waitForTimeout(600);
  g = await hand(); ck('new fight: after a reload both are still flipped (server state)', [g[a2].f, g[b2].f], [!g0[a2].f, !g0[b2].f]);
  ck('no console error', errs, []);
  console.log('flip: done'); await b.close(); process.exit(fails ? 1 : 0);
})().catch(e => { console.log('FAIL crash ' + e); process.exit(1); });
