"""Remove the three baked-in birds from the sky of stop-tower.png.
Each bird pixel (dark purple 78,58,138) inside the sky box is replaced with the
flat sky-band colour of its own row, sampled just left of the box."""
from PIL import Image
import numpy as np

SRC = "/home/user/gnome-venture/game/assets/img/scenes/stop-tower.png"
OUT = "/home/user/gnome-venture/art-review/scenes/out/game__assets__img__scenes__stop-tower.png"
CMP = "/home/user/gnome-venture/art-review/scenes/out/game__assets__img__scenes__stop-tower-cmp.png"

im = Image.open(SRC)
mode = im.mode
a = np.array(im.convert("RGBA"))
orig = a.copy()
BIRD = np.array([78, 58, 138])
x0, x1, y0, y1 = 130, 205, 35, 70
for y in range(y0, y1):
    sky = a[y, x0 - 2].copy()
    for x in range(x0, x1):
        if (a[y, x, :3] == BIRD).all():
            a[y, x] = sky
assert not (a[y0:y1, x0:x1, :3] == BIRD).all(-1).any()
new = Image.fromarray(a, "RGBA").convert(mode)
new.save(OUT)
w, h = im.size
c = Image.new("RGBA", (w * 4 + 8, h * 2), (0, 0, 0, 255))
c.paste(Image.fromarray(orig).resize((w * 2, h * 2), Image.NEAREST), (0, 0))
c.paste(new.convert("RGBA").resize((w * 2, h * 2), Image.NEAREST), (w * 2 + 8, 0))
c.save(CMP)
print("changed px:", int((orig != a).any(-1).sum()))
