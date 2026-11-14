// Puzzle box belt, Remove on a broken or gone tool, in a browser: node tests/pfv1_belt.js BASE OUTDIR GAMEDIR TESTSDIR (run by tests/pfv1_belt.sh)
const { chromium } = require('playwright');
const { execSync } = require('child_process');
const [base, out, game, here] = process.argv.slice(2);
const seed = () => execSync(`php -d display_errors=1 ${here}/pfv1_belt_seed.php ${game}`).toString().trim();
const sql = (q) => execSync(`php -r '$p=new PDO("sqlite:${game}/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(",",$r),"\\n";' ${JSON.stringify(q)}`).toString().trim();
let fails = 0;
const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { console.log(`FAIL ${what} (got ${g}, want ${w})`); fails++; } };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  for (const [w, h] of [[390, 844], [1280, 720]]) for (const js of [true, false]) {
    const T = (s) => `${w}px${js ? '' : ' no-JS'}: ${s}`;
    const c = await b.newContext({ viewport: { width: w, height: h }, deviceScaleFactor: 1, javaScriptEnabled: js });
    const p = await c.newPage(); const errs = []; p.on('pageerror', e => { if (!/ViewTransition/.test(String(e))) errs.push(String(e)); });
    const n = (sel) => p.locator(sel).count();
    // sign in (without script the login form is submitted by its button)
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
    await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    ck(T('seeded: axe broken, till ok, rod gone'), JSON.parse(seed()), { axe: 'broken', till: 'ok', rod: 'none' });
    await p.goto(base + '/puzzlebox.php?t=belt', { waitUntil: 'networkidle' }); await p.waitForTimeout(400);
    ck(T('Remove shows on the broken and the gone entry only'), [await n('.pfv-rm button'), await n('.pcg .bslot'), await n('.pfv-rm [name=tool][value=axe]'), await n('.pfv-rm [name=tool][value=rod]'), await n('.pfv-rm [name=tool][value=till]')], [2, 1, 1, 1, 0]);
    ck(T('the page says the item is kept'), /keep it to repair later/i.test(await p.locator('.pfv').innerText()), true);
    if (js) { await p.locator('#pfv-tools .tb.broken').first().click(); await p.waitForTimeout(150);
      ck(T('the broken tool\'s line offers Fix and Remove (and not Put on)'), [await n('.pfv-dsheet [data-pfv-tool][data-do=pfd_fix]'), await n('.pfv-dsheet [data-pfv-tool][data-do=pfd_remove]'), await n('.pfv-dsheet [data-do=pfd_equip]')], [1, 1, 0]);
      await p.keyboard.press('Escape'); await p.waitForTimeout(100); }
    await p.screenshot({ path: `${out}/belt-remove-${w}x${h}${js ? '' : '-nojs'}.png`, fullPage: true });
    ck(T('no sideways scroll'), await p.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1), true);
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('.pfv-rm [name=tool][value=axe] ~ button')]); await p.waitForTimeout(900);
    ck(T('Remove the broken axe: the entry is off the belt in the database'), sql(`SELECT group_concat(tool_type) FROM pf_belts ORDER BY slot`), 'till,rod');
    await p.goto(base + '/puzzlebox.php?t=belt', { waitUntil: 'networkidle' });
    ck(T('the page now shows one Remove (the gone rod); the axe is still a tool button, broken, with its durability'), [await n('.pfv-rm button'), await n('#pfv-tools .tb.broken'), await n('.pfv-rm [name=tool][value=axe]')], [1, 1, 0]);
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('.pfv-rm button')]); await p.waitForTimeout(900);
    await p.goto(base + '/puzzlebox.php?t=belt', { waitUntil: 'networkidle' });
    ck(T('both removed: no Remove button, the freed slots show the plus'), [await n('.pfv-rm'), sql('SELECT group_concat(tool_type) FROM pf_belts')], [0, 'till']);
    ck(T('no script errors'), errs, []);
    await c.close();
  }
  await b.close(); console.log(fails ? `${fails} FAILED` : 'belt shots: all ok'); process.exit(fails ? 1 : 0);
})();
