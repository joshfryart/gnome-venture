import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

# Concept: a tattered cream topsail (inner-TTTT, keyhole): top tab = brown masthead flying the red pennant, bottom tab = mast foot,
# left/right tabs = sail corners billowing; orange mend patch, a little tear, teal sea-blue trim from cell 5-2.
SAIL = K.ramp('#ecd9a8')
SAILD = K.ramp('#d6b880')
WOODR = K.ramp('#8a5a32')
RED = K.ramp('#d8322e')
PATCH = K.ramp('#e8822a')
SEA = K.ramp('#2a9ab8')


def fn(c):
    s = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 11, 14, 53, 51
    core = K.rect(x0, y0, x1, y1)
    tl = K.knob('T', 'keyhole', x0, 33, -1, 0, r=4.3 * s)
    tr = K.knob('T', 'keyhole', x1, 33, 1, 0, r=4.3 * s)
    tb = K.knob('T', 'keyhole', 32, y1, 0, 1, r=4.3 * s)
    tt = K.knob('T', 'keyhole', 32, y0, 0, -1, r=4.3 * s)
    # tattered bottom: two small rag notches beside the mast foot
    rag = [K.poly([(15, 52), (18, 47), (21, 52)]), K.poly([(43, 52), (46, 47.5), (49, 52)])]
    c.add(c.m(core, tl, tr, minus=rag), SAIL, stitch=None if c.small else '#c9a874')
    # canvas seams (vertical panels)
    if not c.small:
        for x in (21, 43):
            c.line([(x, 19), (x, 46)], SAIL[1])
    # billow shade down the right side
    fold = c.m(K.poly([(46, 18), (53, 18), (53, 51), (50, 51), (47, 34)]), minus=rag)
    c.add(fold, SAILD)
    c.edge(fold, SAILD[1])
    # yard (spar) across the top
    c.add(c.m(K.rect(x0 - 2, y0 - 1, x1 + 2, y0 + 3.5)), WOODR)
    c.add(c.m(tt), WOODR)
    c.add(c.m(tb), WOODR)
    # red pennant off the masthead
    c.add(c.m(K.poly([(33, 2.5), (46, 6), (33, 9.5)])), RED)
    # orange mend patch, upper left, with cross stitch
    pt = c.m(K.rect(14, 20, 24, 29))
    c.add(pt, PATCH)
    c.edge(pt, PATCH[1])
    if not c.small:
        c.line([(16, 22), (21.5, 26.5)], K.CREAM)
        c.line([(21.5, 22), (16, 26.5)], K.CREAM)
    else:
        c.line([(16.5, 23), (21, 26.5)], K.CREAM)
    # torn hole showing the sea (cell 5-2: blue water + tear)
    hole = c.m(K.ell(19, 43, 3.4, 3.0) if not c.small else K.ell(18.5, 42, 4, 3.6))
    c.add(hole, SEA)
    c.edge(hole, K.UMBER2)
    # face
    c.eye(28, 32)
    c.eye(38, 32)
    c.smile(33, 38)
    c.blush(23, 36)
    c.blush(43, 36)


K.render_pal(fn, 'pl-sung-4', 'Topsail Bandage', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sung-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sung-4.png')
