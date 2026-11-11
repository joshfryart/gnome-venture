#!/usr/bin/env python3
"""Named combo stamps (6 x 32x32), boss crown (12x12) and open-end socket marker (24x24), felt style, HARD PIXELS ONLY.
Run: python3 gen_combo.py [out dir]   (default: game/assets/img/pfight/)
Writes combo-ambush.png combo-riposte.png combo-double-swing.png combo-calm-charm.png combo-win-over.png combo-bait.png
crown-boss.png open-end.png.

Colour-blind cue: every stamp has its OWN outer silhouette + its own motif; colour (the two types' hues) is only an accent.
  ambush       diamond   trick yellow  -> domino mask over three orange claw rips         (trick then hurt)
  riposte      shield    guard blue    -> orange U-turn arrow bouncing off a cream spark  (guard then hurt)
  double-swing burst     hurt orange   -> two crossed cream slashes                       (hurt then hurt)
  calm-charm   cloud     soothe blue   -> pink flower resting on the cloud, sleepy wisps  (soothe then charm)
  win-over     heart     charm pink    -> cream heart, green heal pluses at the lobes      (charm then heal)
  bait         tag       item amber    -> wrapped trick-yellow candy on a fishing hook    (item then trick)
Build: shape mask -> type fill, 1 px light top / shade bottom, running stitch inset 2 px -> motif (own ink outline)
-> 1 px ink outline (4-nbr) -> 1 px cream halo (8-nbr), same finish as the ico-*.png type icons."""
import math
import os
import sys
import numpy as np
from PIL import Image, ImageDraw
import base_icons as B

INK, CREAM, GOLD = B.INK, B.CREAM, B.GOLD
CD = B.CREAM_D
hx = B.hx
TY = B.TYPES
WHITE = hx('#fff8e6')
LGOLD = hx('#f8c552')
DGOLD = hx('#a05c08')
GREEN, DGREEN = hx('#8ed04a'), hx('#3f7d1e')
HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_OUT = os.path.normpath(os.path.join(HERE, '../../../../game/assets/img/pfight'))
S = 32


# ---------------------------------------------------------------- mask helpers
def grid(f, s=S):
    return np.array([[bool(f(x, y)) for x in range(s)] for y in range(s)])


def poly_mask(pts, s=S):
    im = Image.new('L', (s, s), 0)
    ImageDraw.Draw(im).polygon(pts, fill=255)
    return np.array(im) > 0


def ell_mask(x0, y0, x1, y1, s=S):
    im = Image.new('L', (s, s), 0)
    ImageDraw.Draw(im).ellipse([x0, y0, x1, y1], fill=255)
    return np.array(im) > 0


def nb4(m):
    p = np.pad(m, 1)
    return p[:-2, 1:-1] | p[2:, 1:-1] | p[1:-1, :-2] | p[1:-1, 2:]


def nb8(m):
    p = np.pad(m, 1)
    return nb4(m) | p[:-2, :-2] | p[:-2, 2:] | p[2:, :-2] | p[2:, 2:]


def erode(m):
    p = np.pad(m, 1)
    return m & p[:-2, 1:-1] & p[2:, 1:-1] & p[1:-1, :-2] & p[1:-1, 2:]


def put(a, m, col):
    a[m] = col + (255,)


def pix(a, rows, x0, y0, pal):
    """paint a pixel string; '.' = skip."""
    for j, r in enumerate(rows):
        for i, ch in enumerate(r):
            if ch in pal:
                a[y0 + j, x0 + i] = pal[ch] + (255,)


def outlined(a, layer):
    """composite an RGBA motif layer onto a with its own 1 px 4-nbr ink outline."""
    m = layer[..., 3] > 0
    a[nb4(m) & ~m] = INK + (255,)
    a[m] = layer[m]


def layer():
    return np.zeros((S, S, 4), np.uint8)


