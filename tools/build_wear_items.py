#!/usr/bin/env python3
"""Build the data files of the 280 Tailor wearables from the design (claude/wear-pieces/):
  game/includes/data/wear_items.txt         one row per item: what it is, its region, the Tailor fee and level, energy, materials
  game/includes/data/wear_items_pieces.txt  its piece: the catalog row of claude/wear-pieces/wear_pieces.txt, copied as is (fx|a|b carried for the engine)
Materials: the two local materials of the item's region (game/includes/data/region_locals.txt, both gatherables): Common 2+1, Uncommon 3+2, Rare 4+3 (+ 1 any-hide, a creature part).
usage: python3 tools/build_wear_items.py   (rewrites both files; same input, same output)
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'claude/wear-pieces')
DATA = os.path.join(ROOT, 'game/includes/data')
MATS = {'Common': (2, 1), 'Uncommon': (3, 2), 'Rare': (4, 3)}


def locals_of():
    out = {}
    for line in open(os.path.join(DATA, 'region_locals.txt'), encoding='utf-8'):
        line = line.strip()
        if line and not line.startswith('#'):
            c = [x.strip() for x in line.split('|')]
            out[c[0]] = (c[1], c[2])
    return out


def main():
    pieces = json.load(open(os.path.join(SRC, 'pieces.json'), encoding='utf-8'))
    loc = locals_of()
    rows = ['# Tailor wearables (280): built by tools/build_wear_items.py from claude/wear-pieces/pieces.json. Read by includes/wearables.php (wear_defs).',
            '# slug|region|category|n|rarity|name|petals (Common fee; Lined x1.5, Fine x2.5)|tailor level|energy|materials (slug:qty,...)|description',
            '# Made only at the Tailor, once the gnome has reached the region\'s level (REGION_LEVELS). One piece each (no cuts); its row is in wear_items_pieces.txt.']
    for p in pieces:
        a, b = loc[p['region']]; na, nb = MATS[p['rarity']]
        mats = '%s:%d,%s:%d' % (a, na, b, nb) if a != b else '%s:%d' % (a, na + nb)
        if p['rarity'] == 'Rare':
            mats += ',any-hide:1'   # 2.7.58 creature parts: a Rare piece also takes one Hide part of any kind
        cells = [p['slug'], p['region'], p['cat'], str(p['n']), p['rarity'], p['item'], str(p['petals']), str(p['tailor']), str(p['energy']), mats, p['artDesc']]
        assert all('|' not in c for c in cells), p['slug']
        rows.append('|'.join(cells))
    open(os.path.join(DATA, 'wear_items.txt'), 'w', encoding='utf-8').write('\n'.join(rows) + '\n')
    cat = ['# the pieces of the Tailor wearables (wear_items.txt): copied from claude/wear-pieces/wear_pieces.txt by tools/build_wear_items.py. Read by includes/wearables.php.',
           '# key|name|source|ref|type|v|knob|tag|life|rarity|blurb|mod|fx|a|b   (pf_pieces.txt columns + fx|a|b: the effect code and its {a} {b} numbers, see claude/wear-pieces/design3.py)']
    for line in open(os.path.join(SRC, 'wear_pieces.txt'), encoding='utf-8'):
        line = line.rstrip('\n')
        if line.strip() and not line.startswith('#'):
            cat.append(line)
    open(os.path.join(DATA, 'wear_items_pieces.txt'), 'w', encoding='utf-8').write('\n'.join(cat) + '\n')
    print('wear_items.txt %d rows, wear_items_pieces.txt %d rows' % (len(rows) - 3, len(cat) - 2))


if __name__ == '__main__':
    main()
