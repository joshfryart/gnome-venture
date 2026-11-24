# previews for cf_zoom (python3 + PIL): strip 1x on cream, 4x, 0.5x, GIF at 4x, optional GIF with fx from out_props/
from PIL import Image, ImageDraw
import os
here = os.path.dirname(os.path.abspath(__file__)); O = here + "/out_zoom/"; V = O + "_view/"
os.makedirs(V, exist_ok=True)
CREAM = (245, 236, 215, 255); N = 6
fr = [Image.open(O + "cf-cat-grey-zoom%02d.png" % i).convert("RGBA") for i in range(1, N + 1)]
def on_bg(im, bg=CREAM):
    b = Image.new("RGBA", im.size, bg); b.alpha_composite(im); return b
strip = Image.new("RGBA", (80 * N, 64), CREAM)
for i, f in enumerate(fr): strip.alpha_composite(f, (i * 80, 0))
strip.save(V + "strip_1x.png")
s4 = strip.resize((320 * N, 256), Image.NEAREST)
d = ImageDraw.Draw(s4)
d.line([(0, 55 * 4 + 3), (320 * N, 55 * 4 + 3)], fill=(255, 0, 0, 255), width=1)
for i in range(1, N): d.line([(i * 320, 0), (i * 320, 256)], fill=(180, 180, 180, 255))
s4.save(V + "strip_4x.png")
strip.resize((40 * N, 32), Image.NEAREST).save(V + "strip_0.5x.png")
g = [on_bg(f.resize((320, 256), Image.NEAREST)).convert("P", palette=Image.ADAPTIVE) for f in fr]
g[0].save(V + "zoom.gif", save_all=True, append_images=g[1:], duration=50, loop=0, disposal=2)
# GIF with fx: dust on Z1,Z2,Z4,Z5 (doubled Z6) at planted paws, streaks left of cat
P = here + "/out_props/"
if os.path.exists(P + "cf-fx-dust-1.png") and os.path.exists(P + "cf-fx-streak-1.png"):
    dust = [Image.open(P + "cf-fx-dust-%d.png" % i).convert("RGBA") for i in range(1, 5)]
    streak = [Image.open(P + "cf-fx-streak-%d.png" % i).convert("RGBA") for i in range(1, 4)]
    planted = {1: [(49, 53), (52, 53), (22, 53), (25, 53)], 2: [(16, 53), (20, 53)], 4: [(61, 53), (57, 53)],
               5: [(26, 53), (30, 53)], 6: [(65, 53), (61, 53)]}
    out = []
    for i, f in enumerate(fr):
        im = Image.new("RGBA", (80, 64), CREAM)
        k = i + 1
        im.alpha_composite(streak[i % 3], (0, 28 + (i % 2) * 6))
        im.alpha_composite(streak[(i + 1) % 3], (4, 38))
        for (x, y) in planted.get(k, []):
            if k in (1, 2, 4, 5, 6): im.alpha_composite(dust[min(3, i % 4)], (x - 19 + 4, y - 14))
        im.alpha_composite(f)
        out.append(im.resize((320, 256), Image.NEAREST).convert("P", palette=Image.ADAPTIVE))
    out[0].save(V + "zoom_fx.gif", save_all=True, append_images=out[1:], duration=50, loop=0, disposal=2)
else:
    print("out_props fx not found: skipped zoom_fx.gif")
print("views ok")
