#!/usr/bin/env python3
"""pl-gwk-5 "Howl Echo": a moon-pale wolf pup's head mid-howl that IS an inner-TTBB piece (hook knobs).
Blank N is the dip between the ears, blank W cuts the left cheek; hook tab E is the echo curling back out,
hook tab S a curled chest ruff. Lavender-grey fur and moon-white rings from cell 8-4 (the moon halo behind the
Grey Wolf King), yellow eyes and navy ear-insides from the king himself."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

FUR = K.ramp('#9aa4c6')
FURD = K.ramp('#8692b9')
PALE = K.ramp('#d8dcf0')
MOON = ('#f2f2fa', '#b0b8d4', '#ffffff')
NAVY = K.ramp('#3e4478')
MOUTH = ('#5a2a48', '#3e1e34', '#7a3a5e')
TONGUE = K.ramp('#e0708e')
YEL = '#f0d020'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(11, 20, 51, 56)
    earL = poly([(11, 26), (13, 5), (27, 20)])
    earR = poly([(35, 20), (49, 5), (51, 26)])
    blankN = knob('B', 'hook', 31, 20, 0, -1, r=3.6 * k)
    blankW = knob('B', 'hook', 11, 45, -1, 0, r=3.8 * k, flip=True)
    tabE = knob('T', 'hook', 51, 37, 1, 0, r=5.2 * k, nw=3.0)
    tabS = knob('T', 'hook', 31, 56, 0, 1, r=4.3 * k, nw=2.8, flip=True)
    body = c.m(core, earL, earR, minus=(blankN, blankW))
    c.add(body, FUR, stitch=None if c.small else FUR[2])
    # ear insides (navy, like the king's ears)
    c.add(c.m(poly([(15, 22), (15.5, 11), (23, 20)])), NAVY)
    c.add(c.m(poly([(39, 20), (46.5, 11), (47, 22)])), NAVY)
    # hook tabs: the howl's echo (moon white) and the chest ruff
    c.add(c.m(tabE, minus=(core,)), MOON)
    c.add(c.m(tabS, minus=(core,)), FUR)
    # pale muzzle and cheeks
    c.add(c.m(ell(31, 45, 11, 8.5)) & body, PALE)
    # forehead stripe (darker fur, like the king's mane)
    c.add(c.m(poly([(26, 21), (36, 21), (33, 33), (29, 33)])) & body, FURD)
    # howling O mouth with tongue
    mo = c.m(ell(31, 48, 4.2 if not c.small else 4.6, 4.6 if not c.small else 5.0))
    c.add(mo, MOUTH)
    c.add(c.m(ell(31, 50.5, 2.6, 1.8)) & mo, TONGUE)
    # nose
    c.add(c.m(ell(31, 40.5, 3.4, 2.2)), NAVY)
    # yellow wolf eyes
    for ex in (22, 40):
        cx, cy = c.P(ex, 32)
        if not c.small:
            for dx in range(-2, 2):
                for dy in range(-1, 2):
                    c.px(cx + dx, cy + dy, YEL)
            c.px(cx, cy - 1, K.UMBER); c.px(cx, cy, K.UMBER); c.px(cx - 1, cy, K.UMBER)
            c.px(cx - 2, cy - 2, K.UMBER); c.px(cx - 1, cy - 2, K.UMBER); c.px(cx, cy - 2, K.UMBER); c.px(cx + 1, cy - 2, K.UMBER)
        else:
            c.px(cx - 1, cy, YEL); c.px(cx, cy, K.UMBER); c.px(cx + 1, cy, YEL)
            c.px(cx - 1, cy - 1, K.UMBER); c.px(cx, cy - 1, K.UMBER); c.px(cx + 1, cy - 1, K.UMBER)
    # echo rings: moon-white arcs ringing out from the mouth toward the hook tab
    if not c.small:
        c.line([(43.5, 47), (45, 44.5), (45, 41.5)], '#6a74a8')
        c.line([(47, 50), (48.5, 46.5), (48.5, 42)], '#6a74a8')
    else:
        c.line([(45, 49), (47.5, 45), (47.5, 41)], '#6a74a8')
    c.blush(17, 39)
    c.blush(44, 38) if c.small else None


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-gwk-5', 'Howl Echo', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-gwk-5-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-gwk-5.png')
    print(rep)
