// node tests/hovel_room_page.js BASE : the interactive hovel room in a real browser, called by tests/hovel_room.sh (skipped without playwright).
// Player sprout is at home at 10:00 with the slim home, the game clock and the tea kettle on.
// SHOTS=/some/dir also writes screenshots (390 x 844, light and dark). Prints "  ok   ..." / "  FAIL ..." lines.
const { chromium } = require('playwright');
const B = process.argv[2];
const out = []; const ok = (name, got, want) => out.push((got === want ? '  ok   ' : '  FAIL ') + name + (got === want ? '' : " (got '" + got + "', want '" + want + "')"));
(async () => {
  const br = await chromium.launch({ args: ['--no-sandbox'] }).catch(() => chromium.launch());
  const c = await br.newContext({ viewport: { width: 390, height: 844 } }); const p = await c.newPage(); const errs = [];
  p.on('pageerror', e => errs.push(String(e)));
  p.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
  await p.goto(B + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
  await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]); await p.goto(B + '/gnome.php');
  const boxes = await p.evaluate(() => [...document.querySelectorAll('.hs-room .ht-hit, .hs-room .hd-hit')].map(r => { const b = r.getBoundingClientRect(); return [r.parentNode.getAttribute('class').split(' ')[1], b.x, b.y, b.width, b.height]; }));
  ok('six tap boxes in the room', boxes.length, 6);
  const small = boxes.filter(b => b[3] < 44 || b[4] < 44).map(b => b[0] + ' ' + Math.round(b[3]) + 'x' + Math.round(b[4]));
  ok('no tap box under 44 px at 390 wide (' + boxes.map(b => b[0].replace(/^h[td]-/, '') + ' ' + Math.round(b[3]) + 'x' + Math.round(b[4])).join(', ') + ')', small.join(', '), '');
  const clash = []; for (let i = 0; i < boxes.length; i++) for (let j = i + 1; j < boxes.length; j++) { const a = boxes[i], b = boxes[j]; if (a[1] < b[1] + b[3] - .5 && b[1] < a[1] + a[3] - .5 && a[2] < b[2] + b[4] - .5 && b[2] < a[2] + a[4] - .5) clash.push(a[0] + '/' + b[0]); }
  ok('no two tap boxes overlap on the screen', clash.join(', '), '');
  ok('each thing is the top element at its middle (nothing covers it)', await p.evaluate(() => [...document.querySelectorAll('.hs-room .ht-hit, .hs-room .hd-hit')].filter(r => { const b = r.getBoundingClientRect(); return document.elementFromPoint(b.x + b.width / 2, b.y + b.height / 2) !== r; }).length), 0);
  ok('the page does not scroll sideways', await p.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth), true);
  const row = await p.evaluate(() => [...document.querySelectorAll('.hs-btns .hs-sb')].map(b => { const r = b.getBoundingClientRect(); return [b.textContent.trim(), r.width, r.height, r.y]; }));
  ok('the sleep row: Sleep and Nap', row.map(r => r[0]).join(' | '), 'Sleep | Nap');
  ok('...small buttons (40 px high, under the old 52), on one line', row.every(r => r[2] >= 36 && r[2] < 52) && row.every(r => r[3] === row[0][3]), true);
  ok('...under the picture and the greeting', await p.evaluate(() => { const y = s => document.querySelector(s).getBoundingClientRect(); return y('.hs-room').bottom <= y('.hs-hi').top && y('.hs-hi').bottom <= y('.hs-btns').top && y('.hs-btns').bottom <= y('.hstabs').top; }), true);
  ok('the greeting is one line', await p.evaluate(() => { const h = document.querySelector('.hs-hi'); return h.getBoundingClientRect().height < 2 * parseFloat(getComputedStyle(h).fontSize) && /^Good \w+, \S+!$/.test(h.textContent); }), true);
  const mid = async sel => { const b = await p.locator(sel).boundingBox(); return [b.x + b.width / 2, b.y + b.height / 2]; };
  const tap = async sel => { const [x, y] = await mid(sel); await p.mouse.click(x, y); await p.waitForTimeout(250); };
  // the gnome: a hop and a bubble
  ok('the bubble is hidden', await p.locator('.hs-say').isVisible(), false);
  await tap('.hs-room a.ht-gnome .ht-hit');
  ok('a tap on the gnome: the greeting in a bubble, no page load', (await p.locator('.hs-say').isVisible()) && /^Good \w+!$/.test(await p.locator('.hs-say').innerText()) && await p.evaluate(() => location.pathname.endsWith('/gnome.php') && location.search === ''), true);
  ok('...and a hop', await p.evaluate(() => document.querySelector('.hs-room .hr-gnome').classList.contains('hop')), true);
  await tap('.hs-room a.ht-gnome .ht-hit');
  ok('a second tap: a mood line', ['Rested and ready!', 'Tired: a nap?', 'A fine day for a wander.'].includes(await p.locator('.hs-say').innerText()), true);
  ok('...the bubble stays inside the picture', await p.evaluate(() => { const a = document.querySelector('.hs-say').getBoundingClientRect(), b = document.querySelector('.hs-room').getBoundingClientRect(); return a.left >= b.left && a.right <= b.right && a.top >= b.top; }), true);
  // the lamp: a look only
  ok('the lamp is off by day', await p.evaluate(() => document.querySelector('.hs-room svg').classList.contains('lamp-on') || getComputedStyle(document.querySelector('.hr-lampglow')).opacity !== '0'), false);
  await tap('.hs-room a.ht-lamp .ht-hit');
  ok('a tap on the lamp lights it, no page load', await p.evaluate(() => document.querySelector('.hs-room svg').classList.contains('lamp-on') && document.querySelector('a.ht-lamp').getAttribute('aria-pressed') === 'true' && location.search === ''), true);
  await tap('.hs-room a.ht-lamp .ht-hit');
  ok('...and again switches it off', await p.evaluate(() => document.querySelector('.hs-room svg').classList.contains('lamp-on')), false);
  // focus: the dotted outline
  await p.keyboard.press('Tab'); await p.waitForTimeout(400);   // from the lamp (focused by the tap) to the next thing, with the keyboard
  ok('keyboard focus on a thing shows its dotted outline', await p.evaluate(() => { const a = document.activeElement, o = a && a.querySelector('.ht-out'); if (!o || !a.closest('.hs-room')) return 'focus is on ' + (a && a.getAttribute('class')); const s = getComputedStyle(o); return s.opacity === '1' && s.strokeDasharray !== 'none'; }), true);
  if (process.env.SHOTS) await p.screenshot({ path: process.env.SHOTS + '/hovel-today.png' });
  // the window and the bed: dialogs
  await tap('.hs-room a.ht-window .ht-hit');
  ok('a tap on the window opens the weather card as a modal dialog', await p.evaluate(() => { const d = document.getElementById('hp-window'); return d.open && d.matches(':modal') && location.search === '' && /Today[\s\S]*Tomorrow/.test(d.innerText); }), true);
  await p.locator('#hp-window [data-hdlg-close]').click(); await p.waitForTimeout(200);
  ok('...Close shuts it', await p.evaluate(() => document.getElementById('hp-window').open), false);
  await tap('.hs-room a.hd-kettle .hd-hit');
  ok('the kettle still opens the tea popover', await p.evaluate(() => document.getElementById('htea').matches(':modal')), true);
  await p.keyboard.press('Escape'); await p.waitForTimeout(200);
  await tap('.hs-room a.ht-bed .ht-hit');
  ok('a tap on the bed opens its card', await p.evaluate(() => { const d = document.getElementById('hp-bed'); return d.open && d.matches(':modal') && location.search === ''; }), true);
  ok('...Go to sleep and Nap, 44 px or more', await p.evaluate(() => [...document.querySelectorAll('#hp-bed .hpop-acts .btn')].map(b => b.textContent + ':' + (b.getBoundingClientRect().height >= 44)).join(' ')), 'Go to sleep:true Nap:true');
  if (process.env.SHOTS) await p.screenshot({ path: process.env.SHOTS + '/hovel-bed.png' });
  const day0 = await p.evaluate(() => document.querySelector('.hs-tag').textContent);
  await Promise.all([p.waitForURL(/tab=today/), p.locator('#hp-bed button[value=home_nap]').click()]);
  await p.waitForTimeout(300);
  ok('Nap from the card: the clock moved on, back on Today', await p.evaluate(d => { const t = document.querySelector('.hs-tag').textContent; return t !== d && !!document.querySelector('.hs-room svg.hroom-things'); }, day0), true);
  // reduced motion: nothing moves
  const c2 = await br.newContext({ viewport: { width: 390, height: 844 }, reducedMotion: 'reduce', storageState: await c.storageState() }); const p2 = await c2.newPage();
  await p2.goto(B + '/gnome.php');
  ok('reduced motion: no animation in the room', await p2.evaluate(() => ['.hr-gnome', '.hr-steam .a', '.hr-zz .a', 'a.ht-bed .ht-out'].map(s => getComputedStyle(document.querySelector('.hs-room ' + s)).animationName).join(',')), 'none,none,none,none');
  await c2.close();
  ok('with motion: the gnome bobs, the steam rises', await p.evaluate(() => ['.hr-gnome', '.hr-steam .a'].map(s => getComputedStyle(document.querySelector('.hs-room ' + s)).animationName).join(',')), 'hr-bob,hr-rise');
  // Furnish: the slot taps are as they were
  await p.goto(B + '/gnome.php?tab=furnish');
  const fb = await p.locator('.hs-full a.hd-lamp .hd-hit').boundingBox();
  await p.mouse.click(fb.x + fb.width / 2, fb.y + fb.height / 2); await p.waitForTimeout(250);
  ok('Furnish: a tap on the lamp slot still opens its picker', await p.evaluate(() => document.getElementById('hpick-lamp').matches(':modal')), true);
  ok('no script errors', errs.join(' | '), '');
  console.log(out.join('\n'));
  await br.close();
  process.exit(out.some(l => l.startsWith('  FAIL')) ? 1 : 0);
})().catch(e => { console.log(out.join('\n')); console.log('  FAIL hovel_room_page.js crashed: ' + String(e).split('\n')[0]); process.exit(1); });
