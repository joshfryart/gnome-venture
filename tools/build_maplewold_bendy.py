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
import json, math, os, random, sys, zlib
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from bend_rules import SHORTCUT_AIM, LONG_CAP, WALL_MIN, WALL_MAX, road_ok, walk, reachable, run_lengths
from gen_bendy_trail_proto import noise_field, quantile, W, H

PRESET = {"grassland": dict(wall=.15, rough=.14), "forest": dict(wall=.40, rough=.10, tight=True, scale=5), "coast": dict(wall=.17, rough=.13), "tundra": dict(wall=.15, rough=.20)}
STEP = {"N": (0, -1), "S": (0, 1), "E": (1, 0), "W": (-1, 0)}

def parse_road(entry, text):
    x, y = entry; line = [(x, y)]
    for tok in text.split():
        dx, dy = STEP[tok[0]]
        for _ in range(int(tok[1:])): x, y = x + dx, y + dy; line.append((x, y))
    return line

def disc(cx, cy, r):
    return [(x, y) for y in range(cy - r, cy + r + 1) for x in range(cx - r, cx + r + 1) if (x - cx) ** 2 + (y - cy) ** 2 <= r * r + r * 0.6]


# ---- stamp library: named landscape pieces, expanded into the basic ops (seeded by their own position, so always the same) ----
def _r(*a): return random.Random(zlib.crc32(repr(a).encode()))
def expand(op):
    k = op[0]
    if k == "pond":      # ("pond", cx, cy, r): water disc with a rough shore ring
        return [("r", op[1], op[2], op[3] + 1), ("w", op[1], op[2], op[3])]
    if k == "marsh":     # ("marsh", cx, cy, r): rough ground with small pools
        rg = _r(*op); out = [("r", op[1], op[2], op[3])]
        for _ in range(op[3] + 1):
            a, b = rg.randint(-op[3] + 1, op[3] - 1), rg.randint(-op[3] + 1, op[3] - 1)
            out.append(("w", op[1] + a, op[2] + b, 0))
        return out
    if k == "grove":     # ("grove", cx, cy, r): scattered single trees on open floor
        rg = _r(*op); out = [("f", op[1], op[2], op[3])]
        for (x, y) in disc(op[1], op[2], op[3]):
            if rg.random() < 0.38: out.append(("w", x, y, 0))
        return out
    if k == "orchard":   # ("orchard", x0, y0, x1, y1, step): trees on a grid
        st = op[5] if len(op) > 5 else 3
        return [("w", x, y, 0) for y in range(op[2], op[4] + 1, st) for x in range(op[1], op[3] + 1, st)]
    if k == "hedgefield":  # ("hedgefield", x0, y0, x1, y1, gapx): hedge outline, rough ploughed inside, a gap in the bottom hedge
        x0, y0, x1, y1, gx = op[1:6]
        out = [("R", x0 + 1, y0 + 1, x1 - 1, y1 - 1), ("W", x0, y0, x1, y0), ("W", x0, y1, x1, y1), ("W", x0, y0, x0, y1), ("W", x1, y0, x1, y1), ("F", gx, y1, gx, y1)]
        return out
    if k == "drift":     # ("drift", cx, cy, rx, ry): rough ellipse (flower drift, snow drift, dune)
        return [("r", x, y, 0) for y in range(op[2] - op[4], op[2] + op[4] + 1) for x in range(op[1] - op[3], op[1] + op[3] + 1)
                if ((x - op[1]) / op[3]) ** 2 + ((y - op[2]) / op[4]) ** 2 <= 1.0]
    if k == "fence":     # ("fence", x0, y0, x1, y1): posts every other tile on a straight line
        return [("w", x, y, 0) for y in range(min(op[2], op[4]), max(op[2], op[4]) + 1) for x in range(min(op[1], op[3]), max(op[1], op[3]) + 1) if (x + y) % 2 == 0]
    return [op]

