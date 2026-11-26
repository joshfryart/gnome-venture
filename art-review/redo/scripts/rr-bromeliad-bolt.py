"""rr-bromeliad-bolt: Bromeliad Bolt, inner-TTTT, tri knobs.
A spiky bromeliad rosette that IS a square piece: four tri tabs are its four leaf tips (W, E green leaf points, N the red flower bract
bolt, S a bark-brown root foot), the body is fanned leaves around a cup of rain in its crown. Leaf greens + bark umber from cell 1-1,
heliconia red and river blue from the Rainroot picture."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

LEAF = K.ramp('#5fa84f')
DEEP = K.ramp('#307a45')
BARK = K.ramp('#7a6a51')
RED = K.ramp('#d8402e')
PINK = K.ramp('#e86a9a')
RAIN = K.ramp('#5aa8d8')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = rect(13, 17, 51, 51)
    tN = knob('T', 'tri', 32, 17, 0, -1, r=5.0 * s)
    tW = knob('T', 'tri', 13, 35, -1, 0, r=4.6 * s)
    tE = knob('T', 'tri', 51, 35, 1, 0, r=4.6 * s)
    tS = knob('T', 'tri', 32, 51, 0, 1, r=4.0 * s)
    tips = poly([(13, 17), (13, 10.5), (19, 17), (22, 11), (26, 17.5), (38, 17.5), (42, 11), (45, 17), (51, 10.5), (51, 17)])
    body = c.m(core, tN, tW, tE, tS, tips)
    c.add(body, DEEP)
    # strap leaves radiating from the base, alternating light and deep green, tips up into the top edge
    base = (32, 60)
    ends = [(4, 38), (8, 12), (19, 8), (26, 8), (38, 8), (45, 8), (56, 12), (60, 38)]
    for i in range(len(ends) - 1):
        if i % 2 == 0:
            m = c.m(poly([base, ends[i], ends[i + 1]])) & body
            c.add(m, LEAF)
            c.edge(m - c.m(ell(32, 21.5, 12, 5.4)), DEEP[1])
    # broad front leaf carrying the face
    fr = c.m(poly([(32, 54), (19, 44), (20, 30), (32, 25), (44, 30), (45, 44)])) & body
    c.add(fr, K.ramp('#6fb85a'))
    c.edge(fr - c.m(ell(32, 21.5, 12, 5.4)), DEEP[1])
    # red-tipped leaves at the top points
    for tx in (13, 22, 42, 51):
        c.add(c.m(ell(tx + (0.6 if tx < 32 else -0.6), 12.2, 1.9, 2.4)) & body, RED)
    # S tab: a bark root foot
    c.add(c.m(tS, minus=(rect(0, 0, 64, 50),)), BARK)
    # crown: pink bracts holding a cup of rain, red bolt spike (N tab) rising from it
    c.add(c.m(tN, minus=(rect(0, 17.5, 64, 64),)) | c.m(poly([(28, 22), (32, 15), (36, 22)])), RED)
    cup = c.m(ell(32, 21.5, 11, 4.4))
    c.add(cup, PINK)
    water = c.m(ell(32, 21, 8, 2.4))
    c.add(water, RAIN)
    if not c.small:
        c.px(*c.P(29, 21.5), '#cfe8f4')
        c.px(*c.P(30, 21.5), '#cfe8f4')
    # face on the front leaf fan
    c.eye(27, 37, disc=True)
    c.eye(37, 37, disc=True)
    c.smile(32, 43)
    c.blush(23.5, 41)
    c.blush(40, 41)


K.render_pal(fn, 'rr-bromeliad-bolt', 'Bromeliad Bolt', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/rr-bromeliad-bolt-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/rr-bromeliad-bolt.png')
