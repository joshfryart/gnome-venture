// node trekshell_shot.js BASE IGNORED OUTDIR : screenshots of the trek page (map, then Party drawer), desktop and phone
const { chromium } = require('playwright');
(async () => {
  const [base, sid, out, mode] = process.argv.slice(2);
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  for (const [name, vp] of [['desktop', { width: 1280, height: 800 }], ['phone', { width: 390, height: 800 }]]) {
    const c = await b.newContext({ viewport: vp });
    await c.addInitScript(() => { try { localStorage.setItem('gvSceneOff', '1'); localStorage.setItem('gvCampAuto', '0'); } catch (e) {} });
    const p = await c.newPage();
    const errs = [];
    p.on('pageerror', e => errs.push(String(e)));
    await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!'); await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    await p.goto(base + '/trek.php', { waitUntil: 'networkidle' });
    await p.screenshot({ path: `${out}/${name}-${mode || 'map'}.png` });
    if (mode === 'fight') { console.log(await p.evaluate(() => { const h = document.querySelector('.gvs-hp i'); if (!h) return 'no hp'; const cs = getComputedStyle(h); return h.outerHTML + ' w=' + cs.width + ' bg=' + cs.backgroundColor + ' disp=' + cs.display + ' parentw=' + getComputedStyle(h.parentNode).width; })); console.log(name, 'fight js errors:', errs.length ? errs.join(' | ') : 'none'); await c.close(); continue; }
    await p.click('main nav.tabs a:has-text("Party")', { timeout: 5000 }).catch(e => { errs.push('click: ' + e.message.split('\n')[0]); });
    await p.waitForSelector('.tkdrawer:not([hidden]) .partybox', { timeout: 5000 }).catch(e => errs.push('drawer: ' + e.message));
    await p.screenshot({ path: `${out}/${name}-party.png` });
    console.log(name, 'js errors:', errs.length ? errs.join(' | ') : 'none');
    await c.close();
  }
  await b.close();
})();
