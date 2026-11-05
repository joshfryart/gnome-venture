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
def lm_tideline(rnd, cv):   # 300 x 90
    W, Hh = 300, 90
    for y in range(40, 82):   # curved wet-sand band
        for x in range(4, 296):
            top = 40 + int(math.sin(x / 38.0) * 7); bot = 70 + int(math.sin(x / 38.0 + 1) * 6)
            if y < top or y > bot: continue
            e = min(x - 4, 295 - x)
            if e < 12 and (y - top) * 12 < (12 - e) * (bot - top): continue
            t = 1 if y < top + 5 else 2 if y < bot - 8 else 3
            if (x * 7 + y * 3) % 13 == 0: t = max(0, t - 1)
            cv.put(x, y, RAMP["sand"][t])
    for x in range(6, 294):   # foam edge
        top = 40 + int(math.sin(x / 38.0) * 7)
        if x % 5 != 0: cv.put(x, top, CREAM); cv.put(x, top + 1, RAMP["sea"][0] if x % 2 else CREAM)
    cols = ["gold", "petal", "sand", "snow", "ember", "dusk"]
    n = 0
    for x in range(18, 284, 15):   # the long line of shells
        y = 60 + int(math.sin(x / 38.0 + .5) * 6) + rnd.randint(-3, 3); n += 1
        if n % 3 == 0: spiral(cv, x, y, 4, cols[n % 6])
        else: shell(cv, x, y, 5 if n % 2 else 4, cols[n % 6], rnd)
    for x in range(10, 292, 5): cv.put(x, 74 + int(math.sin(x / 38.0 + 1) * 6) + (x % 3), RAMP["sand"][3])
    for k in range(7):   # tiny pebbles + a seaweed strand
        x = rnd.randint(14, 286); hline(cv, x, x + 3, 50 + int(math.sin(x / 38.0) * 7) + rnd.randint(2, 6), RAMP["stone"][2])
    cv.put(0, 0, (0, 0, 0, 0))

