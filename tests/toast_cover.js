// 2.7.08: the toast box (Milestone lines, new Almanac pages, prizes) must not cover a fight's end scene (#fightscene).
// On a game page a stand-in end scene is laid over part of the screen, then a toast is shown (gvShowToasts): it must not overlap the scene;
// when the scene fills nearly the whole screen the box goes top-right and compact (.toasts-top.toasts-tiny); with no scene nothing changes.
//   node tests/toast_cover.js BASE   (tests/toast_cover.sh sets it up)
const { chromium, devices } = require('playwright');
const [base] = process.argv.slice(2);
let fails = 0;
const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { console.log(`FAIL ${what} (got ${g}, want ${w})`); fails++; } };
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  for (const [vw, vh, phone] of [[1280, 720, false], [390, 844, true]]) {
    const c = await b.newContext(phone ? { ...devices['Pixel 7'], viewport: { width: vw, height: vh } } : { viewport: { width: vw, height: vh } });
    const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e)));
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await p.press('input[name=password]', 'Enter'); await p.waitForLoadState('networkidle');
    const tag = `[${vw}x${vh}]`;
    const run = (scene) => p.evaluate(async (scene) => {
      document.querySelectorAll('.toasts, #fightscene').forEach(n => n.remove());
      document.body.classList.remove('fs-hold');
      if (scene) { const s = document.createElement('div'); s.id = 'fightscene'; s.className = 'fightscene fs-done'; Object.assign(s.style, { position: 'fixed', zIndex: 5, ...scene }); document.body.appendChild(s); }
      const n = document.createElement('div'); n.className = 'flash ok'; n.textContent = '🏆 Milestone: Trail Walker, you earned 20 Petals!';
      const pg = document.createElement('div'); pg.className = 'newpages'; pg.textContent = '📖 New Almanac page: The Clover Patch';
      gvShowToasts([n, pg]);
      await new Promise(r => setTimeout(r, 50));
      const box = document.querySelector('.toasts'); const sc = document.getElementById('fightscene');
      if (!box) return { box: false };
      const a = box.getBoundingClientRect(), bb = sc ? sc.getBoundingClientRect() : null;
      const over = !!bb && a.left < bb.right && a.right > bb.left && a.top < bb.bottom && a.bottom > bb.top;
      return { box: true, over, top: box.classList.contains('toasts-top'), tiny: box.classList.contains('toasts-tiny'), onscreen: a.top >= 0 && a.bottom <= innerHeight && a.left >= 0 && a.right <= innerWidth };
    }, scene);
    // the end scene over the lower right part of the screen (where the corner box would go)
    let r = await run({ right: '0px', bottom: '0px', width: '70vw', height: '55vh' });
    ck(`${tag} a scene in the lower right: the box steps aside, on screen`, [r.box, r.over, r.top, r.onscreen], [true, false, true, true]);
    // a scene that fills the screen below the header: compact box at the top
    r = await run({ left: '0px', right: '0px', top: '0px', bottom: '0px' });
    ck(`${tag} a full-screen scene: the box goes compact at the top`, [r.box, r.top, r.tiny, r.onscreen], [true, true, true, true]);
    // no scene: the box stays where it always was
    r = await run(null);
    ck(`${tag} no end scene: no dodge classes`, [r.box, r.top, r.tiny], [true, false, false]);
    ck(`${tag} no page errors`, errs, []);
    await c.close();
  }
  await b.close();
  console.log('toast_cover: done'); process.exit(fails ? 1 : 0);
})().catch(e => { console.log('FAIL ' + e); process.exit(1); });
