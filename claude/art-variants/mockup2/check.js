// Mockup 2 checks + screenshots. Usage: node claude/art-variants/mockup2/check.js
// Runs every combination of phone width (360/390/430) x theme (light/dark) x content (real labels / longest real labels)
// x font (system-ui = Inter here / DejaVu Sans, a wider face) and checks, for every text element inside a phone:
//   overflow   scrollWidth > clientWidth (text wider than its box)
//   truncated  an ellipsis or line-clamp actually cut text (scrollHeight/scrollWidth past the box)
//   escape     the text box pokes outside its container (card ribbon / card / banner / find / phone)
//   overlap    two text boxes intersect
//   tap        a button or link smaller than 44 x 44
//   contrast   text vs its (composited) background below 4.5:1 (art backgrounds use the art's base colour)
//   images     an <img> that failed to load
//   motion     the sparkle animates normally and is static under prefers-reduced-motion
// Writes overflow-check.json (every finding) and overflow-check.txt (summary), plus the screenshots.
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const HERE = __dirname;
const URL = 'file://' + path.join(HERE, 'mock.html');
const WIDTHS = [360, 390, 430];

// longest real strings (game/includes: data/stop_acts.txt, data/gatherables.txt, tools.php TOOL_TYPES/TOOL_ITEMS, gnome.php GNOME_STATS, data/stops.txt)
const STRESS = {
  gatherLabel: ['Rock picking', 'Bug catching', 'Tide pooling'],
  gatherMeta: [['⚡1', '42 uses left'], ['⚡1', '30 days left'], ['Needs Masterwork']],
  doLabel: ['Riddle on the notice post', 'Chat with the toll-keeper', 'A hot bath and a soft bed', 'Tall tales by the hearth', 'Late supper by lamplight', 'After-rain mushrooms'],
  doMeta: [['🛏️ Rest', '1,400 Petals'], ['95% · easy', 'Hardiness check'], ['⚡2', '45% · fair'], ['⚡1', 'Hardiness check'], ['✔ Done today'], ['Needs tier 2']],
  bannerName: 'Shed Butterfly Scales',
  tileNames: ['Shed Butterfly Scales', 'Shed Dragonfly Wing', 'Amber Chanterelle', 'Stag Beetle Shell'],
  tag: 'Hooked Forager’s Knife',
  rarTag: '✦ Legendary',
  findNames: ['Shed Butterfly Scales', 'Shed Dragonfly Wing', 'Fiddlehead Ferns', 'Stag Beetle Shell', 'Bromeliad Seeds', '???'],
  findNeed: 'needs Masterwork',
  beltNow: '<b>Hooked Forager’s Knife</b> · Masterwork · 30 days left',
  stopName: 'Tinkers’ workshop',
  amb: 'Stallholders pack up the last of the day’s bargains.',
  doSub: '12 of 12 left this visit',
  flag: 'Built here',
  chips: ['🌲 Tropical Rainforest', '⚡ 120 / 120'],
};

function applyStress(S) {
  const set = (sel, vals) => document.querySelectorAll(sel).forEach((el, i) => { el.textContent = vals[i % vals.length]; });
  const meta = (sel, rows) => document.querySelectorAll(sel).forEach((el, i) => { el.innerHTML = rows[i % rows.length].map(t => '<span>' + t + '</span>').join(''); });
  set('[data-screen=gather] .gcard__label', S.gatherLabel);
  meta('[data-screen=gather] .gcard__meta', S.gatherMeta);
  set('[data-screen=do] .gcard__label', S.doLabel);
  meta('[data-screen=do] .gcard__meta', S.doMeta);
  set('[data-screen=gather] .gx-banner__name', [S.bannerName]);
  set('.rtile .gx-banner__name', S.tileNames);
  set('[data-screen=gather] .gx-banner__meta .gx-tag:not(.gx-tag--rar):last-child', [S.tag]);
  set('.gx-tag--rar', [S.rarTag]);
  set('.find__name', S.findNames);
  set('.find__need', [S.findNeed]);
  document.querySelector('.belt__now').innerHTML = S.beltNow;
  set('.dohead__name', [S.stopName]);
  set('.dohead__amb', [S.amb]);
  set('[data-screen=do] .gx-h__sub', [S.doSub]);
  set('.gcard__flag', [S.flag]);
  set('.gx-chip', S.chips);
  document.querySelectorAll('.ptabs__badge').forEach(b => { b.textContent = '12'; });
}

