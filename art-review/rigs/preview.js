// node preview.js BASE OUT.png slug...   (run by preview.sh, which installs a scratch game and exports GV_GAME / GV_ADVFORCE)
// For each slug: start a fight against it (tests/advforce.php), open adventure.php in Chromium so includes/fight_scene.php + assets/fightscene.js
// mount the stage exactly as players see it, once with the shipped sheet and once with art-review/rigs/out/rig-<slug>.png swapped in by
// route interception. Shots: rest pose (idle animations held at 0) and mid-attack (the foe's attack move, paused part way), each on light
// #f1ece0 and dark #2a1a10 (everything but the two actors hidden). Also records page errors and the sheet size the engine loaded.
const { chromium } = require('playwright');
const { execFileSync } = require('child_process');
const fs = require('fs'), path = require('path');
const [base, out, ...slugs] = process.argv.slice(2);
const SHOTS = path.join(__dirname, 'out', '_preview'); fs.mkdirSync(SHOTS, { recursive: true });
const GAME = process.env.GV_GAME, FORCE = process.env.GV_ADVFORCE;
const hasCreature = s => execFileSync('php', ['-r', '$p=new PDO("sqlite:' + GAME + '/data/game.sqlite"); $q=$p->prepare("SELECT COUNT(*) FROM creatures WHERE slug=?"); $q->execute([$argv[1]]); echo $q->fetchColumn();', s]).toString().trim() === '1';
const BG = { light: '#f1ece0', dark: '#2a1a10' };
const report = [];

