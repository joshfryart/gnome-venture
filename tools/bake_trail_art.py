#!/usr/bin/env python3
"""Bake the authored Trail maps into game art (Hearth Pop v3 tiles, pass 2). Any region: follow claude/prompt-route-maps.md and claude/route-list.md.
Input   one or more map files or folders (every *.json in a folder). A file is a list of route objects, {"routes": [...]}, or one route object
        {route_id, from, to, land, sections: [{feature, caption, rows, tokens}]}; sections may be 11 wide (as the prompt asks) or 22 wide (Maplewold).
        Suggested place: claude/<region-slug>-trail-maps/<region-slug>_trail_maps.json. No argument = the Maplewold file.
Output  game/assets/img/trail/ground/<route>-<section>.png   one blended ground picture per section (shadows baked in); the game reads this name
        game/assets/img/trail/obj/<key>.png                  raised things (trees, rocks ...), 64x96, drawn by the game in depth order
        game/assets/img/trail/find-<art land>[-done].png     find spots, 64x64;   gnome.png  the player idle frame, 64x80
        game/includes/data/trail_maps.json                   rows + object list per section, read by includes/trail_art.php. MERGED into the
                                                             routes already in it (re-baking one region keeps the others); --fresh starts empty
        --route=N  (repeatable) bake only route N and re-bake it even if its pictures exist; the other routes in trail_maps.json are kept
Landmarks  claude/maplewold-trail-maps/maplewold_landmarks.json: {route_id: [[ [x, y, name, jitter] per feature ] per section]}. A route listed there also
        gets a worn path (tile type 'p') from the S to the exit; each landmark is a raised sprite obj/lm-<name>.png (drawn by gen2.LANDMARKS).
Options --check   validate only (shape, characters, a walkable path in every section, continuity between sections), write nothing, exit 1 on a problem
        --all     re-bake routes that already have all their pictures (default: only new or incomplete routes)
        --fresh   start trail_maps.json empty instead of merging
Run: python3 -I tools/bake_trail_art.py [--check] [--all] [--fresh] [maps.json|folder ...]   (needs Pillow, except --check; the drawing code is claude/tile-art-v3-proposal/gen2.py)
Lands: the art exists for grassland, forest, coast and tundra only. ART_LAND below says which one stands in for the other lands (desert, island,"""
import glob, json, os, re, sys, zlib
from collections import deque
from multiprocessing import Pool
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CHECK_ONLY = "--check" in sys.argv[1:]
if not CHECK_ONLY:
    sys.path.insert(0, os.path.join(REPO, "claude", "tile-art-v3-proposal"))
    import gen2
    from PIL import Image
    gen2.ROOT = REPO
T, PAD = 64, 40
IMG = os.path.join(REPO, "game", "assets", "img", "trail")
BOSS = {313: "miniboss", 315: "boss"}   # fallback only: delve = miniboss spot, lair = boss spot, on the last section (the E in the rows)
ART_LAND = {"grassland": "grassland", "forest": "forest", "coast": "coast", "tundra": "tundra",   # stand-ins until each land has its own art
            "rainforest": "forest", "wetland": "forest", "island": "coast", "desert": "coast", "mountain": "tundra"}
LIST = os.path.join(REPO, "claude", "route-list.md")
DATA = os.path.join(REPO, "game", "includes", "data", "trail_maps.json")
DEFAULT_MAPS = os.path.join(REPO, "claude/maplewold-trail-maps/maplewold_trail_maps_22wide.json")
LANDMARKS = os.path.join(REPO, "claude/maplewold-trail-maps/maplewold_landmarks.json")   # routes listed here get a worn path and one raised landmark per named feature

def boss_of(rid):
    """'miniboss' when the route list says one end is a delve, 'boss' for a lair (only used when the last section has an E), else ''."""
    try:
        for line in open(LIST, encoding="utf-8"):
            m = re.match(r"\|\s*(\d+)\s*\|(.*)\|", line)
            if m and int(m.group(1)) == rid: return "boss" if "(lair)" in m.group(2) else "miniboss" if "(delve)" in m.group(2) else ""
    except OSError: pass
    return BOSS.get(rid, "")

