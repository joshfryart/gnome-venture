"""Shop interiors, redrawn 2026-10-27 (second pass): game/assets/img/scenes/shop-{bakery,craft,dyes,general,herbs,seeds}.png.

Usage: python3 aseprite-source/scenes-pil/shops.py [out_dir]   (default: game/assets/img/scenes)
Drawn on the 240 x 135 scene grid, written at 2x (480 x 270). The place header shows the middle 2:1 band
(about 9 grid px off the top and 6 off the bottom on phones), so nothing that matters sits in those strips:
hanging things hang from a beam that is fully in view, and the foreground reaches the bottom edge.
Each shop has its own foreground (no shared counter slab) and its props fill the wall.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import (Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, OL, W, H)  # noqa: E402

# ---- shared ramps (Part A families; shades and lights by the Part D recipe) ----
WOOD = ramp('#9a6b3f', '#7a4a1f', '#c9a96e', '#8a5a30')
DWOOD = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
CREAM = ramp('#f2e4c0', '#c9a96e', '#fff3c8')
BREAD = ramp('#e8a317', '#b07a10', '#f5cf6a', '#c98a1a')
STONE = ramp('#8b8f96', '#5b6470', '#c9c5bc')
BRICK = ramp('#e0501f', '#a8241f', '#f08a24')
PETAL = ramp('#e46a9b', '#b8457a', '#f6b8cf')
COPPER = ramp('#f08a24', '#a8241f', '#f5cf6a')
MOSS = ramp('#4f9a45', '#2f6a3a', '#7ab55c')
LEAF = ramp('#7ab55c', '#4f9a45', '#a4b86a')
WATER = ramp('#3f8fb0', '#25637d', '#a9d6ea')
DUSK = ramp('#7a5cc0', '#4e3a8a', '#c3b2ea')
EMBER = ramp('#d6322b', '#a8241f', '#f08a24')
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
THREAD = '#f5cf6a'


def ceiling(cv, wood=DWOOD, y1=8):
    """Ceiling boards plus one beam, all above the phone crop line; the beam's lower edge shows."""
    cv.fill(rect(0, 0, W - 1, y1), wood['b'])
    for x in range(0, W, 20):
        cv.fill(rect(x, 0, x, y1 - 3), wood['s'])
    o = cv.obj()
    o.part(rect(-2, y1 - 2, W + 1, y1 + 3), wood, d=2)
    o.draw()


def stitch_h(cv, x0, x1, y, col=THREAD):
    """Thread-gold dashed seam, 2 on 1 off (only on real joins)."""
    cv.dots([(x, y) for x in range(x0, x1 + 1) if (x - x0) % 3 != 2], col)


def button(cv, x, y):
    """4 x 4 cut-corner gold button with two holes."""
    cv.fill(rrect(x, y, x + 3, y + 3, 1), '#e8a317')
    cv.dots([(x + 3, y + 1), (x + 3, y + 2), (x + 1, y + 3), (x + 2, y + 3)], '#b07a10')
    cv.dots([(x + 1, y + 1), (x + 2, y + 2)], '#4a2c1a')


