import sys, asyncio
from playwright.async_api import async_playwright
base=sys.argv[1]
async def main():
    async with async_playwright() as p:
        b=await p.chromium.launch()
        pg=await b.new_page(viewport={'width':390,'height':800}, is_mobile=True, has_touch=True)
        errs=[]; pg.on('pageerror', lambda e: errs.append(str(e)))
        pg.on('dialog', lambda d: asyncio.ensure_future(d.accept()))
        await pg.goto(base+'/login.php'); await pg.fill('input[name=username]','sprout'); await pg.fill('input[name=password]','TestPass123!'); await pg.click('form button')
        async def check(name):
            ok = await pg.evaluate('window.__m === 1')
            msg = await pg.locator('.toasts, main .flash').first.inner_text() if await pg.locator('.toasts, main .flash').count() else ''
            print(f'{name:34s} in-place={ok} url={pg.url.replace(base,"")} msg={msg[:70]!r}')
        # shop buy
        await pg.goto(base+'/shop.php?id=1'); await pg.evaluate('window.__m = 1'); await pg.evaluate('scrollTo(0, 600)')
        await pg.locator('main form.sbuy button').first.click(); await pg.wait_for_timeout(1200); await check('shop buy')
        print('   scroll kept', await pg.evaluate('scrollY'))
        # satchel eat
        await pg.goto(base+'/inventory.php'); await pg.evaluate('window.__m = 1')
        eat = pg.locator('main form input[value=eat]')
        if await eat.count():
            await pg.evaluate("(() => { const i = document.querySelector('main form input[value=eat]'); const d = i.closest('details'); d.open = true; })()")
            await eat.first.locator('xpath=..').locator('button').click(); await pg.wait_for_timeout(1200); await check('satchel eat')
        # jobs tab
        await pg.goto(base+'/jobs.php'); await pg.evaluate('window.__m = 1')
        await pg.locator('main nav.tabs a').nth(1).click(); await pg.wait_for_timeout(1200); await check('jobs tab')
        await pg.go_back(); await pg.wait_for_timeout(1500); print('   back ->', pg.url.replace(base,''))
        # crafting tab
        await pg.goto(base+'/crafting.php'); await pg.evaluate('window.__m = 1')
        await pg.locator('main nav.tabs a').nth(1).click(); await pg.wait_for_timeout(1200); await check('crafting tab')
        # world
        await pg.goto(base+'/world.php'); await pg.evaluate('window.__m = 1')
        await pg.screenshot(path='w47-world.png', full_page=True)
        await pg.locator('a[href="#worldmap"]').click(); await pg.wait_for_timeout(500)
        print('   map fold open:', await pg.evaluate("document.getElementById('worldmap').open"))
        await pg.locator('main nav.tabs a').nth(1).click(); await pg.wait_for_timeout(1200); await check('world markets tab')
        # world: go along a road
        await pg.goto(base+'/world.php')
        await pg.locator('button.gocard').first.click(); await pg.wait_for_timeout(1500)
        print('   go ->', pg.url.replace(base,''))
        print('js errors:', errs)
        await b.close()
asyncio.run(main())
