// node fight_finale.js BASE [SHOTDIR] : kill the foe in a browser and watch the end scene (needs a 1-hp foe set up by fight_scene_trail.sh)
const { chromium } = require('playwright');
(async () => {
  const [base, shot] = [process.argv[2], process.argv[3]];
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const p = await (await b.newContext({ viewport: { width: 390, height: 760 }, deviceScaleFactor: 2 })).newPage();
  const errs = []; let bad = 0; p.on('pageerror', e => errs.push(String(e)));
  const fail = m => { console.log('FAIL ' + m); bad++; };
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' });
  await p.waitForSelector('#fightscene .fe-view', { timeout: 6000 }).catch(() => fail('stage did not mount'));
  await p.evaluate(() => { [...document.querySelectorAll('body *')].filter(e => getComputedStyle(e).position === 'fixed' && /Wren/.test(e.textContent) && e.getBoundingClientRect().height < 400 && !e.querySelector('main')).forEach(e => { e.style.display = 'none'; }); });
  await p.waitForFunction(() => !document.querySelector('.fsdock.fs-wait'), null, { timeout: 8000 }).catch(() => fail('dock stays locked'));
  let held = false;
  for (let i = 0; i < 6 && !held; i++) {   // a miss just means another swing
    await p.click('.fsdock form:has(input[value=attack]) button');
    held = await p.waitForFunction(() => document.body.classList.contains('fs-hold'), null, { timeout: 7000 }).then(() => true, () => false);
    if (!held) await p.waitForFunction(() => !document.querySelector('.fsdock.fs-wait'), null, { timeout: 8000 }).catch(() => {});
  }
  if (!held) fail('no end scene after the killing blow');
  else {
    const mapLocked = await p.evaluate(() => getComputedStyle(document.querySelector('.tmgrid')).pointerEvents === 'none'); if (!mapLocked) fail('map not locked during the end scene');
    let seenDrop = false;
    for (let i = 0; i < 14; i++) {
      await p.waitForTimeout(450);
      if (await p.evaluate(() => !!document.querySelector('.fe-drop'))) seenDrop = true;
      if (shot && [3, 5, 7, 9].includes(i)) { await p.evaluate(() => { document.querySelector('.tmwrap').scrollIntoView(); window.scrollBy(0, -70); }); await p.screenshot({ path: shot + '/fin-' + i + '.png' }); }
    }
    if (!seenDrop) fail('no XP/loot drop shown');
    await p.waitForFunction(() => !document.body.classList.contains('fs-hold'), null, { timeout: 15000 }).catch(() => fail('map never unlocked'));
    const open = await p.evaluate(() => getComputedStyle(document.querySelector('.tmgrid')).pointerEvents !== 'none'); if (!open) fail('map still locked after the end scene');
  }
  if (errs.length) fail('page errors: ' + errs.join(' | '));
  console.log(bad ? 'finale: ' + bad + ' problem(s)' : 'finale ok');
  await b.close(); process.exit(bad ? 1 : 0);
})();
