import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
import math
R = '/home/user/gnome-venture/'
# Aurora Band: a wavy aurora ribbon that is an inner piece, peg tabs on all four sides; green crest, pink seam, violet body with rays, a star.
GREEN = K.ramp('#38b890')
PINK = K.ramp('#e890d8')
VIOL = K.ramp('#b870d0')
NAVY = K.ramp('#241c5c')
STAR = '#fff0d0'

def top(x): return 15 + 4 * math.sin((x - 12) / 40 * 2 * math.pi)
def bot(x): return 49 + 4 * math.sin((x - 12) / 40 * 2 * math.pi)

def fn(c):
    s = 1.15 if c.small else 1.0
    core = lambda x, y: 12 <= x < 52 and top(x) <= y < bot(x)
    r = 4.2 * s
    tabs = [K.knob('T', 'peg', 32, top(32), 0, -1, r=r), K.knob('T', 'peg', 32, bot(32), 0, 1, r=r),
            K.knob('T', 'peg', 12, 32, -1, 0, r=r), K.knob('T', 'peg', 52, 32, 1, 0, r=r)]
    body = c.m(core, *tabs)
    c.add(body, VIOL)
    deep = c.m(lambda x, y: y >= bot(min(max(x, 12), 51.9)) - 5 and not (27 < x < 37 and y > bot(32) - 1))
    c.add(deep & body, K.ramp('#8858b8'))
    green = c.m(lambda x, y: y < top(min(max(x, 12), 51.9)) + 9)
    c.add(green & body, GREEN)
    pink = c.m(lambda x, y: top(min(max(x, 12), 51.9)) + 9 <= y < top(min(max(x, 12), 51.9)) + 12)
    c.add(pink & body, PINK)
    # curtain rays: lighter streaks hanging down from the seam
    for rx, ln in ((14, 22), (19, 18), (24, 10), (41, 12), (46, 20), (50, 22)):
        ray = c.m(lambda x, y, rx=rx, ln=ln: rx <= x < rx + 2.4 and top(rx) + 12 <= y < top(rx) + 12 + ln)
        for p in ray & body:
            c.px(p[0], p[1], VIOL[2])
    # green flicker rays in the crest
    for rx in (20, 36, 44):
        ray = c.m(lambda x, y, rx=rx: rx <= x < rx + 2.4 and top(rx) + 2 <= y < top(rx) + 7)
        for p in ray & body:
            c.px(p[0], p[1], GREEN[2])
    # star on the top tab
    sx, sy = c.P(32, top(32) - 5.5)
    for d in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
        c.px(sx + d[0], sy + d[1], STAR)
    # face on the violet body
    c.eye(26, 36)
    c.eye(38, 36)
    c.smile(32, 40.5)
    c.blush(22.5, 39.5)
    c.blush(40.5, 39.5)

K.render_pal(fn, 'pl-aurc-4', 'Aurora Band', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-aurc-4-cell.png', oldfile=R + 'game/assets/img/puzzles/pals/pl-aurc-4.png')
