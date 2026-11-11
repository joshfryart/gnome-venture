#!/usr/bin/env python3
"""Puzzle Combat "charmed" end cards (64x64) and the gift icon (24x24), felt "Stitched Toy" style, hard pixels only.
Run: python3 gen_endcards.py [out dir]   (default: game/assets/img/pfight/)
Writes end-charmed-small.png, end-charmed-medium.png, end-charmed-large.png, end-charmed-boss.png, ico-gift.png.

Each card = one friendly creature, won over, with the charm flower (pink five-petal bloom, gold heart, green stem)
plus hearts and gold sparkles. The four creatures differ in SIZE and SILHOUETTE, not just colour:
  small  = mouse-squirrel, tiny, round ears + big curled tail, holds the flower up over its head
  medium = fox, pointed ears + wrapped brush tail, carries the flower in its mouth
  large  = bear, wide round mass filling the card, hugs a big bloom to its chest
  boss   = maned lion-king, scalloped mane + gold crown, holds a tall ceremonial flower sceptre with a gold bow
Rendering: shapes are painted as layers (back to front). Each layer gets its own dark line on its edge (selective
outline), a 1 px rim light top-left and one lower-right cel-shade band. A final pass turns the silhouette edge into
ink #2a1a10 and adds a 1 px cream halo #f2e4c0, like the pfight icons."""
import math
import os
import sys
import numpy as np
from PIL import Image, ImageDraw
import base_icons as B

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
INK, CREAM, GOLD = B.INK, B.CREAM, B.GOLD
hx = B.hx
WHITE = hx('#fff8e6')

# ramps: (rim light, base, cel shade, edge line) - hue-shifted: lights lean yellow, shades lean red/purple
R_FLOWER = (hx('#f8cce0'), hx('#e294bf'), hx('#a8588a'), hx('#5e2448'))
R_FLOWER2 = (WHITE, hx('#f2c6dc'), hx('#d88ab4'), hx('#9a4a7c'))     # inner petals of the ceremonial bloom
R_GOLD = (hx('#fbd877'), GOLD, hx('#a8650c'), hx('#6b3a08'))
R_STEM = (hx('#8fd05a'), hx('#4f9a3a'), hx('#2f6a32'), hx('#1c3f22'))
R_CREAM = (WHITE, CREAM, hx('#d2b994'), hx('#8a6a4a'))
R_PINKEAR = (hx('#f6c6cc'), hx('#e89aa4'), hx('#c06a7c'), hx('#7a3446'))
R_HEART = (hx('#ffb0b8'), hx('#e0566e'), hx('#a82c50'), hx('#5e1a2c'))
# creatures
R_MOUSE = (hx('#d6c9b0'), hx('#a8977e'), hx('#76627a'), hx('#45344a'))
R_MTAIL = (hx('#e8d8b4'), hx('#c4a77e'), hx('#94706a'), hx('#5a3c40'))
R_FOX = (hx('#f8ae5c'), hx('#e2702a'), hx('#a8432e'), hx('#62241c'))
R_SOCK = (hx('#6a4a52'), hx('#4a3038'), hx('#30202a'), INK)
R_BEAR = (hx('#a8784a'), hx('#7c5234'), hx('#563428'), hx('#2f1c18'))
R_BEARTAN = (hx('#ecc894'), hx('#cfa070'), hx('#a0704e'), hx('#5e3a26'))
R_LION = (hx('#f6d888'), hx('#dca552'), hx('#a8703e'), hx('#5e3820'))
R_MANE = (hx('#d0763a'), hx('#a44c26'), hx('#702a24'), hx('#3c1614'))
R_GEM = (hx('#bfe8ff'), hx('#3f9bd0'), hx('#1f5a8e'), hx('#0a2a4a'))
BLUSH = hx('#ec8a9a')

N = 64


