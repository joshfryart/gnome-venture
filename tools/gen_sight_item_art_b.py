"""Item pictures (Hearth Pop v3) for rows 22-42 of game/includes/data/trail_sight_items.txt.
64 x 64 RGBA, hard pixels, 5-tone ramps lit from the top-left, 1 px ink outline, soft translucent ground shadow.
Deterministic and re-runnable.  Run from anywhere:  python3 tools/gen_sight_item_art_b.py [slug ...]"""
import math, os, random, sys
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "claude", "tile-art-v3-proposal"))
import gen2  # noqa: E402
from gen2 import RAMP, INK, CREAM, r5, Cv, lump, outline, H, mix  # noqa: E402

OUT = os.path.join(ROOT, "game", "assets", "img", "ph")
S = 64
CLEAR = (0, 0, 0, 0)

# ------------------------------------------------------------------ ramps (5 tones, light -> dark)
R = {k: r5(v) for k, v in RAMP.items()}
def ramp(*hexes): return [H(h) for h in hexes]
CREAMR = ramp("#fffaf0", "#fff0cf", "#eed6a6", "#c9a77e", "#8a6656")
BRONZE = ramp("#ffd9a0", "#e8a660", "#c07a3e", "#8d4f2c", "#56302a")
PAPER = ramp("#fffbef", "#fbf0d2", "#efdcb2", "#d2b88e", "#9c7e66")
PEBBLE = ramp("#efe6d6", "#cdbfa8", "#a8977f", "#7b6b5d", "#4f4547")
BLUEST = ramp("#e4ecf6", "#b9c8dc", "#8ea3c0", "#66789c", "#424b6c")
GLASS = ramp("#fffbe6", "#fbe8b4", "#efc982", "#c99257", "#83573e")
WILLOW = [ramp("#e4e07a", "#b8b84a", "#7f8634"), ramp("#d9b064", "#b07a3c", "#7c4f2c"),
          ramp("#c9d870", "#8fae48", "#5d7c38"), ramp("#e09a6a", "#b4603e", "#7a3a30")]
WHITE = H("#ffffff")


# ------------------------------------------------------------------ raster helpers
def fm(cv, drawfn, fn):
    m = Image.new("L", cv.im.size, 0); drawfn(ImageDraw.Draw(m)); bb = m.getbbox()
    if not bb: return
    mp = m.load()
    for y in range(bb[1], bb[3]):
        for x in range(bb[0], bb[2]):
            if mp[x, y]:
                c = fn(x, y, bb)
                if c is not None: cv.put(x, y, c)

def poly(cv, pts, c): fm(cv, lambda d: d.polygon(pts, fill=255), lambda x, y, b: c)
def ell(cv, cx, cy, rx, ry, c): fm(cv, lambda d: d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=255), lambda x, y, b: c)
def rect(cv, x0, y0, x1, y1, c):
    for y in range(y0, y1):
        for x in range(x0, x1): cv.put(x, y, c)
def line(cv, x0, y0, x1, y1, c, w=1):
    n = int(max(abs(x1 - x0), abs(y1 - y0), 1))
    for i in range(n + 1):
        x = x0 + (x1 - x0) * i / n; y = y0 + (y1 - y0) * i / n
        for dx in range(w):
            for dy in range(w): cv.put(int(round(x)) + dx - w // 2, int(round(y)) + dy - w // 2, c)
def clear(cv, x, y): cv.put(x, y, CLEAR)

def tone(d, bands=(.18, .40, .66, .86)):
    return 0 if d < bands[0] else 1 if d < bands[1] else 2 if d < bands[2] else 3 if d < bands[3] else 4

def gshade(Rm, lx=1.0, ly=1.0, bands=(.18, .40, .66, .86)):
    """colour fn: tone by position across the mask bbox along the light direction (top-left lit)."""
    def f(x, y, b):
        u = (x - b[0]) / max(1, b[2] - b[0] - 1); v = (y - b[1]) / max(1, b[3] - b[1] - 1)
        return Rm[tone((u * lx + v * ly) / (lx + ly), bands)]
    return f
def gpoly(cv, pts, Rm, **k): fm(cv, lambda d: d.polygon(pts, fill=255), gshade(Rm, **k))
def gell(cv, cx, cy, rx, ry, Rm, **k): fm(cv, lambda d: d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=255), gshade(Rm, **k))

def rot(pts, fr):
    cx, cy, a = fr; ca, sa = math.cos(math.radians(a)), math.sin(math.radians(a))
    return [(cx + x * ca - y * sa, cy + x * sa + y * ca) for x, y in pts]
def unrot(x, y, fr):
    cx, cy, a = fr; ca, sa = math.cos(math.radians(a)), math.sin(math.radians(a)); dx, dy = x + .5 - cx, y + .5 - cy
    return dx * ca + dy * sa, -dx * sa + dy * ca
def lpoly(cv, pts, fr, fn):
    """polygon given in local coords of frame fr=(cx,cy,deg); fn(lx,ly) -> colour."""
    fm(cv, lambda d: d.polygon(rot(pts, fr), fill=255), lambda x, y, b: fn(*unrot(x, y, fr)))

def ilump(cv, cx, cy, rx, ry, Rm):
    """recessed (inverted) shaded ellipse: dark top-left, light bottom-right."""
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry
            if nx * nx + ny * ny <= 1: cv.put(x, y, Rm[gen2.tone5(gen2.shade_pt(-nx * .8, -ny * .8))])

def star(cv, x, y, c, big=False):
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)): cv.put(x + dx, y + dy, c)
    if big:
        for dx, dy in ((2, 0), (-2, 0), (0, 2), (0, -2)): cv.put(x + dx, y + dy, c)

def arc(cv, cx, cy, r, a0, a1, c, w=1):
    n = max(8, int(abs(a1 - a0) / 360 * 2 * math.pi * r * 3))
    for i in range(n + 1):
        a = math.radians(a0 + (a1 - a0) * i / n)
        for k in range(w):
            cv.put(int(round(cx + (r + k) * math.cos(a))), int(round(cy + (r + k) * math.sin(a))), c)

def bez(p0, p1, p2, t):
    return ((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0], (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1])

def overlay(cv, drawfn):
    """draw onto a fresh layer, give it its own ink outline, stamp it over cv (for floating bits)."""
    t = Cv(S, S); drawfn(t); outline(t)
    tp = t.im.load()
    for y in range(S):
        for x in range(S):
            if tp[x, y][3]: cv.put(x, y, tp[x, y])

def drop(cv, x, y, Rm):
    """small water/resin drop, 3 x 4."""
    cv.put(x, y, Rm[1]); cv.put(x - 1, y + 1, Rm[0]); cv.put(x, y + 1, Rm[1]); cv.put(x + 1, y + 1, Rm[2])
    cv.put(x - 1, y + 2, Rm[1]); cv.put(x, y + 2, Rm[2]); cv.put(x + 1, y + 2, Rm[3]); cv.put(x, y + 3, Rm[3])


