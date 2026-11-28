#!/usr/bin/env python3
"""Stop art states: ruined / being worked on / fixed (proof on mill, shrine, ferry of the Maplewold).

    python3 tools/stop_states/make_states.py [--out DIR] [--look grassland_maplewold] [--kinds mill,shrine,ferry]

Hard pixels only (nearest neighbour, no soft edges), so the Hearth Pop look stays crisp.
  fixed  = the finished scene, untouched (optional life overlays: 'stocked', 'lit', composable)
  ruin   = overcast recolour toward the cavern palette + a per-kind break recipe + overgrowth (moss, ivy, rubble)
  work   = stepped-diagonal / hand-mask blend of ruin and fixed + builder's props (scaffold, ladder, planks, lantern)
Proposal: claude/proposal-stop-states.md (sections 4 and 5).

Town recipe (claude/proposal-town-states.md section 2, slice 2): run from the repo root

    python3 tools/stop_states/make_states.py town [--out DIR] [--sheet SHEET.png]

writes 32 pictures to game/assets/img/scenes (or DIR), deterministic (fixed seeds, no clock):
  here-town-<code>-ruin.png / -work.png for the 14 region towns (not the hub), here-town-ruin.png / -work.png (generic
  fallback) and stop-market-ruin.png / -work.png (the town header; its 3 stall boxes are MARKET_HEADER_SPOTS).
  The fixed pictures (here-town-<code>.png, here-town.png, stop-market.png) are only read, never written.
  ruin (Run low) = overcast at town_strength() (about .4 to .8, aims at ~15% visibly changed pixels), the 'shops' spots keep
         colour + a lit lamp + an OPEN board, other windows dimmed, 60% of them shuttered, flags faded, roof patches, moss,
         weeds, a crack, an empty cart. No holes, no rubble.
  work (Mending) = the fixed picture with a stepped half still run low, scaffold on the teahouse, library and homes buildings, cart + crates +
         shelf at the shop, more lamps, planks on the green.
  Every position comes from the spot boxes in game/includes/data/here_layouts.json (town-<code>; the generic 'town' layout
  has no boxes, so 72 x 64 round each spot). The middle 40% of every spot box (centre()) is never painted over: props refuse
  it and it is restored from the recoloured picture at the end. Each twin is snapped to its fixed picture's palette
  (town_palette(): the fixed colours, their overcast twins, the house prop colours) and asserted to stay inside it.
  Prints colours and the visibly changed share (RGB distance >= 36) per picture; --sheet writes a 2x contact sheet
  (na, ea, mena x run low / mending / thriving).
"""
import argparse, json, math, os, random
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
SCENES = os.path.join(REPO, 'game', 'assets', 'img', 'scenes')

# ---------------------------------------------------------------------------------------------
# House palette (game/assets/img/ph/palette.json + the scene ink) and the prop sheet
# ---------------------------------------------------------------------------------------------
INK = (46, 26, 28)
CAVERN = (74, 66, 104)          # stone700 pulled toward dusk700: the underground hue the ruin leans to
WARM = (255, 214, 120)
PAL = {
    'k': INK, 'K': (74, 44, 34),
    'W': (240, 221, 170), 'w': (214, 180, 120), 'b': (166, 116, 70), 'B': (122, 74, 31),   # fresh + old wood
    's': (201, 197, 188), 'S': (139, 143, 150), 'T': (91, 100, 112),                        # stone
    'l': (164, 184, 106), 'm': (122, 181, 92), 'M': (79, 154, 69), 'n': (47, 90, 42),       # moss
    'c': (255, 244, 214), 'g': (245, 207, 106), 'G': (232, 163, 23), 'o': (240, 138, 36),   # light
    'r': (214, 50, 43), 'R': (168, 36, 31), 'p': (228, 106, 155), 'u': (63, 143, 176),
    'y': (217, 186, 124), 'Y': (170, 130, 80), 'v': (122, 92, 192),
}

SPRITES = {
    'rubble_a': [
        "....kkk.....",
        "...kssSk.kk.",
        "..kssSSkkssk",
        ".kkkSTTksSSk",
        "kssSkkkkSTTk",
        "kSSTTkkTTTk.",
        ".kkkk..kkk..",
    ],
    'rubble_b': [
        "..kkk..",
        ".ksSSk.",
        "kssSTkk",
        "kSTTksk",
        ".kkkkkk",
    ],
    'rubble_c': [
        "...kk...kk.",
        "..kbBk.kSk.",
        ".kbBk.kssSk",
        "kbBk.kkSTTk",
        "kkk..kkkkk.",
    ],
    'crack_a': ["..k..", "..k..", ".k...", ".k...", "..k..", "..kk.", "...k.", "..k.k", "..k.."],
    'crack_b': ["k....", ".k...", ".kk..", "...k.", "...k.", "..k.k", "..k.."],
    'crack_c': ["...k", "..k.", "..k.", ".kk.", "k..k", "k..."],
    'moss_cap': ["..lml...", ".lmMmml.", "lmMnMmMl"],
    'moss_cap_s': [".lm.", "lmMl"],
    'weeds': [".m..m.", ".M.mM.", "mMlM.m", "MnMnMM"],
    'board': [                                  # boarded window / door plank
        "kkkkkkkkkkkkkk",
        "kbwwwbwwwwbwwk",
        "kBbbbbbBbbbbBk",
        "kkkkkkkkkkkkkk",
    ],
    'ladder_seg': ["kWk...kWk", "kWk...kWk", "kWk...kWk", "kWkkkkkWk", "kWwwwwwWk", "kWkkkkkWk"],
    'ladder_top': ["kk.....kk", "kWk...kWk"],
    'planks': [
        "kkkkkkkkkkkkkkkk..",
        "kWWWWWWWWWWWWWWWk.",
        "kkkkkkkkkkkkkkkkkk",
        ".kWWWWWWWWWWWWWWWk",
        "kkkkkkkkkkkkkkkkkk",
        "kWWWWWWWWWWWWWWWk.",
        "kwwwwwwwwwwwwwwwk.",
        "kkkkkkkkkkkkkkkkk.",
    ],
    'crate': [
        "kkkkkkkkkk",
        "kWWWWWWWbk",
        "kWkwwwwkbk",
        "kWwkwwkwbk",
        "kWwwkkwwbk",
        "kWwwkkwwbk",
        "kWwkwwkwbk",
        "kWkwwwwkbk",
        "kbbbbbbbbk",
        "kkkkkkkkkk",
    ],
    'sack': [
        "..kkk..",
        ".kyyYk.",
        "..kYk..",
        ".kyyyYk",
        "kycyyYk",
        "kyyyyYk",
        "kYyyYYk",
        ".kkkkk.",
    ],
    'apples': [".krkrk.", "krRrRrk", "kkkkkkk"],
    'shelf': [
        "kkkkkkkkkkkkkkkkkkkk",
        "kWWWWWWWWWWWWWWWWWWk",
        "kbbbbbbbbbbbbbbbbbbk",
        "kkkkkkkkkkkkkkkkkkkk",
        ".kbk............kbk.",
        ".kbk............kbk.",
        ".kbk............kbk.",
        ".kkk............kkk.",
    ],
    'rope_coil': ["..kkkkk..", ".kyyyyyk.", "kykkkkkyk", "kyyyyyyyk", ".kkkkkkk."],
    'paper_lantern': ["..k..", ".kRk.", "kRrRk", "kGgGk", "kgcgk", "kGgGk", "kRrRk", ".kkk."],
    'work_lantern': ["..k..", ".k.k.", ".kkk.", "kTgTk", "kgcgk", "kgcgk", "kTgTk", "kkkkk"],
    'dark_lantern': ["..k..", ".k.k.", ".kkk.", "kTSTk", "kSTSk", "kTSTk", "kkkkk"],
    'flag': ["kkkkk", "kfffk", ".kfk.", "..k.."],
    'bucket': [".kkkkk.", "k.....k", "kSSSSSk", "kTsssTk", ".kTTTk.", ".kkkkk."],
    'sawhorse': ["kkkkkkkkkkkk", "kWWWWWWWWWWk", "kkkkkkkkkkkk", ".kbk....kbk.", "kbk......kbk", "kk........kk"],
    'pulley': [".kkk.", "kSsSk", "kskSk", "kSsSk", ".kkk."],
    'stake': ["kk", "kb", "kb", "kb", ".k"],
}


