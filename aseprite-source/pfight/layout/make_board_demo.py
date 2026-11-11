#!/usr/bin/env python3
"""2D board demo art: strip-size pieces attached on a grid, open sockets left free.
Writes board-demo.png and board-demo.json (piece cells + open sockets) next to this file."""
import json, os, random, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from PIL import Image
from gen_shapes import paint, G, FAM3
OUT = os.path.dirname(os.path.abspath(__file__))
ICO = os.path.join(OUT, '../../../game/assets/img/pfight')
k = 'strip'; W, H, P = G[k]['W'], G[k]['H'], G[k]['P']
# (col,row): (type, owner); a 3x3 board, player = me, creature = foe
cells = {(1, 0): ('guard', 'me'), (0, 1): ('hurt', 'me'), (1, 1): ('trick', 'foe'), (2, 1): ('hurt', 'foe'), (1, 2): ('heal', 'me')}
rnd = random.Random(7)
edges = {c: {s: ('flat', None) for s in 'LRTB'} for c in cells}
opp = {'L': 'R', 'R': 'L', 'T': 'B', 'B': 'T'}
d = {'L': (-1, 0), 'R': (1, 0), 'T': (0, -1), 'B': (0, 1)}
fams = iter(['body', 'mind', 'craft', 'mind', 'body', 'craft'])
open_sockets = []
for c in sorted(cells):
    for s in 'RB':
        n = (c[0] + d[s][0], c[1] + d[s][1])
        if n in cells:
            f, kn = next(fams), rnd.random() < .5
            edges[c][s] = ('knob' if kn else 'hole', f)
            edges[n][opp[s]] = ('hole' if kn else 'knob', f)
for c in sorted(cells):
    for s in 'LRTB':
        n = (c[0] + d[s][0], c[1] + d[s][1])
        if n not in cells and edges[c][s][0] == 'flat' and 0 <= n[0] < 3 and 0 <= n[1] < 3:
            f, kn = rnd.choice(FAM3), rnd.random() < .5
            edges[c][s] = ('knob' if kn else 'hole', f)          # open socket: a free tab or blank waiting for a match
            open_sockets.append({'cell': list(c), 'side': s, 'kind': edges[c][s][0], 'fam': f})
PV = max(6, P * 2 // 3)
cv = Image.new('RGBA', (3 * W + 2 * P, 3 * H + 2 * PV), (0, 0, 0, 0))
for c, (t, o) in cells.items():
    cv.alpha_composite(paint(t, k, edges[c], o, ICO), (c[0] * W, c[1] * H))
cv.save(os.path.join(OUT, 'board-demo.png'))
json.dump({'pitch': [W, H], 'pad_x': P, 'pad_y': PV, 'cells': {f'{c[0]},{c[1]}': v for c, v in cells.items()}, 'open_sockets': open_sockets},
          open(os.path.join(OUT, 'board-demo.json'), 'w'), indent=1)
print(cv.size, len(open_sockets), 'open sockets')

# hand tray demo pieces (strip size, 4 sided) and one hand-size inspect card
tray = [('hurt', {'L': ('hole', 'body'), 'R': ('knob', 'mind'), 'T': ('flat', None), 'B': ('knob', 'craft')}),
        ('guard', {'L': ('knob', 'craft'), 'R': ('hole', 'body'), 'T': ('hole', 'mind'), 'B': ('flat', None)}),
        ('charm', {'L': ('flat', None), 'R': ('knob', 'body'), 'T': ('knob', 'mind'), 'B': ('hole', 'craft')}),
        ('item', {'L': ('hole', 'craft'), 'R': ('flat', None), 'T': ('flat', None), 'B': ('knob', 'body')})]
for i, (t, e) in enumerate(tray):
    paint(t, 'strip', e, 'me', ICO).save(os.path.join(OUT, f'tray-demo-{i}.png'))
paint('hurt', 'hand', tray[0][1], 'me', ICO).save(os.path.join(OUT, 'inspect-demo.png'))
