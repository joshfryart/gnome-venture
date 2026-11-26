"""pl-rrs-1 "Dotted Trail": corner-BB, round. A grey bilby (the songlines picture's creature, cell 6-6) sitting as a corner piece:
flat W and S sides, a round blank cut in the top between its tall pink ears, a round blank in the E side. A painted dot trail
(cyan / cream / ochre dots, from the picture's songline) loops across its grey fur."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp, UMBER, UMBER2, CREAM, BLUSH

GREY = ramp('#a49cb0')
GREYD = ramp('#857a96')
PINK = ramp('#e88aa8')
BELLY = ramp('#dcd6e2')
CYAN = '#4cc4c4'
DOTW = '#f8ecc0'
OCHRE = '#e89a48'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(8, 20, 56, 60)
    blankN = knob('B', 'round', 32, 20, 0, -1, r=4.8 * k)
    blankE = knob('B', 'round', 56, 46, 1, 0, r=4.8 * k)
    ew = 0 if not c.small else 0.6
    earL = poly([(9, 24), (12 - ew, 3), (17, 2), (23 + ew, 22)])
    earR = poly([(41 - ew, 22), (47, 2), (52 + ew, 3), (55, 24)])
    ears = c.m(earL, earR, minus=(core,))
    body = c.m(core, minus=(blankN, blankE))
    c.add(ears, GREY)
    # pink inner ears
    inL = poly([(13, 22), (14, 7), (16, 6), (19.5, 22)])
    inR = poly([(44.5, 22), (48, 6), (50, 7), (51, 22)])
    c.add(c.m(inL, inR) & ears, PINK)
    c.add(body, GREY, stitch=None)
    # darker back/flank at lower right, pale belly
    c.add(body & c.m(ell(50, 60, 16, 12)), GREYD)
    c.add(body & c.m(ell(26, 56, 13, 8)), BELLY)
    # face
    c.eye(19, 33, disc=False)
    c.eye(37, 33, disc=False)
    nx, ny = c.P(28, 39)
    for dx in range(-1, 2 if not c.small else 1):
        c.px(nx + dx, ny, PINK[1])
    if not c.small:
        c.px(nx, ny + 1, PINK[1])
    c.blush(14, 38)
    c.blush(41, 38)
    # painted dot trail: a wavy songline of big alternating cyan / cream dots crossing the fur (the picture's dotted path)
    if c.small:
        pts = [(11, 49), (17, 45), (23, 47), (29, 51), (35, 51), (41, 47), (46, 43)]
        sz = 2
    else:
        pts = [(11, 49), (17, 45), (23, 46), (29, 50), (35, 51), (41, 48), (46, 43)]
        sz = 4
    for i, (x, y) in enumerate(pts):
        px, py = c.P(x, y)
        col = CYAN if i % 2 == 0 else DOTW
        for dx in range(sz):
            for dy in range(sz):
                if sz == 4 and dx in (0, 3) and dy in (0, 3):
                    continue
                c.px(px + dx, py + dy, col)
    # ochre dot ring on the forehead (rock-art dots)
    ring = [(32, 26), (29, 27.5), (35, 27.5)] if not c.small else [(32, 27)]
    for (x, y) in ring:
        px, py = c.P(x, y)
        c.px(px, py, OCHRE)
        if not c.small:
            c.px(px + 1, py, OCHRE)

K.render_pal(fn, 'pl-rrs-1', 'Dotted Trail', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-rrs-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-rrs-1.png')
