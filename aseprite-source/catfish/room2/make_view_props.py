# previews + self-check for cf_props_room2.lua (python3 + PIL). Writes out_props/_view/.
from PIL import Image, ImageDraw
import os, json, sys
here = os.path.dirname(os.path.abspath(__file__)); O = here + "/out_props/"; V = O + "_view/"
IMG = os.path.abspath(here + "/../../../game/assets/img/catfish/") + "/"
os.makedirs(V, exist_ok=True)
CREAM = (245, 236, 215, 255)

def load(n): return Image.open(O + n + ".png").convert("RGBA")
def on_bg(im, bg=CREAM):
    b = Image.new("RGBA", im.size, bg); b.alpha_composite(im); return b

def strip_rows(rows, pad=4, bg=CREAM):
    """rows: list of lists of images, laid left to right, bottom aligned per row."""
    rh = [max(i.height for i in r) + pad * 2 for r in rows]
    W = max(sum(i.width + pad for i in r) + pad for r in rows)
    s = Image.new("RGBA", (W, sum(rh)), bg)
    y = 0
    for r, h in zip(rows, rh):
        x = pad
        for i in r:
            s.alpha_composite(i, (x, y + h - pad - i.height)); x += i.width + pad
        y += h
    return s

def emit(name, sheet, zooms=(1, 4, 0.5)):
    for z in zooms:
        w, h = max(1, int(sheet.width * z)), max(1, int(sheet.height * z))
        sheet.resize((w, h), Image.NEAREST).save(V + "%s_%sx.png" % (name, z))

# ---- lures
rows = [[load("cf-lure-%s-%d" % (s, n)) for n in range(1, 7)] for s in ("near", "mid", "far")]
emit("lures", strip_rows(rows))
# lures composited at 3 sizes on the room floor (4x crop of the bottom-left 120x60)
room = Image.open(IMG + "cf-room.png").convert("RGBA")
fl = room.crop((100, 120, 250, 200)).copy()
canvas = Image.new("RGBA", (6 * 34 + 4, 3 * 40 + 4), CREAM)
sheet = Image.new("RGBA", (fl.width * 1, fl.height * 3), CREAM)
out = Image.new("RGBA", (6 * 34 + 8, 3 * 34 + 8))
tile = Image.new("RGBA", (6 * 34 + 8, 3 * 34 + 8))
for ry, s in enumerate(("near", "mid", "far")):
    for n in range(6):
        bgc = room.crop((120 + n * 30, 140, 120 + n * 30 + 34, 140 + 34))
        im = load("cf-lure-%s-%d" % (s, n + 1))
        b = bgc.copy(); b.alpha_composite(im, (17 - im.width // 2, 28 - im.height + (3 if s == "near" else 2)))
        tile.alpha_composite(b, (4 + n * 34, 4 + ry * 34))
emit("lures_floor", tile.convert("RGBA"), zooms=(1, 4, 0.5))

# ---- wand (with a drawn string to a fish for the read) + cf-rod.png for comparison
wj = json.load(open(O + "cf-wand-cast.json"))
wr = []
for fr in wj["frames"]:
    im = on_bg(load(fr["file"][:-4]))
    d = ImageDraw.Draw(im); ax, ay = fr["attach"]
    d.line([(ax, ay), (ax, ay + 8)], fill=(74, 44, 26, 255))
    d.point((ax, ay), fill=(255, 0, 0, 255))
    wr.append(im)
wr.append(on_bg(Image.open(IMG + "cf-rod.png").convert("RGBA")))
emit("wand", strip_rows([wr]))

# ---- shadows at 35% under a cat sprite (scale ladder: nearest rung)
cat = Image.open(IMG + "cf-cat-grey-idleA.png").convert("RGBA")
bb = cat.getbbox(); paw = bb[3] - 3
pieces = []
for i, sc in enumerate((1, .75, .5, .42), 1):
    sh = load("cf-shadow-%d" % i)
    c2 = cat.resize((max(1, round(cat.width * sc)), max(1, round(cat.height * sc))), Image.NEAREST)
    pawy = round(paw * sc)
    pane = Image.new("RGBA", (64, 80), CREAM)
    a = sh.split()[3].point(lambda v: int(v * 0.35))
    shp = sh.copy(); shp.putalpha(a)
    cx = 32; pane.alpha_composite(shp, (cx - sh.width // 2, 66 - sh.height // 2))
    pane.alpha_composite(c2, (cx - c2.width // 2, 66 - pawy))
    pieces.append(pane)
shs = [on_bg(load("cf-shadow-%d" % i)) for i in range(1, 5)]
emit("shadow", strip_rows([pieces, shs]))

# ---- fx
dust = [load("cf-dust-%d" % n) for n in range(1, 5)]
stk = [load("cf-streak-%d" % n) for n in range(1, 4)]
dark = (120, 100, 80, 255)
emit("fx", strip_rows([dust, stk]))
emit("fx_dark", strip_rows([dust, stk], bg=dark))

# ---- self-check
bad = []
for f in sorted(os.listdir(O)):
    if not f.endswith(".png"): continue
    im = Image.open(O + f).convert("RGBA"); px = im.load(); W, H = im.size
    cols = set(); blk = 0
    for y in range(H):
        for x in range(W):
            r, g, b, a = px[x, y]
            if a not in (0, 255): bad.append(f + " semi")
            if a:
                cols.add((r, g, b))
                if (r, g, b) == (0, 0, 0): blk += 1
    sticker = f.startswith(("cf-lure", "cf-wand"))
    if len(cols) > 16: bad.append("%s colours %d" % (f, len(cols)))
    if sticker is False and blk: bad.append(f + " has black")
    if sticker:
        edge = [px[x, y] for x in range(W) for y in (H - 1,)] + [px[x, y] for y in range(H) for x in (0, W - 1)]
        if not f.startswith("cf-wand"): edge += [px[x, 0] for x in range(W)]
        if any(p[3] and p[:3] != (0, 0, 0) for p in edge): bad.append(f + " art on frame edge")
print("checks:", "PASS" if not bad else bad)
