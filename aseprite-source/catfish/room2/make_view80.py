# previews for cf_run80 (python3 + PIL): strip 1x on cream, 4x, 0.5x, GIF
from PIL import Image, ImageDraw
import os
here = os.path.dirname(os.path.abspath(__file__)); O = here + "/out80/"; V = O + "_view/"
os.makedirs(V, exist_ok=True)
CREAM = (245, 236, 215, 255)
fr = [Image.open(O + "cf-cat-grey-run%02d.png" % i).convert("RGBA") for i in range(1, 13)]
def on_bg(im, bg=CREAM):
    b = Image.new("RGBA", im.size, bg); b.alpha_composite(im); return b
strip = Image.new("RGBA", (960, 64), CREAM)
for i, f in enumerate(fr): strip.alpha_composite(f, (i * 80, 0))
strip.save(V + "strip_1x.png")
s4 = strip.resize((3840, 256), Image.NEAREST)
d = ImageDraw.Draw(s4)
d.line([(0, 55 * 4 + 3), (3840, 55 * 4 + 3)], fill=(255, 0, 0, 255), width=1)
for i in range(1, 12): d.line([(i * 320, 0), (i * 320, 256)], fill=(180, 180, 180, 255))
s4.save(V + "strip_4x.png")
strip.resize((400, 32), Image.NEAREST).save(V + "strip_0.5x.png")
g = [on_bg(f.resize((320, 256), Image.NEAREST)).convert("P", palette=Image.ADAPTIVE) for f in fr]
g[0].save(V + "run80.gif", save_all=True, append_images=g[1:], duration=60, loop=0, disposal=2)
# ladder_shadow: each rung = frame nearest-scaled + the matching ground shadow centred at (round(35*s), round(54.5*s)); 4x, red y=55 line
BGS = (200, 190, 168, 255)
SH = {1: 1, .875: 2, .75: 2, .625: 3, .5: 3, .42: 4}
rungs = [1, .875, .75, .625, .5, .42]
Z = 4; rowh = [round(64 * s) * Z for s in rungs]
lad = Image.new("RGBA", (80 * Z * 12, sum(rowh)), BGS)
y0 = 0
for s, rh in zip(rungs, rowh):
    sh = Image.open(os.path.join(here, "out_props", "cf-shadow-%d.png" % SH[s])).convert("RGBA")
    cw, ch = round(80 * s), round(64 * s)
    for i, f in enumerate(fr):
        cell = Image.new("RGBA", (cw, ch), BGS)
        cx, cy = round(35 * s), round(54.5 * s)
        cell.alpha_composite(sh, (cx - sh.size[0] // 2, cy - sh.size[1] // 2))
        cell.alpha_composite(f.resize((cw, ch), Image.NEAREST))
        lad.alpha_composite(cell.resize((cw * Z, ch * Z), Image.NEAREST), (i * 80 * Z, y0))
    ImageDraw.Draw(lad).line([(0, y0 + round(55 * s) * Z + Z // 2), (80 * Z * 12, y0 + round(55 * s) * Z + Z // 2)], fill=(255, 0, 0, 255), width=1)
    y0 += rh
os.makedirs(V + "review", exist_ok=True)
lad.save(V + "review/ladder_shadow.png")
# half-size ladder (rung .5 etc. at 2x) for paw readability
lad2 = Image.new("RGBA", (80 * 2 * 12, sum(round(64 * s) * 2 for s in rungs)), BGS); yy = 0
for s in rungs:
    cw, ch = round(80 * s), round(64 * s)
    for i, f in enumerate(fr):
        lad2.alpha_composite(f.resize((cw, ch), Image.NEAREST).resize((cw * 2, ch * 2), Image.NEAREST), (i * 160, yy))
    yy += ch * 2
lad2.save(V + "review/ladder_2x.png")
# p2 review views
half = [f.resize((40, 32), Image.NEAREST) for f in fr]
hs = Image.new("RGBA", (40 * 6, 32 * 2), CREAM)
for i, h in enumerate(half): hs.alpha_composite(h, ((i % 6) * 40, (i // 6) * 32))
hs.resize((240 * 6, 64 * 6), Image.NEAREST).save(V + "review/p2_half_x6.png")
import re
src = open(os.path.join(here, "cf_run80.lua")).read()
HEAD = {}
for i, m in enumerate(re.finditer(r"head=\{(\d+),(\d+)\}", src)): HEAD[i + 1] = (int(m.group(1)) , int(m.group(2)))
S5 = {}
for i, m in enumerate(re.finditer(r"S=\{(\d+),", src)): S5[i + 1] = int(m.group(1))
tiles = []
for f in (1, 5, 10):
    hx, hy = S5[f] + 9, HEAD[f][1]
    tiles.append(on_bg(fr[f - 1]).crop((hx - 14, hy - 16, hx + 16, hy + 8)).resize((30 * 14, 24 * 14), Image.NEAREST))
hd = Image.new("RGBA", (30 * 14 * 3 + 20, 24 * 14), (60, 60, 60, 255))
for i, t in enumerate(tiles): hd.paste(t, (i * (30 * 14 + 10), 0))
hd.save(V + "review/p2_heads_14x.png")
print("views ok")
# p3 texture review views
R = V + "review/"
def grid(imgs, scale, bg=CREAM):
    w, h = imgs[0].size
    g = Image.new("RGBA", (w * 6, h * 2), bg)
    for i, im in enumerate(imgs): g.alpha_composite(im, ((i % 6) * w, (i // 6) * h))
    return g.resize((w * 6 * scale, h * 2 * scale), Image.NEAREST)
grid(fr, 4).save(R + "p3_grey_4x.png")
grid(half, 6).save(R + "p3_half_x6.png")
for n in (1, 5, 10): on_bg(fr[n - 1]).resize((800, 640), Image.NEAREST).save(R + "p3_f%02d_10x.png" % n)
ref = [Image.open(O + "_view/review/p2_ref/cf-cat-grey-run%02d.png" % i).convert("RGBA") for i in range(1, 13)]
diffs = []
for a, b in zip(fr, ref):
    d = Image.new("RGBA", a.size, (128, 128, 128, 255))
    pa, pb, pd = a.load(), b.load(), d.load()
    for y in range(a.size[1]):
        for x in range(a.size[0]):
            if pa[x, y] != pb[x, y]: pd[x, y] = (255, 0, 0, 255)
    diffs.append(d)
grid(diffs, 4, (128, 128, 128, 255)).save(R + "p3_tex_diff.png")
print("p3 views ok")
