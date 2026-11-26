import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""Slowpage Tortoise (whimsy-tortoise, keyhole). Side-view tortoise whose domed shell is the piece body.
N tab = the stack of books on its back, E tab = neck flare + head in spectacles, W blank cut in the shell,
S blank between front and back legs. Picture: green tortoise with book stack; cell 5-6: brown step stripes, sand."""
from pal_kit import rect, ell, knob, poly, thick_path, ramp, UMBER, UMBER2, CREAM

SHELL = ramp('#3f9a4a')
SCUTE = '#2f6a3a'
SKIN = ramp('#7ab55c')
STEP = ramp('#b07a3a')
STEPD = '#5a3418'
BOOKS = [ramp('#7ab55c'), ramp('#e0802a'), ramp('#3f7fc8'), ramp('#d6322b')]
GOLDR = '#e8a317'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1, yt, yb = 7, 49, 15, 55
    cx = (x0 + x1) / 2
    dome = lambda x, y: (x0 <= x < x1 and 27 <= y < yb) or ell(cx, 28, (x1 - x0) / 2, 13)(x, y)
    tabN = knob('T', 'keyhole', cx, yt, 0, -1, r=6.6 * k, nw=3.6)
    tabE = knob('T', 'keyhole', x1, 41, 1, 0, r=5.8 * k, nw=2.8)
    blankW = knob('B', 'keyhole', x0, 33, -1, 0, r=4.4 * k)
    blankS = knob('B', 'keyhole', cx, yb, 0, 1, r=3.8 * k, nw=2.6)
    hx, hy = x1 + 5.8 * k + 2.6, 40.0
    head = ell(hx, hy, 5.6, 4.6)
    body = c.m(dome, tabN, tabE, head, minus=(blankW, blankS))
    # legs + head (skin) underneath everything
    c.add(body, SKIN)
    # shell dome
    shell = c.m(dome, minus=(blankW, blankS, rect(0, 46, 64, 64)))
    c.add(shell, SHELL)
    # scutes: inner contours of plates
    w = 2.4 if c.small else 1.6
    hexc = [(cx - 6, 24), (cx + 6, 24), (cx + 9, 32), (cx + 6, 40), (cx - 6, 40), (cx - 9, 32), (cx - 6, 24)]
    c.add(c.m(thick_path(hexc, w)) & shell, (SCUTE, SCUTE, SCUTE))
    spokes = [[(cx - 6, 24), (cx - 11, 17)], [(cx + 6, 24), (cx + 11, 17)], [(cx - 9, 32), (x0 + 3, 32)],
              [(cx + 9, 32), (x1, 32)], [(cx - 6, 40), (cx - 9, 46)], [(cx + 6, 40), (cx + 9, 46)]]
    for sp in spokes:
        c.add(c.m(thick_path(sp, w)) & shell, (SCUTE, SCUTE, SCUTE))
    if not c.small:
        for (x, y) in c.m(ell(cx - 3, 30, 3, 2.2)) & shell:
            c.px(x, y, SHELL[2])
    # skirt band: the stepped stripes from the cell
    skirt = c.m(dome, minus=(blankW, blankS, rect(0, 0, 64, 45), rect(0, 50, 64, 64)))
    c.add(skirt, STEP)
    if not c.small:
        for (x, y) in skirt:
            if y == c.P(0, 47.5)[1]:
                c.px(x, y, STEPD)
    else:
        for (x, y) in skirt:
            if y == c.P(0, 48)[1]:
                c.px(x, y, STEPD)
    # book stack on the N tab (horizontal bands)
    tabpix = c.m(tabN, minus=(dome,))
    if tabpix:
        ys = sorted({y for _, y in tabpix})
        top, bot = ys[0], ys[-1]
        nb = 4
        for i, rp in enumerate(BOOKS):
            a = top + (bot - top + 1) * i // nb
            b = top + (bot - top + 1) * (i + 1) // nb
            c.add({p for p in tabpix if a <= p[1] < b}, rp)
        # page edges (cream) on the right end of each book
        for i in range(nb):
            a = top + (bot - top + 1) * i // nb
            b = top + (bot - top + 1) * (i + 1) // nb
            row = [p for p in tabpix if a <= p[1] < b - (0 if c.small else 1)]
            if row and not c.small:
                xm = max(x for x, _ in row)
                for (x, y) in row:
                    if x == xm - 1 and y > a:
                        c.px(x, y, CREAM)
    # head: eye with gold spectacles
    if not c.small:
        ex, ey = c.P(hx + 0.5, hy - 1)
        for dx in range(-3, 4):
            for dy in range(-3, 4):
                if 2.2 <= (dx * dx + dy * dy) ** 0.5 < 3.3:
                    c.px(ex + dx, ey + dy, GOLDR)
        c.eye(hx + 0.5, hy - 0.5)
        # temple arm back to the neck
        c.px(ex - 4, ey - 1, GOLDR); c.px(ex - 5, ey - 1, GOLDR)
        c.smile(hx + 1.5, hy + 2.6, UMBER2)
    else:
        ex, ey = c.P(hx, hy - 1.5)
        for dx, dy in ((-1, -1), (0, -2), (1, -2), (2, -1), (2, 0), (2, 1), (1, 2), (0, 2), (-1, 1), (-1, 0)):
            c.px(ex + dx, ey + dy, GOLDR)
        c.px(ex, ey, UMBER); c.px(ex + 1, ey, UMBER); c.px(ex, ey + 1, UMBER); c.px(ex + 1, ey + 1, UMBER)
        c.px(ex, ey, CREAM)
    # toes on the feet
    if not c.small:
        for fxu in (x0 + 2, x1 - 4):
            fx, fy = c.P(fxu, yb - 1)
            c.px(fx, fy, SKIN[1]); c.px(fx + 2, fy, SKIN[1])


K.render_pal(fn, 'pl-wmud-6', 'Slowpage Tortoise', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wmud-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wmud-6.png')
