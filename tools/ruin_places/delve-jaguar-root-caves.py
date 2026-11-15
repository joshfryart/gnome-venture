"""Ruined Jaguar Root Caves: the jaguar keeper is gone, the roof has come down on his stone seat.

Cave-in through the ceiling (a grey shaft of daylight falls on the rubble), dead snapped roots, rock fall half blocking
the cave mouth, cracked arch, dead glow-fungus, burnt-out torches, puddles, cobwebs. Hard pixels only.
"""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from ruin_lib import Pic, hx, INK
import math, random, colorsys

DUSK = (0x6a, 0x68, 0x80)
SAT, VAL = 0.55, 0.88


def rm(h):
    """the colour a live-art colour becomes after the overcast remap"""
    r, g, b = hx(h) if isinstance(h, str) else h
    hh, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    c = [round(k * 255) for k in colorsys.hsv_to_rgb(hh, min(1, s * SAT), min(1, v * VAL))]
    return tuple(round(c[i] * .88 + DUSK[i] * .12) for i in range(3))


def build(p):
    px = p.px
    WALL_RAW = [hx(h) for h in ('684b5d', '563c52', '7a5a68', '241a30', '3c2a42', '302239')]
    wall_raw = set(WALL_RAW)
    orig = {(x, y): px[x, y] for y in range(p.h) for x in range(p.w)}

    def is_wall_raw(x, y):
        return orig[(x, y)][:3] in wall_raw

    # ---- 1. heal: paint the wall back where something is removed (tile-wise copy of clean wall) -------------
    def heal(pts, tile=20):
        pts = set(pts)
        tiles = {}
        for (x, y) in pts:
            tiles.setdefault((x // tile, y // tile), []).append((x, y))
        offs = sorted(((dx, dy) for dx in range(-200, 201, 2) for dy in range(-90, 91, 2)),
                      key=lambda o: abs(o[0]) + 2 * abs(o[1]))
        last = None
        for k in sorted(tiles):
            tp = tiles[k]
            cand = ([last] if last else []) + offs
            for (dx, dy) in cand:
                ok = True
                for (x, y) in tp:
                    sx, sy = x + dx, y + dy
                    if not (0 <= sx < p.w and 5 <= sy < 200) or (sx, sy) in pts or not is_wall_raw(sx, sy):
                        ok = False
                        break
                if ok:
                    for (x, y) in tp:
                        px[x, y] = orig[(x + dx, y + dy)]
                    last = (dx, dy)
                    break

    def nonwall(box):
        x0, y0, x1, y1 = box
        return [(x, y) for y in range(y0, y1 + 1) for x in range(x0, x1 + 1) if not is_wall_raw(x, y)]

    # the jaguar (body, head, tail) -> wall
    jag = nonwall((138, 92, 292, 203)) + nonwall((196, 90, 204, 91)) + nonwall((268, 98, 292, 203))
    heal(jag)
    # his paws on the slab -> slab top copied from the clean left part
    for dst in (141, 181):
        p.copy_block((98, 200), (dst, 200), 40, 13)
    for yy in range(200, 204):                                  # rows above the slab top that were paws
        for xx in range(138, 222):
            if px[xx, yy][:3] not in wall_raw and px[xx, yy][:3] != INK:
                px[xx, yy] = orig[(xx - 100, yy - 30)] if is_wall_raw(xx - 100, yy - 30) else (0x68, 0x4b, 0x5d, 255)

    # snapped roots: everything of these strands below the break goes
    CUTS = (((118, 56, 137, 112), 125), ((269, 58, 285, 100), 279),
            ((150, 78, 160, 93), 155), ((20, 70, 31, 114), 26))
    for box, _ in CUTS:
        heal(nonwall(box), tile=12)
    heal([q for q in nonwall((210, 3, 237, 66)) if q[1] != 2] + nonwall((190, 3, 204, 40))
         + [q for q in nonwall((243, 3, 268, 100)) if q[1] != 2], tile=12)

    # the sun goes behind cloud (before the remap, on true colours, inside the arch only)
    SKY = hx('a8dcc8')
    for yy in range(92, 132):
        for xx in range(390, 432):
            c = px[xx, yy][:3]
            if (xx - 410) ** 2 + (yy - 112) ** 2 <= 19 * 19 and c in (hx('fff4b0'), hx('ffffd0'), hx('f8f0b8'),
                                                                      hx('fff0c8'), hx('e8f4c0'), hx('ffe27a')):
                px[xx, yy] = SKY + (255,)

    # ---- 2. overcast remap ----------------------------------------------------------------------------------
    p.remap(sat=SAT, val=VAL, tint=DUSK)
    ink_rm = rm(INK)
    p.recolor((0, 0, 479, 269), lambda r, g, b: INK if (r, g, b) == ink_rm else None)

    W_LT, W_MID, W_DK, W_SH, W_VD = rm('7a5a68'), rm('684b5d'), rm('563c52'), rm('3c2a42'), rm('241a30')
    WALLS = {W_LT, W_MID, W_DK, W_SH, W_VD, rm('302239')}
    F_LT, F_MID, F_DK, F_SH, F_VD = rm('d5b782'), rm('aa8765'), rm('8c6a52'), rm('5c4850'), rm('4b3a46')
    SL_LT, SL_MID, SL_DK, SL_SH = rm('b8b0c0'), rm('9a92a8'), rm('7c7490'), rm('54506c')
    ROCK = (hx('a3939c'), hx('8a7885'), hx('6c5a6a'), hx('54455a'), hx('40334a'))    # rim, light, base, shade, deep
    ROCK2 = (hx('aaa4b0'), hx('8e8799'), hx('6f6a80'), hx('555068'), hx('403c52'))   # greyer (ceiling stone)
    R_LT, R_MID, R_DK, R_SH = hx('a59a8c'), hx('86796f'), hx('67595a'), hx('4a3d46')  # dead root
    M_LT, M_MID, M_DK = hx('7f8f66'), hx('637550'), hx('4a5a44')
    FU_LT, FU_MID, FU_DK, FU_ST = hx('9aa09c'), hx('777e80'), hx('575c66'), hx('b0aa9e')
    WEB = hx('a9a2b0')
    SKY_R = rm(SKY)

    def col(x, y):
        return px[x, y][:3] if 0 <= x < p.w and 0 <= y < p.h else None

    def inked(pts):
        s = set(pts)
        for (x, y) in s:
            for (a, b) in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if (a, b) not in s and 0 < a < p.w - 1 and 0 < b < p.h - 1:
                    p.dot(a, b, INK)

    def stamp(x, y, rows, pal, ink=True):
        pts = []
        for j, row in enumerate(rows):
            for i, ch in enumerate(row):
                if ch in pal:
                    p.dot(x + i, y + j, pal[ch])
                    pts.append((x + i, y + j))
        if ink:
            inked(pts)
        return pts

    # ---- 3. outside: grey sky, cloud bands, duller hills ----------------------------------------------------
    def in_mouth(x, y):
        return 333 <= x <= 463 and 66 <= y <= 211 and orig[(x, y)][:3] not in wall_raw

    def outside(r, g, b):
        hh, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        if 0.2 < hh < 0.6:
            sky = v > 0.72 and s < 0.3
            c = colorsys.hsv_to_rgb(hh + (0.08 if sky else 0), s * (0.35 if sky else 0.72), v * (0.9 if sky else 0.92))
            return tuple(round(k * 255) for k in c)
        return None
    for yy in range(66, 212):
        for xx in range(333, 464):
            if in_mouth(xx, yy):
                p.recolor((xx, yy, xx, yy), outside)
    sky_now = col(380, 100)
    CL_DK = tuple(max(0, c - 22) for c in sky_now)
    CL_LT = tuple(min(255, c + 14) for c in sky_now)
    sun_dim = tuple(min(255, c + 22) for c in sky_now)
    for (sx, sy, sw, c) in ((372, 84, 56, CL_DK), (390, 106, 52, CL_DK), (352, 118, 44, CL_LT), (402, 116, 44, CL_DK),
                            (356, 96, 30, CL_LT), (420, 92, 34, CL_LT)):
        for yy, inset in ((sy, 7), (sy + 1, 2), (sy + 2, 0), (sy + 3, 5)):
            for xx in range(sx + inset, sx + sw - inset * 2):
                if in_mouth(xx, yy) and col(xx, yy) in (sky_now, sun_dim):
                    p.dot(xx, yy, c)

    # ---- 4. dead roots: grey and dry ------------------------------------------------------------------------
    root_map = {rm('d8a060'): R_LT, rm('b68050'): R_MID, rm('946040'): R_DK, rm('5c3c3c'): R_SH,
                rm('482e34'): hx('3c3040'), rm('f5b82e'): None}
    banana = {rm('ffc470'): R_LT, rm('f4a74e'): R_MID, rm('e88a2c'): R_DK, rm('f8d8a0'): R_LT,
              rm('ffe27a'): R_LT, rm('f5b82e'): R_MID, rm('ffd75e'): R_LT, rm('d89a28'): R_DK,
              rm('c8841c'): R_DK, rm('b05a28'): R_SH,
              rm('fce475'): R_LT, rm('fff0a0'): R_LT, rm('f8d84a'): R_MID, rm('bc7b36'): R_DK, rm('d89a38'): R_DK}
    p.recolor((0, 0, 479, 212), lambda r, g, b: root_map.get((r, g, b)))
    p.recolor((284, 204, 330, 228), lambda r, g, b: banana.get((r, g, b)))
    # splintered ends where the roots snapped
    for box, cx in CUTS:
        y = box[1] - 1
        for (dx, dy, c) in ((-2, 0, R_DK), (-1, 0, R_LT), (0, 0, R_LT), (1, 0, R_MID), (-1, 1, R_LT), (1, 1, R_DK),
                            (-1, 2, R_LT)):
            p.dot(cx + dx, y + dy, c)
        inked([(cx + dx, y + dy) for (dx, dy) in ((-2, 0), (-1, 0), (0, 0), (1, 0), (-1, 1), (1, 1), (-1, 2))])
        for (a, b) in ((cx - 2, y - 1), (cx - 1, y - 1), (cx, y - 1), (cx + 1, y - 1)):   # do not ink the root itself
            pass

    # ---- 5. the hole in the roof ----------------------------------------------------------------------------
    depth = {}
    prof = [4, 7, 9, 12, 13, 16, 18, 18, 21, 22, 22, 24, 26, 26, 25, 27, 29, 29, 28, 30, 31, 31, 30, 32, 33, 33, 32,
            32, 34, 34, 33, 31, 31, 32, 33, 33, 31, 30, 30, 28, 29, 29, 27, 26, 24, 25, 25, 23, 21, 21, 22, 20, 18,
            17, 17, 15, 13, 13, 14, 12, 10, 9, 9, 7, 5, 4]
    HX0 = 196
    for i, d in enumerate(prof):
        depth[HX0 + i] = d
    HSKY = tuple(min(255, c + 10) for c in sky_now)
    hole = set()
    for xx, d in depth.items():
        for yy in range(0, d + 1):
            if col(xx, yy) in WALLS or yy == 2:
                hole.add((xx, yy))
    for (xx, yy) in hole:
        d = depth[xx]
        i = xx - HX0
        left = i < 22
        right = i > len(prof) - 26
        notch = (i // 5) % 2                                         # broken, stepped edge of the roof slab
        if yy >= d - 1 - notch:                                      # thickness of the roof, seen from below
            c = W_VD if left else (ROCK2[1] if right else ROCK2[3])
        elif yy >= d - 4 - notch:
            c = W_SH if left else (ROCK2[0] if right else ROCK2[2])
        elif yy >= d - 6 - notch and not left:
            c = ROCK2[0] if right and yy >= d - 5 - notch else ROCK2[1]
        elif (xx - 1, yy) not in hole and left:
            c = W_VD
        else:
            c = HSKY
            for (cy_, x0_, x1_) in ((7, 206, 236), (8, 200, 244), (9, 212, 240), (15, 226, 254), (16, 220, 258),
                                    (17, 230, 250)):
                if yy == cy_ and x0_ <= xx <= x1_:
                    c = CL_DK
        p.dot(xx, yy, c)
    for xx, d in depth.items():                                     # ragged ink lip
        if col(xx, d + 1) in WALLS:
            p.dot(xx, d + 1, INK)
    for yy in range(0, 4):
        p.dot(HX0 - 1, yy, INK)
        p.dot(HX0 + len(prof), yy, INK)

    # cracks running out of the hole and through the arch
    def crack(pts, dark=W_VD, lite=None, seed=1):
        r = random.Random(seed)
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = max(abs(x1 - x0), abs(y1 - y0))
            for i in range(n + 1):
                x = round(x0 + (x1 - x0) * i / n)
                y = round(y0 + (y1 - y0) * i / n)
                if col(x, y) in WALLS:
                    p.dot(x, y, dark)
                    if lite and col(x + 1, y) in WALLS and col(x + 1, y) != dark:
                        p.dot(x + 1, y, lite)
    W_HI = hx('8b7482')
    crack([(203, 20), (198, 30), (192, 36), (191, 50), (184, 58), (183, 70)], seed=1)
    crack([(192, 36), (184, 39), (178, 37)], seed=2)
    crack([(243, 27), (248, 40), (246, 51), (254, 60), (255, 72)], seed=3)
    crack([(248, 40), (258, 44)], seed=4)
    crack([(399, 66), (396, 55), (401, 46), (397, 34), (389, 26), (388, 14)], seed=5)
    crack([(401, 46), (411, 40), (414, 31)], seed=6)
    crack([(397, 34), (388, 36)], seed=6)
    crack([(346, 100), (338, 96), (331, 99), (322, 92), (318, 82)], seed=7)
    crack([(458, 108), (464, 100), (470, 102), (476, 92)], seed=8)
    crack([(60, 8), (64, 22), (60, 34), (66, 46)], seed=9)

    # ---- 6. the stone seat: cracked through ---------------------------------------------------------------
    for (xa, ya, xb, yb) in ((171, 204, 174, 211), (174, 211, 171, 218), (171, 218, 176, 224), (176, 224, 175, 230)):
        n = yb - ya
        for i in range(n + 1):
            x = round(xa + (xb - xa) * i / n)
            y = ya + i
            wid = 3 if y < 210 else 2
            for k in range(wid):
                p.dot(x + k, y, hx('2e2438') if k else INK)
            p.dot(x + wid, y, SL_LT if y < 222 else SL_MID)
    for pts in (((120, 206), (126, 212), (124, 219)), ((126, 212), (134, 214)), ((150, 222), (156, 229)),
                ((104, 224), (110, 229))):
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = max(abs(x1 - x0), abs(y1 - y0))
            for i in range(n + 1):
                x, y = round(x0 + (x1 - x0) * i / n), round(y0 + (y1 - y0) * i / n)
                if col(x, y) in (SL_LT, SL_MID, SL_DK):
                    p.dot(x, y, SL_SH)
    # chipped left corner
    for (x, y) in ((92, 204), (93, 204), (94, 204), (95, 204), (92, 205), (93, 205), (92, 206), (96, 204), (93, 206)):
        pass

    # ---- 7. rocks -------------------------------------------------------------------------------------------
    rock_px = set()
    SLAB = {SL_LT, SL_MID, SL_DK, SL_SH, rm('45425e')}

    def rock(cx, cy, rx, ry, seed, pal=ROCK, flat=0.72, shadow=None, moss=False):
        r = random.Random(seed)
        ph = [r.uniform(0, 6.28) for _ in range(3)]
        amp = (0.11, 0.08, 0.05)
        ridge = r.uniform(-0.25, 0.3)
        pts = {}
        for y in range(cy - ry - 3, cy + ry + 3):
            for x in range(cx - rx - 3, cx + rx + 4):
                dx, dy = (x - cx) / rx, (y - cy) / ry
                ang = math.atan2(dy, dx)
                rad = 1 + sum(amp[k] * math.sin((k + 2) * ang + ph[k]) for k in range(3))
                if dx * dx + dy * dy <= rad * rad and dy <= flat:
                    pts[(x, y)] = (dx, dy)
        if shadow:
            by = cy + int(flat * ry)
            for y in range(by - 1, by + 3):
                for x in range(cx - rx + 2 + (y - by), cx + rx + 6 - abs(y - by)):
                    c = col(x, y)
                    if c in (INK, None) or (x, y) in rock_px or c in WALLS or (x, y) in pts:
                        continue
                    if c in SLAB:
                        p.dot(x, y, SL_SH)
                    elif y >= 212:
                        p.dot(x, y, F_VD)
        for (x, y), (dx, dy) in pts.items():
            if dy > 0.38:
                c = pal[4] if dx > 0.25 else pal[3]
            elif dx < ridge + dy * 0.5:
                c = pal[1] if dy < 0.05 else pal[2]
            else:
                c = pal[2] if dy < -0.35 else pal[3]
            p.dot(x, y, c)
        for (x, y), (dx, dy) in pts.items():                        # lit rim, upper left
            if dy < 0.1 and dx < ridge + 0.35 and ((x, y - 1) not in pts or (x - 1, y) not in pts and dy < -0.3):
                p.dot(x, y, pal[0])
        if rx >= 7:                                                 # a facet crease and a chip or two
            x, y = cx + int(ridge * rx), cy - int(ry * 0.75)
            for i in range(int(ry * 0.8)):
                if (x, y) in pts:
                    p.dot(x, y, pal[3])
                y += 1
                if i % 3 == 2:
                    x += 1
            for _ in range(2):
                x, y = cx - r.randint(2, max(3, int(rx * .6))), cy - r.randint(0, max(1, int(ry * .4)))
                for k in range(r.randint(2, 3)):
                    if (x + k, y) in pts and col(x + k, y) == pal[1]:
                        p.dot(x + k, y, pal[2])
        if moss:
            for (x, y), (dx, dy) in pts.items():
                top = (x, y - 1) not in pts
                d2 = (x, y - 2) not in pts
                d3 = (x, y - 3) not in pts
                if dy < -0.15 and -0.7 < dx < 0.55 and (top or d2 or (d3 and (x // 3) % 2)):
                    p.dot(x, y, M_LT if top and dx < 0.1 else (M_MID if top or d2 else M_DK))
        inked(pts)
        rock_px.update(pts)
        return pts

    def rk(cx, base, rx, ry, seed, pal=ROCK, flat=0.72, moss=False, shadow=True):
        return rock(cx, base - int(flat * ry), rx, ry, seed, pal, flat, shadow, moss)
    # pile in the cave mouth (back to front)
    rk(350, 179, 13, 12, 31, ROCK, shadow=False)
    rk(371, 191, 12, 10, 32, ROCK2, shadow=False)
    rk(346, 206, 16, 15, 33, ROCK, moss=True)
    rk(392, 209, 11, 8, 34, ROCK)
    rk(371, 211, 14, 10, 35, ROCK2, moss=True)
    rk(412, 211, 6, 4, 36, ROCK)
    # pile on the seat and around it
    rk(266, 214, 15, 15, 12, ROCK, shadow=False)
    rk(205, 203, 15, 14, 11, ROCK)
    rk(238, 203, 23, 25, 13, ROCK2, flat=0.8)
    rk(256, 176, 9, 8, 10, ROCK, shadow=False)
    rk(187, 203, 7, 5, 14, ROCK2)
    rk(219, 203, 9, 7, 15, ROCK)
    rk(254, 203, 8, 6, 9, ROCK2)
    rk(286, 233, 19, 15, 16, ROCK, moss=True)
    rk(256, 240, 10, 7, 18, ROCK2)
    rk(232, 243, 5, 3, 19, ROCK2)
    rk(336, 244, 4, 3, 20, ROCK)
    rk(160, 243, 5, 4, 21, ROCK)
    rk(196, 249, 3, 2, 22, ROCK2)
    rk(300, 250, 4, 3, 23, ROCK)
    rk(338, 225, 5, 4, 24, ROCK2)
    rk(428, 228, 4, 3, 25, ROCK)
    rk(140, 203, 4, 3, 26, ROCK)

    # ---- 8. the shaft of grey daylight ---------------------------------------------------------------------
    def lighten(x, y, k=(24, 22, 21)):
        r, g, b, a = px[x, y]
        if (r, g, b) != INK:
            px[x, y] = (min(255, r + k[0]), min(255, g + k[1]), min(255, b + k[2]), a)

    def shaft_x(y):
        t = (y - 18) / (212 - 18.0)
        return 200 + t * 30, 262 + t * 62
    for yy in range(4, 212):
        xa, xb = shaft_x(max(yy, 18))
        for xx in range(int(xa), int(xb) + 1):
            if (xx, yy) in hole:
                continue
            if yy <= depth.get(xx, -1) + 1:
                continue
            lighten(xx, yy)
    for yy in range(212, 262):                                   # where it lands
        for xx in range(215, 345):
            dx, dy = (xx - 282) / 58.0, (yy - 232) / 19.0
            if dx * dx + dy * dy <= 1 and ((xx, yy) in rock_px or yy >= 212) :
                lighten(xx, yy, (20, 19, 17))
    for (mx, my) in ((226, 44), (243, 70), (238, 102), (262, 96), (252, 132), (274, 150), (247, 158), (268, 60)):
        p.dot(mx, my, hx('c9c2c6'))                               # dust hanging in the light
        p.dot(mx + 1, my, hx('c9c2c6'))

    # ---- 9. floor: puddles, fallen roots, torch bones, dust --------------------------------------------------
    PU_DK, PU_MID, PU_LT, PU_HI = hx('474a58'), hx('5c6068'), hx('727880'), hx('a0a6a8')

    def puddle(cx, cy, rx, ry, seed, refl=True):
        r = random.Random(seed)
        ph = [r.uniform(0, 6.28) for _ in range(2)]
        pts = {}
        for y in range(cy - ry - 2, cy + ry + 3):
            for x in range(cx - rx - 4, cx + rx + 5):
                dx, dy = (x - cx) / rx, (y - cy) / ry
                rad = 1 + 0.13 * math.sin(3 * math.atan2(dy, dx) + ph[0]) + 0.08 * math.sin(5 * math.atan2(dy, dx) + ph[1])
                if dx * dx + dy * dy <= rad * rad and col(x, y) != INK and (x, y) not in rock_px:
                    pts[(x, y)] = (dx, dy)
        for (x, y), (dx, dy) in pts.items():
            if (x, y - 1) not in pts:
                c = F_VD                                           # dark bank at the far edge
            elif (x, y - 2) not in pts or (x - 1, y) not in pts:
                c = PU_DK
            elif (x, y + 1) not in pts:
                c = PU_LT
            else:
                c = PU_MID
            p.dot(x, y, c)
        if refl:
            for (ox, w) in ((-rx // 2, rx // 2), (rx // 6, rx // 3)):
                yy = cy + (0 if ox < 0 else 1)
                for k in range(w):
                    if col(cx + ox + k, yy) == PU_MID:
                        p.dot(cx + ox + k, yy, PU_HI if ox < 0 else PU_LT)
        return pts
    puddle(118, 249, 24, 5, 41)
    puddle(402, 247, 22, 4, 42)
    puddle(40, 222, 11, 3, 43, refl=False)
    rk(104, 248, 3, 2, 27, ROCK, shadow=False)
    # drip rings in the big puddle under a root
    for (x, y) in ((122, 248), (123, 248), (124, 248), (121, 249), (125, 249), (122, 250), (123, 250), (124, 250)):
        if col(x, y) in (PU_MID, PU_HI, PU_LT):
            p.dot(x, y, PU_HI)

    def root_piece(pts, w=2):
        """a snapped root lying on the floor: thick polyline, light on top, shadow under"""
        body = set()
        for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
            n = max(abs(x1 - x0), abs(y1 - y0))
            for i in range(n + 1):
                x, y = round(x0 + (x1 - x0) * i / n), round(y0 + (y1 - y0) * i / n)
                for k in range(w + 1):
                    body.add((x, y + k))
        for (x, y) in body:
            for k in (1, 2):
                if (x + 1, y + k) not in body and col(x + 1, y + k) not in (INK, None) and (x, y + k) not in body:
                    pass
        lo = {}
        for (x, y) in body:
            lo[x] = max(lo.get(x, 0), y)
        for x, y in lo.items():                                    # contact shadow
            for k in (2, 3):
                if col(x + 1, y + k) not in (INK, None):
                    p.dot(x + 1, y + k, F_VD)
        for (x, y) in body:
            top = (x, y - 1) not in body
            bot = (x, y + 1) not in body
            p.dot(x, y, R_LT if top else (R_DK if bot else R_MID))
            if not top and not bot and (x + y * 2) % 7 == 0:
                p.dot(x, y, R_DK)
        inked(body)
        e = pts[-1]
        p.dot(e[0], e[1], R_LT)
    root_piece([(128, 236), (136, 233), (146, 234), (153, 238)])
    root_piece([(186, 254), (196, 257), (208, 255), (214, 251)], w=1)
    root_piece([(330, 252), (340, 249), (352, 251)], w=1)
    root_piece([(18, 240), (27, 243), (34, 241)], w=1)

    def torch(x, y, lying=True):
        if lying:
            rows = [".kww...........",
                    "kkkkbbbbbbbbbb.",
                    "KkkkbBBbbBBBBd.",
                    "KKkkBBBBBBBdd..",
                    ".KK............"]
        else:
            rows = ["kw.", "kk.", "KK.", "bB.", "bB.", "bB.", "bd."]
        return stamp(x, y, rows, {'w': hx('a09aa0'), 'k': hx('4a3e46'), 'K': hx('2e2434'), 'b': R_LT, 'B': R_MID,
                                  'd': R_DK})
    for (tx, ty) in ((64, 255), (438, 238)):
        for k in range(1, 15):
            if col(tx + k, ty + 5) not in (INK, None):
                p.dot(tx + k, ty + 6, F_VD)
        torch(tx, ty)
    # a little heap of ash and char by the first one
    stamp(80, 256, [".aAa.", "aAAkA"], {'a': hx('8f8a90'), 'A': hx('6e6a74'), 'k': hx('3c3038')}, ink=False)

    # wall sconce with a dead torch, soot above it
    def soot(cx, by, hgt, wid):
        for yy in range(by - hgt, by + 1):
            t = (by - yy) / float(hgt)
            hw = wid * (1 - t) ** 0.7 * (0.6 + 0.4 * math.sin(t * 3.1))
            sway = int(2 * math.sin(t * 5))
            for xx in range(int(cx - hw) + sway, int(cx + hw) + 1 + sway):
                c = col(xx, yy)
                if c in WALLS:
                    nxt = {W_LT: W_MID, W_MID: W_DK, W_DK: W_SH, W_SH: W_VD}.get(c)
                    if nxt:
                        p.dot(xx, yy, nxt)
    for (sx, sy) in ((66, 150), (310, 140)):
        soot(sx + 1, sy - 3, 40, 8)
        soot(sx + 1, sy - 3, 22, 5)
        stamp(sx - 3, sy - 3,
              ["...kkw....",
               "..kkkkw...",
               "..KkkkK...",
               "..KKkKK...",
               "...bbB....",
               "...bbB....",
               "iiibbBiii.",
               "i..bbB..i.",
               "ii.bbB.ii.",
               ".iibbBii..",
               "...bBd....",
               "...bBd....",
               "....d....."],
              {'w': hx('a09aa0'), 'k': hx('4a3e46'), 'K': hx('2e2434'), 'b': R_LT, 'B': R_MID, 'd': R_DK,
               'i': hx('7c7890')})

    # dust and grit drifted against things (flat lumps, no outline)
    def drift(cx, cy, rx, ry, seed):
        r = random.Random(seed)
        ph = r.uniform(0, 6.28)
        for y in range(cy - ry, cy + 1):
            for x in range(cx - rx, cx + rx + 1):
                dx, dy = (x - cx) / float(rx), (y - cy) / float(ry)
                rad = 1 + 0.12 * math.sin(4 * math.atan2(dy, dx) + ph)
                if dx * dx + dy * dy <= rad * rad and col(x, y) not in (INK, None) and (x, y) not in rock_px:
                    top = dx * dx + ((y - 1 - cy) / float(ry)) ** 2 > rad * rad
                    p.dot(x, y, hx('b9ad9c') if top and dx < 0.3 else (hx('a09384') if dx < 0.45 else hx('84786f')))
    drift(108, 234, 12, 3, 51)
    drift(226, 234, 16, 3, 52)
    drift(318, 216, 9, 3, 53)
    drift(12, 216, 10, 3, 54)
    drift(470, 216, 8, 3, 55)
    for (x0, x1, y) in ((98, 122, 204), (128, 150, 204), (156, 168, 204)):      # dust lying on the seat
        for x in range(x0, x1):
            if col(x, y) in (SL_LT, SL_MID):
                p.dot(x, y, hx('c4bcc0'))

    # ---- 10. dead glow-fungus -------------------------------------------------------------------------------
    FP = {'l': FU_LT, 'm': FU_MID, 'd': FU_DK, 's': FU_ST, 'S': hx('8a8580')}
    CAP_A = [".lmm.", "lmmmd", "mmddd", "..s..", "..s..", "..S.."]
    CAP_B = [".lm.", "lmmd", ".s..", ".S.."]
    CAP_C = ["lm.", "mmd", "mdd", ".s.", "sS."]                     # drooped
    CAP_D = ["..lm", "sslm", "..md"]                               # fallen over
    for (x, y, rows) in ((14, 198, CAP_A), (21, 203, CAP_B), (8, 204, CAP_B), (27, 199, CAP_C),
                         (322, 199, CAP_A), (329, 204, CAP_B), (316, 205, CAP_B),
                         (78, 196, CAP_C), (84, 200, CAP_B),
                         (468, 199, CAP_A), (475, 204, CAP_B),
                         (32, 208, CAP_D), (452, 214, CAP_D)):
        stamp(x, y, rows, FP)
    # shelf fungus up the wall, grey and curled
    for (x, y) in ((44, 96), (47, 104), (42, 111), (300, 108), (304, 116), (112, 150), (116, 157)):
        stamp(x, y, ["llmmm..", "mmmdddd", ".ddd..."], FP)
    # one tiny cap still holds a last faint glow
    stamp(88, 206, [".hg.", "hggG", ".s.."], {'h': hx('a9d2c2'), 'g': hx('82b4a6'), 'G': hx('5e8c86'), 's': FU_ST})

    # ---- 11. moss, a seedling in the light -------------------------------------------------------------------
    for (x0, x1, y) in ((300, 332, 211), (2, 30, 211), (440, 462, 211)):
        for x in range(x0, x1):
            if col(x, y) in WALLS and (x * 5) % 11 < 7:
                p.dot(x, y, M_DK if x % 3 else M_MID)
                if (x * 3) % 7 < 2 and col(x, y - 1) in WALLS:
                    p.dot(x, y - 1, M_MID)
    stamp(312, 238, [".L...", ".Ll.l", "..lll", "..s..", "..s.."], {'L': hx('9cb07a'), 'l': hx('7a9160'), 's': hx('5c7450')})

    # ---- 12. cobwebs -----------------------------------------------------------------------------------------
    def web_line(a, b, sag=0):
        (x0, y0), (x1, y1) = a, b
        n = max(abs(x1 - x0), abs(y1 - y0), 1)
        for i in range(n + 1):
            t = i / float(n)
            x = round(x0 + (x1 - x0) * t)
            y = round(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t))
            if col(x, y) not in (INK, None):
                p.dot(x, y, WEB)

    def web(cx, cy, spokes, rings):
        for (ex, ey) in spokes:
            web_line((cx, cy), (ex, ey))
        for f in rings:
            ptsr = [(cx + (ex - cx) * f, cy + (ey - cy) * f) for (ex, ey) in spokes]
            for a, b in zip(ptsr, ptsr[1:]):
                mx, my = (a[0] + b[0]) / 2.0, (a[1] + b[1]) / 2.0
                m = (round(mx + (cx - mx) * 0.22), round(my + (cy - my) * 0.22))
                a, b = (round(a[0]), round(a[1])), (round(b[0]), round(b[1]))
                web_line(a, m)
                web_line(m, b)
    web(0, 4, [(34, 9), (29, 19), (20, 27), (8, 32)], (0.4, 0.7, 1.0))
    web(479, 4, [(446, 8), (451, 19), (460, 27), (471, 31)], (0.4, 0.7, 1.0))
    web(343, 104, [(348, 126), (356, 119), (362, 107), (363, 94)], (0.5, 1.0))
    for (a, b, sg) in (((91, 14), (99, 16), 2), ((90, 26), (99, 30), 3), ((90, 40), (97, 42), 2),
                       ((15, 44), (24, 46), 3), ((14, 60), (25, 58), 3), ((134, 48), (141, 50), 2),
                       ((255, 44), (262, 47), 2), ((256, 58), (263, 60), 2)):
        web_line(a, b, sg)
