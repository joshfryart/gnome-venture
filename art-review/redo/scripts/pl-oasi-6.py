"""pl-oasi-6 Twinhump Stroller: whimsy-bactrian, keyhole. A chibi Bactrian camel that IS the piece: two keyhole tabs N are the humps,
head on a neck breaks out at the NW corner, keyhole blank E (under the tail), keyhole blank S splits the cobble-stone legs.
Colours from cell 9-6 of The Oasis That Moves: tan plank sand, red/plum saddle blanket with plank stripe, cobble grey legs."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, thick_path, knob, ramp

SAND = ramp('#c8884a')
HUMP = ramp('#a8663e')
RED = ramp('#ba5a3f')
PLUM = ramp('#6a3a44')
PLANK = ramp('#f6c880')
STONE = ramp('#6e5a58')
MUZ = ramp('#e0b070')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(14, 26, 54, 56)
    hump1 = knob('T', 'keyhole', 25, 29, 0, -1, r=7.6 * k, nw=4.6)
    hump2 = knob('T', 'keyhole', 44, 29, 0, -1, r=7.6 * k, nw=4.6)
    blankE = knob('B', 'keyhole', 54, 38, 1, 0, r=4.2 * k)
    blankS = knob('B', 'keyhole', 34, 56, 0, 1, r=4.2 * k)
    neck = thick_path([(18, 34), (12, 26), (10, 19)], 8 if not c.small else 8.5)
    head = ell(9, 15.5, 8, 6)
    ears = ell(13, 9, 2, 2.6)
    body = c.m(core, hump1, hump2, neck, head, ears, minus=(blankE, blankS))
    c.add(body, SAND)
    # humps a shade darker, woolly
    hm = c.m(hump1, hump2, minus=(core,)) & body
    c.add(hm & c.m(rect(0, 0, 64, 19)), HUMP)
    # legs: cobble stone below the belly
    legs = body & c.m(rect(0, 47, 64, 64))
    c.add(legs, STONE)
    if not c.small:
        for (x, y) in legs:
            if (y - c.P(0, 47)[1]) % 4 == 0 or ((x + (y // 4) * 3) % 6 == 0):
                c.px(x, y, STONE[1])
    else:
        y = c.P(0, 52)[1]
        for (x, yy) in legs:
            if yy == y:
                c.px(x, yy, STONE[1])
    # red saddle blanket across the back between the humps, plum trim and plank stripe
    blanket = body & c.m(rect(20, 26, 50, 42))
    c.add(blanket, RED)
    trim = body & c.m(rect(20, 40, 50, 43))
    c.add(trim, PLUM)
    sy = c.P(0, 33)[1]
    for (x, y) in blanket:
        if y == sy or (not c.small and y == sy + 1):
            c.px(x, y, PLANK[0])
    if not c.small:
        for (x, y) in trim:
            if y == c.P(0, 41)[1] and x % 3 == 0:
                c.px(x, y, PLANK[0])
    c.edge(blanket | trim, PLUM[1])
    # tail tuft
    c.add(c.m(thick_path([(54, 30), (58, 33)], 3.0 if not c.small else 3.6)), HUMP)
    # muzzle + face
    c.add(c.m(ell(4.5, 18, 4.5, 3.8)) & body, MUZ)
    c.px(*c.P(2.5, 16.5), K.UMBER2)
    c.eye(10, 13.5)
    c.smile(5, 19.5, K.UMBER2)
    c.blush(12.5, 18)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-oasi-6', 'Twinhump Stroller', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-oasi-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-oasi-6.png'))
