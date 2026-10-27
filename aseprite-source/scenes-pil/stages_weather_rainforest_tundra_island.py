"""Weather stage backdrops for rainforest, tundra and island (2026-10-27):
game/assets/img/scenes/stage-<land>-<weather>.png, one per HOLLOW_WEATHER key that makes sense for the land.

Usage: python3 -B aseprite-source/scenes-pil/stages_weather_rainforest_tundra_island.py [out_dir] [name ...]
       names like rainforest-fog, tundra-frost, island-storm (default: all drawn here); the
       stage-weather-<land>.json maps are always rewritten next to the PNGs.

Each picture is the v1 (sun) composition of stages_rainforest_tundra_island.py drawn again with the same horizon,
lane, centrepiece and framing: only the sky, haze tints, light, ground wetness / frost, particles and a few small
props change. The scene is drawn as stages (sky+far, ground, near objects); a stage can be recoloured on its own
(remap_in with the stage's touched mask), so one green can turn wet on the ground but stay put on a leaf.
Wind and storm blow to the LEFT here, the same way the rain streaks of the existing art slant.

What is not drawn (see WEATHER_MAP at the bottom, written as stage-weather-<land>.json):
- rainforest: rain = rainforest-v3 (already the rain scene); frost and snow make no sense -> fog (cool mist);
- tundra: snow = tundra-v3 (already the snowfall scene); heat makes no sense -> sun (the v1 thaw);
- island: frost -> cloud, snow -> rain (a cold day on a tropical isle is grey or wet, never white).
Same rules as the v1 kit: 240 x 135 grid at 2x, opaque, hard pixels, <= 32 colours, ground flat in y 84..116.
"""
import json
import math
import os
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np  # noqa: E402
from pixlib import (Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, dil4, hx, W, H)  # noqa: E402
from stages_rainforest_tundra_island import (  # noqa: E402
    bands, wave, cloud, top_edge, pebbles, ripples, rock, pine, seeded, birds, palm, big_leaf, fern, bromeliad,
    heliconia, butterfly, buttress_tree, canopy, starfish, shell, coconut, grass_clump, snow_patch, cottongrass,
    bearberry, inukshuk, island_beach, mask_of,
    DWOOD, STONE, MOSS, LEAF, DLEAF, EMBER, GOLD, CANVAS, SNOW)

LEFT = -1          # wind direction: towards the left


# ------------------------------------------------------------------ canvas that remembers what each stage painted
class TCanvas(Canvas):
    def __init__(self, bg='#000000'):
        super().__init__(bg)
        self.touched = blank()

    def fill(self, m, col):
        if col:
            super().fill(m, col)
            self.touched |= m

    def dots(self, pts, col):
        super().dots(pts, col)
        for x, y in pts:
            if 0 <= x < W and 0 <= y < H:
                self.touched[y, x] = True

    def stage(self):
        t, self.touched = self.touched, blank()
        return t


def remap_in(cv, pairs, mask=None):
    """Swap colours all at once (no chains), only inside mask."""
    if not pairs:
        return
    src = cv.px.copy()
    for a, b in pairs.items():
        m = np.all(src == hx(a), axis=2)
        if mask is not None:
            m &= mask
        cv.px[m] = hx(b)


def fold(cv, cap=32):
    """Safety net for the colour cap: fold the rarest colour into its nearest neighbour until under the cap."""
    folded = []
    while True:
        cols, counts = np.unique(cv.px.reshape(-1, 3), axis=0, return_counts=True)
        if len(cols) <= cap:
            return folded
        i = counts.argmin()
        c = cols[i].astype(int)
        others = np.delete(cols, i, 0)
        j = ((others.astype(int) - c) ** 2).sum(1).argmin()
        cv.px[np.all(cv.px == cols[i], axis=2)] = others[j]
        folded.append(('#%02x%02x%02x' % tuple(cols[i]), '#%02x%02x%02x' % tuple(others[j]), int(counts[i])))


def lum_map(cv):
    p = cv.px.astype(int)
    return 0.3 * p[:, :, 0] + 0.59 * p[:, :, 1] + 0.11 * p[:, :, 2]


# ------------------------------------------------------------------ weather marks (hard pixels)
def streaks(cv, seed, n, light, dark=None, ys=(0, 84), xs=(-4, W + 4), ln=5, slant=2, thresh=200, avoid=None):
    """Rain: 1 px slanted streaks; over very pale pixels they take the darker colour so they still read."""
    r = seeded(seed)
    m = blank()
    for _ in range(n):
        x, y = r.randint(*xs), r.randint(*ys)
        m |= line([(x, y), (x - slant, y + ln)])
    if avoid is not None:
        m &= ~avoid
    if dark:
        L = lum_map(cv)
        cv.fill(m & (L > thresh), dark)
        cv.fill(m & (L <= thresh), light)
    else:
        cv.fill(m, light)


def bolt(cv, x, y0, y1, seed, core='#f1ece0', glow='#c3b2ea', fork=True):
    """Lightning: zigzag 2 px core in a 1 px glow, with one side fork."""
    r = seeded(seed)
    pts, y = [(x, y0)], y0
    while y < y1:
        y = min(y1, y + r.randint(4, 7))
        x += r.choice((-5, -4, 2, 3)) if len(pts) % 2 else r.choice((-3, 2, 3))
        pts.append((x, y))
    m = line(pts, 2)
    if fork and len(pts) > 3:
        fx, fy = pts[2]
        fp = [(fx, fy)]
        for k in range(3):
            fx += r.randint(4, 6)
            fy += r.randint(4, 6)
            fp.append((fx, fy))
        m |= line(fp, 1)
    cv.fill(dil4(m) & ~m, glow)
    cv.fill(m, core)


def mist(cv, specs, col, shade=None):
    """Flat fog ribbons: (x0, y, x1, h); a 1 px shade under each when given."""
    for (x0, y, x1, h) in specs:
        m = rrect(x0, y, x1, y + h, 1)
        cv.fill(m, col)
        if shade:
            cv.fill(m & ~shift(m, 0, -1) & ~shift(m, 0, 1), shade)


def fog_band(cv, x0, x1, y, h, col, seed=0):
    """A fog wisp: a long lens, h px thick in the middle and tapering to its ends, top edge gently wavy."""
    m = blank()
    for x in range(max(0, x0), min(W - 1, x1) + 1):
        t = (x - x0) / max(1, x1 - x0)
        th = h * math.sin(math.pi * t) ** 0.6
        if th < 0.6:
            continue
        top = y + 1.2 * math.sin(x / 9.0 + seed) - th / 2
        m |= rect(x, round(top), x, round(top + th) - 1 if th >= 1.5 else round(top))
    cv.fill(m, col)
    return m


def fogs(cv, specs, col, seed=0):
    for i, (x0, x1, y, h) in enumerate(specs):
        fog_band(cv, x0, x1, y, h, col, seed + i * 1.7)


