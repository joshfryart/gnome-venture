#!/usr/bin/env python3
"""compose_preview.py OUT.png slug...: the before/after sheet from preview.js's shots (out/_preview/<slug>-<old|new>-<light|dark>-<rest|act>.png).
Per creature one row: shipped at rest | staged at rest | staged mid-attack, on light, then the same on dark. All shots are real
Chromium renders of the game's fight scene. Default: close-ups of the foe (flipped to face the gnome, as in the game);
--stage: the whole stage, gnome on the left for scale."""
import os, sys
from PIL import Image, ImageDraw
D = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out', '_preview')
out, slugs = sys.argv[1], sys.argv[2:]
stage = '--stage' in slugs; slugs = [s for s in slugs if s != '--stage']
SUF = '' if stage else '-foe'
cols = [('old', 'light', 'rest'), ('new', 'light', 'rest'), ('new', 'light', 'act'), ('old', 'dark', 'rest'), ('new', 'dark', 'rest'), ('new', 'dark', 'act')]
heads = ['shipped', 'staged', 'staged, attacking', 'shipped', 'staged', 'staged, attacking']
S = 0.5 if stage else 0.75   # shots are 4 device px per art px: the stage view at 2 px, the close-up of the foe at 3 px per art px
rows = []
for s in slugs:
    ims = [Image.open(os.path.join(D, '%s-%s-%s-%s%s.png' % (s, *c, SUF))).convert('RGB') for c in cols]
    ims = [i.resize((max(1, round(i.width * S)), max(1, round(i.height * S))), Image.NEAREST) for i in ims]
    rows.append((s, ims))
cw = [max(r[1][k].width for r in rows) for k in range(len(cols))]
pad, lab, top = 8, 20, 22
W = sum(cw) + pad * (len(cols) + 1)
H = top + sum(lab + max(i.height for i in r[1]) + pad for r in rows) + pad
o = Image.new('RGB', (W, H), (255, 255, 255)); d = ImageDraw.Draw(o)
x = pad
for k, h in enumerate(heads):
    d.text((x, 6), h + (' (light)' if k < 3 else ' (dark)'), fill=(42, 26, 16)); x += cw[k] + pad
y = top
for s, ims in rows:
    d.text((pad, y + 4), s, fill=(42, 26, 16))
    y += lab; x = pad; rh = max(i.height for i in ims)
    for k, im in enumerate(ims):
        bg = (241, 236, 224) if k < 3 else (42, 26, 16)
        d.rectangle([x, y, x + cw[k] - 1, y + rh - 1], fill=bg)
        o.paste(im, (x, y)); x += cw[k] + pad
    y += rh + pad
o.save(out, optimize=True)
print(out, o.size)
