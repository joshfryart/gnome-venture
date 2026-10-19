#!/usr/bin/env python3
"""v2.0.0.1: draws the animated Sunflower puzzle picture (a swaying sunflower, drifting clouds, a bee).
Usage: python3 tests/gen_puzzle_sunflower.py game/assets/img/puzzles/sunflower.gif"""
import math, random, sys
from PIL import Image, ImageDraw, ImageFilter

W, H, S, N = 400, 300, 2, 24          # picture size, supersample, frames
w, h = W * S, H * S

def lerp(a, b, t): return a + (b - a) * t
def mix(c1, c2, t): return tuple(int(lerp(c1[i], c2[i], t)) for i in range(3))

def sky():
    im = Image.new('RGB', (w, h))
    d = ImageDraw.Draw(im)
    top, mid, low = (96, 178, 232), (170, 218, 244), (255, 238, 190)
    for y in range(h):
        t = y / (h * 0.62)
        c = mix(top, mid, min(t, 1)) if t <= 1 else mix(mid, low, min((t - 1) / 0.6, 1))
        d.line([(0, y), (w, y)], fill=c)
    # soft sun glow
    g = Image.new('RGB', (w, h), (0, 0, 0)); gd = ImageDraw.Draw(g)
    for r in range(220 * S // 2, 0, -6):
        k = int(70 * (1 - r / (110 * S)))
        gd.ellipse([70 * S - r, 55 * S - r, 70 * S + r, 55 * S + r], fill=(k, k * 9 // 10, k // 3))
    g = g.filter(ImageFilter.GaussianBlur(10))
    from PIL import ImageChops
    im = ImageChops.add(im, g)
    d = ImageDraw.Draw(im)
    d.ellipse([58 * S, 43 * S, 82 * S, 67 * S], fill=(255, 247, 200))
    return im

def hills(d):
    layers = [(190, (126, 190, 120), 0.9, 0.0), (214, (92, 160, 92), 1.3, 1.7), (238, (64, 128, 70), 1.7, 3.1)]
    for base, col, f, ph in layers:
        pts = [(0, h)]
        for x in range(0, w + 8, 8):
            pts.append((x, (base + 14 * math.sin(x / (w / (3.2 * f)) + ph)) * S))
        pts.append((w, h)); d.polygon(pts, fill=col)

def cloud(d, cx, cy, sc):
    for dx, dy, r in [(-26, 4, 13), (-10, -6, 17), (10, -8, 19), (28, 2, 14), (0, 6, 16)]:
        x, y, rr = cx + dx * sc, cy + dy * sc, r * sc
        d.ellipse([(x - rr) * S, (y - rr) * S, (x + rr) * S, (y + rr) * S], fill=(255, 255, 255))

def grass(d, rng):
    for _ in range(170):
        x = rng.uniform(0, W); y0 = rng.uniform(244, 300); ln = rng.uniform(8, 20)
        c = mix((40, 104, 52), (90, 168, 76), rng.random())
        d.line([(x * S, y0 * S), ((x + rng.uniform(-4, 4)) * S, (y0 - ln) * S)], fill=c, width=2 * S // 2 + 1)

def small_flowers(d, rng, t):
    for i in range(14):
        x = 14 + i * 28 + rng.uniform(-8, 8); y = rng.uniform(252, 292)
        sw = math.sin(t * 2 * math.pi + i) * 1.2
        col = [(255, 255, 255), (255, 214, 64), (250, 120, 160), (200, 150, 255)][i % 4]
        d.line([(x * S, (y + 10) * S), ((x + sw) * S, y * S)], fill=(52, 120, 60), width=S)
        for k in range(5):
            a = k * 2 * math.pi / 5
            px, py = x + sw + math.cos(a) * 3.2, y + math.sin(a) * 3.2
            d.ellipse([(px - 2.2) * S, (py - 2.2) * S, (px + 2.2) * S, (py + 2.2) * S], fill=col)
        d.ellipse([(x + sw - 1.6) * S, (y - 1.6) * S, (x + sw + 1.6) * S, (y + 1.6) * S], fill=(240, 170, 30))

def leaf(d, base, tip, width, col, edge):
    (bx, by), (tx, ty) = base, tip
    mx, my = (bx + tx) / 2, (by + ty) / 2
    dx, dy = tx - bx, ty - by; L = math.hypot(dx, dy) or 1
    nx, ny = -dy / L, dx / L
    pts = []
    for i in range(0, 21):
        t = i / 20; s = math.sin(t * math.pi) * width
        pts.append((bx + dx * t + nx * s, by + dy * t + ny * s))
    for i in range(20, -1, -1):
        t = i / 20; s = math.sin(t * math.pi) * width
        pts.append((bx + dx * t - nx * s * 0.8, by + dy * t - ny * s * 0.8))
    d.polygon([(x * S, y * S) for x, y in pts], fill=col, outline=edge)
    d.line([(bx * S, by * S), (tx * S, ty * S)], fill=edge, width=S)

def sunflower(d, t, bee_t):
    sway = math.sin(t * 2 * math.pi)
    base = (214, 306)
    head = (214 + sway * 9, 128 + math.sin(t * 4 * math.pi) * 1.2)
    ctrl = (214 - sway * 5 + 6, 215)
    # stem (quadratic bezier, thick)
    pts = []
    for i in range(41):
        u = i / 40
        x = (1 - u) ** 2 * base[0] + 2 * (1 - u) * u * ctrl[0] + u * u * head[0]
        y = (1 - u) ** 2 * base[1] + 2 * (1 - u) * u * ctrl[1] + u * u * head[1]
        pts.append((x, y))
    def at(u):
        x = (1 - u) ** 2 * base[0] + 2 * (1 - u) * u * ctrl[0] + u * u * head[0]
        y = (1 - u) ** 2 * base[1] + 2 * (1 - u) * u * ctrl[1] + u * u * head[1]
        return (x, y)
    # leaves ride the stem
    lx, ly = at(0.30); leaf(d, (lx, ly), (lx - 62 - sway * 4, ly - 22 + sway * 3), 15, (70, 150, 70), (36, 98, 48))
    lx, ly = at(0.50); leaf(d, (lx, ly), (lx + 58 + sway * 4, ly - 26 - sway * 2), 14, (84, 166, 80), (36, 98, 48))
    lx, ly = at(0.15); leaf(d, (lx, ly), (lx + 46, ly - 8 + sway * 2), 11, (60, 136, 64), (36, 98, 48))
    d.line([(x * S, y * S) for x, y in pts], fill=(48, 118, 56), width=7 * S)
    d.line([((x - 1.4) * S, y * S) for x, y in pts], fill=(88, 166, 80), width=2 * S)
    # head
    cx, cy = head
    tilt = sway * 0.10
    R = 50
    for layer, (n, rad, wid, col, edge, off) in enumerate([
            (24, R * 1.0, 11, (236, 160, 20), (186, 110, 10), 0.0),
            (24, R * 0.93, 10.5, (255, 204, 40), (214, 150, 16), math.pi / 24)]):
        for i in range(n):
            a = off + i * 2 * math.pi / n + tilt + math.sin(t * 2 * math.pi + i * 0.7) * 0.025
            tipx, tipy = cx + math.cos(a) * (rad + 18), cy + math.sin(a) * (rad + 18) * 0.97
            bx_, by_ = cx + math.cos(a) * 24, cy + math.sin(a) * 24
            dx, dy = tipx - bx_, tipy - by_; L = math.hypot(dx, dy); nx, ny = -dy / L, dx / L
            poly = []
            for k in range(0, 13):
                u = k / 12; s = math.sin(u * math.pi) ** 0.8 * wid * (1 - 0.25 * u)
                poly.append((bx_ + dx * u + nx * s, by_ + dy * u + ny * s))
            for k in range(12, -1, -1):
                u = k / 12; s = math.sin(u * math.pi) ** 0.8 * wid * (1 - 0.25 * u)
                poly.append((bx_ + dx * u - nx * s, by_ + dy * u - ny * s))
            d.polygon([(x * S, y * S) for x, y in poly], fill=col, outline=edge)
            d.line([(bx_ * S + dx * S * 0.2, by_ * S + dy * S * 0.2), (bx_ * S + dx * S * 0.85, by_ * S + dy * S * 0.85)],
                   fill=mix(col, edge, .6), width=1)
    # centre: dark disc with seed spiral
    d.ellipse([(cx - 27) * S, (cy - 27) * S, (cx + 27) * S, (cy + 27) * S], fill=(92, 52, 20), outline=(58, 30, 10))
    ga = math.pi * (3 - math.sqrt(5))
    for i in range(1, 150):
        r = 2.05 * math.sqrt(i); a = i * ga + tilt
        if r > 25: break
        px, py = cx + math.cos(a) * r, cy + math.sin(a) * r
        k = i / 150
        col = mix((176, 118, 48), (60, 34, 14), k) if i % 2 else mix((130, 80, 30), (44, 24, 10), k)
        rr = 1.5 + 0.3 * (1 - k)
        d.ellipse([(px - rr) * S, (py - rr) * S, (px + rr) * S, (py + rr) * S], fill=col)
    # bee circling the head
    ba = bee_t * 2 * math.pi
    bx, by = cx + 78 * math.cos(ba) - 10, cy - 22 + 36 * math.sin(ba)
    wing = 3 if int(t * N) % 2 else 6
    d.ellipse([(bx - 5) * S, (by - 8 - wing) * S, (bx + 1) * S, (by - 1) * S], fill=(230, 245, 255), outline=(150, 190, 220))
    d.ellipse([(bx - 1) * S, (by - 8 - wing) * S, (bx + 5) * S, (by - 1) * S], fill=(230, 245, 255), outline=(150, 190, 220))
    d.ellipse([(bx - 8) * S, (by - 4.5) * S, (bx + 8) * S, (by + 4.5) * S], fill=(255, 200, 30), outline=(40, 30, 10))
    for sx in (-3, 1.5):
        d.rectangle([(bx + sx) * S, (by - 4) * S, (bx + sx + 2) * S, (by + 4) * S], fill=(30, 22, 8))
    d.ellipse([(bx + 5) * S, (by - 2.5) * S, (bx + 9) * S, (by + 1.5) * S], fill=(30, 22, 8))

def frame(i):
    t = i / N
    im = BG.copy()
    d = ImageDraw.Draw(im)
    for k, (cx0, cy, sc, sp) in enumerate([(60, 38, 1.0, 1), (250, 58, 1.3, 1), (360, 26, .8, 2)]):
        cloud(d, ((cx0 + t * 140 * sp) % (W + 120)) - 60, cy, sc)
    d.bitmap((0, 0), HILLS_MASK, fill=None)
    im.paste(HILLS, (0, 0), HILLS_MASK)
    d = ImageDraw.Draw(im)
    rng = random.Random(7)
    grass(d, rng)
    small_flowers(d, random.Random(11), t)
    sunflower(d, t, (t * 2) % 1)
    return im.resize((W, H), Image.LANCZOS)

BG = sky()
_hl = Image.new('RGB', (w, h), (0, 0, 0)); _hd = ImageDraw.Draw(_hl); hills(_hd)
HILLS = _hl
_m = Image.new('L', (w, h), 0); _md = ImageDraw.Draw(_m)
# mask = wherever the hills drew something (non-black)
HILLS_MASK = _hl.convert('L').point(lambda v: 255 if v > 0 else 0)

if __name__ == '__main__':
    out = sys.argv[1]
    frames = [frame(i) for i in range(N)]
    pal = frames[0].quantize(colors=128, method=Image.MEDIANCUT, dither=Image.NONE)
    q = [f.quantize(palette=pal, dither=Image.NONE) for f in frames]
    q[0].save(out, save_all=True, append_images=q[1:], duration=70, loop=0, optimize=True, disposal=1)
    print(out, len(frames), 'frames')
