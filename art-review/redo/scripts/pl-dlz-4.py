#!/usr/bin/env python3
"""pl-dlz-4 "Diamond Spur": inner-TTTT, hook. The piece IS a dragon-lizard head: square core = head, a toothy grin across
(the cell's dark mouth, pink gums and cream teeth), green scaled crown above, pale yellow jaw scales below.
Hook tabs: N and E = curled tan horns (the picture's horns), W = snout with a nostril, S = a curled chin spur."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import math
import pal_kit as K

GREEN = K.ramp('#5a9e3c')
DKG = '#2e6242'
JAW = K.ramp('#e4dc8c')
CRACK = '#9a8f62'
GUM = K.ramp('#c8586a')
MOUTH = ('#3a1424', '#2b1c26', '#3e2a44')
TOOTH = '#fff1cf'
HORN = K.ramp('#e2b878')
EYE = '#f0b020'


def fn(c):
    k = 1.2 if c.small else 1.0
    x0, y0, x1, y1 = 13, 13, 51, 51
    core = K.rect(x0, y0, x1, y1)
    tN = K.knob('T', 'hook', 30, y0, 0, -1, r=6.4 * k, nw=3.0)
    tE = K.knob('T', 'hook', x1, 25, 1, 0, r=6.0 * k, nw=3.0)
    tW = K.knob('T', 'round', x0, 36.5, -1, 0, r=5.6 * k, nw=4.2)
    tS = K.knob('T', 'hook', 32, y1, 0, 1, r=5.4 * k, nw=3.0)
    if c.small:   # 36 px: the kit's hook ring is under 2 px thick and breaks, so redraw each hook as a thicker open curl
        def curl(mx, my, nx, ny, r):
            cc = r + 1.6
            cx, cy = mx + nx * cc, my + ny * cc
            ax, ay = -ny, nx
            pts = [(mx, my)]
            for d in range(-150, 151, 25):   # open on the +u, near side, like the kit's hook
                a = math.radians(d + 90)
                u, v = math.cos(a) * (r - 1.2), math.sin(a) * (r - 1.2)
                pts.append((cx + ax * u - nx * v, cy + ay * u - ny * v))
            return K.thick_path(pts, 3.6)
        tN = curl(30, y0, 0, -1, 6.4 * k)
        tE = curl(x1, 25, 1, 0, 6.0 * k)
        tS = curl(32, y1, 0, 1, 5.4 * k)
    head = c.m(core)
    c.add(head, GREEN)
    # snout (W) green, chin spur (S) jaw colour, horns tan
    c.add(c.m(tW, minus=(core,)), GREEN)
    c.add(c.m(tN, minus=(core,)), HORN)
    c.add(c.m(tE, minus=(core,)), HORN)
    # lower jaw
    jaw = c.m(K.rect(x0, 40, x1, y1))
    c.add(jaw, JAW)
    c.add(c.m(tS, minus=(core,)), JAW)
    c.add(c.m(tW, minus=(core,)) & c.m(K.rect(0, 38, 64, 64)), JAW)
    c.add(c.m(tW, minus=(core,)) & c.m(K.rect(0, 36, 64, 38.5)), MOUTH)
    # mouth: dark gap, pink gums, cream teeth zigzag (the cell's diamond pattern)
    c.add(c.m(K.rect(x0, 33, x1, 40)), GUM)
    c.add(c.m(K.rect(x0, 36, x1, 38.5)), MOUTH)
    tw = 4.75 if not c.small else 6.333
    for i in range(8 if not c.small else 6):
        cx = x0 + tw * (i + 0.5)
        c.add(c.m(K.poly([(cx - tw * 0.42, 33), (cx + tw * 0.42, 33), (cx, 36.8)])), (TOOTH, TOOTH, TOOTH))
        cx2 = x0 + tw * (i + 1.0)
        if cx2 < x1 - 1:
            c.add(c.m(K.poly([(cx2 - tw * 0.42, 40), (cx2 + tw * 0.42, 40), (cx2, 37.6)])), (TOOTH, TOOTH, TOOTH))
    # scales on the crown and jaw
    if not c.small:
        for (x, y) in head:
            if 16 < y < 31 and (x + 2 * (y // 3 % 2)) % 4 == 0 and y % 3 == 0:
                c.px(x, y, DKG)
            if 43 < y < 50 and (x + 2 * (y // 3 % 2)) % 5 == 0 and y % 3 == 1:
                c.px(x, y, CRACK)
    else:
        for (x, y) in head:
            if 10 < y < 17 and (x + 2 * (y // 2 % 2)) % 4 == 0 and y % 2 == 0:
                c.px(x, y, DKG)
    # nostril on the snout
    nx, ny = c.P(4.5, 32)
    c.px(nx, ny, DKG)
    if not c.small:
        c.px(nx + 1, ny, DKG)
    # brow ridge + big yellow eye (felt pupil)
    ex, ey = 36, 24
    c.add(c.m(K.ell(ex, ey + 0.5, 6.2 if not c.small else 6.8, 5.2 if not c.small else 5.8)), (EYE, '#c07a10', '#f8d060'))
    c.line([(ex - 7, ey - 7), (ex + 6, ey - 7.5)], '#7fc05a' if not c.small else DKG)
    c.eye(ex, ey + 1)
    c.blush(22, 30)


K.render_pal(fn, 'pl-dlz-4', 'Diamond Spur', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-dlz-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-dlz-4.png')
