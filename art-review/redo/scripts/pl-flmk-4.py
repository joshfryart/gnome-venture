#!/usr/bin/env python3
"""pl-flmk-4 Coconut Lookout. Inner-TTTT, peg: a coconut palm crown that IS the piece. Square core = the leafy crown (palm green from the
picture's corner palms) with a cluster of terracotta coconuts (the roof tiles of cell 6-1) nestled under it; N peg = the upright sprout
frond, E/W pegs = a coconut held out on each side, S peg = the ringed trunk. Sky blue from the cell as the frond highlight line."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

LEAF = K.ramp('#5aa34e')
LEAF2 = K.ramp('#78bc54')
NUT = ('#ec7e5c', '#d85c48', '#ffa070')
NUT2 = ('#d85c48', '#98503a', '#ec7e5c')
TRUNK = ('#b07a3a', '#7a4a1f', '#d9a35a')
VEIN = '#2f6a3a'
DEEP = ('#2f6a3a', '#22502a', '#3f8a44')
SKY = '#b8e4f4'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 13, 52, 47)
    tN = K.knob('T', 'peg', 32, 13, 0, -1, r=4.6 * k)
    tS = K.knob('T', 'peg', 32, 47, 0, 1, r=5.0 * k)
    tE = K.knob('T', 'peg', 52, 38, 1, 0, r=4.4 * k)
    tW = K.knob('T', 'peg', 12, 38, -1, 0, r=4.4 * k)
    body = c.m(core, tN, tS, tE, tW)
    c.add(body, LEAF)
    # trunk (S peg), ringed
    trunk = c.m(tS, minus=(core,)) | (c.m(tS) & c.m(K.rect(0, 45, 64, 48)))
    c.add(trunk, TRUNK)
    for yy in (50, 53.5):
        x0, y = c.P(27, yy)
        x1, _ = c.P(37, yy)
        for x in range(x0, x1 + 1):
            if (x, y) in trunk:
                c.px(x, y, TRUNK[1])
    # sprout frond (N peg) a lighter green with a centre vein
    sprout = c.m(tN, minus=(core,))
    c.add(sprout, LEAF2)
    # crown: separate feathered fronds fanning from the top centre over a deep-green shade, drooping to the sides
    c.add(c.m(core) & c.m(K.rect(0, 0, 64, 36)), DEEP)
    fronds = [[(32, 15), (24, 16), (17, 21), (14, 30)], [(32, 15), (40, 16), (47, 21), (50, 30)],
              [(32, 15), (27, 21), (24, 30)], [(32, 15), (37, 21), (40, 30)], [(32, 14), (32, 30)]]
    w = 7.2 if not c.small else 8.0
    for i, pts in enumerate(fronds):
        m = c.m(K.thick_path(pts, w)) & c.m(core)
        c.add(m, LEAF2 if i % 2 == 0 else LEAF)
        if not c.small:
            c.line(pts, VEIN)
    # coconut cluster across the lower body
    nuts = []
    for cx in (18.5, 32, 45.5):
        nuts.append(c.m(K.ell(cx, 40, 7.2, 7.2)) & c.m(core) | (c.m(K.rect(12, 41, 52, 47)) & c.m(K.ell(cx, 41, 7.2, 9))))
    c.add(c.m(K.rect(12, 34, 52, 47)) & c.m(lambda x, y: y > 36), NUT2)
    c.add(nuts[0] | nuts[2], NUT2)
    c.add(nuts[1], NUT)
    c.edge(nuts[1], NUT2[1])
    c.edge(nuts[0], NUT2[1])
    c.edge(nuts[2], NUT2[1])
    # frond tips droop over the outer coconuts (leaflet points) and feathered notches along the crown
    tips = c.m(K.poly([(12, 33), (17, 33), (14, 40.5), (12, 42)]), K.poly([(52, 33), (47, 33), (50, 40.5), (52, 42)]),
               K.poly([(23, 33), (28, 33), (25, 37.5)]), K.poly([(41, 33), (36, 33), (39, 37.5)])) & c.m(core)
    c.add(tips, LEAF)
    if not c.small:
        for (x, y) in list(c.m(core) & c.m(K.rect(13, 16, 51, 35))):
            if (x + 2 * y) % 6 == 0 and (x - 1, y) in tips | c.m(core) and y > 20 and (x < 20 or x > 44):
                c.px(x, y, DEEP[0])
    # side coconuts (E / W pegs)
    for t in (tE, tW):
        m = c.m(t, minus=(core,))
        c.add(m, NUT)
    c.line([(32, 4), (32, 13)], VEIN)
    if not c.small:
        c.line([(30, 5), (30, 9)], SKY)
    for cx, cy in ((7, 35.5), (57, 35.5), (19, 37), (45, 37)):
        c.px(*c.P(cx, cy), '#ffc8a0')
    # face on the middle coconut
    c.eye(29, 39, disc=False)
    c.eye(35.5, 39, disc=False)
    c.smile(32, 43)
    c.blush(26.5, 42)
    c.blush(37, 42)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-flmk-4', 'Coconut Lookout', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-flmk-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-flmk-4.png')
    print(rep)
