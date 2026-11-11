# Puzzle Combat art (pfight)

Status: **Group 1 (tiles) done.** Group 2 (strip, bar) and Group 3 (combo stamps, end cards, fx) not drawn yet.
Style: Stitched Toy, hard pixels only. Ink `#2a1a10`, cream `#f2e4c0`, thread gold `#e8a317`.
Sources: `aseprite-source/pfight/*.aseprite` (one per PNG). Regenerate: `python3 aseprite-source/pfight/gen_pfight.py game/assets/img/pfight`, then `make_ase.sh`, `make_contact.py`. `check_cb.py` runs the tell-apart check.
Open `pfight-contact.html` for every asset on felt and cream, plus grayscale, deuteranopia, protanopia and tritanopia views.

## How the layers stack (all PNGs are transparent, same top-left origin)
1. `tile-<size>-<type>.png` frame body (full tile size)
2. `sock-<size>-<family>-hole.png` at x=0 (left edge), `sock-<size>-<family>-knob.png` at x=W-socketW (right edge). Sockets are opaque wood end panels: knob = dark peg, hole = cream cavity.
3. `ico-<type>.png` (hand, 32x32 at x=37,y=9) / `ico-<type>-s.png` (strip, 20x20 at x=21,y=14), sitting on the cream medallion painted into the body
4. `frame-me-*` or `frame-foe-*` on top (top and bottom edges only; sides are the sockets)
5. Picked: `frame-picked-hand.png` (100x72) goes behind, tile at offset (2,2)

Value corner (print a **cream** number on the dark plate): hand x=21,y=3, 14x12. Strip x=13,y=2, 12x10.
Hand name line: free band y=47..64 (code prints text).

## Encoding (never colour alone)
| Type | Colour | Pattern on body | Icon silhouette |
|---|---|---|---|
| hurt | vermilion `#d55e00` | diagonal slash stripes | three claw slashes |
| guard | blue `#0072b2` | brick wall | leaf shield |
| heal | bluish-green `#009e73` | dots | heart with cross |
| charm | reddish-purple `#cc79a7` | small flowers | flower |
| soothe | sky `#56b4e9` | wavy lines | dove |
| trick | yellow `#f0e442` | checker | mask and feather |
| item | orange `#e69f00` | plain, cream stitched border | jar |

| Socket family | Knob / hole shape |
|---|---|
| body | dome (round) |
| mind | keyhole (flared base, narrow neck, round bulb) |
| craft | triangle |
| flat | no shape, gold button (wild) |

Mine vs foe: mine = cream stitched top/bottom edge; foe = jagged dark thorn edge with red tips.

## Files (all PNG, transparent)
- `tile-hand-<type>.png` x7, 96x68
- `tile-strip-<type>.png` x7, 56x40
- `sock-hand-<body|mind|craft|flat>-<knob|hole>.png` x8, 20x68
- `sock-strip-<body|mind|craft|flat>-<knob|hole>.png` x8, 12x40
- `ico-<type>.png` x7, 32x32; `ico-<type>-s.png` x7, 20x20 (types: hurt guard heal charm soothe trick item)
- `frame-me-hand.png` 96x68, `frame-me-strip.png` 56x40, `frame-foe-hand.png` 96x68, `frame-foe-strip.png` 56x40
- `frame-picked-hand.png` 100x72
- `pfight-contact.html` contact sheet

## Colour-blind check (`check_cb.py`, Machado simulation)
Closest tile pair by per-pixel difference (0-255), hand size: normal 38, gray 17 (heal/charm), deuteranopia 28, protanopia 29, tritanopia 20. Strip size is within 1 of these. Colour alone would fail in gray (gap 7), so the pattern and icon carry it. Socket shapes differ by 16 to 133 pixels in every pair (shape only, no colour used).

## Known limits
- Strip keyhole and triangle holes are small (7 px deep); they read by silhouette but are the weakest pair.
- Icons are drawn with scripted shapes plus auto shading (rim light, lower-right shade, gloss comma), not hand-placed pixels. Worth a pass by hand in Aseprite if a closer match to the Opus-drawn ico set is wanted.
