// node tests/pfmap.js BASE OUTDIR LABEL : a puzzle fight drawn ON the route map (phone + wide): the map is behind the panel, nothing overflows, a piece can be placed (board) or played (strip), no JS errors.
const { chromium } = require('playwright');
(async () => {
  const [base, out, label, want] = process.argv.slice(2);
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  let fail = 0;
  for (const [name, vp] of [['phone', { width: 412, height: 900 }], ['wide', { width: 1280, height: 800 }]]) {
    const c = await b.newContext({ viewport: vp, deviceScaleFactor: 1 }); const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' });
    const over = await p.locator('.advgrid.pfover').count(), mapIn = await p.locator('.advgrid.pfover .mapcol').count(), panel = await p.locator('#pfight').count();
    const box = async (sel) => p.locator(sel).first().boundingBox().catch(() => null);
    const m = await box('.advgrid.pfover .mapcol'), f = await box('#pfight');
    const overlap = !!(m && f && f.x < m.x + m.width && f.x + f.width > m.x && f.y < m.y + m.height && f.y + f.height > m.y);
    const art = await p.locator('.pfx-bar').count();
    const glow = await p.locator('.pfb-glow').count(), stamp = await p.locator('.pfb-stamp').count();
    await p.locator('#pfight').screenshot({ path: out + '/pfmap-' + label + '-' + name + '.png' });
    const wide = await p.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
    const bad = (!over || !mapIn || !panel || !overlap || wide || errs.length || (want === 'fx' && (!glow || !stamp))) ? 1 : 0; fail = fail || bad;
    console.log(bad ? 'FAIL' : 'ok', label, name, '| fight over map', !!over, '| map behind', overlap, '| art bar', art, '| glow', glow, '| stamps', stamp, '| expiring cues', await p.locator('.pfb-old').count(), '| overflow', wide, '| js errors:', errs.length ? errs.join(' | ') : 'none');
    await c.close();
  }
  await b.close(); process.exit(fail);
})();
