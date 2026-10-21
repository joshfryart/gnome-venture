"""Hearthlight style: cream sticker halo + warm umber silhouette line + one shared
lower-right cel crescent clipped to the silhouette. Pure restyle of ph/*.svg."""
import re, copy, math
import xml.etree.ElementTree as ET

NAVF = [False]
NS = 'http://www.w3.org/2000/svg'
ET.register_namespace('', NS)
UMBER = '#2a1a10'
HALO = '#f2e4c0'
SHADE = '#2a1a10'
REMAP = {'#2b2b2b': '#2a1a10', '#000': UMBER, '#000000': UMBER,
 # i2 warmth: richer, less muddy palette steps (wood stays in is_wood range)
 '#7a4a1f': '#8c4a1a', '#9a6b3f': '#a5663a', '#3d2a1c': '#44281c', '#c9a96e': '#dcb06a',
 '#8b8f96': '#968f96', '#5b6470': '#6a6070', '#c9c5bc': '#d6c9b6',
 '#4f9a45': '#58a03e', '#2f5a2a': '#2e5a2c', '#a4b86a': '#b0bc66',
 '#25637d': '#256a80', '#3f8fb0': '#3f93b2'}
# i2: hue-tinted cel shade (one path, no extra bytes): warm tone matched to the icon's dominant hue
TINT = {'g': '#17361c', 'r': '#5a1410', 'b': '#12324a', 'p': '#2e1a5a', 'y': '#5a3008', 'w': '#4a1c10', 's': '#3a2236'}
SHADE_OP = '.34'
def hue_class(c):
    h = _hex(c)
    if not h: return None
    r, g, b = h; mx, mn = max(h), min(h)
    if mx > 235 and mn > 215: return None
    if mx - mn < 26: return 's'
    if g >= r and g > b: return 'g'
    if b >= g and b > r: return 'p' if r > g + 20 else 'b'
    if r > g > b:
        if g - b > (r - b) * .6 and g > 120: return 'y'
        if g < 90 and r > 150: return 'r'
        return 'w'
    return 'w'
def shade_color(kids):
    cnt = {}
    for k in kids:
        for e in k.iter():
            if e.tag == q('g') or skip(e): continue
            f = (e.get('fill') or '').lower()
            hc = hue_class(f)
            if hc and f != UMBER: cnt[hc] = cnt.get(hc, 0) + 1
    return TINT[max(cnt, key=cnt.get)] if cnt else TINT['w']

CHAR_REMAP = {'#6a6070': '#8f7060', '#968f96': '#a38f80', '#d6c9b6': '#e6d2ae', '#e46a9b': '#d9667f', '#f4f0e0': '#f8eed2', '#f1ece0': '#f8eed2', '#a9d6ea': '#b8d8d2', '#a8241f': '#9c2a1e'}
CHARS = ('creature-', 'npc-')
EYE_DARK = [False]
def eye_pass(kids, root, npc):
    whites, pupils = [], []; ids = {}; glints = []; under = {}; seen = []
    def walk(el, tr):
        ta, tb, tc, td = tr
        if el.tag == q('g'):
            a, b, c, d = _tf(el.get('transform'))
            for k in el: walk(k, (ta * a, tb * b, tc + ta * c, td + tb * d))
            return
        if el.tag in (q('circle'), q('ellipse'), q('path'), q('rect')) and not el.get('opacity') and not el.get('stroke') and _hex(el.get('fill')) and not (el.tag == q('circle') and num(el.get('r')) < 3.9 and (el.get('fill') or '').lower() == UMBER):   # i12: what lies under a later pupil (bbox test)
            P = _pts(el)
            if P: seen.append((tc + ta * min(p[0] for p in P), td + tb * min(p[1] for p in P), tc + ta * max(p[0] for p in P), td + tb * max(p[1] for p in P), el.get('fill').lower()))
        if el.tag != q('circle') or el.get('stroke') or el.get('opacity'): return
        f = (el.get('fill') or '').lower(); R0 = ORIG_R.get(id(el), num(el.get('r'))); r = num(el.get('r')) * ta
        x, y = tc + ta * num(el.get('cx')), td + tb * num(el.get('cy'))
        if f in ('#fff', '#ffffff', '#f8eed2') and 2.4 <= R0 <= 7: whites.append((x, y, r)); ids[('w', len(whites) - 1)] = id(el)
        elif f == UMBER and 1.2 <= R0 <= 3.8:
            ul = [b[4] for b in seen if b[0] <= x <= b[2] and b[1] <= y <= b[3]]
            if not npc and R0 >= 3.4 and not [w for w in whites if (w[0] - x) ** 2 + (w[1] - y) ** 2 < w[2] ** 2]: return   # i12: a big dark dot with no eye-white is a tail tip / nub, not an eye
            pupils.append((x, y, r)); ids[('p', len(pupils) - 1)] = id(el); under[len(pupils) - 1] = (ul[-1] if ul else '#fff')
        elif f in ('#fff', '#ffffff') and R0 < 2.4: glints.append((x, y, id(el)))
    for k in kids: walk(k, (1, 1, 0, 0))
    rm = set()
    if not pupils: return rm
    Rg, Wg, Pg, Gg, Rd = [], [], [], [], []
    for pi, (x, y, r) in enumerate(pupils):
        rm.add(ids[('p', pi)])
        wh = [w for w in whites if (w[0] - x) ** 2 + (w[1] - y) ** 2 < w[2] ** 2]
        pr = max(r * 1.1, 1.25); uh = _hex(under.get(pi)); dark = not npc and EYE_DARK[0] and bool(uh) and .3 * uh[0] + .59 * uh[1] + .11 * uh[2] < 80
        if wh:
            rm.add(ids[('w', whites.index(wh[0]))])
            for gx, gy, gi in glints:
                if (gx - wh[0][0]) ** 2 + (gy - wh[0][1]) ** 2 < wh[0][2] ** 2: rm.add(gi)
            wx, wy, wr = wh[0]; wr = max(wr, pr * 1.55, 2.1); (Rg.append((wx, wy, 2 * wr + .7)) if wr >= 2.6 else None); Wg.append((wx, wy, 2 * wr))
        elif dark: wr = max(pr * 1.6, 2.1); Rd.append((x, y, 2 * wr + 1.4)); Wg.append((x, y, 2 * wr))   # i12: eye on a dark fill: cream disc + ring so it reads
        Pg.append((x, y, 2 * pr))
        if pr >= 3.1: Gg.append((x - .38 * pr, y - .4 * pr, 2 * .42 * pr))
    def dots(L, col, op=None):
        by = {}
        for x, y, d in L: by.setdefault(round(d, 1), []).append((x, y))
        for d, pts in by.items():
            a = {'d': ''.join('M%s %sh0' % (fmt(x), fmt(y)) for x, y in pts), 'stroke': col, 'stroke-width': fmt(d), 'stroke-linecap': 'round'}
            if op: a['opacity'] = op
            ET.SubElement(root, q('path'), a)
    dots(Rg, UMBER, '.5'); dots(Rd, '#a38f80'); dots(Wg, '#fffaf0'); dots(Pg, UMBER); dots(Gg, '#fffaf0')
    return rm

def compact_tf(out):
    def f(m):
        x, y, k = float(m.group(1)), float(m.group(2)), float(m.group(3))
        if abs(k - 1) < 1e-6: return ''
        return 'translate(%s %s) scale(%s)' % (fmt(x * (1 - k)), fmt(y * (1 - k)), fmt(k))
    out = re.sub(r'translate\(([\d.-]+) ([\d.-]+)\) scale\(([\d.]+)\) translate\(-\1 -\2\)', f, out)
    out = re.sub(r' transform="\s*"', '', out)
    return re.sub(r'transform="\s+', 'transform="', out).replace('transform=" ', 'transform="')

PRUNE = set()
def prune_inside(kids):
    """chars: drop filled leaves lying inside another filled ellipse/circle's inscribed box (redundant for silhouette/clip)."""
    L = []
    def walk(el, tr):
        ta, tb, tc, td = tr
        if el.tag == q('g'):
            a, b, c, d = _tf(el.get('transform'))
            if 'rotate' in (el.get('transform') or ''): return
            for k in el: walk(k, (ta * a, tb * b, tc + ta * c, td + tb * d))
            return
        if el.tag == q('text') or skip(el) or el.get('transform') or el.get('fill') in (None, 'none') or el.get('stroke'): return
        P = _pts(el)
        if not P: return
        xs = [tc + ta * x for x, y in P]; ys = [td + tb * y for x, y in P]
        L.append((el, min(xs), min(ys), max(xs), max(ys)))
    for k in kids: walk(k, (1, 1, 0, 0))
    allk = [e for e in kids for e in e.iter()]
    for e in allk:
        if e.tag == q('path') and e.get('d') and e.get('fill') not in (None, 'none') and any(o is not e and o.get('d') == e.get('d') and o.get('fill') == 'none' for o in allk): PRUNE.add(id(e))
    if SWARM:   # i10: tiny filled marks sitting inside a bigger shape's bbox add nothing to halo/outline/clip
        for e, x0, y0, x1, y1 in L:
            if max(x1 - x0, y1 - y0) > 7: continue
            for o in allk:
                if o is e or o.tag == q('g') or skip(o): continue
                b = sil_bbox([o])
                if b and (b[2] - b[0]) * (b[3] - b[1]) > 2 * (x1 - x0 + .1) * (y1 - y0 + .1) and b[0] <= x0 + .3 and b[1] <= y0 + .3 and b[2] >= x1 - .3 and b[3] >= y1 - .3: PRUNE.add(id(e)); break
    for e in allk:   # i10: same-geometry stroke-only paths: only the widest joins the silhouette
        if e.tag == q('path') and e.get('d') and e.get('fill') == 'none' and e.get('stroke'):
            for o in allk:
                if o is not e and o.tag == q('path') and o.get('d') == e.get('d') and o.get('fill') == 'none' and o.get('stroke') and num(o.get('stroke-width')) > num(e.get('stroke-width')): PRUNE.add(id(e)); break
    for e, x0, y0, x1, y1 in L:
        for o, a0, b0, a1, b1 in L:
            if o is e or o.tag not in (q('ellipse'), q('circle')): continue
            if (a1 - a0) * (b1 - b0) <= (x1 - x0) * (y1 - y0): continue
            ox, oy, orx, ory = (a0 + a1) / 2, (b0 + b1) / 2, (a1 - a0) / 2 * .94, (b1 - b0) / 2 * .94
            if e.tag in (q('ellipse'), q('circle')):
                ex, ey, erx, ery = (x0 + x1) / 2, (y0 + y1) / 2, (x1 - x0) / 2, (y1 - y0) / 2
                T = [(ex + erx * math.cos(t * math.pi / 8), ey + ery * math.sin(t * math.pi / 8)) for t in range(16)]
            else: T = [(x0, y0), (x1, y0), (x0, y1), (x1, y1)]
            if all(((px - ox) / orx) ** 2 + ((py - oy) / ory) ** 2 <= 1 for px, py in T): PRUNE.add(id(e)); break

