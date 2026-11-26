import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

# Inner-TTTT, tri: a mossy mistmoor standing stone (cell 2-2). N tri tab = moss tuft, E/W tri tabs = stubby stone arms,
# S tri tab = stone foot in a grass tuft. Lichen spots, a crack, grey stone + moss green from the graveyard stones.
STONE = ramp('#9c9d97')
MOSS = ramp('#6a8a3e')
LICHEN = '#c8c45a'
GRASS = ramp('#677159')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: (17 <= x < 47 and 22 <= y < 51) or ell(32, 22, 15, 11)(x, y)
    tN = knob('T', 'tri', 32, 11.2, 0, -1, r=4.6 * k)
    tE = knob('T', 'tri', 47, 36, 1, 0, r=4.4 * k)
    tW = knob('T', 'tri', 17, 36, -1, 0, r=4.4 * k)
    tS = knob('T', 'tri', 32, 51, 0, 1, r=4.6 * k)
    body = c.m(core, tE, tW, tS)
    c.add(body, STONE, stitch=None if c.small else '#bfc0b8')
    # moss cap draping over the top + the N tuft
    cap = c.m(tN, ell(32, 22, 15, 11), minus=(poly([(10, 22), (20, 25), (25, 21.5), (30, 25.5), (36, 22), (41, 25.5), (46, 22), (54, 26), (54, 40), (10, 40)]),))
    c.add(cap, MOSS)
    c.edge(cap, MOSS[1])
    # grass round the foot
    grass = c.m(tS, minus=(core,)) | c.m(rect(17, 48, 47, 51))
    c.add(grass, GRASS)
    c.edge(grass, GRASS[1])
    # crack
    if c.small:
        c.line([(43, 27), (41.5, 30)], STONE[1])
    else:
        c.line([(43, 25), (41.5, 28), (43, 31), (41, 34)], STONE[1])
    # lichen spots
    for (lx, ly, big) in ((20, 29, 1), (43, 42, 1), (22, 44, 0), (39, 45, 0), (20, 38, 0)):
        x, y = c.P(lx, ly)
        c.px(x, y, LICHEN)
        if big and not c.small:
            c.px(x + 1, y, LICHEN); c.px(x, y + 1, LICHEN); c.px(x + 1, y + 1, '#a8a448')
    # face: steady stare, flat stubborn mouth
    c.eye(26.5, 33)
    c.eye(37.5, 33)
    mx, my = c.P(32, 40.5)
    w = 2 if c.small else 3
    for dx in range(-w + 1, w):
        c.px(mx + dx, my, K.UMBER)
    # heavy stone brows
    for bx in (26.5, 37.5):
        x, y = c.P(bx, 28.5)
        for dx in range(-1 if c.small else -2, 2 if c.small else 3):
            c.px(x + dx, y, STONE[1])


K.render_pal(fn, 'mm-stone-sentry', 'Stone Sentry', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mm-stone-sentry-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mm-stone-sentry.png')
