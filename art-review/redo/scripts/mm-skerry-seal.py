#!/usr/bin/env python3
"""mm-skerry-seal: edge-TBB, keyhole. A plump grey harbour seal sitting upright on its skerry, face on.
Flat S = the skerry rock (grass top + heather). Keyhole tab N = the seal's raised snout balancing a red-and-white
lighthouse-striped buoy ball. Keyhole blanks W + E bite into its sides above the fore-flippers.
Colours from cell 0-1 of Mistmoor: sea-grey seal, lighthouse white + red band, moor green, heather purple."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SEAL = K.ramp('#7b8797')
BELLY = K.ramp('#b4bcc6')
WHITE = K.ramp('#e6e2d6')
RED = K.ramp('#9a3a3b')
GRASS = K.ramp('#677159')
ROCK = K.ramp('#5d5650')
HEATH = '#9a6ab0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 22, 55, 61)
    tabN = K.knob('T', 'keyhole', 32, 22, 0, -1, r=7.6 * k, nw=3.4)
    blW = K.knob('B', 'keyhole', 9, 44, -1, 0, r=5.0 * k)
    blE = K.knob('B', 'keyhole', 55, 44, 1, 0, r=5.0 * k)
    # rounded top shoulders of the seal's head
    cutTL = lambda x, y: x < 18 and y < 30 and (x - 18) ** 2 + (y - 30) ** 2 > 64
    cutTR = lambda x, y: x > 46 and y < 30 and (x - 46) ** 2 + (y - 30) ** 2 > 64
    body = c.m(core, minus=(blW, blE, cutTL, cutTR))
    c.add(body, SEAL, stitch=None if c.small else SEAL[1])
    # snout neck of the tab (grey) and buoy ball on top
    tab = c.m(tabN, minus=(core,))
    c.add(tab, SEAL)
    ball = c.m(lambda x, y: y < 15.5 and tabN(x, y))
    c.add(ball, WHITE)
    c.add(c.m(lambda x, y: 7.0 < y < 11.2 and tabN(x, y)), RED)
    if not c.small:
        for sx, sy in ((14, 30), (49, 31), (12, 47), (51, 46), (13, 38), (51, 38)):
            x, y = c.P(sx, sy)
            if (x, y) in body:
                c.px(x, y, SEAL[1]); c.px(x + 1, y, SEAL[1])
    # belly patch
    c.add(c.m(K.ell(32, 43, 10, 10)) & body, BELLY)
    # fore-flippers resting on the rock, below the blanks
    fl = c.m(K.poly([(14, 36), (19, 35), (24, 46), (21, 49)]))
    fr = c.m(K.poly([(50, 36), (45, 35), (40, 46), (43, 49)]))
    FLIP = K.ramp('#5f6a7c')
    c.add(fl & body, FLIP)
    c.add(fr & body, FLIP)
    # skerry: rock with grass top
    c.add(body & c.m(K.rect(0, 51, 64, 64)), ROCK)
    grass = body & c.m(lambda x, y: 50 <= y < 53.5 + (1.5 if (int(x) // 3) % 2 else 0))
    c.add(grass, GRASS)
    # heather + a red/white lighthouse stripe band on the rock lip
    for hx, hy in ((14, 52), (25, 53), (39, 52), (49, 53)):
        c.px(*c.P(hx, hy), HEATH)
        if not c.small:
            x, y = c.P(hx, hy)
            c.px(x + 1, y, HEATH)
    c.edge(c.m(K.rect(0, 51, 64, 64)) & body, ROCK[1])
    # whiskered muzzle + face
    c.add(c.m(K.ell(32, 32, 6.5, 4.2)) & body, BELLY)
    nx, ny = c.P(32, 29.6)
    c.px(nx, ny, K.UMBER)
    c.px(nx - 1, ny, K.UMBER)
    if not c.small:
        for d in (-1, 1):
            c.line([(32 + d * 7.5, 31.5), (32 + d * 12, 30.5)], SEAL[1])
            c.line([(32 + d * 7.5, 33.5), (32 + d * 12, 34.5)], SEAL[1])
    c.smile(31.5, 32.5)
    c.eye(23.5, 28)
    c.eye(40.5, 28)
    c.blush(20, 33)
    c.blush(43, 33)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'mm-skerry-seal', 'Skerry Seal', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/mm-skerry-seal-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mm-skerry-seal.png')
    print(rep)
