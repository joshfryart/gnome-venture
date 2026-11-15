#!/usr/bin/env python3
"""Derive the gnome-wear item variants from the six base icons (Hearth Pop v3, hard pixels only).

  cut b  : a small coloured patch stitched on in the lower right (silhouette unchanged)
  -lined : gold stitched hem, gold #f5b82e dashes 2 on / 1 off, one pixel inside the bottom edge
  -fine  : lined + a tiny pearl-white sparkle (cream plus, 2 px arms) in the upper right

usage: python3 derive_icons.py [ph_dir]   (default: <repo>/game/assets/img/ph)
"""
import os
import sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
PH = sys.argv[1] if len(sys.argv) > 1 else os.path.normpath(os.path.join(HERE, "../../../game/assets/img/ph"))

INK = (0x2B, 0x1C, 0x26, 255)
GOLD = (0xF5, 0xB8, 0x2E, 255)
GOLD_SH = (0xD9, 0x83, 0x22, 255)
CREAM = (0xFF, 0xF4, 0xD6, 255)
PEARL = (0xE8, 0xDF, 0xF2, 255)


def hexc(h):
    return (int(h[1:3], 16), int(h[3:5], 16), int(h[5:7], 16), 255)


# patch ramps for cut b: deep, shade, base, hi  (chosen to contrast with each base material)
PATCH = {
    "flood-boots":   ["#7a3a1a", "#b8601e", "#e8902e", "#ffc860"],  # mustard-orange rubber patch
    "wayfarers-hat": ["#2a4a7a", "#3a86b0", "#5fb0d0", "#a8e4ec"],  # blue felt patch
    "work-gloves":   ["#24544a", "#3f9150", "#6cb458", "#b4dc7c"],  # green canvas patch
    "travel-cloak":  ["#35295f", "#5a459e", "#8a6fd0", "#c9b2f0"],  # plum patch
    "trail-pack":    ["#6e2038", "#b52e3f", "#e0503e", "#ff8a5c"],  # red patch
}
BASES = ["flood-boots", "wayfarers-hat", "work-gloves", "travel-cloak", "trail-pack", "yarn-scarf"]
CUT_B = set(PATCH)


def solid(px, w, h, x, y):
    return 0 <= x < w and 0 <= y < h and px[x, y][3] == 255


def is_ink(p):
    return p[:3] == INK[:3]


def check(im, name):
    assert im.size == (64, 64), name
    for a in (im.get_flattened_data() if hasattr(im, 'get_flattened_data') else im.getdata()):
        assert a[3] in (0, 255), name + ": semi-transparent pixel"


def hem_points(im):
    """For each column: one pixel above the lowest 'cloth' pixel, so a row of material still shows
    under the stitches. Cloth = a material (non-ink) pixel with 2 more material pixels above it and a
    material neighbour left or right (this skips fringes, thin strands and drips)."""
    w, h = im.size
    px = im.load()

    def mat(x, y):
        return 0 <= x < w and 0 <= y < h and px[x, y][3] == 255 and not is_ink(px[x, y])

    pts = {}
    for x in range(w):
        for y in range(h - 1, 2, -1):
            if mat(x, y) and mat(x, y - 1) and mat(x, y - 2) and (mat(x - 1, y) or mat(x + 1, y)):
                pts[x] = y - 1
                break
    # keep only the main hem: drop columns whose y jumps far from both neighbours (stray bits)
    keep = {}
    for x in sorted(pts):
        nb = [pts[n] for n in (x - 1, x + 1) if n in pts]
        if nb and min(abs(pts[x] - v) for v in nb) <= 2:
            keep[x] = pts[x]
    return keep


def add_lined(im):
    px = im.load()
    pts = hem_points(im)
    xs = sorted(pts)
    # dashes 2 on 1 off along the hem, counted along consecutive runs
    runs, cur = [], []
    for x in xs:
        if cur and x != cur[-1] + 1:
            runs.append(cur)
            cur = []
        cur.append(x)
    if cur:
        runs.append(cur)
    for run in runs:
        for i, x in enumerate(run[1:-1]):  # leave the rounded corner pixels at both ends
            if i % 3 < 2:
                px[x, pts[x]] = GOLD
    return im


