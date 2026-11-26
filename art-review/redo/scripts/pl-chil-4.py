"""pl-chil-4 Chili Cluster. Inner-TTTT, peg: a tied bunch of fat red chilies packed into a square piece.
N peg = the green tied stalks (gold cord), E peg + S peg = chili tips poking out of the bunch, W peg = a green leaf.
Coral/brick reds, leaf greens and the market's warm shadow from cell 0-4 (hanging chili strings on cream)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

ROOT = '/home/user/gnome-venture/'
RED = K.ramp('#e04838')
CORAL = ('#ff7050', '#c84438', '#ffa088')
BRICK = ('#b83a34', '#7e2a2a', '#e05848')
SHADOW = ('#5e1c28', '#3a1420', '#8e2a3a')
LEAF = ('#63ae51', '#245b40', '#a8d878')
GOLD = K.GOLD


def pod(a, b, w0, w1):
    """Tapered chili: polygon from end a (width w0) to tip b (width w1)."""
    (ax, ay), (bx, by) = a, b
    dx, dy = bx - ax, by - ay
    L = (dx * dx + dy * dy) ** 0.5
    nx, ny = -dy / L, dx / L
    pts = []
    for t, w in ((0, w0 * .8), (.15, w0), (.55, w0 * .85), (.85, (w0 + w1) / 2), (1, w1)):
        pts.append((ax + dx * t + nx * w / 2, ay + dy * t + ny * w / 2))
    back = []
    for t, w in ((0, w0 * .8), (.15, w0), (.55, w0 * .85), (.85, (w0 + w1) / 2), (1, w1)):
        back.append((ax + dx * t - nx * w / 2, ay + dy * t - ny * w / 2))
    return poly(pts + back[::-1])


def fn(c):
    S = 1.15 if c.small else 1.0
    core = lambda x, y: rect(13, 16, 51, 51)(x, y) and not (
        (x < 16 and y < 19 and not ell(16, 19, 3, 3)(x, y)) or (x > 48 and y < 19 and not ell(48, 19, 3, 3)(x, y)))
    tabN = knob('T', 'peg', 32, 16, 0, -1, r=4.2 * S)
    tabE = knob('T', 'peg', 51, 34, 1, 0, r=3.8 * S)
    tabS = knob('T', 'peg', 32, 51, 0, 1, r=3.8 * S)
    tabW = knob('T', 'peg', 13, 34, -1, 0, r=3.8 * S)
    pl = pod((20, 18), (17, 55), 13, 4)
    pr = pod((44, 18), (47, 55), 13, 4)
    body = c.m(lambda x, y: core(x, y) and y < 45, pl, pr, rect(24, 40, 40, 51))
    c.add(body, SHADOW)
    # back pods (left and right): their tips scallop the bottom corners
    mL, mR = c.m(pl), c.m(pr)
    c.add(mL, BRICK)
    c.add(mR, BRICK)
    c.edge(mL, BRICK[1])
    c.edge(mR, BRICK[1])
    # E tab: a chili lying across, its tip poking out right
    mE = c.m(pod((38, 30), (58, 34), 9, 5), tabE) & (c.m(tabE) | body)
    c.add(mE, CORAL)
    c.edge(mE & body, CORAL[1])
    # S tab: front pod tip hanging down
    pm = pod((32, 18), (32, 57), 15, 7)
    mM = c.m(pm) & (body | c.m(tabS))
    mM |= c.m(tabS)
    c.add(mM, RED)
    c.edge(mM & body, RED[1])
    # W tab: a green leaf
    leaf = c.m(tabW, poly([(13, 30), (24, 36), (21, 42), (13, 38)]))
    c.add(leaf & (body | c.m(tabW)), LEAF)
    # calyx caps along the top + N stalk
    caps = c.m(lambda x, y: y < 21.5 + (1.5 if (x // 3) % 2 else 0)) & body
    c.add(caps | c.m(tabN, minus=(rect(0, 16, 64, 64),)), LEAF)
    c.add(c.m(rect(27, 11.5, 37, 14)), GOLD)
    # gloss streaks
    if not c.small:
        c.line([(18, 26), (17, 40)], BRICK[2])
        c.line([(27, 24), (27, 42)], RED[2])
        c.line([(44, 31), (54, 32)], CORAL[2])
        c.line([(31, 53), (31, 56)], RED[2])
        c.line([(14, 33), (21, 37)], LEAF[1])
    c.eye(28.5, 31)
    c.eye(35.5, 31)
    c.smile(32, 37)
    if not c.small:
        c.blush(25.5, 35)
        c.blush(38, 35)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-chil-4', 'Chili Cluster', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile=ROOT + 'art-review/redo/_src/pl-chil-4-cell.png',
                       oldfile=ROOT + 'game/assets/img/puzzles/pals/pl-chil-4.png'))
