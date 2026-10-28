#!/usr/bin/env python3
"""bulk_verify.py: checks every act-<slug>-anim.png that bulk.py made: width multiple of 144, frame 1 == static,
frame border cells untouched, colours within the image's own palette (+ pilot accents). Prints failures and change stats.
  python aseprite-source/anim/scripts/bulk_verify.py [--sheets DIR]   (sheets: frame1|frame4 contact sheets, 30 per PNG)"""
import os, sys, glob
import numpy as np
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
ACTS = os.path.join(REPO, "game", "assets", "img", "acts")
PILOT = os.path.join(REPO, "aseprite-source", "anim")
ACC = {(0xf5, 0xcf, 0x6a), (0xff, 0xf3, 0xc8), (0xff, 0xf2, 0xb0), (0xff, 0xe0, 0x8a)}
pilots = {os.path.basename(p)[4:-len("-anim.aseprite")] for p in glob.glob(os.path.join(PILOT, "act-*-anim.aseprite"))}
bad = 0; rows = []
for p in sorted(glob.glob(os.path.join(ACTS, "act-*-anim.png"))):
    slug = os.path.basename(p)[4:-9]
    if slug in pilots: continue
    st = np.array(Image.open(os.path.join(ACTS, "act-%s.png" % slug)).convert("RGBA"))
    an = np.array(Image.open(p).convert("RGBA"))
    h, w = an.shape[:2]
    errs = []
    if w % 144 or h != 108: errs.append("size %dx%d" % (w, h))
    else:
        n = w // 144
        f = [an[:, i * 144:(i + 1) * 144] for i in range(n)]
        if not (f[0] == st).all(): errs.append("frame1 != static")
        pal = {tuple(c) for c in st.reshape(-1, 4)}
        palrgb = {c[:3] for c in pal if c[3]}
        ch = []
        for i in range(1, n):
            d = (f[i] != st).any(axis=2)
            ch.append(int(d.sum()) // 4)
            if d[:10].any() or d[-10:].any() or d[:, :10].any() or d[:, -10:].any(): errs.append("frame %d touches border" % (i + 1))
            cols = {tuple(c[:3]) for c in f[i][d]} - palrgb - ACC
            if cols: errs.append("off-palette %s" % sorted(cols)[:3])
        rows.append((slug, ch))
    if errs:
        bad += 1; print("FAIL", slug, errs)
print("checked", len(rows), "failures", bad)
if "--sheets" in sys.argv:
    out = sys.argv[sys.argv.index("--sheets") + 1]; os.makedirs(out, exist_ok=True)
    per = 30
    for s in range(0, len(rows), per):
        W = Image.new("RGB", (3 * 290, 10 * 110), (255, 0, 255))
        for k, (slug, ch) in enumerate(rows[s:s + per]):
            an = Image.open(os.path.join(ACTS, "act-%s-anim.png" % slug)).convert("RGBA")
            for j, fi in enumerate((0, 3)):
                fr = an.crop((fi * 144, 0, fi * 144 + 144, 108))
                bg = Image.new("RGBA", fr.size, (255, 0, 255, 255)); bg.alpha_composite(fr)
                W.paste(bg.convert("RGB"), ((k % 3) * 290 + j * 145 - 0, (k // 3) * 110))
        W.save(os.path.join(out, "sheet%02d.png" % (s // per)))
        open(os.path.join(out, "sheet%02d.txt" % (s // per)), "w").write("\n".join(r[0] for r in rows[s:s + per]))
if "--stats" in sys.argv:
    for slug, ch in rows: print(slug, ch)
