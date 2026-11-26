import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""Brimful Pool, inner-TBTB keyhole: a sandstone basin brimming with blue water. N tab = the waterfall pouring in, S tab = an overflow
drop, E + W blanks bite into the stone. Sandstone tan, plum arch, vine green, pool blue with white sparkles (cell 5-6)."""
from pal_kit import rect, ell, poly, knob, thick_path

SAND = K.ramp('#d4b488')
RIM = K.ramp('#f0dcb4')
WATER = K.ramp('#4aa8d8')
FALL = K.ramp('#6cc0e8')
PLUM = K.ramp('#5a4560')
VINE = K.ramp('#3f9a4a')
SPARK = '#f4fbff'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(11, 16), (53, 16), (53, 48), (50, 53), (44, 55), (20, 55), (14, 53), (11, 48)])
    tabN = knob('T', 'keyhole', 32, 16, 0, -1, r=5.0 * k)
    tabS = knob('T', 'keyhole', 32, 55, 0, 1, r=4.2 * k)
    bE = knob('B', 'keyhole', 53, 44, 1, 0, r=3.6 * k, nw=2.2)
    bW = knob('B', 'keyhole', 11, 44, -1, 0, r=3.6 * k, nw=2.2)
    cut = (bE, bW)
    body = c.m(core, minus=cut)
    c.add(body, SAND, stitch=None)
    # stone courses (sandstone blocks like the terraces)
    if not c.small:
        for (x0, x1, y) in ((12, 52, 51),):
            c.line([(x0, y), (x1, y)], SAND[1])
        for (x, y0, y1) in ((22, 51, 55), (42, 51, 55)):
            c.line([(x, y0), (x, y1)], SAND[1])
    # brimming water: fills the top of the piece, swelling over the rim
    # stone rim (lighter ring) around an oval pool, water brimming to the lip
    rim = c.m(ell(32, 25, 21.5, 11.5)) & body
    c.add(rim, RIM)
    water = c.m(ell(32, 25, 18.5, 8.6)) & body
    c.add(water, WATER)
    c.edge(water, WATER[1])
    # N tab = the waterfall splash plume, S tab = overflow drop
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 14, 64, 17))), FALL)
    c.add(c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(rect(0, 53.5, 64, 56))), WATER)
    # thin falling stream down into the pool
    c.add(c.m(rect(30, 15, 34, 22)), FALL)
    # overflow trickles over the rim
    for x0 in (17, 47):
        c.add(c.m(thick_path([(x0, 31), (x0, 38)], 2.8 if c.small else 2.2)), WATER)
    # vines on the stone (cell green)
    for vx in (12.5, 51.5):
        c.add(c.m(thick_path([(vx, 17), (vx, 30)], 2.4 if c.small else 1.6)) & body, VINE)
    # sparkles + splash ripples
    for (sx, sy) in ((21, 23), (43, 22), (24, 29), (40, 29)):
        x, y = c.P(sx, sy)
        c.px(x, y, SPARK)
        if not c.small:
            c.px(x + 1, y, SPARK); c.px(x, y + 1, SPARK); c.px(x + 1, y + 1, SPARK)
    c.line([(26, 25), (29, 26)] if not c.small else [(27, 25), (28, 25)], SPARK)
    c.line([(35, 26), (38, 25)] if not c.small else [(36, 25), (37, 25)], SPARK)
    # face on the basin
    c.eye(25, 42)
    c.eye(39, 42)
    c.smile(32, 47 if c.small else 46.5, K.UMBER, wide=True)
    c.blush(20.5, 46)
    c.blush(42.5, 46)


K.render_pal(fn, 'pl-hang-3', 'Brimful Pool', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-hang-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-hang-3.png')
