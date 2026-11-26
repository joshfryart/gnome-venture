#!/usr/bin/env python3
"""pl-wpea-3 Coral Fingerlings. Inner-TBTB, keyhole: a clump of pink coral fingers that IS a square piece.
N keyhole tab = the tallest middle finger's bulbous tip, S keyhole tab = the coral's holdfast foot on a blue rock;
keyhole blanks bite into the E and W sides of the clump. Four finger tips round the top edge (short notches only, so the
piece edge stays straight). Coral pink from cell 10-6, cove blue rock below, a hint of the cove's orange coral on the tips."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

PINK = K.ramp('#f690a8')
DEEP = ('#e06a8a', '#a84f68', '#f9b5c5')
ROCK = K.ramp('#3e7aa0')
TIP = ('#f9b5c5', '#f2a0b4', '#fde0e6')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(12, 21, 52, 52)
    tabN = knob('T', 'keyhole', 32, 21, 0, -1, r=5.2 * k)
    tabS = knob('T', 'keyhole', 32, 52, 0, 1, r=4.6 * k)
    blE = knob('B', 'keyhole', 52, 37, 1, 0, r=5.0 * k)
    blW = knob('B', 'keyhole', 12, 37, -1, 0, r=5.0 * k)
    # finger tips poking above the top edge (rounded)
    fw = 8.0 if not c.small else 8.6
    tips = [thick_path([(19, 24), (16.5, 11)], fw), thick_path([(45, 24), (47.5, 11)], fw)]
    # notches between fingers
    gap = 2.6 if not c.small else 3.2
    notches = [poly([(x - gap / 2, 13), (x + gap / 2, 13), (x + 0.5, 26), (x - 0.5, 26)]) for x in ()]
    body = c.m(core, tabN, *tips, minus=(blE, blW, *notches))
    c.add(body, PINK, stitch=None)
    # deeper pink inner fingers (two rear fingers between the front ones)
    for x0, x1 in ((20.5, 23), (41, 43.5)):
        pass
    # finger seams running down from the notches into the clump
    if not c.small:
        for x in (24, 40):
            c.line([(x, 21), (x + (1 if x > 32 else -1), 27)], DEEP[1])
    # rock / holdfast below
    rock = body & c.m(rect(0, 46, 64, 64)) | c.m(tabS, minus=(rect(0, 0, 64, 52),))
    c.add(c.m(tabS, minus=(rect(0, 0, 64, 52),)) | (body & c.m(rect(0, 48.5, 64, 64))), ROCK)
    # darker pink groove down each finger, like the cell's shaded coral
    for a, b in (((15, 13), (17, 24)), ((47, 13), (45, 24)), ((30, 12), (30, 22))):
        c.line([a, b], DEEP[0])
    # light-pink tips tips on the finger ends
    tipm = c.m(*[ell(x, y - 1.5, 4, 2.6) for x, y in ((16.5, 10.5), (47.5, 10.5))]) & body
    c.add(tipm, TIP)
    c.add(c.m(tabN, minus=(rect(0, 18, 64, 64),)) & c.m(rect(0, 0, 64, 13)), TIP)
    # polyp dots
    if not c.small:
        for (x, y) in ((15, 30), (48, 29), (23, 44), (42, 44), (17, 43), (46, 42)):
            px, py = c.P(x, y)
            c.px(px, py, DEEP[1])
    # face on the middle finger / clump
    c.eye(27, 34)
    c.eye(37, 34)
    c.smile(32, 40)
    c.blush(23.5, 38.5)
    c.blush(40.5, 38.5)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wpea-3', 'Coral Fingerlings', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpea-3-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpea-3.png'))
