# Silkthread Tuft: a silk-wrapped cocoon pal hanging from a spider thread (like the cocoons in the Silverback lair picture).
# Corner-TT, peg: flat W and S sides (the cocoon rests in the corner), peg tab N = the silk knot where the thread is tied,
# peg tab E = a sticky silk tuft pulled out sideways. Body in the mauve-grey rock of cell 4-2, wrapped in pale lavender silk bands.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROCK = K.ramp('#8b706e')
ROCK2 = K.ramp('#6e5660')
SILK = ('#e4e0e1', '#9c95ba', '#f6f4fa')
BODY = ('#d6d0e0', '#9c95ba', '#f2f0f8')
THREAD = ('#c8c8e0', '#9c95ba', '#edecf7')


def fn(c):
    k = 1.15 if c.small else 1.0
    # rounded-top core: flat W and S, rounded NE / NW shoulders like a cocoon top
    core = lambda x, y: (10 <= x < 52 and 22 <= y < 58) and not (
        (x > 40 and y < 34 and (x - 40) ** 2 + (y - 34) ** 2 > 144) or
        (x < 22 and y < 34 and (x - 22) ** 2 + (y - 34) ** 2 > 144))
    tabN = K.knob('T', 'peg', 31, 22, 0, -1, r=5.0 * k)
    tabE = K.knob('T', 'peg', 52, 41, 1, 0, r=4.6 * k)
    body = c.m(core)
    c.add(body, BODY)
    # criss-cross silk wrapping in the cell's mauve rock tones (wound round and round)
    bw = 2.2 if not c.small else 2.6
    for x0 in (-6, 10, 26, 42):
        c.edges.update({p: ROCK[0] for p in c.m(K.thick_path([(x0, 58), (x0 + 30, 22)], bw)) & body})
    for x0 in (-14, 2, 18, 34):
        c.edges.update({p: ROCK2[0] for p in c.m(K.thick_path([(x0, 22), (x0 + 30, 58)], bw)) & body})
    # loose silk fluff on the NW shoulder (the tuft)
    fl = c.m(K.ell(15, 23, 4.2, 3.4), K.ell(20.5, 19.5, 3.6, 3.2), K.ell(11.5, 28, 3, 3))
    c.add(fl, SILK)
    # calm face patch so the eyes do not sit on the threads
    c.edges.update({p: BODY[0] for p in c.m(K.ell(31, 39, 13, 7.5)) & body})
    # N peg: the silk knot + the thread it hangs from
    c.add(c.m(tabN, minus=(core,)), SILK)
    tw = 2.2 if not c.small else 2.8
    c.add(c.m(K.thick_path([(31, 0), (31, 12)], tw)), THREAD)
    # E peg: a pulled-out silk tuft
    c.add(c.m(tabE, minus=(core,)), SILK)
    if not c.small:
        x, _ = c.P(57, 0)
        for y in range(c.P(0, 38)[1], c.P(0, 45)[1], 2):
            c.px(x, y, SILK[1])
    # face on the calm rock area between bands
    c.eye(24, 35, disc=False)
    c.eye(38, 35, disc=False)
    c.smile(31, 46 if not c.small else 46, K.UMBER2)
    c.blush(19, 47)
    c.blush(43, 47)


K.render_pal(fn, 'pl-sbs-1', 'Silkthread Tuft', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sbs-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sbs-1.png')
