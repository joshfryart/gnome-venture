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
used={}; items=[]; fixed=[]
for T,r in enumerate(ORDER):
    for ci,cat in enumerate(CATS):
        for i,(pn,ty,tr,py) in enumerate(REG[r][cat]):
            rar=RAR[i]; a=1+T//5+(1 if rar=='Rare' else 0); b=2+T//3+(1 if rar=='Uncommon' else 0)+(2 if rar=='Rare' else 0)
            if tr=='R': txt=RARE[(r,cat)].format(a=a,b=b); code='R:'+r+':'+cat
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
                txt=f"{TRIG[tr]}, {PAY[py].format(a=a,b=b)}."
            v=max(2,BASE[ty]-1+T//3+(0,0,1,1,3)[i])
            art=ART[f'{r}|{cat}|{i+1}']
            items.append(dict(region=r,regionName=NAME[r],regionLevel=LEVEL[r],tier=T,cat=cat,n=i+1,rarity=rar,item=art[0],artDesc=art[1],piece=pn,type=ty,v=v,code=code,effect=txt,
                knob='bmc'[(T+ci+i)%3],petals=price(T,rar),tailor=(1,1,2,2,3)[i],energy=(4,4,5,5,6)[i]))
texts=collections.Counter(x['effect'] for x in items); names=collections.Counter(x['piece'] for x in items); codes=collections.Counter(x['code'] for x in items)
errs=[f'dup text {t}' for t,c in texts.items() if c>1]+[f'dup name {t}' for t,c in names.items() if c>1]+[f'dup code {t}' for t,c in codes.items() if c>1]
print('items',len(items),'distinct effect codes',len(codes),'distinct texts',len(texts),'errors',errs,'pair fixes',len(fixed))
if __name__=='__main__': json.dump(items,open('pieces.json','w'),indent=1)
