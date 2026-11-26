#!/usr/bin/env python3
"""pl-kava-4 "Dome Shelter": inner-TTTT, peg. A round thatched hut whose dome is the piece's top: N peg = the thatch topknot,
W + E pegs = the eave-beam ends poking out of the walls, S peg = the wooden doorstep. Its big window is the cell 4-3: the purple
night sea with the pink horizon band and gold sparkles (plus the picture's crescent moon). Thatch and beam ramps from the picture."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

THATCH = K.ramp('#c8925a')
THATCH_DK = '#644046'
BEAM = K.ramp('#ce8855')
POST = K.ramp('#8a5a3a')
SKY = ('#4a3a88', '#3a2e6c', '#5a4a98')
SEA = ('#5a4a98', '#4a3a88', '#6a5aa8')
PINK = ('#c06888', '#9a5070', '#d888a0')
GLINT = '#ffd8a0'
KNOT = K.ramp('#e2b174')


def fn(c):
    k = 1.15 if c.small else 1.0
    dome = lambda x, y: y < 27 and K.ell(32, 27, 21, 16)(x, y)
    core = lambda x, y: dome(x, y) or K.rect(11, 27, 53, 54)(x, y)
    tN = K.knob('T', 'peg', 32, 11.3, 0, -1, r=3.6 * k)
    tW = K.knob('T', 'peg', 11, 42, -1, 0, r=4.0 * k)
    tE = K.knob('T', 'peg', 53, 42, 1, 0, r=4.0 * k)
    tS = K.knob('T', 'peg', 32, 54, 0, 1, r=4.0 * k)
    body = c.m(core)
    # walls
    c.add(body, POST)
    # thatch dome + eave fringe (scalloped lower edge)
    fringe = lambda x, y: y < 31 + (1.6 if int(x // 3) % 2 else 0)
    thatch = c.m(core, minus=()) & c.m(fringe)
    c.add(thatch, THATCH)
    # thatch tiers: a darker cap tier with a scalloped hem, straw strokes on the sides (kept clear of the face)
    cap = c.m(dome) & c.m(lambda x, y: y < 16.5 + (1.4 if int(x // 3) % 2 else 0))
    c.edge(cap, THATCH[1])
    if not c.small:
        for (x, y) in thatch:
            X, Y = x / c.k, y / c.k
            if 17.5 < Y < 30 and (X < 19 or X > 45 or Y > 28.5) and x % 3 == 0 and (y + x) % 4 != 0:
                c.px(x, y, THATCH[1])
            elif 18 < Y < 21 and 20 < X < 44 and x % 4 == 1:
                c.px(x, y, THATCH[2])
    else:
        for (x, y) in thatch:
            X, Y = x / c.k, y / c.k
            if 18 < Y < 29 and (X < 17 or X > 46) and x % 2 == 0:
                c.px(x, y, THATCH[1])
    c.add(c.m(tN, minus=(core,)) | (c.m(tN) & c.m(K.rect(0, 10, 64, 12.5))), KNOT)
    # eave beam band under the fringe
    c.add(body & c.m(K.rect(0, 32.5, 64, 35.5)), BEAM)
    # beam-end pegs W/E and the doorstep S
    c.add(c.m(tW, minus=(core,)), BEAM)
    c.add(c.m(tE, minus=(core,)), BEAM)
    c.add(c.m(tS, minus=(core,)) | (c.m(tS) & c.m(K.rect(0, 52, 64, 54))), POST)
    # window = the cell: night sky, pink horizon, sparkling sea
    wx0, wx1 = 17.5, 46.5
    c.add(c.m(K.rect(wx0, 36, wx1, 42.5)), SKY)
    c.add(c.m(K.rect(wx0, 42.5, wx1, 45.5)), PINK)
    c.add(c.m(K.rect(wx0, 45.5, wx1, 51)), SEA)
    win = c.m(K.rect(wx0, 36, wx1, 51))
    c.edge(win, K.UMBER2)
    # crescent moon (picture) and sea glints (cell)
    moon = c.m(K.ell(40.5, 39.2, 2.4 if not c.small else 2.8, 2.4 if not c.small else 2.8),
               minus=(K.ell(39.2, 38.4, 2.2 if not c.small else 2.5, 2.2 if not c.small else 2.5),))
    for p in moon:
        c.px(*p, '#ffe6b0')
    for gx, gy in ((21, 47), (27, 49.3), (33, 47), (39, 49.3), (44, 47), (24, 38.5), (31, 37.6)):
        if c.small and (gx, gy) in ((24, 38.5),):
            continue
        c.px(*c.P(gx, gy), GLINT)
    # face on the thatch brow
    c.eye(25, 23, disc=True)
    c.eye(39, 23, disc=True)
    c.smile(32, 27.4, K.UMBER2)
    c.blush(21.5, 27)
    c.blush(42, 27)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-kava-4', 'Dome Shelter', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-kava-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-kava-4.png')
    print(rep)
