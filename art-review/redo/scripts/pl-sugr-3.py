import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

# Sweet Steam Wander: the sugar-shack roof cupola (plum slatted vent, orange wood trim) with a puffy cloud of sweet steam pouring
# out of its top; the steam puff is the top tab, the wooden foot the bottom tab, round blanks cut both sides (inner-TBTB).
STEAM = ('#eef0fa', '#a8b4dc', '#ffffff')
SKY = K.ramp('#93a3d4')
WOOD = ('#d88a46', '#a05a28', '#eeac6a')
PLUM = ('#5e3450', '#3e2238', '#7a4a68')
SLAT = '#2e1e34'
ROOF = ('#ecebf4', '#b4bad8', '#ffffff')


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1, y0, y1 = 12, 52, 18, 52
    core = K.rect(x0, y0 + 3, x1, y1)
    # billowing steam top: a row of puffs along the top edge, the tallest puff in the middle is the tab
    billows = [K.ell(x0 + 4.5, y0 + 5, 4.5, 4.5), K.ell(21, y0 + 2.5, 4.6, 4.3), K.ell(43, y0 + 2.5, 4.6, 4.3), K.ell(x1 - 4.5, y0 + 5, 4.5, 4.5),
               K.rect(x0, y0 + 5, x1, y0 + 8)]
    top = K.knob('T', 'round', 32, y0 + 1, 0, -1, r=5.0 * k, nw=3.4)
    tc = y0 + 1 - (5.0 * k + 1.6)                 # centre of the tab's head: give it cloud puffs so it reads as a billow of steam
    puffs = [K.ell(32, y0 + 3.5, 9.5, 4.5)]   # soft shoulder: the tab swells out of the cloud, no notches beside the face
    wisp = K.ell(41, tc - 3, 3, 2.4)              # a curl of steam drifting off
    bot = K.knob('T', 'round', 32, y1, 0, 1, r=4.5 * k, nw=3.2)
    lb = K.knob('B', 'round', x0, 41, -1, 0, r=4.5 * k)
    rb = K.knob('B', 'round', x1, 41, 1, 0, r=4.5 * k)
    allp = c.m(core, top, bot, wisp, *puffs, *billows, minus=(lb, rb))
    yy = lambda v: c.P(0, v)[1]
    steam = {p for p in allp if p[1] < yy(30)}
    c.add(steam, STEAM)
    c.add({p for p in allp if yy(30) <= p[1] < yy(33)}, ROOF)                     # snowy eave of the cupola
    c.add({p for p in allp if yy(33) <= p[1] < yy(36)}, WOOD)                     # wood trim
    c.add({p for p in allp if yy(36) <= p[1] < yy(49)}, PLUM)                     # slatted vent
    c.add({p for p in allp if p[1] >= yy(49)}, WOOD)                               # sill and foot
    c.add(c.m(K.rect(x0, 36, x0 + 3.5, 49), K.rect(x1 - 3.5, 36, x1, 49)) & allp, WOOD)
    for sx in (21, 27, 33, 39, 45):
        w = 1.0 if c.small else 0.9
        c.add(c.m(K.rect(sx - w, 37, sx + w, 49)) & allp, (SLAT, SLAT, SLAT))
    for dx in (19, 31, 43):                                                          # snow drips over the trim
        c.add(c.m(K.ell(dx, 33.5, 2.2, 2)) & allp, ROOF)
    # soft blue shading between the billows and under the cloud
    sh = c.m(K.rect(x0, 27.5, x1, 30)) & steam
    for p in sh:
        c.px(p[0], p[1], '#c9d2ee')
    for (ax, ay, bx, by) in ((16.5, 20.5, 19, 21.5), (45, 21.5, 47.5, 20.5)):
        c.line([(ax, ay), (bx, by)], '#c9d2ee')
    c.eye(26, 23)
    c.eye(38, 23)
    c.smile(32, 26.5)
    c.blush(21, 26)
    c.blush(43, 26)


K.render_pal(fn, 'pl-sugr-3', 'Sweet Steam Wander', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sugr-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sugr-3.png')
