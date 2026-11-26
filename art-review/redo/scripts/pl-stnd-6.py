#!/usr/bin/env python3
"""pl-stnd-6 Hollowtop Menhir (rare, whimsy-menhir, keyhole).
Concept: a tall round-shouldered standing stone that is the piece: keyhole BLANK cut down into its crown (the 'hollow on top', ringed by a
mossy cap), keyhole TAB on the east flank, keyhole BLANK on the west flank, flat grassy foot. Lavender-grey stone, moss green, and the
aqua portal glow of cell 6-5 as glowing runes carved down the face."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = K.ramp('#aaa4c4')
STONE_D = K.ramp('#847ca0')
MOSS = K.ramp('#529054')
GRASS = K.ramp('#3a704a')
GLOW = '#a8f4e8'
GLOW2 = '#78c8c0'
HOLLOW = '#463e62'


def fn(c):
    import math
    k = 1.15 if c.small else 1.0
    # tall round-topped menhir core, slightly leaning crown
    core = (K.rect(16, 20, 46, 59), K.ell(31, 20, 15, 14))
    tabE = K.knob('T', 'keyhole', 46, 36, 1, 0, r=4.6 * k)
    blankW = K.knob('B', 'keyhole', 16, 45, -1, 0, r=3.9 * k)
    body = c.m(*core, tabE, minus=(blankW,))
    c.add(body, STONE, stitch=None if c.small else STONE_D[1])
    tab = c.m(tabE, minus=(K.rect(0, 0, 46, 64),)) & body
    c.add(tab, STONE_D)
    # mossy cap over the crown with a wavy drip edge
    cap = c.m(lambda x, y: y < 17 + 2.4 * math.sin(x * 0.8)) & body
    c.add(cap, MOSS)
    # the dark hollow on top: a sunken pit in the moss
    pit = c.m(K.ell(31, 9.5, 5.2, 2.6)) & body
    c.add(pit, (HOLLOW, '#2e2a48', '#2e2a48'))
    if not c.small:
        c.line([(27, 11.8), (35, 11.8)], MOSS[2])
    # moss tufts on the shoulder and tab
    c.add(c.m(K.ell(19, 23, 2.6, 2.6), K.ell(55.5, 33.5, 2.6, 1.8)) & body, MOSS)
    # grassy foot band
    foot = c.m(lambda x, y: y > 54 - (1.6 if (int(x) // 3) % 2 else 0)) & body
    c.add(foot, GRASS)
    # glowing runes (the portal light) carved on the stone
    if not c.small:
        runes = [[(20, 24), (20, 29)], [(18, 26), (22, 27)], [(40, 45), (40, 51)], [(38, 46), (42, 48)], [(31, 45), (31, 51)], [(29, 47), (33, 49)]]
    else:
        runes = [[(20, 24), (20, 29)], [(41, 45), (41, 51)], [(31, 46), (31, 51)]]
    for r in runes:
        c.line(r, GLOW)
    if not c.small:
        c.line([(37, 25), (39, 28), (38, 31)], STONE_D[0])
    # face
    c.eye(26.5, 32)
    c.eye(36, 32)
    c.smile(31, 37)
    c.blush(22.5, 36)
    c.blush(39, 36)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-stnd-6', 'Hollowtop Menhir', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-stnd-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-stnd-6.png')
    print(rep)
