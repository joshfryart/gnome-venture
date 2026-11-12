#!/usr/bin/env python3
"""Item pictures (Hearth Pop v3), batch D: Wonder-gate / quiet / giants / clover / tide-pool Sight items.
64 x 64 RGBA, hard pixels, 5-tone ramps lit from the top-left, 1 px ink outline, flat two-tone ground shadow.
Same helpers and shadow as tools/gen_sight_item_art_a.py.
Deterministic and re-runnable:  python3 tools/gen_sight_item_art_d.py [slug ...]  -> game/assets/img/ph/<slug>.png"""
import math, os, random, sys, zlib
from PIL import Image, ImageDraw, ImageChops

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "claude", "tile-art-v3-proposal"))
import gen2  # noqa: E402,F401
from gen2 import RAMP, INK, CREAM, H, r5, Cv, outline, tone5, shade_pt  # noqa: E402

OUT = os.path.join(ROOT, "game", "assets", "img", "ph")
S = 64
SH_IN, SH_OUT = H("#aaa9b8"), H("#74758c")   # ground shadow, as on the existing item pictures


def ramp(*hx): return [H(h) for h in hx]


STONE, WOOD, GOLD, EMBER = r5(RAMP["stone"]), r5(RAMP["wood"]), r5(RAMP["gold"]), r5(RAMP["ember"])
LEAF, MOSS, SEA, DUSK, ICE, PETAL = r5(RAMP["leaf"]), r5(RAMP["moss"]), r5(RAMP["sea"]), r5(RAMP["dusk"]), r5(RAMP["ice"]), r5(RAMP["petal"])
SNOW = r5(RAMP["snow"])
WOOL = ramp("#fffdf4", "#f7efdb", "#e6d8bc", "#c4b090", "#8d7a66")
PARCH = ramp("#fff6dc", "#f5e3b4", "#e4c88e", "#c49c66", "#8a6448")
SYRUP = ramp("#ffe6a0", "#f7b64a", "#d8802a", "#a24f22", "#6a2d1e")
TOAST = ramp("#fff0c4", "#f5c46e", "#d48a3e", "#9a5530", "#5e3326")
NIGHT = ramp("#5a6fb8", "#45569a", "#36437e", "#2a3263", "#1d2346")
BLUE = ramp("#cfe6ff", "#8ab8f2", "#4f7fd6", "#2f50a0", "#22305f")
CRAYON = ramp("#c4b4ec", "#9a86d0", "#7560b4", "#56439a", "#3a2c6e")
HUSH = ramp("#fdfaff", "#f1ecfa", "#ddd4ee", "#ada3c8", "#77709c")
WAX = ramp("#fffaf0", "#fbefd2", "#ecd6a8", "#c9a87a", "#8a6a4f")
FLAME = ramp("#fff4d6", "#ffd27a", "#ffa04a", "#e8693a", "#a8402e")
CARD = ramp("#fbe2b4", "#e8c08a", "#cc9658", "#97643e", "#62402e")
BEETLE = ramp("#d8ffe8", "#7ee6b8", "#3aa890", "#356c96", "#3a2f6e")
CLOTH = ramp("#bfe08a", "#86bf62", "#55964f", "#356a45", "#22463c")
BROWN = ramp("#fbe0b4", "#ebc490", "#d2a066", "#a37044", "#6a4530")
BIRCH = ramp("#ffe8bc", "#f4cc94", "#d9a468", "#a87244", "#6c4630")
SHELL = ramp("#fff6ea", "#fde0c6", "#f2bc98", "#cc8a6a", "#8c544a")
CORAL = ramp("#ffd6a8", "#ffae6a", "#f27e42", "#c75430", "#7e2e2a")
DRIFT = ramp("#f4efe4", "#dad1c0", "#b4a894", "#887b68", "#5a524c")
PINKW = ramp("#fff2f0", "#f6dadb", "#e2b8bf", "#b98a97", "#7c5a68")
BR = H("#7d4a35")


# ------------------------------------------------------------------ masks (as in gen_sight_item_art_a.py)
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
def Mrell(cx, cy, rx, ry, ang, n=48):
    """Ellipse rotated by ang (radians, screen coords)."""
    ca, sa = math.cos(ang), math.sin(ang)
    return Mpoly([(cx + rx * math.cos(t) * ca - ry * math.sin(t) * sa, cy + rx * math.cos(t) * sa + ry * math.sin(t) * ca)
                  for t in (k * 2 * math.pi / n for k in range(n))])
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


def tube(cv, O, ang, s0, s1, hw, R, rnd=None, speck=0.0, stripe=None):
    """A round section along an axis, shaded across its width (light on the upper-left side)."""
    m = Mpoly(axis_poly(O, ang, [(s0, hw), (s1, hw)]))
    ux, uy = math.cos(ang), math.sin(ang); nx, ny = -uy, ux
    s = set(pix(m))
    for x, y in s:
        dx, dy = x + .5 - O[0], y + .5 - O[1]
        sa, d = dx * ux + dy * uy, dx * nx + dy * ny
        dn = d / hw * (1 if ny > 0 else -1)
        t = 0 if dn < -.7 else 1 if dn < -.25 else 2 if dn < .35 else 3 if dn < .75 else 4
        if stripe and stripe(sa, d): t = min(4, t + 1)
        if speck and rnd and rnd.random() < speck: t = max(0, min(4, t + rnd.choice((-1, 1))))
        cv.put(x, y, R[t])
    return m


def letter(cv, x, y, rows, c):
    for j, row in enumerate(rows):
        for i, ch in enumerate(row):
            if ch == "#": cv.put(x + i, y + j, c)


def scrawl(cv, x0, x1, y, c, rnd, gap=6, m=None):
    """A line of tiny handwriting: wobbly pixels with word gaps."""
    for x in range(x0, x1):
        if (x - x0) % gap == gap - 1 or rnd.random() < .12: continue
        yy = y + (1 if (x * 7 + y) % 3 == 0 else 0)
        if m is None or m.getpixel((x, yy)): cv.put(x, yy, c)


def clover4(cv, cx, cy, R):
    for dx, dy in ((-1, -1), (1, -1), (-1, 1), (1, 1)):
        shade(cv, Mell(cx + dx * 1.7, cy + dy * 1.7, 1.7, 1.7), R, "ball")


