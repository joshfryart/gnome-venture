import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
import math
# Concept: a rainbow arch that IS an edge piece: flat bottom on the green hill, keyhole tabs left and right,
# keyhole blank cut into the crown; bands red->violet with pale mint sky inside, from cell 1-4 (rainbow over green hills).
ROOT = '/home/user/gnome-venture'
BANDS = [(42, K.ramp('#e0483a')), (37, K.ramp('#f08a30')), (32, K.ramp('#f8d048')),
         (27, K.ramp('#6cc060')), (22, K.ramp('#4aa0e0')), (17, K.ramp('#8a5cc8'))]
SKY = K.ramp('#cde8dc')
HILL = K.ramp('#6fae88')

def fn(c):
    s = 1.15 if c.small else 1.0
    R = 18
    core = [K.rect(13, 10 + R, 51, 56), K.rect(13 + R, 10, 51 - R, 56),
            K.ell(13 + R, 10 + R, R, R), K.ell(51 - R, 10 + R, R, R)]
    tabs = [K.knob('T', 'keyhole', 13, 40, -1, 0, r=5.0 * s, nw=3.0), K.knob('T', 'keyhole', 51, 40, 1, 0, r=5.0 * s, nw=3.0)]
    blank = [K.knob('B', 'keyhole', 32, 10, 0, -1, r=3.8 * s)]
    body = c.m(*core, *tabs, minus=blank)
    d = lambda x, y: math.hypot(x - 32, y - 56)
    c.add(body, BANDS[0][1])
    for i in range(1, len(BANDS)):
        hi = BANDS[i - 1][0]
        m = c.m(lambda x, y, hi=hi: d(x, y) < hi) & body
        c.add(m, BANDS[i][1])
    inner = c.m(lambda x, y: d(x, y) < BANDS[-1][0]) & body
    c.add(inner, SKY)
    hill = c.m(K.ell(32, 61, 36, 10)) & body
    c.add(hill, HILL)
    c.edge(hill, HILL[1])
    # face in the sky pocket under the arch
    c.eye(27, 46, look=(0, 0))
    c.eye(37, 46, look=(0, 0))
    c.smile(32, 49)
    c.blush(24, 50)
    c.blush(39, 50)

if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-sing-2', 'Prism Streamer', ROOT + '/art-review/redo/out',
                       cellfile=ROOT + '/art-review/redo/_src/pl-sing-2-cell.png',
                       oldfile=ROOT + '/game/assets/img/puzzles/pals/pl-sing-2.png'))
