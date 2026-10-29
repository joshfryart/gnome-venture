// node advshot.js BASE OUTDIR MODE : screenshots of adventure.php, desktop and phone
const { chromium } = require('playwright');
(async () => {
  const [base, out, mode] = process.argv.slice(2);
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  for (const [name, vp] of [['desktop', { width: 1280, height: 800 }], ['phone', { width: 390, height: 800 }]]) {
    const c = await b.newContext({ viewport: vp });
    const p = await c.newPage();
    const errs = [];
    p.on('pageerror', e => errs.push(String(e)));
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' });
    await p.waitForTimeout(500);
    if (process.env.OPEN) { await p.evaluate(() => document.querySelectorAll('details.wfold').forEach(d => { d.open = true; })); await p.waitForTimeout(200); }
    await p.screenshot({ path: `${out}/adv-${name}-${mode}.png`, fullPage: !!process.env.OPEN });
    console.log(name, mode, 'js errors:', errs.length ? errs.join(' | ') : 'none');
    await c.close();
  }
  await b.close();
})();