# ------------------------------------------------------------------ items
def gate_rubbing(cv, rnd):
    paper = Mpoly([(11, 8), (44, 6.5), (52, 14), (54, 53), (13, 55)])
    shade(cv, paper, WOOL, "flat", rnd, .03)
    fold = Mpoly([(44, 6.5), (52, 14), (45, 14)]); shade(cv, fold, WOOL, 2)
    # waxy crayon rubbing of the gate arch and its bars
    outer = union(Mell(32, 25, 14, 13), Mrect(18, 25, 47, 48))
    hole = union(Mell(32, 26, 10, 9), Mrect(22, 26, 43, 48))
    for x, y in pix(inter(minus(outer, hole), paper)):
        if rnd.random() < .86: cv.put(x, y, CRAYON[3] if (x + 2 * y) % 5 == 0 else CRAYON[2])
    for x, y in pix(inter(hole, paper)):
        if x in (26, 27, 32, 33, 38, 39):
            if rnd.random() < .85: cv.put(x, y, CRAYON[2])
        elif (x - y) % 4 == 0 and rnd.random() < .75: cv.put(x, y, CRAYON[0])
    for x in range(22, 43):                                      # cross bar
        if rnd.random() < .85: cv.put(x, 37, CRAYON[2])
    shade(cv, Mpoly([(30, 11), (34, 11), (33.5, 15), (30.5, 15)]), CRAYON, 3, rim=False)   # keystone
    # one line of riddle underneath
    scrawl(cv, 17, 48, 50, CRAYON[4], rnd)
    # the crayon stub
    shade(cv, Mline([(40, 57), (52, 49)], 5), CRAYON, "edge")
    shade(cv, Mline([(43, 55), (49, 51)], 5), PARCH, "edge")
    shade(cv, Mpoly([(51, 46.5), (55, 51), (58, 46)]), CRAYON, "edge")


def hush_page(cv, rnd):
    page = Mpoly([(13, 13), (45, 9), (51, 53), (18, 57)])
    shade(cv, page, HUSH, "flat", rnd, .02)
    for i in range(9):                                           # very soft writing
        y0 = 19 + i * 4
        for x in range(18, 48):
            y = int(y0 - (x - 18) / 8 + (x - 18) * 0 + (i * 0))
            if not page.getpixel((x, y)) or not page.getpixel((x + 2, y)): continue
            if i in (0, 2, 3, 5, 7) and (x + i * 3) % 9 not in (7, 8) and x < 46 - (i % 3) * 5:
                cv.put(x, y, HUSH[3] if rnd.random() < .5 else HUSH[2])
            elif x % 2 == 0:
                cv.put(x, y, HUSH[2])
    # a tiny sleeping moon at the bottom corner
    px(cv, pix(minus(Mell(42, 47, 3.5, 3.5), Mell(44, 46, 3, 3))), GOLD[1])
    # the speech bubble with the thing it nearly said
    bub = union(Mell(44, 13, 10, 7.5), Mpoly([(38, 17), (42, 19), (35, 25)]))
    shade(cv, bub, WOOL, "ball")
    for x in (39, 44, 49):
        px(cv, [(x, 13), (x + 1, 13), (x, 14), (x + 1, 14)], HUSH[3])

    def post(c):
        for x, y in ((8, 20), (56, 30), (10, 44)): c.put(x, y, HUSH[2])
        sparkle(c, 57, 40, HUSH[1])
    return post


def snore_note(cv, rnd):
    top = [(8, 25), (13, 22), (18, 25), (23, 21), (29, 24), (35, 21), (41, 24), (47, 21), (52, 24), (56, 22)]
    bot = [(56, 47), (51, 50), (45, 47), (39, 50), (33, 47), (27, 50), (21, 47), (15, 50), (9, 47)]
    scrap = Mpoly(top + bot)
    shade(cv, scrap, PARCH, "flat", rnd, .04)
    for y in (28, 32, 36, 40, 44):                               # stave
        px(cv, [(x, y) for x in range(9, 56) if scrap.getpixel((x, y)) and scrap.getpixel((x, y - 1))], PARCH[3])
    # one big note, fast asleep
    shade(cv, Mrect(33, 13, 36, 41), NIGHT, "edge")
    flag = Mline([(35, 14), (40, 18), (42, 23), (40, 28)], 3); shade(cv, flag, NIGHT, "edge")
    head = Mrell(28, 40, 7, 5, -.3); shade(cv, head, NIGHT, "ball")
    for x, y in ((24, 39), (25, 40), (26, 39), (29, 38), (30, 39), (31, 38)): cv.put(x, y, CREAM)
    px(cv, [(28, 42), (29, 42), (28, 43), (29, 43)], PETAL[1])
    # zzz, drifting off
    for x0, y0, s in ((44, 4, 7), (52, 0, 5)):
        z = Mline([(x0, y0 + 1), (x0 + s, y0 + 1), (x0, y0 + s), (x0 + s, y0 + s)], 2)
        shade(cv, z, ICE, "edge")


def lucky_wick(cv, rnd):
    # a walnut-shell boat
    shell = inter(Mell(32, 40, 20, 14), Mrect(0, 40, 64, 64))
    shade(cv, shell, WOOD, "ball", rnd, .06, box=(12, 26, 52, 54))
    for pts in (((16, 44), (22, 47), (26, 52)), ((30, 43), (33, 48), (31, 53)), ((40, 43), (45, 46), (47, 50))):
        px(cv, pix(Mline(pts, 1)), WOOD[3])
    shade(cv, Mell(32, 40, 20, 3), WOOD, 1, rim=False)
    shade(cv, Mell(32, 40.5, 17, 2), WAX, 2, rim=False)
    # the candle stub with a melted lip
    stub = Mrr(25, 23, 40, 42, 2); shade(cv, stub, WAX, "cyl", box=(23, 23, 42, 42))
    shade(cv, Mell(32.5, 23, 7.5, 2), WAX, "edge")
    shade(cv, union(Mrect(26, 23, 28, 30), Mell(27, 30, 1, 1.2)), WAX, 0, rim=False)
    clover4(cv, 33, 33, LEAF)
    # wick and flame
    px(cv, [(32, 19), (32, 20), (32, 21), (33, 22)], INK)
    flame = union(Mell(32, 14, 4.5, 5.5), Mpoly([(31, 2), (36.5, 12), (27.5, 12)]))
    shade(cv, flame, FLAME, "ball")
    shade(cv, Mell(32, 15, 2, 3), [CREAM] * 5, 0, rim=False)

    def post(c):
        for x, y in ((18, 12), (47, 8)): sparkle(c, x, y, GOLD[0])
        c.put(22, 5, GOLD[1]); c.put(44, 18, GOLD[1])
    return post


