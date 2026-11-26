import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
import math

PURP = K.ramp('#8a5a8e')
GOLD = K.ramp('#c9a239')
SPAR = K.ramp('#6a4426')
SPARC = '#5a3a20'

T, R, B, L = (32, 2), (57, 21), (32, 53), (7, 21)


def side(a, b, kind, c, r, t=0.5):
    mx, my = a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t
    dx, dy = b[0] - a[0], b[1] - a[1]
    ln = math.hypot(dx, dy)
    nx, ny = dy / ln, -dx / ln          # outward for clockwise order T->R->B->L
    return K.knob(kind, 'hook', mx, my, nx, ny, r=r)


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 4.0 * k
    core = K.poly([T, R, B, L])
    bNE = side(T, R, 'B', c, 3.1 * k, 0.58)
    bNW = side(L, T, 'B', c, 3.1 * k, 0.42)
    tSE = side(R, B, 'T', c, r)
    tSW = side(B, L, 'T', c, r)
    body = c.m(core, tSE, tSW, minus=(bNE, bNW))
    cx, cy = 32, 21
    # quadrants: upper-left purple, upper-right gold, lower-left gold, lower-right purple (as in the cell)
    c.add({p for p in body if (p[0] + .5) / c.k < cx and (p[1] + .5) / c.k < cy}, PURP)
    c.add({p for p in body if (p[0] + .5) / c.k >= cx and (p[1] + .5) / c.k < cy}, GOLD)
    c.add({p for p in body if (p[0] + .5) / c.k < cx and (p[1] + .5) / c.k >= cy}, GOLD)
    c.add({p for p in body if (p[0] + .5) / c.k >= cx and (p[1] + .5) / c.k >= cy}, PURP)
    # tail: a wavy string from the bottom tip, tied with bows ("knots")
    w = 2.6 if not c.small else 3.0
    tail = [(32, 52), (30, 56), (26, 58.5), (20, 58), (14, 59), (6, 62)]
    c.add(c.m(K.thick_path(tail, w)), SPAR)
    for (bx, by, col) in ((25, 58.3, PURP), (13, 59.2, GOLD)):
        bs = 4.2 if not c.small else 4.6
        c.add(c.m(K.poly([(bx, by), (bx - bs, by - bs), (bx - bs, by + bs)]),
                  K.poly([(bx, by), (bx + bs, by - bs), (bx + bs, by + bs)]), K.ell(bx, by, 1.4, 1.4)), col)
    # spars: vertical and cross spar
    sw = 1.0 if not c.small else 1.0
    for (a, b) in ((T, B), (L, R)):
        c.line([a, b], SPARC)
    if not c.small:
        c.line([(T[0] + 1 / c.k, T[1]), (B[0] + 1 / c.k, B[1])], SPARC)
        c.line([(L[0], L[1] + 1 / c.k), (R[0], R[1] + 1 / c.k)], SPARC)
    # face in the middle, eyes flanking the spar above the cross spar
    c.eye(26, 29, disc=True)
    c.eye(38.5, 29, disc=True)
    c.smile(32.5, 37, K.UMBER)
    c.blush(22.5, 34)
    c.blush(41.5, 34)


K.render_pal(fn, 'mm-kite-knot', 'Kite Knot', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mm-kite-knot-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mm-kite-knot.png')
