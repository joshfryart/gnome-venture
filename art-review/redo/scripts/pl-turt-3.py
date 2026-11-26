#!/usr/bin/env python3
"""pl-turt-3 "Wave Ribbon": inner-TBTB, round. A rolling moonlit sea wave that is an inner piece: the N tab is the wave's
curling lip (foam crest, purple night-sky hollow inside the barrel), the S tab its foot sliding up the sand, round blanks
pinch W and E. Ramps from cell 7-4: deep sea #2c3c88 / #2a4c94, foam band #5a8cb8, sky purple #5a4a98, moon-cream glints."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

DEEP = K.ramp('#2c3c88')
SEA = K.ramp('#2a4c94')
FOAMB = K.ramp('#5a8cb8')
SKY = K.ramp('#5a4a98')
FOAM = ('#e8eef4', '#a8c4dc', '#ffffff')
MOON = '#f2e4a8'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 20, 52, 54)
    tabN = K.knob('T', 'round', 36, 20, 0, -1, r=6.2 * k)
    tabS = K.knob('T', 'round', 28, 54, 0, 1, r=5.0 * k)
    blW = K.knob('B', 'round', 12, 45, -1, 0, r=4.6 * k)
    blE = K.knob('B', 'round', 52, 45, 1, 0, r=4.6 * k)
    rimw = 3.4 if not c.small else 3.8
    lipP = [(29, 21), (29.5, 12.5), (34, 7.5), (41, 7.2), (46, 10.5), (47, 15), (44.5, 17.5)]
    lipF = K.thick_path(lipP, rimw)
    body = c.m(core, tabN, tabS, lipF, minus=(blW, blE))
    c.add(body, DEEP)
    # mid-water band, wavy top
    import math
    mid = c.m(lambda x, y: y > 30 + 2.2 * math.sin(x / 4.0) and y < 49 - 1.8 * math.sin(x / 5.0 + 1)) & body
    c.add(mid, SEA)
    # light foam band along the top of the core: scalloped crest
    band = c.m(lambda x, y: y < 27.5 + 2.4 * abs(math.sin(x / 3.2)) and y >= 0) & body
    c.add(band, FOAMB)
    # white foam fringe: scallops hanging from the crest line, spilling off the lip
    fr = c.m(lambda x, y: 19 <= y < 22.2 + 1.8 * abs(math.sin(x / 3.2 + 0.6))) & body
    c.add(fr, FOAM)
    # the curling lip in the N tab: purple barrel hollow + white foam rim curling over to the right
    hollow = c.m(K.ell(38, 14.5, 4.6 * k, 4.2 * k)) & body
    c.add(hollow, SKY)
    lip = c.m(lipF) & body
    c.add(lip, FOAM)
    # foot of the wave (S tab): foam lace sliding onto sand
    foot = c.m(K.thick_path([(22.5, 60.5), (28, 63), (33.5, 60.5)], 2.8 if not c.small else 3.2)) & body
    c.add(foot, FOAM)
    # foam caps on the scallops + moon glints
    if not c.small:
        for x0 in (14, 24, 47):
            c.line([(x0, 23), (x0 + 3, 21.5)], FOAM[0])
        c.px(*c.P(21, 50), MOON); c.px(*c.P(22, 50), MOON)
        c.px(*c.P(37, 51), MOON); c.px(*c.P(38, 51), MOON); c.px(*c.P(36, 51), MOON)
        c.px(*c.P(40, 11), MOON)
    else:
        c.px(*c.P(16, 23), FOAM[0]); c.px(*c.P(48, 23), FOAM[0])
        c.px(*c.P(22, 50), MOON)
    # face on the calm deep water
    c.eye(25, 34, disc=True)
    c.eye(39, 34, disc=True)
    c.smile(32, 39, K.CREAM if not c.small else K.CREAM)
    c.blush(21, 38.5)
    c.blush(43, 38.5)


rep = K.render_pal(fn, 'pl-turt-3', 'Wave Ribbon', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-turt-3-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-turt-3.png')
print(rep)
