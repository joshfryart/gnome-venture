#!/usr/bin/env python3
"""Per-piece lines from an agg.py summary.  usage: python3 pieces_table.py SUMMARY.json [RANK=1] [sort key=ehp] [filter rarity]
Columns: est win / hp (smoothed piece + effect), eff win / hp (effect alone, paired), play (share of fights placed), fire/play (effect actions per fight it was placed),
eff/play (health effect per fight it was placed: the strength of the effect when it is used), v a b."""
import json, sys
S = json.load(open(sys.argv[1]))['pieces']; rank = int(sys.argv[2]) if len(sys.argv) > 2 else 1; key = sys.argv[3] if len(sys.argv) > 3 else 'ehp'
rar = sys.argv[4] if len(sys.argv) > 4 else ''
P = {p['slug']: p for p in json.load(open(__file__.rsplit('/', 2)[0] + '/pieces.json'))}
rows = [o for o in S.values() if o['rank'] == rank and (not rar or o['rar'] == rar)]
for o in rows:
    o['fpp'] = o['fire'] / o['play'] if o['play'] else 0.0; o['epp'] = o['ehp'] / o['play'] if o['play'] else 0.0
rows.sort(key=lambda o: o[key])
for o in rows:
    p = P[o['slug']]
    print(f"{o['slug']:32} {o['reg']:4} {o['rar'][:3]} {o['type']:6} {o['code']:18} v{p['v']:<2} a{p['a']} b{p['b']} est {o['est_win']:+5.1f} {o['est_hp']:+6.1f} eff {o['ewin']:+5.1f} {o['ehp']:+6.2f} play {o['play']:.2f} f/p {o['fpp']:4.1f} e/p {o['epp']:+6.1f}")
