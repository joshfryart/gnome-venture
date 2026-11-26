#!/usr/bin/env python3
"""draw_pilot.py: PILOT redraw of the 6 Spicepeak Puzzle Pals (art-review staging only; nothing under game/ is touched).

Ruling: a pal is ONE merged silhouette that reads as a puzzle piece AND as a thing (a crocus that is a corner piece, a yak that is an edge piece...).
Each pal is drawn procedurally in a 64-unit space and rasterised separately at 64 px (master) and 36 px (perch/small), so the 36 px file is a
re-rasterisation with its own small-size details (eyes, mouths, knob size), never a resize.

    python3 art-review/pilot/spicepeak/draw_pilot.py          # writes <key>.png, <key>-36.png, compare.png next to this file

Pillow only (no numpy). Deterministic: a re-run gives the same bytes.
House finish (DESIGN.md "Stitched Toy"): 1 px umber #2a1a10 outline (4-adjacent), light from the upper left (1 px rim), a lower-right crescent
shade, a dashed felt stitch on the main body at 64 px, hard 1-bit alpha, no pure black. Ramps are the picture's own (jigsaw_spicepeak.py).
"""
import math
import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, '..', '..', '..'))
PIC = os.path.join(ROOT, 'game', 'assets', 'img', 'jigsaw', 'spicepeak.jpg')
OLD = os.path.join(ROOT, 'game', 'assets', 'img', 'puzzles', 'pals')

UMBER, UMBER2, CREAM = '#2a1a10', '#4a2c1a', '#f2e4c0'

# ---------------------------------------------------------------- ramps (base, dark, light), from aseprite-source/scenes-pil/jigsaw_spicepeak.py
SAFF = ('#f0a020', '#c06a10', '#f8d060')
SAFFRED = ('#d8481e', '#a8301a', '#f08a4a')
MAG = ('#c8327a', '#8e1f58', '#ec74ac')
TEAL = ('#2a9a9a', '#1d7378', '#7fd0c8')
TEA = ('#3f9a4a', '#2f6a3a', '#7ab55c')
WALL = ('#b49a76', '#7a6248', '#d8c4a0')
WOOD = ('#b07a3a', '#7a4a1f', '#d9a35a')
WHITE = ('#f4f0e4', '#c9c5bc', '#ffffff')
GOLD = ('#e8a317', '#b07a10', '#f5cf6a')
CHILLI = ('#c8202a', '#8e1a20', '#e0483a')
YAK = ('#5a4634', '#3a3028', '#7a6248')
HORN = ('#e6e0d0', '#b8b0a0', '#f4f0e4')
LAV = ('#9a9cc0', '#7a7ca6', '#c9d2e4')
BURLAP = ('#cfae7a', '#9a7a4a', '#ecd6a4')
MOTH = ('#e0702a', '#a8301a', '#f08a4a')
FLAGS = ('#3f7fc8', '#f4f0e4', '#d6322b', '#3f9a4a', '#f0c030')
BLUSH = '#f6b8cf'


# ---------------------------------------------------------------- shape predicates (64-unit space, evaluated at pixel centres)
def rect(x0, y0, x1, y1):
    return lambda x, y: x0 <= x < x1 and y0 <= y < y1


def ell(cx, cy, rx, ry):
    return lambda x, y: ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 < 1


def poly(pts):
    def f(x, y):
        inside = False
        j = len(pts) - 1
        for i in range(len(pts)):
            xi, yi = pts[i]
            xj, yj = pts[j]
            if (yi > y) != (yj > y) and x < (xj - xi) * (y - yi) / (yj - yi) + xi:
                inside = not inside
            j = i
        return inside
    return f


def thick_path(pts, w):
    """A polyline of width w (distance to any segment < w / 2)."""
    def f(x, y):
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            dx, dy = bx - ax, by - ay
            t = max(0.0, min(1.0, ((x - ax) * dx + (y - ay) * dy) / (dx * dx + dy * dy)))
            if (x - ax - t * dx) ** 2 + (y - ay - t * dy) ** 2 < (w / 2) ** 2:
                return True
        return False
    return f


