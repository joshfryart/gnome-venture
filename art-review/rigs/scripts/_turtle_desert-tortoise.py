"""helpers for the turtle/tortoise and python rigs (desert-tortoise, reef-turtle, ancient-snapper, emerald-python).
Private to that batch; the shared kit (rigkit.py) is untouched."""
import math


def scutes(p, mask, centres, seam, areola=None, ring=None, rings=(.58,), core=.32, sx=1.0):
    """felt scutes sewn onto a shell: Voronoi cells around `centres` inside `mask`.
    seam: colour of the thread between scutes; areola: (ramp) the pale centre patch of each scute; ring: colour of growth rings
    at the fractions `rings` of each cell's radius. sx stretches the metric in x (sx > 1 = wider cells)."""
    near = {}
    for (x, y) in mask:
        X, Y = x + .5, y + .5
        best = min(range(len(centres)), key=lambda i: ((X - centres[i][0]) / sx) ** 2 + (Y - centres[i][1]) ** 2)
        near[(x, y)] = best
    rad = {}
    for q, i in near.items():
        cx, cy = centres[i]
        d = math.hypot((q[0] + .5 - cx) / sx, q[1] + .5 - cy)
        rad[i] = max(rad.get(i, 0), d)
    cores = set()
    for q, i in near.items():
        cx, cy = centres[i]
        t = math.hypot((q[0] + .5 - cx) / sx, q[1] + .5 - cy) / (rad[i] or 1)
        if any((q[0] + dx, q[1] + dy) in near and near[(q[0] + dx, q[1] + dy)] != i for dx, dy in ((1, 0), (0, 1))):
            p.px(q[0], q[1], seam)
            continue
        if ring and any(abs(t - r) < .07 for r in rings):
            p.px(q[0], q[1], ring)
        if t < core:
            cores.add(q)
    if areola:
        p.add(cores, areola, flat=True)
    return near


def lerp(a, b, t):
    return (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)
