"""Hearth Pop v3 trail tiles, pass 2: more realism (tileable noise ground, lump-built crowns, faceted rocks, bark, foam), find-spot
sprites per land, a search icon. Hard pixels only. Run: python3 -I gen2.py <repo-root>"""
import json, math, random, sys, os, zlib
from PIL import Image
ROOT = sys.argv[1] if len(sys.argv) > 1 else ""; OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "pass2")
T = 64; OBJ_H = 96
def H(h): return tuple(int(h[i:i+2], 16) for i in (1, 3, 5)) + (255,)
def mix(a, b, t): return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3)) + (255,)
INK = H("#2b1c26"); CREAM = H("#fff4d6")
RAMP = {
 "moss":  [H(c) for c in ("#c4e07a", "#7cc35a", "#3f9150", "#24544a")],
 "leaf":  [H(c) for c in ("#a6d86a", "#5fae4f", "#337a48", "#1d4545")],
 "pine":  [H(c) for c in ("#7cc08a", "#3c9060", "#276a55", "#173f48")],
 "wood":  [H(c) for c in ("#e8b982", "#b97a4a", "#864c33", "#51302b")],
 "stone": [H(c) for c in ("#e2e0e6", "#aaa9b8", "#74758c", "#444663")],
 "sea":   [H(c) for c in ("#b6f0e0", "#5fc4c8", "#3a86b0", "#2a4a7a")],
 "sand":  [H(c) for c in ("#fff0b8", "#ebcd8c", "#c39a64", "#7d5a49")],
 "snow":  [H(c) for c in ("#f4fbff", "#d6ecf8", "#a9c9ea", "#7b8fc6")],
 "gold":  [H(c) for c in ("#ffe38a", "#f5b82e", "#d98322", "#8f4a1f")],
 "petal": [H(c) for c in ("#ffc4d8", "#f5809f", "#c94f84", "#7d2c5e")],
 "ember": [H(c) for c in ("#ff8a5c", "#e8493b", "#b52e3f", "#6e2038")],
 "dusk":  [H(c) for c in ("#c9b2f0", "#8a6fd0", "#5a459e", "#35295f")],
 "litter":[H(c) for c in ("#c9a06a", "#9a6a3f", "#744530", "#4a2c2b")],
 "ice":   [H(c) for c in ("#e8f6ff", "#bfe0f2", "#8ec0e6", "#6a94cc")],
}
def r5(R): return [R[0], mix(R[0], R[1], .5), R[1], R[2], R[3]]   # 5-tone ramp for raised things
STEP = {}
for k, v in RAMP.items():
    for i, c in enumerate(v): STEP.setdefault(c, (k, i))
def darker(c, n=1):
    if c in STEP: k, i = STEP[c]; return RAMP[k][min(3, i + n)]
    return tuple(int(v * (.82 ** n)) for v in c[:3]) + (255,)

class Cv:
    def __init__(s, w, h): s.im = Image.new("RGBA", (w, h), (0, 0, 0, 0)); s.p = s.im.load(); s.w, s.h = w, h
    def put(s, x, y, c, wrap=False):
        if wrap: x %= s.w; y %= s.h
        if 0 <= x < s.w and 0 <= y < s.h: s.p[x, y] = c
    def get(s, x, y): return s.p[x, y] if 0 <= x < s.w and 0 <= y < s.h else (0, 0, 0, 0)
def outline(cv, col=INK):
    sp = cv.im.copy().load()
    for y in range(cv.h):
        for x in range(cv.w):
            if sp[x, y][3] == 0 and any(0 <= x+dx < cv.w and 0 <= y+dy < cv.h and sp[x+dx, y+dy][3] for dx, dy in ((1,0),(-1,0),(0,1),(0,-1))): cv.p[x, y] = col

# ---------------------------------------------------------------- tileable value noise
def noise(rnd, n):
    g = [[rnd.random() for _ in range(n)] for _ in range(n)]
    def f(x, y):
        fx, fy = x / T * n, y / T * n; x0, y0 = int(fx), int(fy); tx, ty = fx - x0, fy - y0
        tx = tx * tx * (3 - 2 * tx); ty = ty * ty * (3 - 2 * ty)
        a, b = g[y0 % n][x0 % n], g[y0 % n][(x0 + 1) % n]; c, d = g[(y0 + 1) % n][x0 % n], g[(y0 + 1) % n][(x0 + 1) % n]
        return (a + (b - a) * tx) * (1 - ty) + (c + (d - c) * tx) * ty
    return f
def field(rnd):
    a, b, c = noise(rnd, 4), noise(rnd, 8), noise(rnd, 16)
    return [[.45 * a(x, y) + .33 * b(x, y) + .22 * c(x, y) for x in range(T)] for y in range(T)]
def ground_base(rnd, R, hi_t=.6, lo_t=.4, bias=0):
    v = field(rnd); lo = [mix(R[1], R[2], .6), mix(R[1], R[2], .28)]; hi = [mix(R[1], R[0], .28), mix(R[1], R[0], .55)]
    cv = Cv(T, T)
    # stretch field to full 0..1 so the tones all appear
    flat = sorted(c for row in v for c in row); q = lambda p: flat[int(p * (len(flat) - 1))]
    t1, t2, t3, t4 = q(.10 + bias), q(.30 + bias), q(.72 + bias), q(.91 + bias)
    for y in range(T):
        for x in range(T):
            c = v[y][x]; cv.p[x, y] = lo[0] if c < t1 else lo[1] if c < t2 else R[1] if c < t3 else hi[0] if c < t4 else hi[1]
    return cv
def blade(cv, x, y, h, lean, R, rnd):
    for k in range(h):
        px = x + int(lean * k / max(1, h - 1) + .5)
        c = R[3] if k == 0 else R[0] if k >= h - 2 else R[1] if k > h // 3 else R[2]
        cv.put(px, y - k, c, True)
        if k < h // 2 and k > 0: cv.put(px + 1, y - k, R[2], True)
def clump(cv, x, y, n, hmin, hmax, R, rnd, spread=5):
    for _ in range(n): blade(cv, x + rnd.randint(-spread, spread), y + rnd.randint(-1, 1), rnd.randint(hmin, hmax), rnd.choice((-2, -1, 0, 1, 2)), R, rnd)
def pebble(cv, x, y, R, rnd, w=3):
    for dx in range(w):
        for dy in range(2): cv.put(x + dx, y + dy, R[1] if dy == 0 and dx < w - 1 else R[2], True)
    cv.put(x, y, R[0], True); cv.put(x + 1, y + 2, darker(R[3]), True); cv.put(x + 2, y + 2, R[3], True)
def spots(rnd, n): return [(rnd.randrange(T), rnd.randrange(T)) for _ in range(n)]

