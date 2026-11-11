// node tools/pfartifact/test_aside.js BUILT.html : set pieces aside, end the turn, in the same browser session for 3 fights: the creature's turn must play every time (regression: a fixed nonce made the replay key repeat).
const { chromium } = require('playwright');
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] });
  const ctx = await b.newContext({ viewport: { width: 400, height: 900 } }); const p = await ctx.newPage(); const errs = [];
  p.on('pageerror', e => errs.push(String(e)));
  const res = [];
  for (let round = 0; round < 3; round++) {   // the same browser session, several fights: every set-aside turn must replay the creature's turn
    await p.goto('file://' + (process.argv[2] || '/tmp/claude-0/art4.html') + ''); await p.waitForSelector('.pfb-cv'); await p.waitForTimeout(600);
    const hand = p.locator('#pf-hand .pf-tile'); const n = await hand.count(); let joined = false;
    for (let i = 0; i < n && !joined; i++) { await hand.nth(i).click({ position: { x: 8, y: 26 } }); if (await p.locator('#pf-opts:not([hidden]) .pf-chipbtn').count()) { await p.locator('#pf-opts .pf-chipbtn').first().click(); joined = true; } else await p.click('#pf-undo'); }
    if (!joined) { res.push('no join'); continue; }
    await p.click('#pf-go');
    const foeBanner = await p.waitForSelector('.pf-turn-foe', { timeout: 5000 }).then(() => 1, () => 0);
    const foeChips = await p.locator('.pf-chip.foe').count();
    res.push({ foeBanner, foeChips }); if (round === 0) await p.screenshot({ path: '/tmp/claude-0/demo-aside.png', fullPage: true });
  }
  console.log(JSON.stringify({ res, errs })); await b.close();
})();
