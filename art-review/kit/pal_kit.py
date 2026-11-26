#!/usr/bin/env python3
"""pal_kit.py: shared drawing kit for the puzzle pal redraw (extracted from the Spicepeak pilot draw_pilot.py). PILOT redraw of the 6 Spicepeak Puzzle Pals (art-review staging only; nothing under game/ is touched).

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

ROOT = '/home/user/gnome-venture'

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
    """Knob in local coords: u along the side, v > 0 outward. Styles: round keyhole peg tri double hook (PPAL_KNOBS)."""
    c = r + 1.6
    if style == 'round':
        return (abs(u) < nw and -2.5 < v < r * 0.6 + 1) or u * u + (v - c) ** 2 < r * r
    if style == 'keyhole':
        flare = -2.5 < v < c and abs(u) < nw + 2.2 * max(0.0, min(1.0, 1 - v / c))
        return flare or u * u + (v - c - 0.5) ** 2 < (r * 0.8) ** 2
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
        self.edges = {}          # inner contours: drawn only where the pixel is not on the outer silhouette edge

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

    def edge(self, mask, col):
        """Inner contour: colour the pixels of mask that touch a pixel outside it (but still inside the silhouette, so the outline stays umber)."""
        for (x, y) in mask:
            if any((x + dx, y + dy) not in mask for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                self.edges[(x, y)] = col

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
        for (x, y), c in self.edges.items():
            if (x, y) in sil and all((x + dx, y + dy) in sil for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                cols[(x, y)] = c
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



# ================================================================ scale-up helpers (one agent = one pal = one script that imports this module)
def ramp(base):
    """(base, dark, light) ramp from one hex colour: dark = 72% value, light = 38% toward white."""
    r, g, b = (int(base.lstrip('#')[i:i + 2], 16) for i in (0, 2, 4))
    dk = '#%02x%02x%02x' % (int(r * .72), int(g * .72), int(b * .72))
    lt = '#%02x%02x%02x' % tuple(int(v + (255 - v) * .38) for v in (r, g, b))
    return (base, dk, lt)


def render_pal(fn, key, name, outdir, cellfile=None, oldfile=None):
    """Render fn(c) at 64 and 36 px into outdir/<key>.png and <key>-36.png, run the checks, write outdir/<key>-preview.png
    (old sticker | new 64 | new 36 at 4x on light and dark, plus the source cell). Returns the check report dict."""
    os.makedirs(outdir, exist_ok=True)
    i64, i36 = draw(fn, 64), draw(fn, 36)
    i64.save(os.path.join(outdir, key + '.png'))
    i36.save(os.path.join(outdir, key + '-36.png'))
    rep = {}
    for tag, im in (('64', i64), ('36', i36)):
        ck = check(im)
        ck.pop('sil')
        rep[tag] = ck
    S = 4
    font = ImageFont.load_default(13)
    tiles = []
    if oldfile and os.path.isfile(oldfile):
        tiles.append(Image.open(oldfile).convert('RGBA'))
    tiles += [i64, i36]
    W = 24 + len(tiles) * (64 * S + 16) + (64 * S + 16)
    sheet = Image.new('RGB', (W * 2 - 24, 64 * S + 60), '#d8d0bc')
    d = ImageDraw.Draw(sheet)
    for bi, bg in enumerate(('#f1ece0', '#2a1a10')):
        x0 = bi * (W - 12)
        d.rectangle((x0, 0, x0 + W - 24, 64 * S + 59), fill=bg)
        d.text((x0 + 8, 6), '%s "%s"' % (key, name), fill=UMBER if bi == 0 else '#f1ece0', font=font)
        xx = x0 + 8
        for im in tiles:
            big = im.resize((im.width * S, im.height * S), Image.NEAREST)
            sheet.paste(big, (xx, 30), big)
            xx += 64 * S + 16
        if bi == 0 and cellfile and os.path.isfile(cellfile):
            cell = Image.open(cellfile).convert('RGB').resize((64 * S, 64 * S), Image.NEAREST)
            sheet.paste(cell, (xx, 30))
    sheet.save(os.path.join(outdir, key + '-preview.png'))
    return rep


def draw(fn, n):
    c = C(n)
    fn(c)
    return c.render()


def check(img):
    px = [img.getpixel((x, y)) for y in range(img.height) for x in range(img.width)]
    alphas = {p[3] for p in px}
    cols = {p[:3] for p in px if p[3] == 255}
    black = any(p[:3] == (0, 0, 0) and p[3] == 255 for p in px)
    sil = tuple(p[3] == 255 for p in px)
    return {'size': img.size, 'alpha_ok': alphas <= {0, 255}, 'colours': len(cols), 'black': black, 'sil': sil}