def scouts_spyglass(cv, rnd):
    O, ang = (8, 52), -.62
    tube(cv, O, ang, 0, 4, 3, GOLD)
    tube(cv, O, ang, 4, 18, 4, CARD, rnd, .03, stripe=lambda s, d: int(s + d * .6) % 4 == 0)
    tube(cv, O, ang, 18, 20, 5, GOLD)
    tube(cv, O, ang, 20, 33, 5.3, EMBER, rnd, .02)
    tube(cv, O, ang, 33, 35, 6.3, GOLD)
    tube(cv, O, ang, 35, 49, 6.8, CARD, rnd, .03, stripe=lambda s, d: int(s + d * .6) % 4 == 0)
    tube(cv, O, ang, 49, 52, 7.8, GOLD)
    ux, uy = math.cos(ang), math.sin(ang)
    # beetle-wing lens on the far end
    lx, ly = O[0] + 52 * ux, O[1] + 52 * uy
    lens = Mrell(lx, ly, 2.2, 6.6, ang); shade(cv, lens, BEETLE, "ball")
    cv.put(int(lx - 1), int(ly - 3), CREAM); cv.put(int(lx), int(ly - 4), CREAM)
    # a star sticker on the big section
    sx, sy = O[0] + 42 * ux, O[1] + 42 * uy
    for dx, dy in ((0, -2), (-1, -1), (0, -1), (1, -1), (-2, 0), (-1, 0), (0, 0), (1, 0), (2, 0), (-1, 1), (1, 1)):
        cv.put(int(sx) + dx, int(sy) + dy, GOLD[0] if dy < 0 else GOLD[1])

    def post(c):
        sparkle(c, 58, 10, CREAM, True); c.put(53, 6, BEETLE[1])
    return post


def book_of_hushes(cv, rnd):
    pages = Mrect(44, 11, 52, 52); shade(cv, pages, WOOL, "flat", rim=False)
    px(cv, [(x, y) for x in range(45, 52) for y in range(13, 51, 3)], WOOL[3])
    spine = Mrr(12, 8, 21, 55, 2); shade(cv, spine, CLOTH, "cyl", rnd, .05)
    for y in (14, 15, 47, 48): px(cv, [(x, y) for x in range(13, 20)], GOLD[2])
    cover = Mrr(17, 7, 49, 54, 2); shade(cv, cover, CLOTH, "ball", rnd, .08, box=(10, 2, 56, 60))
    px(cv, [(17, y) for y in range(9, 53)], CLOTH[3])
    # embossed frame
    fr = minus(Mrect(21, 11, 46, 50), Mrect(22, 12, 45, 49))
    px(cv, pix(fr), CLOTH[3]); px(cv, [(x, y + 1) for x, y in pix(fr) if y < 12 or x < 22], CLOTH[1])
    # a sleeping crescent moon, gold-stamped
    moon = minus(Mell(33, 27, 9, 9), Mell(37, 24, 8, 8)); shade(cv, moon, GOLD, "ball")
    for x, y in ((28, 28), (29, 29), (30, 29), (31, 28)): cv.put(x, y, GOLD[4])
    for x, y in ((39, 34), (42, 17), (27, 17)): sparkle(cv, x, y, GOLD[1])
    # little title plate
    plate = Mrect(25, 40, 43, 46); shade(cv, plate, PARCH, "flat")
    px(cv, [(x, 43) for x in range(27, 41) if x % 5 != 4], PARCH[3])
    # gold corners and the ribbon
    for pts in ([(41, 7), (49, 7), (49, 15)], [(41, 54), (49, 54), (49, 46)]):
        shade(cv, Mpoly(pts), GOLD, "edge")
    shade(cv, Mpoly([(33, 53), (37, 53), (37, 60), (35, 58), (33, 60)]), PETAL, "edge")


def lullaby_song_sheet(cv, rnd):
    # hanging string and nail
    shade(cv, Mline([(18, 12), (32, 5), (46, 12)], 1), PARCH, 2, rim=False)
    shade(cv, Mell(32, 5, 2, 2), GOLD, "ball")
    outer = Mrr(11, 10, 54, 56, 1); inner = Mrect(16, 15, 49, 51)
    frame = minus(outer, inner)
    shade(cv, frame, WOOD, "flat", rnd, .06)
    for x, y in pix(frame):
        if inner.getpixel((x, min(63, y + 1))) and y < 16 or inner.getpixel((min(63, x + 1), y)) and x < 17: cv.put(x, y, WOOD[4])
        elif inner.getpixel((x, y - 1)) and y > 49 or inner.getpixel((x - 1, y)) and x > 47: cv.put(x, y, WOOD[1])
    shade(cv, inner, PARCH, "flat", rnd, .02, rim=False, hi=False)
    tint(cv, [(x, 15) for x in range(16, 49)] + [(16, y) for y in range(15, 51)], PARCH, 1)
    for y0 in (18, 31):
        for k in range(5): px(cv, [(x, y0 + 2 * k) for x in range(18, 48)], PARCH[3])
        # a little clef
        px(cv, [(19, y0 - 1), (20, y0), (19, y0 + 1), (19, y0 + 2), (20, y0 + 3), (21, y0 + 4), (20, y0 + 5), (19, y0 + 6),
                (19, y0 + 7), (20, y0 + 8), (19, y0 + 9)], NIGHT[2])
    # seven notes (a gentle tune: it goes down)
    notes = [(24, 18, 25), (29, 18, 23), (34, 18, 21), (40, 18, 23), (25, 31, 35), (31, 31, 37), (37, 31, 39)]
    for x, y0, y in notes:
        px(cv, [(x, y), (x + 1, y), (x + 2, y), (x, y + 1), (x + 1, y + 1), (x + 2, y + 1)], NIGHT[2])
        px(cv, [(x + 2, yy) for yy in range(y - 6, y)], NIGHT[2])
    # a sleepy moon and three z's
    px(cv, pix(minus(Mell(26, 46, 3.5, 3.5), Mell(28, 45, 3, 3))), GOLD[1])
    letter(cv, 33, 44, ["###", "..#", ".#.", "#..", "###"], DUSK[2])
    letter(cv, 38, 43, ["###", ".#.", "###"], DUSK[1])
    letter(cv, 43, 41, ["##", "##"][:0] + ["###", ".#.", "###"], DUSK[1])


