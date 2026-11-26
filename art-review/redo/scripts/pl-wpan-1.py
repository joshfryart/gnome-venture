"""pl-wpan-1 Knock-Knock Bamboo. Corner-TT, keyhole: a bundle of three bamboo stalks packed into a square corner piece.
Flat W and S sides (the grassy ground), keyhole tab N = the middle stalk's new shoot, keyhole tab E = a leafy sprig off a node.
Bamboo greens and the pale grove-sky green from the Wonder Panda bamboo grove (cell 1-1)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp

STALK = ramp('#4ba161')
STALK = (STALK[0], '#34864f', '#79bd88')
STALK2 = ('#409458', '#2f6a3a', '#6cb07a')
LEAF = ('#7ab55c', '#4f8a3a', '#b8e0a0')
GRASS = ('#b8e0a0', '#8cc070', '#d1e8a0')
NODE = '#2f6a3a'
NODEL = '#c8e8a0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(9, 17, 49, 57)
    tabN = knob('T', 'keyhole', 29, 17, 0, -1, r=5.4 * k)
    tabE = knob('T', 'keyhole', 49, 35, 1, 0, r=5.0 * k)
    body = c.m(core, tabN, tabE)
    # three stalks: side stalks a touch darker, the middle one carries the face
    sL = c.m(rect(9, 17, 20, 57))
    sM = c.m(rect(20, 17, 38, 57), tabN, minus=(rect(0, 0, 64, 64 if False else 0),))
    sR = c.m(rect(38, 17, 49, 57))
    c.add(sL & body, STALK2)
    c.add(sR & body, STALK2)
    c.add((sM & body) - c.m(tabE), STALK, stitch=None)
    c.edge(sL & body, NODE)
    c.edge(sR & body, NODE)
    # E tab: the leaf sprig (pale grove green)
    sprig = c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(rect(47, 0, 49.5, 64)))
    c.add(sprig, LEAF)
    # hollow cut tops of the side stalks
    for x0, x1 in ((9, 20), (38, 49)):
        for x in range(c.P(x0 + 1.5, 0)[0], c.P(x1 - 1.5, 0)[0] + 1):
            c.px(x, c.P(0, 18.5)[1], NODE)
    # nodes: dark band with a pale ring above, staggered per stalk
    def node(x0, x1, y):
        py = c.P(0, y)[1]
        for x in range(c.P(x0, 0)[0], c.P(x1, 0)[0]):
            if (x, py) in body:
                c.px(x, py, NODE)
                c.px(x, py - 1, NODEL)
    for y in (31, 46):
        node(9, 20, y)
    for y in (27, 42):
        node(38, 49, y)
    node(20, 38, 23.5)
    node(20, 38, 47)
    # vertical sheen on each stalk (light from the upper left) + dark seams between stalks
    for sx in (11.5, 23, 40.5):
        x = c.P(sx, 0)[0]
        for y in range(c.P(0, 20)[1], c.P(0, 52)[1]):
            if (x, y) in body and c.over.get((x, y)) is None:
                c.px(x, y, '#9fd49a')
    # long leaf blades: one drooping off the shoot to the W, one off the left stalk's node
    lw = 3.0 if c.small else 2.6
    c.add(c.m(poly([(27, 7), (21, 4.5), (14, 6), (10, 11), (16, 10), (22, 9.5), (27, 10)])), LEAF)
    c.add(c.m(poly([(9.5, 30), (3, 34), (2, 39), (6, 37), (11, 33)])), LEAF)
    # pointed leaf blades on the E sprig
    c.add(c.m(poly([(56, 31), (62, 26), (61, 30), (58, 34)])), LEAF)
    # grass tuft along the flat S side
    grass = c.m(lambda x, y: y > 52 + (1.6 if (x // 3) % 2 else 0) and 9 <= x < 49 and y < 57)
    c.add(grass & body, GRASS)
    # face on the middle stalk
    c.eye(25, 34)
    c.eye(33, 34)
    c.smile(29, 38.5)
    c.blush(23, 37.5)
    c.blush(35, 37.5)


K.render_pal(fn, 'pl-wpan-1', 'Knock-Knock Bamboo', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpan-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpan-1.png')
