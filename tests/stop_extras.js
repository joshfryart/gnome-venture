const { chromium } = require('playwright');
(async () => {
  // node stop_extras.js BASE : the Extras tab of the Rest stop popover (needs tests/stop_extras_setup.php run first): every kind of button must work in place
  const base = process.argv[2]; let bad = 0; const fail = m => { console.log('FAIL ' + m); bad++; };
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] })); const p = await (await b.newContext({ viewport: { width: 390, height: 800 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(String(e)));
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  await p.goto(base + '/here.php'); await p.waitForTimeout(800);
  await p.evaluate(() => document.querySelectorAll('dialog[open]').forEach(d => d.close()));
  const hs = p.locator('a[data-pop]:has-text("Rest stop"), .hs:has-text("Rest stop")').first();
  if (!(await hs.count())) fail('no Rest stop hotspot on the Here page'); await hs.click({ force: true }); await p.waitForTimeout(1500);
  await p.click('.st-tab--extras'); await p.waitForTimeout(300);
  const rows = p.locator('.st-pan--extras button.choice');
  if ((await rows.count()) < 3) fail('Extras shows fewer than 3 buttons: ' + (await rows.count()));
  for (let i = 0; i < Math.min(3, await rows.count()); i++) {
    const r = p.locator('.st-pan--extras button.choice').nth(i); const label = (await r.textContent()).trim().slice(0, 40);
    await r.click(); await p.waitForTimeout(1500);
    const msg = await p.evaluate(() => { const m = document.querySelector('.st-slim > p.good, .st-slim > p.bad'); return m ? m.textContent.trim().slice(0, 90) : null; });
    const tab = await p.evaluate(() => document.querySelector('.st-tabs input:checked') && document.querySelector('.st-tabs input:checked').id);
    if (!msg || /Pick how to go about it/.test(msg)) fail('Extras button "' + label + '" did nothing (' + msg + ')');
    if (tab !== 'stt-extras') fail('the card left the Extras tab after "' + label + '"');
    if (tab !== 'stt-extras') await p.click('.st-tab--extras');
  }
  if (errs.length) fail('page errors: ' + errs.join(' | '));
  console.log(bad ? bad + ' FAILED' : 'extras buttons ok');
  await b.close(); process.exit(bad ? 1 : 0);
})();
