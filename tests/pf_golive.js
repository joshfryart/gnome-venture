// 2.7.57 go-live check (tests/pf_golive.sh): on a fresh install with no puzzle settings written, a normal player walks a road until a creature, sees the 4-step intro,
// reopens it from the fight's help sheet, and plays the puzzle fight to its end in a 390 px browser. node tests/pf_golive.js BASE [SHOTDIR]
const { chromium } = require('playwright');
const [base, out] = process.argv.slice(2);
let fails = 0; const ck = (w, ok, got) => { console.log((ok ? 'ok   ' : 'FAIL ') + w + (ok ? '' : ' (got ' + JSON.stringify(got) + ')')); if (!ok) fails++; };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const p = await (await b.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2 })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error' && !/favicon|404/.test(m.text())) errs.push(m.text()); });
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  await p.evaluate(() => localStorage.setItem('pfvspd', '0'));
  const menu = await p.evaluate(() => !!document.querySelector('a[href*="puzzlebox.php"]'));
  ck('menu has the Puzzle box for a normal player', menu, menu);
  let helpDone = false, fightSeen = false, introShot = false, over = null, walks = 0, moves = 0;
  const shot = (n) => out ? p.screenshot({ path: out + '/' + n + '.png' }) : Promise.resolve();
  for (let i = 0; i < 160 && !over; i++) {
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }).catch(() => {});
    await p.waitForTimeout(400);
    const st = await p.evaluate(() => {
      const pfi = document.getElementById('pfi'); const d = document.getElementById('pf-data');
      return { url: location.pathname, intro: !!(pfi && !pfi.hidden), pre: !!document.getElementById('pfv-pre'), board: !!document.getElementById('pfb-board'),
        data: d ? (() => { try { return JSON.parse(d.textContent); } catch (e) { return null; } })() : null, res: !!document.getElementById('pfv-res'), end: !!document.getElementById('pf-end'),
        cont: !!document.querySelector('form:has(input[name=do][value=continue]) button'), route: !!document.querySelector('form:has(input[name=route_id]) button') };
    });
    if (st.intro) {
      if (!introShot) {
        introShot = true;
        for (let k = 0; k < 4; k++) { await shot('intro-step' + (k + 1)); const nx = p.locator('#pfi .pfi-next'); if (await nx.isVisible()) await nx.click(); await p.waitForTimeout(250); }
        const r = p.waitForResponse(r => r.request().method() === 'POST' && /pfi_seen/.test(r.request().postData() || ''), { timeout: 8000 }).catch(() => null);
        await p.click('#pfi .pfi-done'); const rr = await r;
        ck('intro: Got it sends the seen flag (204)', rr && rr.status() === 204, rr && rr.status());
        ck('intro: the card is gone and the fight is there', await p.evaluate(() => document.getElementById('pfi').hidden && (!!document.getElementById('pfb-board') || !!document.getElementById('pfv-pre'))), false);
      }
      continue;
    }
    if (st.pre) { fightSeen = true; await shot('prefight'); await Promise.all([p.waitForNavigation().catch(() => {}), p.click('#pfv-go')]); continue; }
    if (st.board && st.data) {
      if (!fightSeen) { fightSeen = true; await shot('fight-start'); console.log('fight vs ' + st.data.foe); }
      if (!helpDone) {   // the help sheet opens the intro again, in place; Esc closes it and the fight is still there
        helpDone = true;
        const hb = p.locator('[data-a="help"]').first();
        if (await hb.count()) {
          await hb.click(); await p.waitForTimeout(300);
          const again = p.locator('[data-pfintro]');
          ck('help sheet: has the intro link', await again.count() > 0, await again.count());
          if (await again.count()) { await again.first().click(); await p.waitForTimeout(300); ck('help sheet: the intro opens in place', await p.evaluate(() => !document.getElementById('pfi').hidden), false); await shot('intro-again'); await p.keyboard.press('Escape'); await p.waitForTimeout(200); ck('Esc closes the intro, the board stays', await p.evaluate(() => document.getElementById('pfi').hidden && !!document.getElementById('pfb-board')), false); }
        } else ck('help button on the fight page', false, 'none');
      }
      if (st.data.won) { over = st.data.won; await shot('fight-end'); break; }
      // one move: a hand piece on the first lit spot, then End turn / Confirm start
      const hand = p.locator('#pf-hand .pf-tile:not(.pfv-off)');
      if (await hand.count()) { await hand.first().click(); await p.waitForTimeout(400); }
      const lit = p.locator('.pfb-lit').first(); if (await lit.count()) { await lit.click(); await p.waitForTimeout(300); }
      const go = p.locator('#pf-go');
      if (await go.count() && await go.isEnabled()) {
        await Promise.all([p.waitForResponse(r => r.request().method() === 'POST', { timeout: 10000 }).catch(() => null), go.click()]);
        await p.waitForTimeout(500);
        const cw = p.locator('#pf-go'); if (await cw.count() && /sure|anyway|still/i.test(await cw.innerText().catch(() => ''))) await cw.click().catch(() => {});   // costly-spot ask
        moves++;
      } else { const ps = p.locator('#pf-pass'); if (await ps.count()) { await ps.click().catch(() => {}); await p.waitForTimeout(500); } }
      continue;
    }
    if (st.end || st.res) { over = 'result card'; await shot('fight-end'); break; }
    const other = await p.evaluate(() => { const bad = ['skip', 'later', 'start', 'trail_back', 'explore', 'logout', 'gather', 'rod', 'sight', 'trail_wander', 'trail_stance']; const f = [...document.querySelectorAll('main form, .box form, form.option')].find(f => { const d = f.querySelector('[name=do]'); const bt = f.querySelector('button'); return d && !bad.includes(d.value) && d.value !== 'continue' && bt && bt.offsetParent !== null; }); if (!f) return null; f.setAttribute('data-e2e', '1'); return f.querySelector('[name=do]').value; });
    if (other && !st.cont) { console.log('event: ' + other); await Promise.all([p.waitForNavigation().catch(() => {}), p.click('form[data-e2e="1"] button')]); continue; }
    if (st.cont) { await Promise.all([p.waitForNavigation().catch(() => {}), p.click('form:has(input[name=do][value=continue]) button')]); walks++; continue; }
    await p.goto(base + '/world.php', { waitUntil: 'networkidle' });
    const rt = p.locator('form:has(input[name=route_id]) button');
    if (await rt.count()) { await Promise.all([p.waitForNavigation().catch(() => {}), rt.first().click()]); continue; }
    console.log('stuck at', st.url); await shot('stuck'); break;
  }
  ck('a puzzle fight started for a normal player on a road', fightSeen, fightSeen);
  ck('the intro card showed on the first fight', introShot, introShot);
  ck('the fight was played to an end', !!over, over);
  console.log('walk steps ' + walks + ', fight moves ' + moves + ', end: ' + over);
  ck('no console errors', errs.length === 0, errs.slice(0, 5));
  await b.close(); process.exit(fails ? 1 : 0);
})().catch(e => { console.log('FAIL crash ' + e); process.exit(1); });
