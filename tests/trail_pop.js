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
  await p.evaluate(() => sessionStorage.clear());   // the login may have landed here already: a reload does not announce the same line again
  await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' });
  await p.waitForSelector('.tilemap .tmpop', { timeout: 3000 }).catch(() => fail('nothing floats over the map'));
  const cam = await p.evaluate(() => { const m = document.querySelector('.tilemap[data-clamp]'); return m ? [+m.dataset.x0, +m.dataset.y0, +m.dataset.mw, +m.dataset.mh] : null; });
  if (!cam) fail('the Trail map has no camera clamp'); else if (cam[0] < -1 || cam[1] < -1 || cam[0] + 8 > cam[2] + 1 || cam[1] + 8 > cam[3] + 1) fail('the camera shows empty ground past the map edge: ' + cam);
  if (await p.locator('.trailtoast').count()) fail('the old fixed top box is back');
  if (await p.locator('.toasts').count() > 1) fail('two toast boxes at once');
  if (await p.locator('[data-gvtoast]').count()) fail('the hidden carrier was not consumed');
  const r = await p.evaluate(() => { const v = document.querySelector('.tilemap .tmview').getBoundingClientRect(), o = document.querySelector('.tilemap .tmpop'); if (!o) return null; const q = o.getBoundingClientRect(); return q.left >= v.left - 1 && q.right <= v.right + 1 && q.top >= v.top - 1; });
  if (r === false) fail('the pop-up spills outside the map');
  // walking swaps the page in place: whatever the reply says just happened must still show (toast + pop-up), not be left as a hidden carrier
  let carried = false; p.on('response', async r => { if (r.request().method() === 'POST' && /adventure\.php/.test(r.url())) { const t = await r.text().catch(() => ''); if (t.includes('data-gvtoast')) carried = true; } });
  const reach = p.locator('.tilemap .tmt.reach').first();
  if (await reach.count()) {
    await reach.click(); await p.waitForTimeout(1500);
    if (await p.locator('[data-gvtoast]').count()) fail('after walking, the carrier was left unread (no notification)');
    if (carried && !(await p.locator('.tilemap .tmpop, .toasts').count())) fail('walked: the reply had a message but nothing was shown');
    console.log('walk reply carried a message: ' + carried);
  } else fail('no tile to walk to');
  // the same journal line must not be announced twice (a step that adds none), a new one must
  await p.waitForTimeout(4500);
  const shown = async key => p.evaluate(k => { document.querySelectorAll('.tmpop').forEach(x => x.remove()); const c = document.createElement('div'); c.hidden = true; c.setAttribute('data-gvtoast', k); c.textContent = 'You find a test clover.'; document.body.appendChild(c); gvPageToasts(); return document.querySelectorAll('.tmpop').length; }, key);
  const k1 = await shown('9:5:111'), k2 = await shown('9:5:111'), k3 = await shown('9:6:222');
  if (k1 !== 1) fail('a new journal line is not announced (' + k1 + ')');
  if (k2 !== 0) fail('the same journal line is announced again (' + k2 + ')');
  if (k3 !== 1) fail('the next new line is not announced (' + k3 + ')');
  if (errs.length) fail('page errors: ' + errs.join(' | '));
  console.log(bad ? bad + ' FAILED' : 'trail pop ok'); await b.close(); process.exit(bad ? 1 : 0);
})();
