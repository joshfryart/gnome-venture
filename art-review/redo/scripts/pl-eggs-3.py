"""pl-eggs-3 "Spring Chick": inner-TBTB, round. A square fluffy yellow chick IS the piece: wing tabs W and E, a blank N cut into the
painted-egg shell cap it still wears (red/yellow stripes of the roof egg), a blank S between its orange feet in the cell's meadow greens."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

CHICK = ramp('#f6cf3a')
WING = ramp('#e8b020')
EGGR = ramp('#e83f3c')
EGGY = ramp('#fce679')
BEAK = ramp('#ef7431')
G1 = ramp('#80bc50')
G2 = ramp('#44844a')
GL = '#a8d464'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 11, 51, 53)
    corners = lambda x, y: ((x < 15 or x >= 49) and (y < 13 or y >= 51))
    tW = knob('T', 'round', 13, 31, -1, 0, r=5.0 * k)
    tE = knob('T', 'round', 51, 31, 1, 0, r=5.0 * k)
    bN = knob('B', 'round', 32, 11, 0, -1, r=4.0 * k)
    bS = knob('B', 'round', 32, 53, 0, 1, r=4.0 * k)
    body = c.m(core, minus=(bN, bS, corners))
    c.add(body, CHICK, stitch=None if c.small else '#fbe48a')
    # wings (tabs) with a feather notch
    for t, side in ((tW, -1), (tE, 1)):
        w = c.m(t, minus=(core,)) | (c.m(t) & c.m(rect(10, 0, 15, 64) if side < 0 else rect(49, 0, 54, 64)))
        c.add(w, WING)
        c.edge(c.m(t) & c.m(rect(10, 0, 15, 64) if side < 0 else rect(49, 0, 54, 64)), WING[1])
    # painted eggshell cap on the head: big zigzag crack edge, cream shell with the roof egg's red and yellow bands
    zz = lambda x: 3.0 * abs(((x - 13) % 6) - 3) / 3
    zig = lambda x, y: y < 19 + zz(x)
    cap = c.m(zig, minus=(bN,)) & body
    c.add(cap, ramp('#fbf2dc'))
    c.add(cap & c.m(lambda x, y: 12.5 <= y < 15.5), EGGR)
    c.add(cap & c.m(lambda x, y: 15.5 <= y < 18), EGGY)
    c.edge(cap, '#c06a10')
    # meadow (cell greens) at the feet, wavy top, blank cut between the feet
    gr = c.m(lambda x, y: y >= 46 + (1.5 if (int(x) // 3) % 2 else 0)) & body
    c.add(gr, G1)
    c.add(gr & c.m(lambda x, y: y >= 50), G2)
    # feet: three orange toes each
    for fx in (23, 41):
        c.add(c.m(rect(fx - 1, 42, fx + 1.5, 46), rect(fx - 4.5, 45, fx + 5, 47.5)) & body, BEAK)
        if not c.small:
            for dx in (-2, 1):
                c.px(*c.P(fx + dx + 0.5, 47), BEAK[1])
    # face
    c.eye(25, 28)
    c.eye(39, 28)
    c.add(c.m(poly([(28, 32), (36, 32), (32, 37.5)])), BEAK)
    c.blush(21, 33)
    c.blush(42, 33)
    # fluff tufts on the chest
    if not c.small:
        for (x, y) in [(30, 40), (32, 41), (34, 40), (26, 38), (38, 38)]:
            c.px(x, y, CHICK[2])


K.render_pal(fn, 'pl-eggs-3', 'Spring Chick', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-eggs-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-eggs-3.png')