function audit() {
  const out = [];
  const hex = c => { const m = c.match(/rgba?\(([^)]+)\)/); if (!m) return null; const p = m[1].split(/[ ,/]+/).filter(Boolean).map(Number); return { r: p[0], g: p[1], b: p[2], a: p.length > 3 ? p[3] : 1 }; };
  const parseHex = h => ({ r: parseInt(h.slice(1, 3), 16), g: parseInt(h.slice(3, 5), 16), b: parseInt(h.slice(5, 7), 16), a: 1 });
  const lum = c => { const f = v => { v /= 255; return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); }; return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b); };
  const ratio = (a, b) => { const x = lum(a), y = lum(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); };
  const over = (top, bot) => ({ r: top.r * top.a + bot.r * (1 - top.a), g: top.g * top.a + bot.g * (1 - top.a), b: top.b * top.a + bot.b * (1 - top.a), a: 1 });
  // base colours of the art the text sits on (mockup2/gather_b.py FELT / SIGN; c/ scene sky, the lightest thing behind the hero chips)
  const FELT = { idle: '#c9a46a', sel: '#8fae5c', off: '#bdb6a6' }, SIGN = { idle: '#8e3c2a', sel: '#e0aa48', off: '#d6d0c2' };
  const cardState = card => card.matches(':disabled,[aria-disabled="true"]') ? 'off' : card.getAttribute('aria-pressed') === 'true' ? 'sel' : 'idle';
  const artBg = el => {
    const card = el.closest('.gcard');
    if (card && !el.closest('.gcard__flag')) return parseHex(el.closest('.gcard__ribbon') ? SIGN[cardState(card)] : FELT[cardState(card)]);
    if (el.closest('.gx-hero')) return parseHex('#c8e6ea');
    return null;
  };
  const bgOf = el => {
    const layers = [];
    for (let n = el; n && n.nodeType === 1; n = n.parentElement) {
      const art = artBg(n === el ? el : n);
      if (n.matches('.gcard__ribbon, .gcard, .gx-hero') && art) { layers.push(art); break; }
      const c = hex(getComputedStyle(n).backgroundColor);
      if (c && c.a > 0) { layers.push(c); if (c.a >= 1) break; }
    }
    let acc = layers.pop() || { r: 255, g: 255, b: 255, a: 1 };
    while (layers.length) acc = over(layers.pop(), acc);
    return acc;
  };
  const R = el => el.getBoundingClientRect();
  const ownText = el => [...el.childNodes].some(n => n.nodeType === 3 && n.textContent.trim() !== '');
  const label = el => { const c = (el.className && typeof el.className === 'string') ? '.' + el.className.trim().split(/\s+/).join('.') : ''; return el.tagName.toLowerCase() + c + ' "' + el.textContent.trim().slice(0, 40) + '"'; };
  for (const ph of document.querySelectorAll('.ph')) {
    const screen = ph.dataset.screen, pr = R(ph);
    const texts = [...ph.querySelectorAll('*')].filter(el => ownText(el) && !el.closest('.vh') && getComputedStyle(el).display !== 'none' && R(el).width > 0);
    for (const el of texts) {
      const cs = getComputedStyle(el), r = R(el), inline = cs.display === 'inline';
      const box = inline ? el.parentElement : el;
      if (box.scrollWidth > box.clientWidth + 1 && box.clientWidth > 0) out.push({ screen, kind: 'overflow', el: label(el), detail: box.scrollWidth + ' > ' + box.clientWidth });
      if (!inline && (cs.webkitLineClamp !== 'none' && cs.webkitLineClamp) && el.scrollHeight > el.clientHeight + 1) out.push({ screen, kind: 'truncated', el: label(el), detail: 'line-clamp cut: ' + el.scrollHeight + ' > ' + el.clientHeight });
      if (!inline && cs.textOverflow === 'ellipsis' && el.scrollWidth > el.clientWidth) out.push({ screen, kind: 'truncated', el: label(el), detail: 'ellipsis: ' + el.scrollWidth + ' > ' + el.clientWidth });
      // containment
      const rib = el.closest('.gcard__ribbon');
      let cont = rib || el.closest('.gcard, .gx-banner, .find, .belt, .dohead__plate, .gbtn, .ptabs a, .gx-chip, .gx-hero') || ph;
      let cr = R(cont);
      if (rib) { const s = getComputedStyle(rib); cr = { left: cr.left + parseFloat(s.borderLeftWidth), right: cr.right - parseFloat(s.borderRightWidth), top: cr.top + parseFloat(s.borderTopWidth) - 2, bottom: cr.bottom - parseFloat(s.borderBottomWidth) + 2 }; }
      if (el.closest('.gcard__flag')) cr = R(el.closest('.gcard'));
      const t = 0.5;
      if (r.left < cr.left - t || r.right > cr.right + t || r.top < cr.top - t || r.bottom > cr.bottom + t) out.push({ screen, kind: 'escape', el: label(el), detail: 'outside ' + label(cont).split(' "')[0] });
      if (r.left < pr.left - t || r.right > pr.right + t) out.push({ screen, kind: 'escape', el: label(el), detail: 'outside the phone' });
      // contrast
      const fg = hex(cs.color), bg = bgOf(el);
      if (fg && bg) { const k = ratio(fg, bg); const big = parseFloat(cs.fontSize) >= 24 || (parseFloat(cs.fontSize) >= 18.66 && +cs.fontWeight >= 700); if (k < (big ? 3 : 4.5)) out.push({ screen, kind: 'contrast', el: label(el), detail: k.toFixed(2) + ':1' }); }
    }
    // overlap between text boxes (not nested)
    for (let i = 0; i < texts.length; i++) for (let j = i + 1; j < texts.length; j++) {
      const a = texts[i], b = texts[j];
      if (a.contains(b) || b.contains(a)) continue;
      const p = R(a), q = R(b);
      const ix = Math.min(p.right, q.right) - Math.max(p.left, q.left), iy = Math.min(p.bottom, q.bottom) - Math.max(p.top, q.top);
      if (ix > 1 && iy > 1) out.push({ screen, kind: 'overlap', el: label(a), detail: 'with ' + label(b) });
    }
    for (const el of ph.querySelectorAll('button, a, [role=button]')) { const r = R(el); if (r.width < 44 || r.height < 44) out.push({ screen, kind: 'tap', el: label(el), detail: r.width.toFixed(1) + ' x ' + r.height.toFixed(1) }); }
    for (const el of ph.querySelectorAll('.belt__slot')) { const r = R(el); if (r.width < 44 || r.height < 44) out.push({ screen, kind: 'tap', el: label(el), detail: r.width.toFixed(1) + ' x ' + r.height.toFixed(1) }); }
    for (const im of ph.querySelectorAll('img')) if (!im.complete || !im.naturalWidth) out.push({ screen, kind: 'images', el: im.getAttribute('src'), detail: 'not loaded' });
    const texts2 = texts.length;
    out.push({ screen, kind: '_count', detail: texts2 });
  }
  return out;
}

