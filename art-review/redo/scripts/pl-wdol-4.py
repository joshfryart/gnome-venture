"""pl-wdol-4 "Rosy Fin Salute": inner-TTTT, double. A pink river dolphin bobbing up out of the teal pool. The square core is its body (pink
melon dome on top, long beak, felt eye), the lower band is the cell's teal water with cream foam dashes. N double tab = the melon hump,
W double tab = the left flipper, E double tab = the raised flipper waving (salute), S double tab = a teal splash."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = K.ramp('#d77fb0')
PINK2 = K.ramp('#f0a6c8')
BEAK = K.ramp('#e894bc')
TEAL = K.ramp('#3fa896')
TEALD = K.ramp('#2e8a7c')
FOAM = '#d8f0dc'
LEAF = K.ramp('#7cc06a')


def fn(c):
    k = 1.15 if c.small else 1.0
    # core: square sides, top corners domed into the dolphin's bulbous melon
    core = lambda x, y: (13 <= x < 51 and 22 <= y < 51) or K.ell(32, 23, 19, 10)(x, y) and 13 <= x < 51 and y >= 13
    tN = K.knob('T', 'double', 32, 14, 0, -1, r=4.8 * k)
    tW = K.knob('T', 'double', 13, 25, -1, 0, r=4.4 * k)
    tE = K.knob('T', 'double', 51, 27, 1, 0, r=4.8 * k)
    tS = K.knob('T', 'double', 32, 51, 0, 1, r=4.8 * k)
    bw = 4.4 if not c.small else 5.2
    beak = K.thick_path([(20, 36), (10, 38.5), (3.5, 39.5)], bw)
    body = c.m(core, tN, tW, tE, tS, beak)
    water = c.m(lambda x, y: y >= 42 + (1 if (int(x) // 5) % 2 else 0) and x >= 12) & body
    pinkpart = body - water
    c.add(pinkpart, PINK, stitch=None)
    # lighter belly/throat patch above the water
    c.add(c.m(K.ell(33, 39, 13, 4.5)) & pinkpart, PINK2)
    c.add(c.m(beak) & pinkpart, BEAK)
    c.line([(22, 37.5), (11, 39.8)], PINK[1])   # mouth line along the beak
    c.add(water, TEAL)
    c.add(c.m(tS) & c.m(K.rect(0, 51, 64, 64)), TEALD)
    # foam dashes (from the cell)
    for (yy, xs) in ((45, (16, 26, 38)), (49, (21, 33, 44))):
        if c.small and yy == 49:
            continue
        y = c.P(0, yy)[1]
        for x0 in xs:
            a = c.P(x0, 0)[0]
            for x in range(a, a + (4 if not c.small else 2)):
                c.px(x, y, FOAM)
    # splash sparkle on the S tab
    c.px(*c.P(29, 56), FOAM)
    c.px(*c.P(35, 56), FOAM)
    # flipper crease on the raised E flipper
    c.line([(52, 23), (55, 30)], PINK[1])
    # melon highlight
    c.px(*c.P(26, 17), PINK2[2]); c.px(*c.P(27, 16), PINK2[2])
    c.eye(29, 29, disc=False)
    c.blush(34, 34)


K.render_pal(fn, 'pl-wdol-4', 'Rosy Fin Salute', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wdol-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wdol-4.png')
