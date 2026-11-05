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

def lm_ringlog(rnd, cv):   # 270 x 150
    cv_w = 270
    for x in range(70, 240):   # log body
        top = 80 + (x // 9) % 2; bot = 136
        for y in range(top, bot):
            u = (y - top) / (bot - top); t = 0 if u < .12 else 1 if u < .35 else 2 if u < .65 else 3
            if (x * 5 + y * 3) % 17 == 0: t = min(3, t + 1)
            if (x // 5 + y // 12) % 7 == 0 and y % 4 == 0: t = 3
            cv.put(x, y, WD[t])
    for x in range(70, 240, 11):   # bark ridges
        for y in range(86 + x % 7, 130, 1):
            if (y + x) % 5: cv.put(x, y, WD[3]) if (x // 11) % 2 else None
    for x in range(80, 232):   # moss on top
        for y in range(76, 80 + (x * 3) % 9):
            if (x // 6) % 3 != 0: cv.put(x, y, r5(RAMP["moss"])[1 + (x + y) % 3 // 2 * 1])
    for x in range(160, 215): cv.put(x, 82 + (x * 5) % 7, RAMP["moss"][2])
    def face(x, y, nx, ny):
        d = math.sqrt(nx * nx + ny * ny)
        if d > .93: return WD[3]
        if d > .86: return WD[2]
        k = int(d * 20)
        if k % 3 == 0 and d > .1: return WD[1] if (k // 3) % 2 else WD[2]
        return WD[0] if d < .12 else r5(WD)[1]
    ell(cv, 66, 108, 26, 30, face)
    
    for i, (x, y) in enumerate(((68, 84), (80, 128), (56, 120))): cv.put(x, y, CREAM)
    for i in range(6):   # tally pebbles on top
        lump(cv, 120 + i * 13, 72, 5, 4, r5(RAMP["stone"]), rnd, 0)
    toadstool(cv, 232, 98, .8, rnd); toadstool(cv, 246, 110, .5, rnd)
    for x in range(100, 250): cv.put(x, 138 + (x * 7) % 3, WD[3]) if x % 2 else None
    grass_tufts(cv, 20, 250, 143, rnd, 14)
    # question marks / lost count swirl

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

def lm_toadring(rnd, cv):   # 260 x 130
    cx, cy, rx, ry = 130, 70, 108, 22
    def g(x, y, nx, ny):
        return RAMP["moss"][1 if (x * 7 + y * 3) % 11 else 0]
    ell(cv, cx, cy + 4, rx - 8, ry - 3, g)
    n = 15; items = []
    for i in range(n):
        a = i / n * 6.2832 + .2
        items.append((cy + int(math.sin(a) * ry) + 12, cx + int(math.cos(a) * rx), rnd.choice((.8, 1.0, 1.1, .9, 1.25))))
    for y, x, s in sorted(items): toadstool(cv, x, y, s * 1.15, rnd, "ember" if rnd.random() < .85 else "petal")
    for x, y in ((120, 68), (150, 78), (100, 80)): 
        for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)): cv.put(x + dx, y + dy, CREAM)
    grass_tufts(cv, 10, 250, 122, rnd, 16)

def lm_bramble(rnd, cv):   # 290 x 170
    L = r5(RAMP["leaf"]); D = [RAMP["leaf"][1], RAMP["leaf"][2], RAMP["leaf"][3], RAMP["pine"][3], RAMP["pine"][3]]
    for side in (0, 1):
        ox = 0 if side == 0 else 190
        for cx, cy, rx, ry in ((50, 112, 50, 44), (30, 70, 34, 34), (70, 64, 36, 36), (58, 28, 30, 28), (20, 120, 24, 30)):
            cx2 = ox + (cx if side == 0 else 100 - cx + 0)
            lump(cv, cx2, cy + 18, rx, ry, D, rnd, .15)
        for _ in range(26):   # thorny canes
            x = ox + rnd.randint(8, 92); y = rnd.randint(30, 140); d = rnd.choice((-1, 1))
            for k in range(12): cv.put(x + d * k, y - (k * k) // 12, RAMP["wood"][2 if k % 3 else 3])
            cv.put(x + d * 5, y - 4, RAMP["wood"][0]); cv.put(x + d * 8, y - 9, RAMP["wood"][0])
        for _ in range(26):   # berries
            x = ox + rnd.randint(8, 92); y = rnd.randint(40, 150)
            if cv.get(x, y)[3]:
                c = RAMP["dusk"] if rnd.random() < .5 else RAMP["ember"]
                for dx, dy, i in ((0, 0, 1), (1, 0, 1), (0, 1, 2), (1, 1, 2), (-1, 0, 2), (0, -1, 0)): cv.put(x + dx, y + dy, c[i] if i < 3 else c[1])
                cv.put(x, y - 1, CREAM)
    # the offered berry on a stalk at the gap
    for k in range(20): cv.put(100 + k // 3, 80 + k, RAMP["moss"][2])
    for x in range(100, 190):   # path floor
        for y in range(155, 168): cv.put(x, y, LT[1 if (x + y) % 5 else 0]) if False else None
    for x, y in ((104, 94), (105, 94), (104, 95), (105, 95)): cv.put(x, y, RAMP["dusk"][1])
    cv.put(104, 94, CREAM)
    # sign
    for y in range(110, 160): cv.put(142, y, WD[2]); cv.put(143, y, WD[3])
    for x in range(126, 160):
        for y in range(108, 124): cv.put(x, y, WD[1] if y < 110 else WD[2] if y < 122 else WD[3])
    for x, y in ((132, 114), (133, 114), (138, 116), (139, 116), (145, 114), (146, 114), (150, 116)): cv.put(x, y, CREAM); cv.put(x, y + 1, CREAM) if x % 2 else None

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

def lm_beaverdam(rnd, cv):   # 290 x 150
    _pond(cv, 145, 70, 138, 52, rnd)
    for x in range(8, 282):   # dam: stacked sticks in a low mound
        nx = (x - 145) / 138; top = int(62 - 24 * math.sqrt(max(0, 1 - nx * nx)))
        for y in range(top, 126):
            c = WD[(x * 3 + y * 5 + (x // 7)) % 4]
            if (y // 4 + x // 13) % 2 == 0: c = LT[(x + y) % 4]
            cv.put(x, y, c)
    for i in range(140):   # sticks poking out
        x = rnd.randint(8, 280); nx = (x - 145) / 138; top = int(62 - 24 * math.sqrt(max(0, 1 - nx * nx)))
        y = rnd.randint(top - 2, 122); L = rnd.randint(14, 26); d = rnd.choice((-1, 1)) 
        if y < top + 2: continue
        for k in range(L):
            xx = x + d * k; yy = y - k // 5
            if cv.get(xx, yy)[3] and cv.get(xx, yy) != INK or yy < top: cv.put(xx, yy, WD[1 if k % 7 else 0]); cv.put(xx, yy + 1, WD[3])
    for x in range(8, 282):   # mud and wet line
        nx = (x - 145) / 138; top = int(62 - 24 * math.sqrt(max(0, 1 - nx * nx)))
        for y in range(118, 128): cv.put(x, y, LT[3 if (x + y) % 3 else 2])
    for k in range(70, 82):   # beaver on top
        pass
    B = [H("#c9884a"), H("#a8683a"), H("#85502e"), H("#5f3a28"), H("#472a24")]
    lump(cv, 145, 30, 17, 15, B, rnd, 0)
    ell(cv, 145, 38, 8, 6, lambda x, y, nx, ny: H("#e8c08a"))
    for dx in (-1, 0): 
        for dy in range(4): cv.put(145 + dx * 2, 42 + dy, CREAM); cv.put(146 + dx * 2, 42 + dy, CREAM)
    cv.put(145, 38, INK); cv.put(146, 38, INK)
    for dx in (-8, 7): cv.put(145 + dx, 26, INK); cv.put(145 + dx, 27, INK)
    for dx in (-13, 12): lump(cv, 145 + dx, 18, 4, 4, B, rnd, 0)
    ell(cv, 215, 12, 14, 5, lambda x, y, nx, ny: B[2 if ny > 0 else 1])   # tail slapping
    _reeds(cv, 6, 132, 3, rnd); _reeds(cv, 262, 132, 3, rnd)

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

LM = {"312-ringlog": (270, 150, lm_ringlog), "312-woodpecker": (170, 270, lm_woodpecker), "312-toadring": (260, 130, lm_toadring),
      "312-bramble": (290, 170, lm_bramble), "312-greatstump": (250, 190, lm_greatstump), "312-larder": (230, 196, lm_larder),
      "313-beaverdam": (290, 150, lm_beaverdam), "313-mudslide": (250, 160, lm_mudslide), "313-lodge": (290, 220, lm_lodge),
      "313-stickgate": (250, 200, lm_stickgate), "313-tunnelmouth": (290, 240, lm_tunnelmouth), "313-glowtunnel": (290, 210, lm_glowtunnel)}
