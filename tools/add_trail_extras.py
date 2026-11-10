#!/usr/bin/env python3
"""Tool gates and extra mini-boss spots for the 230 generated routes (claude/bend-prototype-v2/route-<id>.json; the 16 hand-tuned Maplewold routes have theirs from
tools/build_maplewold_bendy.py). Deterministic and idempotent (a section that already has `gates` / `extra_minibosses` is left alone). Edits the committed route files in place
(do NOT rerun tools/gen_bendy_trail_proto.py: its output is not reproducible). Josh 2026-11-10: yes to gates and extra mini-bosses for the other regions.
  Gate tier rule = region rank + 1 (rank = place in REGION_LEVELS order, Maplewold = 1), capped at 3: NA 2 (Sturdy), every later region 3 (Fine). Josh's cap 4 cannot be used: staff, lantern, pick and axe have no tier 4.
  Locks (a wall across the whole section with a 3 tile gap on the road; nothing else gets through): one on the last section of every delve / lair route, before the E tile.
  Shortcuts (same wall, plus a second 2 tile opening far along it; the way round is >= 6 steps longer): one plain route per region.
  Extra mini-bosses: one large creature of the route's land on the road of one section of about every 4th plain route; level = the creature's own (creatures.txt), the one nearest
  to 12 + 0.7 x region level; never in the section of a gate (3+ steps from any gate), 5+ steps from the entry, 7+ from the exit.
Usage: python3 tools/add_trail_extras.py [--dry]   then python3 tools/lint_trail_bends.py claude/bend-prototype-v2/route-*.json; python3 tools/lint_maplewold_extras.py claude/bend-prototype-v2/route-*.json
Sections with a new gate change their rows: re-bake those routes (tools/bake_trail_rich.py <ids>), see the printed list."""
import glob, json, os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(HERE); sys.path.insert(0, HERE)
from bend_rules import walk, reachable
import lint_trail_bends as LT
import lint_maplewold_extras as LX
ORDER = ["NA", "CA", "NWE", "CB", "SE", "SA", "EE", "MENA", "EA", "CSA", "SEA", "WCA", "ESA", "OC"]   # includes/progression.php REGION_LEVELS order
LEVEL = {"NA": 1, "CA": 4, "NWE": 6, "CB": 8, "SE": 10, "SA": 12, "EE": 14, "MENA": 17, "EA": 20, "CSA": 23, "SEA": 26, "WCA": 29, "ESA": 32, "OC": 35}
TOOLS = ["staff", "lantern", "pick", "axe"]
LOCK_LABEL = {"staff": "steep steps: needs a staff to climb", "lantern": "dark passage: needs a lantern to find the way", "pick": "rockfall: needs a pick to clear the rocks", "axe": "fallen trunk: needs an axe to chop through"}
SHORT_LABEL = {"staff": "steep short cut: a staff for the short way, the long way round is open", "lantern": "dim short cut: a lantern for the short way, the long way round is open",
               "pick": "rocky short cut: a pick for the short way, the long way round is open", "axe": "overgrown short cut: an axe for the short way, the long way round is open"}
CRE = []   # (slug, name, size, lands, level)
for l in open(os.path.join(REPO, "game/includes/data/creatures.txt"), encoding="utf-8"):
    if l.startswith("#") or "|" not in l: continue
    f = l.split("|"); CRE.append((f[0], f[1], f[2], [x.strip() for x in f[3].split(",")], int(f[4])))

def tier_of(region): return min(3, ORDER.index(region) + 2)   # the gathering tools only go to tier 3 (Fine)

def put_gate(route, si, k, tool, kind):
    """The section with a wall across it at road index k, or None when it does not fit (a landmark, find or E in the wall, lint fails, no good bypass)."""
    s = route["sections"][si]; line = [tuple(c) for c in s["line"]]; rows = s["rows"]; w, h = len(rows[0]), len(rows)
    en, ex = (s["entry"]["x"], s["entry"]["y"]), (s["exit"]["x"], s["exit"]["y"])
    px, py = line[k]; a, b = line[k - 1], line[k + 1]; vert = abs(b[0] - a[0]) >= abs(b[1] - a[1])   # the road runs E-W: the wall runs N-S
    cells = [(px, y) for y in range(1, h - 1)] if vert else [(x, py) for x in range(1, w - 1)]
    tiles = [(px, y) for y in range(max(1, py - 1), min(h - 2, py + 1) + 1)] if vert else [(x, py) for x in range(max(1, px - 1), min(w - 2, px + 1) + 1)]
    lms = {(l[0], l[1]) for l in s.get("landmarks", [])}
    if any(rows[y][x] in "FES9" or (x, y) in lms for x, y in cells): return None
    far_opts = [None]
    if kind == "shortcut":
        span = range(2, h - 3) if vert else range(2, w - 3)
        far_opts = sorted(span, key=lambda f: -abs(f - (py if vert else px)))
        far_opts = [f for f in far_opts if abs(f - (py if vert else px)) >= 5]
    for far in far_opts:
        g = [list(r) for r in rows]
        for x, y in cells: g[y][x] = "#"
        for x, y in tiles: g[y][x] = "."
        byp = []
        if far is not None:
            byp = [(px, far), (px, far + 1)] if vert else [(far, py), (far + 1, py)]
            if any(rows[y][x] == "#" and False for x, y in byp): continue
            for x, y in byp: g[y][x] = "."
        seen = reachable(g, en)
        if ex not in seen: continue
        for y in range(h):
            for x in range(w):
                if g[y][x] != "#" and (x, y) not in seen: g[y][x] = "#"
        if any(g[y][x] not in ".," for x, y in lms) or any(g[y][x] in "#" for y in range(h) for x in range(w) if rows[y][x] in "FE"): continue
        blocked = [list(r) for r in g]
        for x, y in tiles: blocked[y][x] = "#"
        sp = walk(blocked, en, ex)
        if kind == "lock" and sp is not None: continue
        if kind == "shortcut" and (sp is None or len(sp) - 1 < len(line) - 1 + 6): continue
        new = dict(s); new["rows"] = ["".join(r) for r in g]
        if LT.lint_section(si, new, w, h, bool(route["boss"]), si == len(route["sections"]) - 1): continue
        tr = tier_of(route["region"]); name = LX.TOOL_NAME[(tool, tr)]
        rec = dict(tiles=[list(t) for t in tiles], road_index=k, tool_type=tool, min_tier=tr, tool_name=name, kind=kind, label=(LOCK_LABEL if kind == "lock" else SHORT_LABEL)[tool])
        if byp: rec["bypass"] = [list(t) for t in byp]
        new["gates"] = [rec]
        return new
    return None

