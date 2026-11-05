"""Grassland landmarks for routes 232, 236 and 311 (see gen2.py for the look: hard pixels, ramps, lump shading, auto outline)."""
import random, math
import gen2
from gen2 import RAMP, INK, CREAM, Cv, lump, r5, outline, trunk, leaf_texture, darker, mix, H, T, _col, _pond, _reeds
from PIL import Image, ImageDraw

W5, S5, G5, M5, L5 = r5(RAMP["wood"]), r5(RAMP["stone"]), r5(RAMP["gold"]), r5(RAMP["moss"]), r5(RAMP["leaf"])
E5, P5, A5, SEA5, D5, LT5 = r5(RAMP["ember"]), r5(RAMP["petal"]), r5(RAMP["sand"]), r5(RAMP["sea"]), r5(RAMP["dusk"]), r5(RAMP["litter"])
CLEAR = (0, 0, 0, 0)

def fillmask(cv, drawfn, fn):
    m = Image.new("L", cv.im.size, 0); drawfn(ImageDraw.Draw(m)); bb = m.getbbox()
    if not bb: return
    mp = m.load()
    for y in range(bb[1], bb[3]):
        for x in range(bb[0], bb[2]):
            if mp[x, y]: cv.put(x, y, fn(x, y))
def poly(cv, pts, c): fillmask(cv, lambda d: d.polygon(pts, fill=255), lambda x, y: c)
def ell(cv, cx, cy, rx, ry, c): fillmask(cv, lambda d: d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=255), lambda x, y: c)
def rect(cv, x0, y0, x1, y1, c):
    for y in range(y0, y1):
        for x in range(x0, x1): cv.put(x, y, c)
