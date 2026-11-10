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
from bend_stamps import disc, expand, apply_ops
from bend_water import stream_ops

PRESET = {"grassland": dict(wall=.15, rough=.14), "forest": dict(wall=.40, rough=.10, tight=True, scale=5), "coast": dict(wall=.17, rough=.13), "tundra": dict(wall=.15, rough=.20)}
STEP = {"N": (0, -1), "S": (0, 1), "E": (1, 0), "W": (-1, 0)}

def parse_road(entry, text):
    x, y = entry; line = [(x, y)]
    for tok in text.split():
        dx, dy = STEP[tok[0]]
        for _ in range(int(tok[1:])): x, y = x + dx, y + dy; line.append((x, y))
    return line


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
            wide = c["name"] in ("hub-river", "mid-outlet", "bridge-brook")
            sops, note, (px, py, dx, dy) = stream_ops(line, c, f"{rid}|{i}", wide)
            ops += sops; notes.append(note)
            if c["name"] == "pond-brook":      # this brook ends in the middle pond: put the pond at the end of the brook
                bx, by = round(px + dx * 8), round(py + dy * 8); bx = max(4, min(W - 5, bx)); by = max(4, min(H - 5, by))
                ops.append(("pond", bx, by, 2)); notes.append(dict(name="pond-mid", pond=[bx, by])); skip_pond.add("pond-mid")
        elif c.get("dist", 99) <= 14 and c["name"] != "lake" and c["name"] not in skip_pond:
            ax, ay = c["at"]; vx, vy = c["near"][0] - ax, c["near"][1] - ay; n = math.hypot(vx, vy) or 1
            idx = round(min(0.85, max(0.15, c["t"])) * (len(line) - 1)); px, py = line[idx]
            cx, cy = round(px + vx / n * 7), round(py + vy / n * 7); cx = max(5, min(W - 6, cx)); cy = max(5, min(H - 6, cy))
            ops.append(("pond", cx, cy, 2)); notes.append(dict(name=c["name"], pond=[cx, cy]))
    return ops, notes

# ---- gates (tool-locked chokepoints) and extra mini-boss spots ----
def road_tile(line, hint, lo=5, hi=7, avoid=()):
    """Index of the road tile nearest to hint, at least lo steps from the entry and hi from the exit (the mini-boss E sits 4 before the exit)."""
    ok = [k for k in range(lo, len(line) - hi) if all(abs(k - a) > 2 for a in avoid)]
    return min(ok, key=lambda k: (abs(line[k][0] - hint[0]) + abs(line[k][1] - hint[1]), k))

REGION_LEVEL = {"NA": 1}      # Maplewold = level 1. Gate rule: min tool tier = region level + 1 (Maplewold: Sturdy), +1 per region level, capped at 4 (Masterwork)
def tool_tier_name(ttype, tier):
    """Name of the tier-`tier` tool of a type, read from TOOL_ITEMS in game/includes/tools.php."""
    import re
    for t, n, name in re.findall(r"\['(\w+)', (\d), '([^']+)'", open(os.path.join(REPO, "game/includes/tools.php"), encoding="utf-8").read()):
        if t == ttype and int(n) == tier: return name
    raise SystemExit(f"no tier {tier} {ttype} tool in tools.php")

def gates_for(specs, line, wnotes, region="NA"):
    """Gate = a wall across the whole section at a road tile, open only at the gate tiles (3 wide, centred on the road). kind 'shortcut' also gets a second,
    longer opening far along the wall (the bypass). Returns (ops, gate records)."""
    ops, out = [], []
    for sp in specs:
        k = road_tile(line, sp["at"]); px, py = line[k]; a, b = line[k - 1], line[k + 1]
        vertical_wall = abs(b[0] - a[0]) >= abs(b[1] - a[1])          # road runs E-W: wall runs N-S
        if vertical_wall:
            ops.append(("W", px, 1, px, H - 2)); tiles = [(px, y) for y in range(max(1, py - 1), min(H - 2, py + 1) + 1)]
        else:
            ops.append(("W", 1, py, W - 2, py)); tiles = [(x, py) for x in range(max(1, px - 1), min(W - 2, px + 1) + 1)]
        ops += [("F", x, y, x, y) for x, y in tiles]
        rec = dict(tiles=[list(t) for t in tiles], road_index=k, tool_type=sp["tool"], min_tier=sp.get("tier", min(4, REGION_LEVEL[region] + 1)), tool_name=tool_tier_name(sp["tool"], sp.get("tier", min(4, REGION_LEVEL[region] + 1))), kind=sp.get("kind", "lock"), label=sp["label"])
        if rec["kind"] == "shortcut":
            far = sp["bypass"]; byp = [(px, far), (px, far + 1)] if vertical_wall else [(far, py), (far + 1, py)]
            ops += [("F", x, y, x, y) for x, y in byp]; rec["bypass"] = [list(t) for t in byp]
        out.append(rec)
    return ops, out

def check_gates(rows, entry, exit_, gates):
    for gt in gates:
        g = [list(r) for r in rows]
        for x, y in gt["tiles"]: g[y][x] = "#"
        sp = walk(g, entry, exit_)
        if gt["kind"] == "lock" and sp is not None: raise SystemExit(f"gate {gt['label']}: a lock that can be walked around")
        if gt["kind"] == "shortcut" and sp is None: raise SystemExit(f"gate {gt['label']}: shortcut has no bypass")

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
    wops, wnotes = water_for(rid, i, line, entry, exit_)
    gate_ops, gates = gates_for(spec.get("gates", []), line, wnotes)
    if gates: wops = [o for o in wops if not (o[0] == "r" and len(o) == 4 and o[3] == 0)]      # no shallows around a gate: it must stay the only way
    prot = set(); apply_ops(g, prot, spec.get("ops", []) + gate_ops); apply_ops(g, set(), wops)
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
    rows_out = ["".join(r) for r in g]; check_gates(rows_out, entry, exit_, gates)
    gate_k = [gt["road_index"] for gt in gates]; minis = []
    for m in spec.get("mini", []):
        k = road_tile(line, m["at"], avoid=gate_k); minis.append(dict(x=line[k][0], y=line[k][1], road_index=k, creature=m["slug"], level=m["level"], label=m["label"]))
    return rows_out, toks, lms, line, wnotes, gates, minis

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
        rows, toks, lms, line, wnotes, gates, minis = build_section(rid, i, spec, src["land"], entry, exit_, i == 0, bool(src["boss"]) and i == len(src["sections"]) - 1, [l[2] for l in s["landmarks"]], None)
        t.update(rows=rows, tokens=toks, landmarks=lms, line=[list(c) for c in line], water=wnotes)
        if gates: t["gates"] = gates
        if minis: t["extra_minibosses"] = minis
        out["sections"].append(t)
        if do_show: print(f"route {rid} section {i + 1}: {s['feature']}"); show(t)
    d = os.path.join(REPO, "claude", "maplewold-bendy-maps"); os.makedirs(d, exist_ok=True)
    json.dump(out, open(os.path.join(d, f"route-{rid}.json"), "w"), indent=1, ensure_ascii=False)
    print("wrote", os.path.join(d, f"route-{rid}.json"))

if __name__ == "__main__":
    ids = [int(a) for a in sys.argv[1:] if a.isdigit()]
    for rid in ids: build(rid, "--show" in sys.argv)
