# Candlehead Crab: a square crab-shell piece; keyhole tab = left side, keyhole blank = right side, eye stalks on top between the raised claws;
# two claws raised at the top corners each holding a lit cream candle (the lighthouse lamp); coral lighthouse red, sunset rock belly, violet feet.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#e0605e')
ROCK = K.ramp('#d09a8a')
VIO = K.ramp('#8a4880')
WAX = K.ramp('#e7d5b8')
FLAME = ('#ffcf70', '#ee8a78', '#fffabb')
SAND = '#ffb877'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.poly([(13, 24), (51, 24), (54, 27), (54, 48), (51, 51), (13, 51), (10, 48), (10, 27)])
    tab_l = K.knob('T', 'keyhole', 10, 37, -1, 0, r=4.5 * s)
    blank_r = K.knob('B', 'keyhole', 54, 36, 1, 0, r=4.0 * s)
    # raised arms + pincer claws at top corners
    arm_l = K.thick_path([(15, 27), (13, 20)], 5.5)
    arm_r = K.thick_path([(49, 27), (51, 20)], 5.5)
    claw_l = K.ell(13, 17, 6.5, 5)
    claw_r = K.ell(51, 17, 6.5, 5)
    notch_l = K.poly([(13, 17), (17.5, 10), (21, 13)])
    notch_r = K.poly([(51, 17), (46.5, 10), (43, 13)])
    legs = K.thick_path([(17, 49), (14, 57)], 4.5), K.thick_path([(25, 49), (24, 57)], 4.5), \
        K.thick_path([(39, 49), (40, 57)], 4.5), K.thick_path([(47, 49), (50, 57)], 4.5)

    c.add(c.m(*legs), VIO)
    stalks = c.m(K.rect(23.5, 18, 27, 25), K.rect(37, 18, 40.5, 25))
    c.add(stalks, RED)
    c.add(c.m(K.ell(25.2, 16.5, 4.2, 4.2), K.ell(38.8, 16.5, 4.2, 4.2)), WAX)
    shell = c.add(c.m(core, tab_l, arm_l, arm_r, minus=(blank_r,)), RED, stitch=SAND)
    belly = c.m(K.rect(10, 43, 55, 52), minus=(blank_r,))
    belly &= shell
    c.add(belly, ROCK)
    c.edge(belly, RED[1])
    c.add(c.m(claw_l, claw_r, minus=(notch_l, notch_r)), RED)
    # candles held in the claws
    cw = 3.2 if not c.small else 3.6
    candle_l = c.m(K.rect(13.5 - cw, 6, 13.5 + cw, 13))
    candle_r = c.m(K.rect(50.5 - cw, 6, 50.5 + cw, 13))
    c.add(candle_l | candle_r, WAX)
    c.add(c.m(K.poly([(13.5, 0), (17, 4.5), (13.5, 7), (10, 4.5)]), K.poly([(50.5, 0), (54, 4.5), (50.5, 7), (47, 4.5)])), FLAME)
    for x in (13.5, 50.5):
        px, py = c.P(x, 4.2)
        c.px(px, py, FLAME[2]); c.px(px, py - 1, FLAME[2])
    # wax drips
    for x, y in ((12, 8), (49, 9)):
        px, py = c.P(x, y)
        c.px(px, py, WAX[2]); c.px(px, py + 1, WAX[2])
    # face
    c.eye(25.2, 17)
    c.eye(38.8, 17)
    c.smile(32, 33, wide=True)
    if not c.small:
        c.blush(23, 32); c.blush(40, 32)
    # sunset glint dots on the belly (rock motif)
    if not c.small:
        for x, y in ((18, 47), (30, 48), (42, 46), (36, 49)):
            px, py = c.P(x, y)
            c.px(px, py, VIO[0])


K.render_pal(fn, 'pl-wlig-6', 'Candlehead Crab', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wlig-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wlig-6.png')
