#!/usr/bin/env python3
"""PROTOTYPE: bendy trail maps (plan: claude/plan-route-map-bends.md). Does NOT touch game data.
Makes one route (default 313, Poppyburrow -> Beaverdam Tunnels) as 30 x 18 sections whose road wanders, enters and leaves on any edge
(headings from the region road, snapped to 8 compass directions), then writes
    claude/bend-prototype/route-<id>.json     (shape of the game maps plus w, h, entry, exit, line per section)
    claude/bend-prototype/route-<id>.txt      (ASCII preview)
Check it with:  python3 tools/lint_trail_bends.py claude/bend-prototype/route-313.json
Usage: python3 tools/gen_bendy_trail_proto.py [route_id]     (needs php for tools/map_layout.php)
Rules: the road wanders; thickets close in on the inside of bends so a shortcut saves at most about 18% (and never a straight run over 10); wiggle (straight run <= 6 tiles, one run up to 10 per section), entry of section N+1 = exit of N moved across the join,
S on the first entry, one 9 on the exit edge, 1 or 2 F on short spurs off the line, E on the line 4 steps from the exit on the last section of a delve/lair."""
import json, math, os, random, re, subprocess, sys, zlib
from collections import deque
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_trail_maps import LAND_FEEL      # one table of land feel for both generators
W, H = 30, 18
CAP, LONG_CAP = 6, 10
# (name, dx, dy) with y pointing down (screen); 8 compass headings
DIRS = {"E": (1, 0), "SE": (1, 1), "S": (0, 1), "SW": (-1, 1), "W": (-1, 0), "NW": (-1, -1), "N": (0, -1), "NE": (1, -1)}
OPP = {"E": "W", "W": "E", "N": "S", "S": "N"}
STEP = {"E": (1, 0), "W": (-1, 0), "N": (0, -1), "S": (0, 1)}

def snap(vx, vy):
    """The compass heading (of 8) closest to a vector: the largest dot product with a unit direction."""
    return max(DIRS, key=lambda k: (vx * DIRS[k][0] + vy * DIRS[k][1]) / math.hypot(*DIRS[k]))

def catmull(p0, p1, p2, p3, t):
    return tuple(0.5 * ((2 * p1[i]) + (-p0[i] + p2[i]) * t + (2 * p0[i] - 5 * p1[i] + 4 * p2[i] - p3[i]) * t * t + (-p0[i] + 3 * p1[i] - 3 * p2[i] + p3[i]) * t ** 3) for i in (0, 1))

def region_path(rid, frm, to, region=None):
    """The route's curve on the region frame, and how it was found: 'road' = the road's own points (Catmull-Rom through its neighbours, so it leaves a stop the way the
    road arrives), 'trail' = a drawn side trail, 'bowed' = no line in the layout, a curve bowed to one side by route id (plan item 8).
    Village names repeat across regions, so a stop pair on a real road or trail wins over two names that merely sit in one region (--region=CODE forces one)."""
    lay = json.loads(subprocess.check_output(["php", os.path.join(REPO, "tools", "map_layout.php")]))["regions"]
    found = []
    for x in lay:
        if region and x["code"] != region: continue
        pos = {x["town"]["name"]: (x["town"]["x"], x["town"]["y"])}
        for s_ in x["stops"]: pos[s_["name"]] = (s_["x"], s_["y"])
        if frm not in pos or to not in pos: continue
        inv = {v: k for k, v in pos.items()}
        for r in x["roads"]:
            pts = [tuple(q) for q in r["pts"]]
            for i in range(len(pts) - 1):
                a_, b_ = inv.get(pts[i]), inv.get(pts[i + 1])
                if {a_, b_} == {frm, to}:
                    p0, p3 = pts[max(0, i - 1)], pts[min(len(pts) - 1, i + 2)]
                    cur = [catmull(p0, pts[i], pts[i + 1], p3, k / 12) for k in range(13)]
                    found.append((0, x["code"], cur if a_ == frm else cur[::-1], "road"))
        for t in x["trails"]:
            if {inv.get(tuple(t[0])), inv.get(tuple(t[-1]))} == {frm, to}:
                found.append((1, x["code"], [tuple(q) for q in t] if inv.get(tuple(t[0])) == frm else [tuple(q) for q in t][::-1], "trail"))
        a, b = pos[frm], pos[to]
        mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
        vx, vy = b[0] - a[0], b[1] - a[1]; n = math.hypot(vx, vy) or 1
        bow = 0.18 * n * (1 if rid % 2 else -1)
        found.append((2, x["code"], [a, (mx - vy / n * bow, my + vx / n * bow), b], "bowed"))
    if not found: raise SystemExit(f"route {rid}: {frm} -> {to} not found in the layout")
    found.sort(key=lambda f: f[0])
    best = [f for f in found if f[0] == found[0][0]]
    if len(best) > 1: print(f"warn: {len(best)} regions match route {rid} ({', '.join(f[1] for f in best)}); using {best[0][1]}; pass --region=CODE to choose", file=sys.stderr)
    return best[0][2], best[0][3], best[0][1]

