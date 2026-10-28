"""Gather tab scene, COAST: a salt-wind morning on the rock shelf below the tideline.

Usage: python3 -B aseprite-source/scenes-pil/gather_coast.py  -> game/assets/img/gather/scene-coast.png (480 x 270)
Same frame as every gather scene: sky and far sea on top, ground from y 50, the shared open satchel (gather_common)
at its fixed place, a flat wet-sand ring left of it where the find lands. Focal prop: an old driftwood mooring post
on the left, wound with rope and hung with kelp, a gull standing on top. Tide pool on the rock shelf at bottom left,
kelp-draped rocks at far right, sea stacks and gulls in the far layer.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, W, H  # noqa: E402
from gather_common import draw_satchel, save_scene  # noqa: E402
from stops import bands, wave, cloud, ripples  # noqa: E402

STONE = ramp('#8b8f96', '#5b6470', '#c9c5bc')
DRIFT = ramp('#c9a96e', '#9a6b3f', '#f1ece0', '#8a5a30')     # sun-bleached driftwood
ROPE = ramp('#e8a317', '#b07a10', '#f5cf6a')
KELP = ramp('#4f9a45', '#2f5a2a', '#a4b86a')
WATER = ramp('#3f8fb0', '#25637d', '#a9d6ea')
GULL = ramp('#f1ece0', '#c9c5bc', None)
GWING = ramp('#8b8f96', '#5b6470', '#c9c5bc')
STAR = ramp('#f08a24', '#d6322b', '#f5cf6a')

SAND, WET, FOAM = '#e8cf98', '#c9a96e', '#f1ece0'


def rnd(seed):
    s = [seed * 9301 + 49297]

    def r(a, b):
        s[0] = (s[0] * 9301 + 49297) % 233280
        return a + s[0] * (b - a + 1) // 233280
    return r


def gull_fly(cv, x, y, col='#5b6470'):
    cv.fill(line([(x, y + 2), (x + 2, y), (x + 4, y + 2), (x + 6, y), (x + 8, y + 2)]), col)


def kelp_strand(cv, pts, w=2):
    o = cv.obj(outline=False)
    o.part(line(pts, w), KELP, d=1)
    o.draw()


def scene():
    cv = Canvas()
    # ---------------------------------------------------------------- sky
    bands(cv, [(0, '#a9d6ea'), (20, '#cde6e8')])
    cloud(cv, 52, 6, 34, FOAM, '#cde6e8')
    cloud(cv, 150, 12, 26, FOAM, '#cde6e8')
    # ---------------------------------------------------------------- far sea + sea stacks
    bands(cv, [(31, '#7fbcd8'), (40, '#3f8fb0')])
    cv.fill(rect(0, 31, W - 1, 31), '#a9d6ea')                       # bright horizon line
    ripples(cv, rect(0, 33, W - 1, 38), '#a9d6ea', step=3, ln=3, seed=2)
    ripples(cv, rect(0, 41, W - 1, 46), '#7fbcd8', step=3, ln=5, seed=5)
    # two weathered stacks and an arch, hazy, far right of centre
    stk = (poly([(98, 41), (100, 26), (104, 22), (109, 24), (111, 41)]) |
           poly([(116, 41), (118, 31), (122, 29), (125, 33), (126, 41)]))
    arch = poly([(196, 41), (198, 30), (204, 26), (226, 27), (234, 33), (238, 41)]) & ~ell(205, 32, 223, 50)
    for m in (stk, arch):
        cv.fill(m, '#8b8f96')
        cv.fill(m & ~shift(m, 1, 0), '#c9c5bc')
        cv.fill(rect(0, 40, W, 41) & m, '#5b6470')
    cv.fill(rect(97, 42, 112, 42) | rect(115, 42, 127, 42) | rect(195, 42, 206, 42) | rect(222, 42, 239, 42), FOAM)
    for (x, y) in ((66, 15), (80, 21), (176, 7)):
        gull_fly(cv, x, y)
    # ---------------------------------------------------------------- shore + sand
    s = wave(48, [(1.2, 60, 0.4), (0.8, 23, 1.6)])
    cv.fill(s, WET)
    cv.fill(s & ~shift(s, 0, 1), FOAM)
    for x in range(6, W, 26):
        cv.fill(rect(x, 46, x + 7, 46), FOAM)
    d = wave(53, [(1.2, 70, 2.0), (0.8, 29, 0.1)])
    cv.fill(d, SAND)
    cv.fill(d & ~shift(d, 0, 1), '#f2e4c0')
    r = rnd(4)
    for y in range(60, H, 7):                                         # wind ripples in the sand
        x = r(0, 20)
        while x < W:
            cv.fill(rect(x, y, x + r(3, 6), y), WET)
            x += r(16, 30)
    # ---------------------------------------------------------------- landing ring: flat wet sand with pebbles
    cv.fill(ell(94, 97, 146, 113), WET)
    cv.fill(ell(99, 100, 141, 110), '#f2e4c0')
    cv.fill(ell(99, 100, 141, 110) & ~shift(ell(99, 100, 141, 110), 0, -1), WET)
    for i in range(14):
        a = i * 2 * math.pi / 14 + 0.2
        px, py = round(120 + 25 * math.cos(a)), round(105 + 7.5 * math.sin(a))
        cv.fill(rect(px - 1, py, px, py), '#8b8f96' if i % 3 else '#c9c5bc')
        cv.dots([(px, py + 1)], '#5b6470')
    # ---------------------------------------------------------------- rock shelf with the tide pool (bottom left)
    shelf = poly([(0, 104), (14, 98), (40, 96), (66, 100), (86, 108), (92, 118), (88, 135), (0, 135)])
    o = cv.obj()
    o.part(shelf, STONE, d=3)
    o.draw()
    cv.fill(line([(10, 112), (24, 108)]) | line([(70, 116), (80, 124)]) | line([(6, 126), (18, 130)]), '#5b6470')
    pool = ell(18, 106, 72, 126)
    cv.fill(shift(pool, 0, -1) & ~pool | (pool & ~shift(pool, 1, 1)), '#5b6470')
    cv.fill(pool, WATER['b'])
    cv.fill(pool & ~shift(pool, -2, -2), WATER['s'])
    cv.fill(ell(24, 109, 46, 113), '#7fbcd8')                         # sky in the water
    cv.fill(rect(28, 110, 36, 110) | rect(50, 118, 55, 118), '#a9d6ea')
    # anemones + a starfish in the pool, weed at its lip
    for (x, y) in ((56, 113), (62, 117)):
        cv.fill(ell(x - 2, y - 1, x + 2, y + 2), '#e46a9b')
        cv.dots([(x - 2, y - 2), (x, y - 3), (x + 2, y - 2)], '#f6b8cf')
    o = cv.obj(outline=False)
    m = blank()
    for k in range(5):
        a = -math.pi / 2 + k * 2 * math.pi / 5
        m |= line([(38, 119), (round(38 + 5 * math.cos(a)), round(119 + 4 * math.sin(a)))], 2)
    o.part(m, STAR, d=1)
    o.draw()
    for (x, y, h) in ((22, 108, 5), (26, 107, 7), (68, 110, 6)):
        cv.fill(line([(x, y), (x + 1, y - h)]), '#2f5a2a')
    # ---------------------------------------------------------------- focal: driftwood mooring post with a gull
    px0, px1 = 36, 45
    post = rect(px0, 44, px1, 100) & ~(rect(px0, 44, px0 + 2, 46) | rect(px1 - 3, 44, px1, 45))
    post &= ~(rect(px1, 70, px1, 74) | rect(px0, 82, px0, 85))   # weather-worn notches
    o = cv.obj()
    o.part(post, DRIFT, d=3)
    o.part(rect(px0 - 1, 62, px1 + 1, 64), ROPE, d=1, contour=True)
    o.part(rect(px0 - 1, 67, px1 + 1, 69), ROPE, d=1, contour=True)
    o.draw()
    for (x, y0, y1) in ((39, 48, 58), (42, 74, 92), (38, 88, 96), (41, 50, 55)):
        cv.fill(rect(x, y0, x, y1), '#9a6b3f')                       # grain
    cv.dots([(x, 63) for x in range(px0, px1 + 1, 2)] + [(x, 68) for x in range(px0 + 1, px1 + 1, 2)], '#b07a10')
    # rope tail trailing down to a ring in the sand
    o = cv.obj()
    o.part(line([(px1 + 1, 69), (49, 80), (50, 90), (53, 97), (58, 99), (63, 97), (68, 99), (72, 98)], 2), ROPE, d=0)
    o.draw()
    cv.dots([(51, 84), (51, 91), (56, 99), (66, 99)], '#b07a10')
    # kelp draped over the rope
    kelp_strand(cv, [(px0, 64), (32, 70), (31, 78), (33, 84)])
    kelp_strand(cv, [(px0 + 3, 65), (37, 74), (38, 80)])
    kelp_strand(cv, [(px1, 66), (47, 72), (46, 79)], 1)
    cv.dots([(33, 84), (34, 85), (38, 81)], '#a4b86a')
    # the gull on top, facing left into the wind
    o = cv.obj()
    o.part(ell(32, 32, 50, 43), GULL, d=2)                            # body
    o.part(ell(28, 25, 38, 35), GULL, d=1)                            # head
    o.part(poly([(38, 33), (50, 33), (58, 40), (47, 41)]), GWING, d=1, contour=True)  # folded wing + tail
    o.part(rect(23, 29, 28, 30) | rect(24, 31, 27, 31), ROPE, d=0)    # beak
    o.draw()
    cv.fill(poly([(53, 37), (58, 40), (52, 40)]), '#2a1a10')          # black wingtip
    cv.dots([(56, 41), (54, 41)], '#f1ece0')
    cv.dots([(30, 28), (31, 28)], '#2a1a10')                          # eye
    cv.dots([(24, 31)], '#d6322b')                                     # beak spot
    cv.fill(rect(39, 43, 39, 44) | rect(43, 43, 43, 44), '#f08a24')   # legs
    # ---------------------------------------------------------------- scatter: shells, driftwood stick, crab
    for i, (x, y) in enumerate(((10, 70), (62, 66), (84, 84), (74, 58), (20, 88), (226, 64), (150, 118), (190, 124),
                                (110, 124), (6, 60), (130, 88))):
        c = ('#f6b8cf', FOAM, '#e8a317')[i % 3]
        cv.fill(rect(x, y, x + 2, y) | rect(x + 1, y - 1, x + 1, y - 1), c)
    o = cv.obj()                                                       # a driftwood log on the sand
    log = poly([(56, 74), (88, 68), (90, 74), (58, 81)])
    o.part(line([(76, 71), (80, 61), (84, 58)], 2), DRIFT, d=0)
    o.part(log, DRIFT, d=2)
    o.part(ell(53, 74, 59, 81), ramp('#f2e4c0', '#c9a96e', '#f1ece0'), d=1, contour=True)
    o.draw()
    cv.dots([(56, 77)], '#9a6b3f')
    cv.fill(line([(62, 76), (72, 74)]) | line([(74, 75), (84, 72)]), '#9a6b3f')
    o = cv.obj()                                                       # little red crab by the pool
    o.part(ell(76, 92, 86, 98), ramp('#d6322b', '#a8241f', '#f08a24'), d=1)
    o.part(ell(72, 89, 76, 93) | ell(86, 89, 90, 93), ramp('#d6322b', '#a8241f', '#f08a24'), d=0, contour=True)
    o.draw()
    cv.dots([(79, 91), (83, 91)], '#2a1a10')
    cv.dots([(74, 98), (76, 99), (86, 99), (88, 98)], '#a8241f')
    # ---------------------------------------------------------------- far right: kelp-draped rocks
    o = cv.obj()
    o.part(ell(214, 96, 244, 126) & rect(0, 0, W, 118), STONE, d=3)
    o.part(ell(208, 108, 226, 124) & rect(0, 0, W, 120), STONE, d=2)
    o.draw()
    kelp_strand(cv, [(222, 98), (218, 104), (219, 112)])
    kelp_strand(cv, [(230, 97), (232, 104), (229, 110), (231, 116)])
    kelp_strand(cv, [(214, 110), (212, 116)], 1)
    for (x, y) in ((224, 103), (226, 102), (236, 101)):
        cv.dots([(x, y)], '#2a1a10')                                   # barnacles
    for (x, y) in ((218, 80), (232, 76), (236, 84)):                   # sea pinks in a grass tuft
        cv.fill(line([(x, y + 6), (x - 1, y)]) | line([(x + 1, y + 6), (x + 3, y + 1)]), KELP['b'])
        cv.dots([(x - 1, y - 1), (x, y - 1), (x - 1, y - 2)], '#e46a9b')
    # ---------------------------------------------------------------- the satchel (shared)
    draw_satchel(cv)
    cv.remap({'#fff3c8': FOAM})
    return cv


if __name__ == '__main__':
    cv = scene()
    save_scene(cv, 'coast')
    print('colours:', cv.colours())
