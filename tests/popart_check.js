// v2.0.82: popover art motion in a real browser (called by tests/popart.sh). node popart_check.js BASE GAME_DIR SHOT_DIR [ICO_SLUG]
// Logs in as sprout (standing at a rest stop). Per theme: the hero picture in an OPEN activity popover has a computed animationName that is not
// "none"; the card pictures (.gcard__art) are always "none"; a CLOSED popover's picture is "none"; under prefers-reduced-motion nothing animates and
// nothing is swapped. Then Tier B: with a drawn strip on disk the open popover's picture plays it (data-animating, src = strip, a running
// animation, the Tier A bob off) and closing restores the static src.
const { chromium } = require('playwright');
const fs = require('fs');
(async () => {
  const [base, game, shots, ico] = process.argv.slice(2);
  const b = await chromium.launch({ executablePath: process.env.PW_CHROMIUM || undefined, args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  let fails = 0;
  const say = (ok, msg) => { if (!ok) fails++; console.log((ok ? 'ok   ' : 'FAIL ') + msg); };
  const login = async p => {
    await p.goto(base + '/login.php');
    await p.fill('input[name="username"]', 'sprout'); await p.fill('input[name="password"]', 'TestPass123!');
    await Promise.all([p.waitForNavigation({ waitUntil: 'load' }), p.press('input[name="password"]', 'Enter')]);
  };
  const an = (p, sel) => p.evaluate(s => { const e = document.querySelector(s); return e ? getComputedStyle(e).animationName : 'MISSING'; }, sel);
  for (const reduce of [false, true]) {
    const c = await b.newContext({ viewport: { width: 390, height: 844 }, reducedMotion: reduce ? 'reduce' : 'no-preference' });
    const p = await c.newPage(); const errs = []; p.on('pageerror', e => errs.push(String(e)));
    await login(p);
    await p.goto(base + '/town.php'); await p.goto(base + '/town.php');
    const tag = reduce ? 'reduced-motion' : 'motion';
    const card = p.locator('.gcell > button.docard[data-sheet]').first();
    say(await card.count() > 0, `${tag}: a tappable activity card exists`);
    if (!await card.count()) { await c.close(); continue; }
    say(await an(p, '.gcell .gcard__art img') === 'none', `${tag}: card picture does not animate`);
    say(await an(p, 'dialog.dosheet .doart img.doart-img') === 'none', `${tag}: closed popover picture does not animate`);
    await card.click();
    await p.waitForSelector('dialog.dosheet[open]');
    const hero = await an(p, 'dialog.dosheet[open] .doart img.doart-img');
    say(reduce ? hero === 'none' : (hero !== 'none' && hero !== 'MISSING'), `${tag}: open popover hero animationName = ${hero}`);
    const icoAn = await p.evaluate(() => [...document.querySelectorAll('dialog.dosheet[open] .choice-ico .ico, dialog.dosheet[open] .doacts .btn .ico')].map(e => getComputedStyle(e).animationName));
    if (icoAn.length) say(reduce ? icoAn.every(x => x === 'none') : icoAn.every(x => x !== 'none'), `${tag}: ${icoAn.length} option icons in the popover -> ${[...new Set(icoAn)].join(',')}`);
    else console.log(`note ${tag}: this popover has no emoji-swapped option icons`);
    say(await an(p, '.gcell .gcard__art img') === 'none', `${tag}: card picture still does not animate while the popover is open`);
    if (!reduce) {
      const stag = await p.evaluate(() => { const e = document.querySelector('.gcell .gcard__art img'); return getComputedStyle(e).animationName; });
      say(stag === 'none', 'motion: page cards stay still');
      if (shots) await p.screenshot({ path: `${shots}/popart-open-390.png` });
    }
    await p.keyboard.press('Escape');
    await p.waitForTimeout(100);
    say(await an(p, 'dialog.dosheet .doart img.doart-img') === 'none', `${tag}: closed again, popover picture does not animate`);
    say(!errs.length, `${tag}: no page errors${errs.length ? ' (' + errs.join(' | ') + ')' : ''}`);
    await c.close();
  }
  // Tier B: a strip on disk (3 frames of 144x108), then the open popover plays it, and closing restores the static art
  const strip = game + '/assets/img/acts/act-any-anim.png';
  if (fs.existsSync(game + '/assets/img/acts')) {
    const { execFileSync } = require('child_process');
    execFileSync('php', ['-r', '$im=imagecreatetruecolor(432,108); imagepng($im,$argv[1]);', strip]);
    const c = await b.newContext({ viewport: { width: 390, height: 844 } });
    const p = await c.newPage(); const errs = []; p.on('pageerror', e => errs.push(String(e)));
    await login(p); await p.goto(base + '/town.php'); await p.goto(base + '/town.php');
    const staticSrc = await p.evaluate(() => document.querySelector('dialog.dosheet .doart img.doart-img').getAttribute('src'));
    await p.locator('.gcell > button.docard[data-sheet]').first().click();
    await p.waitForSelector('dialog.dosheet[open] .doart img[data-animating]', { timeout: 4000 }).catch(() => {});
    const st = await p.evaluate(() => { const e = document.querySelector('dialog.dosheet[open] .doart img.doart-img'); return { on: e.hasAttribute('data-animating'), src: e.getAttribute('src'), anims: e.getAnimations().length, bob: getComputedStyle(e).animationName }; });
    say(st.on && /act-any-anim\.png/.test(st.src) && st.anims >= 1, `strip: open popover plays the drawn strip (src ${st.src}, ${st.anims} animation)`);
    say(st.bob === 'none', `strip: Tier A bob is off while the strip plays (${st.bob})`);
    say(await an(p, '.gcell .gcard__art img') === 'none' && await p.evaluate(() => !document.querySelector('.gcard__art img[data-animating]')), 'strip: the card picture is untouched');
    await p.keyboard.press('Escape'); await p.waitForTimeout(150);
    const after = await p.evaluate(() => { const e = document.querySelector('dialog.dosheet .doart img.doart-img'); return { on: e.hasAttribute('data-animating'), src: e.getAttribute('src') }; });
    say(!after.on && after.src === staticSrc, `strip: closing restores the static picture (${after.src})`);
    // a strip that fails to load: static art stays
    await p.goto(base + '/town.php');
    fs.writeFileSync(strip, 'not a png');   // the page already carries data-anim; the file now fails to load
    await p.locator('.gcell > button.docard[data-sheet]').first().click(); await p.waitForTimeout(500);
    const bad = await p.evaluate(() => { const e = document.querySelector('dialog.dosheet[open] .doart img.doart-img'); return { on: e.hasAttribute('data-animating'), src: e.getAttribute('src') }; });
    say(!bad.on && bad.src === staticSrc, 'strip: a broken strip leaves the static art in place');
    say(!errs.length, `strip: no page errors${errs.length ? ' (' + errs.join(' | ') + ')' : ''}`);
    fs.unlinkSync(strip);
    await c.close();
  }
  await b.close();
  console.log(fails ? `${fails} FAILED` : 'all popover-art checks ok');
})();
