"""Contact sheet for the Mistmoor (NWE) wearable concepts: 4 rows x 5 columns, 3x NEAREST, names under icons."""
import glob, os
from PIL import Image, ImageDraw, ImageFont

D = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
NAMES = {
    "footwear": ["Alder Clogs", "Drain Brogues", "Felted Fleece Boots", "Birch-Bark Slippers", "Herringbone Gaiters"],
    "backpack": ["Peat Creel", "Waxed Roll-top", "Heather Frame", "Bark Box Pack", "Fleece Bundle"],
    "coat": ["Cable-Knit Long Coat", "Waxed Field Jacket", "Tweed Waistcoat", "Tanbark Smock", "Eiderdown Coat"],
    "cloak": ["Heather Shawl", "Mustard Rain Cape", "Sheepskin Mantle", "Rush Thatch Cape", "Woad Mist Cloak"],
}
S, CW, CH, LW, TOP = 3, 224, 236, 96, 36
BG, CELL, TXT = (232, 226, 214), (244, 239, 228), (60, 44, 52)
try:
    font = ImageFont.truetype("DejaVuSans.ttf", 13)
    big = ImageFont.truetype("DejaVuSans-Bold.ttf", 16)
except OSError:
    font = big = ImageFont.load_default()
sheet = Image.new("RGB", (LW + 5 * CW, TOP + 4 * CH), BG)
d = ImageDraw.Draw(sheet)
d.text((10, 9), "Mistmoor (NWE): wearable concepts", fill=TXT, font=big)
for r, cat in enumerate(CATS):
    y0 = TOP + r * CH
    d.text((10, y0 + CH // 2 - 8), cat, fill=TXT, font=big)
    for n in range(5):
        f = glob.glob(os.path.join(D, f"{cat}-{n + 1}-*.png"))[0]
        im = Image.open(f).convert("RGBA")
        assert im.size == (64, 64)
        x0 = LW + n * CW
        d.rectangle([x0 + 8, y0 + 4, x0 + CW - 8, y0 + CH - 6], fill=CELL)
        big_im = im.resize((64 * S, 64 * S), Image.NEAREST)
        sheet.paste(big_im, (x0 + (CW - 64 * S) // 2, y0 + 8), big_im)
        name = f"{n + 1}. {NAMES[cat][n]}"
        tw = d.textlength(name, font=font)
        d.text((x0 + (CW - tw) / 2, y0 + 8 + 64 * S + 6), name, fill=TXT, font=font)
sheet.save(os.path.join(D, "sheet.png"))
print("wrote", os.path.join(D, "sheet.png"))
