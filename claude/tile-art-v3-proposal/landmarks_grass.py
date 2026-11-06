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

# ------------------------------------------------------------------ hand-drawn detail helpers (form shading, dither, strokes)
_B4 = ((0, 8, 2, 10), (12, 4, 14, 6), (3, 11, 1, 9), (15, 7, 13, 5))
_LV = (-0.5, -0.6, 0.62)
def hd_tone(v, x, y):
    """continuous tone 0..4 -> int tone with a 4x4 ordered dither so ramp steps melt into a checker."""
    b = (_B4[y & 3][x & 3] + .5) / 16 - .5
    return max(0, min(4, int(math.floor(v + b + .5))))
def hd_noise(rnd, cell, w=900, h=900):
    gw, gh = w // cell + 3, h // cell + 3; g = [[rnd.random() for _ in range(gw)] for _ in range(gh)]
    def f(x, y):
        fx, fy = x / cell, y / cell; x0, y0 = int(fx), int(fy); tx, ty = fx - x0, fy - y0
        tx = tx * tx * (3 - 2 * tx); ty = ty * ty * (3 - 2 * ty)
        a, b, c, d = g[y0][x0], g[y0][x0 + 1], g[y0 + 1][x0], g[y0 + 1][x0 + 1]
        return (a + (b - a) * tx) * (1 - ty) + (c + (d - c) * tx) * ty
    return f
def hd_form(cv, box_, inside, hf, R, rnd, gain=2.8, bias=.95, extra=None):
    """Fill every pixel where inside(x,y) with a ramp tone from a height field hf(x,y) (normal . light, dithered). Returns {(x,y): v}."""
    x0, y0, x1, y1 = box_; out = {}
    for y in range(y0, y1):
        for x in range(x0, x1):
            if not inside(x, y): continue
            gx = (hf(x + 1, y) - hf(x - 1, y)) / 2.0; gy = (hf(x, y + 1) - hf(x, y - 1)) / 2.0
            nn = math.sqrt(gx * gx + gy * gy + 1); d = (-gx * _LV[0] - gy * _LV[1] + _LV[2]) / nn
            v = (bias - d) * gain + (extra(x, y) if extra else 0)
            out[(x, y)] = v; cv.put(x, y, R[hd_tone(v, x, y)])
    return out
def hd_idx(c, R):
    for i, r in enumerate(R):
        if r == c: return i
    return None
def hd_blade(cv, x, y, h, lean, R, wide=False, ib=None):
    """one grass blade growing up from (x, y), coloured from whatever it grows on (dark root, lit tip)."""
    i = hd_idx(cv.get(x, y), R) if ib is None else ib; i = 2 if i is None else i
    for k in range(h):
        xx = x + (k * lean) // 3; t = max(0, i - 2) if k >= h - 1 else max(0, i - 1) if k > h // 2 else min(4, i + 1) if k == 0 else i
        cv.put(xx, y - k, R[t])
        if wide and k < h - 1: cv.put(xx + 1, y - k, R[min(4, i + 1)])
def hd_tuft(cv, x, y, n, hmax, R, rnd, spread=3, lean0=0, ib=None):
    for j in range(n):
        u = (j - (n - 1) / 2.0); hd_blade(cv, x + int(u * spread / max(1, n - 1) * 2), y + rnd.choice((0, 0, 1)), rnd.randint(max(2, hmax - 2), hmax), int(u * 1.2) + lean0, R, False, ib)
def hd_line(cv, x0, y0, x1, y1, c, only=None):
    n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in range(n + 1):
        x = int(round(x0 + (x1 - x0) * i / n)); y = int(round(y0 + (y1 - y0) * i / n))
        if only is None or only(x, y): cv.put(x, y, c)
def hd_blob(cv, cx, cy, rx, ry, c, rnd, only=None, rough=.18):
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            d = ((x + .5 - cx) / rx) ** 2 + ((y + .5 - cy) / ry) ** 2
            if d <= 1 - (rough if rnd.random() < .5 else 0) and (only is None or only(x, y)): cv.put(x, y, c)
