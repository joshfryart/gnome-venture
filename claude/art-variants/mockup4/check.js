// Mockup 4 checks + screenshots (adapted from mockup2/check.js). Usage: node claude/art-variants/mockup4/check.js
// Every combination of width (360/390/430) x theme (light/dark) x content (real / longest real) x font (system-ui = Inter here / DejaVu Sans, wider)
// and, for every text element inside a phone:
//   overflow   scrollWidth > clientWidth          truncated  a line-clamp or ellipsis actually cut text
//   escape     text pokes outside its box (ribbon inner box / item square / chip / basket / sheet / phone)
//   overlap    two text boxes intersect           tap        button, link, summary or select smaller than 44 x 44
//   contrast   text vs its composited background below 4.5:1 (3:1 large); felt and signs are art, so their base colours are used
//   images     an <img> that failed to load       motion     sparkle animates normally, still under prefers-reduced-motion
//   lines      an item name on more than 2 lines (the clamp guard is 3, so nothing is cut; this flags the 2-line design rule)
//   grid       columns: 3 at phone widths, 6 in the 1400 px frame; ribbons in a row share one height (subgrid)
//   csp        inline style / script / handler in mock.html
// Writes overflow-check.json (every finding) and overflow-check.txt (summary) plus the screenshots.
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const HERE = __dirname;
const URL = 'file://' + path.join(HERE, 'mock.html');
const WIDTHS = [360, 390, 430];

// longest real strings: item names (seed packets: includes/flowers.php "<flower> Seed Packet"; broken tools: tools.php "Broken <tool>";
// recipes.txt, crafts.txt, hybrids.txt), the biggest count the Satchel shows in the mock and a five-figure price
const STRESS = {
  names: ['Night-flowering Jasmine Seed Packet', 'Chocolate Cosmos Hybrid Seed Packet', 'Goat Cheese and Quail Egg Tart', 'Broken Masterwork Harvest Cart',
    'Cloud Monastery Chili Crisp', 'Goat Cheese Stuffed Peppers', 'Timber Planks (palm trunk)', 'Mistmoor Cloudberry Supper', 'Birchbramble Steppe Table',
    'Broken Hooked Forager’s Knife', 'Bleeding Glory-bower Cutting'],
  count: '×9,999',
  price: '12,500',
};

function applyStress(S) {
  document.querySelectorAll('.itm').forEach((card, i) => {
    // the same rules the server uses: kind words lifted into the first foot chip, then .itm--long (> 15) / .itm--xlong (> 22)
    let n = S.names[i % S.names.length], kind = '';
    if (n.startsWith('Broken ')) { n = n.slice(7); kind = 'Broken'; }
    for (const [suf, k] of [[' Seed Packet', 'Seed packet'], [' Seeds', 'Seeds'], [' Seedling', 'Seedling'], [' Cutting', 'Cutting']]) if (!kind && n.endsWith(suf)) { n = n.slice(0, -suf.length); kind = k; }
    card.querySelector('.itm__name').textContent = n;
    card.classList.remove('itm--long', 'itm--xlong');
    if (n.length > 19) card.classList.add('itm--xlong'); else if (n.length > 13) card.classList.add('itm--long');
    const foot = card.querySelector('.itm__foot');
    let kc = foot.querySelector('.itm__kind');
    if (kind) { if (!kc) { kc = document.createElement('span'); kc.className = 'itm__kind'; foot.prepend(kc); } kc.textContent = kind; } else if (kc) kc.remove();
    const c = card.querySelector('.itm__n'); if (c) c.lastChild.textContent = S.count;
    card.querySelectorAll('.itm__price').forEach(p => { p.firstChild.nodeType === 3 ? (p.firstChild.textContent = S.price) : p.childNodes[1].nodeType === 3 && (p.childNodes[1].textContent = S.price); });
  });
}

