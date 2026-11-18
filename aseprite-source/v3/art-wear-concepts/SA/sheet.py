# sheet.py: contact sheet for the SA wearable concepts (4 rows x 5 columns, 3x NEAREST, name under each icon)
import os, glob
from PIL import Image, ImageDraw, ImageFont
D = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
S, CW, CH, TOP, LEFT = 3, 212, 232, 34, 110
BG, INK, SUB = (226, 221, 210), (43, 28, 38), (110, 96, 100)
try:
    F = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 13)
    FB = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 15)
except OSError:
    F = FB = ImageFont.load_default()
img = Image.new("RGB", (LEFT + 5 * CW + 10, TOP + 4 * CH + 6), BG)
d = ImageDraw.Draw(img)
d.text((10, 8), "SA  The Rainroot Reaches: wearable concepts (64 px icons at 3x)", font=FB, fill=INK)
for r, cat in enumerate(CATS):
    y0 = TOP + r * CH
    d.text((10, y0 + 90), cat, font=FB, fill=INK)
    for f in sorted(glob.glob(os.path.join(D, f"{cat}-*.png"))):
        n = int(os.path.basename(f).split("-")[1])
        ic = Image.open(f).convert("RGBA")
        assert ic.size == (64, 64), f
        big = ic.resize((64 * S, 64 * S), Image.NEAREST)
        x0 = LEFT + (n - 1) * CW + (CW - 64 * S) // 2
        img.paste(big, (x0, y0), big)
        name = " ".join(os.path.basename(f)[:-4].split("-")[2:])
        name = f"{n}. " + name.title()
        w = d.textlength(name, font=F)
        d.text((LEFT + (n - 1) * CW + (CW - w) / 2, y0 + 64 * S + 6), name, font=F, fill=SUB)
img.save(os.path.join(D, "sheet.png"))
print("sheet.png", img.size)
