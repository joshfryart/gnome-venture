#!/usr/bin/env python3
"""br-dragon-dart "Dragon Dart" (whimsy-dragonfly, tri): a dragonfly seen from above whose four spread wings ARE the square piece core.
Tri tab out of the left front wing, tri blank cut into the right hind wing; head pokes out of the top edge, segmented tail drops out of the bottom.
Colours from cell 8-0: sky blue + cloud white wings, cherry-petal pink hind wings and petal spots, the teal-blue pagoda roof for the body."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, UMBER2

SKY = K.ramp('#a9d2ea')
PINK = K.ramp('#f2a6c6')
ROOF = K.ramp('#3f8fb0')
HEAD = K.ramp('#4aa6a0')
PETAL = '#e8709e'
CLOUD = '#fcf6f8'


def fn(c):
    s = 1.15 if c.small else 1.0
    # wing core: a square with rounded wing tips and a small V notch between front and hind wing on each side
    def rr(x0, y0, x1, y1, r):
        def f(x, y):
            if not (x0 <= x < x1 and y0 <= y < y1):
                return False
            cx = min(max(x, x0 + r), x1 - r)
            cy = min(max(y, y0 + r), y1 - r)
            return (x - cx) ** 2 + (y - cy) ** 2 < r * r
        return f
    trimmed = rr(9, 14, 55, 50, 6.5)
    vL = poly([(7, 27.5), (15.5, 32), (7, 36.5)])
    vR = poly([(57, 27.5), (48.5, 32), (57, 36.5)])
    tabW = knob('T', 'tri', 9, 22, -1, 0, r=4.2 * s)
    blankE = knob('B', 'tri', 55, 41.5, 1, 0, r=3.8 * s)
    wings = c.m(trimmed, tabW, minus=(vL, vR, blankE))
    front = wings & c.m(rect(0, 0, 64, 32))
    hind = wings - front
    c.add(front, SKY, stitch=None if c.small else '#e4f2fa')
    c.add(hind, PINK, stitch=None if c.small else '#fbe0ec')
    # wing tips: cloud white on front, petal pink spots on hind
    c.add(front & c.m(ell(11, 18, 6, 5), ell(53, 18, 6, 5)), K.ramp('#e4f0f6'))
    # division between wing pairs
    c.edge(front, SKY[1])
    # veins
    if not c.small:
        c.line([(30, 22), (14, 18)], SKY[1]); c.line([(34, 22), (50, 18)], SKY[1])
        c.line([(30, 25), (16, 27)], SKY[1]); c.line([(34, 25), (48, 27)], SKY[1])
        c.line([(30, 38), (15, 44)], PINK[1]); c.line([(34, 38), (49, 44)], PINK[1])
    for (x, y) in ((17, 40), (46, 38), (21, 45), (44, 46)) if not c.small else ((17, 41), (45, 40)):
        c.add(c.m(ell(x, y, 2.0 * s, 1.7 * s)), K.ramp(PETAL))
    # body: thorax down the middle, segmented tail out of the bottom edge
    thor = c.m(ell(32, 26, 4.5, 9))
    tail = c.m(thick_path([(32, 30), (32, 62)], 4.6 if not c.small else 5.2))
    c.add(tail, ROOF)
    c.add(thor, ROOF)
    for ty in (39, 44, 49, 54, 58):
        y = c.P(0, ty)[1]
        for x in range(c.n):
            if (x, y) in tail and not (x, y) in thor:
                c.px(x, y, ROOF[1])
    # head with big compound eyes, out of the top edge
    head = c.m(ell(32, 10.5, 8.5, 6.5) if not c.small else ell(32, 10, 9.5, 7.5))
    c.add(head, HEAD)
    c.edge(thor, ROOF[1])
    c.eye(28.2 if not c.small else 27.5, 10.5, disc=True, look=(1, 0))
    c.eye(36.2 if not c.small else 35.0, 10.5, disc=True, look=(1, 0))
    c.smile(32.2, 14.5, UMBER2)


if __name__ == '__main__':
    out = '/home/user/gnome-venture/art-review/redo/out'
    print(K.render_pal(fn, 'br-dragon-dart', 'Dragon Dart', out,
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/br-dragon-dart-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/br-dragon-dart.png'))
