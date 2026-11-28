#!/usr/bin/env python3
"""Write game/includes/data/stop_perks.txt (the lasting-marks catalogue read by game/includes/stop_marks.php): all 540 perks.

    python3 claude/tools_export_stop_perks.py                         # stop names only (loc slug column '-')
    python3 claude/tools_export_stop_perks.py --db game/data/game.sqlite   # also fills the location slug; lists unmatched stops

Sources: the four perk files through tools_audit_stop_perks.parse_all() (the audit's corrections are already in those files),
claude/proposal-perk-impact.csv (impact estimate, value points per game day). Stop types of the Maplewold set come from the
"Stop | Type | Why" table of proposal-stop-perks.md section 5; the region files carry a Type column.

Row: key | region | stop | loc slug | type | bar | icon | name | effect | family | class | scope | size | impact
- key: the perk name as a slug (unique; stored in stop_marks.perk_key, so it never changes once shipped)
- class: W world, P place, D daily charge, F flag
- scope: '/'-separated key=value list in the act "when" grammar (stop_marks.php MARK_SCOPE_KEYS); '-' = none.
  `here` as a value = the perk's own stop. trig= (daily charges) and page= (flags) say where a hook goes.
- size: the number in the family's unit, sign = direction (-2 = 2% less walk time); daily charges 1, A4 its coins, flags 0
"""
import csv
import os
import re
import sqlite3
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tools_audit_stop_perks as A   # noqa: E402

ROOT = os.path.dirname(A.CL)
OUT = os.path.join(ROOT, 'game', 'includes', 'data', 'stop_perks.txt')
F_CSV = os.path.join(A.CL, 'proposal-perk-impact.csv')
LANDS = ('forest', 'grassland', 'coast', 'mountain', 'desert', 'wetland', 'tundra', 'island', 'rainforest')
BAD_WEATHER = 'rain,storm,snow,frost,fog,wind'

# The Maplewold set has no Scope column: the conditions of its numeric perks, written from section 5's effect text.
MAIN_SCOPE = {
    'The Straightened Signpost': 'region=NA/land=forest,grassland,wetland',
    'Second Breakfast': 'dp=dawn,day/group=homecooked',
    'A Bed With Your Name On': 'type=inn',
    'Tidy Skeps': 'group=flower,herb,fruit',
    'Honey in the Tea': 'group=tea,drink,sweet',
    'Greased Wheel': 'group=grain',
    "Miller's Pinch": 'items=oats,lentil,soybean,kidney-bean',
    'Dry Woodpile': 'group=trail',
    "Squirrel's Arithmetic": 'land=forest,grassland',
    'Sawdust Mulch': 'we=sun,cloud,heat,wind',
    'Sound Nets': 'group=energy',
    'Catch of the Day': 'group=fish,find,dish',
    'Beacon Basket, Refilled': 'region=NA',
    "Watcher's Flask": 'we=' + BAD_WEATHER,
    'Scrubbed Pools': 'type=spring',
    'Warm to the Bones': 'we=' + BAD_WEATHER,
    "This Year's Stone": 'region=NA/land=mountain,tundra',
    'Goat-Track Pickings': 'region=NA/land=mountain,tundra,coast,wetland',
    'Packed by the Cook': 'group=homecooked',
    'Tailwind': 'we=wind,storm,rain,snow,frost,fog',
    'Hop-Yard Hum': 'group=food,drink',
    'Stacked Birch': 'group=syrup,sweet,preserve,drink',
    'Brim-Full Bucket': 'group=regrow',
    'Oatcake for the Road': 'at=here',
    'Spring-Boiled Egg': 'at=here',
}
GROUP_WORDS = {   # effect words -> item group (region files; families that act on a kind of item)
    'fish': 'fish', 'tea': 'tea', 'teas': 'tea', 'soup': 'soup', 'soups': 'soup', 'stew': 'stew', 'stews': 'stew',
    'bread': 'bread', 'breads': 'bread', 'bakes': 'bake', 'syrup': 'syrup', 'syrups': 'syrup', 'sweets': 'sweet',
    'spices': 'spice', 'dried': 'dried', 'pickles': 'pickle', 'preserves': 'preserve', 'juices': 'juice', 'drinks': 'drink',
    'egg': 'egg', 'flowers': 'flower', 'seeds': 'seed', 'tools': 'tool',
}
GROUP_FAMS = {'F01', 'F02', 'F06', 'F07', 'F08'}


PLACE_KEYS = {'region', 'items', 'from', 'to', 'at', 'delve'}


def place_key(p):
    """A place perk whose Scope cell names no place: its delve (torch), else from / to / at its own stop."""
    m = re.search(r'torch step in (?:the )?(.+)$', p.effect)
    if p.fam == 'F21' and m:
        return 'delve=' + slug(m.group(1))
    k = A.scope_keys(p) & {'from', 'to'}
    return (sorted(k)[0] if k else 'at') + '=here'


def slug(s):
    return re.sub(r'[^a-z0-9]+', '_', s.lower().replace("'", '').replace('’', '')).strip('_')[:40]


def main_types():
    sec = A.read(A.F_MAIN).split('## 5.', 1)[1]
    out = {}
    for ln in sec.splitlines():
        c = A.cells(ln) if ln.startswith('| ') else []
        if len(c) == 3 and c[1] in ('market', 'mill', 'inn', 'shrine', 'jetty', 'herb', 'workshop', 'orchard', 'ferry', 'tower', 'spring', 'camp'):
            out[A.norm_stop(re.sub(r'\s*\(NEW\)', '', c[0]))] = c[1]
    return out


