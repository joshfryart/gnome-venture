import html
JARS=[("🍓","Strawberry Jam",3,"Ready!",100),("🍅","Tomato Chutney",3,"1.2 days",60),("🥒","Dill Pickles",3,"2.5 days",18),("🥬","Sauerkraut",3,"6 days",14),("🫖","Elderberry Cordial",3,"13 days",7)]
EMPTY=2
R=[ # icon,name,makes,time,days,kind,ings[(name,have,need)]
("🍓","Strawberry Jam",4,"1 day",1,"Jam",[("Strawberry",6,5)]),
("🫐","Blueberry Jam",4,"1 day",1,"Jam",[("Blueberry",2,5)]),
("🍑","Peach Jam",4,"1 day",1,"Jam",[("Peach",5,5)]),
("🍅","Tomato Chutney",3,"2 days",2,"Chutney",[("Tomato",6,4),("Onion",2,1),("Ginger",1,1)]),
("🍎","Apple Chutney",3,"2 days",2,"Chutney",[("Apple",1,2),("Onion",0,1),("Ginger",0,1)]),
("🥒","Dill Pickles",3,"3 days",3,"Pickle",[("Cucumber",8,5),("Dill",3,1)]),
("🥕","Pickled Carrots",3,"3 days",3,"Pickle",[("Carrot",4,5)]),
("🧅","Pickled Onions",3,"3 days",3,"Pickle",[("Onion",5,5)]),
("🌶️","Kimchi",3,"5 days",5,"Ferment",[("Cabbage",4,3),("Chili",2,2),("Ginger",1,1)]),
("🥬","Sauerkraut",4,"7 days",7,"Ferment",[("Cabbage",6,6)]),
("🫖","Elderberry Cordial",3,"14 days",14,"Cordial",[("Elderberry",3,6)]),
("🍎","Apple Cider",3,"14 days",14,"Cordial",[("Apple",1,5)]),
]
def can(r): return all(h>=n for _,h,n in r[6])
def short(r): return ", ".join(f"{n} {need-h}" for n,h,need in r[6] if h<need)
CSS="""
*{box-sizing:border-box;margin:0}
html,body{overflow-x:hidden}
:root{--bg:#2a1a10;--s:#3d2a1c;--s2:#4a2c1a;--ink:#f2e4c0;--mu:#c9a96e;--ln:#74462a;--ac:#e8a317;--gr:#2f5a2a;--grl:#7ab55c;--rd:#b23a2a;--k:#f08a24}
body{background:var(--bg);color:var(--ink);font:15px/1.4 system-ui,sans-serif}
.top{display:flex;justify-content:space-between;align-items:center;padding:10px 16px;border-bottom:2px dashed var(--ac);font-weight:700}
.top .st{display:flex;gap:8px}.pill{background:var(--s2);border:1px solid var(--ln);border-radius:8px;padding:3px 9px;font-size:13px}.pill.g{background:var(--ac);color:#2a1a10}
main{min-width:0}
.layout{display:grid;grid-template-columns:230px 1fr;gap:24px;max-width:1360px;margin:0 auto;padding:18px}
.nav{display:grid;gap:8px;align-content:start}.nav b{background:var(--s);border:1px solid var(--ln);border-radius:8px;padding:9px 12px;font-weight:600;font-size:14px}.nav b.on{background:var(--rd);border-color:var(--rd)}
@media(max-width:760px){.layout{grid-template-columns:1fr;padding:12px}.nav{display:none}.top{padding:8px 12px}}
h1{font-size:24px;margin:2px 0 10px}h2{font-size:16px;display:flex;gap:8px;align-items:baseline}h2 small{color:var(--mu);font-weight:400}
.tabs{display:flex;gap:8px;margin-bottom:14px}.tabs span{flex:1;text-align:center;padding:8px;border-radius:8px;background:var(--s);border:1px solid var(--ln);font-size:14px}.tabs .on{background:var(--rd)}
.card{background:var(--s);border:1px solid var(--ln);border-radius:10px}
.btn{background:var(--gr);color:#fff;border:0;border-radius:8px;padding:8px 14px;font-weight:700;font-size:14px;min-height:40px}.btn.s{padding:4px 10px;min-height:32px;font-size:13px}.btn.alt{background:var(--s2);border:1px solid var(--ln);color:var(--ink)}
.chip{display:inline-flex;gap:4px;align-items:center;padding:3px 9px;border-radius:99px;font-size:12.5px;background:var(--s2);border:1px solid var(--ln);white-space:nowrap}
.chip.ok{background:#27471f;border-color:#4a7a3a}.chip.no{background:#4a2020;border-color:#8a3a30;color:#ffb8a8}.chip.on{background:var(--ac);color:#2a1a10;border-color:var(--ac);font-weight:700}
.mu{color:var(--mu)}.sm{font-size:12.5px}
.bar{height:6px;border-radius:9px;background:#2a1a10;overflow:hidden}.bar i{display:block;height:100%;background:var(--ac)}.bar.rd i{background:var(--grl)}
.lbl{position:absolute;top:6px;right:10px;font-size:11px;color:var(--mu);letter-spacing:.06em}
"""
def shell(title,body,extra=""):
    return f"""<!DOCTYPE html><html><head><meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1"><style>{CSS}{extra}</style></head><body>
<div class=top><span>Gnome Venture</span><span class=st><span class=pill>⚡ 20/10</span><span class="pill g">5,000</span></span></div>
<div class=layout><div class=nav><b>Today</b><b>Satchel</b><b class=on>Crafting</b><b>Garden</b><b>Villagers</b></div><main>
<h1>Your Satchel</h1><div class=tabs><span>Satchel</span><span class=on>Crafting</span><span>Belt</span><span>Arrange</span></div>
{body}</main></div></body></html>"""
def jar_chip(j): return f"{j[0]} {j[1]} ×{j[2]}"
# ---------- A: Shelf + dense rows ----------
def A():
    jars="".join(f"<div class='jar{' rdy' if j[3]=='Ready!' else ''}'><span class=ic>{j[0]}</span><b>{j[1]}</b><span class=sm>{'<u>Ready</u>' if j[3]=='Ready!' else j[3]}</span><div class='bar{' rd' if j[3]=='Ready!' else ''}'><i style='width:{j[4]}%'></i></div></div>" for j in JARS)
    jars+="".join("<div class='jar emp'><span class=ic>＋</span><span class=sm>Empty</span></div>" for _ in range(EMPTY))
    rows=""
    for r in R:
        ok=can(r)
        ing=" ".join(f"<span class='chip {'ok' if h>=n else 'no'}'>{n} {h}/{need}</span>" for n,h,need in r[6] for need in [n] ) if False else " ".join(f"<span class='chip {'ok' if h>=need else 'no'}'>{nm} {h}/{need}</span>" for nm,h,need in r[6])
        rows+=f"<div class='row card'><span class=ic>{r[0]}</span><div class=rm><b>{r[1]}</b><div class='sm mu'>Makes {r[2]} jars · ⏱ {r[3]}</div><div class=ings>{ing}</div></div><button class='btn s{'' if ok else ' alt'}' {'' if ok else 'disabled style=opacity:.5'}>Make</button></div>"
    css=""".shelf{display:flex;gap:10px;overflow-x:auto;scroll-snap-type:x mandatory;padding:4px 0 10px}.jar{flex:0 0 150px;scroll-snap-align:start;background:var(--s);border:1px solid var(--ln);border-radius:10px;padding:10px;display:grid;gap:4px;justify-items:center;text-align:center}.jar.rdy{border-color:var(--grl);box-shadow:0 0 0 1px var(--grl)}.jar .bar{width:100%}.jar.emp{border-style:dashed;background:none;color:var(--mu);align-content:center}.ic{font-size:26px}u{color:var(--grl);text-decoration:none;font-weight:700}
.chips{display:flex;gap:6px;flex-wrap:wrap;margin:12px 0}.list{display:grid;grid-template-columns:1fr 1fr;gap:10px}.row{display:flex;gap:12px;padding:10px 12px;align-items:center}.rm{flex:1;min-width:0}.ings{display:flex;gap:5px;flex-wrap:wrap;margin-top:6px}
@media(max-width:760px){.list{grid-template-columns:1fr}.jar{flex-basis:128px}.row{padding:10px}}"""
    body=f"<h2>🫙 Pantry <small>5/7 jars in use</small> <button class='btn s' style='margin-left:auto'>Collect ready (1)</button></h2><div class=shelf>{jars}</div><div class=chips><span class='chip on'>✅ Can make (6)</span><span class=chip>📋 Missing (6)</span><span class=chip>❔ To discover</span><span class=chip>All kinds ▾</span></div><div class=list>{rows}</div>"
    return shell("A",body,css)
