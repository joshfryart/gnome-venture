// Mockup 3 (town / main stop) checks + screenshots. Usage: node claude/art-variants/mockup3/check.js
// A copy of mockup2/check.js with the town screens. Runs every phone width (360/390/430) x theme (light/dark)
// x content (real copy / longest real copy) x font (system-ui = Inter here / DejaVu Sans, a wider face) and checks,
// for every text element inside a phone:
//   overflow   scrollWidth > clientWidth (text wider than its box)
//   truncated  an ellipsis or line-clamp actually cut text
//   escape     the text box pokes outside its container (sign / card / tab / summary / phone)
//   overlap    two text boxes intersect
//   tap        a link or button smaller than 44 x 44 (inline links inside a sentence, .inl, are exempt: WCAG 2.5.8 inline exception)
//   contrast   text vs its (composited) background below 4.5:1 (3:1 for large); felt and signs use the art's base colour
//   images     an <img> that failed to load
//   tabs       the five tabs are not on one row, or a tab label wrapped
// Also: no inline style / script / handler in mock.html.
// Writes overflow-check.json and overflow-check.txt, plus the screenshots named in the task.
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const HERE = __dirname;
const URL = 'file://' + path.join(HERE, 'mock.html');
const WIDTHS = [360, 390, 430];

// longest real strings (game/includes: town.php TOWN_FLAVOUR, data/towns.txt, catalog.php SEED_SHOP_NAMES + staff names,
// flowers.php / seed.php / sinks.php staff, data/crops.txt + flowers.txt names, market100.php npc_order() texts)
const STRESS = {
  town: 'The Sunsprinkle Isles',
  placeNames: ['The Lumberjack’s Kettle', 'The Storyteller’s Tree', 'The Waterhole Lookout', 'The Pōhutukawa Green', 'The Drizzle & Crumpet', 'The Bamboo Teahouse'],
  chips: ['🔒 Only open in December, January, February, March.', '12 things to do', '✔️ all done today', '🚧 closed for repairs', 'Have a look', '🔒 Open 6 pm to 11 pm (Hollow time).'],
  folk: '<span aria-hidden="true">🦗🦋🐢</span> 🧑‍🌾 12 gnomes here',
  stats: ['12', '14', '12'],
  statLabels: ['things left to do today', 'places open', 'orders on the board'],
  more: ['🧑‍🌾 12 gnomes about', '🧺 Market day: stalls are up!'],
  trav: 'Tobias Trundle',
  bdayName: 'Marigold Tuftwhistle',
  vNames: ['Marigold Tuftwhistle', 'Petalpin Greenfinger', 'Madder Quillfeather'],
  vSubs: [['generous field mouse · traveller', '📍 🔭 The Waterhole Lookout · 💛 Acquaintance'], ['chatty grasshopper', '📍 📖 The Storyteller’s Tree · 💛 Best friend'], ['proud hedgehog', '🏡 The Sunsprinkle Isles Market · 💛 Good friend']],
  shopNames: ['Blossom Seed Parlour', 'Thornacre Seed Shed', 'Twigg\'s Seed Emporium', 'Rainroot Seed Store', 'Olive Whistle Seeds', 'Canopy Seed Nook'],
  staff: 'At the counter: Marigold Tuftwhistle, Petalpin Greenfinger',
  orderTexts: ['Could you hang and dry 6 × Night-flowering Jasmine for me? I need 6 × Dried Night-flowering Jasmine.', 'Could you bring me 6 × Prickly Pear Cactus, grade A+ (quality 75+)?', 'We are hungry: 4 × Goat Cheese and Quail Egg Tart, please.'],
  orderBar: 'grade A+ (quality 75+)',
  reward: 'Reward: 1,240 Petals, 24 XP, +15 friendship, 🎁 Night-flowering Jasmine Cutting · you have 12 (grade S, 92) · Yours are grade A+ (quality 88+): not good enough.',
};

function applyStress(S) {
  const set = (sel, vals) => document.querySelectorAll(sel).forEach((el, i) => { el.textContent = vals[i % vals.length]; });
  set('.dohead__name', [S.town]);
  set('.pcard .gcard__label', S.placeNames);
  set('.pchip', S.chips);
  document.querySelectorAll('.pfolk').forEach(el => { el.innerHTML = S.folk; });
  set('.tday__n', S.stats); set('.tday__l', S.statLabels); set('.tday__chip', S.more);
  set('.tday__rowt b', [S.trav]); set('.tnote .inl', [S.bdayName]);
  document.querySelectorAll('.mtabs__badge').forEach(b => { b.textContent = '12'; });
  set('.vcard .vcard__name', S.vNames);
  document.querySelectorAll('.vcard').forEach((v, i) => { const subs = v.querySelectorAll('.vcard__sub'); S.vSubs[i % S.vSubs.length].forEach((t, k) => { if (subs[k]) subs[k].textContent = t; }); });
  set('.scard__name', S.shopNames); set('.scard__staff', [S.staff]);
  set('.ocard .vcard__name', S.vNames);
  set('.ocard__q', S.orderTexts.map(t => '“' + t + '”'));
  document.querySelectorAll('.ocard__tags').forEach(p => { const t = p.querySelectorAll('.otag'); if (t[1]) t[1].textContent = S.orderBar; });
  set('.ocard__rw', [S.reward]);
}