def white_clover_sprig(cv, rnd):
    stem = Mline(bezier((34, 55), (37, 42), (31, 26), 12), 2); shade(cv, stem, LEAF, "edge")
    for st, c, r in ((((33, 55), (25, 48), (19, 40)), (17, 36), 5), (((35, 55), (42, 50), (46, 44)), (48, 41), 3.6)):
        shade(cv, Mline(bezier(*st, 10), 2), LEAF, "edge")
        for a in (-math.pi / 2, math.pi * 5 / 6, math.pi / 6):
            lx, ly = c[0] + r * .95 * math.cos(a), c[1] + r * .95 * math.sin(a)
            lf = Mrell(lx, ly, r, r * .8, a); shade(cv, lf, LEAF, "ball", rnd, .03)
            # the pale white-clover chevron
            for k in (-1, 1):
                cv.put(int(lx + k * r * .35), int(ly - r * .15), LEAF[0])
            cv.put(int(lx), int(ly + r * .1), LEAF[0])
    # the round head of little white florets
    C = (31, 18)
    head = Mell(C[0], C[1], 10.5, 10)
    shade(cv, head, lambda x, y: PINKW if y >= C[1] + 5 else WOOL, "ball", rnd, .04)
    hs = set(pix(head))
    for dy in range(-9, 10, 3):
        for dx in range(-9, 10, 3):
            x, y = C[0] + dx + (1 if (dy // 3) % 2 else 0), C[1] + dy
            if (x, y) not in hs: continue
            Rr = PINKW if y >= C[1] + 5 else WOOL
            for q, t in (((x + 1, y + 1), 3), ((x + 1, y), 2), ((x - 1, y - 1), 0)):
                if q in hs: cv.put(*q, Rr[t])
    shade(cv, Mell(31, 28, 3, 1.5), LEAF, "ball")


def mixed_up_letter(cv, rnd):
    env = Mrr(7, 19, 57, 50, 2); shade(cv, env, PARCH, "flat", rnd, .03)
    # flap edge peeking at the top
    px(cv, [(x, 20) for x in range(9, 56)], PARCH[0])
    # address, crossed out, written again, crossed out again
    scrawl(cv, 14, 38, 30, BR, rnd, 7)
    px(cv, pix(Mline([(13, 32), (39, 28)], 1)), EMBER[1])
    scrawl(cv, 18, 44, 36, BR, rnd, 5)
    scrawl(cv, 18, 36, 41, BR, rnd, 8)
    px(cv, pix(Mline([(17, 42), (37, 40)], 1)), EMBER[1])
    # wandering arrow
    px(cv, pix(Mline([(40, 42), (45, 45), (49, 42), (46, 39)], 1)), NIGHT[1])
    px(cv, [(45, 38), (46, 38), (47, 39), (45, 40)], NIGHT[1])
    # crooked stamp
    st = Mpoly([(41, 21), (51, 23), (49, 33), (39, 31)]); shade(cv, st, SEA, "flat")
    for x, y in pix(st):
        if not all(st.getpixel((x + dx, y + dy)) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))) and (x + y) % 2: cv.put(x, y, WOOL[0])
    for x, y in ((44, 25), (46, 25), (43, 26), (44, 26), (45, 26), (46, 26), (47, 26), (44, 27), (45, 27), (46, 27), (45, 28)):
        cv.put(x, y, EMBER[1])
    # postmark rings
    for r in (4, 6):
        for k in range(14):
            a = k * math.pi / 7
            if k % 4 != 3: cv.put(int(34 + r * math.cos(a)), int(25 + r * .7 * math.sin(a)), STONE[3])
    # big puzzled question mark
    q = Mline([(13, 8), (14, 4), (18, 3), (21, 5), (20, 9), (17, 11), (17, 13)], 3)
    shade(cv, q, DUSK, "edge"); shade(cv, Mell(17, 16.5, 1.8, 1.6), DUSK, "ball")


def honey_parcel(cv, rnd):
    bundle = Mell(31, 41, 20, 13.5); shade(cv, bundle, LEAF, "ball", rnd, .05)
    # dock-leaf veins
    rib = bezier((13, 47), (28, 38), (47, 30), 20)
    px(cv, pix(Mline(rib, 1)), LEAF[0])
    for i in (5, 9, 13, 17):
        x, y = rib[i]
        for dy in (-1, 1):
            px(cv, [p for p in pix(Mline([(x, y), (x + 4, y + dy * 5)], 1)) if bundle.getpixel(p)], LEAF[3])
    # the leaf's tip folded up over the top
    tip = Mpoly(axis_poly((38, 31), -1.0, [(0, 5), (7, 5.5), (15, 3.5), (21, .4)]))
    shade(cv, tip, LEAF, "ball", rnd, .03)
    px(cv, pix(Mline([(38, 31), (49, 14)], 1)), LEAF[1])
    # string, round and round
    px(cv, [(x, y) for x, y in pix(Mline(bezier((27, 28), (31, 41), (27, 55), 12), 2)) if bundle.getpixel((x, y))], WOOL[2])
    px(cv, [(x, y) for x, y in pix(Mline(bezier((11, 40), (31, 45), (51, 40), 12), 2)) if bundle.getpixel((x, y))], WOOL[2])
    shade(cv, Mdots([(26, 29, 2.6), (32, 28, 2.6)]), WOOL, "ball")
    # honey oozing out of the bottom fold
    goo = union(Mell(17, 47, 4.5, 3), Mrect(15, 47, 19, 53), Mell(17, 53.5, 2.2, 2.2))
    shade(cv, goo, SYRUP, "ball")
    px(cv, [(15, 46), (16, 45), (15, 49), (15, 50)], CREAM)
    # one interested bee
    shade(cv, Mdots([(11, 14, 2), (15, 13.5, 2)]), ICE, "ball", rim=False)
    shade(cv, Mell(13, 18, 4, 3), GOLD, "ball")
    px(cv, [(12, 16), (12, 17), (12, 18), (12, 19), (14, 16), (14, 17), (14, 18), (14, 19)], INK)

    def post(c):
        for x, y in ((19, 19), (21, 18), (23, 19), (25, 21)): c.put(x, y, WOOL[2])
    return post


