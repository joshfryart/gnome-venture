# Mosscap Topper: a lavender-grey standing stone wearing a woolly green moss hat; inner-TTTT keyhole
# (top tab = the hat's pompom, left/right/bottom tabs = stone), teal glowing rune from the picture's stones.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import math
import pal_kit as K

STONE = K.ramp('#7a7494')
STONE2 = K.ramp('#5e5a78')
MOSS = K.ramp('#4f9a3c')
MOSSD = K.ramp('#3c7a32')
POM = K.ramp('#6cb84a')
RUNE = '#6ee8d8'


def fn(c):
    s = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 14, 14, 50, 51
    core = lambda x, y: x0 <= x < x1 and y0 <= y < y1 and not (
        (x < x0 + 5 and y < y0 + 5 and (x - x0 - 5) ** 2 + (y - y0 - 5) ** 2 > 25) or
        (x > x1 - 5 and y < y0 + 5 and (x - x1 + 5) ** 2 + (y - y0 - 5) ** 2 > 25))
    tT = K.knob('T', 'keyhole', 32, y0, 0, -1, r=5.6 * s, nw=2.8)
    tL = K.knob('T', 'keyhole', x0, 36, -1, 0, r=5.6 * s, nw=2.8)
    tR = K.knob('T', 'keyhole', x1, 36, 1, 0, r=5.6 * s, nw=2.8)
    tB = K.knob('T', 'keyhole', 32, y1, 0, 1, r=5.6 * s, nw=2.8)
    body = c.m(core, tL, tR, tB)
    c.add(body, STONE, stitch=None)
    # weathered darker lower band + lichen spots
    c.add(c.m(lambda x, y: core(x, y) and y > 44 + 1.5 * math.sin(x / 3.0)), STONE2)
    # moss hat: lumpy brim
    hat = c.m(lambda x, y: core(x, y) and y < 24 + 1.6 * math.sin(x / 1.6) + (5 if (x < 19 or 44 < x < 48) else 0) , tT)
    c.add(hat, MOSS, stitch=None if c.small else MOSS[2])
    pom = c.m(tT, minus=(lambda x, y: y > y0 - 1,))
    c.add(pom, POM)
    c.edge(pom, MOSSD[1])
    # brim roll
    brim = c.m(lambda x, y: x0 <= x < x1 and abs(y - (23 + 1.6 * math.sin(x / 1.6))) < 1.3)
    c.add(brim, MOSSD)
    # knit ribs on hat
    if not c.small:
        for xx in range(19, 48, 4):
            c.line([(xx, 15), (xx, 20)], MOSS[1])
        for (sx, sy) in ((26, 46), (36, 28), (46, 41), (17, 46), (33, 48)):
            c.px(*c.P(sx, sy), STONE[1])
    # teal rune on the stone (left side of face)
    rw = [(19, 30), (19, 42), (19, 36), (23, 33)]
    c.line(rw[:2], RUNE)
    c.line(rw[2:], RUNE)
    if c.small:
        c.line([(20.5, 30), (20.5, 42)], RUNE)
    # lichen dots
    for (lx, ly) in ((44, 47), (40, 49), (24, 48)):
        p = c.P(lx, ly)
        c.px(*p, MOSS[0])
    # face
    c.eye(30, 33)
    c.eye(41, 33)
    c.smile(35.5, 39)
    c.blush(26, 37)
    c.blush(45, 37)


K.render_pal(fn, 'pl-stnd-4', 'Mosscap Toppers', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-stnd-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-stnd-4.png')
