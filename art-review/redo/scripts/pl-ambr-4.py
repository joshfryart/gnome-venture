"""pl-ambr-4 Pinetop Procession: a tiered dark pine that is an inner-TTTT keyhole piece.
N tab = the pine tip, E/W tabs = the lowest branch tips, S tab = the brown trunk (the trunk from cell 3-3), amber sunlit tier edges
(the low golden sun of the Amber Woods)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINE = K.ramp('#3e5a34')
PINE2 = K.ramp('#2f4630')
AMBER = K.ramp('#f4a43c')
SUN = '#ffc860'
TRUNK = K.ramp('#915037')
BARK = '#442834'


def fn(c):
    k = 1.15 if c.small else 1.0
    t1 = K.poly([(25, 12), (39, 12), (47, 28), (17, 28)])
    t2 = K.poly([(24.5, 26), (39.5, 26), (51, 39.5), (13, 39.5)])
    t3 = K.poly([(21, 37), (43, 37), (53, 50.5), (11, 50.5)])
    tabN = K.knob('T', 'keyhole', 32, 12.5, 0, -1, r=5.0 * k)
    tabE = K.knob('T', 'keyhole', 48.5, 45, 1, 0, r=5.0 * k)
    tabW = K.knob('T', 'keyhole', 15.5, 45, -1, 0, r=5.0 * k)
    tabS = K.knob('T', 'keyhole', 32, 50.5, 0, 1, r=5.0 * k)
    blankT = K.ell(32, 0, 1, 1)
    c.add(c.m(t1, t2, t3, tabN, tabE, tabW), PINE)
    # shadowed top of each lower tier, tucked under the one above
    c.add(c.m(t2, minus=(t1,)) & c.m(K.rect(0, 28, 64, 31)), PINE2)
    c.add(c.m(t3, minus=(t2,)) & c.m(K.rect(0, 39.5, 64, 42.5)), PINE2)
    # amber sunlit bough tips: a band along each tier's lower edge with drooping points
    def fringe(poly, y, x0, x1):
        def f(x, yy):
            d = abs(((x - x0) % 5) - 2.5) / 2.5
            return poly(x, yy) and yy >= y - 2.2 - 1.6 * (1 - d)
        return f

    def teeth(y, x0, x1):
        return lambda x, yy: x0 + 1 < x < x1 - 1 and y <= yy < y + 2.6 * (1 - abs(((x - x0) % 5) - 2.5) / 2.5)
    c.add(c.m(fringe(t1, 28, 17, 47), minus=(K.rect(0, 28, 64, 64),)), AMBER)
    c.add(c.m(fringe(t2, 39.5, 13, 51), minus=(K.rect(0, 39.5, 64, 64),)), AMBER)
    c.add(c.m(fringe(t3, 50.5, 11, 53)), AMBER)
    c.add(c.m(tabS, minus=(t3,)), TRUNK)
    # golden sun glint on the pine tip
    c.add(c.m(K.ell(32, 4.2, 2.4, 2.2)), (SUN, AMBER[0], '#fff0b0'))
    x, y0 = c.P(33.5, 52)
    for y in range(y0, c.P(0, 62)[1]):
        c.px(x, y, BARK)
    c.eye(27, 33.5, disc=True)
    c.eye(37, 33.5, disc=True)
    c.smile(32, 36, K.UMBER)
    if not c.small:
        c.blush(22.5, 35)
        c.blush(41, 35)


K.render_pal(fn, 'pl-ambr-4', 'Pinetop Procession', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-ambr-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ambr-4.png')
