#!/usr/bin/env python3
"""pl-wlfe-3 Lollipop Tree. Inner-TBTB, keyhole: the round night-teal canopy is the piece body; keyhole tab N = a leaf tuft,
keyhole tab S = the lollipop trunk ending in a root bole; keyhole blanks W and E bite into the canopy. Lantern-light dapples
(gold/orange from the festival lanterns) on the bank trees' teal green; a lavender bridge-stone rim at the trunk foot (cell 2-4)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

LEAF = K.ramp('#2c6a58')
LEAF2 = K.ramp('#469474')
BARK = K.ramp('#825d39')
STONE = K.ramp('#9a8cc0')
GLOW = '#f5cf6a'
GLOW2 = '#f08a4a'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1, r = 8, 7, 56, 45, 13
    core = [K.rect(x0 + r, y0, x1 - r, y1), K.rect(x0, y0 + r, x1, y1 - r),
            K.ell(x0 + r, y0 + r, r, r), K.ell(x1 - r, y0 + r, r, r), K.ell(x0 + r, y1 - r, r, r), K.ell(x1 - r, y1 - r, r, r)]
    tabN = K.knob('T', 'keyhole', 32, y0, 0, -1, r=4.2 * k)
    tabS = K.knob('T', 'keyhole', 32, y1, 0, 1, r=5.4 * k, nw=3.2 * k)
    blW = K.knob('B', 'keyhole', x0, 26, -1, 0, r=4.2 * k)
    blE = K.knob('B', 'keyhole', x1, 26, 1, 0, r=4.2 * k)
    canopy = c.m(*core, tabN, minus=(blW, blE))
    c.add(canopy, LEAF)
    # leaf clumps: lighter scallops on the upper-left of the canopy
    for (cx, cy, rr) in ((19, 16, 6), (31, 12, 6.5), (43, 16, 6), (15, 36, 5), (49, 36, 5)):
        cl = c.m(K.ell(cx, cy, rr, rr * 0.8)) & canopy
        c.add(cl, LEAF2)
        c.edge(cl, LEAF[1])
    # trunk + root bole (the S tab)
    trunk = c.m(tabS, minus=core)
    c.add(trunk, BARK)
    # lavender bridge-stone band under the bole
    bole_y = 45 + 5.4 * k + 2.1
    stone = c.m(K.ell(32, bole_y + 3.2 * k, 5.6 * k, 1.9 * k)) & trunk
    c.add(stone, STONE)
    # lantern-light dapples
    for (x, y, col) in ((17, 33, GLOW), (46, 16, GLOW), (44, 37, GLOW2), (25, 40, GLOW), (48, 28, GLOW2), (15, 22, GLOW)):
        px, py = c.P(x, y)
        c.px(px, py, col)
        if not c.small:
            c.px(px + 1, py, col)
            c.px(px, py + 1, col)
    # face on the calm middle
    c.eye(25.5, 27, disc=True)
    c.eye(38.5, 27, disc=True)
    c.smile(32, 32, wide=True)
    c.blush(21, 31)
    c.blush(42, 31)


rep = K.render_pal(fn, 'pl-wlfe-3', 'Lollipop Tree', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wlfe-3-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wlfe-3.png')
print(rep)
