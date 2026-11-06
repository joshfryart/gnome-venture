// node fight_scene.js BASE [SHOTDIR] : the fight page in a browser (needs the fight set up by fight_scene.sh)
const { chromium } = require('playwright');
// the fight menu is a command column: open Fight, tap Attack once to read it and again to do it (a plain button list still works)
async function doAttack(p, shot) {
  if (await p.locator('.fsc-top[data-open=fight]').count()) {
    const snap = async n => { if (shot) { await p.evaluate(() => { const h = document.querySelector('.fsc'); if (h) h.scrollIntoView({ block: 'end' }); }); await p.waitForTimeout(250); await p.screenshot({ path: shot + '/menu-' + n + '.png' }); } };
    await snap('1-closed');
    await p.click('.fsc-top[data-open=fight]'); await snap('2-fight-open');
    await p.click('.fsc-sub[data-for=fight] form:has(input[value=attack]) button'); await snap('3-attack-read');
    await p.click('.fsc-sub[data-for=fight] form:has(input[value=attack]) button');
    return;
  }
  await p.click('.fightbtns form:has(input[value=attack]) button');
}

(async () => {
  const [base, shot] = [process.argv[2], process.argv[3]];
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const p = await (await b.newContext({ viewport: { width: 390, height: 800 } })).newPage();
  const errs = []; let bad = 0; p.on('console', m => { if (m.type() === 'warning' || m.type() === 'error') errs.push(m.text()); });
  p.on('pageerror', e => errs.push(String(e)));
  const fail = m => { console.log('FAIL ' + m); bad++; };
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' });
  const noTour = () => p.evaluate(() => { [...document.querySelectorAll('body *')].filter(e => getComputedStyle(e).position === 'fixed' && /Wren/.test(e.textContent) && e.getBoundingClientRect().height < 400 && !e.querySelector('main')).forEach(e => { e.style.display = 'none'; }); });   // the new-player tour card floats over the bottom of the map
  try { await p.waitForSelector('#fightscene .fe-view', { timeout: 4000 }); } catch (e) { fail('engine did not mount'); }
  await noTour();
  const mk = await p.evaluate(() => { const m = document.querySelector('.tilemap.tm-fight .tmme'); return m ? getComputedStyle(m).display : 'none'; }); if (mk !== 'none') fail('the map marker shows behind the stage gnome');
  try { await p.waitForFunction(() => !document.querySelector('.fightbtns.fs-wait, .fsdock.fs-wait'), null, { timeout: 8000 }); } catch (e) { fail('buttons stay locked after the enter'); }
  if (shot) console.log('HB', JSON.stringify(await p.evaluate(() => [...document.querySelectorAll('.fe-hb')].map(e => { const r = e.getBoundingClientRect(), h = document.getElementById('fightscene').getBoundingClientRect(); return [e.className, Math.round(r.x), Math.round(r.y), Math.round(r.width), Math.round(r.height), 'host', Math.round(h.x), Math.round(h.y), Math.round(h.width), Math.round(h.height), getComputedStyle(e).display, getComputedStyle(e).opacity]; }))));
  if (shot) await p.evaluate(() => { const h = document.getElementById('fightscene'); if (h) h.scrollIntoView({ block: 'center' }); }); await p.waitForTimeout(300); await p.screenshot({ path: shot + '/fs-enter.png' });

  await doAttack(p, shot);
  await p.waitForFunction(() => { const h = document.getElementById('fightscene'); try { return JSON.parse(h.dataset.fight).events.length > 0; } catch (e) { return false; } }, null, { timeout: 15000 }).catch(() => fail('no events after the attack click'));
  try { await p.waitForSelector('#fightscene .fe-view', { timeout: 20000 }); } catch (e) { fail('engine did not mount after attack: ' + errs.join('|') + ' ' + await p.evaluate(() => typeof FightEngine + ' ' + document.readyState)); }
  const locked = await p.evaluate(() => !!document.querySelector('.fightbtns.fs-wait, .fsdock.fs-wait')); if (!locked) fail('buttons not locked while events play');
  await p.waitForSelector('#fightscene .fe-dmg', { timeout: 6000 }).catch(() => fail('no damage number popped'));
  if (shot) await p.evaluate(() => { const h = document.getElementById('fightscene'); if (h) h.scrollIntoView({ block: 'center' }); }); await p.screenshot({ path: shot + '/fs-attack.png' });
  try { await p.waitForFunction(() => !document.querySelector('.fightbtns.fs-wait, .fsdock.fs-wait'), null, { timeout: 12000 }); } catch (e) { fail('buttons stay locked after the events'); }
  const hp = await p.evaluate(() => { const bars = [...document.querySelectorAll('#fightscene .fe-hud *')]; return bars.length; });
  if (errs.length) fail('page errors: ' + errs.join(' | '));
  console.log(bad ? 'browser: ' + bad + ' problem(s)' : 'browser ok (' + hp + ' hud nodes)');
  await b.close(); process.exit(bad ? 1 : 0);
})();
