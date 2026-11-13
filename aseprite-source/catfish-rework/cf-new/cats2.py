import sys, os, math, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib2 import *
HERE = os.path.dirname(os.path.abspath(__file__)) + '/'
OLD = '/home/user/gnome-venture/game/assets/img/catfish/'
G = dict(deep='#3d3654', shade='#57516f', bounce='#6e6684', base='#8a859b', light='#cdc9d3', gloss='#f1ebe3', lift='#aca7b9', rim='#646691')
PINK, PINKD, CREAM = '#e8909e', '#c66a80', '#f2e4c0'
FISH = ['#ac3b1d', '#dc6f2c', '#e38111', '#f2a860', '#ffc27a', '#fff1c8']
UMB, UMBD = '#4a2c1a', '#2a1a10'

def style(rich):
    if rich:
        R = [G[k] for k in ('deep', 'shade', 'bounce', 'base', 'lift', 'light', 'gloss')]
        return R, (0.22, 0.36, 0.5, 0.7, 0.84, 0.95), G['rim']
    R = [G[k] for k in ('deep', 'shade', 'bounce', 'base', 'light', 'gloss')]
    return R, (0.22, 0.38, 0.52, 0.76, 0.92), None

def hsh(x, y, k=0): return ((x * 73856093) ^ (y * 19349663) ^ (k * 83492791)) % 1000 / 1000.0
def old(frame): return np.array(Image.open(OLD + 'cf-cat-grey-%s.png' % frame).convert('RGBA'))
def rell(cv, cx, cy, rx, ry, ang):
    y, x = np.mgrid[0:cv.h, 0:cv.w]; c, s = math.cos(ang), math.sin(ang)
    u = (x - cx) * c + (y - cy) * s; v = -(x - cx) * s + (y - cy) * c
    return (u / rx) ** 2 + (v / ry) ** 2 <= 1.0
def light(cv, m, name):
    for y, x in zip(*np.nonzero(m & cv.a)): cv.set(x, y, G[name], lock=False)

