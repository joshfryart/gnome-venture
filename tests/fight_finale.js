// node fight_finale.js BASE [SHOTDIR] : kill the foe in a browser and watch the end scene (needs a 1-hp foe set up by fight_scene_trail.sh)
const { chromium } = require('playwright');
// the fight menu is a command column: open Fight, tap Attack once to read it and again to do it (a plain button list still works)
async function doAttack(p) {
  if (await p.locator('.fsc-top[data-open=fight]').count()) {
    await p.click('.fsc-top[data-open=fight]');
    await p.click('.fsc-sub[data-for=fight] form:has(input[value=attack]) button');
    await p.click('.fsc-sub[data-for=fight] form:has(input[value=attack]) button');
    return;
  }
  await p.click('.fightbtns form:has(input[value=attack]) button');
}

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
    await doAttack(p);
    held = await p.waitForFunction(() => document.body.classList.contains('fs-hold'), null, { timeout: 7000 }).then(() => true, () => false);
    if (!held) await p.waitForFunction(() => !document.querySelector('.fsdock.fs-wait'), null, { timeout: 8000 }).catch(() => {});
  }
  if (!held) fail('no end scene after the killing blow');
  else {
    const mapLocked = await p.evaluate(() => getComputedStyle(document.querySelector('.tmgrid')).pointerEvents === 'none'); if (!mapLocked) fail('map not locked during the end scene');
    const marker = await p.evaluate(() => { const m = document.querySelector('.tilemap .tmme'); return m ? getComputedStyle(m).display : 'none'; }); if (marker !== 'none') fail('the map marker (red-hat gnome) shows behind the stage gnome');
    let seenDrop = false, maxR = 0, maxXY = 0;
    await p.evaluate(() => { window.__drops = 0; new MutationObserver(ms => ms.forEach(m => m.addedNodes.forEach(n => { if (n.classList && n.classList.contains('fe-drop')) window.__drops++; }))).observe(document.body, { childList: true, subtree: true }); });
    if (process.env.SKIPTEST !== '0') {   // tap the stage to skip (speed x40): the hat must not whip about
      await p.waitForTimeout(1800); await p.click('#fightscene', { force: true, position: { x: 150, y: 60 } }).catch(() => {});
      for (let k = 0; k < 20; k++) { await p.waitForTimeout(100); const h = await p.evaluate(() => { const a = window.feScene && window.feScene.acts.me && window.feScene.acts.me.hat; return a ? [a.r, a.x, a.y, a.tr] : null; }); if (h && process.env.HATLOG) console.log('s', k, h.map(Math.round).join(','));
 if (h) { maxR = Math.max(maxR, Math.abs(h[0]), Math.abs(h[3])); maxXY = Math.max(maxXY, Math.abs(h[1]), Math.abs(h[2])); } }
      if (process.env.HATLOG) console.log('skip hat max r/tip', Math.round(maxR), 'max x/y', Math.round(maxXY));
      if (maxR > 20 || maxXY > 4) fail('the hat whips about while skipping (max rotation ' + Math.round(maxR) + ', offset ' + Math.round(maxXY) + ')');
    }
    for (let i = 0; i < (process.env.FRAMES ? 40 : 14); i++) {
      await p.waitForTimeout(process.env.FRAMES ? 150 : 450);
      if (process.env.FRAMES) { await p.evaluate(() => { document.querySelector('.tmwrap').scrollIntoView(); window.scrollBy(0, -70); }); await p.screenshot({ path: shot + '/frm-' + String(i).padStart(2, '0') + '.png', clip: { x: 60, y: 190, width: 270, height: 220 } }); }
      if (await p.evaluate(() => !!document.querySelector('.fe-drop'))) seenDrop = true;
      if (process.env.DOMLOG && (i === 1 || i === 9)) console.log('dom', i, JSON.stringify(await p.evaluate(() => [...document.querySelectorAll('.tmstage image, .tmstage img, .tmstage use, .tmstage [class*=hat], .tmstage [class*=me], .tmstage [class*=gnome]')].filter(e => !e.closest('.fe-actors')).map(e => [e.tagName, String(e.getAttribute('class')), (e.getAttribute('href') || e.getAttribute('src') || '').split('/').pop().slice(0, 40), Math.round(e.getBoundingClientRect().x), Math.round(e.getBoundingClientRect().y), Math.round(e.getBoundingClientRect().width)]).slice(0, 14))));
      if (process.env.HATLOG) console.log('hat', i, JSON.stringify(await p.evaluate(() => { const h = window.feScene && window.feScene.acts.me && window.feScene.acts.me.hat; return h ? [h.mode, Math.round(h.x), Math.round(h.y), Math.round(h.r), h.rest] : null; })));
      if (shot && [3, 5, 7, 9].includes(i)) { await p.evaluate(() => { document.querySelector('.tmwrap').scrollIntoView(); window.scrollBy(0, -70); }); await p.screenshot({ path: shot + '/fin-' + i + '.png' }); }
    }
    if (!seenDrop && !(await p.evaluate(() => window.__drops))) fail('no XP/loot drop shown');
    await p.waitForFunction(() => !document.body.classList.contains('fs-hold'), null, { timeout: 15000 }).catch(() => fail('map never unlocked'));
    const open = await p.evaluate(() => getComputedStyle(document.querySelector('.tmgrid')).pointerEvents !== 'none'); if (!open) fail('map still locked after the end scene');
  }
  if (errs.length) fail('page errors: ' + errs.join(' | '));
  console.log(bad ? 'finale: ' + bad + ' problem(s)' : 'finale ok');
  await b.close(); process.exit(bad ? 1 : 0);
})();
