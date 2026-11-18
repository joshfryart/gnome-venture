"""Contact sheet for the Olivewhistle Shore (SE) wear concepts: 4 rows x 5 columns, icons 3x NEAREST."""
import glob, os
from PIL import Image, ImageDraw, ImageFont

D = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
NAMES = {
    "footwear": ["Shoreline Rope Slips", "Sunpath Sandals", "Corkbark Clogs", "Thyme-Hill Wraps", "Harvest Treaders"],
    "backpack": ["Olive Picker's Creel", "Fisher's Float Net", "Amphora Frame", "Sailcloth Seabag", "Lemon-Grove Satchel"],
    "coat": ["Net-Mender's Smock", "Goatherd's Fleece Vest", "Olive-Grove Quilt Jacket", "Vintner's Long Coat", "Sun-Stripe Tunic Coat"],
    "cloak": ["Shepherd's Felt Cape", "Lemon-Fringe Shawl", "Loom-Stripe Poncho", "Whitewash Sun Mantle", "Sea-Squall Capelet"],
}
S, CW, CH, PAD, TOP = 3, 230, 232, 12, 34
try:
    font = ImageFont.truetype("DejaVuSans.ttf", 13)
    big = ImageFont.truetype("DejaVuSans-Bold.ttf", 16)
except OSError:
    font = big = ImageFont.load_default()
W, H = PAD * 2 + 110 + 5 * CW, TOP + PAD + 4 * CH
sheet = Image.new("RGB", (W, H), (236, 232, 224))
d = ImageDraw.Draw(sheet)
d.text((PAD, 8), "Olivewhistle Shore (SE): wear concepts", fill=(60, 44, 52), font=big)
for r, cat in enumerate(CATS):
    y0 = TOP + r * CH
    d.text((PAD, y0 + 90), cat, fill=(60, 44, 52), font=big)
    for n in range(5):
        f = glob.glob(os.path.join(D, f"{cat}-{n + 1}-*.png"))[0]
        im = Image.open(f).convert("RGBA")
        assert im.size == (64, 64)
        im = im.resize((64 * S, 64 * S), Image.NEAREST)
        x0 = PAD + 110 + n * CW + (CW - 64 * S) // 2
        sheet.paste(im, (x0, y0), im)
        t = NAMES[cat][n]
        tw = d.textlength(t, font=font)
        d.text((PAD + 110 + n * CW + (CW - tw) / 2, y0 + 64 * S + 6), t, fill=(60, 44, 52), font=font)
sheet.save(os.path.join(D, "sheet.png"))
print("sheet.png", sheet.size)
