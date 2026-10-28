// v2.0.87 B: a Jigsaw tournament in a real browser (called by tests/jigsaw_tourney.sh). node jigsaw_tourney_check.js BASE TOURNAMENT_ID
// Logs in as sprout, opens the page, starts a timed go: the table must have the TIER's pieces (Advanced = 96), the tier select is disabled and no free-play call is made.
const { chromium } = require('playwright');
(async () => {
  const [base, tid, pieces] = process.argv.slice(2);
  const b = await chromium.launch({ executablePath: process.env.PW_CHROMIUM || undefined, args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  let fails = 0;
  const say = (ok, msg) => { if (!ok) fails++; console.log((ok ? 'ok   ' : 'FAIL ') + msg); };
  const c = await b.newContext({ viewport: { width: 1280, height: 800 } });
  const p = await c.newPage(); const errs = [], calls = [];
  p.on('pageerror', e => errs.push(String(e)));
  p.on('request', r => { if (r.url().includes('puzzles_api.php')) calls.push(r.postData() || ''); });
  await p.goto(base + '/login.php');
  await p.fill('input[name="username"]', 'sprout'); await p.fill('input[name="password"]', 'TestPass123!');
  await Promise.all([p.waitForNavigation({ waitUntil: 'load' }), p.press('input[name="password"]', 'Enter')]);
  await p.goto(base + '/jigsaw.php?t=' + tid);
  await p.click('#tstart');
  await p.waitForFunction(m => document.querySelectorAll('#field .piece').length === m, +pieces, { timeout: 15000 }).catch(() => {});
  say(await p.locator('#field .piece').count() === +pieces, `tournament table has ${pieces} pieces`);
  say(await p.locator('#count').isDisabled(), 'tier select is disabled');
  say(await p.locator('#count').inputValue() === String(pieces), 'tier select shows the tier');
  say(calls.length === 1 && /do=start/.test(calls[0]), `only the tournament start was called (${calls.join(' | ')})`);
  say(await p.locator('#nexttier').isHidden(), 'no next-tier button');
  say(await p.locator('#again').innerText() === 'Another go' && await p.locator('#back2').innerText() === 'See the times', 'win card buttons say Another go / See the times');
  say(errs.length === 0, 'no script errors ' + errs.join(';'));
  await b.close();
  process.exit(fails ? 1 : 0);
})();
