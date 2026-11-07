#!/usr/bin/env python3
"""Lint for bendy trail maps (plan: claude/plan-route-map-bends.md). Usage: python3 tools/lint_trail_bends.py <route.json> [...]   Exit 1 on any FAIL.
Per section
  shape     rows are w x h; entry and exit sit on edges; the only border openings are the entry and the exit; exactly one 9 (on the exit); S only on section 1
  road      the stored line is connected, on floor, runs entry to exit, no cell twice, no step back, straight runs within the limits (tools/bend_rules.py)
  land      thicket share 12 to 45% inside the border; some rough ground; the shortest walk is at least 80% of the road and has no straight run over 10
  tokens    1 to 3 F (reachable, off the road); E only on the road of the last section of a delve / lair route (exactly one there, none elsewhere)
  landmarks on plain floor, off the road, x 3..w-4, feet row 3..h-2, no two on one tile
Between sections: the exit of N moved across the join equals the entry of N+1 (same row for E/W, same column for N/S, opposite sides)."""
import json, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bend_rules import CAP, LONG_CAP, SHORTCUT_MIN, WALL_MIN, WALL_MAX, run_lengths, reverses, walk, reachable

def lint_section(i, s, w, h, boss, last):
    t, bad, rows = f"section {i + 1}", [], s["rows"]
    if len(rows) != h or any(len(r) != w for r in rows): return [f"{t}: size is not {w} x {h}"]
    en, ex = (s["entry"]["x"], s["entry"]["y"]), (s["exit"]["x"], s["exit"]["y"]); line = [tuple(c) for c in s["line"]]
    edge = lambda c: c[0] in (0, w - 1) or c[1] in (0, h - 1)
    if not (edge(en) and edge(ex)): bad.append(f"{t}: entry or exit not on an edge")
    openings = sorted((x, y) for y in range(h) for x in range(w) if edge((x, y)) and rows[y][x] != "#")
    if openings != sorted({en, ex}): bad.append(f"{t}: border openings {openings} are not exactly entry and exit")
    if rows[ex[1]][ex[0]] != "9" or sum(r.count("9") for r in rows) != 1: bad.append(f"{t}: needs exactly one 9, on the exit")
    nS = sum(r.count("S") for r in rows)
    if nS != (1 if i == 0 else 0): bad.append(f"{t}: S count {nS}")
    # road
    if line[0] != en or line[-1] != ex: bad.append(f"{t}: line does not run entry to exit")
    if any(abs(a[0] - b[0]) + abs(a[1] - b[1]) != 1 for a, b in zip(line, line[1:])): bad.append(f"{t}: line has a gap")
    if any(rows[y][x] == "#" for x, y in line): bad.append(f"{t}: line crosses a wall")
    if len(set(line)) != len(line): bad.append(f"{t}: road line uses a cell twice")
    if reverses(line): bad.append(f"{t}: road line steps straight back")
    rr = run_lengths(line)
    if rr and max(rr) > LONG_CAP: bad.append(f"{t}: straight run of {max(rr)} (limit {LONG_CAP})")
    if sum(r > CAP for r in rr) > 1: bad.append(f"{t}: more than one run over {CAP}")
    on = set(line)
    # land
    inside = [rows[y][x] for y in range(1, h - 1) for x in range(1, w - 1)]
    wall, rough = inside.count("#") / len(inside), inside.count(",") / len(inside)
    if not WALL_MIN <= wall <= WALL_MAX: bad.append(f"{t}: thicket share {wall:.0%} (want {WALL_MIN:.0%} to {WALL_MAX:.0%})")
    if rough < 0.02: bad.append(f"{t}: almost no rough ground ({rough:.0%})")
    sp = walk(rows, en, ex)
    if sp is None: bad.append(f"{t}: entry cannot reach exit")
    else:
        if (len(sp) - 1) / max(1, len(line) - 1) < SHORTCUT_MIN: bad.append(f"{t}: a shortcut saves {1 - (len(sp) - 1) / (len(line) - 1):.0%} of the road (limit {1 - SHORTCUT_MIN:.0%})")
        if max(run_lengths(sp), default=0) > LONG_CAP: bad.append(f"{t}: shortest walk has a straight run of {max(run_lengths(sp))} (limit {LONG_CAP})")
    # tokens
    seen = reachable(rows, en)
    toks = [(x, y, c) for y, r in enumerate(rows) for x, c in enumerate(r) if c in "FE"]
    nF, nE = sum(c == "F" for *_, c in toks), sum(c == "E" for *_, c in toks)
    if not 1 <= nF <= 3: bad.append(f"{t}: {nF} finds (want 1 to 3)")
    if nE != (1 if boss and last else 0): bad.append(f"{t}: {nE} E tiles (want {1 if boss and last else 0})")
    for x, y, c in toks:
        if (x, y) not in seen: bad.append(f"{t}: {c} at {x},{y} cannot be reached")
        if c == "F" and (x, y) in on: bad.append(f"{t}: F on the road line at {x},{y}")
        if c == "E" and (x, y) not in on: bad.append(f"{t}: E off the road line at {x},{y}")
    # landmarks
    lm = [(l[0], l[1]) for l in s.get("landmarks", [])]
    for x, y in lm:
        if not (3 <= x <= w - 4 and 3 <= y <= h - 2): bad.append(f"{t}: landmark {x},{y} out of bounds (x 3..{w - 4}, feet row 3..{h - 2})")
        elif rows[y][x] not in ".,": bad.append(f"{t}: landmark {x},{y} is not on plain floor")
        elif (x, y) in on: bad.append(f"{t}: landmark {x},{y} sits on the road")
    if len(set(lm)) != len(lm): bad.append(f"{t}: two landmarks on one tile")
    return bad

def lint(path):
    r = json.load(open(path)); secs, w, h = r["sections"], r["w"], r["h"]; bad = []
    for i, s in enumerate(secs): bad += lint_section(i, s, w, h, bool(r.get("boss")), i == len(secs) - 1)
    for i, (a, b) in enumerate(zip(secs, secs[1:])):
        ex, n = a["exit"], b["entry"]
        same = n["y"] == ex["y"] if ex["side"] in "EW" else n["x"] == ex["x"]
        opposite = {"E": "W", "W": "E", "N": "S", "S": "N"}[ex["side"]] == n["side"]
        if not (same and opposite): bad.append(f"section {i + 1} -> {i + 2}: join does not line up (exit {ex['side']} {ex['x']},{ex['y']} vs entry {n['side']} {n['x']},{n['y']})")
    for b in bad: print("FAIL", path, b)
    print(f"{path}: {len(secs)} sections, {len(bad)} problems")
    return not bad

if __name__ == "__main__":
    sys.exit(0 if all([lint(p) for p in sys.argv[1:]]) else 1)
