#!/usr/bin/env python3
"""Rich (environment) picture of a hand-tuned Maplewold bendy route, painted with the game's own tile art (claude/tile-art-v3-proposal/gen2.py)
plus the decor sprites below. Mockup only: reads claude/maplewold-bendy-maps/route-<id>.json and tools/maplewold_rich_specs.py, changes no data.
Run:  python3 -I tools/render_bendy_rich.py 228 [--sheet] [--out DIR] [--cache DIR]
Out:  claude/maplewold-bendy-maps/rich/route-<id>-s<n>.png  (one picture per section, 64 px tiles);  --sheet = decor sprite sheet only."""
import json, math, os, random, sys, zlib
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(HERE)
sys.path.insert(0, HERE); sys.path.insert(0, os.path.join(REPO, "claude", "tile-art-v3-proposal"))
from PIL import Image
import gen2 as G
G.ROOT = REPO
T, PAD = 64, 40
RAMP, INK, CREAM = G.RAMP, G.INK, G.CREAM
WOOD = RAMP["wood"]
def crc(*a): return zlib.crc32("|".join(map(str, a)).encode())
def R5(n): return G.r5(RAMP[n])

# ---------------------------------------------------------------- raised looks for thicket cells (64 x 96, feet near y 90)
def haybale(seed):
    rnd = random.Random(f"hb{seed}"); cv = G.Cv(64, 96); Gd = R5("gold"); tall = seed % 4 == 0; top = 32 if tall else 50
    for y in range(top, 91):
        for x in range(3, 61):
            if (x < 5 or x > 58) and (y < top + 2 or y > 88): continue
            if y < top + 12: t = 0 if x < 42 else 1
            else:
                u = (x - 3) / 58; t = 1 if u < .12 else 2 if u < .72 else 3
                if y > 85: t = min(4, t + 1)
            if rnd.random() < .2: t = max(0, min(4, t + rnd.choice((-1, 1))))
            cv.put(x, y, Gd[t])
    if tall:
        for x in range(3, 61): cv.put(x, 61, Gd[4]); cv.put(x, 62, Gd[1] if x < 42 else Gd[2])
    for bx in (18, 44):   # twine
        for y in range(top + 1, 90): cv.put(bx, y, WOOD[2] if y % 2 else WOOD[1]); cv.put(bx + 1, y, WOOD[3])
    for _ in range(46):   # straw
        x, y = rnd.randint(5, 52), rnd.randint(top + 14, 86)
        for k in range(rnd.randint(3, 6)): cv.put(x + k, y, Gd[0]); cv.put(x + k, y + 1, Gd[3]) if k > 1 else None
    for _ in range(7):    # loose straw
        x = rnd.randint(2, 54)
        for k in range(rnd.randint(3, 7)): cv.put(x + k, 91 + rnd.randint(0, 2), Gd[1 + k % 2])
    G.outline(cv); return cv.im

def fence(seed, north=False, crow=False):
    rnd = random.Random(f"fe{seed}"); cv = G.Cv(64, 96); W = R5("wood"); lean = (seed % 3) - 1
    if north:   # rails running up to the post in the tile above
        for y in range(18, 58):
            for x0 in (27, 35): cv.put(x0, y, W[1]); cv.put(x0 + 1, y, W[3])
    for y0 in (60, 74):   # broken rail stubs left and right
        for d, n in ((-1, 12 + seed % 7), (1, 9 + (seed * 3) % 9)):
            for k in range(n):
                x = (27 if d < 0 else 37) + d * k
                if k == n - 1 and (seed + y0) % 2: continue
                for j, c in enumerate((W[0], W[1], W[2], W[3])): cv.put(x, y0 + j, c)
    for y in range(48, 91):   # the post
        o = int(lean * (90 - y) / 20)
        for x in range(27, 37):
            u = (x - 27) / 9; t = 0 if u < .2 else 1 if u < .45 else 2 if u < .8 else 3
            if (y * 5 + x * 3) % 13 == 0: t = min(4, t + 1)
            cv.put(x + o, y, W[t] if y > 50 else W[0])
    if crow:
        o = int(lean * 2); D = R5("dusk")
        G.lump(cv, 32 + o, 42, 7, 5, [D[2], D[3], D[4], D[4], INK], rnd, 0)
        G.lump(cv, 38 + o, 37, 4, 4, [D[2], D[3], D[4], D[4], INK], rnd, 0)
        cv.put(42 + o, 37, RAMP["gold"][1]); cv.put(43 + o, 38, RAMP["gold"][2]); cv.put(39 + o, 36, CREAM)
        for k in range(5): cv.put(24 + o + k, 44 + (k < 2), D[4])
    for x in range(22, 42):
        if x % 3 == 0: cv.put(x, 92, RAMP["moss"][2]); cv.put(x, 91, RAMP["moss"][1])
    G.outline(cv); return cv.im

