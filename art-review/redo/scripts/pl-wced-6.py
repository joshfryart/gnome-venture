import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp, UMBER, UMBER2

# whimsy-woodspirit, keyhole: carved cedar-wood spirit (kokeshi peg doll) meditating.
# N tab = cedar sprig topknot, S tab = mist puff, W + E blanks = carved waist. Cedar-tier cap + red ribbon (picture), peach/lavender mist (cell 2-2).
WOOD = ramp('#c08850')
GRAIN = '#8a5a2c'
CEDAR = ramp('#3c8958')
CEDAR2 = ramp('#5aa865')
RIB = ramp('#ee4b3a')
MIST = ramp('#9a9cc0')
PEACH = ramp('#f6cf98')
CREAMM = '#fff3e2'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(11, 17, 53, 53)
    dome = ell(32, 21, 21, 6.5)
    tabN = knob('T', 'keyhole', 32, 15.5, 0, -1, r=4.6 * k)
    tabS = knob('T', 'keyhole', 32, 53, 0, 1, r=4.6 * k)
    blW = knob('B', 'keyhole', 11, 37, -1, 0, r=3.6 * k)
    blE = knob('B', 'keyhole', 53, 37, 1, 0, r=3.6 * k)
    shape = c.m(rect(11, 22, 53, 53), dome, minus=(blW, blE))
    c.add(shape, WOOD, stitch='#e0b078')
    # cedar-tier cap: two green bands like the cedar's layers
    cap = c.m(dome, minus=(rect(0, 21.5, 64, 64),)) | c.m(rect(11, 20, 53, 23))
    c.add(cap & shape, CEDAR)
    tier = c.m(ell(32, 17.5, 13, 3.6))
    c.add(tier & shape, CEDAR2)
    c.edge(tier & shape, CEDAR[1])
    c.add(c.m(tabN, minus=(dome,)), CEDAR2)
    # red ribbons hanging from the cap (the tree's red tags)
    for rx in (14, 50):
        c.add(c.m(rect(rx - 1.4, 22, rx + 1.4, 28.5)) & shape, RIB)
    # carved grain rings on the lap
    if not c.small:
        c.line([(16, 41), (20, 39.5)], GRAIN); c.line([(44, 39.5), (48, 41)], GRAIN)
    # mist cushion at the base (cell colours)
    mist = c.m(rect(0, 47, 64, 64), ell(20, 47, 8, 3), ell(42, 46.5, 9, 3)) & shape
    c.add(mist, PEACH)
    c.add(c.m(tabS, minus=(rect(0, 0, 64, 53),)), PEACH)
    c.add(c.m(rect(0, 50.5, 64, 53)) & shape, MIST)
    c.edge(mist, PEACH[1])
    # folded hands / crossed legs carved in the lap
    if not c.small:
        c.line([(19, 44), (26, 46), (32, 44.5), (38, 46), (45, 44)], GRAIN)
        c.line([(27, 41), (32, 43), (37, 41)], GRAIN)
        c.line([(15, 33), (15, 36)], GRAIN)
        c.line([(49, 30), (49, 34)], GRAIN)
    else:
        c.line([(19, 45), (32, 44), (45, 45)], GRAIN)
    # hands: little round knuckles in a mudra
    hx, hy = c.P(32, 42)
    for dx in ((-1, 0) if c.small else (-2, -1, 0, 1)):
        c.px(hx + dx, hy, WOOD[2])
    # meditating face: closed eyes (umber arcs), small smile, blush
    for ex in (25, 39):
        x, y = c.P(ex, 28)
        if c.small:
            c.px(x - 1, y, UMBER); c.px(x, y + 1, UMBER); c.px(x + 1, y + 1, UMBER); c.px(x + 2, y, UMBER)
        else:
            for dx in range(-2, 3):
                c.px(x + dx, y + (1 if abs(dx) < 2 else 0), UMBER)
            c.px(x - 2, y + 1, UMBER); c.px(x + 2, y + 1, UMBER)
    c.smile(32, 31.5)
    c.blush(20, 31)
    c.blush(44, 31)


K.render_pal(fn, 'pl-wced-6', 'Branch Meditator', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wced-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wced-6.png')