# ---------------------------------------------------------------- badge base
def badge(mask, base, light, shade, stitch, dash=(2, 2)):
    """felt badge: fill, top light row, bottom shade row, running stitch 2 px inside the edge."""
    a = np.zeros((S, S, 4), np.uint8)
    put(a, mask, base)
    up = np.pad(mask, 1)[:-2, 1:-1]          # pixel above is inside
    dn = np.pad(mask, 1)[2:, 1:-1]
    put(a, mask & ~up, light)
    put(a, mask & ~dn, shade)
    e1 = erode(mask)
    put(a, e1 & ~np.pad(e1, 1)[2:, 1:-1], shade)   # 2 px felt shade at the bottom
    ring_in = erode(erode(mask))
    ring = ring_in & ~erode(ring_in)
    pts = list(zip(*np.nonzero(ring)))       # (y, x)
    cy, cx = np.mean([p[0] for p in pts]), np.mean([p[1] for p in pts])
    pts.sort(key=lambda p: math.atan2(p[0] - cy, p[1] - cx))
    on, off = dash
    for i, (y, x) in enumerate(pts):
        if i % (on + off) < on:
            a[y, x] = stitch + (255,)
    return a


def finish(a, mask_extra=None):
    m = a[..., 3] > 0
    o = nb4(m) & ~m
    a[o] = INK + (255,)
    m = a[..., 3] > 0
    h = nb8(m) & ~m
    a[h] = CREAM + (255,)
    return Image.fromarray(a)


# ---------------------------------------------------------------- the six stamps
def ambush():
    """diamond, trick yellow; three long orange claw rips slash diagonally behind a dark domino mask whose eyes glance sideways."""
    t, h = TY['trick'], TY['hurt']
    m = grid(lambda x, y: abs(x - 15.5) + abs(y - 15.5) <= 13.6)
    a = badge(m, t['base'], t['light'], t['shade'], DGOLD, (2, 2))
    L = layer()
    inner = erode(erode(erode(m)))
    for ox in (-5, 0, 5):                    # rips run top-right -> bottom-left, fat in the middle
        for k in range(-8, 9):
            y = 15 + k
            x = 15 + ox - k // 2
            if not inner[y, x]:
                continue
            L[y, x] = h['base'] + (255,)
            if abs(k) < 6 and inner[y, x + 1]:
                L[y, x + 1] = h['light'] + (255,)
    outlined(a, L)
    L = layer()
    mk, md = hx('#4a2a6c'), hx('#2f1a48')
    pix(L, [
        "mm..........mm",
        "mmmm......mmmm",
        "mmmmmmmmmmmmmm",
        "mwwwpmmmmwwwpm",
        "mmwwpmddmmwwpm",
        ".mmmmd..dmmmm.",
    ], 9, 12, {'m': mk, 'd': md, 'w': WHITE, 'p': INK})
    outlined(a, L)
    return finish(a)


def riposte():
    """heater shield, guard blue; an orange arrow comes in, bends round a cream parry spark and goes back up."""
    g, h = TY['guard'], TY['hurt']
    m = poly_mask([(4, 4), (11, 2), (15.5, 3.5), (20, 2), (27, 4), (27, 15), (24, 22), (15.5, 29), (7, 22), (4, 15)])
    a = badge(m, g['base'], g['light'], g['shade'], CREAM, (2, 2))
    L = layer()
    o, ol = h['base'], h['light']
    # U-turn arrow: shaft down on the left, round the bottom, back up on the right with a head
    pix(L, [
        ".........aa.....",
        "........aaaa....",
        ".......aaaaaa...",
        "......aaaaaaaa..",
        "oo.......oo.....",
        "oo.......oo.....",
        "oo.......oo.....",
        "oo.......oo.....",
        "oo.......oo.....",
        "loo.....ool.....",
        ".looo.oool......",
        "..lloooll.......",
        "....lll.........",
    ], 9, 6, {'o': o, 'l': ol, 'a': o})
    outlined(a, L)
    L = layer()
    # cream parry spark where the blow is turned (centre, inside the U)
    pix(L, [
        "..w..",
        ".www.",
        "wwgww",
        ".www.",
        "..w..",
    ], 11, 10, {'w': WHITE, 'g': GOLD})
    outlined(a, L)
    return finish(a)


