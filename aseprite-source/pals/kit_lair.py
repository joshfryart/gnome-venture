"""kit_lair: shared parts for the 14 LAIR Places rosters (Puzzle Pals, claude/plan-places-pals.md s2). Builds on palib; never edits it.
Mood: the villain's leftovers, spooky-cute not scary: hooks and horns, rounded tips, cream highlights, never sharp black teeth.

API (all coordinates are 64 x 64 canvas px; every part paints straight onto a palib Sticker and returns the mask it painted)

  Picture + rows
    PlacePic(slug)                     a Places picture (game/assets/img/jigsaw/places/<slug>.png, 360 x 240), cut 12 x 8, palette = its own
                                       colours. Same .sample() / .snap() / .dominant() as palib.Pic.
    rows(pic_slug)                     {key: {'rarity', 'piece': (col, row), 'shape', 'knob', 'name'}} from puzzle_pals.txt
    cell_fill(pic, piece, mask, x0, y0, size, k=3, passes=3, dx=0, dy=0)   cell texture: sampled, majority-filtered, reduced to k colours
    calm_tones(tex, mask, tones)       map the fill by brightness onto a short list of hex tones (dark to light): a flat cell -> 2 or 3 quiet
                                       bands that keep the cell's layout but let the face read. The usual call for 15 x 15 Places cells.
    lift(tex, mask, col, thr)          fill colours darker than thr (r+g+b) become col
    tidy(st, cap=35)                   fold the rarest colours until the sticker fits the < 40 colour budget
    ramp(base)                         (base, shade, light, deep) hex from one base colour (palib tone recipe): pass to any part as `pal`

  Tinted palettes (base, shade, light, deep) ready to pass as pal=:
    BONE HORN EMBER LAVA ASH SOOT FROST JADE SAND SILVER GOLDP MOTH

  Parts (pal = a 4-tuple like the above or ramp('#hex'); d = palib shade depth)
    horn(st, x, y, h=7, lean=1.0, w=4, pal=HORN)            curved horn from base centre (x, y) up h px; lean > 0 curls right, < 0 left
    horns(st, cx, y, gap=12, h=7, pal=HORN)                 a mirrored pair, curling outward
    fang(st, x, y, h=3, pal=BONE)                           one rounded fang hanging down from (x, y): 2 px wide, cream tip
    fangs(st, x, y, n=2, gap=4, h=3)                        a row of fangs under a mouth line
    claw_feet(st, xs, y, w=6, h=4, pal=SOOT, tip=BONE)      felt-boot feet with 3 cream claw tips each (the lair foot)
    claw_tips(st, x, y, n=3, pal=BONE, down=True)           just the tips, for a paw or a tab arm
    ember(st, cx, cy, r=3, pal=EMBER)                       a glowing coal: dark cinder disc with orange cracks and a gold core
    flame_mask(cx, by, w, h, lean=0.0, licks=0)             flame silhouette, base centre (cx, by), width w, height h, tip leaning
    flame(st, cx, by, w=6, h=9, lean=0.0, pal=LAVA, core=GOLDP, licks=1)   a painted flame with an inner gold tongue
    puff(st, cx, cy, r=3.0, pal=ASH, lobes=3)               ash / smoke / steam / cloud puff (3 lobes, shade lower right)
    scale(st, x, y, w=4, pal=LAVA)                          one round-bottomed scale chip (an arch), light top edge
    scales(st, mask, pal, step=4)                           a scale pattern clipped to a mask (arches on a staggered grid)
    spike_crown(st, x0, x1, y, n=3, h=5, pal=HORN, tip=None)   n spikes on a band from x0 to x1 standing on row y, tips optionally lit
    web_strand(st, pts, col=SILVER[2], dew=True)            1 px silk thread through pts with a dew dot; web(st, cx, cy, r) = a little orb web
    feather(st, x, y, L=9, ang=-60, pal=JADE)               a feather from its quill end (x, y), length L, angle in degrees
    shell_chip(st, cx, cy, r=4, pal=SAND)                   a fan shell fragment with ribs
    frost_chip(st, cx, cy, r=3, pal=FROST)                  an ice shard / snowflake chip (6 arms) for frost lairs
    sand_grains(st, mask, col, every=5)                     sparse grain dots inside a mask (desert lairs), deterministic
    bat_wing(st, x, y, L=10, side=1, pal=SOOT)              a stubby scalloped bat / dragon wing from its root (x, y); side -1 = left
    sparks(st, pts, big=False)                              gold pop sparks (sparkler bits): 3 x 3 plus marks, border only
    zzz(st, x, y, col=CREAM)                                a small sleeping Z

Everything is deterministic (no random).
"""
import math
import os

