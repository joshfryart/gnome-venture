#!/usr/bin/env python3
"""stops_kit.py: shared drawing kit for the 48 x 48 stop type icons (game/assets/img/stops/<type>.png), Stitched Toy redraw.

STAGING ONLY: writes art-review/stopart/out/stops/<type>.png and art-review/stopart/out/_cmp/stops-<type>.png. Never touches game/.

Coordinates are pixels of the 48 px canvas, shapes are tested at pixel centres (shape predicates come from art-review/kit/pal_kit.py).
Each felt piece ("part") gets its own finish: a light rim upper-left, a dark crescent lower-right, a dashed thread stitch 2 px inside
when the piece is big enough, and an inner umber-brown contour where it lies in front of an earlier piece. One 1 px umber outline
around the whole silhouette. Hard 1-bit alpha, no anti-aliasing, flat colours. Deterministic.
"""
import math
import os
import sys

from PIL import Image, ImageDraw

ROOT = '/home/user/gnome-venture'
sys.path.insert(0, os.path.join(ROOT, 'art-review/kit'))
from pal_kit import rect, ell, poly, thick_path, erode, hexrgb, UMBER, UMBER2, CREAM  # noqa: E402,F401

N = 48
OUT = os.path.join(ROOT, 'art-review/stopart/out/stops')
CMP = os.path.join(ROOT, 'art-review/stopart/out/_cmp')
SHIP = os.path.join(ROOT, 'game/assets/img/stops')

# ramps (base, dark, light)
MOSS = ('#5f9a42', '#3a6a2a', '#9ac86a')
LEAF = ('#5aa04a', '#2f6a3a', '#9ad07a')
WOOD = ('#b07a3a', '#7a4a1f', '#d9a35a')
WOOD_D = ('#7a4a26', '#4a2c1a', '#a06a3a')
CANVAS = ('#dcb47a', '#a8804a', '#f2d6a4')
CLOTH = ('#f2e4c0', '#c9a96e', '#fff6dc')
RED = ('#c8382e', '#8e221c', '#ec6a4e')
GOLD = ('#e8a317', '#b07a10', '#f5cf6a')
WATER = ('#3f8ac8', '#245a8e', '#a9d6ea')
STONE = ('#9a96a0', '#66626e', '#c8c4cc')
SOIL = ('#8a5a32', '#5a3a1e', '#b4824e')
DARK = ('#5a3a24', '#3d2a1c', '#7a5232')
PLASTER = ('#f0c896', '#c4925a', '#ffe2b8')
STEAM = ('#eef0ec', '#b8c4c8', '#ffffff')
PURPLE = ('#5a46a0', '#3a2c6e', '#8a78c8')
GLASS = ('#a9d6ea', '#5a8aa8', '#e0f2fa')
FLAME = ('#e8602a', '#b03a1a', '#f59a4a')
FLAME_IN = ('#f5c030', '#e89a17', '#fde68a')
THREAD = '#e8a317'      # gold thread (house)
THREAD_B = '#7a4a1f'    # brown thread for light felt
CONTOUR = '#4a2c1a'


def rot_ell(cx, cy, rx, ry, deg):
    a = math.radians(deg)
    ca, sa = math.cos(a), math.sin(a)

    def f(x, y):
        dx, dy = x - cx, y - cy
        u, v = dx * ca + dy * sa, -dx * sa + dy * ca
        return (u / rx) ** 2 + (v / ry) ** 2 < 1
    return f


def AND(*ps):
    return lambda x, y: all(p(x, y) for p in ps)


def OR(*ps):
    return lambda x, y: any(p(x, y) for p in ps)


def NOT(p):
    return lambda x, y: not p(x, y)


