#!/usr/bin/env python3
"""gc-yam-nub "Yam Nub": inner-TBTB, peg. A knobbly sweet-potato yam whose body IS the piece: N peg tab = the green sprout
stalk (leaves fan out above it), S peg tab = the stubby root tail, square peg blanks bite into its E and W flanks.
Skin in the clay-path red-brown of cell 5-6, sprout in its grass green, root tail and dimples in the path's dark umber-brown."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROOT = '/home/user/gnome-venture'
SKIN = K.ramp('#b9532d')        # clay path (cell 5-6)
ROOTC = K.ramp('#8a3a23')       # path shadow
GRASS = K.ramp('#3a9a50')       # grass (cell 5-6)
FLESH = K.ramp('#f0a050')


def fn(c):
    k = 1.15 if c.small else 1.0
    # tuber: plump at the shoulders, tapering a little toward the root tail; corners well rounded
    core = K.poly([(19, 18), (45, 18), (51, 21), (53, 27), (53, 44), (50, 51), (43, 55), (21, 55), (14, 51), (11, 44), (11, 27), (13, 21)])
    # knobbly lumps on the skin (break the straight sides a little, rounded so they do not read as ears)
    lumps = (K.ell(16, 22, 5, 4.5), K.ell(47, 50, 5.5, 5), K.ell(15, 47, 4.5, 5.5), K.ell(48, 23, 5, 4.5))
    tabN = K.knob('T', 'peg', 32, 18, 0, -1, r=3.6 * k)
    tabS = K.knob('T', 'peg', 32, 55, 0, 1, r=4.0 * k)
    blankE = K.knob('B', 'peg', 53, 35, 1, 0, r=3.4 * k)
    blankW = K.knob('B', 'peg', 11, 35, -1, 0, r=3.4 * k)
    cut = (blankE, blankW)
    body = c.m(core, *lumps, minus=cut)
    c.add(body, SKIN)
    # S peg: stubby root tail
    c.add(c.m(tabS, minus=(K.rect(0, 0, 64, 55.5),)), ROOTC)
    # N peg: sprout stalk, with two leaves spreading out of it
    c.add(c.m(tabN, minus=(K.rect(0, 18.5, 64, 64),)), GRASS)
    lw = 1.0 if not c.small else 1.15
    leafL = K.poly([(31, 9), (25, 4.5 * lw + 1), (18, 4), (14, 7), (20, 10.5), (27, 11)])
    leafR = K.poly([(33, 9), (39, 4.5 * lw + 1), (46, 4), (50, 7), (44, 10.5), (37, 11)])
    leaves = c.m(leafL, leafR)
    c.add(leaves, GRASS)
    if not c.small:
        c.line([(29, 9), (22, 7), (17, 6.5)], GRASS[1])
        c.line([(35, 9), (42, 7), (47, 6.5)], GRASS[1])
    # curved growth rings across the skin (the yam's tell-tale bands)
    rw = 1.2 if not c.small else 1.8
    for y0 in ((25, 49) if c.small else (25, 50)):
        band = c.m(lambda x, y, y0=y0: abs(y - (y0 - 0.010 * (x - 32) ** 2)) < rw / 2 and 12 < x < 52) & body
        c.add(band, (SKIN[1], ROOTC[1], SKIN[1]))
    # dimples ("eyes" of the yam) and root hairs
    for (x, y) in ((18, 26), (45, 28), (20, 50), (44, 46), (39, 22)):
        px, py = c.P(x, y)
        c.px(px, py, ROOTC[1])
        if not c.small:
            c.px(px + 1, py, ROOTC[0])
    if not c.small:
        for (a, b) in (((17, 26), (14.5, 24.5)), ((46, 28), (49, 26.5)), ((21, 50), (19, 53))):
            c.line([a, b], ROOTC[1])
    # a little nub nicked open at the top-left lump: orange flesh (it giggles when dug up)
    c.add(c.m(K.ell(15.5, 20.5, 2.3, 1.8)) & body, FLESH)
    # grass tuft hugging the root (picture's grass)
    c.add(c.m(K.poly([(24, 55.5), (26, 50.5), (28, 54), (30, 49.5), (31, 55.5)]),
              K.poly([(33, 55.5), (34, 49.5), (36, 54), (38, 50.5), (40, 55.5)])) & body, GRASS)
    # face: giggling
    c.eye(25, 34)
    c.eye(39, 34)
    c.smile(32, 41, wide=True)
    c.blush(21, 39)
    c.blush(42, 39)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'gc-yam-nub', 'Yam Nub', ROOT + '/art-review/redo/out',
                       cellfile=ROOT + '/art-review/redo/_src/gc-yam-nub-cell.png',
                       oldfile=ROOT + '/game/assets/img/puzzles/pals/gc-yam-nub.png')
    print(rep)
