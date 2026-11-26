"""pl-spsk-2 Palm Sway: edge-TBT peg. A potted souk palm as an edge piece: flat S (the pot base), peg tabs W and E (frond tips),
peg blank N (the crown parts in the middle). Sky panels behind the trunk in the cell's dusk mauve/indigo, pot in souk saffron with the
red-and-gold checker of the souk floor."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

LEAF = K.ramp('#3f9a4a')
LEAF2 = K.ramp('#2f7a3e')
MAUVE = K.ramp('#9a5a8c')
INDIGO = K.ramp('#4a3a8a')
TRUNK = K.ramp('#b07a3a')
POT = K.ramp('#e7aa58')
RED = '#cf4f54'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(11, 12, 53, 57)
    tabW = K.knob('T', 'peg', 11, 25, -1, 0, r=4.6 * k)
    tabE = K.knob('T', 'peg', 53, 25, 1, 0, r=4.6 * k)
    blankN = K.knob('B', 'peg', 32, 12, 0, -1, r=3.6 * k)
    body = c.m(core, tabW, tabE, minus=(blankN,))
    # sky panel (cell colours: indigo top, mauve below)
    c.add(body, MAUVE)
    c.add(body & c.m(K.rect(0, 0, 64, 31)), INDIGO)
    # trunk, swaying, fat and ringed
    trunk = c.m(K.thick_path([(32, 20), (34, 33), (31.5, 48)], 12 if not c.small else 13))
    c.add(trunk & body, TRUNK)
    for yy in (30, 44) if not c.small else (31, 44):
        c.line([(27.5, yy), (37, yy + 1.5)], TRUNK[1])
    # canopy: a band of fronds along the top plus four drooping pointed fronds; the W/E tabs are frond tips
    band = K.rect(11, 12, 53, 21)
    fronds = [K.poly([(11, 16), (25, 20), (13, 34)]), K.poly([(17, 19), (31, 22), (21, 31)]),
              K.poly([(53, 16), (39, 20), (51, 34)]), K.poly([(47, 19), (33, 22), (43, 31)])]
    crown = c.m(band, tabW, tabE, *fronds) & body
    c.add(crown, LEAF)
    # leaflet hatching + light midribs
    if not c.small:
        for (x, y) in crown:
            if (x + y) % 4 == 0 and x < 32 or (x - y) % 4 == 0 and x >= 32:
                c.px(x, y, LEAF[1])
    for pts in ([(32, 18), (19, 15), (7, 21)], [(32, 18), (45, 15), (57, 21)], [(30, 19), (14, 32)], [(34, 19), (50, 32)],
                [(31, 20), (21, 30)], [(33, 20), (43, 30)]):
        c.line(pts, LEAF[2])
    # coconuts under the crown
    c.add(c.m(K.ell(28.5, 24, 2.8, 2.8), K.ell(36, 24, 2.8, 2.8)), K.ramp('#5a3418'))
    # pot: saffron with the souk floor checker band
    pot = c.m(K.rect(11, 47, 53, 57))
    c.add(pot, POT)
    c.edge(pot, POT[1])
    s = 4 if not c.small else 6
    y0, y1 = c.P(0, 50.5)[1], c.P(0, 54.5)[1]
    for (x, y) in pot:
        if y0 <= y < y1 and ((x // (s // 2 if not c.small else 2)) + (y - y0) // (2 if not c.small else 2)) % 2 == 0:
            c.px(x, y, RED)
    # face on the trunk
    c.eye(30, 35.5)
    c.eye(36.5, 35.5)
    c.smile(33, 39.5)
    c.blush(28, 39)


if __name__ == '__main__':
    r = K.render_pal(fn, 'pl-spsk-2', 'Palm Sway', '/home/user/gnome-venture/art-review/redo/out',
                     cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-spsk-2-cell.png',
                     oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-spsk-2.png')
    print(r)
