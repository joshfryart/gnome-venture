"""pl-stnd-2 Goldtip Twinkle. Edge-TBB, keyhole: a little mossy standing stone (menhir) that IS the piece.
Flat S = the stone's foot on the moonlit grass, keyhole tab N = the gold twinkle knob on its tip, keyhole blanks W + E bite into the stone.
Lavender-grey stone, green moss cap, a teal rune, night-purple and moon-gold from the standing-stones picture (cell 9-5)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp

STONE = ramp('#8e86a8')
MOSS = ramp('#4f9a5a')
GRASS = ramp('#3f8a4a')
GOLDT = ramp('#e8b830')
RUNE = '#7fe0d0'


def fn(c):
    k = 1.15 if c.small else 1.0
    # stone: tall slab, slightly rounded shoulders, straight sides
    core = poly([(13, 58), (13, 20), (16, 14), (22, 11), (42, 11), (48, 14), (51, 20), (51, 58)])
    tabN = knob('T', 'keyhole', 32, 11.5, 0, -1, r=4.8 * k)
    blW = knob('B', 'keyhole', 13, 38, -1, 0, r=3.4 * k, nw=2.0)
    blE = knob('B', 'keyhole', 51, 38, 1, 0, r=3.4 * k, nw=2.0)
    body = c.m(core, minus=(blW, blE))
    c.add(body, STONE, stitch=STONE[2])
    # grass foot band (flat S side)
    c.add(body & c.m(rect(0, 53, 64, 64)), GRASS)
    if not c.small:
        for gx in range(14, 51, 3):
            x, y = c.P(gx, 52)
            c.px(x, y, GRASS[0])
            c.px(x + 1, y - 1 if gx % 2 else y, GRASS[0])
    # moss cap draping over the shoulders
    moss = c.m(lambda x, y: (x < 30 and y < 15 + 2.5 * ((int(x) // 4) % 2) + (8 if x < 18 else 0)) or (x > 43 and y < 16 + (3 if (int(y) // 3) % 2 else 0)))
    c.add(body & moss, MOSS)
    # gold twinkle knob on top
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 10, 64, 13))), GOLDT)
    gx, gy = c.P(32, 4.2)
    for d in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
        c.px(gx + d[0], gy + d[1], '#fff6c8')
    # teal rune on the stone (like the glowing marks in the picture)
    if not c.small:
        c.line([(24, 43), (22, 46), (24, 49), (22, 52)], RUNE)
        c.line([(40, 43), (40, 51)], RUNE)
        c.line([(40, 45), (43, 43)], RUNE)
        c.line([(40, 48), (43, 46)], RUNE)
    else:
        c.line([(22, 44), (22, 50)], RUNE)
        c.line([(41, 44), (41, 50)], RUNE)
    # speckles of lichen on stone
    if not c.small:
        for (sx, sy) in ((18, 25), (45, 27), (36, 49), (28, 52)):
            c.px(*c.P(sx, sy), STONE[1])
    c.eye(26, 30, disc=True)
    c.eye(38, 30, disc=True)
    c.blush(21.5, 36)
    c.blush(41, 36)
    c.smile(32, 36)


K.render_pal(fn, 'pl-stnd-2', 'Goldtip Twinkle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-stnd-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-stnd-2.png')
