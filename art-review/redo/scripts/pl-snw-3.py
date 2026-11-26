"""pl-snw-3 Snowmelt Trickle. Inner-TBTB, tri: a giggling meltwater trickle running down a snowcrown rock slab. N tri tab = the snowy
peak tip, S tri tab = the drip falling off the bottom, tri blanks E + W bite into the grey-lavender rock walls the trickle runs between.
Rock lavender-grey with dark purple crevices and cream ledges (cell 8-3), snow white-lavender, meltwater icy blue."""
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
import math

ROCK = K.ramp('#a6979c')
CREV = ('#3f3550', '#2f2840', '#544860')
LEDGE = '#c2b2a8'
SNOW = ('#f4f2f8', '#c9c8dc', '#ffffff')
WATER = ('#6fb4e0', '#4a86b8', '#b4dcf4')
FOAM = '#e4f4fc'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 15, 52, 51)
    tabN = K.knob('T', 'tri', 32, 15, 0, -1, r=5.6 * k, nw=3.4 * k)
    tabS = K.knob('T', 'tri', 32, 51, 0, 1, r=5.6 * k, nw=3.4 * k)
    blE = K.knob('B', 'tri', 52, 34, 1, 0, r=5.6 * k, nw=3.2 * k)
    blW = K.knob('B', 'tri', 12, 34, -1, 0, r=5.6 * k, nw=3.2 * k)
    body = c.m(core, tabN, tabS, minus=(blE, blW))
    c.add(body, ROCK)
    # rock ledges + crevices like the cell
    if not c.small:
        for (y0, x0, x1) in ((27, 13, 22), (43, 42, 51), (44, 13, 20), (25, 43, 51)):
            for x in range(*c.P(x0, 0)[0:1], c.P(x1, 0)[0]):
                if (x, c.P(0, y0)[1]) in body:
                    c.px(x, c.P(0, y0)[1], LEDGE)
                    c.px(x, c.P(0, y0)[1] + 1, CREV[2])
    else:
        for (y0, x0, x1) in ((27, 13, 21), (44, 43, 51)):
            for x in range(c.P(x0, 0)[0], c.P(x1, 0)[0]):
                if (x, c.P(0, y0)[1]) in body:
                    c.px(x, c.P(0, y0)[1], LEDGE)
    # the trickle: wavy water column from the snow to the drip tab, widening into the face pool
    def wat(x, y):
        if y < 18 or y > 64:
            return False
        w = 6.5 + 5.5 * max(0.0, 1 - abs(y - 35) / 13.0)
        cx = 32 + 1.6 * math.sin(y / 4.0)
        return abs(x - cx) < w
    water = c.m(wat) & body
    c.add(water | (c.m(tabS) & body), WATER)
    c.edge(water, WATER[1])
    # dark purple crevices down the rock walls, like the cell
    for cx in (14.5, 49.5):
        c.add(c.m(K.rect(cx - 1.6, 20, cx + 1.6, 51)) & body - water, CREV)
    # snow cap with drippy lower edge (the snowcrown), N tri tab is the peak
    def snow(x, y):
        d = 21 + (3.5 if int(x // 5) % 2 == 0 else 0) + (2 if 26 < x < 38 else 0)
        return y < d
    s = c.m(snow) & body
    c.add(s, SNOW)
    c.edge(s, SNOW[1])
    # foam ripples / sparkle in the water
    if not c.small:
        for (x0, x1, y) in ((25, 30, 44), (34, 39, 46), (29, 34, 50)):
            c.line([(x0, y), (x1, y)], FOAM)
        c.px(*c.P(36, 56), FOAM)
    else:
        c.line([(26, 45), (30, 45)], FOAM)
        c.line([(34, 47), (38, 47)], FOAM)
    # giggling face in the pool
    c.eye(27.5, 34)
    c.eye(36.5, 34)
    c.smile(32, 38, wide=True)
    c.blush(23.5, 37.5)
    c.blush(39.5, 37.5)


K.render_pal(fn, 'pl-snw-3', 'Snowmelt Trickle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-snw-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-snw-3.png')
