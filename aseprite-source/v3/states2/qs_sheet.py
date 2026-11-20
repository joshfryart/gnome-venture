import sys
from PIL import Image
b = sys.argv[1]
d = f"/tmp/ase/states2/{b}/"
e = Image.open(d + f"{b}-empty.png").convert("RGBA")
r = Image.open(d + f"{b}-ready.png").convert("RGBA")
H = e.height; W = e.width // 4
cells = [e.crop((i * W, 0, (i + 1) * W, H)) for i in range(4)]
cells += [Image.open(d + f"{b}-l{i}.png").convert("RGBA") for i in (1, 2, 3)]
cells += [r.crop((i * W, 0, (i + 1) * W, H)) for i in range(4)]
S = 3
sheet = Image.new("RGBA", (len(cells) * W * S, H * S), (200, 228, 160, 255))
for i, cl in enumerate(cells):
    sheet.alpha_composite(cl.resize((W * S, H * S), Image.NEAREST), (i * W * S, 0))
sheet.save(d + f"{b}-sheet.png")
bad = 0
for f in [f"{b}-empty", f"{b}-l1", f"{b}-l2", f"{b}-l3", f"{b}-ready"]:
    im = Image.open(d + f + ".png").convert("RGBA")
    bad += sum(1 for p in im.getdata() if p[3] not in (0, 255))
print("semi-transparent px:", bad, sheet.size)
