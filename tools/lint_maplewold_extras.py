#!/usr/bin/env python3
"""Lint for gates and extra mini-boss spots in the Maplewold bendy maps. Usage: python3 tools/lint_maplewold_extras.py claude/maplewold-bendy-maps/route-*.json
Gates (section field 'gates'): tiles inside the section, at least one on the road line; tool is an adventure tool type with a tier (1 Worn .. 4 Masterwork) that follows the region rule; kind lock = blocking the tiles cuts entry from exit,
  kind shortcut = still connected with the tiles blocked and the way round is at least 6 steps longer; on the last section of a boss route a gate comes before the E tile.
Extra mini-bosses (field 'extra_minibosses'): on the road line, 5+ steps from entry and 7+ from exit, 3+ steps from any gate, creature exists in creatures.txt for the route's land
  with the stated level, one per section, never on the starter routes 228 232 236 or the havens 311 316."""
import json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(HERE); sys.path.insert(0, HERE)
from bend_rules import walk
import re
_TP = open(os.path.join(REPO, "game/includes/tools.php"), encoding="utf-8").read()
TOOL_NAME = {(t, int(n)): name for t, n, name in re.findall(r"\['(\w+)', (\d), '([^']+)'", _TP)}   # (type, tier) -> name, from TOOL_ITEMS (tiers 1 Worn, 2 Sturdy, 3 Fine, 4 Masterwork)
GATHER = {"forage", "pick", "net", "bucket", "axe", "rod", "basket", "staff", "lantern"}
REGION_LEVEL = {"NA": 1}   # Maplewold = level 1. Gate rule: min_tier = region level + 1 (Maplewold: Sturdy), +1 per region level, capped at 4 (Masterwork)
FREE = {228, 232, 236, 311, 316}
CREATURES = {}
for l in open(os.path.join(REPO, "game/includes/data/creatures.txt"), encoding="utf-8"):
    if l.startswith("#") or "|" not in l: continue
    f = l.split("|"); CREATURES[f[0]] = (f[2], f[3].split(","), int(f[4]))

def lint(path):
    r = json.load(open(path)); bad = []; rid = r["route_id"]
    for i, s in enumerate(r["sections"]):
        t = f"section {i + 1}"; line = [tuple(c) for c in s["line"]]; en, ex = (s["entry"]["x"], s["entry"]["y"]), (s["exit"]["x"], s["exit"]["y"])
        gate_k = []
        for g in s.get("gates", []):
            tiles = [tuple(c) for c in g["tiles"]]; gate_k.append(g["road_index"])
            if not any(c in line for c in tiles): bad.append(f"{t}: gate '{g['label']}' has no tile on the road")
            if any(s["rows"][y][x] == "#" for x, y in tiles): bad.append(f"{t}: gate tile is a wall")
            if g["tool_type"] not in GATHER: bad.append(f"{t}: gate tool type {g['tool_type']} is not an adventure tool type")
            want = min(4, REGION_LEVEL.get(r["region"], 0) + 1)
            if g["kind"] not in ("lock", "shortcut"): bad.append(f"{t}: gate kind")
            if g["min_tier"] != want: bad.append(f"{t}: gate tier {g['min_tier']}, rule says {want}")
            if g["tool_name"] != TOOL_NAME.get((g["tool_type"], g["min_tier"])): bad.append(f"{t}: tool name {g['tool_name']} is not the tier {g['min_tier']} {g['tool_type']}")
            if not (5 <= g["road_index"] <= len(line) - 7): bad.append(f"{t}: gate too near the section ends")
            grid = [list(row) for row in s["rows"]]
            for x, y in tiles: grid[y][x] = "#"
            sp = walk(grid, en, ex)
            if g["kind"] == "lock" and sp is not None: bad.append(f"{t}: lock '{g['label']}' can be walked around")
            if g["kind"] == "shortcut":
                if sp is None: bad.append(f"{t}: shortcut '{g['label']}' has no way round")
                elif len(sp) - 1 < len(line) - 1 + 6: bad.append(f"{t}: the way round the shortcut is only {len(sp) - 1 - (len(line) - 1)} steps longer")
            if r.get("boss") and i == len(r["sections"]) - 1:
                e = next(((x, y) for y, row in enumerate(s["rows"]) for x, c in enumerate(row) if c == "E"), None)
                if e and line.index(e) < g["road_index"]: bad.append(f"{t}: gate after the E tile")
        minis = s.get("extra_minibosses", [])
        if len(minis) > 1: bad.append(f"{t}: more than one extra mini-boss")
        for m in minis:
            k = m["road_index"]
            if rid in FREE: bad.append(f"{t}: route {rid} must stay free of fights")
            if k >= len(line) or (m["x"], m["y"]) != line[k]: bad.append(f"{t}: mini-boss not on the road line")
            if not (5 <= k <= len(line) - 7): bad.append(f"{t}: mini-boss too near the section ends")
            if any(abs(k - gk) < 3 for gk in gate_k): bad.append(f"{t}: mini-boss within 3 steps of a gate")
            c = CREATURES.get(m["creature"])
            if not c: bad.append(f"{t}: unknown creature {m['creature']}")
            else:
                if c[0] != "large": bad.append(f"{t}: {m['creature']} is {c[0]}, want large")
                if r["land"] not in c[1]: bad.append(f"{t}: {m['creature']} does not live in {r['land']}")
                if c[2] != m["level"]: bad.append(f"{t}: level {m['level']} but creatures.txt says {c[2]}")
    for b in bad: print("FAIL", path, b)
    print(f"{path}: {len(bad)} problems"); return not bad

if __name__ == "__main__": sys.exit(0 if all([lint(p) for p in sys.argv[1:]]) else 1)
