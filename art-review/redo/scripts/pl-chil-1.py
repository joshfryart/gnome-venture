import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""Stripe Shade (pl-chil-1), corner-TB round: a striped market awning that IS a corner piece. Flat W + S, round tab N (the canopy's
gold finial ball, like the stall's pennant pole), round blank E bitten into the shaded stall under the canopy. Red/cream stripes with a
scalloped valance, wooden pole, chilli counter, cream shade (cell 1-3 of the Market of a Thousand Chilies)."""
from pal_kit import rect, ell, knob

RED = K.ramp('#d8483c')
CRM = K.ramp('#f4e2c4')
SHADE = K.ramp('#e6c9a0')
POLE = K.ramp('#a8693a')
CTR = K.ramp('#9a5a2e')
GOLDF = K.ramp('#f0b030')
CHL = K.ramp('#d02a28')
GRN = K.ramp('#5aa040')
YEL = K.ramp('#f0c030')


def fn(c):
    k = 1.15 if c.small else 1.0
    X0, Y0, X1, Y1 = 9, 14, 55, 58
    core = rect(X0, Y0, X1, Y1)
    tabN = knob('T', 'round', 32, Y0, 0, -1, r=5.2 * k)
    blankE = knob('B', 'round', X1, 44, 1, 0, r=4.6 * k)
    body = c.m(core, tabN, minus=(blankE,))
    # shade under the awning
    c.add(body, SHADE)
    # canopy: vertical stripes, scalloped valance bottom
    VB = 34
    sw = 7.67 if not c.small else 7.67
    def canopy(x, y):
        if y < Y0 - 0.01 or y >= VB + 4:
            return False
        if y < VB:
            return True
        # scallops: each stripe ends in a half disc
        i = int((x - X0) // sw)
        cx = X0 + (i + 0.5) * sw
        return ((x - cx) / (sw / 2)) ** 2 + ((y - VB) / 4.0) ** 2 < 1
    can = c.m(canopy) & body
    def stripe(x, y):
        return int((x - X0) // sw) % 2 == 0
    reds = can & c.m(stripe)
    crms = can - reds
    c.add(crms, CRM)
    c.add(reds, RED)
    c.edge(can, RED[1])
    # valance hem line
    hem = c.m(rect(X0, VB - 1.6, X1, VB)) & body
    for p in hem:
        c.px(*p, RED[1])
    # finial ball on the tab
    fin = c.m(tabN, minus=(rect(0, Y0 - 0.5, 64, 64),))
    c.add(fin, GOLDF)
    # pole on the left
    pole = c.m(rect(11.5, VB + 2, 15.5, 50))
    c.add(pole, POLE)
    # counter
    ctr = c.m(rect(X0, 50, X1, Y1)) & body
    c.add(ctr, CTR)
    if not c.small:
        y = c.P(0, 53.5)[1]
        for x in range(c.P(X0, 0)[0], c.P(X1, 0)[0]):
            if (x, y) in body and x % 4:
                c.px(x, y, CTR[1])
    # peppers on the counter
    for i, (px_, col) in enumerate(((21, CHL), (28, GRN), (35, YEL))):
        pep = c.m(ell(px_, 49.5, 3.0, 2.4))
        c.add(pep, col)
    # face in the shade, peeking from under the valance
    c.eye(23.5, 42)
    c.eye(32.5, 42)
    c.smile(28, 45.5)
    c.blush(19.5, 44.5)
    c.blush(35.5, 44.5)


rep = K.render_pal(fn, 'pl-chil-1', 'Stripe Shade', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-chil-1-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-chil-1.png')
print(rep)
