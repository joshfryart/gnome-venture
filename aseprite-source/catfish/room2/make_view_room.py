# previews for cf_room_a (python3 + PIL): stacks the plates, cats at depth d, 1x / 2x / 0.5x, night
import json, os
from PIL import Image
here = os.path.dirname(os.path.abspath(__file__)); O = here + "/out_room/"
CAT = "/home/user/gnome-venture/game/assets/img/catfish/cf-cat-grey-idleA.png"
def ld(n): return Image.open(O + n + ".png").convert("RGBA")
def persp(u, d): return 240 + (u - .5) * 720 * (1 - .45 * d), 268 - 158 * d ** .8, 1 - .58 * d
def room(night=False, cats=(), p4=True):
    im = Image.new("RGBA", (480, 270), (0, 0, 0, 255))
    im.alpha_composite(ld("cf-room2-p0n-night-sky" if night else "cf-room2-p0-sky"))
    for n in ("cf-room2-p1-wall", "cf-room2-p2-floor"): im.alpha_composite(ld(n))
    if not night: im.alpha_composite(ld("cf-room2-p5-sunbeam"))
    im.alpha_composite(ld("cf-room2-window"))
    cat = Image.open(CAT).convert("RGBA")
    for u, d in sorted(cats, key=lambda c: persp(*c)[1]):
        x, y, s = persp(u, d); s = max(1, round(s * 16)) / 16
        w = max(1, round(64 * s)); c = cat.resize((w, w), Image.NEAREST)
        bx = round(x - 33 * s)   # sprite foot centre (33, 60) is the anchor
        by = round(y - 60 * s)
        im.alpha_composite(c, (bx, by)) if bx >= 0 and by >= 0 and bx + w <= 480 else im.paste(c, (bx, by), c)
    im.alpha_composite(Image.new("RGBA", (480, 270), (0, 0, 0, 0)))
    if not p4: return im
    f = ld("cf-room2-p4-front"); big = Image.new("RGBA", (480, 270), (0, 0, 0, 0)); big.paste(f, (-4, 0), f); im.alpha_composite(big)
    if night:
        t = Image.new("RGBA", (480, 270), (0x29, 0x1d, 0x4a, round(.40 * 255)))
        im.alpha_composite(t); im.alpha_composite(ld("cf-room2-p5b-night"))
    return im
plain = room()
scene = room(p4=False)
_fj = json.load(open(here + "/out_furn/furniture.json"))
for sp in sorted(_fj["sprites"].values(), key=lambda q: q.get("z", 0)):
    fp = here + "/out_furn/" + sp["file"]
    if not os.path.exists(fp): continue
    o = sp["origin"]; ox, oy = (o["x"], o["y"]) if isinstance(o, dict) else o
    scene.alpha_composite(Image.open(fp).convert("RGBA"), (ox, oy)) if ox >= 0 and oy >= 0 else scene.paste(Image.open(fp).convert("RGBA"), (ox, oy), Image.open(fp).convert("RGBA"))
card = room(cats=[(u, d) for d in (.1, .5, .9) for u in (.2, .5, .8)])
three = room(cats=[(.5, 0), (.5, .5), (.5, 1)])
night = room(True, cats=[(.5, .5)])
W = 960
_th = room(cats=[(.5, 0), (.5, .5), (.5, 1)], p4=False)
_cats = Image.alpha_composite(scene, Image.new("RGBA", (480, 270), (0, 0, 0, 0)))
# cats from `three` only (difference vs the base room without cats)
_base = room(p4=False)
for _y in range(270):
    for _x in range(480):
        if _th.getpixel((_x, _y)) != _base.getpixel((_x, _y)): _cats.putpixel((_x, _y), _th.getpixel((_x, _y)))
_f = ld("cf-room2-p4-front"); _big = Image.new("RGBA", (480, 270), (0, 0, 0, 0)); _big.paste(_f, (-4, 0), _f); _cats.alpha_composite(_big)
_cats.resize((960, 540), Image.NEAREST).save(O + "cf-room2-scene-preview-2x.png")
os.makedirs(O + "_view/review", exist_ok=True)
_cats.resize((240, 135), Image.NEAREST).save(O + "_view/review/scene_half.png")
_cats.resize((1920, 1080), Image.NEAREST).save(O + "_view/review/scene4x.png")
# chair gap
_miny = min(y for y in range(270) for x in range(8, 36) if _big.getpixel((x, y))[3] > 0)
print("chair gap min opaque y (x8..35):", _miny); assert _miny >= 188
# fringe
_legR = _big.getpixel((2, 2 * 120 + 0))[:3] if False else (0x74, 0x46, 0x2a, 255)
for _x in range(296, 484):
    for _y in (266, 267): assert _f.getpixel((_x + 4, _y)) == _legR, (_x, _y, _f.getpixel((_x + 4, _y)))
