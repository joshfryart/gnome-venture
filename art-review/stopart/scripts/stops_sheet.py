#!/usr/bin/env python3
"""Contact sheet: shipped (top) vs Stitched Toy redraw (bottom) for the 12 stop type icons, 5x, light bg. Writes out/_cmp/stops-all.png."""
from PIL import Image
R = '/home/user/gnome-venture/'
names = 'camp ferry herb inn jetty market mill orchard shrine spring tower workshop'.split()
S = 5; W = 48 * S + 8
for half, nm in ((0, names[:6]), (1, names[6:])):
    pass
sh = Image.new('RGB', (6 * W, 4 * W), '#f1ece0')
for i, n in enumerate(names):
    for k, p in enumerate(('game/assets/img/stops/', 'art-review/stopart/out/stops/')):
        im = Image.open(R + p + n + '.png').convert('RGBA').resize((48 * S, 48 * S), Image.NEAREST)
        sh.paste(im, ((i % 6) * W, ((i // 6) * 2 + k) * W), im)
sh.save(R + 'art-review/stopart/out/_cmp/stops-all.png')
