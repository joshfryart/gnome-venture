#!/usr/bin/env python3
"""Chapter II-a placeholder creature art (deterministic): creature-<slug>.svg, 64 box, palette.json colours (claybound = grey/brown clay).
Run: python3 tests/gen_ph_ch2.py"""
import os
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'game', 'assets', 'img', 'ph')
S9, S7, S5, S3 = '#3d2a1c', '#7a4a1f', '#9a6b3f', '#c9a96e'
T7, T5, T3 = '#5b6470', '#8b8f96', '#c9c5bc'
W5, W3 = '#3f8fb0', '#a9d6ea'
E7, E3 = '#a8241f', '#f08a24'
INK, CR, G5 = '#2b2b2b', '#f4f0e0', '#e8a317'
def svg(slug, label, body):
    t = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="Creature %s">'
         '<ellipse cx="32" cy="57" rx="18" ry="3.2" fill="#000" opacity=".15"/>%s</svg>') % (label, body)
    open(os.path.join(OUT, 'creature-%s.svg' % slug), 'w', encoding='utf8').write(t)
def eye(x, y, r=1.6):
    return '<circle cx="%s" cy="%s" r="%s" fill="%s"/><circle cx="%s" cy="%s" r="0.6" fill="#fff"/>' % (x, y, r, INK, x - 0.5, y - 0.6)
svg('clay-crawler', 'Clay Crawler',
    '<path d="M8 50q10 -22 24 -10q12 10 24 -12" fill="none" stroke="%s" stroke-width="11" stroke-linecap="round"/>' % T7 +
    '<path d="M8 50q10 -22 24 -10q12 10 24 -12" fill="none" stroke="%s" stroke-width="4" stroke-linecap="round"/>' % S5 +
    '<circle cx="56" cy="28" r="6.5" fill="%s"/>%s<path d="M14 44l2 6M26 38l2 6M40 40l2 6" stroke="%s" stroke-width="2" stroke-linecap="round"/>' % (T7, eye(55, 26), S9))
svg('page-silverfish', 'Page Silverfish',
    '<path d="M6 44q16 -14 40 -6l12 -2l-10 10q-22 10 -42 -2z" fill="%s"/>' % T3 +
    '<path d="M10 44q16 -10 34 -4" fill="none" stroke="#fff" stroke-width="2" opacity=".55"/>' +
    '<path d="M6 44l-4 -6M6 46l-5 2" stroke="%s" stroke-width="1.4" stroke-linecap="round"/>' % T5 +
    '%s<rect x="22" y="22" width="14" height="10" rx="1" fill="%s" opacity=".9" transform="rotate(-12 29 27)"/>' % (eye(50, 40), CR))
svg('mud-crayfish', 'Mud Crayfish',
    '<ellipse cx="32" cy="42" rx="16" ry="9" fill="%s"/><ellipse cx="32" cy="40" rx="12" ry="5" fill="%s"/>' % (S7, S5) +
    '<path d="M16 40q-8 -6 -6 -16q6 2 8 8M48 40q8 -6 6 -16q-6 2 -8 8" fill="%s"/>' % S7 +
    '<path d="M46 46l10 6l-2 -8z" fill="%s"/>' % S7 + eye(26, 34) + eye(38, 34))
svg('spadefoot-toad', 'Spadefoot Toad',
    '<ellipse cx="32" cy="42" rx="19" ry="13" fill="%s"/><ellipse cx="32" cy="38" rx="14" ry="7" fill="%s"/>' % (S5, S3) +
    '<circle cx="22" cy="30" r="5" fill="%s"/><circle cx="42" cy="30" r="5" fill="%s"/>' % (S5, S5) + eye(22, 29, 2) + eye(42, 29, 2) +
    '<path d="M24 44q8 5 16 0" fill="none" stroke="%s" stroke-width="2" stroke-linecap="round"/>' % S9 +
    '<path d="M12 54l-4 3M52 54l4 3" stroke="%s" stroke-width="3" stroke-linecap="round"/>' % S7)
svg('claybound-millipede', 'Claybound Millipede',
    ''.join('<ellipse cx="%d" cy="%d" rx="8" ry="9" fill="%s"/><path d="M%d %d l-3 8M%d %d l3 8" stroke="%s" stroke-width="2" stroke-linecap="round"/>' % (x, y, T7 if i % 2 else T5, x, y + 6, x, y + 6, S9) for i, (x, y) in enumerate([(12, 44), (24, 40), (36, 40), (48, 44)])) +
    '<circle cx="54" cy="34" r="7" fill="%s"/>%s<path d="M58 28l4 -6M52 27l0 -6" stroke="%s" stroke-width="1.6" stroke-linecap="round"/>' % (T7, eye(56, 33), S9))
svg('silverfin', 'Silverfin the Page-Eater',
    '<path d="M4 38q20 -22 42 -8l14 -4l-8 12l8 10l-14 -4q-22 14 -42 -6z" fill="%s"/>' % T5 +
    '<path d="M10 38q18 -14 34 -6" fill="none" stroke="#fff" stroke-width="2.2" opacity=".5"/>' +
    '<path d="M22 24l6 -10l4 10M34 26l8 -8l2 10" fill="%s"/>' % W5 +
    '<rect x="26" y="34" width="14" height="10" rx="1.5" fill="%s" transform="rotate(8 33 39)"/><path d="M28 38h10M28 41h8" stroke="%s" stroke-width="1" opacity=".6"/>' % (CR, T5) +
    eye(12, 36, 2) + '<path d="M4 42l-2 5M7 44l-1 5" stroke="%s" stroke-width="1.4"/>' % T7 + '<circle cx="50" cy="26" r="2" fill="%s"/>' % W3)

