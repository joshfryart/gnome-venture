#!/usr/bin/env python3
"""PROTOTYPE: bendy trail maps (plan: claude/plan-route-map-bends.md). Does NOT touch game data.
Makes any route of the game (all 246) as 30 x 18 sections whose road wanders and enters / leaves on any edge (headings from the region road, snapped to 8 compass
directions) and writes, per route,
    claude/bend-prototype/route-<id>.json   (the game's map shape plus w, h, heading, entry, exit, line, landmarks per section)
    claude/bend-prototype/route-<id>.txt    (ASCII preview)
Usage:  python3 tools/gen_bendy_trail_proto.py [route_id ...] [--all] [--region=CODE]      (default route 313; --all = every route; needs php for tools/map_layout.php; sources: claude/*-trail-maps, groups from claude/route-list.md)
Check:  python3 tools/lint_trail_bends.py claude/bend-prototype/route-*.json        Picture:  python3 tools/preview_bend_proto.py <route.json>
Rules (numbers in tools/bend_rules.py):
  road     wanders; straight run <= 6 tiles, one run per section up to 10; no cell twice, no step back
  joins    entry of section N+1 = exit of N moved across the join; S on the first entry, one 9 on the exit edge
  land     off the road: meadow, rough ground and thickets in soft blobs (12 to 45% thicket); thickets close in on the inside of the bends until a shortcut
           saves at most about 18% of the road and gives no straight run over 10
  tokens   1 to 3 F out in the landscape (3+ tiles from the road, reachable); E on the road 4 steps before the exit on the last section of a delve / lair route
  landmarks  the route's own names (maplewold_landmarks.json, trail-landmarks/other_regions_landmarks.json), beside the road, feet row >= 3
Same route id and region always give the same maps."""
import functools, glob, json, math, os, random, subprocess, sys, zlib
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from bend_rules import SHORTCUT_AIM, LONG_CAP, WALL_MIN, WALL_MAX, CAP, road_ok, walk, reachable, run_lengths
from gen_trail_maps import LAND_FEEL, parse
from bend_stamps import apply_ops
VARIETY = False      # --variety: landscape stamps by land + ponds read from the region picture (tools/bend_stamps.py, tools/bend_water.py); written to claude/bend-prototype-v2/
K = 0.75             # tiles per region unit, for placing ponds    # one table of land feel for both generators; parse() reads claude/route-list.md
W, H = 30, 18
MIN_LINE = 25                              # a road shorter than this has no room to wander
DIRS = {"E": (1, 0), "SE": (1, 1), "S": (0, 1), "SW": (-1, 1), "W": (-1, 0), "NW": (-1, -1), "N": (0, -1), "NE": (1, -1)}   # y points down
OPP = {"E": "W", "W": "E", "N": "S", "S": "N"}
STEP = {"E": (1, 0), "W": (-1, 0), "N": (0, -1), "S": (0, 1)}

class NoFit(Exception): pass

# ---------- where the route goes on the region map ----------

@functools.lru_cache(maxsize=1)
def layout(): return json.loads(subprocess.check_output(["php", os.path.join(HERE, "map_layout.php")]))["regions"]

def catmull(p0, p1, p2, p3, t):
    return tuple(0.5 * (2 * p1[i] + (p2[i] - p0[i]) * t + (2 * p0[i] - 5 * p1[i] + 4 * p2[i] - p3[i]) * t * t + (3 * p1[i] - p0[i] - 3 * p2[i] + p3[i]) * t ** 3) for i in (0, 1))

def curve(pts, i0, i1):
    """Catmull-Rom through pts[i0..i1], with the road's own neighbours as tangents, so the curve leaves a stop the way the road arrives."""
    out = []
    for i in range(i0, i1):
        p0, p3 = pts[max(0, i - 1)], pts[min(len(pts) - 1, i + 2)]
        out += [catmull(p0, pts[i], pts[i + 1], p3, k / 12) for k in range(12)]
    return out + [pts[i1]]

@functools.lru_cache(maxsize=1)
def region_codes():
    """Gnomish region name -> code, from game/includes/data/regions.txt (the route list groups routes by these names)."""
    return {l.split("|")[1]: l.split("|")[0] for l in open(os.path.join(REPO, "game/includes/data/regions.txt"), encoding="utf-8") if "|" in l and not l.startswith("#")}

