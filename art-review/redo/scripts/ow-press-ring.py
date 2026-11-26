"""ow-press-ring "Press Ring": inner-BBBB, double. The olive-press millstone of Olivewhistle (cell 6-5): a grey speckled stone wheel
with a brown rim, shaped as a rounded square piece with a double blank cut into each side. A dark wooden axle hub holds a green olive,
a carved groove rings the face, and golden oil drips from the lower rim."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = K.ramp('#a49e92')
RIM = K.ramp('#7a5236')
HUB = K.ramp('#5a3a22')
OLIVE = K.ramp('#7a9a38')
OIL = K.ramp('#e8b828')


def sq(cx, cy, a, p=3.2):
    return lambda x, y: (abs(x - cx) / a) ** p + (abs(y - cy) / a) ** p < 1


def fn(c):
    k = 1.15 if c.small else 1.0
    cx, cy, a = 32, 32, 25
    outer = sq(cx, cy, a)
    blanks = (K.knob('B', 'double', cx, cy - a, 0, -1, r=3.7 * k),
              K.knob('B', 'double', cx, cy + a, 0, 1, r=3.7 * k),
              K.knob('B', 'double', cx - a, cy, -1, 0, r=3.7 * k),
              K.knob('B', 'double', cx + a, cy, 1, 0, r=3.7 * k))
    body = c.m(outer, minus=blanks)
    c.add(body, RIM)
    face = c.m(sq(cx, cy, a - 3.4), minus=blanks)
    face = {p for p in face if p in body}
    # keep a rim band around the blanks too: erode the face where it touches a blank
    rimband = c.m(*[K.knob('B', 'double', *args, r=3.7 * k + 1.4, nw=2.6 + 1.2) for args in
                    ((cx, cy - a, 0, -1), (cx, cy + a, 0, 1), (cx - a, cy, -1, 0), (cx + a, cy, 1, 0))])
    face -= rimband
    c.add(face, STONE, stitch=None if c.small else '#c8c2b6')
    c.edge(face, RIM[1])
    # carved groove ring
    groove = c.m(K.ell(cx, cy + 6, 11, 11), minus=(K.ell(cx, cy + 6, 9.4 if not c.small else 9.0, 9.4 if not c.small else 9.0),))
    for p in groove:
        if p in face:
            c.px(p[0], p[1], OIL[0] if (p[1] * 64 / c.n) > cy + 6 else OIL[1])
    # hub with olive
    hub = c.m(K.ell(cx, cy + 6, 6.2, 6.2)) & face
    c.add(hub, HUB)
    c.add(c.m(K.ell(cx + 0.3, cy + 5.6, 3.4, 2.8)) & hub, OLIVE)
    # speckles
    for sx, sy in ((18, 24), (45, 22), (20, 41), (44, 43), (40, 15), (25, 51)):
        x, y = c.P(sx, sy)
        if (x, y) in face:
            c.px(x, y, STONE[1])
    # a golden oil drop squeezed out at the bottom of the ring
    for p in c.m(K.ell(cx - 9.5, cy + 15.5, 1.8, 2.4), K.poly([(cx - 10.6, cy + 14.5), (cx - 8.4, cy + 14.5), (cx - 9.5, cy + 11.5)])):
        if p in face:
            c.px(p[0], p[1], OIL[0])
    x, y = c.P(cx - 10, cy + 15)
    c.px(x, y, OIL[2])
    # face
    c.eye(23.5, 20, disc=True)
    c.eye(40.5, 20, disc=True)
    c.smile(32, 25)
    c.blush(18, 24.5)
    c.blush(45, 24.5)


if __name__ == '__main__':
    print(K.render_pal(fn, 'ow-press-ring', 'Press Ring', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/ow-press-ring-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/ow-press-ring.png'))
