#!/usr/bin/env python3
"""PROTOTYPE: bendy trail maps (plan: claude/plan-route-map-bends.md). Does NOT touch game data.
Makes one route (default 313, Poppyburrow -> Beaverdam Tunnels) as 30 x 18 sections whose road wanders, enters and leaves on any edge
(headings from the region road, snapped to 8 compass directions), then writes
    claude/bend-prototype/route-<id>.json     (shape of the game maps plus w, h, entry, exit, line per section)
    claude/bend-prototype/route-<id>.txt      (ASCII preview)
Check it with:  python3 tools/lint_trail_bends.py claude/bend-prototype/route-313.json
Usage: python3 tools/gen_bendy_trail_proto.py [route_id]     (needs php for tools/map_layout.php)
Rules: wiggle (straight run <= 6 tiles, one run up to 10 per section), entry of section N+1 = exit of N moved across the join,
S on the first entry, one 9 on the exit edge, 1 or 2 F on short spurs off the line, E on the line 4 steps from the exit on the last section of a delve/lair."""
import json, math, os, random, subprocess, sys, zlib
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
W, H = 30, 18
CAP, LONG_CAP = 6, 10
# (name, dx, dy) with y pointing down (screen); 8 compass headings
DIRS = {"E": (1, 0), "SE": (1, 1), "S": (0, 1), "SW": (-1, 1), "W": (-1, 0), "NW": (-1, -1), "N": (0, -1), "NE": (1, -1)}
OPP = {"E": "W", "W": "E", "N": "S", "S": "N"}
STEP = {"E": (1, 0), "W": (-1, 0), "N": (0, -1), "S": (0, 1)}

def snap(vx, vy):
    a = math.atan2(vy, vx)
    return min(DIRS, key=lambda k: abs(math.atan2(math.sin(a - math.atan2(DIRS[k][1], DIRS[k][0])), math.cos(a - math.atan2(DIRS[k][1], DIRS[k][0])))))

def region_path(rid, frm, to):
    """The route's curve on the region frame: the road's own points if there are any, else a side trail bowed to one side (plan item 8)."""
    lay = json.loads(subprocess.check_output(["php", os.path.join(REPO, "tools", "map_layout.php")]))["regions"]
    for x in lay:
        pos = {x["town"]["name"]: (x["town"]["x"], x["town"]["y"])}
        for s in x["stops"]: pos[s["name"]] = (s["x"], s["y"])
        if frm in pos and to in pos:
            a, b = pos[frm], pos[to]
            mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
            vx, vy = b[0] - a[0], b[1] - a[1]; n = math.hypot(vx, vy) or 1
            bow = 0.18 * n * (1 if rid % 2 else -1)       # side trails bow left or right by route id
            return [a, (mx - vy / n * bow, my + vx / n * bow), b]
    raise SystemExit("route ends not found in the layout")

def sample(path, n):
    seg = [math.dist(path[i], path[i + 1]) for i in range(len(path) - 1)]; tot = sum(seg); out = []
    for k in range(n + 1):
        t = tot * k / n; i = 0
        while i < len(seg) - 1 and t > seg[i]: t -= seg[i]; i += 1
        f = min(1, t / seg[i]) if seg[i] else 0
        out.append((path[i][0] + (path[i + 1][0] - path[i][0]) * f, path[i][1] + (path[i + 1][1] - path[i][1]) * f))
    return out

def sides_for(heading, idx, prev_exit):
    """Exit side from a compass heading; a diagonal alternates its two sides section by section. Entry side is the opposite of the previous exit."""
    ex, ey = DIRS[heading]
    if ex and ey: exit_side = ("E" if ex > 0 else "W") if idx % 2 == 0 else ("S" if ey > 0 else "N")
    elif ex: exit_side = "E" if ex > 0 else "W"
    else: exit_side = "S" if ey > 0 else "N"
    entry_side = OPP[prev_exit] if prev_exit else OPP[exit_side]
    if entry_side == exit_side: entry_side = OPP[exit_side]
    return entry_side, exit_side

def edge_cell(side, pos):   # pos: 0..1 along the edge
    if side in "EW": y = 1 + round(pos * (H - 3)); return (0 if side == "W" else W - 1, y)
    x = 1 + round(pos * (W - 3)); return (x, 0 if side == "N" else H - 1)

def inward(cell, side):     # the first interior cell next to an edge cell on that side
    dx, dy = STEP[OPP[side]]; return (cell[0] + dx, cell[1] + dy)

def steps_of(line): return [(b[0] - a[0], b[1] - a[1]) for a, b in zip(line, line[1:])]

def runs_ok(line):
    longs, cur, prev = 0, 0, None
    runs = []
    for s in steps_of(line):
        if s == prev: cur += 1
        else:
            if prev is not None: runs.append(cur)
            cur, prev = 1, s
    runs.append(cur)
    return max(runs) <= LONG_CAP and sum(1 for r in runs if r > CAP) <= 1

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

