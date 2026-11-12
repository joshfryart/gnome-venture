#!/usr/bin/env python3
"""Item pictures (Hearth Pop v3) for a later batch of Sight items (trail_sight_items*.txt): mirror-pebble ... feather-pillow.
64 x 64 RGBA, hard pixels, 5-tone ramps lit from the top-left, 1 px ink outline, flat two-tone ground shadow.
Helpers copied from tools/gen_sight_item_art_a.py so the pictures match.
Deterministic and re-runnable:  python3 tools/gen_sight_item_art_e.py [slug ...]   -> game/assets/img/ph/<slug>.png"""
import math, os, random, sys, zlib
from PIL import Image, ImageDraw, ImageChops

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "claude", "tile-art-v3-proposal"))
import gen2  # noqa: E402,F401
from gen2 import RAMP, INK, CREAM, H, r5, Cv, outline, lump, tone5, shade_pt  # noqa: E402

OUT = os.path.join(ROOT, "game", "assets", "img", "ph")
S = 64
SH_IN, SH_OUT = H("#aaa9b8"), H("#74758c")   # ground shadow, as on the existing item pictures


def ramp(*hx): return [H(h) for h in hx]


STONE, WOOD, GOLD, EMBER = r5(RAMP["stone"]), r5(RAMP["wood"]), r5(RAMP["gold"]), r5(RAMP["ember"])
LEAF, MOSS, SEA, DUSK, ICE, PETAL = r5(RAMP["leaf"]), r5(RAMP["moss"]), r5(RAMP["sea"]), r5(RAMP["dusk"]), r5(RAMP["ice"]), r5(RAMP["petal"])
SNOW, PINE, SAND = r5(RAMP["snow"]), r5(RAMP["pine"]), r5(RAMP["sand"])
WOOL = ramp("#fffdf4", "#f7efdb", "#e6d8bc", "#c4b090", "#8d7a66")
PARCH = ramp("#fff6dc", "#f5e3b4", "#e4c88e", "#c49c66", "#8a6448")
TOAST = ramp("#fff0c4", "#f5c46e", "#d48a3e", "#9a5530", "#5e3326")
NIGHT = ramp("#5a6fb8", "#45569a", "#36437e", "#2a3263", "#1d2346")
BLUE = ramp("#cfe6ff", "#8ab8f2", "#4f7fd6", "#2f50a0", "#22305f")
DEW = ramp("#f2fdff", "#c6f0fb", "#86d3ee", "#4c9ad0", "#2f5e9a")
SILVER = ramp("#ffffff", "#e6e8f0", "#bcc0d0", "#8a8ea8", "#5a5c78")
SKIN = ramp("#fff0e0", "#ffd2b4", "#f0a888", "#c87866", "#8a4a48")
PEB = ramp("#f0e8dc", "#d4c8b8", "#a89c8e", "#7a6e66", "#4e4648")
SLATE = ramp("#d0dcf0", "#a2b4d6", "#768cb6", "#536894", "#36446c")
SAGE = ramp("#e2ecd2", "#b8cca6", "#8ca67e", "#62805e", "#40564a")
ROSE = ramp("#f8e0d6", "#e4b8ac", "#c08e88", "#90666c", "#5e4452")
DRIFT = ramp("#f4ead6", "#dccaa8", "#b6a184", "#887760", "#5c4f44")
SALT = ramp("#ffffff", "#f3f5fa", "#dce2ec", "#b0b8cc", "#7c84a0")
PLANK = ramp("#fae0b4", "#eec890", "#d8a66e", "#ae7a4c", "#7a5038")
LEATHER = ramp("#dc9868", "#b46a42", "#8c4a30", "#623226", "#40201e")
COCOA = ramp("#d8a07a", "#a86a48", "#7c4834", "#58302a", "#3a2022")
BR = H("#7d4a35")


# ------------------------------------------------------------------ masks (from gen_sight_item_art_a.py)
def M(fn):
    m = Image.new("L", (S, S), 0); fn(ImageDraw.Draw(m)); return m
def Mpoly(pts): return M(lambda d: d.polygon([(float(x), float(y)) for x, y in pts], fill=255))
def Mell(cx, cy, rx, ry): return M(lambda d: d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=255))
def Mrect(x0, y0, x1, y1): return M(lambda d: d.rectangle((x0, y0, x1 - 1, y1 - 1), fill=255))
def Mrr(x0, y0, x1, y1, r): return M(lambda d: d.rounded_rectangle((x0, y0, x1 - 1, y1 - 1), radius=r, fill=255))
def Mline(pts, w): return M(lambda d: d.line([(float(x), float(y)) for x, y in pts], fill=255, width=w, joint="curve"))
def Mdots(pts):
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


def shade(cv, m, R, mode="ball", rnd=None, speck=0.0, rim=True, hi=True, box=None):
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


def axis_poly(O, ang, segs):
    ux, uy = math.cos(ang), math.sin(ang); nx, ny = -uy, ux
    a = [(O[0] + s * ux + w * nx, O[1] + s * uy + w * ny) for s, w in segs]
    b = [(O[0] + s * ux - w * nx, O[1] + s * uy - w * ny) for s, w in reversed(segs)]
    return a + b


def bezier(p0, p1, p2, n):
    return [((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0],
             (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]) for t in (i / n for i in range(n + 1))]


def rot(c, ang, pts):
    ca, sa = math.cos(ang), math.sin(ang)
    return [(c[0] + x * ca - y * sa, c[1] + x * sa + y * ca) for x, y in pts]


def glyph(cv, x0, y0, rows, c, shadow=None):
    for j, row in enumerate(rows):
        for i, ch in enumerate(row):
            if ch == "#":
                cv.put(x0 + i, y0 + j, c)
                if shadow and (j + 1 >= len(rows) or row_at(rows, i, j + 1) != "#"): cv.put(x0 + i, y0 + j + 1, shadow)


def row_at(rows, i, j): return rows[j][i] if 0 <= j < len(rows) and 0 <= i < len(rows[j]) else "."


def note(cv, x, y, c, flag=True):
    """Eighth note with its head's top-left at (x, y)."""
    px(cv, [(x, y), (x + 1, y), (x - 1, y + 1), (x, y + 1), (x + 1, y + 1), (x - 1, y)], c)
    px(cv, [(x + 1, y - k) for k in range(1, 6)], c)
    if flag: px(cv, [(x + 2, y - 4), (x + 3, y - 3), (x + 3, y - 2)], c)


