// node tests/tea_page.js BASE : the Hovel tea kettle in a real browser, called by tests/tea.sh (skipped without playwright).
// Player sprout holds tea, mint, cardamom, cinnamon, ginger, lemon (3 each), tea_open = everyone, home_slim on, no cup yet today.
// SHOTS=/some/dir also writes screenshots (390 x 844). Prints "  ok   ..." / "  FAIL ..." lines.
const { chromium } = require('playwright');
const B = process.argv[2];
const out = []; const ok = (name, got, want) => out.push((got === want ? '  ok   ' : '  FAIL ') + name + (got === want ? '' : " (got '" + got + "', want '" + want + "')"));
(async () => {
  const br = await chromium.launch({ args: ['--no-sandbox'] }).catch(() => chromium.launch());
  const c = await br.newContext({ viewport: { width: 390, height: 844 } }); const p = await c.newPage(); const errs = [];
  p.on('pageerror', e => errs.push(String(e)));
  p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
  await p.goto(B + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]); await p.goto(B + '/gnome.php');
  const hit = p.locator('.hs-crop a.hd-kettle .hd-hit');
  const bb = await hit.boundingBox();
  ok('the kettle tap area is at least 44 px each way on a phone (' + (bb ? Math.round(bb.width) + ' x ' + Math.round(bb.height) : 'none') + ')', !!bb && bb.width >= 44 && bb.height >= 44, true);
  ok('the popover is closed', await p.evaluate(() => document.getElementById('htea').open), false);
  await p.mouse.click(bb.x + bb.width / 2, bb.y + bb.height / 2);
  await p.waitForTimeout(200);
  ok('a tap on the kettle opens the popover as a modal dialog (no page load)', await p.evaluate(() => { const d = document.getElementById('htea'); return d.open && d.matches(':modal') && location.search === ''; }), true);
  ok('the no-script button is hidden', await p.locator('#htea .tea-nojs').isVisible(), false);
  const tick = s => p.locator('#htea [data-tea-ing="' + s + '"] input[type=checkbox]').check();
  const outText = () => p.locator('#htea [data-tea-out]').innerText();
  await tick('tea');
  ok('the first thing that steeps becomes the base', await p.locator('#htea [data-tea-ing="tea"] input[type=radio]').isChecked(), true);
  ok('...and its card is marked', await p.locator('#htea [data-tea-ing="tea"]').getAttribute('class'), 'tea-card on base');
  ok('the live preview: a House Blend on the tin kettle', (await outText()).replace(/\s+/g, ' ').includes('House Blend Lore +1 until you sleep Lore: steep 4 × 4 ÷ 8 = 2, cap 1'), true);
  await tick('cardamom'); await tick('cinnamon'); await tick('ginger');
  const live = (await outText()).replace(/\s+/g, ' ');
  ok('four parts: the preview names the tea', live.includes('Masala Chai named tea · +1 steep Lore +1 Nimble +1 until you sleep'), true);
  await p.locator('#htea [data-tea-ing="mint"] input[type=checkbox]').click();
  ok('a fifth part does not go in', await p.locator('#htea [data-tea-ing="mint"] input[type=checkbox]').isChecked(), false);
  ok('...and a note says why', (await p.locator('#htea [data-tea-note]').innerText()).includes('4 components at most'), true);
  await p.locator('#htea [data-tea-ing="ginger"] input[type=radio]').check();
  ok('another base can be picked: the main stat follows it', (await outText()).replace(/\s+/g, ' ').includes('Masala Chai named tea · +1 steep Nimble +1 Lore +1'), true);
  await p.locator('#htea [data-tea-ing="tea"] input[type=radio]').check();
  ok('the live preview is the cup the server draws for the same picks', await p.evaluate(async () => {
    const norm = s => s.replace(/\s+/g, ' ').trim();
    const mine = norm(document.querySelector('#htea [data-tea-out]').textContent);
    const html = await (await fetch('gnome.php?tea=1&base=tea&c=ginger,cardamom,cinnamon', { credentials: 'same-origin' })).text();
    const doc = new DOMParser().parseFromString(html, 'text/html');
    return mine === norm(doc.querySelector('#htea [data-tea-out]').textContent);
  }), true);
  if (process.env.SHOTS) await p.screenshot({ path: process.env.SHOTS + '/tea-popover.png' });
  await Promise.all([p.waitForURL(/tea=1/), p.locator('#htea [data-tea-brew]').click()]);
  await p.waitForTimeout(300);
  ok('Brew: back on Today with the cup', (await p.locator('#htea .tea-today').innerText()).includes('Today’s cup: Masala Chai'), true);
  ok('...the journal has its stamp', (await p.locator('#htea .tea-journal summary').innerText()).includes('1 of 20 found'), true);
  if (process.env.SHOTS) await p.screenshot({ path: process.env.SHOTS + '/tea-after.png', fullPage: true });
  // a second cup: the game's own confirm dialog, Cancel keeps the first cup
  await p.locator('.hs-teal a').click(); await p.waitForTimeout(200);
  ok('the plain link on Today opens the same popover', await p.evaluate(() => document.getElementById('htea').matches(':modal')), true);
  await tick('mint');
  await p.locator('#htea [data-tea-brew]').click(); await p.waitForTimeout(200);
  ok('a second brew asks first', (await p.locator('dialog.gvask .gvmsg').innerText()).includes('This pours out your Masala Chai'), true);
  await p.locator('dialog.gvask .btn.alt').click(); await p.waitForTimeout(200);
  ok('Cancel: nothing is brewed', await p.locator('#htea input[name=confirm]').isChecked(), false);
  await p.locator('#htea [data-tea-brew]').click(); await p.waitForTimeout(200);
  await Promise.all([p.waitForURL(/tea=1/), p.locator('dialog.gvask .gvbtns .btn:not(.alt)').click()]);
  await p.waitForTimeout(300);
  ok('OK: the new cup replaces the first', (await p.locator('#htea .tea-today').innerText()).includes('Today’s cup: Mint Tea'), true);
  ok('no script errors', errs.join(' | '), '');
  console.log(out.join('\n'));
  await br.close();
  process.exit(out.some(l => l.startsWith('  FAIL')) ? 1 : 0);
})().catch(e => { console.log(out.join('\n')); console.log('  FAIL tea_page.js crashed: ' + String(e).split('\n')[0]); process.exit(1); });