def load_routes(paths):
    out = []
    for p in paths:
        for f in (sorted(glob.glob(os.path.join(p, "*.json"))) if os.path.isdir(p) else [p]):
            j = json.load(open(f, encoding="utf-8"))
            j = j["routes"] if isinstance(j, dict) and "routes" in j else [j] if isinstance(j, dict) else j
            out += [(f, r) for r in j]
    return out

def check_route(r):
    """Problems in one route object (empty list = fine): shape, characters, entry/exit, a walkable path, section continuity."""
    bad, prev_exit, w0 = [], None, None
    if not r.get("sections"): return ["no sections"]
    for si, s in enumerate(r["sections"]):
        rows = s.get("rows") or []
        w = len(rows[0]) if rows else 0
        w0 = w0 or w
        if len(rows) != 7 or w < 5 or w != w0 or any(len(x) != w for x in rows): bad.append(f"s{si+1}: needs 7 equal rows, same width in every section"); continue
        if any(c not in "#.,S9EF" for x in rows for c in x): bad.append(f"s{si+1}: characters other than # . , S 9 E F"); continue
        nines = [(x, y) for y, x_ in enumerate(rows) for x, c in enumerate(x_) if c == "9"]
        if len(nines) != 1 or nines[0][0] != w - 1: bad.append(f"s{si+1}: exactly one 9, on the right edge"); continue
        starts = [(x, y) for y, x_ in enumerate(rows) for x, c in enumerate(x_) if c == "S"]
        if si == 0:
            if len(starts) != 1 or starts[0][0] != 0: bad.append("s1: exactly one S, on the left edge"); continue
            start = starts[0]
        else:
            if starts: bad.append(f"s{si+1}: S only in section 1"); continue
            if prev_exit is None or rows[prev_exit][0] == "#": bad.append(f"s{si+1}: no floor at x=0 on the previous exit row"); continue
            start = (0, prev_exit)
        seen, q = {start}, deque([start])
        while q:
            x, y = q.popleft()
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < 7 and (nx, ny) not in seen and rows[ny][nx] != "#": seen.add((nx, ny)); q.append((nx, ny))
        if nines[0] not in seen: bad.append(f"s{si+1}: no path from the entry to the 9")
        for x_, y_ in ((x, y) for y, row in enumerate(rows) for x, c in enumerate(row) if c in "EF"):
            if (x_, y_) not in seen: bad.append(f"s{si+1}: token at {x_},{y_} unreachable")
        prev_exit = nines[0][1]
    return bad

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
    if p[0] == "lm": return gen2.landmark(key[3:])
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

def path_cells(rows):
    """Cells of the shortest walk from the entry (S, or the first open cell on the left edge) to the exit (9), as a set of (x, y)."""
    W, Hh = len(rows[0]), len(rows)
    st = next(((x, y) for y, r in enumerate(rows) for x, c in enumerate(r) if c == "S"), None) or next((0, y) for y in range(Hh) if rows[y][0] != "#")
    en = next((W - 1, y) for y in range(Hh) if rows[y][-1] == "9")
    prev, q = {st: None}, deque([st])
    while q:
        c = q.popleft()
        if c == en: break
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (c[0] + dx, c[1] + dy)
            if 0 <= n[0] < W and 0 <= n[1] < Hh and rows[n[1]][n[0]] != "#" and n not in prev: prev[n] = c; q.append(n)
    out, c = set(), en
    while c is not None: out.add(c); c = prev[c]
    return out

def bake(job):
    rid, si, land, rows, path, lms = job   # land = the ART land (ART_LAND), the one the drawing code knows; path = set of (x, y) or None; lms = landmark objs
    W, Hh = len(rows[0]), len(rows); tw, th = W * T, Hh * T + PAD
    flat = flat_set(land, rows)
    types = ["".join("w" if (x, y) in flat else "u" if c == "#" else "p" if path and (x, y) in path else "r" if c == "," else "f" for x, c in enumerate(r)) for y, r in enumerate(rows)]
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
    return rid, si, objs + [list(o) for o in lms]

