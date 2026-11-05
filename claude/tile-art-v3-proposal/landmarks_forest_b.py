import random, math
import gen2
from gen2 import RAMP, INK, CREAM, Cv, lump, r5, outline, trunk, leaf_texture, darker, mix, H, T, _col, _pond, _reeds

WD = RAMP["wood"]; LT = RAMP["litter"]
def line(cv, x0, y0, x1, y1, cols, w=2):
    n = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
    for i in range(n + 1):
        x = x0 + (x1 - x0) * i / max(1, n); y = y0 + (y1 - y0) * i / max(1, n)
        for k in range(w):
            cv.put(int(x), int(y) + k, cols[min(k, len(cols) - 1)])
def ell(cv, cx, cy, rx, ry, fn):
    for y in range(int(cy - ry), int(cy + ry) + 1):
        for x in range(int(cx - rx), int(cx + rx) + 1):
            nx = (x - cx) / rx; ny = (y - cy) / ry
            if nx * nx + ny * ny <= 1:
                c = fn(x, y, nx, ny)
                if c: cv.put(x, y, c)
def toadstool(cv, x, y, s, rnd, cap="ember", stem=None):
    R = r5(RAMP[cap]); S = r5(RAMP["sand"])
    sh = int(8 * s)
    for yy in range(y - sh, y):
        for xx in range(x - int(3 * s), x + int(3 * s)):
            u = (xx - (x - int(3 * s))) / (6 * s); cv.put(xx, yy, CREAM if u < .4 else S[1] if u < .75 else S[2])
    lump(cv, x, y - sh - int(3 * s), int(11 * s), int(8 * s), R, rnd, 0)
    for dx, dy in ((-5, -2), (3, -4), (6, 0), (-1, 1), (-8, 1)):
        px, py = x + int(dx * s), y - sh - int(3 * s) + int(dy * s)
        if cv.get(px, py)[3]: cv.put(px, py, CREAM); cv.put(px + 1, py, CREAM); cv.put(px, py + 1, CREAM)
