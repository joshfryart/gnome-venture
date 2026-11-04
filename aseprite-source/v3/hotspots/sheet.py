#!/usr/bin/env python3
"""Contact sheet: python3 sheet.py OUT.png  (4x, grey ground row + game-brown ground row)"""
import glob, os, sys
from PIL import Image
H = os.path.dirname(os.path.abspath(__file__))
fs = sorted(glob.glob(H + '/hs-*.png'))
cols = 10; S = 4; cell = 48 * S + 8
rows = -(-len(fs) // cols)
out = Image.new('RGB', (cols * cell * 2 + 8, rows * cell + 8), (43, 28, 38))
for i, f in enumerate(fs):
    im = Image.open(f).convert('RGBA').resize((48 * S, 48 * S), Image.NEAREST)
    x, y = (i % cols) * cell + 8, (i // cols) * cell + 8
    for off, bg in ((0, (150, 150, 150)), (cols * cell, (43, 28, 38))):
        t = Image.new('RGBA', im.size, bg + (255,)); t.alpha_composite(im); out.paste(t.convert('RGB'), (x + off, y))
out.save(sys.argv[1]); print(len(fs), out.size)
