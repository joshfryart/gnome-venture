"""Gather tab scene, DESERT land (by day): game/assets/img/gather/scene-desert.png (480 x 270).

Run: python3 -B aseprite-source/scenes-pil/gather_desert.py
Same layout as every gather scene: sky + far layer on top, sand from y ~50, the shared open satchel at its fixed place
(drawn by gather_common.draw_satchel after the background and props), a clear landing patch at x 96..144, y 92..112.
Desert: an ember sun in a hot sky, heat-shimmer lines over far mesas with a blue mirage pool on the horizon, wind-combed
dunes. Focal prop: an old sandstone gnome head, half sunk in a dune at the left, its tall hat still standing.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, W, H  # noqa: E402
from gather_common import draw_satchel, save_scene  # noqa: E402

SANDSTONE = ramp('#e0805a', '#b8553a', '#f6b89a', '#c96a40')
HATSTONE = ramp('#c96a40', '#8a3a2a', '#e0805a')
CACTUS = ramp('#4f9a45', '#2f6a3a', '#7ab55c')
PEBBLE = ramp('#c9a96e', '#9a6b3f', '#f6e7c0')


def wave(base, terms, x0=0, x1=W - 1, bottom=H - 1):
    m = blank()
    for x in range(max(0, x0), min(W - 1, x1) + 1):
        t = base + sum(a * math.sin(x * 2 * math.pi / p + ph) for a, p, ph in terms)
        m[max(0, int(round(t))):bottom + 1, x] = True
    return m


def mesa(cv, x0, x1, top, base, col, shade=None):
    s = max(3, (x1 - x0) // 8)
    m = poly([(x0, base), (x0 + s, top + 3), (x0 + s + 2, top), (x1 - s - 2, top), (x1 - s, top + 3), (x1, base)])
    cv.fill(m, col)
    if shade:
        cv.fill(m & poly([(x1 - s - 2, top), (x1, base), (x1 - s - 8, base), (x1 - s - 6, top)]), shade)
    return m


def saguaro(cv, x, base, h, arms):
    o = cv.obj()
    o.part(rrect(x - 3, base - h, x + 3, base, 2), CACTUS, d=2)
    for (t, side, ah) in arms:
        ay = round(base - h * t)
        ax = x + side * 8
        o.part(rect(min(x, ax), ay, max(x, ax), ay + 3), CACTUS, d=1)
        o.part(rrect(ax - 2, ay - ah, ax + 2, ay + 3, 2), CACTUS, d=2)
    o.draw()
    for k in range(base - h + 3, base - 2, 3):
        cv.dots([(x - 1, k), (x + 1, k + 1)], CACTUS['s'])


def scene():
    cv = Canvas('#7fbcd8')
    # hot sky: stepped bands, paler and warmer toward the horizon
    for y, c in ((0, '#7fbcd8'), (16, '#a9d6ea'), (30, '#f6e7c0'), (40, '#f6d9b0')):
        cv.fill(rect(0, y, W - 1, H - 1), c)
    # ember sun with a stepped glow ring (kept clear of the top corners)
    cx, cy = 78, 22
    cv.fill(ell(cx - 13, cy - 13, cx + 13, cy + 13) & rect(0, 0, W, 29), '#f5cf6a')
    cv.fill(ell(cx - 10, cy - 10, cx + 10, cy + 10), '#f08a24')
    cv.fill(rect(cx - 4, cy - 6, cx - 1, cy - 5) | rect(cx - 6, cy - 4, cx - 5, cy - 1), '#f5cf6a')
    cv.fill(rect(cx - 4, cy - 4, cx - 3, cy - 3), '#f6e7c0')
    # far mesas in warm haze, with heat-shimmer lines cut through them
    far = blank()
    for (x0, x1, t) in ((-12, 46, 34), (120, 168, 38), (186, 252, 32)):
        far |= mesa(cv, x0, x1, t, 52, '#e8b48a', '#e0a07a')
    for y in (39, 43, 47):
        for x in range((y * 5) % 11, W, 17):
            cv.fill(rect(x, y, x + 6, y) & far, '#f6d9b0')
    # dunes: a back ridge with a shaded lee, then the main sand floor
    d1 = wave(52, [(3, 96, 0.4), (2, 41, 2.0)])
    cv.fill(d1, '#f5cf6a')
    cv.fill(d1 & ~shift(d1, -4, 0) & ~rect(0, 0, W, 53), '#e8a317')
    # the mirage: a cool false pool on the horizon, reflecting a mesa upside down
    mir = ell(58, 49, 128, 58) & rect(0, 52, W, 58)
    cv.fill(mir, '#a9d6ea')
    cv.fill(mir & poly([(104, 52), (126, 52), (120, 56), (110, 56)]), '#e8b48a')
    for (x, y, w) in ((66, 54, 10), (84, 56, 12), (92, 53, 6)):
        cv.fill(rect(x, y, x + w, y) & mir, '#f6e7c0')
    d2 = wave(62, [(3, 120, 2.4), (1, 37, 0.9)])
    cv.fill(d2, '#e8cf98')
    cv.fill(d2 & ~shift(d2, 0, 2), '#f6e7c0')
    near = wave(122, [(2, 110, 1.1), (1, 33, 0.3)])
    cv.fill(near, '#d9b878')
    # wind ripples on the sand (short paired lines)
    for (x, y, w) in ((10, 76, 16), (52, 84, 12), (96, 72, 14), (20, 116, 18), (64, 112, 14), (156, 112, 14),
                      (214, 74, 14), (124, 80, 10), (176, 118, 16), (220, 104, 12), (80, 124, 16), (40, 98, 10)):
        cv.fill(rect(x, y, x + w, y) | rect(x + 3, y + 1, x + w - 2, y + 1), '#d9b878')

    # FOCAL: the sunken sandstone gnome head, hat still upright, beard drowned in the dune
    o = cv.obj()
    hat = poly([(22, 58), (60, 58), (50, 30), (44, 22), (40, 20)])
    face = ell(20, 52, 62, 96) & rect(0, 0, W, 90)
    o.part(face, SANDSTONE, d=3)
    o.part(hat, HATSTONE, d=2)
    o.part(rrect(18, 54, 64, 61, 2), HATSTONE, d=2, contour=True)     # hat brim band
    o.draw()
    # closed, sleepy stone eyes and brow, a crack and a chip off the hat
    for ex in (27, 49):
        cv.fill(rect(ex, 67, ex + 5, 67) | rect(ex + 1, 68, ex + 4, 68), '#8a3a2a')
    cv.fill(line([(56, 64), (54, 70), (57, 75)]), '#8a3a2a')
    cv.fill(line([(44, 30), (47, 38), (45, 44)]), '#8a3a2a')
    cv.fill(rect(22, 62, 25, 62), '#f6b89a')
    # stone beard, curls showing above the sand
    o = cv.obj()
    o.part(poly([(24, 80), (36, 78), (46, 78), (58, 80), (56, 94), (26, 94)]), SANDSTONE, d=2, contour=True)
    o.draw()
    o = cv.obj()
    o.part(ell(35, 67, 47, 80), SANDSTONE, d=2)                        # big round nose, in front of the beard
    o.draw()
    cv.fill(rect(38, 70, 39, 71), '#f6b89a')
    for (bx, by) in ((28, 84), (49, 84), (53, 87), (33, 89), (41, 88), (49, 90)):
        cv.fill(rect(bx, by, bx + 3, by) | rect(bx + 3, by + 1, bx + 3, by + 1), '#b8553a')
    # sand drift piled over the beard (it sits in front of the head)
    drift = ell(4, 88, 84, 110) & rect(0, 0, W, 98)
    cv.fill(drift, '#f5cf6a')
    cv.fill(drift & ~shift(drift, 0, 2), '#f6e7c0')
    cv.fill(drift & ~shift(drift, -3, 0) & rect(0, 88, W, H), '#e8a317')
    cv.fill(drift & rect(0, 97, W, 98), '#e8cf98')
    # a little barrel cactus in flower on the drift
    o = cv.obj()
    o.part(ell(70, 88, 80, 100) & rect(0, 0, W, 97), CACTUS, d=2)
    o.draw()
    for k in (72, 75, 78):
        cv.fill(rect(k, 91, k, 96), CACTUS['s'])
    cv.fill(rect(74, 86, 76, 87), '#e46a9b')
    cv.dots([(75, 86)], '#f6b8cf')
    # pebbles bottom left
    for (x0, y0, x1, y1) in ((10, 110, 26, 118), (30, 116, 38, 121)):
        o = cv.obj()
        o.part(ell(x0, y0, x1, y1 + (y1 - y0) // 2) & rect(0, 0, W, y1), PEBBLE, d=2)
        o.draw()

    # far right: a tall saguaro and a rock at its foot
    saguaro(cv, 226, 108, 58, arms=((0.48, -1, 14), (0.66, 1, 10)))
    cv.dots([(218, 59), (219, 58), (234, 77)], '#e46a9b')
    o = cv.obj()
    o.part(ell(214, 110, 238, 130) & rect(0, 0, W, 122), SANDSTONE, d=3)
    o.draw()

    # the landing patch: a flat, wind-smoothed hardpan ring left of the satchel
    cv.fill(ell(96, 98, 144, 112), '#d9b878')
    cv.fill(ell(100, 100, 140, 110), '#f6e7c0')
    cv.fill(ell(100, 100, 140, 110) & ~shift(ell(100, 100, 140, 110), 0, 1) & rect(0, 0, W, 103), '#e8cf98')
    # satchel's cast shadow on the sand, lower right
    cv.fill(rrect(150, 100, 218, 108, 3), '#d9b878')

    draw_satchel(cv)
    return cv


if __name__ == '__main__':
    cv = scene()
    save_scene(cv, 'desert')
    print('colours:', cv.colours())
