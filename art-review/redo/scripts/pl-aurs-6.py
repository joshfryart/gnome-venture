"""pl-aurs-6 Towel Bear (whimsy-bear, round): a sleepy bear soaking in a wooden hot tub, the whole pal one square-ish piece.
Round ears break out of the top corners, the N round tab is the folded striped towel on its head, the E round tab is a paw
waving at the aurora, a round blank bites into the W side of the tub; flat bottom. Fur tan, towel white + red stripe,
cyan water, orange tub with plum hoops, an aurora-green ribbon on the towel (cell 3-6: paw on the tub rim over cyan water)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

FUR = K.ramp('#d0ad8a')
FUR = (FUR[0], '#b4845e', '#e8d0b0')
MUZ = ('#efd4c1', '#d0ad8a', '#fdedd5')
EAR_IN = '#b4845e'
TOWEL = ('#fff5e7', '#d8ccc0', '#ffffff')
RED = '#f16063'
WATER = ('#5fd5df', '#3aa8b8', '#b0eef2')
TUB = ('#cc8452', '#8e5634', '#e8a868')
HOOP = '#6e3a48'
AUR = '#38d898'
NOSE = '#4a3844'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 22, 54, 59)
    earL = K.ell(15.5, 20, 6.2, 6.2)
    earR = K.ell(48.5, 20, 6.2, 6.2)
    tabN = K.knob('T', 'round', 32, 22, 0, -1, r=5.2 * k)
    tabE = K.knob('T', 'round', 54, 31, 1, 0, r=4.8 * k)
    blankW = K.knob('B', 'round', 10, 50, -1, 0, r=5.0 * k)
    body = c.m(core, earL, earR, tabN, tabE, minus=(blankW,))
    c.add(body, FUR, stitch=None)
    # ear insides
    for ex in (15.5, 48.5):
        c.add(c.m(K.ell(ex, 20.5, 3.0, 3.0)), (EAR_IN, EAR_IN, EAR_IN))
    # towel: band over the crown + the folded bundle (N tab)
    towel = c.m(tabN, K.ell(32, 23.5, 14, 5.0)) & body
    c.add(towel, TOWEL)
    c.edge(towel, '#d8ccc0')
    sw = 1.6 if not c.small else 2.2
    c.add(c.m(K.rect(25.5, 15.5 - sw / 2, 38.5, 15.5 + sw / 2)) & towel, (RED, '#c04044', '#f88a8c'))
    c.add(c.m(K.rect(17, 24.2, 47, 24.2 + sw)) & towel, (RED, '#c04044', '#f88a8c'))
    # waving paw (E tab) a shade lighter + pad
    paw = c.m(tabE, minus=(K.rect(0, 0, 54.5, 64),))
    c.add(paw, FUR)
    c.edge(c.m(tabE) & body, '#b4845e')
    c.px(*c.P(61, 31), EAR_IN)
    # muzzle
    c.add(c.m(K.ell(32, 36.5, 7.2, 5.0)), MUZ)
    nx, ny = c.P(32, 34.2)
    for dx in ((-1, 0, 1) if not c.small else (0, 1)):
        c.px(nx + dx, ny, NOSE)
    if not c.small:
        c.px(nx, ny + 1, NOSE)
    c.smile(32, 37.5, NOSE)
    # sleepy closed eyes (down-turned arcs)
    for ex in (24, 40):
        x, y = c.P(ex, 31.5)
        if not c.small:
            for dx, dy in ((-2, 0), (-1, 1), (0, 1), (1, 1), (2, 0)):
                c.px(x + dx, y + dy, K.UMBER)
        else:
            for dx, dy in ((-1, 0), (0, 1), (1, 0)):
                c.px(x + dx, y + dy, K.UMBER)
    c.blush(19.5, 35)
    c.blush(43.5, 35)
    # water ring + tub
    water = body & c.m(K.rect(0, 42, 64, 46))
    c.add(water, WATER)
    tub = body & c.m(K.rect(0, 45.5, 64, 64))
    c.add(tub, TUB)
    for hy in (48.5, 55.5):
        y = c.P(0, hy)[1]
        for x in range(c.n):
            if (x, y) in tub:
                c.px(x, y, HOOP)
                if not c.small:
                    c.px(x, y + 1, HOOP)
    if not c.small:
        for sx in (18, 26, 34, 42, 50):
            x = c.P(sx, 0)[0]
            for y in range(c.P(0, 50.5)[1], c.P(0, 55.5)[1]):
                if (x, y) in tub:
                    c.px(x, y, TUB[1])
        # ripples
        for x in range(c.P(12, 0)[0], c.P(52, 0)[0]):
            if x % 5 in (0, 1):
                c.px(x, c.P(0, 43)[1], WATER[2])
    # paws resting on the tub rim (the cell)
    for px_ in (19, 45):
        pm = c.m(K.ell(px_, 45.3, 4.4, 2.8))
        c.add(pm, FUR)
        c.edge(pm, '#8e5e40')
        if not c.small:
            x, y = c.P(px_, 46.5)
            c.px(x - 1, y, '#8e5e40')
            c.px(x + 1, y, '#8e5e40')


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-aurs-6', 'Towel Bear', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-aurs-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-aurs-6.png')
    print(rep)
