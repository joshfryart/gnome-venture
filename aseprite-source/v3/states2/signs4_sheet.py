import sys
from PIL import Image
b, W, H = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
d = f"/tmp/ase/states2/{b}/"
strip = Image.open(d + f"{b}-empty.png").convert("RGBA")
a = set(strip.getchannel("A").getdata())
print(b, strip.size, "alpha values:", sorted(a))
BG = (197, 227, 165, 255)
GR = (128, 176, 92, 255)
pad = 8
fr = [strip.crop((k * W, 0, (k + 1) * W, H)) for k in range(4)]
sw = 4 * (W * 4) + 5 * pad
sh = H * 4 + 2 * pad + H * 2 + pad
sheet = Image.new("RGBA", (sw, sh), BG)
for k, f in enumerate(fr):
    sheet.alpha_composite(f.resize((W * 4, H * 4), Image.NEAREST), (pad + k * (W * 4 + pad), pad))
y2 = H * 4 + 2 * pad
x = pad
for bg in (BG, GR):
    tile = Image.new("RGBA", (W * 3 + 3 * pad, H * 2), bg)
    tile.alpha_composite(fr[0], (0, H // 2))
    tile.alpha_composite(fr[0].resize((W * 2, H * 2), Image.NEAREST), (W + pad, 0))
    sheet.alpha_composite(tile, (x, y2))
    x += W * 3 + 4 * pad
sheet.save(d + f"{b}-signs-sheet.png")
