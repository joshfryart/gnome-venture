"""Weather stage backdrops for grassland, forest and coast (2026-10-27):
game/assets/img/scenes/stage-<land>-<weather>.png, weather in cloud storm frost heat wind fog snow.

Usage: python3 -B aseprite-source/scenes-pil/stages_weather_grass_forest_coast.py [out_dir] [name ...]
       names: grassland-cloud ... coast-snow (default all 21)
Each is the v1 (sun, stage-<land>.png) composition from stages_grass_forest_coast.py redrawn with the same horizon,
lane, centrepiece and stand spots; only the sky, light, ground cover, particles and a few small props change.
Rain is not drawn here: stage-<land>-v3.png already is the rain scene. stage-weather-<land>.json maps all nine
HOLLOW_WEATHER keys to a file key (see WEATHER_MAP at the bottom; written next to the PNGs).
Same rules as the v1 kit: 240 x 135 grid at 2x, opaque, hard pixels, <= 32 colours, ground open from y 86.
"""
import json
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import (Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, hx, W, H)  # noqa: E402
from shops import (WOOD, DWOOD, CREAM, STONE, LEAF, MOSS)  # noqa: E402
from stops import (bands, wave, cloud, tufts, ripples)  # noqa: E402
from stages_grass_forest_coast import (  # noqa: E402
    CANVAS, BURLAP, ROOF, BARK, OAK, SHROOM, GROUND_Y, rock, sun, flowers, puddle, birds, far_fence, grass_edge,
    sheep, signpost, toadstool, stump, trunk, rnd, back_trunks, undergrowth, lighthouse, headland, beach, starfish,
    shells, boat_beached, sail, fern)

WEATHERS = ['cloud', 'storm', 'frost', 'heat', 'wind', 'fog', 'snow']
SNOW = '#f1ece0'
SNOW_S = '#cde6e8'
ICE = '#cde6e8'


# ------------------------------------------------------------------ weather effects (hard pixels, no blends)
def streaks(cv, col, y0=0, y1=H - 1, step=11, seed=0, ln=3, slant=1, gap=(12, 22), clear=None):
    """Rain: 1 px slanted streaks on a loose staggered grid between y0 and y1."""
    m = blank()
    r = rnd(seed + 40)
    for y in range(y0 - 4, y1, step):
        x = r(0, 16) - 10
        while x < W + 10:
            m |= line([(x, y), (x - slant, y + ln)])
            x += r(*gap)
    m &= rect(0, y0, W - 1, y1)
    if clear is not None:
        m &= ~clear
    cv.fill(m, col)


def snowfall(cv, col, y0=0, y1=H - 1, step=9, seed=0, big=False, clear=None, gap=(10, 20)):
    """Flakes: single pixels (far) or 2 x 2 plus-ish flakes (near) on a staggered grid."""
    r = rnd(seed + 90)
    pts = []
    for y in range(y0, y1, step):
        x = r(0, 14) - 4
        while x < W + 4:
            pts.append((x, y + r(-2, 2)))
            x += r(*gap)
    m = blank()
    for (x, y) in pts:
        if big:
            m |= rect(x, y, x + 1, y + 1) | rect(x + 1, y - 1, x + 1, y - 1)
        else:
            m |= rect(x, y, x, y)
    m &= rect(0, y0, W - 1, y1)
    if clear is not None:
        m &= ~clear
    cv.fill(m, col)


def bolt(cv, pts, core='#fff3c8', glow='#f5cf6a', fork=None):
    """Lightning: a 1 px core zigzag inside a 3 px glow, optional side fork."""
    g = line(pts, 3)
    c = line(pts, 1)
    if fork:
        g |= line(fork, 3)
        c |= line(fork, 1)
    cv.fill(g, glow)
    cv.fill(c, core)


def fog_band(cv, y, h, col, seed=0, amp=2, x0=0, x1=W - 1):
    """A soft-edged (stepped) fog ribbon: a wavy top and bottom."""
    top = wave(y, [(amp, 37 + seed * 3, seed * 0.7), (1, 13, seed)], x0, x1)
    bot = wave(y + h, [(amp, 41 + seed * 5, seed * 1.3 + 1), (1, 17, seed + 2)], x0, x1)
    m = top & ~bot
    cv.fill(m, col)
    return m


def swoosh(cv, x, y, ln, col, curl=True, up=False):
    """A wind line: a long gentle stroke that curls up (or down) at its head."""
    pts = [(x + i, y + round(1.5 * math.sin(i / ln * math.pi))) for i in range(0, ln, 3)] + [(x + ln, y)]
    m = line(pts)
    if curl:
        s = -1 if up else 1
        hx_, hy = x + ln, y
        m |= line([(hx_, hy), (hx_ + 3, hy - 1 * s), (hx_ + 4, hy - 3 * s), (hx_ + 2, hy - 5 * s), (hx_, hy - 4 * s)])
    cv.fill(m, col)


def flying_leaves(cv, pts, cols):
    """Leaves tumbling on the wind: little 5-pixel lozenges with a dark midrib pixel, alternating tilt."""
    for i, (x, y) in enumerate(pts):
        c = cols[i % len(cols)]
        if i % 3 == 0:
            cv.dots([(x, y), (x + 1, y), (x + 2, y - 1), (x + 3, y - 1), (x + 1, y - 1), (x + 2, y)], c)
        elif i % 3 == 1:
            cv.dots([(x, y - 1), (x + 1, y - 1), (x + 1, y), (x + 2, y), (x + 3, y + 1), (x + 2, y + 1)], c)
        else:
            cv.dots([(x, y), (x + 1, y - 1), (x + 1, y), (x + 2, y - 1), (x + 1, y + 1)], c)


