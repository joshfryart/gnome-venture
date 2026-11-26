# Acorn Nip: an acorn that is a corner-TT piece. Flat W and S sides, round tab N (the acorn's stem nub, with a grass-green
# leaf), round tab E (a tiny hidden acorn "in its knob"). Cap in the log brown, nut in the autumn orange, leaf in the grass green of cell 1-5.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

CAP = K.ramp('#794a1e')
NUT = K.ramp('#d8842a')
NUT2 = K.ramp('#e7a24a')
LEAF = K.ramp('#4f9a45')
STEM = K.ramp('#5a3a1c')
HATCH = '#4a2c1a'


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
    capm = rrect(7, 13, 53, 31, 8)            # dome cap, overhangs the nut
    nutm = rrect(11, 24, 49, 56, 4)           # nut body, near-square: flat W and S
    tabN = knob('T', 'round', 30, 13, 0, -1, r=5.4 * k, nw=3.0)
    tabE = knob('T', 'round', 49, 43, 1, 0, r=5.4 * k, nw=3.0)
    body = c.m(nutm, tabE)
    c.add(body, NUT, stitch=None if c.small else '#f0b868')
    # the tab E is a tiny acorn: lighter nut + a little cap on its top half
    te = c.m(tabE, minus=(nutm,))
    c.add(te, NUT2)
    c.add(te & c.m(rect(50, 0, 64, 42.5 if not c.small else 42.5)), CAP)
    c.edge(te, NUT[1])
    # stem nub on top + leaf
    c.add(c.m(tabN), STEM)
    c.add(c.m(poly([(35, 7), (42, 2.5), (49, 3.5), (45, 8.5), (38, 10)])) if True else set(), LEAF)
    cap = c.add(c.m(capm), CAP)
    c.edge(cap, CAP[1])
    # cap crosshatch scales
    if not c.small:
        for (x, y) in cap:
            if (x + y) % 4 == 0 and (x - y) % 4 == 0:
                c.px(x, y, HATCH)
            elif (x + y) % 4 == 2 and (x - y) % 4 == 2:
                c.px(x, y, CAP[2])
    else:
        for (x, y) in cap:
            if (x + y) % 3 == 0 and y % 2 == 0:
                c.px(x, y, HATCH)
    # face
    c.eye(22, 40)
    c.eye(37, 40)
    c.blush(17.5, 45)
    c.blush(41, 45)
    c.smile(29.5, 45)
    # leaf vein
    c.line([(37, 8), (46, 4.5)], LEAF[1])


K.render_pal(fn, 'mw-acorn-nip', 'Acorn Nip', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mw-acorn-nip-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mw-acorn-nip.png')
