#!/usr/bin/env python3
"""Chapter III-a placeholder creature art (deterministic): creature-<slug>.svg, 64 box. Deep rock folk = slate greys with a thin grey-violet vein of blight.
Writes ONLY the six new slugs (shale-slater, quartz-snail, pale-olm, echo-bat, gravel-centipede, old-gneiss) into game/assets/img/ph/. Run: python3 tests/gen_ph_ch3.py"""
import os
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'game', 'assets', 'img', 'ph')
R9, R7, R5, R3 = '#2f3440', '#4a5160', '#6e7685', '#a9afba'     # slate
Q5, Q3 = '#8f7fc9', '#d8d0f5'                                    # crystal / blight vein
P5, P3 = '#e8d8d0', '#f7efe9'                                    # pale olm
B7, B5 = '#4b3a2f', '#6e5646'                                    # bat brown
INK, G5 = '#2b2b2b', '#e8a317'
NEW = ('shale-slater', 'quartz-snail', 'pale-olm', 'echo-bat', 'gravel-centipede', 'old-gneiss')
def svg(slug, label, body):
    assert slug in NEW, slug
    t = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="Creature %s">'
         '<ellipse cx="32" cy="57" rx="18" ry="3.2" fill="#000" opacity=".15"/>%s</svg>') % (label, body)
    open(os.path.join(OUT, 'creature-%s.svg' % slug), 'w', encoding='utf8').write(t)
def eye(x, y, r=1.6):
    return '<circle cx="%s" cy="%s" r="%s" fill="%s"/><circle cx="%s" cy="%s" r="0.6" fill="#fff"/>' % (x, y, r, INK, x - 0.5, y - 0.6)
svg('shale-slater', 'Shale Slater',
    '<ellipse cx="32" cy="42" rx="20" ry="12" fill="%s"/>' % R7 +
    ''.join('<path d="M%d 32q0 12 0 20" stroke="%s" stroke-width="1.6" opacity=".7"/>' % (x, R9) for x in (18, 25, 32, 39, 46)) +
    '<path d="M16 38q16 -6 32 0" fill="none" stroke="%s" stroke-width="1.6" opacity=".8"/>' % Q5 +
    '<circle cx="52" cy="42" r="5" fill="%s"/>%s<path d="M56 38l5 -4M56 42l6 0" stroke="%s" stroke-width="1.4" stroke-linecap="round"/>' % (R5, eye(53, 41), R5) +
    '<path d="M16 52l-3 4M24 54l-2 4M36 54l2 4M44 52l3 4" stroke="%s" stroke-width="2" stroke-linecap="round"/>' % R9)
svg('quartz-snail', 'Quartz Snail',
    '<path d="M6 52q22 4 44 -2l6 -2l-4 -6q-10 4 -22 2z" fill="%s"/>' % R5 +
    '<path d="M22 46q-2 -22 16 -24q16 2 14 20q-4 6 -14 6q-12 0 -16 -2z" fill="%s"/>' % R7 +
    '<path d="M30 44l6 -16l6 16M36 44l2 -22M44 44l4 -12" stroke="%s" stroke-width="1.6" fill="none"/>' % Q3 +
    '<path d="M28 30l4 -6l2 8M42 28l6 4" stroke="%s" stroke-width="1.4" fill="none"/>' % Q5 +
    '<path d="M54 46q4 -6 6 -12M58 48q4 -4 6 -8" stroke="%s" stroke-width="1.6" stroke-linecap="round" fill="none"/>' % R5 + eye(58, 42, 1.4))
svg('pale-olm', 'Pale Olm',
    '<path d="M4 46q12 -12 26 -4q10 6 20 -4q8 -4 10 2q-2 8 -12 8q-20 6 -44 -2z" fill="%s"/>' % P5 +
    '<path d="M8 46q12 -8 22 -2q10 4 20 -2" fill="none" stroke="%s" stroke-width="2" opacity=".7"/>' % P3 +
    '<path d="M14 44q8 -4 14 0" fill="none" stroke="%s" stroke-width="1.4" opacity=".8"/>' % Q5 +
    '<circle cx="54" cy="40" r="6" fill="%s"/>' % P5 + '<circle cx="56" cy="38" r="1" fill="%s"/>' % R5 +
    '<path d="M58 34q4 -4 6 -2M58 38q4 -2 6 0M60 42q3 0 4 2" stroke="%s" stroke-width="1.4" stroke-linecap="round" fill="none"/>' % '#c98f8f' +
    '<path d="M16 50l-3 5M26 52l-2 5M40 52l2 5M48 50l3 5" stroke="%s" stroke-width="2.4" stroke-linecap="round"/>' % P5)
