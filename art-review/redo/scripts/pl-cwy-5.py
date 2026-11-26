import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
import math
R = '/home/user/gnome-venture/'
ASH = K.ramp('#b4a2a6')      # cell stone, pinkish ash grey
ASHL = K.ramp('#dccfcc')     # pale ash leaves
ASHD = K.ramp('#7e6874')     # mauve-grey leaves
LAVA = K.ramp('#d8482a')     # cell lava red
EMB = '#f07a24'              # cell lava orange
EMBL = '#f8b048'

def rell(cx, cy, rx, ry, a):
    ca, sa = math.cos(a), math.sin(a)
    def f(x, y):
        dx, dy = x - cx, y - cy
        u, v = dx * ca + dy * sa, -dx * sa + dy * ca
        return (u / rx) ** 2 + (v / ry) ** 2 < 1
    return f

def fn(c):
    k = 1.15 if c.small else 1.0
    r = 3.6 * k
    # rounded-square wreath core (round enough to be a wreath, straight sides to stay a piece)
    core = [K.rect(19, 9, 45, 55), K.rect(9, 19, 55, 45),
            K.ell(19, 19, 10, 10), K.ell(45, 19, 10, 10), K.ell(19, 45, 10, 10), K.ell(45, 45, 10, 10)]
    # little leaf scallops on the four rounded corners
    bumps = []
    for (cx, cy) in ((19, 19), (45, 19), (19, 45), (45, 45)):
        base = math.atan2(cy - 32, cx - 32)
        for d in (-0.45, 0.45):
            a = base + d
            bumps.append(K.ell(cx + math.cos(a) * 10.2, cy + math.sin(a) * 10.2, 2.8, 2.8))
    blanks = [K.knob('B', 'hook', 32, 9, 0, -1, r=r),
              K.knob('B', 'hook', 55, 32, 1, 0, r=r),
              K.knob('B', 'hook', 42, 55, 0, 1, r=r, flip=True),
              K.knob('B', 'hook', 9, 32, -1, 0, r=r, flip=True)]
    hole = K.ell(32, 33, 6.5, 6.5)
    body = c.m(*(core + bumps), minus=blanks + [hole])
    c.add(body, ASH)
    # leaves around the ring, alternating pale / mauve, each with a dark vein edge
    for i in range(14):
        a = i * math.tau / 14 + 0.2
        cx, cy = 32 + math.cos(a) * 16, 33 + math.sin(a) * 16
        rp = ASHL if i % 2 == 0 else ASHD
        lm = c.m(rell(cx, cy, 4.6, 2.2, a + math.pi / 2 + 0.6)) & body
        c.add(lm, rp)
        c.edge(lm, rp[1])
    # glow round the hollow: it still hopes for a fire
    glow = c.m(K.ell(32, 33, 9, 9)) & body
    c.add(glow, (EMB, '#c05a1a', EMBL))
    c.edge(glow, LAVA[0])
    # lava-red bow at the bottom
    bow = c.m(K.poly([(24, 47), (14, 42), (14, 53), (24, 49)]), K.poly([(24, 47), (33, 43), (33, 52), (24, 49)]),
              K.poly([(22, 49), (18, 58), (21, 58), (24, 50)]), K.poly([(25, 49), (28, 58), (31, 57), (26, 49)])) & body
    c.add(bow, LAVA)
    c.edge(bow, LAVA[1])
    knot = c.m(K.ell(24, 48, 2.6, 2.6)) & body
    c.add(knot, LAVA)
    c.edge(knot, LAVA[1])
    # ember specks
    for (x, y) in [(14, 24), (50, 24), (49, 41), (24, 13)]:
        px, py = c.P(x, y)
        c.px(px, py, EMB)
        if not c.small:
            c.px(px + 1, py, EMBL)
    # face on the upper ring
    c.eye(21.5, 22, disc=True)
    c.eye(42.5, 22, disc=True)
    c.blush(17, 27)
    c.blush(46, 27)

K.render_pal(fn, 'pl-cwy-5', 'Ash Wreath', '/home/user/gnome-venture/art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-cwy-5-cell.png', oldfile=R + 'game/assets/img/puzzles/pals/pl-cwy-5.png')
