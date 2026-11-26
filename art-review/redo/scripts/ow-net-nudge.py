#!/usr/bin/env python3
"""ow-net-nudge "Net Nudge": a bundled teal fishing net that is a corner-TB piece (flat W and S, sitting on the quay).
Round tab N = the red-and-white cork float tied on top (the gnome's red hat colour from cell 3-6), round blank E cut into the net.
Diamond mesh in dark teal, cream knots, a tiny silver fish caught in the mesh. Colours from Olivewhistle (net, quay, red hat)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

NET = K.ramp('#3a9a8c')
MESH = '#1f5e57'
KNOT = '#bfe6d8'
RED = K.ramp('#d03a2a')
CORK = K.ramp('#f2ece0')
ROPE = K.ramp('#c8a060')
FISH = K.ramp('#a8bcc8')


def fn(c):
    Kk = 1.15 if c.small else 1.0
    # sack-shaped net bundle: straight W, S and E sides, top shoulders pinched up into the tie (still a square-ish core)
    core = K.poly([(8, 58), (8, 31), (11, 26), (19, 23), (41, 23), (49, 26), (54, 31), (54, 58)])
    tabN = K.knob('T', 'round', 30, 23, 0, -1, r=7.0 * Kk, nw=3.6)
    blankE = K.knob('B', 'round', 54, 42, 1, 0, r=5.2 * Kk)
    body = c.m(core, minus=(blankE,))
    c.add(body, NET)
    # net-bag mesh: cords fanning down from the tie + sagging rows, 1 px wide at both sizes
    w = 1.05 / c.k
    cords = [K.thick_path([(30, 16), (bx, 60)], w) for bx in (-6, 6, 18, 30, 42, 54, 66)]
    rows = [K.thick_path([(x, y0 + 2.0 * (1 - ((x - 31) / 24.0) ** 2)) for x in range(6, 58, 2)], w) for y0 in (30, 38.5, 47)]
    mesh = c.m(*(cords + rows))
    for q in mesh & body:
        c.edges[q] = MESH
    # rope tie where the float meets the net
    c.add(c.m(K.ell(30, 23, 8, 3.0)), ROPE)
    # float: red buoy on top with a white band (gnome-hat red from the cell)
    fl = c.m(tabN, minus=(K.rect(0, 21, 64, 64),))
    c.add(fl, RED)
    c.add(fl & c.m(K.rect(0, 10.5, 64, 14.5)), CORK)
    # rope bottom band (net sits on the quay rope coil)
    c.add(body & c.m(K.rect(0, 54.5, 64, 58)), ROPE)
    # little silver fish in the mesh, lower right
    fish = c.m(K.ell(42, 47, 5, 2.6), K.poly([(46, 47), (50.5, 44), (50.5, 50)]))
    c.add(fish & body, FISH)
    c.px(*c.P(39.5, 46.5), K.UMBER)
    # face on the calm upper-left net
    c.eye(21, 35, disc=True)
    c.eye(33, 35, disc=True)
    c.blush(16.5, 40)
    c.blush(36.5, 40)
    c.smile(27, 40)


K.render_pal(fn, 'ow-net-nudge', 'Net Nudge', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/ow-net-nudge-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/ow-net-nudge.png')
