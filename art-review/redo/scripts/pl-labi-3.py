import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

# Concept: a hedge-maze gate. Two hedge gateposts + hedge lintel form the square body; E and W keyhole tabs are the two orange
# lamps hanging out on iron brackets; the S keyhole blank is the arched entrance cut into the sand path; the N keyhole blank is
# a notch in the hedge crown. Sand path and hedge greens from cell 5-7, lamp orange from the picture's beacon flame.

SAND = K.ramp('#f4dc9c')
PATH = ('#d8b078', '#b08a58', '#ecd29c')
HEDGE = ('#58b048', '#2e7a44', '#7cc858')
LEAF = '#bef06a'
DEEP = '#1a4a38'
LAMP = K.ramp('#f09028')
IRON = K.ramp('#6a4a3c')
GLOW = '#fff0a0'
CAP = K.ramp('#d8b078')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 13, 52, 55)
    tabW = K.knob('T', 'keyhole', 12, 30, -1, 0, r=6.0 * k)
    tabE = K.knob('T', 'keyhole', 52, 30, 1, 0, r=6.0 * k)
    blankN = K.knob('B', 'keyhole', 32, 13, 0, -1, r=2.6 * k, nw=2.0)
    blankS = K.knob('B', 'keyhole', 32, 55, 0, 1, r=4.4 * k)
    body = c.m(core, tabW, tabE, minus=(blankN, blankS))
    # hedge: whole body first
    c.add(body & c.m(core), HEDGE, stitch=None)
    # sand path running through the gate opening
    opening = c.m(K.rect(22, 26, 42, 55)) & body
    c.add(opening, SAND)
    c.edge(opening, PATH[1])
    # stone caps on top of the two posts
    c.add(body & c.m(K.rect(12, 13, 21, 17)), CAP)
    c.add(body & c.m(K.rect(43, 13, 52, 17)), CAP)
    # lamps: bracket (flare part) in iron, globe in orange
    for tab, sx in ((tabW, -1), (tabE, 1)):
        t = c.m(tab, minus=(core,))
        bx = 12 if sx < 0 else 52
        bracket = t & c.m(K.rect(bx - 3.6, 0, bx, 64) if sx < 0 else K.rect(bx, 0, bx + 3.6, 64))
        globe = t - bracket
        c.add(bracket, IRON)
        c.add(globe, LAMP)
        cap = globe & c.m(K.rect(0, 0, 64, 26.2))
        c.add(cap, IRON)
        gx = 5.5 if sx < 0 else 58.5
        x, y = c.P(gx, 30.5)
        c.px(x, y, GLOW)
        if not c.small:
            c.px(x, y + 1, GLOW)
            c.px(x - 1, y, GLOW)
            c.px(x - 1, y + 1, GLOW)
            c.px(x + sx, y, LAMP[2])
            c.px(x, y - 1, LAMP[2])
    # hedge texture: leaf flecks and dark sprigs on hedge parts only
    hedge_px = (body & c.m(core)) - opening
    for (x, y) in hedge_px:
        if (x * 3 + y * 5) % 11 == 0:
            c.px(x, y, LEAF if (x + y) % 2 else HEDGE[2])
        elif (x * 7 + y * 3) % 13 == 0 and not c.small:
            c.px(x, y, DEEP)
    # path pebbles
    if not c.small:
        for (x, y) in opening:
            if (x * 5 + y * 7) % 17 == 0:
                c.px(x, y, PATH[0])
    # gate shadow at lintel underside
    for (x, y) in opening:
        if (x, y - 1) not in opening and (x, y - 1) in hedge_px:
            c.px(x, y, PATH[1])
    # face in the doorway
    c.eye(27.5, 32)
    c.eye(36.5, 32)
    c.blush(25, 37)
    c.blush(38, 37)
    c.smile(32, 36.5)


K.render_pal(fn, 'pl-labi-3', 'Gatepost Lampshine', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-labi-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-labi-3.png')
