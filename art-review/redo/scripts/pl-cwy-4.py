# Spine Spark: an ember hedgehog that is an inner-TTTT piece; four double-knob tabs are its four spark-spikes,
# forge-fire colours from cell 4-3 (orange body, red quills, yellow face and spark tips).
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp

ORANGE = ramp('#f26a2c')
RED = ramp('#c8402c')
YEL = ramp('#ffb43c')
PALE = ramp('#ffe66a')
NOSE = '#4a2c1a'


def fn(c):
    # side view: quilled back up and left, face to the right; E tab = snout, S tab = feet, N and W tabs = spark quills
    k = 1.15 if c.small else 1.0
    core = rect(12, 18, 50, 50)
    tN = knob('T', 'double', 28, 18, 0, -1, r=4.8 * k)
    tW = knob('T', 'double', 12, 32, -1, 0, r=4.6 * k)
    tE = knob('T', 'double', 50, 36, 1, 0, r=4.4 * k)
    tS = knob('T', 'double', 32, 50, 0, 1, r=4.4 * k)
    q = 3.2 if c.small else 2.6
    quills = []
    for x in (16, 39, 45):          # quills on the top edge
        quills.append(poly([(x - q, 18.5), (x + q, 18.5), (x + 1.5, 12.5)]))
    for y in (22, 42):              # quills on the left edge
        quills.append(poly([(12.5, y - q), (12.5, y + q), (7, y - 1.5)]))
    body = c.m(core, tN, tW, tE, tS, *quills)
    c.add(body, YEL)
    # red quill coat over the back and top; the yellow face and belly sit in the lower right
    face = ell(45, 38, 12, 10.5)
    def hemzig(x, y):   # zigzag edge just outside the face: a fringe of quills
        import math
        d = ((x - 45) / 12) ** 2 + ((y - 38) / 10.5) ** 2
        ang = math.atan2(y - 38, x - 45)
        return d < 1.0 + 0.45 * (1 + math.sin(ang * 9)) / 2
    belly = rect(18, 45, 64, 64)
    c.add(body & c.m(core, *quills, tN, tW, minus=(hemzig, belly)), RED)
    c.add(body & c.m(hemzig, minus=(face, belly, tE, tS)), ORANGE)
    # spark tips on the N and W tabs
    c.add(c.m(tN, minus=(rect(0, 9.5, 64, 64),)), PALE)
    c.add(c.m(tW, minus=(rect(7, 0, 64, 64),)), PALE)
    # feet
    c.add(c.m(tS, minus=(rect(0, 0, 64, 52),)), ORANGE)
    # face: eye, nose at snout tip, blush
    c.eye(41, 31)
    nx, ny = c.P(57.5, 35.5)
    for dx in ((-1, 0, 1) if not c.small else (0, 1)):
        for dy in ((0, 1) if not c.small else (0,)):
            c.px(nx + dx, ny + dy, NOSE)
    c.smile(50, 41)
    c.blush(43, 37)
    # glowing quill tips (the sparkler spikes)
    for (tx, ty) in [(17.5, 13.5), (40.5, 13.5), (46.5, 13.5), (8, 20.5), (8, 40.5)]:
        c.px(*c.P(tx, ty), PALE[0])
    # sparks on the coat (64 only)
    if not c.small:
        for (sx, sy) in ((19, 30), (36, 23)):
            x, y = c.P(sx, sy)
            for d in (-1, 0, 1):
                c.px(x + d, y, PALE[0]); c.px(x, y + d, PALE[0])


K.render_pal(fn, 'pl-cwy-4', 'Spine Spark', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cwy-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cwy-4.png')
