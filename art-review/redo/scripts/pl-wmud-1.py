"""pl-wmud-1 Onion Dome Daydream: corner-BB keyhole. A blue onion dome on a mud-brick drum. Flat sides: left + bottom (the corner L).
Keyhole blanks: E side of the drum, and the dome's upper-right shoulder. Gold finial, arched striped windows, dreamy upward eyes."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob

DOME = K.ramp('#3586bd')
DOMELT = '#70c8e3'
MUD = K.ramp('#ca8651')
MUDLT = K.ramp('#dfa566')
GOLD = K.GOLD
WIN = '#5c3526'
STRIPES = ('#f0c030', '#d6322b', '#3f7fc8')


def fn(c):
    k = 1.15 if c.small else 1.0
    R = [(32, 4), (33.6, 8), (36, 11), (41, 13.5), (47, 16.5), (52, 20.5), (54.5, 24.5), (53, 28), (48.5, 30.5), (48.5, 32)]
    dome = poly(R + [(64 - x, y) for x, y in reversed(R[1:])])
    drum = rect(10, 31, 54, 58)
    finial = (rect(30.6, 0.5, 33.4, 6), ell(32, 2.6, 2.6, 2.4))
    blankE = knob('B', 'keyhole', 54, 44, 1, 0, r=4.2 * k)
    blankS = knob('B', 'keyhole', 46.5, 16, 0.5, -0.866, r=3.5 * k)
    minus = (blankE, blankS)
    c.add(c.m(*finial, minus=minus), GOLD)
    dm = c.m(dome, minus=minus)
    c.add(dm, DOME, stitch=None if c.small else '#2a6d9c')
    dr = c.m(drum, minus=minus)
    c.add(dr, MUD, stitch=None if c.small else '#e7b27a')
    band = c.m(rect(10, 30.5, 54, 34.5), minus=minus)
    c.add(band, GOLD)
    c.edge(band, GOLD[1])
    # dome highlight streak (upper left)
    hl = c.m(poly([(22, 15), (27, 11), (25, 18), (19, 22)]))
    for p in hl:
        c.px(p[0], p[1], DOMELT)
    # arched striped windows on the drum
    for wx in (19, 32):
        win = c.m(rect(wx - 3.2, 42, wx + 3.2, 53), ell(wx, 42, 3.2, 3.4))
        for (x, y) in win:
            c.px(x, y, WIN)
        inner = c.m(rect(wx - 1.6, 43, wx + 1.6, 52))
        ys = sorted({p[1] for p in inner})
        for (x, y) in inner:
            c.px(x, y, STRIPES[(ys.index(y) // (1 if c.small else 2)) % 3])
    # mud-brick specks
    if not c.small:
        for bx, by in ((42, 36), (14, 37), (44, 54), (25, 56), (38, 39)):
            x, y = c.P(bx, by)
            c.px(x, y, MUD[1]); c.px(x + 1, y, MUD[1])
    # dreamy face on the dome, eyes looking up
    c.eye(25, 23, disc=True, look=(0, -1))
    c.eye(37, 23, disc=True, look=(0, -1))
    c.smile(31, 26, col=K.UMBER)
    c.blush(20.5, 26.5)
    c.blush(41.5, 26.5)


K.render_pal(fn, 'pl-wmud-1', 'Onion Dome Daydream', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wmud-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wmud-1.png')
print(K.check(K.draw(fn, 64))['colours'], K.check(K.draw(fn, 36))['colours'])
