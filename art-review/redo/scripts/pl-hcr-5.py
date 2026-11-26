# pl-hcr-5 "Eye of the Storm": inner-BBBB, hook. A hurricane seen from above that IS a square piece: the four hook blanks are cut
# in pinwheel order so each comma-shaped bite reads as a wind curl, three pale spiral arms wheel round a calm round eye (the face),
# puffy cloud corners, rain streaks. Storm-sky purples and the pale rain lavender of cell 4-1.
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SKY = K.ramp('#44406e')
DEEP = ('#34315a', '#26234a', '#4e4a7a')
ARM = K.ramp('#8480b8')
EYE = ('#c8c4e0', '#9a96c0', '#ece8f8')
RAIN = '#b4b0cc'


def spiral(ph, t0, t1, a=6.5, b=0.30, cx=32, cy=32, steps=14):
    pts = []
    for i in range(steps + 1):
        t = t0 + (t1 - t0) * i / steps
        r = a * math.exp(b * t)
        pts.append((cx + r * math.cos(t + ph), cy + r * math.sin(t + ph)))
    return pts


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(8, 8, 56, 56)
    puffs = [K.ell(x, y, 8.5, 8.5) for x in (13, 51) for y in (13, 51)]
    side = [K.rect(12, 8, 52, 56), K.rect(8, 12, 56, 52)]
    blanks = (K.knob('B', 'hook', 32, 8, 0, -1, r=4.7 * k),
              K.knob('B', 'hook', 56, 32, 1, 0, r=4.7 * k),
              K.knob('B', 'hook', 32, 56, 0, 1, r=4.7 * k),
              K.knob('B', 'hook', 8, 32, -1, 0, r=4.7 * k))
    body = c.m(*side, *puffs, minus=blanks)
    c.add(body, DEEP, stitch=None)
    # mid cloud mass
    mid = c.m(K.ell(32, 32, 20, 20)) & body
    c.add(mid, SKY)
    c.edge(mid, DEEP[2])
    # three spiral arms
    w = 4.2 if c.small else 3.6
    for j in range(3):
        ph = j * 2 * math.pi / 3
        arm = c.m(K.thick_path(spiral(ph, 0.0, 4.3), w)) & body
        c.add(arm, ARM)
    # calm eye
    c.add(c.m(K.ell(32, 32, 9.5, 9.5)), EYE)
    # rain streaks in the corners
    for (x, y) in ((14, 12), (48, 44), (44, 14), (16, 46)):
        if c.small:
            c.line([(x, y), (x - 1.8, y + 4)], RAIN)
        else:
            c.line([(x, y), (x - 1.5, y + 4)], RAIN)
    c.eye(28.5, 31.5)
    c.eye(35.5, 31.5)
    c.smile(32, 35)
    c.blush(26, 35)
    c.blush(37.5, 35)


K.render_pal(fn, 'pl-hcr-5', 'Eye of the Storm', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-hcr-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-hcr-5.png')
