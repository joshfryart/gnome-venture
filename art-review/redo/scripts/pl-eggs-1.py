"""pl-eggs-1 "Painted Bough": corner-TB, round. A little clipped tree: the leafy canopy is the square piece body (flat top and
left sides), the trunk + grassy root mound is the round tab on the bottom, a round blank bites the right side. Striped painted eggs
(red/yellow, blue, pink) hang in the leaves, as on the tree and fence in the Painted Egg House picture (cell 1-3 is the sky above it)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

LEAF = ramp('#5f9e48')
LEAF2 = ramp('#8cc46a')
BARK = ramp('#8a5743')
GRASS = ramp('#7dba4e')
RED, YEL, BLUE, PINK = '#e0483a', '#f5cf5a', '#5aa8e6', '#f89fbb'
SKY = '#b7e4f0'


def rounded(x0, y0, x1, y1, r):
    return lambda x, y: (rect(x0 + r, y0, x1 - r, y1)(x, y) or rect(x0, y0 + r, x1, y1 - r)(x, y)
                         or any(ell(cx, cy, r, r)(x, y) for cx in (x0 + r, x1 - r) for cy in (y0 + r, y1 - r)))


def egg(c, x, y, cols):
    """Small striped egg centred at 64-unit (x, y): rows of colours top to bottom."""
    cx, cy = c.P(x, y)
    if c.small:
        rows = [(0, 1), (-1, 2), (-1, 2), (0, 1)]
        cols = [cols[0], cols[1], cols[0], cols[0]]
    else:
        rows = [(0, 1), (-1, 2), (-1, 2), (-1, 2), (-1, 2), (0, 1)]
    for i, (a, b) in enumerate(rows):
        col = cols[i % len(cols)]
        for dx in range(a, b + 1):
            c.px(cx + dx, cy + i - len(rows) // 2, col)
    # hanging thread
    c.px(cx, cy - len(rows) // 2 - 1, K.UMBER2)


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rounded(8, 6, 54, 42, 3)
    lumps = [ell(x, 43, 4.6, 3.6) for x in (12.5, 21, 39, 49.5)]
    tabS = knob('T', 'round', 30, 45, 0, 1, r=6.2 * k, nw=4.6)
    blkE = knob('B', 'round', 54, 24, 1, 0, r=4.6 * k)
    canopy = c.m(core, *lumps, minus=(blkE,))
    c.add(canopy, LEAF, stitch=LEAF[1])
    # light leaf clumps (upper-left lit)
    clumps = c.m(ell(18, 15, 7, 5), ell(32, 13, 8, 5), ell(45, 16, 6, 5), ell(14, 30, 4.5, 6), minus=(blkE,)) & canopy
    c.add(clumps, LEAF2)
    c.edge(clumps, LEAF[0])
    # trunk neck and grassy root mound (the tab)
    trunk = c.m(tabS, minus=(core, *lumps))
    c.add(trunk, BARK)
    ball = trunk & c.m(rect(0, 53.5, 64, 64))
    c.add(ball, GRASS)
    c.edge(ball, GRASS[1])
    c.add(c.m(ell(30, 53.5, 4.2, 1.6)) & trunk, BARK)   # root flare
    c.line([(28, 46), (28, 51)], BARK[1])
    if not c.small:
        c.line([(32, 47), (32, 50)], BARK[1])
    # painted eggs hanging in the leaves
    egg(c, 15, 20, [RED, YEL])
    egg(c, 46, 36, [BLUE, '#f4f0e4'])
    egg(c, 40, 10, [PINK, YEL])
    egg(c, 13, 37, [YEL, RED])
    if not c.small:
        egg(c, 24, 9, [BLUE, YEL])
        egg(c, 47, 9, [RED, '#f4f0e4'])
    # face on the calm centre of the canopy
    c.eye(26, 27, disc=True)
    c.eye(37, 27, disc=True)
    c.smile(31.5, 33)
    c.blush(21.5, 31)
    c.blush(40.5, 31)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-eggs-1', 'Painted Bough', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-eggs-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-eggs-1.png')
    print(rep)
