#!/usr/bin/env python3
"""Draws the rest stop icons and passport stamps into game/assets/img/stops/ (v1.0.0 wave 1).
Run: python3 tests/stops_art.py  (from src/). All paths use currentColor so CSS tints them and dark mode just works."""
import os
OUT = os.path.join(os.path.dirname(__file__), '..', 'game', 'assets', 'img', 'stops')
os.makedirs(OUT, exist_ok=True)
SOFT = 'fill="currentColor" fill-opacity=".16"'
ICONS = {
 'market': f'''<path d="M7 19 L11 8 H37 L41 19 Z" {SOFT}/><path d="M7 19 q4 5 8.5 0 q4 5 8.5 0 q4 5 8.5 0 q4 5 8.5 0"/><path d="M9 25 V40 M39 25 V40"/><path d="M7 31 H41"/><circle cx="18" cy="27.4" r="2.6" {SOFT}/><circle cx="25.5" cy="27" r="2.2" {SOFT}/><path d="M29 29 h8 l-1 2.6 h-6 z" {SOFT}/>''',
 'mill': f'''<path d="M17 42 L20 20 H28 L31 42 Z" {SOFT}/><path d="M18 20 L24 12 L30 20"/><circle cx="24" cy="20" r="1.4" fill="currentColor"/><path d="M24 20 L12 8 M24 20 L36 8 M24 20 L12 32 M24 20 L36 32" stroke-width="2"/><path d="M21 42 v-7 h6 v7"/>''',
 'inn': f'''<path d="M7 23 L24 8 L41 23" /><path d="M10 21 V41 H38 V21" {SOFT}/><rect x="20" y="29" width="8" height="12" rx="1"/><rect x="12.5" y="25" width="5" height="5"/><rect x="30.5" y="25" width="5" height="5"/><path d="M33 13 V8 h4 v9"/><path d="M5 41 H43"/>''',
 'shrine': f'''<path d="M6 14 Q24 8 42 14" /><path d="M10 20 H38"/><path d="M14 14 V41 M34 14 V41"/><path d="M24 14 V20"/><path d="M11 41 h6 M31 41 h6"/><path d="M5 11 q3 5 7 5 M43 11 q-3 5 -7 5" stroke-width="2"/>''',
 'jetty': f'''<path d="M5 28 H34" /><path d="M9 28 V40 M18 28 V40 M27 28 V40"/><path d="M2 36 q3.5 -3 7 0 t7 0 t7 0 t7 0 t7 0 t7 0" /><path d="M32 28 L40 10 M40 10 q0 14 -5 20" /><circle cx="35" cy="31" r="1.5" fill="currentColor"/><path d="M13 24 q3 -3 6 0 q-3 3 -6 0 z" {SOFT}/>''',
 'herb': f'''<path d="M24 42 V18" /><path d="M24 36 q-11 -2 -13 -13 q11 0 13 13z" {SOFT}/><path d="M24 30 q11 -2 12 -14 q-11 1 -12 14z" {SOFT}/><path d="M24 20 q-5 -3 -4 -10 q6 3 4 10z" {SOFT}/><path d="M16 42 h16"/>''',
 'workshop': f'''<circle cx="24" cy="24" r="8" {SOFT}/><circle cx="24" cy="24" r="3"/><path d="M24 11 V15 M24 33 V37 M11 24 H15 M33 24 H37 M15 15 l3 3 M30 30 l3 3 M33 15 l-3 3 M18 30 l-3 3" stroke-width="3.4"/><path d="M5 42 H43"/>''',
 'orchard': f'''<circle cx="24" cy="19" r="12" {SOFT}/><path d="M24 31 V42 M19 42 h10"/><circle cx="19" cy="16" r="2.2" fill="currentColor"/><circle cx="28" cy="14" r="2.2" fill="currentColor"/><circle cx="26" cy="23" r="2.2" fill="currentColor"/><path d="M24 31 l-5 -4 M24 33 l5 -4" stroke-width="2"/>''',
 'ferry': f'''<path d="M7 31 H41 L36 39 H12 Z" {SOFT}/><path d="M24 31 V7"/><path d="M24 9 L37 27 H24 Z" {SOFT}/><path d="M24 12 L14 27 H24"/><path d="M3 43 q3.5 -3 7 0 t7 0 t7 0 t7 0 t7 0 t7 0" />''',
 'tower': f'''<path d="M17 42 L19 18 H29 L31 42 Z" {SOFT}/><path d="M15 18 H33 M15 18 V13 h3 v3 h3 v-3 h6 v3 h3 v-3 h3 v5" /><path d="M24 12 q-5 -4 0 -9 q5 5 0 9z" fill="currentColor" fill-opacity=".35"/><rect x="21.5" y="26" width="5" height="6" rx="2.5"/><path d="M13 42 H35"/>''',
 'spring': f'''<path d="M6 30 q0 12 18 12 t18 -12 z" {SOFT}/><path d="M6 30 H42"/><path d="M15 25 q-3 -4 0 -7 q3 -3 0 -7 M24 25 q-3 -4 0 -7 q3 -3 0 -7 M33 25 q-3 -4 0 -7 q3 -3 0 -7" /><circle cx="31" cy="34" r="2" fill="currentColor" fill-opacity=".4"/>''',
 'camp': f'''<path d="M5 42 L17 20 L29 42 Z" {SOFT}/><path d="M17 20 V42 M12 42 L17 34 L22 42"/><path d="M33 42 q-5 -5 0 -12 q1 3 3 4 q3 -4 -1 -10 q9 4 6 14 q-1 3 -3 4" {SOFT}/><path d="M29 43 L41 40 M29 40 L41 43" stroke-width="2.6"/>''',
}
for k, body in ICONS.items():
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">{body}</svg>\n'
    open(os.path.join(OUT, k + '.svg'), 'w').write(svg)
    st = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="64" height="64" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">'
          '<circle cx="32" cy="32" r="29.5" stroke-width="2.4" stroke-dasharray="1.6 3.2"/>'
          '<circle cx="32" cy="32" r="26" stroke-width="2.6"/><circle cx="32" cy="32" r="22.5" stroke-width="1"/>'
          f'<g transform="translate(14.5 14.5) scale(0.7)" stroke-width="3.2">{body}</g></svg>\n')
    open(os.path.join(OUT, 'stamp-' + k + '.svg'), 'w').write(st)
print('wrote', len(ICONS) * 2, 'files to', os.path.normpath(OUT))
