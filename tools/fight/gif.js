// Record a fight to a tight, crisp GIF.  node tools/fight/gif.js out.gif ['<events json>'] [slug] [width=560] [lead=1.9]
// Renders the stage natively wide (no upscaling = no blur), records video, crops to the stage, palettes it with ffmpeg. Needs playwright, ffmpeg.
const { chromium } = require('playwright'), path = require('path'), fs = require('fs'), os = require('os'), cp = require('child_process');
const DEF = [{ from: 'me', to: 'foe', move: 'pluck', dmg: 4 }, { from: 'foe', to: 'me', dmg: 6, crit: true }, { from: 'me', to: 'foe', move: 'pluck', dmg: 8 }, { from: 'foe', to: 'me', miss: true }, { from: 'me', to: 'foe', move: 'pluck', dmg: 99 }];
(async () => {
  const [out, ev, slug, W = '560', lead = '1.9'] = process.argv.slice(2), events = ev ? JSON.parse(ev) : DEF, w = +W;
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'fegif-')), H = Math.round(w * .75);
  const b = await chromium.launch(), ctx = await b.newContext({ viewport: { width: w, height: H }, recordVideo: { dir, size: { width: w, height: H } } }), p = await ctx.newPage();
  p.on('pageerror', e => console.log('E:', e.message));
  await p.addInitScript(() => { Math.random = () => 0.9; });
  await p.goto('file://' + path.resolve(__dirname, '../../game/fight_demo.html'));
  await p.addStyleTag({ content: 'body{padding:0!important}main{max-width:none!important}h1,select,label,.btns,p{display:none!important}' });
  if (slug) await p.selectOption('#cr', slug);
  await p.waitForTimeout(+lead * 1000);
  const box = await p.locator('.fe-stage').boundingBox(), t0 = Date.now();
  await p.evaluate(l => { window.__p = feDemo().play(l); }, events);
  await p.evaluate(() => window.__p); await p.waitForTimeout(600);
  const secs = (Date.now() - t0) / 1000 + .4; await ctx.close(); await b.close();
  const vid = path.join(dir, fs.readdirSync(dir)[0]), crop = `crop=${Math.floor(box.width)}:${Math.floor(box.height)}:${Math.floor(box.x)}:${Math.floor(box.y)}`;
  cp.execFileSync('ffmpeg', ['-v', 'error', '-y', '-ss', String(+lead), '-t', String(secs), '-i', vid, '-vf', `${crop},fps=18,split[a][b];[a]palettegen=max_colors=96:stats_mode=diff[p];[b][p]paletteuse=dither=none:diff_mode=rectangle`, out]);
  console.log(out, Math.round(fs.statSync(out).size / 1024) + ' KB', Math.floor(box.width) + 'x' + Math.floor(box.height));
})();
