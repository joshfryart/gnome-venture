"""br-panda-puff: inner-TTTB peg. A sitting panda face-on; the square body is the piece. N peg tab = the bamboo stalk it holds,
poking up between the black ears; W + E peg tabs = black arms; S peg blank = the gap between the two black legs.
Bamboo green, fur white and indigo-black from Blossomreach cell 10-6."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

WHITE = K.ramp('#eeece4')
BLACK = K.ramp('#3e3a4c')
GREEN = K.ramp('#5ea83a')
LEAF = K.ramp('#86c24a')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(13, 17, 51, 57)
    tabN = K.knob('T', 'peg', 32, 17, 0, -1, r=4.2 * s)
    tabW = K.knob('T', 'peg', 13, 41, -1, 0, r=4.6 * s)
    tabE = K.knob('T', 'peg', 51, 41, 1, 0, r=4.6 * s)
    blankS = K.knob('B', 'peg', 32, 57, 0, 1, r=4.4 * s)
    earL, earR = K.ell(17, 18, 6, 5.5), K.ell(47, 18, 6, 5.5)
    body = c.m(core, minus=(blankS,))
    c.add(body, WHITE, stitch=None)
    # ears
    c.add(c.m(earL, earR), BLACK)
    # black shoulder band + arms (tabs W/E)
    band = c.m(K.rect(13, 35, 51, 47), tabW, tabE) 
    c.add(band, BLACK)
    # legs: bottom corners black
    legs = c.m(K.ell(19, 53, 7.5, 6.5), K.ell(45, 53, 7.5, 6.5), K.rect(13, 50, 51, 57), minus=(blankS,)) & body
    c.add(legs, BLACK)
    # white belly between band and legs
    belly = c.m(K.ell(32, 47, 11, 7), minus=(blankS,)) & body
    c.add(belly, WHITE)
    # bamboo stalk: from the N tab, behind the head, held in front of the belly
    stalkN = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 14, 64, 18)))
    c.add(stalkN, GREEN)
    stalk = c.m(K.rect(29.2, 36, 34.8, 54)) & body
    c.add(stalk, GREEN)
    # bamboo nodes
    for ny in (10.5, 49):
        y = c.P(0, ny)[1]
        for x in range(c.P(29, 0)[0], c.P(35.5, 0)[0]):
            if (x, y) in stalkN or (x, y) in stalk:
                c.px(x, y, GREEN[1])
    # leaf from the top of the stalk
    c.add(c.m(K.poly([(35, 8), (44, 3.5), (48, 5), (40, 9.5)])), LEAF)
    # paws gripping the stalk
    c.add(c.m(K.ell(26.5, 42, 4.4, 3.8), K.ell(37.5, 42, 4.4, 3.8)), BLACK)
    c.add(c.m(K.poly([(35, 47), (42, 50), (44, 49), (37, 46)])) & body, LEAF)
    # face: eye patches, eyes, nose
    c.add(c.m(K.ell(24, 27, 5.0, 4.4), K.ell(22, 30, 3.6, 3.4), K.ell(40, 27, 5.0, 4.4), K.ell(42, 30, 3.6, 3.4)) & body, BLACK)
    c.eye(24, 27, disc=True, look=(1, 0))
    c.eye(40, 27, disc=True, look=(-1, 0))
    nx, ny = c.P(32, 31.5)
    for dx in (-1, 0, 1):
        c.px(nx + dx, ny, K.UMBER)
    c.px(nx, ny + 1, K.UMBER)
    if not c.small:
        c.px(nx - 2, ny + 2, K.UMBER2); c.px(nx - 1, ny + 3, K.UMBER2); c.px(nx + 1, ny + 3, K.UMBER2); c.px(nx + 2, ny + 2, K.UMBER2)
    c.blush(18, 32)
    c.blush(45, 32)
    # foot pads
    for fx in (19, 45):
        px, py = c.P(fx, 53)
        c.px(px, py, '#d89aa8')
        if not c.small:
            c.px(px + 1, py, '#d89aa8')


if __name__ == '__main__':
    print(K.render_pal(fn, 'br-panda-puff', 'Panda Puff', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/br-panda-puff-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/br-panda-puff.png'))
