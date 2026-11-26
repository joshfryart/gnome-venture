#!/usr/bin/env python3
"""pl-stkv-3 Sunflower Nodder. Inner-TBTB, keyhole.
Concept: a sunflower head IS the square piece: a ring of sun-yellow petals (corners end in petal tips) round a big door-brown seed disc
with a face. N tab = a top petal tuft, S tab = the green stem neck, E and W blanks cut into the petal ring. Colours from cell 8-6:
the brown village door (disc), cream wall (seed glints), sandy ground (petal shade), plus the picture's sunset sun yellow."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PETAL = K.ramp('#f2c02a')
GLOW = K.ramp('#ffe27a')
DISC = K.ramp('#7c4d3b')
SEED = '#5a3428'
CREAMW = '#f6e2b8'
STEM = K.ramp('#5f9a3c')
SOIL = K.ramp('#d8a46c')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 13, 55, 51)
    tips = [K.poly([(9, 19), (4.5, 9.5), (15, 13)]), K.poly([(55, 19), (59.5, 9.5), (49, 13)]),
            K.poly([(9, 45), (4.5, 54.5), (15, 51)]), K.poly([(55, 45), (59.5, 54.5), (49, 51)])]
    tabN = K.knob('T', 'keyhole', 32, 13, 0, -1, r=4.2 * k)
    tabS = K.knob('T', 'keyhole', 32, 51, 0, 1, r=4.2 * k)
    blW = K.knob('B', 'keyhole', 9, 32, -1, 0, r=3.8 * k)
    blE = K.knob('B', 'keyhole', 55, 32, 1, 0, r=3.8 * k)
    body = c.m(core, tabN, *tips, minus=(blW, blE))
    c.add(body, PETAL)
    # petal dividers radiating from the disc (inner contours)
    disc = K.ell(32, 32, 11.5, 11)
    if not c.small:
        for ang in range(0, 360, 30):
            import math
            a = math.radians(ang + 15)
            c.line([(32 + 13 * math.cos(a), 32 + 12.5 * math.sin(a)), (32 + 19 * math.cos(a), 32 + 18 * math.sin(a))], PETAL[1])
    # sun glow on the upper-left petals
    c.add(c.m(K.ell(22, 22, 9, 8), tabN, minus=(disc, blW)) & body, GLOW)
    c.add(c.m(tabS, minus=(core,)), STEM)
    c.add(c.m(tabS, minus=(core,)) & c.m(K.rect(0, 57.5, 64, 64)), SOIL)
    c.add(c.m(disc), DISC)
    dm = c.m(disc)
    c.edge(dm, DISC[1])
    # seed dots (door-brown speckle) on the lower disc
    for sx, sy in ((25, 37), (29, 40), (33, 41), (37, 39.5), (40, 36), (27, 34.5)):
        x, y = c.P(sx, sy)
        c.px(x, y, SEED)
    if not c.small:
        for sx, sy in ((23, 31), (41, 30), (35, 43)):
            x, y = c.P(sx, sy)
            c.px(x, y, CREAMW)
    c.eye(27.5, 30, disc=not c.small)
    c.eye(36.5, 30, disc=not c.small)
    c.smile(32, 35, col=CREAMW)
    c.blush(24.5, 34)
    c.blush(39.5, 34)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-stkv-3', 'Sunflower Nodder', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-stkv-3-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-stkv-3.png'))
