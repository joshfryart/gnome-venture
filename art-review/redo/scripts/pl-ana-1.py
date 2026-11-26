import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import math
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp, UMBER

# Corner-TT, peg: the anaconda's tail, coiled into one loop on the creek, its tapering tip crossing over the coil
# and poking up as the N peg tab (the tickler). Flat W + S (the coil rests in the teal creek strip), E peg tab =
# a bulge of the coil. Snake greens with dark anaconda spots + creek teal (cell 6-7).
GREEN = ramp('#6cb43c')
BELLY = ramp('#c8e47a')
DEEP = '#2f6a3a'
WATER = ramp('#2a8a8a')
TIP = ramp('#94cc52')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(9, 15, 53, 56)
    tabN = knob('T', 'peg', 33, 15, 0, -1, r=4.4 * k)
    tabE = knob('T', 'peg', 53, 33, 1, 0, r=4.6 * k)
    hole = ell(34, 33, 6.2 * (1.1 if c.small else 1.0), 6.6 * (1.1 if c.small else 1.0))
    body = c.m(core, tabN, tabE, minus=(hole,))
    c.add(body, GREEN)
    # spiral seam: one dark turn from the hole rim out to the outline, so the square reads as a coil
    pts = []
    for i in range(0, 46):
        a = -math.pi / 2 + i * 0.16
        r = 8.5 + i * 0.30
        pts.append((34 + r * math.cos(a), 33 + r * math.sin(a)))
    seam = c.m(thick_path(pts, 2.0 if not c.small else 2.6)) & body
    c.add(seam, (DEEP, DEEP, DEEP))
    # anaconda spots
    step = 6 if not c.small else 7
    for row, yy in enumerate(range(18, 47, step)):
        for xx in range(11 + (row % 2) * 3, 56, step):
            sx, sy = c.P(xx, yy)
            if (sx, sy) in body and (sx, sy) not in seam:
                c.px(sx, sy, DEEP)
                if not c.small and (sx + 1, sy) in body:
                    c.px(sx + 1, sy, DEEP)
    # creek strip
    water = body & c.m(rect(0, 47, 64, 64))
    c.add(water, WATER)
    for x in range(c.P(9, 0)[0], c.P(53, 0)[0] + 1):
        y = c.P(0, 47.5)[1] + (1 if (x // 3) % 2 else 0)
        c.px(x, y, '#7fd0c8')
    if not c.small:
        for x in range(c.P(14, 0)[0], c.P(50, 0)[0], 7):
            c.px(x, c.P(0, 52.5)[1], '#7fd0c8')
            c.px(x + 1, c.P(0, 52.5)[1], '#7fd0c8')
    # tapering tail tip: rises out of the water at the left, sweeps over the coil and up into the N peg
    segs = [(17, 50, 10), (16, 40, 9.5), (18, 30, 8.5), (24, 21, 7.5), (31, 15, 6.5), (33, 9, 6.0)]
    tail = set()
    for (ax, ay, aw), (bx, by, bw) in zip(segs, segs[1:]):
        tail |= c.m(thick_path([(ax, ay), (bx, by)], (aw + bw) / 2 * (1.05 if c.small else 1.0)))
    tail = (tail & body) | c.m(tabN, minus=(core,))
    c.add(tail, TIP)
    c.edge(tail, DEEP)
    # belly stripe on the tail
    c.add(c.m(thick_path([(19.5, 47), (19, 39), (21, 31), (26, 24), (32, 18)], 2.6 if not c.small else 2.8)) & tail, BELLY)
    # tickle curl at the very tip
    c.line([(31, 9), (33, 7), (35, 8.5), (34, 10.5)], DEEP)
    # face on the coil's right side, the calm area
    c.eye(41, 41.5)
    c.eye(47.5, 41.5)
    c.smile(44.3, 44.5)


rep = K.render_pal(fn, 'pl-ana-1', 'Tailtip Tickle', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-ana-1-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ana-1.png')
print(rep)
