#!/usr/bin/env python3
"""Contact sheets + floor preview for room2/out_furn (run after cf_room_a_furn.lua).
Writes out_furn/_view/sheet_1x.png (cream), sheet_2x.png, preview.png (480x270), preview_2x.png, and checks."""
import json, os, sys
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out_furn")
VIEW = os.path.join(OUT, "_view")
CAT = os.path.join(HERE, "..", "..", "..", "game", "assets", "img", "catfish", "cf-cat-grey-idleA.png")
os.makedirs(VIEW, exist_ok=True)
J = json.load(open(os.path.join(OUT, "furniture.json")))["sprites"]
CREAM = (241, 236, 224, 255)

def load(k): return Image.open(os.path.join(OUT, J[k]["file"])).convert("RGBA")

def sheet(scale, path):
    pad, x, y, rowh, W = 8, 8, 8, 0, 720
    items = list(J)
    pos = []
    for k in items:
        im = load(k); w, h = im.width * scale, im.height * scale
        if x + w + pad > W * scale // 1 and x > 8:
            x, y, rowh = 8, y + rowh + 22, 0
        pos.append((k, x, y, im)); x += w + pad + 6; rowh = max(rowh, h)
    H = y + rowh + 24
    sh = Image.new("RGBA", (W * scale if scale == 1 else W * 2 // 1 + 0, H), CREAM)
    d = ImageDraw.Draw(sh)
    for k, x, y, im in pos:
        big = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
        sh.alpha_composite(big, (x, y + 10))
        d.rectangle([x - 1, y + 9, x + big.width, y + 10 + big.height], outline=(200, 170, 120, 255))
        d.text((x, y), k, fill=(60, 40, 20, 255))
    sh.convert("RGB").save(path)

def floor_bg():
    im = Image.new("RGBA", (480, 270), (233, 217, 176, 255))
    px = im.load()
    for y in range(110, 270):
        for x in range(480):
            # board index from seams x_k(y)
            t = (268 - y) / 158.0
            k = -1
            for kk in range(18):
                xk = (-100 + 40 * kk) + (153 - 18 * kk) * t
                if x >= xk: k = kk
            # seams: x_k line at (k=0..17) between boards; board i is between seam i-1 and i
            seam = any(abs(x - ((-100 + 40 * kk) + (153 - 18 * kk) * t)) < 0.5 for kk in range(18))
            col = (199, 141, 82, 255) if (k + 1) % 2 == 0 else (176, 122, 69, 255)
            if seam: col = (138, 79, 42, 255) if y >= 178 else (154, 107, 63, 255)
            px[x, y] = col
    d = ImageDraw.Draw(im)
    d.rectangle([0, 82, 479, 99], fill=(154, 107, 63, 255))
    d.rectangle([0, 100, 479, 109], fill=(176, 122, 69, 255))
    d.rectangle([116, 64, 187, 109], fill=(176, 122, 69, 255))                 # bookshelf carcase
    d.rectangle([118, 66, 185, 108], fill=(138, 79, 42, 255))
    for sy in (80, 94): d.rectangle([116, sy, 187, sy + 1], fill=(217, 166, 96, 255))
    d.rectangle([296, 18, 395, 83], fill=(176, 122, 69, 255)); d.rectangle([304, 26, 387, 77], fill=(200, 232, 244, 255))
    d.rectangle([140, 22, 163, 51], fill=(176, 122, 69, 255))
    return im

def model(u, dd):
    y = 268 - 158 * dd ** 0.8
    x = 240 + (u - .5) * 720 * (1 - .45 * dd)
    return x, y, 1 - .58 * dd

def preview(path):
    bg = floor_bg()
    cat = Image.open(CAT).convert("RGBA")
    objs = []
    for k, s in J.items():
        im = load(k); ox, oy = s["origin"]
        z = s["z"] - (1000 if s.get("under_cats") else 0)
        objs.append((z, 0, k, im, ox, oy))
    # cats: (u, d) for scale comparison, drawn after furniture on ties
    for i, (u, dd) in enumerate([(0.24, 0.12), (0.55, 0.30), (0.50, 0.66), (0.30, 0.82), (0.70, 0.90), (0.62, 0.10)]):
        x, y, sc = model(u, dd)
        n = max(1, round(64 * sc / 4) * 4) if False else round(64 * sc)
        c = cat.resize((n, n), Image.NEAREST)
        objs.append((y, 1, "cat", c, int(x - n / 2), int(y - n * 61 / 64)))
    for z, tie, k, im, ox, oy in sorted(objs, key=lambda o: (o[0], o[1])):
        bg.alpha_composite(im, (ox, oy)) if 0 <= ox and 0 <= oy and ox + im.width <= 480 and oy + im.height <= 270 else \
            bg.alpha_composite(im.crop((max(0, -ox), max(0, -oy), min(im.width, 480 - ox), min(im.height, 270 - oy))), (max(0, ox), max(0, oy)))
    bg.convert("RGB").save(path)
    bg.convert("RGB").resize((960, 540), Image.NEAREST).save(path.replace(".png", "_2x.png"))

def checks():
    ok = True
    for k, s in J.items():
        im = load(k)
        a = [p[3] for p in im.getdata()]
        cols = {p[:3] for p in im.getdata() if p[3]}
        bad = []
        if im.size != tuple(s["size"]): bad.append("size")
        if any(0 < v < 255 for v in a): bad.append("semi")
        if len(cols) > 16: bad.append("cols %d" % len(cols))
        if (0, 0, 0) in cols or (255, 255, 255) in cols: bad.append("bw")
        bb = im.getbbox()
        # anchor vs model for floor items
        if s["kind"] == "floor" and not isinstance(s["u"], list):
            x, y, sc = model(s["u"], s["d"])
            if abs(x - s["anchor"][0]) > 4 or abs(y - s["anchor"][1]) > 4: bad.append("anchor off model %.0f,%.0f" % (x, y))
        print("%-11s %s %2d cols bbox=%s %s" % (k, im.size, len(cols), bb, ",".join(bad) or "ok"))
        ok = ok and not bad
    return ok

if __name__ == "__main__":
    sheet(1, os.path.join(VIEW, "sheet_1x.png"))
    sheet(2, os.path.join(VIEW, "sheet_2x.png"))
    preview(os.path.join(VIEW, "preview.png"))
    sys.exit(0 if checks() else 1)
