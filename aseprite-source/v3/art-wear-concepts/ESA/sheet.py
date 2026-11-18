"""Contact sheet for the ESA (Thornacre Savanna) wearable concepts: 4 rows x 5 columns, 3x NEAREST."""
import os
from PIL import Image, ImageDraw, ImageFont

D = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
S, CELL_W, CELL_H, PAD, HEAD = 3, 64 * 3 + 24, 64 * 3 + 30, 12, 34
BG, CARD, TXT, SUB = (234, 228, 216), (244, 239, 229), (60, 44, 52), (120, 100, 96)


def font(size, bold=False):
    for p in ["/usr/share/fonts/truetype/dejavu/DejaVuSans%s.ttf" % ("-Bold" if bold else ""),
              "/usr/share/fonts/dejavu/DejaVuSans%s.ttf" % ("-Bold" if bold else "")]:
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def main():
    fN, fT, fR = font(12), font(16, True), font(13, True)
    W = PAD + 90 + 5 * (CELL_W + PAD)
    H = HEAD + PAD + 4 * (CELL_H + PAD)
    sh = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(sh)
    d.text((PAD, 9), "Thornacre Savanna (ESA): wearable concepts", fill=TXT, font=fT)
    for r, cat in enumerate(CATS):
        y = HEAD + PAD + r * (CELL_H + PAD)
        d.text((PAD, y + CELL_H // 2 - 8), cat, fill=SUB, font=fR)
        for n in range(1, 6):
            fn = [f for f in sorted(os.listdir(D)) if f.startswith("%s-%d-" % (cat, n)) and f.endswith(".png")][0]
            im = Image.open(os.path.join(D, fn)).convert("RGBA")
            assert im.size == (64, 64), fn
            x = PAD + 90 + (n - 1) * (CELL_W + PAD)
            d.rectangle([x, y, x + CELL_W - 1, y + CELL_H - 1], fill=CARD)
            big = im.resize((64 * S, 64 * S), Image.NEAREST)
            sh.paste(big, (x + 12, y + 4), big)
            name = fn[len(cat) + 3:-4].replace("-", " ").title().replace("Herders", "Herder's")
            tw = d.textlength(name, font=fN)
            d.text((x + (CELL_W - tw) / 2, y + CELL_H - 22), name, fill=TXT, font=fN)
    sh.save(os.path.join(D, "sheet.png"))


if __name__ == "__main__":
    main()
