# Lantern Bob (pl-cblo-4), inner-TTTT peg: a round red paper lantern (chochin) whose squircle body is the piece core.
# N peg tab = navy lacquer top cap (roof navy) with hanging loop, S peg tab = bottom cap with a mauve tassel,
# E/W peg tabs = the paper bulging out on the sides. Glowing amber shoji-window centre with dark-red post ribs from cell 6-5.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

RED = K.ramp('#c8342c')
GLOW = K.ramp('#f0a83c')
NAVY = K.ramp('#34407a')
MAUVE = K.ramp('#c08a90')
RIB = '#8a2a26'
POST = '#8e3c3c'


def sq(cx, cy, a, b, p=4):
    return lambda x, y: abs((x - cx) / a) ** p + abs((y - cy) / b) ** p < 1


def fn(c):
    k = 1.15 if c.small else 1.0
    core = sq(32, 33, 19, 17)
    tabN = K.knob('T', 'peg', 32, 16, 0, -1, r=6.4 * k, nw=2.3)
    tabS = K.knob('T', 'peg', 32, 50, 0, 1, r=6.4 * k, nw=2.3)
    tabE = K.knob('T', 'peg', 51, 33, 1, 0, r=5.8 * k, nw=2.2)
    tabW = K.knob('T', 'peg', 13, 33, -1, 0, r=5.8 * k, nw=2.2)
    body = c.m(core, tabE, tabW)
    c.add(body, RED, stitch=None)
    # glow window in the middle of the paper
    glow = c.m(sq(32, 34, 11.5, 10.5, 3))
    c.add(glow, GLOW)
    c.add(glow & c.m(K.rect(0, 0, 64, 28.5)), K.ramp('#fbd77a'))   # pale-yellow top of the shoji pane (cell)
    # caps: navy bands at top and bottom of the barrel plus the peg tabs
    capN = c.m(tabN, rect := K.rect(19, 14, 45, 18.5))
    capS = c.m(tabS, K.rect(19, 47.5, 45, 52))
    c.add(capN, NAVY)
    c.add(capS, NAVY)
    # hanging loop above the top cap
    # tassel below
    pass  # tassel dropped: the S peg cap is the lantern foot
    # ribs: horizontal paper ribs, curved (follow the squircle) - on red only
    for yy in (22.5, 28, 39, 44.5) if not c.small else (24, 42):
        for x in range(c.n):
            p = (x, c.P(0, yy)[1])
            if p in body and p not in glow and p not in capN and p not in capS:
                c.px(p[0], p[1], RIB)
    # shoji post down the middle of the glow (cell's dark red post) + one cross bar
    if not c.small:
        for gx in (25, 39):
            x = c.P(gx, 0)[0]
            for y in range(c.P(0, 24.5)[1], c.P(0, 29)[1]):
                if (x, y) in glow:
                    c.px(x, y, '#c07038')
    # navy cap tops light gold rim (lacquer catching the glow)
    for (x, y) in capN:
        if (x, y + 1) not in capN and (x, y + 1) in body:
            c.px(x, y, '#e8a317')
    for (x, y) in capS:
        if (x, y - 1) not in capS and (x, y - 1) in body:
            c.px(x, y, '#e8a317')
    # face on the glow
    c.eye(27.5, 33)
    c.eye(36.5, 33)
    c.smile(32, 38)
    c.blush(23.5, 37)
    c.blush(40, 37)


K.render_pal(fn, 'pl-cblo-4', 'Lantern Bob', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cblo-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cblo-4.png')
