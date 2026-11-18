#!/usr/bin/env python3
"""zoom.py REGION SLUG [frames] [scale] -> /tmp-free: writes REGION/zoom.png (3 views x frames, crop x8..56 y26..76)."""
import sys, os, importlib
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import rig, av
region, slug = sys.argv[1], sys.argv[2]
fr = [int(x) for x in (sys.argv[3] if len(sys.argv) > 3 else '1,5').split(',')]
s = int(sys.argv[4]) if len(sys.argv) > 4 else 6
cat = next(it['cat'] for it in importlib.import_module(f'{region}.items').ITEMS if it['slug'] == slug)
cw, chh = 48 * s, 50 * s
out = Image.new('RGBA', (cw * len(fr) * 3, chh), (138, 134, 144, 255))
for j, v in enumerate(av.VIEWS):
    st = rig.compose(v, [(cat, Image.open(os.path.join(HERE, 'wear', slug, v + '.png')))])
    for k, f in enumerate(fr):
        out.alpha_composite(st.crop(((f - 1) * 64 + 8, 26, (f - 1) * 64 + 56, 76)).resize((cw, chh), Image.NEAREST), ((j * len(fr) + k) * cw, 0))
out.save(os.path.join(HERE, region, 'zoom.png'))
