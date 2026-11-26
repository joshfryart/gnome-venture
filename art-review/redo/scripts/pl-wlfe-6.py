# Concept: a glowing red paper river-lantern riding in a little wooden boat (whimsy-wishlight). The lantern body is the
# square-ish piece core: keyhole tab on the left side, keyhole blank cut into the right side, keyhole tab on top as the
# lantern's gold finial; the boat + water are the flat bottom. Colours from cell 6-6: lantern red, peach/cream glow, gold, river blues.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#b74d47')
GLOW = ('#faba90', '#e0906a', '#fff0b0')
CREAMR = ('#fff0b0', '#faba90', '#fffadc')
GOLD = K.ramp('#ffd070')
CAP = ('#77362e', '#4a2a22', '#a0564a')
WOOD = K.ramp('#a66e4a')
WATER = K.ramp('#2a5a98')
WATER2 = K.ramp('#4a74b8')


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
    body = rrect(12, 14, 52, 46, 11)
    capT = K.rect(22, 11, 42, 16)
    capB = K.rect(22, 44, 42, 48)
    tabL = K.knob('T', 'keyhole', 12.5, 30, -1, 0, r=4.5 * k)
    blkR = K.knob('B', 'keyhole', 51.5, 30, 1, 0, r=4.5 * k)
    tabT = K.knob('T', 'keyhole', 32, 11, 0, -1, r=4.2 * k)
    boat = K.poly([(2, 42), (9, 47), (55, 47), (62, 42), (55, 56), (9, 56)])
    water = K.poly([(5, 55), (59, 55), (59, 61), (5, 61)])

    lant = c.m(body, tabL, minus=(blkR,))
    c.add(c.m(water), WATER)
    # ripples
    c.add(c.m(K.rect(6, 58, 16, 60), K.rect(46, 58, 58, 60), K.rect(26, 59, 36, 61)), WATER2)
    c.add(c.m(boat), WOOD, stitch=WOOD[1] if False else None)
    c.add(lant, RED, stitch='#e07a6a')
    # glow panel on the left (as in the cell: peach band then cream)
    c.add(c.m(rrect(12, 14, 52, 46, 11), minus=(K.rect(0, 0, 12.6, 64), K.rect(24, 0, 64, 64))), GLOW)
    c.add(c.m(K.rect(16, 20, 21, 40)), CREAMR)
    c.add(c.m(tabT), K.ramp('#ff9a3a'))
    c.add(c.m(K.ell(32, 6.2, 2.4 * k, 3.4 * k)), CREAMR)
    c.add(c.m(capT), CAP)
    c.add(c.m(capB), CAP)
    # ribs
    if not c.small:
        c.line([(36, 18), (36, 42)], RED[1])
        c.line([(44, 18), (44, 26)], RED[1])
        c.line([(44, 35), (44, 42)], RED[1])
        c.line([(10, 50), (54, 50)], WOOD[1])
    else:
        c.line([(37, 18), (37, 42)], RED[1])
    # gold wish band
    c.add(c.m(K.rect(24, 36, 34, 39) if not c.small else K.rect(24, 36, 35, 40)), GOLD)
    c.eye(28, 26, disc=False)
    c.eye(40, 26) if c.small else c.eye(40.5, 26)
    c.smile(34, 30.5)
    c.blush(25, 30)
    c.blush(42, 30)


K.render_pal(fn, 'pl-wlfe-6', 'Candle Boat Pilot', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wlfe-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wlfe-6.png')
