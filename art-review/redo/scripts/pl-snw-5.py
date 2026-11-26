import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Lion Paw Pair, inner-TTBB hook: two tan lion paws side by side, palms out, toe scallops on top; hook tabs N (raised claw of the waving
# left paw) and E (thumb claw of the right paw); hook blanks W and S cut into the mane-brown wrist cuff. Pads in the cell's rock umber-grey.
from pal_kit import rect, ell, knob, thick_path

FUR = K.ramp('#d89a48')     # lion tan
GOLD = K.ramp('#e8bc6a')    # cell gold
MANE = K.ramp('#8a4a22')    # lion mane brown
PAD = K.ramp('#5a4840')     # cell rock
ROCK = K.ramp('#a89c88')    # cell grey
CLAW = K.ramp('#f2e4c0')

def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(12, 23, 52, 57)
    toes = [ell(x, 21.5, 3.9, 4.2) for x in (17, 24.5, 39.5, 47)]
    tabN = knob('T', 'hook', 32, 22, 0, -1, r=5.2 * k)
    tabE = knob('T', 'hook', 52, 34, 1, 0, r=4.8 * k)
    blW = knob('B', 'hook', 12, 50, -1, 0, r=3.4 * k, flip=True)
    blS = knob('B', 'hook', 46, 57, 0, 1, r=3.4 * k)
    body = c.m(core, *toes, minus=(blW, blS))
    c.add(body, FUR)
    c.add(c.m(tabN, minus=(core,)), MANE)
    c.add(c.m(tabE, minus=(core,)), MANE)
    cuff = body & c.m(rect(0, 42.5, 64, 64))
    c.add(cuff, MANE)
    if not c.small:
        y = c.P(0, 42.5)[1]
        for x in range(c.P(12, 0)[0], c.P(52, 0)[0]):
            if x % 3 == 0 and (x, y + 1) in body:
                c.px(x, y + 1, MANE[2])
    # split between the two paws
    for p in c.m(rect(31.3, 26, 32.8, 42.5)) & body:
        c.px(p[0], p[1], FUR[1])
    # toe beans + main heart pads
    for x in (17, 24.5, 39.5, 47):
        c.add(c.m(ell(x, 22.5, 2.3 * k, 2.5 * k)) & body, PAD)
    for x in (21, 43):
        c.add(c.m(ell(x, 33.5, 5.6, 3.8), ell(x - 2.6, 36.2, 3.0, 2.8), ell(x + 2.6, 36.2, 3.0, 2.8)) & body, PAD)
    # face on the wrist cuff
    c.eye(26, 49, disc=True)
    c.eye(35, 49, disc=True)
    c.smile(30.5, 52, CLAW[0])
    c.blush(39, 52.5)

K.render_pal(fn, 'pl-snw-5', 'Lion Paw Pair', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-snw-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-snw-5.png')
