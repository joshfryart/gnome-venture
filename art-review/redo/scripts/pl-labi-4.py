# pl-labi-4 "Hedgerow Swirls": a clipped topiary hedge block on a little trunk, inner-TTTT keyhole.
# N tab = leafy top tuft, W/E tabs = clipped hedge lobes, S tab = trunk stub. A sandy maze lane spirals
# round the body (the labyrinth's sand paths between hedge walls, cell 3-5), the face sits in the hedge heart.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, knob

HEDGE = K.ramp('#5cb43c')
HEDGED = K.ramp('#3a8a30')
LEAF = K.ramp('#9ad85a')
SAND = K.ramp('#efd49a')
TRUNK = K.ramp('#9a6a3a')
DOT = '#d4a470'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 14, 13, 50, 49
    core = rect(x0, y0, x1, y1)
    tN = knob('T', 'keyhole', 32, y0, 0, -1, r=5.4 * k, nw=3.0)
    tS = knob('T', 'keyhole', 32, y1, 0, 1, r=4.6 * k)
    tW = knob('T', 'keyhole', x0, 31, -1, 0, r=5.2 * k, nw=3.0)
    tE = knob('T', 'keyhole', x1, 31, 1, 0, r=5.2 * k, nw=3.0)
    c.add(c.m(core, tW, tE), HEDGE, stitch=None)
    c.add(c.m(tN, minus=(core,)) | c.m(rect(25, y0 - 1, 39, y0 + 1)) & c.m(tN), LEAF)
    c.add(c.m(tS, minus=(core,)), TRUNK)
    # sandy maze lane: a square spiral ring with an entrance gap at upper left
    w = 4.2 if not c.small else 4.6
    a = 19.5
    b = 64 - a - 0.0
    ring = c.m(rect(a, a - 1, b, b - 1), minus=(rect(a + w, a + w - 1, b - w, b - w - 1),))
    gap = c.m(rect(a - 6, a - 1, a + w, a + 3.5))       # lane opens out of the hedge at upper left
    spur = c.m(rect(a + w - 0.5, 30, a + w + 5, 30 + w))  # lane turns inward on the left: the swirl
    lane = (ring | spur) - c.m(rect(a, a - 1 + w, a + w, a + w + 3))  # a hedge wall blocks the ring once
    c.add(lane, SAND)
    c.add(c.m(rect(a - 6, a - 1, a, a + 3.5)) & c.m(core), SAND)
    c.edge(lane, SAND[1])
    if not c.small:
        for (x, y) in lane:
            if (x * 7 + y * 3) % 11 == 0:
                c.px(x, y, DOT)
    # leaf speckle on the hedge walls
    for (x, y) in c.m(core, tW, tE):
        if (x * 5 + y * 3) % (9 if not c.small else 7) == 0 and (x, y) not in lane:
            c.px(x, y, HEDGED[0])
    # face in the hedge heart
    c.eye(29, 34, disc=False)
    c.eye(36, 34, disc=False)
    c.smile(32.5, 38)
    if not c.small:
        c.blush(26, 37)
        c.blush(38, 37)


K.render_pal(fn, 'pl-labi-4', 'Hedgerow Swirls', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-labi-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-labi-4.png')
