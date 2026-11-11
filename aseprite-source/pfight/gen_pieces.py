#!/usr/bin/env python3
"""Real jigsaw-piece silhouettes: knob sticks OUT of the right edge, hole is CUT INTO the left edge.

piece-<hand|strip>-<type>-<holefam>-<knobfam>.png   body, transparent notch and knob (fam: body mind craft flat)
edge-<hand|strip>-<me|foe>-<holefam>-<knobfam>.png  outline overlay that follows the same silhouette

Canvas = tile W + P wide (P = knob depth). The hole is the first P px at the left, the knob the last P px.
When pieces snap together place the next piece at x + W (its hole swallows the previous knob).
Run: python3 gen_pieces.py <out dir>
"""
import math
import os
import sys
from PIL import Image
from gen_pfight import TYPES, INK, CREAM, GOLD, dark_of, light_of, pat

FAMS = ['body', 'mind', 'craft', 'flat']
G = {'hand': dict(W=96, H=68, P=18, R=5, vx=21, vy=3, vw=14, vh=12, mx=53, my=25, mr=19.5),
     'strip': dict(W=56, H=40, P=9, R=3, vx=13, vy=2, vw=12, vh=10, mx=31, my=24, mr=11.5)}


def prof(fam, P, k):
    """half-height per column t=0..P-1, base (wide) at t=0 -> tip at t=P-1"""
    hand = k == 'hand'
    out = []
    for t in range(P):
        x = t + .5
        if fam == 'body':    # classic jigsaw: short neck, big round head
            r = 9.6 if hand else 5.0
            c = P - r
            neck = 6.0 if hand else 3.2
            hh = max(neck if x < c else 0, math.sqrt(max(0, r * r - (x - c) ** 2)))
        elif fam == 'mind':  # keyhole: flared trapezoid base, thin neck, small round head
            r = 6.4 if hand else 3.2
            c = P - r
            neck = 2.4 if hand else 1.2
            top = 14.0 if hand else 7.5
            flare = top - (top - neck) * x / (P * .38)
            hh = max(neck, flare if x < P * .38 else 0, math.sqrt(max(0, r * r - (x - c) ** 2)))
        else:                # craft: triangle with a slightly blunt tip
            A = 15.0 if hand else 8.0
            hh = A * (1 - x / P) + (.9 if hand else .5)
        out.append(hh)
    return out


def mask_for(k, hole, knob):
    g = G[k]
    W, H, P, R = g['W'], g['H'], g['P'], g['R']
    Wc = W + P
    from gen_pfight import in_rr
    m = [[False] * Wc for _ in range(H)]
    for y in range(H):
        for x in range(W):
            m[y][x] = in_rr(x, y, W, H, R)
    cy = H / 2.0
    if hole != 'flat':
        hp = prof(hole, P, k)
        for t in range(P):
            for y in range(H):
                if abs(y + .5 - cy) <= hp[t]:
                    m[y][t] = False
    if knob != 'flat':
        kp = prof(knob, P, k)
        for t in range(P):
            for y in range(H):
                if abs(y + .5 - cy) <= kp[t]:
                    m[y][W + t] = True
    return m, Wc, H


def depth_map(m, Wc, H, lim=6):
    """4-neighbour distance from outside, 0 = outside, 1 = outline ring ..."""
    d = [[0] * Wc for _ in range(H)]
    for lvl in range(1, lim + 1):
        for y in range(H):
            for x in range(Wc):
                if not m[y][x]:
                    continue
                if lvl == 1:
                    nb = [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
                    if any(not (0 <= a < Wc and 0 <= b < H and m[b][a]) for a, b in nb):
                        d[y][x] = 1
                else:
                    if d[y][x] == 0 and any(0 <= a < Wc and 0 <= b < H and d[b][a] == lvl - 1
                                            for a, b in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1))):
                        d[y][x] = lvl
    for y in range(H):
        for x in range(Wc):
            if m[y][x] and d[y][x] == 0:
                d[y][x] = lim + 1
    return d


