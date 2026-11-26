"""Remove baked-in gnome, birds and flying red kite/creature from Poppyburrow village card."""
from PIL import Image
import numpy as np

SRC = '/home/user/gnome-venture/game/assets/img/villages/poppyburrow.png'
OUT = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__villages__poppyburrow.png'
CMP = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__villages__poppyburrow-cmp.png'

im = Image.open(SRC)
mode = im.mode
a = np.array(im.convert('RGBA'))

def col(x, y):
    return a[y, x].copy()

GRASS = col(88, 52 + 3)       # (124,195,90)
LINE_B = col(90, 52)          # (63,145,80)
LINE_C = col(92, 52)          # (36,84,74)
assert tuple(GRASS[:3]) == (124, 195, 90) and tuple(LINE_C[:3]) == (36, 84, 74)

# 1. birds in the sky: replace bird blue with left neighbour
bird = np.array([95, 154, 208])
for y in range(2, 14):
    for x in range(10, 45):
        if (a[y, x, :3] == bird).all():
            a[y, x] = a[y, x - 1]

# 2. red flying thing + its speed streaks: fill with sky colour of the row
for y in range(18, 31):
    sky = a[y, 90].copy()
    for x in range(94, 118):
        a[y, x] = sky

# 3. gnome: repaint grass, then continue the two mound outlines
for y in range(57, 75):
    for x in range(96, 110):
        a[y, x] = GRASS
# central mound right edge: diagonal then vertical (matches rows 72-77 below)
for y in range(57, 75):
    cx = min(97 + (y - 57), 104)
    a[y, cx - 1] = LINE_B
    a[y, cx] = LINE_C
# restore small flowers that sat in the grass left of the gnome (row 58/59 at x93-95 untouched)
# a few poppy buds where the gnome stood, sampled from the existing bud pattern (g over j)
RED = col(94, 58)    # (232,73,59)
DRED = col(95, 58)   # (181,46,63)
for (x, y) in [(99, 66), (101, 61)]:
    a[y, x] = RED
    a[y + 1, x] = DRED

out = Image.fromarray(a, 'RGBA').convert(mode) if mode != 'RGBA' else Image.fromarray(a, 'RGBA')
assert out.size == im.size and out.mode == im.mode
out.save(OUT)

w, h = im.size
cmp = Image.new('RGBA', (w * 4 + 8, h * 2), (40, 40, 40, 255))
cmp.paste(im.convert('RGBA').resize((w * 2, h * 2), Image.NEAREST), (0, 0))
cmp.paste(out.convert('RGBA').resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
cmp.save(CMP)
