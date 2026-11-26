# Concept: a jade dragonfly seen from above that IS an inner-TTTT piece with double knobs: N double tab = the two big blue compound eyes,
# E and W double tabs = paired wing tips (fore + hind), S double tab = forked tail tip; the square core is four pale wing panels
# with veins (the cell 4-3 is a pale sea-glass wing tip over the teal pond) split by a jade-green segmented body.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path, ramp

WING = ramp('#a6dcd0')
JADE = ramp('#3fae86')
EYEB = ramp('#5ab4dc')
TEALD = '#1a6770'
VEIN = '#6fb4a8'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(12, 18, 52, 50)
    tN = knob('T', 'double', 32, 18, 0, -1, r=7.2 * k)
    tE = knob('T', 'double', 52, 34, 1, 0, r=6.6 * k)
    tW = knob('T', 'double', 12, 34, -1, 0, r=6.6 * k)
    tS = knob('T', 'double', 32, 51, 0, 1, r=4.6 * k)
    # wings: core + side tabs, pale sea glass
    wings = c.m(core, tE, tW, minus=(ell(12, 18, 3.2, 3.2), ell(52, 18, 3.2, 3.2), ell(12, 50, 3.2, 3.2), ell(52, 50, 3.2, 3.2)))
    c.add(wings, WING)
    # veins: fore/hind wing split + a few long veins
    for side in (-1, 1):
        x0, x1 = 32 + side * 4, 32 + side * 27
        c.line([(x0, 33.5), (x1, 33.5)], TEALD)
        if not c.small:
            c.line([(x0, 26), (x1 - side * 6, 29.5)], VEIN)
            c.line([(x0, 41), (x1 - side * 6, 38)], VEIN)
            c.line([(x0, 30), (x1 - side * 2, 31.5)], VEIN)
            c.line([(x0, 37), (x1 - side * 2, 36)], VEIN)
            c.line([(x0, 20.5), (x1 - side * 3, 21)], VEIN)
            c.line([(x0, 46.5), (x1 - side * 3, 46)], VEIN)
        else:
            c.line([(x0, 26), (x1 - side * 8, 29)], VEIN)
            c.line([(x0, 42), (x1 - side * 8, 39)], VEIN)
    # wing-tip spots (the red-brown pterostigma in the picture)
    for sx in (61, 3):
        c.add(c.m(ell(sx, 30.5, 1.6 if not c.small else 2.0, 1.4 if not c.small else 1.8)), ramp('#a8503a'))
    # body: thorax + segmented abdomen down the middle, into the S tab (tail)
    bw = 8.5 if not c.small else 9.0
    c.add(c.m(ell(32, 26, 7.5, 8)), JADE)
    abd = c.m(rect(32 - bw / 2 + 1, 28, 32 + bw / 2 - 1, 52))
    c.add(abd, JADE)
    tail = c.m(tS, minus=(rect(0, 0, 64, 51),))
    c.add(tail | (c.m(tS) & c.m(rect(0, 50, 64, 53))), ramp('#2f8f70'))
    for y in (34, 39, 44, 49):
        a, b = c.P(29, y), c.P(35, y)
        for x in range(a[0], b[0]):
            if (x, a[1]) in abd:
                c.px(x, a[1], JADE[1])
    # eyes: N double tab in blue
    eyes = c.m(tN, minus=(rect(0, 18.5, 64, 64),)) | (c.m(tN) & c.m(rect(0, 17, 64, 20)))
    c.add(eyes, EYEB)
    c.edge(eyes, '#2f7fa8')
    c.eye(27.5, 9.5, disc=True)
    c.eye(36.5, 9.5, disc=True)
    c.smile(32, 25 if not c.small else 25.5)
    c.blush(27, 24)
    c.blush(36, 24)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-jdf-4', 'Jadewing Quartet', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-jdf-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-jdf-4.png'))
