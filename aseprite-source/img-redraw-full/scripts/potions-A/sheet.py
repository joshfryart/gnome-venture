"""Contact sheet for the potion icons: 3x, 1x, 32 px and 16 px, on light and dark rows.
Usage: python3 sheet.py <png dir> <out.png> <title>"""
import sys, os
from PIL import Image, ImageDraw

SLUGS = ["healing-potion", "strong-healing-potion", "grand-healing-elixir", "lucky-draught",
         "sages-draught", "stoneskin-brew", "swiftfoot-elixir", "garden-tonic"]
src, out, title = sys.argv[1], sys.argv[2], sys.argv[3]
CW, ROWH = 300, 300
img = Image.new("RGB", (CW * 4, 40 + ROWH * 2 * 2), "#f1ece0")
d = ImageDraw.Draw(img)
d.text((10, 12), title, fill="#2a1a10")
for i, s in enumerate(SLUGS):
    ic = Image.open(os.path.join(src, s + ".png")).convert("RGBA")
    col, row = i % 4, i // 4
    for dark in (0, 1):
        x0, y0 = col * CW, 40 + (row * 2 + dark) * ROWH
        bg = "#2b2420" if dark else "#f1ece0"
        d.rectangle([x0, y0, x0 + CW - 1, y0 + ROWH - 1], fill=bg)
        img.paste(ic.resize((192, 192), Image.NEAREST), (x0 + 6, y0 + 6), ic.resize((192, 192), Image.NEAREST))
        # 1x, 32, 16 along the bottom
        for j, sz in enumerate((64, 32, 16)):
            sm = ic.resize((sz, sz), Image.NEAREST if sz == 64 else Image.LANCZOS)
            img.paste(sm, (x0 + 10 + j * 80, y0 + ROWH - 8 - sz), sm)
        d.text((x0 + 200, y0 + ROWH - 20), s[:18], fill="#f1ece0" if dark else "#2a1a10")
img.save(out)
print(out, img.size)
