"""pl-bvd-3 Tunnel Trickle: inner-TBTB, tri. A pond-water drop that is an inner piece: N tri tab = the drop's tip, S tri tab = a drip
falling off its round bottom, tri blanks bite into E and W. A tan beaver-dam log (cell 2-7: log with dark ring end) runs across its belly,
the tunnel it trickles through. Pond blues + log tans from the cell."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

WATER = K.ramp('#2f6aa0')
DEEP = K.ramp('#245a88')
LOG = ('#d8a060', '#946040', '#ecc48a')
LOGEND = ('#b68050', '#5c3c3c', '#d8a060')
SHINE = '#e8f2fa'
RIP = '#8ec0e4'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(12, 31), (23, 19), (41, 19), (52, 31), (52, 50), (12, 50)])
    bottom = K.ell(32, 49, 20, 8.5)
    tabN = K.knob('T', 'tri', 32, 19.5, 0, -1, r=5.0 * k)
    tabS = K.knob('T', 'tri', 32, 57, 0, 1, r=4.2 * k)
    blE = K.knob('B', 'tri', 52, 36.5, 1, 0, r=5.0 * k)
    blW = K.knob('B', 'tri', 12, 36.5, -1, 0, r=5.0 * k)
    cut = (blE, blW)
    body = c.m(core, bottom, tabN, tabS, minus=cut)
    c.add(body, WATER)
    # deeper water at the bottom and the drip
    c.add(body & c.m(K.rect(0, 53, 64, 64)), DEEP)
    # the log the trickle runs through
    logm = c.m(K.rect(10, 44.5, 54, 52), minus=cut) & c.m(core, bottom)
    c.add(logm, LOG)
    endm = c.m(K.ell(15, 48.2, 3.6, 4.0)) & logm
    c.add(endm, LOGEND)
    c.edge(endm, '#5c3c3c')
    ex, ey = c.P(15, 48.2)
    c.px(ex, ey, '#5c3c3c')
    # grain lines on the log
    if not c.small:
        for (x0, x1, y) in ((22, 34, 46.5), (36, 49, 49.5), (25, 31, 50.5)):
            c.line([(x0, y), (x1, y)], '#946040')
    else:
        c.line([(24, 48.5), (46, 48.5)], '#946040')
    # shine on the drop (upper left) and ripples
    if not c.small:
        c.line([(17, 29), (21, 24), (25, 21)], SHINE)
        c.line([(17, 31), (20, 27)], SHINE)
        c.px(*c.P(29, 12), SHINE)
        c.px(*c.P(30, 14), SHINE)
        for (x0, y0) in ((38, 41), (24, 56)):
            for i in range(6):
                c.px(c.P(x0, 0)[0] + i, c.P(0, y0)[1] + (i // 2) % 2, RIP)
    else:
        c.line([(17, 29), (23, 22)], SHINE)
        c.px(*c.P(30, 13), SHINE)
    # face
    c.eye(27, 31, disc=True)
    c.eye(37.5, 31, disc=True)
    c.smile(32, 37, '#2a1a10')
    c.blush(24, 37)
    c.blush(40, 37)


K.render_pal(fn, 'pl-bvd-3', 'Tunnel Trickle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-bvd-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-bvd-3.png')
