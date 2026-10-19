#!/usr/bin/env python3
"""Gnome Venture placeholder art generator (deterministic). Writes SVGs into game/assets/img/ph/.
Run: python3 tests/gen_ph_world.py   (palette: assets/img/ph/palette.json)"""
import math, os, random

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'game', 'assets', 'img', 'ph')
S9, S7, S5, S3, S1 = '#3d2a1c', '#7a4a1f', '#9a6b3f', '#c9a96e', '#f1ece0'
M8, M6, M4, M2 = '#2f5a2a', '#4f9a45', '#7ab55c', '#a4b86a'
G7, G5, G3 = '#b07a10', '#e8a317', '#f5cf6a'
E7, E5, E4, E3 = '#a8241f', '#d6322b', '#e0501f', '#f08a24'
PT5, PT3 = '#e46a9b', '#f6b8cf'
W7, W5, W3 = '#25637d', '#3f8fb0', '#a9d6ea'
D7, D5, D3 = '#4e3a8a', '#7a5cc0', '#c3b2ea'
T7, T5, T3 = '#5b6470', '#8b8f96', '#c9c5bc'
INK, CR = '#2b2b2b', '#f4f0e0'
FILES = {}


def f(v):
    s = ('%.1f' % v).rstrip('0').rstrip('.')
    return '0' if s in ('-0', '') else s


def border(w, h):
    return ''   # v1.6.8: no red outline (Joshua)


def put(name, body, label, w=64, h=64):
    FILES[name + '.svg'] = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" role="img" aria-label="%s">%s%s</svg>'
                            % (w, h, label, body, border(w, h)))


def sh(cx, cy, rx, ry):
    return '<ellipse cx="%s" cy="%s" rx="%s" ry="%s" fill="#000" opacity=".15"/>' % (f(cx), f(cy), f(rx), f(ry))


def hl(x, y, w, h, r=1.5):
    return '<rect x="%s" y="%s" width="%s" height="%s" rx="%s" fill="#fff" opacity=".4"/>' % (f(x), f(y), f(w), f(h), f(r))


def rect(x, y, w, h, fill, r=0, extra=''):
    return '<rect x="%s" y="%s" width="%s" height="%s"%s fill="%s"%s/>' % (f(x), f(y), f(w), f(h), (' rx="%s"' % f(r)) if r else '', fill, extra)


def circ(x, y, r, fill, op=None):
    return '<circle cx="%s" cy="%s" r="%s" fill="%s"%s/>' % (f(x), f(y), f(r), fill, (' opacity="%s"' % op) if op else '')


def ell(x, y, rx, ry, fill, op=None, extra=''):
    return '<ellipse cx="%s" cy="%s" rx="%s" ry="%s" fill="%s"%s%s/>' % (f(x), f(y), f(rx), f(ry), fill, (' opacity="%s"' % op) if op else '', extra)


def path(d, fill='none', stroke=None, sw=None, op=None, extra=''):
    s = '<path d="%s" fill="%s"' % (d, fill)
    if stroke:
        s += ' stroke="%s" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round"' % (stroke, f(sw or 1.5))
    if op:
        s += ' opacity="%s"' % op
    return s + extra + '/>'


# ---------------- buildings ----------------
def lamp(x, y):
    return (circ(x, y + 1, 7, G3, .3) + path('M%s %sv3' % (f(x), f(y - 5)), stroke=INK, sw=1)
            + rect(x - 2.5, y - 2, 5, 6.5, G5, 2) + rect(x - 1.2, y - 1, 1.2, 3, '#fff', 0, ' opacity=".5"'))


def flag(x, y, h=11):
    return (path('M%s %sV%s' % (f(x), f(y), f(y - h)), stroke=S9, sw=1.6)
            + path('M%s %sl9 3-9 3z' % (f(x), f(y - h)), E5))


def star(x, y, r=3.2):
    pts = []
    for i in range(8):
        a = i * math.pi / 4
        rr = r if i % 2 == 0 else r * .4
        pts.append('%s %s' % (f(x + math.sin(a) * rr), f(y - math.cos(a) * rr)))
    return path('M' + 'L'.join(pts) + 'z', G3)


def moss(bb):
    x0, y0, x1, y1 = bb
    w = x1 - x0
    s = ''
    for i, (fx, fy, r) in enumerate([(.15, 0.08, 6), (.5, 0.02, 5), (.8, 0.12, 6), (.25, .95, 7), (.7, .97, 8)]):
        s += ell(x0 + fx * w, y0 + fy * (y1 - y0), r, r * .55, M6 if i % 2 else M4, .92)
    s += path('M%s %sq-3 7 0 14M%s %sq3 6 0 12' % (f(x0 + 4), f(y1 - 14), f(x1 - 5), f(y1 - 12)), stroke=M6, sw=2)
    return s


def b_kitchen(l, a, b):
    s = sh(32, 58, 27, 4)
    s += rect(41, 11, 7, 15, T5) + rect(39.5, 9.5, 10, 3.5, T7, 1) + circ(46, 6, 3, T3, .7)
    s += rect(9, 31, 46, 25, a, 2) + path('M9 40h46M9 48h46', stroke=S5, sw=.8, op=.5)
    s += path('M4 34L32 14l28 20z', b) + path('M11 31L32 17', stroke='#fff', sw=2, op=.4)
    s += rect(4, 33, 56, 3, E7, 1.5)
    s += path('M15 56V45a5 5 0 0 1 10 0v11z', S9) + circ(23, 51, 1, G5)
    s += rect(34, 39, 12, 9, G3, 2) + path('M40 39v9M34 43.5h12', stroke=S7, sw=1.2)
    if l >= 2:
        s += rect(33, 47.5, 14, 3.5, S7, 1) + circ(36, 46.5, 1.5, PT5) + circ(40, 46.5, 1.5, G5) + circ(44, 46.5, 1.5, PT3)
    return s, (4, 14, 60, 56), (32, 14)


def b_rain_barrel(l, a, b):
    s = sh(32, 58, 22, 4)
    s += rect(7, 6, 5, 16, T5, 2) + rect(7, 19, 14, 4.5, T5, 2) + circ(9.5, 27, 1.7, W3)
    s += rect(14, 21, 36, 35, a, 8)
    s += path('M23 22v33M32 22v33M41 22v33', stroke=S7, sw=1, op=.5)
    s += rect(14, 28, 36, 4.5, b, 2) + rect(14, 46, 36, 4.5, b, 2)
    s += ell(32, 21, 18, 5.5, S7) + ell(32, 21.5, 15.5, 4, W5) + path('M26 21.5q3-2 6 0t6 0', stroke=W3, sw=1)
    s += hl(17, 34, 3, 10, 1.5) + rect(29, 49, 6, 3, T7, 1) + circ(32, 55, 1.4, W3)
    return s, (14, 17, 50, 56), (47, 24)


def b_tool_shed(l, a, b):
    s = sh(32, 58, 28, 4)
    s += rect(7, 30, 50, 26, a, 2) + path('M7 38h50M7 47h50', stroke=S7, sw=.8, op=.6)
    s += path('M2 33L11 17h42l9 16z', b) + path('M13 30L19 20', stroke='#fff', sw=2, op=.4)
    s += rect(2, 32, 60, 3.5, T7, 1.5)
    s += rect(23, 38, 18, 18, S7, 1) + path('M23 38l18 18M41 38L23 56M32 38v18', stroke=S9, sw=1.3)
    s += path('M50 56l4-22', stroke=S5, sw=2) + path('M51 36l5-1.5-1.5 6z', T5)
    s += path('M12 56l-2-20', stroke=S5, sw=2) + path('M7 33h6l-1 5H8z', T5)
    return s, (2, 17, 62, 56), (32, 17)


