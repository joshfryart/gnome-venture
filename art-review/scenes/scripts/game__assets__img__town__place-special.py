"""Remove baked-in gnome from town/place-special.png; replace with hill/sky/grass and a small tree stump."""
from PIL import Image
import numpy as np

SRC = '/home/user/gnome-venture/game/assets/img/town/place-special.png'
OUT = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__town__place-special.png'
CMP = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__town__place-special-cmp.png'

im = Image.open(SRC)
a = np.array(im)
px = lambda x, y: a[y, x].copy()

SKY = px(10, 40)      # sky
HILL = px(10, 60)     # dark hill green
STRIP = px(10, 82)    # light grass strip
GRASS = px(10, 84)    # grass
D_OUT = px(10, 0) if False else np.array([42, 26, 16, 255], np.uint8)  # darkest outline (sampled from gnome outline)
WOOD_L = np.array([160, 106, 58, 255], np.uint8)   # signpost light wood
WOOD_M = np.array([116, 70, 42, 255], np.uint8)
WOOD_D = np.array([74, 44, 26, 255], np.uint8)
TOP = np.array([240, 200, 160, 255], np.uint8)      # pale cut wood (sampled)

x0, x1 = 26, 50          # gnome columns (exclusive end)
for x in range(x0, x1):
    top = 52 if x < 36 else (54 if x < 44 else 56)
    for y in range(40, 86):
        if y < top:
            a[y, x] = SKY
        elif y < 82:
            a[y, x] = HILL
        elif y < 84:
            a[y, x] = STRIP
        else:
            a[y, x] = GRASS

# small tree stump (2px blocks) sitting on the grass strip, where the gnome stood
def blk(bx, by, c):
    a[by:by+2, bx:bx+2] = c

sx, sy = 32, 74   # top-left of stump
W = 6             # blocks wide
# rows of blocks: outline + body
rows = [
    'OOOOOO',
    'OTTTTO',
    'OLLLMO',
    'OLLMMO',
    'OLMLMO',
    'OLLMDO',
    'OOOOOOO',
]
shape = [
    ' OOOO ',
    'OTTTTO',
    'OLLMDO',
    'OLLMDO',
    'OLMMDO',
    'OLLMDO',
]
cmap = {'O': D_OUT, 'T': TOP, 'L': WOOD_L, 'M': WOOD_M, 'D': WOOD_D}
for j, r in enumerate(shape):
    for i, ch in enumerate(r):
        if ch != ' ':
            blk(sx + 2*i, sy + 2*j, cmap[ch])
# root flares on the grass strip
for bx in (sx - 2, sx + 2*W):
    blk(bx, sy + 10, D_OUT)
# cut ring on top
blk(sx + 4, sy + 2, WOOD_L)

out = Image.fromarray(a, 'RGBA')
assert out.size == im.size
out.save(OUT)
w, h = im.size
cmp = Image.new('RGBA', (w*4 + 8, h*2), (0, 0, 0, 0))
cmp.paste(im.convert('RGBA').resize((w*2, h*2), Image.NEAREST), (0, 0))
cmp.paste(out.resize((w*2, h*2), Image.NEAREST), (w*2 + 8, 0))
cmp.save(CMP)
