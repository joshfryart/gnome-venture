#!/usr/bin/env python3
"""Hand-tuned Maplewold bendy maps (prompt: claude/prompt-maplewold-bendy-maps.md). Deterministic. Does NOT touch game data.
Builds claude/maplewold-bendy-maps/route-<id>.json from the sketches in tools/maplewold_bendy_specs.py, starting from the generated file
claude/bend-prototype/route-<id>.json (route data, captions, landmark names, entry and exit tiles are taken from it).
Usage: python3 tools/build_maplewold_bendy.py 313 [315 ...] [--show]      (--show prints the grid; road = +, landmark = L, find = F, mini-boss = E)

A section sketch (dict in SPECS[route_id][section index]):
  road   turtle string from the entry tile, e.g. "E4 N3 E6 S3 ..."  (N up, S down; must end on the exit tile; runs <= 6, one up to 10)
  ops    stamps applied in order on top of the base landscape (later ones win; the road is always cut through afterwards):
           ("W", x0,y0,x1,y1) thicket rect   ("F", ...) floor rect   ("R", ...) rough rect     (all inclusive)
           ("w", cx,cy,r) ("f", cx,cy,r) ("r", cx,cy,r)   same as discs
           ("pat", x, y, [rows])  literal stamp, chars # . , and ? (= leave as is)
         Stamped cells are protected from the shortcut closing.
  land   overrides of the land preset: dict(wall=.., rough=.., seed=..)
  F      find hints [(x, y), ...] (1 to 3); each snaps to the nearest valid floor tile off the road (>= 3 from it)
  L      landmark hints, one per landmark in file order; each snaps to the nearest plain floor tile 2..5 from the road"""
import json, os, random, sys, zlib
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from bend_rules import SHORTCUT_AIM, LONG_CAP, WALL_MIN, WALL_MAX, road_ok, walk, reachable, run_lengths
from gen_bendy_trail_proto import noise_field, quantile, W, H

PRESET = {"grassland": dict(wall=.15, rough=.14), "forest": dict(wall=.36, rough=.10), "coast": dict(wall=.17, rough=.13), "tundra": dict(wall=.15, rough=.20)}
STEP = {"N": (0, -1), "S": (0, 1), "E": (1, 0), "W": (-1, 0)}

def parse_road(entry, text):
    x, y = entry; line = [(x, y)]
    for tok in text.split():
        dx, dy = STEP[tok[0]]
        for _ in range(int(tok[1:])): x, y = x + dx, y + dy; line.append((x, y))
    return line

def disc(cx, cy, r):
    return [(x, y) for y in range(cy - r, cy + r + 1) for x in range(cx - r, cx + r + 1) if (x - cx) ** 2 + (y - cy) ** 2 <= r * r + r * 0.6]

def apply_ops(g, prot, ops):
    def put(c, ch):
        x, y = c
        if 1 <= x <= W - 2 and 1 <= y <= H - 2: g[y][x] = ch; prot.add(c)
    for op in ops:
        k = op[0]
        if k in ("W", "F", "R"):
            for y in range(op[2], op[4] + 1):
                for x in range(op[1], op[3] + 1): put((x, y), {"W": "#", "F": ".", "R": ","}[k])
        elif k in ("w", "f", "r"):
            for c in disc(*op[1:4]): put(c, {"w": "#", "f": ".", "r": ","}[k])
        elif k == "pat":
            for j, row in enumerate(op[3]):
                for i, ch in enumerate(row):
                    if ch != "?": put((op[1] + i, op[2] + j), ch)
        else: raise SystemExit(f"unknown op {k}")

def near_map(line):
    near = {}
    for x, y in line:
        for dy in range(-6, 7):
            for dx in range(-6, 7):
                d = abs(dx) + abs(dy)
                if d < near.get((x + dx, y + dy), 99): near[(x + dx, y + dy)] = d
    return near

