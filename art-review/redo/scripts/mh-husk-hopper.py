import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp

# Grasshopper corner piece: head = round tab (E), round blank in the rump (W), flat N and S sides.
# Body = green corn husk opened on a yellow cob belly; flat base = furrowed brown soil (cell 2-6).
HUSK = ramp('#58a83c')      # cell stalk green
LEAF = ramp('#2f7430')      # deeper stalk green
COB = ramp('#f0c040')       # cell cob yellow
KER = '#f8dc78'
SOIL = ramp('#b0683c')      # cell furrow brown
FUR = '#7a4428'
LEG = ramp('#9ccc4c')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(5, 15, 47, 57)
    head = knob('T', 'round', 47, 31, 1, 0, r=6.6 * k, nw=4.2)
    rump = knob('B', 'round', 5, 34, -1, 0, r=4.5 * k)
    knee = ell(15, 11, 4.4, 4.4)
    ant1 = thick_path([(52, 24), (50, 12), (44, 4)], 2.8)
    ant2 = thick_path([(56, 24), (58, 12), (61, 5)], 2.8)
    body = c.m(core, head, knee, ant1, ant2, minus=(rump,))
    c.add(body, HUSK, stitch=None)
    # head + antennae a touch lighter
    H = c.add(body & c.m(head, ant1, ant2, minus=(core,)), HUSK)
    # soil base strip with furrows
    S = c.add(body & c.m(rect(0, 49, 64, 64)), SOIL)
    c.edge(S, SOIL[1])
    if not c.small:
        c.line([(9, 52.5), (43, 52.5)], FUR)
    else:
        c.line([(9, 53), (43, 53)], FUR)
    # cob belly peeking from the husk
    belly = c.m(poly([(20, 49), (26, 34), (36, 26), (46, 28), (46, 49)]))
    B = c.add(body & belly - S, COB)
    c.edge(B, COB[1])
    step = 2 if c.small else 3
    for (x, y) in B:
        if (x + (y // step) % 2) % step == 0 and y % step == 0:
            c.px(x, y, KER)
    # husk leaf flap over the back (wing)
    wing = c.m(poly([(6, 20), (44, 20), (34, 30), (6, 44)]))
    W = c.add(body & wing, LEAF)
    c.edge(W, LEAF[1])
    if not c.small:
        c.line([(10, 25), (34, 20)], LEAF[2])
    # folded hind leg: big thigh from mid body up/back to a knee above the rump, shin back down to the soil
    tw = 7.5 if not c.small else 8.0
    thigh = c.m(thick_path([(31, 41), (15, 11)], tw), ell(15, 11, 4.0, 4.0))
    shin = c.m(thick_path([(15, 11), (26, 50)], 3.4 if not c.small else 3.8))
    Lt = c.add(body & thigh, LEG)
    Ls = c.add(body & shin - Lt, LEG)
    c.edge(Lt, LEG[1])
    c.edge(Ls, LEG[1])
    if not c.small:
        c.line([(29, 38), (17, 14)], LEG[2])
        for i in range(5):
            y = 22 + i * 4
            c.line([(21 + i * 1.8, y), (24 + i * 1.8, y - 2)], '#5a8a2a')
    # face: big eye on the head tab, no mouth (says nothing at all)
    c.eye(55.5, 30, disc=False)
    c.blush(57, 35)


K.render_pal(fn, 'mh-husk-hopper', 'Husk Hopper', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mh-husk-hopper-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mh-husk-hopper.png')
