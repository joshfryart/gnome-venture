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
strip.resize((40 * N, 32), Image.NEAREST).resize((160 * N, 128), Image.NEAREST).save(V + "strip_half_x4.png")
g = [on_bg(f.resize((320, 256), Image.NEAREST)).convert("P", palette=Image.ADAPTIVE) for f in fr]
g[0].save(V + "zoom.gif", save_all=True, append_images=g[1:], duration=50, loop=0, disposal=2)
# GIF with fx: dust at planted paws (parsed from the Lua), streaks behind the cat
def z8(i, name):
    b = Image.new("RGBA", (80, 64), CREAM); b.alpha_composite(fr[i])
    b = b.resize((640, 512), Image.NEAREST)
    gl = Image.new("RGBA", b.size, (0, 0, 0, 0)); gd = ImageDraw.Draw(gl)
    for k in range(0, 80, 5): gd.line([(k * 8, 0), (k * 8, 511)], fill=(255, 0, 0, 90))
    for k in range(0, 64, 5): gd.line([(0, k * 8), (639, k * 8)], fill=(255, 0, 0, 90))
    b.alpha_composite(gl); b.save(V + name)
z8(2, "z3_8x.png"); z8(4, "z5_8x.png")
import re
lua = open(here + "/cf_zoom.lua").read()
P = here + "/out_props/"
if os.path.exists(P + "cf-dust-1.png") and os.path.exists(P + "cf-streak-1.png"):
    dust = [Image.open(P + "cf-dust-%d.png" % i).convert("RGBA") for i in range(1, 5)]
    streak = [Image.open(P + "cf-streak-%d.png" % i).convert("RGBA") for i in range(1, 4)]
    pose = [tuple(map(int, m)) for m in re.findall(r"\{ BY=(\d+), L=(\d+)", lua)]
    bx = int(re.search(r"local BX = (\d+)", lua).group(1))
    planted = {}
    for k, m in enumerate(re.finditer(r"\{ nf=\{(\d+),(\d+)\}, ff=\{(\d+),(\d+)\}, nh=\{\{(\d+),(\d+)\},\{(\d+),(\d+)\}\}, fh=\{\{(\d+),(\d+)\},\{(\d+),(\d+)\}\} \}", lua)):
        v_ = list(map(int, m.groups()))
        cand = [(v_[0], v_[1]), (v_[2], v_[3]), (v_[6], v_[7]), (v_[10], v_[11])]
        planted[k + 1] = [c for c in cand if c[1] == 53]
    out = []
    for i, f in enumerate(fr):
        im = Image.new("RGBA", (80, 64), CREAM)
        k = i + 1
        BY, L = pose[i]
        rear = bx - L // 2
        sx = max(0, rear - 30)
        im.alpha_composite(streak[i % 3], (sx, BY - 6))
        im.alpha_composite(streak[(i + 1) % 3], (sx, BY + 2))
        for (x, y) in planted.get(k, []):
            im.alpha_composite(dust[min(3, i % 4)], (x - 19, 55 - 14))
        im.alpha_composite(f)
        out.append(im.resize((320, 256), Image.NEAREST).convert("P", palette=Image.ADAPTIVE))
    out[0].save(V + "zoom_fx.gif", save_all=True, append_images=out[1:], duration=50, loop=0, disposal=2)
else:
    print("out_props fx not found: skipped zoom_fx.gif")
# compare with run80 f06 vs zoom Z3 at 4x, red ground line at y 55
rp = here + "/out80/"
cand = [x for x in sorted(os.listdir(rp)) if x.startswith("cf-cat-grey-run") and "06" in x] if os.path.isdir(rp) else []
if cand:
    a = Image.open(rp + cand[0]).convert("RGBA"); b = fr[2]
    cmp_ = Image.new("RGBA", (160, 64), CREAM)
    cmp_.alpha_composite(a.resize(a.size) if a.size == (80, 64) else a.crop((0, 0, 80, 64)), (0, 0)); cmp_.alpha_composite(b, (80, 0))
    cmp_ = cmp_.resize((640, 256), Image.NEAREST)
    ImageDraw.Draw(cmp_).line([(0, 55 * 4 + 3), (640, 55 * 4 + 3)], fill=(255, 0, 0, 255), width=1)
    cmp_.save(V + "compare_run_zoom.png")
else:
    print("run80 f06 not found: skipped compare")
# neigh_3x: cross-group read check, bottom-aligned at 3x on cream (400x64 at 1x)
H = here + "/../"
def _find(paths):
    for p_ in paths:
        if os.path.exists(p_): return Image.open(p_).convert("RGBA")
    return None
def _crop(im):
    return im
items = [(0, _find([here + "/out/cf-cat-grey-idleA.png", here + "/../out/cf-cat-grey-idleA.png", here + "/out_toward/cf-cat-grey-idleA.png"] + [os.path.join(dp, "cf-cat-grey-idleA.png") for dp, dn, fn in os.walk(H) if "cf-cat-grey-idleA.png" in fn][:1])),
         (68, _find([os.path.join(dp, "cf-cat-grey-jump.png") for dp, dn, fn in os.walk(H) if "cf-cat-grey-jump.png" in fn][:1])),
         (136, _find([here + "/out80/cf-cat-grey-run06.png"])),
         (220, fr[2]), (304, fr[4])]
nb = Image.new("RGBA", (400, 64), CREAM)
for x0, im in items:
    if im is None: print("neigh: missing sprite at x", x0); continue
    nb.alpha_composite(im, (x0, 64 - im.size[1]))
nb.resize((1200, 192), Image.NEAREST).save(V + "neigh_3x.png")
print("views ok")
