"""pl-tegr-5 Buttermilk Daybreak: inner-BBBB, double. A pale buttermilk sun rising over a mint misty ridge: the sun is the domed
upper half of the piece (rounded ray nubs break the top outline), the mint ridge is the lower half; four double blanks.
Colours from cell 10-0 (sky teal, mint mist ridge, cream sun) and the picture's pale dawn sun."""
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SUN = K.ramp('#fbe7a0')
RAY = K.ramp('#f6cf62')
MINT = K.ramp('#b8e4d0')
TEALR = K.ramp('#6fbcc4')
MIST = '#e8f6ee'


def fn(c):
    k = 1.15 if c.small else 1.0
    cx, cy = 32, 36
    # square-ish core, top corners rounded into a sun dome
    core = lambda x, y: (10 <= x < 54 and 12 <= y < 56) and not (
        (y < 27 and ((x < 25 and (x - 25) ** 2 + (y - 27) ** 2 > 225) or (x > 39 and (x - 39) ** 2 + (y - 27) ** 2 > 225)))
        or (y > 52 and ((x < 13 and (x - 13) ** 2 + (y - 52) ** 2 > 9) or (x > 50 and (x - 50) ** 2 + (y - 52) ** 2 > 9))))
    bN = K.knob('B', 'double', 32, 12, 0, -1, r=3.4 * k)
    bS = K.knob('B', 'double', 32, 56, 0, 1, r=3.4 * k)
    bW = K.knob('B', 'double', 10, 34, -1, 0, r=3.2 * k)
    bE = K.knob('B', 'double', 54, 34, 1, 0, r=3.2 * k)
    rays = []
    for a in (-172, -148, -124, -56, -32, -8):
        t = math.radians(a)
        p0 = (cx + 19 * math.cos(t), 31 + 19 * math.sin(t))
        p1 = (cx + 24.5 * math.cos(t), 31 + 24.5 * math.sin(t))
        rays.append(K.thick_path([p0, p1], 5.4 if c.small else 4.6))
    blanks = (bN, bS, bW, bE)
    body = c.m(core, *rays, minus=blanks)
    c.add(c.m(*rays, minus=blanks), RAY)
    c.add(c.m(core, minus=blanks), SUN, stitch=None if c.small else '#f6cf62')
    # glowing inner sun disc
    c.add(c.m(K.ell(32, 30, 15, 15), minus=blanks) & body, K.ramp('#fff3c4'))
    c.edge(c.m(K.ell(32, 30, 15, 15)) & body, '#f6cf62')
    for q in [q for q in c.edges if q[1] >= c.P(0, 37)[1]]:
        del c.edges[q]
    # misty ridge: wavy hill line across the lower body
    ridge = lambda x, y: y > 40 + 2.5 * math.sin((x - 8) / 7.0) + (x - 32) * 0.06
    c.add(body & c.m(ridge), MINT)
    # far teal ridge peeking in a band, and a mist stripe
    far = lambda x, y: 40 + 2.5 * math.sin((x - 8) / 7.0) + (x - 32) * 0.06 < y < 44.5 + 1.5 * math.sin((x + 3) / 5.0)
    c.add(body & c.m(far), TEALR)
    mist = c.m(lambda x, y: 49 < y < 51.2 + 0.8 * math.sin(x / 3.0) and 16 < x < 48)
    for p in mist & body:
        c.px(p[0], p[1], MIST)
    # face on the sun
    c.eye(25.5, 26, look=(0, 0))
    c.eye(38.5, 26, look=(0, 0))
    c.smile(32, 31)
    c.blush(20, 30)
    c.blush(43, 30)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-tegr-5', 'Buttermilk Daybreak', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tegr-5-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tegr-5.png')
    print(rep)
