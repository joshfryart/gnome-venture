"""pl-wcen-1 Mossy Ledge Croaker. Corner-TT, keyhole.
Concept: a moss-green frog sitting face-on on the grey pool ledge; flat sides W and S (the ledge stone is the S edge),
keyhole tab N = the purple echo pebble from cell 0-2 balanced on its head (pink glints), keyhole tab E = a webbed hand
raised to croak hello; bulging eyes break the top corners. Colours: cenote moss greens, rim-stone grey, pool teal, pebble mauve."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path

MOSS = K.ramp('#6bb551')
BELLY = K.ramp('#c4e08a')
STONE = K.ramp('#9da2a2')
TEALW = K.ramp('#28a0aa')
PEBBLE = K.ramp('#7a6a88')
PINK = '#ffd0d8'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(8, 22, 50, 58)
    tabN = knob('T', 'keyhole', 29, 22, 0, -1, r=6.2 * k)
    tabE = knob('T', 'keyhole', 50, 38, 1, 0, r=4.8 * k)
    eyeL = ell(15.5, 21, 7.2, 6.6)
    eyeR = ell(42.5, 21, 7.2, 6.6)
    body = c.m(core, eyeL, eyeR)
    c.add(body, MOSS, stitch=None)
    # webbed hand tab (green) and pebble tab (mauve)
    hand = c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(rect(48, 0, 51, 64)))
    c.add(hand, MOSS)
    peb = c.m(tabN, minus=(core, eyeL, eyeR))
    c.add(peb, PEBBLE)
    # belly
    c.add(c.m(ell(29, 44, 14, 9)) & body, BELLY)
    # ledge stone along the S edge with a moss lip, a teal water lick on the W
    ledge = c.m(rect(8, 50, 50, 58))
    c.add(ledge, STONE)
    c.edge(ledge, STONE[1])
    c.add(c.m(rect(8, 55, 20, 58)), TEALW)
    # front feet resting on the ledge
    feet = c.m(ell(17, 50, 6, 3.4), ell(41, 50, 6, 3.4))
    c.add(feet, MOSS)
    c.edge(feet, MOSS[1])
    # a vine of cenote moss dripping over the ledge
    c.add(c.m(rect(30, 50, 33, 56)), MOSS)
    # toes on the raised hand
    hx, hy = c.P(57.5, 38)
    if not c.small:
        for dy in (-2, 1):
            for dx in range(0, 4):
                c.px(hx + dx, hy + dy, MOSS[1])
    else:
        c.px(hx + 2, hy - 1, MOSS[1]); c.px(hx + 2, hy + 1, MOSS[1])
    # pebble glints (pink, like the cell's pebble)
    px, py = c.P(29, 12.5)
    if not c.small:
        c.px(px - 2, py, PINK); c.px(px + 2, py, PINK); c.px(px - 2, py + 1, PINK); c.px(px + 2, py + 1, PINK)
    else:
        c.px(px - 1, py, PINK); c.px(px + 1, py, PINK)
    # eyes
    c.eye(15.5, 21, disc=True)
    c.eye(42.5, 21, disc=True)
    # wide frog mouth
    y = c.P(0, 32)[1]
    x0, x1 = c.P(17, 0)[0], c.P(41, 0)[0]
    for x in range(x0 + 1, x1):
        c.px(x, y + (1 if x0 + 2 < x < x1 - 2 else 0), K.UMBER2)
    c.px(x0, y - 1, K.UMBER2); c.px(x1, y - 1, K.UMBER2)
    c.blush(14, 31); c.blush(43, 31)
    # moss spots on back
    if not c.small:
        for (sx, sy) in ((11, 36), (47, 30), (12, 44)):
            c.px(*c.P(sx, sy), MOSS[2])


K.render_pal(fn, 'pl-wcen-1', 'Mossy Ledge Croaker', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wcen-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wcen-1.png')