# =====================================================================================
def bakery():
    cv = Canvas('#f2e4c0')
    WALL, WLINE = '#f2e4c0', '#e8cf98'
    cv.fill(rect(0, 0, W - 1, H - 1), WALL)
    # tiled plaster: wide stepped blocks so the wall has texture without noise
    for y in range(14, 100, 12):
        cv.fill(rect(0, y, W - 1, y), WLINE)
        off = 0 if (y // 12) % 2 else 14
        for x in range(off, W, 28):
            cv.fill(rect(x, y, x, y + 11), WLINE)
    ceiling(cv)

    # --- oven hood + chimney (centre) ---
    o = cv.obj()
    o.part(rect(106, 0, 134, 30), STONE, d=3)
    o.part(poly([(94, 22), (146, 22), (156, 40), (84, 40)]), COPPER, d=2, contour=True)
    o.draw()
    cv.fill(rect(96, 26, 144, 26), '#f5cf6a')
    # --- oven dome ---
    o = cv.obj()
    dome = ell(78, 34, 162, 118) & rect(0, 0, W, 104)
    o.part(dome, STONE, d=4)
    o.part(rect(76, 86, 164, 104), STONE, d=3, contour=True)
    u = o.draw()
    for y in (50, 62, 74):
        cv.fill(rect(80, y, 160, y) & dome & ~rect(100, 52, 140, 104), '#5b6470')
    for y0, y1, xs in ((50, 62, (92, 118, 146)), (62, 74, (86, 106, 150)), (38, 50, (104, 126, 140))):
        for x in xs:
            cv.fill(rect(x, y0, x, y1) & dome, '#5b6470')
    # brick arch around the mouth
    o = cv.obj(outline=False)
    arch_out = ell(96, 50, 144, 106) | rect(96, 78, 144, 104)
    arch_in = ell(104, 58, 136, 104) | rect(104, 82, 136, 104)
    o.part(arch_out & ~arch_in & rect(0, 0, W, 103), BRICK, d=2)
    o.draw()
    for (x, y) in ((106, 56), (120, 52), (134, 56), (98, 70), (142, 70), (97, 86), (143, 86)):
        cv.fill(rect(x, y, x + 1, y + 1), '#a8241f')
    # the fire inside
    cv.fill(arch_in & rect(0, 0, W, 103), '#3d2a1c')
    cv.fill(arch_in & rect(0, 92, W, 103), '#a8241f')
    for (x0, x1, top, col) in ((106, 116, 80, '#d6322b'), (112, 128, 72, '#f08a24'), (124, 134, 82, '#d6322b'),
                               (115, 125, 80, '#e8a317'), (118, 122, 86, '#f5cf6a')):
        cv.fill(poly([(x0, 94), (x1, 94), ((x0 + x1) // 2, top)]), col)
    for x in range(106, 136, 5):
        cv.fill(rect(x, 95, x + 2, 97), '#f5cf6a')

    # --- left: tall bread rack, three full shelves ---
    cv.fill(rect(11, 16, 65, 99), '#c9a96e')
    o = cv.obj()
    o.part(rect(6, 14, 10, 104), WOOD, d=2)
    o.part(rect(66, 14, 70, 104), WOOD, d=2)
    for y in (36, 62, 88):
        o.part(rect(4, y, 72, y + 3), WOOD, d=1, contour=True)
    o.draw()
    o = cv.obj(); o.part(rect(4, 12, 72, 15), WOOD, d=1); o.draw()
    for x in (12, 30, 48):                                   # round boules
        o = cv.obj(); o.part(ell(x, 21, x + 16, 36), BREAD, d=3); u = o.draw()
        cv.fill(rect(x + 5, 25, x + 11, 25), '#b07a10'); cv.fill(rect(x + 4, 29, x + 12, 29), '#b07a10')
    for x in (11, 39):                                       # long loaves
        o = cv.obj(); o.part(ell(x, 48, x + 26, 62), BREAD, d=3); o.draw()
        for k in range(4):
            cv.fill(line([(x + 5 + k * 5, 58), (x + 8 + k * 5, 52)]), '#b07a10')
    for x in range(12, 64, 9):                               # buns
        o = cv.obj(); o.part(ell(x, 79, x + 8, 88), ramp('#f08a24', '#b07a10', '#f5cf6a'), d=2); o.draw()
        cv.dots([(x + 3, 82), (x + 4, 82)], '#f5cf6a')

    # --- right: copper pans on a rail (rail fully in view), cake shelf ---
    o = cv.obj()
    o.part(rect(172, 14, 234, 16), DWOOD, d=1)
    o.draw()
    for (x, r) in ((176, 9), (198, 11), (222, 8)):
        cv.fill(rect(x + r, 17, x + r, 21), '#4a2c1a')
        o = cv.obj()
        o.part(rect(x + r - 2, 19, x + r + 2, 25), COPPER, d=1)
        o.part(ell(x, 24, x + 2 * r, 24 + 2 * r), COPPER, d=3, contour=True)
        o.draw()
        cv.fill(ell(x + 4, 28, x + 2 * r - 4, 20 + 2 * r), '#e0501f')
        cv.dots([(x + 4, 27), (x + 5, 26)], '#ffc27a')
    o = cv.obj()
    o.part(rect(168, 74, 236, 77), WOOD, d=1)
    o.part(poly([(174, 78), (180, 78), (180, 86)]), WOOD, d=0)
    o.part(poly([(224, 78), (230, 78), (224, 86)]), WOOD, d=0)
    o.draw()
    o = cv.obj()                                             # two-tier cake on a plate
    o.part(rect(170, 71, 200, 73), STONE, d=1)
    o.part(rrect(173, 59, 197, 70, 2), CREAM, d=3, contour=True)
    o.part(rrect(178, 50, 192, 58, 2), CREAM, d=2, contour=True)
    o.part(rect(173, 59, 197, 61) | rect(178, 50, 192, 52), PETAL, d=1)
    o.draw()
    for x in (176, 181, 186, 191, 195):
        cv.fill(rect(x, 62, x, 64), '#e46a9b')
    o = cv.obj(); o.part(ell(183, 45, 187, 49), EMBER, d=1); o.draw()
    o = cv.obj()                                             # cookie jar
    o.part(rect(210, 50, 226, 53), WOOD, d=1)
    o.part(rrect(206, 54, 230, 73, 3), ramp('#a9d6ea', '#3f8fb0', '#f2e4c0'), d=2, contour=True)
    o.draw()
    for (x, y) in ((209, 62), (217, 58), (221, 65), (210, 67)):
        o = cv.obj(); o.part(ell(x, y, x + 7, y + 6), BREAD, d=2); o.draw()
        cv.dots([(x + 3, y + 2), (x + 5, y + 4)], '#7a4a1f')
    cv.fill(rect(208, 56, 209, 60), '#f2e4c0')

    # --- foreground counter: wood top and panelled front, a checked runner with a stitched hem in the middle ---
    o = cv.obj()
    o.part(rect(-2, 100, W + 1, 106), WOOD, d=2)
    o.part(rect(-2, 107, W + 1, H + 1), DWOOD, d=0, contour=True)
    o.draw()
    for x in range(0, W, 30):
        cv.fill(rect(x + 3, 112, x + 26, H - 1) & ~rect(x + 5, 114, x + 24, H - 1), '#5c3420')
        cv.fill(rect(x + 5, 114, x + 5, H - 1) | rect(x + 5, 114, x + 24, 114), '#9a6b3f')
    run = rect(72, 101, 168, 120)
    for x in range(72, 169, 8):                    # scalloped hem
        run |= ell(x, 117, x + 7, 125)
    o = cv.obj(); o.part(run, ramp('#f2e4c0', None), d=0); o.draw()
    for x in range(72, 169, 8):
        cv.fill(rect(x, 101, x + 3, 125) & run, '#f6b8cf')
    for y in range(103, 126, 8):
        cv.fill(rect(72, y, 168, y + 3) & run, '#f6b8cf')
        for x in range(72, 169, 8):
            cv.fill(rect(x, y, x + 3, y + 3) & run, '#e46a9b')
    stitch_h(cv, 73, 167, 115, '#a8241f')
    # baguette basket (left)
    for (xb, xt, yt) in ((28, 22, 70), (40, 42, 62), (52, 60, 68)):
        o = cv.obj(); o.part(line([(xb, 96), (xt, yt)], 7) | ell(xt - 3, yt - 3, xt + 3, yt + 3), BREAD, d=2); o.draw()
        for k in (0.3, 0.55, 0.8):
            px, py = round(xb + (xt - xb) * k), round(96 + (yt - 96) * k)
            cv.fill(line([(px - 2, py + 1), (px + 1, py - 1)]), '#b07a10')
    o = cv.obj()
    o.part(poly([(16, 86), (68, 86), (62, 104), (22, 104)]), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=2)
    o.draw()
    for y in (90, 95, 100):
        cv.fill(rect(18, y, 66, y) & poly([(16, 86), (68, 86), (62, 104), (22, 104)]), '#9a6b3f')
    # tray of buns (centre, in front of the oven)
    o = cv.obj(); o.part(rect(90, 96, 150, 100), STONE, d=1); o.draw()
    for x in range(92, 144, 11):
        o = cv.obj(); o.part(ell(x, 85, x + 11, 97), BREAD, d=3); o.draw()
        cv.dots([(x + 4, 88), (x + 5, 88), (x + 6, 88)], '#f5cf6a')
    # flour sack (right) with a real seam
    o = cv.obj()
    o.part(poly([(204, 104), (238, 104), (236, 84), (230, 78), (212, 78), (206, 84)]), CREAM, d=3)
    o.part(rect(211, 76, 231, 80), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=1, contour=True)
    o.draw()
    stitch_h(cv, 210, 232, 82, '#b07a10')
    cv.fill(ell(215, 87, 227, 99), '#e8cf98')
    cv.fill(ell(218, 90, 224, 96), '#e8a317')
    # big round loaf on a board
    o = cv.obj(); o.part(rect(156, 98, 196, 101), WOOD, d=1); o.draw()
    o = cv.obj(); o.part(ell(160, 76, 192, 100), BREAD, d=4); o.draw()
    cv.fill(line([(168, 84), (184, 92)]), '#b07a10'); cv.fill(line([(168, 92), (184, 84)]), '#b07a10')
    cv.dots([(166, 80), (167, 80), (166, 81)], '#ffc27a')
    return cv


# =====================================================================================
def craft():
    cv = Canvas('#c3b2ea')
    cv.fill(rect(0, 0, W - 1, H - 1), '#c3b2ea')
    for x in range(8, W, 16):                                  # wall boards
        cv.fill(rect(x, 0, x, H - 1), '#a48fd6')
    ceiling(cv)

    # --- left: pegboard with big tools ---
    o = cv.obj()
    o.part(rect(4, 14, 78, 74), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=2)
    o.draw()
    for y in range(19, 72, 7):
        for x in range(9, 76, 7):
            cv.dots([(x, y)], '#9a6b3f')
    # hammer
    o = cv.obj(); o.part(rect(14, 28, 18, 64), WOOD, d=1); o.part(rrect(8, 22, 24, 30, 1), STONE, d=2, contour=True); o.draw()
    cv.dots([(10, 23), (11, 23)], '#f2e4c0')
    # saw
    o = cv.obj()
    o.part(poly([(30, 24), (52, 24), (52, 60), (36, 66), (30, 60)]), STONE, d=2)
    o.part(rrect(30, 18, 54, 28, 2), EMBER, d=2, contour=True)
    o.draw()
    cv.fill(rect(36, 21, 47, 24), '#4a2c1a')
    for y in range(32, 62, 4):
        cv.dots([(52, y), (53, y + 1)], '#5b6470')
    # scissors
    o = cv.obj()
    o.part(line([(62, 30), (70, 62)], 3) | line([(70, 30), (62, 62)], 3), STONE, d=1)
    o.part(ell(56, 56, 66, 68) | ell(66, 56, 76, 68), WATER, d=2, contour=True)
    o.draw()
    cv.fill(ell(59, 59, 63, 65) | ell(69, 59, 73, 65), '#c9a96e')

    # --- centre: quilting frame with a quilt in progress (real seams + button) ---
    o = cv.obj()
    o.part(rect(84, 12, 90, 100), WOOD, d=2)
    o.part(rect(150, 12, 156, 100), WOOD, d=2)
    o.part(rect(80, 14, 160, 19), DWOOD, d=2, contour=True)
    o.draw()
    cols = [[PETAL, GOLD, MOSS, WATER], [WATER, CREAM, PETAL, GOLD], [GOLD, MOSS, WATER, PETAL], [MOSS, PETAL, GOLD, CREAM]]
    o = cv.obj()
    for r in range(4):
        for c in range(4):
            o.part(rect(94 + c * 13, 22 + r * 15, 94 + c * 13 + 12, 22 + r * 15 + 14), cols[r][c], d=2)
    o.draw()
    for r in range(1, 4):
        stitch_h(cv, 94, 145, 22 + r * 15 - 1 + 1)
    for c in range(1, 4):
        x = 94 + c * 13
        cv.dots([(x, y) for y in range(22, 82) if (y - 22) % 3 != 2], THREAD)
    for (x, y) in ((104, 33), (130, 48), (117, 63)):
        cv.dots([(x, y), (x + 1, y), (x, y + 1), (x + 1, y + 1)], '#f2e4c0')
    button(cv, 118, 34)
    # needle + thread hanging off the quilt
    cv.fill(line([(146, 66), (148, 90)]), '#f5cf6a')
    o = cv.obj(); o.part(rect(146, 88, 149, 94), STONE, d=0); o.draw()

    # --- right: cubbies of yarn balls ---
    o = cv.obj()
    o.part(rect(164, 14, 236, 100), DWOOD, d=2)
    o.draw()
    for (x0, y0) in [(168 + c * 23, 18 + r * 27) for r in range(3) for c in range(3)]:
        cv.fill(rect(x0, y0, x0 + 19, y0 + 22), '#5c3420')
        cv.fill(rect(x0, y0, x0 + 19, y0 + 1), '#3d2a1c')
    yarns = [PETAL, GOLD, WATER, MOSS, EMBER, DUSK, GOLD, PETAL, CREAM]
    for i, (x0, y0) in enumerate([(168 + c * 23, 18 + r * 27) for r in range(3) for c in range(3)]):
        o = cv.obj(); o.part(ell(x0 + 2, y0 + 6, x0 + 17, y0 + 22), yarns[i], d=3); o.draw()
        cv.fill(line([(x0 + 5, y0 + 10), (x0 + 13, y0 + 18)]), yarns[i]['s'])
        cv.fill(line([(x0 + 4, y0 + 15), (x0 + 9, y0 + 20)]), yarns[i]['s'])
        cv.dots([(x0 + 6, y0 + 8), (x0 + 7, y0 + 8)], yarns[i]['r'])

    # --- foreground left: workbench with a birdhouse being painted ---
    o = cv.obj()
    o.part(rect(-2, 96, 112, 102), WOOD, d=2)
    o.part(rect(4, 103, 108, H + 1), DWOOD, d=0, contour=True)
    o.draw()
    for (x0, x1) in ((10, 52), (58, 102)):
        cv.fill(rect(x0, 108, x1, 124) & ~rect(x0 + 2, 110, x1 - 2, 122), '#5c3420')
        o = cv.obj(); o.part(rect((x0 + x1) // 2 - 4, 114, (x0 + x1) // 2 + 4, 117), GOLD, d=1); o.draw()
    o = cv.obj()                                               # birdhouse
    o.part(rect(22, 66, 50, 95), ramp('#a4b86a', '#7ab55c', '#f2e4c0'), d=3)
    o.part(poly([(16, 68), (36, 50), (56, 68)]), EMBER, d=2, contour=True)
    o.draw()
    cv.fill(ell(31, 74, 41, 84), '#3d2a1c')
    o = cv.obj(); o.part(rect(34, 86, 38, 89), WOOD, d=0); o.draw()
    o = cv.obj()                                               # paint pot + brush
    o.part(rrect(62, 80, 80, 95, 2), STONE, d=2)
    o.part(rect(62, 80, 80, 83), WATER, d=0, contour=True)
    o.draw()
    o = cv.obj(); o.part(line([(74, 82), (86, 62)], 3), WOOD, d=0); o.part(rect(84, 58, 89, 63), PETAL, d=0, contour=True); o.draw()
    o = cv.obj()                                               # spool
    o.part(rect(92, 80, 104, 83) | rect(92, 92, 104, 95), WOOD, d=1)
    o.part(rect(94, 84, 102, 91), PETAL, d=2, contour=True)
    o.draw()

    # --- foreground centre: stacked fabric bolts ---
    for i, (rp, y) in enumerate(((WATER, 122), (GOLD, 112), (PETAL, 102))):
        o = cv.obj()
        o.part(rrect(110 + i * 3, y, 166 - i * 2, y + 11, 3), rp, d=3)
        o.part(ell(108 + i * 3, y, 120 + i * 3, y + 11), rp, d=2, contour=True)
        o.draw()
        cv.fill(ell(111 + i * 3, y + 3, 117 + i * 3, y + 8), rp['s'])

    # --- foreground right: wicker basket of yarn with needles ---
    for (x, rp) in ((178, DUSK), (196, GOLD), (214, MOSS), (186, PETAL), (206, WATER)):
        y = 90 if x in (178, 196, 214) else 84
        o = cv.obj(); o.part(ell(x, y, x + 18, y + 18), rp, d=3); o.draw()
        cv.fill(line([(x + 4, y + 6), (x + 12, y + 14)]), rp['s'])
    o = cv.obj(); o.part(line([(196, 96), (214, 66)], 2) | line([(204, 96), (226, 70)], 2), STONE, d=0); o.draw()
    o = cv.obj()
    o.part(poly([(168, 102), (240, 102), (234, H + 1), (174, H + 1)]), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=3)
    o.part(rect(166, 100, 242, 105), WOOD, d=1, contour=True)
    o.draw()
    for y in range(110, H, 6):
        cv.fill(rect(172, y, 236, y) & poly([(168, 102), (240, 102), (234, H + 1), (174, H + 1)]), '#9a6b3f')
    for x in range(178, 234, 8):
        cv.fill(rect(x, 106, x, H - 1) & poly([(168, 102), (240, 102), (234, H + 1), (174, H + 1)]), '#9a6b3f')
    cv.remap({'#c9c5bc': '#f2e4c0', '#fff3c8': '#f2e4c0'})
    return cv


def flower(cv, x, y, rp, r=3):
    """A round bloom: petals in a plus, gold centre."""
    o = cv.obj()
    o.part(ell(x - r, y - r - 1, x + r, y + r - 1) | ell(x - r - 1, y - r, x + r + 1, y + r - 2), rp, d=1)
    o.draw()
    cv.fill(rect(x - 1, y - 2, x, y - 1), '#e8a317')


def herbs():
    cv = Canvas('#a9d6ea')
    # greenhouse wall: big panes, a hedge outside, wooden mullions
    cv.fill(rect(0, 0, W - 1, H - 1), '#a9d6ea')
    cv.fill(rect(0, 64, W - 1, 100), '#7ab55c')
    for x in range(0, W, 14):
        cv.fill(ell(x - 4, 56, x + 12, 72), '#7ab55c')
    cv.fill(rect(0, 80, W - 1, 100), '#4f9a45')
    for x in range(6, W, 18):
        cv.fill(ell(x - 4, 74, x + 10, 86), '#4f9a45')
    o = cv.obj()
    for x in range(0, W + 1, 40):
        o.part(rect(x - 2, 10, x + 2, 100), WOOD, d=1)
    o.part(rect(-2, 48, W + 1, 51), WOOD, d=1)
    o.draw()
    for x in range(8, W, 40):
        cv.fill(line([(x + 4, 14), (x + 12, 22)]), '#f2e4c0')
        cv.fill(line([(x + 4, 20), (x + 8, 24)]), '#f2e4c0')
    ceiling(cv)

    # --- drying rack with herb bundles (rack fully in view) ---
    o = cv.obj(); o.part(rect(14, 14, 156, 17), DWOOD, d=1); o.draw()
    for x in (14, 156):
        cv.fill(rect(x, 9, x + 1, 13), '#4a2c1a')
    bundles = [(22, MOSS), (44, DUSK), (66, LEAF), (88, ramp('#f2e4c0', '#c9a96e', '#fff3c8')), (110, MOSS), (132, DUSK)]
    for i, (x, rp) in enumerate(bundles):
        cv.fill(rect(x + 6, 18, x + 6, 21), '#4a2c1a')
        o = cv.obj()
        for (lx, ly, lw, lh) in ((x - 2, 30, 7, 14), (x + 8, 30, 7, 14), (x + 2, 26, 8, 22), (x - 4, 38, 7, 12), (x + 11, 38, 7, 12), (x + 3, 40, 6, 12)):
            o.part(ell(lx, ly, lx + lw, ly + lh), rp, d=2)
        o.part(rect(x + 2, 20, x + 10, 27), WOOD, d=1, contour=True)
        o.draw()
        stitch_h(cv, x + 2, x + 10, 24)
        for k in range(3):
            cv.fill(line([(x + 1 + k * 4, 32 + (k % 2) * 4), (x + 1 + k * 4, 46)]), rp['s'])
        if rp is DUSK:
            cv.dots([(x, 46), (x + 4, 48), (x + 8, 47), (x + 12, 45), (x + 2, 42), (x + 10, 41)], '#c3b2ea')
        if rp['b'] == '#f2e4c0':
            for (fx, fy) in ((x + 1, 44), (x + 6, 47), (x + 11, 44), (x + 4, 39)):
                cv.dots([(fx, fy), (fx + 1, fy)], '#e8a317')

    # --- right: apothecary shelves of jars ---
    o = cv.obj()
    o.part(rect(166, 14, 238, 100), DWOOD, d=2)
    o.draw()
    cv.fill(rect(170, 18, 234, 98), '#5c3420')
    o = cv.obj()
    for y in (44, 72, 98):
        o.part(rect(168, y, 236, y + 3), WOOD, d=1)
    o.draw()
    jars = [(172, 20, PETAL), (192, 24, GOLD), (212, 18, MOSS), (172, 48, DUSK), (194, 52, EMBER), (214, 50, WATER), (174, 76, LEAF), (196, 80, PETAL), (216, 76, GOLD)]
    for (x, y, rp) in jars:
        hgt = 44 - y if y < 40 else (72 - y if y < 70 else 98 - y)
        o = cv.obj()
        o.part(rrect(x, y + 5, x + 17, y + hgt - 1, 3), CREAM, d=2)
        o.part(rect(x + 4, y, x + 13, y + 5), WOOD, d=1, contour=True)
        o.draw()
        cv.fill(rrect(x + 2, y + 11, x + 15, y + hgt - 3, 2), rp['b'])
        cv.fill(rect(x + 2, y + hgt - 5, x + 15, y + hgt - 3) & rrect(x + 2, y + 11, x + 15, y + hgt - 3, 2), rp['s'])
        cv.fill(rect(x + 3, y + 8, x + 4, y + 12), '#fff3c8')

    # --- left: a big leafy plant in a terracotta pot ---
    leaves = [((4, 30), (26, 58)), ((22, 22), (40, 58)), ((-4, 56), (24, 80)), ((26, 48), (52, 76)), ((10, 40), (30, 70))]
    for (a, b) in leaves:
        o = cv.obj(); o.part(ell(a[0], a[1], b[0], b[1]), MOSS, d=3); o.draw()
        cx = (a[0] + b[0]) // 2
        cv.fill(line([(cx, a[1] + 4), (cx, b[1] - 3)]), '#2f6a3a')
    o = cv.obj()
    o.part(poly([(2, 96), (48, 96), (42, H + 1), (8, H + 1)]), BRICK, d=3)
    o.part(rect(0, 90, 50, 97), BRICK, d=2, contour=True)
    o.draw()

    # --- potting bench (centre and right) ---
    o = cv.obj()
    o.part(rect(54, 100, W + 1, 105), WOOD, d=2)
    o.part(rect(58, 106, 64, H + 1) | rect(228, 106, 234, H + 1), WOOD, d=1, contour=True)
    o.draw()
    cv.fill(rect(65, 106, 227, H - 1), '#3d2a1c')
    for x in (72, 160, 196):                                        # pots under the bench
        for k, yy in enumerate((112, 120)):
            o = cv.obj(); o.part(poly([(x, yy), (x + 20, yy), (x + 17, H + 1), (x + 3, H + 1)]) | rect(x - 1, yy - 2, x + 21, yy + 1), BRICK, d=2); o.draw()
    o = cv.obj()                                                    # soil sack with a seam
    o.part(poly([(104, H + 1), (148, H + 1), (146, 116), (138, 108), (114, 108), (106, 116)]), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=3)
    o.draw()
    stitch_h(cv, 112, 140, 112, '#7a4a1f')
    cv.fill(ell(118, 118, 134, 130), '#7a4a1f')
    cv.fill(ell(122, 120, 130, 126), '#4f9a45')
    # mortar and pestle
    o = cv.obj()
    o.part(line([(84, 90), (96, 66)], 5), STONE, d=1)
    o.part(poly([(68, 80), (100, 80), (94, 99), (74, 99)]) | rect(66, 78, 102, 82), STONE, d=3, contour=True)
    o.draw()
    cv.fill(rect(70, 79, 98, 80), '#4f9a45')
    # vase with a bouquet (florist)
    stems = [(120, 60), (128, 52), (136, 58), (124, 70), (134, 70), (143, 64), (116, 72)]
    for (x, y) in stems:
        cv.fill(line([(130, 84), (x, y)], 1), '#2f6a3a')
    o = cv.obj(); o.part(ell(112, 66, 124, 74), MOSS, d=1); o.part(ell(138, 64, 150, 72), MOSS, d=1); o.draw()
    for (x, y), rp in zip(stems, [PETAL, GOLD, PETAL, DUSK, EMBER, GOLD, PETAL]):
        flower(cv, x, y, rp, 4)
    o = cv.obj()
    o.part(poly([(122, 80), (138, 80), (142, 90), (138, 99), (122, 99), (118, 90)]), WATER, d=3)
    o.part(rect(121, 76, 139, 80), WATER, d=1, contour=True)
    o.draw()
    cv.fill(rect(124, 84, 125, 90), '#a9d6ea')
    # seedling pots
    for x in (154, 172):
        o = cv.obj()
        o.part(ell(x + 2, 74, x + 9, 84) | ell(x + 7, 72, x + 15, 82), LEAF, d=2)
        o.part(poly([(x, 86), (x + 16, 86), (x + 14, 99), (x + 2, 99)]) | rect(x - 1, 84, x + 17, 87), BRICK, d=2, contour=True)
        o.draw()
    # copper watering can
    o = cv.obj()
    o.part(poly([(220, 80), (236, 66), (238, 69), (224, 86)]), COPPER, d=1)
    o.part(ell(196, 70, 214, 82), COPPER, d=1)
    o.part(rrect(192, 78, 222, 99, 3), COPPER, d=3, contour=True)
    o.draw()
    cv.fill(ell(200, 74, 210, 79), '#3d2a1c')
    cv.dots([(195, 81), (196, 81), (195, 82)], '#ffc27a')
    cv.remap({'#f6b8cf': '#f2e4c0', '#c9c5bc': '#f2e4c0', '#ffc27a': '#f5cf6a'})
    return cv


def seeds():
    cv = Canvas('#c9a96e')
    cv.fill(rect(0, 0, W - 1, H - 1), '#c9a96e')
    for x in range(6, W, 12):                                  # wall panelling
        cv.fill(rect(x, 0, x, H - 1), '#b08a55')
    cv.fill(rect(0, 60, W - 1, 61), '#9a6b3f')
    ceiling(cv)

    # --- left: window onto the garden, with shutters ---
    o = cv.obj()
    o.part(rect(10, 16, 62, 56), WOOD, d=2)
    o.draw()
    cv.fill(rect(14, 20, 58, 52), '#a9d6ea')
    cv.fill(rect(14, 40, 58, 52), '#7ab55c')
    for x in range(16, 58, 7):
        cv.fill(ell(x, 34, x + 5, 40), '#4f9a45')
        cv.fill(rect(x + 2, 44, x + 3, 48), '#4f9a45')
    cv.fill(ell(44, 23, 52, 31), '#f5cf6a')
    o = cv.obj(); o.part(rect(35, 20, 37, 52) | rect(14, 35, 58, 37), WOOD, d=0); o.draw()
    for (x0, x1) in ((0, 9), (63, 72)):
        o = cv.obj(); o.part(rect(x0, 14, x1, 58), MOSS, d=2); o.draw()
        for y in range(19, 56, 6):
            cv.fill(rect(x0 + 2, y, x1 - 2, y), '#2f6a3a')
    o = cv.obj(); o.part(rect(6, 56, 66, 60), WOOD, d=1); o.draw()

    # --- left lower: rack of seed packets ---
    o = cv.obj()
    o.part(rect(6, 64, 72, 100), DWOOD, d=2)
    o.draw()
    cv.fill(rect(9, 66, 69, 98), '#5c3420')
    pk = [(PETAL, EMBER), (GOLD, MOSS), (WATER, GOLD), (MOSS, PETAL), (EMBER, GOLD), (DUSK, MOSS), (GOLD, EMBER), (MOSS, DUSK)]
    for i in range(8):
        r, c = divmod(i, 4)
        x, y = 10 + c * 15, 67 + r * 16
        band, fruit = pk[i]
        o = cv.obj()
        o.part(rect(x, y, x + 12, y + 14), CREAM, d=1)
        o.part(rect(x, y, x + 12, y + 3), band, d=0, contour=True)
        o.draw()
        cv.fill(ell(x + 3, y + 6, x + 9, y + 12), fruit['b'])
        cv.dots([(x + 4, y + 7)], fruit['r'])
        cv.fill(rect(x + 6, y + 4, x + 7, y + 6), '#4f9a45')

    # --- centre: the big seed-drawer cabinet; one drawer pulled out ---
    o = cv.obj()
    o.part(rect(78, 12, 202, 102), DWOOD, d=3)
    o.part(rect(76, 10, 204, 15), WOOD, d=1, contour=True)
    o.draw()
    labels = ['#e8a317', '#4f9a45', '#d6322b', '#e46a9b', '#7a5cc0', '#3f8fb0',
              '#f2e4c0', '#d6322b', '#4f9a45', '#e8a317', '#3f8fb0', '#e46a9b',
              '#7a5cc0', '#e8a317', '#f2e4c0', '#4f9a45', '#d6322b', '#e8a317']
    k = 0
    for r in range(4):
        for c in range(6):
            x, y = 82 + c * 20, 18 + r * 21
            if (r, c) == (1, 4):
                continue
            o = cv.obj(outline=False)
            o.part(rect(x, y, x + 17, y + 18), WOOD, d=2)
            o.draw()
            cv.fill(rect(x - 1, y - 1, x + 18, y - 1) | rect(x - 1, y - 1, x - 1, y + 19), '#3d2a1c')
            cv.fill(rect(x + 4, y + 3, x + 13, y + 7), '#f2e4c0')
            cv.fill(rect(x + 6, y + 4, x + 11, y + 6), labels[k % len(labels)])
            cv.fill(rrect(x + 7, y + 11, x + 10, y + 14, 1), '#e8a317')
            cv.dots([(x + 10, y + 13), (x + 9, y + 14)], '#b07a10')
            k += 1
    x, y = 162, 39                                             # the open drawer, full of beans
    cv.fill(rect(x - 1, y - 1, x + 18, y + 19), '#3d2a1c')
    o = cv.obj()
    o.part(rect(x - 4, y + 6, x + 21, y + 24), WOOD, d=2)
    o.part(ell(x - 2, y - 2, x + 19, y + 12) & rect(0, 0, W, y + 8), ramp('#e8a317', '#b07a10', '#f5cf6a'), d=2)
    o.draw()
    for (dx, dy) in ((2, 2), (7, 0), (12, 3), (4, 5), (10, 6), (15, 5), (6, 3)):
        cv.dots([(x + dx, y + dy), (x + dx + 1, y + dy)], '#b07a10')
    cv.fill(rrect(x + 7, y + 15, x + 12, y + 18, 1), '#e8a317')

    # --- right: garden tools on pegs ---
    o = cv.obj(); o.part(rect(208, 16, 238, 19), WOOD, d=1); o.draw()
    o = cv.obj()                                               # hoe
    o.part(rect(212, 20, 215, 96), WOOD, d=1)
    o.part(rect(208, 90, 222, 100), STONE, d=2, contour=True)
    o.draw()
    o = cv.obj()                                               # hand rake
    o.part(rect(224, 20, 227, 54), WOOD, d=1)
    o.part(rect(218, 54, 234, 58), STONE, d=1, contour=True)
    o.part(rect(218, 58, 220, 66) | rect(224, 58, 226, 66) | rect(231, 58, 233, 66), STONE, d=0)
    o.draw()
    o = cv.obj()                                               # trowel
    o.part(rect(225, 72, 229, 82), EMBER, d=1)
    o.part(poly([(220, 82), (234, 82), (232, 96), (227, 100), (222, 96)]), STONE, d=2, contour=True)
    o.draw()

    # --- foreground: three open seed sacks with a scoop ---
    fills = [(GOLD, '#f5cf6a', '#b07a10'), (ramp('#9a6b3f', '#7a4a1f', '#c9a96e'), '#c9a96e', '#5c3420'), (MOSS, '#7ab55c', '#2f6a3a')]
    for i, (x, fl) in enumerate(zip((12, 84, 156), fills)):
        rp, lt, dk = fl
        t = (2, -4, 4)[i]
        burlap = ramp('#c9a96e', '#9a6b3f', '#f2e4c0')
        o = cv.obj()
        o.part(poly([(x + 2, H + 1), (x + 64, H + 1), (x + 69, 122), (x + 66, 108 + t), (x + 58, 102 + t), (x + 8, 102 + t), (x, 108 + t), (x - 3, 122)]), burlap, d=3)
        o.part(rrect(x + 1, 96 + t, x + 65, 106 + t, 3), burlap, d=2, contour=True)
        o.part(ell(x + 5, 88 + t, x + 61, 104 + t) & rect(0, 0, W, 101 + t), rp, d=2, contour=True)
        o.draw()
        for (dx, dy) in ((14, 92), (24, 90), (34, 93), (44, 91), (52, 95), (19, 96), (30, 97), (40, 96), (12, 98), (48, 98)):
            cv.dots([(x + dx, dy + t), (x + dx + 1, dy + t)], dk)
            cv.dots([(x + dx - 1, dy - 1 + t)], lt)
        stitch_h(cv, x + 4, x + 62, 109 + t, '#7a4a1f')
        cv.fill(line([(x + 10, 114 + t), (x + 6, H - 1)]), '#9a6b3f')
        cv.fill(line([(x + 56, 114 + t), (x + 60, H - 1)]), '#9a6b3f')
        cv.fill(rect(x + 22, 117 + t, x + 44, 129 + t), '#e8cf98')
        cv.fill(ell(x + 28, 119 + t, x + 38, 127 + t), rp['b'])
    o = cv.obj()                                               # scoop
    o.part(line([(132, 70), (124, 86)], 4), WOOD, d=1)
    o.part(poly([(110, 84), (132, 84), (130, 94), (112, 94)]), STONE, d=2, contour=True)
    o.draw()
    # seedling tray on a crate (far right)
    o = cv.obj()
    o.part(rect(222, 108, 242, H + 1), WOOD, d=2)
    o.draw()
    cv.fill(rect(222, 116, 240, 116) | rect(222, 126, 240, 126), '#7a4a1f')
    for x in (224, 232):
        o = cv.obj(); o.part(ell(x, 98, x + 6, 104) | ell(x + 3, 96, x + 9, 102), LEAF, d=1); o.draw()
        cv.fill(rect(x + 3, 103, x + 4, 107), '#4f9a45')
    cv.remap({'#fff3c8': '#f2e4c0', '#c9c5bc': '#f2e4c0', '#c3b2ea': '#f2e4c0', '#f6b8cf': '#f2e4c0'})
    return cv


def barrel(cv, x0, y0, x1, y1):
    o = cv.obj()
    body = ell(x0, y0, x1, y1 + 6) & rect(0, y0 + 2, W, y1) | rect(x0 + 3, y0 + 2, x1 - 3, y1)
    o.part(body, WOOD, d=3)
    o.part(ell(x0 + 2, y0 - 2, x1 - 2, y0 + 6), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=1, contour=True)
    o.draw()
    for yy in (y0 + 10, y1 - 8):
        cv.fill(rect(x0, yy, x1, yy + 2) & body, '#5b6470')
    for xx in range(x0 + 7, x1 - 3, 7):
        cv.fill(rect(xx, y0 + 6, xx, y1) & body & ~rect(0, y0 + 10, W, y0 + 12) & ~rect(0, y1 - 8, W, y1 - 6), '#7a4a1f')


def general():
    cv = Canvas('#a4b86a')
    cv.fill(rect(0, 0, W - 1, H - 1), '#a4b86a')
    for x in range(4, W, 10):                                 # striped wallpaper
        cv.fill(rect(x, 0, x + 1, H - 1), '#93a85c')
    ceiling(cv)

    # --- back: a wall of shelves with all sorts ---
    o = cv.obj()
    o.part(rect(56, 12, 204, 100), DWOOD, d=3)
    o.draw()
    cv.fill(rect(60, 16, 200, 98), '#5c3420')
    o = cv.obj()
    for y in (40, 68, 96):
        o.part(rect(58, y, 202, y + 3), WOOD, d=1)
    o.draw()
    # top shelf: tins and jars
    for i, rp in enumerate((EMBER, WATER, GOLD, MOSS, PETAL)):
        x = 62 + i * 13
        o = cv.obj(); o.part(rect(x, 24, x + 10, 39), rp, d=2); o.part(rect(x, 24, x + 10, 26), STONE, d=0, contour=True); o.draw()
        cv.fill(rect(x + 2, 29, x + 8, 34), '#f2e4c0')
    for i, rp in enumerate((GOLD, PETAL, MOSS)):
        x = 132 + i * 22
        o = cv.obj()
        o.part(rrect(x, 22, x + 18, 39, 3), ramp('#a9d6ea', '#3f8fb0', '#f2e4c0'), d=2)
        o.part(rect(x + 4, 18, x + 14, 22), WOOD, d=1, contour=True)
        o.draw()
        for (dx, dy) in ((3, 30), (9, 27), (12, 33), (5, 35), (14, 28)):
            cv.fill(ell(x + dx - 2, dy - 2, x + dx + 2, dy + 2), rp['b'])
    # middle shelf: bottles, a coil of rope, candles
    for i, rp in enumerate((MOSS, WATER, EMBER, MOSS)):
        x = 62 + i * 11
        o = cv.obj()
        o.part(rrect(x, 52, x + 9, 67, 2), rp, d=2)
        o.part(rect(x + 3, 44, x + 6, 52), rp, d=1, contour=True)
        o.part(rect(x + 3, 42, x + 6, 44), WOOD, d=0, contour=True)
        o.draw()
        cv.fill(rect(x + 2, 56, x + 7, 60), '#f2e4c0')
    o = cv.obj(); o.part(ell(110, 46, 140, 67), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=3); o.draw()
    for r in (4, 8, 12):
        cv.fill(ell(125 - r, 56 - r * 0.6, 125 + r, 57 + r * 0.6) & ~ell(126 - r, 57 - r * 0.6, 124 + r, 56 + r * 0.6), '#9a6b3f')
    for i in range(4):
        x = 150 + i * 12
        o = cv.obj(); o.part(rect(x, 50 - (i % 2) * 4, x + 6, 67), CREAM, d=2); o.draw()
        cv.fill(rect(x + 3, 46 - (i % 2) * 4, x + 3, 49 - (i % 2) * 4), '#3d2a1c')
    # bottom shelf: folded blankets and boxes (half hidden by the counter)
    for i, rp in enumerate((PETAL, GOLD, WATER)):
        o = cv.obj(); o.part(rect(62 + i * 24, 76 + (i % 2) * 4, 82 + i * 24, 95), rp, d=2); o.draw()
        cv.fill(rect(62 + i * 24, 84 + (i % 2) * 4, 82 + i * 24, 84 + (i % 2) * 4), rp['s'])

    # --- left: hanging lantern, broom, barrels ---
    cv.fill(rect(30, 12, 30, 18), '#4a2c1a')
    o = cv.obj()
    o.part(rect(24, 18, 36, 21), STONE, d=1)
    o.part(rect(25, 22, 35, 34), ramp('#f5cf6a', '#e8a317', '#fff3c8'), d=2, contour=True)
    o.part(rect(24, 34, 36, 37), STONE, d=1, contour=True)
    o.draw()
    cv.fill(rect(29, 26, 31, 31), '#f08a24')
    o = cv.obj()
    o.part(line([(44, 30), (36, 96)], 3), WOOD, d=1)
    o.part(poly([(30, 92), (42, 92), (46, 110), (24, 110)]), GOLD, d=2, contour=True)
    o.draw()
    for x in (30, 35, 40):
        cv.fill(line([(x, 96), (x - 2 + (x - 35) // 2, 109)]), '#b07a10')
    barrel(cv, 2, 92, 44, H + 1)
    barrel(cv, 40, 102, 78, H + 1)
    for (x, y) in ((8, 84), (16, 82), (24, 85), (12, 88), (20, 89), (30, 88)):
        o = cv.obj(); o.part(ell(x, y, x + 9, y + 8), EMBER, d=2); o.draw()
        cv.dots([(x + 4, y)], '#4f9a45'); cv.dots([(x + 2, y + 2)], '#f08a24')

    # --- foreground centre: a crate of apples and a potato sack ---
    o = cv.obj()
    o.part(rect(80, 108, 132, H + 1), WOOD, d=2)
    o.draw()
    for y in (116, 126):
        cv.fill(rect(80, y, 132, y), '#7a4a1f')
    cv.fill(line([(82, 110), (130, H - 1)]), '#7a4a1f')
    for (x, y) in ((82, 100), (92, 98), (102, 100), (112, 98), (122, 100), (87, 104), (107, 104), (117, 104)):
        o = cv.obj(); o.part(ell(x, y, x + 9, y + 8), GOLD if (x // 10) % 2 else EMBER, d=2); o.draw()
        cv.dots([(x + 4, y)], '#4f9a45')
    o = cv.obj()
    o.part(poly([(136, H + 1), (166, H + 1), (166, 112), (160, 102), (142, 102), (136, 112)]), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=3)
    o.part(rect(144, 98, 158, 103), WOOD, d=1, contour=True)
    o.draw()
    stitch_h(cv, 140, 162, 106, '#7a4a1f')

    # --- right: the counter with a brass scale, a sweet jar and a bell ---
    o = cv.obj()
    o.part(rect(166, 94, W + 1, 99), WOOD, d=2)
    o.part(rect(170, 100, W + 1, H + 1), DWOOD, d=0, contour=True)
    o.draw()
    cv.fill(rect(176, 106, 232, 120) & ~rect(178, 108, 230, 118), '#5c3420')
    o = cv.obj(); o.part(rrect(198, 111, 210, 114, 1), GOLD, d=1); o.draw()
    o = cv.obj()                                              # scale
    o.part(rect(184, 66, 187, 92) | rect(176, 89, 196, 93), GOLD, d=1)
    o.part(rect(170, 64, 202, 67), GOLD, d=1, contour=True)
    o.part(poly([(166, 78), (180, 78), (176, 84), (170, 84)]) | poly([(190, 74), (204, 74), (200, 80), (194, 80)]), GOLD, d=1, contour=True)
    o.draw()
    cv.fill(rect(172, 68, 172, 77) | rect(197, 68, 197, 73), '#b07a10')
    o = cv.obj(); o.part(ell(194, 68, 200, 74), EMBER, d=1); o.draw()
    o = cv.obj()                                              # sweet jar
    o.part(rrect(208, 66, 230, 93, 4), ramp('#a9d6ea', '#3f8fb0', '#f2e4c0'), d=2)
    o.part(rect(212, 60, 226, 65), PETAL, d=1, contour=True)
    o.draw()
    for (x, y, c) in ((212, 76, '#e46a9b'), (219, 72, '#e8a317'), (224, 80, '#4f9a45'), (214, 84, '#d6322b'), (221, 86, '#7a5cc0'), (225, 72, '#e46a9b')):
        cv.fill(ell(x - 2, y - 2, x + 2, y + 2), c)
    cv.fill(rect(211, 70, 212, 74), '#f2e4c0')
    o = cv.obj()                                              # bell
    o.part(rect(235, 82, 237, 85), GOLD, d=0)
    o.part(ell(230, 85, 242, 97) & rect(0, 0, W, 93), GOLD, d=2, contour=True)
    o.draw()
    cv.remap({'#fff3c8': '#f2e4c0', '#c9c5bc': '#f2e4c0', '#f6b8cf': '#f2e4c0', '#c3b2ea': '#f2e4c0'})
    return cv


def cloth(cv, x, w, yb, rp, dip=None):
    """A dyed cloth folded over the drying pole: fold on top, two creases, a wavy hem, two drips; dip = a dip-dyed hem band."""
    body = poly([(x, 18), (x + w, 18), (x + w, yb - 2), (x + 3 * w // 4, yb), (x + w // 2, yb - 2), (x + w // 4, yb), (x, yb - 2)])
    o = cv.obj()
    o.part(body, rp, d=2)
    o.part(rrect(x - 1, 12, x + w + 1, 18, 2), rp, d=1, contour=True)
    o.draw()
    low = rp
    if dip:
        band = body & rect(0, yb - 12, W, H)
        cv.fill(band, dip['b'])
        cv.fill(band & ~shift(band, -2, -2), dip['s'])
        cv.fill(rect(x, yb - 12, x + w, yb - 12) & body, dip['s'])
        low = dip
    for k in (w // 3, 2 * w // 3):
        cv.fill(rect(x + k, 21, x + k, yb - (13 if dip else 5)), rp['s'])
        if dip:
            cv.fill(rect(x + k, yb - 10, x + k, yb - 5), dip['s'])
    cv.fill(rect(x + 1, 19, x + w - 1, 19), rp['s'])
    cv.fill(rect(x + 2, 14, x + w - 2, 14), rp['r'])
    for (dx, dy) in ((4, 3), (w - 5, 6)):
        cv.fill(rect(x + dx, yb + dy, x + dx, yb + dy + 1), low['s'])


def skein(cv, x, yb, rp):
    """A twisted hank of yarn hung over the pole, tied near the bottom."""
    o = cv.obj()
    o.part(rrect(x, 12, x + 9, yb, 3), rp, d=2)
    o.draw()
    cv.fill(rect(x, yb - 10, x + 9, yb - 8), '#f2e4c0')
    cv.fill(rect(x + 7, yb - 10, x + 9, yb - 8) | rect(x, yb - 8, x + 9, yb - 8), '#c9a96e')
    for y in range(19, yb - 11, 5):
        cv.fill(line([(x + 1, y), (x + 8, y + 3)]), rp['s'])
    cv.dots([(x + 2, 15), (x + 3, 14)], rp['r'])


def bubbles(cv, pts, col, rim):
    """Little round bubbles on a dye surface (2 x 2 with a lit pixel)."""
    for (x, y) in pts:
        cv.fill(rect(x, y, x + 2, y + 1), col)
        cv.dots([(x, y)], rim)


def dyes():
    cv = Canvas('#c9c5bc')
    # whitewashed stone wall, block courses
    cv.fill(rect(0, 0, W - 1, H - 1), '#c9c5bc')
    for i, y in enumerate(range(22, 100, 11)):
        cv.fill(rect(0, y, W - 1, y), '#8b8f96')
        for x in range(6 + (i % 2) * 11, W, 22):
            cv.fill(rect(x, y + 1, x, min(y + 10, 99)), '#8b8f96')
    # flagstone floor, the dye has splashed everywhere
    cv.fill(rect(0, 100, W - 1, H - 1), '#8b8f96')
    cv.fill(rect(0, 100, W - 1, 101), '#5b6470')
    for i, y in enumerate((112, 124)):
        cv.fill(rect(0, y, W - 1, y), '#5b6470')
        for x in range(10 + i * 17, W, 34):
            cv.fill(rect(x, y - 10 if i == 0 else 113, x, y - 1), '#5b6470')
    for (x0, y0, x1, y1, c) in ((50, 116, 66, 121, '#3f8fb0'), (124, 125, 140, 130, '#d6322b'), (60, 127, 72, 131, '#e8a317'),
                                (188, 120, 198, 124, '#7a5cc0'), (98, 128, 112, 132, '#3f8fb0'), (166, 129, 182, 133, '#e46a9b'),
                                (4, 128, 14, 132, '#d6322b'), (216, 128, 230, 132, '#e8a317')):
        cv.fill(ell(x0, y0, x1, y1), c)
        cv.dots([(x1 + 2, y0 + 1), (x0 - 2, y1)], c)
    ceiling(cv)

    # --- left: tall pigment shelf (jars of powder, bowls of heaped colour, paper twists) ---
    o = cv.obj()
    o.part(rect(2, 14, 58, 98), DWOOD, d=2)
    o.draw()
    cv.fill(rect(6, 18, 54, 96), '#5c3420')
    o = cv.obj()
    for y in (42, 68, 94):
        o.part(rect(4, y, 56, y + 3), WOOD, d=1)
    o.draw()
    glass = ramp('#f2e4c0', '#c9a96e', '#fff3c8')
    for i, rp in enumerate((EMBER, WATER, GOLD)):           # top row: powder jars
        x = 8 + i * 16
        o = cv.obj()
        o.part(rrect(x, 24, x + 13, 41, 2), glass, d=2)
        o.part(rect(x + 3, 20, x + 10, 24), WOOD, d=1, contour=True)
        o.draw()
        cv.fill(rrect(x + 2, 31, x + 11, 39, 1), rp['b'])
        cv.fill(rect(x + 2, 37, x + 11, 39) & rrect(x + 2, 31, x + 11, 39, 1), rp['s'])
        cv.fill(rect(x + 2, 31, x + 11, 31), rp['r'])
        cv.fill(rect(x + 2, 26, x + 3, 29), '#fff3c8')
    for i, rp in enumerate((DUSK, PETAL, MOSS)):            # middle row: bowls with heaps of powder
        x = 7 + i * 16
        o = cv.obj()
        o.part(ell(x + 1, 50, x + 13, 62) & rect(0, 0, W, 59), rp, d=2)
        o.part(poly([(x - 1, 59), (x + 15, 59), (x + 12, 67), (x + 2, 67)]), STONE, d=2, contour=True)
        o.draw()
        cv.dots([(x + 4, 53), (x + 5, 52)], rp['r'])
    for i, rp in enumerate((GOLD, EMBER, WATER)):           # bottom row: paper twists of colour
        x = 8 + i * 16
        o = cv.obj()
        o.part(poly([(x, 93), (x + 13, 93), (x + 11, 78), (x + 2, 78)]), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=2)
        o.part(poly([(x + 2, 78), (x + 11, 78), (x + 9, 74), (x + 4, 74)]), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=1, contour=True)
        o.draw()
        cv.fill(rect(x + 3, 83, x + 10, 88), rp['b'])
        cv.fill(rect(x + 3, 88, x + 10, 88), rp['s'])

    # --- drying pole across the room: dyed cloths and yarn skeins drying ---
    cv.fill(rect(70, 12, 70, 14) | rect(226, 12, 226, 14), '#4a2c1a')
    o = cv.obj(); o.part(rect(62, 14, 238, 16), DWOOD, d=1); o.draw()
    hang = [('c', 64, 20, 50, WATER, None), ('s', 87, 0, 44, GOLD, None), ('c', 99, 22, 46, EMBER, GOLD), ('s', 124, 0, 48, DUSK, None),
            ('c', 136, 20, 52, GOLD, None), ('s', 159, 0, 42, WATER, None), ('c', 171, 22, 48, DUSK, PETAL), ('s', 196, 0, 46, PETAL, None),
            ('c', 208, 22, 44, MOSS, WATER)]
    for (kind, x, w, yb, rp, dip) in hang:
        if kind == 'c':
            cloth(cv, x, w, yb, rp, dip)
        else:
            skein(cv, x, yb, rp)
    skein(cv, 232, 40, EMBER)

    # --- centre left: the big wooden indigo vat, a paddle stood in it ---
    o = cv.obj()
    body = rect(64, 66, 124, 124) | (ell(64, 112, 124, 128) & rect(0, 120, W, 128))
    o.part(body, WOOD, d=3)
    o.part(ell(62, 58, 126, 72), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=1, contour=True)
    o.draw()
    for yy in (80, 112):
        cv.fill(rect(64, yy, 124, yy + 2) & body, '#5b6470')
        cv.dots([(66, yy)], '#c9c5bc')
    for xx in range(71, 122, 8):
        cv.fill(rect(xx, 72, xx, 126) & body & ~rect(0, 80, W, 82) & ~rect(0, 112, W, 114), '#7a4a1f')
    cv.fill(ell(66, 60, 122, 70), '#3d2a1c')
    cv.fill(ell(67, 61, 121, 70), '#25637d')
    cv.fill(ell(76, 62, 112, 68) & ~ell(78, 63, 110, 67), '#3f8fb0')
    bubbles(cv, ((82, 64), (92, 63), (100, 66), (108, 64), (74, 66), (88, 67)), '#3f8fb0', '#a9d6ea')
    cv.fill(rect(66, 71, 68, 75) | rect(67, 76, 67, 78), '#25637d')               # a blue drip down the side
    o = cv.obj()                                              # paddle
    o.part(line([(104, 66), (118, 22)], 4), WOOD, d=1)
    o.part(rrect(115, 16, 122, 24, 2), WOOD, d=1, contour=True)
    o.draw()
    cv.fill(line([(104, 66), (108, 54)], 4) & ~ell(66, 60, 122, 70), '#25637d')
    for (x, y) in ((86, 54), (96, 50), (78, 56)):                                  # rising bubbles
        cv.fill(rect(x, y, x + 2, y + 2) & ~rect(x + 1, y + 1, x + 1, y + 1), '#a9d6ea')

    # --- centre right: copper cauldron of madder red over a stone hearth ---
    o = cv.obj()
    o.part(rect(134, 106, 188, 126), STONE, d=2)
    o.draw()
    for y in (113, 120):
        cv.fill(rect(134, y, 188, y), '#5b6470')
    for (x, y0, y1) in ((146, 107, 112), (166, 107, 112), (140, 114, 119), (178, 114, 119), (152, 121, 125), (172, 121, 125)):
        cv.fill(rect(x, y0, x, y1), '#5b6470')
    mouth = ell(148, 108, 174, 130) & rect(0, 0, W, 125)
    cv.fill(mouth, '#3d2a1c')
    for (x0, x1, top, col) in ((150, 160, 113, '#d6322b'), (155, 168, 109, '#f08a24'), (163, 172, 114, '#d6322b'),
                               (157, 165, 114, '#e8a317'), (160, 163, 118, '#f5cf6a')):
        cv.fill(poly([(x0, 125), (x1, 125), ((x0 + x1) // 2, top)]) & mouth, col)
    o = cv.obj()
    o.part(ell(132, 56, 190, 114) & rect(0, 64, W, 114), COPPER, d=4)
    o.part(ell(130, 58, 192, 72), COPPER, d=1, contour=True)
    o.draw()
    cv.fill(rect(128, 74, 133, 78) | rect(189, 74, 194, 78), '#4a2c1a')          # ring handles
    cv.fill(rect(139, 76, 141, 92) | rect(140, 74, 142, 75), '#f5cf6a')            # a long glint on the lit side
    pot = ell(132, 56, 190, 114) & rect(0, 64, W, 114)
    cv.fill(rect(130, 82, 192, 83) & pot, '#a8241f')                              # riveted band
    cv.dots([(x, 85) for x in range(137, 188, 6) if pot[85, x]], '#a8241f')
    cv.fill(ell(134, 60, 188, 70), '#3d2a1c')
    cv.fill(ell(135, 61, 187, 70), '#a8241f')
    cv.fill(ell(146, 62, 176, 68) & ~ell(148, 63, 174, 67), '#d6322b')
    bubbles(cv, ((142, 64), (152, 63), (162, 65), (172, 63), (178, 66), (156, 67)), '#d6322b', '#f08a24')
    for (x, y) in ((150, 52), (164, 47), (174, 54), (158, 56)):                    # bubbles and steam rising
        cv.fill(rect(x, y, x + 2, y + 2) & ~rect(x + 1, y + 1, x + 1, y + 1), '#f2e4c0')

    # --- right: bench of dye plants (madder, indigo, marigold), a purple dye bucket below ---
    o = cv.obj()
    o.part(rect(194, 96, W + 1, 100), WOOD, d=2)
    o.part(rect(198, 101, 202, 124) | rect(232, 101, 236, 124), WOOD, d=1, contour=True)
    o.draw()
    # madder: whorls of narrow leaves, red roots on the bench
    cv.fill(line([(203, 86), (203, 54)]) | line([(204, 84), (209, 62)]), '#2f6a3a')
    for (x, y) in ((203, 56), (203, 64), (203, 72), (203, 80), (209, 63), (207, 71)):
        o = cv.obj(); o.part(ell(x - 7, y, x - 1, y + 2) | ell(x + 1, y, x + 7, y + 2) | ell(x - 1, y - 4, x + 1, y + 1), LEAF, d=1); o.draw()
    # indigo: taller, oval leaves, pink flower spikes
    cv.fill(line([(219, 86), (219, 50)]) | line([(219, 70), (225, 58)]), '#2f6a3a')
    for (x, y, s) in ((219, 54, -1), (219, 62, 1), (219, 70, -1), (219, 78, 1), (225, 60, 1)):
        o = cv.obj(); o.part(ell(x + (1 if s > 0 else -9), y, x + (9 if s > 0 else -1), y + 5), MOSS, d=1); o.draw()
    for (x, y) in ((218, 44), (225, 51), (212, 58)):
        o = cv.obj(); o.part(rect(x, y, x + 2, y + 6), PETAL, d=1); o.draw()
    # marigold: bushy, big orange heads
    o = cv.obj(); o.part(ell(224, 66, 242, 88) | ell(228, 58, 243, 78), MOSS, d=2); o.draw()
    cv.fill(line([(232, 64), (236, 80)]) | line([(228, 74), (232, 84)]), '#2f6a3a')
    for (x, y, rp) in ((233, 60, COPPER), (239, 70, GOLD), (228, 70, GOLD), (236, 80, COPPER)):
        flower(cv, x, y, rp, 4)
    for x in (196, 212, 226):                                  # terracotta pots
        o = cv.obj()
        o.part(poly([(x, 86), (x + 14, 86), (x + 12, 95), (x + 2, 95)]) | rect(x - 1, 84, x + 15, 87), BRICK, d=2)
        o.draw()
    o = cv.obj()                                              # a bundle of dug madder roots
    o.part(line([(196, 96), (212, 98)], 2) | line([(198, 99), (213, 95)], 2) | line([(200, 95), (210, 99)], 2), EMBER, d=0)
    o.part(rect(203, 95, 205, 99), CREAM, d=0, contour=True)
    o.draw()
    o = cv.obj()                                              # purple dye bucket under the bench
    o.part(poly([(206, 108), (230, 108), (228, 128), (208, 128)]), DWOOD, d=2)
    o.part(ell(204, 104, 232, 112), WOOD, d=1, contour=True)
    o.draw()
    cv.fill(rect(206, 116, 230, 117) & poly([(206, 108), (230, 108), (228, 128), (208, 128)]), '#5b6470')
    cv.fill(ell(206, 105, 230, 111), '#4e3a8a')
    bubbles(cv, ((212, 107), (220, 106), (225, 108)), '#7a5cc0', '#c3b2ea')
    o = cv.obj(); o.part(poly([(204, 107), (210, 106), (210, 122), (206, 124), (203, 118)]), PETAL, d=1); o.draw()

    # --- left foreground: a stone basin of marigold yellow, flower heads floating ---
    o = cv.obj()
    basin = rect(4, 104, 52, 124) | (ell(4, 116, 52, 128) & rect(0, 120, W, 128))
    o.part(basin, STONE, d=3)
    o.part(ell(2, 96, 54, 110), STONE, d=1, contour=True)
    o.draw()
    for (x, y0, y1) in ((16, 111, 118), (34, 111, 118), (24, 119, 125), (44, 119, 125)):
        cv.fill(rect(x, y0, x, y1) & basin, '#5b6470')
    cv.fill(rect(4, 118, 52, 118) & basin, '#5b6470')
    cv.fill(ell(5, 98, 51, 108), '#3d2a1c')
    cv.fill(ell(6, 99, 50, 108), '#e8a317')
    cv.fill(ell(14, 100, 42, 106) & ~ell(16, 101, 40, 105), '#b07a10')
    bubbles(cv, ((12, 102), (22, 101), (34, 103), (42, 101)), '#f5cf6a', '#fff3c8')
    for (x, y) in ((18, 104), (30, 101)):
        cv.fill(ell(x, y, x + 4, y + 3), '#f08a24')
    cv.fill(rect(6, 110, 7, 114), '#e8a317')
    cv.remap({'#fff3c8': '#f2e4c0', '#8a5a30': '#7a4a1f'})
    return cv


SHOPS = {'bakery': bakery, 'craft': craft, 'dyes': dyes, 'general': general, 'herbs': herbs, 'seeds': seeds}

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..', '..', 'game', 'assets', 'img', 'scenes')
    only = sys.argv[2:] or list(SHOPS)
    for k in only:
        cv = SHOPS[k]()
        p = os.path.join(out, 'shop-' + k + '.png')
        cv.save(p)
        print(k, 'colours', cv.colours(), '->', p)
