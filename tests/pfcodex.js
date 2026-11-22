// 2.7.57 Creature Codex in a real browser at 390 px (tests/pfcodex.sh): the seen pieces are drawn by the game's renderer, nothing scrolls sideways, Esc closes the sheet.
// node tests/pfcodex.js BASE SLUG [SHOTDIR]
const { chromium } = require('playwright');
const [base, slug, shots] = process.argv.slice(2);
let fails = 0; const ck = (w, ok, got) => { console.log((ok ? 'ok   ' : 'FAIL ') + w + (ok ? '' : ' (got ' + JSON.stringify(got) + ')')); if (!ok) fails++; };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const p = await (await b.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2 })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  await p.goto(base + '/puzzlebox.php?t=codex', { waitUntil: 'networkidle' });
  const wide = () => p.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
  ck('codex grid: no sideways scroll at 390 px', (await wide()) <= 0, await wide());
  if (shots) await p.screenshot({ path: shots + '/codex-grid.png' });
  await p.goto(base + '/puzzlebox.php?t=codex&c=' + encodeURIComponent(slug), { waitUntil: 'networkidle' });
  await p.waitForSelector('.cx-pcs canvas.cx-cv', { timeout: 10000 }).catch(() => null);
  await p.waitForTimeout(600);
  const st = await p.evaluate(() => ({ drawn: document.querySelectorAll('.cx-pc.cx-drawn canvas.cx-cv').length, seen: document.querySelectorAll('.cx-pc:not(.cx-q):not(.cx-old)').length,
    blanks: document.querySelectorAll('.cx-pc.cx-q').length, focus: document.activeElement && document.activeElement.id, sheetW: document.getElementById('cx-sheet').scrollWidth - document.getElementById('cx-sheet').clientWidth }));
  ck('sheet: every seen piece is drawn on a canvas', st.drawn > 0 && st.drawn === st.seen, st);
  ck('sheet: unseen pieces are blanks', st.blanks > 0, st.blanks);
  ck('sheet: takes the focus', st.focus === 'cx-sheet', st.focus);
  ck('sheet: no sideways scroll inside it or on the page', st.sheetW <= 0 && (await wide()) <= 0, [st.sheetW, await wide()]);
  if (shots) { await p.screenshot({ path: shots + '/codex-sheet.png' }); await p.locator('#cx-sheet').screenshot({ path: shots + '/codex-sheet-full.png' }).catch(() => {}); }
  await Promise.all([p.waitForNavigation().catch(() => null), p.keyboard.press('Escape')]);
  ck('Esc closes the sheet (back on the grid, at the tile)', /t=codex/.test(p.url()) && !/c=/.test(p.url()) && /#cx-/.test(p.url()) && !(await p.$('#cx-sheet')), p.url());
  ck('no console errors', errs.length === 0, errs.slice(0, 4));
  await b.close(); process.exit(fails ? 1 : 0);
})().catch(e => { console.log('FAIL crash ' + e); process.exit(1); });
