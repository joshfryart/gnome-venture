#!/usr/bin/env python3
"""pl-mirr-6 "Puddle Dancer" (rare, whimsy-saltflamingo, keyhole).
Concept: a chibi flamingo whose plump pink body IS the square piece core; the top keyhole tab is its neck and round head (beak hooked down),
the right keyhole tab is its fluffed tail, a keyhole blank bites the left side, and it stands on one leg (other leg bent, dancing) on a
mirror-salt puddle that carries its pink reflection. Colours from cell 1-4 / the Mirror Salt Flat: flamingo pink, magenta wing,
salt white, lavender mirror, sunset peach."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = K.ramp('#ff8ab0')
WING = K.ramp('#d8508a')
TAIL = K.ramp('#ffb0b8')
LEG = K.ramp('#e8608e')
SALT = ('#faf8fc', '#c9b8e0', '#ffffff')
MIRROR = K.ramp('#a786c6')
PEACH = K.ramp('#ff9c80')
BEAK = ('#fff4c8', '#e0c890', '#ffffff')


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
    core = rrect(9, 23, 51, 47, 4)
    blankN = K.knob('B', 'keyhole', 36, 23, 0, -1, r=3.8 * k, nw=2.2)             # keyhole bite in the back
    tabE = K.knob('T', 'keyhole', 51, 34, 1, 0, r=5.2 * k)               # fluffed tail tab
    blankW = K.knob('B', 'keyhole', 9, 38, -1, 0, r=4.6 * k)              # bite under the chest
    lw = 3.0 if c.small else 2.6
    nw = 5.6 if c.small else 5.0
    # puddle base (salt flat mirror)
    c.add(c.m(K.ell(32, 58, 22, 4.8)), MIRROR)
    c.add(c.m(K.ell(32, 57.3, 19, 3.2)), SALT)
    c.add(c.m(K.ell(33, 57.6, 8, 2.0)), PEACH)
    # legs: standing leg straight, dancing leg bent back
    c.add(c.m(K.thick_path([(29, 45), (29, 57)], lw)), LEG)
    c.add(c.m(K.thick_path([(37, 45), (43, 50), (37, 53)], lw)), LEG)
    # body = piece, S-neck rising from the front corner, round head
    neck = K.thick_path([(15, 28), (11, 21), (12, 14), (17, 10)], nw)
    head = K.ell(20, 9.5, 6.2, 5.6)
    body = c.m(core, neck, head, minus=(blankN, blankW))
    c.add(body, PINK)
    c.add(c.m(tabE, minus=(core,)), TAIL)
    # wing: a teardrop of magenta feathers sweeping back to the tail
    wing = c.m(K.ell(30, 35, 9, 6.5), K.poly([(30, 29), (47, 33), (30, 41.5)])) & body
    c.add(wing, WING)
    c.edge(wing, WING[1])
    if not c.small:
        c.line([(32, 35), (42, 35)], WING[2])
    # flamingo beak: pale base pointing forward, bending down to a dark tip
    c.add(c.m(K.poly([(24, 6.5), (31, 8), (33, 12), (31.5, 15.5), (29.5, 12.5), (24, 12)])), BEAK)
    c.add(c.m(K.poly([(29.5, 10.5), (32.6, 10.5), (31.5, 15.5), (29.2, 12.5)])), (K.UMBER2, K.UMBER, '#6a4a3a'))
    c.eye(19.5, 8.5)
    c.blush(16.5, 12)
    if not c.small:
        c.px(*c.P(16, 56), '#ffffff')
        c.px(*c.P(48, 58), '#ffffff')


K.render_pal(fn, 'pl-mirr-6', 'Puddle Dancer', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-mirr-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-mirr-6.png')
print(K.check(K.draw(fn, 64))['colours'])