import numpy as np
from PIL import Image

from palib import (N, ROOT, CX, CY, XX, YY, CREAM, UMBER, UMBER2, GOLD, GOLD_D, GOLD_L, SHOE, Pic, hx, hexs, tone, blank, rect, disc,
                   ellipse, poly, line, shift, dil4, grow, shrink, majority, reduce)

DATA = os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt')


# ---------------------------------------------------------------- picture + rows
class PlacePic(Pic):
    """A Places picture: game/assets/img/jigsaw/places/<slug>.png (360 x 240 file px = 180 x 120 art px), cut 12 x 8 (30 x 30 file px cells).
    Its palette is the picture's own colours (it is hard-pixel art, under ~60 colours), so snapping never invents a tone."""

    def __init__(self, slug, cols=12, rows=8):
        self.slug = slug
        self.img = np.array(Image.open(os.path.join(ROOT, 'game', 'assets', 'img', 'jigsaw', 'places', slug + '.png')).convert('RGB')).astype(np.int32)
        self.h, self.w = self.img.shape[:2]
        self.cw, self.ch = self.w / cols, self.h / rows
        cols_, cnt = np.unique(self.img.reshape(-1, 3), axis=0, return_counts=True)
        self.pal = cols_[np.argsort(-cnt)][:64].astype(np.int32)


