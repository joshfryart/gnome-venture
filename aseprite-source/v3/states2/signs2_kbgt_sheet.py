import sys
from PIL import Image
BG = (196, 226, 170, 255)
NS = "/tmp/claude-0/-home-user-gnome-venture/0379a473-bbc7-5af0-81bd-b41f5db92fbf/scratchpad/ns/"
for b in sys.argv[1:]:
    d = f"/tmp/ase/states2/{b}/"
    im = Image.open(d + f"{b}-empty.png").convert("RGBA")
    ns = Image.open(NS + f"{b}/{b}-empty.png").convert("RGBA")
    l1 = Image.open(d + f"{b}-l1.png").convert("RGBA")
    W4, H = im.size; W = W4 // 4
    alphas = sorted(set(im.getchannel("A").tobytes()))
    fr = [im.crop((i * W, 0, (i + 1) * W, H)) for i in range(4)]
    boxes = []
    for i in range(4):
        bb = ns.crop((i * W, 0, (i + 1) * W, H)).getchannel("A").getbbox()
        boxes.append((bb, bb[2] - bb[0], bb[3] - bb[1]))
    u = [min(x[0][0] for x in boxes), min(x[0][1] for x in boxes), max(x[0][2] for x in boxes), max(x[0][3] for x in boxes)]
    l1bb = l1.getchannel("A").getbbox()
    print(b, "canvas", W, H, "alphas", alphas, "l1w", l1bb[2] - l1bb[0])
    for x in boxes: print("   frame", x)
    print("   union", u, u[2] - u[0], "x", u[3] - u[1])
    g = 8
    s1 = 3
    sw = max(4 * (W * 4) + 5 * g, 2 * W * s1 + 3 * g)
    sh = g + H * 4 + g + H * s1 + g
    s = Image.new("RGBA", (sw, sh), BG)
    for i, f in enumerate(fr):
        s.alpha_composite(f.resize((W * 4, H * 4), Image.NEAREST), (g + i * (W * 4 + g), g))
    y2 = g + H * 4 + g
    s.alpha_composite(l1.resize((W * s1, H * s1), Image.NEAREST), (g, y2))
    s.alpha_composite(fr[0].resize((W * s1, H * s1), Image.NEAREST), (2 * g + W * s1, y2))
    s.alpha_composite(fr[0], (3 * g + 2 * W * s1, y2))
    s.alpha_composite(fr[0].resize((W * 2, H * 2), Image.NEAREST), (4 * g + 2 * W * s1 + W, y2))
    s.convert("RGB").save(d + f"{b}-signs2-sheet.png")
