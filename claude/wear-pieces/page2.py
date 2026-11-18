#!/usr/bin/env python3
import json, base64, glob, html, os
ORDER=['NA','CA','NWE','CB','SE','SA','EE','MENA','EA','CSA','SEA','WCA','ESA','OC']; CATS=['footwear','backpack','coat','cloak']
NAME={}; LEVEL={}
IT=json.load(open('pieces.json')); NAME={x['region']:x['regionName'] for x in IT}; LEVEL={x['region']:x['regionLevel'] for x in IT}; ART='/home/user/gnome-venture/aseprite-source/v3/art-wear-concepts'
FAM={'b':'body','m':'mind','c':'craft'}
def b64(p): return 'data:image/png;base64,'+base64.b64encode(open(p,'rb').read()).decode()
def icon(x): return glob.glob(f"{ART}/{x['region']}/{x['cat']}-{x['n']}-*.png")[0]
def short(t): return t.split('.')[0]+'.'
sc=[]
for T,r in enumerate(ORDER):
    v=[x['v'] for x in IT if x['region']==r]
    sc.append(f"<tr><td>{NAME[r]}</td><td>{LEVEL[r]}</td><td>+{T//3}</td><td>{min(v)}&ndash;{max(v)}</td><td>{min(x['petals'] for x in IT if x['region']==r):,}&ndash;{max(x['petals'] for x in IT if x['region']==r):,}</td></tr>")
cards=[]
for r in ORDER:
    cards.append(f'<section id="{r}" data-r="{r}"><h2>{NAME[r]} <span>{r} &middot; region level {LEVEL[r]}</span></h2><div class="grid">')
    for x in [y for y in IT if y['region']==r]:
        ch=''; md=''
        cards.append(f'''<article data-c="{x['cat']}" class="rar-{x['rarity'].lower()}"><div class="pics"><img class="ic" src="{b64(icon(x))}" alt="{html.escape(x['item'])}" width="64" height="64"><img class="pc" src="{b64(f"img/piece-{r}-{x['cat']}-{x['n']}.png")}" alt="" width="132" height="92"></div>
<div class="tx"><p class="it">{html.escape(x['item'])} <i>{x['cat']} &middot; {x['rarity']}</i></p><p class="ds">{html.escape(short(x['artDesc']))}</p>
<h3>{html.escape(x['piece'])}</h3><p class="ef"><b>{x['type']} {x['v']}</b><br>{html.escape(x['effect'])}</p>
<p class="co"><span>{x['petals']:,} Petals</span><span>Tailor {x['tailor']}</span><span>{x['energy']} energy</span><span>{FAM[x['knob']]} knob</span></p></div></article>''')
    cards.append('</div></section>')