def group_regions(group):
    """('A', None) for 'A', ('A', 'B') for 'A -> B' (region codes)."""
    names = [g.strip() for g in group.split("->")]
    return region_codes()[names[0]], (region_codes()[names[1]] if len(names) > 1 else None)

def region_path(rid, frm, to, region, to_region=None):
    """(curve, kind, region code) in region `region`. kind: 'road' = along a real road, 'trail' = a drawn side trail, 'exit' = a stop to the road's exit toward the next
    region (for a route that crosses a border), 'bowed' = no line in the layout, so a curve bowed to one side by route id (plan item 8)."""
    x = next(r for r in layout() if r["code"] == region)
    pos = {x["town"]["name"]: (x["town"]["x"], x["town"]["y"])}
    pos.update({s["name"]: (s["x"], s["y"]) for s in x["stops"]})
    roads = [[tuple(q) for q in r["pts"]] for r in x["roads"]]
    if to_region:                                  # crosses a border: the stop to the exit toward the next region, along its road if the stop is on it
        ex = next((e for e in x["exits"] if e["to"] == to_region), None)
        if frm in pos and ex:
            a, end = pos[frm], (ex["x"], ex["y"]); pts = roads[ex["road"]] if ex.get("road") is not None else []
            if a in pts and end in pts:
                i, j = pts.index(a), pts.index(end); cur = curve(pts, min(i, j), max(i, j))
                return (cur if i < j else cur[::-1]), "exit", region
            return [a, end], "exit", region
        raise SystemExit(f"route {rid}: no way from {frm} to the exit toward {to_region} in {region}")
    if frm not in pos or to not in pos: raise SystemExit(f"route {rid}: {frm} or {to} not in region {region}")
    a, b = pos[frm], pos[to]
    for pts in roads:
        if a in pts and b in pts:
            i, j = pts.index(a), pts.index(b); cur = curve(pts, min(i, j), max(i, j))
            return (cur if i < j else cur[::-1]), "road", region
    for t in x["trails"]:
        t = [tuple(q) for q in t]
        if (t[0], t[-1]) == (a, b): return t, "trail", region
        if (t[0], t[-1]) == (b, a): return t[::-1], "trail", region
    vx, vy = b[0] - a[0], b[1] - a[1]; n = math.hypot(vx, vy) or 1; bow = 0.18 * n * (1 if rid % 2 else -1)
    return [a, ((a[0] + b[0]) / 2 - vy / n * bow, (a[1] + b[1]) / 2 + vx / n * bow), b], "bowed", region

def sample(path, n):
    """n + 1 points spread evenly along a polyline by length."""
    seg = [math.dist(path[i], path[i + 1]) for i in range(len(path) - 1)]; tot = sum(seg); out = []
    for k in range(n + 1):
        t, i = tot * k / n, 0
        while i < len(seg) - 1 and t > seg[i]: t -= seg[i]; i += 1
        f = min(1.0, t / seg[i]) if seg[i] else 0.0
        out.append((path[i][0] + (path[i + 1][0] - path[i][0]) * f, path[i][1] + (path[i + 1][1] - path[i][1]) * f))
    return out

def snap(vx, vy):
    """The compass heading (of 8) closest to a vector: the largest dot product with a unit direction."""
    return max(DIRS, key=lambda k: (vx * DIRS[k][0] + vy * DIRS[k][1]) / math.hypot(*DIRS[k]))

# ---------- sides, edges, joins ----------

def sides_for(heading, idx, prev_exit):
    """(entry side, exit side). The entry is always opposite the previous exit, so the join lines up. A diagonal heading alternates its two sides section by
    section. A heading that would send the road back where it came from leaves by a side edge instead."""
    ex, ey = DIRS[heading]
    if ex and ey: exit_side = ("E" if ex > 0 else "W") if idx % 2 == 0 else ("S" if ey > 0 else "N")
    elif ex: exit_side = "E" if ex > 0 else "W"
    else: exit_side = "S" if ey > 0 else "N"
    entry_side = OPP[prev_exit] if prev_exit else OPP[exit_side]
    if exit_side == entry_side:
        exit_side = ("S" if ey >= 0 else "N") if exit_side in "EW" else ("E" if ex >= 0 else "W")
    return entry_side, exit_side

