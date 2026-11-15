"""Ruin-picture helpers (hard pixels only). Used by tools/gen_ruin_art.py.

A ruin picture = the live 480x270 picture, recoloured (overcast, desaturated, lights out) plus hand-placed damage.
Everything is nearest-neighbour: no blending, no anti-aliasing, so the Hearth Pop look stays crisp.
"""
import colorsys, random
import numpy as np
from PIL import Image, ImageDraw

INK = (0x2b, 0x1c, 0x26)


def hx(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


class Pic:
    def __init__(self, path):
        self.im = Image.open(path).convert('RGBA')
        self.w, self.h = self.im.size
        self.px = self.im.load()
        self.d = ImageDraw.Draw(self.im)
        self.rng = random.Random(7)

    # ---- colour work -------------------------------------------------------------------------------
    def remap(self, sat=0.6, val=0.9, hue=0.0, tint=None, box=None, keep=None):
        """Per-pixel HSV remap over the whole picture (or a box). tint = (r,g,b) pulled in by 12%."""
        x0, y0, x1, y1 = box or (0, 0, self.w - 1, self.h - 1)
        cache = {}
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                r, g, b, a = self.px[x, y]
                if a == 0:
                    continue
                k = (r, g, b)
                if k not in cache:
                    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
                    h = (h + hue) % 1.0
                    s = min(1, s * sat)
                    v = min(1, v * val)
                    rr, gg, bb = [round(c * 255) for c in colorsys.hsv_to_rgb(h, s, v)]
                    if tint:
                        rr = round(rr * .88 + tint[0] * .12)
                        gg = round(gg * .88 + tint[1] * .12)
                        bb = round(bb * .88 + tint[2] * .12)
                    cache[k] = (rr, gg, bb)
                self.px[x, y] = cache[k] + (a,)

    def recolor(self, box, fn):
        """fn(r,g,b)->(r,g,b) or None (keep) for each pixel of the box."""
        x0, y0, x1, y1 = box
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                r, g, b, a = self.px[x, y]
                o = fn(r, g, b)
                if o is not None:
                    self.px[x, y] = tuple(o) + (a,)

    def sample(self, x, y):
        return self.px[x, y][:3]

    # ---- drawing -----------------------------------------------------------------------------------
    def poly(self, pts, col, outline=None):
        if outline:
            self.d.polygon(pts, fill=col + (255,), outline=outline + (255,))
        else:
            self.d.polygon(pts, fill=col + (255,))

    def rect(self, x0, y0, x1, y1, col):
        self.d.rectangle((x0, y0, x1, y1), fill=col + (255,))

    def ell(self, cx, cy, rx, ry, col, outline=None):
        self.d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=col + (255,),
                       outline=(outline + (255,)) if outline else None)

    def dot(self, x, y, col):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.px[x, y] = col + (255,)

    def line(self, pts, col, w=1):
        self.d.line(pts, fill=col + (255,), width=w)

    def patch(self, box, mask_fn, col_fn):
        """paint pixels of box where mask_fn(x,y) true, colour col_fn(x,y)."""
        x0, y0, x1, y1 = box
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                if mask_fn(x, y):
                    self.dot(x, y, col_fn(x, y))

    def copy_block(self, src, dst, w, h, skip_alpha=True):
        """copy a w*h block from (sx,sy) to (dx,dy)"""
        sx, sy = src
        dx, dy = dst
        blk = [[self.px[sx + i, sy + j] for i in range(w)] for j in range(h)]
        for j in range(h):
            for i in range(w):
                self.px[dx + i, dy + j] = blk[j][i]

    def outline_new(self, before, col=INK):
        """1px ink ring round every pixel that is new (differs from `before`) and not at the picture edge."""
        a = np.array(self.im)
        b = np.array(before)
        new = (a != b).any(axis=2)
        h, w = new.shape
        ring = np.zeros_like(new)
        ring[1:, :] |= new[:-1, :]
        ring[:-1, :] |= new[1:, :]
        ring[:, 1:] |= new[:, :-1]
        ring[:, :-1] |= new[:, 1:]
        ring &= ~new
        for y in range(1, h - 1):
            for x in range(1, w - 1):
                if ring[y, x]:
                    self.px[x, y] = col + (255,)

    def snapshot(self):
        return self.im.copy()

    # ---- ruin details ------------------------------------------------------------------------------
    def vine(self, x, y, length, cols, drop=1, sway=2, leaf=0.35):
        """a hanging / climbing vine: wobbling column with leaf pixels."""
        c0, c1 = cols
        cx = x
        for i in range(length):
            if self.rng.random() < 0.25:
                cx += self.rng.choice((-1, 1)) if sway else 0
            cx = max(x - sway, min(x + sway, cx))
            self.dot(cx, y + i * drop, c0)
            if self.rng.random() < leaf:
                self.dot(cx + self.rng.choice((-1, 1)), y + i * drop, c1)

    def moss(self, box, cols, density=0.5, edge_only=None):
        x0, y0, x1, y1 = box
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                if self.px[x, y][3] and self.rng.random() < density:
                    if edge_only and not edge_only(x, y):
                        continue
                    self.dot(x, y, self.rng.choice(cols))

    def crack(self, x, y, steps, col=INK, bias=(0, 1)):
        for _ in range(steps):
            self.dot(x, y, col)
            x += self.rng.choice((-1, 0, 1)) if bias[0] == 0 else bias[0]
            y += bias[1] if self.rng.random() < .7 else 0
            x += self.rng.choice((-1, 1)) if self.rng.random() < .35 else 0

    def web(self, x, y, size, col=(0xd8, 0xd6, 0xe0)):
        """cobweb in the corner: fan of lines + arcs, corner at (x,y) opening right/down."""
        for k in range(1, size + 1, 3):
            self.line([(x + k, y), (x, y + k)], col)
        self.line([(x, y), (x + size, y + size // 3)], col)
        self.line([(x, y), (x + size // 2, y + size)], col)

    def grain(self, box, amount=0.12, step=16, only=None, seed=None):
        """texture: some pixels take a lighter or darker tone of their own colour (new hard tones, no blending)."""
        rng = random.Random(seed if seed is not None else self.rng.random())
        x0, y0, x1, y1 = box
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                r, g, b, a = self.px[x, y]
                if not a or (only and not only(r, g, b)):
                    continue
                if rng.random() < amount:
                    k = step if rng.random() < .5 else -step
                    self.px[x, y] = (max(0, min(255, r + k)), max(0, min(255, g + k)), max(0, min(255, b + k)), a)

    def speckle(self, box, cols, n, rng=None):
        rng = rng or self.rng
        x0, y0, x1, y1 = box
        for _ in range(n):
            self.dot(rng.randint(x0, x1), rng.randint(y0, y1), rng.choice(cols))

    def blob(self, cx, cy, rx, ry, cols, outline=None, wobble=1):
        """irregular lump (drift, rubble, clump): ellipse with a wobbly edge, light top-left / dark bottom-right."""
        hi, base, sh = cols
        for y in range(cy - ry - wobble, cy + ry + wobble + 1):
            for x in range(cx - rx - wobble, cx + rx + wobble + 1):
                dx, dy = (x - cx) / max(rx, 1), (y - cy) / max(ry, 1)
                d = dx * dx + dy * dy + self.rng.uniform(-.12, .12) * wobble
                if d <= 1:
                    t = (dx + dy)
                    self.dot(x, y, hi if t < -.7 else (sh if t > .55 else base))
        if outline:
            before = None

    def save(self, path):
        self.im.save(path)