class Canvas:
    def __init__(self, n=N):
        self.n = n
        self.a = np.zeros((n, n, 4), np.uint8)

    # ---- masks
    def blank(self):
        return Image.new('1', (self.n, self.n), 0)

    def ell(self, cx, cy, rx, ry):
        im = self.blank()
        ImageDraw.Draw(im).ellipse([cx - rx, cy - ry, cx + rx, cy + ry], fill=1)
        return np.array(im, bool)

    def poly(self, pts):
        im = self.blank()
        ImageDraw.Draw(im).polygon(pts, fill=1)
        return np.array(im, bool)

    def rect(self, x0, y0, x1, y1):
        m = np.zeros((self.n, self.n), bool)
        m[y0:y1 + 1, x0:x1 + 1] = True
        return m

    def line(self, pts, w=1):
        im = self.blank()
        ImageDraw.Draw(im).line(pts, fill=1, width=w)
        return np.array(im, bool)

    # ---- painting
    @staticmethod
    def shift(m, dx, dy):
        """value at (x, y) = m[y - dy, x - dx], outside = False"""
        h, w = m.shape
        o = np.zeros_like(m)
        ys, yd = (slice(0, h - dy), slice(dy, h)) if dy >= 0 else (slice(-dy, h), slice(0, h + dy))
        xs, xd = (slice(0, w - dx), slice(dx, w)) if dx >= 0 else (slice(-dx, w), slice(0, w + dx))
        o[yd, xd] = m[ys, xs]
        return o

    def erode(self, m):
        s = self.shift
        return m & s(m, 1, 0) & s(m, -1, 0) & s(m, 0, 1) & s(m, 0, -1)

    def put(self, m, col):
        self.a[m] = col + (255,)

    def layer(self, m, ramp, k=2, rim=True, edge=True):
        """fill with base, rim light top-left, cel-shade band k px lower-right, own dark line on the edge."""
        hi, base, sh, ln = ramp
        inner = self.erode(m) if edge else m
        self.put(m, ln if edge else base)
        self.put(inner, base)
        if k:
            band = inner & ~self.shift(inner, -k, -k)          # pixel (x+k, y+k) falls outside
            self.put(band, sh)
        if rim:
            r = inner & ~self.shift(inner, 1, 1) & ~(inner & ~self.shift(inner, -k, -k))
            self.put(r, hi)

    def px(self, pts, col):
        for x, y in pts:
            if 0 <= x < self.n and 0 <= y < self.n:
                self.a[y, x] = col + (255,)

    def stitch(self, m, col, on=2, off=1):
        """dashed stitch on the ring 1 px inside m's edge (gold stitched seam / felt patch)."""
        ring = self.erode(m) & ~self.erode(self.erode(m))
        pts = [(int(x), int(y)) for y, x in zip(*np.nonzero(ring))]
        i = 0
        for path in B.walk_ring(pts):
            for p in path:
                if i % (on + off) < on:
                    self.px([p], col)
                i += 1

    def glyph(self, x0, y0, rows, cmap):
        for j, r in enumerate(rows):
            for i, ch in enumerate(r):
                if ch in cmap:
                    self.px([(x0 + i, y0 + j)], cmap[ch])

    # ---- finish
    def dil(self, m, diag):
        o = m.copy()
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                if diag or dx == 0 or dy == 0:
                    o |= self.shift(m, dx, dy)
        return o

    def finish(self, deco=None):
        """silhouette edge -> ink, 1 px cream halo. deco (hearts, sparkles) is outlined OUTWARD so tiny glyphs keep their fill."""
        op = self.a[..., 3] > 0
        s = self.shift
        inside = op & s(op, 1, 0) & s(op, -1, 0) & s(op, 0, 1) & s(op, 0, -1)
        self.a[op & ~inside] = INK + (255,)
        nb = np.zeros_like(op)
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                nb |= s(op, dx, dy)
        self.a[nb & ~op] = CREAM + (255,)
        if deco is not None:
            dm = deco.a[..., 3] > 0
            ink = self.dil(dm, False) & ~dm
            halo = self.dil(dm | ink, True) & ~(dm | ink) & (self.a[..., 3] == 0)
            self.a[halo] = CREAM + (255,)
            self.a[ink] = INK + (255,)
            self.a[dm] = deco.a[dm]
        return Image.fromarray(self.a, 'RGBA')




