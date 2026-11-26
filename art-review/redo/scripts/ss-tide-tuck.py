import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp, UMBER, UMBER2, CREAM

SAND = ramp('#f2d9a0')
SANDDK = ramp('#c2ad8e')
CRAB = ramp('#c0702e')
CRABDK = ramp('#8a5a2a')
WAVE = ramp('#3aa8c8')
FOAM = ('#f4f0e4', '#c9e4ec', '#ffffff')
DRIFT = ramp('#8f7a5d')


def fn(c):
    """Inner-TTTB round: a sand crab tucked into the sand as the wave laps in. Blank N = the dip in its carapace between the
    eye bumps; tabs W+E = claws; tab S = the lapping wave in front. Sand / brown / grey-tan from cell 3-5, sea teal from the picture."""
    k = 1.15 if c.small else 1.0
    core0 = rect(11, 15, 53, 52)
    core = lambda x, y: core0(x, y) and not ((x < 16 or x > 48) and y < 20 and ((x - (16 if x < 32 else 48)) ** 2 + (y - 20) ** 2) > 25)
    bN = knob('B', 'round', 32, 15, 0, -1, r=4.4 * k)
    tW = knob('T', 'round', 11, 30, -1, 0, r=5.0 * k)
    tE = knob('T', 'round', 53, 30, 1, 0, r=5.0 * k)
    tS = knob('T', 'round', 32, 52, 0, 1, r=5.0 * k)
    body = c.m(core, tW, tE, tS, minus=(bN,))
    c.add(body & c.m(core), CRAB)
    # sand mound over the lower half: the crab is tucked in
    sand = c.m(lambda x, y: y > 37.5 + 1.2 * ((x - 32) / 21.0) ** 2) & body
    c.add(sand, SAND)
    c.edge(sand, SANDDK[1])
    for (sx, sy) in ((17, 43), (24, 45), (42, 44), (47, 46), (36, 42), (20, 48)):
        if c.small and (sx, sy) in ((24, 45), (36, 42), (20, 48)):
            continue
        c.px(*c.P(sx, sy), SANDDK[0])
    # wave lapping in at the bottom: teal band + the S tab as a curling splash
    wave = c.m(lambda x, y: 45.5 + 1.3 * __import__('math').sin(x * 0.45) < y < 49.5 + 1.3 * __import__('math').sin(x * 0.45)) & body
    c.add(wave, WAVE)
    c.add(c.m(lambda x, y: 45.5 + 1.3 * __import__('math').sin(x * 0.45) < y < 46.8 + 1.3 * __import__('math').sin(x * 0.45)) & body, FOAM)
    # claws (after the sand, so they stay crab-coloured), with an upper pincer notch
    for side, mx in ((-1, 11), (1, 53)):
        tab = knob('T', 'round', mx, 30, side, 0, r=5.0 * k)
        cl = c.m(tab, minus=(core,)) | (c.m(tab) & c.m(rect(mx - 2, 0, mx + 2, 64)))
        c.add(cl, CRAB)
        tipx = mx + side * 7.8
        c.cut |= (c.m(poly([(tipx + side * 4, 23.5), (tipx + side * 4, 28.6), (tipx - side * 1.6, 29.4)])) & cl)
    # carapace grain
    if not c.small:
        c.line([(19, 26), (25, 24.5), (39, 24.5), (45, 26)], CRABDK[0])
    # face: eyes on the two bumps beside the dip
    c.eye(21.5, 21.5, disc=True)
    c.eye(42.5, 21.5, disc=True)
    c.smile(32, 30.5, UMBER2)
    c.blush(17.5, 29)
    c.blush(45.5, 29)


K.render_pal(fn, 'ss-tide-tuck', 'Tide Tuck', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/ss-tide-tuck-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/ss-tide-tuck.png')
