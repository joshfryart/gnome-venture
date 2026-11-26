"""pl-kava-5 "Shared Cup": the tanoa kava bowl IS an inner-BBBB round piece. N blank = a dip in the pale kava (bilo cup floats beside it),
E/W blanks bite into the carved wooden flanks, S blank opens between the stubby legs. Wood oranges/browns, grey kava, gold dots (cell 6-7)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp, UMBER, UMBER2

WOOD = ramp('#8a4838')
WOODLT = ramp('#c87840')
RIM = ramp('#e49c58')
KAVA = ramp('#bcae98')
SHELL = ramp('#4e2a38')
GOLD = '#ffc070'


def fn(c):
    k = 1.15 if c.small else 1.0
    # bowl: wide rim on top (flat N side), straight flanks, rounded belly, four stubby legs
    upper = rect(8, 12, 56, 35)
    belly = ell(32, 34, 24, 13)
    legs = (poly([(12, 40), (19, 44), (18, 56), (12, 56)]), poly([(52, 40), (45, 44), (46, 56), (52, 56)]),
            rect(20, 44, 25.5, 56), rect(38.5, 44, 44, 56))
    bN = knob('B', 'round', 32, 12, 0, -1, r=4.2 * k)
    bE = knob('B', 'round', 56, 33, 1, 0, r=4.2 * k)
    bW = knob('B', 'round', 8, 33, -1, 0, r=4.2 * k)
    bS = knob('B', 'round', 32, 56, 0, 1, r=4.4 * k)
    bl = (bN, bE, bW, bS)
    body = c.m(upper, belly, *legs, minus=bl)
    c.add(body, WOOD, stitch=None)
    # lighter carved flank band
    band = c.m(rect(8, 25, 56, 38), minus=bl) & body
    c.add(band, WOODLT)
    # rim ring (ellipse seen from above) and the kava inside
    rim = c.m(rect(8, 12, 56, 26), minus=bl)
    c.add(rim, RIM)
    kava = c.m(ell(32, 19, 21, 5.2), minus=bl)
    c.add(kava, KAVA)
    c.edge(kava, KAVA[1])
    c.edge(c.m(rect(0, 25, 64, 26)) & body, WOOD[1])
    # coconut-shell cup (bilo) floating on the kava
    c.add(c.m(ell(44, 19, 4.2, 2.4)), SHELL)
    # gold dots along the band (the cell's glints)
    for gx in ((16, 24, 40, 48) if not c.small else (16, 48)):
        x, y = c.P(gx, 37)
        c.px(x, y, GOLD)
        if not c.small:
            c.px(x + 1, y, GOLD)
    # face on the flank band
    c.eye(23, 30.5)
    c.eye(41, 30.5)
    c.smile(32, 33.5)
    c.blush(18, 34)
    c.blush(46, 34)


K.render_pal(fn, 'pl-kava-5', 'Shared Cup', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-kava-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-kava-5.png')
