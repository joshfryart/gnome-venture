"""Shared landscape stamps for the bendy trail maps (used by tools/build_maplewold_bendy.py and tools/gen_bendy_trail_proto.py --variety).
A stamp is a named piece of landscape expanded into basic ops; ops are applied to a grid (list of lists of chars) and mark their cells as protected.
Basic ops: ("W"|"F"|"R", x0, y0, x1, y1) rects of thicket / floor / rough; ("w"|"f"|"r", cx, cy, r) discs; ("pat", x, y, rows) literal stamp."""
import random, zlib
W, H = 30, 18

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
    if k == "dune":      # ("dune", cx, cy, rx, ry): rough sand ridge with a few tufts on the crest
        out = expand(("drift",) + tuple(op[1:5])); rg = _r(*op)
        out += [("w", op[1] + rg.randint(-op[3], op[3]), op[2] + rg.randint(-op[4], op[4]), 0) for _ in range(2)]
        return out
    if k == "rockstack": # ("rockstack", cx, cy): a heap of rock with a rough skirt
        return [("r", op[1], op[2], 2), ("w", op[1], op[2], 1)]
    if k == "tidepool":  # ("tidepool", cx, cy): a small pool in rough shore
        return [("r", op[1], op[2], 2), ("w", op[1], op[2], 1)]
    if k == "icelake":   # ("icelake", cx, cy, r): walkable ice (rough) with two open pools
        return [("r", op[1], op[2], op[3]), ("w", op[1] - 1, op[2], 0), ("w", op[1] + 1, op[2] + 1, 0)]
    if k == "pines":     # ("pines", cx, cy, r): snowy ground with dense pines
        rg = _r(*op); out = [("r", op[1], op[2], op[3])]
        out += [("w", x, y, 0) for (x, y) in disc(op[1], op[2], op[3]) if rg.random() < 0.5]
        return out
    if k == "log":       # ("log", x, y, length): a fallen log with a rough shadow either side
        return [("R", op[1], op[2] - 1, op[1] + op[3] - 1, op[2] + 1), ("W", op[1], op[2], op[1] + op[3] - 1, op[2])]
    if k == "clearing":  # ("clearing", cx, cy, r): an open glade with a rough heart
        return [("f", op[1], op[2], op[3]), ("r", op[1], op[2], max(1, op[3] - 1))]
    return [op]

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

