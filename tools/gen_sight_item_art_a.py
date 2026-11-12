#!/usr/bin/env python3
"""Item pictures (Hearth Pop v3) for the FIRST 21 rows of game/includes/data/trail_sight_items.txt.
64 x 64 RGBA, hard pixels, 5-tone ramps lit from the top-left, 1 px ink outline, flat two-tone ground shadow.
Deterministic and re-runnable:  python3 tools/gen_sight_item_art_a.py   -> game/assets/img/ph/<slug>.png"""
import math, os, random, sys, zlib
from PIL import Image, ImageDraw, ImageChops

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "claude", "tile-art-v3-proposal"))
import gen2  # noqa: E402
from gen2 import RAMP, INK, CREAM, H, r5, Cv, outline, lump, tone5, shade_pt  # noqa: E402

OUT = os.path.join(ROOT, "game", "assets", "img", "ph")
S = 64
SH_IN, SH_OUT = H("#aaa9b8"), H("#74758c")   # ground shadow, as on the existing item pictures


def ramp(*hx): return [H(h) for h in hx]


STONE, WOOD, GOLD, EMBER = r5(RAMP["stone"]), r5(RAMP["wood"]), r5(RAMP["gold"]), r5(RAMP["ember"])
LEAF, MOSS, SEA, DUSK, ICE, PETAL = r5(RAMP["leaf"]), r5(RAMP["moss"]), r5(RAMP["sea"]), r5(RAMP["dusk"]), r5(RAMP["ice"]), r5(RAMP["petal"])
SACK = ramp("#fffaf0", "#f5ead0", "#e2cda4", "#bf9f74", "#86664f")
WOOL = ramp("#fffdf4", "#f7efdb", "#e6d8bc", "#c4b090", "#8d7a66")
PARCH = ramp("#fff6dc", "#f5e3b4", "#e4c88e", "#c49c66", "#8a6448")
SYRUP = ramp("#ffe6a0", "#f7b64a", "#d8802a", "#a24f22", "#6a2d1e")
TOFFEE = ramp("#ffe0a0", "#f0b45c", "#d68a3c", "#a65a2c", "#6a3424")
TOAST = ramp("#fff0c4", "#f5c46e", "#d48a3e", "#9a5530", "#5e3326")
GOO = ramp("#fffdf2", "#fff2d0", "#f5dca8", "#d9b27a", "#a07850")
GLASS = ramp("#e6fff0", "#aee6cc", "#6fbfa6", "#3f8c80", "#285a5e")
GLOW = ramp("#f4ffd6", "#d7f78a", "#9ee05a", "#4fa85a", "#2e6a55")
STEM = ramp("#fffbe8", "#f6ecc8", "#e6d29e", "#c6aa74", "#8e7254")
NIGHT = ramp("#5a6fb8", "#45569a", "#36437e", "#2a3263", "#1d2346")
JARDARK = ramp("#3a4f86", "#2f3f70", "#26325c", "#1e284a", "#161c36")
BLUE = ramp("#cfe6ff", "#8ab8f2", "#4f7fd6", "#2f50a0", "#22305f")
DEW = ramp("#f2fdff", "#c6f0fb", "#86d3ee", "#4c9ad0", "#2f5e9a")
SNAIL = ramp("#f6f3d0", "#e2e2a8", "#bcc684", "#8c9a62", "#5c6748")
SOCKY = ramp("#fff2a8", "#ffe070", "#f2bf3c", "#c98a2a", "#8a5222")


# ------------------------------------------------------------------ masks
def M(fn):
    m = Image.new("L", (S, S), 0); fn(ImageDraw.Draw(m)); return m
def Mpoly(pts): return M(lambda d: d.polygon([(float(x), float(y)) for x, y in pts], fill=255))
def Mell(cx, cy, rx, ry): return M(lambda d: d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=255))
def Mrect(x0, y0, x1, y1): return M(lambda d: d.rectangle((x0, y0, x1 - 1, y1 - 1), fill=255))
def Mrr(x0, y0, x1, y1, r): return M(lambda d: d.rounded_rectangle((x0, y0, x1 - 1, y1 - 1), radius=r, fill=255))
def Mline(pts, w): return M(lambda d: d.line([(float(x), float(y)) for x, y in pts], fill=255, width=w, joint="curve"))
def Mdots(pts):
    """Union of discs: [(x, y, r), ...]."""
    def f(d):
        for x, y, r in pts: d.ellipse((x - r, y - r, x + r, y + r), fill=255)
    return M(f)
def union(*ms):
    out = ms[0]
    for m in ms[1:]: out = ImageChops.lighter(out, m)
    return out
def minus(a, b): return ImageChops.subtract(a, b)
def inter(a, b): return ImageChops.darker(a, b)
def pix(m):
    bb = m.getbbox()
    if not bb: return []
    p = m.load(); return [(x, y) for y in range(bb[1], bb[3]) for x in range(bb[0], bb[2]) if p[x, y]]


def shade(cv, m, R, mode="ball", rnd=None, speck=0.0, rim=True, hi=True, box=None, light=None):
    """Paint mask m with ramp R (5 tones, 0 = lightest). R may be a function (x, y) -> ramp.
    mode: ball / cyl (vertical) / hcyl (horizontal) / flat / edge / int (fixed tone)."""
    pts = pix(m)
    if not pts: return {}
    s = set(pts)
    x0, y0, x1, y1 = box or m.getbbox()
    cx, cy = (x0 + x1) / 2, (y0 + y1) / 2; rx, ry = max(1, (x1 - x0) / 2), max(1, (y1 - y0) / 2)
    tone = {}
    for x, y in pts:
        nx, ny = (x + .5 - cx) / rx, (y + .5 - cy) / ry
        if mode == "ball": t = tone5(shade_pt(max(-1, min(1, nx)), max(-1, min(1, ny))))
        elif mode == "cyl": t = tone5(shade_pt(max(-1, min(1, nx)) * .95, -.15))
        elif mode == "hcyl": t = tone5(shade_pt(-.2, max(-1, min(1, ny)) * .95))
        elif mode == "flat": t = 1 if nx + ny < -1.0 else 2 if nx + ny < .9 else 3
        elif mode == "edge": t = 2
        else: t = int(mode)
        if speck and rnd and rnd.random() < speck: t = max(0, min(4, t + rnd.choice((-1, 1))))
        up, lf = (x, y - 1) not in s, (x - 1, y) not in s
        dn, rt = (x, y + 1) not in s, (x + 1, y) not in s
        if mode == "edge":
            if hi and (up or lf): t = 1 if not (up and lf) else 0
            if rim and (dn or rt): t = 4 if (dn and rt) else 3
        else:
            if hi and (up or lf) and nx + ny < -.3: t = max(0, t - 1)
            if rim and (dn or rt) and nx + ny > .1: t = 4
        tone[(x, y)] = t
        RR = R(x, y) if callable(R) else R
        cv.put(x, y, RR[t])
    return tone