def gusts(cv, seed, n, col, ys, xs=(0, W - 1), lmin=8, lmax=20, avoid=None):
    """Wind lines blowing left: a long 1 px stroke (with a short tail dash) that curls up at its leading (left)
    end, or steps down once half way."""
    r = seeded(seed)
    m = blank()
    for k in range(n):
        x, y = r.randint(*xs), r.randint(*ys)
        ln = r.randint(lmin, lmax)
        m |= rect(x + ln + 3, y, x + ln + 5, y)
        if k % 2 == 0:
            m |= rect(x, y, x + ln, y)
            m |= rect(x - 1, y - 1, x - 1, y - 1) | rect(x - 2, y - 3, x - 2, y - 2) | rect(x - 1, y - 4, x, y - 4) | rect(x + 1, y - 3, x + 1, y - 3)
        else:
            m |= rect(x, y, x + ln // 2, y) | rect(x + ln // 2 + 1, y + 1, x + ln, y + 1)
    if avoid is not None:
        m &= ~avoid
    cv.fill(m, col)


def flying(cv, seed, n, cols, ys=(10, 110), xs=(0, W - 1), avoid=None):
    """Leaves / petals tumbling on the wind: little 3-4 pixel shapes in alternating tilts."""
    r = seeded(seed)
    for k in range(n):
        x, y = r.randint(*xs), r.randint(*ys)
        c = cols[k % len(cols)]
        t = k % 3
        if t == 0:
            pts = [(x, y), (x + 1, y), (x + 2, y), (x + 1, y - 1)]
        elif t == 1:
            pts = [(x, y), (x + 1, y), (x + 1, y + 1), (x + 2, y + 1)]
        else:
            pts = [(x, y + 1), (x + 1, y), (x + 1, y + 1), (x + 2, y)]
        if avoid is not None:
            pts = [(a, b) for a, b in pts if not (0 <= a < W and 0 <= b < H and avoid[b, a])]
        cv.dots(pts, c)


def shimmer(cv, seed, ys, col, xs=(0, W - 1), step=4, avoid=None):
    """Heat haze: short wavy dashes in rows, each row offset."""
    r = seeded(seed)
    m = blank()
    for y in range(ys[0], ys[1], step):
        x = xs[0] + r.randint(0, 18)
        while x < xs[1]:
            w = r.randint(6, 12)
            m |= rect(x, y, x + w // 2, y) | rect(x + w // 2 + 1, y - 1, x + w, y - 1)
            x += w + r.randint(10, 22)
    m &= rect(xs[0], 0, xs[1], H - 1)
    if avoid is not None:
        m &= ~avoid
    cv.fill(m, col)


def twinkles(cv, seed, n, col, mask, big=0.3):
    """Frost glints: single dots and little plus-shaped stars, only inside mask."""
    r = seeded(seed)
    ys, xs = mask.nonzero()
    if not len(ys):
        return
    m = blank()
    for k in range(n):
        i = r.randrange(len(ys))
        x, y = xs[i], ys[i]
        if r.random() < big:
            m |= rect(x - 1, y, x + 1, y) | rect(x, y - 1, x, y + 1)
        else:
            m |= rect(x, y, x, y)
    cv.fill(m & mask, col)


def steam(cv, pts, col):
    """Heat / humidity wisps: thin S-curves rising from the ground or canopy."""
    for (x, y, h) in pts:
        p = [(round(x + 2 * math.sin(k / 3.0)), y - k) for k in range(h)]
        cv.fill(line(p), col)


def puddles(cv, specs, water, rim, glint):
    for (x, y, w) in specs:
        pd = ell(x, y, x + w, y + 5)
        cv.fill(pd, water)
        cv.fill(top_edge(pd, 1), rim)
        cv.fill(rect(x + w // 3, y + 2, x + w // 3 + 3, y + 2), glint)


def rain_rings(cv, pts, col):
    for (x, y) in pts:
        cv.dots([(x - 1, y), (x + 1, y), (x, y - 1)], col)


def overcast(cv, y, col, under, seed, lump=(8, 18), drop=(3, 7)):
    """A cloud deck: everything above y, with a lumpy underside and a 1-2 px darker under-lip."""
    r = seeded(seed)
    m = rect(0, 0, W - 1, y)
    x = -10
    while x < W + 10:
        w = r.randint(*lump)
        d = r.randint(*drop)
        m |= ell(x, y - d, x + w, y + d)
        x += w - r.randint(2, 6)
    cv.fill(m, col)
    if under:
        cv.fill(m & ~shift(m, 0, -2), under)
    return m


def streak_cloud(cv, x, y, w, col, sh):
    """Wind-stretched cloud: two long flat pills, the upper one shorter and set back to the right."""
    m = rrect(x, y + 3, x + w, y + 6, 2) | rrect(x + w // 4, y, x + w - 2, y + 4, 2)
    cv.fill(m, col)
    cv.fill(m & ~shift(m, 0, -1), sh)


def vine_swung(cv, x, y0, y1, lean, col='#4f9a45', leafc='#7ab55c', ph=0.0):
    """Hanging liana blown sideways: offset grows with the square of the drop."""
    n = max(1, y1 - y0)
    pts = [(round(x + lean * ((y - y0) / n) ** 2 + 1.5 * math.sin(y / 6.0 + ph)), y) for y in range(y0, y1 + 1)]
    cv.fill(line(pts), col)
    for i, (px, py) in enumerate(pts[3::6]):
        cv.fill(rect(px - 3, py, px - 1, py) | rect(px - 2, py - 1, px - 2, py - 1) if i % 2 else rect(px + 1, py, px + 2, py), leafc)


def tufts_w(cv, pts, col, wind=False):
    for (x, y) in pts:
        if wind:
            cv.dots([(x, y), (x + 2, y), (x - 1, y - 1), (x + 1, y - 1), (x - 3, y - 2), (x - 1, y - 2)], col)
        else:
            cv.dots([(x, y), (x + 2, y), (x + 1, y - 1), (x - 1, y - 2), (x + 3, y - 2)], col)


# ================================================================== RAINFOREST
RF = {
    # sky bands; far ridge; far crowns; cliff; cliff lit; ledges; ledge lip; falls; falls streaks; mist; wall; trunk/low
    'sun':   dict(sky=[(0, '#a9d6ea'), (16, '#cde6e8'), (30, '#dfe9d0')], ridge='#c4dcc0', crowns='#a4c8b0',
                  cliff='#7ab58a', cliffl='#a4c8b0', ledge='#4f7a5a', ledgel='#7ab58a', falls='#f1ece0',
                  fallsl='#cde6e8', mist='#f1ece0', wall='#7ab58a', low='#4f7a5a'),
    'cloud': dict(sky=[(0, '#a4b8a8'), (16, '#b8ccb8'), (30, '#dfe9d0')], ridge='#c4dcc0', crowns='#b8ccb8',
                  cliff='#7a9a7a', cliffl='#a4b8a8', ledge='#4f7a5a', ledgel='#7a9a7a', falls='#dfe9d0',
                  fallsl='#b8ccb8', mist='#dfe9d0', wall='#7a9a7a', low='#4f7a5a'),
    'storm': dict(sky=[(0, '#4e3a8a'), (12, '#5b6470'), (28, '#8b8f96'), (40, '#a4b8a8')], ridge='#8b8f96',
                  crowns='#7a9a7a', cliff='#4f7a5a', cliffl='#7a9a7a', ledge='#2f5a2a', ledgel='#4f7a5a',
                  falls='#c9c5bc', fallsl='#a4b8a8', mist='#c9c5bc', wall='#4f7a5a', low='#2f5a2a'),
    'fog':   dict(sky=[(0, '#c4dcc0'), (14, '#dfe9d0'), (34, '#e6efe6')], ridge=None, crowns='#dfe9d0',
                  cliff='#c4dcc0', cliffl='#dfe9d0', ledge='#b8ccb8', ledgel='#c4dcc0', falls='#f1ece0',
                  fallsl='#dfe9d0', mist='#f1ece0', wall='#b8ccb8', low='#a4b8a8'),
    'wind':  dict(sky=[(0, '#7fbcd8'), (16, '#a9d6ea'), (30, '#cde6e8')], ridge='#c4dcc0', crowns='#a4c8b0',
                  cliff='#7ab58a', cliffl='#a4c8b0', ledge='#4f7a5a', ledgel='#7ab58a', falls='#f1ece0',
                  fallsl='#cde6e8', mist='#f1ece0', wall='#7ab58a', low='#4f7a5a'),
    'heat':  dict(sky=[(0, '#cde6e8'), (14, '#f2e4c0'), (30, '#f6d9b0')], ridge='#dfe9d0', crowns='#c4dcc0',
                  cliff='#a4c8b0', cliffl='#c4dcc0', ledge='#7ab58a', ledgel='#a4c8b0', falls='#f1ece0',
                  fallsl='#cde6e8', mist='#f1ece0', wall='#a4c8b0', low='#7ab58a'),
}


def rf_ground_w(cv, w, y0=84, soil='#7a4a1f'):
    """rf_ground of the v1 file, with wind-bent tufts on windy days."""
    g = wave(y0, [(1.2, 80, 0.4), (0.8, 33, 1.7)])
    cv.fill(g, '#4f9a45')
    cv.fill(top_edge(g, 2), '#7ab55c')
    lane = wave(y0 + 11, [(2.0, 120, 2.0), (1.0, 37, 0.5)]) & ~wave(y0 + 25, [(2.0, 100, 0.9), (1.0, 29, 2.2)])
    cv.fill(lane, '#9a6b3f')
    cv.fill(top_edge(lane, 1), '#7a4a1f')
    low = wave(116, [(1.5, 50, 0.3), (1.0, 19, 1.0)])
    cv.fill(low, '#2f6a3a')
    cv.fill(top_edge(low, 1), '#4f9a45')
    pebbles(cv, [(24, 102), (58, 108), (92, 100), (130, 104), (168, 101), (204, 106), (226, 100), (150, 108)], soil, '#c9a96e')
    if w != 'wind':      # on windy days the litter has blown away (it flies in the air instead)
        for (x, y, c) in ((36, 90, '#e8a317'), (112, 112, '#d6322b'), (186, 90, '#e8a317'), (76, 112, '#a4b86a'),
                          (214, 112, '#a4b86a'), (140, 92, '#d6322b'), (60, 92, '#a4b86a')):
            cv.fill(rect(x, y, x + 2, y + 1), c)
            cv.dots([(x + 1, y - 1)], '#7a4a1f')
    tufts_w(cv, [(8, 92), (70, 89), (120, 89), (160, 92), (232, 90), (100, 114), (16, 113), (190, 113)], '#2f6a3a', w == 'wind')
    return lane


def rainforest_w(w):
    P = RF[w]
    cv = TCanvas()
    bands(cv, P['sky'])
    if w == 'cloud':
        overcast(cv, 14, '#c4dcc0', '#a4b8a8', 11)
        for (x, y, wd) in ((60, 20, 40), (150, 24, 34), (4, 28, 30)):
            cloud(cv, x, y, wd, '#dfe9d0', '#b8ccb8')
    elif w == 'storm':
        overcast(cv, 18, '#5b6470', '#4e3a8a', 12, lump=(10, 22), drop=(4, 8))
        overcast(cv, 8, '#4e3a8a', None, 13)
        for (x, y, wd) in ((40, 22, 40), (150, 26, 46)):
            cloud(cv, x, y, wd, '#8b8f96', '#5b6470')
    elif w == 'fog':
        pass
    elif w == 'wind':
        for (x, y, wd) in ((20, 10, 52), (130, 16, 60), (90, 30, 36), (196, 30, 34)):
            streak_cloud(cv, x, y, wd, '#f1ece0', '#cde6e8')
    elif w == 'heat':
        cloud(cv, 150, 22, 20, '#f1ece0', '#f2e4c0')
    else:
        cloud(cv, 70, 16, 30, '#f1ece0', '#cde6e8')
        cloud(cv, 150, 22, 24, '#f1ece0', '#cde6e8')
    # far ridge and cliff with the waterfall in the middle
    if P['ridge']:
        cv.fill(wave(46, [(5, 70, 0.3), (3, 31, 1.1)]), P['ridge'])
    for x in range(-6, W + 6, 12):
        h = 14 + (x * 7) % 9
        cv.fill(ell(x, 52 - h, x + 16, 58), P['crowns'])
    cv.fill(rect(0, 54, W - 1, 64), P['crowns'])
    if w == 'fog':
        fogs(cv, [(-20, 120, 45, 4), (120, 260, 41, 4)], '#f1ece0')
    cliff = poly([(90, 44), (100, 30), (112, 26), (130, 26), (142, 30), (152, 44), (158, 70), (82, 70)])
    cv.fill(cliff, P['cliff'])
    cv.fill(cliff & ~shift(cliff, 3, 0), P['cliffl'])
    for (x, y, wd) in ((84, 36, 12), (92, 30, 12), (101, 25, 11), (128, 24, 11), (137, 28, 12), (146, 34, 12)):
        cv.fill(ell(x, y, x + wd, y + 8), P['ledge'])
        cv.fill(top_edge(ell(x, y, x + wd, y + 8), 1), P['ledgel'])
    falls = rect(112, 28, 126, 70)
    if w == 'heat':                        # a dry spell: the fall runs thin
        falls = rect(115, 28, 123, 70)
    elif w == 'storm':                     # swollen and wide
        falls = rect(110, 28, 128, 70)
    cv.fill(falls, P['falls'])
    for x in (114, 118, 123):
        cv.fill(rect(x, 32 + (x % 4) * 3, x, 66) & falls, P['fallsl'])
    cv.fill(rect(111, 27, 127, 28) & dil4(falls), P['fallsl'])
    md = -6 if w in ('wind', 'storm') else 0       # the spray blows left
    for (x, y, wd) in ((102, 62, 36), (94, 66, 20), (128, 65, 22)):
        cv.fill(ell(x + md, y, x + wd + md, y + 7), P['mist'])
    if md:
        cv.dots([(86, 58), (82, 62), (90, 55), (78, 66), (84, 52)], P['mist'])
    # mid jungle wall
    for i, x in enumerate(range(-4, W + 6, 15)):
        if 98 < x < 142:
            continue
        h = 16 + (i * 11) % 8
        cv.fill(rect(x + 7, 64, x + 8, 84), P['low'])
        cv.fill(ell(x, 66 - h, x + 18, 70), P['wall'])
    if w == 'fog':
        fogs(cv, [(-30, 100, 60, 5), (140, 270, 57, 5), (60, 180, 68, 4)], '#f1ece0', 1)
    cv.fill(wave(70, [(2, 40, 0.0), (1.5, 17, 1.0)]), P['wall'])
    for i, x in enumerate(range(2, W, 19)):
        cv.fill(ell(x, 70 + (i % 2) * 2, x + 22, 86), P['low'])
    if w == 'fog':
        fogs(cv, [(-20, 90, 76, 4), (90, 260, 78, 4), (30, 210, 82, 3)], '#e6efe6', 2)
    cv.stage()
    # --- ground
    lane = rf_ground_w(cv, w)
    gmask = cv.stage()
    if w == 'storm':
        remap_in(cv, {'#7ab55c': '#4f9a45', '#4f9a45': '#2f6a3a', '#2f6a3a': '#2f5a2a', '#9a6b3f': '#7a4a1f',
                      '#7a4a1f': '#5c3420', '#c9a96e': '#9a6b3f'}, gmask)
        puddles(cv, [(30, 104, 22), (120, 98, 16), (176, 108, 26), (74, 112, 14), (150, 101, 10)], '#3f8fb0', '#25637d', '#a9d6ea')
    elif w == 'cloud':
        remap_in(cv, {'#7ab55c': '#4f9a45'}, gmask & ~lane)
        cv.fill(top_edge(wave(84, [(1.2, 80, 0.4), (0.8, 33, 1.7)]), 1), '#7ab55c')
    elif w == 'heat':
        remap_in(cv, {'#4f9a45': '#7ab55c', '#7ab55c': '#a4b86a', '#9a6b3f': '#c9a96e', '#7a4a1f': '#9a6b3f',
                      '#2f6a3a': '#4f9a45'}, gmask)
        for (x, y, ln) in ((40, 102, 8), (96, 106, 6), (150, 100, 9), (196, 104, 7), (122, 108, 5)):   # cracks
            cv.fill(line([(x, y), (x + ln // 2, y + 1), (x + ln, y)]), '#9a6b3f')
    elif w == 'fog':
        remap_in(cv, {'#7ab55c': '#a4b86a'}, gmask)
        fogs(cv, [(20, 130, 85, 2), (140, 236, 86, 2)], '#e6efe6', 3)
    # sun shafts across the far layers only (sun and heat)
    if w in ('sun', 'heat'):
        far = mask_of(cv, [P['crowns'], P['wall'], P['cliffl']] + ([P['ridge']] if P['ridge'] else []))
        sh_col, sh_col2 = ('#dfe9d0', '#7ab58a') if w == 'sun' else ('#f2e4c0', '#a4c8b0')
        for (xa, xb) in ((40, 48), (64, 70), (178, 186), (200, 205)) + (((20, 26), (150, 156)) if w == 'heat' else ()):
            sh = poly([(xa, 0), (xb, 0), (xb + 26, 84), (xa + 26, 84)]) & ~wave(84, [(1.2, 80, 0.4), (0.8, 33, 1.7)])
            cv.fill(sh & far, sh_col)
            cv.fill(sh & mask_of(cv, [P['low']]), sh_col2)
    cv.stage()
    # --- framing giants
    buttress_tree(cv, -6, 10, 0, 90, flare=9)
    buttress_tree(cv, 228, 244, 0, 88, flare=9)
    cp = DLEAF if w == 'storm' else MOSS
    canopy(cv, [(-24, -16, 30, 20), (6, -14, 50, 14), (-10, 6, 22, 30), (200, -18, 256, 18), (180, -12, 226, 12), (222, 4, 252, 30)], cp)
    for (x, y0, y1, ph) in ((26, 8, 46, 0.0), (36, 4, 30, 1.5), (204, 8, 52, 2.0), (192, 6, 28, 0.7)):
        if w in ('wind', 'storm'):
            vine_swung(cv, x, y0, y1, -12 if w == 'wind' else -16, ph=ph)
        elif w == 'heat':
            vine_swung(cv, x, y0, y1 - 4, 0, '#4f9a45', '#a4b86a', ph=ph)
        else:
            vine_swung(cv, x, y0, y1, 0, ph=ph)
    bromeliad(cv, 12, 46, LEAF)
    bromeliad(cv, 230, 40, LEAF, GOLD)
    # foreground corners
    lf2 = ramp('#a4b86a', '#7ab55c', '#dfe9d0') if w == 'heat' else LEAF
    big_leaf(cv, -4, 132, 40, 16, -40, MOSS, slits=3)
    big_leaf(cv, 6, 134, 34, 14, -70 if w not in ('wind', 'storm') else -82, lf2)
    fern(cv, 30, 130, 26, -30 if w not in ('wind', 'storm') else -150, lf2, droop=0.5 if w != 'heat' else 0.9)
    heliconia(cv, 44, 130, 18)
    big_leaf(cv, 244, 132, 40, 16, -140 if w not in ('wind', 'storm') else -165, MOSS, slits=3)
    big_leaf(cv, 236, 134, 32, 14, -105 if w not in ('wind', 'storm') else -128, lf2)
    fern(cv, 210, 130, 24, -150 if w not in ('wind', 'storm') else -165, lf2, droop=0.5 if w != 'heat' else 0.9)
    for (x, y) in ((176, 126), (186, 128)):
        o = cv.obj(); o.part(rect(x + 2, y + 3, x + 3, y + 6), CANVAS, d=0)
        o.part(ell(x, y, x + 5, y + 4) & rect(0, 0, W, y + 3), EMBER, d=1, contour=True); o.draw()
        cv.dots([(x + 2, y + 1)], '#f2e4c0')
    cv.stage()
    # --- life and weather marks
    if w in ('sun', 'heat'):
        butterfly(cv, 150, 46)
        butterfly(cv, 86, 58, '#e8a317', '#f5cf6a')
        if w == 'heat':
            butterfly(cv, 170, 64, '#e46a9b', '#f6b8cf')
    if w in ('sun', 'cloud', 'heat'):
        birds(cv, [(170, 12), (182, 8)], '#4f7a5a')
    if w == 'cloud':
        butterfly(cv, 150, 50, '#e8a317', '#f5cf6a')
    if w == 'heat':
        steam(cv, [(56, 86, 16), (94, 87, 12), (152, 86, 18), (186, 87, 13), (72, 64, 10), (170, 60, 12)], '#f1ece0')
        steam(cv, [(30, 40, 10), (210, 46, 12)], '#f2e4c0')
    if w == 'fog':
        birds(cv, [(170, 16)], '#b8ccb8')
    if w == 'wind':
        gusts(cv, 21, 9, '#f1ece0', ys=(14, 70), xs=(40, 200))
        flying(cv, 22, 34, ['#7ab55c', '#a4b86a', '#e8a317', '#4f9a45', '#d6322b'], ys=(8, 112), xs=(14, 226))
        butterfly(cv, 132, 40, '#e8a317', '#f5cf6a')
    if w == 'storm':
        bolt(cv, 180, 12, 56, 5)
        bolt(cv, 62, 16, 44, 9, fork=False)
        streaks(cv, 31, 340, '#a9d6ea', '#7fbcd8', ys=(0, 120), ln=6, slant=3)
        streaks(cv, 32, 70, '#c9c5bc', None, ys=(0, 84), ln=7, slant=3)
        flying(cv, 33, 14, ['#4f9a45', '#7ab55c'], ys=(20, 80), xs=(30, 210))
        rain_rings(cv, [(40, 106), (130, 100), (186, 110), (82, 114), (154, 103)], '#a9d6ea')
    cv.remap({'#fff3c8': '#f2e4c0', '#c9c5bc': '#f1ece0', '#e6efd8': '#dfe9d0'} if w not in ('storm',) else {'#fff3c8': '#f2e4c0'})
    return cv


# ================================================================== TUNDRA
TU = {
    'sun':   dict(sky=[(0, '#7fbcd8'), (12, '#a9d6ea'), (26, '#cde6e8'), (40, '#e6efe6')], cl=('#f1ece0', '#cde6e8'),
                  peak='#a9d6ea', peaks='#7fbcd8', cap='#f1ece0', caps='#cde6e8', far='#a4b8a8', fartop='#cde6e8',
                  farsnow='#f1ece0', mid='#a4b86a', midtop='#c9a96e', lake='#3f8fb0', lakeu='#7fbcd8',
                  floe='#f1ece0', floes='#a9d6ea', pines='#4f7a5a'),
    'cloud': dict(sky=[(0, '#a4b8a8'), (12, '#b8ccb8'), (26, '#c9c5bc'), (40, '#e6efe6')], cl=('#e6efe6', '#c9c5bc'),
                  peak='#a4b8a8', peaks='#8b8f96', cap='#e6efe6', caps='#c9c5bc', far='#a4b8a8', fartop='#c9c5bc',
                  farsnow='#e6efe6', mid='#a4b86a', midtop='#c9a96e', lake='#3f8fb0', lakeu='#5b6470',
                  floe='#e6efe6', floes='#a4b8a8', pines='#4f7a5a'),
    'rain':  dict(sky=[(0, '#8b8f96'), (14, '#a4b8a8'), (30, '#b8ccb8')], cl=('#c9c5bc', '#a4b8a8'),
                  peak='#a4b8a8', peaks='#8b8f96', cap='#c9c5bc', caps='#a4b8a8', far='#8b8f96', fartop='#a4b8a8',
                  farsnow='#c9c5bc', mid='#7ab55c', midtop='#a4b86a', lake='#25637d', lakeu='#3f8fb0',
                  floe='#c9c5bc', floes='#a4b8a8', pines='#4f7a5a'),
    'storm': dict(sky=[(0, '#4e3a8a'), (12, '#5b6470'), (28, '#8b8f96'), (40, '#a4b8a8')], cl=('#8b8f96', '#5b6470'),
                  peak='#5b6470', peaks='#4e3a8a', cap='#c9c5bc', caps='#8b8f96', far='#5b6470', fartop='#8b8f96',
                  farsnow='#a4b8a8', mid='#4f7a5a', midtop='#7a9a7a', lake='#25637d', lakeu='#5b6470',
                  floe='#a4b8a8', floes='#8b8f96', pines='#2f5a2a'),
    'frost': dict(sky=[(0, '#a9d6ea'), (14, '#cde6e8'), (30, '#e6efe6')], cl=('#f1ece0', '#cde6e8'),
                  peak='#cde6e8', peaks='#a9d6ea', cap='#f1ece0', caps='#e6efe6', far='#cde6e8', fartop='#f1ece0',
                  farsnow='#f1ece0', mid='#c9c5bc', midtop='#f1ece0', lake='#a9d6ea', lakeu='#cde6e8',
                  floe='#f1ece0', floes='#cde6e8', pines='#4f7a5a'),
    'wind':  dict(sky=[(0, '#7fbcd8'), (12, '#a9d6ea'), (26, '#cde6e8'), (40, '#e6efe6')], cl=('#f1ece0', '#cde6e8'),
                  peak='#a9d6ea', peaks='#7fbcd8', cap='#f1ece0', caps='#cde6e8', far='#a4b8a8', fartop='#cde6e8',
                  farsnow='#f1ece0', mid='#a4b86a', midtop='#c9a96e', lake='#3f8fb0', lakeu='#7fbcd8',
                  floe='#f1ece0', floes='#a9d6ea', pines='#4f7a5a'),
    'fog':   dict(sky=[(0, '#cde6e8'), (16, '#e6efe6')], cl=None,
                  peak='#cde6e8', peaks='#cde6e8', cap='#e6efe6', caps='#e6efe6', far='#dfe9d0', fartop='#e6efe6',
                  farsnow='#e6efe6', mid='#c4dcc0', midtop='#dfe9d0', lake='#a9d6ea', lakeu='#cde6e8',
                  floe='#e6efe6', floes='#cde6e8', pines='#b8ccb8'),
}


def tundra_ground_w(cv, w, y0=84, snow='#a4b86a', shade='#7ab55c', grass='#c9a96e', tuft='#7a4a1f'):
    """The thaw lane of tundra_ground(thaw=True), with frost / wind variations of its marks."""
    g = wave(y0, [(1.0, 90, 0.2), (0.8, 41, 1.5)])
    cv.fill(g, snow)
    cv.fill(top_edge(g, 1), grass)
    for (x, y, wd, sd) in ((-6, 87, 30, 1), (156, 86, 34, 2), (100, 93, 18, 3), (214, 98, 30, 4), (44, 106, 16, 5), (128, 110, 22, 6)):
        p = snow_patch(x, y, wd, 5, sd)
        cv.fill(p, '#f1ece0')
        cv.fill(p & ~shift(p, 0, -1), '#cde6e8' if w != 'storm' else '#a4b8a8')
    for (x, y, wd) in ((60, 96, 20), (170, 100, 18), (16, 112, 14), (220, 106, 12), (84, 112, 16)):
        cv.fill(rect(x, y, x + wd, y), grass)
        cv.fill(rect(x + 3, y + 1, x + wd - 4, y + 1), shade)
    low = wave(117, [(1.5, 50, 0.6)])
    cv.fill(low, shade)
    cv.fill(top_edge(low, 1), grass)
    tufts_w(cv, [(6, 98), (56, 90), (140, 96), (230, 90), (92, 104), (214, 114), (160, 114)], tuft, w in ('wind', 'storm'))
    for (x, y) in ((22, 100), (122, 98), (178, 106), (66, 110)):
        cv.dots([(x, y), (x + 1, y)], '#8b8f96')
    return g


def tundra_w(w):
    P = TU[w]
    cv = TCanvas()
    bands(cv, P['sky'])
    if w == 'cloud':
        overcast(cv, 12, '#b8ccb8', '#a4b8a8', 21)
        for (x, y, wd) in ((24, 18, 40), (150, 14, 50), (96, 26, 30)):
            cloud(cv, x, y, wd, *P['cl'])
    elif w == 'rain':
        overcast(cv, 16, '#a4b8a8', '#8b8f96', 22, lump=(10, 22))
        for (x, y, wd) in ((40, 20, 44), (170, 22, 40)):
            cloud(cv, x, y, wd, *P['cl'])
    elif w == 'storm':
        overcast(cv, 16, '#5b6470', '#4e3a8a', 23, lump=(10, 22), drop=(4, 8))
        overcast(cv, 6, '#4e3a8a', None, 24)
        for (x, y, wd) in ((20, 22, 46), (140, 20, 50)):
            cloud(cv, x, y, wd, *P['cl'])
    elif w == 'frost':
        for (x, y, wd) in ((30, 12, 50), (160, 18, 40)):
            cv.fill(rrect(x, y, x + wd, y + 1, 1), '#f1ece0')
            cv.fill(rect(x + 8, y + 2, x + wd - 12, y + 2), '#e6efe6')
    elif w == 'wind':
        for (x, y, wd) in ((14, 12, 56), (150, 8, 64), (96, 22, 40)):
            streak_cloud(cv, x, y, wd, *P['cl'])
    elif w == 'sun':
        cloud(cv, 24, 14, 34, *P['cl'])
        cloud(cv, 168, 10, 44, *P['cl'])
    peaks = poly([(-10, 62), (18, 38), (36, 48), (62, 28), (92, 52), (120, 38), (150, 56), (182, 26), (212, 44), (250, 32), (250, 66), (-10, 66)])
    cv.fill(peaks, P['peak'])
    cv.fill(peaks & ~shift(peaks, -3, 0) & ~rect(0, 0, W, 32), P['peaks'])
    caps = (poly([(18, 38), (27, 47), (9, 47)]) | poly([(62, 28), (75, 43), (49, 43)]) | poly([(120, 38), (129, 47), (111, 47)])
            | poly([(182, 26), (197, 43), (167, 43)]) | poly([(250, 32), (250, 45), (237, 43)]))
    if w == 'frost':        # fresh rime lower down the slopes
        caps = (poly([(18, 38), (31, 51), (5, 51)]) | poly([(62, 28), (79, 47), (45, 47)]) | poly([(120, 38), (133, 51), (107, 51)])
                | poly([(182, 26), (201, 47), (163, 47)]) | poly([(250, 32), (250, 49), (233, 47)]))
    cv.fill(caps & peaks, P['cap'])
    cv.fill(caps & peaks & ~shift(caps & peaks, -2, 0), P['caps'])
    if w == 'wind':          # spindrift: snow plumes blown off the summits
        for (px, py) in ((18, 38), (62, 28), (120, 38), (182, 26)):
            m = line([(px, py), (px - 8, py - 2), (px - 18, py - 2)], 2) | line([(px - 4, py + 1), (px - 14, py + 1)])
            cv.fill(m, '#f1ece0')
            cv.dots([(px - 22, py - 3), (px - 26, py - 2), (px - 21, py)], '#f1ece0')
    if w == 'fog':
        fogs(cv, [(-20, 110, 45, 4), (130, 260, 40, 4)], '#f1ece0')
    far = wave(58, [(2, 110, 0.6), (1.5, 47, 2.1)])
    cv.fill(far, P['far'])
    cv.fill(top_edge(far, 1), P['fartop'])
    for (x, y, wd, sd) in ((8, 60, 26, 11), (150, 59, 30, 12), (200, 62, 26, 13), (56, 63, 18, 14)):
        cv.fill(snow_patch(x, y, wd, 3, sd), P['farsnow'])
    mid = wave(66, [(2, 90, 1.6), (1, 31, 0.3)])
    cv.fill(mid, P['mid'])
    cv.fill(top_edge(mid, 1), P['midtop'])
    if w == 'fog':
        fogs(cv, [(-20, 80, 62, 3), (160, 260, 61, 3)], '#f1ece0', 1)
    # the lake
    lake = ell(70, 67, 176, 84)
    cv.fill(lake, P['lake'])
    cv.fill(lake & ~shift(lake, 0, -2), P['lakeu'])
    if w == 'frost':        # frozen over: cracks and pale wind-scoured streaks
        for pts in (((84, 74), (96, 76), (104, 74), (114, 78)), ((126, 72), (134, 75), (142, 74)), ((146, 79), (158, 76), (166, 77)),
                    ((96, 80), (104, 79))):
            cv.fill(line(list(pts)) & lake, '#7fbcd8')
        for (x, y, wd) in ((86, 71, 14), (118, 77, 16), (150, 72, 10), (104, 82, 18)):
            cv.fill(rect(x, y, x + wd, y) & lake, '#f1ece0')
    else:
        for (x0, y0, x1, y1) in ((80, 73, 100, 76), (108, 70, 130, 72), (136, 74, 150, 78), (154, 71, 166, 73), (96, 79, 112, 81)):
            f = rrect(x0, y0, x1, y1, 1) & lake
            cv.fill(f, P['floe'])
            cv.fill(f & ~shift(f, 0, -1), P['floes'])
        rip = {'rain': '#3f8fb0', 'storm': '#3f8fb0', 'wind': '#f1ece0'}.get(w, P['floes'])
        for (x, y, wd) in ((118, 77, 12), (88, 70, 6), (140, 70, 8)) + (((76, 76, 4), (102, 74, 5), (160, 76, 5), (128, 81, 6)) if w in ('wind', 'storm') else ()):
            cv.fill(rect(x, y, x + wd, y) & lake, rip)
        if w in ('rain', 'storm'):
            rain_rings(cv, [(92, 78), (120, 74), (146, 80), (104, 71), (164, 75), (132, 77)], P['floes'])
    # the inukshuk on its rise in the middle
    rise = ell(104, 58, 140, 70) & rect(0, 0, W, 66)
    cv.fill(rise, P['mid'])
    cv.fill(top_edge(rise, 1), P['midtop'])
    if w == 'fog':          # a ghost of a waymarker in the fog
        sil = blank()
        cv2 = TCanvas()
        inukshuk(cv2, 122, 64, 0.62)
        sil = np.any(cv2.px != 0, axis=2)
        cv.fill(sil, '#a4b8a8')
        cv.fill(sil & ~shift(sil, 0, 1), '#c9c5bc')
    else:
        inukshuk(cv, 122, 64, 0.62)
        if w == 'frost':
            cv.fill(rect(112, 54, 132, 54) & mask_of(cv, ['#8b8f96', '#5b6470']) | rect(118, 41, 126, 41) & mask_of(cv, ['#8b8f96']), '#f1ece0')
    sky_far = cv.stage()
    # --- ground
    gcol = {'sun': ('#a4b86a', '#7ab55c', '#c9a96e', '#7a4a1f'), 'cloud': ('#a4b86a', '#7ab55c', '#c9a96e', '#7a4a1f'),
            'wind': ('#a4b86a', '#7ab55c', '#c9a96e', '#7a4a1f'), 'rain': ('#7ab55c', '#4f9a45', '#a4b86a', '#5c3420'),
            'storm': ('#4f9a45', '#2f6a3a', '#7ab55c', '#3d2a1c'), 'frost': ('#a4b8a8', '#7a9a7a', '#e6efe6', '#7a4a1f'),
            'fog': ('#a4b86a', '#7ab55c', '#c4dcc0', '#7a4a1f')}[w]
    g = tundra_ground_w(cv, w, 84, *gcol)
    if w in ('rain', 'storm'):
        puddles(cv, [(30, 102, 18), (126, 104, 14), (180, 96, 20), (82, 114, 14)], '#7fbcd8' if w == 'rain' else '#3f8fb0',
                '#3f8fb0' if w == 'rain' else '#25637d', '#cde6e8')
    if w == 'frost':
        twinkles(cv, 41, 70, '#f1ece0', g & ~rect(0, 116, W, H) & ~mask_of(cv, ['#f1ece0', '#cde6e8']), big=0.25)
    if w == 'fog':
        fogs(cv, [(-10, 110, 85, 3), (130, 250, 86, 3)], '#e6efe6', 2)
    if w == 'wind':      # snow blown low along the lane: flat streaks off the patches
        for (x, y, ln) in ((28, 88, 16), (192, 87, 18), (120, 94, 12), (246, 99, 14), (62, 107, 12), (152, 111, 14), (100, 100, 8)):
            cv.fill(rect(x - ln, y, x - 3, y) | rect(x - ln - 6, y + 1, x - ln - 2, y + 1), '#f1ece0')
    cv.stage()
    # --- spruces
    for (x, yb, wd, h) in ((38, 70, 10, 18), (48, 72, 12, 22), (58, 70, 9, 16)):
        pine(cv, x, yb, wd, h, flat=P['pines'], snow='#f1ece0' if w != 'fog' else '#e6efe6')
    pine(cv, 8, 92, 18, 46, snow='#f1ece0')
    pine(cv, 22, 88, 12, 30, snow='#f1ece0')
    if w == 'wind':
        cv.dots([(2, 52), (0, 58), (4, 46), (14, 60), (12, 66)], '#f1ece0')
    # foreground corners
    cap = SNOW if w == 'frost' else None
    for (x0, y0, x1, y1) in ((-8, 112, 34, 134), (206, 114, 250, 134)):
        rock(cv, x0, y0, x1, y1, cap=cap)
        for (dx, dy) in ((8, 6), (14, 4), (20, 8), (30, 6)):
            if not cap or dy >= 6:
                cv.fill(rect(x0 + dx, y0 + dy, x0 + dx + 2, y0 + dy + 1), '#e8cf98')
    bearberry(cv, 34, 120)
    bearberry(cv, 186, 122)
    cg = [(52, 126, 8), (56, 124, 10), (60, 127, 7), (176, 124, 9), (180, 126, 7), (230, 104, 8), (234, 106, 6), (90, 116, 6)]
    if w in ('wind', 'storm'):
        for (x, y, h) in cg:
            cv.fill(line([(x, y), (x - 1, y - h // 2), (x - 3, y - h + 1)]), '#a4b86a')
            cv.fill(rect(x - 5, y - h, x - 3, y - h + 1), '#f1ece0')
    else:
        cottongrass(cv, cg)
    if w == 'frost':
        for (x, y) in ((36, 120), (42, 119), (48, 121), (188, 122), (196, 121), (200, 123)):
            cv.dots([(x, y)], '#f1ece0')
    near = cv.stage()
    # --- weather marks
    if w in ('sun', 'cloud', 'frost'):
        birds(cv, [(118, 18), (128, 14), (138, 20)], '#5b6470' if w != 'cloud' else '#8b8f96')
    if w == 'wind':
        birds(cv, [(150, 34), (164, 38)], '#5b6470')
        gusts(cv, 51, 8, '#f1ece0', ys=(16, 56), xs=(70, 220))
        gusts(cv, 52, 4, '#e6efe6', ys=(88, 112), xs=(40, 200), lmin=10, lmax=16)
        flying(cv, 53, 18, ['#f1ece0', '#d6322b', '#c9a96e'], ys=(70, 118), xs=(40, 226))
    if w == 'rain':
        streaks(cv, 61, 220, '#dfe9d0', '#8b8f96', ys=(0, 118), ln=5, slant=2)
    if w == 'storm':
        bolt(cv, 186, 10, 34, 7)
        bolt(cv, 66, 14, 34, 3, fork=False)
        streaks(cv, 62, 320, '#a9d6ea', '#8b8f96', ys=(0, 122), ln=6, slant=3)
        streaks(cv, 63, 60, '#c9c5bc', None, ys=(0, 70), ln=7, slant=3)
    if w == 'fog':
        fogs(cv, [(-30, 50, 32, 3), (-20, 40, 64, 4), (190, 270, 70, 3)], '#f1ece0', 3)
        birds(cv, [(128, 22)], '#c9c5bc')
    cv.remap({'#fff3c8': '#f1ece0', '#c9c5bc': '#e6efe6'} if w in ('sun', 'wind') else {'#fff3c8': '#f1ece0'})
    return cv


# ================================================================== ISLAND
IS = {
    'sun':   dict(sky=[(0, '#7fbcd8'), (14, '#a9d6ea'), (28, '#cde6e8')], sea=[(46, '#7fbcd8'), (56, '#7fc8c8'), (70, '#bfe6e0')],
                  rip=('#bfe6e0', '#7fc8c8'), vol='#7ab58a', vols='#4f7a5a', crater='#8b8f96', smoke='#f1ece0',
                  strip='#a4b86a', bush='#4f7a5a'),
    'cloud': dict(sky=[(0, '#a4b8a8'), (14, '#b8ccb8'), (28, '#c9c5bc')], sea=[(46, '#3f8fb0'), (56, '#7fbcd8'), (70, '#a9d6ea')],
                  rip=('#a9d6ea', '#7fbcd8'), vol='#7a9a7a', vols='#4f7a5a', crater='#8b8f96', smoke='#c9c5bc',
                  strip='#a4b8a8', bush='#4f7a5a'),
    'rain':  dict(sky=[(0, '#8b8f96'), (14, '#a4b8a8'), (30, '#b8ccb8')], sea=[(46, '#25637d'), (56, '#3f8fb0'), (70, '#7fbcd8')],
                  rip=('#7fbcd8', '#a9d6ea'), vol='#a4b8a8', vols='#8b8f96', crater='#8b8f96', smoke='#b8ccb8',
                  strip='#8b8f96', bush='#8b8f96'),
    'storm': dict(sky=[(0, '#4e3a8a'), (12, '#5b6470'), (28, '#8b8f96')], sea=[(46, '#25637d'), (56, '#3f8fb0'), (70, '#7fbcd8')],
                  rip=('#f1ece0', '#f1ece0'), vol='#5b6470', vols='#4e3a8a', crater='#5b6470', smoke='#8b8f96',
                  strip='#5b6470', bush='#4e3a8a'),
    'heat':  dict(sky=[(0, '#a9d6ea'), (12, '#cde6e8'), (26, '#f2e4c0'), (38, '#f6d9b0')], sea=[(46, '#7fc8c8'), (56, '#bfe6e0'), (70, '#cde6e8')],
                  rip=('#cde6e8', '#bfe6e0'), vol='#a4c8b0', vols='#7ab58a', crater='#c9c5bc', smoke='#f1ece0',
                  strip='#c9a96e', bush='#7ab58a'),
    'wind':  dict(sky=[(0, '#7fbcd8'), (14, '#a9d6ea'), (28, '#cde6e8')], sea=[(46, '#3f8fb0'), (56, '#7fbcd8'), (70, '#7fc8c8')],
                  rip=('#f1ece0', '#bfe6e0'), vol='#7ab58a', vols='#4f7a5a', crater='#8b8f96', smoke='#f1ece0',
                  strip='#a4b86a', bush='#4f7a5a'),
    'fog':   dict(sky=[(0, '#cde6e8'), (16, '#e6efe6')], sea=[(46, '#cde6e8'), (58, '#bfe6e0'), (70, '#a9d6ea')],
                  rip=('#e6efe6', '#cde6e8'), vol='#cde6e8', vols='#a9d6ea', crater='#a9d6ea', smoke='#e6efe6',
                  strip='#a9d6ea', bush='#a9d6ea'),
}

PALM_L = [(-170, 30, 3), (-140, 34, 6), (-100, 26, 10), (-60, 30, 8), (-20, 34, 5), (10, 28, 3), (-200, 24, 2)]
PALM_R = [(-10, 30, 3), (-40, 34, 6), (-80, 26, 10), (-120, 30, 8), (-160, 34, 5), (170, 28, 3), (20, 24, 2)]
# blown left: every frond streams between left-up and left-down, flatter (less droop) the harder it blows
PALM_WIND = [(-212, 26, 5), (-198, 36, 4), (-183, 38, 2), (-168, 32, 0), (-152, 24, -2), (-226, 20, 4)]
PALM_HEAT = [(a, ln, d + 4) for (a, ln, d) in PALM_L]        # limp in the heat
PALM_HEAT_R = [(a, ln, d + 4) for (a, ln, d) in PALM_R]


def palm_blown(cv, base, ctrl, top, w0=8, w1=5, fronds=PALM_WIND, leaf=LEAF):
    """palm() of the v1 kit in a gale: same ringed trunk, but every frond streams downwind (left) like a feather,
    its leaflets swept towards the tip instead of hanging."""
    from stages_rainforest_tundra_island import bezier, WOOD
    o = cv.obj()
    left, right, rings = [], [], []
    n = 30
    for k in range(n + 1):
        t = k / n
        x, y = bezier(base, ctrl, top, t)
        r = (w0 + (w1 - w0) * t) / 2
        left.append((round(x - r), round(y)))
        right.append((round(x + r), round(y)))
        if k % 2 == 1:
            rings.append((x, y, r))
    tr = poly(left + right[::-1])
    o.part(tr, WOOD, d=2)
    o.draw()
    for (x, y, r) in rings:
        cv.fill(rect(round(x - r) + 1, round(y), round(x + r) - 2, round(y)) & tr, '#7a4a1f')
    tx, ty = top
    o = cv.obj()
    for (ang, ln, bend) in fronds:
        a = math.radians(ang)
        pts = [(tx + math.cos(a) * k, ty + math.sin(a) * k + bend * (k / ln) ** 2 * 3) for k in range(ln + 1)]
        lf = line([(round(px), round(py)) for px, py in pts], 2)
        for k in range(3, ln - 1, 4):
            px, py = pts[k]
            qx, qy = pts[k + 1]
            dx, dy = qx - px, qy - py
            d = math.hypot(dx, dy) or 1
            dx, dy = dx / d, dy / d
            ll = round(6 * (1 - k / ln) + 3)
            for sg in (1, -1):
                c, sn = math.cos(sg * 0.6), math.sin(sg * 0.6)
                ux, uy = dx * c - dy * sn, dx * sn + dy * c
                lf |= line([(round(px), round(py)), (round(px + ux * ll), round(py + uy * ll))], 2 if ll > 5 else 1)
        o.part(lf, leaf, d=1)
    o.draw()
    for (dx, dy) in ((-2, 2), (2, 3), (0, 5)):
        oo = cv.obj()
        oo.part(ell(tx + dx - 2, ty + dy - 2, tx + dx + 2, ty + dy + 2), DWOOD, d=1)
        oo.draw()


def sail_boat(cv, heel=0.0, sail='#f1ece0', stripe='#e46a9b', hull='#7a4a1f'):
    """The little sail of v1; heel > 0 leans the mast to the left (shear about the waterline y 48)."""
    def sh(pts):
        return [(round(x - (48 - y) * heel), y) for x, y in pts]
    o = cv.obj(outline=False)
    o.part(poly(sh([(66, 34), (66, 48), (56, 48)])), ramp(sail, None), d=0)
    o.part(poly(sh([(68, 38), (68, 48), (74, 48)])), ramp(stripe, None), d=0)
    o.part(rect(54, 49, 76, 51), ramp(hull, None), d=0)
    o.draw()


def island_w(w):
    P = IS[w]
    cv = TCanvas()
    bands(cv, P['sky'])
    if w == 'cloud':
        overcast(cv, 12, '#b8ccb8', '#a4b8a8', 31)
        for (x, y, wd) in ((30, 18, 40), (150, 22, 36), (96, 28, 26)):
            cloud(cv, x, y, wd, '#dfe9d0', '#b8ccb8')
    elif w == 'rain':
        overcast(cv, 16, '#a4b8a8', '#8b8f96', 32, lump=(10, 22))
        for (x, y, wd) in ((20, 22, 40), (140, 20, 48)):
            cloud(cv, x, y, wd, '#b8ccb8', '#a4b8a8')
    elif w == 'storm':
        overcast(cv, 18, '#5b6470', '#4e3a8a', 33, lump=(10, 22), drop=(4, 8))
        overcast(cv, 7, '#4e3a8a', None, 34)
        for (x, y, wd) in ((60, 24, 44), (170, 26, 40)):
            cloud(cv, x, y, wd, '#8b8f96', '#5b6470')
    elif w == 'wind':
        for (x, y, wd) in ((24, 10, 56), (140, 16, 60), (96, 30, 30)):
            streak_cloud(cv, x, y, wd, '#f1ece0', '#cde6e8')
    elif w == 'heat':
        pass
    elif w == 'sun':
        cloud(cv, 30, 12, 36, '#f1ece0', '#cde6e8')
        cloud(cv, 150, 20, 28, '#f1ece0', '#cde6e8')
    bands(cv, P['sea'])
    # volcano isle right of centre
    vol = poly([(120, 46), (150, 24), (162, 24), (196, 46)])
    cv.fill(vol, P['vol'])
    cv.fill(vol & ~shift(vol, -4, 0), P['vols'])
    cv.fill(poly([(147, 27), (150, 24), (162, 24), (165, 27)]), P['crater'])
    if w in ('wind', 'storm'):        # the smoke is torn off to the left
        for (x, y, wd) in ((142, 20, 8), (130, 18, 10), (118, 17, 8)):
            cv.fill(ell(x, y, x + wd, y + 3), P['smoke'])
    elif w == 'heat':                 # it smokes harder on a hot still day
        for (x, y, wd) in ((150, 16, 8), (155, 9, 11), (162, 3, 10), (170, -2, 9)):
            cv.fill(ell(x, y, x + wd, y + wd * 2 // 3), P['smoke'])
    elif w != 'fog':
        for (x, y, wd) in ((150, 16, 8), (156, 10, 10), (164, 6, 8)):
            cv.fill(ell(x, y, x + wd, y + wd * 2 // 3), P['smoke'])
    cv.fill(rect(116, 45, 200, 46), P['strip'])
    for (x, wd) in ((124, 6), (132, 5), (186, 6)):
        cv.fill(ell(x, 40, x + wd, 46), P['bush'])
    # the sail: heeled in the wind, faded in rain and fog, home in harbour in the storm
    if w == 'wind':
        sail_boat(cv, 0.3)
    elif w == 'fog':
        sail_boat(cv, 0, '#f1ece0', '#cde6e8', '#a9d6ea')
    elif w == 'rain':
        sail_boat(cv, 0, '#c9c5bc', '#b8ccb8', '#8b8f96')
    elif w != 'storm':
        sail_boat(cv)
    ripples(cv, rect(0, 50, W - 1, 68), P['rip'][0], step=4, ln=4 if w not in ('wind', 'storm') else 6, seed=2)
    ripples(cv, rect(0, 70, W - 1, 78), P['rip'][1], step=4, ln=3, seed=5)
    if w == 'storm':        # breakers
        for (x, y) in ((20, 60), (70, 64), (110, 58), (160, 66), (204, 61), (40, 72), (140, 74), (220, 73)):
            cv.fill(poly([(x, y + 2), (x + 4, y), (x + 9, y + 2)]), '#f1ece0')
    if w == 'heat':
        shimmer(cv, 6, (44, 52), '#f2e4c0', step=3)
    if w == 'fog':
        fogs(cv, [(-20, 130, 41, 4), (100, 260, 47, 4), (-20, 100, 58, 3), (120, 260, 64, 3)], '#f1ece0')
    cv.stage()
    # --- beach
    foam = '#f1ece0'
    island_beach(cv, 84, '#c9a96e', '#e8cf98', foam)
    bmask = cv.stage()
    if w in ('rain', 'storm'):
        remap_in(cv, {'#e8cf98': '#c9a96e', '#c9a96e': '#9a6b3f', '#f2e4c0': '#e8cf98'}, bmask)
        cv.fill(top_edge(wave(78, [(1.5, 60, 0.7), (1, 23, 2.0)]), 2), foam)
        puddles(cv, [(28, 104, 20), (120, 98, 16), (176, 108, 24), (76, 112, 12)], '#7fbcd8', '#3f8fb0', '#cde6e8')
    elif w == 'heat':
        remap_in(cv, {'#e8cf98': '#f2e4c0', '#c9a96e': '#e8cf98'}, bmask)
        shimmer(cv, 8, (90, 112), '#f1ece0', step=6, xs=(30, 210))
    elif w == 'cloud':
        remap_in(cv, {'#f2e4c0': '#c9a96e'}, bmask)
    elif w == 'wind':       # sand blown in flat streaks
        for (x, y, ln) in ((40, 90, 14), (120, 96, 18), (196, 92, 12), (80, 108, 16), (170, 112, 12), (230, 102, 10)):
            cv.fill(rect(x - ln, y, x, y) | rect(x - ln - 5, y - 1, x - ln - 2, y - 1), '#f2e4c0')
    elif w == 'fog':
        fogs(cv, [(0, 120, 80, 2), (130, 240, 82, 2)], '#e6efe6', 1)
    cv.stage()
    # --- palms
    if w in ('wind', 'storm'):
        palm_blown(cv, (8, 116), (0, 70), (22, 28))
        palm_blown(cv, (234, 116), (244, 76), (212, 34))
    elif w == 'heat':
        lf = ramp('#a4b86a', '#7ab55c', '#e8cf98')
        palm(cv, (8, 116), (0, 70), (24, 26), w0=8, w1=5, fronds=PALM_HEAT, leaf=lf)
        palm(cv, (234, 116), (244, 76), (216, 32), w0=8, w1=5, fronds=PALM_HEAT_R, leaf=lf)
    else:
        palm(cv, (8, 116), (0, 70), (24, 26), w0=8, w1=5, fronds=PALM_L)
        palm(cv, (234, 116), (244, 76), (216, 32), w0=8, w1=5, fronds=PALM_R)
    # foreground corners
    for (x, y) in ((28, 118), (34, 122)):
        coconut(cv, x, y)
    starfish(cv, 50, 126)
    shell(cv, 70, 124)
    shell(cv, 172, 126, ramp('#f2e4c0', '#c9a96e', '#fff3c8'))
    starfish(cv, 196, 122, ramp('#e46a9b', '#b8457a', '#f6b8cf'))
    if w in ('wind', 'storm'):
        for (x, yb, h, n) in ((214, 130, 9, 6), (12, 132, 8, 5)):
            for k in range(n):
                dx = (k - n // 2) * 2
                cv.fill(line([(x + dx // 2, yb), (x + dx // 2 - 2, yb - h // 2), (x + dx // 2 - 5, yb - h + 2 + abs(dx) // 2)]),
                        '#4f9a45' if k % 2 else '#7ab55c')
    else:
        gc = ('#7ab55c', '#a4b86a') if w == 'heat' else ('#4f9a45', '#7ab55c')
        grass_clump(cv, 214, 130, gc[0], gc[1], 9, 6)
        grass_clump(cv, 12, 132, gc[0], gc[1], 8, 5)
    cv.stage()
    # --- weather marks
    if w in ('sun', 'heat'):
        birds(cv, [(96, 16), (106, 12), (204, 18)], '#5b6470')
    if w == 'cloud':
        birds(cv, [(96, 22), (106, 18)], '#8b8f96')
    if w == 'wind':
        birds(cv, [(100, 26), (112, 30)], '#5b6470')
        gusts(cv, 71, 9, '#f1ece0', ys=(10, 44), xs=(50, 200))
        flying(cv, 72, 16, ['#7ab55c', '#4f9a45', '#a4b86a'], ys=(20, 80), xs=(30, 200))
    if w == 'rain':
        streaks(cv, 81, 230, '#dfe9d0', '#8b8f96', ys=(0, 118), ln=5, slant=2)
        rain_rings(cv, [(36, 106), (128, 100), (186, 110), (60, 70), (140, 64), (200, 72)], '#cde6e8')
    if w == 'storm':
        bolt(cv, 104, 12, 46, 4)
        bolt(cv, 30, 18, 40, 8, fork=False)
        streaks(cv, 82, 330, '#a9d6ea', '#8b8f96', ys=(0, 122), ln=6, slant=3)
        streaks(cv, 83, 60, '#c9c5bc', None, ys=(0, 46), ln=7, slant=3)
        flying(cv, 84, 12, ['#7ab55c', '#4f9a45'], ys=(30, 80), xs=(30, 200))
    if w == 'fog':
        fogs(cv, [(-30, 50, 30, 3), (190, 270, 44, 3), (-20, 30, 70, 3), (210, 260, 66, 3)], '#f1ece0', 2)
    cv.remap({'#fff3c8': '#f2e4c0', '#a8241f': '#b8457a'} | ({'#c9c5bc': '#f1ece0'} if w in ('sun', 'wind', 'heat') else {}))
    return cv


# ------------------------------------------------------------------ registry, checks, maps
STAGES = {}
for _w in ('cloud', 'storm', 'heat', 'wind', 'fog'):
    STAGES['rainforest-' + _w] = (rainforest_w, _w)
for _w in ('cloud', 'rain', 'storm', 'frost', 'wind', 'fog'):
    STAGES['tundra-' + _w] = (tundra_w, _w)
for _w in ('cloud', 'rain', 'storm', 'heat', 'wind', 'fog'):
    STAGES['island-' + _w] = (island_w, _w)

WEATHER_MAP = {
    'rainforest': {'sun': 'rainforest', 'cloud': 'rainforest-cloud', 'rain': 'rainforest-v3', 'storm': 'rainforest-storm',
                   'frost': 'rainforest-fog', 'heat': 'rainforest-heat', 'wind': 'rainforest-wind', 'fog': 'rainforest-fog',
                   'snow': 'rainforest-fog'},
    'tundra': {'sun': 'tundra', 'cloud': 'tundra-cloud', 'rain': 'tundra-rain', 'storm': 'tundra-storm', 'frost': 'tundra-frost',
               'heat': 'tundra', 'wind': 'tundra-wind', 'fog': 'tundra-fog', 'snow': 'tundra-v3'},
    'island': {'sun': 'island', 'cloud': 'island-cloud', 'rain': 'island-rain', 'storm': 'island-storm', 'frost': 'island-cloud',
               'heat': 'island-heat', 'wind': 'island-wind', 'fog': 'island-fog', 'snow': 'island-rain'},
}


def check(cv):
    cols = {tuple(p) for p in cv.px.reshape(-1, 3)}
    bad = [c for c in cols if c in ((0, 0, 0), (255, 255, 255))]
    return len(cols), bad


if __name__ == '__main__':
    scenes = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'game', 'assets', 'img', 'scenes'))
    out = sys.argv[1] if len(sys.argv) > 1 else scenes
    only = sys.argv[2:] or list(STAGES)
    for k in only:
        fn, w = STAGES[k]
        cv = fn(w)
        folded = fold(cv, 32)
        n, bad = check(cv)
        p = os.path.join(out, 'stage-' + k + '.png')
        cv.save(p)
        print(k, 'colours', n, 'folded', folded if folded else '-', 'BAD' if bad else '', '->', os.path.normpath(p))
    for land, mp in WEATHER_MAP.items():
        for f in mp.values():
            assert os.path.exists(os.path.join(scenes, 'stage-' + f + '.png')) or f in STAGES, f
        with open(os.path.join(out, 'stage-weather-' + land + '.json'), 'w') as fh:
            json.dump(mp, fh, indent=1)
            fh.write('\n')
