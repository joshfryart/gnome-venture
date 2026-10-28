"""Gather tab scene, RAINFOREST land: game/assets/img/gather/scene-rainforest.png (480 x 270).

Usage: python3 -B aseprite-source/scenes-pil/gather_rainforest.py
Drawn on the 240 x 135 grid with pixlib. Same layout as every gather scene: far layer on top, ground from y ~54,
the shared open satchel at its fixed place (gather_common.draw_satchel), a clear landing spot left of it
(x 96..144, y 92..112: a big fallen leaf lying flat). Props sit left (x 8..90) and far right (x 216..236).
Focal prop: a giant orchid, far taller than a gnome, arching out of a mossy root stump with dripping blooms.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, W, H  # noqa: E402
from stops import bands, wave  # noqa: E402
from gather_common import draw_satchel, save_scene  # noqa: E402

MOSS = ramp('#4f9a45', '#2f6a3a', '#7ab55c', None, '#1f3f3a')
LEAF = ramp('#7ab55c', '#4f9a45', '#a4b86a')
DEEP = ramp('#2f6a3a', '#1f3f3a', '#4f9a45')
BARK = ramp('#7a4a1f', '#5c3420', '#9a6b3f', '#8a5a30')
PETAL = ramp('#e46a9b', '#b8457a', '#f6b8cf')
LIP = ramp('#7a5cc0', '#4e3a8a', '#c3b2ea')
GOLD = ramp('#e8a317', '#b07a10', '#f5cf6a')
EMBER = ramp('#d6322b', '#a8241f', '#f08a24')
INK = ramp('#3d2a1c', '#2a1a10', '#5c3420')

SKY, MIST, FAR1, FAR2, FAR3, FAR4 = '#cde6e8', '#dfe9d0', '#c4dcc0', '#a4c8b0', '#7ab58a', '#4f7a5a'
DROP = '#a9d6ea'


def top_edge(m, k=1):
    return m & ~shift(m, 0, k)


def bez(p0, p1, p2, t):
    return ((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0],
            (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1])


def drip(cv, x, y, n=2):
    """A falling drop with two trailing specks above it."""
    cv.fill(rect(x, y, x, y + 1), DROP)
    cv.dots([(x, y - 4), (x, y - 7)][:n], DROP)


def vine(cv, x, y0, y1, ph=0.0, col='#2f6a3a', leafc='#4f9a45'):
    pts = [(round(x + 2 * math.sin(y / 7.0 + ph)), y) for y in range(y0, y1 + 1)]
    cv.fill(line(pts), col)
    for i, (px, py) in enumerate(pts[4::6]):
        sg = 1 if i % 2 else -1
        cv.fill(rect(px + (1 if sg > 0 else -2), py, px + (2 if sg > 0 else -1), py + 1), leafc)
    return pts[-1]


def leaf_shape(cx, cy, ln, wd, ang):
    a = math.radians(ang)
    ca, sa = math.cos(a), math.sin(a)
    up, lo = [], []
    for k in range(21):
        s = k / 20
        half = wd / 2 * math.sin(math.pi * s) ** 0.8
        x, y = cx + ca * ln * s, cy + sa * ln * s
        up.append((round(x - sa * half), round(y + ca * half)))
        lo.append((round(x + sa * half), round(y - ca * half)))
    return poly(up + lo[::-1]), (ca, sa)


def big_leaf(cv, cx, cy, ln, wd, ang, rp=MOSS, slits=0):
    m, (ca, sa) = leaf_shape(cx, cy, ln, wd, ang)
    for k in range(1, slits + 1):
        s = k / (slits + 1)
        x, y = cx + ca * ln * s, cy + sa * ln * s
        for sg in (1, -1):
            ex, ey = x + sg * (-sa) * wd * 0.6 + ca * 3, y + sg * ca * wd * 0.6 + sa * 3
            mx, my = x + sg * (-sa) * wd * 0.2, y + sg * ca * wd * 0.2
            m &= ~line([(round(mx), round(my)), (round(ex), round(ey))], 1)
    o = cv.obj()
    o.part(m, rp, d=2)
    o.draw()
    cv.fill(line([(cx, cy), (round(cx + ca * ln * 0.9), round(cy + sa * ln * 0.9))]) & m, rp['r'])
    return m, (round(cx + ca * ln), round(cy + sa * ln))


def orchid(cv, cx, cy, s=1.0):
    """A big moth orchid bloom facing us: dorsal sepal, two broad petals, two lower sepals, violet lip, gold throat."""
    def e(a, b, c, d):
        return ell(cx + round(a * s), cy + round(b * s), cx + round(c * s), cy + round(d * s))
    o = cv.obj()
    o.part(e(-4, -11, 4, -1) | e(-8, 1, -1, 10) | e(1, 1, 8, 10), PETAL, d=1)   # sepals
    o.part(e(-12, -6, -1, 4), PETAL, d=2, contour=True)                             # left petal
    o.part(e(1, -6, 12, 4), PETAL, d=2, contour=True)                               # right petal
    o.part(e(-3, 0, 3, 8), LIP, d=1, contour=True)                                  # lip
    o.draw()
    cv.fill(e(-1, -2, 1, 1), GOLD['b'])
    cv.dots([(cx - 1, cy - 2)], GOLD['r'])
    # freckles on the petals
    for (dx, dy) in ((-6, -2), (-4, 0), (5, -2), (7, 0)):
        cv.dots([(cx + round(dx * s), cy + round(dy * s))], PETAL['s'])


def toucan(cv, x, y):
    """Perched toucan (facing left), x,y = top of head."""
    o = cv.obj()
    o.part(ell(x, y, x + 8, y + 12), INK, d=2)                                   # body
    o.part(rect(x + 5, y + 11, x + 8, y + 16), INK, d=1)                          # tail
    o.part(poly([(x + 1, y + 2), (x - 8, y + 4), (x - 8, y + 5), (x + 1, y + 6)]), EMBER, d=1, contour=True)  # bill
    o.part(ell(x, y + 3, x + 5, y + 9), ramp('#f2e4c0', '#f5cf6a', '#fff3c8'), d=0, contour=True)            # bib
    o.draw()
    cv.fill(line([(x - 7, y + 4), (x - 1, y + 3)]), GOLD['b'])                    # bill top stripe
    cv.dots([(x - 8, y + 5)], INK['b'])
    cv.dots([(x + 3, y + 2), (x + 3, y + 1), (x + 4, y + 2)], DROP)
    cv.dots([(x + 3, y + 2)], INK['s'])


def scene():
    cv = Canvas(SKY)
    # ---- sky + misty far canopy layers
    bands(cv, [(0, SKY), (18, MIST)])
    far = blank()
    for i, x in enumerate(range(-6, W + 8, 13)):
        h = 10 + (i * 7) % 8
        far |= ell(x, 36 - h, x + 16, 42)
    # emergent giants, flat haze: one tall left, one right
    for (cx, top, w) in ((58, 14, 34), (196, 18, 28)):
        far |= rect(cx - 1, top + 6, cx + 1, 42)
        far |= ell(cx - w // 2, top, cx + w // 2, top + 10) | ell(cx - w // 2 - 6, top + 6, cx - 2, top + 13) | ell(cx + 2, top + 5, cx + w // 2 + 6, top + 12)
    cv.fill(far | rect(0, 40, W - 1, H - 1), FAR1)
    cv.fill(top_edge(far, 1) & rect(0, 16, W - 1, H - 1), MIST)
    cv.fill(rrect(10, 40, 90, 41, 1) | rrect(150, 41, 230, 42, 1), MIST)      # mist strip
    mid = blank()
    for i, x in enumerate(range(-4, W + 6, 15)):
        h = 9 + (i * 11) % 7
        mid |= ell(x, 47 - h, x + 18, 52)
        mid |= rect(x + 8, 44, x + 9, 56)
    cv.fill(mid | rect(0, 48, W - 1, H - 1), FAR2)
    cv.fill(rrect(30, 48, 120, 49, 1) | rrect(170, 49, 236, 50, 1), FAR1)     # second mist strip
    near = wave(52, [(2, 40, 0.0), (1.5, 17, 1.0)])
    for i, x in enumerate(range(2, W, 17)):
        near |= ell(x, 48 + (i % 2) * 2, x + 20, 60)
    cv.fill(near, FAR3)
    cv.fill(top_edge(near, 1), FAR2)
    # ---- ground: dark loamy moss floor
    g = wave(57, [(1.0, 70, 0.4), (0.7, 27, 1.7)])
    cv.fill(g, MOSS['b'])
    cv.fill(top_edge(g, 2), LEAF['b'])
    cv.fill(g & rect(0, 64, W - 1, H - 1), DEEP['b'])
    cv.fill(top_edge(g & rect(0, 64, W - 1, H - 1), 1) & rect(0, 64, W - 1, 64), MOSS['b'])
    low = wave(112, [(1.5, 50, 0.3), (1.0, 19, 1.0)])
    cv.fill(low, DEEP['s'])
    # leaf litter flecks and fallen petals
    for y in range(68, H, 7):
        for x in range((y * 11) % 19, W, 21):
            c = MOSS['b'] if y < 112 else DEEP['b']
            cv.fill(rect(x, y, x + 2, y), c)
            cv.dots([(x + 1, y - 1)], c)
    # fallen leaves scattered on the floor (small flat ovals with a rib)
    for (x, y, c) in ((50, 120, LEAF['s']), (78, 100, GOLD['b']), (16, 128, GOLD['b']), (160, 116, LEAF['s']), (196, 108, GOLD['b']),
                      (94, 76, LEAF['s']), (134, 70, GOLD['b']), (176, 66, LEAF['s']), (64, 70, LEAF['s']), (120, 126, LEAF['s'])):
        cv.fill(ell(x, y, x + 6, y + 3), c)
        cv.fill(rect(x + 1, y + 1, x + 4, y + 1), DEEP['s'] if c == LEAF['s'] else BARK['b'])
    for (x, y) in ((70, 96), (88, 118), (60, 124), (150, 112), (226, 126), (36, 116), (196, 118)):
        cv.fill(rect(x, y, x + 1, y), PETAL['b'])
        cv.dots([(x, y - 1)], PETAL['r'])
    for (x, y) in ((92, 72), (128, 80), (220, 76), (110, 124), (174, 126)):
        cv.fill(rect(x, y, x + 2, y + 1), GOLD['s'])
        cv.dots([(x + 1, y)], GOLD['b'])

    # ---- canopy fringe at the top, with vines; corners stay a plain band
    cv.fill(rect(0, 0, W - 1, 3), DEEP['s'])
    can = blank()
    for (x0, x1, y1) in ((36, 58, 12), (52, 74, 16), (70, 92, 11), (150, 176, 10), (172, 200, 13)):
        can |= ell(x0, -10, x1, y1)
    o = cv.obj()
    o.part(can, DEEP, d=2)
    o.draw()
    cv.fill(rect(0, 0, W - 1, 2), DEEP['s'])
    tips = []
    for (x, y0, y1, ph) in ((44, 10, 34, 0.0), (66, 14, 48, 1.5), (84, 10, 30, 2.4), (188, 12, 26, 0.7)):
        tips.append(vine(cv, x, y0, y1, ph))
    for (x, y) in tips:
        drip(cv, x, y + 6)
    drip(cv, 60, 26, 1)
    drip(cv, 162, 20)

    # ---- right edge: liana with a perched toucan, monstera clump and a heliconia
    cv.fill(line([(240, 30), (226, 40), (214, 38)], 2), BARK['s'])
    cv.fill(line([(240, 29), (226, 39)], 1), BARK['b'])
    vine(cv, 230, 2, 36, 1.1, BARK['s'], LEAF['s'])
    toucan(cv, 222, 22)
    cv.fill(line([(208, 22), (206, 20)]) | line([(208, 26), (205, 26)]) | line([(208, 30), (206, 32)]), '#f2e4c0')  # its call
    big_leaf(cv, 236, 122, 34, 16, -120, MOSS, slits=3)
    big_leaf(cv, 242, 112, 28, 14, -150, LEAF, slits=2)
    _, tip = big_leaf(cv, 230, 128, 26, 12, -80, MOSS, slits=2)
    drip(cv, tip[0], tip[1] + 6)
    hx0 = 220
    cv.fill(rect(hx0, 74, hx0 + 1, 112), DEEP['b'])
    o = cv.obj()
    for k in range(4):
        y = 78 + k * 6
        sg = 1 if k % 2 else -1
        o.part(poly([(hx0 + (1 if sg > 0 else 0), y), (hx0 + sg * 8, y - 4), (hx0 + sg * 5, y + 3)]), EMBER, d=1)
    o.draw()
    for k in range(4):
        y = 78 + k * 6
        sg = 1 if k % 2 else -1
        cv.dots([(hx0 + sg * 7, y - 4), (hx0 + sg * 8, y - 4)], GOLD['r'])

    # ---- left: focal giant orchid out of a mossy root stump
    stump = poly([(10, 108), (14, 86), (16, 74), (30, 72), (34, 86), (40, 108)]) | ell(4, 102, 48, 112) & rect(0, 0, W, 108)
    o = cv.obj()
    o.part(stump, BARK, d=3)
    o.part(ell(13, 69, 34, 78), MOSS, d=1, contour=True)
    o.part(ell(10, 82, 20, 90), MOSS, d=1)
    o.draw()
    cv.fill(ell(17, 71, 30, 75), BARK['s'])           # hollow top
    for gx in (20, 26, 31):
        cv.fill(line([(gx, 92), (gx - 2 + (gx % 3), 106)]), BARK['s'])
    # surface roots creeping off the stump
    o = cv.obj()
    o.part(line([(38, 106), (54, 110), (70, 108), (82, 112)], 3), BARK, d=1)
    o.part(line([(8, 108), (2, 116)], 3), BARK, d=1)
    o.draw()
    # strap leaves at the base of the orchid
    big_leaf(cv, 26, 72, 26, 10, -170, LEAF)
    big_leaf(cv, 24, 74, 30, 11, -20, MOSS)
    big_leaf(cv, 28, 70, 22, 9, -60, LEAF)
    # the arching flower spike: up out of the stump, over and down to the right, blooms hanging under it
    p0, p1, p2 = (24, 68), (36, 4), (96, 40)
    pts = [bez(p0, p1, p2, k / 60) for k in range(61)]
    o = cv.obj()
    o.part(line([(round(x), round(y)) for x, y in pts], 2), DEEP, d=0)
    o.draw()
    for (t, sc, dy) in ((0.30, 0.95, 10), (0.58, 1.05, 10), (0.86, 0.9, 10)):
        x, y = bez(p0, p1, p2, t)
        bx, by = round(x), round(y) + dy
        cv.fill(line([(round(x), round(y)), (bx, by - 7)], 1), DEEP['b'])
        orchid(cv, bx, by, sc)
        drip(cv, bx + 1, by + round(10 * sc) + 6)
    xt, yt = p2
    o = cv.obj(); o.part(ell(xt - 2, yt, xt + 3, yt + 6), PETAL, d=1); o.draw()
    drip(cv, xt + 1, yt + 13)
    # small ferns / tufts on the floor
    for (x, y) in ((60, 92), (8, 124), (184, 120), (90, 82), (204, 112)):
        cv.dots([(x, y), (x + 2, y), (x + 1, y - 1), (x - 1, y - 2), (x + 3, y - 2)], LEAF['b'])

    # ---- landing spot: a giant fallen leaf lying flat (no outline, flat fills)
    cv.fill(ell(96, 100, 144, 113), DEEP['s'])
    lf, (ca, sa) = leaf_shape(98, 104, 46, 16, -6)
    cv.fill(lf, LEAF['b'])
    cv.fill(lf & ~shift(lf, 0, -2), MOSS['b'])
    cv.fill(line([(98, 105), (141, 101)]) & lf, LEAF['r'])
    for k in range(4):
        x = 106 + k * 9
        y = 105 - round(k * 0.9)
        cv.fill(line([(x, y), (x + 4, y - 5)]) & lf, MOSS['b'])
        cv.fill(line([(x, y), (x + 4, y + 4)]) & lf, MOSS['b'])
    cv.fill(rect(95, 104, 98, 105), DEEP['b'])        # stalk
    # ring of drops on the leaf (it just rained)
    cv.dots([(112, 100), (130, 103), (122, 108)], DROP)

    cv.remap({'#fff3c8': '#f2e4c0', '#c3b2ea': '#f6b8cf', '#b07a10': '#a8241f'})
    draw_satchel(cv)
    return cv


if __name__ == '__main__':
    cv = scene()
    save_scene(cv, 'rainforest')
    print('colours', cv.colours())
