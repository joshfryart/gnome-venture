#!/usr/bin/env python3
"""Lint a draft of road cards (E/O rows of road_events.txt, v2.0.79 kinds).
Usage: tools/lint_road_events.py DRAFT.txt ITEM_SLUGS.txt [--region NA] [--prefix na_]
Checks: columns, unique ids (also against shipped road_events.txt), kind rules (riddle one right answer, fork two ways, trade has a decline, chain targets exist,
sketch has journal:ID and a name), effects, real item slugs, curly apostrophes, no |, lands/where/region, text lengths."""
import re, sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
SHIPPED = os.path.join(HERE, '..', 'game', 'includes', 'data', 'road_events.txt')
LANDS = {'forest','grassland','coast','mountain','desert','rainforest','wetland','tundra','island','any'}
STATS = {'grit','nimble','hardiness','lore','sense','charm','luck'}
REGIONS = {'NA','CA','CB','SA','NWE','SE','EE','MENA','WCA','ESA','CSA','EA','SEA','OC'}
KINDS = {'choice','fork','riddle','trade','chain','sketch'}
FX = {'xp','coins','item','rand','energy','buff','heal','hp','pay','take','next','skip','journal','landmark'}
def opt(n): return sys.argv[sys.argv.index(n) + 1] if n in sys.argv else ''
def parse(path):
    ev = []; cur = None
    for l in open(path, encoding='utf-8'):
        l = l.rstrip('\n')
        if not l.strip() or l.startswith('#'): continue
        f = l.split('|')
        if f[0] == 'E': cur = {'f': f, 'opts': []}; ev.append(cur)
        elif f[0] == 'O' and cur is not None: cur['opts'].append(f)
    return ev
def main():
    draft, slugs = sys.argv[1], sys.argv[2]
    items = {l.split('|')[0] for l in open(slugs, encoding='utf-8') if l.strip()}
    rc, prefix = opt('--region'), opt('--prefix')
    ship = {e['f'][1] for e in parse(SHIPPED)}
    evs = parse(draft)
    ids = {e['f'][1] for e in evs} | ship
    bad = []; seen = set()
    for e in evs:
        f = e['f']
        i = f[1] if len(f) > 1 else '?'
        def err(m): bad.append(f'{i}: {m}')
        if len(f) < 10: err(f'{len(f)} columns (need 10: ... text|kind|name)'); continue
        _, id_, cond, lands, region, where, icon, text, kind, name = f[:10]
        if not re.fullmatch(r'[a-z0-9-]{3,40}', id_): err('id format (a-z 0-9 -)')
        if id_ in seen or id_ in ship: err('duplicate id')
        seen.add(id_)
        if prefix and not (id_.startswith(prefix) or id_.startswith('chain-' + prefix)): err(f'id must start with {prefix} (or chain-{prefix})')
        if not re.fullmatch(r'-|(dp|se|we)=[a-z,]+(/(dp|se|we)=[a-z,]+)*|!(dp|se|we)=[a-z,]+(/(dp|se|we)=[a-z,]+)*', cond): err(f'cond {cond}')
        if any(x.strip() not in LANDS for x in lands.split(',')): err(f'lands {lands}')
        rg = [x.strip() for x in region.split(',')]
        if any(x not in REGIONS for x in rg) or (rc and rg != [rc]): err(f'region {region}')
        if where not in ('road', 'both'): err('where must be road or both')
        if not icon: err('icon')
        if kind not in KINDS: err(f'kind {kind}')
        if not 40 <= len(text) <= 300: err('text 40-300 chars')
        for t in (text, name) + tuple(o[1] for o in e['opts']):
            if "'" in t: err('straight apostrophe')
        o = e['opts']
        if not 1 <= len(o) <= 3: err('1-3 options'); continue
        for x in o:
            if len(x) < 8: err(f'option has {len(x)} columns'); continue
            label, stat, dc, win, wt, lose, lt = x[1:8]
            if stat not in ('', '!') and stat not in STATS: err(f'stat {stat}')
            if stat in STATS and not (8 <= int(dc or 0) <= 15): err('dc 8-15')
            if len(label) > 48: err('option label over 48')
            for fx in (win, lose):
                for part in [p for p in fx.split('+') if p]:
                    p = part.split('@')[0]; k = p.split(':')[0]
                    if k not in FX: err(f'effect {k}'); continue
                    if k in ('item', 'take') and p.split(':')[1] not in items: err(f'item {p.split(":")[1]} missing')
                    if k == 'next' and p.split(':')[1] not in ids: err(f'next target {p.split(":")[1]} missing')
                    if k == 'rand' and p.split(':')[1] not in ('forage', 'uncommon', 'food'): err('rand kind')
            if stat != '' and stat != '!' and not lt: err('rolled option needs a lose text')
            if win and not wt: err('option needs a win text')
        stats_ = [x[2] for x in o if len(x) >= 8]
        wins = [x[4] for x in o if len(x) >= 8]
        if kind == 'riddle':
            if len(o) != 3 or sum(1 for s in stats_ if s != '!') != 1: err('riddle: 3 options, exactly one right (the others stat !)')
        if kind == 'fork':
            if not 2 <= len(o) <= 3: err('fork: 2-3 ways')
            if not any('skip:' in w for w in wins) and not any(x[2] in STATS for x in o): err('fork needs a short way (skip:N) or a rolled way')
        if kind == 'trade':
            if not any('take:' in w or 'pay:' in w for w in wins): err('trade needs a take: or pay: option')
            if not any(w == '' for w in wins): err('trade needs a decline option with no effect')
        if kind == 'chain':
            if not any('next:' in w or 'next:' in x[6] for x, w in zip(o, wins)) and not id_.startswith('chain-'): err('chain: first card needs a next: effect')
        if kind == 'sketch':
            if len(o) != 1 or f'journal:{id_}' not in o[0][4] or not name: err('sketch: one option, win has journal:<own id>, name column set')
        if id_.startswith('chain-') and kind != 'chain' and kind != 'choice' and kind != 'riddle' and kind != 'fork' and kind != 'trade': err('bad kind for a chain card')
    # every chain: a first card reaches a chain- card
    nexts = {p.split(':')[1] for e in evs for x in e['opts'] if len(x) >= 8 for fx in (x[4], x[6]) for p in fx.split('+') if p.startswith('next:')}
    for e in evs:
        if e['f'][1].startswith('chain-') and e['f'][1] not in nexts: bad.append(f"{e['f'][1]}: a chain- card nothing leads to")
    print(f'{len(evs)} cards, {len(bad)} problems')
    for b in bad: print('  ' + b)
    sys.exit(1 if bad else 0)
main()