# ---------- B: Ledger ----------
def B():
    jr="".join(f"<tr><td>{j[0]} {j[1]} ×{j[2]}</td><td class=mu>{'Ready!' if j[3]=='Ready!' else j[3]}</td><td class=bc><div class=bar><i style='width:{j[4]}%'></i></div></td><td>{'<button class=\"btn s\">Collect</button>' if j[3]=='Ready!' else ''}</td></tr>" for j in JARS)
    rr=""
    for r in R:
        ok=can(r)
        ing=", ".join(f"<span class='{'' if h>=need else 'nn'}'>{nm} {h}/{need}</span>" for nm,h,need in r[6])
        rr+=f"<tr><td class=n>{r[0]} <b>{r[1]}</b><div class='sm mu m'>{r[3]} · {r[2]} jars</div></td><td class='mu c3'>{r[3]}</td><td class='c3 mu'>{r[2]}</td><td class=ig>{ing}</td><td><button class='btn s{'' if ok else ' alt'}'{'' if ok else ' disabled style=opacity:.45'}>Make</button></td></tr>"
    css="""table{width:100%;border-collapse:collapse}td,th{padding:8px 10px;border-bottom:1px solid var(--ln);text-align:left;vertical-align:middle}th{font-size:11.5px;letter-spacing:.07em;color:var(--mu);font-weight:600;text-transform:uppercase}.bc{width:28%}.nn{color:#ffb8a8}.ig{font-size:13.5px}.m{display:none}.sec{margin:18px 0 8px}.wrap{overflow:hidden}
@media(max-width:760px){.c3{display:none}.m{display:block}th.c3{display:none}.bc{width:22%}td,th{padding:8px 6px}.ig{font-size:12.5px}}"""
    body=f"<h2 class=sec style='margin-top:0'>🫙 Pantry <small>5/7 jars</small></h2><div class='card wrap'><table>{jr}<tr><td colspan=4 class='mu sm'>＋ 2 empty jars</td></tr></table></div><h2 class=sec>Recipes <small>sorted by time</small></h2><div class='card wrap'><table><tr><th>Recipe</th><th class=c3>Time</th><th class=c3>Jars</th><th>Ingredients</th><th></th></tr>{rr}</table></div>"
    return shell("B",body,css)
