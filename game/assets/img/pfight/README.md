# Puzzle Combat art (pfight)

Status: Group 1 (tiles), Group 2 and Group 3 done (see Update 4 below and parts/README.md for the 2D board kit).
Style: Stitched Toy, hard pixels only. Ink `#2a1a10`, cream `#f2e4c0`, thread gold `#e8a317`.
Sources: `aseprite-source/pfight/*.aseprite` (one per PNG). Regenerate: `python3 aseprite-source/pfight/gen_pfight.py game/assets/img/pfight`, then `make_ase.sh`, `make_contact.py`. `check_cb.py` runs the tell-apart check.
Open `pfight-contact.html` for every asset on felt and cream, plus grayscale, deuteranopia, protanopia and tritanopia views.


## USE THESE: real jigsaw pieces (added after review)
The `sock-*`, `tile-*` and `frame-*` layers below are flat rectangles with end panels (legacy, still delivered). Overlays cannot cut a hole, so the true jigsaw silhouettes are pre-composed:
- `piece-<hand|strip>-<type>-<holefam>-<knobfam>.png`: coloured body with a **real notch cut into the left edge** and a **real knob sticking out of the right edge** (transparent outside). Families: `body` (round head on a neck), `mind` (keyhole: flared base, thin neck, small head), `craft` (triangle), `flat` (straight edge, wild). 7 types x 4 x 4 x 2 sizes = 224 files.
- `edge-<hand|strip>-<me|foe>-<holefam>-<knobfam>.png`: outline overlay that follows the same silhouette. me = cream line with gold stitches, foe = dark thorn teeth. 64 files.
- Sizes: hand piece 114x68 (tile 96 + knob 18), strip piece 65x40 (tile 56 + knob 9). The knob is the last 18 (hand) or 9 (strip) px.
- Snap: the next piece goes at x + 96 (hand) or x + 56 (strip), so its hole swallows the previous knob.
- Layers: piece, then `ico-<type>.png` at (37,9) hand or (21,14) strip, then edge overlay. Value plate is already baked in at hand (21,3) 14x12, strip (13,2) 12x10: print a cream number.
- Sources: no `.aseprite` per piece (288 files, all generated); `aseprite-source/pfight/gen_pieces.py` rebuilds them.
- Not drawn: `frame-picked-hand.png` still fits only the legacy rectangle; a piece-shaped raised overlay is not done.

## Legacy rectangle layers: how they stack (all PNGs are transparent, same top-left origin)
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

## Update 4: Groups 2 and 3 (felt style, hard pixels)
- `combo-ambush|riposte|double-swing|calm-charm|win-over|bait.png` 32x32 (diamond, shield, burst, cloud, heart, tag silhouettes).
- `end-charmed-small|medium|large|boss.png` 64x64 (mouse-squirrel, fox, bear, crowned lion). `ico-gift.png` 24x24.
- `fx-hit|guard|heal|charm.png` 128x32, 4 frames of 32x32.
- `crown-boss.png` 12x12 boss mark (use with the `boss` palette in `parts/rim.json`). `open-end.png` 24x24 open-socket marker.
- Bar, bubble and strip art for the 2D board live in `parts/` (`resolve-*`, `intent-bubble`, `chain-glow-*`); `strip-rail.png` is dropped (no 1D strip any more).

## Update 5: round 2 variant icons and popover header
- `ico-<name>.png` 32x32 and `ico-<name>-s.png` 20x20 for: jab pierce sting trip bash smash (Hurt), brace roll thornhide mending (Guard), hum lull (Soothe), bond (Charm), pluck (Trick). Drawn with the same `gen_pfight.py` look as the shipped icons; every silhouette is unique at both sizes.
- `popover-header.png` 96x96 "Choose an upgrade" header; banner rect (7,73) 82x15 left empty for the title.
- Tag marks, upgrade marks and rarity gems: `parts/marks/` (see `parts/README.md`).