# ---- water ways from the region map (tools/maplewold_waterways.py): streams cross the road where the region curve crosses them ----
K = 0.75   # tiles per region unit
def water_for(rid, i, line, entry, exit_):
    """(ops, notes) for section i of route rid. Streams: a meandering water line through the road tile at the crossing, along the stream's own direction (region axes =
    grid axes), 1 tile wide for brooks, 2 for rivers, rough banks at the ford. Ponds: a pond on the side the pond lies, 6 tiles off the road."""
    import maplewold_waterways as MW
    global _WCACHE
    try: _WCACHE
    except NameError: _WCACHE = {}
    if rid not in _WCACHE: _WCACHE[rid] = MW.route_water(rid)
    ops, notes, skip_pond = [], [], set()
    for c in sorted(_WCACHE[rid][i], key=lambda c: "dir" not in c):
        if "dir" in c:
            dx, dy = c["dir"]; i0 = round(min(0.85, max(0.15, c["t"])) * (len(line) - 1))
            def along(k):      # how much a stream through road tile k would run along the road (1 = parallel)
                a, b = line[max(0, k - 2)], line[min(len(line) - 1, k + 2)]; L = math.hypot(b[0] - a[0], b[1] - a[1]) or 1
                return abs((b[0] - a[0]) * dx + (b[1] - a[1]) * dy) / L
            idx = min((k for k in range(max(4, i0 - 8), min(len(line) - 4, i0 + 9))), key=lambda k: (round(along(k), 1), abs(k - i0)))
            px, py = line[idx]
            wide = c["name"] in ("hub-river", "mid-outlet", "bridge-brook")
            rg = random.Random(zlib.crc32(f"{rid}|{i}|{c['name']}".encode())); ph = rg.uniform(0, 6.3)
            cells, pts = [], []
            for k in range(-90, 91):
                s = k * 0.5; off = 1.3 * math.sin(s / 5.0 + ph)
                x = px + dx * s - dy * off; y = py + dy * s + dx * off; cx, cy = round(x), round(y)
                if not (1 <= cx <= W - 2 and 1 <= cy <= H - 2): continue
                if (cx, cy) not in cells: cells.append((cx, cy)); pts.append([cx, cy])
                if wide:
                    q = (round(x - dy), round(y + dx))
                    if q not in cells and 1 <= q[0] <= W - 2 and 1 <= q[1] <= H - 2: cells.append(q)
            ops.append(("r", px, py, 2))
            ops += [("w", x, y, 0) for x, y in cells]
            ops.append(("r", px, py, 1))
            fl = ("E" if dx > 0.5 else "W" if dx < -0.5 else "") if abs(dx) > abs(dy) * 0.5 else ""
            fl = ("S" if dy > 0.5 else "N" if dy < -0.5 else "") + fl
            notes.append(dict(name=c["name"], flow=fl, pts=pts, cross=[px, py], wide=wide))
            if c["name"] == "pond-brook":      # this brook ends in the middle pond: put the pond at the end of the brook
                bx, by = round(px + dx * 8), round(py + dy * 8); bx = max(4, min(W - 5, bx)); by = max(4, min(H - 5, by))
                ops.append(("pond", bx, by, 2)); notes.append(dict(name="pond-mid", pond=[bx, by])); skip_pond.add("pond-mid")
        elif c.get("dist", 99) <= 14 and c["name"] != "lake" and c["name"] not in skip_pond:
            ax, ay = c["at"]; vx, vy = c["near"][0] - ax, c["near"][1] - ay; n = math.hypot(vx, vy) or 1
            idx = round(min(0.85, max(0.15, c["t"])) * (len(line) - 1)); px, py = line[idx]
            cx, cy = round(px + vx / n * 7), round(py + vy / n * 7); cx = max(5, min(W - 6, cx)); cy = max(5, min(H - 6, cy))
            ops.append(("pond", cx, cy, 2)); notes.append(dict(name=c["name"], pond=[cx, cy]))
    return ops, notes

def apply_ops(g, prot, ops):
    ops = [e for op in ops for e in expand(op)]
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
    wops, wnotes = water_for(rid, i, line, entry, exit_); prot = set(); apply_ops(g, prot, spec.get("ops", [])); apply_ops(g, set(), wops)
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
    return ["".join(r) for r in g], toks, lms, line, wnotes

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
        rows, toks, lms, line, wnotes = build_section(rid, i, spec, src["land"], entry, exit_, i == 0, bool(src["boss"]) and i == len(src["sections"]) - 1, [l[2] for l in s["landmarks"]], None)
        t.update(rows=rows, tokens=toks, landmarks=lms, line=[list(c) for c in line], water=wnotes); out["sections"].append(t)
        if do_show: print(f"route {rid} section {i + 1}: {s['feature']}"); show(t)
    d = os.path.join(REPO, "claude", "maplewold-bendy-maps"); os.makedirs(d, exist_ok=True)
    json.dump(out, open(os.path.join(d, f"route-{rid}.json"), "w"), indent=1, ensure_ascii=False)
    print("wrote", os.path.join(d, f"route-{rid}.json"))

if __name__ == "__main__":
    ids = [int(a) for a in sys.argv[1:] if a.isdigit()]
    for rid in ids: build(rid, "--show" in sys.argv)
