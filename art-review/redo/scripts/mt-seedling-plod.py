"""mt-seedling-plod: a rice-seedling clump creature that is an edge-TBB peg piece.
Flat S = the paddy waterline it plods through (muddy water band, two stubby feet), peg tab N = the seedling bundle's root collar with
three rice blades fanning out of it, peg blanks W and E cut into the green body. Body striped like the cell's paddy terraces
(greens + pale water bands from cell 6-4 of Monsoon Tangle), hay-bale tan feet."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, thick_path, knob

PADDY = K.ramp('#5aa848')
DEEP = K.ramp('#3f8a3c')
SHOOT = K.ramp('#8cc85a')
WATER = K.ramp('#a8d8c8')
MUD = K.ramp('#8a6236')
HAY = K.ramp('#c8a060')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(12, 26, 52, 58)
    tabN = knob('T', 'peg', 32, 26, 0, -1, r=5.0 * k)
    blW = knob('B', 'peg', 12, 40, -1, 0, r=4.4 * k)
    blE = knob('B', 'peg', 52, 40, 1, 0, r=4.4 * k)
    body = c.m(core, minus=(blW, blE))
    # rounded top corners of the clump
    body -= c.m(lambda x, y: (x < 14 or x >= 50) and y < 28)
    c.add(body, PADDY, stitch=None)
    # terrace bands across the body
    if True:
        t = lambda x, y: y - 0.01 * (x - 32) ** 2
        lw = 1.6 if c.small else 1.1
        c.add(c.m(lambda x, y: 31 <= t(x, y) < 46) & body, SHOOT)
        c.add(c.m(lambda x, y: 31 - lw <= t(x, y) < 31 or 46 <= t(x, y) < 46 + lw) & body, HAY)
    # water + mud band at the flat bottom (the paddy waterline)
    c.add(body & c.m(rect(0, 50, 64, 58)), WATER)
    if not c.small:
        for x in range(c.P(13, 0)[0], c.P(51, 0)[0]):
            if x % 4 == 0:
                c.px(x, c.P(0, 52.5)[1], WATER[2])
    # stubby plodding feet sitting in the water
    feet = c.m(ell(23, 56, 5, 3.6), ell(41, 56, 5, 3.6)) & c.m(core)
    c.add(feet, MUD)
    # peg tab = seedling root collar (hay twine) with blades fanning out
    tab = c.m(tabN, minus=(core,))
    c.add(tab, HAY)
    w = 4.2 if not c.small else 5.0
    blades = c.m(thick_path([(32, 16), (31, 9), (33, 2)], w),
                 thick_path([(29, 17), (23, 11), (16, 7)], w),
                 thick_path([(35, 17), (41, 11), (48, 7)], w))
    c.add(blades, SHOOT)
    # face on the top calm band
    c.add(c.m(rect(17, 27, 47, 31)) & body, PADDY)
    c.eye(25, 37)
    c.eye(39, 37)
    c.blush(21, 40)
    c.blush(42, 40)
    c.smile(32, 41.5)


K.render_pal(fn, 'mt-seedling-plod', 'Seedling Plod', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mt-seedling-plod-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mt-seedling-plod.png')
