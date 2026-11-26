#!/usr/bin/env python3
"""Contact sheet: all 12 new stamps (top light / bottom dark bg) next to shipped, -> out/_cmp/stamps-all.png"""
import glob, os
from PIL import Image
R = '/home/user/gnome-venture'
fs = sorted(glob.glob(R + '/art-review/stopart/out/stops/stamp-*.png'))
S = 4; W = 64 * S + 8
sh = Image.new('RGB', (6 * W, 4 * W), '#f1ece0')
sh.paste('#2a1a10', (0, 2 * W, 6 * W, 4 * W))
for i, f in enumerate(fs):
    for row, src in ((0, f), (2, f)):
        im = Image.open(src).convert('RGBA').resize((64 * S, 64 * S), Image.NEAREST)
        sh.paste(im, ((i % 6) * W + 4, (row + i // 6) * W + 4), im)
sh.save(R + '/art-review/stopart/out/_cmp/stamps-all.png')