def double_swing():
    """12-point starburst, hurt orange; two crossed cream slash streaks (an X of blows)."""
    h = TY['hurt']
    pts = []
    for i in range(24):
        r = 13.9 if i % 2 == 0 else 10.2
        ang = -math.pi / 2 + i * math.pi / 12
        pts.append((15.5 + r * math.cos(ang), 15.5 + r * math.sin(ang)))
    m = poly_mask(pts)
    a = badge(m, h['base'], h['light'], h['shade'], LGOLD, (2, 2))
    L = layer()
    # slash 1: top-left to bottom-right, fat in the middle; slash 2 mirrored
    for k in range(-8, 9):
        w = 1 if abs(k) > 5 else 2
        x, y = 15 + k, 15 + k
        for d in range(w):
            L[y, x + d] = WHITE + (255,)
            L[y, 31 - (x + d)] = WHITE + (255,)
    # light-gold edge on one side of each streak (felt shade)
    for k in range(-4, 5):
        x, y = 15 + k, 15 + k
        L[y + 1, x] = LGOLD + (255,)
        L[y + 1, 31 - x] = LGOLD + (255,)
    outlined(a, L)
    # speed ticks at the outer ends
    return finish(a)


def calm_charm():
    """puffy cloud, soothe blue; a pink five-petal flower resting on it, two sleepy wisps."""
    s, c = TY['soothe'], TY['charm']
    m = (ell_mask(3, 11, 14, 23) | ell_mask(8, 5, 22, 19) | ell_mask(17, 9, 28, 21) | ell_mask(22, 14, 29, 24)
         | poly_mask([(6, 17), (26, 17), (26, 24), (6, 24)]))
    a = badge(m, s['base'], s['light'], s['shade'], WHITE, (2, 2))
    L = layer()
    pt, pd = c['light'], c['base']
    pix(L, [
        "....ppp....",
        "...ppppp...",
        ".pp.ppp.pp.",
        "pppp.d.pppp",
        "ppppdyydppp",
        ".ppdyyyydp.",
        "...dyyyyd..",
        "..pp.dd.pp.",
        ".pppp..pppp",
        "..ppp..ppp.",
    ], 10, 7, {'p': pt, 'd': pd, 'y': GOLD})
    outlined(a, L)
    sh = s['shade']
    pix(a, ["ss..", "..ss"], 5, 19, {'s': sh})
    pix(a, ["ss..", "..ss"], 22, 20, {'s': sh})
    pix(a, ["ss..", "..ss"], 6, 14, {'s': sh})
    return finish(a)


def win_over():
    """big heart, charm pink; a cream heart in the middle, green heal pluses and a gold sparkle around it."""
    c, hl = TY['charm'], TY['heal']
    m = ell_mask(2, 3, 16, 17) | ell_mask(15, 3, 29, 17) | poly_mask([(3, 12), (28, 12), (15.5, 28.5)])
    a = badge(m, c['base'], c['light'], c['shade'], WHITE, (2, 2))
    L = layer()
    pix(L, [
        ".wwww...wwww.",
        "wwwwww.wwwwww",
        "wWwwwwwwwwwww",
        "wWwwwwwwwwwwc",
        "wwwwwwwwwwwwc",
        ".wwwwwwwwwwc.",
        "..wwwwwwwwc..",
        "...wwwwwcc...",
        "....wwwcc....",
        ".....wcc.....",
        "......c......",
    ], 9, 9, {'w': WHITE, 'W': CREAM, 'c': CD})
    outlined(a, L)
    L = layer()
    plus = [".g.", "ggg", ".g."]
    pix(L, plus, 6, 6, {'g': hl['light']})
    pix(L, plus, 23, 6, {'g': hl['light']})
    outlined(a, L)
    L = layer()
    pix(L, ["G", "G"], 13, 11, {'G': WHITE})
    return finish(a)


