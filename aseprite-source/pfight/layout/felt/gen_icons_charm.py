#!/usr/bin/env python3
"""Variant type icons for the Charm / Soothe / Trick sub-moves (felt "Stitched Toy" style, hard pixels only).

Same finish as the delivered ico-<type>.png set (aseprite-source/pfight/gen_pfight.py): glyph in the type's base
colour, auto light on the top-left edge, hue-shifted shade on the lower-right edge, 1 px ink outline, and (32 px only)
a 1 px cream halo plus a few white gloss pixels. The 20 px versions are redrawn on their own grid, outline only.

  hum   (soothe, sky)  : eighth note with two calm sound-wave arcs
  lull  (soothe, sky)  : crescent moon with a sleepy "z" and a small star
  bond  (charm, pink)  : two linked rings with a small heart over the link
  pluck (trick, yellow): finger and thumb pinching a little feather, lifting it

Run: python3 gen_icons_charm.py [out dir]   (default game/assets/img/pfight)
Writes ico-<name>.png (32x32) and ico-<name>-s.png (20x20).
"""
import os
import sys
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.normpath(os.path.join(HERE, '..', '..')))   # aseprite-source/pfight
import gen_pfight as P  # noqa: E402

INK, CREAM, GOLD, WHITE = P.INK, P.CREAM, P.GOLD, P.WHITE
TYPES, light_of, dark_of, finish_icon = P.TYPES, P.light_of, P.dark_of, P.finish_icon
CLEAR = (0, 0, 0, 0)
FEATHER = (30, 150, 130)          # same teal as the trick-mask feather
SKIN = TYPES['trick']


def canvas(S):
    im = Image.new('RGBA', (S, S), CLEAR)
    return im, ImageDraw.Draw(im)


def clear(im, pts):
    for x, y in pts:
        im.putpixel((x, y), CLEAR)


def ring_px(cx, cy, r_out, r_in):
    """pixel set of a ring, centres on pixel centres (hard edges)."""
    out = []
    for y in range(int(cy - r_out) - 1, int(cy + r_out) + 2):
        for x in range(int(cx - r_out) - 1, int(cx + r_out) + 2):
            d2 = (x - cx) ** 2 + (y - cy) ** 2
            if r_in ** 2 <= d2 <= r_out ** 2:
                out.append((x, y))
    return out


def arc_px(cx, cy, r_out, r_in, x_min):
    """right-hand part of a ring (a ')' sound wave)."""
    return [(x, y) for x, y in ring_px(cx, cy, r_out, r_in) if x >= x_min]


def put_art(im, art, pal, ox, oy):
    rows = [r.strip() for r in art.strip('\n').split('\n')]
    w = len(rows[0])
    for j, r in enumerate(rows):
        assert len(r) == w, (j, r)
        for i, ch in enumerate(r):
            if ch != '.':
                im.putpixel((ox + i, oy + j), pal[ch] + (255,))


def link_rings(im, L, R, ro, ri, col):
    """two interlocked rings: left ring passes over at the top crossing, under at the bottom.
    The ring underneath gets a 1 px ink cut on each side of the one on top."""
    A, B = set(ring_px(*L, ro, ri)), set(ring_px(*R, ro, ri))
    mx = (L[0] + R[0]) / 2.0
    cy = L[1]
    for p in A | B:
        im.putpixel(p, col + (255,))

    def over(top, under, upper):
        for (x, y) in top:
            if (y < cy) == upper and abs(x - mx) < (R[0] - L[0]) / 2.0 + 1:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    q = (x + dx, y + dy)
                    if q in under and q not in top:
                        im.putpixel(q, INK + (255,))
        for (x, y) in top:
            if (y < cy) == upper and abs(x - mx) < (R[0] - L[0]) / 2.0 + 1:
                im.putpixel((x, y), col + (255,))
    over(A, B, True)
    over(B, A, False)


# ---------------------------------------------------------------- hum: eighth note + sound waves
def ico_hum(S):
    im, d = canvas(S)
    b = TYPES['soothe']
    if S == 32:
        d.ellipse([2, 19, 11, 27], fill=b)                       # note head
        d.rectangle([9, 4, 11, 23], fill=b)                      # stem
        d.polygon([(11, 4), (13, 4), (16, 8), (16, 13), (14, 15), (14, 10), (11, 8)], fill=b)   # flag
        waves = [(x, y) for x, y in arc_px(11, 16, 10.4, 8.4, 19) if abs(y - 16) <= 6] + \
                [(x, y) for x, y in arc_px(11, 16, 15.4, 13.4, 23) if abs(y - 16) <= 9]
        for p in waves:
            im.putpixel(p, b + (255,))
        g = [(4, 21), (5, 21), (4, 22)]
    else:
        d.ellipse([1, 12, 6, 17], fill=b)
        d.rectangle([5, 2, 6, 15], fill=b)
        d.polygon([(7, 2), (9, 4), (9, 8), (8, 8), (8, 5), (7, 4)], fill=b)
        waves = [(x, y) for x, y in arc_px(6, 10, 7.0, 5.6, 11) if abs(y - 10) <= 4] + \
                [(x, y) for x, y in arc_px(6, 10, 10.6, 9.2, 14) if abs(y - 10) <= 6]
        for p in waves:
            im.putpixel(p, b + (255,))
        g = []
    return finish_icon(im, halo=(S == 32), gloss=g)


