// node pfboardshot.js BASE OUTDIR : board mode in a browser (phone and wide): pick a piece, see lit cells, place it, Undo, place again. Fails on JS errors, no lit cells, overflow.
const { chromium } = require('playwright');
(async () => {
  const [base, out] = process.argv.slice(2);
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  let fail = 0;
  for (const [name, vp] of [['phone', { width: 412, height: 900 }], ['wide', { width: 1280, height: 800 }]]) {
    const c = await b.newContext({ viewport: vp, deviceScaleFactor: name === 'phone' ? 2 : 1 }); const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' });
    const cells = await p.locator('.pfb-cell').count(), foe = await p.locator('.pfb-p.by-foe').count();
    // find a hand piece that has lit cells
    const hand = p.locator('#pf-hand .pf-tile'); const n = await hand.count(); let lit = 0, used = -1;
    for (let i = 0; i < n && !lit; i++) { await hand.nth(i).click(); lit = await p.locator('.pfb-lit').count(); used = i; }
    await p.screenshot({ path: out + '/pfboard-' + name + '-1-lit.png', fullPage: true });
    let ghosts = 0, goDis = true, undoWorks = false;
    if (lit) {
      await p.locator('.pfb-lit').first().click(); ghosts = await p.locator('.pf-ghost').count(); goDis = await p.locator('#pf-go').isDisabled();
      await p.screenshot({ path: out + '/pfboard-' + name + '-2-placed.png', fullPage: true });
      await p.locator('#pf-undo').click(); undoWorks = (await p.locator('.pf-ghost').count()) === 0 && await p.locator('#pf-go').isDisabled();
    }
    const over = await p.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
    const bad = (cells !== 25 || foe < 1 || !lit || ghosts !== 1 || goDis || !undoWorks || over || errs.length) ? 1 : 0; fail = fail || bad;
    console.log(bad ? 'FAIL' : 'ok', name, '| cells', cells, '| creature pieces', foe, '| lit', lit, '| ghosts', ghosts, '| End turn enabled', !goDis, '| undo', undoWorks, '| overflow', over, '| js errors:', errs.length ? errs.join(' | ') : 'none');
    await c.close();
  }
  await b.close(); process.exit(fail);
})();
