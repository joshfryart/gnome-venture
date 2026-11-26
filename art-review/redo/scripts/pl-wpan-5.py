import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Panda that is an inner-BBBB keyhole piece: ears flank the top blank, dark arms carry the side blanks,
# dark feet flank the bottom blank; huge dark eye patches; bamboo stalk (the cell) held in its mouth.
FUR = K.ramp('#f4ecda')
DARK = K.ramp('#463a48')
BAM = ('#8ccc5c', '#4e9848', '#c8ec8c')
PATCH = '#3a2e3c'

def fn(c):
    s = 1.15 if c.small else 1.0
    r = 3.7 * s
    core = K.rect(8, 11, 56, 58)
    earL, earR = K.ell(13, 12, 7.5, 7), K.ell(51, 12, 7.5, 7)
    blanks = (K.knob('B', 'keyhole', 32, 11, 0, -1, r=r),
              K.knob('B', 'keyhole', 8, 43, -1, 0, r=r),
              K.knob('B', 'keyhole', 56, 43, 1, 0, r=r),
              K.knob('B', 'keyhole', 32, 58, 0, 1, r=r))
    c.add(c.m(core, minus=blanks), FUR, stitch='#d8ccb4')
    c.add(c.m(earL, earR, minus=blanks), DARK)
    # dark arms (side bands) and feet
    c.add(c.m(K.ell(8, 43, 13, 10), minus=blanks + (K.rect(-9, 0, 8, 64),)), DARK)
    c.add(c.m(K.ell(56, 43, 13, 10), minus=blanks + (K.rect(56, 0, 80, 64),)), DARK)
    c.add(c.m(K.rect(8, 53, 25, 58), K.rect(39, 53, 56, 58), minus=blanks), DARK)
    # eye patches (tilted ovals)
    for cx, tilt in ((22, 1), (42, -1)):
        pts = []
        import math
        for i in range(24):
            a = 2 * math.pi * i / 24
            x, y = 7.4 * math.cos(a), 5.8 * math.sin(a)
            ang = tilt * 0.45
            pts.append((cx + x * math.cos(ang) - y * math.sin(ang), 26 + x * math.sin(ang) + y * math.cos(ang)))
        for p in c.m(K.poly(pts)):
            c.px(p[0], p[1], PATCH)
    c.eye(22.5, 26.5, disc=not c.small)
    c.eye(41.5, 26.5, disc=not c.small)
    # nose + blush
    for p in c.m(K.ell(32, 33.5, 2.8, 1.9)):
        c.px(p[0], p[1], PATCH)
    c.blush(14, 33); c.blush(49, 33)
    # bamboo stalk in mouth
    bam = c.m(K.rect(28.5, 36, 35.5, 50))
    c.add(bam, BAM)
    c.line([(28.5, 43), (35, 43)], '#2f6a3a')

K.render_pal(fn, 'pl-wpan-5', 'Dark Eye Patches', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpan-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpan-5.png')
