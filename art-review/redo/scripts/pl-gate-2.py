#!/usr/bin/env python3
"""pl-gate-2 "Hilltop Bowl Shimmer": a gold offering bowl that is an edge piece (edge-TTB, keyhole).
Flat S = the bowl's foot standing on the hill; keyhole tabs E + W = the bowl's two loop handles; keyhole blank N = the bowl's open mouth.
Torii-red lacquer rim and foot (cell 8-3: the red gate post), gold body (the sunrise), purple hill band + grass-green foot ring."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

GOLDB = K.ramp('#e8a317')
RED = K.ramp('#c8422e')
REDDK = K.ramp('#982828')
HILL = K.ramp('#a0648a')
GRASS = K.ramp('#a5c476')
SUN = '#f9a475'


def fn(c):
    S = 1.15 if c.small else 1.0
    top = K.rect(12, 15, 52, 42)
    belly = K.ell(32, 41, 20, 14)
    foot = K.rect(21, 50, 43, 59)
    core = lambda x, y: top(x, y) or (belly(x, y) and y < 52) or foot(x, y)
    tabE = K.knob('T', 'keyhole', 52, 28, 1, 0, r=4.8 * S, nw=2.8)
    tabW = K.knob('T', 'keyhole', 12, 28, -1, 0, r=4.8 * S, nw=2.8)
    blankN = K.knob('B', 'keyhole', 32, 15, 0, -1, r=4.8 * S, nw=2.8)
    body = c.m(core, tabE, tabW, minus=(blankN,))
    c.add(body, GOLDB, stitch=None if c.small else GOLDB[1])
    # handles in torii red
    c.add(body & c.m(tabE, minus=(K.rect(0, 0, 52, 64),)), RED)
    c.add(body & c.m(tabW, minus=(K.rect(12, 0, 64, 64),)), RED)
    # red lacquer rim band with the dark cap line (like the torii crossbeam)
    rim = body & c.m(K.rect(12, 15, 52, 19.5))
    c.add(rim, RED)
    c.add(body & c.m(K.rect(12, 15, 52, 16.6 if not c.small else 17)), REDDK)
    # inside wall of the bowl's mouth (the keyhole blank): a dark gold lip around the cut
    lip = body & c.m(K.knob('B', 'keyhole', 32, 15, 0, -1, r=4.8 * S + 1.8, nw=2.8 + 1.4)) - c.m(K.rect(0, 15, 64, 19.5))
    c.add(lip, K.ramp('#9a5c12'))
    # handle holes (ring handles) at 64 px
    if not c.small:
        for hx in (52 + 4.8 + 2.1, 12 - 4.8 - 2.1):
            c.cut |= c.m(K.ell(hx, 28, 1.6, 1.6))
    # purple hill band low on the belly, green grass foot ring
    c.add(body & c.m(K.rect(0, 43, 64, 48)), HILL)
    c.add(body & c.m(foot), GRASS)
    c.add(body & c.m(K.rect(0, 55, 64, 59)), RED)
    # sunrise shimmer: a little sparkle on the gold
    sx, sy = c.P(45, 33)
    for d in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)) if not c.small else ((0, 0), (1, 0), (0, 1)):
        c.px(sx + d[0], sy + d[1], '#fff2c0')
    if not c.small:
        for d in ((2, 0), (-2, 0), (0, 2), (0, -2)):
            c.px(sx + d[0], sy + d[1], '#f5cf6a')
    # face
    c.eye(25, 36)
    c.eye(38, 36)
    c.smile(31, 40)
    c.blush(20, 40)
    c.blush(42, 40)


K.render_pal(fn, 'pl-gate-2', 'Hilltop Bowl Shimmer', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gate-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gate-2.png')
