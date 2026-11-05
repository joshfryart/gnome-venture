import random, math
import gen2
from gen2 import RAMP, INK, CREAM, Cv, lump, r5, outline, trunk, leaf_texture, darker, mix, H, T, _col, _pond, _reeds

def R_(n): return RAMP[n]
def rect(cv, x0, y0, x1, y1, c):
    for y in range(y0, y1):
        for x in range(x0, x1): cv.put(x, y, c)
def disc(cv, cx, cy, r, c):
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r, cx + r + 1):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r * r + r // 2: cv.put(x, y, c)
def hline(cv, x0, x1, y, c):
    for x in range(x0, x1): cv.put(x, y, c)
def vline(cv, x, y0, y1, c):
    for y in range(y0, y1): cv.put(x, y, c)
def eyes(cv, x, y, gap=8, s=3):
    for ex in (x - gap // 2, x + gap // 2):
        rect(cv, ex - s // 2, y, ex - s // 2 + s, y + s + 1, INK); cv.put(ex - s // 2, y, CREAM)
def smile(cv, x, y, w, c=None):
    c = c or RAMP["ember"][3]
    for k in range(-w, w + 1): cv.put(x + k, y + (k * k) // max(1, w * 2) * -1 + w // 2, c)
def foot_flat(cv, cx, y, rx, c):   # flat-bottomed lump: erase below y
    for yy in range(y + 1, cv.h):
        for x in range(cx - rx - 4, cx + rx + 5): cv.p[x, yy] = (0, 0, 0, 0) if 0 <= x < cv.w else None
def mound(cv, cx, base, rx, ry, R, rnd, speck=.1):
    lump(cv, cx, base, rx, ry, R, rnd, speck)
    for y in range(base + 1, base + ry + 3):
        for x in range(cx - rx - 2, cx + rx + 3):
            if 0 <= x < cv.w and 0 <= y < cv.h: cv.p[x, y] = (0, 0, 0, 0)
def shell(cv, x, y, s, col, rnd):
    P = RAMP[col]
    for dy in range(-s, 1):
        w = int(s * math.sqrt(max(0, 1 - (dy / s) ** 2)) * 1.4) + 1 if False else s + dy + 1
        for dx in range(-w, w + 1):
            cv.put(x + dx, y + dy, P[1] if (dx + dy) % 3 else P[0])
    for k in range(-s + 1, s, 2): cv.put(x + k, y, P[2]); cv.put(x + k // 2, y - s // 2, P[2])
    cv.put(x, y, P[3])
def spiral(cv, x, y, s, col):
    P = RAMP[col]
    disc(cv, x, y, s, P[1]); disc(cv, x - 1, y - 1, s - 1, P[0])
    for a in range(0, 540, 20):
        r = s * (1 - a / 640.0)
        cv.put(x + int(round(math.cos(math.radians(a)) * r)), y + int(round(math.sin(math.radians(a)) * r)), P[3])
def crab(cv, x, y, s, rnd, wave=False):
    E = r5(RAMP["ember"])
    for sx in (-1, 1):   # legs
        for k in range(3):
            for j in range(5 * s): cv.put(x + sx * (7 * s + j), y + 2 * s + k * 2 * s + j // 2, RAMP["ember"][3])
    lump(cv, x, y + 2 * s, 9 * s, 6 * s, E, rnd, .05)
    for sx in (-1, 1):   # claws
        cy = y - 4 * s if (wave and sx > 0) else y
        for k in range(5 * s): cv.put(x + sx * (8 * s + k // 3), y + 2 * s - k // 2 if wave and sx > 0 else y + 2 * s, RAMP["ember"][2])
        lump(cv, x + sx * 12 * s, cy, 4 * s, 3 * s, E, rnd, 0)
        rect(cv, x + sx * 12 * s - 1, cy - 1, x + sx * 12 * s + 1, cy + 1, RAMP["ember"][3])
    for sx in (-1, 1):
        vline(cv, x + sx * 3 * s, y - s, y + s, RAMP["ember"][2])
        disc(cv, x + sx * 3 * s, y - s * 2, s + 1, CREAM); disc(cv, x + sx * 3 * s, y - s * 2, max(1, s - 1) , INK)
def gull(cv, x, y, s=1, flip=False, open_beak=False):
    d = -1 if flip else 1
    rnd = random.Random(x * 31 + y)
    lump(cv, x, y, 8 * s, 5 * s, r5(RAMP["snow"]), rnd, 0)
    for k in range(7 * s):   # grey wing
        for j in range(3 * s): cv.put(x - d * (k + 1) + d * 2 * s, y - s + j, RAMP["stone"][1 if j < 2 * s else 2]) if k > s else None
    lump(cv, x + d * 7 * s, y - 5 * s, 4 * s, 4 * s, r5(RAMP["snow"]), rnd, 0)
    for k in range(4 * s): cv.put(x + d * (10 * s + k), y - 4 * s + k // 3 + (1 if open_beak else 0), RAMP["gold"][1])
    if open_beak:
        for k in range(3 * s): cv.put(x + d * (10 * s + k), y - 5 * s, RAMP["gold"][1])
    cv.put(x + d * 8 * s, y - 6 * s, INK); cv.put(x + d * 8 * s, y - 6 * s + 1, INK)
    for lx in (-2 * s, 2 * s): vline(cv, x + lx, y + 4 * s, y + 7 * s, RAMP["gold"][2])
    for k in range(3 * s): cv.put(x - d * (8 * s + k), y + 1 * s, RAMP["stone"][2])   # tail
def waves(cv, x0, x1, y, rnd, amp=2, c=None):
    for x in range(x0, x1):
        yy = y + int(round(math.sin(x / 7.0) * amp))
        cv.put(x, yy, c or CREAM)
        if x % 3: cv.put(x, yy + 1, RAMP["sea"][0])
def seaband(cv, x0, x1, y0, y1, rnd):
    for y in range(y0, y1):
        t = 0 if y < y0 + (y1 - y0) // 4 else 1 if y < y0 + (y1 - y0) // 2 else 2 if y < y0 + 3 * (y1 - y0) // 4 else 3
        for x in range(x0, x1):
            tt = t
            if (x * 5 + y * 3) % 11 == 0: tt = max(0, tt - 1)
            cv.put(x, y, RAMP["sea"][tt])
def pebble_(cv, x, y, rx, ry, c, rnd):
    R = [mix(c, CREAM, .5), mix(c, CREAM, .22), c, darker_c(c), darker_c(darker_c(c))]
    lump(cv, x, y, rx, ry, R, rnd, 0)
def darker_c(c): return mix(c, H("#2b1c26"), .35)

# ------------------------------------------------------------------ 307
# ---- polish-pass helpers
def logh(cv, x0, x1, y0, h, rnd, R=None):
    """horizontal driftwood log, lit from the top, with a ring end on the left and grain lines"""
    R = R or r5(RAMP["wood"])
    for x in range(x0, x1):
        e = min(x - x0, x1 - 1 - x)
        for r in range(h):
            if e < 3 and (r < 3 - e or r >= h - 3 + e): continue
            u = r / float(h - 1); t = 0 if u < .18 else 1 if u < .45 else 2 if u < .75 else 3
            if (x * 5 + r * 3) % 17 == 0: t = min(4, t + 1)
            if r in (h // 2,) and (x // 6) % 3 == 0: t = min(4, t + 1)
            cv.put(x, y0 + r, R[t])
    for dy in range(h - 2):
        for dx in range(4):
            if (dx - 1.5) ** 2 / 4 + (dy - (h - 2) / 2.0) ** 2 / max(1, ((h - 2) / 2.0) ** 2) <= 1: cv.put(x0 + dx, y0 + 1 + dy, R[0] if dx == 1 or dy % 3 == 1 else R[1])
def stick(cv, x0, y0, x1, y1, w=3, R=None):
    R = R or RAMP["wood"]; n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in range(n + 1):
        x = x0 + (x1 - x0) * i // n; y = y0 + (y1 - y0) * i // n
        for k in range(w): cv.put(x + k, y, R[0 if k == 0 else 1 if k < w - 1 else 3])
def weed(cv, x, y, h, rnd, lean=1, R=None):
    R = R or RAMP["pine"]
    for k in range(h):
        xx = x + int(math.sin(k / 5.0 + x) * 2) + lean * k // 6
        cv.put(xx, y - k, R[1 if k % 5 else 0]); cv.put(xx + 1, y - k, R[2])
        if k % 7 == 3: disc(cv, xx - 2, y - k, 2, R[0])
def prints(cv, x, y, c, flip=1):
    for dx, dy in ((0, 0), (-3, -3), (3, -3), (0, -4)):
        pass
    cv.put(x, y, c); cv.put(x, y - 1, c); cv.put(x, y - 2, c); cv.put(x - 2, y - 3, c); cv.put(x + 2, y - 3, c); cv.put(x - 1, y - 2, c); cv.put(x + 1, y - 2, c)
def bottle(cv, x, y, lean=1):
    """green bottle stuck neck-up in the sand; y is where it sits"""
    G = [H("#d4f5d0"), H("#8fd4a0"), H("#4fa07c"), H("#2c6358")]
    for k in range(40):
        bx = x + lean * (40 - k) // 6; w = 8 if k < 26 else 3
        for dx in range(-w, w + 1):
            if k < 26 or abs(dx) <= 3: cv.put(bx + dx, y - k, G[0] if dx < -w + 2 else G[1] if dx < w - 2 else G[2])
    for k in range(26, 38):
        bx = x + lean * (40 - k) // 6
        for dx in range(-2, 3): cv.put(bx + dx, y - k - 1, G[1] if dx < 2 else G[2])
    bx = x + lean * 2 // 6 * 0
    tx = x + lean * (40 - 38) // 6
    for dx in range(-3, 4): cv.put(tx + dx, y - 40, RAMP["wood"][1]); cv.put(tx + dx, y - 41, RAMP["wood"][0]); cv.put(tx + dx, y - 39, RAMP["wood"][2])
    for k in range(14): cv.put(x - 2 + (k % 2), y - 8 - k, CREAM); cv.put(x + (k % 2) + 1, y - 8 - k, RAMP["sand"][1])   # the message inside
def cairn(cv, cx, base, n, rnd, cols, w0=18):
    y = base
    for i in range(n):
        rx = max(5, int(w0 * (1 - i * .15) + rnd.randint(-1, 2))); ry = max(3, int(rx * .55))
        pebble_(cv, cx + rnd.randint(-2, 2), y - ry, rx, ry, cols[(i * 3 + 1) % len(cols)], rnd); y -= int(ry * 1.7)
    return y
def para(cv, pts_fn, x0, x1, y0, y1, colfn):
    for y in range(y0, y1):
        for x in range(x0, x1):
            if pts_fn(x, y): cv.put(x, y, colfn(x, y))
def lm_tideline(rnd, cv):   # 330 x 124
    W = 330; SD = RAMP["sand"]
    top = lambda x: 82 + int(math.sin(x / 40.0) * 6); bot = lambda x: 118 + int(math.sin(x / 40.0 + 1) * 3)
    for y in range(70, 124):   # wide curved wet-sand band
        for x in range(4, W - 4):
            if y < top(x) or y > bot(x): continue
            e = min(x - 4, W - 5 - x)
            if e < 14 and (y - top(x)) * 14 < (14 - e) * (bot(x) - top(x)): continue
            t = 1 if y < top(x) + 5 else 2 if y < bot(x) - 12 else 3
            if (x * 7 + y * 3) % 13 == 0: t = max(0, t - 1)
            cv.put(x, y, SD[t])
    for x in range(6, W - 6):   # foam edge, two rows
        if x % 5 != 0: cv.put(x, top(x), CREAM); cv.put(x, top(x) + 1, RAMP["sea"][0] if x % 2 else CREAM)
        if x % 9 < 4: cv.put(x, top(x) - 2 + (x // 9) % 2, RAMP["sea"][0])
    for x in range(10, W - 10, 5): cv.put(x, bot(x) - 1 + (x % 3), SD[3])
    for x in range(12, W - 10, 11):   # ripples in the wet sand
        hline(cv, x, x + 5, top(x) + 12 + (x // 11) % 3 * 3, SD[1])
    # driftwood log with a branch and draped weed, left
    logh(cv, 22, 122, 94, 14, rnd)
    stick(cv, 58, 96, 38, 30, 5); stick(cv, 44, 66, 70, 36, 4); stick(cv, 47, 78, 22, 44, 4); stick(cv, 40, 40, 30, 10, 3); stick(cv, 38, 40, 52, 16, 3); stick(cv, 68, 38, 80, 24, 3)
    weed(cv, 64, 96, 18, rnd, -1); weed(cv, 100, 96, 14, rnd, 1)
    # crab waving from a tide-line rock
    lump(cv, 188, 100, 24, 16, r5(RAMP["stone"]), rnd, .1)
    crab(cv, 188, 52, 3, rnd, wave=True)
    gull(cv, 112, 76, 2, True)
    # bottle with a message
    bottle(cv, 244, 116, -1)
    # shell piles at both ends
    for cx, base, rx, ry in ((292, 112, 28, 26), (136, 116, 18, 14)):
        mound(cv, cx, base, rx, ry, r5(SD), rnd, .1)
    cols = ["gold", "petal", "sand", "snow", "ember", "dusk"]
    for i in range(34):
        cx, rx, ry, base = (292, 28, 26, 112) if i < 24 else (136, 18, 14, 116)
        a = rnd.random() * 3.14; r = math.sqrt(rnd.random()) * .85
        x = int(cx + math.cos(a) * rx * r * (1 if rnd.random() < .5 else -1)); y = int(base - math.sin(a) * ry * r)
        if i % 4 == 0: spiral(cv, x, y, 4, cols[i % 6])
        else: shell(cv, x, y, 4 + i % 2, cols[i % 6], rnd)
    n = 0
    for x in range(18, 300, 17):   # the long line of shells along the foam
        if 270 < x < 314: continue
        y = top(x) + 18 + rnd.randint(-2, 5) if x < 150 else top(x) + 14 + rnd.randint(-2, 4); n += 1
        if 100 < x < 170 and y > 92: continue
        if n % 3 == 0: spiral(cv, x, y, 4, cols[n % 6])
        else: shell(cv, x, y, 5 if n % 2 else 4, cols[n % 6], rnd)
    for x, y in ((196, 110), (214, 104), (262, 100), (246, 94), (150, 108), (160, 111)):   # bird footprints
        prints(cv, x, y, SD[3])
    # a lonely sock on a stick
    stick(cv, 308, 100, 310, 14, 4); rect(cv, 314, 14, 328, 24, RAMP["ember"][1]); rect(cv, 314, 24, 322, 40, RAMP["ember"][2]); rect(cv, 314, 36, 328, 46, RAMP["ember"][2]); rect(cv, 314, 14, 328, 18, CREAM); rect(cv, 314, 28, 322, 31, CREAM)
    weed(cv, 214, 86, 10, rnd, 1); weed(cv, 20, 90, 12, rnd, 1)
    for _ in range(10):
        x = rnd.randint(14, W - 14); pebble_(cv, x, top(x) + rnd.randint(8, 24), rnd.randint(2, 3), 2, rnd.choice([H("#aab0c0"), H("#8c8ca0"), H("#d8c8b0")]), rnd)

def barnacles(cv, cx, cy, rx, ry, n, rnd):
    for _ in range(n):
        a = rnd.random() * 6.28; r = math.sqrt(rnd.random()) * .8
        x, y = int(cx + math.cos(a) * rx * r), int(cy + math.sin(a) * ry * r)
        for dy in range(-3, 1):
            for dx in range(-3 - dy // 2, 4 + dy // 2): cv.put(x + dx, y + dy, CREAM if dx < 1 else RAMP["snow"][1])
        cv.put(x, y - 3, RAMP["stone"][3]); cv.put(x - 1, y - 2, RAMP["stone"][3]); cv.put(x + 1, y - 2, RAMP["stone"][3])
def face(cv, x, y, s=1):
    for ex in (x - 10 * s, x + 10 * s):
        rect(cv, ex, y, ex + 5 * s, y + 7 * s, CREAM); rect(cv, ex + s, y + 2 * s, ex + 4 * s, y + 7 * s, INK); cv.put(ex + s, y + 2 * s, CREAM)
    for k in range(-12 * s, 13 * s): cv.put(x + 2 + k, y + 14 * s - (k * k) // (24 * s) + 6 * s, RAMP["ember"][2]); cv.put(x + 2 + k, y + 15 * s - (k * k) // (24 * s) + 6 * s, RAMP["ember"][3]) if abs(k) < 11 * s else None
def starfish(cv, x, y, c="ember"):
    P = RAMP[c]
    for a in range(5):
        ang = math.radians(-90 + a * 72)
        for k in range(1, 9): disc(cv, x + int(math.cos(ang) * k), y + int(math.sin(ang) * k), max(1, 3 - k // 3), P[1] if k % 3 else P[0])
    disc(cv, x, y, 3, P[1]); cv.put(x, y, P[3])
def lm_barnacles(rnd, cv):   # 270 x 190
    S = r5(RAMP["stone"])
    lump(cv, 48, 148, 46, 38, S, rnd, .1); lump(cv, 224, 152, 44, 34, S, rnd, .1); lump(cv, 135, 104, 74, 80, S, rnd, .1)
    lump(cv, 94, 160, 28, 22, S, rnd, .1)
    for (cx, cy, rx, ry, n) in ((48, 148, 42, 32, 14), (224, 152, 40, 28, 14), (135, 104, 68, 70, 44), (94, 160, 24, 16, 6)): barnacles(cv, cx, cy, rx, ry, n, rnd)
    face(cv, 133, 76, 1)   # smiling face on the big one
    for (fx, fy) in ((36, 134), (219, 138)):   # the little ones smile too
        for ex in (fx - 6, fx + 8): rect(cv, ex, fy, ex + 4, fy + 5, CREAM); cv.put(ex + 1, fy + 1, INK); cv.put(ex + 1, fy + 2, INK); cv.put(ex + 2, fy + 2, INK)
        for k in range(-7, 8): cv.put(fx + 2 + k, fy + 12 - (k * k) // 14, INK)
    for x in range(70, 200, 6):   # tide mark: a pale line of dried salt
        cv.put(x, 132 + (x // 6) % 2, CREAM)
    for k in range(5):   # weed hanging off the big rock like hair
        x = 96 + k * 20; h = rnd.randint(18, 30)
        for j in range(h): cv.put(x + int(math.sin(j / 4.0 + k) * 2), 34 + j, RAMP["pine"][1 if j % 4 else 0]); cv.put(x + 1 + int(math.sin(j / 4.0 + k) * 2), 34 + j, RAMP["pine"][2])
    starfish(cv, 38, 160, "ember"); starfish(cv, 224, 128, "gold")
    crab(cv, 196, 160, 1, rnd)   # a small crab who agrees
    for x in range(8, 262):   # wet foot with weed and foam
        if x % 4 == 0 and cv.get(x, 184)[3] == 0: cv.put(x, 188, RAMP["moss"][2]); cv.put(x, 187, RAMP["moss"][1])
    for x in range(8, 262, 7): cv.put(x, 189, RAMP["sea"][0]); cv.put(x + 1, 189, CREAM)
def lm_shellhollow(rnd, cv):   # 240 x 150
    S = r5(RAMP["stone"])
    mound(cv, 120, 146, 112, 104, S, rnd, .12)   # rocky bank
    for y in range(56, 146):   # scooped hollow
        for x in range(30, 211):
            if ((x - 120) / 80.0) ** 2 + ((y - 118) / 62.0) ** 2 <= 1:
                u = ((x - 120) / 80.0) ** 2 + ((y - 118) / 62.0) ** 2
                t = 3 if y < 84 else 2 if u > .6 else 1 if u > .25 else 0
                cv.put(x, y, RAMP["sand"][t])
    for a in range(0, 360, 14):   # shells lining the rim
        x = 120 + int(math.cos(math.radians(a)) * 80); y = 118 + int(math.sin(math.radians(a)) * 62)
        if y > 60 and a % 28 == 0: spiral(cv, x, y, 4, ["petal", "gold", "snow"][a // 28 % 3])
        elif y > 60: shell(cv, x, y + 3, 4, ["snow", "petal", "gold"][a // 14 % 3], rnd)
    for k in range(4):   # echo arcs from "hello"
        for a in range(-50, 51, 4):
            r = 16 + k * 10; x = 120 + int(math.cos(math.radians(a - 90)) * r); y = 132 + int(math.sin(math.radians(a - 90)) * r * .8)
            cv.put(x, y, CREAM if k % 2 == 0 else RAMP["sea"][0])
    shell(cv, 120, 140, 6, "petal", rnd)
def lm_sandcastle(rnd, cv):   # 230 x 200
    _pond(cv, 115, 178, 108, 17, rnd)
    Sd = r5(RAMP["sand"])
    mound(cv, 115, 182, 82, 20, Sd, rnd, .12)
    def tower(cx, w, top, base):
        _col(cv, cx - w // 2, cx + w // 2, top, base, Sd, rnd, .1)
        for x in range(cx - w // 2, cx + w // 2 + 1, 4): rect(cv, x, top - 6, x + 3, top, Sd[1 if x < cx else 2])   # crenels
        for y in range(top + 12, base, 14): hline(cv, cx - w // 2, cx + w // 2, y, Sd[3])
        rect(cv, cx - 3, base - 18, cx + 3, base, Sd[4]); disc(cv, cx, base - 18, 3, Sd[4])
    for cx, w, top in ((50, 28, 118), (180, 28, 118), (78, 24, 98), (152, 24, 98), (115, 30, 70)):
        tower(cx, w, top, 176)
    _col(cv, 64, 166, 126, 180, Sd, rnd, .1)   # curtain wall
    for x in range(64, 166, 8): rect(cv, x, 120, x + 4, 126, Sd[1 if x < 115 else 2])
    rect(cv, 105, 150, 125, 180, Sd[4]); disc(cv, 115, 150, 10, Sd[4])
    for x in range(106, 125, 3): vline(cv, x, 150, 180, Sd[3])   # portcullis
    tower(115, 30, 70, 126)
    for ty, tx in ((50, 78), (50, 152)): pass
    for tx in (50, 180, 78, 152): disc(cv, tx, 108 if tx in (78, 152) else 126, 0, Sd[0])
    for tx, ty in ((78, 84), (152, 84), (50, 104), (180, 104)):   # cone roofs
        for k in range(14): hline(cv, tx - 14 + k, tx + 14 - k, ty - k + 14 - 14 + 0, RAMP["petal"][1 if k < 8 else 2]) if False else None
    vline(cv, 152, 40, 92, RAMP["wood"][2]); vline(cv, 153, 40, 92, RAMP["wood"][3])
    for k in range(14):   # the flag
        hline(cv, 154, 180 - k // 2, 42 + k, RAMP["ember"][1 if k < 7 else 2])
    hline(cv, 154, 178, 42, RAMP["ember"][0])
    for sx in (-1, 1):
        for k in range(8): cv.put(115 + sx * 20 + sx * k, 188 + k % 2, RAMP["sea"][0])
    crab(cv, 115, 48, 1, rnd, wave=True)   # crab in charge, on the top
    for k in range(8): cv.put(40 + k * 22, 198, RAMP["sea"][0]); cv.put(41 + k * 22, 198, CREAM)
    shell(cv, 25, 192, 4, "petal", rnd); shell(cv, 204, 192, 4, "gold", rnd)

# ------------------------------------------------------------------ 308
def lm_pebblebar(rnd, cv):   # 300 x 170
    PC = [H(h) for h in ("#e86a5c", "#f2b84b", "#7cc0d8", "#a98fd8", "#8fd18a", "#f08fb0", "#fff0d0", "#6f7aa8", "#e0a070", "#3a4a58")]
    mound(cv, 150, 164, 144, 44, r5(RAMP["sand"]), rnd, .08)
    for _ in range(330):
        x = rnd.randint(14, 286); y = rnd.randint(130, 164)
        e = ((x - 150) / 140.0) ** 2 + ((y - 164) / 40.0) ** 2
        if e > .9: continue
        pebble_(cv, x, y, rnd.randint(3, 6), rnd.randint(2, 4), rnd.choice(PC), rnd)
    # tilted pebble mosaic: a rainbow on a sheared slab
    sh = lambda y: int((y - 130) * .28)
    X0, X1, Y0, Y1 = 98, 206, 52, 134
    def inside(x, y): return X0 + sh(y) <= x < X1 + sh(y) and Y0 <= y < Y1
    def slab(x, y):
        u = (x - X0 - sh(y)) / float(X1 - X0); t = 1 if u < .1 else 2 if u < .8 else 3
        if y < Y0 + 2: t = 0
        if y >= Y1 - 4: t = 4
        if (x * 3 + y * 7) % 19 == 0 and t < 3: t += 1
        return r5(RAMP["stone"])[t]
    para(cv, inside, X0 - 40, X1 + 40, Y0, Y1, slab)
    cx0, cy0 = 152, 124
    for i, rr in enumerate(range(40, 6, -6)):
        c = PC[i % 6]
        for a in range(190, 351, 14 if rr > 20 else 24):
            px = cx0 + int(math.cos(math.radians(a)) * rr * 1.15) + sh(int(cy0 + math.sin(math.radians(a)) * rr)); py = cy0 + int(math.sin(math.radians(a)) * rr)
            if Y0 + 4 < py < Y1 - 3: pebble_(cv, px, py, 4, 3, c, rnd)
    for k in range(6): pebble_(cv, 124 + k * 12 + sh(128), 129, 4, 3, PC[(k + 2) % 10], rnd) if False else None
    # three pebble cairns, topped with a tiny gnome hat
    for cx, base, n, w0 in ((46, 152, 6, 20), (250, 150, 7, 22), (92, 162, 4, 14)):
        ty = cairn(cv, cx, base, n, rnd, PC, w0)
        if cx == 46 or cx == 250:
            for k in range(14): hline(cv, cx - 5 + k // 3, cx + 6 - k // 3, ty - 2 - k, RAMP["ember"][1 if k < 7 else 2])
            hline(cv, cx - 7, cx + 8, ty - 2, CREAM)
    cairn(cv, 206, 158, 3, rnd, PC, 12)
    for x, y in ((20, 150), (276, 160)):   # strand of weed on the bar
        weed(cv, x, y, 12, rnd, 1)
    for _ in range(14):   # the white one with a stripe
        x = rnd.randint(30, 270); y = rnd.randint(144, 162); pebble_(cv, x, y, 6, 4, CREAM, rnd); hline(cv, x - 4, x + 5, y, RAMP["stone"][1])
def ribbon(cv, x, y0, ln, w, rnd, ph=0, R=None):
    R = R or RAMP["pine"]
    for k in range(ln):
        xx = x + int(math.sin(k / 7.0 + ph) * 3); ww = w - (k * 2) // max(1, ln // 2) if k > ln - 8 else w
        for dx in range(max(2, ww)):
            t = 0 if dx == 0 else 1 if dx < ww // 2 else 2 if dx < ww - 1 else 3
            if (k + dx) % 9 == 0: t = max(0, t - 1)
            cv.put(xx + dx, y0 + k, R[t])
def float_(cv, x, y, r, c):
    disc(cv, x, y, r, RAMP[c][1]); disc(cv, x - 1, y - 1, max(1, r - 2), RAMP[c][0]); cv.put(x + r // 2, y + r // 2, RAMP[c][3]); hline(cv, x - r + 1, x + r, y + r - 1, RAMP[c][2])
def rack(cv, x0, x1, base, top, rnd, ph):
    W = RAMP["wood"]
    for px in (x0, x1):
        stick(cv, px, base, px + 3, top, 5); stick(cv, px - 10, base, px, top + 14, 3); stick(cv, px + 14, base, px + 4, top + 14, 3)
    for y in range(top, top + 5): hline(cv, x0 - 4, x1 + 9, y, W[0] if y == top else W[1] if y < top + 3 else W[3])
    n = (x1 - x0) // 13
    for i in range(n):
        x = x0 + 8 + i * 13; ln = rnd.randint(40, 64) if i % 2 == 0 else rnd.randint(28, 44)
        ribbon(cv, x, top + 5, ln, 7, rnd, ph + i)
    for x in (x0 - 2, x1 + 5): float_(cv, x, top - 6, 6, "gold" if x < x0 else "ember")
def lm_kelp(rnd, cv):   # 320 x 124
    G = RAMP["pine"]
    rack(cv, 24, 112, 116, 22, rnd, 0)
    rack(cv, 214, 298, 116, 30, rnd, 2)
    for x in range(6, 314):   # the long line of kelp on the ground
        yy = 108 + int(math.sin(x / 11.0) * 3) + int(math.sin(x / 31.0) * 4)
        for y in range(yy - 3, yy + 3): cv.put(x, y, G[1 if y < yy else 2 if y < yy + 2 else 3])
        if x % 17 == 0: disc(cv, x, yy - 5, 4, G[0]); disc(cv, x + 1, yy - 4, 2, G[1])
    # tall centre pole with streamers and a bobbing float on top
    stick(cv, 160, 118, 162, 4, 5)
    for i, (ln, dx, y0) in enumerate(((60, 5, 16), (80, -9, 24), (50, 5, 52), (70, -9, 60))):
        ribbon(cv, 160 + dx, y0, ln, 8, rnd, i * 2)
    float_(cv, 162, 8, 7, "ember"); float_(cv, 148, 100, 7, "gold"); float_(cv, 182, 102, 6, "ember")
    lump(cv, 135, 102, 20, 12, r5(G), rnd, .12); lump(cv, 190, 104, 16, 9, r5(G), rnd, .12)   # heaps
    for x, y in ((130, 98), (196, 100)): disc(cv, x, y, 3, G[0])
def mask_ell(cv, cx, cy, rx, ry):
    for y in range(cv.h):
        for x in range(cv.w):
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 > 1: cv.p[x, y] = (0, 0, 0, 0)
def bollard(cv, x, y, h, rnd):
    S = RAMP["stone"]
    for xx in range(x - 6, x + 7):
        for yy in range(y - h, y):
            u = (xx - x + 6) / 12.0; t = 0 if u < .2 else 1 if u < .45 else 2 if u < .8 else 3
            cv.put(xx, yy, S[t])
    for xx in range(x - 8, x + 9): cv.put(xx, y - h - 1, S[0]); cv.put(xx, y - h, S[1]); cv.put(xx, y - h + 1, S[3])
    hline(cv, x - 6, x + 7, y - h // 2, RAMP["wood"][2]); hline(cv, x - 6, x + 7, y - h // 2 + 1, RAMP["wood"][3]); hline(cv, x - 6, x + 7, y - h // 2 - 1, RAMP["wood"][1])
def lamp(cv, x, y, h, rnd):
    K = [H(c) for c in ("#8a8aa6", "#5d5e7c", "#3f4062", "#2c2d48")]
    for xx in range(x - 2, x + 3):
        for yy in range(y - h, y): cv.put(xx, yy, K[0 if xx == x - 2 else 1 if xx < x + 1 else 3])
    for xx in range(x - 5, x + 6): cv.put(xx, y - 3, K[1]); cv.put(xx, y - 2, K[3])
    stick(cv, x - 1, y - h + 4, x - 12, y - h - 2, 2, K) if False else None
    lx, ly = x, y - h - 12
    rect(cv, lx - 7, ly - 3, lx + 8, ly, K[2]); rect(cv, lx - 6, ly, lx + 7, ly + 14, RAMP["gold"][0]); rect(cv, lx - 4, ly + 2, lx + 5, ly + 12, CREAM)
    for yy in range(ly, ly + 14): cv.put(lx - 6, yy, K[1]); cv.put(lx + 7, yy, K[2]); cv.put(lx, yy, K[1])
    rect(cv, lx - 7, ly + 14, lx + 8, ly + 16, K[2])
    for k in range(5): hline(cv, lx - 5 + k, lx + 7 - k, ly - 4 - k, K[1 if k < 3 else 0])
    disc(cv, lx, ly - 11, 2, RAMP["gold"][1])
def lm_causeway(rnd, cv):   # 330 x 160
    W = 330
    seaband(cv, 4, W - 4, 60, 150, rnd)
    for y in range(60, 150):
        for x in range(4, W - 4):
            e = min(x - 4, W - 5 - x)
            if e < 16 and (y - 60) < (16 - e): cv.p[x, y] = (0, 0, 0, 0)
    for x in range(10, W - 10, 17): waves(cv, x, x + 12, 70 + (x // 17) % 3 * 14, rnd, 1)
    stones = [(28, 104), (68, 100), (108, 106), (148, 100), (188, 106), (228, 100), (268, 104), (306, 100)]
    for i, (x, y) in enumerate(stones):
        lump(cv, x, y, 25, 12, r5(RAMP["stone"]), rnd, .1)
        for k in range(-21, 22, 3): cv.put(x + k, y + 13, CREAM) if (k + i) % 2 else None
        hline(cv, x - 10, x - 3, y - 4, RAMP["stone"][0])
    for x in range(10, W - 10):
        for yy in (66, 138):
            if (x * 3) % 7 < 3: cv.put(x, yy + int(math.sin(x / 8.0) * 2), CREAM)
    mask_ell(cv, 165, 105, 161, 48)
    # rope swagging between bollards
    for bx in (44, 118, 212, 290): bollard(cv, bx, 98, 30, rnd)
    for ax, bx in ((44, 118), (212, 290)):
        for x in range(ax, bx + 1):
            y = 74 + int(math.sin((x - ax) / float(bx - ax) * math.pi) * 14); cv.put(x, y, RAMP["wood"][1]); cv.put(x, y + 1, RAMP["wood"][3])
    for lx in (80, 165, 250): lamp(cv, lx, 96, 62, rnd)
    crab(cv, 148, 86, 1, rnd, wave=True)   # a crab holding the toll
    for x, y in ((10, 100), (320, 104)): weed(cv, x, y, 12, rnd, 1)
def lm_rockpool(rnd, cv):   # 220 x 150
    S = r5(RAMP["stone"])
    mound(cv, 110, 140, 104, 90, S, rnd, .12)
    for y in range(90, 140):
        for x in range(30, 191):
            if ((x - 110) / 72.0) ** 2 + ((y - 118) / 22.0) ** 2 <= 1:
                u = (y - 96) / 44.0; t = 3 if u > .75 else 2 if u > .4 else 1 if u > .12 else 0
                if (x * 5 + y * 3) % 9 == 0: t = max(0, t - 1)
                cv.put(x, y, RAMP["sea"][t])
    for k in range(6): hline(cv, 60 + k * 18, 70 + k * 18, 106 + k % 3 * 5, RAMP["sea"][0])
    crab(cv, 112, 108, 1, rnd, wave=True)
    for a in range(0, 360, 20):   # anemones & weed round the rim
        x = 110 + int(math.cos(math.radians(a)) * 76); y = 118 + int(math.sin(math.radians(a)) * 25)
        if a % 40 == 0: disc(cv, x, y + 1, 3, RAMP["petal"][1]); cv.put(x, y - 3, RAMP["petal"][0]); cv.put(x - 3, y - 1, RAMP["petal"][0]); cv.put(x + 3, y - 1, RAMP["petal"][0])
        else: cv.put(x, y, RAMP["moss"][1]); cv.put(x, y - 1, RAMP["moss"][2]); cv.put(x + 1, y - 2, RAMP["moss"][1])
def lm_tidesteps(rnd, cv):   # 280 x 200
    K = [H(c) for c in ("#8a8aa6", "#5d5e7c", "#3f4062", "#2c2d48", "#201f36")]
    steps = [(20, 112, 120), (66, 112, 150), (112, 112, 100)]
    ys = [150, 120, 90, 60]
    for i in range(4):
        x0 = 14 + i * 56; top = ys[i] if i < 4 else 60; x1 = x0 + 74 if i < 3 else 270
        x1 = min(x1, 268)
        for y in range(top, 196):   # block face
            for x in range(x0, x1):
                if y < top + 10: t = 0 if (x - x0) % 29 > 3 else 1   # lit top face
                else: u = (x - x0) / (x1 - x0); t = 1 if u < .2 else 2 if u < .7 else 3
                if rnd.random() < .08: t = min(4, t + 1)
                cv.put(x, y, K[t])
        for y in range(top + 16, 196, 9): hline(cv, x0 + 3, x1 - 3, y, K[4])
        px = (x0 + x1) // 2
        for y in range(top + 1, top + 8):   # teacup pool on the tread
            for x in range(px - 16, px + 17):
                if ((x - px) / 16.0) ** 2 + ((y - top - 4) / 3.5) ** 2 <= 1: cv.put(x, y, RAMP["sea"][1 if y < top + 4 else 2])
        cv.put(px - 7, top + 3, RAMP["sea"][0]); cv.put(px - 6, top + 3, RAMP["sea"][0])
        if i == 1: crab(cv, px, top - 14, 1, rnd) if False else None
    for sx, sy, c in ((84, 118, "snow"), (140, 82, "petal"), (200, 52, "gold")):   # shell on a step
        spiral(cv, sx, sy, 3, c)
    # sea at the foot
    seaband(cv, 8, 272, 192, 199, rnd); waves(cv, 8, 272, 192, rnd, 1)
    for k in range(4): disc(cv, 40 + k * 56, 143 - k * 30 - 2 + 0, 0, CREAM)
    # little seaweed tuft on the top step
    for k in range(6): vline(cv, 240 + k * 3, 48 - k % 3 * 3, 58, RAMP["moss"][1 + k % 2])

# ------------------------------------------------------------------ 314
def lm_driftwood(rnd, cv):   # 300 x 220
    W = r5(RAMP["wood"]); Wd = RAMP["wood"]
    def log(x0, y0, x1, y1, th):   # thick bent log, thickness th
        n = max(abs(x1 - x0), abs(y1 - y0)) * 2
        for i in range(n + 1):
            x = x0 + (x1 - x0) * i / n; y = y0 + (y1 - y0) * i / n
            for dy in range(-th // 2, th // 2 + 1):
                for dx in range(-th // 2, th // 2 + 1):
                    if dx * dx + dy * dy <= (th // 2) ** 2 + 2:
                        t = 0 if dx + dy < -th // 3 else 1 if dx + dy < 0 else 2 if dx + dy < th // 3 else 3
                        cv.put(int(x) + dx, int(y) + dy, Wd[t] if (int(x) + dy) % 9 else Wd[min(3, t + 1)])
    # sofa (left): back, seat, arms, tired sag
    sx = 6
    rect(cv, sx + 4, 130, sx + 94, 170, Wd[2]); _col(cv, sx + 4, sx + 94, 130, 170, W, rnd, .1)
    lump(cv, sx + 20, 168, 22, 10, W, rnd); lump(cv, sx + 78, 168, 22, 10, W, rnd)
    log(sx + 8, 148, sx + 8, 190, 14); log(sx + 90, 148, sx + 90, 190, 14)
    for cx in (sx + 28, sx + 60): lump(cv, cx, 165, 18, 9, r5(RAMP["petal"]), rnd, .05)   # saggy cushions
    for k in range(10): cv.put(sx + 32 + k, 150 + abs(k - 5) // 2, Wd[3])
    for lx in (sx + 10, sx + 88): rect(cv, lx, 186, lx + 6, 216, Wd[2]); rect(cv, lx, 186, lx + 2, 216, Wd[1])
    # chair (middle)
    cx0 = 118
    log(cx0, 112, cx0, 215, 8); log(cx0 + 40, 112, cx0 + 40, 215, 8)
    for y in (118, 134, 150): log(cx0, y, cx0 + 40, y - 2, 6) if y < 160 else None
    log(cx0 - 4, 170, cx0 + 44, 170, 12)
    log(cx0 + 2, 172, cx0 + 2, 214, 8) if False else None
    for k in range(5): cv.put(cx0 + 8 + k * 6, 100 + k % 2, Wd[0])
    rect(cv, cx0 - 2, 112, cx0 + 4, 116, Wd[3])
    # the dragon (right)
    dx0 = 195
    log(dx0, 214, dx0 + 20, 170, 20); log(dx0 + 20, 170, dx0 + 14, 120, 18); log(dx0 + 14, 120, dx0 + 30, 78, 16); log(dx0 + 30, 78, dx0 + 54, 62, 14)
    log(dx0 + 54, 62, dx0 + 80, 70, 12)
    log(dx0 + 80, 70, dx0 + 96, 80, 8)
    for k in range(5):   # spines
        for j in range(8 - k): cv.put(dx0 + 22 + k * 3 - j // 3, 112 - k * 18 - j, RAMP["gold"][1 + (j > 4)])
    disc(cv, dx0 + 64, 64, 4, CREAM); disc(cv, dx0 + 65, 64, 2, INK)   # eye
    for k in range(7): cv.put(dx0 + 90 + k, 78 + k // 3, RAMP["ember"][1]); cv.put(dx0 + 94 + k, 72 - k, RAMP["ember"][0] if k % 2 else RAMP["gold"][1])   # puff of smoke / fire
    for k in range(5): cv.put(dx0 + 56 + k * 4, 52 - k, Wd[1]); cv.put(dx0 + 56 + k * 4, 51 - k, Wd[1])   # horn
    log(dx0 - 4, 214, dx0 - 30, 200, 10)   # tail curl
    log(dx0 - 30, 200, dx0 - 40, 184, 7)
    log(dx0 + 10, 130, dx0 - 14, 150, 7)   # a stubby arm
    hline(cv, 8, 292, 217, RAMP["sand"][2]) if False else None
def lm_shellpile(rnd, cv):   # 210 x 170
    mound(cv, 105, 166, 98, 100, r5(RAMP["sand"]), rnd, .06)
    cols = ["snow", "petal", "gold", "sand", "dusk"]
    # sorted in rows by colour (strong feelings), spirals on top
    pts = []
    for row in range(10):
        y = 166 - row * 9
        half = int(math.sqrt(max(0, 1 - ((166 - y) / 96.0) ** 2)) * 90)
        for x in range(105 - half + 8, 105 + half - 6, 14):
            pts.append((x + (7 if row % 2 else 0), y, row))
    for x, y, row in sorted(pts, key=lambda p: p[1]):
        if abs(x - 105) > 92 - 0: continue
        c = cols[(x // 14 + row // 2) % 5]
        if row % 3 == 0 or (x // 14) % 2: spiral(cv, x, y - 2, 5, c)
        else: shell(cv, x, y, 6, c, rnd)
    spiral(cv, 105, 76, 8, "petal")   # the favourite
    # sorting stick sign: arrow pointing to spirals
    vline(cv, 188, 120, 166, RAMP["wood"][2]); vline(cv, 189, 120, 166, RAMP["wood"][3])
    rect(cv, 170, 106, 204, 124, RAMP["wood"][0]); hline(cv, 170, 204, 106, RAMP["wood"][3]); hline(cv, 170, 204, 124, RAMP["wood"][3])
    for k in range(8): cv.put(180 + k, 115 - (k if k < 4 else 7 - k), RAMP["ember"][2]) if False else None
    spiral(cv, 187, 115, 4, "petal")
def lm_stepping(rnd, cv):   # 280 x 130
    seaband(cv, 4, 276, 40, 124, rnd)
    for y in range(40, 124):
        for x in range(4, 276):
            e = min(x - 4, 275 - x)
            if e < 18 and (y - 40) < (18 - e) * 2: cv.p[x, y] = (0, 0, 0, 0)
    K = [H(c) for c in ("#8a8aa6", "#5d5e7c", "#3f4062", "#2c2d48", "#201f36")]
    for i, (x, y, rx, ry) in enumerate(((36, 86, 24, 12), (84, 66, 20, 10), (132, 92, 26, 12), (184, 70, 20, 10), (236, 88, 24, 12))):
        lump(cv, x, y, rx, ry, K, rnd, .1)
        for k in range(-rx + 3, rx - 2, 3): cv.put(x + k, y + ry + 1, CREAM) if (k + i) % 2 else None
        hline(cv, x - 8, x - 2, y - 4, K[0])
    for x in range(8, 272, 14): waves(cv, x, x + 9, 56 + (x // 14) % 4 * 14, rnd, 1)
    gull(cv, 132, 78, 1, flip=False)   # one gull watching
    mask_ell(cv, 140, 82, 137, 44)
def lm_lanternrocks(rnd, cv):   # 300 x 270
    S = r5(RAMP["stone"])
    specs = [(70, 262, 40, 150, 200), (232, 262, 40, 130, 220), (150, 262, 52, 200, 150)]
    for (cx, base, rx, ht, top) in sorted(specs, key=lambda s: s[3]):
        pass
    order = [(58, 262, 36, 150), (240, 262, 36, 130), (150, 262, 52, 190)]
    for (cx, base, rx, ht) in order:
        top = base - ht
        for y in range(top, base):   # tapering spire
            u = (y - top) / float(ht); hw = int(rx * (.35 + .65 * u ** .7) + math.sin(y / 9.0) * 3)
            for x in range(cx - hw, cx + hw + 1):
                f = (x - (cx - hw)) / max(1, 2.0 * hw); t = 0 if f < .15 else 1 if f < .35 else 2 if f < .7 else 3
                if (y // 12 + x // 11) % 5 == 0 and f > .3: t = min(4, t + 1)
                if rnd.random() < .08: t = max(0, min(4, t + rnd.choice((-1, 1))))
                cv.put(x, y, S[t])
        lump(cv, cx, top + 2, int(rx * .38), 8, S, rnd, .05)
        lump(cv, cx - rx // 3, base - 4, rx // 2 + 6, 12, S, rnd, .1); lump(cv, cx + rx // 2, base - 4, rx // 2, 11, S, rnd, .1)
        # lantern on a hook at the top: bracket, cage, glow
        ly = top - 20
        vline(cv, cx, top - 6, top + 2, INK)
        rect(cv, cx - 8, ly - 4, cx + 9, ly + 22, RAMP["wood"][3])
        rect(cv, cx - 6, ly, cx + 7, ly + 19, RAMP["gold"][0])
        for yy in range(ly, ly + 19):
            for xx in range(cx - 6, cx + 7):
                d = abs(xx - cx) + abs(yy - ly - 9) * .6
                cv.put(xx, yy, RAMP["gold"][0] if d < 4 else RAMP["gold"][1] if d < 7 else RAMP["gold"][2])
        vline(cv, cx, ly, ly + 19, RAMP["wood"][3]); hline(cv, cx - 6, cx + 7, ly + 9, RAMP["wood"][3])
        for k in range(10): hline(cv, cx - 10 + k, cx + 11 - k, ly - 5 - k // 1 + 0 if False else ly - 5 - k, RAMP["ember"][1 if k < 5 else 2]) if k < 7 else None
        rect(cv, cx - 1, ly - 14, cx + 2, ly - 11, RAMP["ember"][3]) if False else None
        for k in range(3):   # humming notes
            nx, ny = cx + 16 + k * 8, ly - 4 - k * 9
            disc(cv, nx, ny + 6, 2, CREAM); vline(cv, nx + 2, ny - 3, ny + 6, CREAM); cv.put(nx + 3, ny - 3, CREAM); cv.put(nx + 4, ny - 2, CREAM)
        for x in range(cx - rx, cx + rx, 5): cv.put(x, base + 1, CREAM) if False else None
        for x in range(cx - rx - 12, cx + rx + 12, 6): cv.put(x, base - 1, RAMP["sea"][0]); cv.put(x + 1, base - 1, CREAM)
    # barnacle crust and sea-foam dots
    for k in range(10):
        x = rnd.randint(30, 270); y = rnd.randint(236, 258)
        if cv.get(x, y)[3] and cv.get(x, y) != INK: cv.put(x, y, CREAM); cv.put(x + 1, y, CREAM)
def lm_gullparliament(rnd, cv):   # 300 x 250
    S = r5(RAMP["stone"])
    # stepped rock like benches/tiers
    tiers = [(150, 248, 140, 40), (150, 208, 112, 40), (150, 168, 86, 40), (150, 128, 58, 36)]
    for (cx, base, rx, ht) in tiers:
        top = base - ht
        for y in range(top, base):
            for x in range(cx - rx, cx + rx + 1):
                f = (x - (cx - rx)) / (2.0 * rx); r = (y - top)
                if y < top + 6: t = 0 if f < .5 else 1
                else: t = 1 if f < .15 else 2 if f < .55 else 3
                if rnd.random() < .08: t = max(0, min(4, t + rnd.choice((-1, 1))))
                cv.put(x, y, S[t])
        for k in range(rx * 2 // 24 + 1): vline(cv, cx - rx + 10 + k * 24, top + 8, base - 2, S[4])
    # gulls in rows
    rows = [(246, 140, 7), (206, 112, 6), (166, 84, 5)]
    for (ry, rx, n) in rows:
        for i in range(n):
            x = 150 - rx + 18 + i * (2 * rx - 36) // max(1, n - 1)
            gull(cv, x, ry - 40 + 8, 1, flip=(x > 150), open_beak=(i + ry) % 4 == 0)
    # podium and the chairgull on top
    rect(cv, 128, 100, 172, 124, RAMP["wood"][1]); _col(cv, 128, 172, 100, 124, r5(RAMP["wood"]), rnd, .05)
    rect(cv, 128, 98, 172, 101, RAMP["wood"][0]); hline(cv, 128, 172, 124, RAMP["wood"][3])
    gull(cv, 150, 98, 2, flip=False, open_beak=True)
    # tiny wig, gavel
    for x in range(138, 163): cv.put(x, 66 + abs(x - 150) // 3 * 0 + (x % 3 == 0), CREAM) if False else None
    rect(cv, 168, 90, 180, 96, RAMP["wood"][2]); vline(cv, 174, 96, 100, RAMP["wood"][3])
    # banners / flags
    for fx, c in ((34, "ember"), (266, "petal")):
        vline(cv, fx, 128, 210, RAMP["wood"][2]); vline(cv, fx + 1, 128, 210, RAMP["wood"][3])
        for k in range(18): hline(cv, fx + 2, fx + 24 - k // 3, 130 + k, RAMP[c][1 if k < 9 else 2])
    for k in range(6):   # speech squiggles
        x = 120 + k * 12; cv.put(x, 36 - (k % 2) * 4, CREAM); cv.put(x + 1, 36 - (k % 2) * 4, CREAM)
    for x in range(20, 282, 7): cv.put(x, 249, RAMP["sea"][0]); cv.put(x + 1, 249, CREAM)

LM = {
 "307-tideline": (330, 124, lm_tideline),
 "307-barnacles": (270, 190, lm_barnacles),
 "307-shellhollow": (240, 150, lm_shellhollow),
 "307-sandcastle": (230, 200, lm_sandcastle),
 "308-pebblebar": (300, 170, lm_pebblebar),
 "308-kelpline": (320, 124, lm_kelp),
 "308-rockpool": (220, 150, lm_rockpool),
 "308-tidesteps": (280, 200, lm_tidesteps),
 "314-driftwood": (300, 220, lm_driftwood),
 "314-shellpile": (210, 170, lm_shellpile),
 "314-causeway": (330, 160, lm_causeway),
 "314-steppingrocks": (280, 130, lm_stepping),
 "314-lanternrocks": (300, 270, lm_lanternrocks),
 "314-gullparliament": (300, 250, lm_gullparliament),
}
