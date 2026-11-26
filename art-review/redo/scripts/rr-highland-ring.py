# Highland Ring: a leafy canopy hoop (wreath ring with a hole through its middle) that is an inner piece, all four sides round blanks;
# frosty cloud cap on top (cloud-cold, highest hoop), a brown branch twining round it; greens + sky from cell 9-0.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

LEAF = ('#307a45', '#1f5a3a', '#5fa84f')
DEEP = ('#1f5a3a', '#143f2b', '#307a45')
BARK = K.ramp('#6a3a1e')
CLOUD = ('#f4f6f0', '#bfe0d7', '#ffffff')
SKY = '#bfe0d7'
SPRIG = '#60a850'


def fn(c):
    kk = 1.15 if c.small else 1.0
    r = 4.2 * kk
    x0, y0, x1, y1 = 7, 9, 57, 59
    # rounded square core
    core = [K.rect(x0 + 5, y0, x1 - 5, y1), K.rect(x0, y0 + 5, x1, y1 - 5),
            K.ell(x0 + 5, y0 + 5, 5, 5), K.ell(x1 - 5, y0 + 5, 5, 5), K.ell(x0 + 5, y1 - 5, 5, 5), K.ell(x1 - 5, y1 - 5, 5, 5)]
    cy = (y0 + y1) / 2
    blanks = [K.knob('B', 'round', 32, y0, 0, -1, r), K.knob('B', 'round', 32, y1, 0, 1, r),
              K.knob('B', 'round', x0, cy, -1, 0, r), K.knob('B', 'round', x1, cy, 1, 0, r)]
    hole = K.ell(32, cy - 1, 8.5, 8.5)
    body = c.m(*core, minus=blanks + [hole])
    c.add(body, LEAF, stitch=None if c.small else '#5fa84f')
    # inner rim of the hoop: darker ring around the hole
    rim = c.m(K.ell(32, cy - 1, 12.5, 12.5), minus=[hole] + blanks)
    c.add(rim, DEEP)
    # the hoop itself: a bark-wood ring around the hole, with leaf wraps crossing it
    hoop = c.m(K.ell(32, cy - 1, 11.2, 11.2), minus=[hole] + blanks)
    c.add(hoop, BARK)
    import math
    wraps = [K.ell(32 + 10 * math.cos(a), cy - 1 + 10 * math.sin(a), 3.2, 3.2) for a in (0.4, 2.0, 3.6, 5.2)]
    c.add(c.m(*wraps, minus=[hole] + blanks), LEAF)
    # cloud cap: frosty puffs sitting over the top corners (cloud-cold)
    cloud = c.m(K.ell(16, 11, 9, 6), K.ell(10, 15, 5, 5), K.ell(48, 11, 9, 6), K.ell(54, 15, 5, 5),
                minus=blanks + [hole])
    c.add(cloud, CLOUD)
    # branch twining round the hoop
    br = c.m(K.thick_path([(9, 40), (14, 44), (20, 42), (24, 48), (30, 52)], 2.8 if c.small else 2.2),
             K.thick_path([(55, 26), (50, 24), (46, 28), (44, 22)], 2.8 if c.small else 2.2), minus=blanks + [hole])
    c.add(br, BARK)
    # leaf sprigs (light pixels) in the canopy
    for (x, y) in [(13, 27), (51, 38), (40, 52), (24, 53), (50, 46), (14, 33), (48, 20), (18, 20)]:
        px, py = c.P(x, y)
        c.px(px, py, SPRIG)
        if not c.small:
            c.px(px + 1, py, SPRIG); c.px(px, py + 1, '#5fa84f')
    # frost glints on cloud
    if not c.small:
        for (x, y) in [(14, 9), (46, 9)]:
            px, py = c.P(x, y); c.px(px, py, SKY)
    # face on the lower band, flanking the bottom blank
    c.eye(22, 44 if not c.small else 43, disc=True)
    c.eye(42, 44 if not c.small else 43, disc=True)
    c.blush(17, 49)
    c.blush(46, 49)


rep = K.render_pal(fn, 'rr-highland-ring', 'Highland Ring', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/rr-highland-ring-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/rr-highland-ring.png')
print(rep)
