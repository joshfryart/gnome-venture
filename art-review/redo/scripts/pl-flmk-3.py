# Stir Wave: a teal canal-water cooking pot that IS an inner piece. Tabs L/R = the pot's two round handles,
# blanks top/bottom = the pot mouth (peach + pink market dumplings bob either side) and the gap between two stubby feet.
# Colours from cell 4-6: canal teal, peach and pink dumplings, golden raft; a wooden stirring spoon leans out.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

POT = K.ramp('#3a9cb4')
RIM = K.ramp('#f4bc5c')
PEACH = K.ramp('#ffb880')
PINK = K.ramp('#f08a9c')
SPOON = K.ramp('#c88a48')
STEAM = ('#f4f0e4', '#c8e8ec', '#ffffff')


def fn(c):
    k = 1.15 if c.small else 1.0
    top, bot = 11, 56
    belly = (K.rect(12, 25, 52, 50), K.ell(32, 47, 20, 9.5), K.rect(17, 50, 47, bot))
    tl = K.knob('T', 'round', 12, 37, -1, 0, r=4.5 * k)
    tr = K.knob('T', 'round', 52, 37, 1, 0, r=4.5 * k)
    bt = K.knob('B', 'round', 32, top, 0, -1, r=4.0 * k)
    bb = K.knob('B', 'round', 32, bot, 0, 1, r=3.4 * k)
    blanks = (bt, bb)
    # spoon behind: wooden handle leaning up-right out of the pot
    c.add(c.m(K.thick_path([(44, 20), (55, 4)], 3.4 if c.small else 3.0), K.ell(55.5, 4.5, 3.0, 3.0)), SPOON)
    # heap of market dumplings filling the mouth; the top blank bites into the heap
    c.add(c.m(K.rect(13, 17, 51, 25), K.ell(21, 17, 9, 6.5), minus=blanks), PEACH)
    pink = c.m(K.ell(43, 17, 9, 6.5), minus=blanks)
    c.add(pink, PINK)
    c.edge(pink, PINK[1])
    body = c.m(*belly, tl, tr, minus=blanks)
    c.add(body, POT, stitch=None if c.small else '#8ad0dc')
    rim = c.m(K.rect(10, 22, 54, 27), minus=blanks)
    c.add(rim, RIM)
    for cx in (12 - 6.1 * k, 52 + 6.1 * k):
        c.add(c.m(K.ell(cx, 37, 2.6 * k, 2.6 * k)), RIM)
    c.eye(24, 35)
    c.eye(40, 35)
    c.smile(32, 40, wide=True)
    c.blush(19, 40)
    c.blush(44, 40)
    # canal wave across the belly
    c.line([(15, 47), (19, 45), (23, 47), (26, 45)], '#8ad0dc')
    c.line([(38, 45), (41, 47), (45, 45), (49, 47)], '#8ad0dc')
    # dumpling pleats
    if not c.small:
        c.line([(18, 14), (21, 12), (24, 14)], PEACH[1])
        c.line([(40, 14), (43, 12), (46, 14)], PINK[1])


K.render_pal(fn, 'pl-flmk-3', 'Stir Wave', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-flmk-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-flmk-3.png')