def edge_cell(side, pos):
    """A cell on an edge (never a corner); pos 0..1 along it."""
    if side in "EW": return (0 if side == "W" else W - 1, 1 + round(pos * (H - 3)))
    return (1 + round(pos * (W - 3)), 0 if side == "N" else H - 1)

def inward(cell, side):
    dx, dy = STEP[OPP[side]]; return (cell[0] + dx, cell[1] + dy)

def across_join(cell, side):
    """Where an exit cell on `side` lands on the next section's opposite edge."""
    return (W - 1 - cell[0], cell[1]) if side in "EW" else (cell[0], H - 1 - cell[1])

# ---------- the road ----------

def make_line(rng, entry, exit_, esd, xsd):
    """A wandering road from entry to exit: 4 to 6 waypoints along the straight line, pushed sideways, joined by stair-steps with chunks of 1 to 6."""
    a, b = inward(entry, esd), inward(exit_, xsd)
    k = rng.randint(4, 6)
    vx, vy = b[0] - a[0], b[1] - a[1]; n = math.hypot(vx, vy) or 1; px, py = -vy / n, vx / n
    off = [0.0] + [rng.uniform(-3.6, 3.6) for _ in range(k - 1)] + [0.0]
    clamp = lambda x, y: (max(1, min(W - 2, round(x))), max(1, min(H - 2, round(y))))
    pts = [a] + [clamp(a[0] + vx * i / k + px * off[i], a[1] + vy * i / k + py * off[i]) for i in range(1, k)] + [b]
    line = [entry, a]
    for (x, y), q in zip(pts, pts[1:]):
        dx, dy = q[0] - x, q[1] - y
        while dx or dy:
            if dx and (not dy or rng.random() < abs(dx) / (abs(dx) + abs(dy))):
                sg = 1 if dx > 0 else -1; run = rng.randint(1, min(abs(dx), CAP)); dx -= sg * run
                line += [(x + sg * (i + 1), y) for i in range(run)]; x += sg * run
            else:
                sg = 1 if dy > 0 else -1; run = rng.randint(1, min(abs(dy), CAP)); dy -= sg * run
                line += [(x, y + sg * (i + 1)) for i in range(run)]; y += sg * run
    line.append(exit_)
    return [c for i, c in enumerate(line) if i == 0 or c != line[i - 1]]

# ---------- the landscape ----------

