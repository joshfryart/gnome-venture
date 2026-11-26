import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

# Questionmark Bubble: inner-BBBB double. A sand-coloured speech bubble with a hedge rim (the maze hedge of cell 7-2),
# a tail at the lower left, a big hedge-green question mark; double blanks bitten into all four sides.
HEDGE = K.ramp('#4e9c48')
HEDGED = K.ramp('#2e7a44')
SAND = K.ramp('#f4dc9c')
LEAF = '#bef06a'

def rrect(x0, y0, x1, y1, r):
    return [rect(x0 + r, y0, x1 - r, y1), rect(x0, y0 + r, x1, y1 - r),
            ell(x0 + r, y0 + r, r, r), ell(x1 - r, y0 + r, r, r), ell(x0 + r, y1 - r, r, r), ell(x1 - r, y1 - r, r, r)]

def fn(c):
    k = 1.15 if c.small else 1.0
    r = 3.3 * k
    x0, y0, x1, y1 = 4, 3, 60, 57
    outer = rrect(x0, y0, x1, y1, 9)
    tail = poly([(9, 50), (2, 63), (22, 54)])
    blanks = (knob('B', 'double', 32, y0, 0, -1, r=r), knob('B', 'double', 32, y1, 0, 1, r=r),
              knob('B', 'double', x0, 30, -1, 0, r=r), knob('B', 'double', x1, 30, 1, 0, r=r))
    body = c.m(*outer, tail, minus=blanks)
    c.add(body, HEDGE)
    inner = rrect(x0 + 3, y0 + 3, x1 - 3, y1 - 3, 7)
    # inner sand field: body eroded by the rim width
    bw = 3
    blanks_wide = (knob('B', 'double', 32, y0, 0, -1, r=r + bw * 0.55, nw=2.6 + bw),
                   knob('B', 'double', 32, y1, 0, 1, r=r + bw * 0.55, nw=2.6 + bw),
                   knob('B', 'double', x0, 30, -1, 0, r=r + bw * 0.55, nw=2.6 + bw),
                   knob('B', 'double', x1, 30, 1, 0, r=r + bw * 0.55, nw=2.6 + bw))
    sand = c.m(*inner, minus=blanks_wide) & body
    c.add(sand, SAND)
    c.edge(sand, HEDGED[1])
    # leafy speckles on the hedge rim (64 only)
    if not c.small:
        rim = body - sand
        for (x, y) in rim:
            if (x * 7 + y * 3) % 11 == 0:
                c.px(x, y, HEDGE[2])
            elif (x * 5 + y * 9) % 13 == 0:
                c.px(x, y, HEDGED[0])
    # question mark: a clean hook arc, stem and dot, dark hedge with an umber contour
    import math
    w = 4.6 if not c.small else 5.4
    arc = [(32 + 6.8 * math.cos(math.radians(a)), 23.5 + 6.8 * math.sin(math.radians(a))) for a in range(170, 400, 20)]
    q = thick_path(arc + [(32, 32.5), (32, 35)], w)
    qm = c.m(q, ell(32, 41.5, 2.8 * k, 2.8 * k)) & sand
    c.add(qm, HEDGED)
    c.edge(qm, K.UMBER2)
    # face on the sand, flanking the question dot
    c.eye(18.5, 32, look=(1, -1))
    c.eye(45.5, 32, look=(-1, -1))
    c.blush(16, 37)
    c.blush(47, 37)

K.render_pal(fn, 'pl-labi-5', 'Questionmark Bubble', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-labi-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-labi-5.png')
