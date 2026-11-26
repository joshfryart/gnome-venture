"""ss-cocopaddle "Cocopaddle" (rare, whimsy-boat, peg), sunsprinkle cell 6-2.
Concept: a coconut-half sailboat that is a puzzle piece. Square-ish core = coral-and-cream striped sail (top) on a half-coconut hull
(brown hairy shell, cream flesh rim) riding a teal sea band (bottom). Peg tabs: N = mast-top cap with pennant, E = the sail's billow.
Peg blank: W cut into the sail; the sea band is the flat S side (a blank there read as legs). A slate paddle dips into the sea. Colours from the cell: sky #bee9f0, sea teal #1f8fa7, coral #c76a59,
slate fishing line #4a5a6a (the paddle shaft), cream #fef4e8, coconut brown #74462c. The coconut's three 'eyes' are its face."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

CORAL = K.ramp('#c76a59')
CREAMR = ('#fef4e8', '#d8c8b0', '#ffffff')
SHELL = K.ramp('#7a4a2c')
SEA = K.ramp('#1f8fa7')
SLATE = K.ramp('#4a5a6a')
SKY = K.ramp('#8fd4e0')


def fn(c):
    k = 1.15 if c.small else 1.0
    sail = K.rect(13, 9, 51, 33)
    hull = lambda x, y: y >= 31 and ((x - 32) / 25) ** 2 + ((y - 31) / 20) ** 2 < 1
    sea = K.poly([(9, 46), (55, 46), (57, 49), (57, 55), (7, 55), (7, 49)])
    tabN = K.knob('T', 'peg', 32, 9, 0, -1, r=3.6 * k, nw=2.4)
    tabE = K.knob('T', 'peg', 51, 20, 1, 0, r=3.6 * k, nw=2.4)
    blankW = K.knob('B', 'peg', 13, 20, -1, 0, r=3.4 * k, nw=2.2)
    blankS = K.knob('B', 'peg', 32, 56, 0, 1, r=3.2 * k, nw=2.2)
    minus = (blankW,)
    whole = c.m(sail, hull, sea, tabN, tabE, minus=minus)
    # sail with vertical coral / cream stripes (the striped pier awning)
    sailm = whole & c.m(sail, tabE, tabN)
    stripe = lambda x, y: int((x - 13) // 6.4) % 2 == 0
    c.add(sailm & c.m(stripe), CORAL)
    c.add(sailm - c.m(stripe), CREAMR)
    # mast-top cap: slate peg with a little coral pennant
    cap = whole & c.m(tabN, minus=(sail,))
    c.add(cap, SLATE)
    # sea band
    seam = whole & c.m(sea)
    c.add(seam, SEA)
    # coconut hull: shell + cream flesh rim
    hm = whole & c.m(hull, minus=(K.rect(0, 47, 64, 64),))
    hm = hm | (whole & c.m(lambda x, y: hull(x, y) and y < 50 and abs(x - 32) < 25 * (1 - ((y - 31) / 20) ** 2) ** .5 - 0))
    c.add(c.m(K.rect(7, 31, 57, 35.5)) & whole, CREAMR)
    c.add(whole & c.m(hull, minus=(K.rect(0, 0, 64, 35.5), K.rect(0, 50, 64, 64))), SHELL, stitch=None)
    c.edge(c.m(K.rect(7, 31, 57, 35.5)) & whole, '#d8c8b0')
    # mast (slate) through sail
    c.add(whole & c.m(K.rect(30.6, 9, 33.4, 31)), SLATE)
    # paddle: slate shaft held across the hull's right, coral blade dipping into the sea
    c.add(whole & c.m(K.thick_path([(41, 30), (51, 51)], 2.8 if c.small else 2.2)), SLATE)
    c.add(whole & c.m(K.ell(51.5, 51, 3.2, 3.6)), CORAL)
    # pennant on the mast cap
    c.add(c.m(K.poly([(34, 2.2), (41, 4.2), (34, 6.4)])), CORAL)
    # coconut fibres on the shell
    if not c.small:
        for (x0, y0) in ((14, 40), (20, 44), (44, 44), (50, 40), (26, 46), (38, 46)):
            c.line([(x0, y0), (x0 + 1.5, y0 + 1.5)], SHELL[1])
    # waves
    wy = 52 if not c.small else 52.5
    y = c.P(0, wy)[1]
    for x in range(c.n):
        if (x // (3 if not c.small else 2)) % 2 == 0 and (x, y) in seam:
            c.px(x, y, SEA[2])
    # face on the shell (the coconut's eyes)
    c.eye(25, 40, disc=True)
    c.eye(39, 40, disc=True)
    c.smile(32, 44, col=CREAMR[0])
    c.blush(20, 43)
    c.blush(43, 43)


if __name__ == '__main__':
    print(K.render_pal(fn, 'ss-cocopaddle', 'Cocopaddle', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/ss-cocopaddle-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/ss-cocopaddle.png'))
