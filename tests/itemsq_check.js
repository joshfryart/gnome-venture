// v2.0.67: item squares on the REAL pages at 390 px, light and dark (called by tests/itemsq.sh; mockup4/check.js did the same on the mockup).
// node itemsq_check.js BASE SHOP_ID CURIO_SHOP_ID CSS_ITEMS_FILE [SHOT_DIR]
// Per page: every square is at least 44 x 44, no text pokes out of its square / ribbon / chip, no sideways page scroll, every picture loads,
// item names wrap on at most 3 lines (2 by design: more is reported as a note), the grid has 3 columns, the sparkle stands still under reduced motion.
// Satchel: tapping a square opens its card inside the screen. Shop Buy: Add to basket marks the tile and fills "N in basket".
// If style.css does not carry the .itm rules yet (claude/build/css-items.css not merged), the file is appended to the served style.css.
// Wave 2 (env, each optional): ISQ_CSS2 = claude/build/css-items2.css (appended the same way when style.css lacks it), ISQ_NPC = a villager on duty
// (gift picker), ISQ_SPOT = the hub's green (bird-seed picker), ISQ_MARKET = 1 when it is market day (basket picks). Pages: crafting Ready + Missing,
// the gift picker (open, pick one: aria-pressed + Give it), the garden seed picker (select a square, open, tap a seed: count + steps) and soil picker,
// the town bird-seed picker, the market-day basket (tick one: picked). Their step buttons must be 44 x 44 too.
const { chromium } = require('playwright');
const fs = require('fs');
(async () => {
  const [base, shop, curio, cssFile, shots] = process.argv.slice(2);
  const extra = cssFile && fs.existsSync(cssFile) ? fs.readFileSync(cssFile, 'utf8') : '';
  const css2 = process.env.ISQ_CSS2, extra2 = css2 && fs.existsSync(css2) ? fs.readFileSync(css2, 'utf8') : '';
  const NPC = process.env.ISQ_NPC || '', SPOT = process.env.ISQ_SPOT || '', MARKET = process.env.ISQ_MARKET === '1';
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--no-sandbox'] }).catch(() => chromium.launch({ args: ['--no-sandbox'] }));
  let fails = 0;
  const say = (ok, msg) => { if (!ok) fails++; console.log((ok ? 'ok   ' : 'FAIL ') + msg); };
  const pages = [['satchel', '/inventory.php'], ['shop-buy', '/shop.php?id=' + shop], ['shop-sell', '/shop.php?id=' + shop + '&tab=sell'], ['curio', '/shop.php?id=' + curio],
    ['craft', '/inventory.php?tab=craft&c=cooking&show=ready'], ['craft-missing', '/inventory.php?tab=craft&c=cooking&show=missing']];
  if (NPC) pages.push(['gift', '/villagers.php?id=' + NPC]);
  pages.push(['garden-seed', '/garden.php'], ['garden-soil', '/garden.php']);
  if (SPOT) pages.push(['town-seed', '/town.php?hub=1&spot=' + SPOT]);
  if (MARKET) pages.push(['basket', '/marketday.php']);
  // wave 2: open the picker (and pick one) before measuring; returns a note on what happened
  const garden = async (p, kind) => {
    await p.click('.selbar [data-sel="on"]');
    await p.locator('#yard a.tile').first().click();
    await p.click('.selbar [data-open="' + kind + '"]');
    await p.locator('dialog.picker[data-kind="' + kind + '"][open] .itm').first().click();
    return p.evaluate(() => { const c = document.querySelector('dialog.picker[open] .itm'); const n = c.querySelector('.pccount');
      return { pressed: c.getAttribute('aria-pressed'), count: n && !n.hidden ? n.textContent : '', steps: !!c.querySelector('.pcbtns:not([hidden])'), go: !document.querySelector('dialog.picker[open] [data-go]').disabled }; });
  };
  const prep = {
    gift: async p => {
      await p.click('[data-giftopen]');
      await p.locator('dialog.giftpick[open] .itm').first().click();
      return p.evaluate(() => { const d = document.querySelector('dialog.giftpick[open]'); const c = d.querySelector('.itm');
        return { pressed: c.getAttribute('aria-pressed'), others: d.querySelectorAll('.itm[aria-pressed="true"]').length, give: !d.querySelector('.giftgo').hidden, says: d.querySelector('.gname').textContent }; });
    },
    'garden-seed': p => garden(p, 'seed'),
    'garden-soil': p => garden(p, 'soil'),
    'town-seed': async p => { await p.evaluate(() => { const d = document.querySelector('dialog.townpick[data-kind="anyseed"]'); if (d) d.showModal(); }); return p.evaluate(() => !!document.querySelector('dialog.townpick[open]')); },
    basket: async p => { const l = p.locator('main label.mkopt').first(); await l.click();
      return p.evaluate(() => { const l = document.querySelector('main label.mkopt'); const sq = l.querySelector('.itm'); return { checked: l.querySelector('input').checked, halo: getComputedStyle(sq).boxShadow !== 'none' }; }); },
  };
  const want = {
    gift: r => r && r.pressed === 'true' && r.others === 1 && r.give && /^Give .+\?$/.test(r.says),
    'garden-seed': r => r && r.pressed === 'true' && r.count !== '' && r.steps && r.go,
    'garden-soil': r => r && r.pressed === 'true' && r.go,
    'town-seed': r => r === true,
    basket: r => r && r.checked && r.halo,
  };
  for (const theme of ['light', 'dark']) {
    for (const motion of theme === 'light' ? ['no-preference', 'reduce'] : ['no-preference']) {
      const c = await b.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 1, colorScheme: theme, reducedMotion: motion });
      await c.route(/\/assets\/style\.css/, async route => {
        const r = await route.fetch(); let body = await r.text();
        if (!body.includes('.itm__win') && extra) body += '\n' + extra;
        if (!body.includes('label.itmcell') && extra2) body += '\n' + extra2;
        await route.fulfill({ response: r, body, headers: { ...r.headers(), 'content-type': 'text/css' } });
      });
      const p = await c.newPage();
      const errs = [];
      p.on('pageerror', e => errs.push(String(e)));
      await p.goto(base + '/login.php');
      await p.fill('input[name=username]', 'sprout'); await p.fill('input[name=password]', 'TestPass123!');
      await Promise.all([p.waitForNavigation(), p.press('input[name=password]', 'Enter')]);
      for (const [key, url] of pages) {
        const tag = `${key} ${theme}${motion === 'reduce' ? ' reduced-motion' : ''}`;
        await p.goto(base + url, { waitUntil: 'networkidle' });
        await p.evaluate(t => { document.documentElement.setAttribute('data-pref', t); document.documentElement.setAttribute('data-theme', t); }, theme);   // the player's saved theme would win otherwise
        if (motion === 'reduce') {
          const still = await p.evaluate(() => { const w = document.querySelector('.itm--r .itm__win, .itm--l .itm__win'); return w ? getComputedStyle(w, '::before').animationName : 'none'; });
          say(still === 'none', `${tag}: sparkle is still (${still})`);
          continue;
        }
        if (prep[key]) {
          const got = await prep[key](p).catch(e => 'error: ' + String(e).split('\n')[0]);
          say(want[key](got), `${tag}: picker opens and picks (${JSON.stringify(got)})`);
        }
        await p.evaluate(() => document.querySelectorAll('img[loading="lazy"]').forEach(i => { i.loading = 'eager'; }));
        await p.waitForLoadState('networkidle');
        await p.waitForFunction(() => [...document.querySelectorAll('main .itm img')].every(i => i.complete), null, { timeout: 15000 }).catch(() => {});
        const r = await p.evaluate(() => {
          const out = { n: 0, small: [], escape: [], lines3: [], lines4: [], img: [], cols: [], scroll: 0, style: 0, steps: [] };
          const R = el => el.getBoundingClientRect();
          const items = [...document.querySelectorAll('main .itm')].filter(el => R(el).width > 0);
          out.n = items.length;
          out.scroll = document.scrollingElement.scrollWidth - window.innerWidth;
          out.style = document.querySelectorAll('main [style]').length;
          for (const it of items) {
            const k = R(it), name = it.querySelector('.itm__name').textContent;
            if (k.width < 44 || k.height < 44) out.small.push(name + ' ' + k.width.toFixed(0) + 'x' + k.height.toFixed(0));
            const nm = it.querySelector('.itm__name'), lh = parseFloat(getComputedStyle(nm).lineHeight), lines = Math.round(R(nm).height / lh);
            if (lines > 3 || nm.scrollHeight > nm.clientHeight + 1) out.lines4.push(name + ' ' + lines); else if (lines > 2) out.lines3.push(name);
            const rib = it.querySelector('.itm__rib'), rr = R(rib), rs = getComputedStyle(rib);
            const box = { l: rr.left + parseFloat(rs.borderLeftWidth) - .5, r: rr.right - parseFloat(rs.borderRightWidth) + .5 };
            const nr = R(nm); if (nr.left < box.l || nr.right > box.r) out.escape.push(name + ': name outside its ribbon');
            for (const ch of it.querySelectorAll('.itm__foot > :not(.vh)')) {
              const cr = R(ch); if (!cr.width) continue;
              if (cr.left < k.left - .5 || cr.right > k.right + .5) out.escape.push(name + ': chip "' + ch.textContent.trim() + '" outside the square');
              if (ch.scrollWidth > ch.clientWidth + 1) out.escape.push(name + ': chip "' + ch.textContent.trim() + '" overflows');
            }
            for (const im of it.querySelectorAll('img')) if (!im.complete || !im.naturalWidth) out.img.push(im.getAttribute('src'));
            for (const b of it.querySelectorAll('[role="button"]')) { const br = R(b); if (br.width && (br.width < 44 || br.height < 44)) out.steps.push(name + ' ' + b.textContent + ' ' + br.width.toFixed(0) + 'x' + br.height.toFixed(0)); }
          }
          for (const g of document.querySelectorAll('main .itms')) if (R(g).width > 0) out.cols.push(getComputedStyle(g).gridTemplateColumns.split(' ').length);
          return out;
        });
        say(r.n > 0, `${tag}: ${r.n} item squares`);
        say(!r.small.length, `${tag}: every square is 44 x 44 or more${r.small.length ? ' (' + r.small.slice(0, 4).join(', ') + ')' : ''}`);
        say(!r.escape.length, `${tag}: no text pokes out${r.escape.length ? ' (' + r.escape.slice(0, 4).join('; ') + ')' : ''}`);
        say(!r.lines4.length, `${tag}: names never cut${r.lines4.length ? ' (' + r.lines4.slice(0, 4).join(', ') + ')' : ''}`);
        if (r.lines3.length) console.log(`note ${tag}: 3-line names: ${r.lines3.join(', ')}`);
        say(r.scroll <= 0, `${tag}: no sideways scroll (${r.scroll})`);
        say(!r.img.length, `${tag}: pictures load${r.img.length ? ' (' + r.img.slice(0, 3).join(' ') + ')' : ''}`);
        say(r.cols.every(n => n === 3), `${tag}: 3 columns (${r.cols.join(',')})`);
        say(r.style === 0, `${tag}: no style= attribute in main`);
        say(!r.steps.length, `${tag}: step buttons 44 x 44 or more${r.steps.length ? ' (' + r.steps.join(', ') + ')' : ''}`);
        if (key === 'satchel') {
          const sum = p.locator('main details.itmcell > summary.itm').first();
          await sum.click();
          const pop = await p.evaluate(() => { const d = document.querySelector('main details.itmcell[open]'); if (!d) return null; const r = d.querySelector('.ipop').getBoundingClientRect(); return { l: r.left, r: r.right, t: r.top, b: r.bottom, w: innerWidth, h: innerHeight }; });
          say(pop && pop.l >= 0 && pop.r <= pop.w && pop.t >= 0 && pop.b <= pop.h, `${tag}: tapped square opens its card on screen ${JSON.stringify(pop)}`);
          if (shots) await p.screenshot({ path: `${shots}/satchel-open-390-${theme}.png` });
          await p.keyboard.press('Escape'); await sum.click();
        }
        if (key === 'shop-buy') {
          const tile = p.locator('main .stile:has(.sadd) > .itm').first();
          if (await tile.count()) {
            await tile.click();
            await p.locator('dialog.isheet[open] .sadd').click();
            const st = await p.evaluate(() => { const t = document.querySelector('main .stile.sel'); const bk = document.querySelector('main form.basket'); return { sel: !!t, inb: t ? t.querySelector('.itm__inb').textContent : '', bar: bk && !bk.hidden }; });
            say(st.sel && st.inb === '1 in basket' && st.bar, `${tag}: Add to basket marks the tile (${st.inb}) and shows the bar`);
          } else say(false, `${tag}: no tile with Add to basket`);
        }
        if (shots) {   // one phone screen with the first grid near the top (a full-page shot repeats the sticky header mid-page)
          await p.evaluate(k => { if (document.querySelector('dialog[open]')) return;   // an open picker is the screen
            const g = document.querySelector(k === 'curio' ? '#curios' : k.startsWith('craft') ? 'main .ccard' : k === 'basket' ? 'main .mkpick' : 'main .itms');
            if (g) window.scrollTo(0, g.getBoundingClientRect().top + scrollY - (k === 'shop-buy' ? 330 : 150)); }, key);
          await p.waitForTimeout(150);
          await p.screenshot({ path: `${shots}/${key}-390-${theme}.png` });
        }
      }
      say(!errs.length, `${theme}: no page errors${errs.length ? ' (' + errs.join(' | ') + ')' : ''}`);
      await c.close();
    }
  }
  await b.close();
  console.log(fails ? `${fails} FAILED` : 'all item-square checks ok');
})();
