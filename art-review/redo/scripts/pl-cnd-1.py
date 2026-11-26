# Crag Quill: a condor flight feather that is a corner piece. Flat top + left (square corner top-left),
# hook blank cut into the right vane (a feather split), hook tab on the bottom = the bronze quill nib.
# Colours from cell 2-3: condor wing indigo/violet, lavender sky, peach-orange neck accent.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

DARK = K.ramp('#3a2c56')
MID = K.ramp('#786295')
LAV = K.ramp('#9a82bc')
PEACH = K.ramp('#f19c74')
BRONZE = ('#d8903a', '#9a5a1f', '#f5c66a')


def fn(c):
    s = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 8, 6, 54, 46
    core = K.rect(x0, y0, x1, y1)
    # feather tip: big rounded top-right, vane tapering into the quill at the bottom
    tipcut = lambda x, y: x > 34 and y < 26 and (x - 34) ** 2 + (y - 26) ** 2 > 20 ** 2
    blcut = lambda x, y: x < 22 and y > 34 and (x - 22) ** 2 + (y - 34) ** 2 > 12 ** 2
    brcut = lambda x, y: x > 40 and y > 32 and (x - 40) ** 2 + (y - 32) ** 2 > 14 ** 2
    # feather split: a V notch in the right vane edge
    n1 = K.poly([(55, 37), (44, 42), (55, 41)])
    n2 = K.poly([(47, 9), (40, 16), (49, 11)])
    quill = K.poly([(29, 44), (34, 44), (33.6, 52), (29.4, 52)])
    tab = K.knob('T', 'hook', 31.5, 52, 0, 1, r=4.2 * s)
    blank = K.knob('B', 'hook', x1, 25, 1, 0, r=4.0 * s)
    body = c.m(core, quill, tab, minus=(tipcut, blcut, brcut, blank, n1))
    c.add(body, MID, stitch=None)
    # barbs: chevrons rising from the shaft, alternating dark / lavender bands
    w = 3.4 if c.small else 2.6
    ys = (10, 20, 30, 40) if c.small else (8, 14, 20, 26, 32, 38, 44)
    for i, yy in enumerate(ys):
        rp = DARK if i % 2 == 0 else LAV
        c.add(body & c.m(K.thick_path([(10, yy - 8), (31, yy + 4), (56, yy - 10)], w)), rp)
    # rachis (shaft) and the bronze quill nib
    c.add(body & c.m(K.rect(29.8, y0, 33.2 + (0.6 if c.small else 0), 46)), K.ramp('#ead0a3'))
    c.add(body & c.m(K.rect(0, 44, 64, 64)), BRONZE)
    # peach ruff where the vane meets the quill (condor neck colour)
    c.add(body & c.m(ell(31.5, 43, 10, 3.2)), PEACH)
    # face on the right vane
    c.eye(16, 22, disc=True)
    c.eye(24, 23, disc=True)
    c.smile(20, 29, col=K.CREAM)
    c.blush(13, 28)


def ell(cx, cy, rx, ry):
    return K.ell(cx, cy, rx, ry)


K.render_pal(fn, 'pl-cnd-1', 'Crag Quill', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cnd-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cnd-1.png')