def walk(ring):
    """Order ring pixels as chains (4-neighbours first, then diagonals) so a dash pattern runs along the thread."""
    left = set(ring)
    out = []
    while left:
        cur = min(left, key=lambda q: (q[1], q[0]))
        while cur:
            left.discard(cur)
            out.append(cur)
            x, y = cur
            nxt = None
            for dx, dy in ((1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (-1, 1), (-1, -1), (1, -1)):
                if (x + dx, y + dy) in left:
                    nxt = (x + dx, y + dy)
                    break
            cur = nxt
        out += [None, None]   # gap between chains
    return out


class Icon:
    def __init__(self):
        self.parts = []   # dict(mask, ramp, stitch, shade, contour)
        self.over = {}

    def mask(self, pred):
        return {(x, y) for y in range(N) for x in range(N) if pred(x + 0.5, y + 0.5)}

    def add(self, pred, rmp, stitch=None, shade=True, contour=True):
        m = self.mask(pred) if callable(pred) else set(pred)
        self.parts.append(dict(mask=m, ramp=rmp, stitch=stitch, shade=shade, contour=contour))
        return m

    def px(self, x, y, col):
        self.over[(x, y)] = col

    def line(self, pts, col):
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            steps = max(abs(bx - ax), abs(by - ay), 1)
            for i in range(steps + 1):
                self.px(round(ax + (bx - ax) * i / steps), round(ay + (by - ay) * i / steps), col)

    def render(self):
        own = {}
        for i, p in enumerate(self.parts):
            for q in p['mask']:
                own[q] = i
        sil = set(own)
        vis = [set() for _ in self.parts]
        for q, i in own.items():
            vis[i].add(q)
        cols = {}
        nb4 = ((1, 0), (-1, 0), (0, 1), (0, -1))
        for i, p in enumerate(self.parts):
            V = vis[i]
            K = set()
            if p['contour']:
                for (x, y) in V:
                    for dx, dy in nb4:
                        j = own.get((x + dx, y + dy))
                        if j is not None and j < i:
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
                full = p['mask']
                e2 = erode(erode(full))
                e3 = erode(e2)
                ring = (e2 - e3) & I
                if len(e3) >= 6:
                    for k, q in enumerate(walk(ring)):
                        if q is not None and k % 4 < 2:
                            cols[q] = p['stitch']
        for q, c in self.over.items():
            if q in sil:
                cols[q] = c
        img = Image.new('RGBA', (N, N), (0, 0, 0, 0))
        for q, c in cols.items():
            img.putpixel(q, hexrgb(c) + (255,))
        for y in range(N):
            for x in range(N):
                if (x, y) not in sil and any((x + dx, y + dy) in sil for dx, dy in nb4):
                    img.putpixel((x, y), hexrgb(UMBER) + (255,))
        return img


def run(name, fn):
    ic = Icon()
    fn(ic)
    img = ic.render()
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(CMP, exist_ok=True)
    img.save(os.path.join(OUT, name + '.png'))
    old = Image.open(os.path.join(SHIP, name + '.png')).convert('RGBA')
    S = 6
    W = N * S
    sheet = Image.new('RGB', (4 * W + 50, W + 20), '#d8d0bc')
    d = ImageDraw.Draw(sheet)
    for bi, bg in enumerate(('#f1ece0', '#2a1a10')):
        x0 = bi * (2 * W + 30)
        d.rectangle((x0, 0, x0 + 2 * W + 19, W + 19), fill=bg)
        for k, im in enumerate((old, img)):
            big = im.resize((W, W), Image.NEAREST)
            sheet.paste(big, (x0 + 6 + k * (W + 8), 10), big)
        sheet.paste(img, (x0 + 2 * W - 40, W - 40), img)   # 1x actual size
    sheet.save(os.path.join(CMP, 'stops-' + name + '.png'))
    al = {px[3] for px in img.getdata()}
    assert al <= {0, 255}, al
    assert img.size == old.size and img.mode == old.mode
    print(name, 'ok', len({px[:3] for px in img.getdata() if px[3]}), 'colours')
    return img
