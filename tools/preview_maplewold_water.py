#!/usr/bin/env python3
"""Like preview_bend_proto.py, plus water: stream tiles blue with a flow arrow, ponds blue. python3 tools/preview_maplewold_water.py claude/maplewold-bendy-maps/route-228.json -> route-228-water.png"""
import json, sys
from PIL import Image, ImageDraw
C = {"#": (46, 84, 52), ".": (206, 196, 140), ",": (176, 170, 112), "S": (90, 160, 230), "9": (230, 120, 60), "F": (240, 210, 60), "E": (200, 40, 50)}
T = 18; BLUE = (70, 140, 210)
r = json.load(open(sys.argv[1])); n = len(r["sections"]); W, H = r["w"], r["h"]
im = Image.new("RGB", (n * (W * T + 12) + 12, H * T + 24), (30, 30, 34)); d = ImageDraw.Draw(im)
for i, s in enumerate(r["sections"]):
    ox = 12 + i * (W * T + 12); oy = 20; d.text((ox, 4), f"section {i + 1}: " + ", ".join(w["name"] + (" flows " + w["flow"] if "flow" in w else "") for w in s.get("water", [])), fill=(230, 230, 230))
    wet = {tuple(p) for w in s.get("water", []) for p in w.get("pts", [])}
    for y, row in enumerate(s["rows"]):
        for x, c in enumerate(row):
            col = BLUE if (x, y) in wet and c == "#" else C[c]
            d.rectangle([ox + x * T, oy + y * T, ox + x * T + T - 1, oy + y * T + T - 1], fill=col)
    for w in s.get("water", []):
        if "pond" in w:
            px, py = w["pond"]
            for y in range(py - 3, py + 4):
                for x in range(px - 3, px + 4):
                    if 0 <= y < H and 0 <= x < W and s["rows"][y][x] == "#" and (x - px) ** 2 + (y - py) ** 2 <= 6: d.rectangle([ox + x * T, oy + y * T, ox + x * T + T - 1, oy + y * T + T - 1], fill=BLUE)
        elif w.get("pts"):
            a, b = w["pts"][len(w["pts"]) // 2 - 1], w["pts"][len(w["pts"]) // 2 + 1]
            d.line([ox + a[0] * T + 9, oy + a[1] * T + 9, ox + b[0] * T + 9, oy + b[1] * T + 9], fill=(255, 255, 255), width=3)
            d.ellipse([ox + b[0] * T + 5, oy + b[1] * T + 5, ox + b[0] * T + 13, oy + b[1] * T + 13], fill=(255, 255, 255))
    for (x, y) in s["line"]: d.ellipse([ox + x * T + 6, oy + y * T + 6, ox + x * T + 11, oy + y * T + 11], fill=(120, 80, 40))
    for x, y, nm, _ in s.get("landmarks", []): d.rectangle([ox + x * T + 2, oy + y * T + 2, ox + x * T + T - 3, oy + y * T + T - 3], outline=(255, 255, 255), width=2); d.text((ox + x * T + 5, oy + y * T + 3), "L", fill=(255, 255, 255))
out = sys.argv[1].replace(".json", "-water.png"); im.save(out); print(out)
