"""Hearth Pop v3 trail tiles: proposal generator. Hard pixels only, 64 px tiles, 3/4 top-down, light from the upper left.
Run: python3 -I gen.py <repo-root>   (reads the Maplewold maps and the v3 gnome/hedgehog models, writes PNGs next to itself)"""
import json, math, random, sys, os, zlib
from PIL import Image
ROOT = sys.argv[1]; OUT = os.path.dirname(os.path.abspath(__file__))
T = 64
def H(h): return tuple(int(h[i:i+2], 16) for i in (1, 3, 5)) + (255,)
INK = H("#2b1c26"); CREAM = H("#fff4d6")
RAMP = {  # hi base shade deep   (Hearth Pop 50 ramps + trail extras built with the guide recipe)
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
 "cream": [H(c) for c in ("#fffbe8", "#fff4d6", "#e8d9b4", "#b8a58a")],
}
STEP = {}  # colour -> (ramp, idx) so we can find the darker neighbour tone for contact shadows
for k, v in RAMP.items():
    for i, c in enumerate(v): STEP.setdefault(c, (k, i))
def darker(c, n=1):
    if c in STEP:
        k, i = STEP[c]; return RAMP[k][min(3, i + n)]
    return tuple(int(v * .78) for v in c[:3]) + (255,)

class Cv:
    def __init__(s, w, h): s.im = Image.new("RGBA", (w, h), (0, 0, 0, 0)); s.p = s.im.load(); s.w, s.h = w, h
    def put(s, x, y, c, wrap=False):
        if wrap: x %= s.w; y %= s.h
        if 0 <= x < s.w and 0 <= y < s.h: s.p[x, y] = c
    def get(s, x, y): return s.p[x, y] if 0 <= x < s.w and 0 <= y < s.h else (0, 0, 0, 0)
LIGHT = (-0.5, -0.6, 0.62)
def tone(d): return 0 if d > .72 else 1 if d > .30 else 2 if d > -.10 else 3
def shade_pt(nx, ny):
    nz = math.sqrt(max(0, 1 - nx * nx - ny * ny)); return nx * LIGHT[0] + ny * LIGHT[1] + nz * LIGHT[2]
def blob(cv, cx, cy, rx, ry, ramp, rnd, speck=.13, mask=None):
    """lit dome: per-pixel normal snapped to the 4-tone ramp, leaf-speckle flips one tone."""
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry
            if nx * nx + ny * ny > 1: continue
            t = tone(shade_pt(nx, ny))
            if rnd.random() < speck: t = max(0, min(3, t + rnd.choice((-1, 1))))
            cv.put(x, y, ramp[t])
def outline(cv, col=INK):
    src = cv.im.copy(); sp = src.load()
    for y in range(cv.h):
        for x in range(cv.w):
            if sp[x, y][3] == 0 and any(0 <= x+dx < cv.w and 0 <= y+dy < cv.h and sp[x+dx, y+dy][3] for dx, dy in ((1,0),(-1,0),(0,1),(0,-1))):
                cv.p[x, y] = col
def inner_lines(cv, rnd):  # 1 px darker-neighbour line where lit blob meets lower blob (kept light: speckle only)
    pass

