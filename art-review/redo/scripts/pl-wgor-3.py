#!/usr/bin/env python3
"""pl-wgor-3 "Rainbow Fruit Tumble": a heap of glade fruit packed into an inner piece.
Tabs N (an orange on its stalk) and S (a grass tuft), keyhole blanks W and E cut into the heap.
Colours: the glade's orange fruit, the gorilla's violet fur (plums), the grass green of cell 3-7."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ORANGE = K.ramp('#f08a2a')
PLUM = K.ramp('#6a5a8a')
RED = K.ramp('#d8402e')
YELLOW = K.ramp('#f0c840')
GRASS = K.ramp('#4aa040')
FUR = K.ramp('#4a3e60')
LEAF = '#2f7a3a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(11, 15, 53, 50)
    tabN = K.knob('T', 'keyhole', 32, 15, 0, -1, r=5.6 * k)
    tabS = K.knob('T', 'keyhole', 32, 50, 0, 1, r=5.0 * k)
    blW = K.knob('B', 'keyhole', 11, 31, -1, 0, r=5.4 * k)
    blE = K.knob('B', 'keyhole', 53, 31, 1, 0, r=5.4 * k)
    body = c.m(core, tabN, tabS, minus=(blW, blE))
    c.add(body, FUR)                                   # the shady heap behind the fruit
    grass = body & c.m(K.rect(0, 44, 64, 54))
    c.add(grass, GRASS)
    fruits = [((32, 6.5, 5.4 * k), ORANGE),           # the tab: an orange on a stalk
              ((32, 58.5, 4.9 * k), RED),
              ((19, 22, 6.5), PLUM), ((45, 22, 6.5), RED),
              ((19, 41, 5.8), YELLOW), ((45, 41, 5.8), PLUM),
              ((32, 31, 10.5), ORANGE)]
    for (x, y, r), rp in fruits:
        m = body & c.m(K.ell(x, y, r, r))
        c.add(m, rp)
        c.edge(m, K.UMBER2)
        if not c.small:   # glint
            gx, gy = c.P(x - r * 0.45, y - r * 0.45)
            c.px(gx, gy, '#fff4d8')
    # stalk + leaf on the top orange
    sx, sy = c.P(32, 1.5)
    c.px(sx, sy, K.UMBER2); c.px(sx, sy + 1, K.UMBER2)
    for dx in range(1, 3 if c.small else 4):
        c.px(sx + dx, sy + (0 if dx < 3 else 1), LEAF)
    # grass blades poking up between the fruit
    for gx in (13, 26, 38, 51):
        x, y = c.P(gx, 47)
        for d in range(2 if c.small else 3):
            c.px(x + (d % 2), y - d, GRASS[2])
    # face on the big orange
    c.eye(28, 30)
    c.eye(36.5, 30)
    c.blush(25, 34)
    c.blush(39, 34)
    c.smile(32, 35)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-wgor-3', 'Rainbow Fruit Tumble', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgor-3-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgor-3.png')
    print(rep)