def lock_for(route, si):
    s = route["sections"][si]; n = len(s["line"]); tool = TOOLS[route["route_id"] % 4]
    for k in sorted(range(5, n - 7), key=lambda k: (abs(k - round(n * .4)), k)):
        if "E" in "".join(s["rows"]) and k >= [tuple(c) for c in s["line"]].index(next((x, y) for y, r in enumerate(s["rows"]) for x, c in enumerate(r) if c == "E")): continue
        new = put_gate(route, si, k, tool, "lock")
        if new: return new
    return None

def shortcut_for(route, si):
    s = route["sections"][si]; n = len(s["line"]); tool = TOOLS[(route["route_id"] // 3) % 4]
    for k in sorted(range(5, n - 7), key=lambda k: (abs(k - round(n * .5)), k)):
        new = put_gate(route, si, k, tool, "shortcut")
        if new: return new
    return None

def mini_for(route, si):
    s = route["sections"][si]; line = [tuple(c) for c in s["line"]]; n = len(line); gk = [g["road_index"] for g in s.get("gates", [])]
    tgt = 12 + .7 * LEVEL[route["region"]]
    pool = [c for c in CRE if c[2] == "large" and (route["land"] in c[3] or "any" in c[3])]
    if not pool: return None
    c = min(pool, key=lambda c: (abs(c[4] - tgt), c[4], c[0]))
    for k in sorted(range(5, n - 6), key=lambda k: (abs(k - n // 2), k)):
        if all(abs(k - g) >= 3 for g in gk) and tuple(line[k]) not in {(l[0], l[1]) for l in s.get("landmarks", [])} and s["rows"][line[k][1]][line[k][0]] in ".,":
            return dict(x=line[k][0], y=line[k][1], road_index=k, creature=c[0], level=c[4], label=f"{s['feature']}: {c[1]}")
    return None

def main():
    dry = "--dry" in sys.argv
    import bake_trail_rich as K
    routes = {i: json.load(open(os.path.join(REPO, "claude", "bend-prototype-v2", f"route-{i}.json"))) for i in K.all_ids() if K.region_of(i) != "MW"}
    byreg = {}
    for i, r in routes.items(): byreg.setdefault(r["region"], []).append(i)
    changed = set(); rebake = set(); report = []
    for reg, ids in sorted(byreg.items()):
        ids.sort(); plain = [i for i in ids if not routes[i]["boss"]]
        for i in ids:   # locks on the last section of every boss route
            r = routes[i]; si = len(r["sections"]) - 1
            if r["boss"] and not r["sections"][si].get("gates"):
                new = lock_for(r, si)
                if new: r["sections"][si] = new; changed.add(i); rebake.add(i); report.append(f"{reg} {i} s{si + 1} lock {new['gates'][0]['tool_name']}")
                else: report.append(f"{reg} {i} NO LOCK FITS")
        sc = None   # one shortcut per region on a plain route (the first one where it fits; any section)
        for i in plain:
            if sc: break
            r = routes[i]
            for si in range(len(r["sections"])):
                if r["sections"][si].get("gates"): continue
                new = shortcut_for(r, si)
                if new: r["sections"][si] = new; changed.add(i); rebake.add(i); sc = (i, si); report.append(f"{reg} {i} s{si + 1} shortcut {new['gates'][0]['tool_name']}"); break
        if not sc: report.append(f"{reg} NO SHORTCUT FITS")
        for n, i in enumerate(plain):   # extra mini-bosses: every 4th plain route, one section (not the gate section)
            if n % 4 != 2: continue
            r = routes[i]
            for si in sorted(range(len(r["sections"])), key=lambda si: (si == 0 and len(r["sections"]) > 1, (si + i) % len(r["sections"]))):
                s = r["sections"][si]
                if s.get("extra_minibosses") or s.get("gates"): continue
                m = mini_for(r, si)
                if m: s["extra_minibosses"] = [m]; changed.add(i); report.append(f"{reg} {i} s{si + 1} mini {m['creature']} {m['level']}"); break
    print("\n".join(report)); print("changed routes:", len(changed), " to re-bake:", " ".join(map(str, sorted(rebake))))
    if not dry:
        for i in changed: json.dump(routes[i], open(os.path.join(REPO, "claude", "bend-prototype-v2", f"route-{i}.json"), "w"), indent=1, ensure_ascii=False)
    open(os.path.join(REPO, "claude", "bend-prototype-v2", "rebake-ids.txt"), "w").write(" ".join(map(str, sorted(rebake))) + "\n") if not dry else None

if __name__ == "__main__": main()