def flat_groups(kids):
    out = []
    for k in kids:
        if k.tag == q('g') and len(k) and all(c.tag == q('g') for c in k) and 'rotate' not in (k.get('transform') or ''):
            a, b, c0, d0 = _tf(k.get('transform'))
            for c in k:
                a2, b2, c2, d2 = _tf(c.get('transform')) if c.get('transform') else (1, 1, 0, 0)
                if 'rotate' in (c.get('transform') or ''): out.append(k); break
                A, B, C, D = a * a2, b * b2, c0 + a * c2, d0 + b * d2
                c.set('transform', 'translate(%s %s) scale(%s)' % (fmt(C), fmt(D), fmt(A)))
            else: out.extend(flat_groups(list(k)))
        else: out.append(k)
    return out


# ---- i7: byte diet helpers -------------------------------------------------
GEOM = ('x', 'y', 'width', 'height', 'rx', 'ry', 'cx', 'cy', 'r', 'd', 'points')
def f1(x):
    if NAVF[0]: return str(int(round(x)))   # nav icons (24px): whole units are enough for halo/outline/clip/shade copies
    return ('%.1f' % x).rstrip('0').rstrip('.') if abs(x) >= .05 else '0'
def rnd1(el):
    """1-decimal numbers on halo/outline/clip copies (geometry attrs only)."""
    for e in el.iter():
        for a in ('d', 'points', 'x', 'y', 'width', 'height', 'rx', 'ry', 'cx', 'cy', 'r'):
            v = e.get(a)
            if v: e.set(a, re.sub(r'-?\d*\.\d+', lambda m: (lambda t: '0' if t in ('-0', '') else t)(f1(float(m.group(0)))), v))
def _parse(d):
    """single-subpath M/L/H/V/C/Q/Z path -> (nodes, segs, closed) absolute; None if unsupported."""
    if not d or d.count('M') + d.count('m') != 1 or re.search(r'[AaSsTt]', d): return None
    cx = cy = 0.0; segs = []; start = None; closed = False
    for m in re.finditer(r'([MmLlHhVvCcQqZz])([^MmLlHhVvCcQqZz]*)', d):
        c = m.group(1); v = [float(x) for x in re.findall(r'-?\d*\.?\d+(?:e-?\d+)?', m.group(2))]; rel = c.islower(); C = c.upper()
        if C == 'Z': closed = True; continue
        if closed: return None
        n = {'M': 2, 'L': 2, 'H': 1, 'V': 1, 'C': 6, 'Q': 4}[C]
        if not v or len(v) % n: return None
        for i in range(0, len(v), n):
            p = v[i:i + n]
            if C == 'H': cx = cx + p[0] if rel else p[0]; segs.append(('L', [(cx, cy)])); continue
            if C == 'V': cy = cy + p[0] if rel else p[0]; segs.append(('L', [(cx, cy)])); continue
            ox, oy = (cx, cy) if rel and start is not None else (0, 0)
            pts = [(ox + p[j], oy + p[j + 1]) for j in range(0, n, 2)]
            if C == 'M':
                if segs: return None
                start = pts[0]; cx, cy = start; segs.append(('M', pts)); continue
            if start is None: return None
            segs.append((C, pts)); cx, cy = pts[-1]
    return segs, closed
def _area(segs):
    P = [p for c, pts in segs for p in pts]
    return .5 * sum(P[i][0] * P[(i + 1) % len(P)][1] - P[(i + 1) % len(P)][0] * P[i][1] for i in range(len(P)))
def _emit(segs, closed, F=f1):
    o = ''
    for c, pts in segs: o += c + ' '.join('%s %s' % (F(x), F(y)) for x, y in pts)
    return (o + 'z') if closed else o
def _reverse(segs):
    nodes = [segs[0][1][0]]; sg = []
    for c, pts in segs[1:]: nodes.append(pts[-1]); sg.append((c, pts))
    out = [('M', [nodes[-1]])]
    for i in range(len(sg) - 1, -1, -1):
        c, pts = sg[i]; ctrl = pts[:-1][::-1]; out.append((c, ctrl + [nodes[i]]))
    return out
def to_d(el, F=f1):
    """path data with positive (clockwise on screen) orientation, or None if it cannot be safely merged as a fill."""
    t, a = el.tag, el.get
    if el.get('transform'): return None
    if t == q('rect'):
        x, y, w, h = num(a('x')), num(a('y')), num(a('width')), num(a('height')); rx = num(a('rx')); ry = num(a('ry'), rx)
        if rx or ry:
            rx = min(rx, w / 2) if rx else min(ry, w / 2); ry = min(ry, h / 2) if ry else rx
            return 'M%s %sh%sa%s %s 0 0 1 %s %sv%sa%s %s 0 0 1 -%s %sh-%sa%s %s 0 0 1 -%s -%sv-%sa%s %s 0 0 1 %s -%sz' % (F(x + rx), F(y), F(w - 2 * rx), F(rx), F(ry), F(rx), F(ry), F(h - 2 * ry), F(rx), F(ry), F(rx), F(ry), F(w - 2 * rx), F(rx), F(ry), F(rx), F(ry), F(h - 2 * ry), F(rx), F(ry), F(rx), F(ry))
        return 'M%s %sh%sv%sh-%sz' % (F(x), F(y), F(w), F(h), F(w))
    if t in (q('circle'), q('ellipse')):
        cx, cy = num(a('cx')), num(a('cy')); rx = num(a('r')) if t == q('circle') else num(a('rx')); ry = rx if t == q('circle') else num(a('ry'))
        return 'M%s %sa%s %s 0 1 1 %s 0a%s %s 0 1 1 -%s 0z' % (F(cx - rx), F(cy), F(rx), F(ry), F(2 * rx), F(rx), F(ry), F(2 * rx))
    if t == q('polygon'):
        v = [float(x) for x in re.findall(r'-?\d*\.?\d+', a('points') or '')]; P = list(zip(v[::2], v[1::2]))
        if len(P) < 3: return None
        segs = [('M', [P[0]])] + [('L', [p]) for p in P[1:]]
        if _area(segs) < 0: segs = _reverse(segs)
        return _emit(segs, True, F)
    if t == q('path'):
        d = a('d')
        if re.fullmatch(r'M[-\d. ]+a[-\d. ]+ 1 1 [-\d. ]+a[-\d. ]+ 1 1 [-\d. ]+z', d or ''): return d   # clockwise two-arc ellipse
        if a('fill') == 'none' and d and d.startswith('M') and not a('fill-rule') and d.count('M') > 1 and not re.search(r'[AaSsTtZz]', d): return d   # i9: multi-subpath strokes merge too
        r = _parse(d)
        if not r or a('fill-rule') or not d.startswith('M'): return None
        segs, closed = r
        if a('fill') == 'none' and True: return d
        if _area(segs) >= 0: return d
        return _emit(_reverse(segs), closed, F)
    return None
def merge_shapes(parent, consecutive, F=f1):
    """merge shapes with identical non-geometry attributes into one multi-subpath <path>. Filled ones are re-oriented so overlaps still union."""
    items = list(parent); out = []; buckets = {}
    def new(key, grp):
        if len(grp) == 1: return [grp[0][0]]
        n = ET.Element(q('path'), dict(key)); n.set('d', re.sub(r' -', '-', ''.join(d for _, d in grp)))
        if len(ET.tostring(n)) >= sum(len(ET.tostring(e)) for e, _ in grp): return [e for e, _ in grp]
        return [n]
    cur = None
    for e in items:
        d = to_d(e, F) if e.tag in (q('rect'), q('circle'), q('ellipse'), q('path'), q('polygon')) else None
        if d is None: out.append(('e', e)); cur = None; continue
        key = tuple(sorted((k, v) for k, v in e.attrib.items() if k not in GEOM))
        if consecutive:
            if cur is not None and cur[0] == key: cur[1].append((e, d)); continue
            cur = (key, [(e, d)]); out.append(('g', cur))
        else:
            if key not in buckets: buckets[key] = (key, []); out.append(('g', buckets[key]))
            buckets[key][1].append((e, d))
    for e in items: parent.remove(e)
    for k, v in out:
        for e in ([v] if k == 'e' else new(*v)): parent.append(e)
def unwrap(g):
    """splice attribute-less child groups up into g (order kept)."""
    for c in list(g):
        if c.tag == q('g'):
            unwrap(c)
            if not c.attrib:
                i = list(g).index(c); g.remove(c)
                for j, k in enumerate(list(c)): g.insert(i + j, k)
def tidy(g):
    unwrap(g)
    for c in list(g):
        if c.tag == q('g'): tidy(c)
    rnd1(g); merge_shapes(g, False)
    # flatten nested groups without transform are left as is


_ARGN = {'M': 2, 'L': 2, 'T': 2, 'H': 1, 'V': 1, 'C': 6, 'S': 4, 'Q': 4, 'A': 7, 'Z': 0}
def bake_path(d, A, tx, ty):
    out = []
    for m in re.finditer(r'([MmLlHhVvCcSsQqTtAaZz])([^MmLlHhVvCcSsQqTtAaZz]*)', d):
        c = m.group(1); C = c.upper(); rel = c.islower(); v = [float(x) for x in re.findall(r'-?\d*\.?\d+(?:e-?\d+)?', m.group(2))]
        n = _ARGN[C]; o = []
        if C == 'Z': out.append(c); continue
        for i in range(0, len(v), n):
            p = v[i:i + n]
            if C == 'A': p = [p[0] * A, p[1] * A, p[2], p[3], p[4], p[5] * A + (0 if rel else tx), p[6] * A + (0 if rel else ty)]
            elif C == 'H': p = [p[0] * A + (0 if rel else tx)]
            elif C == 'V': p = [p[0] * A + (0 if rel else ty)]
            else: p = [p[j] * A + (0 if rel else (tx if j % 2 == 0 else ty)) for j in range(n)]
            o.extend(p)
        out.append(c + ' '.join(fmt(x) for x in o))
    return re.sub(r' -', '-', ''.join(out))
def bake_path_rot(d, M):
    """i10: full-affine (uniform scale + rotation) bake of M/L/C/S/Q/T/A/Z paths; None if H/V present."""
    a, b, c, dd, e, f = M; th = math.degrees(math.atan2(b, a)); s = math.hypot(a, b); out = []
    for m in re.finditer(r'([MmLlHhVvCcSsQqTtAaZz])([^MmLlHhVvCcSsQqTtAaZz]*)', d):
        ch = m.group(1); C = ch.upper(); rel = ch.islower()
        if C in 'HV': return None
        if C == 'Z': out.append(ch); continue
        v = [float(x) for x in re.findall(r'-?\d*\.?\d+(?:e-?\d+)?', m.group(2))]; n = _ARGN[C]; o = []
        for i in range(0, len(v), n):
            p = v[i:i + n]
            if C == 'A':
                x, y = p[5], p[6]; nx, ny = a * x + c * y + (0 if rel else e), b * x + dd * y + (0 if rel else f)
                o += [p[0] * s, p[1] * s, p[2] + th, p[3], p[4], nx, ny]
            else:
                for j in range(0, n, 2):
                    x, y = p[j], p[j + 1]; o += [a * x + c * y + (0 if rel else e), b * x + dd * y + (0 if rel else f)]
        out.append(ch + ' '.join(fmt(x) for x in o))
    return re.sub(r' -', '-', ''.join(out))
