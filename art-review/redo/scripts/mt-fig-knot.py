#!/usr/bin/env python3
"""mt-fig-knot "Fig Knot": inner-TTBB, hook. A strangler fig, face on: the piece's top half is the leafy green canopy (hook tab N, a curling
sprout), the bottom half a pale bark trunk wrapped in a net of dark aerial roots (hook tab E = a root curling out). Hook blanks W and S:
the S blank opens between two splayed root feet. Pink figs on the canopy; greens, bark tans and the pink fruit from cell 9-1."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

LEAF = K.ramp('#2f8a4f')
LEAF2 = ('#1f6944', '#174f33', '#5aa86a')
BARK = ('#c4b494', '#9a8a6c', '#e2d6b8')
ROOT = ('#5a3c24', '#3e2a1a', '#8a6a48')
FIG = K.ramp('#d8407a')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = rect(11, 13, 53, 53)
    tabN = knob('T', 'hook', 32, 13, 0, -1, r=5.4 * s)
    tabE = knob('T', 'hook', 53, 38, 1, 0, r=5.0 * s)
    blankW = knob('B', 'hook', 11, 36, -1, 0, r=4.6 * s, flip=True)
    blankS = knob('B', 'hook', 32, 53, 0, 1, r=4.8 * s)
    crown = c.m(ell(9.5, 21, 4.5, 6.5), ell(54.5, 21, 4.5, 6.5), ell(14, 13.5, 6, 4.5), ell(50, 13.5, 6, 4.5))
    body = c.m(core, tabN, tabE, minus=(blankW, blankS)) | crown
    # trunk (bark) fills the lower body
    c.add(body, BARK)
    # aerial roots: dark strands wrapping the trunk, a knot criss-cross
    rw = 3.6 if not c.small else 4.2
    roots = [
        [(17, 28), (15, 40), (13.5, 53)],
        [(25, 29), (24, 41), (21, 53)],
        [(39, 29), (40, 41), (43, 53)],
        [(47, 28), (49, 40), (51, 53)],
        [(15, 48), (32, 43), (49, 48)],
    ]
    rm = c.m(*[thick_path(p, rw) for p in roots]) & body
    c.add(rm, ROOT)
    c.add(c.m(tabE, minus=(core,)) & body, ROOT)
    # canopy: top half, lumpy lower edge drooping over the trunk
    can = c.m(rect(0, 0, 64, 25), ell(15, 25, 6, 5), ell(26, 27, 6.5, 5), ell(38, 27, 6.5, 5), ell(49, 25, 6, 5)) & body
    c.add(can, LEAF, stitch=None)
    # dark leaf clumps inside the canopy
    for (x, y, rx, ry) in ((20, 19, 5, 3.5), (44, 18, 5, 3.5), (32, 24, 4.5, 3)):
        m = c.m(ell(x, y, rx, ry)) & can
        c.add(m, LEAF2)
    c.add(c.m(tabN, minus=(core,)) & body, LEAF)
    # figs: pink fruit on the canopy
    for (x, y) in ((14, 18), (49, 23), (38, 14)) if not c.small else ((14, 18), (49, 22)):
        r = 3.0 if not c.small else 3.2
        c.add(c.m(ell(x, y, r, r)) & body, FIG)
    # face on the bark between the inner roots
    c.eye(28.5, 35, disc=False)
    c.eye(36, 35, disc=False)
    c.smile(32, 38.5, UMBER2, wide=True)


UMBER2 = K.UMBER2

if __name__ == '__main__':
    rep = K.render_pal(fn, 'mt-fig-knot', 'Fig Knot', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/mt-fig-knot-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mt-fig-knot.png')
    print(rep)
