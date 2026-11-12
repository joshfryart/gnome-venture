"""Hearth Pop v3 item pictures for Trail Sight items, part C (rows 43-62 of game/includes/data/trail_sight_items.txt).
64 x 64 RGBA, hard pixels, 1 px ink outline, light from the top-left, a soft translucent ground shadow.
Deterministic and re-runnable. Run from the repo root: python3 tools/gen_sight_item_art_c.py"""
import math, os, random, sys
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "claude", "tile-art-v3-proposal"))
import gen2
from gen2 import RAMP, INK, CREAM, H, mix, r5, Cv, outline, shade_pt, tone5

OUT = os.path.join(ROOT, "game", "assets", "img", "ph")
S = 64

# ---------------------------------------------------------------- ramps (5 tones, light -> dark)
def R(*hx): return [H(h) for h in hx]
GOLD = r5(RAMP["gold"]); SEA = r5(RAMP["sea"]); ICE = r5(RAMP["ice"]); SNOW = r5(RAMP["snow"])
LEAF = r5(RAMP["leaf"]); MOSS = r5(RAMP["moss"]); WOOD = r5(RAMP["wood"]); LITTER = r5(RAMP["litter"])
SAND = r5(RAMP["sand"]); STONE = r5(RAMP["stone"]); EMBER = r5(RAMP["ember"]); PETAL = r5(RAMP["petal"])
DUSK = r5(RAMP["dusk"]); PINE = r5(RAMP["pine"])
AMBER = R("#ffe09a", "#f6b04a", "#d97a26", "#a44a1c", "#62281a")
CORAL = R("#ffd6dc", "#ffa8b8", "#f57c98", "#cf507a", "#8a2c5a")
BREAD = R("#ffe2a8", "#f2b866", "#d68a3e", "#a35a2a", "#64321f")
WAX = R("#fffaf0", "#fbefd2", "#ecd6a8", "#c9a87a", "#8a6a4f")
CHALK = R("#fffdf6", "#f3eee6", "#dcd5d8", "#aea8bd", "#7b7a96")
LANTERN = R("#fff4d6", "#ffd27a", "#ffa04a", "#e8693a", "#a8402e")
SLATE = R("#8f93a8", "#6f7390", "#555973", "#3e4058", "#2c2d40")
BLUSH = H("#f5809f")

# ---------------------------------------------------------------- masks and fills
def mask(fn):
    m = Image.new("L", (S, S), 0); fn(ImageDraw.Draw(m)); p = m.load()
    return {(x, y) for y in range(S) for x in range(S) if p[x, y]}
def m_ell(cx, cy, rx, ry): return mask(lambda d: d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=255))
def m_poly(pts): return mask(lambda d: d.polygon(pts, fill=255))
def m_line(pts, w): return mask(lambda d: d.line(pts, fill=255, width=w))
def m_rect(x0, y0, x1, y1): return {(x, y) for y in range(y0, y1) for x in range(x0, x1)}
def fill(cv, M, c):
    for x, y in M: cv.put(x, y, c)
def bevel(cv, M, Rm, d=(1, 1), cuts=(.16, .38, .68, .88), lo=0, hi=4, rnd=None, speck=0.0):
    """Shade any shape: tone from how far a pixel sits from the lit (top-left) edge vs the shaded edge."""
    dx, dy = d
    for x, y in M:
        a = 0
        while (x - (a + 1) * dx, y - (a + 1) * dy) in M: a += 1
        b = 0
        while (x + (b + 1) * dx, y + (b + 1) * dy) in M: b += 1
        t = (a + .5) / (a + b + 1)
        k = 0 if t < cuts[0] else 1 if t < cuts[1] else 2 if t < cuts[2] else 3 if t < cuts[3] else 4
        if rnd and rnd.random() < speck: k += rnd.choice((-1, 1))
        cv.put(x, y, Rm[max(lo, min(hi, k))])
def sphere(cv, cx, cy, rx, ry, Rm, rnd=None, speck=0.0, rim=True):
    M = set()
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry
            if nx * nx + ny * ny > 1: continue
            t = tone5(shade_pt(nx, ny))
            if rnd and rnd.random() < speck: t = max(0, min(4, t + rnd.choice((-1, 1))))
            cv.put(x, y, Rm[t]); M.add((x, y))
    if rim:
        for x, y in M:
            nx = (x + .5 - cx) / rx; ny = (y + .5 - cy) / ry
            if nx + ny > .2 and ((x + 1, y) not in M or (x, y + 1) not in M): cv.put(x, y, Rm[4])
    return M
def edge_of(M):
    return {(x, y) for x, y in M if any((x + a, y + b) not in M for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1)))}
def line(cv, x0, y0, x1, y1, c, w=1):
    n = int(max(abs(x1 - x0), abs(y1 - y0), 1))
    for i in range(n + 1):
        x = x0 + (x1 - x0) * i / n; y = y0 + (y1 - y0) * i / n
        for ax in range(w):
            for ay in range(w): cv.put(int(round(x)) + ax - w // 2, int(round(y)) + ay - w // 2, c)
def path(cv, pts, c, w=1):
    for (a, b), (c2, d2) in zip(pts, pts[1:]): line(cv, a, b, c2, d2, c, w)
def sparkle(cv, x, y, c=CREAM, big=False):
    for a, b in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)): cv.put(x + a, y + b, c)
    if big:
        for a, b in ((2, 0), (-2, 0), (0, 2), (0, -2)): cv.put(x + a, y + b, c)
def star_pts(cx, cy, ro, ri, n=5, rot=-math.pi / 2):
    return [(cx + (ro if i % 2 == 0 else ri) * math.cos(rot + i * math.pi / n), cy + (ro if i % 2 == 0 else ri) * math.sin(rot + i * math.pi / n)) for i in range(2 * n)]
def zz(cv, x, y, s=3, c=INK):   # a little sleepy "z"
    line(cv, x, y, x + s, y, c); line(cv, x + s, y, x, y + s, c); line(cv, x, y + s, x + s, y + s, c)
def note(cv, x, y, c=INK):     # an eighth note, head at (x, y)
    for a, b in ((0, 0), (1, 0), (-1, 0), (0, 1), (1, 1), (0, -1)): cv.put(x + a, y + b, c)
    line(cv, x + 1, y - 1, x + 1, y - 6, c); line(cv, x + 2, y - 6, x + 3, y - 4, c); cv.put(x + 3, y - 3, c)

