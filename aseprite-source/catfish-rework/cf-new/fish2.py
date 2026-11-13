import sys, os, math, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib2 import *
BASE = os.path.dirname(os.path.abspath(__file__)) + '/'
CR = '#fff4d6'
ORA = ['#8a2c22', '#c4491f', '#dc6f2c', '#f08a3a', '#ffc27a', '#fff1c8']
PET = ['#7d2c5e', '#b0407a', '#c94f84', '#f5809f', '#ffc4d8', '#fff0f5']
MOS = ['#24544a', '#3f9150', '#4f9f52', '#7cc35a', '#c4e07a', '#eef8c0']
BLU = ['#262f6e', '#3a4ab0', '#4a63cf', '#5f86ea', '#a8c8ff', '#e8f2ff']
VIO = ['#35295f', '#5a459e', '#6f58b8', '#8a6fd0', '#c9b2f0', '#efe6fc']
GLD = ['#8f4a1f', '#d98322', '#e89a26', '#f5b82e', '#ffe38a', '#fff6c8']
CUTS = (0.22, 0.38, 0.52, 0.76, 0.92)

def rell(cv, cx, cy, rx, ry, ang):
    y, x = np.mgrid[0:cv.h, 0:cv.w]; c, s = math.cos(ang), math.sin(ang)
    u = (x - cx) * c + (y - cy) * s; v = -(x - cx) * s + (y - cy) * c
    return (u / rx) ** 2 + (v / ry) ** 2 <= 1.0

def new(): return Cv2(48, 48, ORA, CUTS)
def part(cv, m, ramp, label, k=1.0, ao=1, **kw):
    cv.R = ramp; cv.pt(m, label, ao=ao, k=k, **kw)
def px(cv, pts, col):
    for p in pts: cv.set(p[0], p[1], col)
def seg(cv, x0, y0, x1, y1, col, only=None, rmin=0):
    n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in range(n + 1):
        x, y = round(x0 + (x1 - x0) * i / n), round(y0 + (y1 - y0) * i / n)
        if math.hypot(x - x0, y - y0) < rmin: continue
        if only is None or only[y, x]: cv.set(x, y, col)

def eye(cv, x, y, rich):
    if rich:   # bead eye, 3x3 with a glint and a faint warm bounce
        px(cv, [(x + i, y + j) for i in range(3) for j in range(3)], '#2b1c26')
        cv.set(x, y, CR); cv.set(x + 2, y + 2, '#5a4560')
    else:
        px(cv, [(x, y), (x + 1, y), (x, y + 1), (x + 1, y + 1)], '#2b1c26'); cv.set(x, y, CR)

def scallops(cv, label, ramp, x0, x1, y0, y1, rows=3):
    for r in range(rows):
        y = y0 + r * 3
        for x in range(x0 + (r % 2) * 2, x1, 4):
            if all(0 <= yy < 48 and cv.own[yy, xx] == label for xx, yy in ((x, y), (x + 1, y + 1), (x + 2, y))):
                cv.set(x, y, ramp[2], lock=False); cv.set(x + 1, y + 1, ramp[2], lock=False); cv.set(x + 2, y, ramp[2], lock=False)

def grain(cv, label, ramp):
    for y, x in zip(*np.nonzero(cv.own == label)):
        if cv.lock[y, x] or (x + 2 * y) % 5: continue
        i = cv.idx[y, x]
        if i in (3, 4): cv.rgb[y, x] = hx(ramp[i - 1]); cv.idx[y, x] = i - 1
def lighten(cv, m, idxs, ramp):
    for y, x in zip(*np.nonzero(m)):
        if not cv.lock[y, x] and cv.idx[y, x] in idxs:
            j = min(5, cv.idx[y, x] + 1); cv.rgb[y, x] = hx(ramp[j]); cv.idx[y, x] = j

def rays(cv, m, ramp, ax, ay, targets, rmin=3.5):
    for (tx, ty) in targets: seg(cv, ax, ay, tx, ty, ramp[1], only=m & (cv.own == 'fin') | m, rmin=rmin)

