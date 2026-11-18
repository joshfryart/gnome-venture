"""Contact sheet for the CB wearable concepts: 4 rows x 5 cols, 3x NEAREST, name under each icon."""
import glob, os, sys
from PIL import Image, ImageDraw, ImageFont
D = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
S, PAD, LAB = 3, 14, 18
CW, CH = 64 * S + PAD, 64 * S + LAB + PAD
try:
    font = ImageFont.truetype("DejaVuSans.ttf", 12)
except OSError:
    font = ImageFont.load_default()
sheet = Image.new("RGB", (5 * CW + PAD + 90, 4 * CH + PAD), (226, 222, 212))
dr = ImageDraw.Draw(sheet)
bad = []
for r, cat in enumerate(CATS):
    dr.text((8, PAD + r * CH + 64 * S // 2), cat, fill=(70, 60, 64), font=font)
    for i, f in enumerate(sorted(glob.glob(os.path.join(D, f"{cat}-[1-5]-*.png")))):
        im = Image.open(f).convert("RGBA")
        px = list(im.getdata())
        if im.size != (64, 64) or any(a not in (0, 255) for *_, a in px) or any(p[:3] in ((0, 0, 0), (255, 255, 255)) and p[3] for p in px):
            bad.append(f)
        x, y = 90 + PAD + i * CW, PAD + r * CH
        big = im.resize((64 * S, 64 * S), Image.NEAREST)
        sheet.paste(big, (x, y), big)
        name = os.path.basename(f)[:-4].split("-", 2)[2].replace("-", " ").title()
        tw = dr.textlength(name, font=font)
        dr.text((x + (64 * S - tw) / 2, y + 64 * S + 2), name, fill=(60, 44, 52), font=font)
sheet.save(os.path.join(D, "sheet.png"))
print("bad:", bad)
