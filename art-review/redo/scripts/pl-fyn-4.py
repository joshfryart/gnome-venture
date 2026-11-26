"""pl-fyn-4 "Protea Petals": a king protea that is an inner-TTTT (double) piece.
Square-ish bract cup; N double tab = the fuzzy cream crown of the flower head, E/W double tabs = outermost bracts flaring sideways,
S double tab = the stubby mauve stem/log foot. Bracts shade pink -> flame orange/yellow tips (cell 8-6: flames over a mauve log)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

PINK = ramp('#e0507a')
DPINK = ramp('#b83a5c')
FLAME = ramp('#f48a34')
EMBER = ramp('#e0402c')
GLOW = ramp('#ffd45a')
CREAMR = ramp('#f8d8a0')
LOG = ramp('#9c5c48')
MAUVE = ramp('#643c48')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(14, 24, 50, 50)
    tabN = knob('T', 'double', 32, 18, 0, -1, r=5.0 * k)
    tabE = knob('T', 'double', 50, 36, 1, 0, r=4.8 * k)
    tabW = knob('T', 'double', 14, 36, -1, 0, r=4.8 * k)
    tabS = knob('T', 'double', 32, 50, 0, 1, r=5.0 * k)
    # tall outer bracts rising above the cup, flame tipped (they break the top outline like flames)
    tall = [poly([(14, 32), (12.5, 17), (12, 13), (16, 15), (23, 26)]),
            poly([(18, 28), (19, 16), (21.5, 12.5), (24.5, 16), (27, 24)]),
            poly([(50, 32), (51.5, 17), (52, 13), (48, 15), (41, 26)]),
            poly([(46, 28), (45, 16), (42.5, 12.5), (39.5, 16), (37, 24)])]
    body = c.m(core, *tall)
    c.add(body, DPINK)
    for i, t in enumerate(tall):
        m = c.m(t)
        c.add(m, PINK)
        c.add(m & c.m(rect(0, 0, 64, 19)), FLAME)
        c.add(m & c.m(rect(0, 0, 64, 15)), GLOW)
        c.edge(m, DPINK[1])
    c.add(c.m(tabE, tabW, minus=(core,)), PINK)
    c.add(c.m(tabS, minus=(rect(0, 0, 64, 49),)), LOG)
    # scale-like lower bracts (rows of rounded petals)
    for row, (yy, cols) in enumerate(((40, (19, 27, 37, 45)), (46, (15, 23, 32, 41, 49)))):
        for xx in cols:
            m = c.m(poly([(xx - 4.5, yy + 5), (xx + 4.5, yy + 5), (xx + 3, yy - 2), (xx, yy - 5.5), (xx - 3, yy - 2)])) & body
            c.add(m, PINK if row == 0 else DPINK)
            c.edge(m, DPINK[1])
    # fuzzy cream dome with the N tab as its crown
    dome = ell(32, 28, 11, 10.5)
    c.add(c.m(dome, tabN), CREAMR)
    c.add(c.m(tabN, minus=(dome,)), GLOW)
    for fx, fy in ((25, 23), (29.5, 20.5), (35, 21), (39, 25)):
        if c.small:
            break
        x, y = c.P(fx, fy)
        c.px(x, y, EMBER[0])
    # inner bracts hugging the dome
    for xx in (22.5, 41.5):
        m = c.m(poly([(xx - 3, 40), (xx + 3, 40), (xx, 27)]))
        c.add(m, PINK)
        c.add(m & c.m(rect(0, 0, 64, 31)), FLAME)
        c.edge(m, DPINK[1])
    c.add(body & c.m(rect(0, 48, 64, 64)), MAUVE)
    c.eye(28.5, 29)
    c.eye(35.5, 29)
    c.smile(32, 33)
    c.blush(26, 32.5)
    c.blush(38, 32.5)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-fyn-4', 'Protea Petals', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-fyn-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-fyn-4.png')
    print(rep)
