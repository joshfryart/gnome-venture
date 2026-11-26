#!/usr/bin/env python3
"""place_kit.py: shared kit for the 144 x 108 town place cards (game/assets/img/town/place-*.png), Stitched Toy redraw.

STAGING ONLY: writes art-review/stopart/out/town/place-<name>.png and art-review/stopart/out/_cmp/place-<name>.png. Never touches game/.

A card is a felt frame (6 px brown felt, gold dashed thread, 1 px umber edge, 2 x 2 cut corners like the shipped cards) around a
scene of flat felt pieces. Each piece ("part") gets a light rim upper-left and a dark crescent lower-right; parts are grouped into
objects, each object gets ONE 1 px umber outline where it meets what lies behind it, and inner umber-brown contours between its own
parts. Optional dashed thread stitch 2 px inside a part. No anti-aliasing, alpha only 0 (the 4 cut corners) or 255. Deterministic.
"""
import math
import os
import sys

from PIL import Image, ImageDraw

ROOT = '/home/user/gnome-venture'
sys.path.insert(0, os.path.join(ROOT, 'art-review/kit'))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pal_kit import rect, ell, poly, thick_path, erode, hexrgb, UMBER, UMBER2, CREAM  # noqa: E402,F401
from stops_kit import (rot_ell, AND, OR, NOT, walk, MOSS, LEAF, WOOD, WOOD_D, CANVAS, CLOTH, RED, GOLD, WATER,  # noqa: E402,F401
                       STONE, SOIL, DARK, PLASTER, STEAM, PURPLE, GLASS, FLAME, FLAME_IN, THREAD, THREAD_B, CONTOUR)

W, H = 144, 108
FW = 7          # frame: umber edge + 6 px felt; scene starts at FW + 1 (inner umber line at FW)
OUT = os.path.join(ROOT, 'art-review/stopart/out/town')
CMP = os.path.join(ROOT, 'art-review/stopart/out/_cmp')
SHIP = os.path.join(ROOT, 'game/assets/img/town')

SKY = ('#a9d6ea', '#7ab4d0', '#cfe8f2')
SKY2 = ('#cfe8f2', '#a9d6ea', '#e6f4f8')
CLOUD = ('#fff6dc', '#e6dcc0', '#ffffff')
HILL = ('#6a9a4a', '#4a7a36', '#8ab86a')
HILL2 = ('#86b468', '#6a9a4a', '#a4cc84')
GRASS = ('#7ab55c', '#5a8a42', '#9ad07a')
PATH = ('#d6b07a', '#b08a52', '#ecd0a0')
FRAME = ('#8a5a32', '#5a3a1e', '#b4824e')
WALLWOOD = ('#a06a3a', '#7a4a26', '#b4824e')
PLANK = ('#6a4426', '#4a2c1a', '#86583a')
CREAMWALL = ('#f2dcb0', '#dcc08c', '#fff0d0')
SNOW = ('#f4f0e4', '#c9c5bc', '#ffffff')
PAPER = ('#f4f0e4', '#c9c5bc', '#ffffff')
YELLOWP = ('#f5cf6a', '#d8a83a', '#fde68a')
BLUEP = ('#a9d6ea', '#7ab4d0', '#e0f2fa')
PINK = ('#f6b8cf', '#d888a8', '#fde0ea')
BLUE = ('#3f7fc8', '#245a8e', '#7aaee0')
GREEN = ('#3f9a4a', '#2f6a3a', '#7ab55c')
ALE = ('#f0b030', '#c08010', '#f8d060')
FOAM = ('#fff6dc', '#e6dcc0', '#ffffff')
TERRA = ('#c0603a', '#8e3a20', '#e08a5a')
TEAPOT = ('#c8382e', '#8e221c', '#ec6a4e')
SPICE_Y = ('#f0a020', '#c06a10', '#f8d060')
SPICE_R = ('#d8481e', '#a8301a', '#f08a4a')
HERB = ('#5aa04a', '#2f6a3a', '#9ad07a')
BURLAP = ('#cfae7a', '#9a7a4a', '#ecd6a4')
GREY = ('#9a96a0', '#66626e', '#c8c4cc')
DGREY = ('#7a7680', '#55515c', '#a09ca8')


