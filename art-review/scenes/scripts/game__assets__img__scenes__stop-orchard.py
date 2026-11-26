"""Remove baked-in birds from stop-orchard backdrop (two sky birds, one bird in right tree)."""
from PIL import Image
import numpy as np

SRC = '/home/user/gnome-venture/game/assets/img/scenes/stop-orchard.png'
OUT = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__scenes__stop-orchard.png'
CMP = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__scenes__stop-orchard-cmp.png'

im = Image.open(SRC)
a = np.array(im)
BIRD = (78, 58, 138)
RED = (214, 50, 43)
YEL = (245, 207, 106)

def is_col(px, c):
    return tuple(int(v) for v in px[:3]) == c

# 1) Sky birds: fill with the sky band colour of the same row (bands are horizontal).
for y in range(24, 46):
    sky = a[y, 185].copy()
    for x in range(188, 232):
        if is_col(a[y, x], BIRD):
            a[y, x] = sky

# 2) Bird in right tree foliage (purple wings, red/yellow body), x 448-473, y 57-67.
LIGHT = a[58, 448].copy()   # foliage light green
DARK = a[58, 466].copy()    # foliage shade green
for y in range(57, 68):
    for x in range(448, 474):
        if any(is_col(a[y, x], c) for c in (BIRD, RED, YEL)):
            off = x - 448
            a[y, x] = DARK if (16 <= off <= 21 and y >= 62) else LIGHT

out = Image.fromarray(a, im.mode)
assert out.size == im.size
out.save(OUT)
w, h = im.size
cmp = Image.new(im.mode, (w * 4 + 8, h * 2), (0, 0, 0, 255))
cmp.paste(im.resize((w * 2, h * 2), Image.NEAREST), (0, 0))
cmp.paste(out.resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
cmp.save(CMP)
print(len(np.argwhere((a[..., :3] == BIRD).all(-1))), 'bird-colour pixels left')
