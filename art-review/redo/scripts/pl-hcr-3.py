"""pl-hcr-3 Gust Ribbon: a little storm gust that is an inner-TBTB piece (double tabs W and E, double blanks N and S).
Its body is a puff of the picture's storm-sky purple, a pale wind ribbon spirals around its face (the eye of the storm),
the ribbon flicks out of the top-right corner as a curled wisp, and a coral leaf (the crab's red) rides out the bottom-left corner.
Rain streaks from cell 7-2 on the body."""
import sys, math
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SKY = K.ramp('#5a5684')
MIST = ('#9a92aa', '#7a7498', '#c8c4dc')
RIB = ('#b4b0cc', '#8a84aa', '#e4e0f0')
LEAF = ('#ec6d54', '#b8402e', '#ff9a7a')
RAIN = '#b4b0cc'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(15, 15, 49, 49)
    tabW = K.knob('T', 'double', 15, 32, -1, 0, r=4.8 * k)
    tabE = K.knob('T', 'double', 49, 32, 1, 0, r=4.8 * k)
    blN = K.knob('B', 'double', 32, 15, 0, -1, r=4.2 * k)
    blS = K.knob('B', 'double', 32, 49, 0, 1, r=4.2 * k)
    body = c.m(core, tabW, tabE, minus=(blN, blS))
    c.add(body, SKY, stitch=None if c.small else '#7a7498')
    w = 4.4 if c.small else 3.6

    def curl(x0, y0, x1, cy, r, down):
        # a wind-icon stroke: straight run, then a round curl at its end
        pts = [(x0, y0), (x1, y0)]
        for i in range(1, 15):
            t = i / 14 * 1.45 * math.pi
            rr = r * (1 - 0.5 * i / 14)
            sgn = 1 if down else -1
            pts.append((x1 + rr * math.sin(t), cy - sgn * rr * math.cos(t)))
        return K.thick_path(pts, w)
    # two gust strokes run across the body and curl off the right corners (wind icon)
    top = c.m(curl(19, 21, 49, 15.5, 5.5, False), minus=(blN,))
    bot = c.m(curl(22, 43, 46, 48.5, 5.5, True), minus=(blS,))
    c.add(top, RIB)
    c.add(bot, RIB)
    # short wisp flicking off the left
    c.add(c.m(K.thick_path([(20, 26), (8, 24), (4, 21)], w * 0.85)), RIB)
    # coral leaf riding the gust out of the bottom-left corner, midrib and stem
    leaf = c.m(K.poly([(2, 57), (4, 50), (9, 46), (17, 45.5), (16, 51), (11, 56), (5, 58)]), K.thick_path([(17, 47), (20, 44)], 2.6))
    c.add(leaf, LEAF)
    c.line([(3, 57), (15, 47)], LEAF[1])
    # rain streaks (cell 7-2)
    if not c.small:
        for (x0, y0) in ((41, 25), (24, 35), (43, 36)):
            c.line([(x0, y0), (x0 - 1.5, y0 + 4)], RAIN)
    # face in the eye of the storm
    c.eye(28.5, 31, disc=True)
    c.eye(35.5, 31, disc=True)
    c.smile(32, 36.5, '#e4e0f0' if not c.small else CREAMY)
    c.blush(25, 35)
    c.blush(38, 35)


CREAMY = '#f2e4c0'

K.render_pal(fn, 'pl-hcr-3', 'Gust Ribbon', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-hcr-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-hcr-3.png')
