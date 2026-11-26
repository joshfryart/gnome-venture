# pl-wfri-2 "Ribboned Gift": a pink toadstool-cap gift box that IS an edge piece. Flat S (the box sits on the moss),
# keyhole tab N = the ribbon knot with bow loops, keyhole blanks W and E cut into the box sides.
# Colours from cell 10-6: toadstool pink box + violet cap-top ribbon, cream toadstool spots.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, poly, thick_path

PINK = ('#d8486a', '#a63e64', '#ff8aa0')
VIO = ('#c85ab0', '#9c4992', '#f090d8')
SPOT = '#fff4d6'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(10, 20, 54, 59)
    tabN = knob('T', 'keyhole', 32, 20, 0, -1, r=5.2 * k)
    bW = knob('B', 'keyhole', 10, 46, -1, 0, r=3.7 * k)
    bE = knob('B', 'keyhole', 54, 46, 1, 0, r=3.7 * k)
    loopL = ell(22, 17.8, 6.5, 3.2)
    loopR = ell(42, 17.8, 6.5, 3.2)
    body = c.m(core, minus=(bW, bE))
    c.add(body, PINK)
    # lid band (slightly darker lip across the top)
    lid = body & c.m(rect(0, 20, 64, 26))
    c.add(lid, ('#c8406a', '#a63e64', '#ff8aa0'))
    c.edge(lid, PINK[1])
    # toadstool cream spots on the box
    for (sx, sy, r) in ((17, 41, 2.4), (48, 40, 2.2), (18, 55, 2.2), (46, 55, 2.2)):
        c.add(c.m(ell(sx, sy, r * k, r * k)) & body, (SPOT, '#e8d8b8', SPOT))
    # ribbon: vertical band and horizontal band
    rw = 7 if not c.small else 7.5
    vband = c.m(rect(32 - rw / 2, 20, 32 + rw / 2, 59)) & body
    hband = c.m(rect(10, 28, 54, 28 + rw)) & body
    c.add(vband | hband, VIO)
    # bow: two loops + knot tab
    c.add(c.m(loopL, loopR), VIO)
    knot = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 18, 64, 21)))
    c.add(knot, VIO)
    c.edge(knot, VIO[1])
    if not c.small:
        c.px(*c.P(23, 17.5), VIO[1]); c.px(*c.P(24, 17.5), VIO[1])
        c.px(*c.P(41, 17.5), VIO[1]); c.px(*c.P(40, 17.5), VIO[1])
    else:
        c.px(*c.P(23, 17.5), VIO[1]); c.px(*c.P(41, 17.5), VIO[1])
    c.edge(c.m(tabN) & c.m(rect(0, 0, 64, 20)), VIO[1])
    # face below the horizontal ribbon, either side of the vertical one
    c.eye(24, 43)
    c.eye(40, 43)
    c.smile(32, 50) if not c.small else c.smile(31, 50)
    c.blush(20, 48)
    c.blush(43, 48)


K.render_pal(fn, 'pl-wfri-2', 'Ribboned Gift', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wfri-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wfri-2.png')
