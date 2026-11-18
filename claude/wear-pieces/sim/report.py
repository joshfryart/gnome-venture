#!/usr/bin/env python3
"""Markdown tables for balance.md from two agg.py summaries (before, after) and the two pieces.json.
usage: python3 report.py BEFORE.json AFTER.json PIECES_BEFORE.json PIECES_AFTER.json > tables.md"""
import json, sys, statistics as st
ORDER = ['NA','CA','NWE','CB','SE','SA','EE','MENA','EA','CSA','SEA','WCA','ESA','OC']
LV = dict(zip(ORDER, [1,4,6,8,10,12,14,17,20,23,26,29,32,35]))
B0, B1 = (json.load(open(f)) for f in sys.argv[1:3]); P0, P1 = ({p['slug']: p for p in json.load(open(f))} for f in sys.argv[3:5])
S0, S1 = B0['pieces'], B1['pieces']
m = lambda g, k: st.mean(o[k] for o in g) if g else float('nan')
out = []
def p(s=''): out.append(s)

p('### Baseline (no wear piece)\n\n| region | level | careful win % | careful health lost % | careful turns | careless win % | careless health lost % | careless turns |\n|---|---|---|---|---|---|---|---|')
for r in ORDER:
    a, b = B1['base'][f'look|{r}'], B1['base'][f'greedy|{r}']
    p(f"| {r} | {LV[r]} | {a['win']:.1f} | {a['hp']:.1f} | {a['turns']:.1f} | {b['win']:.1f} | {b['hp']:.1f} | {b['turns']:.1f} |")

for rank, rars, title in ((1, ('Common', 'Uncommon', 'Rare'), 'Common rank (every piece)'), (3, ('Rare',), 'Fine rank (+4), the Rares')):
    p(f'\n### Per region, {title}: mean delta against the baseline, after the changes (before in brackets)\n')
    p('est = smoothed piece + effect (points; health: negative = less lost). eff = the effect alone. play = share of fights the piece was placed.\n')
    p('| region | rarity | n | est win | est health | eff win | eff health | play |\n|---|---|---|---|---|---|---|---|')
    for r in ORDER:
        for rar in rars:
            g1 = [o for o in S1.values() if o['rank'] == rank and o['reg'] == r and o['rar'] == rar]
            g0 = [o for o in S0.values() if o['rank'] == rank and o['reg'] == r and o['rar'] == rar]
            if not g1: continue
            p(f"| {r} | {rar} | {len(g1)} | {m(g1,'est_win'):+.1f} ({m(g0,'est_win'):+.1f}) | {m(g1,'est_hp'):+.1f} ({m(g0,'est_hp'):+.1f}) | {m(g1,'ewin'):+.1f} ({m(g0,'ewin'):+.1f}) | {m(g1,'ehp'):+.2f} ({m(g0,'ehp'):+.2f}) | {m(g1,'play'):.2f} |")
    p('\nBy region band (mean of the regions), effect alone in health points, after (before):\n')
    for band, regs in (('NA-SE (1-10)', ORDER[:5]), ('SA-CSA (12-23)', ORDER[5:10]), ('SEA-OC (26-35)', ORDER[10:])):
        line = []
        for rar in rars:
            g1 = [o for o in S1.values() if o['rank'] == rank and o['reg'] in regs and o['rar'] == rar]; g0 = [o for o in S0.values() if o['rank'] == rank and o['reg'] in regs and o['rar'] == rar]
            line.append(f"{rar} {m(g1,'ehp'):+.2f} ({m(g0,'ehp'):+.2f})")
        p(f"- {band}: " + ', '.join(line))

def row(o, P):
    q = P[o['slug']]
    return f"| {o['slug']} | {o['reg']} | {o['rar']} | {o['type']} | `{o['code']}` | {q['v']}/{q['a']}/{q['b']} | {o['est_win']:+.1f} | {o['est_hp']:+.1f} | {o['ewin']:+.1f} | {o['ehp']:+.2f} | {o['play']:.2f} |"
hdr = '| piece | region | rarity | type | fx | v/a/b | est win | est health | eff win | eff health | play |\n|---|---|---|---|---|---|---|---|---|---|---|'
for rank, lab in ((1, 'Common rank'), (3, 'Fine rank (Rares)')):
    g = [o for o in S1.values() if o['rank'] == rank]
    p(f'\n### Outliers after the changes, {lab}\n\nStrongest 15 (by est health, most health saved):\n\n' + hdr)
    for o in sorted(g, key=lambda o: o['est_hp'])[:15]: p(row(o, P1))
    p('\nStrongest 15 by est win:\n\n' + hdr)
    for o in sorted(g, key=lambda o: -o['est_win'])[:15]: p(row(o, P1))
    p('\nWeakest 15 (by the effect alone, health; positive = the effect costs health):\n\n' + hdr)
    for o in sorted(g, key=lambda o: -o['ehp'])[:15]: p(row(o, P1))

p('\n### Before / after of every piece whose numbers changed (v/a/b; effect alone at Common, Rares also at Fine)\n')
p('| piece | region | rarity | fx | v/a/b before | after | eff health before | after | eff win before | after | Fine eff health before | after |\n|---|---|---|---|---|---|---|---|---|---|---|---|')
for s, q1 in P1.items():
    q0 = P0[s]
    if (q0['v'], q0['a'], q0['b']) == (q1['v'], q1['a'], q1['b']): continue
    o0, o1 = S0.get(f'{s}@1'), S1.get(f'{s}@1'); f0, f1 = S0.get(f'{s}@3'), S1.get(f'{s}@3')
    fine = f"{f0['ehp']:+.2f} | {f1['ehp']:+.2f}" if f0 and f1 else ' | '
    p(f"| {s} | {q1['region']} | {q1['rarity']} | `{q1['code']}` | {q0['v']}/{q0['a']}/{q0['b']} | {q1['v']}/{q1['a']}/{q1['b']} | {o0['ehp']:+.2f} | {o1['ehp']:+.2f} | {o0['ewin']:+.1f} | {o1['ewin']:+.1f} | {fine} |")
print('\n'.join(out))
