# Dam Captain (pl-bvd-6), whimsy-beaver, double knobs.
# Concept: a face-on beaver whose square torso is the piece core. Double tab S = two big feet, double tab E = the flat
# cross-hatched tail paddle, double blank W cut into the flank, N = round head with ears under a water-blue captain cap.
# Colours from cell 3-4 / the dam picture: sandy dam tan, beaver browns, water blue cap, dark crack umber.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

FUR = ramp('#a86a42')
HEAD = ramp('#c48456')
BELLY = ramp('#e8b888')
TAIL = ramp('#5e3c34')
CAP = ramp('#245a88')
BAND = ramp('#d8a060')
TOOTH = ('#fffff0', '#d8d0b8', '#ffffff')
SAND = ramp('#d8a060')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 30, 47, 54)
    tabS = knob('T', 'double', 30, 54, 0, 1, r=6.2 * k, nw=3.4)
    tabE = knob('T', 'double', 47, 42, 1, 0, r=5.0 * k)
    blankW = knob('B', 'double', 13, 42, -1, 0, r=4.4 * k)
    head = ell(30, 24, 14, 11.5)
    body = c.m(core, head, minus=(blankW,))
    c.add(body, FUR)
    # ears
    c.add(c.m(ell(18.5, 15, 3.6, 3.6)) | c.m(ell(41.5, 15, 3.6, 3.6)), FUR)
    # head (lighter)
    hd = c.m(head) & c.m(rect(0, 0, 64, 34))
    c.add(hd, HEAD)
    # belly
    c.add(c.m(ell(30, 45, 9, 8.5), minus=(blankW,)) & body, BELLY)
    # feet = double tab S
    c.add(c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(rect(0, 52, 64, 55))), TAIL)
    fx, _ = c.P(30, 0)
    for y in range(c.P(0, 56)[1], c.n):
        c.px(fx, y, TAIL[1])
        if not c.small:
            c.px(fx - 1, y, TAIL[1])
    for tx_ in ((22.5, 26, 34, 37.5) if not c.small else (24, 36)):
        x_, y_ = c.P(tx_, 61)
        c.px(x_, y_, TAIL[2]); c.px(x_, y_ - 1, TAIL[2])
    # tail = double tab E, cross-hatched paddle
    tm = c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(rect(45, 0, 48, 64)))
    c.add(tm, TAIL)
    if not c.small:
        for (x, y) in tm:
            if (x + y) % 3 == 0 or (x - y) % 3 == 0:
                if all((x + dx, y + dy) in tm for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                    c.px(x, y, TAIL[1])
    else:
        for (x, y) in tm:
            if (x + y) % 2 == 0 and all((x + dx, y + dy) in tm for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                c.px(x, y, TAIL[1])
    # captain cap (water blue) with sandy band and peak
    cap = c.m(ell(30, 13.5, 11.5, 5.5), rect(19, 13, 41, 17.5))
    c.add(cap, CAP)
    c.add(c.m(rect(19, 15.5, 41, 18)), BAND)
    c.add(c.m(ell(30, 18.8, 10, 1.9)), CAP)
    c.px(*c.P(30, 12), '#f8d060')
    if not c.small:
        c.px(*c.P(31, 12), '#f8d060')
    # muzzle + nose + buck teeth
    c.add(c.m(ell(30, 29, 6, 3.6)), BELLY)
    nx, ny = c.P(30, 26.3)
    for dx in ((-1, 0, 1) if not c.small else (0, 1)):
        c.px(nx + dx - (0 if not c.small else 1), ny, K.UMBER)
    tx, ty = c.P(28.5, 31.5)
    tw, th = (3, 4) if not c.small else (2, 2)
    for dx in range(tw + (1 if not c.small else 0)):
        for dy in range(th):
            c.px(tx + dx, ty + dy, TOOTH[0])
    if not c.small:
        for dy in range(th):
            c.px(tx + 2, ty + dy, TOOTH[1])
    # stick it chews (dam log) across the chest
    c.add(c.m(thick_path([(15, 40.5), (45, 37.5)], 3.2 if not c.small else 3.6)) & body, SAND)
    c.eye(24.5, 23)
    c.eye(35.5, 23)
    c.blush(21, 27.5)
    c.blush(38, 27.5)


K.render_pal(fn, 'pl-bvd-6', 'Dam Captain', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-bvd-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-bvd-6.png')
