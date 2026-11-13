// 2.6.80: the puzzle fight on the Trail lives in a MODAL <dialog id="trailpop"> (Josh: "End turn still reloads the popover"). Every turn is swapped in place; the dialog must stay the
// SAME open modal element through it: no close/reopen, no new element, the card keeps its scroll, no frame with an empty board, no navigation.
//   node tests/pfv1_trail.js BASE GAME TESTSDIR      (needs gnav_on + gnav_tiles + a tile walk under way: see tests/pfv1_charm.sh)
const { chromium, devices } = require('playwright');
const { execSync } = require('child_process');
const [base, game, here] = process.argv.slice(2);
const seed = (...a) => execSync(`php -d display_errors=1 ${here}/pbox_v1_seed.php ${game} ${a.join(' ')}`).toString().trim();
const SHOTS = process.env.SHOTS || '';
let fails = 0;
const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { console.log(`FAIL ${what} (got ${g}, want ${w})`); fails++; } };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  for (const [vw, vh, scheme] of [[390, 844, 'light'], [360, 640, 'dark']]) {
    const c = await b.newContext({ ...devices['Pixel 7'], viewport: { width: vw, height: vh }, colorScheme: scheme });
    await c.addInitScript(() => {
      window.__ev = []; window.__blank = 0; window.__armed = false; window.__modalLost = 0; window.__scrollMin = 1e9; window.__gone = 0;
      window.addEventListener('beforeunload', () => window.__ev.push('beforeunload'));
      document.addEventListener('close', e => { if (e.target.id === 'trailpop') window.__ev.push('close'); }, true);
      document.addEventListener('cancel', e => { if (e.target.id === 'trailpop') window.__ev.push('cancel'); }, true);
      document.addEventListener('submit', e => setTimeout(() => { if (!e.defaultPrevented) window.__ev.push('plain submit'); }, 0));
      const tick = () => {
        if (window.__armed) {
          const d = document.getElementById('trailpop'), f = document.getElementById('pfight'), bd = document.getElementById('pfb-board');
          if (!d) window.__gone++; else { if (d !== window.__dlg && !window.__newd) { window.__newd = 1; window.__ev.push('new dialog element'); } if (!d.matches(':modal')) window.__modalLost++; }
          if (!window.__over && (!f || !bd || !bd.children.length) && !document.querySelector('.pfv-ghost')) window.__blank++;
          if (f && !window.__over && f.getBoundingClientRect().height < 200) window.__collapsed = (window.__collapsed || 0) + 1;   // 2.6.84: the fight shrank to a thin bar while a turn was swapped in (the pf-in fade-in of its panel)
          const h = d && d.querySelector('.hubcard'); if (h && window.__ctop !== undefined && h.scrollTop < window.__ctop - 1 && !window.__over) window.__scrollMin = Math.min(window.__scrollMin, h.scrollTop);
        }
        requestAnimationFrame(tick);
      };
      requestAnimationFrame(tick);
    });
    const p = await c.newPage(); const L = { errs: [], navs: [], posts: [], bad: [] };
    p.on('pageerror', e => L.errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') L.errs.push(m.text()); });
    p.on('framenavigated', f => { if (f === p.mainFrame()) L.navs.push(f.url().replace(base, '')); });
    p.on('request', r => { if (r.method() === 'POST' && r.resourceType() === 'document') L.posts.push(r.url()); });
    p.on('response', r => { if (r.status() >= 400) L.bad.push(r.status() + ' ' + r.url()); });
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await p.press('input[name=password]', 'Enter'); await p.waitForLoadState('networkidle');
    const tag = `${vw}x${vh} ${scheme}`;
    const open = async () => {
      await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(600); L.errs = []; L.navs = []; L.posts = []; L.bad = [];
      await p.evaluate(() => {
        const d = document.getElementById('trailpop'); window.__dlg = d; window.__mark = 1; window.__ev = []; window.__blank = 0; window.__modalLost = 0; window.__gone = 0; window.__over = false; window.__newd = 0;
        const h = d.querySelector('.hubcard'); h.scrollTop = Math.min(120, h.scrollHeight - h.clientHeight); window.__ctop = h.scrollTop; window.scrollTo(0, 0); window.__wy = window.scrollY; window.__scrollMin = 1e9; window.__armed = true;
      });
      return p.evaluate(() => ({ modal: window.__dlg.matches(':modal'), top: window.__ctop, room: window.__dlg.querySelector('.hubcard').scrollHeight - window.__dlg.querySelector('.hubcard').clientHeight }));
    };
    const done = async (what, ended) => {
      await p.waitForTimeout(500);
      const s = await p.evaluate((ended) => { const d = document.getElementById('trailpop'); const h = d && d.querySelector('.hubcard'); return { mark: window.__mark, ev: window.__ev, blank: window.__blank, same: d === window.__dlg, modal: !!d && d.matches(':modal') && d.open, lost: window.__modalLost, gone: window.__gone, top: h ? h.scrollTop : -1, want: window.__ctop, min: window.__scrollMin, wy: window.scrollY, wy0: window.__wy }; }, ended).catch(() => ({ mark: 'gone' }));
      ck(`[${tag}] ${what}: same document, no navigation/close/cancel/new dialog/plain submit`, [s.mark, L.navs.length, s.ev, L.posts.length], [1, 0, [], 0]);
      ck(`[${tag}] ${what}: the SAME dialog element, open and modal in every frame`, [s.same, s.modal, s.lost, s.gone], [true, true, 0, 0]);
      ck(`[${tag}] ${what}: the fight never collapses to a thin bar and the map never shows (2.6.84)`, await p.evaluate(() => [window.__collapsed || 0, !!document.querySelector('dialog.trailpop.pfdlg')]), [0, true]);
      await p.evaluate(() => { window.__collapsed = 0; });
      ck(`[${tag}] ${what}: the page scroll is unchanged`, s.wy, s.wy0);
      if (!ended) ck(`[${tag}] ${what}: the card never scrolls back (it is not the scroller: the fight is a fixed full screen), no empty-board frame`, [s.min === 1e9, s.blank], [true, 0]);
      ck(`[${tag}] ${what}: no failed request, no console error`, [L.bad, L.errs.filter(x => !/ResizeObserver/.test(x))], [[], []]);
      return s;
    };
    const quiet = () => p.waitForFunction(() => { const f = document.getElementById('pfight'); return f && !f.classList.contains('pf-playing'); }, null, { timeout: 25000 }).then(() => p.waitForTimeout(400)).catch(() => {});
    const hand = async (i) => {   // 2.6.94: on a 4 x 4 board the piece asked for may have no spot after a turn: take the next hand piece that has one (all Charm pieces here)
      await p.locator('#pf-hand .pf-tile').nth(i).tap(); await p.waitForTimeout(250);
      if (await p.locator('#pfb-board .pfb-lit').count()) return;
      await p.locator('#pf-hand .pf-tile').nth(i).tap(); await p.waitForTimeout(150);
      for (let j = 0; j < 5; j++) { if (j === i) continue; await p.locator('#pf-hand .pf-tile').nth(j).tap(); await p.waitForTimeout(350); if (await p.locator('#pfb-board .pfb-lit').count()) return; await p.locator('#pf-hand .pf-tile').nth(j).tap(); await p.waitForTimeout(150); }
    };
    const cell = async () => { await p.locator('#pfb-board .pfb-lit').first().tap(); await p.waitForTimeout(200); };
    const start = async (kind, ...more) => { seed('fight', 'small'); seed(kind === 'nofit' ? 'nofit' : 'charm', ...(kind === 'nofit' ? ['7'] : ['7', more[0] || 'plain'])); await p.evaluate(() => localStorage.setItem('pfvspd', '2')).catch(() => {}); const o = await open(); ck(`[${tag}] fight is in the modal Trail dialog`, [o.modal, await p.locator('#trailpop #pfight').count()], [true, 1]); };
    const shot = async (n) => { if (SHOTS) await p.screenshot({ path: `${SHOTS}/${n}-${vw}-${scheme}.png` }); };

    await start('charm'); await hand(0); await cell(); await shot('before'); await p.locator('#pf-go').tap(); await p.waitForTimeout(60); await shot('mid'); await quiet(); await done('End turn');
    await start('charm'); for (const i of [0, 1]) { await hand(i); await cell(); await p.locator('#pf-go').tap(); await quiet(); } await done('two End turns in a row');
    await start('charm'); await hand(0); await cell(); await p.locator('#pf-undo').tap(); await hand(3); await cell(); await p.locator('#pf-go').tap(); await quiet(); await done('Undo then End turn');
    await start('charm'); await hand(0); if (await p.locator('#pf-flip').isEnabled()) await p.locator('#pf-flip').tap(); await p.waitForTimeout(900); await cell(); await p.locator('#pf-go').tap(); await quiet(); await done('Flip then End turn');
    await start('nofit'); await p.locator('#pf-pass').tap(); await quiet(); await done('Pass');
    await start('charm', 'near'); await hand(0); await cell(); await p.evaluate(() => { window.__over = true; }); await p.locator('#pf-go').tap(); await p.waitForSelector('#pfv-res', { state: 'visible', timeout: 25000 }).catch(() => {});
    const e = await done('charm win to the result card', true);
    ck(`[${tag}] the result card shows inside the same dialog`, await p.locator('#trailpop #pfv-res').count(), 1);
    await c.close();
  }
  console.log('trail: done'); await b.close(); process.exit(fails ? 1 : 0);
})();