def head(cv, ox, oy, frame, rich):
    E = lambda cx, cy, rx, ry: cv.ellipse(cx + ox, cy + oy, rx, ry)
    P = lambda pts: cv.poly([(x + ox, y + oy) for x, y in pts])
    for side in (0, 1):
        f = (lambda x: x) if side == 0 else (lambda x: 50 - x)
        ear = P([(f(9), 15), (f(10), 3), (f(22), 9)]) | P([(f(10), 14), (f(11), 3), (f(21), 9), (f(20), 14)])
        cv.pt(ear, 'ear')
    hd = E(25, 19, 15.5, 12.5)
    hd |= P([(11, 25), (8, 28), (12, 28)]) | P([(39, 25), (42, 28), (38, 28)])
    cv.pt(hd, 'head', bias=0.02, ao=1)
    for side in (0, 1):
        f = (lambda x: x) if side == 0 else (lambda x: 50 - x)
        for (x, y, c) in [(12, 12, PINKD), (12, 11, PINKD), (12, 10, PINK), (12, 9, PINK), (13, 10, PINK), (13, 11, PINK), (13, 12, PINK), (14, 11, PINK), (14, 10, PINK), (15, 11, PINK), (12, 8, PINK), (12, 7, PINKD), (14, 12, PINKD), (13, 13, PINKD)]:
            cv.set(f(x) + ox, y + oy, c)
        # lit ear rim
        for (x, y) in [(10, 8), (11, 5), (11, 4), (12, 6)]: cv.set(f(x) + ox, y + oy, G['light'] if side == 0 else G['shade'])
    # cowlick quirk: a hooked lock of fur on the crown, 2-3px thick, lit on the left, hi pixel on the curl
    cow = cv.line([(24 + ox, 9 + oy), (24 + ox, 6 + oy), (25 + ox, 3 + oy), (27 + ox, 2 + oy), (29 + ox, 3 + oy)], 2.6, 1.8)
    cv.pt(cow & ~hd, 'tuft', bias=0.05, ao=0)
    for p in [(24, 7), (24, 5), (25, 4)]: cv.set(p[0] + ox, p[1] + oy, G['light'])
    cv.set(26 + ox, 2 + oy, G['gloss']); cv.set(27 + ox, 2 + oy, G['gloss'])
    cv.set(28 + ox, 4 + oy, G['shade']); cv.set(26 + ox, 6 + oy, G['shade'])
    mz = E(25, 27.5, 5.2, 3.4)
    light(cv, mz, 'light')
    for p in [(21, 26), (22, 25), (28, 25), (29, 26), (22, 29), (28, 29)]: cv.set(p[0] + ox, p[1] + oy, G['gloss'])
    for p in [(24, 25), (25, 25), (26, 25), (25, 26)]: cv.set(p[0] + ox, p[1] + oy, '#2b1c26')
    cv.set(24 + ox, 25 + oy, CREAM)
    for p in [(25, 27), (24, 28), (26, 28), (23, 27), (27, 27)]: cv.set(p[0] + ox, p[1] + oy, G['shade'])
    for (x, y) in [(16, 27), (17, 27), (18, 27), (18, 29), (19, 29), (15, 25)]:
        cv.set(x + ox, y + oy, G['gloss']); cv.set(50 - x + ox, y + oy, G['gloss'])
    for (x, y) in [(12, 26), (13, 28), (38, 26), (37, 28), (14, 15), (36, 15)]: cv.set(x + ox, y + oy, G['shade'])
    if rich:   # cheek fur strands: light strokes on the lit side, dark under the jaw
        for (x, y) in [(12, 23), (11, 22), (13, 24), (15, 29), (17, 31), (21, 31), (29, 31), (33, 31), (36, 29), (39, 23)]:
            cv.set(x + ox, y + oy, G['lift'] if x < 26 else G['shade'])
        for (x, y) in [(13, 30), (14, 30), (36, 30), (37, 30), (25, 31), (26, 31)]: cv.set(x + ox, y + oy, G['shade'] if x > 24 else G['bounce'])
        for (x, y) in [(20, 13), (23, 11), (30, 12), (33, 14)]: cv.set(x + ox, y + oy, G['lift'])
    o = old(frame)
    for ecx in (16, 34):
        cx, cy = ecx + ox, 21 + oy
        for y in range(cy - 3, cy + 4):
            for x in range(cx - 3, cx + 4):
                r, g, b, a = o[y, x]
                if a and (r, g, b) in ((0x2a, 0x1a, 0x10), (0xf2, 0xe4, 0xc0)):
                    cv.set(x, y, '#%02x%02x%02x' % (r, g, b), only=False)

