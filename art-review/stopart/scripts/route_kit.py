#!/usr/bin/env python3
"""route_kit.py: shared kit for the 144 x 108 route destination cards (game/assets/img/town/route-<kind>.png), Stitched Toy redraw.

STAGING ONLY: writes art-review/stopart/out/town/route-<kind>.png and art-review/stopart/out/_cmp/route-<kind>.png. Never touches game/.

A card is a felt appliqué: flat felt pieces laid in order (sky, hills, ground, subject). Each piece gets its own finish:
a light rim on its upper-left edge, a darker crescent on its lower-right edge, a 1 px umber outline round it and a dashed
thread stitch 2 px inside it when it is big enough. The frame is a thin felt band (1 px umber, 4 px felt with a gold dashed
stitch, 1 px umber) so the picture still reads when scaled up in a popover: the subject sits in the middle with a margin and
nothing relies on the frame. Flat colours, no anti-aliasing, hard alpha (only the 4 stepped corner pixels are transparent).
No baked-in people or animals (DESIGN.md "Here, door and treehouse pictures"). Pillow only, deterministic.
"""
import math
import os
import sys

from PIL import Image

ROOT = '/home/user/gnome-venture'
sys.path.insert(0, os.path.join(ROOT, 'art-review/kit'))
from pal_kit import rect, ell, poly, thick_path, erode, hexrgb, UMBER, UMBER2, CREAM  # noqa: E402,F401

W, H = 144, 108
B = 6                                   # frame thickness: inner picture is x, y in [B, W - B) x [B, H - B)
IX0, IY0, IX1, IY1 = B, B, W - B, H - B
OUT = os.path.join(ROOT, 'art-review/stopart/out/town')
CMP = os.path.join(ROOT, 'art-review/stopart/out/_cmp')
SHIP = os.path.join(ROOT, 'game/assets/img/town')

# ramps (base, dark, light)
SKY = ('#a9d6ea', '#8cc0dc', '#cfe9f4')
SKY2 = ('#c4e2ee', '#a9d6ea', '#dff1f7')
DUSK = ('#eaa87a', '#d48a5e', '#f4c49a')
DUSK2 = ('#f4cc96', '#e8b07a', '#fbe0b4')
SUN = ('#f5c030', '#d8961a', '#fde68a')
CLOUD = ('#f4f0e4', '#d8d0bc', '#ffffff')
HILL = ('#4f8a3a', '#3a6a2a', '#6fa84e')
HILL2 = ('#6a9a52', '#4f7a3e', '#8ab86a')
GRASS = ('#7ab55c', '#5a9442', '#a2d07a')
MOSS = ('#7a9a62', '#58784a', '#9ab884')
LEAF = ('#4f9a3e', '#2f6a2a', '#7ec45e')
WOOD = ('#b07a3a', '#7a4a1f', '#d9a35a')
WOOD_D = ('#7a4a26', '#4a2c1a', '#a06a3a')
DARK = ('#4a2c1a', '#3d2418', '#5e3a24')
HOLE = ('#3d2418', '#2a1a10', '#4a2c1a')
CANVAS = ('#dcb47a', '#a8804a', '#f2d6a4')
CLOTH = ('#f2e4c0', '#c9a96e', '#fff6dc')
RED = ('#c8382e', '#8e221c', '#ec6a4e')
TENT = ('#c8462e', '#94301e', '#e8704a')
GOLD = ('#e8a317', '#b07a10', '#f5cf6a')
STONE = ('#7a7088', '#5a5268', '#9a92a8')
STONE2 = ('#8e8698', '#6a6278', '#b0a8ba')
PLASTER = ('#ecd2a0', '#c8a46a', '#fbe8c4')
WALL_W = ('#f2e4c0', '#d0b888', '#fff6dc')
ROOF_R = ('#9a3a24', '#6e2616', '#c45a3a')
ROOF_B = ('#3f6aa8', '#2a4a7e', '#6a94c8')
CRYS_B = ('#8cc8e8', '#5a96c0', '#d4eefa')
CRYS_P = ('#b8a0e8', '#8a70c4', '#e0d4fa')
FLAME = ('#e8602a', '#b03a1a', '#f59a4a')
FLAME_IN = ('#f5c030', '#e89a17', '#fde68a')
BONE = ('#f2ead6', '#c8bca0', '#ffffff')
PATH = ('#d4b07a', '#b08a52', '#ecd0a0')
FRUIT_R = ('#d8402e', '#a02a1e', '#f07a5a')
FRUIT_O = ('#f0a020', '#c07010', '#f8d060')
FRUIT_G = ('#6aa83e', '#4a7a2a', '#9ad06a')
FELT = ('#6a4630', '#4a2c1a', '#8a6040')   # frame band (a lighter umber felt, per RULINGS 3)
THREAD = '#e8a317'
THREAD_B = '#7a4a1f'
THREAD_C = '#f2e4c0'