function audit() {
  const out = [];
  const hex = c => { const m = c.match(/rgba?\(([^)]+)\)/); if (!m) return null; const p = m[1].split(/[ ,/]+/).filter(Boolean).map(Number); return { r: p[0], g: p[1], b: p[2], a: p.length > 3 ? p[3] : 1 }; };
  const parseHex = h => ({ r: parseInt(h.slice(1, 3), 16), g: parseInt(h.slice(3, 5), 16), b: parseInt(h.slice(5, 7), 16), a: 1 });
  const lum = c => { const f = v => { v /= 255; return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); }; return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b); };
  const ratio = (a, b) => { const x = lum(a), y = lum(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); };
  const over = (top, bot) => ({ r: top.r * top.a + bot.r * (1 - top.a), g: top.g * top.a + bot.g * (1 - top.a), b: top.b * top.a + bot.b * (1 - top.a), a: 1 });
  // base colours of the art (item_art.py FELT, gather_b.py FELT off / SIGN)
  const FELT = { c: '#c9a46a', u: '#b4c07e', r: '#a9c8d0', l: '#e2be62', off: '#bdb6a6' }, SIGN = { idle: '#8e3c2a', sel: '#e0aa48', off: '#d6d0c2' };
  const cardOf = el => el.closest('.itm');
  const isSel = c => c.getAttribute('aria-pressed') === 'true' || c.classList.contains('is-sel') || (c.parentElement && c.parentElement.matches('details[open]'));
  const feltOf = c => c.classList.contains('is-off') ? 'off' : ['u', 'r', 'l'].find(k => c.classList.contains('itm--' + k)) || 'c';
  const artBg = n => {
    if (n.matches('.itm__rib')) { const c = cardOf(n); return parseHex(SIGN[c.classList.contains('is-off') ? 'off' : isSel(c) ? 'sel' : 'idle']); }
    if (n.matches('.itm')) return parseHex(FELT[feltOf(n)]);
    if (n.matches('.irec')) return parseHex(n.classList.contains('is-miss') ? FELT.off : FELT.c);
    return null;
  };
  const bgOf = el => {
    const layers = [];
    for (let n = el; n && n.nodeType === 1; n = n.parentElement) {
      const c = hex(getComputedStyle(n).backgroundColor);
      if (c && c.a > 0) { layers.push(c); if (c.a >= 1) break; }
      const art = artBg(n);
      if (art) { layers.push(art); break; }
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
    const texts = [...ph.querySelectorAll('*')].filter(el => ownText(el) && !el.closest('.vh, [hidden], dialog:not([open]), option') && getComputedStyle(el).display !== 'none' && R(el).width > 0);
    for (const el of texts) {
      const cs = getComputedStyle(el), r = R(el), inline = cs.display === 'inline';
      const box = inline ? el.parentElement : el;
      if (box.scrollWidth > box.clientWidth + 1 && box.clientWidth > 0) out.push({ screen, kind: 'overflow', el: label(el), detail: box.scrollWidth + ' > ' + box.clientWidth });
      if (!inline && (cs.webkitLineClamp !== 'none' && cs.webkitLineClamp) && el.scrollHeight > el.clientHeight + 1) out.push({ screen, kind: 'truncated', el: label(el), detail: 'line-clamp cut: ' + el.scrollHeight + ' > ' + el.clientHeight });
      if (!inline && cs.textOverflow === 'ellipsis' && el.scrollWidth > el.clientWidth) out.push({ screen, kind: 'truncated', el: label(el), detail: 'ellipsis: ' + el.scrollWidth + ' > ' + el.clientWidth });
      if (el.matches('.itm__name')) { const lines = Math.round(el.getBoundingClientRect().height / parseFloat(cs.lineHeight)); if (lines > 2) out.push({ screen, kind: 'lines', el: label(el), detail: lines + ' lines (design: 2 max)' }); }
      // containment
      const rib = el.closest('.itm__rib');
      const cont = rib || el.closest('.itm__foot > *, .itm, .ibasket, .irec, .isheet, .ichip, .fbtn, .ptabs a, .ihead') || ph;
      let cr = R(cont);
      if (rib) { const s = getComputedStyle(rib); cr = { left: cr.left + parseFloat(s.borderLeftWidth), right: cr.right - parseFloat(s.borderRightWidth), top: cr.top + parseFloat(s.borderTopWidth) - 2, bottom: cr.bottom - parseFloat(s.borderBottomWidth) + 2 }; }
      const t = 0.5;
      if (r.left < cr.left - t || r.right > cr.right + t || r.top < cr.top - t || r.bottom > cr.bottom + t) out.push({ screen, kind: 'escape', el: label(el), detail: 'outside ' + label(cont).split(' "')[0] });
      const card = cardOf(el);
      if (card && el.closest('.itm__foot')) { const k = R(card); if (r.left < k.left - t || r.right > k.right + t) out.push({ screen, kind: 'escape', el: label(el), detail: 'outside the item square' }); }
      if (r.left < pr.left - t || r.right > pr.right + t) out.push({ screen, kind: 'escape', el: label(el), detail: 'outside the phone' });
      const fg = hex(cs.color), bg = bgOf(el);
      if (fg && bg) { const k = ratio(fg, bg); const big = parseFloat(cs.fontSize) >= 24 || (parseFloat(cs.fontSize) >= 18.66 && +cs.fontWeight >= 700); if (k < (big ? 3 : 4.5)) out.push({ screen, kind: 'contrast', el: label(el), detail: k.toFixed(2) + ':1 on rgb(' + [bg.r, bg.g, bg.b].map(Math.round) + ')' }); }
    }
    for (let i = 0; i < texts.length; i++) for (let j = i + 1; j < texts.length; j++) {
      const a = texts[i], b = texts[j];
      if (a.contains(b) || b.contains(a)) continue;
      const p = R(a), q = R(b);
      const ix = Math.min(p.right, q.right) - Math.max(p.left, q.left), iy = Math.min(p.bottom, q.bottom) - Math.max(p.top, q.top);
      if (ix > 1 && iy > 1) out.push({ screen, kind: 'overlap', el: label(a), detail: 'with ' + label(b) });
    }
    for (const el of ph.querySelectorAll('button, a, summary, select, [role=button]')) {
      if (el.closest('dialog:not([open]), [hidden]')) continue;
      const r = R(el); if (r.width < 44 || r.height < 44) out.push({ screen, kind: 'tap', el: label(el), detail: r.width.toFixed(1) + ' x ' + r.height.toFixed(1) });
    }
    for (const im of ph.querySelectorAll('img')) if (!im.complete || !im.naturalWidth) out.push({ screen, kind: 'images', el: im.getAttribute('src'), detail: 'not loaded' });
    // grid: 3 columns on a phone; in each row every ribbon has the same height
    for (const g of ph.querySelectorAll('.itms')) {
      const cols = getComputedStyle(g).gridTemplateColumns.split(' ').length;
      if (cols !== 3 && pr.width < 500) out.push({ screen, kind: 'grid', el: label(g), detail: cols + ' columns at ' + pr.width });
      const rows = {};
      g.querySelectorAll('.itm__rib').forEach(rb => { const k = Math.round(R(rb).top); (rows[k] = rows[k] || []).push(Math.round(R(rb).height)); });
      for (const k in rows) if (Math.max(...rows[k]) - Math.min(...rows[k]) > 1) out.push({ screen, kind: 'grid', el: label(g), detail: 'ribbons in a row differ: ' + rows[k].join('/') });
    }
    out.push({ screen, kind: '_count', detail: texts.length });
  }
  return out;
}

