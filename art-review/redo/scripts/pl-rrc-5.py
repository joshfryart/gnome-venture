#!/usr/bin/env python3
"""pl-rrc-5 Lamplit Doorway. Inner-TTBB, round.
Concept: the rose-red rock-cut temple facade IS the piece: a broken pediment (N round blank = the gap in the roof), four carved columns,
a dark plum arched doorway as the mouth with lamplight inside; S round tab = the yellow pool of lamplight spilling out of the door,
E round tab = a gold hanging lamp on a bracket; W round blank bites the left wall. Colours from cell 5-5: rose column, plum door, lamp yellow.
"""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROSE = K.ramp('#e2998c')
PEACH = K.ramp('#f2c4a4')
COL = K.ramp('#d07a78')
ROOF = K.ramp('#9a4a66')
PLUM = ('#4a2440', '#2b1c26', '#6a3458')
LAMP = K.ramp('#f4d070')
GOLD = K.ramp('#d49a48')
CREAMY = K.ramp('#fbe2b0')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(11, 15, 51, 52)
    roof = K.poly([(8, 22), (32, 9), (56, 22)])
    blankN = K.knob('B', 'round', 32, 9.5, 0, -1, r=3.8 * k)
    blankW = K.knob('B', 'round', 11, 38, -1, 0, r=4.4 * k)
    tabS = K.knob('T', 'round', 32, 52, 0, 1, r=4.6 * k)
    tabE = K.knob('T', 'round', 51, 36, 1, 0, r=4.4 * k)
    cut = (blankN, blankW)
    body = c.m(core, roof, minus=cut)
    c.add(body, ROSE, stitch=None)
    # pediment (plum-rose roof band) and the cornice under it
    c.add(c.m(roof, minus=cut), ROOF)
    c.add(c.m(K.rect(9, 21, 55, 24.5), minus=cut), PEACH)
    # four columns
    for x0 in (14, 19.5, 40.5, 46):
        m = c.m(K.rect(x0, 24.5, x0 + 3.5, 52), minus=cut)
        c.add(m, COL)
    # base step
    c.add(c.m(K.rect(11, 49, 51, 52), minus=cut), PEACH)
    # doorway: dark plum arch with lamplight glowing from inside, spilling into the S tab
    door = c.m(K.rect(25, 37, 39, 52), K.ell(32, 37, 7, 6.5))
    c.add(door, PLUM)
    glow = c.m(K.rect(27, 42, 37, 52), K.ell(32, 42, 5, 4))
    c.add(glow, LAMP)
    c.add(c.m(tabS, minus=(core,)), CREAMY)
    c.add(c.m(tabS) & c.m(K.rect(0, 49, 64, 52)), CREAMY)
    c.add(c.m(K.ell(32, 45.5, 1.8, 2.6)), GOLD)
    c.add(c.m(K.ell(32, 45, 0.9, 1.4)), CREAMY)
    # hanging lamp on the E tab: bracket arm + gold lamp with a lit window
    c.add(c.m(tabE, minus=(core,)), GOLD)
    lx, ly = 51 + 4.4 * k + 1.6, 36
    win = c.m(K.ell(lx, ly, 2.0 * k, 2.4 * k))
    c.add(win, CREAMY)
    # face in the calm band above the door
    c.eye(27, 30, disc=False)
    c.eye(37, 30, disc=False)
    c.blush(23, 33)
    c.blush(40, 33)
    # bunting dots along the cornice (picture's pennant garland)
    if not c.small:
        for i, (fx, col) in enumerate(((14, '#3f9a9a'), (24, '#d6322b'), (40, '#f0c030'), (50, '#3f9a4a'))):
            x, y = c.P(fx, 23)
            c.px(x, y, col); c.px(x + 1, y, col); c.px(x, y + 1, col)


K.render_pal(fn, 'pl-rrc-5', 'Lamplit Doorway', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-rrc-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-rrc-5.png')
print(K.check(K.draw(fn, 64))['colours'])
