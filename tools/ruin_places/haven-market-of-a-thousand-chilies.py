"""Ruined Market of a Thousand Chilies: stalls sagging and shredded, chili strings dried to husks, cocoa house roof caved in."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from ruin_lib import Pic, hx, INK

DUSK = hx('#6a6488')
SAT, VAL = 0.56, 0.86


def build(p):
    import math, random, colorsys
    px = p.px

    def rm(h):
        """the colour a live-art colour becomes after the overcast remap"""
        r, g, b = hx(h) if isinstance(h, str) else h
        hh, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        c = [round(k * 255) for k in colorsys.hsv_to_rgb(hh, min(1, s * SAT), min(1, v * VAL))]
        return tuple(round(c[i] * .88 + DUSK[i] * .12) for i in range(3))

    def col(x, y):
        return px[x, y][:3] if 0 <= x < p.w and 0 <= y < p.h else None

    def put(x, y, c):
        if 0 <= x < p.w and 3 <= y < 267:
            px[x, y] = tuple(c) + (255,)

    def tone(x, y, k):
        c = col(x, y)
        if c is None or c == INK or not (3 <= y < 267):
            return
        px[x, y] = tuple(max(0, min(255, v + k)) for v in c) + (255,)

    def inked(draw):
        b = p.snapshot()
        draw()
        p.outline_new(b)

    def stamp(x, y, rows, pal):
        for j, row in enumerate(rows):
            for i, ch in enumerate(row):
                if ch in pal:
                    put(x + i, y + j, pal[ch])

    def heal(box):
        x0, y0, x1, y1 = box
        for yy in range(y0, y1 + 1):
            a, b_ = px[x0 - 1, yy], px[x1 + 1, yy]
            for xx in range(x0, x1 + 1):
                px[xx, yy] = a if xx - x0 <= x1 - xx else b_

    def ragged(cx, cy, rx, ry, seed, rough=.28):
        r = random.Random(seed)
        ph = [r.uniform(0, 6.28) for _ in range(3)]
        out = set()
        for y in range(cy - ry * 2, cy + ry * 2 + 1):
            for x in range(cx - rx * 2, cx + rx * 2 + 1):
                dx, dy = (x - cx) / float(rx), (y - cy) / float(ry)
                a = math.atan2(dy, dx)
                lim = 1 + rough * math.sin(3 * a + ph[0]) + rough * .6 * math.sin(7 * a + ph[1]) \
                    + rough * .35 * math.sin(13 * a + ph[2])
                if math.hypot(dx, dy) <= lim * .8:
                    out.add((x, y))
        return out

    def cut(mask, fill):
        """open a hole: fill with what is behind, ink the remaining material round it"""
        for (x, y) in mask:
            put(x, y, fill(x, y))
        for (x, y) in mask:
            for (nx, ny) in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if (nx, ny) in mask:
                    continue
                c = col(nx, ny)
                if c is None or c == INK or c == tuple(fill(nx, ny)):
                    continue
                put(nx, ny, INK)

    def stain(cx, cy, rx, ry, k, seed, only=None):
        for (x, y) in ragged(cx, cy, rx, ry, seed, .22):
            if only is None or only(x, y):
                tone(x, y, k)

    def hsv(c):
        return colorsys.rgb_to_hsv(c[0] / 255, c[1] / 255, c[2] / 255)

    # ================= A. work on the live colours =======================================================
    # A1 lamps out, their glow on the wall gone
    def lamp(r, g, b):
        if r > 200 and g > 120:
            return (0x74, 0x5c, 0x58) if g < 200 else (0x92, 0x7c, 0x72)
        return None
    for (cx, cy, rr) in ((210, 148, 9), (270, 148, 9)):
        for yy in range(cy - rr, cy + rr + 1):
            for xx in range(cx - rr, cx + rr + 1):
                if (xx - cx) ** 2 + (yy - cy) ** 2 <= rr * rr:
                    p.recolor((xx, yy, xx, yy), lamp)
    GLOW = {hx(h) for h in ('#b96a55', '#96554f', '#a1584e', '#c26a53', '#b26956', '#ac5b4e')}

    def wall(y):
        return hx('#a86858') if y < 150 else hx('#895250')
    for yy in range(140, 177):
        for xx in range(160, 317):
            if col(xx, yy) in GLOW:
                px[xx, yy] = wall(yy) + (255,)

    # A2 the frog keeper is gone
    for yy in range(141, 177):
        x1 = 262 if yy <= 159 else (253 if yy <= 162 else 259)
        for xx in range(223, x1 + 1):
            if (xx - 270) ** 2 + (yy - 148) ** 2 <= 81:
                continue                                                    # the lamp stays
            lim = 156 + (3 if xx % 17 < 9 else 0) + (2 if xx % 7 < 3 else 0)
            px[xx, yy] = (hx('#a86858') if yy < lim else hx('#895250')) + (255,)

    # A3 the counter is bare
    for yy in range(172, 184):
        for xx in range(161, 319):
            px[xx, yy] = wall(yy) + (255,)
    for xx in range(158, 323):
        px[xx, 184] = INK + (255,)
        px[xx, 185] = (hx('#f4b878') if 158 < xx < 322 else INK) + (255,)
        px[xx, 186] = INK + (255,)
        px[xx, 187] = INK + (255,)

    # A4 every chili dried to a brown husk
    KEEP = {hx(h) for h in ('#d8905c', '#a05c48', '#b96a55', '#d08b56', '#b86e44', '#e8a868', '#c88858', '#a96d48',
                            '#8a5238', '#c8946c')}

    def husk(r, g, b):
        c = (r, g, b)
        if c == INK or c in KEEP:
            return None
        h, s, v = hsv(c)
        green = .18 < h < .48 and s > .25
        if not (s > .5 or green):
            return None
        lum = .3 * r + .59 * g + .11 * b
        if green:
            return hx('#6f6a44') if lum > 150 else hx('#4e4c38')
        return hx('#c8a070') if lum > 185 else hx('#a87850') if lum > 130 else hx('#84583e') if lum > 85 else hx('#5e3c34')
    for box in ((8, 128, 96, 157), (383, 126, 465, 156), (160, 137, 178, 172), (300, 137, 318, 172),
                (176, 150, 302, 160), (150, 149, 163, 161), (128, 136, 143, 192), (337, 136, 351, 197)):
        p.recolor(box, husk)

    def husk_crate(r, g, b):
        c = (r, g, b)
        if c == INK:
            return None
        h, s, v = hsv(c)
        lum = .3 * r + .59 * g + .11 * b
        if .18 < h < .48 and s > .25:
            return hx('#6f6a44') if lum > 150 else hx('#4e4c38')
        if (h < .05 or h > .93) and s > .5:
            return hx('#a87850') if lum > 130 else hx('#84583e') if lum > 85 else hx('#5e3c34')
        if .1 < h < .18 and s > .5 and v > .9:
            return hx('#c8a070')
        return None
    for box in ((9, 220, 71, 229), (63, 235, 111, 245), (151, 220, 180, 233), (371, 236, 420, 247), (412, 222, 470, 232)):
        p.recolor(box, husk_crate)

    # A5 strings that fell
    for box in ((57, 128, 70, 157), (79, 128, 92, 157), (425, 127, 439, 156), (403, 140, 417, 156)):
        heal(box)
    for yy in range(142, 158):
        for xx in range(14, 27):
            px[xx, yy] = px[27, yy]
    for yy in range(126, 142):                                               # the whole left string is gone
        for xx in range(14, 28):
            px[xx, yy] = px[30, yy]
    for xx in range(47, 99):                                                 # the string rail goes with them
        for yy in range(125, 129):
            px[xx, yy] = px[xx, 130]

    # A6 left stall: right post snapped, the awning sags down on that side
    heal((99, 126, 106, 173))
    for xx in range(40, 116):
        dy = min(13, int(round((xx - 40) * 13 / 68.0)))
        if dy == 0:
            continue
        top = next(yy for yy in range(70, 130) if col(xx, yy) == INK)
        bot = 128 if xx <= 110 else 122
        sky = px[xx, top - 2]
        for yy in range(bot, top - 1, -1):
            px[xx, yy + dy] = px[xx, yy]
        for yy in range(top, top + dy):
            px[xx, yy] = sky
    for yy in range(84, 101):
        for xx in range(111, 119):
            px[xx, yy] = px[119, 84]

    # ================= B. overcast ======================================================================
    p.remap(sat=SAT, val=VAL, tint=DUSK)
    ink_rm = rm('#2b1c26')
    p.recolor((0, 0, 479, 269), lambda r, g, b: INK if (r, g, b) == ink_rm else None)

    SK = {rm('#78c0e8'): hx('#6d6b88'), rm('#98d0ec'): hx('#7f7d98'), rm('#c8e4e0'): hx('#9a98ac')}
    p.recolor((0, 0, 479, 130), lambda r, g, b: SK.get((r, g, b)))
    SKY_LO = hx('#9a98ac')
    CREAM_BG = rm('#f8ecc0')

    def cloud(r, g, b):
        if (r, g, b) in SK.values() or (r, g, b) == INK:
            return None
        return hx('#b9b6c6') if r + g + b > 600 else hx('#a5a1b6')
    for box in ((36, 28, 102, 48), (392, 42, 446, 58)):
        p.recolor(box, cloud)

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
                    c = hx('#3e3a52')
                elif yy <= top[xx] + 1 and top.get(xx - 1, cy) >= top[xx]:
                    c = hx('#8a86a2')
                elif yy <= top[xx] + 3 and xx % 23 < 15:
                    c = hx('#6a6682')
                else:
                    c = hx('#55516c')
                p.dot(xx, yy, c)
    storm(170, 24, 150, 1, 13)
    storm(330, 30, 110, 2, 10)
    storm(452, 22, 90, 3, 11)
    storm(40, 20, 90, 5, 10)
    storm(250, 48, 70, 4, 6)

    def sky(x, y):
        return SKY_LO if y < 117 else CREAM_BG

    # palettes
    VD, VD2, RIM = hx('#3a2e3c'), hx('#2a2030'), hx('#5c4a56')
    W_LT, W_MID, W_DK, W_SH = hx('#b39a86'), hx('#93766a'), hx('#6c535a'), hx('#463744')
    M_LT, M_MID, M_DK = hx('#8a9a66'), hx('#68794e'), hx('#4a5a40')
    H_LT, H_MID, H_DK = rm('#c8a070'), rm('#84583e'), rm('#5e3c34')
    C_CREAM, C_CREAM2, C_RED, C_RED2 = rm('#fff1d4'), rm('#e0b0a0'), rm('#f46d62'), rm('#a02c4c')
    G_SH, G_SH2 = rm('#b88068'), rm('#a06c5c')
    WEB = hx('#d4d0dc')
    WEB_L = hx('#f4f0f6')
    BACK = hx('#4a3c4a')

    # ================= C. damage =========================================================================
    # C1 cocoa house: ridge beam snapped, roof and awning caved in
    CX, HW = 213, 26

    def vline(x):
        return 101 + int(round((1 - abs(x - CX) / float(HW)) * 14))
    rr = random.Random(21)
    edge = {}
    wl = wr = 0
    for yy in range(101, 135):
        wl = max(-2, min(2, wl + rr.choice((-1, 0, 0, 1))))
        wr = max(-2, min(2, wr + rr.choice((-1, 0, 0, 1))))
        half = HW - (yy - 101) * 0.6
        edge[yy] = (int(CX - half + wl), int(CX + half + wr))
    edge[101] = edge[102] = edge[103] = (CX - HW, CX + HW)
    mask = set()
    for yy, (a, b_) in edge.items():
        for xx in range(a, b_ + 1):
            mask.add((xx, yy))

    def interior(x, y):
        return SKY_LO if y < vline(x) else VD
    cut(mask, interior)
    for (x, y) in mask:                                                      # depth: dark under the lip, a lit inner rim
        if y < vline(x):
            continue
        a, b_ = edge[y]
        if x - a <= 2 or y - vline(x) <= 5:
            put(x, y, VD2)
        elif b_ - x <= 1:
            put(x, y, RIM)
    for xx in range(CX - HW, CX + HW + 1):                                   # the two drooping beam halves
        if abs(xx - CX) <= 3:
            continue
        v = vline(xx)
        put(xx, v, INK)
        put(xx, v + 1, rm('#c88858') if xx < CX else rm('#a8683c'))
        put(xx, v + 2, rm('#a8683c') if xx < CX else rm('#8a5238'))
        put(xx, v + 3, INK)
    for (sx, d) in ((CX - 4, 1), (CX + 4, -1)):                              # splintered ends
        v = vline(sx)
        for k in range(4):
            put(sx, v + k, INK)
        put(sx + d, v + 1, INK)
        put(sx + d, v + 3, INK)
        put(sx + 2 * d, v + 4, INK)
    for (x, y) in mask:                                                      # the back wall of the loft, dimly
        if col(x, y) == VD and y >= 118 + (x - 200) // 4 and x >= 204:
            put(x, y, BACK)
    for (x0, y0, x1, y1) in ((198, 110, 212, 131), (232, 109, 219, 128), (203, 122, 224, 117)):   # broken rafters inside
        n = max(abs(x1 - x0), abs(y1 - y0))
        for i in range(n + 1):
            x = x0 + (x1 - x0) * i // n
            y = y0 + (y1 - y0) * i // n
            if col(x, y) in (VD, VD2, BACK) and y > vline(x) + 3:
                put(x, y, hx('#7a6260'))
                if col(x + 1, y) in (VD, VD2, BACK):
                    put(x + 1, y, hx('#5a4850'))
    for (tx, ty, n) in ((196, 121, 4), (229, 118, 5), (222, 132, 3), (201, 131, 3)):   # threads hanging off the torn edge
        for k in range(n):
            if col(tx, ty + k) in (VD, VD2, RIM, BACK):
                put(tx, ty + k, C_CREAM2)

    # smaller tear in the cocoa house awning
    def deep(m, threads=None):
        """shade a hole: shadow under the top/left lip, the far side lit dimly, a rim of light at the bottom-right"""
        tops, bots = {}, {}
        for (x, y) in m:
            tops[x] = min(tops.get(x, 999), y)
            bots[x] = max(bots.get(x, -1), y)
        for (x, y) in m:
            t, b_ = tops[x], bots[x]
            if y - t <= 1 or (x - 1, y) not in m:
                c = VD2
            elif (x + 1, y) not in m or b_ - y == 0:
                c = RIM
            elif y - t > (b_ - t) * .55 and (x + y) % 9 != 0:
                c = BACK
            else:
                c = VD
            put(x, y, c)
        if threads:
            for x in sorted(tops)[1:-1:3]:
                for k in range(1 + (x * 7) % 3):
                    if (x, tops[x] + k) in m:
                        put(x, tops[x] + k, threads)
    m = ragged(302, 120, 8, 5, 37)
    cut(m, lambda x, y: VD)
    deep(m, C_CREAM2)

    # C2 side awnings shredded: sky shows through
    for (cx, cy, rx, ry, sd) in ((432, 99, 12, 10, 3), (397, 91, 6, 5, 8), (22, 103, 8, 7, 5), (70, 104, 5, 6, 12)):
        m = ragged(cx, cy, rx, ry, sd)
        cut(m, sky)
        top = {}
        for (x, y) in m:
            top[x] = min(top.get(x, 999), y)
        r3 = random.Random(sd)
        for x in sorted(top)[2::4]:                                         # frayed threads hang into the hole
            for k in range(r3.randint(1, 4)):
                if (x, top[x] + k) in m:
                    put(x, top[x] + k, C_CREAM2)
    # notches ripped up from the hems
    for (nx, w, hgt, ybase) in ((444, 5, 13, 124), (406, 4, 9, 124), (34, 4, 10, 124)):
        m = set()
        for k in range(hgt):
            ww = max(0, int(w * (1 - k / float(hgt))))
            for xx in range(nx - ww, nx + ww + 1):
                m.add((xx + (k // 4), ybase - k))
        if ybase == 124:
            cut(m, lambda x, y: sky(x, y) if y <= 124 else col(x, y))
        else:
            cut(m, lambda x, y: rm(wall(y)) if y < 141 else col(x, y))

    # the pennant: faded and half torn away
    fm = set()
    for yy in range(58, 80):
        for xx in range(272, 291):
            if xx >= 272 + abs(yy - 68) // 2 + (2 if yy % 5 < 2 else 0) and col(xx, yy) not in SK.values():
                fm.add((xx, yy))
    skyrow = {yy: col(292, yy) for yy in range(56, 82)}
    cut(fm, lambda x, y: skyrow[y])
    p.recolor((257, 58, 290, 80), lambda r, g, b: tuple(min(255, int(v * .9) + 14) for v in (r, g, b))
              if (r, g, b) != INK and (r, g, b) not in SK.values() else None)

    # C3 left stall: the snapped post
    def post():
        p.poly([(99, 162), (101, 159), (103, 163), (105, 160), (106, 164), (106, 173), (99, 173)], W_MID)
        for yy in range(160, 174):
            for xx in (104, 105, 106):
                if col(xx, yy) == W_MID:
                    put(xx, yy, W_DK)
            if col(100, yy) == W_MID:
                put(100, yy, W_LT)
        # the upper half still dangles from the sagging awning
        p.poly([(101, 133), (106, 133), (101, 154), (99, 157), (97, 154), (95, 156), (96, 152)], W_MID)
        p.line([(101, 134), (96, 153)], W_LT)
        p.line([(105, 134), (100, 154)], W_DK)
    inked(post)

    # C4 counters: a stove-in board, cracks, a fallen plank
    m = ragged(58, 196, 10, 6, 44)
    cut(m, lambda x, y: VD)
    deep(m)
    for (x, y) in ((52, 193), (53, 194), (54, 195), (63, 192), (63, 193)):     # splinters poking into the hole
        if (x, y) in m:
            put(x, y, W_MID)
    for (x0, y0, n, k) in ((10, 186, 30, -26), (72, 189, 26, -26), (14, 205, 20, -22), (384, 187, 40, -26),
                           (430, 200, 34, -24), (170, 195, 44, -24), (250, 197, 50, -24), (392, 206, 22, -20)):
        r4 = random.Random(x0)
        y = y0
        for i in range(n):
            if i % 9 == 8:
                y += r4.choice((-1, 0, 1))
            tone(x0 + i, y, k)

    def plank():
        p.poly([(438, 215), (443, 214), (459, 178), (455, 177)], W_MID)
        p.line([(439, 214), (455, 179)], W_LT)
        p.line([(443, 213), (458, 180)], W_DK)
    inked(plank)
    for xx in range(436, 449):
        tone(xx, 216, -30)

    # C5 debris of the roof on the cocoa counter where the keeper stood
    def rubble():
        p.poly([(236, 139), (240, 139), (252, 182), (248, 183)], W_MID)       # fallen rafter
        p.line([(237, 140), (249, 181)], W_LT)
        p.line([(240, 141), (252, 181)], W_DK)
        p.poly([(196, 183), (201, 177), (230, 175), (236, 183)], W_DK)        # heap of boards
        p.poly([(199, 181), (203, 178), (226, 177), (229, 180)], W_MID)
        p.line([(203, 178), (225, 177)], W_LT)
        p.line([(212, 183), (222, 172)], W_SH)
        p.line([(213, 183), (223, 172)], W_MID)
    inked(rubble)

    def drape():                                                              # a strip of the awning hangs over the counter
        pts = [(203, 183), (229, 183), (228, 198), (224, 204), (220, 199), (215, 206), (209, 200), (205, 203)]
        p.poly(pts, C_CREAM)
        for yy in range(183, 207):
            for xx in range(203, 230):
                if col(xx, yy) == C_CREAM:
                    if (xx - 203) // 5 % 2 == 0:
                        put(xx, yy, C_RED if yy < 197 else C_RED2)
                    elif yy >= 197:
                        put(xx, yy, C_CREAM2)
        for xx in (207, 217, 226):                                            # folds
            for yy in range(185, 198):
                tone(xx, yy, -26)
    inked(drape)

    # husks left on shelves and counter
    def husk_at(x, y, flip=False, shadow=None):
        rows = ("hbb.", ".bdd") if not flip else (".bbh", "ddb.")
        stamp(x, y, rows, {'h': H_LT, 'b': H_MID, 'd': H_DK})
        if shadow:
            for i in range(4):
                put(x + i, y + 2, shadow)
    def counter_husks():
        for (x, y, f) in ((170, 182, False), (184, 182, True), (262, 182, False), (286, 182, True), (294, 181, False)):
            husk_at(x, y, f)
    inked(counter_husks)

    # C6 the dark doorway: cobweb, a board fallen across
    def web2(x, y, sx, sy, size, c=WEB):
        """corner cobweb: spokes from the corner, sagging threads across them"""
        angs = (0.0, 0.52, 1.05, 1.5708)
        spokes = []
        for a in angs:
            pts = []
            for r in range(size + 1):
                pts.append((x + sx * int(round(r * math.cos(a))), y + sy * int(round(r * math.sin(a)))))
            spokes.append(pts)
            for q in pts[1:]:
                put(q[0], q[1], c)
        for rad in range(5, size + 1, 4):
            for i in range(len(angs) - 1):
                a0, a1 = spokes[i][rad], spokes[i + 1][rad]
                n = max(abs(a1[0] - a0[0]), abs(a1[1] - a0[1]), 1)
                for k in range(n + 1):
                    t = k / float(n)
                    sag = int(round(math.sin(t * math.pi) * rad / 6.0))
                    put(int(round(a0[0] + (a1[0] - a0[0]) * t)) - sx * sag,
                        int(round(a0[1] + (a1[1] - a0[1]) * t)) - sy * sag, c)
    web2(330, 141, -1, 1, 10)

    def doorboard():
        p.poly([(320, 208), (323, 209), (333, 190), (330, 189)], W_MID)
        p.line([(321, 207), (331, 190)], W_LT)
    inked(doorboard)

    # cobweb across the left stall corner, another under the green awning
    web2(14, 128, 1, 1, 12, WEB_L)
    web2(466, 128, -1, 1, 11, WEB_L)

    # C7 sacks: one split, cocoa beans spilled
    def spill():
        p.blob(277, 253, 9, 3, (H_LT, H_MID, H_DK), wobble=1)
        for (x, y) in ((264, 255), (267, 252), (289, 256), (283, 249), (271, 250)):
            put(x, y, H_MID)
            put(x + 1, y, H_DK)
    BEAN, BEAN2, BEAN3 = hx('#8a6456'), hx('#6a4a46'), hx('#4e3840')

    def spill2():
        for (x0, x1, y) in ((272, 280, 250), (268, 284, 251), (265, 286, 252), (263, 287, 253), (262, 287, 254)):
            for xx in range(x0, x1 + 1):
                put(xx, y, BEAN if (xx + y) % 5 < 2 and y < 253 else (BEAN3 if (xx * 3 + y) % 7 == 0 else BEAN2))
        for (x, y) in ((256, 254), (259, 251), (252, 252)):
            put(x, y, BEAN2); put(x + 1, y, BEAN3)
    inked(spill2)
    for xx in range(258, 290):
        if col(xx, 256) != INK:
            tone(xx, 256, -24)
    for (x, y) in ((287, 246), (286, 247), (286, 248), (285, 249), (286, 250)):   # the split seam
        put(x, y, INK)
    for (x, y) in ((287, 247), (287, 248), (286, 249)):
        put(x, y, BEAN2)

    # C8 cold brazier tipped over in the street
    IR_L, IR_M, IR_D, ASH, ASH2, COAL = hx('#7c7688'), hx('#5a5466'), hx('#3e3848'), hx('#aaa6b2'), hx('#8c8896'), hx('#322a34')

    def brazier():
        stamp(222, 224, (
            "....aAAa......",
            "..aAAaaAAa....",
            "LLLLLLLLLLLLLL",
            "dmmLLmmmmmmmmd",
            ".dmmLmmmmmmdd.",
            "..dmmmmmmmdd..",
            "...ddmmmddd...",
            "....dddddd....",
            "...l..ll..l...",
            "..l...ll...l..",
            "..l...ll...l..",
            ".l....ll....l.",
        ), {'m': IR_M, 'L': IR_L, 'd': IR_D, 'l': IR_D, 'a': ASH2, 'A': ASH})
    inked(brazier)
    for xx in range(221, 238):
        if col(xx, 237) != INK:
            tone(xx, 237, -24)

    def ash():
        for (x0, x1, y) in ((243, 249, 234), (241, 252, 235), (240, 253, 236)):
            for xx in range(x0, x1 + 1):
                put(xx, y, ASH if y == 234 else (ASH2 if (xx + y) % 4 else hx('#726e7e')))
        put(246, 233, COAL); put(247, 233, COAL); put(250, 234, COAL)
    inked(ash)

    # ================= D. age: stains, moss, vines, weeds, fallen husks ==================================
    in_box = lambda x0, y0, x1, y1: (lambda x, y: x0 <= x <= x1 and y0 <= y <= y1)
    for (cx, cy, rx, ry, k, sd) in ((48, 100, 9, 5, -18, 1), (88, 112, 7, 5, -16, 2), (10, 110, 6, 4, -16, 3),
                                    (150, 118, 8, 6, -18, 4), (262, 116, 10, 5, -16, 5), (330, 122, 8, 5, -18, 6),
                                    (350, 112, 5, 7, -14, 7), (410, 104, 9, 6, -18, 8), (462, 96, 8, 5, -16, 9),
                                    (378, 100, 5, 6, -16, 10), (176, 112, 6, 4, -14, 11)):
        stain(cx, cy, rx, ry, k, sd)
    r5 = random.Random(9)
    for (x0, x1, y0, y1) in ((4, 110, 96, 118), (120, 186, 110, 132), (242, 360, 110, 132), (370, 478, 86, 116)):
        for _ in range(9):                                                   # dirt runs down the cloth
            x = r5.randint(x0, x1)
            y = r5.randint(y0, y1 - 8)
            for k in range(r5.randint(4, 9)):
                if col(x, y + k) not in (INK, VD, VD2, RIM, SKY_LO, CREAM_BG):
                    tone(x, y + k, -14)

    def moss_top(x0, x1, seed, yscan=(70, 125)):
        r6 = random.Random(seed)
        for xx in range(x0, x1 + 1):
            top = next((yy for yy in range(yscan[0], yscan[1]) if col(xx, yy) == INK), None)
            if top is None:
                continue
            d = 2 + (1 if (xx - x0) % 5 in (1, 2, 3) else 0) + (1 if r6.random() < .3 else 0)
            if xx - x0 < 2 or x1 - xx < 2:
                d = 1
            for k in range(1, d + 1):
                if col(xx, top + k) == INK:
                    break
                put(xx, top + k, M_LT if k == 1 else (M_MID if k < d else M_DK))
    for (a, b_, sd) in ((4, 22, 1), (50, 66, 2), (86, 104, 3), (372, 392, 4), (418, 430, 5), (452, 476, 6)):
        moss_top(a, b_, sd)
    for (a, b_, sd) in ((120, 150, 7), (262, 300, 8), (330, 360, 9)):       # on the ridge beam
        r6 = random.Random(sd)
        for xx in range(a, b_ + 1):
            if (xx - a) % 11 < 7:
                put(xx, 103, M_LT if r6.random() < .6 else M_MID)
                if (xx - a) % 11 in (2, 3, 4):
                    put(xx, 104, M_DK)

    # vines
    for (x, y, n) in ((474, 84, 46), (468, 88, 30), (371, 92, 40), (376, 126, 44), (470, 130, 40), (10, 126, 44),
                      (128, 108, 30), (355, 108, 34), (446, 122, 16), (414, 122, 10)):
        p.rng.seed(x * 7 + y)
        p.vine(x, y, n, (M_DK, M_LT), sway=2, leaf=.4)
    p.rng.seed(5)
    p.vine(143, 140, 50, (M_DK, M_MID), sway=1, leaf=.35)
    p.vine(334, 140, 56, (M_DK, M_MID), sway=1, leaf=.35)

    # weeds through the ground
    def tuft(x, y, h, seed):
        r7 = random.Random(seed)
        for i in range(-2, 3):
            hh = r7.randint(max(1, h - 3), h) - abs(i)
            lean = i // 2
            for k in range(max(1, hh)):
                put(x + i + (lean if k > hh // 2 else 0), y - k, M_LT if i < 0 else (M_MID if i == 0 else M_DK))
    for i, (x, y, h) in enumerate(((6, 216, 5), (30, 217, 4), (96, 217, 6), (112, 215, 5), (124, 213, 6), (156, 214, 4),
                                   (190, 214, 5), (300, 214, 4), (327, 211, 5), (352, 213, 6), (372, 217, 5),
                                   (420, 217, 4), (476, 217, 6), (130, 236, 5), (190, 252, 4), (250, 224, 4),
                                   (350, 240, 5), (362, 258, 4), (120, 258, 5), (26, 250, 4), (440, 258, 5),
                                   (474, 244, 5), (232, 258, 4), (60, 176 - 3, 3), (402, 174 - 3, 3))):
        tuft(x, y, h, i)

    # fallen husks under the strings, a broken string lying in the dust
    def fallen():
        for i, (x, y) in enumerate(((62, 219), (118, 222), (140, 219), (186, 222), (198, 219),
                                    (340, 218), (356, 222), (408, 219), (430, 221), (436, 226), (352, 250),
                                    (136, 246), (18, 240))):
            husk_at(x, y, i % 2 == 1)
    inked(fallen)
    for (x, y) in ((62, 219), (118, 222), (140, 219), (186, 222), (198, 219), (340, 218),
                   (356, 222), (408, 219), (430, 221), (436, 226), (352, 250), (136, 246), (18, 240)):
        for i in range(0, 5):
            tone(x + i, y + 3, -22)

    # a whole string fallen from the left stall, lying in the dust
    ROPE = hx('#8c7466')
    def fallen_string():
        for i in range(0, 32):
            x, y = 76 + i, 220 + (i * 3) // 31
            put(x, y, ROPE)
        for i, x in enumerate(range(77, 105, 5)):
            husk_at(x, 218 + (x - 76) * 3 // 31 + (i % 2), i % 2 == 1)
    inked(fallen_string)
    for xx in range(75, 110):
        yy = 223 + (xx - 76) * 3 // 31
        if col(xx, yy) != INK:
            tone(xx, yy, -22)

    # a seedling in the abandoned box of chilies
    put(166, 219, M_MID); put(166, 218, M_MID); put(165, 217, M_LT); put(167, 216, M_LT); put(166, 217, M_MID)
