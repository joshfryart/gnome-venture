// One contact sheet of every creature's animations: a row per creature = attack | hit | dodge | KO, frames cut around the creature, slow motion x0.3.
//   node tools/fight/creatures.js out.png [slug ...]      (needs playwright + python3 PIL)
const { chromium } = require('playwright'), path = require('path'), fs = require('fs'), os = require('os'), cp = require('child_process');
const ALL = ['wild-boar', 'bramble-wolf', 'black-bear', 'cliff-ram', 'dune-scorpion', 'bullfrog'];
// [label, events, frames, ms between frames]
const SC = [['attack', [{ from: 'foe', to: 'me', dmg: 3 }], 9, 330], ['hit', [{ from: 'foe', move: 'hit' }], 4, 260], ['dodge', [{ from: 'foe', move: 'dodge' }], 4, 380], ['ko', [{ from: 'foe', move: 'ko' }], 5, 550]];
(async () => {
  const out = process.argv[2], slugs = process.argv.length > 3 ? process.argv.slice(3) : ALL, dir = fs.mkdtempSync(path.join(os.tmpdir(), 'fecrit-')), cells = [];
  const b = await chromium.launch(), p = await b.newPage({ viewport: { width: 412, height: 520 }, deviceScaleFactor: 2 });
  p.on('pageerror', e => console.log('E:', e.message));
  await p.addInitScript(() => { Math.random = () => 0.9; });
  await p.goto('file://' + path.resolve(__dirname, '../../game/fight_demo.html'));
  for (const slug of slugs) {
    const row = [];
    for (const [label, ev, n, iv] of SC) {
      await p.selectOption('#cr', slug); await p.check('#slow'); await p.waitForTimeout(3300);   // mount + slow-motion enter
      await p.evaluate(e => { window.__p = feDemo().play(e); }, ev);
      for (let i = 0; i < n; i++) {
        const bb = await p.locator('.fe-body').nth(1).boundingBox(), f = path.join(dir, `${slug}-${label}-${i}.png`), cx = bb.x + bb.width / 2, cy = bb.y + bb.height / 2;
        await p.screenshot({ path: f, clip: { x: Math.max(0, Math.min(412 - 100, cx - 50)), y: Math.max(0, cy - 56), width: 100, height: 100 } }); row.push([label, f]);
        await p.waitForTimeout(iv);
      }
    }
    cells.push(row);
  }
  await b.close();
  fs.writeFileSync(path.join(dir, 'cells.json'), JSON.stringify({ cells, labels: slugs }));
  cp.execFileSync('python3', ['-c', `
import json,sys
from PIL import Image, ImageDraw
d=json.load(open(sys.argv[1]+'/cells.json'));C=200;W=13
s=Image.new('RGB',(W*C,len(d['cells'])*2*C),(40,30,24));dr=ImageDraw.Draw(s)
for y,r in enumerate(d['cells']):
    line={'attack':0,'hit':1,'dodge':1,'ko':1};col=[0,0]
    for lab,f in r:
        l=line[lab];s.paste(Image.open(f).convert('RGB'),(col[l]*C,(y*2+l)*C));col[l]+=1
    dr.text((6,y*2*C+6),d['labels'][y]+'  attack',fill=(255,230,120));dr.text((6,(y*2+1)*C+6),'hit | dodge | KO',fill=(255,230,120))
s.save(sys.argv[2])`, dir, out]);
  console.log(out);
})();
