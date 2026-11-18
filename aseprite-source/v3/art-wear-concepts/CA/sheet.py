"""Contact sheet for the Maizehollow (CA) wear concepts: 4 rows x 5 columns, icons 3x NEAREST, name under each."""
import glob, os
from PIL import Image, ImageDraw, ImageFont
D = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
S, PAD, LAB, HEAD = 192, 16, 22, 34
try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 13)
    hfont = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 16)
except OSError:
    font = hfont = ImageFont.load_default()
W = 5 * (S + PAD) + PAD
H = HEAD + 4 * (S + LAB + PAD) + PAD
sheet = Image.new("RGB", (W, H), (234, 230, 220))
d = ImageDraw.Draw(sheet)
d.text((PAD, 9), "Maizehollow (CA) wear concepts: footwear / backpack / coat / cloak", fill=(43, 28, 38), font=hfont)
for r, cat in enumerate(CATS):
    files = sorted(glob.glob(os.path.join(D, f"{cat}-[1-5]-*.png")))
    for i, f in enumerate(files):
        im = Image.open(f).convert("RGBA").resize((S, S), Image.NEAREST)
        x, y = PAD + i * (S + PAD), HEAD + r * (S + LAB + PAD)
        sheet.paste(im, (x, y), im)
        label = f"{i + 1}. " + os.path.basename(f)[:-4].split("-", 2)[2].replace("-", " ").title()
        tw = d.textlength(label, font=font)
        d.text((x + (S - tw) / 2, y + S + 3), label, fill=(43, 28, 38), font=font)
sheet.save(os.path.join(D, "sheet.png"))
print("sheet.png", sheet.size)
