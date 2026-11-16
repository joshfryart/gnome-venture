// 2.7.01 the rest of claude/reviews-2026-11-13/learn.md, in a real browser: fixed first fight, guided first turns, Hint button, stall nudge, defeat recap, free retry.
// node tests/pfv1_guide.js BASE GAME TESTSDIR  (see tests/pfv1_guide.sh)
const { chromium } = require('playwright');
const { execSync } = require('child_process');
const [base, game, here] = process.argv.slice(2);
const seedNew = (...a) => execSync(`PBOX_RULES=new php -d display_errors=1 ${here}/pbox_v1_seed.php ${game} ${a.join(' ')}`).toString().trim();
const sql = (q) => execSync(`php -r '$p=new PDO("sqlite:${game}/data/game.sqlite"); $p->exec($argv[1]);' "${q}"`);
let fails = 0;
const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { console.log(`FAIL ${what} (got ${g}, want ${w})`); fails++; } };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const p = await (await b.newContext({ viewport: { width: 390, height: 844 } })).newPage();
  const errs = []; p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
  const posts = { hint: 0, guideoff: 0 };
  p.on('request', r => { if (r.method() !== 'POST') return; const d = r.postData() || ''; if (/pfb_hint/.test(d)) posts.hint++; if (/pfb_guideoff/.test(d)) posts.guideoff++; });
  await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
  await p.evaluate(() => localStorage.setItem('pfvspd', '0'));
  const ready = async () => { await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(700); };
  const pdata = () => p.evaluate(() => { const e = document.getElementById('pf-data'); return e ? JSON.parse(e.textContent) : null; });
  const guide = () => p.evaluate(() => { const g = document.getElementById('pfv-guide'); return g && !g.hidden ? [g.dataset.k, g.querySelector('.gt').textContent] : null; });
  const handNames = () => p.evaluate(() => [...document.querySelectorAll('#pf-hand .pf-tile')].map(t => t.dataset.name));
  const firstLit = () => p.evaluate(() => { const c = document.querySelector('.pfb-lit'); return c ? [c.dataset.x, c.dataset.y] : null; });
  const tapHand = async (k) => { await p.locator('#pf-hand .pf-tile').nth(k).click(); await p.waitForTimeout(600); };
  const tapLit = async (xy) => { await p.click(`.pfb-lit[data-x="${xy[0]}"][data-y="${xy[1]}"]`); await p.waitForTimeout(300); };
  const freshFirst = () => { sql('DELETE FROM pf_learn'); sql('DELETE FROM pf_deck_pieces'); sql('UPDATE pf_decks SET starter = 0'); seedNew('fight', 'small', 'x', 'garden-snail'); };

  // ---- 1. a new gnome's first fight: no box screen, the Garden Snail, the same deal every time
  freshFirst(); await ready();
  ck('first fight: no "Pack your box" screen, the board at once', await p.evaluate(() => !!document.getElementById('pfb-board') && !/Pack your/.test(document.body.innerText)), true);
  let d = await pdata();
  ck('first fight: the Garden Snail', d && d.foe, 'Garden Snail');
  const hand1 = await handNames();
  freshFirst(); await ready();
  ck('first fight: the same hand on a second deal', await handNames(), hand1);
  ck('first fight: the opening (blank) is on', (await pdata()).start, true);
  // ---- 2. guided first turns: the opening, then turn 1
  ck('guide: the opening says tap a piece', await guide(), ['guide', 'Your first move: tap a piece in your hand.']);
  ck('guide: no Hint button in the opening', await p.evaluate(() => !document.getElementById('pf-hint')), true);
  await tapHand(0);
  ck('guide: then a side of the blank', (await guide() || [])[1], 'Now tap a lit spot beside the blank ✦: that side of the blank is where you start.');
  const lit0 = await firstLit(); if (lit0) await tapLit(lit0);
  ck('guide: then Confirm start', (await guide() || [])[1], 'Tap Confirm start. The Garden Snail picks its side of the blank too, hidden.');
  await Promise.all([p.waitForResponse(r => r.request().method() === 'POST' && /pfb_play/.test(r.request().postData() || ''), { timeout: 10000 }).catch(() => null), p.click('#pf-go')]); await ready();
  ck('guide: turn 1, pick a piece and link it', (await guide() || [])[1], 'Tap a piece in your hand. Put it where it links to other pieces, so they fire in your chain.');
  await tapHand(0); await p.waitForTimeout(500);
  ck('guide: what the lit-spot numbers mean', /Its numbers are what your chain does there: ⚔ hurt, ✿ charm, ❤− health you lose\./.test((await guide() || [])[1]), true);
  const lit1 = await firstLit(); if (lit1) await tapLit(lit1);
  ck('guide: fire it in your chain, End turn', (await guide() || [])[1], 'Your piece fires, then every piece linked to it: that is your chain. Tap End turn.');
  ck('guide: never in the way (End turn still works)', await p.evaluate(() => !document.getElementById('pf-go').disabled), true);
  await p.click('#pf-undo'); await p.waitForTimeout(300);
  // ---- 3. the Hint button: a lit spot and why; once a turn counted
  ck('hint: the button says 3 free hints', await p.evaluate(() => document.querySelector('#pf-hint small').textContent), '3');
  await p.click('#pf-hint'); await p.waitForTimeout(1200);
  let g = await guide();
  ck('hint: the line says the spot and why', !!g && g[0] === 'hint' && /^💡 .+ here: .+\.$/.test(g[1]), true);
  ck('hint: one lit spot is marked', await p.evaluate(() => document.querySelectorAll('.pfb-lit.pfv-hint').length), 1);
  ck('hint: the piece is picked', await p.evaluate(() => document.querySelectorAll('#pf-hand .pf-tile.pf-picked.pfv-hinted').length), 1);
  ck('hint: 2 left', await p.evaluate(() => document.querySelector('#pf-hint small').textContent), '2');
  await p.click('#pf-hint'); await p.waitForTimeout(600);
  ck('hint: asking again this turn asks nothing more', [posts.hint, await p.evaluate(() => document.querySelector('#pf-hint small').textContent)], [1, '2']);
  await ready();
  ck('hint: after a reload the count stays (2 left)', (await pdata()).hints, 2);
  // ---- 4. closing the coaching is remembered for the gnome
  ck('guide: shown again after the reload', ((await guide()) || [])[0], 'guide');
  await p.click('#pfv-guide .gx'); await p.waitForTimeout(800);
  ck('guide: the close button hides it', await guide(), null);
  ck('guide: the close is sent once', posts.guideoff, 1);
  await ready();
  ck('guide: still off after a reload', [(await pdata()).guide, await guide()], [false, null]);
  // ---- 5. the stall nudge: from turn N while the bar is under half (here N = 1, a gnome past its guided fights)
  sql("INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_stall_turn','1')"); sql('DELETE FROM pf_learn'); sql("INSERT INTO pf_learn (user_id, fights) SELECT id, 6 FROM users WHERE username = 'sprout'");
  seedNew('fight', 'small'); seedNew('midfight', '7', '1', 'soft'); await ready();
  g = await guide();
  ck('stall nudge: "Stuck?" with the hint named', !!g && g[0] === 'stall' && /^Stuck\? Link to a Bramble or to your own pieces for a longer chain, or tap Hint\.$/.test(g[1]), true);
  await p.click('#pfv-guide .gx'); await p.waitForTimeout(300);
  ck('stall nudge: closes for the fight', await guide(), null);
  sql("INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_stall_turn','0')");
  await ready();
  ck('stall nudge: pfight_stall_turn = 0, none', await guide(), null);
  // ---- 6. a defeat in the first fights: the recap and Try again
  sql('DELETE FROM pf_learn'); sql("INSERT INTO pf_learn (user_id, fights) SELECT id, 3 FROM users WHERE username = 'sprout'");
  seedNew('fight', 'small'); seedNew('midfight', '7', '1', 'soft'); seedNew('lose'); await ready();
  ck('defeat: the recap says where the health went', /^You lost \d+ health to /.test(await p.evaluate(() => (document.getElementById('pfv-recap') || {}).textContent || '')), true);
  ck('defeat: Try again is offered next to Go home', await p.evaluate(() => [!!document.getElementById('pf-retry'), /Go home to rest$/.test((document.getElementById('pf-end') || {}).textContent || '')]), [true, true]);
  await Promise.all([p.waitForResponse(r => r.request().method() === 'POST' && /pf_retry/.test(r.request().postData() || ''), { timeout: 10000 }).catch(() => null), p.click('#pf-retry')]); await ready();
  d = await pdata();
  ck('retry: a new fight against the same creature, at your health as it was', [!!d && !d.won, await p.evaluate(() => !document.getElementById('pfv-res') && !!document.getElementById('pfb-board')), d && d.hp], [true, true, 60]);
  sql('DELETE FROM pf_learn'); sql("INSERT INTO pf_learn (user_id, fights) SELECT id, 7 FROM users WHERE username = 'sprout'");
  seedNew('fight', 'small'); seedNew('midfight', '7', '1', 'soft'); seedNew('lose'); await ready();
  ck('defeat after fight 6: no Try again', await p.evaluate(() => !document.getElementById('pf-retry') && !!document.getElementById('pf-end')), true);
  ck('no console error', errs, []);
  console.log('guide: done'); await b.close(); process.exit(fails ? 1 : 0);
})().catch(e => { console.log('FAIL crash ' + e); process.exit(1); });
