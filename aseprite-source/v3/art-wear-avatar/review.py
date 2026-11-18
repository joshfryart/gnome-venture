#!/usr/bin/env python3
"""review.py REGION CAT [frames] [scale] [y0,y1] -> REGION/review-CAT.png: each item of a category, chosen frames x 3 views, scaled."""
import sys, os, importlib
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import rig, av
region, cat = sys.argv[1], sys.argv[2]
fr = [int(x) for x in (sys.argv[3] if len(sys.argv) > 3 else '1,4,7').split(',')]
s = int(sys.argv[4]) if len(sys.argv) > 4 else 4
items = [it for it in importlib.import_module(f'{region}.items').ITEMS if it['cat'] == cat]
y0, y1 = [int(x) for x in (sys.argv[5] if len(sys.argv) > 5 else '28,74').split(',')]
cw, chh = 44 * s, (y1 - y0) * s   # crop x 10..54
out = Image.new('RGBA', (cw * len(fr) * 3 + 20, chh * len(items)), (138, 134, 144, 255))
for i, it in enumerate(items):
    for j, v in enumerate(av.VIEWS):
        st = rig.compose(v, [(cat, Image.open(os.path.join(HERE, 'wear', it['slug'], v + '.png')))])
        for k, f in enumerate(fr):
            c = st.crop(((f - 1) * 64 + 10, y0, (f - 1) * 64 + 54, y1)).resize((cw, chh), Image.NEAREST)
            out.alpha_composite(c, ((j * len(fr) + k) * cw + j * 10, i * chh))
out.save(os.path.join(HERE, region, f'review-{cat}.png'))
