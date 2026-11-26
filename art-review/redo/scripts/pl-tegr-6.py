"""pl-tegr-6 Beaming Headpicker (whimsy-picker, keyhole): a chibi tea picker whose silhouette is a puzzle piece.
N keyhole tab = the straw cone hat's tip knob; E + W keyhole tabs = peach mitt hands; S keyhole blank cut into the basket.
Cell 11-5: bright green tea-bush hedge over a tan stone terrace wall -> leaves heaped in a stone-brick-woven basket."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

STRAW = ramp('#e8d4a8')
BAND = ramp('#b49a7a')
SKIN = ramp('#f2c08e')
LEAF = ('#8ccc48', '#3a6a3c', '#d8f080')
LEAF2 = ramp('#5a9a44')
WALL = ('#b49a7a', '#7c6a6a', '#e8d4a8')
MORTAR = '#7c6a6a'


def fn(c):
    k = 1.15 if c.small else 1.0
    hat = poly([(4, 20), (32, 5), (60, 20), (55, 22.5), (9, 22.5)])
    face = ell(32, 29, 13.5, 9)
    basket = rect(12, 36, 52, 59)
    tabN = knob('T', 'keyhole', 32, 6.5, 0, -1, r=4.6 * k, nw=2.2)
    tabE = knob('T', 'keyhole', 52, 47, 1, 0, r=4.2 * k)
    tabW = knob('T', 'keyhole', 12, 47, -1, 0, r=4.2 * k)
    blankS = knob('B', 'keyhole', 32, 59, 0, 1, r=4.4 * k, nw=2.0)
    c.add(c.m(face), SKIN)
    c.add(c.m(ell(20.5, 24.5, 2.8, 3.8), ell(43.5, 24.5, 2.8, 3.8)), ramp('#6a3e24'))
    bm = c.add(c.m(basket, minus=(blankS,)), WALL, stitch=None)
    c.add(c.m(tabE, tabW, minus=(basket,)), SKIN)
    # heaped tea leaves on top of the basket
    leaves = c.m(ell(15.5, 38.5, 4.5, 4), ell(23.5, 37.5, 5, 4.5), ell(40.5, 37.5, 5, 4.5), ell(48.5, 38.5, 4.5, 4), rect(12, 39, 52, 43))
    c.add(leaves, LEAF)
    c.add(c.m(hat, tabN), STRAW, stitch=None if c.small else '#c8b08a')
    c.add(c.m(poly([(10.5, 17.5), (53.5, 17.5), (56, 19.3), (8, 19.3)])), BAND)
    # leaf clumps (darker) like the hedge in the cell
    for (lx, ly) in ((18, 40), (27, 39.5), (37, 39.5), (46, 40)):
        x, y = c.P(lx, ly)
        for dx in range(0, 2 if c.small else 3):
            c.px(x + dx, y + 1, LEAF2[0])
        if not c.small:
            c.px(x + 1, y, LEAF[2])
    # stone-brick weave on the basket (cell's terrace wall)
    rows = (48, 53.5) if not c.small else (48.5, 54)
    y0 = c.P(0, 43)[1]
    for x in range(c.P(12, 0)[0], c.P(52, 0)[0]):
        c.px(x, y0, MORTAR)
    for ri, ry in enumerate(rows):
        yy = c.P(0, ry)[1]
        for x in range(c.P(12, 0)[0], c.P(52, 0)[0]):
            if (x, yy) in bm:
                c.px(x, yy, MORTAR)
    for ri, (ya, yb) in enumerate(((43, 48), (48, 53.5), (53.5, 59))):
        xs = (20, 32, 44) if ri % 2 == 0 else (26, 38)
        for bx in xs:
            x = c.P(bx, 0)[0]
            for y in range(c.P(0, ya)[1] + 1, c.P(0, yb)[1]):
                if (x, y) in bm:
                    c.px(x, y, MORTAR)
    # a tea sprig in the west mitt
    sx, sy = c.P(6, 43)
    for d in range(2 if c.small else 3):
        c.px(sx + d, sy - d, LEAF[0])
        c.px(sx + d + 1, sy - d, LEAF[2] if d == 0 else LEAF[0])
    # face: beaming grin
    c.eye(27, 27.5)
    c.eye(37, 27.5)
    c.smile(32, 31.5, wide=True)
    c.blush(23.5, 31)
    c.blush(39.5, 31)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-tegr-6', 'Beaming Headpicker', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tegr-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tegr-6.png'))
