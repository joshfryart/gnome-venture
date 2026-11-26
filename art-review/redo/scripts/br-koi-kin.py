#!/usr/bin/env python3
"""Koi Kin (br-koi-kin), edge-TBT keyhole: a fat koi swimming left, side on, whose body IS the piece.
Flat W side = the blunt koi head; N keyhole tab = dorsal fin; E keyhole blank = the forked tail notch (tail lobes wrap round it);
S keyhole tab = belly fin. Gold and orange koi with white patches, red fins, a pink blossom petal on its head (Blossomreach cell 2-7)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

GOLDK = K.ramp('#f0b92b')
ORNG = K.ramp('#e8701e')
WHT = ('#f4f0e4', '#c9c5bc', '#ffffff')
FIN = K.ramp('#c8493a')
PINK = '#f6b8cf'
TEAL = '#5fa89f'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 5, 19, 61, 49
    R = 7
    def head(x, y):
        if not (x0 <= x < 42 and y0 <= y < y1):
            return False
        for cy in (y0 + R, y1 - R):
            if x < x0 + R and ((y < y0 + R and cy == y0 + R) or (y >= y1 - R and cy == y1 - R)):
                return (x - x0 - R) ** 2 + (y - cy) ** 2 < R * R
        return True
    waist = K.poly([(38, y0), (46, 23), (46, 45), (38, y1)])
    tailp = K.poly([(44, 24), (x1, 11), (x1, 57), (44, 44)])
    core = lambda x, y: head(x, y) or waist(x, y) or tailp(x, y)
    tabN = K.knob('T', 'keyhole', 26, y0, 0, -1, r=6.0 * k, nw=3.2)
    tabS = K.knob('T', 'keyhole', 25, y1, 0, 1, r=5.4 * k, nw=3.0)
    blankE = K.knob('B', 'keyhole', x1, 34, 1, 0, r=4.2 * k, nw=2.4)
    body = c.m(core, tabN, tabS, minus=(blankE,))
    c.add(body, GOLDK, stitch=None if c.small else '#f8d878')
    fins = c.m(tabN, tabS, minus=(head,))
    tail = body & c.m(K.rect(46, 0, 64, 64))
    c.add(tail, FIN)
    c.add(fins & body, FIN)
    # fin rays
    if not c.small:
        for (a, b) in (((48, 30), (60, 14)), ((48, 38), (60, 54)), ((48, 32), (54, 25)), ((48, 36), (54, 43))):
            c.line([a, b], FIN[2])
        c.line([(23, 13), (25, 18)], FIN[2])
        c.line([(29, 13), (27, 18)], FIN[2])
    # white belly
    belly = body & c.m(K.ell(26, 52, 20, 9)) & c.m(K.rect(0, 0, 47, y1))
    c.add(belly, WHT)
    # orange kohaku patches on the back
    c.add(body & c.m(K.ell(30, 24, 9, 5.5), K.ell(41, 33, 4.5, 6.5)) - tail - fins, ORNG)
    # gill line + tail seam
    c.edge(tail, FIN[1])
    gx = 20
    c.line([(gx, 24), (gx + 2, 30), (gx + 2, 36), (gx, 42)], ORNG[1])
    # head: eye, mouth, barbels
    c.eye(13, 30, disc=True)
    mx, my = c.P(x0, 39)
    c.px(mx, my, UM := '#2a1a10')
    c.px(mx + 1, my, UM)
    if not c.small:
        c.px(mx + 2, my - 1, UM)
        c.line([(9, 41), (12, 43), (13, 46)], ORNG[1])
    c.blush(15, 36)
    # pink blossom petal on the head
    px_, py_ = c.P(12, 21)
    pts = [(0, 0), (1, 0), (-1, 1), (0, 1), (1, 1), (2, 1), (0, 2), (1, 2)] if not c.small else [(0, 0), (1, 0), (0, 1)]
    for dx, dy in pts:
        c.px(px_ + dx, py_ + dy, PINK)
    c.px(px_ + 1, py_ + 1, '#ec74ac')
    # scales (64 only): small arcs on the gold
    if not c.small:
        for (x, y) in body:
            if 24 <= x < 43 and 24 <= y < 44 and x % 5 == 0 and y % 5 == 2:
                c.px(x, y, GOLDK[1])
                c.px(x + 1, y + 1, GOLDK[1])


if __name__ == '__main__':
    print(K.render_pal(fn, 'br-koi-kin', 'Koi Kin', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/br-koi-kin-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/br-koi-kin.png'))
