// Browser check for the villager overlay (run by folkoverlay.sh). Prints "OVERLAY OK" or what went wrong.
const { chromium } = require('playwright');
(async () => {
  const base = process.env.BASE, fid = process.env.FID;
  const b = await chromium.launch(); const ctx = await b.newContext({ viewport: { width: 412, height: 900 } });
  const page = await ctx.newPage();
  const bad = [];
  page.on('pageerror', e => bad.push('pageerror ' + e.message));
  await page.goto(base + '/login.php');
  await page.fill('input[name=username]', 'sprout'); await page.fill('input[name=password]', 'TestPass123!');
  await page.click('button:has-text("Log in")'); await page.waitForLoadState('load');
  if (process.env.MODE === 'npc') {   // main-stop townsfolk: a name or Chat opens the overlay with the full-page link, no navigation
    await page.goto(base + '/town.php?view=villagers');
    const link = page.locator('[data-folk-npc]').first();
    if (!(await link.count())) { console.log('OVERLAY OK (no townsfolk about right now, npc part skipped)'); await b.close(); return; }
    const u0 = page.url();
    await link.click();
    await page.waitForSelector('dialog.folkdlg[open] .vpanel, dialog.folkdlg[open] .vmsg');
    if (process.env.SHOT) await page.screenshot({ path: process.env.SHOT });
    if (page.url() !== u0) bad.push('page navigated to ' + page.url());
    if (!(await page.locator('dialog.folkdlg[open] .folkfoot a[href*="villagers.php?id="]').count())) bad.push('no full-page link');
    await page.keyboard.press('Escape');
    if (await page.locator('dialog.folkdlg[open]').count()) bad.push('still open after Esc');
    await b.close();
    console.log(bad.length ? 'OVERLAY FAIL: ' + bad.join('; ') : 'OVERLAY OK (npc)');
    return;
  }
  await page.goto(base + '/town.php?t=folk');
  const url0 = page.url();
  await page.click('[data-folk-stop="' + fid + '"]');
  await page.waitForSelector('dialog.folkdlg[open] .vpanel');
  if (page.url() !== url0) bad.push('page navigated to ' + page.url());
  if (!(await page.locator('dialog.folkdlg[open] button:has-text("Say hello")').count())) bad.push('no Say hello in overlay');
  if (process.env.SHOT) await page.screenshot({ path: process.env.SHOT });
  await page.click('dialog.folkdlg[open] button:has-text("Say hello")');
  await page.waitForSelector('dialog.folkdlg[open] .vmsg.ok');
  if (!(await page.locator('dialog.folkdlg[open] button:has-text("Chatted today")').count())) bad.push('chat button did not change');
  if (page.url() !== url0) bad.push('page navigated after chat');
  // gift: open the picker, pick the first item, give
  await page.evaluate(() => {});
  const giftBtn = page.locator('dialog.folkdlg[open] [data-giftopen]');
  if (await giftBtn.count()) {
    await giftBtn.click();
    await page.waitForSelector('dialog.giftpick[open] .gcard');
    await page.click('dialog.giftpick[open] .gcard');
    await page.click('dialog.giftpick[open] .giftgo button');
    await page.waitForSelector('dialog.folkdlg[open] .vmsg.ok:has-text("grateful")');
    if (!(await page.locator('dialog.folkdlg[open] :text("Gift given today")').count())) bad.push('gift not marked done');
  } else bad.push('no gift button (satchel empty?)');
  await page.keyboard.press('Escape');
  await page.waitForNavigation({ timeout: 5000 }).catch(() => {});   // closing after a change reloads the page
  if (await page.locator('dialog.folkdlg[open]').count()) bad.push('overlay still open after Esc');
  await b.close();
  console.log(bad.length ? 'OVERLAY FAIL: ' + bad.join('; ') : 'OVERLAY OK');
})().catch(e => { console.log('OVERLAY FAIL: ' + e.message); process.exit(0); });
