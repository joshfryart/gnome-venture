#!/usr/bin/env python3
"""install.py: copy the v3 act scenes (static + 6-frame strip) into game/assets/img/acts and build the review sheet.
  1. Build each scene:  /tmp/aseq/squashfs-root/AppRun -b --script aseprite-source/v3/acts/<slug>/<slug>.lua
  2. python3 aseprite-source/v3/acts/install.py      (copies every <slug>/act-<slug>{,-anim}.png that exists)
  3. python3 aseprite-source/anim/scripts/bulk_verify.py
bulk.py skips any slug that has a folder here, so the generic generator never overwrites these strips."""
import os, glob
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
ACTS = os.path.join(REPO, "game", "assets", "img", "acts")
slugs = sorted(os.path.basename(d) for d in glob.glob(os.path.join(HERE, "*")) if os.path.isfile(os.path.join(d, "act-%s-anim.png" % os.path.basename(d))))
for s in slugs:
    for suf in ("", "-anim"):
        im = Image.open(os.path.join(HERE, s, "act-%s%s.png" % (s, suf))).convert("RGBA")
        im.save(os.path.join(ACTS, "act-%s%s.png" % (s, suf)), optimize=True)
    print("installed", s)
# review sheet: before | after frame 1 | after frame 3 | after frame 4, at 2x
sc, gap = 2, 6
W = 4 * (144 * sc + gap) + gap
H = len(slugs) * (108 * sc + gap) + gap
sheet = Image.new("RGBA", (W, H), (60, 58, 70, 255))
for r, s in enumerate(slugs):
    old = Image.open(os.path.join(HERE, s, "old-act-%s.png" % s)).convert("RGBA")
    an = Image.open(os.path.join(HERE, s, "act-%s-anim.png" % s)).convert("RGBA")
    cells = [old] + [an.crop((i * 144, 0, i * 144 + 144, 108)) for i in (0, 2, 3)]
    for k, im in enumerate(cells):
        im = im.resize((144 * sc, 108 * sc), Image.NEAREST)
        sheet.paste(im, (gap + k * (144 * sc + gap), gap + r * (108 * sc + gap)), im)
sheet.save(os.path.join(HERE, "review-9-scenes.png"), optimize=True)
print("sheet", os.path.join(HERE, "review-9-scenes.png"), "(columns: before | after f1 | f3 | f4)")
