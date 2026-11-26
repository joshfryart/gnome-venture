#!/usr/bin/env python3
"""pl-bjq-2 Clownfish Peek. Edge-TTB, tri: a clownfish whose body IS the piece, facing east and peeking up out of a coral bed.
Flat S = the sand/coral bed. Tri tab W = the forked tail fin, tri tab N = the dorsal fin, tri blank E = the open little mouth nibbling.
Colours: reef-water blues from cell 3-5 behind the coral, pink and lilac coral + sand from the reef floor, clownfish orange/white bands."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp, UMBER, UMBER2, CREAM

ORANGE = ramp('#f07820')
STRIPE = ('#f4f0e4', '#c9c5bc', '#ffffff')
WATER = ('#264c88', '#223870', '#2a64a0')
CORAL = ramp('#e8689a')
LILAC = ramp('#9a7ac0')
SAND = ramp('#f0d498')
FIN = ramp('#f59a3a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(11, 13, 53, 57)
    nose = lambda x, y: x > 41 and y < 25 and ((x - 41) / 12) ** 2 + ((y - 25) / 12) ** 2 > 1   # rounded forehead/nose corner
    back = lambda x, y: x < 16 and y < 18 and ((x - 16) / 5) ** 2 + ((y - 18) / 5) ** 2 > 1
    tabN = knob('T', 'tri', 29, 13, 0, -1, r=5.2 * k)
    tabW = knob('T', 'tri', 11, 29, -1, 0, r=5.4 * k)
    blankE = knob('B', 'tri', 53, 34, 1, 0, r=4.2 * k)
    body = c.m(core, tabN, tabW, minus=(blankE, nose, back))
    c.add(body, WATER)                       # reef water of cell 3-5 shows between the coral
    fish = body & c.m(rect(0, 0, 64, 45.5), ell(33, 40, 20, 8))
    c.add(fish, ORANGE)
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 12, 64, 15))), FIN)
    c.add(c.m(tabW, minus=(core,)) | (c.m(tabW) & c.m(rect(9, 0, 12.5, 64))), FIN)
    # two curved white bands with umber borders: head band behind the eye, mid band
    bw = 2.6 if not c.small else 3.0
    for bx, bend in ((38, 0.06), (24, 0.04)):
        band = c.m(lambda x, y, bx=bx, bend=bend: abs(x - (bx - bend * (y - 29) ** 2 * 0.5 - 0)) < bw) & fish
        band -= c.m(tabN)
        c.add(band, STRIPE)
        c.edge(band, UMBER2)
    for t, cut in ((tabN, rect(0, 0, 64, 4.5)), (tabW, rect(0, 0, 3.4, 64))):
        c.add(c.m(t) & c.m(cut), (UMBER2, UMBER, UMBER2))
    # coral bed along the flat S side
    br = 3.6 if not c.small else 4.4
    coral = c.m(thick_path([(16, 57), (16, 47), (13, 43)], br), thick_path([(16, 51), (21, 46)], br),
                thick_path([(41, 57), (41, 48), (37, 44)], br), thick_path([(41, 51), (47, 45), (48, 42)], br)) & body
    c.add(coral, CORAL)
    puff = c.m(ell(28.5, 52, 6, 5), ell(50, 53, 4, 4.5)) & body
    c.add(puff, LILAC)
    c.add(c.m(rect(0, 54, 64, 64)) & body, SAND)
    if not c.small:
        for (x, y) in puff:
            if (x * 3 + y * 5) % 7 == 0:
                c.px(x, y, LILAC[1])
    # face on the head: eye, cheek; the E blank is the little open mouth
    c.eye(45.5, 25.5, disc=True)
    c.blush(47, 30.5)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-bjq-2', 'Clownfish Peek', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-bjq-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-bjq-2.png'))
