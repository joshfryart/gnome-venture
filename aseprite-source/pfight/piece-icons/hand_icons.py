#!/usr/bin/env python3
"""Hand-drawn replacements for 5 GLM piece icons, in the style of gen_pfight.py's
ico_hurt/guard/heal/... (bold type-colour silhouette, ink edge, cream halo, gloss).
Run: python3 hand_icons.py   -> writes out/ico-<key>.png, -s.png, .aseprite (32px drawn, 20px scaled)."""
import os, sys, struct, zlib
from PIL import Image, ImageDraw
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
from gen_pfight import TYPES, INK, CREAM, GOLD, WHITE, dark_of, light_of, finish_icon

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'out')
CLEAR = (0, 0, 0, 0)


class Pen:
    """Draws in 32px coordinates, scaled by k for the 20px version."""
    def __init__(s, S):
        s.S, s.k = S, S / 32.0
        s.im = Image.new('RGBA', (S, S), CLEAR)
        s.d = ImageDraw.Draw(s.im)

    def _p(s, pts):
        return [(round(x * s.k), round(y * s.k)) for x, y in pts]

    def _b(s, b):
        x0, y0, x1, y1 = b
        return [round(x0 * s.k), round(y0 * s.k), max(round(x1 * s.k), round(x0 * s.k)), max(round(y1 * s.k), round(y0 * s.k))]

    def poly(s, pts, c): s.d.polygon(s._p(pts), fill=c)
    def ell(s, b, c): s.d.ellipse(s._b(b), fill=c)
    def rect(s, b, c): s.d.rectangle(s._b(b), fill=c)
    def line(s, pts, c, w=1): s.d.line(s._p(pts), fill=c, width=w)
    def pt(s, x, y, c): s.d.point((round(x * s.k), round(y * s.k)), fill=c)

    def hole(s, b):  # transparent cut-out
        s.d.ellipse(s._b(b), fill=CLEAR)


def finish(p, gloss=()):
    g = [(round(x * p.k), round(y * p.k)) for x, y in gloss] if p.S == 32 else []
    return finish_icon(p.im, halo=(p.S == 32), gloss=g)


# --- hurt / quick: a gnat cloud, one big gnat + two small, wings cream, stingers
def ico_gnat_nip(S):
    p = Pen(S); b = TYPES['hurt']; lb, db = light_of(b), dark_of(b)
    smalls = [(21, 1)] + ([(23, 22)] if S == 32 else [])
    for ox, oy in smalls:                                               # small gnats
        p.poly([(ox + 1, oy + 4), (ox + 3, oy), (ox + 8, oy + 1), (ox + 7, oy + 5)], CREAM)
        p.ell((ox, oy + 4, ox + 8, oy + 8), b)
        p.pt(ox + 8, oy + 6, GOLD)
    p.poly([(3, 4), (13, 3), (16, 14), (6, 15)], CREAM)                 # big wing back
    p.poly([(8, 2), (17, 4), (17, 14), (10, 14)], WHITE)                # big wing front
    p.line([(10, 4), (14, 13)], light_of(TYPES['guard'])) if S == 32 else None
    p.ell((4, 13, 22, 24), b)                                           # body
    p.ell((19, 11, 28, 20), db)                                         # head
    p.poly([(27, 15), (31, 18), (27, 18)], GOLD)                        # proboscis
    p.poly([(2, 20), (6, 17), (6, 22)], db)                             # tail
    p.line([(8, 23), (5, 30)], db); p.line([(12, 24), (11, 31)], db); p.line([(17, 23), (19, 30)], db)
    p.line([(8, 16), (17, 16)], lb); p.line([(6, 19), (19, 19)], db)    # stripes
    p.pt(24, 14, WHITE); p.pt(25, 15, INK)
    return finish(p, [(9, 14), (10, 14)])


