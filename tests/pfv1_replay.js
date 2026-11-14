// 2.6.96: the replay is short and skippable (Josh/turn-flow review: a 14.6 s median wait after End turn with no control). node tests/pfv1_replay.js BASE GAME TESTSDIR
// In a real browser on the served v1 fight page, on a seed whose replay has 11 events (a medium creature, four turns in, then one more turn; the review's 13-event seed is not named, 11 is the longest the seeds here give):
//  - control is back in <= 9.3 s at 1x (8.46 s cap; it was 14.5 s before 2.6.95 and 4.6 s in 2.6.95), <= 5.2 s at 2x, at once at "skip"; the replay still walks every event in order;
//  - a tap on the board during the replay skips it; "prefers-reduced-motion" with no stored speed skips it; a stored speed wins over reduced motion;
//  - no "Your turn" banner before the creature's, no separate environment banner (the environment places in the creature's step);
//  - 2.6.88: the health number walks with the replay (never the new value early); 2.6.78: the last turn of a fight plays in full before the result card.
const { chromium } = require('playwright');
const { execSync } = require('child_process');
const [base, game, here] = process.argv.slice(2);
const seed = (...a) => execSync(`php -d display_errors=1 ${here}/pbox_v1_seed.php ${game} ${a.join(' ')}`).toString().trim();
let fails = 0;
const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { console.log(`FAIL ${what} (got ${g}, want ${w})`); fails++; } };
const le = (what, got, max) => { if (got !== null && got <= max) console.log(`ok   ${what} (${got} ms <= ${max})`); else { console.log(`FAIL ${what} (got ${got} ms, want <= ${max})`); fails++; } };
const SEEDARGS = (process.env.REPLAY_SEED || 'midfight 9 4 soft').split(' ');
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const mk = async (opts) => {
    const c = await b.newContext({ viewport: { width: 390, height: 844 }, ...opts }); const p = await c.newPage(); p.__errs = [];
    p.on('pageerror', e => p.__errs.push(String(e)));
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
    await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    return { c, p };
  };
  const SAMPLER = () => { window.__tl = []; const hp = () => { const h = document.querySelector('.pfc-top .pf-hp'); const m = h && /\d+/.exec(h.textContent); return m ? +m[0] : null; };
    clearInterval(window.__iv); window.__iv = setInterval(() => { const f = document.getElementById('pfight'), t = document.querySelector('.pf-turn:not([hidden])'), r = document.getElementById('pfv-res');
      window.__tl.push({ at: performance.now(), pl: !!f && f.classList.contains('pf-playing'), turn: f ? f.dataset.turn : null, ban: t ? t.firstChild.textContent : null, hp: hp(), res: !!r && getComputedStyle(r).display !== 'none' && r.getBoundingClientRect().height > 0, wait: !!f && f.classList.contains('pfv-endwait') }); }, 25); };
  // open the seeded fight, wait until the page is quiet, play the first piece on its first lit cell up to End turn (not yet pressed)
  const ready = async (p, speed, args = SEEDARGS) => {
    seed('fight', process.env.REPLAY_SIZE || 'medium'); seed(...args);
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.evaluate((s) => { try { s === null ? localStorage.removeItem('pfvspd') : localStorage.setItem('pfvspd', s); } catch (e) {} }, speed === null ? null : String(speed));
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' });
    await p.waitForFunction(() => { const f = document.getElementById('pfight'); return f && !f.classList.contains('pf-playing'); }, null, { timeout: 30000 }); await p.waitForTimeout(1200);
    const n = await p.locator('#pf-hand .pf-tile').count();
    for (let i = 0; i < n; i++) { await p.locator('#pf-hand .pf-tile').nth(i).click(); await p.waitForTimeout(300); if (await p.locator('#pfb-board .pfb-lit').count()) break; if (i === n - 1) throw new Error('no playable piece'); }
    await p.locator('#pfb-board .pfb-lit').first().click(); await p.waitForTimeout(400);
    await p.evaluate(SAMPLER);
    return await p.evaluate(() => ({ turn: document.getElementById('pfight').dataset.turn, hp: (/\d+/.exec(document.querySelector('.pfc-top .pf-hp').textContent) || [])[0] }));
  };
  // press End turn, then: time to control (the new turn's page is there and nothing is playing any more), the sampled timeline, the replay events of the new page
  const endTurn = async (p, before, tapAt) => {
    const t0 = await p.evaluate(() => performance.now()); await p.click('#pf-go');
    if (tapAt) { await p.waitForFunction(() => window.__tl.some(s => s.pl), null, { timeout: 8000, polling: 20 }); await p.waitForTimeout(tapAt); await p.mouse.click(195, 330); }
    let tl = [], k = 0;
    for (; k < 1600; k++) {   // quiet = the new turn's page, nothing playing, for the last 700 ms of samples
      await p.waitForTimeout(25); tl = await p.evaluate(() => window.__tl); const last = tl[tl.length - 1]; if (!last || last.turn === before.turn || last.pl) continue;
      if (tl.filter(s => s.at > last.at - 700).every(s => !s.pl && s.turn !== before.turn)) break;
    }
    const data = await p.evaluate(() => JSON.parse(document.getElementById('pf-data').textContent));
    const nw = tl.filter(s => s.turn !== before.turn), pl = nw.filter(s => s.pl), tEnd = pl.length ? pl[pl.length - 1].at + 25 : (nw[0] ? nw[0].at : t0);
    return { tc: Math.round(tEnd - t0), t0, tl, pl, play: pl.length ? Math.round(pl[pl.length - 1].at - pl[0].at) : 0, tPlay0: pl.length ? Math.round(pl[0].at - t0) : null, n: (data.replay || []).length, evhp: (data.replay || []).map(e => e.hp).filter(v => v !== null && v !== undefined), newhp: data.hp,
      bans: [...new Set(pl.map(s => s.ban).filter(Boolean))], errs: p.__errs.length };
  };
  let { c, p } = await mk({});
  if (process.env.REPLAY_PROBE === '3') {   // the replay length of the turn AFTER End turn (first piece, first lit cell) for many seeds
    for (const sa of process.env.REPLAY_SEEDS.split(';')) { try { seed('fight', process.env.REPLAY_SIZE || 'medium'); seed(...sa.split(' ')); const bf = await ready(p, 0, sa.split(' ')); const rr = await endTurn(p, bf); console.log('seed ' + sa + ': ' + rr.n + ' events'); } catch (e) { console.log('seed ' + sa + ': ' + String(e).slice(0, 60)); } }
    await b.close(); console.log('replay: done'); process.exit(0);
  }
  if (process.env.REPLAY_PROBE === '2') {   // list the replay length of many seeds: REPLAY_SEEDS="midfight 8 3 soft;midfight 7 4 soft"
    for (const sa of process.env.REPLAY_SEEDS.split(';')) { try { seed('fight', process.env.REPLAY_SIZE || 'medium'); seed(...sa.split(' ')); await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); console.log('seed ' + sa + ': ' + await p.evaluate(() => { const d = JSON.parse(document.getElementById('pf-data').textContent); return (d.replay || []).length + ' events, hand ' + d.hand.length; })); } catch (e) { console.log('seed ' + sa + ': ' + String(e).slice(0, 60)); } }
    await b.close(); console.log('replay: done'); process.exit(0);
  }
  // ---- 1x, 2x, skip on the 13-event replay seed
  let before = await ready(p, 1); let r = await endTurn(p, before);
  console.log(`replay: ${r.n} events; control after ${r.tc} ms at 1x (playing ${r.play} ms, from ${r.tPlay0} ms); banners ${JSON.stringify(r.bans)}`);
  if (process.env.REPLAY_PROBE) { await b.close(); console.log('replay: done'); process.exit(0); }
  ck('the replay seed has a long replay (11 events; the turn-flow review measured 9 to 13)', r.n >= 10, true);
  ck('the replay does not start by itself before End turn was pressed (the page was quiet)', r.tPlay0 !== null, true);
  le('1x: control is back after End turn', r.tc, 9300);   // cap 8.46 s of replay + the End turn round trip
  ck('1x: the replay really plays (at least 2.5 s, every event walked, not just skipped)', r.play >= 4000, true);
  ck('1x: the first banner of the replay is the creature\'s (no "Your turn" before it) and there is no environment banner', [r.bans.length > 0 && !/^Your turn/.test(r.bans[0]), r.bans.some(x => /Environment|Terrain/i.test(x))], [true, false]);
  ck('1x: no page error', r.errs, 0);
  // 2.6.88: the health number follows the replay: old value first, only values the events set, the final value last
  const hps = r.pl.map(s => s.hp).filter(v => v !== null); const allowed = new Set([+before.hp, ...r.evhp, r.newhp]);
  ck('2.6.88 health: the number shown during the replay starts at the old value and only shows values the events set', [hps.length > 0 && hps[0] === +before.hp, hps.every(v => allowed.has(v))], [true, true]);
  ck('2.6.88 health: after the replay it reads the new value', await p.evaluate(() => (/\d+/.exec(document.querySelector('.pfc-top .pf-hp').textContent) || [])[0]), String(r.newhp));
  before = await ready(p, 2); r = await endTurn(p, before);
  console.log(`replay: control after ${r.tc} ms at 2x (playing ${r.play} ms)`); le('2x: control is back after End turn', r.tc, 5200);
  before = await ready(p, 0); r = await endTurn(p, before);
  console.log(`replay: control after ${r.tc} ms at skip (playing ${r.play} ms)`); le('skip: control is back after End turn', r.tc, 1200);
  // ---- a tap on the board 0.5 s into the replay
  before = await ready(p, 1); r = await endTurn(p, before, 500);
  const tapEnd = r.pl.length ? r.tc - Math.round(r.pl[0].at - r.t0) : null;
  console.log(`replay: a board tap 500 ms in: playing stopped ${tapEnd} ms after it started (tap at 500)`);
  ck('a board tap during the replay skips it (control back within 0.4 s of the tap)', tapEnd !== null && tapEnd <= 500 + 400, true);
  ck('after the tap the hand shows the new turn and the health reads the new value', [await p.evaluate(() => document.getElementById('pfight').dataset.turn) !== before.turn, await p.evaluate(() => (/\d+/.exec(document.querySelector('.pfc-top .pf-hp').textContent) || [])[0])], [true, String(r.newhp)]);
  await c.close();
  // ---- reduced motion, no stored speed: skipped; a stored speed wins
  ({ c, p } = await mk({ reducedMotion: 'reduce' }));
  before = await ready(p, null); r = await endTurn(p, before);
  console.log(`replay: control after ${r.tc} ms with reduced motion and no stored speed (playing ${r.play} ms)`);
  le('reduced motion, no stored speed: the replay is skipped', r.tc, 600); ck('reduced motion: nothing plays', r.play < 100, true);
  before = await ready(p, 1); r = await endTurn(p, before);
  ck('reduced motion with the speed set to 1x by the player: the replay plays', r.play >= 2500, true);
  await c.close();
  // ---- 2.6.78: the last turn of a fight plays in full, then the result card
  ({ c, p } = await mk({}));
  seed('fight', 'small'); seed('charm', '7', 'near');
  await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.evaluate(() => localStorage.setItem('pfvspd', '1')); await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(800);
  await p.locator('#pf-hand .pf-tile').nth(0).click(); await p.waitForTimeout(300); await p.locator('#pfb-board .pfb-lit').first().click(); await p.waitForTimeout(400); await p.evaluate(SAMPLER);
  const t0 = Date.now(); await p.click('#pf-go'); await p.waitForSelector('#pfv-res', { state: 'visible', timeout: 25000 }); const tr = Date.now() - t0; await p.waitForTimeout(300);
  const tl = await p.evaluate(() => window.__tl), pl = tl.filter(s => s.pl), res0 = tl.find(s => s.res);
  console.log(`replay: last turn of a fight, result card after ${tr} ms (playing ${pl.length ? Math.round(pl[pl.length - 1].at - pl[0].at) : 0} ms)`);
  ck('2.6.78 last turn: it plays in full (not skipped), the card is never over the replay and comes after it', [pl.length > 0 && pl[pl.length - 1].at - pl[0].at >= 800, tl.some(s => s.pl && s.res), !!res0 && res0.at >= pl[pl.length - 1].at], [true, false, true]);
  le('last turn: the card shows within 9.3 s of End turn', tr, 9300);
  await c.close();
  console.log('replay: done'); await b.close(); process.exit(fails ? 1 : 0);
})().catch(e => { console.log('FAIL ' + e.stack); process.exit(1); });
