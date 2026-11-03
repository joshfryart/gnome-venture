// Polish audit (claude/plan-polish.md Phase 0): node tests/polish_audit.js BASE_URL OUT_DIR
// Logs in as the seeded demo gnome (tests/shot_seed.php + walk.sh install), visits every player page at four viewports and writes
// OUT_DIR/audit.json (one row per page x viewport) plus OUT_DIR/<viewport>/<page>.png. Checks: horizontal overflow, tap targets under 44px,
// console errors and failed requests, inline style attributes (CSP), icon-only buttons and links with no accessible name, images without alt.
const { chromium } = require('playwright');
const fs = require('fs');
const [BASE, OUT] = process.argv.slice(2);
const PAGES = [
  'index.php', 'index.php?today=1', 'gnome.php', 'gnome.php?tab=calling', 'book.php', 'inventory.php', 'inventory.php?tab=craft', 'inventory.php?tab=belt',
  'garden.php', 'yard.php', 'arrange.php', 'games.php', 'games.php?tab=contests', 'puzzles.php', 'jigsaw.php', 'gifsaw.php',
  'world.php', 'world.php?tab=map', 'world.php?tab=gather', 'world.php?tab=shops', 'world.php?tab=travel', 'town.php', 'town.php?view=passport', 'town.php?t=orders',
  'villagers.php', 'folk.php', 'market.php', 'marketday.php', 'jobs.php', 'jobs.php?t=quests', 'jobs.php?t=requests', 'community.php', 'community.php?t=jar',
  'pals.php', 'puzzlepals.php', 'paljobs.php', 'catfish.php', 'mentor.php', 'letters.php', 'festival.php', 'firstweek.php', 'gourmand.php', 'fair.php', 'show.php', 'gotm.php',
  'account.php', 'profile.php', 'feedback.php', 'guide.php', 'welcome.php', 'trek.php', 'adventure.php', 'back.php',
  'admin/index.php',
];
const VIEWS = [
  { name: 'phone-dark', w: 412, h: 915, theme: 'dark' }, { name: 'phone-light', w: 412, h: 915, theme: 'light' },
  { name: 'tablet-light', w: 768, h: 1024, theme: 'light' }, { name: 'desk-light', w: 1400, h: 900, theme: 'light' },
];
const slug = u => u.replace(/\.php/, '').replace(/[^a-z0-9]+/gi, '-').replace(/^-|-$/g, '');
const login = async p => {
  await p.goto(BASE + '/login.php');
  await p.fill('[name=username]', 'sprout'); await p.fill('[name=password]', 'TestPass123!');
  await p.click('main button.btn'); await p.waitForLoadState();
};
const setTheme = async (p, th) => {
  if ((await p.getAttribute('html', 'data-theme')) !== th) { await p.evaluate(t => { const b = document.querySelector('button.th-to-' + t); if (b) b.click(); }, th); await p.waitForTimeout(500); }
};
const measure = () => {
  const vis = el => { const r = el.getBoundingClientRect(); const cs = getComputedStyle(el); return r.width > 0 && r.height > 0 && cs.visibility !== 'hidden' && cs.display !== 'none'; };
  const desc = el => (el.tagName.toLowerCase() + (el.id ? '#' + el.id : '') + (el.className && typeof el.className === 'string' ? '.' + el.className.trim().split(/\s+/).slice(0, 2).join('.') : '')).slice(0, 60);
  const small = [...document.querySelectorAll('a[href],button,input:not([type=hidden]),select,textarea,summary')].filter(vis).filter(el => {
    const r = el.getBoundingClientRect(); return (r.width < 44 || r.height < 44) && !el.closest('p,li.inline') ; });
  const nameless = [...document.querySelectorAll('a[href],button')].filter(vis).filter(el => !(el.textContent || '').trim() && !el.getAttribute('aria-label') && !el.getAttribute('title') && !el.querySelector('img[alt]:not([alt=""])'));
  const noalt = [...document.images].filter(i => !i.hasAttribute('alt'));
  const wide = [...document.querySelectorAll('body *')].filter(vis).filter(el => el.getBoundingClientRect().right > innerWidth + 1 && !el.closest('.bottombar,.side,nav.side,.toasts'));
  return {
    overflowX: document.documentElement.scrollWidth - innerWidth,
    wideEls: [...new Set(wide.map(desc))].slice(0, 6),
    smallTargets: small.length, smallSample: [...new Set(small.map(desc))].slice(0, 6),
    nameless: nameless.length, namelessSample: [...new Set(nameless.map(desc))].slice(0, 5),
    imgNoAlt: noalt.length, inlineStyle: document.querySelectorAll('[style]').length,
    h1: document.querySelectorAll('h1').length, docH: document.documentElement.scrollHeight,
  };
};
(async () => {
  const b = await chromium.launch(); const rows = [];
  for (const v of VIEWS) {
    fs.mkdirSync(`${OUT}/${v.name}`, { recursive: true });
    const ctx = await b.newContext({ viewport: { width: v.w, height: v.h }, deviceScaleFactor: 1, bypassCSP: false });
    const p = await ctx.newPage(); await login(p);
    let errs = [];
    p.on('console', m => { if (m.type() === 'error') errs.push(m.text().slice(0, 140)); });
    p.on('pageerror', e => errs.push('pageerror ' + String(e).slice(0, 140)));
    p.on('requestfailed', r => errs.push('reqfail ' + r.url().slice(-80)));
    p.on('response', r => { if (r.status() >= 400) errs.push(r.status() + ' ' + r.url().slice(-80)); });
    await p.goto(BASE + '/index.php'); await setTheme(p, v.theme);
    for (const u of PAGES) {
      errs = [];
      let status = 0, final = u;
      try {
        const r = await p.goto(BASE + '/' + u, { waitUntil: 'load', timeout: 20000 }); status = r ? r.status() : 0;
        await p.waitForTimeout(400); final = p.url().replace(BASE + '/', '');
        await p.evaluate(() => document.querySelectorAll('.toasts,.flash').forEach(n => n.remove()));
        const m = await p.evaluate(measure);
        const th = await p.getAttribute('html', 'data-theme');
        await p.screenshot({ path: `${OUT}/${v.name}/${slug(u)}.png`, fullPage: false });
        rows.push({ view: v.name, page: u, final: final === u ? '' : final, status, theme: th, ...m, errors: errs.slice(0, 4) });
      } catch (e) { rows.push({ view: v.name, page: u, status, error: String(e).slice(0, 120) }); }
    }
    await ctx.close();
  }
  await b.close();
  fs.writeFileSync(OUT + '/audit.json', JSON.stringify(rows, null, 1));
  console.log('rows', rows.length);
})().catch(e => { console.error('audit failed:', e.message); process.exit(1); });
