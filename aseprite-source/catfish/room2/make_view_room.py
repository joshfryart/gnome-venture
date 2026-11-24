# previews for cf_room_a (python3 + PIL): stacks the plates, cats at depth d, 1x / 2x / 0.5x, night
import json, os
from PIL import Image
here = os.path.dirname(os.path.abspath(__file__)); O = here + "/out_room/"
CAT = "/home/user/gnome-venture/game/assets/img/catfish/cf-cat-grey-idleA.png"
def ld(n): return Image.open(O + n + ".png").convert("RGBA")
def persp(u, d): return 240 + (u - .5) * 720 * (1 - .45 * d), 268 - 158 * d ** .8, 1 - .58 * d
def room(night=False, cats=()):
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
    f = ld("cf-room2-p4-front"); big = Image.new("RGBA", (480, 270), (0, 0, 0, 0)); big.paste(f, (-4, 0), f); im.alpha_composite(big)
    if night:
        t = Image.new("RGBA", (480, 270), (0x29, 0x1d, 0x4a, round(.40 * 255)))
        im.alpha_composite(t); im.alpha_composite(ld("cf-room2-p5b-night"))
    return im
plain = room()
card = room(cats=[(u, d) for d in (.1, .5, .9) for u in (.2, .5, .8)])
three = room(cats=[(.5, 0), (.5, .5), (.5, 1)])
night = room(True, cats=[(.5, .5)])
W = 960
sheet = Image.new("RGBA", (W, 270 + 540 + 135 + 4), (245, 236, 215, 255))
sheet.paste(plain, (0, 0)); sheet.paste(card, (480, 0))
sheet.paste(three.resize((960, 540), Image.NEAREST), (0, 274))
sheet.paste(card.resize((240, 135), Image.NEAREST), (0, 818)); sheet.paste(three.resize((240, 135), Image.NEAREST), (250, 818))
sheet.paste(night.resize((240, 135), Image.NEAREST), (500, 818))
sheet.save(O + "cf-room2-preview.png")
night.resize((960, 540), Image.NEAREST).save(O + "cf-room2-preview-night.png")
card.resize((960, 540), Image.NEAREST).save(O + "cf-room2-preview-cats2x.png")
print("preview ok")
