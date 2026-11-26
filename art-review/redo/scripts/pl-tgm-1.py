"""pl-tgm-1 Tiger Dust: corner-TB, hook. A fuzzy tiger-moth chick whose spread wings ARE a corner piece: flat W and S sides,
hook tab N = its fuzzy tan head with a curled antenna, hook blank E bites into the wing. Brown/cream striped forewings,
red hindwings with cream border + blue eyespots, mossy teal sill (cell 1-4: teal, moss pillar, red wing with cream edge)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path

BROWN = K.ramp('#6a3a22')
STRIPE = K.ramp('#efe0bc')
RED = K.ramp('#d03a2a')
ORANGE = K.ramp('#e8782a')
CREAMR = K.ramp('#f4d79a')
TAN = K.ramp('#d8a46a')
BLUE = '#4a8ed8'
MOSS = K.ramp('#2f7a5a')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = rect(9, 17, 55, 57)
    tabN = knob('T', 'hook', 32, 17, 0, -1, r=6.0 * s, nw=3.4)
    blankE = knob('B', 'hook', 55, 35, 1, 0, r=4.6 * s)
    headE = ell(32, 9.5, 7.2 if not c.small else 7.8, 6.4 if not c.small else 7.0)
    antL = thick_path([(28, 5), (25, 1.5), (21, 1.2), (20, 3.5)], 2.6 if not c.small else 3.4)
    antR = thick_path([(36, 5), (39, 1.5), (43, 1.2), (44, 3.5)], 2.6 if not c.small else 3.4)
    body = c.m(core, tabN, headE, minus=(blankE,))
    sil = body
    # forewings (upper band), brown with cream diagonal stripes
    fw = sil & c.m(rect(0, 17, 64, 37))
    c.add(fw, BROWN)
    if True:
        w = 2.4 if not c.small else 3.0
        stripes = c.m(
            thick_path([(11, 21), (27, 31)], w), thick_path([(11, 28), (24, 35)], w),
            thick_path([(53, 21), (37, 31)], w), thick_path([(53, 28), (44, 33)], w))
        c.add(stripes & fw, STRIPE)
    # hindwings (lower band), red with orange flush + cream border
    hw = sil & c.m(rect(0, 37, 64, 51))
    c.add(hw, RED)
    c.add(hw & c.m(ell(32, 37, 15, 6)), ORANGE)
    c.add(sil & c.m(rect(0, 36, 64, 38)), CREAMR)
    # mossy sill at the bottom (the temple pillar / teal ground)
    c.add(sil & c.m(rect(0, 51, 64, 57)), MOSS, stitch=None)
    # fuzzy body down the middle
    c.add(c.m(ell(32, 37, 4.2, 15)), TAN)
    c.edge(c.m(ell(32, 37, 4.2, 15)), TAN[1])
    if not c.small:
        for yy in (30, 35, 40, 45):
            x0, y0 = c.P(30, yy)
            for dx in range(0, 5):
                c.px(x0 + dx, y0, TAN[1])
    # head = the hook tab (tan, fuzzy)
    head = c.m(tabN, headE, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 15, 64, 18)))
    c.add(c.m(antL, antR), BROWN)
    c.add(head, TAN)
    # wing seams: dark V from the body to the corners
    c.line([(29, 20), (11, 36)], BROWN[1]); c.line([(35, 20), (53, 36)], BROWN[1])
    # blue eyespots on the hindwings
    for (x, y) in ((17, 44), (24, 47), (47, 44)):
        cx, cy = c.P(x, y)
        rr = 1 if not c.small else 0
        for dx in range(-rr, rr + 1):
            for dy in range(-rr, rr + 1):
                c.px(cx + dx, cy + dy, BLUE)
        if not c.small:
            c.px(cx - 1, cy - 1, '#a8d0f4')
    # face on the main chest (calm area just under the head)
    c.eye(28.8, 9.5)
    c.eye(35.2, 9.5)
    c.smile(32, 13, K.UMBER) if not c.small else c.px(*c.P(32, 13.5), K.UMBER)
    if not c.small:
        c.blush(26.5, 13)
        c.blush(37.5, 13)
    # orange dust motes on the sill
    for (x, y) in ((14, 54), (21, 53), (44, 54), (50, 53)):
        c.px(*c.P(x, y), ORANGE[2])


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-tgm-1', 'Tiger Dust', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tgm-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tgm-1.png')
    print(rep)
