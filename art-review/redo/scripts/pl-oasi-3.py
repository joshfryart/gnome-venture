# pl-oasi-3 "Plum Window Blink": a sandstone wall block that IS an inner-TBTB keyhole piece, with an arched plum window
# (the creature's face) peeking out. Tabs W/E (wall stones), keyhole blanks N/S (keystone notch above the arch, drain below the sill).
# Colours: sandstone peach/orange and plum of the turtle-shell scutes, teal ring for the window frame, olive cobble (cell 1-5).
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

SAND = K.ramp('#eaa868')
SAND2 = K.ramp('#d88a4c')
TEAL = K.ramp('#6fae94')
PLUM = K.ramp('#5c3658')
PLUMRING = K.ramp('#8c5a84')
COB = K.ramp('#9a9668')
SILL = K.ramp('#f2c890')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 10, 54, 54)
    tW = K.knob('T', 'keyhole', 10, 32, -1, 0, r=3.8 * k)
    tE = K.knob('T', 'keyhole', 54, 32, 1, 0, r=3.8 * k)
    bN = K.knob('B', 'keyhole', 32, 10, 0, -1, r=3.0 * k)
    bS = K.knob('B', 'keyhole', 32, 54, 0, 1, r=3.0 * k)
    body = c.m(core, tW, tE, minus=(bN, bS))
    c.add(body, SAND, stitch=None if c.small else SAND[1])
    # olive cobble stones on the tabs
    c.add(c.m(tW, minus=(core,)) | (body & c.m(K.rect(0, 0, 13, 64), K.ell(10, 32, 4, 6))), COB)
    c.add(c.m(tE, minus=(core,)) | (body & c.m(K.rect(51, 0, 64, 64), K.ell(54, 32, 4, 6))), COB)
    # stone course lines on the wall
    if not c.small:
        for y in (21, 43):
            c.line([(13, y), (19, y)], SAND[1]); c.line([(45, y), (51, y)], SAND[1])
        c.line([(16, 13), (16, 21)], SAND[1]); c.line([(48, 43), (48, 51)], SAND[1])
    for (cx, cy) in ((10, 10), (54, 10), (10, 54), (54, 54)):
        ring = c.m(lambda x, y, cx=cx, cy=cy: 7.5 ** 2 < (x - cx) ** 2 + (y - cy) ** 2 < 10.5 ** 2) & body
        c.add(ring, SAND2)
    # window: teal ring frame, plum glass in concentric rings (the shell's scute motif)
    arch = lambda rx, top, bot: (lambda x, y: (abs(x - 32) < rx and top + rx <= y < bot) or ((x - 32) ** 2 + (y - top - rx) ** 2 < rx * rx))
    frame = c.m(arch(12, 20.5, 45), minus=(bN,))
    c.add(frame & body, TEAL)
    c.edge(frame & body, TEAL[1])
    c.add(c.m(arch(9.5, 23, 44)), PLUMRING)
    c.add(c.m(arch(7.5, 25.5, 44)), PLUM)
    # sill
    c.add(body & c.m(K.rect(17, 43, 47, 47.5)), SILL)
    c.edge(body & c.m(K.rect(17, 43, 47, 47.5)), SAND2[1])
    # face in the window: one open felt eye, one blinking
    ex = 27 if c.small else 28
    c.eye(ex, 34 if c.small else 35, disc=True)
    bx, by = c.P(37 if c.small else 36, 35)
    if c.small:
        for dx in range(-1, 3):
            c.px(bx + dx, by + (1 if dx in (0, 1) else 0), '#f2e4c0')
    else:
        for dx in range(-2, 3):
            c.px(bx + dx, by + (1 if abs(dx) < 2 else 0), '#f2e4c0')
    if not c.small:
        c.blush(24, 39); c.blush(39, 39)
        c.smile(32, 40, '#f2e4c0')
    else:
        c.smile(31, 40.5, '#f2e4c0')


K.render_pal(fn, 'pl-oasi-3', 'Plum Window Blink', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-oasi-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-oasi-3.png')
