import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Concept: a piazza bell tower that IS an inner-TTTT peg piece: terracotta tile roof band with a peg finial (top tab),
# green shutters as the side peg tabs, a stone step as the bottom peg, golden bell with a face in the arched window, lavender sky behind it.
ROOF = K.ramp('#e0743c'); TILE_D = '#a8402e'
WALL = K.ramp('#e8a868'); SHUT = K.ramp('#2f7a5a'); SKY = K.ramp('#9a8cc8')
GOLD = K.GOLD; STONE = K.ramp('#b8a890')

def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 14, 52, 52)
    tabs = [K.knob('T', 'peg', 32, 14, 0, -1, r=5.2 * k), K.knob('T', 'peg', 12, 35, -1, 0, r=5.2 * k),
            K.knob('T', 'peg', 52, 35, 1, 0, r=5.2 * k), K.knob('T', 'peg', 32, 52, 0, 1, r=5.2 * k)]
    body = c.m(core, *tabs)
    c.add(body, WALL, stitch=None if c.small else '#c88048')
    # roof band (terracotta) + finial tab
    roof = c.m(K.rect(12, 14, 52, 24), tabs[0])
    c.add(roof, ROOF)
    # tile rows
    for y in (17, 20):
        c.line([(13, y), (51, y)], TILE_D) if not c.small else None
    if c.small:
        c.line([(13, 19), (51, 19)], TILE_D)
    for x in range(16, 52, 6):
        c.line([(x, 14.5 if x % 12 else 17.5), (x, 23)], TILE_D) if not c.small else None
    c.edge(c.m(K.rect(12, 14, 52, 24)), TILE_D)
    # shutters (side tabs), green with slats
    for t, x0, x1 in ((tabs[1], 3, 17), (tabs[2], 47, 61)):
        px0, px1 = (14, 20) if x0 == 3 else (44, 50)
        sh = c.m(lambda x, y, t=t: t(x, y) and 26 < y < 46, K.rect(px0, 27, px1, 47))
        c.add(sh, SHUT)
        c.edge(sh, SHUT[1])
        if not c.small:
            xs = (4, 19) if x0 == 3 else (45, 60)
            for y in (30, 33, 36, 39, 42):
                c.line([(xs[0], y), (xs[1], y)], SHUT[1])
    # step (bottom tab)
    st = c.m(tabs[3], K.rect(12, 48, 52, 52))
    c.add(st, K.ramp('#a8484a'))
    c.edge(c.m(K.rect(12, 48, 52, 52)), '#7a3036')
    # arched window with sky
    win = c.m(K.rect(21, 34, 43, 48), K.ell(32, 34, 11, 9))
    c.add(win, SKY)
    c.edge(win, '#5a3a50')
    # bell
    bell = c.m(K.ell(32, 36, 6, 7), K.poly([(26, 36), (38, 36), (41.5, 44), (22.5, 44)]), K.rect(22, 42.5, 42, 45.5), K.ell(32, 28.5, 2.2, 2.2))
    c.add(bell, GOLD)
    c.edge(c.m(K.rect(22, 43.5, 42, 46)), GOLD[1])
    clap = c.m(K.ell(32, 46.5, 2.2, 2.2))
    c.add(clap, K.ramp('#b07a10'))
    c.eye(29.2, 37); c.eye(35.2, 37)
    c.smile(32.2, 40.5)
    c.blush(26.5, 40); c.blush(37, 40)

K.render_pal(fn, 'pl-oliv-4', 'Piazza Chime', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-oliv-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-oliv-4.png')
