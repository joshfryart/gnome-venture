#!/usr/bin/env python3
"""bulk_zoom.py OUT.png slug [slug...]  : 2x crops of the changed area, frame 1 | frame 3 | frame 4 per scene (QA aid)."""
import os, sys
import numpy as np
from PIL import Image, ImageDraw
HERE = os.path.dirname(os.path.abspath(__file__))
ACTS = os.path.join(os.path.abspath(os.path.join(HERE, "..", "..", "..")), "game", "assets", "img", "acts")
out, slugs = sys.argv[1], sys.argv[2:]
tiles = []
for s in slugs:
    an = Image.open(os.path.join(ACTS, "act-%s-anim.png" % s)).convert("RGBA")
    fr = [np.array(an.crop((i * 144, 0, i * 144 + 144, 108))) for i in range(an.width // 144)]
    d = np.zeros((108, 144), bool)
    for f in fr[1:]: d |= (f != fr[0]).any(axis=2)
    ys, xs = np.where(d)
    x0, x1, y0, y1 = max(10, xs.min() - 8), min(134, xs.max() + 8), max(10, ys.min() - 8), min(98, ys.max() + 8)
    if x1 - x0 > 80: c = (x0 + x1) // 2; x0, x1 = c - 40, c + 40
    if y1 - y0 > 64: c = (y0 + y1) // 2; y0, y1 = c - 32, c + 32
    ims = []
    for k in (0, 2, 3):
        im = Image.fromarray(fr[k]).crop((x0, y0, x1, y1))
        bg = Image.new("RGBA", im.size, (255, 0, 255, 255)); bg.alpha_composite(im)
        ims.append(bg.convert("RGB").resize((im.width * 2, im.height * 2), Image.NEAREST))
    T = Image.new("RGB", (3 * 164 + 4, 132), (30, 30, 30))
    for j, im in enumerate(ims): T.paste(im, (j * 164, 10))
    ImageDraw.Draw(T).text((2, 0), s, fill=(255, 255, 255))
    tiles.append(T)
cols = 2
W = Image.new("RGB", (cols * (3 * 164 + 8), ((len(tiles) + cols - 1) // cols) * 134), (60, 60, 60))
for i, t in enumerate(tiles): W.paste(t, ((i % cols) * (3 * 164 + 8), (i // cols) * 134))
W.save(out)