def build_section(rid, i, spec, land, entry, exit_, first, last_boss, lm_names, hints_note):
    line = parse_road(entry, spec["road"])
    if line[-1] != tuple(exit_): raise SystemExit(f"route {rid} section {i + 1}: road ends at {line[-1]}, exit is {tuple(exit_)}")
    if not road_ok(line): raise SystemExit(f"route {rid} section {i + 1}: road breaks the run rules, runs {run_lengths(line)}")
    if any(not (0 <= x < W and 0 <= y < H) for x, y in line) or any(0 in c or c[0] == W - 1 or c[1] == H - 1 for c in line[1:-1]):
        raise SystemExit(f"route {rid} section {i + 1}: road touches the border before the exit")
    on = set(line); near = near_map(line)
    p = dict(PRESET[land]); p.update(spec.get("land", {}))
    rng = random.Random(p.get("seed", zlib.crc32(f"mw|{rid}|{i}".encode())))
    sc = p.get("scale", 8); big, small = noise_field(rng, sc), noise_field(rng, max(2, sc // 2))
    fld = {(x, y): 0.65 * big[y][x] + 0.35 * small[y][x] for y in range(H) for x in range(W)}
    thin = (lambda c: 0.0 if near.get(c, 99) > 1 else -0.30) if p.get("tight") else (lambda c: 0.0 if near.get(c, 99) > 2 else -0.16 if near[c] == 2 else -0.30)
    inner = [(x, y) for y in range(1, H - 1) for x in range(1, W - 1) if (x, y) not in on]
    t_wall = quantile(sorted(fld[c] + thin(c) for c in inner), 1 - p["wall"] * 0.75)
    rv = sorted(fld[c] for c in inner); r_lo, r_hi = quantile(rv, 0.30), quantile(rv, 0.30 + p["rough"] * 0.6)
    g = [["#"] * W for _ in range(H)]
    for c in inner:
        if fld[c] + thin(c) < t_wall: g[c[1]][c[0]] = "," if r_lo <= fld[c] < r_hi else "."
    prot = set(); apply_ops(g, prot, spec.get("ops", []))
    for x, y in line: g[y][x] = "," if (x, y) not in (entry, exit_) and rng.random() < p["rough"] * 0.5 else "."
    prot -= on
    g[entry[1]][entry[0]] = "S" if first else "."; g[exit_[1]][exit_[0]] = "9"
    L = len(line) - 1
    for _ in range(400):                        # close in on shortcuts
        sp = walk(g, entry, exit_)
        if sp is None: raise SystemExit(f"route {rid} section {i + 1}: entry cannot reach exit")
        if (len(sp) - 1) / L >= SHORTCUT_AIM and max(run_lengths(sp), default=0) <= LONG_CAP: break
        cut = [c for c in sp if c not in on and c not in prot]
        if not cut: raise SystemExit(f"route {rid} section {i + 1}: shortcut runs only through protected cells (walk {len(sp) - 1} of road {L})")
        cx, cy = max(cut, key=lambda c: (near.get(c, 99), rng.random())); rad = rng.choice((1, 2))
        for dy in range(-rad, rad + 1):
            for dx in range(-rad, rad + 1):
                q = (cx + dx, cy + dy)
                if abs(dx) + abs(dy) <= rad and q not in on and q not in prot and 1 <= q[0] <= W - 2 and 1 <= q[1] <= H - 2: g[q[1]][q[0]] = "#"
    else: raise SystemExit(f"route {rid} section {i + 1}: could not close shortcuts")
    seen = reachable(g, entry)
    for y in range(H):
        for x in range(W):
            if g[y][x] != "#" and (x, y) not in seen: g[y][x] = "#"
    taken = set()
    def snap(hint, ok):
        best = sorted((c for c in seen if ok(c) and c not in taken), key=lambda c: (abs(c[0] - hint[0]) + abs(c[1] - hint[1]), c))
        return best[0] if best else None
    toks = []
    for h in spec.get("F", [(15, 9)]):
        c = snap(h, lambda c: c not in on and g[c[1]][c[0]] in ".," and near.get(c, 99) >= 3 and 1 <= c[0] <= W - 2 and 1 <= c[1] <= H - 2)
        if c is None: raise SystemExit(f"route {rid} section {i + 1}: no place for a find near {h}")
        taken.add(c); toks.append([c[0], c[1], "F"]); g[c[1]][c[0]] = "F"
    if last_boss:
        x, y = line[-5]; g[y][x] = "E"; toks.append([x, y, "E"])
    lms = []
    for name, h in zip(lm_names, spec["L"]):
        c = snap(h, lambda c: c not in on and g[c[1]][c[0]] in ".," and 2 <= near.get(c, 99) <= 5 and 3 <= c[0] <= W - 4 and 3 <= c[1] <= H - 2)
        if c is None: raise SystemExit(f"route {rid} section {i + 1}: no place for landmark {name} near {h}")
        taken.add(c); lms.append([c[0], c[1], name, 0])
    return ["".join(r) for r in g], toks, lms, line

def show(sec):
    g = [list(r) for r in sec["rows"]]
    for x, y in sec["line"]:
        if g[y][x] == "." or g[y][x] == ",": g[y][x] = "+"
    for x, y, _, _ in sec["landmarks"]: g[y][x] = "L"
    print("    " + "".join(str(x % 10) for x in range(W)))
    for y, r in enumerate(g): print(f"{y:3d} " + "".join(r))

def build(rid, do_show=False):
    from maplewold_bendy_specs import SPECS
    src = json.load(open(os.path.join(REPO, "claude", "bend-prototype", f"route-{rid}.json")))
    out = dict(src); out["sections"] = []
    for i, s in enumerate(src["sections"]):
        spec = SPECS[rid][i]; t = dict(s); t.update(spec.get("meta", {}))
        entry, exit_ = (s["entry"]["x"], s["entry"]["y"]), (s["exit"]["x"], s["exit"]["y"])
        rows, toks, lms, line = build_section(rid, i, spec, src["land"], entry, exit_, i == 0, bool(src["boss"]) and i == len(src["sections"]) - 1, [l[2] for l in s["landmarks"]], None)
        t.update(rows=rows, tokens=toks, landmarks=lms, line=[list(c) for c in line]); out["sections"].append(t)
        if do_show: print(f"route {rid} section {i + 1}: {s['feature']}"); show(t)
    d = os.path.join(REPO, "claude", "maplewold-bendy-maps"); os.makedirs(d, exist_ok=True)
    json.dump(out, open(os.path.join(d, f"route-{rid}.json"), "w"), indent=1, ensure_ascii=False)
    print("wrote", os.path.join(d, f"route-{rid}.json"))

if __name__ == "__main__":
    ids = [int(a) for a in sys.argv[1:] if a.isdigit()]
    for rid in ids: build(rid, "--show" in sys.argv)
