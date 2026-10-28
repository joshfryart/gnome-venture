// v2.0.73: capture the front-page tour screenshots from a running test copy. Usage: node tests/shots.js BASE_URL OUT_DIR
// Phone 412 px wide at 2x, logged in as the seeded demo account, dark and light. Writes shot-<stop>.png (light) and shot-<stop>-dark.png (raw: tests/shots.sh quantises them).
const { chromium } = require('playwright');
const BASE = process.argv[2], OUT = process.argv[3];
const STOPS = [['garden', 'garden.php', 70], ['satchel', 'inventory.php', 110], ['world', 'world.php', 0], ['town', 'town.php', 0], ['games', 'games.php', 40], ['almanac', 'book.php', 0]];
const H = 560;
(async () => {
  const b = await chromium.launch();
  for (const th of ['dark', 'light']) {
    const c = await b.newContext({ viewport: { width: 412, height: 900 }, deviceScaleFactor: 2, bypassCSP: true });
    const p = await c.newPage();
    await p.goto(BASE + '/login.php');
    await p.fill('[name=username]', 'sprout'); await p.fill('[name=password]', 'TestPass123!');
    await p.click('main button.btn'); await p.waitForLoadState();
    if ((await p.getAttribute('html', 'data-theme')) !== th) {
      await p.evaluate(t => document.querySelector('button.th-to-' + t).click(), th); await p.waitForTimeout(1500);
    }
    for (const [name, url, y] of STOPS) {
      await p.goto(BASE + '/' + url); await p.waitForTimeout(900);
      await p.addStyleTag({ content: '.toasts,.flash{display:none!important}' });
      await p.evaluate(yy => window.scrollTo(0, yy), y); await p.waitForTimeout(300);
      await p.screenshot({ path: OUT + '/raw-' + name + (th === 'dark' ? '-dark' : '') + '.png', clip: { x: 0, y: 0, width: 412, height: H } });
    }
    await c.close();
  }
  await b.close();
})().catch(e => { console.error('shots failed:', e.message); process.exit(1); });