def heart(cv, x, y, c, d):
    for j, row in enumerate([".#.#.", "#####", ".###.", "..#.."]):
        for i, ch in enumerate(row):
            if ch == "#": cv.put(x + i, y + j, d if (i >= 3 and j >= 1) else c)


# ------------------------------------------------------------------ items
def mirror_pebble(cv, rnd):
    side = Mell(32, 43, 24, 11); shade(cv, side, STONE, 3, rnd, .05)
    top = Mell(32, 39, 24, 11); shade(cv, top, STONE, "ball", rnd, .06, box=(6, 26, 58, 54))
    mirror = Mell(31, 38, 17, 7.5)
    bevel = minus(Mell(31, 38.5, 18.5, 9), mirror)
    for x, y in pix(bevel): cv.put(x, y, STONE[0] if y < 38 else STONE[3])
    shade(cv, mirror, SILVER, "flat", rim=False)
    # your reflection: a little gnome, smiling (it always is)
    g = Cv(S, S)
    shade(g, Mpoly([(25, 38), (37, 38), (31, 30)]), EMBER, "ball")
    shade(g, Mell(31, 40, 4.5, 3.5), SKIN, "ball", rim=False)
    shade(g, Mell(31, 44, 4.5, 2.5), WOOL, "ball", rim=False)
    for x, y in ((29, 39), (33, 39)): g.put(x, y, INK)
    for x, y in ((29, 41), (30, 42), (31, 42), (32, 42), (33, 41)): g.put(x, y, BR)
    g.put(27, 41, PETAL[1]); g.put(35, 41, PETAL[1])
    for x, y in pix(mirror):
        c = g.get(x, y)
        if c[3]: cv.put(x, y, c)
    px(cv, pix(Mline([(17, 39), (21, 33)], 1)) + pix(Mline([(20, 40), (23, 35)], 1)) + pix(Mline([(41, 42), (44, 37)], 1)), CREAM)

    def post(c):
        sparkle(c, 50, 28, CREAM, True); sparkle(c, 13, 26, CREAM)
    return post


def dare_pebble(cv, rnd):
    shade(cv, Mell(32, 52, 21, 4), SEA, "ball")            # the puddle it was won from
    px(cv, [(18, 51), (19, 51), (20, 51), (44, 53), (45, 53)], SEA[0])

    def bands(x, y):
        k = int((y + .05 * (x - 32) ** 2 + .35 * (x - 32)) / 4.5) % 4
        return (PETAL, WOOL, DUSK, WOOL)[k]
    egg = Mell(32, 33, 14, 18)
    shade(cv, egg, bands, "ball", rnd, .03)
    px(cv, pix(Mline([(23, 25), (26, 20)], 2)), CREAM); cv.put(23, 28, CREAM)
    # a gold star sticker, for being slightly too brave
    st = [(39 + (4.5 if k % 2 == 0 else 2) * math.cos(-math.pi / 2 + k * math.pi / 5),
           38 + (4.5 if k % 2 == 0 else 2) * math.sin(-math.pi / 2 + k * math.pi / 5)) for k in range(10)]
    shade(cv, Mpoly(st), GOLD, "ball", rim=False)
    # splashes
    for x, y in ((12, 40), (52, 36), (49, 44)):
        shade(cv, union(Mell(x, y + 1, 1.8, 1.8), Mpoly([(x, y - 3), (x + 1.6, y + .5), (x - 1.6, y + .5)])), SEA, "ball")


def rivers_postcard(cv, rnd):
    shade(cv, Mrr(6, 18, 58, 50, 6), PEB, 3, rnd, .05)
    top = union(Mrr(6, 13, 58, 45, 6))
    top = minus(top, Mpoly([(50, 13), (58, 13), (58, 19)]))       # chipped corner
    shade(cv, top, PEB, "flat", rnd, .06)
    # the river's handwriting: wavy lines on the left
    for y0 in (20, 25, 30, 35):
        for x in range(11, 33):
            y = y0 + round(1.3 * math.sin(x * .7 + y0))
            cv.put(x, y, SEA[3]); cv.put(x, y + 1, SEA[1])
    px(cv, [(36, y) for y in range(18, 41)], PEB[3]); px(cv, [(37, y) for y in range(18, 41)], PEB[0])
    # a stamp with a raindrop, and the address
    stamp = Mrect(42, 18, 53, 29); shade(cv, stamp, WOOL, 1, rim=False)
    px(cv, [(x, y) for x, y in pix(stamp) if (x in (42, 52) or y in (18, 28)) and (x + y) % 2], PEB[2])
    shade(cv, Mrect(44, 20, 51, 27), DEW, 1, rim=False)
    drop = union(Mell(47.5, 24.5, 1.8, 1.8), Mpoly([(47.5, 21), (49.2, 24), (45.8, 24)])); shade(cv, drop, SEA, 2, rim=False)
    for y in (33, 37, 41):
        for x in range(40, 55):
            if (x * 7 + y) % 11: cv.put(x, y, SEA[3])


def blue_stitch_hat_patch(cv, rnd):
    C, ang = (28, 30), math.radians(-10)
    sq = lambda h: rot(C, ang, [(-h, -h), (h, -h), (h, h), (-h, h)])
    patch = Mpoly(sq(17)); shade(cv, patch, BLUE, "ball", rnd, .04)
    # running stitch round the edge
    pts = sq(14)
    for (ax, ay), (bx, by) in zip(pts, pts[1:] + pts[:1]):
        for k in range(28):
            if k % 4 < 2:
                t = k / 28; cv.put(round(ax + (bx - ax) * t), round(ay + (by - ay) * t), WOOL[0])
    # the dragonfly
    for cx, cy, rx, ry in ((22, 25, 6, 2.5), (34, 24, 6, 2.5), (22, 30, 5, 2), (34, 29, 5, 2)):
        shade(cv, Mell(cx, cy, rx, ry), ICE, "ball", rim=False)
    shade(cv, Mline([(28, 22), (29, 40)], 2), GOLD, "edge")
    shade(cv, Mell(28, 21, 2, 2), GOLD, "ball")
    cv.put(27, 20, INK); cv.put(29, 20, INK)
    # needle and thread
    shade(cv, Mline([(42, 54), (58, 40)], 2), SILVER, "edge")
    cv.put(56, 41, INK)
    for x, y in bezier((44, 44), (54, 50), (56, 42), 14): cv.put(round(x), round(y), BLUE[1])

    def post(c):
        sparkle(c, 10, 10, ICE[0])
    return post


