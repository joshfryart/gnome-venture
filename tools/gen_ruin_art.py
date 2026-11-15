#!/usr/bin/env python3
"""Ruin pictures for the havens / wonders / delves (the 'before' of a repair). 480x270, hard pixels.

  python3 -I tools/gen_ruin_art.py [slug ...] [--out DIR]

Reads game/assets/img/wonders/<kind>-<slug>.png (the repaired look, untouched) and writes <kind>-<slug>.png
into DIR (default aseprite-source/v3/wonders/ruin/png). tools/ruin_to_aseprite.sh makes the .aseprite files.
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ruin_lib import Pic, hx, INK

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'game/assets/img/wonders')

DUSK = hx('#6a6488')      # overcast tint
MOSS = [hx('#5f7a3a'), hx('#47612f'), hx('#7a9446')]
DEADLEAF = [hx('#8a7340'), hx('#6b5a34'), hx('#a08a50')]
VOID = hx('#3a2c34')       # dark inside of a hole
VOID2 = hx('#241a28')


def dim_lights(p, box, thresh=200):
    """lit lamps / glows -> cold dark versions"""
    def f(r, g, b):
        if r > thresh and g > 150 and b < 190:
            return (0x4a, 0x3c, 0x40)
        if r > 230 and g > 200:
            return (0x6a, 0x58, 0x58)
        return None
    p.recolor(box, f)


def driftwood_tavern(p):
    # lamp post + the four lanterns go dark (before the recolour: original warm yellows)
    def lamp(r, g, b):
        if r > 200 and g > 120 and b < 175:
            return (0x6a, 0x52, 0x4c) if g < 200 else (0x84, 0x6e, 0x62)
        return None
    for (cx, cy, r) in ((239, 118, 8), (303, 144, 6), (334, 144, 6), (381, 144, 6), (418, 144, 6)):
        def circ(rr, gg, bb, cx=cx, cy=cy, r=r):
            return None
        for yy in range(cy - r, cy + r + 1):
            for xx in range(cx - r, cx + r + 1):
                if (xx - cx) ** 2 + (yy - cy) ** 2 <= r * r:
                    p.recolor((xx, yy, xx, yy), lamp)
    p.remap(sat=0.55, val=0.86, tint=DUSK)
    # crab leaves: paint wall back over the crab, then add a knocked-over cup
    wall = [p.sample(300, 143), p.sample(345, 150)]
    plank = [p.sample(300, 152), p.sample(304, 152), p.sample(309, 152)]
    p.patch((324, 124, 388, 184), lambda x, y: True,
            lambda x, y: plank[(x // 4) % 3])
    # shelf bar line stays: redraw it
    p.rect(288, 148, 430, 149, p.sample(300, 148))
    before = p.snapshot()
    # roof: the pink shell is gone, a ragged hole shows the dark inside, thatch hangs
    p.poly([(338, 76), (352, 70), (366, 76), (370, 90), (360, 98), (344, 98), (336, 88)], VOID)
    p.poly([(346, 80), (358, 78), (362, 88), (352, 93), (344, 88)], VOID2)
    for i in range(8):
        p.dot(338 + i * 4, 98 + (i % 3), hx('#b59a50'))
    p.poly([(300, 80), (312, 82), (310, 92), (300, 94)], VOID)           # second hole, left
    p.poly([(396, 70), (410, 68), (412, 80), (400, 84)], VOID)           # third hole, right
    # thatch strands hang down the front
    for x in range(296, 420, 9):
        n = 3 + (x * 7) % 9
        for k in range(n):
            p.dot(x, 100 + k, hx('#a58b48') if k % 2 else hx('#8a7236'))
    # awning torn: strips missing, tatters hang
    for (x0, x1) in ((308, 322), (352, 366), (392, 404)):
        p.rect(x0, 124, x1, 132, VOID2)
        for k in range(x0, x1, 3):
            p.dot(k, 133 + (k % 4), hx('#d8d2d8') if (k // 3) % 2 else hx('#c05058'))
    # counter: two planks gone, one cracked
    p.rect(332, 174, 342, 186, VOID2)
    p.rect(402, 170, 408, 182, VOID2)
    p.crack(372, 156, 22)
    p.crack(300, 160, 16)
    # leaning post: left support snapped
    p.line([(285, 130), (281, 172)], INK, 2)
    # palm (right): fronds dead and drooping
    def dead(r, g, b):
        if g > r and g > b:
            return (r + 40, g - 10, b - 10) if g < 170 else (r + 60, g - 20, b)
        return None
    p.recolor((380, 90, 470, 130), dead)
    # palm (left) too
    p.recolor((8, 40, 85, 100), dead)
    # broken sign + cups + planks on the sand
    p.poly([(262, 205), (286, 200), (288, 207), (264, 212)], hx('#7a5a3a'), INK)
    p.poly([(300, 215), (330, 212), (332, 218), (302, 221)], hx('#6e5030'), INK)
    p.ell(352, 232, 5, 3, hx('#6b4a2c'), INK)
    p.ell(398, 226, 4, 3, hx('#7a5a38'), INK)
    p.dot(398, 223, hx('#d85a6a'))
    for x in range(20, 75, 11):                                              # seaweed tangles
        p.rect(x, 238, x + 4, 239, hx('#4c5a34'))
    # moss and vines on the roof edge
    p.moss((290, 70, 420, 118), MOSS, 0.07, lambda x, y: p.px[x, y][0] > 120)
    for vx in (299, 341, 382):
        p.vine(vx, 108, 14, (MOSS[1], MOSS[0]))
    p.web(290, 100, 10)
    # ---- richness pass: texture first, then more debris ----------------------------------------------------
    is_sand = lambda r, g, b: r > 170 and g > 150 and b > 120 and abs(r - g) < 40
    is_wood = lambda r, g, b: r > g > b and r < 190 and r - b > 25
    p.grain((0, 205, 479, 268), 0.03, 8, is_sand, seed=3)                  # sand grain
    p.grain((270, 160, 445, 218), 0.06, 10, is_wood, seed=4)                # counter: weathered
    p.grain((290, 72, 420, 116), 0.06, 10, None, seed=5)                    # thatch: straw flecks
    p.speckle((0, 212, 479, 266), [hx('#b0a086'), hx('#e0d4ba')], 40)     # sand glints / pebbles
    # plank grain + nails on the stripped back wall
    for x in range(326, 386, 8):
        p.line([(x, 126), (x, 182)], hx('#6a5648'))
        for y in (130, 150, 176):
            p.dot(x + 2, y, hx('#bdb0a0'))                                  # nail heads
    for (kx, ky) in ((340, 140), (366, 164), (352, 178)):
        p.ell(kx, ky, 2, 1, hx('#3a2c2c'))                                   # knots
    # sand drifts piled against the counter and round the stump
    sand = (hx('#d6c8a8'), hx('#c6b692'), hx('#a8987a'))
    for (cx, cy, rx, ry) in ((280, 213, 9, 3), (338, 215, 11, 3), (405, 214, 9, 3), (172, 209, 8, 2)):
        p.blob(cx, cy, rx, ry, sand)
    # fallen lantern on the sand + broken glass
    p.rect(256, 232, 262, 238, hx('#5a4a40'))
    p.rect(257, 233, 261, 237, hx('#8a6a58'))
    p.dot(259, 235, hx('#d8c8a0'))
    for (gx, gy) in ((270, 236), (273, 238), (277, 235), (283, 239)):
        p.dot(gx, gy, hx('#bfe0e0'))
    # rope coil and a torn net draped over the stump
    p.ell(222, 240, 6, 3, hx('#9a8660'), INK)
    p.ell(222, 240, 3, 1, hx('#cfc29a'))
    for k in range(0, 30, 6):
        p.line([(146 + k, 184), (148 + k, 196 + (k % 4))], hx('#a59a7e'))
    p.line([(146, 186), (176, 188)], hx('#8c8268'))
    p.line([(147, 192), (177, 194)], hx('#8c8268'))
    # barnacles + weed on the log
    p.speckle((4, 236, 58, 260), [hx('#d9d2c0'), hx('#9a9484')], 26)
    for x in range(6, 56, 9):
        p.vine(x, 262, 5, (MOSS[1], MOSS[2]), sway=1, leaf=.5)
    # quirk: a hermit crab has moved into a coconut cup
    p.ell(352, 232, 5, 3, hx('#6b4a2c'), INK)
    p.rect(349, 227, 351, 229, hx('#e0703c'))
    p.dot(352, 226, INK); p.dot(350, 226, INK)
    p.dot(353, 230, hx('#e0703c'))
    # a seedling grows from the hole in the roof
    p.line([(352, 70), (352, 62)], hx('#4f7a34'))
    for (dx, dy) in ((-3, 63), (3, 62), (-2, 60), (2, 59)):
        p.line([(352, 64), (352 + dx, dy)], hx('#6aa042'))
    # leaning, bent lamp post
    p.line([(245, 150), (241, 190)], hx('#6a5a48'))
    # rain-dark stains running down the thatch and wall
    for x in range(296, 420, 11):
        p.line([(x, 100), (x, 112 + (x % 9))], hx('#5e4e3c'))
    # ---- pass 3: directional texture and storytelling --------------------------------------------------------
    rng = p.rng
    straw = [hx('#c4ab62'), hx('#9a8446'), hx('#d8c37a'), hx('#7a6a3c')]
    for _ in range(150):                                                    # straw strokes, falling to the right
        x, y = rng.randint(292, 418), rng.randint(74, 112)
        if p.px[x, y][3] and p.px[x, y][0] > 120:
            c = rng.choice(straw)
            for k in range(rng.randint(2, 4)):
                p.dot(x + k // 2, y + k, c)
    for x in range(280, 436, 14):                                           # counter plank seams (soft)
        for y in range(180, 212, 2):
            p.dot(x, y, hx('#7c664f'))
    p.line([(272, 174), (436, 174)], hx('#c4aa86'))                         # lit top edge
    ripple = hx('#b6a684')
    for (rx0, ry0) in ((12, 232), (60, 246), (110, 238), (190, 252), (300, 248), (380, 256), (440, 240), (150, 224)):
        for i in range(0, 22, 1):                                           # wind ripples: shallow wavy lines
            p.dot(rx0 + i, ry0 + (1 if (i // 4) % 2 else 0), ripple)
    for (fx, fy) in ((210, 256), (218, 253), (226, 256), (234, 253), (242, 256)):   # footprints
        p.rect(fx, fy, fx + 2, fy + 1, hx('#a89878'))
    # strandline along the water: dark weed + foam crust
    for x in range(0, 480, 2):
        y = 188 + int(2 * __import__('math').sin(x / 9.0))
        if p.px[x, y][3] and (x * 13) % 7 < 3:
            p.dot(x, y + 1, hx('#4c5238'))
    for x in range(30, 480, 41):
        p.rect(x, 190, x + 5, 190, hx('#e8e4e0'))
    # the umbrella has holes and a snapped rib
    for (ux, uy) in ((290, 175), (298, 177)):
        p.rect(ux - 1, uy, ux + 1, uy + 1, hx('#b4a8a0'))
    p.line([(300, 168), (312, 160)], INK)
    # stump: moss on top, cracks down the front
    p.moss((136, 190, 190, 200), MOSS, 0.12)
    p.crack(160, 192, 16)
    p.crack(178, 196, 12)
    # shadows under the loose debris
    for (sx, sy, sw) in ((268, 214, 22), (306, 223, 26), (354, 235, 9), (392, 229, 8)):
        p.line([(sx, sy), (sx + sw, sy)], hx('#8c7c64'))
    # coconuts that fell from the left palm, a snapped frond across the sand
    for (cx, cy) in ((62, 214), (70, 218), (44, 222)):
        p.ell(cx, cy, 3, 3, hx('#6b4a2c'), INK)
        p.dot(cx - 1, cy - 1, hx('#a07850'))
    p.line([(78, 208), (110, 214)], hx('#8a7340'), 2)
    for k in range(0, 30, 4):
        p.line([(80 + k, 209 + k // 6), (78 + k, 204 + k // 6)], hx('#8a7340'))
    p.outline_new(before)


SPECS = {
    'haven-driftwood-tavern': driftwood_tavern,
}


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    out = os.path.join(ROOT, 'aseprite-source/v3/wonders/ruin/png')
    if '--out' in sys.argv:
        out = sys.argv[sys.argv.index('--out') + 1]
        args = [a for a in args if a != out]
    os.makedirs(out, exist_ok=True)
    for slug, fn in SPECS.items():
        if args and slug not in args:
            continue
        p = Pic(os.path.join(SRC, slug + '.png'))
        fn(p)
        p.save(os.path.join(out, slug + '.png'))
        print('wrote', slug)


if __name__ == '__main__':
    main()
