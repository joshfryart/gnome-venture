#!/usr/bin/env python3
"""Bake bendy 30 x 18 routes with the RICH painter (tools/render_bendy_rich.py) into the game's art shape.
Per section: ground/<route>-<section>-r.png (terrain, water, rough, shadows and every flat decor thing), a list of raised things
[x, y, key, jit, jy] (64 x 96 sprites 'x-<name>-<args>', landmarks 'lm-<name>' in their own size), and obj/<key>.png once per key.
The game draws the raised things and the walker in depth order (includes/trail_art.php; jy = the sprite's shift down in picture pixels).
Finds, the boss mark and mini-boss marks are NOT in the pictures: the game draws those.
Per section 'wet' = rows of 0/1, the water tiles of the picture (streams, fords, ponds, sea, ice); the game offers fishing on and beside them.
Output (staging, NOT the game): the 16 hand-tuned Maplewold routes (region "MW") -> claude/maplewold-bendy-maps/bake/, every other region (NA = the 3 other routes of the Maplewold region) -> claude/trail-rich-bake/ (git-ignored); in each
{ground,obj}/ and one authored-map file per region <name>_30x18.json (Maplewold: trail_maps_maplewold_30x18.json). Source file of a route: render_bendy_rich.src_of().
Usage: python3 -I tools/bake_trail_rich.py [route ids ... | --region CODE ... | --all] [--proof] [--jobs N]     no id = the 16 Maplewold routes; --proof also writes proof/<route>-<section>.png,
the section put together the way the game does it (to compare with rich/route-<id>-s<n>.png).
--install [--all | --region CODE] copies the staged bake into the game (a release step): ground/ and obj/ into game/assets/img/trail/, the json(s) to game/includes/data/trail_maps/<name>_30x18.json.
Bake once per version: a re-bake is not bit-for-bit the same."""
import glob, json, os, sys
from multiprocessing import Pool
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(HERE); sys.path.insert(0, HERE)
OUT_NA = os.path.join(REPO, "claude", "maplewold-bendy-maps", "bake")
OUT_REST = os.path.join(REPO, "claude", "trail-rich-bake")
T, PAD = 64, 40
def out_of(region): return OUT_NA if region == "MW" else OUT_REST
def map_name(region): return "maplewold" if region == "MW" else region.lower()
def region_of(rid):
    """'MW' = the 16 hand-tuned Maplewold routes (claude/maplewold-bendy-maps); otherwise the region code of the generated route (NA also has 3 generated routes: file na_30x18.json)."""
    import render_bendy_rich as R
    p = R.src_of(rid)
    return "MW" if "maplewold-bendy-maps" in p else json.load(open(p))["region"]