def parrot_phrasebook(cv, rnd):
    page = Mpoly([(12, 8), (44, 8), (51, 15), (51, 54), (12, 54)])
    shade(cv, page, PARCH, "flat", rnd, .03)
    shade(cv, Mpoly([(44, 8), (44, 15), (51, 15)]), PARCH, 3, rim=False)
    # parrot portrait
    shade(cv, Mpoly([(17, 14), (20, 9), (22, 14)]), EMBER, "ball")
    shade(cv, Mell(22, 19, 6, 6), LEAF, "ball")
    shade(cv, Mpoly([(26, 16), (31, 17), (30, 22), (27, 21)]), GOLD, "ball")
    shade(cv, Mell(21, 18, 2, 2), WOOL, 0, rim=False); cv.put(22, 18, INK)
    # speech bubble
    shade(cv, union(Mrr(31, 12, 47, 23, 4), Mpoly([(32, 20), (35, 22), (29, 24)])), WOOL, "flat", rim=False)
    for x in (35, 39, 43): px(cv, [(x, 17), (x + 1, 17)], BR)
    px(cv, pix(minus(union(Mrr(30, 11, 48, 24, 4), Mpoly([(31, 20), (35, 23), (28, 25)])), union(Mrr(31, 12, 47, 23, 4), Mpoly([(32, 20), (35, 22), (29, 24)])))), PARCH[4])
    # three languages, three little flags
    for y, F in ((30, EMBER), (37, SEA), (44, GOLD)):
        shade(cv, Mrect(16, y - 1, 21, y + 3), F, 1, rim=False)
        px(cv, [(16, y - 1 + k) for k in range(4)], F[3])
        for x in range(24, 47):
            if (x * 5 + y) % 13 > 2: cv.put(x, y + (x % 4 == 0), BR)
    # a red parrot feather tucked in
    O, a = (36, 56), math.radians(-42)
    vane = Mpoly(axis_poly(O, a, [(3, 1), (8, 3.5), (16, 3.8), (22, 2), (24, .5)]))
    shade(cv, vane, lambda x, y: SEA if (x - O[0]) * math.cos(a) + (y - O[1]) * math.sin(a) > 18 else EMBER, "ball")
    px(cv, pix(Mline([O, (O[0] + 23 * math.cos(a), O[1] + 23 * math.sin(a))], 1)), WOOL[1])


def planks_gratitude(cv, rnd):
    side = union(Mrect(8, 36, 57, 45), Mell(32.5, 45, 24.5, 9))
    shade(cv, side, PLANK, "cyl", rnd, .04, box=(8, 30, 57, 55))
    for x in range(12, 55, 5): px(cv, [(x, y) for y in range(38, 54) if side.getpixel((x, y)) and (x + y) % 3], PLANK[3])
    top = Mell(32.5, 36, 24.5, 9.5); shade(cv, top, PLANK, "flat", rnd, .03)
    for k in (.72, .44):
        ring = minus(Mell(32.5, 36, 24.5 * k, 9.5 * k), Mell(32.5, 36, 24.5 * k - 1.2, 9.5 * k - .9))
        px(cv, pix(ring), PLANK[2])
    # very grateful face
    for x, y in ((24, 35), (25, 34), (26, 35), (39, 35), (40, 34), (41, 35)): cv.put(x, y, INK)
    for x, y in ((30, 38), (31, 39), (32, 39), (33, 39), (34, 39), (35, 38)): cv.put(x, y, INK)
    for x, y in ((21, 37), (22, 37), (43, 37), (44, 37)): cv.put(x, y, PETAL[1])

    def post(c):
        heart(c, 14, 20, PETAL[1], PETAL[3]); heart(c, 45, 15, PETAL[1], PETAL[3]); heart(c, 30, 9, PETAL[0], PETAL[2])
    return post


def scree_xylophone(cv, rnd):
    def rail(y0, y1): return Mline([(7, y0), (57, y1)], 3)
    shade(cv, rail(19, 32), WOOD, "edge"); shade(cv, rail(50, 37), WOOD, "edge")
    for x0, y0, x1, y1 in ((6, 17, 9, 53), (54, 30, 58, 40)):
        shade(cv, Mrr(x0, y0, x1, y1, 1), WOOD, "cyl")
    stones = [STONE, PEB, SLATE, SAND, SAGE, ROSE, STONE]
    for i, R in enumerate(stones):
        cx = 13 + i * 6.4; top = 13 + i * 2.2; bot = 55 - i * 2.4
        bar = union(Mrr(cx - 2.6, top, cx + 2.6, bot, 2), Mell(cx + (.5 if i % 2 else -.5), top + 2, 2.6, 2))
        shade(cv, bar, R, "cyl", rnd, .1, box=(cx - 3, top, cx + 3, bot))
        cv.put(int(cx) - 1, int(top) + 2, R[0])
    # the string, threaded through every stone
    for (y0, y1) in ((19, 32), (50, 37)):
        for x in range(7, 58):
            y = round(y0 + (y1 - y0) * (x - 7) / 50)
            if (x - 11) % 6 in (0, 1, 2, 3): pass
            c = cv.get(x, y)
            if c in WOOD: continue
            cv.put(x, y, PARCH[3] if x % 2 else PARCH[1])
    # tick, tock, chatter
    note(cv, 47, 14, DUSK[2]); note(cv, 55, 20, DUSK[2], flag=False)


