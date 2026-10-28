#!/usr/bin/env python3
"""Dark-mode variant of a Stitched Toy PNG: black border -> cream halo, fills a touch dimmer/cooler.
usage: darken.py in.png out-dark.png"""
import sys
from PIL import Image
im = Image.open(sys.argv[1]).convert('RGBA'); px = im.load()
for y in range(im.height):
    for x in range(im.width):
        r, g, b, a = px[x, y]
        if a == 0: continue
        px[x, y] = (0xf2, 0xe4, 0xc0, 255) if (r, g, b) == (0, 0, 0) else (int(r*.88), int(g*.9), min(255, int(b*.95)+6), 255)
im.save(sys.argv[2])
