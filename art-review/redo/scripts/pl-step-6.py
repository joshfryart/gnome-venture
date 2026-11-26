import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#d8302a')
YEL = K.ramp('#f0c030')
BLUE = K.ramp('#2f78c8')
SKY = K.ramp('#a6dcea')
MINT = K.ramp('#cce8dc')
IVORY = K.ramp('#efe6cc')
BILL = K.ramp('#5a4a3e')
FACE = K.ramp('#f4f0e4')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.poly([(18, 12), (46, 12), (50, 16), (50, 48), (46, 52), (18, 52), (14, 48), (14, 16)])
    crest = K.knob('T', 'keyhole', 30, 12, 0, -1, r=4.5 * s)
    wing = K.knob('T', 'keyhole', 50, 34, 1, 0, r=4.5 * s)
    tail = K.knob('T', 'keyhole', 32, 52, 0, 1, r=4.5 * s)
    blank = K.knob('B', 'keyhole', 14, 40, -1, 0, r=4.2 * s)
    beak = K.poly([(16, 16), (8, 18), (5, 23), (6, 29), (9, 27), (12, 30), (17, 30)])
    body = c.m(core, crest, minus=(blank,))
    c.add(body, RED, stitch='#f08a4a')
    c.add(c.m(wing), BLUE)
    c.add(c.m(tail), BLUE)
    # wing on the body: yellow covert band then blue flight feathers
    c.add(c.m(K.ell(42, 36, 9, 12), minus=(K.ell(30, 36, 6, 30),)), YEL)
    w2 = c.m(K.ell(43, 41, 8, 9), minus=(K.ell(30, 36, 6, 30),))
    c.add(w2, BLUE)
    c.edge(w2, BLUE[1])
    # tail: mint/sky perch base hint from the cell
    c.add(c.m(K.rect(14, 48, 30, 53), K.rect(36, 48, 50, 53), minus=(blank,)), MINT)
    # beak
    c.add(c.m(beak), IVORY)
    lower = c.m(K.poly([(9, 27), (12, 30), (17, 30), (17, 25), (12, 25)]))
    c.add(lower, BILL)
    # white face patch
    c.add(c.m(K.ell(23, 22, 6, 5.5)), FACE)
    c.eye(24, 22)
    c.blush(29, 28)
    # sky-blue feather tips on the tail
    c.add(c.m(K.rect(29.5, 57, 34.5, 60)), SKY)
    c.add(c.m(K.rect(51, 32, 58, 36)), SKY)


rep = K.render_pal(fn, 'pl-step-6', 'Scarlet Riddlecaller', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-step-6-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-step-6.png')
print(rep)
