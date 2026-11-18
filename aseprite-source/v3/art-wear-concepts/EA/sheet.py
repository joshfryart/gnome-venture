"""Contact sheet for EA Blossomreach wearable concepts: 4 rows x 5 cols, 3x NEAREST, names under."""
import glob
import os
from PIL import Image, ImageDraw, ImageFont

D = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
NAMES = {
    "footwear": ["Hemp-Cord Sandals", "Rain Clogs", "Indigo Stitch Boots", "Steppe Felt Boots", "Snow Straw Boots"],
    "backpack": ["Bamboo A-Frame", "Forager's Basket", "Knotted Cloth Bundle", "Lacquer Tea Chest", "Quilted Silk Satchel"],
    "coat": ["Indigo Work Jacket", "Padded Winter Vest", "Spring Wrap Coat", "Fleece-Lined Jacket", "Ramie Summer Jacket"],
    "cloak": ["Straw Rain Cape", "Plum Snow Hood", "Maple Shawl", "Felt Herder's Poncho", "Blossom Capelet"],
}
S, PAD, LAB, HEAD = 192, 14, 22, 34
try:
    font = ImageFont.truetype("DejaVuSans.ttf", 14)
    big = ImageFont.truetype("DejaVuSans-Bold.ttf", 18)
except OSError:
    font = big = ImageFont.load_default()
W = PAD + 5 * (S + PAD)
H = HEAD + 4 * (S + LAB + PAD) + PAD
sheet = Image.new("RGB", (W, H), (226, 221, 210))
d = ImageDraw.Draw(sheet)
d.text((PAD, 8), 'EA "Blossomreach" wearables — footwear / backpack / coat / cloak', fill=(43, 28, 38), font=big)
for r, cat in enumerate(CATS):
    files = sorted(glob.glob(os.path.join(D, f"{cat}-*.png")))
    for col, f in enumerate(files[:5]):
        im = Image.open(f).convert("RGBA")
        assert im.size == (64, 64), f
        x = PAD + col * (S + PAD)
        y = HEAD + r * (S + LAB + PAD)
        d.rectangle([x, y, x + S - 1, y + S - 1], fill=(236, 232, 222))
        sheet.paste(im.resize((S, S), Image.NEAREST), (x, y), im.resize((S, S), Image.NEAREST))
        name = f"{col + 1}. {NAMES[cat][col]}"
        tw = d.textlength(name, font=font)
        d.text((x + (S - tw) / 2, y + S + 3), name, fill=(43, 28, 38), font=font)
sheet.save(os.path.join(D, "sheet.png"))
print("sheet.png", sheet.size)