# ------------------------------------------------------------------ shared bits
HEART = [".#.#.", "#####", "#####", ".###.", "..#.."]
HEART_S = ["#.#", "###", ".#."]
HEART_L = [".##.##.", "#######", "#######", "#######", ".#####.", "..###..", "...#..."]


def heart(c, x, y, size='m'):
    rows = {'s': HEART_S, 'm': HEART, 'l': HEART_L}[size]
    hi, base, sh, _ = R_HEART
    c.glyph(x, y, rows, {'#': base})
    h, w = len(rows), len(rows[0])
    # lower-right shade + one glint
    for j, r in enumerate(rows):
        for i, ch in enumerate(r):
            if ch == '#' and (j + 1 >= h or i + 1 >= w or rows[j + 1][i] != '#' or (i + 1 < w and r[i + 1] != '#')) and size != 's':
                if j >= h // 2 or i > w // 2:
                    c.px([(x + i, y + j)], sh)
    if size != 's':
        c.px([(x + 1, y + 1)], hi)


def sparkle(c, x, y, big=False):
    """4-point gold star (+ cream heart). big = 7x7, else 5x5. (x, y) = centre."""
    if big:
        c.px([(x, y - 3), (x, y - 2), (x, y + 2), (x, y + 3), (x - 3, y), (x - 2, y), (x + 2, y), (x + 3, y),
              (x - 1, y - 1), (x + 1, y - 1), (x - 1, y + 1), (x + 1, y + 1), (x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)], GOLD)
        c.px([(x, y)], WHITE)
        c.px([(x + 1, y + 1), (x + 2, y), (x, y + 2)], R_GOLD[2])
    else:
        c.px([(x, y - 2), (x, y + 2), (x - 2, y), (x + 2, y), (x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)], GOLD)
        c.px([(x, y)], WHITE)


def dot_sparkle(c, x, y):
    c.px([(x, y)], GOLD)


def flower(c, cx, cy, r, ramp=R_FLOWER, centre=R_GOLD, petals=5, rot=-math.pi / 2, pr=None, cr=None):
    """five round petals around a gold centre. r = petal ring radius."""
    pr = pr if pr is not None else r * 0.72
    m = np.zeros((c.n, c.n), bool)
    for i in range(petals):
        a = rot + i * 2 * math.pi / petals
        m |= c.ell(cx + r * math.cos(a), cy + r * math.sin(a), pr, pr)
    m |= c.ell(cx, cy, r, r)
    c.layer(m, ramp, k=1 if r < 4 else 2)
    # petal notches: line from centre outward between petals
    if r >= 4:
        for i in range(petals):
            a = rot + (i + 0.5) * 2 * math.pi / petals
            for t in np.arange(r * 0.7, r + pr * 0.55, 0.5):
                xx, yy = int(round(cx + t * math.cos(a))), int(round(cy + t * math.sin(a)))
                if m[yy, xx] and c.a[yy, xx][3] and tuple(c.a[yy, xx][:3]) != ramp[3]:
                    c.px([(xx, yy)], ramp[2])
    cr = cr if cr is not None else max(1.5, r * 0.5)
    cm = c.ell(cx, cy, cr, cr)
    c.layer(cm, centre, k=1)
    return m


def eye_open(c, x, y):
    """2x3 ink eye with a cream gloss comma."""
    c.px([(x, y), (x + 1, y), (x, y + 1), (x + 1, y + 1), (x, y + 2), (x + 1, y + 2)], INK)
    c.px([(x, y)], WHITE)


def eye_happy(c, x, y, w=3):
    """closed happy eye: an upward arc (^), w = 3 or 4 wide."""
    if w == 3:
        c.px([(x, y + 1), (x + 1, y), (x + 2, y + 1)], INK)
    else:
        c.px([(x, y + 1), (x + 1, y), (x + 2, y), (x + 3, y + 1)], INK)


