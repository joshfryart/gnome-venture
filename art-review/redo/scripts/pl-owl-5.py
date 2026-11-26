import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

# Crag-owlet inner piece (inner-BBBB, peg): top blank = dip between snowy ear tufts, side blanks notch the folded wings,
# bottom blank between the feet. Lavender ice-stripe facets from cell 6-6, snow cap, sleepy closed eyes, aurora halo band.
VIO = K.ramp('#8a86b8')
VIOD = K.ramp('#5e5a92')
PALE = K.ramp('#c4bedc')
SNOW = K.WHITE
BEAK = K.ramp('#f0a030')
FOOT = K.ramp('#e8a317')

def fn(c):
    k = 1.15 if c.small else 1.0
    r = 3.4 * k
    core = K.poly([(10, 16), (8, 3), (20, 13), (44, 13), (56, 3), (54, 16), (54, 51), (50, 56), (14, 56), (10, 51)])
    blanks = (K.knob('B', 'peg', 32, 13, 0, -1, r=r),
              K.knob('B', 'peg', 10, 38, -1, 0, r=r),
              K.knob('B', 'peg', 54, 38, 1, 0, r=r),
              K.knob('B', 'peg', 32, 56, 0, 1, r=r))
    body = c.m(core, minus=blanks)
    c.add(body, VIO)
    # ice-stripe facets (vertical, like the cell)
    for x0, w, rm in ((16, 3, PALE), (36, 2, VIOD), (44, 3, PALE), (22, 2, VIOD)):
        c.add(c.m(K.rect(x0, 30, x0 + w, 50)) & body, rm)
    # pale belly
    belly = c.m(K.ell(32, 41, 10, 10)) & body
    c.add(belly, PALE)
    for yy in (37, 42, 47):
        c.line([(29, yy), (31, yy + 1), (33, yy)], VIOD[0])
        if not c.small:
            c.line([(34, yy - 2), (36, yy - 1), (38, yy - 2)], VIOD[0])
    # wings (darker), notched by the side blanks
    lw = c.m(K.poly([(10, 24), (18, 28), (20, 51), (10, 51)]), minus=blanks) & body
    rw = c.m(K.poly([(54, 24), (46, 28), (44, 51), (54, 51)]), minus=blanks) & body
    c.add(lw, VIOD)
    c.add(rw, VIOD)
    c.edge(lw, VIOD[1]); c.edge(rw, VIOD[1])
    # ice facet streaks on the wings (from the cell's vertical lavender bands)
    for x0 in (13, 49):
        c.add(c.m(K.rect(x0, 30, x0 + 2.6, 49), minus=blanks) & body, PALE)
    # snow cap on the tufts and head
    snow = c.m(K.poly([(10, 16), (8, 3), (13, 8), (14, 14), (24, 14), (40, 14), (50, 14), (51, 8), (56, 3), (54, 16), (54, 20), (47, 18), (40, 20), (33, 18), (26, 20), (18, 18), (10, 20)]), minus=blanks) & body
    c.add(snow, SNOW)
    # feet
    for fx in (22, 42):
        c.add(c.m(K.rect(fx - 3, 52, fx + 3, 56)) & body, FOOT)
    # face: sleepy closed eyes in pale discs, beak
    for ex in (24, 40):
        cx, cy = c.P(ex, 27)
        if not c.small:
            for dx in range(-3, 4):
                for dy in range(-3, 4):
                    if dx * dx + dy * dy <= 10:
                        c.px(cx + dx, cy + dy, PALE[2])
            c.px(cx - 2, cy, K.UMBER); c.px(cx + 2, cy, K.UMBER)
            c.px(cx - 1, cy + 1, K.UMBER); c.px(cx, cy + 1, K.UMBER); c.px(cx + 1, cy + 1, K.UMBER)
        else:
            for dx in range(-2, 3):
                for dy in range(-2, 2):
                    if abs(dx) + abs(dy) <= 2:
                        c.px(cx + dx, cy + dy, PALE[2])
            c.px(cx - 1, cy, K.UMBER); c.px(cx, cy + 1 - 1, K.UMBER); c.px(cx + 1, cy, K.UMBER)
    bx, by = c.P(32, 30)
    for dx, dy in ((-1, 0), (0, 0), (1, 0), (0, 1)) if not c.small else ((0, 0), (1, 0), (0, 1)):
        c.px(bx + dx, by + dy, BEAK[0])
    c.blush(19, 31) if not c.small else None
    if not c.small:
        c.blush(44, 31)

K.render_pal(fn, 'pl-owl-5', 'Snowcrag Halo', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-owl-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-owl-5.png')