def stamp(a, name, x, y, flip=False, recol=None, alpha=None):
    """Draw sprite `name` with top-left (x, y). recol: {char: rgb} overrides."""
    g = SPRITES[name] if isinstance(name, str) else name
    H, W = a.shape[:2]
    for j, row in enumerate(g):
        if flip:
            row = row[::-1]
        for i, ch in enumerate(row):
            if ch == '.':
                continue
            col = (recol or {}).get(ch) or PAL.get(ch)
            if col is None:
                continue
            xx, yy = x + i, y + j
            if 0 <= xx < W and 0 <= yy < H:
                a[yy, xx] = col


def sprite_size(name):
    g = SPRITES[name]
    return len(g[0]), len(g)


# ---------------------------------------------------------------------------------------------
# Colour work
# ---------------------------------------------------------------------------------------------
def to_hsv(a):
    return np.array(Image.fromarray(a, 'RGB').convert('HSV')).astype(np.float32)


def lit_mask(a):
    """Lit lamps and windows: bright, saturated, yellow to orange."""
    h = to_hsv(a)
    return (h[..., 0] >= 12) & (h[..., 0] <= 42) & (h[..., 1] >= 128) & (h[..., 2] >= 242)


def frame_mask(shape):
    H, W = shape[:2]
    m = np.zeros((H, W), bool)
    m[:, :17] = True
    m[:, W - 17:] = True
    m[:15, :] = True
    return m


def overcast_rgb(a, strength=1.0):
    """The overcast colour map alone (no masks): also used to build a town picture's allowed palette."""
    H, W = a.shape[:2]
    st = np.full((H, W), strength, np.float32)
    hsv = to_hsv(a)
    hsv[..., 1] *= 1 - .48 * st
    hsv[..., 2] *= 1 - .16 * st
    rgb = np.array(Image.fromarray(np.clip(hsv, 0, 255).astype(np.uint8), 'HSV').convert('RGB')).astype(np.float32)
    t = (.16 * st)[..., None]
    rgb = rgb * (1 - t) + np.array(CAVERN, np.float32) * t
    return np.clip(np.rint(rgb), 0, 255).astype(np.uint8)


def overcast(a, strength=1.0, far_y=96, keep=None, lit=None, frame=True):
    """Desaturate, darken, pull toward the cavern hue. Lit pixels stay warm (lit: own lit mask, default lit_mask).
    frame=False: the 17 px border is recoloured too (town pictures: their frames vary in width)."""
    out = overcast_rgb(a, strength)
    k = (lit_mask(a) if lit is None else lit)
    if frame:
        k = k | frame_mask(a.shape)
    if keep is not None:
        k |= keep
    out[k] = a[k]
    return out


def darken_lights(a, box, to=None):
    """Lights out inside box: lit pixels become cold stone."""
    x0, y0, x1, y1 = box
    sub = a[y0:y1, x0:x1]
    m = lit_mask(sub)
    sub[m] = to or PAL['S']
    # the orange rims of the light go to stone shade
    h = to_hsv(sub)
    m2 = (h[..., 0] >= 10) & (h[..., 0] <= 40) & (h[..., 1] >= 120) & (h[..., 2] >= 200)
    sub[m2] = PAL['T']


def glow(a, cx, cy, r=8):
    """Warm lantern glow: checker-dithered lift toward WARM, hard pixels."""
    H, W = a.shape[:2]
    for y in range(max(0, cy - r), min(H, cy + r + 1)):
        for x in range(max(17, cx - r), min(W - 17, cx + r + 1)):
            d = math.hypot(x - cx, y - cy)
            if d > r or (x + y) % 2:
                continue
            t = .38 if d < r * .55 else .2
            a[y, x] = np.clip(a[y, x] * (1 - t) + np.array(WARM) * t, 0, 255).astype(np.uint8)


# ---------------------------------------------------------------------------------------------
# Healing, cutting, pasting
# ---------------------------------------------------------------------------------------------
def heal_rows(a, mask, maxlen=36):
    """Fill masked runs row by row with a mirrored copy of the pixels next to the run (texture continues)."""
    H, W = mask.shape
    for y in range(H):
        row = mask[y]
        if not row.any():
            continue
        x = 0
        while x < W:
            if not row[x]:
                x += 1
                continue
            s = x
            while x < W and row[x]:
                x += 1
            e = x  # run [s, e)
            n = e - s
            L = min(maxlen, max(4, n))
            left = [i for i in range(s - L, s) if 17 <= i and not row[i]]
            right = [i for i in range(e, e + L) if i < W - 17 and not row[i]]
            if len(left) >= len(right) and left:
                src = a[y, left][::-1]        # nearest first
            elif right:
                src = a[y, right]
            else:
                continue
            m = len(src)
            for i in range(n):
                k = i % (2 * m)
                k = k if k < m else 2 * m - 1 - k
                if left and len(left) >= len(right):
                    a[y, s + i] = src[k]
                else:
                    a[y, e - 1 - i] = src[k]


def heal_synth(a, mask, rng, reach=48, share=.12):
    """Fill masked pixels with the row's own common colours (dither noise of the ground / water band of that row).
    Colours under `share` of the row's pool are left out, so objects next to the hole are not copied in."""
    H, W = mask.shape
    for y in np.nonzero(mask.any(axis=1))[0]:
        xs = np.nonzero(mask[y])[0]
        lo, hi = max(17, xs.min() - reach), min(W - 17, xs.max() + reach + 1)
        pool = [tuple(a[y, x]) for x in range(lo, hi) if not mask[y, x]]
        if not pool:
            continue
        cnt = {}
        for c in pool:
            cnt[c] = cnt.get(c, 0) + 1
        keep = [(c, n) for c, n in cnt.items() if n >= share * len(pool)] or [max(cnt.items(), key=lambda t: t[1])]
        cols = [c for c, n in keep]
        wts = [n for c, n in keep]
        for x in xs:
            a[y, x] = rng.choices(cols, wts)[0]


def cut(a, mask):
    """RGBA image of the masked pixels (bbox) and its top-left."""
    ys, xs = np.nonzero(mask)
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    rgba = np.zeros((y1 - y0, x1 - x0, 4), np.uint8)
    rgba[..., :3] = a[y0:y1, x0:x1]
    rgba[..., 3] = mask[y0:y1, x0:x1] * 255
    return Image.fromarray(rgba, 'RGBA'), (int(x0), int(y0))


