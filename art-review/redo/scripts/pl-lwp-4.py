# Battlement Whistle: a brick wall-walk segment that is an inner-TTTT piece; top tab (double) + two corner merlons = four battlements,
# left/right/bottom double tabs; mauve-red bricks with plum mortar and a beige paving footing from cell 5-5.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

BRICK = K.ramp('#a46068')
MORTAR = '#5f3d58'
PAVE = K.ramp('#c4b2a0')
PLUM = K.ramp('#744a68')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(14, 17, 50, 49)
    m1 = K.rect(14, 9, 23, 18)
    m2 = K.rect(41, 9, 50, 18)
    top = K.knob('T', 'double', 32, 17, 0, -1, r=5.2 * k)
    lt = K.knob('T', 'double', 14, 31, -1, 0, r=4.6 * k)
    rt = K.knob('T', 'double', 50, 31, 1, 0, r=4.6 * k)
    bt = K.knob('T', 'double', 32, 49, 0, 1, r=4.6 * k)
    wall = c.m(core, m1, m2, top, lt, rt)
    c.add(wall, BRICK)
    foot = c.m(K.rect(14, 42, 50, 49), bt)
    c.add(foot, PAVE)
    c.edge(foot, PLUM[1])
    # merlon caps in plum (coping stones)
    caps = c.m(K.rect(14, 9, 23, 12), K.rect(41, 9, 50, 12))
    c.add(caps, PLUM)
    pb = c.m(K.rect(38, 17, 50, 22), K.rect(14, 28, 20, 36), K.rect(14, 36, 26, 42), K.rect(45, 28, 50, 36))
    c.add(pb, PLUM)
    # brick courses
    rows = [22, 28, 36] if not c.small else [23, 37]
    for y in rows:
        c.line([(15, y), (49, y)], MORTAR)
    if not c.small:
        for (x, y0, y1) in [(20, 17, 22), (38, 17, 22), (29, 22, 28), (45, 22, 28), (20, 28, 36), (44, 28, 36), (26, 36, 42), (40, 36, 42),
                            (18, 12, 17), (46, 12, 17)]:
            c.line([(x, y0), (x, y1 - 1)], MORTAR)
        for (x, y0, y1) in [(8, 31, 36)]:
            pass
    else:
        for (x, y0, y1) in [(22, 17, 23), (42, 17, 23), (24, 37, 42), (40, 37, 42)]:
            c.line([(x, y0), (x, y1 - 1)], MORTAR)
    # face: felt eyes and a round whistle mouth (an O in the brickwork)
    c.eye(26, 31)
    c.eye(38, 31)
    cx, cy = c.P(32, 38)
    if not c.small:
        for dx, dy in [(-1, -1), (0, -1), (1, -1), (-2, 0), (2, 0), (-2, 1), (2, 1), (-1, 2), (0, 2), (1, 2)]:
            c.px(cx + dx, cy + dy, K.UMBER)
        for dx, dy in [(-1, 0), (0, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]:
            c.px(cx + dx, cy + dy, '#3c2438')
    else:
        for dx, dy in [(0, 0), (1, 0), (0, 1), (1, 1)]:
            c.px(cx + dx, cy + dy, K.UMBER)
    c.blush(21, 35)
    c.blush(42, 35)


K.render_pal(fn, 'pl-lwp-4', 'Battlement Whistle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-lwp-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-lwp-4.png')
