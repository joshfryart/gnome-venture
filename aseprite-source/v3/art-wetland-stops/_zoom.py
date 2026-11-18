# zoom.py in.png out.png x0 y0 x1 y1 scale : nearest-neighbour crop for review
import sys
from PIL import Image
a = sys.argv
im = Image.open(a[1]).convert("RGBA")
x0, y0, x1, y1, s = map(int, a[3:8])
im.crop((x0, y0, x1, y1)).resize(((x1 - x0) * s, (y1 - y0) * s), Image.NEAREST).save(a[2])
