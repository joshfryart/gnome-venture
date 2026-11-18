"""cats.py: the four category templates. Each takes a design dict (see NA/items.py) and returns {view: 512x80 strip}.

  footwear(d)  per foot (2 per view, from the rig clog table: lift, x) a shoe = foot shell + optional shaft up to a rim
               row + cuff band + sole; d['detail'](c, g, foot, k) for the signature bits. Drawn over the tunic.
  coat(d)      the rig tunic silhouette (torso ellipse + hip poly + sleeves, arm swing exact) remapped to the coat ramp
               through the tunic's own tone map, optional hem extension / puff / no sleeves / open front, pattern fn,
               d['detail'] painter. Drawn over the tunic, under scarf, hands and beard.
  cloak(d)     a hanging silhouette from the shoulders: length, flare, hem style, sway (cloth lags one frame, `tail`),
               border band, hood drop. Back = over the back; side = trailing behind (never over the near arm);
               front = its own wider silhouette, BEHIND the gnome (only the rim beside arms/legs shows).
  backpack(d)  d['back'](c, x, y, g) paints the pack seen from behind at anchor (top centre), d['side'](c, x, y, g)
               in profile at the back line (pack extends to the left). Bounce = body bob + one-frame lag.
               Front = the back painting mirrored, darkened, behind the gnome (corners over shoulders, sides at hips).
"""
import av
from av import C, M, ellipse, poly, rect, line, form, ring, remap, INK


def _strip(fn):
    return {v: av.strip([fn(v, f) for f in range(1, 9)]) for v in av.VIEWS}


# ---------------------------------------------------------------- footwear
def footwear(d):
    """d: shell (ramp), upper (ramp, for the shaft), cuff (ramp or None), sole (hex), rim (absolute top row of the shaft at
    rest, None = shoe only), half (shaft half width, default 4), puff (extra foot radius), toe (side-view toe length),
    flat (True = clog/slipper with no shaft), detail(c, g, foot, k)."""
    def frame(view, f):
        g = av.geo(view, f)
        c = C()
        for k, ft in enumerate(g['feet']):
            cx, cy, lift = ft['cx'], ft['cy'], ft['lift']
            pf = d.get('puff', 0)
            if view == 'side':
                foot = ellipse(cx + 0.5 + d.get('toe', 0) / 2, cy, 4 + d.get('toe', 0) / 2 + pf, 2.5 + pf / 2)
                sx0, sx1 = int(cx - 3 - pf), int(cx + 1 + pf)
            else:
                foot = ellipse(cx, cy, 4 + pf, 2.5 + pf / 2)
                hw = d.get('half', 4) + pf
                sx0, sx1 = int(round(cx - hw)), int(round(cx + hw)) - (1 if ft['side'] == 'L' else 0)
                if ft['side'] == 'R': sx0 += 1
            shaft = M()
            if d.get('rim') is not None:
                top = d['rim'] + lift
                shaft = rect(sx0, top, sx1, int(cy))
                if view == 'side': shaft = rect(sx0, top, sx1, int(cy))
            g2 = dict(g, foot=foot, shaft=shaft, sx0=sx0, sx1=sx1, top=(d['rim'] + lift) if d.get('rim') is not None else int(cy - 2.5),
                      far=(view == 'side' and ft['side'] == 'far'))
            if view == 'side' and k == 1:   # near foot: ink seam where it overlaps the far one
                for q in (foot | shaft).edge():
                    if q in c and q not in foot and q not in shaft: c.put(q[0], q[1], INK)
            sh = d['shell']
            if g2['far']:   # far foot a tone darker
                sh = [sh[0]] + sh[:5]
            form(c, shaft, d.get('upper', sh), frac=0.35)
            form(c, foot, sh, frac=0.35, hi=[(int(cx) - 2, int(cy) - 2)] if view != 'back' else None)
            # sole row
            for q in foot.bottom(): c.put(q[0], q[1], d.get('sole', sh[0]))
            if d.get('cuff') and shaft:
                band = shaft.rows(g2['top'], g2['top'] + d.get('cuff_rows', 2) - 1)
                form(c, band, d['cuff'], frac=0.35, under=False)
            if d.get('detail'): d['detail'](c, g2, ft, k)
            if view == 'side' and ft['side'] == 'far':   # seam between far and near foot drawn by near foot's ring
                pass
        # separate the near foot from the far one in side view with a seam
        ring(c, g, 'all')
        if view == 'side':
            pass
        return c
    return _strip(frame)


