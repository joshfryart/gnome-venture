// node trail_pop.js BASE : on a Trail tile page, what just happened floats over the map and joins the one toast box (no second box over the message bar)
const { chromium } = require('playwright');
(async () => {
  const base = process.argv[2];
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const p = await (await b.newContext({ viewport: { width: 390, height: 760 } })).newPage();
  let bad = 0; const fail = m => { console.log('FAIL ' + m); bad++; };
  const errs = []; p.on('pageerror', e => errs.push(String(e)));
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' });
  await p.waitForSelector('.tilemap .tmpop', { timeout: 3000 }).catch(() => fail('nothing floats over the map'));
  if (await p.locator('.trailtoast').count()) fail('the old fixed top box is back');
  if (await p.locator('.toasts').count() > 1) fail('two toast boxes at once');
  if (await p.locator('[data-gvtoast]').count()) fail('the hidden carrier was not consumed');
  const r = await p.evaluate(() => { const v = document.querySelector('.tilemap .tmview').getBoundingClientRect(), o = document.querySelector('.tilemap .tmpop'); if (!o) return null; const q = o.getBoundingClientRect(); return q.left >= v.left - 1 && q.right <= v.right + 1 && q.top >= v.top - 1; });
  if (r === false) fail('the pop-up spills outside the map');
  if (errs.length) fail('page errors: ' + errs.join(' | '));
  console.log(bad ? bad + ' FAILED' : 'trail pop ok'); await b.close(); process.exit(bad ? 1 : 0);
})();