def bait():
    """luggage tag, item amber, point up with a punched eyelet; a line drops to a fish hook with a wrapped trick-yellow candy on it."""
    it, t = TY['item'], TY['trick']
    m = poly_mask([(10, 2), (21, 2), (28, 9), (28, 29), (3, 29), (3, 9)])
    a = badge(m, it['base'], it['light'], it['shade'], CREAM, (2, 2))
    pix(a, [".kkk.", "kcccK", "kc.cK", "kcccK", ".kkk."], 13, 3, {'k': INK, 'c': CREAM, 'K': INK})
    a[5, 15] = (0, 0, 0, 0)                  # see-through hole
    for y in range(8, 11):                   # fishing line
        a[y, 16] = INK + (255,)
    L = layer()
    w, g = WHITE, CD
    pix(L, [
        "ww........",
        "ww........",
        "ww........",
        "ww........",
        "wg........",
        "wg......w.",
        "wg.....ww.",
        "wg.....ww.",
        "wg....ww..",
        ".wwwwwwg..",
        "..gggg....",
    ], 15, 11, {'w': w, 'g': g})
    outlined(a, L)
    L = layer()
    yw, yl, ys = t['base'], t['light'], t['shade']
    pix(L, [
        "f..ooo..f",
        "ffolllyff",
        "ffoyyyyff",
        "ffoysyyff",
        "f..ooo..f",
    ], 18, 18, {'f': yl, 'o': yw, 'l': yl, 'y': yw, 's': ys})
    outlined(a, L)
    return finish(a)


# ---------------------------------------------------------------- crown + open end
def crown():
    """12x12 boss crown: three spikes with light tips, cream jewel dots on the band, ink outline."""
    rows = [
        ".#...##...#.",
        "#l#.#lg#.#g#",
        "#lg#lggd#lg#",
        "#lgglgggggd#",
        "#gggggggggd#",
        "#cgcgcgcgcd#",
        "#dddddddddd#",
        "############",
    ]
    im = np.zeros((12, 12, 4), np.uint8)
    pix(im, rows, 0, 2, {'#': INK, 'g': GOLD, 'l': LGOLD, 'd': DGOLD, 'c': CREAM})
    return Image.fromarray(im)


def open_end():
    """24x24: gold ring with a cream inner bevel and an ink arrow pointing inward (to the free socket)."""
    s = 24
    a = np.zeros((s, s, 4), np.uint8)
    outer = ell_mask(1, 1, 22, 22, s)
    inner = ell_mask(6, 6, 17, 17, s)
    ring = outer & ~inner
    a[ring] = GOLD + (255,)
    # light on the top half of the ring, shade on the bottom half
    yy, xx = np.mgrid[0:s, 0:s]
    a[ring & (yy + xx < 18)] = LGOLD + (255,)
    a[ring & (yy + xx > 28)] = DGOLD + (255,)
    # cream stitch dashes around the ring middle
    mid = ell_mask(3, 3, 20, 20, s) & ~ell_mask(4, 4, 19, 19, s)
    pts = list(zip(*np.nonzero(mid)))
    pts.sort(key=lambda p: math.atan2(p[0] - 11.5, p[1] - 11.5))
    for i, (y, x) in enumerate(pts):
        if i % 4 < 2:
            a[y, x] = CREAM + (255,)
    # inner hole: dark felt so it reads as a socket
    a[inner] = B.FELT + (255,)
    m = a[..., 3] > 0
    a[nb4(m) & ~m] = INK + (255,)
    # ink outline between ring and hole
    a[inner & nb4(ring)] = INK + (255,)
    # arrow: from the top of the ring pointing down into the hole (cream with ink)
    pix(a, [
        "..kkkk..",
        "..kcck..",
        "..kcck..",
        "..kcck..",
        "kkkcckkk",
        "kccccccK",
        ".kcccck.",
        "..kcck..",
        "...kk...",
    ], 8, 3, {'k': INK, 'c': CREAM, 'K': INK})
    return Image.fromarray(a)


STAMPS = [('ambush', ambush), ('riposte', riposte), ('double-swing', double_swing),
          ('calm-charm', calm_charm), ('win-over', win_over), ('bait', bait)]


def check_hard(im, name):
    a = np.array(im)
    al = set(np.unique(a[..., 3]).tolist())
    assert al <= {0, 255}, f'{name}: soft alpha {al}'


def main(out):
    os.makedirs(out, exist_ok=True)
    for k, f in STAMPS:
        im = f()
        assert im.size == (32, 32)
        check_hard(im, k)
        im.save(os.path.join(out, f'combo-{k}.png'))
    c = crown()
    check_hard(c, 'crown')
    c.save(os.path.join(out, 'crown-boss.png'))
    o = open_end()
    check_hard(o, 'open-end')
    o.save(os.path.join(out, 'open-end.png'))
    print('wrote', out)


if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else DEFAULT_OUT)
