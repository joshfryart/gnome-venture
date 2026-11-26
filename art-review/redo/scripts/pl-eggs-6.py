#!/usr/bin/env python3
"""pl-eggs-6 "Pink Stripe Egg" (whimsy-egg, round knobs).
Concept: a painted Easter egg that IS the piece: egg outline with a round tab E and a round blank W,
pink / yellow / magenta horizontal stripes from the striped fence-post eggs of cell 2-6, red bow on the tip, chibi grin."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROOT = '/home/user/gnome-venture'
PINK = K.ramp('#f070a0')
MAGE = K.ramp('#b04888')
YELL = K.ramp('#f8d048')
RED = K.ramp('#d83a3a')
CX, CY, RY = 32, 38, 23.5


def egg(x, y):
    t = (y - CY) / RY
    rx = 20.0 + 3.0 * t          # narrower at the top, fuller at the base
    return ((x - CX) / rx) ** 2 + t * t < 1


def fn(c):
    k = 1.15 if c.small else 1.0
    tabE = K.knob('T', 'round', 51.6, 39, 1, 0, r=4.6 * k)
    blankW = K.knob('B', 'round', 12.4, 39, -1, 0, r=4.4 * k)
    body = c.m(egg, tabE, minus=(blankW,))
    c.add(body, PINK, stitch=None if c.small else '#f8b8d0')
    # stripes: yellow bands above and below the face band, thin magenta pinstripes
    ybands = [(22, 28), (49, 56)] if not c.small else [(21.5, 28), (48.5, 56)]
    for a, b in ybands:
        c.add(body & c.m(K.rect(0, a, 64, b)), YELL)
    for a, b in ([(19.5, 22), (28, 30.5), (46.5, 49), (56, 58.5)] if not c.small else [(19.5, 21.5), (28, 30), (46.5, 48.5)]):
        c.add(body & c.m(K.rect(0, a, 64, b)), MAGE)
    # dotted cream spots on the yellow bands (the painted dots in the picture), 64 px only
    if not c.small:
        for yy in (25, 52):
            for xx in range(14, 52, 6):
                p = c.P(xx + (3 if yy == 52 else 0), yy)
                c.px(p[0], p[1], '#fff4d8')
    # red bow on the tip: two loops, knot, two tails
    loops = c.m(K.ell(24.5, 11.5, 6.2, 4.6), K.ell(39.5, 11.5, 6.2, 4.6))
    tails = c.m(K.thick_path([(30, 15), (26, 21)], 3.6 if not c.small else 4.2),
                K.thick_path([(34, 15), (38, 21)], 3.6 if not c.small else 4.2))
    c.add(tails, RED)
    c.add(loops, RED)
    knot = c.m(K.ell(32, 13, 3.4, 3.4))
    c.add(knot, (RED[1], K.UMBER2, RED[0]))
    c.edge(loops, RED[1])
    # face on the calm pink band
    c.eye(29, 37)
    c.eye(42, 37)
    c.smile(35.5, 42, wide=True)
    c.blush(25, 41)
    c.blush(46, 41)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-eggs-6', 'Pink Stripe Egg', ROOT + '/art-review/redo/out',
                       cellfile=ROOT + '/art-review/redo/_src/pl-eggs-6-cell.png',
                       oldfile=ROOT + '/game/assets/img/puzzles/pals/pl-eggs-6.png')
    print(rep)