def inner(x, y):
    return FW + 1 <= x < W - FW - 1 and FW + 1 <= y < H - FW - 1


NB4 = ((1, 0), (-1, 0), (0, 1), (0, -1))


class Card:
    def __init__(self):
        self.parts = []
        self.over = {}
        self.under = {}   # pixel -> (colour, number of parts when drawn): only lands on pixels whose owner was already there
        self.g = None
        self._n = 0

    def add(self, pred, rmp, stitch=None, shade=True, outline=True, contour=True, group=None):
        m = {(x, y) for y in range(H) for x in range(W) if inner(x, y) and pred(x + 0.5, y + 0.5)} if callable(pred) else set(pred)
        g = group or self.g
        if g is None:
            self._n += 1
            g = '_%d' % self._n
        self.parts.append(dict(mask=m, ramp=rmp, stitch=stitch, shade=shade, outline=outline, contour=contour, group=g))
        return m

    def bg(self, pred, rmp, stitch=None, shade=True):
        """Background felt: no outline of its own."""
        return self.add(pred, rmp, stitch=stitch, shade=shade, outline=False)

    def px(self, x, y, col):
        self.over[(x, y)] = col

    def line(self, pts, col):
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            steps = max(abs(bx - ax), abs(by - ay), 1)
            for i in range(steps + 1):
                self.px(round(ax + (bx - ax) * i / steps), round(ay + (by - ay) * i / steps), col)

    def uline(self, pts, col):
        """A line painted on the background drawn so far (later parts cover it)."""
        n = len(self.parts)
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            steps = max(abs(bx - ax), abs(by - ay), 1)
            for i in range(steps + 1):
                self.under[(round(ax + (bx - ax) * i / steps), round(ay + (by - ay) * i / steps))] = (col, n)

    def fill(self, x0, y0, x1, y1, col):
        for y in range(y0, y1):
            for x in range(x0, x1):
                self.px(x, y, col)

    def render(self):
        # z order: each outlined group's ring goes in just before the group's first part
        unions, first = {}, {}
        for i, p in enumerate(self.parts):
            unions.setdefault(p['group'], set()).update(p['mask'])
            first.setdefault(p['group'], i)
        entries = []
        for i, p in enumerate(self.parts):
            g = p['group']
            if first[g] == i and any(q['outline'] for q in self.parts if q['group'] == g):
                U = unions[g]
                ring = {(x + dx, y + dy) for (x, y) in U for dx, dy in NB4} - U
                ring = {q for q in ring if inner(*q)}
                entries.append(('ring', ring))
            entries.append(('part', i))
        own = {}
        for kind, v in entries:
            if kind == 'ring':
                for q in v:
                    own[q] = -1
            else:
                for q in self.parts[v]['mask']:
                    own[q] = v
        cols = {q: UMBER for q, i in own.items() if i == -1}
        vis = {}
        for q, i in own.items():
            if i >= 0:
                vis.setdefault(i, set()).add(q)
        for i, p in enumerate(self.parts):
            V = vis.get(i, set())
            K = set()
            if p['contour']:
                for (x, y) in V:
                    for dx, dy in NB4:
                        j = own.get((x + dx, y + dy))
                        if j is not None and 0 <= j < i and self.parts[j]['group'] == p['group']:
                            K.add((x, y))
                            break
            I = V - K
            base, dk, lt = p['ramp']
            for (x, y) in I:
                c = base
                if p['shade']:
                    if (x - 1, y) not in I or (x, y - 1) not in I:
                        c = lt
                    if (x + 1, y) not in I or (x, y + 1) not in I or (x + 1, y + 1) not in I:
                        c = dk
                cols[(x, y)] = c
            for q in K:
                cols[q] = CONTOUR
            if p['stitch']:
                e2 = erode(erode(p['mask']))
                e3 = erode(e2)
                ring = (e2 - e3) & I
                if len(e3) >= 6:
                    for k, q in enumerate(walk(ring)):
                        if q is not None and k % 4 < 2:
                            cols[q] = p['stitch']
        for q, (c, n) in self.under.items():
            if inner(*q) and 0 <= own.get(q, -1) < n:
                cols[q] = c
        for q, c in self.over.items():
            if inner(*q):
                cols[q] = c
        img = Image.new('RGBA', (W, H), hexrgb(SKY[0]) + (255,))
        for q, c in cols.items():
            img.putpixel(q, hexrgb(c) + (255,))
        frame(img)
        return img


