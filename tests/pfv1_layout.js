// 2.6.96 (owner: "Whole game covers over the website, we still want to see it behind it!"): the v1 fight sits OVER the site, not instead of it.
// Both ways in (the plain adventure page, and the MODAL Trail dialog #trailpop after a tile walk), at a phone (390x844, 360x640) and a desktop (1280x720, 1440x900):
//   - no page scroll, the fight fills the height between the site's header and bottom bar (a phone in the Trail dialog: the whole window, as before), End turn in view;
//   - desktop: the fight is a centred column no wider than MAXW, and the site shows at its left and right AND in the header row: the pixels there keep at least
//     MINVIS of their contrast against the same page with the fight hidden (a solid cover keeps 0, the old .78 dim kept about .2);
//   - Escape (pressed three times) never closes the Trail dialog or drops the fight; a reload lands on the same fight; End turn still works at a desktop size.
//   node tests/pfv1_layout.js BASE GAME TESTSDIR    (tests/pfv1_layout.sh sets it up; SHOTS=dir saves screenshots)
const { chromium, devices } = require('playwright');
const { execSync } = require('child_process');
const [base, game, here] = process.argv.slice(2);
const seed = (...a) => execSync(`php -d display_errors=1 ${here}/pbox_v1_seed.php ${game} ${a.join(' ')}`).toString().trim();
const SHOTS = process.env.SHOTS || '', TAG = process.env.TAG || 'after', MAXW = 600, MINVIS = 0.4;
let fails = 0;
const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { console.log(`FAIL ${what} (got ${g}, want ${w})`); fails++; } };
const VIEWS = [[390, 844, 'light', true], [360, 640, 'dark', true], [1280, 720, 'light', false], [1440, 900, 'dark', false]];
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  for (const path of ['page', 'trail']) {
    if (path === 'trail') execSync(`php ${here}/here.php ${game} cli tilewalk`);
    for (const [vw, vh, scheme, phone] of VIEWS) {
      const c = await b.newContext(phone ? { ...devices['Pixel 7'], viewport: { width: vw, height: vh }, colorScheme: scheme, bypassCSP: true } : { viewport: { width: vw, height: vh }, colorScheme: scheme, bypassCSP: true });   // bypassCSP: the hide-the-fight style for the contrast check
      const p = await c.newPage(); const errs = [];
      p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
      await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await p.press('input[name=password]', 'Enter'); await p.waitForLoadState('networkidle');
      const tag = `[${path} ${vw}x${vh} ${scheme}]`;
      seed('fight', 'small'); seed('charm', '7', 'plain');
      await p.evaluate(() => localStorage.setItem('pfvspd', '2')).catch(() => {});
      await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(900);
      const inDlg = await p.locator('#trailpop #pfight').count();
      ck(`${tag} the fight is on screen (${path === 'trail' ? 'in the modal Trail dialog' : 'on the page'})`, [await p.locator('#pfight.pfv-fit').count(), inDlg, path === 'trail' ? await p.evaluate(() => document.getElementById('trailpop').matches(':modal')) : false], [1, path === 'trail' ? 1 : 0, path === 'trail']);
      const m = await p.evaluate(() => {
        const f = document.getElementById('pfight').getBoundingClientRect(), se = document.scrollingElement, go = document.getElementById('pf-go');
        const cs = getComputedStyle(document.documentElement), top = parseFloat(cs.getPropertyValue('--pfv-top')) || 0, bot = parseFloat(cs.getPropertyValue('--pfv-bot')) || 0;
        const hd = document.querySelector('.bannerin'), hr = hd ? hd.getBoundingClientRect() : null, g = go ? go.getBoundingClientRect() : null;
        return { f: { l: Math.round(f.left), r: Math.round(f.right), t: Math.round(f.top), b: Math.round(f.bottom), w: Math.round(f.width) }, top, bot, iw: innerWidth, ih: innerHeight,
          scroll: se.scrollHeight - se.clientHeight, wx: se.scrollWidth - se.clientWidth, hb: hr ? Math.round(hr.bottom) : 0, go: g ? [Math.round(g.top), Math.round(g.bottom)] : null };
      });
      ck(`${tag} the page does not scroll (no vertical or sideways overflow)`, [m.scroll <= 0, m.wx <= 0], [true, true]);
      ck(`${tag} the fight fills the height between the header and the bottom bar`, [Math.abs(m.f.t - m.top) <= 1, Math.abs(m.f.b - (m.ih - m.bot)) <= 1, m.f.b - m.f.t >= m.ih - m.top - m.bot - 2], [true, true, true]);
      ck(`${tag} End turn is in view`, !!m.go && m.go[0] >= m.f.t && m.go[1] <= m.f.b, true);
      if (phone) ck(`${tag} a phone: the fight is the full width`, m.f.w >= vw - 1, true);
      else {
        ck(`${tag} desktop: the fight is a centred column no wider than ${MAXW}px (${m.f.w})`, [m.f.w <= MAXW, m.f.w >= 380, Math.abs((m.f.l + m.f.r) / 2 - vw / 2) <= 2], [true, true, true]);
        ck(`${tag} desktop: the site's header is in view above the fight`, [m.hb > 0, m.f.t >= m.hb - 1], [true, true]);
        // the site behind: the pixels left and right of the fight and in the header row keep their contrast (std of the luminance) against the same page with the fight hidden
        const shotA = (await p.screenshot()).toString('base64');
        await p.addStyleTag({ content: '#pfight, .pfv-ghost { visibility: hidden !important; box-shadow: none !important; } dialog#trailpop { visibility: hidden !important; } dialog#trailpop::backdrop { background: transparent !important; backdrop-filter: none !important; }' });
        await p.waitForTimeout(150);
        const shotB = (await p.screenshot()).toString('base64');
        await p.evaluate(() => { const s = document.querySelectorAll('style'); s[s.length - 1].remove(); });
        const vis = await p.evaluate(async ([a, bb, f, hb]) => {
          const load = (s) => new Promise(r => { const i = new Image(); i.onload = () => { const c = document.createElement('canvas'); c.width = i.width; c.height = i.height; const x = c.getContext('2d'); x.drawImage(i, 0, 0); r(x); }; i.src = 'data:image/png;base64,' + s; });
          const A = await load(a), B = await load(bb);
          const sd = (ctx, x0, y0, x1, y1) => { const d = ctx.getImageData(x0, y0, x1 - x0, y1 - y0).data; let s = 0, s2 = 0, n = 0; for (let i = 0; i < d.length; i += 4) { const l = 0.2126 * d[i] + 0.7152 * d[i + 1] + 0.0722 * d[i + 2]; s += l; s2 += l * l; n++; } const mu = s / n; return Math.sqrt(Math.max(0, s2 / n - mu * mu)); };
          const r = (x0, y0, x1, y1) => { const sb = sd(B, x0, y0, x1, y1); return sb < 2 ? null : Math.round(sd(A, x0, y0, x1, y1) / sb * 100) / 100; };
          return { left: r(0, Math.max(hb, f.t), f.l - 4, f.b), right: r(f.r + 4, Math.max(hb, f.t), innerWidth, f.b), head: hb > 8 ? r(0, 0, innerWidth, hb) : null };
        }, [shotA, shotB, m.f, m.hb]);
        console.log(`     ${tag} contrast kept: left ${vis.left}, right ${vis.right}, header ${vis.head}`);
        ck(`${tag} desktop: the site shows at the left and right of the fight and in the header (contrast kept >= ${MINVIS})`, [vis.left !== null && vis.left >= MINVIS, vis.right !== null && vis.right >= MINVIS, vis.head !== null && vis.head >= MINVIS], [true, true, true]);
      }
      if (SHOTS) await p.screenshot({ path: `${SHOTS}/${TAG}-${path}-${vw}x${vh}.png` });
      // Escape must never close the Trail dialog or drop the fight (Chrome closes a dialog whose cancel was refused twice without a user tap in between)
      for (let i = 0; i < 3; i++) { await p.keyboard.press('Escape'); await p.waitForTimeout(120); }
      await p.waitForTimeout(400);
      ck(`${tag} Escape x3: the fight is still on screen${path === 'trail' ? ' in the open modal dialog' : ''}`, await p.evaluate(() => { const d = document.getElementById('trailpop'), f = document.getElementById('pfight'); return [!!f && f.getBoundingClientRect().height > 200, d ? d.open && d.matches(':modal') : null]; }), [true, path === 'trail' ? true : null]);
      // End turn at a desktop size (the board fits the narrower column), then a reload lands on the same fight
      if (!phone) {
        await p.locator('#pf-hand .pf-tile').first().click(); await p.waitForTimeout(300);
        if (await p.locator('#pfb-board .pfb-lit').count()) { await p.locator('#pfb-board .pfb-lit').first().click(); await p.waitForTimeout(200); await p.locator('#pf-go').click();
          await p.waitForFunction(() => { const f = document.getElementById('pfight'); return f && !f.classList.contains('pf-playing'); }, null, { timeout: 25000 }).catch(() => {}); await p.waitForTimeout(500); }
        ck(`${tag} after End turn: the fight is still a column of the same width, the page does not scroll`, await p.evaluate(() => { const f = document.getElementById('pfight'), r = f && f.getBoundingClientRect(), se = document.scrollingElement; return [!!f && r.width <= 600 && r.height > 300, se.scrollHeight - se.clientHeight <= 0]; }), [true, true]);
      }
      const before = await p.evaluate(() => document.getElementById('pfb-board').children.length);
      await p.reload({ waitUntil: 'networkidle' }); await p.waitForTimeout(700);
      ck(`${tag} a reload lands on the same fight`, [await p.locator('#pfight.pfv-fit').count(), await p.evaluate(() => document.getElementById('pfb-board').children.length) === before], [1, true]);
      ck(`${tag} no console error`, errs.filter(x => !/ResizeObserver/.test(x)), []);
      await c.close();
    }
  }
  console.log('layout: done'); await b.close(); process.exit(fails ? 1 : 0);
})();
