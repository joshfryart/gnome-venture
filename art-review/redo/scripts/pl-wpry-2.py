#!/usr/bin/env python3
"""pl-wpry-2 "Glacier Hat": a snowy mountain peak that is an edge piece wearing a puffy cloud hat.
Flat S (the mountain's foot), keyhole tab N (the cloud hat's top puff), keyhole blanks W and E (cut into the rock flanks).
Colours from cell 6-0 (cream cloud #fff6e0, sky blues #78b4ec / #5a9ae0, pale #c8d8ec) and the picture's peaks (#8a90b8 / #5e6694)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROCK = K.ramp('#8a90b8')
SNOW = ('#fff6e0', '#b8c4e4', '#ffffff')
CLOUD = ('#fff6e0', '#c8d8ec', '#ffffff')
SKY = K.ramp('#5a9ae0')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.poly([(8, 59), (8, 40), (32, 16), (56, 40), (56, 59)])
    tabN = K.knob('T', 'keyhole', 32, 15, 0, -1, r=5.4 * s, nw=2.4)
    bW = K.knob('B', 'keyhole', 8, 50, -1, 0, r=4.3 * s)
    bE = K.knob('B', 'keyhole', 56, 50, 1, 0, r=4.3 * s)
    body = c.m(core, minus=(bW, bE))
    c.add(body, ROCK, stitch=None)
    # snow cap: zigzag skirt down the slopes
    zz = lambda x, y: y < 33 - (3.5 if (int(x) // 4) % 2 else 0) + abs(x - 32) * 0.12
    c.add(body & c.m(zz), SNOW)
    if not c.small:
        c.line([(16, 56), (21, 49)], ROCK[1])
        c.line([(48, 56), (43, 49)], ROCK[1])
    # cloud hat: the keyhole tab is the puffy crown, a cream brim with a sky-blue band sits on the summit
    crown = c.m(tabN) | c.m(K.ell(32, 16.5, 5.5, 3.5))
    c.add(crown, CLOUD)
    brim = c.m(K.ell(32, 21, 11, 3.2), K.ell(22.5, 20.5, 4.2, 3.4), K.ell(41.5, 20.5, 4.2, 3.4))
    c.add(brim, CLOUD)
    c.edge(brim, CLOUD[1])
    c.add(c.m(K.rect(26.5, 16.5, 37.5, 19.2)), SKY)
    # face on the rock, between the blanks
    c.eye(26.5, 41)
    c.eye(37.5, 41)
    c.blush(22, 45)
    c.blush(40.5, 45)
    c.smile(32, 45)


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-wpry-2', 'Glacier Hat', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-wpry-2-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-wpry-2.png'))