ORIG_R = {}
def _mat(tf):
    """translate/scale(uniform)/rotate -> affine (a,b,c,d,e,f) or None."""
    M = (1.0, 0.0, 0.0, 1.0, 0.0, 0.0)
    def mul(M, N):
        a, b, c, d, e, f = M; A, B, C, D, E, F = N
        return (a * A + c * B, b * A + d * B, a * C + c * D, b * C + d * D, a * E + c * F + e, b * E + d * F + f)
    for m in re.finditer(r'(\w+)\(([^)]*)\)', tf or ''):
        k = m.group(1); v = [float(x) for x in re.split(r'[ ,]+', m.group(2).strip()) if x]
        if k == 'translate': N = (1, 0, 0, 1, v[0], v[1] if len(v) > 1 else 0)
        elif k == 'scale':
            if len(v) > 1 and abs(v[0] - v[1]) > 1e-6: return None
            N = (v[0], 0, 0, v[0], 0, 0)
        elif k == 'rotate':
            t = math.radians(v[0]); co, si = math.cos(t), math.sin(t); cx, cy = (v[1], v[2]) if len(v) > 2 else (0, 0)
            N = (co, si, -si, co, cx - co * cx + si * cy, cy - si * cx - co * cy)
        else: return None
        M = mul(M, N)
    return M
def _mmul(M, N):
    a, b, c, d, e, f = M; A, B, C, D, E, F = N
    return (a * A + c * B, b * A + d * B, a * C + c * D, b * C + d * D, a * E + c * F + e, b * E + d * F + f)
IDM = (1.0, 0.0, 0.0, 1.0, 0.0, 0.0)
def bake_source(kids):
    """chars: fold translate/uniform-scale/rotate groups into leaf geometry (rotated ellipses become arc paths) so halo/outline/clip merge cleanly."""
    res = []
    def wrapT(el, M):
        if M == IDM: return el
        a, b, c, d, e, f = M
        g = ET.Element(q('g'), {'transform': 'matrix(%s)' % ' '.join(fmt3(x) for x in M)}); g.append(el); return g
    def go(el, M):
        if el.tag == q('g'):
            N = _mat(el.get('transform'))
            if N is None: return [wrapT(el, M)]
            M2 = _mmul(M, N); r = []
            for c in list(el): r += go(c, M2)
            return r
        if M == IDM: return [el]
        if el.get('transform'):   # i10: own rotate(a x y) on an ellipse/rect folds under translate+uniform scale
            mr = re.fullmatch(r'rotate\(([-\d.]+) ([-\d.]+) ([-\d.]+)\)', el.get('transform'))
            a0, b0, c0, d0, e0, f0 = M
            if mr and el.tag in (q('ellipse'), q('rect')) and abs(b0) < 1e-9 and abs(c0) < 1e-9 and abs(a0 - d0) < 1e-9:
                n = copy.copy(el); n.attrib = dict(el.attrib); sA = a0
                if el.tag == q('ellipse'):
                    n.set('cx', fmt(sA * num(el.get('cx')) + e0)); n.set('cy', fmt(sA * num(el.get('cy')) + f0)); n.set('rx', fmt(sA * num(el.get('rx')))); n.set('ry', fmt(sA * num(el.get('ry'))))
                else:
                    n.set('x', fmt(sA * num(el.get('x')) + e0)); n.set('y', fmt(sA * num(el.get('y')) + f0)); n.set('width', fmt(sA * num(el.get('width')))); n.set('height', fmt(sA * num(el.get('height'))))
                    for rk in ('rx', 'ry'):
                        if el.get(rk): n.set(rk, fmt(sA * num(el.get(rk))))
                n.set('transform', 'rotate(%s %s %s)' % (mr.group(1), fmt(sA * float(mr.group(2)) + e0), fmt(sA * float(mr.group(3)) + f0))); return [n]
            return [wrapT(el, M)]
        a, b, c, d, e, f = M; s = math.hypot(a, b); th = math.degrees(math.atan2(b, a)); a_ = el.get
        n = copy.copy(el); n.attrib = dict(el.attrib)
        if abs(a * d - b * c - s * s) > 1e-6: return [wrapT(el, M)]
        sw = lambda: n.set('stroke-width', fmt(num(a_('stroke-width')) * s)) if a_('stroke-width') else None
        if el.tag in (q('circle'), q('ellipse')):
            cx, cy = num(a_('cx')), num(a_('cy')); X, Y = a * cx + c * cy + e, b * cx + d * cy + f
            rx = num(a_('r')) if el.tag == q('circle') else num(a_('rx')); ry = rx if el.tag == q('circle') else num(a_('ry'))
            if abs(th) < .01:
                if el.tag == q('circle'): n.set('cx', fmt(X)); n.set('cy', fmt(Y)); n.set('r', fmt(rx * s)); ORIG_R[id(n)] = rx
                else: n.set('cx', fmt(X)); n.set('cy', fmt(Y)); n.set('rx', fmt(rx * s)); n.set('ry', fmt(ry * s))
            else:
                if el.tag == q('circle'): return go_circle(n, X, Y, rx * s)
                co, si = math.cos(math.radians(th)), math.sin(math.radians(th)); R, Q = rx * s, ry * s
                x1, y1 = X - co * R, Y - si * R
                for k in ('cx', 'cy', 'rx', 'ry'): n.attrib.pop(k, None)
                n.tag = q('path'); n.set('d', 'M%s %sa%s %s %s 1 1 %s %sa%s %s %s 1 1 %s %sz' % (fmt(x1), fmt(y1), fmt(R), fmt(Q), fmt(th), fmt(2 * co * R), fmt(2 * si * R), fmt(R), fmt(Q), fmt(th), fmt(-2 * co * R), fmt(-2 * si * R)))
        elif el.tag == q('rect') and abs(th) < .01:
            for rk in ('rx', 'ry'):
                if a_(rk): n.set(rk, fmt(num(a_(rk)) * s))
            n.set('x', fmt(a * num(a_('x')) + e)); n.set('y', fmt(d * num(a_('y')) + f)); n.set('width', fmt(num(a_('width')) * s)); n.set('height', fmt(num(a_('height')) * s))
        elif el.tag == q('path') and a_('d') and abs(th) < .01: n.set('d', bake_path(a_('d'), s, e, f))
        elif el.tag == q('path') and a_('d') and bake_path_rot(a_('d'), M): n.set('d', bake_path_rot(a_('d'), M))
        else: return [wrapT(el, M)]
        sw(); return [n]
    def go_circle(n, X, Y, R):
        n.set('cx', fmt(X)); n.set('cy', fmt(Y)); n.set('r', fmt(R)); return [n]
    for k in kids: res += go(k, IDM)
    return res
def fmt3(x): return ('%.3f' % x).rstrip('0').rstrip('.') or '0'

def q(t): return '{%s}%s' % (NS, t)


def _tf(t):
    a, b, c, d = 1.0, 1.0, 0.0, 0.0   # sx, sy, tx, ty (translate/scale only)
    for m in re.finditer(r'(translate|scale)\(([^)]*)\)', t or ''):
        v = [float(x) for x in re.split(r'[ ,]+', m.group(2).strip()) if x]
        if m.group(1) == 'translate': c += a * v[0]; d += b * (v[1] if len(v) > 1 else 0)
        else: sy = v[1] if len(v) > 1 else v[0]; a *= v[0]; b *= sy
    return a, b, c, d
def _pts(el):
    t, a = el.tag, el.get
    if t == q('rect'):
        x, y, w, h = num(a('x')), num(a('y')), num(a('width')), num(a('height')); return [(x, y), (x + w, y + h)]
    if t == q('circle'):
        x, y, r = num(a('cx')), num(a('cy')), num(a('r')); return [(x - r, y - r), (x + r, y + r)]
    if t == q('ellipse'):
        x, y, rx, ry = num(a('cx')), num(a('cy')), num(a('rx')), num(a('ry')); return [(x - rx, y - ry), (x + rx, y + ry)]
    if t == q('line'): return [(num(a('x1')), num(a('y1'))), (num(a('x2')), num(a('y2')))]
    if t in (q('polygon'), q('polyline')):
        v = [float(x) for x in re.findall(r'-?\d*\.?\d+', a('points') or '')]; return list(zip(v[::2], v[1::2]))
    if t == q('path'):
        out = []; cx = cy = sx = sy = 0.0
        for m in re.finditer(r'([MmLlHhVvCcSsQqTtAaZz])([^MmLlHhVvCcSsQqTtAaZz]*)', a('d') or ''):
            c = m.group(1); v = [float(x) for x in re.findall(r'-?\d*\.?\d+(?:e-?\d+)?', m.group(2))]; rel = c.islower(); C = c.upper()
            if C == 'Z': cx, cy = sx, sy; continue
            n = {'M': 2, 'L': 2, 'T': 2, 'H': 1, 'V': 1, 'C': 6, 'S': 4, 'Q': 4, 'A': 7}[C]
            for i in range(0, len(v) - n + 1, n):
                p = v[i:i + n]
                if C == 'H': nx, ny = (cx + p[0] if rel else p[0]), cy; out.append((nx, ny)); cx = nx; continue
                if C == 'V': nx, ny = cx, (cy + p[0] if rel else p[0]); out.append((nx, ny)); cy = ny; continue
                ox, oy = (cx, cy) if rel else (0, 0)
                if C == 'A': out.append((ox + p[5], oy + p[6])); cx, cy = ox + p[5], oy + p[6]; continue
                for j in range(0, n, 2): out.append((ox + p[j], oy + p[j + 1]))
                cx, cy = ox + p[n - 2], oy + p[n - 1]
                if C == 'M' and i == 0: sx, sy = cx, cy
        return out
    return []
