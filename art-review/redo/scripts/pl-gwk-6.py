# pl-gwk-6 "Grey Wolf Whistle" (rare, whimsy-wolf, double knobs).
# Concept: the stone wolf king howling at the moon, in profile. The square core is the wolf's
# chest/neck (stone-blue speckle from cell 5-4); the head breaks out of the top edge with a pointed
# ear (top-left) and a long snout howling up-right. Double tab W (ruff), double blank E cut into the
# chest, double tab S (forepaws block). A little brass whistle hangs on a red cord at the chest.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

STONE = ('#828db9', '#5a6492', '#aab6e0')
STONED = ramp('#5c6aa0')
EARIN = ramp('#5a3a70')
NOSE = '#24284f'
MOUTH = ramp('#cf515f')
EYEY = '#f2d661'
BRASS = ramp('#e0a83a')
CORD = '#c8323a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(12, 28, 50, 57)
    head = poly([(12, 28), (14, 18), (22, 12), (30, 11), (38, 12), (50, 4.5), (56, 6), (55, 11),
                 (50, 16), (52, 20), (47, 24), (44, 28)])
    ear = poly([(15, 22), (14, 4), (27, 14)])
    tabW = knob('T', 'double', 12, 42, -1, 0, r=4.8 * k)
    tabS = knob('T', 'double', 31, 57, 0, 1, r=4.8 * k)
    blankE = knob('B', 'double', 50, 41, 1, 0, r=4.6 * k)
    cut = (blankE,)
    body = c.m(core, head, ear, tabW, tabS, minus=cut)
    c.add(body, STONE, stitch=None)
    # stone speckle from the cell (dark navy and light flecks)
    if not c.small:
        for (x, y) in body:
            h = (x * 7 + y * 13 + (x * y) % 5) % 37
            if h == 0:
                c.px(x, y, '#24284f')
            elif h in (5, 11):
                c.px(x, y, STONED[0])
            elif h == 17:
                c.px(x, y, STONE[2])
    else:
        for (x, y) in body:
            if (x * 7 + y * 13) % 19 == 0:
                c.px(x, y, STONED[0])
    # inner ear
    c.add(c.m(poly([(16.5, 20), (16, 8), (23.5, 14.5)])), EARIN)
    # spiky ruff down the back of the neck (statue's spines) - lighter tone on the W tab
    c.add(c.m(tabW, minus=(core,)) | (c.m(tabW) & c.m(rect(10, 0, 13, 64))), STONED)
    # paws on the S tab
    paws = c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(rect(0, 55, 64, 58)))
    c.add(paws, STONED)
    # open howling mouth: red wedge between upper snout and lower jaw
    c.add(c.m(poly([(44, 17.5), (54, 9.5), (49, 16), (50.5, 19), (46, 20)])), MOUTH)
    # nose tip
    nx, ny = c.P(54.5, 6.5)
    for dx in range(-1 if not c.small else 0, 1):
        for dy in range(0, 2):
            c.px(nx + dx, ny + dy, NOSE)
    # eye: yellow, narrowed, looking up
    ex, ey = c.P(35, 15)
    if not c.small:
        for dx in range(-2, 2):
            for dy in range(-1, 2):
                c.px(ex + dx, ey + dy, EYEY)
        c.px(ex, ey, NOSE); c.px(ex + 1, ey, NOSE); c.px(ex, ey - 1, NOSE)
        c.px(ex + 1, ey - 1, NOSE)
    else:
        c.px(ex - 1, ey, EYEY); c.px(ex, ey, NOSE); c.px(ex - 1, ey + 1, EYEY); c.px(ex, ey + 1, EYEY)
    # cord around the neck + brass whistle
    c.line([(14, 30), (22, 36), (25, 37.5)], CORD) if not c.small else c.line([(14, 31), (22, 36), (25, 37.5)], CORD)
    if c.small:
        c.line([(14, 32), (22, 37)], CORD)
    wh = c.m(ell(27.5, 41, 4.6, 4.2), rect(27.5, 36.8, 41, 40.6))
    c.add(wh, BRASS)
    c.edge(wh, BRASS[1])
    hx, hy = c.P(31.5, 37.6)
    c.px(hx, hy, K.UMBER2)
    if not c.small:
        c.px(hx + 1, hy, K.UMBER2)
        c.px(*c.P(26, 39.5), BRASS[2])


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-gwk-6', 'Grey Wolf Whistle', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gwk-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gwk-6.png'))
