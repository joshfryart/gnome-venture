from gen import *
EM={"Strawberry":"🍓","Blueberry":"🫐","Peach":"🍑","Tomato":"🍅","Onion":"🧅","Ginger":"🫚","Apple":"🍎","Cucumber":"🥒","Dill":"🌿","Carrot":"🥕","Cabbage":"🥬","Chili":"🌶️","Elderberry":"🫐"}
def frames(r,small=False):
    return "".join(f"<div class='ib {'' if h>=need else 'lack'}'><div class=bx>{EM.get(nm,'🧺')}<em>×{h}</em></div><b>{nm}</b><span class=sm>{'✓ ' if h>=need else 'need '+str(need-h)+' more · '}{h}/{need}</span></div>" for nm,h,need in r[6])
BASE="""main{min-width:0}.ic{font-size:22px}.rm{flex:1;min-width:0}.dot{width:10px;height:10px;border-radius:99px;flex:none}.dot.g{background:var(--grl)}.dot.r{background:var(--rd)}
.ib{width:112px;text-align:center;display:grid;gap:4px;justify-items:center}.bx{position:relative;width:84px;height:84px;border-radius:10px;background:var(--s2);border:2px solid var(--grl);display:grid;place-items:center;font-size:40px}.bx em{position:absolute;right:4px;bottom:2px;font:700 12px system-ui;font-style:normal;background:#000a;border-radius:6px;padding:0 5px}.ib.lack .bx{border-color:var(--rd)}.ib.lack span{color:#ffb8a8}
.li{display:flex;gap:10px;align-items:center;padding:8px 10px;border-radius:8px;border:1px solid transparent}.li.sel{background:var(--s);border-color:var(--ac)}
.jb{display:flex;gap:6px;align-items:center;flex-wrap:wrap}.ibs{display:flex;gap:12px;margin:14px 0;flex-wrap:wrap}
.chipbar{display:flex;gap:6px;overflow-x:auto;margin:10px 0}.srch{background:var(--s);border:1px solid var(--ln);border-radius:8px;padding:9px 12px;color:var(--mu);margin:10px 0}
"""
# ---- D2: kinds + search + jar-fit preview ----
def D2():
    sel=R[3]
    kinds=["All","Jam","Chutney","Pickle","Ferment","Cordial"]
    ch="".join(f"<span class='chip{' on' if k=='Chutney' else ''}'>{k}</span>" for k in kinds)
    lst=""; last=None
    for r in R:
        if r[5]!=last and r[5] in("Jam","Chutney","Pickle","Ferment","Cordial"): pass
        lst+=f"<div class='li{' sel' if r is sel else ''}'><span class=ic>{r[0]}</span><div class=rm><b>{r[1]}</b><div class='sm mu'>{r[3]} · {r[2]} jars</div></div><i class='dot {'g' if can(r) else 'r'}'></i></div>"
    jars=" ".join(f"<span class='chip{' ok' if j[3]=='Ready!' else ''}'>{j[0]} {'Ready' if j[3]=='Ready!' else j[3]}</span>" for j in JARS)+f" <span class=chip>＋{EMPTY} free</span>"
    det=f"""<div class=dh><span class=big>{sel[0]}</span><div><h3>{sel[1]}</h3><div class='sm mu'>Chutney · makes {sel[2]} jars · ⚡ +6</div></div></div>
<div class=fit><b>⏱ {sel[3]}</b><span class=mu>Goes in a free jar · ready Sun 2 Nov</span></div>
<h4 class=sm style='letter-spacing:.07em;color:var(--mu)'>INGREDIENTS</h4><div class=ibs>{frames(sel)}</div>
<div class=acts><button class=btn>Make ×1</button><button class='btn alt'>×2</button><button class='btn alt'>All 2</button></div>"""
    css=BASE+""".top2{display:flex;align-items:center;gap:10px;flex-wrap:wrap}.md{display:grid;grid-template-columns:330px 1fr;gap:14px;margin-top:6px}.lst{display:grid;gap:4px;align-content:start;max-height:600px;overflow:auto}
.det{padding:20px}.dh{display:flex;gap:14px;align-items:center}.big{font-size:44px}.det h3{font-size:22px}.fit{display:flex;gap:12px;align-items:center;background:var(--s2);border-radius:8px;padding:9px 12px;margin:14px 0}.acts{display:flex;gap:8px}
.sheet{display:none}.chipbar .chip{flex:none}
@media(max-width:760px){.md{grid-template-columns:1fr}.det{display:none}.sheet{display:block;position:sticky;bottom:0;margin:10px -12px -12px;background:var(--s);border-top:2px solid var(--ac);border-radius:16px 16px 0 0;padding:6px 14px 14px;box-shadow:0 -8px 24px #000b}.sheet .grab{width:40px;height:4px;border-radius:9px;background:var(--ln);margin:4px auto 10px}.sheet .hd{display:flex;justify-content:space-between;align-items:center}.sheet .fit{margin:8px 0;padding:6px 10px;font-size:13px;flex-wrap:wrap;gap:4px 10px}.sheet .bx{width:56px;height:56px;font-size:28px}.sheet .ib{width:76px}.sheet .ibs{margin:8px 0;gap:8px}.sheet .acts .btn{flex:1}.lst{max-height:none}}"""
    sheet=f"<div class=sheet><div class=grab></div><div class=hd><b>{sel[0]} {sel[1]}</b><span class='sm mu'>{sel[3]} · {sel[2]} jars</span></div><div class=fit><span class=mu>Ready Sun 2 Nov in a free jar</span></div><div class=ibs>{frames(sel)}</div><div class=acts><button class=btn>Make ×1</button><button class='btn alt'>×2</button><button class='btn alt'>All 2</button></div></div>"
    body=f"<div class=top2><h2>🫙 Pantry <small>5/7 jars in use</small></h2></div><div class=jb style='margin-top:6px'>{jars}<button class='btn s'>Collect (1)</button></div><div class=srch>🔍 Search recipes…</div><div class=chipbar>{ch}</div><div class=md><div class=lst>{lst}</div><div class='card det'>{det}</div></div>{sheet}"
    return shell("D2",body,css)
