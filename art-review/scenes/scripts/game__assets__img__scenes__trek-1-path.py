"""trek-1-path: remove the two baked firefly sparkles floating in the cave air (scarecrow, signpost, lantern-sun kept as props)."""
from PIL import Image
import numpy as np
SRC = '/home/user/gnome-venture/game/assets/img/scenes/trek-1-path.png'
OUT = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__scenes__trek-1-path.png'
CMP = '/home/user/gnome-venture/art-review/scenes/out/game__assets__img__scenes__trek-1-path-cmp.png'
im = Image.open(SRC)
a = np.array(im)
x0, y0, x1, y1 = 185, 64, 225, 90
box = a[y0:y1, x0:x1]
r, g, b = box[..., 0].astype(int), box[..., 1].astype(int), box[..., 2].astype(int)
bright = (r > 200) & (g > 170)            # yellow / cream sparkle pixels
for y, x in zip(*np.nonzero(bright)):
    Y, X = y + y0, x + x0
    # copy the nearest non-sparkle pixel in the same row (wall brown)
    for d in range(1, 12):
        for XX in (X - d, X + d):
            p = a[Y, XX]
            if not (p[0] > 200 and p[1] > 170) and int(p[0]) + int(p[1]) + int(p[2]) > 200:
                a[Y, X] = p; break
        else:
            continue
        break
new = Image.fromarray(a, im.mode)
new.save(OUT)
w, h = im.size
c = Image.new('RGBA', (w * 4 + 8, h * 2), (0, 0, 0, 255))
c.paste(im.convert('RGBA').resize((w * 2, h * 2), Image.NEAREST), (0, 0))
c.paste(new.convert('RGBA').resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
c.save(CMP)
