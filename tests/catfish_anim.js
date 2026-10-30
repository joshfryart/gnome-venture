// ({NOW} in a state SQL = 10 minutes ahead, so the next page load pays no Kibble into the run.)
// node catfish_anim.js BASE : the Cat Fish stage animation machine in a real browser (called by tests/catfish.sh with the full art installed and a seeded home).
// Prints "ok   ..." / "FAIL ..." lines. Player sprout (cats: active patterned folded-ear bobtail cat, a lazy cat, an awake side cat, a bored cat; glitter fish owned).
const { chromium } = require('playwright');
const B = process.argv[2];
const { execFileSync } = require('child_process');
const sql = q => execFileSync('php', ['-r', '$p = new PDO("sqlite:" . getenv("DBFILE")); $p->exec(getenv("SQLQ"));'], { env: Object.assign({}, process.env, { SQLQ: q.replace(/{NOW}/g, String(Math.floor(Date.now() / 1000) + 600)) }) });
const out = []; const ok = (name, got, want) => out.push((got === want ? 'ok   ' : 'FAIL ') + name + (got === want ? '' : " (got '" + got + "', want '" + want + "')"));
async function login(p, q) {
  await p.goto(B + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]); await p.goto(B + '/catfish.php' + (q || ''));
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
  ok('anim: after 2 s the 11 lazy frames are built from the manifest (19 groups), all their pictures loaded', await p.evaluate(() => document.querySelectorAll('.cfactive .cfframe').length + ':' + [].every.call(document.querySelectorAll('.cfactive .cfframe img'), i => i.complete && i.naturalWidth > 0)), '19:true');
  ok('anim: without room upgrades there is no bird and no dust, the yarn roll element is there', await p.evaluate(() => [document.querySelectorAll('.cfbird').length, document.querySelectorAll('.cfdust').length, document.querySelectorAll('.cfyarn').length, document.querySelector('.cfstage').classList.contains('is-bird')].join()), '0,0,1,false');
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
  await c.close();
  // 2.1.06: all four room upgrades owned. ?cffast=1 shortens the idle variety and bird waits tenfold (a test hook; production pages never carry it)
  sql(process.env.SQL_ROOM);
  c = await br.newContext({ viewport: { width: 412, height: 900 } }); p = await c.newPage(); const errs2 = []; p.on('pageerror', e => errs2.push(String(e)));
  await login(p, '?cffast=1');
  ok('ambience: window, sunbeam and rug owned: one bird, one dust layer of 6 motes, one yarn element, 6 motes animate (cfmote)', await p.evaluate(() => [document.querySelectorAll('.cfbird').length, document.querySelectorAll('.cfdust i').length, document.querySelectorAll('.cfyarn').length, [].filter.call(document.querySelectorAll('.cfdust i'), i => getComputedStyle(i).animationName === 'cfmote').length].join()), '1,6,1,6');
  ok('ambience: no inline style attribute and no inline script on the stage', await p.evaluate(() => document.querySelectorAll('.cfstage [style], .cfstage script:not([type="application/json"])').length), 0);
  // the perched sprite sits exactly where the robin was: crop the perch with the bird on, then with the window overlay's robin back
  await p.waitForTimeout(600);
  ok('ambience: with JS and motion the stage is in bird mode, the window overlay is hidden and the perched frame f1 shows', await p.evaluate(() => [document.querySelector('.cfstage').classList.contains('is-bird'), getComputedStyle(document.querySelector('.cfl-window')).display, document.querySelector('.cfbird').className].join()), 'true,none,cfbird f1');
  const box = await p.$eval('.cfstage', e => { const r = e.getBoundingClientRect(); return { x: r.left + scrollX, y: r.top + scrollY }; });
  const clip = { x: box.x, y: box.y + 40, width: 28, height: 28 };
  let shotA = null, shotB = null;
  for (let t = 0; t < 8 && !shotA; t++) { const cls = await p.$eval('.cfbird', e => e.className); if (cls === 'cfbird f1') { shotA = await p.screenshot({ clip }); if ((await p.$eval('.cfbird', e => e.className)) !== 'cfbird f1') shotA = null; } if (!shotA) await p.waitForTimeout(50); }
  await p.evaluate(() => document.querySelector('.cfstage').classList.remove('is-bird'));
  shotB = await p.screenshot({ clip });
  await p.evaluate(() => document.querySelector('.cfstage').classList.add('is-bird'));
  const cmp = await p.evaluate(async ([a, b]) => {
    const load = u => new Promise(r => { const i = new Image(); i.onload = () => r(i); i.src = 'data:image/png;base64,' + u; });
    const px = async u => { const i = await load(u), c = document.createElement('canvas'); c.width = i.width; c.height = i.height; const x = c.getContext('2d'); x.drawImage(i, 0, 0); return x.getImageData(0, 0, i.width, i.height).data; };
    const A = await px(a), B = await px(b); let diff = 0, light = 0;
    for (let i = 0; i < A.length; i += 4) if (A[i] !== B[i] || A[i + 1] !== B[i + 1] || A[i + 2] !== B[i + 2]) { diff++; if (A[i] + A[i + 1] + A[i + 2] > 150) light++; }
    return diff + ',' + light;
  }, [shotA ? shotA.toString('base64') : '', shotB.toString('base64')]);
  const cmpN = cmp.split(',').map(Number);
  ok('ambience: the perched bird sprite sits on the robin of cf-room-window.png: the toggle changes no robin pixel (the redrawn 2.2.x sprite has no outline ring; an old 1 px dark ring, under 140 px, would still pass)', !!shotA && cmpN[0] < 140 && cmpN[1] === 0, true);
  // idle variety and the bird, over time (fast hook: waits are one tenth). Recording starts at an idleA (now, or the next one), so a wash already
  // running when the watch begins never shows up as a partial washB washA washB at the front of the sequence.
  await p.evaluate(() => { window.__seq = []; var c = document.querySelector('.cfactive'), on = c.getAttribute('data-frame') === 'idleA';
    new MutationObserver(() => { var f = c.getAttribute('data-frame'); if (!on) { on = f === 'idleA'; if (!on) return; } window.__seq.push(f); }).observe(c, { attributes: true, attributeFilter: ['data-frame'] }); });
  await p.evaluate(() => { window.__bird = []; var b = document.querySelector('.cfbird'); new MutationObserver(() => window.__bird.push(b.className)).observe(b, { attributes: true, attributeFilter: ['class'] }); });
  const seen2 = {}; const t1 = Date.now();
  let fullWash = false;
  while (Date.now() - t1 < 80000 && !(seen2.yawn && seen2.stretch && fullWash)) {
    const sq = await p.evaluate(() => window.__seq.slice()); sq.forEach(f => seen2[f] = true); fullWash = /washA washB washA washB idleA/.test(sq.join(' ')); await p.waitForTimeout(500);
  }
  const seq2 = await p.evaluate(() => window.__seq.slice()); seq2.forEach(f => seen2[f] = true);
  ok('ambience: idle variety shows a yawn, a stretch and a wash within the window', !!(seen2.yawn && seen2.stretch && seen2.washA && seen2.washB), true);
  const J = seq2.join(' ');
  const J2 = J.replace(/ washA washB washA( washB)?$/, '').replace(/ washA( washB)?$/, '');
  ok('ambience: a wash is always washA washB washA washB then idleA', (J2.match(/washA/g) || []).length > 0 && (J2.match(/washA washB washA washB idleA/g) || []).length === (J2.match(/washA/g) || []).length / 2 ? 'wash' : J2, 'wash');
  let badv = 0; seq2.forEach((f, i) => { if (['yawn', 'stretch', 'washA'].includes(f) && i > 0 && seq2[i - 1] !== 'idleA' && !(f === 'washA' && seq2[i - 1] === 'washB')) badv++; if (['wiggle', 'stalk', 'pounce', 'catch', 'bored'].includes(f) && i > 0 && ['yawn', 'stretch', 'washA', 'washB'].includes(seq2[i - 1])) badv++; });
  ok('ambience: yawn, stretch and wash only start from idleA and a play loop never starts straight out of one', badv, 0);
  const bj = await p.evaluate(() => window.__bird.join('|'));
  ok('ambience: the bird perches, hops (f2) and spreads its wings (f3), then perches again', /cfbird f2\|cfbird f1/.test(bj) || /cfbird f3\|cfbird f1/.test(bj), true);
  // tap: yarn roll and rug wobble
  await p.waitForTimeout(1500);
  const waitCalm = async () => { for (let i = 0; i < 40; i++) { if (await p.getAttribute('.cfactive', 'data-anim-state') === 'rest') return; await p.waitForTimeout(250); } };
  await waitCalm();
  await p.click('.cfsdrop.sd3', { force: true }); await p.waitForTimeout(200);
  const rolling = await p.evaluate(() => [document.querySelector('.cfyarn').classList.contains('is-roll'), getComputedStyle(document.querySelector('.cfyarn .yp')).display, getComputedStyle(document.querySelector('.cfyarn .yb')).display, document.querySelector('.cfl-rug').classList.contains('is-wobble'), getComputedStyle(document.querySelector('.cfl-rug')).animationName].join());
  ok('ambience: a swat rolls the yarn (patch and rolling sprite shown) and wobbles the rug', rolling, 'true,block,block,true,cfrug');
  await p.waitForTimeout(500);
  ok('ambience: the rug wobble is over after 300 ms', await p.$eval('.cfl-rug', e => e.classList.contains('is-wobble')), false);
  await p.waitForTimeout(1200);
  ok('ambience: the yarn roll ends after about 1.2 s and the ball is the base ball again (patch hidden)', await p.evaluate(() => document.querySelector('.cfyarn').classList.contains('is-roll') + ',' + getComputedStyle(document.querySelector('.cfyarn .yp')).display), 'false,none');
  ok('ambience: no page errors', errs2.join('|'), '');
  await c.close();
  // reduced motion with all room upgrades: static, nothing extra
  c = await br.newContext({ viewport: { width: 412, height: 900 }, reducedMotion: 'reduce' }); p = await c.newPage(); await login(p, '?cffast=1');
  await p.waitForTimeout(2500); await watch(p, '.cfactive', '__seq');
  await p.click('.cfsdrop.sd1', { force: true }); await p.waitForTimeout(12000);
  const rr = await p.evaluate(() => [window.__seq.length, document.querySelector('.cfstage').classList.contains('is-bird'), getComputedStyle(document.querySelector('.cfbird')).display, getComputedStyle(document.querySelector('.cfl-window')).display, getComputedStyle(document.querySelector('.cfdust')).display, document.querySelector('.cfyarn').classList.contains('is-roll'), document.querySelector('.cfl-rug').classList.contains('is-wobble')].join());
  ok('ambience: reduced motion: no frame change, no bird (the window overlay with the robin stays), no dust, no yarn roll, no rug wobble', rr, '0,false,none,block,none,false,false');
  // 2.1.07: the buy flow in a real browser: the cost leaves the counter at once, pending taps ride the buy, the scene changes in place (no reload), a refused or failed buy puts the number right
  const num = t => parseInt(String(t).replace(/\D/g, ''), 10);
  const kib = () => p.$eval('#cf-kibble', e => e.textContent).then(num);
  sql(process.env.SQL_BUY);
  c = await br.newContext({ viewport: { width: 412, height: 900 } }); p = await c.newPage(); const errs3 = []; p.on('pageerror', e => errs3.push(String(e)));
  const reqs = []; p.on('request', r => { if (/catfish_api/.test(r.url()) && r.method() === 'POST') reqs.push(r.postData() || ''); });
  await login(p);
  await p.route('**/catfish_api.php', async r => { await new Promise(x => setTimeout(x, 700)); r.continue(); });
  await p.waitForTimeout(500);
  await p.evaluate(() => { window.__mark = 'same page'; window.__oldStage = document.querySelector('.cfstage'); });
  const k0 = await kib();
  ok('buy: before, no room overlay, no dust, no bird', await p.evaluate(() => [document.querySelectorAll('.cfroom-layer').length, document.querySelectorAll('.cfdust').length].join()), '0,0');
  const cost1 = +(await p.getAttribute('#cf-ups form[data-key=sunbeam] button', 'data-cost'));
  await p.click('.cftabs [data-branch=room]');
  await p.click('#cf-ups form[data-key=sunbeam] button');
  await p.waitForTimeout(250);
  ok('buy: the cost leaves the Kibble counter at once (before the reply), the pressed button is off', (await kib()) + ',' + await p.$eval('#cf-ups form[data-key=sunbeam] button', b => b.disabled), (k0 - cost1) + ',true');
  ok('buy: a small -N shows by the counter (class go, minus sign and the cost)', await p.$eval('#cf-spend', e => e.classList.contains('go') + ',' + parseInt(e.textContent.replace(/\D/g, ''), 10)).catch(() => 'x'), 'true,' + cost1);
  await p.waitForTimeout(1200);
  ok('buy: the room overlay and the dust motes appear in place after the reply, same page (no reload)', await p.evaluate(() => [document.querySelectorAll('.cfl-sunbeam').length, document.querySelectorAll('.cfdust i').length, window.__mark].join()), '1,6,same page');
  ok('buy: the stage is a new node and the old one is gone (one stage, one manifest, one active cat)', await p.evaluate(() => [window.__oldStage !== document.querySelector('.cfstage'), document.contains(window.__oldStage), document.querySelectorAll('.cfstage').length, document.querySelectorAll('#cf-frames').length, document.querySelectorAll('.cfactive').length].join()), 'true,false,1,1,1');
  ok('buy: the counter shows the server value (cost paid once) and the rate went up', (await kib() <= k0 - cost1 + 5) + ',' + (await kib() >= k0 - cost1 - 5) + ',' + await p.$eval('#cf-kph', e => +e.textContent > 600), 'true,true,true');
  ok('buy: the row shows x1 and the button is back on', await p.$eval('#cf-ups form[data-key=sunbeam]', f => f.querySelector('small.muted').textContent + ',' + f.querySelector('button').disabled), '×1,false');
  await watch(p, '.cfactive', '__seq3');
  await p.waitForTimeout(9000);
  ok('buy: the cat on the new stage keeps animating (frames change by themselves)', await p.evaluate(() => window.__seq3.length > 1), true);
  const kp = await kib(); await p.click('.cfsdrop.sd1', { force: true }); await p.waitForTimeout(250);
  ok('buy: a tap on a fish of the new stage works (counter +v, fish bounces, cat swats)', (await kib() > kp) + ',' + await p.$eval('.cfsdrop.sd1', b => b.classList.contains('is-hit')) + ',' + (await p.getAttribute('.cfactive', 'data-anim-state')), 'true,true,play');
  await p.waitForTimeout(2500);
  // a pending tap rides the buy request (play and seq), is cleared after the reply, and the new stage shows it as zero pending
  const nReq = reqs.length;
  await p.click('.cfsdrop.sd2', { force: true }); await p.waitForTimeout(100);
  const pend0 = +(await p.getAttribute('.cfstage', 'data-play-pending'));
  ok('buy: taps are pending on the stage before the buy (the fish tap above and this one)', pend0 >= 1, true);
  const kq = await kib();
  await p.click('.cftabs [data-branch=fish]');
  await p.click('#cf-ups form[data-key=silk] button'); await p.waitForTimeout(1500);
  const bq = reqs.slice(nReq).find(x => /name="do"\s+buy/.test(x)) || '';
  ok('buy: the request carries play=<pending taps>, a seq and the scene key', new RegExp('name="play"\\s+' + pend0 + '\\s').test(bq) + ',' + /name="seq"\s+\d{6,}/.test(bq) + ',' + /name="scene"/.test(bq), 'true,true,true');
  ok('buy: after the reply no tap is pending, silk is x1, and the new fish kind is in the stage', await p.evaluate(() => [document.querySelector('.cfstage').getAttribute('data-play-pending'), document.querySelector('#cf-ups form[data-key=silk] small.muted').textContent, document.querySelectorAll('.cfsdrop.cfk-2').length].join()), '0,×1,1');
  const dq = (await kib()) - (kq - 150);
  ok('buy: Kibble after the silk buy is the number before minus 150 (the taps were already counted and are paid by the same request), give or take a second of income', dq >= -3 && dq <= 8 ? 'ok' : 'off by ' + dq, 'ok');
  // refused: another tab spent everything
  sql("UPDATE catfish_state SET kibble=0, last_tick={NOW} WHERE user_id=" + process.env.UIDX);
  await p.waitForTimeout(100);
  const costR = +(await p.getAttribute('#cf-ups form[data-key=catnip] button', 'data-cost'));
  const kr = await kib();
  await p.click('.cftabs [data-branch=fish]');
  await p.click('#cf-ups form[data-key=catnip] button'); await p.waitForTimeout(250);
  ok('buy refused: the number dips at once (optimistic)', await kib(), kr - costR);
  await p.waitForTimeout(1200);
  ok('buy refused: the number is the server value again, the reason is shown (error style), nothing bought, the button is not stuck', (await kib()) + ',' + await p.$eval('#cf-msg', e => e.textContent + ',' + e.className) + ',' + await p.$eval('#cf-ups form[data-key=catnip] small.muted', e => e.textContent), '0,Not enough Kibble.,flash err,×0');
  // network failure: the number is given back
  sql("UPDATE catfish_state SET kibble=5000, last_tick={NOW} WHERE user_id=" + process.env.UIDX);
  await p.goto(B + '/catfish.php');
  await p.route('**/catfish_api.php', r => r.abort());
  const kn = await kib();
  await p.click('.cftabs [data-branch=fish]');
  await p.click('#cf-ups form[data-key=catnip] button'); await p.waitForTimeout(600);
  ok('buy with no reply: the Kibble is given back, a message says so, the button is on again', (await kib()) + ',' + await p.$eval('#cf-msg', e => e.textContent) + ',' + await p.$eval('#cf-ups form[data-key=catnip] button', b => b.disabled), kn + ',Could not reach the game. Try again.,false');
  ok('buy flow: no page errors', errs3.join('|'), '');
  await c.close();
  // reduced motion: the -N only fades, the scene still changes, the cat stays still
  sql(process.env.SQL_BUY);
  c = await br.newContext({ viewport: { width: 412, height: 900 }, reducedMotion: 'reduce' }); p = await c.newPage(); await login(p);
  await p.route('**/catfish_api.php', async r => { await new Promise(x => setTimeout(x, 500)); r.continue(); });
  await p.waitForTimeout(500);
  await p.click('.cftabs [data-branch=room]');
  await p.click('#cf-ups form[data-key=sunbeam] button'); await p.waitForTimeout(150);
  ok('buy, reduced motion: the -N fades (cfspendfade), it does not move', await p.$eval('#cf-spend', e => getComputedStyle(e).animationName), 'cfspendfade');
  await p.waitForTimeout(1200);
  await watch(p, '.cfactive', '__seq4');
  await p.waitForTimeout(5000);
  ok('buy, reduced motion: the overlay appears, no dust (hidden), the cat stays on idleA and never changes frame', await p.evaluate(() => [document.querySelectorAll('.cfl-sunbeam').length, getComputedStyle(document.querySelector('.cfdust')).display, document.querySelector('.cfactive').getAttribute('data-frame'), window.__seq4.length].join()), '1,none,idleA,0');
  await c.close();
  // no JavaScript: the plain form post still buys
  sql(process.env.SQL_BUY);
  c = await br.newContext({ viewport: { width: 412, height: 900 }, javaScriptEnabled: false }); p = await c.newPage(); await login(p);
  await Promise.all([p.waitForNavigation(), p.click('#cf-ups form[data-key=sunbeam] button')]);
  ok('buy without JS: the form post buys and the page shows the overlay after the redirect', await p.evaluate(() => document.querySelectorAll('.cfl-sunbeam').length + ',' + document.querySelector('#cf-ups form[data-key=sunbeam] small.muted').textContent), '1,×1');
  await c.close();
  await br.close();
  console.log(out.join('\n'));
})().catch(e => { if (out.length) console.log(out.join('\n')); console.log('FAIL anim script: ' + e.message); process.exit(0); });