def paste(a, im, x, y, water=None, water_col=None, fill=False):
    """Paste RGBA im at (x, y). water = absolute y of a waterline: below it the piece is half seen through water."""
    r = np.array(im)
    H, W = a.shape[:2]
    hh, ww = r.shape[:2]
    for j in range(hh):
        for i in range(ww):
            if r[j, i, 3] < 128:
                continue
            xx, yy = x + i, y + j
            if not (17 <= xx < W - 17 and 15 <= yy < H):
                continue
            c = r[j, i, :3].astype(np.float32)
            if water is not None and yy > water:
                wc = np.array(water_col if water_col is not None else a[yy, xx], np.float32)
                if (xx + yy) % 2 == 0 or yy > water + 9:
                    if fill:                                     # hidden by water: water over it
                        a[yy, xx] = wc if (xx * 7 + yy * 3) % 23 else np.clip(wc + 40, 0, 255)
                    continue
                c = c * .45 + wc * .55
            a[yy, xx] = np.clip(c, 0, 255).astype(np.uint8)


def ripple(a, x0, x1, y, rng, col=(200, 236, 236)):
    for x in range(x0, x1):
        if rng.random() < .7:
            a[y, x] = col
    for x in (x0 - 3, x0 - 2, x1 + 1, x1 + 2):
        a[y + 1, x] = col


def ink_ring(a, mask):
    """1px ink outline round a newly drawn shape (mask)."""
    ring = np.zeros_like(mask)
    ring[1:] |= mask[:-1]; ring[:-1] |= mask[1:]
    ring[:, 1:] |= mask[:, :-1]; ring[:, :-1] |= mask[:, 1:]
    ring &= ~mask
    a[ring] = INK


def rect_mask(shape, *boxes):
    m = np.zeros(shape[:2], bool)
    for x0, y0, x1, y1 in boxes:
        m[y0:y1, x0:x1] = True
    return m


def shear(a, mask, k, base_y, rng):
    """Lean the masked piece: x' = x + k * (base_y - y). Heals what it leaves behind."""
    ys, xs = np.nonzero(mask)
    cols = a[ys, xs].copy()
    heal_synth(a, mask, rng)
    nx = np.rint(xs + k * (base_y - ys)).astype(int)
    ok = (nx >= 17) & (nx < a.shape[1] - 17)
    a[ys[ok], nx[ok]] = cols[ok]


def line(a, p0, p1, col):
    x0, y0 = p0; x1, y1 = p1
    n = int(max(abs(x1 - x0), abs(y1 - y0))) + 1
    for i in range(n):
        t = i / max(1, n - 1)
        x, y = round(x0 + (x1 - x0) * t), round(y0 + (y1 - y0) * t)
        if 0 <= x < a.shape[1] and 0 <= y < a.shape[0]:
            a[y, x] = col


