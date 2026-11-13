// 2.6.79: End turn on a phone (Josh: "reload still occurring when end turn", usually after a pink piece). Emulated Pixel 7, touch taps, the served v1 page:
//   node tests/pfv1_endturn.js BASE GAME TESTSDIR
// Every sequence must end the turn IN PLACE: no navigation, no beforeunload, no plain form post, no failed request, no console error, and no frame in which the board is empty
// (the turn is swapped in place; the old fight stays frozen over it until the new board is drawn, so it never looks like a reload).
const { chromium, devices } = require('playwright');
const { execSync } = require('child_process');
const [base, game, here] = process.argv.slice(2);
const seed = (...a) => execSync(`php -d display_errors=1 ${here}/pbox_v1_seed.php ${game} ${a.join(' ')}`).toString().trim();
let fails = 0;
const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { console.log(`FAIL ${what} (got ${g}, want ${w})`); fails++; } };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const c = await b.newContext({ ...devices['Pixel 7'] });
  await c.addInitScript(() => {
    window.__ev = []; window.__blank = 0; window.__armed = false;
    window.addEventListener('beforeunload', () => window.__ev.push('beforeunload'));
    document.addEventListener('submit', e => setTimeout(() => { if (!e.defaultPrevented) window.__ev.push('plain submit ' + (e.target.id || '')); }, 0));
    const tick = () => { if (window.__armed) { const f = document.getElementById('pfight'), bd = document.getElementById('pfb-board'); if (!f || !bd || !bd.children.length) { if (!document.querySelector('.pfv-ghost')) window.__blank++; } } requestAnimationFrame(tick); };
    requestAnimationFrame(tick);
  });
  const p = await c.newPage(); const L = { errs: [], navs: [], posts: [], bad: [] };
  p.on('pageerror', e => L.errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') L.errs.push(m.text()); });
  p.on('framenavigated', f => { if (f === p.mainFrame()) L.navs.push(f.url().replace(base, '')); });
  p.on('request', r => { if (r.method() === 'POST' && r.resourceType() === 'document') L.posts.push(r.url()); });
  p.on('response', r => { if (r.status() >= 400) L.bad.push(r.status() + ' ' + r.url()); });
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await p.press('input[name=password]', 'Enter'); await p.waitForLoadState('networkidle');
  const open = async () => { await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(600); L.errs = []; L.navs = []; L.posts = []; L.bad = []; await p.evaluate(() => { window.__mark = 1; window.__ev = []; window.__blank = 0; window.__armed = true; }); };
  const done = async (what) => {
    await p.waitForTimeout(500);
    const s = await p.evaluate(() => ({ mark: window.__mark, ev: window.__ev, blank: window.__blank })).catch(() => ({ mark: 'gone' }));
    ck(`${what}: the page is never reloaded (same document, no navigation, no beforeunload, no plain submit)`, [s.mark, L.navs.length, s.ev, L.posts.length], [1, 0, [], 0]);
    ck(`${what}: no empty-board frame, no failed request, no console error`, [s.blank, L.bad, L.errs.filter(x => !/ResizeObserver/.test(x))], [0, [], []]);
  };
  const quiet = () => p.waitForFunction(() => { const f = document.getElementById('pfight'); return f && !f.classList.contains('pf-playing'); }, null, { timeout: 25000 }).then(() => p.waitForTimeout(400)).catch(() => {});
  const hand = async (i) => { await p.locator('#pf-hand .pf-tile').nth(i).tap(); await p.waitForTimeout(250); };
  const cell = async () => { await p.locator('#pfb-board .pfb-lit').first().tap(); await p.waitForTimeout(200); };
  const start = async (kind) => { seed('fight', 'small'); seed(kind === 'nofit' ? 'nofit' : 'charm', ...(kind === 'nofit' ? ['7'] : ['7', 'plain'])); await p.evaluate(() => localStorage.setItem('pfvspd', '2')).catch(() => {}); await open(); };

  // pink pieces: Charm, Offer, Hum, Lull, Bond, then End turn
  for (const [i, nm] of [[0, 'Charm'], [1, 'Offer'], [2, 'Hum'], [3, 'Lull'], [4, 'Bond']]) {
    await start('charm'); await hand(i); await cell(); await p.locator('#pf-go').tap(); await quiet(); await done(`pink ${nm} then End turn`);
  }
  // two turns in a row (the second page is the swapped one)
  await start('charm'); for (const i of [0, 1]) { await hand(i); await cell(); await p.locator('#pf-go').tap(); await quiet(); } await done('two End turns in a row');
  // undo, then another piece, then End turn
  await start('charm'); await hand(0); await cell(); await p.locator('#pf-undo').tap(); await hand(3); await cell(); await p.locator('#pf-go').tap(); await quiet(); await done('after Undo');
  // flip, then place, then End turn
  await start('charm'); await hand(0); if (await p.locator('#pf-flip').isEnabled()) await p.locator('#pf-flip').tap(); await p.waitForTimeout(900); await cell(); await p.locator('#pf-go').tap(); await quiet(); await done('after Flip');
  // a rapid double tap on End turn
  await start('charm'); await hand(0); await cell(); await p.locator('#pf-go').tap(); await p.locator('#pf-go').tap({ timeout: 400 }).catch(() => {}); await quiet(); await done('double tap on End turn');
  // End turn (and a piece) while the replay is still running
  await start('charm'); await hand(0); await cell(); await p.locator('#pf-go').tap(); await p.waitForTimeout(700); await p.locator('#pf-go').tap({ timeout: 500 }).catch(() => {}); await p.locator('#pf-hand .pf-tile').nth(1).tap({ timeout: 500, force: true }).catch(() => {}); await quiet(); await done('End turn during the replay');
  // nothing fits: pass with End turn
  await start('nofit'); await p.locator('#pf-pass').tap(); await quiet(); await done('pass (nothing fits)');
  // a charm piece that wins the fight, then the result
  seed('fight', 'small'); seed('charm', '7', 'near'); await p.evaluate(() => localStorage.setItem('pfvspd', '2')); await open(); await hand(0); await cell(); await p.locator('#pf-go').tap(); await p.waitForSelector('#pfv-res', { state: 'visible', timeout: 25000 }).catch(() => {}); await done('charm win');
  console.log('endturn: done'); await b.close(); process.exit(fails ? 1 : 0);
})();
