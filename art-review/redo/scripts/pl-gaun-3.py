#!/usr/bin/env python3
"""pl-gaun-3 "Gourd Pass": a yerba-mate gourd that is an inner-TBTB round piece.
N round tab = the green yerba mound heaped in the mouth (silver bombilla straw rising from it), S round tab = the gourd's round foot,
round blanks E + W pinch the calabash waist. Fence-rail wood from cell 5-6 is the gourd's rim band; grass greens are the yerba."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROOT = '/home/user/gnome-venture'
GOURD = K.ramp('#c8844f')       # rail wood (208,139,86) a touch deeper
RAIL = K.ramp('#e8a868')        # light rail top
PLUM = '#66364a'                # dark fence post / rail shadow
YERBA = K.ramp('#b8b850')       # grass highlight
YERBA2 = K.ramp('#7a8a48')      # grass shade
SILVER = ('#c9c5bc', '#8a8680', '#f4f0e4')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(17, 20), (47, 20), (48, 25), (51, 29), (53, 34), (53, 47), (51, 52), (46, 56), (40, 58), (24, 58), (18, 56),
                   (13, 52), (11, 47), (11, 34), (13, 29), (16, 25)])
    tabN = K.knob('T', 'round', 32, 20, 0, -1, r=5.0 * k, nw=3.4)
    tabS = K.knob('T', 'round', 32, 57.5, 0, 1, r=3.6 * k, nw=3.0)
    blankE = K.knob('B', 'round', 53, 41, 1, 0, r=4.0 * k)
    blankW = K.knob('B', 'round', 11, 41, -1, 0, r=4.0 * k)
    cut = (blankE, blankW)
    body = c.m(core, minus=cut)
    c.add(body, GOURD, stitch=None if c.small else '#e8a868')
    # gourd foot (S tab) in the darker wood
    c.add(c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(K.rect(0, 56, 64, 59))), K.ramp('#a86c44'))
    # yerba heaped in the mouth: green fills the top of the neck and the N tab
    yer = c.m(tabN, minus=(K.rect(0, 20, 64, 64),)) | (body & c.m(K.rect(0, 0, 64, 23)))
    c.add(yer, YERBA)
    if not c.small:
        for (x, y) in yer:
            if (x * 3 + y * 5) % 7 == 0:
                c.px(x, y, YERBA2[0])
    # rim band: a fence rail around the mouth, plum shadow line under it
    rim = body & c.m(K.rect(0, 23, 64, 27.5))
    c.add(rim, RAIL)
    yb = c.P(0, 27.5)[1]
    for (x, y) in body:
        if y == yb:
            c.px(x, y, PLUM)
    # bombilla straw rising from the yerba, gold mouthpiece
    bw = 2.8 if not c.small else 3.2
    c.add(c.m(K.thick_path([(36, 17), (45, 6), (50, 5)], bw)), SILVER)
    c.add(c.m(K.thick_path([(48, 5), (52, 5)], bw)), K.ramp('#e8a317'))
    # second rail band low on the belly (fence motif)
    band = body & c.m(K.rect(0, 50, 64, 53))
    c.add(band, RAIL)
    for (x, y) in body:
        if y == c.P(0, 53)[1]:
            c.px(x, y, PLUM)
    # face on the calm belly
    c.eye(26, 38)
    c.eye(38, 38)
    c.smile(32, 42)
    c.blush(22, 42)
    c.blush(41, 42)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-gaun-3', 'Gourd Pass', ROOT + '/art-review/redo/out',
                       cellfile=ROOT + '/art-review/redo/_src/pl-gaun-3-cell.png',
                       oldfile=ROOT + '/game/assets/img/puzzles/pals/pl-gaun-3.png'))
