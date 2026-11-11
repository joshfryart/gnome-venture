#!/usr/bin/env python3
"""Hurt sub-type icons (felt "Stitched Toy" style, hard pixels only, no AA / no gradients).
Run: python3 gen_icons_hurt.py [out dir]   (default: game/assets/img/pfight)
Writes ico-<name>.png (32x32) and ico-<name>-s.png (20x20, redrawn) for
jab, pierce, sting, trip, bash, smash.

Same pipeline as the 7 base type icons (aseprite-source/pfight/gen_pfight.py): flat fills are drawn,
then gen_pfight.finish_icon() adds the 1 px light top-left / hue-shifted shade lower-right, the ink
outline, and (32 px only) the cream halo. All are Hurt orange (#d55e00) + cream / ink; identity is the
SILHOUETTE (colour-blind safe):
  jab    fist punching right + 3 speed dashes behind it
  pierce spear blade driven diagonally through an upright plank (shield line), splinters out the far side
  sting  striped wasp abdomen pointing down-left, needle stinger, falling poison drop
  trip   boot snagged on a taut rope between two stakes, toppling into it
  bash   round buckler with a domed boss over a jagged impact star
  smash  big maul head slammed down, handle up-right, impact rays fanning from the bottom
"""
import math
import os
import sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.normpath(os.path.join(HERE, '..', '..')))
import gen_pfight as GP  # noqa: E402

INK, CREAM, WHITE, GOLD = GP.INK, GP.CREAM, GP.WHITE, GP.GOLD
O = GP.TYPES['hurt']                 # #d55e00
OD = (0x9c, 0x36, 0x08)              # hurt pattern mark (base_icons TYPES['hurt'].mark)
DEEP = (0x8a, 0x2c, 0x0a)            # hurt shade
OL = (0xf0, 0x8a, 0x3c)              # hurt light
WOOD = (150, 100, 60)                # cork / handle (same as the item jar lid)
STEEL = (0xd2, 0xbf, 0x94)           # cream shade, reads as dull metal
POISON = (0x8e, 0xd0, 0x4a)          # leaf green from the felt set
NAMES = ['jab', 'pierce', 'sting', 'trip', 'bash', 'smash']


