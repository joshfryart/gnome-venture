#!/usr/bin/env python3
"""Placeholder art: a white square with a red border and the words THIS IS PLACEHOLDER.
Usage: tools/gen_placeholder_art.py OUT.png [SIZE [HEIGHT]]  (several: tools/gen_placeholder_art.py --many OUTDIR name1 name2 ...)
Every placeholder is listed in claude/todo-art-variety.md; replace the file with the real art (same name, same size) and tick it off.
"""
import sys, os
from PIL import Image, ImageDraw, ImageFont

def make(path, size=96, h=None):
    w = size
    h = h or size
    size = min(w, h)
    im = Image.new('RGB', (w, h), (255, 255, 255))
    d = ImageDraw.Draw(im)
    b = max(3, size // 16)
    d.rectangle([0, 0, w - 1, h - 1], outline=(220, 20, 20), width=b)
    f = ImageFont.load_default(size=max(9, size // 7))
    lines = ['THIS IS', 'PLACE-', 'HOLDER']
    lh = f.size + 2
    y = (h - lh * len(lines)) // 2
    for t in lines:
        tw = d.textlength(t, font=f)
        d.text(((w - tw) / 2, y), t, fill=(220, 20, 20), font=f)
        y += lh
    im.save(path, optimize=True)

if __name__ == '__main__':
    if sys.argv[1] == '--many':
        out = sys.argv[2]
        os.makedirs(out, exist_ok=True)
        for n in sys.argv[3:]:
            make(os.path.join(out, n + '.png'))
    else:
        make(sys.argv[1], int(sys.argv[2]) if len(sys.argv) > 2 else 96, int(sys.argv[3]) if len(sys.argv) > 3 else None)
