import sys
from PIL import Image
b, W, H = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
x0, y0, x1, y1 = [int(v) for v in sys.argv[4:8]]
s = Image.open(f"/tmp/ase/states2/{b}/{b}-empty.png").convert("RGBA")
Z = 10; w, h = x1 - x0, y1 - y0
out = Image.new("RGBA", (4 * (w * Z + 10), h * Z), (197, 227, 165, 255))
for k in range(4):
    f = s.crop((k * W + x0, y0, k * W + x1, y1)).resize((w * Z, h * Z), Image.NEAREST)
    out.alpha_composite(f, (k * (w * Z + 10), 0))
out.save("/tmp/claude-0/-home-user-gnome-venture/0379a473-bbc7-5af0-81bd-b41f5db92fbf/scratchpad/z.png")
