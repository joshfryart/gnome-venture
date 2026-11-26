"""pl-rrc-1 Bunting Flag: a teal pennant hanging off the bunting cord, as a corner-TB piece.
Flat N (the hem sleeve threaded on the cord) and flat W; round tab E (the flag's corner snapping out in the wind);
round blank S (the swallowtail notch). Teal #4aa8a0 pennant on the rose canyon, cord with knots (cell 3-2)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

TEAL = K.ramp('#4aa8a0')
ROSE = K.ramp('#e8a898')
CORD = ('#6a4030', '#4a2c1a', '#9a6a4a')
GOLD = K.ramp('#f0c030')


def fn(c):
    k = 1.15 if c.small else 1.0
    # pennant core: flat top under the hem, sides tapering hard toward the point
    core = K.poly([(11, 18), (53, 18), (40, 51), (24, 51)])
    # round tab S: the gold tassel at the pennant's point; round blank W: a bite in the flapping left edge
    tabS = K.knob('T', 'round', 32, 48.5, 0, 1, r=(4.4 if not c.small else 5.6))
    blankW = K.knob('B', 'round', 20.8, 42.5, -0.93, 0.37, r=3.8 * k)
    body = c.m(core, minus=(blankW,))
    c.add(body, TEAL, stitch=None if c.small else TEAL[2])
    tas = c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(K.rect(0, 47, 64, 52)))
    c.add(tas, GOLD)
    # hem sleeve on top (rose canvas folded over the cord)
    hem = c.m(K.rect(10, 12, 54, 20))
    c.add(hem, ROSE)
    # the cord running through the hem, out past both sides, with knots
    cw = 2.6 if not c.small else 3.2
    c.add(c.m(K.thick_path([(2, 9), (11, 15), (53, 15), (62, 9)], cw)), CORD)
    c.add(c.m(K.ell(4, 10, 2.6 * k, 2.6 * k), K.ell(60, 10, 2.6 * k, 2.6 * k)), CORD)
    c.edge(hem, ROSE[1])
    # face on the teal body
    c.eye(27, 27)
    c.eye(40, 27)
    c.smile(33.5, 33)
    c.blush(24, 31)
    c.blush(44, 31)
    # wind ripple lines on the flag
    if not c.small:
        c.line([(29, 41), (32, 39), (35, 41), (38, 39)], TEAL[1])


K.render_pal(fn, 'pl-rrc-1', 'Bunting Flag', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-rrc-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-rrc-1.png')
