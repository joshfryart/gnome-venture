#!/usr/bin/env python3
"""Contact sheets: each stop picture with its here_layouts.json hotspots drawn on it.
Red boxes = spot 'box' with the name, yellow dot = spot x,y, cyan dots = stand slots, green box = compass_clear.
One sheet per stop type: the Maplewold picture first (what the layout was drawn for), then the 7 new styles.
Usage: python3 -I claude/stop-hotspot-check/make_sheets.py [outdir]"""
import json, os, sys
from PIL import Image, ImageDraw, ImageFont
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.abspath(__file__))
L = json.load(open(os.path.join(R, 'game/includes/data/here_layouts.json')))
S = os.path.join(R, 'game/assets/img/scenes')
TYPES = 'market mill shrine jetty herb workshop orchard tower camp inn ferry spring'.split()
STYLES = ['grassland_maplewold', 'forest_pinewood', 'mountain_granite', 'coast_driftwood', 'island_palm', 'wetland_reed', 'tundra_frost', 'rainforest_canopy']
Z = 2
def cell(t, st):
    k = f'stop-{t}-{st}'
    lay = L.get(k) or L.get('stop-' + t)
    f = os.path.join(S, f'here-stop-{t}-{st}.png')
    if not os.path.exists(f): f = os.path.join(S, f'here-stop-{t}.png')
    im = Image.open(f).convert('RGB'); im = im.resize((lay['w'] * Z, lay['h'] * Z), Image.NEAREST)
    d = ImageDraw.Draw(im, 'RGBA')
    for s in lay['spots']:
        b = [v * Z for v in s['box']]; d.rectangle(b, outline=(255, 40, 40, 255), width=3); d.rectangle([b[0], b[1], b[0] + 7 * len(s['name']) + 6, b[1] + 14], fill=(0, 0, 0, 170)); d.text((b[0] + 3, b[1] + 2), s['name'], fill=(255, 255, 255, 255))
        x, y = s['x'] * Z, s['y'] * Z; d.ellipse([x - 5, y - 5, x + 5, y + 5], fill=(255, 220, 0, 255), outline=(0, 0, 0, 255))
    for p in lay['stand']:
        x, y = p['x'] * Z, p['y'] * Z; d.ellipse([x - 4, y - 4, x + 4, y + 4], fill=(0, 230, 255, 220), outline=(0, 0, 0, 255))
    if lay.get('compass_clear'): d.rectangle([v * Z for v in lay['compass_clear']], outline=(60, 255, 60, 255), width=2)
    d.rectangle([0, lay['h'] * Z - 16, 330, lay['h'] * Z], fill=(0, 0, 0, 200)); d.text((4, lay['h'] * Z - 13), k, fill=(255, 255, 255, 255))
    return im
for t in TYPES:
    cs = [cell(t, st) for st in STYLES]; w, h = cs[0].size
    sheet = Image.new('RGB', (w * 2, h * 4), (30, 30, 30))
    for i, c in enumerate(cs): sheet.paste(c, ((i % 2) * w, (i // 2) * h))
    sheet.save(os.path.join(OUT, f'sheet-{t}.png'), optimize=True); print('sheet', t)