function audit() {
  const out = [];
  const hex = c => { const m = c.match(/rgba?\(([^)]+)\)/); if (!m) return null; const p = m[1].split(/[ ,/]+/).filter(Boolean).map(Number); return { r: p[0], g: p[1], b: p[2], a: p.length > 3 ? p[3] : 1 }; };
  const parseHex = h => ({ r: parseInt(h.slice(1, 3), 16), g: parseInt(h.slice(3, 5), 16), b: parseInt(h.slice(5, 7), 16), a: 1 });
  const lum = c => { const f = v => { v /= 255; return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); }; return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b); };
  const ratio = (a, b) => { const x = lum(a), y = lum(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); };
  const over = (top, bot) => ({ r: top.r * top.a + bot.r * (1 - top.a), g: top.g * top.a + bot.g * (1 - top.a), b: top.b * top.a + bot.b * (1 - top.a), a: 1 });
  // base colours of the art (mockup2/gather_b.py FELT / SIGN; mockup3/town_art.py felt-gold has the idle base)
  const FELT = { idle: '#c9a46a', off: '#bdb6a6', gold: '#c9a46a' }, SIGN = { idle: '#8e3c2a', sel: '#e0aa48', off: '#d6d0c2' };
  const FELTED = '.gcard, .vcard, .scard, .ocard, .tday';
  const RIB = '.gcard__ribbon, .vcard__ribbon, .scard__ribbon';
  const offCard = card => card.matches('.is-done, .is-closed, .is-repair, :disabled, [aria-disabled="true"]');
  const feltOf = card => card.matches('.tday') ? 'gold' : offCard(card) ? 'off' : 'idle';
  const signOf = card => card.matches('.pcard--gold') ? 'sel' : offCard(card) ? 'off' : 'idle';
  const bgOf = el => {
    const layers = [];
    for (let n = el; n && n.nodeType === 1; n = n.parentElement) {
      if (n.matches(RIB)) { layers.push(parseHex(SIGN[signOf(n.closest(FELTED))])); break; }
      if (n.matches(FELTED)) { layers.push(parseHex(FELT[feltOf(n)])); break; }
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
      // containment: inside the sign's content box (2 px slack for the notch), else the card / tab / summary / phone
      const rib = el.closest(RIB);
      const cont = rib || el.closest('.gcard, .vcard, .scard, .ocard, .tday, .mtabs__a, .dohead__plate, .gbtn, .fbtn, .tnote') || ph;
      let cr = R(cont);
      if (rib) { const s = getComputedStyle(rib); cr = { left: cr.left + parseFloat(s.borderLeftWidth), right: cr.right - parseFloat(s.borderRightWidth), top: cr.top + parseFloat(s.borderTopWidth) - 2, bottom: cr.bottom - parseFloat(s.borderBottomWidth) + 2 }; }
      if (el.closest('.gcard__flag')) cr = R(el.closest('.gcard'));
      const t = 0.5;
      if (!el.closest('.gcard__flag') && (r.left < cr.left - t || r.right > cr.right + t || r.top < cr.top - t || r.bottom > cr.bottom + t)) out.push({ screen, kind: 'escape', el: label(el), detail: 'outside ' + label(cont).split(' "')[0] });
      if (r.left < pr.left - t || r.right > pr.right + t) out.push({ screen, kind: 'escape', el: label(el), detail: 'outside the phone' });
      const fg = hex(cs.color), bg = bgOf(el);
      if (fg && bg) { const k = ratio(fg, bg); const big = parseFloat(cs.fontSize) >= 24 || (parseFloat(cs.fontSize) >= 18.66 && +cs.fontWeight >= 700); if (k < (big ? 3 : 4.5)) out.push({ screen, kind: 'contrast', el: label(el), detail: k.toFixed(2) + ':1 on ' + JSON.stringify(bg) }); }
    }
    for (let i = 0; i < texts.length; i++) for (let j = i + 1; j < texts.length; j++) {
      const a = texts[i], b = texts[j];
      if (a.contains(b) || b.contains(a)) continue;
      const p = R(a), q = R(b);
      const ix = Math.min(p.right, q.right) - Math.max(p.left, q.left), iy = Math.min(p.bottom, q.bottom) - Math.max(p.top, q.top);
      if (ix > 1 && iy > 1) out.push({ screen, kind: 'overlap', el: label(a), detail: 'with ' + label(b) });
    }
    for (const el of ph.querySelectorAll('button, a, [role=button]')) { if (el.matches('.inl')) continue; const r = R(el); if (r.width < 44 || r.height < 44) out.push({ screen, kind: 'tap', el: label(el), detail: r.width.toFixed(1) + ' x ' + r.height.toFixed(1) }); }
    for (const im of ph.querySelectorAll('img')) if (!im.complete || !im.naturalWidth) out.push({ screen, kind: 'images', el: im.getAttribute('src'), detail: 'not loaded' });
    // tabs: one row, labels on one line
    const tabs = [...ph.querySelectorAll('.mtabs__a')];
    if (tabs.length !== 5 || new Set(tabs.map(a => Math.round(R(a).top))).size !== 1) out.push({ screen, kind: 'tabs', detail: 'tabs not on one row' });
    for (const t of ph.querySelectorAll('.mtabs__t')) { const lh = parseFloat(getComputedStyle(t).lineHeight); if (R(t).height > lh * 1.5) out.push({ screen, kind: 'tabs', el: label(t), detail: 'label wrapped' }); }
    out.push({ screen, kind: '_count', detail: texts.length });
  }
  return out;
}

