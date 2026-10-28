"""Gather tab scene for the GRASSLAND (2026-10-28): game/assets/img/gather/scene-grassland.png (480 x 270).

Usage: python3 -B aseprite-source/scenes-pil/gather_grassland.py
Gnome-eye view of a meadow: a wide sky, rolling far hills with barley strips, a wall of grass taller than a gnome on
the horizon, a green floor. Focal prop: a giant dandelion clock on the left, shedding seeds that drift over the satchel.
The open satchel (draw_satchel, fixed place x 146..214, y 34..104) and a pressed-grass nest left of it (the landing
spot, x 96..144, y 98..112) stay clear. Props live at x 8..90 and x 216..236; the top corners (UI chips) stay plain sky.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import Canvas, ramp, rect, ell, poly, line, blank, shift, W, H  # noqa: E402
from gather_common import draw_satchel, save_scene  # noqa: E402
from stops import bands, wave, cloud  # noqa: E402

MOSS = ramp('#4f9a45', '#2f6a3a', '#7ab55c')
LEAF = ramp('#7ab55c', '#4f9a45', '#a4b86a')
STEM = ramp('#a4b86a', '#4f9a45', '#a4b86a')
PUFF = ramp('#f1ece0', '#c9c5bc', '#fff3c8')
BLOOM = ramp('#e8a317', '#b07a10', '#f5cf6a')
STONE = ramp('#8b8f96', '#5b6470', '#c9c5bc')
BARLEY = ramp('#e8cf98', '#c9a96e', '#f5cf6a')
EMBER = ramp('#d6322b', '#a8241f', '#f08a24')

GROUND = 50


def blade(x, ybot, h, lean, w=3):
    """A tapering grass blade: a thin triangle from a w-wide foot to a point leaning `lean` px."""
    return poly([(x, ybot), (x + w, ybot), (x + lean + w // 2, ybot - h)])


def seed(cv, x, y, col='#fff3c8', stalk='#9a6b3f'):
    """One drifting dandelion seed: a little parasol, its stalk and the seed."""
    cv.dots([(x - 2, y), (x - 1, y - 1), (x, y - 1), (x + 1, y - 1), (x + 2, y)], col)
    cv.dots([(x, y), (x, y + 1)], '#c9c5bc')
    cv.dots([(x, y + 2), (x, y + 3)], stalk)


def sky(cv):
    bands(cv, [(0, '#7fbcd8'), (14, '#a9d6ea'), (26, '#cde6e8')])
    cloud(cv, 54, 6, 40, '#f1ece0', '#cde6e8')
    cloud(cv, 112, 18, 26, '#f1ece0', '#cde6e8')
    cloud(cv, 168, 6, 22, '#f1ece0', '#cde6e8')


def far(cv):
    hills = wave(34, [(3, 110, 0.6), (2, 47, 2.1)])
    cv.fill(hills, '#b9cf8e')
    for x0 in range(-20, W, 34):                       # barley strips on the far slopes
        cv.fill(hills & poly([(x0, 30), (x0 + 12, 30), (x0 + 2, 50), (x0 - 10, 50)]), '#e8cf98')
    mid = wave(40, [(3, 140, 2.4), (1, 37, 0.3)])
    cv.fill(mid, '#a4b86a')
    # the grass wall on the horizon: blades taller than a gnome, light ones behind, darker in front
    back, front = blank(), blank()
    for i, x in enumerate(range(-4, W + 4, 5)):
        h = 14 + (i * 7) % 13
        back |= blade(x, GROUND + 1, h, (i % 3) - 1, 4)
    for i, x in enumerate(range(-2, W + 4, 4)):
        h = 6 + (i * 5) % 9
        front |= blade(x, GROUND + 1, h, ((i * 2) % 5) - 2, 3)
    cv.fill(back, '#7ab55c')
    cv.fill(back & ~shift(back, 1, 0) & rect(0, 0, W, GROUND - 6), '#a4b86a')     # lit left edges
    cv.fill(front, '#4f9a45')
    # barley ears nodding above the wall
    for (x, y) in ((72, 24), (98, 28), (206, 26)):
        cv.fill(line([(x, y + 6), (x + 1, GROUND - 4)]), '#c9a96e')
        for k in range(4):
            cv.dots([(x - 1, y + k * 2), (x + 1, y + k * 2 + 1)], '#e8cf98')
        cv.dots([(x, y - 1), (x, y - 3)], '#c9a96e')


def ground(cv):
    cv.fill(rect(0, GROUND, W - 1, H - 1), '#4f9a45')
    cv.fill(rect(0, GROUND, W - 1, GROUND + 2), '#2f6a3a')         # contact shade under the grass wall
    # short blade marks on a staggered grid (no dither: little Vs)
    for r, y in enumerate(range(58, H, 7)):
        for x in range((r * 11) % 19, W, 19):
            cv.dots([(x, y), (x + 1, y + 1), (x + 2, y)], '#2f6a3a')
        for x in ((r * 11) % 19 + 9, ):
            for xx in range(x, W, 19):
                cv.dots([(xx, y + 3), (xx + 1, y + 2)], '#7ab55c')


def nest(cv):
    """The landing spot: a ring of pressed straw-gold grass, flat and calm."""
    cv.fill(ell(96, 98, 144, 112), '#2f6a3a')
    cv.fill(ell(99, 100, 141, 110), '#c9a96e')
    cv.fill(ell(103, 102, 137, 108), '#e8cf98')
    cv.fill(line([(106, 104), (112, 103), (118, 103)]) | line([(122, 107), (128, 107), (134, 106)]), '#c9a96e')


def dandelion_clock(cv):
    """Focal prop: a gnome-towering dandelion clock, a bite of seeds gone on the right where the wind took them."""
    cx, cy, r = 40, 36, 16
    # rosette of broad toothed leaves at its foot
    o = cv.obj()
    for (tip, base, rp) in (((8, 92), (38, 102), LEAF), ((72, 94), (44, 102), MOSS), ((18, 80), (38, 100), MOSS),
                            ((64, 82), (43, 100), LEAF)):
        bx, by = base
        tx, ty = tip
        dx, dy = tx - bx, ty - by
        n = math.hypot(dx, dy)
        px, py = -dy / n * 5, dx / n * 5
        m = poly([(bx, by), (bx + dx * 0.5 + px, by + dy * 0.5 + py), (tx, ty), (bx + dx * 0.5 - px, by + dy * 0.5 - py)])
        for t in (0.3, 0.55, 0.78):                       # saw-tooth bites along both edges
            nx, ny = bx + dx * t, by + dy * t
            for sg in (1, -1):
                ex, ey = nx + sg * px * 0.9, ny + sg * py * 0.9
                m &= ~poly([(ex, ey), (ex + dx / n * 4 - sg * px * 0.5, ey + dy / n * 4 - sg * py * 0.5), (ex + dx / n * 5, ey + dy / n * 5)])
        o.part(m, rp, d=2)
    o.draw()
    # stem
    o = cv.obj()
    o.part(line([(41, 100), (43, 78), (41, 56), (40, cy + r - 3)], 3), STEM, d=1)
    o.draw()
    # the clock: a round seed ball with a fine fringe of pappus tips
    ball = ell(cx - r, cy - r, cx + r, cy + r)
    fringe = blank()
    for k in range(36):
        a = k * 2 * math.pi / 36
        fringe |= line([(cx + (r - 1) * math.cos(a), cy + (r - 1) * math.sin(a)),
                        (cx + (r + 2) * math.cos(a), cy + (r + 2) * math.sin(a))])
    bite = ell(cx + 6, cy - 14, cx + 24, cy + 2)
    puff = (ball | fringe) & ~bite
    o = cv.obj()
    o.part(puff, PUFF, d=3)
    o.draw()
    # seed spokes from the core with parasol dots at their tips
    for k in range(16):
        a = k * 2 * math.pi / 16 + 0.1
        ex, ey = round(cx + (r - 4) * math.cos(a)), round(cy + (r - 4) * math.sin(a))
        if bite[ey, ex]:
            continue
        cv.fill(line([(cx + 4 * math.cos(a), cy + 4 * math.sin(a)), (ex, ey)]) & puff, '#c9c5bc')
        cv.dots([(ex - 1, ey), (ex + 1, ey), (ex, ey - 1)], '#fff3c8' if math.cos(a) + math.sin(a) < 0 else '#f1ece0')
    core = ell(cx - 4, cy - 4, cx + 4, cy + 4)
    cv.fill(core, '#c9a96e')
    cv.fill(core & ~shift(core, -1, -1), '#9a6b3f')
    cv.dots([(cx - 2, cy - 2), (cx - 1, cy - 2), (cx - 2, cy - 1)], '#e8cf98')
    # bare stubs inside the bite
    for a in (-0.9, -0.55, -0.2):
        cv.fill(line([(cx + 5 * math.cos(a), cy + 5 * math.sin(a)), (cx + 9 * math.cos(a), cy + 9 * math.sin(a))]), '#9a6b3f')
    cv.fill(ell(cx - 12, cy - 12, cx - 9, cy - 9), '#fff3c8')     # gloss on the lit upper left
    # seeds on the wind, drifting right over the meadow towards the satchel
    for (x, y) in ((66, 24), (80, 18), (94, 28), (110, 12), (126, 22), (140, 10), (162, 24), (196, 20)):
        seed(cv, x, y)


def bloom(cv, x, y):
    """A small open dandelion flower on its own stem."""
    o = cv.obj()
    o.part(line([(x, y + 4), (x + 1, 102)], 2), STEM, d=1)
    m = ell(x - 6, y - 5, x + 6, y + 5)
    for k in range(10):
        a = k * math.pi / 5
        m |= ell(round(x + 6 * math.cos(a)) - 2, round(y + 5 * math.sin(a)) - 2, round(x + 6 * math.cos(a)) + 2, round(y + 5 * math.sin(a)) + 2)
    o.part(m, BLOOM, d=2)
    o.draw()
    cv.fill(ell(x - 2, y - 2, x + 2, y + 2), '#b07a10')
    cv.dots([(x - 1, y - 1)], '#f5cf6a')


def clover(cv, x, y, s=4):
    """A three-leaf clover, raised."""
    o = cv.obj()
    o.part(line([(x, y + s), (x + 1, y + s * 3)], 1), MOSS, d=0)
    for (dx, dy) in ((-s, -1), (s, -1), (0, -s - 1)):
        o.part(ell(x + dx - s + 1, y + dy - s + 1, x + dx + s - 1, y + dy + s - 1), LEAF, d=2)
    o.draw()
    cv.dots([(x - s, y - 1), (x + s, y - 1), (x, y - s - 1)], '#a4b86a')


def barley(cv, x, ybot, h, bend):
    """A tall barley stalk at the far right, its fat ear nodding over with long awns."""
    top = (x + bend, ybot - h)
    grains = [(top[0] + (2 if k % 2 else -2) + k, top[1] + 2 - k * 4) for k in range(6)]
    for (gx, gy), k in zip(grains, range(6)):           # awns first, behind the ear
        sg = 1 if k % 2 else -1
        cv.fill(line([(gx + sg * 2, gy - 1), (gx + sg * 7, gy - 9)]), '#c9a96e')
    o = cv.obj()
    o.part(line([(x, ybot), (x + bend // 3, ybot - h // 2), top], 2), BARLEY, d=1)
    ear = blank()
    for (gx, gy) in grains:
        ear |= ell(gx - 3, gy - 3, gx + 2, gy + 2)
    o.part(ear, BARLEY, d=2)
    o.draw()


def props(cv):
    dandelion_clock(cv)
    bloom(cv, 76, 70)
    for (x, y, s) in ((14, 112, 4), (28, 122, 3), (64, 118, 4), (80, 126, 3)):
        clover(cv, x, y, s)
    # pebble at the left edge
    o = cv.obj()
    o.part(ell(54, 100, 70, 112) & rect(0, 0, W, 108), STONE, d=2)
    o.draw()
    # far right: tall blades and a nodding barley stalk, a red poppy low down
    o = cv.obj(outline=False)
    for (x, h, lean) in ((216, 44, -6), (224, 54, 4), (230, 38, 6), (220, 30, 9)):
        o.part(blade(x, 112, h, lean, 3), MOSS, d=1)
    o.draw()
    barley(cv, 226, 112, 62, -4)
    o = cv.obj()
    o.part(line([(232, 128), (231, 112)], 1), MOSS, d=0)
    o.part(ell(226, 104, 236, 113), EMBER, d=2)
    o.draw()
    cv.fill(rect(230, 107, 232, 109), '#2a1a10')
    # wildflower specks in the near grass, off the nest and the satchel
    for i, (x, y) in enumerate(((10, 62), (30, 70), (88, 60), (96, 76), (58, 84), (8, 92), (84, 96), (218, 66),
                                (228, 84), (40, 128), (96, 124), (150, 122), (178, 128), (206, 118), (120, 126))):
        c = ('#f5cf6a', '#f1ece0', '#e46a9b')[i % 3]
        cv.dots([(x, y), (x + 1, y), (x, y + 1), (x + 1, y + 1)], c)
        cv.dots([(x, y + 2)], '#2f6a3a')


def scene():
    cv = Canvas('#a9d6ea')
    sky(cv)
    far(cv)
    ground(cv)
    nest(cv)
    props(cv)
    draw_satchel(cv)
    cv.remap({'#c8e6a0': '#a4b86a'})
    return cv


if __name__ == '__main__':
    cv = scene()
    save_scene(cv, 'grassland')
    print('colours:', cv.colours())
