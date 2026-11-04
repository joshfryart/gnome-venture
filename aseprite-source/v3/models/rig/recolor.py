#!/usr/bin/env python3
"""Recolour the gnome-player rig by palette mapping (not multiply).

  python3 recolor.py --hat ef4a3b --tunic 3a86b0 --beard f5f0e6 --scarf f5b82e --boots 864c33 \
      --skin skinA|skinB|skinC|#hex [--trim gold] [--frame N] [--scale S] out.png
  python3 recolor.py --verify            # default recolour vs ../gnome-player.png
  python3 recolor.py --preview preview.png

Each role takes a preset name from rig.json (e.g. "ember red", skinB) or a hex base colour (ramp built
by the recipe below). Omitted roles use their "default" preset = the colours the gnome was drawn with.
Same maths as recolor.js.
"""
import argparse, json, math, os, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
RIG = json.load(open(os.path.join(HERE, "rig.json")))
TONES = ("hi", "base", "shade", "deep")


def _hex(h):
    h = h.lstrip("#")
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)


def _rgb2hsl(r, g, b):
    r, g, b = r / 255, g / 255, b / 255
    mx, mn = max(r, g, b), min(r, g, b)
    l = (mx + mn) / 2
    if mx == mn:
        return 0.0, 0.0, l
    d = mx - mn
    s = d / (2 - mx - mn) if l > 0.5 else d / (mx + mn)
    if mx == r:
        h = (g - b) / d + (6 if g < b else 0)
    elif mx == g:
        h = (b - r) / d + 2
    else:
        h = (r - g) / d + 4
    return h * 60, s, l


def _h2c(p, q, t):
    if t < 0: t += 1
    if t > 1: t -= 1
    if t < 1 / 6: return p + (q - p) * 6 * t
    if t < 1 / 2: return q
    if t < 2 / 3: return p + (q - p) * (2 / 3 - t) * 6
    return p


def _hsl2hex(h, s, l):
    if s == 0:
        r = g = b = l
    else:
        q = l * (1 + s) if l < 0.5 else l + s - l * s
        p = 2 * l - q
        hh = h / 360
        r, g, b = _h2c(p, q, hh + 1 / 3), _h2c(p, q, hh), _h2c(p, q, hh - 1 / 3)
    return "#%02x%02x%02x" % tuple(int(math.floor(v * 255 + 0.5)) for v in (r, g, b))


def _toward(h, target, amt):
    d = ((target - h + 540) % 360) - 180
    step = min(abs(d), amt) * (1 if d >= 0 else -1)
    return (h + step + 360) % 360


def _clampL(l):
    return min(0.97, max(0.03, l))


def ramp_from_base(base):
    """Recipe (art guide 4), tuned to reproduce the Hearth Pop ramps (HSL):
    hi    hue 10deg toward yellow (45), L + 0.30*(1-L), S kept
    shade hue  8deg toward violet (270), L * 0.80, S * 0.80
    deep  hue 20deg toward violet (270), L * 0.55, S * 0.60"""
    h, s, l = _rgb2hsl(*_hex(base))
    return [
        _hsl2hex(_toward(h, 45, 10), s, _clampL(l + (1 - l) * 0.30)),
        _hsl2hex(h, s, l),
        _hsl2hex(_toward(h, 270, 8), s * 0.80, _clampL(l * 0.80)),
        _hsl2hex(_toward(h, 270, 20), s * 0.60, _clampL(l * 0.55)),
    ]


def resolve(role, spec):
    """spec: None (default), preset name, or hex. Returns [hi, base, shade, deep]."""
    pre = RIG["presets"][role]
    if spec is None:
        spec = "default"
    if spec in pre:
        p = pre[spec]
        return [c.lower() for c in p["ramp"]] if "ramp" in p else ramp_from_base(p["base"])
    s = spec.lstrip("#")
    if len(s) == 6 and all(c in "0123456789abcdefABCDEF" for c in s):
        return ramp_from_base("#" + s)
    sys.exit(f"recolor: '{spec}' is not a {role} preset ({', '.join(pre)}) or a hex colour")


def _px(im):
    f = getattr(im, "get_flattened_data", None) or im.getdata  # Pillow >= 12.1 renamed getdata
    return list(f())


def load_layers():
    return [(L, Image.open(os.path.join(HERE, L["file"])).convert("RGBA")) for L in RIG["layers"]]


def compose(colours, layers=None):
    """colours: {role: spec}. Returns the full RGBA strip."""
    layers = layers or load_layers()
    mk = {_hex(RIG["markers"][t]): t for t in TONES}
    out = Image.new("RGBA", layers[0][1].size, (0, 0, 0, 0))
    for L, im in layers:
        if L["tint"]:
            r = dict(zip(TONES, (_hex(c) for c in resolve(L["role"], colours.get(L["role"])))))
            px = [(*r[mk[p[:3]]], 255) if p[3] and p[:3] in mk else p for p in _px(im)]
            im = Image.new("RGBA", im.size)
            im.putdata(px)
        out.alpha_composite(im)
    return out