(async () => {
  const browser = await chromium.launch();
  const runs = [], findings = [];
  const shots = { square: 's-square', villagers: 's-villagers', shops: 's-shops', orders: 's-orders' };
  for (const theme of ['light', 'dark']) for (const content of ['real', 'stress']) for (const font of ['system-ui', 'wide']) for (const w of WIDTHS) {
    const ctx = await browser.newContext({ viewport: { width: w * 5 + 5 * 24 + 48, height: 900 }, reducedMotion: 'reduce', deviceScaleFactor: 1 });
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
    const shot = async (id, name) => page.locator('#' + id + ' .ph').screenshot({ path: path.join(HERE, name) });
    if (content === 'real' && font === 'system-ui' && theme === 'light' && w === 390) for (const [k, id] of Object.entries(shots)) await shot(id, `mockup3-${k}-390.png`);
    if (content === 'real' && font === 'system-ui' && theme === 'light' && w === 390) await shot('s-square2', 'mockup3-square-states-390.png');
    if (content === 'real' && font === 'system-ui' && theme === 'light' && w === 360) await shot('s-square', 'mockup3-square-360.png');
    if (content === 'real' && font === 'system-ui' && theme === 'dark' && w === 390) await shot('s-square', 'mockup3-square-dark.png');
    if (content === 'stress' && font === 'wide' && theme === 'light' && w === 360) await page.screenshot({ path: path.join(HERE, 'mockup3-stress-360.png'), fullPage: true });
    await ctx.close();
  }
  const html = fs.readFileSync(path.join(HERE, 'mock.html'), 'utf8');
  const inline = (html.match(/\sstyle=|<style|<script|\son[a-z]+=/gi) || []).length;
  if (inline) findings.push({ kind: 'csp', detail: inline + ' inline style/script/handler' });
  await browser.close();

  const byKind = {};
  findings.forEach(f => { byKind[f.kind] = (byKind[f.kind] || 0) + 1; });
  fs.writeFileSync(path.join(HERE, 'overflow-check.json'), JSON.stringify({ when: new Date().toISOString(), runs, inlineStyleOrScript: inline, findings }, null, 2));
  const lines = ['Town mockup 3: text-fit / tabs / tap / contrast check (check.js)', '',
    'width theme content font        text-els problems'];
  runs.forEach(r => lines.push(String(r.width).padEnd(6) + r.theme.padEnd(6) + r.content.padEnd(8) + r.font.padEnd(12) + String(r.textElements).padStart(8) + String(r.problems).padStart(9)));
  lines.push('', 'inline style/script in mock.html: ' + inline, '', 'findings: ' + findings.length + (findings.length ? ' ' + JSON.stringify(byKind) : ' (none)'));
  findings.slice(0, 80).forEach(f => lines.push(`  [${f.kind}] ${f.width || ''} ${f.theme || ''} ${f.content || ''} ${f.font || ''} ${f.screen || ''}: ${f.el || ''} ${f.detail}`));
  fs.writeFileSync(path.join(HERE, 'overflow-check.txt'), lines.join('\n') + '\n');
  console.log(lines.join('\n'));
})();