def fin_fade(cv, m, ramp, ax, ay, rr):
    """translucency fake: outer part of the fin one tone lighter (2 tones: body-side deeper, edge paler)"""
    y, x = np.mgrid[0:48, 0:48]
    far = m & (np.hypot(x - ax, y - ay) > rr)
    lighten(cv, far, (2, 3, 4), ramp)

def save(cv, path, name):
    cv.outline2(); c = cv.check(); cv.save(path + name + '.png'); print(path.split('/')[-2], name, c)

def belly(cv, body, ramp, cx, cy, rx, ry, ang=0):
    b = rell(cv, cx, cy, rx, ry, ang) & body
    for y, x in zip(*np.nonzero(b)):
        if not cv.lock[y, x]: cv.rgb[y, x] = hx(ramp[4]); cv.idx[y, x] = 4

def fish1(cv, rich):
    cv.R = ORA
    tail = cv.poly([(33, 24), (45, 14), (42, 24), (45, 34)]); part(cv, tail, ORA, 'fin', 1.2)
    dors = cv.poly([(15, 17), (21, 9), (30, 17)]); part(cv, dors, ORA, 'fin', 1.2)
    belly_f = cv.poly([(19, 30), (23, 37), (28, 30)]); part(cv, belly_f, ORA, 'fin', 1.2)
    if rich:
        fin_fade(cv, tail, ORA, 33, 24, 6); fin_fade(cv, dors, ORA, 22, 17, 4); fin_fade(cv, belly_f, ORA, 23, 30, 3)
        for t in [(44, 15), (44, 20), (44, 28), (44, 33)]: seg(cv, 34, 24, t[0], t[1], ORA[1], only=tail, rmin=3)
        for t in [(17, 11), (21, 10), (26, 11), (29, 14)]: seg(cv, 22, 17, t[0], t[1], ORA[1], only=dors, rmin=2)
        seg(cv, 23, 31, 23, 36, ORA[1], only=belly_f)
    else:
        px(cv, [(39, 19), (40, 17), (41, 16), (39, 29), (40, 31), (41, 32)], ORA[1])
        px(cv, [(21, 12), (22, 14), (24, 12), (25, 14)], ORA[1])
    body = rell(cv, 21, 24, 15.5, 8.2, 0); part(cv, body, ORA, 'body', 0.9)
    scallops(cv, 'body', ORA, 16, 33, 20, 31, 4 if rich else 3)
    belly(cv, body, ORA, 20, 29, 9, 2.2)
    if rich:
        grain(cv, 'body', ORA)
        belly(cv, body, ORA, 20, 29.5, 8, 1.2)
        for p in [(18, 28), (22, 29), (26, 28)]: cv.set(*p, ORA[5])
        for x in range(12, 32, 3): cv.set(x, 17 if x % 2 else 18, ORA[5])   # sheen along the back
        for p in [(30, 20), (31, 21), (33, 24)]: cv.set(*p, ORA[1])   # tail root shadow
    px(cv, [(17, 19), (18, 20), (19, 22), (19, 24), (19, 26), (18, 28)], ORA[0])
    pect = rell(cv, 22, 27, 4.5, 2.2, -0.5); part(cv, pect, ORA, 'fin', 1.3)
    if rich: fin_fade(cv, pect, ORA, 20, 28, 2.5)
    eye(cv, 10 if rich else 11, 20 if rich else 21, rich); cv.set(8, 25, ORA[0]); cv.set(9, 25, ORA[0])
    px(cv, [(11, 17), (12, 17), (13, 17), (9, 19)] if not rich else [(12, 16), (13, 16), (14, 16), (9, 18)], ORA[5]); px(cv, [(16, 18), (17, 18)], ORA[5])
    b = cv.ellipse(4.5, 22.5, 1.6, 1.6); cv.flat(b, '#b6f0e0'); cv.set(4, 22, CR)
    return 'cf-fish-1'

