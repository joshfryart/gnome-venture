import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import math
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp, thick_path

# Edge-TBB, tri: a slag drip hanging off the forge lip. Flat N = iron lip it hangs from; tri tab S = the drip's falling point;
# tri blanks W and E pinch the sides like a drop about to let go. Molten yellow -> orange -> red crust from cell 3-7.
IRON = ramp('#6e6a7a')
HOT = ramp('#ffe66a')
GLOW = ramp('#ffc04b')
ORNG = ramp('#ff9a2c')
CRUST = ramp('#e04a2c')
PALE = '#fff0a0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(9, 8), (55, 8), (55, 46), (50, 54), (40, 57), (24, 57), (14, 54), (9, 46)])
    tabS = knob('T', 'tri', 32, 56.5, 0, 1, r=4.6 * k)
    blW = knob('B', 'tri', 9, 34, -1, 0, r=4.8 * k)
    blE = knob('B', 'tri', 55, 34, 1, 0, r=4.8 * k)
    body = c.m(core, tabS, minus=(blW, blE))
    c.add(body, ORNG, stitch=None)
    # lower crust: smooth cooling bowl of red at the bottom and the tip
    c.add(body & c.m(lambda x, y: y > 49 + 0.012 * (x - 32) ** 2 * -1 + 3), CRUST)
    # glowing band, then hot yellow pouring off the lip in round-ended drip tongues
    c.add(body & c.m(rect(0, 0, 64, 25)), GLOW)
    w = 6.0 if not c.small else 7.0
    tongues = [thick_path([(x, 14), (x, y)], w) for x, y in ((15, 25), (25, 31), (35, 22), (46, 28))]
    c.add(body & c.m(rect(0, 0, 64, 19), *tongues), HOT)
    # iron forge lip along the flat top
    c.add(body & c.m(rect(0, 0, 64, 13.5)), IRON)
    if not c.small:
        for x in range(c.P(11, 0)[0], c.P(54, 0)[0], 6):
            c.px(x, c.P(0, 10.5)[1], '#4a4856')   # rivets
        # pale highlights in the hot metal
        c.line([(17, 17), (21, 17)], PALE)
        c.line([(25, 20), (25, 26)], PALE)
        c.line([(46, 21), (46, 24)], PALE)
        c.line([(46, 30), (46, 33)], '#ffd070')
    else:
        c.line([(18, 17), (21, 17)], PALE)
    # face on the calm orange middle
    c.eye(22, 38, disc=False)
    c.eye(40, 38, disc=False)
    c.smile(31, 44)
    c.blush(17, 43)
    c.blush(44, 43)


K.render_pal(fn, 'pl-cwy-2', 'Slag Drip', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cwy-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cwy-2.png')
