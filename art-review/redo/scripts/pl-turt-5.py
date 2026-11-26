#!/usr/bin/env python3
"""pl-turt-5 "Mama Shell": inner-BBBB, round. A turtle face-on: the square-ish shell dome + skin body is the piece; round blanks
N (notch in the dome), W and E (flanks), S (gap between the front feet). Mossy green shell (the picture's big turtle), a rim of
hut-wood planks with plum seams and a centre scute glowing like the hut window (cell 9-5)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp, UMBER, UMBER2

SHELL = ramp('#4a9448')
MOSS = ramp('#7ab858')
SKIN = ramp('#a8d870')
WOOD = ramp('#e8a868')
GLOW = ('#fff4b8', '#ffd870', '#fffbe0')
PLUM = '#603a48'


def rrect(x0, y0, x1, y1, rad):
    def f(x, y):
        if not (x0 <= x < x1 and y0 <= y < y1):
            return False
        cx = min(max(x, x0 + rad), x1 - rad)
        cy = min(max(y, y0 + rad), y1 - rad)
        return (x - cx) ** 2 + (y - cy) ** 2 < rad * rad
    return f


BELLY = ramp('#f0d890')
HEAD = ramp('#8cc860')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rrect(6, 9, 58, 58, 13)
    r = 4.0 * k
    bN = knob('B', 'round', 32, 9, 0, -1, r=r)
    bW = knob('B', 'round', 6, 44, -1, 0, r=r)
    bE = knob('B', 'round', 58, 44, 1, 0, r=r)
    bS = knob('B', 'round', 32, 58, 0, 1, r=3.6 * k)
    blanks = (bN, bW, bE, bS)
    body = c.m(core, minus=blanks)
    # cream belly plate (plastron) in the lower piece, segment lines across
    c.add(body, BELLY)
    for gy in (45, 51):
        _, y = c.P(0, gy)
        for x in range(c.n):
            if (x, y) in body:
                c.px(x, y, WOOD[1])
    # shell dome
    shell = c.m(lambda x, y: y < 37 and core(x, y), minus=blanks)
    c.add(shell, SHELL, stitch=None if c.small else MOSS[2])
    rim = c.m(lambda x, y: 33 <= y < 38 and core(x, y), minus=blanks)
    c.add(rim, WOOD)
    for gx in (12, 19, 26, 38, 45, 52):
        x, _ = c.P(gx, 0)
        for y in range(c.P(0, 33)[1], c.P(0, 38)[1]):
            if (x, y) in rim:
                c.px(x, y, PLUM)
    # scutes ring around the glowing window scute
    for sx, sy in ((14, 26), (50, 26), (19, 15.5), (45, 15.5)):
        sc = c.m(ell(sx, sy, 5.2, 4.6)) & shell
        c.add(sc, MOSS)
        c.edge(sc, SHELL[1])
    win = c.m(poly([(25, 16), (39, 16), (42, 23), (39, 30), (25, 30), (22, 23)]))
    c.add(win, GLOW)
    c.edge(win, PLUM)
    if not c.small:
        mx, _ = c.P(32, 0)
        for y in range(c.P(0, 17)[1], c.P(0, 30)[1]):
            c.px(mx, y, '#f0b860')
        _, my = c.P(0, 23)
        for x in range(c.P(23, 0)[0], c.P(41, 0)[0]):
            if (x, my) in win:
                c.px(x, my, '#f0b860')
    # stubby front legs at the bottom corners, below the side blanks
    for lx in (6, 42):
        leg = c.m(rrect(lx, 47, lx + 16, 58, 3), minus=blanks)
        c.add(leg, SKIN)
        c.edge(leg, SKIN[1])
        cx, cy = c.P(lx + 8, 56)
        for d in (-3, 0, 3):
            c.px(cx + int(d * c.k), cy, SKIN[1])
    # head poking out under the rim
    hk = 1.12 if c.small else 1.0
    head = c.m(ell(32, 43, 9 * hk, 6.8 * hk), minus=blanks)
    c.add(head, HEAD)
    c.edge(head, HEAD[1])
    c.eye(28.5 if not c.small else 27.5, 42.5)
    c.eye(35.5, 42.5)
    if not c.small:
        c.smile(32, 45, UMBER2)
        c.blush(25, 44.5)
        c.blush(38, 44.5)


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-turt-5', 'Mama Shell', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-turt-5-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-turt-5.png'))
