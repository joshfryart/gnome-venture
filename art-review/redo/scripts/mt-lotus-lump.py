#!/usr/bin/env python3
"""mt-lotus-lump "Lotus Lump": inner-TBTB, keyhole.
A plump pink lotus bud sitting on a green lily pad on the canal. N tab = the bud's pointed tip (pink keyhole), S tab = the lily-pad lobe
dipping into the teal water; E + W blanks cut into the bud's flanks. Petal seams in deep magenta, lily pad green, teal water ripple,
a yellow stamen peek -- colours from monsoontangle cell 1-6 (pink lotus bud over a green pad on teal canal water)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import ell, rect, poly, knob

PINK = K.ramp('#e8408b')
PETAL = ('#f990b8', '#e8408b', '#fcc6da')
PAD = ('#4ead69', '#2f8a4d', '#8ad49a')
WATER = ('#3b9aa0', '#2a7a83', '#7fc8c8')
SEAM = '#a82a66'
GOLD = '#efc43a'


def fn(c):
    k = 1.15 if c.small else 1.0
    # square-ish piece core: pink bud above, lily-pad band below, straight E/W sides between the blanks
    core = poly([(13, 48), (13, 22), (17, 17), (24, 14.5), (32, 13), (40, 14.5), (47, 17), (51, 22), (51, 48)])
    pad = ell(32, 47, 19, 5.5)
    tabN = knob('T', 'keyhole', 32, 13.5, 0, -1, r=4.6 * k)
    tabS = knob('T', 'keyhole', 32, 51, 0, 1, r=4.6 * k)
    blkE = knob('B', 'keyhole', 51, 31, 1, 0, r=3.8 * k)
    blkW = knob('B', 'keyhole', 13, 31, -1, 0, r=3.8 * k)
    blanks = (blkE, blkW)
    body = c.m(core, tabN, pad, minus=blanks)
    c.add(body, PINK)
    # outer side petals (deep pink) curve up from the pad to the tip; light centre petal carries the face
    cpet = c.m(poly([(32, 5), (39, 15), (42, 26), (41, 38), (32, 43), (23, 38), (22, 26), (25, 15)]), minus=blanks)
    c.add(cpet & body, PETAL)
    c.edge(cpet & body, SEAM)
    lpet = c.m(ell(22, 40, 8, 5), ell(42, 40, 8, 5), minus=blanks)
    # lily pad band + water lobe
    padm = c.m(pad, rect(13, 44, 51, 48), minus=blanks) & body
    c.add(padm, PAD)
    c.edge(padm, PAD[1])
    c.add(c.m(tabS, minus=(pad, rect(13, 44, 51, 48))), WATER)
    notch = c.m(poly([(32, 46), (28.5, 53), (35.5, 53)])) & body
    c.add(notch, WATER)
    if not c.small:
        c.line([(17, 47), (25, 46)], PAD[1])
        c.line([(39, 46), (47, 47)], PAD[1])
        c.line([(16, 24), (19, 34), (22, 41)], SEAM)
        c.line([(48, 24), (45, 34), (42, 41)], SEAM)
    # golden stamen peeking at the tip
    tx, ty = c.P(32, 7.5)
    for dx in range(-1, 1 if c.small else 2):
        c.px(tx + dx, ty, GOLD)
    c.eye(28.5, 28)
    c.eye(35.5, 28)
    c.smile(32, 33)
    c.blush(25, 33)
    c.blush(38.5 if not c.small else 37.5, 33)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'mt-lotus-lump', 'Lotus Lump', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/mt-lotus-lump-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mt-lotus-lump.png')
    print(rep)
