"""Ruined Turtle Nesting Beach: the turtles are gone, the nests are empty pits, the lookout hut has sunk on its stilts."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from ruin_lib import Pic, hx, INK

DUSK = hx('#6a6488')


def build(p):
    import math, random, colorsys
    px = p.px
    src = p.im.copy()
    spx = src.load()

    def rm(c):
        """live colour -> overcast colour"""
        if isinstance(c, str):
            c = hx(c)
        if c == INK:
            return INK
        hh, s, v = colorsys.rgb_to_hsv(c[0] / 255, c[1] / 255, c[2] / 255)
        k = [round(q * 255) for q in colorsys.hsv_to_rgb(hh, min(1, s * .5), min(1, v * .9))]
        return tuple(round(k[i] * .88 + DUSK[i] * .12) for i in range(3))

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

    def mk_noise(seed, sx, sy):
        r = random.Random(seed)
        g = {}

        def gv(i, j):
            if (i, j) not in g:
                g[(i, j)] = r.random()
            return g[(i, j)]

        def n(x, y):
            fx, fy = x / sx, y / sy
            ix, iy = int(math.floor(fx)), int(math.floor(fy))
            tx, ty = fx - ix, fy - iy
            tx, ty = tx * tx * (3 - 2 * tx), ty * ty * (3 - 2 * ty)
            a = gv(ix, iy) * (1 - tx) + gv(ix + 1, iy) * tx
            b = gv(ix, iy + 1) * (1 - tx) + gv(ix + 1, iy + 1) * tx
            return a * (1 - ty) + b * ty
        return n

    # ================= 1. the plate: sky without stars/hut, new sea and sand (live colours) ====================
    # stars: nearly all hidden by the overcast
    def is_star(c):
        return c[0] > 200 and c[1] > 190
    for y in range(3, 150):
        for x in range(480):
            if (x - 360) ** 2 + (y - 52) ** 2 <= 29 * 29:
                continue
            if is_star(spx[x, y][:3]):
                single = not any(is_star(spx[xx, yy][:3]) for xx, yy in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1))
                                 if 0 <= xx < 480)
                if single and (x * 7 + y * 13) % 5 == 0 and y > 60 and not (x > 296 and y > 94):
                    continue                                   # a few faint ones stay low in the sky
                xx = x
                while xx > 0 and (is_star(px[xx, y][:3]) or px[xx, y][:3] == INK):
                    xx -= 1
                px[x, y] = px[xx, y]

    def hut_span(y):
        """source-picture x range of the hut on row y (None if none)"""
        if 174 <= y <= 230:
            return (325, 467)
        if 98 <= y <= 173:
            xs = [x for x in range(296, 480) if spx[x, y][:3] == INK]
            if not xs:
                return None
            c = spx[479, y][:3]
            return (xs[0], 479 if (c[0] > c[2] or c == INK) else xs[-1])
        return None

    for y in range(96, 150):
        s = hut_span(y)
        if s:
            c = px[s[0] - 1, y]
            for x in range(s[0], 480):
                px[x, y] = c
    # clean leftover warm pixels in the sky right of x=296 (flag tip, glow)
    for y in range(90, 150):
        for x in range(296, 480):
            c = px[x, y][:3]
            if c[0] > c[2] or c == INK:
                px[x, y] = px[x - 1, y]

    SEA = [hx(h) for h in ('#2c3c88', '#2a4c94', '#2a5c9c', '#3e74ac', '#5a8cb8')]
    SANDL = [hx(h) for h in ('#e8d8f0', '#d0c0e4', '#b8a8d8', '#9c8cc2', '#7a6aa8', '#625590', '#4a4078', '#3a3066')]

    def yfoam(x):
        q = x // 3 * 3
        return 199 + int(round(1.6 * math.sin(q / 27.0) + 1.1 * math.sin(q / 11.0 + 2)))

    n1, n2, n3 = mk_noise(11, 13.0, 5.5), mk_noise(12, 5.0, 3.0), mk_noise(13, 40.0, 14.0)
    sidx = {}
    for x in range(480):
        q = x // 4 * 4
        bnd = [b + int(round(2.2 * math.sin(q / 29.0 + k * 2.1) + 1.3 * math.sin(q / 12.0 + k)))
               for k, b in enumerate((158, 168, 179, 190))]
        yf = yfoam(x)
        for y in range(150, 270):
            if y < yf - 1:
                k = sum(1 for b in bnd if y >= b)
                c = SEA[k]
            elif y == yf - 1:
                c = hx('#d0e0f8')
            elif y == yf:
                c = hx('#f4f8ff')
            elif y == yf + 1:
                c = hx('#e8f0ff')
            elif y == yf + 2:
                c = hx('#8ab0d8')
            else:
                v = 0.2 + (y - 203) / 64.0 * 5.4 + (n1(x, y) - .5) * 2.3 + (n2(x, y) - .5) * .8 + (n3(x, y) - .5) * 1.4
                i = max(0, min(5, int(v)))
                if y <= yf + 4:
                    i = max(i, 1)                              # wet strip
                sidx[(x, y)] = i
                c = SANDL[i]
            px[x, y] = c + (255,)
    r = random.Random(5)
    for _ in range(13):                                         # a few still glints
        x, y, L = r.randint(4, 470), r.randint(153, 188), r.randint(3, 6)
        c = col(x, y)
        if c in SEA[:4] and all(col(x + i, y) == c for i in range(-1, L + 1)):
            for i in range(L):
                p.dot(x + i, y, SEA[SEA.index(c) + 1])
    for y in (2, 267):                                          # frame dashes stay
        for x in range(480):
            if spx[x, y][:3] == hx('#f5b82e'):
                px[x, y] = spx[x, y]

    # ================= 2. overcast remap =====================================================================
    cache = {}
    for y in range(270):
        for x in range(480):
            c = px[x, y][:3]
            if c not in cache:
                cache[c] = rm(c)
            px[x, y] = cache[c] + (255,)
    SAND = [rm(c) for c in SANDL]
    SIDX = {c: i for i, c in enumerate(SAND)}

    def sand_i(x, y):
        return SIDX.get(col(x, y))

    def sand_put(x, y, i):
        if 0 <= x < 480 and 200 <= y < 267:
            p.dot(x, y, SAND[max(0, min(7, i))])

    # ================= 3. cloud banks over the moon ==========================================================
    C_RIM, C_UP, C_BODY, C_BELLY = hx('#6c6a88'), hx('#555372'), hx('#45435f'), hx('#323048')

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
                if yy < 4:
                    continue
                if yy >= bot - 1 and edge > 4:
                    c = C_BELLY
                elif yy <= top[xx] + 1 and top.get(xx - 1, cy) >= top[xx]:
                    c = C_RIM
                elif yy <= top[xx] + 3 and xx % 23 < 15:
                    c = C_UP
                else:
                    c = C_BODY
                p.dot(xx, yy, c)
    storm(120, 30, 170, 1, 14)
    storm(330, 22, 120, 2, 10)
    storm(374, 77, 112, 6, 17)       # across the lower half of the moon
    storm(455, 44, 70, 3, 10)
    storm(215, 62, 90, 4, 8)
    storm(40, 66, 80, 5, 8)
    storm(250, 112, 110, 7, 7)
    storm(90, 126, 120, 8, 6)
    storm(440, 100, 90, 9, 7)
    plate = p.snapshot()
    ppx = plate.load()

    # ================= 4. the hut, sunk to the right on its stilts ===========================================
    def dy(x):
        return int(round((x - 325) * 0.075))

    # fix the source hut first: right lantern and the two sparkles go (planks are vertical: copy from above)
    for x in range(452, 468):
        for y in range(185, 206):
            spx[x, y] = spx[x, 183]
    for x in range(370, 416):
        for y in range(189, 200):
            c = spx[x, y][:3]
            if c[0] > 235 and c[1] > 225 and c[2] > 190:
                spx[x, y] = spx[x, 187]
    for x in range(403, 458):                                   # the step is cut off the floor line
        for y in (229, 230):
            spx[x, y] = spx[x, 228] if spx[x, 228][:3] != INK else spx[x, 228]
    G1, G2, G3 = hx('#4c4e68'), hx('#3f4159'), hx('#33334a')

    def glass(c):
        if c[0] > 235 and c[1] > 150 and c[2] < 200:
            return G1 if c[1] > 240 else (G2 if c[1] > 200 else G3)
        return None

    hut = set()
    for y in range(98, 231):
        s = hut_span(y)
        if not s:
            continue
        for x in range(s[0], s[1] + 1):
            c = spx[x, y][:3]
            f = None
            if (346 <= x <= 382 and 184 <= y <= 214) or (412 <= x <= 448 and 184 <= y <= 228):
                f = glass(c)
            if f is None and (x - 330) ** 2 + (y - 195) ** 2 <= 36 and c[0] > 220 and c[1] > 110 \
                    and c not in (hx('#e8a868'), hx('#d58d54'), hx('#d58c54')):
                f = hx('#5d5a6e') if c[1] > 200 else (hx('#4a4759') if c[1] > 150 else hx('#3b3848'))
            yy = y + dy(x)
            if 0 <= yy < 270:
                px[x, yy] = (f or rm(c)) + (255,)
                hut.add((x, yy))
    for x in range(325, 468):                                   # floor line
        p.dot(x, 231 + dy(x), INK)
        hut.add((x, 231 + dy(x)))
    for y in range(174, 231):                                   # body side edges true ink
        for x in (325, 467):
            p.dot(x, y + dy(x), INK)

    def cut(mask):
        gone = [q for q in hut if mask(*q)]
        for q in gone:
            px[q[0], q[1]] = ppx[q[0], q[1]]
            hut.discard(q)
        for (x, y) in gone:
            for q in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if q in hut:
                    p.dot(q[0], q[1], INK)

    def ragged(cx, cy, rx, ry, ph=0.0, amp=1.0):
        def f(x, y):
            u, v = (x - cx) / float(rx), (y - cy) / float(ry)
            a = math.atan2(v, u)
            return u * u + v * v <= 1 + amp * (0.22 * math.sin(3 * a + ph) + 0.14 * math.sin(7 * a + 2 * ph))
        return f

    TH = [rm(h) for h in ('#ffd878', '#f0bc64', '#e0a050', '#a8684a', '#845149', '#603a48')]
    W_LT, W_MID, W_DK, W_SH = hx('#bda18b'), hx('#98786b'), hx('#6f545b'), hx('#453644')
    VD, VD2 = hx('#3a2e3c'), hx('#2a2030')
    M_LT, M_MID, M_DK = hx('#7f9160'), hx('#63754c'), hx('#48583e')

    # torn-away eave corner on the left, bite out of the ridge, tattered flag
    cut(ragged(305, 170, 13, 7, 1.0))
    cut(ragged(331, 150, 6, 4, 2.2))
    cut(ragged(431, 131, 5, 4, 0.4))
    cut(lambda x, y: x >= 402 and y < 119 and (y % 4 == 0 or x >= 404 + (y % 3)))

    # shadow under the raised floor
    for x in range(326, 470):
        top = 232 + dy(x)
        bot = 247 + int(round(1.5 * math.sin(x / 9.0))) - max(0, 334 - x) // 2
        for y in range(top, bot + 1):
            if sand_i(x, y) is not None:
                sand_put(x, y, 7 if y < top + 4 else 6)
    # stilts: left one stands, the middle one snapped, right ones gone under the sand
    def stilt(x, y0, y1, lean=0.0):
        for y in range(y0, y1 + 1):
            xx = x + int(round((y - y0) * lean))
            p.dot(xx, y, W_MID)
            p.dot(xx + 1, y, W_DK)
            p.dot(xx + 2, y, W_SH)
    inked(lambda: stilt(333, 232 + dy(333), 248))
    inked(lambda: stilt(363, 232 + dy(363), 238))
    inked(lambda: stilt(366, 243, 249, -0.5))
    inked(lambda: stilt(392, 232 + dy(392), 247, 0.25))
    for x in (363, 364, 365):
        p.dot(x, 239 if x != 364 else 240, W_LT)                # splintered break

    # ---- roof: big tear, sagging thatch ------------------------------------------------------------------
    def roof_hole(cx, cy, rx, ry, ph, beams=()):
        f = ragged(cx, cy, rx, ry, ph)
        g = ragged(cx + 1, cy + 1, rx - 2, ry - 2, ph)

        def draw():
            for y in range(cy - ry - 4, cy + ry + 5):
                for x in range(cx - rx - 5, cx + rx + 6):
                    if f(x, y) and (x, y) in hut:
                        if not g(x, y):
                            # cut edge of the thatch: lit on the lower right lip, shadowed on the upper left
                            p.dot(x, y, TH[1] if (x - cx) * ry + (y - cy) * rx > 0 else TH[5])
                        else:
                            p.dot(x, y, VD2 if (x - cx) + 2 * (y - cy) < 0 else VD)
            for (x0, y0, x1, y1) in beams:
                n = max(abs(x1 - x0), abs(y1 - y0))
                for i in range(n + 1):
                    x, y = x0 + (x1 - x0) * i // n, y0 + (y1 - y0) * i // n
                    if g(x, y):
                        p.dot(x, y, W_DK)
                        if g(x, y - 1):
                            p.dot(x, y - 1, W_MID)
        inked(draw)
    roof_hole(416, 151, 17, 10, 0.7, beams=((398, 158, 434, 142), (406, 141, 430, 160)))
    roof_hole(356, 158, 8, 5, 2.0, beams=((348, 160, 364, 155),))
    # dark damp patches and slipped bundles (directional, clustered)
    r = random.Random(21)
    for _ in range(46):
        x, y = r.randint(310, 474), r.randint(118, 178)
        L = r.randint(3, 8)
        for i in range(L):
            for j in (0, 1):
                q = (x + i, y + j)
                if q in hut and col(*q) in TH[:3] and (j == 0 or i % 3):
                    p.dot(q[0], q[1], TH[TH.index(col(*q)) + 2])
    # strands hanging below the eave
    for x in range(312, 478, 1):
        if (x * 37) % 11 < 3:
            L = 2 + (x * 13) % 6
            y0 = 174 + dy(x)
            for i in range(L):
                if col(x, y0 + i) != INK or i == 0:
                    p.dot(x, y0 + i, TH[3] if i < L - 1 else TH[2])

    # ---- windows: broken panes, a board, the door hangs open ----------------------------------------------
    def shard_hole(pts, glints):
        p.poly(pts, VD2)
        for (x, y) in glints:
            p.dot(x, y, hx('#7c7e96'))
    d1 = dy(365)
    shard_hole([(366, 187 + d1), (372, 185 + d1), (375, 190 + d1), (381, 191 + d1), (377, 196 + d1), (379, 201 + d1),
                (372, 198 + d1), (367, 200 + d1), (369, 194 + d1)], [(367, 201 + d1), (380, 192 + d1), (371, 186 + d1)])
    shard_hole([(348, 204 + d1), (353, 201 + d1), (357, 206 + d1), (362, 205 + d1), (360, 212 + d1), (350, 212 + d1)],
               [(354, 201 + d1), (363, 205 + d1)])

    def board():
        for i in range(0, 44):
            x = 342 + i
            y = 188 + dy(x) + i * 2 // 5
            p.dot(x, y, W_LT)
            p.dot(x, y + 1, W_MID)
            p.dot(x, y + 2, W_MID if i % 9 else W_DK)
            p.dot(x, y + 3, W_DK)
    inked(board)
    for (x, y) in ((345, 191), (382, 207)):
        p.dot(x, y + dy(x), VD2)                                # nails
    d2 = dy(430)
    p.poly([(413, 196 + d2), (429, 190 + d2), (429, 228 + d2), (413, 228 + d2)], VD2)   # left door leaf gone: dark inside
    p.poly([(414, 214 + d2), (428, 208 + d2), (428, 228 + d2), (414, 228 + d2)], VD)
    shard_hole([(434, 199 + d2), (440, 196 + d2), (446, 201 + d2), (443, 207 + d2), (446, 212 + d2), (437, 210 + d2),
                (433, 205 + d2)], [(441, 196 + d2), (447, 212 + d2)])

    def leaf():                                                 # the fallen door leaf leans in the doorway
        for i in range(0, 30):
            y = 199 + d2 + i
            x = 409 + i // 5
            for k in range(7):
                p.dot(x + k, y, W_LT if k == 0 else (W_MID if k < 4 else W_DK))
            if i % 10 == 9:
                for k in range(7):
                    p.dot(x + k, y, W_SH)
    inked(leaf)
    p.web(327, 176 + dy(327), 9, hx('#9896aa'))
    p.web(450, 176 + dy(450), 8, hx('#9896aa'))

    # moss on roof and wall foot, vines
    def mossclump(cx, cy, rx, ry, only=None):
        f = ragged(cx, cy, rx, ry, cx * .7, 1.2)
        for y in range(cy - ry - 2, cy + ry + 3):
            for x in range(cx - rx - 2, cx + rx + 3):
                if f(x, y) and col(x, y) != INK and (only is None or only(x, y)):
                    u, v = (x - cx) / float(rx), (y - cy) / float(ry)
                    p.dot(x, y, M_LT if u + v < -.6 else (M_DK if u + v > .5 else M_MID))
    on_hut = lambda x, y: (x, y) in hut
    for (cx, cy, rx, ry) in ((346, 139, 7, 2), (384, 124, 9, 3), (372, 150, 6, 2), (447, 158, 8, 2), (328, 166, 7, 2),
                             (400, 171, 9, 2), (462, 175, 7, 2), (336, 229, 6, 2), (398, 234, 9, 2), (455, 238, 6, 2)):
        mossclump(cx, cy, rx, ry, on_hut)
    p.rng = random.Random(3)
    for (x, y, L) in ((329, 178, 22), (387, 181, 16), (404, 183, 30), (458, 186, 24), (341, 179, 9)):
        p.vine(x, y + dy(x), L, (M_DK, M_MID))

    # ================= 5. the beach ==========================================================================
    def shadow(x0, x1, y, rows=2, skew=1):
        for j in range(rows):
            for x in range(x0 + j * skew, x1 + 1 + j * skew):
                i = sand_i(x, y + j)
                if i is not None and i < 7:
                    sand_put(x, y + j, min(7, i + 2))

    def base_i(x, y):
        return sidx.get((x, y), 4)

    def drift(cx, by, w, h, over=False):
        b = base_i(cx, by)
        for x in range(cx - w // 2, cx + w // 2 + 1):
            t = (x - cx) / (w / 2.0)
            top = by - int(round(h * math.sqrt(max(0, 1 - t * t))))
            for y in range(top, by + 1):
                if sand_i(x, y) is None and not over:
                    continue
                i = b - 2 if (y == top and t < .35) else (b - 1 if (y - top) <= 1 + (1 - t) * h * .5 else b)
                sand_put(x, y, max(0, i))
        shadow(cx - w // 4, cx + w // 2 + 2, by + 1, 1)

    def pit(cx, cy, rx, ry, ph):
        b = base_i(cx, cy)
        f = ragged(cx, cy, rx, ry, ph, .7)
        o = ragged(cx, cy, rx + 3, ry + 2, ph, .7)
        for y in range(cy - ry - 4, cy + ry + 5):
            for x in range(cx - rx - 6, cx + rx + 7):
                if sand_i(x, y) is None:
                    continue
                u, v = (x - cx) / float(rx), (y - cy) / float(ry)
                if f(x, y):
                    if v < -.2:
                        i = 7 if u < .35 else 6
                    elif v < .4:
                        i = 6 if u < -.25 else 5
                    else:
                        i = 5 if u < .45 else 4
                    sand_put(x, y, i)
                elif o(x, y):
                    if v > .15 or u > .55:
                        sand_put(x, y, max(0, b - 1 if u + v < 1.5 else b - 2))      # lit lip of thrown-up sand
                    elif u < -.5 and v < 0:
                        sand_put(x, y, max(0, b - 1))

    # wind ripples (short crests, clustered)
    r = random.Random(31)
    for _ in range(26):
        gx, gy = r.randint(6, 470), r.randint(210, 262)
        for k in range(r.randint(2, 4)):
            x0, y0, L = gx + r.randint(-8, 8), gy + k * 2, r.randint(4, 10)
            for i in range(L):
                x, y = x0 + i, y0 + (1 if i > L * .6 else 0)
                si = sand_i(x, y)
                if si is not None and 0 < si < 6 and (x, y) in sidx:
                    sand_put(x, y, si - 1)

    # the empty nests
    pit(40, 243, 27, 8, 0.3)
    pit(150, 241, 17, 6, 1.7)
    pit(222, 250, 18, 6, 2.6)
    pit(108, 258, 11, 4, 0.9)
    pit(318, 259, 11, 3, 3.3)
    pit(250, 230, 9, 3, 4.0)
    drift(74, 240, 18, 4)
    drift(8, 238, 14, 3)
    drift(446, 244, 60, 6)       # blown up against the sunken corner of the hut
    drift(470, 252, 30, 4)

    # tide-line weed
    K1, K2, K3 = hx('#3c4a3c'), hx('#52603f'), hx('#5c4a48')

    def weed(cx, cy, rx, ry, seed):
        r = random.Random(seed)
        f = ragged(cx, cy, rx, ry, seed * 1.3, 1.4)
        for y in range(cy - ry - 2, cy + ry + 3):
            for x in range(cx - rx - 3, cx + rx + 4):
                if f(x, y) and col(x, y) != INK and y > yfoam(max(0, min(479, x))) + 1:
                    u, v = (x - cx) / float(rx), (y - cy) / float(max(ry, 1))
                    p.dot(x, y, K2 if (v < -.3 and (x // 3) % 2 == 0) else (K3 if (u > .4 and v > 0) else K1))
        for _ in range(3 + rx // 3):                            # loose strands trailing off the clump
            x, y = cx + r.randint(-rx, rx), cy + r.randint(-ry, ry)
            d = r.choice((-1, 1))
            c = r.choice((K1, K1, K3))
            for i in range(r.randint(5, 10)):
                if col(x, y) != INK and y > yfoam(max(0, min(479, x))) + 1:
                    p.dot(x, y, c)
                x += d
                if i % 3 == 2:
                    y += r.choice((-1, 0, 1, 1))
        shadow(cx - rx + 2, cx + rx + 1, cy + ry + 1, 1)
    for i, (cx, rx, ry) in enumerate(((20, 9, 2), (62, 5, 1), (101, 10, 2), (146, 6, 1), (190, 9, 2), (238, 6, 1),
                                      (283, 11, 2), (312, 4, 1))):
        weed(cx, yfoam(cx) + 6 + (i % 2), rx, ry, 40 + i)
    weed(128, 233, 7, 2, 60)
    weed(292, 262, 8, 1, 61)
    weed(206, 263, 5, 1, 62)
    weed(30, 259, 8, 2, 63)

    # ---- guide fence: posts and a slack rope, half knocked down ---------------------------------------------
    ROPE, ROPE_D = hx('#b7a58c'), hx('#8a7a6e')

    def post(x, yb, h, lean=0.0):
        def draw():
            for i in range(h):
                xx = x + int(round(i * lean))
                y = yb - i
                p.dot(xx, y, W_LT)
                p.dot(xx + 1, y, W_MID)
                p.dot(xx + 2, y, W_MID if (i + x) % 7 else W_DK)
                p.dot(xx + 3, y, W_DK)
            xx = x + int(round((h - 1) * lean))
            for k in range(3):
                p.dot(xx + k, yb - h + 1, hx('#cdb39c'))
            for k in range(4):                                  # rope band round the top
                p.dot(xx + k - (1 if lean > .2 else 0), yb - h + 4, ROPE_D)
        shadow(x + 3, x + 10, yb, 2)
        inked(draw)
        return (x + int(round((h - 4) * lean)) + 2, yb - h + 4)

    def flat_post(x, y, L, up=0):
        def draw():
            for i in range(L):
                yy = y - (i * up) // L
                p.dot(x + i, yy, W_LT)
                p.dot(x + i, yy + 1, W_MID)
                p.dot(x + i, yy + 2, W_MID if i % 6 else W_DK)
                p.dot(x + i, yy + 3, W_DK)
            for k in range(1, 3):
                p.dot(x, y + k, hx('#cdb39c'))
        shadow(x + 1, x + L + 2, y + 4, 1)
        inked(draw)

    def rope(a, b, sag):
        n = max(1, b[0] - a[0])
        for i in range(n + 1):
            t = i / float(n)
            x = a[0] + i
            y = int(round(a[1] + (b[1] - a[1]) * t + sag * 4 * t * (1 - t)))
            if col(x, y) != INK and col(x, y) not in (W_LT, W_MID, W_DK):
                p.dot(x, y, ROPE if i % 5 else ROPE_D)

    t1 = post(86, 224, 14)
    t2 = post(110, 225, 14, 0.1)
    t3 = post(134, 224, 13, -0.15)
    flat_post(150, 221, 15, 1)
    t5 = post(180, 225, 12, 0.5)
    t6 = post(206, 224, 14)
    flat_post(222, 222, 14, -1)
    t8 = post(270, 223, 13, -0.3)
    t9 = post(294, 224, 14, 0.05)
    rope(t1, t2, 3)
    rope(t2, t3, 4)
    rope(t3, (150, 222), 3)                                     # drops to the fallen post
    rope(t5, t6, 3)
    rope(t6, (223, 223), 2)
    rope((237, 227), (254, 226), 1)                             # loose end on the sand
    rope(t8, t9, 4)
    drift(92, 226, 18, 3, over=True)
    drift(212, 226, 18, 3, over=True)
    drift(276, 225, 14, 2, over=True)

    # ---- nest markers: stake + little egg plaque, knocked about ----------------------------------------------
    E_W, E_L, E_S, E_D = hx('#e4ded6'), hx('#c9c0c4'), hx('#a296a8'), hx('#5a4c5e')
    PL = {'L': W_LT, 'M': W_MID, 'D': W_DK, 'e': E_W, 's': W_SH}
    PLAQUE = ["LLLLLLLLL",
              "LMMMeMMMD",
              "LMMeeeMMD",
              "LMMeeeMMD",
              "LMMMeMMMD",
              "MDDDDDDDD"]

    def marker(x, yb, lean=0.0, h=11):
        def draw():
            for i in range(h):
                xx = x + int(round(i * lean))
                p.dot(xx, yb - i, W_MID)
                p.dot(xx + 1, yb - i, W_DK)
            tx = x + int(round(h * lean))
            stamp(tx - 4, yb - h - 5, PLAQUE, PL)
        shadow(x + 1, x + 6, yb, 2)
        inked(draw)
    marker(178, 247, 0.35, 12)                                      # leaning by the second nest
    # snapped stake by the main nest, plaque face down in the sand beside it

    def stub():
        for i in range(4):
            p.dot(72, 250 - i, W_MID)
            p.dot(73, 250 - i, W_DK)
        p.dot(72, 246, W_LT)
    shadow(73, 78, 250, 2)
    inked(stub)

    def fallen_marker(x, y):
        def draw():
            for i in range(10):
                p.dot(x + i, y + (i // 5), W_MID)
                p.dot(x + i, y + 1 + (i // 5), W_DK)
            stamp(x + 10, y - 2, ["LLLLLLL", "LMMeMMD", "LMeeeMD", "LMMeMMD", "MDDDDDD"], PL)
        shadow(x + 1, x + 17, y + 3, 1)
        inked(draw)
    fallen_marker(78, 254)
    fallen_marker(240, 258)
    marker(304, 252, -0.25, 10)

    # ---- broken eggshells --------------------------------------------------------------------------------------
    EP = {'W': E_W, 'w': E_L, 's': E_S, 'd': E_D}
    CUP = ["..dd.dd..",
           ".WdWdWdw.",
           "WWWWWWwws",
           "WWWWWwwss",
           "WWWWwwwss",
           ".WWwwwss.",
           "..wwsss.."]
    TIP = ["..WWWw....",
           ".WWWWWdd..",
           "WWWWWdddw.",
           "WWWWwdddds",
           "WWWwwddds.",
           ".wwwsss...",
           "..sss....."]
    CAP = ["..WWw..",
           ".WWWws.",
           "WWWWwss",
           "W.Ww.ws"]
    BIT = ["W.W",
           "Wws"]
    BIT2 = ["Ww",
            ".s"]

    def shells(items):
        def draw():
            for (kind, x, y) in items:
                stamp(x, y, kind, EP)
        for (kind, x, y) in items:
            shadow(x + 2, x + len(kind[0]) + 1, y + len(kind), 1)
        inked(draw)
    shells([(CUP, 24, 238), (TIP, 38, 241), (CUP, 53, 237), (CAP, 33, 247), (BIT2, 19, 246), (BIT, 62, 247),
            (BIT, 48, 248), (BIT2, 45, 239)])
    shells([(TIP, 140, 238), (CUP, 154, 237), (BIT2, 150, 246), (BIT, 166, 249), (CAP, 126, 246)])
    shells([(CUP, 212, 246), (BIT, 225, 253), (TIP, 229, 248), (BIT2, 206, 255)])
    shells([(BIT, 101, 258), (CAP, 108, 256), (BIT2, 122, 262)])
    shells([(BIT, 314, 258), (BIT2, 324, 260), (BIT2, 248, 230), (BIT, 190, 234), (BIT2, 96, 242), (CAP, 197, 240)])

    # ---- cold fire ring -----------------------------------------------------------------------------------
    ST = (hx('#a29eac'), hx('#807c8e'), hx('#5c586c'))
    ASH1, ASH2 = hx('#8d8992'), hx('#6a6672')

    def stone(cx, cy, rx, ry):
        def draw():
            for y in range(cy - ry, cy + ry + 1):
                for x in range(cx - rx, cx + rx + 1):
                    u, v = (x - cx) / (rx + .3), (y - cy) / (ry + .3)
                    if u * u + v * v <= 1:
                        p.dot(x, y, ST[0] if u + v < -.5 else (ST[2] if u + v > .45 else ST[1]))
        inked(draw)
    fx, fy = 276, 244
    shadow(fx - 12, fx + 17, fy + 6, 2)
    for y in range(fy - 4, fy + 5):
        for x in range(fx - 12, fx + 13):
            u, v = (x - fx) / 12.0, (y - fy) / 4.5
            if u * u + v * v <= 1:
                p.dot(x, y, ASH1 if (u * .6 - v) > .2 else ASH2)

    def char_logs():
        for i in range(13):
            p.dot(fx - 7 + i, fy + 1 - i // 4, VD2)
            p.dot(fx - 7 + i, fy + 2 - i // 4, VD)
        for i in range(10):
            p.dot(fx - 3 + i, fy - 3 + i // 3, VD2)
            p.dot(fx - 3 + i, fy - 2 + i // 3, VD)
        p.dot(fx - 6, fy + 1, W_SH)
        p.dot(fx + 2, fy - 2, W_SH)
    inked(char_logs)
    for (cx, cy, rx, ry) in ((fx - 13, fy - 1, 2, 2), (fx - 8, fy - 5, 3, 1), (fx, fy - 6, 3, 1), (fx + 8, fy - 5, 3, 1),
                             (fx + 14, fy, 2, 2), (fx + 9, fy + 5, 3, 1), (fx, fy + 6, 3, 1), (fx - 9, fy + 5, 3, 1),
                             (fx + 23, fy + 8, 2, 1)):
        stone(cx, cy, rx, ry)

    # ---- driftwood --------------------------------------------------------------------------------------------
    def log(x0, y0, L, rad, rise=0):
        def draw():
            for i in range(L):
                yc = y0 - (i * rise) // L
                for j in range(-rad, rad + 1):
                    end = (i < 2 or i > L - 3) and abs(j) == rad
                    if end:
                        continue
                    c = W_LT if j == -rad else (W_MID if j < rad - 1 else W_DK)
                    if j == 0 and i % 11 in (3, 4, 5, 6):
                        c = W_DK
                    p.dot(x0 + i, yc + j, c)
            # sawn end, upper-left lit
            for j in range(-rad + 1, rad):
                p.dot(x0, y0 + j, hx('#cdb39c'))
                p.dot(x0 + 1, y0 + j, hx('#cdb39c') if j < 0 else W_LT)
            p.dot(x0 + 1, y0, W_DK)
        shadow(x0 + 2, x0 + L + 2, y0 + rad + 1, 2)
        inked(draw)

    def stick(pts, c0=W_MID, c1=W_DK):
        def draw():
            for a, b in zip(pts, pts[1:]):
                n = max(abs(b[0] - a[0]), abs(b[1] - a[1]), 1)
                for i in range(n + 1):
                    x, y = a[0] + (b[0] - a[0]) * i // n, a[1] + (b[1] - a[1]) * i // n
                    p.dot(x, y, c0)
                    p.dot(x, y + 1, c1)
        inked(draw)
    log(156, 259, 44, 3, 2)
    stick([(186, 254), (192, 249), (197, 248)])                # branch stub on the log
    shadow(8, 44, 214, 1)
    stick([(8, 212), (22, 210), (34, 212), (44, 209)])
    stick([(26, 210), (30, 206)])
    shadow(336, 366, 261, 1)
    stick([(334, 259), (350, 257), (366, 260)])
    stick([(352, 257), (357, 253)])

    # ---- the hut's step, fallen and half buried; the lantern that dropped off the wall ------------------------
    def step():
        for i in range(34):
            x = 384 + i
            y = 252 + i // 8
            p.dot(x, y, W_LT)
            p.dot(x, y + 1, W_MID)
            p.dot(x, y + 2, W_MID if i % 12 else W_SH)
            p.dot(x, y + 3, W_DK)
            p.dot(x, y + 4, W_DK)
    shadow(386, 421, 258, 2)
    inked(step)
    drift(414, 261, 24, 6, over=True)

    LP = {'k': hx('#4a4554'), 'm': hx('#6a6474'), 'g': hx('#7a7c92'), 'h': hx('#a3a5b8'), 'd': hx('#5a5c72'),
          'x': VD2}
    LANT = ["..kkkkkk....",
            ".kmmmmmmk.k.",
            "kmghgxdmkkmk",
            "kmggxddmk..k",
            "kmgxxddmkkmk",
            ".kmmmmmmk.k.",
            "..kkkkkk...."]
    shadow(452, 465, 263, 1)
    inked(lambda: stamp(450, 255, LANT, LP))
    # the bent hook left on the wall where it hung
    hx_, hy_ = 465, 190 + dy(465)
    for (x, y) in ((hx_, hy_), (hx_ - 1, hy_), (hx_ - 2, hy_ + 1), (hx_ - 2, hy_ + 2)):
        p.dot(x, y, VD2)

    # ---- small things on the tide line and a lone crab -------------------------------------------------------
    def bottle(x, y):
        stamp(x, y, ["gggggh.",
                     "gGGGGgn",
                     "ggggg.."], {'g': hx('#5f7d78'), 'G': hx('#86a39a'), 'h': hx('#86a39a'), 'n': hx('#8a7a6e')})
    shadow(65, 72, 213, 1)
    inked(lambda: bottle(63, 210))
    shadow(247, 257, 212, 1)
    inked(lambda: [p.dot(246 + i, 209 + (i // 6), W_LT) or p.dot(246 + i, 210 + (i // 6), W_DK) for i in range(11)])
    CR = {'r': hx('#a8605a'), 'R': hx('#c98478'), 'k': INK}
    shadow(340, 347, 249, 1)
    inked(lambda: stamp(338, 245, ["r.....r",
                                  ".RRRRR.",
                                  ".rRkRkr",
                                  "r.r.r.r"], CR))
    # beach grass tufts taking over
    GR = (M_DK, M_MID, M_LT)

    def tuft(x, y, seed):
        r = random.Random(seed)
        for k in range(-3, 4):
            L = r.randint(3, 6) - abs(k) // 2
            for i in range(L):
                xx = x + k + (i * (1 if k > 0 else -1 if k < 0 else 0)) // 3
                p.dot(xx, y - i, GR[0] if i < 2 else (GR[1] if i < L - 1 else GR[2]))
    for i, (x, y) in enumerate(((120, 226), (300, 236), (474, 240), (6, 228), (243, 238), (378, 249), (200, 236))):
        tuft(x, y, 70 + i)
