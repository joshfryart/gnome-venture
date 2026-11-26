#!/usr/bin/env python3
"""pl-snw-2 "Acacia Sprig": edge-BTB, peg. A flat-topped savanna acacia that IS an edge piece: the flat side is the flat crown top (N),
the S peg tab is the trunk planted in a tan savanna clod, peg blanks W + E bite into the canopy sides. Canopy greens from the picture's
acacias, trunk brown and tan/rock from the cell (lion mane brown, tan coat, grey rock)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

LEAF = K.ramp('#5b8133')
LEAFLT = K.ramp('#739941')
LEAFDK = K.ramp('#2f4b1e')
BARK = K.ramp('#74462a')
TAN = K.ramp('#c5a66d')
ROCK = K.ramp('#a89a82')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(5, 12, 59, 46)
    blankW = K.knob('B', 'peg', 5, 29, -1, 0, r=4.2 * k)
    blankE = K.knob('B', 'peg', 59, 29, 1, 0, r=4.2 * k)
    tabS = K.knob('T', 'peg', 32, 46, 0, 1, r=5.4 * k, nw=3.4)
    body = c.m(core, minus=(blankW, blankE))
    # canopy underside (dark) then the flat crown layers
    c.add(body, LEAFDK)
    # trunk peg + branches forking up through the dark underside
    trunk = c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(K.rect(0, 43, 64, 47)))
    bw = 3.4 if c.small else 3.0
    br = c.m(K.thick_path([(32, 47), (32, 40), (22, 33), (16, 31)], bw),
             K.thick_path([(32, 40), (42, 33), (48, 31)], bw),
             K.thick_path([(32, 42), (32, 32)], bw)) & body
    c.add(br, BARK)
    c.add(trunk, BARK)
    # savanna clod at the trunk foot (tan grass, grey rock)
    foot = c.m(tabS) & c.m(K.rect(0, 54, 64, 64))
    c.add(foot, TAN)
    # flat crown: wide mid-green slab, light top layer, lumpy lower hem
    hem = lambda x, y: 12 <= y < 30 + 3 * abs(((x - 2.5) % 7) - 3.5) / 3.5
    crown = c.m(hem) & body
    c.add(crown, LEAF, stitch=None if c.small else LEAFLT[2])
    top = c.m(K.rect(0, 12, 64, 18)) & body
    c.add(top, LEAFLT)
    if not c.small:
        for (x, y) in crown:
            if y > c.P(0, 20)[1] and (x * 3 + y * 5) % 11 == 0:
                c.px(x, y, LEAFLT[0])
    c.edge(crown, LEAF[1])
    # rock pebble + grass tuft on the clod
    c.px(*c.P(28, 57), ROCK[2] if not c.small else ROCK[0])
    gx, gy = c.P(35, 56)
    c.px(gx, gy, LEAFLT[0])
    # face on the calm crown
    c.eye(24, 23, disc=False)
    c.eye(40, 23, disc=False)
    c.smile(32, 27)
    c.blush(19, 27)
    c.blush(44, 27)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-snw-2', 'Acacia Sprig', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-snw-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-snw-2.png'))
