"""pl-step-2 "Glyph Doodle": edge-TBB, keyhole. A carved temple stone block that walks the terrace. Flat S (it stands on the ledge),
keyhole tab N = a mossy sprout holding the gold seed, keyhole blanks W + E bite into the brick courses. Mossy green ledge cap with
dark-green drips, tan / umber / rose bricks with dark mortar (cell 3-5), carved triangle + square glyph doodles on the lower course."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

TAN = K.ramp('#c09a72')
ROSE = K.ramp('#d4aa84')
BRN = K.ramp('#8a6e5c')
MORTAR = '#5a463e'
MOSS = K.ramp('#4aa57a')
MOSSDK = '#2e6650'
GOLD = K.ramp('#e8b030')
GLYPH = '#4a3428'
GLYPHLT = '#ecd2a8'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(8, 19, 56, 58)
    tabN = K.knob('T', 'keyhole', 32, 19, 0, -1, r=5.8 * s)
    blW = K.knob('B', 'keyhole', 8, 42, -1, 0, r=3.8 * s)
    blE = K.knob('B', 'keyhole', 56, 42, 1, 0, r=3.8 * s)
    body = c.m(core, minus=(blW, blE))
    c.add(body, TAN, stitch=None)
    # bricks: course rows, alternating tones
    rows = [(23, 37), (37, 47), (47, 58)]
    for ri, (y0, y1) in enumerate(rows):
        joints = [8, 56] if ri == 0 else ([8, 32, 56] if ri == 2 else [8, 20, 44, 56])
        for bi, (x0, x1) in enumerate(zip(joints, joints[1:])):
            rmp = (TAN, ROSE, BRN)[(ri + bi * 2) % 3]
            m = body & c.m(K.rect(x0, y0, x1, y1))
            c.add(m, rmp)
            c.edge(m, MORTAR)
    # moss ledge cap with drips
    cap = c.m(K.rect(8, 19, 56, 23), lambda x, y: 8 <= x < 56 and 23 <= y < 23 + (2.2 if (x < 15 or x > 49) and int(x // 4) % 2 else 0))
    c.add(cap & body, MOSS)
    if not c.small:
        for x in range(c.P(10, 0)[0], c.P(54, 0)[0]):
            if (x // 3) % 3 == 0:
                c.px(x, c.P(0, 20.5)[1], MOSS[2])
    # keyhole tab = moss stem + gold seed
    tab = c.m(tabN, minus=(K.rect(0, 19, 64, 64),))
    c.add(tab, MOSS)
    seed = c.m(K.ell(32, 19 - (1.6 + 5.8 * s) - 0.5, 4.4 * s, 4.8 * s))
    c.add(seed & tab, GOLD)
    # glyph doodles carved on the lower course: triangle (left), square (right)
    tri = c.m(K.poly([(13, 56.5), (20, 48), (27, 56.5)]))
    sq = c.m(K.rect(37, 49, 47, 56.5))
    for g in (tri, sq):
        c.add(g & body, (GLYPH, GLYPH, GLYPHLT))
    if not c.small:
        inner = c.m(K.rect(40, 51.5, 44, 54))
        c.add(inner, ROSE)
        c.add(c.m(K.poly([(18, 54.5), (20, 51), (22, 54.5)])) , ROSE)
    # face on the big middle course
    c.eye(23, 30, disc=True)
    c.eye(41, 30, disc=True)
    c.smile(32, 33.5)
    c.blush(17.5, 34)
    c.blush(45.5, 34)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-step-2', 'Glyph Doodle', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-step-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-step-2.png')
    print(rep)
