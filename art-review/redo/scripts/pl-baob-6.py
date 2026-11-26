# pl-baob-6 "Baobab Innkeeper": a baobab inn that is a whimsy piece. Bottle trunk = square-ish core with a peg blank cut in
# the left flank and a peg tab on the right flank painted as a glowing lantern; flat green baobab canopy on top with a peg tab
# tuft; arched glowing yellow door at the foot. Colours from cell 6-3 / picture: tan-peach bark with plum streaks, amber window.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROOT = '/home/user/gnome-venture'
BARK = K.ramp('#cf8f62')
STREAK = '#8a4a52'
LEAF = K.ramp('#4f9a48')
LEAF2 = K.ramp('#7cbe55')
DOOR = K.ramp('#ffd060')
LAMP = K.ramp('#fba947')
STEP = K.ramp('#a8693a')


def fn(c):
    k = 1.15 if c.small else 1.0
    # trunk: bottle shape, flat bottom, straight-ish sides between knobs
    trunk = K.poly([(20, 20), (44, 20), (47, 30), (49, 44), (50, 57), (14, 57), (15, 44), (17, 30)])
    tab_r = K.knob('T', 'peg', 48.5, 40, 1, 0, r=4.8 * k)
    blank_l = K.knob('B', 'peg', 15.5, 40, -1, 0, r=4.8 * k)
    canopy = [K.ell(13, 16, 11, 5), K.ell(51, 16, 11, 5), K.ell(32, 9, 14, 5.5)]
    tuft = K.knob('T', 'peg', 32, 4, 0, -1, r=3.6 * k)
    bw = 3.4 if c.small else 3.0
    branches = [K.thick_path([(25, 22), (19, 17), (13, 16)], bw), K.thick_path([(39, 22), (45, 17), (51, 16)], bw),
                K.thick_path([(29, 22), (30, 10)], bw), K.thick_path([(35, 22), (34, 10)], bw)]
    c.add(c.m(*branches), BARK)
    c.add(c.m(trunk, minus=(blank_l,)), BARK, stitch=None)
    c.add(c.m(tab_r), LAMP)
    can = c.m(*canopy, tuft)
    c.add(can, LEAF)
    c.add(c.m(K.ell(11, 14.5, 7, 2.6), K.ell(49, 14.5, 7, 2.6), K.ell(30, 7, 9, 2.8), tuft), LEAF2)
    c.edge(can, LEAF[1])
    # door + step
    door = c.m(K.rect(26, 46, 38, 57), K.ell(32, 46, 6, 5))
    c.add(door, DOOR)
    c.edge(door, '#b07a10')
    c.add(c.m(K.rect(24, 56, 40, 59.5)), STEP)
    # bark streaks (plum) and door planks
    w = 1.6 if c.small else 1.0
    if not c.small:
        c.line([(21, 25), (20, 33), (21, 38)], STREAK)
        c.line([(43, 24), (44, 32)], STREAK)
        c.line([(42, 46), (44, 54)], STREAK)
        c.line([(20, 48), (19, 54)], STREAK)
        c.line([(30, 45), (30, 55)], '#e8a830')
        c.line([(34, 45), (34, 55)], '#e8a830')
    else:
        c.line([(21, 26), (21, 34)], STREAK)
        c.line([(44, 26), (44, 32)], STREAK)
    # lantern detail on the right tab: bright core
    lx, ly = c.P(55.5, 40)
    for dx in ((0, 1) if not c.small else (0,)):
        for dy in ((-1, 0, 1) if not c.small else (-1, 0)):
            c.px(lx + dx, ly + dy, '#fff8d6')
    # face
    c.eye(26, 32)
    c.eye(38, 32)
    c.blush(23, 37)
    c.blush(41, 37) if not c.small else c.blush(40, 37)
    c.smile(32, 37)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-baob-6', 'Baobab Innkeeper', ROOT + '/art-review/redo/out',
                       cellfile=ROOT + '/art-review/redo/_src/pl-baob-6-cell.png',
                       oldfile=ROOT + '/game/assets/img/puzzles/pals/pl-baob-6.png'))
