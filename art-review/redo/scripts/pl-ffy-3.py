import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

# Lake Twinkle: a firefly reflection in the cave lake. inner-TBTB, peg: tabs L/R = glassy wings, blanks top/bottom.
LAKE = K.ramp('#2d5a84')
DEEP = K.ramp('#1f3e66')
RIP = K.ramp('#6a9ad0')
WING = K.ramp('#c9dcf0')
GLOW = K.ramp('#8ccc2a')
YEL = K.ramp('#f0f080')
TIP = K.ramp('#e8f060')

def fn(c):
    k = 1.15 if c.small else 1.0
    r = 4.6 * k
    rb = 3.4 * k
    core = K.rect(13, 14, 51, 56)
    wl = K.knob('T', 'peg', 13, 30, -1, 0, r=r)
    wr = K.knob('T', 'peg', 51, 30, 1, 0, r=r)
    bt = K.knob('B', 'peg', 32, 14, 0, -1, r=rb, nw=2.2)
    bb = K.knob('B', 'peg', 32, 56, 0, 1, r=rb, nw=2.2)
    w = 3.2 if c.small else 2.8
    antL = K.thick_path([(22, 15), (20, 9), (16, 5)], w)
    antR = K.thick_path([(42, 15), (44, 9), (48, 5)], w)
    tipL = K.ell(16, 5, 3, 3)
    tipR = K.ell(48, 5, 3, 3)
    blanks = (bt, bb)
    body = c.m(core, minus=blanks)
    c.add(c.m(antL, antR), DEEP)
    c.add(c.m(tipL, tipR), TIP)
    c.add(body, LAKE, stitch=RIP[2])
    c.add(c.m(wl, wr), WING)
    # lantern belly in the lower part (glowing)
    belly = c.m(K.ell(32, 42, 16, 11), minus=blanks + (K.rect(0, 0, 64, 35),))
    c.add(belly, GLOW)
    c.add(c.m(K.ell(32, 42, 9, 4.5), minus=blanks), YEL)
    # ripple streaks across the upper half (lake reflection lines from the cell)
    for (x0, x1, y) in ((15, 27, 19), (36, 47, 22), (15, 21, 34), (44, 50, 35)):
        c.line([(x0, y), (x1, y)], RIP[2] if not c.small else RIP[2])
        if c.small:
            pass
    # belly ripple bands
    c.line([(20, 49), (44, 49)], GLOW[2])
    c.line([(25, 52), (39, 52)], GLOW[2])
    c.eye(26, 26, disc=True)
    c.eye(38, 26, disc=True)
    c.blush(21, 31) ; c.blush(42, 31)
    c.smile(32, 31, col=K.UMBER)

K.render_pal(fn, 'pl-ffy-3', 'Lake Twinkle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-ffy-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ffy-3.png')
