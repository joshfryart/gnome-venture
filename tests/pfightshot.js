// node pfightshot.js BASE OUTDIR : phone (412px) screenshots of the puzzle fight card; taps a chain and checks the preview, the badges and that nothing overflows sideways.
const { chromium } = require('playwright');
(async () => {
  const [base, out] = process.argv.slice(2);
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const c = await b.newContext({ viewport: { width: 412, height: 900 }, deviceScaleFactor: 2 });
  const p = await c.newPage(); const errs = [];
  p.on('pageerror', e => errs.push(String(e)));
  p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' });
  await p.screenshot({ path: out + '/pfight-1-start.png', fullPage: true });
  const tiles = p.locator('#pf-hand .pf-tile'); const n = await tiles.count();
  await tiles.nth(0).click(); await tiles.nth(2).click();
  const prev = await p.locator('#pf-preview').innerText(); const badges = await p.locator('.pf-ord').count(); const dis = await p.locator('#pf-go').isDisabled();
  await p.screenshot({ path: out + '/pfight-2-chain.png', fullPage: true });
  const over = await p.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
  let fail = (n < 5 || over || dis === true || !/\S/.test(prev) || badges !== 2 || errs.length) ? 1 : 0;
  console.log(fail ? 'FAIL' : 'ok', 'tiles', n, '| preview:', prev, '| badges', badges, '| play disabled', dis, '| h-overflow', over, '| js errors:', errs.length ? errs.join(' | ') : 'none');
  await p.click('#pf-go'); await p.waitForTimeout(1500); console.log('flash:', (await p.locator('.flash, .msg, .alert').allInnerTexts()).join(' | ').slice(0,200), '| url', p.url());
  await p.screenshot({ path: out + '/pfight-3-after.png', fullPage: true });
  console.log('after play, strip tiles:', await p.locator('.pf-strip .pf-tile').count(), '| turn', await p.getAttribute('#pfight', 'data-turn'));
  await b.close();
  process.exit(fail);
})();