const shot = async (page, id, file) => { await (await page.$('#s-' + id)).screenshot({ path: path.join(HERE, file) }); };

(async () => {
  const browser = await chromium.launch();
  const runs = [], findings = [];
  for (const theme of ['light', 'dark']) for (const content of ['real', 'stress']) for (const font of ['system-ui', 'wide']) for (const w of WIDTHS) {
    const ctx = await browser.newContext({ viewport: { width: 1400, height: 1000 }, reducedMotion: 'reduce', deviceScaleFactor: 1 });
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
    if (content === 'real' && font === 'system-ui' && theme === 'light' && w === 390)
      for (const id of ['satchel', 'shop-buy', 'shop-sell', 'craft', 'gift']) await shot(page, id, `mockup4-${id}-390.png`);
    if (content === 'real' && font === 'system-ui' && theme === 'light' && w === 360) await shot(page, 'satchel', 'mockup4-satchel-360.png');
    if (content === 'real' && font === 'system-ui' && theme === 'dark' && w === 390) { await shot(page, 'satchel', 'mockup4-satchel-dark.png'); await shot(page, 'shop-buy', 'mockup4-shop-buy-dark.png'); }
    if (content === 'stress' && font === 'wide' && theme === 'light' && w === 360) await shot(page, 'satchel', 'mockup4-stress-360.png');
    await ctx.close();
  }
  // desktop: the same markup in a 1400 px frame -> 6 columns
  {
    const ctx = await browser.newContext({ viewport: { width: 1460, height: 1000 }, reducedMotion: 'reduce' });
    const page = await ctx.newPage(); await page.goto(URL);
    await page.evaluate(() => { document.documentElement.className = 'w1400'; });
    await page.waitForFunction(() => [...document.images].every(i => i.complete));
    const cols = await page.evaluate(() => getComputedStyle(document.querySelector('[data-screen=satchel] .itms')).gridTemplateColumns.split(' ').length);
    const res = (await page.evaluate(audit)).filter(r => r.kind !== '_count' && r.screen === 'satchel');
    runs.push({ width: 1400, theme: 'light', content: 'real', font: 'system-ui', textElements: '-', problems: res.length + (cols === 6 ? 0 : 1) });
    res.forEach(b => findings.push({ width: 1400, ...b }));
    if (cols !== 6) findings.push({ width: 1400, kind: 'grid', detail: cols + ' columns, expected 6' });
    await shot(page, 'satchel', 'mockup4-satchel-1400.png');
    await ctx.close();
  }
  // motion
  const motion = {};
  for (const rm of ['no-preference', 'reduce']) {
    const ctx = await browser.newContext({ viewport: { width: 1400, height: 900 }, reducedMotion: rm });
    const page = await ctx.newPage(); await page.goto(URL);
    motion[rm] = await page.evaluate(() => { const s = getComputedStyle(document.querySelector('.itm--r .itm__win'), '::before'); return { spark: s.animationName, pos: s.backgroundPosition }; });
    await ctx.close();
  }
  const motionOk = motion['no-preference'].spark === 'itm-spark' && motion.reduce.spark === 'none';
  if (!motionOk) findings.push({ kind: 'motion', detail: JSON.stringify(motion) });
  const html = fs.readFileSync(path.join(HERE, 'mock.html'), 'utf8');
  const inline = (html.match(/\sstyle=|<style|<script|\son[a-z]+=/gi) || []).length;
  if (inline) findings.push({ kind: 'csp', detail: inline + ' inline style/script/handler' });
  await browser.close();

  const byKind = {};
  findings.forEach(f => { byKind[f.kind] = (byKind[f.kind] || 0) + 1; });
  fs.writeFileSync(path.join(HERE, 'overflow-check.json'), JSON.stringify({ when: new Date().toISOString(), runs, motion, inlineStyleOrScript: inline, findings }, null, 2));
  const lines = ['Item squares mockup 4: text-fit / tap / contrast / grid check (check.js)', '', 'width theme content font        text-els problems'];
  runs.forEach(r => lines.push(String(r.width).padEnd(6) + r.theme.padEnd(6) + r.content.padEnd(8) + r.font.padEnd(12) + String(r.textElements).padStart(8) + String(r.problems).padStart(9)));
  lines.push('', 'reduced motion: ' + (motionOk ? 'OK' : 'FAIL') + ' ' + JSON.stringify(motion), 'inline style/script in mock.html: ' + inline, '',
    'findings: ' + findings.length + (findings.length ? ' ' + JSON.stringify(byKind) : ' (none)'));
  findings.slice(0, 120).forEach(f => lines.push(`  [${f.kind}] ${f.width || ''} ${f.theme || ''} ${f.content || ''} ${f.font || ''} ${f.screen || ''}: ${f.el || ''} ${f.detail}`));
  fs.writeFileSync(path.join(HERE, 'overflow-check.txt'), lines.join('\n') + '\n');
  console.log(lines.slice(0, 40).join('\n'));
  console.log(lines.slice(40).join('\n'));
})();
