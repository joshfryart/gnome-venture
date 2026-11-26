import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import math
import pal_kit as K

# Apricot Sunbun: a brioche sun-bun as an inner piece (TBTB, keyhole). Top tab = the bun's top knot,
# left/right blanks cut into the bun, bottom tab sits in the pink cloud band the sun sinks behind.
SUN = K.ramp('#f0a050')
GLOW = K.ramp('#f8c878')
CLOUD = K.ramp('#f0a0a0')
MAUVE = K.ramp('#c878a8')
CREAM = K.ramp('#f0dcb8')

def rrect(x0, y0, x1, y1, r):
    def f(x, y):
        if not (x0 <= x < x1 and y0 <= y < y1):
            return False
        cx = min(max(x, x0 + r), x1 - r); cy = min(max(y, y0 + r), y1 - r)
        return (x - cx) ** 2 + (y - cy) ** 2 < r * r
    return f

def fn(c):
    s = 1.15 if c.small else 1.0
    core0 = rrect(11, 13, 53, 53, 6)
    sun = K.ell(32, 34, 27, 23)
    core = lambda x, y: core0(x, y) and (y > 36 or sun(x, y))
    top = K.knob('T', 'keyhole', 32, 13, 0, -1, r=4.8 * s)
    bot = K.knob('T', 'keyhole', 32, 53, 0, 1, r=4.8 * s)
    lb = K.knob('B', 'keyhole', 11, 31, -1, 0, r=5.0 * s)
    rb = K.knob('B', 'keyhole', 53, 31, 1, 0, r=5.0 * s)
    c.add(c.m(core, top, bot, minus=(lb, rb)), SUN)
    # top knot a touch lighter (brioche tete)
    c.add(c.m(K.ell(32, 7.6, 5.2 * s, 5.2 * s), K.rect(29, 7, 35, 14), minus=(lambda x, y: y > 13.5,)), GLOW)
    c.edge(c.m(K.ell(32, 7.6, 5.2 * s, 5.2 * s), K.rect(29, 7, 35, 14), minus=(lambda x, y: y > 13.5,)), SUN[1])
    # sun-glow halo disc around the face with short glow rays (sun cue), light from upper left
    c.add(c.m(K.ell(32, 27, 13, 11)), GLOW)
    w = 3.0 if c.small else 2.6
    rays = []
    for a in (-160, -125, -90, -55, -20):
        t = math.radians(a)
        rays.append(K.thick_path([(32 + 14 * math.cos(t), 27 + 12.5 * math.sin(t)), (32 + 18.5 * math.cos(t), 27 + 16 * math.sin(t))], w))
    c.add(c.m(*rays), GLOW)
    c.add(c.m(K.ell(32, 27, 11, 9)), SUN)
    # cloud band with scalloped top: the sun sinking behind
    def cloud(x, y):
        bumps = [(15, 47, 4.5), (24, 45.5, 4.8), (33, 46.5, 4.5), (42, 45.5, 4.8), (50, 47, 4.5)]
        return y > 48 or any((x - bx) ** 2 + (y - by) ** 2 < r * r for bx, by, r in bumps)
    cm = c.m(core, bot, minus=(lambda x, y: not cloud(x, y), lb, rb))
    c.add(cm, CLOUD)
    c.edge(cm, MAUVE[0])
    # mauve dusk lip at the very bottom, cream stone tip in the bottom tab
    c.add(c.m(core, minus=(lambda x, y: y < 51.5,)), MAUVE)
    c.add(c.m(bot, minus=(lambda x, y: y < 53,)), CLOUD)
    # face on the bun
    c.eye(27, 26)
    c.eye(37, 26)
    c.blush(24, 30)
    c.blush(39, 30)
    c.smile(32, 30)
    # score lines on the bun (sun rays hint) at 64 only
    if False:
        for a in ():
            t = math.radians(a - 90)
            c.line([(32 + 12 * math.cos(t), 27 + 12 * math.sin(t)), (32 + 16 * math.cos(t), 27 + 16 * math.sin(t))], SUN[1])

K.render_pal(fn, 'pl-skyc-3', 'Apricot Sunbun', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-skyc-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-skyc-3.png')
print(K.check(K.draw(fn, 64))['colours'])
