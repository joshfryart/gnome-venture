# pl-wfla-4 "Long-Neck Lineup": a flamingo that IS an inner-TTTT piece (double knobs).
# N tab = the flamingo's head (left lobe head with eye, right lobe the cream beak with its dark bent tip),
# S tab = two pink feet standing in the shallows, W tab = dark tail tuft, E tab = puffed chest.
# Body pink with a folded wing; bottom band is the lavender shallow water with the cream ripple ring from cell 9-6.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path, poly

PINK = K.ramp('#e8a0b8')
HOT = K.ramp('#d8789a')
WING = K.ramp('#f6c0cc')
WATER = K.ramp('#b878b0')
BEAK = K.ramp('#f4e8d8')
TIP = ('#6a4a68', '#3a2430', '#8a6a88')
RIPPLE = '#fbeee0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 21, 51, 51)
    # N tab: the long neck + head + bent beak (a stretched double knob: head lobe and beak lobe)
    nw = 5.2 if not c.small else 6.0
    neck = thick_path([(27, 23), (25, 17), (26.5, 12), (29, 9)], nw)
    head = ell(30.5, 7.5, 5.6 * k, 4.6 * k)
    beakS = thick_path([(34, 6.5), (39.5, 7.5), (41.5, 11.5), (41, 14.5)], 4.4 if not c.small else 5.0)
    tN = lambda x, y: neck(x, y) or head(x, y) or beakS(x, y)
    tS = knob('T', 'double', 32, 51, 0, 1, r=5.0 * k)
    tW = knob('T', 'double', 13, 34, -1, 0, r=5.0 * k)
    tE = knob('T', 'double', 51, 34, 1, 0, r=5.0 * k)
    body = c.m(core, tN, tS, tW, tE)
    c.add(body, PINK)
    # tail tuft (W tab) in the darker flamingo pink
    c.add(c.m(tW, minus=(core,)) | (c.m(tW) & c.m(rect(11, 0, 14.5, 64))), HOT)
    # folded wing on the body
    wing = c.m(poly([(20, 27), (36, 25), (43, 31), (40, 38), (26, 39), (16, 34)]))
    c.add(wing & body, WING, stitch=None if c.small else '#e8a0b8')
    c.edge(wing & body, HOT[0])
    # dark wing-tip feathers trailing to the tail
    c.add(c.m(poly([(14, 33), (22, 31), (25, 36), (16, 38)])) & body, HOT)
    # head: the N tab; right lobe becomes the bent beak
    c.add(c.m(beakS, minus=(head,)), BEAK)
    c.add(c.m(beakS) & c.m(rect(36, 9.5, 64, 21)), TIP)
    # water band at the bottom of the core and the feet in it
    water = c.m(rect(0, 43, 64, 51)) & body
    c.add(water, WATER)
    feet = c.m(tS, minus=(core,))
    c.add(feet, HOT)
    legw = 2.4 if not c.small else 2.8
    c.add(c.m(thick_path([(28.5, 37), (28.5, 52)], legw), thick_path([(35.5, 37), (35.5, 52)], legw)), HOT)
    # cream ripple ring around the legs (the cell's motif)
    if not c.small:
        c.line([(19, 46.5), (26, 45.5), (38, 45.5), (45, 46.5)], RIPPLE)
        c.line([(17, 49.5), (46, 49.5)], RIPPLE)
    else:
        c.line([(18, 47), (46, 47)], RIPPLE)
    # face on the head lobe
    c.eye(30, 7 if not c.small else 6)
    c.blush(26.5, 10)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wfla-4', 'Long-Neck Lineup', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wfla-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wfla-4.png'))