# ------------------------------------------------------------------ small: mouse-squirrel holding the flower up
def small():
    c = Canvas()
    # tail: a big curled plume behind, on the left
    tail = c.ell(17, 45, 7, 11) | c.ell(14, 33, 6, 7) | c.ell(19, 26, 6, 4) | c.ell(24, 28, 3, 3)
    tail &= ~c.ell(19, 32, 2, 2)                                 # curl hole
    c.layer(tail, R_MTAIL, k=2)
    c.stitch(c.ell(16, 42, 4, 7), R_MTAIL[2], 1, 1)                 # fluff stitching down the plume
    # flower stem (behind the paws) rising up and right
    c.put(c.line([(36, 47), (40, 37), (44, 27)], 2), R_STEM[1])
    c.px([(41, 36), (42, 33), (43, 30)], R_STEM[0])
    leaf = c.poly([(41, 37), (47, 33), (49, 35), (44, 39)])
    c.layer(leaf, R_STEM, k=1)
    # feet
    c.layer(c.ell(27, 58, 3, 2) | c.ell(38, 58, 3, 2), R_PINKEAR, k=1, rim=False)
    # body
    body = c.ell(32, 50, 9, 9)
    c.layer(body, R_MOUSE, k=2)
    belly = c.ell(33, 52, 5, 6)
    c.layer(belly, R_CREAM, k=1, edge=False)
    # ears (round, pink inside)
    ears = c.ell(25, 31, 4, 4) | c.ell(40, 30, 4, 4)
    c.layer(ears, R_MOUSE, k=1)
    c.layer(c.ell(25, 31, 2, 2) | c.ell(40, 30, 2, 2), R_PINKEAR, k=0, rim=False, edge=False)
    # head
    head = c.ell(32, 38, 8, 7)
    c.layer(head, R_MOUSE, k=2)
    c.layer(c.ell(33, 41, 4, 3), R_CREAM, k=1, edge=False)        # muzzle
    eye_open(c, 28, 36)
    eye_open(c, 35, 36)
    c.px([(33, 40), (34, 40)], hx('#c06a7c'))                       # nose
    c.px([(32, 42), (35, 42)], R_MOUSE[3])                          # smile
    c.px([(33, 43), (34, 43)], R_MOUSE[3])
    c.px([(26, 40), (27, 40), (39, 40), (40, 40)], BLUSH)
    # whiskers
    c.px([(23, 40), (24, 41), (43, 40), (42, 41)], R_MOUSE[3])
    # paws gripping the stem
    paws = c.ell(35, 47, 2, 2) | c.ell(38, 45, 2, 2)
    c.layer(paws, R_MOUSE, k=1)
    # the flower, held up high
    flower(c, 46, 20, 4.5)
    # hearts and sparkles
    d = Canvas()
    heart(d, 52, 33, 'm')
    heart(d, 8, 13, 's')
    heart(d, 54, 6, 's')
    sparkle(d, 30, 12, big=True)
    sparkle(d, 56, 47)
    sparkle(d, 7, 57)
    dot_sparkle(d, 40, 8)
    dot_sparkle(d, 21, 6)
    return c.finish(d)