# ---------- C: Timeline groups (accordions) ----------
def C():
    groups={}
    for r in R: groups.setdefault(r[4],[]).append(r)
    names={1:"Jams · 1 day",2:"Chutneys · 2 days",3:"Pickles · 3 days",5:"Kimchi · 5 days",7:"Sauerkraut · 7 days",14:"Cordials · 14 days"}
    secs=""
    for i,(d,rs) in enumerate(groups.items()):
        mk=sum(can(r) for r in rs)
        inner="".join(f"<div class=it><span class=ic>{r[0]}</span><div class=rm><b>{r[1]}</b><div class='sm {'mu' if can(r) else 'bad'}'>{'Ready to make' if can(r) else 'Need '+short(r)}</div></div><button class='btn s{'' if can(r) else ' alt'}'{'' if can(r) else ' disabled style=opacity:.45'}>Make</button></div>" for r in rs)
        op=' open' if i==0 else ''
        secs+=f"<details class=card{op}><summary><b>{names[d]}</b><span class='chip {'ok' if mk else ''}'>{mk}/{len(rs)} ready</span></summary><div class=g>{inner}</div></details>"
    jars=" ".join(f"<span class='chip{' ok' if j[3]=='Ready!' else ''}'>{j[0]} {j[3]}</span>" for j in JARS)
    css="""details{margin-bottom:10px}summary{display:flex;justify-content:space-between;align-items:center;padding:12px 14px;cursor:pointer;list-style:none;font-size:15.5px}summary::after{content:'▾';margin-left:10px;color:var(--mu)}summary b{flex:1}
.g{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;padding:0 12px 12px}.it{display:flex;gap:10px;align-items:center;background:var(--s2);border-radius:8px;padding:8px 10px}.rm{flex:1;min-width:0}.ic{font-size:22px}.bad{color:#ffb8a8}
.sticky{position:sticky;top:0;z-index:2;background:var(--bg);padding:8px 0 10px;margin-bottom:6px;border-bottom:1px solid var(--ln)}.sticky .row{display:flex;gap:6px;flex-wrap:wrap;align-items:center}
@media(max-width:760px){.g{grid-template-columns:1fr}.sticky .row{flex-wrap:nowrap;overflow-x:auto}}"""
    body=f"<div class=sticky><h2>🫙 Pantry <small>5/7 jars in use</small></h2><div class=row style='margin-top:6px'>{jars}<button class='btn s'>Collect (1)</button></div></div>{secs}"
    return shell("C",body,css)