class Pic:
    def __init__(s, shadow=(32, 56, 16)):
        s.under = Cv(S, S); s.obj = Cv(S, S); s.over = Cv(S, S); s.shadow = shadow
    def render(s):
        base = Image.new("RGBA", (S, S), (0, 0, 0, 0))
        if s.shadow:
            cx, cy, rx = s.shadow; ry = max(2, rx // 5); d = ImageDraw.Draw(base)
            d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=INK[:3] + (64,))
            d.ellipse((cx - rx + 3, cy - ry + 1, cx + rx - 3, cy + ry - 1), fill=INK[:3] + (104,))
        base.alpha_composite(s.under.im)
        outline(s.obj); base.alpha_composite(s.obj.im); base.alpha_composite(s.over.im)
        return base

# ================================================================ the items
def wishing_coin(rnd):
    p = Pic((32, 56, 15)); o = p.obj
    fill(o, m_ell(35, 32, 17, 21), GOLD[3])            # coin edge (thickness)
    fill(o, m_ell(35, 33, 16, 20) - m_ell(33, 32, 17, 21), GOLD[4])
    face = m_ell(32, 32, 17, 21); bevel(o, face, GOLD)
    ring = m_ell(32, 32, 13, 17) - m_ell(32, 32, 12, 16)
    for x, y in ring: o.put(x, y, GOLD[0] if x + y > 64 else GOLD[3])
    st = m_poly(star_pts(32, 33, 10, 4.5)); bevel(o, st, [GOLD[0], GOLD[0], GOLD[1], GOLD[3], GOLD[3]])
    for x, y in edge_of(st):
        if x + y > 64: o.put(x, y, GOLD[4])
    for x, y in ((24, 20), (25, 19), (26, 18), (23, 22)): o.put(x, y, CREAM)   # glint on the rim
    for i, (x, y) in enumerate(((20, 46), (22, 49), (40, 47))): o.put(x, y, GOLD[3])  # worn dents
    # a little warm wish rising out of it
    v = p.over; sparkle(v, 52, 12, CREAM, big=True); sparkle(v, 12, 20, GOLD[0]); v.put(47, 6, CREAM); v.put(56, 22, GOLD[0])
    for x, y in ((47, 14), (48, 13), (46, 13), (47, 15)): pass
    return p

def giant_fern_spores(rnd):
    p = Pic((32, 57, 11)); o = p.obj
    cone = m_poly([(13, 25), (51, 22), (35, 51), (30, 51)]); bevel(o, cone, LEAF, d=(1, 0))
    tail = m_poly([(29, 50), (35, 50), (37, 57), (27, 57)]); bevel(o, tail, LEAF, d=(1, 0))
    line(o, 29, 52, 35, 52, LEAF[4]); line(o, 28, 55, 36, 54, LEAF[3])
    # the leaf's tip curling up on the right, with a fern frill along the rim
    tip = m_poly([(44, 23), (51, 22), (57, 13), (55, 9), (52, 16)]); bevel(o, tip, LEAF)
    line(o, 50, 21, 55, 11, LEAF[3])
    for i in range(4): line(o, 32 + i * 0, 26 + i * 6, 32, 30 + i * 6, LEAF[3])
    line(o, 32, 26, 32, 49, LEAF[3])
    for i, y in enumerate(range(29, 48, 5)):
        w = int((49 - y) * .45)
        line(o, 32, y, 32 - w, y - 3, LEAF[3]); line(o, 32, y, 32 + w, y - 3, LEAF[4])
    # opening full of green dust
    fill(o, m_ell(32, 24, 18, 4), LEAF[4])
    for cx, cy, rx, ry in ((24, 21, 7, 4), (33, 19, 8, 5), (41, 21, 6, 4), (29, 16, 5, 3), (37, 15, 5, 3)):
        sphere(o, cx, cy, rx, ry, MOSS, rnd, .12)
    # a puff drifting up
    for x, y, r in ((22, 8, 3), (16, 13, 2), (30, 6, 2)):
        sphere(o, x, y, r, r, [MOSS[0], MOSS[0], MOSS[1], MOSS[2], MOSS[2]], rim=False)
    v = p.over
    for x, y in ((12, 6), (26, 3), (40, 7), (9, 18), (36, 10), (19, 3)): v.put(x, y, MOSS[0] if (x + y) % 2 else MOSS[1])
    return p

def vine_twine(rnd):
    p = Pic((32, 54, 22)); o = p.obj
    x0, x1, cy, r, turns = 13, 49, 33, 11, 4.5
    pts = []
    n = 400
    for i in range(n + 1):
        t = i / n; a = t * turns * 2 * math.pi
        x = x0 + (x1 - x0) * t + 4 * math.sin(a); y = cy - r * math.cos(a) + 2 * math.sin(t * math.pi * 2)
        pts.append((x, y, math.sin(a)))
    def strand(front):
        for k in range(len(pts) - 1):
            x, y, z = pts[k]
            if (z >= 0) != front: continue
            for ax in range(-2, 3):
                for ay in range(-2, 3):
                    if ax * ax + ay * ay <= 5: o.put(int(round(x)) + ax, int(round(y)) + ay, INK)
        for k in range(len(pts) - 1):
            x, y, z = pts[k]
            if (z >= 0) != front: continue
            for ax in range(-1, 2):
                for ay in range(-1, 2):
                    if ax * ax + ay * ay <= 1:
                        c = (MOSS if front else PINE)[1 if (ax < 0 or ay < 0) else 2] if front else PINE[3]
                        o.put(int(round(x)) + ax, int(round(y)) + ay, c)
            if front: o.put(int(round(x)) - 1, int(round(y)) - 1, MOSS[0]) if k % 3 == 0 else None
    strand(False); strand(True)
    # loose ends curl into tendrils
    for (ex, ey, _), sx in ((pts[0], -1), (pts[-1], 1)):
        tp = [(ex + sx * (3 + 3 * math.sin(i / 14 * 2.6 * math.pi) * (1 - i / 20)) + sx * i * .25, ey + 2 + i * .9) for i in range(15)]
        path(o, tp, INK, 3); path(o, tp, MOSS[1], 1)
    lf = m_poly([(30, 18), (35, 13), (40, 14), (35, 19)]); bevel(o, lf, LEAF); line(o, 31, 18, 39, 14, LEAF[3])
    v = p.over; note(v, 47, 12); note(v, 55, 8); note(v, 14, 15)
    return p

