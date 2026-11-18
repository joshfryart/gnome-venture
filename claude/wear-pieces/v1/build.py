#!/usr/bin/env python3
"""Validate design.py and compute value / price / tailor for the 280 wearable pieces. Writes pieces.json."""
import json, sys, collections, math
sys.path.insert(0, '.')
from design import REG
ORDER = ['NA','CA','NWE','CB','SE','SA','EE','MENA','EA','CSA','SEA','WCA','ESA','OC']
LEVEL = dict(zip(ORDER,[1,4,6,8,10,12,14,17,20,23,26,29,32,35]))
NAME = {'NA':'The Maplewold','CA':'Maizehollow','NWE':'Mistmoor','CB':'The Sunsprinkle Isles','SE':'Olivewhistle Shore','SA':'The Rainroot Reaches','EE':'Birchbramble Steppe','MENA':'The Dunewhisper','EA':'Blossomreach','CSA':'Spicepeak','SEA':'The Monsoon Tangle','WCA':'The Greatcanopy','ESA':'Thornacre Savanna','OC':'The Coralscatter'}
CATS = ['footwear','backpack','coat','cloak']
RAR = ['Common','Common','Uncommon','Uncommon','Rare']
BASE = dict(hurt=4,guard=4,heal=3,charm=4,item=5,trick=3,soothe=2)
TAGCOST = {'-':0,'quick':1,'pierce':1,'hold':1,'poison':2,'trip':2,'bash':2,'evade':2,'mend':2,'thorns':2,'heavy':-2,'hum':1,'bond':1,'lull':2,'simmer':1,'plenty':2,'keep':1,'pluck':0,'snack':0}
TAGS = {'hurt':{'-','quick','heavy','pierce','poison','trip','bash'},'guard':{'-','hold','evade','thorns','mend','keep'},'heal':{'-','simmer','plenty'},
        'charm':{'-','hum','lull','bond'},'soothe':{'-','keep'},'trick':{'-','pluck'},'item':{'-','snack','plenty'}}
MODS = {'hurt':{'leech','warm','finisher','steady','sticky','swift','lucky'},'guard':{'hardy','spiky','sticky','swift','lucky'},'heal':{'tender','soft','sticky','swift','lucky'},
        'charm':{'soft','sticky','swift','lucky'},'soothe':{'sticky','swift','lucky'},'trick':{'sticky','swift','lucky'},'item':{'tender','soft','sticky','swift','lucky'}}
MODTIER = {'sticky':0,'swift':0,'hardy':0,'tender':0,'leech':1,'spiky':1,'soft':1,'warm':2,'finisher':2,'lucky':2,'steady':2}
ADV = {'keep','plenty','bond','lull','simmer'}
def life_of(tag): return 2 if tag=='quick' else 4 if tag=='hold' else 3
TYPE_TXT = {'hurt':'Deals # damage','guard':'Blocks # damage until your next turn','heal':'Heals you #','charm':'Fills its Yield bar with # charm','soothe':'Cuts up to # damage from the creature next turn','trick':'Boosts a Hurt or Guard fired right after it by +#','item':'Heals you #'}
TAG_TXT = {'quick':'Quick: fires first in its chain','heavy':'Heavy: fires last in its chain, then falls away','pierce':'Pierce: ignores its guard','poison':'Poison: hits again for the next 2 turns','trip':'Trip: it skips its next turn','bash':'Bash: adds your guard to the hit','hold':'Hold: the guard stays up one more turn','thorns':'Thorns: a blocked hit pricks it','evade':'Evade: its first hit misses','mend':'Mend: also heals you 2','hum':'Hum: also cuts its next hits by 2','lull':'Lull: it skips its next turn','bond':'Bond: your Charm fills 10% more (up to 3 times)','pluck':'Pluck: small chance to lift its item (once a fight)','snack':'Snack: eats a food item from your satchel','keep':'Keeper: stays in your hand until played','plenty':'Plenty: next round you pick from 6 pieces','simmer':'Simmer: heals 2 at the start of your next 2 turns'}
MOD_TXT = {'sticky':'Sticky: a snug fit also draws you a piece','swift':'Swift: does not count toward a four-piece chain','hardy':'Hardy: +2 guard','tender':'Tender: heals 2 more','leech':'Leech: heals you a little when it hits','spiky':'Spiky: also pricks it for 2 when played','soft':'Soft touch: also calms it (Soothe 2)','warm':'Warm: a quarter of the damage also counts as Charm','finisher':'Finisher: +3 once its Yield bar is past 60%','lucky':'Lucky: one extra redraw this fight','steady':'Steady: a Heavy piece can go anywhere in a chain'}
def tier_of(T): return 0 if T<2 else 0 if T<4 else 1 if T<8 else 2   # mod tier allowed by region index T
def modcap(T): return -1 if T<2 else 0 if T<4 else 1 if T<8 else 2
def price(lv, rar): return int(round(100*(1+lv/10)*{'Common':1,'Uncommon':1.6,'Rare':2.5}[rar]/5)*5)
import random
ART=json.load(open('art.json'))
ADVT={'keep','plenty','bond','lull','simmer'}
HIGH={'hurt':['leech','finisher','warm','steady','sticky','swift','lucky'],'guard':['hardy','spiky','sticky','swift','lucky'],'heal':['tender','soft','sticky','swift','lucky'],
      'charm':['soft','sticky','swift','lucky'],'soothe':['sticky','swift','lucky'],'trick':['sticky','swift','lucky'],'item':['tender','soft','sticky','swift','lucky']}
