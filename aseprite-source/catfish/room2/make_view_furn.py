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
        # (a) anchor/origin consistency
        if s["origin"][1] + im.height != s["anchor"][1]: bad.append("origin.y")
        if s["origin"][0] + im.width // 2 != s["anchor"][0]: bad.append("origin.x")
        px = im.load()
        W, H = im.size
        # (c) floor sprites with a baked shadow: shadow reaches further right than the body in the last 4 rows
        if s["kind"] == "floor" and s.get("shadow"):
            sh_r = body_r = -1
            for y in range(H - 4, H):
                for x in range(W):
                    p = px[x, y]
                    if p[3]:
                        if p[:3] == (0x9a, 0x6b, 0x3f): sh_r = max(sh_r, x)
                        else: body_r = max(body_r, x)
            print("   (c) %s shadow right %d vs body right %d" % (k, sh_r, body_r))
            if not sh_r > body_r: bad.append("shadow not right of body")
        # (b) rug side lines meet the seam lines through the VP
        if k == "rug":
            ox, oy = s["origin"]
            for side, name in ((0, "left"), (1, "right")):
                def edge(y):
                    xs = [x for x in range(W) if px[x, y][3]]
                    return (xs[0] if side == 0 else xs[-1]) + ox
                xb, xt = edge(H - 1), edge(0)
                yb, yt = oy + H - 1, oy
                pred = xb + (240 - xb) * (yb - yt) / (yb + 83.0)
                print("   (b) rug %s bottom %d top %d predicted %.1f" % (name, xb, xt, pred))
                if abs(pred - xt) > 1.5: bad.append("rug %s side off %.1f" % (name, pred - xt))
        # (d) pinholes / stray outline px on the half grid
        if s["kind"] != "floor-decal":
            hw, hh = W // 2, H // 2
            def op(x, y): return 0 <= x < hw and 0 <= y < hh and px[2 * x, 2 * y][3] > 0
            OL = {(0x2a, 0x1a, 0x10), (0x4a, 0x2c, 0x1a), (0x74, 0x46, 0x2a)}
            pin, stray = [], []
            for y in range(hh):
                for x in range(hw):
                    nb = [(x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))]
                    n = sum(op(*q) for q in nb)
                    if not op(x, y):
                        if sum(op(*q) and px[2 * q[0], 2 * q[1]][:3] != (0x9a, 0x6b, 0x3f) for q in nb) >= 3: pin.append((x, y))
                    elif px[2 * x, 2 * y][:3] in OL and n <= 1 and not any(op(*q) and px[2 * q[0], 2 * q[1]][:3] not in OL for q in nb):
                        stray.append((x, y))
            if pin: bad.append("pinholes %s" % pin)
            if stray: bad.append("strays %s" % stray)
        # (e) speckle cap: opaque half-grid px whose 4 neighbours are all opaque and all a different colour
        LIM = {"cushion": 41, "bowl-plain": 10, "bowl": 15, "rug": 60, "toybox": 24, "cattree": 17, "scratch": 16, "plant": 10}.get(k, 8)
        hw, hh = W // 2, H // 2
        def hc(x, y): return px[2 * x, 2 * y][:3] if 0 <= x < hw and 0 <= y < hh and px[2 * x, 2 * y][3] else None
        spk = 0
        for y in range(hh):
            for x in range(hw):
                c0 = hc(x, y)
                if c0 is None: continue
                nb = [hc(x + 1, y), hc(x - 1, y), hc(x, y + 1), hc(x, y - 1)]
                if all(n is not None and n != c0 for n in nb): spk += 1
        print("   (e) %s speckle %d / %d" % (k, spk, LIM))
        if spk > LIM: bad.append("speckle %d>%d" % (spk, LIM))
        # (f) outline side: lit left outline is light umber, lower-right is dark
        OS = {"cattree": [((0, 48), (0x74, 0x46, 0x2a)), ((25, 49), (0x2a, 0x1a, 0x10))],
              "scratch": [((0, 31), (0x74, 0x46, 0x2a)), ((13, 31), (0x2a, 0x1a, 0x10))],
              "plant": [((2, 24), (0x74, 0x46, 0x2a))]}.get(k, [])
        for (hx, hy), want in OS:
            got = hc(hx, hy)
            print("   (f) %s (%d,%d) %s want %s" % (k, hx, hy, "#%02x%02x%02x" % got if got else None, "#%02x%02x%02x" % want))
            if got != want and "outline side" not in bad: bad.append("outline side")
        print("%-11s %s %2d cols bbox=%s %s" % (k, im.size, len(cols), bb, ",".join(bad) or "ok"))
        ok = ok and not bad
    return ok

