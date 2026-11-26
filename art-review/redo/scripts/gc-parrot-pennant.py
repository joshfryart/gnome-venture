"""gc-parrot-pennant: whimsy-parrot, hook knobs. A scarlet macaw on a bunting perch. Square-ish core = head+body; E hook tab = curved beak,
N hook tab = curled crest, W hook blank bites the back. Leaf-green wing with brown veins (cell 0-6 leaf), pennants from the picture's bunting."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, UMBER

RED = K.ramp('#d6322b')
YEL = K.ramp('#f0c030')
LEAF = K.ramp('#3f9a4a')
BLUE = K.ramp('#3f7fc8')
BEAK = K.ramp('#e6e0d0')
BRANCH = K.ramp('#8a5a2a')
VEIN = '#6a3a1a'


def solid_hook(mx, my, nx, ny, r, nw, flip=False):
    """A filled hook tab (disc + curled tip), so beak and crest read solid instead of as a ring."""
    ax, ay = -ny, nx

    def f(x, y):
        px, py = x - mx, y - my
        u, v = px * ax + py * ay, px * nx + py * ny
        if flip:
            u = -u
        return K._ks('hook', u, v, r, nw, solid=True)
    return f


GREEN = K.ramp('#3a9a4c')
WINGG = K.ramp('#2a7a3e')
DARK = ('#4a3a30', '#3a2c22', '#6a5848')
BROWN = ('#7a4a1f', '#5a3414', '#9a6a3a')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = lambda x, y: rect(15, 13, 45, 49)(x, y) and not (
        (x - 20) ** 2 + (y - 18) ** 2 > 25 and x < 20 and y < 18) and not ((x - 40) ** 2 + (y - 18) ** 2 > 25 and x > 40 and y < 18)
    beak = solid_hook(45, 24, 1, 0, r=5.6 * s, nw=4.0)
    crest = solid_hook(27, 13, 0, -1, r=4.4 * s, nw=3.0, flip=True)
    back = knob('B', 'hook', 15, 37, -1, 0, r=4.4 * s, nw=2.6)
    # tail: long red-and-blue feathers hanging below the perch
    c.add(c.m(poly([(24, 46), (36, 46), (33, 63), (27, 63)])), BLUE)
    c.add(c.m(poly([(28, 48), (32, 48), (31, 63), (29, 63)])), RED)
    body = c.m(core, crest, minus=(back,))
    c.add(body - c.m(rect(0, 49, 64, 64)), GREEN, stitch=GREEN[2])
    # red cap over the head + crest
    c.add((c.m(ell(30, 13, 15, 8.5)) & body) | c.m(crest, minus=(rect(0, 12.5, 64, 64),)), RED)
    c.add(c.m(crest, minus=(rect(0, 8, 64, 64),)), YEL)
    # beak: cream upper mandible curling down, dark lower jaw
    ex = 45 + 2 * 5.6 * s + 1.6      # outer end of the beak disc
    tip = poly([(ex - 1.2, 22), (ex + 0.3, 27), (ex - 1.5, 32.5), (ex - 4.5, 28.5)])
    bk = c.m(beak, tip, minus=(core,)) | (c.m(beak) & c.m(rect(43, 0, 46, 64)))
    c.add(bk, BEAK)
    jaw = c.m(ell(47.5, 29, 3.6, 2.6)) & bk
    c.add(jaw, DARK)
    c.line([(46, 26.5), (ex - 4, 27.5), (ex - 2, 31)], '#8a7a68')
    # yellow shoulder, then darker leaf wing with brown veins (the cell's leaf)
    hi = c.m(rect(0, 0, 64, 31.5))
    wing = (c.m(ell(28, 39, 10, 9.5)) & body) - hi
    c.add(c.m(ell(28, 33, 10.5, 5)) & body, YEL)
    c.add(wing, WINGG)
    vw = 1.6 if not c.small else 2.3
    c.add(c.m(thick_path([(20, 34), (36, 46)], vw)) & wing, BROWN)
    if not c.small:
        c.add(c.m(thick_path([(26, 38.5), (25, 45)], 1.4), thick_path([(31, 42), (34, 36)], 1.4)) & wing, BROWN)
    # white face patch + eye
    c.add(c.m(ell(37, 23, 5.5, 5)) & body, ('#f4f0e4', '#c9c5bc', '#ffffff'))
    c.eye(38, 23)
    # perch with the picture's bunting pennants
    c.add(c.m(rect(6, 49, 58, 53)), BRANCH)
    for (x0, col) in ((8, YEL), (15, RED), (40, BLUE), (48, YEL)):
        c.add(c.m(poly([(x0, 52.5), (x0 + 6.5, 52.5), (x0 + 3.25, 60)])), col)
    for fx in (26, 34):
        c.add(c.m(ell(fx, 50, 2.4, 1.8)), DARK)


K.render_pal(fn, 'gc-parrot-pennant', 'Parrot Pennant', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/gc-parrot-pennant-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/gc-parrot-pennant.png')
print(K.check(K.draw(fn, 64))['colours'])
