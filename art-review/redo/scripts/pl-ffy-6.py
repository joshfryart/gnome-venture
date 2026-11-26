#!/usr/bin/env python3
"""pl-ffy-6 Firefly Lamplighter (whimsy-firefly, round knobs).
Concept: a chibi firefly face-on whose body is the square piece: fuzzy brown head on top, glowing pale-yellow lantern belly below.
Tabs: W + E are the pale-blue wings (round tabs), S is the glowing tail bulb (round tab). Blank: N, a round notch in the fuzzy crown,
with the two antennae (yellow-green glow tips) rising on either side. Colours from the Firefly Caves fireflies (cell 11-4: brown fuzz, cream
eyes, pink blush) plus the lantern yellow and green halo of the picture."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROOT = '/home/user/gnome-venture'
BROWN = K.ramp('#6e4430')
FUZZ = K.ramp('#9a6a4a')
GLOW = ('#f2fc9d', '#c8d860', '#fffff0')
GLOWB = K.ramp('#e6f07a')
WING = ('#dbe4f6', '#a6b4d6', '#ffffff')
GREEN = K.ramp('#619c43')
TIP = ('#e8f870', '#9ccc3a', '#ffffd0')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(16, 14), (48, 14), (52, 18), (52, 52), (48, 56), (16, 56), (12, 52), (12, 18)])
    blankN = K.knob('B', 'round', 32, 14, 0, -1, r=4.2 * k)
    tabW = K.knob('T', 'round', 12, 32, -0.8, -0.6, r=(5.6 if c.small else 6.6), nw=3.2)
    tabE = K.knob('T', 'round', 52, 32, 0.8, -0.6, r=(5.6 if c.small else 6.6), nw=3.2)
    tabS = K.knob('T', 'round', 32, 56, 0, 1, r=5.2 * k)
    aw = 3.0 if c.small else 2.6
    antL = K.thick_path([(24, 15), (21, 9), (16, 5)], aw)
    antR = K.thick_path([(40, 15), (43, 9), (48, 5)], aw)
    tipL, tipR = K.ell(15.5, 4.8, 3.2, 3.2), K.ell(48.5, 4.8, 3.2, 3.2)
    body = c.m(core, minus=(blankN,))
    c.add(c.m(antL, antR), BROWN)
    c.add(c.m(tipL, tipR), TIP)
    # wings (W/E tabs), pale cave-blue
    c.add(c.m(tabW, minus=(core,)) | (c.m(tabW) & c.m(K.rect(11, 0, 13, 64))), WING)
    c.add(c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(K.rect(51, 0, 53, 64))), WING)
    # glowing lantern belly (lower half) with brown segment stripes
    belly = body & c.m(K.rect(0, 37, 64, 64))
    c.add(belly, GLOW)
    for yy in (44, 50):
        c.add(belly & c.m(K.rect(0, yy, 64, yy + (1.6 if c.small else 1.3))), GLOWB)
    # glowing tail bulb (S tab) in the halo green with a bright core
    c.add(c.m(tabS, minus=(core,)), GREEN)
    c.add(c.m(K.ell(32, 62, 2.6, 2.2)), TIP)
    # fuzzy brown head (upper half), scalloped hem over the belly
    head = c.m(lambda x, y: y < 37 + (1.5 if (int(x) // 4) % 2 else 0)) & body
    c.add(head, BROWN, stitch=None)
    if not c.small:
        for (x, y) in head:
            if (x * 7 + y * 3) % 13 == 0 and 18 < y < 34 and (x < 18 or x > 45 or y < 22):
                c.px(x, y, FUZZ[0])
    # wing veins
    wv = WING[1]
    c.line([(9, 29), (3, 24)], wv)
    c.line([(55, 29), (61, 24)], wv)
    # face
    c.eye(25, 28, disc=True)
    c.eye(39, 28, disc=True)
    c.blush(20.5, 33)
    c.blush(42.5, 33)
    c.smile(32, 33, K.CREAM)
    # little glow dots on the belly (64 px only)
    if not c.small:
        for (x, y) in ((24, 41), (30, 47), (38, 41), (35, 53), (27, 53)):
            c.px(*c.P(x, y), '#ffffff')


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-ffy-6', 'Firefly Lamplighter', ROOT + '/art-review/redo/out',
                       cellfile=ROOT + '/art-review/redo/_src/pl-ffy-6-cell.png',
                       oldfile=ROOT + '/game/assets/img/puzzles/pals/pl-ffy-6.png')
    print(rep)
