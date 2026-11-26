# pl-stkv-2 "Airmail Parcel Sway": cream cloth parcel = edge-BTB piece (flat bottom, keyhole tab on top = twine knot, keyhole blanks left/right),
# red twine cross + bow, airmail plum/red stripe border; colours from cell 5-0 (violet dusk sky, cream bundle).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

CLOTH = ('#f2e6d0', '#b8a2c8', '#fff8ea')
TWINE = K.ramp('#d8402a')
PLUM = K.ramp('#5a4e9c')
VIOLET = K.ramp('#8a52a8')
SKY = '#5a4e9c'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(8, 18, 56, 59)
    tab = K.knob('T', 'keyhole', 32, 18, 0, -1, r=5.2 * s, nw=2.8 * s)
    bl = K.knob('B', 'keyhole', 8, 37, -1, 0, r=3.8 * s, nw=2.2 * s)
    br = K.knob('B', 'keyhole', 56, 37, 1, 0, r=3.8 * s, nw=2.2 * s)
    body = c.m(core, tab, minus=(bl, br))
    c.add(body, CLOTH, stitch=None)
    # airmail border: diagonal stripes along the bottom band
    band = c.m(K.rect(8, 51, 56, 59), minus=(bl, br))
    def stripe(cols):
        def f(x, y):
            return int((x + y) // 4) % 4 == cols
        return f
    c.add(c.m(K.rect(8, 51, 56, 59), minus=()) & {p for p in band if stripe(0)((p[0] + .5) / c.k, (p[1] + .5) / c.k)}, TWINE)
    c.add({p for p in band if stripe(2)((p[0] + .5) / c.k, (p[1] + .5) / c.k)}, PLUM)
    # twine cross
    w = 3.4 if c.small else 3.0
    c.add(c.m(K.rect(32 - w / 2, 16, 32 + w / 2, 51)), TWINE)
    c.add(c.m(K.rect(8, 25 - w / 2, 56, 25 + w / 2), minus=(bl, br)), TWINE)
    # bow on top: knot is the keyhole tab, two loops lean out
    c.add(c.m(tab, minus=(K.rect(0, 13, 64, 64),)) | c.m(K.ell(32, 9 * 1 + 0.0, 3.6 * s, 3.4 * s)), TWINE)
    c.add(c.m(K.ell(25, 14, 5, 3.2), K.ell(39, 14, 5, 3.2)), TWINE)
    c.add(c.m(K.ell(32, 12, 2.4, 2.4)), K.ramp('#a8301a'))
    # face on the lower-left cloth panel
    c.eye(24, 35)
    c.eye(40, 35)
    c.smile(32, 42)
    c.blush(20, 41)
    c.blush(43, 41)
    # little postmark circle on upper right panel
    if not c.small:
        c.line([(44, 20), (50, 20)], SKY)
        c.line([(44, 21), (50, 21)], SKY)


K.render_pal(fn, 'pl-stkv-2', 'Airmail Parcel Sway', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-stkv-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-stkv-2.png')
