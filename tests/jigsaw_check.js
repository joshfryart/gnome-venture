// v2.0.87: Jigsaw in a real browser (called by tests/jigsaw.sh). node jigsaw_check.js BASE SHOT_DIR
// Logs in as sprout. Per viewport (desktop, phone): the library shows a card per picture with Easy / Advanced / Expert buttons; each button opens a table with exactly
// 24 / 96 / 216 pieces (6x4, 12x8, 18x12: square pieces on a 3:2 picture), no script errors, no sideways scroll on the phone, no Motion button; the tier select holds only the three tiers.
const { chromium } = require('playwright');
(async () => {
  const [base, shots] = process.argv.slice(2);
  const b = await chromium.launch({ executablePath: process.env.PW_CHROMIUM || undefined, args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  let fails = 0;
  const say = (ok, msg) => { if (!ok) fails++; console.log((ok ? 'ok   ' : 'FAIL ') + msg); };
  for (const [tag, vp] of [['desktop', { width: 1280, height: 800 }], ['phone', { width: 360, height: 740 }]]) {
    const c = await b.newContext({ viewport: vp });
    const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e)));
    await p.goto(base + '/login.php');
    await p.fill('input[name="username"]', 'sprout'); await p.fill('input[name="password"]', 'TestPass123!');
    await Promise.all([p.waitForNavigation({ waitUntil: 'load' }), p.press('input[name="password"]', 'Enter')]);
    await p.goto(base + '/jigsaw.php');
    const cards = await p.locator('#grid .pzcard').count();
    say(cards >= 3, `${tag}: picture cards (${cards})`);
    say(await p.locator('#grid .pzcard').first().locator('button.pztier').count() === 3, `${tag}: a card has 3 tier buttons`);
    say(await p.locator('#grid select').count() === 0, `${tag}: no piece-count picker on a card`);
    for (const [k, n] of [['easy', 24], ['advanced', 96], ['expert', 216]]) {
      await p.goto(base + '/jigsaw.php');
      const t0 = Date.now();
      await p.locator('#grid .pzcard').first().locator(`button[data-tier="${k}"]`).click();
      await p.waitForFunction(m => document.querySelectorAll('#field .piece').length === m, n, { timeout: 15000 }).catch(() => {});
      const got = await p.locator('#field .piece').count();
      say(got === n, `${tag}: ${k} has ${got} pieces (want ${n}) [${Date.now() - t0} ms to set up]`);
      const opts = await p.$$eval('#count option', o => o.map(x => x.value).join(','));
      say(opts === '24,96,216', `${tag}: ${k}: the tier select holds only the three tiers (${opts})`);
      say(await p.locator('#anim').isHidden(), `${tag}: ${k}: no Motion button`);
      say(await p.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1), `${tag}: ${k}: no sideways scroll`);
      if (k === 'expert' || k === 'easy') await p.screenshot({ path: `${shots}/jigsaw-${tag}-${k}.png` });
    }
    say(errs.length === 0, `${tag}: no script errors ${errs.join(' | ')}`);
    await c.close();
  }
  await b.close();
  process.exit(fails ? 1 : 0);
})();
