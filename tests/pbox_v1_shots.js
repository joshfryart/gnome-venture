// 2.6.74 stage C: the browser pass over the v1 pages at phone width (390px), light and dark. Run by tests/pbox_v1.sh on its installed copy:
//   node tests/pbox_v1_shots.js BASE OUTDIR GAMEDIR TESTSDIR
// Every new screen and state is opened with seeded data (tests/pbox_v1_seed.php), checked (what must be on it, no sideways overflow, no console errors) and saved as a picture.
// Prints "ok ..." / "FAIL ..." lines and "shots: done" at the end.
const { chromium } = require('playwright');
const { execSync } = require('child_process');
const [base, out, game, here] = process.argv.slice(2);
const seed = (...a) => execSync(`php -d display_errors=1 ${here}/pbox_v1_seed.php ${game} ${a.join(' ')}`).toString().trim();
const sql = (q) => execSync(`php -r '$p=new PDO("sqlite:${game}/data/game.sqlite"); $p->exec($argv[1]);' ${JSON.stringify(q)}`);
let fails = 0;
const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { console.log(`FAIL ${what} (got ${g}, want ${w})`); fails++; } };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  for (const theme of ['light', 'dark']) {
    sql(`UPDATE users SET theme='${theme}' WHERE username='sprout'`);
    const c = await b.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2 });
    const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
    const T = (s) => `${theme}: ${s}`;
    const shot = async (name, full = true) => { await p.screenshot({ path: `${out}/${name}-${theme}.png`, fullPage: full }); const over = await p.evaluate(() => document.documentElement.scrollWidth > window.innerWidth + 1); if (over) { console.log(`FAIL ${T(name)}: the page scrolls sideways`); fails++; } };
    const speed = (v) => p.evaluate((x) => { try { localStorage.setItem('pfvspd', x); } catch (e) {} }, String(v));
    const open = async (path) => { await p.goto(base + path, { waitUntil: 'networkidle' }); await p.waitForFunction(() => !document.querySelector('.pfv i.cvh') || !(window.PFParts), null, { timeout: 5000 }).catch(() => {}); await p.waitForTimeout(350); };
    const n = (sel) => p.locator(sel).count();
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
    await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    ck(T('the site theme is ' + theme), await p.evaluate(() => document.documentElement.getAttribute('data-theme')), theme);

    // ---- 1. the starter pick (the deck is forgotten first), through the page
    sql('UPDATE expeditions SET encounter=NULL'); sql('DELETE FROM pf_deck_pieces'); sql('DELETE FROM pf_decks'); sql('DELETE FROM pf_belts');
    await open('/puzzlebox.php');
    ck(T('starter: 12 pieces on offer are drawn (canvas), Pack is off until 6 are picked'), [await n('#pfv-offer .pc canvas'), await p.isDisabled('#pfv-sgo')], [12, true]);
    await p.click(theme === 'light' ? '[data-kit]:nth-of-type(1)' : '[data-kit]:nth-of-type(2)'); await p.waitForTimeout(150);
    ck(T('starter: a kit in one tap fills the 6 slots; the Hurt chip is good; Pack is on'), [await n('#pfv-tray .pfv-ps .pc'), await n('#pfv-hurt.good'), await p.isDisabled('#pfv-sgo'), await p.locator('#pfv-n').innerText()], [6, 1, false, '10']);
    await p.locator('#pfv-offer .pc.off').first().click();
    ck(T('starter: a seventh piece is refused with a line'), /box is full/.test(await p.locator('#pfv-info').innerText()), true);
    await shot('1-starter');
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pfv-sgo')]); await p.waitForTimeout(900);
    ck(T('starter: packed, the Puzzle box opens'), await n('#pfv-box'), 1);

    // ---- 2. the Puzzle box
    await open('/puzzlebox.php');
    const kitN = await n('.pfv-g .pc.sel');
    await p.locator('.pfv-g .pc.sel').nth(5).click();
    ck(T('box: a tapped piece shows its detail line with a Take out button'), [await n('#pfv-info [data-pfv-act]'), /stays \d rounds/.test(await p.locator('#pfv-info').innerText())], [1, true]);
    await shot('2-box-kit');
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pfv-info [data-pfv-act]')]); await p.waitForTimeout(900);
    ck(T('box: Take out updates the page in place (one piece fewer in the kit)'), await n('.pfv-g .pc.sel'), kitN - 1);
    await p.click('#pfv-filt [data-g=crop]'); await p.waitForTimeout(100);
    ck(T('box: the crop filter leaves only crop pieces'), await p.evaluate(() => [...document.querySelectorAll('.pfv-g > li[data-g]')].filter(li => !li.hidden).every(li => li.dataset.g === 'crop')), true);
    await open('/puzzlebox.php?t=belt'); ck(T('belt: durability bars are sized by the script'), await p.evaluate(() => [...document.querySelectorAll('.pfv .dur i')].some(i => i.style.width && i.style.width !== '0%')), true); 
    ck(T('belt: the tools are buttons in a grid (no long list)'), [await n('#pfv-tools .tb') >= 4, await n('.pfv .toolrow'), await p.evaluate(() => { const b = [...document.querySelectorAll('#pfv-tools .tb')].map(x => x.getBoundingClientRect()); return b[0].top === b[1].top && b[1].top === b[2].top; })], [true, 0, true]);
    await p.locator('#pfv-tools .tb.on').first().click(); await p.waitForTimeout(100);
    ck(T('belt: a tapped tool shows its line with Take off'), [/durability \d+\/\d+/.test(await p.locator('#pfv-info').innerText()), await n('#pfv-info [data-pfv-tool][data-do=pfd_unequip]')], [true, 1]);
    await shot('2-box-belt');
    const onN = await n('#pfv-tools .tb.on');
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pfv-info [data-pfv-tool][data-do=pfd_unequip]')]); await p.waitForTimeout(900);
    ck(T('belt: Take off works in place (one tool fewer on the belt, the tab is kept)'), [await n('#pfv-tools .tb.on'), await n('.pfv .tabs a.on[href*="t=belt"]')], [onN - 1, 1]);
    await p.locator('#pfv-tools .tb:not(.on):not(.broken)').first().click(); await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pfv-info [data-pfv-tool][data-do=pfd_equip]')]); await p.waitForTimeout(900);
    ck(T('belt: Put on works in place'), await n('#pfv-tools .tb.on'), onN);
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pfv-auto')]); await p.waitForTimeout(900);
    ck(T('box: the auto-use switch works in place (on), and off again'), await p.isChecked('#pfv-auto'), true);
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pfv-auto')]); await p.waitForTimeout(900);
    await open('/puzzlebox.php?t=pals'); await shot('2-box-pals');

    // ---- 3. the pre-fight screen: auto off (free swaps), auto on (read-only)
    seed('fight', 'medium'); await open('/adventure.php');
    await p.locator('#pfv-pre .pc.L-uni').first().click(); await p.locator('#pfv-pre .pc[data-a=tog]').nth(2).click();
    ck(T('pre-fight, auto off: creature piece detail, a deck piece offers Take out, a bench is there'), [/plays ×2/.test(await p.locator('#pfv-cinfo').innerText()), await n('#pfv-info [data-pfv-act]'), await p.locator('#pfv-pre').innerText().then(t => /BENCH/i.test(t))], [true, 1, true]);
    await shot('3-prefight-auto-off');
    seed('fight', 'boss', 'auto'); await open('/adventure.php');
    ck(T('pre-fight, auto on: one strip (N pieces), Turn off and edit, no swaps, the deck in a closed fold, Let\'s fight on screen'), [/Auto deck is active: \d+ pieces/.test(await p.locator('#pfv-info').innerText()), await n('#pfv-pre .pc[data-a=tog]'), await p.evaluate(() => document.getElementById('pfv-deckfold').open), await p.evaluate(() => { const r = document.getElementById('pfv-go').getBoundingClientRect(); return r.top >= 0 && r.bottom <= innerHeight; }), await p.locator('#pfv-deckfold .pc').first().isVisible()], [true, 0, false, true, false]);
    await p.click('#pfv-deckfold summary'); ck(T('pre-fight, auto on: Show deck opens the read-only deck'), await p.locator('#pfv-deckfold .pc').first().isVisible(), true); await p.click('#pfv-deckfold summary');
    await shot('3-prefight-auto-on');
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pfv-go')]); await p.waitForTimeout(1500);
    await p.waitForSelector('#pfb-board .gc', { timeout: 8000 }).catch(() => {});
    ck(T('Let\'s fight: the board of a boss (7 by 6 cells), no ground cells, two face-up environment pieces in the strip'), [await n('#pfb-board .gc'), await n('#pfb-board .gc[data-ter]'), await n('#pfv-legend .envp'), await n('#pfv-legend [data-ter]')], [42, 0, 2, 0]);
    await shot('4-fight-opening');

    // ---- 4. the fight: a seeded position with ground, a forecast, the aim and hand pieces that cannot be played
    await speed(0); let st = null;
    for (const sd of [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26]) {   // the deck differs with the kit that was packed: take the first seeded position that shows everything
      seed('fight', 'large'); seed('midfight', String(sd), '3', 'soft'); await open('/adventure.php'); await p.waitForTimeout(500);
      st = await pos(); if (st.off >= 1 && st.off < 5 && st.envp >= 1 && st.aim === 1 && st.ground === 0) break;
    }
    async function pos() { return p.evaluate(() => ({ ground: document.querySelectorAll('#pfb-board .gc[data-ter]').length, marks: document.querySelectorAll('#pfb-board .mk.ev').length, legendTer: document.querySelectorAll('#pfv-legend [data-ter]').length, evchips: document.querySelectorAll('#pfv-row .tg.ev').length,
      envp: document.querySelectorAll('#pfv-legend .envp').length, envOnBoard: document.querySelectorAll('#pfb-board .pfb-cell.pfb-env').length, envBadge: document.querySelectorAll('#pfb-board .pfb-cell.pfb-env .pfv-eb').length, envPips: document.querySelectorAll('#pfb-board .pfb-cell.pfb-env .xp').length,
      aim: document.querySelectorAll('#pfb-board .mk.aim').length, off: document.querySelectorAll('#pf-hand .pfv-off').length, pips: document.querySelectorAll('#pf-hand .pf-tile .xp').length, aimchip: document.querySelectorAll('#pfv-row .tg.aim').length,
      team: document.querySelectorAll('#pfv-row .tg.team').length, envchips: document.querySelectorAll('.pf-chip.env').length, lifepips: document.querySelectorAll('#pfb-board .pfb-cell .xp').length > 0 })); }
    ck(T('fight: no ground cells, legend or forecast marks; the Next strip shows 2 face-up environment pieces; environment pieces on the board with a badge and life pips; the aim marker, Teamwork chip, life pips'),
      [st.ground, st.marks, st.legendTer, st.evchips, st.envp, st.envOnBoard >= 1, st.envBadge === st.envOnBoard, st.envPips === st.envOnBoard, st.aim, st.aimchip, st.team, st.pips > 0], [0, 0, 0, 0, 2, true, true, true, 1, 1, 1, true]);
    ck(T('fight: some hand pieces cannot be played here and are faded'), st.off >= 1 && st.off < 5, true);
    ck(T('fight: a faded piece is 38% and grey'), await p.evaluate(() => { const s = getComputedStyle(document.querySelector('#pf-hand .pfv-off')); return [s.opacity, /grayscale/.test(s.filter)]; }), ['0.38', true]);
    // the faded pieces are exactly the ones the server has no lit cell for (flipped or not)
    const srv = await p.evaluate(async () => { const f = document.getElementById('pf-form'), q = k => f.querySelector('[name=' + k + ']').value, o = []; const tiles = [...document.querySelectorAll('#pf-hand .pf-tile')];
      for (let i = 0; i < tiles.length; i++) { const fd = new FormData(); fd.append('csrf', q('csrf')); fd.append('do', 'pfb_cells'); fd.append('nonce', q('nonce')); fd.append('turn', q('turn')); fd.append('i', String(i));
        const j = await (await fetch(location.pathname, { method: 'POST', body: fd, credentials: 'same-origin', headers: { 'X-Requested-With': 'pfpreview' } })).json(); o.push(tiles[i].classList.contains('pfv-off') === (Object.keys(j.cells || {}).length + Object.keys(j.flipped || {}).length === 0)); } return o; });
    ck(T('fight: faded = the server has no spot for the piece, flipped or not'), srv.every(Boolean), true);
    await p.locator('#pf-hand .pfv-off').first().click({ force: true }); await p.waitForTimeout(150);
    ck(T('fight: a faded piece says why and is not picked'), [/cannot be played: /.test(await p.locator('#pf-preview').innerText()), await n('#pf-hand .pf-picked')], [true, 0]);
    await shot('4-fight-faded-hand');
    await p.locator('#pfv-legend [data-en="0"]').click(); await p.waitForTimeout(150);
    ck(T('fight: a Next-strip piece opens its popover (name, what it does in words, who gets it)'), await p.locator('.pfv-pop').innerText().then(t => [/Goes to whoever fires it/.test(t), /you or the creature|your chain/.test(t)]), [true, true]);
    await shot('4-fight-env-popover');
    await p.click('.pfv-popx');
    const ecol = await p.evaluate(() => { const c = document.querySelector('#pfb-board .pfb-cell.pfb-env'); if (!c) return null; c.click(); return c.getAttribute('aria-label'); }); await p.waitForTimeout(150);
    ck(T('fight: an environment piece on the board says it is the environment\'s and opens its card'), [/^Environment piece: /.test(ecol || ''), /belongs to nobody/.test(await p.locator('#pf-inspect').innerText())], [true, true]);
    await p.click('#pfi-x').catch(() => {});
    await p.click('#pfv-legend [data-a=turn]'); await p.waitForTimeout(100);
    ck(T('fight: the Environment chip explains the round and the environment turn'), await p.locator('.pfv-pop').innerText().then(t => [/you, the creature, then the environment/.test(t), /two pieces|2 pieces/.test(t), /belong to nobody/.test(t)]), [true, true, true]);
    await p.click('#pfv-legend [data-a=help]'); await p.waitForTimeout(200);
    ck(T('fight: the ? help covers the environment turn, the aim, chains, flip and the six environment pieces'), await p.locator('.pfv-sheet').innerText().then(t => ['Environment turn', 'aim', 'Chains', 'Flip', 'Sun', 'Bramble', 'Rain', 'Wind', 'Mud', 'Thornburst', 'whoever fires it', 'Animation speed'].every(w => t.toLowerCase().includes(w.toLowerCase()))), true);
    await shot('4-fight-help', false);
    await p.keyboard.press('Escape'); ck(T('fight: Escape closes the help'), await n('.pfv-sheet'), 0);
    const pi = await p.evaluate(() => [...document.querySelectorAll('#pf-hand .pf-tile')].findIndex(t => !t.classList.contains('pfv-off')));
    await p.locator('#pf-hand .pf-tile').nth(pi).click(); await p.waitForTimeout(900);
    ck(T('fight: a playable piece lights its spots with numbers, without a reply number; Flip is on'), [await n('#pfb-board .pfb-lit') > 0, await n('#pfb-board .pfb-lit .pfb-num') > 0, await p.locator('#pfb-board').innerText().then(t => t.includes('↩')), await p.isDisabled('#pf-flip')], [true, true, false, false]);
    await shot('4-fight-lit-spots');
    // 2.6.75 regression (Josh: "Flip reloads the page and does nothing"): the flip happens on the page itself. No navigation, the fight element is the same node, the piece is drawn again with top and bottom swapped,
    // the server has it flipped, the lit spots are asked for again, the other pieces say the flip is used.
    const before = await p.evaluate((i) => { const f = document.getElementById('pfight'); f.__same = 1; window.__navmark = 1; const t = document.querySelectorAll('#pf-hand .pf-tile')[i]; return { art: t.querySelector('.pfh-cv').toDataURL(), lit: [...document.querySelectorAll('#pfb-board .pfb-lit')].map(c => c.dataset.x + ',' + c.dataset.y).join(' ') }; }, pi);
    let navs = 0; const onNav = (f) => { if (f === p.mainFrame()) navs++; }; p.on('framenavigated', onNav);
    const [flipReq] = await Promise.all([p.waitForRequest(r => r.method() === 'POST' && /do"\s*\r?\n\r?\npfb_flip|do=pfb_flip/.test(r.postData() || '')), p.click('#pf-flip')]);
    ck(T('flip: the piece turns over (the animation class is on it once the answer is in)'), await p.waitForFunction((i) => document.querySelectorAll('#pf-hand .pf-tile')[i].classList.contains('pfv-flipping'), pi, { timeout: 3000, polling: 'raf' }).then(() => true).catch(() => false), true);
    await p.waitForTimeout(1200);
    const after = await p.evaluate((i) => { const f = document.getElementById('pfight'), t = document.querySelectorAll('#pf-hand .pf-tile')[i]; return { same: f.__same === 1 && window.__navmark === 1, art: t.querySelector('.pfh-cv').toDataURL(), flipped: t.classList.contains('pfv-flipped'), picked: t.classList.contains('pf-picked'), nums: document.querySelectorAll('#pfb-board .pfb-lit .pfb-num').length, lit: document.querySelectorAll('#pfb-board .pfb-lit').length, btn: document.getElementById('pf-flip').disabled }; }, pi);
    p.off('framenavigated', onNav);
    const srvFlip = execSync(`php -r '$p=new PDO("sqlite:${game}/data/game.sqlite"); $e=json_decode($p->query("SELECT encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetchColumn(),true); echo empty($e["pf"]["me"]["hand"][${pi}]["flip"]) ? "no" : "flipped";'`).toString();
    ck(T('flip: no page load and no swap of the page (same fight element), sent as a request (X-Requested-With: pfflip)'), [navs, after.same, flipReq.headers()['x-requested-with']], [0, true, 'pfflip']);
    ck(T('flip: the piece is drawn again with its edges swapped, marked flipped, still picked; the server has it flipped'), [after.art !== before.art, after.flipped, after.picked, srvFlip], [true, true, true, 'flipped']);
    ck(T('flip: the lit spots and their numbers are worked out again; the same piece may flip back'), [after.lit > 0, after.nums > 0, after.btn], [true, true, false]);
    const other = await p.evaluate((i) => [...document.querySelectorAll('#pf-hand .pf-tile')].findIndex((t, k) => k !== i && !t.classList.contains('pfv-off')), pi);
    if (other >= 0) { await p.locator('#pf-hand .pf-tile').nth(other).click(); await p.waitForTimeout(300);
      ck(T('flip: with another piece picked the button is off and says why (Flip used)'), [await p.isDisabled('#pf-flip'), /Flip used/.test(await p.locator('#pf-flip').innerText()), /flipped a piece this turn/.test(await p.getAttribute('#pf-flip', 'title'))], [true, true, true]);
      await p.locator('#pf-hand .pf-tile').nth(pi).click(); await p.waitForTimeout(300); }
    await p.click('#pf-flip'); await p.waitForTimeout(1200);
    ck(T('flip: flipping it back restores the piece and gives the flip back'), [await p.evaluate((i) => document.querySelectorAll('#pf-hand .pf-tile')[i].querySelector('.pfh-cv').toDataURL(), pi) === before.art, await p.evaluate((i) => document.querySelectorAll('#pf-hand .pf-tile')[i].classList.contains('pfv-flipped'), pi)], [true, false]);
    await p.click('#pf-flip'); await p.waitForTimeout(1200);
    await shot('4-fight-flipped');

    // ---- the turn played back step by step: Your turn, the creature's turn, Terrain turn
    seed('fight', 'boss'); seed('midfight', '8', '3', 'soft'); await speed(0); await open('/adventure.php'); await speed(1);
    const pj = await p.evaluate(() => [...document.querySelectorAll('#pf-hand .pf-tile')].findIndex(t => !t.classList.contains('pfv-off')));
    await p.locator('#pf-hand .pf-tile').nth(pj).click(); await p.waitForTimeout(700);
    if (!(await n('#pfb-board .pfb-lit'))) { await p.click('#pf-flip'); await p.waitForTimeout(1500); }
    await p.locator('#pfb-board .pfb-lit').first().click(); await p.waitForTimeout(500);
    ck(T('fight: a planned piece lights the chain dots'), await n('#pfv-row .dots i.on, #pfv-row .dots i.over') > 0, true);
    await shot('5-turn-planned');
    await p.click('#pf-go');
    const seen = {};
    for (let k = 0; k < 90 && !(seen.me && seen.foe && seen.env && seen.flash); k++) {
      await p.waitForTimeout(200);
      const s = await p.evaluate(() => { const e = document.querySelector('.pf-turn:not([hidden])'); return { t: e ? (e.className.match(/pf-turn-(me|foe|env)/) || [])[1] || '' : '', fl: document.querySelectorAll('.pfv-envin, .pfv-fx').length, skip: !!(document.getElementById('pf-skip') && !document.getElementById('pf-skip').hidden) }; }).catch(() => ({ t: '' }));
      if (s.t && !seen[s.t]) { seen[s.t] = 1; await p.waitForTimeout(250); await shot('5-turn-banner-' + s.t, false); }
      if (s.fl && !seen.flash) { seen.flash = 1; await shot('5-turn-env-place', false); }
      if (s.skip) seen.skip = 1;
    }
    ck(T('replay: the banners YOUR TURN, THEIR TURN and ENVIRONMENT TURN each show, an environment piece grows in or an effect shows, Skip is offered'), [!!seen.me, !!seen.foe, !!seen.env, !!seen.flash, !!seen.skip], [true, true, true, true, true]);
    await p.click('#pf-skip').catch(() => {}); await p.waitForTimeout(400);
    ck(T('replay: Skip ends it; the board is the new turn\'s'), [await p.evaluate(() => document.getElementById('pfight').classList.contains('pf-playing')), await n('#pfb-board .pfb-cell.pfb-env') > 0], [false, true]);
    await p.click('#pfv-legend [data-a=spd]'); ck(T('speed: the chip cycles 1x, 2x, skip'), /2/.test(await p.locator('#pfv-legend [data-a=spd]').innerText()), true); await speed(0);

    // ---- 5. the result card: a win (with tool wear), then a fight that was left
    seed('win'); await open('/adventure.php');
    ck(T('result: the win card with tool wear rows, the box link and the reward button'), [await n('#pfv-res .resbadge'), await n('#pfv-res .toolrow') >= 2, await n('#pfv-res a[href*="puzzlebox.php"]'), await n('#pf-end')], [1, true, 1, 1]);
    await shot('6-result-win');
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pf-end')]); await p.waitForTimeout(1200);
    seed('fight', 'medium'); await open('/adventure.php'); await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pfv-go')]); await p.waitForTimeout(1200);
    await p.locator('#pf-hand .pf-tile').first().click(); await p.waitForTimeout(300); await p.locator('#pfb-board .pfb-lit').first().click(); await p.waitForTimeout(200);
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pf-go')]); await p.waitForTimeout(1200);
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('.pf-runf button')]); await p.waitForTimeout(1500);
    ck(T('result: a fight that was left shows the lost card on the next page'), [await n('#pfv-res .badge-lose'), /walked away/.test(await p.locator('#pfv-res').innerText().catch(() => ''))], [1, true]);
    await shot('6-result-left');
    ck(T('no console errors on any screen'), errs, []);
    await c.close();

    // ---- 2.6.75: the fight never scrolls: every board size at phone, small phone and desktop sizes; the pre-fight screen keeps Let's fight on screen; the menu has the link under Hobbies
    for (const vp of [[390, 844], [360, 640], [412, 915], [1280, 720]]) {
      const c2 = await b.newContext({ viewport: { width: vp[0], height: vp[1] }, deviceScaleFactor: vp[0] > 1000 ? 1 : 2 }); const q = await c2.newPage(); const e2 = [];
      q.on('pageerror', e => e2.push(String(e))); q.on('console', m => { if (m.type() === 'error') e2.push(m.text()); });
      await q.addInitScript(() => { try { localStorage.setItem('pfvspd', '0'); } catch (e) {} });
      await q.goto(base + '/login.php'); await q.fill('input[name=username]', 'sprout'); await q.fill('input[name=password]', 'TestPass123!');
      await Promise.all([q.waitForNavigation(), q.press('input[name=password]', 'Enter')]);
      const V = (s) => `${theme} ${vp[0]}x${vp[1]}: ${s}`;
      for (const size of ['small', 'medium', 'large', 'boss']) {
        seed('fight', size); seed('midfight', '8', '2', 'soft');
        await q.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await q.waitForTimeout(700);
        const pk = q.locator('#pf-hand .pf-tile:not(.pfv-off)'); if (await pk.count()) { await pk.first().click({ timeout: 3000 }); await q.waitForTimeout(500); }
        const m = await q.evaluate(() => { const f = document.getElementById('pfight'), ih = innerHeight, iw = innerWidth, de = document.documentElement; window.scrollTo(0, 400);
          const inV = (sel) => { const e = document.querySelector(sel); if (!e) return false; const r = e.getBoundingClientRect(); return r.height > 0 && r.top >= -1 && r.bottom <= ih + 1 && r.left >= -1 && r.right <= iw + 1; };
          const bd = document.getElementById('pfb-board').getBoundingClientRect(), d = JSON.parse(document.getElementById('pf-data').textContent), fb = document.getElementById('pf-flip').getBoundingClientRect();
          return { doc: de.scrollHeight <= ih, sy: window.scrollY, fight: f.scrollHeight <= f.clientHeight + 1 && f.scrollWidth <= f.clientWidth + 1, wide: de.scrollWidth <= iw, cell: Math.round(bd.height / d.h),
            all: ['.pfc-top', '.pf-hist', '#pfv-row', '#pfb-board', '#pfv-legend', '#pf-preview', '.pf-buttons', '#pf-go', '#pf-flip', '#pf-undo', '#pf-hand'].filter(s => !inV(s)), hand: [...document.querySelectorAll('#pf-hand .pf-tile')].every(t => { const r = t.getBoundingClientRect(); return r.top >= 0 && r.bottom <= ih + 1; }), flipH: Math.round(fb.height) }; });
        ck(V(`${size} board: the page does not scroll (document height <= window, scrollTo stays at 0), nothing overflows the fight`), [m.doc, m.sy, m.fight, m.wide], [true, 0, true, true]);
        ck(V(`${size} board: header, history, chips, board, legend, hint, buttons and hand are all on screen; cells at least 24px; Flip is 40 to 46px high`), [m.all, m.hand, m.cell >= 24, m.flipH >= 40 && m.flipH <= 46], [[], true, true, true]);
        await q.screenshot({ path: `${out}/7-fit-${size}-${vp[0]}x${vp[1]}-${theme}.png` });
        // 2.6.76: no dead bands. The sections from the chips down are packed (no gap over 24px between the boxes of the header, chips, board, Next strip, hint, buttons, hand), the board takes the height there is
        const lay = await q.evaluate(() => { const ih = innerHeight, rs = ['.pfc-top', '#pfv-row', '#pfb-board', '#pfv-legend', '#pf-preview', '.pf-buttons', '#pf-hand'].map(s => { const r = document.querySelector(s).getBoundingClientRect(); return [s, r.top, r.bottom]; }).sort((a, b) => a[1] - b[1]);
          const bd = document.getElementById('pfb-board').getBoundingClientRect(), wr = document.querySelector('.pfv-bwrap').getBoundingClientRect(), hd = document.getElementById('pf-hand').getBoundingClientRect(), ft = document.getElementById('pfight').getBoundingClientRect();
          return { gaps: rs.slice(1).map((r, i) => [r[0], Math.round(r[1] - rs[i][2])]).filter(g => g[1] > 24 || g[1] < -1), pct: Math.round(bd.height * 100 / ih), roomLeft: Math.round(wr.height - bd.height), handBottomGap: Math.round(ft.bottom - hd.bottom) }; });
        ck(V(`${size} board: no gap over 24px between header, chips, board, Next strip, hint, buttons and hand`), lay.gaps, []);
        if (vp[1] >= 800) ck(V(`${size} board: the board is at least 45% of the window height on a tall phone (${lay.pct}%)`), lay.pct >= 45, true);
        ck(V(`${size} board: the room under or over the board (width limits it) is at most 48px in all (${lay.roomLeft})`), lay.roomLeft <= 48 || vp[0] > 1000, true);
        const wasInsp = await q.evaluate(() => { const t = document.querySelector('#pfb-board .pfb-tap'); if (t) t.click(); const i = document.getElementById('pf-inspect'), h = document.getElementById('pf-hand').getBoundingClientRect(), ib = i.getBoundingClientRect(), bd = document.getElementById('pfb-board').getBoundingClientRect(); return { open: !i.hidden, over: ib.bottom <= h.top + 1, inBoardRoom: ib.top >= bd.top - 60 && ib.bottom <= bd.bottom + 60, doc: document.documentElement.scrollHeight <= innerHeight }; });
        await q.waitForTimeout(150); if (wasInsp.open) await q.screenshot({ path: `${out}/7-insp-${size}-${vp[0]}x${vp[1]}-${theme}.png` });
        ck(V(`${size} board: the piece card is an overlay on the board room (not over the hand), the page does not grow`), [wasInsp.open, wasInsp.over, wasInsp.inBoardRoom, wasInsp.doc], [true, true, true, true]);
        if (wasInsp.open) { const pv = await q.locator('#pf-preview').boundingBox(); await q.mouse.click(pv.x + pv.width / 2, pv.y + pv.height / 2); await q.waitForTimeout(150); ck(V(`${size} board: a tap outside closes the piece card`), await q.evaluate(() => document.getElementById('pf-inspect').hidden), true); }
        if (size === 'medium') { await q.click('#pfv-legend [data-en="0"]').catch(() => {}); await q.waitForTimeout(250);
          ck(V('medium board: the Next-strip popover opens over the fight and the page still does not scroll, the strip does not overflow'), [await q.locator('.pfv-pop').count(), await q.evaluate(() => document.documentElement.scrollHeight <= innerHeight), await q.evaluate(() => { const l = document.getElementById('pfv-legend'); return l.scrollWidth <= l.clientWidth + 1; })], [1, true, true]);
          await q.screenshot({ path: `${out}/7-envpop-${vp[0]}x${vp[1]}-${theme}.png` }); await q.click('.pfv-popx').catch(() => {}); }
      }
      seed('win'); await q.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await q.waitForTimeout(600);
      ck(V('the result card lies over the fight (the page still does not scroll) with the reward button reachable'), [await q.evaluate(() => document.documentElement.scrollHeight <= innerHeight), await q.locator('#pf-end').count()], [true, 1]);
      await q.locator('#pf-end').scrollIntoViewIfNeeded(); await q.screenshot({ path: `${out}/7-fit-result-${vp[0]}x${vp[1]}-${theme}.png` });
      await Promise.all([q.waitForResponse(r => r.request().method() === 'POST'), q.click('#pf-end')]); await q.waitForTimeout(900);
      ck(V('after the fight the page scrolls again (the lock is gone)'), await q.evaluate(() => getComputedStyle(document.documentElement).overflowY !== 'hidden'), true);
      for (const auto of ['auto', 'off']) {
        seed('fight', 'boss', auto); await q.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await q.waitForTimeout(600);
        ck(V(`pre-fight, auto ${auto === 'auto' ? 'on' : 'off'}: Let's fight is on screen without scrolling`), await q.evaluate(() => { const r = document.getElementById('pfv-go').getBoundingClientRect(); return r.top >= 0 && r.bottom <= innerHeight && document.documentElement.scrollHeight <= innerHeight; }), true);
        await q.screenshot({ path: `${out}/7-prefight-${auto}-${vp[0]}x${vp[1]}-${theme}.png` });
      }
      sql('UPDATE expeditions SET encounter=NULL');
      await q.goto(base + '/puzzlebox.php?t=belt', { waitUntil: 'networkidle' }); await q.waitForTimeout(500); await q.screenshot({ path: `${out}/7-belt-${vp[0]}x${vp[1]}-${theme}.png`, fullPage: true });
      ck(V('the menu has the Puzzle box under Hobbies'), await q.evaluate(() => { const g = document.querySelector('details[data-g="Hobbies"]'); return !!g && !!g.querySelector('a.navtile[href$="puzzlebox.php"]'); }), true);
      if (vp[0] < 1000) { await q.click('.menubtn.more').catch(() => {}); await q.waitForTimeout(400); } await q.screenshot({ path: `${out}/7-menu-${vp[0]}x${vp[1]}-${theme}.png` });
      ck(V('no console errors'), e2, []);
      await c2.close();
    }
  }
  await b.close();
  console.log('shots: done' + (fails ? ' (' + fails + ' failed)' : ''));
})().catch(e => { console.log('FAIL the browser pass stopped: ' + String(e).slice(0, 400)); process.exit(1); });
