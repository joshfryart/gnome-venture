"""Check hovel decor PNGs and build a 4x contact sheet on plank + cream wall backing.
usage: python3 sheet.py out.png file1.png file2.png ..."""
import sys
from PIL import Image

SIZES = {"shelf": (64, 40), "rug": (112, 24), "lamp": (16, 40), "pet": (48, 32)}
out, files = sys.argv[1], sys.argv[2:]
cells = []
for f in files:
    im = Image.open(f).convert("RGBA")
    slot = f.split("hovel-")[-1].split("-")[0]
    px = list(im.getdata())
    semi = sum(1 for p in px if p[3] not in (0, 255))
    bw = sum(1 for p in px if p[3] == 255 and (p[:3] in ((0, 0, 0), (255, 255, 255))))
    ok = im.size == SIZES[slot] and semi == 0 and bw == 0
    print(f"{'OK ' if ok else 'BAD'} {f.split('/')[-1]} {im.size} semi={semi} bw={bw}")
    cells.append(im)
S, pad = 4, 12
cw = max(i.width for i in cells) * S + pad * 2
ch = max(i.height for i in cells) * S + pad * 2
cols = 3
rows = (len(cells) + cols - 1) // cols
sheet = Image.new("RGBA", (cw * cols, ch * rows))
for k, im in enumerate(cells):
    ox, oy = (k % cols) * cw, (k // cols) * ch
    bg = Image.new("RGBA", (cw, ch))
    floor_y = ch * 2 // 3
    for y in range(ch):
        for x in range(cw):
            if y < floor_y:
                col = (236, 220, 188) if (y // 8) % 2 else (230, 213, 180)
                if y > floor_y - 24:
                    col = (70, 138, 132)
            else:
                plank = ((y - floor_y) // 28)
                col = (132, 86, 54) if plank % 2 else (148, 98, 62)
                if (y - floor_y) % 28 == 0:
                    col = (90, 56, 40)
            bg.putpixel((x, y), col)
    big = im.resize((im.width * S, im.height * S), Image.NEAREST)
    slot = files[k].split("hovel-")[-1].split("-")[0]
    py = pad if slot == "shelf" else max(pad, ch - pad - big.height - (0 if slot == "rug" else 30))
    bg.alpha_composite(big, ((cw - big.width) // 2, py))
    small = im
    bg.alpha_composite(small, (4, 4))
    sheet.paste(bg, (ox, oy))
sheet.convert("RGB").save(out)
print("sheet", out, sheet.size)
