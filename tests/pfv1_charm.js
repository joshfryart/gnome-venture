// 2.6.78: see tests/pfv1_charm.sh. node tests/pfv1_charm.js BASE GAME TESTSDIR
const { chromium } = require('playwright');
const { execSync } = require('child_process');
const [base, game, here] = process.argv.slice(2);
const seed = (...a) => execSync(`php -d display_errors=1 ${here}/pbox_v1_seed.php ${game} ${a.join(' ')}`).toString().trim();
let fails = 0;
const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { console.log(`FAIL ${what} (got ${g}, want ${w})`); fails++; } };
const VERBOSE = !!process.env.VERBOSE;
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const c = await b.newContext({ viewport: { width: 390, height: 844 } });
  const p = await c.newPage();
  const L = { errs: [], navs: [], reqs: [], bad: [] };
  p.on('pageerror', e => L.errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') L.errs.push(m.text()); });
  p.on('framenavigated', f => { if (f === p.mainFrame()) L.navs.push(f.url().replace(base, '')); });
  p.on('request', r => { if (r.method() === 'POST' || r.resourceType() === 'document') L.reqs.push(r.method() + ' ' + r.resourceType() + ' ' + r.url().replace(base, '') + ' ' + (r.headers()['x-requested-with'] || '')); });
  p.on('response', r => { if (r.status() >= 400 || (r.status() >= 300 && r.status() < 400)) L.bad.push(r.status() + ' ' + r.url().replace(base, '')); });
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  const speed = (v) => p.evaluate((x) => { try { localStorage.setItem('pfvspd', x); } catch (e) {} }, String(v));
  const open = async () => { await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(600); await p.evaluate(() => { window.__mark = 'same-doc'; }); };
  const reset = () => { L.errs = []; L.navs = []; L.reqs = []; L.bad = []; };
  const st = () => p.evaluate(() => ({ mark: window.__mark || null, playing: !!document.getElementById('pfight') && document.getElementById('pfight').classList.contains('pf-playing'), over: !!document.getElementById('pfv-res') || !!document.querySelector('#pf-end'), res: !!document.getElementById('pfv-res'), turn: (document.getElementById('pfight') || {}).dataset ? document.getElementById('pfight').dataset.turn : null }));
  // play one charm piece (hand index i) on the first lit cell; waits until the replay is over
  async function playOne(i) {
    await p.locator('#pf-hand .pf-tile').nth(i).click(); await p.waitForTimeout(250);
    if (!(await p.locator('#pfb-board .pfb-lit').count())) return 'nolit';
    await p.locator('#pfb-board .pfb-lit').first().click(); await p.waitForTimeout(150);
    await p.click('#pf-go');
    return 'played';
  }
  async function settle(max = 40) {
    for (let k = 0; k < max * 5; k++) { await p.waitForTimeout(200); const s = await st().catch(() => ({ mark: 'gone' })); if (s.mark === 'gone') continue; if (!s.playing && k > 5) return s; }
    return await st();
  }

  // FUZZ=1: real seeded fights (all sizes), charm pieces preferred, several turns each; report any navigation, plain POST, failed request or console error
  if (process.env.FUZZ) {
    const sizes = (process.env.SIZES || 'small,medium,large').split(','); const nseeds = +(process.env.NSEEDS || 6);
    for (const size of sizes) for (let sd = 1; sd <= nseeds; sd++) {
      seed('fight', size); seed('midfight', String(sd), String(sd % 3), 'soft'); await speed(process.env.SPEED || '2'); await open(); reset();
      const turns = [];
      for (let turn = 0; turn < 8; turn++) {
        const s0 = await st().catch(() => null); if (!s0 || s0.res) break;
        const pick = await p.evaluate(() => { const d = JSON.parse(document.getElementById('pf-data').textContent); const ts = [...document.querySelectorAll('#pf-hand .pf-tile')]; let best = -1; ts.forEach((el, i) => { if (el.classList.contains('pfv-off')) return; if (best < 0 || (d.hand[i].t === 'charm' && d.hand[best].t !== 'charm')) best = i; }); return best < 0 ? null : { i: best, t: d.hand[best].t, n: d.hand[best].n }; });
        let did = 'pass';
        if (pick) { did = await playOne(pick.i); did = did + ':' + pick.n; } else { await p.click('#pf-pass').catch(() => {}); }
        turns.push(did); const s = await settle(); if (s.res) break;
      }
      const docPosts = L.reqs.filter(r => /^POST document/.test(r)); const extra = L.navs.filter(u => !/adventure\.php$/.test(u));
      const bad = L.bad.filter(x => !/^302 /.test(x));
      console.log(`${size} ${sd}: ${turns.join(' ')} | navs ${L.navs.length} docPosts ${docPosts.length} bad ${bad.length} errs ${L.errs.length}`);
      ck(`[fuzz ${size} ${sd}] no navigation, no plain POST, no failed request, no console error`, [L.navs.length, docPosts.length, bad, L.errs], [0, 0, [], []]);
    }
    console.log('charm: done'); await b.close(); process.exit(fails ? 1 : 0);
  }
  const variants = (process.env.VARIANTS || 'plain,near,defeat').split(',');
  for (const sp of (process.env.SPEEDS || '1').split(',')) for (const var_ of variants) for (const sd of (process.env.SEEDS || '7,8').split(',')) {
    seed('fight', 'small'); const info = seed('charm', sd, var_); await speed(sp); await open(); reset();
    if (VERBOSE) console.log('---', var_, sd, 'speed', sp, info);
    const trail = [];
    for (let turn = 0; turn < 6; turn++) {
      const s0 = await st().catch(() => null); if (!s0 || s0.res) break;
      const n = await p.locator('#pf-hand .pf-tile').count(); let did = 'nolit';
      for (let i = 0; i < n && did === 'nolit'; i++) did = await playOne(i);
      if (did === 'nolit') { await p.click('#pf-pass').catch(() => {}); }
      const s = await settle(); trail.push(`${did} -> ${JSON.stringify(s)}`);
      if (s.res) break;
    }
    if (VERBOSE) { console.log(trail.join('\n')); console.log('navs', JSON.stringify(L.navs)); console.log('reqs', JSON.stringify(L.reqs)); console.log('bad', JSON.stringify(L.bad)); console.log('errs', JSON.stringify(L.errs)); }
    ck(`[${var_} ${sd} x${sp}] no console errors`, L.errs, []);
  }
  console.log('charm: done');
  await b.close(); process.exit(fails ? 1 : 0);
})();
