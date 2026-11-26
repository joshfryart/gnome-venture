"""Remove baked gnome from town/place-library.png; replace with a stool and book stack."""
from PIL import Image
import numpy as np

SRC = '/home/user/gnome-venture/game/assets/img/town/place-library.png'
OUT = '/home/user/gnome-venture/art-review/scenes/out/town__place-library.png'
CMP = '/home/user/gnome-venture/art-review/scenes/out/town__place-library-cmp.png'

im = Image.open(SRC)
mode = im.mode
a = np.array(im.convert('RGBA'))

def px(x, y):
    return a[y, x].copy()

# colours sampled from the image
C = {
    'c': px(82, 44),   # wall plank
    'e': px(82, 48),   # plank line
    'b': px(98, 82),   # outline / floor edge
    'd': px(112, 66),  # light wood (lectern stand)
    'q': px(82, 80),   # mid-dark wood
    'k': px(86, 56),   # red
    'j': px(90, 64),   # dark red
    'o': px(81, 70),   # blue
    'p': px(97, 70),   # dark blue
    'g': px(84, 68),   # cream
    'i': px(100, 56),  # page shadow
}

# gnome area (pixels; art is 2x2 blocks). Rows 48-59 stop at x96 where the
# lectern book begins; rows 60-81 also cover the gnome's right outline (x98-99).
def span(y):
    return (80, 96) if y < 60 else (80, 100)

# 1) repaint wall
for y in range(48, 82):
    x0, x1 = span(y)
    for x in range(x0, x1):
        ly = y // 2
        a[y, x] = C['e'] if ly in (24, 30, 36) else C['c']
# floor top edge
a[82:84, 80:100] = C['b']

# 2) prop: stool with a small stack of books (logical cols 41..47, rows 27..40)
grid = {
    27: '.bbbbbb',
    28: '.booogb',
    29: '.bpppib',
    30: 'bbbbbbb',
    31: 'bkkkkgb',
    32: 'bjjjjib',
    33: 'bbbbbbb',
    34: 'bdddddb',
    35: 'bqqqqqb',
    36: 'bbbbbbb',
    37: 'bdb.bdb',
    38: 'bdb.bdb',
    39: 'bdb.bdb',
    40: 'bdb.bdb',
}
for ly, row in grid.items():
    for i, ch in enumerate(row):
        if ch == '.':
            continue
        lx = 41 + i
        a[ly*2:ly*2+2, lx*2:lx*2+2] = C[ch]

out = Image.fromarray(a, 'RGBA')
if mode != 'RGBA':
    out = out.convert(mode)
out.save(OUT)

orig = Image.open(SRC).convert('RGBA')
w, h = orig.size
cmp_ = Image.new('RGBA', (w*4 + 8, h*2), (0, 0, 0, 255))
cmp_.paste(orig.resize((w*2, h*2), Image.NEAREST), (0, 0))
cmp_.paste(out.convert('RGBA').resize((w*2, h*2), Image.NEAREST), (w*2 + 8, 0))
cmp_.save(CMP)
