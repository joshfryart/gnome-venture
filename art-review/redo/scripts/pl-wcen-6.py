#!/usr/bin/env python3
"""pl-wcen-6 Chestwatch Goldfish (rare, whimsy-goldfish, keyhole).
Concept: a plump goldfish whose body is the piece core, facing left: keyhole TAB on top (dorsal fin), keyhole BLANK on the
bottom (cut into the belly), keyhole BLANK on the left (its round open mouth), forked tail fan out the right side.
Lower body sinks into the cenote's teal water (cell 9-6) with aqua/foam ripple dashes; stone-grey band at the waterline lip."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path

GOLD = K.ramp('#f08a2a')
FIN = K.ramp('#e0502a')
TAIL = K.ramp('#f8b040')
WATER = K.ramp('#1f7a94')
STONE = K.ramp('#b4b8b4')
BELLY = K.ramp('#f8d890')
AQUA, FOAM = '#8ee8dc', '#d8fff0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 15, 44, 53)
    head = ell(26, 34, 16, 21)
    rnd = ell(30, 34, 17, 23)
    tabN = knob('T', 'keyhole', 29, 15, 0, -1, r=5.0 * k)
    blankS = knob('B', 'keyhole', 34, 53, 0, 1, r=4.2 * k)
    blankW = knob('B', 'keyhole', 7.5, 34, -1, 0, r=3.6 * k)
    tail = poly([(41, 28), (57, 12), (62, 16), (56, 34), (62, 52), (57, 56), (41, 40)])
    tailnotch = poly([(63, 25), (56, 34), (63, 43)])
    # square-ish core with only its left (head) side rounded, so it stays a piece with a fish's snout
    body = c.m(lambda x, y: core(x, y) and (x > 26 or head(x, y)), minus=(blankS, blankW))
    c.add(body, GOLD)
    # cream belly
    c.add(body & c.m(ell(26, 50, 12, 6)), BELLY)
    # tail and dorsal fin in the cenote's teal water, with aqua ripple stripes
    t = c.m(tail, minus=(tailnotch, core))
    c.add(t, WATER)
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 14, 64, 16.5))), WATER)
    if not c.small:
        for a, b in (((46, 30), (57, 17)), ((47, 34), (57, 34)), ((46, 38), (57, 51))):
            c.line([a, b], AQUA)
        c.line([(29, 7), (29, 11)], FOAM)
    else:
        c.line([(46, 30), (56, 18)], AQUA)
        c.line([(46, 38), (56, 50)], AQUA)
    # teal pectoral fin with a stone-grey edge (the cenote rim)
    pf = c.m(poly([(27, 35), (37, 34), (39, 42), (31, 43)]))
    c.add(pf, WATER)
    c.edge(pf, STONE[0])
    # scales on the gold back
    sc = ((30, 22), (36, 22), (33, 27), (39, 27), (40, 33)) if not c.small else ((32, 22), (39, 25))
    for (sx, sy) in sc:
        c.line([(sx - 2, sy - 1), (sx, sy + 1), (sx + 2, sy - 1)], GOLD[1])
    # gill arc
    c.line([(23, 21), (25.5, 28), (24, 35)], GOLD[1])
    c.eye(16, 26, disc=True)
    c.blush(19, 32)


K.render_pal(fn, 'pl-wcen-6', 'Chestwatch Goldfish', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wcen-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wcen-6.png')
