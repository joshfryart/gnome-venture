import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

# Songline Kangaroo (whimsy-kangaroo, tri): an upright kangaroo seen side-on whose torso is a square piece.
# Tri tab N = the tall ear, tri tab E = the paw pointing along the song, tri blank W cut into the back,
# flat bottom with a long foot and a striped tail. Rock orange + cream/yellow dot-painting rings (cell 1-6).
ROCK = ramp('#e8905a')
SAND = ramp('#f2ac6d')
RED = ramp('#b05a50')
DOT, DOTY = '#fff0c0', '#f8b848'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 24, 45, 55)
    head = ell(43, 21, 9.5, 7.5)
    snout = poly([(44, 15), (58, 19.5), (58, 23), (44, 27)])
    ear = knob('T', 'tri', 38, 15, 0, -1, r=4.6 * k)
    paw = knob('T', 'tri', 45, 37, 1, 0, r=4.2 * k)
    blank = knob('B', 'tri', 13, 37, -1, 0, r=5.2 * k)
    foot = poly([(30, 50), (58, 53), (59, 58), (30, 58)])
    tail = poly([(14, 43), (17, 52), (8, 58), (2, 61), (1.5, 59), (6, 53)])
    ear2 = poly([(31, 20), (31.5, 9), (36, 17)])
    body = c.m(core, head, snout, ear, ear2, minus=(blank,))
    c.add(body, ROCK, stitch=None)
    c.add(c.m(paw, minus=(core,)), ROCK)
    c.add(c.m(tail, minus=(core,)), RED)
    c.add(c.m(foot, minus=(rect(0, 0, 64, 50),)) | c.m(foot, minus=(core,)), RED)
    # pale belly on the front of the torso
    belly = c.m(ell(40, 42, 6.5, 11), minus=(blank,)) & body
    c.add(belly, SAND)
    # inner ear
    c.add(c.m(poly([(36.5, 15), (38, 7.5), (39.5, 15)])), RED)
    # dark nose tip
    nx, ny = c.P(57, 20.5)
    c.px(nx, ny, K.UMBER2)
    c.px(nx, ny + 1, K.UMBER2)
    # tail stripes
    for (sx, sy) in ((10, 53), (5.5, 57.5)):
        c.line([(sx - 1.5, sy - 2.5), (sx + 2, sy + 1)], '#f2ac6d')
    # concentric dot-painting rings on the haunch (the songline motif)
    cx, cy = 25, 43
    if not c.small:
        c.px(*c.P(cx, cy), DOTY)
        c.px(c.P(cx, cy)[0] + 1, c.P(cx, cy)[1], DOTY)
        import math
        for r, n, col in ((4.2, 8, DOT), (8.0, 14, DOTY)):
            for i in range(n):
                a = 2 * math.pi * i / n
                q = c.P(cx + r * math.cos(a), cy + r * math.sin(a))
                c.px(*q, col)
                if r > 5:
                    c.px(q[0] + 1, q[1], col)
        # dot trail along the back (the songline)
        for (x, y) in ((17, 28), (22, 27), (27, 27), (32, 28)):
            q = c.P(x, y)
            c.px(*q, DOT)
            c.px(q[0] + 1, q[1], DOT)
    else:
        import math
        p = c.P(cx, cy)
        c.px(p[0], p[1], DOTY)
        for i in range(8):
            a = 2 * math.pi * i / 8
            c.px(*c.P(cx + 5.5 * math.cos(a), cy + 5.5 * math.sin(a)), DOT)
    c.eye(46, 19.5)


K.render_pal(fn, 'pl-rrs-6', 'Songline Kangaroo', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-rrs-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-rrs-6.png')
print(K.check(K.draw(fn, 64))['colours'])
