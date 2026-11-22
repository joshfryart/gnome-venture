// 2.7.55 piece effects: node tests/pfanim.js BASE GAME TESTSDIR SHOTDIR   (see tests/pfanim.sh)
// On the served v1 fight page at 390 x 844 (deviceScaleFactor 1), for a small (3x3), a medium (4x4), a large (5x5) creature and a boss with its AOE marked:
// play one turn (a hand piece on a lit spot, End turn) and watch its replay, then replay it again with a reload (sessionStorage cleared) in each setting.
//   full: the engine and its data load, the overlay canvas sits in the board's world at z-index 7 (no taps), the pieces land (place) and fire (own edge + chain carrier), pixels are drawn;
//   the replay's steps come at the same times with the effects on and off (the step clock is untouched); the board does not move; nothing scrolls sideways;
//   off: nothing is started or drawn; light: pieces land, nothing fires; a skip drops every effect at once; reduced motion with no choice = off, with Full chosen = full.
// Screenshots (the clock frozen mid-effect with PFAnim.seek): place on 3x3, a chain on 4x4, the boss AOE pulse on 5x5.
const { chromium } = require('playwright');
const { execSync } = require('child_process');
const [base, game, here, shots] = process.argv.slice(2);
const php = (...a) => execSync(`php -d display_errors=1 ${a.join(' ')}`).toString().trim();
let fails = 0;
const ok = (what, cond, got) => { if (cond) console.log('ok   ' + what); else { console.log(`FAIL ${what}` + (got !== undefined ? ` (got ${JSON.stringify(got).slice(0, 600)})` : '')); fails++; } };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  const mk = async (rm) => {
    const c = await b.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 1, reducedMotion: rm ? 'reduce' : 'no-preference' }); const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error' && !/ResizeObserver|favicon/.test(m.text())) errs.push(m.text()); });
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
    await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    return { c, p, errs };
  };
  const { p, errs } = await mk(false);
  const setFx = (v) => p.evaluate(v => { try { localStorage.setItem('pfvspd', '1'); if (v) localStorage.setItem('pfvfx', v); else localStorage.removeItem('pfvfx'); } catch (e) {} }, v);
  const playing = (pg) => pg.evaluate(() => { const f = document.getElementById('pfight'); return !!(f && f.classList.contains('pf-playing')); });
  const quiet = (pg) => pg.waitForFunction(() => { const f = document.getElementById('pfight'); return f && !f.classList.contains('pf-playing'); }, null, { timeout: 30000 }).catch(() => {});
  const stats = (pg) => pg.evaluate(() => { const A = window.PFAnim; if (!A) return null; const c = A.canvas(), w = document.querySelector('#pfb-board .pfb-world');
    return { place: A.st.place, fire: A.st.fire, car: A.st.car, aoe: A.st.aoe, err: A.st.err, drawn: A.st.drawn, steps: A.st.ev.filter(e => e[0] === 's').map(e => e[1]), ready: A.ready(), mode: A.mode(), active: A.active(),
      inWorld: !!(c && w && c.parentNode === w), z: c ? getComputedStyle(c).zIndex : null, pe: c ? getComputedStyle(c).pointerEvents : null }; });
  const ink = (pg) => pg.evaluate(() => { const c = window.PFAnim && window.PFAnim.canvas(); if (!c || !c.width) return 0; const d = c.getContext('2d').getImageData(0, 0, c.width, c.height).data; let n = 0; for (let i = 3; i < d.length; i += 4) if (d[i]) n++; return n; });
  const boardBox = (pg) => pg.evaluate(() => { const r = document.getElementById('pfb-board').getBoundingClientRect(); return [Math.round(r.x), Math.round(r.y), Math.round(r.width), Math.round(r.height), document.documentElement.scrollWidth <= document.documentElement.clientWidth]; });
  // a fresh replay of the turn the server holds: clear the replay key and reload
  const replay = async (pg, fx, during) => {
    await setFxOn(pg, fx); await pg.evaluate(() => { try { sessionStorage.clear(); } catch (e) {} });
    await pg.reload({ waitUntil: 'domcontentloaded' });
    await pg.waitForFunction(() => window.PFAnim && document.getElementById('pfight'), null, { timeout: 15000 });
    await pg.waitForFunction(() => { const f = document.getElementById('pfight'); return f && f.classList.contains('pf-playing'); }, null, { timeout: 15000 }).catch(() => {});
    const box0 = await boardBox(pg); let r = null;
    if (during) r = await during(); else await pg.waitForTimeout(300);
    const box1 = await boardBox(pg);
    await quiet(pg); await pg.waitForTimeout(300);
    return { st: await stats(pg), box0, box1, end: await boardBox(pg), r };
  };
  const setFxOn = async (pg, v) => pg.evaluate(v => { try { localStorage.setItem('pfvspd', '1'); if (v) localStorage.setItem('pfvfx', v); else localStorage.removeItem('pfvfx'); } catch (e) {} }, v);
  const turn = async () => {   // a hand piece with a lit spot, on it, End turn
    await p.waitForFunction(() => { const f = document.getElementById('pfight'); return f && !f.classList.contains('pf-turnhold') && !f.classList.contains('pf-playing'); }, null, { timeout: 8000 }).catch(() => {});
    const n = await p.locator('#pf-hand .pf-tile').count();
    for (let i = 0; i < n; i++) {
      const t = p.locator('#pf-hand .pf-tile').nth(i); if (!(await t.isVisible()) || (await t.getAttribute('aria-disabled')) === 'true') continue;
      await t.click({ timeout: 3000 }).catch(() => {}); await p.waitForTimeout(250);
      if (await p.locator('#pfb-board .pfb-lit').count()) { await p.locator('#pfb-board .pfb-lit').first().click(); await p.waitForTimeout(250); await p.locator('#pf-go').click(); return true; }
      await t.click({ timeout: 3000 }).catch(() => {}); await p.waitForTimeout(150);
    }
    return false;
  };
  const steps = (s) => s.slice(1).map(t => Math.round(t - s[0]));
  let shot = 0;
  for (const [name, slug, aoe, w] of [['small-3x3', 'leopard-slug', '', 3], ['medium-4x4', 'ghost-slug', '', 4], ['large-5x5', 'grey-heron', '', 5], ['boss-aoe', 'coconut-crab-titan', 'aoe', 5]]) {
    const sd = JSON.parse(php(`${here}/pfv1_sizes_seed.php`, game, slug, aoe));
    if (sd.err) { ok(`${name}: seeded`, false, sd); continue; }
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await setFx(''); await p.evaluate(() => { try { sessionStorage.clear(); } catch (e) {} });
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(800);
    const L = await p.evaluate(() => { const d = JSON.parse(document.getElementById('pf-data').textContent); return { w: d.w, h: d.h, slug: d.cslug, anim: !!document.querySelector('script[src*="pfanim.js"]') }; });
    ok(`${name}: ${L.w}x${L.h} board, the page loads pfanim.js and names the creature (${L.slug})`, L.w === w && L.h === w && L.anim && L.slug === slug, L);
    const s0 = await stats(p);
    ok(`${name}: first load: engine and data ready, nothing played (no replay yet)`, s0 && s0.ready && s0.place + s0.fire === 0, s0);
    if (!(await turn())) { ok(`${name}: a piece could be placed`, false); continue; }
    await p.waitForFunction(() => { const f = document.getElementById('pfight'); return f && f.classList.contains('pf-playing'); }, null, { timeout: 15000 }).catch(() => {});
    await quiet(p); await p.waitForTimeout(400);
    const s1 = await stats(p);
    ok(`${name}: the turn's replay landed and fired pieces on the overlay (place ${s1 && s1.place}, fire ${s1 && s1.fire}, chain ${s1 && s1.car})`, s1 && s1.fire > 0 && s1.place > 0 && s1.drawn > 0 && s1.err === 0, s1);
    // full, with a frozen frame mid-effect
    const F = await replay(p, 'full', async () => {
      await p.waitForFunction(() => window.PFAnim.st.fire > 0 || window.PFAnim.st.place > 0, null, { timeout: 12000 }).catch(() => {});
      if (aoe) { await p.evaluate(() => { const d = JSON.parse(document.getElementById('pf-data').textContent); if (d.aoe && d.aoe.cells) window.PFAnim.aoe(d.aoe.cells, { step: 950 }); }); }
      await p.evaluate(a => window.PFAnim.seek(a ? 260 : 300), !!aoe);
      const r = { ink: await ink(p), st: await stats(p) };
      if (name !== 'large-5x5') { const bd = await p.$('#pfb-board'); await bd.screenshot({ path: `${shots}/pfanim-${name}.png` }); shot++; }
      await p.evaluate(() => window.PFAnim.seek(null));
      return r;
    });
    ok(`${name}: full: canvas in the board's world, z-index 7, never takes a tap`, F.r.st.inWorld && F.r.st.z === '7' && F.r.st.pe === 'none', F.r.st);
    ok(`${name}: full: pixels drawn mid-effect (${F.r.ink})`, F.r.ink > 20, F.r.ink);
    const O = await replay(p, 'off');
    ok(`${name}: the layout is the same with the effects on and off (board box at the start and the end of the replay), no sideways scroll`, JSON.stringify([F.box0, F.end]) === JSON.stringify([O.box0, O.end]) && F.box1[4] && F.end[4], { full: [F.box0, F.end], off: [O.box0, O.end] });
    ok(`${name}: off: nothing started, nothing drawn`, O.st.place === 0 && O.st.fire === 0 && (await ink(p)) === 0 && O.st.mode === 'off', O.st);
    const sa = steps(F.st.steps), sb = steps(O.st.steps), dmax = sa.length === sb.length ? Math.max(0, ...sa.map((t, i) => Math.abs(t - sb[i]))) : -1;
    ok(`${name}: the replay's ${sa.length + 1} steps come at the same times with the effects on and off (max drift ${dmax} ms)`, sa.length > 0 && sa.length === sb.length && dmax <= 60, { full: sa, off: sb });
    const G = await replay(p, 'light');
    ok(`${name}: light: pieces land, nothing fires`, G.st.place > 0 && G.st.fire === 0 && G.st.car === 0, G.st);
    const K = await replay(p, 'full', async () => {
      await p.waitForFunction(() => window.PFAnim.active() > 0, null, { timeout: 12000 }).catch(() => {});
      const a0 = await p.evaluate(() => window.PFAnim.active());
      if (await p.locator('#pf-skip').isVisible()) await p.locator('#pf-skip').click(); else await p.evaluate(() => document.getElementById('pfb-board').click());
      await p.waitForTimeout(120);
      return { a0, a1: await p.evaluate(() => window.PFAnim.active()), ink: await ink(p), playing: await playing(p) };
    });
    ok(`${name}: a skip drops every effect at once (active ${K.r.a0} -> ${K.r.a1}, canvas empty)`, K.r.a0 > 0 && K.r.a1 === 0 && K.r.ink === 0 && !K.r.playing, K.r);
    if (name === 'large-5x5') {   // a history rewind (a chip of this turn) shows no effects
      const R = await p.evaluate(() => { const ch = [...document.querySelectorAll('.pf-hist .pf-chip:not([hidden])')]; if (ch.length < 2) return null; const f0 = window.PFAnim.st.fire, p0 = window.PFAnim.st.place; ch[ch.length - 1].click(); return { f0, p0 }; });
      if (R) { await p.waitForTimeout(400); const s = await stats(p); ok(`${name}: rewinding to an old chip starts no effect`, s.fire === R.f0 && s.place === R.p0 && s.active === 0, s); }
    }
  }
  ok(`3 screenshots written (${shot})`, shot === 3, shot);
  ok('no page errors (full / light / off / skip)', errs.length === 0, errs);
  // reduced motion: no choice = off; Full chosen = full; the help sheet has the setting
  const RM = await mk(true);
  await RM.p.goto(base + '/adventure.php', { waitUntil: 'networkidle' });
  const rm0 = await replay(RM.p, '');
  ok('reduced motion, nothing chosen: the effects are off', rm0.st.mode === 'off' && rm0.st.place === 0 && rm0.st.fire === 0, rm0.st);
  const rm1 = await replay(RM.p, 'full');
  ok('reduced motion, Full chosen: the effects play', rm1.st.mode === 'full' && rm1.st.fire > 0, rm1.st);
  const sheet = await RM.p.evaluate(() => { const b = document.querySelector('#pfv-row [data-a="help"], .pfv-help, [data-a="help"]'); if (b) b.click(); return !!b; });
  await RM.p.waitForTimeout(300);
  const row = await RM.p.evaluate(() => [...document.querySelectorAll('[data-pfx]')].map(b => b.textContent + (b.classList.contains('primary') ? '*' : '')));
  if (sheet && row.length) {
    ok('the help sheet has Piece effects: Full / Light / Off (Full marked)', row.join() === 'Full*,Light,Off', row);
    await RM.p.locator('[data-pfx="light"]').click(); await RM.p.waitForTimeout(200);
    ok('choosing Light is stored per device (pfvfx)', await RM.p.evaluate(() => localStorage.getItem('pfvfx') === 'light' && window.PFAnim.mode() === 'light'));
  } else ok('the help sheet opens with the Piece effects row', false, { sheet, row });
  ok('no page errors (reduced motion)', RM.errs.length === 0, RM.errs);
  await b.close();
  console.log(fails ? `pfanim: ${fails} FAILED` : 'pfanim: done');
  process.exit(fails ? 1 : 0);
})();
