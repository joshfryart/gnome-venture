# Concept: a pink cloth seed bundle (furoshiki) sitting on a lime lily pad in teal water; inner-BBBB keyhole:
# top blank = gap between the two knot tufts, side blanks bite the bundle's waist, bottom blank = the lily pad's notch.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

PINK = K.ramp('#d88fb0')
KNOT = K.ramp('#b8638e')
PAD = K.ramp('#9ddc71')
WATER = K.ramp('#3a9e90')
CORD = '#713362'
SEED = '#7a4a1f'


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 3.0 * k
    core = [K.rect(10, 14, 54, 54), K.rect(14, 10, 50, 58), K.ell(14, 14, 4, 4), K.ell(50, 14, 4, 4),
            K.ell(14, 54, 4, 4), K.ell(50, 54, 4, 4), K.rect(10, 14, 54, 54)]
    tufts = [K.poly([(27, 12), (12, 4), (8, 8), (9, 15), (14, 18), (27, 15)]), K.poly([(37, 12), (52, 4), (56, 8), (55, 15), (50, 18), (37, 15)])]
    blanks = [K.knob('B', 'keyhole', 32, 6, 0, -1, r), K.knob('B', 'keyhole', 10, 32, -1, 0, r),
              K.knob('B', 'keyhole', 54, 32, 1, 0, r), K.knob('B', 'keyhole', 32, 58, 0, 1, r)]
    body = c.m(*core, *tufts, K.ell(32, 50, 26, 6.5), minus=blanks)
    c.add(body, WATER)
    pad = c.m(K.ell(32, 50, 26, 6.5), minus=blanks) & body
    c.add(pad, PAD)
    bundle = c.m(K.ell(32, 33, 22, 16), K.rect(10, 12, 54, 38), K.rect(14, 10, 50, 38), minus=blanks) & body
    c.add(bundle, PINK, stitch=None if c.small else '#f8bdcc')
    knot = c.m(*tufts, minus=blanks) & body
    c.add(knot, KNOT)
    c.edge(knot, CORD)
    c.edge(pad, WATER[1])
    # parcel string: a cross from the bow down to the pad
    cord = c.m(K.rect(9, 20, 55, 22.6), K.rect(30.7, 11, 33.3, 44)) & bundle
    c.add(cord, K.ramp(CORD))
    # lily pad veins
    if not c.small:
        c.line([(32, 50), (20, 47)], PAD[1]); c.line([(32, 50), (44, 47)], PAD[1])
    # water ripples at the bottom corners
    c.line([(12, 54), (16, 54)], WATER[2]); c.line([(48, 54), (52, 54)], WATER[2])
    c.eye(24, 30, disc=True); c.eye(40, 30, disc=True)
    c.smile(32, 36, col='#fbe0ea', wide=True)
    c.blush(19, 34); c.blush(44, 34)


K.render_pal(fn, 'pl-wdol-5', 'Parcel on a Pad', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wdol-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wdol-5.png')
