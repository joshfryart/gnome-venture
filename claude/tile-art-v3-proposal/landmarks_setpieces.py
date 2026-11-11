"""STAND-IN sprites for the shared set pieces of every route outside the Maplewold (claude/trail-landmarks/setpieces.json, made by tools/gen_trail_maps.py).
Each is a simple lump-and-post silhouette in the land's colours, sized by a hash of its name, so the map shows WHERE a set piece stands and roughly how big.
Replace one by drawing a real function and adding it to a landmarks_<name>.py (same slug) and deleting its slug here (gen2 asserts a name is defined once);
the brief for each is in claude/trail-setpiece-art-notes.md."""
import json, os, random, zlib
import gen2
from gen2 import RAMP, Cv, lump, r5, CREAM

_CAT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "trail-landmarks", "setpieces.json")
_LAND = {"grassland": "moss", "forest": "leaf", "coast": "sand", "tundra": "snow", "desert": "sand", "mountain": "stone", "wetland": "sea", "rainforest": "pine", "island": "sea"}
_ACC = {"grassland": "gold", "forest": "wood", "coast": "stone", "tundra": "ice", "desert": "wood", "mountain": "wood", "wetland": "moss", "rainforest": "petal", "island": "petal"}

def _make(slug, land):
    h = zlib.crc32(slug.encode())
    end = slug.startswith("end-")
    w, hh = (200, 190) if end else (130 + h % 60, 100 + (h >> 4) % 70)
    def draw(rnd, cv):
        base, acc = r5(RAMP[_LAND[land]]), r5(RAMP[_ACC[land]])
        for i in range(2 + (h >> 8) % 3):   # a few lumps along the ground
            cx = int(w * (.25 + .5 * ((i * 37 + h) % 100) / 100)); rx = 22 + (h >> (i + 3)) % 18; ry = 12 + (h >> (i + 5)) % 12
            lump(cv, cx, hh - 14 - (i % 2) * 8, rx, ry, base, rnd, .08)
        px = w // 2 + (h >> 11) % 30 - 15   # a post with a small flag, so it reads as 'a set piece goes here'
        for y in range(hh - 60 - (h >> 13) % 20, hh - 8):
            for dx in (-1, 0, 1): cv.put(px + dx, y, RAMP["wood"][1 + (dx > 0)])
        for y in range(hh - 60 - (h >> 13) % 20, hh - 44 - (h >> 13) % 20):
            for x in range(px + 2, px + 22 - (y % 4)): cv.put(x, y, acc[1 + ((x + y) % 7 == 0)])
        if end:
            lump(cv, w // 2, hh - 70, 60, 46, base, rnd, .1)
    return (w, hh, draw)

try:
    LM = {slug: _make(slug, v["land"]) for slug, v in json.load(open(_CAT, encoding="utf-8")).items() if not slug.startswith("end-")}   # end-* are drawn in landmarks_endpieces.py
except OSError:
    LM = {}
