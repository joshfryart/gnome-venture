#!/usr/bin/env python3
"""Ruin pictures for the havens / wonders / delves (the 'before' of a repair). 480x270, hard pixels.

  python3 -I tools/gen_ruin_art.py [slug ...] [--out DIR]

Reads game/assets/img/wonders/<kind>-<slug>.png (the repaired look, untouched) and writes <kind>-<slug>.png
into DIR (default aseprite-source/v3/wonders/ruin/png). tools/ruin_to_aseprite.sh makes the .aseprite files.
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ruin_lib import Pic, hx, INK

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'game/assets/img/wonders')

DUSK = hx('#6a6488')      # overcast tint
MOSS = [hx('#5f7a3a'), hx('#47612f'), hx('#7a9446')]
DEADLEAF = [hx('#8a7340'), hx('#6b5a34'), hx('#a08a50')]
VOID = hx('#3a2c34')       # dark inside of a hole
VOID2 = hx('#241a28')


def dim_lights(p, box, thresh=200):
    """lit lamps / glows -> cold dark versions"""
    def f(r, g, b):
        if r > thresh and g > 150 and b < 190:
            return (0x4a, 0x3c, 0x40)
        if r > 230 and g > 200:
            return (0x6a, 0x58, 0x58)
        return None
    p.recolor(box, f)


def driftwood_tavern(p):
    import math, random, colorsys
    px = p.px

    def rm(h):
        """the colour a live-art colour becomes after the overcast remap below"""
        r, g, b = hx(h)
        hh, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        c = [round(k * 255) for k in colorsys.hsv_to_rgb(hh, min(1, s * .55), min(1, v * .86))]
        return tuple(round(c[i] * .88 + DUSK[i] * .12) for i in range(3))

    def col(x, y):
        return px[x, y][:3] if 0 <= x < p.w and 0 <= y < p.h else None

    def tone(x, y, k):
        r, g, b, a = px[x, y]
        px[x, y] = (max(0, min(255, r + k)), max(0, min(255, g + k)), max(0, min(255, b + k)), a)

    def inked(draw):
        """draw an object, then ring just that object with ink"""
        b = p.snapshot()
        draw()
        p.outline_new(b)

    def stamp(x, y, rows, pal):
        for j, row in enumerate(rows):
            for i, ch in enumerate(row):
                if ch in pal:
                    p.dot(x + i, y + j, pal[ch])

    def fill_from(box, src_x):
        x0, y0, x1, y1 = box
        for yy in range(y0, y1 + 1):
            c = px[src_x, yy]
            for xx in range(x0, x1 + 1):
                px[xx, yy] = c

    # ---- 1. lights out, overcast recolour ----------------------------------------------------------------
    def lamp(r, g, b):
        if r > 200 and g > 120 and b < 175:
            return (0x6a, 0x52, 0x4c) if g < 200 else (0x84, 0x6e, 0x62)
        return None
    for (cx, cy, r) in ((239, 118, 8), (303, 144, 6), (334, 144, 6), (381, 144, 6), (418, 144, 6)):
        for yy in range(cy - r, cy + r + 1):
            for xx in range(cx - r, cx + r + 1):
                if (xx - cx) ** 2 + (yy - cy) ** 2 <= r * r:
                    p.recolor((xx, yy, xx, yy), lamp)
    p.remap(sat=0.55, val=0.86, tint=DUSK)
    ink_rm = rm('#2b1c26')
    p.recolor((0, 0, 479, 269), lambda r, g, b: INK if (r, g, b) == ink_rm else None)   # outlines stay true ink

    # ---- 2. the turtle musician and his notes are gone: sea and sky painted back -------------------------
    def heal(box):
        """paint a box over with its surroundings: each pixel takes the nearer of the two columns beside the box"""
        x0, y0, x1, y1 = box
        for yy in range(y0, y1 + 1):
            a, b_ = px[x0 - 1, yy], px[x1 + 1, yy]
            for xx in range(x0, x1 + 1):
                px[xx, yy] = a if xx - x0 <= x1 - xx else b_
    heal((138, 157, 198, 187))
    heal((104, 140, 114, 154))
    heal((123, 158, 131, 170))
    heal((176, 128, 186, 138))
    heal((198, 146, 210, 160))
    for yy in range(186, 190):                                               # the shadow he sat in
        for xx in range(141, 181):
            px[xx, yy] = px[136, yy] if yy < 189 else px[136, 190]
    for xx in range(140, 183):                                               # stray rows just above the stump top
        for yy in (190, 191):
            if px[xx, yy][:3] != INK and px[xx, yy + 1][:3] != INK and px[xx, yy - 1][:3] == px[136, 190][:3]:
                px[xx, yy] = px[136, 190]

    # palettes (all taken from / matched to the recoloured picture)
    SAND = {rm(h) for h in ('#f2c890', '#d8a878', '#f9dca8', '#fff0c0')} | \
           {hx(h) for h in ('#c4b19f', '#a48d81', '#c9bcab', '#8c7775', '#cdc7b8')}
    SEA = {hx(h) for h in ('#585071', '#4d536f', '#665376', '#81607f', '#4d5d77', '#50677d')}
    THATCH = {hx(h) for h in ('#cdbd99', '#c2ac8c', '#b79b7e', '#8b7068', '#715a5c', '#cdbda7')}
    L2 = hx('#d8cebe')            # wind-blown crest (new lightest sand)
    S_LT, S_MID, S_DK, S_SH = hx('#c9bcab'), hx('#c4b19f'), hx('#a48d81'), hx('#8c7775')
    W_LT, W_MID, W_DK, W_SH = hx('#bda18b'), hx('#98786b'), hx('#6f545b'), hx('#453644')
    VD, VD2 = hx('#3a2e3c'), hx('#2a2030')
    RUST, RUST2 = hx('#a0624a'), hx('#7a4a44')
    M_LT, M_MID, M_DK = hx('#7f9160'), hx('#63754c'), hx('#48583e')
    is_sand = lambda x, y: col(x, y) in SAND
    is_sea = lambda x, y: col(x, y) in SEA
    is_thatch = lambda x, y: col(x, y) in THATCH and 262 <= x <= 422 and 64 <= y <= 123

    # ---- 3. sky: the pretty pink clouds turn grey, storm banks roll in ------------------------------------
    cl = {hx('#c6a7a6'): hx('#a69eb2'), hx('#cdb6a9'): hx('#bcb6c6'), hx('#bd97a2'): hx('#8e86a0'),
          hx('#b0858d'): hx('#8e86a0')}
    for box in ((150, 60, 225, 78), (345, 35, 410, 50), (40, 82, 92, 99)):
        p.recolor(box, lambda r, g, b: cl.get((r, g, b)))

    def storm(cx, cy, w, seed, h=9):
        r = random.Random(seed)
        lumps = []
        x = cx - w // 2
        while x < cx + w // 2:
            rx = r.randint(7, 13)
            t = 1 - abs((x - cx) / (w / 2.0))
            lumps.append((x, rx, max(3, int(h * (0.45 + 0.75 * t)) + r.randint(-1, 1))))
            x += rx + r.randint(0, 4)
        top = {}
        for (lx, rx, ry) in lumps:
            for xx in range(lx - rx, lx + rx + 1):
                d = 1 - ((xx - lx) / float(rx)) ** 2
                if d > 0:
                    top[xx] = min(top.get(xx, cy), cy - int(round(ry * math.sqrt(d))))
        xs = sorted(top)
        for xx in xs:
            if not (0 <= xx < 480):
                continue
            edge = min(xx - xs[0], xs[-1] - xx)
            bot = cy + (2 if edge > 10 else (1 if edge > 4 else 0))
            for yy in range(top[xx], bot + 1):
                if yy < 3 or px[xx, yy][:3] == INK:
                    continue
                if yy >= bot - 1 and edge > 4:
                    c = hx('#353048')                                       # heavy flat belly
                elif yy <= top[xx] + 1 and top.get(xx - 1, cy) >= top[xx]:
                    c = hx('#77708f')                                       # lit rim, upper left
                elif yy <= top[xx] + 3 and xx % 23 < 15:
                    c = hx('#625b7c')
                else:
                    c = hx('#4d4766')
                p.dot(xx, yy, c)
    storm(150, 27, 150, 1, 15)
    storm(318, 18, 110, 2, 11)
    storm(455, 33, 80, 3, 12)
    storm(222, 52, 84, 4, 9)
    storm(22, 36, 60, 5, 9)
    # low stratus streaks near the horizon (stepped ends, flat)
    for (sx, sy_, sw, c) in ((96, 104, 70, '#96798c'), (150, 120, 96, '#a98793'), (4, 126, 52, '#a98793'),
                             (440, 112, 40, '#96798c'), (120, 136, 60, '#b99a96')):
        cc = hx(c)
        for yy, inset in ((sy_, 8), (sy_ + 1, 0), (sy_ + 2, 5)):
            for xx in range(sx + inset, sx + sw - inset * 2):
                if 0 <= xx < 480 and px[xx, yy][:3] != INK and not (265 < xx < 440) and not (180 < xx < 236 and yy > 108) \
                        and not (20 < xx < 60):
                    p.dot(xx, yy, cc)

    # ---- 4. sea: whitecaps and a spent foam line ----------------------------------------------------------
    shore = {}
    wet = rm('#b08868')
    for x in range(480):
        for y in range(180, 198):
            if px[x, y][:3] in SAND and px[x, y - 1][:3] not in SAND and px[x, y - 1][:3] != INK:
                shore[x] = y
                break
    CAP, CAPD = hx('#b4bccb'), hx('#3d4763')
    for (x0, y0, n) in ((10, 176, 7), (62, 172, 5), (148, 178, 8), (196, 170, 5), (222, 179, 6), (126, 167, 4),
                        (20, 164, 4), (170, 161, 4), (452, 177, 7), (462, 167, 4), (250, 173, 5), (4, 169, 3),
                        (212, 163, 3), (158, 170, 5)):
        for i in range(n):
            yy = y0 - (1 if 1 <= i < n - 2 else 0)
            if is_sea(x0 + i, yy):
                p.dot(x0 + i, yy, CAP)
            if 0 < i < n and is_sea(x0 + i + 1, y0 + 1):
                p.dot(x0 + i + 1, y0 + 1, CAPD)
    r = random.Random(11)
    x = 0
    while x < 480:
        run = r.randint(5, 13)
        for i in range(run):
            xx = x + i
            if xx in shore and is_sea(xx, shore[xx] - 9):
                p.dot(xx, shore[xx] - 9 - (1 if 1 < i < run - 2 else 0), hx('#9aa9b8'))
        x += run + r.randint(4, 10)

    # ---- 5. sand: ripples, drift, strandline, pebbles (texture only, never outlined) ---------------------
    def ripples(cx, cy, n, length, seed):
        r = random.Random(seed)
        for j in range(n):
            L = length - r.randint(0, 7)
            x0 = cx - L // 2 + r.randint(-4, 4) + j * 2
            for i in range(L):
                yy = cy + j * 3 + (1 if (i < L * .22 or i > L * .8) else 0)
                if is_sand(x0 + i, yy) and is_sand(x0 + i, yy + 1):
                    tone(x0 + i, yy, -17)
                    tone(x0 + i, yy + 1, 9)
    for (cx, cy, n, L, sd) in ((112, 207, 3, 22, 1), (30, 204, 3, 18, 2), (228, 224, 4, 24, 3), (332, 246, 4, 30, 4),
                               (410, 252, 3, 24, 5), (458, 203, 3, 16, 6), (150, 258, 2, 26, 7), (96, 232, 3, 18, 8),
                               (262, 258, 2, 20, 9), (386, 232, 2, 18, 10), (16, 226, 2, 16, 12)):
        ripples(cx, cy, n, L, sd)

    def drift(x0, y0, L, h=2):
        """lee-side tail of blown sand: light lens, darker foot"""
        for i in range(L):
            t = i / float(L)
            hh = max(1, int(round(h * (1 - t) ** .7)))
            for k in range(hh):
                if is_sand(x0 + i, y0 - k) or col(x0 + i, y0 - k) == S_SH:
                    p.dot(x0 + i, y0 - k, L2 if k == hh - 1 else S_LT)
            if is_sand(x0 + i, y0 + 1) and i % 7 < 5:
                p.dot(x0 + i, y0 + 1, S_DK)
    for (dx, dy, L, h) in ((70, 258, 22, 3), (192, 252, 14, 2), (218, 258, 12, 2), (258, 252, 10, 2), (296, 258, 14, 2),
                           (332, 246, 0, 2), (468, 228, 10, 2), (12, 232, 0, 2)):
        if L:
            drift(dx, dy, L, h)

    # strandline: clumps of dark weed left where the last tide stopped, with a few pale floats
    WEED, WEED2, WEED3 = hx('#4c5542'), hx('#6c7654'), hx('#7a5560')
    r = random.Random(21)
    x = 2
    while x < 478:
        L = r.randint(4, 12)
        dy = r.choice((4, 4, 5, 5, 6))
        kind = r.random()
        for i in range(L):
            xx = x + i
            if xx not in shore:
                continue
            yy = shore[xx] + dy + (1 if i in (0, L - 1) and L > 4 else 0)
            if is_sand(xx, yy):
                p.dot(xx, yy, WEED3 if kind < .18 else WEED)
                if 0 < i < L - 1 and L > 5 and i % 4 != 0 and is_sand(xx, yy - 1):
                    p.dot(xx, yy - 1, WEED2)
                if is_sand(xx + 1, yy + 1) and i % 2:
                    p.dot(xx + 1, yy + 1, S_SH)
        if kind > .8 and x + L + 1 in shore and is_sand(x + L + 1, shore[x + L + 1] + dy):
            p.dot(x + L + 1, shore[x + L + 1] + dy, hx('#e2dcd4'))        # float / shell chip
        x += L + r.choice((1, 2, 2, 3, 5, 8, 13))

    PEB = [hx('#857c8e'), hx('#6c6378'), hx('#a79fac'), hx('#9a8478')]

    def pebbles(cx, cy, n, seed, sx=7, sy_=2.5, shells=1):
        r = random.Random(seed)
        for k in range(n):
            x = cx + int(round(r.gauss(0, sx / 2.0)))
            y = cy + int(round(r.gauss(0, sy_ / 2.0)))
            w = r.choice((1, 2, 2, 3))
            c = r.choice(PEB) if k >= shells else r.choice([hx('#e0d9d0'), hx('#c9a2a6')])
            if not all(is_sand(x + i, y + j) for i in range(-1, w + 2) for j in (-1, 0, 1)):
                continue
            for i in range(w):
                p.dot(x + i, y, c)
            if w == 3:
                p.dot(x + 1, y - 1, c)
            if w >= 2 and k >= shells:
                tone(x, y, 22)
            for i in range(1, w + 1):
                p.dot(x + i, y + 1, S_SH)
    for (cx, cy, n, sd) in ((100, 222, 7, 1), (228, 240, 6, 2), (312, 236, 7, 3), (374, 252, 8, 4), (436, 224, 6, 5),
                            (24, 216, 5, 6), (176, 262, 6, 7), (286, 262, 5, 8), (250, 208, 5, 9), (448, 258, 5, 10),
                            (84, 250, 5, 11), (404, 240, 4, 12)):
        pebbles(cx, cy, n, sd)

    # sand piled by the wind against the counter (windward left end highest)
    bumps = ((274, 15, 9), (316, 12, 3), (352, 20, 5), (402, 14, 4), (432, 10, 6))
    for x in range(256, 446):
        h = max([hh * (1 - ((x - c) / float(w)) ** 2) for (c, w, hh) in bumps] + [0])
        h = int(round(h))
        if h <= 0:
            continue
        for y in range(215 - h, 216):
            if px[x, y][:3] == INK and y < 207:
                continue
            p.dot(x, y, L2 if y == 215 - h else (S_LT if y < 214 else S_MID))
    for x in range(262, 290):                                                # lee shadow tucked under the big heap
        if is_sand(x, 216) and x % 9 < 6:
            p.dot(x, 216, S_DK)

    # ---- 6. roof: thatch courses, holes with rafters, moss, a sagging eave ------------------------------
    for y in range(83, 119):                                                 # the shell is gone: thatch where it sat
        for x in range(334, 372):
            if px[x, y][:3] not in THATCH or 84 <= y <= 111 or (344 <= x <= 361 and y >= 108):
                px[x, y] = px[x - 38, y] if px[x - 38, y][:3] in THATCH else px[x - 38, y - 3]
    r = random.Random(31)
    for ty in (76, 87, 98, 109):                                             # overlapping straw courses
        x = 264
        while x < 422:
            run = r.randint(7, 17)
            off = r.choice((0, 0, 1, -1))
            for i in range(run):
                xx, yy = x + i, ty + off + (1 if i > run - 3 else 0)
                if is_thatch(xx, yy):
                    tone(xx, yy, -36)
                    if r.random() < .38:
                        for k in range(1, r.choice((2, 2, 3, 4))):
                            if is_thatch(xx, yy + k):
                                tone(xx, yy + k, -36)
            x += run + r.randint(2, 5)
    for (tx, ty, n) in ((282, 96, 4), (306, 70, 5), (326, 104, 4), (378, 72, 5), (392, 104, 4), (410, 92, 3),
                        (290, 114, 5), (318, 84, 3), (384, 92, 4), (274, 108, 3), (400, 114, 4)):
        for i in range(n):                                                   # tufts of loose straw
            L = 2 + (i * 5 + tx) % 4
            for k in range(L):
                if is_thatch(tx + i * 2, ty + k):
                    tone(tx + i * 2, ty + k, 16 if i % 2 == 0 else -30)
    # the big hole where the shell crashed through
    hole = [(334, 99), (338, 93), (337, 89), (343, 88), (347, 83), (353, 85), (360, 81), (365, 85), (371, 87), (371, 93),
            (376, 98), (372, 103), (374, 109), (367, 110), (364, 115), (357, 113), (351, 117), (346, 112), (340, 112),
            (340, 105)]
    for x in range(333, 378, 4):                                             # damp running down from the hole
        for k in range(4 + (x * 5) % 9):
            for dx in (0, 1):
                if is_thatch(x + dx, 108 + k):
                    tone(x + dx, 108 + k, -20)
    for x in range(298, 316, 4):
        for k in range(3 + (x * 3) % 6):
            if is_thatch(x, 92 + k):
                tone(x, 92 + k, -20)
    p.poly(hole, VD, INK)
    p.poly([(344, 96), (349, 91), (359, 90), (366, 94), (366, 103), (358, 108), (349, 108), (344, 103)], VD2)
    HOLE = (VD, VD2)
    for y in range(78, 121):                                                 # purlin + two rafters seen through it
        for x in range(332, 378):
            if px[x, y][:3] in HOLE:
                if False:
                    p.dot(x, y, W_MID if y == 92 else W_DK)
    for y in range(78, 121):
        for x0 in (350, 365):
            x = x0 + (y - 78) // 14
            for i, c in ((0, W_LT), (1, W_MID), (2, W_DK)):
                if px[x + i, y][:3] in HOLE + (W_MID, W_DK) and not (x0 == 365 and y > 104):
                    p.dot(x + i, y, c)
    for (x, y) in ((366, 105), (367, 106), (368, 105), (366, 107)):          # the right rafter is snapped
        if px[x, y][:3] in HOLE:
            p.dot(x, y, W_MID)
    r = random.Random(32)
    for x in range(334, 376):                                                # straw fringe hanging into the hole
        for y in range(78, 100):
            if px[x, y][:3] in HOLE + (W_LT, W_MID, W_DK) and px[x, y - 1][:3] == INK:
                for k in range(r.choice((1, 1, 2, 2, 3, 4)) if (x // 3) % 3 else 0):
                    p.dot(x, y + k, hx('#c2ac8c') if (x + k) % 3 else hx('#b79b7e'))
                break
    for x in range(340, 368, 3):                                             # stubble along the lower lip
        for y in range(121, 104, -1):
            if px[x, y][:3] in HOLE and px[x, y + 1][:3] == INK:
                p.dot(x, y, hx('#8b7068'))
                if x % 2:
                    p.dot(x, y - 1, hx('#8b7068'))
                break
    # smaller hole, left: a ragged slit
    p.poly([(297, 87), (303, 82), (311, 84), (316, 88), (311, 90), (308, 95), (302, 92)], VD, INK)
    p.poly([(303, 86), (310, 86), (307, 91), (304, 90)], VD2)
    for x in (302, 304, 307, 309, 312):
        if px[x, 84 + (x % 2)][:3] in HOLE:
            p.dot(x, 84 + (x % 2), hx('#c2ac8c'))
            p.dot(x, 85 + (x % 2), hx('#b79b7e'))
    # torn corner top right: open sky shows
    bite = [(398, 64), (414, 64), (417, 82), (410, 80), (407, 74), (401, 73)]
    b = p.snapshot()
    p.poly(bite, (1, 2, 3))
    newpix = [(x, y) for y in range(62, 84) for x in range(396, 420) if px[x, y][:3] == (1, 2, 3)]
    for (x, y) in newpix:
        px[x, y] = b.getpixel((x, y)) if b.getpixel((x, y))[:3] not in THATCH and b.getpixel((x, y))[:3] != INK \
            and not (b.getpixel((x, y))[0] > 100 and b.getpixel((x, y))[0] > b.getpixel((x, y))[2] + 20) else px[430, y]
    for (x, y) in newpix:
        for (ax, ay) in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            if (ax, ay) not in newpix and b.getpixel((ax, ay))[:3] in THATCH | {hx('#56454f')}:
                p.dot(ax, ay, INK)
    for (x, y, L) in ((400, 74, 3), (404, 75, 2), (409, 81, 3), (413, 82, 2)):   # straw stubs sticking into the gap
        for k in range(L):
            p.dot(x, y - k, hx('#b79b7e'))

    # moss: soft clumps gathered where the damp sits (shaded, not sprinkled)
    def mossclump(cx, cy, rx, ry, seed, test=is_thatch):
        r = random.Random(seed)
        parts = [(cx, cy, rx, ry)] + [(cx + r.randint(-rx, rx), cy + r.choice((-1, 0, 1)), max(2, rx // 2 + r.randint(0, 2)),
                                       max(1, ry - r.randint(0, 1))) for _ in range(2)]
        pts = set()
        for (ax, ay, arx, ary) in parts:
            for y in range(ay - ary, ay + ary + 1):
                for x in range(ax - arx, ax + arx + 1):
                    if ((x - ax) / float(arx)) ** 2 + ((y - ay) / float(ary)) ** 2 <= 1.05 and test(x, y):
                        pts.add((x, y))
        for (x, y) in pts:
            if (x, y - 1) not in pts or ((x - 1, y) not in pts and (x, y + 1) in pts):
                c = M_LT
            elif (x, y + 1) not in pts or (x + 1, y) not in pts:
                c = M_DK
            else:
                c = M_MID
            p.dot(x, y, c)
    for (cx, cy, rx, ry, sd) in ((298, 70, 9, 2, 1), (286, 103, 8, 3, 3), (386, 80, 7, 2, 4), (380, 113, 9, 3, 6),
                                 (308, 116, 7, 2, 7), (412, 99, 5, 3, 8), (324, 100, 5, 2, 5)):
        mossclump(cx, cy, rx, ry, sd)

    # ---- 7. awning: three tears, tatters, folds, stains --------------------------------------------------
    AWN = {px[x, y][:3] for x in range(274, 416) for y in range(125, 136)} - {INK} - THATCH
    A_R, A_RD, A_W, A_WD = hx('#bd7985'), hx('#86556d'), hx('#cdc7bf'), hx('#a79fa3')

    def tear(x0, x1, jag):
        for y in range(124, 139):
            a = x0 + jag[(y * 3) % len(jag)]
            b_ = x1 - jag[(y * 5 + 2) % len(jag)]
            for x in range(a, b_ + 1):
                if px[x, y][:3] in AWN or (y <= 137 and px[x, y][:3] == INK and y > 124):
                    p.dot(x, y, VD2 if y < 130 else VD)
            if y < 137:
                p.dot(a - 1, y, INK)
                p.dot(b_ + 1, y, INK)
    p.rect(354, 124, 373, 138, VD)                                           # where the party hat sat
    tear(322, 337, (0, 1, 2, 1, 0, 2))
    tear(353, 374, (0, 2, 1, 3, 1, 0))
    # folds + stains on what is left of the cloth
    for (fx, fy, L, dx) in ((290, 126, 9, 0), (311, 125, 10, 1), (342, 126, 9, -1), (347, 125, 10, 0), (381, 126, 9, 1),
                            (390, 125, 10, -1), (413, 126, 8, 0), (278, 127, 7, 1)):
        for k in range(L):
            xx = fx + (dx * k) // 4
            if px[xx, fy + k][:3] in AWN:
                tone(xx, fy + k, -30)
                if px[xx - 1, fy + k][:3] in AWN and k % 3:
                    tone(xx - 1, fy + k, 10)
    for (sx, sy_, w, h) in ((296, 131, 6, 3), (383, 130, 5, 4), (412, 131, 4, 3), (341, 131, 5, 3)):
        for y in range(sy_, sy_ + h):
            for x in range(sx + (y - sy_) % 2, sx + w - (1 if y == sy_ else 0)):
                if px[x, y][:3] in AWN:
                    tone(x, y, -20)

    def tatters():
        # (points, colour, shade)
        for (pts, c, cd) in (([(317, 137), (322, 137), (323, 151), (321, 157), (319, 150), (318, 143)], A_R, A_RD),
                             ([(348, 137), (353, 137), (352, 146), (350, 142)], A_W, A_WD),
                             ([(375, 137), (380, 137), (379, 150), (377, 154), (376, 145)], A_R, A_RD)):
            p.poly(pts, c)
            xs = [q[0] for q in pts]
            for y in range(138, max(q[1] for q in pts) + 1):
                for x in range(min(xs), max(xs) + 1):
                    if px[x, y][:3] == c and (px[x + 1, y][:3] != c or (y % 5 == 0)):
                        p.dot(x, y, cd)                                      # shaded right side + cross creases
    # (tatters are drawn after the wall is rebuilt, see below)

    # ---- 8. back wall behind where the crab stood, shelf, counter top -------------------------------------
    PL, PM, PD, SEAM = rm('#c8784c'), rm('#a9614b'), rm('#8a4a4a'), rm('#34223c')
    r = random.Random(41)

    def planks(x0, y0, x1, y1):
        for x in range(x0, x1 + 1):
            m = (x - 296) % 7
            streak = (x * 7 + 3) % 11
            for y in range(y0, y1 + 1):
                if m == 0:
                    c = SEAM
                elif m == 6:
                    c = PD
                elif m == 1 and (y + x) % 9 < 5:
                    c = PL
                elif streak < 2 and (y + x * 3) % 13 < 7:
                    c = PD
                else:
                    c = PM
                p.dot(x, y, c)
    planks(341, 138, 373, 147)
    planks(326, 151, 382, 169)
    p.rect(341, 137, 373, 137, INK)
    shelf = px[320, 148][:3]
    p.rect(326, 148, 382, 148, shelf)
    p.rect(326, 149, 382, 150, INK)
    for x in range(326, 383):
        if (x // 5) % 3:
            p.dot(x, 150, PD)
    # one plank fallen out (dark gap), one slipped
    p.rect(359, 151, 364, 169, VD2)
    p.line([(358, 151), (358, 169)], INK)
    p.line([(365, 151), (365, 169)], INK)
    for (x, y) in ((359, 166), (360, 165), (361, 167), (362, 164), (363, 166), (364, 165)):
        for yy in range(y, 170):
            p.dot(x, yy, PM if yy > y else PL)                               # splintered stub
    # counter top restored where the crab's menu lay
    for x in range(340, 371):
        sx = 373 + (x - 340) % 16
        for y in range(170, 178):
            px[x, y] = px[sx, y]
    # nails with rust weeping down the wall planks
    for (nx, ny, L) in ((329, 153, 3), (336, 166, 2), (343, 140, 2), (350, 155, 4), (371, 153, 3), (378, 164, 2),
                        (347, 165, 2), (368, 141, 2), (392, 153, 3), (313, 154, 3), (406, 158, 2), (298, 156, 2)):
        if px[nx, ny][:3] in (PM, PL, PD):
            p.dot(nx, ny, hx('#b9ada6'))
            for k in range(1, L + 1):
                if px[nx, ny + k][:3] in (PM, PL, PD):
                    p.dot(nx, ny + k, RUST2 if k > 1 else RUST)
    # knots
    for (kx, ky) in ((332, 160), (353, 164), (376, 157), (345, 143)):
        p.dot(kx, ky, SEAM); p.dot(kx + 1, ky, SEAM); p.dot(kx, ky + 1, PD); p.dot(kx - 1, ky, PL)
    tatters_before = p.snapshot()
    tatters()
    p.outline_new(tatters_before)
    # a bottle knocked over on the shelf, a dead lantern hanging by one hook
    inked(lambda: (p.rect(367, 145, 373, 146, hx('#7d9a94')), p.dot(374, 145, hx('#9a8478')), p.dot(368, 145, hx('#a9c2ba'))))
    WEB = hx('#d2d0dc')

    def web(x, y, s, fx=1):
        ends = [(s, 1), (s - 2, s // 2), (s // 2, s - 1), (1, s)]
        for (ex, ey) in ends:
            p.line([(x, y), (x + fx * ex, y + ey)], WEB)
        for f in (.5, .9):
            p.line([(x + fx * int(ex * f), y + int(ey * f)) for (ex, ey) in ends], WEB)
    web(290, 138, 10)
    web(431, 151, 8, -1)

    # ---- 9. counter front: weathered boards -------------------------------------------------------------
    CF = {W_LT, hx('#aa8c7b'), hx('#b09485')}
    CS = {hx('#5a4550'), W_DK, W_MID}
    r = random.Random(51)
    for _ in range(46):                                                      # grain: short streaks along the boards
        x, y = r.randint(278, 430), r.choice((176, 177, 178, 182, 183, 184, 185, 186, 190, 192, 193, 197, 199, 200, 204, 205))
        L = r.randint(4, 11)
        k = r.choice((-16, -16, 12))
        for i in range(L):
            c = col(x + i, y)
            if c in CF:
                tone(x + i, y, k)
            elif c in CS:
                tone(x + i, y, 12 if k > 0 else -12)
    for x in (285, 313, 342, 371, 400, 428):                                 # nail heads at the seams, rust runs
        for y in (176, 184, 191, 198):
            if col(x + 2, y) in CF | CS | {hx('#453644')}:
                lit = col(x + 2, y) in CF
                p.dot(x + 2, y, hx('#4a3a44') if lit else hx('#8a7a7a'))
                if (x + y) % 3 != 1:
                    for k in range(1, 2 + (x + y) % 3):
                        if col(x + 2, y + k) in CF | CS:
                            p.dot(x + 2, y + k, RUST if lit else RUST2)
    # a board stove in
    p.poly([(316, 189), (320, 188), (336, 188), (339, 190), (337, 194), (333, 193), (322, 194), (318, 193)], VD2, INK)
    for (x, y) in ((320, 190), (321, 191), (335, 192), (334, 191), (327, 193)):
        p.dot(x, y, W_MID)
    # a board prised loose, hanging by one nail
    inked(lambda: (p.poly([(383, 181), (386, 179), (404, 195), (401, 198)], W_LT),
                   p.line([(385, 182), (401, 196)], hx('#aa8c7b')),
                   p.line([(384, 182), (400, 197)], W_MID),
                   p.dot(386, 182, hx('#4a3a44'))))
    p.rect(384, 181, 398, 186, VD2) if False else None
    # barnacles in a crust low on the left
    for (bx, by) in ((281, 200), (284, 202), (287, 199), (290, 203), (294, 201), (283, 205), (298, 204), (425, 203), (429, 201), (422, 205)):
        if col(bx, by) not in (S_LT, S_MID, L2, INK):
            p.dot(bx, by, hx('#cfc9c2')); p.dot(bx + 1, by, hx('#8f8890')); p.dot(bx, by + 1, hx('#8f8890'))
    for (cx, cy, rx, ry, sd) in ((300, 206, 6, 2, 21), (418, 206, 5, 2, 22), (276, 176, 3, 1, 23)):
        mossclump(cx, cy, rx, ry, sd, test=lambda x, y: col(x, y) in CF | CS | {hx('#453644'), W_SH})

    # ---- 10. sagging eave + hanging thatch + vines ------------------------------------------------------
    def sag():
        r = random.Random(61)
        for x in range(372, 419):
            s = int(round(6 * math.sin(math.pi * (x - 372) / 46.0)))
            for y in range(124, 124 + s):
                c = hx('#8b7068')
                if y >= 124 + s - 2:
                    c = hx('#715a5c')
                elif y == 124 and x % 5 < 3:
                    c = hx('#b79b7e')
                p.dot(x, y, c)
            if s > 1 and x % 3 == 0:
                for k in range(r.randint(1, 3)):
                    p.dot(x, 124 + s + k, hx('#8b7068'))
    inked(sag)
    for x in range(375, 417):
        if px[x, 123][:3] == INK:
            p.dot(x, 123, hx('#715a5c') if x % 4 else hx('#8b7068'))
    def tufts():
        for (x, L) in ((268, 4), (271, 6), (274, 3), (296, 3), (299, 5), (345, 4), (348, 2)):
            for k in range(L):
                p.dot(x, 124 + k, hx('#8b7068') if k % 3 else hx('#b79b7e'))
    inked(tufts)
    r = random.Random(62)
    for (vx, vy, L) in ((287, 124, 30), (431, 126, 22), (305, 119, 9)):
        cx = vx
        for i in range(L):
            if r.random() < .3:
                cx = max(vx - 2, min(vx + 2, cx + r.choice((-1, 1))))
            p.dot(cx, vy + i, M_DK)
            if i % 4 == 2:
                s = 1 if (i // 4) % 2 else -1
                p.dot(cx + s, vy + i, M_LT); p.dot(cx + 2 * s, vy + i, M_MID); p.dot(cx + s, vy + i - 1, M_MID)

    # ---- 11. palms: dead, with a broken frond hanging --------------------------------------------------
    def dead(r_, g, b):
        if g > r_ and g > b:
            return (r_ + 40, g - 10, b - 10) if g < 170 else (r_ + 60, g - 20, b)
        return None
    p.recolor((380, 88, 472, 132), dead)
    p.recolor((6, 38, 88, 102), dead)
    F_LT, F_MID, F_DK = hx('#b7a27a'), hx('#96815e'), hx('#6e5c48')

    def frond(pts, leaf, side=0, hang=False):
        """dry frond: spine through pts with leaflets (side 0 = both)"""
        n = 0
        for (a, b_) in zip(pts, pts[1:]):
            steps = max(abs(b_[0] - a[0]), abs(b_[1] - a[1]))
            for i in range(steps):
                x = a[0] + (b_[0] - a[0]) * i // steps
                y = a[1] + (b_[1] - a[1]) * i // steps
                n += 1
                if n % 3 == 0:
                    L = max(2, leaf - n // 9)
                    for k in range(1, L + 1):
                        if hang:
                            p.dot(x + (k // 3), y + k, F_MID if n % 6 else F_LT)
                        else:
                            if side >= 0:
                                p.dot(x - k // 2, y - k, F_LT if n % 6 else F_MID)
                            if side <= 0:
                                p.dot(x - k // 2, y + k, F_MID)
        p.line(pts, F_DK)

    def leaf(a, b_, w, step=3):
        """a dry frond as one serrated blade from stem a to tip b_ (light upper side, dark lower, spine)"""
        ax, ay = a
        bx, by = b_
        L = math.hypot(bx - ax, by - ay)
        ux, uy = (bx - ax) / L, (by - ay) / L
        nx, ny = -uy, ux
        n = int(L // step)
        top, bot, mid = [], [], []
        for i in range(n + 1):
            t = i / float(n)
            hw = w * math.sqrt(max(0, 4 * t * (1 - t))) * (1 if i % 2 else .5) + .5
            mx, my = ax + ux * t * L, ay + uy * t * L
            mid.append((int(round(mx)), int(round(my))))
            top.append((int(round(mx - nx * hw)), int(round(my - ny * hw))))
            bot.append((int(round(mx + nx * hw)), int(round(my + ny * hw))))
        p.poly(top + mid[::-1], F_LT)
        p.poly(bot + mid[::-1], F_MID)
        p.line(mid, F_DK)
    inked(lambda: leaf((50, 68), (60, 100), 4))
    inked(lambda: leaf((431, 118), (423, 146), 4))

    # ---- 12. the lamp post leans, its lamp dead; the bunting has snapped ---------------------------------
    for y in range(100, 128):
        for x in range(230, 250):
            px[x, y] = px[229, y]
    for y in range(128, 200):
        for x in range(236, 244):
            px[x, y] = px[244, y]
    for y in range(200, 218):
        for x in range(237, 243):
            px[x, y] = px[244, y]
    for y in range(102, 124):
        for x in range(250, 262):
            if px[x, y][:3] != INK or True:
                px[x, y] = px[249, y]
    p.line([(232, 214), (247, 214)], S_SH)                                   # shadow at the foot
    def post():
        p.poly([(238, 216), (241, 216), (252, 134), (249, 134)], W_MID)
        p.line([(239, 215), (250, 135)], W_LT)
        p.line([(241, 215), (252, 135)], W_DK)
        for y in (150, 172, 196):                                            # rope lashings
            xx = 239 + (216 - y) * 11 // 82
            p.rect(xx - 1, y, xx + 3, y + 1, hx('#b3a48a'))
            p.dot(xx + 2, y + 1, hx('#8a7c66'))
        # dead lantern head, cracked pane
        p.rect(246, 121, 256, 133, hx('#5c5058'))
        p.rect(248, 123, 254, 131, hx('#8a8494'))
        p.rect(248, 123, 250, 126, hx('#a9a5b4'))
        p.line([(254, 124), (250, 128), (252, 131)], hx('#3d3340'))
        p.rect(247, 119, 255, 120, hx('#77686a'))
        p.rect(249, 117, 253, 118, hx('#5c5058'))
    inked(post)
    def bunting():
        p.line([(263, 121), (264, 128), (263, 140)], hx('#6b574f'))
        for (x, y, c) in ((264, 126, '#b98a94'), (263, 132, '#7fa3ad'), (264, 138, '#b98a94')):
            p.rect(x, y, x + 2, y + 2, hx(c)); p.dot(x + 2, y + 2, hx('#6b574f'))
    bunting()
    # gull on the dead lamp
    G = {'W': hx('#e6e2e2'), 'G': hx('#9a98a8'), 'D': hx('#6e6c80'), 'Y': hx('#d6a04e'), 'K': INK, 'O': hx('#c9824e'),
         'S': hx('#c2bcc2')}
    inked(lambda: stamp(244, 106, ['..WW......',
                                   '.WKWW.....',
                                   'YYWWW.....',
                                   '.WWWWWW...',
                                   '.WWGGGGGW.',
                                   '.SWGGGGDDD',
                                   '..SWWWWD..',
                                   '...SSS....'], G))
    p.dot(248, 115, G['O']); p.dot(251, 115, G['O']); p.dot(248, 116, G['O']); p.dot(251, 116, G['O'])

    # ---- 13. left beach ----------------------------------------------------------------------------------
    # stump where the musician sat: net thrown over the corner, cracks, a seedling in the moss
    for (x0, y0, L) in ((158, 203, 15), (176, 210, 12), (150, 222, 10)):
        p.crack(x0, y0, L, col=hx('#3a2e3c'))
    NET, NETD = hx('#c2b8a6'), hx('#8f8676')

    rope = [(146, 192), (152, 198), (160, 204), (170, 209), (180, 211), (187, 208), (191, 201)]
    p.line([(x, y + 1) for (x, y) in rope], hx('#4d3c48'))
    inked(lambda: p.line(rope, NET, 2)) if False else p.line(rope, NET)
    for i, (a, b_) in enumerate(zip(rope, rope[1:])):                        # twist marks along the rope
        p.dot((a[0] + b_[0]) // 2, (a[1] + b_[1]) // 2, NETD)
    p.line([(165, 207), (165, 210)], NETD); p.line([(182, 211), (182, 215)], NETD)
    inked(lambda: (p.ell(165, 213, 2, 2, hx('#b0705e')), p.dot(164, 212, hx('#d39a86')),
                   p.ell(182, 218, 2, 2, hx('#b0705e')), p.dot(181, 217, hx('#d39a86'))))       # cork floats
    SG, SGL = hx('#5d8a46'), hx('#8fb866')
    p.line([(152, 191), (152, 184)], SG)                                     # seedling on the stump
    stamp(148, 181, ['.LL...LL.', 'LLLS.SLLL', '.LLSSSL..', '....S....'], {'L': SGL, 'S': SG})
    # table: rust weeps down the leg, a web strung under the top
    for (x, y) in ((212, 216), (212, 217), (213, 221), (212, 226), (212, 227), (213, 233)):
        if col(x, y) not in (INK,):
            p.dot(x, y, RUST)
    for (x, y) in ((196, 204), (197, 205), (224, 206), (229, 204), (230, 205)):
        p.dot(x, y, RUST)
    web(214, 214, 8)
    # fallen lantern + its glass, by the foot of the post
    p.line([(249, 236), (260, 236)], S_SH); p.line([(251, 237), (260, 237)], S_SH)
    inked(lambda: stamp(247, 229, ['....DDDDDD.',
                                   '.HH.DLLPPD.',
                                   'H..HDLPPPDH',
                                   'H..HDPPPPDH',
                                   '.HH.DPPPPD.',
                                   '....DDDDDD.'], {'D': hx('#5c5058'), 'P': hx('#8a8494'), 'L': hx('#b7b3c2'), 'H': hx('#77686a')}))
    for (gx, gy) in ((262, 234), (265, 236), (263, 239), (268, 234), (267, 238)):
        if is_sand(gx, gy):
            p.dot(gx, gy, hx('#b9d2d2')); p.dot(gx + 1, gy + 1, S_SH)
    # coconuts shaken down, in a huddle, each with its shadow
    for (cx, cy) in ((64, 217), (72, 221), (58, 223)):
        p.rect(cx - 1, cy + 3, cx + 5, cy + 4, S_SH)
    def nuts():
        for (cx, cy) in ((64, 217), (72, 221), (58, 223)):
            p.ell(cx, cy, 3, 3, hx('#6e5248'))
            p.rect(cx - 2, cy - 2, cx - 1, cy - 1, hx('#9a7a68'))
            p.dot(cx + 1, cy + 2, hx('#4d3c40')); p.dot(cx + 2, cy + 1, hx('#4d3c40'))
            p.dot(cx, cy - 3, hx('#3a2e3c'))
    inked(nuts)
    # a frond snapped off and lying on the sand
    for i in range(34):
        if is_sand(82 + i, 217 + i // 7):
            p.dot(82 + i, 217 + i // 7, S_SH)
    inked(lambda: leaf((114, 216), (78, 209), 6))
    # the log: weed thrown over it, barnacle crusts, sand banked behind
    def weedpatch(x0, y0, w, drops, seed):
        r = random.Random(seed)
        for i in range(w):
            L = drops[i % len(drops)]
            for k in range(L):
                if col(x0 + i, y0 + k) != INK or k == 0:
                    p.dot(x0 + i, y0 + k, M_LT if k == 0 and i % 3 else (M_DK if k >= L - 1 else M_MID))
    weedpatch(8, 236, 13, (3, 5, 4, 7, 3, 2, 6, 4), 1)
    weedpatch(40, 236, 9, (2, 4, 6, 3, 5, 2), 2)
    for (bx, by) in ((26, 246), (29, 248), (25, 250), (31, 245), (52, 252), (55, 250), (50, 249), (6, 254), (9, 256), (12, 253)):
        p.dot(bx, by, hx('#d6d0c8')); p.dot(bx + 1, by, hx('#8f8890')); p.dot(bx, by + 1, hx('#8f8890'))
    # tiny crab scuttling along the strandline: somebody still lives here
    C = {'R': hx('#c97662'), 'L': hx('#e09a80'), 'K': INK, 'D': hx('#9a5650')}
    p.line([(119, 204), (127, 204)], S_SH)
    inked(lambda: stamp(117, 198, ['L.K.K.L',
                                   'LLRLRLL',
                                   '.RRRRR.',
                                   '.D.D.D.'], C))

    # ---- 14. right beach ---------------------------------------------------------------------------------
    # the roof shell, fallen and split in two
    SH_L, SH_M, SH_D = hx('#d9b3ba'), hx('#bd8c9c'), hx('#93687e')
    p.line([(292, 240), (310, 240)], S_SH); p.line([(294, 241), (310, 241)], S_SH)
    p.line([(316, 237), (324, 237)], S_SH)
    def shell():
        p.poly([(288, 238), (290, 231), (296, 227), (303, 228), (306, 233), (303, 236), (305, 239)], SH_M)
        for (a, b_) in (((290, 236), (294, 229)), ((295, 238), (298, 229)), ((300, 238), (302, 230))):
            p.line([a, b_], SH_L)
        p.line([(292, 238), (304, 238)], SH_D); p.line([(304, 232), (304, 236)], SH_D)
        p.poly([(313, 235), (315, 230), (320, 229), (322, 233), (319, 235)], SH_M)
        p.line([(315, 234), (317, 230)], SH_L); p.dot(321, 234, SH_D); p.dot(320, 235, SH_D)
    inked(shell)
    # loose boards with nails, one propped against the counter (the snapped awning pole)
    p.line([(336, 228), (366, 225)], S_SH); p.line([(338, 229), (366, 226)], S_SH)
    def boards():
        p.poly([(334, 222), (362, 218), (364, 222), (336, 226)], W_LT)
        p.line([(336, 225), (363, 221)], W_MID)
        p.line([(340, 223), (352, 221)], hx('#aa8c7b'))
        p.dot(338, 223, hx('#4a3a44')); p.dot(360, 220, hx('#4a3a44')); p.dot(360, 221, RUST)
    inked(boards)
    def pole():
        p.poly([(262, 213), (265, 214), (277, 180), (274, 179)], W_MID)
        p.line([(263, 213), (275, 180)], W_LT)
        p.line([(265, 213), (277, 181)], W_DK)
        p.rect(272, 185, 277, 186, hx('#b3a48a'))
    inked(pole)
    # coconut cup with a hermit crab moved in
    p.line([(349, 242), (360, 242)], S_SH)
    def cup():
        p.ell(353, 238, 5, 3, hx('#6e5248'))
        p.line([(349, 236), (356, 235)], hx('#9a7a68'))
        p.rect(348, 233, 350, 235, C['R']); p.dot(349, 233, C['L'])
        p.dot(347, 236, C['R']); p.dot(346, 237, C['R'])
    inked(cup)
    p.dot(348, 231, INK); p.dot(350, 231, INK); p.dot(348, 232, C['L']); p.dot(350, 232, C['L'])
    # a bottle half buried
    p.line([(418, 244), (428, 244)], S_SH)
    inked(lambda: (p.poly([(414, 243), (417, 238), (422, 236), (424, 239), (420, 243)], hx('#6f8f88')),
                   p.line([(417, 240), (421, 238)], hx('#a3bfb6')), p.rect(423, 235, 425, 236, hx('#57726e'))))
    for x in range(411, 424):
        p.dot(x, 244, S_LT if x % 4 else L2)
    # seedling pushing up through the drift at the counter's corner
    p.line([(378, 211), (378, 206)], SG)
    stamp(375, 203, ['LL..LL.', '.LS.SLL', '..SSS..'], {'L': SGL, 'S': SG})
    # a coconut at the foot of the right palm
    p.rect(446, 253, 452, 254, S_SH)
    inked(lambda: (p.ell(446, 249, 3, 3, hx('#6e5248')), p.rect(444, 247, 445, 248, hx('#9a7a68'))))


SPECS = {
    'haven-driftwood-tavern': driftwood_tavern,
}


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    out = os.path.join(ROOT, 'aseprite-source/v3/wonders/ruin/png')
    if '--out' in sys.argv:
        out = sys.argv[sys.argv.index('--out') + 1]
        args = [a for a in args if a != out]
    os.makedirs(out, exist_ok=True)
    specs = dict(SPECS)
    import importlib.util, glob
    for f in sorted(glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'ruin_places', '*.py'))):
        slug = os.path.basename(f)[:-3]               # tools/ruin_places/<kind>-<slug>.py defines build(p)
        spec = importlib.util.spec_from_file_location('ruin_' + slug.replace('-', '_'), f)
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        specs[slug] = mod.build
    for slug, fn in specs.items():
        if args and slug not in args:
            continue
        p = Pic(os.path.join(SRC, slug + '.png'))
        fn(p)
        p.save(os.path.join(out, slug + '.png'))
        print('wrote', slug)


if __name__ == '__main__':
    main()