class Px:
    """tiny hard-pixel painter"""

    def __init__(s, S):
        s.S = S
        s.im = Image.new('RGBA', (S, S), (0, 0, 0, 0))
        s.p = s.im.load()

    def put(s, x, y, c):
        if 0 <= x < s.S and 0 <= y < s.S:
            s.p[x, y] = c + (255,)

    def clear(s, x, y):
        if 0 <= x < s.S and 0 <= y < s.S:
            s.p[x, y] = (0, 0, 0, 0)

    def rect(s, x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                s.put(x, y, c)

    def hline(s, x0, x1, y, c):
        s.rect(x0, y, x1, y, c)

    def vline(s, x, y0, y1, c):
        s.rect(x, y0, x, y1, c)

    def line(s, x0, y0, x1, y1, c):
        dx, dy = abs(x1 - x0), -abs(y1 - y0)
        sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
        e = dx + dy
        while True:
            s.put(x0, y0, c)
            if x0 == x1 and y0 == y1:
                break
            e2 = 2 * e
            if e2 >= dy:
                e += dy
                x0 += sx
            if e2 <= dx:
                e += dx
                y0 += sy

    def fill(s, test, c):
        for y in range(s.S):
            for x in range(s.S):
                if test(x + .5, y + .5):
                    s.put(x, y, c)

    def disc(s, cx, cy, r, c):
        s.fill(lambda x, y: (x - cx) ** 2 + (y - cy) ** 2 <= r * r, c)

    def poly(s, pts, c):
        def inside(x, y):
            n, ok = len(pts), False
            j = n - 1
            for i in range(n):
                xi, yi = pts[i]
                xj, yj = pts[j]
                if (yi > y) != (yj > y) and x < (xj - xi) * (y - yi) / (yj - yi) + xi:
                    ok = not ok
                j = i
            return ok
        s.fill(inside, c)

    def rows(s, x0, y0, art, pal):
        for j, r in enumerate(art):
            for i, ch in enumerate(r):
                if ch == ' ':
                    continue
                if ch == '_':
                    s.clear(x0 + i, y0 + j)
                else:
                    s.put(x0 + i, y0 + j, pal[ch])

    def done(s):
        return GP.finish_icon(s.im, halo=(s.S == 32), gloss=None)


def rot_ellipse(cx, cy, a, b, ang):
    ca, sa = math.cos(ang), math.sin(ang)

    def t(x, y):
        u = (x - cx) * ca + (y - cy) * sa
        v = -(x - cx) * sa + (y - cy) * ca
        return (u / a) ** 2 + (v / b) ** 2 <= 1
    return t


PAL = {'o': O, 'd': OD, 'D': DEEP, 'l': OL, 'c': CREAM, 'w': WHITE, 'k': INK, 'g': GOLD, 'b': WOOD, 's': STEEL,
       'p': POISON}


# ---------------------------------------------------------------- jab: fist punching right + speed dashes
def ico_jab(S):
    c = Px(S)
    if S == 32:
        art = [
            "     oooooooooo  ",
            "   oooooooooooooo",
            "cccoooooooooooooo",
            "cccooooooookkkkk ",
            "cccoooooooooooooo",
            "cccoooooooooooooo",
            "cccooooooookkkkk ",
            "cccoooooooooooooo",
            "cccoookkkkkkkoooo",
            "cccoolllllllkkkk ",
            "cccooddddddkooooo",
            "cccoooooooooooooo",
            "cccoooooooooooooo",
            "   ooooooooooooo ",
            "     ooooooooooo ",
        ]
        c.rows(12, 9, art, PAL)
        for y, x0, x1 in ((10, 3, 9), (15, 2, 9), (20, 3, 9)):
            c.rect(x0, y, x1, y + 1, CREAM)
    else:
        art = [
            "   ooooooo  ",
            " ooooooooooo",
            "ccoooookkkk ",
            "ccoooooooooo",
            "ccookkkkkkk ",
            "ccollllllkoo",
            "ccoooooooooo",
            "  ooooooooo ",
        ]
        c.rows(7, 5, art, PAL)
        for y, x0, x1 in ((6, 1, 4), (9, 1, 4), (12, 1, 4)):
            c.hline(x0, x1, y, CREAM)
    return c.done()


# ---------------------------------------------------------------- pierce: spear driven through an upright plank
def ico_pierce(S):
    c = Px(S)
    if S == 32:
        for i in range(-1, 2):                          # shaft, near side of the plank
            c.line(3 + i, 28, 12 + i, 19, WOOD)
            c.line(3, 28 + i, 12, 19 + i, WOOD)
        c.rect(10, 3, 15, 28, O)                       # plank (shield line), drawn over the shaft
        c.vline(12, 4, 27, OD)
        for y in (3, 28):
            c.clear(10, y)
            c.clear(15, y)
        c.rect(10, 18, 10, 21, INK)                    # entry hole
        c.rect(15, 15, 15, 18, INK)                    # exit hole
        for i in range(-1, 2):                          # shaft emerging on the far side
            c.line(16 + i, 16, 18 + i, 14, WOOD)
            c.line(16, 16 + i, 18, 14 + i, WOOD)
        c.poly([(16.5, 15.5), (19, 10), (29.7, 2.3), (22, 13)], STEEL)   # broad leaf blade
        c.poly([(17.5, 14), (19.8, 10.6), (29.7, 2.3)], WHITE)
        c.line(18, 13, 27, 5, STEEL)
        for (x, y) in ((17, 20), (18, 21), (20, 22), (17, 24), (18, 25), (21, 26)):   # splinters
            c.put(x, y, O)
    else:
        for i in range(-1, 1):
            c.line(2 + i, 17, 7 + i, 12, WOOD)
            c.line(2, 17 + i, 7, 12 + i, WOOD)
        c.rect(6, 2, 9, 17, O)
        c.vline(7, 3, 16, OD)
        for y in (2, 17):
            c.clear(6, y)
            c.clear(9, y)
        c.rect(6, 11, 6, 13, INK)
        c.rect(9, 9, 9, 11, INK)
        c.line(10, 9, 11, 8, WOOD)
        c.line(10, 10, 11, 9, WOOD)
        c.poly([(10, 9.5), (12, 6), (18.7, 1.3), (14, 9)], STEEL)
        c.poly([(11, 8.5), (12.5, 6.2), (18.7, 1.3)], WHITE)
        for (x, y) in ((11, 13), (12, 15)):
            c.put(x, y, O)
    return c.done()


# ---------------------------------------------------------------- sting: striped abdomen, stinger, poison drop
def ico_sting(S):
    c = Px(S)
    if S == 32:
        ang = math.radians(135)                         # axis points down-left
        cx, cy, a, b = 19.5, 10.5, 9.0, 6.2
        c.fill(rot_ellipse(cx, cy, a, b, ang), O)
        ux, uy = math.cos(ang), math.sin(ang)
        # stripes perpendicular to the axis
        def band(x, y):
            t = (x - cx) * ux + (y - cy) * uy
            return rot_ellipse(cx, cy, a, b, ang)(x, y) and any(lo <= t < hi for lo, hi in ((-3.5, -1.5), (1, 3), (5, 6.6)))
        c.fill(band, INK)
        # wing (cream) off the back
        c.fill(rot_ellipse(14.5, 4.5, 5.5, 2.6, math.radians(-20)), CREAM)
        # stinger
        tx, ty = cx + a * ux, cy + a * uy
        c.poly([(tx + 2.2, ty - 0.2), (tx - 0.2, ty + 2.2), (4.6, 23.4)], STEEL)
        c.line(int(tx), int(ty) + 1, 5, 23, WHITE)
        # poison drop
        c.poly([(5, 25), (7.6, 28.2), (2.4, 28.2)], POISON)
        c.disc(5.0, 27.6, 2.3, POISON)
    else:
        ang = math.radians(135)
        cx, cy, a, b = 12.5, 6.5, 6.0, 4.2
        c.fill(rot_ellipse(cx, cy, a, b, ang), O)
        ux, uy = math.cos(ang), math.sin(ang)

        def band(x, y):
            t = (x - cx) * ux + (y - cy) * uy
            return rot_ellipse(cx, cy, a, b, ang)(x, y) and any(lo <= t < hi for lo, hi in ((-2.5, -1.2), (0.6, 2), (3.4, 4.6)))
        c.fill(band, INK)
        c.fill(rot_ellipse(9, 2.5, 3.4, 1.6, math.radians(-20)), CREAM)
        tx, ty = cx + a * ux, cy + a * uy
        c.poly([(tx + 1.5, ty - 0.1), (tx - 0.1, ty + 1.5), (2.6, 14.4)], STEEL)
        c.put(3, 16, POISON)
        c.rect(2, 17, 4, 18, POISON)
    return c.done()


# ---------------------------------------------------------------- trip: boot snagged on a taut rope between stakes
def rot_pts(pts, ox, oy, deg, dx, dy):
    a = math.radians(deg)
    ca, sa = math.cos(a), math.sin(a)
    return [(dx + (x - ox) * ca - (y - oy) * sa, dy + (x - ox) * sa + (y - oy) * ca) for x, y in pts]


BOOT = [(0, 0), (6, 0), (6, 8), (11, 9), (13.5, 11), (13.5, 13), (0, 13)]      # side view, toe right
SOLE = [(0, 11.2), (13.5, 11.2), (13.5, 13), (0, 13)]
CUFF = [(-0.6, 0), (6.6, 0), (6.6, 2.2), (-0.6, 2.2)]


def ico_trip(S):
    c = Px(S)
    if S == 32:
        R = lambda p: rot_pts([(x * 1.15, y * 1.15) for x, y in p], 7.5, 15, 38, 11, 23)     # boot pitched forward, toe down into the rope
        c.poly(R(BOOT), O)
        c.poly(R(SOLE), DEEP)
        c.poly(R(CUFF), CREAM)
        c.rect(3, 18, 5, 28, WOOD)                        # stakes
        c.rect(26, 18, 28, 28, WOOD)
        c.put(4, 17, WOOD)
        c.put(27, 17, WOOD)
        c.rect(3, 22, 28, 23, CREAM)                      # rope, in front of the toe = snagged
        for x in range(4, 28, 3):
            c.put(x, 23, STEEL)
    else:
        R = lambda p: rot_pts([(x * .75, y * .75) for x, y in p], 5, 10, 38, 7, 15)
        c.poly(R(BOOT), O)
        c.poly(R(SOLE), DEEP)
        c.poly(R(CUFF), CREAM)
        c.rect(1, 12, 2, 18, WOOD)
        c.rect(17, 12, 18, 18, WOOD)
        c.hline(1, 18, 14, CREAM)
    return c.done()


# ---------------------------------------------------------------- bash: buckler with a boss over an impact star
def star(cx, cy, r_out, r_in, n, rot):
    pts = []
    for i in range(2 * n):
        r = r_out if i % 2 == 0 else r_in
        a = rot + i * math.pi / n
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def ico_bash(S):
    c = Px(S)
    if S == 32:
        c.poly(star(16, 16, 14.6, 9.5, 8, -math.pi / 2 + math.pi / 8), CREAM)
        c.disc(16, 16, 10.2, O)
        c.disc(16, 16, 8.2, DEEP)
        c.disc(16, 16, 7.2, O)
        for a in range(4):                               # rivets
            an = math.radians(45 + 90 * a)
            c.put(int(16 + 8.6 * math.cos(an) - .5) + (1 if math.cos(an) > 0 else 0),
                  int(16 + 8.6 * math.sin(an) - .5) + (1 if math.sin(an) > 0 else 0), GOLD)
        c.disc(16, 16, 3.6, STEEL)                       # boss
        c.disc(15.4, 15.4, 2.2, WHITE)
        c.put(14, 14, CREAM)
        # crack from the boss down-right
        for (x, y) in ((20, 19), (21, 20), (21, 21), (22, 22)):
            c.put(x, y, INK)
    else:
        c.poly(star(10, 10, 9.4, 6.0, 8, -math.pi / 2 + math.pi / 8), CREAM)
        c.disc(10, 10, 6.6, O)
        c.disc(10, 10, 5.2, DEEP)
        c.disc(10, 10, 4.3, O)
        c.disc(10, 10, 2.3, WHITE)
        c.put(10, 10, STEEL)
        c.put(11, 11, STEEL)
    return c.done()


# ---------------------------------------------------------------- smash: maul slammed down + impact rays
def ico_smash(S):
    c = Px(S)
    if S == 32:
        # handle up-right
        for i in range(0, 3):
            c.line(15 + i, 12, 25 + i, 2, WOOD)
        # maul head
        c.rect(6, 11, 25, 21, O)
        c.rect(6, 11, 8, 21, DEEP)                       # iron bands
        c.rect(23, 11, 25, 21, DEEP)
        c.rect(9, 13, 22, 13, OL)
        for (x, y) in ((6, 11), (25, 11), (6, 21), (25, 21)):
            c.clear(x, y)
        # impact rays fanning out from under the head (2 px so the outline does not swallow them)
        for i in (0, 1):
            c.line(5 + i, 24, 2 + i, 27, CREAM)
            c.line(25 + i, 24, 28 + i, 27, CREAM)
        c.rect(15, 24, 16, 28, CREAM)
    else:
        c.line(9, 7, 16, 1, WOOD)
        c.line(10, 7, 17, 1, WOOD)
        c.rect(3, 6, 16, 13, O)
        c.rect(3, 6, 4, 13, DEEP)
        c.rect(15, 6, 16, 13, DEEP)
        for (x, y) in ((3, 6), (16, 6), (3, 13), (16, 13)):
            c.clear(x, y)
        c.line(2, 15, 1, 17, CREAM)
        c.vline(9, 16, 18, CREAM)
        c.vline(10, 16, 17, CREAM)
        c.line(17, 15, 18, 17, CREAM)
    return c.done()


ICONS = {'jab': ico_jab, 'pierce': ico_pierce, 'sting': ico_sting, 'trip': ico_trip, 'bash': ico_bash,
         'smash': ico_smash}


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.normpath(os.path.join(HERE, '..', '..', '..', '..', 'game', 'assets', 'img', 'pfight'))
    os.makedirs(out, exist_ok=True)
    for n in NAMES:
        for S, suf in ((32, ''), (20, '-s')):
            im = ICONS[n](S)
            assert im.size == (S, S)
            a = im.getchannel('A')
            assert set(a.tobytes()) <= {0, 255}, 'alpha must be hard'
            im.save(os.path.join(out, 'ico-%s%s.png' % (n, suf)))
    print('wrote', 2 * len(NAMES), 'icons to', out)


if __name__ == '__main__':
    main()