def tint(cv, pts, R, d):
    """Shift each pixel that uses ramp R by d tones."""
    idx = {c: i for i, c in enumerate(R)}
    for x, y in pts:
        c = cv.get(x, y)
        if c in idx: cv.put(x, y, R[max(0, min(4, idx[c] + d))])


def px(cv, pts, c):
    for x, y in pts: cv.put(x, y, c)


def sparkle(cv, x, y, c=CREAM, big=False):
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)): cv.put(x + dx, y + dy, c)
    if big:
        for dx, dy in ((2, 0), (-2, 0), (0, 2), (0, -2)): cv.put(x + dx, y + dy, c)


def leaf_sprite(cv, cx, cy, c, dark):
    """Tiny 7 x 7 maple leaf."""
    rows = ["...#...", "#.###.#", "#######", ".#####.", "#######", "...#...", "...#..."]
    for j, row in enumerate(rows):
        for i, ch in enumerate(row):
            if ch == "#": cv.put(cx - 3 + i, cy - 3 + j, dark if (i >= 4 and j >= 3) else c)


def axis_poly(O, ang, segs):
    """Polygon round an axis from O at angle ang (radians, screen coords); segs = [(s, half_width), ...]."""
    ux, uy = math.cos(ang), math.sin(ang); nx, ny = -uy, ux
    a = [(O[0] + s * ux + w * nx, O[1] + s * uy + w * ny) for s, w in segs]
    b = [(O[0] + s * ux - w * nx, O[1] + s * uy - w * ny) for s, w in reversed(segs)]
    return a + b


def bezier(p0, p1, p2, n):
    return [((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0],
             (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]) for t in (i / n for i in range(n + 1))]


# ------------------------------------------------------------------ items
def flour(cv, rnd):
    body = union(Mell(32, 43, 16, 13), Mpoly([(25, 22), (39, 22), (47, 40), (17, 40)]))
    shade(cv, body, SACK, "ball", rnd, .05)
    tint(cv, [(x, y) for x, y in pix(body) if (x * 3 + y * 5) % 9 == 0], SACK, 1)   # burlap weave
    # gathered top and the flour peeking out
    ears = Mpoly([(23, 9), (28, 15), (32, 10), (36, 15), (41, 9), (39, 22), (25, 22)])
    shade(cv, ears, SACK, "ball", rnd, .04)
    for x in (28, 32, 36): px(cv, [(x, y) for y in range(16, 21)], SACK[3])
    shade(cv, Mell(32, 12, 4, 2), WOOL, "edge")
    # string tie with a bow
    tie = Mrect(24, 20, 41, 24); shade(cv, tie, WOOD, "edge")
    px(cv, [(x, 21 + (x % 3 == 0)) for x in range(25, 40, 2)], WOOD[3])
    shade(cv, Mdots([(38, 23, 2.5), (44, 22, 2.5)]), WOOD, "ball")
    shade(cv, Mline([(41, 24), (43, 30)], 1), WOOD, 3)
    # windmill stamp, eyes shut (it is only pretending)
    ST, STD = H("#d47860"), H("#a8503f")
    px(cv, pix(Mpoly([(29.5, 39), (34.5, 39), (36.5, 50), (27.5, 50)])), ST)
    px(cv, pix(Mpoly([(29, 39), (32, 35), (35, 39)])), STD)
    for ex, ey in ((25, 29), (40, 30), (24, 42), (39, 43)):
        px(cv, pix(Mline([(32, 37), (ex, ey)], 2)), ST)
    cv.put(32, 37, STD)
    for x, y in ((29, 43), (30, 44), (31, 43), (33, 43), (34, 44), (35, 43)): cv.put(x, y, SACK[0])   # eyes shut
    px(cv, [(31, 48), (32, 48), (33, 48), (31, 47), (32, 47), (33, 47), (32, 46)], STD)               # door

    def post(c):
        for x, y in ((20, 8), (44, 7)): sparkle(c, x, y, WOOL[0])
        for x, y in ((26, 6), (38, 5), (17, 13), (47, 12)): c.put(x, y, WOOL[1])
    return post


