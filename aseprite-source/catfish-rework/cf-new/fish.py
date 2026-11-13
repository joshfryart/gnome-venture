import sys, os, math, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import *
OUT = os.path.dirname(os.path.abspath(__file__)) + '/'
CR = '#fff4d6'
ORA = ['#ac3b1d', '#dc6f2c', '#e38111', '#f2a860', '#ffc27a', '#fff1c8']
ORA = ['#8a2c22', '#c4491f', '#dc6f2c', '#f08a3a', '#ffc27a', '#fff1c8']
PET = ['#7d2c5e', '#b0407a', '#c94f84', '#f5809f', '#ffc4d8', '#fff0f5']
MOS = ['#24544a', '#3f9150', '#4f9f52', '#7cc35a', '#c4e07a', '#eef8c0']
BLU = ['#262f6e', '#3a4ab0', '#4a63cf', '#5f86ea', '#a8c8ff', '#e8f2ff']
VIO = ['#35295f', '#5a459e', '#6f58b8', '#8a6fd0', '#c9b2f0', '#efe6fc']
GLD = ['#8f4a1f', '#d98322', '#e89a26', '#f5b82e', '#ffe38a', '#fff6c8']

def rell(cv, cx, cy, rx, ry, ang):
    y, x = np.mgrid[0:cv.h, 0:cv.w]; c, s = math.cos(ang), math.sin(ang)
    u = (x - cx) * c + (y - cy) * s; v = -(x - cx) * s + (y - cy) * c
    return (u / rx) ** 2 + (v / ry) ** 2 <= 1.0

def part(cv, m, ramp, **kw):
    prev = cv.a.copy(); cv.tone(m, ramp, **kw); cv.ao(m, prev, ramp, 1)

def px(cv, pts, col, idx=None):
    for p in pts: cv.put(p[0], p[1], col, lock=True)

def eye(cv, x, y, ring=None):
    px(cv, [(x, y), (x + 1, y), (x, y + 1), (x + 1, y + 1)], '#2b1c26')
    cv.put(x, y, CR, lock=True)

