// node catfish_room2.js BASE : the room2 canvas paints the Rod upgrades (called by tests/catfish.sh with catfish_room2 on, the room2 art installed; skipped without playwright).
// SQL_UPS (with {UPS} for the upgrades JSON) and DBFILE set the home between loads. Prints "ok   ..." / "FAIL ..." lines. SHOTS=/dir also writes the canvas of each load.
// Before 2.8.73 the canvas ignored Longer string, Springy rod, Rod motor and Double rod (the old stage showed them as CSS classes), so a buy changed nothing on screen.
const { chromium } = require('playwright'); const { execFileSync } = require('child_process');
const B = process.argv[2];
const out = []; const ok = (name, got, want) => out.push((got === want ? 'ok   ' : 'FAIL ') + name + (got === want ? '' : " (got '" + got + "', want '" + want + "')"));
const sql = (ups) => execFileSync('php', ['-r', '$p=new PDO("sqlite:" . $argv[1]); $p->exec($argv[2]);', process.env.DBFILE, process.env.SQL_UPS.replace('{UPS}', ups).replace('{NOW}', String(Math.floor(Date.now() / 1000)))]);
// the room is drawn darker at dusk and night: pin the browser clock to midday so every load draws the same plates
const off = 12 - new Date().getUTCHours(), TZ = off === 0 ? 'UTC' : 'Etc/GMT' + (off > 0 ? '-' : '+') + Math.abs(off);
(async () => {
  const br = await chromium.launch({ args: ['--no-sandbox'] }).catch(() => chromium.launch());
  const errs = [];
  async function load(ups, motion) {
    sql(ups);
    const c = await br.newContext({ viewport: { width: 844, height: 390 }, reducedMotion: motion ? 'no-preference' : 'reduce', timezoneId: TZ }); const p = await c.newPage();
    p.on('pageerror', e => errs.push(String(e)));
    await p.goto(B + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
    await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    await p.goto(B + '/catfish.php');
    await p.waitForFunction(() => window.CFRoom && window.CFRoom.state().M && window.CFRoom.state().pending === 0, null, { timeout: 15000 }).catch(() => {});
    await p.waitForTimeout(600);
    return { c, p };
  }
  const box = (p, x0, y0, x1, y1) => p.evaluate(([x0, y0, x1, y1]) => Array.from(document.querySelector('canvas.cfr2cv').getContext('2d').getImageData(x0, y0, x1 - x0, y1 - y0).data).join(','), [x0, y0, x1, y1]);
  const fishY = (p) => p.evaluate(() => (window.CFRoom.state().fish || []).map(f => f[1]));
  // A: no Rod upgrade, reduced motion (the fish barely sway)
  let { c, p } = await load('{"fish":1}', false);
  const yA = await fishY(p), w2A = await box(p, 290, 0, 340, 16);
  if (process.env.SHOTS) await (await p.$('canvas.cfr2cv')).screenshot({ path: process.env.SHOTS + '/room2-rod-none.png' });
  await c.close();
  // B: Longer string and Double rod
  ({ c, p } = await load('{"fish":1,"string":1,"double":1}', false));
  const yB = await fishY(p), w2B = await box(p, 290, 0, 340, 16);
  if (process.env.SHOTS) await (await p.$('canvas.cfr2cv')).screenshot({ path: process.env.SHOTS + '/room2-rod-string-double.png' });
  await c.close();
  ok('room2 rod: Longer string hangs each fish lower on the canvas (6 to 10 px)', yA.map((y, i) => yB[i] - y >= 6 && yB[i] - y <= 10).join(), 'true,true,true');
  ok('room2 rod: Double rod paints a second wand at the ceiling right of the first (the pixels there change)', w2A !== w2B, true);
  // C: Rod motor with motion on: the resting wand turns, so its pixels change over time; without the motor they hold still
  ({ c, p } = await load('{"fish":1}', true));
  const s0 = await box(p, 200, 0, 280, 40); await p.waitForTimeout(450); const s1 = await box(p, 200, 0, 280, 40); await p.waitForTimeout(450); const s2 = await box(p, 200, 0, 280, 40);
  await c.close();
  ({ c, p } = await load('{"fish":1,"motor":1}', true));
  const m0 = await box(p, 200, 0, 280, 40); await p.waitForTimeout(450); const m1 = await box(p, 200, 0, 280, 40); await p.waitForTimeout(450); const m2 = await box(p, 200, 0, 280, 40);
  if (process.env.SHOTS) await (await p.$('canvas.cfr2cv')).screenshot({ path: process.env.SHOTS + '/room2-rod-motor.png' });
  await c.close();
  ok('room2 rod: without the Rod motor the resting wand holds still', s0 === s1 && s1 === s2, true);
  ok('room2 rod: the Rod motor turns the resting wand (its pixels change within a second)', m0 !== m1 || m1 !== m2, true);
  ok('room2 rod: no page errors', errs.join(' | '), '');
  await br.close();
  console.log(out.join('\n'));
})().catch(e => { console.log('FAIL room2 rod browser check crashed: ' + e); process.exit(0); });
