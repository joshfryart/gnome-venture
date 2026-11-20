import sys
from PIL import Image
b, W, H = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
d = f"/tmp/ase/states2/{b}/"
strip = Image.open(d + f"{b}-empty.png").convert("RGBA")
print(b, strip.size, "alpha:", sorted(set(strip.getchannel("A").getdata())))
SH = {(0x6f, 0x8c, 0x7a), (0x5b, 0x78, 0x68)}
fr = [strip.crop((k * W, 0, (k + 1) * W, H)) for k in range(4)]
ux0 = uy0 = 10**9; ux1 = uy1 = -1
for i, f in enumerate(fr):
    xs, ys = [], []
    for y in range(H):
        for x in range(W):
            p = f.getpixel((x, y))
            if p[3] and p[:3] not in SH:
                xs.append(x); ys.append(y)
    bb = (min(xs), min(ys), max(xs), max(ys))
    ux0, uy0, ux1, uy1 = min(ux0, bb[0]), min(uy0, bb[1]), max(ux1, bb[2]), max(uy1, bb[3])
    print(f" frame {i+1}: bbox {bb} -> {bb[2]-bb[0]+1} x {bb[3]-bb[1]+1}")
print(f" union: {(ux0,uy0,ux1,uy1)} -> {ux1-ux0+1} x {uy1-uy0+1}")
l1 = Image.open(d + f"{b}-l1.png").convert("RGBA")
BG = (197, 227, 165, 255)
pad = 8
sw = 4 * (W * 4) + 5 * pad
sh = H * 4 + 3 * pad + H * 3
sheet = Image.new("RGBA", (sw, sh), BG)
for k, f in enumerate(fr):
    sheet.alpha_composite(f.resize((W * 4, H * 4), Image.NEAREST), (pad + k * (W * 4 + pad), pad))
y2 = H * 4 + 2 * pad
sheet.alpha_composite(l1.resize((W * 3, H * 3), Image.NEAREST), (pad, y2))
sheet.alpha_composite(fr[0].resize((W * 3, H * 3), Image.NEAREST), (pad * 2 + W * 3, y2))
sheet.alpha_composite(fr[0], (pad * 4 + W * 6, y2 + H))
sheet.save(d + f"{b}-signs2-sheet.png")
