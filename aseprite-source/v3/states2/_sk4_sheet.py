import sys
from PIL import Image
b, W, H = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
d = f"/tmp/ase/states2/{b}/"
strip = Image.open(d + f"{b}-empty.png").convert("RGBA")
assert strip.size == (4 * W, H), strip.size
fr = [strip.crop((i * W, 0, i * W + W, H)) for i in range(4)]
semi = sum(1 for p in strip.getdata() if p[3] not in (0, 255))
print(b, "semi", semi)
S, G = 4, 6
BG = (178, 214, 150, 255)
sheet = Image.new("RGBA", (4 * W * S + 5 * G, H * S + 3 * G + 2 * H), BG)
for i, im in enumerate(fr):
    sheet.alpha_composite(im.resize((W * S, H * S), Image.NEAREST), (G + i * (W * S + G), G))
y2 = H * S + 2 * G
sheet.alpha_composite(fr[0], (G, y2))
sheet.alpha_composite(fr[0].resize((W * 2, H * 2), Image.NEAREST), (2 * G + W, y2))
sheet.save(d + f"{b}-signs-sheet.png")
