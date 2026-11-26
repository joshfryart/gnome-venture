import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp, UMBER, CREAM

CRAB = ramp('#e0583a')
CRABD = ramp('#b8402e')
SAND = ramp('#e8c888')
PALM = ramp('#3f9a4a')
TRUNK = ramp('#9a6a3a')
SEA = ramp('#2a8c9a')
STORM = ramp('#5a5a8c')
EYEW = ('#f4f0e4', '#c9c5bc', '#ffffff')
ROOT = '/home/user/gnome-venture/'


def fn(c):
    """whimsy-crab, peg: carapace = piece core; N peg tab = sand island with a palm; S peg blank between the legs;
    pincers raised at the upper corners; eyes on stalks. Crab red, sea teal, storm purple from the picture."""
    k = 1.15 if c.small else 1.0
    core = poly([(12, 27), (52, 27), (55, 32), (55, 47), (51, 52), (13, 52), (9, 47), (9, 32)])
    tabN = knob('T', 'peg', 32, 27, 0, -1, r=6.0 * k, nw=3.5)
    blankS = knob('B', 'peg', 32, 52, 0, 1, r=3.8 * k, nw=2.4)
    # legs: three per side, hanging below the carapace sides
    legs = []
    for x0, x1 in ((13, 8), (19, 16), (24.5, 23.5)):
        legs.append(thick_path([(x0, 49), (x1, 58)], 3.6 * k))
        legs.append(thick_path([(64 - x0, 49), (64 - x1, 58)], 3.6 * k))
    c.add(c.m(*legs, minus=(blankS,)), CRABD)
    # raised arms + pincers
    aw = 4.0 * k
    for s in (1, -1):
        X = lambda x: x if s == 1 else 64 - x
        c.add(c.m(thick_path([(X(12), 33), (X(7), 25), (X(7), 18)], aw)), CRABD)
        claw = c.m(ell(X(8), 13, 6.0, 6.5), minus=(poly([(X(8), 13), (X(5 if s == 1 else 5), 3), (X(13), 4)]),))
        c.add(claw, CRAB)
    body = c.m(core, minus=(blankS,))
    c.add(body, CRAB, stitch=CRAB[2] if False else None)
    # sea-teal water lapping at the island base, then the sand mound (the N peg tab)
    island = c.m(tabN, minus=(core,))
    c.add(island, SAND)
    c.add(c.m(rect(24, 25, 40, 28.5)), SEA)
    # palm: trunk and fronds
    c.add(c.m(thick_path([(33, 20), (34, 13), (32.5, 8)], 2.6 * k)), TRUNK)
    fr = c.m(thick_path([(22, 9), (27, 5), (32.5, 6.5)], 3.0 * k), thick_path([(43, 9), (38, 5), (32.5, 6.5)], 3.0 * k),
             thick_path([(25, 13), (29, 8), (32.5, 7)], 2.8 * k), thick_path([(40, 13), (36, 8), (32.5, 7)], 2.8 * k))
    c.add(fr, PALM)
    # eye stalks + white eyeballs (the cell's eye on the storm sky)
    for ex in (17.5, 46.5):
        c.add(c.m(rect(ex - 1.3 * k, 22, ex + 1.3 * k, 29)), CRABD)
        c.add(c.m(ell(ex, 21, 4.0 * k, 4.0 * k)), EYEW)
    c.eye(17.5, 21.5, look=(1, 0))
    c.eye(46.5, 21.5, look=(-1, 0))
    # storm-purple shell spots, smile
    for (x, y) in ((15, 41), (49, 41), (21, 46), (43, 46)):
        c.add(c.m(ell(x, y, 2.4 * k, 2.0 * k)), STORM)
    c.smile(32, 36, wide=True)
    c.blush(24, 35)
    c.blush(39, 35)


rep = K.render_pal(fn, 'pl-hcr-6', 'Gale Islander', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile=ROOT + 'art-review/redo/_src/pl-hcr-6-cell.png', oldfile=ROOT + 'game/assets/img/puzzles/pals/pl-hcr-6.png')
print(rep)