def size_num(p):
    s = p.size.strip()
    if p.cls == 'F':
        return '0'
    if p.fam == 'A4':
        m = re.match(r'(\d+)\s*coin', s)
        return m.group(1) if m else '1'
    if p.cls == 'D':
        return '1'
    m = re.match(r'([+-]?)(\d+)', s)
    if not m:
        raise SystemExit(f'no size: {p.name} {s!r}')
    return ('-' if m.group(1) == '-' else '') + m.group(2)


def scope_of(p):
    parts = []
    if p.file == A.F_MAIN:
        if p.name in MAIN_SCOPE:
            parts.append(MAIN_SCOPE[p.name])
    else:
        txt = p.scope
        crops = re.search(r'items=local:`?\s*([a-z0-9, -]+)', txt)
        for k, v in re.findall(r'`?([a-z]+)=([^`\s]*)`?', txt):
            if k == 'items':
                continue
            parts.append(f'{k}={v or "here"}')
        if crops:
            parts.append('items=' + ','.join(x.strip() for x in crops.group(1).split(',') if x.strip()))
        elif p.cls in ('P', 'D') and A.crop_scoped(p):
            parts.append('items=' + ','.join(sorted(A.crops_in(p.effect, p.region))))
        if p.cls == 'D' and re.search(r'\bhere\b', txt):
            parts.append('at=here')
        if any(x.startswith('region=') for x in parts) and not any(x.startswith('land=') for x in parts):
            lands = [w for w in LANDS if re.search(r'\b' + w + r'\b', p.effect.lower())]
            if lands:
                parts.append('land=' + ','.join(lands))
        if p.fam in GROUP_FAMS:
            groups = sorted({g for w, g in GROUP_WORDS.items() if re.search(r'\b' + w + r'\b', p.effect.lower())})
            if groups:
                parts.append('group=' + ','.join(groups))
        for k, rx in (('we', r'\b(rain|rainy|wind|windy|snow|snows|frost|fog|heat|hot|sunny|storm)\b'), ('dp', r'\b(dawn|dusk|night|by day)\b')):
            if not any(x.startswith(k + '=') for x in parts):
                found = sorted({re.sub(r'(y|s)$', '', m).replace('by day', 'day').replace('hot', 'heat').replace('sunn', 'sun')
                                for m in re.findall(rx, p.effect.lower())})
                if found and p.cls != 'F':
                    parts.append(f'{k}=' + ','.join(found))
        if p.cls == 'P' and not any(x.split('=')[0] in PLACE_KEYS for x in parts):
            parts.append(place_key(p))
    if p.cls == 'D':
        trig = A.trigger_of(p)[0]
        parts.append('trig=' + slug(trig or 'other'))
    if p.cls == 'F':
        parts.append('page=' + slug(A.ui_of(p)[0]))
    return '/'.join(parts) or '-'


def main():
    db = None
    if '--db' in sys.argv:
        db = sqlite3.connect(sys.argv[sys.argv.index('--db') + 1])
    perks = A.parse_all()
    if A.errors or len(perks) != 540:
        raise SystemExit(f'audit parse: {len(perks)} perks, errors {A.errors[:3]}')
    impact = {}
    with open(F_CSV, encoding='utf-8') as f:
        for r in csv.DictReader(f):
            impact[r['id']] = r['value_points']
    types = main_types()
    locs = {}
    if db:
        for s, n in db.execute("SELECT slug, name FROM locations WHERE kind IN ('village', 'market', 'haven')"):
            locs[A.norm_stop(n).lower()] = s
    keys, rows, unmatched = set(), [], set()
    for p in perks:
        k = slug(p.name)
        if k in keys:
            raise SystemExit(f'duplicate key {k}')
        keys.add(k)
        typ = p.type or types.get(p.stop, '')
        if not typ:
            raise SystemExit(f'no stop type for {p.stop}')
        imp = impact.get(f'{p.region}:{p.stop}:{p.bar}')
        if imp is None:
            raise SystemExit(f'no impact row for {p.region}:{p.stop}:{p.bar}')
        loc = locs.get(p.stop.lower(), '-') if db else '-'
        if db and loc == '-':
            unmatched.add(f'{p.stop} ({p.region})')
        rows.append([k, p.region, p.stop, loc, typ, p.bar.lower(), p.icon, p.name, p.effect.replace('|', '/').replace('`', ''),
                     p.fam, p.cls, scope_of(p), size_num(p), imp])
    with open(OUT, 'w', encoding='utf-8') as f:
        f.write('# Generated by claude/tools_export_stop_perks.py from the four proposal-stop-perks*.md files: do not edit by hand.\n'
                '# Lasting marks (stop_marks.php): 180 stops x 3 bars = 540 perks. Impact = value points per game day (proposal-perk-impact.csv).\n'
                '# key | region | stop | loc slug (- = matched by name) | stop type | bar | icon | name | effect | family | class W/P/D/F | scope | size | impact\n')
        for r in rows:
            f.write(' | '.join(r) + '\n')
    print(f'{len(rows)} perks -> {os.path.relpath(OUT, ROOT)}')
    if db:
        print('unmatched stops (matched by name at run time once they exist): ' + (', '.join(sorted(unmatched)) or 'none'))


if __name__ == '__main__':
    main()
