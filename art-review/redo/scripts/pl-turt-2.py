# Flipper Dash (pl-turt-2): a top-down sea-turtle hatchling that IS an edge piece.
# Shell = square core; flat side = bottom (tail end, the edge of the beach); peg tab top = head; peg tab left = front flipper
# mid-flap; peg blank right = the other flipper tucked in. Colours and the dark teal scute seam from cell 3-5 (the big green shell).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SHELL = K.ramp('#79b65c')
PLATE = K.ramp('#a8d870')
RIM = K.ramp('#4e924d')
SKIN = K.ramp('#9fd068')
SEAM = '#1a3a40'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.poly([(19, 22), (49, 22), (55, 28), (55, 58), (13, 58), (13, 28)])
    head = K.knob('T', 'peg', 34, 22, 0, -1, r=6.4 * s, nw=3.2)
    headtop = K.ell(34, 13.5 - (0.8 if c.small else 0), 6.4 * s, 4.6)
    flip = K.knob('T', 'peg', 13, 34, -1, 0, r=5.0 * s, nw=3.4)
    paddle = K.ell(6.5, 38, 4.2, 5.2)   # the flipper sweeps back: a paddle tip
    blank = K.knob('B', 'peg', 55, 43, 1, 0, r=5.0 * s, nw=2.6)
    c.add(c.m(head, headtop), SKIN)
    c.add(c.m(flip, paddle), SKIN)
    shell = c.add(c.m(core, minus=(blank,)), RIM)
    big = K.knob('B', 'peg', 55, 43, 1, 0, r=5.0 * s + 2.6, nw=4.8)
    inner = c.add(c.m(K.poly([(21, 25.5), (47, 25.5), (51.5, 30), (51.5, 55), (16.5, 55), (16.5, 30)]), minus=(big,)), SHELL)
    # scutes like the big shell in the picture: two central hexes, seams radiating to the rim, dark teal like the cell's seam
    sc = SEAM if not c.small else '#2f5a48'
    hexes = [K.poly([(27.5, 27.5), (40.5, 27.5), (44, 33.5), (40.5, 39.5), (27.5, 39.5), (24, 33.5)]),
             K.poly([(27.5, 42), (40.5, 42), (44, 47.5), (40.5, 53), (27.5, 53), (24, 47.5)])]
    for h in hexes:
        m = c.add(c.m(h) & inner, PLATE)
        c.edge(m, sc)
    w = 1.7 if not c.small else 2.0
    seams = [[(24, 33.5), (17, 33.5)], [(26, 40.7), (17, 40.7)], [(24, 47.5), (17, 47.5)], [(27.5, 27.5), (23, 25.5)],
             [(40.5, 27.5), (45, 25.5)], [(44, 33.5), (51, 33.5)], [(42, 40.7), (46, 40.7)], [(44, 47.5), (47, 50)]]
    for sg in seams:
        for q in c.m(K.thick_path(sg, w)) & inner:
            c.px(q[0], q[1], sc)
    # dome sheen
    if not c.small:
        c.line([(30, 30), (33, 30)], PLATE[2])
    # rim notches (marginal scutes)
    for x in (22, 30, 38):
        c.line([(x, 55.5), (x, 57)], RIM[1])
    # flipper crease
    c.line([(4.5, 35), (10, 34.5)], SKIN[1])
    # face
    c.eye(30.5, 14.5)
    c.eye(37.5, 14.5)
    if not c.small:
        c.smile(34, 18.5)
        c.blush(27.5, 18)
        c.blush(40, 18)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-turt-2', 'Flipper Dash', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-turt-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-turt-2.png')
    print(rep)