# --- trick / thorns: monkey face grimace
def ico_monkey_grimace(S):
    p = Pen(S); b = TYPES['trick']; fur = (170, 110, 60); db = dark_of(fur)
    p.ell((1, 8, 9, 17), fur); p.ell((23, 8, 31, 17), fur)             # ears
    p.ell((3, 10, 7, 15), (230, 170, 140)); p.ell((25, 10, 29, 15), (230, 170, 140))
    p.ell((4, 3, 28, 28), fur)                                         # head
    p.poly([(7, 8), (16, 12), (25, 8), (27, 15), (22, 19), (10, 19), (5, 15)], CREAM)  # face mask
    p.ell((8, 15, 24, 29), CREAM)                                      # muzzle
    p.rect((9, 10, 12, 13), INK); p.rect((20, 10, 23, 13), INK)         # eyes
    p.pt(10, 10, WHITE); p.pt(21, 10, WHITE)
    p.line([(8, 7), (13, 8)], db, 2); p.line([(19, 8), (24, 7)], db, 2) # brows
    p.rect((11, 20, 21, 24), INK)                                      # grimace
    p.rect((11, 20, 21, 21), WHITE); p.rect((13, 23, 19, 24), (232, 120, 120))
    p.rect((15, 17, 17, 18), db)                                       # nose
    p.poly([(12, 4), (14, 0), (16, 3), (18, 0), (20, 4)], db)                                   # hair tuft
    p.ell((6, 17, 10, 21), (230, 170, 140)); p.ell((22, 17, 26, 21), (230, 170, 140))   # cheeks
    return finish(p, [(8, 5), (9, 5)])


# --- heal: old turtle, mossy domed shell with hex plates
def ico_turtle_patience(S):
    p = Pen(S); b = TYPES['heal']; lb, db = light_of(b), dark_of(b); skin = (150, 170, 90)
    p.poly([(0, 23), (5, 19), (6, 24)], skin)                           # tail
    p.ell((22, 12, 31, 22), skin)                                       # head
    p.poly([(24, 20), (28, 23), (22, 23)], skin)
    p.rect((4, 22, 8, 29), skin); p.rect((19, 22, 23, 29), skin); p.rect((11, 23, 15, 28), skin)
    p.ell((2, 6, 26, 26), b)                                            # shell
    p.rect((2, 22, 26, 26), skin)
    p.ell((2, 21, 26, 27), CREAM)                                       # underside rim
    p.ell((2, 6, 26, 25), b)
    for (x, y) in ((14, 11), (8, 16), (20, 16), (14, 21)):              # plates
        p.poly([(x - 4, y), (x - 2, y - 3), (x + 2, y - 3), (x + 4, y), (x + 2, y + 3), (x - 2, y + 3)], lb)
        p.poly([(x - 3, y), (x - 1, y - 2), (x + 1, y - 2), (x + 3, y), (x + 1, y + 2), (x - 1, y + 2)], db)
    p.rect((26, 16, 26, 16), INK); p.pt(27, 16, INK); p.line([(25, 20), (29, 20)], db)
    p.rect((12, 0, 16, 4), GOLD); p.rect((13, 0, 15, 5), GOLD); p.rect((11, 1, 17, 3), GOLD)  # heal cross
    return finish(p, [(7, 10), (8, 9), (9, 9)])


# --- guard / evade: blue shield, cream hyena laughing
def ico_hyena_laugh(S):
    p = Pen(S); b = TYPES['guard']; db = dark_of(b); fur = (214, 170, 100); spot = (110, 70, 40)
    p.poly([(2, 3), (16, 1), (30, 3), (30, 16), (24, 25), (16, 31), (8, 25), (2, 16)], b)  # shield
    p.poly([(7, 6), (10, 2), (13, 9)], fur); p.poly([(25, 6), (22, 2), (19, 9)], fur)       # ears
    p.poly([(8, 7), (16, 6), (24, 7), (25, 14), (21, 22), (16, 25), (11, 22), (7, 14)], fur)  # head
    p.poly([(12, 5), (16, 3), (20, 5)], spot); p.poly([(8, 5), (10, 2), (11, 6)], spot); p.poly([(24, 5), (22, 2), (21, 6)], spot)                                               # mane tuft
    p.rect((10, 10, 12, 12), INK); p.rect((20, 10, 22, 12), INK)                             # eyes
    p.pt(10, 10, WHITE); p.pt(20, 10, WHITE)
    p.poly([(11, 15), (21, 15), (19, 22), (16, 23), (13, 22)], INK)                          # open laugh
    p.rect((12, 15, 20, 16), WHITE); p.rect((13, 21, 19, 21), (232, 120, 120))
    p.rect((15, 13, 17, 14), INK)                                                            # nose
    p.pt(9, 15, spot); p.pt(23, 14, spot); p.pt(12, 8, spot); p.pt(20, 8, spot)               # spots
    return finish(p, [(5, 5), (5, 6), (6, 5)])