FITB = [False]
def sil_bbox(kids):
    X = []; Y = []
    def walk(el, tr):
        if el.tag == q('g'):
            a, b, c, d = _tf(el.get('transform')); ta, tb, tc, td = tr
            for k in el: walk(k, (ta * a, tb * b, tc + ta * c, td + tb * d))
            return
        if el.tag == q('text') or skip(el): return
        ta, tb, tc, td = tr; a, b, c, d = _tf(el.get('transform'))
        sw = num(el.get('stroke-width'), 0) / 2 if el.get('stroke') not in (None, 'none') else 0
        if FITB[0] and thin_wood(el):   # i10: woodfix later widens thin shafts to MINSHAFT; fit must see that
            th = min(num(el.get('width')), num(el.get('height'))) if el.tag == q('rect') else num(el.get('stroke-width'), 1)
            sw = max(sw, (MINSHAFT - th) / 2 + (th / 2 if el.tag != q('rect') else 0), MINSHAFT / 2 if el.tag != q('rect') else 0)
            sw += (.55 * UU[0] if not NAVF[0] else 0) if el.tag == q('rect') else (.75 * UU[0] if not CHARMODE else 0)   # i11: woodfix rim (rect RIM stroke 1.1u / path copy sw+1.5u) sits outside the shaft; halo grows from it
        if FITB[0] and NAVF[0]: sw += .5 * UU[0]   # i11: nav coords round to whole units (up to .5 off)
        if FITB[0] and TIER and not NAVF[0]: sw += TIER_D[2] * UU[0]   # i11: big silhouettes get the heavy pen tier (+.3u halo/outline); fit must budget it
        P0 = _pts(el); mr = re.fullmatch(r'rotate\(([-\d.]+) ([-\d.]+) ([-\d.]+)\)', el.get('transform') or '')
        if mr and len(P0) == 2 and el.tag in (q('rect'), q('ellipse'), q('circle')):   # i10: rotated shapes: bbox of the 4 rotated corners
            t0 = math.radians(float(mr.group(1))); rx0, ry0 = float(mr.group(2)), float(mr.group(3)); (xa, ya), (xb, yb) = P0
            P0 = [(rx0 + (px - rx0) * math.cos(t0) - (py - ry0) * math.sin(t0), ry0 + (px - rx0) * math.sin(t0) + (py - ry0) * math.cos(t0)) for px, py in ((xa, ya), (xb, ya), (xa, yb), (xb, yb))]; a, b, c, d = 1.0, 1.0, 0.0, 0.0
        for x, y in P0:
            x, y = a * x + c, b * y + d
            X.extend([tc + ta * x - sw * ta, tc + ta * x + sw * ta]); Y.extend([td + tb * y - sw * tb, td + tb * y + sw * tb])
    for k in kids: walk(k, (1, 1, 0, 0))
    return (min(X), min(Y), max(X), max(Y)) if X else None

def arcs(cx, cy, rx, ry):
    return 'M%s %sa%s %s 0 1 0 %s 0a%s %s 0 1 0 -%s 0z' % (f1(cx - rx), f1(cy), f1(rx), f1(ry), f1(2 * rx), f1(rx), f1(ry), f1(2 * rx))
RIMTONE = '#fff1c8'

def num(v, d=0.0):
    try: return float(v)
    except Exception: return d

def tscale(t):
    s = 1.0
    for m in re.finditer(r'scale\(\s*([-\d.]+)(?:[ ,]+([-\d.]+))?\s*\)', t or ''):
        a = float(m.group(1)); b = float(m.group(2)) if m.group(2) else a
        s *= math.sqrt(abs(a * b))
    return s

BAKE1 = [False]   # i11: fit-bake emits 1 decimal (a rescaled sprite must not cost +10% bytes in 2-decimal coords)
def fmt(x):
    s = (('%.1f' if (CHARMODE and LEAN) or BAKE1[0] else '%.2f') % x).rstrip('0').rstrip('.')
    return s

def skip(el):
    """Shapes that should not join the silhouette: ground shadow, glints, white highlight strokes."""
    f = (el.get('fill') or '').lower(); s = (el.get('stroke') or '').lower()
    op = num(el.get('opacity'), 1)
    if f in ('#000', '#000000', UMBER) and op < .5: return True
    if s in ('#fff', '#ffffff') and (f in ('none', '') ): return True
    if f in ('#fff', '#ffffff') and el.tag == q('circle') and num(el.get('r')) < 2.5: return True
    if op < .3: return True
    if DETAIL and el.tag == q('circle') and num(el.get('r')) < 3: return True
    if DETAIL and f == 'none' and num(el.get('stroke-width'), 1) < 2.6:
        if CHARMODE and el.tag == q('path') and s not in ('#fff', '#ffffff'):   # antennae / stalks keep their outline
            P = _pts(el); xs = [p[0] for p in P]; ys = [p[1] for p in P]
            if P and min(max(xs) - min(xs), max(ys) - min(ys)) >= 5: return False
        return True
    return False
CAPS = False
SWARM_MIN = [None]
SWARM = False   # i10: char fallback when >3.9K: capsule silhouettes + opaque-only clip
TIER = True   # i9: pen-weight variance: small leaves lighter, big silhouettes heavier
TIER_D = (-.4, 0.0, .3)
UU = [1.0]
DETAIL = True
DROP = set()   # leaf indices omitted from silhouettes (pruned by prune.py as pixel-redundant)
PROBE = False
PROBE_EXTRA = 1.9

def tier_delta(el, s2):
    bb = sil_bbox([el])
    if not bb: return 0.0
    d = max(bb[2] - bb[0], bb[3] - bb[1]) * s2 / UU[0]
    return TIER_D[0] if d < 9 else (TIER_D[2] if d > 26 else TIER_D[1])
def merge_rects(L):
    """i10: abutting plain rects (stacked bricks / rails) with equal width (or height) and aligned edges union into one rect."""
    for e in L:
        if e.tag == q('g'): merge_rects(e)
    def R(e):
        if e.tag != q('rect') or e.get('transform') or e.get('rx') or e.get('ry'): return None
        try: return [num(e.get('x')), num(e.get('y')), num(e.get('width')), num(e.get('height'))]
        except Exception: return None
    ch = True
    while ch:
        ch = False; rs = [(e, R(e)) for e in L]
        for i, (a, ra) in enumerate(rs):
            if ra is None: continue
            for b, rb in rs[i + 1:]:
                if rb is None or a.get('stroke-width') is None or b.get('stroke-width') is None: continue
                if abs(ra[0] - rb[0]) < .06 and abs(ra[2] - rb[2]) < .06 and rb[1] <= ra[1] + ra[3] + .06 and ra[1] <= rb[1] + rb[3] + .06:
                    y0 = min(ra[1], rb[1]); y1 = max(ra[1] + ra[3], rb[1] + rb[3]); a.set('y', fmt(y0)); a.set('height', fmt(y1 - y0))
                elif abs(ra[1] - rb[1]) < .06 and abs(ra[3] - rb[3]) < .06 and rb[0] <= ra[0] + ra[2] + .06 and ra[0] <= rb[0] + rb[2] + .06:
                    x0 = min(ra[0], rb[0]); x1 = max(ra[0] + ra[2], rb[0] + rb[2]); a.set('x', fmt(x0)); a.set('width', fmt(x1 - x0))
                else: continue
                a.set('stroke-width', fmt(max(num(a.get('stroke-width')), num(b.get('stroke-width'))))); L.remove(b); ch = True; break
            if ch: break
def silhouette(root_children, color, extra, keep_fill=True):
    """Deep copy children; every shape becomes `color`, stroked by `extra` (user units at scale 1)."""
    out = []
    cnt = [0]
    def walk(el, sc):
        if el.tag == q('g'):
            if sc * tscale(el.get('transform')) < .6 and not (CHARMODE and sc == 1.0): return None  # inner emblem sits inside its host
            g = ET.Element(q('g'))
            if el.get('transform'): g.set('transform', el.get('transform'))
            s2 = sc * tscale(el.get('transform'))
            for c in el:
                r = walk(c, s2)
                if r is not None: g.append(r)
            return g if len(g) else None
        if el.tag == q('text') or skip(el) or id(el) in PRUNE: return None
        cnt[0] += 1
        if (cnt[0] - 1) in DROP: return None
        if el.tag == q('circle') and extra and not el.get('transform') and el.get('stroke') in (None, 'none') and num(el.get('r')) > 0:   # i9: circle -> round-cap dot (12 bytes instead of 50)
            s2 = sc * tscale(el.get('transform')); dl = tier_delta(el, s2) * UU[0] if (TIER and not NAVF[0]) else 0.0
            return ET.Element(q('path'), {'d': 'M%s %sh0' % (el.get('cx'), el.get('cy')), 'stroke-width': fmt(2 * num(el.get('r')) + 2 * (extra + dl) / s2)})
        if (SWARM or CAPS) and el.tag == q('ellipse') and extra and (not el.get('transform') or re.fullmatch(r'rotate\([-\d.]+ [-\d.]+ [-\d.]+\)', el.get('transform'))) and el.get('stroke') in (None, 'none') and 0 < num(el.get('ry')) and 0 < num(el.get('rx')) <= 3.2 * num(el.get('ry')):   # i10: ellipse -> round-cap capsule (stadium)
            s2 = sc * tscale(el.get('transform')); dl = tier_delta(el, s2) * UU[0] if (TIER and not NAVF[0]) else 0.0
            rx, ry = num(el.get('rx')), num(el.get('ry')); cx, cy = num(el.get('cx')), num(el.get('cy')); ang = 0.0
            if el.get('transform'):
                ad, tx, ty = [float(v) for v in re.findall(r'-?[\d.]+', el.get('transform'))]; ang = math.radians(ad)
                cx, cy = tx + (cx - tx) * math.cos(ang) - (cy - ty) * math.sin(ang), ty + (cx - tx) * math.sin(ang) + (cy - ty) * math.cos(ang)
            if ry > rx: rx, ry, ang = ry, rx, ang + math.pi / 2
            h = rx - ry; dx, dy = h * math.cos(ang), h * math.sin(ang)
            dd = 'M%s %sl%s %s' % (fmt(cx - dx), fmt(cy - dy), fmt(2 * dx), fmt(2 * dy)) if abs(dy) > .05 else 'M%s %sh%s' % (fmt(cx - dx), fmt(cy), fmt(2 * dx))
            return ET.Element(q('path'), {'d': dd, 'stroke-width': fmt(2 * ry + 2 * (extra + dl) / s2)})
        if SWARM and extra and el.get('fill') == 'none' and el.tag == q('path') and num(el.get('stroke-width'), 9) <= 1.7: return None   # swarm: hairline legs/antennae take no halo/outline
        if SWARM and not extra:   # swarm clip: only the big shapes (wings/limbs take no shade)
            if SWARM_MIN[0] is None:
                mx = 0
                for e2 in root_children:
                    for e3 in e2.iter():
                        if e3.tag != q('g') and not skip(e3):
                            b3 = sil_bbox([e3]); mx = max(mx, (b3[2] - b3[0]) * (b3[3] - b3[1]) if b3 else 0)
                SWARM_MIN[0] = mx * .2
            b = sil_bbox([el])
            if b and (b[2] - b[0]) * (b[3] - b[1]) < SWARM_MIN[0]: return None
        if SWARM and not extra and el.get('opacity') and num(el.get('opacity'), 1) < 1: return None   # swarm clip: translucent wings take no shade
        n = ET.Element(el.tag, {k: v for k, v in el.attrib.items()
                                if k not in ('fill', 'stroke', 'stroke-width', 'opacity', 'stroke-dasharray', 'fill-opacity', 'stroke-opacity', 'role', 'aria-label') + (('stroke-linecap', 'stroke-linejoin') if CHARMODE else ())})
        if el.tag == q('rect') and num(el.get('rx')) <= 3.5 and num(el.get('ry')) <= 3.5: n.attrib.pop('rx', None); n.attrib.pop('ry', None)
        s2 = sc * tscale(el.get('transform'))
        sw = num(el.get('stroke-width'), 0) if (el.get('stroke') not in (None, 'none')) else 0
        f = el.get('fill')
        if f == 'none' or (f is None and sw and el.tag == q('path') and re.fullmatch(r'[MmLlHhVv0-9\s.,-]+', el.get('d') or '')): n.set('fill', 'none')   # i9: straight stroke-only paths have zero fill area: treat as fill none (merges, drops from clip)
        dl = tier_delta(el, s2) * UU[0] if (TIER and extra and not NAVF[0]) else 0.0
        n.set('stroke-width', fmt(sw + 2 * (extra + dl) / s2))
        return n
    for c in root_children:
        r = walk(c, 1.0)
        if r is not None: out.append(r)
    silhouette.count = cnt[0]
    merge_rects(out)
    return out

