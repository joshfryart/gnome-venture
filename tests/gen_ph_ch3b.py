#!/usr/bin/env python3
"""Chapter III-b placeholder creature art (deterministic): creature-<slug>.svg, 64 box. Same deep-rock slate palette as gen_ph_ch3.py, with a thin grey-violet vein of blight.
Writes ONLY the six new slugs (tallow-grub, stone-loach, crystal-weaver, bellcap-beetle, basalt-borer, old-holler) into game/assets/img/ph/. Run: python3 tests/gen_ph_ch3b.py"""
import os
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'game', 'assets', 'img', 'ph')
R9, R7, R5, R3 = '#2f3440', '#4a5160', '#6e7685', '#a9afba'     # slate
Q5, Q3 = '#8f7fc9', '#d8d0f5'                                    # blight vein / crystal
W5, W3 = '#efe3b8', '#fff7da'                                    # tallow
F5, F3 = '#5f6a62', '#8d9a90'                                    # toad / loach green-grey
BR7, BR5 = '#6b4a2c', '#9a7447'                                  # borer brown
INK, G5 = '#2b2b2b', '#e8a317'
NEW = ('tallow-grub', 'stone-loach', 'crystal-weaver', 'bellcap-beetle', 'basalt-borer', 'old-holler')
def svg(slug, label, body):
    assert slug in NEW, slug
    t = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="Creature %s">'
         '<ellipse cx="32" cy="57" rx="18" ry="3.2" fill="#000" opacity=".15"/>%s</svg>') % (label, body)
    open(os.path.join(OUT, 'creature-%s.svg' % slug), 'w', encoding='utf8').write(t)
def eye(x, y, r=1.6):
    return '<circle cx="%s" cy="%s" r="%s" fill="%s"/><circle cx="%s" cy="%s" r="0.6" fill="#fff"/>' % (x, y, r, INK, x - 0.5, y - 0.6)
svg('tallow-grub', 'Tallow Grub',
    '<path d="M8 48q0 -14 14 -14q10 0 16 4q12 -2 18 6q2 8 -8 10q-20 4 -40 -6z" fill="%s"/>' % W5 +
    ''.join('<path d="M%d %d q2 6 0 12" stroke="%s" stroke-width="1.4" fill="none" opacity=".7"/>' % (x, 38 + (x % 3), R5) for x in (16, 24, 32, 40)) +
    '<path d="M12 46q10 -6 22 -2" fill="none" stroke="%s" stroke-width="1.4" opacity=".8"/>' % Q5 +
    '<circle cx="52" cy="42" r="6" fill="%s"/>%s' % (W3, eye(54, 41)) +
    '<path d="M56 36q3 -5 6 -4M52 36q0 -6 2 -8" stroke="%s" stroke-width="1.4" stroke-linecap="round" fill="none"/>' % R5 +
    '<path d="M26 34q-1 -6 1 -9q2 3 1 9z" fill="%s"/><circle cx="27" cy="23" r="1.6" fill="%s" opacity=".8"/>' % (G5, G5))
svg('stone-loach', 'Stone Loach',
    '<path d="M4 38q14 -14 32 -6q12 4 22 -2q4 8 -2 14q-8 6 -22 4q-20 4 -30 -10z" fill="%s"/>' % F3 +
    '<path d="M8 38q14 -8 28 -2q10 4 20 -2" fill="none" stroke="%s" stroke-width="1.8" opacity=".7"/>' % F5 +
    '<path d="M2 36l-2 -6l6 4zM2 44l-2 6l6 -4z" fill="%s"/>' % F5 +
    '<path d="M24 32l4 -6l6 6M40 34l3 -5l4 5" fill="%s"/>' % F5 +
    '<circle cx="52" cy="38" r="1.2" fill="%s" opacity=".6"/>' % R9 +
    '<path d="M58 38q4 0 5 3M58 42q4 1 5 4" stroke="%s" stroke-width="1.4" stroke-linecap="round" fill="none"/>' % R5 +
    '<path d="M20 42q8 3 16 0" fill="none" stroke="%s" stroke-width="1.4"/>' % Q5)