# ---------- D: Master-detail ----------
def D():
    sel=R[3]
    lst="".join(f"<div class='li{' sel' if r is sel else ''}'><span class=ic>{r[0]}</span><div class=rm><b>{r[1]}</b><div class='sm mu'>{r[3]} · {r[2]} jars</div></div><i class='dot {'g' if can(r) else 'r'}'></i></div>" for r in R)
    ing="".join(f"<div class='ib {'' if h>=need else 'lack'}'><div class=bx>{['🍅','🧅','🫚'][i]}</div><b>{nm}</b><span class=sm>{h} / {need}</span></div>" for i,(nm,h,need) in enumerate(sel[6]))
    jars="".join(f"<div class='mj{' rdy' if j[3]=='Ready!' else ''}'>{j[0]}<span class=sm>{'Ready' if j[3]=='Ready!' else j[3]}</span></div>" for j in JARS)+"".join("<div class='mj emp'>＋</div>" for _ in range(EMPTY))
    css=""".ic{font-size:22px}.rm{flex:1;min-width:0}.mjs{display:flex;gap:8px;margin-bottom:12px}.mj{flex:1;display:grid;justify-items:center;padding:8px 4px;border-radius:10px;background:var(--s);border:1px solid var(--ln);font-size:22px}.mj.rdy{border-color:var(--grl)}.mj.emp{border-style:dashed;background:none;color:var(--mu);align-content:center}
.md{display:grid;grid-template-columns:340px 1fr;gap:14px}.lst{display:grid;gap:6px;align-content:start;max-height:640px;overflow:auto}.li{display:flex;gap:10px;align-items:center;padding:8px 10px;border-radius:8px;border:1px solid transparent}.li.sel{background:var(--s);border-color:var(--ac)}
.dot{width:10px;height:10px;border-radius:99px}.dot.g{background:var(--grl)}.dot.r{background:var(--rd)}.det{padding:18px}.det h3{font-size:22px}.ibs{display:flex;gap:12px;margin:16px 0}.ib{width:110px;text-align:center;display:grid;gap:4px;justify-items:center}.bx{width:84px;height:84px;border-radius:10px;background:var(--s2);border:2px solid var(--grl);display:grid;place-items:center;font-size:40px}.ib.lack .bx{border-color:var(--rd)}.ib.lack span{color:#ffb8a8}
.mob{display:none}@media(max-width:760px){.md{grid-template-columns:1fr}.det{display:none}.mob{display:block;position:sticky;bottom:0;margin:10px -12px -12px;background:var(--s);border-top:2px solid var(--ac);padding:12px;border-radius:14px 14px 0 0}.mob h3{font-size:17px}.mob .ibs{margin:8px 0}.mob .bx{width:56px;height:56px;font-size:28px}.mob .ib{width:72px}.lst{max-height:none}}"""
    det=f"<h3>{sel[0]} {sel[1]}</h3><div class='sm mu'>Makes {sel[2]} jars · ⏱ {sel[3]} · ⚡ +6</div><div class=ibs>{ing}</div><button class=btn>Make ×1</button> <button class='btn alt'>Make ×3</button>"
    body=f"<h2>🫙 Pantry <small>5/7 jars in use</small></h2><div class=mjs style='margin-top:8px'>{jars}</div><div class=md><div class=lst>{lst}</div><div class='card det'>{det}</div></div><div class=mob><div class=sm style='color:var(--mu)'>SELECTED</div><h3>{sel[0]} {sel[1]} <small class=mu style='font-weight:400'>· {sel[3]}</small></h3><div class=ibs>{ing}</div><button class=btn style='width:100%'>Make ×1</button></div>"
    return shell("D",body,css)
