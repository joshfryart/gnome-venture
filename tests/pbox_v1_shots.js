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
    await open('/puzzlebox.php?t=belt'); ck(T('belt: durability bars are sized by the script'), await p.evaluate(() => [...document.querySelectorAll('.pfv .dur i')].some(i => i.style.width && i.style.width !== '0%')), true); await shot('2-box-belt');
    await open('/puzzlebox.php?t=pals'); await shot('2-box-pals');

    // ---- 3. the pre-fight screen: auto off (free swaps), auto on (read-only)
    seed('fight', 'medium'); await open('/adventure.php');
    await p.locator('#pfv-pre .pc.L-uni').first().click(); await p.locator('#pfv-pre .pc[data-a=tog]').nth(2).click();
    ck(T('pre-fight, auto off: creature piece detail, a deck piece offers Take out, a bench is there'), [/plays ×2/.test(await p.locator('#pfv-cinfo').innerText()), await n('#pfv-info [data-pfv-act]'), await p.locator('#pfv-pre').innerText().then(t => /BENCH/i.test(t))], [true, 1, true]);
    await shot('3-prefight-auto-off');
    seed('fight', 'boss', 'auto'); await open('/adventure.php');
    ck(T('pre-fight, auto on: the note, Turn off and edit, no swaps, Let\'s fight'), [/Auto deck is active/.test(await p.locator('#pfv-info').innerText()), await n('#pfv-pre .pc[data-a=tog]'), await n('#pfv-go')], [true, 0, 1]);
    await shot('3-prefight-auto-on');
    await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pfv-go')]); await p.waitForTimeout(1500);
    ck(T('Let\'s fight: the board of a boss (7 by 6 cells) with ground'), [await n('#pfb-board .gc'), await n('#pfb-board .gc[data-ter]') > 0], [42, true]);
    await shot('4-fight-opening');

    // ---- 4. the fight: a seeded position with ground, a forecast, the aim and hand pieces that cannot be played
    await speed(0); let st = null;
    for (const sd of [7, 8, 9, 10, 11, 12, 13, 14, 15, 16]) {   // the deck differs with the kit that was packed: take the first seeded position that shows everything
      seed('fight', 'large'); seed('midfight', String(sd), '3'); await open('/adventure.php'); await p.waitForTimeout(500);
      st = await pos(); if (st.off >= 1 && st.off < 5 && st.marks >= 1 && st.aim === 1 && st.ground > 0) break;
    }
    async function pos() { return p.evaluate(() => ({ ground: document.querySelectorAll('#pfb-board .gc[data-ter]').length, frames: document.querySelectorAll('#pfb-board .gf svg').length, marks: document.querySelectorAll('#pfb-board .mk.ev .mkb em').length, aim: document.querySelectorAll('#pfb-board .mk.aim').length,
      off: document.querySelectorAll('#pf-hand .pfv-off').length, pips: document.querySelectorAll('#pf-hand .pf-tile .xp').length, legend: document.querySelectorAll('#pfv-legend [data-ter]').length, evchips: document.querySelectorAll('#pfv-row .tg.ev').length, aimchip: document.querySelectorAll('#pfv-row .tg.aim').length,
      team: document.querySelectorAll('#pfv-row .tg.team').length, envchips: document.querySelectorAll('.pf-chip.env').length, lifepips: document.querySelectorAll('#pfb-board .pfb-cell .xp').length > 0 })); }
    ck(T('fight: ground cells with icons, forecast marks with words, the aim marker, legend, forecast and aim chips, Teamwork chip, life pips'), [st.ground > 0, st.frames === st.ground, st.marks >= 1, st.aim, st.legend, st.evchips === st.marks, st.aimchip, st.team, st.lifepips, st.pips > 0], [true, true, true, 1, 3, true, 1, 1, true, true]);
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
    await p.locator('#pfb-board .mkb').first().click(); await p.waitForTimeout(150);
    ck(T('fight: a forecast mark opens its popover (name, what it does, when, who)'), /Lands at the end of this round/.test(await p.locator('.pfv-pop').innerText()), true);
    await shot('4-fight-forecast-popover');
    await p.click('.pfv-popx'); await p.locator('#pfb-board .gc[data-ter]').first().click({ position: { x: 4, y: 4 } }); await p.waitForTimeout(150);
    ck(T('fight: a ground cell opens its popover'), await n('.pfv-pop'), 1);
    await p.click('#pfv-legend [data-a=turn]'); await p.waitForTimeout(100);
    ck(T('fight: the Terrain turn chip explains the round'), /you, the creature, then the terrain/.test(await p.locator('.pfv-pop').innerText()), true);
    await p.click('#pfv-legend [data-a=help]'); await p.waitForTimeout(200);
    ck(T('fight: the ? help covers the terrain turn, the aim, chains, flip, terrain and the five events'), await p.locator('.pfv-sheet').innerText().then(t => ['Terrain turn', 'aim', 'Chains', 'Flip', 'Sunny patch', 'Bramble', 'Mud', 'Sunbeam', 'Bramble creep', 'Puddle', 'Gust', 'Thorn burst', 'Animation speed'].every(w => t.toLowerCase().includes(w.toLowerCase()))), true);
    await shot('4-fight-help', false);
    await p.keyboard.press('Escape'); ck(T('fight: Escape closes the help'), await n('.pfv-sheet'), 0);
    const pi = await p.evaluate(() => [...document.querySelectorAll('#pf-hand .pf-tile')].findIndex(t => !t.classList.contains('pfv-off')));
    await p.locator('#pf-hand .pf-tile').nth(pi).click(); await p.waitForTimeout(900);
    ck(T('fight: a playable piece lights its spots with numbers, without a reply number; Flip is on'), [await n('#pfb-board .pfb-lit') > 0, await n('#pfb-board .pfb-lit .pfb-num') > 0, await p.locator('#pfb-board').innerText().then(t => t.includes('↩')), await p.isDisabled('#pf-flip')], [true, true, false, false]);
    await shot('4-fight-lit-spots');
    await p.click('#pf-flip'); await p.waitForTimeout(1500);
    ck(T('fight: Flip turns the piece over (marked, picked again), and the flip is used'), [await p.evaluate((i) => document.querySelectorAll('#pf-hand .pf-tile')[i].classList.contains('pfv-flipped'), pi), await p.evaluate((i) => document.querySelectorAll('#pf-hand .pf-tile')[i].classList.contains('pf-picked'), pi), await p.evaluate(() => JSON.parse(document.getElementById('pf-data').textContent).flip.used)], [true, true, true]);
    await shot('4-fight-flipped');

    // ---- the turn played back step by step: Your turn, the creature's turn, Terrain turn
    seed('fight', 'boss'); seed('midfight', '8', '3'); await speed(0); await open('/adventure.php'); await speed(1);
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
      const s = await p.evaluate(() => { const e = document.querySelector('.pf-turn:not([hidden])'); return { t: e ? (e.className.match(/pf-turn-(me|foe|env)/) || [])[1] || '' : '', fl: document.querySelectorAll('.evflash').length, skip: !!(document.getElementById('pf-skip') && !document.getElementById('pf-skip').hidden) }; }).catch(() => ({ t: '' }));
      if (s.t && !seen[s.t]) { seen[s.t] = 1; await p.waitForTimeout(250); await shot('5-turn-banner-' + s.t, false); }
      if (s.fl && !seen.flash) { seen.flash = 1; await shot('5-turn-terrain-event', false); }
      if (s.skip) seen.skip = 1;
    }
    ck(T('replay: the banners YOUR TURN, THEIR TURN and TERRAIN TURN each show, a terrain event flashes its mark, Skip is offered'), [!!seen.me, !!seen.foe, !!seen.env, !!seen.flash, !!seen.skip], [true, true, true, true, true]);
    await p.click('#pf-skip').catch(() => {}); await p.waitForTimeout(400);
    ck(T('replay: Skip ends it; the board is the new turn\'s'), [await p.evaluate(() => document.getElementById('pfight').classList.contains('pf-playing')), await n('#pfb-board .mk.ev') > 0], [false, true]);
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
  }
  await b.close();
  console.log('shots: done' + (fails ? ' (' + fails + ' failed)' : ''));
})().catch(e => { console.log('FAIL the browser pass stopped: ' + String(e).slice(0, 400)); process.exit(1); });