def waterfall_sketch(cv, rnd):
    for a, b in (((16, 40), (10, 56)), ((48, 40), (54, 56)), ((32, 38), (32, 54))):
        shade(cv, Mline([a, b], 3), WOOD, "edge")
    frame = Mrr(6, 6, 58, 46, 2); shade(cv, frame, WOOD, "ball", rnd, .05)
    px(cv, pix(minus(Mrect(9, 9, 55, 43), Mrect(10, 10, 54, 42))), WOOD[4])
    # the painting: cliffs, falls, and mostly mist
    shade(cv, Mrect(10, 10, 54, 42), ICE, 1, rim=False)
    shade(cv, Mpoly([(10, 13), (17, 11), (26, 14), (25, 42), (10, 42)]), SAGE, "flat", rim=False)
    shade(cv, Mpoly([(39, 15), (46, 12), (54, 14), (54, 42), (39, 42)]), SAGE, "flat", rim=False)
    for x, y in ((12, 18), (14, 24), (48, 20), (51, 27), (19, 21)): cv.put(x, y, SAGE[4])
    falls = Mrect(26, 14, 39, 36)
    for x, y in pix(falls): cv.put(x, y, DEW[[0, 1, 2, 1, 0, 2, 1][(x - 26) % 7]] if (y + x * 3) % 9 else CREAM)
    for x in range(26, 39): cv.put(x, 14, DEW[3])
    for cx, cy, rx, ry in ((18, 38, 9, 5), (31, 35, 9, 6), (44, 38, 9, 5), (25, 40, 8, 3), (38, 40, 9, 3), (32, 31, 6, 4)):
        lump(cv, cx, cy, rx, ry, WOOL, rnd, .03)
    for x, y in pix(minus(Mrect(10, 30, 54, 42), Mrect(10, 10, 54, 42))): pass
    # (the mist spilled over the frame a bit: trim it back to the canvas)
    for x, y in pix(Mrect(0, 0, 64, 64)):
        if not Mrect(10, 10, 54, 42).getpixel((x, y)) and frame.getpixel((x, y)) and cv.get(x, y) in WOOL:
            cv.put(x, y, WOOD[2] if y < 26 else WOOD[3])
    # ledge and a brush she let you hold
    shade(cv, Mrect(8, 44, 57, 48), WOOD, "edge")
    shade(cv, Mline([(30, 45), (52, 41)], 2), WOOD, "edge")
    shade(cv, Mline([(52, 41), (57, 40)], 2), STONE, "edge")
    shade(cv, Mell(59, 39.5, 2.2, 1.6), SEA, "ball")


def arch_shell_mobile(cv, rnd):
    hang = [(14, 37), (25, 47), (39, 43), (50, 32)]
    arch = bezier((7, 24), (32, 0), (57, 24), 40)
    for (x0, y0), (x, y1) in zip([(round(x), round(bezier((7, 24), (32, 0), (57, 24), 40)[min(range(41), key=lambda i: abs(arch[i][0] - x))][1])) for x, _ in hang], hang):
        px(cv, [(x, y) for y in range(y0, y1)], PARCH[4])
    shade(cv, Mline(arch, 4), DRIFT, "edge", rnd, .12)
    for x, y in ((7, 24), (57, 24)): shade(cv, Mell(x, y + 1, 2.5, 2.5), DRIFT, "ball")
    for x, y in ((18, 13), (30, 11), (44, 13)): cv.put(x, y, DRIFT[4])
    shade(cv, minus(Mell(32, 6, 3.5, 3.5), Mell(32, 6, 1.6, 1.6)), PARCH, "edge")
    # scallop (pink)
    x, y = hang[0]
    fan = Mpoly([(x, y + 9)] + [(x + 8 * math.cos(a), y + 9 + 8 * math.sin(a)) for a in (math.radians(d) for d in range(-160, -19, 10))])
    shade(cv, union(fan, Mrect(x - 2, y + 7, x + 3, y + 11)), PETAL, "ball")
    for d in (-140, -115, -90, -65, -40):
        a = math.radians(d); px(cv, pix(inter(Mline([(x, y + 9), (x + 8 * math.cos(a), y + 9 + 8 * math.sin(a))], 1), fan)), PETAL[3])
    # cone shell (sand, with bands)
    x, y = hang[1]
    cone = union(Mpoly([(x - 5, y + 2), (x + 5, y + 2), (x + 1, y + 13), (x, y + 13)]), Mell(x, y + 2, 5, 2.5))
    shade(cv, cone, lambda X, Y: TOAST if (Y - y) % 4 == 3 else SAND, "ball")
    # starfish (gold)
    x, y = hang[2]
    st = [(x + (6.5 if k % 2 == 0 else 2.6) * math.cos(-math.pi / 2 + k * math.pi / 5), y + 6 + (6.5 if k % 2 == 0 else 2.6) * math.sin(-math.pi / 2 + k * math.pi / 5)) for k in range(10)]
    shade(cv, Mpoly(st), GOLD, "ball")
    for dx, dy in ((0, 3), (0, 6), (-2, 6), (2, 6)): cv.put(x + dx, y + dy, GOLD[3])
    # clam (lilac)
    x, y = hang[3]
    clam = inter(Mell(x, y + 8, 6.5, 6.5), Mrect(0, 0, 64, y + 9))
    shade(cv, union(clam, Mrect(x - 6, y + 8, x + 7, y + 10)), DUSK, "ball", box=(x - 7, y + 1, x + 7, y + 11))
    for r in (2.5, 4.5): px(cv, pix(inter(minus(Mell(x, y + 8, r, r), Mell(x, y + 8, r - 1, r - 1)), clam)), DUSK[3])

    def post(c):
        for x, y in ((20, 46), (31, 52), (45, 44)):
            c.put(x, y, CREAM); c.put(x + 1, y - 1, CREAM)
    return post


