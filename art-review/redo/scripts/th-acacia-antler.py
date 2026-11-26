"""th-acacia-antler: an acacia-sapling stag. inner-TTTT, tri knobs: a square straw-bark body (the hut-thatch / wood tans of cell 6-4)
with tri tabs on all four sides (top tab = crown tuft, left/right = flank tufts, bottom = root foot). Two branching twig antlers grow
from the top corners, each tine capped with a flat green acacia pad, and a straw weaver nest hangs from each outer tine."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, thick_path, knob, ramp, UMBER2

BARK = ramp('#d9a359')      # cell main tan
WOOD = ramp('#a8743a')      # cell dark plank
TWIG = ramp('#7a4f2a')
LEAF = ramp('#7b893a')      # acacia canopy green
NEST = ramp('#f7c870')      # straw / weaver nest
THATCH = ramp('#e2a93e')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(15, 24, 49, 56)
    tN = knob('T', 'tri', 32, 24, 0, -1, r=5.0 * k)
    tS = knob('T', 'tri', 32, 56, 0, 1, r=5.0 * k)
    tW = knob('T', 'tri', 15, 41, -1, 0, r=5.0 * k)
    tE = knob('T', 'tri', 49, 41, 1, 0, r=5.0 * k)
    w = 3.4 if not c.small else 3.8
    # antlers (behind body)
    L = [thick_path([(20, 26), (16, 16), (12, 8)], w), thick_path([(16, 16), (21, 9)], w * 0.9),
         thick_path([(14, 12), (7, 12)], w * 0.9)]
    R = [thick_path([(44, 26), (48, 16), (52, 8)], w), thick_path([(48, 16), (43, 9)], w * 0.9),
         thick_path([(50, 12), (57, 12)], w * 0.9)]
    c.add(c.m(*L, *R), TWIG)
    # flat acacia pads on the tine tips
    pads = [ell(11.5, 6, 5.6, 2.6), ell(22, 7.5, 4.4, 2.4), ell(42, 7.5, 4.4, 2.4), ell(52.5, 6, 5.6, 2.6)]
    c.add(c.m(*pads), LEAF)
    # weaver nests hanging from the side tines
    for nx in (7, 57):
        c.add(c.m(thick_path([(nx, 12), (nx, 15)], 1.6 if not c.small else 2.2)), TWIG)
        c.add(c.m(ell(nx, 18, 3.2, 3.6)), NEST)
        hx, hy = c.P(nx, 19.5)
        c.px(hx, hy, UMBER2)
        if not c.small:
            c.px(hx, hy + 1, UMBER2)
    # body
    body = c.m(core, tW, tE, tS)
    c.add(body, BARK, stitch=None if c.small else '#f1c88a')
    c.add(c.m(tN), THATCH)
    # plank / bark grain from the cell
    if not c.small:
        for gy in (47, 52):
            y = c.P(0, gy)[1]
            for x in range(c.P(18, 0)[0], c.P(46, 0)[0]):
                if (x + gy) % 9:
                    c.px(x, y, WOOD[0])
    else:
        y = c.P(0, 50)[1]
        for x in range(c.P(19, 0)[0], c.P(45, 0)[0]):
            c.px(x, y, WOOD[0])
    # root foot darker
    c.add(c.m(tS, minus=(core,)), WOOD)
    # muzzle and face
    c.add(c.m(ell(32, 41.5, 6.5, 4)), ramp('#f1c88a'))
    c.eye(25, 35)
    c.eye(39, 35)
    nx, ny = c.P(32, 39.5)
    for dx in ((-1, 0, 1) if not c.small else (0, 1)):
        c.px(nx + dx - (0 if not c.small else 1), ny, WOOD[1])
    if not c.small:
        c.px(nx, ny + 1, WOOD[1])
    c.smile(32, 42.5)
    c.blush(21, 39)
    c.blush(42, 39)


K.render_pal(fn, 'th-acacia-antler', 'Acacia Antler', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/th-acacia-antler-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/th-acacia-antler.png')
print(K.check(K.draw(fn, 64))['colours'])