def grass_tufts(cv, x0, x1, y, rnd, n):
    for _ in range(n):
        x = rnd.randint(x0, x1)
        for k in range(rnd.randint(3, 6)): cv.put(x + (k // 3), y - k, RAMP["moss"][1 if k % 2 else 0])

GLYPH = {"0": "111101101101111", "1": "010110010010111", "2": "111001111100111", "3": "111001111001111", "4": "101101111001001",
         "5": "111100111001111", "6": "111100111101111", "7": "111001001010010", "8": "111101111101111", "9": "111101111001111", "?": "111001010000010"}
def glyphs(cv, x, y, txt, col, sc=1):
    for i, ch in enumerate(txt):
        for k, b in enumerate(GLYPH[ch]):
            if b == "1":
                for a in range(sc):
                    for c in range(sc): cv.put(x + (i * 4 + k % 3) * sc + a, y + (k // 3) * sc + c, col)
def flag(cv, x, y, txt, rnd, h=34, tone="ember"):
    for k in range(h): cv.put(x, y - k, WD[2]); cv.put(x + 1, y - k, WD[3])
    w = 8 * len(txt) + 5; E = RAMP[tone]
    for xx in range(x + 2, x + 2 + w):
        for yy in range(y - h, y - h + 19): cv.put(xx, yy + (xx - x) // 12, CREAM if yy > y - h else RAMP["sand"][0])
        for yy in range(y - h + 17, y - h + 19): cv.put(xx, yy + (xx - x) // 12, RAMP["sand"][1])
    glyphs(cv, x + 4, y - h + 3, txt, E[2], 2)
def fern(cv, x, y, rnd, s=1.0):
    G = r5(RAMP["pine"])
    for ang in (-62, -38, -14, 12, 38, 64):
        a = math.radians(ang + rnd.randint(-5, 5)); L = int((20 + rnd.randint(0, 8)) * s)
        for k in range(L):
            px = x + math.sin(a) * k; py = y - math.cos(a) * k + k * k * .02 * (1 if abs(ang) > 30 else .5)
            t = 3 if k < L * .3 else 2 if k < L * .62 else 1 if k < L * .9 else 0
            cv.put(int(px), int(py), G[t])
            if k % 3 == 1 and k > 3:
                for sd in (-1, 1): cv.put(int(px) + sd * 2, int(py) + 1, G[min(4, t + 1)]); cv.put(int(px) + sd * 3, int(py) + 2, G[t])

def lm_ringlog(rnd, cv):   # 340 x 200
    W = r5(WD); M = r5(RAMP["moss"]); SD = r5(RAMP["sand"]); S = r5(RAMP["stone"])
    cx, cy, rx, ry = 84, 128, 58, 66
    top = lambda x: cy - ry + 4 + (x // 40) % 2
    bot = cy + ry
    for x in range(cx, 328):   # the long trunk behind the cut face
        y0 = top(x); y1 = bot - (3 if x > 310 else 0)
        for y in range(y0, y1):
            u = (y - y0) / (y1 - y0); t = 0 if u < .1 else 1 if u < .28 else 2 if u < .55 else 3 if u < .82 else 4
            if (x * 5 + y * 3) % 17 == 0: t = min(4, t + 1)
            if (x // 7 + y // 14) % 6 == 0 and y % 5 == 0: t = min(4, t + 1)
            cv.put(x, y, W[t])
    for x in range(cx + 20, 326, 12):   # bark furrows
        for y in range(top(x) + 6, bot - 4):
            if (y + x) % 4: cv.put(x, y, W[4])
    for x in range(cx + 10, 324):   # moss on top
        for y in range(top(x) - 3, top(x) + 4 + (x * 3) % 8):
            if (x // 7) % 3 != 0: cv.put(x, y, M[1 + (x + y) % 3 // 2 * 2])
    lump(cv, 300, top(300) + 3, 22, 9, M, rnd, .1); lump(cv, 215, top(215) + 2, 24, 8, M, rnd, .1)
    for y in range(cy - ry, cy + ry + 1):   # the huge cut face with annual rings
        for x in range(cx - rx, cx + rx + 1):
            nx = (x - cx) / rx; ny = (y - cy) / ry; d = math.hypot(nx, ny)
            if d > 1: continue
            if d > .94: c = W[3]
            elif d > .88: c = W[1]
            else:
                k = int(d * 26 + math.sin(math.atan2(ny, nx) * 2) * .6)
                c = SD[1] if k % 4 == 0 else SD[2] if k % 4 == 2 else SD[0] if nx + ny < 0 else SD[1]
                if d < .06: c = W[3]
            cv.put(x, y, c)
    for ang, d in ((2.6, .45), (.7, .6), (4.2, .78)):   # radial cracks
        for k in range(int(d * 40)):
            cv.put(int(cx + math.cos(ang) * (k + 4) * rx / 40), int(cy + math.sin(ang) * (k + 4) * ry / 40), W[4])
    # gnome-sized number flags planted in rings, counting up then lost
    flag(cv, 84, 100, "1", rnd, 40); flag(cv, 62, 142, "9", rnd, 52, "dusk"); flag(cv, 108, 160, "27", rnd, 58)
    flag(cv, 160, top(160) + 4, "??", rnd, 44, "dusk"); flag(cv, 262, top(262) + 4, "412", rnd, 42)
    for i in range(6): lump(cv, 190 + i * 11, 38 + (i % 2), 5, 4, S, rnd, 0)   # tally pebbles on top
    for x, y, s in ((236, 62, 1.0), (252, 66, .7), (150, 68, .8)):
        toadstool(cv, x, y, s, rnd)
    fern(cv, 290, 196, rnd, 1.0); fern(cv, 150, 198, rnd, .8)
    for x in range(10, 330, 3): cv.put(x, 197 + (x * 7) % 2, WD[3]) if x % 2 else None
    grass_tufts(cv, 6, 334, 199, rnd, 16)

def lm_woodpecker(rnd, cv):   # 170 x 270
    bark = [H(c) for c in ("#d9cfc0", "#b4a595", "#8a7a70", "#5a4a4f")]
    for y in range(40, 266):
        w = 38 + (y - 40) // 30 + (7 if y > 240 else 0); cx = 85
        for x in range(cx - w // 2, cx + w // 2):
            u = (x - (cx - w // 2)) / w; t = 0 if u < .15 else 1 if u < .4 else 2 if u < .75 else 3
            if (x * 3 + y // 4 * 5) % 13 == 0: t = min(3, t + 1)
            cv.put(x, y, bark[t])
    for y in range(40, 60):   # snapped top
        for x in range(66 + (y % 5), 105 - (y * 3 % 6)): cv.put(x, y, INK) if False else None
    for x0, y0, x1, y1 in ((100, 100, 158, 62), (70, 140, 22, 108), (104, 176, 148, 150)):   # bare branches
        line(cv, x0, y0, x1, y1, [bark[1], bark[2], bark[3]], 5)
        line(cv, x1, y1, x1 + (8 if x1 > 85 else -8), y1 - 18, [bark[1], bark[3]], 3)
    for hy in (118, 128, 138, 148):   # pecked holes
        for dx in range(5):
            for dy in range(5): cv.put(78 + dx + (hy % 3), hy + dy, INK if 0 < dx < 4 and 0 < dy < 4 else bark[3])
    for x in range(60, 112):   # moss
        for y in range(238, 244 + (x * 5) % 9): cv.put(x, y, RAMP["moss"][2 if (x + y) % 3 else 1])
    # woodpecker
    B = r5(RAMP["petal"])
    lump(cv, 112, 108, 11, 15, [H("#4a4a62")] * 2 + [H("#34344d")] * 3, rnd, 0)
    lump(cv, 111, 112, 6, 9, [CREAM] * 3 + [H("#e8dcc0")] * 2, rnd, 0)
    lump(cv, 112, 90, 9, 9, r5(RAMP["stone"][::-1]) if False else [H("#4a4a62")] * 3 + [H("#34344d")] * 2, rnd, 0)
    for x in range(104, 118): cv.put(x, 82 + (x % 2), RAMP["ember"][1]); cv.put(x, 83, RAMP["ember"][1])
    cv.put(108, 90, CREAM); cv.put(109, 90, INK)
    for k in range(10): cv.put(103 - k, 92 + k // 4, RAMP["gold"][2]); cv.put(103 - k, 93 + k // 4, RAMP["gold"][3])
    for k in range(8): cv.put(116 + k, 120 + k, H("#34344d")); cv.put(117 + k, 120 + k, H("#34344d"))
    for nx, ny in ((130, 90), (140, 76), (150, 96)):   # slow song notes
        for dx in range(3):
            for dy in range(3): cv.put(nx + dx, ny + dy, RAMP["gold"][1])
        for k in range(10): cv.put(nx + 3, ny - k + 2, RAMP["gold"][1])
        cv.put(nx + 4, ny - 8, RAMP["gold"][1])
    for _ in range(14): cv.put(rnd.randint(64, 108), 264 + rnd.randint(-1, 0), bark[2])

def tstool(cv, x, y, h, cr, rnd, cap="ember", spots=5):
    """tall glossy toadstool: stem foot at (x, y), total stem height h, cap radius cr"""
    R = r5(RAMP[cap]); S = r5(RAMP["sand"]); sw = max(3, int(cr * .36))
    for yy in range(y - h, y):
        w = sw + (yy - (y - h)) * 2 // max(1, h) + (2 if yy > y - 3 else 0)
        for xx in range(x - w, x + w + 1):
            u = (xx - (x - w)) / max(1, 2 * w); cv.put(xx, yy, S[0] if u < .22 else S[1] if u < .5 else S[2] if u < .78 else S[3])
    for xx in range(x - sw - 3, x + sw + 4): cv.put(xx, y - h + sw // 2 + 4, S[3]); cv.put(xx, y - h + sw // 2 + 5, S[1])   # skirt ring
    cy = y - h - int(cr * .1)
    lump(cv, x, cy, cr, cr * .66, R, rnd, 0)
    for xx in range(x - cr + 2, x + cr - 1):   # shaded gill rim below the cap
        yy = cy + int(cr * .66 * math.sqrt(max(0, 1 - ((xx - x) / cr) ** 2)))
        cv.put(xx, yy, S[3]); cv.put(xx, yy - 1, S[1])
    for k in range(spots):
        a = k / spots * 6.2832 + rnd.random(); rr = rnd.uniform(.25, .7)
        px = x + int(math.cos(a) * rr * cr); py = cy - int(abs(math.sin(a)) * rr * cr * .5) + 1
        s2 = max(1, int(cr / 9)); _blob = [(dx, dy) for dx in range(s2 + 1) for dy in range(s2)]
        for dx, dy in _blob: cv.put(px + dx, py + dy, CREAM)
    for k in range(int(cr * .5)): cv.put(x - int(cr * .5) + k // 2 + 1, cy - int(cr * .4) + k // 3 + 1 - (1 if k else 0), CREAM)   # gloss streak
    cv.put(x - int(cr * .55), cy - int(cr * .25), CREAM); cv.put(x - int(cr * .55) + 1, cy - int(cr * .25), CREAM)

def lm_toadring(rnd, cv):   # 320 x 190
    cx, cy, rx, ry = 160, 142, 134, 30
    M = r5(RAMP["moss"]); SD = r5(RAMP["sand"]); G = RAMP["gold"]; W = r5(WD)
    ell(cv, cx, cy + 2, rx - 6, ry - 2, lambda x, y, nx, ny: M[1 if (x * 7 + y * 3) % 11 else 0] if nx * nx + ny * ny < .86 else M[2])
    ell(cv, cx, cy + 4, rx - 24, ry - 12, lambda x, y, nx, ny: M[0 if (x * 5 + y * 3) % 7 else 1])   # lighter inner lawn
    items = []
    for i in range(15):
        a = i / 15 * 6.2832 + .15
        if abs(math.sin(a + 1.5708)) > .995 and math.sin(a) < 0: continue
        items.append((cy + int(math.sin(a) * ry), cx + int(math.cos(a) * rx), (30, 54, 40, 68, 46, 36, 60)[i % 7], (13, 19, 15, 23, 17, 14, 20)[(i * 3) % 7],
                      "petal" if i % 6 == 4 else "ember"))
    back = [t for t in items if t[0] < cy - 6]; front = [t for t in items if t[0] >= cy - 6]
    for y, x, h, c, cap in sorted(back): tstool(cv, x, y, h, c, rnd, cap)
    # the fairy-door toadstool, back and centre
    dx0, dy0 = 160, cy - 18
    tstool(cv, dx0, dy0, 78, 34, rnd, "ember", 7)
    for y in range(dy0 - 34, dy0 - 6):   # little arched door in the stem
        hw = 6 if y > dy0 - 30 else 4
        for x in range(dx0 - hw, dx0 + hw + 1): cv.put(x, y, W[3] if y > dy0 - 33 else W[3])
    for y in range(dy0 - 30, dy0 - 6):
        for x in range(dx0 - 5, dx0 + 6): cv.put(x, y, W[1 if x < dx0 - 1 else 2])
    for x in range(dx0 - 4, dx0 + 5): cv.put(x, dy0 - 32, W[1]); cv.put(x, dy0 - 33, W[2])
    cv.put(dx0 + 3, dy0 - 18, G[1]); cv.put(dx0 + 3, dy0 - 17, G[1])
    for xx in range(dx0 - 8, dx0 + 9): cv.put(xx, dy0 - 5, SD[3]); cv.put(xx, dy0 - 4, SD[3])
    for xx in range(dx0 - 5, dx0 + 6): cv.put(xx, dy0 - 3, SD[2])
    cv.put(dx0 - 12, dy0 - 36, G[0]); cv.put(dx0 + 12, dy0 - 36, G[0])   # two fairy lights
    for xx in range(dx0 - 12, dx0 + 13): cv.put(xx, dy0 - 41 + int(3 * math.sin((xx - dx0 + 12) / 24 * 3.14)), G[2])
    # the mushroom stool in the middle of the ring
    sx, sy = 160, cy + 12
    for y in range(sy - 16, sy):
        w = 9 + (y - sy + 16) // 5
        for x in range(sx - w, sx + w + 1): cv.put(x, y, SD[0 if x < sx - w // 2 else 1 if x < sx + w // 3 else 2])
    lump(cv, sx, sy - 17, 17, 6, SD, rnd, 0)
    for k in range(6): cv.put(sx - 7 + k * 2, sy - 17, SD[3])
    for y, x, h, c, cap in sorted(front): tstool(cv, x, y, h, c, rnd, cap)
    for x, y in ((92, cy + 18), (232, cy + 20), (40, cy + 10)): fern(cv, x, y + 10, rnd, .7)
    grass_tufts(cv, 8, 312, 186, rnd, 22)

def lm_bramble(rnd, cv):   # 360 x 180
    D = [RAMP["leaf"][1], RAMP["leaf"][2], RAMP["leaf"][3], RAMP["pine"][3], RAMP["pine"][3]]
    D = [RAMP["leaf"][1], mix(RAMP["leaf"][1], RAMP["leaf"][2], .5), RAMP["leaf"][2], RAMP["leaf"][3], RAMP["pine"][3]]
    LV = r5(RAMP["leaf"])
    walls = ((20, 142, 24, 32), (56, 150, 34, 28), (100, 146, 34, 32), (134, 140, 22, 36), (34, 106, 30, 34), (82, 98, 34, 36), (122, 100, 26, 38),
             (24, 62, 22, 30), (64, 56, 30, 34), (106, 52, 28, 32), (140, 74, 16, 30), (44, 28, 26, 22), (88, 24, 28, 20), (128, 40, 20, 20))
    for side in (0, 1):
        def X(v): return v if side == 0 else 359 - v
        for cx, cyy, rx, ry in walls: lump(cv, X(cx), cyy, rx, ry, D, rnd, .18)
        for _ in range(30):   # thorny canes arching out of the hedge
            x = X(rnd.randint(10, 150)); y = rnd.randint(20, 150); d = rnd.choice((-1, 1))
            if not cv.get(x, y)[3]: continue
            for k in range(14): cv.put(x + d * k, y - (k * k) // 14, RAMP["wood"][2 if k % 3 else 3])
            cv.put(x + d * 5, y - 3, RAMP["wood"][0]); cv.put(x + d * 9, y - 9, RAMP["wood"][0]); cv.put(x + d * 3, y - 1, RAMP["wood"][0])
        for _ in range(46):   # leaves catching the light
            x = X(rnd.randint(6, 150)); y = rnd.randint(8, 168)
            if cv.get(x, y)[3] and cv.get(x, y) != INK:
                for dx, dy in ((0, 0), (1, 0), (2, -1), (0, 1)): cv.put(x + dx, y + dy, LV[1])
        for _ in range(44):   # fat berries
            x = X(rnd.randint(8, 150)); y = rnd.randint(20, 160)
            if cv.get(x, y)[3] and cv.get(x, y) != INK:
                c = RAMP["dusk"] if rnd.random() < .6 else RAMP["ember"]
                for dx in range(-2, 3):
                    for dy in range(-2, 3):
                        if dx * dx + dy * dy <= 5: cv.put(x + dx, y + dy, c[0 if dx + dy < -1 else 2 if dx + dy > 1 else 1])
                cv.put(x - 1, y - 1, CREAM)
    for x in range(150, 210):   # the path through the gap
        for y in range(166, 180):
            if (x * 3 + y * 5) % 7 < 3 or y > 172: cv.put(x, y, LT[(x + y) % 3 + 1])
    # the offered berry on a stalk, and a sign
    for k in range(34): cv.put(190 + k // 8, 96 + k, RAMP["moss"][2]); 
    for dx, dy in ((0, 0), (1, 0), (2, 0), (0, 1), (1, 1), (2, 1), (1, 2), (-1, 1), (3, 1), (1, -1)): cv.put(191 + dx, 91 + dy, RAMP["dusk"][1 if dy else 0])
    cv.put(191, 91, CREAM); cv.put(192, 91, CREAM)
    for x in range(170, 186): cv.put(x, 100 + (x - 170) // 3, RAMP["moss"][2])   # little leaf
    for y in range(120, 176): cv.put(163, y, WD[2]); cv.put(164, y, WD[3]); cv.put(162, y, WD[1])
    for x in range(150, 182):
        for y in range(118, 138): cv.put(x, y, WD[1] if y < 121 else WD[2] if y < 135 else WD[3])
    glyphs(cv, 154, 124, "1", CREAM)
    for x, y in ((159, 126), (160, 126), (162, 124), (163, 124), (165, 126), (166, 126), (169, 124), (170, 124), (172, 126)): cv.put(x, y + 1, CREAM)
    for x in range(150, 210, 7): cv.put(x, 177, RAMP["moss"][1]); cv.put(x + 1, 176, RAMP["moss"][0])

def lm_greatstump(rnd, cv):   # 290 x 210
    cx, top, rx, ry, hgt = 125, 46, 112, 32, 96
    for x in range(cx - rx, cx + rx):   # side
        nx = (x - cx) / rx
        y1 = int(top + ry * math.sqrt(max(0, 1 - nx * nx))); y2 = int(top + hgt + ry * math.sqrt(max(0, 1 - nx * nx))) + 4
        u = (x - (cx - rx)) / (2 * rx); t = 0 if u < .1 else 1 if u < .3 else 2 if u < .65 else 3
        for y in range(y1, y2):
            tt = t
            if (x // 4 + y // 9) % 6 == 0 and y % 3: tt = min(3, tt + 1)
            if x % 9 == 0 and y % 4: tt = min(3, tt + 1)
            cv.put(x, y, WD[tt])
    for sx in (-1, 1):   # roots
        for k in range(26):
            x = cx + sx * (rx - 4 + k); y = top + hgt + ry // 2 + 10 + k // 5 * 1
            for h in range(14 - k // 3): cv.put(x, y - h + 6, WD[3 if h < 2 else 2 if sx < 0 else 3])
    def face(x, y, nx, ny):
        d = math.sqrt(nx * nx + ny * ny)
        if d > .95: return WD[3]
        if d > .9: return WD[2]
        k = int(d * 30)
        if k % 4 == 0 and d > .06: return WD[2] if (k // 4) % 3 == 0 else WD[1]
        return WD[0] if (x + y) % 11 else CREAM
    ell(cv, cx, top, rx, ry, face)
    for x in range(cx - 110, cx - 70): cv.put(x, top - 6 + (x * 3) % 4, WD[1]) if False else None
    # little round door and window: a stump that is a house
    for y in range(top + hgt - 40, top + hgt + ry + 2):
        for x in range(cx - 14, cx + 14):
            dy = y - (top + hgt - 38)
            if dy < 14 and (x - cx) ** 2 + (dy - 14) ** 2 > 14 ** 2: continue
            cv.put(x, y, INK if 2 < x - (cx - 14) < 25 else WD[3])
    for y in range(top + 66, top + hgt + 24, 1): cv.put(cx + 9, y, WD[1]) if y > top + hgt - 24 else None
    cv.put(cx + 6, top + hgt - 2, RAMP["gold"][0]); cv.put(cx + 7, top + hgt - 2, RAMP["gold"][1])
    ell(cv, cx + 62, top + 56, 9, 9, lambda x, y, nx, ny: RAMP["gold"][0] if nx + ny < -.3 else INK if abs(nx) < .15 or abs(ny) < .15 else RAMP["sea"][1])
    for k in range(8): cv.put(cx + 70, top + 96 + k, WD[3]) if False else None
    for x in range(cx - 104, cx - 34):   # moss cap on the left shoulder
        for y in range(top + ry - 8, top + ry + 4 + (x * 7) % 8):
            if cv.get(x, y)[3] and cv.get(x, y) != INK and (x + y) % 3: cv.put(x, y, RAMP["moss"][1 + (x // 3) % 2])
    toadstool(cv, cx - 62, top + 12, .7, rnd); toadstool(cv, cx - 48, top + 18, .5, rnd)
    for k in range(5): line(cv, cx + 60 + k * 9, top + 6 - (k % 2) * 3, cx + 60 + k * 9, top - 4 - (k % 2) * 3, [RAMP["moss"][1], RAMP["moss"][0]], 1)
    grass_tufts(cv, 8, 240, 180, rnd, 12)

def lm_larder(rnd, cv):   # 230 x 270
    C = r5(RAMP["leaf"])
    trunk(cv, 115, 100, 192, 62, rnd)
    for cx, cy, rx, ry in ((115, 70, 70, 44), (60, 98, 46, 34), (172, 98, 46, 34), (115, 40, 46, 32), (100, 110, 38, 24), (140, 112, 38, 24)):
        lump(cv, cx, cy, rx, ry, C, rnd, .12)
    leaf_texture(cv, C, rnd, 140)
    def hole(hx, hy, w, h, acorns):
        ell(cv, hx, hy, w, h, lambda x, y, nx, ny: INK if ny < .3 else WD[3])
        for dx, dy in acorns:
            a, b = hx + dx, hy + h - 4 + dy
            for k in range(4):
                for j in range(4): cv.put(a + k, b + j, RAMP["gold"][2 if j > 0 else 3]) if j > 1 else cv.put(a + k, b + j, WD[1] if j == 0 else WD[2])
            cv.put(a + 1, b + 1, RAMP["gold"][0]) if False else None
    hole(100, 140, 9, 13, ((-6, 0), (0, 1), (5, -1), (-2, -4)))
    hole(126, 168, 8, 10, ((-5, 0), (1, 1), (-1, -4)))
    # squirrel peering from the right, eyes sideways
    S = r5(RAMP["ember"]); sq = [H("#e8a060"), H("#c9783d"), H("#a85a32"), H("#7a3f2a"), H("#5a2c26")]
    for k in range(40):   # tail
        for w in range(14): 
            c = (sq[0] if w < 4 else sq[1] if w < 9 else sq[2]); xx = 166 + int(math.sin(k / 8) * 9) + w - (k // 4); cv.put(xx, 172 - k, c) if (k < 36 or w > 3) else None
    lump(cv, 156, 166, 15, 20, sq, rnd, 0); lump(cv, 152, 172, 8, 11, [CREAM, CREAM, H("#f0d9a8"), H("#f0d9a8"), H("#f0d9a8")], rnd, 0)
    lump(cv, 150, 138, 13, 12, sq, rnd, 0)
    for dx in (-8, -9): cv.put(150 + dx + 6, 124, sq[3])
    for ex in (144, 154):
        for dx in range(3): cv.put(ex + dx, 136, CREAM); cv.put(ex + dx, 137, CREAM)
        cv.put(ex, 136, INK); cv.put(ex, 137, INK)
    cv.put(146, 144, INK); cv.put(147, 144, INK); cv.put(148, 145, INK)
    for p in range(2): cv.put(143 + p * 14, 120, sq[2]); cv.put(143 + p * 14, 121, sq[2]); cv.put(144 + p * 14, 119, sq[2])
    for k, c in ((0, RAMP["gold"][1]), (1, RAMP["gold"][2])):   # acorn pile at roots
        pass
    for i in range(14):
        a, b = 40 + i * 11 + rnd.randint(-3, 3), 190 + rnd.randint(-2, 1)
        for k in range(4): cv.put(a + k, b, WD[1]); cv.put(a + k, b + 1, RAMP["gold"][2]); cv.put(a + k, b + 2, RAMP["gold"][3])
    grass_tufts(cv, 30, 200, 192, rnd, 12)

def lm_beaverdam(rnd, cv):   # 360 x 180
    R = r5(RAMP["sea"]); B = [H("#c9884a"), H("#a8683a"), H("#85502e"), H("#5f3a28"), H("#472a24")]
    W5 = r5(WD); L5 = r5(LT)
    _pond(cv, 180, 52, 172, 46, rnd)   # the big clear pond, behind the dam
    for k in range(2): _pond(cv, 180, 52, 172 - k, 46, rnd) if False else None
    for x, y, w in ((60, 44, 14), (110, 64, 11), (250, 36, 15), (300, 60, 12), (205, 70, 10)):   # lily pads and a flower
        lump(cv, x, y, w, 4, r5(RAMP["leaf"]), rnd, 0)
        cv.put(x + 2, y - 4, CREAM); cv.put(x + 3, y - 4, RAMP["petal"][1]) if x % 2 else None
    for x in (16, 28, 332, 342): _reeds(cv, x, 62, 1, rnd)
    for x in range(14, 346, 5): cv.put(x, 8 + (x * 7) % 4, R[0]) if False else None
    top = lambda x: 92 - int(8 * math.sqrt(max(0, 1 - ((x - 180) / 176) ** 2))) + ((x // 17) % 2)
    base = 160
    for x in range(4, 356):   # the dam: neat horizontal logs, tidy as a drawer
        for y in range(top(x), base):
            row = (y - top(x)) // 9; off = (row % 2) * 13; seg = (x + off) // 26
            ry = (y - top(x)) % 9
            c = W5[0 if ry < 1 else 1 if ry < 3 else 2 if ry < 6 else 3 if ry < 8 else 4]
            if (x + off) % 26 < 2: c = W5[4]
            if (seg + row) % 3 == 0 and ry > 1: c = L5[min(4, ry // 2)]
            cv.put(x, y, c)
    for _ in range(60):   # loose sticks poking from the crest
        x = rnd.randint(8, 350); y = top(x) + rnd.randint(-2, 3); L = rnd.randint(12, 24); d = rnd.choice((-1, 1)); sl = rnd.choice((2, 3, 4))
        for k in range(L):
            cv.put(x + d * k, y - k // sl, W5[1 if k % 7 else 0]); cv.put(x + d * k, y - k // sl + 1, W5[3])
    for x in range(4, 356):   # mud along the foot
        for y in range(base - 4, base + 10):
            c = L5[2 + (x + y) % 2] if y < base + 7 else L5[4]
            if (x * 3 + y) % 11 or y > base: cv.put(x, y, c)
    # spillway: pond water pours over the dam
    for x in range(118, 146):
        for y in range(top(x) - 1, base + 12): cv.put(x, y, R[0 if (x + y // 3) % 5 == 0 else 1 if (x * 3 + y) % 7 else 2])
    for x in range(112, 152, 2): cv.put(x, base + 11, CREAM); cv.put(x + 1, base + 12, CREAM)
    for x in range(100, 160): cv.put(x, base + 12, R[2]) if x % 3 else None
    # beaver sitting on the crest
    bx, by = 236, top(236) - 14
    lump(cv, bx, by, 19, 17, B, rnd, 0)
    ell(cv, bx, by + 6, 10, 8, lambda x, y, nx, ny: H("#e8c08a"))
    for dx in (-2, 0): 
        for dy in range(5): cv.put(bx + dx, by + 9 + dy, CREAM); cv.put(bx + dx + 1, by + 9 + dy, CREAM)
    cv.put(bx - 1, by + 6, INK); cv.put(bx, by + 6, INK); cv.put(bx - 1, by + 7, INK)
    for dx in (-9, 8): cv.put(bx + dx, by - 3, INK); cv.put(bx + dx, by - 2, INK)
    for dx in (-14, 13): lump(cv, bx + dx, by - 12, 4, 4, B, rnd, 0)
    ell(cv, bx + 30, by + 13, 14, 5, lambda x, y, nx, ny: B[2 if ny > 0 else 1])   # flat tail
    for dy in range(3): cv.put(bx + 26, by + 3 + dy, B[0])
    # a flag planted on the dam
    fx = 64; fy = top(fx) + 2
    for k in range(52): cv.put(fx, fy - k, W5[2]); cv.put(fx + 1, fy - k, W5[3])
    for xx in range(fx + 2, fx + 34):
        for yy in range(fy - 52, fy - 34): cv.put(xx, yy + (xx - fx) // 12, RAMP["ember"][0 if yy < fy - 50 else 1 if xx < fx + 20 else 2])
    glyphs(cv, fx + 10, fy - 48, "1", CREAM)
    for k in range(4): cv.put(fx + 20 + k, fy - 47 + k // 2, CREAM)
    for x in (8, 22, 336, 348): _reeds(cv, x, 172, 2, rnd)

def lm_mudslide(rnd, cv):   # 250 x 160
    M = [H(c) for c in ("#b88a64", "#8f6648", "#6e4a38", "#4e3330", "#3a2428")]
    lump(cv, 125, 88, 112, 62, M, rnd, .05)
    ell(cv, 125, 142, 90, 12, lambda x, y, nx, ny: M[2 if (x + y) % 7 else 1])
    for y in range(34, 144):   # glossy slide groove (diagonal)
        t = (y - 34) / 110; cxs = int(68 + t * 100)
        for x in range(cxs - 11 - int(t * 6), cxs + 11 + int(t * 6)):
            if cv.get(x, y)[3] and cv.get(x, y) != INK:
                u = (x - cxs) / (11 + t * 6)
                cv.put(x, y, M[1] if u < -.6 else M[2] if u > .6 else H("#d9b08a") if abs(u + .2) < .12 else M[0] if (x + y) % 9 else CREAM)
    for x in range(120, 200):   # puddle at bottom
        pass
    ell(cv, 176, 140, 36, 10, lambda x, y, nx, ny: H("#a9774e") if ny < 0 else M[2])
    for a, b in ((168, 138), (176, 141), (186, 137)): cv.put(a, b, CREAM); cv.put(a + 1, b, CREAM)
    for dx, dy in ((0, 0), (3, -3), (-4, -2), (7, -6), (10, 2)): ell(cv, 204 + dx, 128 + dy, 4, 4, lambda x, y, nx, ny: M[1])   # splats
    for sx, sy in ((50, 60), (84, 52), (100, 56)):   # footprints and handprints
        for k in range(3): cv.put(sx + k * 2, sy, M[3]); cv.put(sx + k * 2, sy + 1, M[3])
        cv.put(sx + 1, sy + 3, M[3]); cv.put(sx + 2, sy + 3, M[3])
    # a flung hat at the top
    for x in range(52, 82): 
        for y in range(34, 38): cv.put(x, y, RAMP["ember"][1] if y < 36 else RAMP["ember"][2])
    lump(cv, 67, 28, 11, 9, r5(RAMP["ember"]), rnd, 0)
    for x in range(10, 240, 7): cv.put(x, 150 + (x % 3), M[3])
    grass_tufts(cv, 6, 36, 120, rnd, 4); grass_tufts(cv, 214, 244, 124, rnd, 4)

def lm_lodge(rnd, cv):   # 290 x 220
    cx, cy = 145, 150
    for y in range(70, 200):
        for x in range(10, 280):
            nx = (x - cx) / 135; ny = (y - 200) / 130
            if nx * nx + ny * ny * 1.0 <= 1 and y <= 200:
                u = (nx * -.5 + ny * -.6) ; t = 0 if u > .45 else 1 if u > .2 else 2 if u > -.2 else 3
                cv.put(x, y, WD[t])
    for _ in range(420):   # sticks across the dome
        x = rnd.randint(14, 276); y = rnd.randint(74, 198); L = rnd.randint(14, 30); d = rnd.choice((-1, 1)); sl = rnd.choice((0, 1, 1, 2)) * rnd.choice((-1, 1)) / 4
        for k in range(L):
            xx, yy = x + d * k, int(y + sl * k)
            if cv.get(xx, yy)[3] and cv.get(xx, yy) != INK and cv.get(xx, yy + 1)[3]:
                cv.put(xx, yy, LT[0 if k % 6 == 0 else 1] if rnd.random() < .5 else WD[1]); cv.put(xx, yy + 1, WD[3])
    for x in range(10, 280):   # mud at the base
        for y in range(190, 204):
            if cv.get(x, y)[3] or y < 200: cv.put(x, y, LT[3 if (x + y) % 3 else 2]) if (x - cx) ** 2 / 135 ** 2 + ((y - 200) / 130) ** 2 <= 1.02 or y > 199 else None
    ell(cv, cx, 178, 26, 24, lambda x, y, nx, ny: INK if ny < .55 else None)   # doorway
    for y in range(176, 202): 
        for x in range(cx - 26, cx + 27):
            if (x - cx) ** 2 / 26 ** 2 + ((y - 178) / 24) ** 2 > 1 and (x - cx) ** 2 / 31 ** 2 + ((y - 178) / 29) ** 2 <= 1: cv.put(x, y, WD[3] if (x + y) % 2 else WD[2])
    for x in range(cx - 26, cx + 27): cv.put(x, 202, INK) if False else None
    for k in range(5): cv.put(cx - 12 + k * 6, 192, RAMP["gold"][1]) if k % 2 else None
    # chimney of sticks + stew smoke
    for y in range(48, 90):
        for x in range(190, 214): cv.put(x, y, WD[2 if (x // 4 + y // 5) % 2 else 1] if x < 208 else WD[3])
    S = [CREAM, H("#ece6e6"), H("#d3cfdc"), H("#b4b2c8"), H("#9a98b4")]
    for i, (sx, sy, r) in enumerate(((202, 36, 8), (212, 22, 8))):
        if sy - r >= 0: lump(cv, sx, sy, r, r, S, rnd, 0)
    for x in range(194, 212): cv.put(x, 48, WD[3])
    # tiny leafy roof tuft
    for _ in range(10): 
        x = rnd.randint(60, 120); lump(cv, x, 92 + (x % 5) * 3, 6, 4, r5(RAMP["moss"]), rnd, 0)
    toadstool(cv, 40, 190, .6, rnd)

def lm_stickgate(rnd, cv):   # 250 x 200
    def post(x, y0, y1, w=14):
        for y in range(y0, y1):
            for xx in range(x - w // 2, x + w // 2):
                u = (xx - (x - w // 2)) / w; cv.put(xx, y, WD[0 if u < .15 else 1 if u < .45 else 2 if u < .8 else 3])
        for xx in range(x - w // 2, x + w // 2): cv.put(xx, y0 - 1, WD[0]) if False else None
    for sx in (-1, 1):   # side fence wings with leaning sticks
        for i in range(5):
            x = 125 + sx * (78 + i * 9); h = 82 - i * 10 + rnd.randint(-3, 3)
            for y in range(196 - h, 196):
                for k in range(4): cv.put(x + k, y, WD[1 if k < 1 else 2 if k < 3 else 3])
            cv.put(x + 1, 196 - h - 1, WD[0]); cv.put(x + 2, 196 - h - 1, WD[1])
        for y0 in (134, 160): line(cv, 125 + sx * 70, y0, 125 + sx * 125, y0 + 10, [WD[0], WD[1], WD[3]], 3) if sx > 0 else line(cv, 125 - 125, y0 + 10, 125 - 70, y0, [WD[0], WD[1], WD[3]], 3)
    post(66, 60, 198); post(184, 60, 198)
    for sx in (66, 184):
        for k in range(4): cv.put(sx - 7 + k, 58 - k // 2 * 0, WD[0]) if False else None
    for i in range(8):   # vertical sticks of the gate, slightly uneven
        x = 82 + i * 11; top = 74 + (i * 7) % 11 - (6 if i % 3 == 0 else 0)
        for y in range(top, 196):
            for k in range(7): cv.put(x + k, y, WD[0 if k < 1 else 1 if k < 3 else 2 if k < 6 else 3])
        for k in range(7): cv.put(x + k, top - 1, LT[0])
    line(cv, 62, 100, 190, 94, [WD[0], WD[1], WD[2], WD[3]], 4)   # crossbars
    line(cv, 62, 160, 190, 168, [WD[0], WD[1], WD[2], WD[3]], 4)
    line(cv, 80, 164, 170, 98, [WD[1], WD[2], WD[3]], 3)
    # latch: a smaller stick on a nail
    line(cv, 150, 124, 188, 136, [RAMP["sand"][0], RAMP["sand"][1], WD[3]], 3)
    for dx in range(3):
        for dy in range(3): cv.put(188 + dx - 1, 126 + dy + 4, RAMP["stone"][2])
    cv.put(152, 121, RAMP["gold"][0])
    for x in range(8, 240): cv.put(x, 197 + (x * 3) % 3, RAMP["moss"][2]) if x % 3 == 0 else None
    # bird on the post, as a gate guard
    lump(cv, 184, 48, 9, 9, [H("#e8a060"), H("#c9783d"), H("#a85a32"), H("#7a3f2a"), H("#5a2c26")], rnd, 0)
    cv.put(180, 46, INK); cv.put(179, 49, RAMP["gold"][1]); cv.put(178, 49, RAMP["gold"][1])
    grass_tufts(cv, 6, 240, 196, rnd, 14)

def lm_tunnelmouth(rnd, cv):   # 290 x 240
    M = r5(RAMP["moss"]); L = r5(RAMP["leaf"])
    cx = 145
    lump(cv, cx, 158, 138, 84, [RAMP["moss"][0], RAMP["moss"][1], RAMP["moss"][2], RAMP["leaf"][2], RAMP["leaf"][3]], rnd, .12)
    for cxx, cyy, r in ((70, 84, 30), (210, 88, 34), (140, 76, 38)): lump(cv, cxx, cyy + 30, r, int(r * .7), L, rnd, .12)
    leaf_texture(cv, L, rnd, 120)
    # stone rim of the doorway
    ell(cv, cx, 162, 56, 66, lambda x, y, nx, ny: RAMP["stone"][0] if nx + ny < -.8 else RAMP["stone"][1] if nx + ny < -.1 else RAMP["stone"][2] if ny < .6 else RAMP["stone"][3])
    # dark interior with a faint violet-teal depth
    def inner(x, y, nx, ny):
        d = nx * nx + ny * ny
        return H("#2a1f3d") if d > .45 else H("#1a1428") if d > .2 else H("#120d1e")
    ell(cv, cx, 168, 44, 56, lambda x, y, nx, ny: inner(x, y, nx, ny) if y < 232 else None)
    for y in range(168, 232):
        for x in range(cx - 44, cx + 44): pass
    for gx, gy in ((cx - 12, 150), (cx + 14, 178), (cx - 4, 200), (cx + 20, 140)): 
        cv.put(gx, gy, RAMP["sea"][0]); cv.put(gx + 1, gy, RAMP["sea"][1])   # glow-cap glints deep in
    for x in range(cx - 44, cx + 44):   # floor lip
        for y in range(226, 232): cv.put(x, y, WD[3 if (x + y) % 4 else 2]) if cv.get(x, y)[3] else None
    # the crooked Welcome sign hanging from the arch by two cords
    for x in range(cx + 62, cx + 66): pass
    sx0, sy0 = 196, 148
    for k in range(6): cv.put(sx0 + 4, sy0 - k * 2 - 4, WD[3]); cv.put(sx0 + 40, sy0 + 2 - k * 2 - 4 + 4, WD[3])
    for x in range(40):
        yk = int(x * .12)
        for y in range(18): 
            cv.put(sx0 + x, sy0 + yk + y, WD[0] if y < 2 else WD[1] if y < 14 else WD[2] if y < 17 else WD[3])
    for i, ch in enumerate((1, 1, 0, 1, 1, 0, 1)):   # scribbled "Welcome"
        x = sx0 + 4 + i * 5; y = sy0 + int((x - sx0) * .12) + 5
        for dy in range(6): cv.put(x, y + dy, CREAM) if ch else None
        cv.put(x + 1, y + 3, CREAM); cv.put(x + 2, y + (0 if i % 2 else 5), CREAM)
    for x in range(10, 280): cv.put(x, 236 + (x % 3) // 2, RAMP["moss"][2]) if x % 3 == 0 else None
    for fx, fy in ((40, 152), (230, 160), (60, 118), (250, 120)):
        for dx, dy, c in ((0, 0, RAMP["gold"][1]), (-3, 0, CREAM), (3, 0, CREAM), (0, -3, CREAM), (0, 3, CREAM)): cv.put(fx + dx, fy + dy, c)

def glowcap(cv, x, y, s, R, rnd, halo=True):
    S = r5(R); sh = int(10 * s)
    if halo:
        for yy in range(y - sh - int(13 * s), y + 3):
            for xx in range(x - int(18 * s), x + int(18 * s)):
                if cv.get(xx, yy)[3] == 0 and ((xx - x) ** 2 / (18 * s) ** 2 + (yy - (y - sh - 4 * s)) ** 2 / (14 * s) ** 2) < 1 and (xx + yy) % 3 == 0: cv.put(xx, yy, R[3])
    for yy in range(y - sh, y):
        for xx in range(x - max(1, int(2 * s)), x + max(1, int(2 * s))): cv.put(xx, yy, CREAM if xx < x else S[1])
    lump(cv, x, y - sh - int(3 * s), int(11 * s), int(8 * s), S[::-1] if False else [H("#e6fff4"), R[0], R[1], R[2], R[3]], rnd, 0)
    for dx in (-4, 1, 5): cv.put(x + int(dx * s), y - sh - int(5 * s), CREAM)

def lm_glowtunnel(rnd, cv):   # 290 x 210
    cx, cy = 145, 112
    ell(cv, cx, cy + 4, 140, 94, lambda x, y, nx, ny: RAMP["dusk"][0 if nx + ny < -.9 else 1 if nx + ny < -.2 else 2 if ny < .5 else 3] if (x + y) % 9 else RAMP["dusk"][2])   # rocky arch
    for _ in range(40): 
        a, b = rnd.randint(14, 276), rnd.randint(30, 190)
        if cv.get(a, b)[3] and cv.get(a, b) != INK: cv.put(a, b, RAMP["dusk"][3]); cv.put(a + 1, b, RAMP["dusk"][3])
    def inner(x, y, nx, ny):
        d = nx * nx + ny * ny
        return H("#1a1233") if d > .6 else H("#120c26") if d > .28 else H("#0a0818")
    ell(cv, cx, cy + 16, 104, 78, inner)
    for k in range(7):   # receding tunnel ribs
        r = 1 - k * .13
        for a in range(0, 360, 3):
            x = cx + int(math.cos(math.radians(a)) * 104 * r); y = cy + 16 + int(math.sin(math.radians(a)) * 78 * r)
            if cv.get(x, y)[3] and (a // 3) % 2: cv.put(x, y, H("#2c2150") if k % 2 else H("#241a44"))
    floor_y = 190
    for x in range(40, 250):   # floor
        nx = (x - cx) / 104; fy = cy + 16 + int(78 * math.sqrt(max(0, 1 - nx * nx)))
        for y in range(fy - 8, fy + 1): cv.put(x, y, H("#2c2150") if (x + y) % 3 else H("#1a1233")) if cv.get(x, y)[3] else None
    teal, vio = RAMP["sea"], RAMP["dusk"]
    for gx, gy, s, R in ((54, 178, 1.2, teal), (82, 190, .9, vio), (34, 150, .8, teal), (216, 182, 1.15, vio), (246, 160, .8, teal), (196, 192, .8, teal), (74, 162, .6, vio), (226, 140, .6, vio),
                         (120, 150, .35, teal), (170, 146, .3, vio), (100, 130, .3, teal), (148, 128, .25, teal), (44, 120, .7, vio), (252, 120, .6, teal)):
        glowcap(cv, gx, gy, s, R, rnd)
    for i in range(10):   # ceiling drip-caps
        x = 50 + i * 20; y = 44 + 22 * int(abs(math.sin(i * 1.3))) if False else 40 + abs(5 - i) * 4
        R = teal if i % 2 else vio
        for k in range(5): cv.put(x, y + k, R[1]); 
        ell(cv, x, y + 6, 4, 3, lambda xx, yy, nx, ny: R[0] if ny < 0 else R[1])
    # stray glow motes
    for _ in range(18):
        x, y = rnd.randint(70, 220), rnd.randint(70, 170); cv.put(x, y, teal[0]); cv.put(x + 1, y, teal[0])

LM = {"312-ringlog": (340, 200, lm_ringlog), "312-woodpecker": (170, 270, lm_woodpecker), "312-toadring": (320, 190, lm_toadring),
      "312-bramble": (360, 180, lm_bramble), "312-greatstump": (250, 190, lm_greatstump), "312-larder": (230, 196, lm_larder),
      "313-beaverdam": (360, 180, lm_beaverdam), "313-mudslide": (250, 160, lm_mudslide), "313-lodge": (290, 220, lm_lodge),
      "313-stickgate": (250, 200, lm_stickgate), "313-tunnelmouth": (290, 240, lm_tunnelmouth), "313-glowtunnel": (290, 210, lm_glowtunnel)}