def _hex(c):
    c = (c or '').lower()
    if re.fullmatch(r'#[0-9a-f]{6}', c): return tuple(int(c[i:i+2], 16) for i in (1, 3, 5))
    if re.fullmatch(r'#[0-9a-f]{3}', c): return tuple(int(ch * 2, 16) for ch in c[1:])
    return None

def is_wood(c):
    h = _hex(c)
    if not h: return False
    r, g, b = h
    return r > g > b and r - b > 40 and r < 200 and (0.3 * r + 0.59 * g + 0.11 * b) < 120

def lift(c, t=.42):
    r, g, b = _hex(c); L = (240, 207, 148)
    return '#%02x%02x%02x' % tuple(int(x + t * (y - x)) for x, y in zip((r, g, b), L))

RIM = '#f0d49a'

def thin_wood(el):
    if el.tag == q('rect'):
        return is_wood(el.get('fill')) and min(num(el.get('width')), num(el.get('height'))) <= 8
    if el.get('fill') in (None, 'none') and is_wood(el.get('stroke')) and num(el.get('stroke-width'), 1) <= 6.5:
        return el.tag in (q('path'), q('line'), q('polyline'))
    return False

MINSHAFT = 6.6
def detail_line(el):
    return (el.tag in (q('path'), q('line'), q('polyline')) and el.get('fill') in (None, 'none')
            and is_wood(el.get('stroke')) and num(el.get('stroke-width'), 1) < 2.6)

SCENE = False
def woodfix(parent, u):
    """Thin brown parts: lift tone and add a light rim so they separate from the umber outline."""
    for el in list(parent):
        if el.tag == q('g'): woodfix(el, u); continue
        if detail_line(el) and not SCENE:   # i1: inner detail lines (spirals, grain) read as umber cel lines
            el.set('stroke', UMBER); el.set('stroke-width', '2.4'); continue
        if not thin_wood(el): continue
        if el.tag != q('rect') and num(el.get('stroke-width'), 1) < MINSHAFT and not SCENE and not re.search(r'[QqCcAaSsTt]', el.get('d') or ''):   # i1: shafts get body
            el.set('stroke-width', fmt(MINSHAFT))
        if el.tag == q('rect'):
            el.set('fill', lift(el.get('fill')))
            if not NAVF[0]: el.set('stroke', RIM); el.set('stroke-width', fmt(1.1 * u)); el.set('stroke-linejoin', 'round')
        else:
            sw = num(el.get('stroke-width'), 1)
            rim = copy.deepcopy(el)
            if CHARMODE: rim = None   # i9: chars skip the rim copy (bytes; halo/outline already separate the limb)
            else: rim.set('stroke', RIM); (rim.set('stroke-width', fmt(sw + 1.5 * u)), rim.attrib.pop('opacity', None)) if rim is not None else None
            el.set('stroke', lift(el.get('stroke')))
            if rim is not None: parent.insert(list(parent).index(el), rim)

def hoist(g):
    """Most common stroke-width among direct shapes moves up to the group; only exceptions keep theirs. Redundant join/cap dropped."""
    for c in g:
        if c.tag == q('g'): hoist(c)
    shapes = [c for c in g if c.tag != q('g')]
    for c in shapes:
        for a in ('stroke-linejoin', 'stroke-linecap'):
            if c.get(a) == 'round' and g.get(a) == 'round' or (c.get(a) == 'round' and g.get(a) is None and False): del c.attrib[a]
    ws = [c.get('stroke-width') for c in shapes if c.get('stroke-width')]
    if len(shapes) > 1 and ws and len(ws) == len(shapes):
        top = max(set(ws), key=ws.count)
        if ws.count(top) > 1:
            g.set('stroke-width', top)
            for c in shapes:
                if c.get('stroke-width') == top: del c.attrib['stroke-width']

def remap(el):
    for e in el.iter():
        for k in ('fill', 'stroke'):
            v = (e.get(k) or '').lower()
            if v in REMAP: e.set(k, REMAP[v])

INNER_W = 1.0
TINY_INNER = 12
MARK_MIN = 14
def inner(el, u):
    """i1: thin umber contour on each filled shape so overlapping same-hue parts separate (shell/body, leaf/mound)."""
    if el.tag == q('g'):
        for c in el: inner(c, u)
        return
    f = (el.get('fill') or '').lower()
    if f in ('none', '', '#fff', '#ffffff') or el.get('stroke') or el.tag == q('text'): return
    if num(el.get('opacity'), 1) < .6 or (el.tag == q('circle') and num(el.get('r')) < 3): return
    if not INNER_W: return
    bb = sil_bbox([el])
    if bb and min(bb[2] - bb[0], bb[3] - bb[1]) < TINY_INNER * u: return   # i7: contour on tiny shapes is noise at 32px
    el.set('stroke', UMBER); el.set('stroke-width', fmt(INNER_W * u)); el.set('stroke-opacity', '.55'); el.set('stroke-linejoin', 'round')

def mat_class(e):
    f = (e.get('fill') or '').lower(); h = _hex(f)
    if not h or e.tag not in (q('rect'), q('ellipse'), q('circle'), q('path'), q('polygon')): return None
    r, g, b = h; L = .3 * r + .59 * g + .11 * b; mx, mn = max(h), min(h)
    if mx > 235 and mn > 215: return None
    if mx - mn < 40 and r >= g - 6 and 90 < L < 225 and b >= mn: return 'stone' if mx - mn < 40 and (b > g - 12 or mx - mn < 14) else None
    if b > r and b >= g - 20 and b - r > 30: return 'water'
    if g > r and g > b and mx - mn > 30: return 'leaf'
    if r > g > b and r - b > 40:
        if L < 85: return 'soil'
        if L < 150: return 'wood'
        return 'shell' if e.tag == q('ellipse') and num(e.get('rx')) >= 10 else None
    return None
def mat_marks(shp, u, cid, root, npc, chars=False):
    """i5: <=3 tiny marks per shape (merged into <=4 paths), shapes >=6u, colours from palette only."""
    if npc or chars or not MAT or FIXED: return
    cands = []
    def walk(el, tf):
        if el.tag == q('g'):
            if el.get('transform'): return
            for c in el: walk(c, tf)
            return
        if skip(el) or el.get('transform') or el.tag == q('text'): return
        c = mat_class(el); bb = sil_bbox([el])
        if c and bb and bb[2] - bb[0] >= MARK_MIN * u and bb[3] - bb[1] >= MARK_MIN * u:
            cands.append(((bb[2] - bb[0]) * (bb[3] - bb[1]), c, bb))
    for k in shp: walk(k, 0)
    cands.sort(key=lambda t: -t[0]); D = {'ink': '', 'lite': '', 'vein': '', 'dot': ''}
    for _, c, (x0, y0, x1, y1) in cands[:2]:
        w, h = x1 - x0, y1 - y0; F = fmt
        if c == 'wood':
            if w >= h: D['ink'] += ''.join('M%s %sh%s' % (F(x0 + a * w), F(y0 + t * h), F(.22 * w)) for a, t in ((.2, .3), (.5, .55), (.3, .8)))
            else: D['ink'] += ''.join('M%s %sv%s' % (F(x0 + t * w), F(y0 + a * h), F(.22 * h)) for a, t in ((.2, .3), (.5, .55), (.3, .8)))
        elif c == 'stone':
            D['lite'] += 'M%s %sh%sM%s %sh%s' % (F(x0 + .18 * w), F(y0 + .22 * h), F(.34 * w), F(x0 + .18 * w), F(y0 + .38 * h), F(.12 * w))
        elif c == 'water':
            D['lite'] += 'M%s %sq%s %s %s 0t%s 0' % (F(x0 + .2 * w), F(y0 + .5 * h), F(.1 * w), F(-.1 * h), F(.2 * w), F(.2 * w))
        elif c == 'leaf':
            if w >= h: D['vein'] += 'M%s %sQ%s %s %s %s' % (F(x0 + .12 * w), F(y0 + .55 * h), F(x0 + .5 * w), F(y0 + .4 * h), F(x0 + .88 * w), F(y0 + .5 * h))
            else: D['vein'] += 'M%s %sQ%s %s %s %s' % (F(x0 + .5 * w), F(y0 + .88 * h), F(x0 + .42 * w), F(y0 + .5 * h), F(x0 + .52 * w), F(y0 + .14 * h))
        elif c == 'soil':
            D['dot'] += ''.join('M%s %sh.1' % (F(x0 + a * w), F(y0 + t * h)) for a, t in ((.3, .35), (.6, .55), (.45, .75)))
        elif c == 'shell':
            D['ink'] += 'M%s %sq%s %s %s %sM%s %sq%s %s %s %s' % (F(x0 + .3 * w), F(y0 + .55 * h), F(.15 * w), F(-.25 * h), F(.3 * w), F(-.05 * h), F(x0 + .38 * w), F(y0 + .72 * h), F(.1 * w), F(-.12 * h), F(.2 * w), F(-.02 * h))
    A = {'clip-path': 'url(#%s)' % cid, 'fill': 'none', 'stroke-linecap': 'round', 'stroke-width': F(.9 * u) if False else fmt(.9 * u)}
    for key, col, op, sw in (('ink', UMBER, '.4', .9), ('vein', '#17361c', '.5', .9), ('lite', '#fffaf0', '.55', .9), ('dot', '#f0d49a', '.8', 1.3)):
        if D[key]: ET.SubElement(root, q('path'), dict(A, d=D[key], stroke=col, opacity=op, **{'stroke-width': fmt(sw * u)}))

