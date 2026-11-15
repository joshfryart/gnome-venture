"""Ruined Singing Waterfall: the stone organ is broken, the fall is down to a trickle, the pond is a muddy puddle."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from ruin_lib import Pic, hx, INK

import math, random, colorsys

TINT = hx('#6e7286')
SAT, VAL = 0.5, 0.84


def rm(h):
    """the colour a live-art colour becomes after the overcast remap"""
    r, g, b = hx(h) if isinstance(h, str) else h
    hh, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    c = [round(k * 255) for k in colorsys.hsv_to_rgb(hh, min(1, s * SAT), min(1, v * VAL))]
    return tuple(round(c[i] * .88 + TINT[i] * .12) for i in range(3))


def nz(x, y):
    """smooth clustered noise, about -3..3"""
    return (math.sin(x * .37 + math.sin(y * .21) * 1.7) + math.sin(y * .45 + math.sin(x * .19) * 2.1)
            + math.sin((x + y) * .23 + 1.3))


def nz2(x, y):
    return (math.sin(x * .53 + math.sin(y * .31 + 2.0) * 1.9) + math.sin(y * .61 + math.sin(x * .27) * 1.6)
            + math.sin((x - y) * .29))


# pipes: (left ink column, original height); all stand on y = 189
PIPES = {'L1': (145, 70), 'L2': (162, 81), 'L3': (179, 94), 'L4': (196, 102),
         'R1': (269, 101), 'R2': (286, 92), 'R3': (303, 85), 'R4': (320, 71)}
BASE = 189


def build(p):
    px = p.px

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

    # =====================================================================================================
    # 0. work on the live colours first: rainbow + notes out of the sky, masks
    # =====================================================================================================
    RAINBOW = {hx(h) for h in ('#e8493b', '#f5a03c', '#ffe05a', '#78c864', '#4aa8e0', '#8a6ac8')}
    NOTE = {hx(h) for h in ('#ffd24a', '#f5b82e', '#f080a8', '#78c864')}
    SKY_L = [hx(h) for h in ('#6ab8dc', '#88cce0', '#a8dce2', '#c8ecde', '#c8e6f0', '#f8f0e0')]
    HILL_L = [hx(h) for h in ('#62a488', '#7cbc98', '#4c8a78', '#9cd0a8', '#3a7066', '#2c5a58')]
    GOOD = set(SKY_L) | set(HILL_L)

    def sky_heal(x0, y0, x1, y1, allbad=False):
        for y in range(y0, y1 + 1):
            row = [col(x, y) for x in range(p.w)]
            for x in range(x0, x1 + 1):
                c = row[x]
                if c in GOOD:
                    continue
                if not allbad and c not in RAINBOW and c not in NOTE:
                    continue
                for d in range(1, 200):
                    a = row[x - d] if x - d >= 0 else None
                    b = row[x + d] if x + d < p.w else None
                    if a in GOOD:
                        px[x, y] = a + (255,)
                        break
                    if b in GOOD:
                        px[x, y] = b + (255,)
                        break
    sky_heal(202, 21, 219, 43, allbad=True)          # yellow note above the fall
    sky_heal(257, 25, 275, 47, allbad=True)          # pink note
    sky_heal(0, 48, 158, 150)                        # rainbow, left
    sky_heal(322, 48, 479, 150)                      # rainbow, right
    # green note sitting on the cliff's right shoulder
    for y in range(86, 105):
        for x in range(328, 316, -1):
            c = col(x, y)
            if c in NOTE or (c == INK and x <= 326 and col(x + 1, y) not in GOOD and col(x + 1, y) not in RAINBOW):
                px[x, y] = px[316, y]
    sky_heal(322, 84, 345, 110)
    # sparkles on the bushes
    for (x, y) in ((430, 232), (20, 236), (96, 243), (95, 244), (96, 244), (97, 244), (96, 245), (452, 250)):
        px[x, y] = px[x - 2, y - 2] if col(x - 2, y - 2) != INK else px[x + 2, y + 2]

    WATER_L = {hx(h) for h in ('#8cc8e4', '#b8e0f0', '#5aa8d0', '#3a86b8', '#e0f4f8', '#f4f8f0', '#f8fcf4',
                               '#ff0f00', '#fff4d6')}
    FROG_L = {hx(h) for h in ('#78b064', '#529054', '#a8e07c', '#7cc058', '#5aa04a', '#3a7a3e', '#2a5a34',
                              '#f0e8b0', '#e8493b', '#fff6dc', '#ffd24a', '#f5b82e')}
    POND = set()
    for y in range(190, 262):
        for x in range(0, 480):
            c = col(x, y)
            if c in WATER_L or (345 <= x <= 392 and 196 <= y <= 242 and c in FROG_L):
                POND.add((x, y))
    for _ in range(3):                                # ink of the frog / lily / note (not ink that edges a bush)
        add = []
        for y in range(196, 243):
            for x in range(345, 393):
                if col(x, y) == INK and (x, y) not in POND:
                    ok = True
                    for dy in (-1, 0, 1):
                        for dx in (-1, 0, 1):
                            q = (x + dx, y + dy)
                            if q not in POND and col(*q) != INK:
                                ok = False
                    if ok:
                        add.append((x, y))
        POND.update(add)
    FALL = set()
    for y in range(59, 190):
        for x in range(213, 269):
            if col(x, y) in WATER_L:
                FALL.add((x, y))

    # =====================================================================================================
    # 1. overcast recolour
    # =====================================================================================================
    p.remap(sat=SAT, val=VAL, tint=TINT)
    ink_rm = rm('#2b1c26')
    p.recolor((0, 0, 479, 269), lambda r, g, b: INK if (r, g, b) == ink_rm else None)

    R_LT, R_MID, R_DK, R_DD, R_VD = rm('#b8aec8'), rm('#948aa8'), rm('#726888'), rm('#564c6a'), rm('#3e3650')
    R_HI = hx('#b9b6c2')
    VOID1, VOID2 = hx('#2a2434'), hx('#3d374a')
    M_LT, M_MID, M_DK = hx('#8a9666'), hx('#6b7a50'), hx('#4f5d42')
    ROCK = {R_LT, R_MID, R_DK, R_DD, R_VD}

    # dead foliage, tired grass
    dead = {}
    for a, b in (('#d0cc6a', '#bfa97c'), ('#a5af4c', '#a38a66'), ('#7a922e', '#846a52'), ('#557228', '#695244'),
                 ('#486225', '#55423c'), ('#3a5222', '#463636'),
                 ('#a8d080', '#a39a78'), ('#7db06a', '#857c60'), ('#529054', '#69644f'), ('#3a704a', '#544f44'),
                 ('#326145', '#46413c'), ('#2a5240', '#3b3636'),
                 ('#3a7a3e', '#6a7050'), ('#326a39', '#5a6048'), ('#5aa04a', '#868a60'), ('#2a5a34', '#4c5240'),
                 ('#81c063', '#9a9a6c'), ('#a8e07c', '#b0ac80'), ('#3f9150', '#6f7a54'), ('#7cc058', '#8f9468')):
        dead[rm(a)] = hx(b)
    for y in range(140, 270):
        for x in range(480):
            if 140 < x < 340 and y < 190:
                continue
            c = col(x, y)
            if c in dead:
                px[x, y] = dead[c] + (255,)

    # the pipe template (R1 is clean in the live art); its blue mouth is dry and dark now
    blue = {rm('#3a86b8'): hx('#4a4458'), rm('#1c1830'): hx('#2a2434')}
    T = [[blue.get(col(269 + i, 89 + j), col(269 + i, 89 + j)) for j in range(101)] for i in range(17)]

    def tcol(i, j):
        while j > 100:
            j -= 7
        return T[i][j]

    # =====================================================================================================
    # 2. sky: grey clouds, heavy banks
    # =====================================================================================================
    cl = {rm('#f8f0e0'): hx('#8c90a2'), rm('#c8e6f0'): hx('#6c7187')}
    p.recolor((0, 4, 479, 75), lambda r, g, b: cl.get((r, g, b)))
    SKYSET = {rm(c) for c in SKY_L} | set(cl.values())

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
                if yy < 4 or col(xx, yy) not in SKYSET:
                    continue
                if yy >= bot - 1 and edge > 4:
                    c = hx('#4b5064')
                elif yy <= top[xx] + 1 and top.get(xx - 1, cy) >= top[xx]:
                    c = hx('#8e92a4')
                elif yy <= top[xx] + 3 and xx % 23 < 15:
                    c = hx('#757a8f')
                else:
                    c = hx('#62677c')
                p.dot(xx, yy, c)
    SKYSET |= {hx(h) for h in ('#4b5064', '#8e92a4', '#757a8f', '#62677c')}
    storm(120, 26, 170, 1, 14)
    storm(330, 20, 130, 2, 12)
    storm(452, 40, 90, 3, 11)
    storm(232, 40, 70, 4, 7)
    storm(18, 44, 70, 5, 9)
    storm(70, 76, 80, 6, 7)
    storm(410, 82, 96, 7, 8)

    # =====================================================================================================
    # 3. the lintel has cracked in two, the right half has dropped
    # =====================================================================================================
    blk = [[px[x, y] for x in range(243, 271)] for y in range(46, 60)]
    for y in range(46, 50):
        for x in range(243, 271):
            px[x, y] = px[x, 44]
    for j, row in enumerate(blk):
        for i, c in enumerate(row):
            dy = 2 + (1 if i > 9 else 0) + (1 if i > 19 else 0)
            px[243 + i, 46 + j + dy] = c
    for x in range(243, 271):                               # sky left above the dropped half
        for y in range(46, 52):
            if col(x, y) not in (INK,) + tuple(ROCK) and col(x, y) not in SKYSET:
                px[x, y] = px[x, 44]
    # the break itself
    for (x, y0, y1) in ((241, 50, 58), (242, 49, 60), (243, 52, 61)):
        for y in range(y0, y1 + 1):
            p.dot(x, y, INK if y in (y0, y1) or x == 241 else VOID1)
    for y in range(50, 60):
        p.dot(240, y, INK)
    p.dot(239, 51, R_HI); p.dot(239, 52, R_HI)

    # =====================================================================================================
    # 4. the fall: a dry stained cliff face with a few trickles
    # =====================================================================================================
    ST_DK, ST_GR, ST_GR2, LIME = hx('#4d485c'), hx('#5f6c58'), hx('#75806a'), hx('#aaa8b6')
    WT_LT, WT_MID = hx('#c3d2da'), hx('#8fa6b6')
    # bare rock where the water used to run, broken into big soft facets
    for (x, y) in FALL:
        n = nz(x * .55 + 17, y * .8)
        c = R_DK
        if n > 1.0:
            c = R_MID
        elif n < -1.3:
            c = R_DD
        if n > 2.1 and nz2(x * .7, y * .7) > 0:
            c = R_LT
        px[x, y] = c + (255,)
    # damp streaks where the water used to run: wavy, tapering, not ruler-straight
    r = random.Random(11)
    for sx, w, y0, ln, c, ph in ((221, 3, 62, 70, ST_DK, 0.3), (231, 4, 62, 122, ST_GR, 1.7), (240, 3, 64, 96, ST_DK, 2.9),
                                (250, 4, 62, 116, ST_GR, 4.1), (259, 2, 62, 58, ST_DK, 5.3), (226, 2, 130, 50, ST_GR, 0.9)):
        for y in range(y0, y0 + ln):
            t = (y - y0) / float(ln)
            ww = max(1, int(round(w * (1 - t * .7))))
            ox = int(round(1.6 * math.sin(y * .06 + ph) + .8 * math.sin(y * .17 + ph * 2)))
            for k in range(ww):
                if (sx + ox + k, y) in FALL:
                    cc = c
                    if c == ST_GR and k == 0 and nz2(sx, y * .5) > .6:
                        cc = ST_GR2
                    px[sx + ox + k, y] = cc + (255,)
    # pale lime scale in a few clustered blotches
    for (cx, cy, rx, ry) in ((223, 70, 3, 5), (253, 78, 3, 4), (246, 112, 3, 6), (262, 134, 2, 5), (220, 156, 3, 4)):
        for y in range(cy - ry, cy + ry + 1):
            for x in range(cx - rx, cx + rx + 1):
                if ((x - cx) / (rx + .5)) ** 2 + ((y - cy) / (ry + .5)) ** 2 <= 1 and (x, y) in FALL \
                        and nz(x * 1.3, y * 1.3) > -.6:
                    px[x, y] = LIME + (255,)
    # shadow under the lintel and down the left wall (ragged, not a ruler line)
    for (x, y) in FALL:
        lim = 62 + (1 if x > 243 else 0) + (1 if x > 252 else 0) + (1 if (x // 3) % 4 == 1 else 0)
        wl = 215 + (1 if (y // 6) % 3 == 0 else 0) + (1 if (y // 13) % 2 else 0)
        if y <= lim or x <= wl:
            px[x, y] = (R_VD if y <= lim - 1 or x <= wl - 1 else R_DD) + (255,)
    # a few broken shelves of rock, staggered: lit lip, dark undercut
    ledges = [(84, 219, 231), (93, 247, 262), (118, 228, 244), (131, 252, 264), (152, 217, 230), (163, 238, 250),
              (176, 254, 264)]

    def ledge_y(ly, x):
        return ly

    for (ly, x0, x1) in ledges:
        for x in range(x0, x1 + 1):
            y = ledge_y(ly, x)
            end = x in (x0, x1)
            if (x, y) in FALL and (x, y + 3) in FALL:
                p.dot(x, y - 1, R_MID if not end else R_DK)
                p.dot(x, y, R_LT if x < x1 - 2 and not end else R_MID)
                p.dot(x, y + 1, R_VD)
                if not end and x0 + 1 < x < x1 - 1:
                    p.dot(x, y + 2, R_DD)
    # trickles: thin, wavering, broken into drops
    def trickle(x, y0, y1, gaps, seed, wide=()):
        rr = random.Random(seed)
        y = y0
        while y <= y1:
            for (ly, lx0, lx1) in ledges:
                if lx0 <= x <= lx1 and ledge_y(ly, x) == y - 1:
                    x += rr.choice((-2, -1, 1, 2))            # the water finds another way over the lip
            if not any(a <= y <= b for a, b in gaps) and (x, y) in FALL:
                p.dot(x, y, WT_LT)
                if any(a <= y <= b for a, b in wide) and (x + 1, y) in FALL:
                    p.dot(x + 1, y, WT_MID)
            if rr.random() < .06:
                x += rr.choice((-1, 1))
            y += 1
        return x
    tx = trickle(237, 63, 189, ((101, 103), (140, 141), (168, 170)), 3, ((63, 80), (120, 132)))
    trickle(226, 63, 112, ((80, 83), (94, 99)), 5)
    trickle(255, 64, 92, ((74, 76), (84, 88)), 8)
    for (x, y) in ((226, 118), (227, 125), (226, 134), (255, 97), (256, 104), (255, 113)):   # drips
        p.dot(x, y, WT_MID)
    p.web(217, 62, 9, hx('#b6b6c4'))

    # =====================================================================================================
    # 5. the organ pipes
    # =====================================================================================================
    filled = set()

    def rock_fill(x0, y0, x1, y1):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                n = nz(x * 0.9 + 40, y * 1.3)
                c = R_DK
                if n > 1.1:
                    c = R_MID
                elif n < -1.7:
                    c = R_DD
                px[x, y] = c + (255,)
                filled.add((x, y))
    for name, (x0, h) in PIPES.items():
        rock_fill(x0, BASE - h, x0 + 16, BASE)
    rock_fill(155, 106, 161, 119)                              # where a note hung over the shortest pipe
    for y in range(106, 120):                                 # blend that patch into the light rock on its left
        for x in range(155, 162):
            if x - 155 < (119 - y) // 2:
                px[x, y] = R_MID + (255,)

    JAG = {'a': [2, 1, 0, 1, 3, 4, 3, 1, 0, 0, 2, 4, 5, 3, 2, 1, 2],
           'b': [0, 0, 1, 3, 2, 1, 0, 2, 4, 5, 4, 2, 1, 1, 0, 2, 3],
           'c': [3, 2, 2, 0, 0, 1, 2, 1, 0, 1, 3, 2, 0, 0, 1, 1, 0],
           'd': [0, 1, 1, 2, 4, 6, 7, 6, 4, 3, 1, 0, 0, 1, 2, 1, 1]}

    def piece(H0, keep=None, jag='a', chip=None):
        """a standing pipe in template space: {(i, j): colour}; keep = rows left standing (from the base)"""
        out = {}
        kind = {}
        for i in range(17):
            if keep is None:
                f = 0 if 0 < i < 16 else 1
                if chip and chip[0] <= i <= chip[1]:
                    f = chip[2] - abs(i - (chip[0] + chip[1]) // 2) * chip[2] // max(1, (chip[1] - chip[0]) // 2 + 1) + 1
            else:
                f = H0 - keep + JAG[jag][i]
            for j in range(f, H0):
                kind[(i, j)] = 'w'
            if keep is not None and 2 <= i <= 14:
                for j in range(f - (4 if 4 <= i <= 12 else 3), f):
                    kind[(i, j)] = 'h'
        for (i, j), k in kind.items():
            edge = False
            for (a, b) in ((i - 1, j), (i + 1, j), (i, j - 1)):
                if (a, b) not in kind:
                    edge = True
            if edge:
                c = INK
            elif k == 'h':
                c = VOID1 if i <= 8 else VOID2
            elif kind.get((i, j - 1)) == 'h':
                c = INK
            elif kind.get((i, j - 2)) == 'h' and 1 < i < 10:
                c = R_HI
            else:
                c = tcol(i, j)
            out[(i, j)] = c
        return out

    def stand(name, keep=None, jag='a', lean=0.0, chip=None):
        x0, H0 = PIPES[name]
        pc = piece(H0, keep, jag, chip)
        drawn = set()
        for (i, j), c in pc.items():
            y = BASE - (H0 - 1) + j
            x = x0 + i + int(round((BASE - y) * lean))
            y2 = y + int(round((x - (x0 + 8)) * lean))
            if y2 > BASE:
                continue
            px[x, y2] = c + (255,)
            drawn.add((x, y2))
        return drawn

    solid = set()
    solid |= stand('L1', keep=12, jag='b')
    solid |= stand('L2', lean=-0.095)
    solid |= stand('L3', chip=(11, 16, 4))
    solid |= stand('L4', keep=64, jag='a')
    solid |= stand('R1')
    solid |= stand('R2', keep=47, jag='d')
    solid |= stand('R3', lean=0.105)
    solid |= stand('R4', keep=9, jag='c')
    # bare rock behind: shadow to the right of whatever still stands, lighter scar where a pipe used to shield it
    for (x, y) in sorted(filled - solid):
        if (x - 1, y) in solid or (x - 2, y) in solid or (x - 1, y - 1) in solid:
            px[x, y] = R_VD + (255,) if (x - 1, y) in solid else R_DD + (255,)
    for (x, y) in sorted(filled - solid):                      # the ground line under the gaps
        if y == BASE:
            px[x, y] = R_VD + (255,)

    # cracks in the pipes that still stand
    CR = hx('#3a3246')
    for pts in (((184, 118), (185, 121), (187, 123), (187, 127), (189, 130), (188, 134)),
                ((187, 123), (190, 122), (192, 124)),
                ((275, 131), (277, 134), (277, 138), (279, 141), (282, 142)),
                ((277, 138), (275, 141), (275, 145)),
                ((281, 104), (280, 108), (282, 111)),
                ((204, 150), (206, 154), (205, 158), (207, 162)),
                ((292, 160), (294, 163), (293, 168), (296, 171))):
        p.line(list(pts), CR)
    for (x, y) in ((186, 122), (276, 137), (205, 153)):
        p.dot(x, y, R_HI)

    # =====================================================================================================
    # 6. the pond: low, brown and still, on a wide rim of drying mud
    # =====================================================================================================
    MUD1, MUD2, MUD3, MUD4, MUD5 = hx('#a39480'), hx('#8d7c6a'), hx('#766557'), hx('#5d4d48'), hx('#4a3d3e')
    WA1, WA2, WA3, SCUM = hx('#7d8a7c'), hx('#5f6e68'), hx('#4c5a58'), hx('#7c8660')

    def pool_r(x, y):
        u, v = (x - 252) / 104.0, (y - 230) / 16.0
        a = math.atan2(v, u)
        return math.hypot(u, v) - 0.10 * math.sin(a * 3 + 1.0) - 0.05 * math.sin(a * 7 + .4)

    def pond_col(x, y):
        rr = pool_r(x, y)
        n = nz2(x * .5, y * 2.2)
        rr2 = rr + n * 0.022
        if rr2 < 0.80:
            c = WA2
            if nz(x * .16 + 9, y * 1.7) > 1.55:
                c = WA3
            if rr2 > 0.72:
                c = WA3
            return c
        if rr2 < 0.86:
            return SCUM if nz(x * .4, y * .9) > -0.4 else WA3
        if rr2 < 0.93:
            return MUD5
        if rr2 < 1.08:
            return MUD4 if n < 1.9 else MUD5
        if rr2 < 1.12:
            return MUD5                                       # an old waterline
        if rr2 < 1.34:
            return MUD3 if n < 1.7 else MUD4
        if rr2 < 1.37:
            return MUD4
        if rr2 < 1.68:
            return MUD2 if n < 1.6 else MUD3
        if rr2 < 1.71:
            return MUD3
        return MUD1 if n < 1.5 else MUD2
    for (x, y) in POND:
        px[x, y] = pond_col(x, y) + (255,)
    # the rim right under the cliff is in its shade
    for (x, y) in POND:
        if y <= 191 and 128 <= x <= 350:
            px[x, y] = (MUD4 if y == 190 else MUD3) + (255,)
    # still glints on the water
    for (x, y, w) in ((206, 226, 9), (232, 222, 6), (262, 229, 12), (290, 224, 7), (300, 234, 8), (222, 236, 10),
                      (178, 231, 5), (322, 229, 5), (250, 238, 6)):
        for k in range(w):
            if (x + k, y) in POND and col(x + k, y) in (WA2, WA3):
                p.dot(x + k, y, WA1)
    # the trickle's landing: a wet patch and a thin runnel down to the puddle
    for y in range(190, 197):
        for x in range(214, 266):
            d = ((x - tx) / 21.0) ** 2 + ((y - 192) / 4.2) ** 2
            if d < 1 and (x, y) in POND:
                p.dot(x, y, MUD5 if d < .45 else MUD4)
    for y in range(190, 196):                          # a small splash pool where the trickle lands
        for x in range(tx - 11, tx + 12):
            d = ((x - tx) / 10.5) ** 2 + ((y - 192.5) / 2.0) ** 2
            if d <= 1 and (x, y) in POND:
                c = WA2
                if y == 191 and x < tx + 3:
                    c = WA1
                if y >= 194 or (y == 193 and x > tx + 3):
                    c = WA3
                p.dot(x, y, c)
    rx_ = tx
    for y in range(194, 222):
        if y % 4 == 0:
            rx_ += (1 if (y // 4) % 3 else -1)
        if (rx_, y) in POND and col(rx_, y) not in (WA1, WA2, WA3, SCUM):
            p.dot(rx_, y, WA3 if y % 9 else WA2)
            if col(rx_ - 1, y) in (MUD1, MUD2, MUD3):
                p.dot(rx_ - 1, y, MUD4)
    # drying cracks in the pale mud
    rr = random.Random(21)
    for (x, y) in ((150, 197), (176, 200), (198, 204), (284, 199), (312, 196), (334, 203), (300, 207), (128, 205),
                   (360, 212), (372, 222), (160, 246), (232, 250), (268, 252), (300, 249), (140, 214), (216, 201),
                   (350, 240), (120, 196), (386, 216)):
        for (dx, dy, n_) in ((1, 0, rr.randint(4, 7)), (-1, 1, rr.randint(2, 4)), (1, 1, rr.randint(2, 3))):
            cx, cy = x, y
            for k in range(n_):
                if (cx, cy) in POND and col(cx, cy) in (MUD1, MUD2):
                    p.dot(cx, cy, MUD3)
                cx += dx
                if k % 2 and dy:
                    cy += dy
                elif not dy and rr.random() < .3:
                    cy += rr.choice((-1, 1))

    # ---- things left on the mud ------------------------------------------------------------------------
    def shadow(x0, x1, y, c=MUD5):
        for x in range(x0, x1 + 1):
            if (x, y) in POND and col(x, y) != INK:
                p.dot(x, y, c)

    def fallen(X, Y, L, j0=22, flip=False, tilt=0.0, sink=None, jag='a', open_end=True):
        """a length of pipe lying on its side; X,Y = top-left of the body"""
        def draw():
            for j in range(L):
                for i in range(1, 16):
                    if j > L - 1 - JAG[jag][i] // 2:
                        continue
                    x = X + (L - 1 - j if flip else j)
                    y = Y + i + int(round(j * tilt))
                    if sink is not None and y > sink:
                        continue
                    c = tcol(i, j0 + j)
                    if c == INK:
                        c = R_VD
                    p.dot(x, y, c)
            if open_end:
                ex = X + L if flip else X - 1
                for i in range(1, 16):
                    y = Y + i + (int(round((L - 1) * tilt)) if flip else 0)
                    if sink is not None and y > sink:
                        continue
                    w = 3 if 4 <= i <= 12 else (2 if 2 <= i <= 14 else 1)
                    for k in range(w):
                        xx = ex + (k if flip else -k)
                        c = R_LT if (i <= 3 or (k == w - 1 and i < 9)) else (VOID1 if i < 11 else VOID2)
                        if k == 0 and 4 <= i <= 12:
                            c = VOID1
                        p.dot(xx, y, c)
        inked(draw)

    def rubble(x, y, rx, ry, seed=0):
        def draw():
            rr_ = random.Random(seed)
            for yy in range(y - ry, y + ry + 1):
                for xx in range(x - rx, x + rx + 1):
                    dx, dy = (xx - x) / (rx + .5), (yy - y) / (ry + .5)
                    ang = math.atan2(dy, dx)
                    if abs(dx) ** 2.2 + abs(dy) ** 2.2 <= 1 + .05 * math.sin(ang * 2 + seed):
                        t = dx + dy * 1.2
                        p.dot(xx, yy, R_LT if t < -.55 else (R_DD if t > .7 else (R_DK if t > .15 else R_MID)))
        inked(draw)

    # L1's top lies where it fell, half in the mud at the left
    fallen(150, 199, 30, j0=24, tilt=0.07, sink=214, jag='b')
    shadow(148, 184, 216); shadow(150, 182, 217, MUD4)
    # R4's top rolled into the puddle
    fallen(296, 215, 26, j0=30, flip=True, tilt=-0.05, sink=226, jag='c')
    for x in range(292, 327):
        if col(x, 228) in (WA2, WA3, WA1):
            p.dot(x, 228, WA3)
        if col(x, 229) in (WA2, WA3) and x % 7 < 4:
            p.dot(x, 229, WA1)
    # chunks from the two broken tall pipes, at the foot of the cliff
    for (x, y, rx, ry, s) in ((204, 196, 6, 4, 1), (214, 199, 4, 3, 2), (196, 200, 3, 2, 3), (288, 196, 7, 4, 4),
                              (299, 199, 4, 3, 5), (279, 200, 3, 2, 6), (226, 204, 3, 2, 7), (314, 196, 5, 3, 8)):
        rubble(x, y, rx, ry, s)
        shadow(x - rx + 1, x + rx + 2, y + ry + 2)
    # exposed stones in and around the puddle
    for (x, y, rx, ry, s) in ((240, 243, 8, 4, 11), (262, 246, 5, 3, 12), (190, 222, 6, 3, 13), (276, 219, 4, 2, 14),
                              (346, 246, 6, 3, 15), (226, 229, 5, 2, 16), (128, 240, 5, 3, 17)):
        if all((x + dx, y + dy) in POND for dx in (-rx - 1, rx + 1) for dy in (-ry - 1, ry + 1)):
            rubble(x, y, rx, ry, s)
            shadow(x - rx + 1, x + rx + 2, y + ry + 2, WA3 if col(x, y + ry + 3) in (WA1, WA2, WA3) else MUD5)
    # contact shadows under the two stones that were always there
    for x in range(176, 206):
        for y in range(252, 258):
            if (x, y) in POND and col(x, y - 1) == INK and col(x, y) != INK:
                p.dot(x, y, MUD5)
    for x in range(315, 346):
        for y in range(246, 254):
            if (x, y) in POND and col(x, y - 1) == INK and col(x, y) != INK:
                p.dot(x, y, MUD5)

    # the frog's lily pad, dried up and curled on the mud
    LP1, LP2, LP3 = hx('#a08a62'), hx('#84704f'), hx('#66563f')

    def pad():
        for yy in range(-4, 5):
            for xx in range(-13, 14):
                if (xx / 13.0) ** 2 + (yy / 4.0) ** 2 <= 1 and not (xx > 3 and abs(yy + 1) * 3 < xx - 3):
                    c = LP2
                    if yy <= -2 or (xx < -8 and yy < 1):
                        c = LP1
                    if yy >= 3 or xx > 9:
                        c = LP3
                    p.dot(364 + xx, 232 + yy, c)
        for (a, b) in (((356, 231), (364, 232)), ((364, 232), (370, 235)), ((364, 232), (360, 235)),
                       ((364, 232), (368, 229))):
            p.line([a, b], LP3)
    inked(pad)
    shadow(354, 376, 238)

    # dry reeds
    RD1, RD2, RD3, CAT = hx('#b7a67c'), hx('#93835f'), hx('#6f6048'), hx('#86603f')

    def reed(x, y, h, bend=0, cat=True, snap=None):
        cx = x
        for k in range(h):
            if snap and k == snap[0]:
                # the stalk has snapped: the top hangs down at a steep angle
                for m in range(snap[1]):
                    p.dot(cx + ((m + 1) // 2) * snap[2], y - k + m + 1, RD2)
                return
            if bend and k and k % bend == 0:
                cx += 1 if bend > 0 else -1
            p.dot(cx, y - k, RD1 if k > h // 2 else RD2)
        if cat:
            for m in range(5):
                p.dot(cx, y - h - m, CAT)
                p.dot(cx + 1, y - h - m, hx('#6a4a36') if m > 1 else CAT)
            p.dot(cx, y - h - 5, RD3)

    def clump(x, y, spec):
        def draw():
            for (dx, h, b, c, s_) in spec:
                reed(x + dx, y - abs(dx) // 3, h, b, c, s_)
            for k in range(-4, 6):                        # the clump's own little base of dead blades
                p.dot(x + k, y + 1, RD3)
                if -3 <= k <= 4:
                    p.dot(x + k, y, RD2)
        inked(draw)
        shadow(x - 4, x + 7, y + 2)
    clump(168, 235, ((-3, 8, -4, False, None), (-1, 13, 7, True, None), (1, 11, 0, False, (6, 5, 1)),
                     (3, 14, -9, True, None), (5, 9, 5, False, None)))
    clump(340, 222, ((-3, 11, -5, False, None), (-1, 19, -8, True, None), (1, 22, 0, True, None),
                     (3, 15, 7, False, (8, 6, 1)), (5, 12, 5, False, None)))
    # a couple of dead leaves on the water
    for (x, y) in ((214, 231), (270, 235), (246, 226), (306, 238)):
        if col(x, y) in (WA1, WA2, WA3):
            p.dot(x, y, hx('#9a7d56')); p.dot(x + 1, y, hx('#9a7d56')); p.dot(x + 2, y, hx('#7a6046'))
            p.dot(x + 1, y - 1, hx('#b29668'))

    # =====================================================================================================
    # 7. moss, vines, a seedling
    # =====================================================================================================
    def moss_tuft(x, y, w, hang=True, seed=0):
        """a cushion of moss sitting on a ledge whose top row is y"""
        rr_ = random.Random(seed)
        for i in range(w):
            t = i / float(max(1, w - 1))
            hgt = 1 + int(round(1.6 * math.sin(t * math.pi))) + (1 if rr_.random() < .25 else 0)
            for k in range(hgt):
                c = M_LT if k == hgt - 1 and i < w * .6 else (M_DK if (k == 0 and i > w * .5) else M_MID)
                if col(x + i, y - k) != INK or k == 0:
                    p.dot(x + i, y - k, c)
            if hang and rr_.random() < .35:
                for k in range(1, rr_.randint(2, 4)):
                    if col(x + i, y + k) != INK:
                        p.dot(x + i, y + k, M_DK if k > 1 else M_MID)
    for (x, y, w, s) in ((214, 49, 12, 1), (228, 49, 6, 2), (251, 52, 9, 3), (181, 96, 7, 4), (271, 89, 9, 5),
                         (156, 104, 8, 6), (199, 126, 7, 7), (289, 143, 8, 8), (146, 177, 8, 9), (322, 180, 7, 10),
                         (135, 189, 9, 11), (338, 189, 8, 12), (221, 83, 7, 13), (253, 130, 6, 14),
                         (219, 151, 7, 15), (166, 108, 6, 16), (306, 104, 6, 17), (300, 78, 8, 18),
                         (176, 78, 7, 19)):
        moss_tuft(x, y, w, True, s)
    # moss creeping over the rock of the cliff itself, in drifts
    for (cx, cy, rx, ry) in ((158, 86, 10, 4), (296, 72, 9, 4), (318, 132, 7, 6), (140, 150, 6, 9),
                             (338, 160, 5, 10), (190, 68, 8, 3)):
        for yy in range(cy - ry, cy + ry + 1):
            for xx in range(cx - rx, cx + rx + 1):
                d = ((xx - cx) / float(rx)) ** 2 + ((yy - cy) / float(ry)) ** 2
                if d <= 1 and col(xx, yy) in ROCK and nz2(xx * 1.4, yy * 1.4) > 0.2 + d * 0.9:
                    p.dot(xx, yy, M_LT if nz2(xx * 1.4, yy * 1.4) > 1.6 else (M_MID if col(xx, yy) != R_DD else M_DK))
    # vines from the lintel and the cliff top
    V1, V2 = hx('#55653f'), hx('#7d8c58')
    p.rng = random.Random(5)
    for (x, y, ln) in ((216, 60, 26), (262, 64, 30), (172, 70, 22), (305, 68, 26),
                       (150, 96, 18), (330, 120, 20), (282, 90, 16), (207, 132, 12)):
        p.vine(x, y, ln, (V1, V2), sway=1, leaf=.4)
    # a seedling has taken root in the tall broken pipe
    def seedling():
        p.line([(204, 124), (204, 119)], hx('#5d7a3c'))
        p.dot(203, 119, hx('#8fb05a')); p.dot(202, 118, hx('#8fb05a')); p.dot(205, 120, hx('#7d9c4c'))
        p.dot(206, 119, hx('#8fb05a')); p.dot(207, 118, hx('#8fb05a')); p.dot(203, 118, hx('#7d9c4c'))
    seedling()

    # bare twigs standing out of the dead bushes, fallen leaves in the grass
    TW = hx('#4a3a38')
    for (x, dx, h, fork) in ((36, 1, 9, 1), (70, 1, 8, -1), (418, -1, 9, 1), (442, 1, 8, -1), (104, 1, 7, 1),
                             (395, -1, 7, 1), (458, 0, 6, -1), (12, 0, 6, 1)):
        y = 140
        while y < 268 and col(x, y) != INK:
            y += 1
        y += 2                                        # rooted just inside the bush
        top = (x + dx * 2, y - h)
        p.line([(x, y), (x + dx, y - h // 2), top], TW)
        p.line([(x + dx, y - h // 2), (x + dx + fork * 3, y - h // 2 - 3)], TW)
    # the meadow flowers have dried to brown heads on bent stalks
    for (x, y) in ((140, 222), (430, 232), (20, 236), (96, 244), (452, 250)):
        for k in range(-1, 2):
            for m in range(-1, 2):
                if abs(k) + abs(m) <= 1 and col(x + k, y + m) in ((202, 198, 192), (202, 191, 161)):
                    px[x + k, y + m] = px[x + 3, y + m] if col(x + 3, y + m) != INK else px[x - 3, y + m]
        p.dot(x, y + 2, hx('#7d6c52')); p.dot(x, y + 3, hx('#7d6c52'))
        p.dot(x + 1, y + 1, hx('#7d6c52'))
        p.dot(x + 2, y + 1, hx('#8a6e50')); p.dot(x + 2, y + 2, hx('#6a5442'))
    rr = random.Random(9)
    for _ in range(70):
        x, y = rr.randint(4, 474), rr.randint(246, 262)
        if col(x, y) in (hx('#6a7050'), hx('#5a6048'), hx('#868a60')) and col(x + 1, y) == col(x, y):
            c = rr.choice((hx('#a38a66'), hx('#846a52'), hx('#bfa97c')))
            p.dot(x, y, c); p.dot(x + 1, y, c)
            if rr.random() < .5:
                p.dot(x + 1, y - 1, c)
