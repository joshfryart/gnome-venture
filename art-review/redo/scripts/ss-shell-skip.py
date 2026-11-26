"""Shell Skip: a hermit crab whose spiral shell IS a corner-BB keyhole piece. Flat W and S sides (it sits on the sand),
keyhole blanks cut into the shell on N and E. Sand-gold shell banded in palm-trunk brown, hammock-red crab with
eye stalks and a big claw out of the aperture at lower left, teal-water lip (cell 0-4 of Sunsprinkle)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

SHELL = ramp('#d9b77a')
BAND = ramp('#a88659')
RED = ramp('#d6312b')
CLAW = ramp('#e04a3a')
TEAL = ramp('#2bb3bf')
STALK = ramp('#a8241f')


def fn(c):
    k = 1.15 if c.small else 1.0
    sq = rect(8, 9, 56, 56)
    # rounded shell back at top-left, a conch spire curling out at top-right (between the two blanks)
    notch = rect(0, 0, 18, 19)
    round_tl = ell(18, 19, 10, 10)
    spire = poly([(44, 9), (52, 5), (58, 2.5), (60, 4), (59, 9), (56, 21), (56, 9)])
    core = lambda x, y: (sq(x, y) and (not notch(x, y) or round_tl(x, y))) or spire(x, y)
    bN = knob('B', 'keyhole', 38, 9, 0, -1, r=4.4 * k)
    bE = knob('B', 'keyhole', 56, 32, 1, 0, r=4.4 * k)
    body = c.m(core, minus=(bN, bE))
    # shell: whole piece, rounded spire at top-left
    c.add(body, SHELL, stitch=None)
    # spiral bands (palm-trunk brown) around the whorl centre
    cx, cy = 30, 30
    for rx, ry in ((19, 17), (12.5, 11), (6.5, 6)):
        ring = c.m(ell(cx, cy, rx, ry), minus=(ell(cx + 1.2, cy + 1.0, rx - 2.6, ry - 2.6),)) & body
        c.add(ring, BAND)
    c.add(c.m(ell(cx + 1, cy + 1, 2.6, 2.4)), BAND)
    # spire bands, a whorl line that runs up into the tip
    c.add(c.m(thick_path([(47, 12), (53, 8), (58, 4)], 2.4 if not c.small else 2.8)) & body, BAND)
    # aperture lip (teal, the water) and the crab coming out at lower left
    lip = c.m(ell(19, 50, 15, 11.5)) & body
    c.add(lip, TEAL)
    crab = c.m(ell(18, 51, 12.5, 9.5)) & body
    c.add(crab, RED)
    # eye stalks rising over the shell
    w = 2.8 if c.small else 2.4
    c.add(c.m(thick_path([(13, 44), (12, 36)], w)), STALK)
    c.add(c.m(thick_path([(22, 44), (23, 36)], w)), STALK)
    c.add(c.m(ell(12, 35, 3.4, 3.4)), CREAMR)
    c.add(c.m(ell(23, 35, 3.4, 3.4)), CREAMR)
    # big claw on the right of the opening
    claw = c.m(ell(38, 48, 7.5, 6), minus=(poly([(39, 47), (47, 43), (47, 49)]),)) & body
    c.add(claw, CLAW)
    c.edge(claw, RED[1])
    c.eye(12, 35.5, disc=False)
    c.eye(23, 35.5, disc=False)
    c.smile(18, 50, K.UMBER)
    c.blush(11, 51)
    c.blush(25, 51)


CREAMR = ramp('#f2d9a0')

if __name__ == '__main__':
    print(K.render_pal(fn, 'ss-shell-skip', 'Shell Skip', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/ss-shell-skip-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/ss-shell-skip.png'))