def rows(pic_slug):
    out = {}
    for l in open(DATA, encoding='utf-8'):
        c = l.rstrip('\n').split('|')
        if not l.startswith('#') and len(c) == 14 and c[0] == pic_slug:
            out[c[1]] = {'name': c[2], 'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}
    return out


def cell_fill(pic, piece_, mask, x0, y0, size, k=3, passes=3, dx=0.0, dy=0.0):
    t = pic.sample(piece_[0], piece_[1], x0, y0, size, dx, dy)
    t = majority(t, mask, passes)
    return reduce(t, mask, k)


def calm_tones(tex, mask, tones, cuts=None):
    """Brightness (r+g+b) of each fill pixel -> one of `tones` (hex, dark to light). cuts = brightness thresholds (len(tones) - 1);
    default = evenly between the fill's own darkest and lightest colours."""
    t = tex.copy()
    lum = tex.astype(int).sum(-1)
    if not mask.any():
        return t
    if cuts is None:
        lo, hi = lum[mask].min(), lum[mask].max()
        cuts = [lo + (hi - lo) * (i + 1) / len(tones) for i in range(len(tones) - 1)]
    idx = np.zeros(lum.shape, int)
    for c in cuts:
        idx += lum > c
    for i, h in enumerate(tones):
        t[mask & (idx == i)] = hx(h)
    return t


def lift(tex, mask, col, thr=260):
    t = tex.copy()
    t[mask & (t.astype(int).sum(-1) < thr)] = hx(col)
    return t


def tidy(st, cap=35):
    m = st.sil | st.extra
    while True:
        cols, cnt = np.unique(st.px[m].reshape(-1, 3), axis=0, return_counts=True)
        if len(cols) <= cap:
            return
        i = cnt.argmin()
        rest = np.delete(cols, i, 0).astype(int)
        near = rest[((rest - cols[i].astype(int)) ** 2).sum(-1).argmin()]
        st.px[m & np.all(st.px == cols[i], axis=2)] = near


def ramp(base):
    return (base, hexs(tone(hx(base), 'shade')), hexs(tone(hx(base), 'rim')), hexs(tone(hx(base), 'deep')))


# (base, shade, light, deep)
BONE = ('#f2e4c0', '#d2bf96', '#fff3c8', '#a8916a')
HORN = ('#c9a96e', '#9a7a48', '#f1dca8', '#6a4a2a')
EMBER = ('#3a1e2a', '#2a1a10', '#f08a24', '#e0501f')      # cinder body, crack dark, glow, crack mid
LAVA = ('#e0501f', '#b12d22', '#f08a24', '#6b1b2c')
ASH = ('#938280', '#6a5a5e', '#b3a8a6', '#48474f')
SOOT = ('#4a3030', '#2f1e26', '#6a4a4a', '#2a1a10')
FROST = ('#a9d6ea', '#6aa6c4', '#eef8fc', '#3f7f9f')
JADE = ('#4fae7a', '#2f7a5a', '#8fd6a6', '#1f5a44')
SAND = ('#e8c88a', '#c09a5a', '#fbe8b8', '#8a6a3a')
SILVER = ('#b3b9bb', '#8b8f96', '#eef2f2', '#5b6470')
GOLDP = ('#f5cf6a', '#e8a317', '#fff3c8', '#b07a10')
MOTH = ('#c9a46a', '#9a7448', '#f2d6a7', '#6a4a2a')


def _paint_part(st, m, pal, d=1, contour=True, rim=True):
    if m.any():
        st.part(m, pal[0], d=d, contour=contour, rim=rim)
    return m


# ---------------------------------------------------------------- horns, fangs, claws
def horn(st, x, y, h=7, lean=1.0, w=4, pal=HORN, d=1):
    """Curved horn: a tapering stack of rows, each row shifted by a curve, rounded tip (2 px), base w px wide, ridge band."""
    m = blank()
    for j in range(h):
        t = j / max(1, h - 1)
        half = max(0.9, (w / 2) * (1 - 0.75 * t))
        off = lean * 3.2 * t * t
        yy = y - j
        if 0 <= yy < N:
            m |= (YY == yy) & (np.abs(CX - (x + off)) <= half + 0.05)
    _paint_part(st, m, pal, d=d)
    ridge = m & (YY == y - h // 3)
    st.paint(ridge, pal[1])
    tip = m & (YY <= y - h + 2)
    st.paint(tip, pal[2])
    return m


def horns(st, cx, y, gap=12, h=7, w=4, pal=HORN):
    return horn(st, cx - gap / 2, y, h, -1.0, w, pal) | horn(st, cx + gap / 2, y, h, 1.0, w, pal)


def fang(st, x, y, h=3, pal=BONE):
    m = rect(x, y, x + 1, y + h - 2) | rect(x, y + h - 1, x, y + h - 1)
    st.paint(m, pal[0])
    st.paint(m & (CX > x + 1), pal[1])
    return m


def fangs(st, x, y, n=2, gap=4, h=3, pal=BONE):
    m = blank()
    for i in range(n):
        m |= fang(st, x + i * gap, y, h, pal)
    return m


def claw_tips(st, x, y, n=3, pal=BONE, down=True, step=2):
    m = blank()
    for i in range(n):
        px = x + i * step
        m |= rect(px, y, px, y)
    st.paint(m, pal[0], solid=True)
    return m


def claw_feet(st, xs, y, w=6, h=4, pal=SOOT, tip=BONE):
    """Lair feet: a soot felt boot (cut corners) with three cream claw tips poking out of its toe row."""
    m = blank()
    for x in xs:
        shoe = rect(x, y, x + w - 1, y + h - 1)
        shoe[y, x] = shoe[y, x + w - 1] = False
        st.part(shoe, pal[0], d=1, contour=True)
        st.paint(rect(x + 1, y + h, x + w - 2, y + h) & ((XX - x) % 2 == 1), tip[0], solid=True)
        m |= shoe
    return m


# ---------------------------------------------------------------- fire and ash
def ember(st, cx, cy, r=3.0, pal=EMBER, lick=False):
    """Glowing cinder flake: a chunky faceted cinder (pal[0]) split by bright cracks (pal[2] core, pal[3] edges), gold hot spot.
    lick = a small flame tongue flickering on top (for a bigger ember worn as a cap)."""
    m = poly([(cx - r, cy + r * 0.5), (cx - r * 0.8, cy - r * 0.45), (cx - r * 0.1, cy - r * 0.85), (cx + r * 0.85, cy - r * 0.55),
              (cx + r, cy + r * 0.35), (cx + r * 0.3, cy + r * 0.8), (cx - r * 0.5, cy + r * 0.8)])
    if lick:
        flame(st, cx + r * 0.2, cy - r * 0.6, w=r * 0.6, h=r * 0.75, lean=0.5, pal=LAVA, licks=0)
    st.part(m, pal[0], d=1, contour=True)
    crack = (line([(cx - r + 1, cy + 0.5), (cx - 0.5, cy - 0.5), (cx + r - 1, cy + 0.8)]) | line([(cx - 0.5, cy - 0.5), (cx + 0.5, cy - r + 1)]) |
             line([(cx + 0.5, cy + 0.2), (cx - 0.3, cy + r - 1)])) & shrink(m, 1)
    st.paint(grow(crack, 1) & shrink(m, 1) if r >= 4 else crack, pal[3])
    st.paint(crack, pal[2])
    st.paint(disc(cx - 0.3, cy - 0.3, 1.0) & m, GOLD)
    return m


def flame_mask(cx, by, w, h, lean=0.0, licks=0):
    """Flame: round bulb at the base tapering to a tip at (cx + lean * h * 0.35, by - h). licks = small side tongues (0..2)."""
    pts_l, pts_r = [], []
    steps = max(6, int(h))
    for i in range(steps + 1):
        t = i / steps
        f = (1 - t) ** 0.85 * min(1.0, 0.55 + 1.9 * t)
        half = (w / 2) * f
        off = lean * h * 0.35 * t * t
        yy = by - t * h
        pts_l.append((cx + off - half, yy))
        pts_r.append((cx + off + half, yy))
    m = poly(pts_l + pts_r[::-1]) | ellipse(cx, by - w * 0.32, w / 2, w * 0.36)
    if licks >= 1:
        m |= poly([(cx + w * 0.30, by - h * 0.25), (cx + w * 0.62, by - h * 0.62), (cx + w * 0.10, by - h * 0.45)])
    if licks >= 2:
        m |= poly([(cx - w * 0.30, by - h * 0.22), (cx - w * 0.58, by - h * 0.52), (cx - w * 0.08, by - h * 0.40)])
    return m


def flame(st, cx, by, w=6, h=9, lean=0.0, pal=LAVA, core=GOLDP, licks=1, d=1):
    m = flame_mask(cx, by, w, h, lean, licks)
    st.part(m, pal[0], d=d, contour=True)
    inner = flame_mask(cx, by - 1, max(2, w * 0.5), h * 0.6, lean * 0.6, 0) & shrink(m, 1)
    st.paint(inner, core[0])
    st.paint(inner & ~shift(inner, 0, 1), core[2])
    return m


def puff(st, cx, cy, r=3.0, pal=ASH, lobes=3, d=1):
    m = disc(cx, cy, r)
    if lobes >= 2:
        m |= disc(cx + r * 0.95, cy + r * 0.35, r * 0.78)
    if lobes >= 3:
        m |= disc(cx - r * 0.9, cy + r * 0.4, r * 0.72)
    if lobes >= 4:
        m |= disc(cx + r * 0.2, cy - r * 0.8, r * 0.6)
    st.part(m, pal[0], d=d, contour=True)
    st.paint(m & disc(cx - r * 0.35, cy - r * 0.35, r * 0.45) & shrink(m, 1), pal[2])
    return m


# ---------------------------------------------------------------- scales, spikes
def scale(st, x, y, w=4, pal=LAVA):
    """One scale chip: an arch w px wide, w px tall, flat top, round bottom; light top row, shade bottom."""
    m = ellipse(x + w / 2, y + w * 0.35, w / 2, w * 0.65) & (CY > y)
    st.part(m, pal[0], d=1, contour=True)
    st.paint(m & (YY == y), pal[2])
    return m


def scales(st, mask, pal, step=4):
    """A scale pattern inside a mask: arch edges (pal[1]) on a staggered grid, a light dot (pal[2]) per scale."""
    row = (YY // step)
    xo = (XX + (row % 2) * (step // 2)) % step
    yo = YY % step
    edge = mask & (((yo == step - 1) & (xo != 0) & (xo != step - 1)) | ((xo == 0) & (yo >= 1)))
    st.paint(edge, pal[1])
    st.paint(mask & (yo == 1) & (xo == step // 2), pal[2])
    return edge


def spike_crown(st, x0, x1, y, n=3, h=5, pal=HORN, tip=None):
    """n triangle spikes standing on row y between x0 and x1 (the wyrm's back spines, a crown, frost spikes). tip = hex for lit tips."""
    m = blank()
    span = (x1 - x0 + 1) / n
    for i in range(n):
        a = x0 + i * span
        b = a + span
        c = (a + b) / 2
        hh = h + (1 if i == n // 2 and n % 2 else 0)
        m |= poly([(a + 0.3, y + 1), (c - 0.6, y - hh), (c + 0.6, y - hh), (b - 0.3, y + 1)])
    _paint_part(st, m, pal)
    if tip:
        st.paint(m & ~shift(m, 0, 2), tip)
    return m


# ---------------------------------------------------------------- the other lairs' bits
def web_strand(st, pts, col=SILVER[2], dew=True):
    m = line(pts)
    st.paint(m, col, solid=True)
    if dew and len(pts) > 1:
        mx, my = int(round((pts[0][0] + pts[-1][0]) / 2)), int(round((pts[0][1] + pts[-1][1]) / 2))
        st.paint(m & disc(mx + 0.5, my + 0.5, 1.6) | rect(mx, my, mx, my), '#ffffff' if col == SILVER[2] else col, solid=True)
    return m


def web(st, cx, cy, r=6, col=SILVER[2]):
    m = blank()
    for k in range(6):
        a = math.radians(k * 60 + 15)
        m |= line([(cx, cy), (cx + r * math.cos(a), cy + r * math.sin(a))])
    ring = (np.abs(np.hypot(CX - cx - 0.5, CY - cy - 0.5) - r * 0.6) < 0.5)
    m |= ring & disc(cx + 0.5, cy + 0.5, r)
    st.paint(m, col, solid=True)
    return m


def feather(st, x, y, L=9, ang=-60.0, pal=JADE):
    a = math.radians(ang)
    ux, uy = math.cos(a), math.sin(a)
    px, py = -uy, ux
    w = L * 0.28
    pts = [(x + ux * L * t + px * w * math.sin(math.pi * min(1, t * 1.15)), y + uy * L * t + py * w * math.sin(math.pi * min(1, t * 1.15)))
           for t in np.linspace(0, 1, 8)]
    pts += [(x + ux * L * t - px * w * math.sin(math.pi * min(1, t * 1.15)), y + uy * L * t - py * w * math.sin(math.pi * min(1, t * 1.15)))
            for t in np.linspace(1, 0, 8)]
    m = poly(pts)
    st.part(m, pal[0], d=1, contour=True)
    st.paint(line([(x, y), (x + ux * L * 0.9, y + uy * L * 0.9)]) & shrink(m, 1), pal[2])
    return m


def shell_chip(st, cx, cy, r=4, pal=SAND):
    m = disc(cx, cy, r) & (CY < cy + 0.6)
    m |= poly([(cx - 1.5, cy), (cx + 1.5, cy), (cx + 0.8, cy + 2), (cx - 0.8, cy + 2)])
    st.part(m, pal[0], d=1, contour=True)
    ang = np.arctan2(CY - cy, CX - cx)
    st.paint(m & shrink(m, 1) & (CY < cy) & ((np.floor((ang + np.pi) / (np.pi / 8)).astype(int) % 2) == 0), pal[1])
    return m


def frost_chip(st, cx, cy, r=3, pal=FROST):
    m = blank()
    for k in range(3):
        a = math.radians(k * 60 + 90)
        m |= line([(cx - r * math.cos(a), cy - r * math.sin(a)), (cx + r * math.cos(a), cy + r * math.sin(a))])
    st.paint(m, pal[0], solid=True)
    st.paint(rect(int(cx), int(cy), int(cx), int(cy)), pal[2], solid=True)
    return m


def sand_grains(st, mask, col, every=5):
    m = mask & (((XX * 7 + YY * 3) % (every * 3)) == 0) & ((YY % 2) == 0) & shrink(mask, 1)
    st.paint(m, col)
    return m


def bat_wing(st, x, y, L=10, side=1, pal=SOOT):
    """Stubby scalloped wing from its root (x, y): a fan up and out, the lower edge bitten by 2 scallops; finger ribs in the light tone."""
    s = side
    m = poly([(x, y), (x + s * L * 0.35, y - L * 0.75), (x + s * L, y - L * 0.55), (x + s * L * 0.95, y + L * 0.2), (x, y + L * 0.25)])
    for k in (0.38, 0.75):
        m &= ~disc(x + s * L * k, y + L * 0.32, L * 0.2)
    st.part(m, pal[0], d=1, contour=True)
    st.paint((line([(x, y), (x + s * L * 0.35, y - L * 0.72)]) | line([(x, y), (x + s * L * 0.92, y - L * 0.5)])) & m, pal[2])
    return m


def sparks(st, pts, big=False):
    for x, y in pts:
        st.sparkle(x, y, big=big)


def zzz(st, x, y, col=CREAM):
    st.sprite(['ZZZ', '.Z.', 'ZZZ'], x, y, {'Z': col}, solid=False)
    st.extra[y:y + 3, x:x + 3] |= np.array([[1, 1, 1], [0, 1, 0], [1, 1, 1]], bool)
