// node tests/closet_page.js BASE : the Closet tab's picker in a real browser, called by tests/wear_equip.sh (skipped without playwright).
// Player sprout: slim home on, wearables on, owns Work Gloves and a Wayfarer's Hat, wears nothing.
// With script a pill opens its picker as a dialog in the page and Wear / Take off change the page without a full load; without script the pill is a link
// (?wear=SLOT, the picker drawn open in the page) and the buttons are plain forms. SHOTS=/some/dir also writes screenshots. Prints "  ok   ..." / "  FAIL ..." lines.
const { chromium } = require('playwright');
const B = process.argv[2];
const out = []; const ok = (name, got, want) => out.push((got === want ? '  ok   ' : '  FAIL ') + name + (got === want ? '' : " (got '" + got + "', want '" + want + "')"));
const login = async p => {
  await p.goto(B + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
};
(async () => {
  const br = await chromium.launch({ args: ['--no-sandbox'] }).catch(() => chromium.launch());
  const c = await br.newContext({ viewport: { width: 390, height: 844 } }); const p = await c.newPage(); const errs = [];
  p.on('pageerror', e => errs.push(String(e)));
  p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
  await login(p); await p.goto(B + '/gnome.php?tab=closet');
  await p.evaluate(() => { window.__stay = 1; });   // lost on a full page load
  const stay = () => p.evaluate(() => window.__stay === 1);
  const modal = id => p.evaluate(i => { const d = document.getElementById(i); return !!d && d.open && d.matches(':modal'); }, id);
  const pill = slot => p.locator('.clpill a[data-hdlg="clpick-' + slot + '"]');
  const pillText = slot => p.evaluate(s => { const a = document.querySelector('.clpill a[data-hdlg="clpick-' + s + '"] b'); return a ? a.textContent.trim() : '(no pill)'; }, slot);
  ok('seven pills, each with its picker dialog in the page', await p.evaluate(() => [...document.querySelectorAll('.clpill a[data-hdlg]')].filter(a => { const d = document.getElementById(a.getAttribute('data-hdlg')); return d && d.tagName === 'DIALOG' && !d.open; }).length), 7);
  ok('the Hands pill says nothing is on', await pillText('hands'), 'Nothing on');

  // open: a dialog in the page, no load
  await pill('hands').click(); await p.waitForTimeout(200);
  ok('a tap on the Hands pill opens its picker as a dialog', await modal('clpick-hands'), true);
  ok('...with no page load and the address unchanged', (await stay()) && await p.evaluate(() => location.search === '?tab=closet'), true);
  ok('...it lists the Work Gloves with a Wear button', await p.locator('#clpick-hands form:has(input[name=item][value="work-gloves"]) button').innerText(), 'Wear');
  ok('...inside the screen', await p.evaluate(() => { const r = document.getElementById('clpick-hands').getBoundingClientRect(); return r.left >= 0 && r.right <= window.innerWidth && r.top >= 0 && r.bottom <= window.innerHeight && r.width > 200; }), true);
  ok('...the Wear button is at least 40 px high', await p.evaluate(() => document.querySelector('#clpick-hands .wbtn button').getBoundingClientRect().height >= 40), true);
  if (process.env.SHOTS) await p.screenshot({ path: process.env.SHOTS + '/closet-picker.png' });
  await p.keyboard.press('Escape'); await p.waitForTimeout(150);
  ok('Escape closes it', await modal('clpick-hands'), false);
  await pill('hands').click(); await p.waitForTimeout(150);
  await p.locator('#clpick-hands [data-hdlg-close]').click(); await p.waitForTimeout(150);
  ok('Done closes it, no page load', (await modal('clpick-hands')) === false && await stay(), true);
  await pill('hat').click(); await p.waitForTimeout(150);
  ok('the Hat pill opens the Hat picker', await modal('clpick-hat'), true);
  await p.mouse.click(5, 5); await p.waitForTimeout(150);
  ok('a tap on the dimmed page closes it', await modal('clpick-hat'), false);

  // wear: the page changes in place
  await pill('hands').click(); await p.waitForTimeout(150);
  await p.locator('#clpick-hands form:has(input[name=item][value="work-gloves"]) button').click();
  await p.waitForFunction(() => { const b = document.querySelector('.clpill a[data-hdlg="clpick-hands"] b'); return b && b.textContent.trim() !== 'Nothing on'; }, null, { timeout: 8000 }).catch(() => {});
  ok('Wear: the pill now names the Work Gloves', await pillText('hands'), 'Work Gloves');
  ok('...without a full page load', await stay(), true);
  ok('...the picker is closed and nothing is left open over the page', await p.evaluate(() => document.querySelectorAll('dialog[open]').length), 0);
  ok('...the address is the Closet tab', await p.evaluate(() => location.search), '?tab=closet');
  ok('...the page says so', await p.evaluate(() => /put on the Work Gloves/.test(document.querySelector('main').textContent)), true);
  if (process.env.SHOTS) await p.screenshot({ path: process.env.SHOTS + '/closet-worn.png' });

  // take off: the same way
  await pill('hands').click(); await p.waitForTimeout(150);
  ok('opened again: the worn item offers Take off', await p.locator('#clpick-hands form:has(input[name=item][value="work-gloves"]) button').innerText(), 'Take off');
  await p.locator('#clpick-hands form:has(input[name=item][value="work-gloves"]) button').click();
  await p.waitForFunction(() => { const b = document.querySelector('.clpill a[data-hdlg="clpick-hands"] b'); return b && b.textContent.trim() === 'Nothing on'; }, null, { timeout: 8000 }).catch(() => {});
  ok('Take off: the pill is empty again, no full page load', (await pillText('hands')) === 'Nothing on' && await stay(), true);
  ok('the page does not scroll sideways', await p.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth), true);
  ok('no script errors', errs.join(' | '), '');
  await c.close();

  // without script: links and forms
  const c2 = await br.newContext({ viewport: { width: 390, height: 844 }, javaScriptEnabled: false }); const q = await c2.newPage();
  await login(q); await q.goto(B + '/gnome.php?tab=closet');
  ok('no script: no picker shows until a pill is followed', await q.locator('dialog.clpick[open]').count(), 0);
  await Promise.all([q.waitForNavigation(), q.locator('.clpill a[data-hdlg="clpick-hands"]').click()]);
  ok('no script: the pill is a link to ?wear=hands', new URL(q.url()).search, '?tab=closet&wear=hands');
  ok('...the Hands picker is drawn open in the page', await q.locator('#clpick-hands[open]').isVisible(), true);
  ok('...and only that one', await q.locator('dialog.clpick[open]').count(), 1);
  if (process.env.SHOTS) await q.screenshot({ path: process.env.SHOTS + '/closet-noscript.png' });
  await Promise.all([q.waitForNavigation(), q.locator('#clpick-hands form:has(input[name=item][value="work-gloves"]) button').click()]);
  ok('...Wear is a plain form: back on the Closet tab with the gloves on', new URL(q.url()).search + ' ' + (await q.locator('.clpill a[data-hdlg="clpick-hands"] b').innerText()), '?tab=closet Work Gloves');
  await q.goto(B + '/gnome.php?tab=closet&wear=hands');
  await Promise.all([q.waitForNavigation(), q.locator('#clpick-hands form:has(input[name=item][value="work-gloves"]) button').click()]);
  ok('...Take off too', await q.locator('.clpill a[data-hdlg="clpick-hands"] b').innerText(), 'Nothing on');
  await br.close();
  console.log(out.join('\n'));
})().catch(e => { console.log(out.join('\n')); console.log('  FAIL closet_page.js crashed: ' + e.message.split('\n')[0]); process.exit(1); });
