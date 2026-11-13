import sys, os, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib import *
OUT = os.path.dirname(os.path.abspath(__file__)) + '/'
OLD = '/home/user/gnome-venture/game/assets/img/catfish/'
GREY = ['#3d3654', '#57516f', '#6e6684', '#8a859b', '#cdc9d3', '#f1ebe3']   # deep shade bounce base light gloss
PINK, PINKD, CREAM = '#e8909e', '#c66a80', '#f2e4c0'
FISH = ['#ac3b1d', '#dc6f2c', '#e38111', '#f2a860', '#ffc27a', '#fff1c8']

def old(frame): return np.array(Image.open(OLD + 'cf-cat-grey-%s.png' % frame).convert('RGBA'))

def part(cv, m, ramp=GREY, **kw):
    """tone a part; AO on whatever was there before"""
    prev = cv.a.copy()
    cv.tone(m, ramp, **kw)
    cv.ao(m, prev, ramp)

def head(cv, ox, oy, frame):
    sh = lambda m: np.roll(np.roll(m, oy, 0), ox, 1)
    E = lambda cx, cy, rx, ry: cv.ellipse(cx + ox, cy + oy, rx, ry)
    P = lambda pts: cv.poly([(x + ox, y + oy) for x, y in pts])
    # ears (behind head)
    for side in (0, 1):
        f = (lambda x: x) if side == 0 else (lambda x: 50 - x)
        ear = P([(f(9), 15), (f(10), 3), (f(22), 9)]) | P([(f(10), 14), (f(11), 3), (f(21), 9), (f(20), 14)])
        part(cv, ear)
    # cheek tufts + cowlick are extra silhouette
    hd = E(25, 19, 15.5, 12.5)
    hd |= P([(11, 25), (8, 28), (12, 28)]) | P([(39, 25), (42, 28), (38, 28)])   # cheek tufts
    cow = cv.line([(24 + ox, 8 + oy), (24 + ox, 6 + oy), (26 + ox, 4 + oy), (28 + ox, 5 + oy), (28 + ox, 7 + oy)], 1.8)
    part(cv, hd, bias=0.02)
    # inner ears
    for side in (0, 1):
        f = (lambda x: x) if side == 0 else (lambda x: 50 - x)
        for (x, y, c) in [(12, 12, PINKD), (12, 11, PINKD), (12, 10, PINK), (12, 9, PINK), (13, 10, PINK), (13, 11, PINK), (13, 12, PINK), (14, 11, PINK), (14, 10, PINK), (15, 11, PINK), (12, 8, PINK), (12, 7, PINKD), (14, 12, PINKD), (13, 13, PINKD)]:
            cv.put(f(x) + ox, y + oy, c, lock=True)
    # cowlick quirk: a curled lock of fur on the crown
    part(cv, cow & ~hd, bias=0.12)
    for p in [(25, 8), (26, 7), (27, 6)]: cv.put(p[0] + ox, p[1] + oy, GREY[4], idx=4)
    cv.put(28 + ox, 5 + oy, GREY[5], idx=5)
    # muzzle: soft light patch
    mz = E(25, 27.5, 5.2, 3.4)
    for y, x in zip(*np.nonzero(mz & cv.a)):
        cv.rgb[y, x] = hx(GREY[4]); cv.idx[y, x] = 4
    for p in [(21, 26), (22, 25), (28, 25), (29, 26), (22, 29), (28, 29)]: cv.put(p[0] + ox, p[1] + oy, GREY[5], idx=5)
    # nose: ink tip, cream glint, small mouth
    for p in [(24, 25), (25, 25), (26, 25), (25, 26)]: cv.put(p[0] + ox, p[1] + oy, '#2b1c26', lock=True)
    cv.put(24 + ox, 25 + oy, CREAM, lock=True)
    for p in [(25, 27), (24, 28), (26, 28)]: cv.put(p[0] + ox, p[1] + oy, GREY[1], lock=True)
    cv.put(23 + ox, 27 + oy, GREY[1], lock=True); cv.put(27 + ox, 27 + oy, GREY[1], lock=True)
    # whisker pops (light dashes, inside the silhouette)
    for (x, y) in [(16, 27), (17, 27), (18, 27), (18, 29), (19, 29), (15, 25)]:
        cv.put(x + ox, y + oy, GREY[5], lock=True); cv.put(50 - x + ox, y + oy, GREY[5], lock=True)
    # fur tufts on the cheeks: short shade ticks
    for (x, y) in [(12, 26), (13, 28), (38, 26), (37, 28), (14, 15), (36, 15)]:
        cv.put(x + ox, y + oy, GREY[1], lock=True)
    # eyes: keep the old art exactly where it is (separate overlay layer aligns with it)
    o = old(frame)
    for ecx in (16, 34):
        cx, cy = ecx + ox, 21 + oy
        for y in range(cy - 3, cy + 4):
            for x in range(cx - 3, cx + 4):
                r, g, b, a = o[y, x]
                if a and (r, g, b) in ((0x2a, 0x1a, 0x10), (0xf2, 0xe4, 0xc0)):
                    cv.put(x, y, '#%02x%02x%02x' % (r, g, b), only=False, lock=True)

