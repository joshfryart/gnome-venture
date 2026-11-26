# pl-tcb-6 "Bridgewalk Marmot" (whimsy-marmot, tri knobs).
# Concept: a chibi orange marmot that is the piece: square body core, tri tab N = the walnut held up over its head,
# tri tab E = its striped bushy tail, tri blank W cut into its flank, flat S = the bridge plank it stands on.
# Colours from cell 4-4 / the picture: marmot orange + cream belly, rust tail stripes, umber-red plank, tan rope, canopy green.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

FUR = K.ramp('#de8953')
BELLY = K.ramp('#e8d0aa')
RUST = K.ramp('#95423c')
NUT = K.ramp('#a86a3c')
PLANK = K.ramp('#6e3e38')
ROPE = K.ramp('#c4894e')
LEAF = K.ramp('#5aaa78')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(12, 20, 50, 56)
    head = K.ell(31, 26, 19, 9)
    tabN = K.knob('T', 'tri', 30, 19, 0, -1, r=6.0 * s)
    tabE = K.knob('T', 'tri', 50, 36, 1, 0, r=5.0 * s)
    blankW = K.knob('B', 'tri', 12, 38, -1, 0, r=5.4 * s)
    earL = K.ell(15.5, 20.5, 3.4, 3.0)
    earR = K.ell(46.5, 20.5, 3.4, 3.0)
    body = c.m(core, earL, earR, minus=(blankW, lambda x, y: y < 22 and not head(x, y) and not earL(x, y) and not earR(x, y)))
    c.add(body, FUR, stitch=None)
    # inner ears
    c.add(c.m(K.ell(15.5, 20.5, 1.6, 1.5)) & body, RUST)
    c.add(c.m(K.ell(46.5, 20.5, 1.6, 1.5)) & body, RUST)
    # tail = E tab, orange with rust bands
    tail = c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(K.rect(47, 0, 51, 64)))
    c.add(tail, FUR)
    for (x, y) in tail:
        X = x / c.k
        if int(X) in (52, 53, 57, 58) or (c.small and int(X) in (53, 54, 58, 59)):
            c.px(x, y, RUST[0])
    c.add(c.m(K.ell(31, 18, 17, 6)) & body, K.ramp('#b8683e'))
    # belly
    c.add(c.m(K.ell(31, 43, 10.5, 10)) & body, BELLY)
    # walnut = N tab, held by two paws
    nut = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 15, 64, 19)))
    c.add(nut, NUT)
    # walnut shell: centre seam + crinkle ridges
    c.line([(30, 5.5 if not c.small else 7), (30, 18)], NUT[1])
    for yy in ((10, 14) if not c.small else (12,)):
        c.line([(26.5, yy), (28.5, yy + 1)], NUT[1])
        c.line([(31.5, yy + 1), (33.5, yy)], NUT[1])
    # two little paws gripping the nut
    paws = c.m(K.ell(24.5, 18, 3.0, 2.6), K.ell(35.5, 18, 3.0, 2.6))
    c.add(paws, BELLY)
    c.edge(paws, K.UMBER2)
    # muzzle + face
    c.add(c.m(K.ell(31, 32.5, 6.5, 4.2)), BELLY)
    nx, ny = c.P(31, 30.5)
    c.px(nx, ny, UMBER2)
    if not c.small:
        c.px(nx - 1, ny, UMBER2)
        c.px(nx + 1, ny, UMBER2)
    # marmot buck teeth
    tx, ty = c.P(31, 34)
    c.px(tx, ty, UMBER2)
    for dy in ((1, 2) if not c.small else (1,)):
        c.px(tx - 1, ty + dy, '#fffaf0')
        c.px(tx + 1, ty + dy, '#fffaf0')
        c.px(tx, ty + dy, UMBER2)
    c.px(tx - 2, ty, UMBER2)
    c.px(tx + 2, ty, UMBER2)
    c.eye(23.5, 28)
    c.eye(38.5, 28)
    c.blush(19.5, 32.5)
    c.blush(41.5, 32.5)
    # bridge plank (flat S side) with the tan hand-rope and a canopy leaf tuft
    c.add(body & c.m(K.rect(0, 50.5, 64, 56)), PLANK)
    c.add(body & c.m(K.rect(0, 50.5, 64, 52.2 if not c.small else 52.4)), ROPE)
    for gx in (20, 31, 42):
        x, _ = c.P(gx, 0)
        for y in range(c.P(0, 53)[1], c.n):
            if (x, y) in body:
                c.px(x, y, PLANK[1])
    leaf = c.m(K.ell(47.5, 47.5, 2.6, 3.8), K.ell(44, 48.5, 2.4, 3.0)) & body
    c.add(leaf, LEAF)


UMBER2 = K.UMBER2
K.render_pal(fn, 'pl-tcb-6', 'Bridgewalk Marmot', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tcb-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tcb-6.png')