def maple_sap(cv, rnd):
    # a stub of maple trunk with a spile
    trunk = union(Mrect(7, 10, 21, 56), Mell(14, 10, 7, 3))
    shade(cv, trunk, WOOD, "cyl", rnd, .06)
    for x in (10, 14, 18): px(cv, [(x + (y // 7) % 2, y) for y in range(14, 55) if (y * 5 + x) % 6]
                             , WOOD[4])
    shade(cv, Mell(14, 10, 6, 2), ramp("#fbe3b8", "#f0cc94", "#e0b37a", "#c48f5c", "#8a6040"), "edge")
    px(cv, pix(minus(Mell(14, 10, 3.5, 1.2), Mell(14, 10, 2, .4))), WOOD[2])
    leaf_sprite(cv, 13, 34, EMBER[1], EMBER[3])
    # spile and the bucket that hangs from it
    shade(cv, Mline([(20, 18), (34, 18)], 3), STONE, "edge")
    shade(cv, Mrect(33, 16, 35, 21), STONE, "edge")
    bucket = Mpoly([(22, 26), (50, 26), (47, 55), (25, 55)])
    shade(cv, bucket, STONE, "cyl", rnd, .03, box=(22, 26, 50, 55))
    for y in (33, 47):
        px(cv, [(x, y) for x in range(23, 50) if bucket.getpixel((x, y))], STONE[3])
        px(cv, [(x, y - 1) for x in range(23, 50) if bucket.getpixel((x, y - 1))], STONE[0])
    rim = Mell(36, 26, 14, 3); shade(cv, rim, STONE, "edge")
    shade(cv, Mell(36, 26.5, 12, 1.6), ICE, 1)
    px(cv, [(30, 26), (31, 26), (40, 27)], CREAM)
    leaf_sprite(cv, 36, 40, EMBER[1], EMBER[3])
    # the polite drip
    drop = union(Mell(34, 23.5, 1.6, 1.6), Mpoly([(34, 20), (35.4, 23), (32.6, 23)]))
    shade(cv, drop, ICE, "ball"); cv.put(33, 23, CREAM)


def maple_syrup(cv, rnd):
    body = Mrr(17, 22, 48, 57, 8)
    shade(cv, body, SYRUP, "ball", rnd, .03)
    shade(cv, Mrect(23, 18, 42, 23), SYRUP, "cyl")
    lid = Mrr(20, 9, 45, 19, 2)
    shade(cv, lid, WOOD, "cyl")
    for x in range(23, 44, 3): px(cv, [(x, y) for y in range(11, 18)], WOOD[3])
    px(cv, [(x, 18) for x in range(21, 44)], WOOD[4])
    # glass shine
    px(cv, [(20, y) for y in range(28, 50)] + [(21, y) for y in range(26, 30)], CREAM)
    px(cv, [(44, y) for y in range(30, 44)], SYRUP[1])
    # label with a maple leaf
    lab = Mrr(24, 33, 42, 48, 2); shade(cv, lab, PARCH, "flat")
    px(cv, [(x, y) for x, y in pix(lab) if not Mrr(25, 34, 41, 47, 1).getpixel((x, y))], PARCH[3])
    leaf_sprite(cv, 33, 40, EMBER[1], EMBER[3])
    # a drip escaping the lid
    drip = union(Mrect(41, 18, 43, 29), Mell(42, 29.5, 1.6, 2))
    shade(cv, drip, SYRUP, "edge")
    px(cv, [(41, 19), (41, 20), (41, 21)], SYRUP[0])


def toffee(cv, rnd):
    # a wax-paper square under a glossy slab of toffee
    paper = Mpoly([(4, 42), (27, 33), (60, 41), (36, 53)])
    shade(cv, paper, WOOL, "flat", rim=False)
    for x, y in ((6, 41), (5, 43), (59, 42), (60, 40)): cv.put(x, y, WOOL[2])
    top = Mpoly([(10, 27), (31, 18), (53, 27), (32, 37)])
    left = Mpoly([(10, 27), (32, 37), (32, 49), (10, 39)])
    right = Mpoly([(32, 37), (53, 27), (53, 39), (32, 49)])
    shade(cv, left, TOFFEE, 2, rnd, .03, rim=False)
    shade(cv, right, TOFFEE, 3, rnd, .03, rim=False)
    shade(cv, top, TOFFEE, 1, rnd, .03, rim=False)
    px(cv, [(x, y) for x, y in pix(left) if not left.getpixel((x, y - 1))], TOFFEE[0])     # lit front edge
    px(cv, [(x, y) for x, y in pix(right) if not right.getpixel((x, y - 1))], TOFFEE[2])
    px(cv, [(32, y) for y in range(37, 49)], TOFFEE[4])
    # glossy streaks, sugar crystals and a crackle
    px(cv, pix(Mline([(16, 26), (27, 21)], 1)) + pix(Mline([(19, 29), (24, 27)], 1)), TOFFEE[0])
    px(cv, pix(Mline([(14, 32), (14, 36)], 1)) + pix(Mline([(48, 32), (48, 35)], 1)), TOFFEE[1])
    for a, b in (((30, 25), (34, 28)), ((34, 28), (39, 27)), ((24, 31), (27, 30))):
        px(cv, pix(Mline([a, b], 1)), TOFFEE[2])
    for x, y in ((21, 24), (35, 22), (29, 30), (43, 27), (38, 31)): cv.put(x, y, CREAM)
    # somebody already took a bite out of the back corner
    bite = Mdots([(54, 30, 4.5), (55, 36, 4), (53, 25, 3)])
    keep = union(top, left, right)
    for x, y in pix(inter(bite, keep)): cv.p[x, y] = (0, 0, 0, 0)
    for x, y in pix(keep):
        if cv.get(x, y)[3] and any(bite.getpixel((min(63, max(0, x + dx)), min(63, max(0, y + dy)))) for dx, dy in ((1, 0), (0, -1), (1, -1), (-1, -1))):
            cv.put(x, y, TOFFEE[3])
    # little tooth bumps on the bite edge
    for x, y in ((49, 29), (50, 34), (50, 39)): cv.put(x, y, TOFFEE[1])
    shade(cv, Mpoly([(52, 44), (56, 42), (57, 46), (53, 47)]), TOFFEE, "flat")


def marshmallow(cv, rnd):
    stick = Mline([(17, 53), (36, 28)], 3); shade(cv, stick, WOOD, "edge")
    px(cv, [(17, 52), (18, 51), (17, 53)], WOOD[4])
    # a fat cylinder: toasted sides, paler top face
    side = union(Mrr(26, 16, 50, 36, 5))
    shade(cv, side, TOAST, "cyl", rnd, .07)
    topf = Mell(38, 16, 12, 4.5); shade(cv, topf, GOO, "ball", rnd, .05)
    px(cv, [(x, y) for x, y in pix(topf) if not topf.getpixel((x, y + 1))], TOAST[2])
    for x, y in ((45, 24), (46, 25), (29, 27), (43, 31), (48, 20)): cv.put(x, y, TOAST[4])
    # gooey drips from the underside
    goo = union(Mrect(31, 33, 36, 40), Mell(33.5, 40, 2.5, 2.5), Mrect(41, 34, 44, 38), Mell(42.5, 38, 1.5, 1.6))
    shade(cv, goo, GOO, "edge")
    px(cv, [(32, 34), (32, 35), (32, 36)], CREAM)

    def post(c):
        for i, y in enumerate(range(4, 10)): c.put(35 + (1 if i % 3 == 1 else 0), y, CREAM)
        for i, y in enumerate(range(3, 8)): c.put(42 + (1 if i % 3 == 0 else 0), y, WOOL[1])
    return post


def message_bottle(cv, rnd):
    O, ang = (14, 48), -math.pi / 4
    ux, uy = math.cos(ang), math.sin(ang); nx, ny = -uy, ux
    segs = [(0, 7.5), (1.5, 9), (27, 9), (33, 4), (41, 4), (41, 5.2), (44, 5.2), (44, 4)]
    bottle = Mpoly(axis_poly(O, ang, segs))
    cork = Mpoly(axis_poly(O, ang, [(43, 3.3), (51, 3.3)]))

    def sd(x, y): dx, dy = x + .5 - O[0], y + .5 - O[1]; return dx * ux + dy * uy, dx * nx + dy * ny
    PAPER = PARCH
    for x, y in pix(bottle):
        s, d = sd(x, y)
        hw = 9 if s < 27 else 4.5
        dn = d / hw
        t = 0 if dn < -.7 else 1 if dn < -.25 else 2 if dn < .35 else 3 if dn < .75 else 4
        R = GLASS
        if 6 <= s <= 25 and abs(d) < 4.6:
            R = EMBER if 14.5 <= s <= 16.5 else PAPER
            t = 1 if d < -1.8 else 2 if d < 1.8 else 3
            if R is PAPER and int(s) % 5 == 0 and abs(d) < 3: t = 3
        if s < 1.6: t = 3
        if 41 <= s <= 44 and abs(d) > 4: t = min(4, t + 1)
        cv.put(x, y, R[t])
    # glass shine
    for s in range(4, 26):
        x, y = O[0] + s * ux - 6.6 * nx, O[1] + s * uy - 6.6 * ny; cv.put(int(x), int(y), CREAM)
    for s in (30, 31, 35, 36, 37):
        x, y = O[0] + s * ux - 2.4 * nx, O[1] + s * uy - 2.4 * ny; cv.put(int(x), int(y), GLASS[0])
    shade(cv, cork, WOOD, "edge", rnd, .1)
    # a little red heart wax seal on the note
    for x, y in ((22, 36), (24, 36), (21, 37), (22, 37), (23, 37), (24, 37), (25, 37), (22, 38), (23, 38), (24, 38), (23, 39)):
        cv.put(x, y, EMBER[1])


def map_scrap(cv, rnd):
    paper = Mpoly([(9, 8), (54, 9), (50, 14), (56, 20), (50, 25), (55, 31), (48, 36), (53, 42), (45, 46), (47, 52),
                   (38, 50), (33, 56), (27, 51), (20, 56), (15, 52), (9, 55)])
    shade(cv, paper, PARCH, "flat", rnd, .04)
    for cx, cy, r in ((40, 44, 4), (16, 30, 3)):          # age stains
        tint(cv, pix(inter(paper, Mell(cx, cy, r, r - 1))), PARCH, 1)
    # fold creases
    px(cv, [(31, y) for y in range(9, 56) if paper.getpixel((31, y))], PARCH[3])
    px(cv, [(32, y) for y in range(9, 56) if paper.getpixel((32, y))], PARCH[0])
    px(cv, [(x, 31) for x in range(9, 56) if paper.getpixel((x, 31))], PARCH[3])
    px(cv, [(x, 32) for x in range(9, 56) if paper.getpixel((x, 32))], PARCH[0])
    # a river, two trees, a compass mark
    river = [(11, 21), (14, 19), (17, 20), (20, 17), (23, 18), (26, 15)]
    px(cv, pix(Mline(river, 2)), SEA[2])
    for tx, ty in ((15, 41), (21, 45)):
        px(cv, pix(Mpoly([(tx, ty - 4), (tx + 3, ty + 1), (tx - 3, ty + 1)])), LEAF[2])
        cv.put(tx, ty + 2, WOOD[3]); cv.put(tx - 1, ty - 1, LEAF[0])
    for dx, dy in ((0, 0), (0, -1), (0, 1), (-1, 0), (1, 0), (0, -2)): cv.put(48 + dx, 14 + dy, INK)
    # dashed path to the x
    path = bezier((14, 50), (22, 26), (39, 28), 40)
    BR = H("#7d4a35")
    for i, (x, y) in enumerate(path):
        if i % 4 < 2: cv.put(int(x), int(y), BR)
    for a, b in (((36, 23), (42, 29)), ((42, 23), (36, 29))): px(cv, pix(Mline([a, b], 2)), EMBER[2])
    # smiley face
    px(cv, pix(Mell(43, 39, 3.5, 3.5)), GOLD[1])
    px(cv, pix(minus(Mell(43, 39, 3.5, 3.5), Mell(43, 39, 2.6, 2.6))), BR)
    for x, y in ((42, 38), (44, 38), (41, 40), (42, 41), (43, 41), (44, 41), (45, 40)): cv.put(x, y, BR)
    cv.put(43, 41, BR)


def snowman_scarf(cv, rnd):
    GRN, CRM = r5(RAMP["moss"]), WOOL

    def stripes_y(x, y): return GRN if (y // 4) % 2 == 0 else CRM
    def stripes_x(x, y): return GRN if (x // 4) % 2 == 0 else CRM
    tailL = Mpoly([(18, 20), (28, 22), (27, 49), (17, 49)])
    shade(cv, tailL, stripes_y, "cyl", rnd, .04)
    ring = minus(Mell(32, 18, 16, 9), Mell(32, 17, 11, 4.5))
    shade(cv, ring, stripes_x, "hcyl", rnd, .04)
    tailR = Mpoly([(30, 22), (40, 22), (46, 47), (36, 49)])
    shade(cv, tailR, stripes_y, "cyl", rnd, .04)
    knot = Mell(33, 25, 6, 4); shade(cv, knot, GRN, "ball")
    # knit stitches
    for m, R in ((tailL, None), (tailR, None), (ring, None)):
        for x, y in pix(m):
            if x % 2 == 0 and y % 3 == 0:
                c = cv.get(x, y)
                for RR in (GRN, CRM):
                    if c in RR[:4]: cv.put(x, y, RR[RR.index(c) + 1])
    # fringe
    for x0, x1, y0, sl in ((18, 27, 49, 0), (37, 46, 48, 1)):
        for x in range(x0, x1, 2):
            for k in range(5): cv.put(x + (k * sl) // 3, y0 + k, CRM[2] if k < 4 else CRM[3])

    def post(c):
        sparkle(c, 53, 8, ICE[0]); sparkle(c, 9, 30, ICE[1])
    return post


def lost_mitten(cv, rnd):
    thumb = Mpoly(axis_poly((24, 38), -2.2, [(0, 5), (8, 5), (12, 3.5), (13.5, 1)]))
    shade(cv, thumb, EMBER, "ball", rnd, .05)
    hand = Mrr(20, 8, 45, 46, 11)
    shade(cv, hand, EMBER, "ball", rnd, .06)
    px(cv, pix(Mline([(24, 37), (21, 33)], 1)), EMBER[3])       # thumb seam
    # knitted heart
    for j, row in enumerate([".##.##.", "#######", "#######", ".#####.", "..###..", "...#..."]):
        for i, ch in enumerate(row):
            if ch == "#": cv.put(30 + i, 20 + j, WOOL[1] if i < 4 else WOOL[2])
    cuff = Mrr(18, 41, 47, 55, 3)
    shade(cv, cuff, WOOL, "hcyl", rnd, .03)
    for x in range(20, 46, 3): px(cv, [(x, y) for y in range(43, 54)], WOOL[3])
    # bell on a loop of yarn
    px(cv, pix(Mline([(45, 49), (49, 49)], 1)), EMBER[3])
    bell = Mell(51, 50, 4, 4); shade(cv, bell, GOLD, "ball")
    px(cv, [(49, 52), (50, 52), (51, 52), (52, 52), (53, 52)], GOLD[4]); cv.put(51, 53, INK)
    cv.put(50, 48, CREAM)


def glowcap_repair_kit(cv, rnd):
    # open lid (inside of the tin)
    lid = Mrr(11, 12, 54, 31, 3); shade(cv, lid, STONE, "flat", rnd, .03)
    px(cv, pix(minus(Mrr(13, 14, 52, 29, 2), Mrr(14, 15, 51, 28, 2))), STONE[3])
    # spare glass chimney
    glass = union(Mell(20, 26, 5.5, 6), Mrect(17, 14, 24, 22), Mrect(16, 12, 25, 15))
    shade(cv, glass, ICE, "cyl")
    px(cv, [(18, y) for y in range(15, 30)], CREAM)
    # coil of wicks
    coil = Mell(32, 30, 7, 4.5); shade(cv, coil, PARCH, "ball")
    px(cv, pix(minus(Mell(32, 30, 4.5, 2.5), Mell(32, 30, 3.5, 1.6))), PARCH[3])
    wick = Mline([(35, 27), (37, 22), (36, 19)], 2); shade(cv, wick, PARCH, "edge")
    cv.put(36, 18, INK)
    # very small screwdriver
    shade(cv, Mline([(44, 26), (49, 13)], 2), STONE, "edge")
    shade(cv, Mline([(41, 35), (44, 25)], 4), EMBER, "edge")
    # the tin front with a glowcap badge
    shade(cv, Mrect(9, 31, 56, 35), SEA, 0, rim=False)
    front = Mrr(9, 34, 56, 56, 2); shade(cv, front, SEA, "flat", rnd, .03)
    px(cv, [(x, 35) for x in range(10, 55)], SEA[1])
    shade(cv, Mrect(30, 32, 35, 38), GOLD, "ball")
    lab = Mrr(22, 39, 43, 54, 2); shade(cv, lab, PARCH, "flat")
    cap = inter(Mell(32.5, 46, 6, 4.5), Mrect(0, 0, 64, 47)); shade(cv, cap, GLOW, "ball")
    shade(cv, Mrect(31, 47, 34, 52), STEM, "edge")
    for x, y in ((30, 44), (35, 45)): cv.put(x, y, CREAM)

    def post(c):
        c.put(24, 41, GLOW[1]); c.put(41, 42, GLOW[1])
    return post


def glowcap_garden_light(cv, rnd):
    for a, b in (((22, 55), (19, 46)), ((24, 55), (25, 48)), ((42, 55), (45, 47)), ((40, 55), (40, 49))):
        shade(cv, Mline([a, b], 2), LEAF, "edge")
    stem = union(Mpoly([(27, 33), (37, 33), (39, 52), (25, 52)]), Mell(32, 52, 9, 3))
    shade(cv, stem, STEM, "cyl", rnd, .03, box=(23, 33, 42, 56))
    gills = Mell(32, 34, 19, 3.5); shade(cv, gills, GLOW, 3, rim=False)
    px(cv, [(x, y) for x, y in pix(gills) if x % 2 == 0 and y >= 34], GLOW[4])
    cap = inter(Mell(32, 32, 23, 20), Mrect(0, 0, 64, 34))
    shade(cv, cap, GLOW, "ball", rnd, .04, box=(9, 12, 56, 52))
    for cx, cy, r in ((22, 22, 2.5), (35, 17, 3), (45, 26, 2.5), (30, 28, 1.5), (14, 30, 1.5)):
        shade(cv, Mell(cx, cy, r, r * .8), STEM, "ball", rim=False)
    # shy face, looking away and blushing
    for x, y in ((28, 40), (28, 41), (34, 40), (34, 41)): cv.put(x, y, INK)
    for x, y in ((26, 43), (27, 43), (35, 43), (36, 43)): cv.put(x, y, PETAL[1])
    cv.put(30, 45, INK); cv.put(31, 45, INK)

    def post(c):
        for x, y, big in ((6, 18, True), (58, 14, False), (12, 6, False), (51, 4, True), (60, 34, False), (4, 38, False)):
            sparkle(c, x, y, GLOW[0] if big else GLOW[1], big)
    return post


def star_chart(cv, rnd):
    sheet = Mrect(15, 12, 50, 51); shade(cv, sheet, NIGHT, "flat", rnd, .03, rim=False)
    for y0 in (6, 49):
        roll = Mrr(11, y0, 54, y0 + 8, 3); shade(cv, roll, PARCH, "hcyl")
        px(cv, [(12, y0 + 3), (13, y0 + 4), (12, y0 + 4)], PARCH[3])
    # the sky, copied in a wobbly hand
    for x, y in ((19, 17), (26, 15), (45, 17), (20, 42), (28, 46), (44, 45), (23, 30), (47, 30), (17, 36), (40, 20)):
        cv.put(x, y, CREAM)
    LN = H("#8a9ad8")
    pts = [(21, 24), (27, 21), (33, 25), (30, 31)]
    for (a, b) in zip(pts, pts[1:]):
        for i, (x, y) in enumerate(bezier(a, ((a[0] + b[0]) / 2 + 1, (a[1] + b[1]) / 2 - 1), b, 10)):
            cv.put(int(x) + (i % 4 == 2), int(y), LN)
    for x, y in pts: sparkle(cv, x, y, CREAM)
    pts2 = [(22, 40), (27, 36), (24, 33)]
    for (a, b) in zip(pts2, pts2[1:]): px(cv, pix(Mline([a, b], 1)), LN)
    for x, y in pts2: cv.put(x, y, CREAM); cv.put(x + 1, y, GOLD[0])
    # moon
    px(cv, pix(minus(Mell(44, 22, 3.5, 3.5), Mell(46, 21, 3, 3))), GOLD[0])
    # the one you made up: big, lopsided, smiling, and a question mark
    star = []
    for k in range(10):
        a = -math.pi / 2 + k * math.pi / 5; r = 7.5 if k % 2 == 0 else 3.2
        if k == 4: r = 9
        star.append((37 + r * math.cos(a), 37 + r * math.sin(a)))
    shade(cv, Mpoly(star), GOLD, "ball")
    for x, y in ((35, 36), (39, 36), (36, 39), (37, 39), (38, 39)): cv.put(x, y, GOLD[4])
    for x, y in ((47, 39), (48, 38), (49, 38), (50, 39), (50, 40), (49, 41), (48, 42), (48, 44)): cv.put(x - 2, y, PETAL[0])


def lost_sock(cv, rnd):
    leg = Mpoly([(21, 12), (37, 12), (38, 40), (22, 42)])
    foot = union(Mrr(21, 36, 55, 55, 9), Mell(28, 46, 8, 9))
    sock = union(leg, foot)

    def stripes(x, y):
        if y < 38: return DUSK if (y // 4) % 2 == 0 else SOCKY
        return DUSK if (x // 4) % 2 == 0 else SOCKY
    shade(cv, leg, stripes, "cyl", rnd, .03, rim=False)
    shade(cv, foot, stripes, "ball", rnd, .03, box=(21, 30, 55, 56))
    darkP = r5([H("#8a6fd0"), H("#5a459e"), H("#35295f"), H("#221a40")])
    heel = inter(foot, Mell(24, 50, 6, 6)); toe = inter(foot, Mrect(48, 30, 64, 64))
    shade(cv, heel, WOOL, "flat", box=(17, 42, 31, 56), rim=False)
    shade(cv, toe, WOOL, "flat", box=(41, 36, 56, 56), rim=False)
    # rim on the outer lower right of the whole sock
    s = set(pix(sock))
    px(cv, [(x, y) for x, y in s if ((x + 1, y) not in s or (x, y + 1) not in s) and (x > 30 or y > 44)], darkP[4])
    cuff = inter(sock, Mrect(0, 12, 64, 18)); shade(cv, cuff, WOOL, "hcyl", rim=False)
    for x in range(22, 38, 2): px(cv, [(x, 13), (x, 14), (x, 15), (x, 16)], WOOL[3])
    # a patch from some old adventure, and a hole at the toe
    patch = Mrect(25, 20, 32, 27); shade(cv, patch, LEAF, "flat", rim=False)
    for x, y in pix(minus(Mrect(24, 19, 33, 28), patch)):
        if (x + y) % 2: cv.put(x, y, CREAM)
    # snagged bramble with a blackberry
    shade(cv, Mline([(30, 16), (40, 10), (48, 8)], 1), WOOD, 3)
    for x, y in ((36, 11), (44, 7)): cv.put(x, y - 1, WOOD[4])
    shade(cv, Mell(41, 7, 3, 1.6), LEAF, "ball")
    shade(cv, Mdots([(50, 9, 1.6), (52, 10, 1.6), (51, 12, 1.6)]), DUSK, "ball")


def grumpys_hedge_shears(cv, rnd):
    P = (32, 34)

    def piece(tip, hend):
        a = math.atan2(tip[1] - P[1], tip[0] - P[0]); L = math.hypot(tip[0] - P[0], tip[1] - P[1])
        blade = Mpoly(axis_poly(P, a, [(-5, 3), (0, 4), (L * .65, 3.2), (L * .92, 1.6), (L, .3)]))
        b = math.atan2(hend[1] - P[1], hend[0] - P[0]); L2 = math.hypot(hend[0] - P[0], hend[1] - P[1])
        handle = Mpoly(axis_poly(P, b, [(6, 2.8), (L2 - 2, 3), (L2, 1.5)]))
        ferrule = Mpoly(axis_poly(P, b, [(4, 3.4), (8, 3.4)]))
        shade(cv, blade, STONE, "edge", rnd, .03)
        # bright cutting edge along the inner side
        for s in range(3, int(L) - 2):
            x = P[0] + s * math.cos(a) + 2.2 * math.sin(a) * (1 if tip[0] < P[0] else -1) * -1
            y = P[1] + s * math.sin(a) - 2.2 * math.cos(a) * (1 if tip[0] < P[0] else -1) * -1
            if blade.getpixel((int(x), int(y))): cv.put(int(x), int(y), CREAM)
        shade(cv, handle, WOOD, "edge", rnd, .08)
        shade(cv, ferrule, GOLD, "edge")
    piece((50, 5), (20, 56))
    piece((14, 5), (44, 56))
    bolt = Mell(32, 34, 5, 5); shade(cv, bolt, GOLD, "ball")
    for x, y in ((29, 32), (30, 33), (35, 32), (34, 33), (30, 34), (34, 34), (31, 37), (32, 36), (33, 37)): cv.put(x, y, INK)


def tuft_of_fleece(cv, rnd):
    stone = Mrr(10, 40, 54, 56, 6); shade(cv, stone, STONE, "ball", rnd, .08, box=(8, 36, 56, 58))
    px(cv, pix(Mline([(40, 47), (44, 51), (43, 55)], 1)), STONE[4])
    px(cv, pix(Mline([(16, 50), (20, 48)], 1)), STONE[3])
    shade(cv, Mell(46, 44, 3, 1.5), MOSS, "ball", rim=False)
    for cx, cy, rx, ry in ((34, 15, 8, 7), (21, 27, 9, 8), (44, 26, 9, 8), (32, 24, 10, 9), (26, 37, 10, 6), (40, 37, 10, 6)):
        lump(cv, cx, cy, rx, ry, WOOL, rnd, .06)
    # curls
    for x, y in ((29, 20), (39, 30), (20, 30), (33, 37), (44, 22), (24, 36)):
        for dx, dy in ((0, 0), (1, -1), (2, -1), (3, 0), (2, 1)): cv.put(x + dx, y + dy, WOOL[3])
        cv.put(x + 1, y, WOOL[0])
    # a wisp still caught on the stone edge
    shade(cv, Mline([(48, 40), (53, 38), (56, 34)], 2), WOOL, "edge")


def daisy(cv, cx, cy, r, back=False):
    pet = Mdots([(cx + r * .9 * math.cos(k * math.pi / 4), cy + r * .7 * math.sin(k * math.pi / 4), r * .55) for k in range(8)])
    W = WOOL if not back else [WOOL[1], WOOL[2], WOOL[3], WOOL[4], WOOL[4]]
    shade(cv, pet, W, "ball")
    shade(cv, Mell(cx, cy, max(1, r * .45), max(1, r * .4)), GOLD, "ball")


def daisy_chain_crown(cv, rnd):
    cx, cy, rx, ry = 32, 39, 22, 12
    ring = minus(Mell(cx, cy, rx, ry), Mell(cx, cy, rx - 3, ry - 3))
    back = inter(ring, Mrect(0, 0, 64, cy)); front = inter(ring, Mrect(0, cy, 64, 64))
    shade(cv, back, [LEAF[2], LEAF[3], LEAF[3], LEAF[4], LEAF[4]], "edge")
    for k in (1, 2, 4, 5):
        a = -math.pi * k / 6
        daisy(cv, cx + (rx - 1.5) * math.cos(a), cy + (ry - 1.5) * math.sin(a), 2.8, back=True)
    # standing daisies on stems: the crown points
    pts = [(16, 30), (24, 27), (32, 26), (40, 27), (48, 30)]
    for i, (x, y) in enumerate(pts):
        h = 11 if i == 2 else 8 if i in (1, 3) else 6
        pass
    for i, (x, y) in enumerate(pts):
        h = 11 if i == 2 else 8 if i in (1, 3) else 6
        daisy(cv, x + (i - 2) * .5, y - h, 4.6 if i == 2 else 4)
    shade(cv, front, LEAF, "edge")
    for a in (math.pi + .3, -.3):
        daisy(cv, cx + (rx - 1.5) * math.cos(a), cy + (ry - 1.5) * math.sin(a), 3.4)
    for k in range(7):
        a = math.pi * (k + .5) / 7
        daisy(cv, cx + (rx - 1.5) * math.cos(a), cy + (ry - 1.5) * math.sin(a), 3.8)
    # tiny leaves between the front daisies
    for k in range(6):
        a = math.pi * (k + 1) / 7
        shade(cv, Mell(cx + (rx - 1.5) * math.cos(a), cy + (ry - .5) * math.sin(a) + 1, 1.6, 1.2), LEAF, "ball")


def dew_pearl(cv, rnd):
    # leaf
    O, ang, L = (5, 52), -.12, 54
    segs = [(s, 7.5 * math.sin(math.pi * min(1, s / L)) ** .8 + .3) for s in range(0, L + 1, 3)]
    leaf = Mpoly(axis_poly(O, ang, segs))
    shade(cv, leaf, LEAF, "ball", rnd, .05)
    px(cv, pix(Mline([O, (O[0] + L * math.cos(ang), O[1] + L * math.sin(ang))], 1)), LEAF[0])
    for s in (12, 22, 36, 44):
        x0, y0 = O[0] + s * math.cos(ang), O[1] + s * math.sin(ang)
        px(cv, pix(Mline([(x0, y0), (x0 + 5, y0 - 4)], 1)) + pix(Mline([(x0, y0), (x0 + 5, y0 + 4)], 1)), LEAF[1])
    # the drop, very pleased with itself
    drop = union(Mell(32, 30, 16, 15), Mell(32, 41, 13, 6))
    shade(cv, drop, DEW, "ball", rnd, .02, box=(16, 15, 48, 47))
    crescent = minus(Mell(33, 33, 12, 11), Mell(30, 30, 12, 11))
    px(cv, [p for p in pix(inter(crescent, drop))], DEW[1])
    shade(cv, Mell(24, 22, 3.5, 2.5), [CREAM] * 5, 0, rim=False)
    for x, y in ((29, 18), (30, 18), (21, 27), (27, 25)): cv.put(x, y, CREAM)
    for x, y in ((25, 25), (26, 26), (22, 19)): cv.put(x, y, PETAL[0])
    for x, y in ((26, 32), (27, 31), (28, 32), (35, 32), (36, 31), (37, 32)): cv.put(x, y, INK)
    for x, y in ((29, 36), (30, 37), (31, 37), (32, 37), (33, 37), (34, 36)): cv.put(x, y, INK)
    for x, y in ((24, 35), (25, 35), (38, 35), (39, 35)): cv.put(x, y, PETAL[1])

    def post(c):
        sparkle(c, 50, 12, CREAM, True); sparkle(c, 12, 16, CREAM)
    return post


def root_race_ribbon(cv, rnd):
    for poly in ([(23, 33), (32, 34), (26, 55), (22, 50), (17, 54)], [(32, 34), (41, 33), (47, 54), (42, 50), (38, 55)]):
        shade(cv, Mpoly(poly), BLUE, "cyl", rnd, .02)
    C = (32, 23)
    outer = Mpoly([(C[0] + (16 + 1.6 * math.cos(16 * a)) * math.cos(a), C[1] + (16 + 1.6 * math.cos(16 * a)) * math.sin(a))
                   for a in (k * math.pi / 64 for k in range(128))])
    t = shade(cv, outer, BLUE, "ball", rnd, .0)
    for x, y in pix(outer):
        a = math.atan2(y + .5 - C[1], x + .5 - C[0])
        if int((a + math.pi) * 16 / (2 * math.pi) * 2) % 2: tint(cv, [(x, y)], BLUE, 1)
    mid = Mell(C[0], C[1], 11.5, 11.5); shade(cv, mid, BLUE, "ball")
    for k in range(12):
        a = k * math.pi / 6
        px(cv, pix(inter(Mline([C, (C[0] + 12 * math.cos(a), C[1] + 12 * math.sin(a))], 1), minus(mid, Mell(C[0], C[1], 8, 8)))), BLUE[3])
    disc = Mell(C[0], C[1], 7.5, 7.5); shade(cv, disc, GOLD, "ball")
    # a big '1' for first across the roots
    for j, row in enumerate(["..#.", ".##.", "#.#.", "..#.", "..#.", "..#.", ".###"]):
        for i, ch in enumerate(row):
            if ch == "#": cv.put(30 + i, C[1] - 3 + j, GOLD[4])
    cv.put(28, C[1] - 4, CREAM); cv.put(27, C[1] - 3, GOLD[0])


def glow_moss_nightlight(cv, rnd):
    jar = union(Mrr(17, 20, 48, 57, 8), Mrect(22, 15, 43, 22))
    inner = union(Mrr(19, 22, 46, 55, 6), Mrect(24, 17, 41, 23))
    shade(cv, jar, ICE, "cyl", rnd, 0)
    shade(cv, inner, JARDARK, "ball", box=(14, 12, 52, 58), rim=False)
    # glowing moss cushion
    moss = Cv(S, S)
    for cx, cy, rx, ry in ((26, 49, 7, 5), (38, 48, 8, 6), (32, 46, 7, 5), (24, 53, 7, 3), (40, 53, 7, 3), (32, 52, 9, 4)):
        lump(moss, cx, cy, rx, ry, GLOW, rnd, .1)
    for x, y in pix(inner):
        c = moss.get(x, y)
        if c[3]: cv.put(x, y, c)
    for x, y in ((27, 44), (33, 42), (39, 45), (22, 48)): cv.put(x, y, CREAM)
    for x, y in ((25, 36), (34, 31), (40, 38), (29, 27), (37, 24), (23, 30), (31, 38)): cv.put(x, y, GLOW[1])
    for x, y in ((36, 34), (28, 33)): sparkle(cv, x, y, GLOW[0])
    px(cv, [(20, y) for y in range(26, 50)] + [(21, y) for y in range(24, 27)], CREAM)
    px(cv, [(45, y) for y in range(28, 44)], ICE[0])
    # cork and a string loop to hang it by
    shade(cv, Mrr(20, 9, 46, 17, 2), WOOD, "cyl", rnd, .1)
    shade(cv, M(lambda d: d.arc((24, 6, 41, 20), 200, 340, fill=255, width=2)), PARCH, "edge")


def bookmark_snail(cv, rnd):
    COVER = DUSK
    spine = Mpoly([(6, 40), (30, 48), (30, 55), (6, 47)])
    pages = Mpoly([(30, 48), (58, 38), (58, 45), (30, 55)])
    top = Mpoly([(6, 40), (33, 30), (58, 38), (30, 48)])
    shade(cv, spine, COVER, 2, rim=False)
    for x in (12, 13, 22, 23): px(cv, [(x, y) for y in range(40, 56) if spine.getpixel((x, y))], GOLD[1])
    shade(cv, pages, PARCH, 1, rim=False)
    for y in range(36, 56, 2): px(cv, [(x, y - (x - 30) * 10 // 28) for x in range(31, 58) if pages.getpixel((x, y - (x - 30) * 10 // 28))], PARCH[2])
    px(cv, [(x, 55 - (x - 30) * 10 // 28) for x in range(30, 59)], COVER[3])
    shade(cv, top, COVER, 1, rnd, .03, rim=False)
    px(cv, [(x, y) for x, y in pix(top) if not top.getpixel((x, y - 1))], COVER[0])
    px(cv, [(x, y) for x, y in pix(top) if not top.getpixel((x, y + 1))], COVER[3])
    # ribbon bookmark
    shade(cv, Mpoly([(46, 42), (49, 41), (50, 53), (48, 51), (46, 54)]), GOLD, "edge")
    # the snail: foot, head, stalks, shell
    shade(cv, Mell(31, 37, 14, 3.5), SNAIL, "ball", rnd, .04)
    head = Mell(19, 31, 4.5, 6); shade(cv, head, SNAIL, "ball")
    for a, b in (((18, 27), (15, 19)), ((21, 27), (23, 19))):
        shade(cv, Mline([a, b], 2), SNAIL, "edge")
        shade(cv, Mell(b[0], b[1], 2, 2), SNAIL, "ball")
        cv.put(b[0], b[1], INK)
    for x, y in ((17, 33), (18, 34), (19, 34), (20, 33)): cv.put(x, y, INK)
    cv.put(22, 33, PETAL[1])
    shell = Mell(36, 25, 11, 10); shade(cv, shell, WOOD, "ball", rnd, .05)
    sp = [(36 + (1 + t * .9) * math.cos(t), 26 + (1 + t * .85) * math.sin(t)) for t in (k * .15 for k in range(66))]
    for x, y in sp:
        if shell.getpixel((int(x), int(y))): cv.put(int(x), int(y), WOOD[4])
    for x, y in ((30, 19), (31, 18), (32, 18)): cv.put(x, y, CREAM)


def fern_drip_hat_charm(cv, rnd):
    C, R0 = (31, 19), 11
    stem = bezier((24, 52), (48, 43), (C[0] + R0, C[1]), 30)
    spiral = []
    for k in range(60):
        th = k * .12; r = R0 * (1 - th / (2.3 * math.pi))
        if r < 2: break
        spiral.append((C[0] + r * math.cos(-th), C[1] + r * math.sin(-th)))
    path = stem + spiral
    # leaflets along the stem, then the stem over them
    for i in range(3, len(path) - 6, 3):
        (x0, y0), (x1, y1) = path[i - 1], path[i + 1]
        a = math.atan2(y1 - y0, x1 - x0); n = len(path)
        Lf = 6.5 * (1 - i / n) + 2
        for side in (1, -1):
            ang = a + side * 1.15
            if i > len(stem) and side == 1: continue
            m = Mpoly(axis_poly(path[i], ang, [(0, 1), (Lf * .5, 2.2), (Lf, .4)]))
            shade(cv, m, MOSS, "edge")
    w = lambda i: 4 if i < len(stem) * .5 else 3 if i < len(stem) + 20 else 2
    m = Mdots([(x, y, w(i) / 2) for i, (x, y) in enumerate(path)])
    shade(cv, m, LEAF, "edge")
    # little gold ring to pin it to a hat
    ring = minus(Mell(23, 53, 3.5, 3.2), Mell(23, 53, 1.4, 1.2)); shade(cv, ring, GOLD, "ball")
    # rain politely redirected
    for x, y in ((13, 11), (7, 23), (53, 10)):
        shade(cv, union(Mell(x, y + 1, 1.8, 1.8), Mpoly([(x, y - 3), (x + 1.6, y + .5), (x - 1.6, y + .5)])), SEA, "ball")

    def post(c):
        for x, y in ((17, 9), (18, 10), (19, 12), (14, 17), (13, 19), (12, 21), (47, 12), (49, 11)): c.put(x, y, ICE[1])
    return post


ITEMS = {
    "flour": flour, "maple-sap": maple_sap, "maple-syrup": maple_syrup, "toffee": toffee, "marshmallow": marshmallow,
    "message-bottle": message_bottle, "map-scrap": map_scrap, "snowman-scarf": snowman_scarf, "lost-mitten": lost_mitten,
    "glowcap-repair-kit": glowcap_repair_kit, "glowcap-garden-light": glowcap_garden_light, "star-chart": star_chart,
    "lost-sock": lost_sock, "grumpys-hedge-shears": grumpys_hedge_shears, "tuft-of-fleece": tuft_of_fleece,
    "daisy-chain-crown": daisy_chain_crown, "dew-pearl": dew_pearl, "root-race-ribbon": root_race_ribbon,
    "glow-moss-nightlight": glow_moss_nightlight, "bookmark-snail": bookmark_snail, "fern-drip-hat-charm": fern_drip_hat_charm,
}


def render(slug):
    rnd = random.Random(zlib.crc32(slug.encode()))
    cv = Cv(S, S)
    post = ITEMS[slug](cv, rnd)
    outline(cv)
    if post: post(cv)
    bb = cv.im.getbbox()
    dx, dy = round(32 - (bb[0] + bb[2]) / 2), 57 - bb[3]
    obj = Image.new("RGBA", (S, S), (0, 0, 0, 0)); obj.paste(cv.im, (dx, dy))
    if bb[1] + dy < 2 or bb[0] + dx < 1 or bb[2] + dx > S - 1: print(f"warning: {slug} touches the edge", file=sys.stderr)
    # flat two-tone ground shadow under the footprint (the lowest rows of the object)
    a = obj.split()[3]; b = a.getbbox()
    foot = a.crop((0, b[3] - 7, S, b[3])).getbbox()
    fx0, fx1 = foot[0], foot[2]
    cx, rx = (fx0 + fx1) / 2, max(9, min(29, (fx1 - fx0) / 2 + 3))
    sh = Image.new("RGBA", (S, S), (0, 0, 0, 0)); d = ImageDraw.Draw(sh)
    d.ellipse((round(cx - rx), 54, round(cx + rx), 58), fill=SH_OUT)
    d.ellipse((round(cx - rx) + 2, 54, round(cx + rx) - 4, 57), fill=SH_IN)
    sh.alpha_composite(obj)
    return sh


def main():
    os.makedirs(OUT, exist_ok=True)
    for slug in ITEMS:
        render(slug).save(os.path.join(OUT, slug + ".png"))
    print(f"wrote {len(ITEMS)} item pictures to {OUT}")


if __name__ == "__main__":
    main()
