#!/usr/bin/env python3
"""Wrap 126x90 scene PNGs (variety-act-*.lua output) in the wooden Do-tab card frame (copied from act-hand.png)
and write 144x108 act-<slug>.png. Usage: variety-act-frame.py <scene_dir> <out_dir> [slug ...]"""
import sys, os
from PIL import Image
root = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
frame = Image.open(os.path.join(root, "game/assets/img/acts/act-hand.png")).convert("RGBA")
src, out = sys.argv[1], sys.argv[2]
slugs = sys.argv[3:] or [f[4:-10] for f in sorted(os.listdir(src)) if f.endswith("-scene.png")]
for s in slugs:
    sc = Image.open(os.path.join(src, f"act-{s}-scene.png")).convert("RGBA")
    assert sc.size == (126, 90), sc.size
    card = frame.copy()
    card.paste(sc, (10, 10))
    card.save(os.path.join(out, f"act-{s}.png"))
    print(s, card.size)
