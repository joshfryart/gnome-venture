#!/usr/bin/env python3
"""Lint for bendy trail maps (plan: claude/plan-route-map-bends.md). Usage: python3 tools/lint_trail_bends.py <route.json> [...]
Per section: size, one entry and one exit on edges, S only on section 1, walls elsewhere on the border, the stored road line is floor and connected,
starts at the entry and ends at the exit, straight runs <= 6 tiles (one run up to 10), F off the line, E on the line, no E except last section.
Between sections: exit of N moved across the join equals the entry of N+1 (same row for E/W, same column for N/S).
Also: no cell used twice on the road line and no step straight back; landscape share (walls 12 to 45% of the inside, some rough ground);
the shortest walk entry to exit is at least 80% of the road line and has no straight run over 10 (no meadow shortcut that skips the bends);
every F can be reached; landmarks are floor, off the road, off F and E, feet row >= 3, inside x 3..W-4. Exit 1 on any FAIL."""
import json, sys
from collections import deque
CAP, LONG = 6, 10
def runs(line):
    out, prev, cur = [], None, 0
    for a, b in zip(line, line[1:]):
        s = (b[0] - a[0], b[1] - a[1])
        if s == prev: cur += 1
        else:
            if prev is not None: out.append(cur)
            prev, cur = s, 1
    return out + [cur] if prev is not None else out
def shortest(rows, st, en):
    h, w = len(rows), len(rows[0]); prev = {st: None}; q = deque([st])
    while q:
        c = q.popleft()
        if c == en: break
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (c[0] + dx, c[1] + dy)
            if 0 <= n[0] < w and 0 <= n[1] < h and rows[n[1]][n[0]] != "#" and n not in prev: prev[n] = c; q.append(n)
    if en not in prev: return None
    out, c = [], en
    while c: out.append(c); c = prev[c]
    return out[::-1]
