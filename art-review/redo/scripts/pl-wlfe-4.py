#!/usr/bin/env python3
"""pl-wlfe-4 "Beads on the Bridge": a red paper lantern that is an inner-TTTT piece with double knobs.
N tab = the plum hanging loop (pagoda-eave plum), S tab = the golden tassel, E + W tabs = red lantern lobes (paper bulging out).
Plum pagoda-eave caps top and bottom, glowing window-yellow centre panel, red ribs; colours from cell 6-3 (red, window yellow, plum eave, indigo)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#c8584a')
GLOW = K.ramp('#ffd070')
PLUM = K.ramp('#7a3a5a')
GOLDT = K.ramp('#e8a33a')
INDIGO = '#3a2c66'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(15, 17, 49, 49)
    capN = K.poly([(12, 19), (16, 13.5), (48, 13.5), (52, 19)])
    capS = K.poly([(12, 47), (52, 47), (48, 52.5), (16, 52.5)])
    tabN = K.knob('T', 'double', 32, 13.5, 0, -1, r=4.8 * k)
    tabS = K.knob('T', 'double', 32, 52.5, 0, 1, r=4.8 * k)
    tabE = K.knob('T', 'double', 49, 33, 1, 0, r=4.8 * k)
    tabW = K.knob('T', 'double', 15, 33, -1, 0, r=4.8 * k)
    belly = K.ell(32, 33, 19.5, 17.5)
    body = c.m(core, belly)
    c.add(body, RED)
    c.add(c.m(tabE, tabW, minus=(core, belly)), RED)
    # glowing centre panel
    glow = c.m(K.ell(32, 33, 9, 12.5))
    c.add(glow, GLOW)
    # ribs on the paper
    for sx in (-1, 1):
        for off, bow in ((11.5, 2.0), (16.5, 3.0)):
            x0 = 32 + sx * off
            c.line([(x0, 18.5), (x0 + sx * bow, 26), (x0 + sx * bow, 40), (x0, 47.5)], RED[1])
    caps = c.m(capN, capS)
    c.add(caps, PLUM)
    c.add(c.m(tabN, minus=(capN,)), PLUM)
    c.add(c.m(tabS, minus=(capS,)), GOLDT)
    # tassel strands
    if not c.small:
        for tx in (29.5, 32, 34.5):
            c.line([(tx, 56), (tx, 61)], GOLDT[1])
    # eave trim line
    for yy in (17.5, 48):
        c.line([(15, yy), (48.5, yy)], INDIGO if not c.small else PLUM[1])
    # face on the glow
    c.eye(28, 32)
    c.eye(36.5, 32)
    c.smile(32, 37)
    c.blush(24.5, 36)
    c.blush(39.5, 36)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wlfe-4', 'Beads on the Bridge', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wlfe-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wlfe-4.png'))
