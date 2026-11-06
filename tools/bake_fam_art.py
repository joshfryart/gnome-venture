#!/usr/bin/env python3
"""Bake the joinable small placeables (Hearth Pop v3): stepping stones, log seats, toadstool rings and flower pots.
Writes game/assets/img/fam/<family>-<set>-<code>[<turn>].png (64x64, transparent), family: steps | logs | toads | pots, set: b (big) | s (small) | m (mixed):
  runs    e end (arm east) | s straight (east-west) | a angle (east+south) | u curve (east+south) | t tee (west+east+south) | x cross, each drawn 4 times, <turn> 0-3 quarter turns clockwise
          (the arrangement turns, the stones, logs, mushrooms and pots stay upright); 1 single cluster (no turn)
  pieces  pc centred | pnw | pne | psw | pse in a corner; set b = one large piece, s = one small piece (set m is drawn like s)
The pieces of neighbouring squares line up across the edges.
Run: python3 -I tools/bake_fam_art.py   (needs Pillow)"""
import math, os, sys
from PIL import Image, ImageDraw
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bake_path_art import hsh
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__))); OUT = os.path.join(REPO, "game", "assets", "img", "fam")
T = 64; OUTL = (0x2b, 0x1c, 0x26, 255)
def rgb(c): return tuple(c) + (255,)
def scale_pts(pts, cx, cy, k, ox=0, oy=0): return [(cx + (x - cx) * k + ox, cy + (y - cy) * k + oy) for x, y in pts]
# ---------- painters: each draws one object centred on (cx, cy) with size r ----------
STONE = [((0x6e,0x6d,0x82),(0x8e,0x8d,0xa2),(0xaa,0xa9,0xb8),(0xd4,0xd3,0xe0)),
         ((0x8a,0x76,0x56),(0xa8,0x94,0x6e),(0xc8,0xb4,0x8a),(0xe6,0xd6,0xb0)),
         ((0x5e,0x6e,0x90),(0x78,0x8a,0xaa),(0x8e,0xa0,0xc0),(0xb4,0xc4,0xe0)),
         ((0x68,0x76,0x5c),(0x80,0x90,0x72),(0x9a,0xa8,0x8a),(0xc0,0xcc,0xaa))]
