#!/usr/bin/env python3
"""Training-set coverage by category. Which categories sit below the target number of examples?

  python3 coverage.py DS_DIR [--target 30]

Categories: crop kinds (crops.txt), dishes (recipes.txt), seed packets by crop kind, and keyword buckets
for everything else (the long tail of unique items). Edit BUCKETS to taste.
"""
import argparse, json, re
from collections import Counter, defaultdict
from pathlib import Path

DATA = Path(__file__).resolve().parents[2] / "game/includes/data"
BUCKETS = {
    "tool": "hoe rake spade shovel trowel secateurs shears knife axe saw scoop net rod hammer pick fork sickle scythe".split(),
    "container": "jar pot pouch sack bag basket bucket barrel box chest can crate bowl cup mug vase tin".split(),
    "light": "lantern candle lamp torch".split(),
    "animal part": "pelt feather fang claw tooth horn bone shell scale egg eggs antler hide".split(),
    "clothing": "hat cap boot boots glove cloak scarf coat apron belt".split(),
    "building": "gate fence door wall roof house hut shed well bridge path tee corner cross end straight".split(),
    "cloth/craft": "rope thread yarn cloth rug banner flag ribbon button needle".split(),
    "mineral": "stone rock gem crystal ore coal salt clay sand".split(),
    "drink/tea": "tea tonic brew ale wine cider juice".split(),
}

def load(name, col):
    out = {}
    for ln in (DATA / name).read_text(encoding="utf-8").splitlines():
        if ln.startswith("#") or "|" not in ln: continue
        p = ln.split("|"); out[p[0].strip()] = p[col].strip() if len(p) > col else ""
    return out

def main():
    ap = argparse.ArgumentParser(); ap.add_argument("ds"); ap.add_argument("--target", type=int, default=30)
    a = ap.parse_args()
    crops = load("crops.txt", 2); dishes = load("recipes.txt", 1)
    rows = [json.loads(l) for l in (Path(a.ds) / "metadata.jsonl").read_text().splitlines()]
    cat = defaultdict(list)
    for r in rows:
        slug = r["file_name"][:-4]
        base = slug[:-5] if slug.endswith("-seed") else slug
        if slug.endswith("-seed"): cat[f"seed packet ({crops.get(base, 'unknown crop')})"].append(slug)
        elif base in crops: cat[f"crop: {crops[base]}"].append(slug)
        elif base in dishes: cat["dish / food"].append(slug)
        else:
            ws = re.split(r"[-_]", base)
            hit = next((b for b, kw in BUCKETS.items() if any(w in kw for w in ws)), "other (unbucketed)")
            cat[hit].append(slug)
    print(f"{len(rows)} images, target {a.target} per category\n")
    print(f"{'category':38}{'have':>6}{'need':>6}")
    for k, v in sorted(cat.items(), key=lambda kv: len(kv[1])):
        print(f"{k:38}{len(v):>6}{max(0, a.target - len(v)):>6}{'  OK' if len(v) >= a.target else ''}")
    print(f"\nshort by: {sum(max(0, a.target - len(v)) for v in cat.values())} images across {sum(1 for v in cat.values() if len(v) < a.target)} categories")
    unb = cat.get("other (unbucketed)", [])
    if unb: print("\nunbucketed examples:", ", ".join(unb[:40]))

main()
