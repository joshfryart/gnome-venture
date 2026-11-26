# Remove the baked-in gnome standing in the central dolmen gap of place-stones.png
# and replace the focal point with a low resting stone. Loads the ORIGINAL; writes to art-review only.
from PIL import Image
import numpy as np

SRC = '/home/user/gnome-venture/game/assets/img/town/place-stones.png'
OUT = '/home/user/gnome-venture/art-review/scenes/out/town__place-stones.png'
CMP = '/home/user/gnome-venture/art-review/scenes/out/town__place-stones-cmp.png'

orig = Image.open(SRC)
a = np.array(orig.convert('RGBA'))

def px(x, y):
    return a[y, x].copy()

# Sample the clean background column inside the gap (x=84, untouched by the gnome).
SKY = px(84, 40)     # cfe8e6
SKY2 = px(84, 60)    # dfe9ea
HILL = px(84, 75)    # 5e8a44
HILLHI = px(84, 82)  # 9cc070
GRASS = px(84, 86)   # 7ea85a
STONE_L = px(20, 60) # aaaab2
STONE_M = px(24, 60) # 8a8a92
STONE_D = px(32, 60) # 62626c
OUT_DK = px(34, 60)  # 2a1a10
OUT_BR = px(18, 75)  # 4a2c1a

# 1. Repaint the gap between the two centre pillars (x 62..85) row by row.
for y in range(36, 86):
    if y < 56: c = SKY
    elif y < 70: c = SKY2
    elif y < 82: c = HILL
    elif y < 84: c = HILLHI
    else: c = GRASS
    a[y, 62:86] = c

# 2. Low resting stone (2px cells like the rest of the art), lit from upper left.
O, B, L, M, D, _ = 'O', 'B', 'L', 'M', 'D', '.'
rock = [
    "..BBBBBB..",
    ".BLLLMMMO.",
    "BLLMMMMMDO",
    "BLMMMMMDDO",
    "BMMMMMDDDO",
    ".OOOOOOOO.",
]
cmap = {'O': OUT_DK, 'B': OUT_BR, 'L': STONE_L, 'M': STONE_M, 'D': STONE_D}
x0, y0 = 64, 74
for j, row in enumerate(rock):
    for i, ch in enumerate(row):
        if ch in cmap:
            a[y0 + 2*j:y0 + 2*j + 2, x0 + 2*i:x0 + 2*i + 2] = cmap[ch]

# 3. A couple of darker grass tufts at the foot of the stone, matching the scene's tufts.
for (tx, ty) in [(62, 82), (84, 84)]:
    a[ty:ty+2, tx:tx+2] = HILL

out = Image.fromarray(a, 'RGBA').convert(orig.mode)
assert out.size == orig.size
out.save(OUT)

w, h = orig.size
cmp_img = Image.new('RGBA', (w * 4 + 8, h * 2), (0, 0, 0, 0))
cmp_img.paste(orig.convert('RGBA').resize((w*2, h*2), Image.NEAREST), (0, 0))
cmp_img.paste(out.convert('RGBA').resize((w*2, h*2), Image.NEAREST), (w*2 + 8, 0))
cmp_img.save(CMP)
print('ok', out.size, out.mode, len(np.unique(a.reshape(-1, 4), axis=0)))
