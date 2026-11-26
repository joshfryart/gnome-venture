#!/usr/bin/env python3
"""pl-wgwo-2 "Wanderlight Wisps": edge-TTB keyhole. A glowing cave wisp hanging from the grotto ceiling.
Flat N = lavender ceiling rock it clings to (with two little stalactite drips), keyhole tabs W and E are its glow-dot hands
(bright cyan bulbs), keyhole blank S cut up into its wispy hem. Body = navy with a teal glow halo and a cyan sparkle (cell 8-4)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

NAVY = K.ramp('#2a3468')
HALO = K.ramp('#38507a')
GLOW = K.ramp('#4a90a8')
CYAN = ('#6ff0e4', '#3fb8b8', '#c8fcf4')
ROCK = K.ramp('#9083b9')
SPARK = '#e8fffc'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(11, 9, 53, 50)
    tabW = K.knob('T', 'keyhole', 11, 31, -1, 0, r=4.6 * k)
    tabS = K.knob('T', 'keyhole', 32, 50, 0, 1, r=4.8 * k)
    blankE = K.knob('B', 'keyhole', 53, 30, 1, 0, r=4.4 * k)
    # rounded lower corners: a soft glowing blob, but the sides stay straight
    corners = (lambda x, y: x < 17 and y > 44 and (x - 17) ** 2 + (y - 44) ** 2 > 36,
               lambda x, y: x > 47 and y > 44 and (x - 47) ** 2 + (y - 44) ** 2 > 36)
    body = c.m(core, minus=(blankE,) + corners)
    c.add(body, NAVY)
    # glow halo rings around the heart (the cell's glowing dot)
    c.add(body & c.m(K.ell(31, 32, 19, 17)), HALO)
    c.add(body & c.m(K.ell(31, 32, 14, 13)), GLOW)
    c.add(body & c.m(K.ell(31, 39, 6.5, 5)), K.ramp('#5fc0c8'))
    # ceiling rock band (flat top) the wisp clings to, with two small drips
    rock = c.m(K.rect(11, 9, 53, 14), K.ell(19, 14, 2.6, 3.2), K.ell(44, 14, 2.4, 2.8))
    c.add(rock, ROCK)
    # glow-dot hand (W) and dripping glow tail (S), like the drip under the cell's glint
    c.add(c.m(tabW, minus=(core,)), CYAN)
    c.add(c.m(tabS, minus=(core,)), CYAN)
    # sparkle heart (the cell's cross glint)
    cx, cy = c.P(31, 41)
    arm = 1 if c.small else 2
    for d in range(-arm, arm + 1):
        c.px(cx + d, cy, CYAN[0])
        c.px(cx, cy + d, CYAN[0])
    c.px(cx, cy, SPARK)
    # face
    c.eye(25, 28, disc=True)
    c.eye(37, 28, disc=True)
    c.smile(31, 33, '#2a1a10')
    c.blush(20.5, 33)
    c.blush(41, 33)
    # loose glow dots wandering in the navy corners
    for (x, y) in ((15.5, 20), (48.5, 45), (15, 42)):
        px, py = c.P(x, y)
        c.px(px, py, CYAN[0])
        if not c.small:
            c.px(px + 1, py, CYAN[0]); c.px(px, py + 1, CYAN[1]); c.px(px + 1, py + 1, CYAN[1])


K.render_pal(fn, 'pl-wgwo-2', 'Wanderlight Wisps', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgwo-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgwo-2.png')