def carve(rng, land_feel, line, entry, exit_, first, boss_last, tries=0):
    wall, widen, rough = land_feel
    g = [["#"] * W for _ in range(H)]
    for x, y in line: g[y][x] = "."
    on = set(line)
    for _ in range(int(widen * 40)):     # widen a little: floor beside floor, never on the border
        x, y = rng.randint(1, W - 2), rng.randint(1, H - 2)
        if g[y][x] == "#" and any(g[y + dy][x + dx] in ".," for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))): g[y][x] = "."
    spurs = []
    for _ in range(rng.randint(1, 2)):   # finds sit at the end of short spurs off the line
        cand = [i for i in range(3, len(line) - 3)]
        rng.shuffle(cand)
        for i in cand:
            x, y = line[i]; dx, dy = rng.choice(((1, 0), (-1, 0), (0, 1), (0, -1)))
            ln = rng.randint(3, 4); cells = [(x + dx * k, y + dy * k) for k in range(2, ln + 2)]
            if (x + dx, y + dy) not in on and g[y + dy][x + dx] == "#" and all(1 <= cx <= W - 2 and 1 <= cy <= H - 2 and g[cy][cx] == "#" for cx, cy in cells):
                for cx, cy in [(x + dx, y + dy)] + cells: g[cy][cx] = "."
                spurs.append(cells[-1]); break
    for y in range(1, H - 1):
        for x in range(1, W - 1):
            if g[y][x] == "." and rng.random() < rough: g[y][x] = ","
    g[entry[1]][entry[0]] = "S" if first else "."
    g[exit_[1]][exit_[0]] = "9"
    toks = []
    for x, y in spurs: g[y][x] = "F"; toks.append([x, y, "F"])
    if boss_last:
        x, y = line[-5]; g[y][x] = "E"; toks.append([x, y, "E"])
    return ["".join(r) for r in g], toks

def main():
    rid = int(sys.argv[1]) if len(sys.argv) > 1 else 313
    src = json.load(open(os.path.join(REPO, "claude/maplewold-trail-maps/maplewold_trail_maps_22wide.json")))
    r = next(x for x in src if x["route_id"] == rid)
    n = len(r["sections"])
    feel = {"forest": (0.45, 0.35, 0.25), "grassland": (0.30, 0.55, 0.30), "coast": (0.30, 0.45, 0.2), "tundra": (0.40, 0.35, 0.25)}[r["land"]]
    path = region_path(rid, r["from"], r["to"])
    pts = sample(path, n)
    secs, prev_exit, prev_cell = [], None, None
    for i in range(n):
        head = snap(pts[i + 1][0] - pts[i][0], pts[i + 1][1] - pts[i][1])
        esd, xsd = sides_for(head, i, prev_exit)
        for attempt in range(400):
            rng = random.Random(zlib.crc32(f"gv-bend|{rid}|{i}|{attempt}".encode()))
            if prev_cell: entry = (W - 1 - prev_cell[0], prev_cell[1]) if esd in "EW" else (prev_cell[0], H - 1 - prev_cell[1])
            else: entry = edge_cell(esd, rng.uniform(0.3, 0.7))
            lean = 0.5 + 0.3 * (DIRS[head][1 if xsd in "EW" else 0])   # lean the exit toward the heading
            exit_ = edge_cell(xsd, min(0.9, max(0.1, rng.uniform(lean - 0.2, lean + 0.2))))
            line = make_line(rng, entry, exit_, esd, xsd)
            if runs_ok(line) and len(line) >= 25: break
        else: raise SystemExit(f"no wiggly line for section {i + 1}")
        rows, toks = carve(rng, feel, line, entry, exit_, i == 0, i == n - 1 and r["sections"][-1].get("tokens") is not None and rid in (313, 315))
        s = dict(r["sections"][i]); s["rows"] = rows; s["tokens"] = toks
        s.update({"w": W, "h": H, "heading": head, "entry": {"side": esd, "x": entry[0], "y": entry[1]}, "exit": {"side": xsd, "x": exit_[0], "y": exit_[1]}, "line": [list(c) for c in line]})
        secs.append(s); prev_exit, prev_cell = xsd, exit_
    out = {"route_id": rid, "from": r["from"], "to": r["to"], "land": r["land"], "w": W, "h": H, "sections": secs}
    d = os.path.join(REPO, "claude", "bend-prototype"); os.makedirs(d, exist_ok=True)
    json.dump(out, open(os.path.join(d, f"route-{rid}.json"), "w"), indent=1, ensure_ascii=False)
    with open(os.path.join(d, f"route-{rid}.txt"), "w") as f:
        for i, s in enumerate(secs):
            f.write(f"section {i + 1}: heading {s['heading']}, in {s['entry']['side']} {s['entry']['x']},{s['entry']['y']}  out {s['exit']['side']} {s['exit']['x']},{s['exit']['y']}\n")
            f.write("\n".join(s["rows"]) + "\n\n")
    print("wrote", os.path.join(d, f"route-{rid}.json"))

if __name__ == "__main__": main()
