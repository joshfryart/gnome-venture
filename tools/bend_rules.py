"""Shared rules for the bendy trail prototype (tools/gen_bendy_trail_proto.py makes the maps, tools/lint_trail_bends.py checks them).
One place for the numbers so the generator and the lint cannot drift apart. Plan: claude/plan-route-map-bends.md."""
from collections import deque
CAP, LONG_CAP = 6, 10           # straight run of the road: at most 6 tiles, and one run per section may go up to 10
SHORTCUT_AIM = 0.82             # the generator closes in on shortcuts until the shortest walk is >= this share of the road line
SHORTCUT_MIN = 0.80             # the lint fails below this share (a little slack under the aim)
WALL_MIN, WALL_MAX = 0.12, 0.45  # share of thicket inside the border

def steps(cells): return [(b[0] - a[0], b[1] - a[1]) for a, b in zip(cells, cells[1:])]

def run_lengths(cells):
    """Lengths of the straight runs along a path (a run = consecutive steps in the same direction)."""
    out, cur, prev = [], 0, None
    for s in steps(cells):
        if s == prev: cur += 1
        else:
            if prev is not None: out.append(cur)
            cur, prev = 1, s
    return out + [cur] if prev is not None else out

def reverses(cells):
    st = steps(cells)
    return any(a[0] == -b[0] and a[1] == -b[1] for a, b in zip(st, st[1:]))

def road_ok(cells):
    """The road line: no cell twice, no step straight back, runs <= 6 with at most one up to 10."""
    rr = run_lengths(cells)
    return len(set(cells)) == len(cells) and not reverses(cells) and max(rr, default=0) <= LONG_CAP and sum(r > CAP for r in rr) <= 1

def walk(g, st, en):
    """Shortest 4-way walk over non-wall cells of a grid (list of strings or lists), as a list of (x, y), or None."""
    h, w = len(g), len(g[0]); prev = {st: None}; q = deque([st])
    while q:
        c = q.popleft()
        if c == en: break
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (c[0] + dx, c[1] + dy)
            if 0 <= n[0] < w and 0 <= n[1] < h and g[n[1]][n[0]] != "#" and n not in prev: prev[n] = c; q.append(n)
    if en not in prev: return None
    out, c = [], en
    while c is not None: out.append(c); c = prev[c]
    return out[::-1]

def reachable(g, st):
    """All cells a walker can reach from st."""
    h, w = len(g), len(g[0]); seen = {st}; stk = [st]
    while stk:
        cx, cy = stk.pop()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (cx + dx, cy + dy)
            if 0 <= n[0] < w and 0 <= n[1] < h and n not in seen and g[n[1]][n[0]] != "#": seen.add(n); stk.append(n)
    return seen
