# pl-flmk-1 "Noodle Awning": corner-TB, round. The red/cream striped market awning of the floating noodle boat (cell 4-5).
# Flat top (the wooden rail it hangs from) and flat left; round tab S (a round paper lantern hanging from the middle of the
# scalloped valance, the market lamp's gold), round blank E cut into the canopy. Vertical coral-red / cream stripes, wood rail, felt face on the canopy.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob

RED = K.ramp('#f05a64')
CRM = K.ramp('#fff1d4')
WOODR = K.ramp('#8a5a32')
GOLD = K.ramp('#f2b632')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(6, 12, 54, 44)
    tabS = knob('T', 'round', 29, 47, 0, 1, r=5.6 * k, nw=2.9)
    blankE = knob('B', 'round', 54, 29, 1, 0, r=4.8 * k)
    # scalloped valance: one half-disc per stripe below the core
    sw = 6.0
    scal = [ell(6 + sw * i + sw / 2, 44, sw / 2, 4.2) for i in range(8) if i not in (3, 4)]
    scal += [rect(6 + sw * 3, 44, 6 + sw * 5, 46)]
    body = c.m(core, *scal, minus=(blankE,))
    # stripes
    def stripe(x, y):
        return int((x - 6) // sw) % 2 == 0
    reds = {p for p in body if stripe((p[0] + .5) / c.k, 0)}
    c.add(body, CRM)
    c.add(reds, RED)
    # tab: gold paper lantern on a short cord
    lan = c.m(tabS, minus=(rect(0, 0, 64, 47),))
    c.add(lan, GOLD)
    if not c.small:
        for yy in (53.5, 57.5):
            y = c.P(0, yy)[1]
            for x in range(c.P(25, 0)[0], c.P(34, 0)[0]):
                if (x, y) in lan and (x, y - 1) in lan:
                    c.px(x, y, GOLD[1])
    # top slope of the canopy: darker band under the rail
    c.add(body & c.m(rect(0, 12, 64, 17)), RED)
    c.add(reds & c.m(rect(0, 12, 64, 17)), K.ramp('#c8404c'))
    # wooden rail on top
    c.add(c.m(rect(4, 9, 56, 14)), WOODR)
    # valance seam line
    y = c.P(0, 40)[1]
    for x in range(c.P(6, 0)[0], c.P(54, 0)[0]):
        if (x, y) in body:
            c.px(x, y, RED[1] if stripe((x + .5) / c.k, 0) else CRM[1])
    # face on the canopy
    c.eye(20, 26)
    c.eye(35, 26)
    c.blush(15.5, 31)
    c.blush(40, 31)
    c.smile(27.5, 31)


K.render_pal(fn, 'pl-flmk-1', 'Noodle Awning', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-flmk-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-flmk-1.png')
