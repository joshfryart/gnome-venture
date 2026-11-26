#!/usr/bin/env python3
"""pl-chil-3 "Cocoa Curl": inner-TBTB, round. A puff of cocoa steam that is an inner piece: the N tab is the curling steam wisp
(a cream knob with a cocoa spiral), the S tab is the wisp tail rising from the chimney, round blanks W and E bite into the puff.
Colours from cell 10-1: sky blue, pale cloud and cream; cocoa brown for the base of the steam."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

CLOUD = K.ramp('#c8e4e0')
CREAMR = ('#fffae8', '#e0d4b4', '#ffffff')
COCOA = K.ramp('#a8704a')
SKY = '#98d0ec'
COCOA_D = '#6a3e24'


def fn(c):
    s = 1.15 if c.small else 1.0
    # rounded-square puff core (straight sides between knobs, soft corners)
    core = lambda x, y: (K.rect(17, 16, 47, 50)(x, y) or K.rect(12, 21, 52, 45)(x, y)
                         or K.ell(17, 21, 5, 5)(x, y) or K.ell(47, 21, 5, 5)(x, y)
                         or K.ell(17, 45, 5, 5)(x, y) or K.ell(47, 45, 5, 5)(x, y)
                         or K.ell(19, 16, 5.5, 4.2)(x, y) or K.ell(45, 16, 5.5, 4.2)(x, y)
                         or K.ell(13.5, 22, 3.8, 4.5)(x, y) or K.ell(50.5, 22, 3.8, 4.5)(x, y))
    tabN = K.knob('T', 'round', 32, 16, 0, -1, r=5.6 * s)
    tabS = K.knob('T', 'round', 32, 50, 0, 1, r=4.8 * s)
    blW = K.knob('B', 'round', 12, 35.5, -1, 0, r=4.4 * s)
    blE = K.knob('B', 'round', 52, 35.5, 1, 0, r=4.4 * s)
    body = c.m(core, tabN, tabS, minus=(blW, blE))
    c.add(body, CLOUD, stitch=None if c.small else '#a8ccd0')
    # cocoa-tinted base of the steam: wavy band across the bottom + the tail tab
    wav = lambda x, y: y > 42.5 + 2.0 * __import__('math').sin(x / 3.2)
    c.add(body & c.m(wav), COCOA)
    # the curl: cream knob on top with a cocoa spiral
    curl = body & c.m(tabN, minus=(K.rect(0, 15, 64, 64),))
    c.add(curl | (body & c.m(K.ell(32, 16.5, 6.2 * s, 2.5))), CREAMR)
    cx, cy = 32, 8.8 if not c.small else 8.0
    if not c.small:
        c.line([(cx + 3.5, cy + 1.5), (cx + 3.5, cy - 1.5), (cx + 1, cy - 3.6), (cx - 2.5, cy - 3), (cx - 3.8, cy),
                (cx - 2, cy + 3), (cx + 1, cy + 2.6), (cx + 1.8, cy), (cx, cy - 1.2), (cx - 1, cy + 0.2)], COCOA_D)
    else:
        c.line([(cx + 3.4, cy + 1.5), (cx + 3.4, cy - 2), (cx, cy - 3.8), (cx - 3.6, cy - 2), (cx - 3.6, cy + 1.8),
                (cx, cy + 2.6), (cx + 0.5, cy)], COCOA_D)
    # little sky-blue puffs curling off the cloud (the clouds it tickles), cream highlights on the puff top
    if not c.small:
        for (x, y) in [(20, 22), (21, 22), (22, 21), (23, 21)]:
            c.px(*c.P(x, y), '#ffffff')
        c.line([(40, 23), (44, 23), (45, 24)], '#ffffff')
    # face on the calm cloud middle
    # steam swirls in the cocoa base (cream curls)
    if not c.small:
        c.line([(20, 47), (22, 45.5), (24.5, 46.5), (24, 48.5), (22.5, 48)], '#fffae8')
        c.line([(39, 48), (41, 46), (43.5, 46.5), (43.5, 48.5), (42, 48.5)], '#fffae8')
    # face on the calm cloud middle, away from the blanks
    c.eye(27, 28)
    c.eye(37, 28)
    c.smile(32, 33)
    c.blush(24, 32)
    c.blush(39.5, 32)


K.render_pal(fn, 'pl-chil-3', 'Cocoa Curl', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-chil-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-chil-3.png')