def sample(path, n):
    seg = [math.dist(path[i], path[i + 1]) for i in range(len(path) - 1)]; tot = sum(seg); out = []
    for k in range(n + 1):
        t = tot * k / n; i = 0
        while i < len(seg) - 1 and t > seg[i]: t -= seg[i]; i += 1
        f = min(1, t / seg[i]) if seg[i] else 0
        out.append((path[i][0] + (path[i + 1][0] - path[i][0]) * f, path[i][1] + (path[i + 1][1] - path[i][1]) * f))
    return out

def sides_for(heading, idx, prev_exit):
    """Exit side from a compass heading; a diagonal alternates its two sides section by section. The entry side is always the opposite of the previous exit
    (so the join lines up). If the heading would send the road back the way it came (exit side = where it came in), turn it onto a side edge instead."""
    ex, ey = DIRS[heading]
    if ex and ey: exit_side = ("E" if ex > 0 else "W") if idx % 2 == 0 else ("S" if ey > 0 else "N")
    elif ex: exit_side = "E" if ex > 0 else "W"
    else: exit_side = "S" if ey > 0 else "N"
    entry_side = OPP[prev_exit] if prev_exit else OPP[exit_side]
    if exit_side == entry_side:     # a U-turn: leave by a side edge
        exit_side = ("S" if ey >= 0 else "N") if exit_side in "EW" else ("E" if ex >= 0 else "W")
    return entry_side, exit_side

def edge_cell(side, pos):   # pos: 0..1 along the edge
    if side in "EW": y = 1 + round(pos * (H - 3)); return (0 if side == "W" else W - 1, y)
    x = 1 + round(pos * (W - 3)); return (x, 0 if side == "N" else H - 1)

def inward(cell, side):     # the first interior cell next to an edge cell on that side
    dx, dy = STEP[OPP[side]]; return (cell[0] + dx, cell[1] + dy)

def steps_of(line): return [(b[0] - a[0], b[1] - a[1]) for a, b in zip(line, line[1:])]

def ok_line(line):
    """Straight runs <= 6 (one up to 10 per section), no cell used twice, no step straight back."""
    if len(set(line)) != len(line): return False
    st = steps_of(line)
    if any(a[0] == -b[0] and a[1] == -b[1] for a, b in zip(st, st[1:])): return False
    runs, cur, prev = [], 0, None
    for s_ in st:
        if s_ == prev: cur += 1
        else:
            if prev is not None: runs.append(cur)
            cur, prev = 1, s_
    runs.append(cur)
    return max(runs) <= LONG_CAP and sum(1 for r in runs if r > CAP) <= 1

def walk(g, st, en):
    """Shortest 4-way walk over non-wall cells, as a list of cells (or None)."""
    prev = {st: None}; q = deque([st])
    while q:
        c = q.popleft()
        if c == en: break
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (c[0] + dx, c[1] + dy)
            if 0 <= n[0] < W and 0 <= n[1] < H and g[n[1]][n[0]] != "#" and n not in prev: prev[n] = c; q.append(n)
    if en not in prev: return None
    out, c = [], en
    while c: out.append(c); c = prev[c]
    return out[::-1]

