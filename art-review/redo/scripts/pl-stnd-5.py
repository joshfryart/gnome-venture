# Concept: a buttercream full moon that IS an inner-BBBB piece: a squircle moon disc with a double-knob blank bitten into all four sides,
# craters and a lavender halo rim from the picture's moon, a drooping night-sky purple nightcap with a star pompom, sleepy moon face (cell 11-1 = night sky).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MOON = K.ramp('#f6eed8')
CRATER = K.ramp('#d3cbc8')
HALO = K.ramp('#8a80b8')
SKY = K.ramp('#463a80')
STAR = K.ramp('#f8e7a0')


def squircle(cx, cy, r, p=4.0):
    return lambda x, y: (abs(x - cx) / r) ** p + (abs(y - cy) / r) ** p < 1


def fn(c):
    k = 1.15 if c.small else 1.0
    cx, cy, R = 32, 35, 24
    core = squircle(cx, cy, R, 2.7)
    bl = [K.knob('B', 'double', cx, cy - R, 0, -1, r=3.9 * k),
          K.knob('B', 'double', cx, cy + R, 0, 1, r=3.9 * k),
          K.knob('B', 'double', cx + R, cy, 1, 0, r=3.9 * k),
          K.knob('B', 'double', cx - R, cy, -1, 0, r=3.9 * k)]
    body = c.m(core, minus=bl)
    c.add(body, HALO)
    inner = c.m(squircle(cx, cy, R - 2.6, 2.7), minus=bl)
    c.add(body & inner, MOON, stitch=None if c.small else '#e4d8b8')
    # shaded right crescent of the moon (waning shadow)
    c.add(body & inner & c.m(lambda x, y: (x - 25) ** 2 + (y - 32) ** 2 > 22 ** 2), CRATER)
    # craters
    for (x, y, rx) in ((41, 22, 3.8), (22, 47, 3.0), (45, 41, 2.6), (18, 26, 2.2)):
        m = body & c.m(K.ell(x, y, rx, rx * 0.8))
        c.add(m, CRATER)
        c.edge(m, CRATER[1])
    # nightcap: drooping cone from the top-left corner, sky purple, star pompom
    cap = K.poly([(12, 21), (22, 13), (17, 7), (10, 3), (5, 5), (7, 13)])
    capm = c.m(cap, minus=(core,))
    c.add(capm, SKY)
    band = c.m(K.thick_path([(11.5, 20.5), (22, 12)], 4.2))
    c.add(band, HALO)
    pom = c.m(K.ell(5.5, 6, 3.6, 3.6))
    c.add(pom, STAR)
    # face: sleepy closed eyes (arcs) + smile + blush
    for ex in (25, 39):
        x, y = c.P(ex, 33)
        if c.small:
            c.px(x - 1, y, K.UMBER); c.px(x, y + 1, K.UMBER); c.px(x + 1, y, K.UMBER)
        else:
            for dx in (-2, 2):
                c.px(x + dx, y, K.UMBER)
            for dx in (-1, 0, 1):
                c.px(x + dx, y + 1, K.UMBER)
    c.smile(32, 39)
    c.blush(21, 38)
    c.blush(42, 38)
    # a twinkle star beside the cap
    if not c.small:
        x, y = c.P(30, 7)
        for d in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
            pass


K.render_pal(fn, 'pl-stnd-5', 'Buttercream Moonlight', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-stnd-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-stnd-5.png')
