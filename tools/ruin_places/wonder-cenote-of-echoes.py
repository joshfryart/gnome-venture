"""Ruined Cenote of Echoes: the sun shaft is gone, the pool has sunk to a murky green puddle, the rope ladder snapped."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from ruin_lib import Pic, hx, INK

DUSK = (0x6a, 0x66, 0x7c)
SAT, VAL = 0.5, 0.86


def build(p):
    import colorsys, random
    from collections import Counter
    px = p.px
    W, H = p.w, p.h

    def rm(h):
        r, g, b = hx(h) if isinstance(h, str) else h
        hh, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        c = [round(k * 255) for k in colorsys.hsv_to_rgb(hh, min(1, s * SAT), min(1, v * VAL))]
        return tuple(round(c[i] * .88 + DUSK[i] * .12) for i in range(3))

    def col(x, y):
        return px[x, y][:3] if 0 <= x < W and 0 <= y < H else None

    def put(x, y, c):
        if 0 <= x < W and 0 <= y < H:
            px[x, y] = tuple(c) + (255,)

    def inked(draw):
        b = p.snapshot()
        draw()
        p.outline_new(b)

    def stamp(x, y, rows, pal):
        for j, row in enumerate(rows):
            for i, ch in enumerate(row):
                if ch in pal:
                    put(x + i, y + j, pal[ch])

    # ================= 1. the sun shaft (a checker overlay in the live art) is taken out =====================
    BX0, BY0, BX1, BY1 = 72, 66, 426, 207
    outside = Counter()
    for y in range(H):
        for x in range(W):
            if not (BX0 <= x <= BX1 and BY0 <= y <= BY1):
                outside[px[x, y][:3]] += 1
    base = {c for c, n in outside.items() if n >= 100}
    base |= {hx('#e8f6e8')}
    todo = {(x, y) for y in range(BY0, BY1 + 1) for x in range(BX0, BX1 + 1) if px[x, y][:3] not in base}
    # outlines that the overlay tinted: a tinted pixel sitting between two ink pixels is ink
    for (x, y) in list(todo):
        for (ax, ay) in ((1, 0), (0, 1), (1, 1), (1, -1)):
            if col(x + ax, y + ay) == INK and col(x - ax, y - ay) == INK:
                put(x, y, INK)
                todo.discard((x, y))
                break
    while todo:
        done = {}
        for (x, y) in todo:
            cnt = Counter()
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    if (dx or dy) and (x + dx, y + dy) not in todo:
                        c = col(x + dx, y + dy)
                        if c and c != INK:
                            cnt[c] += 2 if (dx == 0 or dy == 0) else 1
            if cnt:
                done[(x, y)] = cnt.most_common(1)[0][0]
        if not done:
            break
        for (x, y), c in done.items():
            put(x, y, c)
            todo.discard((x, y))

    WALLS = [hx(h) for h in ('#283840', '#202c32', '#182226', '#121a20', '#34484e', '#34464e', '#223038')]
    WALLSET = set(WALLS)
    # stray outline bits the overlay left on the bare wall (ink with only wall around it)
    for _ in range(2):
        kill = []
        for y in range(BY0, BY1 + 1):
            for x in range(BX0, BX1 + 1):
                if col(x, y) != INK:
                    continue
                ok = True
                cnt = Counter()
                for dy in range(-2, 3):
                    for dx in range(-2, 3):
                        c = col(x + dx, y + dy)
                        if c is None or c == INK:
                            continue
                        if c not in WALLSET:
                            ok = False
                        elif abs(dx) <= 1 and abs(dy) <= 1:
                            cnt[c] += 1
                if ok:
                    kill.append((x, y, cnt.most_common(1)[0][0] if cnt else WALLS[0]))
        for x, y, c in kill:
            put(x, y, c)

    # ================= 2. the cave bat is gone ===============================================================
    p.copy_block((60, 96), (60, 70), 20, 22)

    # ================= 3. pool mask (live colours), then the overcast recolour ===============================
    WATER = {hx(h) for h in ('#28a0aa', '#1f7a94', '#44c8c0', '#1a5e78', '#e8fff0', '#d8fff0', '#fff1cf', '#8ee8dc',
                             '#9aeee0', '#16485c', '#fffbe0', '#fff4d6', '#c8ecee', '#a8dcec')}
    BAND = {hx('#1a5e78'): 0, hx('#1f7a94'): 1, hx('#28a0aa'): 2, hx('#44c8c0'): 3, hx('#e8fff0'): 4, hx('#fff1cf'): 5}
    pool = {(240, 205)}
    st = [(240, 205)]
    while st:
        x, y = st.pop()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if n not in pool and col(*n) in WATER:
                pool.add(n)
                st.append(n)
    band = {}
    todo = set()
    for n in pool:
        c = col(*n)
        if c in BAND:
            band[n] = BAND[c]
        else:
            todo.add(n)
    # thin dashes of the bright tones are ripples too: a glow pixel with no glow above and below
    for n in list(band):
        if band[n] >= 4:
            x, y = n
            if band.get((x, y - 1), 0) < 4 and band.get((x, y + 1), 0) < 4:
                todo.add(n)
    for n in todo:
        band.pop(n, None)
    while todo:
        done = {}
        for (x, y) in todo:
            cnt = Counter()
            for dx, dy in ((0, 1), (0, -1), (1, 0), (-1, 0)):
                if (x + dx, y + dy) in band:
                    cnt[band[(x + dx, y + dy)]] += 1
            if cnt:
                done[(x, y)] = cnt.most_common(1)[0][0]
        if not done:
            break
        band.update(done)
        todo -= set(done)
    top = {}
    for (x, y) in pool:
        top[x] = min(top.get(x, 999), y)

    p.remap(sat=SAT, val=VAL, tint=DUSK)
    ink_rm = rm(INK)
    p.recolor((0, 0, W - 1, H - 1), lambda r, g, b: INK if (r, g, b) == ink_rm else None)

    # ---- sky: flat grey overcast, heavy clouds
    sky = {rm('#8cd0e8'): hx('#7f8798'), rm('#a8dcec'): hx('#8f96a4'), rm('#c8ecee'): hx('#a0a6b0'),
           rm('#e8f6e8'): hx('#b1b5ba'), rm('#fffdf0'): hx('#c6c8cc'), rm('#cfe6e8'): hx('#9a9fae')}
    p.recolor((100, 8, 380, 100), lambda r, g, b: sky.get((r, g, b)))

    # ---- bushes on the rim: tired green, the right-hand ones withered brown
    G = [rm(h) for h in ('#8cd05a', '#6bb551', '#4a9a48', '#4a8a48', '#2e6e44', '#265c3e', '#1e4a38')]
    dead = dict(zip(G, [hx(h) for h in ('#93885e', '#7d7350', '#665d46', '#665d46', '#4f483c', '#453f38', '#3a3534')]))
    dull = dict(zip(G, [hx(h) for h in ('#7f9a62', '#6a8556', '#55704c', '#55704c', '#425a44', '#384c3e', '#2f3f38')]))
    p.recolor((0, 0, W - 1, 110), lambda r, g, b: dull.get((r, g, b)))
    dl = {dull[k]: dead[k] for k in G}
    for (cx, cy, r) in ((336, 18, 17), (373, 50, 15), (270, 10, 9), (100, 50, 11), (150, 14, 8)):
        for yy in range(cy - r, cy + r + 1):
            for xx in range(cx - r, cx + r + 1):
                if (xx - cx) ** 2 + (yy - cy) ** 2 <= r * r and 0 <= xx < W and 0 <= yy < H:
                    c = dl.get(col(xx, yy))
                    if c:
                        put(xx, yy, c)

    # ================= 4. the pool: sunk, murky, a mud wall under the rim ====================================
    WCOL = [hx(h) for h in ('#2e3d3c', '#374840', '#405243', '#495d46', '#526749', '#5c714f')]
    MUD_SH, MUD_DK, MUD, MUD_LT, MUD_WET = hx('#35292f'), hx('#55463f'), hx('#6b5a4c'), hx('#7f6d59'), hx('#473c3a')
    rr = random.Random(11)
    streak = {}
    for x in range(W):
        streak[x] = rr.random()

    def depth(x):
        return 8 if 110 <= x <= 370 else (7 if 80 <= x <= 400 else 6)
    water = set()
    for (x, y) in pool:
        d = y - top[x]
        dp = depth(x)
        if d < dp:
            k = (x // 7 + (x // 23)) % 5
            if d <= 1:
                c = MUD_SH
            elif d == 2:
                c = MUD_DK
            elif d == dp - 1:
                c = MUD_WET
            elif d == 4 and k in (0, 1, 3):
                c = MUD_LT                                   # old water line
            elif d == 3 and k == 2:
                c = MUD_LT
            elif d >= dp - 3 and (x // 11) % 3 == 0:
                c = MUD_DK
            else:
                c = MUD
            put(x, y, c)
        else:
            water.add((x, y))
            put(x, y, WCOL[band.get((x, y), 2)])
    # drip runs down the mud wall
    for x in range(70, 415, 1):
        if x in top and (x * 37) % 53 < 3:
            for d in range(2, depth(x) - 1):
                put(x, top[x] + d, MUD_DK)

    # ---- stagnant green film: flat clustered rafts, lit edge upper left, dark lower edge
    F_LT, F_MID, F_DK = hx('#8a9c5c'), hx('#6f824c'), hx('#56683f')

    def raft(cx, cy, parts):
        cells = set()
        for (ox, oy, rx, ry) in parts:
            for yy in range(cy + oy - ry, cy + oy + ry + 1):
                t = 1 - ((yy - cy - oy) / (ry + .5)) ** 2
                w = int(rx * (t ** .5)) if t > 0 else 0
                for xx in range(cx + ox - w, cx + ox + w + 1):
                    if (xx, yy) in water:
                        cells.add((xx, yy))
        for (xx, yy) in cells:
            if (xx, yy + 1) not in cells and (xx, yy + 1) in water:
                c = F_DK
            elif (xx, yy - 1) not in cells:
                c = F_LT
            else:
                c = F_MID
            put(xx, yy, c)
    raft(96, 222, [(0, 0, 16, 2), (12, 2, 12, 2), (-8, -2, 8, 1)])
    raft(160, 211, [(0, 0, 22, 1), (10, 2, 10, 1)])
    raft(300, 210, [(0, 0, 18, 1), (-12, 1, 9, 1)])
    raft(384, 226, [(0, 0, 14, 2), (-10, 3, 12, 2), (8, -3, 8, 1)])
    raft(205, 248, [(0, 0, 13, 2), (11, 2, 9, 1)])
    raft(262, 229, [(0, 0, 12, 1), (8, 2, 8, 1)])
    raft(318, 252, [(0, 0, 20, 2), (-16, 2, 10, 1), (14, -2, 9, 1)])
    raft(140, 250, [(0, 0, 11, 1), (-8, 2, 9, 1)])
    raft(236, 207, [(0, 0, 9, 1)])
    raft(60, 238, [(0, 0, 9, 2), (6, 3, 7, 1)])

    # ---- the last few ripples, as plain rings round a drip
    RING = hx('#8c9c80')

    def ring(cx, cy, rx, ry, gaps):
        import math
        n = 24 * (rx + ry)
        for i in range(n):
            a = 2 * math.pi * i / n
            if any(g0 <= a <= g1 for g0, g1 in gaps):
                continue
            xx, yy = int(round(cx + rx * math.cos(a))), int(round(cy + ry * math.sin(a)))
            if (xx, yy) in water and col(xx, yy) in WCOL:
                put(xx, yy, RING)
    ring(178, 226, 4, 1, [])
    ring(178, 226, 10, 3, [])
    ring(178, 226, 18, 5, [(0.2, 1.1), (3.5, 4.3)])
    ring(322, 222, 3, 1, [])
    ring(322, 222, 9, 3, [(2.0, 2.9)])
    ring(322, 222, 16, 5, [(0.4, 1.4), (3.3, 4.0), (5.0, 5.6)])

    # ================= 5. tidy the stalactites the shaft used to wash over ===================================
    WR = {rm(c) for c in WALLS}
    WBASE = rm('#283840')
    SKYC = set(sky.values())

    def is_wall(x, y):
        return col(x, y) in WR

    Z = (100, 70, 400, 152)
    for _ in range(2):
        kill = []
        for y in range(Z[1], Z[3] + 1):
            for x in range(Z[0], Z[2] + 1):
                if col(x, y) == INK:
                    if all(col(x + dx, y + dy) in WR or col(x + dx, y + dy) == INK
                           for dx in (-1, 0, 1) for dy in (-1, 0, 1)):
                        kill.append((x, y))
        for x, y in kill:
            c = Counter(col(x + dx, y + dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1) if is_wall(x + dx, y + dy))
            put(x, y, c.most_common(1)[0][0] if c else WBASE)
    edge = []
    for y in range(Z[1], Z[3] + 1):
        for x in range(Z[0], Z[2] + 1):
            c = col(x, y)
            if c != INK and c not in WR and c not in SKYC:
                if any(is_wall(x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    edge.append((x, y))
    for x, y in edge:
        put(x, y, INK)

    # what is left of the sun shaft: three flat, barely lighter bands of grey daylight on the back wall
    for y in range(101, 200):
        t = (y - 101) / 98.0
        for (a0, a1, b0, b1) in ((176, 204, 118, 168), (222, 262, 196, 268), (282, 306, 300, 352)):
            for x in range(int(a0 + (b0 - a0) * t), int(a1 + (b1 - a1) * t) + 1):
                c = col(x, y)
                if c in WR:
                    put(x, y, (c[0] + 9, c[1] + 10, c[2] + 12))
    WR |= {(c[0] + 9, c[1] + 10, c[2] + 12) for c in WR}

    ST_LT, ST_MID, ST_DK, ST_SH, ST_SH2 = [rm(h) for h in ('#b4b8b4', '#9da2a2', '#868c90', '#586070', '#48505f')]
    SL_LT, SL_MID, SL_DK, SL_RIM = [rm(h) for h in ('#6e7888', '#5a6579', '#46526a', '#7a9aaa')]
    STONES = {ST_LT, ST_MID, ST_DK, ST_SH, ST_SH2}

    # one stalactite has snapped: the stump keeps a pale ragged fracture, its tip lies in the pool
    for y in range(120, 150):
        for x in range(188, 214):
            if not is_wall(x, y):
                px[x, y] = px[x + 30, y] if is_wall(x + 30, y) else WBASE + (255,)
    for x in range(188, 214):
        if not is_wall(x, 119) and col(x, 119) != INK:
            j = (x * 7) % 3
            for yy in range(119, 120 + j):
                put(x, yy, SL_LT)
            put(x, 120 + j, INK)
        elif col(x, 119) == INK:
            put(x, 120, INK if not is_wall(x - 1, 119) or not is_wall(x + 1, 119) else col(x, 120))

    for y in range(102, 109):                                            # (its dotted band read as a face)
        for x in range(186, 198):
            if col(x, y) not in (INK, SL_LT, SL_MID, SL_DK, SL_RIM) and not is_wall(x, y):
                put(x, y, SL_MID)

    def tip():
        p.poly([(262, 254), (290, 246), (297, 249), (295, 255), (268, 257)], SL_MID)
        p.line([(266, 254), (290, 247)], SL_LT)
        p.line([(270, 254), (288, 249)], SL_LT)
        p.line([(268, 256), (294, 254)], SL_DK)
        p.line([(276, 255), (294, 253)], SL_DK)
        p.poly([(291, 247), (296, 249), (294, 254), (291, 252)], SL_RIM)
        put(293, 250, SL_LT)
    inked(tip)

    # ================= 6. fallen slabs in the water ==========================================================
    def slab(t, l, r):
        p.poly(t, ST_LT)
        p.poly(l, ST_DK)
        p.poly(r, ST_SH)
    inked(lambda: slab([(118, 214), (140, 209), (152, 213), (131, 219)],
                       [(118, 215), (131, 220), (131, 226), (119, 221)],
                       [(132, 220), (152, 214), (152, 219), (132, 226)]))
    for (x0, x1, y) in ((124, 131, 214), (134, 143, 212), (130, 137, 216), (141, 147, 213)):
        p.line([(x0, y), (x1, y)], ST_MID)
    p.line([(136, 211), (138, 214), (137, 216)], ST_SH)
    p.line([(120, 217), (123, 219)], ST_MID)
    p.line([(135, 221), (139, 222)], ST_SH2)
    inked(lambda: slab([(362, 232), (384, 225), (400, 230), (380, 238)],
                       [(362, 233), (380, 239), (380, 245), (363, 239)],
                       [(381, 239), (400, 231), (400, 236), (381, 245)]))
    for (x0, x1, y) in ((368, 376, 232), (380, 390, 228), (378, 386, 234), (388, 395, 231), (372, 379, 230)):
        p.line([(x0, y), (x1, y)], ST_MID)
    p.line([(383, 227), (381, 231), (384, 235)], ST_SH)
    p.line([(366, 236), (370, 238)], ST_MID)
    p.line([(386, 240), (392, 238)], ST_SH2)
    for (x0, x1, y) in ((117, 133, 228), (133, 153, 221), (361, 381, 247), (382, 401, 238), (263, 296, 259)):
        for x in range(x0, x1 + 1):                                      # dark still water hugging the rubble
            if (x, y) in water and col(x, y) != INK:
                put(x, y, WCOL[0])
    raft(126, 230, [(0, 0, 9, 1)])
    raft(372, 249, [(0, 0, 10, 1)])
    raft(280, 261, [(0, 0, 12, 1)])

    # ================= 7. the rope ladder: snapped, the lower half lies on the ledge =========================
    R_LT, R_DK, WD_LT, WD_DK = hx('#93806a'), hx('#6d5c50'), hx('#8a6f60'), hx('#614d49')

    def rope(x, y0, y1):
        for y in range(y0, y1 + 1):
            put(x, y, R_LT if (y // 2) % 2 == 0 else R_DK)

    def ladder():
        rope(226, 91, 151)
        rope(236, 91, 126)
        for y in (99, 107):
            p.line([(227, y), (235, y)], WD_LT)
            p.line([(227, y + 1), (235, y + 1)], WD_DK)
        p.line([(227, 115), (229, 115)], WD_LT); p.line([(227, 116), (228, 116)], WD_DK)   # a rung broken off short
        put(235, 115, WD_LT); put(235, 116, WD_DK)
        p.line([(227, 123), (235, 124)], WD_LT)
        p.line([(227, 124), (235, 125)], WD_DK)
        p.line([(227, 133), (233, 139)], WD_LT)                         # last rung hangs by one end
        p.line([(227, 134), (232, 139)], WD_DK)
        put(225, 152, R_LT); put(227, 153, R_DK); put(226, 152, R_DK)   # frayed ends
        put(237, 127, R_LT); put(235, 128, R_DK); put(236, 127, R_DK)
        p.rect(225, 89, 227, 90, WD_DK); p.rect(235, 89, 237, 90, WD_DK)   # pegs in the rim
        put(225, 89, WD_LT); put(235, 89, WD_LT)
    inked(ladder)

    # the fallen half lies flat along the ledge (outer silhouette inked by hand so the rungs stay open)
    for x in range(214, 257):
        yt = 189 + (1 if x < 226 else 0) - (1 if x > 246 else 0)
        put(x, yt, R_LT if (x // 2) % 2 == 0 else R_DK)
        put(x, yt + 5, R_DK if (x // 2) % 2 == 0 else R_LT)
        put(x, yt - 1, INK); put(x, yt + 6, INK)
        if x in (218, 228, 238, 249):
            for yy in range(yt + 1, yt + 5):
                put(x, yy, WD_LT); put(x + 1, yy, WD_DK)
    for yy in range(188, 197):
        put(213, yy + 1, INK) if 189 <= yy <= 195 else None
    for (x, y) in ((257, 187), (258, 188), (258, 189), (257, 193), (258, 194), (259, 195)):
        put(x, y, INK)
    put(257, 188, R_LT); put(257, 194, R_DK); put(258, 195, R_LT)       # frayed ends

    # ================= 8. roots over the opening, dead glow-vines under it ===================================
    ROOT, ROOT_LT = hx('#4c3e3a'), hx('#665449')
    for (x, n, s) in ((158, 15, 1), (171, 8, -1), (196, 19, 1), (214, 9, 1), (238, 24, -1), (262, 11, 1),
                      (284, 17, -1), (306, 13, 1), (322, 7, -1)):
        y = 8
        while y < 60 and col(x, y) not in SKYC:
            y += 1
        cx = x
        for i in range(n):
            if col(cx, y + i) not in SKYC:
                break
            put(cx, y + i, ROOT if i < n - 3 else ROOT_LT)
            if i in (n // 3, 2 * n // 3) and col(cx + s, y + i + 1) in SKYC:
                put(cx + s, y + i, ROOT)
                put(cx + 2 * s, y + i + 1, ROOT_LT)
                s = -s
            if i % 5 == 4:
                cx += (1 if (x + i) % 2 else -1)
    V_DK, V_LF, POD, POD_DK = hx('#4b4a3c'), hx('#6e6a4a'), hx('#6a6680'), hx('#4b485e')
    p.rng.seed(5)
    for (x, y, n) in ((125, 80, 36), (151, 96, 24), (176, 100, 13), (272, 103, 30), (304, 100, 17), (327, 92, 44),
                      (371, 62, 40), (344, 84, 20)):
        p.vine(x, y, n, (V_DK, V_LF), sway=1, leaf=0.22)
        if n > 15:                                                     # the bulb that used to glow
            ex = x
            for dx in (-1, 0, 1):
                if col(x + dx, y + n - 1) == V_DK:
                    ex = x + dx
            put(ex, y + n, POD); put(ex - 1, y + n, POD); put(ex, y + n + 1, POD_DK); put(ex - 1, y + n + 1, POD_DK)

    # ================= 9. dry cracked ledges, moss, dead glow-caps, a dead candle and one seedling ===========
    CRK = hx('#46424f')

    def crk(x, y, steps, dx, seed):
        r = random.Random(seed)
        for i in range(steps):
            if col(x, y) in STONES:
                put(x, y, CRK if i < steps - 2 else ST_SH2)
            x += dx if r.random() < .75 else 0
            y += 1 if r.random() < .55 else 0
            if steps >= 16 and i == steps // 2 and col(x + dx, y + 2) in STONES and col(x, y + 1) in STONES:
                put(x, y + 1, CRK)
                put(x, y + 2, CRK)
                put(x - dx, y + 3, ST_SH2)
    for a in ((10, 238, 24, 1, 1), (66, 240, 14, -1, 2), (40, 254, 10, 1, 3), (424, 242, 22, 1, 4), (472, 244, 16, -1, 5),
              (410, 252, 9, 1, 6), (146, 194, 12, 1, 7), (302, 189, 11, -1, 8), (342, 193, 12, 1, 9), (96, 205, 11, -1, 10),
              (188, 188, 9, 1, 12), (394, 204, 12, 1, 13), (272, 188, 9, -1, 14)):
        crk(*a)

    M_LT, M_MID, M_DK = hx('#7b8f5c'), hx('#61764c'), hx('#4a5c40')

    def mossp(cx, cy, w):
        for (dy, x0, x1, c) in ((0, 1, w - 2, M_LT), (1, 0, w, M_MID), (2, 2, w - 1, M_DK)):
            for x in range(cx + x0, cx + x1 + 1):
                if col(x, cy + dy) in STONES:
                    put(x, cy + dy, c)
    for a in ((98, 206, 9), (176, 191, 7), (281, 190, 10), (352, 197, 7), (408, 213, 8), (150, 238, 8), (286, 235, 7),
              (328, 241, 9), (28, 237, 10), (440, 240, 9), (8, 252, 6), (466, 255, 7), (166, 93, 7), (296, 96, 8),
              (140, 78, 5), (334, 80, 6), (124, 212, 6), (386, 228, 6), (62, 232, 6)):
        mossp(*a)

    CAP = {'c': hx('#787391'), 'C': hx('#5c5870'), 'd': hx('#474459'), 's': hx('#cbc5b8'), 'S': hx('#a59f96')}
    for (x, y, rows) in ((20, 242, (' ccc ', 'cCCCd', '  sS ', '  s  ')), (34, 247, (' cc ', 'cCCd', ' s  ')),
                         (48, 239, ('  ccc ', ' cCCCd', 'cCCdd ', '  sS  ', '   s  ', '   s  ')),
                         (432, 248, (' ccc ', 'cCCCd', '  sS ', '  s  ')), (449, 244, (' cc ', 'cCCd', '  s ')),
                         (461, 246, (' ccc  ', 'cCCCd ', ' ddCCd', '  S   ', '  s   '))):
        inked(lambda: stamp(x, y, rows, CAP))

    for y in range(213, 216):
        for x in range(238, 241):
            put(x, y, ST_LT if y < 215 else ST_MID)
    p.rect(238, 216, 239, 219, hx('#a39c8c'))
    p.rect(240, 216, 240, 219, hx('#7f796e'))
    put(239, 215, hx('#3a3034')); put(238, 216, hx('#b5ae9d')); put(237, 219, hx('#a39c8c'))
    put(246, 216, M_DK); put(246, 215, M_MID); put(245, 214, M_LT); put(247, 214, M_LT); put(244, 214, M_MID)

    # cobwebs in the stalactite gaps
    WEB = hx('#7c7b8c')

    def swag(x0, x1, y, sag):
        n = x1 - x0
        for i in range(n + 1):
            t = i / float(n)
            yy = y + int(round(sag * 4 * t * (1 - t)))
            if col(x0 + i, yy) in WR:
                put(x0 + i, yy, WEB)
    for (x0, x1) in ((90, 99), (382, 391)):
        swag(x0, x1, 4, 3)
        swag(x0 + 1, x1 - 1, 7, 4)
        for yy in range(8, 15):
            if col((x0 + x1) // 2, yy) in WR and yy != 11:
                put((x0 + x1) // 2, yy, WEB)