def max_run(cells):
    best, cur, prev = 0, 0, None
    for a, b in zip(cells, cells[1:]):
        s_ = (b[0] - a[0], b[1] - a[1])
        cur = cur + 1 if s_ == prev else 1; prev = s_; best = max(best, cur)
    return best

def make_line(rng, entry, exit_, esd, xsd):
    a, b = inward(entry, esd), inward(exit_, xsd)
    k = rng.randint(4, 6)
    pts = []
    vx, vy = b[0] - a[0], b[1] - a[1]; n = math.hypot(vx, vy) or 1; px, py = -vy / n, vx / n
    off = [0.0] + [rng.uniform(-1, 1) * 3.6 for _ in range(k - 1)] + [0.0]
    for i in range(k + 1):
        t = i / k
        x = a[0] + vx * t + px * off[i]; y = a[1] + vy * t + py * off[i]
        pts.append((max(1, min(W - 2, round(x))), max(1, min(H - 2, round(y)))))
    pts[0], pts[-1] = a, b
    line = [entry, a]
    for p, q in zip(pts, pts[1:]):
        x, y = p; dx, dy = q[0] - x, q[1] - y
        while dx or dy:
            axis_h = bool(dx) and (not dy or rng.random() < abs(dx) / (abs(dx) + abs(dy)))
            if axis_h:
                sgn = 1 if dx > 0 else -1; run = rng.randint(1, min(abs(dx), CAP)); x += sgn * run; dx -= sgn * run
                line += [(x - sgn * (run - 1 - i), y) for i in range(run)]
            else:
                sgn = 1 if dy > 0 else -1; run = rng.randint(1, min(abs(dy), CAP)); y += sgn * run; dy -= sgn * run
                line += [(x, y - sgn * (run - 1 - i)) for i in range(run)]
    line.append(exit_)
    out = [line[0]]
    for c in line[1:]:
        if c != out[-1]: out.append(c)
    return out

def noise_field(rng, scale):
    """Smooth value noise, W x H, 0..1: random values on a coarse grid, smoothstep-blended."""
    gw, gh = W // scale + 3, H // scale + 3
    g = [[rng.random() for _ in range(gw)] for _ in range(gh)]
    def at(x, y):
        fx, fy = x / scale, y / scale; ix, iy = int(fx), int(fy); tx, ty = fx - ix, fy - iy
        tx, ty = tx * tx * (3 - 2 * tx), ty * ty * (3 - 2 * ty)
        a = g[iy][ix] * (1 - tx) + g[iy][ix + 1] * tx; b = g[iy + 1][ix] * (1 - tx) + g[iy + 1][ix + 1] * tx
        return a * (1 - ty) + b * ty
    return [[at(x, y) for x in range(W)] for y in range(H)]

SHORTCUT = 0.82      # the shortest walk may be at most 18% shorter than the road line

