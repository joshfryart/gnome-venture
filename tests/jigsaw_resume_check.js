// v2.0.87 E: Jigsaw save and resume in a real browser (called by tests/jigsaw.sh). node jigsaw_resume_check.js BASE SHOT_DIR
// Per viewport (desktop, phone): place pieces by scripted pointer events, reload, the library says Continue with the right progress, Continue brings back the same cuts,
// locked pieces, loose spots, a joined pair and the HUD time; a resumed solve calls neither pstart nor pfinish and the win card says so; a fresh go still records;
// Start over / Play again / a tier change clear the save; the #hash route resumes; blocked localStorage does not break play; 216 pieces serialize small.
const { chromium } = require('playwright');
const HELP = `
window.__pcs = [...document.querySelectorAll('#field .piece')];
window.__bd = () => document.getElementById('board').getBoundingClientRect();
window.__mk = (t, x, y) => new PointerEvent(t, { bubbles: true, cancelable: true, pointerId: 7, pointerType: 'mouse', button: 0, clientX: x, clientY: y, isPrimary: true });
window.__mv = (i, cx, cy) => { const el = __pcs[i], r = el.getBoundingClientRect(), f = document.getElementById('field');
  el.dispatchEvent(__mk('pointerdown', r.left + r.width / 2, r.top + r.height / 2)); f.dispatchEvent(__mk('pointermove', cx, cy)); f.dispatchEvent(__mk('pointerup', cx, cy)); };
window.__slot = (i, cols, rows) => { const b = __bd(); return [b.left + ((i % cols) + .5) * b.width / cols, b.top + (Math.floor(i / cols) + .5) * b.height / rows]; };
window.__place = (list, cols, rows) => { for (const i of list) { const s = __slot(i, cols, rows); __mv(i, s[0], s[1]); } };
window.__solve = (cols, rows) => { for (let i = 0; i < cols * rows; i++) if (!__pcs[i].classList.contains('locked')) { const s = __slot(i, cols, rows); __mv(i, s[0], s[1]); } };
window.__ctr = i => { const r = __pcs[i].getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height / 2]; };
window.__loose = (i, fx, fy) => { const b = __bd(); __mv(i, b.left + fx * b.width, b.bottom + fy); };
window.__locked = () => __pcs.map((e, i) => e.classList.contains('locked') ? i : -1).filter(x => x >= 0);
window.__cuts = () => __pcs.map(e => e.querySelector('.cut').style.clipPath).join('|');
window.__rel = i => { const b = __bd(), r = __pcs[i].getBoundingClientRect(); return [(r.left - b.left) / b.width, (r.top - b.top) / b.height]; };
`;
(async () => {
  const [base, shots] = process.argv.slice(2);
  const b = await chromium.launch({ executablePath: process.env.PW_CHROMIUM || undefined, args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  let fails = 0;
  const say = (ok, msg) => { if (!ok) fails++; console.log((ok ? 'ok   ' : 'FAIL ') + msg); };
  const login = async p => {
    await p.goto(base + '/login.php');
    await p.fill('input[name="username"]', 'sprout'); await p.fill('input[name="password"]', 'TestPass123!');
    await Promise.all([p.waitForNavigation({ waitUntil: 'load' }), p.press('input[name="password"]', 'Enter')]);
  };
  const pieces = (p, n) => p.waitForFunction(m => document.querySelectorAll('#field .piece').length === m, n, { timeout: 15000 }).catch(() => {});
  const ready = async (p, n) => { await pieces(p, n); await p.evaluate(HELP); };
  const hudT = async p => { const t = (await p.textContent('#hud')).split('·')[1].trim().split(':'); return (+t[0]) * 60 + (+t[1]); };
  const KEY = id => `jiggy.save.${id}.24`;
  for (const [tag, vp] of [['desktop', { width: 1280, height: 800 }], ['phone', { width: 360, height: 740 }]]) {
    const c = await b.newContext({ viewport: vp });
    const p = await c.newPage(); const errs = []; const calls = { pstart: 0, pfinish: 0 };
    p.on('pageerror', e => errs.push(String(e)));
    p.on('request', r => { if (r.method() === 'POST' && r.url().includes('puzzles_api.php')) { const d = r.postData() || ''; if (d.includes('do=pstart')) calls.pstart++; if (d.includes('do=pfinish')) calls.pfinish++; } });
    await login(p);
    await p.goto(base + '/jigsaw.php'); await p.evaluate(() => localStorage.clear());
    await p.reload();
    const card = () => p.locator('#grid .pzcard').first();
    const easy = () => card().locator('button[data-tier="easy"]');
    say(await card().locator('.pzover').count() === 0, `${tag}: no Start over link while nothing is saved`);
    await easy().click(); await ready(p, 24);
    const id = await p.evaluate(() => location.hash.slice(1).replace(/-24$/, ''));
    const sv = () => p.evaluate(k => localStorage.getItem(k), KEY(id));
    say(id.length > 0 && await sv() === null, `${tag}: a fresh table saves nothing yet (${id})`);

    // 1. five pieces to their slots, one loose piece, one joined loose pair
    const PL = [0, 5, 8, 17, 23];
    await p.evaluate(l => __place(l, 6, 4), PL);
    await p.evaluate(() => { __loose(10, .3, 70); __loose(12, .6, 70); const c = __ctr(12), pw = __bd().width / 6; __mv(13, c[0] + pw, c[1]); });
    say(calls.pstart === 1, `${tag}: a fresh go calls pstart once (${calls.pstart})`);
    say(await p.evaluate(() => __pcs[12].classList.contains('joined') && __pcs[13].classList.contains('joined')), `${tag}: the loose pair joined`);
    await p.waitForTimeout(2300);
    const before = await p.evaluate(() => ({ cuts: __cuts(), locked: __locked(), r10: __rel(10), r12: __rel(12), r13: __rel(13) }));
    const hud0 = await hudT(p);
    say(JSON.stringify(before.locked) === JSON.stringify(PL), `${tag}: 5 pieces locked (${before.locked})`);
    await p.waitForTimeout(450);   // the 400 ms debounce
    const raw = await sv(); say(!!raw && raw.length < 3000, `${tag}: saved on the drop, compact (${raw && raw.length} bytes)`);
    await p.reload();   // leave at once: pagehide also saves
    say((await p.evaluate(k => localStorage.getItem(k), KEY(id))) !== null, `${tag}: save survives the reload`);
    await p.goto(base + '/jigsaw.php');   // library, no hash
    const btn = easy();
    const bt = await btn.innerText();
    say(/Continue/.test(bt) && /5 \/ 24/.test(bt), `${tag}: library tier button reads Continue, 5 / 24 (${bt.replace(/\s+/g, ' ')})`);
    say(await card().locator('.pzover').count() === 1, `${tag}: a small Start over sits beside it`);
    say(!/Continue/.test(await card().locator('button[data-tier="advanced"]').innerText()), `${tag}: other tiers are not marked`);
    await p.screenshot({ path: `${shots}/jigsaw-resume-${tag}-library.png` });
    await btn.click(); await ready(p, 24);
    const after = await p.evaluate(() => ({ cuts: __cuts(), locked: __locked(), r10: __rel(10), r12: __rel(12), r13: __rel(13), sub: document.getElementById('sub').textContent, hud: document.getElementById('hud').textContent }));
    say(after.cuts === before.cuts, `${tag}: same cuts (same seed)` + (after.cuts === before.cuts ? '' : ` ${before.cuts.slice(0,160)} vs ${after.cuts.slice(0,160)}`));
    say(JSON.stringify(after.locked) === JSON.stringify(before.locked), `${tag}: same locked pieces (${after.locked})`);
    const near = (a, z) => Math.abs(a[0] - z[0]) < .004 && Math.abs(a[1] - z[1]) < .004;
    say(near(after.r10, before.r10) && near(after.r12, before.r12) && near(after.r13, before.r13), `${tag}: loose pieces are where they were`);
    say(await p.evaluate(() => __pcs[12].classList.contains('joined') && __pcs[13].classList.contains('joined')), `${tag}: the pair is still joined`);
    say(/Welcome back! Picking up where you left off\./.test(after.sub), `${tag}: welcome-back line (${after.sub})`);
    say(/^5 \/ 24/.test(after.hud), `${tag}: HUD shows 5 / 24 (${after.hud})`);
    const hud1 = await hudT(p);
    say(hud1 >= hud0 - 1 && hud1 <= hud0 + 2, `${tag}: HUD time restored, not counting time away (${hud0}s -> ${hud1}s)`);
    await p.waitForTimeout(1600);
    say(await hudT(p) === hud1, `${tag}: the clock waits for the first grab`);
    await p.screenshot({ path: `${shots}/jigsaw-resume-${tag}-resumed.png` });

    // 2. resumed solve: no pstart, no pfinish, win text says so, save cleared
    const ps0 = calls.pstart, pf0 = calls.pfinish;
    await p.evaluate(() => __solve(6, 4));
    await p.waitForTimeout(800);
    say(await p.locator('#win').isVisible(), `${tag}: resumed puzzle solved, win card shown`);
    const wt = await p.textContent('#winText');
    say(/Resumed goes don't set bests\./.test(wt) && /24 pieces in \d+:\d\d/.test(wt), `${tag}: win text (${wt})`);
    say(calls.pstart === ps0 && calls.pfinish === pf0, `${tag}: resumed go called neither pstart nor pfinish (${calls.pstart}/${calls.pfinish})`);
    say(await sv() === null, `${tag}: save cleared on solve`);

    // 3. Play again = a fresh go that still records
    await p.click('#again'); await p.waitForTimeout(300); await p.evaluate(HELP);
    await p.evaluate(() => __place([0], 6, 4)); await p.waitForTimeout(600);   // first grab: pstart answers before the solve
    await p.evaluate(() => __solve(6, 4));
    await p.waitForTimeout(1200);
    const wt2 = await p.textContent('#winText');
    say(calls.pstart === ps0 + 1 && calls.pfinish === pf0 + 1, `${tag}: a fresh go calls pstart + pfinish (${calls.pstart}/${calls.pfinish})`);
    say(!/Resumed/.test(wt2), `${tag}: fresh win text has no resumed note (${wt2})`);

    // 4. Start over (library link) clears the save and opens a fresh table
    await p.click('#again'); await p.waitForTimeout(300); await p.evaluate(HELP);
    await p.evaluate(() => __place([1, 2], 6, 4)); await p.waitForTimeout(500);
    await p.goto(base + '/jigsaw.php');
    say(/2 \/ 24/.test(await easy().innerText()), `${tag}: second save shows 2 / 24`);
    await card().locator('.pzover').first().click(); await ready(p, 24);
    say(await sv() === null && await p.evaluate(() => __locked().length) === 0, `${tag}: Start over clears the save and the table is fresh`);

    // 5. the Library button saves, the #hash route resumes
    await p.evaluate(() => __place([3, 4, 9], 6, 4));
    await p.click('#back'); await p.waitForTimeout(300);
    say(/3 \/ 24/.test(await easy().innerText()), `${tag}: Library button keeps the go (3 / 24)`);
    await p.goto(base + '/jigsaw.php#' + id + '-24'); await ready(p, 24);
    say(await p.evaluate(() => __locked().length) === 3 && /Welcome back/.test(await p.textContent('#sub')), `${tag}: #hash opens the saved go`);

    // 6. saved on one layout, resumed on the other
    const other = tag === 'desktop' ? { width: 360, height: 740 } : { width: 1280, height: 800 };
    await p.evaluate(() => __loose(10, .3, 70)); await p.waitForTimeout(500);
    await p.setViewportSize(other); await p.waitForTimeout(100);
    await p.reload(); await ready(p, 24);
    const lay = await p.evaluate(() => { const f = document.getElementById('field').getBoundingClientRect(); return { locked: __locked().length, out: __pcs.filter(e => !e.classList.contains('locked')).filter(e => { const r = e.getBoundingClientRect(); return r.left < f.left - 2 || r.right > f.right + 2 || r.top < f.top - 2 || r.bottom > f.bottom + 2; }).length }; });
    say(lay.locked === 3 && lay.out === 0, `${tag} -> ${other.width}px: 3 locked, loose pieces all inside the table (out=${lay.out})`);
    await p.setViewportSize(vp); await p.reload(); await ready(p, 24);

    // 7. a tier change forgets the old save
    say(await sv() !== null, `${tag}: save present before the tier change`);
    await p.selectOption('#count', '96'); await pieces(p, 96);
    say(await sv() === null && await p.locator('#field .piece').count() === 96, `${tag}: changing tier clears the old save and starts fresh`);
    say(errs.length === 0, `${tag}: no script errors ${errs.join(' | ')}`);
    await c.close();
  }

  // blocked storage: the page must still play
  {
    const c = await b.newContext({ viewport: { width: 1280, height: 800 } });
    await c.addInitScript(() => { const bad = () => { throw new Error('blocked'); }; try { Object.defineProperty(window, 'localStorage', { get: bad, configurable: true }); } catch (e) {} });
    const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e)));
    await login(p).catch(() => {});
    await p.goto(base + '/jigsaw.php');
    say(await p.locator('#grid .pzcard').count() >= 3, 'blocked storage: library still builds');
    await p.locator('#grid .pzcard').first().locator('button[data-tier="easy"]').click(); await ready(p, 24);
    await p.evaluate(() => __place([0, 1, 2, 7], 6, 4)); await p.waitForTimeout(600);
    say(await p.evaluate(() => __locked().length) === 4, 'blocked storage: pieces still lock');
    await p.click('#back'); await p.waitForTimeout(300);
    say(await p.locator('#grid .pzcard').count() >= 3 && await p.locator('.pzover').count() === 0, 'blocked storage: Library button works, nothing to continue');
    await p.locator('#grid .pzcard').first().locator('button[data-tier="easy"]').click(); await ready(p, 24);
    await p.evaluate(() => __solve(6, 4)); await p.waitForTimeout(500);
    say(await p.locator('#win').isVisible(), 'blocked storage: a whole puzzle can be solved');
    say(errs.length === 0, `blocked storage: no script errors ${errs.join(' | ')}`);
    await c.close();
  }

  // size: 216 loose singletons are the biggest save
  {
    const c = await b.newContext({ viewport: { width: 1280, height: 800 } });
    const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e)));
    await login(p); await p.goto(base + '/jigsaw.php'); await p.evaluate(() => localStorage.clear());
    await p.locator('#grid .pzcard').first().locator('button[data-tier="expert"]').click(); await ready(p, 216);
    await p.evaluate(() => __loose(0, .3, 70)); await p.waitForTimeout(600);
    const len = await p.evaluate(() => { const k = Object.keys(localStorage).find(x => /^jiggy\.save\..*\.216$/.test(x)); return k ? localStorage.getItem(k).length : -1; });
    say(len > 0 && len < 60000, `216 pieces, all loose: save is ${len} bytes (< 60000)`);
    await p.evaluate(() => __place([...Array(150).keys()], 18, 12)); await p.waitForTimeout(600);
    const len2 = await p.evaluate(() => { const k = Object.keys(localStorage).find(x => /^jiggy\.save\..*\.216$/.test(x)); return k ? localStorage.getItem(k).length : -1; });
    say(len2 > 0 && len2 < 60000, `216 pieces, 150 locked: save is ${len2} bytes`);
    await p.reload(); await ready(p, 216);
    say(await p.evaluate(() => __locked().length) >= 150, 'expert: 150+ pieces still locked after a reload');
    say(errs.length === 0, `expert: no script errors ${errs.join(' | ')}`);
    await c.close();
  }
  await b.close();
  process.exit(fails ? 1 : 0);
})();
