"""Contact sheet for the Spicepeak (CSA) wear concepts: 4 rows x 5 columns, icons 3x NEAREST, names below.
Also checks every PNG: 64x64, hard alpha, no #000000 / #ffffff.
Run: python3 sheet.py"""
import glob, os
from PIL import Image, ImageDraw, ImageFont

D = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
S, PAD, LABEL = 3, 10, 26
CW = 64 * S + PAD * 2
CH = 64 * S + PAD + LABEL
HEAD = 30
BG, CELL, TXT = (226, 220, 208), (236, 231, 221), (60, 44, 52)

def font(sz):
    for f in ["/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", "/usr/share/fonts/dejavu/DejaVuSans.ttf"]:
        if os.path.exists(f):
            return ImageFont.truetype(f, sz)
    return ImageFont.load_default()

def check(path, im):
    assert im.size == (64, 64), (path, im.size)
    for r, g, b, a in im.getdata():
        assert a in (0, 255), (path, "semi alpha", a)
        if a:
            assert (r, g, b) not in ((0, 0, 0), (255, 255, 255)), (path, "pure black/white")

f, fh = font(13), font(16)
sheet = Image.new("RGB", (CW * 5, HEAD + CH * 4), BG)
d = ImageDraw.Draw(sheet)
d.text((PAD, 7), "Spicepeak (CSA) wearables: footwear / backpack / coat / cloak", fill=TXT, font=fh)
for r, cat in enumerate(CATS):
    files = sorted(glob.glob(os.path.join(D, f"{cat}-[1-5]-*.png")))
    assert len(files) == 5, (cat, files)
    for col, p in enumerate(files):
        im = Image.open(p).convert("RGBA")
        check(p, im)
        x, y = col * CW, HEAD + r * CH
        d.rectangle([x + 4, y + 2, x + CW - 5, y + CH - 4], fill=CELL)
        big = im.resize((64 * S, 64 * S), Image.NEAREST)
        sheet.paste(big, (x + PAD, y + PAD // 2), big)
        name = os.path.basename(p)[:-4].split("-", 2)[2].replace("-", " ").title()
        tw = d.textlength(name, font=f)
        d.text((x + (CW - tw) / 2, y + 64 * S + PAD // 2 + 4), name, fill=TXT, font=f)
sheet.save(os.path.join(D, "sheet.png"))
print("sheet.png ok", sheet.size)