items=[]; errs=[]; used=set(); stats=collections.Counter()
for T,r in enumerate(ORDER):
    for cat in CATS:
        rows = REG[r][cat]
        if len(rows)!=5: errs.append(f'{r} {cat}: {len(rows)} rows')
        for i,(pn,code,story) in enumerate(rows):
            ty,tag,pmod,pk = code.split(':')
            if tag in ADVT and T<3: tag = {'charm':'hum','hurt':'-'}.get(ty,'-'); stats['tag simplified (early region)']+=1
            if tag!='-' and tag not in TAGS[ty]: errs.append(f'{r}/{cat}/{pn}: tag {tag} on {ty}')
            cap=modcap(T)
            allowed=[m for m in HIGH[ty] if MODTIER[m]<=cap] if i>=2 and cap>=0 else []
            rnd=random.Random(f'{r}{cat}{i}')
            rnd.shuffle(allowed)
            if pmod in allowed: allowed.remove(pmod); allowed.insert(0,pmod)
            want_mod = (i==4 or i==3) and allowed          # Uncommon 4 and Rare 5 carry a knack where the region allows
            if i==2 and allowed and rnd.random()<0.5: want_mod=True
            mods = (allowed if want_mod else ['-']+allowed)
            if not want_mod: mods=['-']
            pref_tag=tag
            tagorder=[pref_tag]+[t for t in sorted(TAGS[ty],key=lambda t:(t in ADVT,TAGCOST[t])) if t!=pref_tag and not (t in ADVT and T<3)]
            if i<2 and T>=4 and cap>=0 and rnd.random()<0.4:
                low=[m for m in HIGH[ty] if MODTIER[m]==0]; rnd.shuffle(low); lowc=low[:1]
            else: lowc=[]
            pick=None
            lowall=[m for m in HIGH[ty] if MODTIER[m]==0] if (i<2 and T>=4) else []
            for tag in tagorder:
                dl=life_of(tag); knobs=[pk]+[k for k in 'bmc' if k!=pk]; lives=[dl]+[l for l in (3,2,4) if l!=dl]
                cand=(mods+['-'] if want_mod else (lowc+['-'] if lowc else mods))
                cand=cand+[m for m in lowall if m not in cand]
                for mod in cand:
                    for life in lives:
                        for kn in knobs:
                            if (ty,tag,mod,kn,life) not in used: pick=(mod,kn,life); break
                        if pick: break
                    if pick: break
                if pick: break
            if tag!=pref_tag: stats['tag swapped for uniqueness']+=1
            if not pick: errs.append(f'{r}/{cat}/{pn}: no unique signature'); continue
            mod,kn,life=pick; used.add((ty,tag,mod,kn,life))
            if life!=dl: stats['life varied']+=1
            if kn!=pk: stats['knob varied']+=1
            v = BASE[ty]-TAGCOST[tag]-(1 if mod!='-' and MODTIER[mod]>=1 else 0)+T//3+(0,0,1,1,2)[i]+(dl-life)
            v = max(2,v); lv=LEVEL[r]; art=ART[f'{r}|{cat}|{i+1}']
            items.append(dict(region=r,regionName=NAME[r],regionLevel=lv,tier=T,cat=cat,n=i+1,rarity=RAR[i],item=art[0],artDesc=art[1],piece=pn,type=ty,tag=tag,mod=mod,knob=kn,life=life,v=v,
                petals=price(lv,RAR[i]),tailor=(1,1,2,2,3)[i],energy=(4,4,5,5,6)[i]))
names=collections.Counter(x['piece'] for x in items)
for n,c in names.items():
    if c>1: errs.append(f'piece name repeated: {n} x{c}')
sig=collections.Counter((x['type'],x['tag'],x['mod']) for x in items)
print('items',len(items),'errors',len(errs),'distinct full signatures',len(used),'distinct (type,tag,knack)',len(sig),dict(stats))
for e in errs[:40]: print(' ERR',e)
if __name__=='__main__': json.dump(items,open('pieces.json','w'),indent=1)
