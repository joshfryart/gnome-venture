"""Ponds and lakes of a region, read from its picture game/assets/img/scenes/map-<CODE>.png (blue water pixels), for tools/gen_bendy_trail_proto.py --variety.
Streams are not read (they are thin and the pictures draw them inconsistently); Maplewold's streams are hand-derived in tools/maplewold_waterways.py.
region_ponds(code) -> [{x, y, r}] in the 480 x 270 region frame (r = about the pond's radius). Crystals and other small blue things are filtered by shape."""
import functools, os
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(HERE)

@functools.lru_cache(maxsize=None)
def region_ponds(code):
    f = os.path.join(REPO, "game", "assets", "img", "scenes", f"map-{code}.png")
    if not os.path.isfile(f): return []
    im = Image.open(f).convert("RGB"); W, H = im.size
    pts = {(x, y) for y in range(H) for x in range(W) if (lambda r, g, b: b > r + 25 and b > g - 5 and b > 110)(*im.getpixel((x, y)))}
    seen, out = set(), []
    for p in sorted(pts):
        if p in seen: continue
        st, c = [p], []; seen.add(p)
        while st:
            q = st.pop(); c.append(q)
            for dx in (-2, -1, 0, 1, 2):
                for dy in (-2, -1, 0, 1, 2):
                    n = (q[0] + dx, q[1] + dy)
                    if n in pts and n not in seen: seen.add(n); st.append(n)
        xs = [q[0] for q in c]; ys = [q[1] for q in c]; w, h = max(xs) - min(xs) + 1, max(ys) - min(ys) + 1; fill = len(c) / (w * h)
        if len(c) >= 40 and 0.65 <= w / h <= 2.0 and (0.25 <= fill <= 0.75 or len(c) >= 150):
            out.append(dict(x=round(sum(xs) / len(c)), y=round(sum(ys) / len(c)), r=max(2, round((w + h) / 4))))
    return out

if __name__ == "__main__":
    import sys
    for code in sys.argv[1:] or ["NA", "CA", "CB", "SA", "NWE", "SE", "EE", "MENA", "WCA", "ESA", "CSA", "EA", "SEA", "OC"]: print(code, region_ponds(code))
