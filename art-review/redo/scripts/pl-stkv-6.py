import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp, UMBER2

# Rooftop Courier (whimsy-whitestork, keyhole): a plump white stork facing right IS the piece.
# N keyhole tab = neck + head, W keyhole tab = black tail, E keyhole blank bites the breast,
# flat S sits in the straw nest on a brick chimney top. Red beak carries the cream parcel. Pink/lilac sky satchel (cell 7-2).
WHITE = ('#f4f0e4', '#c9c5bc', '#ffffff')
WING = ('#3c3446', '#2e2836', '#5a5068')
BEAK = ramp('#d8402a')
STRAW = ramp('#c8a060')
BRICK = ramp('#b85a3a')
PARCEL = ramp('#eee0c0')
PINK = ramp('#e8789a')
LILAC = ramp('#9a62b0')

def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 24, 49, 44)
    tabN = knob('T', 'keyhole', 34, 24, 0, -1, r=6.6 * k, nw=3.0)
    tabW = knob('T', 'keyhole', 13, 34, -1, 0, r=4.6 * k)
    blankE = knob('B', 'keyhole', 49, 36, 1, 0, r=5.0 * k)
    body = c.m(core, tabN, minus=(blankE,))
    c.add(body, WHITE, stitch='#d8d0bc')
    # black tail (W tab) and black flight feathers along the lower back
    c.add(c.m(tabW, minus=(core,)) | (c.m(tabW) & c.m(rect(12, 0, 14, 64))), WING)
    wing = c.m(poly([(14, 35), (24, 34.5), (33, 39), (29, 44), (14, 44)]), minus=(blankE,)) & body
    c.add(c.m(rect(25, 43, 27.6, 48), rect(33, 43, 35.6, 48)), BEAK)
    c.add(wing, WING)
    # satchel strap and bag (pink with lilac strap) across the chest
    c.add(c.m(thick_path([(30, 25), (36, 34)], 2.8 if c.small else 2.4)) & body, LILAC)
    c.add(c.m(ell(37, 36, 3.2, 3.0)) & body, PINK)
    # beak: long red, pointing right out of the head, holding the parcel string
    c.add(c.m(poly([(38, 12.5), (55, 15.5), (55, 17.3), (38, 18.5)])), BEAK)
    c.add(c.m(thick_path([(53, 17), (54, 21)], 1.6 if not c.small else 2.4)), PARCEL)
    c.add(c.m(ell(54.5, 25, 4.8, 4.4)), PARCEL)
    c.add(c.m(rect(53.7, 21, 55.4, 29.4)), PINK)
    # straw nest under the body, chimney below
    nest = c.m(ell(31, 50, 22, 4.5), lambda x, y: 9 <= x < 53 and 47 + (1.2 if (int(x) // 3) % 2 else 0) <= y < 53)
    c.add(nest, STRAW)
    c.add(c.m(rect(17, 53, 45, 61)), BRICK)
    if not c.small:
        for (x, y) in nest:
            if (x * 3 + y * 5) % 7 == 0:
                c.px(x, y, STRAW[1])
            elif (x * 7 + y * 3) % 11 == 0:
                c.px(x, y, STRAW[2])
        for y in (c.P(0, 56)[1],):
            for x in range(c.P(17, 0)[0], c.P(45, 0)[0]):
                c.px(x, y, BRICK[1])
        for x in (c.P(25, 0)[0], c.P(37, 0)[0]):
            for y in range(c.P(0, 52.5)[1], c.P(0, 56)[1]):
                c.px(x, y, BRICK[1])
        for x in (c.P(31, 0)[0],):
            for y in range(c.P(0, 57)[1], c.P(0, 61)[1]):
                c.px(x, y, BRICK[1])
    else:
        y = c.P(0, 56.5)[1]
        for x in range(c.P(17, 0)[0], c.P(45, 0)[0]):
            c.px(x, y, BRICK[1])
    c.eye(35.5, 14.5)
    c.blush(32, 19)
    if not c.small:
        c.px(*c.P(40, 15.5), BEAK[1])

K.render_pal(fn, 'pl-stkv-6', 'Rooftop Courier', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-stkv-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-stkv-6.png')
