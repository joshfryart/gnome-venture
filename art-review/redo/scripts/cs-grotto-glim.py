# Concept: a little grotto boulder that IS an inner-BBBB keyhole piece: purple cave rock (cell 0-6) with four keyhole blanks cut in,
# its big navy cave mouth is an "ooh" mouth full of cyan glowworms hanging on silk threads, stalactite teeth on the lip.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

ROCK = ('#5b3a57', '#3b2441', '#80556f')
ROCK_LT = '#7f5673'
CAVE = ('#1c2a47', '#121734', '#2a3a60')
DEEP = '#121734'
GLOW = '#58e8e0'
GLOW_LT = '#c8fff4'
THREAD = '#3c5a7a'


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 3.0 * k
    core = K.rect(6, 6, 58, 58)
    # rounded corners (worn rock), straight sides between the knobs
    corners = [K.rect(6, 6, 10, 10), K.rect(54, 6, 58, 10), K.rect(6, 54, 10, 58), K.rect(54, 54, 58, 58)]
    keep = [K.ell(10, 10, 4, 4), K.ell(54, 10, 4, 4), K.ell(10, 54, 4, 4), K.ell(54, 54, 4, 4)]
    cornercut = lambda x, y: any(a(x, y) for a in corners) and not any(b(x, y) for b in keep)
    bN = K.knob('B', 'keyhole', 32, 6, 0, -1, r=r)
    bS = K.knob('B', 'keyhole', 32, 58, 0, 1, r=r)
    bW = K.knob('B', 'keyhole', 6, 32, -1, 0, r=r)
    bE = K.knob('B', 'keyhole', 58, 32, 1, 0, r=r)
    body = c.m(core, minus=(bN, bS, bW, bE, cornercut))
    c.add(body, ROCK, stitch=None if c.small else ROCK[1])
    # rock strata: lighter slabs, upper left
    if not c.small:
        for pts in ([(11, 18), (17, 17)], [(46, 16), (52, 17)], [(12, 44), (18, 45)], [(45, 46), (51, 44)]):
            c.line(pts, ROCK_LT)
    # cave mouth: a tall arch "ooh"
    mouth = c.m(K.ell(32, 37, 12, 11), K.rect(20, 37, 44, 45)) & body
    c.add(mouth, CAVE)
    inner = c.m(K.ell(32, 39, 9, 8)) & mouth
    c.add(inner, (DEEP, DEEP, CAVE[0]))
    # stalactite teeth hanging from the arch lip
    for tx in (24, 32, 40):
        c.add(c.m(K.poly([(tx - 2.6, 25), (tx + 2.6, 25), (tx, 32.5 if tx == 32 else 31)])) & mouth, ('#80556f', ROCK[0], '#9a6e88'))
    # pebble floor of the grotto
    c.add(c.m(K.ell(25, 47, 5, 2.6), K.ell(37, 47.5, 6, 2.4)) & mouth, ('#80556f', ROCK[0], '#9a6e88'))
    # glowworms on silk threads inside the mouth
    worms = [(25, 39), (29, 43), (35, 41.5), (39, 37), (32, 36)] if not c.small else [(25, 40), (31, 43), (37, 39)]
    for (gx, gy) in worms:
        if not c.small:
            c.line([(gx, 28), (gx, gy - 1.5)], THREAD)
            x, y = c.P(gx, gy)
            c.px(x, y, GLOW_LT); c.px(x + 1, y, GLOW); c.px(x, y + 1, GLOW); c.px(x + 1, y + 1, GLOW)
        else:
            x, y = c.P(gx, gy)
            c.px(x, y, GLOW_LT); c.px(x + 1, y, GLOW); c.px(x, y + 1, GLOW)
    # a few glowworm specks on the rock face (the cell's cyan dots)
    for (gx, gy) in ((13, 22), (51, 22), (15, 50), (49, 51)):
        x, y = c.P(gx, gy)
        c.px(x, y, GLOW)
        if not c.small:
            c.px(x + 1, y, GLOW_LT)
    # face: glowing eyes above the mouth
    c.eye(22, 17, disc=True, look=(0, 0))
    c.eye(42, 17, disc=True, look=(0, 0))
    c.blush(16, 21) if not c.small else None
    c.blush(47, 21) if not c.small else None


K.render_pal(fn, 'cs-grotto-glim', 'Grotto Glim', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/cs-grotto-glim-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/cs-grotto-glim.png')