svg('echo-bat', 'Echo Bat',
    '<path d="M32 36q-10 -14 -28 -8q6 4 6 10q6 -2 10 2q4 -2 12 4z" fill="%s"/><path d="M32 36q10 -14 28 -8q-6 4 -6 10q-6 -2 -10 2q-4 -2 -12 4z" fill="%s"/>' % (B5, B5) +
    '<path d="M32 36l-14 -4M32 36l-10 4M32 36l14 -4M32 36l10 4" stroke="%s" stroke-width="1" opacity=".6"/>' % B7 +
    '<ellipse cx="32" cy="38" rx="6" ry="9" fill="%s"/>' % B7 + '<circle cx="32" cy="30" r="5.5" fill="%s"/>' % B7 +
    '<path d="M28 26l-2 -7l5 4M36 26l2 -7l-5 4" fill="%s"/>' % B7 + eye(30, 30, 1.2) + eye(34, 30, 1.2) +
    '<path d="M24 22q-4 4 0 8M40 22q4 4 0 8" fill="none" stroke="%s" stroke-width="1.2" opacity=".8"/>' % Q3 +
    '<path d="M30 34l2 3l2 -3" fill="none" stroke="%s" stroke-width="1.2"/>' % '#f1e9e4')
svg('gravel-centipede', 'Gravel Centipede',
    ''.join('<ellipse cx="%d" cy="%d" rx="7" ry="8" fill="%s"/><path d="M%d %d l-4 7M%d %d l4 7" stroke="%s" stroke-width="2" stroke-linecap="round"/>' % (x, y, R7 if i % 2 else R5, x, y + 5, x, y + 5, R9)
            for i, (x, y) in enumerate([(8, 46), (17, 40), (26, 44), (35, 38), (44, 42)])) +
    '<path d="M8 44l8 -4M26 42l8 -4" stroke="%s" stroke-width="1.4" opacity=".8"/>' % Q5 +
    '<circle cx="54" cy="36" r="7.5" fill="%s"/>%s<path d="M58 30l4 -6M52 29l0 -6M60 38l4 2" stroke="%s" stroke-width="1.6" stroke-linecap="round"/>' % (R7, eye(56, 35), R9) +
    '<circle cx="14" cy="38" r="1.6" fill="%s"/><circle cx="34" cy="34" r="1.6" fill="%s"/><circle cx="20" cy="50" r="1.4" fill="%s"/>' % (R3, R3, R3))
svg('old-gneiss', 'Old Gneiss',
    '<ellipse cx="32" cy="44" rx="24" ry="12" fill="%s"/><path d="M8 44q4 -22 24 -22q20 0 24 22z" fill="%s"/>' % (R9, R7) +
    '<path d="M32 22v22M20 26q-2 8 0 18M44 26q2 8 0 18" stroke="%s" stroke-width="1.6" fill="none" opacity=".7"/>' % R9 +
    '<path d="M14 36q10 -6 16 2M34 32q10 -4 16 4" stroke="%s" stroke-width="1.8" fill="none"/><path d="M22 26l6 6l-2 6" stroke="%s" stroke-width="1.4" fill="none"/>' % (Q5, Q3) +
    '<circle cx="52" cy="46" r="8" fill="%s"/>%s<path d="M56 40l6 -6M52 38l2 -8" stroke="%s" stroke-width="2" stroke-linecap="round"/>' % (R5, eye(54, 45, 2), R5) +
    '<path d="M8 52l-6 6M18 56l-4 6M44 56l4 6M56 54l6 4" stroke="%s" stroke-width="3" stroke-linecap="round"/>' % R9 +
    '<path d="M30 12l2 6l2 -6" fill="none" stroke="%s" stroke-width="2" stroke-linecap="round"/>' % G5)