# ------------------------------------------------------------------ medium: fox carrying the flower in its mouth
def medium():
    c = Canvas()
    # brush tail curled round the right side to the front, cream tip
    tail = c.ell(46, 49, 9, 8) | c.ell(51, 39, 6, 8)
    c.layer(tail, R_FOX, k=2)
    # body (sitting pear)
    body = c.ell(28, 46, 11, 13)
    c.layer(body, R_FOX, k=3)
    bib = c.poly([(21, 36), (35, 36), (32, 50), (28, 54), (24, 50)])
    c.layer(bib, R_CREAM, k=1, edge=False)
    c.stitch(bib, R_CREAM[2], 2, 1)
    # front legs with dark socks
    legs = c.rect(21, 49, 25, 60) | c.rect(30, 49, 34, 60)
    c.layer(legs, R_FOX, k=1)
    socks = (c.rect(21, 56, 25, 60) | c.rect(30, 56, 34, 60))
    c.layer(socks & legs, R_SOCK, k=1)
    c.px([(23, 60), (32, 60)], R_SOCK[3])
    # front of the tail wrapped round the feet, cream tip
    wrap = c.ell(43, 57, 9, 3.5)
    c.layer(wrap, R_FOX, k=1)
    c.layer(c.ell(35, 57, 4, 3), R_CREAM, k=1)
    # ears
    earl = c.poly([(15, 25), (17, 9), (26, 20)])
    earr = c.poly([(30, 20), (39, 9), (41, 25)])
    c.layer(earl | earr, R_FOX, k=1)
    c.layer(c.poly([(18, 22), (18.5, 13), (23, 20)]) | c.poly([(33, 20), (38, 13), (38, 22)]), R_SOCK, k=0, rim=False, edge=False)
    # head: wide cheeks with fluff points
    head = c.ell(28, 27, 11, 8) | c.poly([(14, 27), (18, 31), (17, 34)]) | c.poly([(42, 27), (38, 31), (39, 34)])
    c.layer(head, R_FOX, k=2)
    face = c.poly([(19, 29), (24, 27), (28, 30), (32, 27), (37, 29), (33, 35), (28, 37), (23, 35)])
    c.layer(face, R_CREAM, k=1, edge=False)
    eye_happy(c, 21, 25, 4)
    eye_happy(c, 31, 25, 4)
    c.px([(27, 32), (28, 32), (29, 32), (28, 33)], INK)              # nose
    c.px([(19, 30), (20, 30), (36, 30), (37, 30)], BLUSH)
    # flower in its mouth: stem from the mouth corner out to the right, bloom beside the cheek
    c.put(c.line([(27, 35), (36, 34), (44, 30)], 1), R_STEM[2])
    c.put(c.line([(36, 33), (44, 29)], 1), R_STEM[1])
    leaf = c.poly([(37, 34), (41, 37), (45, 37), (41, 34)])
    c.layer(leaf, R_STEM, k=1)
    flower(c, 49, 26, 4.5)
    # hearts and sparkles
    d = Canvas()
    heart(d, 8, 8, 'l')
    heart(d, 45, 6, 'm')
    heart(d, 3, 44, 's')
    sparkle(d, 56, 13, big=True)
    sparkle(d, 6, 30)
    sparkle(d, 58, 58)
    dot_sparkle(d, 30, 6)
    dot_sparkle(d, 12, 56)
    return c.finish(d)


# ------------------------------------------------------------------ large: bear hugging a big bloom
def large():
    c = Canvas()
    # body: wide round mass
    body = c.ell(32, 44, 24, 16)
    c.layer(body, R_BEAR, k=3)
    belly = c.ell(32, 47, 13, 10)
    c.layer(belly, R_BEARTAN, k=2, edge=False)
    c.stitch(belly, R_BEARTAN[2], 2, 1)
    # legs out front, soles to the viewer
    for fx in (16, 48):
        foot = c.ell(fx, 55, 8, 6)
        c.layer(foot, R_BEAR, k=2)
        c.layer(c.ell(fx, 56, 4, 3), R_BEARTAN, k=1)
        c.px([(fx - 4, 50), (fx, 49), (fx + 4, 50)], R_BEARTAN[1])
        c.px([(fx - 4, 51), (fx, 50), (fx + 4, 51)], R_BEARTAN[2])
    # flower stem down the belly
    c.put(c.line([(32, 41), (32, 53)], 2), R_STEM[1])
    c.px([(32, y) for y in range(43, 53)], R_STEM[0])
    c.layer(c.poly([(34, 49), (39, 46), (41, 48), (36, 51)]), R_STEM, k=1)
    # ears
    ears = c.ell(18, 11, 6, 6) | c.ell(46, 11, 6, 6)
    c.layer(ears, R_BEAR, k=2)
    c.layer(c.ell(18, 11, 3, 3) | c.ell(46, 11, 3, 3), R_BEARTAN, k=1, rim=False, edge=False)
    # head
    head = c.ell(32, 23, 16, 12)
    c.layer(head, R_BEAR, k=3)
    muz = c.ell(32, 28, 7, 5)
    c.layer(muz, R_BEARTAN, k=2)
    c.glyph(29, 24, ["#######", ".#####.", "..###.."], {'#': INK})      # nose
    c.px([(30, 24)], hx('#6a4a52'))
    c.px([(32, 27)], INK)
    c.px([(29, 29), (30, 30), (31, 30), (33, 30), (34, 30), (35, 29), (32, 29)], INK)  # w smile
    eye_happy(c, 21, 20, 4)
    eye_happy(c, 39, 20, 4)
    c.px([(19, 25), (20, 25), (21, 25), (43, 25), (44, 25), (45, 25)], BLUSH)
    # the bloom on the chest
    flower(c, 32, 39, 6.5)
    # arms hugging it, paws over the lower petals
    arms = c.ell(15, 40, 6, 9) | c.ell(49, 40, 6, 9)
    c.layer(arms, R_BEAR, k=2)
    paws = c.ell(24, 45, 4, 3) | c.ell(40, 45, 4, 3)
    c.layer(paws, R_BEAR, k=1)
    c.px([(22, 44), (24, 43), (26, 44), (38, 44), (40, 43), (42, 44)], R_BEAR[3])
    # hearts and sparkles
    d = Canvas()
    heart(d, 2, 22, 'l')
    heart(d, 55, 22, 'm')
    heart(d, 30, 2, 's')
    sparkle(d, 5, 4, big=True)
    sparkle(d, 59, 4)
    dot_sparkle(d, 60, 36)
    dot_sparkle(d, 3, 36)
    return c.finish(d)