GLY = {
    "G": [".###.", "#....", "#....", "#.###", "#...#", "#...#", ".###."],
    "N": ["#...#", "##..#", "#.#.#", "#.#.#", "#..##", "#...#", "#...#"],
    "O": [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
    "M": ["#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"],
    "E": ["#####", "#....", "#....", "####.", "#....", "#....", "#####"],
}


def salt_sign(cv, rnd):
    shade(cv, Mrect(29, 34, 36, 54), WOOD, "cyl", rnd, .06)
    for cx, cy, rx, ry in ((32, 54, 11, 3), (26, 53, 5, 2.5), (39, 53, 5, 2.5)): lump(cv, cx, cy, rx, ry, SALT, rnd, .2)
    edge = [(x, y, 1.6 + rnd.random()) for x, y in [(6 + k * 2.6, 11) for k in range(20)] + [(6 + k * 2.6, 38) for k in range(20)]
            + [(6, 12 + k * 3) for k in range(9)] + [(57, 12 + k * 3) for k in range(9)]]
    board = union(Mrr(6, 11, 58, 39, 3), Mdots(edge))
    shade(cv, board, SALT, "ball", rnd, .14, box=(4, 6, 60, 44))
    word = "GNOME"
    x0 = 32 - (len(word) * 6 - 1) // 2
    for i, ch in enumerate(word):
        glyph(cv, x0 + i * 6, 21, GLY[ch], TOAST[3], TOAST[1])
    for x, y in ((12, 15), (50, 16), (15, 33), (47, 34), (9, 25), (55, 27)): cv.put(x, y, SALT[3])

    def post(c):
        sparkle(c, 9, 7, CREAM); sparkle(c, 56, 8, CREAM, True)
    return post


def snow_fort_banner(cv, rnd):
    shade(cv, Mrect(31, 4, 34, 44), WOOD, "cyl")
    shade(cv, Mell(32.5, 4, 2.5, 2.5), GOLD, "ball")
    # tatty flag
    flag = []
    for x in range(34, 56):
        w = round(1.5 * math.sin((x - 34) * .45))
        for y in range(8 + w, 26 + w): flag.append((x, y))
    fm = Image.new("L", (S, S), 0)
    for p in flag: fm.putpixel(p, 255)
    fm = minus(fm, Mpoly([(56, 8), (51, 11), (56, 14), (50, 17), (56, 21), (52, 24), (56, 28)]))
    fm = minus(fm, Mrect(45, 21, 47, 23))
    shade(cv, fm, lambda x, y: EMBER if (x // 4) % 2 or True else EMBER, "flat", rnd, .04)
    for x, y in pix(fm):
        if math.sin((x - 34) * .45) > .6: tint(cv, [(x, y)], EMBER, -1)
        elif math.sin((x - 34) * .45) < -.6: tint(cv, [(x, y)], EMBER, 1)
    w0 = lambda x: round(1.5 * math.sin((x - 34) * .45))
    shade(cv, Mell(42, 16 + w0(42), 4, 4), WOOL, "ball")
    # the fort wall, bricks of snow
    wall = minus(Mrect(9, 38, 56, 56), union(*[Mrect(x, 38, x + 5, 42) for x in (15, 27, 39, 51)]))
    shade(cv, wall, SNOW, "flat", rnd, .03)
    for y in (42, 48):
        px(cv, [(x, y) for x in range(9, 56)], SNOW[3])
    for x, y0 in ((15, 38), (27, 38), (39, 38), (51, 38), (12, 43), (24, 43), (36, 43), (48, 43), (18, 49), (30, 49), (42, 49)):
        px(cv, [(x, y) for y in range(y0, y0 + 5 if y0 > 38 else y0 + 4)], SNOW[3])
    for x, y in ((14, 55), (22, 55), (40, 55)): cv.put(x, y, SNOW[4])
    # the cocoa at stake
    shade(cv, Mrr(45, 30, 52, 38, 1), EMBER, "cyl")
    shade(cv, minus(Mell(52.5, 33.5, 2.5, 2.5), Mell(52.5, 33.5, 1, 1)), EMBER, "edge")
    shade(cv, Mrect(46, 30, 51, 31), COCOA, 2, rim=False)

    def post(c):
        for i, y in enumerate(range(23, 28)): c.put(48 + (i % 2), y, WOOL[1])
    return post


def fir_ornament(cv, rnd):
    shade(cv, Mline([(6, 10), (32, 9), (58, 12)], 2), WOOD, "edge")
    for k in range(0, 52, 3):
        x = 7 + k; y = 9 + (1 if k > 26 else 0)
        for dy, dx in ((-4, 2), (4, 2)):
            px(cv, pix(Mline([(x, y), (x + dx, y + dy)], 1)), PINE[1] if dy < 0 else PINE[3])
    # hook and cap
    shade(cv, minus(Mell(32, 15, 2.5, 3.5), Mell(32, 15, 1, 2)), GOLD, "edge")
    cap = Mrr(27, 17, 38, 23, 1); shade(cv, cap, GOLD, "cyl")
    for x in (29, 32, 35): px(cv, [(x, 18), (x, 19), (x, 20), (x, 21)], GOLD[3])
    ball = Mell(32.5, 37, 15.5, 15.5); shade(cv, ball, SEA, "ball", rnd, .02)
    # painted band and a little fir with snow
    for x in range(17, 49):
        y = 32 + (abs((x % 6) - 3) - 1)
        if ball.getpixel((x, y)): cv.put(x, y, GOLD[1]); cv.put(x, y + 1, GOLD[3])
    tree = Mpoly([(32, 35), (39, 47), (26, 47)]); shade(cv, tree, LEAF, "flat", rim=False)
    shade(cv, Mpoly([(32, 39), (37, 46), (27, 46)]), LEAF, 2, rim=False)
    px(cv, [(32, 47), (33, 47), (32, 48), (33, 48)], WOOD[3])
    cv.put(32, 34, GOLD[0])
    for x, y in ((22, 41), (42, 39), (24, 46), (41, 46), (37, 41), (28, 42)): cv.put(x, y, WOOL[0])
    px(cv, pix(Mline([(22, 28), (25, 24), (29, 23)], 2)), CREAM)


def runaway_kite(cv, rnd):
    T, Rr, B, L = (34, 3), (57, 18), (31, 42), (11, 20)
    kite = Mpoly([T, Rr, B, L])

    def side(p, a, b): return (b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0])

    def quad(x, y):
        s1, s2 = side((x + .5, y + .5), T, B) > 0, side((x + .5, y + .5), L, Rr) > 0
        return {(False, False): EMBER, (True, False): GOLD, (False, True): SEA, (True, True): PETAL}[(s1, s2)]
    shade(cv, kite, quad, "flat", rnd, .03)
    # a mended patch, stitches everywhere
    patch = Mpoly([(19, 21), (25, 18), (28, 24), (22, 27)]); shade(cv, patch, LEAF, "flat", rim=False)
    for x, y in pix(minus(Mpoly([(18, 20), (26, 17), (29, 25), (21, 28)]), patch)):
        if (x + y) % 2: cv.put(x, y, WOOL[0])
    for x, y in ((44, 30), (47, 27), (40, 9), (42, 12)):
        for dx, dy in ((0, 0), (1, 1), (1, 0), (0, 1)): pass
        px(cv, [(x, y), (x + 1, y + 1), (x + 1, y - 1), (x - 1, y + 1), (x - 1, y - 1)], WOOL[0])
    px(cv, pix(Mline([T, B], 1)) + pix(Mline([L, Rr], 1)), WOOD[3])
    # happy to be home
    for x, y in ((28, 23), (29, 22), (30, 23), (37, 22), (38, 21), (39, 22)): cv.put(x, y, INK)
    for x, y in ((32, 26), (33, 27), (34, 27), (35, 26)): cv.put(x, y, INK)
    # tail with bows
    tail = bezier(B, (22, 46), (16, 56), 24)
    for x, y in tail: cv.put(round(x), round(y), PARCH[4])
    for i, Rb in ((8, PETAL), (16, GOLD), (24, SEA)):
        x, y = tail[i]; x, y = round(x), round(y)
        shade(cv, Mpoly([(x, y), (x - 4, y - 3), (x - 4, y + 2)]), Rb, "ball")
        shade(cv, Mpoly([(x, y), (x + 4, y - 2), (x + 4, y + 3)]), Rb, "ball")
        cv.put(x, y, Rb[3])


def hatters_thimble(cv, rnd):
    body = union(Mpoly([(19, 20), (45, 20), (48, 49), (16, 49)]), Mell(32, 21, 13, 9))
    shade(cv, body, SILVER, "cyl", rnd, .02, box=(15, 12, 49, 52))
    er = body.copy()
    for k in range(3): er = inter(er, inter(ImageChops.offset(er, 1, 0), ImageChops.offset(er, -1, 0)))
    for j, y in enumerate(range(15, 33, 3)):
        for x in range(14 + (j % 2) * 2, 50, 4):
            if er.getpixel((x, y)) and er.getpixel((x, y + 1)):
                cv.put(x, y, SILVER[3]); cv.put(x - 1, y, SILVER[2]); cv.put(x + 1, y + 1, SILVER[0])
    # the fussy hatter's ribbon band and bow
    band = inter(body, Mrect(0, 35, 64, 41)); shade(cv, band, PETAL, "cyl", box=(15, 35, 49, 41))
    px(cv, [(x, 35) for x in range(15, 50) if band.getpixel((x, 35))], PETAL[0])
    shade(cv, Mpoly([(44, 38), (51, 33), (52, 42)]), PETAL, "ball")
    shade(cv, Mpoly([(44, 38), (39, 45), (46, 46)]), PETAL, "ball")
    shade(cv, Mell(44, 38, 2, 2), PETAL, "ball")
    rim = Mrr(14, 46, 50, 54, 3); shade(cv, rim, SILVER, "cyl", box=(14, 46, 50, 54))
    px(cv, [(x, 47) for x in range(16, 48)], SILVER[0])
    px(cv, [(20, y) for y in range(22, 34)] + [(21, y) for y in range(42, 46)], WOOL[0])

    def post(c):
        sparkle(c, 12, 12, CREAM, True); sparkle(c, 52, 22, CREAM); c.put(56, 14, CREAM)
    return post


def shield_pts(x0, x1, yt, yk, yb):
    xm = (x0 + x1) / 2
    return ([(x0, yt), (x1, yt), (x1, yk)] + bezier((x1, yk), (x1, yb - 4), (xm, yb), 8)[1:]
            + bezier((xm, yb), (x0, yb - 4), (x0, yk), 8)[1:])


def bridgewardens_badge(cv, rnd):
    bar = Mrr(18, 4, 47, 14, 2)
    shade(cv, bar, lambda x, y: SEA if x < 24 or x >= 41 else WOOL if x < 29 or x >= 36 else GOLD, "hcyl")
    for x in (24, 29, 36, 41): px(cv, [(x, y) for y in range(5, 13)], INK)
    for x in (26, 39): shade(cv, minus(Mell(x, 16.5, 2.5, 2.5), Mell(x, 16.5, 1, 1)), GOLD, "edge")
    outer = Mpoly(shield_pts(13, 52, 18, 35, 57)); shade(cv, outer, GOLD, "ball", rnd, .02)
    inner = Mpoly(shield_pts(17, 48, 22, 35, 52))
    # sky, river and an arched bridge
    for x, y in pix(inner): cv.put(x, y, ICE[1] if y < 36 else SEA[2] if (x + y) % 5 else SEA[1])
    deck = inter(Mrect(14, 30, 52, 33), inner); shade(cv, deck, WOOD, "edge")
    arch = inter(minus(Mrect(18, 33, 48, 44), Mell(32.5, 44, 9.5, 8.5)), inner); shade(cv, arch, STONE, "edge")
    px(cv, [(x, 33) for x in range(19, 47, 4)], STONE[3])
    for x in range(19, 47, 3): px(cv, [(x, 28), (x, 29)], WOOD[2])
    px(cv, [(x, 27) for x in range(18, 48)], WOOD[2])
    px(cv, pix(minus(Mpoly(shield_pts(16, 49, 21, 35, 53)), inner)), GOLD[3])
    sparkle(cv, 22, 25, CREAM)

    def post(c):
        sparkle(c, 8, 22, GOLD[0], True); sparkle(c, 57, 30, GOLD[0]); sparkle(c, 54, 49, CREAM)
    return post


def seaside_stationery(cv, rnd):
    for ang, c in ((-14, (26, 27)), (-5, (29, 28))):
        sh = Mpoly(rot(c, math.radians(ang), [(-14, -18), (14, -18), (14, 18), (-14, 18)]))
        shade(cv, sh, WOOL, 2 if ang < -10 else 1, rim=False)
    front = Mrect(17, 9, 46, 46); shade(cv, front, WOOL, "flat")
    for x in range(19, 45):
        cv.put(x, 12 + round(math.sin(x * .9)), SEA[2]); cv.put(x, 43 + round(math.sin(x * .9)), SEA[2])
    for y in range(13, 43):
        cv.put(20 + round(math.sin(y * .9)), y, SEA[2]); cv.put(43 + round(math.sin(y * .9)), y, SEA[2])
    for y in (19, 24, 29):
        px(cv, [(x, y) for x in range(24, 39) if (x + y) % 7], ICE[3])
    # envelope sealed with a crab
    env = Mrect(30, 33, 58, 54); shade(cv, env, PARCH, "flat", rnd, .02)
    px(cv, pix(Mline([(30, 33), (44, 44), (57, 33)], 1)), PARCH[3])
    px(cv, pix(Mline([(31, 53), (40, 45)], 1)) + pix(Mline([(57, 53), (48, 45)], 1)), PARCH[2])
    for x in range(31, 57): cv.put(x, 51 + round(math.sin(x * .9) * .8), SEA[2])
    shade(cv, Mell(44, 45, 3.5, 2.5), EMBER, "ball")
    for x, y in ((40, 43), (39, 42), (48, 43), (49, 42)): cv.put(x, y, EMBER[2])
    for x, y in ((43, 41), (45, 41)): cv.put(x, y, INK); cv.put(x, y + 1, EMBER[3])
    for x, y in ((42, 48), (46, 48), (40, 47), (48, 47)): cv.put(x, y, EMBER[3])


def pocket_star_wheel(cv, rnd):
    C = (29, 35)
    ring = Mell(C[0], C[1], 20, 20); shade(cv, ring, GOLD, "ball", rnd, .02)
    for k in range(24):
        a = k * math.pi / 12; r = 18
        cv.put(round(C[0] + r * math.cos(a)), round(C[1] + r * math.sin(a)), GOLD[4] if k % 3 else INK)
    disc = Mell(C[0], C[1], 15, 15); shade(cv, disc, NIGHT, "ball", rim=False)
    for _ in range(14):
        a, r = rnd.random() * 6.283, 3 + rnd.random() * 10
        cv.put(round(C[0] + r * math.cos(a)), round(C[1] + r * math.sin(a)), WOOL[2] if rnd.random() < .5 else CREAM)
    # tonight's stars, lined up
    a = math.radians(-35)
    LN = H("#8a9ad8")
    ends = [(C[0] + s * math.cos(a), C[1] + s * math.sin(a)) for s in (-11, 11)]
    px(cv, pix(Mline(ends, 1)), LN)
    for s in (-10, -3.5, 3.5):
        sparkle(cv, round(C[0] + s * math.cos(a)), round(C[1] + s * math.sin(a)), CREAM)
    shade(cv, Mell(C[0], C[1], 2, 2), GOLD, "ball")
    # the keeper's lens on its arm
    L = (46, 19)
    shade(cv, Mline([C, L], 3), GOLD, "edge")
    shade(cv, Mell(L[0], L[1], 9, 9), GOLD, "ball")
    shade(cv, Mell(L[0], L[1], 6.5, 6.5), DEW, "ball", rim=False)
    sparkle(cv, L[0] + 1, L[1] + 1, GOLD[0], True); cv.put(L[0] + 1, L[1] + 1, CREAM)
    px(cv, [(42, 16), (43, 15), (42, 17)], CREAM)


def patchwork_picnic_blanket(cv, rnd):
    A, Bp, C, D = (5, 30), (32, 19), (59, 30), (32, 41)
    pal = [EMBER, GOLD, LEAF, SEA, PETAL, WOOL, DUSK]
    grid = [[pal[(i * 3 + j * 5 + (i * j) % 3) % len(pal)] for j in range(4)] for i in range(4)]
    det = (Bp[0] - A[0]) * (D[1] - A[1]) - (Bp[1] - A[1]) * (D[0] - A[0])

    def uv(x, y):
        dx, dy = x + .5 - A[0], y + .5 - A[1]
        u = (dx * (D[1] - A[1]) - dy * (D[0] - A[0])) / det
        v = (dy * (Bp[0] - A[0]) - dx * (Bp[1] - A[1])) / det
        return u, v
    TH = 12
    left = Mpoly([A, D, (D[0], D[1] + TH), (A[0], A[1] + TH)])
    right = Mpoly([D, C, (C[0], C[1] + TH), (D[0], D[1] + TH)])

    def layers(x, y, along):
        k = int((y - along) // 3)
        return grid[k % 4][(x // 7) % 4]
    for m, base, t, along in ((left, A, 2, lambda x: A[1] + (x - A[0]) * 11 / 27), (right, D, 3, lambda x: D[1] - (x - D[0]) * 11 / 27)):
        shade(cv, m, lambda x, y, al=along: layers(x, y, al(x)), t, rnd, .03, rim=False)
        for x, y in pix(m):
            if (y - along(x)) % 3 < 1 and y - along(x) > 1: cv.put(x, y, INK if t == 3 else grid[0][0][4] if False else H("#4a3040"))
    top = Mpoly([A, Bp, C, D])

    def patch(x, y):
        u, v = uv(x, y); return grid[min(3, max(0, int(u * 4)))][min(3, max(0, int(v * 4)))]
    shade(cv, top, patch, "flat", rnd, .03, rim=False)
    for x, y in pix(top):
        u, v = uv(x, y)
        fu, fv = (u * 4) % 1, (v * 4) % 1
        if (fu < .09 or fv < .09) and u > .05 and v > .05 and (x + y) % 2: cv.put(x, y, CREAM)
    # gingham on one patch
    for x, y in pix(top):
        u, v = uv(x, y)
        if int(u * 4) == 1 and int(v * 4) == 2 and (x % 2 == 0 or y % 2 == 0): tint(cv, [(x, y)], patch(x, y), 1)
    px(cv, [(x, y) for x, y in pix(top) if not top.getpixel((x, y - 1))], CREAM)


def hollow_round_song_sheet(cv, rnd):
    outer = Mrr(12, 5, 52, 57, 2); inner = Mrect(15, 8, 49, 54)
    shade(cv, minus(outer, inner), GOLD, "ball", rnd, .02, box=(12, 5, 52, 57))
    px(cv, pix(minus(Mrect(14, 7, 50, 55), inner)), GOLD[4])
    shade(cv, inner, PARCH, "flat", rnd, .02, rim=False)
    for x in range(21, 44):
        if (x * 3) % 7: cv.put(x, 12 + (x % 5 == 0), BR)
    for y in range(18, 27, 2): px(cv, [(x, y) for x in range(17, 48)], PARCH[3])
    for x, y in ((20, 24), (26, 21), (32, 23), (38, 19)): note(cv, x, y, INK)
    # the cheeky echo: small, faint, with ripples
    px(cv, [(44, 22), (45, 22), (44, 23), (45, 23)], DUSK[2]); px(cv, [(46, 18), (46, 19), (46, 20), (46, 21)], DUSK[2])
    for y in range(29, 32): cv.put(48 - (y == 30), y, DUSK[1])
    # a doodle of the hollow, with sound rings rolling out
    hill = inter(Mell(32, 54, 15, 12), inner); shade(cv, hill, MOSS, "ball", box=(17, 42, 47, 66), rim=False)
    shade(cv, inter(Mell(30, 54, 5, 6), inner), NIGHT, 4, rim=False)
    for r in (3, 5):
        px(cv, [(x, y) for x, y in pix(minus(Mell(39, 47, r, r - 1), Mell(39, 47, r - 1, r - 2))) if x > 39 and y < 50], DUSK[2])
    for y in (33, 37):
        for x in range(18, 47):
            if (x * 5 + y) % 9 > 2: cv.put(x, y, PARCH[4])

    def post(c):
        note(c, 6, 18, DUSK[1]); note(c, 57, 30, DUSK[1])
    return post


def curve_y(pts, x):
    best = min(pts, key=lambda p: abs(p[0] - x)); return best[1]


def marrowbys_price_book(cv, rnd):
    cover = Mpoly([(3, 25), (32, 31), (61, 25), (61, 47), (32, 55), (3, 47)])
    shade(cv, cover, LEATHER, "flat", rnd, .06)
    ltop, lbot = bezier((6, 23), (18, 16), (31, 28), 30), bezier((6, 44), (18, 38), (31, 50), 30)
    for off, t in ((3, 3), (1.5, 2)):
        for pg in (lambda p: p, lambda p: (64 - p[0], p[1])):
            m = Mpoly([pg((x, y + off)) for x, y in ltop] + [pg((x, y + off)) for x, y in reversed(lbot)])
            shade(cv, m, PARCH, t, rim=False)
    lp = Mpoly(ltop + list(reversed(lbot)))
    rp = Mpoly([(64 - x, y) for x, y in ltop] + [(64 - x, y) for x, y in reversed(lbot)])
    shade(cv, lp, PARCH, "flat", rnd, .03, rim=False, box=(6, 16, 60, 52))
    shade(cv, rp, PARCH, 2, rnd, .03, rim=False)
    px(cv, [(x, y) for x, y in pix(union(lp, rp)) if 30 <= x <= 34], PARCH[3])
    for cx, cy in ((12, 40), (52, 28)): tint(cv, pix(inter(lp if cx < 32 else rp, Mell(cx, cy, 3, 2))), PARCH, 1)
    # left page: the price list, a coin at the end of each line
    for k in range(4):
        for x in range(9, 22):
            if (x + k) % 6: cv.put(x, round(curve_y(ltop, x)) + 6 + k * 5, BR)
        x = 26; y = round(curve_y(ltop, x)) + 6 + k * 5
        px(cv, [(x, y), (x + 1, y), (x, y - 1), (x + 1, y - 1)], GOLD[1]); cv.put(x + 1, y, GOLD[3])
    # right page: a turnip, and a stern note
    tx, ty = 44, 31
    for a, b in (((tx, ty - 3), (tx - 3, ty - 8)), ((tx, ty - 3), (tx + 3, ty - 8)), ((tx, ty - 3), (tx, ty - 9))):
        px(cv, pix(Mline([a, b], 1)), LEAF[2])
    shade(cv, inter(Mell(tx, ty + 1, 4.5, 4), Mrect(0, 0, 64, ty + 1)), DUSK, 1, rim=False)
    shade(cv, inter(Mell(tx, ty + 1, 4.5, 4), Mrect(0, ty + 1, 64, 64)), WOOL, 1, rim=False)
    px(cv, [(tx, ty + 5), (tx, ty + 6)], WOOL[3])
    for x in range(37, 54): cv.put(x, ty + 10 + round(math.sin(x * 1.1)), EMBER[2])
    for x in range(38, 52):
        if (x * 3) % 5: cv.put(x, ty + 14 + (x % 3 == 0), BR)
    # ribbon bookmark
    shade(cv, Mpoly([(31, 50), (34, 50), (35, 59), (33, 57), (31, 59)]), EMBER, "edge")


def feather_pillow(cv, rnd):
    corners = [(7, 19), (57, 21), (55, 52), (9, 50)]
    pts = []
    for i in range(4):
        a, b = corners[i], corners[(i + 1) % 4]
        mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
        cx, cy = 32 - mx, 36 - my; L = math.hypot(cx, cy)
        ctrl = (mx - cx / L * 2, my - cy / L * 2) if i % 2 == 0 else (mx - cx / L * 3, my - cy / L * 3)
        ctrl = (mx + cx / L * 3, my + cy / L * 3)
        pts += bezier(a, ctrl, b, 16)[:-1]
    body = union(Mpoly(pts), Mell(32, 36, 21, 13))
    PST = ramp("#f0f8ff", "#cfe4f6", "#a6c6e6", "#7c9cc6", "#56709c")
    shade(cv, body, lambda x, y: PST if (x - y // 6) % 6 in (0, 1) else WOOL, "ball", rnd, .03, box=(6, 17, 58, 55))
    # tuft in the middle, creases out to the corners
    for c in corners:
        for x, y in bezier((32, 36), ((32 + c[0]) / 2, (36 + c[1]) / 2 + 2), c, 14)[3:-3]:
            tint(cv, [(round(x), round(y))], WOOL, 1); tint(cv, [(round(x), round(y))], PST, 1)
    shade(cv, Mell(32, 36, 2, 2), PST, "ball")
    # a feather escaping from a corner seam
    O, a = (50, 23), math.radians(-60)
    vane = Mpoly(axis_poly(O, a, [(0, 1), (5, 3), (12, 3.2), (17, 1.5), (19, .3)]))
    shade(cv, vane, WOOL, "ball")
    px(cv, pix(Mline([O, (O[0] + 18 * math.cos(a), O[1] + 18 * math.sin(a))], 1)), WOOL[3])

    def post(c):
        for x, y in ((12, 8), (13, 9), (14, 9), (15, 10), (16, 10), (17, 10)): c.put(x, y, WOOL[2])
        for x, y in ((13, 8), (14, 8), (15, 9), (16, 9)): c.put(x, y, WOOL[0])
    return post


ITEMS = {
    "mirror-pebble": mirror_pebble, "dare-pebble": dare_pebble, "rivers-postcard": rivers_postcard,
    "blue-stitch-hat-patch": blue_stitch_hat_patch, "parrot-phrasebook": parrot_phrasebook, "planks-gratitude": planks_gratitude,
    "scree-xylophone": scree_xylophone, "waterfall-sketch": waterfall_sketch, "arch-shell-mobile": arch_shell_mobile,
    "salt-sign": salt_sign, "snow-fort-banner": snow_fort_banner, "fir-ornament": fir_ornament, "runaway-kite": runaway_kite,
    "hatters-thimble": hatters_thimble, "bridgewardens-badge": bridgewardens_badge, "seaside-stationery": seaside_stationery,
    "pocket-star-wheel": pocket_star_wheel, "patchwork-picnic-blanket": patchwork_picnic_blanket,
    "hollow-round-song-sheet": hollow_round_song_sheet, "marrowbys-price-book": marrowbys_price_book, "feather-pillow": feather_pillow,
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
    if bb[1] + dy < 1 or bb[0] + dx < 0 or bb[2] + dx > S:
        print(f"warning: {slug} touches the edge", file=sys.stderr)
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
    slugs = sys.argv[1:] or list(ITEMS)
    for slug in slugs:
        render(slug).save(os.path.join(OUT, slug + ".png"))
    print(f"wrote {len(slugs)} item pictures to {OUT}")


if __name__ == "__main__":
    main()
