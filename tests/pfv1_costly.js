// 2.7.01 costly cell (claude/reviews-2026-11-13/learn.md item 1) and the help sheet rows. node tests/pfv1_costly.js BASE GAME TESTSDIR  (see tests/pfv1_costly.sh)
const { chromium } = require('playwright');
const { execSync } = require('child_process');
const [base, game, here] = process.argv.slice(2);
const seedNew = (...a) => execSync(`PBOX_RULES=new php -d display_errors=1 ${here}/pbox_v1_seed.php ${game} ${a.join(' ')}`).toString().trim();
const sql = (q) => execSync(`php -r '$p=new PDO("sqlite:${game}/data/game.sqlite"); $p->exec($argv[1]);' "${q}"`);
let fails = 0;
const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { console.log(`FAIL ${what} (got ${g}, want ${w})`); fails++; } };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const p = await (await b.newContext({ viewport: { width: 390, height: 844 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
  let costly = null, sent = 0;   // costly: the "x,y" spot the test made cost 4 health; sent: End turn posts that reached the server
  await p.route('**/adventure.php*', async (route) => {
    const rq = route.request(), body = rq.postData() || '';
    if (rq.method() !== 'POST') return route.continue();
    if (!/pfb_cells/.test(body)) { if (/pfb_play/.test(body)) sent++; return route.continue(); }
    const r = await route.fetch(); let j; try { j = await r.json(); } catch (e) { return route.fulfill({ response: r }); }
    if (j && j.ok && j.cells) { const ks = Object.keys(j.cells); ks.forEach((k, i) => { j.cells[k].hp = i === 0 ? 4 : 0; if (i === 0) j.cells[k].hw = [['Snap', 'foe', 4]]; else delete j.cells[k].hw; }); costly = ks.length >= 2 ? ks[0] : null; }
    return route.fulfill({ response: r, json: j });
  });
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  await p.evaluate(() => localStorage.setItem('pfvspd', '0'));
  const ready = async () => { await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(700); };
  // a hand piece with two or more lit spots; returns its lit spots as [x,y,classes,title]
  const pick = async () => {
    const tiles = p.locator('#pf-hand .pf-tile'); const n = await tiles.count();
    for (let k = 0; k < n; k++) {
      if (await tiles.nth(k).evaluate(t => t.hidden || t.classList.contains('pfv-off'))) continue;
      costly = null; await tiles.nth(k).click(); await p.waitForTimeout(900);
      if (costly) return p.evaluate(() => [...document.querySelectorAll('.pfb-lit')].map(c => [c.dataset.x + ',' + c.dataset.y, c.className, c.title || '', c.getAttribute('aria-label') || '']));
      await tiles.nth(k).click(); await p.waitForTimeout(300);
    }
    return null;
  };
  const foe = async () => (await p.evaluate(() => JSON.parse(document.getElementById('pf-data').textContent).foe));
  const prevT = () => p.evaluate(() => { const e = document.getElementById('pf-preview'); return [e.textContent, e.classList.contains('pfv-costwarn')]; });

  // ---- a gnome in its first fights (no pf_learn row): red edge, named cause, End turn asks once
  sql('DELETE FROM pf_learn');
  seedNew('fight', 'small'); seedNew('midfight', '7', '1', 'soft');
  await ready();
  ck('page data: costwarn on for a new gnome', await p.evaluate(() => JSON.parse(document.getElementById('pf-data').textContent).costwarn), true);
  let lit = await pick(); ck('arrange: a piece with 2+ lit spots', !!lit, true);
  if (lit) {
    const F = await foe(), c = lit.find(l => l[0] === costly), o = lit.filter(l => l[0] !== costly);
    ck('the costly spot has the red edge', /pfv-costly/.test(c[1]), true);
    ck('its title names the cost and the cause', c[2], `Costs you 4 health: it fires the ${F}’s Snap`);
    ck('its label for screen readers says it too', /costs you 4 health/.test(c[3]) && /it fires the .*Snap/.test(c[3]), true);
    ck('the free spots have no red edge', o.every(l => !/pfv-costly/.test(l[1])), true);
    const [x, y] = costly.split(',');
    await p.click(`.pfb-lit[data-x="${x}"][data-y="${y}"]`); await p.waitForTimeout(400);
    ck('placed: the line above End turn names it', await prevT(), [`This fires the ${F}’s Snap. You lose 4 health.`, true]);
    const s0 = sent; await p.click('#pf-go'); await p.waitForTimeout(800);
    ck('first End turn: nothing is sent', sent - s0, 0);
    ck('first End turn: it asks', (await prevT())[0], `This fires the ${F}’s Snap. You lose 4 health. A lit spot that costs nothing was open. Tap End turn again to play it anyway.`);
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST' && /pfb_play/.test(r.request().postData() || ''), { timeout: 10000 }).catch(() => null), p.click('#pf-go')]);
    await p.waitForTimeout(800);
    ck('second End turn: the move is sent', sent - s0, 1);
  }
  // ---- after 5 fights the ask is off: the red edge stays, End turn sends at once
  sql('DELETE FROM pf_learn'); sql("INSERT INTO pf_learn (user_id, fights) SELECT id, 5 FROM users WHERE username = 'sprout'");
  seedNew('fight', 'small'); seedNew('midfight', '7', '1', 'soft');
  await ready();
  ck('page data: costwarn off after 5 fights', await p.evaluate(() => JSON.parse(document.getElementById('pf-data').textContent).costwarn), false);
  lit = await pick();
  if (lit) {
    const [x, y] = costly.split(',');
    ck('after 5 fights: still the red edge', /pfv-costly/.test(lit.find(l => l[0] === costly)[1]), true);
    await p.click(`.pfb-lit[data-x="${x}"][data-y="${y}"]`); await p.waitForTimeout(400);
    const s0 = sent;
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST' && /pfb_play/.test(r.request().postData() || ''), { timeout: 10000 }).catch(() => null), p.click('#pf-go')]);
    await p.waitForTimeout(800);
    ck('after 5 fights: the first End turn sends', sent - s0, 1);
  } else ck('arrange: a piece with 2+ lit spots (second fight)', false, true);
  // ---- the help sheet: how a fight ends, the lit-spot numbers, combos; Chains, Guard and Flip have their own marks
  await ready();
  await p.click('#pfv-legend [data-a=help]'); await p.waitForTimeout(300);
  const sh = await p.evaluate(() => { const e = document.querySelector('.pfv-sheet'); return e ? e.innerText : ''; });
  ck('help sheet: how a fight ends (win, lose, the turn cap)', /How a fight ends/.test(sh) && /You lose when your health reaches 0/.test(sh) && /After 24 turns/.test(sh), true);
  ck('help sheet: what the numbers on a lit spot mean', /Numbers on a lit spot/.test(sh) && /health YOU lose/.test(sh), true);
  ck('help sheet: what a combo is', /Combos/.test(sh) && /Riposte/.test(sh), true);
  ck('help sheet: no set-aside row in a fight without set aside', /Set aside/.test(sh), false);
  ck('help sheet: one mark per row (no shared arrow glyph for Chains, Guard, Flip)', await p.evaluate(() => { const r = [...document.querySelectorAll('.pfv-sheet .helpl li')].filter(li => /^(Chains|Guard|Flip)/.test(li.querySelector('b').textContent)).map(li => li.querySelector('svg').innerHTML); return r.length === 3 && new Set(r).size === 3; }), true);
  ck('no console error', errs, []);
  console.log('costly: done'); await b.close(); process.exit(fails ? 1 : 0);
})().catch(e => { console.log('FAIL crash ' + e); process.exit(1); });
