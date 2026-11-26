"""ss-coral-cuff "Coral Cuff": inner-TTTT, double. A square chunk of pink reef coral whose four double tabs are forked coral
branch tips (one tiny reef per knob). The lower third is the teal sea cuff from cell 8-3 with a cream foam/sail line; cream polyps dot the coral."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

CORAL = K.ramp('#d84a5c')
BRANCH = K.ramp('#f6909a')
SEA = K.ramp('#2bb3bf')
FOAM = K.ramp('#fef4e8')
POLYP = '#fff0e8'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(14, 14, 50, 50)
    r = 5.4 * k
    tN = K.knob('T', 'double', 32, 14, 0, -1, r=r)
    tS = K.knob('T', 'double', 32, 50, 0, 1, r=r)
    tW = K.knob('T', 'double', 14, 32, -1, 0, r=r)
    tE = K.knob('T', 'double', 50, 32, 1, 0, r=r)
    body = c.m(core)
    c.add(body, CORAL)
    # staghorn coral: forked fingers grow up from the face zone into the N tab and out past the top corners
    bw = 3.4 if not c.small else 3.8
    fingers = ([(32, 27), (32, 14)], [(32, 25), (24, 19), (17, 11)], [(32, 25), (40, 19), (47, 11)],
               [(24, 19), (21, 15)], [(40, 19), (43, 15)], [(18, 27), (14, 32)], [(46, 27), (50, 32)])
    for pts in fingers:
        c.add(c.m(K.thick_path(pts, bw)) & body, BRANCH)
    # corner coral sprouts break the outline (round-tipped fingers)
    sw = 4.6 if not c.small else 5.2
    for pts in ([(18, 18), (11, 10)], [(46, 18), (53, 10)], [(14, 14), (8, 15)], [(50, 14), (56, 15)]):
        c.add(c.m(K.thick_path(pts, sw), K.ell(pts[1][0], pts[1][1], sw / 2 + 0.6, sw / 2 + 0.6)), BRANCH)
    for t, clip in ((tN, K.rect(0, 0, 64, 15)), (tW, K.rect(0, 0, 15, 64)), (tE, K.rect(49, 0, 64, 64))):
        c.add(c.m(t) & c.m(clip), BRANCH)
    # teal sea cuff (lower band) with cream foam crest, and the south tab is a wave of sea
    wave = lambda x, y: y >= 40 + (1.5 if (x // 5) % 2 else 0)
    sea = c.m(core, tS) & c.m(wave)
    c.add(c.m(tS) | (body & sea), SEA)
    foam = c.m(lambda x, y: 38.5 + (1.5 if (x // 5) % 2 else 0) <= y < 41 + (1.5 if (x // 5) % 2 else 0) and 14 <= x < 50)
    c.add(foam, FOAM)
    # polyps on coral
    for (px, py) in ((27, 16), (37, 16), (19, 22), (45, 22), (11, 10), (53, 10), (20, 36), (44, 36)):
        x, y = c.P(px, py)
        c.px(x, y, POLYP)
        if not c.small:
            c.px(x + 1, y, POLYP)
    # tab tips: cream polyp highlights on each lobe
    for (px, py) in ((29, 5), (35, 5), (5, 29), (5, 35), (59, 29), (59, 35)):
        x, y = c.P(px, py)
        c.px(x, y, POLYP)
    # sea ripples
    if not c.small:
        for (px, py) in ((20, 46), (40, 47), (31, 55)):
            x, y = c.P(px, py)
            for d in range(3):
                c.px(x + d, y, SEA[2])
    # face on the coral, between the branches
    c.eye(26, 32)
    c.eye(38, 32)
    c.blush(22, 35)
    c.blush(41, 35)
    c.smile(32, 35)


if __name__ == '__main__':
    print(K.render_pal(fn, 'ss-coral-cuff', 'Coral Cuff', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/ss-coral-cuff-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/ss-coral-cuff.png'))