def ground(land, kind, seed):
    rnd = random.Random(f"g2{land}{kind}{seed}")
    if land == "grassland":
        R = RAMP["moss"] if kind == "floor" else RAMP["leaf"]
        cv = ground_base(rnd, R, bias=.0 if kind == "floor" else .05)
        if kind == "floor":
            for x, y in spots(rnd, 34): blade(cv, x, y, rnd.randint(2, 3), rnd.choice((-1, 0, 1)), RAMP["moss"], rnd)
            for x, y in spots(rnd, 3):
                for dx, dy in ((0, 0), (2, 0), (1, -1), (1, 1)): cv.put(x + dx, y + dy, RAMP["moss"][2], True)
            for x, y in spots(rnd, 2):   # daisy
                for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)): cv.put(x + dx, y + dy, CREAM, True)
                cv.put(x, y, RAMP["gold"][1], True)
        else:
            for x, y in spots(rnd, 16): clump(cv, x, y, 5, 5, 9, RAMP["leaf"], rnd, 4)
            for x, y in spots(rnd, 5):   # seed heads
                for k in range(3): cv.put(x, y - 9 - k, RAMP["gold"][1 if k else 0], True)
            for x, y in spots(rnd, 3):
                f = RAMP["petal"] if rnd.random() < .6 else RAMP["ember"]
                for dx, dy, c in ((0, 0, f[0]), (1, 0, f[1]), (-1, 0, f[1]), (0, 1, f[2]), (0, -1, f[1])): cv.put(x + dx, y - 6 + dy, c, True)
                cv.put(x, y - 5, RAMP["leaf"][2], True); cv.put(x, y - 4, RAMP["leaf"][2], True)
    elif land == "forest":
        R = RAMP["litter"] if kind == "floor" else RAMP["moss"]
        cv = ground_base(rnd, R if kind == "floor" else [H("#7fb86a"), H("#3f8a50"), H("#2c6a48"), H("#1d4545")])
        if kind == "floor":
            for x, y in spots(rnd, 6):   # fallen leaves, with a midrib
                L = rnd.choice((RAMP["ember"], RAMP["gold"], RAMP["wood"], RAMP["wood"], RAMP["litter"])); w = rnd.choice((5, 6))
                for dx in range(w):
                    for dy in range(2 if 0 < dx < w - 1 else 1): cv.put(x + dx, y + dy, L[1] if dy == 0 else L[2], True)
                for dx in range(1, w - 1): cv.put(x + dx, y, L[0] if dx < 3 else L[1], True)
                cv.put(x + w // 2, y + 1, L[3], True)
            for x, y in spots(rnd, 12):  # pine needles
                d = rnd.choice((-1, 1))
                for k in range(4): cv.put(x + d * k, y + k // 2, RAMP["litter"][0] if k else RAMP["litter"][2], True)
            for x, y in spots(rnd, 3): pebble(cv, x, y, RAMP["stone"], rnd)
            for x, y in spots(rnd, 1):   # twig with a fork
                for k in range(8): cv.put(x + k, y + (k // 4), RAMP["wood"][2 if k % 2 else 1], True)
                cv.put(x + 5, y + 1, RAMP["wood"][2], True); cv.put(x + 6, y - 1, RAMP["wood"][1], True)
        else:
            for x, y in spots(rnd, 7):   # ferns: a stem with leaflet pairs
                for k in range(9):
                    cv.put(x + k // 4, y - k, RAMP["leaf"][2], True)
                    if k > 1 and k % 2 == 0:
                        for s in (-1, 1):
                            cv.put(x + k // 4 + s * 2, y - k, RAMP["leaf"][1 if s < 0 else 0], True); cv.put(x + k // 4 + s * 3, y - k + 1, RAMP["leaf"][2], True)
            for x, y in spots(rnd, 1):   # toadstool
                for dx, dy, c in ((-2, 0, RAMP["ember"][1]), (-1, -1, RAMP["ember"][0]), (0, -1, RAMP["ember"][0]), (1, -1, RAMP["ember"][1]), (2, 0, RAMP["ember"][2]), (-1, 0, RAMP["ember"][1]), (0, 0, RAMP["ember"][1]), (1, 0, RAMP["ember"][2]), (0, -1, CREAM)): cv.put(x + dx, y + dy - 3, c, True)
                for k in range(3): cv.put(x, y - k + 0, CREAM if k else RAMP["wood"][3], True)
    elif land == "coast":
        R = RAMP["sand"]
        cv = ground_base(rnd, R, bias=.0)
        for x, y in spots(rnd, 7 if kind == "floor" else 4):   # wind ripples: lit crest over a shade line
            n = rnd.randint(8, 14); ph = rnd.random() * 6
            for k in range(n):
                yy = y + int(1.2 * math.sin(k * .6 + ph)); cv.put(x + k, yy, R[0], True); cv.put(x + k, yy + 1, R[2], True)
        for x, y in spots(rnd, 20): cv.put(x, y, R[3], True)
        for x, y in spots(rnd, 3):   # shell bit
            for dx, dy, c in ((0, 0, CREAM), (1, 0, R[0]), (0, 1, RAMP["petal"][1]), (1, 1, RAMP["petal"][2])): cv.put(x + dx, y + dy, c, True)
        if kind == "rough":
            sg = [H("#d8e48a"), H("#9cba58"), H("#5e8a4c"), H("#3a5c46")]
            for x, y in spots(rnd, 8): clump(cv, x, y, 4, 4, 8, sg, rnd, 3)
            for x, y in spots(rnd, 6): pebble(cv, x, y, RAMP["stone"], rnd)
            for x, y in spots(rnd, 1):   # starfish
                for dx, dy in ((0, 0), (-1, 0), (1, 0), (0, -1), (0, 1), (-2, 1), (2, 1)): cv.put(x + dx, y + dy, RAMP["ember"][1], True)
                cv.put(x, y, RAMP["ember"][0], True); cv.put(x + 1, y + 1, RAMP["ember"][2], True)
    else:  # tundra
        R = RAMP["snow"]
        cv = ground_base(rnd, R, bias=.0)
        for x, y in spots(rnd, 6):   # drift edges: hi crest, shade lip under
            n = rnd.randint(10, 18); ph = rnd.random() * 6
            for k in range(n):
                yy = y + int(1.5 * math.sin(k * .45 + ph)); cv.put(x + k, yy, CREAM if k % 3 else R[0], True); cv.put(x + k, yy + 1, R[2], True)
        for x, y in spots(rnd, 16):
            cv.put(x, y, R[0], True); cv.put(x + 1, y, R[0], True)
        if kind == "rough":
            ft = [H("#c6e0f0"), H("#8fb4d8"), H("#6a86bc"), H("#4a5c94")]
            for x, y in spots(rnd, 9): clump(cv, x, y, 4, 3, 7, ft, rnd, 3)
            for x, y in spots(rnd, 2):  # patch of clear ice
                for dy in range(-3, 4):
                    for dx in range(-5, 6):
                        if dx * dx / 25 + dy * dy / 9 <= 1: cv.put(x + dx, y + dy, RAMP["ice"][1 if dy > -2 else 0], True)
                for k in range(5): cv.put(x - 2 + k, y + 1 - (k % 2), RAMP["ice"][3], True)
        for x, y in spots(rnd, 4):  # mitten-sized paw prints (pairs of dots)
            cv.put(x, y, R[2], True); cv.put(x + 2, y + 3, R[2], True)
    return cv.im

PATH_RAMP = {"grassland": "litter", "forest": "sand", "coast": "litter", "tundra": "litter"}   # the floor of forest is already brown, of coast sand and of tundra white, so those paths take a colour that shows: pale in the forest, trodden brown on the beach and in the snow
def pathtex(land, seed):
    """Worn path ground ('p' tiles): packed dirt in the land's own colour, ruts and pebbles; tileable like the rest."""
    rnd = random.Random(f"p2{land}{seed}"); R = RAMP[PATH_RAMP.get(land, "litter")]
    cv = ground_base(rnd, R, bias=.0)
    for x, y in spots(rnd, 5):   # cart-rut dashes: lit crest over a shade line
        n = rnd.randint(6, 12)
        for k in range(n): cv.put(x + k, y, R[0], True); cv.put(x + k, y + 1, R[2], True)
    for x, y in spots(rnd, 6): pebble(cv, x, y, RAMP["stone"], rnd, 2)
    for x, y in spots(rnd, 14): cv.put(x, y, R[3], True)
    return cv.im

def understory(land, seed):
    rnd = random.Random(f"u2{land}{seed}"); src = ground(land, "floor", seed).copy(); p = src.load()
    for y in range(T):
        for x in range(T): p[x, y] = darker(p[x, y], 1)
    return src

# ---------------------------------------------------------------- raised objects
def tone5(d): return 0 if d > .78 else 1 if d > .5 else 2 if d > .12 else 3 if d > -.25 else 4
LIGHT = (-0.5, -0.6, 0.62)
def shade_pt(nx, ny):
    nz = math.sqrt(max(0, 1 - nx * nx - ny * ny)); return nx * LIGHT[0] + ny * LIGHT[1] + nz * LIGHT[2]
def lump(cv, cx, cy, rx, ry, R, rnd, speck=.10):
    inside = []
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry
            if nx * nx + ny * ny > 1: continue
            t = tone5(shade_pt(nx, ny))
            if rnd.random() < speck: t = max(0, min(4, t + rnd.choice((-1, 1))))
            cv.put(x, y, R[t]); inside.append((x, y, nx, ny))
    ins = {(x, y) for x, y, _, _ in inside}
    for x, y, nx, ny in inside:   # dark under-rim on the lower-right edge so overlapping lumps separate
        if nx + ny > .15 and ((x + 1, y) not in ins or (x, y + 1) not in ins or (x + 1, y + 1) not in ins): cv.put(x, y, R[4])
def leaf_texture(cv, R, rnd, n):
    idx = {c: i for i, c in enumerate(R)}
    for _ in range(n):
        x, y = rnd.randrange(4, cv.w - 4), rnd.randrange(4, cv.h - 4); c = cv.get(x, y)
        if c in idx and c != INK:
            i = idx[c]; cv.put(x, y, R[max(0, i - 1)]); cv.put(x + 1, y, R[max(0, i - 1)])
            if cv.get(x, y + 1) in idx: cv.put(x, y + 1, R[min(4, i + 1)])
def trunk(cv, cx, y0, y1, w, rnd, flare=True):
    W = RAMP["wood"]
    for y in range(y0, y1):
        fl = (max(0, y - (y1 - 6)) // 2 + 1) if flare else 0
        for x in range(cx - w // 2 - fl, cx + w // 2 + fl):
            u = (x - (cx - w // 2 - fl)) / (w + 2 * fl); t = 0 if u < .12 else 1 if u < .42 else 2 if u < .74 else 3
            if (y * 3 + x * 7) % 11 == 0: t = min(4 - 1, t + 1)
            cv.put(x, y, W[t])
        if y < y1 - 1 and rnd.random() < .35: cv.put(cx - w // 2 + rnd.randint(1, w - 2), y, W[3])
    for x in range(cx - w // 2 - 4, cx + w // 2 + 4): cv.put(x, y1 - 1, W[3]) if cv.get(x, y1 - 1)[3] else None
def tree(seed, R_name="leaf"):
    rnd = random.Random(f"t2{seed}"); cv = Cv(T, OBJ_H); R = r5(RAMP[R_name])
    trunk(cv, 32, 62, 89, 11, rnd)
    if seed % 6 == 0:   # owl hole
        for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (1, 1), (-1, 1), (0, 2), (1, 2), (-1, 2), (0, 3)): cv.put(32 + dx, 76 + dy, INK)
        cv.put(31, 77, CREAM); cv.put(33, 77, CREAM); cv.put(32, 78, RAMP["gold"][1])
    L = [(32, 36, 22, 19), (16, 45, 15, 13), (48, 45, 15, 13), (22, 56, 16, 12), (42, 56, 16, 12), (32, 50, 19, 13)]
    for l in sorted(L, key=lambda a: a[1] + rnd.random()): lump(cv, *l, R, rnd)
    for x in range(22, 42):   # crown shadow over the trunk
        for y in range(62, 76):
            c = cv.get(x, y)
            if c[3] and c in RAMP["wood"]: cv.put(x, y, darker(c, 1 if y < 70 else 2))
    leaf_texture(cv, R, rnd, 90)
    if seed % 4 == 1:   # blossom/berries
        f = RAMP["petal"] if seed % 8 == 1 else RAMP["ember"]
        for _ in range(6):
            bx, by = rnd.randrange(14, 50), rnd.randrange(24, 56)
            if cv.get(bx, by)[3] and cv.get(bx, by) != INK: cv.put(bx, by, f[1]); cv.put(bx - 1, by - 1, f[0]); cv.put(bx + 1, by + 1, f[2])
    outline(cv); return cv.im
def bush(seed):
    rnd = random.Random(f"b2{seed}"); cv = Cv(T, OBJ_H); R = r5(RAMP["moss"])
    for l in ((22, 76, 15, 12), (44, 77, 15, 11), (32, 70, 18, 13), (32, 80, 22, 9)): lump(cv, *l, R, rnd, .14)
    leaf_texture(cv, R, rnd, 55)
    if seed % 2:   # ladybird
        x, y = 34 + seed % 5, 69
        for dx, dy, c in ((0, 0, RAMP["ember"][1]), (1, 0, RAMP["ember"][1]), (0, 1, RAMP["ember"][2]), (1, 1, RAMP["ember"][2]), (-1, 0, INK), (-1, 1, INK)): cv.put(x + dx, y + dy, c)
        cv.put(x, y, RAMP["ember"][0])
    else:
        f = RAMP["petal"]
        for _ in range(6):
            bx, by = rnd.randrange(14, 52), rnd.randrange(64, 84)
            if cv.get(bx, by)[3]: cv.put(bx, by, f[1]); cv.put(bx - 1, by, f[0]); cv.put(bx, by - 1, f[0]); cv.put(bx + 1, by, f[2]); cv.put(bx, by, CREAM) if rnd.random() < .3 else None
    outline(cv); return cv.im
def hedge(seed):
    rnd = random.Random(f"h2{seed}"); cv = Cv(T, OBJ_H); R = r5(RAMP["moss"])
    for y in range(56, 90):
        for x in range(2, 62):
            if y < 72: t = 0 if (y < 60 and x < 38) else 1 if y < 66 else 2
            else: t = 3 if y < 84 else 4
            if rnd.random() < .16: t = max(0, min(4, t + rnd.choice((-1, 1))))
            cv.put(x, y, R[t])
    for y in range(56, 90):   # scalloped top silhouette and rounded corners
        for x in range(2, 62):
            c = min(x - 2, 61 - x); r = max(0, 6 - c); bump = 1 if (x // 5) % 2 else 0
            if y < 56 + r + bump or y > 89 - r: cv.p[x, y] = (0, 0, 0, 0)
    for x in range(2, 62):
        if cv.get(x, 72)[3]: cv.put(x, 72, R[3])
    leaf_texture(cv, R, rnd, 70)
    if seed % 3 == 0:   # a hedgehog snout poking out
        for dx, dy, c in ((0, 0, RAMP["wood"][1]), (1, 0, RAMP["wood"][2]), (0, 1, RAMP["wood"][2]), (-1, 0, RAMP["wood"][0]), (2, 0, INK)): cv.put(46 + dx, 80 + dy, c)
        cv.put(45, 79, INK)
    outline(cv); return cv.im
def boulder(seed, moss=False, snowcap=False):
    rnd = random.Random(f"r2{seed}"); cv = Cv(T, OBJ_H); R = r5(RAMP["stone"])
    cx, cy, rx, ry = 32, 72, 27, 21; wob = [rnd.random() * 6.28 for _ in range(3)]
    for y in range(cy - ry - 2, cy + ry + 3):
        for x in range(cx - rx - 2, cx + rx + 3):
            nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry; a = math.atan2(ny, nx)
            lim = 1 + .08 * math.sin(3 * a + wob[0]) + .05 * math.sin(5 * a + wob[1])
            if nx * nx + ny * ny > lim * lim: continue
            if ny > .55 and abs(nx) < .9: ny2 = ny
            # facets: top plane, lit left face, shade right face, base band
            if ny < -.22 - .1 * nx: t = 0 if nx < .35 else 1
            elif nx < -.05 + .25 * ny: t = 2
            else: t = 3
            if ny > .70: t = 4
            if rnd.random() < .12: t = max(0, min(4, t + rnd.choice((-1, 1))))
            cv.put(x, y, R[t])
    for k in range(rnd.randint(1, 2)):   # crack
        x, y = rnd.randrange(22, 44), rnd.randrange(62, 70)
        for j in range(8): cv.put(x + (j % 3 == 0) + (j // 5), y + j, R[4])
    if moss:
        for x in range(8, 40):
            for y in range(52, 64):
                if cv.get(x, y)[3] and y < 58 + (x * 3 % 5) and cv.get(x, y) != INK: cv.put(x, y, RAMP["moss"][rnd.choice((0, 1, 1, 2))])
    if snowcap:
        for x in range(8, 56):
            for y in range(50, 66):
                if cv.get(x, y)[3] and y < 58 + int(3 * math.sin(x * .5)) - abs(x - 28) // 6 and cv.get(x, y) != INK: cv.put(x, y, RAMP["snow"][0 if x < 38 else 1])
    for _ in range(14):   # lichen specks
        x, y = rnd.randrange(8, 56), rnd.randrange(56, 88)
        if cv.get(x, y)[3] and cv.get(x, y) in R[:3]: cv.put(x, y, RAMP["gold"][1 if rnd.random() < .5 else 0])
    if seed % 4 == 0:   # snail on top
        for dx, dy, c in ((0, 0, RAMP["wood"][1]), (1, 0, RAMP["wood"][0]), (-1, 1, RAMP["wood"][2]), (0, 1, RAMP["wood"][1]), (1, 1, RAMP["wood"][2]), (-2, 2, RAMP["sand"][1]), (-1, 2, RAMP["sand"][1]), (0, 2, RAMP["sand"][2]), (1, 2, RAMP["sand"][2]), (-3, 2, RAMP["sand"][0]), (-3, 1, INK)): cv.put(30 + dx, 55 + dy, c)
    outline(cv); return cv.im
def pine(seed, snowy=True):
    rnd = random.Random(f"p2{seed}"); cv = Cv(T, OBJ_H); R = r5(RAMP["pine"]); S = RAMP["snow"]
    trunk(cv, 32, 80, 90, 8, rnd)
    tiers = ((4, 28, 12), (18, 42, 17), (32, 56, 22), (46, 70, 26), (58, 84, 29))
    for i, (y0, y1, hw) in enumerate(tiers):
        hw += rnd.randint(-1, 1)
        for y in range(y0, y1):
            half = hw * ((y - y0) / (y1 - y0 - 1)) ** .95 + 1
            for x in range(int(32 - half), int(32 + half) + 1):
                u = (x - (32 - half)) / (2 * half + .001)
                t = 0 if u < .15 else 1 if u < .38 else 2 if u < .62 else 3 if u < .86 else 4
                if rnd.random() < .12: t = max(0, min(4, t + rnd.choice((-1, 1))))
                cv.put(x, y, R[t])
                if snowy and (y - y0) < (y1 - y0) * .38 - abs(x - 32) * .06 + math.sin(x * .9 + i) * 1.4:
                    cv.put(x, y, S[0] if u < .4 else S[1] if u < .72 else S[2])
        for x in range(int(32 - hw), int(32 + hw) + 1):   # scalloped drooping hem
            e = y1 - 1 - (1 if (x * 3 + i) % 6 < 2 else 0)
            if cv.get(x, e)[3]: cv.put(x, e, R[4])
    if seed % 5 == 0:   # a gold bauble on the tip
        for dx, dy, c in ((0, 0, RAMP["gold"][1]), (-1, 0, RAMP["gold"][0]), (1, 0, RAMP["gold"][2]), (0, 1, RAMP["gold"][2]), (0, -1, RAMP["gold"][0])): cv.put(32 + dx, 3 + dy, c)
    outline(cv); return cv.im
def water(land, seed):
    rnd = random.Random(f"w2{land}{seed}"); R = RAMP["sea"] if land != "tundra" else RAMP["ice"]
    cv = ground_base(rnd, R, bias=.05)
    for x, y in spots(rnd, 16):
        n = rnd.choice((3, 4, 5, 6))
        for k in range(n): cv.put(x + k, y, R[0], True)
        for k in range(1, n): cv.put(x + k, y + 1, R[2], True)
    for x, y in spots(rnd, 6): cv.put(x, y, CREAM, True)
    if land == "tundra":
        for _ in range(2):
            x, y = rnd.randrange(6, 56), rnd.randrange(6, 56)
            for k in range(9): cv.put(x + k, y + (k * 2 // 3) % 4, R[3], True)
    return cv.im

# ---------------------------------------------------------------- landmarks: one named feature of a route, drawn LARGE (a few tiles wide and tall) so the
# walker reads as a small gnome beside it. Each has its own canvas; the sprite is cropped top and bottom, its bottom edge is the feet line, and it is centred
# on its tile (trail_art.php reads the size from the PNG). Hard pixels, the same ramps and lumps as the trees.
def _col(cv, x0, x1, y0, y1, R, rnd, speck=.08):
    """Rectangle shaded left (lit) to right (shade), with a little speckle."""
    for x in range(x0, x1):
        u = (x - x0) / max(1, x1 - x0 - 1); t = 0 if u < .15 else 1 if u < .4 else 2 if u < .72 else 3
        for y in range(y0, y1):
            tt = t
            if rnd.random() < speck: tt = max(0, min(4, tt + rnd.choice((-1, 1))))
            cv.put(x, y, R[tt])
def _pond(cv, cx, cy, rx, ry, rnd, R=None):
    R = R or r5(RAMP["sea"])
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            if (x - cx) ** 2 / rx ** 2 + (y - cy) ** 2 / ry ** 2 <= 1:
                t = 3 if y > cy + ry // 2 else 2 if y > cy else 1 if y > cy - ry // 2 else 0
                if (x * 5 + y * 3) % 9 == 0: t = max(0, t - 1)
                cv.put(x, y, R[t])
    for _ in range(rx // 6):   # glints
        x, y = rnd.randint(cx - rx + 10, cx + rx - 18), rnd.randint(cy - ry + 4, cy + ry - 4)
        if (x - cx) ** 2 / rx ** 2 + (y - cy) ** 2 / ry ** 2 > .8: continue
        for k in range(rnd.randint(5, 9)): cv.put(x + k, y, R[0]); cv.put(x + k + 1, y + 1, R[2]) if k > 1 else None
def _reeds(cv, x, y, n, rnd):
    for i in range(n):
        xx, h = x + i * 4 + rnd.randint(-1, 1), rnd.randint(20, 40)
        for k in range(h): cv.put(xx + (k * 3 // h) % 2, y - k, RAMP["moss"][1 if k % 5 else 0])
        if i % 2 == 0:
            for k in range(8): cv.put(xx, y - h - k, RAMP["wood"][2]); cv.put(xx + 1, y - h - k, RAMP["wood"][3])
def lm_scarecrow(rnd, cv):   # 160 x 250
    W = RAMP["wood"]
    for y in range(70, 246):
        for k, c in enumerate((W[0], W[1], W[1], W[2], W[2], W[3])): cv.put(77 + k, y, c)
    for x in range(22, 140):   # crossbar
        for k, c in enumerate((W[0], W[1], W[1], W[2], W[3])): cv.put(x, 112 + k, c)
    for x0, d in ((12, 1), (138, -1)):   # straw hands
        for k in range(18): cv.put(x0 + k * d, 110 + (k * 7) % 5, RAMP["sand"][k % 3]); cv.put(x0 + k * d, 117 - (k * 5) % 6, RAMP["sand"][1 + k % 2]); cv.put(x0 + k * d + d, 113 + k % 4, RAMP["sand"][0])
    lump(cv, 80, 146, 30, 36, r5(RAMP["sea"]), rnd, .07)   # shirt
    for px_, py_ in ((64, 132), (92, 160), (70, 168)):   # patches, stitched
        for dx in range(10):
            for dy in range(10): cv.put(px_ + dx, py_ + dy, RAMP["ember"][1 if dx + dy < 12 else 2])
        for dx in range(0, 10, 2): cv.put(px_ + dx, py_, CREAM); cv.put(px_ + dx, py_ + 9, CREAM)
    for k in range(4): cv.put(80, 120 + k * 8, RAMP["gold"][1]); cv.put(81, 121 + k * 8, RAMP["gold"][2])   # buttons
    for x in range(52, 109):   # ragged straw hem
        for y in range(176, 176 + 5 + (x * 7) % 9): cv.put(x, y, RAMP["sand"][1 + (x + y) % 2])
    lump(cv, 80, 92, 24, 24, r5(RAMP["sand"]), rnd, .1)   # sack head
    for ex in (70, 90):
        for dx in range(4):
            for dy in range(5): cv.put(ex + dx, 88 + dy, INK)
        cv.put(ex, 88, CREAM)
    for x in range(70, 92): cv.put(x, 106 + (3 if 76 < x < 86 else 1 if x % 2 else 0), RAMP["ember"][2])   # stitched smile
    for x in range(70, 92, 3): cv.put(x, 104, RAMP["wood"][2])
    for x in range(46, 115):   # hat brim
        for y in range(68, 75): cv.put(x, y, W[0] if y == 68 else W[1] if y < 71 else W[2] if y < 74 else W[3])
    lump(cv, 80, 56, 24, 20, r5(RAMP["wood"]), rnd, .07)   # crown
    for x in range(58, 103): cv.put(x, 66, RAMP["petal"][1]); cv.put(x, 65, RAMP["petal"][0]); cv.put(x, 67, RAMP["petal"][2])   # ribbon
    for k in range(8): cv.put(100 + k, 62 - k, RAMP["gold"][min(2, k // 3)]); cv.put(101 + k, 62 - k, RAMP["gold"][1])   # feather
    for x in range(48, 112): cv.put(x, 250 - 6, RAMP["moss"][2]) if x % 3 == 0 else None
def lm_haybales(rnd, cv):   # 210 x 150
    for cx, cy, rx, ry in ((58, 108, 46, 32), (152, 108, 46, 32), (105, 62, 46, 34)):
        lump(cv, cx, cy, rx, ry, r5(RAMP["gold"]), rnd, .16)
        for k in range(-30, 40, 16):   # twine, three bands per bale
            for y in range(cy - ry + 2, cy + ry - 1):
                if cv.get(cx + k, y)[3] and cv.get(cx + k, y) != INK:
                    for w in (0, 1): cv.put(cx + k + w, y, RAMP["wood"][2] if y % 2 else RAMP["wood"][1])
        for _ in range(60):   # straw
            x, y = rnd.randint(cx - rx + 3, cx + rx - 3), rnd.randint(cy - ry + 3, cy + ry - 3)
            if cv.get(x, y)[3] and cv.get(x, y) != INK:
                for k in range(rnd.randint(3, 6)): cv.put(x + k, y, RAMP["gold"][0]); cv.put(x + k, y + 1, RAMP["gold"][3]) if k > 1 else None
    for k in range(18):   # loose straw on the ground
        x = rnd.randint(8, 200); y = 142 + rnd.randint(0, 3)
        for j in range(rnd.randint(4, 8)): cv.put(x + j, y, RAMP["gold"][1 + j % 2])
def lm_ford(rnd, cv):   # 270 x 110
    _pond(cv, 135, 66, 128, 38, rnd)
    for cx, cy, rx, ry in ((50, 66, 22, 12), (135, 84, 25, 13), (216, 62, 22, 12), (92, 74, 11, 6), (176, 72, 11, 6)):
        lump(cv, cx, cy, rx, ry, r5(RAMP["stone"]), rnd, .1)
        for k in range(-rx, rx + 1):   # foam ring
            if cv.get(cx + k, cy + ry + 1)[3] == 0 or cv.get(cx + k, cy + ry + 1) in r5(RAMP["sea"]): cv.put(cx + k, cy + ry + 1, CREAM)
    _reeds(cv, 10, 78, 5, rnd); _reeds(cv, 236, 74, 5, rnd)
def lm_pondmill(rnd, cv):   # 290 x 250
    _pond(cv, 92, 214, 84, 30, rnd)
    W, C = r5(RAMP["wood"]), r5(RAMP["sand"])
    _col(cv, 158, 262, 114, 238, C, rnd)   # walls
    for y in (150, 190): 
        for x in range(158, 262): cv.put(x, y, W[2]); cv.put(x, y + 1, W[3])   # timber bands
    for x in (160, 208, 258):
        for y in range(114, 238): cv.put(x, y, W[2]); cv.put(x + 1, y, W[3])
    for y in range(52, 118):   # roof
        hw = (y - 52) * 62 // 66 + 6
        for x in range(210 - hw, 210 + hw + 1):
            row = (y // 7) % 2; col = RAMP["ember"][0 if x < 186 else 1 if x < 220 else 2]
            if (x + row * 6) % 12 == 0 or y % 7 == 0: col = RAMP["ember"][3]
            cv.put(x, y, col)
    for y in range(196, 238):   # door
        for x in range(190, 226): cv.put(x, y, W[1] if x < 204 else W[2]); 
    for y in range(196, 238, 8):
        for x in range(190, 226): cv.put(x, y, W[3])
    cv.put(216, 220, RAMP["gold"][1]); cv.put(217, 220, RAMP["gold"][0])
    for wx in (176, 236):   # windows
        for y in range(132, 150):
            for x in range(wx, wx + 14): cv.put(x, y, RAMP["sea"][0] if y < 138 else RAMP["sea"][2])
        for x in range(wx, wx + 14): cv.put(x, 131, W[3]); cv.put(x, 150, W[3])
        for y in range(131, 151): cv.put(wx + 7, y, W[3])
    for a in range(0, 360, 30):   # waterwheel: spokes, rim, paddles
        for r in range(4, 40): cv.put(142 + int(round(math.cos(math.radians(a)) * r)), 206 + int(round(math.sin(math.radians(a)) * r)), W[1] if a % 90 == 0 else W[2])
    for a in range(0, 360, 3):
        for r in (38, 39, 40): cv.put(142 + int(round(math.cos(math.radians(a)) * r)), 206 + int(round(math.sin(math.radians(a)) * r)), W[3])
    for a in range(0, 360, 30):
        x, y = 142 + int(round(math.cos(math.radians(a)) * 44)), 206 + int(round(math.sin(math.radians(a)) * 44))
        for dx in range(-4, 5):
            for dy in range(-3, 4): cv.put(x + dx, y + dy, W[1] if dx < 0 else W[2])
    for dx in range(-5, 6):
        for dy in range(-5, 6):
            if dx * dx + dy * dy <= 25: cv.put(142 + dx, 206 + dy, RAMP["gold"][1] if dx + dy < 0 else RAMP["gold"][2])
    for k in range(5): cv.put(120 + k * 8, 236, RAMP["sea"][0]); cv.put(121 + k * 8, 237, CREAM)   # splash
def lm_apple(rnd, cv):   # 230 x 280
    trunk(cv, 115, 190, 270, 38, rnd)
    R = r5(RAMP["leaf"])
    L = [(115, 100, 82, 66), (52, 138, 54, 46), (178, 138, 54, 46), (80, 176, 56, 40), (150, 176, 56, 40), (115, 152, 68, 44)]
    for l in sorted(L, key=lambda a: a[1] + rnd.random()): lump(cv, *l, R, rnd)
    for x in range(78, 152):   # crown shadow over the trunk
        for y in range(190, 230):
            c = cv.get(x, y)
            if c[3] and c in RAMP["wood"]: cv.put(x, y, darker(c, 1 if y < 214 else 2))
    leaf_texture(cv, R, rnd, 700)
    n = 0
    for _ in range(400):   # big red apples
        if n >= 26: break
        x, y = rnd.randrange(30, 195), rnd.randrange(46, 190)
        if all(cv.get(x + dx, y + dy)[3] and cv.get(x + dx, y + dy) != INK and cv.get(x + dx, y + dy) not in RAMP["wood"] and cv.get(x + dx, y + dy) not in RAMP["ember"] for dx in range(-1, 9) for dy in range(-3, 8)):
            n += 1
            for dx in range(7):
                for dy in range(7):
                    if (dx - 3) ** 2 + (dy - 3) ** 2 <= 11: cv.put(x + dx, y + dy, RAMP["ember"][0 if dx + dy < 4 else 1 if dx + dy < 8 else 2])
            cv.put(x + 3, y - 1, RAMP["wood"][2]); cv.put(x + 4, y - 2, RAMP["moss"][1]); cv.put(x + 5, y - 2, RAMP["moss"][0])
    for a in range(0, 360, 12):   # ring of clover round the foot
        x, y = 115 + int(round(math.cos(math.radians(a)) * 92)), 268 + int(round(math.sin(math.radians(a)) * 9))
        for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1), (2, 0), (-2, 0)): cv.put(x + dx, y + dy, RAMP["moss"][2] if (dx or dy) else RAMP["moss"][1])
        if a % 36 == 0: cv.put(x, y - 1, CREAM); cv.put(x + 1, y - 1, CREAM)
    for k in range(7):   # fallen apples
        x = 70 + k * 13 + rnd.randint(-2, 2)
        for dx in range(5):
            for dy in range(4): cv.put(x + dx, 270 + dy, RAMP["ember"][1 if dx + dy < 5 else 2])
def lm_hedgerow(rnd, cv):   # 290 x 190
    R = r5(RAMP["moss"])
    for y in range(76, 172):
        for x in range(6, 284):
            t = (0 if (y < 90 and x % 90 < 52) else 1) if y < 112 else 2 if y < 134 else 3 if y < 160 else 4
            if rnd.random() < .16: t = max(0, min(4, t + rnd.choice((-1, 1))))
            cv.put(x, y, R[t])
    for y in range(76, 172):   # scalloped top, rounded ends
        for x in range(6, 284):
            c = min(x - 6, 283 - x); r = max(0, 14 - c); bump = 3 if (x // 11) % 2 else 0
            if y < 76 + r + bump or y > 171 - r: cv.p[x, y] = (0, 0, 0, 0)
    for x in range(6, 284):
        if cv.get(x, 134)[3]: cv.put(x, 134, R[3])
    leaf_texture(cv, R, rnd, 420)
    for cx, cy, rx, ry, face in ((78, 54, 30, 34, True), (214, 62, 22, 26, False)):   # trimmed topiary, with strong opinions
        for y in range(cy + ry - 4, 100):
            for k in range(6): cv.put(cx - 3 + k, y, RAMP["wood"][1 + k // 2] if k < 5 else RAMP["wood"][3])
        lump(cv, cx, cy, rx, ry, R, rnd, .1); leaf_texture(cv, R, rnd, 60)
        if face:
            for ex in (cx - 11, cx + 6):
                for dx in range(6):
                    for dy in range(7): cv.put(ex + dx, cy - 6 + dy, CREAM if dx < 4 and dy < 6 else INK)
                for dx in range(3):
                    for dy in range(4): cv.put(ex + 1 + dx, cy - 4 + dy, INK)
            for x in range(cx - 10, cx + 12): cv.put(x, cy + 12 + (4 if cx - 5 < x < cx + 5 else 2 if x % 2 else 0), RAMP["ember"][2])
            for k in range(6): cv.put(cx - 22 + k, cy - 22 - k, W_ if False else RAMP["wood"][2])   # a stray twig
    for k in range(6):   # flowers on the hedge
        x, y = 30 + k * 44 + rnd.randint(-6, 6), 118 + rnd.randint(0, 24)
        for dx, dy, c in ((0, 0, CREAM), (-3, 0, RAMP["petal"][1]), (3, 0, RAMP["petal"][1]), (0, -3, RAMP["petal"][0]), (0, 3, RAMP["petal"][2])): cv.put(x + dx, y + dy, c)
        cv.put(x, y, RAMP["gold"][1])
LANDMARKS = {"scarecrow": (160, 250, lm_scarecrow), "haybales": (210, 150, lm_haybales), "ford": (270, 110, lm_ford), "pondmill": (290, 250, lm_pondmill),
             "apple": (230, 280, lm_apple), "hedgerow": (290, 190, lm_hedgerow)}
def landmark(name):
    w, h, fn = LANDMARKS[name]; cv = Cv(w, h); fn(random.Random(f"lm{name}"), cv); outline(cv)
    top, bot = cv.im.getbbox()[1], cv.im.getbbox()[3]; return cv.im.crop((0, top, w, bot))
def _load_landmark_modules():
    """claude/tile-art-v3-proposal/landmarks_*.py each define LM = {name: (canvas w, canvas h, fn(rnd, cv))}; names are '<route id>-<slug>'."""
    import glob, importlib.util
    for f in sorted(glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)), "landmarks_*.py"))):
        spec = importlib.util.spec_from_file_location(os.path.basename(f)[:-3], f); m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
        for k in m.LM:
            assert k not in LANDMARKS, f"landmark {k} is defined twice ({f})"
        LANDMARKS.update(m.LM)
if __name__ == "gen2": _load_landmark_modules()

# ---------------------------------------------------------------- find spots (open / done) and the search icon
def sparkle(cv, x, y, big=True):
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)): cv.put(x + dx, y + dy, CREAM)
    if big:
        for dx, dy in ((2, 0), (-2, 0), (0, 2), (0, -2)): cv.put(x + dx, y + dy, CREAM)
    cv.put(x, y, H("#ffffff") if False else RAMP["gold"][0])
def dome(cv, cx, cy, rx, ry, R, rnd, speck=0):
    lump(cv, cx, cy, rx, ry, r5(R), rnd, speck)
def find_spot(land, done=False):
    rnd = random.Random(f"f2{land}"); cv = Cv(T, T)
    if land == "grassland":
        G = RAMP["leaf"]
        if not done:
            clump(cv, 32, 52, 22, 12, 20, G, rnd, 13)
            dome(cv, 32, 44, 9, 8, RAMP["gold"], rnd)                       # a gold acorn hiding in the grass
            for dx in range(-7, 8):
                for dy in range(-5, 1):
                    if dx * dx / 49 + (dy + 1) * (dy + 1) / 20 <= 1: cv.put(32 + dx, 37 + dy, RAMP["wood"][1 if dx < 2 else 2])
            for k in range(4): cv.put(32, 32 - k, RAMP["wood"][2 if k % 2 else 3])
            clump(cv, 32, 55, 14, 9, 15, G, rnd, 15)
            sparkle(cv, 47, 30)
        else:
            for dx in range(-14, 15):
                for dy in range(-5, 6):
                    if dx * dx / 196 + dy * dy / 25 <= 1: cv.put(32 + dx, 50 + dy, RAMP["litter"][2 if dy < 1 else 3])
            for dx in range(-7, 8):
                for dy in range(-3, 3):
                    if dx * dx / 49 + dy * dy / 9 <= 1: cv.put(32 + dx, 48 + dy, RAMP["litter"][3])
            for x, y in ((14, 52), (22, 55), (34, 56), (42, 54), (18, 47), (44, 46), (26, 58)):   # trampled blades lying flat
                for k in range(9): cv.put(x + k, y + (k // 4), G[2 if k < 4 else 1])
    elif land == "forest":
        W = RAMP["wood"]
        for y in range(38, 58):   # a stump: lit left, shade right, bark grain, rings on top
            for x in range(14, 50):
                u = (x - 14) / 36; cv.put(x, y, W[1 if u < .3 else 2 if u < .72 else 3])
                if (x * 5 + y * 3) % 13 == 0: cv.put(x, y, W[3 if u > .3 else 2])
        for dy in range(-8, 9):
            for dx in range(-18, 19):
                if dx * dx / 324 + dy * dy / 64 <= 1:
                    d = math.sqrt(dx * dx / 324 + dy * dy / 64); cv.put(32 + dx, 38 + dy, W[0] if int(d * 6) % 2 == 0 else W[1])
        for x in range(17, 47):   # moss on the rim
            if x % 3: cv.put(x, 30 + (x % 2), RAMP["moss"][1]); cv.put(x, 31 + (x % 3 == 0), RAMP["moss"][2])
        if not done:
            for dx, dy, c in ((-2, 0, RAMP["ember"][1]), (-1, -1, RAMP["ember"][0]), (0, -1, RAMP["ember"][0]), (1, -1, RAMP["ember"][1]), (2, 0, RAMP["ember"][2]), (-1, 0, RAMP["ember"][1]), (0, 0, RAMP["ember"][1]), (1, 0, RAMP["ember"][2]), (0, -1, CREAM)): cv.put(41 + dx, 31 + dy, c)
            for k in range(3): cv.put(41, 32 + k, CREAM)
        for dx in range(-5, 6):   # a tiny round door in the stump face, gold knob
            for dy in range(-7, 8):
                if dx * dx / 25 + dy * dy / 49 <= 1: cv.put(30 + dx, 49 + dy, INK if done else W[3])
        if not done:
            for dx in range(-4, 5):
                for dy in range(-6, 7):
                    if dx * dx / 16 + dy * dy / 36 <= 1: cv.put(30 + dx, 49 + dy, W[2 if dx < 1 else 3])
            cv.put(32, 50, RAMP["gold"][1]); cv.put(31, 49, RAMP["gold"][0]); sparkle(cv, 52, 28)
        else:
            for k in range(8): cv.put(34 + k // 3, 44 + k, W[1 if k < 4 else 2])   # door ajar, nothing inside
    elif land == "coast":
        S = RAMP["sand"]
        if not done:
            dome(cv, 30, 44, 17, 12, RAMP["petal"], rnd)       # a spiral shell, half buried
            for k in range(34):
                a = k * .5; r = 1 + k * .42; cv.put(30 + int(r * math.cos(a) * .95), 44 + int(r * math.sin(a) * .7), RAMP["petal"][3 if k % 2 else 2])
            for dx in range(-22, 23):
                for dy in range(0, 9):
                    if dx * dx / 484 + dy * dy / 25 <= 1: cv.put(30 + dx, 52 + dy, S[1 if dy < 4 else 2])
            for dx, dy in ((-22, 50), (-21, 50), (20, 51)): cv.put(30 + dx, dy, S[0])
            dome(cv, 47, 42, 5, 5, [CREAM, CREAM, mix(CREAM, RAMP["sea"][1], .4), RAMP["sea"][2]], rnd)   # pearl
            sparkle(cv, 52, 30)
        else:
            for dx in range(-20, 21):
                for dy in range(-6, 7):
                    if dx * dx / 400 + dy * dy / 36 <= 1: cv.put(32 + dx, 50 + dy, S[2 if dy > -2 else 3])
            for dx in range(-13, 14):
                for dy in range(-4, 1):
                    if dx * dx / 169 + dy * dy / 16 <= 1: cv.put(32 + dx, 44 + dy, S[0 if dx < 0 else 1])
    else:
        Sn = RAMP["snow"]
        if not done:
            dome(cv, 32, 48, 24, 14, Sn, rnd)                   # a snow mound with a red mitten poking out
            for dx in range(-5, 7):
                for dy in range(-9, 3):
                    if (dx - 1) ** 2 / 36 + (dy + 3) ** 2 / 36 <= 1: cv.put(38 + dx, 32 + dy, RAMP["ember"][0 if dx < -2 else 1 if dy < 0 or dx < 3 else 2])
            for dx in range(-4, 4):
                for dy in range(3, 8):
                    cv.put(38 + dx, 32 + dy, RAMP["ember"][2 if dx > 0 else 1])
            for dx in range(-5, 5): cv.put(38 + dx, 41, RAMP["gold"][1 if dx % 2 else 0])   # woolly cuff
            for dx in range(-3, 4): cv.put(38 + dx, 40, CREAM)
            sparkle(cv, 17, 30)
        else:
            for dx in range(-23, 24):
                for dy in range(-6, 7):
                    if dx * dx / 529 + dy * dy / 36 <= 1: cv.put(32 + dx, 50 + dy, Sn[1 if dy < 0 else 2])
            for dx in range(-10, 11):
                for dy in range(-4, 5):
                    if dx * dx / 100 + dy * dy / 16 <= 1: cv.put(32 + dx, 50 + dy, Sn[3] if dy > -1 else Sn[2])
    outline(cv); return cv.im
def icon_search():
    rnd = random.Random("icon"); cv = Cv(64, 64); G = r5(RAMP["gold"]); W = RAMP["wood"]
    for k in range(18):   # slim handle, lower-right, with grain
        x, y = 36 + k, 36 + k
        for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)): cv.put(x + dx, y + dy, W[1 if (dx, dy) in ((0, 0), (1, 0)) else 2])
        cv.put(x, y, W[0] if k % 5 else W[1])
    for k in range(4):  # ferrule
        x, y = 33 + k, 33 + k
        for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)): cv.put(x + dx, y + dy, RAMP["stone"][1 if k % 2 else 0])
    cx, cy, r = 26, 26, 17
    for y in range(cy - r - 2, cy + r + 3):
        for x in range(cx - r - 2, cx + r + 3):
            d = math.hypot(x + .5 - cx, y + .5 - cy)
            if d > r + 2: continue
            nx = (x + .5 - cx) / (r + 2); ny = (y + .5 - cy) / (r + 2)
            if d > r - 2: cv.put(x, y, G[tone5(shade_pt(nx, ny) * 1.15)])   # the rim: lit gold ring
            else:
                t = RAMP["sea"]; cv.put(x, y, mix(t[0], CREAM, .5) if (x + y) % 9 else t[0])  # pale glass core
    for k in range(7): cv.put(cx - 9 + k, cy - 8 + k // 3 - 0, CREAM) if k < 6 else None   # specular streak
    for dx, dy in ((-8, -5), (-7, -5), (-6, -4), (-9, -4), (-8, -4)): cv.put(cx + dx, cy + dy, H("#ffffff") if False else CREAM)
    for dx, dy in ((2, 1), (3, 0), (4, -1)): cv.put(cx + dx, cy + dy, RAMP["sea"][1])   # a little leaf seen through the glass
    for dx, dy in ((2, 2), (3, 1), (4, 0), (1, 1), (5, -1)): cv.put(cx + dx, cy + dy + 1, RAMP["moss"][1])
    cv.put(cx + 3, cy + 1, RAMP["moss"][0]); cv.put(cx + 4, cy, RAMP["moss"][0])
    outline(cv); return cv.im

# ---------------------------------------------------------------- sprites + compose
def sprite(name, frame=0):
    return Image.open(os.path.join(ROOT, "aseprite-source/v3/models", name)).convert("RGBA").crop((frame * 64, 0, frame * 64 + 64, 80))
def crc(*a): return zlib.crc32("|".join(map(str, a)).encode())
def wall_obj(land, x, y, seed):
    h = crc(land, x, y, seed) % 100
    if land == "grassland": return hedge(h % 3) if (x + y) % 3 == 0 else (tree(h % 8) if h % 5 else bush(h % 4))
    if land == "forest": return tree(h % 8, "pine" if h % 3 == 0 else "leaf") if h % 6 else boulder(h % 4, True)
    if land == "coast": return boulder(h % 5)
    return pine(h % 6) if h % 5 else boulder(h % 4, False, True)
def ell(bp, cx, cy, rx, ry, n=1, W=None, Hh=None):
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            if 0 <= x < W and 0 <= y < Hh and (x - cx) ** 2 / rx ** 2 + (y - cy) ** 2 / ry ** 2 <= 1: bp[x, y] = darker(bp[x, y], n)

def lighter(c):
    if c in STEP: k, i = STEP[c]; return RAMP[k][max(0, i - 1)]
    return mix(c, CREAM, .22)
def wnoise(rnd, w, h, cell):
    gw, gh = w // cell + 3, h // cell + 3; g = [[rnd.random() for _ in range(gw)] for _ in range(gh)]
    def f(x, y):
        fx, fy = x / cell, y / cell; x0, y0 = int(fx), int(fy); tx, ty = fx - x0, fy - y0
        tx = tx * tx * (3 - 2 * tx); ty = ty * ty * (3 - 2 * ty)
        a, b, c, d = g[y0][x0], g[y0][x0 + 1], g[y0 + 1][x0], g[y0 + 1][x0 + 1]
        return (a + (b - a) * tx) * (1 - ty) + (c + (d - c) * tx) * ty
    return f
def terrain_layer(land, types, seed=0, blend=True):
    """One continuous ground picture from a grid of tile types (f floor, r rough, u under walls, w water/ice).
    Tile boundaries are pushed around by world-space noise, so rough grass spills into the floor and the dark under-wall ground
    creeps out from the trees; hard pixels only. Rough edges get a lit rim (up-left) and a shade rim (down-right)."""
    Hh = len(types); W = len(types[0]); tw, th = W * T, Hh * T
    rnd = random.Random(f"tl{land}{seed}")
    n1, n2, n3, n4 = wnoise(rnd, tw, th, 14), wnoise(rnd, tw, th, 14), wnoise(rnd, tw, th, 5), wnoise(rnd, tw, th, 5)
    tex = {}; nv = wnoise(rnd, tw, th, 40)
    def texof(t, tx, ty, x=0, y=0):
        v = int(nv(x, y) * 4.4) % 4   # which texture variant: big organic patches, so variants never meet on a tile line
        k = (t, v if t != "r" else v % 2, (tx * 3 + ty) % 3 if t == "w" else 0)
        if k not in tex:
            im = understory(land, v) if t == "u" else ground(land, "rough", v % 2) if t == "r" else water(land, k[2]) if t == "w" else pathtex(land, v % 2) if t == "p" else ground(land, "floor", v)
            tex[k] = im.load()
        return tex[k]
    def tp(x, y):
        x = min(max(x, 0), tw - 1); y = min(max(y, 0), th - 1); return types[y // T][x // T], x // T, y // T
    img = Image.new("RGBA", (tw, th)); P = img.load(); TM = [[None] * tw for _ in range(th)]
    for y in range(th):
        for x in range(tw):
            if blend:
                dx = (n1(x, y) - .5) * 15 + (n3(x, y) - .5) * 6; dy = (n2(x, y) - .5) * 15 + (n4(x, y) - .5) * 6
            else: dx = dy = 0
            tn = tp(x, y)
            ts = tp(int(x + dx * .35), int(y + dy * .35))
            td = ts if ("w" in (tn[0], ts[0])) else tp(int(x + dx), int(y + dy))
            t, tx, ty = td; TM[y][x] = t; P[x, y] = texof(t, tx, ty, x, y)[x % T, y % T]
    if not blend: return img
    for y in range(th):   # rims on rough, foam/ice rim on water, wet floor beside the sea
        for x in range(tw):
            t = TM[y][x]
            def at(a, b): return TM[min(max(b, 0), th - 1)][min(max(a, 0), tw - 1)]
            if t == "r":
                if at(x, y + 1) in "fupw" or at(x + 1, y) in "fupw": P[x, y] = darker(P[x, y], 1)
                elif at(x, y - 1) in "fup" or at(x - 1, y) in "fup": P[x, y] = lighter(P[x, y])
            elif t == "p":   # a worn path sits a little lower than the grass: shade on its lit side, grass lip on the far side
                if at(x, y - 1) not in "pu" or at(x - 1, y) not in "pu": P[x, y] = darker(P[x, y], 1)
                elif at(x, y + 1) not in "pu" or at(x + 1, y) not in "pu": P[x, y] = lighter(P[x, y])
            elif t == "w":
                if land == "coast":
                    if at(x, y + 1) != "w": P[x, y] = CREAM
                    elif at(x, y + 2) != "w" or at(x, y + 3) != "w" and (x // 2) % 2: P[x, y] = RAMP["sea"][0]
                    elif at(x - 1, y) != "w" or at(x + 1, y) != "w": P[x, y] = CREAM
                else:
                    if at(x, y - 1) != "w" or at(x - 1, y) != "w": P[x, y] = RAMP["ice"][0]
                    elif at(x, y + 1) != "w" or at(x + 1, y) != "w": P[x, y] = RAMP["ice"][3]
            elif land == "coast" and t in "f" and any(at(x, y - k) == "w" for k in range(1, 5)):
                P[x, y] = darker(P[x, y], 1)
            elif land == "tundra" and t == "f" and any(at(x + a, y + b) == "w" for a, b in ((0, 2), (2, 0), (0, -2), (-2, 0))):
                P[x, y] = lighter(P[x, y]) if at(x, y + 2) == "w" or at(x + 2, y) == "w" else darker(P[x, y], 1)
    return img

def compose(land, rows, seed, player=None, finds=(), done_finds=(), blend=True):
    Hh = len(rows); W = len(rows[0]); pad = 40; tw = W * T; th = Hh * T + pad
    flat = set()
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c != "#": continue
            if land == "coast" and y == 0: flat.add((x, y))
            if land == "tundra" and 1 <= x <= 9 and 1 <= y <= 5 and ((rows[y][x-1] == "#" and x - 1 > 0) or (rows[y][x+1] == "#" and x + 1 < W - 1)): flat.add((x, y))
    types = ["".join("w" if (x, y) in flat else "u" if c == "#" else "r" if c == "," else "f" for x, c in enumerate(row)) for y, row in enumerate(rows)]
    ter = terrain_layer(land, [types[0].replace("w", "u")] + types, seed, blend)   # one extra row above for the top margin
    base = Image.new("RGBA", (tw, th), (0, 0, 0, 0)); base.paste(ter.crop((0, T - pad, tw, T - pad + th)), (0, 0))
    bp = base.load()
    items = []
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c == "#" and (x, y) not in flat:
                jit = ((crc("j", x, y, seed) % 7) - 3) if land != "coast" else 0
                ox = x * T + jit; oy = pad + y * T + T - 93
                items.append((y + .5, x, wall_obj(land, x, y, seed), ox, oy, (ox + 32, pad + y * T + T - 4)))
    for (fx, fy) in finds:
        sp = find_spot(land, (fx, fy) in done_finds)
        items.append((fy + .45, fx, sp, fx * T, pad + fy * T, None))
    if player:
        px, py, spr = player; items.append((py + .5, px, spr, px * T, pad + py * T + 46 - 70, (px * T + 32, pad + py * T + 46)))
    # ground shadows first (hard pixels, one tone darker), then everything depth sorted
    for it in items:
        if it[5]:
            cx, cy = it[5]; ell(bp, cx + 3, cy, 24 if it[2].height > 80 else 14, 6 if it[2].height > 80 else 4, 1, tw, th)
            if it[2].height > 80: ell(bp, cx + 12, cy + 1, 14, 4, 1, tw, th)
    for _, _, im, ox, oy, _ in sorted(items, key=lambda a: (a[0], a[1])):
        cl = im.crop((max(0, -ox), max(0, -oy), min(im.width, tw - ox), min(im.height, th - oy)))
        base.alpha_composite(cl, (max(ox, 0), max(oy, 0)))
    return base, pad

def main():
    os.makedirs(OUT, exist_ok=True)
    by = {r["route_id"]: r for r in json.load(open(os.path.join(OUT, "../../maplewold-trail-maps/maplewold_trail_maps.json")))}
    scenes = [("grassland", 228, 0), ("forest", 304, 0), ("coast", 307, 0), ("tundra", 309, 0), ("tundra", 315, 4)]
    meta = {}
    for land, rid, si in scenes:
        rows = by[rid]["sections"][si]["rows"]
        plain = ["".join("." if c in "S9EF" else c for c in r) for r in rows]
        fl = [(x, y) for y, r in enumerate(rows) for x, c in enumerate(r) if c == "F"]
        spots_ = [(x, y) for y in range(1, 6) for x in range(2, 9) if rows[y][x] in ".," and rows[y + 1][x] == "#" and (x, y) not in fl]
        px, py = spots_[len(spots_) // 2]
        img, pad = compose(land, plain, rid, (px, py, sprite("gnome-player.png", 0)), fl, ())
        hard, _ = compose(land, plain, rid, (px, py, sprite("gnome-player.png", 0)), fl, (), False); hard.save(os.path.join(OUT, f"hard-{land}-{rid}.png"))
        name = f"scene-{land}-{rid}.png"; img.save(os.path.join(OUT, name))
        meta[name] = dict(land=land, route=rid, sec=si + 1, w=img.width, h=img.height, pad=pad, rows=rows, finds=fl)
    json.dump(meta, open(os.path.join(OUT, "scenes.json"), "w"))
    sheet = Image.new("RGBA", (T * 10 + 9 * 6 + 12, (OBJ_H + 8) * 4 + 12), (58, 52, 70, 255)); sy = 6
    lands = {"grassland": [hedge(0), tree(1), bush(1)], "forest": [tree(2, "pine"), tree(6), boulder(0, True)], "coast": [boulder(0), boulder(1), water("coast", 0)], "tundra": [pine(0), pine(5), water("tundra", 0)]}
    for land, objs in lands.items():
        x = 6
        for kind, v in (("floor", 0), ("floor", 1), ("floor", 2), ("floor", 3), ("rough", 0), ("rough", 1)):
            sheet.paste(ground(land, kind, v), (x, sy + OBJ_H - T)); x += T + 6
        for o in objs:
            if o.height == T: sheet.paste(o, (x, sy + OBJ_H - T))
            else: sheet.alpha_composite(o, (x, sy))
            x += T + 6
        sy += OBJ_H + 8
    sheet.save(os.path.join(OUT, "tile-sheet.png"))
    fs = Image.new("RGBA", (4 * 2 * 70 + 6 + 90, 76), (58, 52, 70, 255)); x = 6
    for land in LANDS:
        for dn in (False, True): fs.alpha_composite(find_spot(land, dn), (x, 6)); x += 70
    ic = icon_search(); fs.alpha_composite(ic, (x + 6, 6)); fs.save(os.path.join(OUT, "finds-sheet.png"))
    ic.save(os.path.join(OUT, "ico-search.png"))
    for land in LANDS:
        find_spot(land, False).save(os.path.join(OUT, f"find-{land}.png")); find_spot(land, True).save(os.path.join(OUT, f"find-{land}-done.png"))
def overlay_sheet():
    sheet = Image.new("RGBA", (16 * (T + 4) + 4, 4 * (T + 4) + 4), (58, 52, 70, 255))
    for li, land in enumerate(("grassland", "forest", "coast", "tundra")):
        for m in range(16):
            g = [["f"] * 3 for _ in range(3)]
            if m & 1: g[0][1] = "r"
            if m & 2: g[1][2] = "r"
            if m & 4: g[2][1] = "r"
            if m & 8: g[1][0] = "r"
            if m & 1 and m & 2: g[0][2] = "r"
            if m & 2 and m & 4: g[2][2] = "r"
            if m & 4 and m & 8: g[2][0] = "r"
            if m & 8 and m & 1: g[0][0] = "r"
            lay = terrain_layer(land, ["".join(r) for r in g], m).crop((T, T, 2 * T, 2 * T)); base = ground(land, "floor", 0)
            ov = lay.copy(); mk = terrain_layer(land, ["".join(r) for r in g], m)
            sheet.paste(lay, (4 + m * (T + 4), 4 + li * (T + 4)))
    sheet.save(os.path.join(OUT, "edge-masks.png"))
LANDS = ("grassland", "forest", "coast", "tundra")
if __name__ == "__main__":
    overlay_sheet()
    main()