# ------------------------------------------------------------------ items
def d_squirrels_spare_key(cv, rnd):
    G = R["gold"]; fr = (24, 18, 45)
    def sh(lx, ly): return G[tone((-ly + 3) / 6, (.15, .35, .62, .86))]
    lpoly(cv, [(6, -2.6), (35, -2.6), (35, 2.6), (6, 2.6)], fr, sh)                       # shaft
    lpoly(cv, [(23, 2), (28, 2), (28, 9), (23, 9)], fr, lambda lx, ly: G[2 if lx < 26 else 3])  # teeth
    lpoly(cv, [(30, 2), (35, 2), (35, 7), (30, 7)], fr, lambda lx, ly: G[2 if lx < 33 else 3])
    lpoly(cv, [(34, -3.6), (37, -3.6), (37, 3.6), (34, 3.6)], fr, lambda lx, ly: G[1 if ly < 0 else 3])  # tip collar
    lump(cv, 24, 18, 10.5, 10.5, G, rnd, 0)                                                 # bow ring
    ilump(cv, 24, 18, 6.5, 6.5, G)
    ell(cv, 24, 18, 3.6, 3.6, CLEAR)
    for i in range(3):                                                                      # collar rings
        lpoly(cv, [(9 + i * 3, -3.4), (10 + i * 3, -3.4), (10 + i * 3, 3.4), (9 + i * 3, 3.4)], fr, lambda lx, ly: G[3])
    # string + acorn charm hanging off the bow
    for (x, y) in ((16, 25), (15, 27), (15, 29), (14, 31), (14, 33)): cv.put(x, y, R["ember"][1]); cv.put(x + 1, y, R["ember"][2])
    W = R["litter"]
    lump(cv, 15, 43, 6, 7, R["gold"][1:] + [R["gold"][4]], rnd, 0)                          # nut
    for x in range(8, 23):                                                                   # cap
        for y in range(34, 40):
            nx, ny = (x + .5 - 15) / 7.5, (y + .5 - 39) / 5
            if nx * nx + ny * ny <= 1 or (y >= 38 and abs(x + .5 - 15) < 7.4):
                c = W[tone((x - 8) / 15 * .6 + (y - 34) / 6 * .4)]
                if (x + y) % 3 == 0: c = W[min(4, tone((x - 8) / 15 * .6 + (y - 34) / 6 * .4) + 1)]
                cv.put(x, y, c)
    cv.put(15, 33, W[3]); cv.put(15, 32, W[2])
    for x in range(10, 21): cv.put(x, 40, W[4])
    def post(cv):
        star(cv, 46, 12, CREAM); cv.put(19, 14, CREAM); cv.put(20, 13, CREAM)
    return dict(post=post)


def d_toadstool_stool(cv, rnd):
    C = CREAMR; E = R["ember"]
    for y in range(30, 55):                                                                  # stem, flared foot
        fl = max(0, y - 49)
        x0, x1 = 24 - fl, 40 + fl
        for x in range(x0, x1):
            u = (x - x0) / (x1 - x0 - 1); t = 0 if u < .12 else 1 if u < .38 else 2 if u < .72 else 3
            if (x * 5 + y * 3) % 17 == 0: t = min(4, t + 1)
            cv.put(x, y, C[t])
    for x in range(22, 42): cv.put(x, 54, C[4])
    for y in range(36, 52, 4): cv.put(27, y, C[2]); cv.put(36, y + 2, C[3])
    # cap: a squashed dome with a flat sitting top
    for y in range(12, 35):
        for x in range(4, 61):
            nx, ny = (x + .5 - 32) / 27.5, (y + .5 - 32) / 19
            if nx * nx + ny * ny > 1 or y < 15 or y > 32: continue
            t = gen2.tone5(gen2.shade_pt(nx * .9, min(ny, .2) * .9 - .25)) if y > 15 else 1
            cv.put(x, y, E[t])
    for x in range(10, 55):                                                                  # flat seat top, lit
        nx = (x + .5 - 32) / 23
        if abs(nx) < 1: cv.put(x, 15, E[0] if nx < .4 else E[1])
    for x in range(6, 59):                                                                   # gills band under the rim
        for y in range(31, 36):
            nx, ny = (x + .5 - 32) / 26.5, (y + .5 - 32) / 3.4
            if nx * nx + ny * ny <= 1 and y >= 32: cv.put(x, y, C[3] if (x % 3) else C[4])
    for x in range(5, 60):
        if cv.get(x, 31)[3] and abs(x - 32) < 27: cv.put(x, 31, E[4])
    for (cx, cy, rx, ry) in ((32, 21, 4.5, 3), (18, 22, 3.5, 2.6), (46, 23, 3.5, 2.6), (24, 28, 2.6, 1.8),
                             (40, 28, 2.8, 1.8), (10, 28, 1.8, 1.6), (54, 29, 1.6, 1.4), (38, 17, 2, 1.2), (24, 17, 1.6, 1.2)):
        gell(cv, cx, cy, rx, ry, CREAMR, bands=(.3, .55, .8, .97))
    # tiny grass tufts at the foot
    M = R["moss"]
    for bx, h in ((17, 5), (19, 7), (21, 4), (44, 6), (46, 4), (42, 3)):
        for k in range(h): cv.put(bx + (1 if k > h - 3 and bx < 30 else -1 if k > h - 3 else 0), 54 - k, M[0] if k > h - 2 else M[2])
    return {}


def d_brass_button(cv, rnd):
    G = R["gold"]
    lump(cv, 32, 32, 21, 21, G, rnd, 0)
    ilump(cv, 32, 32, 15.5, 15.5, G)
    lump(cv, 32, 32, 13, 13, [G[0], G[1], G[1], G[2], G[3]], rnd, 0)
    # four thread holes with red thread crossing them
    holes = ((27, 27), (36, 27), (27, 36), (36, 36))
    T = R["ember"]
    line(cv, 28, 28, 37, 37, T[1], 2); line(cv, 37, 28, 28, 37, T[2], 2)
    for hx, hy in holes:
        rect(cv, hx, hy, hx + 2, hy + 2, INK); cv.put(hx + 2, hy + 1, G[0]); cv.put(hx + 1, hy + 2, G[0])
    cv.put(32, 32, T[0]); cv.put(31, 31, T[0])
    # worn shine + gull pecks
    for (x, y) in ((20, 22), (21, 21), (22, 20), (19, 24), (24, 19)): cv.put(x, y, CREAM)
    for (x, y) in ((44, 23), (46, 27), (43, 29)): cv.put(x, y, G[4]); cv.put(x + 1, y + 1, G[1])
    # loose thread tail
    for i, (x, y) in enumerate(((38, 38), (40, 41), (42, 44), (43, 47), (45, 49), (48, 50), (50, 50))):
        cv.put(x, y, T[1]); cv.put(x + 1, y, T[2])
    return {}


