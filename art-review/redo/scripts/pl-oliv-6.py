#!/usr/bin/env python3
"""pl-oliv-6 "Pressed Gold" (rare, whimsy-olive, peg).
Concept: a plump upright olive whose oval body is the piece: peg tab E (side bulge), peg blank W, and a peg tab S that is a
drop of golden oil squeezed out of it; stem with two olive leaves on top. Greens are the olive-tree cell 10-3 (#c8dc98 / #a9c282 /
#8aa86c / #52786a), gold is the oil in the piazza's bottles."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

OLIVE = ('#a8b868', '#6f8a4a', '#c8dc98')
LEAF = K.ramp('#8aa86c')
LEAFD = K.ramp('#52786a')
OIL = ('#e8b020', '#b07a10', '#f8d860')
STEM = K.ramp('#7a5a30')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.ell(32, 35.5, 15.5, 20.5)
    tabE = K.knob('T', 'peg', 47.3, 37, 1, 0, r=4.0 * k)
    blankW = K.knob('B', 'peg', 16.7, 37, -1, 0, r=4.0 * k)
    tabS = K.knob('T', 'peg', 32, 54.8, 0, 1, r=3.8 * k)
    body = c.m(core, tabE, minus=(blankW,))
    c.add(body, OLIVE, stitch=None if c.small else '#c8dc98')
    # golden oil drop = south peg tab
    drop = c.m(tabS, minus=(core,))
    c.add(drop | (c.m(tabS) & c.m(K.rect(0, 53, 64, 56))), OIL)
    # oil glaze running down the lower body toward the drop
    glaze = c.m(lambda x, y: core(x, y) and y > 49 and abs(x - 32) < 7 - (55 - y) * 0.6)
    c.add(glaze, OIL)
    # stem and leaves on top
    sw = 2.6 if not c.small else 3.2
    c.add(c.m(K.thick_path([(32, 17), (32.5, 12), (34, 8)], sw)), STEM)
    c.add(c.m(K.poly([(33, 10), (38, 5), (46, 4), (44, 9), (36, 12)])), LEAF)
    c.add(c.m(K.poly([(32, 11), (27, 6), (19, 6), (22, 11), (29, 13)])), LEAFD)
    # glossy highlight upper left (pressed-oil sheen)
    hl = c.m(K.ell(24.5, 26, 2.6, 5.5))
    c.add(hl & body, ('#e6f0c0', '#c8dc98', '#ffffff'))
    # pit-dimple speckles from the cell (dark teal dots) at 64 px only
    if not c.small:
        for (x, y) in ((40, 24), (41, 47), (24, 47)):
            c.px(*c.P(x, y), '#52786a')
    # face
    c.eye(27.5, 33)
    c.eye(37, 33)
    c.smile(32, 39, wide=True)
    c.blush(24, 38)
    c.blush(39.5, 38)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-oliv-6', 'Pressed Gold', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-oliv-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-oliv-6.png')
    print(rep)
