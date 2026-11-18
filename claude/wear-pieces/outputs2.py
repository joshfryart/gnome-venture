import json, glob, os
IT=json.load(open('pieces.json'))
ORDER=['NA','CA','NWE','CB','SE','SA','EE','MENA','EA','CSA','SEA','WCA','ESA','OC']; CATS=['footwear','backpack','coat','cloak']
ART='/home/user/gnome-venture/aseprite-source/v3/art-wear-concepts'; FAM={'b':'body','m':'mind','c':'craft'}
for x in IT: x['slug']=x['region'].lower()+'-'+os.path.basename(glob.glob(f"{ART}/{x['region']}/{x['cat']}-{x['n']}-*.png")[0])[len(x['cat'])+3:-4]
L=['# Wearable puzzle pieces v2: unique effects (280)','',
 'Every effect is its own trigger + payoff pair (210 Common/Uncommon) or a hand-written rule (70 Rare). No effect repeats. These need new engine support (triggers and payoffs below); nothing is installed in `game/`.','',
 '**Value** is the piece base (the game adds stat, level/3 and rank: Lined +2, Fine +4). **Petals** = Tailor price of the Common rank; Lined x1.5, Fine x2.5. **Tailor** = lowest Tailor level that can craft it. Numbers inside effects ({a}, {b}) grow with region and rarity.','']
for r in ORDER:
    rows=[x for x in IT if x['region']==r]; L+=[f"## {rows[0]['regionName']} ({r}, region level {rows[0]['regionLevel']})",'']
    for cat in CATS:
        L+=[f"### {cat.title()}",'','| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |','|---|---|---|---|---|---|---|---|---|']
        for x in [y for y in rows if y['cat']==cat]:
            L.append(f"| {x['n']} | {x['item']} | {x['rarity']} | **{x['piece']}** | {x['type']} | {x['v']} | {x['effect']} | {x['petals']} | {x['tailor']} |")
        L.append('')
open('pieces.md','w').write('\n'.join(L))
D=['# Wearable pieces v2 (280): key|name|source|ref|type|v|knob|tag|life|rarity|blurb|mod|fx   fx = unique effect code (needs engine support; see design2.py TRIG/PAY and the Rare texts)']
for x in IT: D.append('|'.join([f"w:{x['slug']}",x['piece'],'wear',x['slug'],x['type'],str(x['v']),FAM[x['knob']],'-','-','src',f"{x['item']}: {x['effect']}",'-',x['code']]))
open('wear_pieces.txt','w').write('\n'.join(D)+'\n'); json.dump(IT,open('pieces.json','w'),indent=1); print('ok')
