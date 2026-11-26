"""pl-scr-6 Sandlit Scarab Charm. whimsy-scarab, double knobs. A carved sandstone scarab charm seen from above: head + clypeus N,
double tab E (clawed foreleg), double blank W, double blank S where the wing-case seam ends. Sandstone tans/browns from cell 4-5
(tomb wall with carved grooves), teal faience trim and red jewel from the picture's scarab."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SAND = K.ramp('#d9a46c')
STONE = K.ramp('#a8684e')
DEEP = K.ramp('#7a4a3a')
TEAL = K.ramp('#2aa8a0')
JEWEL = K.ramp('#d8302a')
LEG = K.ramp('#6a4030')


def fn(c):
    k = 1.15 if c.small else 1.0
    # wing cases: wide dome, straight E/W sides between the knobs, round bottom
    ely = lambda x, y: (11 <= x < 53 and 30 <= y < 46) or K.ell(32, 44, 21, 13)(x, y)
    pron = lambda x, y: K.ell(32, 31, 21, 10)(x, y) and y < 31.5
    # flat toothed head (clypeus) with a sawtooth front edge
    head = lambda x, y: K.ell(32, 20, 10.5, 6.5)(x, y) or (K.ell(32, 14.2, 6, 2.4)(x, y) and abs(x - 32) > 1.6)
    tabE = K.knob('T', 'double', 53, 40, 1, 0, r=4.4 * k)
    blankW = K.knob('B', 'double', 11, 40, -1, 0, r=3.8 * k)
    blankS = K.knob('B', 'double', 32, 57, 0, 1, r=3.8 * k)
    lw = 3.0 if not c.small else 3.6
    legs = [K.thick_path([(19, 52), (12, 57), (9, 62)], lw), K.thick_path([(45, 52), (52, 57), (55, 62)], lw),
            K.thick_path([(18, 26), (11, 23), (7, 17)], lw), K.thick_path([(46, 26), (53, 23), (57, 17)], lw)]
    c.add(c.m(*legs), LEG)
    c.add(c.m(tabE, minus=(ely,)), LEG)
    body = c.m(ely, minus=(blankW, blankS))
    c.add(body, TEAL, stitch=None)
    c.add(c.m(head), DEEP)
    pm = c.m(pron)
    c.add(pm, SAND)
    # sandstone carved border round the wing cases
    inner = c.m(lambda x, y: (14 <= x < 50 and 33 <= y < 46) or K.ell(32, 44, 18, 10)(x, y), minus=(K.knob('B', 'double', 11, 40, -1, 0, r=6.4 * k), K.knob('B', 'double', 32, 57, 0, 1, r=6.4 * k)))
    c.edge(inner, SAND[0])
    # wing-case seam down to the S blank
    sx = c.P(32, 0)[0]
    for y in range(c.P(0, 32)[1], c.P(0, 52)[1]):
        if (sx, y) in body:
            c.px(sx, y, SAND[0])
    # carved grooves on the pronotum like the tomb wall
    if not c.small:
        y = c.P(0, 27)[1]
        for x in range(c.P(20, 0)[0], c.P(44, 0)[0]):
            if (x, y) in pm and abs(x - sx) > 4:
                c.px(x, y, SAND[1])
        for (x, y) in body:
            if (x + 2 * y) % 9 == 0 and (x, y) not in c.edges and abs(x - sx) > 1:
                c.px(x, y, TEAL[2])
    # red jewel set at the top of the seam
    jm = c.m(K.ell(32, 37, 4.6 * k, 3.8 * k))
    for (x, y) in jm:
        c.px(x, y, JEWEL[0])
    for (x, y) in jm:
        if (x + 1, y) not in jm or (x, y + 1) not in jm:
            c.px(x, y, JEWEL[1])
    jx, jy = c.P(30.4, 35.4)
    c.px(jx, jy, '#f8c0a0')
    if not c.small:
        c.px(jx + 1, jy, JEWEL[2])
    # felt eyes on the dark head
    c.eye(28, 19.5, disc=True)
    c.eye(36, 19.5, disc=True)


K.render_pal(fn, 'pl-scr-6', 'Sandlit Scarab Charm', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-scr-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-scr-6.png')
