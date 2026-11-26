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
    core = poly([(14, 22), (50, 22), (53, 26), (53, 52), (50, 57), (14, 57), (11, 52), (11, 26)])
    tabN = knob('T', 'peg', 32, 22, 0, -1, r=5.0 * k)
    bW = knob('B', 'peg', 11, 37, -1, 0, r=3.6 * k)
    bE = knob('B', 'peg', 53, 37, 1, 0, r=3.6 * k)
    bS = knob('B', 'peg', 32, 57, 0, 1, r=4.2 * k)
    blanks = (bW, bE, bS)
    body = c.m(core, minus=blanks)
    c.add(body, BRASS)
    # chimney crown (peg tab) in blue, with a brass collar
    tab = c.m(tabN, minus=(core,))
    c.add(tab, BLUE)
    c.add(c.m(rect(28, 19, 36, 22.5)) & tab, BRASS)
    # steam puff on top of the chimney
    puff = c.m(ell(32, 7.5, 6.5, 4.2), ell(26.5, 9.5, 3.6, 3.0), ell(38, 9, 3.8, 3.2))
    c.add(puff, STEAM)
    # blue lid shoulder
    lid = body & c.m(rect(0, 22, 64, 27))
    c.add(lid, BLUE)
    # red folk band with cream dots (kerchief)
    band = body & c.m(rect(0, 40, 64, 45.5))
    c.add(band, RED)
    for x in range(15, 50, 5):
        p = c.P(x + 0.5, 42.7)
        c.px(*p, CREAM)
        if not c.small:
            c.px(p[0] + 1, p[1], CREAM)
    # dark brass base tray
    base = body & c.m(rect(0, 51, 64, 64))
    c.add(base, DARKB)
    # side handles: little dark loops above and below the blanks
    for sx in (11, 53):
        d = -1 if sx == 11 else 1
        c.add(c.m(thick_path([(sx, 29), (sx + 3.2 * d, 29.5)], 2.8 if not c.small else 3.4)), DARKB)
        c.add(c.m(thick_path([(sx, 47.5), (sx + 3.2 * d, 47)], 2.8 if not c.small else 3.4)), DARKB)
    # spigot: red tap on the front band
    c.add(c.m(rect(45, 44, 49.5, 47.5)), DARKB)
    c.add(c.m(rect(47, 47, 50.5, 50)), RED)
    # face
    c.eye(25, 33)
    c.eye(39, 33)
    c.smile(32, 36.5)
    c.blush(21.5, 36.5)
    c.blush(42, 36.5)


K.render_pal(fn, 'bb-samovar-puff', 'Samovar Puff', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/bb-samovar-puff-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/bb-samovar-puff.png')