def carve(rng, land_feel, line, entry, exit_, first, boss_last, lm_names):
    """Off the road is a landscape, not rock: open meadow, rough ground, and thickets / outcrops (#) in soft blobs that come and go (wall = share of thicket,
    rough = share of rough ground; walls thin out beside the road). Then thickets close in on the inside of the bends until a shortcut across the meadow saves
    at most 18% and never gives a straight run over 10. Returns (rows, tokens, landmarks) or None if this seed cannot be made to fit."""
    wall, _widen, rough = land_feel
    big, small = noise_field(rng, 8), noise_field(rng, 4)
    fld = [[0.65 * big[y][x] + 0.35 * small[y][x] for x in range(W)] for y in range(H)]
    on = set(line)
    near = {}
    for x, y in line:
        for dy in range(-3, 4):
            for dx in range(-3, 4):
                k = (x + dx, y + dy); d = abs(dx) + abs(dy)
                if k not in near or d < near[k]: near[k] = d
    bias = lambda c: 0.0 if near.get(c, 9) > 2 else -0.16 if near.get(c) == 2 else -0.30
    inner = [(x, y) for y in range(1, H - 1) for x in range(1, W - 1) if (x, y) not in on]
    vals = sorted(fld[y][x] + bias((x, y)) for x, y in inner)
    t_wall = vals[int(len(vals) * (1 - wall * 0.75))]
    rvals = sorted(fld[y][x] for x, y in inner)
    t_rough_lo, t_rough_hi = rvals[int(len(rvals) * 0.30)], rvals[int(len(rvals) * (0.30 + rough * 0.6))]
    g = [["#"] * W for _ in range(H)]
    for x, y in inner:
        if fld[y][x] + bias((x, y)) >= t_wall: continue
        g[y][x] = "," if t_rough_lo <= fld[y][x] < t_rough_hi else "."
    for x, y in line: g[y][x] = "."
    for x, y in line:      # the road itself: now and then a rough patch on it too
        if rng.random() < rough * 0.5 and (x, y) not in (entry, exit_): g[y][x] = ","
    g[entry[1]][entry[0]] = "S" if first else "."
    g[exit_[1]][exit_[0]] = "9"
    L = len(line) - 1
    for _ in range(300):   # close in on shortcuts
        sp = walk(g, entry, exit_)
        if sp is None: return None
        if (len(sp) - 1) / L >= SHORTCUT and max_run(sp) <= LONG_CAP: break
        cut = [c for c in sp if c not in on]
        if not cut: return None
        cx, cy = max(cut, key=lambda c: (near.get(c, 9), rng.random()))
        rad = rng.choice((1, 2))
        for dy in range(-rad, rad + 1):
            for dx in range(-rad, rad + 1):
                q = (cx + dx, cy + dy)
                if abs(dx) + abs(dy) <= rad and q not in on and 1 <= q[0] <= W - 2 and 1 <= q[1] <= H - 2: g[q[1]][q[0]] = "#"
    else: return None
    seen, st = {entry}, [entry]      # drop floor the entry cannot reach (a pocket cut off by a thicket)
    while st:
        cx, cy = st.pop()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (cx + dx, cy + dy)
            if 0 <= n[0] < W and 0 <= n[1] < H and n not in seen and g[n[1]][n[0]] != "#": seen.add(n); st.append(n)
    for y in range(H):
        for x in range(W):
            if g[y][x] != "#" and (x, y) not in seen: g[y][x] = "#"
    share = sum(g[y][x] == "#" for y in range(1, H - 1) for x in range(1, W - 1)) / ((W - 2) * (H - 2))
    if not 0.12 <= share <= 0.45: return None        # too bare or too choked: try another seed
    free = [c for c in seen if c not in on and 1 <= c[0] <= W - 2 and 1 <= c[1] <= H - 2 and g[c[1]][c[0]] in ".," and near.get(c, 9) >= 3]
    rng.shuffle(free)
    want = rng.randint(1, 3)        # finds: out in the landscape, 3+ from the road, 5+ apart
    toks = []
    for c in free:
        if len(toks) >= want: break
        if all(abs(c[0] - t[0]) + abs(c[1] - t[1]) >= 5 for t in toks): toks.append([c[0], c[1], "F"])
    if not toks: return None
    for x, y, _ in toks: g[y][x] = "F"
    if boss_last:
        x, y = line[-5]; g[y][x] = "E"; toks.append([x, y, "E"])
    lms = []              # landmarks: floor beside the road (2 to 5 away), feet row >= 3 so a tall sprite keeps its top inside the map, spaced 6 apart
    cand = [c for c in seen if c not in on and g[c[1]][c[0]] in ".," and 3 <= c[1] <= H - 2 and 3 <= c[0] <= W - 4 and 2 <= near.get(c, 9) <= 5]
    rng.shuffle(cand)
    for c in cand:
        if len(lms) >= len(lm_names): break
        if all(abs(c[0] - m[0]) + abs(c[1] - m[1]) >= 6 for m in lms): lms.append(c)
    return ["".join(r) for r in g], toks, lms

