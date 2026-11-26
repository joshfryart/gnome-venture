import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Jade Sparklet: a cut jade gem = inner-TTTT piece, keyhole tabs on all four sides; table + facet lines,
# acacia green from the picture, dust brown smear with a wildebeest-purple hoof scuff on the lower cut edge.
JADE = K.ramp('#4fa24a')
JADEL = K.ramp('#8fd07a')
JADED = K.ramp('#2f7a3c')
DUST = K.ramp('#b07840')
HOOF = '#4a3a5a'
SPARK = '#fbe9a0'

def fn(c):
    k = 1.15 if c.small else 1.0
    r = 5.6 * k
    # gem core: square with chamfered (cut) corners
    core = K.poly([(19, 14), (45, 14), (51, 20), (51, 44), (45, 50), (19, 50), (13, 44), (13, 20)])
    tabs = [K.knob('T', 'keyhole', 32, 15, 0, -1, r=r, nw=3.2), K.knob('T', 'keyhole', 50, 32, 1, 0, r=r, nw=3.2),
            K.knob('T', 'keyhole', 32, 49, 0, 1, r=r, nw=3.2), K.knob('T', 'keyhole', 14, 32, -1, 0, r=r, nw=3.2)]
    body = c.m(core, *tabs)
    c.add(body, JADE)
    # dark lower-right facets (pavilion)
    dk = c.m(K.poly([(51, 20), (51, 44), (45, 50), (32, 50), (40, 40), (40, 26)]), tabs[1], tabs[2])
    c.add(dk & body, JADED)
    # light upper-left facets (crown)
    lt = c.m(K.poly([(13, 44), (13, 20), (19, 14), (32, 14), (24, 26), (24, 40)]), tabs[0], tabs[3])
    c.add(lt & body, JADEL)
    # table facet
    table = c.m(K.poly([(24, 26), (40, 26), (40, 40), (24, 40)]))
    c.add(table, JADE)
    c.edge(table, '#2a6a34')
    # facet lines from table corners to the cut corners
    fc = '#2a6a34'
    for a, b in (((24, 26), (19, 14)), ((40, 26), (45, 14)), ((40, 40), (45, 50)), ((24, 40), (19, 50))):
        c.line([a, b], fc)
    # dust from the herd clinging to the lower cut edge (paint only, never silhouette): cell brown + a purple hoof scuff
    dust = c.m(K.poly([(13, 44), (19, 50), (28, 50), (28, 48), (20, 47), (13, 41.5)]))
    c.add(dust & body, DUST)
    hx, hy = c.P(22, 48.5)
    c.px(hx, hy, HOOF)
    if not c.small:
        c.px(hx + 1, hy, HOOF); c.px(hx + 3, hy, HOOF); c.px(hx + 4, hy, HOOF)
    # sparkles on the crown
    sx, sy = c.P(18.5, 21)
    c.px(sx, sy, SPARK); c.px(sx + 1, sy, SPARK); c.px(sx, sy + 1, SPARK)
    if not c.small:
        c.px(sx - 1, sy, SPARK); c.px(sx, sy - 1, SPARK); c.px(sx + 2, sy, SPARK); c.px(sx, sy + 2, SPARK)
    tx, ty = c.P(40, 9)
    c.px(tx, ty, SPARK)
    # face on the table
    c.eye(28, 32)
    c.eye(36.5, 32)
    c.smile(32, 36.5)
    c.blush(25.5, 35.5); c.blush(38.5, 35.5)

K.render_pal(fn, 'pl-migr-4', 'Jade Sparklet', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-migr-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-migr-4.png')
