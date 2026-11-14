#!/usr/bin/env python3
"""Redraws of the 15 weak Trail Sights item pictures (todo.md, Josh 2026-11-14: "redraw all 15 weak Sights items").
Same method and look as the first drawings (tools/gen_sight_item_art_a.py .. _e.py, Hearth Pop v3): 64 x 64 RGBA, hard pixels,
5-tone ramps lit from the top-left, 1 px ink outline, flat two-tone ground shadow, bottom at y 57. The helpers and the
render / shadow step are those of gen_sight_item_art_e.py (imported, not copied), so the pictures match the other 89.
The old drawings of these 15 slugs are left in the a..e scripts but taken out of their ITEMS lists, so re-running an old
script never brings an old picture back.
Deterministic and re-runnable:  python3 tools/gen_sight_item_art_f.py [slug ...]   -> game/assets/img/ph/<slug>.png
Contact sheet (before / after):   python3 tools/gen_sight_item_art_f.py --sheet OUT.png"""
import math, os, random, sys, zlib
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import gen_sight_item_art_e as E  # noqa: E402
from gen_sight_item_art_e import (S, OUT, INK, CREAM, H, ramp, Cv, M, Mpoly, Mell, Mrect, Mrr, Mline, Mdots, union, minus, inter,  # noqa: E402,F401
                                  pix, shade, tint, px, sparkle, axis_poly, bezier, rot, note, heart,
                                  STONE, WOOD, GOLD, EMBER, LEAF, MOSS, SEA, DUSK, ICE, PETAL, SNOW, PINE, SAND,
                                  WOOL, PARCH, TOAST, BLUE, DEW, SILVER, SKIN, PEB, SLATE, SAGE, ROSE, DRIFT, PLANK, LEATHER, BR)

AMBER = ramp("#ffe9a8", "#ffc24a", "#e98a1e", "#b0561a", "#6e2f1c")
BRASS = ramp("#fff2b0", "#f2d36a", "#d2a23a", "#9a6a2a", "#5e3e22")
TEAL = ramp("#c8f4ec", "#7fd8cc", "#3fa8a8", "#2a7684", "#1f4a5e")
REDT = ramp("#ffb8a0", "#f2674e", "#c83a3a", "#8a2636", "#521a2c")
CONE = ramp("#e8b076", "#c27a44", "#94532e", "#663624", "#40221c")
GLOW = ramp("#f4fff0", "#c8ffd8", "#7ef0c0", "#3cc0a0", "#22807a")
LAV = ramp("#f1ecff", "#d9d0f6", "#b4a8e0", "#8678b8", "#584c84")
STRIPE = ramp("#d8ecff", "#a8cdf2", "#78a6dc", "#5078b0", "#34507e")


def face(cv, cx, cy, happy=True, laugh=False, cheeks=True, gap=4):
    """A small Hearth Pop face: two eyes and a smile (laugh = closed ^ ^ eyes, open mouth)."""
    if laugh:
        for ex in (cx - gap, cx + gap - 1):
            px(cv, [(ex - 1, cy + 1), (ex, cy), (ex + 1, cy + 1)], INK)
        px(cv, [(cx - 2, cy + 3), (cx - 1, cy + 3), (cx, cy + 3), (cx + 1, cy + 3), (cx - 1, cy + 4), (cx, cy + 4)], INK)
        cv.put(cx - 1, cy + 4, REDT[1]); cv.put(cx, cy + 4, REDT[1])
    else:
        for ex in (cx - gap, cx + gap - 1):
            px(cv, [(ex, cy), (ex, cy + 1)], INK)
        if happy: px(cv, [(cx - 2, cy + 3), (cx - 1, cy + 4), (cx, cy + 4), (cx + 1, cy + 3)], INK)
    if cheeks:
        for x in (cx - gap - 2, cx - gap - 1, cx + gap, cx + gap + 1): cv.put(x, cy + 2, PETAL[1])


