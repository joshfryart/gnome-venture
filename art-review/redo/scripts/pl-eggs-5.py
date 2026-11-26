#!/usr/bin/env python3
"""pl-eggs-5 "Wreath Hollow": a round orange door wreath that is an inner-BBBB piece (round blanks notched into all four sides of
its squircle ring). Its opening is a little window onto the green garden of cell 9-5, where its felt face peeks out.
Woven orange straw, green leaf sprigs and striped-egg berries (red/yellow like the roof egg)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ORANGE = K.ramp('#e58a2c')
STRAW = '#b8601c'
GARDEN = K.ramp('#5a9a52')
LEAF = '#86c35a'
LEAFD = '#3f7a3e'
EGGR = '#d8402c'
EGGY = '#f5cf4a'
WALL = '#b8909a'


def squircle(cx, cy, R):
    return lambda x, y: (abs(x - cx) / R) ** 4 + (abs(y - cy) / R) ** 4 < 1


def fn(c):
    k = 1.15 if c.small else 1.0
    core = squircle(32, 32, 26.5)
    r = 4.2 * k
    blanks = (K.knob('B', 'round', 32, 5.5, 0, -1, r=r), K.knob('B', 'round', 32, 58.5, 0, 1, r=r),
              K.knob('B', 'round', 5.5, 32, -1, 0, r=r), K.knob('B', 'round', 58.5, 32, 1, 0, r=r))
    body = c.m(core, minus=blanks)
    c.add(body, ORANGE, stitch=None)
    win = K.ell(32, 32, 11.5, 11.5)
    wm = c.m(win)
    c.add(wm, GARDEN)
    # garden in the window: lighter hill top-left, darker bush lower right, a sliver of mauve wall at top
    c.add(wm & c.m(K.ell(26, 25, 9, 6)), K.ramp('#7ab55c'))
    c.add(wm & c.m(K.ell(40, 44, 9, 6)), K.ramp('#3f7a3e'))
    c.edge(wm, '#a45a1a')
    # woven straw: short diagonal strokes around the ring
    import math
    n = 16 if c.small else 26
    for i in range(n):
        a = 2 * math.pi * i / n
        rr = 17.5
        x0, y0 = 32 + rr * math.cos(a), 32 + rr * math.sin(a)
        if (x0 - 32) ** 2 + (y0 - 32) ** 2 < 15 ** 2:
            continue
        if any(b(x0, y0) for b in blanks) or not core(x0, y0):
            continue
        dx, dy = -math.sin(a), math.cos(a)
        c.line([(x0 - 2.2 * dx + 1.2 * math.cos(a), y0 - 2.2 * dy + 1.2 * math.sin(a)),
                (x0 + 2.2 * dx - 1.2 * math.cos(a), y0 + 2.2 * dy - 1.2 * math.sin(a))], STRAW)
    # leaf sprigs on the four thick corners, egg berries beside them
    for j in range(8):
        a = 2 * math.pi * (j + 0.5) / 8
        lx, ly = 32 + 18.5 * math.cos(a) * 1.08, 32 + 18.5 * math.sin(a) * 1.08
        dx, dy = -math.sin(a), math.cos(a)
        lm = c.m(lambda x, y, lx=lx, ly=ly, dx=dx, dy=dy: (((x - lx) * dx + (y - ly) * dy) / 4.4) ** 2 + (((x - lx) * dy - (y - ly) * dx) / 2.3) ** 2 < 1)
        for q in lm:
            c.px(q[0], q[1], LEAF)
        c.line([(lx - 3 * dx, ly - 3 * dy), (lx + 2 * dx, ly + 2 * dy)], LEAFD)
    for i, (ex, ey) in enumerate(((10.5, 22), (53.5, 22), (19, 53.5), (42, 10.5))):
        em = c.m(K.ell(ex, ey, 2.6, 3.2))
        for (x, y) in em:
            c.px(x, y, EGGR if (y // (1 if c.small else 2)) % 2 == 0 else EGGY)
    # little ribbon bow bottom-centre above the blank
    bow = c.m(K.poly([(44, 47), (52, 43), (52, 51)]), K.poly([(44, 47), (38, 41), (38, 50)]) if False else K.poly([(44, 47), (46, 55), (40, 53)]))
    bow = c.m(K.poly([(45, 46), (53, 41.5), (53.5, 50.5)]), K.poly([(45, 46), (40, 39.5), (37.5, 47.5)]),
              K.poly([(45, 46), (49, 56), (45.5, 57)]))
    c.add(bow, K.ramp('#d8402c'))
    c.add(c.m(K.ell(45, 46, 2.2, 2.2)), K.ramp('#a8301a'))
    # face in the window
    c.eye(28, 31, disc=True)
    c.eye(36.5, 31, disc=True)
    c.smile(32, 36)
    c.blush(25, 35)
    c.blush(38.5, 35)


K.render_pal(fn, 'pl-eggs-5', 'Wreath Hollow', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-eggs-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-eggs-5.png')
