# Ember Speckle (pl-smk-3): a glowing ember coal from the smokecap caldera, inner-TBBB peg.
# Peg tab N carries a flame tuft; peg blanks W, E, S cut into the coal. Ash-purple crust (mushroom gills / sky of cell 5-3),
# glowing yellow speckle belly and orange cracks (the caldera rim glow and the salamander's yellow eye), cream hot-spot glints.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

CRUST = ramp('#5e3a68')
MAUVE = ramp('#a8507a')
GLOW = ramp('#f8c030')
FLAME = ramp('#f08a20')
HOT = ramp('#fbe9b0')
CRACK = '#e87a1c'


def fn(c):
    k = 1.15 if c.small else 1.0
    def core(x, y):
        # square-ish coal with softly rounded corners
        if not (9 <= x < 55 and 20 <= y < 58):
            return False
        for cx, cy in ((13, 24), (51, 24), (13, 54), (51, 54)):
            if (x < 13 if cx == 13 else x >= 51) and (y < 24 if cy == 24 else y >= 54):
                return (x - cx) ** 2 + (y - cy) ** 2 < 16
        return True
    tabN = knob('T', 'peg', 32, 20, 0, -1, r=4.8 * k)
    bW = knob('B', 'peg', 9, 40, -1, 0, r=3.8 * k)
    bE = knob('B', 'peg', 55, 40, 1, 0, r=3.8 * k)
    bS = knob('B', 'peg', 32, 58, 0, 1, r=3.8 * k)
    blanks = (bW, bE, bS)
    body = c.m(core, minus=blanks)
    c.add(body, CRUST, stitch=None if c.small else '#7e5490')
    # flame tuft on the peg tab
    flame = poly([(25.5, 21), (25.5, 13), (28, 8), (29.5, 11), (32, 3), (34.5, 10), (36, 7), (38.5, 13), (38.5, 21)])
    c.add(c.m(tabN, flame, minus=(core,)) | (c.m(tabN, flame) & c.m(rect(0, 18, 64, 21))), FLAME)
    c.add(c.m(poly([(28.5, 20), (28.5, 14), (30.5, 11), (32, 8), (34, 12), (35.5, 15), (35.5, 20)])), GLOW)
    # glowing speckle belly
    belly = c.m(ell(32, 37, 11, 9.5), minus=blanks)
    c.add(belly, GLOW)
    c.edge(belly, FLAME[1])
    # orange cracks running out across the crust
    w = 2.6 if c.small else 1.8
    for path in ([(21, 33), (18, 31), (19, 27), (14, 24)], [(43, 33), (46, 30), (45, 27), (50, 24)],
                 [(25, 45), (22, 47), (23, 51), (17, 54)], [(39, 45), (42, 48), (41, 52), (47, 54)],
                 [(22, 41), (16, 42)], [(42, 41), (48, 42)]):
        c.add(c.m(thick_path(path, w), minus=blanks) & body, (CRACK, FLAME[1], GLOW[2]))
    # hot cream glints (the mushroom stem cream)
    if not c.small:
        for (x, y) in ((20, 24), (44, 54), (14, 46), (50, 46)):
            c.px(*c.P(x, y), HOT[0])
    # face on the glowing belly
    c.eye(27.5, 36)
    c.eye(36.5, 36)
    c.smile(32, 41)
    c.blush(24, 40)
    c.blush(39, 40)


K.render_pal(fn, 'pl-smk-3', 'Ember Speckle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-smk-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-smk-3.png')
