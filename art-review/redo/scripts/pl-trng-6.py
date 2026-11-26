#!/usr/bin/env python3
"""pl-trng-6 Tuftear Chipmunk (whimsy-chipmunk, keyhole).
Concept: a sitting chipmunk, face on, IS the piece: square body with straight sides; tufted ears at the top corners; W keyhole tab = the
white orb it holds (paw on the neck); E keyhole tab = the tip of its striped bushy tail; S keyhole blank between its two purple-socked feet.
Stump-wood ramps from cell 2-4 (tan #b88058, ring brown #70483a, light #d8a474); belly is a little tree-ring cross-section."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

WOOD = K.ramp('#b88058')
RING = ('#70483a', '#4e3230', '#946244')
LITE = ('#e8cfa4', '#d8a474', '#f6e8c8')
SOCK = K.ramp('#8a5ab0')
ORB = K.WHITE


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(13, 15, 51, 58)
    tabW = K.knob('T', 'keyhole', 13, 41, -1, 0, r=5.6 * k)
    tabE = K.knob('T', 'keyhole', 51, 27, 1, 0, r=7.0 * k)
    blankS = K.knob('B', 'keyhole', 32, 58, 0, 1, r=4.2 * k)
    earL = K.ell(19, 14, 6, 5.5)
    earR = K.ell(45, 14, 6, 5.5)
    tuftL = K.thick_path([(17.5, 10), (16, 6), (14, 5)], 3.4 if c.small else 3.0)
    tuftR = K.thick_path([(46.5, 10), (48, 6), (50, 5)], 3.4 if c.small else 3.0)
    body = c.m(core, earL, earR, minus=(blankS,))
    c.add(body, WOOD, stitch=None)
    # tufts + ear insides
    c.add(c.m(tuftL, tuftR), RING)
    c.add(c.m(K.ell(19, 15, 3, 2.8), K.ell(45, 15, 3, 2.8)), ('#e0a08a', '#c07a68', '#f0c0a8'))
    # bushy tail: rises up the right side and ends in the E tab, ring-striped
    tail = c.m(K.rect(43, 19, 51, 56), tabE, minus=(K.rect(0, 0, 43, 64),))
    c.add(tail, ('#946244', '#70483a', '#b88058'))
    c.edge(tail, RING[1])
    for yy in (23, 29, 35, 41, 47):
        c.add(c.m(K.rect(43, yy, 64, yy + 2.6)) & tail, RING)
    c.add(c.m(K.rect(55, 0, 64, 64)) & tail & c.m(K.ell(58.5, 27, 4.2, 4.2)), RING)
    c.add(c.m(K.ell(58.5, 27, 1.8, 1.8)) & tail, ('#946244', '#70483a', '#b88058'))
    # white orb held at the W tab
    orb = c.m(tabW, minus=(core,)) & c.m(K.rect(0, 0, 10.5, 64))
    c.add(orb, ORB)
    c.add(c.m(tabW, minus=(core,)) - orb, WOOD)
    # head stripes: dark centre stripe and two side stripes on the crown (chipmunk stripes = tree rings)
    c.add(c.m(K.rect(30.5, 15, 33.5, 23)), RING)
    # chipmunk face stripes: dark band through each eye, cream band above it
    c.add(c.m(K.poly([(13, 22), (21, 23), (21, 25), (13, 25)])), RING)
    c.add(c.m(K.poly([(43, 22), (35, 23), (35, 25), (43, 25)])), RING)
    c.add(c.m(K.poly([(13, 19.5), (21, 20.5), (21, 22.3), (13, 22.3)])), LITE)
    c.add(c.m(K.poly([(43, 19.5), (35, 20.5), (35, 22.3), (43, 22.3)])), LITE)
    # muzzle + cheeks
    c.add(c.m(K.ell(24.5, 32, 6.5, 4.6), K.ell(39.5, 32, 6.5, 4.6)), LITE)
    c.add(c.m(K.ell(32, 46, 9, 7.5)) & body, LITE)
    # tree rings on the belly
    ring = c.m(K.ell(32, 46, 6.3, 5.2), minus=(K.ell(32, 46, 4.9, 3.9),))
    c.edge(c.m(K.ell(32, 46, 9, 7.5)) & body, '#d8a474')
    for p in ring:
        if p in body:
            c.px(p[0], p[1], '#c49068')
    if not c.small:
        ring2 = c.m(K.ell(32, 46, 3.3, 2.5), minus=(K.ell(32, 46, 2.0, 1.4),))
        for p in ring2:
            c.px(p[0], p[1], '#c49068')
    # paw on the orb neck
    c.add(c.m(K.ell(15.5, 41, 3.2, 3.0)), WOOD)
    # purple socks
    c.add(c.m(K.ell(21, 55, 6.5, 3.8), K.rect(15, 54, 27, 58)) & body, SOCK)
    c.add(c.m(K.ell(43, 55, 6.5, 3.8), K.rect(37, 54, 44, 58)) & body, SOCK)
    # face
    c.eye(25, 24.5, disc=True)
    c.eye(38, 24.5, disc=True)
    nx, ny = c.P(32, 29)
    c.px(nx, ny, K.UMBER2)
    if not c.small:
        c.px(nx - 1, ny, K.UMBER2)
        c.px(nx + 1, ny, K.UMBER2)
    c.smile(32, 31.5, K.UMBER2)
    c.blush(21, 32)
    c.blush(42, 32)


rep = K.render_pal(fn, 'pl-trng-6', 'Tuftear Chipmunk', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-trng-6-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-trng-6.png')
print(rep)
