// Contact sheet of one actor over time (the cheap way to review a move: look at ONE image, not a live run).
//   node tools/fight/sheet.js '<events json>' N intervalMs out.png [slug] [me|foe] [cols=6]
// Plays in slow motion (x0.3), crops around the actor each step, tiles the crops with python3+PIL.
const { chromium } = require('playwright'), path = require('path'), fs = require('fs'), os = require('os'), cp = require('child_process');
(async () => {
  const [ev, N, iv, out, slug, who, cols = '6'] = process.argv.slice(2), dir = fs.mkdtempSync(path.join(os.tmpdir(), 'fesheet-'));
  const b = await chromium.launch(), p = await b.newPage({ viewport: { width: 412, height: 520 }, deviceScaleFactor: 3 });
  p.on('pageerror', e => console.log('E:', e.message));
  await p.addInitScript(() => { Math.random = () => 0.9; });   // fixed random = repeatable frames
  await p.goto('file://' + path.resolve(__dirname, '../../game/fight_demo.html'));
  if (slug) await p.selectOption('#cr', slug);
  await p.check('#slow'); await p.waitForTimeout(2600);   // slow-mo remounts; wait out the enter move
  await p.evaluate(e => { window.__p = feDemo().play(JSON.parse(e)); }, ev);
  for (let i = 0; i < +N; i++) {
    await p.waitForTimeout(+iv);
    const bb = await p.locator('.fe-body').nth(who === 'foe' ? 1 : 0).boundingBox();
    await p.screenshot({ path: path.join(dir, i + '.png'), clip: { x: Math.max(0, bb.x - 30), y: Math.max(0, bb.y - 34), width: Math.min(bb.width + 80, 412), height: bb.height + 50 } });
  }
  await b.close();
  cp.execFileSync('python3', ['-c', `
import sys
from PIL import Image
d,n,cols,out=sys.argv[1],int(sys.argv[2]),int(sys.argv[3]),sys.argv[4]
ims=[Image.open(f"{d}/{i}.png") for i in range(n)]
W=max(i.size[0] for i in ims);H=max(i.size[1] for i in ims);rows=(n+cols-1)//cols
s=Image.new("RGB",(W*cols,H*rows),(60,45,35))
for i,im in enumerate(ims): s.paste(im,((i%cols)*W,(i//cols)*H))
s.thumbnail((2000,1400));s.save(out)`, dir, N, cols, out]);
  console.log(out);
})();