def appletree(seed):
    im = G.tree((0, 2, 3, 4, 6, 7)[seed % 6]); rnd = random.Random(f"ap{seed}"); p = im.load(); E = RAMP["ember"]; n = 0
    leafs = set(R5("leaf"))
    for _ in range(400):
        if n >= 9: break
        x, y = rnd.randrange(10, 52), rnd.randrange(22, 62)
        if all(p[x + dx, y + dy] in leafs for dx in range(-1, 4) for dy in range(-1, 4)):
            for dx in range(3):
                for dy in range(3): p[x + dx, y + dy] = E[1] if dx + dy < 3 else E[2]
            p[x, y] = E[0]; p[x + 1, y - 1] = WOOD[3]; n += 1
            for dx in range(-1, 4): p[x + dx, y + 3] = R5("leaf")[4]
    return im

def reeds(seed):
    rnd = random.Random(f"rd{seed}"); cv = G.Cv(64, 96)
    G._reeds(cv, 6 + seed % 5, 90, 4, rnd); G._reeds(cv, 34 + seed % 7, 92, 5, rnd); G._reeds(cv, 20, 86, 3, rnd)
    G.outline(cv); return cv.im

def signpost(seed):
    rnd = random.Random(f"sp{seed}"); cv = G.Cv(64, 96); W = R5("wood")
    for y in range(40, 91):
        for x in range(29, 35): cv.put(x, y, W[0 if x < 30 else 1 if x < 32 else 2 if x < 34 else 3])
    for y in range(44, 58):   # arrow board
        for x in range(10, 54):
            if x > 48 and abs(y - 51) > 54 - x: continue
            cv.put(x, y, W[0] if y < 46 else W[1] if y < 54 else W[2])
    for x in range(15, 44, 4): cv.put(x, 50, W[4]); cv.put(x + 1, 50, W[4]); cv.put(x + (x % 8 == 3), 52, W[4])
    for y in range(62, 72):   # second, smaller board the other way
        for x in range(16, 46):
            if x < 20 and abs(y - 66) > x - 15: continue
            cv.put(x, y, W[1] if y < 68 else W[3])
    G.clump(cv, 26, 91, 4, 4, 8, RAMP["moss"], rnd, 4); G.clump(cv, 38, 92, 4, 4, 7, RAMP["moss"], rnd, 4)
    G.outline(cv); return cv.im

