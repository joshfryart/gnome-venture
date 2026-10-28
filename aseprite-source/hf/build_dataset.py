#!/usr/bin/env python3
"""Build an HF imagefolder dataset (images + metadata.jsonl) from finished 64x64 art and its specs.

  python3 build_dataset.py --out DIR [--kinds icon item] [--limit N]

Captions come from the `subject:` line of img-redraw-full/specs/ph/<slug>.md.
Only 64x64 PNGs in game/assets/img/ph are used, upscaled --scale x on a magenta background.
Output is not meant to be committed.
"""
import argparse, json, re, shutil, sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
IMG = ROOT / "game/assets/img/ph"
SPECS = ROOT / "aseprite-source/img-redraw-full/specs/ph"
TAG = "gvstyle pixel art sticker"
KEY = (255, 0, 255)   # flat background colour; postfx.py keys it out

def kind(slug):
    if slug.endswith("-seed"): return "seed"
    if slug.startswith(("ico-", "icon-")): return "icon"
    return "item"

def subject(spec):
    m = re.search(r"^- subject:\s*(.+)$", spec.read_text(encoding="utf-8"), re.M)
    if not m: return None
    s = re.sub(r"\s+", " ", m.group(1)).strip().rstrip(".")
    return s[:200]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--kinds", nargs="*", default=None, help="icon item seed (default all)")
    ap.add_argument("--limit", type=int, default=0)
    ap.add_argument("--scale", type=int, default=8, help="nearest-neighbour upscale; art is flattened onto magenta (training data only)")
    a = ap.parse_args()
    out = Path(a.out); out.mkdir(parents=True, exist_ok=True)
    rows, skipped = [], {"no_spec": 0, "not_64": 0, "dark": 0, "kind": 0}
    for png in sorted(IMG.glob("*.png")):
        slug = png.stem
        if slug.endswith("-dark"): skipped["dark"] += 1; continue
        k = kind(slug)
        if a.kinds and k not in a.kinds: skipped["kind"] += 1; continue
        spec = SPECS / f"{slug}.md"
        sub = subject(spec) if spec.exists() else None
        if not sub: skipped["no_spec"] += 1; continue
        if Image.open(png).size != (64, 64): skipped["not_64"] += 1; continue
        im = Image.open(png).convert("RGBA")
        bg = Image.new("RGBA", im.size, KEY + (255,)); bg.alpha_composite(im)
        bg.convert("RGB").resize((64 * a.scale,) * 2, Image.NEAREST).save(out / png.name)
        rows.append({"file_name": png.name, "text": f"{TAG}, {k}, {sub}", "kind": k})
        if a.limit and len(rows) >= a.limit: break
    with (out / "metadata.jsonl").open("w", encoding="utf-8") as f:
        for r in rows: f.write(json.dumps(r, ensure_ascii=False) + "\n")
    from collections import Counter
    print(len(rows), "images", dict(Counter(r["kind"] for r in rows)), "skipped", skipped)

if __name__ == "__main__":
    main()
