# Lantern Wink: a hooded smuggler's lantern that IS an inner piece. inner-TBTB, tri knobs:
# T top = the hood's pointed spire, T bottom = the lantern's pointed foot, B left/right = notches cut into the
# iron frame and glass. Hood and frame in the cave-rock blues of cell 3-5, glass in the boat-lantern gold glow.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp

ROCK = ramp('#49667f')      # cave rock (73,102,131)
NAVY = ramp('#1e3a60')      # night sea / iron
GLOW = ramp('#f0a830')      # lantern glow from the picture
HOT = ramp('#f8d775')
FLAME = ramp('#e0602a')


def fn(c):
    k = 1.1 if c.small else 1.0
    core = rect(12, 19, 52, 55)
    tabN = knob('T', 'tri', 32, 19, 0, -1, r=4.4 * k)
    tabS = knob('T', 'tri', 32, 55, 0, 1, r=3.5 * k)
    blankW = knob('B', 'tri', 12, 38, -1, 0, r=(4.6 if c.small else 4.0))
    blankE = knob('B', 'tri', 52, 38, 1, 0, r=(4.6 if c.small else 4.0))
    minus = (blankW, blankE)
    ringw = 2.6 if not c.small else 3.2
    ring = lambda x, y: (3.6 - ringw / 2) ** 2 < (x - 32) ** 2 + (y - 5.2) ** 2 < (3.6 + ringw / 2) ** 2
    body = c.m(core, tabN, tabS, ring, minus=minus)
    c.add(body, NAVY)
    # domed hood with the spire (top tab) and a carry ring
    hood = c.m(tabN, ring, poly([(12, 28), (12, 23), (20, 17.5), (44, 17.5), (52, 23), (52, 28)]), minus=minus) & body
    c.add(hood, ROCK, stitch=None if c.small else ROCK[2])
    # glass behind a cage of two iron bars
    glass = c.m(rect(19, 28, 45, 49), minus=minus)
    c.add(glass, GLOW)
    c.add(c.m(ell(32, 39, 7.5, 8), minus=minus) & glass, HOT)
    bw = 2.0 if not c.small else 2.4
    c.add(c.m(rect(23.5 - bw / 2, 28, 23.5 + bw / 2, 49), rect(40.5 - bw / 2, 28, 40.5 + bw / 2, 49)), NAVY)
    # base band + foot (bottom tab)
    base = c.m(rect(12, 49, 52, 55), tabS) & body
    c.add(base, ROCK)
    c.edge(hood, ROCK[1])
    c.edge(base, ROCK[1])
    # flame
    c.add(c.m(poly([(29.5, 48.5), (32, 41.5), (34.5, 48.5)])), FLAME)
    # face on the glass: left eye open, right eye winking
    c.eye(28.5, 35)
    ex, ey = c.P(36, 35)
    if not c.small:
        for dx, dy in ((-1, 0), (0, -1), (1, -1), (2, 0)):
            c.px(ex + dx, ey + dy, K.UMBER)
    else:
        for dx, dy in ((0, 0), (1, -1), (2, 0)):
            c.px(ex + dx, ey + dy, K.UMBER)
    if not c.small:
        for x in (20, 32, 44):
            c.px(*c.P(x, 25), ROCK[2])


K.render_pal(fn, 'pl-scg-3', 'Lantern Wink', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-scg-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-scg-3.png')
