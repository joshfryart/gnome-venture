"""Ruined Sunken Gnome Galleon: the reef is empty, the mast has snapped and fallen through the hull."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from ruin_lib import Pic, hx, INK

MURK = (0x5a, 0x6e, 0x6a)
SAT, VAL = 0.5, 0.86


def build(p):
    import math, random, colorsys
    px = p.px

    def rm(h):
        """the colour a live-art colour becomes after the murky remap"""
        r, g, b = hx(h) if isinstance(h, str) else h
        hh, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        c = [round(k * 255) for k in colorsys.hsv_to_rgb(hh, min(1, s * SAT), min(1, v * VAL))]
        return tuple(round(c[i] * .88 + MURK[i] * .12) for i in range(3))

    def col(x, y):
        return px[x, y][:3] if 0 <= x < p.w and 0 <= y < p.h else None

    def inked(draw):
        shadow_log.clear()
        b = p.snapshot()
        draw()
        bp = b.load()
        for (x, y, c) in shadow_log:                  # contact shadows on the silt are not objects: no ink
            if px[x, y][:3] == c:
                bp[x, y] = px[x, y]
        shadow_log.clear()
        p.outline_new(b)

    shadow_log = []

    def stamp(x, y, rows, pal):
        for j, row in enumerate(rows):
            for i, ch in enumerate(row):
                if ch in pal:
                    p.dot(x + i, y + j, pal[ch])

    # ================= A. work on the ORIGINAL colours ====================================================
    BANDS = [hx(h) for h in ('#58d0d0', '#3fb8c8', '#2a98b8', '#2078a8', '#1c5c94')]
    RAYS = {hx('#81dfda'): BANDS[0], hx('#70cfd5'): BANDS[1], hx('#62b9ca'): BANDS[2],
            hx('#5ba3bf'): BANDS[3], hx('#5890b1'): BANDS[4]}
    BUB = hx('#d8fff0')
    band_of = {c: i for i, c in enumerate(BANDS)}
    # 1. the sun shafts go out
    p.recolor((0, 0, 479, 269), lambda r, g, b: RAYS.get((r, g, b)))
    # 2. bubbles pop: each ring pixel takes its nearest non-bubble neighbour
    for _ in range(4):
        for y in range(3, 215):
            for x in range(1, 479):
                if col(x, y) == BUB:
                    for (dx, dy) in ((-1, 0), (1, 0), (0, -1), (0, 1), (-2, 0), (2, 0)):
                        c = col(x + dx, y + dy)
                        if c and c != BUB:
                            px[x, y] = c + (255,)
                            break
    # 2b. the lit glow disc behind the old bubbles goes dark; the sparkle by the chest goes out
    for y in range(86, 104):
        for x in range(70, 94):
            if (x - 81) ** 2 + (y - 95) ** 2 <= 81 and col(x, y) == BANDS[1] and y >= 89:
                px[x, y] = BANDS[2] + (255,)
    p.recolor((396, 208, 408, 216), lambda r, g, b: hx('#1c5c94') if (r, g, b) == hx('#fff4d6') else None)
    # 3. where each water band starts in each column (hidden stretches are bridged in a straight line)
    bnd = []
    for k in range(1, 5):
        ys = [None] * 480
        for x in range(480):
            for y in range(4, 230):
                c = col(x, y)
                if c in band_of and band_of[c] >= k:
                    up = col(x, y - 1)
                    if up in band_of and band_of[up] < k:
                        ys[x] = y
                    break
        known = [x for x in range(480) if ys[x] is not None]
        for x in range(480):
            if ys[x] is None:
                lo = max([q for q in known if q < x], default=None)
                hi = min([q for q in known if q > x], default=None)
                if lo is None:
                    ys[x] = ys[hi]
                elif hi is None:
                    ys[x] = ys[lo]
                else:
                    ys[x] = round(ys[lo] + (ys[hi] - ys[lo]) * (x - lo) / (hi - lo))
        bnd.append(ys)
    wpal = list(BANDS)

    def water(x, y):
        return wpal[sum(1 for k in range(4) if bnd[k][x] <= y)]

    def drown(box, keep=None):
        """everything that is not water inside the box becomes water"""
        x0, y0, x1, y1 = box
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                if col(x, y) not in wpal and not (keep and keep(x, y)):
                    px[x, y] = water(x, y) + (255,)

    # 4. the fish have left; the mast top, yard, sail and flag come down
    for box in ((44, 58, 82, 82), (90, 102, 112, 118), (384, 58, 422, 82), (420, 102, 444, 118)):
        drown(box)
    drown((132, 30, 300, 102))
    drown((241, 103, 300, 113))
    for y in range(68, 84):                                            # the blue sail hole left a disc behind
        for x in range(254, 272):
            px[x, y] = water(x, y) + (255,)
    # the lower sail curl in front of the stump goes too; the stump is repainted whole underneath
    mast_row = [col(235 + i, 118) for i in range(6)]
    for y in range(98, 137):
        ml = int(233.5 + (y - 110) * .267)
        for x in range(214, 251):
            if y >= 103 and ml <= x <= ml + 5:
                px[x, y] = mast_row[x - ml] + (255,)
            elif col(x, y) not in band_of:
                px[x, y] = water(x, y) + (255,)
    # 5. the hatted octopus is gone: bare planks where it sat (the breach is cut there below)
    OCT = {hx(h) for h in ('#e0647a', '#f07f91', '#c8406a', '#a04060', '#7d3454', '#ff9aa8', '#d83a3a', '#e0443a',
                            '#ff6a8a', '#ff9ac0', '#5a2848', '#ffa6b9', '#2b1c26')}
    WOOD = hx('#a9714a')
    p.recolor((286, 148, 318, 204), lambda r, g, b: WOOD if (r, g, b) in OCT else None)
    # 5b. the chest is repainted from scratch below: clear the old lid and the gold to silt
    GLD = {hx(h) for h in ('#ffd060', '#fff0c0', '#f5b82e', '#ffe38a', '#ffb03a')}
    for y in range(214, 262):
        for x in range(356, 436):
            c = col(x, y)
            if 379 <= x <= 425 and 221 <= y <= 227:
                px[x, y] = hx('#f4d490' if (x * 3 + y) % 23 > 4 else '#e8c078') + (255,)
            elif c in GLD and not (380 <= x <= 424 and 228 <= y <= 250):
                q = x - 1
                while col(q, y) in GLD:
                    q -= 1
                px[x, y] = px[q, y]
    # 6. the bow has broken off and sagged 3 px
    SHIP = {hx(h) for h in ('#a9714a', '#8a5a3c', '#5a3a34', '#4a2f32', '#3a2430', '#c88858', '#e8b060', '#2b1c26',
                            '#ffd060', '#8fe8f0', '#4a3020', '#c08550', '#c08856', '#a8704a', '#7a4a34', '#623b30',
                            '#d8a062', '#f5b82e', '#ffb03a', '#4a2c2c', '#b8946c', '#917262')}
    SAG = 3
    for x in range(305, 380):
        colm = [col(x, y) for y in range(270)]
        for y in range(240, 125, -1):
            if colm[y - SAG] in SHIP and y - SAG < 236:
                px[x, y] = colm[y - SAG] + (255,)
            elif colm[y] in SHIP and y < 236 and colm[y - SAG] in band_of:
                px[x, y] = water(x, y) + (255,)

    # ================= B. murky recolour ==================================================================
    p.remap(sat=SAT, val=VAL, tint=MURK)
    ink_rm = rm('#2b1c26')
    NEWW = [hx(h) for h in ('#7f9c92', '#6c8c86', '#597a7a', '#48676c', '#3b555e')]
    wmap = {rm(BANDS[i]): NEWW[i] for i in range(5)}
    wmap[ink_rm] = INK
    wmap[rm('#1a4478')] = NEWW[4]
    p.recolor((0, 0, 479, 269), lambda r, g, b: wmap.get((r, g, b)))
    wpal = list(NEWW)
    WSET = set(NEWW)

    # palettes
    S1, S2, S3, S4, S5 = [rm(h) for h in ('#ffe8a8', '#f4d490', '#e8c078', '#b08a5c', '#856a5a')]
    SANDSET = {S1, S2, S3, S4, S5, rm('#f6e0b8'), rm('#fff0d0')}
    H_LT, H_MID, H_DK, H_SH, H_SH2 = [rm(h) for h in ('#c88858', '#a9714a', '#8a5a3c', '#5a3a34', '#4a2f32')]
    SEAM = rm('#3a2430')
    DECK = rm('#e8b060')
    HULLSET = {H_LT, H_MID, H_DK, DECK}
    W_LT, W_MID, W_DK, W_SH = hx('#a8917c'), hx('#8a7164'), hx('#665258'), hx('#463a46')
    VD, VD2 = hx('#33303c'), hx('#262330')
    C_LT, C_MID, C_DK, C_ST = hx('#cfc8b4'), hx('#b3aa98'), hx('#8f8779'), hx('#7a8068')   # rotted sail
    M_LT, M_MID, M_DK = hx('#84946a'), hx('#667a55'), hx('#4b5d48')                         # algae
    I_LT, I_MID, I_DK = hx('#8d9492'), hx('#666c70'), hx('#474a54')                         # iron
    G_LT, G_MID, G_DK = hx('#cdb873'), hx('#a89152'), hx('#7a683f')                         # dull gold
    B_LT, B_MID, B_DK = hx('#e2ded2'), hx('#b9b4aa'), hx('#8d8884')                         # bleached coral
    is_sand = lambda x, y: col(x, y) in SANDSET
    is_hull = lambda x, y: col(x, y) in HULLSET
    is_water = lambda x, y: col(x, y) in WSET

    def seam_y(x, y_at_200):
        return y_at_200 + round(-0.123 * (x - 200))

    # ---- water: silt haze over the seabed, slow silt drifts --------------------------------------------
    HAZE = hx('#4c666a')
    HAZE2 = hx('#5a7474')
    r = random.Random(11)
    for (sx, sy, sw) in ((2, 204, 46), (60, 198, 60), (30, 190, 38), (368, 203, 56), (410, 195, 50), (446, 206, 30),
                         (372, 186, 30), (96, 208, 22), (440, 180, 34), (6, 176, 30)):
        for yy, inset in ((sy, 6), (sy + 1, 0), (sy + 2, 4)):
            for xx in range(sx + inset, sx + sw - inset):
                if 0 <= xx < 480 and is_water(xx, yy) and col(xx, yy) in (NEWW[4], NEWW[3]):
                    p.dot(xx, yy, HAZE if col(xx, yy) == NEWW[4] else HAZE2)
    # drifting silt motes: short slanted trails, lighter than the band they hang in
    for (mx, my, n) in ((30, 60, 4), (120, 120, 5), (70, 150, 4), (180, 40, 4), (330, 70, 5), (400, 150, 5),
                        (450, 60, 4), (300, 110, 3), (20, 120, 3), (150, 95, 3), (430, 110, 4), (250, 30, 3)):
        for i in range(n):
            xx, yy = mx + i * 5 + r.randint(-1, 1), my + i * 3 + r.randint(-1, 1)
            if is_water(xx, yy) and is_water(xx + 1, yy):
                k = NEWW.index(col(xx, yy))
                c = NEWW[k - 1] if k > 0 else hx('#93ada2')
                p.dot(xx, yy, c)
                if i % 2 == 0:
                    p.dot(xx + 1, yy, c)

    # ---- portholes: tarnished rims, dead glass ----------------------------------------------------------
    RIM, RIM_D = hx('#8e8a66'), hx('#6e6c56')
    GL, GL_D, GL_H = hx('#46545a'), hx('#39444c'), hx('#63736f')
    pm = {rm('#ffd060'): RIM, rm('#f5b82e'): RIM_D, rm('#8fe8f0'): GL_H}
    for (cx, cy) in ((150, 202), (182, 199), (214, 196), (246, 197), (278, 194), (313, 195)):
        for yy in range(cy - 12, cy + 13):
            for xx in range(cx - 12, cx + 13):
                c = col(xx, yy)
                if c in pm:
                    p.dot(xx, yy, pm[c])
                elif c == NEWW[2] and (xx - cx) ** 2 + (yy - cy) ** 2 < 100:
                    p.dot(xx, yy, GL if (xx - cx) + (yy - cy) < 3 else GL_D)
        # verdigris on the lower rim
        for yy in range(cy + 3, cy + 12):
            for xx in range(cx - 10, cx + 4):
                if col(xx, yy) == RIM and (xx + yy * 2) % 7 < 4:
                    p.dot(xx, yy, hx('#74907c'))
    # two panes are smashed: a dark jagged hole, a shard left in the frame
    for (cx, cy, s) in ((182, 199, 0), (246, 197, 1)):
        hole = ["..xxx..", ".xxxxx.", "xxxxxxx", ".xxxxxx", "..xxxx.", "...xx.."] if s == 0 else \
               [".xx....", "xxxx...", "xxxxxx.", ".xxxxxx", "..xxxxx", "...xxx."]
        stamp(cx - 3, cy - 2, hole, {'x': VD2})
        p.dot(cx - 3, cy - 3, GL_H)
        p.dot(cx + 3, cy + 3, GL_H)
        p.dot(cx + 2, cy + 4, GL_H)

    # ---- missing planks: ribs show through ---------------------------------------------------------------
    def plank_gap(x0, x1, s200, ribs, sag=0):
        jag = [0, 1, 0, 2, 1, 0, 1, 3, 1, 0, 2, 1, 0]
        for x in range(x0, x1 + 1):
            top = seam_y(x, s200) + 1 + sag
            for j in range(13):
                y = top + j
                if x - x0 < jag[j] or x1 - x < jag[(j + 5) % 13]:
                    continue
                if not (is_hull(x, y) or col(x, y) == SEAM):
                    continue
                c = VD2 if j < 3 else VD
                for rx in ribs:
                    if rx <= x < rx + 3:
                        c = (W_MID if x == rx else W_DK) if j >= 3 else W_SH
                p.dot(x, y, c)
            if is_hull(x, top + 13) or col(x, top + 13) == SEAM:
                p.dot(x, top + 13, H_LT)                                   # lit lip of the plank below
            p.dot(x, top - 1, INK)
    plank_gap(187, 209, 167, (192, 202))
    plank_gap(331, 346, 167, (337,), sag=SAG)

    # ---- the breach: the falling mast split the hull -----------------------------------------------------
    r = random.Random(5)
    hole_l, hole_r = {}, {}
    for y in range(140, 228):
        if y < 200:
            l, rr_ = 284 + (y - 140) * 3 / 60.0, 322 - (y - 140) * 5 / 60.0
        else:
            t = (y - 200) / 27.0
            l, rr_ = 287 + t * 14, 317 - t * 14
        band = (y // 7)
        jr = random.Random(band * 13 + 1)
        l += jr.randint(-2, 2)
        rr_ += jr.randint(-2, 2)
        if y % 7 in (2, 3):
            l += 2
        if y % 7 in (5,):
            rr_ -= 3
        if 184 <= y <= 203:
            l, rr_ = min(l, 287), max(rr_, 316)
        hole_l[y], hole_r[y] = int(round(l)), int(round(rr_))
    top_of = {}
    for x in range(280, 326):
        for y in range(125, 160):
            if not is_water(x, y):
                top_of[x] = y
                break
    for y in range(140, 228):
        for x in range(hole_l[y], hole_r[y] + 1):
            if is_water(x, y) or is_sand(x, y):
                continue
            t = top_of.get(x, 143)
            notch = 4 if 292 <= x <= 312 else (2 if 288 <= x <= 316 else 0)
            if y < t + notch:
                p.dot(x, y, water(x, y))                                   # the rail itself is bitten out
                continue
            c = VD2 if (y < t + notch + 6 or x < hole_l[y] + 3) else VD      # deepest under the deck and the lit side
            p.dot(x, y, c)
    # ribs and a deck beam inside
    for (rx, bend) in ((292, 1), (301, 0), (310, -1)):
        for y in range(150, 226):
            xx = rx + (bend if y > 195 else 0) + (bend if y > 212 else 0)
            for i in range(3):
                if col(xx + i, y) in (VD, VD2):
                    p.dot(xx + i, y, W_DK if i == 0 else W_SH)
            if col(xx, y) == W_DK and y % 9 < 6:
                p.dot(xx, y, W_MID)
    for x in range(284, 324):
        for j in range(3):
            y = 160 + j + round(-0.123 * (x - 300))
            if col(x, y) in (VD, VD2, W_SH, W_DK, W_MID):
                p.dot(x, y, (W_MID, W_DK, W_SH)[j])
    # rim: lit edge on the right side of the hole (faces the light), shadow line on the left
    for y in range(146, 228):
        xr, xl = hole_r[y] + 1, hole_l[y] - 1
        if is_hull(xr, y):
            p.dot(xr, y, H_LT)
        if is_hull(xl, y):
            p.dot(xl, y, H_DK)
    # snapped plank ends still jut into the gap
    for (y0, y1, ln, side) in ((168, 174, 5, 0), (183, 190, 7, 0), (198, 203, 4, 0), (212, 216, 4, 0),
                               (172, 178, 5, 1), (188, 194, 7, 1), (203, 207, 3, 1)):
        mid = (y0 + y1) / 2.0
        for y in range(y0 - 1, y1 + 2):
            n = ln - int(abs(y - mid)) if y0 <= y <= y1 else ln - int(abs(y - mid)) - 1
            for i in range(max(n, 0)):
                x = hole_l[y] + i if side == 0 else hole_r[y] - i
                if y < y0 or y > y1:
                    c = INK
                else:
                    c = H_LT if y == y0 else (H_DK if y == y1 else H_MID)
                    if i == n - 1 and side == 0:
                        c = H_DK
                    if i == n - 1 and side == 1:
                        c = H_LT
                p.dot(x, y, c)
    # silt has poured into the foot of the split
    for y in range(212, 232):
        for x in range(290, 316):
            d = ((x - 302) / 11.0) ** 2 + ((y - 228) / 13.0) ** 2
            if d < 1 and col(x, y) in (VD, VD2, W_SH, W_DK, W_MID, H_SH, H_SH2, INK, H_DK, H_MID):
                p.dot(x, y, S2 if (x - 302) + (y - 228) * 2 < -22 else (S3 if x < 306 else S4))

    # ---- fallen spar with the rotted sail ------------------------------------------------------------------
    def spar_y(x):
        return 104 + int(round((x - 239) * 0.787))

    def hem(x):
        pts = ((250, 152), (255, 167), (260, 161), (266, 177), (271, 170), (277, 180), (281, 172), (285, 163))
        for (a, ya), (b, yb) in zip(pts, pts[1:]):
            if a <= x <= b:
                return int(round(ya + (yb - ya) * (x - a) / (b - a))) + (1 if x % 3 == 0 else 0) - (2 if x % 5 == 0 else 0)
        return 0

    def sail():
        holes = ((260, 139, 4, 6), (262, 143, 3, 4), (274, 158, 4, 4), (276, 155, 3, 3))
        for x in range(250, 286):
            top, bot = spar_y(x) + 3, hem(x)
            for y in range(top, bot + 1):
                if any(((x - hx_) / float(rx)) ** 2 + ((y - hy) / float(ry)) ** 2 <= 1 for (hx_, hy, rx, ry) in holes):
                    continue
                f = (x - 250 + (y // 11)) % 8
                c = C_LT if f < 3 else (C_MID if f < 6 else C_DK)
                if y < top + 4:
                    c = C_DK if f >= 3 else C_MID                             # shade under the spar
                if y > bot - 3 or (((x - 268) / 7.0) ** 2 + ((y - 172) / 5.0) ** 2 < 1) or \
                        (((x - 254) / 4.0) ** 2 + ((y - 150) / 6.0) ** 2 < 1):
                    c = C_ST if f < 6 else M_DK                                # rot creeping up from the hem
                p.dot(x, y, c)
        # two thin tatters nearer the stump
        for (x0, w, ln) in ((243, 3, 13), (247, 2, 8)):
            for x in range(x0, x0 + w):
                for y in range(spar_y(x) + 3, spar_y(x) + 3 + ln - (x - x0) * 2):
                    p.dot(x, y, C_MID if x == x0 else C_DK)
    inked(sail)

    def spar():
        for x in range(240, 302):
            y = spar_y(x)
            for j in range(5):
                if x > 297 and col(x, y + j) not in (VD, VD2, W_SH, W_DK, W_MID) and not is_water(x, y + j):
                    continue
                p.dot(x, y + j, W_LT if j == 0 else (W_MID if j < 3 else W_DK))
            if x % 13 == 5:
                p.dot(x, y + 1, W_DK)
                p.dot(x + 1, y + 2, W_DK)
        # splintered stump top
        for (sx, sy0) in ((232, 99), (234, 101), (236, 98), (238, 101)):
            for y in range(sy0, 104):
                p.dot(sx, y, W_LT if sx < 235 else W_MID)
    inked(spar)

    def flag():
        rows = ["xxxxx", "xxxxo", "xxxxo", ".xxxo", ".xxoo", ".xxo.", "..xo.", "..xo.", "..o.."]
        stamp(289, spar_y(291) + 5, rows, {'x': hx('#96584f'), 'o': hx('#74464a')})
    inked(flag)

    # ---- hull: algae, barnacles, weed hanging from the rail -----------------------------------------------
    def patch(cx, cy, rx, ry, seed, cols=(M_LT, M_MID, M_DK)):
        rr = random.Random(seed)
        edge = {}
        for y in range(cy - ry - 1, cy + ry + 2):
            edge[y] = rr.uniform(-.2, .2)
        for y in range(cy - ry - 1, cy + ry + 2):
            for x in range(cx - rx - 1, cx + rx + 2):
                dx, dy = (x - cx) / float(rx), (y - cy) / float(ry)
                if dx * dx + dy * dy + edge[y] <= 1 and is_hull(x, y):
                    t = dx + dy
                    p.dot(x, y, cols[0] if t < -.8 else (cols[2] if t > .3 else cols[1]))
    for i, (cx, cy, rx, ry) in enumerate(((132, 196, 7, 4), (166, 222, 9, 4), (226, 232, 12, 3), (262, 222, 6, 3),
                                          (232, 188, 5, 3), (140, 180, 5, 2), (345, 200, 6, 4), (328, 160, 5, 2),
                                          (200, 206, 6, 2), (270, 236, 9, 2), (160, 190, 4, 2), (355, 172, 4, 3))):
        patch(cx, cy, rx, ry, 30 + i)
    # weed trailing from the rail and the spar
    for (vx, ln) in ((126, 14), (141, 9), (163, 17), (176, 8), (218, 12), (228, 7), (262, 6), (336, 13), (350, 8)):
        vy = next((y for y in range(125, 180) if col(vx, y) == DECK), None)
        if vy:
            p.vine(vx, vy + 1, ln, (M_DK, M_MID), sway=1, leaf=.3)
    for (vx, ln) in ((246, 9), (287, 7)):
        p.vine(vx, spar_y(vx) + 6, ln, (M_DK, M_MID), sway=1, leaf=.25)
    # barnacle crusts low on the hull
    def barnacles(pts):
        ok = lambda x, y: is_hull(x, y) or col(x, y) in (M_LT, M_MID, M_DK)
        for (bx, by) in pts:
            if all(ok(bx + i, by + j) for i in (0, 1, 2) for j in (0, 1, 2)):
                stamp(bx, by, [".L.", "LdM", ".M."], {'L': hx('#c2c0ae'), 'M': hx('#96958a'), 'd': hx('#5e5a5c')})
    barnacles(((150, 228), (153, 230), (156, 227), (204, 234), (207, 232), (210, 235),
               (249, 231), (252, 233), (340, 212), (343, 209), (136, 208), (139, 211), (133, 205)))

    # ---- stern lantern, dead ---------------------------------------------------------------------------------
    def lantern():
        p.line([(121, 164), (121, 151)], I_DK)
        p.line([(121, 151), (115, 151)], I_DK)
        p.dot(115, 152, I_DK)
        stamp(112, 152, ["..iii..", ".i...i.", ".iiiii.", "iGgigdi", "iggiddi", "iggidgi", "iiiiiii"],
              {'i': I_MID, 'g': hx('#56655f'), 'G': hx('#7b8a80'), 'd': VD})
    inked(lantern)

    # ---- seabed ------------------------------------------------------------------------------------------------
    def shadow(pts):
        for (x, y) in pts:
            if is_sand(x, y):
                p.dot(x, y, S5 if col(x, y) in (S4, S5) else S4)
                shadow_log.append((x, y, col(x, y)))

    def plank(x0, y0, ln, slope, th=3, cols=None):
        hi, mid, dk = cols or (W_LT, W_MID, W_DK)
        shadow([(x0 + i + 2, y0 + int(round(i * slope)) + th + k) for i in range(ln) for k in (0, 1)])

        def d():
            for i in range(ln):
                y = y0 + int(round(i * slope))
                for j in range(th):
                    if i in (0, ln - 1) and j in (0, th - 1) and th > 2:
                        continue
                    p.dot(x0 + i, y + j, hi if j == 0 else (mid if j < th - 1 else dk))
                if i % 9 == 4 and th > 2:
                    p.dot(x0 + i, y + 1, dk)
        inked(d)
    plank(282, 238, 20, 0.2)
    plank(296, 247, 17, -0.25)
    plank(236, 254, 14, 0.1)
    plank(170, 256, 19, -0.1)
    plank(318, 256, 13, 0.3)
    # the yard, half buried on the left
    plank(22, 251, 62, -0.08, th=4, cols=(W_LT, W_MID, W_SH))

    def yard_rag():
        off = [0, 1, 2, 2, 1, 0, -1, 0, 1, 3, 3, 2, 0, -1, 0, 1, 1, 0]
        for x in range(40, 58):
            top = 247 - (1 if 44 <= x <= 52 else 0)
            bot = 255 + off[x - 40]
            for y in range(top, bot + 1):
                f = (x + y) % 7
                p.dot(x, y, C_ST if y > bot - 2 else (C_LT if f < 3 else (C_MID if f < 5 else C_DK)))
    inked(yard_rag)
    # silt drifted over things and against the hull
    def drift(cx, cy, rx, ry, over=None):
        for y in range(cy - ry, cy + ry + 1):
            for x in range(cx - rx, cx + rx + 1):
                dx, dy = (x - cx) / float(rx), (y - cy) / float(ry)
                if dx * dx + dy * dy <= 1 + (0.15 if (x + y) % 5 < 2 else -0.1):
                    if is_water(x, y):
                        continue
                    t = dx * .6 + dy
                    p.dot(x, y, S2 if t < -.55 else (S3 if t < .35 else S4))
    for (cx, cy, rx, ry) in ((66, 256, 9, 4), (26, 256, 7, 3), (152, 240, 13, 4), (246, 249, 15, 4), (330, 226, 9, 4),
                             (196, 249, 10, 3)):
        drift(cx, cy, rx, ry)

    # bleached coral: bone grey, two branches snapped
    cm = {rm('#ff6a8a'): B_MID, rm('#ff9ac0'): B_LT, rm('#e0647a'): B_DK, rm('#f07f91'): B_MID,
          rm('#c8406a'): B_DK, rm('#ff9aa8'): B_LT}
    for box in ((30, 198, 66, 244), (440, 196, 476, 242)):
        p.recolor(box, lambda r_, g, b: cm.get((r_, g, b)))
    CORAL = {B_LT, B_MID, B_DK}

    def snap(x0, x1, y0, y1):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                if col(x, y) in CORAL:
                    q = x0 - 1
                    while col(q, y) in CORAL:
                        q -= 1
                    px[x, y] = px[q, y]
    snap(41, 48, 200, 221)
    snap(465, 472, 198, 216)
    # grain so the dead coral is not flat: a darker right edge and pits
    for box in ((30, 198, 66, 244), (440, 196, 476, 242)):
        for y in range(box[1], box[3] + 1):
            for x in range(box[0], box[2] + 1):
                if col(x, y) in CORAL and col(x + 1, y) not in CORAL:
                    p.dot(x, y, B_DK)
                elif col(x, y) in CORAL and (x * 3 + y) % 11 == 0 and col(x - 1, y) in CORAL:
                    p.dot(x, y, B_DK)
    plank(68, 240, 10, 0.2, th=3, cols=(B_LT, B_MID, B_DK))

    am = {rm('#58d878'): hx('#86a078'), rm('#38a858'): hx('#5f7a58')}
    p.recolor((0, 180, 479, 262), lambda r_, g, b: am.get((r_, g, b)))
    # new algae strands, dull
    def strand(x, yb, h, seed, cols=(M_MID, M_DK)):
        rr = random.Random(seed)
        ph = rr.uniform(0, 6)
        for i in range(h):
            cx = x + int(round(1.6 * math.sin(i / 5.0 + ph)))
            y = yb - i
            p.dot(cx, y, cols[0])
            if i < h - 2:
                p.dot(cx + 1, y, cols[1])
            if i % 7 == 3 and i < h - 4:
                p.dot(cx - 1, y, cols[0])
                p.dot(cx - 1, y - 1, cols[0])
    for i, (sx, yb, h) in enumerate(((10, 236, 30), (14, 238, 20), (74, 234, 26), (104, 240, 18), (232, 258, 16),
                                     (301, 226, 34), (305, 228, 22), (436, 234, 28), (476, 240, 34), (366, 226, 18),
                                     (123, 236, 24))):
        strand(sx, yb, h, 50 + i)

    # ---- the burst chest: lid torn off, front board split, the hoard spilled into the silt -------------------------
    C_W, C_WD, C_WL = rm('#a9714a'), rm('#8a5a3c'), rm('#c88858')
    C_SD = rm('#623b30')
    GOLD = (G_LT, G_MID, G_DK)

    def chest():
        x0, x1, xs, y0, y1 = 380, 418, 424, 230, 250            # front face x0..x1, side face to xs
        vb = {}                                                   # the V break in the front board
        for x in range(390, 407):
            d = abs(x - 397.5)
            vb[x] = 238 - int(d * 0.9) + (1 if x in (393, 401) else 0) - (1 if x == 404 else 0)
        for y in range(222, y1 + 1):
            for x in range(x0, xs + 1):
                if x > x1:                                        # side face, its top slants up to the back
                    top = 229 - (x - x1)
                    if y < top:
                        continue
                    c = C_SD if (y - y0) % 7 else C_WD
                    if x == x1 + 1:
                        c = C_WD
                    p.dot(x, y, c)
                    continue
                if y < 222 + 1:
                    continue
                if y < y0:                                         # the open mouth: back rim, inner wall, dark well
                    if x < x0 + 1 or x > x1:
                        continue
                    c = C_WL if y == 223 else (C_WD if y <= 225 else (VD2 if y < 228 else VD))
                    for (m0, m1) in ({229: ((383, 389), (408, 416)), 228: ((384, 387), (410, 414)),
                                      227: ((411, 412),)}.get(y, ())):
                        if m0 <= x <= m1:                            # what is left of the hoard, in two heaps
                            c = G_MID if x < m1 - 1 else G_DK
                            if y == 228 and x == m0 or y == 227:
                                c = G_LT
                    if y == 224 and x % 9 == 3:
                        c = C_SD
                    p.dot(x, y, c)
                    continue
                if x in vb and y <= vb[x]:                         # through the split: the dark inside
                    p.dot(x, y, VD2 if y < vb[x] - 2 else VD)
                    continue
                k = (y - y0) % 7                                    # three boards, lit top row, seam below
                c = C_WL if k == 0 else (C_WD if k == 6 else C_W)
                if (x * 5 + (y - y0) // 7 * 7) % 17 == 0 and 0 < k < 6:
                    c = C_WD                                        # a grain knot
                if x == x0:
                    c = C_WL if k < 6 else C_W
                if y == y1:
                    c = C_SD
                p.dot(x, y, c)
            # lit splinter lip on the break
        for x in vb:
            if col(x, vb[x] + 1) not in (VD, VD2):
                p.dot(x, vb[x] + 1, C_WL)
        for (x, y) in ((391, 235), (403, 234), (395, 238), (400, 238)):
            p.dot(x, y, C_WL)
        # tarnished iron straps with rivets
        for sx in (384, 412):
            for y in range(230, 251):
                if col(sx, y) in (VD, VD2):
                    continue
                p.dot(sx, y, RIM)
                p.dot(sx + 1, y, I_MID)
                p.dot(sx + 2, y, I_DK)
                if y in (232, 241, 248):
                    p.dot(sx + 1, y, I_LT)
            for y in (236, 245):
                p.dot(sx + 1, y, hx('#74907c'))                     # verdigris
        for y in range(227, 251):                                   # strap round the side
            p.dot(421, y, I_DK)
        # coins caught on the split
        for (x, y) in ((396, 236), (399, 237), (397, 239)):
            p.dot(x, y, G_MID)
    inked(chest)
    for x in range(379, 428):                                       # contact shadow under the chest
        for y in (251, 252):
            if is_sand(x, y):
                p.dot(x, y, S5 if y == 251 else S4)

    def coins():
        shadow([(x, 252 + k) for x in range(376, 404) for k in (0, 1)])
        ax, ay = 389, 240                                           # heap apex, spilling from the split
        for y in range(ay, 253):
            half = int((y - ay) * 1.15) + 1
            for x in range(ax - half, ax + half + 1):
                if y == 252 and abs(x - ax) > half - 2:
                    continue
                t = (x - ax) / float(half + 1)
                c = G_LT if t < -.35 and y < 250 else (G_MID if t < .4 else G_DK)
                if y >= 251:
                    c = G_DK if t > -.6 else G_MID
                if (y - ay) % 3 == 2 and (x + (y // 3) * 2) % 5 in (0, 1) and c != G_DK:
                    c = G_DK if c == G_MID else G_MID                # coin rims, stacked rows
                p.dot(x, y, c)
        for (x, y) in ((396, 238), (395, 239), (394, 240)):         # the trickle out of the split
            p.dot(x, y, G_LT); p.dot(x + 1, y, G_DK)
    inked(coins)
    def lid():
        shadow([(x, 249 + k) for x in range(432, 458) for k in (0, 1)])
        for i in range(24):
            y = 239 - int(round(i * 0.3))
            for j in range(9):
                c = C_WL if j < 2 else (C_W if j < 6 else C_WD)
                if i in (4, 5, 18, 19):
                    c = RIM_D if j > 1 else RIM
                p.dot(432 + i, y + j, c)
    inked(lid)

    def loose():
        for (x, y) in ((369, 256), (374, 260), (406, 256), (360, 262)):
            p.dot(x, y, G_LT); p.dot(x + 1, y, G_LT); p.dot(x + 2, y, G_MID)
            p.dot(x, y + 1, G_MID); p.dot(x + 1, y + 1, G_DK); p.dot(x + 2, y + 1, G_DK)
        # a goblet on its side
        stamp(414, 255, ["GGg....", "Gggggg.", "Gggdgg.", "ggd...."], {'g': G_MID, 'G': G_LT, 'd': G_DK})
    inked(loose)

    # ---- anchor and its tangled chain ----------------------------------------------------------------------------
    def anchor():
        shadow([(x, 258 + k) for x in range(326, 350) for k in (0, 1)])
        for i in range(22):                                            # shank
            x, y = 339 - int(round(i * 0.18)), 232 + i
            p.dot(x, y, I_LT); p.dot(x + 1, y, I_MID); p.dot(x + 2, y, I_DK)
        for x in range(331, 348):                                      # stock
            p.dot(x, 236, I_LT); p.dot(x, 237, I_DK)
        stamp(323, 246, ["I...............d",
                         "Im.............md",
                         "Imm...........mmd",
                         ".Immm.......mmmd.",
                         "..Immmmm.mmmmmd..",
                         "...IImmmmmmmdd...",
                         ".....dddddddd...."], {'I': I_LT, 'm': I_MID, 'd': I_DK})
        stamp(337, 227, [".II.", "I..d", "I..d", ".md."], {'I': I_LT, 'm': I_MID, 'd': I_DK})   # ring
    inked(anchor)
    drift(334, 257, 12, 3)

    def chain():
        pts = [(352, 169 + i) for i in range(0, 52)]
        for (ccx, ccy, rx, ry, a0) in ((350, 227, 5, 3, 0), (356, 231, 5, 3, 2.5), (347, 232, 4, 2, 1)):
            n = 30
            for i in range(n):
                a = a0 + i * 2 * math.pi / n
                pts.append((ccx + int(round(rx * math.cos(a))), ccy + int(round(ry * math.sin(a)))))
        pts += [(343, 231), (342, 230), (341, 229)]
        for i, (x, y) in enumerate(pts):
            c = I_LT if i % 4 < 2 else I_DK
            p.dot(x, y, c)
            p.dot(x + 1, y, I_MID if i % 4 < 2 else I_DK)
        stamp(350, 165, ["dddd", "dVVd", "dVVd", "dddd"], {'d': I_DK, 'V': VD2})        # hawse hole
    inked(chain)

    # ---- small things left behind -----------------------------------------------------------------------------------
    def hat():                                                          # the keeper's cap, faded, left in the silt
        shadow([(x, 261 + k) for x in range(266, 278) for k in (0, 1)])
        stamp(263, 250, ["....r....",
                         "....rR...",
                         "...rRR...",
                         "...rRRd..",
                         "..rRRRd..",
                         "..rRRRd..",
                         ".rRRRRdd.",
                         ".rRRRRRd.",
                         "rRRRRRRdd",
                         "rRRRRRRdd",
                         "rRRRRRRdd"], {'r': hx('#b06a5e'), 'R': hx('#96584f'), 'd': hx('#74464a')})
    inked(hat)
    drift(267, 262, 8, 2)

    def lantern2():                                                     # a lantern dropped in the silt
        shadow([(x, 262 + k) for x in range(209, 221) for k in (0, 1)])
        stamp(208, 255, ["..iii..", ".i...i.", ".iiiii.", "iGgigdi", "iggiddi", "iggidgi", "iiiiiii"],
              {'i': I_MID, 'g': hx('#56655f'), 'G': hx('#7b8a80'), 'd': VD})
    inked(lantern2)
    drift(212, 263, 7, 2)

    def shell():
        stamp(142, 258, [".ss.", "sSos", "sooo"], {'s': hx('#c9c2b0'), 'S': hx('#e0dccb'), 'o': hx('#9c9486')})
    inked(shell)
