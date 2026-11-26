#!/usr/bin/env python3
"""pl-flfm-1 Blooming Barge: corner-TB, round. A flower barge seen side-on: flat S (keel on the waterline) and flat W (stern transom),
round tab N = a heaped mound of pink blooms, round blank E bitten into the wooden hull. Cell 0-5: pinks, orange sun-bloom, leaf green, lake teal."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path, ramp

ROOT = '/home/user/gnome-venture'
PINK = ramp('#ff89a5')
HOT = ramp('#ff5a82')
PALE = ramp('#ffb8c8')
ORANGE = ramp('#ffb848')
LEAF = ramp('#88c458')
HULL = ramp('#b8703a')
RIM = ramp('#e8a85a')
WATER = ramp('#3aa0c0')
WHITE = ('#ffffff', '#e0dccc', '#ffffff')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(7, 20, 57, 57)
    tabN = knob('T', 'round', 28, 20, 0, -1, r=6.2 * k, nw=3.6)
    blankE = knob('B', 'round', 57, 29, 1, 0, r=4.4 * k)
    body = c.m(core, tabN, minus=(blankE,))
    # water fills the bottom band; the hull is a boat-shaped block sitting on it (sloped bow E, square-ish stern W)
    c.add(body, WATER)
    hullp = K.poly([(7, 37), (57, 37), (57, 41), (49, 53), (12, 53), (7, 47)])
    hull = body & c.m(hullp)
    c.add(hull, HULL)
    c.add(body & c.m(hullp) & c.m(rect(0, 37, 64, 40)), RIM)      # gunwale
    # heap of blooms above the gunwale, mounding into the tab
    heap = body & c.m(rect(0, 0, 64, 38))
    c.add(heap, LEAF)
    blooms = [((28, 12), 5.6, PINK), ((19, 24), 5.0, HOT), ((35, 22), 4.6, PINK), ((11, 31), 4.0, ORANGE), ((21, 33), 4.4, PINK),
              ((31, 31), 4.4, HOT), ((42, 33), 4.2, PINK), ((47, 24), 3.8, ORANGE), ((12, 23), 3.4, PINK), ((28, 22), 3.2, ORANGE),
              ((40, 15), 3.0, HOT), ((52, 33), 3.4, HOT), ((47, 16), 3.2, PALE), ((40, 25), 3.0, PALE), ((14, 37), 2.8, HOT), ((19, 16), 2.8, PALE)]
    if c.small:
        blooms = [((28, 11), 6.0, PINK), ((18, 25), 5.6, HOT), ((36, 23), 5.2, PINK), ((27, 33), 4.6, ORANGE), ((11, 32), 4.4, PINK),
                  ((43, 33), 4.8, HOT), ((48, 23), 4.0, ORANGE), ((44, 15), 3.4, PALE)]
    for (x, y) in ([(16, 17), (45, 30), (24, 28), (36, 38), (7, 27)] if not c.small else [(12, 18), (36, 31)]):
        pass
    for (x, y), r, rp in blooms:
        m = c.m(ell(x, y, r, r * 0.9)) & heap
        c.add(m, rp)
        c.edge(m, rp[1])
        cx, cy = c.P(x, y)
        c.px(cx, cy, '#fce46c')
        if not c.small:
            c.px(cx + 1, cy, '#e87a38')
    # white daisies (cell's white flowers)
    for (x, y) in ([(10, 16), (52, 21), (22, 16)] if not c.small else [(9, 20)]):
        cx, cy = c.P(x, y)
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            c.px(cx + dx, cy + dy, '#ffffff')
        c.px(cx, cy, '#fce46c')
    # hull planks
    for yy in (44.5, 49.5):
        y = c.P(0, yy)[1]
        for x in range(c.P(8, 0)[0], c.P(57, 0)[0]):
            if (x, y) in hull and (c.small or x % 9 != 0):
                c.px(x, y, HULL[1])
    # water ripples
    y = c.P(0, 55)[1]
    for x in range(c.P(9, 0)[0], c.P(56, 0)[0]):
        if (x // 3) % 3 == 0 and (x, y) not in hull:
            c.px(x, y, WATER[2])
    # face on the hull
    c.eye(23, 45)
    c.eye(37, 45)
    c.smile(30, 48.5)
    c.blush(18, 48)
    c.blush(42, 48)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-flfm-1', 'Blooming Barge', ROOT + '/art-review/redo/out',
                       cellfile=ROOT + '/art-review/redo/_src/pl-flfm-1-cell.png',
                       oldfile=ROOT + '/game/assets/img/puzzles/pals/pl-flfm-1.png')
    print(rep)
