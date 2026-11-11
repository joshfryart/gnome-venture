// node tests/pfmap.js BASE OUTDIR LABEL : a puzzle fight drawn ON the route map (phone + wide): the map is behind the panel, nothing overflows, a piece can be placed (board) or played (strip), no JS errors.
const { chromium } = require('playwright');
(async () => {
  const [base, out, label, want] = process.argv.slice(2);
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  let fail = 0;
  for (const [name, vp] of [['phone', { width: 412, height: 900 }], ['wide', { width: 1280, height: 800 }]]) {
    const c = await b.newContext({ viewport: vp, deviceScaleFactor: 1, hasTouch: name === 'phone' }); const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' });
    const wanderMode = label.startsWith('wander');
    const over = wanderMode ? 1 : await p.locator('.advgrid.pfover').count(), mapIn = wanderMode ? 1 : await p.locator('.advgrid.pfover .mapcol').count(), panel = await p.locator('#pfight').count();
    const box = async (sel) => p.locator(sel).first().boundingBox().catch(() => null);
    const m = await box('.advgrid.pfover .mapcol'), f = await box('#pfight');
    const overlap = wanderMode || !!(m && f && f.x < m.x + m.width && f.x + f.width > m.x && f.y < m.y + m.height && f.y + f.height > m.y);
    // the replay of the last turn: the piece being scored is lit, its line is listed; Skip ends it
    const replaying = await p.locator('#pfight.pf-playing').count(); let scoring = 0, lines = 0;
    if (replaying) { await p.waitForSelector('.pfb-scoring', { timeout: 4000 }).then(() => { scoring = 1; }, () => {}); lines = await p.locator('#pf-play li').count(); await p.click('#pf-skip'); await p.waitForTimeout(400); }
    const panelH = await p.evaluate(() => { const e = document.getElementById('pfight'); return e ? Math.round(e.getBoundingClientRect().height) : 0; });   // on a phone the whole fight fits one screen
    const art = await p.locator('.pfx-bar').count();
    const glow = await p.locator('.pfb-glow').count(), stamp = await p.locator('.pfb-stamp').count();
    let zoomOk = true;
    if (label.startsWith('board') || label === 'fx' || label === 'wander-board') {   // wheel zoom, the buttons, reset
      const bb = await p.locator('#pfb-board').boundingBox();
      await p.mouse.move(bb.x + bb.width / 2, bb.y + bb.height / 2); await p.mouse.wheel(0, -300); await p.waitForTimeout(80);
      const t1 = await p.evaluate(() => document.querySelector('.pfb-world').style.transform), z1 = await p.locator('.pfb-zoomed').count();
      await p.locator('.pfb-zoom button').nth(2).click(); const t2 = await p.evaluate(() => document.querySelector('.pfb-world').style.transform);
      await p.locator('.pfb-zoom button').first().click(); const t3 = await p.evaluate(() => document.querySelector('.pfb-world').style.transform);
      zoomOk = /scale/.test(t1) && z1 === 1 && t2 === '' && /scale/.test(t3);
      await p.locator('.pfb-zoom button').nth(2).click();
      if (name === 'phone') {   // a real two-finger pinch (touch events from the browser itself), then a one-finger drag to pan
        const cdp = await c.newCDPSession(p), cx = bb.x + bb.width / 2, cy = bb.y + bb.height / 2;
        const touch = (type, pts) => cdp.send('Input.dispatchTouchEvent', { type, touchPoints: pts.map((q, id) => ({ x: q[0], y: q[1], id })) });
        await touch('touchStart', [[cx - 20, cy], [cx + 20, cy]]);
        for (let k = 1; k <= 8; k++) await touch('touchMove', [[cx - 20 - k * 8, cy], [cx + 20 + k * 8, cy]]);
        await touch('touchEnd', []); await p.waitForTimeout(100);
        const pz = await p.evaluate(() => document.querySelector('.pfb-world').style.transform);
        zoomOk = zoomOk && /scale/.test(pz);
        await touch('touchStart', [[cx, cy]]); for (let k = 1; k <= 6; k++) await touch('touchMove', [[cx + k * 6, cy + k * 3]]); await touch('touchEnd', []); await p.waitForTimeout(100);
        const pz2 = await p.evaluate(() => document.querySelector('.pfb-world').style.transform);
        zoomOk = zoomOk && pz2 !== pz;
        await p.locator('.pfb-zoom button').nth(2).click();
      }
    }
    let inplaceOk = true, tapOk = true, connectOk = true, connectNote = '';
    if (label === 'board-1' && name === 'phone') {   // (the heavy turns happen once, on the phone; the wide pass only looks at what is left)
      // tap a piece on the board: its card opens (name and text)
      const tap = p.locator('.pfb-tap').first();
      if (await tap.count()) { await tap.click(); tapOk = (await p.locator('#pfi-name').textContent()).trim().length > 0 && !(await p.locator('#pf-inspect').isHidden()); }
      // set aside: select a piece, take one of its "set aside with" choices (no mode, no extra button), end the turn; then play the group
      const hand = p.locator('#pf-hand .pf-tile'); const n = await hand.count(); let joined = false;
      for (let a = 0; a < n && !joined; a++) {
        await hand.nth(a).click({ position: { x: 10, y: 26 } });
        if (await p.locator('#pf-opts:not([hidden]) .pf-chipbtn').count()) { await p.locator('#pf-opts .pf-chipbtn').first().click(); joined = await p.locator('#pf-go').isEnabled(); }
        if (!joined) await p.click('#pf-undo');
      }
      if (joined) {
        const chip = await p.locator('.pf-held-chip.pf-planned').count();   // the panel shows the planned group at once
        await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pf-go')]); await p.waitForTimeout(1800);
        if (await p.locator('#pf-skip:not([hidden])').count()) await p.click('#pf-skip');
        connectOk = chip === 1 && (await p.locator('.pf-held-chip:not(.pf-planned)').count()) === 1;
        if (connectOk) {
          await p.click('.pf-held-chip'); const spots = await p.locator('.pfb-lit').count(); connectOk = spots > 0;
          if (spots) { await p.locator('.pfb-lit').first().click(); await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pf-go')]); await p.waitForTimeout(1800); if (await p.locator('#pf-skip:not([hidden])').count()) await p.click('#pf-skip'); connectOk = (await p.locator('.pf-held-chip').count()) === 0; }
        }
      } else connectNote = 'no joinable pair';
    }
    if ((label === 'board-1' && name === 'phone') || label === 'wander-board') {   // End turn goes through the in-place page swap: the board and the hand art must come back after it
      const hand = p.locator('#pf-hand .pf-tile'); const n = await hand.count(); let lit = 0;
      for (let i = 0; i < n && !lit; i++) { await hand.nth(i).click({ position: { x: 10, y: 30 } }); lit = await p.locator('.pfb-lit').count(); }
      if (lit) {
        try { await p.locator('.pfb-lit').first().click({ timeout: 4000 }); } catch (e) { await p.screenshot({ path: out + '/dbg-lit.png', fullPage: true }); throw e; }
        const gb = await p.locator('#pf-go').boundingBox(); const hit = await p.evaluate(([x, y]) => { const e = document.elementFromPoint(x, y); return e ? e.tagName + '.' + e.className : 'none'; }, [gb.x + gb.width / 2, gb.y + gb.height / 2]); if (!/pf-go|btn/.test(hit)) console.log('END TURN COVERED BY', hit);
        await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pf-go')]); await p.waitForTimeout(1500);
        const over2 = await p.locator('#pfight').count();
        if (over2) { const cv = await p.locator('.pfb-cv').count(), art2 = await p.locator('.pf-art2').count(); inplaceOk = cv > 0 && art2 > 0; }
      }
    }
    if (await p.locator('#pfight').count()) await p.locator('#pfight').screenshot({ path: out + '/pfmap-' + label + '-' + name + '.png' });
    const wide = await p.evaluate(() => document.documentElement.scrollWidth > window.innerWidth);
    const bad = (!over || !mapIn || !panel || !overlap || wide || errs.length || (name === 'phone' && !label.startsWith('chain') && panelH > 520) || !zoomOk || !inplaceOk || !tapOk || !connectOk || (replaying && !scoring) || (want === 'fx' && !glow && !stamp)) ? 1 : 0; fail = fail || bad;
    console.log(bad ? 'FAIL' : 'ok', label, name, '| fight over map', !!over, '| map behind', overlap, '| art bar', art, '| glow', glow, '| stamps', stamp, '| expiring cues', await p.locator('.pfb-old').count(), '| foe drops', await p.locator('.pfb-drop').count(), '| replay', replaying ? (scoring ? 'lit ' + lines + ' lines' : 'NOT LIT') : 'none', '| panel', panelH + 'px', '| tap info', tapOk, '| connect+group', connectOk, connectNote, '| zoom', zoomOk, '| after in-place turn', inplaceOk, '| overflow', wide, '| js errors:', errs.length ? errs.join(' | ') : 'none');
    await c.close();
  }
  await b.close(); process.exit(fail);
})();