# ---------- E: Tile grid + drawer ----------
def E():
    tiles="".join(f"<div class='t{' sel' if r[1]=='Dill Pickles' else ''}'><span class=ic>{r[0]}</span><b>{r[1]}</b><span class='sm mu'>{r[3]}</span><i class='dot {'g' if can(r) else 'r'}'></i></div>" for r in R)
    jr=R[5]
    jars=" ".join(f"<span class='chip{' ok' if j[3]=='Ready!' else ''}'>{j[0]} {j[3]}</span>" for j in JARS)+f" <span class=chip>＋{EMPTY} empty</span>"
    dr=f"<div class=dh><b>{jr[0]} {jr[1]}</b><span class='sm mu'>Makes {jr[2]} jars · ⏱ {jr[3]} · ⚡ +4</span></div><div class=di>"+" ".join(f"<span class='chip ok'>{nm} {h}/{need}</span>" for nm,h,need in jr[6])+"</div><div class=da><button class=btn>Make ×1</button><button class='btn alt'>×2</button><button class='btn alt'>All 3</button></div>"
    css=""".ic{font-size:30px}.tools{display:flex;gap:8px;margin:12px 0}.search{flex:1;background:var(--s);border:1px solid var(--ln);border-radius:8px;padding:10px 12px;color:var(--mu)}
.grid{display:grid;grid-template-columns:repeat(6,1fr);gap:10px}.t{position:relative;background:var(--s);border:1px solid var(--ln);border-radius:10px;padding:12px 6px;display:grid;justify-items:center;gap:2px;text-align:center;font-size:13.5px}.t.sel{border-color:var(--ac);box-shadow:0 0 0 1px var(--ac)}.dot{position:absolute;top:8px;right:8px;width:9px;height:9px;border-radius:99px}.dot.g{background:var(--grl)}.dot.r{background:var(--rd)}
.dr{margin-top:14px;background:var(--s2);border:1px solid var(--ac);border-radius:12px;padding:14px;display:flex;gap:18px;align-items:center;flex-wrap:wrap}.dh{display:grid}.di{flex:1;display:flex;gap:6px;flex-wrap:wrap}.da{display:flex;gap:8px}
.jb{display:flex;gap:6px;align-items:center;flex-wrap:wrap;margin-top:6px}
@media(max-width:760px){.grid{grid-template-columns:repeat(3,1fr);gap:8px}.t{font-size:12px;padding:10px 4px}.dr{position:sticky;bottom:8px;display:grid;gap:10px;margin:10px 0 0;box-shadow:0 -6px 20px #000a}.jb{flex-wrap:nowrap;overflow-x:auto}.da .btn{flex:1}}"""
    body=f"<h2>🫙 Pantry <small>5/7 jars in use</small></h2><div class=jb>{jars}<button class='btn s'>Collect (1)</button></div><div class=tools><div class=search>🔍 Search recipes</div><span class='chip on' style='align-self:center'>Can make</span><span class=chip style='align-self:center'>All</span></div><div class=grid>{tiles}</div><div class=dr>{dr}</div>"
    return shell("E",body,css)
for k,f in zip("ABCDE",[A,B,C,D,E]): open(f"{k}.html","w").write(f())
