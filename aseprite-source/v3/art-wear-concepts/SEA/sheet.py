#!/usr/bin/env python3
"""Contact sheet for the SEA wearable concepts: 4 rows (footwear, backpack, coat, cloak) x 5, 3x NEAREST."""
import glob, os
from PIL import Image, ImageDraw, ImageFont

D = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
NAMES = {
    "footwear": ["Paddy Stilt-Clogs", "Pandan Sandals", "Ikat Leech-Wraps", "Rattan Trail Boot", "Mudflat Paddles"],
    "backpack": ["Rattan Back-Basket", "Bamboo Ladder-Pack", "Batik Bundle", "Nipa Thatch Pack", "Water-Jar Pack"],
    "coat": ["Indigo Batik Smock", "Pandan Weave Vest", "Ikat Wrap-Jacket", "Kapok Puffer", "Mangrove Oilcloth"],
    "cloak": ["Palm-Frond Rain Cape", "Banana-Leaf Hood", "Batik Shawl", "Net-Veil Mantle", "Monsoon Poncho"],
}
S, PAD, LAB, HEAD = 192, 16, 26, 40
def font(sz):
    for f in ["/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", "/usr/share/fonts/TTF/DejaVuSans.ttf"]:
        if os.path.exists(f): return ImageFont.truetype(f, sz)
    return ImageFont.load_default()
F, FH = font(15), font(20)
W = PAD + 5 * (S + PAD) + 90
H = HEAD + 4 * (S + LAB + PAD) + PAD
img = Image.new("RGB", (W, H), (232, 228, 218))
d = ImageDraw.Draw(img)
d.text((PAD, 10), 'SEA "The Monsoon Tangle" - wearable concepts (64 px, shown 3x)', fill=(43, 28, 38), font=FH)
for r, cat in enumerate(CATS):
    y = HEAD + r * (S + LAB + PAD)
    d.text((PAD + 5 * (S + PAD), y + S // 2 - 8), cat, fill=(90, 70, 80), font=F)
    for n in range(1, 6):
        f = glob.glob(os.path.join(D, f"{cat}-{n}-*.png"))[0]
        im = Image.open(f).convert("RGBA")
        assert im.size == (64, 64), f
        big = im.resize((S, S), Image.NEAREST)
        x = PAD + (n - 1) * (S + PAD)
        d.rectangle([x, y, x + S - 1, y + S - 1], fill=(242, 238, 228))
        img.paste(big, (x, y), big)
        t = f"{n}. {NAMES[cat][n - 1]}"
        tw = d.textlength(t, font=F)
        d.text((x + (S - tw) / 2, y + S + 4), t, fill=(43, 28, 38), font=F)
img.save(os.path.join(D, "sheet.png"))
print("sheet.png", img.size)