def toes(cv, x, y, n=2, dx=2):
    """toe lines + a lit paw top"""
    for i in range(n):
        cv.set(x - dx // 2 + i * dx, y, G['shade']); cv.set(x - dx // 2 + i * dx, y + 1, G['deep'])

def fur_flecks(cv, labels, rich):
    if not rich: return
    ys, xs = np.nonzero(np.isin(cv.own, labels))
    for y, x in zip(ys, xs):
        if cv.lock[y, x] or hsh(x, y, 7) > 0.06: continue
        if x + 1 >= cv.w or y + 1 >= cv.h or cv.own[y + 1, x + 1] not in labels or cv.lock[y + 1, x + 1]: continue
        i = cv.idx[y, x]
        if i < 0: continue
        if cv.v[y, x] > 0.55: j = min(len(cv.R) - 1, i + 1)
        elif cv.v[y, x] < 0.5: j = max(0, i - 1)
        else: continue
        for (xx, yy) in ((x, y), (x + 1, y + 1)):
            cv.rgb[yy, xx] = hx(cv.R[j]); cv.idx[yy, xx] = j

def tail_tip(cv, m, pt, r=2.6):
    y, x = np.mgrid[0:cv.h, 0:cv.w]
    t = m & (((x - pt[0]) ** 2 + (y - pt[1]) ** 2) <= r * r)
    for yy, xx in zip(*np.nonzero(t)): cv.set(xx, yy, G['light'] if len(cv.R) == 6 else G['light'], lock=False)

def gshadow(cv, cx, cy, rx, ry=1.8):
    sh = cv.ellipse(cx, cy, rx, ry)
    cv.flat(sh, UMB); cv.flat(sh & (np.arange(64)[:, None] >= cy + 0.4), UMBD); cv.lock |= sh; cv.own[sh] = 'shadow'

def fish_in_arms(cv, rich):
    saveR, savec, saver = cv.R, cv.cuts, cv.rimcol
    cv.R, cv.cuts, cv.rimcol = FISH, (0.22, 0.38, 0.52, 0.76, 0.92), None
    tl = cv.poly([(34, 44), (42, 38), (41, 44), (42, 50)])
    fb = cv.ellipse(26, 44, 9.5, 5); ft = cv.poly([(24, 38), (30, 38), (28, 41)])
    cv.pt(tl, 'fish', ao=0, k=1.0); cv.pt(fb | ft, 'fish', ao=0, k=1.0)
    for p in [(20, 47), (21, 48), (22, 48), (23, 48), (24, 48), (25, 48)]: cv.set(*p, FISH[4])
    for p in [(31, 41), (31, 42), (31, 43), (31, 44), (31, 45)]: cv.set(*p, FISH[0])
    cv.set(19, 43, '#2b1c26'); cv.set(18, 42, FISH[5])
    for p in [(24, 43), (26, 42), (28, 44), (25, 46), (22, 44), (27, 40)]: cv.set(*p, FISH[2])
    for p in [(23, 41), (24, 41)]: cv.set(*p, FISH[5])
    if rich:
        for p in [(37, 41), (38, 40), (38, 44), (39, 44), (37, 47), (38, 47)]: cv.set(*p, FISH[4])
        for p in [(40, 40), (40, 48)]: cv.set(*p, FISH[0])
    cv.R, cv.cuts, cv.rimcol = saveR, savec, saver
    for (ax, ay) in ((16, 45), (35, 46)):
        arm = cv.ellipse(ax, ay, 3.6, 3.0)
        cv.pt(arm, 'arm', ao=2)
        for dx in (-1, 1): cv.set(ax + dx, ay + 1, G['shade'])
        cv.set(ax, ay - 1, G['gloss'] if True else G['light'])

def build(frame, rich):
    R, cuts, rim = style(rich)
    cv = Cv2(64, 64, R, cuts, rim)
    M = {}
    if frame in ('idleA', 'catch'):
        if rich: gshadow(cv, 24, 59, 16, 1.5)
        tl = cv.line([(36, 52), (45, 57), (52, 50), (52, 40), (48, 34)], 4.6, 3.0)
        cv.pt(tl, 'tail', ao=0); tail_tip(cv, tl, (48, 34))
        for i in range(3): cv.set(51 + (i % 2), 44 + i * 4, G['shade'])
        if rich:
            for p in [(52, 36), (53, 39), (53, 43), (52, 47), (50, 52), (46, 56)]: cv.set(*p, G['lift'])
            for p in [(48, 57), (50, 55), (54, 45), (51, 41), (54, 41)]: cv.set(*p, G['shade'])
            for p in [(49, 38), (47, 36)]: cv.set(*p, G['gloss'])
        body = cv.ellipse(24, 43, 12.5, 12.5)
        cv.pt(body, 'torso', ao=0)
        hl = cv.ellipse(13, 49, 5.6, 6.2); hr = cv.ellipse(35, 49, 5.6, 6.2)
        cv.pt(hl, 'haunch', ao=1); cv.pt(hr, 'haunch', ao=1)
        # thigh crease lines
        for p in [(15, 45), (16, 46), (17, 48), (17, 50)]: cv.set(*p, G['shade'])
        for p in [(33, 45), (32, 46), (31, 48), (31, 50)]: cv.set(*p, G['bounce'])
        bl = cv.ellipse(24, 46, 6.5, 6); light(cv, bl & (cv.own == 'torso'), 'lift' if rich else 'light')
        if rich:
            light(cv, cv.ellipse(23, 45, 3.5, 3.5) & (cv.own == 'torso'), 'light')
            for p in [(21, 43), (22, 42), (24, 42)]: cv.set(*p, G['gloss'])
        elif not frame == 'catch':
            for p in [(21, 42), (22, 41), (24, 41)]: cv.set(*p, G['gloss'])
        for p in [(22, 33), (23, 34), (24, 35), (25, 35), (26, 35), (27, 34), (28, 33)]: cv.set(*p, G['light'])
        for p in [(24, 36), (25, 36), (26, 36)]: cv.set(*p, G['gloss'])
        if rich:
            for p in [(21, 34), (22, 35), (23, 36), (27, 36), (28, 35), (29, 34), (25, 37)]: cv.set(*p, G['lift'] if p[0] < 26 else G['shade'])
        for (lx) in (19, 30):
            leg = cv.poly([(lx - 3, 43), (lx + 3, 43), (lx + 2, 54), (lx - 2, 54)])
            cv.pt(leg, 'leg', ao=2, k=1.4)
            cv.set(lx - 3, 47, G['shade']); cv.set(lx - 3, 48, G['shade'])  # elbow notch
            paw = cv.ellipse(lx, 55, 4.6, 2.5); cv.pt(paw, 'paw', ao=1)
            toes(cv, lx, 55, 2, 2); cv.set(lx - 2, 54, G['gloss']); cv.set(lx - 1, 54, G['light'])
        for p in [(9, 54), (10, 55), (11, 56), (37, 56), (38, 55), (39, 54)]: cv.set(*p, G['shade'])
        if frame == 'catch': fish_in_arms(cv, rich)
        head(cv, 0, 0, frame, rich)
        M = dict(tailend=(48, 34), stub=(37, 53), ox=0, oy=0)
    elif frame == 'pounce':
        gshadow(cv, 30, 57, 12, 1.6)
        tl = cv.line([(9, 34), (4, 28), (5, 20), (8, 13), (12, 9), (14, 11)], 4.6, 2.6)
        cv.pt(tl, 'tail', ao=0); tail_tip(cv, tl, (13, 10), 2.6)
        for p in [(4, 24), (5, 29), (7, 16)]: cv.set(*p, G['shade'])
        if rich:
            for p in [(6, 22), (5, 26), (9, 14), (11, 10), (6, 31)]: cv.set(*p, G['lift'])
            for p in [(7, 25), (8, 18), (10, 12)]: cv.set(*p, G['shade'])
        torso = cv.line([(13, 38), (36, 33)], 11, 10)
        cv.pt(torso, 'torso', ao=0)
        # hind leg pushing off behind: thigh, shin, long foot
        haunch = cv.ellipse(14, 37, 6.2, 6.2); cv.pt(haunch, 'haunch', ao=1)
        shin = cv.line([(12, 40), (7, 45), (4, 48)], 4.2, 3.0); cv.pt(shin, 'leg', ao=1, k=1.3)
        foot = rell(cv, 4, 50, 4.4, 2.2, -0.6); cv.pt(foot, 'paw', ao=1)
        toes(cv, 3, 50, 2, 2)
        for p in [(16, 34), (17, 35), (18, 37), (17, 40)]: cv.set(*p, G['shade'])
        bl = cv.line([(20, 38), (33, 35)], 3.8); light(cv, bl & (cv.own == 'torso'), 'lift' if rich else 'light')
        for p in [(22, 33), (23, 32), (26, 32)]: cv.set(*p, G['gloss'])
        # shorter forelegs reaching
        f2 = cv.line([(34, 37), (40, 42), (46, 43)], 4.4, 3.4); cv.pt(f2, 'arm', ao=2, k=1.3)
        f1 = cv.line([(36, 35), (43, 38), (49, 38)], 4.6, 3.6); cv.pt(f1, 'arm', ao=2, k=1.3)
        for (x, y) in ((50, 38), (47, 43)):
            pw = cv.ellipse(x, y, 3.4, 2.8); cv.pt(pw, 'paw', ao=1)
            toes(cv, x + 1, y - 1, 2, 2)
            cv.set(x - 1, y - 2, G['gloss'])
        head(cv, 16, 0, 'pounce', rich)
        M = dict(tailend=(13, 10), stub=(9, 33), ox=16, oy=0)
    else:  # nap
        if rich: gshadow(cv, 36, 61, 22, 1.2)
        body = cv.ellipse(46, 46, 13.5, 11.5)
        cv.pt(body, 'torso', ao=0)
        sp = cv.line([(40, 38), (44, 36), (50, 36)], 2.0); light(cv, sp & (cv.own == 'torso'), 'lift' if rich else 'light')
        for p in [(54, 40), (55, 44), (56, 49), (52, 52)]: cv.set(*p, G['shade'])
        for p in [(47, 40), (49, 41), (52, 42)]: cv.set(*p, G['gloss'])
        if rich:
            for p in [(44, 40), (46, 42), (50, 44), (53, 46), (42, 44), (55, 50)]: cv.set(*p, G['lift'])
            for p in [(44, 52), (47, 54), (50, 54), (52, 50)]: cv.set(*p, G['bounce'])
        tl = cv.line([(54, 55), (42, 58), (32, 57), (24, 56)], 5.0, 3.4)
        cv.pt(tl, 'tail', ao=1); tail_tip(cv, tl, (24, 56), 2.8)
        for p in [(46, 58), (38, 59), (30, 58)]: cv.set(*p, G['shade'])
        for p in [(46, 56), (40, 57), (34, 55)]: cv.set(*p, G['light'])
        for x in (16, 27):
            pw = cv.ellipse(x, 53, 5, 2.8); cv.pt(pw, 'paw', ao=1)
            toes(cv, x, 53, 2, 2); cv.set(x - 2, 52, G['gloss'])
        head(cv, 0, 18, 'nap', rich)
        M = dict(tailend=(24, 56), stub=(54, 55), ox=0, oy=18)
    fur_flecks(cv, ['torso', 'tail', 'haunch', 'head'], rich)
    cv.outline2()
    M['frame'] = frame
    return cv, M

# ---------------- overlays ----------------
DEEP, SHADE, BASE, LIGHT, GLOSS = G['deep'], G['shade'], G['base'], G['light'], G['gloss']
W_BASE, W_GLOSS, W_SHADE, W_DEEP, W_EDGE = '#e6dfd2', '#fbf6ec', '#bab0c0', '#8d829a', '#463e5e'
INS = ['head', 'ear', 'tail', 'torso', 'haunch', 'leg', 'paw', 'arm', 'tuft']

class Ov:
    def __init__(s, cv):
        s.cv = cv; s.rgba = np.zeros((64, 64, 4), np.uint8)
        s.ok = np.isin(cv.own, INS) & ~cv.lock
    def p(s, x, y, col):
        if 0 <= x < 64 and 0 <= y < 64 and s.ok[y, x]: s.rgba[y, x, :3] = hx(col); s.rgba[y, x, 3] = 255
    def lab(s, *ls): return np.isin(s.cv.own, ls)
    def save(s, path): Image.fromarray(s.rgba, 'RGBA').save(path)

def hsh(x, y, k=0): return ((x * 73856093) ^ (y * 19349663) ^ (k * 83492791)) % 1000 / 1000.0

def tabby(cv, M):
    o = Ov(cv); ox, oy = M['ox'], M['oy']
    for (x, ln) in ((21, 4), (25, 6), (29, 4)):
        for i in range(ln): o.p(x + ox, 9 + oy + i, DEEP)
    for (x0, y) in ((10, 22), (10, 25)):
        for i in range(4): o.p(x0 + i + ox, y + oy, SHADE); o.p(50 - x0 - i + ox, y + oy, SHADE)
    tor = cv.own == 'torso'
    for y in range(64):
        xs = np.nonzero(tor[y])[0]
        if len(xs) and y % 6 in (0, 1):
            for i in range(4):
                c = DEEP if (y % 6 == 0 and i < 2) else SHADE
                o.p(xs[0] + i, y, c); o.p(xs[-1] - i, y, c)
    for y, x in zip(*np.nonzero(o.lab('leg', 'arm', 'haunch'))):
        if y % 4 == 0: o.p(x, y, SHADE)
    for y, x in zip(*np.nonzero(o.lab('tail'))):
        if ((x + y) // 3) % 3 == 0: o.p(x, y, DEEP if (x + y) % 3 == 0 else SHADE)
    return o

def spotted(cv, M):
    o = Ov(cv); ox, oy = M['ox'], M['oy']
    for gy in range(0, 64, 6):
        for gx in range(0, 64, 6):
            cx = gx + int(hsh(gx, gy, 1) * 4); cy = gy + int(hsh(gx, gy, 2) * 4)
            pts = [(cx, cy), (cx + 1, cy), (cx, cy + 1), (cx + 1, cy + 1)]
            if not all(0 <= x < 64 and 0 <= y < 64 and o.ok[y, x] and cv.own[y, x] != 'ear' for x, y in pts): continue
            if cv.own[cy, cx] == 'head' and (cy > oy + 21 or abs(cx - (25 + ox)) > 12 and cy > oy + 14): continue
            if abs(cx - (25 + ox)) < 3 and cv.own[cy, cx] == 'head': continue
            col = DEEP if hsh(gx, gy, 3) > 0.5 else SHADE
            for x, y in pts: o.p(x, y, col)
            if col == DEEP: o.p(cx + 2, cy, SHADE) if hsh(gx, gy, 4) > 0.5 else None
    return o

def patch(o, W, edge=True):
    cv = o.cv
    for y, x in zip(*np.nonzero(W & o.ok)):
        up = not W[y, x - 1] or not W[y - 1, x]; dn = not W[y, min(63, x + 1)] or not W[min(63, y + 1), x]
        col = W_BASE
        if dn and not up: col = W_EDGE if edge else W_SHADE
        elif up and not dn: col = W_GLOSS
        elif not up and not dn and (x + y) % 6 == 0: col = W_SHADE
        o.p(x, y, col)

def bib(cv, M):
    f = M['frame']; ox, oy = M['ox'], M['oy']
    if f in ('idleA', 'catch'): return cv.ellipse(24, 45, 5.5, 10) & (cv.own == 'torso')
    if f == 'pounce': return cv.ellipse(26, 37, 11, 3.2) & (cv.own == 'torso')
    return cv.ellipse(46, 53, 9, 4) & (cv.own == 'torso')

def tuxedo(cv, M):
    o = Ov(cv); ox, oy = M['ox'], M['oy']
    W = (cv.ellipse(25 + ox, 28 + oy, 6.5, 4.8) & (cv.own == 'head')) | bib(cv, M) | (cv.own == 'paw')
    W |= cv.poly([(24 + ox, 25 + oy), (26 + ox, 25 + oy), (26 + ox, 14 + oy), (24 + ox, 14 + oy)]) & (cv.own == 'head') & False
    patch(o, W)
    return o

def calico(cv, M):
    o = Ov(cv); ox, oy = M['ox'], M['oy']
    f = M['frame']
    D = (cv.ellipse(13 + ox, 10 + oy, 9, 7) & o.lab('head', 'ear'))
    S = cv.ellipse(38 + ox, 12 + oy, 6, 5) & o.lab('head', 'ear')
    if f in ('idleA', 'catch'): D |= cv.ellipse(31, 40, 8, 8) & (cv.own == 'torso'); S |= cv.ellipse(15, 51, 5, 4) & o.lab('haunch', 'torso')
    elif f == 'pounce': D |= cv.ellipse(30, 31, 9, 6) & (cv.own == 'torso'); S |= cv.ellipse(14, 37, 5, 5) & o.lab('haunch')
    else: D |= cv.ellipse(50, 42, 8, 6) & (cv.own == 'torso'); S |= cv.ellipse(42, 55, 6, 3) & o.lab('tail')
    D |= (np.isin(cv.own, ['tail']) & ((np.arange(64)[None, :] + np.arange(64)[:, None]) % 17 < 6))
    for y, x in zip(*np.nonzero(S & o.ok)): o.p(x, y, SHADE)
    for y, x in zip(*np.nonzero(D & o.ok)):
        o.p(x, y, SHADE if (not D[y, x - 1] or not D[y - 1, x]) else DEEP)
    Wm = (cv.ellipse(25 + ox, 28 + oy, 6, 4.5) & (cv.own == 'head')) | bib(cv, M) | (cv.own == 'paw')
    patch(o, Wm)
    return o

def pointed(cv, M):
    o = Ov(cv); ox, oy = M['ox'], M['oy']
    face = cv.ellipse(25 + ox, 22 + oy, 8.5, 5.5) & (cv.own == 'head')
    for y, x in zip(*np.nonzero(face)):
        d = math.hypot((x - 25 - ox) / 8.5, (y - 22 - oy) / 5.5)
        o.p(x, y, DEEP if d < 0.62 else SHADE)
    for y, x in zip(*np.nonzero(o.lab('ear'))):
        o.p(x, y, DEEP if y < 9 + oy else SHADE)
    for y, x in zip(*np.nonzero(o.lab('paw'))): o.p(x, y, DEEP if (x + y) % 3 else SHADE)
    for y, x in zip(*np.nonzero(o.lab('tail'))):
        d = math.hypot(x - M['tailend'][0], y - M['tailend'][1])
        if d < 11: o.p(x, y, DEEP if d < 7 else SHADE)
    for y, x in zip(*np.nonzero(bib(cv, M) & o.ok)): o.p(x, y, LIGHT if (x + 2 * y) % 5 else GLOSS)
    return o

def masks(cv):
    ear = cv.own == 'ear'
    head = cv.own == 'head'
    ink = cv.own == 'ink'
    earm = ear | (ink & cv.grow(ear) & ~cv.grow(head))
    earm |= ear
    tl = cv.own == 'tail'
    oth = np.isin(cv.own, ['torso', 'haunch', 'leg', 'paw', 'arm', 'head', 'fish'])
    tailm = tl | (ink & cv.grow(tl) & ~cv.grow(oth))
    return earm, tailm

def save_mask(m, path):
    a = np.zeros((64, 64, 4), np.uint8); a[m] = (255, 255, 255, 255); Image.fromarray(a, 'RGBA').save(path)

def folded(cv, M, rich):
    R, cuts, rim = style(rich)
    L = Cv2(64, 64, R, cuts, rim); ox, oy = M['ox'], M['oy']
    for side in (0, 1):
        f = (lambda x: x) if side == 0 else (lambda x: 50 - x)
        fl = L.poly([(f(x) + ox, y + oy) for x, y in [(9, 11), (10, 8), (13, 6), (18, 8), (19, 11), (16, 13), (11, 13)]])
        fl |= L.poly([(f(x) + ox, y + oy) for x, y in [(9, 11), (8, 14), (12, 13)]])
        L.pt(fl, 'ear', ao=0, k=1.0)
        for (x, y) in [(10, 9), (11, 8), (12, 7), (13, 7), (14, 7)]: L.set(f(x) + ox, y + oy, G['gloss'] if side == 0 else G['light'])
        for (x, y) in [(10, 12), (11, 12), (12, 12), (14, 12), (16, 11), (17, 10)]: L.set(f(x) + ox, y + oy, G['shade'])
        for (x, y) in [(15, 10), (16, 9), (14, 9), (15, 9)]: L.set(f(x) + ox, y + oy, PINK)
        L.set(f(15) + ox, 10 + oy, PINKD)
    L.outline2()
    return L

def bobtail(cv, M, rich, tailm):
    R, cuts, rim = style(rich)
    L = Cv2(64, 64, R, cuts, rim)
    sx, sy = M['stub']
    st = L.ellipse(sx, sy, 4.3, 3.4)
    L.pt(st, 'tail', ao=0, k=1.0)
    L.set(sx - 1, sy - 1, G['light']); L.set(sx - 2, sy, G['light']); L.set(sx + 2, sy + 1, G['shade'])
    ring = L.grow(L.a) & ~L.a
    keep = ring & ~(cv.a & ~tailm)
    L.rgb[keep] = INK; L.a[keep] = True
    return L

def write(L, path):
    L.save(path)

def main(outdir, rich):
    os.makedirs(outdir + 'overlays', exist_ok=True)
    for fr in ('idleA', 'pounce', 'catch', 'nap'):
        cv, M = build(fr, rich)
        n = cv.check()
        cv.save(outdir + 'cf-cat-grey-%s.png' % fr)
        print(fr, n, 'colours')
        for nm, fn in (('tabby', tabby), ('tuxedo', tuxedo), ('calico', calico), ('pointed', pointed), ('spotted', spotted)):
            o = fn(cv, M); o.save(outdir + 'overlays/cf-pat-%s-grey-%s.png' % (nm, fr))
        earm, tailm = masks(cv)
        save_mask(earm, outdir + 'overlays/cf-ears-mask-%s.png' % fr); save_mask(tailm, outdir + 'overlays/cf-tail-mask-%s.png' % fr)
        folded(cv, M, rich).save(outdir + 'overlays/cf-ears-folded-%s.png' % fr)
        bobtail(cv, M, rich, tailm).save(outdir + 'overlays/cf-tail-bobtail-%s.png' % fr)

if __name__ == '__main__':
    for name, rich in (('polish', False), ('rich', True)):
        main(HERE + name + '/', rich)
