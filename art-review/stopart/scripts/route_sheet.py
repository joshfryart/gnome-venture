#!/usr/bin/env python3
"""route_sheet.py: all 7 route cards, shipped (top of each pair) vs Stitched Toy redraw, at 3x -> out/_cmp/route-all.png."""
import glob
import os
from PIL import Image
ROOT = '/home/user/gnome-venture'
S = 3
fs = sorted(os.path.basename(f) for f in glob.glob(ROOT + '/game/assets/img/town/route-*.png'))
cw, ch = 144 * S + 8, 108 * S + 8
sheet = Image.new('RGBA', (4 * cw, 4 * ch), (241, 236, 224, 255))
for i, n in enumerate(fs):
    col, row = i % 4, (i // 4) * 2
    for k, base in enumerate(('game/assets/img/town', 'art-review/stopart/out/town')):
        im = Image.open(os.path.join(ROOT, base, n)).convert('RGBA').resize((144 * S, 108 * S), Image.NEAREST)
        sheet.alpha_composite(im, (col * cw, (row + k) * ch))
sheet.convert('RGB').save(ROOT + '/art-review/stopart/out/_cmp/route-all.png')
