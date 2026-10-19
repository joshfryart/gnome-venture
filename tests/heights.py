import sys, asyncio
from playwright.async_api import async_playwright
base=sys.argv[1]
pages=sys.argv[2].split()
async def main():
    async with async_playwright() as p:
        b=await p.chromium.launch()
        pg=await b.new_page(viewport={'width':360,'height':800}, is_mobile=True)
        await pg.goto(base+'/login.php'); await pg.fill('input[name=username]','sprout'); await pg.fill('input[name=password]','TestPass123!'); await pg.click('form button')
        for u in pages:
            r=await pg.goto(base+'/'+u)
            h=await pg.evaluate('document.documentElement.scrollHeight'); w=await pg.evaluate('document.documentElement.scrollWidth')
            forms=await pg.locator('main form[method=post]').count()
            print(f"{u:28s} {r.status} h={h:6d} screens={h/800:4.1f} wide={'YES' if w>392 else 'no'} postforms={forms}")
        await b.close()
asyncio.run(main())