def frame(strip, n, cw=64):
    return strip.crop(((n - 1) * cw, 0, n * cw, strip.height))


def scale(im, s):
    return im if s == 1 else im.resize((im.width * s, im.height * s), Image.NEAREST)


def verify():
    orig = Image.open(os.path.join(HERE, "..", "gnome-player.png")).convert("RGBA")
    got = compose({})
    a, b = _px(orig), _px(got)
    norm = lambda p: p if p[3] else (0, 0, 0, 0)
    diff = sum(1 for p, q in zip(a, b) if norm(p) != norm(q))
    print(f"verify: default recolour vs gnome-player.png: {diff} differing px of {len(a)}")
    return diff


PREVIEW = [
    ("as drawn", {}),
    ("guide skinA", {"skin": "skinA"}),
    ("cli example", {"hat": "ef4a3b", "tunic": "3a86b0", "beard": "f5f0e6", "scarf": "f5b82e", "boots": "864c33", "skin": "skinA"}),
    ("moss forester", {"hat": "moss", "tunic": "wood", "scarf": "ember red", "beard": "ginger", "boots": "dark leather", "skin": "skinB"}),
    ("dusk wizard", {"hat": "dusk", "tunic": "navy", "scarf": "gold", "beard": "grey", "boots": "black-brown", "skin": "skinC", "trim": "silver"}),
    ("petal", {"hat": "petal", "tunic": "moss", "scarf": "cream", "beard": "blond", "boots": "tan", "skin": "porcelain"}),
    ("gold miner", {"hat": "gold", "tunic": "ember red", "scarf": "sea", "beard": "black-brown", "boots": "oxblood", "skin": "bronze", "trim": "copper"}),
    ("sea sailor", {"hat": "navy", "tunic": "sea", "scarf": "ember red", "beard": "auburn", "boots": "stone", "skin": "tan"}),
    ("wood elder", {"hat": "wood", "tunic": "plum", "scarf": "orange", "beard": "snow", "boots": "wood", "skin": "umber", "trim": "brass"}),
    ("stone", {"hat": "stone", "tunic": "mustard", "scarf": "teal", "beard": "chestnut", "boots": "ember red", "skin": "deep"}),
    ("forest", {"hat": "forest", "tunic": "gold", "scarf": "berry", "beard": "ginger wood", "boots": "moss", "skin": "olive"}),
    ("sprite", {"hat": "plum", "tunic": "petal", "scarf": "sky", "beard": "lilac", "boots": "dusk", "skin": "moss sprite", "trim": "sky"}),
]


def preview(path, sc=3):
    layers = load_layers()
    cols = 6
    cells = [scale(frame(compose(c, layers), 1), sc) for _, c in PREVIEW]
    cw, ch = cells[0].size
    rows = (len(cells) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * cw, rows * ch * 2), (0, 0, 0, 0))
    for i, im in enumerate(cells):  # top half on mid grey, bottom half on dark
        x, y = (i % cols) * cw, (i // cols) * ch
        for bg, oy in (((0x8a, 0x86, 0x90, 255), 0), ((0x24, 0x1e, 0x2a, 255), rows * ch)):
            tile = Image.new("RGBA", (cw, ch), bg)
            tile.alpha_composite(im)
            sheet.paste(tile, (x, y + oy))
    sheet.save(path)
    print(f"preview: {len(cells)} gnomes -> {path}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    for r in RIG["roles"]:
        ap.add_argument("--" + r, metavar="PRESET|HEX")
    ap.add_argument("--frame", type=int, help="output one frame (1-6) instead of the strip")
    ap.add_argument("--scale", type=int, default=1)
    ap.add_argument("--verify", action="store_true")
    ap.add_argument("--preview", metavar="PNG")
    ap.add_argument("--ramps", action="store_true", help="print resolved ramps")
    ap.add_argument("out", nargs="?")
    a = ap.parse_args()
    if a.verify:
        sys.exit(1 if verify() else 0)
    if a.preview:
        preview(a.preview)
        return
    colours = {r: getattr(a, r) for r in RIG["roles"] if getattr(a, r)}
    if a.ramps:
        for r in RIG["roles"]:
            print(f"{r:6} {' '.join(resolve(r, colours.get(r)))}")
    if not a.out:
        if not a.ramps:
            ap.error("out.png required")
        return
    im = compose(colours)
    if a.frame:
        im = frame(im, a.frame)
    scale(im, a.scale).save(a.out)
    print(f"recolor: -> {a.out} {im.width * a.scale}x{im.height * a.scale}")


if __name__ == "__main__":
    main()
