# Quill Bouquet (pl-wfla-2): a tied bouquet of flamingo feathers that IS an edge-TTB keyhole piece.
# Flat S = the quill ends cut flat (stands on the counter); keyhole tab N = the tallest feather's dark-tipped crown;
# keyhole tab E = the twine bow; keyhole blank W bites into the feather fan. Shallows pinks, lilac water, sun-gold twine (cell 5-3).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = K.ramp('#e8a0b8')
ROSE = K.ramp('#d8789c')
DEEP = K.ramp('#c8587c')
TIP = ('#5a3858', '#3a2840', '#7a5070')
LILAC = K.ramp('#b08aa8')
TWINE = ('#f0c860', '#b88a3a', '#fff0b8')
QUILL = '#fff6e0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 20, 52, 58)
    tabN = K.knob('T', 'keyhole', 32, 20, 0, -1, r=5.8 * k)
    tabE = K.knob('T', 'keyhole', 52, 47, 1, 0, r=4.4 * k)
    blankW = K.knob('B', 'keyhole', 12, 33, -1, 0, r=5.0 * k)
    # feather tips scallop gently above the core
    tips = [K.ell(15.5, 20, 5, 4.5), K.ell(24.5, 17.5, 5, 4.5), K.ell(39.5, 17.5, 5, 4.5), K.ell(48.5, 20, 5, 4.5)]
    body = c.m(core, tabN, tabE, *tips, minus=(blankW,))
    c.add(body, PINK)
    # feather vanes: alternating pinks, fanned columns
    cols = [(12, 21, ROSE), (21, 28, PINK), (28, 36, DEEP), (36, 43, PINK), (43, 52, ROSE)]
    vanes = []
    for x0, x1, rp in cols:
        m = body & c.m(K.rect(x0, 0, x1, 44))
        if x0 == 28:
            m |= body & c.m(tabN)
        if x0 == 21:
            m |= body & c.m(tips[1])
        if x0 == 36:
            m |= body & c.m(tips[2])
        m -= c.m(K.rect(52, 0, 64, 64))
        vanes.append(m)
        c.add(m, rp)
    for m in vanes[1:4]:
        c.edge(m, DEEP[1])
    # dark flamingo tip on the crown feather (tab N)
    c.add(body & c.m(K.ell(32, 6, 8, 5.5)), TIP)
    # feather barbs: chevrons sweeping up from each quill
    for (x0, x1, rp), qx in zip(cols, (16.5, 24.5, 32, 39.5, 47.5)):
        per = 3 if not c.small else 2.2
        for (x, y) in vanes[cols.index((x0, x1, rp))]:
            X, Y = (x + 0.5) / c.k, (y + 0.5) / c.k
            if Y > 42 or Y < 10 or c.small:
                continue
            if int((Y + abs(X - qx) * 0.9) / per) % 2 == 0 and abs(X - qx) > 1.0:
                c.px(x, y, rp[1] if not c.small else rp[2])
    # quill shafts
    for qx, top in ((16.5, 22), (24.5, 20), (32, 9), (39.5, 20), (47.5, 22)):
        w = 1.2 if not c.small else 1.8
        c.add(body & c.m(K.thick_path([(qx, top), (qx, 44)], w)), (QUILL, QUILL, QUILL))
    # twine wrap + bow (tab E)
    wrap = body & c.m(K.rect(12, 43, 52, 50))
    bow = body & c.m(tabE, minus=(K.rect(0, 0, 52, 64),))
    c.add(wrap | bow, TWINE)
    if not c.small:
        for x in range(c.P(13, 0)[0], c.P(52, 0)[0], 3):
            c.px(x, c.P(0, 46)[1], TWINE[1])
    c.edge(wrap, TWINE[1])
    # quill stems below the twine, lilac shallows
    stems = body & c.m(K.rect(12, 50, 52, 58))
    c.add(stems, LILAC)
    for gx in (18, 25, 32, 39, 46):
        x = c.P(gx, 0)[0]
        for y in range(c.P(0, 50)[1] + 1, c.n):
            if (x, y) in stems:
                c.px(x, y, QUILL if gx == 32 else LILAC[1])
    # face on the calm middle
    c.eye(26, 33, disc=True)
    c.eye(38, 33, disc=True)
    c.smile(32, 38)
    c.blush(21.5, 37)
    c.blush(42, 37)


K.render_pal(fn, 'pl-wfla-2', 'Quill Bouquet', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wfla-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wfla-2.png')
