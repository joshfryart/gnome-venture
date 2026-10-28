#!/usr/bin/env python3
"""Jigsaw placeholder pictures (v2.0.87): 1800x1200 (3:2) JPEG + 450x300 thumb, red border and THIS IS PLACEHOLDER, over busy coloured blobs so the pieces can still be told apart.
Usage: tools/gen_jigsaw_placeholders.py OUTDIR slug [slug ...]   (writes OUTDIR/<slug>.jpg and OUTDIR/<slug>-thumb.jpg). Replace with the real art, same names."""
import sys, os, random, zlib
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def make(out, slug):
    rnd = random.Random(zlib.crc32(slug.encode()))
    W, H = 1800, 1200
    im = Image.new('RGB', (W, H), (250, 244, 230))
    d = ImageDraw.Draw(im)
    for _ in range(260):
        x, y, r = rnd.randrange(W), rnd.randrange(H), rnd.randrange(30, 150)
        c = tuple(rnd.randrange(60, 235) for _ in range(3))
        d.ellipse([x - r, y - r, x + r, y + r], fill=c)
    im = im.filter(ImageFilter.GaussianBlur(2))
    d = ImageDraw.Draw(im)
    f = ImageFont.load_default(size=120)
    for i, t in enumerate(['THIS IS', 'PLACEHOLDER', slug.upper()]):
        tw = d.textlength(t, font=f)
        x, y = (W - tw) / 2, 330 + i * 190
        d.rectangle([x - 20, y - 8, x + tw + 20, y + 150], fill=(255, 255, 255))
        d.text((x, y), t, fill=(220, 20, 20), font=f)
    d.rectangle([0, 0, W - 1, H - 1], outline=(220, 20, 20), width=24)
    im.save(os.path.join(out, slug + '.jpg'), quality=85, optimize=True)
    im.resize((450, 300), Image.LANCZOS).save(os.path.join(out, slug + '-thumb.jpg'), quality=82, optimize=True)

if __name__ == '__main__':
    os.makedirs(sys.argv[1], exist_ok=True)
    for s in sys.argv[2:]:
        make(sys.argv[1], s)
