#!/usr/bin/env python3
"""pl-bvd-1 "Willow Chew": corner-BB, round. A beaver sitting face-on IS the corner piece: flat W and S sides (its back to the lodge,
its bottom on the lodge floor), a round blank N between its two round ears, a round blank E bitten into its flank. Buck teeth clamp a
willow stick with green leaves. Fur in the lodge-stick browns of cell 4-5, bottom band = the dam's stick strata (tan / plum-brown)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

FUR = K.ramp('#9a5c34')
BELLY = K.ramp('#d8a060')
STICKS = K.ramp('#b68050')
LODGE = K.ramp('#5c3c3c')
EAR = K.ramp('#7a4628')
TOOTH = ('#f4f0e4', '#c9c5bc', '#ffffff')
WILLOW = K.ramp('#b07a3a')
LEAF = K.ramp('#3f9a4a')
NOSE = '#3d2d36'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 14, 55, 59)
    blankN = K.knob('B', 'round', 32, 14, 0, -1, r=4.6 * k)
    blankE = K.knob('B', 'round', 55, 40, 1, 0, r=4.6 * k)
    earL = K.ell(15.5, 13.5, 6, 5.5)
    earR = K.ell(48.5, 13.5, 6, 5.5)
    body = c.m(core, earL, earR, minus=(blankN, blankE))
    c.add(body, FUR, stitch=None if c.small else FUR[2])
    # inner ears
    c.add(c.m(K.ell(15.5, 13.5, 3, 2.6)), EAR)
    c.add(c.m(K.ell(48.5, 13.5, 3, 2.6)), EAR)
    # belly
    c.add(c.m(K.ell(30, 51, 13, 10)) & body, BELLY)
    # lodge stick strata along the bottom (the dam cell)
    band = c.m(K.rect(0, 53, 64, 59)) & body
    c.add(band, STICKS)
    for (x0, x1, y) in ((10, 26, 55), (30, 46, 56.5), (40, 54, 54.5), (16, 34, 57.5)):
        c.add(c.m(K.thick_path([(x0, y), (x1, y)], 1.6 if not c.small else 2.0)) & band, LODGE)
    # muzzle
    c.add(c.m(K.ell(32, 33, 9, 6.5)), BELLY)
    # willow stick held across, leaves at both ends
    sw = 3.2 if not c.small else 3.6
    c.add(c.m(K.thick_path([(12, 41), (41, 40)], sw)), WILLOW)
    c.add(c.m(K.ell(13.5, 37.5, 3.2, 2.0), K.ell(16, 44, 3.2, 2.0), K.ell(40.5, 36.8, 2.8, 1.8)) & body, LEAF)
    # teeth over the stick
    c.add(c.m(K.rect(29, 35, 35.2, 41.5)), TOOTH)
    c.line([(32.1, 35), (32.1, 41)], '#c9c5bc')
    # nose
    nx, ny = c.P(32, 30)
    for dx in range(-2 if not c.small else -1, 2 if not c.small else 1):
        c.px(nx + dx, ny, NOSE)
    if not c.small:
        c.px(nx - 1, ny + 1, NOSE)
        c.px(nx, ny + 1, NOSE)
    c.eye(23, 25, disc=True)
    c.eye(41, 25, disc=True)
    c.blush(20, 31)
    c.blush(43, 31)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-bvd-1', 'Willow Chew', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-bvd-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-bvd-1.png')
    print(rep)
