"""Gather tab scene, TUNDRA: wide white quiet under an aurora (2026-10-28).

Run: python3 -B aseprite-source/scenes-pil/gather_tundra.py  ->  game/assets/img/gather/scene-tundra.png (480 x 270)
Drawn on the 240 x 135 grid with pixlib. Night-blue sky with a green aurora, a far ice ridge with a few caribou,
snow ground with wind ripples and lichen showing through. Focal prop: a perched glacial erratic (a big slab on a
small pedestal stone) with a snow cap, orange and sage lichen, and icicles hanging from its underside.
The find lands on a small frozen pool left of the satchel. The satchel itself comes from gather_common.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, W, H  # noqa: E402
from gather_common import draw_satchel, save_scene  # noqa: E402
from stops import bands, wave  # noqa: E402

SNOW = '#f1ece0'
SNOW_S = '#cde6e8'
ICE = '#a9d6ea'
ICE_D = '#7fbcd8'
STONE = ramp('#8b8f96', '#5b6470', '#c9c5bc')
ICICLE = ramp(SNOW_S, ICE_D, SNOW)
SNOWCAP = ramp(SNOW, SNOW_S, None)
BONE = ramp('#f2e4c0', '#c9a96e', '#fff3c8')
AUR = ('#4f9a45', '#7ab55c', '#a4b86a')  # aurora: upper streaks, body, bright hem


def aurora(cv, y0, amp, per, ph, x0, x1, ln, seed):
    """A curtain: a wavy bright hem with vertical streaks rising from it (hard steps)."""
    for x in range(x0, x1 + 1):
        hem = int(round(y0 + amp * math.sin(x * 2 * math.pi / per + ph) + 1.5 * math.sin(x * 2 * math.pi / 23 + seed)))
        k = (x * 7 + seed * 5) % 11
        edge = min(x - x0, x1 - x)
        h = ln - (k % 4) - max(0, 6 - edge)
        if h <= 1:
            continue
        top = hem - h
        cv.fill(rect(x, max(0, top), x, hem), AUR[1])
        cv.fill(rect(x, max(0, top), x, top + h // 3), AUR[0])
        if k % 3 != 1:
            cv.fill(rect(x, hem, x, hem), AUR[2])


def caribou(cv, x, y, col):
    cv.fill(rect(x, y, x + 5, y + 2), col)
    cv.dots([(x, y + 3), (x + 1, y + 4), (x + 4, y + 3), (x + 5, y + 4), (x + 6, y - 1), (x + 7, y - 1),
             (x + 6, y), (x + 7, y + 1), (x + 6, y - 2), (x + 8, y - 3), (x + 5, y - 3)], col)
    cv.dots([(x, y + 4), (x + 4, y + 4)], col)


def scene():
    cv = Canvas('#2e3a6b')
    # ---- sky: night blue stepping to a lavender horizon
    bands(cv, [(0, '#2e3a6b'), (12, '#3b4f84'), (22, '#4e6a9a'), (31, '#7a8fc0'), (38, '#c3b2ea')])
    for (x, y) in ((52, 6), (88, 16), (118, 4), (160, 18), (192, 8), (14, 22), (226, 24), (70, 27), (140, 28), (104, 22)):
        cv.dots([(x, y)], SNOW)
    cv.dots([(118, 3), (117, 4), (119, 4), (118, 5)], '#c3b2ea')
    cv.dots([(118, 4)], SNOW)
    # ---- aurora overhead: two curtains, kept clear of the UI corners
    aurora(cv, 17, 4, 70, 0.6, 44, 198, 12, 1)
    aurora(cv, 27, 3, 52, 2.4, 22, 128, 8, 4)
    # ---- far layer: low ice ridge and a pale snow plain
    ridge = wave(40, [(2.5, 74, 1.0), (1.2, 29, 0.4)])
    cv.fill(ridge, ICE)
    cv.fill(ridge & ~shift(ridge, 2, 0) & rect(0, 0, W, 46), SNOW_S)
    plain = wave(46, [(1.0, 60, 2.2), (0.6, 21, 0.8)])
    cv.fill(plain, SNOW_S)
    for (x, y) in ((64, 44), (74, 45), (84, 44)):
        caribou(cv, x, y, '#5b6470')
    # ---- snow ground from y 50
    gnd = wave(50, [(0.8, 80, 0.3), (0.5, 33, 1.7)])
    cv.fill(gnd, SNOW)
    cv.fill(gnd & ~shift(gnd, 0, 1), SNOW_S)
    # wind ripples (scoop lines), denser near the front
    for (x, y, w) in ((96, 58, 22), (124, 62, 14), (6, 112, 18), (60, 122, 26), (100, 120, 20), (138, 126, 24),
                      (170, 116, 18), (196, 128, 22), (86, 70, 16), (100, 82, 12), (14, 124, 12), (216, 74, 14)):
        cv.fill(rect(x, y, x + w, y), SNOW_S)
        cv.fill(rect(x + 3, y + 1, x + w - 3, y + 1), ICE)
    # lichen and sedge showing through thin snow
    for (x, y, w) in ((92, 90, 8), (40, 114, 10), (176, 122, 9), (220, 96, 8), (124, 70, 6)):
        cv.fill(rrect(x, y, x + w, y + 2, 1), '#a4b86a')
        cv.dots([(x + 2, y), (x + w - 2, y + 1)], '#e8a317')
        cv.dots([(x + 1, y - 1), (x + 3, y - 2), (x + w - 1, y - 1)], '#c9a96e')
    # ---- focal: perched erratic with icicles
    o = cv.obj()
    o.part(rrect(38, 82, 56, 104, 3), STONE, d=2)                      # pedestal stone
    slab = poly([(8, 72), (14, 62), (30, 56), (58, 53), (78, 57), (88, 66), (86, 78), (72, 86), (24, 87), (10, 82)])
    o.part(slab, STONE, d=3, contour=True)
    lumps = ell(12, 54, 40, 66) | ell(30, 49, 62, 61) | ell(54, 50, 84, 63) | ell(4, 66, 16, 76)
    cap = (lumps & ~slab & rect(0, 0, W, 70)) | (slab & ~shift(slab, 0, 5)) | (ell(5, 68, 14, 78) & slab)
    o.part(cap, SNOWCAP, d=2, contour=True)
    o.draw()
    cv.fill(line([(44, 64), (48, 71), (46, 79), (49, 85)]) & slab & ~cap, '#5b6470')     # frost crack
    cv.fill(line([(45, 64), (49, 71)]) & slab & ~cap, '#c9c5bc')
    cv.dots([(28, 52), (29, 52), (46, 47), (47, 47), (66, 48)], SNOW_S)                 # wind-blown crest
    # icicles hanging from the slab underside (not over the pedestal)
    o = cv.obj()
    for (x, ln) in ((14, 5), (19, 9), (24, 6), (29, 12), (34, 5), (61, 8), (66, 13), (71, 7), (76, 10), (81, 4)):
        top = 85 if 18 < x < 74 else 82
        o.part(poly([(x - 1, top), (x + 2, top), (x, top + ln)]), ICICLE, d=1)
    o.draw()
    cv.dots([(19, 85), (29, 87), (66, 88)], SNOW)
    cv.dots([(29, 100), (30, 100), (66, 101), (67, 101)], ICE_D)                         # drips in the snow below
    # lichen rosettes on the slab face (clusters, not spots)
    for (x, y, c) in ((20, 72, '#f08a24'), (60, 70, '#f08a24'), (34, 79, '#a4b86a'), (74, 76, '#e8a317'), (52, 80, '#a4b86a')):
        m = ell(x - 3, y - 2, x + 2, y + 1) | ell(x, y - 1, x + 4, y + 2) | ell(x - 1, y + 1, x + 1, y + 3)
        cv.fill(m & slab & ~cap, c)
        cv.dots([(x - 2, y - 1), (x + 2, y)], '#f5cf6a' if c != '#a4b86a' else '#c9c5bc')
    cv.fill((ell(40, 90, 45, 94) | ell(43, 92, 47, 96)), '#a4b86a')
    # snow drift banked against the pedestal
    drift = ell(26, 100, 72, 112) & rect(0, 0, W, 106)
    cv.fill(drift, SNOW)
    cv.fill(drift & ~shift(drift, 0, -1) & rect(0, 104, W, H), SNOW_S)
    cv.fill(rect(30, 106, 68, 106), SNOW_S)
    # ---- a shed antler lying in the snow, lower left
    o = cv.obj()
    o.part(line([(8, 127), (20, 123), (34, 121), (46, 117), (56, 110)], 3), BONE, d=1)
    o.part(ell(5, 124, 11, 130), BONE, d=1)                                   # burr
    for pts in (((18, 123), (15, 117), (17, 112)), ((30, 121), (29, 114), (32, 109)),
                ((42, 118), (44, 111), (48, 107)), ((56, 110), (58, 104))):
        o.part(line(list(pts), 2), BONE, d=1)
    o.draw()
    cv.fill(rect(12, 129, 50, 129) & ~rect(26, 129, 30, 129), SNOW_S)
    # ---- far right: small snow-capped stone with cottongrass
    o = cv.obj()
    m = ell(218, 104, 240, 124) & rect(0, 0, W, 117)
    o.part(m, STONE, d=2)
    o.part(m & ~shift(m, 0, 4), SNOWCAP, d=1, contour=True)
    o.draw()
    cv.dots([(222, 112), (223, 112), (226, 114)], '#f08a24')
    for (x, y, h) in ((220, 96, 9), (224, 94, 12), (229, 97, 8), (233, 95, 10)):
        cv.fill(rect(x, y - h, x, y), '#a4b86a')
        cv.fill(rect(x - 1, y - h - 2, x + 1, y - h), SNOW)
        cv.dots([(x - 1, y - h - 2)], '#fff3c8')
    # ---- landing spot: a small frozen pool
    pool = ell(96, 98, 144, 112)
    cv.fill(pool, ICE_D)
    inner = ell(98, 99, 142, 111)
    cv.fill(inner, ICE)
    cv.fill(inner & ~shift(inner, 0, 1) & rect(0, 0, W, 104), ICE_D)
    cv.fill(rect(104, 102, 110, 102) | rect(108, 103, 112, 103), SNOW)                      # glint, upper left
    cv.fill(rect(122, 106, 128, 106) | rect(128, 107, 131, 107), SNOW_S)                    # hairline crack
    # cool shadow under the satchel
    cv.fill(ell(140, 98, 218, 110) & ~pool, SNOW_S)
    draw_satchel(cv)
    save_scene(cv, 'tundra')
    return cv


if __name__ == '__main__':
    cv = scene()
    print('colours:', cv.colours())
