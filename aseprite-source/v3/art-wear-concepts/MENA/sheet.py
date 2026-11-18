"""Contact sheet for the MENA wear concepts: 4 rows (footwear, backpack, coat, cloak) x 5, 3x NEAREST, names below."""
import glob, os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
NAMES = {
    "footwear": ["Dune Slippers", "Palm-Rope Sandals", "Indigo Wrap Boots", "Camel-Pad Overshoes", "Cedar Bath Clogs"],
    "backpack": ["Goatskin Waterskin", "Date-Palm Basket", "Kilim Saddle-Bag", "Copper-Pot Frame", "Bottle-Gourd Sling"],
    "coat": ["Loom-Stripe Vest", "Braided Cord Jacket", "Sand-Robe Coat", "Quilted Night Coat", "Caravan Leather Jerkin"],
    "cloak": ["Camel-Wool Hooded Cape", "Indigo Shawl", "Palm-Leaf Sun Cape", "Rose-Madder Mantle", "Goat-Hair Tent Cape"],
}
S, PAD, LAB, HEAD = 192, 16, 26, 40
W = PAD + 5 * (S + PAD)
H = HEAD + 4 * (S + LAB + PAD) + PAD
try:
    font = ImageFont.truetype("DejaVuSans.ttf", 15)
    big = ImageFont.truetype("DejaVuSans-Bold.ttf", 20)
except OSError:
    font = big = ImageFont.load_default()
sheet = Image.new("RGB", (W, H), (236, 230, 218))
d = ImageDraw.Draw(sheet)
d.text((PAD, 10), 'MENA "The Dunewhisper" - wear concepts', fill=(43, 28, 38), font=big)
for r, cat in enumerate(CATS):
    files = sorted(glob.glob(os.path.join(HERE, f"{cat}-[1-5]-*.png")))
    for i, f in enumerate(files):
        im = Image.open(f).convert("RGBA")
        assert im.size == (64, 64), f
        x = PAD + i * (S + PAD)
        y = HEAD + r * (S + LAB + PAD)
        d.rectangle([x, y, x + S - 1, y + S - 1], fill=(226, 219, 205))
        big_im = im.resize((S, S), Image.NEAREST)
        sheet.paste(big_im, (x, y), big_im)
        name = NAMES[cat][i]
        tw = d.textlength(name, font=font)
        d.text((x + (S - tw) / 2, y + S + 4), name, fill=(43, 28, 38), font=font)
sheet.save(os.path.join(HERE, "sheet.png"))
print("sheet.png", sheet.size)