def d_teeny_axe(cv, rnd):
    fr = (31, 33, 24); W = R["wood"]; St = R["stone"]
    def hnd(lx, ly):
        t = 0 if lx < -1.6 else 1 if lx < -.2 else 2 if lx < 1.2 else 3
        if int(ly) % 7 == 0: t = min(4, t + 1)
        return W[t]
    lpoly(cv, [(-2.5, -17), (2.5, -17), (2.8, 17), (4.5, 20), (4, 23), (-3.5, 23), (-3, 17)], fr, hnd)
    lpoly(cv, [(-2.5, 9), (2.6, 9), (2.6, 12), (-2.5, 12)], fr, lambda lx, ly: R["ember"][1 if lx < 0 else 3])  # grip wrap
    # head (steel), bearded blade on the right, poll on the left
    def head(lx, ly):
        if lx > 15.5: return R["ice"][0] if ly < -12 else R["ice"][1]
        return St[tone(((lx + 7) / 24) * .35 + ((ly + 26) / 22) * .65)]
    lpoly(cv, [(-7, -20), (2, -21), (11, -24), (17, -27), (19, -18), (18, -8), (12, -8), (7, -12), (2, -12), (-7, -13)], fr, head)
    lpoly(cv, [(-7, -20), (-5, -20), (-5, -13), (-7, -13)], fr, lambda lx, ly: St[3])
    # happy face on the blade
    for (lx, ly, c) in ((7, -19, INK), (7, -18, INK), (12, -20, INK), (12, -19, INK)):
        x, y = rot([(lx, ly)], fr)[0]; cv.put(int(x), int(y), c)
    for lx in range(7, 13):
        ly = -13.6 - .22 * (lx - 9.5) ** 2
        x, y = rot([(lx, ly)], fr)[0]; cv.put(int(x), int(y), INK)
    for (lx, ly) in ((5, -16), (14, -17)):
        x, y = rot([(lx, ly)], fr)[0]; cv.put(int(x), int(y), R["petal"][1])
    def post(cv):
        for (x, y) in ((14, 50), (50, 50), (12, 46)):
            cv.put(x, y, W[0]); cv.put(x + 1, y, W[1]); cv.put(x + 1, y + 1, W[2])
        star(cv, 55, 9, CREAM); cv.put(50, 4, CREAM)
    return dict(post=post)


