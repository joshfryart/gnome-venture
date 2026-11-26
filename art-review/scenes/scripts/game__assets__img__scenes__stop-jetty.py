"""Remove the three baked-in gulls from the sky of stop-jetty; sky bands are flat rows."""
from collections import Counter
from PIL import Image
import numpy as np

SRC = "/home/user/gnome-venture/game/assets/img/scenes/stop-jetty.png"
OUT = "/home/user/gnome-venture/art-review/scenes/out/game__assets__img__scenes__stop-jetty.png"
CMP = "/home/user/gnome-venture/art-review/scenes/out/game__assets__img__scenes__stop-jetty-cmp.png"
BIRD = (91, 100, 112, 255)
BOXES = [(220, 32, 250, 46), (188, 44, 218, 58), (436, 56, 466, 70)]

im = Image.open(SRC)
a = np.array(im)
for x0, y0, x1, y1 in BOXES:
    for y in range(y0, y1):
        row = [tuple(p) for p in a[y, x0 - 6:x1 + 6]]
        others = [p for p in row if p != BIRD]
        fill = Counter(others).most_common(1)[0][0]
        for x in range(x0, x1):
            if tuple(a[y, x]) == BIRD:
                a[y, x] = fill
out = Image.fromarray(a, im.mode)
assert out.size == im.size
out.save(OUT)
w, h = im.size
c = Image.new(im.mode, (w * 4 + 8, h * 2), (0, 0, 0, 255))
c.paste(im.resize((w * 2, h * 2), Image.NEAREST), (0, 0))
c.paste(out.resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
c.save(CMP)
