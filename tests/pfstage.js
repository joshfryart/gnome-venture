// node tests/pfstage.js BASE OUTDIR : puzzle fight stage mode (setting pfight_stage on). A fight open on load is shown on the map column's box with no dimming; the dialog NODE survives an in-place turn;
// a fight that appears after load gets the jigsaw cover (and is revealed after it), End match covers the swap that removes it and the cover then leaves; no JS errors. Prints "ok ..." / "FAIL ..." lines.
const { chromium } = require('playwright');
(async () => {
  const [base, out] = process.argv.slice(2);
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  let fail = 0;
  const chk = (ok, msg) => { console.log((ok ? 'ok   ' : 'FAIL ') + msg); if (!ok) fail = 1; };
  for (const [name, vp] of [['wide', { width: 1280, height: 900 }], ['phone', { width: 412, height: 900 }]]) {
    const c = await b.newContext({ viewport: vp, deviceScaleFactor: 1, hasTouch: name === 'phone' }); const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' });
    if (!(await p.locator('dialog.trailpop.pfst').count())) { chk(false, `[${name}] no Trail dialog on the page`); await c.close(); continue; }
    await p.waitForSelector('dialog.trailpop.pfst.pfst-on', { timeout: 4000 }).then(() => chk(true, `[${name}] the fight is revealed on load`), () => chk(false, `[${name}] the fight was never revealed (pfst-on missing)`));
    const geo = await p.evaluate(() => {
      const d = document.querySelector('dialog.trailpop.pfst'), m = document.querySelector('.advgrid .mapcol'); const dr = d.getBoundingClientRect(), mr = m.getBoundingClientRect(), cs = getComputedStyle(d);
      return { pos: cs.position, vis: cs.visibility, dx: dr.left, dy: dr.top, dw: dr.width, dh: dr.height, mx: mr.left, my: mr.top, mw: mr.width, mh: mr.height, bd: getComputedStyle(d, '::backdrop').backgroundColor, modal: d.matches(':modal'), pf: !!d.querySelector('#pfight'), open: d.open };
    });
    const wantW = Math.min(geo.mw, 760), wantX = geo.mx + (geo.mw - wantW) / 2;
    chk(geo.pos === 'absolute' && geo.vis === 'visible', `[${name}] dialog is placed (position ${geo.pos}, ${geo.vis})`);
    chk(Math.abs(geo.dx - wantX) < 3 && Math.abs(geo.dy - geo.my) < 3 && Math.abs(geo.dw - wantW) < 3, `[${name}] dialog sits on the map column box (x ${Math.round(geo.dx)}/${Math.round(wantX)}, y ${Math.round(geo.dy)}/${Math.round(geo.my)}, w ${Math.round(geo.dw)}/${Math.round(wantW)})`);
    chk(geo.dh >= geo.mh - 3, `[${name}] the fight is at least as tall as the map column (${Math.round(geo.dh)} vs ${Math.round(geo.mh)})`);
    chk(/rgba\(0, 0, 0, 0\)|transparent/.test(geo.bd), `[${name}] the page is not dimmed (backdrop ${geo.bd})`);
    chk(geo.modal && geo.pf && geo.open, `[${name}] still a real modal around #pfight (keepTrailPop and hubscene.js rely on it)`);
    chk(!(await p.evaluate(() => document.documentElement.scrollWidth > window.innerWidth)), `[${name}] no sideways scroll`);
    // a turn through the in-place swap: the dialog node, its class and its box stay
    const hand = p.locator('#pf-hand .pf-tile'); const n = await hand.count(); let lit = 0;
    for (let i = 0; i < n && !lit; i++) { await hand.nth(i).dispatchEvent('click'); await p.waitForTimeout(250); lit = await p.locator('.pfb-lit').count(); }
    if (lit) {
      await p.evaluate(() => { window.__pfd = document.querySelector('dialog.trailpop.pfst'); });
      await p.locator('.pfb-lit').first().dispatchEvent('click');
      await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pf-go')]); await p.waitForTimeout(1800);
      if (await p.locator('#pf-skip:not([hidden])').count()) await p.click('#pf-skip');
      const keep = await p.evaluate(() => { const d = document.querySelector('dialog.trailpop.pfst'); return d ? { same: d === window.__pfd, on: d.classList.contains('pfst-on'), vis: getComputedStyle(d).visibility } : null; });
      if (keep) chk(keep.same && keep.on && keep.vis === 'visible', `[${name}] a turn keeps the dialog node and its reveal (same node ${keep.same}, pfst-on ${keep.on}, ${keep.vis})`);
      else console.log('note [' + name + '] the fight ended on that turn');
    } else console.log('note [' + name + '] no lit spot to play');
    // a fight that appears after the page loaded: the cover plays, the fight shows after it
    const sim = await p.evaluate(async () => {
      const d = document.querySelector('dialog.trailpop.pfst'); if (!d) return null;
      const host = d.parentNode, next = d.nextSibling;
      document.querySelectorAll('dialog.trailpop link[rel=stylesheet]').forEach(l => document.head.appendChild(l));   // the page's styles stay when the fight goes (they did load with the first fight)
      d.remove(); await new Promise(r => setTimeout(r, 80));
      const nd = document.createElement('dialog'); nd.className = 'picker hubpop trailpop pfdlg pfst'; nd.setAttribute('open', ''); nd.innerHTML = '<div class="pickbox"><div class="hubcard"><div id="pfight">fight</div></div></div>'; host.insertBefore(nd, next);
      await new Promise(r => setTimeout(r, 120));
      const mr = document.querySelector('.advgrid .mapcol') ? document.querySelector('.advgrid .mapcol').getBoundingClientRect() : null;
      const mid = { mr: mr && [Math.round(mr.width), Math.round(mr.height)], cls: nd.className, cover: document.querySelectorAll('.pfst-cover').length, hidden: getComputedStyle(nd).visibility === 'hidden', on: nd.classList.contains('pfst-on') };
      await new Promise(r => setTimeout(r, 2600));
      const end = { cover: document.querySelectorAll('.pfst-cover').length, on: nd.classList.contains('pfst-on'), vis: getComputedStyle(nd).visibility };
      return { mid, end };
    });
    if (sim) {
      chk(sim.mid.cover === 1 && sim.mid.hidden && !sim.mid.on, `[${name}] a new fight is under the cover first (cover ${sim.mid.cover}, hidden ${sim.mid.hidden}, class ${sim.mid.cls}, map ${JSON.stringify(sim.mid.mr)})`);
      chk(sim.end.cover === 0 && sim.end.on && sim.end.vis === 'visible', `[${name}] then the fight shows and the cover is gone (cover ${sim.end.cover}, ${sim.end.vis})`);
    }
    // End match: the cover goes over the fight, the swap removes it, the cover leaves
    const way = await p.evaluate(async () => {
      const d = document.querySelector('dialog.trailpop.pfst'); if (!d) return null;
      const f = document.createElement('form'); f.method = 'post'; f.innerHTML = '<input type="hidden" name="do" value="pf_finish"><button type="submit" id="fake-end">End match</button>'; f.addEventListener('submit', e => e.preventDefault()); d.appendChild(f);
      document.getElementById('fake-end').click(); await new Promise(r => setTimeout(r, 150));
      const mid = document.querySelectorAll('.pfst-cover').length;
      await new Promise(r => setTimeout(r, 1100)); d.remove();
      await new Promise(r => setTimeout(r, 150)); const gone = document.querySelectorAll('.pfst-cover').length;
      await new Promise(r => setTimeout(r, 2200)); const end = document.querySelectorAll('.pfst-cover').length;
      return { mid, gone, end };
    });
    if (way) chk(way.mid === 1 && way.gone === 1 && way.end === 0, `[${name}] End match: cover on at once (${way.mid}), still there when the fight is swapped out (${way.gone}), gone after (${way.end})`);
    chk(errs.length === 0, `[${name}] no JS errors${errs.length ? ': ' + errs.slice(0, 2).join(' | ') : ''}`);
    await c.close();
  }
  await b.close(); process.exit(fail);
})();
