"""pl-migr-1 Powderpuff Dust: corner-TT, keyhole. A lumpy savanna dust cloud that IS a corner piece: flat W + S sides, a scalloped
cloud top of many small billows, keyhole tabs N + E as big round billows, little dust puffs trailing off the lower right, and a
trodden-earth band at the base where a tiny dark wildebeest herd runs (cell 3-4: sunset peach sky, rose-tan dust, plum herd)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

DUST = K.ramp('#c8987d')
PEACH = K.ramp('#f4c890')
EARTH = K.ramp('#9a6e68')
HERD = '#3a2630'
SWIRL = '#f2dcae'

GNU = ["#.#.......",
       ".##..#....",
       ".########.",
       "..#######.",
       "..#.#..#.#"]
GNU_S = ["#.#....",
         ".#####.",
         ".#...#."]


def fn(c):
    k = 1.12 if c.small else 1.0
    clip = K.rect(6, 0, 64, 58)
    core = K.rect(6, 31, 49, 58)
    bumps = [K.ell(11.5, 31, 5.5, 5.5), K.ell(20, 26, 6.5, 6.5), K.ell(26, 31, 4, 4),
             K.ell(38, 31, 4, 4), K.ell(44, 26, 6.5, 6.5), K.ell(50, 32, 5, 5)]
    side = [K.ell(49.5, 48, 4, 4)]
    trail = [K.ell(52, 53.5, 4.5, 4.5), K.ell(58.5, 55, 3.2, 3.2)]
    tabN = K.knob('T', 'keyhole', 32, 27, 0, -1, r=7.6 * k, nw=3.6)
    tabE = K.knob('T', 'keyhole', 52, 40, 1, 0, r=6.4 * k, nw=3.0)
    whole = c.m(core, K.rect(27, 27, 37, 33), *bumps, *side, *trail, tabN, tabE)
    clipm = c.m(clip)
    whole &= clipm
    c.add(whole, DUST)
    c.add(c.m(tabN, minus=(core, K.rect(27, 28, 37, 33), *bumps)) & clipm, PEACH)
    c.add(c.m(tabE, minus=(core, *bumps, *side, *trail)) & clipm, PEACH)
    # sunlit tops of the billows, a darker gap line under each top billow
    lit = c.m(*bumps, minus=(K.rect(0, 33, 64, 64),)) & clipm
    c.add(lit, ('#e8b48c', '#b88a72', '#f6d6a8'))
    if not c.small:
        for b in trail[:1]:
            c.edge(c.m(b, minus=(K.rect(0, 0, 64, 52), K.rect(0, 0, 48, 64))) & whole, DUST[1])
    # trodden earth band with the running herd
    ground = whole & c.m(lambda x, y: y >= 50 and x < 50)
    c.add(ground, EARTH)
    if not c.small:
        for gx, gy in ((9, 51), (21, 52), (33, 51)):
            for j, row in enumerate(GNU):
                for i, ch in enumerate(row):
                    if ch == '#':
                        c.px(gx + i, gy + j, HERD)
        for dx, dy in ((44, 54), (46, 52)):
            c.px(dx, dy, EARTH[2])
    else:
        for gx, gy in ((5, 29), (13, 30)):
            for j, row in enumerate(GNU_S):
                for i, ch in enumerate(row):
                    if ch == '#':
                        c.px(gx + i, gy + j, HERD)
    # dust swirls in the tabs
    if not c.small:
        c.line([(29, 15), (31, 12), (35, 13), (35, 17), (32, 17)], SWIRL)
        c.line([(60, 37), (63, 39), (62, 43), (59, 42)], SWIRL)
        c.line([(15, 24), (19, 21), (23, 21)], SWIRL)
        c.line([(40, 24), (44, 21), (47, 22)], SWIRL)
    else:
        c.line([(29, 15), (32, 12.5), (35, 15)], SWIRL)
    # sleepy happy face
    c.eye(22, 40)
    c.eye(36, 40)
    c.blush(17.5, 44.5)
    c.blush(39, 44.5)
    c.smile(29, 44.5, '#4a2c1a')


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-migr-1', 'Powderpuff Dust', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-migr-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-migr-1.png')
    print(rep)