def giants_bark_curl(rnd):
    p = Pic((32, 56, 23)); o = p.obj
    sheet = m_poly([(12, 38), (48, 38), (54, 53), (16, 53)])
    for x, y in sheet:
        u = (y - 38) / 15; k = 0 if u < .25 else 1 if u < .7 else 2
        if (y - 38) % 4 == 2 and (x * 3 + y) % 11 > 2: k = 2
        o.put(x, y, WOOD[k])
    lip = m_poly([(15, 51), (54, 51), (55, 55), (16, 55)]); bevel(o, lip, LITTER, d=(0, 1))
    # the rolled body: a horizontal cylinder of rough bark
    body = m_rect(13, 19, 47, 42) | m_ell(13, 30, 4, 11)
    for x, y in body:
        u = (y - 19) / 23; k = 0 if u < .14 else 1 if u < .38 else 2 if u < .7 else 3 if u < .9 else 4
        o.put(x, y, LITTER[k])
    for i in range(14):   # furrows
        x = rnd.randint(12, 45); y = rnd.randint(20, 34); L = rnd.randint(3, 7)
        for j in range(L): o.put(x + (j // 3) * rnd.choice((0, 1)), y + j, LITTER[4])
        o.put(x - 1, y, LITTER[0] if y < 28 else LITTER[1])
    # spiral end
    end = m_ell(47, 30, 7, 11); fill(o, end, LITTER[3])
    fill(o, m_ell(47, 30, 6, 10), WOOD[1])
    for i in range(160):
        a = i / 160 * 3.2 * 2 * math.pi; rr = .12 + i / 160 * .82
        o.put(int(round(47 + 6 * rr * math.cos(a))), int(round(30 + 10 * rr * math.sin(a))), WOOD[4])
    o.put(46, 29, WOOD[0]); o.put(48, 27, WOOD[0])
    # moss tuft
    for cx, cy, rx in ((22, 19, 4), (27, 18, 3)): sphere(o, cx, cy, rx, 2.5, MOSS, rnd, .1)
    v = p.over; zz(v, 52, 10, 3); zz(v, 57, 4, 2)
    return p

def raindrop_bead(rnd):
    p = Pic((32, 57, 20)); o = p.obj
    leaf = m_poly([(9, 52), (20, 47), (40, 46), (57, 49), (44, 55), (20, 56)]); bevel(o, leaf, LEAF, d=(0, 1))
    line(o, 12, 52, 52, 50, LEAF[3])
    for x in (20, 28, 36, 44): line(o, x, 51, x + 3, 48, LEAF[3]); line(o, x, 51, x + 3, 54, LEAF[3])
    drop = m_ell(32, 34, 15, 15) | m_poly([(19, 28), (32, 8), (45, 28)])
    for x, y in drop:
        nx, ny = (x - 32) / 15, (y - 32) / 17; k = 1
        o.put(x, y, ICE[1])
    e = edge_of(drop)
    for x, y in drop:
        near = min(abs(x - ex) + abs(y - ey) for ex, ey in e)
        if near <= 1: o.put(x, y, ICE[3] if x + y > 64 else ICE[2])
        elif near <= 2 and x + y > 68: o.put(x, y, ICE[2])
    # bottom caustic glow (light passing through)
    for x, y in m_ell(35, 41, 8, 4) & drop:
        if (x - 35) ** 2 / 64 + (y - 41) ** 2 / 16 > .35: o.put(x, y, ICE[0])
    for x, y in m_ell(34, 42, 6, 2): o.put(x, y, CREAM) if (x - 34) ** 2 / 36 + (y - 42) ** 2 / 4 > .5 and y >= 42 else None
    # the little window reflected in it
    fill(o, m_rect(23, 24, 30, 31), CREAM); line(o, 26, 24, 26, 30, ICE[1]); line(o, 23, 27, 29, 27, ICE[1])
    o.put(31, 18, CREAM); o.put(31, 19, CREAM); o.put(32, 15, ICE[0])
    v = p.over; sparkle(v, 50, 14, CREAM, big=True); sparkle(v, 13, 22, ICE[0])
    return p

def lantern_fruit(rnd):
    p = Pic((32, 57, 14)); o = p.obj; u = p.under
    body = m_ell(32, 36, 15, 17) | m_poly([(29, 51), (32, 56), (35, 51)])
    for x, y in body:
        nx, ny = (x + .5 - 32) / 15, (y + .5 - 36) / 17; dd = math.sqrt(nx * nx + ny * ny) + .25 * (nx + ny)
        k = 0 if dd < .3 else 1 if dd < .62 else 2 if dd < .92 else 3 if dd < 1.12 else 4
        o.put(x, y, LANTERN[k])
    for rib in (-.62, 0, .62):   # paper-lantern ribs
        for y in range(21, 53):
            ny = (y - 36) / 17
            if abs(ny) >= 1: continue
            x = 32 + rib * 15 * math.sqrt(1 - ny * ny)
            if (int(round(x)), y) in body: o.put(int(round(x)), y, LANTERN[3] if x + y > 68 or abs(ny) > .6 else LANTERN[2])
    cap = m_poly([(22, 22), (26, 17), (38, 17), (42, 22), (36, 21), (32, 24), (28, 21)]); bevel(o, cap, LEAF)
    line(o, 32, 17, 33, 9, WOOD[3], 2)
    lf = m_poly([(34, 12), (40, 7), (47, 8), (41, 13)]); bevel(o, lf, LEAF); line(o, 35, 12, 45, 8, LEAF[3])
    # a friendly face
    for x, y in ((26, 35), (26, 36), (37, 35), (37, 36)): o.put(x, y, INK)
    for x, y in ((29, 40), (30, 41), (31, 41), (32, 41), (33, 41), (34, 40)): o.put(x, y, INK)
    for x, y in ((23, 39), (24, 39), (40, 39), (41, 39)): o.put(x, y, BLUSH)
    o.put(24, 27, CREAM); o.put(25, 26, CREAM); o.put(23, 29, CREAM)
    v = p.over
    for x0, y0, x1, y1 in ((9, 22, 6, 20), (55, 22, 58, 20), (8, 40, 5, 41), (56, 40, 59, 41), (13, 12, 11, 10)):
        line(v, x0, y0, x1, y1, LANTERN[1])
    return p

def soup_mist_jar(rnd):
    p = Pic((32, 57, 17)); o = p.obj
    body = m_rect(17, 26, 48, 50) | m_ell(32, 49, 15, 5) | m_ell(32, 27, 15, 4)
    bevel(o, body, ICE, d=(1, 0), cuts=(.1, .3, .75, .92))
    neck = m_rect(21, 18, 44, 25); bevel(o, neck, ICE, d=(1, 0), cuts=(.1, .3, .75, .92))
    line(o, 20, 24, 44, 24, ICE[3]); line(o, 20, 18, 44, 18, ICE[2])
    # mist inside, soupy-cream swirls
    inner = m_rect(19, 29, 46, 51) | m_ell(32, 49, 13, 4)
    for x, y in inner:
        if (x, y) in body: o.put(x, y, SNOW[1])
    for cx, cy, rx, ry in ((24, 33, 6, 4), (35, 31, 7, 4), (42, 36, 4, 4), (27, 44, 8, 5), (39, 46, 7, 4), (22, 49, 4, 3)):
        for x, y in m_ell(cx, cy, rx, ry) & inner:
            nx, ny = (x - cx) / rx, (y - cy) / ry
            o.put(x, y, SNOW[0] if nx + ny < -.4 else SNOW[1] if nx + ny < .5 else SNOW[2])
    for i in range(50):   # swirl
        a = i / 50 * 2.4 * math.pi; rr = 2 + i * .17
        o.put(int(32 + rr * math.cos(a)), int(39 + rr * .6 * math.sin(a)), SNOW[3])
    for y in range(28, 49): o.put(19, y, CREAM)       # glass glint
    for y in range(30, 36): o.put(21, y, CREAM)
    for x in range(18, 47): o.put(x, 26, ICE[2])
    # label with a soup bowl
    lab = m_rect(26, 36, 40, 46); fill(o, lab, SAND[0]); fill(o, m_rect(26, 45, 40, 46), SAND[2])
    for x, y in edge_of(lab): o.put(x, y, SAND[3])
    bowl = m_poly([(29, 40), (37, 40), (36, 43), (30, 43)]); fill(o, bowl, EMBER[2]); line(o, 29, 40, 37, 40, EMBER[0])
    o.put(31, 38, WOOD[3]); o.put(32, 39, WOOD[3]); o.put(34, 38, WOOD[3]); o.put(35, 39, WOOD[3])
    # cork
    cork = m_rect(22, 10, 43, 18) | m_ell(32, 10, 10, 3); bevel(o, cork, WOOD, d=(1, 0))
    for x, y in m_ell(32, 10, 10, 3): o.put(x, y, WOOD[0] if y < 10 else WOOD[1])
    for x, y in ((25, 13), (29, 15), (36, 12), (40, 15), (33, 14)): o.put(x, y, WOOD[3])
    # string and a little spoon on the neck
    line(o, 20, 21, 45, 21, SAND[3]); line(o, 46, 21, 50, 30, SAND[3])
    sp = m_ell(51, 34, 3, 4); bevel(o, sp, STONE); line(o, 50, 29, 51, 30, STONE[2])
    v = p.over   # mist sneaking out
    path(v, [(40, 8), (43, 5), (46, 6), (47, 3), (50, 2)], SNOW[1], 2); v.put(43, 5, CREAM); v.put(47, 3, CREAM)
    path(v, [(18, 9), (16, 6), (18, 3)], SNOW[1], 1)
    return p

def cave_echo_shell(rnd):
    p = Pic((30, 56, 19)); o = p.obj
    # a whelk lying on its side: pointed spire up-left, round body, flared pink mouth lower-right
    body = m_poly([(8, 12), (22, 18), (36, 22), (46, 30), (48, 42), (40, 51), (26, 52), (18, 46), (13, 34), (9, 22)])
    bevel(o, body, SAND, d=(1, 1), cuts=(.12, .34, .66, .86))
    for k, (cx, cy, rr) in enumerate(((11, 15, 4), (16, 22, 7), (24, 31, 13))):   # whorl seams
        for i in range(40):
            a = math.radians(-20 + i * 3.2)
            x, y = int(round(cx + rr * math.cos(a) * .7)), int(round(cy + rr * math.sin(a) * 1.1))
            if (x, y) in body: o.put(x, y, SAND[4]); o.put(x - 1, y - 1, SAND[0]) if (x - 1, y - 1) in body else None
    for band in (0, 1, 2):   # brown spotted bands on the body
        for i in range(30):
            a = math.radians(-60 + i * 5)
            x = int(round(26 + (12 + band * 5) * math.cos(a) * .9)); y = int(round(34 + (10 + band * 4) * math.sin(a)))
            if (x, y) in body and i % 4 != 0: o.put(x, y, LITTER[3]); o.put(x, y + 1, LITTER[2]) if (x, y + 1) in body else None
    for kx, ky in ((22, 19), (30, 21), (38, 25), (16, 15)):   # knobs on the shoulder
        sphere(o, kx, ky, 2.5, 2, SAND, rim=False)
    lip = m_ell(41, 42, 10, 9); bevel(o, lip, CORAL)
    fill(o, m_ell(42, 43, 7, 6), CORAL[3]); fill(o, m_ell(43, 44, 5, 4), PETAL[4]); fill(o, m_ell(44, 45, 3, 2), INK)
    o.put(36, 37, CREAM); o.put(37, 36, CREAM); o.put(12, 20, CREAM); o.put(13, 19, CREAM)
    v = p.over
    for i, rr in enumerate((5, 9, 13)):
        for j in range(-35, 36, 4 if i else 6):
            a = math.radians(j); x = 47 + rr * math.cos(a); y = 44 + rr * math.sin(a)
            if x < 63: v.put(int(x), int(y), SEA[1]); v.put(int(x), int(y) + 1, SEA[2])
    return p

def bell_shell(rnd):
    p = Pic((32, 57, 17)); o = p.obj
    pts_l, pts_r = [], []
    for y in range(15, 48):
        u = (y - 15) / 33; w = 5 + 13 * u ** 1.5 + (2 if y > 44 else 0)
        pts_l.append((32 - w, y)); pts_r.append((32 + w, y))
    bell = m_poly(pts_l + pts_r[::-1]) | m_ell(32, 16, 6, 4) | m_ell(32, 47, 20, 4)
    bevel(o, bell, PETAL if False else CORAL, d=(1, 0), cuts=(.12, .35, .68, .9))
    for k in range(-4, 5):   # scallop ridges fanning from the crown
        line(o, 32 + k * 1.3, 15, 32 + k * 4.4, 47, CORAL[3] if k > 0 else CORAL[2])
    for x, y in m_ell(32, 47, 20, 4):
        if y >= 47: o.put(x, y, CORAL[3])
    fill(o, m_ell(32, 47, 17, 2), PETAL[4])   # the bell's mouth
    for x in range(14, 51, 3): o.put(x, 45, CORAL[1])  # scalloped rim
    line(o, 32, 47, 32, 50, SAND[3])
    sphere(o, 32, 52, 3, 3, SNOW)              # pearl clapper
    # hanging loop
    for i in range(30):
        a = i / 30 * 2 * math.pi; o.put(int(round(32 + 3 * math.cos(a))), int(round(9 + 3.5 * math.sin(a))), SAND[3])
    o.put(26, 22, CREAM); o.put(26, 23, CREAM); o.put(25, 26, CREAM)
    v = p.over
    for s in (-1, 1):   # ring-a-ling marks
        for rr in (23, 27):
            for j in range(-25, 26, 7):
                a = math.radians(j); v.put(int(32 + s * rr * math.cos(a)), int(30 + rr * math.sin(a) * .9), GOLD[2])
    return p

def beach_ball(rnd):
    p = Pic((32, 57, 17)); o = p.obj
    cx, cy, r = 32, 36, 18; pole = (38, 23)
    rams = [EMBER, SNOW, GOLD, SEA, SNOW, EMBER, SNOW, GOLD]
    M = set()
    for y in range(cy - r - 1, cy + r + 2):
        for x in range(cx - r - 1, cx + r + 2):
            nx, ny = (x + .5 - cx) / r, (y + .5 - cy) / r
            if nx * nx + ny * ny > 1: continue
            M.add((x, y)); a = math.atan2(y + .5 - pole[1], x + .5 - pole[0])
            seg = int(((a + math.pi) / (2 * math.pi) * 8 + .3)) % 8
            t = tone5(shade_pt(nx, ny)); rm = rams[seg]
            o.put(x, y, rm[max(0, min(4, t if rm is not SNOW else min(4, t + (1 if t < 3 else 0))))])
    for x, y in edge_of(M):
        if (x - cx) + (y - cy) > 4: o.put(x, y, darker_px(o.get(x, y)))
    sphere(o, pole[0], pole[1], 3, 2.5, GOLD, rim=False)
    # it is delighted: happy closed eyes, open grin, blush
    for x, y in ((24, 37), (25, 36), (26, 37), (34, 37), (35, 36), (36, 37)): o.put(x, y, INK)
    mouth = m_ell(30, 42, 3, 2) - m_rect(26, 38, 35, 42)
    fill(o, m_rect(27, 41, 34, 42), INK); fill(o, mouth, INK); o.put(30, 43, EMBER[1]); o.put(29, 43, EMBER[1])
    for x, y in ((21, 40), (22, 40), (38, 40), (39, 40)): o.put(x, y, BLUSH)
    o.put(24, 25, CREAM); o.put(25, 24, CREAM); o.put(23, 27, CREAM)
    # a bit of palm frond still stuck on top
    fr = m_poly([(14, 22), (20, 16), (30, 13), (24, 18)]); bevel(o, fr, LEAF)
    for i in range(5): line(o, 17 + i * 3, 19 - i, 16 + i * 3, 15 - i, LEAF[2])
    line(o, 15, 21, 29, 14, LEAF[3])
    v = p.over; sparkle(v, 54, 14, CREAM, big=True); sparkle(v, 9, 34, GOLD[0]); v.put(56, 30, CREAM)
    return p

def darker_px(c):
    for rm in (EMBER, SNOW, GOLD, SEA):
        if c in rm: return rm[min(4, rm.index(c) + 1)]
    return c

def lagoon_glass_bead(rnd):
    p = Pic((32, 56, 15)); o = p.obj
    # string loop over the top
    for i in range(70):
        a = math.pi + i / 70 * math.pi
        x, y = 32 + 9 * math.cos(a), 16 + 11 * math.sin(a)
        o.put(int(round(x)), int(round(y)), SAND[3]); o.put(int(round(x)) + 1, int(round(y)), SAND[2])
    M = sphere(o, 32, 35, 17, 17, SEA, rim=True)
    for x, y in M:   # frosted sea-glass: soften toward the middle
        d = math.hypot(x + .5 - 32, y + .5 - 35) / 17
        if d < .55 and o.get(x, y) in (SEA[2], SEA[3]): o.put(x, y, SEA[1] if (x + y) % 2 else SEA[2])
    fill(o, m_ell(32, 18, 3, 1), SEA[4]); line(o, 32, 16, 32, 18, SAND[3])
    fill(o, m_ell(32, 52, 2, 1), SEA[4])
    # the striped minnow remembered inside
    fb = m_ell(31, 36, 8, 3); fill(o, fb, SEA[3])
    for x, y in fb:
        if y <= 34: o.put(x, y, SEA[2])
    for x in (27, 30, 33): line(o, x, 34, x, 38, SEA[4])
    fill(o, m_poly([(38, 36), (43, 32), (43, 40)]), SEA[3]); o.put(25, 35, CREAM)
    # big glint
    for x, y in ((22, 25), (23, 24), (24, 23), (25, 22), (21, 27), (21, 28)): o.put(x, y, CREAM)
    o.put(27, 22, SEA[0]); o.put(40, 46, SEA[0]); o.put(41, 45, SEA[0])
    v = p.over; sparkle(v, 51, 22, CREAM, big=True); sparkle(v, 12, 44, SEA[0])
    return p

def aurora_ribbon(rnd):
    p = Pic((32, 58, 14)); o = p.obj
    # a waving curtain of green light: bright crest, streaky rays hanging down, a ribbon-fold at each end
    for x in range(6, 59):
        u = (x - 6) / 52
        yc = 22 + 9 * math.sin(u * 2 * math.pi * 1.05 + .3)
        L = 16 + 6 * math.sin(u * 9.0) + (3 if x % 3 == 0 else 0) - (4 if x % 7 == 3 else 0)
        y0, y1 = int(round(yc)), int(round(yc + L))
        rm = [mix(MOSS[i], SEA[i], max(0, (u - .55) / .45) * .8) for i in range(5)]
        for y in range(y0, y1 + 1):
            v = (y - y0) / max(1, y1 - y0)
            k = 0 if v < .12 else 1 if v < .38 else 2 if v < .7 else 3
            if x % 4 == 1 and v > .2: k = min(4, k + 1)       # curtain streaks
            if x % 4 == 3 and v < .8: k = max(0, k - 1)
            o.put(x, y, rm[k])
        o.put(x, y0, CREAM if x % 5 else rm[0])
        if x % 5 == 2: o.put(x, y1 + 1, rm[2]); o.put(x, y1 + 2, rm[3])
    for x in range(6, 59):   # violet fringe at the very bottom
        pass
    v = p.over
    for x, y, b in ((12, 9, True), (50, 52, False), (44, 6, False), (16, 50, False), (57, 12, True), (30, 4, False)):
        sparkle(v, x, y, CREAM, big=b)
    return p

def frost_window_pane(rnd):
    p = Pic((32, 57, 18)); o = p.obj
    pts = [(14, 14), (40, 9), (50, 17), (49, 47), (22, 52), (11, 41)]
    back = m_poly([(x + 3, y + 3) for x, y in pts]); fill(o, back, ICE[4])
    face = m_poly(pts); bevel(o, face, [ICE[0], ICE[0], ICE[1], ICE[1], ICE[2]])
    for x, y in edge_of(face): o.put(x, y, CREAM if x + y < 60 else ICE[2])
    rnd2 = random.Random(7)
    def curl(cx, cy, r, turns, dirn):
        for i in range(90):
            t = i / 90; a = dirn * t * turns * 2 * math.pi; rr = r * (1 - t)
            x, y = int(round(cx + rr * math.cos(a))), int(round(cy + rr * math.sin(a)))
            if (x, y) in face: o.put(x, y, ICE[3] if t < .25 else ICE[2])
    curl(24, 26, 7, 1.2, 1); curl(38, 37, 8, 1.3, -1); curl(27, 43, 4, 1, 1); curl(42, 20, 4, 1, -1)
    for sx, sy, a in ((12, 41, -.6), (49, 46, -2.5), (40, 10, 1.9)):   # fern frost growing in from the corners
        for i in range(10):
            x, y = sx + math.cos(a) * i, sy + math.sin(a) * i
            if (int(x), int(y)) in face: o.put(int(x), int(y), CREAM)
            if i % 3 == 1:
                for s in (1, -1):
                    x2, y2 = x + math.cos(a + s * .9) * 3, y + math.sin(a + s * .9) * 3
                    line_in(o, face, x, y, x2, y2, CREAM)
    for x, y in ((17, 18), (18, 17), (19, 16), (17, 19)): o.put(x, y, CREAM)
    v = p.over; sparkle(v, 54, 10, CREAM, big=True); sparkle(v, 8, 26, ICE[0])
    return p

def line_in(cv, M, x0, y0, x1, y1, c):
    n = int(max(abs(x1 - x0), abs(y1 - y0), 1))
    for i in range(n + 1):
        x, y = int(round(x0 + (x1 - x0) * i / n)), int(round(y0 + (y1 - y0) * i / n))
        if (x, y) in M: cv.put(x, y, c)

def squeaky_ice_chip(rnd):
    p = Pic((32, 57, 17)); o = p.obj
    rim = [(16, 32), (25, 19), (41, 17), (49, 30), (46, 48), (27, 53), (14, 45)]
    c0 = (30, 33)
    tones = [0, 0, 1, 3, 4, 3, 2]
    for i in range(len(rim)):
        a, b = rim[i], rim[(i + 1) % len(rim)]
        fill(o, m_poly([c0, a, b]), ICE[tones[i]])
    # facet seams
    for x, y in rim: line(o, c0[0], c0[1], x, y, ICE[0] if x + y < 60 else ICE[3])
    top = m_poly([(25, 22), (39, 20), (44, 29), (33, 30), (22, 30)]); fill(o, top, SNOW[0])
    for x, y in edge_of(top): o.put(x, y, ICE[1])
    # it squeaks: wide-eyed, mouth open
    for x, y in ((25, 36), (25, 37), (35, 35), (35, 36)): o.put(x, y, INK)
    line(o, 23, 33, 26, 34, INK); line(o, 34, 32, 37, 33, INK)
    fill(o, m_ell(30, 42, 2, 3), INK); o.put(30, 44, EMBER[1])
    o.put(19, 34, CREAM); o.put(20, 33, CREAM)
    v = p.over
    for x0, y0, x1, y1 in ((51, 16, 55, 12), (53, 22, 58, 21), (47, 11, 48, 6)): line(v, x0, y0, x1, y1, INK)
    for x0, y0, x1, y1 in ((12, 22, 9, 19), (10, 28, 6, 28)): line(v, x0, y0, x1, y1, INK)
    return p

def stargazers_chalk(rnd):
    p = Pic((32, 57, 22)); o = p.obj
    stone = m_ell(32, 47, 24, 8) | m_ell(28, 44, 18, 7); bevel(o, stone, SLATE, d=(1, 1), cuts=(.1, .3, .62, .85))
    st = m_poly(star_pts(19, 46, 5, 2.2));
    for x, y in edge_of(st): o.put(x, y, CHALK[1])
    for x, y in ((27, 50), (26, 41)): sparkle(o, x, y, CHALK[2])
    # the chalk stub standing on its stone, top worn slanted
    stub = m_poly([(34, 20), (44, 16), (44, 46), (34, 46)]) | m_ell(39, 46, 5, 2)
    for x, y in stub:
        u = (x - 34) / 10; k = 0 if u < .2 else 1 if u < .5 else 2 if u < .8 else 3
        o.put(x, y, CHALK[k])
    top = m_poly([(34, 20), (44, 16), (44, 18), (35, 22)]); fill(o, top, CHALK[0])
    for x, y in ((37, 26), (41, 31), (36, 38), (42, 40)): o.put(x, y, CHALK[2])
    for x in range(34, 45): o.put(x, 45 + (1 if 36 < x < 43 else 0), CHALK[3])
    # chalk dust
    for x, y in ((47, 44), (49, 46), (31, 43), (46, 41)): o.put(x, y, CHALK[2])
    v = p.over; sparkle(v, 18, 10, CREAM, big=True); sparkle(v, 54, 8, GOLD[0]); v.put(10, 22, CREAM); v.put(27, 6, GOLD[0])
    return p

def sauna_bun(rnd):
    p = Pic((32, 57, 24)); o = p.obj
    towel = m_ell(32, 47, 25, 8) | m_poly([(8, 46), (5, 32), (16, 41)]) | m_poly([(56, 46), (60, 34), (48, 41)])
    for x, y in towel:
        k = 1 if y < 44 else 2 if y < 51 else 3
        o.put(x, y, SNOW[k])
        if (x + 2 * (y // 6)) % 12 in (0, 1): o.put(x, y, SEA[k] if k < 3 else SEA[3])
    for x in range(10, 55, 6): line(o, x, 51, x + 2, 54, SNOW[3])
    # the bun: a cardamom knot
    sphere(o, 32, 34, 16, 12, BREAD, rnd, .05)
    for i in range(110):
        t = i / 110; a = t * 2.4 * 2 * math.pi; rr = 1.5 + 11 * t
        x, y = 32 + rr * math.cos(a), 33 + rr * .62 * math.sin(a)
        if (x - 32) ** 2 / 256 + (y - 34) ** 2 / 144 < .85: o.put(int(round(x)), int(round(y)), BREAD[3])
    for x, y in ((24, 28), (29, 25), (37, 27), (42, 32), (27, 34), (35, 37), (22, 36), (40, 40), (31, 30)):
        o.put(x, y, CREAM); o.put(x + 1, y, SNOW[2])
    o.put(23, 26, BREAD[0]); o.put(24, 25, BREAD[0])
    v = p.over
    for sx in (22, 32, 42):
        for i in range(12):
            v.put(int(sx + 2 * math.sin(i * .9 + sx)), 19 - i, CREAM if i % 4 else SNOW[1])
    return p

def mirror_salt_crystal(rnd):
    p = Pic((32, 58, 22)); o = p.obj
    cx, cy, rx, ry, th = 32, 29, 23, 13, 9
    hexp = [(cx + rx * math.cos(a), cy + ry * math.sin(a)) for a in [math.radians(30 + 60 * i) for i in range(6)]]
    low = [(x, y + th) for x, y in hexp]
    sides = m_poly([hexp[0], hexp[1], hexp[2], hexp[3], low[3], low[2], low[1], low[0]])
    for x, y in sides:
        k = 1 if x < cx - rx * .5 else 2 if x < cx + rx * .5 else 3
        if (y - int(cy)) % 3 == 0: k = min(4, k + 1) if x > cx else k
        o.put(x, y, SNOW[k])
    top = m_poly(hexp)
    for x, y in top:   # the sky, reflected
        u = (y - (cy - ry)) / (2 * ry); k = 0 if u < .3 else 1 if u < .7 else 2
        o.put(x, y, [ICE[0], SEA[0], SEA[1]][k])
    for x, y in edge_of(top): o.put(x, y, CREAM if y < cy or x < cx - 10 else SNOW[1])
    # a cloud, and a second fainter one (the sky shown twice)
    for ccx, ccy, s, cl in ((26, 25, 1, CREAM), (40, 34, .7, SNOW[1])):
        for dx, dy, r in ((-3, 1, 3), (0, -1, 3.5), (3, 1, 3), (6, 1.5, 2)):
            fill(o, m_ell(ccx + dx * s, ccy + dy * s, r * s, r * s * .7), cl)
    sphere(o, 41, 22, 2, 2, GOLD, rim=False); sphere(o, 22, 35, 1.5, 1.5, [GOLD[0]] * 3 + [GOLD[1]] * 2, rim=False)
    # a little cube of salt growing on the rim
    cube_t = m_poly([(10, 34), (15, 31), (20, 34), (15, 37)]); fill(o, cube_t, SNOW[0])
    fill(o, m_poly([(10, 34), (15, 37), (15, 43), (10, 40)]), SNOW[2]); fill(o, m_poly([(15, 37), (20, 34), (20, 40), (15, 43)]), SNOW[3])
    v = p.over; sparkle(v, 50, 12, CREAM, big=True); sparkle(v, 14, 14, CREAM)
    return p

def amber_seed(rnd):
    p = Pic((32, 57, 15)); o = p.obj
    M = m_ell(32, 35, 16, 19) | m_ell(32, 21, 10, 7)
    for x, y in M:
        nx, ny = (x + .5 - 32) / 16, (y + .5 - 33) / 20
        dd = math.sqrt(nx * nx + ny * ny); s = -(nx * -.5 + ny * -.6)
        k = 1 if dd < .45 else 2 if dd < .8 else 3
        if s > .45 and dd > .6: k = 4
        if s < -.35 and dd > .55: k = 1
        o.put(x, y, AMBER[k])
    seed = m_poly([(32, 27), (38, 33), (37, 42), (32, 46), (27, 42), (26, 33)]); bevel(o, seed, LITTER)
    line(o, 32, 29, 32, 44, LITTER[3])
    # tiny sleeping face on the seed
    o.put(29, 37, INK); o.put(30, 38, INK); o.put(34, 38, INK); o.put(35, 37, INK)
    # a curled sprout dreaming of spring
    path(o, [(32, 27), (31, 23), (33, 20), (35, 21), (34, 23)], MOSS[2])
    fill(o, m_poly([(31, 22), (26, 19), (28, 23)]), MOSS[1])
    for x, y in ((26, 46), (40, 28), (24, 30), (39, 46), (36, 50)): o.put(x, y, AMBER[0])   # trapped bubbles
    for x, y in ((22, 24), (22, 25), (23, 23), (21, 27), (21, 28), (24, 22)): o.put(x, y, CREAM)
    v = p.over; zz(v, 48, 12, 3); zz(v, 53, 6, 2); sparkle(v, 12, 44, AMBER[0])
    return p

def flamingo_feather(rnd):
    p = Pic((32, 57, 15)); o = p.obj
    P0, P1, P2 = (46, 54), (52, 26), (14, 8)
    def bz(t): return ((1 - t) ** 2 * P0[0] + 2 * (1 - t) * t * P1[0] + t * t * P2[0], (1 - t) ** 2 * P0[1] + 2 * (1 - t) * t * P1[1] + t * t * P2[1])
    L, Rr, spine = [], [], []
    for i in range(41):
        t = i / 40; x, y = bz(t); x2, y2 = bz(min(1, t + .01)); x1, y1 = bz(max(0, t - .01))
        tx, ty = x2 - x1, y2 - y1; n = math.hypot(tx, ty) or 1; nx, ny = -ty / n, tx / n
        w = 0 if t < .18 else 9 * math.sin(math.pi * min(1, (t - .18) / .84)) ** .6
        wl, wr = w * 1.05, w * .7
        L.append((x + nx * wl, y + ny * wl)); Rr.append((x - nx * wr, y - ny * wr)); spine.append((x, y))
    vane = m_poly(L + Rr[::-1])
    for gi, gt in ((14, 1), (27, -1)):   # splits in the vane
        sx, sy = spine[gi]; ex, ey = (L if gt > 0 else Rr)[gi + 3]
        vane -= m_line([(sx + (ex - sx) * .3, sy + (ey - sy) * .3), (ex + (ex - sx) * .3, ey + (ey - sy) * .3)], 1)
    bevel(o, vane, CORAL, d=(1, 1))
    for i in range(8, 38, 3):   # barbs
        sx, sy = spine[i]; lx, ly = L[min(40, i + 2)]; rx_, ry_ = Rr[min(40, i + 2)]
        line(o, sx, sy, sx + (lx - sx) * .8, sy + (ly - sy) * .8, CORAL[2]); line(o, sx, sy, sx + (rx_ - sx) * .8, sy + (ry_ - sy) * .8, CORAL[3])
    for x, y in vane:   # darker coral tip
        if x < 22 and y < 16: o.put(x, y, CORAL[3] if o.get(x, y) != CORAL[4] else CORAL[4])
    # downy fluff at the base
    for i in range(14):
        sx, sy = spine[rnd.randint(5, 9)]; a = rnd.uniform(0, 2 * math.pi); r = rnd.randint(3, 5)
        line(o, sx, sy, sx + r * math.cos(a), sy + r * math.sin(a), CORAL[0])
    path(o, [(int(x), int(y)) for x, y in spine[:40]], CREAM)
    for x, y in spine[:6]: o.put(int(x), int(y), WAX[2])
    return p

def taper(rnd):
    p = Pic((32, 57, 13)); o = p.obj; u = p.under
    for x, y in m_ell(31, 12, 8, 9): u.put(x, y, GOLD[0][:3] + (60,))
    dish = m_ell(32, 52, 12, 3) | m_ell(32, 50, 12, 3); bevel(o, dish, GOLD, d=(0, 1))
    fill(o, m_ell(32, 50, 9, 2), GOLD[2]); line(o, 44, 50, 49, 47, GOLD[3], 2); fill(o, m_ell(50, 46, 2, 2), GOLD[2])
    body = m_poly([(29, 51), (36, 51), (35, 18), (30, 18)])
    for x, y in body:
        w0 = 29 + (51 - y) * 1 / 33; w1 = 36 - (51 - y) * 1 / 33; uu = (x - w0) / max(1, w1 - w0)
        o.put(x, y, WAX[0 if uu < .25 else 1 if uu < .55 else 2 if uu < .8 else 3])
    for dx, dy, L in ((30, 19, 5), (34, 19, 3)):   # drips
        for j in range(L): o.put(dx, dy + j, WAX[0] if dx < 32 else WAX[2])
    fill(o, m_rect(30, 18, 35, 19), WAX[0])
    line(o, 32, 15, 32, 17, INK)
    # flame
    fl = m_ell(32, 12, 3, 4) | m_poly([(29, 11), (32, 3), (35, 11)])
    for x, y in fl: o.put(x, y, EMBER[1])
    for x, y in m_ell(32, 12, 2, 3) | m_poly([(31, 10), (32, 5), (33, 10)]): o.put(x, y, GOLD[1])
    fill(o, m_ell(32, 13, 1, 1), CREAM)
    # ceremonial ribbon bow
    for pts in ([(32, 36), (23, 31), (23, 39)], [(33, 36), (42, 31), (42, 39)]):
        bevel(o, m_poly(pts), EMBER)
    fill(o, m_poly([(31, 37), (27, 47), (30, 46)]), EMBER[2]); fill(o, m_poly([(34, 37), (38, 47), (35, 46)]), EMBER[3])
    fill(o, m_rect(30, 34, 35, 39), EMBER[1]); o.put(31, 35, EMBER[0])
    v = p.over; sparkle(v, 44, 8, GOLD[0]); sparkle(v, 20, 14, CREAM)
    return p

ITEMS = {
    "wishing-coin": wishing_coin, "giant-fern-spores": giant_fern_spores, "vine-twine": vine_twine,
    "giants-bark-curl": giants_bark_curl, "raindrop-bead": raindrop_bead, "lantern-fruit": lantern_fruit,
    "soup-mist-jar": soup_mist_jar, "cave-echo-shell": cave_echo_shell, "bell-shell": bell_shell,
    "beach-ball": beach_ball, "lagoon-glass-bead": lagoon_glass_bead, "aurora-ribbon": aurora_ribbon,
    "frost-window-pane": frost_window_pane, "squeaky-ice-chip": squeaky_ice_chip, "stargazers-chalk": stargazers_chalk,
    "sauna-bun": sauna_bun, "mirror-salt-crystal": mirror_salt_crystal, "amber-seed": amber_seed,
    "flamingo-feather": flamingo_feather, "taper": taper,
}

def main(sheet=None):
    ims = []
    for i, (slug, fn) in enumerate(ITEMS.items()):
        im = fn(random.Random(1000 + i)).render()
        im.save(os.path.join(OUT, slug + ".png")); ims.append(im)
    if sheet:
        cols = 5; sh = Image.new("RGBA", (cols * 68, ((len(ims) + cols - 1) // cols) * 68), (75, 62, 52, 255))
        for i, im in enumerate(ims): sh.alpha_composite(im, ((i % cols) * 68 + 2, (i // cols) * 68 + 2))
        sh.resize((sh.width * 4, sh.height * 4), Image.NEAREST).save(sheet)
    print("wrote", len(ims), "items")

if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else None)
