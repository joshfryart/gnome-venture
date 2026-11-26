"""pl-wcof-1 Thatchtop Bauble. Corner-TB, keyhole: a little thatched hut roof. Flat W + S (the hut wall stands on the ground),
keyhole tab N = the gold finial bauble on the roof peak, keyhole blank E bitten into the thatch. Golden thatch rows with the shaded right
half (as in the picture), dusk purple/mauve eave shadow, tan wall with the glowing door, a cream star (cell 2-1: night sky + star)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

THATCH = K.ramp('#d09d42')
THATCH_SH = K.ramp('#a87430')
WALLR = K.ramp('#cf9553')
PURPLE = K.ramp('#5a3a80')
MAUVE = K.ramp('#8a4a88')
GOLDR = K.ramp('#e8b02a')
DOOR = ('#ffc455', '#e09a40', '#fff0b0')
SRC = '/home/user/gnome-venture/art-review/redo/_src/'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(9, 57), (9, 37), (25, 19), (39, 19), (55, 37), (55, 57)])
    tabN = K.knob('T', 'keyhole', 32, 19, 0, -1, r=5.4 * k)
    blankE = K.knob('B', 'keyhole', 55, 47, 1, 0, r=4.2 * k)
    body = c.m(core, tabN, minus=(blankE,))
    c.add(body, THATCH)
    # shaded right half of the cone (light from the upper left)
    c.add(body & c.m(K.poly([(32, 19), (40, 19), (64, 45), (64, 47), (32, 47)])), THATCH_SH)
    # thatch rows: staggered short dashes, like the picture's bundled straw
    step = 4 if not c.small else 5
    for (x, y) in body:
        X, Y = (x + 0.5) / c.k, (y + 0.5) / c.k
        if 21 < Y < 43:
            row = int((Y - 21) // step)
            if (Y - 21) % step < (1 / c.k) and (int(X / 4) + row) % 2 == 0:
                c.px(x, y, THATCH_SH[1] if X > 32 else THATCH[1])
    # eave shadow: purple dusk band with a mauve scalloped fringe
    eave = body & c.m(K.rect(0, 41, 64, 46))
    c.add(eave, PURPLE)
    fringe = body & c.m(lambda x, y: 41 <= y < 43.5 + (1.4 if (int(x) // 3) % 2 else 0))
    c.add(fringe, MAUVE)
    # wall + glowing door
    c.add(body & c.m(K.rect(0, 46, 64, 64)), WALLR)
    door = c.m(K.rect(28, 49, 36, 57), K.ell(32, 49.5, 4, 2.5))
    c.add(door, DOOR)
    if not c.small:
        c.line([(32, 50), (32, 56)], '#fff0b0')
    # gold bauble finial on the N tab
    ball = c.m(tabN, minus=(core,))
    c.add(ball, GOLDR)
    c.add(c.m(K.ell(32, 9.5, 5.2 * k, 5.0 * k)), GOLDR)
    c.add(c.m(K.rect(27, 16.5, 37, 19)), GOLDR)
    bx, by = c.P(29.5, 7.5)
    c.px(bx, by, '#fff4c8')
    if not c.small:
        c.px(bx + 1, by, '#fff4c8')
        c.px(bx, by + 1, '#fff4c8')
    # cream star twinkle on the thatch (the cell's star)
    sx, sy = c.P(46.5, 30)
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)) if not c.small else ((0, 0), (1, 0), (0, 1)):
        c.px(sx + dx, sy + dy, '#fff4dc')
    # face on the thatch
    c.eye(26, 32)
    c.eye(36.5, 32)
    c.smile(31, 36.5)
    c.blush(21.5, 36)
    c.blush(40.5, 36)


K.render_pal(fn, 'pl-wcof-1', 'Thatchtop Bauble', '/home/user/gnome-venture/art-review/redo/out',
             cellfile=SRC + 'pl-wcof-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wcof-1.png')
