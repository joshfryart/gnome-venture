#!/usr/bin/env python3
"""Tall Tiptoe (th-tall-tiptoe), whimsy-giraffe, double knobs.
Concept: a giraffe facing right whose square torso is the piece; double tab on top = the two ossicones, double tab W = the tail tuft,
double blank E (under the neck, chest) and double blank S (between the legs). Savanna gold and patch brown from cell 5-3,
with a thatch-straw saddle blanket (the hut roof in the cell) and lavender trim (the mountain)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

ROOT = '/home/user/gnome-venture'
GIR = ramp('#e7b459')
PATCH = '#9a5f2a'
MANE = ramp('#794a1e')
STRAW = ramp('#f7c870')
LAVT = ramp('#c49aa4')
MUZ = ramp('#e0a07a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(8, 33, 52, 62)
    neck = poly([(34, 36), (49, 36), (50, 18), (39, 16)])
    head = ell(44, 17, 7.5, 6)
    snout = ell(52, 19.5, 5.5, 4.2)
    ow = 3.0 if not c.small else 3.6
    tabN = lambda x, y: (thick_path([(40, 13), (38.5, 6)], ow)(x, y) or thick_path([(46.5, 13), (47.5, 6)], ow)(x, y)
                         or ell(38.5, 5, 2.6 * k, 2.4 * k)(x, y) or ell(47.5, 5, 2.6 * k, 2.4 * k)(x, y))
    tabW = knob('T', 'double', 8, 42, -1, 0, r=4.2 * k)
    blankE = knob('B', 'double', 52, 47, 1, 0, r=4.0 * k)
    blankS = knob('B', 'double', 30, 62, 0, 1, r=4.6 * k)
    body = c.m(core, neck, head, snout, tabW, tabN, minus=(blankE, blankS))
    c.add(body, GIR)
    # reticulated patches (a 7-unit grid of brown blocks with gold gaps) on torso and neck
    def patch(x, y):
        gx, gy = (x + (3 if (y // 7) % 2 else 0)) % 7, y % 7
        return 1.6 < gx < 6.4 and 1.6 < gy < 6.4
    pm = c.m(lambda x, y: patch(x, y) and (core(x, y) and y < 52 or neck(x, y) and y > 24) and x > 10)
    for p in pm & body:
        c.px(p[0], p[1], PATCH)
    # thatch saddle blanket on the back (hut roof straw), lavender trim
    blanket = c.m(poly([(14, 33), (32, 33), (34, 43), (12, 43)])) & body
    c.add(blanket, STRAW)
    c.add(c.m(rect(11, 42, 35, 45)) & body, LAVT)
    if not c.small:
        for x in range(c.P(15, 0)[0], c.P(33, 0)[0], 2):
            for y in range(c.P(0, 35)[1], c.P(0, 41)[1]):
                if (x // 2 + y) % 3 == 0:
                    c.px(x, y, STRAW[1])
    else:
        for x in range(c.P(16, 0)[0], c.P(32, 0)[0], 2):
            c.px(x, c.P(0, 38)[1], STRAW[1])
    # mane down the back of the neck
    c.add(c.m(thick_path([(39.5, 18), (36, 35)], 3.0 if not c.small else 3.4)) & body, MANE)
    # ossicones and tail tuft in the dark brown
    c.add(c.m(tabN, minus=(head,)), GIR)
    c.add(c.m(ell(38.5, 5, 2.6 * k, 2.4 * k), ell(47.5, 5, 2.6 * k, 2.4 * k)), MANE)
    c.add(c.m(tabW, minus=(rect(8, 0, 64, 64),)) & c.m(rect(0, 0, 4.5, 64)), MANE)
    # hooves
    c.add(c.m(rect(0, 58.5, 64, 62)) & body, MANE)
    # snout, ear, face
    c.add(c.m(snout) & body, MUZ)
    c.add(c.m(ell(36.5, 14, 3.2, 1.8)), GIR)
    c.eye(45, 16.5)
    c.px(*c.P(55, 18), MANE[1])
    c.smile(52, 21, MANE[1])
    c.blush(48.5, 21)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'th-tall-tiptoe', 'Tall Tiptoe', ROOT + '/art-review/redo/out',
                       cellfile=ROOT + '/art-review/redo/_src/th-tall-tiptoe-cell.png',
                       oldfile=ROOT + '/game/assets/img/puzzles/pals/th-tall-tiptoe.png')
    print(rep)