def scales(cv, body, ramp, x0, x1, y0, y1, step=3):
    for y in range(y0, y1, step):
        for x in range(x0 + ((y - y0) // step % 2) * 2, x1, 4):
            if body[y, x] and body[y, x + 1]:
                cv.put(x, y, ramp[2], lock=False, idx=2); cv.put(x + 1, y + 1, ramp[2], idx=2)

def save(cv, n):
    cv.outline(); c = cv.check(); cv.save(OUT + n + '.png'); print(n, c)

def fish1():  # plain: spindle body, forked tail, bubble on the lips (quirk)
    cv = Cv(48, 48)
    tail = cv.poly([(33, 24), (45, 14), (42, 24), (45, 34)])
    part(cv, tail, ORA, k=1.2)
    px(cv, [(39, 19), (40, 17), (41, 16), (39, 29), (40, 31), (41, 32)], ORA[1])
    dors = cv.poly([(15, 17), (21, 9), (30, 17)]); part(cv, dors, ORA, k=1.2)
    px(cv, [(21, 12), (22, 14), (24, 12), (25, 14)], ORA[1])
    belly = cv.poly([(19, 30), (23, 37), (28, 30)]); part(cv, belly, ORA, k=1.2)
    body = rell(cv, 21, 24, 15.5, 8.2, 0)
    part(cv, body, ORA, k=0.9)
    sc = scales(cv, body, ORA, 17, 33, 20, 31)
    bl = rell(cv, 20, 29, 9, 2.2, 0)
    for y, x in zip(*np.nonzero(bl & body)): cv.rgb[y, x] = hx(ORA[4]); cv.idx[y, x] = 4
    px(cv, [(17, 19), (18, 20), (19, 22), (19, 24), (19, 26), (18, 28)], ORA[0])   # gill
    pect = rell(cv, 22, 27, 4.5, 2.2, -0.5); part(cv, pect, ORA, k=1.3)
    eye(cv, 11, 21); cv.put(8, 25, ORA[0], lock=True); cv.put(9, 25, ORA[0], lock=True)
    px(cv, [(11, 17), (12, 17), (13, 17), (9, 19)], ORA[5])        # glossy head spec
    px(cv, [(16, 18), (17, 18)], ORA[5])
    b = cv.ellipse(4.5, 22.5, 1.6, 1.6); cv.flat(b, '#b6f0e0'); cv.put(4, 22, CR, lock=True)   # bubble
    save(cv, 'cf-fish-1')

def fish2():  # silk-tail: slim petal body, long flowing silk tail with two streamers + knot (quirk: tied bow)
    cv = Cv(48, 48)
    s1 = cv.line([(31, 22), (38, 18), (43, 22), (40, 30), (43, 37)], 5.0, 2.0)
    s2 = cv.line([(32, 26), (38, 30), (36, 38), (30, 43)], 4.5, 1.6)
    part(cv, s2, PET, k=1.2); part(cv, s1, PET, k=1.2)
    for p in [(40, 20), (41, 24), (39, 27), (42, 33), (35, 34), (34, 39)]: cv.put(*p, PET[5], lock=True)
    body = rell(cv, 19, 24, 14, 7.2, 0.12)
    part(cv, body, PET, k=0.9)
    # silk sheen band
    bl = rell(cv, 20, 21, 9, 1.4, 0.12)
    for y, x in zip(*np.nonzero(bl & body)): cv.rgb[y, x] = hx(PET[5]); cv.idx[y, x] = 5
    fin = cv.poly([(17, 17), (22, 8), (29, 14), (26, 19)]); part(cv, fin, PET, k=1.2)
    px(cv, [(23, 11), (24, 13), (26, 14)], PET[1])
    pv = cv.poly([(16, 30), (14, 38), (21, 32)]); part(cv, pv, PET, k=1.2)
    scales(cv, body, PET, 14, 30, 22, 31)
    px(cv, [(15, 18), (16, 19), (16, 21), (16, 24), (16, 27), (15, 29)], PET[0])
    # silk bow knot where tail meets body
    px(cv, [(30, 22), (31, 21), (30, 24), (31, 25), (32, 23)], PET[4]); px(cv, [(31, 23)], PET[1])
    eye(cv, 8, 21); px(cv, [(5, 25), (6, 25)], PET[0]); px(cv, [(9, 17), (10, 17), (12, 17)], PET[5])
    save(cv, 'cf-fish-2')

def fish3():  # catnip: round green tub, big leaf for a tail, sprig on the head, quirk: a catnip bud on the nose
    cv = Cv(48, 48)
    # leaf tail with midrib + veins
    leaf = cv.poly([(30, 24), (36, 14), (44, 11), (46, 18), (42, 28), (36, 33)])
    part(cv, leaf, MOS, k=1.2)
    for (x0, y0, x1, y1) in [(31, 24, 44, 14), (35, 20, 38, 15), (38, 22, 42, 18), (35, 26, 38, 30), (37, 23, 41, 26)]:
        n = max(abs(x1 - x0), abs(y1 - y0))
        for i in range(n + 1):
            xx, yy = round(x0 + (x1 - x0) * i / n), round(y0 + (y1 - y0) * i / n)
            if leaf[yy, xx]: cv.put(xx, yy, MOS[1] if (x0, y0, x1, y1) != (31, 24, 44, 14) else MOS[0], lock=True)
    body = rell(cv, 20, 25, 14, 9.5, 0)
    part(cv, body, MOS, k=0.9)
    # catnip-leaf scale diamonds
    for (cx, cy) in [(18, 25), (23, 22), (23, 28), (28, 25), (18, 31)]:
        px(cv, [(cx, cy - 1), (cx - 1, cy), (cx + 1, cy)], MOS[4]); px(cv, [(cx, cy + 1)], MOS[1])
    bl = rell(cv, 19, 31, 8, 2, 0)
    for y, x in zip(*np.nonzero(bl & body)): cv.rgb[y, x] = hx(MOS[4]); cv.idx[y, x] = 4
    fin = rell(cv, 21, 33, 4.2, 2.4, 0.5); part(cv, fin, MOS, k=1.3)
    # sprig on head: stem + two leaves
    st = cv.line([(14, 16), (13, 11)], 1.6); part(cv, st, MOS, k=1.0)
    l1 = rell(cv, 9, 9, 3.8, 2.0, -0.5); l2 = rell(cv, 17, 8, 3.8, 2.0, 0.5)
    part(cv, l1, MOS, k=1.3); part(cv, l2, MOS, k=1.3)
    px(cv, [(8, 9), (9, 9), (15, 8), (16, 8)], MOS[1])
    eye(cv, 11, 22); px(cv, [(10, 18), (11, 18), (12, 18), (8, 20)], MOS[5])
    # quirk: pink catnip bud on the nose
    bud = cv.ellipse(5, 25, 2, 1.7); cv.flat(bud, '#f5809f'); cv.put(5, 24, '#ffc4d8', lock=True); cv.put(6, 26, '#c94f84', lock=True)
    save(cv, 'cf-fish-3')

def fish4():  # glitter: long torpedo, tall spiky comb fin, violet swallow tail, star sparkles, quirk: one heart scale
    cv = Cv(48, 48)
    tail = cv.poly([(34, 25), (45, 12), (41, 25), (45, 38)]); part(cv, tail, VIO, k=1.2)
    px(cv, [(40, 18), (41, 16), (40, 31), (41, 33)], VIO[1])
    comb = cv.poly([(11, 19), (13, 10), (16, 16), (19, 8), (22, 16), (26, 9), (28, 16), (31, 12), (32, 20)])
    part(cv, comb, VIO, k=1.2)
    px(cv, [(14, 13), (19, 12), (26, 13)], VIO[5])
    body = rell(cv, 21, 25, 17, 7.2, 0.0)
    part(cv, body, BLU, k=0.9)
    anal = cv.poly([(24, 31), (31, 37), (31, 29)]); part(cv, anal, VIO, k=1.3)
    bl = rell(cv, 20, 29, 11, 1.8, 0)
    for y, x in zip(*np.nonzero(bl & body)): cv.rgb[y, x] = hx(BLU[4]); cv.idx[y, x] = 4
    # sparkles: tiny + stars
    for (cx, cy) in [(18, 23), (27, 26), (23, 20), (31, 22)]:
        px(cv, [(cx, cy), (cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)], BLU[5])
    px(cv, [(14, 27), (22, 28), (29, 28)], BLU[5]); px(cv, [(26, 22), (33, 26), (16, 21)], BLU[4])
    px(cv, [(24, 25), (25, 25), (24, 24)], '#f5809f'); cv.put(25, 26, '#f5809f', lock=True); cv.put(26, 24, '#f5809f', lock=True)  # heart scale (quirk)
    px(cv, [(24, 25)], '#ffc4d8')
    px(cv, [(15, 18), (16, 19), (16, 22), (16, 25), (16, 28), (15, 31)], BLU[0])
    eye(cv, 9, 22); px(cv, [(6, 26), (7, 26)], BLU[0]); px(cv, [(8, 19), (9, 19), (10, 19)], BLU[5])
    save(cv, 'cf-fish-4')

def fish5():  # golden: plump tilted body, big fan tail with ruby, crown + monocle (quirk)
    cv = Cv(48, 48)
    fan = cv.poly([(32, 28), (44, 17), (46, 25), (45, 35), (40, 40)]); part(cv, fan, GLD, k=1.2)
    for (x0, y0, x1, y1) in [(33, 28, 44, 20), (34, 29, 45, 27), (34, 30, 42, 37)]:
        n = max(abs(x1 - x0), abs(y1 - y0))
        for i in range(n + 1):
            xx, yy = round(x0 + (x1 - x0) * i / n), round(y0 + (y1 - y0) * i / n)
            if fan[yy, xx]: cv.put(xx, yy, GLD[1], lock=True)
    px(cv, [(44, 19), (45, 24), (44, 32)], GLD[5])
    body = rell(cv, 21, 27, 14.5, 9.8, -0.25)
    part(cv, body, GLD, k=0.9)
    bl = rell(cv, 19, 32, 9, 2, -0.25)
    for y, x in zip(*np.nonzero(bl & body)): cv.rgb[y, x] = hx(GLD[4]); cv.idx[y, x] = 4
    scales(cv, body, GLD, 18, 33, 24, 34)
    fin = cv.poly([(17, 34), (22, 42), (26, 33)]); part(cv, fin, GLD, k=1.3)
    px(cv, [(15, 21), (16, 22), (17, 25), (17, 28), (16, 31), (15, 33)], GLD[0])
    eye(cv, 11, 26); px(cv, [(7, 30), (8, 30)], GLD[0]); px(cv, [(11, 21), (12, 21), (14, 20)], GLD[5])
    # monocle ring (quirk) around the eye
    for p in [(10, 25), (11, 24), (12, 24), (13, 25), (13, 26), (13, 27), (12, 28), (11, 28), (10, 28), (9, 27), (9, 26)]:
        if p not in [(11, 26), (12, 26), (11, 27), (12, 27)]: cv.put(*p, GLD[5], lock=True)
    px(cv, [(13, 28), (14, 30), (14, 32)], GLD[1])
    # crown
    cr = cv.poly([(10, 19), (11, 11), (14, 15), (17, 9), (20, 15), (23, 11), (24, 19)])
    part(cv, cr, GLD, k=1.2)
    px(cv, [(11, 17), (12, 17), (13, 17), (14, 17), (15, 17), (16, 17), (17, 17), (18, 17), (19, 17), (20, 17), (21, 17), (22, 17), (23, 17)], GLD[1])
    cv.put(17, 15, '#e8493b', lock=True); cv.put(17, 14, '#ff8a5c', lock=True)
    save(cv, 'cf-fish-5')

if __name__ == '__main__':
    for f in (fish1, fish2, fish3, fish4, fish5): f()
