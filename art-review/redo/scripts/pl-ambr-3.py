#!/usr/bin/env python3
"""pl-ambr-3 Redcap Pips: inner-TBTB keyhole. Two red-capped toadstools merged into one square piece.
N keyhole blank splits the red cap into two domes, S keyhole blank parts the two cream stems, E + W keyhole tabs are the cap brims.
Cap red with cream spots, amber/brown leaf litter at the feet (cell 2-7, The Amber Woods)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#e04838')
GILL = K.ramp('#a8302a')
STEM = K.ramp('#f2e2c0')
LITTER = K.ramp('#b8682e')
AMBER = K.ramp('#e89a30')
SPOT = '#fbf0d8'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = (K.rect(12, 18, 52, 54), K.rect(18, 12, 46, 20), K.ell(18, 18, 6, 6), K.ell(46, 18, 6, 6))
    tabE = K.knob('T', 'keyhole', 52, 26, 1, 0, r=4.6 * k)
    tabW = K.knob('T', 'keyhole', 12, 26, -1, 0, r=4.6 * k)
    blankN = K.knob('B', 'keyhole', 32, 12, 0, -1, r=5.2 * k)
    blankS = K.knob('B', 'keyhole', 32, 54, 0, 1, r=5.0 * k)
    body = c.m(*core, tabE, tabW, minus=(blankN, blankS))
    # litter base (whole body first), then stems, then caps
    c.add(body, LITTER)
    stems = c.m(K.rect(17, 33, 29, 50), K.rect(35, 33, 47, 50), K.ell(23, 50, 6, 3), K.ell(41, 50, 6, 3)) & body
    c.add(stems, STEM)
    capzone = c.m(K.rect(0, 0, 64, 34)) & body
    c.add(capzone, RED, stitch=None if c.small else '#f08a6a')
    gill = c.m(K.rect(13, 31, 51, 34.5)) & body
    c.add(gill, GILL)
    # split the cap into two domes with a dark crease under the blank
    c.edge(c.m(K.rect(0, 0, 32, 31)) & capzone, RED[1])
    # leaves in the litter
    for (lx, ly) in ((15, 52), (31, 50), (48, 52)):
        c.add(c.m(K.ell(lx, ly, 3.2, 1.8)) & body, AMBER)
    # cream spots on the caps
    spots = [(19, 19, 2.4), (26, 25, 1.8), (16, 27, 1.6), (43, 18, 2.4), (38, 25, 1.8), (49, 26, 1.6), (56, 26, 1.4), (8, 26, 1.4)]
    for (sx, sy, sr) in spots:
        if c.small and sr < 1.7:
            continue
        for p in c.m(K.ell(sx, sy, sr * (1.2 if c.small else 1), sr * (1.2 if c.small else 1))) & body:
            c.px(p[0], p[1], SPOT)
    # faces on the stems, leaning in toward each other (the secret)
    c.eye(21.5, 40, look=(1, 0))
    c.eye(26, 40, look=(1, 0))
    c.eye(38, 40, look=(-1, 0)) if not c.small else c.eye(37.5, 40)
    c.eye(42.5, 40, look=(-1, 0)) if not c.small else c.eye(42, 40)
    c.blush(19, 44)
    c.blush(45, 44)
    if not c.small:
        c.smile(24, 44, K.UMBER2)
        c.smile(40, 44, K.UMBER2)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-ambr-3', 'Redcap Pips', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-ambr-3-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ambr-3.png'))