# ---- D3: three columns (jars rail | list | detail); mobile: inline accordion ----
def D3():
    sel=R[3]
    rail="".join(f"<div class='rj{' rdy' if j[3]=='Ready!' else ''}'><span class=ic>{j[0]}</span><div class=rm><b class=sm>{j[1]}</b><div class='bar{' rd' if j[3]=='Ready!' else ''}'><i style='width:{j[4]}%'></i></div></div><span class='sm mu'>{'<button class=\"btn s\">Collect</button>' if j[3]=='Ready!' else j[3]}</span></div>" for j in JARS)+"".join("<div class='rj emp'>＋ Empty jar</div>" for _ in range(EMPTY))
    lst=""
    for r in R:
        s = r is sel
        inner=f"<div class='li{' sel' if s else ''}'><span class=ic>{r[0]}</span><div class=rm><b>{r[1]}</b><div class='sm mu'>{r[3]} · {r[2]} jars</div></div><i class='dot {'g' if can(r) else 'r'}'></i></div>"
        if s: inner+=f"<div class=inl><div class=ibs>{frames(r)}</div><div class=acts><button class=btn>Make ×1</button><button class='btn alt'>×2</button><button class='btn alt'>All 2</button></div></div>"
        lst+=f"<div class=ent>{inner}</div>"
    det=f"<h3>{sel[0]} {sel[1]}</h3><div class='sm mu'>Makes {sel[2]} jars · ⏱ {sel[3]} · ⚡ +6</div><div class=ibs>{frames(sel)}</div><div class=acts><button class=btn>Make ×1</button><button class='btn alt'>×2</button><button class='btn alt'>All 2</button></div><p class='sm mu' style='margin-top:14px'>Timers run in real days, even while you are away. Nothing spoils.</p>"
    css=BASE+""".md{display:grid;grid-template-columns:250px 300px 1fr;gap:14px;margin-top:8px}.rail{display:grid;gap:8px;align-content:start}.rj{display:flex;gap:8px;align-items:center;background:var(--s);border:1px solid var(--ln);border-radius:10px;padding:8px 10px}.rj.rdy{border-color:var(--grl)}.rj.emp{border-style:dashed;background:none;color:var(--mu);justify-content:center;font-size:13px}.rj .bar{margin-top:4px}
.lst{display:grid;gap:4px;align-content:start;max-height:640px;overflow:auto}.det{padding:20px}.det h3{font-size:22px}.acts{display:flex;gap:8px}.inl{display:none}
.seg{display:none}.jsum{display:none}
@media(max-width:760px){.md{grid-template-columns:1fr;gap:10px}.det{display:none}.rail{display:none}.jsum{display:flex;align-items:center;gap:8px;background:var(--s);border:1px solid var(--ln);border-radius:10px;padding:10px 12px}.jsum b{flex:1}.ent{border-radius:8px}.ent:has(.inl){background:var(--s);border:1px solid var(--ac)}.ent .li.sel{border:0;background:none}.inl{display:block;padding:0 10px 12px}.inl .bx{width:64px;height:64px;font-size:32px}.inl .ib{width:84px}.inl .ibs{gap:8px;margin:6px 0 10px}.inl .acts .btn{flex:1}.lst{max-height:none}.seg{display:flex;gap:6px;margin:10px 0}.seg .chip{flex:1;justify-content:center;padding:8px}.stk{position:sticky;bottom:0;margin:8px -12px -12px;background:var(--s);border-top:2px solid var(--ac);padding:10px 12px;display:flex;gap:10px;align-items:center}.stk b{flex:1}}
.stk{display:none}@media(max-width:760px){.stk{display:flex}}"""
    stk=f"<div class=stk><b>{sel[0]} {sel[1]}<div class='sm mu' style='font-weight:400'>{sel[3]} · ready Sun 2 Nov</div></b><button class=btn>Make ×1</button></div>"
    body=f"<h2>🫙 Pantry <small>5/7 jars in use</small></h2><div class=jsum style='margin-top:8px'><b>🫙 5/7 jars · 1 ready</b><button class='btn s'>Collect</button><span class=mu>▾</span></div><div class=seg><span class='chip on'>Can make</span><span class=chip>Missing</span><span class=chip>Discover</span></div><div class=md><div class=rail><h4 class=sm style='letter-spacing:.07em;color:var(--mu)'>JARS</h4>{rail}</div><div class=lst>{lst}</div><div class='card det'>{det}</div></div>{stk}"
    return shell("D3",body,css)
for k,f in [("D2",D2),("D3",D3)]: open(k+".html","w").write(f())
