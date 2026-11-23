"""score.py <render.png> <reference.png> [scores.txt] [script.lua]
Objective similarity of a render to the reference (0..1, higher = closer):
  sil    - silhouette overlap (alpha IoU)
  layout - colour layout at 1/8 resolution (forgives pixel-level differences)
  pal    - palette overlap (coarse colour histogram intersection)
  total  - 0.4*sil + 0.4*layout + 0.2*pal (shape counts more than palette)
Prints one line, plus the change vs the previous render if scores.txt is given."""
import sys
from PIL import Image

out, ref = Image.open(sys.argv[1]).convert("RGBA"), Image.open(sys.argv[2]).convert("RGBA")
if ref.size != out.size:
    ref = ref.resize(out.size, Image.NEAREST)
W, H = out.size
op, rp = out.load(), ref.load()

inter = union = 0
for y in range(H):
    for x in range(W):
        a, b = op[x, y][3] > 0, rp[x, y][3] > 0
        inter += a and b
        union += a or b
sil = inter / union if union else 1.0

def small(im):
    bg = Image.new("RGBA", im.size, (0, 0, 0, 255))
    bg.alpha_composite(im)
    return bg.convert("RGB").resize((max(1, W // 8), max(1, H // 8)), Image.BOX)
a, b = small(out), small(ref)
ap, bp = a.load(), b.load()
d = n = 0
for y in range(a.size[1]):
    for x in range(a.size[0]):
        d += sum(abs(ap[x, y][i] - bp[x, y][i]) for i in range(3)) / 3
        n += 1
layout = 1 - d / n / 255

def hist(im):
    h, px, c = {}, im.load(), 0
    for y in range(H):
        for x in range(W):
            r, g, bl, al = px[x, y]
            if al:
                k = (r >> 5, g >> 5, bl >> 5)
                h[k] = h.get(k, 0) + 1
                c += 1
    return {k: v / c for k, v in h.items()} if c else {}
ho, hr = hist(out), hist(ref)
pal = sum(min(ho.get(k, 0), hr.get(k, 0)) for k in set(ho) | set(hr))

total = 0.4 * sil + 0.4 * layout + 0.2 * pal
line = f"SCORE total={total:.3f} sil={sil:.3f} layout={layout:.3f} pal={pal:.3f}"
if len(sys.argv) > 3:
    path, prev = sys.argv[3], None
    try:
        prev = float(open(path).read().split()[-1])
    except Exception:
        pass
    open(path, "a").write(f"{total:.3f}\n" if prev is not None else f"{total:.3f}\n")
    if prev is not None:
        line += f"  (prev {prev:.3f}, {'+' if total >= prev else ''}{total - prev:.3f})"
if len(sys.argv) > 4:
    import os, shutil
    d = os.path.dirname(sys.argv[3]) or "."
    bp = os.path.join(d, "best.txt")
    try:
        best = float(open(bp).read())
    except Exception:
        best = -1
    if total > best:
        open(bp, "w").write(f"{total:.3f}")
        shutil.copy(sys.argv[4], os.path.join(d, "best.lua"))
        shutil.copy(sys.argv[1], os.path.join(d, "best.png"))
        line += "  [new best]"
    else:
        line += f"  [best {best:.3f}]"
print(line)
