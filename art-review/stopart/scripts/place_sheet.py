#!/usr/bin/env python3
"""Contact sheet: shipped place cards (left) next to the Stitched Toy redraws (right), 3x. Writes out/_cmp/places-all.png."""
import glob, os
from PIL import Image
R = '/home/user/gnome-venture'
fs = sorted(glob.glob(R + '/game/assets/img/town/place-*.png'))
S, W, H = 3, 144, 108
sh = Image.new('RGB', (2 * (2 * W * S + 30), ((len(fs) + 1) // 2) * (H * S + 10)), '#d8d0bc')
for i, f in enumerate(fs):
    new = R + '/art-review/stopart/out/town/' + os.path.basename(f)
    for k, p in enumerate((f, new)):
        im = Image.open(p).convert('RGBA').resize((W * S, H * S), Image.NEAREST)
        sh.paste(im, ((i % 2) * (2 * W * S + 30) + k * (W * S + 6), (i // 2) * (H * S + 10)), im)
sh.save(R + '/art-review/stopart/out/_cmp/places-all.png')
