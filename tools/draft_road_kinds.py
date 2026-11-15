#!/usr/bin/env python3
"""Draft the 2.7.00 road-kind route list for Josh to veto (claude/road-kinds-2.7.00.md). Reads claude/bend-prototype-v2/route-*.json
(the route data the 30x18 Trail maps were baked from). One route per kind per region where the land fits; nothing is written to game data.
  python3 tools/draft_road_kinds.py > claude/road-kinds-2.7.00.md"""
import json, glob, os, re, collections
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LEVELS = {'NA': 1, 'CA': 4, 'NWE': 6, 'CB': 8, 'SE': 10, 'SA': 12, 'EE': 14, 'MENA': 17, 'EA': 20, 'CSA': 23, 'SEA': 26, 'WCA': 29, 'ESA': 32, 'OC': 35}
FALLBACK = {'tunnel': ('desert', 'coast', 'island', 'grassland'), 'pass': ('desert', 'coast', 'grassland'), 'overgrown': ('wetland', 'grassland', 'coast', 'mountain', 'island')}   # a region with no fitting land: the nearest look (rock canyons, sea cliffs, rolling hills; swamp or meadow gone wild)
KINDS = [  # kind, rule, preferred lands (best first), score key
    ('ferry', 'pay 20 Petals per crossing', ('island', 'coast', 'wetland')),
    ('tunnel', 'lantern gate', ('mountain', 'tundra')),
    ('pass', 'staff gate', ('mountain', 'tundra')),
    ('toll', 'pay 10 Petals once per route; safer, faster', ()),
    ('overgrown', '+10 game min per section; axe = none', ('forest', 'rainforest')),
    ('flooded', '+10 game min per section; flood boots +5', ('wetland', 'rainforest', 'coast', 'island')),
]
baked = {}   # the installed 30x18 maps: real water cells ('wet' grids) and the gates the game really has
for f in glob.glob(os.path.join(R, 'game/includes/data/trail_maps/*_30x18.json')):
    for rid, r in json.load(open(f))['routes'].items(): baked[int(rid)] = r
routes = []
for f in sorted(glob.glob(os.path.join(R, 'claude/bend-prototype-v2/route-*.json'))):
    d = json.load(open(f))
    b = baked.get(int(d['route_id']), {'sections': []})
    water = sum(row.count('1') for s in b['sections'] for row in (s.get('wet') or []))
    gated = any(s.get('gates') for s in b['sections']) or any(s.get('gates') for s in d['sections'])
    routes.append(dict(id=int(d['route_id']), a=d['from'], b=d['to'], land=d['land'], reg=d['region'], pk=d['path_kind'], boss=bool(d.get('boss')),
                       n=len(d['sections']), water=water, gated=gated, minis=sum(1 for s in d['sections'] if s.get('extra_minibosses'))))
def fb(r, kind): return ' (different land: nothing ' + ('mountain here' if kind != 'overgrown' else 'wooded here') + ')' if any(l == r['land'] for l in FALLBACK.get(kind, ())) else ''
def tier(reg): return 2 if LEVELS[reg] <= 12 else 3   # staff / lantern stop at tier 3 (Fine); NA and the early regions Sturdy
def score(r, kind, lands):
    s = 0
    if r['land'] in lands: s += 10 - lands.index(r['land']) * 2
    elif r['land'] in FALLBACK.get(kind, ()): s += 4 - FALLBACK[kind].index(r['land'])
    if kind in ('ferry', 'flooded'): s += min(12, r['water'] // 25) if r['water'] else -8   # no water on the map, no ferry or flood
    if kind == 'toll': s += 6 if r['pk'] == 'road' else 0; s += 3 if re.search(r'Market|Bazaar|Fair|Port|Harbo', r['a'] + ' ' + r['b']) else 0
    if kind in ('tunnel', 'pass'): s += 2 if r['pk'] == 'trail' else 0
    if r['gated']: s -= 6      # already has a tool gate: do not stack
    if r['boss']: s -= 20      # boss lairs keep their own rules
    if r['pk'] == 'exit' and kind not in ('ferry', 'pass'): s -= 5
    if r['n'] < 2: s -= 3
    return s
used = set(); out = collections.defaultdict(list)
for reg in LEVELS:
    pool = [r for r in routes if r['reg'] == reg]
    for kind, rule, lands in KINDS:
        best = sorted((r for r in pool if r['id'] not in used), key=lambda r: (-score(r, kind, lands), r['id']))
        pick = next((r for r in best if (not lands or r['land'] in lands or r['land'] in FALLBACK.get(kind, ())) and score(r, kind, lands) > 0), None)
        if pick is None: out[reg].append((kind, rule, None)); continue
        used.add(pick['id']); out[reg].append((kind, rule, pick))
print('# Road kinds 2.7.00: draft route list (veto me)\n')
print('Draft by `tools/draft_road_kinds.py` from the route data (`claude/bend-prototype-v2/`). Nothing is in the game yet. Kinds and rules: `claude/plan-2.7.00.md` item 5. One route per kind per region where the land fits (`-` = no fitting route: say if you want a pick anyway). **Tier** is for tunnel (lantern) and pass (staff) only: Sturdy (2) up to region level 12, Fine (3) after (those tools stop at tier 3). A route keeps one kind. Routes that already have a tool gate or a boss are skipped.\n')
print('Veto: strike a row, or write the route id you want instead.\n')
print('| Region (lvl) | Route | From to | Land | Path | Kind | Rule | Tier | Why |\n|---|---|---|---|---|---|---|---|---|')
tot = 0
for reg in LEVELS:
    for kind, rule, r in out[reg]:
        if r is None: print(f'| {reg} ({LEVELS[reg]}) | - | - | - | - | {kind} | {rule} | - | no fitting route |'); continue
        tot += 1
        t = str(tier(reg)) if kind in ('tunnel', 'pass') else '-'
        why = {'ferry': f"{r['water']} water cells over {r['n']} sections", 'tunnel': f"{r['land']} route, {r['n']} sections" + fb(r, kind), 'pass': f"{r['land']} route, {r['n']} sections" + fb(r, kind),
               'toll': f"{r['pk']} between {'markets/ports' if re.search(r'Market|Bazaar|Fair|Port|Harbo', r['a'] + r['b']) else 'villages'}", 'overgrown': f"{r['land']} route, {r['n']} sections" + fb(r, kind),
               'flooded': f"{r['water']} water cells, {r['land']}"}[kind]
        print(f"| {reg} ({LEVELS[reg]}) | {r['id']} | {r['a']} to {r['b']} | {r['land']} | {r['pk']} | {kind} | {rule} | {t} | {why} |")
print(f'\n{tot} routes picked of {len(routes)}.')
