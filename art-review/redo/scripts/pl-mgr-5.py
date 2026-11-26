#!/usr/bin/env python3
"""pl-mgr-5 "Tangle Gap": inner-BBBB, round. A crouching mangrove frog that IS a square piece: the top blank is the dip between
its two eye domes, ringed by a grey-green mangrove root arch (the round gap in the roots); round blanks W and E at the flanks and S
between its splayed feet. Frog lime/green and the pale sky-lime of cell 7-4, root grey-green, teal water at the feet."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

FROG = K.ramp('#6abf43')
BELLY = K.ramp('#d0ec7c')
ROOT = K.ramp('#647864')
WATER = K.ramp('#4ab0a4')
SKY = '#f8ffd0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 18, 54, 55)
    domeL = K.ell(20, 18, 9, 8.5)
    domeR = K.ell(44, 18, 9, 8.5)
    bN = K.knob('B', 'round', 32, 15, 0, -1, r=4.6 * k)
    bW = K.knob('B', 'round', 10, 37, -1, 0, r=4.4 * k)
    bE = K.knob('B', 'round', 54, 37, 1, 0, r=4.4 * k)
    bS = K.knob('B', 'round', 32, 55, 0, 1, r=4.4 * k)
    feetL = K.ell(14, 54, 8, 4.2)
    feetR = K.ell(50, 54, 8, 4.2)
    blanks = (bN, bW, bE, bS)
    body = c.m(core, domeL, domeR, feetL, feetR, minus=blanks)
    c.add(body, FROG, stitch=None if c.small else FROG[1])
    # mangrove root arch ringing the top gap (the round gap in the tangled roots)
    rw = 3.2 if not c.small else 3.8
    arch = c.m(K.knob('B', 'round', 32, 15, 0, -1, r=4.6 * k + rw * 0.55, nw=2.6 + rw * 0.8)) & body
    c.add(arch, ROOT)
    # roots trailing down both shoulders
    c.add(c.m(K.thick_path([(27, 24), (18, 27), (10, 26)], rw)) & body, ROOT)
    c.add(c.m(K.thick_path([(37, 24), (46, 27), (54, 26)], rw)) & body, ROOT)
    # belly
    c.add(c.m(K.ell(32, 43, 12, 8.5), minus=blanks) & body, BELLY)
    # teal water lapping the feet
    c.add(body & c.m(K.rect(0, 52, 64, 64)), WATER)
    # eyes in the domes, sky-lime discs
    for ex in (19, 45):
        cx, cy = c.P(ex, 17)
        rr = 3 if not c.small else 2
        for dx in range(-rr, rr + 1):
            for dy in range(-rr, rr + 1):
                if dx * dx + dy * dy <= rr * rr + 1:
                    c.px(cx + dx, cy + dy, SKY)
        c.eye(ex, 17, look=(0, 0))
    c.smile(32, 31, K.UMBER, wide=True)
    c.blush(23, 32)
    c.blush(40, 32)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-mgr-5', 'Tangle Gap', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-mgr-5-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-mgr-5.png'))