def finish(cv, name):
    cv.outline()
    n = cv.check(); cv.save(OUT + name + '.png'); print(name, n, 'colours')

def tail_tip(cv, m, pt, r=2.6):
    y, x = np.mgrid[0:cv.h, 0:cv.w]
    t = m & (((x - pt[0]) ** 2 + (y - pt[1]) ** 2) <= r * r)
    for yy, xx in zip(*np.nonzero(t)):
        cv.rgb[yy, xx] = hx(GREY[4]); cv.idx[yy, xx] = 4
    return t

def idleA(catch=False):
    cv = Cv(64, 64)
    tl = cv.line([(36, 52), (45, 57), (52, 50), (52, 40), (48, 34)], 4.6, 3.0)
    part(cv, tl, bias=0.0); tail_tip(cv, tl, (48, 34))
    for i in range(3): cv.put(51 + (i % 2), 44 + i * 4, GREY[1], lock=True)   # fur ticks on tail
    body = cv.ellipse(24, 43, 12.5, 12.5)
    hl = cv.ellipse(13, 49, 6, 6.5); hr = cv.ellipse(35, 49, 6, 6.5)
    part(cv, body | hl | hr)
    # soft belly light
    bl = cv.ellipse(24, 46, 6.5, 6)
    for y, x in zip(*np.nonzero(bl & cv.a)): cv.rgb[y, x] = hx(GREY[4]); cv.idx[y, x] = 4
    if not catch:
        for p in [(21, 42), (22, 41), (24, 41)]: cv.put(*p, GREY[5], idx=5, lock=True)
    # chest tuft
    for p in [(22, 33), (23, 34), (24, 35), (25, 35), (26, 35), (27, 34), (28, 33)]: cv.put(*p, GREY[4], idx=4, lock=True)
    for p in [(24, 36), (25, 36), (26, 36)]: cv.put(*p, GREY[5], idx=5, lock=True)
    # haunch toe ticks
    for p in [(10, 54), (11, 55), (37, 55), (38, 54)]: cv.put(*p, GREY[1], lock=True)
    legs = [cv.line([(19, 45), (19, 54)], 4.2), cv.line([(30, 45), (30, 54)], 4.2)]
    for lg in legs: part(cv, lg, k=1.3)
    pw = [cv.ellipse(19, 55, 4, 2.4), cv.ellipse(30, 55, 4, 2.4)]
    for p in pw: part(cv, p)
    for x in (19, 30):
        cv.put(x - 1, 56, GREY[1], lock=True); cv.put(x + 1, 56, GREY[1], lock=True)
    if catch:
        fish_in_arms(cv)
    head(cv, 0, 0, 'catch' if catch else 'idleA')
    finish(cv, 'cf-cat-grey-catch' if catch else 'cf-cat-grey-idleA')

def fish_in_arms(cv):
    # little orange fish held across the belly (fixed accents, same as the old catch art)
    fb = cv.ellipse(26, 44, 9.5, 5)
    tl = cv.poly([(34, 44), (42, 38), (41, 44), (42, 50)])
    ft = cv.poly([(24, 38), (30, 38), (28, 41)])
    prev = cv.a.copy()
    cv.tone(tl, FISH, k=1.0)
    cv.tone(fb | ft, FISH, k=1.0)
    # belly light, gill, eye, scales
    for p in [(20, 47), (21, 48), (22, 48), (23, 48), (24, 48), (25, 48)]: cv.put(*p, FISH[4], lock=True)
    for p in [(31, 41), (31, 42), (31, 43), (31, 44), (31, 45)]: cv.put(*p, FISH[0], lock=True)
    cv.put(19, 43, '#2b1c26', lock=True); cv.put(18, 42, FISH[5], lock=True)
    for p in [(24, 43), (26, 42), (28, 44), (25, 46)]: cv.put(*p, FISH[2], lock=True)
    for p in [(23, 41), (24, 41)]: cv.put(*p, FISH[5], lock=True)
    # arms clutching it
    for (ax, ay) in ((16, 45), (35, 46)):
        arm = cv.ellipse(ax, ay, 3.6, 3.0)
        part(cv, arm)
        for dx in (-1, 1): cv.put(ax + dx, ay + 1, GREY[1], lock=True)
        cv.put(ax, ay - 1, GREY[5], lock=True)

