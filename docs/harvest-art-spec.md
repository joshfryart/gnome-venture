# Harvest show: art needed (for Sonnet to write the .lua, Opus to draw)

Feature: `game/assets/harvest.js` + `game/includes/harvest_show.php`. A row of plants all get pulled at once and fly into a basket, then numbers show.
Today it uses emoji (🧺) and CSS blobs. This list replaces those. Plant/crop pictures are NOT needed: they reuse the existing item art (`item_icon`).

Follow `aseprite-source/art-style-guide.md` Part D + addenda, `gvlib/`, and the layer-pair pattern of `extras-pixel/scripts/chest.lua` (several same-canvas PNGs that stack, plus one `.aseprite` with named layers).
Script output dir: `aseprite-source/extras-pixel/` (like chest). Final PNGs get copied to `game/assets/img/`.
Every asset must be visually unique (no recolours). Hard pixels only. Locked eye design not used here (no faces).

## Assets (5 files groups, 8 PNGs)

### 1. harvest-basket (sticker 64x64, 3 stacking layers, same canvas)
Wicker basket, gold-stitched rim, gold button where handle meets rim. Seen 3/4 from the front, open top. Crops fly in and drop *between* back and front.
- `harvest-basket-back.png`: back half of rim (ellipse), dark inside (soil dark #3d2a1c), back weave edge. Carries the cream halo and ground shadow.
- `harvest-basket-heap.png`: a mound of mixed produce peeking over the rim (red, orange, green, purple dots/blobs, 4-5 shapes, no recognisable single crop). Hard-edged. Sits between back and front. Drawn on its own layer so JS can fade it in as the count grows.
- `harvest-basket-front.png`: front weave (cross-hatch, 2 wicker tones + shade), front rim band with thread-gold dashed seam (2 on, 1 off), folded-down side handle loops, gold button. No halo.
- Composite `harvest-basket.png` = back + heap + front (empty state shows without heap: also write `harvest-basket-empty.png` = back + front).
- must-read-at-32px: a round wicker basket, gold rim.
- Display size 64px (CSS), pivot bottom-centre (bounce scales from 50% 90%).

### 2. harvest-soil (2 frames, each 48x24, transparent bg, no halo)
Little bed under each plant, replaces the brown ellipse.
- `harvest-soil-planted.png`: soil mound with a tidy dark ring where the plant sits, 3 crumb pixels, lit upper-left.
- `harvest-soil-pulled.png`: same footprint, ring now a hole, loose crumbs scattered, a thin stitched-seam line across the front (toy look).
- Draw as one `.aseprite` with 2 frames; export both PNGs.

### 3. harvest-tuft (3 variants, each 32x24, transparent, no halo)
Leaves that show above the crop picture so it reads "a whole plant in the ground" before it is pulled. Each variant is a different shape, not a recolour.
- `harvest-tuft-leafy.png`: fan of 5 broad leaves (cabbage, lettuce, radish).
- `harvest-tuft-vine.png`: two curling tendrils and 3 small leaves (tomato, bean).
- `harvest-tuft-stalk.png`: tall thin blades and one tiny flower bud (onion, flower, grain).
- Anchor: bottom-centre sits on the top edge of the crop picture. Moss green family, 1 gold stitch on one leaf each.

### 4. harvest-puff (strip, 4 frames of 24x24 = 96x24)
Dust puff when a plant is pulled. Frames: 1 tight cloud, 2 round puffs, 3 spread with gaps, 4 three faint crumbs. Cream/stone family, outline only on frames 1-2, hard pixels. Played once, ~320 ms.

### 5. harvest-spark (strip, 4 frames of 16x16 = 64x16)
Gold twinkle at the basket as the count lands: dot, 4-point star small, 4-point star large with 1px rim, fade crumbs. Gold family (#e8a317 / #f5cf6a / #fff3c4). Same star shape language as the chest sparks.

## Code wiring after art exists (not part of the art task)
- `harvest.js`: swap 🧺 for the 3 basket layers (back, heap fades in by count, front), swap `.hv-soil` for the 2 soil frames, add tuft above the crop picture (variant by plant kind), play puff on pull, spark on count land. Keep emoji/CSS as fallback if a PNG fails to load (same pattern as `chest.js` `pixelChest`).
- Preload the PNGs from `harvest_show.php` the same way `chest.php` passes `data-body`/`data-lid` (`pixel_has()` check).

## Hand-off checks (gvlib `GV.report`)
- No semi-transparent pixels, no pure black/white, halo inside frame on the basket back only.
- View at native size and at 32px: basket reads as a basket, tufts read as leaves, puff reads as dust.
