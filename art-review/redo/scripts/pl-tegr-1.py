# Heapsy Basket: a wicker tea basket heaped with tea leaves = corner piece. Flat left + flat bottom (basket side and base),
# keyhole blank cut down into the leaf heap on top, keyhole blank cut into the wicker on the right. Colours from cell 0-6:
# bright tea-bush greens with pink blossoms, stone-wall tan and soil brown.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, ramp, UMBER2

LEAF = ramp('#5cb040')
LEAF2 = ramp('#8cd048')
WICK = ramp('#b8864a')
RIM = ramp('#8a5a30')
PINK = '#f4a6c4'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(8, 14, 55, 52)
    base = rect(10, 50, 53, 56)
    bumps = [ell(13, 14, 5.5, 4.5), ell(22, 12.5, 5.5, 4.5), ell(42, 12.5, 5.5, 4.5), ell(50, 14, 5.5, 4.5)]
    rimband = rect(8, 31, 56.5, 35)
    drips = [ell(15, 36.5, 3.2, 3.2), ell(27, 36, 2.6, 2.6), ell(45, 36.5, 3.2, 3.2)]
    blankN = knob('B', 'keyhole', 32, 12, 0, -1, r=5.2 * k, nw=2.0)
    blankE = knob('B', 'keyhole', 55, 44, 1, 0, r=4.6 * k, nw=1.8)
    body = c.m(core, base, rimband, *bumps, minus=(blankN, blankE))
    # leaf heap (top) and basket (bottom)
    c.add(body, LEAF)
    c.add(body & c.m(*[ell(x, y, 6, 4.5) for x, y in ((14, 18), (26, 21), (39, 20), (50, 18), (20, 27), (44, 27))]), LEAF2)
    basket = body & c.m(rect(0, 31, 64, 64))
    c.add(basket, WICK)
    rim = body & c.m(rect(0, 31, 64, 35))
    c.add(rim, RIM)
    c.add(c.m(*drips, minus=(blankE,)), LEAF2)
    # braided rim: diagonal ticks
    dm = c.m(*drips)
    ry0, ry1 = c.P(0, 31)[1], c.P(0, 35)[1]
    for x in range(c.P(8, 0)[0], c.P(57, 0)[0]):
        for y in range(ry0, ry1):
            if not c.small and (x, y) not in dm and (x + y) % 4 == 0:
                c.px(x, y, RIM[2])
    # leaf veins / blossoms
    for (x, y) in ((14, 17), (26, 20), (39, 19), (50, 17), (20, 26), (44, 26)):
        c.line([(x - 2.5, y + 1.5), (x + 2.5, y - 1.5)], LEAF[1])
    for (x, y) in ((18, 22), (45, 15), (33, 26), (11, 27), (51, 26)):
        px, py = c.P(x, y)
        c.px(px, py, PINK)
        if not c.small:
            c.px(px + 1, py, PINK)
    # wicker weave
    step = 2 if c.small else 3
    x0, x1 = c.P(9, 0)[0], c.P(54, 0)[0]
    y0, y1 = c.P(0, 36)[1], c.P(0, 55)[1]
    for y in range(y0, y1):
        row = (y - y0) // step
        for x in range(x0, x1):
            if (x // step + row) % 2 == 0 and (y - y0) % step == 0:
                c.px(x, y, WICK[1])
            if (x // step + row) % 2 == 1 and x % step == 0:
                c.px(x, y, WICK[1])
    # face on the basket
    c.eye(22, 42, disc=True)
    c.eye(38, 42, disc=True)
    c.smile(30, 47)
    c.blush(16.5, 46)
    c.blush(42.5, 46)


K.render_pal(fn, 'pl-tegr-1', 'Heapsy Basket', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tegr-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tegr-1.png')
