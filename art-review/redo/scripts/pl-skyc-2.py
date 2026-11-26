# Concept: a pink cloud-puff raft (edge-TBB, keyhole): flat bottom = the cloud bank's flat base, keyhole tab N = a round
# cloud puff on top, keyhole blanks W and E bitten into its sides; peach-cream and sunset pink from cell 3-7 / the sky, lilac dusk underside.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, poly

PINK = K.ramp('#f0a8b4')
PEACH = K.ramp('#f8cbb4')
CREAMC = K.ramp('#fdebd9')
LILAC = K.ramp('#c49ad0')


def fn(c):
    k = 1.15 if c.small else 1.0
    # core: a wide cloud slab, straight sides between the knobs, flat base
    core = rect(7, 27, 57, 54)
    puffs = (ell(14, 27, 7, 6.5), ell(25, 23, 7.5, 6.5), ell(40, 23, 7.5, 6.5), ell(50, 27, 7, 6.5))
    tabN = knob('T', 'keyhole', 32, 19, 0, -1, r=6.2 * k)
    blW = knob('B', 'keyhole', 7, 39, -1, 0, r=4.6 * k, nw=2.4)
    blE = knob('B', 'keyhole', 57, 39, 1, 0, r=4.6 * k, nw=2.4)
    body = c.m(core, *puffs, ell(32, 24, 6, 5), tabN, minus=(blW, blE))
    c.add(body, PINK, stitch=None)
    # cream sunlit tops on each puff and on the tab head (light from the upper left)
    hl = (ell(13, 24, 4.5, 3.2), ell(24, 20, 5, 3.2), ell(39, 20, 5, 3.2), ell(49, 24, 4.5, 3.2),
          ell(31, 9.5, 4.2 * k, 3.4 * k))
    top = c.m(*hl) & body
    c.add(top, CREAMC)
    # sky-lilac shade band under the flat base (the picture's dusk), with soft cloud bumps on its top edge
    band = c.m(lambda x, y: y > 47.5 - (1.4 if ((x - 7) % 10) < 5 else 0)) & body
    c.add(band, LILAC)
    c.edge(band, LILAC[1])
    # face on the calm pink middle
    c.eye(25, 35)
    c.eye(39, 35)
    c.smile(32, 40)
    c.blush(20, 40)
    c.blush(43, 40)
    # two sky sparkles drifting by (the stars of the picture)
    if not c.small:
        c.line([(15, 51), (22, 51)], '#e8d8f0')
        c.line([(41, 51), (49, 51)], '#e8d8f0')


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-skyc-2', 'Pinkpad Float', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-skyc-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-skyc-2.png'))
