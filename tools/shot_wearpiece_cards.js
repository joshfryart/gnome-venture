// node tools/shot_wearpiece_cards.js BASE SHOP_ID OUTDIR : the wearable puzzle piece card on an outfitter's item sheet, in a real browser (playwright).
// Player sprout (walk.sh install), logged in by this script. For light and dark, phone portrait (412 x 915) and the landscape dock (844 x 390):
// opens the first wearable's sheet, checks the caption under the card (piece name, type and number as text, inside the sheet, no sideways scroll,
// readable contrast) and writes OUTDIR/wearpiece-<theme>-<portrait|landscape>.png. Prints "  ok   ..." / "  FAIL ..." lines.
const { chromium } = require('playwright');
const [B, SHOP, OUT] = process.argv.slice(2);
const out = []; const ok = (name, cond, extra) => out.push((cond ? '  ok   ' : '  FAIL ') + name + (cond ? '' : '  ' + (extra || '')));
(async () => {
  const br = await chromium.launch({ args: ['--no-sandbox'] }).catch(() => chromium.launch());
  for (const theme of ['light', 'dark']) for (const [tag, vp] of [['portrait', { width: 412, height: 915 }], ['landscape', { width: 844, height: 390 }]]) {
    const c = await br.newContext({ viewport: vp, colorScheme: theme, hasTouch: true }); const p = await c.newPage(); const errs = [];
    p.on('pageerror', e => errs.push(String(e)));
    await p.goto(B + '/login.php'); await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
    await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
    await p.goto(B + '/shop.php?id=' + SHOP);
    await p.evaluate(t => { document.documentElement.dataset.theme = t; document.documentElement.dataset.pref = t; }, theme);
    const tile = p.locator('.stile:has(.spiece) .spick').first();
    await tile.click(); await p.waitForTimeout(300);
    const r = await p.evaluate(() => {
      const d = [...document.querySelectorAll('dialog.isheet')].find(x => x.open); if (!d) return null;
      const f = d.querySelector('.spiece'); f.scrollIntoView({ block: 'center' });
      const cap = f.querySelector('figcaption'), img = f.querySelector('img'), n = cap.querySelector('.spn'), v = cap.querySelector('.spv');
      const lum = s => { const m = s.match(/[\d.]+/g).map(Number); const l = m.slice(0, 3).map(x => { x /= 255; return x <= .03928 ? x / 12.92 : ((x + .055) / 1.055) ** 2.4; }); return .2126 * l[0] + .7152 * l[1] + .0722 * l[2]; };
      let el = cap, bg = 'rgba(0, 0, 0, 0)'; while (el && /rgba\(0, 0, 0, 0\)|transparent/.test(bg)) { bg = getComputedStyle(el).backgroundColor; el = el.parentElement; }
      const a = lum(getComputedStyle(n).color), b = lum(bg); const ratio = (Math.max(a, b) + .05) / (Math.min(a, b) + .05);
      const cr = cap.getBoundingClientRect(), dr = d.getBoundingClientRect(), ir = img.getBoundingClientRect();
      return { name: n.textContent, val: v.textContent, ratio: Math.round(ratio * 10) / 10, inside: cr.left >= dr.left - 1 && cr.right <= dr.right + 1, below: cr.top >= ir.bottom - 1,
        imgW: Math.round(ir.width), wide: document.documentElement.scrollWidth <= innerWidth + 1, size: parseFloat(getComputedStyle(n).fontSize) };
    });
    const k = theme + ' ' + tag;
    ok(k + ': a wearable sheet opens with its piece card', !!r);
    if (r) {
      ok(k + ': caption reads "' + r.name + '" / "' + r.val + '"', r.name.length > 1 && /^[A-Z][a-z]+ \d+$/.test(r.val), JSON.stringify(r));
      ok(k + ': caption under the card, inside the sheet', r.below && r.inside, JSON.stringify(r));
      ok(k + ': card at 132 px, no sideways scroll', r.imgW === 132 && r.wide, JSON.stringify(r));
      ok(k + ': name contrast ' + r.ratio + ':1 (>= 4.5), ' + r.size + ' px', r.ratio >= 4.5 && r.size >= 12, JSON.stringify(r));
    }
    ok(k + ': no script errors', errs.length === 0, errs.join(' | '));
    if (OUT) await p.screenshot({ path: OUT + '/wearpiece-' + theme + '-' + tag + '.png' });
    await c.close();
  }
  await br.close();
  console.log(out.join('\n'));
  process.exit(out.some(l => l.startsWith('  FAIL')) ? 1 : 0);
})();