def job(a):
    rid, si, proof = a
    OUT = out_of(region_of(rid))
    import render_bendy_rich as R
    from maplewold_rich_specs import rich_for
    from PIL import Image
    route = json.load(open(R.src_of(rid)))
    base, objs, sprites, wet = R.paint(route, si, rich_for(rid, si, route), None, walker=False, split=True)
    base.convert("RGB").quantize(256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).save(os.path.join(OUT, "ground", f"{rid}-{si + 1}-r.png"), optimize=True)
    for k, im in sprites.items():
        f = os.path.join(OUT, "obj", k + ".png")
        if not os.path.exists(f): im.save(f, optimize=True)
    if proof:   # as includes/trail_art.php draws it: ground, then raised things by (row + .5 + jy / 64, column)
        pic = base.copy()
        for o in sorted(objs, key=lambda o: (o[1] + .5 + (o[4] if len(o) > 4 else 0) / 64, o[0])):
            im = sprites[o[2]]; jy = o[4] if len(o) > 4 else 0
            x, y = (o[0] * T + o[3], PAD + o[1] * T - 29 + jy) if im.size == (64, 96) else (o[0] * T + 32 - im.width // 2 + o[3], PAD + o[1] * T + 62 - im.height)
            cl = im.crop((max(0, -x), max(0, -y), min(im.width, pic.width - x), min(im.height, pic.height - y)))
            if cl.width > 0 and cl.height > 0: pic.alpha_composite(cl, (max(x, 0), max(y, 0)))
        pic.convert("RGB").save(os.path.join(OUT, "proof", f"{rid}-{si + 1}.png"))
    W, H = len(route['sections'][si]['rows'][0]), len(route['sections'][si]['rows'])
    return rid, si, objs, [''.join('1' if (x, y) in wet else '0' for x in range(W)) for y in range(H)]

def all_ids():
    import render_bendy_rich as R
    return sorted(int(os.path.basename(f)[6:-5]) for f in glob.glob(os.path.join(REPO, "claude", "bend-prototype-v2", "route-*.json")) if os.path.basename(f)[6:-5].isdigit())

def main():
    import bendy_to_trail_maps as B, render_bendy_rich as R
    args = sys.argv[1:]; proof = "--proof" in args
    regions = [args[i + 1].upper() for i, a in enumerate(args) if a == "--region"]
    jobsn = next((int(args[i + 1]) for i, a in enumerate(args) if a == "--jobs"), 0)
    if "--install" in args:
        import shutil
        regs = regions or (sorted({region_of(i) for i in all_ids()}) if "--all" in args else ["MW"])
        for out in sorted({out_of(r) for r in regs}):   # the staged folder is shared by all non-Maplewold regions: copy each once
            for d in ("ground", "obj"):
                os.makedirs(os.path.join(REPO, "game", "assets", "img", "trail", d), exist_ok=True)
                for f in sorted(os.listdir(os.path.join(out, d))): shutil.copy2(os.path.join(out, d, f), os.path.join(REPO, "game", "assets", "img", "trail", d, f))
        os.makedirs(os.path.join(REPO, "game", "includes", "data", "trail_maps"), exist_ok=True)
        for reg in regs:
            src = os.path.join(out_of(reg), "trail_maps_maplewold_30x18.json" if reg == "MW" else map_name(reg) + "_30x18.json")
            shutil.copy2(src, os.path.join(REPO, "game", "includes", "data", "trail_maps", map_name(reg) + "_30x18.json")); print("map file", map_name(reg))
        print("installed ground pictures and sprites from", sorted({out_of(r) for r in regs})); return
    if "--all" in args: ids = all_ids()
    else:
        ids = [int(a) for i, a in enumerate(args) if a.isdigit() and (i == 0 or args[i - 1] not in ("--jobs", "--region"))]
        if regions: ids += [i for i in all_ids() if region_of(i) in regions]
        if not ids: ids = [i for i in all_ids() if region_of(i) == "MW"]
    ids = sorted(set(ids))
    for reg in {region_of(i) for i in ids}:
        for d in ("ground", "obj") + (("proof",) if proof else ()): os.makedirs(os.path.join(out_of(reg), d), exist_ok=True)
    data = B.convert([R.src_of(i) for i in ids])
    jobs = [(rid, si, proof) for rid in ids for si in range(len(data["routes"][str(rid)]["sections"]))]
    with Pool(jobsn or min(8, os.cpu_count() or 2)) as pool:
        for rid, si, objs, wet in pool.imap_unordered(job, jobs, chunksize=1):
            sec = data["routes"][str(rid)]["sections"][si]; sec["objs"] = objs; sec["pic"] = "r"   # pic r: the ground picture is <route>-<section>-r.png (the old 22 x 7 pictures keep their names)
            if any("1" in r for r in wet): sec["wet"] = wet   # every water tile in the picture (streams, fords, ponds, sea, ice): the game offers fishing beside them
            print("baked", rid, si + 1, len(objs), "objs", flush=True)
    for reg in sorted({region_of(i) for i in ids}):
        mine = {k: v for k, v in data["routes"].items() if region_of(int(k)) == reg}
        dest = os.path.join(out_of(reg), "trail_maps_maplewold_30x18.json" if reg == "MW" else map_name(reg) + "_30x18.json")
        d = {"v": 1, "routes": mine}
        if os.path.exists(dest):   # a partial bake keeps the other routes of the region
            old = json.load(open(dest)); old["routes"].update(mine); d = old
        json.dump(d, open(dest, "w"), separators=(",", ":"), ensure_ascii=False); print(reg, len(d["routes"]), "routes ->", dest)
    print("sections:", len(jobs))

if __name__ == "__main__": main()
