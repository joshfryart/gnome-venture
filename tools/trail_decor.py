#!/usr/bin/env python3
"""The `decor` field of a Trail section (2026-11-14, Josh: "add a decor data field so the rich map looks are game data"; design: claude/plan-trail-decor.md).

What the rich painter (tools/render_bendy_rich.py) dresses each tile as, taken from the same dressing it was baked from (tools/maplewold_rich_specs.py
rich_for(): the hand sketch of the 16 Maplewold routes, auto() / infer() for the rest) with the painter's own rules applied, so the game does not need them:
  looks: a thicket (#) tile's look; the LAST matching rect wins, only on thicket tiles that are not a stream, and only inside the 1-tile border except "sea"
  rough: a rough (,) tile's kind; the FIRST matching rect wins; tiles that match none are `rough_default` (the land's default kind)
  floor: a plain floor tile's zone (furrows: a vegetable plot, still walkable); the FIRST matching rect wins
Stored as rectangles that do not overlap, one kind each ([kind, x0, y0, x1, y1], inclusive), so a reader needs no order rules:
  "decor": {"v": 1, "looks": [...], "rough": [...], "rough_default": "grass", "floor": [...], "props": [[kind, x, y], ...], "tree": "maple"}
props are the dressing's hints for small flat things (goat, crate, duck ...); the painter snaps each to the nearest free tile, so a prop's x, y is where it was
ASKED for, not always where it is drawn. Raised things (trees, haybales, landmarks) are in `objs` already. Ambient animals and milestones are the painter's own
and are not listed. The ground pictures are NOT re-baked (a re-bake is not bit-for-bit the same): this only writes data next to them.
Usage: python3 -I tools/trail_decor.py --write   (adds / refreshes `decor` in every game/includes/data/trail_maps/*_30x18.json; idempotent; checks that the
       source rows equal the game rows first and refuses a file where they differ)
       python3 -I tools/trail_decor.py --check   (exit 1 when a section's decor is missing or out of date)"""
import glob, json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(HERE); sys.path.insert(0, HERE)
MAPS = os.path.join(REPO, "game", "includes", "data", "trail_maps")


def rects(cells):
    """{(x, y): kind} -> non-overlapping [kind, x0, y0, x1, y1], greedy: take the top-left cell, run right, then grow down while the whole run matches."""
    left = dict(cells); out = []
    for (y, x) in sorted((y, x) for (x, y) in cells):
        k = left.get((x, y))
        if k is None: continue
        x1 = x
        while left.get((x1 + 1, y)) == k: x1 += 1
        y1 = y
        while all(left.get((xx, y1 + 1)) == k for xx in range(x, x1 + 1)): y1 += 1
        for yy in range(y, y1 + 1):
            for xx in range(x, x1 + 1): del left[(xx, yy)]
        out.append([k, x, y, x1, y1])
    return out


def decor_for(route, si, rich, rough_default):
    """The decor of section si of a source route (claude/bend-prototype-v2 or claude/maplewold-bendy-maps), from its dressing `rich`."""
    s = route["sections"][si]; rows = s["rows"]; W, H = len(rows[0]), len(rows)
    wall = lambda x, y: rows[y][x] == "#"
    inner = lambda x, y: 1 <= x <= W - 2 and 1 <= y <= H - 2
    stream = set()
    for wv in s.get("water", []):
        for p in wv.get("pts", []):
            if 0 <= p[0] < W and 0 <= p[1] < H and wall(p[0], p[1]): stream.add((p[0], p[1]))
    inr = lambda x, y, r: r[1] <= x <= r[3] and r[2] <= y <= r[4]
    look = {}
    for r in rich.get("looks", []):
        for y in range(max(0, r[2]), min(H - 1, r[4]) + 1):
            for x in range(max(0, r[1]), min(W - 1, r[3]) + 1):
                if wall(x, y) and (x, y) not in stream and (r[0] == "sea" or inner(x, y)): look[(x, y)] = r[0]
    rough, floor = {}, {}
    for y in range(H):
        for x in range(W):
            c = rows[y][x]
            if c == ",":
                k = next((r[0] for r in rich.get("rough", []) if inr(x, y, r)), None)
                if k and k != rough_default: rough[(x, y)] = k
            elif c != "#":
                k = next((r[0] for r in rich.get("floor", []) if inr(x, y, r)), None)
                if k: floor[(x, y)] = k
    d = {"v": 1, "looks": rects(look), "rough": rects(rough), "rough_default": rough_default, "floor": rects(floor),
         "props": [[p[0], int(p[1]), int(p[2])] for p in rich.get("props", [])]}
    if rich.get("tree"): d["tree"] = rich["tree"]
    return d


def decor_of_game_route(rid, game_route):
    import render_bendy_rich as R
    from maplewold_rich_specs import rich_for
    src = json.load(open(R.src_of(rid), encoding="utf-8"))
    out = []
    for si, sec in enumerate(game_route["sections"]):
        if src["sections"][si]["rows"] != sec["rows"]:
            raise SystemExit(f"route {rid} section {si + 1}: the source rows differ from the game rows: re-bake first")
        out.append(decor_for(src, si, rich_for(rid, si, src), R.ROUGH_DEFAULT[src["land"]]))
    return out


def main():
    args = sys.argv[1:]
    if not args or args[0] not in ("--write", "--check"): print(__doc__); return 2
    bad = n = 0
    for f in sorted(glob.glob(os.path.join(MAPS, "*_30x18.json"))):
        raw = open(f, encoding="utf-8").read(); d = json.loads(raw)
        for k, r in d["routes"].items():
            for sec, dec in zip(r["sections"], decor_of_game_route(int(k), r)):
                n += 1
                if sec.get("decor") != dec: bad += 1; sec["decor"] = dec
        new = json.dumps(d, separators=(",", ":"), ensure_ascii=False)
        if args[0] == "--write" and new != raw: open(f, "w", encoding="utf-8").write(new); print("wrote", os.path.basename(f))
    print(f"{n} sections, {bad} {'updated' if args[0] == '--write' else 'missing or out of date'}")
    return 1 if args[0] == "--check" and bad else 0


if __name__ == "__main__":
    sys.exit(main())