svg('crystal-weaver', 'Crystal Weaver',
    '<path d="M4 8l24 22M60 8L36 30M32 4v22M8 26l20 6M56 26l-20 6" stroke="%s" stroke-width="0.9" opacity=".7"/>' % Q3 +
    '<ellipse cx="32" cy="38" rx="9" ry="11" fill="%s"/><circle cx="32" cy="27" r="6" fill="%s"/>' % (R7, R5) +
    '<path d="M25 36l-10 -8l-8 6M25 40l-12 0l-8 10M25 44l-8 8l-4 6M39 36l10 -8l8 6M39 40l12 0l8 10M39 44l8 8l4 6" stroke="%s" stroke-width="2" stroke-linecap="round" fill="none"/>' % R9 +
    '<path d="M28 34l4 8l4 -8" fill="none" stroke="%s" stroke-width="1.6"/>' % Q5 + eye(30, 26, 1.2) + eye(34, 26, 1.2) +
    '<circle cx="32" cy="46" r="2" fill="%s" opacity=".8"/>' % Q3)
svg('bellcap-beetle', 'Bellcap Beetle',
    '<path d="M10 50q0 -30 22 -30q22 0 22 30z" fill="%s"/>' % R7 +
    '<path d="M32 20v30M20 26q-4 12 -2 24M44 26q4 12 2 24" stroke="%s" stroke-width="1.6" fill="none" opacity=".7"/>' % R9 +
    '<path d="M14 40q18 -8 36 0" fill="none" stroke="%s" stroke-width="1.8"/><path d="M12 46q20 -6 40 0" fill="none" stroke="%s" stroke-width="1.4" opacity=".8"/>' % (R3, Q5) +
    '<circle cx="32" cy="16" r="3" fill="%s"/>' % G5 +
    '<circle cx="52" cy="50" r="6" fill="%s"/>%s<path d="M56 46l4 -6M52 45l0 -7" stroke="%s" stroke-width="1.6" stroke-linecap="round"/>' % (R5, eye(54, 49), R5) +
    '<path d="M12 52l-4 6M22 54l-2 6M42 54l2 6M50 54l4 6" stroke="%s" stroke-width="2.4" stroke-linecap="round"/>' % R9)
svg('basalt-borer', 'Basalt Borer',
    '<ellipse cx="26" cy="40" rx="20" ry="11" fill="%s"/>' % BR5 +
    ''.join('<path d="M%d 31q2 9 0 18" stroke="%s" stroke-width="1.6" fill="none" opacity=".7"/>' % (x, BR7) for x in (14, 20, 26, 32, 38)) +
    '<path d="M10 42q14 -6 30 -2" fill="none" stroke="%s" stroke-width="1.4" opacity=".8"/>' % Q5 +
    '<circle cx="50" cy="40" r="8" fill="%s"/>%s<path d="M54 34l5 -6M49 33l0 -7" stroke="%s" stroke-width="1.6" stroke-linecap="round"/>' % (BR7, eye(53, 38, 1.8), BR7) +
    '<path d="M56 46l8 2l-2 6l-8 -2z" fill="%s"/><path d="M58 50l4 4" stroke="%s" stroke-width="1.2"/>' % (R5, R9) +
    '<path d="M12 48l-6 8M24 51l-3 8M36 50l3 8" stroke="%s" stroke-width="2.6" stroke-linecap="round"/>' % BR7)
svg('old-holler', 'Old Holler',
    '<ellipse cx="32" cy="42" rx="27" ry="15" fill="%s"/>' % F5 +
    '<ellipse cx="32" cy="36" rx="22" ry="11" fill="%s"/>' % F3 +
    ''.join('<circle cx="%d" cy="%d" r="%s" fill="%s" opacity=".6"/>' % (x, y, r, F5) for x, y, r in ((14, 34, 2.4), (24, 30, 2), (40, 31, 2.6), (50, 36, 2), (32, 40, 2.2))) +
    '<path d="M12 30q20 -8 40 0" fill="none" stroke="%s" stroke-width="1.6" opacity=".8"/>' % Q5 +
    '<path d="M16 46q16 14 32 0q-6 4 -16 4t-16 -4z" fill="%s"/><path d="M20 47q12 7 24 0" fill="none" stroke="%s" stroke-width="2.2" opacity=".85"/>' % (R9, Q5) +
    '<circle cx="18" cy="26" r="5" fill="%s"/><circle cx="46" cy="26" r="5" fill="%s"/>' % (F3, F3) +
    '<circle cx="18" cy="26" r="2.4" fill="%s" opacity=".55"/><circle cx="46" cy="26" r="2.4" fill="%s" opacity=".55"/>' % (R7, R7) +
    '<path d="M6 54l-4 5M16 56l-2 5M48 56l2 5M58 54l4 5" stroke="%s" stroke-width="3.2" stroke-linecap="round"/>' % F5)
