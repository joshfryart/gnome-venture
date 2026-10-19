#!/usr/bin/env python3
"""Gnome Venture menu icons (placeholder art, deterministic): one 64x64 SVG per menu entry, named nav-{slug}.
Run: python3 tests/gen_ph_nav.py   Writes game/assets/img/ph/nav-*.svg (palette: assets/img/ph/palette.json).
Real art uploaded in Admin -> Images as nav-{slug}.png wins over these."""
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_ph_world as W
from gen_ph_world import *   # palette, sh, hl, rect, circ, ell, path, leaf, f

NAV = {}


def icon(slug, body, label):
    NAV['nav-' + slug + '.svg'] = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="%s">%s</svg>' % (label, body))


def hat(cx, base, w, h, col, dark, tilt=0):
    """pointed gnome hat: base y, half-width w, height h"""
    tip = cx + tilt
    return (path('M%s %sQ%s %s %s %sQ%s %s %s %sz' % (f(cx - w), f(base), f(cx - w * .5), f(base - h * .55), f(tip), f(base - h), f(cx + w * .5), f(base - h * .45), f(cx + w), f(base)), col)
            + rect(cx - w - 2, base - 3, 2 * w + 4, 6, dark, 3))


def build():
    # gnome: hat, face, beard
    s = sh(32, 58, 18, 3)
    s += circ(32, 38, 12, S3) + path('M20 40Q32 66 44 40Q32 46 20 40z', S1)
    s += circ(32, 40, 3, PT3, .9) + circ(27, 36, 1.5, INK) + circ(37, 36, 1.5, INK)
    s += hat(32, 30, 17, 28, E5, E7, 3) + circ(35, 3.5, 3, CR)
    icon('gnome', s, 'My Gnome')
    # almanac: book
    s = sh(32, 57, 22, 3) + rect(11, 8, 42, 48, M8, 4) + rect(15, 8, 38, 46, M6, 3) + rect(17, 12, 32, 40, CR, 2)
    s += circ(33, 27, 6, M4) + path('M33 33V42', stroke=M8, sw=2) + leaf(33, 38, -7, -5, M6) + leaf(33, 38, 7, -6, M4)
    s += rect(20, 45, 22, 2, T3) + rect(11, 8, 5, 48, M8, 2)
    icon('almanac', s, 'Almanac')
    # satchel
    s = sh(32, 58, 20, 3) + path('M20 24Q32 6 44 24', stroke=S7, sw=4)
    s += rect(11, 24, 42, 32, S5, 8) + rect(11, 24, 42, 14, S7, 7) + rect(27, 32, 10, 10, G5, 3) + rect(30, 35, 4, 4, G7, 1)
    s += hl(15, 42, 4, 10, 2)
    icon('satchel', s, 'Satchel')
    # crafting: hammer
    s = sh(32, 58, 20, 3) + path('M24 24L50 52', stroke=S7, sw=7)
    s += path('M24 24L50 52', stroke=S3, sw=3, op=.7)
    s += rect(8, 10, 38, 18, T5, 3, ' transform="rotate(35 27 19)"') + rect(8, 10, 38, 6, T3, 3, ' transform="rotate(35 27 19)"') + rect(40, 10, 6, 18, T7, 2, ' transform="rotate(35 27 19)"')
    icon('crafting', s, 'Crafting')
    # garden: sprout + fence
    s = sh(32, 58, 24, 3) + ell(32, 50, 22, 8, S7) + ell(32, 48, 18, 5, S5)
    s += path('M32 48V30', stroke=M8, sw=3) + leaf(32, 34, -16, -10, M6) + leaf(32, 30, 16, -12, M4)
    for x in (8, 18, 46, 56):
        s += rect(x - 3, 36, 6, 22, S3, 2) + path('M%s 36l3-5 3 5z' % f(x - 3), S3)
    s += rect(4, 42, 56, 3, S5) + rect(4, 50, 56, 3, S5)
    icon('garden', s, 'Garden')
    # arranging: bouquet
    s = sh(32, 59, 14, 2.5)
    for dx in (-8, 0, 8):
        s += path('M32 56L%s 30' % f(32 + dx), stroke=M8, sw=2)
    s += path('M20 38L44 38L36 60L28 60z', G3) + path('M26 38L38 38L33 60L31 60z', G5)
    for (x, y, c) in ((20, 20, PT5), (32, 14, E4), (44, 20, D5), (26, 30, G5), (38, 30, PT3)):
        for i in range(5):
            a = i * 1.2566
            s += circ(x + math.sin(a) * 5, y + math.cos(a) * 5, 3.6, c)
        s += circ(x, y, 3, G3 if c != G5 else CR)
    icon('arranging', s, 'Arranging')
    # world: globe
    s = sh(32, 58, 20, 3) + circ(32, 31, 25, W5) + circ(32, 31, 25, W3, .25)
    s += path('M14 22Q22 12 30 16Q34 24 26 28Q22 36 16 34Z', M6) + path('M36 30Q46 26 50 34Q48 46 40 50Q36 42 36 36Z', M4) + path('M34 8Q44 10 48 16Q40 18 34 14Z', M6)
    s += hl(16, 14, 8, 4, 2) + path('M10 31Q32 39 54 31', stroke=W7, sw=1, op=.3)
    icon('world', s, 'World')
    # town: little houses
    s = sh(32, 58, 26, 3)
    s += rect(4, 34, 24, 22, S3, 1) + path('M2 36L16 20L30 36z', E5) + rect(12, 44, 8, 12, S7, 1)
    s += rect(30, 28, 30, 28, S1, 1) + path('M27 30L45 10L63 30z', D5) + rect(40, 42, 10, 14, S7, 1) + rect(34, 34, 7, 6, W3) + rect(50, 34, 7, 6, W3)
    s += rect(8, 38, 5, 5, W3)
    icon('town', s, 'Town')
    # villagers: two people
    s = sh(32, 58, 24, 3)
    s += path('M4 58Q4 40 20 40Q36 40 36 58z', M6) + circ(20, 28, 9, S3) + path('M11 26Q20 14 29 26Q20 20 11 26z', S7)
    s += path('M30 58Q30 42 44 42Q58 42 58 58z', D5) + circ(44, 31, 8, S1) + path('M36 30Q44 18 52 30Q44 24 36 30z', G7)
    s += circ(17, 29, 1.2, INK) + circ(23, 29, 1.2, INK) + circ(41, 32, 1.2, INK) + circ(47, 32, 1.2, INK)
    icon('villagers', s, 'Villagers')
    # seasons: sun + cloud
    s = sh(32, 58, 22, 3)
    for i in range(8):
        a = i * math.pi / 4
        s += path('M%s %sL%s %s' % (f(24 + math.cos(a) * 15), f(24 + math.sin(a) * 15), f(24 + math.cos(a) * 21), f(24 + math.sin(a) * 21)), stroke=G5, sw=3)
    s += circ(24, 24, 12, G5) + circ(24, 24, 12, G3, .3) + circ(21, 21, 4, '#fff', .35)
    s += circ(28, 44, 10, T3) + circ(40, 40, 13, CR) + circ(52, 46, 9, T3) + rect(28, 44, 24, 11, T3, 5) + circ(40, 42, 11, CR) + rect(30, 46, 22, 9, CR, 4)
    icon('seasons', s, 'Seasons')
    # passport: booklet with stamp
    s = sh(32, 59, 20, 3) + rect(12, 6, 40, 52, W7, 4) + rect(16, 6, 36, 50, W5, 3) + rect(12, 6, 5, 52, W7, 2)
    s += circ(34, 24, 9, G3) + circ(34, 24, 9, G5, .5) + path('M25 24H43M34 15Q29 24 34 33M34 15Q39 24 34 33', stroke=G7, sw=1.2)
    s += rect(24, 40, 20, 3, G3, 1) + rect(26, 46, 16, 3, G3, 1) + circ(46, 44, 7, E5, .7) + circ(46, 44, 4.5, CR, .45)
    icon('passport', s, 'Passport')
    # games: die
    s = sh(32, 58, 20, 3) + rect(8, 8, 48, 48, CR, 9) + rect(8, 8, 48, 48, '#fff', 9, ' opacity=".25"') + rect(8, 44, 48, 12, T3, 7, ' opacity=".5"')
    for (x, y) in ((20, 20), (44, 20), (32, 32), (20, 44), (44, 44)):
        s += circ(x, y, 4.5, E5)
    icon('games', s, 'Games')
    # trading: scales
    s = sh(32, 59, 20, 2.5) + rect(30, 12, 4, 44, G7, 1) + rect(18, 54, 28, 5, G7, 2) + circ(32, 10, 5, G5)
    s += path('M10 20H54', stroke=G7, sw=3)
    for x in (12, 52):
        s += path('M%s 20L%s 38M%s 20L%s 38' % (f(x), f(x - 8), f(x), f(x + 8)), stroke=G7, sw=1.2)
        s += path('M%s 38H%s Q%s 48 %s 38z' % (f(x - 10), f(x + 10), f(x), f(x - 10)), G5)
    s += circ(10, 35, 2.5, G3) + circ(52, 34, 2.5, M4)
    icon('trading', s, 'Trading')
    # together: sunflower
    s = sh(32, 59, 14, 2.5) + path('M32 60V30', stroke=M8, sw=4) + leaf(32, 50, -16, -8, M6) + leaf(32, 44, 16, -8, M4)
    for i in range(12):
        a = i * math.pi / 6
        s += ell(32 + math.cos(a) * 15, 26 + math.sin(a) * 15, 7, 3.4, G5 if i % 2 else G3, None, ' transform="rotate(%s %s %s)"' % (f(i * 30), f(32 + math.cos(a) * 15), f(26 + math.sin(a) * 15)))
    s += circ(32, 26, 10, S7) + circ(32, 26, 7, S9, .5) + circ(29, 23, 2, S3, .8)
    icon('together', s, 'Together')
    # tasks: clipboard
    s = sh(32, 59, 20, 3) + rect(10, 8, 44, 50, S5, 5) + rect(14, 14, 36, 40, CR, 2)
    s += rect(22, 4, 20, 10, T5, 3) + circ(32, 8, 2.2, CR)
    for i, y in enumerate((24, 34, 44)):
        s += path('M18 %s l3 3 5-6' % f(y), stroke=M6 if i < 2 else T3, sw=2.2) + rect(30, y - 3, 16, 3, T3 if i < 2 else T5, 1)
    icon('tasks', s, 'Tasks')
    # friends: two gnome hats
    s = sh(32, 58, 24, 3)
    s += circ(20, 42, 8, S3) + path('M13 44Q20 62 27 44Q20 48 13 44z', S1) + hat(20, 36, 12, 24, M6, M8, -2)
    s += circ(44, 42, 8, S1) + path('M37 44Q44 62 51 44Q44 48 37 44z', T3) + hat(44, 36, 12, 26, D5, D7, 2)
    s += circ(17, 41, 1.1, INK) + circ(23, 41, 1.1, INK) + circ(41, 41, 1.1, INK) + circ(47, 41, 1.1, INK)
    icon('friends', s, 'Gnome friends')
    # account: cog
    s = sh(32, 59, 20, 3)
    for i in range(8):
        s += rect(28, 3, 8, 16, T5, 2, ' transform="rotate(%s 32 32)"' % f(i * 45))
    s += circ(32, 32, 20, T5) + circ(32, 32, 20, '#fff', .12) + circ(32, 32, 8, '#f1ece0') + circ(32, 32, 8, T3, .6) + hl(18, 20, 8, 3, 1.5)
    icon('account', s, 'Account')
    # today: home
    s = sh(32, 58, 22, 3) + rect(12, 28, 40, 28, S1, 2) + path('M5 31L32 7L59 31z', E5) + path('M5 31L32 7L32 31z', E4, op=.6)
    s += rect(42, 12, 7, 12, S5, 1) + rect(26, 40, 12, 16, S7, 2) + circ(35, 49, 1.2, G5) + rect(15, 34, 8, 8, W3, 1) + rect(41, 34, 8, 8, W3, 1)
    icon('today', s, 'Today')
    # festival: bunting
    s = path('M2 12Q32 28 62 12', stroke=S7, sw=2)
    cols = [E5, G5, M6, W5, D5, PT5, E4]
    for i in range(7):
        t = (i + .5) / 7.0
        x = 2 + 60 * t
        y = 12 + 16 * 4 * t * (1 - t) * .5 * 2 / 2 * 1.0
        y = 12 + 8 * 4 * t * (1 - t) * 1.0
        s += path('M%s %sL%s %sL%s %sz' % (f(x - 5), f(y - 1), f(x + 5), f(y - 1), f(x), f(y + 16)), cols[i % len(cols)])
    s += circ(6, 12, 3, G5) + circ(58, 12, 3, G5)
    for (x, y, c) in ((14, 52, G5), (32, 56, E4), (50, 52, PT5)):
        s += circ(x, y, 3, c)
    icon('festival', s, 'Festival')
    # start: seedling
    s = sh(32, 58, 20, 3) + ell(32, 52, 20, 7, S7) + ell(32, 50, 16, 4.5, S5)
    s += path('M32 50V30', stroke=M8, sw=3) + leaf(32, 36, -18, -12, M6) + leaf(32, 32, 18, -14, M4) + circ(32, 24, 3, G5)
    s += circ(32, 24, 3, G3, .0) + hl(18, 49, 6, 2, 1)
    icon('start', s, 'Getting started')
    # feedback: speech bubble
    s = sh(32, 58, 22, 3) + path('M8 14Q8 8 14 8H50Q56 8 56 14V38Q56 44 50 44H30L16 56V44H14Q8 44 8 38z', W5)
    s += path('M8 14Q8 8 14 8H50Q56 8 56 14V20H8z', W3, op=.35)
    for x in (22, 32, 42):
        s += circ(x, 26, 3.2, CR)
    icon('feedback', s, 'Send feedback')


if __name__ == '__main__':
    build()
    big = 0
    for name, svg in sorted(NAV.items()):
        if len(svg.encode()) >= 4096:
            print('TOO BIG', name, len(svg.encode())); big += 1
        with open(os.path.join(W.OUT, name), 'w') as fh:
            fh.write(svg)
    print(len(NAV), 'files,', big, 'oversize')
