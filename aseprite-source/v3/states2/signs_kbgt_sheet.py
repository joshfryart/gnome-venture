import sys
from PIL import Image
BG = (196, 226, 170, 255)
for b in sys.argv[1:]:
    d = f"/tmp/ase/states2/{b}/"
    im = Image.open(d + f"{b}-empty.png").convert("RGBA")
    W4, H = im.size
    W = W4 // 4
    alphas = set(im.getchannel("A").tobytes())
    fr = [im.crop((i * W, 0, (i + 1) * W, H)) for i in range(4)]
    g = 8
    sw = 4 * (W * 4) + 5 * g
    sh = g + H * 4 + g + H * 2 + g
    s = Image.new("RGBA", (sw, sh), BG)
    for i, f in enumerate(fr):
        s.alpha_composite(f.resize((W * 4, H * 4), Image.NEAREST), (g + i * (W * 4 + g), g))
    y2 = g + H * 4 + g
    s.alpha_composite(fr[0], (g, y2))
    s.alpha_composite(fr[0].resize((W * 2, H * 2), Image.NEAREST), (g + W + g, y2))
    s.alpha_composite(fr[1], (g + W + g + W * 2 + g, y2))
    s.convert("RGB").save(d + f"{b}-signs-sheet.png")
    print(b, im.size, "alphas", sorted(alphas))
