"""Ruined Stepped Seed Temple: overcast, the seed dead and cracked, terraces crumbled, planters gone to dry stalks."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from ruin_lib import Pic, hx, INK

DUSK = hx('#6a6488')
SAT, VAL = 0.55, 0.86


def build(p):
    import math, random, colorsys
    px = p.px
    R = random.Random(41)

    def rm(h):
        r, g, b = hx(h) if isinstance(h, str) else h
        hh, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        c = [round(k * 255) for k in colorsys.hsv_to_rgb(hh, min(1, s * SAT), min(1, v * VAL))]
        return tuple(round(c[i] * .88 + DUSK[i] * .12) for i in range(3))

    def col(x, y):
        return px[x, y][:3] if 0 <= x < p.w and 0 <= y < p.h else None

    def inked(draw):
        b = p.snapshot()
        draw()
        p.outline_new(b)

    def stamp(x, y, rows, pal):
        for j, row in enumerate(rows):
            for i, ch in enumerate(row):
                if ch in pal:
                    p.dot(x + i, y + j, pal[ch])

    # =========================== 1. before the remap: lights out, keeper's bird gone =======================
    SKY1, SKY2, SKY3 = hx('#58b0e0'), hx('#7cc8e8'), hx('#a4dcec')
    HALO = {hx(h) for h in ('#79bacf', '#9bc3be', '#96cdd5', '#b0d2c2')}
    SPARK = {hx(h) for h in ('#fff0a8', '#fff4d6', '#d0e5ad', '#c0e6b8', '#f3d5a4', '#b0e8c4', '#bccdac', '#97ba82',
                             '#809065')}
    UNTINT = {hx('#75ad7f'): hx('#52a07c'), hx('#96cd98'): hx('#7cc89c'), hx('#b0d295'): hx('#7cc89c'),
              hx('#567558'): hx('#3a7a62'), hx('#c09d72'): hx('#b08c6c'), hx('#ddb888'): hx('#d4ae88'),
              hx('#7e6855'): hx('#5e4a48'), hx('#806a4e'): hx('#8a6c5a'), hx('#614642'): hx('#5e4a48')}
    SEEDC = {hx(h) for h in ('#fce67c', '#f4cc4a', '#e0aa2c', '#f5b82e', '#bc8420', '#8a5a1a', '#fff0a8')}

    # which pixels belong to the seed itself (inside its ink outline)?  flood from the middle of the seed
    seed_px = set()
    st = [(240, 30)]
    while st:
        x, y = st.pop()
        if (x, y) in seed_px or not (215 <= x <= 265 and 8 <= y <= 52) or col(x, y) == INK:
            continue
        seed_px.add((x, y))
        st += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]

    def sky_at(x, y):
        t = min(1.0, max(0.0, (x - 198) / 78.0))
        return SKY1 if y <= 35 + round(11 * (1 - math.cos(math.pi * t)) / 2) else SKY2
    for y in range(0, 80):
        for x in range(190, 292):
            c = col(x, y)
            if (x, y) in seed_px:
                continue
            if c in HALO or (c in SPARK and y < 49):
                p.dot(x, y, sky_at(x, y))
            elif c in UNTINT:
                p.dot(x, y, UNTINT[c])
    for _ in range(3):                                   # sparkles lying over the slab / shrine: take a neighbour
        for y in range(49, 80):
            for x in range(200, 282):
                if col(x, y) in SPARK:
                    n = col(x - 1, y)
                    p.dot(x, y, n if n not in SPARK else col(x, y + 1))
    # the door glow is out
    p.recolor((231, 62, 249, 78), lambda r, g, b: hx('#3a2030') if (r, g, b) == hx('#f0a050') else None)

    # the red bird and its blue perch: sky and planter painted back
    for yy in range(129, 150):
        a, b_ = px[101, yy], px[127, yy]
        for xx in range(102, 127):
            px[xx, yy] = a if xx < 115 else b_
    for yy in range(149, 158):
        for xx in range(103, 110):
            px[xx, yy] = px[xx + 9, yy]

    # flowers: planter blooms and meadow blooms wither away (taken out; dry stalks come later)
    FLOWER = {hx(h) for h in ('#f5a03c', '#e8493b', '#ffd24a', '#ffa898', '#f080a8', '#a02030', '#ffe38a',
                              '#fff2dc', '#f5b82e', '#fff8e8', '#e0aa2c')}
    for y in range(56, 262):
        for x in range(0, 480):
            if col(x, y) in FLOWER and (x, y) not in seed_px:
                if y > 215 or col(x, y) not in (hx('#fff8e8'),):
                    if y < 215 and col(x, y) in (hx('#f5b82e'), hx('#e0aa2c')):
                        p.dot(x, y, hx('#8a6c5a'))            # gold studs on the jade bands tarnish
                    else:
                        n = col(x, y + 1)
                        p.dot(x, y, n if n not in FLOWER else col(x + 1, y + 1))
    for _ in range(2):
        for y in range(216, 262):
            for x in range(1, 479):
                if col(x, y) in FLOWER:
                    p.dot(x, y, col(x - 1, y))

    # =========================== 2. overcast remap ==========================================================
    p.remap(sat=SAT, val=VAL, tint=DUSK)
    ink_rm = rm('#2b1c26')
    p.recolor((0, 0, 479, 269), lambda r, g, b: INK if (r, g, b) == ink_rm else None)

    # the seed: dead, dull husk
    def dead(r, g, b):
        hh, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        return tuple(round(k * 255) for k in colorsys.hsv_to_rgb(hh + .01, s * .5, v * .8))
    for (x, y) in seed_px:
        px[x, y] = dead(*col(x, y)) + (255,)
    # its two leaves wither brown
    LEAF = {rm(h): hx(c) for h, c in (('#529054', '#6b5a4c'), ('#78b064', '#8a765c'), ('#7db06a', '#8a765c'),
                                      ('#3a704a', '#54463f'), ('#a8d080', '#a08c6a'), ('#4c8a46', '#6b5a4c'),
                                      ('#64a454', '#7a684f'), ('#82c068', '#8a765c'))}
    p.recolor((218, 0, 262, 14), lambda r, g, b: LEAF.get((r, g, b)))

    # palettes
    B_HI, B_LT, B_MID, B_DK, MORT = rm('#f0d2aa'), rm('#d4ae88'), rm('#b08c6c'), rm('#8a6c5a'), rm('#5e4a48')
    VD, VD2 = hx('#33283a'), hx('#231a28')
    RIM = hx('#6f5e62')
    M_LT, M_MID, M_DK = hx('#7d8f62'), hx('#61744e'), hx('#465840')
    DRY_LT, DRY_MID, DRY_DK, DRY_SH = hx('#b3a07c'), hx('#917f63'), hx('#6c5d50'), hx('#4d423f')
    ROOT_LT, ROOT_MID, ROOT_DK = hx('#8a6f5e'), hx('#66504a'), hx('#47363a')
    SKYMAP = {rm(SKY1): hx('#73869a'), rm(SKY2): hx('#8a9bad'), rm(SKY3): hx('#a2b0bc'), rm('#cceadc'): hx('#b3bdc1')}
    p.recolor((0, 0, 479, 215), lambda r, g, b: SKYMAP.get((r, g, b)))
    SKYSET = set(SKYMAP.values()) | {rm('#fff8e8'), rm('#cfe8ee')}
    GRASS = {rm(h) for h in ('#7db06a', '#529054', '#a8d080', '#3a704a', '#326145', '#64a454', '#4c8a46',
                             '#78b064', '#82c068', '#38723c', '#a4d884')}
    G_SH = rm('#326145')
    is_sky = lambda x, y: col(x, y) in SKYSET
    STONE = {B_HI, B_LT, B_MID, B_DK, MORT}

    # =========================== 3. sky: grey clouds, storm banks ==========================================
    cl = {rm('#fff8e8'): hx('#b4b2c2'), rm('#cfe8ee'): hx('#9796ac')}
    p.recolor((0, 3, 479, 110), lambda r, g, b: cl.get((r, g, b)))
    SKYSET |= set(cl.values())

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
                if yy < 4 or not is_sky(xx, yy):
                    continue
                if yy >= bot - 1 and edge > 4:
                    c = hx('#474660')
                elif yy <= top[xx] + 1 and top.get(xx - 1, cy) >= top[xx]:
                    c = hx('#8c8ca6')
                elif yy <= top[xx] + 3 and xx % 23 < 15:
                    c = hx('#74748f')
                else:
                    c = hx('#5e5d79')
                px[xx, yy] = c + (255,)
    marks = []
    for a in ((70, 24, 130, 1, 13), (330, 22, 120, 2, 12), (452, 46, 90, 3, 11), (170, 62, 70, 4, 7),
              (20, 62, 60, 5, 8), (395, 78, 64, 6, 7)):
        storm(*a)
    SKYSET |= {hx(h) for h in ('#474660', '#8c8ca6', '#74748f', '#5e5d79')}

    # =========================== 4. the temple breaks ========================================================
    def brick(x, y):
        """the pixels of the brick under (x,y): everything up to mortar / ink"""
        S = set()
        st = [(x, y)]
        while st:
            a, b = st.pop()
            if (a, b) in S or abs(a - x) > 18 or abs(b - y) > 6 or col(a, b) not in (B_HI, B_LT, B_MID, B_DK):
                continue
            S.add((a, b))
            st += [(a + 1, b), (a - 1, b), (a, b + 1), (a, b - 1)]
        return S

    LEDGE, CHEEK = hx('#a3948c'), hx('#54454e')

    def cavity(S, stub=True):
        """a missing block: a brick stub left in it, the course above chipped, dark under the lip, lit ledge"""
        S = set(S)
        x0, x1 = min(a for a, b in S), max(a for a, b in S)
        y0, y1 = min(b for a, b in S), max(b for a, b in S)
        if stub and x1 - x0 > 7:
            side = R.choice((0, 1))
            w = R.randint(2, 4)
            for (a, b) in list(S):
                t = (a - x0) if side == 0 else (x1 - a)
                if t < w + ((b - y0) // 2 if side == 0 else (y1 - b) // 2):
                    S.discard((a, b))
        # chip into the course above: a little arch of 4-7 px
        n = R.randint(4, 7)
        a0 = R.randint(x0 + 2, max(x0 + 2, x1 - n - 1))
        for i in range(n):
            if (a0 + i, y0) in S:
                for k in (1, 2) if 0 < i < n - 1 else (1,):
                    if col(a0 + i, y0 - k) in STONE:
                        S.add((a0 + i, y0 - k))
        cols = {}
        for (a, b) in S:
            cols.setdefault(a, []).append(b)
        lump = R.randint(x0 + 2, max(x0 + 2, x1 - 4))
        for a, ys in cols.items():
            ys.sort()
            for i, b in enumerate(ys):
                px[a, b] = (VD2 if i < 2 else VD) + (255,)
            if (a + 1) not in cols and len(ys) > 2:
                for b in ys[2:]:
                    px[a, b] = CHEEK + (255,)
            if lump <= a <= lump + 2 and len(ys) > 3:               # a broken bit left on the floor
                px[a, ys[-1]] = B_DK + (255,)
                if a == lump + 1:
                    px[a, ys[-2]] = B_MID + (255,)
            if col(a, ys[-1] + 1) in STONE:
                px[a, ys[-1] + 1] = LEDGE + (255,)
        return S

    holes = []
    for (bx, by) in ((176, 101), (301, 117), (142, 147), (336, 131), (118, 162), (300, 176), (196, 190),
                     (372, 205), (88, 207), (279, 84), (160, 176), (398, 191)):
        S = brick(bx, by)
        if 8 < len(S) < 140:
            holes.append(cavity(S))
    # a wider breach: two bricks and what is under them, tier 5 left
    S = brick(206, 162) | brick(203, 175)
    for (a, b) in list(S):
        for k in (1, 2):
            if col(a, b + k) == MORT:
                S.add((a, b + k))
    cavity(S, stub=False)
    for seeds in (((310, 176), (305, 182)), ((176, 131), (170, 137)), ((330, 205), (322, 211))):
        S = set()
        for q in seeds:
            S |= brick(*q)
        for (a, b) in list(S):
            if col(a, b + 1) == MORT and (a, b + 2) in S:
                S.add((a, b + 1))
        if len(S) > 20:
            cavity(S, stub=False)

    # corners sheared off (stepped along the courses), sky shows through
    def shear(steps, sky_x, side=1):
        """steps: list of (y0, y1, x_cut): remove everything from x_cut outwards on rows y0..y1"""
        for (y0, y1, xc) in steps:
            for yy in range(y0, y1 + 1):
                rng_x = range(xc, sky_x) if side > 0 else range(sky_x + 1, xc + 1)
                for xx in rng_x:
                    px[xx, yy] = px[sky_x, yy]
        for (y0, y1, xc) in steps:                             # new ink edge + lit ledge
            for yy in range(y0, y1 + 1):
                xi = xc - side
                if col(xi, yy) not in SKYSET:
                    px[xi, yy] = INK + (255,)
        for i, (y0, y1, xc) in enumerate(steps[:-1]):
            xn = steps[i + 1][2]
            for xx in range(min(xc, xn) - (1 if side > 0 else 0), max(xc, xn) + (0 if side > 0 else 1)):
                if col(xx, y1 + 1) not in SKYSET:
                    px[xx, y1 + 1] = INK + (255,)
    shear([(88, 101, 303), (102, 107, 309), (108, 113, 314), (114, 119, 319)], 330, 1)       # tier 3 right
    shear([(148, 161, 108), (162, 167, 104)], 93, -1)                                         # tier 5 left
    shear([(58, 71, 198), (72, 77, 194)], 183, -1)                                            # tier 2 left

    # the jade cap: right end snapped off
    for yy in range(48, 58):
        for xx in range(267 + (yy % 3 == 0), 279):
            px[xx, yy] = px[282, yy] if is_sky(282, yy) else rm(SKY2) + (255,)
        if col(266 + (yy % 3 == 0), yy) not in SKYSET:
            px[266 + (yy % 3 == 0), yy] = INK + (255,)

    # stairs slump: the flight between the 4th and 5th terrace sags to the right in three slabs
    snap = p.snapshot().load()
    for yy in range(128, 155):
        xl = 240
        while col(xl, yy) != INK and xl > 215:
            xl -= 1
        xr = 240
        while col(xr, yy) != INK and xr < 265:
            xr += 1
        for xx in range(xl + 1, xr):
            off = 0 if xx < 234 else (1 if xx < 246 else 3)
            px[xx, yy] = snap[xx, yy - off]
        for xb in (234, 246):
            if yy % 6 != 0:
                px[xb + ((yy // 4) % 2), yy] = MORT + (255,)
    # a breach in the flight below: broken treads, dark underneath, the lower treads still showing in the gloom
    bands = ((161, 163, 232, 243), (164, 167, 228, 247), (168, 171, 227, 249), (172, 175, 229, 248),
             (176, 178, 232, 245), (179, 180, 236, 241))
    S = set()
    for (y0, y1, xl, xr) in bands:
        for yy in range(y0, y1 + 1):
            a, b = xl + R.choice((0, 0, 1)), xr - R.choice((0, 0, 1))
            for xx in range(a, b + 1):
                S.add((xx, yy))
    for (a, b) in S:
        up = sum((a, b - k) in S for k in (1, 2))
        px[a, b] = (VD2 if up < 2 else VD) + (255,)
    for (y1, xl, xr) in ((167, 233, 242), (171, 231, 244), (175, 233, 243)):      # sunken treads
        for xx in range(xl, xr + 1):
            px[xx, y1] = CHEEK + (255,)
        for xx in range(xl, xl + 4):
            px[xx, y1] = RIM + (255,)
    for (a, b) in S:
        if (a, b + 1) not in S and col(a, b + 1) not in (INK, CHEEK, RIM):
            px[a, b + 1] = LEDGE + (255,)
        if (a, b - 1) not in S and col(a, b - 1) not in (INK,):
            px[a, b - 1] = MORT + (255,)

    # the door: dark, with a web
    WEB = hx('#8f8a9c')
    for (x, y) in ((234, 67), (235, 68), (236, 69), (237, 70),                       # strand from the corner
                   (233, 72), (234, 71), (235, 70), (237, 68), (238, 67), (239, 66),   # outer thread
                   (233, 69), (236, 66)):
        if col(x, y) == rm('#3a2030') or col(x, y) == hx('#3a2030'):
            px[x, y] = WEB + (255,)

    # the dead seed: split, a shard gone
    for (x, y) in ((240, 13), (240, 14), (241, 15), (241, 16), (240, 17), (239, 18), (239, 19), (240, 20),
                   (241, 21), (242, 22), (242, 23), (241, 24), (240, 25), (240, 26), (239, 27), (238, 28),
                   (238, 29), (239, 30), (240, 31), (240, 32), (241, 33), (243, 23), (244, 24), (245, 24),
                   (237, 19), (236, 20), (235, 20)):
        px[x, y] = INK + (255,)
    shard = {(x, y) for (x, y) in seed_px if x >= 246 and 30 <= y <= 40 and (x - 246) >= (y - 30) // 3}
    for (x, y) in shard:
        px[x, y] = (VD2 if (x, y - 1) not in shard or (x, y - 2) not in shard else VD) + (255,)
    for (x, y) in shard:
        if (x - 1, y) not in shard:
            px[x, y] = INK + (255,)
        elif (x + 1, y) not in shard or (x + 2, y) not in shard:
            px[x, y] = hx('#5a5048') + (255,)                     # inner wall of the husk catches a little light

    # =========================== 5. dead planters ============================================================
    PL = {rm('#3a704a'): DRY_DK, rm('#a8d080'): DRY_LT, rm('#78b064'): DRY_MID, rm('#529054'): DRY_MID,
          rm('#7db06a'): DRY_MID, rm('#2a5240'): DRY_SH, rm('#326145'): DRY_SH, rm('#4c8a46'): DRY_MID,
          rm('#64a454'): DRY_MID, rm('#82c068'): DRY_LT, rm('#38723c'): DRY_DK, rm('#a4d884'): DRY_LT}
    planters = [(185, 58, 209, 66), (272, 58, 296, 66), (155, 88, 190, 96), (291, 88, 327, 96),
                (125, 118, 160, 126), (322, 118, 358, 126), (95, 148, 130, 156), (352, 148, 388, 156),
                (65, 178, 100, 186), (382, 178, 418, 186)]
    for i, (x0, y0, x1, y1) in enumerate(planters):
        def dry(r, g, b, x0=x0):
            return PL.get((r, g, b))
        keep = R.randint(x0 + 4, x1 - 10)                       # one weed clump per planter stays green
        for yy in range(y0, y1 + 1):
            for xx in range(x0, x1 + 1):
                if keep <= xx <= keep + 6:
                    continue
                c = PL.get(col(xx, yy))
                if c:
                    px[xx, yy] = c + (255,)
        # dry stalks standing above the planter rim
        xx = x0 + 2
        while xx < x1 - 1:
            top = y0 + 2
            while top < y1 and (is_sky(xx, top) or col(xx, top) == INK):
                top += 1
            base = top - 1
            while base > y0 - 2 and col(xx, base) != INK:
                base -= 1
            if col(xx, base) == INK and is_sky(xx, base - 1) and not (i == 5 and xx < 350):
                hgt = R.randint(2, 6)
                lean = R.choice((-1, 0, 0, 1))
                for k in range(1, hgt + 1):
                    sx = xx + (lean if k > hgt // 2 + 1 else 0)
                    if is_sky(sx, base - k):
                        px[sx, base - k] = (DRY_DK if k < hgt else DRY_MID) + (255,)
                if hgt >= 4 and is_sky(xx + lean + 1, base - hgt):
                    px[xx + lean + 1, base - hgt] = DRY_MID + (255,)
            xx += R.randint(2, 5)

    # =========================== 6. moss, vines, roots =======================================================
    def mossrun(x, y, n, drip=True):
        for i in range(n):
            if col(x + i, y) in STONE or col(x + i, y) == RIM:
                px[x + i, y] = (M_LT if i % 5 < 3 else M_MID) + (255,)
                d = 1 if (i in (0, n - 1)) else (2 if (i * 7 + n) % 4 else 3)
                for k in range(1, d + 1 if drip else 1):
                    if col(x + i, y + k) in STONE:
                        px[x + i, y + k] = (M_MID if k < d else M_DK) + (255,)
    for (x, y, n) in ((74, 187, 14), (140, 187, 9), (330, 187, 16), (392, 187, 10), (104, 157, 11), (176, 157, 12),
                      (270, 157, 8), (356, 157, 13), (134, 127, 10), (286, 127, 12), (166, 97, 8), (268, 97, 9),
                      (194, 67, 6), (214, 58, 7), (250, 58, 9), (100, 201, 9), (236, 201, 0), (318, 171, 10),
                      (148, 141, 8), (190, 111, 7), (348, 201, 12), (262, 141, 7)):
        mossrun(x, y, n)
    # moss creeping up the bottom course from the grass
    for xx in range(70, 412):
        if col(xx, 214) in STONE or col(xx, 213) in STONE:
            hgt = (1, 2, 3, 2, 4, 3, 1, 0, 0, 1, 2, 2, 5, 3, 1, 0, 0, 0, 2, 3)[(xx // 2) % 20]
            for k in range(hgt):
                if col(xx, 214 - k) in STONE:
                    px[xx, 214 - k] = (M_DK if k == 0 else (M_MID if k < hgt - 1 else M_LT)) + (255,)
    # moss on the stair treads (left side, where water runs)
    for (x, y, n) in ((224, 196, 9), (226, 152, 6), (228, 112, 7), (245, 206, 8), (229, 88, 5)):
        for i in range(n):
            if col(x + i, y) not in (INK, VD, VD2):
                px[x + i, y] = (M_LT if i % 4 < 2 else M_MID) + (255,)

    # hanging vines from the planters and ledges
    for (x, y, n) in ((128, 157, 17), (158, 127, 13), (188, 97, 15), (294, 97, 9), (354, 157, 20), (384, 187, 14),
                      (98, 187, 12), (206, 67, 8), (274, 67, 12), (324, 127, 16), (212, 58, 9), (344, 157, 8),
                      (170, 127, 7), (78, 187, 18)):
        cx = x
        for i in range(n):
            if i and R.random() < .3:
                cx += R.choice((-1, 1))
            cx = max(x - 2, min(x + 2, cx))
            if col(cx, y + i) in (INK,) and i > 2:
                pass
            px[cx, y + i] = M_DK + (255,)
            if i % 3 == 1:
                s = 1 if (i // 3) % 2 else -1
                if col(cx + s, y + i) != INK or True:
                    px[cx + s, y + i] = M_LT + (255,)
                    px[cx + s, y + i + 1] = M_MID + (255,)

    # the seed's own roots, dried out, still gripping the cap and the shrine
    for pts in (((238, 49), (236, 50), (233, 51), (229, 52), (226, 53), (225, 56), (224, 58), (224, 61), (223, 64),
                 (223, 68), (222, 71)),
                ((242, 49), (245, 51), (249, 52), (253, 53), (254, 57), (255, 60), (255, 63), (256, 66)),
                ((240, 50), (240, 53), (239, 56), (239, 59), (238, 61)),
                ((229, 52), (221, 53), (216, 54), (214, 57), (213, 61))):
        for i in range(len(pts) - 1):
            (xa, ya), (xb, yb) = pts[i], pts[i + 1]
            n = max(abs(xb - xa), abs(yb - ya))
            for k in range(n + 1):
                x, y = round(xa + (xb - xa) * k / n), round(ya + (yb - ya) * k / n)
                if col(x, y) != INK:
                    px[x, y] = (ROOT_MID if (x + y) % 5 else ROOT_LT) + (255,)

    # big roots prising the blocks: from the left thicket over the two lower terraces, and one down the right
    def root(pts, w=2):
        def draw():
            for i in range(len(pts) - 1):
                (x0, y0), (x1, y1) = pts[i], pts[i + 1]
                n = max(abs(x1 - x0), abs(y1 - y0))
                for k in range(n + 1):
                    x = round(x0 + (x1 - x0) * k / n)
                    y = round(y0 + (y1 - y0) * k / n)
                    ww = w if i < len(pts) - 2 else 1
                    for j in range(ww):
                        p.dot(x + j, y, ROOT_LT if j == 0 else ROOT_MID)
                    if ww > 1:
                        p.dot(x + ww - 1, y + 1, ROOT_DK)
        inked(draw)
    root([(60, 196), (70, 192), (82, 195), (96, 203), (112, 200), (126, 208), (138, 213)], 3)
    root([(96, 203), (104, 196), (116, 190), (128, 191)], 2)
    root([(420, 190), (410, 194), (398, 198), (388, 207), (376, 211), (366, 214)], 3)
    root([(248, 181), (251, 188), (249, 196), (253, 204), (252, 214)], 2)

    # =========================== 7. rubble and fallen things ================================================
    def shadow(x0, x1, y, h=2):
        for yy in range(y, y + h):
            for xx in range(x0 + (yy - y), x1 + 1 + (yy - y)):
                if col(xx, yy) in GRASS:
                    px[xx, yy] = G_SH + (255,)

    def block(x, y, w, h, tilt=0, shade=True):
        """a fallen ashlar: lit top strip, darker right end; tilt = px the right end sits lower"""
        def draw():
            for i in range(w):
                dy = (tilt * i) // w
                for j in range(h):
                    c = B_HI if j == 0 else (B_LT if j < h - 2 and i < w - 3 else (B_MID if i < w - 3 else B_DK))
                    if j == h - 1:
                        c = B_DK if i >= w - 3 else B_MID
                    p.dot(x + i, y + j + dy, c)
        if shade:
            shadow(x + 1, x + w + 2, y + h + max(tilt, 0), 2)
        inked(draw)

    def stone(x, y, w, h):
        """an angular chunk sitting on row y: clipped top corners, lit top, dark right/bottom"""
        def draw():
            for j in range(h):
                yy = y - h + 1 + j
                inset_l = 1 if j == 0 else 0
                inset_r = 2 if j == 0 else (1 if j == 1 and h > 3 else 0)
                for i in range(inset_l, w - inset_r):
                    c = B_HI if j == 0 else (B_DK if (j == h - 1 or i >= w - 2) else (B_LT if i < w // 2 else B_MID))
                    p.dot(x + i, yy, c)
        inked(draw)

    def rubble(x, y, stones, on_grass=True):
        """stones: (dx, dy, w, h) drawn back to front"""
        if on_grass:
            x0 = min(s[0] for s in stones)
            x1 = max(s[0] + s[2] for s in stones)
            shadow(x + x0 + 1, x + x1 + 2, y + 2, 2)
        for (dx, dy, w, h) in stones:
            stone(x + dx, y + dy, w, h)

    # heap under the sheared tier-3 corner, lying on the terrace below
    rubble(324, 119, ((8, -3, 7, 5), (0, 0, 6, 4), (14, 0, 5, 3), (5, 0, 8, 5), (19, 0, 4, 3)), on_grass=False)
    # under the tier-5 left shear
    rubble(84, 177, ((4, -2, 5, 4), (0, 0, 5, 3), (6, 0, 6, 4)), on_grass=False)
    # under the tier-2 left shear
    rubble(176, 89, ((0, 0, 5, 3), (6, 0, 4, 3)), on_grass=False)
    # at the foot of the temple
    block(150, 219, 12, 6, 0)
    block(196, 224, 10, 6, 1)
    rubble(206, 221, ((6, -3, 6, 5), (0, 0, 6, 4), (11, 0, 5, 3), (5, 0, 7, 5)))
    block(262, 217, 11, 6, -1)
    rubble(241, 185, ((0, 0, 4, 3), (5, 0, 5, 4), (9, 0, 3, 2)), on_grass=False)   # what fell out of the stairs
    rubble(350, 221, ((5, -2, 6, 5), (0, 0, 5, 3), (10, 0, 6, 4)))
    block(388, 221, 11, 6, 2)
    rubble(108, 222, ((0, 0, 5, 3), (4, 0, 6, 4)))
    block(318, 222, 9, 5, 0)
    stone(228, 219, 4, 3)
    stone(274, 228, 4, 3)
    stone(136, 232, 5, 3)

    # the snapped jade cap end, leaning on the planter
    def jade():
        p.poly([(280, 52), (288, 55), (286, 60), (278, 57)], rm('#52a07c'))
        p.line([(280, 52), (288, 55)], rm('#7cc89c'))
        p.line([(279, 57), (286, 60)], rm('#2c5a4c'))
    inked(jade)
    # the seed shard, fallen on the cap
    def sh():
        p.poly([(254, 46), (259, 44), (262, 47), (257, 48)], dead(*rm('#e0aa2c')))
        p.line([(255, 46), (259, 44)], dead(*rm('#fce67c')))
    inked(sh)

    # ---- the split pillar (left foreground) and its fallen drum ---------------------------------------------
    P_HI, P_LT, P_MID, P_DK = B_HI, B_LT, B_MID, B_DK
    def pillar():
        x0, y0, x1, y1 = 164, 211, 179, 242
        for yy in range(y0, y1 + 1):
            for xx in range(x0, x1 + 1):
                t = xx - x0
                c = P_HI if t < 2 else (P_LT if t < 7 else (P_MID if t < 12 else P_DK))
                left = t < 8
                top = y0 + ((0, 0, 1, 1, 0, 2, 3, 5)[t] if left else (9, 7, 6, 6, 7, 6, 8, 9)[t - 8])
                # the split: a wedge of nothing between the two halves, closing at y=233
                half = max(0, (233 - yy) // 6)
                gap = (172 - half) <= xx <= (172 + half) and yy < 233
                if yy >= top and not gap:
                    p.dot(xx, yy, c)
        for yy in (224, 235):                                    # drum joints
            for xx in range(x0, x1 + 1):
                if col(xx, yy) in (P_HI, P_LT, P_MID, P_DK):
                    p.dot(xx, yy, MORT)
        for xx in range(x0 - 2, x1 + 3):                         # plinth
            for yy in range(243, 247):
                p.dot(xx, yy, P_LT if yy == 243 else (P_MID if xx < x1 else P_DK))
    shadow(166, 190, 247, 3)
    inked(pillar)
    for (x, y) in ((172, 233), (172, 234), (173, 236), (173, 237), (173, 238), (174, 239), (174, 240)):
        px[x, y] = INK + (255,)                                  # the split runs on down as a crack
    mossrun(162, 243, 6, drip=True)
    for (x, y) in ((165, 212), (166, 212), (164, 213), (165, 213), (164, 214)):
        px[x, y] = M_LT + (255,)

    def drum():
        for yy in range(240, 250):
            for xx in range(186, 204):
                c = P_HI if yy == 240 else (P_LT if yy < 245 else (P_MID if yy < 248 else P_DK))
                p.dot(xx, yy, c)
        p.ell(204, 244, 3, 4, P_MID)                              # the round end face
        p.ell(204, 244, 1, 2, P_DK)
        for yy in range(240, 250):                                # broken left end
            for xx in range(186, 186 + (2, 0, 1, 3, 2, 0, 1, 2, 0, 1)[yy - 240]):
                px[xx, yy] = snapd[xx, yy]
    shadow(188, 208, 250, 2)
    snapd = p.snapshot().load()
    inked(drum)
    for xx in (192, 198):
        for yy in range(241, 249):
            px[xx, yy] = MORT + (255,)

    # ---- carved riddle stones, fallen and cracked (right foreground) ----------------------------------------
    GLY, GLY2 = hx('#55706c'), hx('#3f5556')                   # the carvings: a dull, dead teal
    def tablet(x, y, w, h, lean):
        """an upright tablet leaning `lean` px to the right at its top, rounded head"""
        def draw():
            for j in range(h):
                off = (lean * (h - j)) // h
                inset = 2 if j == 0 else (1 if j == 1 else 0)
                for i in range(inset, w - inset):
                    c = P_HI if (i == inset or j == 0) else (P_LT if i < w - 4 else (P_MID if i < w - 2 else P_DK))
                    p.dot(x + i + off, y + j, c)
        inked(draw)
    shadow(292, 318, 248, 3)
    tablet(292, 222, 16, 26, 5)
    # glyphs follow the lean
    def gly(rows, x, y, h0, lean, y_top):
        for j, row in enumerate(rows):
            for i, ch in enumerate(row):
                if ch != '.':
                    off = (lean * (h0 - (y + j - y_top))) // h0
                    p.dot(x + i + off, y + j, GLY if ch == 'o' else GLY2)
    gly(['..ooo..', '.o...o.', 'o..o..o', 'o.o.o.o', 'o..o..o', '.o...o.', '..ooo..'], 296, 226, 26, 5, 222)
    gly(['o.o.o.o', '.......', '.ooooo.', '.......', '..o.o..'], 296, 236, 26, 5, 222)
    # crack across it
    for (x, y) in ((296, 233), (297, 233), (298, 234), (299, 234), (300, 235), (301, 234), (302, 234), (303, 233),
                   (304, 233), (305, 232), (306, 232), (307, 231)):
        px[x + 1, y] = INK + (255,)
    for xx in range(291, 300):
        for k in range((1, 2, 3, 2, 1, 2, 1, 0, 1)[xx - 291]):
            if col(xx, 247 - k) in STONE:
                px[xx, 247 - k] = (M_MID if k else M_DK) + (255,)

    # a second stone, flat on its back and broken in two
    def flat():
        p.poly([(322, 240), (338, 238), (341, 246), (324, 248)], P_LT)
        p.line([(322, 240), (338, 238)], P_HI)
        p.line([(324, 248), (341, 246)], P_DK)
        p.poly([(344, 239), (352, 240), (353, 247), (345, 246)], P_LT)
        p.line([(344, 239), (352, 240)], P_HI)
        p.line([(345, 246), (353, 247)], P_DK)
    shadow(324, 356, 248, 2)
    inked(flat)
    stamp(326, 241, ['.oo..o.o..', 'o..o.....o', '.oo..ooo..', '......o...'], {'o': GLY})
    stamp(346, 242, ['o.o.', '.o..', 'o.oo'], {'o': GLY})

    # =========================== 8. weeds, dry grass, one seedling ==========================================
    def tuft(x, y, dry=True, hgt=4):
        c0, c1 = (DRY_MID, DRY_LT) if dry else (M_MID, M_LT)
        for i, (dx, h) in enumerate(((-2, hgt - 2), (-1, hgt - 1), (0, hgt), (1, hgt - 1), (3, hgt - 2))):
            for k in range(h):
                xx = x + dx + (1 if (k == h - 1 and dx > 0) else (-1 if (k == h - 1 and dx < 0) else 0))
                if col(xx, y - k) not in (INK,):
                    px[xx, y - k] = (c1 if (i % 2 == 0 and k >= h - 2) else c0) + (255,)
    for (x, y, d, h) in ((132, 222, True, 5), (184, 218, True, 4), (228, 232, True, 5), (276, 226, True, 4),
                         (306, 218, False, 4), (372, 228, True, 5), (238, 248, True, 6), (258, 240, False, 4),
                         (146, 236, False, 4), (210, 252, True, 5), (332, 228, True, 4), (282, 254, True, 5),
                         (402, 218, True, 4), (96, 218, False, 4), (156, 252, True, 4)):
        tuft(x, y, d, h)
    # weeds in the stair joints
    for (x, y) in ((231, 102), (250, 120), (229, 160), (252, 172), (232, 208), (247, 92)):
        px[x, y] = M_MID + (255,)
        px[x, y - 1] = M_LT + (255,)
        px[x + 1, y - 2] = M_LT + (255,)

    # the charm: one living seedling by the fallen shard of the seed, at the foot of the stairs
    SG, SG2 = hx('#8fc46a'), hx('#5f9a52')
    stamp(238, 221, ['o...o', 'ooxoo', '.oxo.', '..x..', '..x..'], {'o': SG, 'x': SG2})
    for xx in range(237, 244):
        if col(xx, 226) in GRASS:
            px[xx, 226] = G_SH + (255,)
