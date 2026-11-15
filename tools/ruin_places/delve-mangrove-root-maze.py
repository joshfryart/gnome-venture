"""Ruined Mangrove Root Maze: the frog keeper is gone, the lantern fell, an arch root snapped into the stagnant water."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from ruin_lib import Pic, hx, INK

import math, random, colorsys

DUSK = hx('#6a6c78')
SAT, VAL = 0.48, 0.74


def rm(h):
    """the colour a live-art colour becomes after the overcast remap"""
    r, g, b = hx(h) if isinstance(h, str) else h
    hh, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    c = [round(k * 255) for k in colorsys.hsv_to_rgb(hh, min(1, s * SAT), min(1, v * VAL))]
    return tuple(round(c[i] * .88 + DUSK[i] * .12) for i in range(3))


BROWN_O = [hx(h) for h in ('#c88a5c', '#aa6b4c', '#8c4c3c', '#5c2c3c', '#482434', '#341c2c')]
GREY_O = [hx(h) for h in ('#7c8c70', '#647864', '#4c6458', '#344c4c', '#2b4246', '#223840')]
WATER_O = [hx(h) for h in ('#4ab0a4', '#3a9494', '#2e7a84', '#246270', '#1c4a5c', '#16405a')]
WATER_F = [hx(h) for h in ('#566e62', '#4a6058', '#3f544f', '#354846', '#2c3d40', '#243338')]   # stagnant
MUD_O = [hx(h) for h in ('#a8805c', '#926a50', '#7c5444', '#54384a', '#442e43', '#34243c')]
LEAF_O = [hx(h) for h in ('#88d070', '#63b564', '#3e9a58', '#2e6a5c')]
ORANGE = hx('#f5b82e')

HEART = [hx('#b9a487'), hx('#9c866e'), hx('#7a6557')]          # pale snapped heartwood
SCUM = [hx('#7e8b58'), hx('#69774b'), hx('#56633f')]
MOSS = [hx('#7d8a4a'), hx('#657339'), hx('#4d5a30')]
DEAD = [hx('#8f8362'), hx('#766a50'), hx('#5d5342')]
PLANK = [hx('#9b8c7c'), hx('#7f7066'), hx('#5f5350'), hx('#463c40')]
VINE = (hx('#4b4732'), hx('#6f6a41'))


def build(p):
    px = p.px
    rng = random.Random(41)
    W, H = p.w, p.h

    def col(x, y):
        return px[x, y][:3] if 0 <= x < W and 0 <= y < H else None

    def inked(draw):
        """draw an object on a blank key layer, paste it, ring it with ink (so same-colour overlaps stay solid)"""
        from PIL import Image, ImageDraw
        KEY = (255, 0, 255, 255)
        real_im, real_px, real_d = p.im, p.px, p.d
        lay = Image.new('RGBA', (W, H), KEY)
        p.im, p.px, p.d = lay, lay.load(), ImageDraw.Draw(lay)
        try:
            draw()
        finally:
            lpx = p.px
            p.im, p.px, p.d = real_im, real_px, real_d
        new = set()
        for y in range(H):
            for x in range(W):
                if lpx[x, y] != KEY:
                    real_px[x, y] = lpx[x, y]
                    new.add((x, y))
        for (x, y) in new:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                q = (x + dx, y + dy)
                if q not in new and 0 < q[0] < W - 1 and 0 < q[1] < H - 1:
                    real_px[q] = INK + (255,)

    def blobby(x, y, a=1.0):
        return math.sin(x * .21 * a + 1.3) + math.sin(y * .33 * a + x * .07) + math.sin((x + y) * .13 * a + 4.0)

    BR_ALL = set(BROWN_O)
    orange = [(x, y) for y in list(range(0, 6)) + list(range(262, H)) for x in range(W) if col(x, y) == ORANGE]

    # ---- 1. removals on the live colours ----------------------------------------------------------------
    # 1a. lantern glow and lantern: still water painted back (rows taken from clean water at x=272)
    GLOW = {hx(h) for h in ('#d0ec7c', '#a8dc70', '#7cc464', '#fffbc0', '#fcea88', '#f8d850')}
    for y in range(148, 197):
        for x in range(276, 324):
            c = col(x, y)
            if c in GLOW or (c == INK and 293 <= x <= 307 and 160 <= y <= 181):
                px[x, y] = px[272, y]
    # the far root the glow was hiding is drawn back in
    for y in range(150, 193):
        f = (y - 150) / 42
        xl = round(279 + f * 8)
        xr = round(291 + f * 7)
        for x in range(xl, xr + 1):
            if col(x, y) in BR_ALL:
                continue
            if x == xl or x == xr:
                c = INK
            elif x - xl <= 2:
                c = GREY_O[0] if blobby(x, y * 2) > -0.5 else GREY_O[1]
            elif xr - x <= 3:
                c = GREY_O[3] if blobby(x, y * 2) > -0.8 else GREY_O[2]
            else:
                c = GREY_O[1] if blobby(x * 2, y * 1.5) > -0.9 else GREY_O[2]
            px[x, y] = c + (255,)
    for y in range(150, 162):                                   # the slim fork beside it joins in
        xr2 = round(306 - (y - 150) * 0.9)
        for x in range(round(291 + (y - 150) / 42 * 7), xr2 + 1):
            if col(x, y) in BR_ALL:
                continue
            px[x, y] = (INK if x == xr2 else (GREY_O[2] if xr2 - x <= 2 else GREY_O[1])) + (255,)
    # the cord keeps a frayed stump: cut everything of it below y=128
    for y in range(129, 162):
        for x in (299, 300, 301):
            if col(x, y) == INK and col(x - 2, y) != INK and col(x + 2, y) != INK:
                c = col(x - 1, y) if col(x - 1, y) != INK else col(x + 1, y)
                px[x, y] = c + (255,)

    # 1b. the frog: water above the island, mud inside it
    top = {}
    for x in range(214, 269):
        top[x] = 232 + (1 if (x // 5) % 3 == 1 else 0) - (1 if (x // 7) % 4 == 2 else 0)
    for y in range(193, 232 + 2):
        a, b_ = px[213, y], px[269, y]
        if col(213, y) not in WATER_O:
            a = b_
        if col(269, y) not in WATER_O:
            b_ = a
        for x in range(214, 269):
            if y < top[x]:
                if a == b_:
                    px[x, y] = a
                else:
                    edge = 241 + 14 * math.sin(y * 1.9) + 6 * math.sin(y * .7 + 2)
                    px[x, y] = a if x < edge else b_
    FROG = {hx(h) for h in ('#9ad85f', '#c8f07a', '#e8f4a0', '#307340', '#3c8c44', '#6cc044', '#ffe27a', '#245a3c')}
    for x in range(214, 269):
        for y in range(top[x], 253):
            c = col(x, y)
            if y == top[x]:
                px[x, y] = INK + (255,)
            elif c in FROG or c == INK or c in WATER_O or y <= top[x] + 2:
                d = y - top[x]
                n = blobby(x * 1.7, y * 2.3)
                if d <= 2:
                    k = 0 if n > -0.6 else 1
                elif d <= 12:
                    k = 0 if n > 1.2 else (2 if n < -1.3 else 1)
                else:
                    k = 2 if n < 0.2 else 1
                px[x, y] = MUD_O[k] + (255,)

    # 1c. generic "take a piece of root away" with snapped, inked, pale ends
    def remove(pix, fill, rootset):
        R = set(pix)
        for (x, y) in R:
            px[x, y] = fill(x, y) + (255,)
        edge = set()
        for (x, y) in R:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                q = (x + dx, y + dy)
                if q not in R and col(*q) in rootset:
                    edge.add(q)
        for q in edge:
            px[q] = INK + (255,)
        return R, edge

    def heartwood(edge, rootset, depth=3):
        """pale core just behind a snapped end (drawn after the remap, rootset = final colours)"""
        seen = set(edge)
        front = set(edge)
        for d in range(depth):
            nxt = set()
            for (x, y) in front:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    q = (x + dx, y + dy)
                    if q not in seen and col(*q) in rootset:
                        nxt.add(q)
            for (x, y) in nxt:
                if d < depth - 1 or (x + y) % 3:
                    px[x, y] = HEART[0 if d == 0 else 1] + (255,)
            seen |= nxt
            front = nxt

    BR = set(BROWN_O)
    # outer brown arch: a stretch on the right is gone (sky above painted down to the root below it)
    gap = []
    jag_a = [0, 2, 1, 4, 2, 5, 3, 1, 3, 0, 2, 4, 1, 3, 2, 0, 1, 3, 5, 2, 4, 1, 0, 2]
    for x in range(310, 372):
        y = 70
        while col(x, y) != INK and y < 150:
            y += 1
        y_top = y
        y += 3
        while col(x, y) != INK and y < 160:
            y += 1
        y_sep = y
        for yy in range(y_top, y_sep):
            t = (x - 300) * .915 + (yy - 80) * .40
            s = yy - y_top
            if 27 + jag_a[s % 24] <= t <= 55 - jag_a[(s + 7) % 24]:
                gap.append((x, yy, y_top))
    ytop = {(x, y): yt for x, y, yt in gap}
    sky_above = {}
    for (x, y), yt in ytop.items():
        sky_above[(x, y)] = col(x, yt - 2)
    _, arch_edge = remove(list(ytop), lambda x, y: sky_above[(x, y)], BR)

    # middle grey arch: a stretch at the top is gone
    GR = set(GREY_O)
    ggap = []
    for x in range(228, 262):
        for y in range(112, 140):
            if col(x, y) in GR or col(x, y) == INK:
                s = y - 116
                if 233 + jag_a[(s + 3) % 24] // 2 <= x - (y - 118) // 3 <= 252 - jag_a[(s + 11) % 24] // 2:
                    ggap.append((x, y))
    gfill = {}
    for (x, y) in ggap:
        yy = y
        while col(x, yy) in GR or col(x, yy) == INK:
            yy -= 1
        gfill[(x, y)] = col(x, yy)
    _, grey_edge = remove(ggap, lambda x, y: gfill[(x, y)], GR)

    # a thin prop root on the left snapped off above the water
    tgap = []
    for y in range(203, 242):
        for x in range(104, 142):
            if col(x, y) in BR or col(x, y) == INK:
                tgap.append((x, y))
    tgap = [(x, y) for (x, y) in tgap if y >= 203 + ((x * 3) % 4)]
    tfill = {}
    for (x, y) in tgap:
        xx = x
        while col(xx, y) in BR or col(xx, y) == INK:
            xx += 1
        tfill[(x, y)] = col(xx, y)
    _, thin_edge = remove(tgap, lambda x, y: tfill[(x, y)], BR)

    # and one on the right
    tgap2 = []
    for y in range(196, 240):
        for x in range(303, 327):
            if (col(x, y) in BR or col(x, y) == INK) and y >= 196 + ((x * 5) % 4):
                tgap2.append((x, y))
    tfill2 = {}
    for (x, y) in tgap2:
        xx = x
        while col(xx, y) in BR or col(xx, y) == INK or col(xx, y) in GR:
            xx -= 1
        tfill2[(x, y)] = col(xx, y)
    _, thin_edge2 = remove(tgap2, lambda x, y: tfill2[(x, y)], BR)

    # ---- 2. overcast recolour -----------------------------------------------------------------------------
    p.remap(sat=SAT, val=VAL, tint=DUSK)
    ink_rm = rm(INK)
    wmap = {rm(a): b for a, b in zip(WATER_O, WATER_F)}
    wmap[ink_rm] = INK
    wmap[rm('#cfeec0')] = hx('#7d8f7c')            # the bright ripples are dull now
    p.recolor((0, 150, W - 1, H - 1), lambda r, g, b: wmap.get((r, g, b)))
    p.recolor((0, 0, W - 1, 149), lambda r, g, b: INK if (r, g, b) == ink_rm else None)
    BROWN = [rm(c) for c in BROWN_O]
    GREY = [rm(c) for c in GREY_O]
    MUD = [rm(c) for c in MUD_O]
    LEAF = [rm(c) for c in LEAF_O]
    WSET = set(WATER_F) | {hx('#7d8f7c')}
    BSET, GSET = set(BROWN), set(GREY)

    for e, rs in ((arch_edge, BSET), (grey_edge, GSET), (thin_edge, BSET), (thin_edge2, BSET)):
        heartwood(e, rs, 3 if rs is BSET else 2)

    # ---- 3. faint light shaft from the upper left (only on the far things: sky, water, grey roots) --------
    back = WSET | GSET
    SKY = {rm(h) for h in ('#3c8a70', '#5cae84', '#8ccc98', '#78c4a0', '#c8ecb0', '#f8ffd0', '#9cd8a8', '#e0f4b8',
                           '#c0e8b0')}
    back |= SKY
    for y in range(44, 236):
        xl = 150 + (y - 44) * 0.36
        for x in range(int(xl), int(xl + 30 + (y - 44) * .06)):
            c = col(x, y)
            if c in back:
                px[x, y] = tuple(min(255, k + 13) for k in c) + (255,)

    # ---- 4. canopy half dead: clustered dry clumps ----------------------------------------------------------
    leafmap = dict(zip(LEAF[:3], DEAD))
    def dry(r, g, b):
        return None
    for y in range(0, 62):
        for x in range(W):
            c = col(x, y)
            if c in leafmap and blobby(x, y, 0.8) > 0.95:
                px[x, y] = leafmap[c] + (255,)

    # ---- 5. moss on the upper side of the roots, clustered -------------------------------------------------
    for x in range(20, 460):
        if blobby(x * 1.3, 17) < -0.1:
            continue
        for y in range(62, 150):
            if col(x, y) in BSET and col(x, y - 1) == INK and col(x, y - 2) not in BSET and col(x, y - 2) != INK:
                d = 2 + (1 if blobby(x * 2.1, 5) > 0.3 else 0) + (1 if blobby(x * 3.3, 9) > 0.9 else 0) + (1 if blobby(x * .9, 2) > 1.3 else 0)
                for k in range(d):
                    if col(x, y + k) in BSET:
                        px[x, y + k] = MOSS[0 if k == 0 else (1 if k < d - 1 else 2)] + (255,)
                break

    # ---- 6. green scum on the still water --------------------------------------------------------------------
    def scum(cx, cy, rx, ry, seed):
        r2 = random.Random(seed)
        for dy in range(-ry, ry + 1):
            half = rx * math.sqrt(max(0, 1 - (dy / (ry + .5)) ** 2)) + r2.randint(-2, 2)
            off = r2.randint(-2, 2)
            for x in range(int(cx - half + off), int(cx + half + off) + 1):
                y = cy + dy
                if col(x, y) in WSET:
                    c = SCUM[0] if dy == -ry or (dy < 0 and r2.random() < .0) else (SCUM[2] if dy == ry else SCUM[1])
                    px[x, y] = c + (255,)
        for _ in range(max(1, rx // 5)):                       # light flecks as short dashes
            x = cx + r2.randint(-rx + 2, rx - 4)
            y = cy + r2.randint(-ry + 1, max(-ry + 1, ry - 1))
            for i in range(r2.randint(2, 4)):
                if col(x + i, y) in set(SCUM):
                    px[x + i, y] = SCUM[0] + (255,)
    for (cx, cy, rx, ry) in ((30, 196, 24, 2), (150, 212, 18, 2), (182, 226, 12, 1),
                             (300, 214, 22, 2), (356, 196, 16, 2), (438, 212, 26, 3), (268, 180, 16, 1),
                             (120, 186, 12, 1), (455, 180, 18, 2), (220, 204, 14, 1),
                             (14, 228, 12, 2), (232, 164, 12, 1), (290, 256, 26, 2), (70, 172, 14, 1),
                             (398, 226, 12, 1), (170, 250, 18, 2)):
        r3 = random.Random(cx + cy * 3)
        scum(cx, cy, rx, ry, cx * 7 + cy)
        scum(cx - rx // 2 + r3.randint(-3, 3), cy + ry + 1, rx // 2 + 2, max(1, ry - 1), cx + 1)
        scum(cx + rx // 2 + r3.randint(-3, 3), cy - ry - 1, rx // 2, 1, cx + 2)

    # ---- 7. new things --------------------------------------------------------------------------------------
    def log(x0, y0, x1, y1, th, pal, water=None, seed=0):
        """a lying trunk from (x0,y0) to (x1,y1) (centre line), th thick, lit on top; below `water` y it is under"""
        r2 = random.Random(seed)
        L = math.hypot(x1 - x0, y1 - y0)
        ux, uy = (x1 - x0) / L, (y1 - y0) / L
        for y in range(int(min(y0, y1) - th), int(max(y0, y1) + th) + 1):
            for x in range(int(min(x0, x1) - th), int(max(x0, x1) + th) + 1):
                t = (x - x0) * ux + (y - y0) * uy
                s = -(x - x0) * uy + (y - y0) * ux
                jag0 = (int(s * 1.7) * 5) % 4
                jag1 = (int(s * 1.3 + 9) * 3) % 5
                if -jag0 <= t <= L + jag1 - 2 and abs(s) <= th / 2:
                    if water is not None and y > water(x):
                        continue
                    f = s / (th / 2)
                    n = blobby(t * 1.5 + seed, s * 3 + seed * 2)
                    if t < 2 - jag0 + 1 or t > L + jag1 - 5:
                        c = HEART[0] if f < 0.1 else HEART[1]
                    elif f < -0.45:
                        c = pal[0] if n > -0.8 else pal[1]
                    elif f < 0.3:
                        c = pal[1] if n > -1.0 else pal[2]
                    else:
                        c = pal[2] if n > -0.6 else pal[3]
                    p.dot(x, y, c)

    def waterline(x0, x1, yfn, seed):
        """scum and a dark shadow line where something sits in the water"""
        r2 = random.Random(seed)
        for x in range(x0, x1 + 1):
            y = yfn(x)
            for k in (1, 2):
                if col(x, y + k) in WSET or col(x, y + k) in set(SCUM):
                    px[x, y + k] = (WATER_F[5] if k == 1 else WATER_F[4]) + (255,)

    # 7a. rotten boardwalk from the island towards the right edge
    def post(x, yt, lean=0):
        for y in range(yt, 264):
            o = round(lean * (263 - y) / 20)
            p.dot(x + o, y, PLANK[0] if y % 7 else PLANK[1]); p.dot(x + o + 1, y, PLANK[1])
            p.dot(x + o + 2, y, PLANK[2]); p.dot(x + o + 3, y, PLANK[3])
    def deck(x0, x1, y):
        x = x0
        i = 0
        while x < x1:
            w = (7, 6, 8, 7, 6)[i % 5]
            e = min(x + w - 1, x1)
            dy = (0, 0, 1, 0, 0)[i % 5]
            for xx in range(x, e + 1):
                p.dot(xx, y + dy, PLANK[0]); p.dot(xx, y + dy + 1, PLANK[0] if (xx + i) % 5 else PLANK[1])
                p.dot(xx, y + dy + 2, PLANK[1]); p.dot(xx, y + dy + 3, PLANK[2]); p.dot(xx, y + dy + 4, PLANK[3])
            p.dot(e, y + dy + 1, PLANK[2]); p.dot(e, y + dy + 2, PLANK[3])
            x = e + 1
            i += 1
    def boardwalk():
        post(372, 250); post(398, 250, 1); post(452, 250); post(474, 250)
        deck(364, 404, 245)
        deck(446, 479, 245)
        # the gap in front of the big root: one plank hangs, one stringer still crosses
        p.line([(405, 249), (445, 249)], PLANK[2])
        p.line([(405, 250), (445, 250)], PLANK[3])
        p.poly([(412, 246), (416, 246), (419, 258), (415, 258)], PLANK[1])
        p.line([(412, 246), (415, 258)], PLANK[0])
        p.line([(416, 246), (419, 258)], PLANK[3])
        # island side: the deck is smashed and slopes into the water
        p.poly([(300, 243), (320, 250), (319, 254), (299, 247)], PLANK[1])
        p.line([(300, 243), (320, 250)], PLANK[0])
        p.line([(299, 247), (319, 254)], PLANK[3])
        for k in (306, 312):
            p.line([(k, 246), (k - 1, 249)], PLANK[3])
        # splintered planks standing up where the arch piece hit
        p.poly([(352, 249), (357, 234), (360, 235), (356, 250)], PLANK[1])
        p.line([(352, 249), (357, 234)], PLANK[0])
        p.line([(356, 250), (360, 235)], PLANK[3])
        p.poly([(360, 248), (366, 240), (368, 242), (363, 250)], PLANK[2])
        p.line([(360, 248), (366, 240)], PLANK[0])
        # floating plank
        p.poly([(140, 230), (156, 228), (157, 230), (141, 232)], PLANK[1])
        p.line([(140, 230), (156, 228)], PLANK[0])
    inked(boardwalk)
    for (x0, x1, y) in ((138, 158, 233), (298, 322, 255)):
        for x in range(x0, x1):
            if col(x, y) in WSET:
                px[x, y] = WATER_F[5] + (255,)

    # 7b. the fallen piece of the arch, lying on the smashed deck under the gap
    wl_a = lambda x: 247 - (x - 330) // 14
    inked(lambda: log(320, 229, 354, 239, 16, BROWN, water=wl_a, seed=3))
    waterline(316, 358, lambda x: wl_a(x), 1)

    # 7c. fallen mangrove trunk, left foreground
    wl_b = lambda x: 255 + (x - 60) // 40
    inked(lambda: log(-4, 236, 136, 249, 17, BROWN, water=wl_b, seed=11))
    inked(lambda: log(60, 233, 69, 216, 5, BROWN, water=lambda x: 232, seed=5))       # snapped branch stub
    waterline(0, 140, wl_b, 2)
    for x in range(2, 132):                                      # moss along its top
        if blobby(x * 1.1, 40) > -0.2:
            for y in range(225, 250):
                if col(x, y) in BSET and col(x, y - 1) == INK:
                    px[x, y] = MOSS[0] + (255,)
                    if col(x, y + 1) in BSET:
                        px[x, y + 1] = MOSS[1] + (255,)
                    if blobby(x * 2.3, 3) > 0.4 and col(x, y + 2) in BSET:
                        px[x, y + 2] = MOSS[2] + (255,)
                    break

    # 7d. the grey piece of the far arch, leaning out of the water
    inked(lambda: log(197, 181, 211, 154, 8, GREY, water=lambda x: 177, seed=8))
    for x in range(192, 204):
        if col(x, 179) in WSET:
            px[x, 179] = WATER_F[4] + (255,)

    # 7e. dead lantern post on the boardwalk
    GLASS = [hx('#59606a'), hx('#454a55'), hx('#7b8288')]
    def lamp_post():
        for y in range(212, 245):
            p.dot(470, y, PLANK[0]); p.dot(471, y, PLANK[1]); p.dot(472, y, PLANK[3])
        p.line([(470, 212), (460, 215)], PLANK[1])
        p.line([(470, 213), (460, 216)], PLANK[3])
        p.line([(461, 217), (461, 219)], PLANK[3])
        p.rect(458, 220, 464, 221, PLANK[2])
        p.rect(459, 222, 463, 229, GLASS[1])
        p.line([(459, 222), (459, 229)], GLASS[0])
        p.dot(460, 223, GLASS[2]); p.dot(460, 224, GLASS[2])
        p.line([(462, 222), (461, 225), (463, 228)], INK)          # cracked glass
        p.rect(458, 230, 464, 230, PLANK[3])
    inked(lamp_post)

    # 7f. the keeper's lantern fell on the island: lying on its side, glass dark and cracked, cord trailing
    def lantern():
        BRASS = [hx('#9a8d78'), hx('#75695e'), hx('#51474a')]
        p.poly([(232, 225), (249, 220), (252, 229), (235, 233)], GLASS[1])
        p.line([(234, 226), (248, 222)], GLASS[0])
        p.line([(237, 227), (243, 225)], GLASS[2])
        p.line([(236, 232), (251, 228)], hx('#343843'))
        p.poly([(231, 225), (234, 224), (237, 233), (234, 234)], BRASS[1])      # cap
        p.line([(231, 225), (234, 224)], BRASS[0])
        p.poly([(247, 220), (250, 219), (253, 229), (250, 230)], BRASS[1])      # foot
        p.line([(247, 220), (250, 219)], BRASS[0])
        p.line([(250, 230), (253, 229)], BRASS[2])
        p.line([(241, 223), (240, 227), (243, 230)], INK)                       # crack
        p.line([(244, 222), (246, 225)], INK)
        p.line([(230, 228), (227, 227), (226, 230), (228, 232)], BRASS[1])      # bent hanging hook
    inked(lantern)
    for x in range(233, 252):                                          # contact shadow on the mud
        for y in (233, 234):
            if col(x, y) in set(MUD) :
                px[x, y] = MUD[3] + (255,)
    # frayed cord end where it hung
    p.dot(299, 129, INK); p.dot(301, 130, INK); p.dot(300, 131, INK)

    # 7g. a mangrove seedling on the island (life comes back)
    def seedling():
        p.line([(262, 231), (262, 225)], hx('#5d6a3b'))
        p.line([(259, 224), (261, 225)], hx('#93a45a')); p.dot(258, 223, hx('#93a45a'))
        p.line([(263, 224), (265, 222)], hx('#7d8a4a')); p.dot(266, 222, hx('#7d8a4a'))
    inked(seedling)

    # 7h. mud banks in the corners
    def bank(x0, x1, ytop, seed):
        r2 = random.Random(seed)
        h = 0
        for x in range(x0, x1 + 1):
            f = (x - x0) / max(1, (x1 - x0))
            yt = ytop + round(8 * (2 * f - 1) ** 2) + (1 if (x // 6) % 2 else 0)
            for y in range(yt, 266):
                d = y - yt
                n = blobby(x * 1.9 + seed, y * 2.7)
                c = MUD[0] if d < 2 and n > -0.5 else (MUD[1] if d < 6 and n > -1.0 else (MUD[2] if d < 9 else MUD[3]))
                p.dot(x, y, c)
    inked(lambda: bank(96, 150, 257, 9))

    # 7i. floating dead leaves (little inked chips) and twigs
    def leaf(x, y, k):
        c = DEAD[k % 3]
        p.dot(x, y, c); p.dot(x + 1, y, c); p.dot(x + 2, y, DEAD[2])
    for i, (x, y) in enumerate(((98, 214), (160, 198), (284, 206), (346, 214), (404, 200), (20, 212), (300, 246),
                                (200, 252), (438, 232))):
        inked(lambda: leaf(x, y, i))
    for (x, y, w) in ((130, 228, 9), (276, 226, 7), (352, 244, 10), (48, 204, 8)):
        p.line([(x, y), (x + w, y - 1)], hx('#3a3034'))
        p.dot(x + w // 2, y - 2, hx('#3a3034'))

    # stress cracks in the arch beside the break
    p.rng.seed(5)
    p.crack(322, 84, 9); p.crack(300, 80, 6); p.crack(366, 112, 8); p.crack(182, 84, 7)

    # ---- 8. dead hanging vines ---------------------------------------------------------------------------------
    def under(x, y):
        while col(x, y) not in BSET and y < 160:
            y += 1
        while (col(x, y) in BSET or col(x, y) == INK or col(x, y) in set(MOSS) or col(x, y) in set(HEART)) and y < 200:
            y += 1
        return y
    for (x, ln) in ((112, 22), (136, 14), (171, 30), (205, 18), (262, 26), (291, 12), (383, 20), (402, 32),
                    (86, 16)):
        y = under(x, 62)
        p.vine(x, y, ln, VINE, sway=2, leaf=0.3)
    for (x, y, ln) in ((100, 46, 18), (158, 44, 12), (236, 20, 26), (330, 40, 16), (376, 44, 22), (62, 44, 14),
                       (462, 46, 20), (276, 26, 14)):
        while col(x, y) in set(LEAF) | set(DEAD) | {INK, hx('#4c4438')} and y < 70:
            y += 1
        p.vine(x, y, ln, VINE, sway=2, leaf=0.25)

    # ---- 9. cobweb in the fork of the left trunk ----------------------------------------------------------------
    WEB = hx('#c9cbd0')
    cx, cy = 54, 98
    def ray(a, r):
        aa = math.radians(a)
        return (cx + round(r * math.sin(aa)), cy - round(r * math.cos(aa)))
    for a, r in ((2, 22), (30, 22), (62, 21), (95, 20), (124, 19)):
        p.line([(cx, cy), ray(a, r)], WEB)
    for r in (7, 13, 19):
        p.line([ray(a, r - (1 if a in (30, 62, 95) else 0)) for a in (2, 30, 62, 95, 124)], WEB)

    # the frame marks of the live picture stay exactly as they were
    for (x, y) in orange:
        px[x, y] = ORANGE + (255,)
