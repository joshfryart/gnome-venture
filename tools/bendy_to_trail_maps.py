#!/usr/bin/env python3
"""Turns bendy route files (claude/maplewold-bendy-maps/route-*.json) into the game's authored-map shape ({"v":1,"routes":{id:{land, art, from, to, boss, sections}}},
the same as game/includes/data/trail_maps.json) with the v2.7 fields: per section 'entry' {side, x, y} (sections after the first have no S in their rows), 'gates',
'extra_minibosses', 'water'. Landmarks become objs [x, y, 'lm-<name>', 0].
Usage: python3 tools/bendy_to_trail_maps.py [out.json] [route-files...]    default out: claude/maplewold-bendy-maps/trail_maps_maplewold_30x18.json (NOT game data:
the game has no ground pictures for 30 x 18 sections yet; copy to game/includes/data/trail_maps/ after the bake)."""
import glob, json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(HERE)
ART = {"grassland": "grassland", "forest": "forest", "coast": "coast", "tundra": "tundra"}
def convert(files):
    routes = {}
    for f in files:
        r = json.load(open(f)); secs = []
        for s in r["sections"]:
            t = {"feature": s["feature"], "caption": s["caption"], "rows": s["rows"], "objs": [[x, y, "lm-" + n, j] for x, y, n, j in s["landmarks"]], "entry": s["entry"]}
            for k in ("gates", "extra_minibosses", "water"):
                if s.get(k): t[k] = s[k]
            secs.append(t)
        routes[str(r["route_id"])] = {"land": r["land"], "art": ART.get(r["land"], r["land"]), "from": r["from"], "to": r["to"], "boss": r["boss"], "sections": secs}
    return {"v": 1, "routes": routes}
if __name__ == "__main__":
    args = sys.argv[1:]; out = args[0] if args and args[0].endswith(".json") and "route-" not in args[0] else os.path.join(REPO, "claude", "maplewold-bendy-maps", "trail_maps_maplewold_30x18.json")
    files = [a for a in args if "route-" in a] or sorted(glob.glob(os.path.join(REPO, "claude", "maplewold-bendy-maps", "route-*.json")))
    json.dump(convert(files), open(out, "w"), indent=1, ensure_ascii=False); print("wrote", out, len(files), "routes")