def shimmer(cv, y0, y1, col, seed=0, step=4, clear=None):
    """Heat haze: short wavy dashes in rows, each row offset (a mirage ripple, hard pixels)."""
    r = rnd(seed + 7)
    m = blank()
    for y in range(y0, y1, step):
        x = r(0, 18)
        while x < W:
            w = r(6, 12)
            m |= rect(x, y, x + w // 2, y) | rect(x + w // 2 + 1, y - 1, x + w, y - 1)
            x += w + r(10, 22)
    m &= rect(0, y0 - 1, W - 1, y1)
    if clear is not None:
        m &= ~clear
    cv.fill(m, col)


def specks(cv, mask, col, seed=0, step=5, gap=(6, 13), shape='tick'):
    """Frost rime / sparkle: tiny marks scattered over a mask on a staggered grid."""
    ys, xs = mask.nonzero()
    if not len(ys):
        return
    r = rnd(seed + 3)
    m = blank()
    for y in range(ys.min() + 1, ys.max() + 1, step):
        x = r(0, 8)
        while x < W:
            if shape == 'tick':
                m |= rect(x, y, x + 1, y) | rect(x + 1, y - 1, x + 1, y - 1)
            elif shape == 'star':
                m |= rect(x, y - 1, x, y + 1) | rect(x - 1, y, x + 1, y)
            else:
                m |= rect(x, y, x, y)
            x += r(*gap)
    cv.fill(m & mask, col)


def cap(cv, m, k=3, col=SNOW, sh=SNOW_S, drips=True):
    """Snow (or rime) lying on the top k rows of a shape, with a shaded lower lip and a few lumps."""
    top = m & ~shift(m, 0, k)
    if drips:
        ys, xs = m.nonzero()
        if len(xs):
            for x in range(xs.min() + 2, xs.max(), 5):
                top |= m & rect(x, 0, x + 1, H) & ~shift(m, 0, k + 2)
    cv.fill(top, col)
    lip = top & ~shift(top, 0, -1) & shift(m, 0, -1)
    cv.fill(lip, sh)
    return top


def tint(cv, mask, table, default=None):
    """Recolour pixels under mask through a colour table (fog / frost wash; still hard pixels in palette)."""
    px = cv.px
    out = px.copy()
    for a, b in table.items():
        sel = mask & (px[:, :, 0] == hx(a)[0]) & (px[:, :, 1] == hx(a)[1]) & (px[:, :, 2] == hx(a)[2])
        out[sel] = hx(b)
    if default:
        keep = blank()
        for a in table:
            keep |= (px[:, :, 0] == hx(a)[0]) & (px[:, :, 1] == hx(a)[1]) & (px[:, :, 2] == hx(a)[2])
        out[mask & ~keep] = hx(default)
    cv.px[:] = out


def veil(cv, mask, fog, amount=0.5, extra=()):
    """See-through fog under a mask: each colour moves `amount` toward the fog colour, snapped to a colour already in
    the scene (or in extra), so the wash stays hard-pixel and in palette."""
    import numpy as np
    flat = cv.px.reshape(-1, 3)
    cols = np.unique(flat, axis=0).astype(int)
    cands = np.vstack([cols] + [np.array([hx(c) for c in extra], int).reshape(-1, 3)] if extra else [cols])
    f = np.array(hx(fog), int)
    out = cv.px.copy()
    for c in cols:
        t = c + (f - c) * amount
        d = ((cands - t) ** 2).sum(1)
        # never snap back to itself unless it already is the fog
        d[np.all(cands == c, axis=1)] = 1e9 if not np.all(c == f) else 0
        n = cands[int(d.argmin())]
        sel = mask & np.all(cv.px == c.astype(np.uint8), axis=2)
        out[sel] = n.astype(np.uint8)
    cv.px[:] = out


def cap_colours(cv, n=32, keep=()):
    """Fold the least-used colours into their nearest kept colour until the scene has n or fewer."""
    import numpy as np
    flat = cv.px.reshape(-1, 3)
    cols, counts = np.unique(flat, axis=0, return_counts=True)
    if len(cols) <= n:
        return []
    keep_t = {hx(c) for c in keep}
    order = sorted(range(len(cols)), key=lambda i: counts[i])
    drop = [i for i in order if tuple(int(v) for v in cols[i]) not in keep_t][:len(cols) - n]
    kept = [i for i in range(len(cols)) if i not in drop]
    folded = []
    for i in drop:
        c = cols[i].astype(int)
        j = min(kept, key=lambda k: int(((cols[k].astype(int) - c) ** 2).sum()))
        m = np.all(cv.px == cols[i], axis=2)
        cv.px[m] = cols[j]
        folded.append(('#%02x%02x%02x' % tuple(cols[i]), '#%02x%02x%02x' % tuple(cols[j]), int(counts[i])))
    return folded


def flat_cloud(cv, x, y, w, col, sh):
    """A long wind-stretched cloud: two thin flat lozenges, a shade line under them."""
    m = ell(x, y, x + w, y + 5) | ell(x + w // 4, y - 2, x + w * 3 // 4, y + 3) | ell(x + w // 2, y + 3, x + w + w // 3, y + 7)
    cv.fill(m, col)
    cv.fill(m & ~shift(m, 0, -1), sh)


def heavy_cloud(cv, x, y, w, col, sh, deep=None):
    """A big low cumulus bank for overcast / storm skies: three humps, a flat shaded base."""
    h = max(8, w // 3)
    m = ell(x, y + h // 3, x + w, y + h + 6) | ell(x + w // 8, y, x + w * 5 // 8, y + h + 2) | ell(x + w * 2 // 5, y - h // 4, x + w * 9 // 10, y + h)
    m &= rect(0, 0, W, y + h + 3)
    cv.fill(m, col)
    cv.fill(m & ~shift(m, 0, -3), sh)
    if deep:
        cv.fill(m & ~shift(m, 0, -1), deep)
    return m


def ceiling(cv, y, col, sh, seed=0, lumps=(18, 34)):
    """A storm-cloud ceiling: solid above, a scalloped underside of hanging lumps, each lump shaded at its base."""
    r = rnd(seed + 50)
    m = rect(0, 0, W - 1, y)
    x = -10
    while x < W + 10:
        w = r(*lumps)
        d = r(3, 9)
        m |= ell(x, y - 8, x + w, y + d)
        x += w - r(4, 9)
    cv.fill(m, col)
    cv.fill(m & ~shift(m, 0, -2), sh)
    return m


def hat(cv, x, y, tilt=0.6, rp=ROOF):
    """A gnome's red cone hat blown off and tumbling: cone with a drooping tip and a cream brim (outlined)."""
    ca, sa = math.cos(tilt), math.sin(tilt)

    def P(pts):
        return [(round(x + px * ca - py * sa), round(y + px * sa + py * ca)) for (px, py) in pts]
    cone = P([(-7, 0), (7, 0), (4, -8), (1, -14), (-2, -17), (-7, -18), (-4, -14), (-4, -8)])
    brim = P([(-8, -1), (8, -1), (8, 2), (-8, 2)])
    o = cv.obj()
    o.part(poly(cone), rp, d=2)
    o.part(poly(brim), CREAM, d=1, contour=True)
    o.draw()


def kite(cv, x, y, tail):
    o = cv.obj()
    o.part(poly([(x, y - 7), (x + 5, y), (x, y + 9), (x - 5, y)]), ROOF, d=1)
    o.draw()
    cv.fill(line([(x, y - 6), (x, y + 8)]) | line([(x - 4, y), (x + 4, y)]), '#f5cf6a')
    pts = [(x, y + 9)] + tail
    cv.fill(line(pts), '#5c3420')
    for (bx, by) in tail[1::2]:
        cv.fill(rect(bx - 1, by - 1, bx + 1, by), '#f5cf6a')


def mask_of(cv, col):
    import numpy as np
    return np.all(cv.px == hx(col), axis=2)


# ------------------------------------------------------------------ shared tree / clump drawing with weather options
def oak_w(cv, x, y, w, h, leaf=OAK, trunk_rp=BARK, snow=False, lean=0, rime=None):
    """The lone oak of stage-grassland.png; snow = caps on every clump; lean = crown pushed right (wind)."""
    cx = x + w // 2
    o = cv.obj()
    o.part(poly([(cx - 5, y + h - 8), (cx + 5, y + h - 8), (cx + 6, y + h + 16), (cx + 12, y + h + 19), (cx - 12, y + h + 19), (cx - 6, y + h + 16)]), trunk_rp, d=2)
    o.part(line([(cx + 2, y + h - 4), (cx + 14, y + h - 14)], 3), trunk_rp, d=0)
    o.draw()
    o = cv.obj()
    clumps = [(0.0, 0.42, 0.42, 0.95), (0.58, 0.40, 1.0, 0.92), (0.08, 0.12, 0.55, 0.62), (0.45, 0.08, 0.92, 0.6),
              (0.26, 0.0, 0.74, 0.42), (0.22, 0.45, 0.78, 1.0)]
    ms = []
    for (a, b, c, d) in clumps:
        dx = round(lean * (1 - (b + d) / 2) * 1.6)                     # upper clumps blow further
        m = ell(round(x + w * a) + dx, round(y + h * b), round(x + w * c) + dx, round(y + h * d))
        o.part(m, leaf, d=3)
        ms.append(m)
    u = o.draw()
    for (a, b) in ((0.2, 0.55), (0.42, 0.28), (0.66, 0.5), (0.5, 0.72), (0.8, 0.66)):
        px, py = round(x + w * a) + round(lean * (1 - b) * 1.6), round(y + h * b)
        cv.fill(line([(px, py), (px + 3, py - 2)]), leaf['s'])
    if snow:
        tops = blank()
        for i, m in enumerate(ms):
            above = blank()
            for j in range(i + 1, len(ms)):
                above |= ms[j]
            tops |= (m & ~above) & ~shift(m & ~above, 0, 3)
        tops &= u
        cv.fill(tops, SNOW)
        cv.fill(tops & ~shift(tops, 0, -1) & shift(u, 0, -1), SNOW_S)
    if rime:
        cv.fill(u & ~shift(u, 1, 1), rime)
    return u


def bush_w(cv, x, y, w, rp=OAK, berries=None, snow=False, rime=None):
    o = cv.obj()
    m = ell(x, y + w // 5, x + w * 3 // 5, y + w // 2 + 2) | ell(x + w * 2 // 5, y + w // 6, x + w, y + w // 2 + 2) | ell(x + w // 5, y, x + w * 4 // 5, y + w // 2)
    o.part(m, rp, d=2)
    o.draw()
    if berries:
        for (dx, dy) in ((0.25, 0.25), (0.55, 0.15), (0.75, 0.32), (0.4, 0.38)):
            cv.fill(rect(x + round(w * dx), y + round(w * dy), x + round(w * dx) + 1, y + round(w * dy) + 1), berries)
    if snow:
        cap(cv, m, 3)
    if rime:
        cv.fill(m & ~shift(m, 1, 1), rime)
    return m


def clump_w(cv, x, ybot, heads, seed=0, w=26, lean=0, stem='#2f6a3a', lite='#7ab55c', head_ok=True):
    """meadow_clump with a wind lean and weather colours (dry stalks for snow / heat)."""
    r = rnd(seed + 11)
    for i in range(w // 2):
        bx = x + r(0, w)
        h = r(6, 14)
        ln_ = r(-3, 3)
        if lean:
            ln_ = lean + r(0, 2)
            h = max(4, h - abs(lean) // 2)
        cv.fill(line([(bx, ybot), (bx + ln_ // 2, ybot - h // 2), (bx + ln_, ybot - h)]), stem if i % 3 else lite)
        if i % 3 == 0 and head_ok:
            hx_, hy = bx + ln_, ybot - h - 1
            c = heads[i % len(heads)]
            cv.fill(rect(hx_ - 1, hy - 1, hx_ + 1, hy + 1), c)
            cv.dots([(hx_, hy)], '#e8a317' if c != '#e8a317' else '#b07a10')


def tufts_w(cv, pts, col, lean=0):
    for (x, y) in pts:
        if lean:
            cv.dots([(x, y), (x + 1, y - 1), (x + 2, y), (x + 3, y - 1), (x + 4, y - 2), (x + 2, y - 2)], col)
        else:
            cv.dots([(x, y), (x + 2, y), (x + 1, y - 1), (x - 1, y - 2), (x + 3, y - 2)], col)


def snowman(cv, x, ybot):
    o = cv.obj()
    o.part(ell(x - 6, ybot - 11, x + 6, ybot), ramp(SNOW, '#c9c5bc', None), d=2)
    o.part(ell(x - 4, ybot - 18, x + 4, ybot - 10), ramp(SNOW, '#c9c5bc', None), d=2, contour=True)
    o.part(rect(x - 5, ybot - 12, x + 5, ybot - 11), ramp('#d6322b', '#a8241f', None), d=0, contour=True)
    o.draw()
    cv.dots([(x - 2, ybot - 15), (x + 1, ybot - 15)], '#3d2a1c')
    cv.dots([(x, ybot - 13), (x + 1, ybot - 13), (x + 2, ybot - 13)], '#f08a24')
    cv.fill(line([(x - 6, ybot - 7), (x - 11, ybot - 11)]) | line([(x + 6, ybot - 7), (x + 11, ybot - 12)]), '#5c3420')


# ------------------------------------------------------------------ GRASSLAND (v1: the lone oak at the end of the path)
GRASS = {
    'sun': dict(sky=[(0, '#7fbcd8'), (14, '#a9d6ea'), (30, '#cde6e8'), (44, '#e6efd8')],
                far='#b9cf8e', field='#e8cf98', mid='#a4b86a', hedge='#7ab55c', near='#4f9a45', farm='#7ab55c',
                path='#c9a96e', path_s='#9a6b3f', oak=OAK, bush=OAK, t1='#4f9a45', t2='#2f6a3a'),
    'cloud': dict(sky=[(0, '#a3abb3'), (20, '#c9c5bc'), (38, '#dcdccf')],
                  far='#9fb59a', field='#c9b48e', mid='#8fa86a', hedge='#6f9a5a', near='#4f9a45', farm='#6f9a5a',
                  path='#c9a96e', path_s='#9a6b3f', oak=OAK, bush=OAK, t1='#2f6a3a', t2='#2f6a3a'),
    'storm': dict(sky=[(0, '#8b8f96'), (40, '#a3abb3')],
                  far='#6f8a7a', field='#8b8f96', mid='#5f8a55', hedge='#4f7a4a', near='#2f6a3a', farm='#4f7a4a',
                  path='#9a6b3f', path_s='#7a4a1f', oak=ramp('#2f6a3a', '#1f3f3a', '#4f9a45'),
                  bush=ramp('#2f6a3a', '#1f3f3a', '#4f9a45'), t1='#1f3f3a', t2='#1f3f3a'),
    'frost': dict(sky=[(0, '#a9d6ea'), (16, '#cde6e8'), (34, '#e6efd8'), (46, '#f1ece0')],
                  far='#c3cdb6', field='#dcdccf', mid='#a3b59a', hedge='#7f9a8a', near='#6f9a5a', farm='#a3b59a',
                  path='#c9c5bc', path_s='#8b8f96', oak=ramp('#6f9a5a', '#2f6a3a', '#cde6e8'),
                  bush=ramp('#6f9a5a', '#2f6a3a', '#cde6e8'), t1='#cde6e8', t2='#4f7a4a'),
    'heat': dict(sky=[(0, '#a9d6ea'), (12, '#cde6e8'), (26, '#f2e4c0'), (40, '#f6d9b0')],
                 far='#e8cf98', field='#f2e4c0', mid='#c9b46e', hedge='#a4b86a', near='#a4b86a', farm='#c9b46e',
                 path='#e8cf98', path_s='#c9a96e', oak=OAK, bush=OAK, t1='#7ab55c', t2='#4f9a45'),
    'wind': dict(sky=[(0, '#7fbcd8'), (14, '#a9d6ea'), (30, '#cde6e8'), (44, '#e6efd8')],
                 far='#b9cf8e', field='#e8cf98', mid='#a4b86a', hedge='#7ab55c', near='#4f9a45', farm='#7ab55c',
                 path='#c9a96e', path_s='#9a6b3f', oak=OAK, bush=OAK, t1='#7ab55c', t2='#2f6a3a'),
    'fog': dict(sky=[(0, '#c9c5bc'), (18, '#d6dccb'), (36, '#dcdccf')],
                far='#d6dccb', field='#dcdccf', mid='#c3cdb6', hedge='#a3b59a', near='#4f9a45', farm='#6f9a5a',
                path='#c9a96e', path_s='#9a6b3f', oak=ramp('#6f9a5a', '#4f7a4a', '#8fa86a'),
                bush=ramp('#6f9a5a', '#4f7a4a', '#8fa86a'), t1='#2f6a3a', t2='#2f6a3a'),
    'snow': dict(sky=[(0, '#8b8f96'), (14, '#a3abb3'), (30, '#c9c5bc')],
                 far='#e6efd8', field='#dcdccf', mid=SNOW, hedge='#4f7a4a', near=SNOW, farm='#dcdccf',
                 path='#c9c5bc', path_s='#a3abb3', oak=ramp('#4f7a4a', '#1f3f3a', '#6f9a5a'),
                 bush=ramp('#4f7a4a', '#1f3f3a', '#6f9a5a'), t1='#c9c5bc', t2='#a3abb3'),
}


def grassland_w(wx):
    P = GRASS[wx]
    cv = Canvas()
    bands(cv, P['sky'])
    sky = rect(0, 0, W - 1, 70)
    # ---- sky
    if wx == 'sun':
        sun(cv, 200, 16, 9)
        for (x, y, w) in ((18, 12, 36), (150, 22, 28), (80, 6, 22)):
            cloud(cv, x, y, w, '#f1ece0', '#cde6e8')
        birds(cv, [(64, 22), (76, 18)])
    elif wx == 'cloud':
        for (x, y, w) in ((-10, 10, 60), (44, 2, 70), (120, 8, 56), (178, 0, 70), (20, 26, 40), (150, 28, 44)):
            heavy_cloud(cv, x, y, w, '#dcdccf', '#a3abb3')
        birds(cv, [(64, 40), (76, 36)], '#5b6470')
    elif wx == 'storm':
        ceiling(cv, 18, '#5b6470', '#4e3a8a', seed=1)
        for (x, y, w) in ((20, 32, 40), (150, 36, 36)):
            flat_cloud(cv, x, y, w, '#5b6470', '#4e3a8a')
        bolt(cv, [(196, 30), (190, 38), (198, 42), (188, 50), (194, 52), (186, 60)], fork=[(190, 38), (180, 44), (178, 50)])
        bolt(cv, [(34, 34), (38, 42), (33, 46), (39, 56)])
    elif wx == 'frost':
        sun(cv, 200, 22, 8, '#fff3c8', '#f1ece0')
        flat_cloud(cv, 20, 14, 40, '#f1ece0', '#cde6e8')
        flat_cloud(cv, 150, 30, 30, '#f1ece0', '#cde6e8')
    elif wx == 'heat':
        sun(cv, 200, 16, 12, '#fff3c8', '#f1ece0')
        for k in range(8):                                               # stepped rays round the sun
            a = k * math.pi / 4 + 0.2
            x0, y0 = 200 + 15 * math.cos(a), 16 + 15 * math.sin(a)
            x1, y1 = 200 + 20 * math.cos(a), 16 + 20 * math.sin(a)
            cv.fill(line([(round(x0), round(y0)), (round(x1), round(y1))], 2), '#f5cf6a')
        flat_cloud(cv, 30, 10, 26, '#f1ece0', '#cde6e8')
        birds(cv, [(64, 24)], '#9a6b3f')
    elif wx == 'wind':
        for (x, y, w) in ((6, 10, 44), (110, 4, 50), (150, 26, 40), (60, 20, 30), (196, 12, 36)):
            flat_cloud(cv, x, y, w, '#f1ece0', '#cde6e8')
        for (x, y, ln) in ((14, 34, 26), (150, 40, 30), (60, 4, 24), (196, 2, 22)):
            swoosh(cv, x, y, ln, '#f1ece0')
        birds(cv, [(40, 26), (54, 30)])
    elif wx == 'fog':
        sun(cv, 200, 18, 8, '#f1ece0', '#f1ece0')
        cv.fill(rect(0, 14, W - 1, 15) | rect(0, 26, W - 1, 27), '#dcdccf')
    elif wx == 'snow':
        for (x, y, w) in ((-10, 4, 60), (44, -2, 70), (120, 4, 56), (178, -2, 70)):
            heavy_cloud(cv, x, y, w, '#a3abb3', '#8b8f96')
    # ---- far hills, fields, mid hill
    far = wave(56, [(4, 96, 0.4), (2, 41, 1.2)])
    cv.fill(far, P['far'])
    for x0 in range(-24, W, 30):
        cv.fill(far & poly([(x0, 40), (x0 + 12, 40), (x0 + 4, 80), (x0 - 8, 80)]), P['field'])
    if wx == 'snow':
        cv.fill(far & ~shift(far, 0, 1), SNOW)
    mid = wave(68, [(4, 130, 2.0), (2, 47, 0.6)])
    cv.fill(mid, P['mid'])
    if wx == 'frost':
        cv.fill(far & ~shift(far, 0, 1), '#f1ece0')
        cv.fill(mid & ~shift(mid, 0, 1), '#cde6e8')
    for (x, w) in ((4, 12), (18, 16), (196, 14), (212, 18), (228, 12)):
        m = ell(x, 62, x + w, 62 + w)
        cv.fill(m, P['hedge'])
        if wx == 'snow':
            cv.fill(m & ~shift(m, 0, 2), SNOW)
        if wx == 'frost':
            cv.fill(m & ~shift(m, 0, 1), '#cde6e8')
    far_fence(cv, 150, 200, 74, P['hedge'] if wx not in ('snow',) else '#9a6b3f')
    if wx in ('sun', 'cloud', 'frost', 'wind', 'heat'):
        for (x, y) in ((168, 66), (182, 70), (40, 70)):
            sheep(cv, x, y)
    if wx == 'heat':
        shimmer(cv, 60, 78, '#f6d9b0', seed=2, step=5)
    # ---- the meadow
    top = GROUND_Y - 6
    cv.fill(rect(0, top, W - 1, H - 1), P['farm'])
    cv.fill(rect(0, top + 22, W - 1, H - 1), P['near'])
    grass_edge(cv, top + 22, P['near'] if wx != 'snow' else '#dcdccf')
    pm = poly([(114, top), (126, top), (150, H), (90, H)])
    cv.fill(pm, P['path'])
    cv.fill(pm & ~shift(pm, -2, 0), P['path_s'])
    cv.fill(pm & rect(0, top, W, top), P['path_s'])
    if wx != 'snow':
        grass_edge(cv, top, P['farm'])
    else:
        cv.fill(rect(0, top, W - 1, top) & ~pm, '#dcdccf')
    if wx == 'heat':                                                     # baked, cracked path
        for (x, y) in ((112, 88), (120, 96), (108, 104), (128, 110), (116, 120), (134, 126), (104, 128)):
            cv.fill(line([(x, y), (x + 3, y + 1), (x + 5, y)]), P['path_s'])
        cv.fill(ell(96, 78, 150, 90) & ~pm & rect(0, top + 1, W, H), '#7ab55c')     # the oak's pool of shade
    if wx == 'frost':                                                    # silvered meadow
        field = rect(0, top, W - 1, H - 1) & ~pm
        specks(cv, field & rect(0, top, W, top + 21), '#e6efd8', seed=4, step=4, gap=(7, 14))
        specks(cv, field & rect(0, top + 23, W, H), '#cde6e8', seed=5, step=6, gap=(12, 22))
    if wx == 'snow':
        for (x, y) in ((116, 86), (121, 92), (113, 99), (124, 106), (114, 114), (126, 122), (112, 129)):
            cv.fill(rect(x, y, x + 1, y + 1), '#a3abb3')                # footprints up the lane
        for (x, w) in ((-6, 40), (60, 30), (170, 34), (214, 34)):        # drifts
            cv.fill(ell(x, top + 26, x + w, top + 36) & ~pm, '#e6efd8')
    # ---- centrepiece: the lone oak with a hedge either side
    snow = wx == 'snow'
    rime = '#cde6e8' if wx == 'frost' else None
    bush_w(cv, 84, 66, 22, rp=P['bush'], berries=None if wx in ('storm', 'fog') else '#e46a9b' if wx != 'snow' else '#d6322b', snow=snow, rime=rime)
    bush_w(cv, 138, 68, 20, rp=P['bush'], snow=snow, rime=rime)
    lean = 6 if wx == 'wind' else 2 if wx == 'storm' else 0
    oak_w(cv, 92, 14, 58, 52, leaf=P['oak'], snow=snow, lean=lean, rime=rime)
    if wx == 'snow':
        snowman(cv, 152, GROUND_Y - 5)
    # ---- meadow life, low and off the stand spots
    tl = 1 if wx in ('wind', 'storm') else 0
    pts1 = [(20, 94), (60, 100), (180, 92), (210, 104), (100, 88), (148, 96), (36, 122), (200, 126), (8, 108), (232, 96)]
    pts2 = [(24, 124), (66, 128), (170, 120), (222, 130), (160, 132), (12, 132)]
    tufts_w(cv, pts1, P['t1'], tl)
    tufts_w(cv, pts2, P['t2'], tl)
    if wx in ('sun', 'cloud', 'wind'):
        flowers(cv, [(14, 90), (50, 92), (80, 104), (164, 102), (196, 90), (226, 108), (30, 112), (186, 112)],
                ['#f5cf6a', '#f2e4c0', '#e46a9b'])
        flowers(cv, [(6, 120), (44, 126), (78, 118), (162, 124), (210, 118), (234, 126), (24, 130), (190, 130)],
                ['#e46a9b', '#f5cf6a', '#f2e4c0', '#d6322b'])
    elif wx in ('heat', 'storm', 'fog'):
        flowers(cv, [(14, 90), (80, 104), (196, 90), (30, 112), (162, 124), (210, 118)], ['#f5cf6a', '#e46a9b'])
    for (x, y) in ((106, 98), (128, 110), (118, 124)):
        cv.fill(rect(x, y, x + 2, y), '#e8cf98' if wx not in ('snow', 'frost') else '#dcdccf')
    if wx == 'storm':
        puddle(cv, 108, 96, 124, 100, '#a3abb3', '#8b8f96')
        puddle(cv, 116, 112, 136, 118, '#a3abb3', '#8b8f96')
        puddle(cv, 30, 118, 50, 122, '#a3abb3', '#8b8f96')
        puddle(cv, 190, 120, 212, 124, '#a3abb3', '#8b8f96')
    if wx == 'frost':
        for (x0, y0, x1, y1) in ((108, 96, 124, 100), (190, 120, 212, 124)):   # frozen puddles
            puddle(cv, x0, y0, x1, y1, '#e6efd8', '#cde6e8')
            cv.fill(line([(x0 + 4, y0 + 1), (x0 + 8, y1 - 1), (x0 + 12, y0 + 2)]), '#a3abb3')
    # corner clumps
    if wx == 'snow':
        clump_w(cv, -4, H, [], seed=1, stem='#9a6b3f', lite='#c9a96e', head_ok=False)
        clump_w(cv, 214, H, [], seed=2, stem='#9a6b3f', lite='#c9a96e', head_ok=False)
    elif wx == 'heat':
        clump_w(cv, -4, H, ['#f5cf6a', '#e8cf98'], seed=1, stem='#c9a96e', lite='#a4b86a')
        clump_w(cv, 214, H, ['#e8cf98', '#e46a9b'], seed=2, stem='#c9a96e', lite='#a4b86a')
    elif wx == 'frost':
        clump_w(cv, -4, H, ['#f1ece0', '#cde6e8'], seed=1, stem='#4f7a4a', lite='#cde6e8')
        clump_w(cv, 214, H, ['#cde6e8', '#f1ece0'], seed=2, stem='#4f7a4a', lite='#cde6e8')
    else:
        L = {'wind': 9, 'storm': 7}.get(wx, 0)
        clump_w(cv, -4, H, ['#d6322b', '#f1ece0'], seed=1, lean=L)
        clump_w(cv, 214, H, ['#f1ece0', '#e46a9b'], seed=2, lean=L)
    # ---- weather over everything
    if wx == 'storm':
        streaks(cv, '#c9c5bc', 0, GROUND_Y - 7, step=7, seed=2, ln=5, slant=2, gap=(8, 14))
        streaks(cv, '#a9d6ea', GROUND_Y - 6, H - 1, step=11, seed=5, ln=5, slant=2, gap=(10, 18))
    if wx == 'wind':
        flying_leaves(cv, [(154, 20), (160, 34), (168, 26), (176, 14), (186, 30), (198, 22), (208, 40), (152, 46),
                           (220, 26), (230, 48), (168, 54), (214, 58), (64, 46), (30, 52), (12, 40), (78, 34), (44, 20),
                           (140, 10), (236, 14), (100, 8)], ['#7ab55c', '#4f9a45', '#e8a317', '#e46a9b', '#a4b86a'])
        hat(cv, 192, 34, tilt=1.1)
        for (x, y, ln) in ((10, 96, 30), (176, 104, 34), (60, 118, 26), (150, 126, 30)):
            swoosh(cv, x, y, ln, '#a4b86a', curl=False)
    if wx == 'fog':
        far_m = wave(50, [(2, 53, 0.3), (1, 19, 1.0)]) & ~wave(86, [(2, 61, 2.0), (1, 23, 0.5)])
        veil(cv, far_m, '#dcdccf', 0.55)
        near_m = wave(84, [(2, 47, 1.1), (1, 17, 0.2)]) & ~wave(104, [(2, 67, 0.8), (1, 21, 2.0)])
        veil(cv, near_m, '#dcdccf', 0.35)
        fog_band(cv, 62, 3, '#dcdccf', seed=2, x0=0, x1=W - 1)
        fog_band(cv, 78, 2, '#dcdccf', seed=3)
    if wx == 'snow':
        snowfall(cv, '#f1ece0', 0, GROUND_Y - 4, step=8, seed=3)
        snowfall(cv, '#f1ece0', 4, H - 1, step=14, seed=7, big=True, gap=(16, 30))
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0'})
    return cv


# ------------------------------------------------------------------ FOREST (v1: the mossy stump on the path, midday)
def canopy_w(cv, y, rps, seed=0, back=None, hang=True, snow=False, rime=None, lean=0):
    """stages_grass_forest_coast.canopy with weather: snow caps on each clump's visible top, a frost rim, a wind lean."""
    r = rnd(seed)
    if back:
        x = -12
        while x < W + 10:
            w = r(14, 24)
            if r(0, 2):
                cv.fill(ell(x, y - 14 + r(0, 8), x + w, y + 4 + r(0, 12)), back)
            x += w - r(4, 8)
    x = -16
    clumps = []
    while x < W + 10:
        w, h = r(22, 38), r(18, 26)
        top = y - 20 + r(-3, 6)
        rp = rps[r(0, len(rps) - 1)]
        o = cv.obj()
        m = ell(x, top, x + w, top + h)
        o.part(m, rp, d=3)
        if hang and r(0, 2) == 0:
            hx_ = x + r(6, w - 10)
            hm = ell(hx_ + lean, top + h - 6, hx_ + 10 + lean, top + h + 6)
            o.part(hm, rp, d=2)
            m = m | hm
        o.draw()
        for k in range(2):
            px, py = x + r(6, max(7, w - 8)), top + r(5, max(6, h - 6))
            cv.fill(line([(px, py), (px + 3, py - 2)]), rp['s'])
        clumps.append(m)
        x += w - r(6, 12)
    u = blank()
    for m in clumps:
        u |= m
    if snow:
        for i, m in enumerate(clumps):
            later = blank()
            for j in range(i + 1, len(clumps)):
                later |= clumps[j]
            vis = m & ~later
            # snow lies on the hanging lower lobes and shoulders that face up (the top row is off-canvas)
            t = vis & ~shift(vis, 0, 3) & rect(0, 6, W, H)
            cv.fill(t, SNOW)
            cv.fill(t & ~shift(t, 0, -1) & shift(vis, 0, -1), SNOW_S)
    if rime:
        cv.fill(u & ~shift(u, 1, 1) & rect(0, 4, W, H), rime)
    return u


def robin(cv, x, y):
    o = cv.obj()
    o.part(ell(x, y, x + 7, y + 5), ramp('#9a6b3f', '#7a4a1f', '#c9a96e'), d=1)
    o.part(ell(x + 4, y - 2, x + 9, y + 3), ramp('#9a6b3f', '#7a4a1f', '#c9a96e'), d=1, contour=True)
    o.part(ell(x + 4, y + 1, x + 8, y + 5), ramp('#e0501f', '#a8241f', '#f08a24'), d=0, contour=True)
    o.draw()
    cv.dots([(x + 7, y), (x + 10, y + 1)], '#3d2a1c')
    cv.fill(rect(x - 3, y + 1, x, y + 2), '#7a4a1f')


_F_SUN = dict(sky=[(0, '#e6efd8'), (36, '#d6e3b4'), (58, '#c4d698')], far='#c4d698', mid='#a4b86a', mid_s='#93a85c',
              under='#7ab55c', moss='#7ab55c', dark='#4f9a45', path='#c9a96e', path_s='#9a6b3f', spots='#a4b86a',
              canopy=[OAK, LEAF, OAK, MOSS], back='#4f9a45', t1='#4f9a45', t2='#2f6a3a', fern1=LEAF, fern2=MOSS,
              trunk=BARK)
_DARK = ramp('#2f6a3a', '#1f3f3a', '#4f9a45')
_DULL = ramp('#6f9a5a', '#4f7a4a', '#8fa86a')
FOREST = {
    'sun': _F_SUN,
    'cloud': dict(_F_SUN, sky=[(0, '#dcdccf'), (36, '#d6dccb'), (58, '#c3cdb6')], far='#c3cdb6', mid='#9fb59a',
                  mid_s='#8fa86a', under='#6f9a5a', moss='#6f9a5a', spots=None, canopy=[MOSS, OAK, _DULL, MOSS],
                  back='#2f6a3a', fern1=_DULL),
    'storm': dict(_F_SUN, sky=[(0, '#8b8f96'), (36, '#7d8a88'), (58, '#6f8a7a')], far='#6f8a7a', mid='#4f7a4a',
                  mid_s='#2f6a3a', under='#4f7a4a', moss='#4f7a4a', dark='#2f6a3a', path='#9a6b3f', path_s='#7a4a1f',
                  spots=None, canopy=[_DARK, MOSS, _DARK, _DARK], back='#1f3f3a', t1='#2f6a3a', t2='#1f3f3a',
                  fern1=MOSS, fern2=_DARK),
    'frost': dict(_F_SUN, sky=[(0, '#f1ece0'), (36, '#e6efd8'), (58, '#c3cdb6')], far='#c3cdb6', mid='#a3b59a',
                  mid_s='#8fa86a', under='#7f9a8a', moss='#a3b59a', dark='#6f9a5a', path='#c9c5bc', path_s='#8b8f96',
                  spots=None, canopy=[ramp('#4f9a45', '#2f6a3a', '#cde6e8'), ramp('#6f9a5a', '#4f7a4a', '#cde6e8')],
                  back='#2f6a3a', t1='#cde6e8', t2='#4f7a4a', fern1=ramp('#6f9a5a', '#4f7a4a', '#cde6e8'),
                  fern2=ramp('#4f9a45', '#2f6a3a', '#cde6e8')),
    'heat': dict(_F_SUN, sky=[(0, '#f2e4c0'), (36, '#f6d9b0'), (58, '#e8cf98')], far='#e8cf98', mid='#c9a96e',
                 mid_s='#b08a55', under='#a4b86a', moss='#a4b86a', dark='#7ab55c', path='#e8cf98', path_s='#c9a96e',
                 spots='#c4d698', canopy=[OAK, LEAF, ramp('#a4b86a', '#7ab55c', '#d6e3b4'), MOSS], back='#4f9a45',
                 t1='#7ab55c', t2='#4f9a45', fern1=ramp('#c9b46e', '#9a6b3f', '#e8cf98')),
    'wind': dict(_F_SUN),
    'fog': dict(_F_SUN, sky=[(0, '#dcdccf'), (36, '#dcdccf')], far='#c3cdb6', mid='#8fa86a', mid_s=None,
                under='#a3b59a', moss='#6f9a5a', spots=None, canopy=[_DULL, MOSS, _DULL], back='#4f7a4a', fern1=_DULL),
    'snow': dict(_F_SUN, sky=[(0, '#dcdccf'), (36, '#c9c5bc'), (58, '#a3abb3')], far='#a3abb3', mid='#8b8f96',
                 mid_s='#5b6470', under='#e6efd8', moss='#e6efd8', dark=SNOW, path='#c9c5bc', path_s='#a3abb3',
                 spots=None, canopy=[_DARK, ramp('#4f7a4a', '#2f6a3a', '#6f9a5a'), _DARK], back='#1f3f3a',
                 t1='#a3abb3', t2='#c9c5bc', fern1=_DARK, fern2=_DARK),
}


def forest_w(wx):
    P = FOREST[wx]
    cv = Canvas()
    bands(cv, P['sky'])
    if wx == 'heat':
        shimmer(cv, 40, 82, '#f2e4c0', seed=3, step=6)
    back_trunks(cv, P['far'], 16, GROUND_Y, 2, 4, 14, 3)
    cv.fill(wave(30, [(5, 47, 0.3), (3, 23, 1.9)], bottom=44), P['far'])
    if wx == 'storm':
        bolt(cv, [(172, 22), (164, 36), (174, 40), (160, 58), (168, 61), (158, 82)], fork=[(164, 36), (150, 44), (146, 54)])
        bolt(cv, [(30, 30), (36, 42), (28, 48), (34, 62)])
    back_trunks(cv, P['mid'], 18, GROUND_Y, 4, 7, 26, 7, shade=P['mid_s'])
    cv.fill(wave(22, [(5, 61, 1.1), (3, 29, 0.4)], bottom=34), P['mid'])
    if wx == 'wind':
        for (x, y, ln) in ((20, 50, 30), (140, 44, 34), (76, 62, 24), (190, 68, 28)):
            swoosh(cv, x, y, ln, '#f1ece0')
    if wx == 'fog':
        veil(cv, rect(0, 0, W - 1, GROUND_Y - 3), '#dcdccf', 0.5)
    if wx == 'fog':
        fog_band(cv, 48, 3, '#dcdccf', seed=5)
        fog_band(cv, 66, 4, '#dcdccf', seed=2)
    undergrowth(cv, GROUND_Y - 2, P['under'], 5)
    top = GROUND_Y - 4
    cv.fill(rect(0, top, W - 1, H - 1), P['moss'])
    cv.fill(rect(0, top + 26, W - 1, H - 1), P['dark'])
    grass_edge(cv, top + 26, P['dark'] if wx != 'snow' else '#e6efd8')
    pm = poly([(108, top), (132, top), (162, H), (78, H)])
    cv.fill(pm, P['path'])
    cv.fill(pm & ~shift(pm, -2, 0), P['path_s'])
    for (x, y) in ((116, top + 8), (126, top + 18), (110, top + 30), (134, top + 40)):
        cv.fill(rect(x, y, x + 3, y), P['path_s'])
    floor = rect(0, top, W - 1, H - 1) & ~pm
    if P['spots']:
        for (x, y, w) in ((20, 96, 14), (60, 104, 10), (176, 98, 16), (206, 108, 12), (150, 90, 8), (34, 112, 12)):
            ww = w + 6 if wx == 'heat' else w
            cv.fill(ell(x, y, x + ww, y + 3), P['spots'])
    if wx == 'frost':
        specks(cv, floor & rect(0, top, W, top + 25), '#e6efd8', seed=4, step=5, gap=(10, 18))
        specks(cv, floor & rect(0, top + 27, W, H), '#cde6e8', seed=6, step=6, gap=(12, 22))
    if wx == 'snow':
        for (x, y) in ((118, 86), (123, 93), (114, 100), (126, 108), (116, 116), (130, 124), (118, 131)):
            cv.fill(rect(x, y, x + 1, y + 1), '#a3abb3')
    if wx in ('heat', 'wind'):                                           # a few dry / blown leaves on the floor
        r = rnd(23)
        for i in range(22):
            x, y = r(2, 236), r(GROUND_Y, H - 2)
            c = ('#e8a317', '#c9a96e', '#7ab55c')[i % 3] if wx == 'heat' else ('#7ab55c', '#a4b86a', '#e8a317')[i % 3]
            cv.fill(rect(x, y, x + 2, y) | rect(x + 1, y - 1, x + 1, y - 1), c)
    if wx == 'fog':
        veil(cv, wave(80, [(2, 47, 1.1), (1, 17, 0.2)]) & ~wave(98, [(2, 67, 0.8), (1, 21, 2.0)]), '#dcdccf', 0.4)
    snow = wx == 'snow'
    rime = '#cde6e8' if wx == 'frost' else None
    for (x, w, yb) in ((-6, 11, GROUND_Y + 2), (230, 13, GROUND_Y + 4), (52, 7, GROUND_Y - 6), (184, 8, GROUND_Y - 8)):
        trunk(cv, x, w, 0, yb, rp=P['trunk'])
        if snow:                                                         # snow drift banked at each trunk foot
            cv.fill(ell(x - 6, yb - 4, x + w + 6, yb + 3) & rect(0, 0, W, yb), SNOW)
        if rime:
            cv.fill(rect(x + 1, 0, x + 1, yb - 2), rime)
    canopy_w(cv, 16, P['canopy'], seed=3, back=P['back'], snow=snow, rime=rime, lean=5 if wx == 'wind' else 0)
    # ---- centrepiece: the big mossy stump with toadstools and ferns
    if not snow:
        fern(cv, 88, GROUND_Y + 2, rp=P['fern1'])
        fern(cv, 152, GROUND_Y + 2, rp=P['fern2'])
    else:
        for (x, w) in ((76, 24), (142, 22)):                             # ferns under snow: white mounds, tips out
            o = cv.obj()
            o.part(ell(x, GROUND_Y - 6, x + w, GROUND_Y + 4) & rect(0, 0, W, GROUND_Y + 2), ramp(SNOW, '#c9c5bc', None), d=2)
            o.draw()
            cv.fill(line([(x + 3, GROUND_Y - 3), (x - 1, GROUND_Y - 7)]) | line([(x + w - 3, GROUND_Y - 3), (x + w + 1, GROUND_Y - 8)]), '#2f6a3a')
    stump_x0, stump_x1, stump_top = 102, 136, 60
    stump(cv, stump_x0, stump_x1, stump_top, GROUND_Y + 2, moss=not snow)
    if snow:
        cv.fill(ell(stump_x0 - 1, stump_top - 3, stump_x1 + 1, stump_top + 6) & ~rect(0, stump_top + 4, W, H) | rect(stump_x0, stump_top + 3, stump_x0 + 1, stump_top + 7) | rect(stump_x1 - 6, stump_top + 3, stump_x1 - 5, stump_top + 9), SNOW)
        cv.fill(rect(stump_x0 + 1, stump_top + 4, stump_x1 - 1, stump_top + 4) & ~rect(stump_x0 + 2, 0, stump_x1 - 8, H), SNOW_S)
        robin(cv, 112, stump_top - 7)
    if rime:
        cv.fill(ell(stump_x0, stump_top, stump_x1, stump_top + 6) & ~shift(ell(stump_x0, stump_top, stump_x1, stump_top + 6), 0, 1), rime)
    if not snow:
        cap_rp = SHROOM
        toadstool(cv, 144, GROUND_Y + 4, 7, cap=cap_rp)
        toadstool(cv, 154, GROUND_Y + 5, 4, cap=cap_rp)
        toadstool(cv, 96, GROUND_Y + 5, 4, cap=cap_rp)
        toadstool(cv, 112, 62, 3, cap=cap_rp)
        if rime:
            for (x, yb, r_) in ((144, GROUND_Y + 4, 7), (154, GROUND_Y + 5, 4), (96, GROUND_Y + 5, 4), (112, 62, 3)):
                cv.fill(rect(x - r_ + 2, yb - r_ * 2 - 1, x + r_ - 3, yb - r_ * 2 - 1), rime)
    else:
        toadstool(cv, 144, GROUND_Y + 4, 7)
        cv.fill(ell(137, GROUND_Y - 13, 151, GROUND_Y - 6) & ~rect(0, GROUND_Y - 9, W, H), SNOW)
    tl = 1 if wx in ('wind', 'storm') else 0
    tufts_w(cv, [(20, 92), (52, 98), (186, 92), (220, 100), (34, 118), (196, 124), (8, 110), (230, 116)], P['t1'], tl)
    tufts_w(cv, [(24, 124), (66, 130), (170, 122), (214, 132), (10, 132)], P['t2'], tl)
    if wx in ('cloud', 'wind', 'heat', 'fog'):
        flowers(cv, [(30, 102), (190, 106), (60, 120), (180, 126), (222, 112), (12, 98)], ['#f2e4c0', '#e46a9b'])
    if not snow:
        for (x, y) in ((40, 128), (204, 122)):
            toadstool(cv, x, y, 3)
        fern(cv, 8, 134, rp=P['fern2'])
        fern(cv, 232, 134, rp=P['fern1'])
    else:
        for (x, y) in ((-2, 126), (220, 124)):
            cv.fill(ell(x, y, x + 24, y + 14), '#e6efd8')
            cv.fill(line([(x + 6, y + 2), (x + 3, y - 4)]) | line([(x + 14, y + 1), (x + 16, y - 5)]), '#2f6a3a')
    if wx == 'storm':
        for (x0, y0, x1, y1) in ((104, 100, 122, 104), (118, 116, 142, 121), (26, 122, 46, 126), (190, 118, 210, 122)):
            puddle(cv, x0, y0, x1, y1, '#a3abb3', '#8b8f96')
        streaks(cv, '#c3cdb6', 0, GROUND_Y - 5, step=7, seed=4, ln=5, slant=2, gap=(8, 14))
        streaks(cv, '#a9d6ea', GROUND_Y - 4, H - 1, step=11, seed=1, ln=5, slant=2, gap=(10, 18))
    if wx == 'frost':
        for (x0, y0, x1, y1) in ((104, 100, 122, 104), (190, 118, 210, 122)):
            puddle(cv, x0, y0, x1, y1, '#e6efd8', '#cde6e8')
            cv.fill(line([(x0 + 4, y0 + 1), (x0 + 8, y1 - 1), (x0 + 12, y0 + 2)]), '#a3abb3')
    if wx == 'wind':
        flying_leaves(cv, [(60, 40), (74, 52), (90, 36), (150, 30), (164, 46), (176, 38), (200, 54), (214, 42), (30, 60),
                           (140, 64), (100, 48), (226, 66), (12, 48), (190, 72)], ['#7ab55c', '#4f9a45', '#e8a317', '#a4b86a'])
        hat(cv, 162, 58, tilt=1.2)
    if snow:
        snowfall(cv, SNOW, 8, GROUND_Y - 2, step=8, seed=4)
        snowfall(cv, SNOW, 12, H - 1, step=14, seed=8, big=True, gap=(16, 30))
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0'})
    return cv


# ------------------------------------------------------------------ COAST (v1: lighthouse headland, the rowboat on the sand)
def spray(cv, dx, by=70, col='#f1ece0', sh='#c9c5bc', s=1.0):
    """A wave bursting white over rocks (the coast-v3 burst, moved and scaled)."""
    m = blank()
    for (bx, ang, ln, w) in ((-17, -58, 10, 2), (-10, -30, 17, 2), (-5, -8, 22, 3), (2, 14, 15, 2), (9, 40, 12, 2), (16, 60, 8, 2)):
        a = math.radians(ang)
        ln = ln * s
        bx = dx + bx * s
        tx, ty = bx + ln * math.sin(a), by - 2 - ln * math.cos(a)
        m |= poly([(round(bx - w), by), (round(bx + w), by), (round(tx + 1), round(ty)), (round(tx - 1), round(ty))])
        m |= ell(round(tx) - 2, round(ty) - 2, round(tx) + 2, round(ty) + 2)
    m |= ell(round(dx - 29 * s), by - 8, round(dx - 7 * s), by + 4) | ell(round(dx - 15 * s), by - 12, round(dx + 11 * s), by + 2) | ell(round(dx + 5 * s), by - 8, round(dx + 29 * s), by + 4)
    cv.fill(m, col)
    cv.fill(m & ~shift(m, -2, -1), sh)
    return m


def beam(cv, x, y, col, core, x1=140, spread=5):
    """The lamp's beam: a narrow pale wedge with a brighter 1 px core line."""
    cv.fill(poly([(x, y - 1), (x, y + 1), (x1, y + spread), (x1, y - spread)]), col)
    cv.fill(line([(x, y), (x1, y)]), core)


def parasol(cv, x, ybot):
    o = cv.obj()
    o.part(rect(x, ybot - 22, x + 1, ybot), DWOOD, d=0)
    o.draw()
    o = cv.obj()
    cano = poly([(x - 15, ybot - 18), (x + 16, ybot - 18), (x + 13, ybot - 22), (x + 6, ybot - 25), (x - 5, ybot - 25), (x - 12, ybot - 22)])
    o.part(cano, ROOF, d=1)
    o.draw()
    for k in (-8, 1, 10):
        cv.fill(cano & rect(x + k - 2, 0, x + k + 1, H), '#f1ece0')
    cv.fill(rect(x, ybot - 27, x + 1, ybot - 26), '#5c3420')


_C_SUN = dict(sky=[(0, '#7fbcd8'), (14, '#a9d6ea'), (28, '#cde6e8'), (38, '#f1ece0')],
              sea=('#a9d6ea', '#7fbcd8', '#3f8fb0'), glint=('#cde6e8', '#a9d6ea'), island='#a4c8a0',
              grass='#7ab55c', grass_top='#a4b86a', rockc=('#c9c5bc', '#8b8f96', '#5b6470'),
              sand='#e8cf98', wet='#c9a96e', foam='#f1ece0', edge='#f2e4c0', dune='#c9a96e',
              marram=('#7ab55c', '#a4b86a'), lit=False)
COAST = {
    'sun': _C_SUN,
    'cloud': dict(_C_SUN, sky=[(0, '#a3abb3'), (18, '#c9c5bc'), (32, '#dcdccf')], sea=('#a3abb3', '#8b8f96', '#5b8a9a'),
                  glint=('#c9c5bc', '#a3abb3'), island='#9fb59a', grass='#6f9a5a', grass_top='#8fa86a',
                  marram=('#6f9a5a', '#8fa86a')),
    'storm': dict(_C_SUN, sky=[(0, '#8b8f96'), (34, '#a3abb3')], sea=('#5b8a9a', '#5b6470', '#25637d'),
                  glint=('#a3abb3', '#8b8f96'), island=None, grass='#4f7a4a', grass_top='#6f9a5a',
                  sand='#c9a96e', wet='#9a6b3f', foam='#f1ece0', edge='#e8cf98', dune='#9a6b3f',
                  marram=('#4f7a4a', '#6f9a5a'), lit=True),
    'frost': dict(_C_SUN, sky=[(0, '#a9d6ea'), (16, '#cde6e8'), (30, '#e6efd8'), (38, '#f1ece0')],
                  sea=('#cde6e8', '#a9d6ea', '#5b8a9a'), glint=('#f1ece0', '#cde6e8'), island='#c3cdb6',
                  grass='#a3b59a', grass_top='#cde6e8', wet='#c9a96e', marram=('#7f9a8a', '#cde6e8')),
    'heat': dict(_C_SUN, sky=[(0, '#a9d6ea'), (12, '#cde6e8'), (26, '#f2e4c0'), (36, '#f6d9b0')],
                 sea=('#cde6e8', '#7fbcd8', '#3f8fb0'), glint=('#f1ece0', '#cde6e8'), island='#e8cf98',
                 grass='#a4b86a', grass_top='#c9b46e', edge='#f6d9b0',
                 marram=('#a4b86a', '#c9b46e')),
    'wind': dict(_C_SUN),
    'fog': dict(_C_SUN, sky=[(0, '#c9c5bc'), (18, '#d6dccb'), (36, '#dcdccf')], sea=('#c9c5bc', '#a3abb3', '#8b8f96'),
                glint=('#dcdccf', '#c9c5bc'), island=None, lit=True),
    'snow': dict(_C_SUN, sky=[(0, '#8b8f96'), (14, '#a3abb3'), (30, '#c9c5bc')], sea=('#8b8f96', '#5b8a9a', '#25637d'),
                 glint=('#a3abb3', '#8b8f96'), island='#dcdccf', grass=SNOW, grass_top=SNOW,
                 sand=SNOW, wet='#c9a96e', foam='#dcdccf', edge='#dcdccf', dune='#dcdccf',
                 marram=('#9a6b3f', '#c9a96e'), lit=True),
}


def coast_w(wx):
    P = COAST[wx]
    cv = Canvas()
    bands(cv, P['sky'])
    if wx == 'sun':
        cloud(cv, 20, 10, 40, '#f1ece0', '#cde6e8')
        cloud(cv, 120, 18, 30, '#f1ece0', '#cde6e8')
        birds(cv, [(86, 22), (100, 16), (150, 34)])
    elif wx == 'cloud':
        for (x, y, w) in ((-10, 6, 60), (44, 0, 70), (120, 6, 56), (178, -2, 70), (20, 22, 40), (140, 22, 44)):
            heavy_cloud(cv, x, y, w, '#dcdccf', '#a3abb3')
        birds(cv, [(86, 34), (100, 30)], '#5b6470')
    elif wx == 'storm':
        ceiling(cv, 16, '#5b6470', '#4e3a8a', seed=2)
        for (x, y, w) in ((90, 30, 40), (180, 32, 30)):
            flat_cloud(cv, x, y, w, '#5b6470', '#4e3a8a')
        bolt(cv, [(70, 22), (64, 30), (72, 33), (62, 44)], fork=[(64, 30), (56, 36)])
        bolt(cv, [(150, 26), (154, 34), (148, 37), (153, 44)])
    elif wx == 'frost':
        sun(cv, 70, 26, 8, '#fff3c8', '#f1ece0')
        flat_cloud(cv, 120, 14, 40, '#f1ece0', '#cde6e8')
        flat_cloud(cv, 10, 8, 30, '#f1ece0', '#cde6e8')
    elif wx == 'heat':
        sun(cv, 64, 16, 12, '#fff3c8', '#f1ece0')
        for k in range(8):
            a = k * math.pi / 4 + 0.2
            x0, y0 = 64 + 15 * math.cos(a), 16 + 15 * math.sin(a)
            x1, y1 = 64 + 20 * math.cos(a), 16 + 20 * math.sin(a)
            cv.fill(line([(round(x0), round(y0)), (round(x1), round(y1))], 2), '#f5cf6a')
        flat_cloud(cv, 140, 12, 30, '#f1ece0', '#cde6e8')
    elif wx == 'wind':
        for (x, y, w) in ((6, 8, 44), (100, 4, 50), (150, 22, 40), (60, 22, 30), (196, 10, 36)):
            flat_cloud(cv, x, y, w, '#f1ece0', '#cde6e8')
        for (x, y, ln) in ((120, 32, 30), (10, 30, 24), (180, 2, 22)):
            swoosh(cv, x, y, ln, '#f1ece0')
        birds(cv, [(150, 34), (164, 28)])
    elif wx == 'fog':
        cv.fill(rect(0, 12, W - 1, 13) | rect(0, 26, W - 1, 27), '#dcdccf')
    elif wx == 'snow':
        for (x, y, w) in ((-10, 2, 60), (44, -4, 70), (120, 2, 56), (178, -4, 70)):
            heavy_cloud(cv, x, y, w, '#a3abb3', '#8b8f96')
    # ---- sea and far island
    shore = GROUND_Y - 8
    sea_top = 44
    bands(cv, [(sea_top, P['sea'][0]), (sea_top + 8, P['sea'][1]), (sea_top + 20, P['sea'][2])])
    ripples(cv, rect(0, sea_top + 2, W - 1, sea_top + 18), P['glint'][0], step=4, ln=3, seed=4)
    ripples(cv, rect(0, sea_top + 22, W - 1, shore - 2), P['glint'][1], step=5, ln=5, seed=1)
    if P['island']:
        cv.fill(wave(41, [(3, 40, 0.0)], 2, 60, 44), P['island'])
        cv.fill(rect(30, 38, 33, 41), '#f1ece0' if wx != 'snow' else '#a3abb3')
    if wx in ('storm', 'wind'):
        pts = ((20, 50), (64, 56), (110, 52), (160, 60), (186, 54), (40, 66), (150, 70), (90, 64), (220, 68), (200, 74),
               (6, 60), (130, 58), (76, 72), (236, 52), (176, 64))
        for (x, y) in pts[:15 if wx == 'storm' else 10]:
            cv.fill(line([(x, y + 1), (x + 3, y), (x + 6, y + 1)]), '#f1ece0')
    if wx == 'heat':
        for (x, y) in ((56, 46), (62, 48), (66, 50), (58, 52), (64, 55), (60, 58), (68, 61), (56, 64), (64, 68)):
            cv.fill(rect(x, y, x + 4, y), '#f1ece0')                     # sun glare on the water
        shimmer(cv, 40, 48, '#f6d9b0', seed=5, step=4)
    if wx in ('sun', 'cloud', 'heat'):
        sail(cv, 70, 56, 9)
        sail(cv, 142, 52, 6)
    elif wx == 'frost':
        sail(cv, 142, 52, 6)
    elif wx == 'wind':                                                   # heeled over, running before the wind
        o = cv.obj(outline=False)
        o.part(poly([(66, 44), (72, 56), (58, 56)]), ramp('#f1ece0', None), d=0)
        o.part(poly([(68, 46), (78, 56), (73, 56)]), ramp('#f1ece0', None), d=0)
        o.part(rect(57, 57, 79, 58), ramp('#7a4a1f', None), d=0)
        o.draw()
        sail(cv, 142, 52, 6)
    # ---- headland, lighthouse and the keeper's cottage
    if P['lit'] and wx in ('fog', 'storm', 'snow'):
        beam(cv, 214, 26, '#c9c5bc' if wx == 'fog' else '#dcdccf', '#f1ece0', x1=156, spread=5)
    hl_pts = [(158, GROUND_Y - 6), (170, 72), (184, 62), (198, 58), (246, 56), (246, GROUND_Y - 6)]
    headland(cv, hl_pts, P['grass'], P['grass_top'], rockc=P['rockc'], cap=6)
    lighthouse(cv, 220, 58, 28, lit=P['lit'])
    o = cv.obj()
    o.part(rect(190, 50, 204, 59), CANVAS, d=1)
    roof_m = poly([(188, 51), (197, 43), (206, 51)])
    o.part(roof_m, ROOF, d=1, contour=True)
    o.draw()
    cv.fill(rect(194, 53, 197, 56), '#3f8fb0' if wx not in ('storm', 'fog', 'snow') else '#f5cf6a')
    if wx == 'snow':
        cap(cv, roof_m, 2, drips=False)
        cap(cv, poly([(213, 22), (227, 22), (220, 15)]), 2, drips=False)
        cv.fill(poly(hl_pts) & ~shift(poly(hl_pts), 0, 1), '#dcdccf')
    if wx == 'frost':
        cv.fill(roof_m & ~shift(roof_m, 1, 1), '#cde6e8')
        for x in range(189, 206, 3):                                     # icicles on the eave
            cv.fill(rect(x, 52, x, 53 + (x % 2)), '#cde6e8')
        specks(cv, poly(hl_pts) & rect(0, 64, W, GROUND_Y), '#cde6e8', seed=2, step=6, gap=(6, 12))
    if wx == 'fog':
        skyc = blank()
        for (_, c) in P['sky']:
            skyc |= mask_of(cv, c)
        veil(cv, rect(0, sea_top, W - 1, shore - 1) | (rect(150, 0, W - 1, GROUND_Y) & ~(skyc & rect(0, 0, W, sea_top - 1))), '#dcdccf', 0.5)
        cv.fill(rect(216, 24, 223, 28), '#f5cf6a')                       # the lamp still shines through
        cv.fill(rect(218, 24, 219, 28), '#fff3c8')
        fog_band(cv, 52, 4, '#dcdccf', seed=1)
        fog_band(cv, 66, 3, '#dcdccf', seed=3)
    # ---- beach
    beach(cv, shore, P['sand'], P['wet'], P['foam'], P['edge'], dune=P['dune'], seed=1)
    if wx == 'heat':
        shimmer(cv, GROUND_Y - 3, GROUND_Y + 10, '#f6d9b0', seed=8, step=5)
        parasol(cv, 72, GROUND_Y - 6)
    if wx == 'frost':
        sand_m = rect(0, shore + 7, W - 1, H - 1)
        specks(cv, sand_m, '#f1ece0', seed=7, step=7, gap=(12, 22))
        cv.fill(wave(shore, [(1.5, 60, 0.4), (1, 23, 1.6)]) & ~wave(shore + 2, [(1.5, 60, 0.4), (1, 23, 1.6)]), ICE)
    if wx == 'storm':
        cv.fill(wave(shore - 3, [(2, 30, 0.4), (1, 13, 1.6)]) & ~wave(shore + 1, [(1.5, 60, 0.4), (1, 23, 1.6)]), '#f1ece0')
    # rocks at the left of the waterline (spray over them in a storm), the boat in the middle
    if wx == 'storm':
        spray(cv, 24, 76, s=0.8)
    rk1 = rock(cv, 6, 70, 30, 82)
    rk2 = rock(cv, 24, 75, 38, 82, moss=ramp(P['grass'], '#4f9a45', P['grass_top']) if wx != 'snow' else None)
    boat_beached(cv, 90, 78)
    if wx == 'snow':
        cap(cv, rk1 | rk2, 2, drips=False)
        cap(cv, poly([(90, 78), (144, 76), (138, 90), (98, 91)]) & rect(0, 0, W, 80), 1, drips=False)
    if wx == 'frost':
        cv.fill((rk1 | rk2) & ~shift(rk1 | rk2, 1, 1), '#cde6e8')
    if wx != 'snow':
        starfish(cv, 152, 90)
        shells(cv, [(20, 96), (58, 106), (180, 100), (214, 110), (110, 104), (140, 120), (36, 118), (200, 116)])
    else:
        for (x, y) in ((116, 92), (122, 99), (114, 106), (126, 113), (118, 121), (128, 128)):
            cv.fill(rect(x, y, x + 1, y + 1), '#a3abb3')
    if wx == 'storm':
        for (x0, y0, x1, y1) in ((60, 100, 80, 104), (150, 116, 174, 120), (104, 108, 120, 111)):
            puddle(cv, x0, y0, x1, y1, '#a3abb3', '#8b8f96')
    lean = {'wind': 6, 'storm': 4}.get(wx, 0)
    if lean:
        for (x0, x1, seed) in ((0, 40, 1), (196, 240, 2)):
            r = rnd(seed + 3)
            x = x0
            while x < x1:
                h = r(5, 9)
                cv.fill(line([(x, H - 6), (x + lean // 2, H - 6 - h // 2), (x + lean, H - 6 - h + 1)]), P['marram'][0])
                if r(0, 1):
                    cv.fill(line([(x + 1, H - 6), (x + lean + 2, H - 6 - h + 3)]), P['marram'][1])
                x += r(2, 4)
    else:
        from stages_grass_forest_coast import marram
        marram(cv, 0, 40, H - 6, P['marram'][0], P['marram'][1], seed=1)
        marram(cv, 196, 240, H - 6, P['marram'][0], P['marram'][1], seed=2)
    # ---- weather over everything
    if wx == 'wind':
        kite(cv, 40, 22, [(38, 34), (42, 40), (36, 46), (40, 52), (34, 58)])
        cv.fill(line([(40, 31), (30, 44), (16, 56), (0, 64)]), '#9a6b3f')
        for (x, y, ln) in ((10, 96, 30), (176, 104, 34), (60, 118, 26), (150, 126, 30), (110, 88, 20)):
            swoosh(cv, x, y, ln, '#f2e4c0', curl=False)
        hat(cv, 176, 36, tilt=1.0)
    if wx == 'storm':
        streaks(cv, '#c9c5bc', 0, shore - 1, step=7, seed=3, ln=5, slant=2, gap=(8, 14))
        streaks(cv, '#e8cf98', shore, H - 1, step=11, seed=6, ln=5, slant=2, gap=(10, 18))
    if wx == 'snow':
        snowfall(cv, SNOW, 0, shore, step=8, seed=5)
        snowfall(cv, SNOW, 6, H - 1, step=14, seed=9, big=True, gap=(16, 30))
    cv.remap({'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0'})
    return cv


# ------------------------------------------------------------------ build
STAGES = {}
for _land, _fn in (('grassland', grassland_w), ('forest', forest_w), ('coast', coast_w)):
    for _w in WEATHERS:
        STAGES[_land + '-' + _w] = (lambda f, w: (lambda: f(w)))(_fn, _w)

# all nine HOLLOW_WEATHER keys -> file key (stage-<key>.png). sun = the v1 scene, rain = the existing v3 rain scene.
WEATHER_MAP = {land: dict({'sun': land, 'rain': land + '-v3'}, **{w: land + '-' + w for w in WEATHERS})
               for land in ('grassland', 'forest', 'coast')}
ORDER = ['sun', 'cloud', 'rain', 'storm', 'frost', 'heat', 'wind', 'fog', 'snow']

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..', '..', 'game', 'assets', 'img', 'scenes')
    only = sys.argv[2:] or list(STAGES)
    for k in only:
        cv = STAGES[k]()
        folded = cap_colours(cv, 32)
        p = os.path.join(out, 'stage-' + k + '.png')
        cv.save(p)
        print(k, 'colours', cv.colours(), ('folded %s' % folded) if folded else '', '->', p)
    if not sys.argv[2:]:
        for land, m in WEATHER_MAP.items():
            p = os.path.join(out, 'stage-weather-' + land + '.json')
            with open(p, 'w') as f:
                json.dump({w: m[w] for w in ORDER}, f, indent=1)
                f.write('\n')
            print('map ->', p)
