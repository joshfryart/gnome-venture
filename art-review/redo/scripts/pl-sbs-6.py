"""pl-sbs-6 Silverback Spool (whimsy-spider, peg): a spider whose square plum body is the piece core. The top half is the silver back,
wound with silk like a spool. Peg tabs N (with the silk thread hanging up), E and W; a peg blank S under the jaw. Two bent legs at each
corner. Cell 6-3: a dark violet lair, silver-lavender web threads, glowing white eyes with violet halos."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

PLUM = K.ramp('#5a4680')
SILK = ('#c9c8e4', '#9a98c0', '#f2f0ff')
LEG = K.ramp('#3e3060')
GLOW = '#f4eeff'
HALO = '#b090e0'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 15, 17, 49, 51
    core = lambda x, y: rect(x0, y0, x1, y1)(x, y) and not (
        any(((x - cx) ** 2 + (y - cy) ** 2 > 16 and (x - cx) * sx > 0 and (y - cy) * sy > 0)
            for cx, cy, sx, sy in ((x0 + 4, y0 + 4, -1, -1), (x1 - 4, y0 + 4, 1, -1), (x0 + 4, y1 - 4, -1, 1), (x1 - 4, y1 - 4, 1, 1))))
    tabN = knob('T', 'peg', 32, y0, 0, -1, r=4.0 * k)
    tabE = knob('T', 'peg', x1, 34, 1, 0, r=4.0 * k)
    tabW = knob('T', 'peg', x0, 34, -1, 0, r=4.0 * k)
    blankS = knob('B', 'peg', 32, y1, 0, 1, r=4.0 * k)
    lw = 3.6 if not c.small else 4.4
    legs = [
        thick_path([(19, 21), (9, 9), (4, 19)], lw),
        thick_path([(45, 21), (55, 9), (60, 19)], lw),
        thick_path([(19, 47), (9, 50), (5, 61)], lw),
        thick_path([(45, 47), (55, 50), (59, 61)], lw),
    ]
    c.add(c.m(*legs, minus=(core,)), LEG)
    body = c.m(core, tabE, tabW, minus=(blankS,))
    c.add(body, PLUM)
    # silver back: wound silk, the spool (top half and the N peg)
    back = c.m(tabN) | (body & c.m(lambda x, y: y < 32))
    c.add(back, SILK)
    if not c.small:
        for yy in (23, 26.5):
            c.line([(x0 + 2, yy), (x1 - 2, yy)], SILK[1])
    else:
        c.line([(x0 + 2, 25), (x1 - 2, 25)], SILK[1])
    c.edge(back, PLUM[1])
    # spool flanges: dark plum rims top and bottom of the silk winding
    c.add(back & c.m(rect(0, 0, 64, 19.5)), PLUM)
    c.add(c.m(rect(x0, 30, x1, 32.5)), LEG)
    # the silk thread rising from the N peg
    c.add(c.m(rect(31, 0, 33.2, 12)), SILK)
    # glowing eyes with violet halos (the picture's eyes)
    for ex in (25, 39):
        cx, cy = c.P(ex, 40)
        r = 3 if not c.small else 2
        for dx in range(-r, r + 1):
            for dy in range(-r, r + 1):
                if dx * dx + dy * dy <= r * r + 1:
                    c.px(cx + dx, cy + dy, HALO)
        c.eye(ex, 40, disc=True)
    # little fangs either side of the blank
    for fx in (28, 36):
        x, y = c.P(fx, 47)
        c.px(x, y, SILK[2])
        c.px(x, y + 1, SILK[2])
    c.blush(20, 45)
    c.blush(43, 45)


K.render_pal(fn, 'pl-sbs-6', 'Silverback Spool', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sbs-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sbs-6.png')