def inside(x, y):
    return IX0 <= x < IX1 and IY0 <= y < IY1


def tri(ax, ay, bx, by, cx, cy):
    return poly([(ax, ay), (bx, by), (cx, cy)])


def circ(cx, cy, r):
    return ell(cx, cy, r, r)


class Card:
    def __init__(self, kind):
        self.kind = kind
        self.px = {}        # (x, y) -> hex, inner picture only

    def mask(self, *preds, minus=()):
        out = set()
        for y in range(IY0, IY1):
            for x in range(IX0, IX1):
                X, Y = x + 0.5, y + 0.5
                if any(p(X, Y) for p in preds) and not any(p(X, Y) for p in minus):
                    out.add((x, y))
        return out

    def piece(self, mask, rmp, stitch=None, outline=True, flat=False, crescent=1, rim=True, dash=2, depth=2, bleed=True):
        """Lay one felt piece. bleed: the picture edge counts as 'inside', so pieces running off the card get no rim there."""
        mask = set(mask)
        if not mask:
            return mask

        def m(x, y):
            return (x, y) in mask or (bleed and not inside(x, y))

        for (x, y) in mask:
            c = rmp[0]
            if not flat:
                if rim and (not m(x - 1, y) or not m(x, y - 1)):
                    c = rmp[2]
                if any(not m(x + d, y) or not m(x, y + d) or not m(x + d, y + d) for d in range(1, crescent + 1)):
                    c = rmp[1]
            self.px[(x, y)] = c
        if stitch:
            ins = {p for p in mask}
            # erode with the picture edge counted as inside, so a stitch runs along the visible edges only
            e = ins
            rings = []
            for _ in range(depth + 1):
                e2 = {(x, y) for (x, y) in e if all(((x + dx, y + dy) in e) or not inside(x + dx, y + dy)
                                                    for dx in (-1, 0, 1) for dy in (-1, 0, 1))}
                rings.append(e - e2)
                e = e2
            ring = rings[depth]
            for (x, y) in ring:
                if ((x + y) // dash) % 2 == 0:
                    self.px[(x, y)] = stitch
        if outline:
            for (x, y) in mask:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    q = (x + dx, y + dy)
                    if q not in mask and inside(*q):
                        self.px[q] = UMBER
        return mask

    def dot(self, x, y, col):
        if inside(x, y):
            self.px[(x, y)] = col

    def dots(self, pts, col):
        for x, y in pts:
            self.dot(x, y, col)

    def hline(self, x0, x1, y, col):
        for x in range(x0, x1 + 1):
            self.dot(x, y, col)

    def vline(self, x, y0, y1, col):
        for y in range(y0, y1 + 1):
            self.dot(x, y, col)

    def stitch_line(self, pts, col, dash=2):
        """Dashed 1 px thread along a polyline (pixel coords)."""
        k = 0
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            steps = max(abs(bx - ax), abs(by - ay), 1)
            for i in range(steps):
                if (k // dash) % 2 == 0:
                    self.dot(round(ax + (bx - ax) * i / steps), round(ay + (by - ay) * i / steps), col)
                k += 1

    def tuft(self, x, y, col='#5a9442'):
        self.dots([(x, y), (x, y - 1), (x - 1, y - 2), (x + 2, y), (x + 2, y - 1), (x + 3, y - 2)], col)

    def sparkle(self, x, y, col=GOLD[2], core='#ffffff'):
        for d in (-2, -1, 1, 2):
            self.dot(x + d, y, col)
            self.dot(x, y + d, col)
        self.dot(x, y, core)

    # ------------------------------------------------------------ common backdrops
    def sky(self, top, bottom=None, split=None):
        self.piece(self.mask(rect(0, 0, W, H)), top, flat=True, outline=False)
        if bottom:
            self.piece(self.mask(rect(0, split, W, H)), bottom, flat=True, outline=False)

    def sun(self, cx, cy, r):
        self.piece(self.mask(circ(cx, cy, r)), SUN, crescent=1)

    def cloud(self, x, y, w):
        h = max(6, w // 3)
        self.piece(self.mask(ell(x + w * .32, y + h * .45, w * .26, h * .55), ell(x + w * .62, y + h * .35, w * .3, h * .7),
                             rect(x + 2, y + h * .5, x + w - 2, y + h)), CLOUD)

    def ground(self, y, back=None, back_y=None, stitch=THREAD_B):
        if back:
            self.piece(self.mask(lambda X, Y: Y > back_y + 6 * math.sin(X / 23.0) + 3 * math.sin(X / 9.0 + 1)), back, crescent=1)
        self.piece(self.mask(lambda X, Y: Y > y + 2 * math.sin(X / 17.0 + 2)), GRASS, stitch=stitch, crescent=1)

    # ------------------------------------------------------------ finish
    def render(self):
        img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
        put = img.putpixel
        for (x, y), c in self.px.items():
            put((x, y), hexrgb(c) + (255,))
        # frame: umber edge, felt band with rim / shade, gold dashed stitch, umber inner edge
        for y in range(H):
            for x in range(W):
                if inside(x, y):
                    continue
                d = min(x, y, W - 1 - x, H - 1 - y)
                if d == 0 or d == B - 1:
                    c = UMBER
                else:
                    c = FELT[0]
                    if d == 1 and (x == 1 or y == 1) and x < W - 2 and y < H - 2:
                        c = FELT[2]
                    if d == 1 and (x == W - 2 or y == H - 2):
                        c = FELT[1]
                    if d == 3 and ((x + y) // 3) % 2 == 0:
                        c = THREAD
                put((x, y), hexrgb(c) + (255,))
        # stepped corners
        for cx, cy, sx, sy in ((0, 0, 1, 1), (W - 1, 0, -1, 1), (0, H - 1, 1, -1), (W - 1, H - 1, -1, -1)):
            put((cx, cy), (0, 0, 0, 0))
            put((cx + sx, cy + sy), hexrgb(UMBER) + (255,))
        return img


def finish(card):
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(CMP, exist_ok=True)
    img = card.render()
    name = 'route-%s.png' % card.kind
    img.save(os.path.join(OUT, name))
    old = Image.open(os.path.join(SHIP, name)).convert('RGBA')
    S = 4
    sheet = Image.new('RGBA', (W * S * 2 + 48, H * S * 2 + 64), (241, 236, 224, 255))
    sheet.alpha_composite(old.resize((W * S, H * S), Image.NEAREST), (16, 16))
    sheet.alpha_composite(img.resize((W * S, H * S), Image.NEAREST), (W * S + 32, 16))
    dark = Image.new('RGBA', (W * S * 2 + 48, H * S + 32), (42, 26, 16, 255))
    sheet.alpha_composite(dark, (0, H * S + 32))
    sheet.alpha_composite(img, (16, H * S + 48))
    sheet.alpha_composite(img.resize((W * 2, H * 2), Image.NEAREST), (W + 32, H * S + 48))
    sheet.alpha_composite(img.resize((W * 3, H * 3), Image.NEAREST), (W * 3 + 48, H * S + 48))
    sheet.convert('RGB').save(os.path.join(CMP, 'route-%s.png' % card.kind))
    px = list(img.getdata()) if not hasattr(img, 'get_flattened_data') else list(img.get_flattened_data())
    alphas = {p[3] for p in px}
    cols = {p[:3] for p in px if p[3] == 255}
    print(name, img.size, img.mode, 'alpha', sorted(alphas), 'colours', len(cols))
    return img