# ------------------------------------------------------------------ boss: maned lion-king with a ceremonial flower sceptre
def boss():
    c = Canvas()
    # tail with tuft, curling up on the left
    c.put(c.line([(18, 56), (10, 52), (7, 44)], 2), R_LION[3])
    c.put(c.line([(18, 55), (11, 51), (8, 44)], 1), R_LION[1])
    c.layer(c.ell(7, 41, 3, 4), R_MANE, k=1)
    # body sitting
    body = c.ell(28, 49, 14, 12)
    c.layer(body, R_LION, k=3)
    chest = c.ell(28, 47, 7, 8)
    c.layer(chest, R_CREAM, k=1, edge=False)
    c.stitch(chest, R_CREAM[2], 2, 1)
    # front paws
    paws = c.ell(22, 59, 4, 3) | c.ell(34, 59, 4, 3)
    c.layer(paws, R_LION, k=1)
    c.px([(21, 60), (23, 60), (33, 60), (35, 60)], R_LION[3])
    # mane: scalloped ring of puffs
    mane = c.ell(28, 27, 15, 14)
    for i in range(12):
        a = i * 2 * math.pi / 12
        mane |= c.ell(28 + 14 * math.cos(a), 27 + 13 * math.sin(a), 4.5, 4.5)
    c.layer(mane, R_MANE, k=3)
    for i in range(12):                                             # tuft lines between puffs
        a = (i + 0.5) * 2 * math.pi / 12
        for t in (13, 14, 15):
            c.px([(int(round(28 + t * math.cos(a))), int(round(27 + t * math.sin(a))))], R_MANE[2])
    # head
    head = c.ell(28, 28, 10, 9)
    c.layer(head, R_LION, k=2)
    c.layer(c.ell(25, 33, 3, 3) | c.ell(31, 33, 3, 3), R_CREAM, k=1)  # muzzle puffs
    c.glyph(26, 29, ["#####", ".###.", "..#.."], {'#': hx('#8a4a3c')})  # nose
    c.px([(26, 29)], hx('#c07a6a'))
    c.px([(28, 32), (27, 36), (28, 36), (29, 36)], R_LION[3])
    eye_happy(c, 20, 25, 4)
    eye_happy(c, 32, 25, 4)
    c.px([(20, 23), (21, 22), (22, 22), (34, 22), (35, 22), (36, 23)], R_LION[3])   # brows
    c.px([(19, 29), (20, 29), (36, 29), (37, 29)], BLUSH)
    # crown on top of the mane
    crown = c.poly([(17, 15), (17, 6), (21, 10), (24, 3), (28, 9), (32, 3), (35, 10), (39, 6), (39, 15)])
    c.layer(crown, R_GOLD, k=2)
    band = c.rect(17, 12, 39, 15) & crown
    c.layer(band, R_GOLD, k=1)
    for gx in (22, 28, 34):
        c.layer(c.rect(gx - 1, 13, gx + 1, 14) & band, R_GEM if gx == 28 else R_FLOWER, k=0, rim=False, edge=False)
        c.px([(gx - 1, 13)], WHITE)
    c.px([(17, 5), (24, 2), (32, 2), (39, 5)], GOLD)                     # point pearls
    # sceptre flower: tall stem in the right paw, gold bow, big double bloom
    c.put(c.line([(49, 60), (50, 30), (50, 20)], 2), R_STEM[1])
    c.px([(50, y) for y in range(24, 58, 2)], R_STEM[0])
    c.layer(c.poly([(51, 47), (57, 42), (59, 44), (53, 49)]), R_STEM, k=1)
    c.layer(c.poly([(49, 38), (43, 35), (42, 37), (47, 40)]), R_STEM, k=1)
    bow = c.poly([(50, 30), (44, 26), (44, 33)]) | c.poly([(51, 30), (57, 26), (57, 33)]) | \
        c.poly([(50, 31), (46, 38), (48, 39), (50, 33)]) | c.poly([(51, 31), (55, 38), (53, 39), (51, 33)])
    c.layer(bow, R_GOLD, k=1)
    c.layer(c.rect(49, 29, 52, 32), R_GOLD, k=0)
    flower(c, 51, 12, 6.5, petals=6, rot=-math.pi / 2)
    flower(c, 51, 12, 3.2, ramp=R_FLOWER2, petals=6, rot=-math.pi / 2 + math.pi / 6, pr=2.4, cr=1.6)
    # paw gripping the sceptre
    grip = c.ell(46, 47, 4, 3)
    c.layer(grip, R_LION, k=1)
    c.px([(48, 45), (48, 47)], R_LION[3])
    # hearts and sparkles
    d = Canvas()
    heart(d, 3, 22, 'm')
    heart(d, 56, 52, 's')
    sparkle(d, 6, 7, big=True)
    sparkle(d, 60, 28)
    sparkle(d, 42, 4)
    dot_sparkle(d, 12, 32)
    dot_sparkle(d, 61, 40)
    return c.finish(d)


