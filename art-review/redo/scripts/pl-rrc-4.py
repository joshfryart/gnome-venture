"""pl-rrc-4 Saddle Stripes: a woven camel saddle blanket (kilim) that is an inner-TTTT piece with double knobs.
The square body is the blanket, woven in four sunset stripes from the canyon picture (lavender sky, mauve, rose cliff, sand gold);
the double tabs N/E/W/S are its paired woollen pom-pom tassels; cream kilim diamonds run along the middle band (the camel's cream coat, cell 7-7)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path

LAVS = K.ramp('#8c7cb8')
MAUVE = K.ramp('#b890b4')
ROSE = K.ramp('#d07a78')
SAND = K.ramp('#e8a850')
CAMEL = K.ramp('#f2dcb0')
RED = K.ramp('#c8483e')
TEALT = K.ramp('#3a9a9a')


def arch(x):
    t = (x - 32) / 21.0
    return 7.0 * max(0.0, 1 - t * t)


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 12, 18, 52, 52
    # blanket draped over the hump: top edge arches up 7 units in the middle
    core = lambda x, y: x0 <= x < x1 and y0 - arch(x) <= y < y1
    tN = knob('T', 'double', 32, y0 - 7, 0, -1, r=4.4 * k)
    tS = knob('T', 'double', 32, y1, 0, 1, r=4.6 * k)
    tW = knob('T', 'double', x0, 35, -1, 0, r=4.6 * k)
    tE = knob('T', 'double', x1, 35, 1, 0, r=4.6 * k)
    # fringe teeth along the bottom edge, between corners and the S tassel
    fringe = lambda x, y: y1 <= y < y1 + 2.2 and ((x0 + 1 < x < 25) or (39 < x < x1 - 1)) and int(x) % 2 == 0
    body = c.m(core)
    bands = [(-99, 22, LAVS), (22, 27, RED), (27, 39, MAUVE), (39, 45, SAND), (45, 99, ROSE)]
    for a, b, rp in bands:
        c.add(body & c.m(lambda x, y, a=a, b=b: a <= y + arch(x) * 0.55 < b), rp)
    c.add(c.m(fringe), CAMEL)
    # pommel (N): the wooden saddle horn on top of the hump; tassels E/W/S cream wool
    c.add(c.m(tN, minus=(core,)), K.ramp('#a8683a'))
    for t in (tS, tW, tE):
        c.add(c.m(t, minus=(core,)), CAMEL)
    # red wraps at tassel roots
    for t, rr in ((tW, rect(x0 - 3.2, 0, x0, 64)), (tE, rect(x1, 0, x1 + 3.2, 64)), (tS, rect(0, y1, 64, y1 + 3.2))):
        c.add(c.m(t) & c.m(rr), RED)
    # woven stripe dividers and kilim zigzags, following the arch
    for x in range(c.P(x0, 0)[0], c.P(x1, 0)[0]):
        X = (x + 0.5) / c.k
        for yy, col in ((22, K.UMBER2), (27, K.UMBER2), (39, K.UMBER2), (45, K.UMBER2)):
            if x % 2 == 0 and not c.small:
                c.px(x, int((yy - arch(X) * 0.55) * c.k), col)
        for yy, col in ((24.5, '#f2dcb0'), (42, '#f8f0dc')):
            yb = int((yy - arch(X) * 0.55) * c.k)
            if not c.small:
                d = x % 4
                c.px(x, yb + (1 if d in (1, 3) else (2 if d == 2 else 0)) - 1, col)
            else:
                c.px(x, yb + (x % 2), col)
    c.eye(25, 30, disc=False)
    c.eye(39, 30, disc=False)
    c.blush(20, 33)
    c.blush(43, 33)
    c.smile(32, 33)


K.render_pal(fn, 'pl-rrc-4', 'Saddle Stripes', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-rrc-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-rrc-4.png')
