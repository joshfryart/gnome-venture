"""Gather tab scene for the ISLAND land: a bright tropical lagoon under a leaning coconut palm.

Run: python3 -B aseprite-source/scenes-pil/gather_island.py  ->  game/assets/img/gather/scene-island.png (480 x 270)
Same composition as every gather scene: sky and far layer on top, ground from about y 50, the shared open satchel
(gather_common.draw_satchel) at its fixed place, a clear landing patch left of it (x 96..144, y 92..112).
Island look: turquoise lagoon inside a white reef line, a far palm islet, warm sand; focal prop is the big coconut
palm leaning in from the left with its fronds over the scene; a coral pool in the left shallows, a conch on the right.
"""
import math
import os
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import Canvas, ramp, rect, rrect, ell, poly, line, shift, W, H  # noqa: E402
from gather_common import draw_satchel, save_scene  # noqa: E402
from stages_rainforest_tundra_island import (bands, wave, cloud, top_edge, ripples, palm, coconut, starfish,  # noqa: E402
                                             shell, grass_clump, birds, DWOOD, LEAF, MOSS, PETAL)

SAND = '#e8cf98'
WET = '#c9a96e'
LITE = '#f2e4c0'
FOAM = '#f1ece0'
CORAL = ramp('#e46a9b', '#b8457a', '#f6b8cf')
ORANGE = ramp('#f08a24', '#b8457a', '#f5cf6a')


def scene():
    cv = Canvas('#7fbcd8')
    # ---- sky: three calm bands, two small clouds kept out of the UI corners
    bands(cv, [(0, '#7fbcd8'), (12, '#a9d6ea'), (24, '#cde6e8')])
    cloud(cv, 112, 4, 30, FOAM, '#cde6e8')
    cloud(cv, 168, 16, 22, FOAM, '#cde6e8')
    birds(cv, [(92, 10), (102, 7)], '#3f8fb0')

    # ---- far layer: open sea, a white reef line, the lagoon, a far palm islet
    hz = 32
    bands(cv, [(hz, '#3f8fb0'), (hz + 5, '#7fc8c8'), (hz + 12, '#bfe6e0')])
    # far islet (flat haze, no outline)
    isle = wave(hz - 3, [(1.5, 50, 0.5)], 106, 146, hz) & ell(102, hz - 6, 150, hz + 6)
    cv.fill(isle, '#7ab58a')
    cv.fill(isle & ~shift(isle, -3, 0), '#4f7a5a')
    for (px, h, lean) in ((116, 9, -2), (124, 11, 1), (134, 8, 2)):
        cv.fill(line([(px, hz - 3), (px + lean, hz - 3 - h)]), '#4f7a5a')
        tx, ty = px + lean, hz - 3 - h
        cv.fill(line([(tx - 4, ty + 2), (tx, ty), (tx + 4, ty + 2)]), '#4f7a5a')
        cv.fill(line([(tx - 3, ty - 1), (tx, ty), (tx + 3, ty - 1)]), '#4f7a5a')
    # reef: a broken white breaker line with dark reef heads under it
    for x in range(0, W, 9):
        w = 4 + (x * 7) % 5
        cv.fill(rect(x, hz + 4, x + w, hz + 4), FOAM)
        cv.fill(rect(x + 1, hz + 5, x + w - 2, hz + 5), '#25637d')
    ripples(cv, rect(0, hz + 7, W - 1, hz + 11), '#bfe6e0', step=3, ln=3, seed=3)
    ripples(cv, rect(0, hz + 13, W - 1, 48), FOAM, step=3, ln=3, seed=7)

    # ---- ground: foam lip, wet band, warm sand
    surf = wave(48, [(1.2, 46, 0.4), (0.8, 19, 1.7)])
    cv.fill(surf, WET)
    cv.fill(top_edge(surf, 1), FOAM)
    beach = wave(52, [(1.0, 70, 1.1)])
    cv.fill(beach, SAND)
    cv.fill(top_edge(beach, 1), WET)
    # sand ripple marks (flat)
    for (x, y, w) in ((40, 62, 14), (80, 58, 12), (118, 66, 16), (60, 78, 12), (12, 88, 10), (98, 84, 12),
                      (220, 64, 12), (226, 88, 10), (150, 118, 14), (176, 126, 18), (110, 124, 12), (8, 128, 12),
                      (130, 76, 10), (20, 70, 10)):
        cv.fill(rect(x, y, x + w, y), WET)
        cv.fill(rect(x + 2, y - 1, x + w - 3, y - 1), LITE)

    # ---- coral pool in the left shallows (flat water, coral seen through it, one brain coral breaking surface)
    pool = ell(30, 104, 92, 130)
    cv.fill(dil(pool), WET)
    cv.fill(pool, '#7fc8c8')
    cv.fill(pool & ~shift(pool, 0, 2), '#3f8fb0')                  # shaded far bank of the pool
    for (cx, cy, s, rp) in ((42, 120, 6, CORAL), (56, 124, 5, ORANGE), (74, 121, 6, CORAL), (84, 116, 4, ORANGE), (64, 115, 4, CORAL)):
        branch(cv, cx, cy, s, rp)
    ripples(cv, pool & ~rect(0, 0, W, 108), '#bfe6e0', step=4, ln=3, seed=1)
    cv.fill(rect(30, 129, 92, 129) & dil(pool) & ~pool, FOAM)
    # a little fish in the pool
    cv.dots([(52, 112), (53, 112), (54, 112), (53, 111), (55, 111), (55, 113)], '#f5cf6a')

    # ---- right: second smaller palm leaning out of frame, conch, starfish, beach grass
    palm(cv, (234, 104), (244, 70), (226, 40), w0=7, w1=5, leaf=MOSS,
         fronds=[(-20, 18, 3), (-60, 14, 4), (-170, 20, 6), (160, 20, 7), (120, 18, 6), (30, 16, 4), (80, 14, 5)])
    grass_clump(cv, 222, 112, '#4f9a45', '#7ab55c', 9, 6)
    conch(cv, 216, 116)
    starfish(cv, 230, 126, ramp('#f08a24', '#b8457a', '#f5cf6a'))

    # ---- the focal palm: leans in from the left, fronds swaying over the scene, coconuts on the sand
    cv.fill(ell(10, 104, 40, 112), WET)
    palm(cv, (22, 108), (8, 58), (58, 24), w0=11, w1=6, leaf=LEAF,
         fronds=[(-178, 30, 6), (-150, 22, 4), (-110, 16, 6), (-60, 22, 5), (-20, 34, 7), (10, 36, 10),
                 (40, 28, 10), (150, 30, 12), (115, 24, 10)])
    for (x, y) in ((6, 104), (32, 106), (14, 112)):
        coconut(cv, x, y)
    shell(cv, 46, 92, PETAL)
    shell(cv, 70, 98, ramp('#f2e4c0', '#c9a96e', '#fff3c8'))

    # ---- landing patch: a smoothed ring of damp sand with a sunlit centre and a few shells round it
    cv.fill(ell(96, 98, 144, 112), WET)
    cv.fill(ell(100, 100, 140, 110), LITE)
    cv.fill(ell(104, 102, 136, 108) & ~ell(106, 103, 134, 107), SAND)

    draw_satchel(cv)
    cv.remap({'#fff3c8': LITE, '#c9c5bc': FOAM, '#8a5a30': '#7a4a1f'})
    return cv


