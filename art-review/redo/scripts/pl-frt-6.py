import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

# Ice crown of the frost toad's barrow: 5 rounded ice spikes on top (whimsy edge), snowy band body with the barrow's
# green moss strip at the bottom; hook tabs on left + right, hook blank in the bottom. Colours: snow white, ice blue, moss green.
SNOW = K.ramp('#e8f2f4')
ICE = K.ramp('#9fd0e0')
ICE2 = K.ramp('#cdeaf2')
MOSS = K.ramp('#6aae46')
GEM = K.ramp('#4a90c0')
TOADEYE = '#d8e04a'


def fn(c):
    S = 1.15 if c.small else 1.0
    core = K.rect(13, 28, 51, 54)
    # crown spikes (rounded tips): centre tallest
    spikes = []
    for cx, top, hw in ((16, 15, 5), (24.5, 10, 5), (32, 5, 5.5), (39.5, 10, 5), (48, 15, 5)):
        spikes.append(K.poly([(cx - hw, 29), (cx - 1.4, top + 1.5), (cx + 1.4, top + 1.5), (cx + hw, 29)]))
        spikes.append(K.ell(cx, top + 2, 1.8, 1.8))
    tL = K.knob('T', 'hook', 13, 41, -1, 0, r=4.5 * S)
    bR = K.knob('B', 'hook', 51, 42, 1, 0, r=4.5 * S)
    body = c.m(core, tL, *spikes, minus=(bR,))
    c.add(body, SNOW)
    c.add(c.m(tL, minus=(core,)), ICE2)
    # spikes in ice blue, with pale inner facet
    sp = c.m(*spikes, minus=(K.rect(0, 28, 64, 64),))
    c.add(sp, ICE)
    facet = c.m(*[K.poly([(cx - 1, 27), (cx - 0.6, top + 4), (cx + 1.6, 27)]) for cx, top in ((16, 15), (24.5, 10), (32, 5), (39.5, 10), (48, 15))])
    c.add(facet & sp, ICE2)
    # moss band at bottom (and on the tabs), wavy top edge
    moss = c.m(K.poly([(0, 48), (10, 48), (18, 46.5), (26, 48.5), (36, 46.5), (46, 48.5), (64, 47), (64, 64), (0, 64)]),
               ) & body - c.m(K.rect(0, 0, 13, 64))
    c.add(moss, MOSS, stitch=None)
    c.edge(moss, MOSS[1])
    # snow lumps on moss
    c.add(c.m(K.ell(20, 51, 2.6, 1.6), K.ell(33, 52, 2.6, 1.6)) & body, SNOW)
    # crown rim: band of gems
    rim = c.m(K.rect(13, 28, 51, 31.5)) & body
    c.add(rim, ICE)
    for gx in (19, 32, 45):
        c.add(c.m(K.ell(gx, 29.8, 1.9, 1.9)), GEM)
    # toad face on the snowy band
    c.eye(24, 38, disc=False)
    c.eye(36, 38, disc=False)
    if not c.small:
        for x in (24, 25, 26):
            pass
    c.smile(30, 42, wide=True)
    c.blush(20, 41.5)
    c.blush(40, 41.5)


K.render_pal(fn, 'pl-frt-6', 'Barrow Icecrown', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-frt-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-frt-6.png')
