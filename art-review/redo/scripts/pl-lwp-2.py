# Concept: a living chunk of the Long Wall's brick parapet. Edge-TBB peg: flat S (stands on the walk), peg tab N = a square merlon
# (crenellation) capped in walkway stone, peg blanks W + E = the embrasure notches. Body is the picture's mauve-red brick with plum
# mortar, a pale paver coping with the cell's purple crack, and cream chalk tally marks on the bricks (it counts them).
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

BRICK = K.ramp('#a46068')
MORTAR = '#6e4664'
STONE = ('#d7c9b5', '#b09e8a', '#ece2d2')
CRACK = '#907f90'
CHALK = '#f4ecd8'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(11, 22, 53, 59)
    tabN = K.knob('T', 'peg', 32, 22, 0, -1, r=7.0 * k, nw=5.5)
    blW = K.knob('B', 'peg', 11, 44, -1, 0, r=4.4 * (1.05 if c.small else 1.0))
    blE = K.knob('B', 'peg', 53, 44, 1, 0, r=4.4 * (1.05 if c.small else 1.0))
    body = c.m(core, tabN, minus=(blW, blE))
    c.add(body, BRICK)
    # mortar courses + staggered joints
    bricks = c.m(K.rect(11, 29, 53, 59), minus=(blW, blE))
    if True:
        rows = [29, 36, 43, 50] if not c.small else [29, 37.5, 46]
        for i, y0 in enumerate(rows):
            _, py = c.P(0, y0)
            for (x, y) in bricks:
                if y == py:
                    c.px(x, y, MORTAR)
        step = 7 if not c.small else 8.5
        for i, y0 in enumerate(rows):
            y1 = rows[i + 1] if i + 1 < len(rows) else 59
            off = 0 if i % 2 == 0 else step * 1.5
            x = 11 + off + step * 1.5
            while x < 53:
                px, _ = c.P(x, 0)
                for (xx, yy) in bricks:
                    if xx == px and c.P(0, y0)[1] < yy < c.P(0, y1)[1]:
                        c.px(xx, yy, MORTAR)
                x += step * 3
    # stone coping on top (and on the merlon cap)
    cap = c.m(K.rect(9, 22, 55, 29)) & body | (c.m(K.rect(0, 0, 64, 12)) & body)
    cap2 = c.m(K.rect(11, 22, 53, 28.5))
    c.add(cap2, STONE)
    c.add(c.m(tabN) & c.m(K.rect(0, 0, 64, 12.5 if not c.small else 13)), STONE)
    c.line([(40, 22.5), (38, 25.5), (39, 28.5)], CRACK)
    c.line([(18, 23), (20, 27)], CRACK)
    # face
    c.eye(25, 37, disc=True)
    c.eye(39, 37, disc=True)
    c.smile(32, 41.5, '#4a2c1a')
    c.blush(20, 41)
    c.blush(43, 41)
    # chalk tally marks on the lower bricks (four strokes + a slash)
    if not c.small:
        for tx in (21, 24, 27, 30):
            c.line([(tx, 51.5), (tx, 56.5)], CHALK)
        c.line([(19, 56), (32, 51.5)], CHALK)
    else:
        for tx in (20, 24, 28):
            c.line([(tx, 49), (tx, 55)], CHALK)
        c.line([(18, 54.5), (31, 49.5)], CHALK)


K.render_pal(fn, 'pl-lwp-2', 'Brick Counter', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-lwp-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-lwp-2.png')