def line(cv, x0, y0, x1, y1, c, w=1):
    n = int(max(abs(x1 - x0), abs(y1 - y0), 1))
    for i in range(n + 1):
        x = x0 + (x1 - x0) * i / n; y = y0 + (y1 - y0) * i / n
        for dx in range(w):
            for dy in range(w): cv.put(int(round(x)) + dx - w // 2, int(round(y)) + dy - w // 2, c)
def hline(cv, x0, x1, y, c):
    for x in range(x0, x1): cv.put(x, y, c)
def hsh(u): return 0 if u < .15 else 1 if u < .4 else 2 if u < .72 else 3
def box(cv, x0, x1, y0, y1, R, rnd, speck=.06): _col(cv, x0, x1, y0, y1, R, rnd, speck)
def planks(cv, x0, x1, y0, y1, R, rnd, pw=9):
    for x in range(x0, x1):
        k = (x - x0) // pw; u = (x - x0) / max(1, x1 - x0 - 1); t = min(3, hsh(u) + (1 if k % 3 == 1 else 0) - (1 if k % 4 == 2 and u > .3 else 0)); t = max(0, t)
        for y in range(y0, y1):
            c = R[t]
            if (x - x0) % pw == 0: c = R[3]
            elif (x * 7 + y * 3) % 23 == 0: c = R[min(4, t + 1)]
            cv.put(x, y, c)
def tufts(cv, rnd, x0, x1, y, n, R=None):
    R = R or M5
    for _ in range(n):
        x = rnd.randint(x0, x1); h = rnd.randint(4, 9); l = rnd.choice((-1, 0, 1))
        for k in range(h): cv.put(x + (k * l) // 3, y - k, R[1 if k > h // 2 else 2]); cv.put(x + 1 + (k * l) // 3, y - k, R[2])
def flower(cv, x, y, c1, c2=None, r=2):
    c2 = c2 or G5[1]
    for dx, dy in ((-r, 0), (r, 0), (0, -r), (0, r), (-1, -1), (1, 1), (-1, 1), (1, -1)):
        if abs(dx) + abs(dy) <= r + 1: cv.put(x + dx, y + dy, c1)
    cv.put(x, y, c2); cv.put(x + 1, y, c2)
def disc(cv, cx, cy, r, R, rnd=None):
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r, cx + r + 1):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r * r + r:
                d = ((x - cx) + (y - cy)) / (2.0 * r); cv.put(x, y, R[0 if d < -.5 else 1 if d < -.1 else 2 if d < .45 else 3])
def bee(cv, x, y):
    for dx in range(4): cv.put(x + dx, y, G5[1] if dx % 2 == 0 else INK); cv.put(x + dx, y + 1, G5[1] if dx % 2 == 0 else INK)
    cv.put(x + 1, y - 1, CREAM); cv.put(x + 2, y - 2, CREAM); cv.put(x + 3, y - 1, CREAM)
def sparrow(cv, cx, cy, s, rnd, beak=False):
    R = r5(RAMP["litter"]); lump(cv, cx, cy, 6 * s, 5 * s, R, rnd, 0)
    for dx in range(-3 * s, 3 * s): cv.put(cx + dx, cy + 3 * s, CREAM)
    ell(cv, cx, cy + 2 * s, 3 * s, 2 * s, CREAM)
    cv.put(cx - 2 * s, cy - s, INK); cv.put(cx - 2 * s - 1, cy - s, INK)
    for k in range(s * 2 + 1): cv.put(cx - 6 * s - k, cy - (s if beak else 0) + (k if beak else 0) // 2, G5[1])
    for k in range(s * 3): cv.put(cx + 5 * s + k, cy + 1 + k // 2, R[3])
def sparkle(cv, x, y):
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)): cv.put(x + dx, y + dy, CREAM)

# ------------------------------------------------------------------ 232
def skep(cv, rnd, cx, base, rx, ry, label=False):
    for sx in (-rx // 2, rx // 2): rect(cv, cx + sx - 3, base - 12, cx + sx + 3, base, W5[2]); rect(cv, cx + sx - 3, base - 12, cx + sx - 1, base, W5[1])
    rect(cv, cx - rx - 4, base - 16, cx + rx + 4, base - 11, W5[1]); rect(cv, cx - rx - 4, base - 12, cx + rx + 4, base - 10, W5[3])
    cy = base - 16 - ry + 6
    lump(cv, cx, cy, rx, ry, G5, rnd, .1)
    top = cy - ry
    for k in range(1, 6):   # coiled straw bands
        y = top + k * (2 * ry) // 6
        for x in range(cx - rx, cx + rx + 1):
            if cv.get(x, y)[3] and cv.get(x, y) != INK: cv.put(x, y, G5[3] if x > cx - rx // 2 else G5[2]); cv.put(x, y + 1, G5[2]) if x > cx else None
    ell(cv, cx, base - 28, rx // 4 + 1, rx // 5 + 3, INK)
    for dx in range(-rx // 4 - 1, rx // 4 + 2): cv.put(cx + dx, base - 28 - rx // 5 - 3, W5[1])
    for k in range(5): cv.put(cx - 1 + k, top, G5[0])
    return cy
def lm_beehive(rnd, cv):   # 250 x 210
    ell(cv, 125, 200, 118, 7, M5[2]); tufts(cv, rnd, 10, 240, 204, 36)
    skep(cv, rnd, 52, 196, 34, 32); skep(cv, rnd, 198, 198, 34, 34); skep(cv, rnd, 125, 200, 50, 54)
    # hand-lettered sign the bees cannot spell
    rect(cv, 124, 150, 128, 200, W5[2]); rect(cv, 106, 124, 108 + 38, 150, W5[0]); rect(cv, 106, 150, 144, 152, W5[3])
    for i, x in enumerate(range(110, 140, 4)): cv.put(x, 134 + (i % 2) * 3, INK); cv.put(x + 1, 135 + (i % 2) * 3, INK); cv.put(x + 2, 136 - (i % 3), INK)
    for k in range(10): cv.put(113 + k * 2, 144, INK)
    for _ in range(14):
        x, y = rnd.randint(10, 230), rnd.randint(70, 150); bee(cv, x, y)
        for k in range(rnd.randint(2, 5)): cv.put(x - 6 - k * 4, y + 3 + (k % 2), G5[0]) if k % 2 == 0 else None
    for x in (20, 90, 160, 228): flower(cv, x, 188 + (x % 7), D5[1] if x % 2 else P5[1]); line(cv, x, 190, x, 202, M5[2])
def lm_berrypatch(rnd, cv):   # 240 x 130
    ell(cv, 120, 124, 112, 6, M5[2]); tufts(cv, rnd, 10, 230, 126, 20)
    for cx, cy, rx, ry in ((70, 80, 50, 40), (160, 76, 56, 44), (115, 62, 48, 40), (120, 98, 70, 28)): lump(cv, cx, cy, rx, ry, L5, rnd, .1)
    leaf_texture(cv, L5, rnd, 300)
    n = 0
    for _ in range(300):
        x, y = rnd.randrange(40, 200), rnd.randrange(34, 112)
        if n >= (34) or not cv.get(x, y)[3]: continue
        right = x > 120 or rnd.random() < .12   # the left half has been plundered
        if not right: continue
        if all(cv.get(x + dx, y + dy)[3] and cv.get(x + dx, y + dy) not in E5 for dx in range(-1, 7) for dy in range(-1, 7)):
            n += 1; disc(cv, x + 3, y + 3, 3, E5); cv.put(x + 2, y + 2, CREAM)
    for x, y in ((50, 84), (66, 70), (88, 90), (100, 60)):   # nibbled leaves
        for dx in range(5):
            for dy in range(4): cv.put(x + dx, y + dy, L5[4]) if (dx + dy) % 2 == 0 or dx > 2 else None
    # the culprit: a mouse in an acorn-cap hat, purple around the mouth
    G = r5(RAMP["stone"]); mx, my = 186, 112
    for k in range(14): cv.put(mx + 12 + k, my + 6 + int(3 * math.sin(k / 2.5)), P5[2])
    lump(cv, mx, my, 12, 10, G, rnd, 0); lump(cv, mx - 10, my - 2, 7, 6, G, rnd, 0)
    for ex, ey in ((mx - 12, my - 12), (mx - 3, my - 12)): lump(cv, ex, ey, 4, 4, G, rnd, 0); ell(cv, ex, ey + 1, 2, 2, P5[0])
    cv.put(mx - 14, my - 3, INK); cv.put(mx - 15, my - 3, INK); cv.put(mx - 18, my, INK); cv.put(mx - 17, my, INK)
    for dx in range(-17, -9): cv.put(mx + dx, my + 3, D5[2])
    disc(cv, mx - 8, my + 6, 4, E5); cv.put(mx - 9, my + 4, CREAM)
    lump(cv, mx - 6, my - 9, 6, 3, W5, rnd, 0); cv.put(mx - 6, my - 13, W5[3])
    for k in range(5): cv.put(30 + k * 12, 118 + (k % 2) * 2, W5[3]); cv.put(31 + k * 12, 118 + (k % 2) * 2, W5[2])   # tiny footprints
def lm_logbridge(rnd, cv):   # 300 x 160
    _pond(cv, 150, 124, 140, 26, rnd); _reeds(cv, 6, 128, 4, rnd); _reeds(cv, 270, 128, 4, rnd)
    # log, lit from the top
    def log_col(x, y):
        u = (y - 34) / 62.0
        t = 0 if u < .18 else 1 if u < .45 else 2 if u < .75 else 3
        if u < .2: return M5[0 if (x // 3) % 3 else 1] if u > .04 else M5[0]
        if (x * 5 + y * 11) % 29 == 0 or (x % 17 == 0 and 6 < y % 9): t = min(4, t + 1)
        return W5[t]
    fillmask(cv, lambda d: d.rounded_rectangle((38, 34, 270, 96), 18, fill=255), log_col)
    for x in range(60, 260):
        if (x // 7) % 2: cv.put(x, 36 + (x * 3) % 5, M5[1]); cv.put(x, 37 + (x * 3) % 5, M5[2])
    for y in (56, 70, 82): [cv.put(x, y, W5[3]) for x in range(70 + y, 130 + y, 2)]
    ell(cv, 54, 65, 18, 31, W5[0]); ell(cv, 54, 65, 15, 27, W5[2]); ell(cv, 54, 65, 11, 22, W5[1]); ell(cv, 54, 65, 8, 16, W5[2]); ell(cv, 54, 65, 5, 10, INK)   # the hollow
    ell(cv, 56, 70, 4, 6, INK); rect(cv, 52, 72, 58, 82, INK)
    for r, c in ((14, W5[3]), (18, W5[3])): [cv.put(54 + int(r * .6 * math.cos(a / 20)), 65 + int(r * 1.5 * math.sin(a / 20)), c) for a in range(0, 126)]
    for mx_, my_, s in ((200, 36, 1), (212, 38, 1), (110, 36, 2)):   # shelf mushrooms
        lump(cv, mx_, my_, 7 * s, 4 * s, E5, rnd, 0); rect(cv, mx_ - 1, my_ + 3 * s - 1, mx_ + 2, my_ + 3 * s + 3, CREAM)
        for k in range(3): cv.put(mx_ - 3 + k * 3, my_ - 1, CREAM)
    for bx in (6, 230):   # banks
        lump(cv, bx + 28, 104, 34, 16, M5, rnd, .08)
    for x in (250, 270): flower(cv, x, 96, CREAM)
    tufts(cv, rnd, 10, 290, 98, 10)
def lm_well(rnd, cv):   # 180 x 240
    box(cv, 38, 46, 56, 146, W5, rnd); box(cv, 134, 142, 56, 146, W5, rnd)
    # roof, gabled
    for y in range(14, 62):
        hw = (y - 14) * 74 // 48 + 6
        for x in range(90 - hw, 90 + hw + 1):
            col = E5[0 if x < 60 else 1 if x < 92 else 2]
            if (y // 6) % 2 == 0 and (x + (y // 6) * 5) % 10 == 0 or y % 6 == 5: col = E5[3]
            cv.put(x, y, col)
    for x in range(14, 168): cv.put(x, 62, W5[3]); cv.put(x, 61, W5[2]) if 20 < x < 160 else None
    rect(cv, 40, 70, 140, 76, W5[2]); rect(cv, 40, 70, 140, 71, W5[0])
    for y in range(76, 120): cv.put(90, y, CREAM); cv.put(91, y, A5[2])   # rope
    box(cv, 76, 106, 118, 140, W5, rnd); rect(cv, 76, 122, 106, 124, W5[3]); rect(cv, 76, 134, 106, 136, W5[3])
    for x in range(78, 106): cv.put(x, 118, W5[3])
    # the well: round, bricked, with a wooden lid
    def brick(x, y):
        u = (x - 20) / 140.0; t = hsh(u); row = (y - 140) // 11
        if (y - 140) % 11 == 0 or (x + (row % 2) * 9) % 18 == 0: return S5[3]
        if (x * 3 + y * 5) % 13 == 0: t = min(4, t + 1)
        return S5[t]
    fillmask(cv, lambda d: (d.rectangle((20, 146, 160, 228), fill=255)), brick)
    ell(cv, 90, 146, 70, 18, S5[0]); ell(cv, 90, 146, 62, 14, S5[2])
    fillmask(cv, lambda d: d.ellipse((30, 134, 150, 158), fill=255), lambda x, y: W5[0 if (x - 36) % 10 > 1 and y < 142 else 1 if (x - 36) % 10 > 1 else 3] if (x - 36) % 10 else W5[3])
    ell(cv, 90, 144, 6, 3, INK); ell(cv, 90, 143, 4, 2, S5[1])   # knocker ring
    for dy in range(-2, 3): cv.put(90 + dy * 0, 150 + dy, S5[0])
    for y in range(228, 232): [cv.put(x, y, M5[2]) for x in range(8, 172) if (x + y) % 3]
    for mx_, my_ in ((30, 190), (118, 210), (60, 220)): lump(cv, mx_, my_, 7, 4, M5, rnd, 0)
    # polite reply: a speech bubble
    ell(cv, 148, 104, 18, 11, CREAM); rect(cv, 134, 112, 138, 124, CREAM)
    for k in range(3): rect(cv, 140 + k * 7, 103, 143 + k * 7, 106, INK)
    for k in range(4): cv.put(150 + k * 3, 232 - k % 2, M5[1])
def lm_crossroads(rnd, cv):   # 220 x 240
    ell(cv, 110, 224, 104, 12, M5[2]); ell(cv, 110, 224, 70, 7, A5[2])
    for sx, sy, rx, ry in ((30, 226, 28, 5), (190, 226, 28, 5), (74, 233, 26, 4), (146, 233, 26, 4)): ell(cv, sx, sy, rx, ry, A5[1])
    for _ in range(80):
        x = rnd.randint(14, 206); y = rnd.randint(214, 236)
        if cv.get(x, y)[3]:
            for dx, dy in ((-2, 0), (2, 0), (0, -2)): cv.put(x + dx, y + dy, M5[0])
            cv.put(x, y, M5[1])
    for x in (20, 60, 168, 196): flower(cv, x, 220 + x % 9, CREAM, G5[1], 1)
    box(cv, 104, 118, 40, 228, W5, rnd, .05)
    arms = ((38, 1, 82, "apple"), (80, -1, 94, "cheese"), (122, 1, 70, "cake"), (164, -1, 84, "pie"))
    for y, d, ln, icon in arms:
        x0, x1 = (111, 111 + ln) if d == 1 else (111 - ln, 111)
        bx = 22 if d == 1 else 22
        pts = [(x0, y), (x1 - 12, y), (x1, y + 11), (x1 - 12, y + 22), (x0, y + 22)] if d == 1 else [(x1, y), (x0 + 12, y), (x0, y + 11), (x0 + 12, y + 22), (x1, y + 22)]
        fillmask(cv, lambda dr: dr.polygon(pts, fill=255), lambda x, yy: W5[0] if yy < y + 3 else W5[1] if yy < y + 12 else W5[2] if yy < y + 20 else W5[3])
        ix = x0 + 14 if d == 1 else x1 - 14
        if icon == "apple": disc(cv, ix + 4, y + 11, 5, E5); cv.put(ix + 4, y + 5, M5[1]); cv.put(ix + 5, y + 5, M5[0])
        if icon == "cheese": poly(cv, [(ix - 2, y + 17), (ix + 12, y + 17), (ix + 12, y + 7)], G5[0]); [cv.put(ix + 6, y + 14, INK), cv.put(ix + 9, y + 11, INK)]
        if icon == "cake": rect(cv, ix, y + 10, ix + 12, y + 17, P5[1]); rect(cv, ix, y + 8, ix + 12, y + 10, CREAM); rect(cv, ix + 5, y + 3, ix + 7, y + 8, G5[0])
        if icon == "pie": ell(cv, ix + 6, y + 14, 7, 3, G5[2]); ell(cv, ix + 6, y + 11, 6, 3, G5[1]); [cv.put(ix + 3 + k * 3, y + 10, G5[3]) for k in range(3)]
        for k in range(3): cv.put(x0 + 5 + k * 4 if d == 1 else x1 - 5 - k * 4, y + 3, W5[0])
    for dx, dy, r in ((0, 0, 8), (-9, 8, 7), (9, 8, 7)): lump(cv, 111 + dx, 24 + dy - 4, r, r, L5, rnd, 0)   # clover finial
    rect(cv, 109, 30, 114, 42, W5[2]); leaf_texture(cv, L5, rnd, 14)
def lm_picnicrise(rnd, cv):   # 300 x 150
    lump(cv, 150, 132, 148, 96, M5, rnd, .1); leaf_texture(cv, M5, rnd, 220); tufts(cv, rnd, 40, 260, 56, 6)
    for y in range(142, 150): [cv.put(x, y, CLEAR) for x in range(0, 300)]
    ell(cv, 150, 62, 72, 16, M5[1]); ell(cv, 150, 66, 72, 14, M5[0]); ell(cv, 150, 69, 66, 11, M5[1])
    # gingham blanket, a little tilted
    def gh(x, y):
        a = ((x - 100) // 9 + (y - 56) // 5) % 2; b = ((x - 100) // 9) % 2 == 0 and ((y - 56) // 5) % 2 == 0
        return E5[1] if b else E5[0] if a else CREAM
    fillmask(cv, lambda d: d.polygon([(104, 60), (186, 60), (196, 78), (94, 78)], fill=255), gh)
    for x in range(94, 197): cv.put(x, 78, E5[3])
    # basket, apples, thermos, a very small flag
    box(cv, 140, 166, 52, 70, W5, rnd, .1); [rect(cv, 140, y, 166, y + 1, W5[3]) for y in (56, 62)]
    for x in range(144, 163): cv.put(x, 44 + int(5 * math.sin((x - 144) / 19 * math.pi)) * -1 + 5, W5[1]); cv.put(x, 45 + 5 - int(5 * math.sin((x - 144) / 19 * math.pi)), W5[2])
    rect(cv, 144, 50, 163, 53, CREAM)
    for ax in (112, 122, 174): disc(cv, ax, 70, 4, E5); cv.put(ax, 65, M5[1])
    box(cv, 178, 187, 44, 64, S5, rnd, 0); rect(cv, 178, 40, 187, 45, E5[1])
    line(cv, 124, 62, 124, 36, W5[2]); poly(cv, [(125, 36), (141, 41), (125, 46)], G5[1])
    for k in range(10): flower(cv, 30 + k * 26 + rnd.randint(-5, 5), 100 + rnd.randint(0, 34), CREAM if k % 2 else P5[0], G5[1], 1)
    for x in range(8, 290, 10): cv.put(x, 140, M5[3])

# ------------------------------------------------------------------ 236
def bigflower(cv, x, y, h, kind, rnd, lean=1):
    """tall stem with a big head; kind 0 daisy, 1 poppy, 2 lupin spike, 3 tulip, 4 sunny"""
    for k in range(h):
        xx = x + int(math.sin(k / 9.0 + x) * 2) + lean * k // 14
        cv.put(xx, y - k, M5[2] if k % 4 else M5[1]); cv.put(xx + 1, y - k, M5[3])
        if k % 17 == 8:
            for j in range(6): cv.put(xx + (lean * j), y - k - j // 2, M5[1])
    hx = x + int(math.sin(h / 9.0 + x) * 2) + lean * h // 14; hy = y - h
    if kind == 0 or kind == 4:
        pc = CREAM if kind == 0 else G5[1]; pc2 = A5[0] if kind == 0 else G5[0]; r = 9 if kind == 4 else 8
        for a in range(0, 360, 30):
            px, py = hx + int(math.cos(math.radians(a)) * r), hy + int(math.sin(math.radians(a)) * r); ell(cv, px, py, 3, 3, pc if a % 60 else pc2)
        ell(cv, hx, hy, 5, 5, E5[2] if kind == 4 else G5[2]); ell(cv, hx - 1, hy - 1, 3, 3, W5[1] if kind == 4 else G5[1])
        if rnd.random() < .5: cv.put(hx - 2, hy, INK); cv.put(hx + 2, hy, INK); cv.put(hx - 1, hy + 2, INK); cv.put(hx, hy + 3, INK); cv.put(hx + 1, hy + 2, INK)
    elif kind == 1:
        ell(cv, hx, hy, 8, 7, E5[1]); ell(cv, hx - 2, hy - 2, 5, 4, E5[0]); ell(cv, hx, hy + 2, 3, 3, E5[3]); cv.put(hx - 4, hy + 6, E5[2])
    elif kind == 2:
        for k in range(7):
            ell(cv, hx + (k % 2) * 2 - 1, hy + k * 5 - 8, 5 - k // 3, 3, D5[1 if k % 2 else 0]); cv.put(hx + (k % 2) * 2 - 1, hy + k * 5 - 8, D5[3])
    else:
        ell(cv, hx, hy, 6, 8, P5[1]); ell(cv, hx - 2, hy - 2, 3, 5, P5[0]); poly(cv, [(hx - 6, hy - 4), (hx - 3, hy - 11), (hx, hy - 4), (hx + 3, hy - 11), (hx + 6, hy - 4)], P5[1]); cv.put(hx, hy - 6, P5[3])
def gnomehat(cv, x, y, s=1):
    """a gnome hat tipped over on the ground, brim to the right"""
    for k in range(34 * s):
        h = max(1, int((34 * s - k) * .45)); xx = x - 30 * s + k
        for dy in range(h): cv.put(xx, y - dy - (k // 12 if k < 24 else 2), E5[1 if dy < h // 2 else 2] if dy < h - 1 else E5[3])
    ell(cv, x + 6 * s, y - 4, 5 * s, 8 * s, CREAM); ell(cv, x + 6 * s, y - 4, 3 * s, 6 * s, A5[1])
    ell(cv, x - 30 * s, y - 2, 3, 3, CREAM)   # pompom
def lm_wildflowers(rnd, cv):   # 300 x 170
    lump(cv, 150, 164, 146, 40, M5, rnd, .1); tufts(cv, rnd, 14, 286, 166, 24)
    fl = []
    for _ in range(46):
        x = rnd.randint(16, 284); y = rnd.randint(126, 164)
        if ((x - 150) / 140.0) ** 2 + ((y - 164) / 40.0) ** 2 < 1.0: fl.append((y, x))
    for y, x in sorted(fl):
        back = (y - 126) / 38.0
        h = int(rnd.randint(50, 92) - back * 14); bigflower(cv, x, y, h, rnd.choice((0, 0, 1, 2, 3, 4, 1, 4)), rnd, rnd.choice((-1, 1)))
    gnomehat(cv, 70, 160, 1)
    for k in range(3): ell(cv, 108 + k * 5, 158 - k, 4, 3, G5[1 + k % 2])   # a picnic sandwich, abandoned
    box(cv, 214, 246, 148, 164, LT5, rnd, .1)
    for x in range(214, 246, 4): rect(cv, x, 148, x + 2, 164, CREAM)
    for x in range(214, 246, 8): rect(cv, x, 148, x + 4, 152, E5[1])
    for k in range(10): cv.put(224 + k, 140 - (k * (9 - k)) // 5, W5[2]); cv.put(225 + k, 140 - (k * (9 - k)) // 5, W5[3])   # basket handle
    bee(cv, 182, 40); bee(cv, 104, 70)
    for k in range(8): cv.put(186 + k * 3, 44 + (k * 5) % 9, CREAM) if k % 2 else None
    for k in range(6): cv.put(108 + k * 3, 74 - (k * 5) % 7, CREAM) if k % 2 else None
def puff(cv, cx, cy, r, rnd):
    ell(cv, cx, cy, r, r, RAMP["snow"][1]); ell(cv, cx - 1, cy - 1, r - 2, r - 2, CREAM)
    for a in range(0, 360, 15):
        for rr in range(2, r + 1):
            x = cx + int(round(math.cos(math.radians(a)) * rr)); y = cy + int(round(math.sin(math.radians(a)) * rr))
            if rr % 3 == 0 or rr == r: cv.put(x, y, RAMP["snow"][2] if (a // 15) % 2 else RAMP["snow"][1])
    disc(cv, cx, cy, max(2, r // 3), r5(RAMP["snow"]))
    for a in range(0, 360, 36): cv.put(cx + int(round(math.cos(math.radians(a)) * (r + 2))), cy + int(round(math.sin(math.radians(a)) * (r + 2))), CREAM)
def lm_dandelions(rnd, cv):   # 250 x 190
    lump(cv, 125, 190, 118, 20, M5, rnd, .08); tufts(cv, rnd, 14, 236, 176, 26)
    pts = [(44, 98, 15), (88, 82, 18), (130, 60, 28), (178, 84, 18), (214, 106, 14), (64, 134, 11), (160, 128, 13), (108, 128, 11), (196, 140, 9)]
    for x, y, r in sorted(pts, key=lambda p: p[1]):
        for k in range(y + r, 184): cv.put(x + int(2 * math.sin(k / 18.0 + x)), k, M5[2] if k % 6 else M5[1]); cv.put(x + 1 + int(2 * math.sin(k / 18.0 + x)), k, M5[3])
        puff(cv, x, y, r, rnd)
    for x, y in ((18, 150), (230, 156), (80, 164), (150, 158)):
        for k in range(14): cv.put(x, y + k, M5[2])
        disc(cv, x, y - 1, 5, G5)
    for k in range(14): cv.put(160 + k * 5, 10 + (k * 7) % 23, CREAM)   # wishes drifting off
    for i, (x, y) in enumerate(((190, 20), (210, 8), (232, 34), (70, 14), (24, 30), (112, 6))): sparkle(cv, x, y) if i % 2 == 0 else (cv.put(x, y, CREAM), cv.put(x + 1, y, CREAM), cv.put(x, y + 3, CREAM))
def lm_stonebridge(rnd, cv):   # 300 x 200
    ell(cv, 150, 188, 148, 12, SEA5[2]); rect(cv, 0, 176, 300, 198, SEA5[2])
    for x in range(0, 300, 11): cv.put(x, 182 + (x // 11) % 3 * 3, SEA5[0]); cv.put(x + 1, 182 + (x // 11) % 3 * 3, SEA5[0]); cv.put(x + 2, 183 + (x // 11) % 3 * 3, CREAM)
    deck = lambda x: int(76 + 40 * ((x - 150) / 118.0) ** 2)
    def brick(x, y):
        row = (y - 40) // 10; u = (x - 32) / 236.0; t = hsh(u)
        if (y - 40) % 10 == 0 or (x + (row % 2) * 8) % 16 == 0: return S5[3]
        if (x * 7 + y * 3) % 17 == 0: t = min(4, t + 1)
        return S5[t]
    def shape(d):
        pts = [(32, 182)] + [(x, deck(x)) for x in range(32, 269, 4)] + [(268, 182)]; d.polygon(pts, fill=255)
    fillmask(cv, shape, brick)
    for x in range(32, 269):
        for y in range(deck(x) - 5, deck(x)): cv.put(x, y, S5[0] if y < deck(x) - 2 else S5[1])
    for x in range(36, 266, 16): rect(cv, x, deck(x) - 9, x + 9, deck(x) - 5, S5[0]); rect(cv, x, deck(x) - 5, x + 9, deck(x) - 4, S5[3])
    fillmask(cv, lambda d: d.ellipse((92, 118, 208, 200), fill=255), lambda x, y: INK if y < 150 else SEA5[2] if y < 184 else SEA5[1])
    for k in range(0, 360, 7):   # keystone ring
        x = 150 + int(round(math.cos(math.radians(k)) * 59)); y = 160 + int(round(math.sin(math.radians(k)) * 43))
        if y < 164: cv.put(x, y, S5[0] if k % 21 else S5[3]); cv.put(x, y - 1, S5[1])
    for x in range(100, 200): cv.put(x, 118, INK) if cv.get(x, 118)[3] == 0 else None
    # ivy: lumps on the walls and vines hanging
    for x, y in ((56, 112), (76, 98), (226, 120), (246, 100), (112, 96), (190, 94), (44, 140)): lump(cv, x, y, 9, 6, L5, rnd, .05)
    for x, y0, n in ((60, 118, 26), (80, 104, 20), (230, 126, 30), (248, 106, 24), (116, 102, 16), (48, 146, 20)):
        for k in range(n): cv.put(x + int(math.sin(k / 3.0) * 1.5), y0 + k, L5[2] if k % 3 else L5[1])
        lump(cv, x, y0 + n, 3, 3, L5, rnd, 0)
    for x in (110, 130, 170, 192): flower(cv, x, deck(x) - 13, CREAM if x % 20 else P5[1], G5[1], 1)
    # proud little flag on the crown of the arch
    box(cv, 148, 152, 20, deck(150) - 8, W5, rnd, 0); poly(cv, [(152, 22), (182, 31), (152, 40)], E5[1]); poly(cv, [(152, 22), (168, 27), (152, 30)], E5[0]); ell(cv, 150, 20, 3, 3, G5[1])
    # the troll-sized toll sign
    box(cv, 14, 21, 96, 182, W5, rnd, 0); box(cv, 36, 43, 96, 182, W5, rnd, 0)
    box(cv, 0, 56, 62, 114, W5, rnd, .08); rect(cv, 0, 62, 56, 64, W5[0]); rect(cv, 0, 112, 56, 114, W5[3]); rect(cv, 0, 62, 2, 114, W5[0]); rect(cv, 54, 62, 56, 114, W5[3])
    for yy, ln in ((72, 40), (82, 34), (92, 44)): hline(cv, 8, 8 + ln, yy, INK); hline(cv, 8, 8 + ln, yy + 1, W5[3])
    ell(cv, 14, 103, 4, 3, S5[1]); ell(cv, 24, 103, 4, 3, S5[2]); ell(cv, 34, 103, 4, 3, S5[1]); cv.put(48, 104, E5[1])
    for x in (6,): flower(cv, x, 178, CREAM, G5[1], 1)
    _reeds(cv, 260, 190, 4, rnd)
def lm_beanpoles(rnd, cv):   # 280 x 210
    for i, (cx, h, base) in enumerate(((46, 126, 190), (112, 166, 196), (178, 150, 200), (240, 118, 192))):
        top = base - h
        for dx in (-24, 0, 24):
            if dx == 0: continue
            line(cv, cx + dx, base, cx, top, W5[1], 3); line(cv, cx + dx + 1, base, cx + 1, top, W5[3], 1)
        line(cv, cx, base - 4, cx, top, W5[2], 3)
        for t in range(0, h - 10, 12):   # vines of leaf-lumps
            y = base - 14 - t; w = int(22 * (1 - t / h))
            for s in (-1, 1): lump(cv, cx + s * w // 2 + (t // 12 % 2) * 2 - 1, y, 7, 6, L5, rnd, .05)
        for k in range(5):
            y = base - 20 - k * h // 6; w = int(22 * (1 - (base - y) / h)) + 6; px = cx + (-w if k % 2 else w) // 2
            pod = M5[1 if k % 2 else 0]
            for dy in range(16): cv.put(px, y + dy, pod); cv.put(px + 1, y + dy, M5[2]); cv.put(px + 2, y + dy, M5[3]) if dy % 2 else None
        for k in range(3):
            x = cx - 6 + k * 6; y = top + 14 + k * 20; flower(cv, x + (k % 2) * 4, y, E5[1] if i % 2 else P5[1], G5[1], 1)
        for dy in range(6): cv.put(cx - 1 + dy % 2, top - dy, W5[1])
        # tidy mounds
        for mx in range(cx - 34, cx + 36, 17): lump(cv, mx, base + 8, 10, 5, LT5, rnd, .1)
    # one bean with opinions, and a bean-sized speech bubble
    bx, by = 140, 178
    for dy in range(20):
        for dx in range(9):
            if (dx - 4) ** 2 / 20.0 + (dy - 10) ** 2 / 110.0 <= 1: cv.put(bx + dx, by + dy, M5[0 if dx < 3 else 1 if dx < 6 else 2])
    for ex in (bx + 1, bx + 5): cv.put(ex, by + 6, INK); cv.put(ex, by + 7, INK)
    for dx in range(3): cv.put(bx + 3 + dx, by + 12, INK)
    ell(cv, 118, 168, 12, 8, CREAM); rect(cv, 126, 174, 129, 180, CREAM)
    for k in range(3): cv.put(112 + k * 6, 168, INK); cv.put(113 + k * 6, 168, INK)
    for x in range(8, 270): cv.put(x, 208, M5[3]) if x % 3 == 0 else None
def lm_windmill(rnd, cv):   # 260 x 252, drawn big and scaled down (hard pixels, nearest)
    big = Cv(260, 300); _windmill(rnd, big); outline(big)
    sm = big.im.resize((213, 246), Image.NEAREST)
    cv.im.alpha_composite(sm, (23, 252 - 246 - 1))
    for y in range(cv.h):
        for x in range(cv.w):
            if cv.p[x, y][3] and cv.p[x, y][3] != 255: cv.p[x, y] = CLEAR
def _windmill(rnd, cv):
    def tower(x, y):
        hw = 40 + (y - 112) * 22 // 168.0; u = (x - (130 - hw)) / (2 * hw)
        t = hsh(u)
        if (y - 112) % 56 < 3 and y > 124: return W5[2] if (y - 112) % 56 < 2 else W5[3]
        if (x * 5 + y * 3) % 31 == 0: t = min(4, t + 1)
        return A5[t]
    fillmask(cv, lambda d: d.polygon([(90, 112), (170, 112), (193, 290), (67, 290)], fill=255), tower)
    for y in range(112, 290, 8):   # timber frame verticals
        pass
    for y in range(112, 291): hw = 40 + (y - 112) * 22 // 168; cv.put(int(130 - hw), y, W5[2]); cv.put(int(130 - hw) + 1, y, W5[3]); cv.put(int(130 + hw) - 1, y, W5[3])
    fillmask(cv, lambda d: (d.rectangle((113, 236, 147, 290), fill=255), d.ellipse((113, 226, 147, 246), fill=255)), lambda x, y: W5[1] if x < 128 else W5[2])
    for y in range(236, 290, 9): [cv.put(x, y, W5[3]) for x in range(113, 148)]
    rect(cv, 143, 262, 146, 266, G5[1])
    for wx, wy in ((116, 166), (130 - 6, 206)):
        fillmask(cv, lambda d: d.rectangle((wx, wy, wx + 12, wy + 14), fill=255), lambda x, y: G5[0] if y < wy + 6 else G5[1])
        rect(cv, wx - 1, wy - 1, wx + 13, wy, W5[3]); rect(cv, wx - 1, wy + 14, wx + 13, wy + 15, W5[3]); rect(cv, wx + 6, wy, wx + 7, wy + 14, W5[3])
    rect(cv, 112, 150, 148, 154, W5[2]); rect(cv, 112, 150, 148, 151, W5[0])   # balcony
    for x in range(112, 149, 6): rect(cv, x, 154, x + 1, 162, W5[3])
    cap = lambda x, y: E5[0 if (x - 90) / 80.0 < .15 else 1 if (x - 90) / 80.0 < .45 else 2 if (x - 90) / 80.0 < .78 else 3] if not ((x + (y // 6 % 2) * 6) % 12 == 0 or y % 6 == 0) else E5[3]
    fillmask(cv, lambda d: d.pieslice((84, 64, 176, 160), 180, 360, fill=255), cap)
    rect(cv, 84, 111, 176, 116, W5[2]); rect(cv, 84, 111, 176, 112, W5[0])
    for a_ in (22, 112, 202, 292):
        a = math.radians(a_); dx_, dy_ = math.cos(a), math.sin(a); nx_, ny_ = -dy_, dx_; hx, hy = 130, 100
        L = 96
        pts = [(hx + dx_ * 16 + nx_ * 3, hy + dy_ * 16 + ny_ * 3), (hx + dx_ * L + nx_ * 3, hy + dy_ * L + ny_ * 3), (hx + dx_ * L + nx_ * 24, hy + dy_ * L + ny_ * 24), (hx + dx_ * 16 + nx_ * 24, hy + dy_ * 16 + ny_ * 24)]
        def sail(x, y):
            t = (x - hx) * dx_ + (y - hy) * dy_; s = (x - hx) * nx_ + (y - hy) * ny_
            if s < 6 or s > 21 or t < 19 or t > L - 3 or int(t) % 12 < 2: return W5[2] if s > 12 else W5[1]
            return A5[0] if (int(t) // 12) % 2 else A5[1]
        fillmask(cv, lambda d: d.polygon(pts, fill=255), sail)
        line(cv, hx, hy, hx + dx_ * (L + 4), hy + dy_ * (L + 4), W5[3], 3); line(cv, hx - 1, hy - 1, hx + dx_ * L - 1, hy + dy_ * L - 1, W5[1], 1)
    disc(cv, 130, 100, 8, G5)
    for x, y in ((100, 276), (160, 282)): lump(cv, x, y, 9, 5, M5, rnd, 0)
def wheel(cv, cx, cy, r, rnd):
    ell(cv, cx, cy, r, r, W5[3]); ell(cv, cx, cy, r - 3, r - 3, W5[2]); ell(cv, cx, cy, r - 6, r - 6, CLEAR)
    for a in range(180, 361, 3): cv.put(cx + int(round(math.cos(math.radians(a)) * (r - 2))), cy + int(round(math.sin(math.radians(a)) * (r - 2))), W5[0 if a < 270 else 1])
    for a in range(0, 360, 30): line(cv, cx, cy, cx + int(math.cos(math.radians(a)) * (r - 5)), cy + int(math.sin(math.radians(a)) * (r - 5)), W5[1] if a < 180 else W5[2], 2)
    disc(cv, cx, cy, 6, G5)
def lm_haywagon(rnd, cv):   # 270 x 180
    ell(cv, 135, 174, 120, 6, M5[2]); tufts(cv, rnd, 10, 260, 176, 20)
    line(cv, 218, 130, 266, 160, W5[2], 4); line(cv, 218, 126, 266, 156, W5[0], 2)   # tow shafts
    wheel(cv, 66, 142, 36, rnd); wheel(cv, 192, 148, 28, rnd)
    box(cv, 22, 214, 96, 122, W5, rnd, .08)
    for x in range(22, 214, 17): rect(cv, x, 96, x + 1, 122, W5[3])
    rect(cv, 22, 96, 214, 98, W5[0]); rect(cv, 22, 120, 214, 122, W5[3])
    for cx, cy, rx, ry in ((60, 80, 38, 30), (118, 66, 46, 34), (176, 78, 38, 30), (96, 86, 40, 24), (150, 88, 40, 22)): lump(cv, cx, cy, rx, ry, G5, rnd, .16)
    for _ in range(100):
        x, y = rnd.randint(30, 205), rnd.randint(40, 100)
        if cv.get(x, y)[3] and cv.get(x, y) != INK and cv.get(x, y) not in W5:
            for k in range(rnd.randint(3, 7)): cv.put(x + k, y - k // 3, G5[0]); cv.put(x + k, y + 1 - k // 3, G5[3]) if k > 2 else None
    # driver's bench with a sparrow family
    rect(cv, 202, 74, 207, 98, W5[2]); rect(cv, 234, 74, 239, 98, W5[3]); box(cv, 196, 246, 70, 78, W5, rnd, 0)
    sparrow(cv, 212, 62, 3, rnd); sparrow(cv, 232, 66, 2, rnd, True); sparrow(cv, 246 - 4, 56, 2, rnd, True)
    for dx in range(-6, 6): cv.put(48 + dx, 160 + abs(dx) // 3, CLEAR) if False else None
def lm_taprow(rnd, cv):   # 290 x 240
    ell(cv, 145, 232, 140, 7, M5[2]); tufts(cv, rnd, 6, 284, 236, 24)
    for cx, base, s, R in ((58, 206, .72, G5), (146, 220, .9, E5), (226, 234, 1.08, G5)):
        tw = int(18 * s); th = int(130 * s)
        trunk(cv, cx, base - th, base, tw, rnd)
        for dx, dy, rx, ry in ((0, -th - 6, 50, 42), (-34, -th + 18, 36, 30), (34, -th + 18, 36, 30), (0, -th + 22, 44, 30)):
            lump(cv, cx + int(dx * s), base + int(dy * s), int(rx * s), int(ry * s), R, rnd, .1)
        leaf_texture(cv, R, rnd, 160)
        sy = base - int(52 * s); rect(cv, cx + tw // 2 - 1, sy, cx + tw // 2 + 8, sy + 3, S5[1]); rect(cv, cx + tw // 2 + 4, sy, cx + tw // 2 + 8, sy + 3, S5[3])
        bw, bh = int(22 * s), int(20 * s); bx = cx + tw // 2 + 6 - bw // 2; by = sy + 8
        line(cv, cx + tw // 2 + 6, sy + 3, cx + tw // 2 + 6, by, S5[3])
        fillmask(cv, lambda d: d.polygon([(bx, by), (bx + bw, by), (bx + bw - 3, by + bh), (bx + 3, by + bh)], fill=255), lambda x, y: S5[0] if x < bx + bw // 4 else S5[1] if x < bx + bw // 2 else S5[2] if x < bx + bw * 3 // 4 else S5[3])
        rect(cv, bx - 1, by, bx + bw + 1, by + 3, S5[0]); rect(cv, bx + 1, by + 1, bx + bw - 1, by + 2, INK)
        for k in range(3):   # drip, drip, drip
            cv.put(cx + tw // 2 + 6, sy + 4 + k * 0, G5[1])
        dy0 = by + bh + 6
        for k in range(2): cv.put(bx + bw // 2, dy0 + k * 5, G5[1]); cv.put(bx + bw // 2, dy0 + k * 5 + 1, G5[2])
        for k in range(4): cv.put(bx + bw // 2 - 3 + k * 2, base + 2, G5[1])
    for _ in range(40):
        x, y = rnd.randint(8, 280), rnd.randint(218, 238); cv.put(x, y, E5[1]); cv.put(x + 1, y, G5[1])
def bucket(cv, rnd, cx, base, w, h, R=None, wood=False):
    R = R or S5; bw = w
    def body(x, y):
        u = (x - (cx - w // 2)) / float(w); t = hsh(u)
        if wood: return W5[t] if (x - (cx - w // 2)) % 7 else W5[3]
        if (y - (base - h)) % 12 == 8: return R[3]
        return R[t]
    top, bot = base - h, base
    fillmask(cv, lambda d: d.polygon([(cx - w // 2, top), (cx + w // 2, top), (cx + w // 2 - 4, bot), (cx - w // 2 + 4, bot)], fill=255), body)
    rect(cv, cx - w // 2 - 1, top, cx + w // 2 + 2, top + 3, R[0]); rect(cv, cx - w // 2 + 1, top + 3, cx + w // 2, top + 4, R[3])
def lm_bucketstacks(rnd, cv):   # 230 x 230
    ell(cv, 115, 222, 108, 6, M5[2])
    for cx, n, lean, base in ((52, 4, 1, 220), (118, 7, -1, 222), (184, 3, 0, 220)):
        for i in range(n - 1, -1, -1):
            wob = (i * i * lean) // 3
            bucket(cv, rnd, cx + wob, base - i * 16, 52 - (i % 2) * 2, 34, S5 if (i + cx) % 3 else r5(RAMP["gold"]))
    bucket(cv, rnd, 118 - 6, 42, 40, 14, W5, wood=True) if False else None
    # one tipped over, spilling syrup
    fillmask(cv, lambda d: d.polygon([(138, 202), (172, 196), (176, 220), (142, 222)], fill=255), lambda x, y: S5[0] if y < 206 else S5[1] if y < 212 else S5[2])
    ell(cv, 140, 212, 5, 10, S5[3]); ell(cv, 140, 212, 3, 8, INK)
    for x in range(126, 150): cv.put(x, 223 + (x // 4) % 2, G5[1]); cv.put(x, 224, G5[2])
    ell(cv, 100, 226, 14, 4, G5[1])
    for k in range(3): cv.put(104 + k * 3, 223, G5[0])
def lm_sugarshack(rnd, cv):   # 280 x 260
    planks(cv, 46, 234, 122, 246, W5, rnd, 10)
    for y in range(66, 124):
        hw = (y - 66) * 112 // 58 + 22
        for x in range(140 - hw, 140 + hw + 1):
            u = (x - (140 - hw)) / max(1, 2.0 * hw); col = SEA5[min(3, hsh(u))] if (y // 7) % 2 == 0 else SEA5[min(4, hsh(u) + 1)]
            if (x + (y // 7 % 2) * 7) % 14 == 0 or (y % 7) == 6: col = SEA5[4]
            cv.put(x, y, col)
    for x in range(22, 260): cv.put(x, 123, W5[3]); cv.put(x, 122, W5[0]) if 30 < x < 250 else None
    # cupola
    box(cv, 118, 162, 38, 70, W5, rnd, 0)
    for y in range(42, 68, 5): rect(cv, 122, y, 158, y + 2, W5[3])
    for y in range(18, 40):
        hw = (y - 18) * 30 // 22 + 4
        for x in range(140 - hw, 140 + hw + 1): cv.put(x, y, SEA5[1 if x < 140 else 2] if y % 6 else SEA5[4])
    # chimney and pancake-shaped steam
    for y in range(40, 102):
        for x in range(206, 230):
            u = (x - 206) / 24.0; col = E5[1 if u < .4 else 2 if u < .8 else 3]
            if (y - 40) % 9 == 0 or (x - 206 + ((y - 40) // 9 % 2) * 6) % 12 == 0: col = E5[3]
            cv.put(x, y, col)
    rect(cv, 203, 36, 233, 42, S5[1]); rect(cv, 203, 36, 233, 38, S5[0])
    for i, (px, py, rx) in enumerate(((220, 26, 16), (214, 12, 12), (226, 2, 8))):
        ell(cv, px, py, rx, 4 if i < 2 else 3, G5[1]); ell(cv, px, py - 2, rx - 2, 3, G5[0])
        cv.put(px - 1, py - 3, CREAM); cv.put(px, py - 3, CREAM)
    # door, window, sign, woodpile
    fillmask(cv, lambda d: (d.rectangle((112, 188, 160, 246), fill=255), d.ellipse((112, 178, 160, 198), fill=255)), lambda x, y: E5[1] if x < 134 else E5[2])
    for x in range(112, 161, 12): [cv.put(x, y, E5[3]) for y in range(184, 246)]
    cv.put(152, 218, G5[1]); cv.put(153, 218, G5[0]); [cv.put(x, 246, W5[3]) for x in range(106, 166)]
    for wx in (62, 190):
        fillmask(cv, lambda d: d.rectangle((wx, 146, wx + 30, 178), fill=255), lambda x, y: G5[0] if (x + y) % 9 else CREAM)
        rect(cv, wx - 2, 144, wx + 32, 147, W5[3]); rect(cv, wx - 2, 177, wx + 32, 180, W5[3]); rect(cv, wx + 14, 146, wx + 16, 178, W5[3]); rect(cv, wx - 2, 146, wx, 178, W5[3]); rect(cv, wx + 30, 146, wx + 32, 178, W5[3])
    ell(cv, 140, 138, 10, 8, G5[1]); poly(cv, [(140, 126), (134, 138), (146, 138)], G5[1]); cv.put(137, 136, CREAM)   # syrup drop
    for r in range(4):
        for c in range(4 - r % 2): lump(cv, 24 + c * 14 + (r % 2) * 7, 244 - r * 12, 7, 6, W5, rnd, 0); ell(cv, 24 + c * 14 + (r % 2) * 7, 244 - r * 12, 3, 2, W5[0])
    bucket(cv, rnd, 250, 244, 22, 20)
    for x in range(10, 270): cv.put(x, 250 if (x * 7) % 5 else 251, M5[2])
    for x in range(8, 272, 5): cv.put(x, 249, M5[1])
def lm_pancakelane(rnd, cv):   # 320 x 236
    cx = 160
    for i in range(4):   # the road is a tall stack of pancakes
        cy = 214 - i * 15; rx = 150 - i * 3
        ell(cv, cx, cy + 13, rx, 24, G5[3]); rect(cv, cx - rx, cy, cx + rx + 1, cy + 14, G5[2])
        for x in range(cx - rx, cx + rx + 1):   # side shading and a darker butter-brown seam
            u = (x - cx + rx) / (2.0 * rx)
            for y in range(cy, cy + 14): cv.put(x, y, G5[1] if u < .3 and y < cy + 9 else G5[2] if u < .7 or y > cy + 9 else G5[3])
            cv.put(x, cy + 14 + int(math.sin(x / 5.0) * 1.5), G5[3])
        ell(cv, cx, cy, rx, 24, G5[1] if i < 3 else A5[1])
    top = 214 - 3 * 15
    ell(cv, cx, top, 147, 23, A5[0]); ell(cv, cx, top + 1, 138, 20, A5[1])
    for x in range(30, 290):   # toasty griddle freckles
        for y in range(top - 18, top + 22):
            if ((x - cx) / 138.0) ** 2 + ((y - top - 1) / 20.0) ** 2 < 1 and (x * 13 + y * 7) % 41 == 0: cv.put(x, y, A5[2])
    for i, y in enumerate(range(top - 12, top + 18, 7)):   # wobbly footprints, the gnome who followed his nose
        px = cx - 40 + int(34 * math.sin(i * 1.3)) + i * 3
        for dx in (-5, 5): rect(cv, px + dx, y, px + dx + 3, y + 4, A5[3])
    # syrup river: from a pat of butter down over the front edge, dripping down the stack
    rect(cv, 126, top - 20, 144, top - 12, CREAM); rect(cv, 126, top - 20, 144, top - 19, G5[0]); rect(cv, 126, top - 13, 144, top - 12, G5[1])
    for y in range(top - 12, top + 24):
        mx = 150 + int(math.sin((y - top) / 6.0) * 10) + (y - top) // 3; w = 14 + (y - top) // 3
        for x in range(mx - w // 2, mx + w // 2): cv.put(x, y, G5[0] if x == mx - w // 2 + 1 and y % 3 else LT5[2] if x < mx - 1 else LT5[3] if x > mx + w // 4 else LT5[2])
    for dx, ln in ((-14, 18), (-2, 36), (10, 26), (22, 14)):
        x0 = 150 + 14 + dx; y0 = top + 24
        for k in range(ln): rect(cv, x0, y0 + k, x0 + 6, y0 + k + 1, LT5[2] if k < ln - 3 else LT5[3])
        ell(cv, x0 + 3, y0 + ln, 4, 4, LT5[2]); cv.put(x0 + 1, y0 + ln - 1, G5[0])
    def post(x, y, n):
        box(cv, x - 3, x + 4, y - 30, y, W5, rnd, 0)
        for k in range(n):
            ell(cv, x, y - 33 - k * 7, 19, 7, G5[2]); ell(cv, x, y - 36 - k * 7, 19, 7, G5[1]); ell(cv, x, y - 37 - k * 7, 16, 5, G5[0] if k % 2 else A5[0])
        rect(cv, x - 4, y - 46 - n * 7, x + 4, y - 41 - n * 7, CREAM); rect(cv, x - 4, y - 41 - n * 7, x + 4, y - 40 - n * 7, G5[0])
    for i, x in enumerate((38, 72, 106)): post(x, top + 6 + i * 4 - 8 if False else top + 2 + (2 - i) * 0, 2 + i % 2)
    for i, x in enumerate((214, 248)): post(x, top + 2, 3 - i % 2)
    # big fork signpost
    fx = 284
    for x in range(fx - 4, fx + 5):
        for y in range(36, top + 4): cv.put(x, y, S5[0 if x < fx - 2 else 1 if x < fx else 2 if x < fx + 3 else 3])
    for tx in (fx - 12, fx - 4, fx + 4, fx + 12):
        for y in range(6, 40): cv.put(tx, y, S5[0 if y < 30 else 1]); cv.put(tx + 1, y, S5[2]) if True else None
        cv.put(tx, 5, S5[0])
    for x in range(fx - 12, fx + 14): rect(cv, x, 36, x + 1, 44 + (4 if 4 < abs(x - fx) else 0), S5[1] if x < fx else S5[2])
    box(cv, 216, 280, 52, 76, W5, rnd, .08); rect(cv, 216, 52, 280, 54, W5[0]); rect(cv, 216, 74, 280, 76, W5[3])
    poly(cv, [(206, 64), (218, 52), (218, 76)], W5[1]); hline(cv, 224, 270, 60, INK); hline(cv, 224, 262, 66, INK); hline(cv, 224, 252, 71, INK)
    box(cv, fx - 2, fx + 2, 40, 52, S5, rnd, 0)
    for x0 in (88, 140, 190):   # the smell, in wiggles
        for y in range(50, 120):
            cv.put(x0 + int(6 * math.sin(y / 6.0 + x0)), y, CREAM if y % 3 else G5[0]); cv.put(x0 + 1 + int(6 * math.sin(y / 6.0 + x0)), y, G5[0])
LM = {
    "232-beehive": (250, 210, lm_beehive), "232-berrypatch": (240, 130, lm_berrypatch), "232-logbridge": (300, 160, lm_logbridge),
    "232-well": (180, 240, lm_well), "232-crossroads": (220, 240, lm_crossroads), "232-picnicrise": (300, 150, lm_picnicrise),
    "236-wildflowers": (300, 170, lm_wildflowers), "236-dandelions": (250, 190, lm_dandelions), "236-stonebridge": (300, 200, lm_stonebridge),
    "236-beanpoles": (280, 210, lm_beanpoles), "236-windmill": (260, 252, lm_windmill), "236-haywagon": (270, 180, lm_haywagon),
    "311-taprow": (290, 240, lm_taprow), "311-bucketstacks": (230, 230, lm_bucketstacks), "311-sugarshack": (280, 260, lm_sugarshack),
    "311-pancakelane": (320, 236, lm_pancakelane),
}
