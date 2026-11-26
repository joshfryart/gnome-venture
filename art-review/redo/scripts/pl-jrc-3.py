#!/usr/bin/env python3
"""pl-jrc-3 Glowcap Nibble: inner-TBTB, tri. A glowing cave mushroom that is a puzzle piece.
N tab = the cap's pointed umbo (glowing tip), S tab = the root tip into the sand, W + E tri blanks cut into the chunky stem.
Colours from cell 0-6: purple cave rock for the cap, tan sand floor for the stem, green moss at the cap rim, pale yellow glow spots."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob

CAP = K.ramp('#8a5c8c')        # cave purple, lifted to glow
GILL = K.ramp('#563c52')       # dark cave rock
STEM = K.ramp('#c8a478')       # sand floor
ROOT = K.ramp('#8c6a52')       # dark sand
MOSS = K.ramp('#34704c')
GLOW = ('#f4e08a', '#d8b848', '#fff4c0')


def fn(c):
    k = 1.15 if c.small else 1.0
    cap = lambda x, y: ell(32, 31, 25.5, 18)(x, y) and y < 35
    stem = rect(13, 35, 51, 55)
    tabN = knob('T', 'tri', 32, 13.4, 0, -1, r=4.6 * k)
    tabS = knob('T', 'tri', 32, 55, 0, 1, r=4.4 * k)
    blW = knob('B', 'tri', 13, 45.5, -1, 0, r=4.2 * k)
    blE = knob('B', 'tri', 51, 45.5, 1, 0, r=4.2 * k)
    body = c.m(cap, stem, tabN, tabS, minus=(blW, blE))
    c.add(c.m(stem, tabS, minus=(blW, blE)), STEM, stitch=None if c.small else '#a88458')
    c.add(c.m(tabS, minus=(stem,)), ROOT)
    c.add(c.m(cap, tabN), CAP, stitch=None)
    c.add(c.m(tabN, minus=(cap,)), GLOW)
    gills = c.m(rect(7, 32, 57, 35.5), minus=(blW, blE))
    c.add(gills & c.m(cap), GILL)
    # moss tufts at the rim
    c.add(c.m(ell(11, 33.5, 4.2, 2.6), ell(53, 33.5, 4.2, 2.6)) & body, MOSS)
    # glow spots on the cap
    for (sx, sy, r) in ((17, 25, 3.2), (32, 18.5, 2.6), (47, 25, 3.2), (23.5, 19.5, 1.7), (40.5, 19.5, 1.7)):
        c.add(c.m(ell(sx, sy, r, r * 0.9)), GLOW)
    # sand speckles on stem
    for (sx, sy) in ((21, 39), (42, 50), (25, 51), (40, 38)):
        x, y = c.P(sx, sy)
        c.px(x, y, ROOT[0])
        if not c.small:
            c.px(x + 1, y, ROOT[0])
    # face on the cap
    c.eye(25.5, 27.5, disc=True)
    c.eye(38.5, 27.5, disc=True)
    c.smile(32, 30.5, col=K.UMBER)
    c.blush(20.5, 31)
    c.blush(43, 31)


K.render_pal(fn, 'pl-jrc-3', 'Glowcap Nibble', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-jrc-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-jrc-3.png')