def dil(m):
    return m | shift(m, 1, 0) | shift(m, -1, 0) | shift(m, 0, 1) | shift(m, 0, -1)


def branch(cv, cx, cy, s, rp):
    """Branching coral seen through shallow water: flat, base tone with a lit tip on each arm."""
    arms = [(cx, cy, cx, cy - s - 1), (cx, cy - 1, cx - s, cy - s), (cx, cy - 1, cx + s, cy - s + 1),
            (cx - s // 2, cy - s // 2, cx - s // 2 - 1, cy - s - 2)]
    for (x0, y0, x1, y1) in arms:
        cv.fill(line([(x0, y0), (x1, y1)], 2), rp['b'])
        cv.dots([(x1, y1)], rp['r'])
    cv.fill(rect(cx - 2, cy, cx + 2, cy + 1), rp['s'])


def conch(cv, x, y):
    """A big pink conch lying on the sand, spire up-left."""
    o = cv.obj()
    body = poly([(x - 8, y - 4), (x - 2, y - 9), (x + 8, y - 6), (x + 12, y), (x + 4, y + 4), (x - 6, y + 2)])
    o.part(body, ramp('#f6b8cf', '#e46a9b', '#f2e4c0'), d=2)
    o.part(poly([(x - 8, y - 4), (x - 13, y - 7), (x - 6, y - 7)]), ramp('#f2e4c0', '#c9a96e'), d=1)
    o.draw()
    cv.fill(ell(x + 1, y - 4, x + 9, y + 1), '#e46a9b')
    cv.fill(ell(x + 3, y - 3, x + 8, y), '#b8457a')
    for k in (-6, -2):
        cv.dots([(x + k, y - 6), (x + k + 1, y - 7)], '#c9a96e')


if __name__ == '__main__':
    cv = scene()
    save_scene(cv, 'island')
    print('colours', cv.colours())