# ------------------------------------------------------------------ 1 toffee: a thick glassy square, a bite out of one corner, on crinkled wax paper
def toffee(cv, rnd):
    paper = Mpoly([(4, 46), (22, 34), (60, 40), (44, 55)])
    shade(cv, paper, WOOL, "flat", rnd, .05)
    for x, y in ((10, 46), (18, 42), (30, 51), (46, 49), (54, 43)): cv.put(x, y, WOOL[3])     # crinkles
    T = ramp("#ffd98a", "#e8a040", "#b8682a", "#84421e", "#52281a")
    top = Mpoly([(10, 33), (30, 22), (54, 30), (34, 41)])
    side_f = Mpoly([(10, 33), (34, 41), (34, 52), (10, 44)])
    side_r = Mpoly([(34, 41), (54, 30), (54, 41), (34, 52)])
    bite = union(Mell(50, 32, 4, 4), Mell(53, 36, 4, 4))   # two tooth marks
    shade(cv, minus(side_f, bite), T, 2, rnd, .04)
    shade(cv, minus(side_r, bite), T, 3, rnd, .04)
    shade(cv, minus(top, bite), T, "flat", rnd, .03)
    # glassy: a bright streak across the top, light glowing through the front face
    px(cv, pix(inter(Mline([(15, 33), (30, 25)], 2), top)), T[0])
    px(cv, pix(inter(Mline([(26, 36), (42, 28)], 1), top)), T[1])
    for x in range(12, 33):
        y = round(35 + (x - 10) * 8 / 24)
        if (x // 3) % 2: cv.put(x, y + 3, T[1])
    px(cv, [(x, round(43 + (x - 10) * 8 / 24)) for x in range(11, 34)], T[3])
    # the bite: lighter broken faces, a sticky thread hanging off
    for m, sh in ((Mell(50, 32, 5, 5), T[1]), (Mell(53, 36, 5, 5), T[2])):
        for x, y in pix(inter(m, union(top, side_r))):
            if not bite.getpixel((x, y)): cv.put(x, y, sh)
    px(cv, [(56, 40), (57, 42), (57, 44), (56, 46), (56, 47)], T[1])
    # sugar crystals
    for x, y in ((20, 31), (26, 29), (33, 32), (24, 35), (40, 31), (44, 34)): cv.put(x, y, CREAM)

    def post(c):
        sparkle(c, 10, 22, CREAM, True); sparkle(c, 42, 16, CREAM)
    return post


# ------------------------------------------------------------------ 2 daisy-chain crown: a ring in 3/4 view, small daisies behind, big ones in front
def daisy(cv, cx, cy, r, dim=False):
    pet = WOOL if not dim else ramp("#efe8d8", "#e0d6c0", "#c8b89a", "#a8967a", "#7a6a58")
    for k in range(8):
        a = k * math.pi / 4 + .2
        shade(cv, Mell(cx + r * .7 * math.cos(a), cy + r * .62 * math.sin(a), r * .42, r * .42), pet, "ball", rim=False)
    shade(cv, Mell(cx, cy, r * .38 + .3, r * .34 + .3), GOLD, "ball", rim=False)


def daisy_chain_crown(cv, rnd):
    cx, cy, rx, ry = 32, 34, 23, 15
    band = minus(Mell(cx, cy, rx, ry), Mell(cx, cy - 1, rx - 4, ry - 4.5))
    shade(cv, band, LEAF, 3, rnd, .1)
    angs = [i * 2 * math.pi / 11 + .15 for i in range(11)]
    back = [a for a in angs if math.sin(a) < 0]; front = [a for a in angs if math.sin(a) >= 0]
    for a in sorted(back, key=math.sin, reverse=True):
        daisy(cv, cx + (rx - 2) * math.cos(a), cy + (ry - 2) * math.sin(a), 5.0, dim=True)
    # stems woven over the band in front
    for a in front:
        x, y = cx + (rx - 2) * math.cos(a), cy + (ry - 2) * math.sin(a)
        px(cv, pix(Mline([(x - 4, y + 1), (x + 4, y - 1)], 1)), LEAF[2])
    for a in sorted(front, key=math.sin):
        daisy(cv, cx + (rx - 2) * math.cos(a), cy + (ry - 2) * math.sin(a), 7.2)
    # a little ribbon tag: grandmother measured it twice
    shade(cv, Mpoly([(51, 40), (56, 46), (53, 47)]), PETAL, "ball")
    shade(cv, Mpoly([(51, 40), (49, 47), (52, 47)]), PETAL, "ball")

    def post(c):
        sparkle(c, 10, 20, CREAM, True); sparkle(c, 54, 18, CREAM)
    return post


# ------------------------------------------------------------------ 3 glowcap lantern repair kit: an open tin with a spare glass, wicks and a tiny screwdriver
def glowcap_repair_kit(cv, rnd):
    # the lid, open, standing behind
    lid = Mrr(10, 16, 54, 32, 3)
    shade(cv, lid, TEAL, 3, rnd, .04)
    px(cv, [(x, 18) for x in range(12, 53)], TEAL[2])
    shade(cv, Mrr(13, 20, 51, 30, 2), TEAL, 4, rim=False)
    # what is in the tin, sticking up: the spare glass, a coil of wick, a little bundle of wicks
    glass = union(Mrr(32, 18, 43, 36, 3), Mell(37.5, 18, 6, 2))
    shade(cv, glass, ICE, "cyl", rnd, 0)
    px(cv, [(34, y) for y in range(20, 34)], CREAM); px(cv, [(35, y) for y in range(22, 27)], CREAM)
    for k, x in enumerate((19, 22, 25)):
        shade(cv, Mrect(x, 24 - k, x + 2, 36), WOOL, "ball", rim=False); cv.put(x, 23 - k, INK); cv.put(x + 1, 23 - k, EMBER[1])
    body = Mrr(8, 33, 56, 53, 3)
    shade(cv, body, TEAL, "flat", rnd, .04)
    px(cv, [(x, 35) for x in range(10, 55)], TEAL[0]); px(cv, [(x, 50) for x in range(10, 55)], TEAL[3])
    # label: a glowing glowcap mushroom
    lab = Mrr(21, 38, 43, 49, 2); shade(cv, lab, PARCH, "flat")
    shade(cv, union(Mell(32, 42, 7, 3.6), Mrect(25, 42, 40, 43)), GLOW, "ball", rim=False)
    shade(cv, Mrect(30, 43, 34, 48), WOOL, 1, rim=False)
    for x, y in ((28, 41), (33, 40), (36, 42)): cv.put(x, y, CREAM)
    # the very small screwdriver lying across the front
    sd = Mpoly(axis_poly((10, 55), -.28, [(0, 2.4), (8, 2.4), (8.5, 1), (20, .9), (22, .4)]))
    hdl = Mpoly(axis_poly((10, 55), -.28, [(0, 4), (8.4, 4)]))
    shade(cv, inter(sd, hdl), REDT, "ball"); shade(cv, minus(sd, hdl), SILVER, "ball")

    def post(c):
        for x, y in ((23, 37), (41, 37), (32, 36), (20, 42), (44, 42)): c.put(x, y, GLOW[1])
        sparkle(c, 50, 6, GLOW[0], True); sparkle(c, 6, 20, CREAM)
    return post


# ------------------------------------------------------------------ 4 pine-snow cone: a real pine cone, snow on its shoulders, resin syrup running down
def pine_snow_cone(cv, rnd):
    cone = Mpoly([(32, 12), (44, 22), (47, 34), (42, 47), (32, 54), (22, 47), (17, 34), (20, 22)])
    shade(cv, cone, CONE, "ball", rnd, .03, box=(17, 12, 47, 54))
    # scales: rows of little pointed plates, darker gap under each
    for row, y in enumerate(range(18, 52, 5)):
        w = {18: 8, 23: 12, 28: 14, 33: 15, 38: 14, 43: 11, 48: 7}.get(y, 10)
        off = 0 if row % 2 == 0 else 3
        for x in range(32 - w + off, 32 + w, 6):
            sc = Mpoly([(x - 3, y), (x + 3, y), (x, y + 4)])
            sc = inter(sc, cone)
            shade(cv, sc, CONE, "ball", rim=False, box=(x - 3, y, x + 3, y + 4))
            for xx in range(x - 3, x + 4):
                if cv.get(xx, y - 1)[3]: cv.put(xx, y - 1, CONE[4])
    # snow on the top and the left shoulders
    snow = inter(union(Mell(31, 17, 11, 6), Mell(24, 25, 6, 3), Mell(38, 23, 6, 2.5)), cone)
    snow = union(snow, Mell(31, 14, 8, 4))
    shade(cv, snow, SNOW, "ball", rnd, .03)
    # resin syrup: amber drips
    for x0, y0, L in ((27, 22, 9), (36, 25, 13), (42, 30, 7), (31, 29, 6)):
        drip = union(Mline([(x0, y0), (x0, y0 + L)], 2), Mell(x0 + .5, y0 + L, 1.6, 1.8))
        shade(cv, drip, AMBER, "ball", rim=False)
        cv.put(x0, y0 + 1, AMBER[0])

    def post(c):
        sparkle(c, 50, 14, CREAM, True); sparkle(c, 13, 20, SNOW[0])
        for x, y in ((48, 30), (12, 40), (52, 44)): c.put(x, y, SNOW[1])
    return post


# ------------------------------------------------------------------ 5 barnacle giggle: a ridged little barnacle on a rock, laughing, its beak plates clicking open
def barnacle_giggle(cv, rnd):
    BARN = ramp("#fffaf0", "#eee2cc", "#d0bea0", "#a08a78", "#6c5a5e")
    rock = union(Mell(32, 48, 24, 8), Mell(20, 45, 9, 6))
    shade(cv, rock, SLATE, "ball", rnd, .08)
    for x, y in ((12, 44), (50, 46)):    # two tiny neighbours, not laughing
        shade(cv, Mpoly([(x - 4, y + 3), (x - 2, y - 3), (x + 2, y - 3), (x + 4, y + 3)]), BARN, "cyl")
        px(cv, [(x - 1, y - 3), (x, y - 3), (x + 1, y - 3)], DUSK[3])
    body = Mpoly([(14, 47), (20, 26), (25, 20), (39, 20), (44, 26), (50, 47)])
    shade(cv, body, BARN, "cyl", rnd, .05, box=(14, 18, 50, 48))
    # plates: wide ridged wedges with deep seams and a scalloped lower edge
    for x0, x1 in ((17, 21), (24, 27), (31, 33), (37, 40), (43, 47)):
        px(cv, [p for p in pix(Mline([(x0 + (x1 - x0) * .3 + (32 - x0) * .25, 22), (x0, 46)], 1)) if body.getpixel(p)], BARN[4])
        px(cv, [p for p in pix(Mline([(x0 + 1 + (x1 - x0) * .3 + (32 - x0) * .25, 22), (x0 + 1, 46)], 1)) if body.getpixel(p)], BARN[0])
    for y in (30, 37, 43):     # growth lines
        px(cv, [(x, y + round(.6 * math.sin(x))) for x in range(15, 50) if body.getpixel((x, y))], BARN[3])
    # the beak plates at the top, ajar: that is the click
    shade(cv, Mell(32, 20, 7.5, 2.6), DUSK, 4, rim=False)
    shade(cv, Mpoly([(25, 19), (31, 14), (32, 20)]), BARN, "ball"); shade(cv, Mpoly([(33, 14), (39, 19), (32, 20)]), BARN, "ball")
    shade(cv, Mrr(26, 28, 39, 37, 3), BARN, 1, rim=False)    # a smooth patch for the face
    face(cv, 32, 29, laugh=True, gap=4)

    def post(c):
        for x, y in ((22, 10), (21, 8), (42, 10), (43, 8), (32, 7), (32, 5)): c.put(x, y, INK)   # giggle marks
        for x, y in ((14, 22), (13, 24), (50, 22), (51, 24)): c.put(x, y, DUSK[2])
        sparkle(c, 56, 32, CREAM)
    return post


# ------------------------------------------------------------------ 6 pocket whistle: a brass whistle with a ribbon bow through its ring, a tune coming out
def pocket_whistle(cv, rnd):
    barrel = union(Mell(36, 38, 12, 10), Mrect(16, 30, 36, 46))
    shade(cv, barrel, BRASS, "hcyl", rnd, .03, box=(16, 28, 48, 48))
    mouth = Mrr(6, 31, 18, 40, 1)
    shade(cv, mouth, BRASS, "hcyl", box=(6, 30, 18, 41))
    px(cv, [(x, 33) for x in range(7, 17)], BRASS[0])
    shade(cv, Mrect(24, 28, 31, 32), ramp("#3a2a30", "#3a2a30", "#2b1c26", "#2b1c26", "#2b1c26"), 2, rim=False)   # the sound hole
    px(cv, [(x, 27) for x in range(23, 32)], BRASS[4])
    px(cv, pix(Mline([(20, 35), (40, 31)], 1)), BRASS[0])
    # ring and ribbon bow
    ring = minus(Mell(48, 30, 4, 4), Mell(48, 30, 2, 2)); shade(cv, ring, BRASS, "ball")
    for pts in ([(50, 30), (60, 24), (59, 34)], [(50, 31), (56, 41), (52, 42)], [(49, 31), (46, 43), (43, 41)]):
        shade(cv, Mpoly(pts), PETAL, "ball")
    shade(cv, Mell(50, 31, 2.5, 2.5), PETAL, "ball")

    def post(c):
        note(c, 6, 18, DUSK[2]); note(c, 14, 10, PETAL[2]); note(c, 22, 16, GOLD[2], flag=False)
        sparkle(c, 56, 12, CREAM, True)
    return post


# ------------------------------------------------------------------ 7 cave echo shell: a spiral whelk, pink mouth towards you, the cave breathing out of it
def cave_echo_shell(cv, rnd):
    body = union(Mpoly([(10, 22), (20, 14), (34, 16), (46, 26), (50, 40), (40, 52), (24, 50), (14, 38)]), Mell(30, 36, 17, 14))
    shade(cv, body, SAND, "ball", rnd, .04, box=(8, 12, 52, 54))
    # the spire: stacked whorls to the upper left
    for i, (x, y, r) in enumerate(((22, 18, 7), (16, 14, 4.5), (12, 11, 3), (9.5, 9, 1.8))):
        w = Mell(x, y, r, r * .8)
        shade(cv, w, SAND, "ball", rim=False)
        for xx, yy in pix(minus(Mell(x + .5, y + .7, r, r * .8), w)): cv.put(xx, yy, SAND[4])
    # growth bands curving round the body
    for k in range(4):
        a0 = 3.3 + k * .32
        pts = [(30 + (12 + k * 2) * math.cos(a0 + t / 10), 33 + (10 + k * 1.6) * math.sin(a0 + t / 10)) for t in range(0, 22)]
        px(cv, [p for p in pix(Mline(pts, 1)) if body.getpixel(p)], SAND[3])
    # knobs on the shoulder
    for x, y in ((28, 18), (35, 20), (41, 25)): shade(cv, Mell(x, y, 2, 2), SAND, "ball", rim=False)
    # the aperture: glossy pink lip around a dark cave
    lip = Mpoly(rot((40, 38), -.35, [(-6, -15), (2, -13), (9, -4), (9, 8), (4, 15), (-4, 13), (-7, 2)]))
    shade(cv, lip, ROSE, "ball", rnd, 0)
    cave = Mpoly(rot((41, 38), -.35, [(-2, -12), (2, -10), (5, -3), (5, 7), (2, 12), (-2, 9), (-3, 0)]))
    shade(cv, cave, ramp("#7a5a7a", "#5e4466", "#463454", "#322640", "#221a2e"), "flat", rim=False)
    px(cv, pix(Mline(rot((40, 38), -.35, [(-5, -12), (-6, 0)]), 1)), ROSE[0])
    # the tide inside, breathing
    px(cv, [(40, 41), (41, 40), (42, 41)], SEA[1]); px(cv, [(41, 45), (42, 44)], SEA[2])

    def post(c):
        for r in (4, 7):
            for t in range(-5, 6):
                a = t / 9
                c.put(round(52 + r * math.cos(a)), round(39 + r * 1.3 * math.sin(a)), SEA[1] if r == 4 else SEA[2])
        sparkle(c, 12, 34, CREAM)
    return post


# ------------------------------------------------------------------ 8 vine twine: a loose coil of springy green vine, three clear loops, leaves on it, one curly end
def vine_twine(cv, rnd):
    VINE = ramp("#c8ec8a", "#86cc5a", "#4c9a44", "#2e6a40", "#1d4436")
    loops = [(32, 40, 21, 11), (30, 36, 17, 9), (33, 32, 13, 7)]
    for cx, cy, rx, ry in loops:
        ring = minus(Mell(cx, cy, rx, ry), Mell(cx, cy - .3, rx - 2.6, ry - 2.6))
        shade(cv, ring, VINE, "ball", rnd, .04, box=(cx - rx, cy - ry, cx + rx, cy + ry))
        for t in range(0, 360, 16):   # twist: little diagonal ticks along the strand
            a = math.radians(t)
            x, y = cx + (rx - 1.3) * math.cos(a), cy + (ry - 1.3) * math.sin(a)
            cv.put(round(x), round(y), VINE[3])
    # the loose end, curling up and off
    end = bezier((52, 42), (60, 50), (58, 56), 10)
    px(cv, pix(Mline(end, 3)), VINE[2]); px(cv, pix(Mline(end[:-3], 1)), VINE[1])
    curl = minus(Mell(56, 56, 2.5, 2), Mell(55.5, 55.5, 1.2, .8)); px(cv, pix(curl), VINE[2])
    # leaves
    for O, ang in (((22, 29), -2.6), ((45, 31), -.25)):   # leaves on the top loop only (at the sides they read as legs)
        lf = Mpoly(axis_poly(O, ang, [(0, .5), (3, 2.8), (7, 2.8), (10, .3)]))
        shade(cv, lf, LEAF, "ball", rim=False)

    def post(c):
        note(c, 8, 18, LEAF[3]); sparkle(c, 30, 14, CREAM)
    return post


# ------------------------------------------------------------------ 9 amber seed: a seed asleep in a clear golden bead, on a string
def amber_seed(cv, rnd):
    px(cv, pix(Mline(bezier((4, 30), (14, 40), (17, 36), 10), 1)), WOOD[3])
    px(cv, pix(Mline(bezier((47, 36), (54, 46), (60, 40), 10), 1)), WOOD[3])
    bead = union(Mell(32, 36, 16, 15), Mell(32, 31, 13, 13))
    shade(cv, bead, AMBER, "ball", rnd, 0, box=(16, 17, 48, 51))
    # clear: lighter inside, glowing bottom-right rim (light passing through)
    for x, y in pix(inter(Mell(34, 38, 10, 9), bead)): cv.put(x, y, AMBER[1] if (x + y) % 7 else AMBER[2])
    for x, y in pix(minus(Mell(35, 39, 15, 13), Mell(33, 37, 15, 13))):
        if bead.getpixel((x, y)): cv.put(x, y, AMBER[0])
    # the seed, sleeping, with a curled sprout
    seed = Mpoly(axis_poly((28, 42), -1.1, [(0, .5), (3, 3.2), (8, 3.6), (12, .5)]))
    shade(cv, seed, COCOA_D, "ball", rim=False)
    px(cv, pix(Mline([(29, 41), (33, 32)], 1)), COCOA_D[0])
    sprout = bezier((33, 31), (37, 26), (33, 25), 6)
    px(cv, pix(Mline(sprout, 1)), LEAF[2]); cv.put(32, 25, LEAF[1]); cv.put(34, 26, LEAF[1])
    for x, y in ((29, 36), (31, 36), (29, 38), (30, 38), (31, 38)): pass
    # the string hole
    for x, y in ((16, 33), (47, 35)): shade(cv, Mell(x, y, 1.5, 1.5), AMBER, 4, rim=False)
    # highlight
    px(cv, pix(Mline([(21, 26), (26, 21)], 2)), CREAM); cv.put(22, 30, CREAM)

    def post(c):
        for x, y in ((47, 12), (48, 12), (49, 12), (49, 13), (48, 14), (47, 15), (48, 15), (49, 15)): c.put(x, y, DUSK[3])
        for x, y in ((53, 6), (54, 6), (54, 7), (53, 8), (54, 8)): c.put(x, y, DUSK[2])
        sparkle(c, 12, 18, CREAM, True)
    return post


COCOA_D = ramp("#c89a72", "#9a6a48", "#74482e", "#523022", "#34201a")


# ------------------------------------------------------------------ 10 white clover sprig: two fluffy white heads, pink at the base, three-leaf clovers with their pale V
def clover_head(cv, cx, cy, r, rnd):
    base = Mell(cx, cy + 1, r, r * .9)
    shade(cv, base, ramp("#ffffff", "#f6eef2", "#e6d0dc", "#c8a0b8", "#94708c"), "ball", rnd, .04)
    for k in range(18):   # florets: little upward petals all round
        a = rnd.uniform(0, 2 * math.pi); d = rnd.uniform(.25, .95) * r
        x, y = cx + d * math.cos(a), cy + d * math.sin(a) * .85
        c = WOOL[0] if y < cy else (PETAL[0] if y > cy + r * .45 else WOOL[1])
        px(cv, [(round(x), round(y)), (round(x), round(y) - 1)], c)
        cv.put(round(x) + 1, round(y), WOOL[3] if y > cy else WOOL[2])
    for x in range(int(cx - r * .7), int(cx + r * .7) + 1):   # drooping pink florets under the head
        if x % 2: px(cv, [(x, round(cy + r * .82)), (x, round(cy + r * .82) + 1)], PETAL[1])


def trefoil(cv, cx, cy, s):
    for a in (-math.pi / 2, math.pi / 6, 5 * math.pi / 6):
        lf = union(Mell(cx + s * .55 * math.cos(a - .25), cy + s * .55 * math.sin(a - .25), s * .42, s * .42),
                   Mell(cx + s * .55 * math.cos(a + .25), cy + s * .55 * math.sin(a + .25), s * .42, s * .42))
        shade(cv, lf, LEAF, "ball", rim=False)
        mx, my = cx + s * .5 * math.cos(a), cy + s * .5 * math.sin(a)   # the pale V on each leaflet
        px(cv, [(round(mx + s * .14 * math.cos(a + 1.3)), round(my + s * .14 * math.sin(a + 1.3))), (round(mx), round(my)),
                (round(mx + s * .14 * math.cos(a - 1.3)), round(my + s * .14 * math.sin(a - 1.3)))], LEAF[0])


def white_clover_sprig(cv, rnd):
    for pts in (((30, 56), (28, 40), (24, 22)), ((31, 56), (36, 42), (42, 30)), ((30, 56), (22, 50), (14, 44)), ((31, 56), (42, 52), (50, 46))):
        px(cv, pix(Mline(bezier(*pts, 10), 2)), LEAF[3]); px(cv, pix(Mline(bezier(*pts, 10), 1)), LEAF[2])
    trefoil(cv, 14, 43, 10); trefoil(cv, 50, 45, 10)
    clover_head(cv, 24, 18, 9, rnd); clover_head(cv, 42, 28, 7.5, rnd)

    def post(c):
        sparkle(c, 54, 12, CREAM, True); sparkle(c, 8, 24, CREAM)
    return post


# ------------------------------------------------------------------ 11 crab gavel: a bleached driftwood gavel on its block, the crab judge holding the handle
def crab_gavel(cv, rnd):
    block = Mell(26, 50, 18, 5); shade(cv, block, DRIFT, 3, rnd, .05)
    shade(cv, Mell(26, 47, 18, 5), DRIFT, "flat", rnd, .05)
    for x, y in pix(minus(Mell(26, 47, 12, 3), Mell(26, 47, 11, 2))): cv.put(x, y, DRIFT[3])   # rings of the wood
    handle = Mpoly(axis_poly((44, 45), -2.1, [(0, 2), (26, 1.6)]))
    shade(cv, handle, DRIFT, "ball", rnd, .05)
    hd = Mpoly(rot((30, 21), -.5, [(-12, -6), (12, -6), (12, 6), (-12, 6)]))
    shade(cv, hd, DRIFT, "ball", rnd, .07, box=(16, 10, 44, 32))
    for k in (-3, 0, 3):   # grain
        px(cv, [p for p in pix(Mline(rot((30, 21), -.5, [(-10, k), (10, k + 1)]), 1)) if hd.getpixel(p)], DRIFT[3])
    band = Mpoly(rot((30, 21), -.5, [(-2, -6.5), (2, -6.5), (2, 6.5), (-2, 6.5)])); shade(cv, band, LEATHER, "ball", rim=False)
    for end in (-12, 12):
        cap = Mpoly(rot((30, 21), -.5, [(end - 1.5, -6), (end + 1.5, -6), (end + 1.5, 6), (end - 1.5, 6)]))
        shade(cv, inter(cap, hd), DRIFT, 2, rim=False)
    # the crab judge, both claws on the handle
    crab = Mell(48, 50, 8, 5.5); shade(cv, crab, REDT, "ball", rnd, .03)
    for side in (-1, 1):
        for k in range(3): px(cv, pix(Mline([(48 + side * (6 + k), 52), (48 + side * (9 + k * 1.5), 55)], 1)), REDT[3])
    for x, y, r in ((43, 41, 3.2), (52, 39, 3.6)):
        shade(cv, minus(Mell(x, y, r, r), Mpoly([(x, y - r - 1), (x + r + 1, y - r - 1), (x + 1, y)])), REDT, "ball")
    px(cv, pix(Mline([(44, 46), (43, 43)], 1)) + pix(Mline([(52, 46), (52, 42)], 1)), REDT[2])
    for x in (45, 51): px(cv, [(x, 44), (x, 45)], REDT[3]); shade(cv, Mell(x, 43, 1.6, 1.6), WOOL, "ball", rim=False); cv.put(x, 43, INK)
    px(cv, [(46, 51), (47, 52), (48, 52), (49, 52), (50, 51)], INK)

    def post(c):
        for x, y in ((9, 32), (8, 30), (11, 28), (14, 36)): c.put(x, y, INK)    # the knock: order, order
        sparkle(c, 50, 10, CREAM, True)
    return post


# ------------------------------------------------------------------ 12 hush page: a curled cream page of very soft writing, a quill, and a hush bubble
def hush_page(cv, rnd):
    page = Mpoly([(12, 16), (46, 12), (50, 52), (16, 56)])
    shade(cv, Mpoly([(14, 18), (48, 14), (52, 54), (18, 58)]), PARCH, 4)      # the page under it
    shade(cv, page, PARCH, "flat", rnd, .03)
    curl = Mpoly([(50, 52), (40, 53), (46, 44)])
    shade(cv, curl, PARCH, 3, rim=False)
    px(cv, pix(Mline([(40, 53), (46, 44)], 1)), PARCH[4])
    # very soft writing: faint lavender lines, smaller and fainter down the page
    for i, y in enumerate(range(22, 48, 4)):
        L = 26 - (i % 3) * 5
        for x in range(17, 17 + L):
            if (x * 7 + i * 3) % 5: cv.put(x, round(y - (x - 12) * .1 + .3 * math.sin(x * .9)), LAV[2] if i < 3 else LAV[1])
    # the quill
    q = Mpoly(axis_poly((24, 52), -1.05, [(0, .4), (6, 1.4), (10, 3), (22, 3.6), (30, 2), (33, .3)]))
    shade(cv, q, WOOL, "ball", rnd, .03)
    px(cv, pix(Mline([(24, 52), (40, 24)], 1)), WOOL[3])
    # a hush bubble: shhh
    bub = union(Mell(48, 13, 10, 7), Mpoly([(41, 17), (40, 24), (46, 18)]))
    shade(cv, bub, LAV, "ball", rnd, 0)
    for x in (43, 48, 53): cv.put(x, 13, LAV[4]); cv.put(x + 1, 13, LAV[3])

    def post(c):
        sparkle(c, 8, 10, CREAM); sparkle(c, 58, 30, LAV[1])
    return post


# ------------------------------------------------------------------ 13 feather pillow: plump, pinched corners, curved ticking stripes, feathers drifting out
def feather(cv, O, ang, L):
    """A curved down feather: a quill with soft vanes, wider on one side."""
    segs = [(s, 3.6 * math.sin(math.pi * min(1, s / L)) ** .6 + .2) for s in range(0, L + 1, 1)]
    shade(cv, Mpoly(axis_poly(O, ang, segs)), WOOL, "ball", rim=False)
    tip = (O[0] + L * math.cos(ang), O[1] + L * math.sin(ang))
    px(cv, pix(Mline([(O[0] - 2 * math.cos(ang), O[1] - 2 * math.sin(ang)), tip], 1)), WOOL[3])
    for k in range(3, L - 2, 3):    # vane notches
        x, y = O[0] + k * math.cos(ang), O[1] + k * math.sin(ang)
        cv.put(round(x - 3 * math.sin(ang)), round(y + 3 * math.cos(ang)), (0, 0, 0, 0))


def feather_pillow(cv, rnd):
    pts = [(8, 30), (14, 27), (32, 25), (50, 27), (57, 24), (55, 38), (57, 53), (50, 50), (32, 53), (14, 50), (7, 53), (10, 40)]
    pil = Mpoly(pts)
    pil = union(pil, Mell(32, 39, 23, 13))

    def stripes(x, y):
        k = int((x + 3 * math.sin((y - 25) / 9) - 6) / 5) % 3
        return STRIPE if k == 0 else WOOL
    shade(cv, pil, stripes, "ball", rnd, .02, box=(7, 24, 57, 54))
    for x, y in ((9, 30), (56, 25), (56, 52), (8, 52)):          # pinched corners: little ties
        shade(cv, Mell(x, y, 2, 2), PETAL, "ball", rim=False)
    px(cv, pix(Mline(bezier((14, 50), (32, 47), (50, 50), 12), 1)), WOOL[3])   # the seam
    for x, y in ((24, 32), (25, 31), (26, 31)): cv.put(x, y, CREAM)

    def post(c):
        feather(c, (38, 24), -1.25, 16); feather(c, (12, 20), -.6, 12); feather(c, (48, 12), .3, 10)
    return post


# ------------------------------------------------------------------ 14 scree xylophone: seven flat scree stones laid over two wooden rails, a mallet beside
def scree_xylophone(cv, rnd):
    rail_t = Mpoly(axis_poly((6, 34), -.18, [(0, 1.8), (50, 1.8)]))
    rail_b = Mpoly(axis_poly((10, 50), -.18, [(0, 1.8), (46, 1.8)]))
    for r in (rail_t, rail_b): shade(cv, r, WOOD, "ball", rnd, .05)
    tones = [SLATE, PEB, STONE, SAGE, SLATE, ROSE, PEB]
    for i in range(7):
        x = 10 + i * 6.6
        top = 34 - (x - 6) * .18 + (i * 1.2) - 4; bot = 50 - (x - 10) * .18 - (i * 1.0) + 4
        w = 2.6 + (6 - i) * .12
        st = Mpoly([(x - w, top + rnd.uniform(-1, 1)), (x + w, top + rnd.uniform(-1, 1)), (x + w + .6, bot), (x - w - .4, bot + rnd.uniform(-1, 1))])
        shade(cv, st, tones[i], "flat", rnd, .1)
        px(cv, [(round(x - w + 1), round(top + 2)), (round(x - w + 1), round(top + 3))], tones[i][0])
    # strings tying each stone down
    for r_y0, r_x0, L in ((34, 6, 50), (50, 10, 46)):
        for x in range(r_x0, r_x0 + L):
            y = round(r_y0 - (x - r_x0) * .18)
            if x % 7 == 3: cv.put(x, y, WOOL[1])
    # the mallet: a little stick with a round felt head
    m = Mpoly(axis_poly((44, 56), -.9, [(0, 1), (16, 1)]))
    shade(cv, m, WOOD, "ball")
    shade(cv, Mell(54, 43, 3.5, 3.5), REDT, "ball")

    def post(c):
        for x, y in ((14, 18), (15, 17), (22, 14), (40, 12), (41, 11), (48, 16)): c.put(x, y, INK)    # tick, tock, chatter
        sparkle(c, 56, 24, CREAM)
    return post


# ------------------------------------------------------------------ 15 bridgewarden's badge: a round gold medal with an arched bridge over water, on a ribbon
def bridgewardens_badge(cv, rnd):
    for pts, R in (([(20, 6), (31, 6), (34, 26), (26, 30)], BLUE), ([(33, 6), (44, 6), (38, 30), (30, 26)], GOLD)):
        shade(cv, Mpoly(pts), R, "flat", rnd, .03)
    for x in range(21, 31, 3): px(cv, [(x, 7), (x + 1, 8)], BLUE[0])
    shade(cv, Mrr(18, 3, 46, 9, 2), BLUE, 2, rim=False)
    for x in range(20, 45, 4): cv.put(x, 5, CREAM)
    rim = Mell(32, 40, 16, 16)
    shade(cv, rim, GOLD, "ball", rnd, .02)
    disc = Mell(32, 40, 12, 12)
    shade(cv, disc, ramp("#ffe9a0", "#f5c84e", "#e0a030", "#b8782a", "#8f4a1f"), "flat")
    for k in range(24):    # milled edge
        a = k * math.pi / 12
        cv.put(round(32 + 14.2 * math.cos(a)), round(40 + 14.2 * math.sin(a)), GOLD[3])
    # the bridge: one bold stone arch over blue water, a railing on top
    water = inter(Mrect(18, 45, 46, 54), disc); shade(cv, water, SEA, "flat")
    for x in range(21, 44, 4): cv.put(x, 49, SEA[0]); cv.put(x + 1, 49, SEA[0])
    arch = inter(minus(Mrect(18, 36, 47, 46), Mell(32.5, 47, 8.5, 7)), disc)
    shade(cv, arch, STONE, "ball", rim=False, box=(18, 36, 47, 46))
    under = inter(minus(Mell(32.5, 47, 8.5, 7), Mrect(18, 45, 47, 54)), disc)
    shade(cv, under, ramp("#6a6488", "#56506e", "#443e5c", "#342f48", "#262238"), 2, rim=False)
    for x, y in ((21, 41), (26, 38), (40, 39), (44, 42)): cv.put(x, y, STONE[3]); cv.put(x + 1, y, STONE[3])
    px(cv, [(x, 36) for x in range(19, 47)], STONE[3])
    for x in range(20, 46, 4): px(cv, [(x, 32), (x, 33), (x, 34), (x, 35)], WOOD[3])
    px(cv, [(x, 32) for x in range(19, 47) if disc.getpixel((x, 32))], WOOD[2])
    px(cv, pix(Mline([(23, 30), (26, 28)], 1)), CREAM)

    def post(c):
        sparkle(c, 54, 30, CREAM, True); sparkle(c, 10, 40, CREAM); sparkle(c, 52, 54, GOLD[0])
    return post


ITEMS = {
    "toffee": toffee, "daisy-chain-crown": daisy_chain_crown, "glowcap-repair-kit": glowcap_repair_kit,
    "pine-snow-cone": pine_snow_cone, "barnacle-giggle": barnacle_giggle, "pocket-whistle": pocket_whistle,
    "cave-echo-shell": cave_echo_shell, "vine-twine": vine_twine, "amber-seed": amber_seed,
    "white-clover-sprig": white_clover_sprig, "crab-gavel": crab_gavel, "hush-page": hush_page,
    "feather-pillow": feather_pillow, "scree-xylophone": scree_xylophone, "bridgewardens-badge": bridgewardens_badge,
}


def render(slug):
    E.ITEMS = ITEMS   # E.render looks the slug up in its module's ITEMS
    return E.render(slug)


def sheet(path, before_dir=None):
    Z, W = 4, 5
    rows = (len(ITEMS) + W - 1) // W
    pair = 2 if before_dir else 1
    out = Image.new("RGBA", (W * 64 * Z * pair + (W - 1) * 8, rows * (64 * Z + 16)), (232, 232, 238, 255)); d = ImageDraw.Draw(out)
    for i, slug in enumerate(ITEMS):
        x = (i % W) * (64 * Z * pair + 8); y = (i // W) * (64 * Z + 16)
        if before_dir:
            out.alpha_composite(Image.open(os.path.join(before_dir, slug + ".png")).convert("RGBA").resize((64 * Z, 64 * Z), Image.NEAREST), (x, y + 16))
            x2 = x + 64 * Z
        else: x2 = x
        out.alpha_composite(render(slug).resize((64 * Z, 64 * Z), Image.NEAREST), (x2, y + 16)); d.text((x + 4, y + 2), slug, fill=(0, 0, 0, 255))
    out.save(path)


def main():
    args = sys.argv[1:]
    if args and args[0] == "--sheet":
        sheet(args[1], args[2] if len(args) > 2 else None); return
    os.makedirs(OUT, exist_ok=True)
    slugs = args or list(ITEMS)
    for slug in slugs:
        render(slug).save(os.path.join(OUT, slug + ".png"))
    print(f"wrote {len(slugs)} item pictures to {OUT}")


if __name__ == "__main__":
    main()