def add_patch(im, name):
    """A 7x6 patch with a deep border, lit top-left and two cream tack stitches, placed as far to the
    lower right as fits fully on material pixels (and clear of the hem line)."""
    w, h = im.size
    px = im.load()
    hem = hem_points(im)
    for pw, ph in ((9, 8), (8, 7), (7, 6)):
        best = find_spot(px, w, h, hem, pw, ph)
        if best:
            break
    assert best, name + ": no room for patch"
    paint_patch(px, best[1], best[2], pw, ph, name)
    return im


def find_spot(px, w, h, hem, pw, ph):
    best = None
    for y0 in range(h - ph):
        for x0 in range(w - pw):
            ok = True
            for y in range(y0 - 1, y0 + ph + 1):
                for x in range(x0 - 1, x0 + pw + 1):
                    p = px[x, y] if 0 <= x < w and 0 <= y < h else (0, 0, 0, 0)
                    if p[3] != 255 or is_ink(p):
                        ok = False
                        break
                    if x in hem and y >= hem[x] - 1:
                        ok = False
                        break
                if not ok:
                    break
            if ok:
                score = (x0 + pw) * 1.0 + (y0 + ph) * 1.15
                if best is None or score > best[0]:
                    best = (score, x0, y0)
    return best


def paint_patch(px, x0, y0, pw, ph, name):
    deep, shade, base, hi = [hexc(c) for c in PATCH[name]]
    for y in range(y0, y0 + ph):
        for x in range(x0, x0 + pw):
            edge = x in (x0, x0 + pw - 1) or y in (y0, y0 + ph - 1)
            corner = x in (x0, x0 + pw - 1) and y in (y0, y0 + ph - 1)
            if corner:
                continue  # rounded corners: underlying material shows
            if edge:
                c = deep
            elif y == y0 + 1:
                c = hi
            elif x == x0 + pw - 2 or y == y0 + ph - 2:
                c = shade
            elif (x - x0 + y - y0) % 3 == 0:
                c = shade  # diagonal weave of the patch cloth
            else:
                c = base
            px[x, y] = c
    # cream tack stitches across the patch border (top-left and bottom-right) and one weave pixel
    px[x0 + 1, y0] = CREAM
    px[x0, y0 + 1] = CREAM
    px[x0 + pw - 2, y0 + ph - 1] = CREAM
    px[x0 + pw - 1, y0 + ph - 2] = CREAM
    px[x0 + pw // 2, y0 + ph // 2] = shade


def add_sparkle(im):
    """Cream plus with 2 px arms (pearl tips) in the upper right, on clear canvas, 1 px clear of the
    object's outline, as close as possible to the object's top-right corner."""
    w, h = im.size
    px = im.load()
    occ = [(x, y) for y in range(h) for x in range(w) if px[x, y][3] == 255]
    x1 = max(x for x, _ in occ)
    y0 = min(y for _, y in occ)
    best = None
    for cy in range(2, h // 2):
        for cx in range(w // 2, w - 2):
            pts = [(cx + dx, cy) for dx in range(-2, 3)] + [(cx, cy + dy) for dy in (-2, -1, 1, 2)]
            ok = all(
                0 <= x + ex < w and 0 <= y + ey < h and px[x + ex, y + ey][3] == 0
                for x, y in pts for ex, ey in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1))
            )
            if ok:
                score = (cx - (x1 - 2)) ** 2 + (cy - (y0 + 3)) ** 2
                if best is None or score < best[0]:
                    best = (score, cx, cy)
    assert best, "no room for sparkle"
    _, cx, cy = best
    for d in (-1, 0, 1):
        px[cx + d, cy] = CREAM
        px[cx, cy + d] = CREAM
    for d in (-2, 2):
        px[cx + d, cy] = PEARL
        px[cx, cy + d] = PEARL
    return im


def main():
    made = []
    for base in BASES:
        src = Image.open(os.path.join(PH, base + ".png")).convert("RGBA")
        check(src, base)
        cuts = [("", src)]
        if base in CUT_B:
            cuts.append(("-b", add_patch(src.copy(), base)))
        for suffix, im in cuts:
            out = {}
            if suffix:
                out[base + suffix] = im
            lined = add_lined(im.copy())
            out[base + suffix + "-lined"] = lined
            out[base + suffix + "-fine"] = add_sparkle(lined.copy())
            for slug, img in out.items():
                check(img, slug)
                img.save(os.path.join(PH, slug + ".png"))
                made.append(slug)
    print(len(made), "derived:", " ".join(made))


if __name__ == "__main__":
    main()
