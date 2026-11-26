#!/usr/bin/env python3
"""pl-jrc-2 "Rootlet Swing": a jaguar cub that IS an edge piece (edge-TBB, peg).
Flat S (the cub's chin line), peg TAB N = the knot of hanging cave root it clings to with both paws,
peg BLANKS W and E cut into its cheeks. Round ears break out at the top corners.
Colours and motif from cell 3-3: jaguar orange with dark rosette spots, cream muzzle, rosy-brown nose."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

FUR = ('#f4a74e', '#b05a28', '#ffc470')
MUZ = ('#f8d8a0', '#d8a070', '#fff0c8')
ROOT = K.ramp('#c58f57')
EAR = K.ramp('#8c4c4c')
SPOT = '#2b1c26'
NOSE = '#8c4c4c'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(11, 22, 53, 58)
    tabN = K.knob('T', 'peg', 32, 22, 0, -1, r=5.2 * k)
    blW = K.knob('B', 'peg', 11, 42, -1, 0, r=4.0 * k)
    blE = K.knob('B', 'peg', 53, 42, 1, 0, r=4.0 * k)
    earL, earR = K.ell(15.5, 22, 6, 6), K.ell(48.5, 22, 6, 6)
    rootline = K.thick_path([(32, 1), (31, 6), (32, 12)], 3.4 if not c.small else 4.0)
    body = c.m(core, earL, earR, minus=(blW, blE))
    c.add(body, FUR, stitch=None)
    # the root knot (tab) and the strand it hangs from
    c.add(c.m(tabN, rootline, minus=(core,)), ROOT)
    c.add(c.m(K.ell(15.5, 22, 3, 3), K.ell(48.5, 22, 3, 3)), EAR)
    # paws gripping the knot
    c.add(c.m(K.ell(27.8, 17.5, 2.8, 3.0), K.ell(36.2, 17.5, 2.8, 3.0)), FUR)
    if not c.small:
        for x0 in (28.3, 35.7):
            c.line([(x0, 18.5), (x0, 20)], FUR[1])
    # cream muzzle + nose
    mz = c.m(K.ell(32, 48, 8.5, 6.5))
    c.add(mz, MUZ)
    nx, ny = c.P(32, 43.5)
    w = 2 if not c.small else 1
    for dx in range(-w, w + 1):
        c.px(nx + dx, ny, NOSE)
    for dx in range(-w + 1, w):
        c.px(nx + dx, ny + 1, NOSE)
    c.px(nx, ny + 2, SPOT)
    if not c.small:
        c.px(nx, ny + 3, SPOT)
        c.smile(32, 49.5, SPOT)
    # rosette spots (forehead, cheeks below the blanks, sides)
    spots = [(26, 25.5), (32, 27), (38, 25.5), (17, 33), (47, 33), (16, 53), (48, 53), (22, 55), (42, 55)]
    if c.small:
        spots = [(25, 26), (32, 27), (39, 26), (17, 33), (47, 33), (16, 53), (48, 53)]
    for sx, sy in spots:
        x, y = c.P(sx, sy)
        c.px(x, y, SPOT)
        c.px(x + 1, y, SPOT)
        if not c.small:
            c.px(x, y + 1, SPOT)
            c.px(x + 1, y + 1, SPOT)
            c.px(x + 2, y, SPOT)
            c.px(x - 1, y + 1, SPOT)
            c.px(x + 2, y + 2, SPOT)
    c.eye(25.5, 35)
    c.eye(38.5, 35)
    c.blush(21.5, 39) if not c.small else None
    c.blush(41.5, 39) if not c.small else None


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-jrc-2', 'Rootlet Swing', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-jrc-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-jrc-2.png')
    print(rep)