def fish2(cv, rich):
    s1 = cv.line([(31, 22), (38, 18), (43, 22), (40, 30), (43, 37)], 5.0, 2.0)
    s2 = cv.line([(32, 26), (38, 30), (36, 38), (30, 43)], 4.5, 1.6)
    part(cv, s2, PET, 'fin', 1.2); part(cv, s1, PET, 'fin', 1.2)
    if rich:   # silk ribbon: lighter edge sheen + fold lines
        for (x0, y0, x1, y1) in [(33, 21, 38, 19), (39, 19, 42, 22), (41, 24, 40, 28), (35, 29, 37, 34), (35, 36, 32, 41)]: seg(cv, x0, y0, x1, y1, PET[5], only=cv.own == 'fin')
        for (x0, y0, x1, y1) in [(34, 24, 40, 21), (36, 31, 41, 33), (37, 33, 34, 38)]: seg(cv, x0, y0, x1, y1, PET[1], only=cv.own == 'fin')
        fin_fade(cv, s1 | s2, PET, 31, 24, 9)
    else:
        for p in [(40, 20), (41, 24), (39, 27), (42, 33), (35, 34), (34, 39)]: cv.set(*p, PET[5])
    body = rell(cv, 19, 24, 14, 7.2, 0.12); part(cv, body, PET, 'body', 0.9)
    bl = rell(cv, 20, 21, 9, 1.4, 0.12)
    for y, x in zip(*np.nonzero(bl & body)): cv.rgb[y, x] = hx(PET[5]); cv.idx[y, x] = 5
    fin = cv.poly([(17, 17), (22, 8), (29, 14), (26, 19)]); part(cv, fin, PET, 'fin', 1.2)
    pv = cv.poly([(16, 30), (14, 38), (21, 32)]); part(cv, pv, PET, 'fin', 1.2)
    if rich:
        fin_fade(cv, fin, PET, 22, 18, 5); fin_fade(cv, pv, PET, 18, 31, 3)
        for t in [(22, 9), (25, 10), (28, 14)]: seg(cv, 22, 18, t[0], t[1], PET[1], only=fin, rmin=3)
        seg(cv, 17, 32, 15, 37, PET[1], only=pv)
        grain(cv, 'body', PET); belly(cv, body, PET, 18, 28, 8, 1.6, 0.12)
    scallops(cv, 'body', PET, 14, 30, 22, 31, 3)
    px(cv, [(15, 18), (16, 19), (16, 21), (16, 24), (16, 27), (15, 29)], PET[0])
    px(cv, [(30, 22), (31, 21), (30, 24), (31, 25), (32, 23)], PET[4]); px(cv, [(31, 23)], PET[1])
    eye(cv, 7 if rich else 8, 20 if rich else 21, rich); px(cv, [(5, 25), (6, 25)], PET[0]); px(cv, [(9, 17), (10, 17), (12, 17)], PET[5])
    return 'cf-fish-2'

def fish3(cv, rich):
    leaf = cv.poly([(30, 24), (36, 14), (44, 11), (46, 18), (42, 28), (36, 33)])
    part(cv, leaf, MOS, 'fin', 1.2)
    for (x0, y0, x1, y1) in [(31, 24, 44, 14), (35, 20, 38, 15), (38, 22, 42, 18), (35, 26, 38, 30), (37, 23, 41, 26)]:
        seg(cv, x0, y0, x1, y1, MOS[1] if (x0, y0, x1, y1) != (31, 24, 44, 14) else MOS[0], only=leaf)
    if rich:
        fin_fade(cv, leaf, MOS, 31, 24, 8)
        for (x0, y0, x1, y1) in [(40, 18, 44, 15), (39, 25, 43, 24), (37, 29, 41, 29)]: seg(cv, x0, y0, x1, y1, MOS[1], only=leaf)
    body = rell(cv, 20, 25, 14, 9.5, 0); part(cv, body, MOS, 'body', 0.9)
    for (cx, cy) in [(18, 25), (23, 22), (23, 28), (28, 25), (18, 31)] + ([(14, 27), (28, 30), (13, 21)] if rich else []):
        if cv.own[cy, cx] != 'body': continue
        px(cv, [(cx, cy - 1), (cx - 1, cy), (cx + 1, cy)], MOS[4]); px(cv, [(cx, cy + 1)], MOS[1])
        if rich: cv.set(cx, cy, MOS[2])   # catnip-leaf diamond with its own vein
    belly(cv, body, MOS, 19, 31, 8, 2)
    fin = rell(cv, 21, 33, 4.2, 2.4, 0.5); part(cv, fin, MOS, 'fin', 1.3)
    st = cv.line([(14, 16), (13, 11)], 1.6); part(cv, st, MOS, 'fin', 1.0)
    l1 = rell(cv, 9, 9, 3.8, 2.0, -0.5); l2 = rell(cv, 17, 8, 3.8, 2.0, 0.5)
    part(cv, l1, MOS, 'fin', 1.3); part(cv, l2, MOS, 'fin', 1.3)
    px(cv, [(8, 9), (9, 9), (15, 8), (16, 8)], MOS[1])
    if rich:
        grain(cv, 'body', MOS); belly(cv, body, MOS, 19, 31.5, 7, 1.2)
        for p in [(14, 18), (16, 17), (22, 17), (26, 18)]: cv.set(*p, MOS[5])
    eye(cv, 10 if rich else 11, 21 if rich else 22, rich); px(cv, [(10, 17), (11, 17), (12, 17), (8, 19)], MOS[5])
    bud = cv.ellipse(5, 25, 2, 1.7); cv.flat(bud, '#f5809f'); cv.set(5, 24, '#ffc4d8'); cv.set(6, 26, '#c94f84')
    return 'cf-fish-3'

