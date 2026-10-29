#!/usr/bin/env python3
"""cf_room_cat.py: draws the four Cat-branch room overlays (2.1.08) into aseprite-source/catfish/test/.

Run: python3 aseprite-source/catfish/cf_room_cat.py [--out DIR]

Writes cf-room-bowl.png, cf-room-toybox.png, cf-room-cattree.png, cf-room-catflap.png: 320 x 200, alpha 0/255 only, drawn on the room's 2 x 2 px art grid
(160 x 100) in the room's own colours and with its 1-art-pixel dark outline, so they sit on cf-room.png like cf-room-rug.png does. Spots (room px, from room-layout.json):
  bowl     the base bowl [282,176,316,199] is repainted as a fancy bowl on a felt mat (the floor under it is refilled first)
  toybox   x 212..244, y 164..199, on the right end of the rug, left of the right-hand cat's feet
  cattree  x 202..238, y 76..150, behind the centre/right cats, clear of the hanging fish (the lowest fish ends at y 82 at x 198..246)
  catflap  x 246..272, y 84..114, in the blue wainscot between the tree and the scratch post
The overlay layer order in game/includes/catfish.php (CATFISH_ROOM_LAYERS) is back to front: window, sunbeam, rug, catflap, cattree, scratch, toybox, bowl.
"""
import argparse, os
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
O = (42, 26, 16)        # outline
B1 = (74, 44, 26); B2 = (116, 70, 42)
W1 = (138, 79, 42); W2 = (176, 122, 69); W3 = (199, 141, 82)     # wood, dark to light
FLOOR = (217, 166, 96)
CR1 = (232, 204, 152); CR2 = (242, 223, 182); CR3 = (248, 232, 196)   # cream, dark to light
PK = (228, 106, 155); PK2 = (184, 70, 110); PK3 = (242, 154, 187)
GD = (232, 163, 23); GD2 = (245, 207, 106)
GR = (95, 158, 72); GR2 = (63, 122, 58); GR3 = (140, 192, 100)
BL = (142, 170, 191); BL2 = (111, 138, 168); BL3 = (185, 207, 217); BL4 = (156, 207, 232)
TC = (200, 100, 60); TC2 = (224, 138, 90)


class Art:
    """A 160 x 100 art-pixel layer (each art pixel is 2 x 2 room px)."""
    def __init__(self):
        self.px = {}

    def p(self, x, y, c):
        if 0 <= x < 160 and 0 <= y < 100: self.px[(x, y)] = c

    def r(self, x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1): self.p(x, y, c)

    def outline(self, c=O):
        add = {}
        for (x, y) in self.px:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                k = (x + dx, y + dy)
                if k not in self.px and 0 <= k[0] < 160 and 0 <= k[1] < 100: add[k] = c
        self.px.update(add)

    def image(self):
        im = Image.new('RGBA', (320, 200), (0, 0, 0, 0))
        for (x, y), c in self.px.items():
            for dx in (0, 1):
                for dy in (0, 1): im.putpixel((x * 2 + dx, y * 2 + dy), c + (255,))
        return im


def bowl():
    a = Art()
    # a felt mat, pink with a stitched gold edge (art px 140..158 x 95..99)
    a.r(141, 96, 158, 99, PK)
    a.r(141, 96, 158, 96, PK3)
    for x in range(142, 158, 2): a.p(x, 98, GD)
    a.r(141, 99, 158, 99, PK2)
    # the bowl: cream ceramic, blue band, gold rim, a pink heart (art px 144..156 x 90..97)
    a.r(145, 92, 155, 92, GD2)
    a.r(144, 93, 156, 93, GD)
    a.r(144, 94, 156, 94, CR3)
    a.r(144, 95, 156, 95, BL3)
    a.r(145, 96, 155, 96, CR2)
    a.r(146, 97, 154, 97, CR1)
    for x in (147, 150, 153): a.p(x, 95, BL2)
    a.p(149, 96, PK); a.p(151, 96, PK); a.p(150, 97, PK2)
    for x in range(145, 156, 2): a.p(x, 94, CR2)
    # a heap of kibble over the rim
    a.r(146, 90, 154, 91, W2)
    a.r(147, 89, 153, 89, W3)
    for x, y in ((147, 91), (150, 90), (152, 91), (149, 89), (153, 90)): a.p(x, y, W1)
    a.p(151, 89, CR1)
    a.outline()
    out = a.image()
    # refill the floor under the old bowl first, so none of it shows around the new one
    base = Image.new('RGBA', (320, 200), (0, 0, 0, 0))
    for y in range(174, 200):
        for x in range(278, 320): base.putpixel((x, y), FLOOR + (255,))
    base.alpha_composite(out)
    return base