def pounce():
    cv = Cv(64, 64)
    # ground shadow (2-tone, 3px)
    sh = cv.ellipse(30, 57, 12, 1.6)
    cv.flat(sh, '#4a2c1a'); cv.flat(sh & (np.arange(64)[:, None] >= 58), '#2a1a10'); cv.lock |= sh
    tl = cv.line([(10, 33), (5, 26), (7, 17), (11, 9)], 4.6, 3.0)
    part(cv, tl); tail_tip(cv, tl, (11, 9), 2.8)
    for p in [(5, 22), (6, 28), (8, 15)]: cv.put(*p, GREY[1], lock=True)
    # hind: haunch + stretched foot
    haunch = cv.ellipse(15, 37, 6.5, 6)
    part(cv, cv.line([(14, 35), (7, 41)], 4.0));
    part(cv, haunch)
    foot = cv.ellipse(6, 41, 3.8, 2.6); part(cv, foot)
    for p in [(5, 42), (7, 42)]: cv.put(*p, GREY[1], lock=True)
    torso = cv.line([(14, 37), (36, 32)], 13, 12)
    part(cv, torso, bias=0.0)
    for p in [(22, 34), (23, 33), (25, 33)]: cv.put(*p, GREY[5], idx=5, lock=True)
    bl = cv.line([(18, 38), (32, 35)], 4.5)
    for y, x in zip(*np.nonzero(bl & cv.a)): cv.rgb[y, x] = hx(GREY[4]); cv.idx[y, x] = 4
    # forelegs reaching out to the right
    f1 = cv.line([(38, 34), (47, 38), (54, 36)], 4.2, 3.6)
    f2 = cv.line([(36, 36), (44, 43), (51, 42)], 4.2, 3.6)
    part(cv, f2, k=1.3); part(cv, f1, k=1.3)
    for (x, y) in ((54, 36), (51, 42)):
        pw = cv.ellipse(x, y, 3.4, 2.8); part(cv, pw)
        cv.put(x + 1, y - 1, GREY[1], lock=True); cv.put(x + 1, y + 1, GREY[1], lock=True)
    head(cv, 16, 0, 'pounce')
    finish(cv, 'cf-cat-grey-pounce')

def nap():
    cv = Cv(64, 64)
    body = cv.ellipse(46, 46, 13.5, 11.5)
    part(cv, body)
    sp = cv.line([(40, 38), (44, 36), (50, 36)], 2.0)
    for y, x in zip(*np.nonzero(sp & cv.a)): cv.rgb[y, x] = hx(GREY[4]); cv.idx[y, x] = 4
    for p in [(54, 40), (55, 44), (56, 49), (52, 52)]: cv.put(*p, GREY[1], lock=True)
    tl = cv.line([(54, 55), (42, 58), (32, 57), (24, 56)], 5.0, 3.4)
    part(cv, tl); tail_tip(cv, tl, (24, 56), 2.8)
    for p in [(46, 58), (38, 59), (30, 58)]: cv.put(*p, GREY[1], lock=True)
    for p in [(46, 56), (40, 57)]: cv.put(*p, GREY[4], idx=4, lock=True)
    for x in (16, 27):
        pw = cv.ellipse(x, 53, 5, 2.8); part(cv, pw)
        cv.put(x - 1, 54, GREY[1], lock=True); cv.put(x + 1, 54, GREY[1], lock=True)
    head(cv, 0, 18, 'nap')
    # quirk (sleeping): a tiny "z" bubble would be a second quirk; skip, cowlick is the quirk
    finish(cv, 'cf-cat-grey-nap')

if __name__ == '__main__':
    idleA(); idleA(catch=True); pounce(); nap()
