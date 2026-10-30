// node catfish_pets.js BASE : the room things (pet shops) in a real browser, called by tests/catfish.sh (skipped without playwright) with the full art and the pet PNGs installed and a seeded home:
// player sprout, all 8 spots filled (an Amphora on the shelf and a Steel-pan Chime on the ceiling are rested and ready, the rest are passive). Prints "ok   ..." / "FAIL ..." lines.
// SHOTS=/some/dir also writes screenshots (390 x 844, dark): the stage with the things, the Room things panel.
const { chromium } = require('playwright');
const B = process.argv[2];
const out = []; const ok = (name, got, want) => out.push((got === want ? 'ok   ' : 'FAIL ') + name + (got === want ? '' : " (got '" + got + "', want '" + want + "')"));
(async () => {
  const br = await chromium.launch({ args: ['--no-sandbox'] }).catch(() => chromium.launch());
  const c = await br.newContext({ viewport: { width: 390, height: 844 }, colorScheme: 'dark' }); const p = await c.newPage(); const errs = [];
  p.on('pageerror', e => errs.push(String(e)));
  if (process.env.PETDEBUG) p.on('response', r => { if (r.url().includes('catfish_api')) console.log('RESP', r.status(), (r.request().postData() || '').replace(/[\r\n-]+/g, ' ').replace(/Content Disposition: form data; name=/g, '').slice(0, 160)); });
  await p.goto(B + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]); await p.goto(B + '/catfish.php');
  await p.waitForTimeout(1500);
  ok('pets browser: the stage shows all eight room things (6 passive spans, 2 buttons)', await p.evaluate(() => document.querySelectorAll('.cfstage .cfpet').length + ':' + document.querySelectorAll('.cfstage button.cfpet').length), '8:2');
  ok('pets browser: every thing is its sprite at its slot size inside the 320 x 200 stage (PNG installed), none overlaps the stage edge', await p.evaluate(() => {
    var st = document.querySelector('.cfstage').getBoundingClientRect(), bad = [];
    document.querySelectorAll('.cfstage .cfpet').forEach(function (e) {
      var r = e.getBoundingClientRect(), im = e.querySelector('img');
      if (!im || !im.complete || im.naturalWidth < 1) bad.push(e.className + ' no image');
      else if (Math.round(r.width) !== im.naturalWidth || Math.round(r.height) !== im.naturalHeight) bad.push(e.className + ' size ' + Math.round(r.width) + 'x' + Math.round(r.height) + ' vs ' + im.naturalWidth + 'x' + im.naturalHeight);
      if (r.left < st.left - 0.5 || r.top < st.top - 0.5 || r.right > st.right + 0.5 || r.bottom > st.bottom + 0.5) bad.push(e.className + ' outside');
    });
    return bad.join('; ') || 'fine';
  }), 'fine');
  ok('pets browser: the cats and the fish are drawn over the room things (the pet layer comes first in the DOM)', await p.evaluate(() => { var all = [].slice.call(document.querySelectorAll('.cfstage > *')); var ix = function (sel) { return all.indexOf(document.querySelector(sel)); }; var sp = document.querySelector('.cfspot'); return (!sp || ix('.cfpet-s6') < ix('.cfspot')) && ix('.cfpet-s6') < ix('.cfactive') && ix('.cfpet-s5') < ix('.cfsdrop') && ix('.cfpet-s8') > ix('.cfsline'); }), true);
  ok('pets browser: a ready thing has the pip (is-ready) and a 44 px tap target', await p.evaluate(() => { var b = document.querySelector('button.cfpet.is-ready'); if (!b) return 'none'; var r = b.getBoundingClientRect(), a = getComputedStyle(b, '::after'); return b.getAttribute('data-slot') + ':' + (parseFloat(a.width) >= 44 && parseFloat(a.height) >= 44 ? 'big' : a.width + 'x' + a.height); }), '1:big');
  if (process.env.SHOTS) { await (await p.$('.cfstagewrap')).screenshot({ path: process.env.SHOTS + '/stage-390-dark.png' }); }
  const k0 = await p.evaluate(() => +document.getElementById('cf-kibble').textContent.replace(/\D/g, ''));
  const [resp] = await Promise.all([p.waitForResponse(r => r.url().includes('catfish_api.php') && /petuse/.test(r.request().postData() || '')), p.click('button.cfpet[data-slot="5"]', { force: true })]);
  const j = await resp.json();
  ok('pets browser: tapping the ready Steel-pan Chime posts do=petuse, the server pays a pop and answers with the new stage', j.ok + ':' + (j.message || '').slice(0, 14) + ':' + /cfpet-s5 cfpi-steel_pan_chime is-wait/.test(j.stage_html || ''), 'true:Ting-a-ling! T:true');
  await p.waitForTimeout(400);
  const k1 = await p.evaluate(() => +document.getElementById('cf-kibble').textContent.replace(/\D/g, ''));
  ok('pets browser: the Kibble counter went up by the pop (more than 10 minutes of the rate / 6 is far over the few seconds of income)', k1 > k0 + 20, true);
  ok('pets browser: the stage was swapped in place (one stage, the chime is waiting now), the message is shown, still 8 things', await p.evaluate(() => document.querySelectorAll('.cfstage').length + ':' + document.querySelectorAll('button.cfpet.is-wait[data-slot="5"]').length + ':' + document.querySelectorAll('.cfstage .cfpet').length + ':' + (document.getElementById('cf-msg').textContent.indexOf('Kibble') >= 0)), '1:1:8:true');
  const [resp2] = await Promise.all([p.waitForResponse(r => r.url().includes('catfish_api.php') && /petuse/.test(r.request().postData() || '')), p.click('button.cfpet[data-slot="5"]', { force: true })]);
  const j2 = await resp2.json();
  ok('pets browser: tapping it again is refused with the time left, and nothing breaks', j2.ok + ':' + /ready again in/.test(j2.message || ''), 'false:true');
  await p.waitForTimeout(300);
  ok('pets browser: the refusal is shown as an error message', await p.evaluate(() => document.getElementById('cf-msg').className), 'flash err');
  if (process.env.SHOTS) { await p.evaluate(() => window.scrollTo(0, 0)); await p.screenshot({ path: process.env.SHOTS + '/page-390-dark.png', fullPage: false }); }
  // the hub: seven tiles, the Room things tile opens the panel
  ok('pets browser: the hub has seven tiles and the Room things tile', await p.evaluate(() => document.querySelectorAll('.cfhub button').length + ':' + [].some.call(document.querySelectorAll('.cfhub button'), b => /Room things/.test(b.textContent))), '7:true');
  await p.evaluate(() => { [].find.call(document.querySelectorAll('.cfhub button'), b => /Room things/.test(b.textContent)).click(); });
  ok('pets browser: the Room things panel is the only open panel, with a form per open spot', await p.evaluate(() => [].filter.call(document.querySelectorAll('.cfpanel'), e => !e.hidden).map(e => e.id).join() + ':' + document.querySelectorAll('#cf-p-pets form.cfpetform select[name=item]').length), 'cf-p-pets:8');
  ok('pets browser: no page overflow sideways at 390 px', await p.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth), true);
  if (process.env.SHOTS) { await (await p.$('.cfhub')).scrollIntoViewIfNeeded(); await p.screenshot({ path: process.env.SHOTS + '/hub-390-dark.png', fullPage: false }); await (await p.$('#cf-p-pets')).screenshot({ path: process.env.SHOTS + '/panel-390-dark.png' }); }
  // the pet shop pages (PETSHOPS=id,id,...): the real banner (480 x 120) and keeper bust (80 x 100) are loaded images, not placeholders; no sideways overflow
  for (const id of (process.env.PETSHOPS || '').split(',').filter(Boolean)) {
    await p.goto(B + '/shop.php?id=' + id); await p.waitForTimeout(600);
    ok('pets browser: shop ' + id + ' shows its banner PNG 480x120, the keeper bust PNG 80x100 and 5 things with sprites', await p.evaluate(() => {
      var b = document.querySelector('.cfpbanner img'), k = document.querySelector('.cfpportrait img'), t = document.querySelectorAll('.cfpetimg');
      return [b && b.complete && b.naturalWidth + 'x' + b.naturalHeight, k && k.complete && k.naturalWidth + 'x' + k.naturalHeight, t.length, [].every.call(t, function (i) { return i.complete && i.naturalWidth > 0; }), document.documentElement.scrollWidth <= window.innerWidth].join(' ');
    }), '480x120 80x100 5 true true');
    if (process.env.SHOTS) await p.screenshot({ path: process.env.SHOTS + '/shop-' + id + '-390-dark.png', fullPage: true });
  }
  // reduced motion: the pip stops, nothing moves
  const c2 = await br.newContext({ viewport: { width: 390, height: 844 }, reducedMotion: 'reduce' }); const p2 = await c2.newPage();
  p2.on('pageerror', e => errs.push(String(e)));
  await p2.goto(B + '/login.php'); await p2.fill('input[name=username]', 'sprout'); await p2.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p2.waitForNavigation(), p2.press('input[name=password]', 'Enter')]); await p2.goto(B + '/catfish.php'); await p2.waitForTimeout(800);
  ok('pets browser: reduced motion: the ready pip does not animate', await p2.evaluate(() => { var b = document.querySelector('button.cfpet.is-ready') || document.querySelector('button.cfpet'); return getComputedStyle(b, '::before').animationName; }), 'none');
  ok('pets browser: no page errors', errs.join('|'), '');
  await br.close();
  console.log(out.join('\n'));
})().catch(e => { console.log('FAIL pets browser: crashed: ' + e); process.exit(0); });