def piece(t, k, hole, knob):
    g = G[k]
    m, Wc, H = mask_for(k, hole, knob)
    d = depth_map(m, Wc, H)
    base = TYPES[t]
    dk, lt = dark_of(base), light_of(base)
    im = Image.new('RGBA', (Wc, H), (0, 0, 0, 0))
    px = im.load()
    pm = {'d': dk, 'l': lt, 'g': CREAM, 'y': GOLD}
    for y in range(H):
        for x in range(Wc):
            if not m[y][x]:
                continue
            dd = d[y][x]
            if dd == 1:
                c = INK
            elif dd == 2:
                up_left = (not m[y][x - 1] if x > 0 else True) or (not m[y - 1][x] if y > 0 else True) or d[y][x - 1] == 1 or d[y - 1][x] == 1
                c = lt if up_left else dk if (d[y][x + 1] == 1 or d[y + 1][x] == 1) else base
                if c is base:
                    code = pat(t, x, y, k)
                    c = pm[code] if code else base
            else:
                code = pat(t, x, y, k)
                c = pm[code] if code else base
            if t == 'item' and dd == 4 and (x + y) % 3 < 2:
                c = CREAM
            px[x, y] = c + (255,)
    # medallion + value plate (same places as the legacy tiles)
    mx, my, mr = g['mx'], g['my'], g['mr']
    for y in range(H):
        for x in range(Wc):
            dd2 = (x + .5 - mx) ** 2 + (y + .5 - my) ** 2
            if dd2 <= mr * mr and m[y][x]:
                px[x, y] = (INK if dd2 > (mr - 1.15) ** 2 else CREAM) + (255,)
    if k == 'hand':
        n = 0
        for a in range(0, 360, 6):
            n += 1
            if n % 3 == 0:
                continue
            px_, py_ = int(mx + (mr - 2.6) * math.cos(math.radians(a))), int(my + (mr - 2.6) * math.sin(math.radians(a)))
            px[px_, py_] = GOLD + (255,)
    from gen_pfight import in_rr
    vx, vy, vw, vh = g['vx'], g['vy'], g['vw'], g['vh']
    for y in range(vh):
        for x in range(vw):
            if not in_rr(x, y, vw, vh, 2):
                continue
            edge = not all(in_rr(x + a, y + b, vw, vh, 2) for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            px[vx + x, vy + y] = (CREAM if edge else INK) + (255,)
    return im


def edge(k, style, hole, knob):
    g = G[k]
    m, Wc, H = mask_for(k, hole, knob)
    d = depth_map(m, Wc, H)
    im = Image.new('RGBA', (Wc, H), (0, 0, 0, 0))
    px = im.load()
    hand = k == 'hand'
    per = 10 if hand else 7
    for y in range(H):
        for x in range(Wc):
            dd = d[y][x]
            if not m[y][x]:
                continue
            if style == 'me':   # ink line, cream line, gold stitches
                if dd == 1:
                    px[x, y] = INK + (255,)
                elif dd == 2:
                    px[x, y] = CREAM + (255,)
                elif dd == 3 and (x + y) % 3 < 2:
                    px[x, y] = GOLD + (255,)
            else:               # foe: dark thorns biting inward along the whole contour
                s = (x + y) % per
                tri = min(s, per - 1 - s)            # 0..per/2-1 triangle wave
                reach = 2 + tri // 2
                if dd == 1 or dd == 2 or dd <= reach:
                    px[x, y] = INK + (255,)
                if dd == reach and reach >= 4 and dd > 2:
                    px[x, y] = (150, 52, 28, 255)
    return im


def build(out):
    os.makedirs(out, exist_ok=True)
    n = 0
    for k in ('hand', 'strip'):
        for hole in FAMS:
            for knob in FAMS:
                for t in TYPES:
                    piece(t, k, hole, knob).save(os.path.join(out, f'piece-{k}-{t}-{hole}-{knob}.png'))
                    n += 1
                for st in ('me', 'foe'):
                    edge(k, st, hole, knob).save(os.path.join(out, f'edge-{k}-{st}-{hole}-{knob}.png'))
                    n += 1
    return n


if __name__ == '__main__':
    print(build(sys.argv[1]), 'files')
