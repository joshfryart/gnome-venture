# Concept: a great white owl's plume (whimsy-feather): a broad lavender-white vane with straight-ish puzzle sides,
# hook TAB on the right edge, hook BLANK cut into the left edge (reads as the natural split in a feather's vane),
# a cream rachis down the middle ending in a hollow-brown quill, and the owl's glowing yellow eye (cell 6-3) on the vane.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

VANE = K.ramp('#dcd8ee')
BARB = '#aaa6d0'
SHADOW = K.ramp('#9c98c4')
QUILL = K.ramp('#6e3a36')
RACH = K.ramp('#f4f0e4')
EYE = K.ramp('#f8d040')
GLOW = '#fff4b0'
NAVY = '#4a4c80'
AUR1 = K.ramp('#f6e6a0')
AUR2 = K.ramp('#f8d040')


def fn(c):
    k = 1.15 if c.small else 1.0
    # vane: long feather with a pointed, slightly curled tip; straight-ish sides carry the knobs
    vane = K.poly([(17, 48), (16, 24), (19, 15), (26, 8), (34, 3), (41, 1), (44, 6), (47, 15), (47, 44), (42, 51), (34, 54), (24, 54)])
    split = K.poly([(47, 45), (40, 47), (46, 49)])          # the natural split in a feather's vane
    tabE = K.knob('T', 'hook', 47, 30, 1, 0, r=(5.0 if not c.small else 5.8))
    blankW = K.knob('B', 'hook', 16, 40, -1, 0, r=(4.6 if not c.small else 5.6), flip=True)
    body = c.m(vane, tabE, minus=(blankW, split))
    c.add(body, VANE)
    # aurora tip (the blurb): yellow glow fading into lavender, from the owl's eye colour
    c.add(body & c.m(lambda x, y: y < 12 - 0.25 * (x - 30)), AUR1)
    c.add(body & c.m(lambda x, y: y < 7 - 0.25 * (x - 30)), AUR2)
    # downy base in deeper lavender
    c.add(body & c.m(lambda x, y: y > 46 + 0.15 * (x - 30)), SHADOW)
    # quill
    c.add(c.m(K.thick_path([(31, 52), (30, 58), (26, 63)], 3.6 if not c.small else 4.4)), QUILL)
    # barbs: chevrons off the rachis on both sides
    rx = lambda y: 33 - (y - 6) * 0.04
    ys = (14, 21, 40, 47) if not c.small else (16, 44)
    for y0 in ys:
        c.line([(rx(y0), y0 + 3), (19, y0 - 4)], BARB)
        c.line([(rx(y0), y0 + 3), (46, y0 - 4)], BARB)
    # rachis
    rach = c.m(K.thick_path([(36, 5), (33, 20), (31, 52)], 2.0 if not c.small else 2.8))
    for p in rach:
        if p in body:
            c.px(p[0], p[1], RACH[2] if p[1] < c.P(0, 46)[1] else RACH[1])
    # two glowing owl eyes (cell 6-3) on the widest part of the vane
    for ex in (25, 40):
        ey = 29
        rr = 5.2 if not c.small else 5.6
        c.add(c.m(K.ell(ex, ey, rr, rr)), EYE)
        ecx, ecy = c.P(ex, ey)
        if not c.small:
            for dy in range(-2, 2):
                c.px(ecx, ecy + dy, K.UMBER)
                c.px(ecx - 1, ecy + dy, K.UMBER)
            c.px(ecx - 1, ecy - 2, '#ffffff')
        else:
            for dy in range(-1, 1):
                c.px(ecx, ecy + dy, K.UMBER)
            c.px(ecx - 1, ecy - 1, '#ffffff')
    # brows (owl tufts) in navy lavender
    c.line([(20, 22), (25, 23), (29, 25)], NAVY)
    c.line([(36, 25), (40, 23), (45, 22)], NAVY)
    # tiny beak between the eyes
    bx, by = c.P(32.5, 33)
    c.px(bx, by, '#e8a020'); c.px(bx - 1, by, '#e8a020')
    if not c.small:
        c.px(bx, by + 1, '#c07a10'); c.px(bx - 1, by + 1, '#c07a10')


K.render_pal(fn, 'pl-owl-6', 'Great White Plumelet', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-owl-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-owl-6.png')