def fish4(cv, rich):
    tail = cv.poly([(34, 25), (45, 12), (41, 25), (45, 38)]); part(cv, tail, VIO, 'fin', 1.2)
    comb = cv.poly([(11, 19), (13, 10), (16, 16), (19, 8), (22, 16), (26, 9), (28, 16), (31, 12), (32, 20)]); part(cv, comb, VIO, 'fin', 1.2)
    anal = cv.poly([(24, 31), (31, 37), (31, 29)]); part(cv, anal, VIO, 'fin', 1.3)
    if rich:
        fin_fade(cv, tail, VIO, 34, 25, 6); fin_fade(cv, comb, VIO, 22, 19, 6); fin_fade(cv, anal, VIO, 25, 30, 3)
        for t in [(44, 14), (43, 20), (43, 30), (44, 36)]: seg(cv, 35, 25, t[0], t[1], VIO[1], only=tail, rmin=3)
        for x in (13, 19, 26, 31): seg(cv, x, 18, x, 12, VIO[5], only=comb)
    else:
        px(cv, [(40, 18), (41, 16), (40, 31), (41, 33)], VIO[1]); px(cv, [(14, 13), (19, 12), (26, 13)], VIO[5])
    body = rell(cv, 21, 25, 17, 7.2, 0.0); part(cv, body, BLU, 'body', 0.9)
    bl = rell(cv, 20, 29, 11, 1.8, 0)
    for y, x in zip(*np.nonzero(bl & body)): cv.rgb[y, x] = hx(BLU[4]); cv.idx[y, x] = 4
    if rich:
        grain(cv, 'body', BLU)
        for (cx, cy) in [(18, 23), (27, 26), (23, 20), (31, 22), (13, 26), (34, 27)]:
            px(cv, [(cx, cy), (cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)], BLU[5])
            cv.set(cx - 2, cy, BLU[4]); cv.set(cx + 2, cy, BLU[4]); cv.set(cx, cy - 2, BLU[4]); cv.set(cx, cy + 2, BLU[4])
        px(cv, [(14, 22), (22, 28), (29, 28), (20, 22), (25, 29), (34, 24), (11, 28)], BLU[5])
    else:
        for (cx, cy) in [(18, 23), (27, 26), (23, 20), (31, 22)]:
            px(cv, [(cx, cy), (cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)], BLU[5])
        px(cv, [(14, 27), (22, 28), (29, 28)], BLU[5]); px(cv, [(26, 22), (33, 26), (16, 21)], BLU[4])
    px(cv, [(24, 25), (25, 25), (24, 24), (25, 26), (26, 24)], '#f5809f'); px(cv, [(24, 25)], '#ffc4d8')
    px(cv, [(15, 18), (16, 19), (16, 22), (16, 25), (16, 28), (15, 31)], BLU[0])
    eye(cv, 8 if rich else 9, 21 if rich else 22, rich); px(cv, [(6, 26), (7, 26)], BLU[0]); px(cv, [(8, 18), (9, 18), (10, 18)] if rich else [(8, 19), (9, 19), (10, 19)], BLU[5])
    return 'cf-fish-4'