def barnacles(cv, cx, cy, rx, ry, n, rnd):
    for _ in range(n):
        a = rnd.random() * 6.28; r = math.sqrt(rnd.random()) * .8
        x, y = int(cx + math.cos(a) * rx * r), int(cy + math.sin(a) * ry * r)
        for dy in range(-3, 1):
            for dx in range(-3 - dy // 2, 4 + dy // 2): cv.put(x + dx, y + dy, CREAM if dx < 1 else RAMP["snow"][1])
        cv.put(x, y - 3, RAMP["stone"][3]); cv.put(x - 1, y - 2, RAMP["stone"][3]); cv.put(x + 1, y - 2, RAMP["stone"][3])
def lm_barnacles(rnd, cv):   # 200 x 150
    S = r5(RAMP["stone"])
    lump(cv, 50, 108, 42, 34, S, rnd, .1); lump(cv, 150, 112, 44, 30, S, rnd, .1); lump(cv, 100, 80, 52, 50, S, rnd, .1)
    for (cx, cy, rx, ry, n) in ((50, 108, 38, 28, 10), (150, 112, 40, 24, 10), (100, 80, 46, 42, 22)): barnacles(cv, cx, cy, rx, ry, n, rnd)
    for (ex, ey) in ((86, 66), (114, 66)):   # smiling face on the big one
        rect(cv, ex, ey, ex + 5, ey + 7, CREAM); rect(cv, ex + 1, ey + 2, ex + 4, ey + 7, INK)
    for k in range(-14, 15): cv.put(100 + k, 90 + (k * k) // 28 * -1 + 7, RAMP["ember"][2]); cv.put(100 + k, 91 + 7 - (k * k) // 28, RAMP["ember"][3]) if abs(k) < 13 else None
    for (ex, ey) in ((38, 98), (60, 98)): rect(cv, ex, ey, ex + 3, ey + 4, CREAM); cv.put(ex + 1, ey + 1, INK); cv.put(ex + 1, ey + 2, INK)
    for k in range(-6, 7): cv.put(49 + k, 112 + (k * k) // 12 * -1 + 3, INK)
    for (ex, ey) in ((138, 102), (160, 102)): rect(cv, ex, ey, ex + 3, ey + 4, CREAM); cv.put(ex + 1, ey + 1, INK); cv.put(ex + 1, ey + 2, INK)
    for k in range(-6, 7): cv.put(149 + k, 116 + (k * k) // 12 * -1 + 3, INK)
    for x in range(10, 190):   # wet foot with weed
        if x % 4 == 0 and cv.get(x, 140)[3] == 0: cv.put(x, 148, RAMP["moss"][2]); cv.put(x, 147, RAMP["moss"][1])
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
def lm_pebblebar(rnd, cv):   # 290 x 90
    mound(cv, 145, 86, 138, 34, r5(RAMP["sand"]), rnd, .08)
    cols = [H(h) for h in ("#e86a5c", "#f2b84b", "#7cc0d8", "#a98fd8", "#8fd18a", "#f08fb0", "#fff0d0", "#6f7aa8", "#e0a070", "#3a4a58")]
    for _ in range(230):
        x = rnd.randint(14, 276); y = rnd.randint(60, 86)
        e = ((x - 145) / 134.0) ** 2 + ((y - 86) / 28.0) ** 2
        if e > .9: continue
        pebble_(cv, x, y, rnd.randint(3, 6), rnd.randint(2, 4), rnd.choice(cols), rnd)
    for _ in range(14):   # the white one with a stripe
        x = rnd.randint(30, 260); y = rnd.randint(68, 84); pebble_(cv, x, y, 6, 4, CREAM, rnd); hline(cv, x - 4, x + 5, y, RAMP["stone"][1])
def lm_kelp(rnd, cv):   # 300 x 100
    G = [RAMP["pine"][0], RAMP["pine"][1], RAMP["pine"][2], RAMP["pine"][3]]
    for x in range(6, 294):
        yy = 74 + int(math.sin(x / 11.0) * 4) + int(math.sin(x / 31.0) * 6)
        for y in range(yy - 3, yy + 3): cv.put(x, y, G[1 if y < yy else 2 if y < yy + 2 else 3])
        if x % 11 == 0:   # bladders
            disc(cv, x, yy - 5, 4, G[0]); disc(cv, x + 1, yy - 4, 2, G[1])
            for k in range(5): cv.put(x + k // 2, yy - 10 - k, G[1])
        if x % 7 == 2:   # frills
            for k in range(10): cv.put(x + (k * 2) // 3 * (1 if x % 2 else -1), yy - 4 - k // 2, G[1 + k % 2])
    for x in range(10, 290, 3): cv.put(x, 82 + int(math.sin(x / 11.0) * 3), RAMP["sand"][3])   # dribble of sea
    for fx in (60, 150, 235):   # tiny gull that's trying not to eat it
        pass
    # polite sign: a stick with a "do not eat" cross
    vline(cv, 150, 30, 78, RAMP["wood"][2]); vline(cv, 151, 30, 78, RAMP["wood"][3])
    rect(cv, 136, 22, 166, 44, RAMP["wood"][0]); hline(cv, 136, 166, 22, RAMP["wood"][3]); hline(cv, 136, 166, 44, RAMP["wood"][3]); vline(cv, 136, 22, 44, RAMP["wood"][3]); vline(cv, 165, 22, 44, RAMP["wood"][3])
    for k in range(14): cv.put(144 + k, 28 + k, RAMP["ember"][1]); cv.put(145 + k, 28 + k, RAMP["ember"][2]); cv.put(158 - k, 28 + k, RAMP["ember"][1]); cv.put(157 - k, 28 + k, RAMP["ember"][2])
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
def mask_ell(cv, cx, cy, rx, ry):
    for y in range(cv.h):
        for x in range(cv.w):
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 > 1: cv.p[x, y] = (0, 0, 0, 0)
def lm_causeway(rnd, cv):   # 300 x 110
    seaband(cv, 4, 296, 40, 100, rnd)
    for y in range(40, 100): 
        for x in range(4, 296):
            e = min(x - 4, 295 - x)
            if e < 14 and (y - 40) < (14 - e): cv.p[x, y] = (0, 0, 0, 0)
    for x in range(10, 290, 17): waves(cv, x, x + 12, 50 + (x // 17) % 3 * 12, rnd, 1)
    stones = [(26, 70), (62, 66), (100, 72), (138, 66), (176, 72), (214, 66), (252, 70)]
    for i, (x, y) in enumerate(stones):
        lump(cv, x, y, 24, 11, r5(RAMP["stone"]), rnd, .1)
        for k in range(-20, 21, 3): cv.put(x + k, y + 12, CREAM) if (k + i) % 2 else None
        hline(cv, x - 10, x - 3, y - 3, RAMP["stone"][0])
    for x, y in ((12, 52), (282, 50)):   # lapping foam along both edges
        pass
    for x in range(10, 290):
        for yy in (45, 92):
            if (x * 3) % 7 < 3: cv.put(x, yy + int(math.sin(x / 8.0) * 2), CREAM)
    mask_ell(cv, 150, 70, 147, 34)
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
 "307-tideline": (300, 90, lm_tideline),
 "307-barnacles": (200, 150, lm_barnacles),
 "307-shellhollow": (240, 150, lm_shellhollow),
 "307-sandcastle": (230, 200, lm_sandcastle),
 "308-pebblebar": (290, 90, lm_pebblebar),
 "308-kelpline": (300, 100, lm_kelp),
 "308-rockpool": (220, 150, lm_rockpool),
 "308-tidesteps": (280, 200, lm_tidesteps),
 "314-driftwood": (300, 220, lm_driftwood),
 "314-shellpile": (210, 170, lm_shellpile),
 "314-causeway": (300, 110, lm_causeway),
 "314-steppingrocks": (280, 130, lm_stepping),
 "314-lanternrocks": (300, 270, lm_lanternrocks),
 "314-gullparliament": (300, 250, lm_gullparliament),
}
