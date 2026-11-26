# Concept: a red fly-agaric toadstool that IS a corner piece: flat left and bottom sides (mossy turf base + straight cap/moss side),
# a round blank bitten into the domed cap top and a round blank on the right side under the cap brim (exposing the stem);
# Mistmoor colours: fly-agaric red with cream spots, cream stem with felt face, olive moss turf with heather tufts.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

RED = K.ramp('#bd3f34')
SPOT = K.ramp('#f1ece0')
STEM = K.ramp('#e6e2d6')
MOSS = K.ramp('#657340')
DMOSS = K.ramp('#4c5630')
HEATH = K.ramp('#8a5a8e')
GILL = K.ramp('#c9a98a')
BROWN = K.ramp('#8f6a4a')


def fn(c):
    s = 1.15 if c.small else 1.0
    L, R, T, B = 8, 56, 8, 57
    # core: square with domed (rounded) top corners
    core = lambda x, y: (L <= x < R and T + 14 <= y < B) or (L + 14 <= x < R - 14 and T <= y < B) \
        or K.ell(L + 14, T + 14, 14, 14)(x, y) or K.ell(R - 14, T + 14, 14, 14)(x, y)
    bt = K.knob('B', 'round', 30, T, 0, -1, r=4.6 * s)
    br = K.knob('B', 'round', R, 41, 1, 0, r=4.6 * s)
    body = c.m(core, minus=(bt, br))
    # moss turf (whole body base, shows on lower half / left tuck)
    c.add(body, DMOSS)
    # stem
    stem = c.m(K.poly([(23, 30), (41, 30), (44, 53), (20, 53)]), minus=(bt, br))
    c.add(stem & body, STEM)
    # turf lip in front of the stem foot
    turf = c.m(K.ell(32, 55, 26, 5), K.rect(L, 52, R, B), minus=(br,))
    c.add(turf & body, MOSS)
    # cap (red dome, full width, ends at brim y=31)
    shade = c.m(K.rect(L, 31, R, 35)) & body
    c.add(shade - stem, ('#3a3f26', '#3a3f26', '#3a3f26'))
    c.add(shade & stem, GILL)
    cap = c.m(lambda x, y: y < 31 + 0.004 * (x - 32) ** 2, minus=(bt,)) & body
    c.add(cap, RED, stitch=RED[2])
    gill = c.m(lambda x, y: 29 + 0.004 * (x - 32) ** 2 <= y < 31 + 0.004 * (x - 32) ** 2) & body
    c.add(gill, GILL)
    c.edge(cap | gill, RED[1])
    # cream spots
    for (x, y, r) in ((19, 17, 3.4), (43, 14, 3.2), (25, 25, 2.6), (39, 23, 2.6), (51, 25, 2.2), (13, 27, 1.8)):
        if c.small and r < 2.2:
            continue
        c.add(c.m(K.ell(x, y, r * s, r * s)) & cap, SPOT)
    # heather tufts and a little brown bud in the left moss tuck
    for (x, y) in ((13, 50), (50, 52), (46, 49)):
        c.add(c.m(K.ell(x, y, 2.6 * s, 2.2 * s)) & body, HEATH)
    bud = c.m(K.ell(14, 39, 4.2, 3), K.rect(12.5, 39, 15.5, 45)) & body
    c.add(bud, BROWN)
    # face on the stem
    c.eye(28.5, 39)
    c.eye(36, 39)
    c.blush(25.5, 43)
    c.blush(38.5, 43)
    c.smile(32, 44)


K.render_pal(fn, 'mm-toadstool-tuck', 'Toadstool Tuck', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mm-toadstool-tuck-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mm-toadstool-tuck.png')