(async () => {
  const browser = await chromium.launch();
  const runs = [], findings = [];
  for (const theme of ['light', 'dark']) for (const content of ['real', 'stress']) for (const font of ['system-ui', 'wide']) for (const w of WIDTHS) {
    const ctx = await browser.newContext({ viewport: { width: w * 3 + 48 + 48, height: 900 }, reducedMotion: 'reduce', deviceScaleFactor: 1 });
    const page = await ctx.newPage();
    await page.goto(URL);
    await page.evaluate(([w, theme, font]) => {
      const h = document.documentElement; h.className = 'w' + w + (font === 'wide' ? ' widefont' : '');
      if (theme === 'dark') h.dataset.theme = 'dark'; else delete h.dataset.theme;
    }, [w, theme, font]);
    if (content === 'stress') await page.evaluate(applyStress, STRESS);
    await page.evaluate(() => document.fonts.ready);
    await page.waitForFunction(() => [...document.images].every(i => i.complete));
    const res = await page.evaluate(audit);
    const count = res.filter(r => r.kind === '_count').reduce((s, r) => s + r.detail, 0);
    const bad = res.filter(r => r.kind !== '_count');
    const key = { width: w, theme, content, font };
    runs.push({ ...key, textElements: count, problems: bad.length });
    bad.forEach(b => findings.push({ ...key, ...b }));
    if (content === 'real' && font === 'system-ui' && theme === 'light') await page.screenshot({ path: path.join(HERE, `mockup2-${w}.png`), fullPage: true });
    if (content === 'real' && font === 'system-ui' && theme === 'dark' && w === 390) await page.screenshot({ path: path.join(HERE, 'mockup2-dark.png'), fullPage: true });
    if (content === 'stress' && font === 'wide' && theme === 'light' && w === 360) await page.screenshot({ path: path.join(HERE, 'mockup2-stress-360.png'), fullPage: true });
    await ctx.close();
  }
  // motion: sparkle animates normally, static under reduced motion
  const motion = {};
  for (const rm of ['no-preference', 'reduce']) {
    const ctx = await browser.newContext({ viewport: { width: 1300, height: 900 }, reducedMotion: rm });
    const page = await ctx.newPage(); await page.goto(URL);
    motion[rm] = await page.evaluate(() => { const s = getComputedStyle(document.querySelector('.gx-spark')); const i = getComputedStyle(document.querySelector('.gx-item')); return { spark: s.animationName, sparkPos: s.backgroundPosition, item: i.animationName }; });
    await ctx.close();
  }
  const motionOk = motion['no-preference'].spark === 'gx-spark' && motion.reduce.spark === 'none' && motion.reduce.item === 'none';
  if (!motionOk) findings.push({ kind: 'motion', detail: JSON.stringify(motion) });
  // inline style / script audit (strict CSP)
  const html = fs.readFileSync(path.join(HERE, 'mock.html'), 'utf8');
  const inline = (html.match(/\sstyle=|<style|<script|\son[a-z]+=/gi) || []).length;
  if (inline) findings.push({ kind: 'csp', detail: inline + ' inline style/script/handler' });
  await browser.close();

  const byKind = {};
  findings.forEach(f => { byKind[f.kind] = (byKind[f.kind] || 0) + 1; });
  fs.writeFileSync(path.join(HERE, 'overflow-check.json'), JSON.stringify({ when: new Date().toISOString(), runs, motion, inlineStyleOrScript: inline, findings }, null, 2));
  const lines = ['Satchel mockup 2: text-fit / tap / contrast check (check.js)', '',
    'width theme content font        text-els problems'];
  runs.forEach(r => lines.push(String(r.width).padEnd(6) + r.theme.padEnd(6) + r.content.padEnd(8) + r.font.padEnd(12) + String(r.textElements).padStart(8) + String(r.problems).padStart(9)));
  lines.push('', 'reduced motion: ' + (motionOk ? 'OK' : 'FAIL') + ' ' + JSON.stringify(motion), 'inline style/script in mock.html: ' + inline, '',
    'findings: ' + findings.length + (findings.length ? ' ' + JSON.stringify(byKind) : ' (none)'));
  findings.slice(0, 80).forEach(f => lines.push(`  [${f.kind}] ${f.width || ''} ${f.theme || ''} ${f.content || ''} ${f.font || ''} ${f.screen || ''}: ${f.el || ''} ${f.detail}`));
  fs.writeFileSync(path.join(HERE, 'overflow-check.txt'), lines.join('\n') + '\n');
  console.log(lines.join('\n'));
})();
