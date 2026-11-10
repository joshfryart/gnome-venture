#!/usr/bin/env python3
"""Rich (environment) picture of a hand-tuned Maplewold bendy route, painted with the game's own tile art (claude/tile-art-v3-proposal/gen2.py)
plus the decor sprites below. Mockup only: reads claude/maplewold-bendy-maps/route-<id>.json and tools/maplewold_rich_specs.py, changes no data.
Run:  python3 -I tools/render_bendy_rich.py [ids ...] [s2] [--sheet] [--out DIR] [--cache DIR]      (no id = all 16 routes; s2 = only section 2)
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

def rowboat(seed):
    rnd = random.Random(f"rb{seed}"); cv = G.Cv(64, 64); W = R5("wood")
    for x in range(6, 60):
        if (x // 3) % 2: cv.put(x, 51, RAMP["sea"][0])
    G.lump(cv, 32, 40, 22, 9, W, rnd, .05)
    for y in range(33, 45):
        for x in range(14, 51):
            if ((x - 32) / 17) ** 2 + ((y - 38.5) / 5.5) ** 2 <= 1: cv.put(x, y, W[4] if y < 36 else W[3])
    for x in range(22, 43): cv.put(x, 38, W[0]); cv.put(x, 39, W[1]); cv.put(x, 40, W[2])
    for k in range(26): cv.put(16 + k, 46 - k // 2, RAMP["sand"][1]); cv.put(16 + k, 47 - k // 2, RAMP["sand"][3])
    for dx in range(5):
        for dy in range(4): cv.put(12 + dx, 45 + dy, RAMP["sand"][0 if dy < 2 else 2])
    G.outline(cv); return cv.im

def jetty(seed):
    cv = G.Cv(64, 64); W = R5("wood")
    for px in (8, 30, 52):
        for y in range(40, 58):
            for k in range(4): cv.put(px + k, y, W[3] if k < 2 else W[4])
    for y in range(26, 44):
        for x in range(4, 64):
            t = 0 if y == 26 else 1 if y < 39 else 3
            if x % 9 == 0: t = 4
            elif (x * 5 + y * 3) % 17 == 0: t = min(4, t + 1)
            cv.put(x, y, W[t])
    G.outline(cv); return cv.im

def hen(seed):
    rnd = random.Random(f"hn{seed}"); cv = G.Cv(64, 64); S = [CREAM, CREAM, RAMP["sand"][0], RAMP["sand"][1], RAMP["sand"][2]] if seed % 2 else [RAMP["wood"][0], RAMP["wood"][1], RAMP["wood"][1], RAMP["wood"][2], RAMP["wood"][3]]
    for lx in (28, 32): cv.put(lx, 51, RAMP["gold"][2]); cv.put(lx, 52, RAMP["gold"][2]); cv.put(lx + 1, 53, RAMP["gold"][2])
    G.lump(cv, 23, 42, 3, 4, S, rnd, 0); G.lump(cv, 30, 46, 7, 5, S, rnd, 0); G.lump(cv, 37, 40, 3, 3, S, rnd, 0)
    for dx, dy in ((0, 0), (1, 0), (-1, 1), (2, 1)): cv.put(37 + dx, 35 + dy, RAMP["ember"][1])
    cv.put(41, 40, RAMP["gold"][1]); cv.put(42, 41, RAMP["gold"][2]); cv.put(38, 39, INK); cv.put(40, 42, RAMP["ember"][1])
    G.outline(cv); return cv.im

def wheelbarrow(seed):
    rnd = random.Random(f"wb{seed}"); cv = G.Cv(64, 64); W = R5("wood"); St = RAMP["stone"]
    for k in range(16): cv.put(44 + k, 38 + k // 4, W[1]); cv.put(44 + k, 39 + k // 4, W[3])
    for y in range(46, 55): cv.put(43, y, W[3]); cv.put(44, y, W[4])
    for y in range(34, 47):
        for x in range(16 + (y - 34) // 2, 48 - (y - 34) // 3): cv.put(x, y, W[0] if y == 34 else W[1] if x < 24 else W[2] if x < 40 else W[3])
    G.lump(cv, 31, 31, 13, 6, R5("moss") if seed % 2 else R5("gold"), rnd, .18)
    for y in range(45, 56):
        for x in range(13, 24):
            d = (x - 18) ** 2 + (y - 50) ** 2
            if d <= 25: cv.put(x, y, St[0] if d < 3 else St[3] if d > 14 else St[2])
    G.outline(cv); return cv.im

def ladder(seed):
    cv = G.Cv(64, 96); W = R5("wood")
    for y in range(28, 91):
        o = int((90 - y) * 12 / 60)
        if (y - 28) % 9 == 4:
            for x in range(24 + o, 37 + o): cv.put(x, y, W[1]); cv.put(x, y + 1, W[3])
        for bx in (22, 36): cv.put(bx + o, y, W[0]); cv.put(bx + o + 1, y, W[2]); cv.put(bx + o + 2, y, W[3])
    G.outline(cv); return cv.im

def bench(seed):
    cv = G.Cv(64, 64); W = R5("wood")
    for px in (15, 46):
        for y in range(28, 55):
            for k in range(3): cv.put(px + k, y, W[2 + (k > 0) + (y > 44)])
    for y in range(30, 37):
        for x in range(12, 52): cv.put(x, y, W[0] if y == 30 else W[1] if y < 35 else W[3])
    for y in range(41, 47):
        for x in range(10, 54): cv.put(x, y, W[0] if y < 43 else W[2] if y < 46 else W[4])
    G.outline(cv); return cv.im

def rabbit(seed):
    rnd = random.Random(f"rbt{seed}"); cv = G.Cv(64, 64); Sd = RAMP["sand"]; S = [Sd[0], Sd[1], Sd[1], Sd[2], Sd[3]] if seed % 2 else [CREAM, RAMP["stone"][0], RAMP["stone"][0], RAMP["stone"][1], RAMP["stone"][2]]
    for ex in (38, 41):
        for y in range(30, 39): cv.put(ex, y, S[1]); cv.put(ex + 1, y, RAMP["petal"][0] if y > 31 else S[1])
    G.lump(cv, 29, 46, 8, 6, S, rnd, 0); G.lump(cv, 39, 41, 4, 4, S, rnd, 0)
    cv.put(41, 40, INK); cv.put(43, 42, RAMP["petal"][1])
    for dx in range(3):
        for dy in range(3): cv.put(19 + dx, 45 + dy, CREAM)
    G.outline(cv); return cv.im

def log(seed):
    rnd = random.Random(f"lg{seed}"); cv = G.Cv(64, 64); W = R5("wood")
    G.lump(cv, 30, 46, 22, 7, W, rnd, .12)
    for y in range(39, 54):
        for x in range(44, 56):
            d = ((x - 50) / 5.5) ** 2 + ((y - 46) / 7) ** 2
            if d <= 1: cv.put(x, y, RAMP["sand"][0] if d < .15 else RAMP["sand"][2] if .4 < d < .6 else RAMP["sand"][1])
    for x in range(10, 40):
        if (x * 7 + seed) % 5 < 3: cv.put(x, 40 + (x % 3 == 0), RAMP["moss"][1]); cv.put(x, 39 + (x % 3 == 0), RAMP["moss"][0])
    for x in range(14, 40, 6): cv.put(x, 47, W[4]); cv.put(x + 1, 47, W[4]); cv.put(x + 2, 48, W[4])
    G.outline(cv); return cv.im

def sacks(seed):
    rnd = random.Random(f"sk{seed}"); cv = G.Cv(64, 64); S = R5("sand")
    for cx, cy, rx, ry in ((23, 46, 9, 8), (41, 47, 9, 8), (32, 35, 8, 7)):
        G.lump(cv, cx, cy, rx, ry, S, rnd, .08)
        for dx in range(-2, 3): cv.put(cx + dx, cy - ry + 2, WOOD[2])
        cv.put(cx - 1, cy - ry, S[1]); cv.put(cx, cy - ry - 1, S[0]); cv.put(cx + 1, cy - ry, S[2])
    G.outline(cv); return cv.im

def crows(seed):
    rnd = random.Random(f"cw{seed}"); cv = G.Cv(64, 64); D = R5("dusk"); C = [D[2], D[3], D[4], D[4], INK]
    for cx, cy, d in ((22, 46, 1), (42, 38, -1)):
        G.lump(cv, cx, cy, 7, 5, C, rnd, 0); G.lump(cv, cx + 6 * d, cy - 5, 4, 4, C, rnd, 0)
        cv.put(cx + 10 * d, cy - 5, RAMP["gold"][1]); cv.put(cx + 11 * d, cy - 4, RAMP["gold"][2]); cv.put(cx + 7 * d, cy - 6, CREAM)
        for k in range(5): cv.put(cx - (8 + k) * d, cy + 2 + (k < 2), D[4])
        cv.put(cx - 1, cy + 6, RAMP["gold"][2]); cv.put(cx + 2, cy + 6, RAMP["gold"][2])
    G.outline(cv); return cv.im

def pitchfork(seed):
    cv = G.Cv(64, 96); W = R5("wood"); St = RAMP["stone"]
    for k in range(50):
        x, y = 40 - k * 14 // 50, 90 - k
        cv.put(x, y, W[1]); cv.put(x + 1, y, W[3])
    for x in range(20, 33): cv.put(x, 40, St[1]); cv.put(x, 41, St[3])
    for tx in (20, 26, 32):
        for y in range(26, 40): cv.put(tx, y, St[0]); cv.put(tx + 1, y, St[2])
    G.outline(cv); return cv.im

def topiary(seed):
    rnd = random.Random(f"tp{seed}"); cv = G.Cv(64, 96); cv.im.alpha_composite(G.hedge(seed % 3)); cv.p = cv.im.load()
    for y in range(42, 58):
        for x in range(30, 34): cv.put(x, y, WOOD[1 if x < 32 else 3])
    G.lump(cv, 32, 34, 13, 12, R5("moss"), rnd, .14)
    if seed % 2: G.lump(cv, 32, 16, 7, 6, R5("moss"), rnd, .14); cv.put(32, 23, WOOD[2]); cv.put(32, 24, WOOD[2])
    G.leaf_texture(cv, R5("moss"), rnd, 30)
    G.outline(cv); return cv.im

PROPS = {"goat": goat, "duck": duck, "pumpkins": pumpkins, "stump": stump, "crate": crate, "basket": basket, "signpost": signpost, "rowboat": rowboat, "jetty": jetty, "hen": hen,
         "wheelbarrow": wheelbarrow, "ladder": ladder, "bench": bench, "rabbit": rabbit, "log": log, "sacks": sacks, "crows": crows, "pitchfork": pitchfork}
TALL = ("signpost", "ladder", "pitchfork"); AFLOAT = ("duck", "rowboat", "jetty")

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
    stalks = [(rnd.randrange(2, 62), rnd.randrange(22, 78)) for _ in range(50)]
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
    pts = sorted(((rnd.randrange(4, 60), rnd.randrange(20, 72)) for _ in range(22)), key=lambda p: p[1])
    for i, (x, y) in enumerate(pts):
        flowerhead(cv, x, y, k0 if i % 3 else k0 + 1 + i % 2)
        if i % 4 == 0:   # a fat bloom
            a = RAMP[FLOWER[(k0 + i) % len(FLOWER)][0]]
            for dx, dy in ((-2, 0), (2, 0), (0, -2), (0, 2)): cv.put(x + dx, y + dy, a[1])
    return cv.im

def ov_clover(seed):
    rnd = random.Random(f"cl{seed}"); cv = G.Cv(64, 80); M = RAMP["moss"]
    for _ in range(26):
        x, y = rnd.randrange(3, 61), rnd.randrange(20, 77)
        for dx, dy, c in ((0, 0, M[2]), (-2, -1, M[0]), (-1, -1, M[1]), (1, -1, M[0]), (2, -1, M[1]), (0, -2, M[0]), (0, -3, M[1]), (-1, 0, M[1]), (1, 0, M[1])): cv.put(x + dx, y + dy, c)
    for _ in range(9):   # white clover heads
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
    for i in range(2 + seed % 3): flowerhead(cv, rnd.randrange(8, 56), rnd.randrange(26, 72), seed + (i == 0), big=i % 2 == 0)
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
        if (seed + i) % 5 == 3:   # a frog
            P = RAMP["pine"]
            for dx in range(-2, 3):
                for dy in range(-1, 2): cv.put(cx + dx, cy - 2 + dy, P[1] if dy < 1 else P[2])
            cv.put(cx - 2, cy - 4, CREAM); cv.put(cx + 2, cy - 4, CREAM); cv.put(cx - 2, cy - 3, INK); cv.put(cx + 2, cy - 3, INK)
    return cv.im
def sc_fern(seed):
    rnd = random.Random(f"fn{seed}"); cv = G.Cv(64, 80); P = RAMP["pine"]
    for _ in range(2 + seed % 2):
        x, y = rnd.randrange(14, 50), rnd.randrange(44, 76)
        for d in (-1, 1, 0):
            n = rnd.randint(10, 15)
            for k in range(n):
                px = x + int(d * k * .75); py = y - int(k * (.95 if d == 0 else .55)) - int(3 * math.sin(k / n * 3.1))
                cv.put(px, py, P[1])
                if k % 2 and k > 1:
                    w = max(1, (n - k) // 3)
                    for j in range(1, w + 1): cv.put(px - j, py + (j if d else 0), P[0] if j == w else P[1]); cv.put(px + j, py + (j if d else 0), P[2])
    return cv.im
def sc_trod(seed):
    rnd = random.Random(f"td{seed}"); cv = G.Cv(64, 80); L = RAMP["litter"]
    for _ in range(7):
        x, y = rnd.randrange(14, 46), rnd.randrange(24, 74); w = rnd.randint(4, 8)
        for k in range(w): cv.put(x + k, y, L[0]); cv.put(x + k, y + 1, L[1] if 0 < k < w - 1 else L[0]); cv.put(x + k, y + 2, L[1]) if 1 < k < w - 2 else None
    return cv.im
def sc_tulips(seed):
    rnd = random.Random(f"tl{seed}"); cv = G.Cv(64, 80); L = RAMP["litter"]
    for y in range(26, 36):
        for x in range(3, 61):
            if (x < 5 or x > 58) and (y < 28 or y > 33): continue
            cv.put(x, y, L[2] if y > 32 or rnd.random() < .15 else L[1])
    for i, x in enumerate(range(8, 60, 7)):
        c = RAMP[("ember", "gold", "petal", "dusk")[(seed + i) % 4 if seed % 3 else seed % 4]]
        for k in range(9): cv.put(x, 31 - k, RAMP["moss"][2])
        cv.put(x - 1, 27, RAMP["moss"][1]); cv.put(x - 2, 26, RAMP["moss"][1]); cv.put(x + 1, 28, RAMP["moss"][1]); cv.put(x + 2, 27, RAMP["moss"][0])
        for dx in range(-1, 3):
            for dy in range(5): cv.put(x + dx, 18 + dy, c[0] if dx < 0 else c[1] if dx < 2 and dy < 4 else c[2])
        cv.put(x - 1, 18, (0, 0, 0, 0)) if False else None
    return cv.im
def sc_furrows(seed):
    rnd = random.Random(f"fu{seed}"); cv = G.Cv(64, 80); L = RAMP["litter"]; M = R5("moss")
    for r, y0 in enumerate((22, 38, 54, 70)):
        for x in range(0, 64):
            for y in range(y0, y0 + 8):
                cv.put(x, y, L[0] if y == y0 and rnd.random() < .7 else L[2] if y > y0 + 5 or rnd.random() < .12 else L[1])
        for x in range(8 + (r % 2) * 8, 60, 16):
            if seed % 3: G.lump(cv, x, y0 + 1, 5, 4, M, rnd, .1); cv.put(x - 1, y0 - 1, M[0])
            else: G.clump(cv, x, y0 + 3, 4, 5, 9, RAMP["moss"], rnd, 2)
    return cv.im
def sc_flow(horiz, seed):
    rnd = random.Random(f"fw{seed}"); cv = G.Cv(64, 80); Se = RAMP["sea"]
    for _ in range(4):
        x, y = rnd.randrange(8, 44), rnd.randrange(26, 70); n = rnd.randint(6, 12)
        for k in range(n):
            px, py = (x + k, y + (k // 5) % 2) if horiz else (x + (k // 5) % 2, y + k - 6)
            cv.put(px, py, CREAM if k < n - 3 else Se[0]); cv.put(px + (0 if horiz else 1), py + (1 if horiz else 0), Se[2])
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
           "lily": sc_lily, "stones": sc_stones, "rock": sc_rock, "leaves": sc_leaves, "fern": sc_fern, "trod": sc_trod, "tulips": sc_tulips, "furrows": sc_furrows}

# ---------------------------------------------------------------- looks, rough, scatter and props for forest, coast and tundra
SNOW5 = [RAMP["snow"][0], RAMP["snow"][0], RAMP["snow"][1], RAMP["snow"][2], RAMP["snow"][3]]
def recolor(im, src, dst):
    m = dict(zip(src, dst)); p = im.load()
    for y in range(im.height):
        for x in range(im.width):
            if p[x, y] in m: p[x, y] = m[p[x, y]]
    return im
def birch(seed):
    St = RAMP["stone"]; im = recolor(G.tree(seed % 8, "moss"), RAMP["wood"], [CREAM, RAMP["snow"][1], St[1], St[2]]); p = im.load(); pale = (CREAM, RAMP["snow"][1], St[1])
    for y in range(63, 88, 4):
        for x in range(27 + (y * 3) % 5, 31 + (y * 3) % 5):
            if p[x, y] in pale: p[x, y] = St[3]
    return im
def maple(seed):
    im = G.tree(seed % 8, "gold" if seed % 2 else "ember"); p = im.load(); St = RAMP["stone"]
    for y in range(77, 85):
        for x in range(35, 42): p[x, y] = St[0] if y == 77 else St[1] if x < 39 else St[2]
    for x in range(35, 42): p[x, 85] = INK
    p[34, 76] = INK; p[42, 76] = INK; p[38, 75] = RAMP["gold"][0]; p[38, 76] = RAMP["gold"][1]
    return im
def berry(seed):
    im = G.bush(seed % 4).copy(); p = im.load(); rnd = random.Random(f"by{seed}"); ok = set(R5("moss")); D = RAMP["dusk"] if seed % 2 else RAMP["ember"]; n = 0
    for _ in range(300):
        if n >= 11: break
        x, y = rnd.randrange(10, 54), rnd.randrange(62, 86)
        if all(p[x + dx, y + dy] in ok for dx in (0, 1, 2) for dy in (0, 1, 2)):
            p[x, y] = D[0]; p[x + 1, y] = D[1]; p[x, y + 1] = D[1]; p[x + 1, y + 1] = D[2]; n += 1
    return im
def bramble(seed):
    rnd = random.Random(f"bm{seed}"); cv = G.Cv(64, 96); R = R5("pine")
    for l in ((20, 74, 17, 13), (45, 76, 16, 12), (32, 66, 19, 13), (32, 80, 26, 9)): G.lump(cv, *l, R, rnd, .18)
    for _ in range(16):   # thorny canes
        x, y = rnd.randrange(8, 54), rnd.randrange(58, 86); d = rnd.choice((-1, 1))
        for k in range(rnd.randint(5, 9)): cv.put(x + k * d, y - k // 2, RAMP["litter"][2]) if cv.get(x + k * d, y - k // 2)[3] else None
    for _ in range(8):
        x, y = rnd.randrange(10, 54), rnd.randrange(60, 86)
        if cv.get(x, y)[3]: cv.put(x, y, RAMP["dusk"][1]); cv.put(x + 1, y, RAMP["dusk"][2]); cv.put(x, y - 1, RAMP["dusk"][0])
    G.outline(cv); return cv.im
def beanpole(seed):
    rnd = random.Random(f"bp{seed}"); cv = G.Cv(64, 96); W = R5("wood")
    for bx in (14, 32, 50):
        for k in range(52):
            x = bx + int((32 - bx) * k / 52); y = 90 - k
            cv.put(x, y, W[1]); cv.put(x + 1, y, W[3])
            if k % 3 == 0 and 4 < k < 46:
                c = RAMP["moss"][rnd.choice((0, 1, 1, 2))]; d = rnd.choice((-2, -1, 2, 3))
                cv.put(x + d, y, c); cv.put(x + d, y - 1, c); cv.put(x + d + (1 if d > 0 else -1), y, RAMP["moss"][2])
            if k % 11 == 5: cv.put(x + 2, y, RAMP["ember"][1]); cv.put(x + 3, y - 1, RAMP["ember"][0])
    for x in range(29, 37): cv.put(x, 40, RAMP["sand"][1]); cv.put(x, 41, RAMP["sand"][2])
    G.outline(cv); return cv.im
def barrels(seed):
    rnd = random.Random(f"br{seed}"); cv = G.Cv(64, 96); W = R5("wood"); St = RAMP["stone"]
    for x0, y0 in ((6, 66), (34, 66), (20, 42))[:2 + (seed % 3 > 0)]:
        for y in range(y0, y0 + 24):
            ins = 2 if y - y0 > 18 else 0
            for x in range(x0 + ins, x0 + 24 - ins):
                u = (x - x0) / 23; t = 0 if y == y0 else 1 if u < .2 else 2 if u < .7 else 3
                if y in (y0 + 6, y0 + 17): cv.put(x, y, St[1] if u < .6 else St[2])
                else: cv.put(x, y, W[t] if (x - x0) % 5 else W[min(4, t + 1)])
        for x in range(x0 + 3, x0 + 21): cv.put(x, y0 + 1, RAMP["gold"][0] if seed % 2 else W[4]); cv.put(x, y0 + 2, RAMP["gold"][1] if seed % 2 else W[4])
    G.outline(cv); return cv.im
def biglog(seed, west=True, east=True):
    rnd = random.Random(f"bl{seed}"); cv = G.Cv(64, 96); W = R5("wood")
    x0 = 0 if west else 5
    for y in range(58, 90):
        for x in range(x0, 64 if east else 56):
            if not west and x < 9 and (y < 61 or y > 86): continue
            t = 0 if y < 61 else 1 if y < 68 else 2 if y < 80 else 3 if y < 87 else 4
            if (x * 3 + y * 7) % 23 < 2 or rnd.random() < .08: t = min(4, t + 1)
            cv.put(x, y, W[t])
    for x in range(x0, 64 if east else 56):   # moss on top
        if (x * 5 + seed) % 9 < 6:
            for k in range(1 + (x * 7 + seed) % 4): cv.put(x, 57 + k, RAMP["moss"][0 if k == 0 else 1])
    if not east:
        for y in range(57, 91):
            for x in range(50, 63):
                d = ((x - 56) / 6.5) ** 2 + ((y - 73.5) / 16.5) ** 2
                if d <= 1: cv.put(x, y, RAMP["sand"][0] if d < .1 else RAMP["sand"][2] if .3 < d < .42 or .65 < d < .78 else RAMP["sand"][1])
    if seed % 3 == 0:
        for dx in range(-3, 4): cv.put(22 + dx, 55 - (abs(dx) < 2), RAMP["ember"][1])
        cv.put(22, 56, CREAM); cv.put(22, 57, CREAM); cv.put(21, 54, CREAM)
    G.outline(cv); return cv.im
def sticks(seed):
    rnd = random.Random(f"sx{seed}"); cv = G.Cv(64, 96); W = R5("wood"); L = RAMP["litter"]
    G.lump(cv, 32, 76, 31, 15, [L[0], L[1], L[1], L[2], L[3]], rnd, .2)
    for _ in range(26):
        x, y = rnd.randrange(2, 50), rnd.randrange(64, 90); n = rnd.randint(9, 22); sl = rnd.choice((-.5, -.25, 0, .25, .5)); c = rnd.choice((W[0], W[1], W[1], RAMP["sand"][1]))
        for k in range(n):
            if cv.get(x + k, int(y + k * sl))[3]: cv.put(x + k, int(y + k * sl), c); cv.put(x + k, int(y + k * sl) + 1, W[4])
    for _ in range(5): cv.put(rnd.randrange(8, 56), rnd.randrange(62, 70), RAMP["moss"][1])
    G.outline(cv); return cv.im
def bigshroom(seed):
    rnd = random.Random(f"bs{seed}"); cv = G.Cv(64, 96); E = R5("ember"); S = R5("sand")
    for y in range(58, 91):
        for x in range(25, 39): cv.put(x + (y > 84) * (1 if x > 32 else -1), y, CREAM if x < 29 else S[1] if x < 35 else S[2])
    G.lump(cv, 32, 50, 27, 17, E, rnd, .05)
    for y in range(58, 68):
        for x in range(8, 57):
            if cv.get(x, y)[3] and cv.get(x, y) in E and y > 61 + abs(x - 32) // 9: cv.put(x, y, (0, 0, 0, 0)) if abs(x - 32) > 8 else cv.put(x, y, S[3])
    for cx, cy, r in ((22, 44, 4), (38, 40, 5), (46, 52, 3), (14, 54, 3), (31, 52, 3)):
        for dx in range(-r, r + 1):
            for dy in range(-r + 1, r):
                if dx * dx + dy * dy * 2 <= r * r and cv.get(cx + dx, cy + dy) in E: cv.put(cx + dx, cy + dy, CREAM)
    G.outline(cv); return cv.im
def glowrock(seed):
    im = G.boulder(seed % 5, True).copy(); p = im.load(); Se = RAMP["sea"]
    for i, (x, y) in enumerate(((10 + seed % 5, 84), (22, 88), (44 - seed % 4, 86), (52, 82))):
        for dy in range(4): p[x, y + dy] = CREAM
        for dx in range(-3, 4): p[x + dx, y] = Se[0] if dx < 1 else Se[1]; p[x + dx, y + 1] = Se[1]
        for dx in range(-2, 3): p[x + dx, y - 1] = CREAM if dx < 0 else Se[0]
    return im
def snowman(seed):
    rnd = random.Random(f"sm{seed}"); cv = G.Cv(64, 96); W = RAMP["wood"]
    for k in range(13): cv.put(19 - k, 62 - k // 2, W[2]); cv.put(45 + k, 62 - k // 2 - (k > 8), W[2])
    G.lump(cv, 32, 78, 15, 12, SNOW5, rnd, .04); G.lump(cv, 32, 60, 11, 9, SNOW5, rnd, .04); G.lump(cv, 32, 46, 8, 7, SNOW5, rnd, .04)
    c = RAMP[("ember", "dusk", "pine", "gold")[seed % 4]]
    for x in range(24, 41): cv.put(x, 52, c[0] if x < 30 else c[1]); cv.put(x, 53, c[1]); cv.put(x, 54, c[2])
    for y in range(54, 63): cv.put(38, y, c[1]); cv.put(39, y, c[2])
    for ex in (29, 34): cv.put(ex, 44, INK); cv.put(ex, 45, INK)
    for k in range(5): cv.put(32 + k, 47, RAMP["gold"][2] if k < 3 else RAMP["ember"][1])
    for k in (58, 63, 76): cv.put(32, k, INK); cv.put(33, k, INK)
    if seed % 2:
        for x in range(25, 40): cv.put(x, 39, W[3]); cv.put(x, 38, W[2])
        for y in range(30, 38):
            for x in range(28, 37): cv.put(x, y, W[2] if x < 31 else W[3])
    else:
        for x in range(27, 38): cv.put(x, 39, RAMP["stone"][2])
        for dx in range(5): cv.put(30 + dx, 38, RAMP["stone"][1]); cv.put(31 + dx % 3, 37, RAMP["stone"][1])
    G.outline(cv); return cv.im
def snowbank(seed):
    rnd = random.Random(f"sb{seed}"); cv = G.Cv(64, 96)
    for l in ((18, 76, 17, 12), (46, 78, 17, 11), (32, 68, 21, 15), (32, 82, 30, 9)): G.lump(cv, *l, SNOW5, rnd, .03)
    for _ in range(7):
        x, y = rnd.randrange(10, 54), rnd.randrange(58, 84)
        if cv.get(x, y)[3]: cv.put(x, y, CREAM); cv.put(x + 1, y, RAMP["ice"][1])
    if seed % 3 == 0: G.clump(cv, 12 + seed % 30, 88, 4, 6, 11, RAMP["sand"], rnd, 3)
    G.outline(cv); return cv.im
def icewall(seed):
    im = recolor(G.boulder(seed % 5), R5("stone"), R5("ice")); p = im.load(); rnd = random.Random(f"iw{seed}")
    for _ in range(8):
        x, y = rnd.randrange(10, 54), rnd.randrange(54, 86)
        if p[x, y][3] and p[x, y] != INK: p[x, y] = CREAM; p[x + 1, y + 1] = CREAM
    return im
def icicle(seed):
    cv = G.Cv(64, 96); I = R5("ice")
    for cx, top, hw in ((32, 26, 12), (16, 54, 7), (48, 46, 8)):
        for y in range(top, 91):
            half = max(.5, hw * (y - top) / (90 - top))
            for x in range(int(cx - half), int(cx + half) + 1):
                u = (x - (cx - half)) / (2 * half + .01); cv.put(x, y, I[0] if u < .22 else I[1] if u < .45 else I[2] if u < .75 else I[3])
        for y in range(top + 6, 88, 9): cv.put(cx - 1, y, CREAM); cv.put(cx - 1, y + 1, CREAM)
    for x in range(4, 60): cv.put(x, 91, RAMP["snow"][1]); cv.put(x, 90, RAMP["snow"][0]) if x % 5 else None
    G.outline(cv); return cv.im
def snowwall(seed):
    rnd = random.Random(f"sw2{seed}"); cv = G.Cv(64, 96); S = RAMP["snow"]
    for y in range(52, 90):
        for x in range(1, 63):
            c = min(x - 1, 62 - x); bump = 2 if (x // 8) % 2 else 0
            if y < 52 + max(0, 4 - c) + bump: continue
            row = (y - 54) // 9; t = S[0] if y < 60 else S[1] if y < 74 else S[2]
            if (y - 54) % 9 == 0 or (x + row * 8) % 16 == 0: t = S[3]
            cv.put(x, y, t)
    for _ in range(6): cv.put(rnd.randrange(4, 60), rnd.randrange(54, 60), CREAM)
    G.outline(cv); return cv.im
def cairn(seed):
    rnd = random.Random(f"cn{seed}"); cv = G.Cv(64, 96); St = R5("stone")
    for cx, cy, rx, ry in ((32, 82, 14, 7), (31 + seed % 3, 71, 11, 6), (33, 62, 8, 5), (32 - seed % 2, 54, 5, 4)):
        G.lump(cv, cx, cy, rx, ry, St, rnd, .1)
        for x in range(cx - rx + 2, cx + rx - 2): cv.put(x, cy - ry, RAMP["snow"][0]); cv.put(x, cy - ry + 1, RAMP["snow"][1]) if x % 3 else None
    if seed % 2:
        for k in range(9): cv.put(36 + k // 3, 49 - k, CREAM if k > 2 else RAMP["stone"][1]); cv.put(37 + k // 3, 49 - k, RAMP["snow"][2]) if k > 3 else None
    G.outline(cv); return cv.im
def starstone(seed):
    rnd = random.Random(f"ss2{seed}"); cv = G.Cv(64, 96); St = R5("stone"); top = 44 + seed % 3 * 5
    for y in range(top, 91):
        for x in range(21, 43):
            c = min(x - 21, 42 - x)
            if y < top + max(0, 6 - c * 2): continue
            u = (x - 21) / 21; t = 0 if u < .15 else 1 if u < .4 else 2 if u < .72 else 3
            if y > 86: t = 4
            if rnd.random() < .1: t = max(0, min(4, t + rnd.choice((-1, 1))))
            cv.put(x, y, St[t])
    cx, cy = 32, top + 20; Gd = RAMP["gold"]
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1), (2, 0), (-2, 0), (0, 2), (0, -2), (3, 0), (-3, 0), (0, 3), (0, -3), (1, 1), (-1, -1), (1, -1), (-1, 1)): cv.put(cx + dx, cy + dy, Gd[0] if abs(dx) + abs(dy) < 2 else Gd[1])
    cv.put(cx, cy, CREAM)
    for i in range(3): cv.put(27 + i * 5, cy + 12 + i % 2 * 3, Gd[1]); cv.put(26 + i * 5, cy - 9 - i % 2 * 2, Gd[0])
    for x in range(22, 42): cv.put(x, top + max(0, 6 - min(x - 21, 42 - x) * 2), RAMP["snow"][0]); cv.put(x, top + 1 + max(0, 6 - min(x - 21, 42 - x) * 2), RAMP["snow"][1])
    G.outline(cv); return cv.im
def driftwood(seed):
    rnd = random.Random(f"dw{seed}"); cv = G.Cv(64, 96); S = R5("sand"); P = [S[0], S[1], S[2], S[3], S[4]]
    G.lump(cv, 32, 82, 29, 7, P, rnd, .12); G.lump(cv, 24, 71, 20, 6, P, rnd, .12)
    if seed % 2: G.lump(cv, 42, 62, 14, 5, P, rnd, .12)
    for bx, by, d in ((50, 74, 1), (12, 64, -1), (38, 56, 1)):
        for k in range(10): cv.put(bx + k * d, by - k, S[1]); cv.put(bx + k * d + 1, by - k, S[3])
    for x in range(8, 56, 5): cv.put(x, 82 + x % 3, S[4]); cv.put(x + 1, 82 + x % 3, S[4]); cv.put(x + 2, 71, S[4])
    G.outline(cv); return cv.im
def dunetuft(seed):
    rnd = random.Random(f"dt{seed}"); cv = G.Cv(64, 96); S = R5("sand")
    G.lump(cv, 32, 82, 30, 10, S, rnd, .1); G.lump(cv, 26 + seed % 12, 74, 17, 9, S, rnd, .1)
    for _ in range(5): G.clump(cv, rnd.randrange(12, 52), rnd.randrange(70, 82), 6, 10, 22, RAMP["moss"], rnd, 5)
    G.outline(cv); return cv.im
def gatepost(seed):
    cv = G.Cv(64, 96); W = R5("wood")
    for y in range(40, 91):
        for x in range(25, 39):
            u = (x - 25) / 13; t = 0 if u < .18 else 1 if u < .45 else 2 if u < .78 else 3
            cv.put(x, y, W[t] if y > 43 else W[0])
    for y in range(52, 60):
        for x in range(25, 39): cv.put(x, y, RAMP["ember"][1] if (x + y) // 4 % 2 else CREAM)
    for k in range(12): cv.put(39 + k, 66 + int(3 * math.sin(k / 3.5)), RAMP["stone"][2]); cv.put(24 - k, 66 + int(3 * math.sin(k / 3.5)), RAMP["stone"][2])
    for dx in range(-3, 4):
        for dy in range(-3, 4):
            if abs(dx) + abs(dy) < 5: cv.put(32 + dx, 34 + dy, RAMP["gold"][0] if abs(dx) + abs(dy) < 2 else RAMP["gold"][1])
    G.outline(cv); return cv.im
def pennant(seed):
    cv = G.Cv(64, 96); W = R5("wood"); E = RAMP["ember"]
    for y in range(30, 91): cv.put(31, y, W[1]); cv.put(32, y, W[3])
    for y in range(32, 52):
        for x in range(33, 33 + max(0, 22 - abs(y - 42) * 2)): cv.put(x, y, E[0] if y < 36 else E[1] if y < 46 else E[2])
    for dx, dy in ((0, 0), (1, 0), (2, 0), (0, 1), (2, 1), (0, 2), (1, 2), (2, 2), (1, 3)): cv.put(38 + dx, 40 + dy, CREAM)
    cv.put(39, 41, INK)
    G.outline(cv); return cv.im
LOOKS = {"haybale": haybale, "topiary": topiary, "apple": appletree, "reeds": reeds, "berry": berry, "bramble": bramble, "beanpole": beanpole, "maple": maple, "barrels": barrels,
         "sticks": sticks, "bigshroom": bigshroom, "glowrock": glowrock, "snowman": snowman, "snowbank": snowbank, "icewall": icewall, "icicle": icicle, "snowwall": snowwall,
         "cairn": cairn, "starstone": starstone, "driftwood": driftwood, "dunetuft": dunetuft, "birch": birch}
RIGID = ("haybale", "topiary", "snowwall", "barrels", "sticks", "icicle", "beanpole")          # no jitter: they join into walls
BARE = ("haybale", "fence", "snowman", "cairn", "starstone", "beanpole", "barrels", "icicle", "snowwall", "driftwood", "dunetuft", "bigshroom", "biglog", "sticks", "snowbank", "icewall")   # no dark understory below
WET = ("pond", "sea", "icehole")

def ov_gravel(seed):
    rnd = random.Random(f"gv{seed}"); cv = G.Cv(64, 80); L = RAMP["litter"]
    for _ in range(12):
        x, y = rnd.randrange(3, 55), rnd.randrange(20, 76); w = rnd.randint(4, 9)
        for k in range(w): cv.put(x + k, y, L[0]); cv.put(x + k, y + 1, L[1]); cv.put(x + k, y + 2, L[1]) if 0 < k < w - 1 else None
    for _ in range(7): G.pebble(cv, rnd.randrange(5, 56), rnd.randrange(22, 76), RAMP["stone"], rnd, rnd.choice((3, 4)))
    return cv.im
def ov_toadstools(seed):
    rnd = random.Random(f"ts{seed}"); cv = G.Cv(64, 80)
    for i in range(4 + seed % 3):
        x, y = rnd.randrange(8, 54), rnd.randrange(30, 74); c = RAMP["ember"] if (seed + i) % 4 else RAMP["gold"]; r = rnd.randint(3, 5)
        for dy in range(5): cv.put(x, y + dy, CREAM); cv.put(x + 1, y + dy, RAMP["sand"][1])
        for dx in range(-r, r + 2):
            cv.put(x + dx, y - 1, c[1]); cv.put(x + dx, y, c[2])
            if abs(dx - .5) < r - 1: cv.put(x + dx, y - 2, c[0] if dx < 1 else c[1]); cv.put(x + dx, y - 3, c[0]) if abs(dx - .5) < r - 2 else None
        cv.put(x - 1, y - 1, CREAM); cv.put(x + 2, y - 2, CREAM); cv.put(x - 2, y, INK) if False else None
    return cv.im
def ov_ferns(seed):
    cv = G.Cv(64, 80)
    for k in range(3): cv.im.alpha_composite(sc_fern(seed * 3 + k), (0, 0)) if k == 0 else cv.im.alpha_composite(sc_fern(seed * 3 + k).transpose(Image.FLIP_LEFT_RIGHT), ((k * 9) % 12 - 6 if False else 0, 0))
    return cv.im
def ov_leaves(seed):
    cv = G.Cv(64, 80)
    for k in range(4): cv.im.alpha_composite(sc_leaves(seed * 4 + k) if k % 2 else sc_leaves(seed * 4 + k).transpose(Image.FLIP_LEFT_RIGHT))
    cv.p = cv.im.load(); rnd = random.Random(f"ac{seed}")
    for _ in range(3):   # acorns
        x, y = rnd.randrange(8, 54), rnd.randrange(30, 74)
        for dx in range(3): cv.put(x + dx, y, WOOD[3]); cv.put(x + dx, y + 1, RAMP["sand"][2]); cv.put(x + dx, y + 2, RAMP["sand"][2 if dx else 1])
        cv.put(x + 1, y + 3, RAMP["sand"][3]); cv.put(x + 1, y - 1, WOOD[3])
    return cv.im
def ov_glowcaps(seed):
    rnd = random.Random(f"gc{seed}"); cv = G.Cv(64, 80); Se = RAMP["sea"]
    for i in range(5 + seed % 3):
        x, y = rnd.randrange(8, 54), rnd.randrange(30, 74)
        for dy in range(4): cv.put(x, y + dy, CREAM)
        for dx in range(-3, 4): cv.put(x + dx, y, Se[1]); cv.put(x + dx, y - 1, Se[0]) if abs(dx) < 3 else None
        cv.put(x - 1, y - 2, CREAM); cv.put(x, y - 2, Se[0]); cv.put(x + 1, y - 2, Se[0])
        cv.put(x + rnd.randint(-5, 5), y - 6, Se[0])
    return cv.im
def ov_pebbles(seed):
    rnd = random.Random(f"op{seed}"); cv = G.Cv(64, 80); St = R5("stone")
    for _ in range(9): G.pebble(cv, rnd.randrange(4, 56), rnd.randrange(22, 76), RAMP["stone"] if rnd.random() < .7 else RAMP["sand"], rnd, rnd.choice((3, 4, 5, 6)))
    for _ in range(2 + seed % 2): G.lump(cv, rnd.randrange(12, 52), rnd.randrange(34, 70), rnd.randint(4, 6), 3, St, rnd, .1)
    return cv.im
def shell(cv, x, y, k):
    c = RAMP[("petal", "sand", "snow", "dusk")[k % 4]]
    if k % 3 == 0:   # starfish
        E = RAMP["ember"] if k % 2 else RAMP["gold"]
        for dx, dy in ((0, 0), (0, -1), (0, -2), (-1, 0), (-2, 0), (1, 0), (2, 0), (-1, 1), (-2, 2), (1, 1), (2, 2)): cv.put(x + dx, y + dy, E[1] if abs(dx) + abs(dy) > 1 else E[0])
    else:
        for dx, dy, i in ((0, 0, 0), (1, 0, 1), (2, 0, 1), (-1, 1, 0), (0, 1, 1), (1, 1, 1), (2, 1, 2), (3, 1, 2), (0, 2, 2), (1, 2, 2), (2, 2, 2)): cv.put(x + dx, y + dy, c[i])
        cv.put(x + 1, y + 1, c[0])
def ov_shells(seed):
    rnd = random.Random(f"sh{seed}"); cv = G.Cv(64, 80)
    for i in range(7): shell(cv, rnd.randrange(6, 56), rnd.randrange(22, 74), seed + i)
    for _ in range(3): G.pebble(cv, rnd.randrange(5, 56), rnd.randrange(22, 76), RAMP["stone"], rnd, 3)
    return cv.im
def ov_dunegrass(seed):
    rnd = random.Random(f"dg{seed}"); cv = G.Cv(64, 80)
    for _ in range(5): G.clump(cv, rnd.randrange(8, 56), rnd.randrange(34, 78), 6, 9, 18, RAMP["moss"], rnd, 4)
    for _ in range(8):
        x, y = rnd.randrange(4, 52), rnd.randrange(24, 76)
        for k in range(rnd.randint(5, 10)): cv.put(x + k, y + (k // 4) % 2, RAMP["sand"][2])
    return cv.im
def ov_kelp(seed):
    rnd = random.Random(f"kp{seed}"); cv = G.Cv(64, 80); P = RAMP["pine"]
    for _ in range(6):
        x, y = rnd.randrange(2, 40), rnd.randrange(26, 74); c = rnd.choice((P[2], P[3], RAMP["litter"][2]))
        for k in range(rnd.randint(12, 24)):
            yy = y + int(2 * math.sin(k / 2.5)); cv.put(x + k, yy, c); cv.put(x + k, yy + 1, P[3] if k % 5 else P[1])
    for _ in range(8): cv.put(rnd.randrange(3, 60), rnd.randrange(24, 76), CREAM)
    return cv.im
def ov_snowdrift(seed):
    rnd = random.Random(f"sd{seed}"); cv = G.Cv(64, 80); S = RAMP["snow"]
    for _ in range(3):
        cx, cy, rx = rnd.randrange(14, 50), rnd.randrange(30, 72), rnd.randint(9, 16)
        for dx in range(-rx, rx + 1):
            h = int(5 * math.sqrt(max(0, 1 - (dx / rx) ** 2)))
            for k in range(h + 1): cv.put(cx + dx, cy - k, S[0] if k >= h - 1 else S[1])
            cv.put(cx + dx, cy + 1, S[2]); cv.put(cx + dx + 2, cy + 2, S[2]) if abs(dx) < rx - 3 else None
    for _ in range(5): cv.put(rnd.randrange(4, 60), rnd.randrange(22, 76), CREAM)
    if seed % 3 == 0: G.clump(cv, rnd.randrange(10, 54), rnd.randrange(40, 76), 4, 5, 9, RAMP["sand"], rnd, 3)
    return cv.im
def ov_tracks(seed):
    rnd = random.Random(f"tk{seed}"); cv = G.Cv(64, 80); S = RAMP["snow"]
    if seed % 2:   # sled runners
        for x in range(0, 64):
            for y0 in (38, 56): cv.put(x, y0 + int(1.5 * math.sin(x / 9 + seed)), S[2]); cv.put(x, y0 + 1 + int(1.5 * math.sin(x / 9 + seed)), S[3] if x % 4 else S[2])
    else:          # paw prints
        for k in range(5):
            x, y = 6 + k * 12, 34 + (k % 2) * 14 + seed % 9
            for dx, dy in ((0, 0), (1, 0), (2, 0), (0, 1), (1, 1), (2, 1), (-1, -2), (1, -3), (3, -2)): cv.put(x + dx, y + dy, S[2] if dy < 1 else S[3])
    return cv.im
ROUGH.update({"ploughed": lambda seed: sc_furrows(seed), "gravel": ov_gravel, "toadstools": ov_toadstools, "ferns": ov_ferns, "leaves": ov_leaves, "glowcaps": ov_glowcaps,
              "pebbles": ov_pebbles, "shells": ov_shells, "dunegrass": ov_dunegrass, "kelp": ov_kelp, "snowdrift": ov_snowdrift, "tracks": ov_tracks, "mud": ov_marsh})
ROUGH_DEFAULT = {"grassland": "grass", "forest": "ferns", "coast": "pebbles", "tundra": "snowdrift"}

def sc_shells(seed):
    rnd = random.Random(f"s2h{seed}"); cv = G.Cv(64, 80)
    for i in range(1 + seed % 3): shell(cv, rnd.randrange(8, 54), rnd.randrange(28, 72), seed + i * 5)
    return cv.im
def sc_drygrass(seed):
    rnd = random.Random(f"dgr{seed}"); cv = G.Cv(64, 80)
    for _ in range(1 + seed % 2): G.clump(cv, rnd.randrange(10, 54), rnd.randrange(36, 76), 5, 5, 11, RAMP["sand"], rnd, 3)
    return cv.im
def sc_sparkle(seed):
    rnd = random.Random(f"spk{seed}"); cv = G.Cv(64, 80)
    for _ in range(2 + seed % 3):
        x, y = rnd.randrange(6, 58), rnd.randrange(24, 74); cv.put(x, y, CREAM); cv.put(x - 1, y, RAMP["ice"][1]); cv.put(x + 1, y, RAMP["ice"][1]); cv.put(x, y - 1, RAMP["ice"][1]); cv.put(x, y + 1, RAMP["ice"][1])
    return cv.im
def sc_crack(seed):
    rnd = random.Random(f"ck{seed}"); cv = G.Cv(64, 80); I = RAMP["ice"]
    for _ in range(2):
        x, y = rnd.randrange(6, 30), rnd.randrange(28, 70); d = rnd.choice((-1, 1))
        for k in range(rnd.randint(14, 28)): cv.put(x + k, y + d * ((k * 2) // 5 + (k // 7) % 2), I[3]); cv.put(x + k, y + d * ((k * 2) // 5 + (k // 7) % 2) + 1, I[0])
    for _ in range(3): cv.put(rnd.randrange(6, 58), rnd.randrange(24, 74), CREAM)
    return cv.im
def sc_icehole(seed):
    rnd = random.Random(f"ih{seed}"); cv = G.Cv(64, 80); Se = RAMP["sea"]
    cx, cy, rx, ry = 32, 50, 21 + seed % 5, 12 + seed % 3
    for y in range(cy - ry - 2, cy + ry + 3):
        for x in range(cx - rx - 2, cx + rx + 3):
            d = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 + .12 * math.sin(x * .7 + seed) * math.sin(y * .9)
            if d <= 1: cv.put(x, y, Se[3] if y < cy - ry + 4 or d > .8 and y < cy else Se[2])
            elif d <= 1.25: cv.put(x, y, CREAM if y > cy else RAMP["ice"][3])
    for k in range(8): cv.put(cx - 6 + k, cy + 2, Se[1]); cv.put(cx + 2 + k // 2, cy - 4, Se[1])
    return cv.im
def sc_paw(seed):
    cv = G.Cv(64, 80); c = RAMP["ember"]
    for k in range(3):
        x, y = 12 + k * 16, 40 + (k % 2) * 16
        for dx, dy in ((0, 0), (1, 0), (2, 0), (3, 0), (0, 1), (1, 1), (2, 1), (3, 1), (1, 2), (2, 2), (-1, -2), (1, -3), (3, -3), (5, -2)): cv.put(x + dx, y + dy, c[2] if dy > 0 else c[1])
    return cv.im

def skep(seed):
    rnd = random.Random(f"sk2{seed}"); cv = G.Cv(64, 64); S = [RAMP["gold"][0], RAMP["sand"][1], RAMP["gold"][1], RAMP["gold"][2], RAMP["gold"][3]]
    for y in range(50, 55):
        for x in range(18, 46): cv.put(x, y, WOOD[1] if y < 52 else WOOD[3])
    G.lump(cv, 32, 40, 12, 13, S, rnd, .08)
    for y in range(30, 52, 4):
        for x in range(20, 45):
            if cv.get(x, y)[3] and cv.get(x, y) != INK: cv.put(x, y, RAMP["gold"][3])
    for dx in range(-2, 3):
        for dy in range(4): cv.put(32 + dx, 47 + dy, INK) if abs(dx) + (dy == 0) < 3 else None
    for bx, by in ((16, 30), (48, 26), (44, 40), (20, 22)): cv.put(bx, by, RAMP["gold"][1]); cv.put(bx + 1, by, INK); cv.put(bx, by - 1, CREAM)
    G.outline(cv); return cv.im
def picnic(seed):
    cv = G.Cv(64, 64)
    for y in range(34, 54):
        for x in range(10 + (y - 34) // 4, 54 + (y - 34) // 4): cv.put(x, y, RAMP["ember"][1] if ((x - (y - 34) // 4) // 5 + y // 5) % 2 else CREAM)
    cv.im.alpha_composite(basket(seed).crop((16, 22, 48, 56)).resize((24, 26), Image.NEAREST), (30, 22)); cv.p = cv.im.load()
    for dx in range(5):
        for dy in range(3): cv.put(18 + dx, 40 + dy, RAMP["gold"][1 if dy < 2 else 2])
    G.outline(cv); return cv.im
def bucket(seed):
    cv = G.Cv(64, 64); W = R5("wood"); St = RAMP["stone"]
    for y in range(38, 54):
        ins = (y - 38) // 6
        for x in range(22 + ins, 42 - ins): cv.put(x, y, St[1] if y in (42, 50) else W[1] if x < 28 else W[2] if x < 37 else W[3])
    for x in range(23, 41): cv.put(x, 38, RAMP["gold"][0]); cv.put(x, 39, RAMP["gold"][1])
    for a in range(0, 181, 9): cv.put(32 + int(9 * math.cos(math.radians(a))), 38 - int(8 * math.sin(math.radians(a))), St[2])
    G.outline(cv); return cv.im
def owl(seed):
    rnd = random.Random(f"ow{seed}"); cv = G.Cv(64, 64); S = SNOW5 if seed >= 100 else [RAMP["sand"][1], RAMP["wood"][0], RAMP["wood"][1], RAMP["wood"][2], RAMP["wood"][3]]
    G.lump(cv, 32, 43, 8, 10, S, rnd, .12); G.lump(cv, 32, 33, 7, 6, S, rnd, .05)
    cv.put(26, 27, S[3]); cv.put(27, 28, S[3]); cv.put(38, 27, S[3]); cv.put(37, 28, S[3])
    for ex in (29, 35):
        for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)): cv.put(ex + dx, 33 + dy, RAMP["gold"][0])
        cv.put(ex, 33, INK)
    cv.put(32, 35, RAMP["gold"][2]); cv.put(32, 36, RAMP["gold"][2])
    for x in range(27, 38, 3): cv.put(x, 44, S[4]); cv.put(x + 1, 47, S[4])
    cv.put(29, 53, RAMP["gold"][2]); cv.put(35, 53, RAMP["gold"][2])
    G.outline(cv); return cv.im
def squirrel(seed):
    rnd = random.Random(f"sq{seed}"); cv = G.Cv(64, 64); S = [RAMP["gold"][1], RAMP["gold"][2], RAMP["wood"][1], RAMP["wood"][2], RAMP["wood"][3]]
    G.lump(cv, 22, 38, 5, 9, S, rnd, .1); G.lump(cv, 30, 46, 6, 6, S, rnd, 0); G.lump(cv, 36, 39, 4, 4, S, rnd, 0)
    cv.put(35, 34, S[2]); cv.put(36, 33, S[2]); cv.put(38, 38, INK); cv.put(40, 40, INK)
    for dx in range(3): cv.put(38 + dx, 44, RAMP["sand"][2]); cv.put(38 + dx, 45, WOOD[3])
    for dx in range(-1, 3): cv.put(31 + dx, 48, CREAM)
    G.outline(cv); return cv.im
def lantern(seed):
    cv = G.Cv(64, 64); W = R5("wood"); Gd = RAMP["gold"]
    for y in range(36, 55): cv.put(31, y, W[2]); cv.put(32, y, W[3])
    for x in range(27, 37): cv.put(x, 54, W[3])
    for y in range(22, 36):
        for x in range(26, 38): cv.put(x, y, W[3] if x in (26, 37) or y in (22, 35) else Gd[0] if abs(x - 31.5) < 2 and 26 < y < 32 else Gd[1])
    for x in range(28, 36): cv.put(x, 21, W[1]); cv.put(x + (x < 32) - (x > 32), 20, W[1]) if 29 < x < 34 else None
    for dx, dy in ((-4, 6), (16, 4), (-6, -2), (18, 12)): cv.put(26 + dx, 24 + dy, Gd[0])
    G.outline(cv); return cv.im
def lamp(seed):
    cv = G.Cv(64, 96); St = RAMP["stone"]; Gd = RAMP["gold"]
    for y in range(44, 91):
        for x in range(30, 34): cv.put(x, y, St[1] if x < 31 else St[2] if x < 33 else St[3])
    for x in range(26, 38): cv.put(x, 90, St[3]); cv.put(x, 89, St[2])
    for y in range(28, 44):
        for x in range(25, 39): cv.put(x, y, St[3] if x in (25, 38) or y in (28, 43) else Gd[0] if abs(x - 31.5) < 3 and 31 < y < 40 else Gd[1])
    for x in range(23, 41): cv.put(x, 27, RAMP["snow"][1]); cv.put(x, 26, RAMP["snow"][0]) if 24 < x < 39 else None
    for x in range(27, 37): cv.put(x, 25, RAMP["snow"][0])
    G.outline(cv); return cv.im
def beaver(seed):
    rnd = random.Random(f"bv{seed}"); cv = G.Cv(64, 64); S = [RAMP["wood"][0], RAMP["wood"][1], RAMP["wood"][1], RAMP["wood"][2], RAMP["wood"][3]]
    for y in range(47, 52):
        for x in range(12, 24): cv.put(x, y, RAMP["litter"][3] if (x + y) % 2 else RAMP["litter"][2])
    G.lump(cv, 30, 45, 10, 7, S, rnd, .08); G.lump(cv, 41, 41, 5, 5, S, rnd, 0)
    cv.put(43, 39, INK); cv.put(46, 42, INK); cv.put(45, 44, CREAM); cv.put(45, 45, CREAM); cv.put(39, 36, S[3]); cv.put(40, 36, S[3])
    G.outline(cv); return cv.im
def gull(seed):
    rnd = random.Random(f"gl{seed}"); cv = G.Cv(64, 64); S = [CREAM, CREAM, RAMP["snow"][1], RAMP["snow"][2], RAMP["stone"][1]]; d = 1 if seed % 2 else -1
    for lx in (29, 33): cv.put(lx, 50, RAMP["gold"][2]); cv.put(lx, 51, RAMP["gold"][2]); cv.put(lx + d, 52, RAMP["gold"][2])
    G.lump(cv, 31, 44, 8, 5, S, rnd, 0); G.lump(cv, 31 + 7 * d, 38, 4, 4, S, rnd, 0)
    for k in range(8): cv.put(31 - (2 + k) * d, 43 + k // 4, RAMP["stone"][1]); cv.put(31 - (2 + k) * d, 44 + k // 4, RAMP["stone"][2])
    cv.put(31 - 10 * d, 45, INK); cv.put(31 - 11 * d, 45, INK)
    cv.put(31 + 11 * d, 38, RAMP["gold"][1]); cv.put(31 + 12 * d, 39, RAMP["gold"][2]); cv.put(31 + 8 * d, 37, INK)
    G.outline(cv); return cv.im
def lobsterpot(seed):
    cv = G.Cv(64, 64); W = R5("wood")
    for y in range(34, 52):
        for x in range(16, 46):
            edge = y in (34, 51) or x in (16, 45)
            if y < 38 and (x < 19 + (38 - y) or x > 42 - (38 - y)): continue
            cv.put(x, y, W[1] if edge and y < 44 else W[3] if edge else W[2] if (x + y) % 5 == 0 or (x - y) % 5 == 0 else W[4])
    for a in range(0, 360, 20): cv.put(52 + int(5 * math.cos(math.radians(a))), 48 + int(3 * math.sin(math.radians(a))), RAMP["sand"][1 + (a // 20) % 2])
    for dx in range(4):
        for dy in range(5): cv.put(50 + dx, 38 + dy, RAMP["ember"][1 if dx < 2 else 2])
    G.outline(cv); return cv.im
def sled(seed):
    cv = G.Cv(64, 64); W = R5("wood")
    for x in range(12, 52):
        cv.put(x, 50, W[3]); cv.put(x, 51, W[4])
        if x % 9 == 3:
            for y in range(42, 50): cv.put(x, y, W[2]); cv.put(x + 1, y, W[3])
    for k in range(7): cv.put(52 + k // 2, 50 - k, W[3]); cv.put(53 + k // 2, 50 - k, W[4])
    for y in range(38, 43):
        for x in range(10, 50): cv.put(x, y, W[0] if y == 38 else W[1] if x % 8 else W[3])
    for k in range(10): cv.put(50 + k, 40 + k // 3, RAMP["sand"][1])
    G.outline(cv); return cv.im
def campfire(seed):
    rnd = random.Random(f"cf{seed}"); cv = G.Cv(64, 64); St = R5("stone"); Gd = RAMP["gold"]; E = RAMP["ember"]
    for a in range(0, 360, 45): G.lump(cv, 32 + int(13 * math.cos(math.radians(a))), 46 + int(6 * math.sin(math.radians(a))), 4, 3, St, rnd, 0)
    for k in range(18): cv.put(23 + k, 48 - k // 4, WOOD[2]); cv.put(23 + k, 49 - k // 4, WOOD[3]); cv.put(41 - k, 48 - k // 4, WOOD[1])
    for y in range(24, 46):
        hw = max(0, 7 - abs(y - 38) // 2 - (y < 30) * 2)
        for x in range(32 - hw, 33 + hw):
            d = abs(x - 32); cv.put(x + int(1.5 * math.sin(y / 2.5)), y, CREAM if d < 1 and y > 34 else Gd[0] if d < 2 else Gd[1] if d < 4 else E[0] if d < 6 else E[1])
    G.outline(cv); return cv.im
def tent(seed):
    cv = G.Cv(64, 96); c = RAMP["ember"] if seed % 2 else RAMP["dusk"]; S = RAMP["sand"]
    for y in range(38, 90):
        hw = (y - 38) * 28 // 52
        for x in range(32 - hw, 33 + hw):
            stripe = ((x - 32) * 52 // max(1, y - 37) + 40) // 9 % 2
            cv.put(x, y, (c[0] if x < 32 else c[1]) if stripe else (S[0] if x < 32 else S[1]))
    for y in range(62, 90):
        hw = (y - 62) * 7 // 28
        for x in range(32 - hw, 33 + hw): cv.put(x, y, INK if abs(x - 32) < hw else S[3])
    for y in range(30, 40): cv.put(32, y, WOOD[2])
    for dx in range(7):
        for dy in range(4): cv.put(33 + dx, 30 + dy, RAMP["gold"][1]) if dx < 7 - dy else None
    for x in range(4, 60): cv.put(x, 90, RAMP["snow"][1]) if x % 4 else None
    G.outline(cv); return cv.im
def fox(seed):
    rnd = random.Random(f"fx{seed}"); cv = G.Cv(64, 64)
    S = SNOW5 if seed >= 100 else [RAMP["gold"][1], RAMP["gold"][2], RAMP["gold"][2], RAMP["ember"][2], RAMP["wood"][3]]
    for lx in (24, 28, 36, 40):
        for y in range(48, 55): cv.put(lx, y, S[3]); cv.put(lx + 1, y, S[4] if seed < 100 else S[3])
    G.lump(cv, 16, 44, 7, 4, S, rnd, 0); cv.put(10, 43, CREAM); cv.put(11, 43, CREAM); cv.put(10, 44, CREAM); cv.put(11, 45, CREAM)
    G.lump(cv, 31, 45, 11, 6, S, rnd, .05); G.lump(cv, 43, 40, 5, 5, S, rnd, 0)
    for ex in (40, 45):
        for k in range(4): cv.put(ex + (k > 1), 35 - k, S[1]); cv.put(ex + 1, 35 - k // 2, S[3])
    cv.put(48, 42, CREAM); cv.put(49, 42, INK); cv.put(47, 43, CREAM); cv.put(44, 39, INK)
    G.outline(cv); return cv.im
def crab(seed):
    rnd = random.Random(f"cb{seed}"); cv = G.Cv(64, 64); E = R5("ember")
    G.lump(cv, 32, 46, 7, 4, E, rnd, 0)
    for d in (-1, 1):
        for k in range(3): cv.put(32 + d * (8 + k), 49 + k, E[3]); cv.put(32 + d * (7 + k), 51, E[3])
        G.lump(cv, 32 + d * 10, 41, 3, 2, E, rnd, 0)
        cv.put(32 + d * 3, 41, CREAM); cv.put(32 + d * 3, 40, INK)
    G.outline(cv); return cv.im
PROPS.update({"skep": skep, "picnic": picnic, "bucket": bucket, "owl": owl, "snowyowl": lambda s: owl(100 + s), "squirrel": squirrel, "lantern": lantern, "lamp": lamp, "beaver": beaver, "gull": gull,
              "lobsterpot": lobsterpot, "sled": sled, "campfire": campfire, "tent": tent, "fox": fox, "arcticfox": lambda s: fox(100 + s), "hare": lambda s: rabbit(0), "crab": crab,
              "driftlog": lambda s: recolor(log(s).copy(), R5("wood"), R5("sand"))})
TALL = TALL + ("lamp", "tent"); AFLOAT = AFLOAT + ("beaver",)
AMBIENT = {"grassland": ("rabbit", "hen", "log", "stump", "rabbit", "basket"), "forest": ("log", "stump", "squirrel", "owl", "fox", "squirrel", "log"),
           "coast": ("gull", "gull", "lobsterpot", "driftlog", "crab", "crab", "gull"), "tundra": ("hare", "arcticfox", "snowyowl", "hare", "sled", "stump")}

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

def paint_water(bp, tw, th, wet, ford, corners, land, seed, holes=()):
    """Water with a wandering bank: the wet cells are pushed around by noise, so no edge is straight. Bank shade up-left, pale shallows, deeper middle, a mud rim."""
    rnd = random.Random(f"wa{seed}"); Se = RAMP["ice"] if land == "tundra" else RAMP["sea"]; foam = CREAM if land == "coast" else Se[0]
    n1, n2, n3, n4 = (G.wnoise(rnd, tw, th + T, c) for c in (22, 22, 7, 7)); nv, nd = G.wnoise(rnd, tw, th + T, 52), G.wnoise(rnd, tw, th + T, 16)
    tex = [G.water(land, k).load() for k in range(3)]
    cells = {(x + dx, y + dy) for x, y in wet for dx in (-1, 0, 1) for dy in (-1, 0, 1)}
    deep = {c for c in wet if all((c[0] + dx, c[1] + dy) in wet for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))}
    m = {}; land_px = []
    for cx, cy in cells:
        for py in range(max(0, PAD + cy * T), min(th, PAD + cy * T + T)):
            for px in range(max(0, cx * T), min(tw, cx * T + T)):
                wx = px + (n1(px, py) - .5) * 26 + (n3(px, py) - .5) * 9; wy = py - PAD + (n2(px, py) - .5) * 26 + (n4(px, py) - .5) * 9
                c = (int(wx // T), int(wy // T))
                if c in wet: m[(px, py)] = c
                else:
                    for qx, qy, qc in corners:
                        if (wx - qx) ** 2 + (wy - qy) ** 2 < 26 * 26: m[(px, py)] = qc; break
                    else: land_px.append((px, py))
    for (px, py), c in m.items():
        w = lambda a, b: (px + a, py + b) in m
        t = tex[int(nv(px, py) * 5.9) % 3][px % T, py % T]
        if not (w(0, -1) and w(0, -2) and w(-1, 0) and w(0, -3)): col = Se[3]
        elif not (w(0, 2) and w(2, 0)): col = foam
        elif not (w(0, 6) and w(6, 0) and w(0, -7) and w(-6, 0)): col = foam if (px + py) % 2 else Se[1]
        elif c in ford: col = G.lighter(t)
        elif c in deep and nd(px, py) > .42: col = G.darker(t, 1)
        else: col = t
        bp[px, py] = col
    for px, py in land_px:   # mud and pebble rim on the land side
        d = 1 if any((px + a, py + b) in m for a, b in ((0, 1), (1, 0), (0, -1), (-1, 0), (0, 2), (2, 0))) else 2 if any((px + a, py + b) in m for a, b in ((0, 4), (4, 0), (0, -3), (-3, 0), (3, 3))) else 0
        if d == 1: bp[px, py] = RAMP["litter"][1] if n3(px, py) > .3 else RAMP["sand"][2]
        elif d == 2 and n3(px, py) > .45: bp[px, py] = RAMP["sand"][1] if (px * 3 + py) % 7 else RAMP["stone"][0]

def paint(route, si, rich, cache_dir=None, walker=True):
    s = route["sections"][si]; rows = s["rows"]; W, Hh = len(rows[0]), len(rows); rid = route["route_id"]; land = route["land"]; seed = rid * 10 + si
    green = land in ("grassland", "forest")
    wall = lambda x, y: 0 <= x < W and 0 <= y < Hh and rows[y][x] == "#"
    walk = lambda x, y: 0 <= x < W and 0 <= y < Hh and rows[y][x] != "#"
    inner = lambda x, y: 1 <= x <= W - 2 and 1 <= y <= Hh - 2
    line = [tuple(c) for c in s["line"]]; on = set(line)
    water, ford, horiz, corners = set(), set(), {}, []
    for wv in s.get("water", []):
        pts = [tuple(c) for c in wv.get("pts", [])]
        for i, (x, y) in enumerate(pts):
            (water if wall(x, y) else ford).add((x, y))
            a, b = pts[max(0, i - 1)], pts[min(len(pts) - 1, i + 1)]; horiz[(x, y)] = abs(b[0] - a[0]) >= abs(b[1] - a[1])
            if i and a[0] != x and a[1] != y: corners.append((max(a[0], x) * T, max(a[1], y) * T, (x, y)))
    look = {}
    for r in rich.get("looks", []):
        for y in range(r[2], r[4] + 1):
            for x in range(r[1], r[3] + 1):
                if wall(x, y) and (x, y) not in water and (r[0] == "sea" or inner(x, y)): look[(x, y)] = r[0]
    rough_of = lambda x, y: next((r[0] for r in rich.get("rough", []) if in_rect(x, y, r)), ROUGH_DEFAULT[land])
    icefloor = {(x, y) for y in range(Hh) for x in range(W) if rows[y][x] == "," and rough_of(x, y) == "ice"}
    pond = {c for c, k in look.items() if k in WET}; sea = {c for c, k in look.items() if k == "sea"}; holes = {c for c, k in look.items() if k == "icehole"}
    wet = water | pond | ford | icefloor
    ln = lownoise(seed)
    def default_look(x, y):
        h = crc("lk", x, y, seed) % 100; border = not inner(x, y)
        opens = sum(walk(x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
        alone = not any(wall(x + dx, y + dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1) if (dx, dy) != (0, 0))
        near_wet = any((x + dx, y + dy) in wet for dx in (-1, 0, 1) for dy in (-1, 0, 1)); v = ln(x, y)
        if land == "coast":
            if alone: return "boulder" if h < 50 else "driftwood" if h < 75 else "dunetuft"
            if border: return "boulder" if v > .52 else "dunetuft"
            if opens == 0: return "boulder"
            return "boulder" if h < 62 else "dunetuft" if h < 86 else "driftwood"
        if land == "tundra":
            if alone: return "boulder" if h < 35 else "snowbank" if h < 65 else "tree"
            if border: return "snowbank" if opens and h < 12 else "tree"
            if opens == 0: return "tree"
            return "snowbank" if v > .66 else "boulder" if h < 12 else "tree"
        if alone: return "boulder" if h < 35 else "bush" if h < 65 else "tree"
        if near_wet and opens and h < 45: return "reeds"
        if border: return "bush" if opens and h < 12 else "tree"
        if opens == 0: return "tree"
        return "bush" if v > .62 else "boulder" if h < 7 else "tree"
    style = rich.get("tree")
    def tree_im(x, y):
        h = crc("tc", x, y, seed); c = h % 100; v = (h // 100) % 8
        if land == "tundra": return spr(G.pine, v % 6)
        if land == "coast": return spr(G.boulder, v % 5)
        if style == "birch": return spr(birch, v) if c < 85 else spr(G.tree, v, "pine")
        if style == "maple": return spr(G.tree, v, "gold" if c < 28 else "ember" if c < 52 else "leaf" if c < 85 else "moss")
        if land == "forest": return spr(G.tree, v, "pine" if c < 32 else "moss" if c < 47 else "gold" if c < 50 else "ember" if c < 52 else "leaf")
        return spr(G.tree, v, "gold" if c < 5 else "ember" if c < 8 else "pine" if c < 20 else "moss" if c < 30 else "leaf")
    def boulder_im(h): return spr(G.boulder, h % 5, False, True) if land == "tundra" else spr(G.boulder, h % 5, land == "forest" or (green and h % 2 == 0))
    types = []
    for y, row in enumerate(rows):
        t = ""
        for x, c in enumerate(row):
            if (x, y) in wet: t += "f"
            elif c == "#": t += "f" if look.get((x, y)) in BARE or (land == "coast" and not inner(x, y)) else "u"
            elif (x, y) in on: t += "p"
            else: t += "r" if c == "," else "f"
        types.append(t)
    key = f"{crc(land, seed, *types):08x}"; cf = os.path.join(cache_dir, f"ter-{key}.png") if cache_dir else None
    if cf and os.path.exists(cf): ter = Image.open(cf).convert("RGBA")
    else:
        ter = G.terrain_layer(land, [types[0]] + types, seed, True)
        if cf: ter.save(cf)
    tw, th = W * T, Hh * T + PAD
    base = Image.new("RGBA", (tw, th)); base.paste(ter.crop((0, T - PAD, tw, T - PAD + th)), (0, 0)); bp = base.load()
    if wet: paint_water(bp, tw, th, wet, ford | icefloor, corners, land, seed)
    items = []   # (depth, x, image, ox, oy)
    def shadow(cx, cy, big=True):
        G.ell(bp, cx + 3, cy, 24 if big else 13, 6 if big else 4, 1, tw, th)
        if big: G.ell(bp, cx + 12, cy + 1, 14, 4, 1, tw, th)
    def add_obj(x, y, im, jit=0, sh=True, depth=.5, jy=0):   # 64 x 96 raised thing standing on tile x, y
        if sh: shadow(x * T + jit + 32, PAD + y * T + T - 4 + jy)
        items.append((y + depth + jy / 64, x, im, x * T + jit, PAD + y * T + T - 93 + jy))
    def add_ov(x, y, im, depth=.3):                      # 64 x 80 or 64 x 64 overlay on tile x, y
        items.append((y + depth, x, im, x * T, PAD + y * T + T - im.height))
    at = rich.get("lm_at", {}); lms = [(at.get(l[2], (l[0], l[1])), l[2], l[3]) for l in s.get("landmarks", [])]
    finds = [(t[0], t[1]) for t in s.get("tokens", []) if t[2] == "F"]
    # worn side trails: from every landmark and find to the nearest road tile
    trod = set()
    for tx, ty in [c for c, _, _ in lms] + finds:
        prev = {(tx, ty): None}; q = [(tx, ty)]; hit = None
        while q and hit is None:
            c = q.pop(0)
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = (c[0] + dx, c[1] + dy)
                if n in prev or not walk(*n) or n in wet: continue
                prev[n] = c
                if n in on: hit = c; break
                q.append(n)
        while hit is not None and hit != (tx, ty): trod.add(hit); hit = prev[hit]
    fences = {c for c, k in look.items() if k == "fence"}; logs = {c for c, k in look.items() if k == "biglog"}
    zone = lambda x, y: next((r[0] for r in rich.get("floor", []) if in_rect(x, y, r)), None)
    if land != "coast":
        for x in range(W - 1):   # a second row of crowns behind the top edge, for depth
            if rows[0][x] == "#" and rows[0][x + 1] == "#" and (x, 0) not in wet and (x + 1, 0) not in wet: items.append((-.5, x, tree_im(x, -1), x * T + 32, PAD - 62))
    for y in range(Hh):
        for x in range(W):
            h = crc("o", x, y, seed); hh = h % 100
            if (x, y) in wet:
                land_nb = any(walk(x + dx, y + dy) and (x + dx, y + dy) not in wet for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
                if (x, y) in holes: add_ov(x, y, spr(sc_icehole, h % 6), .03)
                elif (x, y) in ford: add_ov(x, y, spr(sc_stones, h % 6), .05)
                elif (x, y) in icefloor or land == "tundra":
                    if hh < 40: add_ov(x, y, spr(sc_crack, h % 8), .02)
                    elif hh < 55: add_ov(x, y, spr(sc_sparkle, h % 8), .02)
                elif (x, y) in sea:
                    if hh < 16: add_ov(x, y, spr(sc_flow, True, h % 6), .02)
                    elif hh < 19 and inner(x, y): add_ov(x, y, spr(sc_rock, h % 5), .1)
                    elif hh < 21 and inner(x, y) and not land_nb: add_ov(x, y, spr(gull, h % 4), .2)
                elif not green:
                    if hh < 25: add_ov(x, y, spr(sc_shells, h % 9), .02)
                    elif hh < 40: add_ov(x, y, spr(sc_rock, h % 5), .1)
                elif (x, y) in pond and hh < 30: add_ov(x, y, spr(sc_lily, h % 10), .1)
                elif land_nb and hh < 46: add_obj(x, y, spr(reeds, h % 5), sh=False, jy=-6 - h % 9)
                elif (x, y) in water and hh < 58: add_ov(x, y, spr(sc_rock, h % 5), .1)
                elif (x, y) in water and hh < 70: add_ov(x, y, spr(sc_lily, h % 10), .1)
                elif (x, y) in water: add_ov(x, y, spr(sc_flow, horiz.get((x, y), True), h % 6), .02)
                continue
            if rows[y][x] == "#":
                k = look.get((x, y)) or default_look(x, y); jit = (crc("j", x, y, seed) % 11) - 5; jy = (crc("jy", x, y, seed) % 9) - 4
                if land == "coast" and not inner(x, y): jit = jy = 0
                if k == "fence": add_obj(x, y, spr(fence, h % 6, (x, y - 1) in fences, h % 3 == 0), sh=False); shadow(x * T + 34, PAD + y * T + T - 4, False)
                elif k == "biglog": add_obj(x, y, spr(biglog, h % 6, (x - 1, y) in logs, (x + 1, y) in logs))
                elif k == "hedge": add_obj(x, y, spr(G.hedge, h % 3))
                elif k == "bush": add_obj(x, y, spr(G.bush, h % 4), jit, jy=jy)
                elif k == "boulder": add_obj(x, y, boulder_im(h), jit)
                elif k in LOOKS:
                    rigid = k in RIGID; add_obj(x, y, spr(LOOKS[k], h % 8), 0 if rigid else jit, sh=k not in ("reeds", "beanpole"), jy=0 if rigid else jy)
                else:
                    add_obj(x, y, tree_im(x, y), jit, jy=jy)
                    if green and hh < 16 and walk(x, y + 1): add_obj(x, y, spr(G.bush, h % 4), (h // 100) % 2 * 30 - 15, sh=False, depth=.7, jy=4)   # undergrowth at its foot
                continue
            if (x, y) in trod and (x, y) not in on: add_ov(x, y, spr(sc_trod, h % 6), .01)
            if rows[y][x] == ",":
                k = rough_of(x, y)
                if (x, y) not in on or k in ("clover", "flowers", "gravel", "tracks", "leaves"): add_ov(x, y, spr(ROUGH[k], h % 6), .3)
                continue
            if (x, y) in on or rows[y][x] not in ".": continue
            if zone(x, y) == "furrows": add_ov(x, y, spr(sc_furrows, (x * 3 + y) % 6), .02); continue
            # plain floor: scatter by what is next to it
            nb = [look.get((x + dx, y + dy)) or ("wall" if wall(x + dx, y + dy) else None) for dx in (-1, 0, 1) for dy in (-1, 0, 1)]
            r = h % 1000; road = any((x + dx, y + dy) in on for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            shore = any((x + dx, y + dy) in wet for dx in (-1, 0, 1) for dy in (-1, 0, 1))
            if land == "coast":
                if shore and r < 300: add_ov(x, y, spr(ROUGH["kelp"], h % 6), .05)
                elif shore and r < 520: add_ov(x, y, spr(sc_shells, h % 12), .1)
                elif r < 150: add_ov(x, y, spr(sc_shells, h % 12), .1)
                elif r < 270: add_ov(x, y, spr(sc_pebbles, h % 6), .1)
                elif r < 340: add_ov(x, y, spr(sc_tuft, h % 6), .2)
                elif r < 356: add_ov(x, y, spr(crab, h % 4), .3)
            elif land == "tundra":
                if "snowman" in nb and r < 400: add_ov(x, y, spr(ROUGH["tracks"], h % 3 * 2), .05)
                elif r < 130: add_ov(x, y, spr(sc_drygrass, h % 6), .2)
                elif r < 240: add_ov(x, y, spr(sc_sparkle, h % 8), .05)
                elif r < 310: add_ov(x, y, spr(sc_pebbles, h % 6), .1)
                elif r < 370: add_ov(x, y, spr(ROUGH["tracks"], h % 3 * 2), .05)
                elif r < 440: add_ov(x, y, spr(ROUGH["snowdrift"], h % 6), .1)
            elif look.get((x, y - 1)) in ("hedge", "topiary") and r < 600: add_ov(x, y, spr(sc_tulips, (x + y * 5) % 12), .12)
            elif "haybale" in nb and r < 520: add_ov(x, y, spr(sc_straw, h % 6), .1)
            elif ("apple" in nb or "berry" in nb) and r < 560: add_ov(x, y, spr(sc_apples, h % 6), .1)
            elif "maple" in nb and r < 600: add_ov(x, y, spr(sc_leaves, h % 6), .1)
            elif "wall" in nb and r < 150: add_ov(x, y, spr(sc_leaves, h % 6), .1)
            elif "wall" in nb and r < 230: add_ov(x, y, spr(sc_mushroom, h % 6), .2)
            elif "wall" in nb and r < 480: add_ov(x, y, spr(sc_fern, h % 6), .25)
            elif road and r < 300: add_ov(x, y, spr(sc_pebbles, h % 6), .1)
            elif road and r < 520: add_ov(x, y, spr(sc_tuft, h % 6), .2)
            elif land == "forest":
                if r < 200: add_ov(x, y, spr(sc_fern, h % 6), .25)
                elif r < 330: add_ov(x, y, spr(sc_leaves, h % 6), .1)
                elif r < 400: add_ov(x, y, spr(sc_mushroom, h % 6), .2)
                elif r < 460: add_ov(x, y, spr(sc_flowers, 2 + h % 2 * 6), .2)
                elif r < 490: add_ov(x, y, spr(sc_butterfly, h % 40), .9)
            elif r < 170: add_ov(x, y, spr(sc_flowers, h % 12), .2)
            elif r < 300: add_ov(x, y, spr(sc_tuft, h % 6), .2)
            elif r < 350: add_ov(x, y, spr(sc_pebbles, h % 6), .1)
            elif r < 385: add_ov(x, y, spr(sc_butterfly, h % 40), .9)
    # props: hints snap to the nearest free tile; then a few ambient ones for the land
    taken = set(on) | {c for c, _, _ in lms} | set(finds)
    def free(x, y, afloat): return ((x, y) in pond and (x, y) not in holes and inner(x, y)) if afloat else (walk(x, y) and (x, y) not in wet and (x, y) not in taken and inner(x, y) and zone(x, y) is None)
    def snap(x, y, afloat):
        best = sorted(((abs(cx - x) + abs(cy - y), cy, cx) for cy in range(Hh) for cx in range(W) if abs(cx - x) + abs(cy - y) <= 7 and free(cx, cy, afloat) and (cx, cy) not in taken))
        return (best[0][2], best[0][1]) if best else None
    props = list(rich.get("props", []))
    if rich.get("ambient", True):
        rnd = random.Random(f"amb{seed}"); cells = [(x, y) for y in range(2, Hh - 2) for x in range(2, W - 2) if free(x, y, False) and rows[y][x] == "." and not any((x + dx, y + dy) in on for dx in (-1, 0, 1) for dy in (-1, 0, 1))]
        rnd.shuffle(cells); props += [(k, c[0], c[1]) for k, c in zip(AMBIENT[land], cells)]
    for kind, x, y in props:
        c = snap(x, y, kind in AFLOAT)
        if c is None: continue
        x, y = c; taken.add(c); im = spr(PROPS[kind], crc(kind, x, y) % 8)
        if kind in TALL: add_obj(x, y, im, sh=False); shadow(x * T + 34, PAD + y * T + T - 4, False)
        else:
            if kind not in AFLOAT: shadow(x * T + 32, PAD + y * T + T - 8, False)
            add_ov(x, y, im, .45)
    for gt in s.get("gates", []):
        for gx, gy in gt["tiles"]:
            if (gx, gy) not in on: add_obj(gx, gy, spr(gatepost, 0), sh=False); shadow(gx * T + 34, PAD + gy * T + T - 4, False)
    for mb in s.get("extra_minibosses", []): add_ov(mb["x"], mb["y"], spr(sc_paw, 0), .02)
    for (x, y), name, jit in lms:
        im = G.landmark(name if name in G.LANDMARKS else f"{rid}-{name}"); cx, cy = x * T + 32 + jit, PAD + y * T + 60
        if (x, y) not in wet: G.ell(bp, cx + 4, cy, int(im.width * .36), 7, 1, tw, th); G.ell(bp, cx + 8, cy + 1, int(im.width * .24), 4, 1, tw, th)
        items.append((y + .6, x, im, cx - im.width // 2, PAD + y * T + 62 - im.height))
    for x, y, c in s.get("tokens", []):
        if c == "F": items.append((y + .45, x, G.find_spot(land), x * T, PAD + y * T))
        elif c == "E": add_obj(x, y, spr(pennant, 0), sh=False, depth=.2)
    if walker:
        gx, gy = line[min(3, len(line) - 1)]; gn = Image.open(os.path.join(REPO, "game/assets/img/trail/gnome.png")).convert("RGBA")
        shadow(gx * T + 30, PAD + gy * T + 46, False); items.append((gy + .5, gx, gn, gx * T, PAD + gy * T + 46 - 70))
    for _, _, im, ox, oy in sorted(items, key=lambda a: (a[0], a[1])):
        cl = im.crop((max(0, -ox), max(0, -oy), min(im.width, tw - ox), min(im.height, th - oy)))
        if cl.width > 0 and cl.height > 0: base.alpha_composite(cl, (max(ox, 0), max(oy, 0)))
    return base

def render_one(job):
    rid, si, out, cache = job
    from maplewold_rich_specs import rich_for
    route = json.load(open(os.path.join(REPO, "claude", "maplewold-bendy-maps", f"route-{rid}.json")))
    im = paint(route, si, rich_for(rid, si, route), cache); p = os.path.join(out, f"route-{rid}-s{si + 1}.png")
    im.convert("RGB").quantize(256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).save(p, optimize=True); return p

def contact(rid, out, dest):
    """All sections of a route side by side at 1/3 size (for a quick look)."""
    import glob
    ims = [Image.open(f).convert("RGB") for f in sorted(glob.glob(os.path.join(out, f"route-{rid}-s*.png")))]
    w, h = ims[0].width // 3, ims[0].height // 3; sh = Image.new("RGB", (len(ims) * (w + 6), h), (20, 20, 24))
    for i, im in enumerate(ims): sh.paste(im.resize((w, h), Image.LANCZOS), (i * (w + 6), 0))
    sh.save(dest); return dest

def sheet(path):
    cells = [haybale(i) for i in range(4)] + [fence(0), fence(1, True), fence(3, False, True), appletree(0), appletree(1), reeds(0), signpost(0)] + \
            [topiary(0), topiary(1)] + [fn(1) for fn in PROPS.values() if fn is not signpost] + [fn(i) for fn in ROUGH.values() for i in (0, 1)] + [fn(i) for fn in SCATTER.values() for i in (0, 1)] + [sc_flow(True, 0), sc_flow(False, 1)]
    n = 12; im = Image.new("RGBA", (n * 68, ((len(cells) + n - 1) // n) * 100), (118, 180, 90, 255))
    for i, c in enumerate(cells): im.alpha_composite(c, ((i % n) * 68 + 2, (i // n) * 100 + 98 - c.height))
    im = im.resize((im.width * 2, im.height * 2), Image.NEAREST); im.save(path); print(path)

def main():
    args = sys.argv[1:]; out = os.path.join(REPO, "claude", "maplewold-bendy-maps", "rich"); cache = None
    if "--out" in args: out = args[args.index("--out") + 1]
    if "--cache" in args: cache = args[args.index("--cache") + 1]; os.makedirs(cache, exist_ok=True)
    os.makedirs(out, exist_ok=True)
    if "--sheet" in args: return sheet(os.path.join(out, "decor-sheet.png"))
    import glob
    from multiprocessing import Pool
    ids = [int(a) for a in args if a.isdigit()] or sorted(int(os.path.basename(f)[6:9]) for f in glob.glob(os.path.join(REPO, "claude", "maplewold-bendy-maps", "route-???.json")))
    only = [int(a[1:]) - 1 for a in args if a.startswith("s") and a[1:].isdigit()]; jobs = []
    for rid in ids:
        n = len(json.load(open(os.path.join(REPO, "claude", "maplewold-bendy-maps", f"route-{rid}.json")))["sections"])
        jobs += [(rid, si, out, cache) for si in range(n) if not only or si in only]
    with Pool(min(8, os.cpu_count() or 2)) as pool:
        for p in pool.imap_unordered(render_one, jobs): print(p, flush=True)

if __name__ == "__main__": main()
