#!/usr/bin/env python3
"""2.7.20 hovel room art (Hearth Pop v3), drawn with Python + Pillow (Aseprite 1.3.18 was not in the container).

What it draws (hard pixels, ink #2b1c26 outline, no pure black or white, no semi-transparent pixels):
  sprite/gnome-home-big.png (+ -hat, -beard grey tint layers)   48x72 home gnome for the whole room (old 32x48 stays as the fallback)
  scenes/hovel-window-<item>-night.png                          night / lamp-lit twin of each window decor item (48x48)
  fx/fx-steam-a.png, fx-steam-b.png, fx-z-a.png, fx-z-b.png      the kettle steam and the bed's z's in the room (CSS animates them)
  scenes/hovel-kettle-<copper|castiron|samovar>.png             kettle overlays over the painted tin kettle (box HOVEL_KETTLE_ART: 312,140 40x47)
  ico/ico-kettle-<tin|copper|castiron|samovar>.png, ico-steam-cup.png   20x20 icons for the tea popover

usage: python3 aseprite-source/extras-pixel/scripts/hovel-room-2720.py [--install] [--contact]
  writes the PNGs to aseprite-source/extras-pixel/hovel-room-2720/ (the sources: this script + those PNGs),
  --install copies them to game/assets/img/<path>, --contact writes art-2720/contact.png (before | after on the real room).
"""
import math
import os
import shutil
import sys

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
IMG = os.path.join(ROOT, 'game/assets/img')
OUT = os.path.join(ROOT, 'aseprite-source/extras-pixel/hovel-room-2720')
INK = (0x2b, 0x1c, 0x26)
CREAM = (0xff, 0xf4, 0xd6)
KETTLE_BOX = (312, 140, 40, 47)   # x, y, w, h in room units; game/includes/home_slim.php HOVEL_KETTLE_ART must match


def hx(s):
    s = s.lstrip('#')
    return tuple(int(s[i:i + 2], 16) for i in (0, 2, 4))


def R(*cols):
    return [hx(c) for c in cols]


# ramps: hi .. deep
SEA = R('#b6f0e0', '#5fc4c8', '#3a86b0', '#2a4a7a')
WOOD = R('#e8b982', '#b97a4a', '#864c33', '#51302b')
SKIN = R('#ffe0bd', '#f0b98d', '#c98462', '#7a4036')
GOLD = R('#ffe38a', '#f5b82e', '#d98322', '#8f4a1f')
HATG = R('#f0f0f0', '#b4b4b4', '#787878', '#3c3c3c')      # tint markers (the hat layer is multiplied by the hat colour)
BEARDG = R('#e8e8e8', '#cccccc', '#9a9a9a', '#707070')    # tint markers for the beard layer (x1.25 = the beard colour)
BEARDC = R('#fbf2de', '#e2d4ba', '#b4a48a', '#6e6252')    # the base layer's own beard (cream), seen when no tint layer loads
COPPER = R('#ffd0a0', '#f0a064', '#d2703c', '#a4482e', '#6c2a26')
IRON = R('#a2a8c0', '#737992', '#50566a', '#3a3c50', '#26232f')
SILVER = R('#eef0f8', '#c6cad8', '#9ea2b8', '#73768f', '#4a4c66')
TIN = R('#94c8b2', '#64aa9a', '#408a84', '#2c686a', '#1e4a52')
PORC = R('#fff4d6', '#f2e2c4', '#d2bc9c', '#9a7e68')


class Spr:
    """A sprite as a dict of pixels; draw shapes with tone functions, then outline."""

    def __init__(self, w, h, ox=0, oy=0):
        self.w, self.h, self.ox, self.oy = w, h, ox, oy
        self.p = {}
        self.tag = {}

    def put(self, x, y, c, tag=None):
        x -= self.ox; y -= self.oy
        if 0 <= x < self.w and 0 <= y < self.h:
            self.p[(x, y)] = c
            if tag is not None: self.tag[(x, y)] = tag
            else: self.tag.pop((x, y), None)

    def get(self, x, y):
        return self.p.get((x - self.ox, y - self.oy))

    def has(self, x, y):
        return (x - self.ox, y - self.oy) in self.p

    def ellipse(self, cx, cy, rx, ry, fn, clip=None, tag=None):
        for y in range(int(math.floor(cy - ry)), int(math.ceil(cy + ry)) + 1):
            for x in range(int(math.floor(cx - rx)), int(math.ceil(cx + rx)) + 1):
                nx = (x + .5 - cx) / rx if rx else 0
                ny = (y + .5 - cy) / ry if ry else 0
                if nx * nx + ny * ny <= 1.0 and (clip is None or clip(x, y)):
                    c = fn(x, y, nx, ny)
                    if c: self.put(x, y, c, tag)

    def poly(self, pts, fn, tag=None):
        xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
        for y in range(int(min(ys)), int(max(ys)) + 1):
            for x in range(int(min(xs)), int(max(xs)) + 1):
                if inside(pts, x + .5, y + .5):
                    c = fn(x, y)
                    if c: self.put(x, y, c, tag)

    def rect(self, x0, y0, x1, y1, fn, tag=None):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                c = fn(x, y) if callable(fn) else fn
                if c: self.put(x, y, c, tag)

    def line(self, pts, c, w=1, tag=None):
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = max(abs(x1 - x0), abs(y1 - y0), 1)
            for i in range(n + 1):
                x = round(x0 + (x1 - x0) * i / n); y = round(y0 + (y1 - y0) * i / n)
                for dx in range(w):
                    cc = c(x + dx, y) if callable(c) else c
                    self.put(x + dx, y, cc, tag)

    def outline(self, col=INK, diag=False):
        add = []
        for y in range(self.h):
            for x in range(self.w):
                if (x, y) in self.p: continue
                nb = [(1, 0), (-1, 0), (0, 1), (0, -1)] + ([(1, 1), (-1, -1), (1, -1), (-1, 1)] if diag else [])
                if any((x + a, y + b) in self.p for a, b in nb): add.append((x, y))
        for q in add: self.p[q] = col

    def image(self):
        im = Image.new('RGBA', (self.w, self.h), (0, 0, 0, 0))
        for (x, y), c in self.p.items(): im.putpixel((x, y), tuple(c) + (255,))
        return im


