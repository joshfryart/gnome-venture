"""mt-bill-brolly: whimsy-hornbill, double knobs. A slate hornbill IS the square piece: the curved yellow bill + orange casque break out
of the E side, a green leaf 'brolly' is the N double tab, two yellow feet are the S double tab, a double blank bites into the wing (W).
Slate wing, white wing band, teal sky glint from cell 6-0 (the hornbill over Monsoon Tangle)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

SLATE = K.ramp('#3c3b3b')
WING = K.ramp('#2e2c2e')
WHT = K.ramp('#e7f0eb')
TEAL = K.ramp('#8eb5b2')
BILL = K.ramp('#f0c030')
CASQ = K.ramp('#e0702a')
LEAF = K.ramp('#4f9a3c')
FEET = K.ramp('#e8a317')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(10, 21, 44, 50)
    tabN = knob('T', 'double', 22, 21, 0, -1, r=6.6 * k, nw=2.0)
    tabS = knob('T', 'double', 27, 50, 0, 1, r=4.4 * k)
    blankW = knob('B', 'double', 10, 37, -1, 0, r=4.2 * k)
    body = c.m(core, minus=(blankW,))
    c.add(body, SLATE, stitch=None)
    # heart-shaped taro leaf brolly (N double tab), stem into the body
    canopy = lambda x, y: y < 13.5 and (ell(15.5, 13, 8.5, 7)(x, y) or ell(28.5, 13, 8.5, 7)(x, y))
    stem = thick_path([(22, 11), (22, 22)], 3.4 if not c.small else 4.0)
    leaf = c.m(canopy, stem, minus=(core,)) | (c.m(stem) & c.m(rect(0, 19, 64, 22)))
    c.add(leaf, LEAF)
    # feet (S double tab): two yellow toes
    c.add(c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(rect(0, 49, 64, 51))), FEET)
    # wing: darker block on the back, the W blank bites into it; white wing bar (cell 6-0)
    wing = c.m(poly([(10, 27), (27, 30), (31, 42), (24, 49), (10, 49)])) & body
    c.add(wing, WING)
    bar = c.m(thick_path([(13, 45), (27, 42)], 3.2 if not c.small else 3.8)) & wing
    c.add(bar, WHT)
    c.edge(wing, SLATE[2])
    # white chest bib under the bill
    c.add(c.m(ell(38, 46, 7.5, 6)) & body, WHT)
    # bill + casque breaking out of the E side
    bill = poly([(38, 30), (50, 29), (58, 32), (63, 38), (57, 36.5), (49, 37), (38, 38)])
    c.add(c.m(bill), BILL)
    casq = poly([(38, 22), (48, 21.5), (55, 24), (57, 29.5), (48, 29.5), (38, 30)])
    c.add(c.m(casq), CASQ)
    c.line([(44, 34), (53, 34), (59, 36)], BILL[1])
    # teal rain glints on the wing (the cell's sky)
    if not c.small:
        for x, y in ((15, 33), (20, 36), (24, 33), (17, 39)):
            c.px(*c.P(x, y), TEAL[2])
    # leaf veins
    x0, _ = c.P(22, 0)
    for y in range(c.P(0, 13)[1], c.P(0, 21)[1]):
        c.px(x0, y, LEAF[1])
    c.line([(15.5, 12), (11, 9)], LEAF[1])
    c.line([(28.5, 12), (33, 9)], LEAF[1])
    c.eye(33, 28, disc=True)
    c.blush(30, 33)


rep = K.render_pal(fn, 'mt-bill-brolly', 'Bill Brolly', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/mt-bill-brolly-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mt-bill-brolly.png')
print(rep)
