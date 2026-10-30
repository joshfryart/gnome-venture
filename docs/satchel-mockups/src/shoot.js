const { chromium } = require('playwright');
const BASE='http://127.0.0.1:8962'; const [,, path, out, mode, click] = process.argv;
(async()=>{ const b=await chromium.launch();
 const mob = mode!=='d';
 const c=await b.newContext(mob?{viewport:{width:390,height:844},deviceScaleFactor:2,isMobile:true,hasTouch:true,bypassCSP:true}:{viewport:{width:1440,height:900},deviceScaleFactor:1,bypassCSP:true});
 const p=await c.newPage(); const errs=[]; p.on('console',m=>{if(m.type()==='error')errs.push(m.text())}); p.on('pageerror',e=>errs.push(String(e)));
 await p.goto(BASE+'/login.php'); await p.fill('[name=username]','sprout'); await p.fill('[name=password]','TestPass123!'); await p.click('main button.btn'); await p.waitForLoadState();
 await p.goto(BASE+path); await p.waitForTimeout(500);
 if(await p.evaluate(()=>document.documentElement.dataset.theme)!=='dark'){ await p.evaluate(()=>{try{document.querySelector('button.th-to-dark').click()}catch(e){}}); await p.waitForTimeout(800); await p.goto(BASE+path); await p.waitForTimeout(500);}
 await p.addStyleTag({path:'/tmp/pt/sm/notoast.css'}).catch(()=>{});
 if(click){ await p.click(click); await p.waitForTimeout(400); }
 const info=await p.evaluate(()=>{const de=document.documentElement; const small=[];
   document.querySelectorAll('.sm a, .sm button, .sm select, .sm input:not([type=hidden]), .sm summary').forEach(el=>{const r=el.getBoundingClientRect(); if(r.width&&r.height&&(r.height<40||r.width<40)&&getComputedStyle(el).visibility!=='hidden') small.push(el.tagName+'.'+el.className+' '+(el.textContent||'').trim().slice(0,16)+' '+Math.round(r.width)+'x'+Math.round(r.height))});
   const wide=[...document.querySelectorAll('body *')].filter(e=>{const r=e.getBoundingClientRect(); return r.width && r.right>de.clientWidth+1 && !e.closest('.chips,.smscroll,[class*=row]')}).slice(0,5).map(e=>e.tagName+'.'+e.className);
   return {sw:de.scrollWidth,cw:de.clientWidth,sh:de.scrollHeight,small:[...new Set(small)].slice(0,12),wide};});
 console.log(out.split('/').pop(), JSON.stringify(info));
 if(mode==='ms') await p.screenshot({path:out}); else await p.screenshot({path:out,fullPage:true});
 if(errs.length) console.log('ERR',errs.join('\n')); await b.close();})();
