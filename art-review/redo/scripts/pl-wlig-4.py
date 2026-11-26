# pl-wlig-4 "Sunset Layer Cake": inner-TTTT, double knobs. A square layer cake that IS the piece: purple frosting top with drips,
# salmon / gold / peach sponge bands (the sunset bands of the lighthouse sky, cell 4-3 salmon), N double tab = two cherries,
# E + W double tabs = gold sponge bulging out, S double tab = a purple sea-coloured cake stand foot.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PURP = K.ramp('#7a4e98')
LILAC = K.ramp('#b07ab8')
SALM = K.ramp('#ec8a78')
GOLD = K.ramp('#f6c068')
PEACH = K.ramp('#f2a37c')
CREAMF = K.ramp('#f8e4c4')
CHERRY = K.ramp('#d8325a')
SEA = K.ramp('#5a3a7a')


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 14, 18, 50, 53
    core = K.rect(x0, y0, x1, y1)
    tN = K.knob('T', 'double', 32, y0, 0, -1, r=5.2 * k)
    tS = K.knob('T', 'double', 32, y1, 0, 1, r=4.6 * k)
    tE = K.knob('T', 'double', x1, 34.5, 1, 0, r=4.8 * k)
    tW = K.knob('T', 'double', x0, 34.5, -1, 0, r=4.8 * k)
    body = c.m(core, tE, tW)
    # layers bottom-up
    c.add(body & c.m(K.rect(0, 39.5, 64, 64)), PEACH)
    c.add(body & c.m(K.rect(0, 37.5, 64, 39.5)), CREAMF)
    c.add(body & c.m(K.rect(0, 31.5, 64, 37.5)), GOLD)
    c.add(body & c.m(K.rect(0, 29.5, 64, 31.5)), CREAMF)
    c.add(body & c.m(K.rect(0, 0, 64, 29.5)), SALM)
    # frosting top with drips
    def frost(x, y):
        if y < y0 or y >= 64 or not (x0 <= x < x1):
            return False
        lim = 24.5
        for dx, dl in ((17, 4.5), (24, 2.5), (31, 5.5), (39, 3), (46, 5)):
            if abs(x - dx) < 2.2:
                lim = 24.5 + dl
        return y < lim
    fm = c.m(frost)
    c.add(fm, LILAC)
    c.edge(fm, PURP[1])
    # cherries (N tab)
    c.add(c.m(tN, minus=(core,)), CHERRY)
    # stand foot (S tab) in sea purple
    c.add(c.m(tS, minus=(core,)), SEA)
    # plate band at the bottom
    c.add(c.m(K.rect(x0, y1 - 2.5, x1, y1)), SEA)
    # cherry stems + glint
    c.line([(32, 10), (32, 18)], CHERRY[1])
    c.line([(32, 5), (32, 8)], '#4a7a3a')
    c.px(*c.P(28.5, 11.5), CHERRY[2])
    c.px(*c.P(35, 11.5), CHERRY[2])
    # sprinkle dots on frosting
    for sx, sy, col in ((20, 21.5, GOLD[2]), (27, 22.5, '#f6b8cf'), (37, 21.5, GOLD[0]), (44, 22.5, '#f6b8cf')):
        c.px(*c.P(sx, sy), col)
    # face on the gold band
    c.eye(25, 43.5)
    c.eye(39, 43.5)
    c.smile(32, 46)
    c.blush(21, 46.5)
    c.blush(42, 46.5)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wlig-4', 'Sunset Layer Cake', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wlig-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wlig-4.png'))
