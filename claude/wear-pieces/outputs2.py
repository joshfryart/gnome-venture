import json, glob, os
IT=json.load(open('pieces.json'))
ORDER=['NA','CA','NWE','CB','SE','SA','EE','MENA','EA','CSA','SEA','WCA','ESA','OC']; CATS=['footwear','backpack','coat','cloak']
ART='/home/user/gnome-venture/aseprite-source/v3/art-wear-concepts'; FAM={'b':'body','m':'mind','c':'craft'}
for x in IT:
    x['slug']=x['region'].lower()+'-'+os.path.basename(glob.glob(f"{ART}/{x['region']}/{x['cat']}-{x['n']}-*.png")[0])[len(x['cat'])+3:-4]
    for k in ('a','b'): x[k]=x.pop(k)   # a, b after slug (the file's key order)
L=['# Wearable puzzle pieces v2: unique effects (280)','',
 'Written against the 2.7.00 quick rules (fixed rank order, a placed piece always touches and fits a neighbour, one piece a turn, Keeper only on Guards). No effect talks about firing order or a lone piece. Each is its own trigger + payoff pair (210) or a hand-written rule (70 Rare). Needs new engine support (`design3.py` TRIG/PAY); nothing is installed in `game/`.','',
 '**Value** is the piece base (the game adds stat, level/3 and rank: Lined +2, Fine +4). **Petals** = Tailor price of the Common rank; Lined x1.5, Fine x2.5. **Tailor** = lowest Tailor level that can craft it. Numbers inside effects ({a}, {b}) grow with region and rarity.','']
for r in ORDER:
    rows=[x for x in IT if x['region']==r]; L+=[f"## {rows[0]['regionName']} ({r}, region level {rows[0]['regionLevel']})",'']
    for cat in CATS:
        L+=[f"### {cat.title()}",'','| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |','|---|---|---|---|---|---|---|---|---|']
        for x in [y for y in rows if y['cat']==cat]:
            L.append(f"| {x['n']} | {x['item']} | {x['rarity']} | **{x['piece']}** | {x['type']} | {x['v']} | {x['effect']} | {x['petals']} | {x['tailor']} |")
        L.append('')
open('pieces.md','w').write('\n'.join(L))
D=['# Wearable pieces v2 (280): key|name|source|ref|type|v|knob|tag|life|rarity|blurb|mod|fx|a|b   fx = unique effect code (needs engine support; see design2.py TRIG/PAY and the Rare texts)']
for x in IT: D.append('|'.join([f"w:{x['slug']}",x['piece'],'wear',x['slug'],x['type'],str(x['v']),FAM[x['knob']],'-','-','src',f"{x['item']}: {x['effect']}",'-',x['code'],str(x.get('a','')),str(x.get('b',''))]))
open('wear_pieces.txt','w').write('\n'.join(D)+'\n'); json.dump(IT,open('pieces.json','w'),indent=1); print('ok')
# the engine's data: game/includes/data/wear_fx.txt (design3 TRIG_FX / PAY_FX / ACT / RARE_FX + the texts). The game reads only this file.
from design3 import TRIG, PAY, ACT, TRIG_FX, PAY_FX, RARE_FX, RARE
F=['# Wear piece effects (claude/wear-pieces/design3.py, written by outputs2.py: edit design3.py, then run build3.py and outputs2.py). Read by pfb_wx_data() in includes/pfboard.php and mirrored in tools/pfengine.js.',
 '# A wear piece tile carries fx (the code), fxa and fxb (its two numbers a, b). fx = TRIG>PAY (Common, Uncommon) or R:REGION:category (Rare).',
 '# act|name|phase|step   phase: fire (each firing for you), place (the firing when you place it), hand (at the redraw, in your hand), held (you place another piece while it is in your hand),',
 '#   block (a creature Hurt your guard blocks, until your guard fades), miss (a creature Hurt your Evade made miss). step: pre = changes its own hit, post = after it fired.',
 '# trig|code|conditions|text    pay|code|clause|text    rare|REGION:category|clauses (" ; ")|text',
 '# A clause: tokens, the last is the action (name:arg..., a / b = the piece numbers; act*per^cap multiplies), the others conditions (! = not). @phase: conditions before it are checked when it fires, after it when the phase comes.',
 '# A Common piece is "TRIG PAY" (the trigger goes after @hand / @held). Names of conditions and actions: see pfb_wx_cond / pfb_wx_act.']
for k,(ph,st) in ACT.items(): F.append(f'act|{k}|{ph}|{st}')
for k,v in TRIG_FX.items(): F.append(f'trig|{k}|{v}|{TRIG[k]}')
for k,v in PAY_FX.items(): F.append(f'pay|{k}|{v}|{PAY[k]}')
for (r,c),v in RARE_FX.items(): F.append(f'rare|{r}:{c}|{v}|{RARE[(r,c)]}')
open('../../game/includes/data/wear_fx.txt','w').write('\n'.join(F)+'\n'); print('wear_fx ok', len(F))