(async () => {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  for (const slug of slugs) {
    const real = hasCreature(slug), stand = real ? slug : 'bullfrog';
    execFileSync('php', [FORCE, GAME, 'fight', stand]);
    let dsf = 1;
    for (const kind of ['old', 'new']) for (const pass of [0, 1]) {
      if (pass === 0 && kind === 'new') continue;   // pass 0 only measures the art-pixel size (to pick a device scale of 4 px per art pixel)
      const ctx = await b.newContext({ viewport: { width: 412, height: 900 }, deviceScaleFactor: dsf, reducedMotion: 'no-preference', bypassCSP: true });
      const p = await ctx.newPage();
      const errs = []; p.on('pageerror', e => errs.push(String(e))); p.on('console', m => { if (m.type() === 'error' || m.type() === 'warning') errs.push(m.text()); });
      let served = null;
      await p.route(/\/assets\/img\/fight\/rig-[\w-]+\.png/, async (r) => {
        const u = r.request().url();
        if (kind === 'new' && u.includes('/rig-' + slug + '.png')) { served = 'staged'; return r.fulfill({ path: path.join(__dirname, 'out', 'rig-' + slug + '.png'), contentType: 'image/png' }); }
        if (u.includes('/rig-' + slug + '.png')) served = 'shipped';
        return r.continue();
      });
      if (!real) await p.route(/adventure\.php/, async (r) => {   // the Trek crew has no creature row: a stand-in fight whose slug and name are rewritten
        const res = await r.fetch(); let html = await res.text();
        html = html.split('&quot;slug&quot;:&quot;' + stand + '&quot;').join('&quot;slug&quot;:&quot;' + slug + '&quot;');
        return r.fulfill({ response: res, body: html });
      });
      await p.goto(base + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
      await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
      await p.goto(base + '/adventure.php', { waitUntil: 'networkidle' });
      await p.waitForSelector('#fightscene .fe-view', { timeout: 20000 });
      await p.waitForFunction(() => window.feScene && !document.querySelector('.fightbtns.fs-wait, .fsdock.fs-wait'), null, { timeout: 15000 }).catch(() => {});
      await p.waitForTimeout(400);
      const info = await p.evaluate((slug) => {
        const f = window.feScene.acts.foe, r = f.rig;
        return { kind: r.kind, cols: r.cols ? r.cols.length : 0, fw: r.fw, fh: r.fh, slug: (JSON.parse(document.getElementById('fightscene').dataset.fight) || {}).slug, w: f.spr.getBoundingClientRect().width };
      }, slug);
      if (pass === 0) { dsf = Math.max(1, Math.min(8, 4 / (info.w / info.fw))); await ctx.close(); continue; }
      const natural = await p.evaluate(() => new Promise(res => {
        const el = [...window.feScene.acts.foe.spr.querySelectorAll('.fe-part')].find(e => e.style.backgroundImage);
        const i = new Image(); i.onload = () => res([i.naturalWidth, i.naturalHeight]); i.onerror = () => res([0, 0]); i.src = el.style.backgroundImage.replace(/^url\("?|"?\)$/g, '');
      }));
      await p.addStyleTag({ content: 'html,body{background:var(--pv-bg)!important} body *{visibility:hidden!important} .fe-act,.fe-act *{visibility:visible!important} .fe-hb,.fe-sh,.fe-dmg{display:none!important}' });
      const clip = async () => p.evaluate(() => {
        const rs = Object.values(window.feScene.acts).map(a => a.spr.getBoundingClientRect());
        const x0 = Math.min(...rs.map(r => r.left)) - 6, y0 = Math.min(...rs.map(r => r.top)) - 6, x1 = Math.max(...rs.map(r => r.right)) + 6, y1 = Math.max(...rs.map(r => r.bottom)) + 6;
        return { x: Math.max(0, x0), y: Math.max(0, y0), width: x1 - Math.max(0, x0), height: y1 - Math.max(0, y0) };
      });
      const clipFoe = async () => p.evaluate(() => { const r = window.feScene.acts.foe.spr.getBoundingClientRect(); return { x: Math.max(0, r.left - 4), y: Math.max(0, r.top - 4), width: r.width + 8, height: r.height + 8 }; });
      const hold = () => p.evaluate(() => document.getAnimations().forEach(a => { try { a.pause(); if (a.effect && a.effect.getTiming().iterations === Infinity) a.currentTime = 0; } catch (e) { } }));
      await hold(); await p.waitForTimeout(250);   // springs settle
      const c0 = await clip(), f0 = await clipFoe();
      for (const th of ['light', 'dark']) { await p.evaluate(c => document.documentElement.style.setProperty('--pv-bg', c), BG[th]); await p.screenshot({ path: path.join(SHOTS, `${slug}-${kind}-${th}-rest.png`), clip: c0 }); await p.screenshot({ path: path.join(SHOTS, `${slug}-${kind}-${th}-rest-foe.png`), clip: f0 }); }
      await p.evaluate(() => { document.getAnimations().forEach(a => a.play()); const e = window.feScene; e.setSpeed(.25); e.play([{ from: 'foe', to: 'me', dmg: 1 }]); });
      await p.waitForTimeout(1250);
      await p.evaluate(() => document.getAnimations().forEach(a => a.pause()));
      const c1 = await clip(), f1 = await clipFoe();
      for (const th of ['light', 'dark']) { await p.evaluate(c => document.documentElement.style.setProperty('--pv-bg', c), BG[th]); await p.screenshot({ path: path.join(SHOTS, `${slug}-${kind}-${th}-act.png`), clip: c1 }); await p.screenshot({ path: path.join(SHOTS, `${slug}-${kind}-${th}-act-foe.png`), clip: f1 }); }
      report.push({ slug, kind, served, real, natural, cols: info.cols, fw: info.fw, fh: info.fh, mountedSlug: info.slug, errors: errs.filter(e => !/favicon/.test(e)) });
      await ctx.close();
    }
  }
  await b.close();
  fs.writeFileSync(path.join(SHOTS, 'report.json'), JSON.stringify(report, null, 1));
  let bad = 0;
  for (const r of report) {
    const okSize = r.natural[0] === r.cols * r.fw && r.natural[1] === r.fh * 2;
    const okServe = r.kind === 'new' ? r.served === 'staged' : r.served === 'shipped';
    if (!okSize || !okServe || r.errors.length || r.mountedSlug !== r.slug) bad++;
    console.log(`${r.slug.padEnd(18)} ${r.kind}  sheet ${r.natural.join('x')} (${okSize ? 'ok' : 'WRONG'})  served ${r.served}${r.real ? '' : ' (crew: stand-in fight, slug rewritten)'}  errors ${r.errors.length ? r.errors.join(' | ') : 'none'}`);
  }
  execFileSync('python3', [path.join(__dirname, 'compose_preview.py'), out, ...slugs], { stdio: 'inherit' });
  execFileSync('python3', [path.join(__dirname, 'compose_preview.py'), out.replace(/\.png$/, '_stage.png'), '--stage', ...slugs], { stdio: 'inherit' });
  process.exit(bad ? 1 : 0);
})();
