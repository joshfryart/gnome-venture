import random, math
import gen2
from gen2 import RAMP, INK, CREAM, Cv, lump, r5, outline, trunk, leaf_texture, darker, mix, H, T, _col, _pond, _reeds
"""Forest landmarks, routes 304-306 (12 sprites). Hard pixels only; the figure is centred on canvas_w/2, base at the bottom."""

BIRCH = [H(c) for c in ("#fffdf2", "#ece9de", "#c4c0b6", "#8a8586")]
BIRCH5 = r5(BIRCH)

def _ok(cv, x, y):
    c = cv.get(x, y); return c[3] and c != INK

def _bole(cv, cxf, wf, y0, y1, R, rnd, bark=True):
    for y in range(y0, y1):
        c = cxf(y); w = wf(y)
        for x in range(int(c - w), int(c + w) + 1):
            u = (x - (c - w)) / max(1, 2 * w)
            t = 0 if u < .12 else 1 if u < .32 else 2 if u < .6 else 3 if u < .85 else 4
            if bark and (x * 13 + (y // 5) * 7) % 9 == 0: t = min(4, t + 1)
            elif bark and rnd.random() < .04: t = max(0, t - 1)
            cv.put(x, y, R[t])

def _disc(cv, cx, cy, r, col, ry=None):
    ry = ry or r
    for y in range(int(cy - ry), int(cy + ry) + 1):
        for x in range(int(cx - r), int(cx + r) + 1):
            if (x - cx) ** 2 / r ** 2 + (y - cy) ** 2 / ry ** 2 <= 1: cv.put(x, y, col)

def _rect(cv, x0, y0, x1, y1, col):
    for y in range(y0, y1):
        for x in range(x0, x1): cv.put(x, y, col)

def _line(cv, x0, y0, x1, y1, col, w=1):
    n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in range(n + 1):
        x = x0 + (x1 - x0) * i / n; y = y0 + (y1 - y0) * i / n
        for a in range(w):
            for b in range(w): cv.put(int(round(x)) + a, int(round(y)) + b, col)

def _acorn(cv, x, y, rnd, s=1):
    L = r5(RAMP["litter"]); W = r5(RAMP["wood"])
    lump(cv, x, y + 2 * s, 3.5 * s, 5 * s, L, rnd, 0)
    lump(cv, x, y - 2 * s, 4.5 * s, 3 * s, [W[1], W[2], W[3], W[4], W[4]], rnd, 0)
    cv.put(x, y - 6 * s, W[3]); cv.put(x, y - 5 * s, W[3])

def _mush(cv, x, y, rnd, s=1):
    E = r5(RAMP["ember"]); S = r5(RAMP["sand"])
    _rect(cv, x - s, y - 4 * s, x + s + 1, y + 1, S[2])
    lump(cv, x, y - 5 * s, 5 * s, 3.5 * s, E, rnd, 0)
    cv.put(x - s, y - 6 * s, CREAM); cv.put(x + 2 * s, y - 5 * s, CREAM)

def _tuft(cv, x, y, rnd, n=4, h=8):
    M = RAMP["moss"]
    for i in range(n):
        xx = x + i * 2 - n; hh = h + rnd.randint(-2, 2); lean = rnd.choice((-1, 1))
        for k in range(hh): cv.put(xx + (lean * k) // 4, y - k, M[0] if k > hh - 3 else M[1 + (i % 2)])

def _hat(cv, x, y, rnd):   # tiny pointed red hat, base centred at x, bottom at y
    E = RAMP["ember"]
    for k in range(20):
        hw = (20 - k) * 8 // 20 + (0 if k < 19 else 0)
        for xx in range(x - hw, x + hw + 1):
            cv.put(xx + (k // 8), y - k, E[0] if xx < x - hw // 2 else E[1] if xx < x + hw // 3 else E[2])
    for xx in range(x - 9, x + 10): cv.put(xx, y, RAMP["sand"][1]); cv.put(xx, y - 1, RAMP["sand"][0])

# ----------------------------------------------------------------------------------- 304
def lm_oakarch(rnd, cv):   # 280 x 250
    W = r5(RAMP["wood"]); R = r5(RAMP["leaf"])
    for y in range(26, 238):
        for x in range(8, 274):
            ox = (x - 140) / 124; oy = (y - 236) / 208
            ix = (x - 140) / 64; iy = (y - 236) / 122
            if ox * ox + oy * oy > 1 or ix * ix + iy * iy < 1: continue
            t = tone5(ox, oy)
            if ix * ix + iy * iy < 1.35: t = min(4, t + 1)
            if (x * 11 + int(math.atan2(oy, ox) * 40) * 5) % 13 == 0: t = min(4, t + 1)
            elif rnd.random() < .05: t = max(0, t - 1)
            cv.put(x, y, W[t])
    for cx, cy, rx, ry in ((140, 42, 74, 34), (76, 70, 54, 32), (204, 70, 54, 32), (140, 66, 62, 26), (36, 108, 30, 24), (244, 108, 30, 24)):
        lump(cv, cx, cy, rx, ry, R, rnd)
    leaf_texture(cv, R, rnd, 260)
    for cx, cy, rx, ry in ((26, 232, 30, 12), (254, 232, 30, 12), (62, 238, 22, 8), (220, 238, 22, 8)):
        lump(cv, cx, cy, rx, ry, W, rnd, .05)
    for cx, cy, rx, ry in ((22, 160, 14, 10), (28, 196, 16, 10), (252, 178, 14, 10)):
        lump(cv, cx, cy, rx, ry, r5(RAMP["moss"]), rnd)
    _line(cv, 140, 104, 140, 126, RAMP["stone"][2])   # lantern on a string
    lump(cv, 140, 136, 8, 10, r5(RAMP["gold"]), rnd, 0); _rect(cv, 134, 126, 147, 128, RAMP["wood"][3]); _rect(cv, 139, 133, 142, 139, CREAM)
    _rect(cv, 108, 244, 172, 249, RAMP["sand"][2]); _rect(cv, 108, 244, 172, 245, RAMP["sand"][1])   # welcome mat
    _mush(cv, 40, 246, rnd); _mush(cv, 50, 248, rnd, 1); _tuft(cv, 236, 246, rnd); _tuft(cv, 84, 247, rnd, 3)

def tone5(nx, ny):
    d = nx * -0.5 + ny * -0.6 + math.sqrt(max(0, 1 - nx * nx - ny * ny)) * .62
    return 0 if d > .7 else 1 if d > .4 else 2 if d > .05 else 3 if d > -.3 else 4

def lm_hollowtrunk(rnd, cv):   # 210 x 250
    W = r5(RAMP["wood"]); R = r5(RAMP["leaf"])
    top = lambda x: 40 + ((x * 7) % 23) + (14 if x < 70 else 0) - (10 if 110 < x < 140 else 0)
    for y in range(36, 248):
        c = 105; w = 48 + max(0, y - 190) // 3 + (4 if y % 40 < 6 else 0)
        for x in range(c - w, c + w + 1):
            if y < top(x): continue
            u = (x - (c - w)) / (2 * w + 1)
            t = 0 if u < .12 else 1 if u < .32 else 2 if u < .6 else 3 if u < .85 else 4
            if (x * 13 + (y // 5) * 7) % 9 == 0: t = min(4, t + 1)
            cv.put(x, y, W[t])
    for x in range(62, 150):   # ragged lit rim of the broken top
        y = top(x)
        for k in range(3): cv.put(x, y + k, W[0] if k == 0 else W[1])
    # doorway
    for y in range(150, 248):
        hw = 34 if y > 188 else int(34 * math.sqrt(max(0, 1 - ((y - 188) / 38) ** 2)))
        for x in range(105 - hw, 105 + hw + 1):
            e = abs(x - 105) / 34
            cv.put(x, y, INK if e < .8 else W[4])
    lump(cv, 105, 214, 14, 24, [RAMP["moss"][0], RAMP["moss"][1], RAMP["moss"][2], RAMP["moss"][2], RAMP["moss"][3]], rnd, 0)   # green light at the far end
    _rect(cv, 94, 244, 118, 248, RAMP["moss"][1])
    _line(cv, 90, 152, 112, 152, CREAM); _line(cv, 90, 152, 100, 176, CREAM); _line(cv, 112, 152, 100, 176, CREAM); _line(cv, 90, 152, 112, 180, CREAM)   # web
    _line(cv, 112, 150, 112, 186, RAMP["stone"][0])   # spider on a thread
    lump(cv, 112, 192, 6, 5, [CREAM, RAMP["dusk"][0], RAMP["dusk"][1], RAMP["dusk"][2], RAMP["dusk"][3]], rnd, 0)
    for lx, d in ((-1, -1), (1, 1)):
        for k in range(3): _line(cv, 112 + d * 5, 190 + k * 2, 112 + d * 11, 186 + k * 4 - 2, RAMP["dusk"][3])
    cv.put(110, 190, CREAM); cv.put(114, 190, CREAM)
    for cx, cy, rx, ry in ((70, 40, 20, 14), (96, 38, 16, 10), (150, 36, 26, 16)):
        lump(cv, cx, cy, rx, ry, R, rnd)
    leaf_texture(cv, R, rnd, 40)
    for cx, cy, rx, ry in ((50, 244, 26, 10), (160, 246, 26, 9)): lump(cv, cx, cy, rx, ry, r5(RAMP["moss"]), rnd)
    for y in range(120, 158):   # bracket fungus
        hw = int(26 * math.sqrt(max(0, 1 - ((y - 120) / 36) ** 2)))
        for x in range(148, 148 + hw): cv.put(x, y, RAMP["gold"][0 if y < 128 else 1 if y < 142 else 2])
    for x in range(148, 172): cv.put(x, 121, RAMP["gold"][0])
    _mush(cv, 30, 246, rnd); _tuft(cv, 180, 247, rnd)

def lm_acorndrop(rnd, cv):   # 210 x 250
    W = r5(RAMP["wood"]); R = r5(RAMP["leaf"])
    _bole(cv, lambda y: 100 + (y - 120) // 30 * 0 + (4 if y % 50 < 25 else 0), lambda y: 11 + max(0, y - 220) // 3, 120, 246, W, rnd)
    for cx, cy, rx, ry in ((100, 62, 70, 40), (46, 88, 40, 28), (156, 88, 40, 28), (100, 98, 58, 26), (70, 40, 34, 22), (136, 44, 34, 22)):
        lump(cv, cx, cy, rx, ry, R, rnd)
    leaf_texture(cv, R, rnd, 300)
    for x, y in ((50, 100), (80, 112), (120, 108), (150, 98), (100, 84), (66, 70), (134, 68)): _acorn(cv, x, y, rnd, 1)   # still hanging
    for x, y, sz in ((62, 136, 1), (96, 160, 1), (126, 144, 1), (82, 190, 1), (134, 186, 1), (112, 214, 1), (150, 160, 1)):   # falling, with speed marks
        _acorn(cv, x, y, rnd, sz)
        for k in range(3): cv.put(x - 1, y - 9 - k * 4, RAMP["litter"][0]); cv.put(x, y - 9 - k * 4, RAMP["litter"][0])
    for k in range(16):   # the heap
        x = 100 + int(rnd.gauss(0, 24)); y = 242 - rnd.randint(0, 6) - max(0, 12 - abs(x - 100) // 2)
        _acorn(cv, x, y, rnd, 1)
    _hat(cv, 156, 247, rnd)
    for k in range(5): cv.put(30 + k * 8, 248, RAMP["moss"][1]); cv.put(31 + k * 8, 247, RAMP["moss"][0])

def lm_owloak(rnd, cv):   # 240 x 290
    W = r5(RAMP["wood"]); R = r5(RAMP["leaf"])
    _bole(cv, lambda y: 120 + int(6 * math.sin(y / 38)), lambda y: 52 + max(0, y - 240) // 2 + int(5 * math.sin(y / 23)), 80, 286, W, rnd)
    _bole(cv, lambda y: 68 - (y - 160) // 3, lambda y: 8, 150, 190, W, rnd)   # side bough stump
    lump(cv, 50, 136, 22, 14, R, rnd)
    for cx, cy, rx, ry in ((120, 54, 88, 46), (52, 92, 46, 32), (190, 86, 50, 34), (120, 96, 66, 26), (176, 50, 40, 28)):
        lump(cv, cx, cy, rx, ry, R, rnd)
    leaf_texture(cv, R, rnd, 380)
    for ox in (-12, 12):   # feather tufts
        for k in range(8): cv.put(120 + ox + (k // 3) * (1 if ox > 0 else -1), 120 - k, W[1] if k % 2 else W[2])
    _disc(cv, 122, 148, 24, W[4]); _disc(cv, 122, 148, 20, INK)   # hole with a rim
    for ex in (112, 134):
        _disc(cv, ex, 150, 8, CREAM); _disc(cv, ex + 1, 152, 3, INK)
        _rect(cv, ex - 8, 141, ex + 9, 148, W[3])   # sleepy lids
        for x in range(ex - 8, ex + 9): cv.put(x, 148, INK)
    for zx, zy, zs in ((156, 118, 7), (166, 102, 9), (180, 84, 11)):   # z z z
        for k in range(zs): cv.put(zx + k, zy, CREAM); cv.put(zx + zs - k, zy + k, CREAM); cv.put(zx + k, zy + zs, CREAM)
    for cx, cy, rx, ry in ((98, 220, 8, 14), (140, 196, 7, 11)): lump(cv, cx, cy, rx, ry, [W[3], W[3], W[4], W[4], W[4]], rnd, 0)   # knots
    for cx, cy, rx, ry in ((62, 282, 36, 10), (178, 284, 34, 9)): lump(cv, cx, cy, rx, ry, r5(RAMP["moss"]), rnd)
    _tuft(cv, 200, 286, rnd, 5, 12); _mush(cv, 34, 287, rnd); _mush(cv, 44, 288, rnd)

# ----------------------------------------------------------------------------------- 305
def lm_birchtunnel(rnd, cv):   # 290 x 230
    R = r5(RAMP["leaf"]); P = r5(RAMP["pine"])
    for y in range(54, 226):   # the dark way through
        for x in range(76, 216):
            e = abs(x - 146) / 70; t = 4 if e > .55 or y < 100 else 3
            cv.put(x, y, P[t])
    for y in range(110, 226):   # light at the end
        hw = int(26 * math.sqrt(max(0, 1 - ((y - 190) / 80) ** 2)))
        for x in range(146 - hw, 146 + hw + 1): cv.put(x, y, R[0] if abs(x - 146) < hw * .5 else R[1] if y < 200 else R[2])
    def tr(x0, x1, ytop, w, flip):
        cxf = lambda y: x0 + (x1 - x0) * (226 - y) / (226 - ytop)
        _bole(cv, cxf, lambda y: w, ytop, 226, BIRCH5, rnd, bark=False)
        for y in range(ytop + 6, 224, 11):   # black chevron marks
            c = int(cxf(y))
            for x in range(c - w + 2, c + w - 3):
                if rnd.random() < .8: cv.put(x, y, BIRCH[3]); cv.put(x, y + 1, BIRCH[3]) if (x + y) % 3 else None
            for k in range(rnd.randint(3, 5)): cv.put(c - w + rnd.randint(3, 2 * w - 4), y + 3 + rnd.randint(0, 3), BIRCH[3])
    for x0, x1, yt in ((28, 44, 66), (62, 80, 58), (96, 126, 66)): tr(x0, x1, yt, 11, 0)
    for x0, x1, yt in ((262, 246, 66), (228, 210, 58), (194, 166, 66)): tr(x0, x1, yt, 11, 1)
    for cx, cy, rx, ry in ((60, 52, 50, 30), (146, 38, 80, 34), (230, 52, 50, 30), (146, 70, 62, 24), (110, 52, 40, 26), (182, 52, 40, 26), (26, 84, 22, 22), (264, 84, 22, 22)):
        lump(cv, cx, cy, rx, ry, R, rnd)
    leaf_texture(cv, R, rnd, 280)
    for x in range(126, 168, 7): _tuft(cv, x, 226, rnd, 2, 5)
    _mush(cv, 18, 226, rnd); _tuft(cv, 270, 227, rnd, 3, 8)

def lm_birchcurtain(rnd, cv):   # 280 x 220
    R = r5(RAMP["leaf"]); M = r5(RAMP["moss"])
    xs = [24 + i * 29 for i in range(9)]
    for i, x in enumerate(xs):
        yt = 50 + (i * 17) % 23
        _bole(cv, lambda y, x=x: x + int(2 * math.sin(y / 30 + x)), lambda y: 9, yt, 216, BIRCH5, rnd, bark=False)
        for y in range(yt + 8, 214, 13):
            for xx in range(x - 6, x + 5):
                if rnd.random() < .7: cv.put(xx, y, BIRCH[3])
            cv.put(x + rnd.randint(-5, 3), y + 5, BIRCH[3]); cv.put(x + rnd.randint(-5, 3), y + 6, BIRCH[2])
    for i, x in enumerate(xs):
        yt = 50 + (i * 17) % 23
        lump(cv, x, yt - 6, 26, 18, R, rnd, .1)
    for i, x in enumerate(xs):   # hanging curtain strands
        for k in range(-2, 3):
            xx = x + k * 5 + 1; L = 70 + rnd.randint(0, 50) + (20 if k == 0 else 0)
            for y in range(52, 52 + L):
                cv.put(xx, y, M[1 + (y // 7 + k) % 2] if y < 52 + L - 6 else M[0]); cv.put(xx + 1, y, M[2]) if y % 5 else None
    leaf_texture(cv, R, rnd, 160)
    for i in (2, 6):   # two trunks who have forgotten why they came
        x = xs[i] + 1
        for ex in (x - 5, x + 2):
            _rect(cv, ex, 140, ex + 4, 147, CREAM); _rect(cv, ex + 1, 142, ex + 3, 146, INK)
        _disc(cv, x, 158, 3, INK, 4); _disc(cv, x, 158, 1, RAMP["petal"][1], 2)
    for i in (2, 6, 4):   # boots at the foot, in a crowd
        for d in (-4, 6): _rect(cv, xs[i] + d - 2, 211, xs[i] + d + 4, 216, RAMP["wood"][2]); _rect(cv, xs[i] + d - 2, 215, xs[i] + d + 5, 217, RAMP["wood"][3])
    _hat(cv, xs[5], 62, rnd)
    for x in range(8, 274, 11): _tuft(cv, x, 218, rnd, 2, 5)

def lm_fernhollow(rnd, cv):   # 270 x 130
    M = r5(RAMP["moss"]); L = r5(RAMP["leaf"])
    cx, cy, rx, ry = 135, 92, 128, 34
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            nx = (x - cx) / rx; ny = (y - cy) / ry
            if nx * nx + ny * ny > 1: continue
            d = nx * nx + ny * ny; t = 4 if d > .82 else 3 if d > .55 else 2 if d > .3 else 1
            if ny > .3 and d < .5: t = 0 if ny > .55 else 1   # light cups the lower side
            if rnd.random() < .08: t = max(0, min(4, t + rnd.choice((-1, 1))))
            cv.put(x, y, M[t])
    lump(cv, 150, 92, 52, 18, [M[0], M[0], M[1], M[1], M[2]], rnd, .05)   # the pillow
    def frond(x, y, ang, ln, bend, R):
        pts = []
        for k in range(ln):
            a = ang + bend * k / ln
            x += math.cos(math.radians(a)); y -= math.sin(math.radians(a)); pts.append((x, y, a))
        for k, (px, py, a) in enumerate(pts):
            cv.put(int(px), int(py), R[3]); cv.put(int(px) + 1, int(py), R[2])
            if k % 3 == 0 and k > 3:
                ll = int((ln - k) * .42) + 2
                for s in (-1, 1):
                    for j in range(ll):
                        ax = int(px + s * j * math.cos(math.radians(a - 80 * s + 90 * 0)) * .9 + s * j); ay = int(py - j * .35 - (j * j) * .02)
                        c = R[0] if j < 2 else R[1] if s < 0 else R[2]
                        cv.put(ax, ay, c); cv.put(ax, ay + 1, R[2] if s < 0 else R[3])
    for x, y, a, ln, b in ((28, 100, 120, 56, 50), (42, 106, 100, 70, 40), (236, 104, 60, 60, -50), (250, 98, 75, 54, -40), (70, 112, 110, 48, 40),
                           (206, 114, 70, 50, -40), (112, 76, 95, 44, 55), (190, 74, 85, 48, -55), (148, 70, 90, 40, 0), (16, 94, 130, 46, 60)):
        frond(x, y, a, ln, b, M)
    # snail
    lump(cv, 150, 100, 26, 7, r5(RAMP["sand"]), rnd, 0)
    lump(cv, 132, 92, 8, 9, r5(RAMP["sand"]), rnd, 0)   # head
    lump(cv, 156, 80, 18, 18, r5(RAMP["petal"]), rnd, 0)   # shell
    for a in range(0, 540, 12):
        r = 2 + a / 540 * 13; cv.put(156 + int(r * math.cos(math.radians(a))), 80 + int(r * math.sin(math.radians(a))), RAMP["petal"][3])
    for ex in (128, 134): _line(cv, ex, 86, ex - 2 + (ex - 128) // 2 * 3, 72, RAMP["sand"][2]); _disc(cv, ex - 2 + (ex - 128) // 2 * 3, 71, 2, CREAM); cv.put(ex - 2 + (ex - 128) // 2 * 3, 71, INK)
    for x in range(124, 176): cv.put(x, 108, M[0]) if x % 4 else None
    _tuft(cv, 14, 118, rnd, 3, 6); _tuft(cv, 258, 118, rnd, 3, 6)

def lm_sunclearing(rnd, cv):   # 250 x 170
    M = r5(RAMP["moss"]); S = RAMP["sand"]; G = RAMP["gold"]
    cx, cy, rx, ry = 125, 124, 120, 34
    for y in range(cy - ry, cy + ry + 1):   # grass disc
        for x in range(cx - rx, cx + rx + 1):
            if (x - cx) ** 2 / rx ** 2 + (y - cy) ** 2 / ry ** 2 > 1: continue
            t = 2 if y < cy else 3 if y < cy + ry // 2 else 4
            if rnd.random() < .1: t = max(0, t - 1)
            cv.put(x, y, M[t])
    for y in range(104, 142):   # the square of sun, in perspective
        f = (y - 104) / 38; x0 = int(52 - f * 26); x1 = int(186 + f * 26)
        for x in range(x0, x1):
            e = min(x - x0, x1 - x, y - 104, 141 - y)
            t = G[0] if e > 5 else S[0]
            if e > 5 and (x + y) % 11 == 0: t = CREAM
            cv.put(x, y, t)
    for x in range(30, 220, 4): cv.put(x, 126 + (x % 7), S[0]) if cv.get(x, 126 + (x % 7)) == M[2] else None
    # rabbit, in the sun
    L = r5(RAMP["litter"]); W = r5(RAMP["sand"])
    lump(cv, 98, 124, 11, 9, r5([CREAM, CREAM, S[1], S[2], S[3]] and [CREAM, CREAM, H("#f4e6c0"), S[1], S[2]]), rnd, 0)   # tail
    lump(cv, 126, 110, 30, 30, L, rnd, .05)   # body
    lump(cv, 136, 118, 15, 18, [CREAM, CREAM, H("#f4e6c0"), S[1], S[1]], rnd, 0)   # belly
    lump(cv, 112, 134, 18, 8, L, rnd, 0); lump(cv, 150, 134, 14, 7, L, rnd, 0)   # feet
    lump(cv, 144, 68, 22, 20, L, rnd, .05)   # head
    for ex, ey, tilt in ((138, 26, -1), (156, 28, 1)):
        for k in range(-6, 7):
            for y in range(ey - 8, ey + 38):
                w = 7 - abs(y - (ey + 12)) // 5
                if abs(k) <= max(2, w): cv.put(ex + k + (y - ey) // 10 * tilt, y, L[0 if k < -2 else 1 if k < 2 else 2])
        for y in range(ey + 2, ey + 28): cv.put(ex + (y - ey) // 10 * tilt, y, RAMP["petal"][0])
    for ex in (150, 160): _disc(cv, ex, 66, 3, INK); cv.put(ex - 1, 65, CREAM)
    cv.put(166, 74, RAMP["petal"][2]); cv.put(167, 74, RAMP["petal"][2]); cv.put(166, 75, RAMP["petal"][2])
    for k in range(5): cv.put(158 + k, 78 + k // 2, L[0]); cv.put(158 + k, 82 - k // 2, L[0])
    for i in range(7):   # buttercups
        x, y = 14 + i * 36 + rnd.randint(-5, 5), 120 + rnd.randint(-4, 24)
        if 50 < x < 190 and 100 < y < 142: continue
        for dx, dy in ((0, 0), (-2, 0), (2, 0), (0, -2), (0, 2)): cv.put(x + dx, y + dy, CREAM if dx or dy else G[1])
    for x in (12, 40, 210, 236): _tuft(cv, x, 150 + (x % 3), rnd, 3, 7)

# ----------------------------------------------------------------------------------- 306
def lm_mosslog(rnd, cv):   # 290 x 130
    W = r5(RAMP["wood"]); M = r5(RAMP["moss"])
    _pond(cv, 145, 110, 138, 16, rnd)
    for cx in (30, 262): lump(cv, cx, 100, 26, 14, r5(RAMP["stone"]), rnd, .1)
    top = lambda x: 36 + int(5 * math.sin((x - 20) / 90 * math.pi)) if 20 <= x <= 270 else 36
    for x in range(14, 272):
        y0 = top(x); y1 = y0 + 44 - (6 if x > 250 else 0) - (4 if x < 30 else 0)
        for y in range(y0, y1):
            u = (y - y0) / (y1 - y0); t = 0 if u < .1 else 1 if u < .3 else 2 if u < .58 else 3 if u < .84 else 4
            if (y * 13 + (x // 5) * 7) % 9 == 0: t = min(4, t + 1)
            cv.put(x, y, W[t])
    for cy, d in ((60, 1),):   # the cut end, with rings
        for y in range(36, 82):
            for x in range(262, 281):
                if ((x - 268) / 12) ** 2 + ((y - 59) / 23) ** 2 <= 1:
                    r = math.hypot((x - 268) / 12, (y - 59) / 23); cv.put(x, y, RAMP["sand"][0] if int(r * 7) % 2 == 0 else RAMP["sand"][1])
        cv.put(268, 59, W[3])
    for x0 in range(30, 262, 22):   # moss fur on top
        lump(cv, x0 + rnd.randint(-3, 3), top(x0) + 2, 18 + rnd.randint(-3, 4), 8 + rnd.randint(0, 4), M, rnd, .12)
    for x in range(30, 260, 3):   # moss drips
        if (x * 7) % 5 < 2:
            for y in range(top(x) + 8, top(x) + 8 + 4 + (x * 3) % 9): cv.put(x, y, M[2 + (y % 2)])
    lump(cv, 28, 38, 10, 9, W, rnd, 0)   # branch stub
    _mush(cv, 120, top(120) + 2, rnd, 1); _mush(cv, 130, top(130) + 4, rnd, 1); _mush(cv, 200, top(200) + 2, rnd, 1)
    _reeds(cv, 6, 118, 2, rnd)
    for x in range(60, 230, 30): cv.put(x, 116, RAMP["sea"][0]); cv.put(x + 1, 117, CREAM)

def lm_dripgrotto(rnd, cv):   # 250 x 240
    S = r5(RAMP["stone"]); M = r5(RAMP["moss"])
    for cx, cy, rx, ry in ((125, 170, 118, 66), (44, 184, 48, 48), (206, 184, 48, 48), (125, 110, 74, 58), (80, 142, 52, 42), (172, 142, 52, 42)):
        lump(cv, cx, cy, rx, ry, S, rnd, .1)
    cm = lambda y: 36 if y > 170 else int(36 * math.sqrt(max(0, 1 - ((y - 170) / 40) ** 2)))
    for y in range(130, 238):
        for x in range(125 - cm(y), 125 + cm(y) + 1):
            e = abs(x - 125) / 36; cv.put(x, y, S[4] if (e > .85 or y < 138) else INK)
    for x in range(125 - 36, 125 + 37, 12):   # stalactites
        L = 14 + (x * 7) % 12
        for k in range(L):
            hw = (L - k) // 4
            for xx in range(x - hw, x + hw + 1): cv.put(xx, 134 + k, S[1 if xx < x else 2]) if cv.get(xx, 134 + k) in (INK, S[4]) else None
    for x in (100, 148):   # stalagmites
        for k in range(18):
            for xx in range(x - (18 - k) // 4, x + (18 - k) // 4 + 1): cv.put(xx, 228 - k, S[1 if xx < x else 3])
    _pond(cv, 125, 230, 30, 6, rnd)
    for rx_ in (14, 24): cv.put(125 - rx_, 230, CREAM); cv.put(125 + rx_, 230, CREAM)
    for x, y in ((110, 164), (132, 188), (116, 206), (140, 160)):   # drips
        _disc(cv, x, y, 2, RAMP["sea"][0], 3); cv.put(x, y - 4, RAMP["sea"][0]); cv.put(x, y - 3, RAMP["sea"][1])
    for cx, cy, rx, ry in ((125, 70, 50, 20), (74, 100, 34, 16), (176, 100, 34, 16), (42, 150, 20, 12), (208, 150, 20, 12)):
        lump(cv, cx, cy, rx, ry, M, rnd, .1)
    for x in range(78, 172, 5):   # moss fringe over the mouth
        for y in range(122, 126 + (x * 5) % 8): cv.put(x, y, M[2 + (y % 2)])
    _mush(cv, 40, 236, rnd); _tuft(cv, 214, 238, rnd, 3, 8)
    _acorn_ = None

def lm_mossgate(rnd, cv):   # 240 x 230
    S = r5(RAMP["stone"]); M = r5(RAMP["moss"]); G = RAMP["gold"]
    posts = ((24, 74, 78, 222), (166, 216, 100, 222))
    for x0, x1, y0, y1 in posts:
        _col(cv, x0, x1, y0, y1, S, rnd, .12)
        for y in range(y0 + 14, y1, 22):   # courses of stone
            for x in range(x0, x1): cv.put(x, y, S[3])
        mh = (y1 - y0) * 62 // 100
        for x in range(x0, x1):   # moss poured down the post
            dep = mh + 8 * ((x * 7) % 5) // 2 - (x - x0) // 6
            for y in range(y0 + 4, y0 + dep):
                u = (x - x0) / (x1 - x0); t = 0 if u < .2 else 1 if u < .5 else 2 if u < .8 else 3
                if y > y0 + dep - 5: t = min(4, t + 1)
                if rnd.random() < .12: t = max(0, t - 1)
                cv.put(x, y, M[t + 0])
        lump(cv, (x0 + x1) // 2, y0 + 2, (x1 - x0) // 2 + 6, 14, M, rnd, .12)   # domed cap
        for y in range(y1 - 22, y1):   # mossy foot
            for x in range(x0 - 4, x1 + 4):
                if (x * 5 + y) % 7 < 3: cv.put(x, y, M[2 + (y % 2)])
    for ey, ex in ((124, 74), (184, 74)):   # hinges, holding nothing
        _rect(cv, ex, ey, ex + 18, ey + 6, S[4]); _rect(cv, ex, ey, ex + 18, ey + 2, S[2])
        _disc(cv, ex + 20, ey + 3, 4, S[4]); _disc(cv, ex + 20, ey + 3, 2, (0, 0, 0, 0))
    _line(cv, 94, 130, 94, 160, S[2]); _line(cv, 95, 130, 95, 160, S[3])   # a chain, going nowhere
    lump(cv, 95, 172, 7, 9, r5(G), rnd, 0); cv.put(95, 180, G[3]); cv.put(95, 181, G[3])
    _rect(cv, 166 - 8, 158, 166, 164, S[4]); _rect(cv, 158, 158, 166, 160, S[2])
    for cx, cy in ((50, 76), (192, 98)):   # little flowers on the caps
        for dx, dy, c in ((0, 0, G[1]), (-3, 0, CREAM), (3, 0, CREAM), (0, -3, CREAM), (0, 3, CREAM)): cv.put(cx + dx, cy + dy, c)
    for x in range(84, 160, 5): _tuft(cv, x, 224, rnd, 2, 6 + (x % 4))
    _mush(cv, 118, 222, rnd); _mush(cv, 128, 224, rnd)
    _mush(cv, 12, 224, rnd)

def lm_toadsteps(rnd, cv):   # 260 x 240
    M = r5(RAMP["moss"]); E = r5(RAMP["ember"]); S = r5(RAMP["sand"])
    lump(cv, 130, 200, 124, 38, M, rnd, .1); lump(cv, 190, 160, 66, 60, M, rnd, .1)
    steps = ((200, 96), (150, 128), (100, 160), (52, 194))
    for sx, sy in steps:
        for y in range(sy + 4, sy + 34):
            hw = 9 + (y - sy) // 12
            for x in range(sx - hw, sx + hw): 
                u = (x - (sx - hw)) / (2 * hw); cv.put(x, y, S[0 if u < .15 else 1 if u < .4 else 2 if u < .75 else 3])
        lump(cv, sx, sy, 40, 14, E, rnd, 0)   # flat cap
        for y in range(sy + 4, sy + 14):   # gills underneath
            hw = int(40 * math.sqrt(max(0, 1 - ((y - sy - 4) / 14) ** 2))) if False else 0
        for k in range(5):
            ax = sx - 26 + k * 13 + (k % 2) * 3; ay = sy - 5 + (k * 5) % 7
            _disc(cv, ax, ay, 3, CREAM, 2)
        for x in range(sx - 36, sx + 37, 4):   # light rim and gill line on the lower edge
            y = sy + int(11 * math.sqrt(max(0, 1 - ((x - sx) / 40) ** 2)))
            cv.put(x, y + 1, S[2]); cv.put(x + 1, y + 1, S[1])
    for x, y in ((24, 214), (236, 206), (212, 206)): _tuft(cv, x, y + 22, rnd, 3, 8)
    _mush(cv, 232, 226, rnd, 1); _mush(cv, 18, 226, rnd, 1); _mush(cv, 240, 232, rnd, 1)
    for x in range(60, 200, 6): cv.put(x, 232, M[0]); cv.put(x + 1, 233, M[1])

LM = {
 "304-oakarch": (280, 250, lm_oakarch), "304-hollowtrunk": (210, 250, lm_hollowtrunk),
 "304-acorndrop": (210, 250, lm_acorndrop), "304-owloak": (240, 290, lm_owloak),
 "305-birchtunnel": (290, 230, lm_birchtunnel), "305-birchcurtain": (280, 220, lm_birchcurtain),
 "305-fernhollow": (270, 130, lm_fernhollow), "305-sunclearing": (250, 170, lm_sunclearing),
 "306-mosslog": (290, 130, lm_mosslog), "306-dripgrotto": (250, 240, lm_dripgrotto),
 "306-mossgate": (240, 230, lm_mossgate), "306-toadsteps": (260, 240, lm_toadsteps),
}
