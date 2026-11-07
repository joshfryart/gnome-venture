#!/usr/bin/env python3
"""Maplewold water ways (region NA, frame 480 x 270). Read from the region picture game/assets/img/scenes/map-NA.png (blue water pixels), then flow
completed by rule. Writes claude/maplewold-bendy-maps/waterways.json. Streams are polylines in region coordinates, listed UPSTREAM -> DOWNSTREAM.
Seen in the picture (kind 'drawn'): the lake (428,224) bottom right; Bridge Brook, which comes down from the top edge near (398,30), passes under the wooden
bridge on the Mistmoor road at (395,70) and goes on south; a short brook on a NE-SW slant around (339,173); two ponds (60,77) and (258,116).
Derived (kind 'derived'): the main river runs south from the bridge to the lake's west shore (everything drains to the lake, the lowest water); the slant brook rises
at its SW end and runs NE to meet Bridge Brook just below the bridge; the middle pond (258,116) gets an outlet that runs east to the river.
Usage: python3 tools/maplewold_waterways.py [--crossings]   (crossings: which of the 16 routes cross which water, per section)"""
import json, math, os, sys
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(HERE); sys.path.insert(0, HERE)
OUT = os.path.join(REPO, "claude", "maplewold-bendy-maps", "waterways.json")

WATER = {
 "lake": dict(kind="drawn", disc=[428, 224, 20]),
 "pond-west": dict(kind="drawn", disc=[60, 77, 6]),
 "pond-mid": dict(kind="drawn", disc=[258, 116, 6]),
 "bridge-brook": dict(kind="drawn+derived", flows_to="lake", pts=[[398, 28], [398, 48], [396, 70], [397, 92], [400, 120], [403, 150], [404, 185], [406, 214], [409, 222]]),
 "slant-brook": dict(kind="drawn+derived", flows_to="bridge-brook", pts=[[331, 192], [339, 173], [347, 163], [365, 140], [385, 112], [397, 93]]),
 "mid-outlet": dict(kind="derived", flows_to="bridge-brook", pts=[[264, 116], [290, 124], [320, 128], [350, 134], [378, 142], [402, 148]]),
 "west-river": dict(kind="derived", flows_to="hub-river", pts=[[60, 83], [85, 91], [112, 98], [140, 107], [160, 113], [176, 118]]),
 "south-brook": dict(kind="derived", flows_to="hub-river", pts=[[50, 112], [66, 122], [78, 132], [84, 146], [110, 152], [140, 150], [175, 150]]),
 "hub-brook": dict(kind="derived", flows_to="hub-river", pts=[[188, 52], [186, 76], [178, 96], [176, 118]]),
 "hub-river": dict(kind="derived", flows_to="lake", pts=[[176, 118], [173, 138], [180, 150], [200, 160], [215, 168], [250, 188], [300, 205], [360, 215], [406, 222]]),
 "pond-brook": dict(kind="derived", flows_to="mid-outlet", pts=[[250, 84], [251, 100], [252, 108], [256, 112]]),
}

def write():
    json.dump({"region": "NA", "frame": [480, 270], "note": __doc__.split("\n")[0], "water": WATER}, open(OUT, "w"), indent=1)

def seg_cross(a, b, c, d):
    """Intersection of segments ab and cd: (t along ab, u along cd) or None."""
    r = (b[0] - a[0], b[1] - a[1]); s = (d[0] - c[0], d[1] - c[1]); den = r[0] * s[1] - r[1] * s[0]
    if abs(den) < 1e-9: return None
    t = ((c[0] - a[0]) * s[1] - (c[1] - a[1]) * s[0]) / den; u = ((c[0] - a[0]) * r[1] - (c[1] - a[1]) * r[0]) / den
    return (t, u) if 0 <= t <= 1 and 0 <= u <= 1 else None

def route_water(rid):
    """Per section of route rid: list of dicts {name, t (0..1 along the section), dir (unit vector of the flow, region axes), kind} for streams the route curve crosses,
    and {name, side, dist} for ponds / the lake within 28 units of the section."""
    import gen_bendy_trail_proto as G
    from gen_trail_maps import parse
    src = json.load(open(os.path.join(REPO, "claude", "bend-prototype", f"route-{rid}.json")))
    info = {r[1]: r for r in parse()}[rid]
    home, away = G.group_regions(info[0])
    path, kind, rc = G.region_path(rid, src["from"], src["to"], home, away)
    n = len(src["sections"]); pts = G.sample(path, n)
    fine = [G.sample(path, n * 40)[i] for i in range(n * 40 + 1)]
    out = [[] for _ in range(n)]
    for i in range(len(fine) - 1):
        sec = min(n - 1, i // 40); a, b = fine[i], fine[i + 1]
        for name, w in WATER.items():
            if "pts" not in w: continue
            for p, q in zip(w["pts"], w["pts"][1:]):
                x = seg_cross(a, b, p, q)
                if x:
                    dx, dy = q[0] - p[0], q[1] - p[1]; L = math.hypot(dx, dy)
                    if any(c.get("name") == name and abs(c.get("t", 9) - (((i % 40) + x[0]) / 40)) < 0.2 for c in out[sec]): continue
                    out[sec].append(dict(name=name, t=((i % 40) + x[0]) / 40, dir=[round(dx / L, 3), round(dy / L, 3)], kind=w["kind"]))
    for name, w in WATER.items():
        if "disc" not in w: continue
        cx, cy, r = w["disc"]
        for sec in range(n):
            seg = fine[sec * 40: sec * 40 + 41]; d = min(math.hypot(p[0] - cx, p[1] - cy) for p in seg) - r
            if d < 28:
                k = min(seg, key=lambda p: math.hypot(p[0] - cx, p[1] - cy)); out[sec].append(dict(name=name, near=[cx, cy], at=[round(k[0], 1), round(k[1], 1)], dist=round(d, 1), t=seg.index(k) / 40))
    for name, w in WATER.items():                  # a pond or lake is drawn once per route: in the section where the route passes it closest
        if "disc" not in w: continue
        have = [(c["dist"], i) for i, sec in enumerate(out) for c in sec if c.get("name") == name]
        if have:
            keep = min(have)[1]
            for i, sec in enumerate(out): out[i] = [c for c in sec if c.get("name") != name or i == keep]
    return out

if __name__ == "__main__":
    write(); print("wrote", OUT)
    if "--crossings" in sys.argv:
        for rid in (228,232,236,304,305,306,307,308,309,310,311,312,313,314,315,316):
            for i, s in enumerate(route_water(rid)):
                if s: print(rid, "section", i + 1, s)
