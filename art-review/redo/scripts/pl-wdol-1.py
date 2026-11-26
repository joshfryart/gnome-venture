"""pl-wdol-1 Lilypad Parasol: corner-BB, keyhole. A round lily pad, top-down, that IS a corner piece: flat W and S sides
(the pad rests in the pool corner), the N keyhole blank is the pad's own notch (veins radiate from its tip), the E keyhole blank
bites the rim. Rounded NE rim with an upturned light lip. A pink blossom (the dolphin pink) sits on the pad; teal water ripples
and cream sparkles from cell 2-4 (dolphin-pools green, mint water, dolphin pink)."""
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PAD = K.ramp('#5aa476')
PADDK = K.ramp('#3f8a5c')
LIP = K.ramp('#8acc8e')
PINK = K.ramp('#e0a0c0')
PINKC = K.ramp('#f0cede')
GOLD = K.ramp('#f0d070')
VEIN = '#8acc8e'


def fn(c):
    s = 1.15 if c.small else 1.0
    # core: flat W (x=9) and S (y=56); NE corner rounded like a pad rim, NW/SE softly rounded
    core = lambda x, y: (9 <= x < 55 and 9 <= y < 56) and not (x > 41 and y < 23 and (x - 41) ** 2 + (y - 23) ** 2 > 14 ** 2) \
        and not (x < 14 and y < 14 and (x - 14) ** 2 + (y - 14) ** 2 > 5 ** 2) \
        and not (x > 50 and y > 51 and (x - 50) ** 2 + (y - 51) ** 2 > 5 ** 2)
    bN = K.knob('B', 'keyhole', 31, 9, 0, -1, r=4.6 * s)
    bE = K.knob('B', 'keyhole', 55, 38, 1, 0, r=4.2 * s)
    body = c.m(core, minus=(bN, bE))
    c.add(body, PAD, stitch=None if c.small else LIP[0])
    # upturned rim lip along the rounded NE edge + top-right
    lip = c.m(lambda x, y: core(x, y) and not (x < 51.5 and y > 12.5 and (x - 41) ** 2 + (y - 23) ** 2 < 11.5 ** 2 or (x < 51.5 and y >= 23) or (x <= 41 and y > 12.5)),
              minus=(bN, bE))
    c.add(lip, LIP)
    # veins radiating from the notch tip
    tip = (31, 24 if not c.small else 25)
    w = 1.6 if not c.small else 2.0
    for ang in (200, 235, 270, 305, 340, 20, 160):
        a = math.radians(ang)
        ex, ey = tip[0] + math.cos(a) * 40, tip[1] - math.sin(a) * 40
        v = c.m(K.thick_path([tip, (ex, ey)], w)) & body
        if c.small:
            v = {p for p in v if abs(p[0] - c.P(*tip)[0]) + abs(p[1] - c.P(*tip)[1]) > 3}
        face = c.m(K.ell(31, 41, 13, 6.5))
        c.edges.update({p: VEIN for p in v if p not in face})
    # pink blossom on the upper-left of the pad (dolphin pink)
    bx, by = 18, 19
    pet = [K.ell(bx + math.cos(math.radians(a)) * 3.6, by + math.sin(math.radians(a)) * 3.6, 3.4 * s, 3.4 * s) for a in (0, 72, 144, 216, 288)]
    pm = c.m(*pet)
    c.add(pm, PINK)
    c.edge(pm, PINK[1])
    c.add(c.m(K.ell(bx, by, 2.4 * s, 2.4 * s)), GOLD)
    # water ripples at the flat S foot (the pool), mint + teal
    if not c.small:
        for (x0, x1, yy) in ((14, 24, 52.5), (38, 50, 52.5)):
            c.line([(x0, yy), (x1, yy)], PADDK[1])
        c.px(*c.P(46, 30), '#fff1cf')
        c.px(*c.P(13, 42), '#fff1cf')
    else:
        c.line([(36, 52), (48, 52)], PADDK[1])
    # face on the calm lower pad
    c.eye(25, 39, disc=False)
    c.eye(37, 39, disc=False)
    c.smile(31, 44)
    c.blush(20.5, 43)
    c.blush(41.5, 43)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-wdol-1', 'Lilypad Parasol', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wdol-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wdol-1.png')
    print(rep)
