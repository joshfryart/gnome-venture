# Arch Parade: inner-TTTT round piece = a cream monastery wall section; top tab is a terracotta bell-cap, eave band on top,
# three glowing amber arched windows singing shoulder to shoulder (colours from the lit cream wall + amber arches of the cell).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

WALL = K.ramp('#f2dcae')
PLAST = K.ramp('#e2bf88')
ROOF = K.ramp('#c8603a')
GLOW = K.ramp('#f2b040')
FRAME = '#7a4a28'
GLOWL = '#fbe08a'


def fn(c):
    s = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 11, 13, 53, 52
    core = K.rect(x0, y0, x1, y1)
    mx, my = (x0 + x1) / 2, (y0 + y1) / 2
    top = K.knob('T', 'round', mx, y0, 0, -1, r=5.0 * s)
    bot = K.knob('T', 'round', mx, y1, 0, 1, r=5.0 * s)
    lft = K.knob('T', 'round', x0, my + 2, -1, 0, r=5.0 * s)
    rgt = K.knob('T', 'round', x1, my + 2, 1, 0, r=5.0 * s)
    c.add(c.m(core, bot, lft, rgt), WALL, stitch=PLAST[1])
    # plaster patches lower corners (the weathered wall)
    c.add(c.m(K.ell(14, 51, 6, 4), K.ell(51, 50, 5, 4), minus=(lambda x, y: not core(x, y),)), PLAST)
    # roof eave band + bell cap tab
    eave = c.m(K.rect(x0, y0, x1, y0 + 6), top)
    c.add(eave, ROOF)
    c.edge(eave, ROOF[1])
    # three arched windows, middle one taller
    wins = [(19.5, 11, 25), (32, 12, 22), (44.5, 11, 25)]
    for cx, w, ytop in wins:
        h = 47
        if c.small:
            ytop = ytop - 1
        win = c.m(K.rect(cx - w / 2, ytop + w / 2, cx + w / 2, h), K.ell(cx, ytop + w / 2, w / 2, w / 2))
        c.add(win, GLOW)
        c.edge(win, FRAME)
        # mullion cross on 64 only
        if not c.small:
            c.line([(cx, ytop + w / 2 + 6), (cx, ytop + w / 2 + 6)], GLOWL)
        # face: eyes + singing O mouth
        ey = ytop + w / 2 + 2
        c.eye(cx - 2.4, ey, disc=not c.small)
        c.eye(cx + 2.6, ey, disc=not c.small)
        mxp, myp = c.P(cx, ey + 6)
        if c.small:
            c.px(mxp, myp, K.UMBER); c.px(mxp + 1, myp, K.UMBER)
            c.px(mxp, myp + 1, K.UMBER); c.px(mxp + 1, myp + 1, K.UMBER)
        else:
            for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 1), (-1, 1), (1, -1), (-1, -1), (1, 1)):
                c.px(mxp + dx, myp + dy, K.UMBER)
            c.px(mxp, myp, '#a8301a')
    # sill line
    c.add(c.m(K.rect(13, 47, 51, 49.5)), PLAST)


K.render_pal(fn, 'pl-lemn-4', 'Arch Parade', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-lemn-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-lemn-4.png')
