"""pl-turt-6 Moonshell Hatchling (whimsy-hatchling, peg): a top-down sea-turtle hatchling that IS a piece. Square shell = body,
N peg tab = head, E + W peg tabs = front flippers, S peg blank between the hind flippers. Shell rim in the turtle green, scutes in
the night-sea blue of cell 7-5 with a cream crescent moon and a gold star speck."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

GREEN = K.ramp('#6cb850')
LEAF = K.ramp('#9ace64')
SEA = K.ramp('#3e74ac')
NIGHT = K.ramp('#2a5c9c')
MOON = ('#fff4d6', '#e0c890', '#ffffff')
STAR = '#ffd860'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.ell(32, 37, 21, 19)          # rounded-square shell via superellipse below
    def shell(x, y):
        return ((abs(x - 32) / 20.5) ** 3.2 + (abs(y - 37) / 18.5) ** 3.2) < 1
    head = K.knob('T', 'peg', 32, 18.8, 0, -1, r=4.4 * k, nw=3.0)
    headball = K.ell(32, 10.5, 8.2, 6.8)
    finE = K.knob('T', 'peg', 52.3, 32, 1, 0, r=4.6 * k, nw=2.8)
    finW = K.knob('T', 'peg', 11.7, 32, -1, 0, r=4.6 * k, nw=2.8)
    blankS = K.knob('B', 'peg', 32, 55.6, 0, 1, r=4.0 * k, nw=2.4)
    # hind flippers: little rounded lobes poking down at the bottom corners
    hindW = K.thick_path([(18, 52), (12.5, 57.5)], 6.4)
    hindE = K.thick_path([(46, 52), (51.5, 57.5)], 6.4)
    body = c.m(shell, head, headball, finE, finW, hindW, hindE, minus=(blankS,))
    c.add(body, GREEN, stitch=None)
    # head (lighter leaf green) and flippers
    c.add(body & c.m(head, headball, minus=(shell,)), LEAF)
    c.add(body & c.m(finE, finW, minus=(shell,)), LEAF)
    # flipper tips a shade darker so the pegs read as paddles
    c.add(body & c.m(K.rect(57, 0, 64, 64), K.rect(0, 0, 7, 64)), GREEN)
    c.add(body & c.m(hindW, hindE, minus=(shell,)), LEAF)
    # inner shell: the night sea, with scute plates
    inner = lambda x, y: ((abs(x - 32) / 15.5) ** 3 + (abs(y - 37) / 13.5) ** 3) < 1
    im = c.m(inner, minus=(blankS,))
    c.add(im, SEA, stitch=None if c.small else '#5a8cbc')
    c.edge(im, NIGHT[1])
    # crescent moon on the shell
    moon = c.m(K.ell(28, 36, 7.0, 7.0), minus=(K.ell(31.5, 34, 6.2, 6.2),))
    c.add(moon & im, MOON)
    # star specks
    for sx, sy in ((40, 30), (38, 43)):
        x, y = c.P(sx, sy)
        c.px(x, y, STAR)
        if not c.small:
            c.px(x + 1, y, STAR)
    # rim scute ticks
    if not c.small:
        for ang in range(0, 360, 40):
            import math
            a = math.radians(ang)
            x0, y0 = 32 + 16.5 * math.cos(a), 37 + 14.5 * math.sin(a)
            x1, y1 = 32 + 19.5 * math.cos(a), 37 + 17.5 * math.sin(a)
            c.line([(x0, y0), (x1, y1)], GREEN[1])
    # face on the head
    c.eye(28.0, 9.5)
    c.eye(36.0, 9.5)
    c.blush(25.5, 13)
    c.blush(38, 13)
    c.smile(32, 13)


K.render_pal(fn, 'pl-turt-6', 'Moonshell Hatchling', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-turt-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-turt-6.png')
