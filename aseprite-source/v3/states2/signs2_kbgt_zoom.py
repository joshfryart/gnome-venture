import sys
from PIL import Image
b, x0, y0, x1, y1 = sys.argv[1], *map(int, sys.argv[2:6])
im = Image.open(f"/tmp/ase/states2/{b}/{b}-empty.png").convert("RGBA")
W = im.width // 4
s = Image.new("RGBA", (4 * (x1 - x0) * 10 + 30, (y1 - y0) * 10), (196, 226, 170, 255))
for i in range(4):
    f = im.crop((i * W + x0, y0, i * W + x1, y1))
    s.alpha_composite(f.resize(((x1 - x0) * 10, (y1 - y0) * 10), Image.NEAREST), (i * ((x1 - x0) * 10 + 10), 0))
s.save("/tmp/claude-0/-home-user-gnome-venture/0379a473-bbc7-5af0-81bd-b41f5db92fbf/scratchpad/z.png")
