# previews for cf_run80 (python3 + PIL): strip 1x on cream, 4x, 0.5x, GIF
from PIL import Image, ImageDraw
import os
here = os.path.dirname(os.path.abspath(__file__)); O = here + "/out80/"; V = O + "_view/"
os.makedirs(V, exist_ok=True)
CREAM = (245, 236, 215, 255)
fr = [Image.open(O + "cf-cat-grey-run%02d.png" % i).convert("RGBA") for i in range(1, 11)]
def on_bg(im, bg=CREAM):
    b = Image.new("RGBA", im.size, bg); b.alpha_composite(im); return b
strip = Image.new("RGBA", (800, 64), CREAM)
for i, f in enumerate(fr): strip.alpha_composite(f, (i * 80, 0))
strip.save(V + "strip_1x.png")
s4 = strip.resize((3200, 256), Image.NEAREST)
d = ImageDraw.Draw(s4)
d.line([(0, 55 * 4 + 3), (3200, 55 * 4 + 3)], fill=(255, 0, 0, 255), width=1)
for i in range(1, 10): d.line([(i * 320, 0), (i * 320, 256)], fill=(180, 180, 180, 255))
s4.save(V + "strip_4x.png")
strip.resize((400, 32), Image.NEAREST).save(V + "strip_0.5x.png")
g = [on_bg(f.resize((320, 256), Image.NEAREST)).convert("P", palette=Image.ADAPTIVE) for f in fr]
g[0].save(V + "run80.gif", save_all=True, append_images=g[1:], duration=125, loop=0, disposal=2)
print("views ok")
