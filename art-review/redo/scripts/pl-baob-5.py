#!/usr/bin/env python3
"""pl-baob-5 "Trunk Peephole": inner-BBBB, round. A square chunk of baobab trunk with stubby branch arms at the top corners and
root flares at the bottom corners, four round blanks cut into the bark, and a big round glowing window in the middle
with a wooden mullion cross; two felt eyes peek out of the upper panes. Colours from cell 5-4: peach/terracotta bark with
mauve fissures, lamp-lit cream-yellow glow, umber frame."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BARK = K.ramp('#c8845a')
BARKLT = K.ramp('#e0a070')
FISS = '#8a4a58'
FRAME = K.ramp('#7a4a2a')
GLOW = ('#f8d870', '#e8a830', '#fff4c8')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 13, 54, 53)
    armL = K.thick_path([(15, 15), (13, 6)], 7.0)
    armR = K.thick_path([(49, 15), (52, 5)], 7.0)
    rootL = K.poly([(10, 42), (10, 53), (2, 58), (24, 58), (22, 53)])
    rootR = K.poly([(54, 42), (54, 53), (62, 58), (40, 58), (42, 53)])
    blanks = (K.knob('B', 'round', 32, 13, 0, -1, r=3.8 * k),
              K.knob('B', 'round', 32, 53, 0, 1, r=3.8 * k),
              K.knob('B', 'round', 10, 30, -1, 0, r=3.8 * k),
              K.knob('B', 'round', 54, 30, 1, 0, r=3.8 * k))
    body = c.m(core, armL, armR, rootL, rootR, minus=blanks)
    c.add(body, BARK, stitch=None)
    # lighter bark patches (picture's mottled trunk)
    c.add(body & c.m(K.ell(18, 44, 3.5, 4.5), K.ell(47, 45, 3.5, 4), K.ell(21, 20, 3, 3.5)), BARKLT)
    # cut branch ends: light wood rings
    c.add(c.m(K.ell(13, 6.5, 3.0, 2.0), K.ell(52, 5.5, 3.0, 2.0)) & body, ('#ecc08a', '#d09a60', '#f8dcae'))
    # a leaf sprig on the right branch
    c.add(c.m(K.ell(57.5, 11, 3.6, 2.4), K.ell(55, 14.5, 2.4, 1.8), minus=(K.thick_path([(49, 15), (52, 5)], 7.0),)), K.ramp('#5a9a3a'))
    # long vertical bark fissures (trunk grain)
    for pts in ([(15, 36), (14, 44), (16, 52)], [(49, 36), (50, 44), (48, 52)], [(25, 16), (24, 20)], [(40, 16), (41, 20)],
                [(27, 45), (26, 52)], [(38, 45), (39, 52)]):
        c.line(pts, FISS)
    # round window: frame ring, glow, mullions
    frame = c.m(K.ell(32, 31, 11.5, 11.5))
    c.add(frame, FRAME)
    glass = c.m(K.ell(32, 31, 8.8, 8.8))
    c.add(glass, GLOW)
    c.edge(frame, FRAME[1])
    mw = 1.6 if c.small else 1.3
    for x, y in c.m(K.rect(32 - mw, 21, 32 + mw, 41), K.rect(22, 32.5 - mw, 42, 32.5 + mw)) & glass:
        c.px(x, y, FRAME[0])
    # eyes peeking out of the upper panes
    c.eye(27.5, 28.5)
    c.eye(37, 28.5)
    c.blush(26, 36) if not c.small else None
    c.blush(37, 36) if not c.small else None


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-baob-5', 'Trunk Peephole', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-baob-5-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-baob-5.png'))
