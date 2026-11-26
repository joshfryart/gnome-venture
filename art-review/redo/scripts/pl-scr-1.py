#!/usr/bin/env python3
"""pl-scr-1 "Pyramid Speck": corner-BB, hook. A tiny unfinished pyramid of tomb dust: flat base (sitting in the mauve dune) and flat
unfinished top (a gold course waiting for its capstone); hook blanks bitten into both sloping faces. Cream sunset sky + mauve dune
from cell 1-4, sandstone tan from the tomb."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

R = '/home/user/gnome-venture/'
SAND = K.ramp('#dea062')      # tomb sandstone (picture)
CREAMS = K.ramp('#f6dc98')    # cream sky of the cell
DUNE = K.ramp('#a8587a')      # mauve dune of the cell
GOLDC = K.ramp('#f0b838')     # golden sun / scarab ball


def fn(c):
    k = 1.15 if c.small else 1.0
    BL, BR, TL, TR, YB, YT = 3, 61, 27, 37, 59, 5
    core = K.poly([(BL, YB), (TL, YT), (TR, YT), (BR, YB)])
    # slope midpoints at y = 45, outward normals of the two faces
    dx, dy = TL - BL, YT - YB
    L = (dx * dx + dy * dy) ** 0.5
    nlx, nly = dy / L, -dx / L          # left face outward normal (points left/up)
    t = (42 - YB) / dy
    mL = (BL + dx * t, 42)
    mR = (64 - mL[0], 42)
    blankL = K.knob('B', 'hook', mL[0], mL[1], nlx, nly, r=3.6 * k)
    blankR = K.knob('B', 'hook', mR[0], mR[1], -nlx, nly, r=3.6 * k, flip=True)
    body = c.m(core, minus=(blankL, blankR))
    c.add(body, SAND, stitch=None)
    # cream sun-lit left face (light from upper left): left third of the pyramid
    lf = c.m(K.poly([(BL, YB), (TL, YT), (30, YT), (19, YB)]))
    c.add(lf & body, CREAMS)
    # mauve dune drift across the base
    dune = c.m(lambda x, y: y > 51 + 2.2 * __import__('math').sin(x / 6.0))
    c.add(dune & body, DUNE)
    # gold top course, still waiting for a capstone
    c.add(body & c.m(K.rect(0, 0, 64, 13)), GOLDC)
    # block courses (stone joints)
    joint = SAND[1]
    for yy in (20, 28, 36):
        x0 = BL + (TL - BL) * (YB - yy) / (YB - YT) + 1
        c.line([(x0, yy), (64 - x0, yy)], joint)
    if not c.small:
        for yy, xs in ((20, (32,)), (28, (28, 36)), (36, (25, 39))):
            for xx in xs:
                c.line([(xx, yy - 7.5), (xx, yy - 1)], joint)
    # face on the calm middle
    c.eye(27.5, 44)
    c.eye(36.5, 44)
    c.blush(25, 48)
    c.blush(38, 48)
    c.smile(32, 48)


K.render_pal(fn, 'pl-scr-1', 'Pyramid Speck', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-scr-1-cell.png', oldfile=R + 'game/assets/img/puzzles/pals/pl-scr-1.png')
