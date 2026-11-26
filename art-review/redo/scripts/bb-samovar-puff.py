import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path

# Samovar Puff: inner-TBBB, peg. A brass samovar IS the piece: N peg tab = chimney crown (blue cap) puffing steam,
# peg blanks W + E bite between the side handles, peg blank S splits the base into two feet.
# Colours from birchbramble cell 9-4 / the porch samovar: brass gold, blue lid, red kerchief band with cream dots.
BRASS = K.ramp('#e8a317')
BLUE = K.ramp('#2f62c0')
RED = K.ramp('#d6322b')
STEAM = ('#f4f0e4', '#c9c5bc', '#ffffff')
DARKB = K.ramp('#b07a10')
CREAM = '#f4f0e4'


def fn(c):
    k = 1.15 if c.small else 1.0
    # urn body: domed shoulders, straight sides (piece edges), flared foot
    core = poly([(20, 20), (44, 20), (50, 23), (52, 28), (52, 50), (49, 54), (51, 58), (13, 58), (15, 54), (12, 50), (12, 28), (14, 23)])
    tabN = knob('T', 'peg', 32, 20, 0, -1, r=4.6 * k)
    bW = knob('B', 'peg', 12, 38, -1, 0, r=3.4 * k)
    bE = knob('B', 'peg', 52, 38, 1, 0, r=3.4 * k)
    bS = knob('B', 'peg', 32, 58, 0, 1, r=4.0 * k)
    body = c.m(core, minus=(bW, bE, bS))
    c.add(body, BRASS, stitch=None)
    tab = c.m(tabN, minus=(core,))
    c.add(tab, BRASS)
    c.add(c.m(rect(26, 9, 38, 13.5)) & tab, BLUE)   # blue chimney cap
    # steam: a wisp curling up and right into a puff (off-axis, so it is not a hat)
    w = 3.0 if not c.small else 3.6
    c.add(c.m(thick_path([(34, 10.5), (37, 8), (40, 7.5)], w), ell(46, 6.5, 6.2, 4.6), ell(52.5, 8.5, 4.0, 3.4), ell(42, 4.5, 3.4, 3.0)), STEAM)
    # blue domed lid shoulder
    lid = body & c.m(rect(0, 20, 64, 26))
    c.add(lid, BLUE)
    # red folk band with cream dots (the doll's kerchief)
    band = body & c.m(rect(0, 41, 64, 46.5))
    c.add(band, RED)
    for x in range(16, 50, 5):
        q = c.P(x + 0.5, 43.7)
        c.px(*q, CREAM)
        if not c.small:
            c.px(q[0] + 1, q[1], CREAM)
    # dark brass foot
    c.add(body & c.m(rect(0, 52, 64, 64)), DARKB)
    # side handles: short dark stubs on the shoulders, above the blanks
    hw = 3.0 if not c.small else 3.6
    for sx, d in ((12, -1), (52, 1)):
        c.add(c.m(thick_path([(sx + 1 * -d, 29), (sx + 3.2 * d, 29), (sx + 3.2 * d, 31.5)], hw)), DARKB)
    # spigot: tap under the band
    c.add(c.m(rect(41, 46.5, 48, 49.5)), DARKB)
    c.add(c.m(rect(45, 49, 49, 52.5)), RED)
    # face
    c.eye(25, 33)
    c.eye(39, 33)
    c.smile(32, 36.5)
    c.blush(21.5, 37)
    c.blush(42, 37)


K.render_pal(fn, 'bb-samovar-puff', 'Samovar Puff', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/bb-samovar-puff-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/bb-samovar-puff.png')
