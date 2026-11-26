"""pl-jrc-5 "Sunspill Arch": inner-BBBB, round. A plum cave-rock creature whose wide open MOUTH is the sunlit cave arch:
through it you see the mint sky, the pale sun and the green hills of cell 10-4. Round blanks: N in the domed crown,
W + E in the cheeks, S at the foot of the doorway (the path out). Moss tufts on the crown from the cell's greens."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

ROCK = ramp('#5e4258')
ROCK2 = ramp('#47324a')
SKY = ramp('#a8dcc8')
PALE = ramp('#c8ecc0')
HILL = ramp('#65af5d')
HILL2 = ramp('#4e9a56')
TREE = ramp('#2c6048')
SUN = ('#fff2a0', '#e8c860', '#ffffd8')
MOSS = ramp('#5aa55e')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = [rect(9, 24, 55, 57), ell(32, 25, 23, 17)]
    bN = knob('B', 'round', 32, 8, 0, -1, r=3.8 * k)
    bW = knob('B', 'round', 9, 41, -1, 0, r=3.4 * k)
    bE = knob('B', 'round', 55, 41, 1, 0, r=3.4 * k)
    bS = knob('B', 'round', 32, 57, 0, 1, r=3.4 * k)
    cut = (bN, bW, bE, bS)
    body = c.m(*core, minus=cut)
    c.add(body, ROCK, stitch=None if c.small else '#7a5a70')
    # moss tufts on the crown shoulders
    moss = c.m(ell(17, 15, 6, 4.5), ell(47, 15, 6, 4.5), ell(24, 10.5, 4.5, 3.5), ell(40, 10.5, 4.5, 3.5)) & body
    moss = moss - c.m(rect(0, 0, 64, 64), minus=(lambda x, y: y < 14 + (1.5 if (int(x) // 3) % 2 else 0),))
    c.add(moss & body, MOSS)
    # the mouth = the sunlit arch
    door = c.m(rect(21.5, 33, 42.5, 57), ell(32, 33, 10.5, 11), minus=cut) & body
    c.add(door, SKY)
    c.edge(door, ROCK2[1])
    c.add(door & c.m(rect(0, 39, 64, 64)), PALE)
    c.add(door & c.m(ell(28, 52, 13, 9)), HILL2)
    c.add(door & c.m(ell(40, 54, 10, 10)), HILL)
    c.add(door & c.m(poly([(21, 57), (21, 40), (24, 44), (27, 57)])), TREE)
    sx, sy = c.P(36, 30)
    rr = 2 if c.small else 3
    for dx in range(-rr, rr + 1):
        for dy in range(-rr, rr + 1):
            if dx * dx + dy * dy <= rr * rr + (0 if c.small else 1):
                c.px(sx + dx, sy + dy, SUN[2] if dx + dy < 0 else SUN[0])
    # stone teeth hanging at the top of the mouth (stalactites)
    for tx in (26, 38):
        c.add(c.m(poly([(tx - 2.2, 22), (tx + 2.2, 22), (tx, 27 if c.small else 26.5)])) & body, ROCK)
    # rock speckles
    if not c.small:
        for (x, y) in body:
            if (x * 7 + y * 3) % 23 == 0 and (x, y) not in door and (x, y) not in moss:
                c.px(x, y, ROCK2[0])
    c.eye(20, 25, disc=True)
    c.eye(44, 25, disc=True)
    c.blush(16, 31)
    c.blush(47, 31)


K.render_pal(fn, 'pl-jrc-5', 'Sunspill Arch', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-jrc-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-jrc-5.png')
