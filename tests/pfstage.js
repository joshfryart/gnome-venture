// node tests/pfstage.js BASE GAME TESTSDIR : puzzle fight stage mode (setting pfight_stage on), the whole flow on the real page, phone and wide:
//   a fight that starts (a tap on the map while a creature waits): the jigsaw comes in over the map FIRST, the pre-fight card shows on top of it and the pieces STAY;
//   Let's fight: new pieces cover the card, the combat section is swapped in under them, they leave; a turn keeps the dialog node; Run: the result card is OVER the map (never above it) with the pieces
//   again, and its button sends them away; End match: a cover over the swap that removes the fight; the page is not dimmed; no JS errors. Prints "ok ..." / "FAIL ..." lines.
const { chromium } = require('playwright');
const { execFileSync } = require('child_process');
const [base, game, here] = process.argv.slice(2);
const php = (...a) => execFileSync('php', ['-d', 'display_errors=1', ...a], { encoding: 'utf8' });
(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  let fail = 0;
  const chk = (ok, msg) => { console.log((ok ? 'ok   ' : 'FAIL ') + msg); if (!ok) fail = 1; };
  for (const [name, vp] of [['wide', { width: 1280, height: 900 }], ['phone', { width: 412, height: 600 }]]) {
    php(here + '/here.php', game, 'cli', 'tilewalk'); php(here + '/here.php', game, 'cli', 'clearenc');
    const c = await b.newContext({ viewport: vp, deviceScaleFactor: 1, hasTouch: name === 'phone' }); const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.waitForTimeout(500);
    const st = () => p.evaluate(() => {
      const d = document.querySelector('dialog.trailpop.pfst'), L = document.querySelector('.pfst-layer'), pb = d && d.querySelector('.pickbox');
      return { dlg: !!d, held: !!(d && d.classList.contains('pfst-held')), on: !!(d && d.classList.contains('pfst-on')), layer: L ? L.children.length : 0, hidden: pb ? getComputedStyle(pb).visibility === 'hidden' : null, pre: !!document.getElementById('pfv-pre'), board: !!document.querySelector('#pfight.pf-screen'), res: !!document.querySelector('.pfst-res'),
        ghost: !!document.querySelector('.pfst-ghost'), top: (document.querySelector('.pfst-top') || { children: [] }).children.length, wait: !!(d && d.classList.contains('pfst-wait')), modal: d ? d.matches(':modal') : false, resOutside: [...document.querySelectorAll('.res.pfv')].filter(e => !e.closest('dialog')).length };
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
    const mid = await until(s => s.top > 0 && s.ghost && s.wait, 3000); chk(!!mid, `[${name}] Let's fight: a second set of pieces flies in over the card (a ghost of the card stays under them)`);
    const fightOn = await until(s => s.board && !s.pre && s.on && !s.wait, 8000); chk(!!fightOn, `[${name}] the combat section shows once the pieces cover the card`);
    const gone = await until(s => s.board && s.layer === 0 && s.top === 0 && !s.held && !s.ghost && !s.wait, 6000); chk(!!gone, `[${name}] all the pieces and the ghost are gone once the fight is on`);

    const fit = await p.evaluate(() => { const d = document.querySelector('dialog.trailpop.pfst').getBoundingClientRect(), h = [...document.querySelectorAll('#pf-hand .pf-tile')], hb = h.length ? Math.max(...h.map(e => e.getBoundingClientRect().bottom)) : 0, bd = document.getElementById('pfb-board'), br = bd ? bd.getBoundingClientRect() : null;
      return { top: Math.round(d.top), bottom: Math.round(d.bottom), ih: innerHeight, hand: Math.round(hb), n: h.length, bh: br ? Math.round(br.height) : 0, bb: br ? Math.round(br.bottom) : 0 }; });
    chk(fit.n > 0 && fit.hand <= fit.ih + 1 && fit.bottom <= fit.ih + 1 && fit.top >= -1, `[${name}] the combat fits the window, the hand is in sight (dialog ${fit.top}-${fit.bottom} of ${fit.ih}, hand bottom ${fit.hand}, ${fit.n} pieces)`);
    chk(fit.bh >= 100 && fit.bb <= fit.ih, `[${name}] the play board is not cut off (board ${fit.bh}px high, bottom ${fit.bb})`);

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

    // ---- a FULL page load with a fight waiting (not an in-place swap): the card must not show while the pieces are still coming in, and the map is followed when it moves
    php(here + '/pbox_v1_seed.php', game, 'fight', 'small'); await p.goto(base + '/adventure.php', { waitUntil: 'commit' });
    const samples = []; for (let i = 0; i < 70; i++) { samples.push(await st()); await p.waitForTimeout(45); }
    const early = samples.filter(s => s.dlg && s.on && !s.hidden && s.layer > 0 && !s.held).length;
    chk(early === 0 && samples.some(s => s.layer > 0 && s.hidden === true), `[${name}] a page load with a fight waiting: the card stays hidden until the pieces are in (card shown mid-flight in ${early} samples)`);
    const fin = samples[samples.length - 1]; chk(fin.held && fin.pre && !fin.hidden, `[${name}] ...then the card shows over the held pieces`);
    const btn = await p.evaluate(() => { const b = document.querySelector('#pfv-pre .pfv-gof button'); const r = b ? b.getBoundingClientRect() : null; return r ? { bottom: r.bottom, ih: innerHeight, focus: document.activeElement === b } : null; });
    chk(!!btn && btn.bottom <= btn.ih + 1, `[${name}] the Let's fight button is on screen (bottom ${btn ? Math.round(btn.bottom) : '?'} of ${btn ? btn.ih : '?'})`);
    chk(!!btn && btn.focus, `[${name}] and it has the focus (the card was hidden when the modal opened)`);
    await p.evaluate(() => { const m = document.querySelector('.advgrid .tmwrap'); m.style.marginTop = '60px'; });   // the map moves without any DOM change (a late stylesheet, an image): the dialog follows
    await p.waitForTimeout(400);
    const fol = await p.evaluate(() => { const d = document.querySelector('dialog.trailpop.pfst').getBoundingClientRect(), m = document.querySelector('.advgrid .tmwrap').getBoundingClientRect(); return { d: Math.round(d.top + scrollY), m: Math.round(m.top + scrollY) }; });
    chk(Math.abs(fol.d - fol.m) < 3, `[${name}] the dialog follows the map when it moves (dialog ${fol.d}, map ${fol.m})`);

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
    // ---- a Trail walk still playing on the map: the pieces wait for it
    const p2 = await c.newPage();
    await p2.addInitScript(() => { document.addEventListener('DOMContentLoaded', () => { const t = document.createElement('div'); t.className = 'tilemap tmplay'; t.id = 'fake-walk'; (document.querySelector('.advgrid .tmwrap') || document.body).appendChild(t); }); });
    await p2.goto(base + '/adventure.php');   // (the seeded fight from the section above is still waiting)
    await p2.waitForTimeout(1500);
    const w1 = await p2.evaluate(() => document.querySelectorAll('.pfst-layer svg').length);
    await p2.evaluate(() => document.getElementById('fake-walk') && document.getElementById('fake-walk').remove());
    await p2.waitForFunction(() => document.querySelectorAll('.pfst-layer svg').length > 0, null, { timeout: 4000 }).catch(() => {});
    const w2 = await p2.evaluate(() => document.querySelectorAll('.pfst-layer svg').length);
    chk(w1 === 0 && w2 > 0, `[${name}] the pieces wait while the walk plays (${w1} pieces during it, ${w2} after)`);
    await p2.close();
    // ---- off the road: (1) a wander begun from a Trail walk (the map behind the card), (2) a wander begun with no map at all (the window). Both get the jigsaw like the Trail, and the result card of a fight run from
    for (const kind of ['behind', 'nomap']) {
      if (kind === 'behind') { php(here + '/here.php', game, 'cli', 'tilewalk'); php(here + '/here.php', game, 'cli', 'clearenc'); await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' }); await p.locator('a[data-pop=hubpop-twander]').first().click(); await p.locator('#hubpop-twander form button').click(); await p.waitForSelector('dialog.wanderpop', { timeout: 8000 }); await p.waitForTimeout(500); }
      else { php(here + '/here.php', game, 'cli', 'endexp'); php(here + '/here.php', game, 'cli', 'at', 'market'); }
      php(here + '/pbox_v1_seed.php', game, 'fight', 'small'); await p.evaluate(() => sessionStorage.removeItem('pfstSeen')); await p.goto(base + '/adventure.php', { waitUntil: 'commit' });
      const w1 = await until(s => s.dlg && s.layer > 0 && s.hidden === true, 8000); chk(!!w1, `[${name}] wander (${kind}): the jigsaw comes in over the fight card`);
      const w2 = await until(s => s.on && s.pre && s.held && s.layer > 0 && s.hidden === false, 8000); chk(!!w2, `[${name}] wander (${kind}): the card shows over the held pieces`);
      await p.locator('#pfv-pre .pfv-gof button').first().click({ force: true });
      const w3 = await until(s => s.top > 0 && s.ghost && s.wait, 4000); chk(!!w3, `[${name}] wander (${kind}): Let's fight brings the second set of pieces`);
      await until(s => s.board && s.layer === 0 && s.top === 0 && !s.wait, 9000);
      if (await p.locator('.pf-runf button').count()) {
        await p.locator('.pf-runf button').first().click({ force: true });
        const w4 = await until(s => s.res && s.on && s.layer > 0 && s.resOutside === 0, 8000); chk(!!w4, `[${name}] wander (${kind}): the result card of a fight run from is over the map's place with the pieces`);
        await p.locator('[data-pfst-dismiss]').first().click({ force: true });
        chk(!!(await until(s => !s.dlg && s.layer === 0, 6000)), `[${name}] wander (${kind}): its button sends the pieces away`);
      } else console.log('note [' + name + '] wander (' + kind + '): no Run button');
    }
    chk(errs.length === 0, `[${name}] no JS errors${errs.length ? ': ' + errs.slice(0, 2).join(' | ') : ''}`);
    await c.close();
  }
  // ---- every page that can carry .pfover (adventure.php: Trail walk, wander, delve, lair), 1280 and 390 wide: the popover sits on the content column (the map's box; a wander with no map: the page column,
  // centred) and the page does not scroll sideways, before the fight (pre-fight card) and in combat. 2.7.30: a delve at >= 1000 px had the popover pushed sideways by the overlay grid.
  for (const [name, vp] of [['wide', { width: 1280, height: 900 }], ['phone', { width: 390, height: 900 }]]) {
    const c = await b.newContext({ viewport: vp, deviceScaleFactor: 1, hasTouch: name === 'phone' }); const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e)));
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    for (const kind of ['trail', 'wander', 'delve', 'lair']) {
      const seeded = php(here + '/pfstage_seed.php', game, kind).trim(); chk(seeded.startsWith('ok '), `[${name}] layout ${kind}: seeded (${seeded})`);
      await p.goto(base + '/adventure.php?view=map', { waitUntil: 'networkidle' }); await p.waitForSelector('dialog.trailpop.pfst.pfst-on', { timeout: 9000 }).catch(() => {}); await p.waitForTimeout(500);
      const box = () => p.evaluate(() => {
        const d = document.querySelector('dialog.trailpop.pfst'); if (!d) return null;
        const r = e => { const x = e.getBoundingClientRect(); return { l: x.left + scrollX, w: x.width, r: x.right + scrollX }; };
        const m = document.querySelector('.advgrid .tmwrap'), mn = document.querySelector('main');
        return { d: r(d), col: m ? r(m) : r(mn), map: !!m, fixed: getComputedStyle(d).position === 'fixed', sw: document.documentElement.scrollWidth, iw: innerWidth, grid: document.querySelector('.advgrid').className };
      });
      const fits = (g, phone) => {   // on a phone the combat fills the window; otherwise the dialog sits on the column (centred on it, never wider than 760)
        if (!g) return false; if (g.sw > g.iw) return false;
        if (phone && g.fixed) return g.d.l >= -1 && g.d.r <= g.iw + 1;
        const cc = g.col.l + g.col.w / 2, dc = g.d.l + g.d.w / 2; return Math.abs(cc - dc) < 3 && g.d.w <= Math.max(g.col.w, 760) + 3;
      };
      const g1 = await box(); chk(fits(g1, name === 'phone'), `[${name}] layout ${kind}, pre-fight: the popover sits on the content column, no sideways scroll (${g1 ? `dialog ${Math.round(g1.d.l)}+${Math.round(g1.d.w)}, column ${Math.round(g1.col.l)}+${Math.round(g1.col.w)}, page ${g1.sw}/${g1.iw}, ${g1.grid}` : 'no dialog'})`);
      await p.locator('#pfv-pre .pfv-gof button').first().click({ force: true }).catch(() => {}); await p.waitForTimeout(4500);
      const g2 = await box(); chk(fits(g2, name === 'phone'), `[${name}] layout ${kind}, combat: the popover sits on the content column, no sideways scroll (${g2 ? `dialog ${Math.round(g2.d.l)}+${Math.round(g2.d.w)}, column ${Math.round(g2.col.l)}+${Math.round(g2.col.w)}, page ${g2.sw}/${g2.iw}` : 'no dialog'})`);
    }
    chk(errs.length === 0, `[${name}] layout: no JS errors${errs.length ? ': ' + errs.slice(0, 2).join(' | ') : ''}`);
    await c.close();
  }
  await b.close(); process.exit(fail);
})();
