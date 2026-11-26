"""pl-step-1 Grumpy Mossmask: corner-BB keyhole. A carved sandstone temple-block mask: flat W + S sides (it sits on the terrace),
keyhole blanks N (cut down through its moss cap, a forehead notch) and E (a bite out of its cheek). Green moss cap with the ledge's
gold studs, two leafy ears breaking out at the top corners, deep socketed eyes under heavy grumpy brows, the dark mortar stripe as a frown.
Colours from cell 2-5: sandstone bricks, umber mortar, temple-ledge green, gold studs."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SAND = K.ramp('#b08c6c')
SANDLT = K.ramp('#d4ae88')
MORTAR = '#8a6c5a'
SOCK = K.ramp('#7a5e50')
MOSS = ('#52a07c', '#3a7a62', '#7cc89c')
LEAF = ('#3f8a64', '#2c5a4c', '#7cc89c')
GOLD = ('#e0aa2c', '#b07a10', '#f5cf6a')
DARK = ('#2b1c26', '#2b1c26', '#5e4a48')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 17, 54, 57)
    blankN = K.knob('B', 'keyhole', 30, 17, 0, -1, r=3.4 * k, nw=2.0)
    blankE = K.knob('B', 'keyhole', 54, 45, 1, 0, r=3.6 * k, nw=2.2)
    cut = (blankN, blankE)
    leafL = K.poly([(17, 22), (9, 23), (3, 19), (1, 12), (4, 8), (10, 8), (15, 12), (18, 18)])
    leafR = K.poly([(47, 22), (55, 23), (61, 19), (63, 12), (60, 8), (54, 8), (49, 12), (46, 18)])
    body = c.m(core, minus=cut)
    c.add(body, SAND, stitch=None if c.small else '#d4ae88')
    c.add(c.m(leafL, leafR, minus=cut + (core,)), LEAF)
    # brick courses (64 px only)
    if not c.small:
        for yy in (29, 41, 52):
            y = c.P(0, yy)[1]
            for x in range(c.P(10, 0)[0], c.P(54, 0)[0]):
                if (x, y) in body:
                    c.px(x, y, MORTAR)
    # light sandstone step at the bottom
    c.add(body & c.m(K.rect(0, 52.5, 64, 64)), SANDLT)
    # moss cap with drooping tufts and gold studs
    cap = body & c.m(lambda x, y: y < 22.5 + (2.2 if int(x // 4) % 3 == 0 else 0))
    c.add(cap, MOSS)
    if not c.small:
        c.line([(11, 18.5), (53, 18.5)], MOSS[2])
        for gx in (16, 40, 48):
            x, y = c.P(gx, 20)
            for dx in (0, 1):
                for dy in (0, 1):
                    c.px(x + dx, y + dy, GOLD[0])
            c.px(x, y, GOLD[2])
    else:
        for gx in (16, 44):
            x, y = c.P(gx, 20)
            c.px(x, y, GOLD[0])
    # leaf midribs
    if not c.small:
        c.line([(15, 19), (10, 15), (4, 10)], LEAF[1])
        c.line([(49, 19), (54, 15), (60, 10)], LEAF[1])
    # deep eye sockets
    socks = c.m(K.ell(21.5, 34, 6, 5.2), K.ell(38.5, 34, 6, 5.2))
    c.add(socks & body, SOCK)
    # heavy grumpy brows (slant down to the middle)
    bw = 2.6 if not c.small else 3.0
    c.add(c.m(K.thick_path([(15, 27.5), (26, 30.5)], bw), K.thick_path([(45, 27.5), (34, 30.5)], bw)), DARK)
    c.eye(21.5, 35, disc=True)
    c.eye(38.5, 35, disc=True)
    c.blush(15.5, 41)
    c.blush(44, 41)
    # frown: the dark mortar stripe of the cell
    mw = 2.6 if not c.small else 3.0
    c.add(c.m(K.thick_path([(22, 48.5), (25, 45.5), (35, 45.5), (38, 48.5)], mw)), DARK)


K.render_pal(fn, 'pl-step-1', 'Grumpy Mossmask', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-step-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-step-1.png')
