"""pl-gaun-6 Pampas Rider. whimsy-horse, round knobs: a chunky side-view horse whose barrel + legs are the square piece core.
N round tab = the gaucho gnome rider's head under a flat hat, E round tab = the tail, S round blank = the gap between the legs,
W = the horse's neck and head breaking out (whimsy). Horse browns + mane plum from the picture, pampas yellow-green from cell 8-5
as the saddle blanket and the grass tufts at the hooves."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

HORSE = ('#a86a48', '#7a4a32', '#c88858')
MANE = ('#5a3040', '#472837', '#7a4858')
GRASS = ('#b8b850', '#7a8a48', '#e8e078')
PAMPA = K.ramp('#d0cc64')
SKIN = ('#f0c09a', '#c89070', '#f8dcc0')
HAT = ('#4a2c1a', '#3a2214', '#6a4430')
PONCHO = ('#c8402a', '#8e2a1c', '#e8704a')
BEARD = ('#f4f0e4', '#c9c5bc', '#ffffff')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(20, 26, 52, 57)
    tabN = K.knob('T', 'round', 37, 26, 0, -1, r=5.2 * k)
    tabE = K.knob('T', 'round', 52, 34, 1, 0, r=4.8 * k)
    blankS = K.knob('B', 'round', 36, 57, 0, 1, r=5.0 * k)
    # neck + head: a wedge rising up-left from the chest, muzzle pointing down-left
    neck = K.poly([(20, 40), (20, 27), (25, 26), (19, 13), (14, 7), (10, 7), (5, 15), (3, 22), (7, 24), (12, 20), (13, 30)])
    ear = K.poly([(14, 8), (16, 1.5), (18.5, 9)])
    body = c.m(core, neck, ear, tabE, minus=(blankS,))
    c.add(body, HORSE, stitch=None)
    # muzzle darker
    c.add(c.m(K.ell(5.5, 19.5, 4.2, 4.2)) & body, K.ramp('#8a5238'))
    # mane along the back of the neck
    c.add(c.m(K.thick_path([(15, 8), (20, 15), (24, 23), (26, 27)], 4.0 if not c.small else 4.6)) & body, MANE)
    # tail = E tab
    c.add(c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(K.rect(50, 0, 53, 64))), MANE)
    # saddle blanket in pampas green with a lighter stripe
    blanket = c.m(K.rect(28, 25, 47, 37))
    c.add(blanket & body, PAMPA)
    c.add(c.m(K.rect(28, 33, 47, 35.5)) & body, GRASS)
    # rider = N tab: red poncho shoulders, skin face, white beard, flat gaucho hat
    rider = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 24, 64, 27)))
    c.add(rider, SKIN)
    c.add(c.m(K.rect(30, 22, 44, 27)) & c.m(tabN), PONCHO)
    c.add(c.m(K.ell(37, 21.5, 3.6, 2.6)) & c.m(tabN), BEARD)
    c.add(c.m(K.rect(29.5, 11.5, 44.5, 13.6)), HAT)
    c.add(c.m(K.rect(32.5, 7.5, 41.5, 12)), HAT)
    # grass tufts at the hooves (bottom band of the legs), jagged tops
    tuft = c.m(lambda x, y: y >= 52.5 + (1.6 if int(x) % 4 < 2 else 0))
    c.add(tuft & body, GRASS)
    # leg separation lines (front pair / back pair)
    if not c.small:
        for gx in (25, 47):
            x, _ = c.P(gx, 0)
            for y in range(c.P(0, 46)[1], c.P(0, 53)[1]):
                c.px(x, y, HORSE[1])
    else:
        for gx in (25, 47):
            x, _ = c.P(gx, 0)
            for y in range(c.P(0, 47)[1], c.P(0, 52)[1]):
                c.px(x, y, HORSE[1])
    # faces
    c.eye(12.5, 13)
    c.px(*c.P(3.6, 19.5), K.UMBER2)
    for ex in (35, 39.5):
        x, y = c.P(ex, 16.6)
        c.px(x, y, K.UMBER)
        if not c.small:
            c.px(x, y + 1, K.UMBER)
    if not c.small:
        c.blush(33.5, 19)
        c.blush(40, 19)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-gaun-6', 'Pampas Rider', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gaun-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gaun-6.png'))
