import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

# Ichu Whisker: a tuft of golden ichu grass in a lavender snow-leopard-spotted rock. inner-TBTB, tri knobs:
# top T = tallest grass blade, bottom T = the rock foot, left/right B. Colours: cell fur lavender-grey, peach sky, pink nose.
GRASS = K.ramp('#d8a838')
STRAW = K.ramp('#f0cc70')
ROCK = K.ramp('#a49cbc')
SPOT = '#6a6088'
NOSE = '#e890a0'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1, y0, y1 = 12, 52, 16, 53
    core = K.rect(x0, y0, x1, y1)
    # fringe of rounded blade tips along the top edge (small, so the edge stays straight)
    bw = 3.4 if c.small else 3.0
    tips = [K.thick_path([(bx, y0 + 3), (tx, ty)], bw) for bx, tx, ty in
            ((15, 11.5, 10), (20, 18.5, 7), (25, 24.5, 11), (39, 39.5, 10), (44, 45.5, 6.5), (49, 52.5, 11))]
    top = K.knob('T', 'tri', 32, y0, 0, -1, r=4.6 * k)
    bot = K.knob('T', 'tri', 32, y1, 0, 1, r=4.3 * k)
    lb = K.knob('B', 'tri', x0, 44, -1, 0, r=3.6 * k)
    rb = K.knob('B', 'tri', x1, 44, 1, 0, r=3.6 * k)
    blanks = (lb, rb)
    body = c.m(core, top, *tips, minus=blanks)
    c.add(body, GRASS, stitch=None if c.small else '#a87a20')
    # lighter straw blades (vertical streaks)
    w = 2.8 if c.small else 2.2
    for pts in ([(15, 14), (17, 26), (18, 38)], [(26, 14), (25, 22)], [(32, 8), (32, 20)],
                [(38, 14), (39, 22)], [(49, 14), (47, 26), (46, 38)]):
        c.add(c.m(K.thick_path(pts, w), minus=blanks) & body, STRAW)
    for gx in (22.5, 28, 36, 41.5, 46.5):
        c.add(c.m(K.thick_path([(gx, y0 - 1), (gx, y0 + 4)], 1.4 if not c.small else 1.8)) & body, GRASS[1:2] * 3)
    # rock base with leopard rosettes
    rock = c.m(K.rect(x0, 37, x1, y1), bot, minus=blanks)
    c.add(rock, ROCK)
    c.edge(rock, K.ramp('#a49cbc')[1])
    for (sx, sy) in ((19, 41), (27, 48), (37, 42), (45, 49), (32, 56), (22, 50)):
        px, py = c.P(sx, sy)
        if c.small:
            c.px(px, py, SPOT); c.px(px + 1, py, SPOT)
        else:
            for d in ((0, 0), (1, 0), (2, 0), (0, 1), (2, 1), (0, 2), (1, 2), (2, 2)):
                c.px(px + d[0] - 1, py + d[1] - 1, SPOT)
    # face on the grass
    c.eye(26, 27)
    c.eye(38, 27)
    c.blush(21, 31); c.blush(42, 31)
    nx, ny = c.P(32, 30)
    c.px(nx, ny, NOSE)
    if not c.small:
        c.px(nx - 1, ny, NOSE)
    c.smile(32, 32)
    # whiskers: dark blade-lines fanning out of the cheeks
    if not c.small:
        c.line([(22, 31), (14, 29)], '#a87a20')
        c.line([(42, 31), (50, 29)], '#a87a20')


K.render_pal(fn, 'pl-sll-3', 'Ichu Whisker', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sll-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sll-3.png')
