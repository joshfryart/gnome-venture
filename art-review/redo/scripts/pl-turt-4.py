"""pl-turt-4 Hatchling Line: inner-TTTT, peg. A sea-turtle hatchling seen from above; its square shell is the piece core,
the four peg tabs are head (N), tail (S) and two flippers (W, E). Leaf-green shell with ring scutes and a dark rim (cell 4-5),
sea-blue belly peeking at the flipper roots."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

SHELL = ramp('#6aae4a')
RIM = ramp('#3f7a34')
SCUTE = ramp('#8cc85c')
SKIN = ramp('#a8d070')
SEA = ramp('#3a68b0')


def fn(c):
    k = 1.15 if c.small else 1.0
    def rr(x0, y0, x1, y1, r):
        return lambda x, y: (x0 <= x < x1 and y0 + r <= y < y1 - r) or (x0 + r <= x < x1 - r and y0 <= y < y1) or any(
            (x - cx) ** 2 + (y - cy) ** 2 < r * r for cx, cy in ((x0 + r, y0 + r), (x1 - r, y0 + r), (x0 + r, y1 - r), (x1 - r, y1 - r)))
    core = rr(13, 15, 51, 51, 4)
    tN = knob('T', 'peg', 32, 15, 0, -1, r=5.6 * k, nw=3.2)
    tS = knob('T', 'peg', 32, 51, 0, 1, r=3.4 * k, nw=2.2)
    tW = knob('T', 'peg', 13, 30, -1, 0, r=4.6 * k, nw=3.0)
    tE = knob('T', 'peg', 51, 30, 1, 0, r=4.6 * k, nw=3.0)
    body = c.m(core)
    # limbs (skin) first, shell on top
    c.add(c.m(tN, tS, tW, tE, minus=(core,)), SKIN)
    c.add(body, RIM)
    inner = c.m(rr(17, 19, 47, 47, 3))
    c.add(inner, SHELL)
    # scutes: central hexagon and four side plates
    hexa = c.m(poly([(32, 23), (39, 27), (39, 37), (32, 41), (25, 37), (25, 27)]))
    c.add(hexa, SCUTE)
    c.edge(hexa, RIM[1])
    if not c.small:
        for a, b in (((32, 23), (32, 19)), ((39, 27), (46, 22)), ((25, 27), (18, 22)), ((39, 37), (46, 43)), ((25, 37), (18, 43)), ((32, 41), (32, 46))):
            c.line([a, b], RIM[1])
        # ring motif in the hexagon
        c.add(c.m(ell(32, 32, 3.6, 3.6), minus=(ell(32, 32, 2.0, 2.0),)), SHELL)
    else:
        for a, b in (((39, 27), (46, 22)), ((25, 27), (18, 22)), ((39, 37), (46, 43)), ((25, 37), (18, 43))):
            c.line([a, b], RIM[1])
    # rim notches
    for gx in (21, 27, 37, 43):
        x, _ = c.P(gx, 0)
        c.px(x, c.P(0, 16)[1] if c.small else c.P(0, 16)[1] + 1, RIM[1])
        c.px(x, c.P(0, 49)[1], RIM[1])
    # flipper tips darker spots
    for fx in (6.5, 57.5):
        c.px(*c.P(fx, 28), SKIN[1])
        if not c.small:
            c.px(*c.P(fx, 33), SKIN[1])
    # face on the head tab
    if c.small:
        c.eye(28.6, 7, disc=False)
        c.eye(34.4, 7, disc=False)
    else:
        c.eye(29, 7.5)
        c.eye(35.5, 7.5)
        c.smile(32.2, 10.5)
    c.blush(26.5, 10.5)
    c.blush(37, 10.5)


K.render_pal(fn, 'pl-turt-4', 'Hatchling Line', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-turt-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-turt-4.png')