# ---------------------------------------------------------------- ground tiles (full bleed, opaque, seamless via wrap)
LAND = {
 "grassland": dict(floor="moss", rough="leaf", wall="moss", base_floor=1),
 "forest":    dict(floor="wood", rough="leaf", wall="pine", base_floor=1),
 "coast":     dict(floor="sand", rough="sand", wall="stone", base_floor=1),
 "tundra":    dict(floor="snow", rough="snow", wall="pine", base_floor=1),
}
def ground(land, kind, seed):
    rnd = random.Random(f"{land}{kind}{seed}"); cv = Cv(T, T); L = LAND[land]
    ramp = RAMP[L["floor"] if kind != "rough" else L["rough"]]
    if land == "grassland" and kind == "floor": ramp = RAMP["moss"]
    if land == "forest" and kind == "floor": ramp = [H("#c9a06a"), H("#a0703f"), H("#7a4a33"), H("#4d2f2b")]  # leaf litter
    base = ramp[1]
    if land == "grassland" and kind == "rough": base = RAMP["leaf"][1]
    for y in range(T):
        for x in range(T): cv.p[x, y] = base
    def spot(n, mk):
        for _ in range(n): mk(rnd.randrange(T), rnd.randrange(T))
    # soft two-tone mottling (blobs of shade / hi, never a gradient)
    def mott(x, y):
        r = rnd.choice((2, 3, 3, 4)); c = ramp[2] if rnd.random() < .6 else ramp[0]
        for dy in range(-r, r + 1):
            for dx in range(-r, r + 1):
                if dx * dx + dy * dy <= r * r * .8 and rnd.random() < .85: cv.put(x + dx, y + dy, c, True)
    spot(6 if kind == "floor" else 4, mott)
    if kind == "rough":
        # tall tufts: each a lit blade fan (3 blades, hi tip, base, deep root)
        tuft_ramp = RAMP["moss"] if land != "tundra" else [H("#c6e0f0"), H("#8fb4d8"), H("#6a86bc"), H("#4a5c94")]
        if land == "coast": tuft_ramp = RAMP["moss"][:]; tuft_ramp = [H("#d8e48a"), H("#9cba58"), H("#5e8a4c"), H("#3a5c46")]
        if land == "forest": tuft_ramp = RAMP["moss"]
        def tuft(x, y):
            for i, (dx, h) in enumerate(((-2, 5), (0, 7), (2, 5))):
                for k in range(h):
                    cv.put(x + dx + (k // 4 if dx > 0 else -(k // 4) if dx < 0 else 0), y - k, tuft_ramp[0 if k > h - 3 else 1], True)
                cv.put(x + dx, y, tuft_ramp[3], True)
            cv.put(x + 1, y - 2, tuft_ramp[2], True)
        spot(9, tuft)
        if land in ("grassland", "forest"):
            fl = RAMP["petal"] if rnd.random() < .5 else RAMP["gold"]
            for _ in range(2):
                fx, fy = rnd.randrange(6, T - 6), rnd.randrange(6, T - 6)
                for dx, dy, c in ((0, 0, fl[1]), (-1, 0, fl[0]), (1, 0, fl[2]), (0, -1, fl[0]), (0, 1, fl[2]), (0, 0, CREAM)):
                    cv.put(fx + dx, fy + dy, c, True)
        if land == "coast":  # pebbles
            for _ in range(7):
                px, py = rnd.randrange(T), rnd.randrange(T); st = RAMP["stone"]
                cv.put(px, py, st[0], True); cv.put(px + 1, py, st[1], True); cv.put(px, py + 1, st[2], True); cv.put(px + 1, py + 1, st[3], True)
    else:
        # floor: flecks and tiny stones / leaves / ripples-in-sand / snow glints, each land its own
        def fleck(x, y): cv.put(x, y, ramp[0], True); cv.put(x + 1, y, ramp[0], True)
        def dot(x, y): cv.put(x, y, ramp[3], True)
        spot(10, fleck); spot(7, dot)
        if land == "grassland":
            for _ in range(5):
                x, y = rnd.randrange(T), rnd.randrange(T)
                for k in range(3): cv.put(x, y - k, RAMP["moss"][0] if k == 2 else RAMP["moss"][1], True)
        if land == "forest":
            for _ in range(4):  # little fallen leaves
                x, y = rnd.randrange(T), rnd.randrange(T); lf = rnd.choice((RAMP["ember"], RAMP["gold"]))
                cv.put(x, y, lf[1], True); cv.put(x + 1, y, lf[0], True); cv.put(x, y + 1, lf[2], True)
        if land == "coast":
            for _ in range(5):  # ripple lines in the sand
                x, y = rnd.randrange(T), rnd.randrange(T)
                for k in range(5): cv.put(x + k, y + (k % 2), ramp[2], True)
        if land == "tundra":
            for _ in range(3):
                x, y = rnd.randrange(T), rnd.randrange(T); cv.put(x, y, CREAM, True); cv.put(x + 1, y, CREAM, True); cv.put(x, y + 1, CREAM, True)
    return cv.im

def understory(land, seed):  # the ground beneath wall objects, darker than the walkable floor so edges read
    rnd = random.Random(f"under{land}{seed}")
    L = LAND[land]; src = ground(land, "floor", seed).copy(); p = src.load()
    for y in range(T):
        for x in range(T): p[x, y] = darker(p[x, y], 1)
    return src

# ---------------------------------------------------------------- raised objects (bottom aligned in a 64 x 96 canvas)
OBJ_H = 96
def tree(seed, ramp_name="leaf", trunk="wood", crown=1.0):
    rnd = random.Random(f"tree{seed}"); cv = Cv(T, OBJ_H); R = RAMP[ramp_name]
    # trunk (visible front: the 3/4 view shows the trunk below the crown)
    tw = 10
    for y in range(66, 90):
        for x in range(32 - tw // 2, 32 + tw // 2):
            u = (x - (32 - tw // 2)) / tw; t = 1 if u < .35 else 2 if u < .8 else 3
            if (y + x) % 7 == 0: t = min(3, t + 1)
            cv.put(x, y, RAMP[trunk][t])
    for x in range(26, 38): cv.put(x, 89, RAMP[trunk][3])
    # crown: three overlapping lit domes, the biggest at the back
    k = crown
    blob(cv, 32, 36, 30 * k, 29 * k, R, rnd)
    blob(cv, 20, 52, 17 * k, 15 * k, R, rnd); blob(cv, 45, 54, 17 * k, 14 * k, R, rnd)
    # underside of the crown over the trunk: deep ambient row
    for x in range(20, 46):
        for y in range(66, 72):
            if cv.get(x, y)[3] and y >= 68: cv.put(x, y, R[3])
    # berries / blossom: the quirk
    if seed % 3 == 0:
        for _ in range(4):
            bx, by = rnd.randrange(14, 50), rnd.randrange(26, 58)
            if cv.get(bx, by)[3]: cv.put(bx, by, RAMP["ember"][1]); cv.put(bx + 1, by - 1, CREAM)
    outline(cv); return cv.im
def bush(seed, ramp_name="moss"):
    rnd = random.Random(f"bush{seed}"); cv = Cv(T, OBJ_H); R = RAMP[ramp_name]
    blob(cv, 32, 72, 26, 17, R, rnd, .16); blob(cv, 20, 76, 15, 11, R, rnd, .16); blob(cv, 45, 77, 14, 10, R, rnd, .16)
    for y in range(86, 90):
        for x in range(8, 56):
            if cv.get(x, y)[3] and cv.get(x, y)[:3] != INK[:3] and y >= 87: cv.put(x, y, R[3])
    if seed % 2:
        for _ in range(5):
            bx, by = rnd.randrange(14, 50), rnd.randrange(64, 82)
            if cv.get(bx, by)[3]: f = RAMP["petal"]; cv.put(bx, by, f[1]); cv.put(bx - 1, by, f[0]); cv.put(bx, by - 1, f[0]); cv.put(bx + 1, by, f[2])
    outline(cv); return cv.im
def hedge(seed):
    rnd = random.Random(f"hedge{seed}"); cv = Cv(T, OBJ_H); R = RAMP["moss"]
    top, front = 58, 30   # top face 28 high, front face below it
    for y in range(58, 90):
        for x in range(2, 62):
            if y < 74:  # top face: lit, leaf speckle
                t = 0 if (y < 62 and x < 40) else 1
                t = max(0, min(3, t + (rnd.choice((-1, 1)) if rnd.random() < .22 else 0)))
            else:       # front face: shade side, deeper
                t = 2 if y < 84 else 3
                t = max(1, min(3, t + (rnd.choice((-1, 1)) if rnd.random() < .18 else 0)))
            cv.put(x, y, R[t])
    for y in range(58, 90):  # rounded corners: carve
        for x in range(2, 62):
            c = min(x - 2, 61 - x); r = max(0, 5 - c)
            if (y < 58 + r) or (y > 89 - r): cv.p[x, y] = (0, 0, 0, 0)
    for x in range(2, 62):  # lip where top meets front
        if cv.get(x, 74)[3]: cv.put(x, 74, R[2])
    outline(cv); return cv.im
def boulder(seed, ramp_name="stone", moss=False):
    rnd = random.Random(f"rock{seed}"); cv = Cv(T, OBJ_H); R = RAMP[ramp_name]
    cx, cy, rx, ry = 32, 74, 27, 20
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry
            if nx * nx + ny * ny > 1 + (rnd.random() - .5) * .06: continue
            d = shade_pt(nx * .9, ny * .9)
            # facet: a flat top plane lit hi, hard edge
            t = tone(d)
            if ny < -.35 and abs(nx) < .6: t = 0
            elif ny < -.35: t = min(t, 1)
            cv.put(x, y, R[t])
    for _ in range(2):  # crack
        x, y = rnd.randrange(24, 44), rnd.randrange(66, 76)
        for k in range(7): cv.put(x + (k % 3 == 0), y + k, R[3])
    if moss:
        for x in range(10, 36):
            for y in range(56, 64):
                if cv.get(x, y)[3] and rnd.random() < .5 and y < 60 + (x % 4): cv.put(x, y, RAMP["moss"][rnd.choice((0, 1))])
    for y in range(90, 94):
        for x in range(6, 58):
            if cv.get(x, y)[3] and y >= 91: cv.put(x, y, R[3])
    outline(cv); return cv.im
def pine(seed, snowy=True):
    rnd = random.Random(f"pine{seed}"); cv = Cv(T, OBJ_H); R = RAMP["pine"]; S = RAMP["snow"]
    for y in range(80, 90):
        for x in range(28, 36): cv.put(x, y, RAMP["wood"][1 if x < 31 else 2 if x < 34 else 3])
    tiers = [(8, 30, 3), (24, 44, 4), (42, 58, 5)]  # (top, bottom, extra half width)
    for i, (y0, y1, hw) in enumerate(((6, 38, 15), (24, 58, 21), (42, 80, 27))):
        for y in range(y0, y1):
            half = hw * (y - y0) / (y1 - y0 - 1) + 1
            for x in range(int(32 - half), int(32 + half) + 1):
                u = (x - (32 - half)) / (2 * half + .001)
                t = 0 if u < .22 else 1 if u < .55 else 2 if u < .85 else 3
                # snow cap on each tier's upper part
                if snowy and (y - y0) < (y1 - y0) * .42 - abs(x - 32) * .08 + rnd.random():
                    cv.put(x, y, S[0] if u < .45 else S[1] if u < .8 else S[2])
                else: cv.put(x, y, R[t])
        for x in range(int(32 - hw), int(32 + hw) + 1):  # drip edge: scalloped hem
            if (x * 3 + i) % 5 == 0 and cv.get(x, y1 - 1)[3]: cv.put(x, y1 - 1, R[3])
    outline(cv); return cv.im
def water(land, seed):  # flat, no object: calm sea / ice
    rnd = random.Random(f"water{land}{seed}"); cv = Cv(T, T)
    R = RAMP["sea"] if land != "tundra" else [H("#e8f6ff"), H("#bfe0f2"), H("#8ec0e6"), H("#6a94cc")]
    for y in range(T):
        for x in range(T): cv.p[x, y] = R[1] if land != "tundra" else R[1]
    for _ in range(14):  # ripple dashes: 2 hi, 1 shade under
        x, y = rnd.randrange(T), rnd.randrange(T); n = rnd.choice((3, 4, 5))
        for k in range(n): cv.put(x + k, y, R[0], True)
        for k in range(1, n): cv.put(x + k, y + 1, R[2], True)
    if land == "tundra":
        for _ in range(2):  # crack lines on ice
            x, y = rnd.randrange(6, 56), rnd.randrange(6, 56)
            for k in range(9): cv.put(x + k, y + (k * 2 // 3) % 4, R[3], True)
    return cv.im

# ---------------------------------------------------------------- the 2.5D sprite
def sprite(name, frame=0):
    im = Image.open(os.path.join(ROOT, "aseprite-source/v3/models", name)).convert("RGBA")
    return im.crop((frame * 64, 0, frame * 64 + 64, 80))

# ---------------------------------------------------------------- compose a section
def wall_obj(land, x, y, seed, n):
    h = zlib.crc32(f'{land}{x}{y}{seed}'.encode()) % 100
    if land == "grassland": return hedge(h % 3) if (x + y) % 3 == 0 else (tree(h % 6) if h % 5 else bush(h % 4))
    if land == "forest": return tree(h % 8, "pine" if h % 3 == 0 else "leaf") if h % 6 else boulder(h % 3, "stone", True)
    if land == "coast": return boulder(h % 5, "stone", False)
    return pine(h % 6) if h % 5 else boulder(h % 3, "stone", False)

def compose(land, rows, seed, player=None, extra=()):
    Hh = len(rows); W = len(rows[0]); pad = 40
    base = Image.new("RGBA", (W * T, Hh * T + pad), (0, 0, 0, 0))
    cache = {}
    def gt(kind, v):
        k = (kind, v)
        if k not in cache: cache[k] = ground(land, kind, v) if kind != "under" else understory(land, v)
        return cache[k]
    # 1. ground layer: floor, rough, understory under walls
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            v = (x * 7 + y * 13) % 4
            if c == "#":
                til = understory(land, v) if (land, "u", v) not in cache else cache[(land, "u", v)]
                cache[(land, "u", v)] = til
            elif c == ",": til = gt("rough", v % 2)
            else: til = gt("floor", v)
            base.paste(til, (x * T, pad + y * T))
    # top pad = understory colour
    for x in range(W):
        for yy in range(0, pad, T): base.paste(understory(land, x % 4).crop((0, T - pad, T, T)), (x * T, 0))
    # flat water / ice replaces objects
    flat = set()
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c != "#": continue
            if land == "coast" and y == 0: flat.add((x, y))
            if land == "tundra" and 1 <= x <= 9 and 1 <= y <= 5 and (rows[y][x-1] == "#" and 0 < x-1 or rows[y][x+1] == "#" and x+1 < W-1): flat.add((x, y))
    for (x, y) in flat: base.paste(water(land, (x * 3 + y) % 3), (x * T, pad + y * T))
    # 2. contact shadows of raised objects on neighbouring ground (lower-right), hard pixels, one tone darker
    bp = base.load()
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c != "#" or (x, y) in flat: continue
            for dx, dy in ((1, 0), (0, 1), (1, 1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < W and 0 <= ny < Hh and rows[ny][nx] != "#" or (ny >= Hh):
                    if ny >= Hh: continue
                    ox, oy = nx * T, pad + ny * T
                    for yy in range(T):
                        for xx in range(T):
                            if (dx == 1 and dy == 0 and xx < 14 and yy > 8 + xx // 2 and yy < T - 4) or (dx == 0 and dy == 1 and yy < 12 and xx > 6 and xx < T - 2 - yy) or (dx == 1 and dy == 1 and xx + yy < 14):
                                bp[ox + xx, oy + yy] = darker(bp[ox + xx, oy + yy])
    # 3. depth-sorted: wall objects and sprites by feet row
    items = []
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c == "#" and (x, y) not in flat:
                jit = ((zlib.crc32(f'j{x}{y}{seed}'.encode()) % 7) - 3) if land != "coast" else 0
                items.append((y + .5, x, wall_obj(land, x, y, seed, len(rows[0])), x * T + jit - 0, pad + y * T + T - OBJ_H + 12))
    if player:
        for (px, py, spr) in [player] + list(extra):
            items.append((py + .5 + .01, px, spr, px * T, pad + py * T + 46 - 70))   # feet baseline y=70 -> 46 px into the tile
    items.sort(key=lambda a: (a[0], a[1]))
    for _, _, im, ox, oy in items: base.alpha_composite(im, (ox, oy)) if ox >= 0 and oy >= 0 and ox + im.width <= base.width else base.alpha_composite(im.crop((max(0, -ox), max(0, -oy), min(im.width, base.width - ox), im.height)), (max(ox, 0), max(oy, 0)))
    return base, pad

def main():
    maps = json.load(open(os.path.join(OUT, "../maplewold-trail-maps/maplewold_trail_maps.json")))
    by = {r["route_id"]: r for r in maps}
    scenes = [("grassland", 228, 0, (1, 3)), ("forest", 304, 0, (1, 3)), ("coast", 307, 0, (2, 3)), ("tundra", 309, 0, (1, 3))]
    npc = sprite("npc-hedgehog.png", 0)
    out = {}
    for land, rid, si, _ in scenes:
        rows = by[rid]["sections"][si]["rows"]
        plain = ["".join("." if c in "S9EF" else c for c in r) for r in rows]
        # player: first floor tile with a wall directly to its south and floor to its west
        spots = [(x, y) for y in range(1, 6) for x in range(2, 9) if rows[y][x] in ".," and rows[y + 1][x] == "#"]
        px, py = spots[len(spots) // 2]
        g = sprite("gnome-player.png", 0)
        img, pad = compose(land, plain, rid, (px, py, g), extra=[(0, [y for y in range(7) if rows[y][0] == "S"][0], npc)] if False else [])
        img.save(os.path.join(OUT, f"scene-{land}.png")); out[land] = dict(route=rid, w=img.width, h=img.height, pad=pad, player=[px, py], rows=rows)
    # tile sheet per land
    sheet = Image.new("RGBA", (T * 10 + 9 * 6 + 12, (OBJ_H + 8) * 4 + 4 * 0 + 12 * 1), (58, 52, 70, 255)); sy = 6
    for land in LAND:
        x = 6
        for kind, v in (("floor", 0), ("floor", 1), ("floor", 2), ("floor", 3), ("rough", 0), ("rough", 1)):
            sheet.paste(ground(land, kind, v), (x, sy + OBJ_H - T)); x += T + 6
        objs = {"grassland": [hedge(0), tree(1), bush(1)], "forest": [tree(2, "pine"), tree(3), boulder(0, "stone", True)], "coast": [boulder(0), boulder(1), water(land, 0)], "tundra": [pine(0), pine(1), water(land, 0)]}[land]
        for o in objs[:3]:
            if o.height == T: sheet.paste(o, (x, sy + OBJ_H - T))
            else: sheet.alpha_composite(o, (x, sy))
            x += T + 6
        sy += OBJ_H + 8
    sheet.save(os.path.join(OUT, "tile-sheet.png"))
    json.dump(out, open(os.path.join(OUT, "scenes.json"), "w"))
main()
