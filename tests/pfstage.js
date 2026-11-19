// node tests/pfstage.js BASE GAME TESTSDIR : puzzle fight stage mode (setting pfight_stage on), the whole flow on the real page, phone and wide:
//   a fight that starts (a tap on the map while a creature waits): the jigsaw comes in over the map FIRST, the pre-fight card shows on top of it and the pieces STAY;
//   Let's fight: the card fades into the combat section and the pieces leave; a turn keeps the dialog node; Run: the result card is OVER the map (never above it) with the pieces
//   again, and its button sends them away; End match: a cover over the swap that removes the fight; the page is not dimmed; no JS errors. Prints "ok ..." / "FAIL ..." lines.
const { chromium } = require('playwright');
const { execFileSync } = require('child_process');
const [base, game, here] = process.argv.slice(2);
const php = (...a) => execFileSync('php', ['-d', 'display_errors=1', ...a], { encoding: 'utf8' });
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  let fail = 0;
  const chk = (ok, msg) => { console.log((ok ? 'ok   ' : 'FAIL ') + msg); if (!ok) fail = 1; };
  for (const [name, vp] of [['wide', { width: 1280, height: 900 }], ['phone', { width: 412, height: 900 }]]) {
    php(here + '/here.php', game, 'cli', 'tilewalk'); php(here + '/here.php', game, 'cli', 'clearenc');
    const c = await b.newContext({ viewport: vp, deviceScaleFactor: 1, hasTouch: name === 'phone' }); const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(500);
    const st = () => p.evaluate(() => {
      const d = document.querySelector('dialog.trailpop.pfst'), L = document.querySelector('.pfst-layer'), pb = d && d.querySelector('.pickbox');
      return { dlg: !!d, held: !!(d && d.classList.contains('pfst-held')), on: !!(d && d.classList.contains('pfst-on')), layer: L ? L.children.length : 0, hidden: pb ? getComputedStyle(pb).visibility === 'hidden' : null, pre: !!document.getElementById('pfv-pre'), board: !!document.querySelector('#pfight.pf-screen'), res: !!document.querySelector('.pfst-res'),
        ghost: !!document.querySelector('.pfst-ghost'), modal: d ? d.matches(':modal') : false, resOutside: [...document.querySelectorAll('.res.pfv')].filter(e => !e.closest('dialog')).length };
    });
    const until = async (f, ms = 6000) => { const t0 = Date.now(); for (;;) { const s = await st(); if (f(s)) return s; if (Date.now() - t0 > ms) return null; await p.waitForTimeout(60); } };

    // ---- start: a creature waits, the player taps the map
    chk((await st()).dlg === false, `[${name}] the map shows, no fight yet`);
    php(here + '/pbox_v1_seed.php', game, 'fight', 'small');
    await p.locator('.tmt.reach').first().click({ force: true });
    const sawCover = await until(s => s.dlg && s.layer > 0 && s.hidden === true);
    chk(!!sawCover, `[${name}] the jigsaw comes in while the fight card is still hidden`);
    const held = await until(s => s.on && s.pre && s.layer > 0 && s.held && s.hidden === false);
    chk(!!held, `[${name}] the pre-fight card shows on top of the pieces and they stay (held)`);
    await p.waitForTimeout(1200);
    const still = await st(); chk(still.layer > 0 && still.held && still.pre, `[${name}] still held a second later: the pieces cover the map until the player accepts`);
    const geo = await p.evaluate(() => { const d = document.querySelector('dialog.trailpop.pfst'), m = document.querySelector('.advgrid .tmwrap'), dr = d.getBoundingClientRect(), mr = m.getBoundingClientRect(), pre = document.getElementById('pfv-pre').getBoundingClientRect(), cs = getComputedStyle(d);
      return { pos: cs.position, dx: dr.left, dy: dr.top, dw: dr.width, dh: dr.height, mx: mr.left, my: mr.top, mw: mr.width, mh: mr.height, px: pre.left, pw: pre.width, bd: getComputedStyle(d, '::backdrop').backgroundColor, modal: d.matches(':modal'), sw: document.documentElement.scrollWidth, iw: innerWidth }; });
    chk(Math.abs(geo.dx - geo.mx) < 3 && Math.abs(geo.dy - geo.my) < 3 && Math.abs(geo.dw - Math.min(geo.mw, 760)) < 3 && geo.dh >= geo.mh - 3, `[${name}] the fight sits on the tile map's box (x ${Math.round(geo.dx)}/${Math.round(geo.mx)}, y ${Math.round(geo.dy)}/${Math.round(geo.my)}, w ${Math.round(geo.dw)}/${Math.round(geo.mw)}, h ${Math.round(geo.dh)}/${Math.round(geo.mh)})`);
    chk(geo.px >= geo.dx - 1 && geo.px + geo.pw <= geo.dx + geo.dw + 1, `[${name}] the pre-fight card fits inside that box (it is not a full-window panel)`);
    chk(/rgba\(0, 0, 0, 0\)|transparent/.test(geo.bd) && geo.modal && geo.sw <= geo.iw, `[${name}] not dimmed, still a real modal, no sideways scroll`);

    // ---- accept the deck: the card fades into combat, the pieces leave
    await p.locator('#pfv-pre .pfv-gof button').first().click({ force: true });
    const mid = await until(s => s.ghost || s.board, 3000); chk(!!mid, `[${name}] Let's fight: a ghost of the card (or the board) appears`);
    const fightOn = await until(s => s.board && !s.pre && s.on, 5000); chk(!!fightOn, `[${name}] the combat section is there`);
    const gone = await until(s => s.board && s.layer === 0 && !s.held && !s.ghost, 4000); chk(!!gone, `[${name}] the pieces and the ghost are gone once the fight is on`);

    // ---- a turn through the in-place swap keeps the dialog node
    const hand = p.locator('#pf-hand .pf-tile'); const n = await hand.count(); let lit = 0;
    for (let i = 0; i < n && !lit; i++) { await hand.nth(i).dispatchEvent('click'); await p.waitForTimeout(250); lit = await p.locator('.pfb-lit').count(); }
    if (lit) {
      await p.evaluate(() => { window.__pfd = document.querySelector('dialog.trailpop.pfst'); });
      await p.locator('.pfb-lit').first().dispatchEvent('click');
      await Promise.all([p.waitForResponse(r => r.request().method() === 'POST'), p.click('#pf-go')]); await p.waitForTimeout(1800);
      if (await p.locator('#pf-skip:not([hidden])').count()) await p.click('#pf-skip');
      const keep = await p.evaluate(() => { const d = document.querySelector('dialog.trailpop.pfst'); return d ? { same: d === window.__pfd, on: d.classList.contains('pfst-on') } : null; });
      if (keep) chk(keep.same && keep.on, `[${name}] a turn keeps the dialog node and its reveal`); else console.log('note [' + name + '] the fight ended on that turn');
    } else console.log('note [' + name + '] no lit spot to play');

    // ---- Run: the result card is over the map, never above it
    if (await p.locator('.pf-runf button').count()) {
      await p.locator('.pf-runf button').first().click({ force: true });
      const r1 = await until(s => s.res && s.layer > 0, 6000); chk(!!r1, `[${name}] Run: the result card comes with the pieces`);
      const r2 = await until(s => s.res && s.on && !s.hidden && s.layer > 0, 6000);
      chk(!!r2 && r2.resOutside === 0, `[${name}] the result card is over the map (cards outside a dialog: ${r2 ? r2.resOutside : '?'})`);
      await p.locator('[data-pfst-dismiss]').first().click({ force: true });
      const r3 = await until(s => !s.dlg && s.layer === 0, 6000); chk(!!r3, `[${name}] the button sends the pieces away and the card with them`);
      chk((await st()).resOutside === 0, `[${name}] nothing of the result is left above the map`);
    } else console.log('note [' + name + '] no Run button (the fight ended)');

    // ---- End match: a popover cover over the swap that removes the fight (a fake form with the same do value; the swap is simulated by removing the dialog)
    php(here + '/pbox_v1_seed.php', game, 'fight', 'small'); await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForSelector('dialog.trailpop.pfst.pfst-on', { timeout: 8000 }).catch(() => {});
    const way = await p.evaluate(async () => {
      const d = document.querySelector('dialog.trailpop.pfst'); if (!d) return null;
      const f = document.createElement('form'); f.method = 'post'; f.innerHTML = '<input type="hidden" name="do" value="pf_finish"><button type="submit" id="fake-end">End match</button>'; f.addEventListener('submit', e => e.preventDefault()); d.appendChild(f);
      document.getElementById('fake-end').click(); await new Promise(r => setTimeout(r, 150));
      const mid = document.querySelectorAll('.pfst-cover').length;
      await new Promise(r => setTimeout(r, 1500)); d.remove();
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