def bunty_parcel(cv, rnd):
    top = Mpoly([(9, 26), (31, 16), (54, 26), (32, 36)])
    left = Mpoly([(9, 26), (32, 36), (32, 55), (9, 45)])
    right = Mpoly([(32, 36), (54, 26), (54, 45), (32, 55)])
    shade(cv, left, BROWN, 2, rnd, .03, rim=False)
    shade(cv, right, BROWN, 3, rnd, .03, rim=False)
    shade(cv, top, BROWN, 1, rnd, .03, rim=False)
    px(cv, [(x, y) for x, y in pix(left) if not left.getpixel((x, y - 1))], BROWN[0])
    px(cv, [(x, y) for x, y in pix(right) if not right.getpixel((x, y - 1))], BROWN[2])
    px(cv, [(32, y) for y in range(36, 55)], BROWN[4])
    # string: a cross on top and down both faces
    S1 = [(20, 21), (43, 31)]; S2 = [(42, 21), (21, 31)]
    for a, b in (S1, S2): px(cv, pix(Mline([a, b], 2)), WOOL[1])
    px(cv, pix(Mline([(21, 31), (21, 50)], 2)), WOOL[1]); px(cv, [(22, y) for y in range(32, 51)], WOOL[3])
    px(cv, pix(Mline([(43, 31), (43, 50)], 2)), WOOL[2]); px(cv, [(44, y) for y in range(31, 50)], WOOL[4])
    # bow
    shade(cv, Mrell(26, 22, 4.5, 2.6, -.4), WOOL, "ball"); shade(cv, Mrell(37, 22, 4.5, 2.6, .4), WOOL, "ball")
    shade(cv, Mline([(30, 26), (27, 31)], 2), WOOL, "edge"); shade(cv, Mline([(33, 26), (37, 30)], 2), WOOL, "edge")
    shade(cv, Mell(31.5, 24, 2, 2), WOOL, "ball")
    # tag with a big B for Bunty
    px(cv, pix(Mline([(43, 33), (47, 37)], 1)), WOOL[2])
    tag = Mpoly([(45, 36), (54, 34), (56, 46), (47, 48)]); shade(cv, tag, PARCH, "flat")
    cv.put(47, 38, BROWN[4])
    letter(cv, 49, 39, ["###.", "#..#", "###.", "#..#", "###."], EMBER[2])

    def post(c):
        for x0 in (22, 34):
            for k in range(7): c.put(x0 + (1 if k % 4 in (1, 2) else 0), 13 - k, TOAST[1] if k < 4 else TOAST[0])
    return post


def owl_letter(cv, rnd):
    slab = Mrr(10, 22, 56, 52, 3); shade(cv, slab, SNOW, 3, rim=True)
    env = Mrr(8, 19, 54, 49, 3); shade(cv, env, SNOW, "ball", rnd, .02, box=(4, 10, 58, 58))
    # the flap
    flap = [(9, 20), (31, 37), (53, 20)]
    px(cv, pix(Mline(flap, 1)), SNOW[3]); px(cv, [(x, y - 1) for x, y in pix(Mline(flap, 1))], SNOW[0])
    # tucked white feather
    O, ang = (34, 33), -1.0
    vane = Mpoly(axis_poly(O, ang, [(2, 2), (8, 4.6), (16, 4.4), (22, 2.5), (25, .3)]))
    shade(cv, vane, WOOL, "ball")
    ux, uy = math.cos(ang), math.sin(ang)
    px(cv, [(int(O[0] + s * ux), int(O[1] + s * uy)) for s in range(0, 24)], WOOL[3])
    for s in (9, 13, 17):
        x, y = O[0] + s * ux, O[1] + s * uy
        px(cv, pix(Mline([(x, y), (x + 3, y + 1)], 1)), WOOL[2])
    # snowflake wax seal
    seal = Mdots([(31, 37, 6), (27, 39, 2.5), (35, 41, 2.2), (36, 33, 2)]); shade(cv, seal, BLUE, "ball")
    for k in range(3):
        a = k * math.pi / 3
        px(cv, pix(Mline([(31 - 3.6 * math.cos(a), 37 - 3.6 * math.sin(a)), (31 + 3.6 * math.cos(a), 37 + 3.6 * math.sin(a))], 1)), CREAM)
    cv.put(31, 37, BLUE[0])
    # the careful capitals peeking out on the side
    for x in range(12, 22, 2): px(cv, [(x, 44), (x, 45)], NIGHT[2])
    for x in range(41, 51, 2): px(cv, [(x, 44), (x, 45)], NIGHT[2])

    def post(c):
        sparkle(c, 9, 12, SNOW[1]); sparkle(c, 56, 12, CREAM)
    return post


def sticky_spoon(cv, rnd):
    handle = Mpoly(axis_poly((11, 55), -.86, [(0, 3), (22, 2.6), (30, 1.8)]))
    shade(cv, handle, WOOD, "edge", rnd, .08)
    px(cv, pix(Mline([(14, 50), (24, 38)], 1)), WOOD[1])
    bowl = Mrell(42, 21, 12, 9, -.86); shade(cv, bowl, WOOD, "ball", rnd, .05)
    # a big gloop of syrup in the bowl, running over
    glob = union(Mrell(43, 20, 9, 6.5, -.86), Mdots([(34, 28, 2.6), (31, 31, 2)]))
    shade(cv, glob, SYRUP, "ball", box=(30, 10, 54, 34))
    drip = union(Mrect(29, 31, 32, 40), Mell(30.5, 41, 2.4, 2.8)); shade(cv, drip, SYRUP, "edge")
    px(cv, [(40, 16), (41, 15), (42, 15), (39, 17), (30, 33), (30, 34)], CREAM)
    shade(cv, union(Mell(31, 49, 2, 2.2), Mpoly([(31, 45), (32.8, 48.5), (29.2, 48.5)])), SYRUP, "ball")

    def post(c):
        sparkle(c, 56, 8, PETAL[0], True); sparkle(c, 22, 18, CREAM); c.put(52, 36, PETAL[0])
    return post