def inside(pts, x, y):
    n = len(pts); c = False
    for i in range(n):
        x1, y1 = pts[i]; x2, y2 = pts[(i + 1) % n]
        if (y1 > y) != (y2 > y) and x < (x2 - x1) * (y - y1) / (y2 - y1) + x1: c = not c
    return c


def lit(ramp, nx, ny, bias=0.0):
    """Tone from a round surface normal, light from the upper left."""
    nz = math.sqrt(max(0.0, 1 - nx * nx - ny * ny))
    l = -0.55 * nx - 0.6 * ny + 0.55 * nz + bias
    n = len(ramp)
    cut = [0.72, 0.42, 0.08, -0.3] if n == 5 else [0.62, 0.2, -0.22]
    for i, t in enumerate(cut):
        if l > t: return ramp[i]
    return ramp[-1]


# ------------------------------------------------------------------ 1. the home gnome, 48x72
def gnome_big():
    """Returns (base, hat layer, beard layer) as Spr. Feet at row 69, a 2-row floor shadow at 70-71."""
    base = Spr(48, 72)
    hat_px, beard_px = set(), set()
    cx = 24
    # boots
    for bx in (14, 26):
        base.rect(bx, 62, bx + 8, 69, lambda x, y, bx=bx: WOOD[3] if y == 69 else (WOOD[0] if (x == bx + 1 and y < 66) else (WOOD[2] if x >= bx + 6 else WOOD[1])))
        base.put(bx - 1 if bx == 14 else bx + 9, 68, WOOD[2]); base.put(bx - 1 if bx == 14 else bx + 9, 69, WOOD[3])
        base.rect(bx, 62, bx + 8, 62, WOOD[3])   # boot cuff shadow under the tunic
    # tunic: a slightly flared body
    def tunic(x, y):
        t = (y - 38) / 23.0
        l = 13 - round(2 * t); r = 35 + round(2 * t)
        if x < l or x > r: return None
        u = (x - l) / max(1, r - l)
        if y >= 60: return SEA[3] if u > .7 else SEA[2]
        if u < .18: return SEA[0]
        if u < .62: return SEA[1]
        if u < .86: return SEA[2]
        return SEA[3]
    base.rect(10, 38, 38, 61, tunic)
    for x in range(12, 37):   # hem stitch: gold dashes 2 on 1 off
        if (x - 12) % 3 != 2 and base.has(x, 59): base.put(x, 59, GOLD[1] if x < 30 else GOLD[2])
    # belt + buckle
    base.rect(11, 52, 37, 54, lambda x, y: (WOOD[3] if y == 54 else (WOOD[1] if x < 28 else WOOD[2])) if base.has(x, y) else None)
    base.rect(22, 51, 26, 55, lambda x, y: GOLD[3] if x in (22, 26) or y in (51, 55) else (GOLD[0] if (x, y) == (23, 52) else GOLD[1]))
    base.rect(24, 53, 24, 53, SEA[3])
    # quirk: a wooden teaspoon tucked in the belt
    SPOON = []
    # arms (sleeves) and mitten hands
    for side in (-1, 1):
        x0 = 8 if side < 0 else 36
        for y in range(40, 54):
            for x in range(x0, x0 + 5):
                if y == 40 and x in (x0, x0 + 4): continue
                c = SEA[1] if side < 0 else SEA[2]
                if side < 0 and x == x0 + 1: c = SEA[0]
                if (side < 0 and x == x0 + 4) or (side > 0 and x == x0 + 4): c = SEA[3]
                if y == 53: c = SEA[3]
                base.put(x, y, c)
        hx0 = x0
        base.rect(hx0, 54, hx0 + 4, 57, lambda x, y, s=side, h0=hx0: SKIN[3] if y == 57 and x in (h0, h0 + 4) else (SKIN[0] if (x == h0 + 1 and y == 54) else (SKIN[2] if (y == 57 or x == h0 + 4) else SKIN[1])))
        base.p.pop((hx0, 57), None); base.p.pop((hx0 + 4, 57), None)
    # face
    base.ellipse(cx, 28, 11, 7.5, lambda x, y, nx, ny: lit(SKIN, nx, ny, .15))
    # ears
    for ex, c in ((12, SKIN[1]), (36, SKIN[2])):
        base.rect(ex, 26, ex, 29, c); base.put(ex, 28, SKIN[2] if ex == 12 else SKIN[3])
    # beard (tinted layer): a soft V down the chest
    def beard_w(y):
        if y < 30 or y > 57: return None
        t = (y - 30) / 27.0
        hw = 12.5 * (1 - t ** 1.8) ** .55
        return max(1, round(hw))
    for y in range(30, 58):
        hw = beard_w(y)
        if hw is None: continue
        for x in range(cx - hw, cx + hw):
            u = (x - (cx - hw)) / max(1, 2 * hw - 1)
            strand = (x + (y // 4)) % 4 == 0 and 33 < y < 55
            if u < .2: k = 0
            elif u < .6: k = 1
            elif u < .85: k = 2
            else: k = 3
            if strand and k < 3: k = min(3, k + 1)
            if y >= 55 and k < 2: k = 2
            base.put(x, y, BEARDC[k], tag=('beard', k)); beard_px.add((x, y))
    # mustache: two lobes over the mouth, a shade row under it
    for side in (-1, 1):
        mx = cx - 5 if side < 0 else cx + 4
        base.ellipse(mx + .5, 33.5, 5.2, 2.2, lambda x, y, nx, ny: None, tag=None)
        for y in range(32, 36):
            for x in range(mx - 5, mx + 6):
                nx = (x + .5 - (mx + .5)) / 5.4; ny = (y + .5 - 33.6) / 2.2
                if nx * nx + ny * ny <= 1:
                    k = 0 if ny < -.3 and nx < .3 else (1 if ny < .4 else 2)
                    if side > 0 and nx > .5: k = min(3, k + 1)
                    base.put(x, y, BEARDC[k], tag=('beard', k)); beard_px.add((x, y))
    for x in range(cx - 7, cx + 7):   # contact shade under the mustache
        if base.has(x, 36) and (x, 36) in beard_px: base.put(x, 36, BEARDC[2], tag=('beard', 2))
    # quirk: a wooden teaspoon tucked in the belt, right of the beard
    base.rect(34, 47, 35, 52, lambda x, y: WOOD[0] if x == 34 else WOOD[2])
    base.rect(33, 44, 36, 46, lambda x, y: WOOD[3] if y == 46 else (WOOD[0] if (x, y) == (34, 44) else (WOOD[2] if x == 36 else WOOD[1])))
    # nose: rounded, warmer, lit tip, dark underside, nostrils
    nose = {(23, 29): 'b', (24, 29): 'b', (25, 29): 'b', (22, 30): 'b', (23, 30): 'h', (24, 30): 'b', (25, 30): 'b', (26, 30): 's',
            (22, 31): 'b', (23, 31): 'b', (24, 31): 'b', (25, 31): 'b', (26, 31): 's', (22, 32): 'n', (23, 32): 's', (24, 32): 's', (25, 32): 's', (26, 32): 'n'}
    ncol = {'h': hx('#ffd2b0'), 'b': hx('#f2a47c'), 's': hx('#c9785a'), 'n': SKIN[3]}
    for (x, y), k in nose.items(): base.put(x, y, ncol[k])
    # eyes: 2x3 ink pills with a cream glint, cheeks
    for ex in (18, 29):
        base.rect(ex, 25, ex + 1, 27, INK); base.put(ex, 25, CREAM)
    for chx in (15, 32):
        base.put(chx, 29, hx('#f5809f')); base.put(chx + 1, 29, hx('#f5809f'))
    # hat: cone with a floppy tip, a brim, a gold band
    cone = [(10, 20), (17, 11), (22, 5), (26, 2), (31, 2), (35, 4), (38, 8), (37, 10), (34, 8), (32, 8), (33, 12), (38, 20)]
    def cone_c(x, y):
        # across the cone: lit on the left, shade on the right
        l = 10 + (20 - y) * 0.6; r = 38 - (20 - y) * 0.4
        if y < 9: return HATG[1] if x < 31 else (HATG[2] if x < 35 else HATG[3])
        u = (x - l) / max(1, r - l)
        if u < .25: return HATG[0]
        if u < .62: return HATG[1]
        if u < .86: return HATG[2]
        return HATG[3]
    base.poly(cone, cone_c, tag='hat')
    for (x, y) in [(36, 9), (37, 9), (36, 10)]: base.put(x, y, HATG[3], tag='hat')
    base.put(27, 3, HATG[0], tag='hat'); base.put(26, 4, HATG[0], tag='hat')   # a glint on the tip
    # a fold crease line down the cone
    for y in range(12, 19): base.put(28 + (y - 12) // 3, y, HATG[2], tag='hat')
    # brim
    base.ellipse(cx, 21.5, 19.5, 2.6, lambda x, y, nx, ny: HATG[3] if ny > .45 else (HATG[0] if nx < -.55 else (HATG[1] if nx < .45 else HATG[2])), tag='hat')
    # gold band dashes on the brim's top row
    for x in range(9, 40):
        if (x - 9) % 3 != 2 and base.has(x, 20) and base.tag.get((x, 20)) == 'hat': base.put(x, 20, GOLD[1] if x < 30 else GOLD[2])
    # shade under the brim on the face
    for x in range(13, 36):
        if base.has(x, 24) and base.get(x, 24) in SKIN: base.put(x, 24, SKIN[2])
    for k, v in list(base.tag.items()):
        if v == 'hat': hat_px.add(k)
    base.outline()
    # floor shadow (rows 70-71), not outlined
    for y, (a, b) in ((70, (11, 37)), (71, (15, 33))):
        for x in range(a, b + 1):
            if (x, y) not in base.p: base.p[(x, y)] = hx('#5a5468')
    hat = Spr(48, 72); beard = Spr(48, 72)
    for q in hat_px:
        if q in base.p and base.p[q] in HATG: hat.p[q] = base.p[q]
    for q in beard_px:
        t = base.tag.get(q)
        if q in base.p and isinstance(t, tuple) and base.p[q] in BEARDC: beard.p[q] = BEARDG[t[1]]
    return base, hat, beard


# ------------------------------------------------------------------ 2. night windows
SKYMAP = {'#a8d6f2': '#24305e', '#b9e2f5': '#2c3a6e', '#d2eefa': '#38477e', '#5f9ad0': '#1c2550',
          '#d2e4ee': '#55609a', '#f4f8f6': '#7a82b8', '#e4f6ff': '#c9b2f0',
          '#78b064': '#2e5652', '#529054': '#223e42'}
SKY_KEYS = {'#a8d6f2', '#b9e2f5', '#d2eefa'}
FRAMEMAP = {'#b88058': '#d8985a', '#946244': '#a86e42', '#d8a474': '#f2c27a', '#fff0c8': '#fff4d6'}


def window_night(day, plain):
    im = day.copy().convert('RGBA'); pl = plain.convert('RGBA')
    W, H = im.size
    glass = set()
    for y in range(H):
        for x in range(W):
            p = im.getpixel((x, y)); q = pl.getpixel((x, y))
            if p[3] == 0: continue
            h = '#%02x%02x%02x' % p[:3]
            hq = '#%02x%02x%02x' % q[:3]
            if hq in SKYMAP and p[:3] == q[:3] and 9 <= x <= 38 and 7 <= y <= 39:
                im.putpixel((x, y), hx(SKYMAP[h]) + (255,)); glass.add((x, y, h))
            elif h in FRAMEMAP:
                im.putpixel((x, y), hx(FRAMEMAP[h]) + (255,))
    sky = {(x, y) for x, y, h in glass if h in SKY_KEYS}
    # a crescent moon in the upper right pane, stars where the sky shows
    moon = [(31, 10), (32, 10), (33, 11), (33, 12), (33, 13), (32, 14), (31, 14), (30, 10), (30, 14)]
    moonhi = [(32, 11), (32, 12), (32, 13)]
    if all(q in sky for q in moon + moonhi):
        for q in moon: im.putpixel(q, hx('#ffe38a') + (255,))
        for q in moonhi: im.putpixel(q, CREAM + (255,))
    stars = [(14, 11), (19, 15), (25, 10), (13, 19), (22, 21), (28, 17), (35, 20), (17, 25), (34, 24)]
    for i, q in enumerate(stars):
        if q in sky: im.putpixel(q, (CREAM if i % 3 == 0 else hx('#ffe38a')) + (255,))
    # lamp light: a warm reflection of the room's lamp low in the right pane
    for q, c in (((30, 33), '#f5b82e'), ((31, 33), '#ffe38a'), ((30, 34), '#d98322'), ((31, 34), '#f5b82e')):
        if (q[0], q[1]) in {(x, y) for x, y, h in glass}: im.putpixel(q, hx(c) + (255,))
    return im


# ------------------------------------------------------------------ 3. steam and z's
def steam(n):
    s = Spr(n, n)
    if n >= 10:
        blobs = [(3.5, 6.0, 2.6), (6.0, 4.0, 2.8), (6.5, 6.8, 2.2)]
    else:
        blobs = [(3.0, 4.6, 2.2), (5.0, 3.4, 2.2)]
    tone = R('#fff4d6', '#eceef6', '#c4c8da')
    for bx, by, r in blobs:
        s.ellipse(bx, by, r, r, lambda x, y, nx, ny: tone[0] if (nx < -.1 and ny < -.1) else (tone[1] if (nx + ny) < .9 else tone[2]))
    s.outline(hx('#8a8ea6'))
    return s


Z_A = ['xxxxxx', '....xx', '...xx.', '..xx..', '.xx...', 'xxxxxx']
Z_B = ['xxxx', '..xx', '.xx.', 'xxxx']


def zsprite(rows):
    h = len(rows); w = len(rows[0])
    s = Spr(w + 2, h + 2)
    for y, r in enumerate(rows):
        for x, ch in enumerate(r):
            if ch == 'x': s.p[(x + 1, y + 1)] = CREAM if y < h - 1 else hx('#d6dae8')
    s.outline(INK, diag=True)
    return s


# ------------------------------------------------------------------ 4. kettle overlays (room coordinates)
def clean_background(room):
    """The room with the painted tin kettle taken out (wall, rail, wainscot, table top rebuilt row by row)."""
    im = room.copy()
    px = room.load(); out = im.load()
    for y in range(160, 186):
        for x in range(316, 352):
            if y <= 174: src = (x - 32, y)              # plaster wall texture
            elif y in (175, 183): src = None; out[x, y] = INK + (255,); continue
            elif y in (176, 177): src = (300, y)        # the rail
            elif y in (178, 179): src = (300, y)
            elif y <= 182: src = (x - 30, y)            # wainscot planks
            else: src = (366, y)                        # the table top
            out[x, y] = px[src]
    return im


def ellipse_tone(ramp, bias=0.0, spec=None):
    def f(x, y, nx, ny):
        if spec and spec(nx, ny): return CREAM
        return lit(ramp, nx, ny, bias)
    return f


def kettle_copper(s):
    # bail handle: wire arc + a wooden grip
    for a in range(0, 181, 3):
        t = math.radians(a)
        x = 335 + 10 * math.cos(t); y = 172 - 14 * math.sin(t)
        s.put(round(x), round(y), COPPER[3] if a < 90 else COPPER[2])
    s.rect(331, 157, 339, 159, lambda x, y: WOOD[0] if y == 157 and x < 336 else (WOOD[3] if y == 159 else WOOD[1]))
    # spout: a tapering gooseneck to the upper left
    for i, (x, y) in enumerate([(326, 180), (325, 179), (324, 178), (323, 177), (323, 176), (322, 175), (322, 174), (321, 173), (321, 172), (321, 171), (320, 170), (320, 169), (320, 168)]):
        w = 3 if i < 6 else 2
        for d in range(w): s.put(x + d, y, COPPER[1] if d == 0 else COPPER[3])
    s.put(319, 167, COPPER[2]); s.put(320, 167, COPPER[1]); s.put(321, 167, COPPER[4])
    # body: a round belly, flat foot
    s.ellipse(335, 176.5, 12.5, 8.5, ellipse_tone(COPPER, .05, lambda nx, ny: -.62 < nx < -.42 and -.62 < ny < -.25), clip=lambda x, y: y <= 183)
    s.rect(327, 183, 343, 183, COPPER[4])
    # a bright band (hammered rim) round the shoulder
    for x in range(325, 346):
        if s.has(x, 171): s.put(x, 171, COPPER[0] if x < 333 else (COPPER[2] if x < 341 else COPPER[3]))
    # lid and knob
    s.ellipse(335, 169.2, 5.5, 2.2, lambda x, y, nx, ny: COPPER[1] if nx < 0 else COPPER[2])
    s.rect(334, 165, 336, 167, lambda x, y: WOOD[0] if x == 334 else WOOD[2])
    s.put(335, 164, WOOD[1])
    # quirk: one little dent, shaded
    s.put(342, 178, COPPER[3]); s.put(343, 179, COPPER[4]); s.put(341, 179, COPPER[2])


def kettle_castiron(s):
    # arched iron bail handle with a twisted grip
    for a in range(0, 181, 3):
        t = math.radians(a)
        x = 335 + 11 * math.cos(t); y = 172 - 13 * math.sin(t)
        s.put(round(x), round(y), IRON[2] if a > 90 else IRON[3])
        s.put(round(x), round(y) + 1, IRON[4])
    for x in range(330, 341):
        s.put(x, 159, IRON[1] if x % 2 else IRON[3])
    # stubby spout
    for i, (x, y) in enumerate([(325, 177), (324, 176), (323, 175), (322, 174), (321, 173), (321, 172), (320, 171)]):
        for d in range(3): s.put(x + d, y, IRON[1] if d == 0 else (IRON[2] if d == 1 else IRON[3]))
    s.put(320, 170, IRON[2]); s.put(321, 170, IRON[3])
    # squat body
    s.ellipse(335, 177.5, 13.5, 7.5, ellipse_tone(IRON, .1, lambda nx, ny: -.55 < nx < -.4 and -.7 < ny < -.45), clip=lambda x, y: y <= 183)
    s.rect(326, 183, 344, 183, IRON[4])
    # hobnail bumps: a lit dot and a dark dot beside it, on a grid
    for y in range(173, 183, 3):
        for x in range(324 + (y // 3) % 2 * 2, 347, 4):
            if s.has(x, y) and s.has(x + 1, y + 1) and s.get(x, y) not in (CREAM,):
                s.put(x, y, IRON[0] if x < 337 else IRON[1]); s.put(x + 1, y + 1, IRON[4])
    # a band where the lid sits
    for x in range(323, 348):
        if s.has(x, 171): s.put(x, 171, IRON[4])
    s.ellipse(335, 169.5, 6.5, 2, lambda x, y, nx, ny: IRON[1] if nx < -.2 else IRON[3])
    # quirk: the lid knob is a little cast acorn in moss green
    s.rect(334, 166, 336, 167, lambda x, y: hx('#7cc35a') if x == 334 else hx('#3f9150'))
    s.put(335, 165, hx('#864c33'))


def kettle_samovar(s):
    # pedestal foot and stem
    s.rect(325, 182, 345, 183, lambda x, y: SILVER[4] if y == 183 else (SILVER[1] if x < 333 else (SILVER[3] if x > 340 else SILVER[2])))
    s.rect(328, 180, 342, 181, lambda x, y: SILVER[1] if x < 333 else (SILVER[3] if x > 339 else SILVER[2]))
    s.rect(331, 178, 339, 179, lambda x, y: SILVER[3] if x > 336 else SILVER[2])
    # side handles (gold loops) and the urn body
    for side in (-1, 1):
        x0 = 322 if side < 0 else 346
        xo = x0 + (0 if side < 0 else 1)
        s.rect(xo, 164, xo + 1, 168, lambda x, y, xo=xo: (GOLD[0] if x == xo else GOLD[2]) if (y in (164, 168) or (x == xo and side < 0) or (x == xo + 1 and side > 0)) else None)
    s.ellipse(335, 169.5, 10.5, 9, ellipse_tone(SILVER, -.12, lambda nx, ny: -.62 < nx < -.45 and -.7 < ny < 0.1))
    # gold belly band with dots
    for x in range(325, 346):
        if s.has(x, 172): s.put(x, 172, GOLD[1] if x < 338 else GOLD[2])
        if s.has(x, 173) and x % 3 == 0: s.put(x, 173, GOLD[3])
    # tap at the front left, with a gold key
    s.rect(321, 175, 326, 176, lambda x, y: SILVER[1] if y == 175 else SILVER[3])
    s.rect(321, 177, 322, 178, lambda x, y: SILVER[2] if x == 321 else SILVER[4])
    s.rect(323, 172, 324, 174, lambda x, y: GOLD[0] if x == 323 else GOLD[2])
    # crown: a neck, a little gallery, and the porcelain teapot on top (the quirk: it keeps warm up there)
    s.rect(330, 159, 340, 160, lambda x, y: SILVER[1] if x < 334 else (SILVER[3] if x > 338 else SILVER[2]))
    for x in range(330, 341, 2): s.put(x, 158, GOLD[1])
    s.ellipse(335, 153.5, 5.5, 4, ellipse_tone(PORC, .1))
    for (x, y) in ((332, 153), (335, 152), (338, 154), (334, 155)): s.put(x, y, hx('#3a86b0'))   # blue dots
    s.rect(327, 151, 330, 152, lambda x, y: PORC[1] if y == 151 else PORC[2]); s.put(326, 150, PORC[1]); s.put(327, 150, PORC[2])
    s.rect(341, 151, 342, 155, lambda x, y: PORC[2] if (x == 342 or y in (151, 155)) else None)
    s.rect(334, 148, 336, 149, lambda x, y: PORC[0] if x == 334 else PORC[2]); s.put(335, 147, PORC[1])


KETTLES = {'copper': kettle_copper, 'castiron': kettle_castiron, 'samovar': kettle_samovar}


def kettle_overlay(room, draw):
    x0, y0, w, h = KETTLE_BOX
    bg = clean_background(room)
    s = Spr(w, h, x0, y0)
    draw(s)
    s.outline()
    comp = bg.crop((x0, y0, x0 + w, y0 + h))
    k = s.image()
    comp.alpha_composite(k)
    # a contact shadow on the table under the foot
    cp = comp.load()
    for x in range(w):
        if s.p.get((x, 183 - y0)) is not None and 184 - y0 < h: cp[x, 184 - y0] = INK + (255,)
    # keep only the pixels that differ from the room
    out = Image.new('RGBA', (w, h), (0, 0, 0, 0)); op = out.load(); rp = room.load()
    for y in range(h):
        for x in range(w):
            if cp[x, y][:3] != rp[x0 + x, y0 + y][:3]: op[x, y] = cp[x, y][:3] + (255,)
    return out


# ------------------------------------------------------------------ 5. 20x20 icons
def ico_kettle(kind):
    s = Spr(20, 20)
    if kind == 'samovar':
        s.rect(5, 17, 14, 18, lambda x, y: SILVER[4] if y == 18 else (SILVER[1] if x < 9 else SILVER[3]))
        s.rect(8, 15, 11, 16, SILVER[2])
        s.ellipse(9.5, 11, 5.5, 4.5, ellipse_tone(SILVER, .05, lambda nx, ny: -.7 < nx < -.3 and -.7 < ny < -.3))
        for x in range(4, 16):
            if s.has(x, 12): s.put(x, 12, GOLD[1] if x < 11 else GOLD[2])
        s.rect(1, 13, 4, 13, SILVER[2]); s.put(1, 14, SILVER[3])
        s.ellipse(9.5, 4.5, 3.5, 2.5, ellipse_tone(PORC, .1))
        s.put(9, 4, hx('#3a86b0')); s.put(5, 3, PORC[2]); s.put(9, 1, PORC[1])
        s.outline(); return s
    ramp = {'tin': TIN, 'copper': COPPER, 'castiron': IRON}[kind]
    # handle
    for a in range(0, 181, 6):
        t = math.radians(a)
        s.put(round(10 + 6 * math.cos(t)), round(10 - 6 * math.sin(t)), ramp[3])
    if kind == 'copper': s.rect(8, 3, 12, 4, lambda x, y: WOOD[0] if y == 3 else WOOD[2])
    # spout
    for (x, y) in [(4, 14), (3, 13), (2, 12), (2, 11), (1, 10)]:
        s.put(x, y, ramp[1]); s.put(x + 1, y, ramp[3])
    s.ellipse(10.5, 14, 7.5, 5, ellipse_tone(ramp, .1, lambda nx, ny: -.6 < nx < -.35 and -.65 < ny < -.35), clip=lambda x, y: y <= 18)
    s.ellipse(10.5, 9.6, 3.5, 1.4, lambda x, y, nx, ny: ramp[1] if nx < 0 else ramp[2])
    s.put(10, 8, GOLD[1] if kind == 'tin' else (hx('#7cc35a') if kind == 'castiron' else WOOD[1]))
    if kind == 'tin':
        s.put(14, 15, ramp[4]); s.put(15, 16, ramp[3])   # the dent
        for x in range(5, 17, 2):
            if s.has(x, 13): s.put(x, 13, hx('#f8eacc'))
    if kind == 'castiron':
        for (x, y) in ((6, 13), (10, 13), (14, 13), (8, 16), (12, 16)): s.put(x, y, ramp[0])
    s.outline()
    return s


def ico_steam_cup():
    s = Spr(20, 20)
    s.rect(4, 10, 13, 17, lambda x, y: hx('#e8493b') if x < 8 else (hx('#b52e3f') if x < 12 else hx('#6e2038')))
    s.rect(5, 10, 5, 15, hx('#ff8a5c'))
    s.rect(4, 10, 13, 10, hx('#6e2038'))
    s.rect(5, 10, 12, 10, hx('#8f4a1f'))   # tea in the cup
    for (x, y) in ((14, 11), (15, 12), (15, 13), (15, 14), (14, 15)): s.put(x, y, hx('#b52e3f'))
    s.rect(2, 18, 15, 18, hx('#aaa9b8'))   # saucer
    for (x, y) in ((6, 7), (7, 6), (6, 5), (7, 4), (10, 7), (11, 6), (10, 5), (11, 4), (10, 3)):
        s.put(x, y, hx('#eceef6'))
    s.outline()
    return s


# ------------------------------------------------------------------ build
def files():
    """[(path under game/assets/img, Image)]"""
    out = []
    base, hat, beard = gnome_big()
    out += [('sprite/gnome-home-big.png', base.image()), ('sprite/gnome-home-big-hat.png', hat.image()), ('sprite/gnome-home-big-beard.png', beard.image())]
    plain = Image.open(os.path.join(IMG, 'scenes/hovel-window-plain.png'))
    for item in window_items():
        day = Image.open(os.path.join(IMG, 'scenes/hovel-window-%s.png' % item))
        out.append(('scenes/hovel-window-%s-night.png' % item, window_night(day, plain)))
    out += [('fx/fx-steam-a.png', steam(10).image()), ('fx/fx-steam-b.png', steam(8).image()),
            ('fx/fx-z-a.png', zsprite(Z_A).image()), ('fx/fx-z-b.png', zsprite(Z_B).image())]
    room = Image.open(os.path.join(IMG, 'scenes/hovel-room.png')).convert('RGBA')
    for k, fn in KETTLES.items(): out.append(('scenes/hovel-kettle-%s.png' % k, kettle_overlay(room, fn)))
    for k in ('tin', 'copper', 'castiron', 'samovar'): out.append(('ico/ico-kettle-%s.png' % k, ico_kettle(k).image()))
    out.append(('ico/ico-steam-cup.png', ico_steam_cup().image()))
    return out


def window_items():
    import json
    d = json.load(open(os.path.join(ROOT, 'game/includes/data/hovel_decor.json')))
    for s in d['slots']:
        if s['k'] == 'window': return [i['k'] for i in s['items']]
    return []


def check(im, name):
    bad = []
    for p in im.getdata():
        if p[3] not in (0, 255): bad.append('semi-transparent'); break
    for p in im.getdata():
        if p[3] and p[:3] in ((0, 0, 0), (255, 255, 255)): bad.append('pure black/white'); break
    if bad: raise SystemExit('%s: %s' % (name, ', '.join(bad)))


def contact(made):
    """art-2720/contact.png: before | after on the real room picture, 3x."""
    room = Image.open(os.path.join(IMG, 'scenes/hovel-room.png')).convert('RGBA')
    old = Image.open(os.path.join(IMG, 'sprite/gnome-home.png')).convert('RGBA')
    S = 3; pad = 8
    tiles = []
    # gnome: before (32x48 at 214,172) | after (48x72 at 202,150), room crop 150..300 x 130..230
    def gcrop(g, at):
        r = room.copy(); r.alpha_composite(g, at); return r.crop((170, 130, 300, 230))
    hat_tint = (0xe8, 0x49, 0x3b)
    big = made['sprite/gnome-home-big.png'].copy()
    hat = made['sprite/gnome-home-big-hat.png']
    tinted = Image.new('RGBA', hat.size, (0, 0, 0, 0))
    for y in range(hat.size[1]):
        for x in range(hat.size[0]):
            p = hat.getpixel((x, y))
            if p[3]: tinted.putpixel((x, y), tuple(min(255, int(p[i] / 255 * hat_tint[i] * 1.25)) for i in range(3)) + (255,))
    big.alpha_composite(tinted)
    tiles.append([gcrop(old, (214, 172)), gcrop(made['sprite/gnome-home-big.png'], (202, 150)), gcrop(big, (202, 150))])
    # windows day | night
    row = []
    for item in window_items():
        for suf in ('', '-night'):
            p = 'scenes/hovel-window-%s%s.png' % (item, suf)
            w = made.get(p) or Image.open(os.path.join(IMG, p)).convert('RGBA')
            r = room.crop((40, 46, 120, 126)); r.alpha_composite(w, (16, 16)); row.append(r)
    tiles.append(row)
    # kettles: tin (the room) | copper | castiron | samovar
    x0, y0, w, h = KETTLE_BOX
    row = [room.crop((300, 136, 380, 196))]
    for k in KETTLES:
        r = room.copy(); r.alpha_composite(made['scenes/hovel-kettle-%s.png' % k], (x0, y0)); row.append(r.crop((300, 136, 380, 196)))
    tiles.append(row)
    # small things: steam, z, icons
    row = []
    for p in ('fx/fx-steam-a.png', 'fx/fx-steam-b.png', 'fx/fx-z-a.png', 'fx/fx-z-b.png', 'ico/ico-kettle-tin.png', 'ico/ico-kettle-copper.png', 'ico/ico-kettle-castiron.png', 'ico/ico-kettle-samovar.png', 'ico/ico-steam-cup.png'):
        t = Image.new('RGBA', (24, 24), (0x6a, 0x5a, 0x58, 255)); t.alpha_composite(made[p], ((24 - made[p].size[0]) // 2, (24 - made[p].size[1]) // 2)); row.append(t)
    tiles.append(row)
    W = max(sum(t.size[0] * S + pad for t in r) for r in tiles) + pad
    H = sum(max(t.size[1] for t in r) * S + pad for r in tiles) + pad
    sheet = Image.new('RGBA', (W, H), (0x3a, 0x30, 0x3a, 255))
    y = pad
    for r in tiles:
        x = pad
        for t in r:
            sheet.paste(t.resize((t.size[0] * S, t.size[1] * S), Image.NEAREST), (x, y)); x += t.size[0] * S + pad
        y += max(t.size[1] for t in r) * S + pad
    os.makedirs(os.path.join(ROOT, 'art-2720'), exist_ok=True)
    sheet.convert('RGB').save(os.path.join(ROOT, 'art-2720/contact.png'))


def main():
    made = {}
    for rel, im in files():
        check(im, rel)
        p = os.path.join(OUT, rel)
        os.makedirs(os.path.dirname(p), exist_ok=True)
        im.save(p)
        made[rel] = im
        if '--install' in sys.argv:
            g = os.path.join(IMG, rel)
            os.makedirs(os.path.dirname(g), exist_ok=True)
            shutil.copyfile(p, g)
    if '--list' in sys.argv:
        for rel, im in made.items(): print('%s|%d|%d' % (rel, im.size[0], im.size[1]))
    if '--contact' in sys.argv: contact(made)
    if '--list' not in sys.argv: print('%d files in %s%s' % (len(made), OUT, ', installed' if '--install' in sys.argv else ''))


if __name__ == '__main__':
    main()
