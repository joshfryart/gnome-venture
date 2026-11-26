"""pl-step-3 Marigold Dot Duo: a grass-sod inner piece (TBTB, keyhole). Top tab = orange marigold head on its stem,
bottom tab = sod root plug, keyhole blanks left/right cut into the turf. A pink flower sprouts from the top-left
corner and nods toward the marigold. Colours from cell 3-7: grass greens, pink + red/orange + white/yellow dots."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

GRASS = ('#529054', '#3a704a', '#7db06a')
DEEP = ('#3a704a', '#326145', '#529054')
STEM = ('#3f9150', '#326145', '#7db06a')
MARI = ('#f0901e', '#c0581a', '#ffd24a')
PINK = ('#f080a8', '#c05080', '#f8b8d0')
CORE = '#a8401e'
SOIL = ('#7a5434', '#54381f', '#a0784a')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(9, 19, 55, 49)
    top = K.knob('T', 'keyhole', 32, 19, 0, -1, r=4.0 * s)
    bot = K.knob('T', 'keyhole', 32, 49, 0, 1, r=5.2 * s)
    bl = K.knob('B', 'keyhole', 9, 34, -1, 0, r=4.8 * s)
    br = K.knob('B', 'keyhole', 55, 34, 1, 0, r=4.8 * s)
    mhead = K.ell(32, 7.0, 8.0, 6.4)
    phead = K.ell(12.5, 8.5, 5.6, 5.0)
    pstem = K.thick_path([(17, 20), (15, 14), (13.5, 10)], 3.0)
    body = c.m(core, bot, minus=(bl, br))
    c.add(body, GRASS, stitch=DEEP[0])
    # root plug: soil under the bottom tab
    c.add(c.m(bot, minus=(core,)), DEEP)
    c.add(c.m(K.rect(0, 58, 64, 64)) & c.m(bot), SOIL)
    # darker grass mottles (the cell's shadow patches)
    c.add(c.m(K.ell(24, 44, 9, 3.5), K.ell(44, 24, 6, 3)) & body, DEEP)
    # stems + flower heads
    c.add(c.m(top, minus=(core,)), STEM)
    c.add(c.m(pstem), STEM)
    mh = c.add(c.m(mhead), MARI)
    ph = c.add(c.m(phead), PINK)
    # petal notches + centres
    for (cx, cy, mask, col, rr) in ((32, 7.0, mh, MARI[1], 8.0), (12.5, 8.5, ph, PINK[1], 5.4)):
        import math
        for i in range(8 if mask is mh else 6):
            a = i * 2 * math.pi / (8 if mask is mh else 6)
            if c.small and mask is ph:
                continue
            c.line([(cx + math.cos(a) * rr * 0.45, cy + math.sin(a) * rr * 0.45),
                    (cx + math.cos(a) * rr * 0.8, cy + math.sin(a) * rr * 0.8)], col)
    c.add(c.m(K.ell(32, 7.0, 2.6, 2.4)), (CORE, '#7a2a14', '#e8493b'))
    c.add(c.m(K.ell(12.5, 8.5, 1.8, 1.7)), ('#ffd24a', '#e8a317', '#fff2dc'))
    # tiny dot flowers in the turf (white, yellow, red)
    for (x, y, col) in ((19, 24, '#fff2dc'), (46, 41, '#ffd24a'), (21, 42, '#e8493b'), (43, 27, '#f080a8')):
        px, py = c.P(x, y)
        c.px(px, py, col)
        if not c.small:
            c.px(px + 1, py, col); c.px(px, py + 1, col); c.px(px + 1, py + 1, col)
            c.px(px, py - 1, '#ffd24a' if col == '#fff2dc' else '#fff2dc')
    # face on the sod
    c.eye(26, 31)
    c.eye(38, 31)
    c.smile(32, 37)
    c.blush(21.5, 35)
    c.blush(41.5, 35)


K.render_pal(fn, 'pl-step-3', 'Marigold Dot Duo', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-step-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-step-3.png')