def spider_hammock(cv, rnd):
    for trunk, fork in ((((12, 56), (11, 32), (13, 12)), ((13, 18), (7, 10))), (((52, 56), (53, 32), (51, 12)), ((51, 19), (57, 11)))):
        shade(cv, Mline(trunk, 3), WOOD, "edge", rnd, .05)
        shade(cv, Mline(fork, 2), WOOD, "edge")
    shade(cv, Mrell(8, 9, 3.5, 2, -.7), LEAF, "ball"); shade(cv, Mrell(56, 9, 3.5, 2, .7), LEAF, "ball")
    # silk ropes
    px(cv, pix(Mline([(13, 25), (20, 30)], 1)) + pix(Mline([(51, 25), (44, 30)], 1)), WOOL[0])
    sling = minus(inter(Mell(32, 29, 14, 13), Mrect(0, 29, 64, 64)), Mell(32, 28, 12, 6.5))
    shade(cv, sling, WOOL, "ball", box=(18, 20, 46, 43))
    for x, y in pix(sling):
        if (x + y) % 3 == 0 or (x - y) % 3 == 0: tint(cv, [(x, y)], WOOL, 1)
    shade(cv, Mrell(23, 31, 3.5, 2.2, .4), PETAL, "ball")          # a petal pillow
    # the polite spider, waving
    shade(cv, Mell(41, 27, 2.8, 2.4), DUSK, "ball")
    shade(cv, Mell(37.5, 28, 1.8, 1.8), DUSK, "ball")

    def post(c):
        for (a, b) in (((39, 30), (37, 32)), ((41, 30), (41, 32)), ((43, 29), (45, 31)), ((44, 26), (46, 25)), ((43, 25), (44, 22)), ((40, 25), (40, 22))):
            for x, y in pix(Mline([a, b], 1)): c.put(x, y, INK)
        c.put(37, 27, CREAM); c.put(38, 27, CREAM)
        c.put(44, 21, INK); c.put(45, 20, INK)
        for x, y in ((6, 24), (58, 30)): c.put(x, y, WOOL[0])
    return post


def derby_rosette(cv, rnd):
    shade(cv, Mpoly([(24, 34), (32, 36), (27, 57), (23, 52), (18, 56)]), EMBER, "cyl")
    shade(cv, Mpoly([(32, 36), (40, 34), (46, 56), (41, 52), (37, 57)]), WOOL, "cyl")
    C = (32, 22)
    outer = Mpoly([(C[0] + (16.5 + 1.6 * math.cos(18 * a)) * math.cos(a), C[1] + (16.5 + 1.6 * math.cos(18 * a)) * math.sin(a))
                   for a in (k * math.pi / 72 for k in range(144))])

    def pleat(x, y):
        a = math.atan2(y + .5 - C[1], x + .5 - C[0])
        return EMBER if int((a + math.pi) / (2 * math.pi) * 18) % 2 else WOOL
    shade(cv, outer, pleat, "ball")
    mid = Mell(C[0], C[1], 12, 12); shade(cv, mid, EMBER, "ball")
    for k in range(16):
        a = k * math.pi / 8
        px(cv, pix(inter(Mline([C, (C[0] + 12 * math.cos(a), C[1] + 12 * math.sin(a))], 1), minus(mid, Mell(C[0], C[1], 8.5, 8.5)))), EMBER[3])
    disc = Mell(C[0], C[1], 8, 8); shade(cv, disc, WOOL, "ball")
    # a little sled on the button
    px(cv, [(x, 25) for x in range(27, 37)] + [(37, 24), (38, 23)], WOOD[3])
    px(cv, [(29, 24), (34, 24)], WOOD[3])
    px(cv, [(x, y) for x in range(28, 37) for y in (21, 22, 23)], EMBER[1])
    px(cv, [(x, 21) for x in range(28, 37)], EMBER[0])


def beaver_badge(cv, rnd):
    shade(cv, Mline([(23, 14), (32, 4), (41, 14)], 1), WOOD, 3, rim=False)
    shield = union(Mrect(13, 12, 51, 31), inter(Mell(32, 30, 19, 25), Mrect(0, 30, 64, 64)))
    bite = Mdots([(51, 13, 3.5), (47, 11, 2.5), (52, 18, 2)])
    shield = minus(shield, bite)
    shade(cv, shield, BIRCH, "ball", rnd, .04)
    face = minus(union(Mrect(17, 16, 47, 31), inter(Mell(32, 30, 15, 21), Mrect(0, 30, 64, 64))), bite)
    shade(cv, face, BIRCH, "flat", rnd, .03, rim=False, hi=False)
    for x, y in pix(face):                                          # bevel
        if not face.getpixel((x, y - 1)) or not face.getpixel((x - 1, y)): cv.put(x, y, BIRCH[3])
        elif not face.getpixel((x, y + 1)) or not face.getpixel((x + 1, y)): cv.put(x, y, BIRCH[0])
    for x0 in (22, 29, 37, 43):                                     # grain
        for y in range(18, 48):
            x = x0 + int(1.5 * math.sin(y / 4 + x0))
            if face.getpixel((x, y)) and (y * 3 + x0) % 7: cv.put(x, y, BIRCH[2])
    # stamped paw
    PAW = WOOD[3]
    for m in (Mell(32, 36, 6.5, 5.5), Mrell(23, 27, 2.4, 3, -.5), Mrell(28, 22, 2.4, 3, -.2), Mrell(36, 22, 2.4, 3, .2), Mrell(41, 27, 2.4, 3, .5)):
        px(cv, pix(m), PAW)
        px(cv, [(x, y) for x, y in pix(m) if not m.getpixel((x + 1, y)) or not m.getpixel((x, y + 1))], WOOD[4])
    # tooth marks on the bitten corner
    for x, y in ((46, 14), (47, 15), (49, 17)): cv.put(x, y, BIRCH[0])

    def post(c):
        for x, y in ((56, 9), (58, 13)): c.put(x, y, BIRCH[1]); c.put(x + 1, y, BIRCH[3])
    return post