def _ks(style, u, v, r, nw, solid=False):
    """Knob in local coords: u along the side, v > 0 outward. Styles: round peg tri double hook (PPAL_KNOBS; keyhole unused here)."""
    c = r + 1.6
    if style == 'round':
        return (abs(u) < nw and -2.5 < v < r * 0.6 + 1) or u * u + (v - c) ** 2 < r * r
    if style == 'peg':
        return (abs(u) < nw and -2.5 < v < 2) or (abs(u) < r and 1.0 <= v < 1.0 + 1.8 * r)
    if style == 'tri':
        h = 2.2 * r
        return (abs(u) < nw and -2.5 < v < 2) or (1.0 <= v < 1.0 + h and abs(u) < (r + 1.6) * (1 - (v - 1.0) / h))
    if style == 'double':
        k = r * 0.56
        return (abs(u) < nw + 1.6 and -2.5 < v < c - 1) or (abs(u) - k) ** 2 + (v - c + 0.3) ** 2 < (k + 0.9) ** 2
    if style == 'hook':
        d2 = u * u + (v - c) ** 2
        if solid:   # a hook blank: a comma-shaped hole (disc + the hook's tip), never a ring that would leave an island
            return (abs(u) < nw and -2.5 < v < c) or d2 < r * r or (u - (r - 0.6)) ** 2 + (v - c + 2.2) ** 2 < 3.2
        ring = (r - 2.8) ** 2 < d2 < r * r and not (u > 0.3 and v < c + 0.3)
        tip = (u - (r - 1.4)) ** 2 + (v - c + 0.6) ** 2 < 2.4
        return (-nw < u < nw - 0.6 and -2.5 < v < c) or ring or tip
    raise ValueError(style)


def knob(kind, style, mx, my, nx, ny, r=4.5, nw=2.6, flip=False):
    """Tab (kind T, add it) or blank (kind B, cut it) on a side through (mx, my) with outward normal (nx, ny)."""
    ax, ay = -ny, nx

    def f(x, y):
        px, py = x - mx, y - my
        u, v = px * ax + py * ay, px * nx + py * ny
        if flip:
            u = -u
        if kind == 'B':
            return _ks(style, u, -v, r + 0.5, nw + 0.4, solid=True)
        return _ks(style, u, v, r, nw)
    return f


