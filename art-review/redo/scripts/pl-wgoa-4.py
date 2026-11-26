# pl-wgoa-4 "Harvest Hat Parade": a grape-basket gnome in a pointy straw hat, inner-TTTT double.
# N tab = the straw hat's pointy tip (cone runs into it), W/E tabs = the basket's two wicker handles, S tab = two little hooves.
# Colours from cell 6-4 / the vineyard picture: straw path khaki, goat cream, vine green, grape purple, wicker brown.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, poly, ell, knob, thick_path, ramp

STRAW = ramp('#d8b860')
CREAMR = ramp('#f4e6c8')
GRAPE = ramp('#7a3e8a')
WICKER = ramp('#a07a48')
VINE = ramp('#5a9a48')
HOOF = ramp('#635241')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 15, 51, 50)
    tN = knob('T', 'double', 32, 15, 0, -1, r=5.4 * k)
    tW = knob("T", "double", 13, 44, -1, 0, r=4.8 * k)
    tE = knob("T", "double", 51, 44, 1, 0, r=4.8 * k)
    tS = knob('T', 'double', 32, 50, 0, 1, r=5.0 * k)
    # vine leaves behind the hat (the picture's vine rows)
    c.add(c.m(core), VINE)
    # pointy straw hat: the cone runs up into the N tab, so the hat tip IS the tab
    cone = poly([(32, 1), (47, 27), (17, 27)])
    c.add(c.m(cone) & c.m(core, tN), STRAW)
    c.add(c.m(tN, minus=(core, cone)), STRAW)
    brim = rect(13, 25.5, 51, 30)
    c.add(c.m(brim), STRAW)
    c.add(c.m(poly([(24.5, 19), (39.5, 19), (41, 22), (23, 22)])), GRAPE)   # purple hat band
    c.edge(c.m(cone) & c.m(core, tN), STRAW[1])
    face = c.m(rect(13, 30, 51, 40))
    c.add(face, CREAMR)
    # basket with handles, a row of grape bunches at its rim
    bask = c.m(rect(13, 40, 51, 50), tW, tE)
    c.add(bask, WICKER)
    grapes = c.m(*[ell(gx, 43, 3.6, 3.0) for gx in (18, 25, 32, 39, 46)])
    c.add(grapes & c.m(core), GRAPE)
    c.add(c.m(tS, minus=(core,)) | (c.m(tS) & c.m(rect(0, 48, 64, 51))), HOOF)
    c.edge(c.m(brim), STRAW[1])
    c.edge(grapes & c.m(core), GRAPE[1])
    for gx in (18, 25, 32, 39, 46):
        c.px(*c.P(gx - 1.2, 42), GRAPE[2])
    weave = c.m(rect(0, 46, 64, 50), tW, tE) & bask
    for (x, y) in weave:
        if (x + (y // 2) * 2) % 4 == 0 and y % 2 == 0:
            c.px(x, y, WICKER[1])
    # leaf veins
    if not c.small:
        for (lx, ly) in [(15, 18), (47, 18), (16, 23), (46, 23)]:
            c.px(*c.P(lx, ly), VINE[2])
            c.px(c.P(lx, ly)[0] + 1, c.P(lx, ly)[1] + 1, VINE[2])
    c.eye(26, 33.5)
    c.eye(38, 33.5)
    c.blush(21, 36)
    c.blush(42, 36)
    c.smile(32, 35.5)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wgoa-4', 'Harvest Hat Parade', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgoa-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgoa-4.png'))
