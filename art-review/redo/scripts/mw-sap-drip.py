# Sap Drip: an amber maple-sap drop that is an inner-TBTB piece. N peg tab = the drip's pointed neck (red maple leaf stuck on it),
# E and W peg blanks cut into the belly, S peg tab = a little drop falling off. Amber/orange sap, gnome-hat red leaf, grass green tuft (cell 8-4).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

SAP = K.ramp('#e08a1c')
SAP2 = K.ramp('#f0b040')
RED = K.ramp('#c8302a')
GRASS = K.ramp('#5aa84a')
SHINE = '#fbe6a8'


def rrect(x0, y0, x1, y1, r):
    def f(x, y):
        if not (x0 <= x < x1 and y0 <= y < y1):
            return False
        cx = min(max(x, x0 + r), x1 - r)
        cy = min(max(y, y0 + r), y1 - r)
        return (x - cx) ** 2 + (y - cy) ** 2 < r * r
    return f


def fn(c):
    k = 1.15 if c.small else 1.0
    bulb = rrect(9, 26, 55, 54, 11)                       # round-bottomed belly, straight W/E sides
    def shoulder(x, y):                                   # curved teardrop taper up into the drip neck
        if not (9 <= y < 56):
            return False
        if y < 39:
            hw = 3.6 + 19.4 * (((y - 9) / 30.0) ** 0.62)
        else:
            hw = 23.0 * max(0.0, 1 - ((y - 39) / 17.0) ** 2) ** 0.5
        return abs(x - 32) < hw
    tabN = knob('T', 'peg', 32, 10, 0, -1, r=4.6 * k, nw=3.6)
    tabS = knob('T', 'peg', 32, 53.5, 0, 1, r=4.0 * k, nw=2.0)
    blW = knob('B', 'peg', 9, 39, -1, 0, r=4.2 * k, nw=2.4)
    blE = knob('B', 'peg', 55, 39, 1, 0, r=4.2 * k, nw=2.4)
    body = c.m(shoulder, tabN, minus=(blW, blE))
    c.add(body, SAP)
    # falling droplet (S tab) in lighter sap
    drop = c.m(tabS, minus=(shoulder,))
    c.add(drop, SAP2)
    c.add(c.m(ell(32, 61.2 if not c.small else 61.5, 3.2 * k, 2.6 * k)) & drop, SAP2)
    c.edge(drop, SAP[1])
    # warm translucent glow in the belly
    glow = c.add(c.m(ell(32, 46, 15, 7)), (SAP2[0], SAP2[0], SAP2[0]))
    # glossy highlight streak on upper left of the belly
    if not c.small:
        c.add(c.m(thick_path([(17, 30), (15, 36), (15, 42)], 2.8)), (SHINE, SHINE, SHINE))
        c.px(*c.P(22.5, 24.5), SHINE)
    else:
        c.add(c.m(thick_path([(16, 31), (15, 39)], 3.4)), (SHINE, SHINE, SHINE))
    # red maple leaf stuck on the neck (top-right), from the gnome-hat red / maple tree
    # five-point maple leaf, flat, stuck on the right shoulder
    lx, ly = 45, 15
    leafpts = [(0, -9), (2, -4), (6, -6), (5, -1), (9, 0), (5, 3), (6, 6), (1, 4), (0, 8), (-1, 4), (-6, 6), (-5, 3), (-9, 0), (-5, -1), (-6, -6), (-2, -4)]
    leaf = c.m(poly([(lx + a * 0.95, ly + b * 0.95) for a, b in leafpts]))
    c.add(leaf, RED)
    if not c.small:
        c.line([(lx, ly + 5.5), (lx, ly - 4)], RED[1])
        c.line([(lx, ly + 1), (lx - 4, ly - 2)], RED[1])
        c.line([(lx, ly + 1), (lx + 4, ly - 2)], RED[1])
    # a run of fresh sap trickling down the left belly, plus a grass-green stalk bit stuck to the drop below
    c.add(c.m(thick_path([(22, 22), (21, 28)], 2.6 * k)), SAP2)
    # face, low on the belly (big calm area)
    c.eye(25, 38)
    c.eye(39, 38)
    c.blush(20, 43.5)
    c.blush(43, 43.5)
    c.smile(31.5, 43.5)


K.render_pal(fn, 'mw-sap-drip', 'Sap Drip', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mw-sap-drip-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mw-sap-drip.png')