# ---------------------------------------------------------------- canvas
class C:
    def __init__(self, n):
        self.n, self.k = n, n / 64.0
        self.small = n < 48
        self.parts = []          # (mask, ramp, stitch colour or None)
        self.over = {}           # pixel -> colour, drawn after shading
        self.cut = set()         # pixels forced transparent (holes)

    def m(self, *preds, minus=()):
        n, k = self.n, self.k
        out = set()
        for y in range(n):
            for x in range(n):
                X, Y = (x + 0.5) / k, (y + 0.5) / k
                if any(p(X, Y) for p in preds) and not any(p(X, Y) for p in minus):
                    out.add((x, y))
        return out

    def add(self, mask, rmp, stitch=None):
        self.parts.append((set(mask), rmp, stitch))
        return mask

    def P(self, x, y):
        """64-unit point -> pixel."""
        return int(x * self.k), int(y * self.k)

    def px(self, x, y, col):
        self.over[(x, y)] = col

    def line(self, pts, col):
        """1 px line through 64-unit points (pixel-stepped)."""
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            a, b = self.P(ax, ay), self.P(bx, by)
            steps = max(abs(b[0] - a[0]), abs(b[1] - a[1]), 1)
            for i in range(steps + 1):
                self.px(round(a[0] + (b[0] - a[0]) * i / steps), round(a[1] + (b[1] - a[1]) * i / steps), col)

    def eye(self, x, y, disc=False, look=(0, 0)):
        """Locked felt eye centred on 64-unit (x, y). 64 px: 3 x 4 umber pupil + glint (+ cream disc). 36 px: 2 x 2 pupil + glint."""
        cx, cy = self.P(x, y)
        lx, ly = look
        if not self.small:
            if disc:
                for dx in range(-2, 3):
                    for dy in range(-3, 3):
                        if abs(dx) == 2 and dy in (-3, 2):
                            continue
                        self.px(cx + dx, cy + dy, CREAM)
            for dx in range(-1, 2):
                for dy in range(-2, 2):
                    self.px(cx + dx + lx, cy + dy + ly, UMBER)
            self.px(cx - 1 + lx, cy - 2 + ly, CREAM)
        else:
            if disc:
                for dx in range(-1, 3):
                    for dy in range(-1, 3):
                        if (dx in (-1, 2)) and (dy in (-1, 2)):
                            continue
                        self.px(cx + dx, cy + dy, CREAM)
            for dx in range(0, 2):
                for dy in range(0, 2):
                    self.px(cx + dx + (lx > 0), cy + dy + (ly > 0), UMBER)
            if not disc:
                self.px(cx, cy - 1, UMBER)
                self.px(cx + 1, cy - 1, UMBER)
            self.px(cx + (lx > 0), cy + (ly > 0) - (0 if disc else 1), CREAM)

    def smile(self, x, y, col=UMBER, wide=False):
        cx, cy = self.P(x, y)
        if not self.small:
            w = 3 if wide else 2
            for dx in range(-w + 1, w):
                self.px(cx + dx, cy + 1, col)
            self.px(cx - w, cy, col)
            self.px(cx + w, cy, col)
        else:
            self.px(cx - 1, cy, col)
            self.px(cx, cy + 1, col)
            self.px(cx + 1, cy + 1, col)
            self.px(cx + 2, cy, col)

    def blush(self, x, y):
        cx, cy = self.P(x, y)
        self.px(cx, cy, BLUSH)
        if not self.small:
            self.px(cx + 1, cy, BLUSH)

    # ------------------------------------------------------------ render
    def render(self):
        n = self.n
        own = {}
        for i, (mask, _, _) in enumerate(self.parts):
            for p in mask:
                own[p] = i
        for p in self.cut:
            own.pop(p, None)
        sil = set(own)
        img = Image.new('RGBA', (n, n), (0, 0, 0, 0))
        put = img.putpixel
        crescent = 1 if self.small else 2
        cols = {}
        for (x, y), i in own.items():
            _, rmp, _ = self.parts[i]
            c = rmp[0]
            if (x - 1, y) not in sil or (x, y - 1) not in sil:
                c = rmp[2]
            if any((x + d, y) not in sil or (x, y + d) not in sil or (x + d, y + d) not in sil for d in range(1, crescent + 1)):
                c = rmp[1]
            cols[(x, y)] = c
        # felt stitch: dashed thread 3 px inside the part's own edge (64 px only)
        if not self.small:
            for i, (mask, _, st) in enumerate(self.parts):
                if not st:
                    continue
                mine = {p for p in mask if own.get(p) == i}
                e1 = erode(mine)
                e2 = erode(e1)
                e3 = erode(e2)
                for (x, y) in e2 - e3:
                    if ((x + y) // 2) % 2 == 0:
                        cols[(x, y)] = st
        for p, c in self.over.items():
            if p in sil:
                cols[p] = c
        for (x, y), c in cols.items():
            put((x, y), hexrgb(c) + (255,))
        for y in range(n):
            for x in range(n):
                if (x, y) in sil:
                    continue
                if any((x + dx, y + dy) in sil for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    put((x, y), hexrgb(UMBER) + (255,))
        return img


def erode(m):
    return {(x, y) for (x, y) in m if all((x + dx, y + dy) in m for dx in (-1, 0, 1) for dy in (-1, 0, 1))}


def hexrgb(c):
    return tuple(int(c[i:i + 2], 16) for i in (1, 3, 5))


# ================================================================ the six pals
PURP = ('#8a5aa8', '#5e3a7a', '#9a7ac8')
SKY = ('#86c9c9', '#5f9c86', '#c8ecdf')
FUR = ('#7a6248', '#5a4634', '#9a7a4a')


def brow(c, x, y):
    """Small arched brow (the painted stupa eyes)."""
    cx, cy = c.P(x, y)
    pts = ((-2, 1), (-1, 0), (0, 0), (1, 0), (2, 1)) if not c.small else ((-1, 0), (0, 0), (1, 0))
    for dx, dy in pts:
        c.px(cx + dx, cy + dy, UMBER2)


def saffron_snip(c):
    """Corner-BB, round: a saffron crocus. Flat W + S (the terrace step it grows from), round blanks N (the open cup) and E.
    Two pointed outer petals rise at the top corners; the N blank is the open cup with the red saffron threads standing in it."""
    K = 1.15 if c.small else 1.0
    petalL = lambda x, y: x >= 10 and y < 31 and ((x - 19) / 9.5) ** 2 + ((y - 24) / 20) ** 2 < 1 and x + 0.9 * y > 17.5
    petalR = lambda x, y: x < 53 and y < 31 and ((x - 44) / 9.5) ** 2 + ((y - 24) / 20) ** 2 < 1 and (53 - x) + 0.9 * y > 17.5
    cup = lambda x, y: petalL(x, y) or petalR(x, y) or (19 <= x < 44 and 13 <= y < 31)
    blankN = knob('B', 'round', 31.5, 13, 0, -1, r=5.2 * K)
    blankE = knob('B', 'round', 53, 44, 1, 0, r=4.6 * K)
    body = c.m(cup, rect(10, 30, 53, 57), minus=(blankN, blankE))
    sepal = c.m(lambda x, y: y >= 32 - (4 if abs(x - 31.5) % 10 < 5 else 0) * (1 - abs(((x - 31.5) % 10) - 2.5) / 2.5))
    c.add(body & sepal, TEA, stitch='#a4c46a')
    c.add(body - sepal, PURP)
    # petal splits running down from the notch shoulders
    c.line([(22.5, 14), (20.5, 26)], PURP[1])
    c.line([(40.5, 14), (42.5, 26)], PURP[1])
    c.line([(14, 10), (13, 20)], PURP[2])
    c.line([(49, 10), (50, 20)], PURP[2])
    # saffron threads standing in the cup
    if not c.small:
        c.add(c.m(thick_path([(31.5, 27), (28.4, 21.6)], 1.7), thick_path([(31.5, 27), (31.5, 20.6)], 1.7),
                  thick_path([(31.5, 27), (34.6, 21.6)], 1.7)), SAFFRED)
    else:
        c.add(c.m(thick_path([(29, 22), (31.5, 25), (34, 22)], 1.9)), SAFFRED)
    # terrace step along the flat bottom (cell 2-6: beige stone walls)
    c.add(body & c.m(rect(0, 51.5, 64, 64)), WALL)
    if not c.small:
        y = c.P(0, 54)[1]
        for x in range(c.P(10, 0)[0], c.P(53, 0)[0]):
            if x % 6 == 0:
                c.px(x, y, WALL[1])
                c.px(x, y + 1, WALL[1])
    # a teal leaf blade (the picker's hat) up the flat side
    c.add(body & c.m(poly([(11, 51), (13.5, 35), (17, 51)])), TEAL)
    c.eye(24, 40)
    c.eye(36, 40)
    c.smile(30, 45)
    c.blush(20, 44)
    c.blush(39.5, 44)


def yak_yonder(c):
    """Edge-TTB, double: a laden yak, face on. Flat S (hooves on the bridge), double tabs N (two bundles on its back) and E (a saddlebag),
    double blank W. Horns break out at the top corners. Bundles and blanket in the tiger-moth orange with its cream zigzag (cell 5-5)."""
    K = 1.15 if c.small else 1.0
    core = rect(12, 23, 50, 58)
    tabN = knob('T', 'double', 31, 23, 0, -1, r=5.6 * K)
    tabE = knob('T', 'double', 50, 41, 1, 0, r=4.8 * K)
    blankW = knob('B', 'double', 12, 42, -1, 0, r=4.6 * K)
    body = c.m(core, minus=(blankW,))
    c.add(body, YAK, stitch=None)
    hw = 3.6 if not c.small else 4.2
    c.add(c.m(thick_path([(18, 28), (12.5, 25), (10, 19), (11, 15)], hw)), HORN)
    c.add(c.m(thick_path([(44, 28), (49.5, 25), (52, 19), (51, 15)], hw)), HORN)
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 21, 64, 24))), MOTH)
    c.add(c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(rect(48, 0, 51, 64))), MOTH)
    # rope on the bundles + cream zigzag on the saddlebag (the moth's wing pattern)
    if not c.small:
        x0 = c.P(31, 0)[0]
        for y in range(c.P(0, 9)[1], c.P(0, 23)[1]):
            c.px(x0, y, '#f5e6c0')
        for y in range(c.P(0, 35)[1], c.P(0, 48)[1]):
            c.px(c.P(56, 0)[0] + (y % 2), y, '#f5e6c0')
    else:
        x0 = c.P(31, 0)[0]
        for y in range(c.P(0, 9)[1], c.P(0, 23)[1]):
            c.px(x0, y, '#f5e6c0')
        for y in range(c.P(0, 37)[1], c.P(0, 46)[1]):
            c.px(c.P(56, 0)[0], y, '#f5e6c0')
    # shaggy fur: long strands hanging down the sides
    if not c.small:
        for (x, y) in body:
            if (x * 5 + (y // 3) * 3) % 7 == 0 and y > 33 and (x < 18 or x > 43):
                c.px(x, y, YAK[2])
    fr = c.m(lambda x, y: 24 <= y < 32 + (2.5 if (x // 4) % 2 else 0) and 15 <= x < 47)
    c.add(fr & body, FUR)
    # muzzle
    c.add(c.m(ell(31, 47, 9.5, 5.5)), WALL)
    c.px(*c.P(27.5, 46), UMBER2)
    c.px(*c.P(34.5, 46), UMBER2)
    c.smile(31, 49, UMBER2)
    # blanket band at the chest, moth orange with the cream zigzag
    c.add(body & c.m(rect(0, 53.5, 64, 58)), MOTH)
    if not c.small:
        y = c.P(0, 55)[1]
        for x in range(c.P(12, 0)[0], c.P(50, 0)[0]):
            c.px(x, y + (x % 2), '#f5e6c0')
    for gx in (21, 31, 41):
        x, _ = c.P(gx, 0)
        for y in range(c.P(0, 54)[1], c.n):
            if (x, y) in body:
                c.px(x, y, YAK[1])
    c.eye(24.5, 37, disc=True)
    c.eye(37.5, 37, disc=True)


def chilli_chime(c):
    """Inner-TBTB, peg: a chilli off the souk garland. Peg tab N (its green stalk), peg tab S (a brass chime bell hanging off its tip),
    square peg blanks E + W pinch its shoulders. Long, tapered, tip curling right. Souk reds and golds (cell 9-6)."""
    K = 1.15 if c.small else 1.0
    pod = poly([(18, 22), (46, 22), (46, 34), (45, 44), (43, 51), (41.5, 56.5), (33, 56.5), (26, 50), (21, 43), (18, 34)])
    shoulders = (ell(23.5, 22.5, 5.5, 6), ell(40.5, 22.5, 5.5, 6), rect(23.5, 16.5, 40.5, 24))
    blankE = knob('B', 'peg', 46, 28.5, 1, 0, r=3.3 * K)
    blankW = knob('B', 'peg', 18, 28.5, -1, 0, r=3.3 * K)
    tabN = knob('T', 'peg', 32, 16.5, 0, -1, r=3.9 * K)
    tabS = knob('T', 'peg', 37.2, 56.5, 0, 1, r=3.5 * K)
    body = c.m(pod, *shoulders, minus=(blankE, blankW))
    c.add(body, CHILLI, stitch='#e0483a')
    cap = body & c.m(lambda x, y: y < 20.5 + (2 if 25 <= x < 39 and ((x - 25) // 4) % 2 == 0 else 0))
    c.add(c.m(tabN) | cap, TEA)
    bell = c.m(tabS, minus=(lambda x, y: y < 57.5,))
    c.add(bell, GOLD)
    by = max(y for (x, y) in bell)
    xs = sorted(x for (x, y) in bell if y == by)
    if not c.small:
        for x in range(xs[0], xs[-1] + 1):
            c.px(x, by - 1, GOLD[1])
    c.px((xs[0] + xs[-1]) // 2, by - (3 if not c.small else 1), UMBER2)
    # gloss: a long curved streak down the left of the pod
    c.line([(21.5, 24), (21.5, 34)], CHILLI[2])
    c.line([(23, 40), (27, 46), (31, 50)], CHILLI[2])
    c.eye(28, 37)
    c.eye(37.5, 37)
    c.smile(33, 42.5)
    c.blush(25, 41.5)
    c.blush(41, 41.5)


def stupa_snug(c):
    """Inner-TTTT (Plus), double: a little white stupa. Double tabs: N the gold finial (with its spire), E + W lavender mitts, S two lavender feet.
    Painted stupa eyes with arched lids and the curl nose, the gold zigzag band and a string of prayer flags over the dome (cell 8-2)."""
    K = 1.15 if c.small else 1.0
    dome = ell(32, 38, 16.5, 19)
    base = rect(15.5, 38, 48.5, 50)
    tabN = knob('T', 'double', 32, 19.6, 0, -1, r=5.0 * K)
    tabE = knob('T', 'double', 48.5, 41, 1, 0, r=4.8 * K)
    tabW = knob('T', 'double', 15.5, 41, -1, 0, r=4.8 * K)
    tabS = knob('T', 'double', 32, 50, 0, 1, r=5.0 * K)
    body = c.m(dome, base)
    c.add(body, WHITE, stitch='#d8d0bc')
    c.add(c.m(tabN, rect(31, 3, 33, 10), minus=(dome,)), GOLD)
    c.add(c.m(tabE, tabW, minus=(base,)), LAV)
    c.add(c.m(tabS, minus=(base,)), LAV)
    c.add(body & c.m(rect(0, 46, 64, 64)), LAV)
    y0 = c.P(0, 41.5)[1]
    for x in range(c.P(16, 0)[0], c.P(48.5, 0)[0]):
        z = (x // (1 if c.small else 2)) % 2
        c.px(x, y0 + z, GOLD[0])
    pts = [(17, 33), (24, 26.5), (32, 25), (40, 26.5), (47, 33)]
    if not c.small:
        c.line(pts, UMBER2)
    for i, (fx, fy) in enumerate([(20.5, 29.5), (26.5, 26), (32, 25.3), (37.5, 26), (43.5, 29.5)]):
        x, y = c.P(fx, fy)
        col = FLAGS[i] if FLAGS[i] != '#f4f0e4' else '#c3cad8'
        for dx in range(0, 2 if c.small else 3):
            for dy in range(1, 3 if c.small else 4):
                c.px(x + dx - (0 if c.small else 1), y + dy, col)
    c.eye(26, 36)
    c.eye(38, 36)
    brow(c, 26, 32.5)
    brow(c, 38, 32.5)
    nx, ny = c.P(32, 37)
    c.px(nx, ny, CHILLI[0])
    c.px(nx, ny + 1, CHILLI[0])
    if not c.small:
        c.px(nx + 1, ny + 2, CHILLI[0])
    c.blush(21.5, 39)
    c.blush(41.5, 39)
    for wx in (21, 27, 37, 43):
        x, y = c.P(wx, 47.5)
        c.px(x, y, UMBER2)
        if not c.small:
            c.px(x + 1, y, UMBER2)
            c.px(x, y + 1, UMBER2)
            c.px(x + 1, y + 1, UMBER2)


def teal_ferry(c):
    """Inner-TTBB, hook: the flower ferry. Hook tabs N (the ferryman's brass boat hook) and E (a curled wooden prow),
    hook blanks W (cut into the cabin) and S (cut into the river). Arched teal canopy on two posts, a curved wooden hull wearing
    the face, pink garland flowers on the rail, floating on its own band of teal river (cell 6-6)."""
    K = 1.12 if c.small else 1.0
    core = rect(11, 17, 49, 55)
    tabN = knob('T', 'hook', 23, 17, 0, -1, r=5.0 * K)
    tabE = knob('T', 'hook', 49, 36, 1, 0, r=5.0 * K, flip=True)
    blankS = knob('B', 'hook', 31, 55, 0, 1, r=3.6 * K)
    blankW = knob('B', 'hook', 11, 27, -1, 0, r=3.5 * K)
    body = c.m(core, minus=(blankS, blankW))
    c.add(body, TEAL)                                     # the river
    c.add(body & c.m(rect(0, 17, 64, 33)), BURLAP)        # cabin
    c.add(body & c.m(lambda x, y: y < 22.5 + 2.2 * (1 - ((x - 30) / 19) ** 2)), TEAL)   # arched canopy
    c.add(body & c.m(rect(12, 22, 15.5, 33), rect(44.5, 22, 48, 33)), WOOD)
    hull = body & c.m(lambda x, y: 32.5 <= y < 46.5 - 5 * ((x - 30) / 19) ** 2)
    c.add(hull, WOOD, stitch='#d9a35a')
    c.add(c.m(tabN, minus=(core,)), GOLD)
    c.add(c.m(tabE, minus=(core,)), WOOD)
    c.line([(11, 32.5), (49, 32.5)], WOOD[1])
    if not c.small:
        c.line([(13, 19), (46, 19)], TEAL[2])
    for i, fx in enumerate((19, 25, 31, 37, 42)):
        x, y = c.P(fx, 29.5)
        col = MAG[2] if i % 2 else MAG[0]
        c.px(x, y, col)
        if not c.small:
            for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(x + d[0], y + d[1], col)
            c.px(x, y, SAFF[2])
    for wy in ((49, 52.5) if not c.small else (50,)):
        y = c.P(0, wy)[1]
        for x in range(c.P(11, 0)[0], c.P(49, 0)[0]):
            if (x + (3 if wy > 50 else 0)) % (6 if not c.small else 4) in (0, 1) and (x, y) in body and (x, y) not in hull:
                c.px(x, y, TEAL[2])
    c.eye(24.5, 36.5)
    c.eye(35.5, 36.5)
    c.smile(30, 39.5)
    c.blush(20.5, 39.5)
    c.blush(39.5, 39.5)

def lofty_kite(c):
    """Whimsy-kite, tri: a diamond kite. Tri tabs on its NW and SE edges, tri blanks on NE and SW, a ribbon tail with two bow ties.
    Saffron-and-orange top (the kite over the ridge), sky-teal bottom (the cell is mostly sky), pink and teal bows. Its eyes look down."""
    K = 1.15 if c.small else 1.0
    T, L, R, B = (32, 2.5), (11, 25), (53, 25), (32, 48)
    dia = poly([T, R, B, L])

    def nrm(a, b):
        dx, dy = b[0] - a[0], b[1] - a[1]
        ln = math.hypot(dx, dy)
        return dy / ln, -dx / ln

    kn = []
    for (a, b, kind) in ((L, T, 'T'), (T, R, 'B'), (R, B, 'T'), (B, L, 'B')):
        mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
        nx, ny = nrm(a, b)
        kn.append(knob(kind, 'tri', mx, my, nx, ny, r=3.4 * K, nw=2.2))
    whole = c.m(dia, kn[0], kn[2], minus=(kn[1], kn[3]))
    cross = 27
    top, left = c.m(lambda x, y: y < cross), c.m(lambda x, y: x < 32)
    c.add(whole & top - left, SAFFRED)
    c.add(whole & top & left, ('#f0c030', '#c08010', '#f8d870'))
    c.add((whole - top) & left, SKY)
    c.add((whole - top) - left, TEAL)
    path = [(32, 48), (34.5, 52), (31, 56), (33.5, 60), (31.5, 64)]
    c.add(c.m(thick_path(path, 1.5 if not c.small else 1.9)), WALL)
    c.add(c.m(poly([(26.5, 51), (32.5, 54), (26.5, 57)]), poly([(38.5, 51), (32.5, 54), (38.5, 57)])), MAG)
    if not c.small:
        c.add(c.m(poly([(27, 57.5), (32.5, 60.5), (27, 63.5)]), poly([(38, 57.5), (32.5, 60.5), (38, 63.5)])), MAG[2:] + MAG[1:2] + MAG[2:])
    c.line([(32, 4), (32, 14)], WOOD[1])
    c.line([(32, 28), (32, 46)], WOOD[1])
    c.line([(12, cross - 0.5), (52, cross - 0.5)], WOOD[1])
    c.eye(27, 19, look=(0, 1))
    c.eye(37, 19, look=(0, 1))
    c.smile(32, 22.5)
    c.blush(23, 23)
    c.blush(40, 23)


PALS = [
    ('sp-saffron-snip', 'Saffron Snip', '2-6', saffron_snip),
    ('sp-yak-yonder', 'Yak Yonder', '5-5', yak_yonder),
    ('sp-chilli-chime', 'Chilli Chime', '9-6', chilli_chime),
    ('sp-stupa-snug', 'Stupa Snug', '8-2', stupa_snug),
    ('sp-teal-ferry', 'Teal Ferry', '6-6', teal_ferry),
    ('sp-lofty-kite', 'Lofty Kite', '4-0', lofty_kite),
]


def draw(fn, n):
    c = C(n)
    fn(c)
    return c.render()


# ---------------------------------------------------------------- checks + compare sheet
def check(img):
    px = [img.getpixel((x, y)) for y in range(img.height) for x in range(img.width)]
    alphas = {p[3] for p in px}
    cols = {p[:3] for p in px if p[3] == 255}
    black = any(p[:3] == (0, 0, 0) and p[3] == 255 for p in px)
    sil = tuple(p[3] == 255 for p in px)
    return {'size': img.size, 'alpha_ok': alphas <= {0, 255}, 'colours': len(cols), 'black': black, 'sil': sil}


def compare(out, rows):
    pic = Image.open(PIC).convert('RGB')
    font = ImageFont.load_default(18)
    small = ImageFont.load_default(13)
    S = 4
    cw = 64 * S
    rh = cw + 40
    W = 24 + 2 * (cw * 2 + 36 * S + 3 * 16 + 16) + cw + 24
    H = 50 + rh * len(rows) + 10
    sheet = Image.new('RGB', (W, H), '#d8d0bc')
    d = ImageDraw.Draw(sheet)
    d.text((24, 14), 'Spicepeak pilot: OLD sticker | NEW 64 | NEW 36 (x4 nearest), light and dark, + source cell', fill=UMBER, font=font)
    for r, (key, name, cell, old, n64, n36) in enumerate(rows):
        y = 50 + r * rh
        x = 24
        for bg in ('#f1ece0', '#2a1a10'):
            bw = cw * 2 + 36 * S + 4 * 16
            d.rectangle((x, y, x + bw - 1, y + cw + 32), fill=bg)
            tc = UMBER if bg == '#f1ece0' else '#f1ece0'
            d.text((x + 8, y + 4), '%s  "%s"' % (key, name), fill=tc, font=small)
            xx = x + 16
            for im in (old, n64, n36):
                big = im.resize((im.width * S, im.height * S), Image.NEAREST)
                sheet.paste(big, (xx, y + 26), big)
                xx += big.width + 16
            x += bw + 16
        a, b = map(int, cell.split('-'))
        crop = pic.crop((a * 150, b * 150, a * 150 + 150, b * 150 + 150)).resize((cw, cw), Image.NEAREST)
        sheet.paste(crop, (x, y + 26))
        d.text((x, y + 4), 'cell %s' % cell, fill=UMBER, font=small)
    sheet.save(os.path.join(out, 'compare.png'))


def main():
    out = HERE
    rows, sils, report = [], {}, []
    for key, name, cell, fn in PALS:
        i64, i36 = draw(fn, 64), draw(fn, 36)
        i64.save(os.path.join(out, key + '.png'))
        i36.save(os.path.join(out, key + '-36.png'))
        for tag, im in (('64', i64), ('36', i36)):
            ck = check(im)
            report.append('%-18s %s size=%s alpha01=%s colours=%d black=%s' % (key, tag, ck['size'], ck['alpha_ok'], ck['colours'], ck['black']))
            sils.setdefault(tag, {})[key] = ck['sil']
        rows.append((key, name, cell, Image.open(os.path.join(OLD, key + '.png')).convert('RGBA'), i64, i36))
    for tag, d in sils.items():
        vals = list(d.values())
        report.append('silhouettes %s unique: %s' % (tag, len(set(vals)) == len(vals)))
        keys = list(d)
        worst = max((sum(p and q for p, q in zip(d[a], d[b])) / sum(p or q for p, q in zip(d[a], d[b])), a, b)
                    for i, a in enumerate(keys) for b in keys[i + 1:])
        report.append('silhouettes %s most alike: IoU %.2f (%s vs %s)' % ((tag,) + worst))
    compare(out, rows)
    print('\n'.join(report))


if __name__ == '__main__':
    main()