def noise_field(rng, scale):
    """Smooth value noise W x H in 0..1: random values on a coarse grid, smoothstep-blended."""
    g = [[rng.random() for _ in range(W // scale + 3)] for _ in range(H // scale + 3)]
    def at(x, y):
        fx, fy = x / scale, y / scale; ix, iy = int(fx), int(fy); tx, ty = fx - ix, fy - iy
        tx, ty = tx * tx * (3 - 2 * tx), ty * ty * (3 - 2 * ty)
        top = g[iy][ix] * (1 - tx) + g[iy][ix + 1] * tx; bot = g[iy + 1][ix] * (1 - tx) + g[iy + 1][ix + 1] * tx
        return top * (1 - ty) + bot * ty
    return [[at(x, y) for x in range(W)] for y in range(H)]

def quantile(sorted_vals, f): return sorted_vals[min(len(sorted_vals) - 1, max(0, int(len(sorted_vals) * f)))]

STAMPS = {"grassland": ["grove", "orchard", "hedgefield", "drift", "marsh"], "forest": ["log", "clearing", "grove", "marsh"], "coast": ["dune", "rockstack", "tidepool"],
    "tundra": ["icelake", "pines", "drift"], "desert": ["dune", "rockstack", "drift"], "mountain": ["rockstack", "pines", "drift"], "wetland": ["marsh", "grove", "tidepool"],
    "rainforest": ["grove", "log", "clearing", "marsh"], "island": ["dune", "tidepool", "grove", "rockstack"]}

def variety_ops(rng, land, near, ponds):
    """Ops for one section: the ponds the region picture puts here, then 2 to 3 stamps of the land's kind, 4+ tiles from the road and 7+ from each other."""
    ops = list(ponds); centres = [(op[1], op[2]) for op in ponds]
    free = [(x, y) for y in range(3, H - 3) for x in range(3, W - 3) if near.get((x, y), 9) >= 4]; rng.shuffle(free)
    kinds = STAMPS.get(land, ["grove", "drift"])
    for c in free:
        if len(ops) - len(ponds) >= rng.randint(2, 3): break
        if any(abs(c[0] - q[0]) + abs(c[1] - q[1]) < 7 for q in centres): continue
        k = rng.choice(kinds); x, y = c
        op = {"grove": ("grove", x, y, rng.randint(2, 3)), "orchard": ("orchard", x, y, x + 5, y + 3, 2), "hedgefield": ("hedgefield", x, y, min(W - 3, x + 7), min(H - 3, y + 4), x + 3),
              "drift": ("drift", x, y, 3, 2), "marsh": ("marsh", x, y, 2), "log": ("log", x, y, 4), "clearing": ("clearing", x, y, 2), "dune": ("dune", x, y, 3, 1),
              "rockstack": ("rockstack", x, y), "tidepool": ("tidepool", x, y), "icelake": ("icelake", x, y, 2), "pines": ("pines", x, y, 2)}[k]
        ops.append(op); centres.append(c)
    return ops

def carve(rng, feel, line, entry, exit_, first, boss_last, n_landmarks, land="", ponds=()):
    """Rows, tokens and landmark cells for one section, or None when this seed cannot be made to fit (the caller tries the next one).
    feel = (thicket share, unused, rough share) from LAND_FEEL. Walls thin out beside the road so the road stays readable."""
    wall, _, rough = feel
    big, small = noise_field(rng, 8), noise_field(rng, 4)
    fld = {(x, y): 0.65 * big[y][x] + 0.35 * small[y][x] for y in range(H) for x in range(W)}
    on = set(line)
    near = {}                                  # road distance (Manhattan) for cells within 3 of the road
    for x, y in line:
        for dy in range(-3, 4):
            for dx in range(-3, 4):
                k = (x + dx, y + dy); d = abs(dx) + abs(dy)
                if d < near.get(k, 9): near[k] = d
    thin = lambda c: 0.0 if near.get(c, 9) > 2 else -0.16 if near[c] == 2 else -0.30
    inner = [(x, y) for y in range(1, H - 1) for x in range(1, W - 1) if (x, y) not in on]
    t_wall = quantile(sorted(fld[c] + thin(c) for c in inner), 1 - wall * 0.75)
    rv = sorted(fld[c] for c in inner)
    rough_lo, rough_hi = quantile(rv, 0.30), quantile(rv, 0.30 + rough * 0.6)
    g = [["#"] * W for _ in range(H)]
    for c in inner:
        if fld[c] + thin(c) < t_wall: g[c[1]][c[0]] = "," if rough_lo <= fld[c] < rough_hi else "."
    prot = set()
    if VARIETY: apply_ops(g, prot, variety_ops(rng, land, near, ponds))
    prot -= on
    for x, y in line: g[y][x] = "," if rng.random() < rough * 0.5 and (x, y) not in (entry, exit_) else "."
    g[entry[1]][entry[0]] = "S" if first else "."
    g[exit_[1]][exit_[0]] = "9"
    L = len(line) - 1
    for _ in range(300):                       # close in on shortcuts: wall the middle of the shortcut that is farthest from the road
        sp = walk(g, entry, exit_)
        if sp is None: return None
        if (len(sp) - 1) / L >= SHORTCUT_AIM and max(run_lengths(sp), default=0) <= LONG_CAP: break
        cut = [c for c in sp if c not in on and c not in prot]
        if not cut: return None
        cx, cy = max(cut, key=lambda c: (near.get(c, 9), rng.random()))
        rad = rng.choice((1, 2))
        for dy in range(-rad, rad + 1):
            for dx in range(-rad, rad + 1):
                q = (cx + dx, cy + dy)
                if abs(dx) + abs(dy) <= rad and q not in on and q not in prot and 1 <= q[0] <= W - 2 and 1 <= q[1] <= H - 2: g[q[1]][q[0]] = "#"
    else: return None
    seen = reachable(g, entry)                 # floor the entry cannot reach (a pocket cut off by a thicket) becomes thicket
    for y in range(H):
        for x in range(W):
            if g[y][x] != "#" and (x, y) not in seen: g[y][x] = "#"
    share = sum(g[y][x] == "#" for y in range(1, H - 1) for x in range(1, W - 1)) / ((W - 2) * (H - 2))
    if not WALL_MIN <= share <= WALL_MAX: return None
    free = [c for c in seen if c not in on and 1 <= c[0] <= W - 2 and 1 <= c[1] <= H - 2 and g[c[1]][c[0]] in ".," and near.get(c, 9) >= 3]
    rng.shuffle(free)
    want, toks = rng.randint(1, 3), []         # finds: out in the landscape, 5+ apart
    for c in free:
        if len(toks) >= want: break
        if all(abs(c[0] - t[0]) + abs(c[1] - t[1]) >= 5 for t in toks): toks.append([c[0], c[1], "F"])
    if not toks: return None
    for x, y, _ in toks: g[y][x] = "F"
    if boss_last:
        x, y = line[-5]; g[y][x] = "E"; toks.append([x, y, "E"])
    cand = [c for c in seen if c not in on and g[c[1]][c[0]] in ".," and 3 <= c[1] <= H - 2 and 3 <= c[0] <= W - 4 and 2 <= near.get(c, 9) <= 5]
    rng.shuffle(cand)
    lms = []                                   # landmarks beside the road, spaced 6 apart
    for c in cand:
        if len(lms) >= n_landmarks: break
        if all(abs(c[0] - m[0]) + abs(c[1] - m[1]) >= 6 for m in lms): lms.append(c)
    if len(lms) < n_landmarks: return None
    return ["".join(r) for r in g], toks, lms

def pond_ops(ponds, line):
    """("pond", cx, cy, r) for the ponds this section owns: ponds = [(pond vector in region units from the road, pond radius)]."""
    out = []
    for (vx, vy), pr in ponds or []:
        n = math.hypot(vx, vy) or 1; px, py = line[len(line) // 2]
        out.append(("pond", max(5, min(W - 6, round(px + vx / n * 7))), max(5, min(H - 6, round(py + vy / n * 7))), 3 if pr >= 10 else 2))
    return out

def section_ponds(path, rcode, n):
    """For each section, the ponds (vector, radius) of the region picture that lie within 14 region units of its stretch of the route; a pond belongs to the section it is nearest to."""
    from bend_water import region_ponds
    fine = sample(path, n * 40); best = {}
    for pi, pd in enumerate(region_ponds(rcode)):
        for sec in range(n):
            seg = fine[sec * 40: sec * 40 + 41]; k = min(seg, key=lambda p: math.dist(p, (pd["x"], pd["y"]))); d = math.dist(k, (pd["x"], pd["y"])) - pd["r"]
            if d <= 14 and (pi not in best or d < best[pi][0]): best[pi] = (d, sec, ((pd["x"] - k[0], pd["y"] - k[1]), pd["r"]))
    out = [[] for _ in range(n)]
    for d, sec, v in best.values(): out[sec].append(v)
    return out

# ---------- a route ----------

def build_section(rid, salt, i, n, head, esd, xsd, prev_cell, feel, boss_last, names, land="", ponds=None):
    """One section, trying seeds until a road, landscape and tokens all fit. Raises NoFit."""
    for attempt in range(800):
        rng = random.Random(zlib.crc32(f"gv-bend|{rid}|{salt}|{i}|{attempt}".encode()))
        entry = across_join(prev_cell, OPP[esd]) if prev_cell else edge_cell(esd, rng.uniform(0.3, 0.7))
        lean = 0.5 + 0.3 * DIRS[head][1 if xsd in "EW" else 0]            # lean the exit toward the heading
        exit_ = edge_cell(xsd, min(0.9, max(0.1, rng.uniform(lean - 0.2, lean + 0.2))))
        line = make_line(rng, entry, exit_, esd, xsd)
        if len(line) < MIN_LINE or not road_ok(line): continue
        res = carve(rng, feel, line, entry, exit_, i == 0, boss_last, len(names), land, pond_ops(ponds, line))
        if res: return entry, exit_, line, res
    raise NoFit(f"section {i + 1}")

def build_route(r, group, end_kind, routes_lm, region=None):
    """r = a route in the game's map shape (sections with feature / caption); group and end_kind come from claude/route-list.md."""
    rid, n = int(r["route_id"]), len(r["sections"])
    boss = {"lair": "boss", "delve": "miniboss"}.get(end_kind, "")
    if r["land"] not in LAND_FEEL: raise SystemExit(f"route {rid}: no land feel for '{r['land']}' in gen_trail_maps.LAND_FEEL")
    home, away = group_regions(group)
    path, kind, rcode = region_path(rid, r["from"], r["to"], region or home, away)
    pts = sample(path, n); ponds = section_ponds(path, rcode, n) if VARIETY else [[] for _ in range(n)]
    for salt in range(6):                      # if a later section cannot fit the join, start the whole route over with new seeds
        try:
            secs, prev_exit, prev_cell = [], None, None
            for i in range(n):
                head = snap(pts[i + 1][0] - pts[i][0], pts[i + 1][1] - pts[i][1])
                esd, xsd = sides_for(head, i, prev_exit)
                names = [lm[2] for lm in (routes_lm[i] if i < len(routes_lm) else [])]
                entry, exit_, line, (rows, toks, lms) = build_section(rid, salt, i, n, head, esd, xsd, prev_cell, LAND_FEEL[r["land"]], bool(boss) and i == n - 1, names, r["land"], ponds[i])
                s = dict(r["sections"][i]); s.update(rows=rows, tokens=toks, landmarks=[[x, y, nm, 0] for (x, y), nm in zip(lms, names)], w=W, h=H, heading=head,
                    entry={"side": esd, "x": entry[0], "y": entry[1]}, exit={"side": xsd, "x": exit_[0], "y": exit_[1]}, line=[list(c) for c in line])
                secs.append(s); prev_exit, prev_cell = xsd, exit_
            return {"route_id": rid, "from": r["from"], "to": r["to"], "land": r["land"], "w": W, "h": H, "region": rcode, "path_kind": kind, "boss": boss, "sections": secs}
        except NoFit as e: print(f"route {rid}: {e} did not fit, new seeds (try {salt + 2})", file=sys.stderr)
    raise SystemExit(f"route {rid}: could not be built")

def write(out):
    d = os.path.join(REPO, "claude", "bend-prototype-v2" if VARIETY else "bend-prototype"); os.makedirs(d, exist_ok=True)
    base = os.path.join(d, f"route-{out['route_id']}")
    json.dump(out, open(base + ".json", "w"), indent=1, ensure_ascii=False)
    with open(base + ".txt", "w") as f:
        for i, s in enumerate(out["sections"]):
            f.write(f"section {i + 1}: heading {s['heading']}, in {s['entry']['side']} {s['entry']['x']},{s['entry']['y']}  out {s['exit']['side']} {s['exit']['x']},{s['exit']['y']}\n")
            f.write("\n".join(s["rows"]) + "\n\n")
    print(f"wrote {base}.json (region {out['region']}, path {out['path_kind']}, boss '{out['boss']}')")

def load_sources():
    """{route id: route in the game's map shape} from every claude/*-trail-maps folder; the 22-wide hand-made Maplewold file wins over the older 11-wide one."""
    out = {}
    for f in sorted(glob.glob(os.path.join(REPO, "claude", "*-trail-maps", "*.json"))):
        if f.endswith("_landmarks.json") or f.endswith("maplewold_trail_maps.json") or f.endswith("_preview.json"): continue
        j = json.load(open(f)); rs = j["routes"] if isinstance(j, dict) else j
        for r in rs: out[int(r["route_id"])] = r
    return out

def load_landmarks():
    lm = {}
    for f in (os.path.join(REPO, "claude/maplewold-trail-maps/maplewold_landmarks.json"), os.path.join(REPO, "claude/trail-landmarks/other_regions_landmarks.json")):
        lm.update({k: v for k, v in json.load(open(f)).items() if not k.startswith("_")})
    return lm

def main():
    global VARIETY
    VARIETY = "--variety" in sys.argv
    ids = [int(a) for a in sys.argv[1:] if a.isdigit()]
    region = next((a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--region=")), None)
    src, lm = load_sources(), load_landmarks()
    info = {rid: (grp, endk) for grp, rid, _f, _t, _l, _s, endk in parse()}
    if "--all" in sys.argv: ids = sorted(info)
    for rid in ids or [313]:
        if rid not in src or rid not in info: raise SystemExit(f"route {rid} has no source map or is not in claude/route-list.md")
        write(build_route(src[rid], *info[rid], lm.get(str(rid), []), region))

if __name__ == "__main__": main()
