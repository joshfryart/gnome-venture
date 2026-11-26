#!/usr/bin/env python3
"""pl-kava-2 "Palm Eavesdrop": edge-TTB, peg. A palm tree that IS an edge piece: flat S = sandy foot, the square body is the
fat bark trunk (kava-hut wall brown, cell 10-3) under a green frond crown; peg tab N = the crown's top shoot, peg tab E = a frond
held out to listen; peg blank W cut into the trunk. Fronds droop past the top corners; a torch-flame orange leaf drops (cell flame)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BARK = K.ramp('#aa6d4a')
BARKD = '#875a40'
LEAF = K.ramp('#7cbc50')
LEAFD = K.ramp('#4f8a3a')
SAND = K.ramp('#f2c683')
FLAME = K.ramp('#ff7a30')
NUT = K.ramp('#7a4a2c')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(13, 22, 51, 58)
    tabN = K.knob('T', 'peg', 32, 22, 0, -1, r=4.6 * k)
    tabE = K.knob('T', 'peg', 51, 44, 1, 0, r=4.4 * k)
    blankW = K.knob('B', 'peg', 13, 45, -1, 0, r=4.4 * k)
    body = c.m(core, minus=(blankW,))
    c.add(body, BARK)
    # bark rings: chevrons down the trunk
    for yy in (42, 51) if not c.small else (43, 52):
        c.line([(20, yy - 2.5), (32, yy + 1), (45, yy - 2.5)], BARKD)
    # sandy foot
    c.add(body & c.m(K.rect(0, 54.5, 64, 58)), SAND)
    # frond crown filling the top of the body: scalloped drooping lower edge
    def crown(x, y):
        drop = 31 + (3.5 if int(x // 6.4) % 2 == 0 else 0)
        return 13 <= x < 51 and 21 <= y < drop
    hw = 4.0 if not c.small else 4.8
    fronds = [
        [(30, 22), (20, 16), (10, 17), (4, 24), (3, 31)],
        [(34, 22), (44, 16), (54, 17), (60, 24), (61, 31)],
        [(30, 21), (24, 12), (15, 8)],
        [(34, 21), (40, 12), (49, 8)],
    ]
    # leaflets: saw teeth hanging under each frond arc (the palm cue lives in the silhouette)
    teeth = []
    for f in fronds:
        for (ax, ay), (bx, by) in zip(f, f[1:]):
            for t in (0.2, 0.6, 1.0):
                x, y = ax + (bx - ax) * t, ay + (by - ay) * t
                if 12 < x < 52 and y > 20:
                    continue
                s_ = 1 if x > 32 else -1
                teeth.append(K.poly([(x - 2.8, y - 1), (x + 2.8, y - 1), (x + 2.5 * s_, y + 6)]))
    crownm = c.m(crown, tabN, *[K.thick_path(f, hw) for f in fronds], *teeth, minus=(blankW,))
    c.add(crownm, LEAF, stitch=None if c.small else LEAFD[0])
    # leaf ribs
    for f in fronds:
        c.line(f, LEAFD[1])
    c.line([(32, 12), (32, 28)], LEAFD[1])
    # coconuts hanging under the crown
    c.add(c.m(K.ell(26, 33.5, 3.6, 3.4), K.ell(38, 33.5, 3.6, 3.4)), NUT)
    # E tab: a cupped leaf held to the trunk like an ear, listening in
    c.add(c.m(tabE), LEAF)
    c.line([(51, 44), (58, 44)], LEAFD[1])
    # face on the trunk, glancing toward the listening frond
    c.eye(26, 43, look=(1, 0))
    c.eye(36, 43, look=(1, 0))
    c.smile(31, 48, wide=not c.small)
    c.blush(23, 47)
    c.blush(41, 47)
    # the dropped leaf, torch-flame orange, falling by the W blank
    leaf = K.poly([(1, 55), (5, 51), (11, 52), (8, 56), (3, 57)])
    c.add(c.m(leaf), FLAME)
    c.line([(2, 56), (9, 53)], FLAME[1])


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-kava-2', 'Palm Eavesdrop', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-kava-2-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-kava-2.png'))
