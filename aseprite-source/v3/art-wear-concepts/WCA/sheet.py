#!/usr/bin/env python3
"""Contact sheet for the WCA wearable concepts: 4 rows (footwear, backpack, coat, cloak) x 5 icons,
each 3x NEAREST on a neutral light background with its name underneath.
Usage: python3 sheet.py [out.png] [--rows footwear,coat] [--scale 3]
Also checks every icon: 64x64, hard alpha, no #000000/#ffffff."""
import os, re, sys
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
args = sys.argv[1:]
out = os.path.join(HERE, "sheet.png")
rows, scale = CATS, 3
i = 0
while i < len(args):
    a = args[i]
    if a == "--rows": rows = args[i + 1].split(","); i += 2; continue
    if a == "--scale": scale = int(args[i + 1]); i += 2; continue
    out = a; i += 1

names = {}
md = open(os.path.join(HERE, "concepts.md"), encoding="utf-8").read()
cat = None
for line in md.splitlines():
    m = re.match(r"## \d+\. (\w+)", line)
    if m: cat = {"Footwear": "footwear", "Backpack": "backpack", "Coat": "coat", "Cloak": "cloak"}[m.group(1)]
    m = re.match(r"\| (\d) \| \*\*(.+?)\*\*", line)
    if m and cat: names[(cat, int(m.group(1)))] = m.group(2)

try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 13)
    tfont = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 15)
except OSError:
    font = tfont = ImageFont.load_default()

S = 64 * scale
cw, ch, lab, pad, top = S + 24, S + 30, 90, 10, 34
W = lab + 5 * cw + pad
H = top + len(rows) * ch + pad
sheet = Image.new("RGBA", (W, H), (226, 221, 210, 255))
d = ImageDraw.Draw(sheet)
d.text((pad, 8), "WCA - The Greatcanopy: wearable concepts", fill=(60, 44, 52), font=tfont)
problems = []
for r, cat in enumerate(rows):
    y = top + r * ch
    d.text((pad, y + S // 2 - 8), cat, fill=(60, 44, 52), font=tfont)
    files = sorted(f for f in os.listdir(HERE) if f.startswith(cat + "-") and f.endswith(".png"))
    for f in files:
        n = int(f.split("-")[1])
        im = Image.open(os.path.join(HERE, f)).convert("RGBA")
        if im.size != (64, 64): problems.append(f"{f}: size {im.size}")
        for px in im.getdata():
            if px[3] not in (0, 255): problems.append(f"{f}: semi alpha"); break
            if px[3] == 255 and px[:3] in ((0, 0, 0), (255, 255, 255)): problems.append(f"{f}: pure b/w"); break
        x = lab + (n - 1) * cw
        d.rectangle([x + 4, y, x + 4 + S + 15, y + S + 1], fill=(238, 234, 225, 255))
        sheet.alpha_composite(im.resize((S, S), Image.NEAREST), (x + 12, y))
        name = names.get((cat, n), f)
        tw = d.textlength(name, font=font)
        d.text((x + 12 + (S - tw) / 2, y + S + 6), name, fill=(60, 44, 52), font=font)
sheet.convert("RGB").save(out)
print("saved", out, "| problems:", problems or "none")