# --- guard / thorns: octopus, blue mantle, cream suckers on curling arms
def ico_octopus_suckers(S):
    p = Pen(S); b = TYPES['guard']; lb, db = light_of(b), dark_of(b)
    for m in (False, True):
        f = (lambda x: 31 - x) if m else (lambda x: x)
        for a in ([(7, 19), (3, 23), (3, 28), (7, 30)], [(12, 21), (11, 27), (15, 30)]):
            p.line([(f(x), y) for x, y in a], b, 3)
    p.ell((4, 2, 27, 24), b)                                            # mantle
    p.ell((8, 14, 23, 25), db)
    p.ell((5, 3, 26, 22), b)
    p.ell((7, 10, 14, 18), CREAM); p.ell((17, 10, 24, 18), CREAM)       # eyes
    p.rect((10, 12, 13, 17), INK); p.rect((18, 12, 21, 17), INK)
    for x, y in ((3, 24), (3, 27), (5, 29), (11, 25), (11, 28), (13, 29)):
        p.pt(x, y, CREAM); p.pt(31 - x, y, CREAM)                       # suckers
    for (x, y) in ((8, 6), (11, 4), (15, 6)):
        p.pt(x, y, lb)
    return finish(p, [(9, 5), (10, 5)])


ICONS = {
    'gnat-cloud-gnat-nip': ico_gnat_nip,
    'mischief-monkey-grimace': ico_monkey_grimace,
    'ancient-snapper-ancient-patience': ico_turtle_patience,
    'savanna-hyena-laugh-it-off': ico_hyena_laugh,
    'deep-octopus-sucker-ring': ico_octopus_suckers,
}


def write_ase(im, path):
    """Minimal single-layer, single-frame RGBA .aseprite (format 1.3)."""
    w, h = im.size
    lname = b'Layer 1'
    lc = struct.pack('<HHHHHHB3sH', 1, 0, 0, 0, 0, 0, 255, b'\0\0\0', len(lname)) + lname
    cc = struct.pack('<HhhBHh5sHH', 0, 0, 0, 255, 2, 0, b'\0' * 5, w, h) + zlib.compress(im.tobytes())
    chunks = b''.join(struct.pack('<IH', len(c) + 6, t) + c for t, c in ((0x2004, lc), (0x2005, cc)))
    frame = struct.pack('<IHHH2sI', 16 + len(chunks), 0xF1FA, 2, 100, b'\0\0', 2) + chunks
    hdr = struct.pack('<IHHHHHIHIIB3sHBBhhHH', 0, 0xA5E0, 1, w, h, 32, 1, 100, 0, 0, 0, b'\0\0\0', 0, 1, 1, 0, 0, 16, 16)
    hdr = hdr.ljust(128, b'\0')
    data = hdr + frame
    open(path, 'wb').write(struct.pack('<I', len(data)) + data[4:])


if __name__ == '__main__':
    for key, fn in ICONS.items():
        big, small = fn(32), fn(20)
        big.save(os.path.join(OUT, 'ico-%s.png' % key))
        small.save(os.path.join(OUT, 'ico-%s-s.png' % key))
        write_ase(big, os.path.join(OUT, 'ico-%s.aseprite' % key))
        print('wrote', key)
