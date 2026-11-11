"""SHARED set pieces (94) for the routes outside the Maplewold: every non-`end-*` slug of claude/trail-landmarks/setpieces.json.
Same look as gen2.py / landmarks_endpieces.py (hard pixels, 5-tone ramps, lump shading, auto outline, painterly pass by gen2.landmark()).
A piece is a small motif library (trees, bridges, stones, flowers, water, huts...) composed per slug in PIECES at the bottom; the land only changes the palette.
Canvas 170 x 130 unless the piece says otherwise; the bottom edge is the feet line."""
import json, os, math, random, importlib.util
import gen2
from gen2 import RAMP, INK, CREAM, lump, r5

_here = os.path.dirname(os.path.abspath(__file__))
_sp = importlib.util.spec_from_file_location("_endhelpers", os.path.join(_here, "landmarks_endpieces.py")); E = importlib.util.module_from_spec(_sp); _sp.loader.exec_module(E)
PAL, fm, poly, ell, rect, line, col, planks, sparkle, glow, lantern, post, smoke = E.PAL, E.fm, E.poly, E.ell, E.rect, E.line, E.col, E.planks, E.sparkle, E.glow, E.lantern, E.post, E.smoke
R5 = {k: r5(v) for k, v in RAMP.items()}
W0, H0 = 170, 130

class Ctx:
    def __init__(s, cv, rnd, land, w, h):
        s.cv, s.rnd, s.w, s.h, s.fy = cv, rnd, w, h, h - 8
        g, r, t, a, gl = [R5[n] for n in PAL[land]]
        s.g, s.r, s.t, s.a, s.gl = g, r, t, a, gl
        s.land = land
