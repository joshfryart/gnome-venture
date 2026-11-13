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
  // ---- what the page does from the click on Play until it is quiet: when the replay runs, which banners show, how the charm bar fills, when the result card appears
  const sample = () => p.evaluate(() => { const f = document.getElementById('pfight'); if (!f) return null; const r = document.getElementById('pfv-res'), b = document.querySelector('.pfx-fill.charm'), tn = document.querySelector('.pf-turn:not([hidden])');
    return { mark: window.__mark || null, playing: f.classList.contains('pf-playing'), wait: f.classList.contains('pfv-endwait'), res: !!r && getComputedStyle(r).display !== 'none' && r.getBoundingClientRect().height > 0, bar: b ? b.style.width : null, cn: (document.querySelector('.pf-charmn') || {}).textContent || null, banner: tn ? tn.textContent.trim() : '' }; }).catch(() => null);
  async function playAndWatch(i) {
    await p.locator('#pf-hand .pf-tile').nth(i).click(); await p.waitForTimeout(250);
    await p.locator('#pfb-board .pfb-lit').first().click(); await p.waitForTimeout(150);
    const t0 = Date.now(); await p.click('#pf-go');
    const tl = []; let quiet = 0;
    for (let k = 0; k < 260; k++) {
      await p.waitForTimeout(90); const s = await sample(); if (!s) continue; s.t = Date.now() - t0; tl.push(s);
      const busy = s.playing || s.wait; quiet = busy ? 0 : quiet + 1; if (quiet >= 8 && k > 12) break;
    }
    const first = (f) => { const x = tl.find(f); return x ? x.t : null; };
    return { tl, played: tl.some(s => s.playing), tPlayStart: first(s => s.playing), tRes: first(s => s.res), banners: [...new Set(tl.map(s => s.banner).filter(Boolean))], tBarFull: first(s => s.bar === '100%'), mark: tl.every(s => s.mark === 'same-doc'), resWhilePlaying: tl.some(s => s.playing && s.res), last: tl[tl.length - 1] };
  }
  const nav = () => ({ navs: L.navs.length, docPosts: L.reqs.filter(r => /^POST document/.test(r)).length, bad: L.bad.filter(x => !/^302 /.test(x)), errs: L.errs });
  const quietOk = (w) => ck(w + ': no navigation, no plain POST, no failed request, no console error', nav(), { navs: 0, docPosts: 0, bad: [], errs: [] });
  const start = async (var_, sd, sp) => { seed('fight', 'small'); seed('charm', sd, var_); await speed(sp); await open(); reset(); };
  const SD = process.env.SEED || '7';

  // 1. charm pieces turn after turn (the creature answers each time): the page is swapped in place, the replay plays, nothing reloads
  await start('plain', SD, 2);
  for (let k = 0; k < 2; k++) {
    const r = await playAndWatch(0);
    ck(`charm turn ${k + 1}: the replay plays (your turn, the creature's turn) and the page is the same document`, [r.played, r.mark, r.banners.some(x => /Your turn/i.test(x)), k === 1 || r.banners.some(x => /turn/i.test(x) && !/Your turn/i.test(x))], [true, true, true, true]);   // (the second charm may already win the fight)
  }
  quietOk('charm pieces, 2 turns');

  // 2. the charm that fills the bar on the FIRST turn: the last turn is replayed, the bar fills, and only then the result card shows
  await start('near', SD, 1);
  let r = await playAndWatch(0);
  ck('charm win (turn 1): the replay plays, the bar reaches full, and only then the result card shows (never over the replay)', [r.played, r.tBarFull !== null, r.tRes !== null && r.tBarFull !== null && r.tBarFull <= r.tRes, r.resWhilePlaying, r.banners.some(x => /Your turn/i.test(x))], [true, true, true, false, true]);
  ck('charm win (turn 1): the card says Charmed with the reward button, the page is the same document', [await p.locator('#pfv-res .badge-charm').count(), await p.locator('#pf-end').isVisible(), r.mark], [1, true, true]);
  quietOk('charm win turn 1');
  // a reload after the end lands on the result at once (no replay again)
  await p.reload({ waitUntil: 'networkidle' }); await p.waitForTimeout(500);
  ck('reload after the end: the result card shows at once', await sample().then(s => [s.res, s.playing, s.wait]), [true, false, false]);

  // 3. the charm that fills the bar on a LATER turn (the page already replayed that turn's number once: the replay must still play)
  await start('plain', SD, 1); reset();
  await playAndWatch(0);
  seed('setbar', '0.93');
  await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(500); await p.evaluate(() => { window.__mark = 'same-doc'; }); reset();
  r = await playAndWatch(0);
  ck('charm win (a later turn): the last turn is replayed (not skipped), the bar fills, then the card', [r.played, r.tBarFull !== null && r.tRes !== null && r.tBarFull <= r.tRes, r.resWhilePlaying, r.mark], [true, true, false, true]);
  quietOk('charm win, later turn');

  // 4. a lost fight: your last turn and the creature's answer are replayed, then the lost card with its Continue button; Continue ends the fight
  await start('defeat', SD, 1);
  r = await playAndWatch(0);
  ck('defeat: the replay plays your turn and the creature\'s turn first, then the card (never over the replay)', [r.played, r.banners.some(x => /Your turn/i.test(x)), r.banners.some(x => /turn/i.test(x) && !/Your turn/i.test(x)), r.resWhilePlaying, r.tRes !== null], [true, true, true, false, true]);
  ck('defeat: the lost card with a button to go home (same document, no reload)', [await p.locator('#pfv-res .badge-lose').count(), await p.locator('#pf-end').isVisible(), r.mark], [1, true, true]);
  quietOk('defeat');
  await Promise.all([p.waitForResponse(x => x.request().method() === 'POST'), p.click('#pf-end')]); await p.waitForTimeout(1500);
  ck('defeat: Continue ends the fight (no fight on the page any more)', await p.locator('#pfight').count(), 0);

  // 5. animation speed: skip shows the card at once; a tap on Skip during the replay shortens it
  await start('near', SD, 0);
  r = await playAndWatch(0);
  ck('speed skip: the card shows at once', [r.tRes !== null && r.tRes < 1500, r.mark], [true, true]);
  await start('near', SD, 1);
  await p.locator('#pf-hand .pf-tile').nth(0).click(); await p.waitForTimeout(250); await p.locator('#pfb-board .pfb-lit').first().click(); await p.waitForTimeout(150); await p.click('#pf-go');
  await p.waitForSelector('#pf-skip:not([hidden])', { timeout: 5000 }); await p.click('#pf-skip'); await p.waitForTimeout(1500);
  ck('Skip during the replay of the last turn: the card shows (the replay can be shortened by the player only)', await sample().then(s => [s.res, s.playing]), [true, false]);

  // 6. the engine and the bar agree (the page never reads a full bar before the fight is won): the fill stops short of the end until then
  await start('plain', SD, 2);
  r = await playAndWatch(0);
  ck('the charm bar is never drawn full while the fight goes on', r.tl.some(s => s.bar === '100%') , false);
  quietOk('bar');
  // 2.6.80 (Josh): a number on the charm meter, N/100: 0/100 at the start, up after a charm piece, 100/100 only when the creature is won
  await start('plain', SD, 2);
  const n0 = await p.locator('.pf-charmn').first().textContent().catch(() => null);
  ck('charm meter number: 0/100 at the start', n0, '0/100');
  r = await playAndWatch(0);
  const nN = r.tl.map(s => s.cn).filter(Boolean), nv = x => parseInt(x, 10), last = nN[nN.length - 1];
  ck('charm meter number: it climbs during the replay and is higher after a charm piece (N/100, never 100 before the win)', [nN.every(x => /^\d{1,3}\/100$/.test(x)), nN.some((x, i) => i && nv(x) > nv(nN[0])) || nv(last) > 0, nN.some(x => x === '100/100')], [true, true, false]);
  await start('near', SD, 2); r = await playAndWatch(0);
  ck('charm meter number: 100/100 exactly when the creature is won', [r.tl.some(s => s.res), (r.tl.filter(s => s.res).pop() || {}).cn], [true, '100/100']);
  quietOk('charm meter number');

  console.log('charm: done');
  await b.close(); process.exit(fails ? 1 : 0);
})();
