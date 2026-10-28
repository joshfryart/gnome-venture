// v2.0.87: README screenshots from a running test copy (tests/readme_shots.sh). node tests/readme_shots.js BASE_URL OUT_DIR
// Desktop 1400x900 (light) and phone 412 (dark, 2x) of the seeded demo gnome: Today, Garden, World, plus the new Jigsaw library and a Jigsaw table.
const { chromium } = require('playwright');
const [BASE, OUT] = process.argv.slice(2);
const login = async p => {
  await p.goto(BASE + '/login.php');
  await p.fill('[name=username]', 'sprout'); await p.fill('[name=password]', 'TestPass123!');
  await p.click('main button.btn'); await p.waitForLoadState();
};
const theme = async (p, th) => {
  if ((await p.getAttribute('html', 'data-theme')) !== th) { await p.evaluate(t => document.querySelector('button.th-to-' + t).click(), th); await p.waitForTimeout(1200); }
};
const shot = async (p, url, file, o = {}) => {
  await p.goto(BASE + '/' + url); await p.waitForTimeout(o.wait || 1000);
  await p.addStyleTag({ content: '.toasts,.flash{display:none!important}' });
  if (o.before) await o.before(p);
  await p.screenshot({ path: OUT + '/' + file, fullPage: false });
};
(async () => {
  const b = await chromium.launch();
  const desk = await b.newContext({ viewport: { width: 1400, height: 900 }, bypassCSP: true });
  let p = await desk.newPage(); await login(p); await theme(p, 'light');
  await shot(p, 'index.php', 'desktop-today.png');
  await shot(p, 'garden.php', 'desktop-garden.png');
  await shot(p, 'world.php', 'desktop-world.png');
  await shot(p, 'jigsaw.php', 'desktop-jigsaw.png', { wait: 1500 });
  await shot(p, 'jigsaw.php#jig-maplewold-24', 'desktop-jigsaw-play.png', { wait: 2500, before: async q => { await q.waitForSelector('#field .piece', { timeout: 15000 }); await q.waitForTimeout(500); } });
  await desk.close();
  const ph = await b.newContext({ viewport: { width: 412, height: 915 }, deviceScaleFactor: 2, bypassCSP: true });
  p = await ph.newPage(); await login(p); await theme(p, 'dark');
  await shot(p, 'index.php', 'phone-today.png');
  await shot(p, 'garden.php', 'phone-garden.png');
  await shot(p, 'world.php', 'phone-world.png');
  await shot(p, 'jigsaw.php', 'phone-jigsaw.png', { wait: 1500 });
  await ph.close();
  await b.close();
})().catch(e => { console.error('readme shots failed:', e.message); process.exit(1); });
