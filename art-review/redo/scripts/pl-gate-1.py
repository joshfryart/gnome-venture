# Lollipop Maple: a round-topped red maple crown that is a corner piece. Flat sides N and W (the square corner of the crown),
# keyhole tab S = trunk (the flared neck) planted in a round grass tuft (the keyhole disc), keyhole blank E bitten into the crown.
# Colours from cell 4-3 of The Thousand Gates: torii vermilion with the dark lacquer beam and orange highlight; trunk = cherry-post brown.
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

VERM = K.ramp('#c8422e')
LAQ = ('#98282a', '#6e1c20', '#c8422e')
HI = '#e8643a'
BARK = K.ramp('#855235')
GRASS = K.ramp('#66924f')


def fn(c):
    k = 1.25 if c.small else 1.0
    x0, y0, x1, y1, rr = 6, 9, 52, 44, 9
    core = lambda x, y: (x0 <= x < x1 and y0 <= y < y1) and not (
        (x > x1 - rr and y > y1 - rr and (x - (x1 - rr)) ** 2 + (y - (y1 - rr)) ** 2 > rr * rr) or
        (x > x1 - rr and y < y0 + rr and (x - (x1 - rr)) ** 2 + (y - (y0 + rr)) ** 2 > rr * rr) or
        (x < x0 + rr and y > y1 - rr and (x - (x0 + rr)) ** 2 + (y - (y1 - rr)) ** 2 > rr * rr))
    tabS = K.knob('T', 'keyhole', 29, 44, 0, 1, r=6.4 * k, nw=3.2 * k)
    blankE = K.knob('B', 'keyhole', 52, 26, 1, 0, r=4.8 * k, nw=2.4 * k)
    crown = c.m(core, minus=(blankE,))
    c.add(crown, VERM, stitch=None if c.small else LAQ[0])
    # lollipop swirl in the gate's orange highlight
    pts = []
    for i in range(0, 60):
        t = i / 59 * 2.6 * math.pi
        r = 2.5 + t * 2.0
        pts.append((25 + r * math.cos(t), 26 + r * math.sin(t) * 0.92))
    sw = c.m(K.thick_path(pts, 3.0 if not c.small else 3.4)) & crown
    c.add(sw, (HI, '#c0502e', '#f39a6a'))
    # dark lacquer beam across the bottom of the crown (the torii crossbeam)
    beam = crown & c.m(K.rect(0, 39, 64, 44))
    c.add(beam, LAQ)
    # a maple leaf sprouting from the round top-right of the crown (5 points)
    lp = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5
        rad = 8.0 if i % 2 == 0 else 3.6
        lp.append((47 + rad * math.cos(a) * 1.05, 10 + rad * math.sin(a)))
    leaf = c.m(K.poly(lp), K.thick_path([(47, 12), (44, 17)], 2.6), minus=(core,))
    c.add(leaf, K.ramp('#e8643a'))
    tab = c.m(tabS, minus=(core,))
    trunk = tab & c.m(lambda x, y: y < 52.5)
    tuft = tab - trunk
    c.add(trunk, BARK)
    c.add(tuft, GRASS)
    # grass blades on the tuft top
    if not c.small:
        for gx in (25, 35):
            c.px(*c.P(gx, 52.5), GRASS[2])
    # face on the calm left of the crown
    c.eye(18, 25, disc=True)
    c.eye(32, 25, disc=True)
    c.smile(25, 32)
    c.blush(14, 31)
    c.blush(36, 31)


K.render_pal(fn, 'pl-gate-1', 'Lollipop Maple', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gate-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gate-1.png')
