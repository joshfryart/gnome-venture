"""pl-spsk-4 Spice Dunes: inner-TTTT peg. A heap of layered spice dunes (mint green / saffron gold / chilli red) as a square piece.
N peg = heaped cone peak with a mint sprig, E/W pegs = side cones spilling out, S peg = brass bowl foot on the red/gold checker (cell 3-6)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import math
import pal_kit as K

RED = K.ramp('#d8484a')
GOLD = K.ramp('#e8a84a')
GREEN = K.ramp('#3fa04a')
MINT = K.ramp('#7ccf6a')
BRASS = K.ramp('#c88a3a')
SAND = K.ramp('#c87a4a')
CHECK = K.ramp('#e8b058')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(21, 19), (43, 19), (51, 36), (51, 49), (13, 49), (13, 36)])
    tray = K.rect(11, 47, 53, 52)
    tN = K.knob('T', 'peg', 32, 19, 0, -1, r=4.6 * k)
    tE = K.knob('T', 'peg', 51, 41, 1, 0, r=3.8 * k)
    tW = K.knob('T', 'peg', 13, 41, -1, 0, r=3.8 * k)
    tS = K.knob('T', 'peg', 32, 52, 0, 1, r=4.2 * k)
    body = c.m(core, tray, tN, tE, tW, tS)
    # big back dune: red spice cone (light face on the left half)
    c.add(body, RED)
    c.add(body & c.m(lambda x, y: x < 32 and y < 47), K.ramp('#e45a50'))
    # front-left gold cone and front-right green cone, spilling out as the W / E pegs
    gl = c.m(K.poly([(10, 48), (21, 32), (34, 48)]), tW, minus=(K.rect(0, 47.5, 64, 64),))
    gr = c.m(K.poly([(30, 48), (43, 32), (54, 48)]), tE, minus=(K.rect(0, 47.5, 64, 64),))
    gl &= body
    gr &= body
    c.add(gl, GOLD)
    c.add(gr, GREEN)
    c.edge(gl, GOLD[1])
    c.edge(gr, GREEN[1])
    # brass tray + bowl foot (S peg) with the red/gold checker
    c.add(body & c.m(K.rect(0, 47.5, 64, 64)), BRASS)
    fx0, fy0 = c.P(27, 52.5)
    fx1, fy1 = c.P(37, 61)
    s = 2 if c.small else 3
    for y in range(fy0, fy1 + 1):
        for x in range(fx0, fx1 + 1):
            if (((x - fx0) // s) + ((y - fy0) // s)) % 2 == 0:
                c.px(x, y, '#d8484a')
    # sparse grains
    if not c.small:
        for (x, y) in [(24, 24), (29, 21), (36, 26), (40, 22), (19, 42), (25, 44), (44, 42), (38, 45)]:
            c.px(x, y, '#fff0c0')
    # pale spice dusting on the peak (N peg)
    c.add(c.m(tN, minus=(K.rect(0, 15, 64, 64),)), K.ramp('#f0c8a0'))
    # face on the red dune
    c.eye(27, 28)
    c.eye(37, 28)
    c.smile(32, 32)
    c.blush(23.5, 31.5)
    c.blush(40, 31.5)


K.render_pal(fn, 'pl-spsk-4', 'Spice Dunes', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-spsk-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-spsk-4.png')
print('ok')