def five_leaf_clover(cv, rnd):
    stem = Mline(bezier((38, 56), (40, 42), (32, 30), 12), 3); shade(cv, stem, LEAF, "edge")
    C = (31, 25)
    owner = {}
    for k in range(5):
        a = -math.pi / 2 + k * 2 * math.pi / 5
        ux, uy = math.cos(a), math.sin(a); nx, ny = -uy, ux
        R = LEAF if k != 3 else MOSS                                 # the one nobody checked
        hx, hy = C[0] + 11.5 * ux, C[1] + 11.5 * uy
        heart = union(Mdots([(hx + 3.3 * nx, hy + 3.3 * ny, 4.6), (hx - 3.3 * nx, hy - 3.3 * ny, 4.6)]),
                      Mpoly([(C[0], C[1]), (hx + 7 * nx - 1 * ux, hy + 7 * ny - 1 * uy), (hx - 7 * nx - 1 * ux, hy - 7 * ny - 1 * uy)]))
        shade(cv, heart, R, "ball", rnd, .03)
        for p_ in pix(heart): owner[p_] = k
        for t in (5, 6, 7, 8, 9):
            cv.put(int(C[0] + t * ux), int(C[1] + t * uy), R[1])
        for side in (1, -1):
            for t in range(3):
                cv.put(int(hx - (1 + t) * ux * .6 + side * (1.6 + t) * nx), int(hy - (1 + t) * uy * .6 + side * (1.6 + t) * ny), R[0])
    for (x, y), k in owner.items():                                 # dark seams between leaflets
        if any(owner.get((x + dx, y + dy), k) != k for dx, dy in ((1, 0), (0, 1), (-1, 0), (0, -1))) and math.hypot(x - C[0], y - C[1]) > 2.5:
            cv.put(x, y, LEAF[4])
    shade(cv, Mell(C[0], C[1], 2, 2), LEAF, "ball")

    def post(c):
        sparkle(c, 9, 10, GOLD[0], True); sparkle(c, 55, 7, GOLD[0]); sparkle(c, 56, 44, GOLD[1]); c.put(8, 40, GOLD[1])
    return post


def clover_ledger(cv, rnd):
    board = Mrr(13, 9, 51, 57, 3); shade(cv, board, WOOD, "ball", rnd, .05, box=(6, 2, 58, 64))
    paper = Mrect(16, 14, 48, 54); shade(cv, paper, WOOL, "flat", rim=False)
    px(cv, [(x, 54) for x in range(16, 48)], WOOD[4]); px(cv, [(48, y) for y in range(15, 55)], WOOD[4])
    # the clip
    clip = Mrr(23, 6, 41, 17, 2); shade(cv, clip, STONE, "ball")
    px(cv, pix(minus(Mell(32, 8, 4, 2.4), Mell(32, 8, 2.5, 1.2))), STONE[4])
    px(cv, [(x, 15) for x in range(24, 40)], STONE[3])
    # rows: box, tick, a tiny clover, initials
    for i, y in enumerate(range(20, 52, 6)):
        bx = Mrect(18, y, 22, y + 4); px(cv, pix(minus(bx, Mrect(19, y + 1, 21, y + 3))), STONE[3])
        px(cv, [(18, y + 2), (19, y + 3), (20, y + 2), (21, y + 1), (22, y)], LEAF[2])
        if i % 2 == 0: px(cv, [(18, y + 3), (19, y + 4), (21, y), (22, y - 1)], LEAF[2])     # double-checked
        for dx, dy in ((0, 0), (2, 0), (1, -1), (1, 1)): cv.put(25 + dx, y + 2 + dy, LEAF[1])
        scrawl(cv, 29, 40 - (i % 3) * 2, y + 2, STONE[3], rnd, 5)
        px(cv, [(43, y + 1), (43, y + 2), (44, y + 3), (45, y + 1), (45, y + 2)], EMBER[2])
    # pencil
    O, ang = (40, 58), -1.15
    tube(cv, O, ang, 0, 3, 1.8, PETAL)
    tube(cv, O, ang, 3, 5, 1.8, STONE)
    tube(cv, O, ang, 5, 22, 1.8, GOLD)
    tip = Mpoly(axis_poly(O, ang, [(22, 1.8), (26, .2)])); shade(cv, tip, WOOD, 1)


