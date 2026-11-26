#!/usr/bin/env python3
"""stamp_kit.py: shared drawing kit for the 12 passport stamps (stamp-<type>.png, 64 x 64 RGBA) in Stitched Toy.
STAGING ONLY: writes art-review/stopart/out/stops/stamp-<key>.png and a side-by-side art-review/stopart/out/_cmp/stamp-<key>.png.

A stamp = a round felt badge (coloured ring with a gold dashed stitch, recessed cream centre) plus a subject made of flat felt pieces.
Each felt piece: base fill, 1 px light rim upper-left, dark crescent lower-right. One umber outline per object (badge, subject).
No anti-aliasing, alpha 0 or 255 only. Pixel-space coordinates (0..64), shapes tested at pixel centres. Deterministic.
"""
import math
import os
import sys

from PIL import Image, ImageDraw

ROOT = '/home/user/gnome-venture'
sys.path.insert(0, os.path.join(ROOT, 'art-review', 'kit'))
from pal_kit import ell, poly, rect, thick_path, erode, hexrgb, ramp  # noqa: E402,F401

UMBER = '#2a1a10'
CREAM = ('#f6ecd0', '#e2d2a8', '#fff8e4')   # base, dark, light
GOLD = '#e8a317'
N = 64


def ring(cx, cy, r0, r1):
    return lambda x, y: r0 * r0 <= (x - cx) ** 2 + (y - cy) ** 2 < r1 * r1


def mask(*preds, minus=()):
    out = set()
    for y in range(N):
        for x in range(N):
            X, Y = x + 0.5, y + 0.5
            if any(p(X, Y) for p in preds) and not any(p(X, Y) for p in minus):
                out.add((x, y))
    return out


class Group:
    """One outlined object made of felt pieces. Later pieces sit on top of earlier ones."""

    def __init__(self, outline=True):
        self.parts = []   # (mask, ramp, opts)
        self.over = {}
        self.outline = outline

    def add(self, m, rmp, flat=False, cres=1, inset=False, stitch=None, depth=2, dash=None):
        if isinstance(rmp, str):
            rmp = ramp(rmp)
        self.parts.append((set(m), rmp, dict(flat=flat, cres=cres, inset=inset, stitch=stitch, depth=depth, dash=dash)))
        return m

    def px(self, x, y, col):
        self.over[(int(x), int(y))] = col

    def line(self, pts, col):
        for (ax, ay), (bx, by) in zip(pts, pts[1:]):
            steps = max(abs(bx - ax), abs(by - ay), 1)
            for i in range(int(steps) + 1):
                self.px(round(ax + (bx - ax) * i / steps), round(ay + (by - ay) * i / steps), col)

    def rectpx(self, x0, y0, x1, y1, col):
        for y in range(y0, y1):
            for x in range(x0, x1):
                self.px(x, y, col)


def _paint_group(cols, sil_all, g):
    own = {}
    for i, (m, _, _) in enumerate(g.parts):
        for p in m:
            own[p] = i
    sil = set(own)
    for (x, y), i in own.items():
        _, rmp, o = g.parts[i]
        base, dk, lt = rmp
        c = base
        if not o['flat']:
            same = lambda q: own.get(q) == i  # noqa: E731
            lit = not same((x - 1, y)) or not same((x, y - 1))
            drk = any(not same((x + d, y)) or not same((x, y + d)) or not same((x + d, y + d)) for d in range(1, o['cres'] + 1))
            if o['inset']:
                lit, drk = drk and not lit, lit
                if drk:
                    c = dk
                elif lit:
                    c = lt
            else:
                if lit:
                    c = lt
                if drk:
                    c = dk
        cols[(x, y)] = c
    for i, (m, _, o) in enumerate(g.parts):
        if not o['stitch']:
            continue
        mine = {p for p in m if own.get(p) == i}
        e = mine
        for _ in range(o['depth']):
            e = erode(e)
        band = e - erode(e)
        dash = o['dash'] or (lambda x, y: ((x + y) // 2) % 2 == 0)
        for (x, y) in band:
            if dash(x, y):
                cols[(x, y)] = o['stitch']
    for p, c in g.over.items():
        if p in sil:
            cols[p] = c
    if g.outline:
        for y in range(N):
            for x in range(N):
                if (x, y) in sil:
                    continue
                if any((x + dx, y + dy) in sil for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    cols[(x, y)] = UMBER
                    sil_all.add((x, y))
    sil_all |= sil


def angle_dash(cx=32, cy=32, r=28.5, on=2, off=2):
    def f(x, y):
        a = math.atan2(y + 0.5 - cy, x + 0.5 - cx)
        s = int((a + math.pi) * r)
        return s % (on + off) < on
    return f


def badge(hue, pale=None):
    """The round stamp body: coloured felt ring with gold dashed stitch, recessed cream centre."""
    g = Group()
    g.add(mask(ell(32, 32, 31, 31)), ramp(hue) if isinstance(hue, str) else hue, cres=2,
          stitch=GOLD, depth=2, dash=angle_dash(r=27.5))
    g.add(mask(ell(32, 32, 24.2, 24.2)), pale or CREAM, inset=True)
    return g


def render(groups):
    cols, sil = {}, set()
    for g in groups:
        _paint_group(cols, sil, g)
    img = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    for (x, y), c in cols.items():
        if 0 <= x < N and 0 <= y < N:
            img.putpixel((x, y), hexrgb(c) + (255,))
    return img


def save(key, groups):
    img = render(groups)
    out = os.path.join(ROOT, 'art-review', 'stopart', 'out', 'stops')
    cmpd = os.path.join(ROOT, 'art-review', 'stopart', 'out', '_cmp')
    os.makedirs(out, exist_ok=True)
    os.makedirs(cmpd, exist_ok=True)
    name = 'stamp-%s.png' % key
    img.save(os.path.join(out, name))
    old = Image.open(os.path.join(ROOT, 'game', 'assets', 'img', 'stops', name)).convert('RGBA')
    S = 5
    W = 64 * S
    sheet = Image.new('RGB', (4 * W + 50, W + 20), '#f1ece0')
    d = ImageDraw.Draw(sheet)
    d.rectangle((2 * W + 25, 0, 4 * W + 50, W + 20), fill='#2a1a10')
    for i, (im, x) in enumerate(((old, 10), (img, W + 15), (old, 2 * W + 35), (img, 3 * W + 40))):
        big = im.resize((W, W), Image.NEAREST)
        sheet.paste(big, (x, 10), big)
    sheet.save(os.path.join(cmpd, name))
    a = {p[3] for p in img.getdata()}
    print(name, img.size, img.mode, 'alpha', sorted(a), 'colours', len({p for p in img.getdata() if p[3]}))
    return img
