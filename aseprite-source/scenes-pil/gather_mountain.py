"""Gather tab scene for the MOUNTAIN land: a high slate ledge under snowy peaks, a quartz cluster by a crag.

Usage: python3 -B aseprite-source/scenes-pil/gather_mountain.py   -> game/assets/img/gather/scene-mountain.png (480x270)
Drawn on the 240 x 135 grid with pixlib; the shared open satchel comes from gather_common.draw_satchel() (fixed place,
grid x 146..214, y 34..104). The find lands on the flat snow patch left of it (x 96..144, y 98..112).
Palette: Part A families (sky, dusk lavender for the range and quartz, stone, moss, umber) plus the Part D ramp recipe.
Focal prop: a big lavender quartz cluster bursting from the foot of a crag, left of centre.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import Canvas, ramp, rect, rrect, ell, poly, line, shift, W, H  # noqa: E402
from gather_common import draw_satchel, save_scene  # noqa: E402

STONE = ramp('#8b8f96', '#5b6470', '#c9c5bc')
SLATE = ramp('#5b6470', '#4a2c1a', '#8b8f96')
QUARTZ = ramp('#c3b2ea', '#7a5cc0', '#f1ece0')
QUARTZ2 = ramp('#9f8ad6', '#7a5cc0', '#c3b2ea')
PINE = ramp('#2f6a3a', '#1f3f3a', '#4f9a45')
DWOOD = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
FEATHER = ramp('#7a4a1f', '#5c3420', '#d9a35a')


def peak(cv, x, top, wl, wr, base, lit, shade, snow=None, snow_sh=None, sh=None, seed=0):
    """Faceted peak, lit left face, shaded right face, jagged snow cap."""
    m = poly([(x - wl, base), (x, top), (x + wr, base)])
    cv.fill(m, lit)
    face = poly([(x, top), (x + wr, base), (x + max(2, wr // 6), base)])
    cv.fill(m & face, shade)
    if snow:
        sh = sh if sh is not None else max(5, (base - top) // 3)
        pts = [(x - wl, top - 1)]
        n = 9
        for i in range(n + 1):
            t = i / n
            xx = round(x - wl * 0.55 + (wl * 0.55 + wr * 0.55) * t)
            yy = top + sh + (3 if (i + seed) % 2 else -1) - round(abs(t - 0.45) * sh * 0.9)
            pts.append((xx, yy))
        pts.append((x + wr, top - 1))
        cap = m & poly(pts)
        cv.fill(cap, snow)
        if snow_sh:
            cv.fill(cap & face, snow_sh)
    return m


def flat_pine(cv, x, ybot, w, h, col):
    cv.fill(rect(x, ybot - 2, x, ybot), col)
    top = ybot - 2 - h
    for i in range(3):
        ty = top + round(h * 0.26 * i)
        by = top + round(h * (0.42 + 0.29 * i))
        hw = w / 2 * (0.5 + 0.25 * i)
        cv.fill(poly([(x, ty), (x + hw, by), (x - hw, by)]), col)


def pine(cv, x, ybot, w, h, lean=0):
    """Wind-bent three-tier pine; lean shifts the upper tiers right (wind from the left)."""
    o = cv.obj()
    o.part(rect(x - 1, ybot - 6, x + 1, ybot), DWOOD, d=0)
    top = ybot - 4 - h
    for i in range(3):
        ty = top + round(h * 0.26 * i)
        by = top + round(h * (0.42 + 0.29 * i))
        hw = w / 2 * (0.5 + 0.25 * i)
        dx = lean * (2 - i)
        o.part(poly([(x + dx, ty), (x + hw + dx, by), (x - hw + dx, by)]), PINE, d=2)
    o.draw()


def prism(x, y, ln, wd, ang):
    """A six-sided crystal: base at (x, y), pointing at angle ang (degrees from straight up, + leans right)."""
    import math
    a = math.radians(ang)
    ux, uy = math.sin(a), -math.cos(a)          # along
    px, py = -uy, ux                            # across
    hw = wd / 2
    tip = ln
    shoulder = ln - wd * 0.9
    pts = [(x - px * hw, y - py * hw),
           (x - px * hw + ux * shoulder, y - py * hw + uy * shoulder),
           (x + ux * tip, y + uy * tip),
           (x + px * hw + ux * shoulder, y + py * hw + uy * shoulder),
           (x + px * hw, y + py * hw)]
    body = poly([(round(a_), round(b_)) for a_, b_ in pts])
    # the lit facet: left strip along the axis
    face = poly([(round(x - px * hw), round(y - py * hw)),
                 (round(x - px * hw + ux * shoulder), round(y - py * hw + uy * shoulder)),
                 (round(x + ux * tip), round(y + uy * tip)),
                 (round(x - px * hw * 0.1 + ux * shoulder), round(y - py * hw * 0.1 + uy * shoulder)),
                 (round(x - px * hw * 0.1), round(y - py * hw * 0.1))])
    return body, face & body


def scene():
    cv = Canvas('#a9d6ea')
    # ---- sky: thin cold air, stepped bands, calm corners
    for y, c in ((0, '#7fbcd8'), (12, '#a9d6ea'), (26, '#cde6e8')):
        cv.fill(rect(0, y, W - 1, H - 1), c)
    # a wisp of cloud and an eagle wheeling between the peaks (echoing calls: two smaller ones farther off)
    cv.fill(rrect(50, 22, 78, 24, 1), '#f1ece0')
    cv.fill(rrect(58, 20, 70, 21, 1), '#f1ece0')
    eagle = [(110, 18), (112, 16), (114, 15), (116, 16), (117, 17), (118, 16), (120, 15), (122, 16), (124, 18)]
    cv.fill(line(eagle), '#4a2c1a')
    cv.dots([(117, 18)], '#4a2c1a')
    for (x, y) in ((132, 22), (98, 24)):
        cv.fill(line([(x, y + 1), (x + 2, y), (x + 3, y + 1), (x + 4, y), (x + 6, y + 1)]), '#7a5cc0')
    # ---- far range: hazy lavender ridge, then the near snowy peaks
    for (x, t, wl, wr) in ((16, 30, 30, 30), (62, 26, 30, 30), (200, 30, 40, 34), (236, 24, 30, 30)):
        peak(cv, x, t, wl, wr, 50, '#c3b2ea', '#c3b2ea', '#f1ece0', None, sh=4, seed=x)
    for (x, t, wl, wr, s) in ((34, 22, 36, 34, 7), (100, 6, 56, 52, 12), (176, 18, 40, 44, 8)):
        peak(cv, x, t, wl, wr, 52, '#9f8ad6', '#7a5cc0', '#f1ece0', '#d9d4ee', sh=s, seed=x)
    # steep switchback path climbing the lit face of the big peak
    # a band of hazy pines at the foot of the range
    for x in range(-4, W + 8, 7):
        flat_pine(cv, x, 52 + (x * 5) % 3, 8, 7 + (x * 13) % 7, '#4f7a5a')
    # ---- ground: a high slate ledge with an alpine turf lip
    ground = rect(0, 52, W - 1, H - 1)
    cv.fill(ground, '#8b8f96')
    cv.fill(rect(0, 52, W - 1, 54), '#4f9a45')
    cv.fill(rect(0, 55, W - 1, 55), '#2f6a3a')
    for x in range(0, W, 9):                       # ragged turf edge
        cv.fill(rect(x + (x * 7) % 5, 56, x + (x * 7) % 5 + 2, 56), '#4f9a45')
    # strata cracks and pale scree flecks
    for y in range(64, H, 10):
        for x in range((y * 7) % 19, W, 27):
            cv.fill(line([(x, y), (x + 5, y), (x + 7, y + 1), (x + 11, y + 1)]), '#5b6470')
            cv.dots([(x + 14, y + 4), (x + 16, y + 3)], '#c9c5bc')
    for (x, y) in ((44, 60), (120, 62), (70, 58), (150, 118), (196, 120), (10, 132), (112, 126), (60, 130), (226, 64)):
        cv.fill(rect(x, y, x + 2, y + 1), '#5b6470')
        cv.dots([(x, y)], '#c9c5bc')
    # ---- the find lands here: a flat old snow patch on the ledge
    snow = ell(94, 97, 146, 113)
    cv.fill(snow, '#c3b2ea')
    cv.fill(ell(96, 98, 144, 111), '#d9d4ee')
    cv.fill(ell(99, 99, 141, 109), '#f1ece0')
    cv.fill(rrect(104, 101, 120, 102, 1) | rect(124, 101, 127, 101), '#fff3c8')
    # ---- left: crag with the quartz cluster bursting from its foot (focal prop)
    o = cv.obj()
    crag = poly([(0, 104), (2, 76), (6, 66), (5, 58), (10, 46), (14, 40), (18, 30), (22, 36), (26, 32), (30, 42),
                 (34, 48), (36, 60), (42, 72), (44, 88), (50, 104)])
    o.part(crag, STONE, d=3)
    o.part(poly([(18, 30), (21, 44), (19, 58), (24, 74), (22, 88), (30, 102), (44, 102), (40, 76), (34, 56),
                 (30, 42), (26, 32), (22, 36)]), SLATE, d=1, rim=False)
    o.draw()
    cv.fill(line([(10, 56), (13, 64), (11, 74), (14, 84)]), '#5b6470')
    cv.fill(line([(6, 68), (9, 72)]) | line([(3, 86), (7, 92)]), '#5b6470')
    cv.fill(line([(28, 52), (26, 62)]) | line([(34, 74), (32, 84)]), '#8b8f96')
    cv.fill(rect(5, 58, 9, 58) | rect(14, 41, 17, 41) | rect(36, 60, 39, 60), '#4f9a45')   # lichen on the ledges
    # quartz cluster: back crystals darker, front ones pale with a lit facet and a glint
    crystals = [(58, 102, 32, 8, -20, QUARTZ2), (74, 102, 28, 8, 22, QUARTZ2), (66, 104, 44, 11, 4, QUARTZ),
                (58, 105, 26, 9, -42, QUARTZ), (76, 105, 22, 8, 46, QUARTZ), (52, 106, 16, 7, -66, QUARTZ2),
                (82, 106, 12, 6, 70, QUARTZ2)]
    o = cv.obj(cx=64, cy=86)
    faces = []
    for (x, y, ln, wd, ang, rp) in crystals:
        body, face = prism(x, y, ln, wd, ang)
        o.part(body, rp, d=2, contour=True)
        faces.append((face, rp))
    o.part(ell(46, 101, 88, 110) & rect(0, 104, W, H), STONE, d=2)   # rubble the cluster grows from
    o.draw()
    for face, rp in faces:
        cv.fill(face & ~shift(face, -1, -1), rp['r'])
    cv.dots([(66, 64), (67, 63), (66, 62)], '#ffffff')
    cv.dots([(50, 86), (74, 80)], '#fff3c8')
    # an eagle feather dropped on the ledge
    o = cv.obj()
    vane = poly([(62, 122), (70, 116), (84, 111), (88, 112), (78, 118), (66, 123)])
    o.part(vane, FEATHER, d=1)
    o.part(poly([(84, 111), (88, 112), (86, 114), (82, 113)]), ramp('#f2e4c0', '#c9a96e', '#fff3c8'), d=0)
    o.draw()
    cv.fill(line([(58, 124), (87, 112)]), '#f2e4c0')
    for (x, y) in ((70, 117), (76, 116)):
        cv.dots([(x, y + 2), (x + 1, y + 2)], '#5c3420')
    # small stones and edelweiss on the left ledge
    for (x0, y0, w) in ((14, 112, 14), (30, 122, 9), (92, 76, 7)):
        o = cv.obj(); o.part(ell(x0, y0, x0 + w, y0 + w * 2 // 3), STONE, d=2); o.draw()
    for (x, y) in ((10, 106), (40, 116), (92, 120), (50, 66), (88, 64)):
        cv.dots([(x, y - 1), (x - 1, y), (x + 1, y), (x, y + 1)], '#f1ece0')
        cv.dots([(x, y)], '#e8a317')
    for (x, y) in ((22, 108), (48, 128), (8, 128), (78, 128), (60, 68), (100, 64), (130, 70), (38, 112)):
        cv.dots([(x, y), (x + 2, y), (x + 1, y - 1), (x - 1, y - 2), (x + 3, y - 2)], '#4f9a45')
    # ---- far right: a cairn and a wind-bent pine at the edge
    pine(cv, 232, 98, 18, 40, lean=2)
    for (a, b, c, d) in ((216, 112, 236, 120), (219, 105, 233, 113), (221, 99, 231, 106), (224, 94, 229, 100)):
        o = cv.obj(); o.part(ell(a, b, c, d + 2) & rect(0, 0, W, d), STONE, d=2); o.draw()
    for (x, y) in ((214, 126), (230, 130)):
        cv.dots([(x, y), (x + 2, y), (x + 1, y - 1), (x - 1, y - 2), (x + 3, y - 2)], '#4f9a45')
    # ---- the shared open satchel last
    draw_satchel(cv)
    return cv


if __name__ == '__main__':
    cv = scene()
    save_scene(cv, 'mountain')
    print('colours:', cv.colours())