# ---------------------------------------------------------------- coat
def coat(d):
    """d: r (ramp), sleeves (bool), hem (extra rows below the tunic hem), puff (1 = 1px fatter torso), open (front opening
    width in px, front view below the beard), pattern(q, tone, g) -> hex or None, detail(c, g), collar(c, g)."""
    def frame(view, f):
        g = av.geo(view, f)
        c = C()
        b, hs = g['b'], g['hem']
        body = g['torso'].copy()
        if d.get('hem'):
            n = d['hem']
            if view == 'side':
                body |= poly([(23 + hs, 63 + b), (42 + hs, 63 + b), (43 + hs + 1, 64 + b + n), (21 + hs + g['tail'], 64 + b + n)])
            else:
                body |= poly([(21 + hs, 63 + b), (44 + hs, 63 + b), (45 + hs, 64 + b + n), (20 + hs, 64 + b + n)])
        if d.get('puff'):
            body |= M(q for q in body.edge() if q[1] < 63 + b and q[1] > 46 + b)
        sl = M()
        if d.get('sleeves', True):
            for s in g['sleeves']: sl |= s
        if view == 'side' and not d.get('sleeves', True):
            body -= g['sleeves'][0].sh(0, 0)  # the near arm stays tunic
        full = body | sl
        tones = g['tunic_tone']
        r = d['r']
        for q in full:
            t = tones.get(q, 1)
            col = r[max(0, min(5, 4 - t))]
            if d.get('pattern'):
                pc = d['pattern'](q, t, g)
                if pc: col = pc
            c.put(q[0], q[1], col)
        # hem extension / puff rows that have no tunic tone: form them
        ext = M(q for q in full if q not in tones)
        if ext:
            tmp = C(); form(tmp, ext, r, frac=0.35)
            for q, col in tmp.items():
                if q[1] >= 63 + b or q not in g['tunic']:
                    pc = d['pattern'](q, 1, g) if d.get('pattern') else None
                    c.put(q[0], q[1], pc if pc and col != r[1] else col)
        # sleeve seams: a deep line where the sleeve meets the torso (vest armhole) handled by ring when sleeveless
        if d.get('open') and view == 'front':
            w = d['open']
            for y in range(58 + b, 65 + b + d.get('hem', 0)):
                for x in range(33 - w // 2, 33 + (w + 1) // 2):
                    c.pop((x, y), None)
        if d.get('collar'): d['collar'](c, g)
        if d.get('detail'): d['detail'](c, g)
        keep = M()
        if not d.get('sleeves', True):   # armhole seam onto the sleeve, but keep the outline under hands
            pass
        ring(c, g, 'all', keep)
        if d.get('open') and view == 'front':   # don't ink over the opening (tunic shows)
            w = d['open']
            for y in range(58 + b, 65 + b + d.get('hem', 0)):
                for x in range(33 - w // 2, 33 + (w + 1) // 2):
                    if c.get((x, y)) == INK and (x, y) in g['tunic'] and not (x in (33 - w // 2, 33 + (w + 1) // 2 - 1)): c.pop((x, y))
        return c
    return _strip(frame)


# ---------------------------------------------------------------- cloak
def cloak_shape(d, g, view):
    """back-view silhouette (also used mirrored for front)."""
    b, tl = g['b'], g['tail']
    top = 46 + b
    L = d.get('len', 64)                 # hem row at rest
    hem = L + b
    fl = d.get('flare', 2)
    x0, x1 = d.get('x0', 22), d.get('x1', 43)
    if view == 'side':
        # shoulder at the back of the neck, hangs down the back and trails left with the sway
        back = d.get('side_back', 21)
        pts = [(28, top), (25, top), (back - fl + 1 + tl, hem - 2), (back - fl + tl, hem + 1), (27 + tl // 2, hem + 1), (27, top + 9)]
        return poly(pts)
    if view == 'front':   # behind the gnome: its own, wider silhouette (only what clears arms/hips/legs shows)
        a, z, ff = d.get('fx0', 17), d.get('fx1', 48), d.get('front_flare', fl + 1)
        t = 45 + b
        return poly([(a + 3, t), (z - 2, t), (z + 1, t + 3), (z + ff - tl, hem + 1), (a - ff - tl, hem + 1), (a, t + 3)])
    pts = [(x0 + 2, top), (x1 - 1, top), (x1 + fl + tl, hem), (x0 - fl + tl, hem)]
    return poly(pts)


def cloak(d):
    """d: r (ramp), lining (ramp, front/inside), len, flare, x0, x1, hemstyle ('straight'|'points'|'diamond'|'tri'),
    border (ramp, rows), hood (dict or None), fx0/fx1/front_flare (front-view silhouette behind the gnome), detail(c, g, m, view)."""
    def frame(view, f):
        g = av.geo(view, f)
        c = C()
        b, tl = g['b'], g['tail']
        m = cloak_shape(d, g, view)
        hem = d.get('len', 64) + b
        st = d.get('hemstyle', 'straight')
        if st == 'points':   # leaf points: notches every 3 px on the last 2 rows
            x0, _, x1, y1 = m.bbox()
            for x in range(x0, x1 + 1):
                ph = (x - x0 + tl) % 4
                if ph == 0: m -= M({(x, y1), (x, y1 - 1)})
                elif ph in (1, 3): m -= M({(x, y1)})
        elif st == 'diamond' and view != 'side':
            x0, y0, x1, y1 = m.bbox(); cx = (x0 + x1) / 2
            m = M(q for q in m if q[1] <= y1 - abs(q[0] - cx - tl) * 0.45 + 2)
        elif st == 'tri' and view != 'side':
            x0, y0, x1, y1 = m.bbox(); cx = (x0 + x1) / 2 + tl
            m = M(q for q in m if q[1] <= y0 + (y1 - y0 + 4) - abs(q[0] - cx) * 1.15)
        if view == 'front':
            form(c, m, d.get('lining', d['r']), frac=0.5)
        else:
            form(c, m, d['r'], frac=0.35 if view == 'back' else 0.2)
            # drape folds: vertical shade lines
            x0, y0, x1, y1 = m.bbox()
            if view == 'back':
                for fx in d.get('folds', (27, 32, 38)):
                    for y in range(y0 + 6, y1):
                        q = (fx + (tl if y > y0 + 10 else 0), y)
                        if q in m and (q[0] + 1, q[1]) in m: c.put(q[0], q[1], d['r'][2])
            else:
                for y in range(y0 + 5, y1):
                    q = (x0 + 3 + tl, y)
                    if q in m: c.put(q[0], q[1], d['r'][2])
        if d.get('border'):
            br, rows = d['border'], d.get('border_rows', 2)
            edge = M(q for q in m if any((q[0], q[1] + k) not in m for k in range(1, rows + 1)))
            if view == 'back' and d.get('border_sides'):
                edge |= M(q for q in m if (q[0] - 1, q[1]) not in m or (q[0] + 1, q[1]) not in m)
            if view == 'side':
                edge |= M(q for q in m if (q[0] - 1, q[1]) not in m and q[1] > m.bbox()[1] + 3)
            for q in edge:
                c.put(q[0], q[1], br[3] if (q[0] + q[1]) % 5 else br[4])
            for q in edge.bottom() if hasattr(edge, 'bottom') else []:
                c.put(q[0], q[1], br[1])
        if d.get('detail'): d['detail'](c, g, m, view)
        ring(c, g, 'all')
        return c
    return _strip(frame)


# ---------------------------------------------------------------- backpack
def backpack(d):
    """d: back(c, x, y, g) at the pack's top-centre (back view), side(c, x, y, g) at the back line (pack goes left),
    y0 (top row at rest, default 47), lag (bounce follows pdy)."""
    def frame(view, f):
        g = av.geo(view, f)
        c = C()
        y = d.get('y0', 47) + g['b'] + (g['pdy'] if d.get('lag', True) else 0)
        if view == 'back':
            d['back'](c, 32, y, g)
        elif view == 'side':
            d['side'](c, d.get('side_x', 24), y, g)
        else:
            # behind the gnome: the back painting, mirrored and stretched sideways so its rims clear the arms
            # (front_span = x range it is stretched to) and lifted front_lift rows so the top corners show over the shoulders
            t = C()
            d['back'](t, 32, y - d.get('front_lift', 2), g)
            if t:
                x0, _, x1, _ = t.mask().bbox()
                a, z = d.get('front_span', (15, 50))
                a, z = min(a, x0), max(z, x1)
                for (x, yy), col in t.items():
                    pass
                for yy in range(min(q[1] for q in t), max(q[1] for q in t) + 1):
                    for nx in range(a, z + 1):
                        sx = x0 + round((nx - a) * (x1 - x0) / max(1, z - a))
                        col = t.get((sx, yy))
                        if col: c.put(63 - nx + 1, yy, col)
            if d.get('front'): d['front'](c, 33, y, g)
        ring(c, g, 'all')
        return c
    return _strip(frame)
