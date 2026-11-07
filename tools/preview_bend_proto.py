#!/usr/bin/env python3
"""Picture of a bendy prototype route: python3 tools/preview_bend_proto.py claude/bend-prototype/route-313.json  ->  same name .png (sections side by side)."""
import json, sys
from PIL import Image, ImageDraw
C = {"#": (46, 84, 52), ".": (206, 196, 140), ",": (176, 170, 112), "S": (90, 160, 230), "9": (230, 120, 60), "F": (240, 210, 60), "E": (200, 40, 50)}
T = 18
r = json.load(open(sys.argv[1])); n = len(r["sections"]); W, H = r["w"], r["h"]
im = Image.new("RGB", (n * (W * T + 12) + 12, H * T + 24), (30, 30, 34)); d = ImageDraw.Draw(im)
for i, s in enumerate(r["sections"]):
    ox = 12 + i * (W * T + 12); oy = 20
    d.text((ox, 4), f"section {i + 1}: heading {s['heading']}, in {s['entry']['side']}, out {s['exit']['side']}", fill=(230, 230, 230))
    for y, row in enumerate(s["rows"]):
        for x, c in enumerate(row):
            d.rectangle([ox + x * T, oy + y * T, ox + x * T + T - 1, oy + y * T + T - 1], fill=C[c])
    for (x, y) in s["line"]: d.ellipse([ox + x * T + 6, oy + y * T + 6, ox + x * T + 11, oy + y * T + 11], fill=(120, 80, 40))
    for x, y, nm, _ in s.get("landmarks", []): d.rectangle([ox + x * T + 2, oy + y * T + 2, ox + x * T + T - 3, oy + y * T + T - 3], outline=(255, 255, 255), width=2); d.text((ox + x * T + 5, oy + y * T + 3), "L", fill=(255, 255, 255))
im.save(sys.argv[1].replace(".json", ".png")); print(sys.argv[1].replace(".json", ".png"))
