#!/usr/bin/env python3
"""Bake the authored Trail maps into game art (Hearth Pop v3 tiles, pass 2).
Reads  claude/maplewold-trail-maps/maplewold_trail_maps_22wide.json (and any other file named on the command line),
writes game/assets/img/trail/ground/<route>-<section>.png   one blended ground picture per section (shadows baked in)
       game/assets/img/trail/obj/<key>.png                  raised things (trees, rocks ...), 64x96, drawn by the game in depth order
       game/assets/img/trail/find-<land>[-done].png         find spots, 64x64
       game/assets/img/trail/gnome.png                      the player, 64x80 (v3 gnome-player, idle frame)
       game/includes/data/trail_maps.json                   rows + object list per section, read by includes/trail_art.php
Run: python3 -I tools/bake_trail_art.py [maps.json ...]   (needs Pillow; the drawing code lives in claude/tile-art-v3-proposal/gen2.py)"""
import json, os, sys, zlib
from multiprocessing import Pool
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(REPO, "claude", "tile-art-v3-proposal"))
import gen2
from PIL import Image
gen2.ROOT = REPO
T, PAD = 64, 40
IMG = os.path.join(REPO, "game", "assets", "img", "trail")
BOSS = {313: "miniboss", 315: "boss"}   # delve = miniboss spot, lair = boss spot, on the last section (the E in the rows)

def crc(*a): return zlib.crc32("|".join(map(str, a)).encode())
def spec(land, x, y, seed):
    h = crc(land, x, y, seed) % 100
    if land == "grassland":
        if (x + y) % 3 == 0: return f"hedge-{h % 3}"
        return f"tree-leaf-{h % 8}" if h % 5 else f"bush-{h % 4}"
    if land == "forest":
        return (f"tree-{'pine' if h % 3 == 0 else 'leaf'}-{h % 8}") if h % 6 else f"boulder-moss-{h % 4}"
    if land == "coast": return f"boulder-{h % 5}"
    return f"pine-{h % 6}" if h % 5 else f"boulder-snow-{h % 4}"
def build_obj(key):
    p = key.split("-")
    if p[0] == "tree": return gen2.tree(int(p[2]), p[1])
    if p[0] == "bush": return gen2.bush(int(p[1]))
    if p[0] == "hedge": return gen2.hedge(int(p[1]))
    if p[0] == "pine": return gen2.pine(int(p[1]))
    if p[0] == "boulder":
        return gen2.boulder(int(p[-1]), p[1] == "moss", p[1] == "snow")

def flat_set(land, rows):
    W = len(rows[0]); out = set()
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c != "#": continue
            if land == "coast" and y == 0: out.add((x, y))
            if land == "tundra" and 1 <= x <= W - 2 and 1 <= y <= 5 and ((rows[y][x-1] == "#" and x - 1 > 0) or (rows[y][x+1] == "#" and x + 1 < W - 1)): out.add((x, y))
    return out

def bake(job):
    rid, si, land, rows = job
    W, Hh = len(rows[0]), len(rows); tw, th = W * T, Hh * T + PAD
    flat = flat_set(land, rows)
    types = ["".join("w" if (x, y) in flat else "u" if c == "#" else "r" if c == "," else "f" for x, c in enumerate(r)) for y, r in enumerate(rows)]
    plain = None
    ter = gen2.terrain_layer(land, [types[0].replace("w", "u")] + types, rid, True)
    base = Image.new("RGBA", (tw, th)); base.paste(ter.crop((0, T - PAD, tw, T - PAD + th)), (0, 0))
    bp = base.load(); objs = []
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c != "#" or (x, y) in flat: continue
            jit = 0 if land == "coast" else (crc("j", x, y, rid) % 7) - 3
            gen2.ell(bp, x * T + jit + 32 + 3, PAD + y * T + T - 4, 24, 6, 1, tw, th)
            gen2.ell(bp, x * T + jit + 32 + 12, PAD + y * T + T - 3, 14, 4, 1, tw, th)
            objs.append([x, y, spec(land, x, y, rid), jit])
    q = base.convert("RGB").quantize(256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    path = os.path.join(IMG, "ground", f"{rid}-{si + 1}.png"); q.save(path, optimize=True)
    return rid, si, objs

def main():
    files = sys.argv[1:] or [os.path.join(REPO, "claude/maplewold-trail-maps/maplewold_trail_maps_22wide.json")]
    routes = [r for f in files for r in json.load(open(f))]
    for d in ("ground", "obj"): os.makedirs(os.path.join(IMG, d), exist_ok=True)
    out, jobs = {}, []
    for r in routes:
        secs = []
        for si, s in enumerate(r["sections"]):
            rows = list(s["rows"]); ey = [y for y in range(len(rows)) if rows[y][0] != "#"][0]
            rows[ey] = "S" + rows[ey][1:]   # every section starts at an S on the left edge (section 1 already has one)
            secs.append({"feature": s["feature"], "caption": s["caption"], "rows": rows, "objs": []})
            jobs.append((r["route_id"], si, r["land"], [w.replace("S", ".").replace("9", ".").replace("E", ".").replace("F", ".") for w in rows]))
        out[str(r["route_id"])] = {"land": r["land"], "from": r["from"], "to": r["to"], "boss": BOSS.get(r["route_id"], ""), "sections": secs}
    with Pool(max(1, os.cpu_count() or 1)) as pool:
        for rid, si, objs in pool.imap_unordered(bake, jobs): out[str(rid)]["sections"][si]["objs"] = objs; print("baked", rid, si + 1, flush=True)
    keys = sorted({o[2] for r in out.values() for s in r["sections"] for o in s["objs"]})
    for k in keys: build_obj(k).save(os.path.join(IMG, "obj", k + ".png"), optimize=True)
    for land in ("grassland", "forest", "coast", "tundra"):
        gen2.find_spot(land, False).save(os.path.join(IMG, f"find-{land}.png"), optimize=True); gen2.find_spot(land, True).save(os.path.join(IMG, f"find-{land}-done.png"), optimize=True)
    gen2.sprite("gnome-player.png", 0).save(os.path.join(IMG, "gnome.png"), optimize=True)
    gen2.icon_search().save(os.path.join(REPO, "game", "assets", "img", "ico", "ico-search.png"), optimize=True)
    os.makedirs(os.path.join(REPO, "game", "includes", "data"), exist_ok=True)
    json.dump({"v": 1, "routes": out}, open(os.path.join(REPO, "game", "includes", "data", "trail_maps.json"), "w"), separators=(",", ":"))
    print("objects:", len(keys), "sections:", len(jobs))

if __name__ == "__main__": main()