MAT = True
TRIM = False
FIT = True
FIXED = False   # i8: stage-* and hedge pieces: no per-sprite marks/glint/AO; shade geometry fixed so base never moves
HEDGE = False
HG = '#58a03e'
def hedge_kids(kids, name):
    """i8: hedge family rebuilt on one shared lattice: circle chains every 6.4u (64 = 10 steps) so every piece has the same phase, y band and width at every join."""
    piece = name.rsplit('-', 1)[1]; fam = name.split('-')[0]; pts = []
    def C(x, y): pts.append((x, y)); return ET.Element(q('circle'), {'cx': fmt(x), 'cy': fmt(y), 'r': '8', 'fill': HG})
    xs = [6.4 * i for i in range(11)]; ys = [32 + 6.4 * i for i in range(1, 6)]
    if piece == 'gate':
        out = [k for k in kids if not (k.tag == q('ellipse') or (k.tag == q('circle') and num(k.get('r')) < 8))]
        out = [C(0, 32), C(6.4, 32), C(57.6, 32), C(64, 32)] + out
    else:
        arm = {'straight': xs, 'corner': xs[5:], 'tee': xs, 'end': xs[5:], 'cross': xs}[piece]
        ys = [32 - 6.4 * i for i in range(5, 0, -1)] + ys if piece == 'cross' else ys
        out = [C(x, 32) for x in arm] + ([C(32, y) for y in ys] if piece in ('corner', 'tee', 'cross') else [])
    if fam in ('holly', 'lavender') and piece != 'gate':
        a1, b1, c1, c2 = (('#d6322b', 4.4, 0, 0) if fam == 'holly' else ('#7a5cc0', 5.2, -1, -2))
        if fam == 'holly': out.append(ET.Element(q('path'), {'d': ''.join('M%s %sh0' % (fmt(x + 1.5 * (-1) ** i), fmt(y - 1)) for i, (x, y) in enumerate(pts)), 'stroke': a1, 'stroke-width': '4.4', 'stroke-linecap': 'round'}))
        else:
            out.append(ET.Element(q('path'), {'d': ''.join('M%s %sh0' % (fmt(x - 1), fmt(y - 2)) for x, y in pts), 'stroke': '#7a5cc0', 'stroke-width': '5.2', 'stroke-linecap': 'round'}))
            out.append(ET.Element(q('path'), {'d': ''.join('M%s %sh0' % (fmt(x + 2), fmt(y + 2)) for x, y in pts), 'stroke': '#c3b2ea', 'stroke-width': '4.4', 'stroke-linecap': 'round'}))
    d = {'straight': 'M-1 27.5H65', 'gate': 'M-1 27.5H12M52 27.5H65', 'tee': 'M-1 27.5H65M27.5 32V65', 'corner': 'M27.5 38V30.5Q27.5 27.5 31 27.5H65', 'end': 'M30 27.5H65', 'cross': 'M-1 27.5H65M27.5 -1V65'}[piece]
    out.append(ET.Element(q('path'), {'d': d, 'fill': 'none', 'stroke': '#b8d47c', 'stroke-width': '2', 'opacity': '.55'}))
    sd = {'corner': 'M28 37H66V44H46V66H40V44H28z', 'tee': 'M-2 37H66V44H46V66H40V44H-2z', 'end': 'M26 37H66V44H26z', 'cross': 'M-2 37H66V44H46V66H40V44H-2zM40 -2H46V37H40z'}.get(piece, 'M-2 37H66V44H-2z')
    out.append(ET.Element(q('path'), {'d': sd, 'fill': UMBER, 'opacity': '.3'}))
    return out
HEDGE_SH = {'end': 'M24 34h42v12h-42z', 'cross': 'M-2 34h68v12h-68zM34 -2h12v68h-12z', 'straight': 'M-2 34h68v12h-68z', 'gate': 'M-2 34h68v12h-68z', 'tee': 'M-2 34h68v12h-68zM34 34h12v32h-12z', 'corner': 'M24 34h42v12h-42zM34 34h12v32h-12z'}
FENCE_RE = r'^((picket|wattle)-fence|garden-gate|stone-wall)-(straight|corner|tee|cross|end|gate)$'
def fence_kids(kids, name):
    """i9: picket/wattle pieces rebuilt on the hedge lattice: pitch 6.4u (10 per tile), rails run past both edges, so runs join with no seam."""
    if not re.match(r'(picket|wattle)-fence-', name): return [k for k in kids if k.tag != q('ellipse')]   # i12: garden-gate/stone-wall pieces keep their art; ground shadow dropped, fixed band shade (FENCE_SH) joins runs
    kind, piece = name.split('-fence-')
    pk = kind == 'picket'
    def E(t, **a): return ET.Element(q(t), a)
    out = []
    hx = [3.2 + 6.4 * i for i in range(10)]
    if piece == 'gate':
        out = [k for k in kids if k.tag != q('ellipse')]
        hx = [3.2, 60.8]; hr = [(-1, 6), (58, 65)]; ys = []; vr = None
    else:
        hx = {'end': hx[5:], 'corner': hx[5:]}.get(piece, hx)
        hr = [(32, 65)] if piece in ('end', 'corner') else [(-1, 65)]
        ys = {'corner': [35.2 + 6.4 * j for j in range(5)], 'tee': [35.2 + 6.4 * j for j in range(5)], 'cross': [3.2 + 6.4 * j for j in range(10)]}.get(piece, [])
        vr = (-1, 65) if piece == 'cross' else (32, 65)
    w1 = w2 = ''
    if pk:
        rc, slat = '#968f96', '#f8eed2'
        for a, b in hr: out.append(E('path', d='M%s 30.2h%sM%s 36.7h%s' % (a, b - a, a, b - a), fill='none', stroke=rc, **{'stroke-width': '2.4'}))
        if ys: out.append(E('path', d='M30.2 %sv%sM36.7 %sv%s' % (vr[0], vr[1] - vr[0], vr[0], vr[1] - vr[0]), fill='none', stroke=rc, **{'stroke-width': '2.4'}))
        for x in hx: out.append(E('rect', x=fmt(x - 2.1), y='25', width='4.2', height='15', rx='1.5', fill=slat))
        for y in ys: out.append(E('rect', x='25', y=fmt(y - 2.1), width='15', height='4.2', rx='1.5', fill=slat))
        if piece != 'gate': out.append(E('rect', x='26.5', y='26.5', width='11', height='11', rx='2.5', fill='#d6c9b6')); out.append(E('rect', x='28', y='28', width='8', height='8', rx='2', fill=slat))
        sd = ''.join('M%s 40H%sV44H%sz' % (a - 1 if a < 0 else a, b + 1 if b > 64 else b, a - 1 if a < 0 else a) for a, b in hr) + ('M40 %sH44V66H40z' % (-2 if piece == 'cross' else 40) if ys else '')
    else:
        wb = '#a5663a'
        for a, b in hr:
            out.append(E('rect', x=str(a), y='27.5', width=str(b - a), height='9', fill=wb))
            for i in range(10):
                x = 1.6 + 6.4 * i
                if a - 3 <= x < b - 1:
                    if i % 2: w2 += 'M%s 28.5l4 7' % fmt(x)
                    else: w1 += 'M%s 28.5l4 7' % fmt(x)
        if ys:
            out.append(E('rect', x='27.5', y=str(vr[0]), width='9', height=str(vr[1] - vr[0]), fill=wb))
            for j in range(10):
                y = .8 + 6.4 * j
                if vr[0] - 3 <= y < vr[1] - 1 and not (26 < y < 38):
                    if j % 2: w2 += 'M28.5 %sl7 4' % fmt(y)
                    else: w1 += 'M28.5 %sl7 4' % fmt(y)
        for dd, col in ((w1, '#8c4a1a'), (w2, '#dcb06a')):
            if dd: out.append(E('path', d=dd, fill='none', stroke=col, **{'stroke-width': '1.8', 'stroke-linecap': 'round'}))
        if piece != 'gate': out.append(E('circle', cx='32', cy='32', r='5', fill='#44281c')); out.append(E('circle', cx='31', cy='31', r='2', fill=wb))
        sd = ''.join('M%s 37H%sV41H%sz' % (a - 1 if a < 0 else a, b + 1 if b > 64 else b, a - 1 if a < 0 else a) for a, b in hr) + ('M37 %sH41V66H37z' % (-2 if piece == 'cross' else 37) if ys else '')
    out.append(E('path', d=sd, fill=UMBER, opacity='.3'))
    return out
FENCE_SH = {'straight': 'M-2 33h68v9h-68z', 'gate': 'M-2 33h68v9h-68z', 'end': 'M-2 33h68v9h-68z', 'tee': 'M-2 33h68v9h-68zM33 33h9v33h-9z', 'corner': 'M24 33h42v9h-42zM33 33h9v33h-9z', 'cross': 'M-2 33h68v9h-68zM33 -2h9v68h-9z'}
CHARMODE = False
LEAN = False
INNER_ON = True
def restyle(src, name):
    global INNER_W
    w0 = INNER_W
    global MAT
    global LEAN
    if name.startswith(CHARS):   # i7: chars always LEAN (as i6 after its byte cap): 1-decimal, no rim/AO/marks, no inner contour
        global SWARM
        LEAN = True; INNER_W = 0; SWARM = False; out = _restyle(src, name)
        if len(out.encode()) > 3900: SWARM = True; SWARM_MIN[0] = None; out = _restyle(src, name); SWARM = False
        INNER_W = w0; LEAN = False; return out
    global TRIM, CAPS
    big = not name.startswith(('banner-', 'land-'))
    # i10 trim ladder, richest first: (TRIM no rim/AO/glint, INNER_W 0 = no inner contour, MAT marks, CAPS capsule silhouettes)
    best = None
    for tr, iw, mt, cp in ((False, w0, True, False), (True, w0, True, False), (True, 0, True, False), (True, 0, False, False), (True, w0, True, True), (True, 0, True, True), (True, 0, False, True)):
        TRIM, INNER_W, MAT, CAPS = tr, iw, mt, cp
        out = _restyle(src, name); n = len(out.encode())
        if best is None or n < best[0] and best[0] > 3500: best = (n, out)
        if n <= 3500 or not big: best = (n, out); break
    TRIM = False; INNER_W = w0; MAT = True; CAPS = False
    return best[1]

AURA_IDS = set()
def is_aura(e):
    return id(e) in AURA_IDS or e.tag == q('circle') and not e.get('transform') and (e.get('fill') or '').lower() not in ('#000', '#000000', UMBER, 'none') and num(e.get('opacity'), 1) < .3 and num(e.get('r')) >= 18 and not e.get('stroke')