def sag(a, p0, p1, drop, col, step_cb=None, every=7):
    """Sagging string (rope, bunting line) from p0 to p1, dropping `drop` px in the middle."""
    x0, y0 = p0; x1, y1 = p1
    n = int(abs(x1 - x0)) + 1
    pts = []
    for i in range(n):
        t = i / max(1, n - 1)
        x = round(x0 + (x1 - x0) * t)
        y = round(y0 + (y1 - y0) * t + drop * 4 * t * (1 - t))
        pts.append((x, y))
    for (xa, ya), (xb, yb) in zip(pts, pts[1:]):
        line(a, (xa, ya), (xb, yb), col)
    if step_cb:
        for i, (x, y) in enumerate(pts[every // 2::every]):
            step_cb(i, x, y)
    return pts


# ---------------------------------------------------------------------------------------------
# Overgrowth and builder's props
# ---------------------------------------------------------------------------------------------
def roof_line(a, x, y0, y1):
    """First dark outline pixel from y0 down in column x (top of the building)."""
    for y in range(y0, y1):
        if int(a[y, x].sum()) < 190:
            return y
    return None


def overgrow(a, box, rng, moss=6, ivy=5, rubble=4, cracks=3, weeds=5, skip=None):
    x0, y0, x1, y1 = box
    skip = skip or (lambda x, y: False)
    for _ in range(moss):
        x = rng.randint(x0 + 4, x1 - 8)
        y = roof_line(a, x, y0, y1)
        if y is not None and not skip(x, y):
            stamp(a, 'moss_cap' if rng.random() < .6 else 'moss_cap_s', x - 3, y)
    for _ in range(ivy):                                         # ivy climbs from the ground up the wall
        x = rng.randint(x0 + 3, x1 - 3)
        yb = y1 - rng.randint(0, 3)
        if skip(x, yb):
            continue
        n = rng.randint(8, 22)
        cx = x
        for j in range(n):
            if rng.random() < .3:
                cx += rng.choice((-1, 1))
            cx = max(x - 2, min(x + 2, cx))
            yy = yb - j
            a[yy, cx] = PAL['n'] if j % 3 else PAL['M']
            if rng.random() < .45:
                a[yy, cx + rng.choice((-1, 1))] = PAL['m'] if rng.random() < .6 else PAL['l']
    for _ in range(cracks):
        for _try in range(30):
            x = rng.randint(x0 + 4, x1 - 8)
            y = rng.randint(y0 + (y1 - y0) // 3, y1 - 12)
            h = to_hsv(a[y:y + 2, x:x + 2])
            if h[..., 2].min() > 175 and h[..., 1].max() < 110 and not skip(x, y):
                stamp(a, rng.choice(['crack_a', 'crack_b', 'crack_c']), x, y)
                break
    for _ in range(rubble):
        nm = rng.choice(['rubble_a', 'rubble_b', 'rubble_c'])
        w, h = sprite_size(nm)
        x = rng.randint(x0, x1 - w)
        if not skip(x, y1):
            stamp(a, nm, x, y1 - h + rng.randint(0, 3), flip=rng.random() < .5)
    for _ in range(weeds):
        x = rng.randint(x0, x1 - 6)
        if not skip(x, y1):
            stamp(a, 'weeds', x, y1 - 3 + rng.randint(0, 3))


def ladder(a, x, ytop, ybot):
    stamp(a, 'ladder_top', x, ytop)
    y = ytop + 2
    while y < ybot:
        stamp(a, 'ladder_seg', x, y)
        y += 6


def pole(a, x, ytop, ybot):
    a[ytop:ybot, x - 1] = INK
    a[ytop:ybot, x] = PAL['W']
    a[ytop:ybot, x + 1] = PAL['b']
    a[ytop:ybot, x + 2] = INK
    a[ytop - 1, x - 1:x + 3] = INK


def walkboard(a, x0, x1, y):
    a[y, x0:x1] = INK
    a[y + 1, x0:x1] = PAL['W']
    a[y + 2, x0:x1] = PAL['w']
    a[y + 3, x0:x1] = INK
    for x in range(x0 + 5, x1 - 2, 9):                          # board joints
        a[y + 1:y + 3, x] = PAL['b']


def scaffold(a, box, bay=20, lift=18, brace=True):
    """Scaffold sized to a box: poles every `bay`, walkboards every `lift`, one X brace per bay."""
    x0, y0, x1, y1 = box
    xs = list(range(x0, x1 + 1, bay))
    if xs[-1] < x1 - 6:
        xs.append(x1)
    lifts = list(range(y1 - lift, y0 - 1, -lift))
    if brace:
        for xa, xb in zip(xs, xs[1:]):
            line(a, (xa + 1, y1 - 2), (xb, y1 - lift + 3), PAL['B'])
            line(a, (xa + 1, y1 - lift + 3), (xb, y1 - 2), PAL['B'])
    for x in xs:
        pole(a, x, y0, y1)
    for y in lifts:
        walkboard(a, x0 - 3, x1 + 5, y)
    return lifts


def lantern_on(a, x, y, name='work_lantern'):
    w, h = sprite_size(name)
    line(a, (x + w // 2, y - 3), (x + w // 2, y), INK)
    glow(a, x + w // 2, y + h // 2, 9)
    stamp(a, name, x, y)


def bunting(a, p0, p1, drop, rng):
    cols = [PAL['r'], PAL['g'], PAL['u'], PAL['p'], PAL['m'], PAL['c']]
    sag(a, p0, p1, drop, PAL['K'],
        lambda i, x, y: stamp(a, 'flag', x - 2, y, recol={'f': cols[i % len(cols)]}), every=7)


def lantern_string(a, p0, p1, drop):
    def put(i, x, y):
        if i % 2 == 0:
            glow(a, x, y + 5, 6)
            stamp(a, 'paper_lantern', x - 2, y + 1)
    sag(a, p0, p1, drop, INK, put, every=11)


# ---------------------------------------------------------------------------------------------
# Kind recipes. Coordinates are for the grassland_maplewold look (layout boxes from here_layouts.json);
# the other looks need their own numbers (or the `do` box rule) - see the hand-work note in the proposal.
# ---------------------------------------------------------------------------------------------
KINDS = {
    'mill': {
        'do': (90, 100, 222, 196),
        'over': (90, 104, 172, 196),           # where moss / ivy / rubble grow (the mill house)
        'work_mask': dict(box=(88, 98, 176, 200), dir=(1, .8), cut=74, step=6),
        'stock': (40, 178, 'door_left'),
        'lit': ((92, 136), (170, 136), 8),
    },
    'shrine': {
        'do': (186, 56, 296, 140),
        'over': (186, 60, 296, 106),
        'work_mask': dict(box=(184, 54, 300, 106), dir=(1, .55), cut=58, step=6),
        'stock': (300, 186, 'right'),
        'lit': ((186, 104), (296, 104), 7),
    },
    'ferry': {
        'do': (270, 116, 368, 158),
        'over': (24, 150, 104, 214),           # the toll hut on the shore grows over
        'work_mask': dict(box=(20, 140, 214, 216), dir=(1, .6), cut=120, step=6),
        'stock': (300, 200, 'right'),
        'lit': ((26, 160), (102, 160), 6),
    },
}


def ruin_mill(a, src, rng):
    # 1 the wheel comes off its axle and drops into the race, half sunk and tilted
    cx, cy, R = 193, 170, 29
    yy, xx = np.mgrid[0:a.shape[0], 0:a.shape[1]]
    circ = ((xx - cx) ** 2 + (yy - cy) ** 2 <= R * R) & (yy < 199)
    h = to_hsv(src)
    water = src[..., 2].astype(int) > src[..., 0].astype(int) + 10
    wood = (h[..., 2] < 190) & ~water & ~((h[..., 1] < 50) & (h[..., 2] > 110))
    wheel = circ & wood
    grow = wheel.copy()                                          # take the outline pixels too
    grow[1:] |= wheel[:-1]; grow[:-1] |= wheel[1:]; grow[:, 1:] |= wheel[:, :-1]; grow[:, :-1] |= wheel[:, 1:]
    wheel = grow & circ & ~((h[..., 1] > 90) & (h[..., 2] > 190))
    stream = rect_mask(a.shape, (184, 136, 224, 199)) & water
    piece, (px0, py0) = cut(a, wheel)
    heal_synth(a, wheel | stream, rng, reach=30, share=.2)
    stamp(a, ['.kkk.', 'kSsSk', 'kskTk', 'kSTSk', '.kkk.'], cx - 2, cy - 2)       # bare axle
    for y in range(142, 172, 2):                                                 # a dribble from the dry flume
        a[y, 207 + (y // 6) % 2] = (190, 220, 226)
    p = piece.rotate(16, resample=Image.NEAREST, expand=True)
    wl = 199
    vals, cnt = np.unique(a[214:250, 40:120].reshape(-1, 3), axis=0, return_counts=True)
    pond = tuple(int(v) for v in vals[cnt.argmax()])           # the pond's main water colour
    paste(a, p, px0 - 10 - (p.width - piece.width) // 2, py0 + 20 - (p.height - piece.height) // 2,
          water=wl, water_col=pond, fill=True)
    ripple(a, 160, 222, wl + 1, rng)
    # 2 windows boarded, gable window too
    stamp(a, 'board', 132, 149); stamp(a, 'board', 148, 151); stamp(a, ['kkkkkkkk', 'kbwwbwwk', 'kkkkkkkk'], 128, 121)
    # 3 split sacks by the wall
    stamp(a, 'sack', 70, 196); stamp(a, ['.yy.y', 'yyYyy'], 78, 202)


def ruin_shrine(a, src, rng):
    # 1 lanterns out (the shrine's own stone lanterns; the frame lanterns and far windows stay warm)
    for b in ((186, 158, 202, 186), (278, 158, 294, 186), (160, 206, 186, 240), (292, 206, 318, 240),
              (210, 136, 222, 150), (258, 136, 270, 150), (226, 92, 256, 106)):
        darken_lights(a, b)
    h = to_hsv(src)
    # 2 the right stone lantern leans on its base
    lmask = rect_mask(a.shape, (279, 158, 293, 185)) & ((h[..., 1] < 70) | (src.sum(axis=2) < 200))
    shear(a, lmask, .3, 184, rng)
    # 3 the torii leans, its kasagi end snapped off and lying across the path
    red = ((h[..., 0] < 12) | (h[..., 0] > 240)) & (h[..., 1] > 70)
    dark = src.sum(axis=2) < 330
    beams = rect_mask(a.shape, (183, 106, 297, 124), (196, 130, 286, 138), (233, 121, 248, 133))
    legs = rect_mask(a.shape, (201, 118, 212, 202), (268, 118, 281, 202)) & (red | dark)
    torii = beams | legs
    tip = torii & rect_mask(a.shape, (282, 104, 298, 124))
    tp, _ = cut(a, tip)
    heal_synth(a, tip, rng)
    shear(a, torii & ~tip, .15, 200, rng)
    paste(a, tp.rotate(-80, resample=Image.NEAREST, expand=True), 240, 192)
    for y, x in ((108, 296), (110, 297), (112, 296), (114, 297), (116, 296), (118, 297)):
        a[y, x] = INK


def ruin_ferry(a, src, rng):
    # 1 the raft has gone under: folk and cargo ashore (cleared), the deck tilted and half sunk
    water = src[..., 2].astype(int) >= src[..., 0].astype(int) - 4
    deck = rect_mask(a.shape, (270, 140, 371, 160)) & ~water
    posts = rect_mask(a.shape, (272, 126, 279, 146), (358, 126, 366, 146)) & ~water
    piece, _ = cut(a, deck | posts)
    heal_synth(a, rect_mask(a.shape, (268, 110, 373, 126)), rng, reach=90, share=.2)
    heal_synth(a, rect_mask(a.shape, (268, 126, 373, 161)), rng)
    p = piece.rotate(-6, resample=Image.NEAREST, expand=True)
    wl = 157
    paste(a, p, 270, 130, water=wl)
    ripple(a, 268, 300, wl + 1, rng)
    # floating cargo
    stamp(a, 'crate', 384, 151)
    a[158:161, 383:395] = a[158:161, 370:382]; ripple(a, 384, 394, 158, rng)
    stamp(a, ['.kkkk.', 'kTSSTk', 'kTSSTk', 'kkkkkk'], 238, 152)
    # 2 the haul rope snapped, its end trailing on the water
    sag(a, (266, 151), (284, 157), 3, (130, 96, 64))
    # 3 the dock lamp post leans (its lamp still warm)
    h = to_hsv(src)
    post = rect_mask(a.shape, (274, 156, 289, 212))
    post &= (h[..., 1] < 100) | (src.sum(axis=2) < 330) | lit_mask(src)
    shear(a, post, -.16, 211, rng)
    # 4 the toll hut boarded up
    stamp(a, 'board', 36, 186); stamp(a, 'board', 52, 190); stamp(a, 'board', 66, 187)


RUIN = {'mill': ruin_mill, 'shrine': ruin_shrine, 'ferry': ruin_ferry}


def ruin(img, kind, seed=None):
    src = np.array(img.convert('RGB'))
    rng = random.Random(seed if seed is not None else hash(kind) & 0xffff)
    k = KINDS[kind]
    a = overcast(src, 1.0)
    x0, y0, x1, y1 = k['do']
    if kind == 'mill':
        darken_lights(a, (x0, y0, x1 + 1, y1 + 1))
    RUIN[kind](a, src, rng)
    overgrow(a, k['over'], rng)
    return Image.fromarray(a)


def stepped_mask(shape, box, dir, cut, step):
    """True on the ruined side of a stepped diagonal over box (hard steps, no soft edge)."""
    x0, y0, x1, y1 = box
    yy, xx = np.mgrid[0:shape[0], 0:shape[1]]
    q = ((xx - x0) // step) * step * dir[0] + ((yy - y0) // step) * step * dir[1]
    return (q < cut) & rect_mask(shape, box)


def work(img, kind, ruined=None, seed=None):
    src = np.array(img.convert('RGB'))
    rng = random.Random((seed if seed is not None else hash(kind) & 0xffff) + 1)
    k = KINDS[kind]
    r = np.array((ruined or ruin(img, kind)).convert('RGB'))
    a = overcast(src, .45)
    damage = (r.astype(int) != overcast(src, 1.0).astype(int)).any(axis=2)
    m = stepped_mask(a.shape, **k['work_mask']) & damage      # only the damage stays on the unmended side
    a[m] = r[m]
    WORK[kind](a, src, rng, m)
    return Image.fromarray(a)


def mask_edge_points(m):
    """Lowest/rightmost boundary pixels of the ruined side, as a list of (x, y)."""
    ys, xs = np.nonzero(m)
    pts = {}
    for x, y in zip(xs, ys):
        pts[x] = max(pts.get(x, 0), y)
    return sorted(pts.items())


def work_mill(a, src, rng, m):
    scaffold(a, (126, 120, 166, 186), bay=20, lift=22)
    ladder(a, 94, 146, 196)
    lantern_on(a, 160, 103)
    line(a, (160, 100), (166, 98), INK)
    stamp(a, 'planks', 98, 196)
    stamp(a, 'sawhorse', 60, 194)
    # wheel held by a block and rope while it beds in
    stamp(a, 'pulley', 211, 128)
    line(a, (213, 133), (205, 150), PAL['y']); line(a, (214, 133), (206, 150), PAL['Y'])
    stamp(a, 'rope_coil', 226, 196)
    stamp(a, 'bucket', 176, 202)
    # half the paddles new: fresh wood on the left of the wheel rim
    for y in range(144, 198):
        for x in range(166, 193):
            c = src[y, x].astype(int)
            if (x - 193) ** 2 + (y - 170) ** 2 <= 28 * 28 and 90 < c[0] < 190 and c[0] > c[2] + 40 and c[1] < 140:
                a[y, x] = PAL['w'] if c[0] > 140 else PAL['b']


def work_shrine(a, src, rng, m):
    scaffold(a, (192, 70, 228, 104), bay=18, lift=16)
    lantern_on(a, 224, 60)
    line(a, (226, 57), (232, 56), INK)
    ladder(a, 190, 128, 200)
    # guy ropes holding the torii true while the feet set
    line(a, (184, 112), (168, 200), PAL['y']); stamp(a, 'stake', 167, 199)
    line(a, (296, 112), (314, 198), PAL['y']); stamp(a, 'stake', 313, 197)
    stamp(a, 'planks', 288, 200)
    stamp(a, 'bucket', 180, 196)
    # one stone lantern relit, the right one still cold
    darken_lights(a, (278, 158, 294, 186))
    glow(a, 194, 170, 7)


def work_ferry(a, src, rng, m):
    scaffold(a, (28, 150, 100, 206), bay=24, lift=20)
    lantern_on(a, 96, 140)
    line(a, (98, 137), (104, 136), INK)
    ladder(a, 106, 160, 212)
    # fresh planks on the left of the raft deck
    for y in range(144, 158):
        for x in range(272, 318):
            c = src[y, x].astype(int)
            if c[0] > c[2] + 30 and c.sum() > 260:
                a[y, x] = PAL['W'] if c.sum() > 480 else (PAL['w'] if c.sum() > 380 else PAL['b'])
    stamp(a, 'rope_coil', 300, 196)
    stamp(a, 'planks', 316, 204)
    stamp(a, 'sawhorse', 296, 214)


WORK = {'mill': work_mill, 'shrine': work_shrine, 'ferry': work_ferry}


def fixed(img, kind, layers=()):
    """The finished scene; layers 'stocked' (crates, sacks, shelf) and 'lit' (lanterns + bunting) compose."""
    a = np.array(img.convert('RGB'))
    k = KINDS[kind]
    rng = random.Random(5)
    if 'lit' in layers:
        p0, p1, d = k['lit']
        bunting(a, (p0[0], p0[1] + 2), (p1[0], p1[1] + 2), d + 3, rng)
        lantern_string(a, p0, p1, d)
    if 'stocked' in layers:
        x, y, side = k['stock']
        stamp(a, 'shelf', x, y)
        stamp(a, 'apples', x + 3, y - 3); stamp(a, 'apples', x + 10, y - 3)
        stamp(a, 'crate', x + 2, y + 8); stamp(a, 'crate', x + 11, y + 8)
        stamp(a, 'sack', x + 22, y + 10)
    return Image.fromarray(a)


# ---------------------------------------------------------------------------------------------
# Contact sheet with a 5x7 pixel font
# ---------------------------------------------------------------------------------------------
FONT = {
    'A': ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
    'B': ["11110", "10001", "10001", "11110", "10001", "10001", "11110"],
    'C': ["01111", "10000", "10000", "10000", "10000", "10000", "01111"],
    'D': ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
    'E': ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
    'F': ["11111", "10000", "10000", "11110", "10000", "10000", "10000"],
    'G': ["01111", "10000", "10000", "10011", "10001", "10001", "01111"],
    'H': ["10001", "10001", "10001", "11111", "10001", "10001", "10001"],
    'I': ["11111", "00100", "00100", "00100", "00100", "00100", "11111"],
    'J': ["00111", "00010", "00010", "00010", "10010", "10010", "01100"],
    'K': ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
    'L': ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
    'M': ["10001", "11011", "10101", "10101", "10001", "10001", "10001"],
    'N': ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
    'O': ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
    'P': ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
    'Q': ["01110", "10001", "10001", "10001", "10101", "10010", "01101"],
    'R': ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
    'S': ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
    'T': ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
    'U': ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
    'V': ["10001", "10001", "10001", "10001", "10001", "01010", "00100"],
    'W': ["10001", "10001", "10001", "10101", "10101", "11011", "10001"],
    'X': ["10001", "10001", "01010", "00100", "01010", "10001", "10001"],
    'Y': ["10001", "10001", "01010", "00100", "00100", "00100", "00100"],
    'Z': ["11111", "00001", "00010", "00100", "01000", "10000", "11111"],
    '0': ["01110", "10011", "10101", "10101", "11001", "10001", "01110"],
    '1': ["00100", "01100", "00100", "00100", "00100", "00100", "01110"],
    '2': ["01110", "10001", "00001", "00110", "01000", "10000", "11111"],
    '3': ["11110", "00001", "00001", "01110", "00001", "00001", "11110"],
    '-': ["00000", "00000", "00000", "11111", "00000", "00000", "00000"],
    '+': ["00000", "00100", "00100", "11111", "00100", "00100", "00000"],
    ':': ["00000", "00100", "00100", "00000", "00100", "00100", "00000"],
    ' ': ["00000"] * 7,
}


def text(a, s, x, y, col, scale=2):
    for ch in s.upper():
        g = FONT.get(ch, FONT[' '])
        for j, row in enumerate(g):
            for i, v in enumerate(row):
                if v == '1':
                    a[y + j * scale:y + (j + 1) * scale, x + i * scale:x + (i + 1) * scale] = col
        x += 6 * scale


def contact(rows, path, scale=2, labels=('RUINED', 'WORKING', 'FIXED')):
    """rows: [(kind, [img, img, img])]. Panels at `scale`x, label above each in the 5x7 font."""
    W, H = 480 * scale, 270 * scale
    g, lh = 12, 7 * scale + 10
    sheet = np.zeros((g + len(rows) * (lh + H + g), g + 3 * (W + g), 3), np.uint8)
    sheet[:] = INK
    for r, (kind, imgs) in enumerate(rows):
        for c, im in enumerate(imgs):
            x = g + c * (W + g)
            y = g + r * (lh + H + g)
            text(sheet, f'{kind} - {labels[c]}', x + 2, y + 2, PAL['c'], scale)
            sheet[y + lh:y + lh + H, x:x + W] = np.array(im.convert('RGB').resize((W, H), Image.NEAREST))
    Image.fromarray(sheet).save(path)


# ---------------------------------------------------------------------------------------------
# Town recipe (claude/proposal-town-states.md section 2): run low (ruin) and mending (work) twins of the 14 region towns,
# the generic here-town.png and the stop-market.png header. Every position comes from the layout boxes.
# ---------------------------------------------------------------------------------------------
LAYOUTS = os.path.join(REPO, 'game', 'includes', 'data', 'here_layouts.json')
TOWN_CODES = ['ca', 'cb', 'sa', 'nwe', 'se', 'ee', 'mena', 'wca', 'esa', 'csa', 'ea', 'na', 'sea', 'oc']   # hub: never (decision 1)
# stop-market.png (the town header) has no layout key: its three stalls, the middle one is the shop that stays open
MARKET_HEADER_SPOTS = [('stall_l', 'board', (8, 60, 158, 205)), ('stall_m', 'shops', (166, 60, 318, 205)), ('stall_r', 'green', (326, 60, 474, 205))]

SPRITES.update({
    'patch': ["kkkkk", "kSTSk", "kTsTk", "kkkkk"],
    'patch_w': ["kkkkkk", "kBbbBk", "kbBBbk", "kkkkkk"],
    'cart': [                                       # an empty hand cart, shafts down
        "kkkkkkkkkkkkkkkkkk....",
        "kWWWWWWWWWWWWWWWWk....",
        "kbwwwbwwwwbwwwwwbk....",
        "kBbbbBbbbbBbbbbbBkkkkk",
        "kkkkkkkkkkkkkkkkkkWWWk",
        "...kkk.......kkk..kkkk",
        "..kSTSk.....kSTSk.....",
        "..kTkTk.....kTkTk.....",
        "...kkk.......kkk......",
    ],
    'open_sign': ["..k....k..", "..k....k..", "kkkkkkkkkk", "kWWWWWWWWk", "kWmMmMmMWk", "kWWWWWWWWk", "kkkkkkkkkk"],
})


def town_spots(key):
    """[(k, behaviour, box)] of a town picture from here_layouts.json. The generic 'town' layout has no boxes: 72 x 64 round each spot."""
    if key == 'stop-market':
        return list(MARKET_HEADER_SPOTS)
    L = json.load(open(LAYOUTS))[key]
    out = []
    for s in L['spots']:
        b = s.get('box') or [s['x'] - 36, s['y'] - 56, s['x'] + 36, s['y'] + 8]
        b = (max(17, b[0]), max(15, b[1]), min(463, b[2]), min(269, b[3]))
        out.append((s['k'], s.get('as', s['k']), b))
    return out


def centre(box, f=.3):
    """The middle of a spot box (f of each side cut off): no prop may cover it."""
    x0, y0, x1, y1 = box
    w, h = x1 - x0, y1 - y0
    return (x0 + int(w * f), y0 + int(h * f), x1 - int(w * f), y1 - int(h * f))


def components(m, maxn=60):
    """Connected parts (4-neighbour) of a bool mask: list of (n, x0, y0, x1, y1). Parts bigger than maxn are counted but not kept."""
    H, W = m.shape
    seen = np.zeros_like(m)
    out = []
    for y0, x0 in zip(*np.nonzero(m)):
        if seen[y0, x0]:
            continue
        st = [(y0, x0)]; seen[y0, x0] = True
        n, bx0, by0, bx1, by1 = 0, x0, y0, x0, y0
        while st:
            y, x = st.pop(); n += 1
            bx0, by0, bx1, by1 = min(bx0, x), min(by0, y), max(bx1, x), max(by1, y)
            for yy, xx in ((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)):
                if 0 <= yy < H and 0 <= xx < W and m[yy, xx] and not seen[yy, xx]:
                    seen[yy, xx] = True; st.append((yy, xx))
        out.append((n, int(bx0), int(by0), int(bx1) + 1, int(by1) + 1))
    return out


def small_lit(src, maxn=48):
    """Lamps and lit windows only: lit_mask parts up to maxn pixels (a yellow wall is not a light)."""
    m = lit_mask(src)
    keep = np.zeros_like(m)
    for n, x0, y0, x1, y1 in components(m):
        if n <= maxn and (x1 - x0) <= 14 and (y1 - y0) <= 14:
            keep[y0:y1, x0:x1] |= m[y0:y1, x0:x1]
    return keep


class Props:
    """Stamps props and remembers where; refuses any prop over a spot box centre (the building must stay readable)."""

    def __init__(self, a, spots):
        self.a = a
        self.no = np.zeros(a.shape[:2], bool)
        for _, _, b in spots:
            x0, y0, x1, y1 = centre(b)
            self.no[y0:y1, x0:x1] = True
        self.used = np.zeros(a.shape[:2], bool)

    def free(self, x, y, w, h):
        H, W = self.no.shape
        if x < 17 or y < 15 or x + w > W - 17 or y + h > H:
            return False
        return not (self.no[y:y + h, x:x + w].any() or self.used[y:y + h, x:x + w].any())

    def mark(self, x, y, w, h):
        self.used[max(0, y):y + h, max(0, x):x + w] = True

    def put(self, name, x, y, flip=False):
        w, h = sprite_size(name)
        if not self.free(x, y, w, h):
            return False
        stamp(self.a, name, x, y, flip=flip)
        self.mark(x, y, w, h)
        return True

    def first(self, name, cands, flip=False):
        for x, y in cands:
            if self.put(name, x, y, flip):
                return (x, y)
        return None

    def lamp(self, cands, name='work_lantern'):
        w, h = sprite_size(name)
        for x, y in cands:
            if self.free(x - 9, y - 9, w + 18, h + 18):
                lantern_on(self.a, x, y, name)
                self.mark(x - 9, y - 9, w + 18, h + 18)
                return (x, y)
        return None


def shutter(a, x0, y0, x1, y1):
    """Closed shutters over a window bbox: two plank leaves, ink outline and middle line."""
    x0, y0, x1, y1 = x0 - 1, y0 - 1, x1 + 1, y1 + 1
    a[y0:y1, x0:x1] = PAL['b']
    for y in range(y0 + 2, y1 - 1, 2):
        a[y, x0 + 1:x1 - 1] = PAL['B']
    a[y0, x0:x1] = INK; a[y1 - 1, x0:x1] = INK
    a[y0:y1, x0] = INK; a[y0:y1, x1 - 1] = INK
    if x1 - x0 >= 6:
        a[y0:y1, (x0 + x1) // 2] = INK


def corner_cands(box, w, h, inside=True):
    """Prop positions round a box, corners first (never the centre): bottom corners just inside/outside, then top corners."""
    x0, y0, x1, y1 = box
    c = [(x0 + 2, y1 - h - 1), (x1 - w - 2, y1 - h - 1), (x0 - w - 2, y1 - h), (x1 + 2, y1 - h),
         (x0 + 2, y0 + 2), (x1 - w - 2, y0 + 2), (x0 + 2, y1 - h + 6), (x1 - w - 2, y1 - h + 6)]
    return c if inside else c[2:4] + c[:2] + c[4:]


def town_palette(fixed, strength=.6):
    """The palette a twin may use: the fixed picture's colours, their overcast twins (ruin strength and 1.0) and the house prop palette."""
    cols = np.array(sorted({c[1][:3] for c in Image.fromarray(fixed).getcolors(1 << 20)}), np.uint8)[None]
    allc = np.concatenate([cols[0], overcast_rgb(cols, strength)[0], overcast_rgb(cols, 1.0)[0], np.array(list(PAL.values()), np.uint8)])
    return np.unique(allc, axis=0)


def snap(a, pal):
    """Every pixel to its nearest palette colour (hard, no dither)."""
    flat = a.reshape(-1, 3)
    u, inv = np.unique(flat, axis=0, return_inverse=True)
    d = ((u[:, None, :].astype(np.int32) - pal[None].astype(np.int32)) ** 2).sum(axis=2)
    return pal[d.argmin(axis=1)][inv.reshape(-1)].reshape(a.shape)


def visible(a, b):
    """Pixels that visibly differ: RGB distance >= 36 (a plain tone shift of the overcast is mostly below it)."""
    return np.sqrt(((a.astype(np.int32) - b.astype(np.int32)) ** 2).sum(axis=2)) >= 36


def shop_keep(src, shops, ring=24, share=.02):
    """The shop spots' own pixels: inside each shop box, minus colours that are common in a ring round it (sky, ground),
    so the kept colour reads as a lit building, not as a rectangle."""
    H, W = src.shape[:2]
    keep = np.zeros((H, W), bool)
    codes = (src[..., 0].astype(np.int32) << 16) | (src[..., 1].astype(np.int32) << 8) | src[..., 2]
    for x0, y0, x1, y1 in shops:
        box = rect_mask(src.shape, (x0, y0, x1, y1))
        out = rect_mask(src.shape, (max(0, x0 - ring), max(0, y0 - ring), min(W, x1 + ring), min(H, y1 + ring))) & ~box
        vals, cnt = np.unique(codes[out], return_counts=True)
        bg = vals[cnt >= share * out.sum()]
        keep |= box & ~np.isin(codes, bg)
    return keep


def town_strength(src, keep, aim=.15):
    """Overcast strength for a town ruin: the strongest of .4 .. 1.0 (steps of .025) whose recolour alone, snapped to the
    twin palette, changes at most `aim` of the picture visibly (see visible()); props add a few % on top.
    Lands at .4 to .6 for most towns; dusk towns (already grey) get more."""
    best = .4
    for s in np.arange(.4, 1.001, .025):
        s = round(float(s), 3)
        d = visible(snap(overcast(src, s, keep=keep, lit=small_lit(src) & keep, frame=False), town_palette(src, s)), src)
        if d.mean() <= aim:
            best = s
    return best


def town_ruin(src, spots, seed, strength=.6):
    """Run low: overcast at town_strength() (about .4 to .8), the shop spots keep colour, lamp lit and an OPEN board; other lights out, half the
    lit windows shuttered, banners faded, patches on the roofs, moss and weeds (no rubble, no holes), an empty cart."""
    rng = random.Random(seed)
    shops = [b for _, beh, b in spots if beh == 'shops']
    keep = shop_keep(src, shops)
    lit = small_lit(src)
    a = overcast(src, strength, keep=keep, lit=lit & keep, frame=False)            # only the shops keep their lights
    band = min(b[1] for _, _, b in spots)                       # banners down: small bright flags above the buildings fade to grey
    h = to_hsv(src)
    flags = (h[..., 1] >= 110) & (h[..., 2] >= 120)
    flags[max(0, band + 10):] = False
    sky = np.zeros(src.shape[:2], bool)
    for n, x0, y0, x1, y1 in components(flags):
        if n <= 40 and x1 - x0 <= 10 and y1 - y0 <= 10:
            sky[y0:y1, x0:x1] |= flags[y0:y1, x0:x1]
    sky &= ~keep
    a[sky] = overcast_rgb(src, 1.0)[sky]
    P = Props(a, spots)
    for k, beh, b in spots:
        if beh == 'shops':
            continue
        x0, y0, x1, y1 = b
        wins = [c for c in components(lit[y0:y1, x0:x1]) if c[0] >= 4 and 2 <= c[3] - c[1] <= 12 and 2 <= c[4] - c[2] <= 12]
        for n, wx0, wy0, wx1, wy1 in wins:
            if rng.random() < .6 and not P.no[y0 + wy0 - 1:y0 + wy1 + 1, x0 + wx0 - 1:x0 + wx1 + 1].any():
                shutter(a, x0 + wx0, y0 + wy0, x0 + wx1, y0 + wy1)
    base = a.copy()                                             # recolour + shutters: what the box centres keep
    for k, beh, b in spots:
        if beh == 'shops':
            continue
        x0, y0, x1, y1 = b
        for _ in range(2):                                      # patches on the roof
            for _try in range(12):
                x = rng.randint(x0 + 3, max(x0 + 4, x1 - 9))
                y = roof_line(a, x, y0, y1)
                if y is not None and P.put(rng.choice(['patch', 'patch_w']), x, y + 2):
                    break
        skip = lambda x, y: P.no[min(y, 269), min(x, 479)] or P.no[max(15, min(y - 4, 269)), min(x + 4, 479)]
        overgrow(a, b, rng, moss=3, ivy=0, rubble=0, cracks=1, weeds=3, skip=skip)
    for b in shops:                                             # the shop: lamp on, OPEN board, warm door glow
        w, h = sprite_size('work_lantern')
        P.lamp(corner_cands(b, w, h)[4:6] + corner_cands(b, w, h)[:2])
        P.first('open_sign', corner_cands(b, *sprite_size('open_sign')))
    g = [b for _, beh, b in spots if beh == 'green'] or [spots[0][2]]
    cw, ch = sprite_size('cart')
    P.first('cart', corner_cands(g[0], cw, ch) + corner_cands(spots[-1][2], cw, ch), flip=rng.random() < .5)
    a[P.no] = base[P.no]                                        # no wear or prop over a spot's centre, ever
    return a


def town_work(src, ruined, spots, seed):
    """Mending: the fixed picture with a stepped half still run low, scaffold on the two widest buildings, a cart being
    unloaded and crates at the shop, the shelf out, more lamps lit."""
    rng = random.Random(seed + 1)
    a = src.copy()
    m = stepped_mask(a.shape, (0, 0, 480, 270), (1, .7), 360, 8)
    a[m] = ruined[m]
    base = a.copy()
    P = Props(a, spots)
    shops = [b for _, beh, b in spots if beh == 'shops']
    others = sorted([(b[2] - b[0], k, b) for k, beh, b in spots if beh in ('teahouse', 'library', 'homes')], reverse=True)   # buildings only (special spots can be ponds, trees)
    for _, k, b in others[:3]:                                  # scaffold on an outer third of the box (left, else right), clear of its centre, only against a wall
        x0, y0, x1, y1 = b
        w = int((x1 - x0) * .3) - 10
        if w < 12:
            continue
        top = y0 + int((y1 - y0) * .2)
        lift = max(12, (y1 - top) // 3)
        own = shop_keep(src, [b])                               # the building's own pixels (not sky / ground)
        for sx0 in (max(20, x0 + 3), x1 - 6 - w):
            if P.free(sx0 - 3, top - 1, w + 9, y1 - top) and own[top:y1, sx0:sx0 + w].mean() >= .5:
                scaffold(a, (sx0, top, sx0 + w, y1 - 2), bay=max(10, w // 2), lift=lift)
                P.mark(sx0 - 3, top - 1, w + 9, y1 - top)
                break
    for b in shops[:1]:
        cw, ch = sprite_size('cart')
        at = P.first('cart', corner_cands(b, cw, ch, inside=False) + corner_cands(b, cw, ch))
        if at:
            P.put('crate', at[0] + cw, at[1] + ch - 10) or P.put('crate', at[0] - 11, at[1] + ch - 10)
            P.put('sack', at[0] + 4, at[1] - 8)
        sw, sh = sprite_size('shelf')
        s = P.first('shelf', corner_cands(b, sw, sh + 4))
        if s:
            stamp(a, 'apples', s[0] + 3, s[1] - 3); stamp(a, 'apples', s[0] + 11, s[1] - 3)
            P.put('crate', s[0] + 2, s[1] + 8) if P.free(s[0] + 2, s[1] + 8, 10, 10) else None
        P.first('crate', corner_cands(b, 10, 10)[1:])
    lit_n = 0
    for k, beh, b in sorted(spots, key=lambda t: t[2][0]):      # the shop and two more buildings get a lamp
        if beh in ('shops',) or (beh not in ('wild', 'green') and lit_n < 2):
            w, h = sprite_size('work_lantern')
            if P.lamp(corner_cands(b, w, h)[4:6] + corner_cands(b, w, h)[:2]) and beh != 'shops':
                lit_n += 1
    sx, sy = sprite_size('planks')
    for k, beh, b in spots:
        if beh == 'green':
            P.first('planks', corner_cands(b, sx, sy)); P.first('sawhorse', corner_cands(b, 12, 6))
    a[P.no] = base[P.no]                                        # no prop over a spot's centre, ever
    return a


def town_jobs():
    """(source file, layout key, ruin file, work file) for all 30 + 2 pictures."""
    j = [(f'here-town-{c}.png', f'town-{c}', f'here-town-{c}-ruin.png', f'here-town-{c}-work.png') for c in TOWN_CODES]
    j.append(('here-town.png', 'town', 'here-town-ruin.png', 'here-town-work.png'))
    j.append(('stop-market.png', 'stop-market', 'stop-market-ruin.png', 'stop-market-work.png'))
    return j


def town_main(out, sheet, check_only=False):
    os.makedirs(out, exist_ok=True)
    rows, report = [], []
    for srcf, key, rf, wf in town_jobs():
        im = Image.open(os.path.join(SCENES, srcf))
        src = np.array(im.convert('RGB'))
        spots = town_spots(key)
        seed = sum(map(ord, key))
        st = town_strength(src, shop_keep(src, [b for _, beh, b in spots if beh == 'shops']))
        pal = town_palette(src, st)
        r = snap(town_ruin(src, spots, seed, st), pal)
        w = snap(town_work(src, r, spots, seed), pal)
        line_ = [srcf, st]
        for arr, name in ((r, rf), (w, wf)):
            assert arr.shape == (270, 480, 3), name
            used = np.unique(arr.reshape(-1, 3), axis=0)
            pal_set = {tuple(c) for c in pal.tolist()}
            assert all(tuple(c) in pal_set for c in used.tolist()), name + ': colour outside the twin palette'
            share = float(visible(arr, src).mean())
            line_.append((name, len(used), round(100 * share, 1)))
            if not check_only:
                Image.fromarray(arr).convert('RGBA').save(os.path.join(out, name))
        report.append(line_)
        if key in ('town-na', 'town-ea', 'town-mena'):
            rows.append((key[5:], [Image.fromarray(r), Image.fromarray(w), Image.fromarray(src)]))
    if sheet:
        contact(rows, sheet, labels=('RUN LOW', 'MENDING', 'THRIVING'))
    print(f'{"fixed":24} {"overcast":8} {"twin":28} colours  visible diff % (RGB distance >= 36)')
    for l in report:
        for name, nc, sh in l[2:]:
            print(f'{l[0]:24} {l[1]:8} {name:28} {nc:7}  {sh:5}')
    return report


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('recipe', nargs='?', default='stop', choices=('stop', 'town'))
    ap.add_argument('--out', default=None)
    ap.add_argument('--look', default='grassland_maplewold')
    ap.add_argument('--kinds', default='mill,shrine,ferry')
    ap.add_argument('--sheet', default=None, help='town: contact sheet path (3 towns x 3 states, 2x)')
    o = ap.parse_args()
    if o.recipe == 'town':
        town_main(o.out or SCENES, o.sheet)
        return
    o.out = o.out or os.path.join(os.getcwd(), 'stops')
    os.makedirs(o.out, exist_ok=True)
    rows = []
    for kind in o.kinds.split(','):
        img = Image.open(os.path.join(SCENES, f'here-stop-{kind}-{o.look}.png')).convert('RGB')
        seed = sum(map(ord, kind + o.look))
        r = ruin(img, kind, seed)
        w = work(img, kind, r, seed)
        f = fixed(img, kind)
        r.save(os.path.join(o.out, f'stop-{kind}-ruin.png'))
        w.save(os.path.join(o.out, f'stop-{kind}-work.png'))
        f.save(os.path.join(o.out, f'stop-{kind}-fixed.png'))
        fixed(img, kind, ('stocked', 'lit')).save(os.path.join(o.out, f'stop-{kind}-fixed-stocked-lit.png'))
        rows.append((kind, [r, w, f]))
    contact(rows, os.path.join(o.out, 'contact-2x.png'))
    print('wrote', o.out)


if __name__ == '__main__':
    main()