def stone(im, cx, cy, r, i, seed):
    d = ImageDraw.Draw(im); tone = STONE[int(hsh(i, seed, 6) * 4)]
    n = 9 if r >= 6 else 7; a0 = hsh(i, seed, 7) * 6.28; flat = .7 + hsh(i, seed, 8) * .12
    pts = []
    for k in range(n):
        a = a0 + 6.2832 * k / n; rr = r * (.8 + .32 * hsh(k, i * 13 + seed, 9)); pts.append((cx + math.cos(a) * rr, cy + math.sin(a) * rr * flat))
    d.polygon(scale_pts(pts, cx, cy, 1, 1, 3), fill=(0, 0, 0, 62))                                   # ground shadow
    d.polygon(scale_pts(pts, cx, cy, 1.0), fill=OUTL, outline=OUTL)
    d.polygon(scale_pts(pts, cx, cy, .86), fill=rgb(tone[0]))                                          # shaded body
    d.polygon(scale_pts(pts, cx, cy, .8, -.8, -.9), fill=rgb(tone[1]))
    d.polygon(scale_pts(pts, cx, cy, .62, -r * .12, -r * .16), fill=rgb(tone[2]))                      # lit face
    if r >= 5:
        d.polygon(scale_pts(pts, cx, cy, .3, -r * .24, -r * .3), fill=rgb(tone[3]))                    # glint
        if hsh(i, seed, 10) > .5:                                                                       # a hairline crack
            x, y = int(cx + r * .1), int(cy - r * .2)
            for k in range(r // 2 + 1): d.point((x + k, y + k // 2 + (k % 2)), fill=rgb(tone[0]))
    if hsh(i, seed, 11) > .55:                                                                          # moss on the shaded side
        for dx, dy, c in ((-1, 0, '#3f7a3e'), (0, 0, '#5a9a48'), (1, 0, '#76b455'), (0, -1, '#76b455')):
            d.point((int(cx - r * .55 + dx), int(cy + r * .3 + dy)), fill=c)
    if hsh(i, seed, 12) > .5:                                                                           # a blade of grass at the foot
        x, y = int(cx + r * .5), int(cy + r * flat * .8)
        d.point((x, y), fill='#3f7a3e'); d.point((x, y - 1), fill='#5a9a48'); d.point((x + 1, y - 2), fill='#97cc66')
WOOD = ((0x5a,0x38,0x22),(0x8a,0x56,0x30),(0xc4,0x92,0x58),(0xe0,0xb8,0x78))
def stump(im, cx, cy, r, i, seed):
    d = ImageDraw.Draw(im); ry = max(2, int(r * .62)); h = max(3, int(r * .55))
    d.ellipse([cx - r + 1, cy - ry + h + 2, cx + r + 1, cy + ry + h + 3], fill=(0, 0, 0, 62))
    d.rectangle([cx - r - 1, cy - 1, cx + r + 1, cy + h], fill=OUTL); d.ellipse([cx - r - 1, cy + h - ry - 1, cx + r + 1, cy + h + ry + 1], fill=OUTL)
    d.rectangle([cx - r, cy, cx + r, cy + h], fill=rgb(WOOD[0])); d.ellipse([cx - r, cy + h - ry, cx + r, cy + h + ry], fill=rgb(WOOD[0]))
    for k in range(-r + 1, r, 3): d.line([(cx + k, cy + 1), (cx + k, cy + h)], fill=rgb(WOOD[1]))          # bark
    d.ellipse([cx - r - 1, cy - ry - 1, cx + r + 1, cy + ry + 1], fill=OUTL); d.ellipse([cx - r, cy - ry, cx + r, cy + ry], fill=rgb(WOOD[2]))
    for k, c in ((.66, WOOD[1]), (.4, WOOD[3]), (.18, WOOD[1])):
        if r * k >= 1: d.ellipse([cx - r * k, cy - ry * k, cx + r * k, cy + ry * k], outline=rgb(c))
TOAD = ((0x7a,0x1c,0x1c),(0xc8,0x36,0x2a),(0xe8,0x5a,0x44),(0xf7,0xf0,0xe6))
def toad(im, cx, cy, r, i, seed):
    d = ImageDraw.Draw(im); sh = max(3, int(r * .9)); sw = max(1, r // 3)
    d.ellipse([cx - r + 1, cy + sh + 1, cx + r + 1, cy + sh + 4], fill=(0, 0, 0, 62))
    d.rectangle([cx - sw - 1, cy, cx + sw + 1, cy + sh + 1], fill=OUTL); d.rectangle([cx - sw, cy, cx + sw, cy + sh], fill='#e8e0d0'); d.line([(cx + sw, cy), (cx + sw, cy + sh)], fill='#b8ae98')
    top = cy - int(r * .55)
    d.pieslice([cx - r - 1, top - r - 1, cx + r + 1, top + r + 1], 180, 360, fill=OUTL); d.chord([cx - r - 1, top - 3, cx + r + 1, top + 3], 0, 180, fill=OUTL)
    d.pieslice([cx - r, top - r, cx + r, top + r], 180, 360, fill=rgb(TOAD[1])); d.chord([cx - r, top - 2, cx + r, top + 2], 0, 180, fill=rgb(TOAD[0]))
    d.pieslice([cx - r + 1, top - r + 1, cx + r - 4, top + r - 4], 190, 290, fill=rgb(TOAD[2]))
    for k, (dx, dy) in enumerate(((-r // 2, -r // 2), (r // 4, -r // 2 - 1), (-1, -r // 4), (r // 2, -r // 5))):
        if r >= 5 or k < 2: d.point((cx + dx, top + dy), fill=rgb(TOAD[3]))
        if r >= 7: d.point((cx + dx + 1, top + dy), fill=rgb(TOAD[3]))
POT = ((0x7a,0x3a,0x22),(0xb8,0x5a,0x34),(0xd8,0x7a,0x48),(0xf0,0xa0,0x68))
def pot(im, cx, cy, r, i, seed):
    d = ImageDraw.Draw(im); h = r + 1; top = cy - 1
    d.ellipse([cx - r + 1, cy + h - 1, cx + r + 3, cy + h + 3], fill=(0, 0, 0, 62))
    body = [(cx - r, top), (cx + r, top), (cx + r - 2, cy + h), (cx - r + 2, cy + h)]
    d.polygon([(x + dx, y + dy) for (x, y), (dx, dy) in zip(body, ((-1, -1), (1, -1), (1, 1), (-1, 1)))], fill=OUTL)
    d.polygon(body, fill=rgb(POT[1])); d.polygon([(cx - r + 1, top + 1), (cx - r // 3, top + 1), (cx - r // 3 + 1, cy + h - 1), (cx - r + 3, cy + h - 1)], fill=rgb(POT[2]))
    d.rectangle([cx - r - 1, top - 2, cx + r + 1, top + 1], fill=OUTL); d.rectangle([cx - r, top - 1, cx + r, top], fill=rgb(POT[2]))
    lc = ['#2f6a3c', '#3f7a3e', '#5a9a48', '#97cc66']; kind = int(hsh(i, seed, 20) * 3)
    for k, (dx, dy) in enumerate(((-r, -r - 1), (-r // 2, -r - 3), (0, -r - 4), (r // 2, -r - 3), (r, -r - 1))):
        d.line([(cx + dx // 3, top - 1), (cx + dx, top + dy)], fill=lc[1 + k % 2], width=2); d.point((cx + dx, top + dy - 1), fill=lc[3])
    if kind == 0:
        for k, c in zip((-1, 1), ('#e8809a', '#f0d067')): d.ellipse([cx + k * (r // 2 + 1) - 2, top - r - 6, cx + k * (r // 2 + 1) + 1, top - r - 3], fill=c, outline=OUTL)
    elif kind == 1: d.ellipse([cx - 2, top - r - 7, cx + 2, top - r - 3], fill='#b9a0e0', outline=OUTL); d.point((cx, top - r - 5), fill='#f7f0e6')
PAINT = {'stone': stone, 'stump': stump, 'toad': toad, 'pot': pot}
SIZES = {'stone': {'big': (8, 11), 'small': (4, 6), 'mixed': (6, 11)}, 'stump': {'big': (8, 10), 'small': (5, 6), 'mixed': (5, 9)},
         'toad': {'big': (7, 9), 'small': (4, 5), 'mixed': (4, 8)}, 'pot': {'big': (7, 8), 'small': (4, 5), 'mixed': (4, 8)}}
DIRS = {'N': (0, -1), 'E': (1, 0), 'S': (0, 1), 'W': (-1, 0)}
def arm_pts(a, dists): dx, dy = DIRS[a]; return [(32 + dx * d, 32 + dy * d) for d in dists]
def arc_pts(a, b, n):
    cxy = {frozenset('NE'): (64, 0), frozenset('SE'): (64, 64), frozenset('SW'): (0, 64), frozenset('NW'): (0, 0)}[frozenset((a, b))]
    ends = {'N': (32, 0), 'E': (64, 32), 'S': (32, 64), 'W': (0, 32)}
    a0 = math.atan2(ends[a][1] - cxy[1], ends[a][0] - cxy[0]); a1 = math.atan2(ends[b][1] - cxy[1], ends[b][0] - cxy[0])
    da = (a1 - a0 + math.pi) % (2 * math.pi) - math.pi
    return [(cxy[0] + 32 * math.cos(a0 + da * t), cxy[1] + 32 * math.sin(a0 + da * t)) for t in [(i + .5) / n for i in range(n)]]
def tile(kind, style, shape, arms, seed=1):
    im = Image.new('RGBA', (T, T), (0, 0, 0, 0)); lo, hi = SIZES[kind][style]
    spaced = kind in ('pot', 'toad')           # fewer, bigger gaps for pots and mushrooms
    dists = (17, 33) if spaced else (13, 26); n = 3 if spaced else 4
    pts = []
    if shape == 'single': pts = [(32, 34, 1), (22, 24, 0), (43, 43, 0)] if not spaced else [(32, 34, 1)]
    elif shape == 'curve': pts = [(p[0], p[1], 0) for p in arc_pts(arms[0], arms[1], 3 if spaced else n)]
    else:
        if shape != 'end': pts.append((32, 32, 1))
        for a in arms: pts += [(p[0], p[1], 0) for p in arm_pts(a, dists[:1] if spaced else dists)]
        if shape == 'end': pts.append((32, 32, 1))
    out = []
    for i, (x, y, big) in enumerate(pts):
        r = hi if big else (lo + int(hsh(i, seed, 5) * (hi - lo + 1)) if style != 'mixed' else (lo if i % 2 else hi))
        if style == 'big' and not big: r = hi - int(hsh(i, seed, 5) * 2)
        out.append((y + (hsh(i, seed, 4) - .5) * 3, x + (hsh(i, seed, 3) - .5) * 3, r, i))
    for y, x, r, i in sorted(out): PAINT[kind](im, int(x), int(y), max(2, r), i, seed)
    return im
POS = {'centre': (32, 34), 'NW': (17, 19), 'NE': (47, 19), 'SW': (17, 47), 'SE': (47, 47)}
def ones(kind, items, seed=3):
    """items: [(position, 'small' | 'large')] -> one tile"""
    im = Image.new('RGBA', (T, T), (0, 0, 0, 0)); lo, hi = SIZES[kind]['mixed']; out = []
    for i, (pos, size) in enumerate(items):
        x, y = POS[pos]; r = hi if size == 'large' else lo
        if pos != 'centre' and size == 'large': r = min(r, 9)
        out.append((y, x, r, i + seed))
    for y, x, r, i in sorted(out): PAINT[kind](im, x, y, max(2, r), i, seed)
    return im

FAMS = {"steps": "stone", "logs": "stump", "toads": "toad", "pots": "pot"}
RUNS = {"e": "end", "s": "straight", "a": "angle", "u": "curve", "t": "tee", "x": "cross", "1": "single"}
ARMS = {"end": ["E"], "straight": ["E", "W"], "angle": ["E", "S"], "curve": ["E", "S"], "tee": ["W", "E", "S"], "cross": ["N", "E", "S", "W"], "single": None}
STYLE = {"b": "big", "s": "small", "m": "mixed"}
TURN = {"E": "S", "S": "W", "W": "N", "N": "E"}
def main():
    os.makedirs(OUT, exist_ok=True); n = 0
    for fam, kind in FAMS.items():
        for sc, sname in STYLE.items():
            for code, shape in RUNS.items():
                if code == "1": tile(kind, sname, shape, None, 1 + n % 7).save(os.path.join(OUT, f"{fam}-{sc}-{code}.png"), optimize=True); n += 1; continue
                arms = ARMS[shape]
                for q in range(4):
                    tile(kind, sname, shape, arms, 1 + (n // 4) % 7).save(os.path.join(OUT, f"{fam}-{sc}-{code}{q}.png"), optimize=True); n += 1
                    arms = [TURN[a] for a in arms]
        for pos in ("c", "nw", "ne", "sw", "se"):
            for sc, size in (("b", "large"), ("s", "small"), ("m", "small")):
                ones(kind, [({"c": "centre"}.get(pos, pos.upper()), size)], 2 + n % 5).save(os.path.join(OUT, f"{fam}-{sc}-p{pos}.png"), optimize=True); n += 1
    print(n, "files in", OUT)
if __name__ == "__main__": main()