def ground(c, rx=None, ry=12, g=None, cy=None):
    lump(c.cv, c.w // 2, cy if cy is not None else c.fy - 4, rx or c.w // 2 - 8, ry, g or c.g, c.rnd, .10)
def tufts(c, n, x0=8, x1=None, g=None):
    g = g or c.g; x1 = x1 or c.w - 8
    for _ in range(n):
        x = c.rnd.randint(x0, x1); y = c.fy - c.rnd.randint(0, 8)
        for k in range(c.rnd.randint(3, 6)): c.cv.put(x + k // 3, y - k, g[1 + (k % 2)])
        for k in range(c.rnd.randint(2, 4)): c.cv.put(x - 2 - k // 3, y - k, g[2])
def rock(c, x, y, rx, ry, R=None): lump(c.cv, x, y, rx, ry, R or c.r, c.rnd, .10)
def flower(c, x, y, R, centre=None, s=2):
    cv = c.cv; line(cv, x, y, x, y + 6, R5["leaf"][2])
    for dx, dy in ((-s, 0), (s, 0), (0, -s), (0, s)): rect(cv, x + dx - 1, y + dy - 1, x + dx + 1, y + dy + 1, R[1])
    rect(cv, x - 1, y - 1, x + 1, y + 1, centre or R5["gold"][1])
    cv.put(x - s, y - 1, R[0])
def shroom(c, x, y, s=1):
    cv = c.cv; rect(cv, x - s, y - 2 * s, x + s + 1, y + 1, CREAM); ell(cv, x, y - 3 * s - 1, 3 * s + 2, 2 * s + 1, R5["ember"][1])
    for dx in (-2 * s, 1 * s): cv.put(x + dx, y - 3 * s - 1, CREAM)
    cv.put(x - 2 * s - 1, y - 3 * s - 2, R5["ember"][0])
def leafy(c, x, yb, s, R=None, th=9, trunkc=None):
    cv = c.cv; R = R or R5["leaf"]; T = trunkc or R5["wood"]
    col(cv, x - th // 2, x + th // 2 + 1, yb - int(s * 1.1), yb, T, c.rnd, .04)
    for (dx, dy, rx, ry) in ((0, -int(s * 1.5), s, int(s * .85)), (-int(s * .7), -int(s * 1.15), int(s * .7), int(s * .6)), (int(s * .7), -int(s * 1.1), int(s * .7), int(s * .6))):
        lump(cv, x + dx, yb + dy, rx, ry, R, c.rnd, .12)
def pinetree(c, x, yb, s, R=None, snow=False):
    cv = c.cv; R = R or R5["pine"]
    col(cv, x - 2, x + 3, yb - 8, yb, R5["wood"], c.rnd, 0)
    for i in range(4):
        y = yb - 8 - i * int(s * .28); wdt = int(s * .55 * (1 - i * .2)) + 4
        poly(cv, [(x - wdt, y), (x, y - int(s * .5)), (x + wdt, y)], R[1 + (i % 2)]); poly(cv, [(x - wdt + 2, y - 1), (x, y - int(s * .5) + 2), (x, y - 1)], R[0 if i % 2 else 1])
        if snow: poly(cv, [(x - wdt // 2, y - int(s * .22)), (x, y - int(s * .5)), (x + wdt // 2, y - int(s * .22))], R5["snow"][0])
def palm(c, x, yb, lean, h, frond=None):
    cv = c.cv; W = R5["wood"]; F = frond or R5["leaf"]
    pts = [(x + int(lean * (k / float(h)) ** 2), yb - k) for k in range(h)]
    for i, (px, py) in enumerate(pts):
        for dx in range(-2, 3): cv.put(px + dx, py, W[0 if dx < -1 else 1 if dx < 1 else 2 if dx < 2 else 3] if (py // 4) % 2 else W[2])
    tx, ty = pts[-1]
    for ang in (-160, -130, -100, -70, -40, -10, 20, 160):
        a = math.radians(ang)
        for k in range(26):
            fx = tx + int(math.cos(a) * k); fy = ty + int(math.sin(a) * k * .5 + (k * k) / 55.0)
            cv.put(fx, fy, F[1 + (k % 3 == 0)]); cv.put(fx, fy + 1, F[2]); cv.put(fx, fy - 1, F[0]) if k > 6 and k < 20 else None
    return tx, ty
def cactus(c, x, yb, h, arms=2):
    cv = c.cv; G = R5["leaf"]
    col(cv, x - 4, x + 5, yb - h, yb, G, c.rnd, .05); lump(cv, x, yb - h, 4, 4, G, c.rnd, 0)
    for k in range(yb - h + 4, yb - 2, 6): cv.put(x - 1, k, G[0]); cv.put(x + 2, k, G[4])
    for i in range(arms):
        sd = -1 if i % 2 == 0 else 1; ay = yb - h // 2 - i * 8
        col(cv, x + sd * 4 if sd > 0 else x - 14, x + 13 if sd > 0 else x - 4, ay, ay + 5, G, c.rnd, 0)
        ax = x + sd * 11; col(cv, ax - 2, ax + 3, ay - 12, ay + 5, G, c.rnd, .05); lump(cv, ax, ay - 12, 2, 3, G, c.rnd, 0)
def fern(c, x, yb, h, R=None, n=6):
    cv = c.cv; R = R or R5["leaf"]
    for i in range(n):
        a = math.radians(-160 + i * (140.0 / max(1, n - 1)))
        for k in range(h):
            fx = x + int(math.cos(a) * k * .7); fy = yb - int(-math.sin(a) * k * .9) + int(k * k / (h * 1.8))
            cv.put(fx, fy, R[1 + (k % 4 == 0)]); cv.put(fx, fy + 1, R[2]); cv.put(fx + (1 if k % 3 == 0 else -1), fy - 1, R[0]) if k % 2 else None
def reeds(c, x, yb, n, spread=4, h0=22):
    cv = c.cv
    for i in range(n):
        xx = x + i * spread + c.rnd.randint(-1, 1); h = h0 + c.rnd.randint(0, 14)
        for k in range(h): cv.put(xx + (k * 3 // h) % 2, yb - k, R5["moss"][1 if k % 5 else 0])
        if i % 2 == 0:
            for k in range(6): cv.put(xx, yb - h - k, R5["wood"][2]); cv.put(xx + 1, yb - h - k, R5["wood"][3])
def pond(c, cx, cy, rx, ry, R=None, glints=True):
    R = R or R5["sea"]; cv = c.cv
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            if (x - cx) ** 2 / float(rx * rx) + (y - cy) ** 2 / float(ry * ry) <= 1:
                t = 3 if y > cy + ry // 2 else 2 if y > cy else 1 if y > cy - ry // 2 else 0
                if (x * 5 + y * 3) % 9 == 0: t = max(0, t - 1)
                cv.put(x, y, R[t])
    for x in range(cx - rx, cx + rx + 1):   # bank rim
        for y in range(cy - ry - 2, cy + ry + 3):
            if cv.get(x, y)[3] == 0 and any(cv.get(x + dx, y + dy) in R for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))): cv.put(x, y, c.g[3] if y > cy else c.g[0])
    if glints:
        for _ in range(max(2, rx // 9)):
            x, y = c.rnd.randint(cx - rx // 2, cx + rx // 2 - 6), c.rnd.randint(cy - ry // 2, cy + ry // 2)
            for k in range(5): cv.put(x + k, y, R[0]); cv.put(x + k + 1, y + 1, R[2]) if k > 1 else None
def lily(c, x, y, s=7, bloom=False):
    ell(c.cv, x, y, s, s // 2 + 1, R5["leaf"][2]); ell(c.cv, x - 1, y - 1, s - 2, s // 2, R5["leaf"][1]); line(c.cv, x, y, x + s - 1, y, R5["sea"][2])
    if bloom: ell(c.cv, x, y - 2, 2, 2, R5["petal"][1]); c.cv.put(x, y - 2, CREAM)
def crab(c, x, y, s=1):
    cv = c.cv; E_ = R5["ember"]; lump(cv, x, y, 6 * s, 4 * s, E_, c.rnd, 0)
    for sx in (-1, 1):
        lump(cv, x + sx * 8 * s, y - 3 * s, 3 * s, 2 * s + 1, E_, c.rnd, 0)
        for k in range(3): cv.put(x + sx * (5 * s + k), y + 3 * s + k // 2, E_[3])
        cv.put(x + sx * 2 * s, y - 5 * s, INK); cv.put(x + sx * 2 * s, y - 4 * s, INK)
def frog(c, x, y, s=1):
    cv = c.cv; G = R5["moss"]; lump(cv, x, y, 5 * s, 3 * s + 1, G, c.rnd, 0)
    for sx in (-1, 1): ell(cv, x + sx * 3 * s, y - 3 * s, s + 1, s + 1, CREAM); cv.put(x + sx * 3 * s, y - 3 * s, INK)
    for k in range(-2 * s, 2 * s): cv.put(x + k, y + 1, R5["petal"][1]) if abs(k) < s else None
def bird(c, x, y, R, s=1, beak=None):
    cv = c.cv; lump(cv, x, y, 5 * s, 4 * s, R, c.rnd, 0); lump(cv, x + 4 * s, y - 4 * s, 3 * s, 3 * s, R, c.rnd, 0)
    for k in range(3): cv.put(x + 7 * s + k, y - 4 * s + k // 2, beak or R5["gold"][1])
    cv.put(x + 5 * s, y - 5 * s, INK); line(cv, x - 5 * s, y + s, x - 10 * s, y + 3 * s, R[3], 2); line(cv, x, y + 4 * s, x, y + 7 * s, R5["gold"][2])
def fish(c, x, y, R, s=1, flip=False):
    d = -1 if flip else 1; cv = c.cv
    lump(cv, x, y, 5 * s, 3 * s, R, c.rnd, 0); poly(cv, [(x - d * 4 * s, y), (x - d * 8 * s, y - 3 * s), (x - d * 8 * s, y + 3 * s)], R[2]); cv.put(x + d * 2 * s, y - 1, INK)
def shell(c, x, y, s=3, R=None):
    R = R or R5["sand"]; cv = c.cv
    for dy in range(-s, 1):
        w = s + dy + 1
        for dx in range(-w, w + 1): cv.put(x + dx, y + dy, R[0 if (dx + dy) % 3 else 1])
    for k in range(-s + 1, s, 2): cv.put(x + k, y, R[3]); cv.put(x + k // 2, y - s // 2, R[3])
def stone_stack(c, x, yb, n, rx, R=None):
    for i in range(n): rock(c, x + (i % 2) * 2 - 1, yb - i * (rx // 2 + 1) - 3, rx - i * 2, rx // 2 + 2, R)
def standing(c, cx, yb, wd, hh, lean=0, R=None, marks=False):
    R = R or c.r; cv = c.cv; top = yb - hh
    pts = [(cx - wd, yb), (cx - wd + 2 + lean, top + 8), (cx + lean, top), (cx + wd - 2 + lean, top + 6), (cx + wd, yb)]
    fm(cv, lambda d: d.polygon(pts, fill=255), lambda x, y: R[0 if x < cx - wd * .4 else 1 if x < cx + wd * .1 else 2 if x < cx + wd * .6 else 3] if (x * 3 + y) % 13 else R[4])
    if marks:
        for k in range(3): cv.put(cx - 2 + k * 2, top + 12 + k * 3, c.a[1]); cv.put(cx - 2 + k * 2, top + 13 + k * 3, c.a[0])
def sign_flag(c, x, y0, y1, flag): post(c.cv, x, y0, y1, 3, c.t, c.rnd); rect(c.cv, x + 2, y0, x + 14, y0 + 8, flag[1]); rect(c.cv, x + 2, y0, x + 14, y0 + 2, flag[0])
def waves(c, x0, x1, y, R=None):
    R = R or R5["sea"]
    for x in range(x0, x1):
        yy = y + int(round(math.sin(x / 6.0) * 1.5)); c.cv.put(x, yy, CREAM); c.cv.put(x, yy + 1, R[1]) if x % 3 else None
def band(c, x0, x1, y0, y1, R):
    for y in range(y0, y1):
        t = 0 if y < y0 + (y1 - y0) // 3 else 1 if y < y0 + 2 * (y1 - y0) // 3 else 2
        for x in range(x0, x1): c.cv.put(x, y, R[t + (1 if (x * 3 + y * 5) % 17 == 0 else 0)])
def ripple_lines(c, x0, x1, y0, rows, R, dy=5):
    for j in range(rows):
        for x in range(x0 + j * 3, x1 - j * 3):
            yy = y0 + j * dy + int(round(math.sin(x / 5.0 + j) * 1.3)); c.cv.put(x, yy, R[0]); c.cv.put(x, yy + 1, R[3]) if x % 2 else None
def bridge_plank(c, x0, x1, y, hrail=14, gap=None, R=None, rails=True):
    R = R or c.t; cv = c.cv
    n = (x1 - x0) // 9
    for i in range(n):
        if gap is not None and i == gap: continue
        planks(cv, x0 + i * 9, x0 + i * 9 + 8, y, y + 6, R, c.rnd, 99); rect(cv, x0 + i * 9, y + 6, x0 + i * 9 + 8, y + 7, R[4])
    if rails:
        for xx in (x0 + 2, x1 - 4): col(cv, xx, xx + 3, y - hrail, y + 8, R, c.rnd, 0)
        rect(cv, x0, y - hrail, x1, y - hrail + 3, R[1]); rect(cv, x0, y - hrail, x1, y - hrail + 1, R[0])
def hut_roof(c, x0, x1, ytop, ybot, R, apex=None):
    ax = (x0 + x1) // 2
    poly(c.cv, [(x0, ybot), (ax, ytop), (x1, ybot)], R[2]); poly(c.cv, [(x0 + 4, ybot - 2), (ax, ytop + 5), (x1 - 4, ybot - 2)], R[1])
    line(c.cv, ax, ytop + 5, x1 - 4, ybot - 2, R[0], 2)

# ---------------------------------------------------------------- the pieces
def grass_plank_footbridge(c):
    ground(c); pond(c, 85, c.fy - 8, 68, 8, R5["sea"], False); rect(c.cv, 14, c.fy - 18, 156, c.fy - 12, c.g[3])
    bridge_plank(c, 40, 130, c.fy - 26, 12); tufts(c, 10)
def grass_picnic_knoll(c):
    ground(c, 70, 14); lump(c.cv, 85, c.fy - 20, 66, 28, c.g, c.rnd, .1); lump(c.cv, 86, c.fy - 22, 30, 7, [c.g[3], c.g[4], c.g[4], c.g[4], c.g[4]], c.rnd, .05)
    rect(c.cv, 70, c.fy - 26, 100, c.fy - 22, R5["petal"][1]); rect(c.cv, 70, c.fy - 26, 100, c.fy - 25, R5["petal"][0])
    for x in range(70, 100, 6): rect(c.cv, x, c.fy - 26, x + 3, c.fy - 22, CREAM)
    ell(c.cv, 112, c.fy - 22, 5, 4, R5["wood"][1]); rect(c.cv, 109, c.fy - 26, 115, c.fy - 25, R5["wood"][0]); lump(c.cv, 112, c.fy - 26, 5, 3, R5["gold"], c.rnd, 0); tufts(c, 8)
def grass_bramble_gap(c):
    ground(c)
    for sx in (-1, 1):
        for i in range(4): lump(c.cv, 85 + sx * (26 + i * 12), c.fy - 20 - (i % 2) * 6, 17, 20 - (i % 2) * 3, R5["leaf"], c.rnd, .15)
    for sx in (-1, 1):
        for k in range(14): c.cv.put(85 + sx * (14 + k * 2), c.fy - 8 - (k * 3) % 29, R5["ember"][1] if k % 3 == 0 else R5["wood"][3]) if False else None
        for (bx, by) in ((26, 30), (40, 18), (126, 26), (140, 36), (60, 48), (112, 50)): ell(c.cv, bx if sx > 0 else 170 - bx, c.fy - by, 3, 3, R5["petal"][2]) if sx > 0 else ell(c.cv, bx, c.fy - by, 3, 3, R5["ember"][2])
    ell(c.cv, 85, c.fy - 3, 12, 3, R5["litter"][2]); tufts(c, 6, 60, 110)
def grass_shepherd_wall(c):
    ground(c, 80, 12)
    for i in range(7):
        x = 6 + i * 21 if i < 4 else 10 + i * 21
        if i == 4: continue
        for row in range(3): rock(c, x + (row % 2) * 6, c.fy - 10 - row * 11, 12, 6, R5["stone"])
    for k in range(2): col(c.cv, 86 + k * 36, 91 + k * 36, c.fy - 44, c.fy - 4, c.t, c.rnd, .03)
    planks(c.cv, 86, 126, c.fy - 40, c.fy - 34, c.t, c.rnd, 99); planks(c.cv, 86, 126, c.fy - 22, c.fy - 16, c.t, c.rnd, 99); line(c.cv, 90, c.fy - 40, 124, c.fy - 18, c.t[1], 2); tufts(c, 8)
def grass_wind_combed(c):
    ground(c, 80, 14)
    for i in range(34):
        x = 12 + (i * 37) % 150; y = c.fy - 4 - (i * 11) % 16
        for k in range(9): c.cv.put(x + k // 2 + k // 3, y - k // 2 - (k % 2), c.g[0 if k > 6 else 1 + (k % 2)])
    line(c.cv, 120, c.fy - 70, 158, c.fy - 36, CREAM); line(c.cv, 120, c.fy - 70, 112, c.fy - 76, CREAM)
    poly(c.cv, [(112, c.fy - 84), (122, c.fy - 76), (112, c.fy - 68), (102, c.fy - 76)], R5["petal"][1]); poly(c.cv, [(112, c.fy - 84), (112, c.fy - 68), (102, c.fy - 76)], R5["petal"][2])
    line(c.cv, 112, c.fy - 84, 112, c.fy - 68, CREAM); line(c.cv, 102, c.fy - 76, 122, c.fy - 76, CREAM)
def grass_dandelion_drift(c):
    ground(c, 78, 12); tufts(c, 8)
    for (x, h) in ((30, 34), (60, 44), (92, 38), (124, 46), (150, 30)):
        line(c.cv, x, c.fy - 4, x, c.fy - h, c.g[2]); ell(c.cv, x, c.fy - h - 6, 9, 9, CREAM)
        for a in range(0, 360, 45): c.cv.put(x + int(12 * math.cos(math.radians(a))), c.fy - h - 6 + int(12 * math.sin(math.radians(a))), CREAM)
        ell(c.cv, x, c.fy - h - 6, 3, 3, R5["snow"][2])
    for (x, y) in ((40, 30), (74, 24), (108, 20), (136, 28), (20, 52), (150, 58)): sparkle(c.cv, x, y, CREAM)
def grass_sleepy_windmill(c):
    ground(c, 66, 12); cx = 85
    poly(c.cv, [(cx - 22, c.fy - 4), (cx - 14, c.fy - 70), (cx + 14, c.fy - 70), (cx + 22, c.fy - 4)], R5["sand"][1])
    for x in range(cx - 22, cx + 23): u = (x - cx + 22) / 44.0; [c.cv.put(x, y, R5["sand"][0 if u < .2 else 1 if u < .5 else 2 if u < .8 else 3]) for y in range(c.fy - 70, c.fy - 4) if c.cv.get(x, y)[3]]
    poly(c.cv, [(cx - 18, c.fy - 70), (cx, c.fy - 92), (cx + 18, c.fy - 70)], c.t[2]); poly(c.cv, [(cx - 14, c.fy - 71), (cx, c.fy - 88), (cx, c.fy - 71)], c.t[1])
    col(c.cv, cx - 6, cx + 7, c.fy - 22, c.fy - 4, c.t, c.rnd, .03); ell(c.cv, cx, c.fy - 22, 6, 4, c.t[1]); rect(c.cv, cx - 6, c.fy - 22, cx + 7, c.fy - 18, c.t[1])
    rect(c.cv, cx - 4, c.fy - 54, cx + 5, c.fy - 44, c.t[3]); rect(c.cv, cx - 3, c.fy - 53, cx + 4, c.fy - 45, c.gl[1])
    hub = (cx, c.fy - 76)
    for a in (35, 125, 215, 305):   # sails, slowly turned
        ex = hub[0] + int(46 * math.cos(math.radians(a))); ey = hub[1] - int(46 * math.sin(math.radians(a))); line(c.cv, hub[0], hub[1], ex, ey, c.t[2], 3)
        nx, ny = -math.sin(math.radians(a)), -math.cos(math.radians(a))
        poly(c.cv, [(hub[0] + int(10 * math.cos(math.radians(a))), hub[1] - int(10 * math.sin(math.radians(a)))), (ex, ey), (ex + int(14 * nx), ey + int(14 * ny)), (hub[0] + int(10 * math.cos(math.radians(a))) + int(14 * nx), hub[1] - int(10 * math.sin(math.radians(a))) + int(14 * ny))], CREAM)
    ell(c.cv, hub[0], hub[1], 4, 4, c.t[3]); tufts(c, 8)
def grass_daisy_ring(c):
    ground(c, 76, 13)
    for k in range(16):
        a = k * math.pi / 8; x = 85 + int(54 * math.cos(a)); y = c.fy - 14 + int(11 * math.sin(a))
        ell(c.cv, x, y, 4, 3, CREAM); ell(c.cv, x, y, 1, 1, R5["gold"][1]); c.cv.put(x - 3, y - 1, R5["snow"][1]) if False else None
    for k in range(5): tufts(c, 1, 60 + k * 10, 72 + k * 10)
def forest_lantern_branch(c):
    ground(c, 60, 10); leafy(c, 60, c.fy - 2, 34, R5["leaf"], 14)
    line(c.cv, 70, c.fy - 70, 118, c.fy - 76, c.t[2], 4); line(c.cv, 118, c.fy - 76, 124, c.fy - 70, c.t[2], 3); line(c.cv, 112, c.fy - 76, 112, c.fy - 62, INK)
    lantern(c.cv, 112, c.fy - 60, c.t, c.gl); glow(c.cv, 112, c.fy - 56, 2, c.gl) if False else None; tufts(c, 8)
def forest_root_tangle(c):
    ground(c);
    for i, (x, dy) in enumerate(((24, 30), (62, 40), (106, 34), (140, 28))):
        for k in range(46):
            xx = x + k; yy = c.fy - 6 - int(dy * math.sin(math.pi * k / 46.0))
            for t in range(-3, 4): c.cv.put(xx, yy + 4 + abs(t) // 2 if False else yy + t, c.t[0 if t < -1 else 1 if t < 1 else 2 if t < 3 else 3]) if (k < 44) else None
    lump(c.cv, 85, c.fy - 6, 30, 8, c.g, c.rnd, .1); tufts(c, 10)
def forest_spring_pebbles(c):
    ground(c, 76, 13); pond(c, 85, c.fy - 18, 50, 12, R5["sea"], True)
    for i in range(14): rock(c, 44 + (i * 17) % 80, c.fy - 18 + (i * 5) % 14 - 4, 3, 2, [R5["sand"], R5["stone"], R5["petal"], R5["snow"]][i % 4])
    rock(c, 135, c.fy - 20, 14, 10); rock(c, 148, c.fy - 12, 9, 6); tufts(c, 8)
def forest_owl_bough(c):
    ground(c, 58, 10); leafy(c, 50, c.fy - 2, 36, R5["leaf"], 15)
    line(c.cv, 60, c.fy - 52, 142, c.fy - 58, c.t[2], 6); line(c.cv, 60, c.fy - 54, 142, c.fy - 60, c.t[0], 1)
    for x in range(92, 138, 9): lump(c.cv, x, c.fy - 62, 6, 4, R5["leaf"], c.rnd, 0)
    ox, oy = 118, c.fy - 76
    lump(c.cv, ox, oy, 9, 12, R5["litter"], c.rnd, .15); lump(c.cv, ox, oy - 4, 8, 6, R5["wood"], c.rnd, 0)
    for sx in (-1, 1): ell(c.cv, ox + sx * 4, oy - 6, 4, 4, CREAM); ell(c.cv, ox + sx * 4, oy - 6, 2, 2, R5["gold"][1]); c.cv.put(ox + sx * 4, oy - 6, INK)
    poly(c.cv, [(ox - 2, oy - 3), (ox + 2, oy - 3), (ox, oy + 1)], R5["gold"][2]); poly(c.cv, [(ox - 9, oy - 12), (ox - 4, oy - 12), (ox - 7, oy - 18)], R5["litter"][2]); poly(c.cv, [(ox + 4, oy - 12), (ox + 9, oy - 12), (ox + 7, oy - 18)], R5["litter"][2])
    tufts(c, 6, 70, 150)
def forest_glow_moss_grotto(c):
    ground(c, 76, 12); lump(c.cv, 85, c.fy - 36, 70, 40, c.r, c.rnd, .12)
    ell(c.cv, 85, c.fy - 22, 34, 26, INK); rect(c.cv, 51, c.fy - 22, 119, c.fy - 6, INK); ell(c.cv, 85, c.fy - 22, 30, 22, (30, 24, 44, 255)); rect(c.cv, 55, c.fy - 22, 115, c.fy - 6, (30, 24, 44, 255))
    for i in range(18):
        a = math.pi + i * math.pi / 17; x = 85 + int(33 * math.cos(a)); y = c.fy - 22 + int(25 * math.sin(a))
        ell(c.cv, x, y + 2, 3, 3, R5["moss"][0]); ell(c.cv, x, y + 2, 1, 1, CREAM)
    for (x, y) in ((70, c.fy - 12), (94, c.fy - 16), (104, c.fy - 9), (78, c.fy - 22)): sparkle(c.cv, x, y, R5["moss"][0])
    for x in range(30, 56, 7): leafy(c, x, c.fy - 40 + (x % 5), 8, R5["leaf"], 3)
    tufts(c, 8)
def wet_mud_skipper(c):
    lump(c.cv, 85, c.fy - 10, 80, 14, R5["litter"], c.rnd, .15); pond(c, 60, c.fy - 10, 22, 5, R5["sea"], False); pond(c, 120, c.fy - 12, 20, 5, R5["sea"], False)
    for (x, y) in ((40, c.fy - 20), (82, c.fy - 16), (100, c.fy - 24), (140, c.fy - 22)):
        lump(c.cv, x, y, 5, 3, R5["stone"], c.rnd, 0); ell(c.cv, x + 3, y - 3, 2, 2, CREAM); c.cv.put(x + 3, y - 3, INK); line(c.cv, x - 5, y + 1, x - 9, y - 1, R5["stone"][3])
    reeds(c, 20, c.fy - 8, 3); reeds(c, 140, c.fy - 8, 3)
def wet_stilt_house(c):
    pond(c, 85, c.fy - 6, 76, 8, R5["sea"], True)
    for x in (48, 72, 98, 122): col(c.cv, x, x + 4, c.fy - 54, c.fy - 4, c.t, c.rnd, .04)
    planks(c.cv, 40, 130, c.fy - 58, c.fy - 52, c.t, c.rnd, 9); col(c.cv, 46, 124, c.fy - 92, c.fy - 58, R5["sand"], c.rnd, .06)
    hut_roof(c, 38, 134, c.fy - 112, c.fy - 90, c.t); rect(c.cv, 56, c.fy - 82, 72, c.fy - 68, c.t[3]); rect(c.cv, 58, c.fy - 80, 70, c.fy - 70, c.gl[1]); rect(c.cv, 59, c.fy - 79, 69, c.fy - 71, c.gl[0])
    rect(c.cv, 92, c.fy - 84, 106, c.fy - 58, c.t[2]); line(c.cv, 140, c.fy - 52, 150, c.fy - 18, c.t[1], 2); line(c.cv, 150, c.fy - 18, 152, c.fy - 8, c.t[1], 2)   # ladder that went for a walk
    for k in range(5): line(c.cv, 138 + k * 3, c.fy - 52 + k * 8, 142 + k * 3, c.fy - 52 + k * 8, c.t[3], 2) if False else None
    reeds(c, 10, c.fy - 6, 3); reeds(c, 150, c.fy - 6, 3)
def wet_willow_curtain(c):
    ground(c, 76, 12); leafy(c, 30, c.fy - 2, 24, R5["pine"], 8); leafy(c, 140, c.fy - 2, 24, R5["pine"], 8)
    for sx in (30, 140):
        lump(c.cv, sx, c.fy - 64, 28, 14, R5["leaf"], c.rnd, .1)
        for i in range(-24, 25, 3):
            h = 34 + c.rnd.randint(0, 22) - abs(i) // 2
            for k in range(h): c.cv.put(sx + i + int(2 * math.sin(k / 6.0)), c.fy - 60 + k, R5["leaf"][1 if k % 5 else 0 if k < 6 else 2])
    tufts(c, 6, 60, 110)
def wet_peat_bank(c):
    ground(c, 78, 11, R5["litter"]); lump(c.cv, 85, c.fy - 22, 72, 22, R5["litter"], c.rnd, .15); lump(c.cv, 85, c.fy - 36, 58, 10, [R5["wood"][3], R5["litter"][3], R5["litter"][3], R5["litter"][3], INK], c.rnd, .1)
    for i in range(7): line(c.cv, 22 + i * 20, c.fy - 26, 22 + i * 20, c.fy - 8, R5["litter"][4])
    for x in range(30, 150, 22): lump(c.cv, x, c.fy - 40 - (x % 3), 4, 3, R5["moss"], c.rnd, 0)
    rect(c.cv, 130, c.fy - 38, 140, c.fy - 34, c.t[1]); tufts(c, 8)
def mtn_scree(c):
    lump(c.cv, 85, c.fy - 6, 82, 10, c.g, c.rnd, .15)
    poly(c.cv, [(10, c.fy - 4), (50, c.fy - 70), (160, c.fy - 4)], c.r[2])
    for y in range(c.fy - 70, c.fy - 3):
        for x in range(8, 162):
            if c.cv.get(x, y) == c.r[2]: c.cv.put(x, y, c.r[[0, 1, 2, 3][min(3, ((x * 7 + y * 3) % 11) // 3)]])
    for i in range(34):
        x = 18 + (i * 29) % 120; y = c.fy - 8 - (i * 13) % 50
        if c.cv.get(x, y)[3]: rock(c, x, y, 3 + i % 3, 2 + i % 2, c.r)
    rock(c, 150, c.fy - 8, 10, 6)
def mtn_pine_shelf(c):
    poly(c.cv, [(0, c.fy), (0, c.fy - 70), (60, c.fy - 76), (170, c.fy - 40), (170, c.fy)], c.r[2])
    for y in range(c.fy - 76, c.fy):
        for x in range(0, 170):
            if c.cv.get(x, y) == c.r[2]: c.cv.put(x, y, c.r[0 if x < 30 else 1 if x < 90 else 2 if (x + y) % 9 else 3])
    rect(c.cv, 0, c.fy - 44, 170, c.fy - 36, c.g[2]); rect(c.cv, 0, c.fy - 44, 170, c.fy - 42, c.g[0])
    for i, x in enumerate((26, 56, 92, 128, 152)): pinetree(c, x, c.fy - 38, 42 - (i % 3) * 7, R5["pine"])
def mtn_wind_notch(c):
    poly(c.cv, [(0, c.fy), (0, c.fy - 100), (60, c.fy - 100), (85, c.fy - 52), (110, c.fy - 100), (170, c.fy - 100), (170, c.fy)], c.r[2])
    for y in range(c.fy - 100, c.fy):
        for x in range(0, 170):
            if c.cv.get(x, y) == c.r[2]: c.cv.put(x, y, c.r[0 if x < 20 or (x < 80 and y < c.fy - 56) else 1 if x < 85 else 2 if x < 150 else 3] if (x * 3 + y * 5) % 17 else c.r[4])
    for k in range(4):
        y = c.fy - 90 + k * 8
        for x in range(70, 106): c.cv.put(x, y + int(round(math.sin(x / 4.0 + k) * 2)), CREAM) if x % 2 == 0 else None
    for (x, y) in ((88, c.fy - 70), (96, c.fy - 78)): sparkle(c.cv, x, y, CREAM)
    lump(c.cv, 85, c.fy - 4, 70, 8, c.g, c.rnd, .1)
def mtn_goat_ledge(c):
    lump(c.cv, 90, c.fy - 22, 78, 24, c.r, c.rnd, .12); rect(c.cv, 14, c.fy - 36, 166, c.fy - 30, c.g[1]); lump(c.cv, 90, c.fy - 34, 74, 6, c.g, c.rnd, .1)
    gx, gy = 96, c.fy - 52
    lump(c.cv, gx, gy, 14, 9, CREAM and R5["snow"], c.rnd, 0); lump(c.cv, gx + 14, gy - 8, 6, 6, R5["snow"], c.rnd, 0)
    for sx in (-8, -2, 6, 12): rect(c.cv, gx + sx, gy + 6, gx + sx + 3, gy + 16, R5["snow"][2])
    line(c.cv, gx + 12, gy - 14, gx + 8, gy - 22, R5["wood"][1], 2); line(c.cv, gx + 17, gy - 14, gx + 22, gy - 22, R5["wood"][1], 2)
    rect(c.cv, gx + 14, gy - 4, gx + 17, gy + 1, R5["snow"][2]); c.cv.put(gx + 16, gy - 9, INK); c.cv.put(gx - 14, gy - 2, R5["snow"][1])
    tufts(c, 6, 10, 160, R5["leaf"])
def forest_fern_tunnel(c):
    ground(c, 76, 12)
    for sx in (-1, 1):
        for i in range(3): fern(c, 85 + sx * (46 - i * 4), c.fy - 8, 50 - i * 6, R5["leaf"] if i % 2 else R5["moss"], 4)
    for i in range(7):
        x = 40 + i * 15; line(c.cv, x, c.fy - 50 + abs(i - 3) * 4 - 8, x + 14, c.fy - 52 + abs(i - 3) * 4, R5["leaf"][1], 4)
    for k in range(5): line(c.cv, 55 + k * 16, c.fy - 44, 55 + k * 16, c.fy - 30 - (k % 2) * 8, R5["sea"][0])
    for k in range(3): ell(c.cv, 70 + k * 22, c.fy - 22 + k % 2 * 5, 1, 2, R5["sea"][0])
def forest_acorn_scatter(c):
    ground(c, 78, 12)
    for i in range(22):
        x = 14 + (i * 41) % 142; y = c.fy - 4 - (i * 13) % 20; ell(c.cv, x, y, 4, 3, R5["wood"][1]); rect(c.cv, x - 4, y - 5, x + 5, y - 2, R5["wood"][3]); c.cv.put(x - 1, y - 6, R5["wood"][2]); c.cv.put(x - 1, y, R5["wood"][0])
    leafy(c, 150, c.fy - 2, 22, R5["leaf"], 7); tufts(c, 6)
def forest_hollow_oak(c):
    ground(c, 68, 11); cx = 85
    col(c.cv, cx - 26, cx + 27, c.fy - 70, c.fy - 4, c.t, c.rnd, .06)
    for k in range(10): line(c.cv, cx - 26 - k // 2, c.fy - 4 + k // 3, cx - 20, c.fy - 20, c.t[1]) if False else None
    ell(c.cv, cx, c.fy - 34, 12, 18, INK); ell(c.cv, cx, c.fy - 34, 9, 15, (40, 26, 36, 255)); rect(c.cv, cx - 9, c.fy - 34, cx + 10, c.fy - 6, (40, 26, 36, 255));
    rect(c.cv, cx - 7, c.fy - 18, cx + 8, c.fy - 10, c.t[1]); rect(c.cv, cx - 5, c.fy - 22, cx + 6, c.fy - 18, R5["snow"][0]); rect(c.cv, cx - 1, c.fy - 22, cx + 2, c.fy - 20, R5["gold"][1])
    for (dx, dy, rx, ry) in ((0, -86, 52, 30), (-34, -74, 30, 22), (34, -74, 30, 22), (0, -100, 30, 16)): lump(c.cv, cx + dx, c.fy + dy, rx, ry, R5["leaf"], c.rnd, .15)
    tufts(c, 8)
def wet_frog_choir(c):
    ground(c, 78, 12, R5["litter"]); pond(c, 85, c.fy - 6, 76, 9, R5["sea"], False)
    for (x, y, s) in ((34, 40, 1), (56, 48, 2), (86, 52, 2), (116, 46, 2), (138, 40, 1)):
        lily(c, x, c.fy - 6 + (x % 3), 11, False); frog(c, x, c.fy - 10 + (x % 3), s)
    for k, (x, y) in enumerate(((86, c.fy - 40), (110, c.fy - 48), (60, c.fy - 44), (134, c.fy - 32))):
        ell(c.cv, x, y, 3, 2, CREAM); line(c.cv, x + 2, y, x + 2, y - 8, CREAM); line(c.cv, x + 2, y - 8, x + 6, y - 6, CREAM)   # notes
    reeds(c, 10, c.fy - 4, 3); reeds(c, 146, c.fy - 4, 3)
def mtn_rope_bridge(c):
    poly(c.cv, [(0, c.fy), (0, c.fy - 36), (38, c.fy - 36), (46, c.fy)], c.r[2]); poly(c.cv, [(170, c.fy), (170, c.fy - 36), (132, c.fy - 36), (124, c.fy)], c.r[2])
    for x in list(range(0, 46)) + list(range(124, 170)):
        for y in range(c.fy - 36, c.fy):
            if c.cv.get(x, y) == c.r[2]: c.cv.put(x, y, c.r[0 if x < 20 else 1 if x < 36 else 2 if (x + y) % 7 else 3] if x < 100 else c.r[1 if x > 160 else 2 if (x + y) % 7 else 3])
    for i in range(36):
        x = 36 + i * 3; y = c.fy - 38 + int(12 * math.sin(math.pi * i / 36.0))
        rect(c.cv, x, y, x + 2, y + 3, c.t[1 + (i % 2)]);
    for i in range(0, 36, 4):
        x = 36 + i * 3; y = c.fy - 38 + int(12 * math.sin(math.pi * i / 36.0)); line(c.cv, x, y - 14, x, y, c.t[3])
    for i in range(35):
        x = 36 + i * 3; y = c.fy - 38 + int(12 * math.sin(math.pi * i / 36.0)) - 14; line(c.cv, x, y, x + 3, c.fy - 38 + int(12 * math.sin(math.pi * (i + 1) / 36.0)) - 14, c.t[0], 1)
    for x in (30, 140): col(c.cv, x, x + 5, c.fy - 54, c.fy - 36, c.t, c.rnd, 0)
def mtn_waterfall(c):
    poly(c.cv, [(40, c.fy), (40, c.fy - 120), (130, c.fy - 120), (130, c.fy)], c.r[2])
    for y in range(c.fy - 120, c.fy):
        for x in range(40, 131):
            if c.cv.get(x, y) == c.r[2]: c.cv.put(x, y, c.r[0 if x < 58 else 1 if x < 90 else 2 if (x * 3 + y * 5) % 13 else 3 if x > 112 else 1])
    for x in range(70, 100):
        for y in range(c.fy - 120, c.fy - 18): c.cv.put(x, y, R5["sea"][0 if (x + y // 3) % 5 == 0 else 1 if x < 82 else 0 if x < 90 else 2])
    pond(c, 85, c.fy - 12, 50, 9, R5["sea"], False); ell(c.cv, 85, c.fy - 20, 22, 8, CREAM)
    for i in range(14): ell(c.cv, 55 + (i * 17) % 60, c.fy - 40 - (i * 7) % 60, 6, 4, (255, 255, 255, 255)) if i % 3 == 0 else None
    for k, R in enumerate((R5["petal"], R5["gold"], R5["sea"])):
        for x in range(104, 150):
            yy = c.fy - 50 - int(26 * math.sin(math.pi * (x - 104) / 46.0)) + k * 2
            c.cv.put(x, yy, R[1 + k % 2])
    for (x, y) in ((60, c.fy - 22), (112, c.fy - 18)): sparkle(c.cv, x, y, CREAM)
def wet_boardwalk_gap(c):
    pond(c, 85, c.fy - 6, 80, 8, R5["litter"], False); pond(c, 85, c.fy - 6, 76, 6, R5["sea"], False)
    bridge_plank(c, 10, 160, c.fy - 18, 12, gap=8, rails=False)
    for x in (16, 52, 88, 124, 150): col(c.cv, x, x + 4, c.fy - 12, c.fy - 2, c.t, c.rnd, .04)
    ell(c.cv, 90, c.fy - 4, 5, 2, R5["sea"][3]); reeds(c, 6, c.fy - 4, 2); reeds(c, 150, c.fy - 4, 3)
def grass_clover(c):
    ground(c, 78, 13)
    for i in range(40):
        x = 16 + (i * 47) % 140; y = c.fy - 8 - (i * 17) % 18
        for dx, dy in ((-3, 0), (3, 0), (0, -3), (0, 3)): ell(c.cv, x + dx, y + dy, 3, 3, R5["moss"][1 + (i % 3 == 0)])
        c.cv.put(x, y, R5["moss"][0])
    for (x, y) in ((70, c.fy - 20), ):
        for dx, dy in ((-3, 0), (3, 0), (0, -3), (0, 3), (-3, -3)): ell(c.cv, x + dx, y + dy, 3, 3, R5["gold"][1])
        sparkle(c.cv, x + 2, y - 8, CREAM)
    tufts(c, 6)
def grass_scarecrow(c):
    ground(c, 66, 11); cx = 85
    col(c.cv, cx - 2, cx + 3, c.fy - 76, c.fy - 4, c.t, c.rnd, 0); col(c.cv, cx - 34, cx + 35, c.fy - 62, c.fy - 57, c.t, c.rnd, 0)
    poly(c.cv, [(cx - 14, c.fy - 62), (cx + 14, c.fy - 62), (cx + 18, c.fy - 22), (cx - 18, c.fy - 22)], R5["gold"][1])
    for y in range(c.fy - 62, c.fy - 22): [c.cv.put(x, y, R5["petal"][2 if x > cx else 0 if x < cx - 8 else 1]) for x in range(cx - 16, cx + 17) if c.cv.get(x, y) == R5["gold"][1]]
    for k in range(0, 36, 6): line(c.cv, cx - 34 + k - 2, c.fy - 58, cx - 36 + k, c.fy - 46, R5["gold"][1]); line(c.cv, cx + 34 - k, c.fy - 58, cx + 36 - k, c.fy - 46, R5["gold"][1])
    lump(c.cv, cx, c.fy - 76, 11, 11, R5["sand"], c.rnd, 0); c.cv.put(cx - 4, c.fy - 78, INK); c.cv.put(cx + 4, c.fy - 78, INK); line(c.cv, cx - 3, c.fy - 72, cx + 3, c.fy - 72, INK)
    poly(c.cv, [(cx - 6, c.fy - 84), (cx + 6, c.fy - 84), (cx + 2, c.fy - 92), (cx - 2, c.fy - 92)], R5["wood"][2]); rect(c.cv, cx - 7, c.fy - 85, cx + 8, c.fy - 83, R5["wood"][1])
    bird(c, 140, c.fy - 62, R5["stone"][3] and [(60, 50, 70, 255)] * 2 + [(40, 34, 52, 255)] * 3, 1); tufts(c, 8)
def grass_milestone(c):
    ground(c, 54, 10); cx = 85
    poly(c.cv, [(cx - 18, c.fy - 4), (cx - 16, c.fy - 54), (cx - 6, c.fy - 62), (cx + 8, c.fy - 62), (cx + 16, c.fy - 54), (cx + 18, c.fy - 4)], c.r[2])
    for y in range(c.fy - 62, c.fy - 3):
        for x in range(cx - 18, cx + 19):
            if c.cv.get(x, y) == c.r[2]: c.cv.put(x, y, c.r[0 if x < cx - 9 else 1 if x < cx + 2 else 2 if x < cx + 12 else 3])
    lump(c.cv, cx - 4, c.fy - 62, 12, 5, R5["moss"], c.rnd, .1); lump(c.cv, cx + 10, c.fy - 8, 12, 6, R5["moss"], c.rnd, .1)
    for k in range(3): line(c.cv, cx - 6 + k * 6, c.fy - 44, cx - 6 + k * 6, c.fy - 34, c.r[3]) if k != 1 else None
    poly(c.cv, [(cx + 18, c.fy - 36), (cx + 38, c.fy - 36), (cx + 46, c.fy - 30), (cx + 38, c.fy - 24), (cx + 18, c.fy - 24)], c.t[1]); rect(c.cv, cx + 18, c.fy - 36, cx + 38, c.fy - 35, c.t[0]); tufts(c, 8)
def forest_mushroom_ring(c):
    ground(c, 76, 13)
    for k in range(11):
        a = k * 2 * math.pi / 11; shroom(c, 85 + int(54 * math.cos(a)), c.fy - 14 + int(10 * math.sin(a)) , 1 + (k % 3 == 0))
    for k in range(5): sparkle(c.cv, 62 + k * 12, c.fy - 20 + (k % 2) * 4, CREAM) if k % 2 == 0 else None
    tufts(c, 8)
def forest_mossy_stair(c):
    ground(c, 76, 12)
    for i in range(6):
        y = c.fy - 8 - i * 12; x0 = 20 + i * 6; x1 = 150 - i * 6
        col(c.cv, x0, x1, y - 10, y, c.t if i % 2 else c.r, c.rnd, .06); lump(c.cv, (x0 + x1) // 2, y - 10, (x1 - x0) // 2, 4, R5["moss"], c.rnd, .1)
    leafy(c, 20, c.fy - 40, 20, R5["leaf"], 6); leafy(c, 152, c.fy - 40, 20, R5["leaf"], 6); tufts(c, 6)
def forest_woodcutter_stump(c):
    ground(c, 66, 11); cx = 85
    col(c.cv, cx - 40, cx + 41, c.fy - 52, c.fy - 4, c.t, c.rnd, .05)
    for k in range(4): line(c.cv, cx - 44 + k * 4, c.fy - 4, cx - 36, c.fy - 20, c.t[1]) if False else None
    ell(c.cv, cx, c.fy - 52, 40, 10, c.t[0]); ell(c.cv, cx, c.fy - 52, 34, 8, R5["sand"][1])
    for r_ in (6, 14, 22, 30): ell(c.cv, cx, c.fy - 52, r_, max(2, r_ // 4), R5["sand"][2]) if False else [c.cv.put(cx + int(r_ * math.cos(a / 20.0)), c.fy - 52 + int(r_ * .24 * math.sin(a / 20.0)), R5["wood"][1]) for a in range(0, 126)]
    line(c.cv, cx + 14, c.fy - 54, cx + 14, c.fy - 80, c.t[2], 3); poly(c.cv, [(cx + 14, c.fy - 84), (cx + 26, c.fy - 80), (cx + 14, c.fy - 72)], c.r[1]); rect(c.cv, cx + 12, c.fy - 54, cx + 17, c.fy - 52, c.r[3]); tufts(c, 8)
def coast_lighthouse_shadow(c):
    lump(c.cv, 85, c.fy - 6, 80, 10, c.g, c.rnd, .1); cx = 128
    poly(c.cv, [(cx - 8, c.fy - 20), (cx - 5, c.fy - 100), (cx + 5, c.fy - 100), (cx + 8, c.fy - 20)], CREAM)
    for k in range(5):
        for y in range(c.fy - 100 + k * 16, c.fy - 92 + k * 16): [c.cv.put(x, y, R5["ember"][1 if x < cx + 2 else 2]) for x in range(cx - 8, cx + 9) if c.cv.get(x, y)[3]]
    rect(c.cv, cx - 7, c.fy - 108, cx + 8, c.fy - 100, c.t[3]); rect(c.cv, cx - 5, c.fy - 107, cx + 6, c.fy - 101, c.gl[0]); poly(c.cv, [(cx - 8, c.fy - 108), (cx, c.fy - 116), (cx + 8, c.fy - 108)], R5["ember"][2])
    for k in range(10): line(c.cv, cx - 8, c.fy - 104, 4 + k * 3, c.fy - 70 + k * 3, c.gl[0] if k % 3 else CREAM) if False else None
    poly(c.cv, [(cx - 7, c.fy - 104), (6, c.fy - 62), (10, c.fy - 40), (cx - 7, c.fy - 100)], c.gl[0] if False else (255, 240, 160, 110))
    lump(c.cv, cx, c.fy - 18, 22, 10, R5["stone"], c.rnd, .12); pond(c, 40, c.fy - 4, 34, 4, R5["sea"], False)
def coast_kelp_line(c):
    lump(c.cv, 85, c.fy - 14, 80, 14, c.g, c.rnd, .1); band(c, 0, 170, c.fy - 36, c.fy - 22, R5["sea"]) if False else None
    for x in range(8, 164):
        y = c.fy - 14 + int(round(math.sin(x / 9.0) * 4))
        for t in range(-2, 3): c.cv.put(x, y + t, R5["moss"][3 if t > 1 else 2 if t > 0 else 1 if t > -2 else 0])
    for x in range(14, 160, 12): ell(c.cv, x, c.fy - 18 + int(round(math.sin(x / 9.0) * 4)), 3, 3, R5["moss"][0])
    for (x, y) in ((40, c.fy - 6), (110, c.fy - 4)): shell(c, x, y, 3, R5["petal"])
    waves(c, 0, 170, c.fy - 34)
def coast_rope_net_rack(c):
    ground(c, 76, 11)
    for x in (30, 140): col(c.cv, x, x + 5, c.fy - 70, c.fy - 4, c.t, c.rnd, .04)
    rect(c.cv, 26, c.fy - 72, 150, c.fy - 66, c.t[1]); rect(c.cv, 26, c.fy - 72, 150, c.fy - 71, c.t[0])
    for i in range(0, 108, 4):
        for j in range(0, 44, 4):
            if (i + j) % 8 == 0: line(c.cv, 36 + i, c.fy - 64 + j, 40 + i, c.fy - 60 + j, R5["sand"][2]); line(c.cv, 40 + i, c.fy - 64 + j, 36 + i, c.fy - 60 + j, R5["sand"][2])
    for k in range(3): ell(c.cv, 60 + k * 30, c.fy - 18, 3, 3, R5["ember"][1]) if False else None
    lump(c.cv, 152, c.fy - 4, 8, 4, R5["wood"], c.rnd, 0); bird(c, 150, c.fy - 80, R5["snow"], 1); rect(c.cv, 40, c.fy - 18, 56, c.fy - 4, c.t[2]); rect(c.cv, 42, c.fy - 16, 54, c.fy - 6, R5["wood"][0]); tufts(c, 5)
def desert_bones(c):
    ground(c, 78, 12)
    for i in range(8):
        x = 32 + i * 14; line(c.cv, x, c.fy - 22, x - 4, c.fy - 10 - (i % 2) * 3, CREAM, 3); line(c.cv, x, c.fy - 22, x - 4, c.fy - 10 - (i % 2) * 3, R5["sand"][0], 1)
    line(c.cv, 36, c.fy - 22, 136, c.fy - 22, CREAM, 3);
    lump(c.cv, 150, c.fy - 22, 14, 11, R5["snow"], c.rnd, 0); ell(c.cv, 152, c.fy - 24, 3, 3, INK); poly(c.cv, [(158, c.fy - 20), (166, c.fy - 20), (166, c.fy - 14)], R5["snow"][1])
    for k in range(4): line(c.cv, 20 + k * 3, c.fy - 22, 28 + k * 3, c.fy - 22 + (k - 2) * 2, CREAM, 2)
    lump(c.cv, 80, c.fy - 4, 12, 4, R5["sand"], c.rnd, .1); cactus(c, 14, c.fy - 4, 22, 1)
def desert_salt_flat(c):
    ground(c, 80, 12, R5["snow"])
    for i in range(70):
        x = 10 + (i * 53) % 150; y = c.fy - 14 + (i * 7) % 12 - 4 + int(math.sin(i) * 3)
        if i % 3 == 0: poly(c.cv, [(x, y), (x + 4, y - 2), (x + 8, y), (x + 4, y + 1)], (255, 255, 255, 255))
        else: c.cv.put(x, y, R5["snow"][2])
    for k in range(5): line(c.cv, 22 + k * 28, c.fy - 20 + (k % 2) * 6, 40 + k * 28, c.fy - 20 + (k % 2) * 6 + 3, R5["snow"][3])
    rock(c, 140, c.fy - 8, 12, 7, R5["litter"]); rock(c, 26, c.fy - 6, 8, 4, R5["litter"])
def desert_shade_awning(c):
    ground(c, 70, 11)
    for x in (34, 130): col(c.cv, x, x + 5, c.fy - 68, c.fy - 4, c.t, c.rnd, .04)
    poly(c.cv, [(24, c.fy - 62), (140, c.fy - 62), (150, c.fy - 44), (14, c.fy - 44)], R5["petal"][1] if False else R5["ember"][1])
    for x in range(24, 140, 16): poly(c.cv, [(x, c.fy - 62), (x + 8, c.fy - 62), (x + 10, c.fy - 44), (x + 2, c.fy - 44)], CREAM) if (x // 16) % 2 == 0 else None
    for x in range(14, 150, 7): poly(c.cv, [(x, c.fy - 44), (x + 7, c.fy - 44), (x + 4, c.fy - 38)], R5["ember"][2])
    ell(c.cv, 90, c.fy - 8, 16, 5, R5["litter"][1]); ell(c.cv, 88, c.fy - 11, 7, 3, R5["petal"][1]); ell(c.cv, 100, c.fy - 9, 4, 4, R5["sand"][1]) ; tufts(c, 3)
def coast_bottle_post(c):
    ground(c, 40, 9); cx = 85
    col(c.cv, cx - 4, cx + 5, c.fy - 66, c.fy - 4, c.t, c.rnd, .05); rect(c.cv, cx - 6, c.fy - 70, cx + 7, c.fy - 66, c.t[1])
    rect(c.cv, cx - 5, c.fy - 92, cx + 6, c.fy - 70, R5["sea"][0]); rect(c.cv, cx - 5, c.fy - 92, cx + 6, c.fy - 91, CREAM); rect(c.cv, cx - 3, c.fy - 98, cx + 4, c.fy - 92, R5["sea"][0]); rect(c.cv, cx - 3, c.fy - 101, cx + 4, c.fy - 98, c.t[1])
    rect(c.cv, cx - 3, c.fy - 88, cx + 4, c.fy - 74, CREAM); line(c.cv, cx - 2, c.fy - 84, cx + 3, c.fy - 84, INK); line(c.cv, cx - 2, c.fy - 80, cx + 2, c.fy - 80, INK)
    for k in range(3): shell(c, 50 + k * 34, c.fy - 4, 3, R5["petal"]) if False else None
    rock(c, 110, c.fy - 6, 10, 5, R5["sand"]); shell(c, 62, c.fy - 5, 3, R5["petal"]); shell(c, 112, c.fy - 12, 2); tufts(c, 3)
def desert_red_arch(c):
    ground(c, 76, 12); cx = 85
    for sx in (-1, 1): col(c.cv, cx + sx * 44 - 12, cx + sx * 44 + 12, c.fy - 56, c.fy - 4, R5["ember"] if False else R5["litter"], c.rnd, .08)
    for x in range(cx - 58, cx + 59):
        u = (x - cx) / 58.0; yy = c.fy - 56 - int(32 * math.sqrt(max(0, 1 - u * u)))
        for y in range(yy, yy + 18): c.cv.put(x, y, R5["litter"][0 if y < yy + 3 else 1 if x < cx - 20 else 2 if x < cx + 20 else 3] if (x * 3 + y) % 13 else R5["litter"][4])
    for (x, y) in ((cx - 58, c.fy - 60), (cx + 52, c.fy - 62)): rock(c, x, y, 10, 6, R5["litter"])
    for x in range(cx - 30, cx + 31):
        for y in range(c.fy - 60, c.fy - 40):
            if c.cv.get(x, y)[3] and (x + y) % 6 == 0: c.cv.put(x, y, R5["ember"][1])
    rock(c, cx, c.fy - 6, 14, 4, R5["sand"]); tufts(c, 3)
def desert_ripple_lane(c):
    ground(c, 80, 12); ripple_lines(c, 10, 160, c.fy - 36, 5, R5["sand"], 6)
    rock(c, 140, c.fy - 8, 10, 5, R5["litter"]); cactus(c, 22, c.fy - 4, 20, 1)
def desert_waystones(c):
    ground(c, 70, 11)
    standing(c, 58, c.fy - 4, 14, 56, -8, R5["litter"], True); standing(c, 90, c.fy - 4, 16, 70, 0, R5["litter"], True); standing(c, 124, c.fy - 4, 13, 50, 10, R5["litter"], True)
    tufts(c, 4)
def desert_dry_riverbed(c):
    lump(c.cv, 85, c.fy - 12, 82, 16, R5["litter"], c.rnd, .1)
    for x in range(0, 170):
        y = c.fy - 20 + int(round(math.sin(x / 14.0) * 6));
        for t in range(-6, 8): c.cv.put(x, y + t, R5["litter"][3 if t > 5 else 2 if t > 1 else 1] if abs(t) < 7 else R5["litter"][0])
    for i in range(30): rock(c, 6 + (i * 37) % 160, c.fy - 20 + (i * 3) % 10 - 4 + int(round(math.sin((6 + (i * 37) % 160) / 14.0) * 6)), 2, 1, R5["stone"])
    for x in range(10, 160, 5): line(c.cv, x, c.fy - 14 + int(round(math.sin(x / 14.0) * 6)), x + 2, c.fy - 12 + int(round(math.sin(x / 14.0) * 6)), R5["litter"][4]) if x % 3 == 0 else None
    shell(c, 130, c.fy - 20 + int(round(math.sin(130 / 14.0) * 6)) , 3, R5["sand"]); tufts(c, 3)
def wet_lily_ford(c):
    pond(c, 85, c.fy - 18, 80, 18, R5["sea"], True)
    for (x, y, s, b) in ((24, 0, 10, False), (44, -8, 12, True), (66, 4, 10, False), (88, -4, 12, False), (110, 6, 10, True), (132, -6, 12, False), (150, 2, 9, False)): lily(c, x, c.fy - 18 + y, s, b)
    reeds(c, 4, c.fy - 6, 3); reeds(c, 152, c.fy - 6, 3)
def wet_dragonfly_bend(c):
    ground(c, 76, 12)
    for x in range(0, 170):
        yb = c.fy - 24 + int(round(math.sin(x / 22.0) * 10))
        for t in range(-6, 7): c.cv.put(x, yb + t, R5["sea"][0 if t < -4 else 1 if t < 0 else 2 if t < 4 else 3])
    reeds(c, 8, c.fy - 6, 3); reeds(c, 140, c.fy - 6, 4)
    for (x, y, R) in ((52, c.fy - 54, R5["sea"]), (96, c.fy - 62, R5["dusk"]), (128, c.fy - 50, R5["sea"])):
        line(c.cv, x - 8, y, x + 8, y, R[2], 2); ell(c.cv, x + 9, y, 2, 2, R[1]); ell(c.cv, x - 2, y - 3, 6, 2, (210, 240, 255, 255)); ell(c.cv, x + 2, y + 3, 6, 2, (210, 240, 255, 255))
def rain_stepping_roots(c):
    ground(c, 80, 12, R5["litter"])
    for i in range(5):
        x = 14 + i * 32
        for k in range(30):
            xx = x + k; yy = c.fy - 6 - int(26 * math.sin(math.pi * k / 30.0))
            for t in range(-3, 4): c.cv.put(xx, yy + t, R5["wood"][0 if t < -1 else 1 if t < 1 else 2 if t < 3 else 3])
        lump(c.cv, x + 15, c.fy - 32, 8, 4, R5["moss"], c.rnd, .1)
    pond(c, 85, c.fy - 4, 76, 4, R5["litter"], False); fern(c, 10, c.fy - 6, 22, R5["leaf"], 4); fern(c, 158, c.fy - 6, 22, R5["leaf"], 4)
def rain_giant_fern_glade(c):
    ground(c, 80, 12)
    for (x, h, n) in ((22, 62, 5), (56, 78, 6), (92, 66, 6), (126, 80, 6), (152, 58, 5)): fern(c, x, c.fy - 6, h, R5["leaf"] if x % 2 else R5["moss"], n)
    for (x, y) in ((70, c.fy - 40), (112, c.fy - 52)): c.cv.put(x, y, R5["sea"][0]); c.cv.put(x, y + 1, R5["sea"][1])
def rain_orchid_tree(c):
    ground(c, 54, 10); cx = 85
    col(c.cv, cx - 9, cx + 10, c.fy - 70, c.fy - 4, c.t, c.rnd, .06)
    for (dx, dy, rx, ry) in ((0, -94, 56, 32), (-34, -80, 30, 20), (34, -80, 30, 20)): lump(c.cv, cx + dx, c.fy + dy, rx, ry, R5["pine"], c.rnd, .15)
    cols = [R5["petal"], R5["dusk"], R5["gold"], R5["ember"]]
    for i in range(30):
        a = i * 2.4; x = cx + int((10 + (i * 7) % 46) * math.cos(a)); y = c.fy - 90 + int((6 + (i * 5) % 26) * math.sin(a)) + (24 if i % 5 == 0 else 0)
        flower(c, x, y, cols[i % 4], CREAM if i % 2 else None, 2)
    for k in range(5): flower(c, cx - 6 + k * 3, c.fy - 40 - k * 8, cols[k % 4], None, 2)
def rain_canopy_gap(c):
    ground(c, 76, 12)
    poly(c.cv, [(60, 0), (110, 0), (140, c.fy - 8), (30, c.fy - 8)], (255, 240, 170, 90))
    for i in range(7): line(c.cv, 70 + i * 6, 0, 56 + i * 14, c.fy - 8, (255, 244, 190, 150))
    for sx in (-1, 1):
        for i in range(3): lump(c.cv, 85 + sx * (62 - i * 6), c.fy - 40 - i * 22, 26 - i * 3, 24, R5["pine"], c.rnd, .15)
    ell(c.cv, 85, c.fy - 8, 38, 6, (255, 244, 190, 255)); ell(c.cv, 85, c.fy - 8, 24, 4, CREAM); fern(c, 40, c.fy - 6, 26, R5["leaf"], 4)
def rain_parrot_perch(c):
    ground(c, 54, 10); col(c.cv, 50, 62, c.fy - 100, c.fy - 4, c.t, c.rnd, .05); line(c.cv, 56, c.fy - 92, 150, c.fy - 100, c.t[2], 6); line(c.cv, 56, c.fy - 94, 150, c.fy - 102, c.t[0], 1)
    for (dx, dy, rx, ry) in ((-6, -108, 30, 14), (126, -104, 24, 10)): lump(c.cv, 56 + dx + 6, c.fy + dy, rx, ry, R5["pine"], c.rnd, .15)
    for (x, R) in ((84, R5["ember"]), (106, R5["sea"]), (128, R5["gold"])):
        bird(c, x, c.fy - 106, R, 1); line(c.cv, x - 4, c.fy - 106, x - 10, c.fy - 100, R5["petal"][1], 2)
    for k in range(3): line(c.cv, 90 + k * 14, c.fy - 124, 94 + k * 14, c.fy - 120, CREAM) if False else None
def rain_vine_bridge(c):
    for sx in (0, 1):
        for i in range(2): lump(c.cv, 14 + sx * 142, c.fy - 40 - i * 20, 22, 22, R5["pine"], c.rnd, .15)
        col(c.cv, 6 + sx * 148, 16 + sx * 148, c.fy - 36, c.fy - 4, c.t, c.rnd, .04)
    for i in range(34):
        x = 24 + i * 4; y = c.fy - 40 + int(14 * math.sin(math.pi * i / 33.0)); rect(c.cv, x, y, x + 3, y + 3, R5["leaf"][1 + i % 2]);
        if i % 5 == 0: line(c.cv, x, y - 16, x, y, R5["moss"][2]);
    for i in range(33):
        x = 24 + i * 4; y = c.fy - 40 + int(14 * math.sin(math.pi * i / 33.0)) - 16; line(c.cv, x, y, x + 4, c.fy - 40 + int(14 * math.sin(math.pi * (i + 1) / 33.0)) - 16, R5["moss"][1], 2)
    for k in range(6): flower(c, 36 + k * 20, c.fy - 40 + int(14 * math.sin(math.pi * (k * 5 + 2) / 33.0)) - 18, R5["petal"], None, 1) if k % 2 == 0 else None
def desert_mirage_pool(c):
    ground(c, 76, 12); pond(c, 85, c.fy - 16, 62, 10, R5["sea"], True)
    for k in range(5):
        for x in range(30, 140):
            if (x + k * 7) % 9 < 4: c.cv.put(x, c.fy - 36 - k * 4 + int(round(math.sin(x / 5.0 + k) * 1.5)), (255, 245, 200, 190))
    for x in range(30, 140, 6): c.cv.put(x, c.fy - 16 + int(round(math.sin(x / 4.0) * 2)), CREAM)
    rock(c, 20, c.fy - 6, 8, 4, R5["litter"]); cactus(c, 150, c.fy - 4, 18, 1)
def desert_cactus_garden(c):
    ground(c, 80, 12)
    for i, x in enumerate((20, 48, 76, 104, 132, 156)):
        cactus(c, x, c.fy - 6, 26 + (i % 3) * 8, 2 if i % 2 else 1); rock(c, x, c.fy - 4, 8, 3, R5["stone"])
    for x in range(10, 160, 6): rect(c.cv, x, c.fy - 3, x + 4, c.fy - 1, c.t[2]) if x % 12 == 0 else None
    rect(c.cv, 10, c.fy - 3, 164, c.fy - 1, c.t[1]); rect(c.cv, 160, c.fy - 22, 166, c.fy - 4, R5["sea"][1]); rect(c.cv, 158, c.fy - 24, 168, c.fy - 22, R5["sea"][0])
def mtn_eagle_rest(c):
    ground(c, 74, 11); rock(c, 85, c.fy - 22, 62, 26); ell(c.cv, 85, c.fy - 44, 56, 6, c.r[0]); ell(c.cv, 85, c.fy - 46, 40, 3, c.r[1])
    ex, ey = 96, c.fy - 62
    lump(c.cv, ex, ey, 12, 14, R5["wood"], c.rnd, .12); lump(c.cv, ex, ey - 18, 8, 8, CREAM and R5["snow"], c.rnd, 0)
    poly(c.cv, [(ex + 6, ey - 20), (ex + 16, ey - 17), (ex + 6, ey - 14)], R5["gold"][1]); c.cv.put(ex + 3, ey - 21, INK); c.cv.put(ex + 4, ey - 21, INK)
    poly(c.cv, [(ex - 12, ey - 6), (ex - 28, ey + 8), (ex - 14, ey + 10)], R5["wood"][2]); line(c.cv, ex - 4, ey + 14, ex - 4, ey + 20, R5["gold"][2], 2); line(c.cv, ex + 4, ey + 14, ex + 4, ey + 20, R5["gold"][2], 2)
    for k in range(3): c.cv.put(ex - 6 + k * 6, ey + 2, R5["wood"][0])
def mtn_stone_hut(c):
    ground(c, 66, 11); lump(c.cv, 85, c.fy - 6, 56, 8, c.g, c.rnd, .1)
    for row in range(5):
        for k in range(6): rock(c, 44 + k * 14 + (row % 2) * 7, c.fy - 10 - row * 11, 8, 6, R5["stone"])
    hut_roof(c, 36, 134, c.fy - 100, c.fy - 62, c.t)
    col(c.cv, 108, 122, c.fy - 108, c.fy - 76, c.r, c.rnd, .06); rect(c.cv, 106, c.fy - 110, 124, c.fy - 106, c.r[1]); smoke(c.cv, 115, c.fy - 112, 4, R5["snow"]) if False else smoke(c.cv, 115, c.fy - 114, 4, R5["snow"])
    col(c.cv, 76, 96, c.fy - 36, c.fy - 4, c.t, c.rnd, .03); rect(c.cv, 76, c.fy - 38, 96, c.fy - 34, c.t[1]); rect(c.cv, 108, c.fy - 36, 124, c.fy - 22, c.t[3]); rect(c.cv, 110, c.fy - 34, 122, c.fy - 24, R5["sea"][1])
    rect(c.cv, 140, c.fy - 22, 160, c.fy - 4, c.t[2]); rect(c.cv, 140, c.fy - 22, 160, c.fy - 20, c.t[0]); tufts(c, 4)
def mtn_echo_wall(c):
    ground(c, 80, 11); poly(c.cv, [(8, c.fy - 4), (8, c.fy - 96), (70, c.fy - 112), (162, c.fy - 92), (162, c.fy - 4)], c.r[2])
    for y in range(c.fy - 112, c.fy - 3):
        for x in range(8, 163):
            if c.cv.get(x, y) == c.r[2]: c.cv.put(x, y, c.r[0 if x < 40 else 1 if x < 90 else 2 if x < 135 else 3] if (x * 5 + y * 3) % 19 else c.r[4])
    for k in range(3):
        for t in range(-3, 4): c.cv.put(85 + k * 3 - 6 + abs(t) * 0, c.fy - 70 + t * 0, CREAM) if False else None
    for k in range(4):
        r = 8 + k * 7; [c.cv.put(60 + int(r * math.cos(a / 30.0)), c.fy - 60 + int(r * 1.0 * math.sin(a / 30.0)), CREAM) for a in range(-60, 61) if a % 3 == 0]
    ell(c.cv, 120, c.fy - 20, 6, 8, R5["petal"][1]); c.cv.put(120, c.fy - 22, INK); c.cv.put(122, c.fy - 22, INK); tufts(c, 3)
def desert_trader_poles(c):
    ground(c, 76, 12)
    for (x, h, ln) in ((40, 72, -6), (96, 82, 4), (140, 62, 8)): col(c.cv, x, x + 4, c.fy - h, c.fy - 4, c.t, c.rnd, .04); rect(c.cv, x - 1, c.fy - h - 2, x + 5, c.fy - h, c.t[3])
    line(c.cv, 42, c.fy - 72, 98, c.fy - 82, R5["sand"][3], 2); line(c.cv, 98, c.fy - 82, 142, c.fy - 62, R5["sand"][3], 2)
    poly(c.cv, [(98, c.fy - 82), (118, c.fy - 76), (112, c.fy - 62), (100, c.fy - 70)], R5["ember"][1])
    for k in range(3): line(c.cv, 44 + k * 5, c.fy - 72 + k, 44 + k * 5 - 3 + k, c.fy - 52, R5["petal"][1 + k % 2])
    lump(c.cv, 120, c.fy - 6, 10, 8, R5["wood"], c.rnd, 0); rock(c, 24, c.fy - 5, 8, 4, R5["litter"]); tufts(c, 2)
def mtn_switchback(c):
    poly(c.cv, [(0, c.fy), (0, c.fy - 100), (170, c.fy - 100), (170, c.fy)], c.r[2])
    for y in range(c.fy - 100, c.fy):
        for x in range(0, 170): c.cv.put(x, y, c.r[0 if (y - 8) % 40 < 5 else 1 if x < 60 else 2 if (x + y) % 11 else 3])
    pts = [(14, c.fy - 12), (146, c.fy - 12), (146, c.fy - 30), (24, c.fy - 30), (24, c.fy - 48), (146, c.fy - 48), (146, c.fy - 66), (50, c.fy - 66)]
    for (a, b) in zip(pts, pts[1:]): line(c.cv, a[0], a[1], b[0], b[1], R5["litter"][1], 7); line(c.cv, a[0], a[1] - 3, b[0], b[1] - 3, R5["litter"][0], 1)
    for (x, y) in ((22, c.fy - 20), (150, c.fy - 38), (30, c.fy - 56)): pinetree(c, x, y, 26, R5["pine"], False)
    for x in range(60, 140, 16): rect(c.cv, x, c.fy - 76, x + 2, c.fy - 66, c.t[1])
def isl_hammock_palms(c):
    ground(c, 76, 12)
    tx1, ty1 = palm(c, 36, c.fy - 4, 8, 78); tx2, ty2 = palm(c, 134, c.fy - 4, -8, 74)
    for i in range(0, 61):
        u = i / 60.0; x = tx1 + 6 + int((tx2 - 6 - tx1 - 6) * u); y = ty1 + 36 + int(16 * math.sin(math.pi * u))
        for t in range(0, 4): c.cv.put(x, y + t, R5["petal"][1 if t < 2 else 2]) if i % 3 else c.cv.put(x, y + t, CREAM)
    line(c.cv, tx1, ty1 + 4, tx1 + 6, ty1 + 36, R5["wood"][3]); line(c.cv, tx2, ty2 + 4, tx2 - 6, ty2 + 36, R5["wood"][3])
    crab(c, 90, c.fy - 76 + 14, 1); tufts(c, 4, 10, 160, R5["leaf"])
def isl_tide_cave(c):
    ground(c, 80, 12); lump(c.cv, 85, c.fy - 36, 74, 44, R5["stone"], c.rnd, .12)
    ell(c.cv, 85, c.fy - 22, 32, 26, INK); rect(c.cv, 53, c.fy - 22, 118, c.fy - 4, INK); ell(c.cv, 85, c.fy - 22, 27, 21, (24, 40, 70, 255)); rect(c.cv, 58, c.fy - 22, 113, c.fy - 5, (24, 40, 70, 255))
    pond(c, 85, c.fy - 8, 44, 6, R5["sea"], False); waves(c, 44, 126, c.fy - 12);
    for k in range(4): sparkle(c.cv, 70 + k * 10, c.fy - 26 - (k % 2) * 8, R5["sea"][0]) if k % 2 else None
    crab(c, 150, c.fy - 6, 1); shell(c, 20, c.fy - 5, 3, R5["petal"])
def isl_shell_bell_tree(c):
    ground(c, 54, 10); cx = 85
    palm(c, cx - 4, c.fy - 4, 12, 70, R5["leaf"]) if False else None
    col(c.cv, cx - 5, cx + 6, c.fy - 56, c.fy - 4, c.t, c.rnd, .05)
    for (dx, dy, rx, ry) in ((0, -76, 50, 22), (-30, -66, 28, 18), (30, -66, 28, 18)): lump(c.cv, cx + dx, c.fy + dy, rx, ry, R5["leaf"], c.rnd, .15)
    for i in range(7):
        x = cx - 42 + i * 14; y = c.fy - 62 + (i % 3) * 6; line(c.cv, x, y, x, y + 16 + (i % 2) * 6, CREAM); shell(c, x, y + 26 + (i % 2) * 6, 4 + i % 2, R5["petal"] if i % 2 else R5["sand"])
    for (x, y) in ((40, c.fy - 40), (128, c.fy - 44)): sparkle(c.cv, x, y, CREAM)
def grass_hay_cart_ruts(c):
    ground(c, 80, 13)
    for k, off in enumerate((-8, 8)):
        for x in range(8, 162):
            y = c.fy - 14 + off + int(round(math.sin(x / 26.0) * 3));
            for t in range(-2, 3): c.cv.put(x, y + t, R5["litter"][3 if t > 0 else 2 if t > -2 else 1])
            c.cv.put(x, y - 3, c.g[0])
    for x in range(20, 150, 12): line(c.cv, x, c.fy - 22, x + 6, c.fy - 22 + 1, R5["gold"][1]) if x % 24 == 0 else None
    lump(c.cv, 150, c.fy - 8, 9, 6, R5["gold"], c.rnd, .15); tufts(c, 8)
def forest_fallen_log_bridge(c):
    lump(c.cv, 85, c.fy - 4, 82, 8, c.g, c.rnd, .1)
    for sx in (0, 1): poly(c.cv, [(sx * 132, c.fy - 4), (sx * 132, c.fy - 40), (sx * 132 + 38, c.fy - 40), (sx * 132 + (38 if sx == 0 else 0), c.fy - 4)], R5["litter"][1])
    rect(c.cv, 38, c.fy - 4, 132, c.fy - 1, R5["litter"][4])
    for y in range(c.fy - 40, c.fy - 3):
        for x in list(range(0, 38)) + list(range(132, 170)):
            if c.cv.get(x, y) == R5["litter"][1]: c.cv.put(x, y, R5["litter"][0 if x < 12 else 1 if x < 30 else 2 if (x + y) % 9 else 3])
    for x in range(14, 160):
        y = c.fy - 44 + int(5 * math.sin(math.pi * (x - 14) / 146.0))
        for t in range(0, 14): c.cv.put(x, y + t, c.t[0 if t < 3 else 1 if t < 8 else 2 if t < 12 else 3])
    ell(c.cv, 14, c.fy - 40, 3, 7, c.t[0]); ell(c.cv, 14, c.fy - 40, 1, 4, R5["sand"][1]); lump(c.cv, 80, c.fy - 46, 20, 3, R5["moss"], c.rnd, .1)
    fern(c, 150, c.fy - 40, 20, R5["leaf"], 3)
def forest_bluebell_glade(c):
    ground(c, 78, 13)
    for i in range(46):
        x = 12 + (i * 37) % 146; y = c.fy - 6 - (i * 19) % 24
        line(c.cv, x, y, x, y - 8, R5["leaf"][2]); line(c.cv, x, y - 8, x + 2, y - 11, R5["leaf"][2])
        for k in range(3): ell(c.cv, x + 2 + (k % 2), y - 10 + k * 2 + 1, 2, 2, R5["dusk"][1 if k < 2 else 2]); c.cv.put(x + 2, y - 10, R5["dusk"][0])
    for (x, y) in ((50, c.fy - 40), (120, c.fy - 46), (86, c.fy - 52)): ell(c.cv, x, y, 3, 3, CREAM) if False else sparkle(c.cv, x, y, R5["dusk"][0])
    leafy(c, 16, c.fy - 2, 20, R5["leaf"], 6); leafy(c, 154, c.fy - 2, 20, R5["leaf"], 6)
def coast_tide_pool_steps(c):
    ground(c, 80, 12)
    for i in range(5):
        x0 = 10 + i * 22; y = c.fy - 8 - i * 9; col(c.cv, x0, x0 + 52, y - 10, y, c.r, c.rnd, .08); ell(c.cv, x0 + 26, y - 10, 26, 4, c.r[0]); pond(c, x0 + 26, y - 10, 14, 3, R5["sea"], False)
    crab(c, 40, c.fy - 22, 1); crab(c, 120, c.fy - 40, 1); shell(c, 20, c.fy - 4, 3, R5["petal"])
def coast_stranded_rowboat(c):
    ground(c, 80, 12); cx = 85
    poly(c.cv, [(cx - 54, c.fy - 34), (cx + 54, c.fy - 34), (cx + 40, c.fy - 8), (cx - 40, c.fy - 8)], c.t[2])
    for y in range(c.fy - 34, c.fy - 7):
        for x in range(cx - 54, cx + 55):
            if c.cv.get(x, y) == c.t[2]: c.cv.put(x, y, c.t[0 if y < c.fy - 28 else 1 if (y - c.fy) % 7 else 3] if x > cx - 36 else c.t[1])
    rect(c.cv, cx - 54, c.fy - 36, cx + 55, c.fy - 33, c.t[0]); rect(c.cv, cx - 54, c.fy - 34, cx + 55, c.fy - 33, c.t[1]); rect(c.cv, cx - 4, c.fy - 36, cx + 6, c.fy - 20, c.t[3]) if False else None
    line(c.cv, cx - 20, c.fy - 36, cx + 12, c.fy - 50, c.t[1], 3); poly(c.cv, [(cx + 10, c.fy - 52), (cx + 22, c.fy - 54), (cx + 14, c.fy - 46)], c.t[1])
    rock(c, 20, c.fy - 5, 8, 4); waves(c, 130, 168, c.fy - 6); shell(c, 140, c.fy - 12, 3, R5["petal"])
def tun_snow_fort(c):
    ground(c, 80, 12, R5["snow"])
    for row in range(3):
        for k in range(6 - row): lump(c.cv, 38 + k * 18 + row * 9, c.fy - 12 - row * 14, 10, 8, R5["snow"], c.rnd, .06)
    for x in (26, 52, 78, 104, 130): lump(c.cv, x, c.fy - 52, 8, 8, R5["snow"], c.rnd, .06) if x % 52 != 0 else None
    sign_flag(c, 84, c.fy - 96, c.fy - 44, R5["ember"]); lump(c.cv, 130, c.fy - 8, 7, 7, R5["snow"], c.rnd, .06); lump(c.cv, 144, c.fy - 6, 5, 5, R5["snow"], c.rnd, .06); rock(c, 24, c.fy - 5, 6, 3, R5["ice"])
def tun_lone_fir(c):
    ground(c, 60, 11, R5["snow"]); pinetree(c, 85, c.fy - 4, 118, R5["pine"], True); lump(c.cv, 85, c.fy - 6, 34, 8, R5["snow"], c.rnd, .06); rock(c, 128, c.fy - 5, 8, 4, R5["ice"]); tufts(c, 3, 20, 150, R5["ice"])
def tun_aurora_rise(c):
    lump(c.cv, 85, c.fy - 12, 82, 18, R5["snow"], c.rnd, .06)
    for k in range(3):
        for x in range(14, 160):
            y = 20 + k * 6 + int(round(math.sin(x / 18.0 + k) * 8))
            for t in range(0, 22): c.cv.put(x, y + t, (R5["moss"][0][:3] + (200 - t * 8,)) if k != 1 else (R5["dusk"][0][:3] + (190 - t * 8,)))
    for (x, y) in ((30, 60), (70, 40), (110, 70), (140, 30), (20, 20)): sparkle(c.cv, x, y, CREAM)
    pinetree(c, 20, c.fy - 8, 40, R5["pine"], True); pinetree(c, 148, c.fy - 8, 44, R5["pine"], True)
def tun_frozen_stream(c):
    ground(c, 80, 12, R5["snow"])
    for x in range(0, 170):
        yb = c.fy - 24 + int(round(math.sin(x / 20.0) * 8))
        for t in range(-7, 8): c.cv.put(x, yb + t, R5["ice"][0 if t < -4 else 1 if t < 0 else 2 if t < 4 else 3] if (x + t * 3) % 23 else CREAM)
    for k in range(5): line(c.cv, 20 + k * 30, c.fy - 26 + (k % 2) * 4, 34 + k * 30, c.fy - 22 + (k % 2) * 4, CREAM)
    rock(c, 14, c.fy - 6, 8, 4, R5["ice"]); reeds(c, 140, c.fy - 6, 2, 4, 14)
def tun_ice_shelf_steps(c):
    ground(c, 80, 12, R5["snow"])
    for i in range(5):
        x0 = 12 + i * 10; y = c.fy - 6 - i * 14; col(c.cv, x0, 158 - i * 10, y - 12, y, R5["ice"], c.rnd, .05); rect(c.cv, x0, y - 13, 158 - i * 10, y - 11, CREAM);
    for (x, y) in ((50, c.fy - 36), (110, c.fy - 56)): sparkle(c.cv, x, y, CREAM)
def tun_star_chart(c):
    ground(c, 78, 12, R5["snow"])
    for (x, y, rx, ry) in ((38, c.fy - 12, 22, 8), (86, c.fy - 18, 26, 9), (134, c.fy - 10, 22, 8)):
        lump(c.cv, x, y, rx, ry, R5["stone"], c.rnd, .1)
        pts = [(x - 12 + (k * 7) % 22, y - 3 + (k * 3) % 5) for k in range(5)]
        for p_ in pts: c.cv.put(p_[0], p_[1], CREAM)
        for a, b in zip(pts, pts[1:]): line(c.cv, a[0], a[1], b[0], b[1], R5["stone"][4] if False else INK)
def coast_sandbar(c):
    band(c, 0, 170, c.fy - 70, c.fy - 4, R5["sea"])
    poly(c.cv, [(0, c.fy - 22), (170, c.fy - 22), (170, c.fy - 14), (0, c.fy - 14)], R5["sand"][1])
    for x in range(0, 170):
        for y in range(c.fy - 24, c.fy - 12):
            if c.cv.get(x, y) == R5["sand"][1]: c.cv.put(x, y, R5["sand"][0 if y < c.fy - 20 else 1 if y < c.fy - 16 else 2])
    for x in range(0, 170, 5): c.cv.put(x, c.fy - 25, CREAM); c.cv.put(x, c.fy - 11, CREAM)
    for (x, y) in ((30, c.fy - 40), (80, c.fy - 54), (130, c.fy - 36), (100, c.fy - 6)): sparkle(c.cv, x, y, CREAM)
def coast_barnacle_wall(c):
    ground(c, 80, 11)
    for row in range(4):
        for k in range(7): rock(c, 18 + k * 22 + (row % 2) * 11, c.fy - 10 - row * 14, 13, 8, c.r)
    for i in range(46):
        x = 8 + (i * 29) % 154; y = c.fy - 6 - (i * 13) % 52; ell(c.cv, x, y, 2, 2, CREAM); c.cv.put(x, y, R5["stone"][3])
    for x in range(10, 160, 24): lump(c.cv, x, c.fy - 62, 8, 4, R5["moss"], c.rnd, .15)
    crab(c, 150, c.fy - 4, 1)
def coast_dune_grass(c):
    lump(c.cv, 85, c.fy - 20, 82, 26, R5["sand"], c.rnd, .08)
    for i in range(36):
        x = 12 + (i * 31) % 146; y = c.fy - 12 - (i * 13) % 20
        for k in range(24 + i % 8): c.cv.put(x + k // 4 + k // 8, y - k + (k // 6), R5["moss"][0 if k > 18 else 1 + (k % 2)]); c.cv.put(x + 1 + k // 4, y - k + 1, R5["moss"][2]) if k < 10 else None
def coast_driftwood_arch(c):
    ground(c, 76, 12); cx = 85
    for x in range(cx - 50, cx + 51):
        u = (x - cx) / 50.0; yy = c.fy - 12 - int(70 * math.sqrt(max(0, 1 - u * u)))
        for t in range(0, 9 if abs(u) < .92 else 6): c.cv.put(x, yy + t, R5["snow"][0 if t < 2 else 1 if t < 6 else 2]) if True else None
    for sx in (-1, 1):
        for y in range(c.fy - 24, c.fy - 4): rect(c.cv, cx + sx * 46 - 4, y, cx + sx * 46 + 5, y + 1, R5["snow"][1 if (y // 5) % 2 else 2])
    for k in range(8):
        x = cx - 32 + k * 9; yy = c.fy - 12 - int(70 * math.sqrt(max(0, 1 - ((x - cx) / 50.0) ** 2))) + 9; line(c.cv, x, yy, x, yy + 10 + (k % 3) * 4, CREAM); shell(c, x, yy + 18 + (k % 3) * 4, 3, R5["petal"] if k % 2 else R5["sand"])
    for (x, y) in ((cx - 10, c.fy - 70), (cx + 20, c.fy - 62)): sparkle(c.cv, x, y, CREAM)
def mtn_cairn_pass(c):
    ground(c, 80, 11)
    for i, (x, n) in enumerate(((26, 2), (56, 3), (90, 4), (126, 5), (152, 6))):
        for k in range(n): rock(c, x + (k % 2) * 2 - 1, c.fy - 6 - k * 9, 12 - k, 5, R5["stone"])
    for (x, y) in ((76, c.fy - 70), (140, c.fy - 62)): sign_flag(c, x, y, y + 24, R5["petal"]) if False else None
def isl_sand_spit(c):
    band(c, 0, 170, c.fy - 70, c.fy - 4, R5["sea"])
    poly(c.cv, [(0, c.fy - 12), (30, c.fy - 26), (110, c.fy - 40), (162, c.fy - 44), (156, c.fy - 36), (112, c.fy - 26), (32, c.fy - 6)], R5["sand"][1])
    for y in range(c.fy - 46, c.fy - 4):
        for x in range(0, 170):
            if c.cv.get(x, y) == R5["sand"][1]: c.cv.put(x, y, R5["snow"][0] if y < c.fy - 34 and x > 100 else R5["sand"][0 if y < c.fy - 24 else 1 if (x + y) % 9 else 2])
    for x in range(10, 160, 4): c.cv.put(x, c.fy - 12 - int(x * .2) + (x % 8 == 0) * 0 - 10 if False else c.fy - 8 - int(x * .22), CREAM)
    for (x, y) in ((44, c.fy - 30), (90, c.fy - 54), (130, c.fy - 18)): sparkle(c.cv, x, y, CREAM)
    shell(c, 70, c.fy - 22, 3, R5["petal"]); shell(c, 112, c.fy - 34, 2)
def isl_rope_swing(c):
    ground(c, 70, 11); pond(c, 100, c.fy - 14, 58, 12, R5["sea"], True)
    col(c.cv, 28, 40, c.fy - 106, c.fy - 4, c.t, c.rnd, .05)
    for (dx, dy, rx, ry) in ((34, -118, 40, 18), (16, -100, 22, 14), (56, -104, 24, 14)): lump(c.cv, dx + 10, c.fy + dy, rx, ry, R5["leaf"], c.rnd, .15)
    line(c.cv, 40, c.fy - 100, 96, c.fy - 96, c.t[2], 5); line(c.cv, 96, c.fy - 92, 96, c.fy - 40, R5["sand"][3]); rect(c.cv, 90, c.fy - 40, 103, c.fy - 36, c.t[1]); rect(c.cv, 90, c.fy - 40, 103, c.fy - 39, c.t[0])
    for (x, y) in ((70, c.fy - 20), (120, c.fy - 12)): c.cv.put(x, y, CREAM)
def isl_reef_shallows(c):
    pond(c, 85, c.fy - 22, 80, 26, R5["sea"], False)
    for i in range(5): lump(c.cv, 24 + i * 30, c.fy - 8 - (i % 2) * 6, 14, 6, [R5["petal"], R5["gold"], R5["dusk"]][i % 3], c.rnd, .15)
    for (x, y, R, f) in ((40, 44, R5["gold"], 0), (70, 30, R5["ember"], 1), (104, 52, R5["petal"], 0), (126, 36, R5["gold"], 1), (86, 22, R5["dusk"], 0)): fish(c, x, c.fy - y + 20, R, 1, f)
    for k in range(6): ell(c.cv, 20 + k * 26, c.fy - 40 + (k % 2) * 6, 1, 1, CREAM)
    waves(c, 4, 166, c.fy - 46)
def isl_palm_lean(c):
    ground(c, 70, 11); tx, ty = palm(c, 40, c.fy - 4, 82, 86)
    rect(c.cv, tx + 6, ty + 4, tx + 15, ty + 14, R5["wood"][2]) if False else None
    for k in range(3): ell(c.cv, tx - 4 + k * 6, ty + 6 + (k % 2) * 3, 4, 4, R5["wood"][1 + k % 2])
    crab(c, 150, c.fy - 6, 1); shell(c, 100, c.fy - 5, 3, R5["petal"])
def wet_reed_causeway(c):
    ground(c, 80, 12, R5["litter"]); pond(c, 85, c.fy - 10, 80, 12, R5["sea"], False)
    poly(c.cv, [(8, c.fy - 4), (162, c.fy - 4), (150, c.fy - 20), (20, c.fy - 20)], R5["litter"][1]); ripple_lines(c, 24, 148, c.fy - 18, 3, R5["litter"], 5)
    for k in (0, 1):
        for i in range(8): reeds(c, 4 + k * 138 + i * 3, c.fy - 16 + (i % 2) * 3, 1, 3, 40 + (i * 5) % 22)
def wet_heron_post(c):
    ground(c, 72, 12); pond(c, 85, c.fy - 8, 70, 7, R5["sea"], False); cx = 85
    col(c.cv, cx - 5, cx + 6, c.fy - 46, c.fy - 4, c.t, c.rnd, .05); ell(c.cv, cx, c.fy - 47, 7, 3, c.t[0])
    lump(c.cv, cx, c.fy - 76, 9, 14, R5["stone"] and [R5["snow"][1], R5["snow"][2], R5["stone"][1], R5["stone"][2], R5["stone"][3]], c.rnd, 0)
    line(c.cv, cx + 4, c.fy - 84, cx + 8, c.fy - 108, R5["snow"][2], 3); lump(c.cv, cx + 8, c.fy - 110, 5, 4, R5["snow"], c.rnd, 0); line(c.cv, cx + 12, c.fy - 110, cx + 26, c.fy - 108, R5["gold"][1], 2); c.cv.put(cx + 8, c.fy - 111, INK)
    line(c.cv, cx - 2, c.fy - 62, cx - 2, c.fy - 48, R5["gold"][2], 2); line(c.cv, cx + 3, c.fy - 62, cx + 3, c.fy - 48, R5["gold"][2], 2)
    for k in range(4): line(c.cv, cx - 18 + k * 2, c.fy - 84 + k * 4, cx - 6, c.fy - 76 + k * 4, R5["stone"][3 - k % 2])
    reeds(c, 12, c.fy - 4, 3); reeds(c, 140, c.fy - 4, 3)
def isl_coconut_grove(c):
    ground(c, 80, 12)
    palm(c, 30, c.fy - 4, -4, 70); palm(c, 78, c.fy - 4, 6, 84); palm(c, 128, c.fy - 4, -6, 74)
    for (x, y) in ((22, c.fy - 62), (82, c.fy - 74), (122, c.fy - 66), (130, c.fy - 62)): ell(c.cv, x, y + 6, 4, 4, R5["wood"][1]); c.cv.put(x - 1, y + 5, R5["wood"][0])
    ell(c.cv, 60, c.fy - 6, 4, 4, R5["wood"][1]); ell(c.cv, 104, c.fy - 5, 4, 4, R5["wood"][1]); ell(c.cv, 52, c.fy - 5, 3, 3, R5["wood"][2])
def coast_shell_heap(c):
    ground(c, 70, 11); lump(c.cv, 85, c.fy - 20, 56, 20, R5["sand"], c.rnd, .12)
    cl = [R5["petal"], R5["sand"], R5["snow"], R5["gold"], R5["dusk"]]
    for i in range(34):
        a = i * 2.39; r_ = 8 + (i * 5) % 40; x = 85 + int(r_ * math.cos(a) * 1.1); y = c.fy - 24 + int(r_ * .5 * math.sin(a)) - (6 if i % 3 == 0 else 0)
        shell(c, x, y, 3 + i % 3, cl[i % 5])
    for k in range(10): c.cv.put(40 + k * 11, c.fy - 4, R5["sand"][3])
def desert_well(c):
    ground(c, 66, 11); cx = 85
    for row in range(3):
        for k in range(9): rect(c.cv, cx - 28 + k * 7, c.fy - 20 - row * 10, cx - 22 + k * 7, c.fy - 12 - row * 10, c.r[1 + (k + row) % 3])
    lump(c.cv, cx, c.fy - 40, 29, 6, c.r, c.rnd, .08); ell(c.cv, cx, c.fy - 40, 22, 4, INK)
    for x in (cx - 26, cx + 22): col(c.cv, x, x + 5, c.fy - 78, c.fy - 40, c.t, c.rnd, .03)
    rect(c.cv, cx - 28, c.fy - 82, cx + 28, c.fy - 76, c.t[1]); rect(c.cv, cx - 28, c.fy - 82, cx + 28, c.fy - 81, c.t[0]); poly(c.cv, [(cx - 32, c.fy - 76), (cx, c.fy - 96), (cx + 32, c.fy - 76)], c.t[2]) if False else None
    line(c.cv, cx, c.fy - 76, cx, c.fy - 58, R5["sand"][3]); rect(c.cv, cx - 6, c.fy - 58, cx + 7, c.fy - 46, c.t[2]); rect(c.cv, cx - 6, c.fy - 58, cx + 7, c.fy - 56, c.t[0]); rect(c.cv, cx - 7, c.fy - 52, cx + 8, c.fy - 51, R5["stone"][3])
    cactus(c, 22, c.fy - 4, 20, 1); tufts(c, 2)
def isl_lagoon_edge(c):
    pond(c, 85, c.fy - 24, 82, 30, R5["sea"], False);
    for y in range(c.fy - 54, c.fy - 20):
        for x in range(0, 170):
            if c.cv.get(x, y) in R5["sea"]: c.cv.put(x, y, R5["sea"][0 if y > c.fy - 36 else 1])
    lump(c.cv, 85, c.fy - 4, 82, 9, R5["sand"], c.rnd, .08)
    for (x, y, R, f) in ((50, 34, R5["gold"], 0), (80, 26, R5["dusk"], 1), (110, 36, R5["ember"], 0)): fish(c, x, c.fy - y, R, 1, f)
    for x in range(30, 140, 8): c.cv.put(x, c.fy - 18 + (x % 3), CREAM)
    palm(c, 152, c.fy - 6, -14, 44); waves(c, 10, 160, c.fy - 52)
def rain_fallen_giant(c):
    lump(c.cv, 85, c.fy - 6, 82, 10, R5["litter"], c.rnd, .1)
    for x in range(0, 170):
        for y in range(c.fy - 58, c.fy - 6):
            t = (y - (c.fy - 58)) / 52.0;
            if abs(y - (c.fy - 32)) < 26: c.cv.put(x, y, R5["wood"][0 if t < .15 else 1 if t < .4 else 2 if t < .8 else 3] if (x * 3 + y * 7) % 17 else R5["wood"][4])
    ell(c.cv, 6, c.fy - 32, 8, 26, R5["wood"][0]); ell(c.cv, 6, c.fy - 32, 5, 20, R5["sand"][1]);
    for r_ in (4, 9, 14): [c.cv.put(6 + int(r_ * .5 * math.cos(a / 10.0)), c.fy - 32 + int(r_ * 1.3 * math.sin(a / 10.0)), R5["wood"][2]) for a in range(63)]
    lump(c.cv, 80, c.fy - 58, 70, 5, R5["moss"], c.rnd, .15);
    for x in range(30, 150, 20): fern(c, x, c.fy - 58, 14, R5["leaf"], 3) if x % 40 == 30 else flower(c, x, c.fy - 62, R5["petal"], None, 2)
def rain_rain_drum_leaf(c):
    ground(c, 74, 11, R5["litter"]);
    col(c.cv, 80, 88, c.fy - 62, c.fy - 4, R5["leaf"], c.rnd, 0)
    ell(c.cv, 85, c.fy - 62, 62, 18, R5["leaf"][2]); ell(c.cv, 83, c.fy - 65, 58, 15, R5["leaf"][1]); ell(c.cv, 80, c.fy - 69, 40, 8, R5["leaf"][0]); line(c.cv, 28, c.fy - 62, 142, c.fy - 62, R5["leaf"][3])
    for k in range(5): line(c.cv, 40 + k * 20, c.fy - 62, 50 + k * 18, c.fy - 52 - (k % 2) * 3, R5["leaf"][3])
    for (x, y) in ((50, c.fy - 94), (80, c.fy - 108), (118, c.fy - 100), (64, c.fy - 122), (132, c.fy - 120), (98, c.fy - 128)):
        line(c.cv, x, y, x - 1, y + 8, R5["sea"][0], 2);
    for (x, y) in ((50, c.fy - 76), (108, c.fy - 78)): ell(c.cv, x, y, 4, 1, R5["sea"][0]);
    fern(c, 14, c.fy - 6, 26, R5["leaf"], 4)
def rain_lantern_fruit(c):
    ground(c, 70, 11); cx = 85
    col(c.cv, cx - 6, cx + 7, c.fy - 60, c.fy - 4, c.t, c.rnd, .05)
    for (dx, dy, rx, ry) in ((0, -78, 50, 24), (-36, -66, 26, 18), (38, -66, 26, 18)): lump(c.cv, cx + dx, c.fy + dy, rx, ry, R5["pine"], c.rnd, .15)
    for i in range(9):
        x = cx - 48 + i * 12; y = c.fy - 60 + (i % 3) * 10; line(c.cv, x, y - 6, x, y, R5["moss"][3]); glow(c.cv, x, y + 6, 6, R5["gold"] if i % 3 else R5["petal"]) if True else None
    for k in range(5): sparkle(c.cv, 30 + k * 24, c.fy - 20 - (k % 2) * 10, R5["gold"][0])
    fern(c, 18, c.fy - 6, 22, R5["leaf"], 4)
def rain_mist_pool(c):
    ground(c, 76, 12); pond(c, 85, c.fy - 16, 66, 14, R5["sea"], True)
    for k in range(4):
        for j in range(5):
            x = 34 + j * 24 + (k % 2) * 10; y = c.fy - 34 - k * 9 - (j % 2) * 4
            ell(c.cv, x, y, 14, 5, (240, 250, 255, 200 - k * 35)); ell(c.cv, x - 2, y - 1, 8, 3, (255, 255, 255, 220 - k * 35))
    fern(c, 12, c.fy - 6, 24, R5["leaf"], 4); fern(c, 158, c.fy - 6, 24, R5["leaf"], 4); rock(c, 130, c.fy - 8, 9, 5)

PIECES = {
    "the-plank-footbridge": grass_plank_footbridge, "the-picnic-knoll": grass_picnic_knoll, "the-bramble-gap": grass_bramble_gap, "the-shepherd-s-wall": grass_shepherd_wall,
    "the-wind-combed-meadow": grass_wind_combed, "the-dandelion-drift": grass_dandelion_drift, "the-sleepy-windmill": (170, 150, grass_sleepy_windmill),
    "the-lantern-branch": forest_lantern_branch, "the-root-tangle-crossing": forest_root_tangle, "the-spring-and-the-pebbles": forest_spring_pebbles, "the-owl-watch-bough": forest_owl_bough,
    "the-glow-moss-grotto": forest_glow_moss_grotto, "the-mud-skipper-flats": wet_mud_skipper, "the-stilt-house": (170, 140, wet_stilt_house), "the-willow-curtain": (170, 140, wet_willow_curtain),
    "the-peat-bank": wet_peat_bank, "the-scree-slope": mtn_scree, "the-pine-shelf": mtn_pine_shelf, "the-wind-notch": (170, 150, mtn_wind_notch), "the-goat-ledge": mtn_goat_ledge,
    "the-daisy-ring": grass_daisy_ring, "the-fern-tunnel": forest_fern_tunnel, "the-acorn-scatter": forest_acorn_scatter, "the-hollow-oak": (170, 150, forest_hollow_oak), "the-frog-choir": wet_frog_choir,
    "the-rope-bridge": mtn_rope_bridge, "the-waterfall-mist": (170, 140, mtn_waterfall), "the-boardwalk-gap": wet_boardwalk_gap, "the-clover-patch": grass_clover, "the-lonely-scarecrow": (170, 130, grass_scarecrow),
    "the-old-milestone": grass_milestone, "the-mushroom-ring": forest_mushroom_ring, "the-mossy-stair": forest_mossy_stair, "the-woodcutter-s-stump": forest_woodcutter_stump,
    "the-lighthouse-shadow": (170, 140, coast_lighthouse_shadow), "the-kelp-line": coast_kelp_line, "the-rope-and-net-rack": coast_rope_net_rack, "the-sun-bleached-bones": desert_bones,
    "the-salt-flat": desert_salt_flat, "the-shade-awning": desert_shade_awning, "the-bottle-post": (170, 130, coast_bottle_post), "the-red-rock-arch": (170, 140, desert_red_arch),
    "the-sand-ripple-lane": desert_ripple_lane, "the-waystone-cluster": desert_waystones, "the-dry-riverbed": desert_dry_riverbed, "the-lily-pad-ford": wet_lily_ford,
    "the-dragonfly-bend": wet_dragonfly_bend, "the-stepping-roots": rain_stepping_roots, "the-giant-fern-glade": (170, 140, rain_giant_fern_glade), "the-orchid-tree": (170, 150, rain_orchid_tree),
    "the-canopy-gap": (170, 140, rain_canopy_gap), "the-parrot-perch": (170, 140, rain_parrot_perch), "the-vine-bridge": rain_vine_bridge, "the-mirage-pool": desert_mirage_pool,
    "the-cactus-garden": desert_cactus_garden, "the-eagle-s-rest": (170, 140, mtn_eagle_rest), "the-stone-hut": (170, 140, mtn_stone_hut), "the-echo-wall": (170, 140, mtn_echo_wall),
    "the-trader-s-tent-poles": desert_trader_poles, "the-switchback-bend": (170, 130, mtn_switchback), "the-hammock-palms": (170, 140, isl_hammock_palms), "the-tide-cave": isl_tide_cave,
    "the-shell-bell-tree": (170, 140, isl_shell_bell_tree), "the-hay-cart-ruts": grass_hay_cart_ruts, "the-fallen-log-bridge": forest_fallen_log_bridge, "the-bluebell-glade": forest_bluebell_glade,
    "the-tide-pool-steps": coast_tide_pool_steps, "the-stranded-rowboat": coast_stranded_rowboat, "the-snow-fort": tun_snow_fort, "the-lone-fir": (170, 150, tun_lone_fir),
    "the-aurora-rise": tun_aurora_rise, "the-frozen-stream": tun_frozen_stream, "the-ice-shelf-steps": tun_ice_shelf_steps, "the-star-chart-stones": tun_star_chart,
    "the-sandbar-causeway": coast_sandbar, "the-barnacle-wall": coast_barnacle_wall, "the-dune-grass-sweep": coast_dune_grass, "the-driftwood-arch": (170, 150, coast_driftwood_arch),
    "the-cairn-pass": (170, 130, mtn_cairn_pass), "the-sand-spit": isl_sand_spit, "the-rope-swing": (170, 140, isl_rope_swing), "the-sea-stack-gap": None,
    "the-reef-shallows": isl_reef_shallows, "the-palm-lean": (170, 140, isl_palm_lean), "the-reed-causeway": wet_reed_causeway, "the-heron-s-post": (170, 140, wet_heron_post),
    "the-coconut-grove": (170, 140, isl_coconut_grove), "the-shell-heap": coast_shell_heap, "the-well-and-its-rope": (170, 130, desert_well), "the-lagoon-edge": isl_lagoon_edge,
    "the-fallen-giant": rain_fallen_giant, "the-rain-drum-leaf": (170, 150, rain_rain_drum_leaf), "the-lantern-fruit": (170, 140, rain_lantern_fruit), "the-mist-pool": rain_mist_pool,
}
def coast_sea_stack_gap(c):
    ground(c, 76, 11)
    for (cx, wd, hh, ln) in ((38, 22, 90, 3), (132, 24, 100, -4)): standing(c, cx, c.fy - 4, wd, hh, ln, R5["stone"])
    for (cx, hh) in ((38, 90), (132, 100)): lump(c.cv, cx, c.fy - hh - 2, 14, 5, R5["moss"], c.rnd, .1)
    pond(c, 85, c.fy - 6, 34, 5, R5["sea"], False);
    for k in range(7): c.cv.put(75 + k * 3, c.fy - 22 - (k * 5) % 14, CREAM); c.cv.put(76 + k * 3, c.fy - 21 - (k * 5) % 14, R5["sea"][0])
    bird(c, 60, c.fy - 100, R5["snow"], 1); shell(c, 110, c.fy - 4, 3, R5["petal"])
PIECES["the-sea-stack-gap"] = (170, 130, coast_sea_stack_gap)

def _norm(v):
    if v is None: return None
    return v if isinstance(v, tuple) else (W0, H0, v)
MASK = {"the-pine-shelf", "the-wind-notch", "the-mountain-scree", "the-echo-wall", "the-switchback-bend", "the-sandbar-causeway", "the-sand-spit", "the-fallen-giant", "the-waterfall-mist", "the-scree-slope"}
def _round(cv, w, h, n=3.2):
    """full-bleed pieces (cliffs, water patches) get rounded corners so they do not read as boxes on the map"""
    for y in range(h):
        for x in range(w):
            if abs((x - w / 2.0) / (w / 2.0)) ** n + abs((y - h / 2.0) / (h / 2.0)) ** n > 1: cv.p[x, y] = (0, 0, 0, 0)
def _mk(land, w, h, fn, rounded=False):
    def draw(rnd, cv):
        fn(Ctx(cv, rnd, land, w, h))
        if rounded: _round(cv, w, h)
    return (w, h, draw)
_CAT = os.path.join(_here, "..", "trail-landmarks", "setpieces.json")
LM = {}
try:
    for slug, v in json.load(open(_CAT, encoding="utf-8")).items():
        if slug.startswith("end-"): continue
        feat = slug.split("-", 1)[1]
        spec = _norm(PIECES.get("the-" + feat if not feat.startswith("the-") else feat))
        if spec is None: continue
        LM[slug] = _mk(v["land"], *spec, rounded=("the-" + feat if not feat.startswith("the-") else feat) in MASK)
except OSError:
    pass