def hd_bounce(cv, S, R, lr, bounce_i=1, deep_i=4):
    """S = set of filled pixels. On the lower-right edge (lr(x,y) true) the outermost px gets a bounce-light tone and the px just inside get the deepest shade."""
    E = [(x, y) for (x, y) in S if ((x + 1, y) not in S or (x, y + 1) not in S) and lr(x, y)]
    ES = set(E)
    for (x, y) in E:
        for dx, dy in ((-1, 0), (0, -1), (-1, -1)):
            p = (x + dx, y + dy)
            if p in S and p not in ES: cv.put(p[0], p[1], R[deep_i] if (p[0] + p[1]) % 3 else R[max(0, deep_i - 1)])
    for (x, y) in E: cv.put(x, y, R[bounce_i])

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
    nz = hd_noise(rnd, 9); nz2 = hd_noise(rnd, 4); nz3 = hd_noise(rnd, 20)
    # ---- the stream: dithered depth, ripple dashes, reflections, lily pads
    wcx, wcy, wrx, wry = 150, 126, 142, 27
    def inw(x, y): return ((x + .5 - wcx) / wrx) ** 2 + ((y + .5 - wcy) / wry) ** 2 <= 1 + (nz2(x, y) - .5) * .12
    wat = set()
    for y in range(wcy - wry - 2, wcy + wry + 3):
        for x in range(wcx - wrx - 3, wcx + wrx + 4):
            if inw(x, y):
                v = 0.3 + (y - (wcy - wry)) / (2.0 * wry) * 3.0 + (nz(x, y) - .5) * 1.1
                cv.put(x, y, SEA5[hd_tone(v, x, y)]); wat.add((x, y))
    for _ in range(95):   # ripple dashes, longer in the middle, short at the banks
        x, y = rnd.randint(14, 285), rnd.randint(wcy - wry + 3, wcy + wry - 3)
        if (x, y) in wat:
            n = rnd.randint(3, 8)
            for k in range(n): (cv.put(x + k, y, SEA5[0]) if (x + k, y) in wat else None); (cv.put(x + k + 1, y + 1, SEA5[3]) if k % 2 == 0 and (x + k + 1, y + 1) in wat else None)
    for _ in range(18): x, y = rnd.randint(30, 270), rnd.randint(wcy - 10, wcy + wry - 6); cv.put(x, y, CREAM); cv.put(x + 1, y, CREAM) if (x + 1, y) in wat else None
    # ---- banks: mossy mounds with stones, tufts, flowers
    def bank(x0, w, flip):
        bnz = hd_noise(rnd, 6)
        def ins(x, y): return ((x + .5 - (x0 + w / 2.0)) / (w / 2.0)) ** 2 + ((y + .5 - 114) / 17.0) ** 2 <= 1 + (bnz(x, y) - .5) * .25 and y < 124
        hf = lambda x, y: 16 * math.sqrt(max(0, 1 - (((x - (x0 + w / 2.0)) / (w / 2.0)) ** 2 + ((y - 114) / 17.0) ** 2))) + 2.5 * bnz(x, y)
        S = hd_form(cv, (x0 - 2, 94, x0 + w + 3, 126), ins, hf, M5, rnd, 2.8, .95, lambda x, y: (bnz(x + 70, y) - .5) * 1.2)
        P_ = set(S)
        for _ in range(w * 2):
            x, y = rnd.randint(x0, x0 + w), rnd.randint(98, 122)
            if (x, y) in P_: hd_tuft(cv, x, y, rnd.randint(2, 4), rnd.randint(3, 6), M5, rnd, 3, rnd.choice((-1, 0, 1)))
        for _ in range(6):   # little stones
            x, y = rnd.randint(x0 + 6, x0 + w - 6), rnd.randint(112, 121)
            if (x, y) in P_: lump(cv, x, y, 4, 3, S5, rnd, .1)
        for _ in range(7):
            x, y = rnd.randint(x0 + 4, x0 + w - 4), rnd.randint(100, 118)
            if (x, y) in P_:
                k = rnd.randint(0, 3); cv.put(x, y + 2, M5[3]); cv.put(x, y + 1, M5[3]); cols = (CREAM, P5[0], G5[0], D5[0])[k]
                for dx, dy in ((-1, 0), (1, 0), (0, -1)): cv.put(x + dx, y + dy, cols)
                cv.put(x, y, G5[1])
        hd_bounce(cv, P_, M5, lambda x, y: x + y > x0 + w / 2.0 + 114 or y > 118, 1, 4)
        for x in range(x0, x0 + w):   # wet foot
            if (x, 123) in P_ and x % 3 == 0: cv.put(x, 123, SEA5[0]); cv.put(x + 1, 124, CREAM)
    bank(2, 70, 1); bank(228, 70, -1)
    # ---- the log: knobbly top and bottom, cylinder shading, bark furrows
    top0, bot0 = 36, 96; cyl = (top0 + bot0) / 2.0; Rr = (bot0 - top0) / 2.0
    def lt(x): return top0 + (nz(x, 3) - .5) * 5 + (2 if x % 23 < 3 else 0) - (x < 62) * max(0, (62 - x) // 6)
    def lb(x): return bot0 + (nz(x, 90) - .5) * 4 - (x < 62) * max(0, (62 - x) // 6)
    def ins(x, y): return 40 <= x <= 270 and lt(x) <= y <= lb(x) and not ((x < 56 or x > 258) and False)
    def hf(x, y):
        u = (y - cyl) / Rr; return 22 * math.sqrt(max(0, 1 - u * u)) + 1.5 * nz2(x, y)
    L = hd_form(cv, (36, 30, 276, 102), lambda x, y: ins(x, y) and (x - 54) ** 2 / 24.0 ** 2 + (y - 66) ** 2 / 38.0 ** 2 >= 0.0, hf, W5, rnd, 3.4, .95, lambda x, y: (nz3(x, y) - .5) * 1.4 + .7 * (x - 40) / 230.0 + 1.0 * (y - cyl) / Rr)
    # rounded right end
    for y in range(34, 100):
        for x in range(246, 276):
            if cv.get(x, y)[3] and ((x - 246) / 25.0) ** 2 + ((y - 66) / 31.0) ** 2 > 1: cv.p[x, y] = CLEAR; L.pop((x, y), None)
    # bark furrows: wavy dark strokes with a lit lip above them
    for _ in range(120):
        x, y = rnd.randint(60, 262), rnd.randint(42, 94); n = rnd.randint(7, 24); ph = rnd.random() * 6
        for k in range(n):
            xx = x + k; yy = y + int(round(math.sin(k / 4.0 + ph) * 1.2))
            if (xx, yy) in L and (xx, yy + 1) in L and cv.get(xx, yy) not in M5:
                cv.put(xx, yy, W5[4 if k % 5 else 3]); cv.put(xx, yy - 1, W5[0] if yy < cyl else W5[1]) if (xx, yy - 1) in L and cv.get(xx, yy - 1) not in M5 and k % 2 == 0 else None
    for _ in range(150):   # bark scales: tiny vertical ticks
        x, y = rnd.randint(60, 262), rnd.randint(42, 94)
        if (x, y) in L and (x, y + 2) in L and cv.get(x, y) not in M5: cv.put(x, y, W5[3]); cv.put(x, y + 1, W5[4]); cv.put(x + 1, y, W5[1]) if (x + 1, y) in L else None
    for (kx, ky, r) in ((150, 70, 6), (216, 58, 5), (92, 82, 4)):   # knots
        for rr_ in range(r, 0, -1):
            for a in range(0, 360, 6):
                x = kx + int(round(math.cos(math.radians(a)) * rr_ * 1.5)); y = ky + int(round(math.sin(math.radians(a)) * rr_))
                cv.put(x, y, W5[1 if (rr_ % 2 and a < 180) else 3 if rr_ % 2 else 2])
        for a in range(0, 360, 5): cv.put(kx + int(round(math.cos(math.radians(a)) * (r + 1) * 1.5)), ky + int(round(math.sin(math.radians(a)) * (r + 1))), W5[4])
        cv.put(kx, ky, INK); cv.put(kx + 1, ky, INK)
    for (cx_, cy_) in ((120, 88), (236, 84)):   # cracks
        for k in range(12): cv.put(cx_ + k + (k // 4), cy_ - k // 3, INK if k % 5 else W5[4]); cv.put(cx_ + k + (k // 4), cy_ - k // 3 + 1, W5[4]) if k % 2 == 0 else None
    # branch stubs breaking the outline, with sawn ends
    for (sx, sh_) in ((88, 9), (196, 12), (240, 7)):
        y0 = int(lt(sx))
        for k in range(sh_):
            for xx in range(sx - 3, sx + 4): cv.put(xx + (k // 4) * 1, y0 - k, W5[0 if xx < sx - 1 else 1 if xx < sx + 1 else 2 if xx < sx + 3 else 3])
        for xx in range(sx - 3, sx + 5): cv.put(xx + 1, y0 - sh_, W5[0] if xx % 2 else W5[1])
        cv.put(sx, y0 - sh_, W5[3]); cv.put(sx + 1, y0 - sh_, W5[3])
    # moss: ragged cap along the top, patches on the lit side and the right end, hanging drips
    def mossy(x, y): return y < lt(x) + 5 + 9 * nz3(x + 20, y) + 4 * (nz2(x, y) - .5)
    MP = {}
    for (x, y), v in L.items():
        if x > 62 and mossy(x, y) and not (150 < x < 210 and y > lt(x) + 6 and nz3(x, 0) < .5 and False):
            t = hd_tone(v * .85 + .2 + (nz2(x + 5, y) - .5) * 1.2, x, y); cv.put(x, y, M5[t]); MP[(x, y)] = t
    for (x, y), v in L.items():
        if x > 62 and not mossy(x, y) and nz3(x * 1.3 + 100, y * 1.7) > .74 and nz2(x, y * 2) > .45: cv.put(x, y, M5[hd_tone(v * .9 + .5, x, y)]); MP[(x, y)] = 1
    for x in range(64, 268, 1):   # tufts and drips on the top silhouette
        y0 = int(lt(x))
        if rnd.random() < .5: hd_tuft(cv, x, y0 + 1, rnd.randint(2, 3), rnd.randint(3, 6), M5, rnd, 3, rnd.choice((-1, 0, 1)), 1)
    for _ in range(26):   # moss strands hanging down the bark
        x = rnd.randint(70, 262); y = int(lt(x)) + 6 + int(8 * nz3(x + 20, 6))
        if (x, y) in L and (x, y) in MP:
            for k in range(rnd.randint(3, 9)): cv.put(x, y + k, M5[1 if k < 2 else 2 if k < 5 else 3]) if (x, y + k) in L else None
    for (mx_, my_) in ((70, 70), (226, 74), (180, 90), (110, 48)):   # extra moss blobs on the bark
        hd_blob(cv, mx_, my_, 8, 4, M5[2], rnd, lambda a, b: (a, b) in L)
        hd_blob(cv, mx_ - 2, my_ - 1, 5, 2, M5[1], rnd, lambda a, b: (a, b) in L); hd_blob(cv, mx_ - 3, my_ - 2, 2, 1, M5[0], rnd, lambda a, b: (a, b) in L)
    # lower edge in shadow with bounce light, reflection under the log
    hd_bounce(cv, set(L), W5, lambda x, y: y > cyl - 8 or x > 250, 2, 4)
    for x in range(48, 262):
        if (x, 96) in L or (x, 95) in L:
            for k in range(1, 7):
                if (x, 98 + k) in wat and (x * 3 + k * 5) % (3 + k) != 0 and rnd.random() < .85 - k * .08: cv.put(x, 97 + k + (k > 3), W5[3] if k < 3 else SEA5[3])
    # ---- the cut end with growth rings, cracks and the hollow
    ex, ey, erx, ery = 54, 66, 19, 31
    for y in range(ey - ery - 2, ey + ery + 3):
        for x in range(ex - erx - 2, ex + erx + 3):
            d = ((x + .5 - ex) / erx) ** 2 + ((y + .5 - ey) / ery) ** 2
            if d <= 1.08: cv.put(x, y, W5[3] if d > 1.0 else W5[4])
    for y in range(ey - ery, ey + ery + 1):
        for x in range(ex - erx, ex + erx + 1):
            d = math.sqrt(((x + .5 - ex) / erx) ** 2 + ((y + .5 - ey) / ery) ** 2)
            if d <= .96:
                ring = int(d * 17 + (nz(x, y) - .5) * 1.8)
                c = W5[0] if ring % 4 == 0 else W5[1] if ring % 4 == 1 else W5[1] if ring % 4 == 2 and (x + y) % 2 else W5[2]
                if ring % 5 == 3: c = W5[3]
                if (x - ex) + (y - ey) > 14 + (nz2(x, y) * 4): c = W5[2] if (x + y) % 2 else W5[3]
                cv.put(x, y, c)
    for y in range(ey - 14, ey + 15):
        for x in range(ex - 9, ex + 10):
            d = (x - ex) ** 2 / 81.0 + (y - ey) ** 2 / 196.0
            if d <= 1: cv.put(x, y, INK if d > .35 or y > ey + 2 else H("#150d14"))
    for yy in range(ey - 13, ey + 14):   # a lit inside edge on the left of the hollow, ember-warm glow low down
        xe = ex - int(9 * math.sqrt(max(0, 1 - (yy - ey) ** 2 / 196.0))); cv.put(xe, yy, W5[1]); cv.put(xe + 1, yy, W5[3])
    for (a, ln) in ((200, 12), (320, 14), (110, 9), (20, 11)):   # radial cracks
        for k in range(ln):
            x = ex + int(round(math.cos(math.radians(a)) * (9 + k) * (1 if k % 3 else 1.04))); y = ey + int(round(math.sin(math.radians(a)) * (15 + k) ))
            if ((x - ex) / erx) ** 2 + ((y - ey) / ery) ** 2 < .9: cv.put(x, y, W5[4]); cv.put(x + 1, y, W5[3]) if k % 2 else None
    for x in range(ex - 6, ex + 7): cv.put(x, ey + 13, W5[1]) if (x + ey) % 2 else None
    cv.put(ex - 4, ey + 9, CREAM); cv.put(ex + 3, ey + 6, CREAM)   # cobwebby glints
    # ---- shelf mushrooms with gills, a sapling, ferns on the bank end
    def shelf(mx_, my_, s):
        w_, h_ = 7 * s + 2, 4 * s + 1
        for y in range(my_ - h_, my_ + 1):
            for x in range(mx_ - w_, mx_ + w_ + 1):
                nx_, ny_ = (x - mx_) / float(w_), (y - my_) / float(h_)
                if nx_ * nx_ + ny_ * ny_ <= 1:
                    d = shade_d(nx_, ny_); cv.put(x, y, E5[0 if d > .8 else 1 if d > .5 else 2 if d > .1 else 3])
        for x in range(mx_ - w_ + 1, mx_ + w_): cv.put(x, my_ + 1, CREAM if x % 2 else A5[2]); cv.put(x, my_ + 2, A5[3]) if x % 2 == 0 else None   # gills
        for k in range(3 + s): cv.put(mx_ - w_ + 3 + k * 4, my_ - h_ // 2 - (k % 2), CREAM); cv.put(mx_ - w_ + 4 + k * 4, my_ - h_ // 2 - (k % 2), CREAM) if s > 1 else None
    def shade_d(nx_, ny_):
        nz_ = math.sqrt(max(0, 1 - nx_ * nx_ - ny_ * ny_)); return nx_ * -.5 + ny_ * -.6 + nz_ * .62
    shelf(202, 40, 1); shelf(214, 41, 1); shelf(126, 41, 2)
    stx, sty = 111, 40   # a sapling
    for k in range(22): cv.put(stx, sty - k, W5[2 if k % 3 else 1]); cv.put(stx + 1, sty - k, W5[3])
    for (lx, ly, d) in ((-1, 14, -1), (1, 10, 1), (-1, 5, -1), (1, 19, 1), (0, 23, 0)):
        for k in range(1, 9):
            for j in range(-(k // 3), k // 3 + 2): cv.put(stx + (lx * (k + 1) if lx else 0) + 0, sty - ly - j + (k // 3) if False else sty - ly - j, L5[1] if j < 1 else L5[2])
        lump(cv, stx + (lx * 9 if lx else 0), sty - ly - (3 if lx == 0 else 0), 6, 3 if lx else 5, L5, rnd, .08)
    for k in range(5): cv.put(stx - 8 + k * 4, sty - 8, L5[0])
    for (fx_, fy_, sgn) in ((18, 108, 1), (284, 108, -1), (34, 112, 1), (268, 112, -1)):   # ferns
        for blade in range(7):
            a = -90 + (blade - 3) * 26
            for k in range(14):
                x = fx_ + int(math.cos(math.radians(a)) * k * .9); y = fy_ + int(math.sin(math.radians(a)) * k * .9 + k * k * .018)
                cv.put(x, y, L5[1] if k % 2 else L5[2]); cv.put(x, y - 1, L5[0]) if k % 3 == 0 and k > 3 else None; cv.put(x + 1, y, L5[3]) if k % 2 == 0 else None
    # reeds and lily pads
    _reeds(cv, 8, 130, 3, rnd); _reeds(cv, 270, 130, 3, rnd)
    for (lx, ly) in ((110, 142), (196, 146), (150, 150)):
        lump(cv, lx, ly, 9, 3, M5, rnd, 0); cv.put(lx + 4, ly - 1, SEA5[2]); cv.put(lx + 5, ly, SEA5[2]); cv.put(lx + 5, ly - 1, SEA5[2])
        for k in range(5): cv.put(lx - 6 + k * 3, ly, M5[0])
    for (lx, ly) in ((110, 140), (196, 144)): cv.put(lx, ly, P5[1]); cv.put(lx - 1, ly - 1, P5[0]); cv.put(lx + 1, ly - 1, P5[0]); cv.put(lx, ly - 1, CREAM); cv.put(lx, ly - 2, P5[0])
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
def lm_picnicrise(rnd, cv):   # 300 x 156
    cx, base, RX, RY, P = 150, 146, 146.0, 100.0, 2.2
    nz = hd_noise(rnd, 14); nz2 = hd_noise(rnd, 5)
    def rr(x, y): return (abs((x + .5 - cx) / RX) ** P + abs((y + .5 - base) / RY) ** P)
    def inside(x, y):
        if y > base: return False
        w = (nz2(x, 0) - .5) * .05 + (nz(x, 60) - .5) * .05
        return rr(x, y) <= 1 + w
    def hf(x, y):
        r = min(1.0, rr(x, y)); return 64 * math.sqrt(max(0, 1 - r)) + 3.0 * nz(x, y) + 1.2 * nz2(x, y)
    S = hd_form(cv, (0, 30, 300, base + 1), inside, hf, M5, rnd, 2.6, .95, lambda x, y: (nz(x + 40, y + 40) - .5) * 1.1 + 1.3 * (x - cx) / RX + .5 * (y - 90) / 60.0 + ((x * 3 + y * 5) % 7 == 0) * .4)
    pts = set(S)
    # ---- worn path: starts at the blanket, swings out to the lower right
    def pc(y):
        t = (y - 78) / 68.0; return 140 + 52 * t + 16 * math.sin(t * 4.2), 3.5 + 17 * t ** 1.1
    PR = [A5[2], LT5[0], LT5[1], LT5[2], LT5[3]]
    path = set()
    for y in range(80, base + 1):
        c, w = pc(y)
        for x in range(int(c - w - 3), int(c + w + 4)):
            if (x, y) not in pts: continue
            e = abs(x + .5 - c) / w + (nz2(x * 2, y) - .5) * .5
            if e < 1.0:
                v = S[(x, y)] - .15 + (e ** 2) * 1.2 - 1.0 + (nz(x + 90, y) - .5) * 1.0
                t = hd_tone(v * .9 + .6, x, y); cv.put(x, y, PR[min(4, t)]); path.add((x, y))
    for y in range(82, base, 2):   # wheel-ruts and footprints: short dark dashes along the path
        c, w = pc(y)
        for sgn in (-.45, .35):
            x = int(c + sgn * w)
            if (x, y) in path and (y // 2 + int(sgn * 9)) % 3: cv.put(x, y, PR[3]); cv.put(x + 1, y, PR[2]) if (x + 1, y) in path else None
    for _ in range(46):   # pebbles in the path
        y = rnd.randint(84, base - 3); c, w = pc(y); x = int(c + rnd.uniform(-.8, .8) * w)
        if (x, y) in path and (x + 2, y + 1) in path:
            cv.put(x, y, S5[0]); cv.put(x + 1, y, S5[1]); cv.put(x, y + 1, S5[2]); cv.put(x + 1, y + 1, S5[3]); cv.put(x + 2, y + 1, PR[4])
    for y in range(80, base):   # ragged edge: grass blades creeping onto the path, and tufts lining it
        c, w = pc(y)
        for sgn in (-1, 1):
            x = int(c + sgn * (w + rnd.uniform(-1, 2)))
            if rnd.random() < .5 and (x, y) in pts: hd_tuft(cv, x, y, rnd.randint(2, 3), rnd.randint(3, 5), M5, rnd, 2, sgn)
    # ---- grass: clustered blades following the form (lean outward), dense in the shade
    def blade_at(x, y, n=None):
        if (x, y) in path or (x, y) not in pts: return
        sl = 1 if x > cx else -1
        hd_tuft(cv, x, y, n or rnd.randint(2, 4), rnd.randint(3, 5), M5, rnd, 3, sl if abs(x - cx) > 40 else 0)
    for _ in range(520):
        x, y = rnd.randint(2, 297), rnd.randint(46, base)
        blade_at(x, y)
    for _ in range(160):   # lone short strokes
        x, y = rnd.randint(2, 297), rnd.randint(46, base)
        if (x, y) in pts and (x, y) not in path: hd_blade(cv, x, y, rnd.randint(2, 3), rnd.choice((-1, 0, 1)), M5)
    # lit/shaded patches of dither: a few mown-looking lighter swirls on the plateau
    for k in range(20):
        x = rnd.randint(60, 240); y = rnd.randint(54, 86)
        for j in range(rnd.randint(6, 12)):
            if (x + j, y) in pts: cv.put(x + j, y, M5[0] if j % 2 else M5[1])
    # ---- silhouette: tufts of grass breaking the outline along the top and sides, little ruffles at the foot
    edge = [(x, y) for (x, y) in pts if (x, y - 1) not in pts or (x - 1, y) not in pts or (x + 1, y) not in pts]
    rnd.shuffle(edge)
    for (x, y) in edge[:150]:
        if y < base - 3: hd_tuft(cv, x, y, rnd.randint(2, 4), rnd.randint(3, 6), M5, rnd, 3, (1 if x > cx else -1) if abs(x - cx) > 60 else 0, 1 if x < cx + 30 and y < 110 else 2)
    for x in range(4, 297):   # ragged hem
        if (x, base) in pts and rnd.random() < .35: hd_blade(cv, x, base + rnd.choice((0, 1)), rnd.randint(2, 4), rnd.choice((-1, 0, 1)), M5)
        if (x, base) in pts and x % 3 == 0: cv.put(x, base, M5[4]); cv.put(x, base - 1, M5[3])
    # ---- clover patches
    def clover(x, y, bloom=None):
        for dx, dy in ((-2, 0), (2, 0), (0, -2), (0, 1)):
            cv.put(x + dx, y + dy, M5[1]); cv.put(x + dx + 1, y + dy, M5[2]); cv.put(x + dx, y + dy + 1, M5[2]); cv.put(x + dx + 1, y + dy + 1, M5[3])
            cv.put(x + dx, y + dy, M5[0]) if (dx + dy) % 2 else None
        if bloom: cv.put(x, y - 4, bloom[1]); cv.put(x - 1, y - 4, bloom[0]); cv.put(x + 1, y - 4, bloom[2]); cv.put(x, y - 5, bloom[0]); cv.put(x, y - 3, M5[3])
    for k in range(18):
        x, y = rnd.randint(14, 285), rnd.randint(70, base - 6)
        if (x, y) in pts and (x, y) not in path:
            clover(x, y, P5 if k % 3 == 0 else None)
            for j in range(3): clover(x + rnd.randint(-8, 8), y + rnd.randint(-4, 4)) if rnd.random() < .6 else None
    # ---- wildflower drifts
    def bloom(x, y, kind):
        st = rnd.randint(2, 4)
        for k in range(st): cv.put(x, y + k, M5[3] if k % 2 else M5[2])
        if kind == 0:   # daisy
            for dx, dy in ((-2, 0), (2, 0), (0, -2), (-1, -1), (1, -1), (-1, 1), (1, 1), (0, 2)): cv.put(x + dx, y + dy, CREAM)
            cv.put(x, y, G5[1]); cv.put(x - 1, y, G5[0]) if False else None
        elif kind == 1:   # buttercup
            for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)): cv.put(x + dx, y + dy, G5[1])
            cv.put(x, y, G5[0]); cv.put(x + 1, y + 1, G5[2])
        elif kind == 2:   # poppy
            for dx, dy in ((-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)): cv.put(x + dx, y + dy, E5[1 if dx < 1 else 2])
            cv.put(x, y, INK); cv.put(x - 1, y - 1, E5[0])
        elif kind == 3:   # campanula
            for dx, dy in ((-1, 0), (0, 0), (1, 0), (-1, 1), (1, 1), (0, -1)): cv.put(x + dx, y + dy, D5[1])
            cv.put(x, y - 1, D5[0]); cv.put(x, y + 1, D5[3])
        else:   # pink thrift
            for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)): cv.put(x + dx, y + dy, P5[1])
            cv.put(x, y, P5[0]); cv.put(x + 1, y + 1, P5[3])
    drifts = [(30, 118), (62, 132), (96, 108), (118, 136), (186, 106), (232, 120), (262, 134), (250, 100), (40, 98), (206, 134), (78, 90), (270, 108)]
    for k, (dx, dy) in enumerate(drifts):
        kinds = [(0, 1, 4), (1, 3), (2, 0), (3, 4), (1, 0), (4, 3)][k % 6]
        for j in range(rnd.randint(5, 9)):
            x, y = dx + rnd.randint(-13, 13), dy + int(rnd.randint(-6, 6))
            if (x, y) in pts and (x, y) not in path and y > 74 or (x, y) in pts and (x < 90 or x > 212) and y > 56 and (x, y) not in path: bloom(x, y, rnd.choice(kinds))
    # ---- rabbit holes
    def rabbit_hole(x, y, s=1):
        for yy in range(-6, 5):
            for xx in range(-9, 10):
                d = (xx / 9.0) ** 2 + (yy / 6.0) ** 2
                if d <= 1.25: cv.put(x + xx, y + yy, LT5[2] if d > 1.0 else LT5[1] if yy < -1 else LT5[3])
        for yy in range(-4, 5):
            for xx in range(-7, 8):
                d = (xx / 7.0) ** 2 + (yy / 4.6) ** 2
                if d <= 1 and yy > -4: cv.put(x + xx, y + yy, INK if d > .45 or yy < 2 else H("#150d14"))
        for xx in range(-8, 9): cv.put(x + xx, y - 6 + (xx * xx) // 40, LT5[0] if xx < 3 else LT5[1])   # lit dirt lip
        for xx in range(-5, 6, 2): cv.put(x + xx, y + 5, LT5[3]); cv.put(x + xx + 1, y + 6, LT5[4])
        for k in range(7): cv.put(x - 10 + rnd.randint(0, 20), y + 6 + rnd.randint(0, 3), LT5[rnd.choice((1, 2))])   # kicked-out dirt
        for xx in (-10, -6, 7, 11): hd_tuft(cv, x + xx, y - 3 if abs(xx) < 8 else y + 1, 3, 5, M5, rnd, 3, 1 if xx > 0 else -1)
        cv.put(x + 3, y + 1, CREAM); cv.put(x + 3, y + 2, CREAM)   # two small eyes shine in the dark
        cv.put(x - 1, y + 1, CREAM) if s else None
    rabbit_hole(58, 104); rabbit_hole(236, 112)
    # ---- mole hills
    def molehill(x, y, w=11, h=7):
        lump(cv, x, y, w, h, LT5, rnd, .12)
        for yy in range(y + h - 1, y + h + 3):
            for xx in range(x - w - 2, x + w + 3):
                if cv.get(xx, yy)[3] and cv.get(xx, yy) in LT5 and yy > y + h - 1 and (xx + yy) % 2: pass
        for k in range(8): hd_blob(cv, x - w + rnd.randint(0, 2 * w), y + rnd.randint(-h // 2, h // 2), 1.3, 1, LT5[rnd.choice((0, 1, 3))], rnd, lambda xx, yy: cv.get(xx, yy) in LT5)
        for xx in (-1, 0, 1): cv.put(x + xx, y - 1, INK) if abs(xx) < 1 or True else None
        cv.put(x - 1, y - 1, LT5[4]); cv.put(x + 1, y - 1, LT5[4]); cv.put(x, y - 2, LT5[3])
        for xx in range(x - w - 2, x + w + 3, 3):
            if rnd.random() < .7: hd_blade(cv, xx, y + h, rnd.randint(2, 4), rnd.choice((-1, 0, 1)), M5)
    molehill(100, 126); molehill(132, 134, 8, 5); molehill(214, 94, 9, 5); molehill(24, 130, 7, 4)
    # ---- the blanket, gingham on a slight tilt, with a turned-up corner and a fringe
    quad = [(102, 61), (190, 58), (202, 82), (92, 84)]
    def inq(x, y):
        m = Image.new("L", (1, 1)); return False
    mk = Image.new("L", (300, 160), 0); ImageDraw.Draw(mk).polygon(quad, fill=255); mp = mk.load()
    def gh(x, y):
        u = (x - 92 + (y - 58) * .5) // 8; v = (y - 58) // 4
        a, b = u % 2 == 0, v % 2 == 0
        c = E5[1] if (a and b) else E5[0] if (a or b) else CREAM
        if (x * 5 + y * 3) % 11 == 0 and c == CREAM: c = E5[0]
        return c
    for y in range(52, 92):   # soft drop shadow on the grass, lower right
        for x in range(90, 212):
            if not mp[x - 3, y - 3] and not mp[x, y] and (mp[x - 3, y - 3] or mp[x - 5, y - 4] or mp[x - 2, y - 5]): cv.put(x, y, M5[4] if (x + y) % 2 else M5[3])
    for y in range(52, 92):
        for x in range(90, 212):
            if mp[x, y]:
                c = gh(x, y)
                if y > 78 and (x + y) % 2: c = E5[2] if c != CREAM else A5[2]   # shaded front edge
                cv.put(x, y, c)
    for t in range(0, 100, 5):   # folds: a lit ridge and a dark valley, short diagonal strokes
        x = 100 + t; hd_line(cv, x, 64 + t // 10, x + 5, 69 + t // 10, E5[2], lambda a, b: mp[a, b])
    for x in range(94, 202):   # fringe
        yb = 84 - (x - 94) * 0 - (94 - 92 if False else 0)
        for y in range(70, 92):
            if mp[x, y] and not mp[x, y + 1] and (x % 2 == 0): cv.put(x, y + 1, E5[3]); cv.put(x, y + 2, CREAM if x % 4 == 0 else E5[1])
    for k in range(0, 6): cv.put(176 + k, 60 + k, CREAM); cv.put(176 + k, 61 + k, E5[3]) if False else None
    poly_corner = [(176, 58), (190, 58), (190, 68)]   # turned corner showing the paler back
    for (a, b) in ((177, 59), (178, 59), (179, 59), (180, 59), (181, 59), (182, 59), (183, 59), (184, 59), (185, 59), (186, 59), (187, 59), (188, 59), (189, 59), (178, 60), (179, 60), (180, 60), (181, 60), (182, 60), (183, 60), (184, 60), (185, 60), (186, 60), (187, 60), (188, 60), (189, 60), (180, 61), (181, 61), (182, 61), (183, 61), (184, 61), (185, 61), (186, 61), (187, 61), (188, 61), (189, 61), (182, 62), (183, 62), (184, 62), (185, 62), (186, 62), (187, 62), (188, 62), (189, 62), (184, 63), (185, 63), (186, 63), (187, 63), (188, 63), (189, 63), (186, 64), (187, 64), (188, 64), (189, 64), (188, 65), (189, 65)):
        cv.put(a, b, CREAM if (a + b) % 3 else A5[1])
    for k in range(10): cv.put(176 + k, 59 + k // 1 if False else 58 + k, E5[3]) if False else None
    hd_line(cv, 176, 58, 190, 66, E5[2], lambda a, b: mp[a, b]); hd_line(cv, 177, 58, 191, 66, E5[3], lambda a, b: mp[a, b])
    # items, back to front
    def cast(x, y, w, h=2):   # contact shadow on the blanket
        for xx in range(x, x + w):
            for yy in range(y, y + h):
                if mp[xx, yy] and (xx + yy) % 2 == 0: cv.put(xx, yy, E5[2] if cv.get(xx, yy) != E5[1] else E5[3])
    # basket with an open lid, bread sticking out
    cast(143, 72, 34)
    for yy in range(48, 72):
        for xx in range(142, 170):
            u = (xx - 142) / 27.0; t = 0 if u < .12 else 1 if u < .36 else 2 if u < .72 else 3
            wv = ((xx // 3) + (yy // 2)) % 2   # wicker weave
            t = min(4, t + (1 if wv and (yy % 2 == 0) else 0)); cv.put(xx, yy, W5[t])
    for xx in range(142, 170): cv.put(xx, 48, W5[0]); cv.put(xx, 49, W5[1]); cv.put(xx, 70, W5[4]); cv.put(xx, 71, W5[4])
    for yy in range(48, 72): cv.put(142, yy, W5[0]); cv.put(169, yy, W5[4])
    for yy in (56, 63): [cv.put(xx, yy, W5[4]) for xx in range(143, 169)]
    for k in range(30): cv.put(143 + k, 40 + int(7 * math.sin(k / 29.0 * math.pi)) * -1 + 7 if False else 49 - int(11 * math.sin(k / 29.0 * math.pi)), W5[1]); cv.put(143 + k, 50 - int(11 * math.sin(k / 29.0 * math.pi)), W5[3])
    for xx in range(143, 169):   # cloth over the top: gingham tucked in
        for yy in range(46, 51):
            cv.put(xx, yy, E5[1] if ((xx // 4) + (yy // 2)) % 2 == 0 else CREAM)
    for xx in range(143, 169, 2): cv.put(xx, 51, E5[2])
    # baguette poking out
    for k in range(24): cv.put(166 + k // 2 - 2 + 0, 44 - k // 2, G5[1] if k % 5 else G5[2]); cv.put(167 + k // 2, 44 - k // 2, G5[0] if k % 5 else G5[3])
    # thermos / jug
    cast(180, 76, 12)
    for yy in range(44, 71):
        for xx in range(180, 190):
            u = (xx - 180) / 9.0; t = 0 if u < .15 else 1 if u < .35 else 2 if u < .65 else 3 if u < .9 else 4
            cv.put(xx, yy, S5[t] if yy > 49 else E5[min(4, t + 0)])
    for xx in range(180, 190): cv.put(xx, 49, S5[4]); cv.put(xx, 62, S5[4]); cv.put(xx, 63, E5[1] if xx < 186 else E5[2]); cv.put(xx, 64, E5[1] if xx < 186 else E5[2]); cv.put(xx, 70, S5[4])
    cv.put(181, 52, CREAM); cv.put(181, 53, CREAM); cv.put(181, 54, S5[0])
    for k in range(5): cv.put(190, 52 + k, S5[3]); cv.put(191, 53 + k, S5[2]) if k % 4 == 1 else None   # handle
    # plate, sandwich, cheese, apples, grapes, cups, napkin
    cast(106, 78, 30, 3)
    ellp = lambda cx_, cy_, rx_, ry_, f: [f(x, y) for y in range(cy_ - ry_, cy_ + ry_ + 1) for x in range(cx_ - rx_, cx_ + rx_ + 1) if ((x - cx_) / float(rx_)) ** 2 + ((y - cy_) / float(ry_)) ** 2 <= 1]
    ellp(120, 72, 13, 5, lambda x, y: cv.put(x, y, SEA5[1] if ((x - 120) / 13.0) ** 2 + ((y - 72) / 5.0) ** 2 > .6 else CREAM))
    ellp(120, 72, 13, 5, lambda x, y: cv.put(x, y, SEA5[0] if (x + y) % 2 and ((x - 120) / 13.0) ** 2 + ((y - 72) / 5.0) ** 2 > .8 else cv.get(x, y)))
    for xx in range(108, 133): cv.put(xx, 77, SEA5[3]) if ((xx - 120) / 13.0) ** 2 < .85 else None
    for k in range(8): cv.put(111 + k, 71 + k % 2, A5[1])   # sandwich: bread
    for yy in range(66, 72):
        for xx in range(113, 127):
            if xx - 113 + (71 - yy) * 1 < 14 + 1 - abs(0) and xx - 113 > (71 - yy) * 1.0 - 1 and xx - 113 < 14 - (71 - yy) * 1.0:
                f = yy - 66; cv.put(xx, yy, A5[0] if f == 0 else M5[1] if f == 1 else P5[1] if f == 2 else A5[1] if f < 5 else A5[2])
    for xx in range(113, 127): cv.put(xx, 71, A5[3])
    cv.put(116, 67, CREAM); cv.put(120, 68, CREAM); cv.put(123, 67, A5[0])
    # cheese wedge on the plate
    for k in range(9):
        for yy in range(0, 5 - k // 2): cv.put(126 + k, 70 - yy + 1, G5[0] if yy == 4 - k // 2 else G5[1] if k < 5 else G5[2])
    cv.put(128, 70, G5[3]); cv.put(131, 71, G5[3]); cv.put(129, 69, G5[3])
    # apples
    for (ax, ay) in ((98, 78), (108, 82), (176, 80)):
        cast(ax - 4, ay + 4, 10)
        disc(cv, ax, ay, 4, E5); cv.put(ax - 2, ay - 2, CREAM); cv.put(ax - 1, ay - 2, E5[0]); cv.put(ax, ay - 5, W5[3]); cv.put(ax, ay - 4, W5[2]); cv.put(ax + 1, ay - 5, M5[1]); cv.put(ax + 2, ay - 5, M5[0]); cv.put(ax + 1, ay + 3, E5[4])
    # grapes
    for k, (gx, gy) in enumerate(((140, 72), (144, 72), (148, 72), (142, 76), (146, 76), (144, 80))):
        disc(cv, gx, gy, 2, D5); cv.put(gx - 1, gy - 1, CREAM) if k % 2 == 0 else None
    cv.put(144, 69, W5[3]); cv.put(145, 68, M5[2]); cv.put(146, 68, M5[1])
    # loaf with scoring
    cast(150, 80, 24, 2)
    for yy in range(73, 81):
        for xx in range(152, 174):
            d = ((xx - 163) / 11.0) ** 2 + ((yy - 79) / 7.0) ** 2
            if d <= 1 and yy <= 80: cv.put(xx, yy, G5[0] if d < .35 and yy < 77 else G5[1] if d < .7 else G5[2] if yy < 79 else G5[3])
    for k in range(3): hd_line(cv, 156 + k * 6, 77, 159 + k * 6, 74, CREAM if k != 1 else A5[0]); cv.put(157 + k * 6, 76, A5[2])
    # cups
    for (px_, py_) in ((194, 78), (200, 80)):
        for yy in range(py_ - 6, py_ + 1):
            for xx in range(px_ - 3, px_ + 4):
                w_ = 3 if yy < py_ - 1 else 2
                if abs(xx - px_) <= w_: cv.put(xx, yy, CREAM if xx < px_ else A5[0] if xx == px_ else S5[1])
        for xx in range(px_ - 3, px_ + 4): cv.put(xx, py_ - 6, S5[1]); cv.put(xx, py_ - 5, SEA5[2] if abs(xx - px_) < 3 else S5[2])
        cv.put(px_ + 4, py_ - 4, S5[2]); cv.put(px_ + 5, py_ - 3, S5[2]); cv.put(px_ + 4, py_ - 2, S5[2])
    # flag on a stick at the back-left corner
    hd_line(cv, 112, 62, 112, 30, W5[2]); hd_line(cv, 113, 62, 113, 30, W5[3]); cv.put(112, 29, G5[0]); cv.put(113, 29, G5[1])
    for xx in range(114, 132):
        h_ = int(7 - (xx - 114) * .35 + math.sin((xx - 114) / 2.5) * 1.2)
        for yy in range(31, 31 + h_): cv.put(xx, yy, G5[0] if yy == 31 else G5[1] if (xx + yy) % 5 else G5[2])
    for k in range(3): cv.put(118 + k * 4, 34, E5[1]); cv.put(119 + k * 4, 35, E5[1])
    # crumbs, a pair of ants carrying them off the blanket
    for (x, y) in ((130, 80), (134, 77), (170, 82), (186, 79), (116, 79)): cv.put(x, y, A5[1]); cv.put(x + 1, y, A5[2])
    for k in range(12):
        ax_, ay_ = 190 + k * 4 + (k % 3), 84 + k * 3 + (k % 2)
        if (ax_, ay_) in pts: cv.put(ax_, ay_, INK); cv.put(ax_ + 1, ay_, INK)
    # a butterfly and two bees over the flowers
    for (bx, by, c1, c2) in ((60, 78, P5[0], P5[2]), (242, 78, G5[0], G5[2])):
        for dx, dy in ((-3, -2), (-2, -2), (-2, -1), (-3, -1), (3, -2), (2, -2), (2, -1), (3, -1), (-2, 0), (-1, 0), (2, 0), (1, 0)): cv.put(bx + dx, by + dy, c1)
        cv.put(-1 + bx, by - 1, c2); cv.put(bx + 1, by - 1, c2); cv.put(bx, by - 1, INK); cv.put(bx, by, INK); cv.put(bx, by + 1, INK)
    # a few sun glints on the lit left shoulder
    for _ in range(14):
        x, y = rnd.randint(14, 120), rnd.randint(64, 110)
        if (x, y) in pts and (x, y) not in path and cv.get(x, y) in (M5[0], M5[1]): cv.put(x, y, M5[0]); cv.put(x + 1, y - 1, CREAM)
    hd_bounce(cv, pts, M5, lambda x, y: (x - cx) + (y - 60) > 60 or y > base - 3, 1, 4)
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
    nz = hd_noise(rnd, 8); nz2 = hd_noise(rnd, 3); nz3 = hd_noise(rnd, 22)
    # ---- water with dithered depth and ripples
    wat = set()
    for y in range(168, 200):
        for x in range(0, 300):
            e = ((x - 150) / 150.0) ** 2 + ((y - 186) / 15.0) ** 2
            if e <= 1 + (nz2(x, y) - .5) * .15 or (y < 188 and e <= 1.4 and False):
                v = .3 + (y - 170) / 30.0 * 3.0 + (nz(x, y) - .5) * 1.2; cv.put(x, y, SEA5[hd_tone(v, x, y)]); wat.add((x, y))
    for _ in range(70):
        x, y = rnd.randint(6, 290), rnd.randint(176, 196)
        if (x, y) in wat:
            for k in range(rnd.randint(3, 8)): cv.put(x + k, y, SEA5[0]) if (x + k, y) in wat else None; cv.put(x + k + 1, y + 1, SEA5[3]) if k % 2 == 0 and (x + k + 1, y + 1) in wat else None
    deck = lambda x: int(76 + 40 * ((x - 150) / 118.0) ** 2)
    ACX, ACY, ARX, ARY = 150, 160, 58.0, 42.0
    def rn(x, y): return math.sqrt(((x + .5 - ACX) / ARX) ** 2 + ((y + .5 - ACY) / ARY) ** 2)
    # ---- coursed masonry: irregular stones, each with its own tone, bevel and mortar
    courses = []; y = 36
    while y < 186:
        h = rnd.randint(9, 12); blocks = []; x = 30 - rnd.randint(0, 12)
        while x < 272:
            w = rnd.randint(14, 25); blocks.append((x, x + w, rnd.uniform(-.55, .55), rnd.random())); x += w
        courses.append((y, y + h, blocks)); y += h
    body = set()
    def inb(x, y): return 32 + (nz2(x * 2, 0) > .6) <= x <= 267 - (nz2(0, y * 2) > .6) and deck(x) <= y <= 183
    for (y0, y1, blocks) in courses:
        for (bx0, bx1, dv, r2) in blocks:
            for yy in range(y0, y1):
                for xx in range(bx0, bx1):
                    if not inb(xx, yy) or rn(xx, yy) < 1.0: continue
                    u = (xx - 32) / 236.0; v = .75 + 2.1 * u + dv * 1.6 + (yy - y0) / float(y1 - y0) * .5
                    lx, ly = xx - bx0, yy - y0; right, bot = xx == bx1 - 1, yy == y1 - 1
                    if lx == 0 or ly == 0 and False: v -= 0 
                    if right or bot: c = S5[4] if (right and bot) or (xx + yy) % 2 else S5[3]   # mortar line
                    elif yy == y0: c = S5[3]   # mortar above
                    else:
                        if ly == 1: v -= 1.0   # lit top edge
                        if lx == 0: v -= .8   # lit left edge
                        if yy == y1 - 2: v += .8
                        if xx == bx1 - 2: v += .8
                        if (xx * 7 + yy * 3 + int(r2 * 50)) % 17 == 0: v += rnd.choice((-1.2, 1.2))
                        v += (nz2(xx + 11, yy) - .5) * .9
                        c = S5[hd_tone(v, xx, yy)]
                    cv.put(xx, yy, c); body.add((xx, yy))
    # shadow under the parapet and on the right, stains below the waterline of the wall
    for (xx, yy) in list(body):
        if yy > 160 and nz3(xx * 1.4, yy) > .45 and cv.get(xx, yy) in S5[:3] and (xx + yy) % 2 == 0: cv.put(xx, yy, S5[3])
    # ---- coping stones on the parapet
    x = 34
    while x < 266:
        w = rnd.randint(11, 17); yb = deck(x + w // 2); tone = rnd.uniform(-.4, .4)
        for xx in range(x, min(268, x + w)):
            yy_b = deck(xx)
            for yy in range(yy_b - 6, yy_b):
                ly = yy - (yy_b - 6)
                if xx == x + w - 1: c = S5[4]
                elif ly == 0: c = S5[0] if xx > x else CREAM
                elif ly == 1: c = S5[0]
                elif ly < 4: c = S5[hd_tone(.9 + tone + .7 * (xx - 32) / 236.0 + (nz2(xx, yy) - .5) * .8, xx, yy)]
                elif ly == 5: c = S5[3]
                else: c = S5[2]
                cv.put(xx, yy, c)
        x += w
    for xx in range(32, 269):   # mortar between top of coping and the wall; chipped nicks
        if nz2(xx, 9) > .72: cv.put(xx, deck(xx) - 6, CLEAR)
    # ---- the arch: radial voussoirs, keystone, dark tunnel with a bright far end, water inside
    for yy in range(112, 200):
        for xx in range(88, 213):
            r = rn(xx, yy)
            if r >= 1.0: continue
            wv = (yy >= 183)
            if yy >= 176 and r < 1.0 and (xx, yy) in wat or yy > 176 and yy < 200: pass
            d = ((xx - 150) / 36.0) ** 2 + ((yy - 166) / 24.0) ** 2   # far end
            if r > .8: c = INK if yy < 176 else SEA5[3]
            elif d < 1:
                gy = (yy - 142) / 40.0; c = M5[hd_tone(.3 + gy * 3 + (nz2(xx, yy) - .5), xx, yy)] if yy < 170 else SEA5[hd_tone(.3 + (yy - 164) / 12.0 * 2.2, xx, yy)]
            else: c = S5[4]
            if yy >= 176: c = SEA5[hd_tone(2.2 + (nz(xx, yy) - .5) * 1.4 + (r - .5) * 2.0, xx, yy)] if c != INK else SEA5[3]
            cv.put(xx, yy, c)
    for xx in range(100, 200):   # reflected arch edge in the water, light dashes
        if (xx * 3) % 7 < 3: cv.put(xx, 178 + (xx // 5) % 2, SEA5[0])
    for k in range(5): cv.put(132 + k * 7, 150 + (k % 2), CREAM); cv.put(133 + k * 7, 151 + (k % 2), CREAM) if k % 2 else None   # sun-glints on the far grass
    N = 22; ang_edges = [180 + 180.0 * i / N for i in range(N + 1)]
    for yy in range(96, 176):
        for xx in range(84, 216):
            r = rn(xx, yy); ky = 1.0 if abs(xx - 150) > 8 else 1.0
            outer = 1.27 + (.12 if abs(xx - 150) < 11 and yy < 125 else 0)
            if not (1.0 <= r < outer): continue
            a = math.degrees(math.atan2((yy + .5 - ACY) / ARY, (xx + .5 - ACX) / ARX)) % 360
            if not (180 <= a <= 360): continue
            k = int((a - 180) / (180.0 / N)); fa = ((a - 180) % (180.0 / N)) / (180.0 / N)
            ringu = (r - 1.0) / (outer - 1.0)
            keystone = abs(xx - 150) < 8 and r > 1.0
            if fa < .06 or ringu > .94: c = S5[4]
            else:
                dv = ((k * 7 + 3) % 5 - 2) * .28 + (.25 if k % 2 else -.25)
                v = .8 + (k / float(N)) * 1.8 + dv + ringu * .45 - (ringu < .2) * .3 + (nz2(xx, yy) - .5) * .8
                if ringu < .12: v -= .5   # lit lower lip
                if fa < .2: v -= .5
                if fa > .8: v += .6
                c = S5[hd_tone(v, xx, yy)]
                if keystone: c = S5[hd_tone(.5 + ringu * .6 + (nz2(xx, yy) - .5) * .5, xx, yy)] if abs(xx - 150) < 7 else S5[4]
            cv.put(xx, yy, c)
    for k in range(-6, 7): cv.put(150 + k, 123, S5[4]) if abs(k) == 6 else None
    # shade under the arch lip: dark band dither at the opening edge
    for yy in range(120, 176):
        for xx in range(92, 209):
            r = rn(xx, yy)
            if .93 <= r < 1.0 and (xx + yy) % 2 == 0 and yy < 176: cv.put(xx, yy, INK)
    # ---- weeds in the joints, stonecrop, lichen, cracks, chips
    for _ in range(70):
        x, y = rnd.randint(36, 264), rnd.randint(90, 175)
        if (x, y) in body and (y - 36) % 10 < 3 and rn(x, y) > 1.3: hd_tuft(cv, x, y, 2, rnd.randint(3, 5), M5, rnd, 2, rnd.choice((-1, 0, 1)), 2)
    for _ in range(60):   # lichen specks, gold and pale green
        x, y = rnd.randint(36, 264), rnd.randint(88, 168)
        if (x, y) in body and cv.get(x, y) in S5[:3]: cv.put(x, y, G5[1] if rnd.random() < .5 else M5[0]); cv.put(x + 1, y, G5[0]) if rnd.random() < .5 and (x + 1, y) in body and cv.get(x + 1, y) in S5[:3] else None
    for (x, y, n, d) in ((64, 124, 18, 1), (240, 132, 16, -1), (112, 100, 12, 1), (196, 106, 14, -1)):   # cracks
        for k in range(n):
            xx = x + d * (k // 2) + (k % 3 == 0) * d; yy = y + k
            if (xx, yy) in body and rn(xx, yy) > 1.3: cv.put(xx, yy, S5[4]); cv.put(xx + 1, yy, S5[3]) if k % 2 == 0 and (xx + 1, yy) in body else None
    for _ in range(26):   # chipped corners: a light flake and a dark notch
        x, y = rnd.randint(40, 262), rnd.randint(86, 176)
        if (x, y) in body and rn(x, y) > 1.3 and (y - 36) % 10 == 1: cv.put(x, y, S5[0]); cv.put(x + 1, y, S5[0]); cv.put(x, y + 1, S5[4]); cv.put(x + 1, y + 1, S5[4])
    # ---- moss climbing from the water line, drips of green stain
    for (x, y) in list(body):
        if y > 150 and rn(x, y) > 1.28 and nz3(x * 1.2 + 10, y * 1.6) > .46 + (182 - y) * .012 and cv.get(x, y) in S5: cv.put(x, y, M5[hd_tone((nz2(x, y) - .5) * 2.5 + 1.8 - (y - 160) * .02 + (x - 150) * .005, x, y)])
    for x in range(34, 268, 2):
        if (x, 182) in body and rn(x, 182) > 1.0 and rnd.random() < .6: hd_blade(cv, x, 183, rnd.randint(2, 5), rnd.choice((-1, 0, 1)), M5, False, 2)
    for _ in range(36):   # green drip streaks from the coping
        x = rnd.randint(36, 264); y0 = deck(x)
        if (x, y0 + 4) in body and rn(x, y0 + 4) > 1.3:
            for k in range(rnd.randint(4, 12)):
                if (x, y0 + k) in body and rn(x, y0 + k) > 1.2: cv.put(x, y0 + k, M5[2] if k % 2 else M5[3])
    # ---- ivy: winding vines with heart leaves
    def leaf(x, y):
        cv.put(x, y, L5[1]); cv.put(x + 1, y, L5[2]); cv.put(x - 1, y, L5[0]); cv.put(x, y + 1, L5[2]); cv.put(x, y - 1, L5[0]); cv.put(x + 1, y + 1, L5[3]); cv.put(x - 1, y - 1, L5[0] if (x + y) % 2 else CREAM)
    def vine(x0, y0, n, drift, thick=1):
        x, y = x0, y0; ph = rnd.random() * 6
        for k in range(n):
            x = x0 + int(math.sin(k / 3.5 + ph) * 2) + (k * drift) // 8; y = y0 + k
            cv.put(x, y, L5[4] if k % 2 else L5[3])
            if k % 3 == 0: leaf(x + (2 if (k // 3) % 2 else -2), y)
            if k % 7 == 3 and thick: leaf(x + (3 if (k // 7) % 2 else -3), y + 2)
    for (x, y, n, d) in ((54, 112, 40, -2), (62, 98, 26, 2), (78, 106, 24, 3), (226, 116, 40, 2), (244, 100, 30, -2), (212, 96, 22, -3), (110, 96, 18, 1), (190, 94, 20, -1), (44, 140, 24, 0), (256, 138, 24, 0)):
        for j in range(3): leaf(x + rnd.randint(-5, 5), y + rnd.randint(-3, 1))
        vine(x, y, n, d)
    for (x, y) in ((86, 114), (204, 112)): lump(cv, x, y, 8, 5, L5, rnd, .1); leaf(x - 5, y + 5); leaf(x + 4, y + 6)
    # ---- flowers in the coping joints and pennants of wild thyme
    for x in (46, 70, 110, 130, 172, 194, 238, 258):
        yb = deck(x) - 6; k = rnd.randint(2, 5)
        for j in range(k): cv.put(x, yb - j, M5[2]); cv.put(x + 1, yb - j + 1, M5[3]) if j == 1 else None
        col = (CREAM, P5[1], G5[0], D5[1])[x % 4]; cv.put(x, yb - k - 1, col); cv.put(x - 1, yb - k, col); cv.put(x + 1, yb - k, col); cv.put(x, yb - k, G5[1]); cv.put(x, yb - k - 2, col)
    # ---- foam and weed at the pier feet, sunlight dashes
    for x in range(30, 272, 3):
        if (x, 183) in body or (x, 182) in body: cv.put(x, 184, CREAM if x % 2 else SEA5[0]); cv.put(x + 1, 185, SEA5[0])
    # ---- proud little flag on the crown
    box(cv, 148, 152, 14, deck(150) - 4, W5, rnd, 0)
    for yy in range(14, deck(150) - 6): cv.put(148, yy, W5[0]); cv.put(151, yy, W5[3]) if yy % 5 else None
    for xx in range(152, 184):
        h_ = int(10 - (xx - 152) * .22 + math.sin((xx - 152) / 3.0) * 1.5)
        for yy in range(22 + int(math.sin((xx - 152) / 4.0 + 1) * 1.5), 22 + int(math.sin((xx - 152) / 4.0 + 1) * 1.5) + h_): cv.put(xx, yy, E5[0] if yy < 25 else E5[1] if yy < 29 else E5[2])
    for k in range(3): cv.put(158 + k * 6, 28, CREAM); cv.put(159 + k * 6, 29, CREAM)
    ell(cv, 150, 12, 3, 3, G5[1]); cv.put(149, 11, G5[0])
    # ---- the troll-sized toll sign with plank grain and nails
    box(cv, 14, 21, 96, 182, W5, rnd, 0); box(cv, 36, 43, 96, 182, W5, rnd, 0)
    for (px_, py0) in ((17, 100), (39, 104), (16, 140), (40, 150)): cv.put(px_, py0, W5[4]); cv.put(px_ + 1, py0 + 1, W5[3])
    for yy in range(120, 182, 6): cv.put(16, yy, W5[4]); cv.put(17, yy + 1, W5[4]); cv.put(38, yy + 2, W5[4])
    for yy in range(60, 118):
        for xx in range(0, 56):
            pl = (yy - 60) // 14; u = (xx / 55.0)
            t = hd_tone(.5 + u * 1.6 + (pl % 2) * .5 + (nz2(xx + 30 * pl, yy * 4) - .5) * 1.6, xx, yy)
            cv.put(xx, yy, W5[t])
    for yy in range(60, 118): cv.put(0, yy, W5[0]); cv.put(1, yy, W5[1]) if yy % 2 else None; cv.put(55, yy, W5[4]); cv.put(54, yy, W5[3])
    for xx in range(0, 56): cv.put(xx, 60, W5[0]); cv.put(xx, 117, W5[4]); cv.put(xx, 116, W5[3]) if xx % 2 else None
    for pl in range(1, 4): [cv.put(xx, 60 + pl * 14, W5[4]) for xx in range(1, 55)]
    for (nx_, ny_) in ((4, 64), (51, 64), (4, 113), (51, 113)): cv.put(nx_, ny_, S5[0]); cv.put(nx_ + 1, ny_ + 1, INK)
    for yy, ln in ((73, 38), (87, 30), (101, 40)):
        for k in range(ln):
            if (k % 7) != 6: cv.put(9 + k, yy, INK); cv.put(9 + k, yy + 1, W5[4]) if k % 3 else None
        for k in range(0, ln, 7): cv.put(9 + k, yy - 1, INK) if k % 2 == 0 else None
    for (cx_, shade_) in ((14, 1), (24, 2), (34, 1)):
        lump(cv, cx_, 106, 4, 3, S5, rnd, 0)
    cv.put(48, 106, E5[1]); cv.put(49, 106, E5[2]); cv.put(48, 107, E5[3])
    for x in (6,): flower(cv, x, 178, CREAM, G5[1], 1); hd_tuft(cv, 10, 182, 3, 6, M5, rnd, 3, 0, 2)
    for x in (14, 20, 40): hd_tuft(cv, x, 183, 3, 6, M5, rnd, 3, 0, 2)
    _reeds(cv, 260, 192, 4, rnd); _reeds(cv, 8, 196, 3, rnd)
    hd_bounce(cv, body, S5, lambda x, y: x > 255 or y > 178, 2, 4)
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
    "232-well": (180, 240, lm_well), "232-crossroads": (220, 240, lm_crossroads), "232-picnicrise": (300, 156, lm_picnicrise),
    "236-wildflowers": (300, 170, lm_wildflowers), "236-dandelions": (250, 190, lm_dandelions), "236-stonebridge": (300, 200, lm_stonebridge),
    "236-beanpoles": (280, 210, lm_beanpoles), "236-windmill": (260, 252, lm_windmill), "236-haywagon": (270, 180, lm_haywagon),
    "311-taprow": (290, 240, lm_taprow), "311-bucketstacks": (230, 230, lm_bucketstacks), "311-sugarshack": (280, 260, lm_sugarshack),
    "311-pancakelane": (320, 236, lm_pancakelane),
}
