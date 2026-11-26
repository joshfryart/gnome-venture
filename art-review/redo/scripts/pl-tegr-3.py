# Steeping Cuppa: a stone-wall teacup that is an inner piece. Keyhole tabs N (a curl of steam) and E (the cup handle, with its finger hole),
# keyhole blanks W and S (S cut into the foot). Cup walls are the cell's tan terrace stones with mortar lines; the brimming tea is the
# cell's rich soil brown with green sprout-leaves floating in it; a pink band from the giant teapot of the picture.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path

STONE = K.ramp('#b49a7a')
STONE_LT = K.ramp('#e8d4a8')
SOIL = K.ramp('#b87a4e')
PINK = K.ramp('#d8706a')
STEAM = K.ramp('#f4f0e4')
MORTAR = '#7c6a6a'
SPROUT = '#8ccc48'
CELL = '/home/user/gnome-venture/art-review/redo/_src/pl-tegr-3-cell.png'
OLD = '/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tegr-3.png'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(10, 21, 48, 56)
    tabN = knob('T', 'keyhole', 29, 21, 0, -1, r=5.0 * k)
    tabE = knob('T', 'keyhole', 48, 38, 1, 0, r=5.4 * k)
    blankW = knob('B', 'keyhole', 10, 44, -1, 0, r=3.3 * k, nw=2.0)
    blankS = knob('B', 'keyhole', 29, 56, 0, 1, r=3.3 * k, nw=2.0)
    cornerL = K.poly([(9, 49), (16, 57), (9, 57)])
    cornerR = K.poly([(49, 49), (42, 57), (49, 57)])
    blanks = (blankW, blankS, cornerL, cornerR)
    body = c.m(core, minus=blanks)
    # stone cup wall
    c.add(body, STONE, stitch=None)
    # mortar: courses of stones like the terrace wall
    rows = (40,) if not c.small else (42,)
    for i, yy in enumerate(rows):
        c.add(c.m(rect(10, yy, 48, yy + (1 if not c.small else 1.8)), minus=blanks), (MORTAR, MORTAR, MORTAR))
    joints = [(16, 28, 40), (42, 28, 40), (22, 40, 48), (36, 40, 48)] if not c.small \
        else [(22, 41, 49)]
    for x, y0, y1 in joints:
        c.add(c.m(rect(x, y0, x + (1 if not c.small else 1.8), y1), minus=blanks), (MORTAR, MORTAR, MORTAR))
    # pale foot ring (the cup's base), notched by the S blank
    c.add(c.m(rect(10, 52, 48, 56), minus=blanks), STONE_LT)
    # pale capstone rim + pink teapot band just below
    c.add(c.m(rect(10, 21, 48, 25)), STONE_LT)
    c.add(c.m(rect(10, 25, 48, 28 if not c.small else 30)), PINK)
    # handle (E tab) in stone, with the finger hole
    hm = c.m(tabE, minus=(core,))
    c.add(hm, STONE)
    hole = c.m(ell(54.3, 38.6, 1.6 if not c.small else 1.9, 1.9))
    c.cut |= hole
    # tea surface: soil-brown brim peeking above the rim, with floating sprout leaves
    tea = c.m(ell(29, 21, 17.5, 3.0), minus=(rect(0, 21.5, 64, 64),))
    c.add(tea, SOIL)
    c.add(c.m(rect(10, 21, 48, 22.2 if not c.small else 22.8)), SOIL)
    # steam (N tab), cream
    c.add(c.m(tabN, minus=(rect(0, 19.5, 64, 64),)), STEAM)
    if not c.small:
        c.line([(27, 8), (30, 11), (28, 14), (30, 17)], '#c9c5bc')
        for p in ((19, 20), (38, 20), (25, 21)):
            c.px(*c.P(*p), SPROUT)
            c.px(c.P(*p)[0] + 1, c.P(*p)[1], '#3e8a68')
    else:
        c.px(*c.P(20, 20.5), SPROUT)
        c.px(*c.P(38, 20.5), SPROUT)
    # face on the big stone belly
    c.eye(22, 34, disc=False)
    c.eye(36, 34, disc=False)
    c.blush(17.5, 38)
    c.blush(39.5, 38)
    c.smile(29, 37)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-tegr-3', 'Steeping Cuppa', '/home/user/gnome-venture/art-review/redo/out', cellfile=CELL, oldfile=OLD))