def toybox():
    a = Art()
    # crate (art px 124..137 x 90..98): wood boards, a pink stripe, a gold star
    a.r(124, 90, 137, 98, W2)
    a.r(124, 90, 137, 90, W3)
    a.r(124, 94, 137, 94, W1)
    a.r(124, 98, 137, 98, W1)
    a.r(124, 92, 137, 92, PK); a.r(124, 93, 137, 93, PK2)
    for x in range(125, 137, 3): a.p(x, 92, PK3)
    a.p(130, 96, GD); a.p(131, 96, GD2); a.p(130, 97, GD2); a.p(131, 97, GD); a.p(129, 96, GD); a.p(132, 96, GD)
    a.r(124, 90, 124, 98, W1); a.r(137, 90, 137, 98, W1)
    # toys over the rim: a teddy (left), a blue ball, a red ball, a mouse tail
    a.r(125, 86, 129, 89, W2); a.r(126, 85, 128, 85, W2)           # head
    a.p(125, 85, W1); a.p(129, 85, W1)                              # ears
    a.p(126, 87, O); a.p(128, 87, O); a.p(127, 88, B2)
    a.r(131, 86, 134, 89, BL); a.p(131, 86, BL3); a.p(132, 86, BL3); a.p(134, 89, BL2)
    a.r(135, 87, 137, 89, TC); a.p(135, 87, TC2); a.p(137, 89, PK2)
    a.p(133, 85, W1); a.p(133, 84, W1); a.p(134, 83, W1)             # a bit of string
    a.outline()
    a.px = {(x - 17, y): c for (x, y), c in a.px.items()}   # left of the right-hand cat's feet, on the end of the rug
    return a.image()


def cattree():
    a = Art()
    cx = 110
    # carpeted base
    a.r(101, 73, 119, 75, GR2); a.r(101, 72, 119, 72, GR); a.r(102, 71, 118, 71, GR3)
    # sisal post, rope bands
    for y in range(48, 71):
        a.r(cx - 2, y, cx + 2, y, CR1 if (y // 2) % 2 == 0 else W3)
    a.r(cx - 2, 48, cx - 2, 70, CR2); a.r(cx + 2, 48, cx + 2, 70, W2)
    # middle platform with a hanging toy
    a.r(102, 59, 118, 60, GR2); a.r(102, 58, 118, 58, GR); a.r(103, 57, 117, 57, GR3)
    a.r(103, 61, 117, 61, B2)
    a.p(104, 62, GD2); a.p(104, 63, GD2); a.p(104, 64, GD2); a.r(103, 65, 105, 66, GD); a.p(103, 65, GD2)
    # top: a cushioned perch with a little den roof
    a.r(103, 45, 117, 46, GR2); a.r(103, 44, 117, 44, GR); a.r(104, 43, 116, 43, GR3)
    a.r(103, 47, 117, 47, B2)
    a.r(106, 41, 114, 42, PK); a.r(107, 40, 113, 40, PK3); a.p(110, 41, GD)
    for x in (106, 108, 112, 114): a.p(x, 42, PK2)
    a.outline()
    return a.image()


def catflap():
    a = Art()
    # wooden frame (art px 123..136 x 42..57), dark opening, light flap
    a.r(123, 42, 136, 57, W2)
    a.r(123, 42, 136, 43, W3)
    a.r(123, 42, 123, 57, W3); a.r(136, 44, 136, 57, W1); a.r(124, 57, 136, 57, W1)
    a.r(125, 45, 134, 56, B1)
    a.r(125, 45, 134, 45, B2)
    a.r(126, 47, 133, 55, BL3)                  # the flap
    a.r(126, 47, 133, 47, BL2)                  # hinge
    a.r(126, 48, 126, 55, CR3); a.r(133, 48, 133, 55, BL)
    a.r(127, 48, 132, 48, BL4)
    a.r(126, 55, 133, 55, BL)
    # a pink paw on the flap
    a.r(129, 52, 130, 53, PK); a.p(128, 51, PK); a.p(129, 50, PK); a.p(130, 50, PK); a.p(131, 51, PK)
    # a gold hinge pin and a stitched sill
    a.p(125, 44, GD); a.p(134, 44, GD)
    for x in range(124, 136, 2): a.p(x, 58, W1)
    a.r(122, 58, 137, 58, W2); a.r(122, 59, 137, 59, W1)
    a.outline()
    return a.image()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default=os.path.join(HERE, 'test'))
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    for name, fn in (('bowl', bowl), ('toybox', toybox), ('cattree', cattree), ('catflap', catflap)):
        im = fn(); im.save(os.path.join(args.out, 'cf-room-%s.png' % name)); print('cf-room-%s.png' % name, im.getbbox())


if __name__ == '__main__':
    main()
