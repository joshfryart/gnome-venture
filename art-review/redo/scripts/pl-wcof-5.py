import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

# Doorway Aglow: inner-BBBB keyhole. A hut-wall block whose whole front is a glowing arched door (the face);
# thatch eave on top, the striped ceremony rug as the doormat at the bottom. Keyhole blanks echo a door lock.
WALL = ramp('#b48654')
THATCH = ramp('#d8a838')
FRAME = ramp('#c8641e')
GLOW = ('#f8c848', '#e89a28', '#fff0a8')
RUGY = ramp('#f0c040')
RUGR = ramp('#d84a30')
RUGT = ramp('#3a9a9a')
GROUND = ramp('#8a5a48')


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 3.3 * k
    core = rect(9, 9, 55, 55)
    bN = knob('B', 'keyhole', 32, 9, 0, -1, r=r)
    bS = knob('B', 'keyhole', 32, 55, 0, 1, r=r)
    bW = knob('B', 'keyhole', 9, 34, -1, 0, r=r)
    bE = knob('B', 'keyhole', 55, 34, 1, 0, r=r)
    blanks = (bN, bS, bE, bW)
    body = c.m(core, minus=blanks)
    c.add(body, WALL, stitch=None)
    # thatch eave (top band), with a slight overhang feel via darker lower lip
    eave = body & c.m(rect(0, 9, 64, 17))
    c.add(eave, THATCH)
    if not c.small:
        for (x, y) in eave:
            if (x + 2 * y) % 5 == 0:
                c.px(x, y, THATCH[1])
    lip = body & c.m(rect(0, 16, 64, 18))
    c.add(lip, THATCH)
    c.edge(lip, THATCH[1])
    # orange door frame + glowing arch
    frame = c.m(rect(17, 30, 47, 47), ell(32, 30, 15, 13)) & body
    c.add(frame, FRAME)
    glow = c.m(rect(20.5, 30, 43.5, 47), ell(32, 30, 11.5, 10)) & body
    c.add(glow, GLOW)
    core_glow = c.m(ell(32, 27, 6, 5)) & body
    for p in core_glow:
        c.px(p[0], p[1], GLOW[2])
    # door planks + knob: it is a door, not a ghost
    for gx in (26, 38):
        x = c.P(gx, 0)[0]
        for y in range(c.P(0, 30)[1], c.P(0, 46)[1]):
            if (x, y) in glow:
                c.px(x, y, GLOW[1])
    kx, ky = c.P(40.5, 41)
    for dx in range(2 if not c.small else 1):
        for dy in range(2 if not c.small else 1):
            c.px(kx + dx, ky + dy, FRAME[1])
    # rug doormat along the bottom: yellow / red / teal stripes
    rug = body & c.m(rect(0, 46, 64, 55))
    c.add(rug, RUGY)
    st = body & c.m(lambda x, y: 46 <= y < 55 and ((x - y) // 4) % 3 == 0)
    c.add(st, RUGR)
    st2 = body & c.m(lambda x, y: 46 <= y < 55 and ((x - y) // 4) % 3 == 1)
    c.add(st2, RUGT)
    c.edge(rug, ramp('#5a2e20')[0])
    # face inside the glowing door
    c.eye(27.5, 35)
    c.eye(36.5, 35)
    c.smile(32, 40, wide=not c.small)
    c.blush(24.5, 39)
    c.blush(38.5, 39)


K.render_pal(fn, 'pl-wcof-5', 'Doorway Aglow', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wcof-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wcof-5.png')
