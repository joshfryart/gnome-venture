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
    let inplaceOk = true;
    if (label === 'board-1' || label === 'wander-board') {   // End turn goes through the in-place page swap: the board and the hand art must come back after it
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
    const bad = (!over || !mapIn || !panel || !overlap || wide || errs.length || !zoomOk || !inplaceOk || (want === 'fx' && !glow && !stamp)) ? 1 : 0; fail = fail || bad;
    console.log(bad ? 'FAIL' : 'ok', label, name, '| fight over map', !!over, '| map behind', overlap, '| art bar', art, '| glow', glow, '| stamps', stamp, '| expiring cues', await p.locator('.pfb-old').count(), '| foe drops', await p.locator('.pfb-drop').count(), '| zoom', zoomOk, '| after in-place turn', inplaceOk, '| overflow', wide, '| js errors:', errs.length ? errs.join(' | ') : 'none');
    await c.close();
  }
  await b.close(); process.exit(fail);
})();