nav=''.join(f'<a href="#{r}">{r}</a>' for r in ORDER)
doc=f'''<title>Wear Pieces</title>
<meta name="claude:viewport-fit-sides" content="cover">
<style>
/* layout: sticky region strip, then one card grid per region; each card = item icon + real strip piece picture + effect + costs */
:root{{--bg:#f6efe2;--card:#fffaf0;--fg:#2b1c26;--mut:#6b5a58;--line:#d9c9a8;--acc:#b4441f;--com:#8a7a5c;--unc:#2f6f9a;--rare:#b07a00}}
@media (prefers-color-scheme:dark){{:root:not([data-theme="light"]){{--bg:#201820;--card:#2c222c;--fg:#f4e8d4;--mut:#bba9a0;--line:#4a3a46;--acc:#f08a5a;--com:#b0a080;--unc:#7fb8e0;--rare:#f0c040;color-scheme:dark}}}}
:root[data-theme="dark"]{{--bg:#201820;--card:#2c222c;--fg:#f4e8d4;--mut:#bba9a0;--line:#4a3a46;--acc:#f08a5a;--com:#b0a080;--unc:#7fb8e0;--rare:#f0c040;color-scheme:dark}}
body{{background:var(--bg);color:var(--fg);font:15px/1.45 Inter,system-ui,sans-serif;padding-inline:max(16px,env(safe-area-inset-left,0px)) max(16px,env(safe-area-inset-right,0px));padding-block:12px 40px}}
h1{{font:700 28px/1.1 "Space Grotesk",Inter,sans-serif;margin:8px 0}} h2{{font:700 22px "Space Grotesk",Inter,sans-serif;margin:28px 0 10px;text-wrap:balance}} h2 span{{font:500 13px Inter;color:var(--mut);margin-left:8px}}
.lead{{max-width:70ch;color:var(--mut)}} table{{border-collapse:collapse;font-size:13px}} th,td{{padding:4px 10px;border-bottom:1px solid var(--line);text-align:left;font-variant-numeric:tabular-nums}} .tw{{overflow-x:auto}}
nav{{position:sticky;top:env(safe-area-inset-top,0px);background:var(--bg);display:flex;flex-wrap:wrap;gap:6px;padding:8px 0;z-index:5;border-bottom:1px solid var(--line)}}
nav a,nav button{{font:600 12px Inter;padding:4px 8px;border:1px solid var(--line);border-radius:6px;background:var(--card);color:var(--fg);text-decoration:none;cursor:pointer}} nav button[aria-pressed="true"]{{background:var(--acc);color:var(--bg);border-color:var(--acc)}} nav .sp{{flex:1}}
.grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(310px,1fr));gap:12px}}
article{{display:flex;gap:12px;background:var(--card);border:1px solid var(--line);border-radius:8px;padding:10px;min-width:0}}
.pics{{display:flex;flex-direction:column;gap:8px;align-items:center;flex:none}} img{{image-rendering:pixelated;max-width:100%}} .ic{{width:64px;height:64px}} .pc{{width:132px;height:auto}}
.tx{{min-width:0;flex:1}} .tx p{{margin:0 0 4px}} .it{{font-weight:600}} .it i{{font:500 12px Inter;color:var(--mut);margin-left:4px}} .ds{{font-size:12px;color:var(--mut)}}
h3{{font:700 16px "Space Grotesk",Inter,sans-serif;margin:6px 0 2px;color:var(--acc)}} .ef{{font-size:13px}} .chip{{font:600 11px Inter;padding:1px 6px;border-radius:99px;border:1px solid var(--line);margin:0 4px 0 6px}} .chip.k{{border-style:dashed}}
.co{{display:flex;flex-wrap:wrap;gap:4px 10px;font-size:12px;color:var(--mut);margin-top:6px!important}}
.rar-uncommon .it i{{color:var(--unc)}} .rar-rare .it i{{color:var(--rare)}} .rar-common .it i{{color:var(--com)}}
</style>
<h1>Wear Pieces</h1>
<p class="lead">280 wearables, 280 different effects, written against the 2.7.00 quick rules (fixed firing order, no lone pieces). Each Common and Uncommon piece pairs its own trigger with its own payoff; each Rare has a hand-written rule. Numbers in the text grow with region and rarity. Left picture is the item, right is the piece it grants. Value is the base; the game adds your stat, level/3 and rank (Lined +2, Fine +4). Petals is the Common-rank price; Lined x1.5, Fine x2.5. New effects need engine work.</p>
<div class="tw"><table><thead><tr><th>Region</th><th>Level</th><th>Base bonus</th><th>Piece values</th><th>Petals (Common&ndash;Rare)</th></tr></thead><tbody>{''.join(sc)}</tbody></table></div>
<nav id="nav">{nav}<span class="sp"></span><button data-f="all" aria-pressed="true">All</button><button data-f="footwear" aria-pressed="false">Footwear</button><button data-f="backpack" aria-pressed="false">Backpack</button><button data-f="coat" aria-pressed="false">Coat</button><button data-f="cloak" aria-pressed="false">Cloak</button></nav>
{''.join(cards)}
<script>
document.querySelectorAll("nav button").forEach(b=>b.addEventListener("click",()=>{{const f=b.dataset.f;document.querySelectorAll("nav button").forEach(o=>o.setAttribute("aria-pressed",String(o===b)));document.querySelectorAll("article").forEach(a=>a.hidden=!(f==="all"||a.dataset.c===f))}}));
</script>'''
open('page.html','w').write(doc); print(len(doc)//1024,'KB')
