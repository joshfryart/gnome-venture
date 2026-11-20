import sys
from PIL import Image
b, W, H = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
d = f'/tmp/ase/states2/{b}/'
e = Image.open(d + f'{b}-empty.png').convert('RGBA')
l1 = Image.open(d + f'{b}-l1.png').convert('RGBA')
G = (196, 228, 160, 255)
pad = 8
sw = 4 * W * 4 + 5 * pad
sh = pad + H * 4 + pad + H * 3 + pad
S = Image.new('RGBA', (max(sw, 2 * W * 3 + 3 * pad + W * 2 + pad), sh), G)
for k in range(4):
    f = e.crop((k * W, 0, k * W + W, H)).resize((W * 4, H * 4), Image.NEAREST)
    S.alpha_composite(f, (pad + k * (W * 4 + pad), pad))
y2 = pad + H * 4 + pad
S.alpha_composite(l1.resize((W * 3, H * 3), Image.NEAREST), (pad, y2))
f1 = e.crop((0, 0, W, H))
S.alpha_composite(f1.resize((W * 3, H * 3), Image.NEAREST), (2 * pad + W * 3, y2))
# small 1x and 2x previews for legibility
S.alpha_composite(f1, (3 * pad + W * 6, y2))
S.alpha_composite(f1.resize((W * 2, H * 2), Image.NEAREST), (4 * pad + W * 7, y2))
S.save(d + f'{b}-signs2-sheet.png')
