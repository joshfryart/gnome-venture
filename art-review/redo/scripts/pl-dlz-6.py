"""pl-dlz-6 Mossback Monitor (rare, whimsy-lizard, double knobs).
Concept: a monitor lizard seen from above, sprawled into a square puzzle body. Head = N tab, curled tail = S tab, splayed legs at
the four corners, double blanks bitten into E and W flanks. Mossy green from the den dragon, back rows of sunset-orange spots and
mauve tail rings from cell 1-5 (the sunset sky through the cave mouth)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

MOSS = K.ramp('#6fa040')
MOSSLT = K.ramp('#9cc060')
SUN = K.ramp('#e8a068')
MAUVE = K.ramp('#b06a5a')
HORN = K.ramp('#e8c890')


def fn(c):
    S = 1.15 if c.small else 1.0
    core = rect(11, 20, 53, 50)
    blankE = knob('B', 'double', 53, 35, 1, 0, r=4.5 * S)
    blankW = knob('B', 'double', 11, 35, -1, 0, r=4.5 * S)
    head = ell(32, 14, 8.5, 9.5)
    neck = rect(26, 16, 38, 23)
    tw = 7.5 if not c.small else 8.5
    tail = thick_path([(32, 46), (32, 55), (37, 59.5), (43, 59), (45, 56)], tw)
    tailtip = ell(45.5, 55, 3.0, 3.0)
    lw = 5.0 if not c.small else 6.0
    legs = [thick_path([(14, 23), (7, 19)], lw), thick_path([(50, 23), (57, 19)], lw),
            thick_path([(14, 47), (7, 51)], lw), thick_path([(50, 47), (57, 51)], lw)]
    # legs first (under), then tail, body, head
    c.add(c.m(*legs, minus=(core,)), MOSS)
    c.add(c.m(tail, tailtip, minus=(core,)), MOSS)
    body = c.m(core, minus=(blankE, blankW))
    c.add(body, MOSS, stitch=None)
    hd = c.m(head, neck)
    c.add(hd, MOSS)
    # mossy spine stripe
    c.add(body & c.m(rect(27, 20, 37, 50)), MOSSLT)
    # horn nubs at the back of the head (den dragon's horns)
    c.add(c.m(ell(24.5, 19, 2.4, 2.8)), HORN)
    c.add(c.m(ell(39.5, 19, 2.4, 2.8)), HORN)
    # sunset spots in rows on the flanks
    for (sx, sy) in ((18, 26), (46, 26), (18, 44), (46, 44), (32, 30), (32, 41)):
        r = 2.6 if not c.small else 3.0
        c.add(body & c.m(ell(sx, sy, r, r)), SUN)
    # mauve tail rings
    tm = c.m(tail, tailtip, minus=(core,))
    for (a, b) in (((28, 52), (37, 52)), ((36, 56), (36, 64)), ((43, 55), (43, 64))):
        ring = c.m(thick_path([a, b], 2.6 if not c.small else 3.2))
        c.add(ring & tm, MAUVE)
    # toes
    for tx, ty in ((6.5, 18.5), (57.5, 18.5), (6.5, 51.5), (57.5, 51.5)):
        c.add(c.m(ell(tx, ty, 2.8, 2.8)), MOSS)
    c.edge(hd, MOSS[1])
    # face
    c.eye(28.5, 12.5, disc=True)
    c.eye(35.5, 12.5, disc=True)
    c.smile(32, 18.5, K.UMBER2)
    c.blush(25.5, 16)
    c.blush(38, 16)


K.render_pal(fn, 'pl-dlz-6', 'Mossback Monitor', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-dlz-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-dlz-6.png')