# ---------------------------------------------------------------- lull: crescent moon + z + star
Z32 = """
######
######
...##.
..##..
.##...
######
######"""
Z20 = """
####
..#.
.#..
####"""


def ico_lull(S):
    im, d = canvas(S)
    b = TYPES['soothe']
    if S == 32:
        d.ellipse([2, 5, 24, 27], fill=b)                        # moon disc
        d.ellipse([9, 2, 29, 22], fill=CLEAR)                    # bite -> crescent opening up-right
        put_art(im, Z32, {'#': CREAM}, 19, 9)                    # sleepy z
        for x, y in ((27, 1), (27, 2), (25, 3), (26, 3), (27, 3), (28, 3), (29, 3), (27, 4), (27, 5)):
            im.putpixel((x, y), GOLD + (255,))                   # little star
        g = [(5, 14), (5, 15), (6, 13)]
    else:
        d.ellipse([1, 3, 15, 17], fill=b)
        d.ellipse([6, 1, 19, 14], fill=CLEAR)
        put_art(im, Z20, {'#': CREAM}, 12, 5)
        for x, y in ((17, 1), (16, 2), (17, 2), (18, 2), (17, 3)):
            im.putpixel((x, y), GOLD + (255,))
        g = []
    return finish_icon(im, halo=(S == 32), gloss=g)


# ---------------------------------------------------------------- bond: two linked rings + heart
HEART7 = """
.##.##.
#######
#######
.#####.
..###..
...#..."""
HEART5 = """
##.##
#####
.###.
..#.."""


def heart_on(im, art, ox, oy):
    rows = [r.strip() for r in art.strip('\n').split('\n')]
    pts = [(ox + i, oy + j) for j, r in enumerate(rows) for i, c in enumerate(r) if c == '#']
    s = set(pts)
    for x, y in pts:                                             # ink seam where the heart sits on the rings
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            q = (x + dx, y + dy)
            if q not in s and im.getpixel(q)[3]:
                im.putpixel(q, INK + (255,))
    for p in pts:
        im.putpixel(p, CREAM + (255,))


def ico_bond(S):
    im, d = canvas(S)
    b = TYPES['charm']
    if S == 32:
        link_rings(im, (10.5, 19), (21.5, 19), 8.4, 4.9, b)
        heart_on(im, HEART7, 13, 6)
        g = [(5, 15), (6, 14), (14, 7)]
    else:
        link_rings(im, (6.5, 12), (13.5, 12), 5.4, 3.0, b)
        heart_on(im, HEART5, 8, 3)
        g = []
    return finish_icon(im, halo=(S == 32), gloss=g)


# ---------------------------------------------------------------- pluck: finger + thumb pinching a feather, lifting it
PLUCK32 = """
....................ff......
...................ffff.....
..................fffFf.....
.................fffFff.....
................fffFff......
...............fffFff.......
...............ffFff........
..............ffFff.........
..............fFff..........
.............ffFf...........
..........yyy.Fyyy..........
.........yyyy.Fyyyy.........
........yyyyydyyyyyy........
........yyyy..yyyyyyy.......
.......yyyy....yyyyyyy......
.......yyy......yyyyyyy.....
......yyyy.......yyyyyyy....
......yyy.........yyyyyy....
......yyy........dyyyyyyy...
......yyyy.......yyyyyyyy...
......yyyyyy...yyydyyyyyy...
.......yyyyyyyyyyyyyyyyyy...
.......yyyyyyyyyyyyyyyyy....
........yyyyyyyyyyyyyyy.....
.........yyyyyyyyyyyyy......
.........ccccccccccccc......
.........ccccccccccccc......
.........ccccccccccccc......"""
PLUCK20 = """
............ff....
...........fFf....
..........fFf.....
.........fFf......
.........Ff.......
......yy.F.yy.....
.....yyy.F.yyy....
.....yy.....yyy...
....yyy......yyy..
....yy.......yyy..
....yy......dyyy..
....yyyy...yyyyy..
.....yyyyyyyyyyy..
.....yyyyyyyyyy...
......yyyyyyyy....
......cccccccc....
......cccccccc....
.................."""


def ico_pluck(S):
    im, d = canvas(S)
    pal = {'f': FEATHER, 'F': dark_of(FEATHER), 'y': SKIN, 'd': dark_of(SKIN), 'c': CREAM}
    if S == 32:
        put_art(im, PLUCK32, pal, 2, 2)
        g = [(12, 13), (13, 12)]
    else:
        put_art(im, PLUCK20, pal, 1, 1)
        g = []
    return finish_icon(im, halo=(S == 32), gloss=g)


ICONS = {'hum': ico_hum, 'lull': ico_lull, 'bond': ico_bond, 'pluck': ico_pluck}


def main(out):
    os.makedirs(out, exist_ok=True)
    for t, f in ICONS.items():
        for S, suf in ((32, ''), (20, '-s')):
            im = f(S)
            assert im.size == (S, S) and im.mode == 'RGBA'
            im.save(os.path.join(out, 'ico-%s%s.png' % (t, suf)))
            print('ico-%s%s.png' % (t, suf), im.size, len(im.getcolors(4096)), 'colours')


if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else
         os.path.normpath(os.path.join(HERE, '..', '..', '..', '..', 'game', 'assets', 'img', 'pfight')))