def scene(rv):
    R = os.path.join(HERE, "out_room")
    im = Image.new("RGBA", (480, 270), (0, 0, 0, 255))
    for n in ("p0-sky", "p1-wall", "p2-floor", "p5-sunbeam", "window"):
        pl = Image.open(os.path.join(R, "cf-room2-%s.png" % n)).convert("RGBA")
        im.alpha_composite(pl.crop((0, 0, min(480, pl.width), min(270, pl.height))) if pl.size != (480, 270) else pl)
    cat = Image.open(CAT).convert("RGBA")
    objs = []
    for k, s in J.items():
        if k in ("bowl-plain", "petbell", "yarnpatch"): continue
        ox, oy = s["origin"]
        objs.append((s["z"] - (1000 if s.get("under_cats") else 0), 0, load(k), ox, oy))
    for u, dd in ((.5, .05), (.5, .5), (.45, .85)):
        x, y, sc = model(u, dd)
        sc = round(sc * 16) / 16
        n = round(64 * sc)
        c = cat.resize((n, n), Image.NEAREST)
        objs.append((y, 1, c, int(round(x - 33 * sc)), int(round(y - 60 * sc))))
    for z, t, spr, ox, oy in sorted(objs, key=lambda o: (o[0], o[1])):
        im.alpha_composite(spr.crop((max(0, -ox), max(0, -oy), min(spr.width, 480 - ox), min(spr.height, 270 - oy))), (max(0, ox), max(0, oy)))
    f4 = Image.open(os.path.join(R, "cf-room2-p4-front.png")).convert("RGBA")
    im.alpha_composite(f4.crop((4, 0, min(f4.width, 484), min(f4.height, 270))), (0, 0))   # pasted at (-4, 0)
    im = im.convert("RGB")
    im.resize((960, 540), Image.NEAREST).save(os.path.join(rv, "scene_2x.png"))
    im.resize((240, 135), Image.NEAREST).resize((480, 270), Image.NEAREST).save(os.path.join(rv, "scene_half2x.png"))

def review():
    rv = os.path.join(VIEW, "review"); os.makedirs(rv, exist_ok=True)
    for k in J:
        im = load(k)
        bg = Image.new("RGBA", im.size, (199, 141, 82, 255)); bg.alpha_composite(im)
        sc = 8 if im.width < 60 else 4
        bg.convert("RGB").resize((im.width * sc, im.height * sc), Image.NEAREST).save(os.path.join(rv, "%s_%dx.png" % (k, sc)))
        h = bg.resize((max(1, im.width // 2), max(1, im.height // 2)), Image.NEAREST)
        h.convert("RGB").resize((h.width * 2, h.height * 2), Image.NEAREST).save(os.path.join(rv, k + "_half2x.png"))
    scene(rv)
    pv = Image.open(os.path.join(VIEW, "preview.png"))
    pv.resize((pv.width // 2, pv.height // 2), Image.NEAREST).save(os.path.join(VIEW, "preview_half.png"))

if __name__ == "__main__":
    sheet(1, os.path.join(VIEW, "sheet_1x.png"))
    sheet(2, os.path.join(VIEW, "sheet_2x.png"))
    preview(os.path.join(VIEW, "preview.png"))
    review()
    sys.exit(0 if checks() else 1)
