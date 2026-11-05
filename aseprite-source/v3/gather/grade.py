#!/usr/bin/env python3
"""Time-of-day grade for gather art. Per-pixel colour map only (hard pixels stay hard, alpha untouched).
usage: grade.py <in.png> <out-dusk.png> <out-night.png>   (either out may be '-')"""
import sys, colorsys
from PIL import Image

def mixc(a, b, t): return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))

def clamp(t): return tuple(max(0, min(255, int(round(c * 255)))) for c in t)

def curve(t, k): return tuple((c - 0.5) * k + 0.5 for c in t)

def dusk(rgb):
    r, g, b = [c / 255 for c in rgb]
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    s = min(1, s * 1.12 + 0.06)
    v = v * 0.84
    t = colorsys.hsv_to_rgb(h, s, v)
    t = mixc(t, (0.34, 0.2, 0.5), max(0, 1 - v * 2.0) * 0.5)       # violet shadows
    t = (t[0] * 1.2, t[1] * 0.84, t[2] * 0.68)                       # low orange sun
    if v > 0.72: t = mixc(t, (1.0, 0.78, 0.5), 0.18)                  # warm highlights
    return clamp(curve(t, 1.12))

def night(rgb):
    r, g, b = [c / 255 for c in rgb]
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    s = min(1, s * 1.0 + 0.04)
    v2 = v * 0.44 + 0.04
    t = colorsys.hsv_to_rgb(h, s, v2)
    t = mixc(t, (0.1, 0.14, 0.56), 0.36)
    t = (t[0] * 0.8, t[1] * 0.92, t[2] * 1.3)
    if v > 0.8: t = mixc(t, (0.7, 0.82, 1.0), 0.32)                   # moonlit highlights
    return clamp(curve(t, 1.18))

def apply(src, fn, dst):
    im = Image.open(src).convert('RGBA')
    px = im.load()
    cache = {}
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a == 0: continue
            k = (r, g, b)
            if k not in cache: cache[k] = fn(k)
            px[x, y] = cache[k] + (a,)
    im.save(dst)

if __name__ == '__main__':
    src, d_out, n_out = sys.argv[1:4]
    if d_out != '-': apply(src, dusk, d_out)
    if n_out != '-': apply(src, night, n_out)
