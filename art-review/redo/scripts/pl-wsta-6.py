# pl-wsta-6 "Starwise Cheerer": whimsy-navigator, keyhole knobs.
# A canoe navigator who IS the piece: head = top keyhole tab (red parrot headband), raised fist = east keyhole tab,
# keyhole blank cut into the west of the night-indigo starry cloak, the canoe hull (tan, umber ribs) is the base,
# and the other arm cheers up holding a gold star. Colours from cell 8-6: indigo sky, cream sail, tan hull.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

INDIGO = ramp('#4b3c8e')
SAIL = ramp('#f2e2b4')
HULL = ramp('#e9a860')
SKIN = ramp('#a86a3c')
RED = ramp('#d8343a')
GOLD = ramp('#f2c33a')
RIB = '#5a2a28'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(14, 25, 50, 50)
    head = knob('T', 'keyhole', 32, 25, 0, -1, r=6.0)
    skull = ell(32, 13.5, 8.2, 8.0)
    tabE = knob('T', 'keyhole', 50, 37, 1, 0, r=5.0 * k)
    blankW = knob('B', 'keyhole', 14, 37, -1, 0, r=4.4 * k)
    hull = poly([(7, 43), (12, 47), (20, 50), (44, 50), (52, 47), (57, 43), (56.5, 49), (51, 55), (44, 58), (20, 58), (13, 55), (7.5, 49)])
    arm = thick_path([(21, 26), (15, 18), (10, 13)], 5.0 if not c.small else 5.6)
    star = poly([(9.5, 1.5), (11.5, 6), (16.5, 6.5), (12.5, 9.5), (14, 14), (9.5, 11.5), (5, 14), (6.5, 9.5), (2.5, 6.5), (7.5, 6)])

    body = c.m(core, minus=(blankW,))
    c.add(body, INDIGO, stitch=None if c.small else INDIGO[2])
    # sail-cream collar/sash wedge (the sail corner of the cell)
    c.add(c.m(poly([(22, 25), (42, 25), (32, 33)])), SAIL)
    # raised cheering arm + star
    c.add(c.m(arm, minus=(core,)), INDIGO)
    c.add(c.m(ell(10, 11.5, 3.2, 3.0)), SKIN)
    c.add(c.m(star), GOLD)
    # east fist tab: sleeve flare + fist
    t = c.m(tabE, minus=(core,))
    c.add(t, INDIGO)
    c.add(t & c.m(rect(52.5, 0, 64, 64)), SKIN)
    # head (keyhole tab) + headband
    hm = c.m(head, skull, minus=(core,))
    c.add(hm, SKIN)
    c.add(hm & c.m(rect(0, 5, 64, 9.5)), ramp('#3a2a40'))  # hair
    c.add(hm & c.m(rect(0, 9.5, 64, 12.5)), RED)
    c.add(c.m(ell(42, 11, 2.6, 2.6)), GOLD)  # headband knot
    # canoe hull base with ribs
    hm2 = c.m(hull)
    c.add(hm2, HULL)
    for gx in (14, 22, 30, 38, 46, 52):
        x, _ = c.P(gx, 0)
        for y in range(c.P(0, 50)[1] + 1, c.n):
            if (x, y) in hm2 and (x, y + 1) in hm2:
                c.px(x, y, RIB)
    # stars on cloak
    for sx, sy in ((38, 30), (44, 42), (25, 44), (33, 38)):
        x, y = c.P(sx, sy)
        c.px(x, y, '#fff4c8')
        if not c.small:
            for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(x + d[0], y + d[1], GOLD[0])
    # face
    c.eye(28.5, 16)
    c.eye(35.5, 16)
    c.smile(32, 19.5, wide=not c.small)
    c.blush(25.5, 19)
    c.blush(38.5, 19)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-wsta-6', 'Starwise Cheerer', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wsta-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wsta-6.png')
    print(rep)
