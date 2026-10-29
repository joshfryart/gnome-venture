// ({NOW} in a state SQL = 10 minutes ahead, so the next page load pays no Kibble into the run.)
// node catfish_anim.js BASE : the Cat Fish stage animation machine in a real browser (called by tests/catfish.sh with the full art installed and a seeded home).
// Prints "ok   ..." / "FAIL ..." lines. Player sprout (cats: active patterned folded-ear bobtail cat, a lazy cat, an awake side cat, a bored cat; glitter fish owned).
const { chromium } = require('playwright');
const B = process.argv[2];
const { execFileSync } = require('child_process');
const sql = q => execFileSync('php', ['-r', '$p = new PDO("sqlite:" . getenv("DBFILE")); $p->exec(getenv("SQLQ"));'], { env: Object.assign({}, process.env, { SQLQ: q.replace(/{NOW}/g, String(Math.floor(Date.now() / 1000) + 600)) }) });
const out = []; const ok = (name, got, want) => out.push((got === want ? 'ok   ' : 'FAIL ') + name + (got === want ? '' : " (got '" + got + "', want '" + want + "')"));
async function login(p) {
  await p.goto(B + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]); await p.goto(B + '/catfish.php');
}
// record every data-frame change of a selector from now on in window.__seq (name only)
const watch = (p, sel, key) => p.evaluate(([sel, key]) => { window[key] = []; var c = document.querySelector(sel); new MutationObserver(() => window[key].push(c.getAttribute('data-frame'))).observe(c, { attributes: true, attributeFilter: ['data-frame'] }); }, [sel, key]);
(async () => {
  const br = await chromium.launch({ args: ['--no-sandbox'] }).catch(() => chromium.launch());
  let c = await br.newContext({ viewport: { width: 412, height: 900 } }); let p = await c.newPage(); const errs = [];
  p.on('pageerror', e => errs.push(String(e)));
  await login(p);
  ok('anim: stage has the 8 inline frame groups, the manifest block, one z and one sparkle element', await p.evaluate(() => [document.querySelectorAll('.cfactive .cfframe').length, !!document.getElementById('cf-frames'), document.querySelectorAll('.cfz-a').length, document.querySelectorAll('.cfspark').length].join()), '8,true,1,1');
  await p.waitForTimeout(3000);
  ok('anim: after 2 s the 7 lazy frames are built from the manifest (15 groups), all their pictures loaded', await p.evaluate(() => document.querySelectorAll('.cfactive .cfframe').length + ':' + [].every.call(document.querySelectorAll('.cfactive .cfframe img'), i => i.complete && i.naturalWidth > 0)), '15:true');
  ok('anim: data-anim-state is rest at start', await p.getAttribute('.cfactive', 'data-anim-state'), 'rest');
  await p.waitForTimeout(500);
  await watch(p, '.cfactive', '__seq');
  // tap: swatA, swatB, catch, happy, idleA
  await p.click('.cfsdrop.sd1', { force: true });
  await p.waitForTimeout(250);
  ok('anim: fish bounce (is-hit) has started by swatB', await p.$eval('.cfsdrop.sd1', b => b.classList.contains('is-hit')), true);
  ok('anim: data-anim-state is play during the loop', await p.getAttribute('.cfactive', 'data-anim-state'), 'play');
  await p.waitForTimeout(1800);
  const seq = await p.evaluate(() => window.__seq.slice(0, 5).join(' '));
  ok('anim: tap play sequence is swatA swatB catch happy idleA', seq, 'swatA swatB catch happy idleA');
  ok('anim: a swatA layer stack has body, pattern, ears and tail (patterned folded-ear bobtail cat)', await p.evaluate(() => [].map.call(document.querySelectorAll('.ff-swatA img'), i => i.src.replace(/\?.*/, '').replace(/.*\//, '').replace('-white', '')).join(' ')), 'cf-cat-swatA.png cf-ears-folded-swatA.png cf-tail-bobtail-swatA.png cf-pat-calico-swatA.png cf-eyes-amber-swatA.png');
  // blink occurs on idleA, then idleA again; tailflick/eartwitch within about 20 s of idle
  const seen = {}; const t0 = Date.now();
  while (Date.now() - t0 < 25000 && !(seen.blink && seen.tailflick && seen.eartwitch)) {
    (await p.evaluate(() => window.__seq.slice())).forEach(f => seen[f] = true); await p.waitForTimeout(500);
  }
  (await p.evaluate(() => window.__seq.slice())).forEach(f => seen[f] = true);
  ok('anim: idle shows blink', !!seen.blink, true);
  ok('anim: idle shows tailflick and eartwitch (5-12 s)', !!(seen.tailflick && seen.eartwitch), true);
  const all = await p.evaluate(() => window.__seq.slice());
  let bad = 0; all.forEach((f, i) => { if (['blink', 'tailflick', 'eartwitch'].includes(f) && i > 0 && all[i - 1] !== 'idleA') bad++; });
  ok('anim: blink, tailflick and eartwitch only ever start from idleA (never during a play loop)', bad, 0);
  // side cats alternate
  const sideSeq = await p.evaluate(() => new Promise(res => { var s = document.querySelector('.cfside'), a = []; new MutationObserver(() => a.push(s.getAttribute('data-frame'))).observe(s, { attributes: true, attributeFilter: ['data-frame'] }); setTimeout(() => res(a), 17000); }));
  ok('anim: the awake side cat alternates idleA and idleB (4-8 s) and only shows its own three frames', sideSeq.length >= 2 && sideSeq.every(f => ['idleA', 'idleB', 'stalk'].includes(f)) && sideSeq.includes('idleB'), true);
  // jump: the top fish tapped twice within 1.5 s
  await p.waitForTimeout(3000);
  const topSlot = await p.evaluate(() => { var best = null, y = 1e9; document.querySelectorAll('button.cfsdrop').forEach(x => { var t = x.querySelector('img').offsetTop; if (t < y) { y = t; best = x; } }); return best.getAttribute('data-fish'); });
  await p.evaluate(() => { window.__seq = []; });
  await p.click('.cfsdrop.sd' + topSlot, { force: true }); await p.waitForTimeout(800); await p.click('.cfsdrop.sd' + topSlot, { force: true });
  await p.waitForTimeout(150);
  ok('anim: the jump has the is-jump arc class', await p.$eval('.cfactive', e => e.classList.contains('is-jump')), true);
  await p.waitForTimeout(2500);
  const jseq = await p.evaluate(() => window.__seq.join(' '));
  ok('anim: top fish tapped twice in 1.5 s: the cat jumps, then the catch, happy, idleA', jseq.indexOf('jump catch happy idleA') > 0 ? 'jump' : jseq, 'jump');
  // sparkles on the glitter fish (kind 4)
  await p.waitForTimeout(2500);
  const g = await p.$eval('.cfsdrop.cfk-4', b => b.getAttribute('data-fish'));
  await p.click('.cfsdrop.sd' + g, { force: true }); await p.waitForTimeout(60);
  ok('anim: a glitter fish tap shows the sparkles over that fish', await p.$eval('.cfspark', e => e.className), 'cfspark at' + g + ' go');
  await p.waitForTimeout(400);
  ok('anim: the sparkles are gone after 200 ms', await p.$eval('.cfspark', e => e.classList.contains('go')), false);
  ok('anim: no page errors', errs.join('|'), '');
  await c.close();
  // nap: z floats over the active cat; a napping cat on the cushion has its own z
  sql(process.env.SQL_NAP);
  c = await br.newContext({ viewport: { width: 412, height: 900 } }); p = await c.newPage(); await login(p);
  const napState = await p.evaluate(() => { var z = document.querySelector('.cfz-a'), s = document.querySelector('.cfspot .cfz-s'); return [document.querySelector('.cfactive').getAttribute('data-frame'), z.classList.contains('is-on'), getComputedStyle(z).display, getComputedStyle(z).animationName, !!s, s ? getComputedStyle(s).display : ''].join(); });
  ok('anim: a napping active cat shows its z (display block, cfzfloat), and the side cat on the cushion has a z too', napState, 'nap,true,block,cfzfloat,true,block');
  await c.close();
  sql(process.env.SQL_AWAKE);
  // reduced motion: static idleA, no extras
  c = await br.newContext({ viewport: { width: 412, height: 900 }, reducedMotion: 'reduce' }); p = await c.newPage(); await login(p);
  await p.waitForTimeout(2500); await watch(p, '.cfactive', '__seq');
  await p.click('.cfsdrop.sd1', { force: true }); await p.waitForTimeout(8000);
  const rs = await p.evaluate(() => [window.__seq.length, document.querySelector('.cfactive').getAttribute('data-frame'), document.querySelectorAll('.cfactive .cfframe').length, getComputedStyle(document.querySelector('.cfspark')).display, document.querySelector('.cfside').getAttribute('data-frame')].join());
  ok('anim: reduced motion: no frame ever changes (static idleA, 8 groups, no preload, no sparkles, side cat still)', rs, '0,idleA,8,none,idleA');
  await p.click('.cfsdrop.sd2', { force: true }); await p.waitForTimeout(100);
  ok('anim: reduced motion: the tapped fish still shows its outline state (is-hit) and the cat stays idleA', await p.evaluate(() => document.querySelector('.cfsdrop.sd2').classList.contains('is-hit') + ',' + document.querySelector('.cfactive').getAttribute('data-frame')), 'true,idleA');
  await br.close();
  console.log(out.join('\n'));
})().catch(e => { console.log('FAIL anim script: ' + e.message); process.exit(0); });