def b_compost(l, a, b):
    s = sh(32, 58, 24, 4)
    s += path('M12 33Q16 9 32 9t20 24z', S9) + path('M17 28Q22 14 30 13', stroke='#fff', sw=2, op=.4)
    s += circ(24, 20, 2.2, M6) + circ(38, 17, 2.2, E4) + circ(33, 25, 2, G5) + path('M42 24l4-3 1 4z', M4)
    s += rect(10, 30, 44, 26, a, 2)
    s += rect(10, 34, 44, 4, S7, 1) + rect(10, 43, 44, 4, S7, 1) + rect(10, 51, 44, 4, S7, 1)
    s += rect(8, 28, 5, 28, b, 1.5) + rect(51, 28, 5, 28, b, 1.5)
    return s, (8, 9, 56, 56), (53, 28)


def b_beehive(l, a, b):
    s = sh(32, 58, 22, 3.5)
    s += rect(14, 49, 36, 7, S5, 2) + rect(17, 54, 5, 4, S7) + rect(42, 54, 5, 4, S7)
    s += rect(14, 38, 36, 12, a, 6) + rect(18, 28, 28, 12, a, 6) + rect(22, 19, 20, 11, a, 5.5)
    s += ell(32, 18, 8.5, 6, a) + rect(30, 9.5, 4, 4, G7, 2)
    s += path('M14 44h36M18 34h28M22 25h20', stroke=G7, sw=1.2)
    s += path('M27 49v-4a5 4 0 0 1 10 0v4z', S9) + hl(19, 41, 2.4, 6) + hl(24, 21, 2, 5)
    s += circ(15, 28, 2.2, b) + circ(15, 28, 1, INK) + circ(52, 37, 2.2, b) + circ(52, 37, 1, INK)
    return s, (14, 9, 50, 56), (48, 40)


def b_greenhouse(l, a, b):
    s = sh(32, 58, 28, 4)
    s += path('M6 54V38L14 20h36l8 18v16z', W3, op=.7)
    s += rect(6, 48, 52, 8, T5, 2)
    s += path('M10 46q4-8 9-4 4-9 9-1 5-7 9 1 6-4 10 4z', M6) + circ(20, 45, 2, E5) + circ(40, 44, 2, E5)
    s += path('M6 38h52M14 20L10 54M50 20l4 34M32 20v34M22 20v34M42 20v34', stroke=CR, sw=1.3)
    s += path('M6 54V38L14 20h36l8 18v16', stroke=CR, sw=2.2)
    s += path('M12 36l7-12M10 46l4-8', stroke='#fff', sw=2, op=.5)
    return s, (6, 20, 58, 56), (32, 20)


def b_root_cellar(l, a, b):
    s = sh(32, 58, 29, 4)
    s += path('M3 56Q3 20 32 20t29 36z', a) + path('M12 32Q18 24 28 23', stroke='#fff', sw=2.2, op=.4)
    s += path('M12 25l-2-4M53 28l3-4M7 40l-4-2', stroke=M8, sw=1.5)
    s += path('M17 56V43a15 12 0 0 1 30 0v13z', T5) + path('M21 56V44a11 9 0 0 1 22 0v12z', b)
    s += path('M32 35v21M26 39v17M38 39v17', stroke=S9, sw=1) + circ(40, 49, 1.4, G5)
    return s, (3, 20, 61, 56), (32, 23)


BUILD = {'kitchen': (b_kitchen, S3, E5), 'rain_barrel': (b_rain_barrel, S5, T7), 'tool_shed': (b_tool_shed, S5, T5),
         'compost_bin': (b_compost, S5, S7), 'beehive': (b_beehive, G5, E3), 'greenhouse': (b_greenhouse, 0, 0),
         'root_cellar': (b_root_cellar, M6, S5)}
SKINS = {'kitchen': ['mossy', 'painted', 'lantern'], 'rain_barrel': ['mossy', 'painted'], 'tool_shed': ['mossy', 'painted', 'lantern'],
         'compost_bin': ['mossy', 'painted'], 'beehive': ['painted', 'lantern'], 'greenhouse': ['mossy', 'painted', 'lantern'],
         'root_cellar': ['mossy', 'lantern']}
PAINT = {'kitchen': (PT3, W5), 'rain_barrel': (W5, PT5), 'tool_shed': (W3, PT5), 'compost_bin': (PT5, G5), 'beehive': (PT3, W5)}
NAMES = {'kitchen': 'Kitchen', 'rain_barrel': 'Rain barrel', 'tool_shed': 'Tool shed', 'compost_bin': 'Compost bin', 'beehive': 'Beehive',
         'greenhouse': 'Greenhouse', 'root_cellar': 'Root cellar'}


def building(bk, l, skin=None):
    fn, a, b = BUILD[bk]
    if skin == 'painted' and bk in PAINT:
        a, b = PAINT[bk]
    body, bb, fl = fn(l, a, b)
    if skin == 'painted' and bk == 'greenhouse':
        body = body.replace(CR, PT5)
    if skin == 'mossy':
        body += moss(bb)
    if skin == 'lantern':
        body += lamp(bb[0] + 5, bb[3] - 24) + lamp(bb[2] - 5, bb[3] - 24)
    if l >= 2:
        body += flag(fl[0], fl[1])
        body += path('M%s %sh%s' % (f(bb[0] + 3), f(bb[3] - 1), f(bb[2] - bb[0] - 6)), stroke=G5, sw=1.8)
    if l >= 3:
        body += lamp(bb[0] + 6, bb[3] - 22) + star(bb[2] - 6, bb[1] + 6)
    nm = NAMES[bk] + (' level %d' % l if not skin else ' (%s)' % skin)
    return body, nm


# ---------------- fences / walls / hedges ----------------
MASK = {'end': 2, 'straight': 10, 'corner': 6, 'tee': 14, 'cross': 15}
FENCES = {'picket-fence': 'picket', 'garden-gate': 'picket', 'wattle-fence': 'wattle', 'stone-wall': 'wall',
          'box-hedge': 'box', 'holly-hedge': 'holly', 'lavender-border': 'lav'}
FNAME = {'picket-fence': 'Picket fence', 'garden-gate': 'Garden gate', 'wattle-fence': 'Wattle fence', 'stone-wall': 'Dry stone wall',
         'box-hedge': 'Box hedge', 'holly-hedge': 'Holly hedge', 'lavender-border': 'Lavender border'}


