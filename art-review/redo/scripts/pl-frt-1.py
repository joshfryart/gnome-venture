#!/usr/bin/env python3
"""pl-frt-1 "Rime Crumb": corner-TT, peg. A squat frost toad sitting in the corner of the piece.
Flat W and S sides (it sits on the snow), peg tab N = a lump of snow on its head between the two eye domes,
peg tab E = its puffed ice-blue croak sac. Barrow-grass greens with snow patches and a tiny red doorway band (cell 4-5)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

GRASS = K.ramp('#8ac478')
MOSS = K.ramp('#5fa860')
SNOW = ('#f0f9fa', '#c6d2e0', '#ffffff')
ICE = ('#a4b4cc', '#6c7ca0', '#e8f0f4')
RED = '#d84a48'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(6, 22, 48, 60)
    eyeL = K.ell(15, 23, 7.5, 6.5)
    eyeR = K.ell(39, 23, 7.5, 6.5)
    tabN = K.knob('T', 'peg', 27, 22, 0, -1, r=4.6 * k)
    tabE = K.knob('T', 'peg', 48, 42, 1, 0, r=4.8 * k)
    body = c.m(core, eyeL, eyeR)
    c.add(body, GRASS)
    # dark grass blotches (warts) like the mound's shading
    blot = c.m(K.ell(14, 49, 5, 3.5), K.ell(37, 35, 4, 2.6), K.ell(28, 55, 6, 2.5), K.ell(11, 36, 3, 2.2))
    c.add(blot & body, MOSS)
    # front legs: darker arcs bent at the elbow
    for lx, d in ((13, 1), (37, -1)):
        c.add(c.m(K.thick_path([(lx, 40), (lx - 3 * d, 50), (lx + 1 * d, 58)], 3.4 if c.small else 3)) & body, MOSS)
    # snow patches drifting on its back (the barrow's snow)
    snow = c.m(K.ell(22, 41, 4.5, 2.6), K.ell(41, 52, 3.5, 2.2))
    c.add(snow & body, SNOW)
    # snow lump on the head = N peg tab
    c.add(c.m(tabN, K.ell(27, 22.5, 6.5, 3), K.ell(27, 13.5, 4.6 * k, 3.2)), SNOW)
    # croak sac = E peg tab, ice blue, bulging from the cheek
    c.add(c.m(tabE, K.ell(47, 42, 4, 6.5), K.ell(54.5, 42, 4.8 * k, 5.2 * k)), ICE)
    # wide toad mouth
    y = 33.5
    c.line([(10, y - 1.5), (14, y), (42, y), (46, y - 1.5)], K.UMBER)
    # toes along the bottom (pale)
    for tx in (9, 14, 34, 39, 44):
        x, yy = c.P(tx, 58)
        c.px(x, yy - 1, GRASS[2])
        if not c.small:
            c.px(x, yy - 2, GRASS[2])
    # red rope band from the barrow doorway, around one wrist
    if not c.small:
        for x in range(c.P(8, 0)[0], c.P(18, 0)[0]):
            c.px(x, c.P(0, 54)[1], RED)
    else:
        for x in range(c.P(8, 0)[0], c.P(18, 0)[0]):
            c.px(x, c.P(0, 54)[1], RED)
    c.eye(15, 23.5, disc=True)
    c.eye(39, 23.5, disc=True)
    c.blush(12, 29)
    c.blush(41, 29)


K.render_pal(fn, 'pl-frt-1', 'Rime Crumb', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-frt-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-frt-1.png')
