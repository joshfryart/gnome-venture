"""pl-thch-6 Teatime Hedgehog (rare, whimsy-hedgehog, peg).
Concept: a round hedgehog seen side-on, facing right, that IS a square piece. Peg tabs: N = a white teacup with a pink band balanced on its
back, E = its long snout with the nose at the tip. Peg blanks: W bites into the spiny rump, S cuts between the two feet. Spines in thatch
brown with gold tips (the tearoom roof), green leaves stuck in the spines and a stone-cream face (cell 4-7: lawn greens + stepping stones)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SPINE = K.ramp('#9a6a34')
GOLDT = K.ramp('#e8b84a')
FACE = K.ramp('#e8dcc8')
LEAF = K.ramp('#7cb450')
CUP = K.ramp('#fff6ea')
PINK = K.ramp('#e0708e')
FEET = K.ramp('#b88a62')


def fn(c):
    S = 1.15 if c.small else 1.0
    # body: square core, top edge a row of spine teeth
    teeth = []
    x = 11.0
    pts = [(11, 52), (11, 23)]
    while x < 40:
        pts += [(x + 1.5, 14.5), (x + 7, 23)]
        x += 7
    pts += [(43, 16.5), (47, 24), (52, 23), (49, 30), (49, 52)]
    core = K.poly(pts)
    tabN = K.knob('T', 'peg', 29, 23, 0, -1, r=5.2 * S, nw=3.2)
    tabE = K.knob('T', 'peg', 49, 40, 1, 0, r=4.2 * S, nw=2.8)
    blankW = K.knob('B', 'peg', 11, 36, -1, 0, r=4.2 * S)
    blankS = K.knob('B', 'peg', 30, 52, 0, 1, r=4.0 * S)
    body = c.m(core, minus=(blankW, blankS))
    c.add(body, SPINE)
    # gold spine tips along the top teeth
    c.add(body & c.m(K.rect(0, 0, 64, 18.5)), GOLDT)
    # spine strokes: short dark slashes pointing back and up
    step = 5
    for gy in range(26, 47, 4):
        for gx in range(14 + (gy // 4 % 2) * 2, 40, step):
            if c.small and (gx + gy) % 3:
                continue
            if (int(gx * c.k), int(gy * c.k)) in body:
                c.line([(gx, gy), (gx - 2.5, gy - 1.8)] if not c.small else [(gx, gy), (gx - 1.8, gy - 1.8)], SPINE[1])
                if not c.small and (gx + gy) % 2 == 0:
                    c.px(int((gx - 3.5) * c.k), int((gy - 2.5) * c.k), GOLDT[0])
    # face: cream patch on the right, belly strip
    face = c.m(K.ell(46, 41, 10, 9.5), K.rect(40, 40, 49, 49)) & body
    c.add(face, FACE)
    c.edge(face, '#c9b89a')
    c.add(c.m(tabE, minus=(core,)), FACE)
    # feet (S blank between them)
    feet = body & c.m(K.rect(0, 47.5, 64, 64))
    c.add(feet, FEET)
    # teacup on the back
    cup = c.m(tabN) & c.m(K.rect(0, 0, 64, 21.5))
    c.add(cup, CUP)
    c.add(cup & c.m(K.rect(0, 14, 64, 16.5)), PINK)
    # cup handle + steam
    c.add(c.m(K.thick_path([(34, 12.5), (36, 13.5), (35.5, 16.5)], 1.6 if not c.small else 2.4)), CUP)
    # green leaves in the spines
    for (lx, ly) in ((19, 30), (27, 40)):
        c.add(c.m(K.ell(lx, ly, 3.4, 2.0)), LEAF)
    # nose on the snout tip
    nx, ny = c.P(57.5 if not c.small else 57, 39.5)
    c.px(nx, ny, K.UMBER)
    c.px(nx, ny + 1, K.UMBER)
    if not c.small:
        c.px(nx - 1, ny, K.UMBER)
        c.px(nx - 1, ny + 1, K.UMBER)
    c.eye(46.5, 40.5)
    c.blush(43.5, 45)
    c.smile(50, 45.5, K.UMBER2)


UMBERB = K.UMBER2
K.render_pal(fn, 'pl-thch-6', 'Teatime Hedgehog', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-thch-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-thch-6.png')
