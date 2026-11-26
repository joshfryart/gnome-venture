"""pl-wdol-6 Nudging Boto (whimsy-boto, keyhole): a chubby pink river dolphin side-on, facing right; its body is the square piece core.
N keyhole tab = teal splash from the blowhole, W + S keyhole blanks bite into the body, tail flukes break out at the lower-left corner,
the long boto snout pokes out E. Pink boto + teal pool water with pale ripple (cell 5-6)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = K.ramp('#e48aa8')
PINKD = K.ramp('#c86a92')
BELLY = K.ramp('#f6c4d2')
TEAL = K.ramp('#46a890')
RIP = '#a4ecc8'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: K.rect(11, 17, 49, 54)(x, y) and not (
        (x < 16 and y < 22 and (x - 16) ** 2 + (y - 22) ** 2 > 25) or
        (x > 41 and y < 25 and (x - 41) ** 2 + (y - 25) ** 2 > 64) or
        (x > 44 and y > 48 and (x - 44) ** 2 + (y - 48) ** 2 > 25))
    melon = K.ell(42, 27, 9, 9)
    snout = K.thick_path([(48, 34), (55, 36.5), (60, 38)], 5.2 if not c.small else 5.8)
    tail = K.thick_path([(14, 47), (8, 52)], 6)
    fl1 = K.ell(5, 49, 4.2, 2.6)
    fl2 = K.ell(9, 56, 2.6, 4.2)
    tabN = K.knob('T', 'keyhole', 27, 17, 0, -1, r=4.4 * k)
    blW = K.knob('B', 'keyhole', 11, 31, -1, 0, r=3.6 * k)
    blE = K.knob('B', 'keyhole', 49, 45.5, 1, 0, r=3.6 * k)
    blanks = (blW, blE)
    body = c.m(core, melon, snout, tail, fl1, fl2, minus=blanks)
    c.add(body, PINK, stitch=None if c.small else PINKD[1])
    # belly: lighter pink under-band
    c.add(body & c.m(K.ell(30, 49, 20, 6.5), K.ell(54, 39.5, 6, 1.6)), BELLY)
    # water: teal pool band at the bottom with a pale ripple
    water = body & c.m(K.rect(16, 48.5, 64, 64))
    c.add(water, TEAL)
    # splash tab (teal) with ripple
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 15, 64, 18.5))), TEAL)
    # flipper
    c.add(c.m(K.poly([(30, 36), (37, 37), (33, 45), (28, 43)])), PINKD)
    if not c.small:
        y = c.P(0, 51)[1]
        for x in range(c.P(17, 0)[0], c.P(62, 0)[0]):
            if (x // 3) % 2 == 0:
                c.px(x, y, RIP)
        cx, cy = c.P(27, 8)
        c.px(cx, cy, RIP); c.px(cx - 1, cy + 1, RIP)
    else:
        y = c.P(0, 51)[1]
        for x in range(c.P(17, 0)[0], c.P(62, 0)[0]):
            if x % 3 != 2:
                c.px(x, y, RIP)
        cx, cy = c.P(27, 8)
        c.px(cx, cy, RIP)
    c.eye(42, 28)
    c.blush(46, 33)
    c.smile(52, 39, K.UMBER2) if not c.small else None


K.render_pal(fn, 'pl-wdol-6', 'Nudging Boto', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wdol-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wdol-6.png')
