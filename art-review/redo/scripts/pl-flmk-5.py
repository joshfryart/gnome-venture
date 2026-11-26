import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, ramp, UMBER

STRAW = ramp('#d8a24a')
RIM = ramp('#a8682a')
PINK = ramp('#ee9aa6')
MINT = ramp('#9ed69a')
CANT = ramp('#e8b048')
TEAL = ramp('#3f9fb4')
WEAVE = '#a87430'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(9, 28, 55, 58)
    mL = ell(20, 22.5, 11, 8.8)
    mR = ell(44, 22.5, 11, 8.8)
    mC = ell(32, 24, 4, 4)
    bN = knob('B', 'round', 32, 28.5, 0, -1, r=3.8 * k)
    bW = knob('B', 'round', 9, 44, -1, 0, r=3.6 * k)
    bE = knob('B', 'round', 55, 44, 1, 0, r=3.6 * k)
    bS = knob('B', 'round', 32, 58, 0, 1, r=3.4 * k)
    cut = (bN, bW, bE, bS)
    body = c.m(core, mL, mR, mC, minus=cut)
    c.add(body, STRAW, stitch=None)
    # melons heaped on top
    c.add(c.m(mC, minus=cut + (rect(0, 28, 64, 64),)), CANT)
    hl = []
    ml = c.m(mL, minus=cut + (rect(0, 29, 64, 64),))
    mr = c.m(mR, minus=cut + (rect(0, 29, 64, 64),))
    c.add(ml, PINK)
    c.add(mr, MINT)
    c.edge(ml, PINK[1])
    c.edge(mr, MINT[1])
    # glints on the melons
    for gx, gy in ((14.5, 18), (38.5, 18)):
        x, y = c.P(gx, gy)
        c.px(x, y, '#ffffff'); c.px(x + 1, y, '#ffffff')
        if not c.small:
            c.px(x, y + 1, '#ffffff')
    # melon stripes
    if not c.small:
        for (x, y) in mr:
            if (x - y) % 5 == 0 and y < c.P(0, 27)[1]:
                c.px(x, y, MINT[1])
        for (x, y) in ml:
            if (x + y) % 6 == 0 and y < c.P(0, 27)[1]:
                c.px(x, y, '#d87888')
    # basket rim
    rim = c.m(rect(9, 28, 55, 32), minus=cut) & body
    c.add(rim, RIM)
    # weave on basket
    bask = c.m(rect(0, 32, 64, 64)) & body
    step = 4 if not c.small else 3
    for (x, y) in (bask if not c.small else ()):
        r = y // step
        if (x + (r % 2) * (step // 2 + 1)) % (step + 1) == 0:
            c.px(x, y, WEAVE)
        if y % step == 0 and x % 2 == 0:
            c.px(x, y, STRAW[2] if not c.small else WEAVE)
    # canal-teal ribbon band low on the basket
    c.add(c.m(rect(0, 52, 64, 55)) & body, TEAL)
    # face on basket
    if c.small:
        for (x, y) in bask:
            if y % 3 == 1 and (x // 2 + y // 3) % 2 == 0:
                c.px(x, y, WEAVE)
    for (x, y) in c.m(rect(18, 34, 46, 47)):
        c.over.pop((x, y), None)
    c.eye(24, 38)
    c.eye(40, 38)
    c.blush(20, 42)
    c.blush(43, 42)
    c.smile(32, 41.5)


K.render_pal(fn, 'pl-flmk-5', 'Basket Rock', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-flmk-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-flmk-5.png')