def d_mudskipper_medal(cv, rnd):
    M = R["moss"]; L = R["litter"]
    # V ribbon: two straps from a top bar down behind the medal
    def strap(lx, ly):
        return (M[1] if lx < 2 else M[2]) if (int(lx) // 3) % 2 == 0 else (L[1] if lx < 4 else L[2])
    lpoly(cv, [(0, 0), (11, 0), (11, 26), (0, 26)], (17, 6, -22), strap)
    lpoly(cv, [(0, 0), (11, 0), (11, 26), (0, 26)], (37, 2, 22), strap)
    for y in range(0, 6):
        for x in range(S): clear(cv, x, y)
    rect(cv, 17, 6, 47, 11, R["gold"][2]); rect(cv, 17, 6, 47, 8, R["gold"][1]); rect(cv, 17, 10, 47, 11, R["gold"][3])
    for x in (17, 46): cv.put(x, 7, R["gold"][0])
    # bronze medal
    B = BRONZE
    lump(cv, 32, 39, 15.5, 15.5, B, rnd, 0)
    ilump(cv, 32, 39, 12, 12, B)
    lump(cv, 32, 39, 10.5, 10.5, [B[2], B[2], B[2], B[3], B[3]], rnd, 0)
    # embossed mudskipper: a raised fish with a sunken rim, popped-up eyes, spiky back fin
    fish = Cv(S, S); Gd = R["gold"]
    ell(fish, 31, 41, 6.5, 2.6, Gd[0]); ell(fish, 27, 40.5, 3.4, 3, Gd[0])
    poly(fish, [(36, 41), (40, 37.5), (39.5, 41), (40, 44.5)], Gd[0])
    for x in (30, 33): poly(fish, [(x, 39), (x + 1, 36.5), (x + 2.5, 39)], Gd[0])
    ell(fish, 25.5, 37, 1.6, 1.6, Gd[0]); ell(fish, 28.5, 37, 1.6, 1.6, Gd[0])
    fp = fish.im.load()
    for y in range(S):
        for x in range(S):
            if fp[x, y][3]:
                cv.put(x, y, Gd[0] if not fish.get(x, y - 1)[3] or not fish.get(x - 1, y)[3] else Gd[1] if fish.get(x + 1, y + 1)[3] else Gd[2])
            elif any(fish.get(x + dx, y + dy)[3] for dx, dy in ((-1, 0), (0, -1), (-1, -1), (1, 0), (0, 1))): cv.put(x, y, B[4])
    cv.put(25, 37, INK); cv.put(28, 37, INK)
    cv.put(24, 41, Gd[3]); cv.put(25, 42, Gd[3]); cv.put(26, 42, Gd[3])                       # grin
    cv.put(30, 44, Gd[2]); cv.put(29, 45, Gd[2])                                             # fin
    def post(cv): star(cv, 49, 28, CREAM)
    return dict(post=post)


def d_willow_withies(cv, rnd):
    A, C, Bz = (12, 50), (52, 12), (27, 23)   # bundle spine: bowed curve
    strands = []
    for k in range(-4, 5):
        strands.append((k, WILLOW[(k + 4) % 4], rnd.uniform(-1.2, 1.2), rnd.uniform(.0, .06)))
    for k, Wc, wob, trim in sorted(strands, key=lambda s: s[0]):
        pts = []
        for i in range(160):
            t = trim + (1 - trim - (.03 if k % 3 == 0 else 0)) * i / 159
            x, y = bez(A, Bz, C, t)
            tx, ty = bez(A, Bz, C, min(1, t + .01)); dx, dy = tx - x, ty - y; n = math.hypot(dx, dy) or 1
            px, py = dy / n, -dx / n                     # perpendicular (down-right side positive)
            spread = 1.55 + 2.4 * abs(t - .52) ** 1.6 * 4 + (wob * math.sin(t * 9) if abs(t - .52) > .15 else 0)
            off = k * spread
            pts.append((x + px * off, y + py * off))
        for x, y in pts:
            xi, yi = int(round(x)), int(round(y))
            cv.put(xi, yi, Wc[0]); cv.put(xi + 1, yi, Wc[1]); cv.put(xi, yi + 1, Wc[1]); cv.put(xi + 1, yi + 1, Wc[2])
    # twine binding round the middle
    S_ = R["sand"]
    cx, cy = bez(A, Bz, C, .52)
    G = R["gold"]
    for j in range(3):
        lpoly(cv, [(-1.1, -12), (1.1, -12), (1.1, 12), (-1.1, 12)], (cx - 3.5 + j * 3.2, cy + 4.5 - j * 3.2, 42),
              lambda lx, ly: (G[0] if ly < -4 else G[1] if ly < 4 else G[2]) if lx < .1 else G[3])
    # a few narrow willow leaves near the tips
    Lf = R["leaf"]
    for (x, y, a) in ((48, 10, -30), (54, 17, 20), (45, 16, -60)):
        lpoly(cv, [(0, -1.5), (5, -1.2), (8, 0), (5, 1.4), (0, 1.5)], (x, y, a), lambda lx, ly: Lf[1] if ly < 0 else Lf[2])
    return {}


def d_icicle_chime(cv, rnd):
    W = R["wood"]; I = R["ice"]
    # twig
    for x in range(8, 57):
        y = 14 + int(round(1.6 * math.sin((x - 8) / 48 * math.pi)))
        for dy, t in ((0, 1), (1, 2), (2, 3)): cv.put(x, y + dy, W[t])
        if x % 9 == 0: cv.put(x, y + 1, W[3])
    for (x, y) in ((54, 12), (55, 11), (56, 10)): cv.put(x, y, W[2]); cv.put(x, y + 1, W[3])
    Lf = R["leaf"]; poly(cv, [(56, 9), (59, 5), (61, 7), (58, 10)], Lf[1]); cv.put(58, 9, Lf[2]); cv.put(60, 7, Lf[0])
    rect(cv, 6, 15, 9, 17, W[3]); cv.put(7, 15, W[0])
    lens = [(15, 18, 5), (23, 27, 6), (32, 36, 7), (41, 26, 6), (49, 18, 5)]
    tops = []
    for (x, L, w) in lens:
        y0 = 14 + int(round(1.6 * math.sin((x - 8) / 48 * math.pi))) + 6
        tops.append((x, y0))
        pts = [(x - w / 2, y0), (x + w / 2, y0), (x + 1, y0 + L * .7), (x + .4, y0 + L), (x - .6, y0 + L * .75)]
        gpoly(cv, pts, I, lx=1, ly=.15, bands=(.22, .48, .72, .9))
        for dy in range(1, int(L * .55)): cv.put(int(x - w / 2 + 1), y0 + dy, CREAM if dy < 3 else I[0])
        rect(cv, int(x - w / 2), y0, int(x + w / 2) + 1, y0 + 2, I[1])                     # frosty collar
        cv.put(int(x - w / 2), y0, CREAM)
    def post(cv):
        for (x, y0) in tops:                                                               # threads
            ty = 14 + int(round(1.6 * math.sin((x - 8) / 48 * math.pi))) + 3
            for y in range(ty, y0 - 1): cv.put(x, y, INK)
        for x in range(9, 33): cv.put(x, 13 - int((x - 9) / 24 * 9), INK)                 # hanging loop
        for x in range(32, 55): cv.put(x, 4 + int((x - 32) / 23 * 9), INK)
        star(cv, 56, 32, CREAM); star(cv, 9, 38, CREAM); cv.put(27, 50, CREAM); cv.put(46, 49, I[0])
    return dict(post=post, shadow=(32, 58, 17, 2.5))


def d_bog_pressed_bookmark(cv, rnd):
    L = R["litter"]
    pts = [(21, 9), (43, 9), (43, 55), (32, 49), (21, 55)]
    gpoly(cv, pts, [L[0], L[1], L[1], L[2], L[3]], lx=1, ly=.4)
    for (x, y) in ((21, 9), (42, 9)): clear(cv, x, y)
    for y in range(10, 52, 3):                                                             # peat grain
        for x in range(22, 43):
            if (x * 7 + y * 5) % 11 == 0 and cv.get(x, y)[3]: cv.put(x, y, L[3])
    # pale pressed panel
    P = PAPER
    gpoly(cv, [(25, 16), (39, 16), (39, 45), (25, 45)], [P[1], P[2], P[2], P[3], P[3]])
    for x in range(25, 40): cv.put(x, 45, L[3])
    for y in range(16, 46): cv.put(39, y, L[3])
    # punched hole + tassel
    rect(cv, 31, 11, 33, 13, INK)
    # pressed flower: flat, two-tone (it has been squashed for a hundred years)
    Gq = ramp("#b9c27a", "#8b9a52", "#62733e")
    for y in range(30, 45): cv.put(32, y, Gq[1]); cv.put(33, y, Gq[2])
    poly(cv, [(32, 38), (27, 35), (26, 36), (31, 40)], Gq[0]); poly(cv, [(33, 41), (37, 38), (38, 39), (34, 43)], Gq[1])
    Pt = ramp("#ffd0de", "#f29ab4", "#c96a8c")
    for i in range(5):
        a = math.radians(-90 + i * 72); px, py = 32.5 + 5 * math.cos(a), 25 + 5 * math.sin(a)
        ell(cv, px, py, 3.2, 3.2, Pt[1] if math.cos(a) + math.sin(a) < .3 else Pt[2])
        cv.put(int(px - 1), int(py - 1), Pt[0])
    ell(cv, 32.5, 25, 2, 2, R["gold"][1]); cv.put(32, 24, R["gold"][0]); cv.put(33, 26, R["gold"][3])
    def post(cv):
        G = R["gold"]                                                                      # tassel string over the top
        for (x, y) in ((31, 10), (30, 8), (29, 6), (27, 5), (25, 5), (23, 6), (21, 8), (19, 11)): cv.put(x, y, G[2])
        for dx in range(-1, 2):
            for y in range(12, 19): cv.put(19 + dx, y, G[1] if dx < 1 else G[3])
        rect(cv, 18, 11, 21, 13, G[3]); cv.put(18, 11, G[0])
        for (x, y) in ((47, 18), (48, 17), (49, 18), (50, 19), (51, 18), (52, 17), (48, 23), (49, 22), (50, 23), (51, 24), (52, 23)):
            cv.put(x, y, R["petal"][1])                                                     # faint summer smell
    return dict(post=post)


def d_herons_programme_notes(cv, rnd):
    P = PAPER
    # back panel peeking out (tri-fold), then the front cover
    gpoly(cv, [(42, 12), (51, 9), (51, 50), (42, 53)], [P[2], P[3], P[3], P[4], P[4]])
    for y in range(10, 51, 5): cv.put(46, y + 2, P[2]); cv.put(47, y + 2, P[2])
    front = [(13, 10), (42, 12), (42, 53), (36, 51), (30, 53), (24, 51), (18, 53), (13, 51)]
    gpoly(cv, front, P[:4] + [P[3]], lx=1, ly=.7)
    # title lines
    rect(cv, 17, 15, 37, 17, R["dusk"][2]); rect(cv, 17, 15, 37, 16, R["dusk"][1])
    rect(cv, 19, 19, 34, 20, P[3])
    # the heron, standing very still on one leg
    Hn = ramp("#e8eef6", "#b9c4d8", "#8a96b4", "#5f6a8c", "#3d4566")
    ell(cv, 27, 32, 5.5, 3.6, Hn[2]); ell(cv, 26, 31, 4, 2.4, Hn[1]); cv.put(24, 30, Hn[0])
    for (x, y) in ((31, 30), (32, 29), (33, 28), (33, 27), (32, 26), (32, 25), (33, 24)): cv.put(x, y, Hn[3]); cv.put(x - 1, y, Hn[2])
    ell(cv, 34, 23.5, 2, 1.6, Hn[1]); cv.put(34, 23, INK)
    line(cv, 36, 24, 39, 25, R["gold"][2])
    cv.put(21, 31, Hn[3]); cv.put(20, 32, Hn[3])
    for y in range(35, 43): cv.put(27, y, R["gold"][3])
    line(cv, 27, 38, 30, 37, R["gold"][3]); line(cv, 30, 37, 29, 40, R["gold"][3])
    for x in range(20, 36, 2): cv.put(x, 43, R["sea"][2]); cv.put(x + 1, 44, R["sea"][2])
    # soggy stain creeping up from the bottom
    Sg = ramp("#d8e6e4", "#b7cfd4", "#94b2c0")
    for y in range(40, 54):
        for x in range(13, 43):
            c = cv.get(x, y)
            if c[3] and c in (P[0], P[1], P[2], P[3]):
                edge = 47 - 2.5 * math.sin(x / 3.1) - (x - 13) * .12
                if y > edge: cv.put(x, y, Sg[0] if y < edge + 2 else Sg[1] if c != P[3] else Sg[2])
    def post(cv):
        drop(cv, 20, 56, R["sea"]); drop(cv, 36, 55, R["sea"]); cv.put(28, 57, R["sea"][1])
    return dict(post=post, shadow=(32, 55, 17, 2.5))


def d_pine_snow_cone(cv, rnd):
    # paper cup (striped)
    for y in range(38, 58):
        hw = (57 - y) * 13 / 19
        for x in range(int(32 - hw), int(32 + hw) + 1):
            stripe = ((x + y) // 4) % 2
            u = (x - (32 - hw)) / max(1, 2 * hw)
            base = (R["ember"] if stripe else CREAMR)
            cv.put(x, y, base[1 if u < .35 else 2 if u < .7 else 3])
    for x in range(18, 47): cv.put(x, 38, CREAMR[0]); cv.put(x, 39, CREAMR[3])
    # pine cone scoop
    L = R["wood"]
    lump(cv, 32, 30, 14, 11, [L[2], L[3], L[3], L[4], L[4]], rnd, 0)
    for row, yy in enumerate((21, 25, 29, 33, 37)):                                      # scales with pale tips
        for xx in range(15 + (row % 2) * 3, 50, 5 if row % 2 else 5):
            nx, ny = (xx + .5 - 32) / 14, (yy + 1.5 - 30) / 11
            if nx * nx + ny * ny > .8: continue
            sh = 1 if xx < 30 else 2 if xx < 40 else 3
            for dx in range(-2, 2): cv.put(xx + dx, yy, L[sh + 1])
            for dx in range(-2, 3): cv.put(xx + dx, yy + 1, L[sh] if dx < 0 else L[min(4, sh + 1)])
            for dx in range(-1, 2): cv.put(xx + dx, yy + 2, L[sh - 1] if dx < 1 else L[sh])
            cv.put(xx, yy + 3, L[0])
    # snow cap
    Sn = R["snow"]
    lump(cv, 31, 18, 13, 7, Sn, rnd, 0)
    for (x, r) in ((20, 2.6), (26, 3), (36, 3), (42, 2.4)): ell(cv, x, 22, r, r, Sn[1])
    for (x, y) in ((24, 13), (28, 12), (25, 14), (34, 13)): cv.put(x, y, WHITE)
    # resin syrup drizzle
    G = R["gold"]
    for (x, y0, n) in ((24, 22, 8), (33, 23, 11), (40, 22, 6)):
        for y in range(y0, y0 + n): cv.put(x, y, G[1]); cv.put(x + 1, y, G[2])
        cv.put(x, y0 + n, G[2]); cv.put(x + 1, y0 + n, G[3]); cv.put(x, y0, G[0])
    for x in range(21, 41):
        if x % 5 != 0: cv.put(x, 21 + (x % 3 == 0), G[1])
    def post(cv): star(cv, 50, 12, CREAM); cv.put(13, 20, Sn[0]); cv.put(52, 26, Sn[0])
    return dict(post=post, shadow=(32, 58, 10, 2))


def d_pocket_whistle(cv, rnd):
    D = R["dusk"]; G = R["gold"]
    # ribbon tail first (behind)
    lpoly(cv, [(0, -2.5), (13, -2.5), (16, -2.5), (13.5, 0), (16, 2.5), (0, 2.5)], (45, 44, 50),
          lambda lx, ly: D[1] if ly < -1 else D[2] if ly < 1.2 else D[3])
    lpoly(cv, [(0, -2.2), (11, -2.2), (13, -2.2), (11, 0), (13, 2.2), (0, 2.2)], (47, 42, 18),
          lambda lx, ly: R["petal"][1] if ly < 0 else R["petal"][2])
    # mouthpiece + barrel
    for x in range(9, 44):
        for y in range(25, 36):
            if x < 20 and (y < 27 or y > 34): continue
            v = (y - 25) / 10; t = 0 if v < .15 else 1 if v < .4 else 2 if v < .7 else 3
            fold = ((x + y // 2) // 4) % 2
            cv.put(x, y, D[min(4, t + fold)])
    # round chamber
    lump(cv, 40, 38, 11, 11, D, rnd, 0)
    for y in range(27, 50):                                                                # folded ribbon creases
        for x in range(29, 52):
            c = cv.get(x, y)
            if c in D and ((x + y // 2) // 4) % 2: cv.put(x, y, D[min(4, D.index(c) + 1)])
    ilump(cv, 40, 38, 3.5, 3.5, D)
    # brass rings
    for x0 in (19, 31):
        for y in range(25 if x0 > 20 else 26, 36):
            cv.put(x0, y, G[1] if y < 30 else G[2]); cv.put(x0 + 1, y, G[2] if y < 30 else G[3])
    rect(cv, 9, 27, 11, 35, G[2]); rect(cv, 9, 27, 10, 31, G[1])
    rect(cv, 24, 25, 29, 28, INK); rect(cv, 24, 27, 29, 28, D[4])                          # sound window
    def post(cv):
        def note(c2, x, y, c):
            ell(c2, x, y, 2.2, 1.7, c[1]); c2.put(x - 1, y - 1, c[0])
            for yy in range(y - 8, y): c2.put(x + 2, yy, c[2])
            for (dx, dy) in ((3, -8), (4, -7), (5, -6), (5, -5)): c2.put(x + dx, y + dy, c[2])
        overlay(cv, lambda t: (note(t, 16, 20, G), note(t, 28, 14, R["petal"])))
        star(cv, 40, 12, CREAM)
    return dict(post=post, shadow=(34, 56, 18, 2.5))


def d_bottled_rainbow(cv, rnd):
    I = R["ice"]
    # glass body
    lump(cv, 32, 39, 16, 16, [CREAM, I[0], I[1], I[2], I[3]], rnd, 0)
    gpoly(cv, [(27, 16), (37, 16), (38, 25), (26, 25)], [CREAM, I[0], I[1], I[2], I[3]], lx=1, ly=0)
    rect(cv, 25, 14, 39, 17, I[1]); rect(cv, 25, 14, 39, 15, I[0])                        # lip
    # inside: mist
    M = ramp("#ffffff", "#f3f7fc", "#dfe8f4", "#c9d6ea")
    ell(cv, 32, 40, 13, 13, M[2])
    for (x, y, r) in ((24, 47, 4), (31, 49, 5), (40, 47, 4), (36, 44, 3)): lump(cv, x, y, r, r * .8, [M[0], M[0], M[1], M[2], M[3]], rnd, 0)
    # the small rainbow
    cols = (R["ember"][1], R["gold"][1], R["moss"][1], R["sea"][1], R["dusk"][1])
    for i, c in enumerate(cols):
        arc(cv, 32, 47, 11 - i * 1.6, 180, 360, c, 2)
    for (x, y, r) in ((22, 47, 3), (42, 47, 3)): lump(cv, x, y, r, r * .8, [M[0], M[0], M[1], M[2], M[3]], rnd, 0)
    # glass highlight + shaded rim
    for y in range(29, 46): cv.put(19 if y > 33 and y < 42 else 20, y, WHITE)
    for y in range(31, 38): cv.put(21, y, WHITE)
    arc(cv, 32, 39, 15, 10, 80, I[3])
    # cork
    W = R["wood"]
    gpoly(cv, [(26, 5), (38, 5), (37, 14), (27, 14)], W, lx=1, ly=.4)
    for (x, y) in ((29, 8), (34, 10), (31, 12)): cv.put(x, y, W[3])
    rect(cv, 26, 5, 38, 6, W[0])
    def post(cv):
        for i, c in enumerate(cols[:4]):
            for k in range(3): cv.put(52 + k, 24 + i * 2 - k // 2, c); cv.put(11 - k, 24 + i * 2 - k // 2, c)
        star(cv, 47, 12, CREAM)
    return dict(post=post)


def d_visitors_book_page(cv, rnd):
    P = PAPER
    pts = [(16, 7), (47, 7), (47, 54), (16, 54)]
    pts = [(16, 7), (41, 7), (47, 13), (47, 54), (16, 54), (14, 50), (16, 46), (13, 42), (16, 38), (14, 33), (16, 29),
           (13, 24), (16, 20), (14, 15), (16, 11)]
    gpoly(cv, pts, P[:4] + [P[3]], lx=1, ly=.8)
    poly(cv, [(41, 7), (41, 13), (47, 13)], P[3]); line(cv, 41, 7, 41, 13, P[4]); line(cv, 41, 13, 47, 13, P[4])  # dog-ear
    for y in range(17, 54, 5):
        for x in range(18, 46):
            if cv.get(x, y)[3]: cv.put(x, y, mix(cv.get(x, y), R["sea"][1], .35))
    # scribbles from past guests
    # a smiley gnome with a red hat
    ell(cv, 23, 21, 3.5, 3.5, CREAMR[1]);
    poly(cv, [(19, 19), (27, 19), (23, 11)], R["ember"][1]); cv.put(22, 14, R["ember"][0]); line(cv, 19, 19, 27, 19, R["ember"][2])
    cv.put(22, 21, INK); cv.put(25, 21, INK); line(cv, 22, 23, 25, 23, INK)
    line(cv, 30, 21, 33, 19, INK); line(cv, 33, 19, 35, 22, INK); line(cv, 35, 22, 38, 18, INK); line(cv, 38, 18, 41, 21, INK)
    # heart
    E = R["ember"]
    for (x, y) in ((33, 28), (34, 28), (36, 28), (37, 28)): cv.put(x, y, E[1])
    rect(cv, 32, 29, 39, 31, E[1]); rect(cv, 33, 31, 38, 32, E[1]); rect(cv, 34, 32, 37, 33, E[2]); cv.put(35, 33, E[2]); cv.put(33, 29, CREAM)
    # signature squiggles
    for x in range(19, 31):
        cv.put(x, 32 + int(round(1.5 * math.sin(x * 1.1))), R["dusk"][2])
    for x in range(20, 43):
        cv.put(x, 38 + int(round(1.4 * math.sin(x * .8 + 1))), INK if x < 34 else R["sea"][3])
    # a sun doodle, a little tree and "xx"
    lump(cv, 39, 45, 3, 3, R["gold"], rnd, 0)
    for (dx, dy) in ((0, -5), (0, 5), (-5, 0), (5, 0), (4, 4), (-4, -4), (4, -4), (-4, 4)): cv.put(39 + dx, 45 + dy, R["gold"][2])
    for (x, y) in ((20, 45), (22, 47), (22, 45), (20, 47), (21, 46), (25, 45), (27, 47), (27, 45), (25, 47), (26, 46)): cv.put(x, y, E[2])
    line(cv, 30, 47, 30, 51, R["wood"][3]); lump(cv, 30, 46, 2.5, 2.5, R["moss"], rnd, 0)
    return {}


def d_echo_pebble(cv, rnd):
    B = BLUEST
    lump(cv, 22, 42, 16, 11, B, rnd, .04)
    for (x, y) in ((14, 36), (15, 35), (16, 35), (13, 37)): cv.put(x, y, WHITE)
    # singing face
    cv.put(18, 40, INK); cv.put(19, 41, INK); cv.put(24, 40, INK); cv.put(25, 41, INK)
    ell(cv, 22, 45.5, 2, 2.2, INK); cv.put(22, 46, R["ember"][1]); cv.put(21, 46, R["ember"][2])
    cv.put(16, 44, R["petal"][1]); cv.put(28, 44, R["petal"][1])
    # echoes, louder each time
    G = R["gold"]
    for i, (r, a) in enumerate(((19, 30), (26, 34), (33, 37))):
        arc(cv, 22, 36, r, -a, a, (G[1], G[1], G[0])[i], 2)
    def post(cv):
        star(cv, 12, 18, CREAM); cv.put(30, 14, CREAM); cv.put(6, 27, CREAM)
    return dict(post=post, shadow=(23, 54, 16, 2.5))


def d_gulls_medal(cv, rnd):
    # a crooked ribbon, tied in a lazy knot
    Bl = R["sea"]
    def strip(lx, ly):
        return (CREAMR[1] if lx < 4 else CREAMR[2]) if 3 <= lx < 6 else (Bl[1] if lx < 4 else Bl[2])
    lpoly(cv, [(0, 0), (9, 0), (9, 22), (0, 22)], (26, 4, -14), strip)
    lpoly(cv, [(0, 0), (9, 0), (9, 14), (0, 14)], (38, 6, 36), strip)
    lump(cv, 33, 22, 4, 3.5, R["sea"], rnd, 0)
    # bottle cap with a crimped edge
    E = R["ember"]; cx, cy = 32, 38
    for y in range(cy - 17, cy + 18):
        for x in range(cx - 17, cx + 18):
            dx, dy = x + .5 - cx, y + .5 - cy; a = math.atan2(dy, dx); r = math.hypot(dx, dy)
            rr = 14.5 + 1.6 * (1 if (int((a + math.pi) / (2 * math.pi) * 21 * 2) % 2) else -1) * .6
            if r <= rr:
                t = gen2.tone5(gen2.shade_pt(dx / 16, dy / 16))
                if r > 12.2: t = min(4, t + (1 if int((a + math.pi) / (2 * math.pi) * 42) % 2 else 0))
                cv.put(x, y, E[t])
    ilump(cv, 32, 38, 11.5, 11.5, E)
    ell(cv, 32, 38, 10.4, 10.4, E[1])
    # a lopsided, not-really-tried star
    pts = []
    for i in range(10):
        a = math.radians(-90 + i * 36 + (14 if i == 2 else 0)); rr = (7 if i % 2 == 0 else 3) * (1.25 if i == 2 else .8 if i == 6 else 1)
        pts.append((32 + rr * math.cos(a), 39 + rr * math.sin(a)))
    poly(cv, pts, CREAMR[1]); poly(cv, [(p[0] + .5, p[1] + .5) for p in pts[3:6]], CREAMR[2])
    cv.put(31, 35, WHITE)
    cv.put(41, 44, E[4]); cv.put(42, 44, E[4]); cv.put(41, 45, E[2])                       # dent
    for (x, y) in ((22, 30), (23, 29), (24, 28)): cv.put(x, y, E[0])
    return {}


def d_barnacle_giggle(cv, rnd):
    St = R["stone"]
    lump(cv, 32, 49, 22, 7, St, rnd, .05)
    C = CREAMR
    def cone(cx, by, bw, tw, h, ribs):
        ty = by - h
        gpoly(cv, [(cx - bw / 2, by), (cx - tw / 2, ty + 1), (cx - tw / 2 + 1, ty), (cx + tw / 2 - 1, ty), (cx + tw / 2, ty + 1), (cx + bw / 2, by)],
              C, lx=1, ly=.25, bands=(.15, .35, .6, .85))
        for i in range(1, ribs):
            fx = -1 + 2 * i / ribs
            line(cv, cx + fx * bw / 2, by - 1, cx + fx * tw / 2, ty + 2, C[3] if fx < .3 else C[4])
            line(cv, cx + fx * bw / 2 - 1, by - 2, cx + fx * tw / 2 - 1, ty + 3, C[1] if fx < .3 else C[2])
        ell(cv, cx, ty + 1, tw / 2 - 1.5, 1.6, R["dusk"][3]); cv.put(int(cx - tw / 2 + 2), ty, C[0])
        if tw > 8: poly(cv, [(cx - 4, ty + 2), (cx, ty - 1), (cx, ty + 2)], C[1]); poly(cv, [(cx + 1, ty + 2), (cx + 1, ty - 1), (cx + 4, ty + 2)], C[2])
        return ty
    cone(14, 49, 12, 6, 9, 3); cone(50, 50, 11, 5, 8, 3)
    ty = cone(32, 49, 30, 16, 21, 6)
    def post(cv):
        P = R["petal"]                                                                     # feathery cirri waving out
        for (pts) in (((30, 26), (28, 23), (26, 21), (26, 19)), ((34, 26), (35, 22), (37, 20), (39, 20)), ((32, 26), (32, 22), (31, 19))):
            for i, (x, y) in enumerate(pts): cv.put(x, y, P[1] if i < 2 else P[0])
        for (x0, y0, dx, dy) in ((21, 24, -1, -1), (16, 30, -1, 0), (43, 24, 1, -1), (48, 30, 1, 0), (32, 15, 0, -1)):   # giggle clicks
            for k in range(3): cv.put(x0 + dx * k, y0 + dy * k, INK)
        pass
    return dict(post=post, shadow=(32, 56, 22, 2))


def d_dream_souvenir(cv, rnd):
    G = R["gold"]
    A = (30, 34, 18); B = (41, 26, 15)
    for y in range(10, 56):
        for x in range(8, 52):
            dxa, dya = x + .5 - A[0], y + .5 - A[1]
            if dxa * dxa + dya * dya > A[2] ** 2: continue
            if (x + .5 - B[0]) ** 2 + (y + .5 - B[1]) ** 2 < B[2] ** 2: continue
            t = gen2.tone5(gen2.shade_pt(dxa / A[2] * .9, dya / A[2] * .9))
            cv.put(x, y, G[t])
    # sleepy face on the thick part of the crescent
    for x in range(17, 22): cv.put(x, 36 + (1 if x in (18, 19, 20) else 0), INK)
    cv.put(23, 43, INK); cv.put(24, 44, INK); cv.put(25, 44, INK); cv.put(26, 43, INK)
    cv.put(16, 40, R["petal"][1]); cv.put(17, 40, R["petal"][1])
    # floppy striped nightcap on the top horn
    D = R["dusk"]
    pts = [(14, 22), (26, 15), (36, 12), (44, 10), (50, 14), (47, 15), (39, 17), (30, 23)]
    for i in range(len(pts)): pass
    fm(cv, lambda d: d.polygon([(15, 22), (24, 13), (34, 9), (43, 9), (50, 13), (48, 15), (36, 15), (29, 22)], fill=255),
       lambda x, y, b: (D[1] if y < 13 else D[2]) if ((x - y // 2) // 4) % 2 else (CREAMR[1] if y < 13 else CREAMR[2]))
    rect(cv, 13, 21, 31, 25, D[2]); rect(cv, 13, 21, 31, 22, D[1])
    lump(cv, 51, 16, 3.5, 3.5, CREAMR, rnd, 0)
    def post(cv):
        overlay(cv, lambda t: (star(t, 51, 33, G[1], True), star(t, 10, 48, G[1])))
        star(cv, 56, 46, CREAM)
        # Zz
        for (x0, y0, s) in ((52, 25, 4), (57, 21, 3)):
            for k in range(s): cv.put(x0 + k, y0, D[3]); cv.put(x0 + k, y0 + s - 1, D[3]); cv.put(x0 + s - 1 - k, y0 + k, D[3])
    return dict(post=post, shadow=(31, 58, 13, 2))


def d_old_river_pebble(cv, rnd):
    P = PEBBLE
    lump(cv, 32, 36, 21, 18, P, rnd, .06)
    # quartz band wrapping round the pebble
    for x in range(10, 54):
        yc = 33 + (x - 32) * .35 + 3 * math.sin((x - 10) / 44 * math.pi) * .3
        for dy in range(-2, 2):
            y = int(round(yc + dy))
            c = cv.get(x, y)
            if c[3] and c in P:
                i = P.index(c); cv.put(x, y, CREAMR[max(0, min(4, i - (1 if dy < 0 else 0)))])
    # cool wet shine + a drop
    for (x, y) in ((20, 24), (21, 23), (22, 23), (23, 22), (19, 25), (24, 22)): cv.put(x, y, H("#e8f4ff"))
    cv.put(21, 25, H("#cfe4f6")); cv.put(23, 24, H("#cfe4f6"))
    drop(cv, 41, 25, R["ice"])
    # a speck of moss and grit
    for (x, y) in ((44, 47), (45, 47), (46, 46), (45, 46)): cv.put(x, y, R["moss"][2])
    cv.put(44, 46, R["moss"][1])
    for (x, y) in ((28, 44), (36, 28), (16, 40), (40, 40)): cv.put(x, y, P[3])
    def post(cv): star(cv, 52, 16, H("#e8f4ff")); cv.put(56, 22, H("#cfe4f6"))
    return dict(post=post)


def d_mirage_marble(cv, rnd):
    Gl = GLASS
    lump(cv, 32, 34, 19, 19, Gl, rnd, 0)
    # refracted glow on the lower-right inside
    arc(cv, 32, 34, 15, 15, 75, Gl[1], 2)
    # tiny dune + pool + palm inside
    Sd = R["sand"]
    for x in range(17, 48):
        top = 40 - int(3 * math.sin((x - 17) / 31 * math.pi))
        for y in range(top, 48):
            if (x + .5 - 32) ** 2 + (y + .5 - 34) ** 2 < 15.5 ** 2: cv.put(x, y, Sd[1] if y < top + 2 else Sd[2])
    Sea = R["sea"]
    ell(cv, 34, 42, 8.5, 2.6, Sea[2]); ell(cv, 33, 41.5, 6, 1.6, Sea[1])
    for x in (30, 31, 36, 37): cv.put(x, 41, Sea[0])
    W = R["wood"]; Lf = R["leaf"]
    for i, y in enumerate(range(30, 41)): cv.put(24 + (1 if y < 34 else 0), y, W[2]); cv.put(25 + (1 if y < 34 else 0), y, W[3])
    for (pts, c) in ((((26, 30), (22, 30), (19, 32)), Lf[1]), (((26, 30), (30, 29), (33, 31)), Lf[1]),
                     (((26, 30), (24, 27), (21, 27)), Lf[0]), (((26, 30), (29, 27), (31, 27)), Lf[0])):
        for a, b in zip(pts, pts[1:]): line(cv, a[0], a[1], b[0], b[1], c, 2)
    # heat shimmer
    for x in range(34, 44):
        cv.put(x, 33 + (x % 4 == 0) - (x % 4 == 2), Gl[0])
    # big glass highlight
    for (x, y) in ((22, 22), (23, 21), (24, 21), (25, 20), (21, 23), (21, 24), (22, 23), (26, 20), (20, 25)): cv.put(x, y, WHITE)
    cv.put(27, 24, WHITE)
    def post(cv): star(cv, 52, 14, CREAM); cv.put(10, 20, CREAM)
    return dict(post=post)


def d_cactus_bloom(cv, rnd):
    M = R["moss"]
    lump(cv, 32, 45, 13, 10, M, rnd, 0)
    for (x0, dx) in ((25, -1), (32, 0), (39, 1)):                                          # ribs
        for y in range(38, 54):
            x = x0 + int(dx * (y - 38) / 5)
            if cv.get(x, y)[3]: cv.put(x, y, M[3])
            if cv.get(x - 1, y)[3]: cv.put(x - 1, y, M[1] if x0 < 35 else M[2])
    # bloom
    P = R["petal"]
    def petal(L_, Pc):
        def f(lx, ly):
            if ly > 3: return Pc[3]
            u = lx / L_
            return Pc[0] if (u > .55 and ly < .5) else Pc[1] if ly < .8 else Pc[2]
        return f
    angs = sorted(range(9), key=lambda i: math.sin(math.radians(i * 40 - 80)))
    for i in angs:
        a_ = i * 40 - 80
        lpoly(cv, [(0, -3), (6, -5), (10, -4), (12.5, -1.5), (13, 0), (12.5, 1.5), (10, 4), (6, 5), (0, 3)], (32, 25, a_), petal(13, P))
    for i in range(7):
        a_ = i * 51 - 60
        lpoly(cv, [(0, -2.5), (4, -3), (8, 0), (4, 3), (0, 2.5)], (32, 25, a_), petal(8, [P[0], P[0], P[1], P[2], P[3]]))
    G = R["gold"]
    lump(cv, 32, 25, 3.2, 3, G, rnd, 0)
    for (x, y) in ((29, 21), (32, 20), (35, 21), (30, 22), (34, 22)): cv.put(x, y, G[1])
    cv.put(31, 24, CREAM)
    def post(cv):
        for (x, y, dx, dy) in ((18, 42, -1, 0), (19, 48, -1, 1), (46, 43, 1, 0), (45, 49, 1, 1), (24, 51, -1, 1), (40, 52, 1, 1)):
            cv.put(x + dx, y + dy, CREAM); cv.put(x + 2 * dx, y + 2 * dy, CREAMR[2])
        star(cv, 50, 10, CREAM)
    return dict(post=post)


def d_marrowbys_wooden_coin(cv, rnd):
    W = R["wood"]
    ell(cv, 34.5, 34.5, 19, 19, W[4])                                                       # thickness (edge)
    for k in range(0, 360, 14):
        a = math.radians(k)
        if 0 < k < 110: cv.put(int(34.5 + 18.5 * math.cos(a)), int(34.5 + 18.5 * math.sin(a)), W[3])
    lump(cv, 32, 32, 19, 19, W, rnd, .03)
    ilump(cv, 32, 32, 15, 15, W)
    lump(cv, 32, 32, 13.4, 13.4, [W[1], W[1], W[2], W[2], W[3]], rnd, .04)
    for (r, a0, a1) in ((9, 200, 280), (5, 150, 250), (11, 20, 80)):                       # grain
        arc(cv, 32, 32, r, a0, a1, W[3])
    # carved M (deep groove with a light lower lip)
    M = [(25, 39), (25, 26), (32, 33), (39, 26), (39, 39)]
    for a, b in zip(M, M[1:]):
        line(cv, a[0] + 1, a[1] + 1, b[0] + 1, b[1] + 1, W[0], 2)
    for a, b in zip(M, M[1:]):
        line(cv, a[0], a[1], b[0], b[1], INK, 2)
    # chipped notch + string hole
    for (x, y) in ((47, 20), (48, 21), (49, 22), (48, 20), (49, 21)): clear(cv, x, y)
    rect(cv, 31, 15, 33, 17, CLEAR)
    def post(cv):
        S_ = R["sand"]
        for (x, y) in ((32, 14), (33, 12), (34, 10), (35, 8), (37, 7), (39, 7), (41, 8), (42, 10), (43, 12), (44, 14)):
            cv.put(x, y, S_[2])
        star(cv, 13, 14, CREAM)
    return dict(post=post)


ITEMS = [
    "squirrels-spare-key", "toadstool-stool", "brass-button", "teeny-axe", "mudskipper-medal", "willow-withies",
    "icicle-chime", "bog-pressed-bookmark", "herons-programme-notes", "pine-snow-cone", "pocket-whistle",
    "bottled-rainbow", "visitors-book-page", "echo-pebble", "gulls-medal", "barnacle-giggle", "dream-souvenir",
    "old-river-pebble", "mirage-marble", "cactus-bloom", "marrowbys-wooden-coin",
]


def shadow_layer(cx, cy, rx, ry):
    im = Image.new("RGBA", (S, S), CLEAR); d = ImageDraw.Draw(im)
    d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=INK[:3] + (60,))
    d.ellipse((cx - rx * .72, cy - ry * .6, cx + rx * .72, cy + ry * .6), fill=INK[:3] + (95,))
    return im


def render(slug):
    rnd = random.Random("sight-b-" + slug)
    cv = Cv(S, S)
    res = globals()["d_" + slug.replace("-", "_")](cv, rnd) or {}
    outline(cv)
    if res.get("post"): res["post"](cv)
    bb = cv.im.getbbox()
    sh = res.get("shadow") or ((bb[0] + bb[2]) / 2, min(58, bb[3] - 1), min(25, (bb[2] - bb[0]) * .42), 2.5)
    out = shadow_layer(*sh)
    out.alpha_composite(cv.im)
    return out


def main():
    slugs = sys.argv[1:] or ITEMS
    for s in slugs:
        render(s).save(os.path.join(OUT, s + ".png"))
    print("wrote", len(slugs), "item pictures to", OUT)


if __name__ == "__main__":
    main()
