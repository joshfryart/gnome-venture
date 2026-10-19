import json, statistics as st
rows=json.load(open('/home/claude/bal/crops.json'))
cur={'C':100,'U':140,'R':220,'L':450}
def scen(mult, regrow_xp=1.0, regrow_yield=1.0):
    out={}
    for x in rows:
        base=x['price']/ (cur[x['r']]/100)
        price=base*mult[x['r']]/100
        y=x['yield']*(regrow_yield if x['per'] else 1)
        seedc = (x['yield']*x['price']-x['rev'])  # seed cost part
        rev=y*price-seedc
        xp=x['xp']*(regrow_xp if x['per'] else 1)
        k=x['r']+('p' if x['per'] else 'a')
        out.setdefault(k,[]).append((rev/x['E'], rev/(x['cyc']/60), xp/x['E'], xp/(x['cyc']/60)))
    return {k:tuple(st.median([v[i] for v in l]) for i in range(4)) for k,l in out.items()}
profiles=[(1,4,['Ca']),(3,4,['Ca','Cp','Ua','Up']),(5,5,['Ca','Cp','Ua','Up','Lp']),(10,6,['Ca','Cp','Ua','Up','Lp']),(20,8,['Ca','Cp','Ua','Up','Lp']),(30,10,['Ca','Cp','Ua','Up','Lp'])]
def run(name,s):
    print(f"\n{name}")
    print("  group: Petals/energy, Petals/square/hour, XP/energy")
    for k in sorted(s): print(f"   {k}: {s[k][0]:6.1f} {s[k][1]:7.1f} {s[k][2]:5.1f}")
    for L,side,av in profiles:
        sq=side*side
        best=max(((min(30*s[k][0], sq*s[k][1]), min(30*s[k][2], sq*s[k][3]), k) for k in av if k in s))
        need=50*(L+1)*L-50*L*(L-1)
        print(f"   L{L:<2} {sq:3d} squares: best {best[2]} ~{best[0]:6.0f} Petals/h, ~{best[1]:5.0f} XP/h -> next level in {need/max(1,best[1]):4.1f} h")
run("BEFORE 0.7.61 (all ×1)", scen({'C':100,'U':100,'R':100,'L':100}))
run("NOW 0.7.63 (U 140, R 220, L 450)", scen(cur))
run("PROPOSED (U 130, R 180, L 250; regrow harvests 60% XP, 75% yield)", scen({'C':100,'U':130,'R':180,'L':250},0.6,0.75))
