import sys, asyncio
from playwright.async_api import async_playwright
base=sys.argv[1]
async def main():
    async with async_playwright() as p:
        b=await p.chromium.launch()
        pg=await b.new_page(viewport={'width':390,'height':800}, is_mobile=True, has_touch=True)
        errs=[]; pg.on('pageerror', lambda e: errs.append(str(e)))
        dialogs=[]
        def ond(d): dialogs.append(d.message); asyncio.ensure_future(d.accept())
        pg.on('dialog', ond)
        await pg.goto(base+'/login.php'); await pg.fill('input[name=username]','sprout'); await pg.fill('input[name=password]','TestPass123!'); await pg.click('form button')
        await pg.goto(base+'/world.php'); await pg.evaluate('window.__m = 1')
        await pg.locator('a[href="#worldmap"]').click(); await pg.wait_for_timeout(700)
        print('fast travel opens map:', await pg.evaluate("document.getElementById('worldmap').open"), 'no reload:', await pg.evaluate('window.__m === 1'))
        await pg.locator('main nav.tabs a').nth(1).click(); await pg.wait_for_timeout(1200)
        print('markets tab in place:', await pg.evaluate('window.__m === 1'), pg.url.replace(base,''))
        await pg.go_back(); await pg.wait_for_timeout(1500); print('back:', pg.url.replace(base,''), 'here card:', await pg.locator('.youare').count())
        # a data-confirm form: garden expand or garden building
        await pg.goto(base+'/garden.php')
        f = pg.locator('main form[data-confirm]')
        print('confirm forms on garden:', await f.count())
        if await f.count():
            await pg.evaluate("document.querySelectorAll('main details').forEach(d => d.open = true)")
            await f.first.locator('button').click(); await pg.wait_for_timeout(1500)
            print('dialogs shown for one click:', len(dialogs), dialogs[:1])
        await pg.goto(base+'/yard.php'); await pg.wait_for_timeout(800)
        print('yard pieces:', await pg.locator('[data-yard-edit] [data-k]').count(), 'tray:', await pg.locator('[data-tray] .trayitem').count())
        print('js errors:', errs)
        await b.close()
asyncio.run(main())