# ------------------------------------------------------------------ gift icon 24x24
R_BOX = (hx('#f07a5a'), hx('#c03c2c'), hx('#82222a'), hx('#4e1218'))
R_LID = (hx('#ff9a72'), hx('#d8503a'), hx('#962c2c'), hx('#4e1218'))


def gift():
    c = Canvas(24)
    box = c.rect(4, 11, 19, 21)
    c.layer(box, R_BOX, k=2)
    c.px([(7, 14), (16, 18), (7, 19), (16, 13)], CREAM)                   # polka dots
    lid = c.rect(3, 8, 20, 11)
    c.layer(lid, R_LID, k=1)
    rib = c.rect(10, 8, 13, 21)
    c.layer(rib, R_GOLD, k=1)
    c.px([(11, y) for y in range(9, 21, 2)], R_GOLD[0])                    # stitched highlight
    loops = c.ell(7, 5, 3.5, 2.5) | c.ell(16, 5, 3.5, 2.5)
    c.layer(loops, R_GOLD, k=1)
    c.px([(6, 5), (7, 5), (16, 5), (17, 5)], R_GOLD[3])                    # loop holes
    tails = c.poly([(10, 7), (7, 10), (9, 10), (11, 8)]) | c.poly([(13, 7), (16, 10), (14, 10), (12, 8)])
    knot = c.rect(10, 4, 13, 7)
    c.layer(knot | (tails & ~lid) , R_GOLD, k=1)
    c.layer(knot, R_GOLD, k=0)
    c.px([(11, 5)], WHITE)
    return c.finish()


def main(out):
    os.makedirs(out, exist_ok=True)
    for name, fn in (('small', small), ('medium', medium), ('large', large), ('boss', boss)):
        fn().save(os.path.join(out, f'end-charmed-{name}.png'))
    gift().save(os.path.join(out, 'ico-gift.png'))


if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else os.path.join(REPO, 'game', 'assets', 'img', 'pfight'))