for _x in range(302, 308):
    for _y in (260, 261): assert _f.getpixel((_x + 4, _y))[3] == 0, (_x, _y)
print("fringe ok")
# crosses
_w = ld("cf-room2-p1-wall")
def _gcomp(col):
    px = {(x, y) for y in range(3, 39) for x in range(21, 219) if _w.getpixel((2 * x, 2 * y))[:3] == col}
    seen, sizes = set(), []
    for p in px:
        if p in seen: continue
        st = [p]; seen.add(p); n = 0
        while st:
            a, b = st.pop(); n += 1
            for q in ((a+1,b),(a-1,b),(a,b+1),(a,b-1)):
                if q in px and q not in seen: seen.add(q); st.append(q)
        sizes.append(n)
    return sizes
_stubs = sum(1 for col in ((0xe8,0xcc,0x98),(0xdc,0xbc,0x88)) for n in _gcomp(col) if 1 <= n <= 4)
print("cross stubs:", _stubs); assert _stubs == 0
# light grain
_p2 = ld("cf-room2-p2-floor")
_L = {(x, y) for y in range(135) for x in range(240) if _p2.getpixel((2*x, 2*y))[:3] == (0xd9,0xa6,0x60)}
_D = {(x, y) for y in range(135) for x in range(240) if _p2.getpixel((2*x, 2*y))[:3] in ((0x9a,0x6b,0x3f),(0x8a,0x4f,0x2a))}
_seen, _bad = set(), 0
for p in _L:
    if p in _seen: continue
    st=[p]; _seen.add(p); comp=[]
    while st:
        a,b=st.pop(); comp.append((a,b))
        for dx in (-1,0,1):
            for dy in (-1,0,1):
                q=(a+dx,b+dy)
                if q in _L and q not in _seen: _seen.add(q); st.append(q)
    if len(comp) <= 3 and any((a+dx,b+dy) in _D for a,b in comp for dx in (-1,0,1) for dy in (-1,0,1)): _bad += 1
print("light grain bad comps:", _bad); assert _bad == 0
sheet = Image.new("RGBA", (W, 270 + 540 + 135 + 4), (245, 236, 215, 255))
sheet.paste(plain, (0, 0)); sheet.paste(card, (480, 0))
sheet.paste(three.resize((960, 540), Image.NEAREST), (0, 274))
sheet.paste(card.resize((240, 135), Image.NEAREST), (0, 818)); sheet.paste(three.resize((240, 135), Image.NEAREST), (250, 818))
sheet.paste(night.resize((240, 135), Image.NEAREST), (500, 818))
sheet.save(O + "cf-room2-preview.png")
night.resize((960, 540), Image.NEAREST).save(O + "cf-room2-preview-night.png")
card.resize((960, 540), Image.NEAREST).save(O + "cf-room2-preview-cats2x.png")
print("preview ok")

# perspective check: magenta rays from the camera VP (240,-83), cyan rays from the light VP (490,-83), at 2x
from PIL import ImageDraw
os.makedirs(O + "_view", exist_ok=True)
os.makedirs(O + "_view/review", exist_ok=True)
plain.resize((240, 135), Image.NEAREST).save(O + "_view/review/half.png")
plain.resize((1920, 1080), Image.NEAREST).save(O + "_view/review/plain4x.png")
pc = plain.resize((960, 540), Image.NEAREST); dr = ImageDraw.Draw(pc)
def ray(vp, thru, col, yend=269):
    (vx, vy), (tx, ty) = vp, thru
    k = (yend - vy) / (ty - vy)
    x0, y0 = vx + (tx - vx) * ((0 - vy) / (ty - vy)), 0
    dr.line([(2 * x0, 2 * y0), (2 * (vx + (tx - vx) * k), 2 * yend)], fill=col, width=1)
for k in range(18): ray((240, -83), (-100 + 40 * k, 268), (255, 0, 255, 255))
for p in ((54, 109), (99, 109), (387, 77)): ray((240, -83), p, (255, 0, 255, 255), p[1])
for x in (304, 345.5, 387): ray((490, -83), (x, 110), (0, 255, 255, 255), 180)
pc.save(O + "_view/cf-room2-persp-check.png")
print("persp-check ok")