def boss_of(rid):
    """'miniboss' for a route that ends at a delve, 'boss' at a lair (from claude/route-list.md), else ''."""
    for line in open(os.path.join(REPO, "claude", "route-list.md"), encoding="utf-8"):
        m = re.match(r"\|\s*(\d+)\s*\|(.*)\|", line)
        if m and int(m.group(1)) == rid: return "boss" if "(lair)" in m.group(2) else "miniboss" if "(delve)" in m.group(2) else ""
    return ""

def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    region = next((a.split("=")[1] for a in sys.argv[1:] if a.startswith("--region=")), None)
    rid = int(args[0]) if args else 313
    src = json.load(open(os.path.join(REPO, "claude/maplewold-trail-maps/maplewold_trail_maps_22wide.json")))
    r = next(x for x in src if x["route_id"] == rid)
    lm_src = json.load(open(os.path.join(REPO, "claude/maplewold-trail-maps/maplewold_landmarks.json"))).get(str(rid), [])
    n = len(r["sections"])
    boss = boss_of(rid)
    path, kind, rcode = region_path(rid, r["from"], r["to"], region)
    pts = sample(path, n)
    secs, prev_exit, prev_cell = [], None, None
    for i in range(n):
        head = snap(pts[i + 1][0] - pts[i][0], pts[i + 1][1] - pts[i][1])
        esd, xsd = sides_for(head, i, prev_exit)
        names = [lm[2] for lm in (lm_src[i] if i < len(lm_src) else [])]
        for attempt in range(800):
            rng = random.Random(zlib.crc32(f"gv-bend|{rid}|{i}|{attempt}".encode()))
            if prev_cell: entry = (W - 1 - prev_cell[0], prev_cell[1]) if esd in "EW" else (prev_cell[0], H - 1 - prev_cell[1])
            else: entry = edge_cell(esd, rng.uniform(0.3, 0.7))
            lean = 0.5 + 0.3 * (DIRS[head][1 if xsd in "EW" else 0])   # lean the exit toward the heading
            exit_ = edge_cell(xsd, min(0.9, max(0.1, rng.uniform(lean - 0.2, lean + 0.2))))
            line = make_line(rng, entry, exit_, esd, xsd)
            if not ok_line(line) or len(line) < 25: continue
            res = carve(rng, LAND_FEEL[r["land"]], line, entry, exit_, i == 0, bool(boss) and i == n - 1, names)
            if res: break
        else: raise SystemExit(f"no fitting section {i + 1} for route {rid}")
        rows, toks, lms = res
        s = dict(r["sections"][i]); s["rows"] = rows; s["tokens"] = toks; s["landmarks"] = [[x, y, names[k], 0] for k, (x, y) in enumerate(lms)]
        s.update({"w": W, "h": H, "heading": head, "entry": {"side": esd, "x": entry[0], "y": entry[1]}, "exit": {"side": xsd, "x": exit_[0], "y": exit_[1]}, "line": [list(c) for c in line]})
        secs.append(s); prev_exit, prev_cell = xsd, exit_
    out = {"route_id": rid, "from": r["from"], "to": r["to"], "land": r["land"], "w": W, "h": H, "region": rcode, "path_kind": kind, "boss": boss, "sections": secs}
    d = os.path.join(REPO, "claude", "bend-prototype"); os.makedirs(d, exist_ok=True)
    json.dump(out, open(os.path.join(d, f"route-{rid}.json"), "w"), indent=1, ensure_ascii=False)
    with open(os.path.join(d, f"route-{rid}.txt"), "w") as f:
        for i, s in enumerate(secs):
            f.write(f"section {i + 1}: heading {s['heading']}, in {s['entry']['side']} {s['entry']['x']},{s['entry']['y']}  out {s['exit']['side']} {s['exit']['x']},{s['exit']['y']}\n")
            f.write("\n".join(s["rows"]) + "\n\n")
    print("wrote", os.path.join(d, f"route-{rid}.json"), f"(region {rcode}, path {kind}, boss '{boss}')")

if __name__ == "__main__": main()
