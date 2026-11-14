// 2.6.96 (owner: "I started a new combat after winning an old one. This always happens when encountering a new combat, resolves on refresh"): the page showed the OLD, finished fight
// (its board, LAST PLAYS, "It is over", the result card) over the new encounter. Fight A is won and collected and fight B is met and started, all in ONE document (in-place swaps, no reload),
// on the plain adventure page and in the modal Trail dialog. Asserts: B's creature, no trace of A (no frozen copy, no "It is over", no result card), B's bar at its start, turn 1, a hand of 5,
// no console error, and the same text as a fresh load of the page.
//   node tests/pfv1_newfight.js BASE GAME TESTSDIR plain|modal      (see tests/pfv1_newfight.sh)
const { chromium } = require('playwright');
const { execSync } = require('child_process');
const [base, game, here, mode] = process.argv.slice(2);
const seed = (...a) => execSync(`php -d display_errors=1 ${here}/pbox_v1_seed.php ${game} ${a.join(' ')}`).toString().trim();
let fails = 0;
const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { console.log(`FAIL ${what} (got ${g}, want ${w})`); fails++; } };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const c = await b.newContext({ viewport: { width: 1280, height: 900 } });   // the owner's desktop browser
  const p = await c.newPage(); const L = { errs: [], navs: [] };
  p.on('pageerror', e => L.errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') L.errs.push(m.text()); });
  p.on('framenavigated', f => { if (f === p.mainFrame()) L.navs.push(f.url().replace(base, '')); });
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  await p.evaluate(() => localStorage.setItem('pfvspd', '2'));
  const fresh = await c.newPage();   // a second tab: "the page after a refresh", without leaving the document under test
  // the text of the fight area as the player sees it: the parent of #pfight (a frozen copy of an old fight would sit next to #pfight, so it is counted)
  // the text CONTENT, not innerText: what the dock shows (one line or several, pfv-docks) depends on its measured height, which is layout, not which fight is on the page
  const area = (pg) => pg.evaluate(() => { const f = document.getElementById('pfight'), a = f && (f.closest('.hubcard') || f.parentElement); if (!a) return ''; const k = a.cloneNode(true); k.querySelectorAll('script, style').forEach(x => x.remove()); return k.textContent.replace(/\s+/g, ' ').trim(); });
  const same = (x) => x.replace(/\s+/g, '');
  const look = (pg) => pg.evaluate(() => {
    const vis = (e) => !!e && e.getClientRects().length > 0 && getComputedStyle(e).visibility !== 'hidden';
    const f = document.getElementById('pfight'); let d = null; try { d = JSON.parse(document.getElementById('pf-data').textContent); } catch (e) {}
    return { ghosts: document.querySelectorAll('.pfv-ghost').length, over: /It is over/.test(document.body.innerText), res: [...document.querySelectorAll('.res.pfv, #pfv-res')].filter(vis).length,
      boards: document.querySelectorAll('.pfight.pf-boardmode').length, name: ((document.querySelector('#pfight .pfc-fname b, #pfv-pre .pfv-foe b, #pfv-pre h2, #pfv-pre h3') || {}).textContent || '').trim(),
      turn: f && f.dataset.turn || null, mode: f && f.dataset.mode || null, hand: document.querySelectorAll('#pf-hand .pf-tile').length, won: d && d.won, fh: d && d.fh, bar: d && d.bar,
      barText: ((document.querySelector('#pfight .pf-fhp b') || {}).textContent || '').trim(), pre: !!document.getElementById('pfv-pre'), modal: !!document.querySelector('#trailpop #pfight'), mark: window.__mark || null };
  });
  const quiet = () => p.waitForFunction(() => { const f = document.getElementById('pfight'); return f && f.dataset.mode === 'board' && !f.classList.contains('pf-playing'); }, null, { timeout: 25000 }).then(() => p.waitForTimeout(500)).catch(() => {});
  const open = async () => { await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(600); await p.evaluate(() => { window.__mark = 'same-doc'; }); L.errs = []; L.navs = []; };

  for (const kind of ['charm', 'hurt']) {
    const T = (s) => `[${mode} ${kind} win] ${s}`;
    // ---- fight A, won in the page
    seed('fight', 'small');
    if (kind === 'charm') {
      seed('charm', '7', 'near'); await open();
      await p.locator('#pf-hand .pf-tile').nth(0).click(); await p.waitForTimeout(250);
      if (!(await p.locator('#pfb-board .pfb-lit').count())) { for (let j = 1; j < 5; j++) { await p.locator('#pf-hand .pf-tile').nth(j).click(); await p.waitForTimeout(250); if (await p.locator('#pfb-board .pfb-lit').count()) break; } }
      await p.locator('#pfb-board .pfb-lit').first().click(); await p.waitForTimeout(150); await p.click('#pf-go');
    } else { seed('midfight', '7', '1', 'soft'); seed('win'); await open(); }   // a hurt win: the last turn is replayed when the page opens
    await p.waitForSelector('#pfv-res', { state: 'visible', timeout: 25000 }).catch(() => {});
    const a = await look(p);
    ck(T('fight A ends on its result card (won: ' + a.won + ')'), [a.res, kind === 'charm' ? a.won === 'charmed' : ['seen_off', 'charmed'].includes(a.won), a.modal], [1, true, mode === 'modal']);   // the server-side greedy player of the hurt seed may also land a charm
    // ---- the result card's button, in place
    await p.click('#pf-end');
    await p.waitForFunction(() => !document.querySelector('#pfight[data-mode=board]'), null, { timeout: 15000 }).catch(() => {}); await p.waitForTimeout(600);
    // ---- fight B: a new encounter (another creature), met through an in-place load of the page (window.gvRefresh, the same swap a Trail step or Go deeper uses)
    const want = (seed('fight', 'medium').match(/^creature: (.*) \(/) || [])[1];
    await p.evaluate(() => window.gvRefresh()); await p.waitForSelector('#pfv-pre', { timeout: 15000 }).catch(() => {}); await p.waitForTimeout(1500);
    const m = await look(p); const mText = await area(p);
    await fresh.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await fresh.waitForTimeout(600); const mFresh = await area(fresh);
    ck(T('B is met in the same document: its pre-fight screen'), [m.mark, L.navs.length, m.pre], ['same-doc', 0, true]);
    ck(T('B met: no frozen copy of A, no "It is over", no result card, no old board'), [m.ghosts, m.over, m.res, m.boards], [0, false, 0, 0]);
    if (same(mText) !== same(mFresh)) { const fw = same(mText), rw = same(mFresh); let i = 0; while (fw[i] === rw[i]) i++; console.log('DIFF at ' + i + ': ' + fw.slice(i - 30, i + 60) + ' || ' + rw.slice(i - 30, i + 60)); }
    ck(T('B met: the page reads as it does after a refresh'), same(mText), same(mFresh));
    // ---- Let's fight: B is dealt, in place
    await p.click('#pfv-go'); await quiet();
    const f = await look(p); const fText = await area(p);
    ck(T('B started in the same document'), [f.mark, L.navs.length, f.mode], ['same-doc', 0, 'board']);
    ck(T("B started: the creature is B's"), f.name, want);
    ck(T('B started: no frozen copy of A, no "It is over", no result card, one board'), [f.ghosts, f.over, f.res, f.boards, f.won], [0, false, 0, 1, null]);
    ck(T('B started: the bar at its start, turn 1, a hand of 5'), [f.fh, f.bar, f.turn, f.hand], [0, 0, '1', 5]);
    ck(T('no console error'), L.errs.filter(x => !/ResizeObserver/.test(x)), []);
    await p.reload({ waitUntil: 'networkidle' }); await quiet();
    const r = await look(p); const rText = await area(p);
    if (same(fText) !== same(rText)) { const fw = same(fText), rw = same(rText); let i = 0; while (fw[i] === rw[i]) i++; console.log('DIFF at ' + i + ': ' + fw.slice(i - 30, i + 60) + ' || ' + rw.slice(i - 30, i + 60)); }
    ck(T('after a reload the fight area reads the same'), same(fText), same(rText));
    ck(T('after a reload: same creature, turn, hand, bar'), [r.name, r.turn, r.hand, r.barText], [f.name, f.turn, f.hand, f.barText]);
  }
  console.log('newfight: done'); await b.close(); process.exit(fails ? 1 : 0);
})();
