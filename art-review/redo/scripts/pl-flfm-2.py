import sys, math
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

R = '/home/user/gnome-venture/'
WATER = K.ramp('#2f8fbf')
PAD = K.ramp('#5aa83a')
PETAL = K.ramp('#f08a1c')
PETAL2 = K.ramp('#f8b030')
HEART = K.ramp('#c8561a')
FOAM = '#bfe6f0'


def fn(c):
    s = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 11, 12, 53, 57
    core = K.rect(x0, y0, x1, y1)
    top = K.knob('T', 'peg', 30, y0, 0, -1, r=4.5 * s)
    left = K.knob('T', 'peg', x0, 32, -1, 0, r=4.5 * s)
    right = K.knob('B', 'peg', x1, 30, 1, 0, r=4.5 * s)
    body = c.m(core, top, left, minus=(right,))
    # water band at the bottom (flat side = waterline)
    c.add(body, WATER)
    # lily pad: wide ellipse resting on the water, notch cut in
    pad = c.m(K.ell(32, 45, 26, 8.5), left, minus=(right, K.poly([(32, 44), (50, 40), (50, 47)])))
    c.add(pad & body, PAD)
    # marigold: ruffled petal disc (scalloped ring) filling the top
    cx, cy = 31, 27
    petals = [K.ell(cx + 12.5 * math.cos(a), cy + 11.5 * math.sin(a), 5.8, 5.8) for a in [i * math.pi / 5 for i in range(10)]]
    outer = c.m(K.ell(cx, cy, 13.5, 12.5), *petals, top, minus=(right,)) & body
    c.add(outer, PETAL, stitch=PETAL[2] if False else None)
    inner = [K.ell(cx + 9 * math.cos(a), cy + 8.5 * math.sin(a), 4.2, 4.2) for a in [i * math.pi / 4 + .4 for i in range(8)]]
    mid = c.m(K.ell(cx, cy, 10, 9.5), *inner) & body
    c.add(mid, PETAL2)
    c.edge(mid, PETAL[1])
    heart = c.m(K.ell(cx, cy + 1, 7.5, 6.5))
    c.add(heart, K.ramp('#e07020'))
    c.edge(heart, HEART[0])
    c.edge(outer, PETAL[1])
    # bud on top tab: green sepal base
    sep = c.m(K.rect(24, 9, 36, 13 if not c.small else 14)) & body
    c.add(sep, PAD)
    # water ripples
    for y in (53, 55.5):
        c.line([(14, y), (19, y)], FOAM)
        c.line([(40, y), (46, y)], FOAM)
    # face on the petals
    c.eye(28, 27.5, disc=not c.small)
    c.eye(35, 27.5, disc=not c.small)
    c.smile(31.5, 31.5)
    c.blush(25, 31)
    c.blush(38, 31)


K.render_pal(fn, 'pl-flfm-2', 'Bobbing Blooms', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-flfm-2-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/pl-flfm-2.png')