def left_handed_spiral(cv, rnd):
    tilt = -.2
    whorls = [(35, 9, 2.4, 2.2), (34.5, 13, 4, 3), (33.5, 18, 6, 4), (32.5, 25, 9, 5.5), (31, 34, 12.5, 7.5), (30, 45, 16, 10)]
    for i, (cx, cy, rx, ry) in enumerate(whorls):
        m = Mrell(cx, cy, rx, ry, tilt)
        shade(cv, m, SHELL, "ball", rnd, .03)
        if i >= 2:
            for x, y in pix(m):
                v = (y + .5 - cy) - math.tan(tilt) * (x + .5 - cx)
                if abs(v - ry * .25) < .8 and (x // 2) % 2 == 0: cv.put(x, y, SHELL[3] if x > cx else SHELL[2])
                if abs(v + ry * .3) < .6 and (x // 3) % 2 == 1 and i >= 3: cv.put(x, y, PETAL[2] if x < cx + 4 else PETAL[3])
    # the opening on the LEFT, which is the whole fuss
    lip = Mrell(19, 45, 7, 9, -.35); shade(cv, lip, SHELL, "ball")
    shade(cv, Mrell(19.5, 45.5, 4.6, 6.6, -.35), PETAL, "ball")
    shade(cv, Mrell(20.5, 46.5, 2.6, 4.2, -.35), PETAL, 3, rim=False)
    px(cv, [(16, 40), (16, 41), (15, 42)], CREAM)

    def post(c):
        # a curly arrow going the wrong way round
        pts = [(34 + 14 * math.cos(t), 12 + 7 * math.sin(t)) for t in (math.radians(d) for d in range(10, -191, -6))]
        for x, y in pts: c.put(int(x), int(y), EMBER[0])
        ex, ey = pts[-1]
        for dx, dy in ((0, 1), (0, 2), (-1, 1), (1, 1), (-2, 0), (2, 0)): c.put(int(ex) + dx, int(ey) + dy, EMBER[0])
        sparkle(c, 54, 26, CREAM, True)
    return post


def starfish_friend(cv, rnd):
    C, pts = (32, 32), []
    for k in range(10):
        a = -math.pi / 2 + k * math.pi / 5
        r = 24 if k % 2 == 0 else 10
        if k == 2: a -= .28; r = 25
        pts.append((C[0] + r * math.cos(a), C[1] + r * math.sin(a)))
    tips = [(x, y, 3) for x, y in pts[::2]]
    tips = [(x - (x - C[0]) * .1, y - (y - C[1]) * .1, 3.2) for x, y, _ in tips]
    star = union(Mpoly(pts), Mdots(tips))
    shade(cv, star, CORAL, "ball", rnd, .03, box=(6, 6, 58, 58))
    # bumps along each arm
    for x, y in pts[::2]:
        for t in (.35, .55, .75):
            bx, by = int(C[0] + (x - C[0]) * t), int(C[1] + (y - C[1]) * t)
            cv.put(bx, by, CORAL[0]); cv.put(bx + 1, by + 1, CORAL[3])
    # friendly face
    for ex in (28, 35):
        px(cv, [(ex, 30), (ex + 1, 30), (ex, 31), (ex + 1, 31), (ex, 32), (ex + 1, 32)], INK); cv.put(ex, 30, CREAM)
    px(cv, [(30, 35), (31, 36), (32, 36), (33, 36), (34, 35)], INK)
    px(cv, [(26, 34), (27, 34), (37, 34), (38, 34)], PETAL[1])

    def post(c):
        for x, y, r in ((55, 10, 2), (59, 4, 1)):
            for a in range(0, 360, 45):
                c.put(int(x + r * math.cos(math.radians(a))), int(y + r * math.sin(math.radians(a))), SEA[0])
        sparkle(c, 8, 12, CREAM)
    return post


def crab_gavel(cv, rnd):
    # sounding block
    shade(cv, Mrect(14, 46, 50, 52), DRIFT, "cyl", rnd, .05, box=(14, 40, 50, 56))
    shade(cv, Mell(32, 52, 18, 3.5), DRIFT, 3, rim=True)
    shade(cv, Mrect(14, 46, 50, 52), DRIFT, "cyl", rnd, .05, box=(14, 40, 50, 56))
    shade(cv, Mell(32, 46, 18, 4), DRIFT, "ball", rnd, .03)
    px(cv, pix(minus(Mell(32, 46, 12, 2.6), Mell(32, 46, 10.5, 1.6))), DRIFT[2])
    # gavel: handle, then the head
    O, ang = (47, 41), -2.35
    tube(cv, O, ang, 0, 27, 2.4, DRIFT, rnd, .06)
    ux, uy = math.cos(ang), math.sin(ang)
    hx, hy = O[0] + 29 * ux, O[1] + 29 * uy
    hang = ang + math.pi / 2
    tube(cv, (hx, hy), hang, -12, 12, 6.2, DRIFT, rnd, .08, stripe=lambda s, d: abs(abs(s) - 8) < 1)
    for sgn in (1, -1):
        ex, ey = hx + sgn * 12 * math.cos(hang), hy + sgn * 12 * math.sin(hang)
        shade(cv, Mrell(ex, ey, 1.6, 6.2, hang), DRIFT, 1 if sgn < 0 else 2)
    # grain
    for s in range(-10, 11, 3):
        x, y = hx + s * math.cos(hang), hy + s * math.sin(hang)
        cv.put(int(x - 2 * ux), int(y - 2 * uy), DRIFT[3])
    # the crab, banging for order
    cx, cy = 50, 50
    shade(cv, Mell(cx, cy, 6, 4), EMBER, "ball")
    for sx in (-1, 1):
        shade(cv, Mline([(cx + sx * 4, cy - 2), (cx + sx * 7, cy - 6)], 2), EMBER, "edge")
        shade(cv, Mdots([(cx + sx * 7, cy - 8, 2.2)]), EMBER, "ball")
    for sx in (-2, 2): px(cv, [(cx + sx, cy - 4), (cx + sx, cy - 5)], EMBER[3])

    def post(c):
        for sx in (-2, 2): c.put(cx + sx, cy - 6, INK)
        for x, y in ((cx - 7, cy - 9), (cx + 7, cy - 9)): c.put(x, y, INK)
        for x, y in ((cx - 2, cy + 1), (cx - 1, cy + 2), (cx, cy + 2), (cx + 1, cy + 2), (cx + 2, cy + 1)): c.put(x, y, INK)
        for x, y in ((9, 20), (8, 24)): c.put(x, y, DRIFT[0])
        sparkle(c, 6, 14, CREAM)
    return post


ITEMS = {
    "gate-rubbing": gate_rubbing, "hush-page": hush_page, "snore-note": snore_note, "lucky-wick": lucky_wick,
    "scouts-spyglass": scouts_spyglass, "book-of-hushes": book_of_hushes, "lullaby-song-sheet": lullaby_song_sheet,
    "white-clover-sprig": white_clover_sprig, "mixed-up-letter": mixed_up_letter, "honey-parcel": honey_parcel,
    "bunty-parcel": bunty_parcel, "owl-letter": owl_letter, "sticky-spoon": sticky_spoon, "spider-hammock": spider_hammock,
    "derby-rosette": derby_rosette, "beaver-badge": beaver_badge, "five-leaf-clover": five_leaf_clover,
    "clover-ledger": clover_ledger, "left-handed-spiral": left_handed_spiral, "starfish-friend": starfish_friend,
    "crab-gavel": crab_gavel,
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
    if bb[1] + dy < 1 or bb[0] + dx < 1 or bb[2] + dx > S - 1: print(f"warning: {slug} touches the edge", file=sys.stderr)
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
    slugs = sys.argv[1:] or list(ITEMS)
    for slug in slugs:
        render(slug).save(os.path.join(OUT, slug + ".png"))
    print(f"wrote {len(slugs)} item pictures to {OUT}")


if __name__ == "__main__":
    main()