# ---- v1.9.4 Chapter II-b: the Dim, the Cistern and the Drum Chamber (placeholders)
svg('dimwing-moth', 'Dimwing Moth',
    '<path d="M32 36q-18 -22 -24 -4q4 16 24 8z" fill="%s"/><path d="M32 36q18 -22 24 -4q-4 16 -24 8z" fill="%s"/>' % (T5, T5) +
    '<path d="M30 34q-12 -10 -16 -2M34 34q12 -10 16 -2" fill="none" stroke="%s" stroke-width="1.6" opacity=".7"/>' % T3 +
    '<ellipse cx="32" cy="40" rx="3.5" ry="9" fill="%s"/>' % T7 + eye(32, 33, 1.5) +
    '<path d="M30 30q-4 -8 -8 -8M34 30q4 -8 8 -8" fill="none" stroke="%s" stroke-width="1.4" stroke-linecap="round"/>' % S9 +
    '<circle cx="14" cy="24" r="2" fill="%s" opacity=".8"/><circle cx="50" cy="24" r="2" fill="%s" opacity=".8"/>' % (G5, G5))
svg('cistern-newt', 'Cistern Newt',
    '<path d="M6 46q14 -12 28 -4q10 4 18 -4q6 -2 6 4q-2 8 -12 8q-20 6 -40 -4z" fill="%s"/>' % T7 +
    '<path d="M10 46q14 -8 26 -2q10 3 16 -2" fill="none" stroke="%s" stroke-width="2" opacity=".5"/>' % W3 +
    '<circle cx="50" cy="38" r="7" fill="%s"/>' % T7 + eye(52, 36) +
    '<path d="M14 50l-3 5M24 52l-2 5M38 52l2 5" stroke="%s" stroke-width="2.4" stroke-linecap="round"/>' % T7 +
    '<path d="M54 32l6 -4M56 36l6 0" stroke="%s" stroke-width="1.6" stroke-linecap="round"/>' % W5)
svg('drumming-cricket', 'Drumming Cricket',
    '<ellipse cx="30" cy="38" rx="17" ry="11" fill="%s"/><ellipse cx="30" cy="36" rx="12" ry="6" fill="%s"/>' % (S7, S5) +
    '<circle cx="50" cy="32" r="6" fill="%s"/>' % S7 + eye(52, 30) +
    '<path d="M52 27q4 -10 10 -12M50 26q0 -10 -2 -12" fill="none" stroke="%s" stroke-width="1.4" stroke-linecap="round"/>' % S9 +
    '<path d="M14 46l-8 8M22 48l-4 8M38 48l4 8M44 46l8 8" stroke="%s" stroke-width="3" stroke-linecap="round"/>' % S9 +
    '<path d="M20 34l6 -8M28 32l6 -8" stroke="%s" stroke-width="2" stroke-linecap="round" opacity=".7"/>' % S3)
svg('old-pinch', 'Old Pinch',
    '<ellipse cx="32" cy="42" rx="20" ry="12" fill="%s"/><ellipse cx="32" cy="38" rx="14" ry="6" fill="%s"/>' % (T7, T5) +
    '<path d="M12 40q-10 -4 -8 -18q10 -2 14 10zM52 40q10 -4 8 -18q-10 -2 -14 10z" fill="%s"/>' % T7 +
    '<path d="M6 26l6 6M58 26l-6 6" stroke="%s" stroke-width="2" stroke-linecap="round"/>' % T3 +
    '<path d="M18 46l-6 8M26 50l-4 8M38 50l4 8M46 46l6 8" stroke="%s" stroke-width="3" stroke-linecap="round"/>' % T7 +
    eye(26, 34, 2) + eye(38, 34, 2) + '<path d="M26 44q6 4 12 0" fill="none" stroke="%s" stroke-width="1.6" stroke-linecap="round"/>' % INK +
    '<circle cx="32" cy="44" r="3" fill="%s" opacity=".9"/>' % CR)
svg('old-thrum', 'Old Thrum',
    '<ellipse cx="32" cy="44" rx="22" ry="10" fill="%s"/><rect x="14" y="26" width="36" height="20" rx="8" fill="%s"/>' % (S7, S5) +
    '<ellipse cx="32" cy="26" rx="18" ry="6" fill="%s"/><ellipse cx="32" cy="26" rx="14" ry="4" fill="%s"/>' % (S3, S5) +
    '<path d="M18 26l28 0M22 22l20 8M42 22l-20 8" stroke="%s" stroke-width="1.2" opacity=".5"/>' % S9 +
    '<circle cx="24" cy="38" r="2.4" fill="%s"/><circle cx="40" cy="38" r="2.4" fill="%s"/>' % (INK, INK) +
    '<path d="M24 44q8 4 16 0" fill="none" stroke="%s" stroke-width="2" stroke-linecap="round"/>' % S9 +
    '<path d="M12 36l-8 -8M52 36l8 -8M16 50l-8 6M48 50l8 6" stroke="%s" stroke-width="3" stroke-linecap="round"/>' % S9 +
    '<path d="M28 10l4 8l4 -8" fill="none" stroke="%s" stroke-width="2" stroke-linecap="round"/>' % E3)