# ---------------------------------------------------------------- props on walkable tiles (small, never read as walls)
def goat(seed):
    rnd = random.Random(f"go{seed}"); cv = G.Cv(64, 80); S = [CREAM] + RAMP["sand"][:1] + RAMP["stone"][:3]; D = RAMP["stone"]
    for lx in (20, 25, 37, 42):
        for y in range(58, 72): cv.put(lx, y, D[2]); cv.put(lx + 1, y, D[3])
        cv.put(lx, 72, INK); cv.put(lx + 1, 72, INK)
    G.lump(cv, 31, 52, 15, 9, S, rnd, .08)
    G.lump(cv, 47, 42, 6, 6, S, rnd, .05); G.lump(cv, 53, 45, 4, 3, S, rnd, 0)   # head, muzzle
    for k in range(7): cv.put(44 - k // 2, 36 - k, WOOD[1]); cv.put(45 - k // 2, 36 - k, WOOD[2])   # horn
    for k in range(5): cv.put(48 - k // 3, 35 - k, WOOD[0]); cv.put(49 - k // 3, 35 - k, WOOD[2])
    cv.put(49, 41, INK); cv.put(50, 41, INK); cv.put(56, 45, RAMP["petal"][1]); cv.put(41, 41, D[1]); cv.put(40, 42, D[2])
    for k in range(5): cv.put(51, 49 + k, CREAM); cv.put(52, 49 + k, D[1])   # beard
    for k in range(4): cv.put(15 - (k > 1), 47 - k, CREAM)   # tail
    for x in range(26, 34): cv.put(x, 46 + (x % 3 == 0), RAMP["sand"][1])   # patch
    G.outline(cv); return cv.im

def duck(seed):
    rnd = random.Random(f"du{seed}"); cv = G.Cv(64, 64); S = [CREAM, CREAM, RAMP["snow"][1], RAMP["snow"][2], RAMP["snow"][3]]
    for x in range(14, 52):   # ripple
        if (x // 3) % 2: cv.put(x, 44, RAMP["sea"][0])
    G.lump(cv, 30, 36, 11, 6, S, rnd, 0)
    if seed % 2: Hd = [RAMP["pine"][0], RAMP["pine"][1], RAMP["pine"][2], RAMP["pine"][3], RAMP["pine"][3]]
    else: Hd = S
    G.lump(cv, 40, 27, 5, 5, Hd, rnd, 0)
    cv.put(45, 27, RAMP["gold"][1]); cv.put(46, 27, RAMP["gold"][1]); cv.put(47, 28, RAMP["gold"][2]); cv.put(45, 28, RAMP["gold"][2]); cv.put(41, 26, INK)
    for k in range(4): cv.put(19 - k, 33 - k, CREAM)
    G.outline(cv); return cv.im

def pumpkins(seed):
    rnd = random.Random(f"pk{seed}"); cv = G.Cv(64, 64); O = [RAMP["gold"][0], RAMP["gold"][1], RAMP["gold"][2], RAMP["ember"][2], RAMP["gold"][3]]
    for cx, cy, rx, ry in ((20, 44, 11, 8), (42, 48, 9, 7), (34, 34, 8, 6))[:2 + seed % 2]:
        G.lump(cv, cx, cy, rx, ry, O, rnd, .04)
        for k in (-rx // 2, 0, rx // 2):
            for y in range(cy - ry + 2, cy + ry - 1): cv.put(cx + k, y, O[3]) if cv.get(cx + k, y)[3] and y % 3 else None
        cv.put(cx, cy - ry - 1, RAMP["moss"][2]); cv.put(cx, cy - ry - 2, RAMP["moss"][2]); cv.put(cx + 1, cy - ry - 3, RAMP["moss"][1])
    for k in range(9): cv.put(28 + k, 52 + int(2 * math.sin(k)), RAMP["moss"][2])   # vine
    for dx, dy in ((0, 0), (1, 0), (0, 1), (2, 1), (1, 2)): cv.put(46 + dx, 36 + dy, RAMP["moss"][1])
    G.outline(cv); return cv.im

def stump(seed):
    rnd = random.Random(f"st{seed}"); cv = G.Cv(64, 64); W = R5("wood")
    for y in range(34, 54):
        for x in range(20, 44):
            u = (x - 20) / 23; t = 1 if u < .15 else 2 if u < .5 else 3 if u < .85 else 4
            if (x * 7 + y) % 9 == 0: t = min(4, t + 1)
            cv.put(x, y, W[t])
    for y in range(26, 40):
        for x in range(19, 45):
            d = ((x - 31.5) / 13) ** 2 + ((y - 33) / 6.5) ** 2
            if d <= 1: cv.put(x, y, RAMP["sand"][0] if d < .12 else RAMP["sand"][2] if .3 < d < .42 or .68 < d < .8 else RAMP["sand"][1])
    for x in (17, 18, 45, 46): cv.put(x, 53, W[3]); cv.put(x, 52, W[2])
    if seed % 2:   # toadstool on the side
        for dx in range(-3, 4): cv.put(47 + dx, 44 - (abs(dx) < 2), RAMP["ember"][1])
        cv.put(46, 43, CREAM); cv.put(47, 45, CREAM); cv.put(47, 46, CREAM)
    G.clump(cv, 18, 55, 4, 4, 8, RAMP["moss"], rnd, 3); G.clump(cv, 46, 56, 4, 4, 7, RAMP["moss"], rnd, 3)
    G.outline(cv); return cv.im

def crate(seed):
    rnd = random.Random(f"cr{seed}"); cv = G.Cv(64, 64); W = R5("wood")
    for y in range(30, 54):
        for x in range(18, 46):
            t = 0 if y < 33 else 1 if x < 24 else 2 if x < 40 else 3
            if (y - 30) % 8 == 7 or x in (18, 45): t = 4
            cv.put(x, y, W[t])
    for i, (ax, ay) in enumerate(((22, 28), (29, 26), (36, 28), (41, 27), (26, 29), (33, 29))):   # apples / turnips on top
        c = RAMP["ember"] if (seed + i) % 3 else RAMP["gold"]
        for dx in range(4):
            for dy in range(4): cv.put(ax + dx, ay + dy, c[1] if dx + dy < 4 else c[2])
        cv.put(ax, ay, c[0])
    G.outline(cv); return cv.im

def basket(seed):
    rnd = random.Random(f"bk{seed}"); cv = G.Cv(64, 64); S = R5("sand")
    G.lump(cv, 32, 44, 12, 8, [S[1], S[2], S[2], S[3], S[4]], rnd, .1)
    for x in range(21, 44, 3):
        for y in range(38, 51): cv.put(x, y, S[4]) if cv.get(x, y)[3] and y % 2 else None
    for a in range(0, 180, 6):   # handle
        x = 32 + int(11 * math.cos(math.radians(a))); y = 38 - int(10 * math.sin(math.radians(a))); cv.put(x, y, S[2]); cv.put(x, y + 1, S[3])
    for i, ax in enumerate((25, 30, 35)):
        c = RAMP["ember"] if (seed + i) % 2 else RAMP["petal"]
        for dx in range(4):
            for dy in range(3): cv.put(ax + dx, 35 + dy, c[1] if dy < 2 else c[2])
        cv.put(ax, 35, c[0])
    G.outline(cv); return cv.im

PROPS = {"goat": goat, "duck": duck, "pumpkins": pumpkins, "stump": stump, "crate": crate, "basket": basket, "signpost": signpost}

# ---------------------------------------------------------------- flat overlays for rough cells and ground scatter (64 x 80, tile = lower 64 rows)
FLOWER = [("petal", "gold"), ("ember", "gold"), ("dusk", "gold"), ("gold", "wood"), ("snow", "gold"), ("sea", "snow")]
def flowerhead(cv, x, y, k, big=True):
    a, b = RAMP[FLOWER[k % len(FLOWER)][0]], RAMP[FLOWER[k % len(FLOWER)][1]]
    for i in range(1, 5 if big else 3): cv.put(x, y + i, RAMP["moss"][2])
    if big: cv.put(x + 1, y + 3, RAMP["moss"][1]); cv.put(x - 1, y + 4, RAMP["moss"][1])
    for dx, dy, c in ((-1, 0, a[1]), (1, 0, a[1]), (0, -1, a[0]), (0, 1, a[2])): cv.put(x + dx, y + dy, c)
    if big:
        for dx, dy, c in ((-1, -1, a[0]), (1, -1, a[1]), (-1, 1, a[2]), (1, 1, a[2])): cv.put(x + dx, y + dy, c)
    cv.put(x, y, b[0] if b is not RAMP["wood"] else b[2])

def ov_wheat(seed):
    rnd = random.Random(f"wh{seed}"); cv = G.Cv(64, 80); Gd = RAMP["gold"]; S = RAMP["sand"]
    stalks = [(rnd.randrange(2, 62), rnd.randrange(22, 78)) for _ in range(34)]
    for x, y in sorted(stalks, key=lambda s: s[1]):
        h = rnd.randint(14, 22); lean = rnd.choice((-2, -1, 0, 1, 2))
        for k in range(h):
            px = x + int(lean * k / h)
            cv.put(px, y - k, S[2] if k < 3 else Gd[2] if k < h - 6 else Gd[1])
            if k >= h - 6: cv.put(px + 1, y - k, Gd[0] if k % 2 else Gd[1]); cv.put(px - 1, y - k, Gd[2] if k % 2 else Gd[1])
        cv.put(x + int(lean), y - h, Gd[0])
    return cv.im

def ov_flowers(seed):
    rnd = random.Random(f"fl{seed}"); cv = G.Cv(64, 80); k0 = seed % len(FLOWER)
    for _ in range(4): G.clump(cv, rnd.randrange(6, 58), rnd.randrange(30, 78), 4, 5, 10, RAMP["moss"], rnd, 5)
    pts = sorted(((rnd.randrange(4, 60), rnd.randrange(20, 72)) for _ in range(13)), key=lambda p: p[1])
    for i, (x, y) in enumerate(pts): flowerhead(cv, x, y, k0 if i % 3 else k0 + 1 + i % 2)
    return cv.im

def ov_clover(seed):
    rnd = random.Random(f"cl{seed}"); cv = G.Cv(64, 80); M = RAMP["moss"]
    for _ in range(26):
        x, y = rnd.randrange(3, 61), rnd.randrange(20, 77)
        for dx, dy, c in ((0, 0, M[2]), (-2, -1, M[0]), (-1, -1, M[1]), (1, -1, M[0]), (2, -1, M[1]), (0, -2, M[0]), (0, -3, M[1]), (-1, 0, M[1]), (1, 0, M[1])): cv.put(x + dx, y + dy, c)
    for _ in range(4):   # white clover heads
        x, y = rnd.randrange(5, 59), rnd.randrange(22, 74)
        for dx, dy in ((0, 0), (1, 0), (0, -1), (1, -1), (-1, 0), (2, 0)): cv.put(x + dx, y + dy, CREAM)
        cv.put(x, y + 1, RAMP["petal"][0]); cv.put(x + 1, y + 1, RAMP["petal"][0]); cv.put(x, y + 2, M[2])
    return cv.im

def ov_marsh(seed):
    rnd = random.Random(f"ma{seed}"); cv = G.Cv(64, 80); Se = RAMP["sea"]
    for _ in range(1 + seed % 2):
        cx, cy, rx, ry = rnd.randrange(16, 48), rnd.randrange(36, 66), rnd.randint(9, 15), rnd.randint(4, 7)
        for y in range(cy - ry, cy + ry + 1):
            for x in range(cx - rx, cx + rx + 1):
                d = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
                if d <= 1: cv.put(x, y, RAMP["litter"][2] if d > .78 else Se[2] if y > cy + 1 else Se[1])
        for k in range(rx // 2): cv.put(cx - rx // 2 + k, cy - 1, Se[0])
    for _ in range(3 + seed % 3):   # short reeds and sedge
        x, y = rnd.randrange(5, 59), rnd.randrange(34, 78); h = rnd.randint(10, 18)
        for i in range(3):
            for k in range(h - i * 3): cv.put(x + i * 2 + (k * 2 // h), y - k, RAMP["moss"][1 if k % 4 else 0] if k > 2 else RAMP["moss"][3])
        if rnd.random() < .6:
            for k in range(5): cv.put(x, y - h - k, WOOD[2]); cv.put(x + 1, y - h - k, WOOD[3])
    return cv.im

def ov_tallgrass(seed):
    rnd = random.Random(f"tg{seed}"); cv = G.Cv(64, 80)
    for _ in range(7): G.clump(cv, rnd.randrange(5, 59), rnd.randrange(28, 78), 5, 7, 13, RAMP["leaf"], rnd, 4)
    for _ in range(3):
        x, y = rnd.randrange(5, 59), rnd.randrange(28, 70)
        for k in range(12): cv.put(x, y - k, RAMP["leaf"][2] if k < 8 else RAMP["gold"][1 if k % 2 else 0])
    return cv.im
ROUGH = {"wheat": ov_wheat, "flowers": ov_flowers, "clover": ov_clover, "marsh": ov_marsh, "grass": ov_tallgrass}

def sc_flowers(seed):
    rnd = random.Random(f"sf{seed}"); cv = G.Cv(64, 80)
    for i in range(2 + seed % 3): flowerhead(cv, rnd.randrange(8, 56), rnd.randrange(26, 72), seed + (i == 0), big=False)
    return cv.im
def sc_tuft(seed):
    rnd = random.Random(f"tu{seed}"); cv = G.Cv(64, 80)
    for _ in range(1 + seed % 2): G.clump(cv, rnd.randrange(10, 54), rnd.randrange(34, 76), 5, 5, 10, RAMP["moss"], rnd, 4)
    return cv.im
def sc_pebbles(seed):
    rnd = random.Random(f"pb{seed}"); cv = G.Cv(64, 80)
    for _ in range(2 + seed % 3): G.pebble(cv, rnd.randrange(8, 54), rnd.randrange(30, 74), RAMP["stone"], rnd, rnd.choice((3, 4, 5)))
    return cv.im
def sc_mushroom(seed):
    rnd = random.Random(f"mu{seed}"); cv = G.Cv(64, 80)
    for i in range(1 + seed % 3):
        x, y = rnd.randrange(12, 50), rnd.randrange(36, 70); c = RAMP["ember"] if (seed + i) % 3 else RAMP["sand"]
        for dy in range(4): cv.put(x, y + dy, CREAM); cv.put(x + 1, y + dy, RAMP["sand"][1])
        for dx in range(-3, 5):
            cv.put(x + dx, y - 1, c[1]); cv.put(x + dx, y, c[2])
            if abs(dx - .5) < 3: cv.put(x + dx, y - 2, c[0] if dx < 1 else c[1])
        cv.put(x - 1, y - 1, CREAM); cv.put(x + 2, y - 2, CREAM)
    G.outline(cv); return cv.im
def sc_straw(seed):
    rnd = random.Random(f"sw{seed}"); cv = G.Cv(64, 80)
    for _ in range(9):
        x, y = rnd.randrange(4, 54), rnd.randrange(24, 78)
        for k in range(rnd.randint(4, 8)): cv.put(x + k, y + (k // 4) * rnd.choice((0, 1)), RAMP["gold"][1 + k % 2]); cv.put(x + k, y + 1, RAMP["gold"][3]) if k % 3 == 0 else None
    return cv.im
def sc_apples(seed):
    rnd = random.Random(f"fa{seed}"); cv = G.Cv(64, 80); E = RAMP["ember"]
    for _ in range(2 + seed % 3):
        x, y = rnd.randrange(8, 54), rnd.randrange(30, 74)
        for dx in range(4):
            for dy in range(4):
                if (dx, dy) in ((0, 0), (3, 0), (0, 3), (3, 3)): continue
                cv.put(x + dx, y + dy, E[1] if dx + dy < 4 else E[2])
        cv.put(x + 1, y + 1, E[0]); cv.put(x + 2, y - 1, WOOD[3]); cv.put(x + 3, y - 1, RAMP["moss"][1])
        for dx in range(1, 5): cv.put(x + dx, y + 4, RAMP["moss"][3])
    return cv.im
def sc_butterfly(seed):
    cv = G.Cv(64, 80); x, y = 14 + seed % 36, 14 + (seed // 7) % 30; c = RAMP[("petal", "dusk", "gold", "sea")[seed % 4]]
    for dx, dy, col in ((-2, -1, c[0]), (-1, -1, c[1]), (-2, 0, c[1]), (-1, 0, c[2]), (1, -1, c[1]), (2, -1, c[0]), (1, 0, c[2]), (2, 0, c[1]), (-1, 1, c[2]), (1, 1, c[2]), (0, -1, INK), (0, 0, INK), (0, 1, INK)): cv.put(x + dx, y + dy, col)
    return cv.im
def sc_lily(seed):
    rnd = random.Random(f"ly{seed}"); cv = G.Cv(64, 80); M = RAMP["moss"]
    for i in range(1 + seed % 3):
        cx, cy, rx, ry = rnd.randrange(14, 50), rnd.randrange(30, 68), rnd.randint(5, 8), rnd.randint(3, 4)
        for y in range(cy - ry, cy + ry + 1):
            for x in range(cx - rx, cx + rx + 1):
                d = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
                if d <= 1 and not (x > cx and abs(y - cy) < (x - cx) * .5): cv.put(x, y, M[0] if y < cy and d < .6 else M[1] if y <= cy else M[2])
        for x in range(cx - rx + 1, cx + rx): cv.put(x, cy + ry + 1, RAMP["sea"][3])
        if (seed + i) % 2 == 0:
            for dx, dy, c in ((0, 0, RAMP["gold"][0]), (-1, 0, RAMP["petal"][0]), (1, 0, RAMP["petal"][1]), (0, -1, CREAM), (0, 1, RAMP["petal"][1]), (-1, -1, RAMP["petal"][0]), (1, -1, RAMP["petal"][0])): cv.put(cx - 2 + dx, cy - 1 + dy, c)
    return cv.im
def sc_stones(seed):
    rnd = random.Random(f"ss{seed}"); cv = G.Cv(64, 80); S = R5("stone")
    for cx, cy, rx, ry in ((18 + seed % 5, 34, 12, 7), (44 - seed % 4, 50, 13, 8), (22, 66, 10, 6)):
        for x in range(cx - rx - 1, cx + rx + 2): cv.put(x, cy + ry + 1, CREAM); cv.put(x + 2, cy + ry + 2, RAMP["sea"][0]) if x % 2 else None
        G.lump(cv, cx, cy, rx, ry, S, rnd, .1)
        for x in range(cx - rx // 2, cx + 2): cv.put(x, cy - ry + 1, RAMP["moss"][1]) if (x + seed) % 3 else None
    G.outline(cv); return cv.im
def sc_rock(seed):
    rnd = random.Random(f"rk{seed}"); cv = G.Cv(64, 80); S = R5("stone")
    G.lump(cv, 30 + seed % 8, 52, 9, 6, S, rnd, .1)
    for x in range(20, 46): cv.put(x, 59, CREAM) if x % 3 else None
    G.outline(cv); return cv.im
def sc_leaves(seed):
    rnd = random.Random(f"lv{seed}"); cv = G.Cv(64, 80)
    for _ in range(6):
        x, y = rnd.randrange(6, 58), rnd.randrange(28, 76); c = rnd.choice((RAMP["gold"], RAMP["ember"], RAMP["litter"]))
        cv.put(x, y, c[1]); cv.put(x + 1, y, c[0]); cv.put(x + 1, y + 1, c[2]); cv.put(x + 2, y + 1, c[1])
    return cv.im
SCATTER = {"flowers": sc_flowers, "tuft": sc_tuft, "pebbles": sc_pebbles, "mushroom": sc_mushroom, "straw": sc_straw, "apples": sc_apples, "butterfly": sc_butterfly,
           "lily": sc_lily, "stones": sc_stones, "rock": sc_rock, "leaves": sc_leaves}

_cache = {}
def spr(fn, *a):
    k = (fn.__name__,) + a
    if k not in _cache: _cache[k] = fn(*a)
    return _cache[k]

# ---------------------------------------------------------------- one section
def in_rect(x, y, r): return r[1] <= x <= r[3] and r[2] <= y <= r[4]
def lownoise(seed, cell=3):
    rnd = random.Random(f"ln{seed}"); g = [[rnd.random() for _ in range(40)] for _ in range(30)]
    def f(x, y):
        fx, fy = x / cell, y / cell; x0, y0 = int(fx), int(fy); tx, ty = fx - x0, fy - y0
        return (g[y0][x0] * (1 - tx) + g[y0][x0 + 1] * tx) * (1 - ty) + (g[y0 + 1][x0] * (1 - tx) + g[y0 + 1][x0 + 1] * tx) * ty
    return f

def paint(route, si, rich, cache_dir=None, walker=True):
    s = route["sections"][si]; rows = s["rows"]; W, Hh = len(rows[0]), len(rows); rid = route["route_id"]; land = route["land"]; seed = rid * 10 + si
    wall = lambda x, y: 0 <= x < W and 0 <= y < Hh and rows[y][x] == "#"
    walk = lambda x, y: 0 <= x < W and 0 <= y < Hh and rows[y][x] != "#"
    line = [tuple(c) for c in s["line"]]; on = set(line)
    water, ford = set(), set()
    for wv in s.get("water", []):
        for x, y in wv.get("pts", []): (water if wall(x, y) else ford).add((x, y))
    look = {}
    for r in rich.get("looks", []):
        for y in range(r[2], r[4] + 1):
            for x in range(r[1], r[3] + 1):
                if wall(x, y) and (x, y) not in water: look[(x, y)] = r[0]
    pond = {c for c, k in look.items() if k == "pond"}; wet = water | pond | ford
    ln = lownoise(seed)
    def default_look(x, y):
        h = crc("lk", x, y, seed) % 100; border = x in (0, W - 1) or y in (0, Hh - 1)
        opens = sum(walk(x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
        alone = not any(wall(x + dx, y + dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1) if (dx, dy) != (0, 0))
        near_wet = any((x + dx, y + dy) in wet for dx in (-1, 0, 1) for dy in (-1, 0, 1))
        if alone: return "boulder" if h < 35 else "bush" if h < 65 else "tree"
        if near_wet and opens and h < 45: return "reeds"
        if border or opens == 0: return "tree"
        v = ln(x, y)
        return "bush" if v > .62 else "boulder" if h < 7 else "tree"
    types = []
    for y, row in enumerate(rows):
        t = ""
        for x, c in enumerate(row):
            if (x, y) in wet: t += "w"
            elif c == "#": t += "f" if look.get((x, y)) in ("haybale", "fence") else "u"
            elif (x, y) in on: t += "p"
            else: t += "r" if c == "," else "f"
        types.append(t)
    key = f"{crc(land, seed, *types):08x}"; cf = os.path.join(cache_dir, f"ter-{key}.png") if cache_dir else None
    if cf and os.path.exists(cf): ter = Image.open(cf).convert("RGBA")
    else:
        ter = G.terrain_layer(land, [types[0].replace("w", "u")] + types, seed, True)
        if cf: ter.save(cf)
    tw, th = W * T, Hh * T + PAD
    base = Image.new("RGBA", (tw, th)); base.paste(ter.crop((0, T - PAD, tw, T - PAD + th)), (0, 0)); bp = base.load()
    items = []   # (depth, x, image, ox, oy)
    def shadow(cx, cy, big=True):
        G.ell(bp, cx + 3, cy, 24 if big else 13, 6 if big else 4, 1, tw, th)
        if big: G.ell(bp, cx + 12, cy + 1, 14, 4, 1, tw, th)
    def add_obj(x, y, im, jit=0, sh=True, depth=.5):   # 64 x 96 raised thing standing on tile x, y
        if sh: shadow(x * T + jit + 32, PAD + y * T + T - 4)
        items.append((y + depth, x, im, x * T + jit, PAD + y * T + T - 93))
    def add_ov(x, y, im, depth=.3):                      # 64 x 80 or 64 x 64 overlay on tile x, y
        items.append((y + depth, x, im, x * T, PAD + y * T + T - im.height))
    fences = {c for c, k in look.items() if k == "fence"}
    for y in range(Hh):
        for x in range(W):
            h = crc("o", x, y, seed)
            if (x, y) in wet:
                land_nb = any(walk(x + dx, y + dy) and (x + dx, y + dy) not in wet for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
                if (x, y) in ford: add_ov(x, y, spr(sc_stones, h % 6), .05)
                elif (x, y) in pond and h % 100 < 34: add_ov(x, y, spr(sc_lily, h % 9), .1)
                elif land_nb and h % 100 < 22 and (x, y) not in ford: add_obj(x, y, spr(reeds, h % 5), sh=False)
                elif (x, y) in water and h % 100 < 14: add_ov(x, y, spr(sc_rock, h % 5), .1)
                elif (x, y) in water and h % 100 < 22: add_ov(x, y, spr(sc_lily, h % 9), .1)
                continue
            if rows[y][x] == "#":
                k = look.get((x, y)) or default_look(x, y); jit = (crc("j", x, y, seed) % 7) - 3
                if k == "haybale": add_obj(x, y, spr(haybale, h % 8))
                elif k == "fence": add_obj(x, y, spr(fence, h % 6, (x, y - 1) in fences, h % 3 == 0), sh=False); shadow(x * T + 34, PAD + y * T + T - 4, False)
                elif k == "hedge": add_obj(x, y, spr(G.hedge, h % 3))
                elif k == "apple": add_obj(x, y, spr(appletree, h % 6), jit)
                elif k == "reeds": add_obj(x, y, spr(reeds, h % 5), sh=False)
                elif k == "bush": add_obj(x, y, spr(G.bush, h % 4), jit)
                elif k == "boulder": add_obj(x, y, spr(G.boulder, h % 5, h % 2 == 0), jit)
                else: add_obj(x, y, spr(G.tree, h % 8, "pine" if h % 11 == 0 else "leaf"), jit)
                continue
            if rows[y][x] == ",":
                k = next((r[0] for r in rich.get("rough", []) if in_rect(x, y, r)), "grass")
                if (x, y) in on and k in ("wheat", "marsh"): k = "grass" if k == "wheat" else k
                if (x, y) not in on or k in ("clover", "flowers"): add_ov(x, y, spr(ROUGH[k], h % 6), .3)
                continue
            if (x, y) in on or rows[y][x] not in ".": continue
            # plain floor: scatter by what is next to it
            nb = [look.get((x + dx, y + dy)) or ("wall" if wall(x + dx, y + dy) else None) for dx in (-1, 0, 1) for dy in (-1, 0, 1)]
            r = h % 1000
            if "haybale" in nb and r < 520: add_ov(x, y, spr(sc_straw, h % 6), .1)
            elif "apple" in nb and r < 560: add_ov(x, y, spr(sc_apples, h % 6), .1)
            elif "wall" in nb and r < 170: add_ov(x, y, spr(sc_leaves, h % 6), .1)
            elif "wall" in nb and r < 240: add_ov(x, y, spr(sc_mushroom, h % 6), .2)
            elif r < 130: add_ov(x, y, spr(sc_flowers, h % 12), .2)
            elif r < 250: add_ov(x, y, spr(sc_tuft, h % 6), .2)
            elif r < 300: add_ov(x, y, spr(sc_pebbles, h % 6), .1)
            elif r < 325: add_ov(x, y, spr(sc_butterfly, h % 40), .9)
    for kind, x, y in rich.get("props", []):
        if not walk(x, y) and kind != "duck": raise SystemExit(f"route {rid} s{si + 1}: prop {kind} at {x},{y} is not on a walkable tile")
        im = spr(PROPS[kind], crc(kind, x, y) % 8)
        if kind == "signpost": add_obj(x, y, im, sh=False); shadow(x * T + 34, PAD + y * T + T - 4, False)
        else:
            if kind != "duck": shadow(x * T + 32, PAD + y * T + T - 8, False)
            add_ov(x, y, im, .45)
    for x, y, name, jit in s.get("landmarks", []):
        im = G.landmark(name if name in G.LANDMARKS else f"{rid}-{name}"); cx, cy = x * T + 32 + jit, PAD + y * T + 60
        G.ell(bp, cx + 4, cy, int(im.width * .36), 7, 1, tw, th); G.ell(bp, cx + 8, cy + 1, int(im.width * .24), 4, 1, tw, th)
        items.append((y + .6, x, im, cx - im.width // 2, PAD + y * T + 62 - im.height))
    for x, y, c in s.get("tokens", []):
        if c == "F": items.append((y + .45, x, G.find_spot(land), x * T, PAD + y * T))
    if walker:
        gx, gy = line[min(3, len(line) - 1)]; gn = Image.open(os.path.join(REPO, "game/assets/img/trail/gnome.png")).convert("RGBA")
        shadow(gx * T + 30, PAD + gy * T + 46, False); items.append((gy + .5, gx, gn, gx * T, PAD + gy * T + 46 - 70))
    for _, _, im, ox, oy in sorted(items, key=lambda a: (a[0], a[1])):
        cl = im.crop((max(0, -ox), max(0, -oy), min(im.width, tw - ox), min(im.height, th - oy)))
        if cl.width > 0 and cl.height > 0: base.alpha_composite(cl, (max(ox, 0), max(oy, 0)))
    return base

def sheet(path):
    cells = [haybale(i) for i in range(4)] + [fence(0), fence(1, True), fence(3, False, True), appletree(0), appletree(1), reeds(0), signpost(0)] + \
            [fn(1) for fn in PROPS.values() if fn is not signpost] + [fn(i) for fn in ROUGH.values() for i in (0, 1)] + [fn(i) for fn in SCATTER.values() for i in (0, 1)]
    n = 12; im = Image.new("RGBA", (n * 68, ((len(cells) + n - 1) // n) * 100), (118, 180, 90, 255))
    for i, c in enumerate(cells): im.alpha_composite(c, ((i % n) * 68 + 2, (i // n) * 100 + 98 - c.height))
    im = im.resize((im.width * 2, im.height * 2), Image.NEAREST); im.save(path); print(path)

def main():
    args = sys.argv[1:]; out = os.path.join(REPO, "claude", "maplewold-bendy-maps", "rich"); cache = None
    if "--out" in args: out = args[args.index("--out") + 1]
    if "--cache" in args: cache = args[args.index("--cache") + 1]; os.makedirs(cache, exist_ok=True)
    os.makedirs(out, exist_ok=True)
    if "--sheet" in args: return sheet(os.path.join(out, "decor-sheet.png"))
    from maplewold_rich_specs import RICH
    only = [int(a[1:]) - 1 for a in args if a.startswith("s") and a[1:].isdigit()]
    for rid in [int(a) for a in args if a.isdigit()]:
        route = json.load(open(os.path.join(REPO, "claude", "maplewold-bendy-maps", f"route-{rid}.json")))
        for si in range(len(route["sections"])):
            if only and si not in only: continue
            im = paint(route, si, RICH[rid][si], cache)
            p = os.path.join(out, f"route-{rid}-s{si + 1}.png")
            im.convert("RGB").quantize(256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).save(p, optimize=True); print(p)

if __name__ == "__main__": main()
