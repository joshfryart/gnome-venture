# Sky Lantern (inner-TTTT, tri): a paper sky lantern that IS an inner piece. Square-ish orange paper body (the lanterns drifting
# over the Monsoon Tangle), tri tab N = the peaked bamboo top, tri tab S = the flame hanging from the wire hoop,
# tri tabs W/E = rain-sky teal paper flaps (the cell 5-1 sky colours), pale rain streaks from the cell across the paper.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PAPER = K.ramp('#ef8723')     # picture lantern orange
PAPER_DK = K.ramp('#c96a1c')
BAMBOO = K.ramp('#8a5a2a')
SKY = K.ramp('#8eb5b2')       # cell sky teal
FLAME = K.ramp('#f8c840')
FLAMECORE = K.ramp('#fbe9a0')
RAIN = '#e2eeea'


def fn(c):
    k = 1.15 if c.small else 1.0
    # lantern bag: shoulders rounded at the top, slight taper to the hoop; straight sides kept for the piece read
    core = K.poly([(15, 18), (17, 14), (47, 14), (49, 18), (47.5, 50), (16.5, 50)])
    tN = K.knob('T', 'tri', 32, 14, 0, -1, r=4.6 * k)
    tS = K.knob('T', 'tri', 32, 50, 0, 1, r=5.2 * k)
    tW = K.knob('T', 'tri', 15.7, 33, -1, 0, r=4.4 * k)
    tE = K.knob('T', 'tri', 48.3, 33, 1, 0, r=4.4 * k)
    paper = c.m(core, tW, tE)
    c.add(paper, PAPER, stitch=None)
    # warm glow in the lower paper
    c.add(paper & c.m(K.rect(0, 39, 64, 47)), K.ramp('#f6a83a'))
    c.add(c.m(K.rect(17, 41.5, 47, 46)), K.ramp('#fbc860'))
    # peaked bamboo top knot + bottom wire hoop and flame tab
    c.add(c.m(tN, minus=(core,)), BAMBOO)
    c.add(c.m(K.rect(16, 46.5, 48, 50.5)), BAMBOO)
    c.add(c.m(tS, minus=(K.rect(0, 0, 64, 50.5),)), FLAME)
    c.add(c.m(K.ell(32, 54.8, 1.7 * k, 2.2 * k)), FLAMECORE)
    # bamboo hoops (horizontal) across paper and side tabs: the lantern's ribs
    for ry in (21, 39):
        y = c.P(0, ry)[1]
        for x in range(c.n):
            if (x, y) in paper:
                c.px(x, y, PAPER_DK[1])
    # vertical seams
    for rx in (22.5, 41.5):
        x = c.P(rx, 0)[0]
        for y in range(c.P(0, 15)[1], c.P(0, 39)[1]):
            c.px(x, y, PAPER_DK[0])
    # rain from the cell sky: pale teal streaks running down the paper
    for (sx, sy) in ((19, 25), (45, 27), (19, 43), (44, 42)):
        x, y = c.P(sx, sy)
        c.px(x, y, SKY[2])
        c.px(x - 1, y + 1, SKY[2])
        if not c.small:
            c.px(x - 2, y + 2, SKY[0])
    # face on the calm paper between the seams
    c.eye(28, 28)
    c.eye(36.5, 28)
    c.smile(32.2, 33)
    c.blush(25.5, 32)
    c.blush(39, 32)


rep = K.render_pal(fn, 'mt-sky-lantern', 'Sky Lantern', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/mt-sky-lantern-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mt-sky-lantern.png')
print(rep)