def seg(sty, x, y, w, h, horiz):
    s = ''
    L = w if horiz else h
    n = max(1, int(L // 6))
    if sty == 'picket':
        if horiz:
            s += rect(x, 29, w, 2.4, T5) + rect(x, 35.5, w, 2.4, T5)
            for i in range(n):
                s += rect(x + 1 + i * 6, 25, 4, 15, CR, 1.5)
        else:
            s += rect(29, y, 2.4, h, T5) + rect(35.5, y, 2.4, h, T5)
            for i in range(n):
                s += rect(25, y + 1 + i * 6, 15, 4, CR, 1.5)
    elif sty == 'wattle':
        s += rect(x, y, w, h, S5, 2)
        for i in range(n):
            o = i * 6
            s += path(('M%s %sl4 %s' % (f(x + o + 1), f(y + 1), f(h - 2))) if horiz else ('M%s %sl%s 4' % (f(x + 1), f(y + o + 1), f(w - 2))),
                      stroke=S3 if i % 2 else S7, sw=1.8)
        s += path(('M%s 33.5h%s' % (f(x), f(w))) if horiz else ('M33.5 %sv%s' % (f(y), f(h))), stroke=S9, sw=.8, op=.5)
    elif sty == 'wall':
        for i in range(n + 1):
            o = i * 7
            if horiz:
                s += rect(x + o, y, 7.4, h, T5 if i % 2 else T3, 3)
            else:
                s += rect(x, y + o, w, 7.4, T5 if i % 2 else T3, 3)
    else:
        col = {'box': M6, 'holly': M8, 'lav': M6}[sty]
        for i in range(n + 1):
            o = i * 6
            cx, cy = (x + o, 32) if horiz else (32, y + o)
            s += circ(cx, cy, 8 if sty != 'lav' else 6.5, col)
            if sty == 'holly' and i % 2 == 0:
                s += circ(cx + 2, cy - 2, 1.4, E5) + circ(cx - 2, cy + 3, 1.4, E5)
            if sty == 'lav':
                s += circ(cx - 1, cy - 2, 2.6, D5) + circ(cx + 2, cy + 2, 2.2, D3)
    return s


def hub(sty):
    if sty == 'picket':
        return rect(26.5, 26.5, 11, 11, T3, 2.5) + rect(28, 28, 8, 8, CR, 2) + hl(29, 29, 3, 3, 1)
    if sty == 'wattle':
        return circ(32, 32, 5, S9) + circ(31, 31, 2, S5)
    if sty == 'wall':
        return rect(25, 25, 14, 14, T7, 4) + rect(27, 27, 10, 10, T5, 3) + hl(28, 28, 4, 3, 1)
    col = {'box': M6, 'holly': M8, 'lav': M6}[sty]
    s = circ(32, 32, 9 if sty != 'lav' else 7.5, col)
    if sty == 'holly':
        s += circ(30, 30, 1.5, E5) + circ(35, 34, 1.5, E5)
    if sty == 'lav':
        return s + circ(31, 30, 2.8, D5) + circ(34, 34, 2.4, D3)
    return s + circ(29, 28, 2.5, '#fff', .4)


def arm_rects(sty, d):
    t = {'picket': 15, 'wattle': 9, 'wall': 13, 'box': 16, 'holly': 16, 'lav': 13}[sty]
    o = t / 2.0
    return {'N': (32 - o, 0, t, 32, False), 'S': (32 - o, 32, t, 32, False), 'E': (32, 32 - o, 32, t, True), 'W': (0, 32 - o, 32, t, True)}[d]


def fence_piece(item, shape):
    sty = FENCES[item]
    if shape == 'gate':
        s = sh(32, 40, 28, 5)
        for px in (10, 54):
            if sty == 'wall':
                s += rect(px - 5, 24, 10, 16, T7, 3) + rect(px - 3.5, 25.5, 7, 12, T5, 2)
            elif sty in ('box', 'holly', 'lav'):
                s += circ(px, 32, 8, M6 if sty != 'holly' else M8)
            else:
                s += rect(px - 4, 25, 8, 14, S7, 2) + rect(px - 3, 26, 6, 3, S3, 1)
        s += rect(15, 28, 34, 3, S5, 1) + rect(15, 36, 34, 3, S5, 1)
        for i in range(6):
            s += rect(16 + i * 5.6, 25, 3.6, 17, CR if sty == 'picket' else S3, 1.5)
        s += path('M16 38L48 28', stroke=S7, sw=1.6) + circ(46, 33, 1.6, G5)
        return s, FNAME[item] + ' gate'
    sg = ''
    for d, bit in zip('NESW', (1, 2, 4, 8)):
        if MASK[shape] & bit:
            x, y, w, h, hz = arm_rects(sty, d)
            sg += seg(sty, x, y, w, h, hz)
    sd = sh(32, 38, 30, 6) if shape in ('straight', 'end') else sh(32, 40, 26, 22) if shape == 'cross' else sh(33, 38, 28, 10)
    return sd + sg + hub(sty), FNAME[item] + ' ' + shape


# ---------------- tiles ----------------
def tile(name):
    r = random.Random(name)
    s = ''
    if name in ('wild', 'grass'):
        s = rect(0, 0, 64, 64, M4 if name == 'grass' else M2)
        for i in range(14 if name == 'wild' else 8):
            x, y = r.randint(4, 58), r.randint(6, 58)
            s += path('M%d %dl-2-5M%d %dl0-6M%d %dl2-5' % (x, y, x, y, x, y), stroke=M6 if name == 'grass' else M4, sw=1.6)
        if name == 'wild':
            for i in range(4):
                s += circ(r.randint(6, 58), r.randint(6, 58), 2, [PT3, G3, CR, D3][i])
        else:
            s += circ(46, 18, 14, '#fff', .12)
    elif name in ('tilled', 'tilled-wet'):
        s = rect(0, 0, 64, 64, S7 if name == 'tilled' else S9)
        for i in range(4):
            s += rect(0, 6 + i * 15, 64, 7, S9 if name == 'tilled' else S9) + rect(0, 13 + i * 15, 64, 3, S5 if name == 'tilled' else S7, 0, ' opacity=".6"')
        for i in range(6):
            s += circ(r.randint(4, 60), r.randint(4, 60), 1.3, S3)
        if name == 'tilled-wet':
            for i in range(5):
                s += ell(r.randint(8, 56), r.randint(8, 56), 2, 2.8, W3, .8)
    elif name == 'notill':
        s = rect(0, 0, 64, 64, S9)
        for i in range(10):
            x, y = r.randint(2, 50), r.randint(4, 58)
            s += path('M%d %dl%d %d' % (x, y, r.randint(8, 13), r.randint(-3, 3)), stroke=G5 if i % 2 else G3, sw=1.8)
        for i in range(6):
            s += circ(r.randint(4, 60), r.randint(4, 60), 1.8, M6)
    elif name == 'stone-path':
        s = rect(0, 0, 64, 64, T7)
        for (x, y, w, h) in [(3, 3, 26, 17), (32, 3, 29, 22), (3, 23, 20, 20), (26, 28, 21, 15), (50, 28, 11, 16), (3, 46, 30, 15), (36, 46, 25, 15)]:
            s += rect(x, y, w, h, T3 if (x + y) % 2 else T5, 4)
        s += hl(6, 6, 12, 3, 1.5)
    elif name == 'bark-path':
        s = rect(0, 0, 64, 64, S5)
        for i in range(22):
            x, y = r.randint(1, 54), r.randint(1, 58)
            s += rect(x, y, r.randint(7, 12), r.randint(4, 6), [S7, S3, S9, S5][i % 4], 2.5, ' transform="rotate(%d %d %d)"' % (r.randint(-40, 40), x, y))
    elif name == 'gravel-path':
        s = rect(0, 0, 64, 64, T3)
        for i in range(70):
            s += circ(r.randint(2, 62), r.randint(2, 62), r.choice([1.2, 1.6, 2]), [T5, T7, CR, S3][i % 4])
    elif name == 'brick-path':
        s = rect(0, 0, 64, 64, CR)
        for row in range(6):
            for col in range(-1, 4):
                s += rect(col * 18 + (9 if row % 2 else 0) + 1, row * 11 + 1, 16, 9, E7 if (row + col) % 3 else E5, 1.5)
        s += hl(3, 3, 10, 2.4, 1)
    elif name == 'stepping-stones':
        s = rect(0, 0, 64, 64, M4)
        for i in range(8):
            s += path('M%d %dl-2-5' % (r.randint(4, 60), r.randint(8, 60)), stroke=M6, sw=1.6)
        for (x, y, rx, ry) in [(20, 18, 13, 10), (44, 44, 13, 10)]:
            s += ell(x + 1.5, y + 3, rx, ry, '#000', .15) + ell(x, y, rx, ry, T5) + ell(x - 2, y - 2, rx - 4, ry - 4, T3) + hl(x - 8, y - 6, 6, 2.4, 1.2)
    return s, 'Tile ' + name


TILES = ['wild', 'grass', 'tilled', 'tilled-wet', 'notill', 'stone-path', 'bark-path', 'gravel-path', 'brick-path', 'stepping-stones']


# ---------------- crop stages ----------------
def leaf(x, y, dx, dy, c=M6):
    mx, my = x + dx / 2.0, y + dy / 2.0
    px, py = -dy * .38, dx * .38
    return path('M%s %sQ%s %s %s %sQ%s %s %s %sz' % (f(x), f(y), f(mx + px), f(my + py), f(x + dx), f(y + dy), f(mx - px), f(my - py), f(x), f(y)), c)


def stage(kind, st):
    s = sh(32, 57, 20, 3.5) + ell(32, 52, 21, 8, S7) + ell(32, 50, 17, 5, S5) + ell(24, 49, 8, 2, '#fff', .3)
    h = [6, 14, 24, 32][st - 1]
    if kind in ('tree', 'nut'):
        tw = [1.5, 2.5, 4, 5.5][st - 1]
        s += rect(32 - tw / 2, 50 - h * 1.1, tw, h * 1.1, S5, 1)
        if st == 1:
            s += leaf(32, 46, -10, -9) + leaf(32, 46, 10, -10, M4)
        else:
            cr = [0, 8, 13, 17][st - 1]
            cy = 48 - h * 1.1
            s += circ(32, cy, cr, M6) + circ(32 - cr * .55, cy + cr * .35, cr * .65, M8 if st > 2 else M6) + circ(32 + cr * .55, cy + cr * .3, cr * .65, M4) + circ(32 - cr * .3, cy - cr * .35, cr * .3, '#fff', .35)
            if st == 4:
                col = G5 if kind == 'tree' else S5
                for dx, dy in [(-9, 3), (7, -3), (1, 8), (-3, -8), (11, 7)]:
                    s += circ(32 + dx, cy + dy, 2.6, col)
        return s
    if kind == 'grain':
        n = [1, 3, 5, 6][st - 1]
        for i in range(n):
            x = 32 + (i - (n - 1) / 2.0) * (14 / max(1, n - 1) if n > 1 else 0)
            top = 49 - h
            tx = x + (i - n / 2.0) * 1.6
            s += path('M%s 50Q%s %s %s %s' % (f(x), f(x + (i - n / 2.0)), f(top + 12), f(tx), f(top)), stroke=M6 if st < 4 else G5, sw=2.2)
            if st == 4:
                s += ell(tx, top - 1, 2.2, 5, G5) + path('M%s %sl0-4' % (f(tx), f(top - 6)), stroke=G7, sw=1)
            elif st == 3:
                s += ell(tx, top, 1.6, 3.5, M4)
        return s
    if kind == 'legume':
        s += path('M44 52V%s' % f(50 - h * 1.15), stroke=S5, sw=2)
        if st > 1:
            s += path('M32 50Q%s 36 44 %s' % (f(36 + st), f(50 - h)), stroke=M6, sw=2)
        for i in range(st):
            s += leaf(33 + i * 3, 49 - i * 6, (-8 if i % 2 else 8), -5, M6 if i % 2 else M4)
        if st == 4:
            for dx, dy in [(-4, 0), (3, 6), (-2, -9)]:
                s += rect(40 + dx, 38 + dy, 3.5, 10, M4, 1.8) + rect(40.6 + dx, 39 + dy, 1, 6, '#fff', .5, ' opacity=".5"')
        return s
    if kind == 'tuber':
        for i in range(st):
            s += leaf(32 + (i - st / 2.0) * 5, 49, (i - st / 2.0) * 7 - 3, -max(11, h * .55), M6 if i % 2 else M4)
        if st == 4:
            s += ell(23, 53, 6, 4, S3) + ell(41, 54, 6, 4, S3) + ell(32, 55.5, 5, 3.4, S5) + hl(19, 51, 4, 1.4, .7)
        return s
    if kind in ('fruit', 'vegetable', 'spice'):
        for i in range(st + 1):
            a = -1 + i * (2.0 / st)
            s += leaf(32, 49, a * 11, -max(11, h * .6), M6 if i % 2 else M4)
        if st >= 3:
            s += circ(32, 49 - h * .7, h * .22 + 4, M6) + circ(30, 49 - h * .7 - 2, 3, '#fff', .3)
        if st == 4:
            col = {'fruit': PT5, 'vegetable': E5, 'spice': E4}[kind]
            for dx, dy in [(-9, 2), (8, 0), (0, 8), (-3, -8)]:
                s += circ(32 + dx, 38 + dy, 3.8, col) + circ(31 + dx, 37 + dy, 1.2, '#fff', .5)
            if kind == 'spice':
                s += path('M40 30q6 2 6 8', stroke=E7, sw=2)
        return s
    if kind == 'herb':
        for i in range(st + 2):
            a = -1 + i * (2.0 / (st + 1))
            s += circ(32 + a * (5 + st * 2.4), 48 - abs(a) * -2 - h * .3, 3 + st * .8, M6 if i % 2 else M4)
        if st == 4:
            for dx, dy in [(-9, -6), (2, -10), (10, -2), (-3, -1)]:
                s += circ(32 + dx, 40 + dy, 2.4, D5) + circ(32 + dx, 40 + dy, 1, D3)
        return s
    for i in range(st + 2):
        x = 14 + i * (36 / (st + 1))
        s += circ(x, 47 - (i % 2) * 2, 4 + st * 1.1, M4 if i % 2 else M6)
    if st == 4:
        for x, y in [(20, 40), (32, 36), (44, 41), (27, 46)]:
            s += circ(x, y, 2.6, PT5) + circ(x, y, 1, G3)
    return s


KINDS = ['vegetable', 'tuber', 'legume', 'grain', 'fruit', 'tree', 'nut', 'herb', 'spice', 'cover']


# ---------------- scenery ----------------
def hills(w, y0, amp, col, ph, bottom, k=1.5, n=16):
    pts = ['%s %s' % (f(i * w / n), f(y0 + amp * math.sin(k * i / n * 6.283 + ph))) for i in range(n + 1)]
    return path('M0 %s L%s L%s %s z' % (f(bottom), 'L'.join(pts), f(w), f(bottom)), col)


def rtree(x, y, r, c, c2=None, trunk=S5):
    return (rect(x - r * .13, y - r * .2, r * .26, r * 1.1, trunk) + circ(x, y - r * .6, r, c) + circ(x - r * .35, y - r * .3, r * .6, c2 or c)
            + circ(x - r * .3, y - r * .95, r * .28, '#fff', .35))


def palm(x, y, hgt, lean=1):
    tx, ty = x + lean * hgt * .25, y - hgt
    s = path('M%s %sQ%s %s %s %s' % (f(x), f(y), f(x), f(y - hgt * .6), f(tx), f(ty)), stroke=S5, sw=hgt * .1 + 1)
    for dx, dy in [(-1, .1), (-.7, -.2), (.7, -.2), (1, .1), (0, -.3)]:
        s += path('M%s %sq%s %s %s %s' % (f(tx), f(ty), f(dx * hgt * .3), f(-hgt * .3 + dy * 10), f(dx * hgt * .6), f(dy * hgt * .5)), stroke=M6, sw=hgt * .09 + 1)
    return s + circ(tx, ty + 2, 1.7, S7)


def birch(x, y, hgt):
    s = rect(x - 1.5, y - hgt, 3, hgt, CR, 1)
    for i in range(3):
        s += rect(x - 1.5, y - hgt * (.2 + i * .25), 2, 1.2, INK)
    return s + ell(x, y - hgt - 2, 6, 7, M2) + ell(x - 2, y - hgt - 4, 2.6, 2.6, '#fff', .35)


def acacia(x, y, s_):
    return (rect(x - 1.2, y - 12 * s_, 2.4, 12 * s_, S9) + path('M%s %sl-5-6M%s %sl5-5' % (f(x), f(y - 8 * s_), f(x), f(y - 9 * s_)), stroke=S9, sw=1.4)
            + ell(x, y - 13 * s_, 12 * s_, 4 * s_, M8) + ell(x - 3, y - 14 * s_, 5 * s_, 1.6 * s_, '#fff', .3))


def mountain(x, y, w, h, c, cap=True):
    s = path('M%s %sL%s %sL%s %sz' % (f(x - w / 2), f(y), f(x), f(y - h), f(x + w / 2), f(y)), c)
    if cap:
        s += path('M%s %sL%s %sL%s %sl-3 3-3-2-3 3z' % (f(x - w * .17), f(y - h * .67), f(x), f(y - h), f(x + w * .17), f(y - h * .67)), CR)
    return s


def scene(code, w, h):
    u = h / 90.0
    X = lambda fr: fr * w
    Y = lambda fr: fr * h
    s = ''
    if code == 'NA':
        s += rect(0, 0, w, h, W3) + ell(X(.2), Y(.2), 14 * u, 4 * u, CR, .8) + ell(X(.7), Y(.14), 18 * u, 4.5 * u, CR, .8)
        s += hills(w, Y(.5), 5 * u, M6, 0, h) + hills(w, Y(.62), 5 * u, M4, 2, h) + hills(w, Y(.8), 3 * u, M2, 4, h)
        for i, fx in enumerate([.07, .22, .38, .55, .7, .86, .96]):
            r = (10 + (i * 5) % 6) * u
            s += rtree(X(fx), Y(.74 + (i % 3) * .06), r, [E4, G5, E3, E5, G5, E4, E3][i], [E5, E3, G5, E4, E3, G5, E4][i])
        for i in range(6):
            s += ell(X(.12 + i * .16), Y(.93), 3 * u, 1.2 * u, E4, .8)
    elif code == 'CA':
        s += rect(0, 0, w, h, G3) + circ(X(.78), Y(.25), 12 * u, E3) + circ(X(.78), Y(.25), 8 * u, G3, .6)
        s += hills(w, Y(.5), 4 * u, S3, 1, h) + hills(w, Y(.62), 3 * u, G5, 3, h)
        s += rect(0, Y(.72), w, h * .28, M2)
        for row, (yy, sc) in enumerate([(.8, .8), (.92, 1.1)]):
            n = 10 if row == 0 else 7
            for i in range(n):
                x = X((i + .5) / n)
                yb = Y(yy)
                s += path('M%s %sv%s' % (f(x), f(yb), f(-16 * u * sc)), stroke=M6, sw=2 * u * sc)
                s += path('M%s %sl-6-5M%s %sl6-5' % (f(x), f(yb - 6 * u * sc), f(x), f(yb - 9 * u * sc)), stroke=M4, sw=1.6 * u * sc)
                s += ell(x + 2.5 * u, yb - 10 * u * sc, 1.8 * u * sc, 4 * u * sc, G5)
    elif code == 'CB':
        s += rect(0, 0, w, h, W3) + circ(X(.85), Y(.2), 9 * u, G3) + ell(X(.3), Y(.18), 16 * u, 4 * u, CR, .8)
        s += rect(0, Y(.52), w, h, W5) + rect(0, Y(.52), w, 3 * u, W3, 0, ' opacity=".6"')
        s += ell(X(.5), Y(.74), 44 * u, 11 * u, G3) + ell(X(.5), Y(.72), 38 * u, 8 * u, M2)
        s += palm(X(.42), Y(.72), 36 * u, -1) + palm(X(.58), Y(.74), 30 * u, 1)
        for i in range(5):
            s += path('M%s %sq3-3 6 0t6 0' % (f(X(.04 + i * .22)), f(Y(.9 - (i % 2) * .05))), stroke=CR, sw=1.4 * u, op=.8)
    elif code == 'SA':
        s += rect(0, 0, w, h, M2) + rect(0, 0, w, Y(.5), M4)
        for i in range(7):
            x = X(i / 6.0)
            s += rect(x - 4 * u, 0, 8 * u, h, S7) + circ(x, Y(.15 + (i % 2) * .1), 17 * u, M8) + circ(x + 10 * u, Y(.3), 13 * u, M6)
        s += rect(0, Y(.72), w, h, M8)
        for i in range(8):
            s += ell(X(i / 7.0), Y(.78), 10 * u, 6 * u, M6) + ell(X(i / 7.0 + .05), Y(.9), 9 * u, 5 * u, M4)
        s += path('M%s 0q5 12 0 24M%s 0q-4 10 0 20' % (f(X(.3)), f(X(.62))), stroke=M2, sw=1.8 * u)
        s += ell(X(.45), Y(.5), 5 * u, 2.6 * u, E5) + ell(X(.45) + 4 * u, Y(.48), 3 * u, 2.4 * u, G5) + circ(X(.45) + 6 * u, Y(.47), .8 * u, INK)
    elif code == 'NWE':
        s += rect(0, 0, w, h, T3) + hills(w, Y(.45), 6 * u, T5, 0, h) + hills(w, Y(.58), 5 * u, D5, 2, h) + hills(w, Y(.75), 4 * u, M6, 4, h)
        s += ell(X(.5), Y(.55), w * .45, 9 * u, CR, .55)
        r = random.Random(7)
        for i in range(26):
            s += circ(r.uniform(0, w), r.uniform(Y(.62), Y(.74)), 2 * u, D3 if i % 2 else D7, .9)
        for i in range(7):
            s += rect(X(.55) + i * 8 * u, Y(.84) - (i % 2) * u, 8.4 * u, 7 * u, T7 if i % 2 else T5, 2)
        s += rect(X(.18), Y(.5), 6 * u, 24 * u, T7, 3 * u) + rect(X(.18) + 1 * u, Y(.5) + 2 * u, 2 * u, 18 * u, T5, u)
        s += ell(X(.3), Y(.7), w * .4, 6 * u, CR, .5)
    elif code == 'SE':
        s += rect(0, 0, w, h, W3) + circ(X(.2), Y(.22), 9 * u, G3) + rect(0, Y(.48), w, h, W5)
        s += rect(0, Y(.48), w, 2.5 * u, W3, 0, ' opacity=".7"')
        s += path('M%s %sL%s %sQ%s %s %s %sL%s %sz' % (f(X(.35)), f(h), f(X(.5)), f(Y(.55)), f(X(.7)), f(Y(.38)), f(w), f(Y(.4)), f(w), f(h)), S3)
        s += path('M%s %sQ%s %s %s %s' % (f(X(.5)), f(Y(.56)), f(X(.7)), f(Y(.4)), f(w), f(Y(.42))), stroke=M2, sw=3 * u)
        s += rect(X(.74), Y(.48), 18 * u, 13 * u, CR, 1) + path('M%s %sl10 -7 10 7z' % (f(X(.74) - 1 * u), f(Y(.48))), E5) + rect(X(.74) + 7 * u, Y(.48) + 5 * u, 4 * u, 8 * u, W5, 1)
        for fx, fy in [(.58, .72), (.82, .78), (.68, .88), (.92, .92)]:
            s += rect(X(fx) - 1 * u, Y(fy) - 3 * u, 2 * u, 7 * u, S7) + circ(X(fx), Y(fy) - 6 * u, 6.5 * u, T5) + circ(X(fx) - 2 * u, Y(fy) - 8 * u, 3 * u, M2)
        s += path('M0 %sq6-3 12 0t12 0t12 0t12 0' % f(Y(.9)), stroke=CR, sw=1.5 * u, op=.8)
    elif code == 'EE':
        s += rect(0, 0, w, h, W3) + hills(w, Y(.5), 4 * u, M4, 1, h) + rect(0, Y(.66), w, h, G3) + hills(w, Y(.7), 3 * u, M2, 3, h)
        s += ell(X(.25), Y(.16), 18 * u, 4 * u, CR, .8) + ell(X(.75), Y(.24), 14 * u, 3.5 * u, CR, .8)
        for i, fx in enumerate([.08, .2, .34, .5, .63, .78, .92]):
            s += birch(X(fx), Y(.78 + (i % 3) * .07), (30 - (i % 3) * 5) * u)
        for i in range(8):
            s += path('M%s %sl-2-5M%s %sl2-5' % (f(X(.05 + i * .13)), f(Y(.95)), f(X(.05 + i * .13)), f(Y(.95))), stroke=G7, sw=1.4 * u)
    elif code == 'MENA':
        s += rect(0, 0, w, h, CR) + rect(0, 0, w, Y(.35), G3, 0, ' opacity=".5"') + circ(X(.78), Y(.26), 13 * u, E3) + circ(X(.78), Y(.26), 9 * u, G3, .6)
        s += hills(w, Y(.55), 7 * u, G3, 0, h) + hills(w, Y(.7), 8 * u, G5, 2, h) + hills(w, Y(.88), 5 * u, G3, 4, h)
        s += ell(X(.25), Y(.82), 12 * u, 3 * u, W5) + palm(X(.2), Y(.82), 28 * u, 1) + palm(X(.3), Y(.83), 22 * u, -1)
        s += path('M%s %sL%s %sL%s %sz' % (f(X(.55)), f(Y(.58)), f(X(.62)), f(Y(.4)), f(X(.69)), f(Y(.58))), S3)
    elif code == 'WCA':
        s += rect(0, 0, w, h, M2) + rect(0, 0, w, Y(.3), W3)
        for fx in (.12, .38, .64, .9):
            s += rect(X(fx) - 5 * u, Y(.2), 10 * u, h, S7) + ell(X(fx), Y(.22), 30 * u, 13 * u, M8) + ell(X(fx) - 8 * u, Y(.2), 16 * u, 7 * u, M6) + ell(X(fx) - 12 * u, Y(.16), 7 * u, 2 * u, '#fff', .3)
            s += path('M%s %sq-4 14 0 26' % (f(X(fx) + 12 * u), f(Y(.3))), stroke=M4, sw=1.8 * u)
        s += rect(0, Y(.85), w, h, M6)
        for i in range(7):
            s += ell(X(i / 6.0), Y(.88), 9 * u, 4 * u, M4)
        s += circ(X(.25), Y(.8), 2.4 * u, PT5) + circ(X(.5), Y(.84), 2.4 * u, G5) + circ(X(.78), Y(.8), 2.4 * u, E5)
    elif code == 'ESA':
        s += rect(0, 0, w, h, E3, 0, ' opacity=".65"') + rect(0, 0, w, Y(.35), G3) + circ(X(.5), Y(.58), 18 * u, E4) + circ(X(.5), Y(.58), 12 * u, G3, .5)
        s += hills(w, Y(.6), 3 * u, S5, 1, h) + rect(0, Y(.66), w, h, G5) + hills(w, Y(.78), 3 * u, M2, 2, h) + hills(w, Y(.92), 2 * u, G5, 5, h)
        s += acacia(X(.2), Y(.82), 1.4 * u) + acacia(X(.8), Y(.86), 1.7 * u) + acacia(X(.55), Y(.74), .9 * u)
    elif code == 'CSA':
        s += rect(0, 0, w, h, W3) + mountain(X(.28), Y(.66), 70 * u, 56 * u, T5) + mountain(X(.62), Y(.66), 84 * u, 66 * u, T7) + mountain(X(.9), Y(.66), 50 * u, 38 * u, T5)
        s += hills(w, Y(.72), 4 * u, M4, 0, h) + hills(w, Y(.84), 3 * u, M6, 3, h)
        for i in range(4):
            s += rect(X(.04 + i * .1), Y(.78), 14 * u, 3 * u, E5) + rect(X(.2 + i * .1), Y(.9), 14 * u, 3 * u, E4) + rect(X(.12 + i * .1), Y(.84), 14 * u, 3 * u, G5)
        s += path('M%s %sQ%s %s %s %s' % (f(X(.08)), f(Y(.2)), f(X(.28)), f(Y(.32)), f(X(.44)), f(Y(.18))), stroke=INK, sw=.8 * u)
        for i, c in enumerate([E5, G5, M6, W5, PT5]):
            s += path('M%s %sl%s %s -%s %sz' % (f(X(.12 + i * .075)), f(Y(.25)), f(4 * u), f(0), f(0), f(4 * u)), c)
    elif code == 'EA':
        s += rect(0, 0, w, h, PT3) + circ(X(.78), Y(.2), 10 * u, CR, .9) + mountain(X(.42), Y(.7), 90 * u, 52 * u, T5)
        s += hills(w, Y(.68), 5 * u, M4, 1, h) + hills(w, Y(.82), 4 * u, M6, 3, h)
        for fx, fy, r in [(.1, .78, 11), (.3, .85, 13), (.62, .8, 12), (.84, .76, 14), (.95, .9, 9)]:
            s += rect(X(fx) - 1.4 * u, Y(fy), 2.8 * u, r * .9 * u, S7) + circ(X(fx), Y(fy) - 3 * u, r * u, PT5) + circ(X(fx) - r * .35 * u, Y(fy) - r * .3 * u, r * .6 * u, PT3) + circ(X(fx) - r * .3 * u, Y(fy) - r * .75 * u, r * .22 * u, '#fff', .5)
        r = random.Random(5)
        for i in range(14):
            s += ell(r.uniform(0, w), r.uniform(Y(.1), Y(.95)), 1.6 * u, 1 * u, PT5, .9)
    elif code == 'SEA':
        s += rect(0, 0, w, h, T3) + rect(0, Y(.2), w, h, M2)
        s += hills(w, Y(.3), 5 * u, M6, 0, h) + hills(w, Y(.4), 3 * u, M8, 2, h)
        for i in range(4):
            yy = Y(.55 + i * .1)
            s += path('M0 %sQ%s %s %s %sL%s %sL0 %sz' % (f(yy), f(w * .5), f(yy - 8 * u), f(w), f(yy), f(w), f(h), f(h)), [M4, M2, M4, M6][i]) + path('M0 %sQ%s %s %s %s' % (f(yy + 2 * u), f(w * .5), f(yy - 6 * u), f(w), f(yy + 2 * u)), stroke=W3, sw=1.6 * u, op=.8)
        for fx in (.08, .9):
            for a in (-1, -.3, .5, 1.1):
                s += ell(X(fx) + a * 8 * u, Y(.35), 4 * u, 14 * u, M6, None, ' transform="rotate(%d %s %s)"' % (a * 40, f(X(fx)), f(Y(.5))))
        r = random.Random(3)
        for i in range(24):
            x = r.uniform(0, w)
            s += path('M%s %sl-2 %s' % (f(x), f(r.uniform(0, h * .8)), f(7 * u)), stroke=W5, sw=.9 * u, op=.8)
    elif code == 'OC':
        s += rect(0, 0, w, h, W3) + rect(0, Y(.3), w, h, W5, 0, ' opacity=".8"') + rect(0, Y(.6), w, h, W7, 0, ' opacity=".55"')
        s += path('M%s 0L%s %sL%s %sz' % (f(X(.3)), f(X(.15)), f(Y(.6)), f(X(.35)), f(Y(.6))), '#fff', op=.18)
        s += hills(w, Y(.88), 3 * u, G3, 0, h)
        for fx, c, hh in [(.1, PT5, 28), (.22, E4, 20), (.58, D5, 30), (.7, PT5, 22), (.9, E4, 26)]:
            x = X(fx)
            yb = Y(.9)
            s += path('M%s %sv%s' % (f(x), f(yb), f(-hh * u)), stroke=c, sw=4 * u) + path('M%s %sl-6 %sM%s %sl6 %s' % (f(x), f(yb - hh * .5 * u), f(-8 * u), f(x), f(yb - hh * .7 * u), f(-7 * u)), stroke=c, sw=3.4 * u)
            s += circ(x, yb - hh * u, 3 * u, c) + circ(x - 6 * u, yb - (hh * .5 + 8) * u, 2.6 * u, c) + circ(x + 6 * u, yb - (hh * .7 + 7) * u, 2.6 * u, c)
        for fx, fy, d in [(.4, .45, 1), (.8, .6, -1), (.3, .7, -1)]:
            x, y = X(fx), Y(fy)
            s += ell(x, y, 7 * u, 4 * u, G5) + path('M%s %sl%s -3 0 6z' % (f(x - d * 6 * u), f(y), f(-d * 5 * u)), G5) + circ(x + d * 3 * u, y - u, .9 * u, INK) + ell(x, y - 1.5 * u, 3 * u, 1 * u, '#fff', .4)
        for fx, fy in [(.5, .35), (.52, .3), (.2, .5), (.85, .4)]:
            s += circ(X(fx), Y(fy), 1.6 * u, CR, .8)
    return s


REGIONS = {'NA': 'Maplewold maple woods', 'CA': 'Maizehollow cornfields', 'CB': 'Sunsprinkle palm isles', 'SA': 'Rainroot rainforest', 'NWE': 'Mistmoor misty moor',
           'SE': 'Olivewhistle olive coast', 'EE': 'Birchbramble steppe', 'MENA': 'Dunewhisper dunes', 'WCA': 'Greatcanopy rainforest', 'ESA': 'Thornacre savanna',
           'CSA': 'Spicepeak mountains', 'EA': 'Blossomreach blossom hills', 'SEA': 'Monsoon Tangle jungle', 'OC': 'Coralscatter coral reef'}


# ---------------- hats ----------------
HATS = {'rootwarden': (S5, S7, 'sprout'), 'bloomcaller': (PT5, E5, 'flower'), 'thornblade': (E5, E7, 'thorn'), 'seedkeeper': (W5, W7, 'seed'),
        'wayfinder': (M6, M8, 'compass'), 'brewroot': (D5, D7, 'flask')}


def hat(name):
    col, dark, em = HATS[name]
    s = sh(32, 57, 25, 4)
    s += path('M12 48Q14 28 26 16Q34 6 50 12Q42 12 40 20Q47 32 52 48z', col)
    s += path('M17 44Q19 32 27 22', stroke='#fff', sw=2.4, op=.4)
    s += ell(32, 49, 25, 6.5, dark) + rect(13, 40, 38, 8, dark, 3) + ell(32, 47, 22, 4.5, col)
    if em == 'sprout':
        s += path('M32 43V34', stroke=M8, sw=2) + leaf(32, 35, -7, -5, M6) + leaf(32, 35, 7, -6, M4)
    elif em == 'flower':
        for i in range(5):
            a = i * 1.2566
            s += circ(32 + math.sin(a) * 4.5, 31 + math.cos(a) * 4.5, 3, PT3)
        s += circ(32, 31, 2.6, G5)
    elif em == 'thorn':
        s += path('M26 40L32 24L38 40z', CR) + path('M32 26v12', stroke=T5, sw=1.2)
    elif em == 'seed':
        s += ell(32, 32, 4.2, 6, G5) + path('M32 27v10', stroke=G7, sw=1.2) + hl(30, 28, 1.5, 4, .7)
    elif em == 'compass':
        s += circ(32, 32, 7.5, CR) + path('M32 25.5l3 6.5-3 6.5-3-6.5z', E5) + circ(32, 32, 1.4, INK)
    else:
        s += path('M29 25h6v6l5 9H24l5-9z', W3) + path('M26 38h12l2 2H24z', M4) + circ(31, 22, 2, CR, .9) + circ(35, 19, 1.5, CR, .9)
    s += circ(50, 11, 3.2, G5) + circ(49, 10, 1.1, '#fff', .5)
    return s


# ---------------- landmarks ----------------
def landmark(kind):
    s = sh(32, 58, 25, 4)
    if kind == 'wonder':
        s += ell(32, 52, 22, 6, M6) + rect(10, 22, 10, 33, T5, 4) + rect(44, 22, 10, 33, T5, 4) + rect(8, 14, 48, 12, T7, 5) + hl(12, 16, 16, 3, 1.5)
        s += path('M32 50l3-9 9-3-9-3-3-9-3 9-9 3 9 3z', G5) + circ(50, 36, 1.8, G3) + circ(14, 40, 1.5, G3)
    elif kind == 'delve':
        s += path('M4 56Q4 18 32 18t28 38z', T5) + path('M10 30Q16 22 26 20', stroke='#fff', sw=2.4, op=.4)
        s += path('M16 56V42a16 16 0 0 1 32 0v14z', INK) + path('M16 56V42a16 16 0 0 1 32 0v14z', 'none', S5, 3)
        s += path('M26 56V36M38 56V36M26 41h12M26 47h12M26 53h12', stroke=S5, sw=2.2) + circ(52, 40, 2, G3)
    elif kind == 'lair':
        s += path('M4 56Q4 20 32 20t28 36z', T7) + path('M12 28l4-10 4 8 6-10 5 11 6-11 4 9 5-8 3 12z', E7)
        s += path('M15 56V44a17 14 0 0 1 34 0v12z', INK) + ell(25, 45, 3, 2.2, E4) + ell(39, 45, 3, 2.2, E4) + circ(25, 45, 1, G3) + circ(39, 45, 1, G3)
        s += path('M20 56l3-6 3 6M28 56l3-6 3 6M36 56l3-6 3 6', CR) + path('M6 56l4-8 4 8zM50 56l4-8 4 8z', CR)
    elif kind == 'ruins':
        s += ell(32, 52, 24, 6, M4) + rect(8, 30, 9, 24, T3, 2) + rect(7, 26, 11, 5, T5, 2) + rect(27, 38, 9, 16, T3, 2) + path('M27 38l5-5 4 5z', T5)
        s += rect(46, 22, 9, 32, T3, 2) + rect(45, 18, 11, 5, T5, 2) + rect(21, 50, 24, 5, T5, 2) + path('M12 50q-2-6 2-10M50 36q3 5-1 11', stroke=M6, sw=2) + hl(10, 32, 2, 16, 1)
    elif kind == 'haven':
        s += ell(32, 52, 25, 6, M4) + path('M6 54L32 14l26 40z', E5) + path('M12 48L30 20', stroke='#fff', sw=2.4, op=.4)
        s += path('M24 54L32 32l8 22z', G3) + path('M32 32v22', stroke=E7, sw=1.2) + rect(28, 6, 8, 5, E4, 1) + path('M32 14V6', stroke=S9, sw=1.5)
        s += path('M44 56q0-6 3-9 1 4 4 3-2 6-1 6z', E3) + circ(48, 52, 2, G3) + rect(41, 55, 12, 3, S7, 1.5)
    return s


# ---------------- landscape icons ----------------
LANDS = ('coast', 'mountain', 'forest', 'desert', 'rainforest', 'grassland', 'wetland', 'tundra', 'island')


def tree(x, y, h, c1, c2):
    return rect(x - 1.2, y - h * .35, 2.4, h * .4, S7) + path('M%s %sl%s %s h-%sz' % (f(x), f(y - h), f(h * .38), f(h * .75), f(h * .76)), c1) + path('M%s %sl%s %s h-%sz' % (f(x), f(y - h * .6), f(h * .3), f(h * .5), f(h * .6)), c2)


def land(kind):
    s = rect(3, 3, 58, 58, W3, 7)
    sun = lambda x, y: circ(x, y, 5, G3) + circ(x - 1.5, y - 1.5, 1.6, '#fff', .5)
    if kind == 'coast':
        s += sun(48, 15) + path('M3 34h58v20a7 7 0 0 1-7 7H10a7 7 0 0 1-7-7z', W5) + path('M3 34h58v4H3z', W7, op=.5)
        s += path('M3 46Q16 40 32 48t29-4v10a7 7 0 0 1-7 7H10a7 7 0 0 1-7-7z', S3)
        s += path('M8 40q4-3 8 0t8 0M36 38q4-3 8 0t8 0', stroke=CR, sw=1.6) + circ(22, 54, 2.2, PT3) + path('M46 46v-8l8 4z', E5) + path('M46 46h8', stroke=S9, sw=1.2)
    elif kind == 'mountain':
        s += sun(15, 15) + path('M3 50L22 20l12 16 8-10 19 26v-1z', T5) + path('M3 50L22 20l19 30z', T5)
        s += path('M22 20l-6 9 3-2 3 3 3-3 3 2z', CR) + path('M42 26l-5 8 3-1 2 2 2-2 3 1z', CR) + path('M3 50h58v4a7 7 0 0 1-7 7H10a7 7 0 0 1-7-7z', M6)
        s += path('M22 20l7 14-7 16', stroke=T7, sw=1.2, op=.6) + tree(14, 54, 12, M8, M6) + tree(50, 55, 10, M8, M6)
    elif kind == 'forest':
        s += rect(3, 3, 58, 58, M2, 7) + path('M3 46h58v8a7 7 0 0 1-7 7H10a7 7 0 0 1-7-7z', M6)
        s += tree(16, 52, 34, M8, M6) + tree(34, 54, 40, M8, M6) + tree(50, 51, 30, M8, M6) + ell(26, 57, 8, 2, S5) + circ(8, 54, 1.8, E5)
    elif kind == 'desert':
        s = rect(3, 3, 58, 58, G3, 7) + sun(48, 14) + path('M3 46Q20 36 34 44t27-4v14a7 7 0 0 1-7 7H10a7 7 0 0 1-7-7z', S3)
        s += path('M3 52Q24 44 44 54t17-2v2a7 7 0 0 1-7 7H10a7 7 0 0 1-7-7z', G5, op=.6)
        s += rect(20, 22, 7, 28, M6, 3.5) + rect(12, 30, 4, 10, M6, 2) + rect(12, 38, 12, 3.5, M6, 1.8) + rect(27, 28, 4, 9, M6, 2) + rect(23, 35, 8, 3.5, M6, 1.8) + hl(21.5, 25, 1.6, 20, .8)
        s += circ(47, 50, 3, T5) + path('M42 48l3-4 3 4z', T3)
    elif kind == 'rainforest':
        s = rect(3, 3, 58, 58, M4, 7) + path('M3 48h58v6a7 7 0 0 1-7 7H10a7 7 0 0 1-7-7z', M8)
        s += rect(14, 22, 5, 30, S7) + rect(44, 18, 5, 34, S7) + ell(16, 20, 12, 7, M8) + ell(46, 16, 13, 7, M8) + ell(30, 14, 10, 6, M6)
        s += path('M30 20q-3 10 0 20M24 20q-4 8-2 16', stroke=M2, sw=1.4) + path('M32 44q3-8 8-6-4 2-5 8M32 44q-3-8-8-6 4 2 5 8', M6)
        s += circ(54, 38, 2.4, PT5) + circ(9, 44, 2.2, PT5) + ell(38, 30, 3, 2, E5) + ell(38, 30, 3, 2, 'none')
    elif kind == 'grassland':
        s += sun(48, 15) + path('M3 36Q20 30 34 36t27-2v20a7 7 0 0 1-7 7H10a7 7 0 0 1-7-7z', M4) + path('M3 46Q24 40 40 46t21-2v10a7 7 0 0 1-7 7H10a7 7 0 0 1-7-7z', M6)
        s += path('M12 56q0-8 2-12M18 57q1-8 3-11M26 56q-1-7-3-10M40 57q0-8 2-11M48 56q1-8-1-12M54 55q-1-6-3-9', stroke=M8, sw=1.6)
        s += circ(14, 44, 2, PT5) + circ(30, 50, 2, G5) + circ(44, 48, 2, PT5) + circ(21, 52, 1.8, CR)
    elif kind == 'wetland':
        s = rect(3, 3, 58, 58, W3, 7) + path('M3 36h58v18a7 7 0 0 1-7 7H10a7 7 0 0 1-7-7z', W5) + path('M3 36Q16 30 32 36t29-2v4H3z', M6)
        s += path('M12 48q4-3 8 0t8 0M36 52q4-3 8 0', stroke=W3, sw=1.6)
        s += ''.join(path('M%d 44V%d' % (x, y), stroke=S5, sw=2) + ell(x, y - 2, 1.8, 4, S7) for x, y in ((14, 24), (20, 20), (46, 22), (52, 26)))
        s += ell(34, 48, 7, 3, M6) + circ(36, 47, 1.6, PT5)
    elif kind == 'tundra':
        s = rect(3, 3, 58, 58, W3, 7) + path('M3 40Q18 32 32 40t29-4v18a7 7 0 0 1-7 7H10a7 7 0 0 1-7-7z', CR) + path('M3 50Q24 44 40 50t21-2v6a7 7 0 0 1-7 7H10a7 7 0 0 1-7-7z', W3, op=.6)
        s += tree(18, 44, 22, M8, T7) + tree(30, 46, 16, M8, T7) + path('M18 22l4 6h-8zM30 30l3 5h-6z', CR) + circ(10, 14, 1.4, CR) + circ(50, 12, 1.4, CR) + circ(40, 20, 1.2, CR) + circ(54, 26, 1.2, CR)
        s += path('M44 54l4-9 4 9z', W5) + path('M44 54l4-9 4 9z', 'none', CR, 1.2)
    else:
        s += sun(50, 14) + path('M3 40h58v14a7 7 0 0 1-7 7H10a7 7 0 0 1-7-7z', W5) + path('M8 52q4-3 8 0t8 0M42 50q4-3 8 0', stroke=W3, sw=1.6)
        s += ell(32, 40, 20, 7, S3) + ell(32, 38, 15, 5, M4) + rect(31, 24, 2.6, 14, S7) + path('M32 25Q22 20 18 28Q26 22 32 25ZM32 25Q42 20 46 28Q38 22 32 25ZM32 25Q30 16 24 15Q30 17 32 25ZM32 25Q34 16 40 15Q34 17 32 25Z', M6)
        s += circ(32, 27, 1.6, S9)
    return s, kind.capitalize() + ' landscape'


def logo():
    s = ell(40, 52, 24, 4, '#000', .15)
    s += rect(32, 30, 9, 22, CR, 4) + path('M16 34Q16 14 40 14t24 20z', E5) + path('M22 28Q26 20 36 18', stroke='#fff', sw=2.2, op=.4)
    s += circ(28, 26, 3, CR) + circ(44, 22, 3.2, CR) + circ(52, 30, 2.2, CR)
    s += path('M70 48Q72 30 82 22Q88 14 98 18Q92 20 92 26Q96 36 100 48z', M6) + ell(85, 49, 18, 4.5, M8) + circ(98, 17, 2.4, G5)
    s += '<text x="108" y="36" font-family="Georgia,\'Times New Roman\',serif" font-size="16" font-weight="700" fill="#3d2a1c">Gnome Venture</text>'
    return s


def build():
    for bk in BUILD:
        for l in (1, 2, 3):
            b, n = building(bk, l)
            put('%s-%d' % (bk, l), b, n)
        for sk in SKINS[bk]:
            b, n = building(bk, 1, sk)
            put('%s-%s' % (bk, sk), b, n)
    for item in FENCES:
        for shp in ('end', 'straight', 'corner', 'tee', 'cross', 'gate'):
            b, n = fence_piece(item, shp)
            put('%s-%s' % (item, shp), b, n)
    for t in TILES:
        b, n = tile(t)
        put('tile-' + t, b, n)
    for k in KINDS:
        for st in (1, 2, 3, 4):
            put('stage-%s-%d' % (k, st), stage(k, st), '%s growth stage %d' % (k.capitalize(), st))
    for c, nm in REGIONS.items():
        put('banner-' + c.lower(), scene(c, 240, 80), nm + ' banner', 240, 80)
    for k in LANDS:
        b, n = land(k)
        put('land-' + k, b, n)
    for c in HATS:
        put('hat-' + c, hat(c), c.capitalize() + ' hat')
    for k in ('wonder', 'delve', 'lair', 'ruins', 'haven'):
        put('lm-' + k, landmark(k), 'Landmark: ' + k)
    put('logo', logo(), 'Gnome Venture', 240, 60)


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    build()
    big = 0
    for name, svg in sorted(FILES.items()):
        lim = 8192 if name.startswith('banner-') else 4096
        if len(svg.encode()) >= lim:
            print('TOO BIG', name, len(svg.encode()))
            big += 1
        with open(os.path.join(OUT, name), 'w') as fh:
            fh.write(svg)
    print(len(FILES), 'files,', big, 'oversize')