def _restyle(src, name):
    ORIG_R.clear(); PRUNE.clear(); AURA_IDS.clear()   # i12: id()-keyed caches must not leak across sprites (output depended on file order / heap layout)
    global CHARMODE
    global FIXED, HEDGE, FENCE
    CHARMODE = name.startswith(CHARS); EYE_DARK[0] = name in ('creature-black-bear', 'creature-honey-badger-brute', 'creature-paper-wasp'); NAVF[0] = name.startswith('nav-')
    HEDGE = bool(re.search(r'-(hedge|border)-(straight|corner|tee|gate|end|cross)$', name)); FENCE = bool(re.search(FENCE_RE, name)); HEDGE = HEDGE or FENCE; FIXED = HEDGE or name.startswith('stage-')
    root = ET.fromstring(src)
    vb = [float(x) for x in root.get('viewBox').split()]
    W, H = vb[2], vb[3]
    u = min(W, H) / 64.0; UU[0] = u
    kids = list(root)
    for k in kids: root.remove(k)
    for k in kids: remap(k)
    if CAPS:   # i10 last rungs: corner radii <= 1.6u vanish at icon sizes; plain rects bucket-merge into one path
        for k in kids:
            for e in k.iter():
                if e.tag == q('rect') and num(e.get('rx')) <= 1.6 and num(e.get('ry'), 0) <= 1.6: e.attrib.pop('rx', None); e.attrib.pop('ry', None)
    if name == 'tile-brick-path':   # i12: running bond on a 64 lattice: 4 bricks per row (pitch 16), 6 rows (pitch 64/6), odd rows offset 8 and wrapped; no edge stubs/glint
        cols = ('#a8241f', '#d6322b', '#a8241f', '#a8241f', '#d6322b', '#a8241f', '#a8241f', '#a8241f')
        kids = [kids[0]]; ph = 64 / 6.0
        for r in range(6):
            for c in range(4):
                x = 1 + 16 * c + (8 if r % 2 else 0)
                for xx in ((x, x - 64) if x > 50 else (x,)):
                    kids.append(ET.Element(q('rect'), {'x': fmt(xx), 'y': fmt(r * ph + 1), 'width': '14', 'height': fmt(ph - 2), 'rx': '1.5', 'fill': cols[(r * 3 + c * 5) % 8]}))
    if name == 'tile-bark-path':   # i12: bark chips must not cross the tile edge (clipped chips made a horizontal seam)
        for k in kids[1:]:
            m = re.fullmatch(r'rotate\(([-\d.]+) ([-\d.]+) ([-\d.]+)\)', k.get('transform') or '')
            if not m: continue
            t = math.radians(float(m.group(1))); x, y, w, h = [num(k.get(a)) for a in ('x', 'y', 'width', 'height')]; px, py = float(m.group(2)), float(m.group(3))
            P = [(px + (a - px) * math.cos(t) - (b - py) * math.sin(t), py + (a - px) * math.sin(t) + (b - py) * math.cos(t)) for a in (x, x + w) for b in (y, y + h)]
            dx = max(0, 1 - min(p[0] for p in P)) - max(0, max(p[0] for p in P) - 63); dy = max(0, 1 - min(p[1] for p in P)) - max(0, max(p[1] for p in P) - 63)
            if dx or dy: k.set('x', fmt(x + dx)); k.set('y', fmt(y + dy)); k.set('transform', 'rotate(%s %s %s)' % (m.group(1), fmt(px + dx), fmt(py + dy)))
    if name.startswith('stage-'):   # i11: mound bottom (60) + heavy-tier halo reaches 63.5 = touches the frame row; lift the mound cy 52 -> 51.5 on every step (same for all, so the base never moves between steps)
        for k in kids:
            if k.tag == q('ellipse') and num(k.get('cy')) == 52 and num(k.get('ry')) == 8: k.set('cy', '51.5')
    if name in ('stage-tree-4', 'stage-nut-4'):   # i9: crown overflowed the top edge; shrink trunk+crown about the mound top, mound fixed
        g = ET.Element(q('g'), {'transform': 'translate(4.8 7.5) scale(.85)'}); [g.append(k) for k in kids[4:]]; kids = kids[:4] + [g]
    if FENCE: kids = fence_kids(kids, name)
    elif HEDGE: kids = hedge_kids(kids, name)
    if FIT and not re.search(r'border|logo|fence|hedge|-(straight|corner|tee|cross|end|gate)$|^tile-|^banner-|^land-|^guide-|^npc-|^stage-', name) and kids and not (kids[0].tag == q('rect') and num(kids[0].get('width')) >= W - 6):
        FITB[0] = True; bb = sil_bbox([k for k in kids if k.tag != q('ellipse') or (k.get('fill') or '').lower() not in ('#000', '#000000')]); FITB[0] = False
        if bb and (bb[0] < 3.8 * u or bb[1] < 3.8 * u or bb[2] > W - 3.8 * u or bb[3] > H - 3.8 * u):   # i11: 3.2u halo + AA px: reach must stay <= 63.5 at 64px   # i10: halo (3.2u) must fit inside the frame
            k = min(1.0, (W - 8.4 * u) / max(bb[2] - bb[0], 1), (H - 8.4 * u) / max(bb[3] - bb[1], 1)); cx, cy = (bb[0] + bb[2]) / 2, (bb[1] + bb[3]) / 2
            if k < .985 or True:
                tf = 'translate(%s %s) scale(%s) translate(%s %s)' % (fmt(W / 2), fmt(H / 2), fmt3(k), fmt(-cx), fmt(-cy))
                if k >= .985:   # i10: fits, but off-centre: minimal shift keeps the 3.6u halo margin
                    dx = max(0, 3.9 * u - bb[0]) - max(0, bb[2] - (W - 3.9 * u)); dy = max(0, 3.9 * u - bb[1]) - max(0, bb[3] - (H - 3.9 * u)); tf = 'translate(%s %s)' % (fmt(dx), fmt(dy))
                g = ET.Element(q('g'), {'transform': tf}); SH = [c for c in kids if c.tag == q('ellipse') and ((c.get('fill') or '').lower() in ('#000', '#000000') or ((c.get('fill') or '').lower() == UMBER and num(c.get('opacity'), 1) < .5))]; [g.append(c) for c in kids if c not in SH]   # i11: ground shadow may already be UMBER here; it must stay put, not ride the fit shift/scale out of frame
                BAKE1[0] = True; bk = bake_source([copy.deepcopy(g)]); BAKE1[0] = False   # i10: bake the fit transform into geometry when every leaf can take it (clip copies stay transform-free)
                kids = SH + (bk if all(e.tag != q('g') for e in bk) else [g])
    if name.startswith(CHARS):
        kids = bake_source(flat_groups(kids))
        for e in kids:   # i12: rarity aura disc must stay inside the frame (fit shift used to push it off the left edge -> flat clip)
            if is_aura(e):
                cx0, cy0 = num(e.get('cx')), num(e.get('cy')); lim = min(cx0 - vb[0], vb[0] + W - cx0, cy0 - vb[1], vb[1] + H - cy0)
                if num(e.get('r')) > lim - 1 > 4: AURA_IDS.add(id(e)); e.set('r', fmt(lim - 1))   # i13: keep 1u inside the frame; id-tagged because r may now be < 18
        for k in kids:   # i9: whiskers (white multi-subpath hairlines) become soft umber ticks, not white noise on the halo
            for e in k.iter():
                if e.tag == q('path') and e.get('fill') == 'none' and (e.get('stroke') or '').lower() in ('#fff', '#ffffff') and num(e.get('stroke-width'), 9) <= 1.6 and (e.get('d') or '').count('M') >= 3 and not e.get('opacity'):
                    e.set('stroke', UMBER); e.set('opacity', '.55'); e.set('stroke-width', '1')
        for k in kids:   # translucent white ellipse wings become solid pale wings (kept in silhouette)
            for e in k.iter():
                if e.tag == q('ellipse') and (e.get('fill') or '').lower() == '#fff' and .3 <= num(e.get('opacity'), 1) < .6 and num(e.get('rx')) >= 5:
                    e.set('fill', '#e6f1ec'); e.attrib.pop('opacity')
        for k in kids:
            for e in k.iter():
                for a in ('fill', 'stroke'):
                    if (e.get(a) or '').lower() in CHAR_REMAP: e.set(a, CHAR_REMAP[(e.get(a) or '').lower()])
    if not name.startswith('tile-'):
        wrap = ET.Element(q('g'))
        for k in kids: wrap.append(k)
        f0 = kids[0] if kids else None
        global SCENE
        SCENE = (f0 is not None and f0.tag == q('rect') and num(f0.get('x')) <= 3 and num(f0.get('y')) <= 3
                 and num(f0.get('width')) >= W - 6 and num(f0.get('height')) >= H - 6)
        woodfix(wrap, u); kids = list(wrap)
    if name.startswith('nav-'):   # i7: nav icons are 24px: rounded corners < 3u are invisible, drop rx
        for k in kids:
            for e in k.iter():
                if e.tag == q('rect') and num(e.get('rx')) <= 3.5: e.attrib.pop('rx', None); e.attrib.pop('ry', None)
                if e.get('fill') == 'none' and e.get('stroke-linecap') == 'round' and num(e.get('stroke-width')) <= 3.2: e.attrib.pop('stroke-linecap', None); e.attrib.pop('stroke-linejoin', None)
    PRUNE.clear()
    if name.startswith(CHARS) or not SCENE: prune_inside(kids)   # i7: shapes fully inside a bigger ellipse add nothing to halo/outline/clip
    first = kids[0] if kids else None
    if not name.startswith(('tile-', 'npc-')) and not SCENE:
        def isg(e):
            f = (e.get('fill') or '').lower(); st = (e.get('stroke') or '').lower()
            return ((f in ('#fff', '#ffffff') and num(e.get('opacity'), 1) < .6) or (st in ('#fff', '#ffffff') and f in ('none', '') and num(e.get('opacity'), 1) < .9))
        def dg(p):
            for c in list(p):
                if c.tag == q('g'): dg(c)
                elif isg(c): p.remove(c)
        for k in list(kids):
            if k.tag == q('g'): dg(k)
        kids = [k for k in kids if not (k.tag != q('g') and isg(k))]
    scene = (first is not None and first.tag == q('rect') and num(first.get('x')) <= 3 and num(first.get('y')) <= 3
             and num(first.get('width')) >= W - 6 and num(first.get('height')) >= H - 6)
    slug = re.sub(r'[^a-z0-9]+', '-', name.lower()).strip('-')
    cid = 'hl-' + slug
    npc = name.startswith('npc-')
    nav = name.startswith('nav-')
    ok = 0.6 if npc else 1.0
    # crescent: everything outside a circle shifted up-left => shade hugs lower-right edges
    cx, cy, r = vb[0] + W * .40, vb[1] + H * .36, min(W, H) * .50
    if scene: cx, cy, r = vb[0] + W * .5, vb[1] + H * .42, max(W, H) * .62
    cres = ('M%s %sh%sv%sh-%sz M%s %sa%s %s 0 1 0 %s 0a%s %s 0 1 0 -%s 0z' % (
        f1(vb[0]), f1(vb[1]), f1(W), f1(H), f1(W),
        f1(cx - r), f1(cy), f1(r), f1(r), f1(2 * r), f1(r), f1(r), f1(2 * r)))
    if PROBE:
        g = ET.SubElement(root, q('g'), {'fill': '#000', 'stroke': '#000', 'stroke-linejoin': 'round', 'stroke-linecap': 'round'})
        for e in silhouette(kids, '#000', PROBE_EXTRA * u * ok): g.append(e)
        return ET.tostring(root, encoding='unicode').replace('ns0:', '')
    if name.startswith('tile-'):
        for k in kids: root.append(k)
        ET.SubElement(root, q('path'), {'d': 'M12 20h4M44 8h3M26 46h4M52 38h3M8 56h3M36 28h3', 'stroke': UMBER, 'stroke-width': '1', 'opacity': '.14'})   # i8: shared hairline grain, all tiles
    elif scene:
        for k in kids: root.append(k)
        defs = ET.SubElement(root, q('defs'))
        cp = ET.SubElement(defs, q('clipPath'), {'id': cid})
        b = copy.deepcopy(first)
        for a in ('fill', 'opacity'): b.attrib.pop(a, None)
        cp.append(b)
        ET.SubElement(root, q('path'), {'d': cres, 'fill': shade_color(kids), 'opacity': '.24', 'fill-rule': 'evenodd', 'clip-path': 'url(#%s)' % cid})
        bw = 1.6 * u
        bd = {'x': fmt(num(first.get('x')) + bw / 2), 'y': fmt(num(first.get('y')) + bw / 2),
              'width': fmt(num(first.get('width')) - bw), 'height': fmt(num(first.get('height')) - bw),
              'fill': 'none', 'stroke': UMBER, 'stroke-width': fmt(bw), 'opacity': '.5'}
        if first.get('rx'): bd['rx'] = first.get('rx')
        ET.SubElement(root, q('rect'), bd)
    else:
        if CHARMODE and not npc:   # i12: aura discs sit under the cream halo (a glow behind the sprite), not over its outline
            for e in [k for k in kids if is_aura(k)]:
                kids.remove(e); h = _hex(e.get('fill')); e.set('fill', '#%02x%02x%02x' % tuple(int(a + .35 * (b - a)) for a, b in zip(h, (255, 244, 205)))); e.set('opacity', fmt3(min(.4, num(e.get('opacity')) * 1.5))); root.append(e)   # lighter, same hue: reads as glow on dark
        shadow = [k for k in kids if (k.get('fill') or '').lower() == UMBER and num(k.get('opacity'), 1) < .5]
        for s in shadow: s.set('opacity', '.42')
        for s in shadow: root.append(s)
        for col, ex in ((HALO, 3.2 * u * ok), (UMBER, 1.9 * u * ok)):
            g = ET.SubElement(root, q('g'), {'fill': col, 'stroke': col, 'stroke-linejoin': 'round', 'stroke-linecap': 'round'})
            for e in silhouette(kids, col, ex): g.append(e)
            tidy(g); hoist(g)
        if SWARM:   # i10: hairline widths snap to 1 / 1.5 so same-colour limbs bucket-merge
            for k in kids:
                for e in k.iter():
                    if e.tag == q('path') and e.get('fill') == 'none' and e.get('stroke') and num(e.get('stroke-width'), 9) <= 1.7: e.set('stroke-width', '1' if num(e.get('stroke-width')) < 1.3 else '1.5')
        fk = ET.Element(q('g')); eyes = ET.Element(q('g')); EYE_RM = set()
        if CHARMODE: EYE_RM = eye_pass([k for k in kids if k not in shadow], eyes, npc)
        MASKG = None
        def is_crack(e): return e.tag == q('path') and (e.get('stroke') or '').lower() == UMBER and (e.get('fill') or 'none') == 'none' and not e.get('transform') and e.get('opacity') is None
        if name.startswith('broken-'):   # i13: cracks are masked by the body INCLUDING stroked shafts (a clipPath ignores strokes -> cracks vanished on thin handles); mask built from the body without the cracks
            holes = []
            for k in kids:
                for par in k.iter():
                    for c in list(par):
                        if is_crack(c): holes.append((par, c, list(par).index(c)))
            body = [k for k in kids if not is_crack(k)]
            for par, c, i in holes: par.remove(c)
            MASKG = ET.Element(q('g'), {'fill': '#fff', 'stroke': '#fff', 'stroke-linejoin': 'round', 'stroke-linecap': 'round'})
            for e in silhouette(body, '#fff', 0.0): MASKG.append(e)
            for par, c, i in reversed(holes): par.insert(i, c)
        for k in kids:
            if k not in shadow and id(k) not in EYE_RM:
                if not nav and not HEDGE: inner(k, u)
                if MASKG is not None:
                    for e in ([k] if k.tag != q('g') else list(k.iter())):
                        if is_crack(e): e.set('mask', 'url(#%s-m)' % cid); e.set('stroke-width', fmt(max(num(e.get('stroke-width')), 2.6 * u)))
                fk.append(k)
        cnt = {}
        for e in fk:
            if e.tag == q('circle') and not e.get('stroke') and not e.get('transform') and e.get('fill') not in (None, 'none'): kk = (e.get('fill'), e.get('r'), e.get('opacity')); cnt[kk] = cnt.get(kk, 0) + 1
        for e in list(fk):   # i10: >=3 same-style filled circles -> round-cap dots (50 bytes -> 12 each once merged)
            kk = (e.get('fill'), e.get('r'), e.get('opacity'))
            if e.tag == q('circle') and cnt.get(kk, 0) >= 3 and not e.get('stroke') and not e.get('transform'):
                a2 = {'d': 'M%s %sh0' % (e.get('cx'), e.get('cy')), 'stroke': e.get('fill'), 'stroke-width': fmt(2 * num(e.get('r'))), 'stroke-linecap': 'round'}
                if e.get('opacity'): a2['opacity'] = e.get('opacity')
                n2 = ET.Element(q('path'), a2); fk.insert(list(fk).index(e), n2); fk.remove(e)
        merge_shapes(fk, not SWARM, fmt)   # i10 swarm: bucket-merge same-style leaves across individuals
        for k in list(fk): root.append(k)
        defs = ET.SubElement(root, q('defs'))
        cp = ET.SubElement(defs, q('clipPath'), {'id': cid})
        for e in silhouette(kids, '#000', 0.0): cp.append(e)
        if MASKG is not None:
            mk = ET.SubElement(defs, q('mask'), {'id': cid + '-m', 'maskUnits': 'userSpaceOnUse', 'x': fmt(vb[0]), 'y': fmt(vb[1]), 'width': fmt(W), 'height': fmt(H)}); mk.append(MASKG)
        # clipPath children cannot be <g>; flatten groups by moving transform down
        flat = []
        def fl(el, tr):
            if el.tag == q('g'):
                t2 = (tr + ' ' + (el.get('transform') or '')).strip()
                if CHARMODE and 'rotate' not in t2 and t2:
                    a, b, c0, d0 = _tf(t2); t2 = 'translate(%s %s)%s' % (fmt(c0), fmt(d0), '' if abs(a - 1) < 1e-6 else ' scale(%s)' % fmt(a))
                    if abs(a - 1) < 1e-6 and not c0 and not d0: t2 = ''
                for c in el: fl(c, t2)
            else:
                if tr: el.set('transform', (tr + ' ' + (el.get('transform') or '')).strip())
                for a in ('stroke-linejoin', 'stroke-linecap'): el.attrib.pop(a, None)
                if el.get('fill') == 'none': return  # strokes don't clip
                el.attrib.pop('stroke', None); el.attrib.pop('stroke-width', None)
                flat.append(el)
        for c in list(cp): cp.remove(c); fl(c, '')
        for e in flat: cp.append(e)
        tidy(cp)
        shp = [k for k in kids if k not in shadow]
        bb = sil_bbox(shp)
        sc = shade_color(kids)
        if name.startswith(CHARS): sc = '#3a1c10'
        if name.startswith('stage-'): sc = TINT['w']   # i8: same shade tone every step so the mound never changes
        if name.startswith('stage-'): bb = (8, 4, 56, 60)   # i8: constant frame for every growth step
        if bb and HEDGE:
            ET.SubElement(root, q('path'), {'d': (FENCE_SH if FENCE else HEDGE_SH)[name.rsplit('-', 1)[1]], 'fill': sc, 'opacity': SHADE_OP, 'clip-path': 'url(#%s)' % cid})
        elif bb and bb[2] - bb[0] > 4 and bb[3] - bb[1] > 4:
            bw, bh = bb[2] - bb[0], bb[3] - bb[1]
            R = lambda d: ' '.join(d.split())
            full = 'M%s %sh%sv%sh-%sz' % (f1(bb[0] - 4), f1(bb[1] - 4), f1(bw + 8), f1(bh + 8), f1(bw + 8))
            sh = full + arcs(bb[0] + .40 * bw, bb[1] + .36 * bh, .52 * bw, .52 * bh)[0:]
            rm = full + arcs(bb[0] + .56 * bw, bb[1] + .57 * bh, .68 * bw, .68 * bh)
            if not npc and not LEAN and not nav and not TRIM and not name.startswith('stage-'): ET.SubElement(root, q('path'), {'d': rm, 'fill': RIMTONE, 'opacity': '.26', 'fill-rule': 'evenodd', 'clip-path': 'url(#%s)' % cid})
            ET.SubElement(root, q('path'), {'d': sh, 'fill': sc, 'opacity': SHADE_OP, 'fill-rule': 'evenodd', 'clip-path': 'url(#%s)' % cid})
            if not npc and not LEAN and not nav and not TRIM and not name.startswith('stage-') and bh > 16 and bw > 16 and not re.search(r'bee|hoe|trowel|spade|rake|wand|staff|stick', name):   # i4: base AO band hugging the bottom of the silhouette
                ET.SubElement(root, q('ellipse'), {'cx': fmt(bb[0] + .5 * bw), 'cy': fmt(bb[3]), 'rx': fmt(.62 * bw), 'ry': fmt(.2 * bh), 'fill': sc, 'opacity': '.22', 'clip-path': 'url(#%s)' % cid})
            if not nav: mat_marks(shp, u, cid, root, npc, name.startswith(CHARS))
            for pth in eyes: root.append(pth)
            if not npc and not nav and not FIXED and not TRIM and bw >= 22 and bh >= 22 and not name.startswith(CHARS):   # i4: one small top-left specular glint, clipped to the silhouette
                best, ba = bb, 0
                for k in shp:
                    for e in (k.iter() if k.tag == q('g') else [k]):
                        if e.tag == q('g') or skip(e) or e.get('fill') in (None, 'none') or e.get('transform') or k.get('transform'): continue
                        b2 = sil_bbox([e])
                        if b2 and (b2[2] - b2[0]) * (b2[3] - b2[1]) > ba: best, ba = b2, (b2[2] - b2[0]) * (b2[3] - b2[1])
                bw2, bh2 = best[2] - best[0], best[3] - best[1]
                gx, gy, gr = best[0] + .3 * bw2, best[1] + .28 * bh2, max(1.5, .07 * min(bw2, bh2))
                ET.SubElement(root, q('ellipse'), {'cx': fmt(gx), 'cy': fmt(gy), 'rx': fmt(gr * 1.6), 'ry': fmt(gr), 'fill': '#fffaf0', 'opacity': '.8', 'transform': 'rotate(-38 %s %s)' % (fmt(gx), fmt(gy)), 'clip-path': 'url(#%s)' % cid})
        else:
            ET.SubElement(root, q('path'), {'d': cres, 'fill': sc, 'opacity': SHADE_OP, 'fill-rule': 'evenodd', 'clip-path': 'url(#%s)' % cid})
    if not (name.startswith('tile-') or scene):
        for s in shadow:   # i4: warm lighter ground shadow + cream edge ring so it reads on dark too
            s.set('fill', '#6a4528'); s.set('opacity', '.5')
            if not nav and not HEDGE: s.set('stroke', HALO); s.set('stroke-opacity', '.3'); s.set('stroke-width', '1')
    out = ET.tostring(root, encoding='unicode')
    out = out.replace(' />', '/>').replace('ns0:', '')
    out = re.sub(r'(<path d="(?:M[-.\d]+[ -][-.\d]+[vhVHlL][-.\d]+)+"[^>]*?) stroke-linejoin="round"', r'\1', out)
    out = re.sub(r' d="([^"]*)"', lambda m: ' d="%s"' % re.sub(r'(?<![\d.])0\.(\d)', r'.\1', re.sub(r' -', '-', m.group(1))), out)
    if name.startswith(CHARS): out = compact_tf(out)
    return out
