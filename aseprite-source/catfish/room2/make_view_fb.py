# previews for cf_run_fb (python3 + PIL): per view 1x strip on cream, 4x with baseline, 0.5x, 0.42x-scaled nearest, GIF at 4x
from PIL import Image, ImageDraw
import os
here = os.path.dirname(os.path.abspath(__file__)); O = here + "/out_fb/"; V = O + "_view/"
os.makedirs(V, exist_ok=True)
CREAM = (245, 236, 215, 255)
def on_bg(im, bg=CREAM):
    b = Image.new("RGBA", im.size, bg); b.alpha_composite(im); return b
for view in ("toward", "away"):
    fr = [Image.open(O + "cf-cat-grey-run%s%02d.png" % (view, i)).convert("RGBA") for i in range(1, 9)]
    strip = Image.new("RGBA", (512, 64), CREAM)
    for i, f in enumerate(fr): strip.alpha_composite(f, (i * 64, 0))
    strip.save(V + "%s_strip_1x.png" % view)
    s4 = strip.resize((2048, 256), Image.NEAREST)
    d = ImageDraw.Draw(s4)
    d.line([(0, 55 * 4 + 3), (2048, 55 * 4 + 3)], fill=(255, 0, 0, 255), width=1)
    for i in range(1, 8): d.line([(i * 256, 0), (i * 256, 256)], fill=(180, 180, 180, 255))
    s4.save(V + "%s_strip_4x.png" % view)
    strip.resize((256, 32), Image.NEAREST).save(V + "%s_strip_0.5x.png" % view)
    # 0.42x scale (27x27) shown back at 2x per frame (nearest) so it is viewable
    small = [f.resize((27, 27), Image.NEAREST) for f in fr]
    s42 = Image.new("RGBA", (27 * 8, 27), CREAM)
    for i, f in enumerate(small): s42.alpha_composite(on_bg(f), (i * 27, 0))
    s42.save(V + "%s_strip_0.42x.png" % view)
    s42.resize((27 * 8 * 4, 27 * 4), Image.NEAREST).save(V + "%s_strip_0.42x_view4.png" % view)
    g = [on_bg(f.resize((256, 256), Image.NEAREST)).convert("P", palette=Image.ADAPTIVE) for f in fr]
    g[0].save(V + "run%s.gif" % view, save_all=True, append_images=g[1:], duration=70, loop=0, disposal=2)
print("views ok")
