# pl-oasi-5 "Rimmed Pool Saucer": a round oasis pool sitting in a wooden saucer (the turtle's plank rim, cell 5-6),
# inner-BBBB with double blanks on all four sides; green grass rim, blue pool with a face floating in it, plank seams on the saucer.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, knob, poly, UMBER, UMBER2

WOOD = ('#c8884a', '#a8663e', '#e8b878')   # cell planks
PLUM = K.ramp('#6a3a44')                    # cell dark rim band
GRASS = ('#4aa63c', '#2f7a34', '#8ed05c')   # oasis grass
POOL = ('#2e8fca', '#1f6a9a', '#7bddff')    # oasis water
SAND = '#f0b878'


def rounded(x0, y0, x1, y1, rr):
    return lambda x, y: (rect(x0 + rr, y0, x1 - rr, y1)(x, y) or rect(x0, y0 + rr, x1, y1 - rr)(x, y)
                         or any(ell(cx, cy, rr, rr)(x, y) for cx in (x0 + rr, x1 - rr) for cy in (y0 + rr, y1 - rr)))


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rounded(5, 5, 59, 59, 8)
    r, nw = 3.5 * k, 2.0
    bl = [knob('B', 'double', 32, 5, 0, -1, r=r, nw=nw), knob('B', 'double', 32, 59, 0, 1, r=r, nw=nw),
          knob('B', 'double', 5, 32, -1, 0, r=r, nw=nw), knob('B', 'double', 59, 32, 1, 0, r=r, nw=nw)]
    body = c.m(core, minus=bl)
    c.add(body, WOOD)
    # plank seams radiating on the saucer (cell's dark plank joints)
    seam = PLUM[0]
    for (a, b) in (((18, 6), (18, 13)), ((46, 6), (46, 13)), ((18, 51), (18, 58)), ((46, 51), (46, 58)),
                   ((6, 18), (13, 18)), ((6, 46), (13, 46)), ((51, 18), (58, 18)), ((51, 46), (58, 46))):
        c.line([a, b], seam)
    # green rim and the pool
    rim = c.m(ell(32, 32, 21.5, 21.5), minus=bl) & body
    c.add(rim, GRASS)
    pool = c.m(ell(32, 32.5, 16, 15)) & body
    c.add(pool, POOL)
    c.edge(pool, GRASS[1])
    # sparkle ripples
    if not c.small:
        c.line([(22, 39), (26, 39)], POOL[2])
        c.line([(38, 41), (42, 41)], POOL[2])
        c.line([(24, 26), (27, 26)], '#ffffff')
    else:
        c.line([(22, 40), (25, 40)], POOL[2])
        c.line([(38, 41), (41, 41)], POOL[2])
    # grass tufts on the rim
    for (gx, gy) in ((20, 17), (44, 17), (17, 44), (47, 46)):
        x, y = c.P(gx, gy)
        c.px(x, y, GRASS[2]); c.px(x + 1, y - 1, GRASS[2])
    # face floating in the pool
    ex = (25, 37) if c.small else (27, 37)
    c.eye(ex[0], 31, disc=True)
    c.eye(ex[1], 31, disc=True)
    c.smile(32, 36.5, UMBER)
    c.blush(23, 36); c.blush(40, 36)


K.render_pal(fn, 'pl-oasi-5', 'Rimmed Pool Saucer', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-oasi-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-oasi-5.png')