def frame(img):
    base, dk, lt = FRAME
    for y in range(H):
        for x in range(W):
            d = min(x, y, W - 1 - x, H - 1 - y)
            if d > FW:
                continue
            if d == FW:
                c = UMBER
            elif d == 0:
                c = UMBER
            else:
                tl = min(x, y) == d                       # on the top or left side
                c = base
                if d == 1:
                    c = lt if tl else dk
                elif d == FW - 1:
                    c = dk if tl else lt
                elif d == 3:
                    t = x if (y == d or y == H - 1 - d) else y
                    if (t // 2) % 2 == 0:
                        c = THREAD
            img.putpixel((x, y), hexrgb(c) + (255,))
    for cx in (0, 1, W - 2, W - 1):
        for cy in (0, 1, H - 2, H - 1):
            img.putpixel((cx, cy), (0, 0, 0, 0))
    for (x, y) in ((2, 1), (1, 2), (W - 3, 1), (W - 2, 2), (2, H - 2), (1, H - 3), (W - 3, H - 2), (W - 2, H - 3)):
        img.putpixel((x, y), hexrgb(UMBER) + (255,))


# ---------------------------------------------------------------- common scenery
def sky_hills(c, horizon=78, hills=True, clouds=((30, 18, 13, 4),), far=None):
    c.bg(lambda x, y: True, SKY, shade=False)
    for (cx, cy, rx, ry) in clouds:
        c.add(OR(ell(cx, cy, rx, ry), ell(cx - rx * 0.45, cy + 1, rx * 0.55, ry * 0.9), ell(cx + rx * 0.4, cy - 1.5, rx * 0.5, ry)),
              CLOUD, group='cloud%d' % cx, outline=False)
    if hills:
        c.bg(lambda x, y: y > horizon - 16 + 5 * math.sin(x / 17.0 + 1.2), HILL2)
        c.bg(lambda x, y: y > horizon - 9 + 4 * math.sin(x / 13.0 + 4.0), HILL)
    c.bg(lambda x, y: y > horizon, GRASS)


def tufts(c, pts):
    for (x, y) in pts:
        c.px(x, y, GRASS[1])
        c.px(x - 1, y - 1, GRASS[1])
        c.px(x + 1, y - 2, GRASS[1])


def run(name, fn):
    c = Card()
    fn(c)
    img = c.render()
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(CMP, exist_ok=True)
    img.save(os.path.join(OUT, 'place-' + name + '.png'))
    old = Image.open(os.path.join(SHIP, 'place-' + name + '.png'))
    S = 3
    sheet = Image.new('RGB', (2 * W * S + 30, H * S + 20), '#d8d0bc')
    for k, im in enumerate((old.convert('RGBA'), img)):
        big = im.resize((W * S, H * S), Image.NEAREST)
        sheet.paste(big, (10 + k * (W * S + 10), 10), big)
    sheet.save(os.path.join(CMP, 'place-' + name + '.png'))
    al = {px[3] for px in img.getdata()}
    assert al <= {0, 255}, al
    assert img.size == old.size and img.mode == old.mode, (img.size, img.mode, old.size, old.mode)
    assert (0, 0, 0) not in {px[:3] for px in img.getdata() if px[3]}
    print(name, 'ok', len({px[:3] for px in img.getdata() if px[3]}), 'colours')
    return img
