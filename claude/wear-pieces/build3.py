#!/usr/bin/env python3
"""Rework: unique effects. design2.py -> pieces.json (value, price, tailor, effect text)."""
import json, collections, sys
sys.path.insert(0,'.')
from design2 import REG as REG2
from design3 import TRIG, PAY, PAYTYPE, OLDT, OLDP, RARE
REG=REG2
ORDER=['NA','CA','NWE','CB','SE','SA','EE','MENA','EA','CSA','SEA','WCA','ESA','OC']
LEVEL=dict(zip(ORDER,[1,4,6,8,10,12,14,17,20,23,26,29,32,35]))
NAME={'NA':'The Maplewold','CA':'Maizehollow','NWE':'Mistmoor','CB':'The Sunsprinkle Isles','SE':'Olivewhistle Shore','SA':'The Rainroot Reaches','EE':'Birchbramble Steppe','MENA':'The Dunewhisper','EA':'Blossomreach','CSA':'Spicepeak','SEA':'The Monsoon Tangle','WCA':'The Greatcanopy','ESA':'Thornacre Savanna','OC':'The Coralscatter'}
CATS=['footwear','backpack','coat','cloak']; RAR=['Common','Common','Uncommon','Uncommon','Rare']
BASE=dict(hurt=4,guard=4,heal=3,charm=4,item=5,trick=3,soothe=2)
ART=json.load(open('art.json'))
def price(T,rar): return int(round(({'Common':1200,'Uncommon':3200,'Rare':8000}[rar])*(1+0.25*T)/50))*50
# Balance 2026-11-18 (balance.md, sims in sim/). The effect numbers a and b follow the region LEVEL: by tier (a 1+T//5, b 2+T//3) they fell to half
# their share of the gnome's health from the first region to the last, while the piece values (the game adds level/3) kept up.
def ab(T,rar):
    L=LEVEL[ORDER[T]]
    return 1+L//10+(1 if rar=='Rare' else 0), 2+L//5+(1 if rar=='Uncommon' else 0)+(2 if rar=='Rare' else 0)
# Triggers the sims saw change a fight in under 6% of the fights the piece was played: +1 on the payoff's number (b or a; the value v when the payoff has none, or when it counts rounds).
RARE_TRIG={'linkT','linkS','linkHeal','link2','linkC','pair','r1','foeB0','foeB3','lastRound'}
PAY_N={'guard':'b','heal':'b','dmg':'b','charm':'b','ward':'b','focus':'b','soothe':'a','poison':'a','thorns':'a','cleanse':'a','boost':'a','mend':'a','shrink':'a'}
# Rares over the Rare limit at Fine (about +6 win points or -12 health points, mostly the Trip ones with the careless bot): their value comes down, the effect stays.
RARE_FIX={('MENA','cloak'):dict(v=-5,b=-2),('EA','footwear'):dict(v=-6,b=-2),('SE','cloak'):dict(v=-3),('SA','footwear'):dict(v=-1),('CB','footwear'):dict(v=-1),('MENA','backpack'):dict(v=-1),('ESA','footwear'):dict(b=-2)}
used={}; items=[]; fixed=[]
for T,r in enumerate(ORDER):
    for ci,cat in enumerate(CATS):
        for i,(pn,ty,tr,py) in enumerate(REG[r][cat]):
            rar=RAR[i]; a,b=ab(T,rar); dv=0
            if tr=='R':
                fx=RARE_FIX.get((r,cat),{}); dv=fx.get('v',0); a+=fx.get('a',0); b+=fx.get('b',0)
                txt=RARE[(r,cat)].format(a=a,b=b); code='R:'+r+':'+cat
            else:
                tr=OLDT.get(tr,tr); py=OLDP.get(py,py)
                if py not in PAYTYPE[ty]: py=next(p for p in PAYTYPE[ty] if (tr,p) not in used or True)
                trs=[tr]+[t for t in TRIG if t!=tr]; pys=[py]+[p for p in PAYTYPE[ty] if p!=py]
                done=False
                for p_ in pys:
                    for t_ in trs:
                        if (t_,p_) not in used: tr,py=t_,p_; done=True; break
                    if done: break
                used[(tr,py)]=pn; code=f'{tr}>{py}'
                if tr in RARE_TRIG:
                    if PAY_N.get(py)=='a': a+=1
                    elif PAY_N.get(py)=='b': b+=1
                    else: dv=1
                txt=f"{TRIG[tr]}, {PAY[py].format(a=a,b=b)}."
            v=max(2,BASE[ty]-1+T//3+(0,0,1,1,3)[i]+dv)
            art=ART[f'{r}|{cat}|{i+1}']
            items.append(dict(region=r,regionName=NAME[r],regionLevel=LEVEL[r],tier=T,cat=cat,n=i+1,rarity=rar,item=art[0],artDesc=art[1],piece=pn,type=ty,v=v,code=code,effect=txt,
                knob='bmc'[(T+ci+i)%3],petals=price(T,rar),tailor=(1,1,2,2,3)[i],energy=(4,4,5,5,6)[i],a=a,b=b))
texts=collections.Counter(x['effect'] for x in items); names=collections.Counter(x['piece'] for x in items); codes=collections.Counter(x['code'] for x in items)
errs=[f'dup text {t}' for t,c in texts.items() if c>1]+[f'dup name {t}' for t,c in names.items() if c>1]+[f'dup code {t}' for t,c in codes.items() if c>1]
print('items',len(items),'distinct effect codes',len(codes),'distinct texts',len(texts),'errors',errs,'pair fixes',len(fixed))
if __name__=='__main__': json.dump(items,open('pieces.json','w'),indent=1)