def fish5(cv, rich):
    fan = cv.poly([(32, 28), (44, 17), (46, 25), (45, 35), (40, 40)]); part(cv, fan, GLD, 'fin', 1.2)
    for (x0, y0, x1, y1) in [(33, 28, 44, 20), (34, 29, 45, 27), (34, 30, 42, 37)]: seg(cv, x0, y0, x1, y1, GLD[1], only=fan)
    px(cv, [(44, 19), (45, 24), (44, 32)], GLD[5])
    if rich:
        fin_fade(cv, fan, GLD, 33, 28, 7)
        for (x0, y0, x1, y1) in [(34, 27, 45, 22), (34, 29, 44, 31), (34, 30, 42, 33)]: seg(cv, x0, y0, x1, y1, GLD[1], only=fan, rmin=3)
    body = rell(cv, 21, 27, 14.5, 9.8, -0.25); part(cv, body, GLD, 'body', 0.9)
    belly(cv, body, GLD, 19, 32, 9, 2, -0.25)
    # regular scale bands (rows of scallops) instead of scattered ticks
    scallops(cv, 'body', GLD, 18, 33, 24, 34, 4 if rich else 3)
    fin = cv.poly([(17, 34), (22, 42), (26, 33)]); part(cv, fin, GLD, 'fin', 1.3)
    px(cv, [(15, 21), (16, 22), (17, 25), (17, 28), (16, 31), (15, 33)], GLD[0])
    if rich:
        fin_fade(cv, fin, GLD, 22, 34, 3); grain(cv, 'body', GLD); belly(cv, body, GLD, 19, 32.5, 8, 1.2, -0.25)
        for p in [(27, 21), (29, 22), (22, 20), (14, 25)]: cv.set(*p, GLD[5])   # gold gleam
        seg(cv, 25, 19, 31, 22, GLD[5], only=cv.own == 'body')
    # monocle: dark ring + pale glass around the eye + chain (clear at 25%)
    ex, ey = 10, 26
    glass = cv.ellipse(ex + 1.5, ey + 1.5, 4.3, 4.3)
    for y, x in zip(*np.nonzero(glass)): cv.set(x, y, '#e4f6ff')
    ring = cv.grow(glass) & ~glass
    for y, x in zip(*np.nonzero(ring)): cv.set(x, y, GLD[0])
    eye(cv, ex, ey, rich)
    cv.set(ex - 2, ey - 1, '#ffffff' if False else CR)
    px(cv, [(13, 31), (14, 32), (14, 34), (15, 35)], GLD[0])
    px(cv, [(7, 31), (8, 31)], GLD[0])
    # crown: tall 3-point band with gem, separated from the head by a dark line
    crown = cv.poly([(9, 21), (9, 10), (12, 14), (16, 7), (20, 14), (24, 10), (24, 21)])
    part(cv, crown, GLD, 'crown', 1.1, ao=1)
    for x in range(10, 24): cv.set(x, 18, GLD[0]); cv.set(x, 19, GLD[4] if x % 2 else GLD[3])
    for x in range(10, 24): cv.set(x, 20, GLD[1])
    px(cv, [(9, 11), (10, 12), (16, 8), (16, 9), (24, 11)], GLD[5])
    px(cv, [(15, 15), (16, 15), (17, 15), (16, 16), (16, 14)], '#e8493b'); cv.set(15, 14, '#ffc4d8'); cv.set(16, 14, '#ff8a5c')
    return 'cf-fish-5'

def main(outdir, rich):
    for f in (fish1, fish2, fish3, fish4, fish5):
        cv = new()
        name = f(cv, rich)
        save(cv, outdir, name)

if __name__ == '__main__':
    for name, rich in (('polish', False), ('rich', True)):
        main(BASE + name + '/', rich)