def lint(path):
    r = json.load(open(path)); bad, warn = [], []
    secs = r["sections"]; W, H = r["w"], r["h"]
    for i, s in enumerate(secs):
        t = f"section {i + 1}"; rows = s["rows"]
        if len(rows) != H or any(len(x) != W for x in rows): bad.append(f"{t}: size is not {W} x {H}"); continue
        en, ex = s["entry"], s["exit"]; line = [tuple(c) for c in s["line"]]
        edge = lambda x, y: x in (0, W - 1) or y in (0, H - 1)
        if not (edge(en["x"], en["y"]) and edge(ex["x"], ex["y"])): bad.append(f"{t}: entry or exit not on an edge")
        openings = [(x, y) for y in range(H) for x in range(W) if edge(x, y) and rows[y][x] != "#"]
        if sorted(openings) != sorted({(en["x"], en["y"]), (ex["x"], ex["y"])}): bad.append(f"{t}: border openings {openings} are not exactly entry and exit")
        if rows[ex["y"]][ex["x"]] != "9": bad.append(f"{t}: exit tile is not 9")
        if sum(x.count("9") for x in rows) != 1: bad.append(f"{t}: needs exactly one 9")
        nS = sum(x.count("S") for x in rows)
        if nS != (1 if i == 0 else 0): bad.append(f"{t}: S count {nS}")
        if line[0] != (en["x"], en["y"]) or line[-1] != (ex["x"], ex["y"]): bad.append(f"{t}: line does not run entry to exit")
        if any(abs(a[0] - b[0]) + abs(a[1] - b[1]) != 1 for a, b in zip(line, line[1:])): bad.append(f"{t}: line has a gap")
        if any(rows[y][x] == "#" for x, y in line): bad.append(f"{t}: line crosses a wall")
        rr = runs(line)
        if rr and max(rr) > LONG: bad.append(f"{t}: straight run of {max(rr)} (limit {LONG})")
        if sum(1 for x in rr if x > CAP) > 1: bad.append(f"{t}: more than one run over {CAP}")
        on = set(line)
        for y, row in enumerate(rows):
            for x, c in enumerate(row):
                if c == "F" and (x, y) in on: bad.append(f"{t}: F on the road line at {x},{y}")
                if c == "E" and (x, y) not in on: bad.append(f"{t}: E off the road line at {x},{y}")
                if c == "E" and i != len(secs) - 1: bad.append(f"{t}: E only on the last section")
        if len(set(line)) != len(line): bad.append(f"{t}: road line uses a cell twice")
        st_ = [(b[0] - a[0], b[1] - a[1]) for a, b in zip(line, line[1:])]
        if any(a[0] == -b[0] and a[1] == -b[1] for a, b in zip(st_, st_[1:])): bad.append(f"{t}: road line steps straight back")
        inside = [rows[y][x] for y in range(1, H - 1) for x in range(1, W - 1)]
        wallshare = inside.count("#") / len(inside); roughshare = inside.count(",") / len(inside)
        if not 0.12 <= wallshare <= 0.45: bad.append(f"{t}: thicket share {wallshare:.0%} (want 12 to 45%)")
        if roughshare < 0.02: bad.append(f"{t}: almost no rough ground ({roughshare:.0%})")
        sp = shortest(rows, (en["x"], en["y"]), (ex["x"], ex["y"]))
        if sp is None: bad.append(f"{t}: entry cannot reach exit")
        else:
            if (len(sp) - 1) / max(1, len(line) - 1) < 0.80: bad.append(f"{t}: shortcut saves {1 - (len(sp) - 1) / (len(line) - 1):.0%} of the road (limit 20%)")
            if runs(sp) and max(runs(sp)) > LONG: bad.append(f"{t}: shortest walk has a straight run of {max(runs(sp))} (limit {LONG})")
        reach = set(sp or [])
        seen, stk = {(en["x"], en["y"])}, [(en["x"], en["y"])]
        while stk:
            cx, cy = stk.pop()
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n_ = (cx + dx, cy + dy)
                if 0 <= n_[0] < W and 0 <= n_[1] < H and n_ not in seen and rows[n_[1]][n_[0]] != "#": seen.add(n_); stk.append(n_)
        toks_ = {(x, y): c for y, row in enumerate(rows) for x, c in enumerate(row) if c in "FE"}
        for (x, y), c in toks_.items():
            if (x, y) not in seen: bad.append(f"{t}: {c} at {x},{y} cannot be reached")
        if not any(c == "F" for c in toks_.values()): bad.append(f"{t}: no find (F)")
        lm_ = [(l[0], l[1]) for l in s.get("landmarks", [])]
        for (x, y) in lm_:
            if not (3 <= x <= W - 4 and 3 <= y <= H - 2): bad.append(f"{t}: landmark {x},{y} out of bounds (x 3..{W - 4}, feet row 3..{H - 2})")
            elif rows[y][x] not in ".,": bad.append(f"{t}: landmark {x},{y} is not on plain floor")
            elif (x, y) in on: bad.append(f"{t}: landmark {x},{y} sits on the road")
        if len(set(lm_)) != len(lm_): bad.append(f"{t}: two landmarks on one tile")
        if i + 1 < len(secs):
            n = secs[i + 1]["entry"]
            if ex["side"] in "EW": ok = n["y"] == ex["y"] and n["side"] != ex["side"]
            else: ok = n["x"] == ex["x"] and n["side"] != ex["side"]
            if not ok: bad.append(f"{t} -> {i + 2}: join does not line up (exit {ex['side']} {ex['x']},{ex['y']} vs entry {n['side']} {n['x']},{n['y']})")
    for b in bad: print("FAIL", path, b)
    for w_ in warn: print("warn", path, w_)
    print(f"{path}: {len(secs)} sections, {len(bad)} problems, {len(warn)} warnings")
    return not bad
if __name__ == "__main__":
    sys.exit(0 if all([lint(p) for p in sys.argv[1:]]) else 1)