def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    only = {int(a.split("=")[1]) for a in sys.argv[1:] if a.startswith("--route=")}
    entries = load_routes(args or [DEFAULT_MAPS])
    lm_data = json.load(open(LANDMARKS, encoding="utf-8")) if os.path.isfile(LANDMARKS) else {}
    bad = 0
    for f, r in entries:
        for msg in check_route(r) + ([] if r.get("land") in ART_LAND else [f"land {r.get('land')!r} is not in ART_LAND"]):
            print(f"PROBLEM {os.path.basename(f)} route {r.get('route_id')}: {msg}"); bad += 1
    print(f"{len(entries)} routes, {sum(len(r['sections']) for _, r in entries)} sections, {bad} problems")
    if CHECK_ONLY or bad: return 1 if bad else 0
    routes = [r for _, r in entries if not only or int(r["route_id"]) in only]
    for d in ("ground", "obj"): os.makedirs(os.path.join(IMG, d), exist_ok=True)
    have = {} if "--fresh" in sys.argv else (json.load(open(DATA)).get("routes", {}) if os.path.isfile(DATA) else {})
    out, jobs = dict(have), []
    for r in routes:
        rid, land = int(r["route_id"]), r["land"]; art = ART_LAND[land]
        done = str(rid) in have and all(os.path.isfile(os.path.join(IMG, "ground", f"{rid}-{i + 1}.png")) for i in range(len(r["sections"]))) and len(have[str(rid)]["sections"]) == len(r["sections"])
        if done and "--all" not in sys.argv and rid not in only: print("kept", rid); continue
        secs = []
        for si, s in enumerate(r["sections"]):
            rows = list(s["rows"]); ey = [y for y in range(len(rows)) if rows[y][0] != "#"][0]
            rows[ey] = "S" + rows[ey][1:]   # every section starts at an S on the left edge (section 1 already has one)
            secs.append({"feature": s["feature"], "caption": s["caption"], "rows": rows, "objs": []})
            lm = lm_data.get(str(rid))
            jobs.append((rid, si, art, [w.replace("S", ".").replace("9", ".").replace("E", ".").replace("F", ".") for w in rows],
                         path_cells(rows) if lm else None, [[x, y, "lm-" + n, j] for x, y, n, j in (lm[si] if lm and si < len(lm) else [])]))
        out[str(rid)] = {"land": land, "art": art, "from": r["from"], "to": r["to"], "boss": boss_of(rid), "sections": secs}
    with Pool(max(1, os.cpu_count() or 1)) as pool:
        for rid, si, objs in pool.imap_unordered(bake, jobs): out[str(rid)]["sections"][si]["objs"] = objs; print("baked", rid, si + 1, flush=True)
    keys = sorted({o[2] for r in out.values() for s in r["sections"] for o in s["objs"]})
    for k in keys:
        if "--all" in sys.argv or not os.path.isfile(os.path.join(IMG, "obj", k + ".png")): build_obj(k).save(os.path.join(IMG, "obj", k + ".png"), optimize=True)
    for land in ("grassland", "forest", "coast", "tundra"):
        gen2.find_spot(land, False).save(os.path.join(IMG, f"find-{land}.png"), optimize=True); gen2.find_spot(land, True).save(os.path.join(IMG, f"find-{land}-done.png"), optimize=True)
    gen2.sprite("gnome-player.png", 0).save(os.path.join(IMG, "gnome.png"), optimize=True)
    gen2.icon_search().save(os.path.join(REPO, "game", "assets", "img", "ico", "ico-search.png"), optimize=True)
    os.makedirs(os.path.dirname(DATA), exist_ok=True)
    json.dump({"v": 1, "routes": out}, open(DATA, "w"), separators=(",", ":"))
    print("objects:", len(keys), "sections baked:", len(jobs), "routes in file:", len(out))
    return 0

if __name__ == "__main__": sys.exit(main())
