#!/usr/bin/env python3
"""Contact sheet of stills: python3 sheet.py <dir> out.png [scale] [slug ...]   (all mini-*.png in <dir> when no slugs are given)"""
import sys, glob, os
from PIL import Image
d, out = sys.argv[1], sys.argv[2]; S = int(sys.argv[3]) if len(sys.argv) > 3 else 4
names = sys.argv[4:] or sorted(os.path.basename(f)[5:-4] for f in glob.glob(d + '/mini-*.png'))
ims = [(n, Image.open('%s/mini-%s.png' % (d, n)).convert('RGBA')) for n in names]
W = 1560; x = y = 8; rowh = 0; pos = []
for n, i in ims:
    w, h = i.width * S, i.height * S
    if x + w > W: x = 8; y += rowh + 8; rowh = 0
    pos.append((x, y)); x += w + 8; rowh = max(rowh, h)
o = Image.new('RGBA', (W, y + rowh + 8), (112, 124, 112, 255))
for (n, i), (x, y) in zip(ims, pos):
    j = i.resize((i.width * S, i.height * S), Image.NEAREST); o.paste(j, (x, y + 0), j)
o.save(out); print(out, o.size, len(ims))
