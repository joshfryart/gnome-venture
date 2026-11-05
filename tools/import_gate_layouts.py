#!/usr/bin/env python3
"""Import the gate-view pictures drawn in aseprite-source/v3/here-gate/ into the game: copy each PNG to game/assets/img/scenes/here-<key>.png and add
its layout under <key> in game/includes/data/here_layouts.json (round-trips with json.dumps(indent=1, ensure_ascii=False); never touches other keys).

Keys: town-<region code lower> (main towns; 'hub' = Mossbottom) and stop-<type>-<landscape>_<style> (rest stops). A layout spot has its own 'k' (an id) and an
optional 'as' = the behaviour the Here page gives it (green teahouse board library special1 special2 shops wild homes / do people stop). Several fronts
can share one behaviour. Run from the repo root:  python3 tools/import_gate_layouts.py [--dry]
"""
import json, os, shutil, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.environ.get('GATE_ART') or os.path.join(ROOT, 'aseprite-source/v3/here-gate')
SCENES = os.path.join(ROOT, 'game/assets/img/scenes')
JSON_F = os.path.join(ROOT, 'game/includes/data/here_layouts.json')

# main town art key -> region code (regions.code; verified against catalog.php SEED_SHOP_NAMES and includes/town.php TOWN_FLAVOUR)
TOWNS = {'mossbottom': 'hub', 'maizehollow': 'ca', 'sunsprinkle': 'cb', 'rainroot': 'sa', 'mistmoor': 'nwe', 'olivewhistle': 'se', 'birchbramble': 'ee',
         'dunewhisper': 'mena', 'greatcanopy': 'wca', 'thornacre': 'esa', 'spicepeak': 'csa', 'blossomreach': 'ea', 'monsoontangle': 'sea', 'coralscatter': 'oc'}
TOWN_AS = {'tea': 'teahouse', 's1': 'special1', 's2': 'special2'}
# The Maplewold market (hand-named spots) -> behaviours. special2 (the Beaver Pond) has no front in this picture.
MAPLEWOLD_AS = {'sugar_shack': 'special1', 'pie_bakery': 'shops', 'tavern': 'teahouse', 'town_hall': 'library', 'maple_stalls': 'shops', 'general_store': 'shops',
                'herbalist': 'shops', 'market_square': 'green', 'notice_board': 'board', 'orchard_path': 'wild'}
# rest stop market look spots -> the stop page's behaviours (do = the activities, people = villagers, stop = the rest stop tab)
STOP_AS = {'cottages': 'homes', 'seed': 'do', 'well': 'do', 'pond': 'do', 'table': 'do', 'trail': 'wild', 'notice': 'people', 'rest': 'stop', 'stall': 'do', 'forage': 'do'}
STOPS = {'stop-market-grassland_maplewold': 'pilot-market-grassland_maplewold', 'stop-market-desert_adobe': 'pilot-market-desert_adobe'}

def clean(L, amap):
    o = {k: L[k] for k in ('w', 'h', 'horizon') if k in L}
    o['view'] = 'gate'
    o['spots'] = []
    for s in L['spots']:
        sp = {'k': s['k'], 'x': s['x'], 'y': s['y'], 'name': s['name'], 'box': s['box']}
        a = amap.get(s['k'], s['k'])
        if a != s['k']: sp['as'] = a
        o['spots'].append(sp)
    o['stand'] = L['stand']
    o['compass_clear'] = L.get('compass_clear', [380, 230, 480, 270])
    return o

def resolve_overlaps(o):
    """Hit boxes never overlap (lint rule): where two do, the later one gives way along the axis with the smaller overlap."""
    done = []
    for sp in o['spots']:
        b = sp['box']
        for ob in done:
            if b[0] < ob[2] and b[2] > ob[0] and b[1] < ob[3] and b[3] > ob[1]:
                ox = min(b[2], ob[2]) - max(b[0], ob[0]); oy = min(b[3], ob[3]) - max(b[1], ob[1])
                if ox <= oy:
                    if (b[0] + b[2]) >= (ob[0] + ob[2]): b[0] = ob[2]
                    else: b[2] = ob[0]
                else:
                    if (b[1] + b[3]) >= (ob[1] + ob[3]): b[1] = ob[3]
                    else: b[3] = ob[1]
        done.append(b)
    # stand slots must stay off every hit box (6 units): a slot the art put on a plaza that is also a box is dropped (lint needs 4 or more left)
    keep = []
    for st in o['stand']:
        if all(max(sp['box'][0] - st['x'], 0, st['x'] - sp['box'][2]) ** 2 + max(sp['box'][1] - st['y'], 0, st['y'] - sp['box'][3]) ** 2 >= 36 for sp in o['spots']): keep.append(st)
    if len(keep) >= 4: o['stand'] = keep
    else: print('  WARNING: fewer than 4 clear stand slots, kept all')
    return o

def main():
    dry = '--dry' in sys.argv
    all_ = json.load(open(JSON_F))
    jobs = []   # (key, png, layout json, as-map)
    for art, code in TOWNS.items():
        jobs.append(('town-' + code, f'towns/here-town-{art}.png', f'towns/here-town-{art}.layout.json', TOWN_AS))
    jobs.append(('town-na', 'here-market-maplewold-v5.png', 'here-market-maplewold-v5.layout.json', MAPLEWOLD_AS))
    for key, art in STOPS.items():
        jobs.append((key, art + '.png', 'pilot-market.layout.json', STOP_AS))
    for key, png, lay, amap in jobs:
        src_png = os.path.join(ART, png)
        if not os.path.isfile(src_png):
            print('missing', png); continue
        all_[key] = resolve_overlaps(clean(json.load(open(os.path.join(ART, lay))), amap))
        print(('would add ' if dry else 'added '), key)
        if not dry: shutil.copyfile(src_png, os.path.join(SCENES, 'here-' + key + '.png'))
    if not dry:
        open(JSON_F, 'w').write(json.dumps(all_, indent=1, ensure_ascii=False))

main()
