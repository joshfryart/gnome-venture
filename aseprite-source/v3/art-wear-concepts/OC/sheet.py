#!/usr/bin/env python3
"""Contact sheet for the OC (Coralscatter) wear concepts: 4 rows x 5 cols, icons at 3x NEAREST.
Also checks every icon: 64x64, hard alpha, no pure black/white, outline ink present."""
import glob, os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
S, PAD, LAB, HEAD = 192, 12, 22, 30
BG, FG = (232, 228, 218, 255), (60, 44, 52, 255)
try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 13)
    bold = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 15)
except OSError:
    font = bold = ImageFont.load_default()

def check(path, im):
    assert im.size == (64, 64), path
    px = [im.getpixel((x, y)) for y in range(64) for x in range(64)]
    assert all(a in (0, 255) for *_, a in px), f"{path}: semi alpha"
    rgb = {p[:3] for p in px if p[3] == 255}
    assert (0, 0, 0) not in rgb and (255, 255, 255) not in rgb, f"{path}: pure b/w"
    assert (0x2b, 0x1c, 0x26) in rgb, f"{path}: no ink outline"

W = 5 * (S + PAD) + PAD
H = HEAD + 4 * (S + LAB + PAD) + PAD
sheet = Image.new("RGBA", (W, H), BG)
d = ImageDraw.Draw(sheet)
d.text((PAD, 8), "OC  The Coralscatter  -  wear concepts (footwear / backpack / coat / cloak)", fill=FG, font=bold)
for r, cat in enumerate(CATS):
    files = sorted(glob.glob(os.path.join(HERE, f"{cat}-[1-5]-*.png")))
    assert len(files) == 5, (cat, files)
    for col, f in enumerate(files):
        im = Image.open(f).convert("RGBA")
        check(f, im)
        x = PAD + col * (S + PAD)
        y = HEAD + r * (S + LAB + PAD)
        sheet.alpha_composite(im.resize((S, S), Image.NEAREST), (x, y))
        name = os.path.basename(f)[:-4].split("-", 2)[2].replace("-", " ")
        tw = d.textlength(name, font=font)
        d.text((x + (S - tw) / 2, y + S + 3), name, fill=FG, font=font)
sheet.save(os.path.join(HERE, "sheet.png"))
print("sheet.png", sheet.size)
