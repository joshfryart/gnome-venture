# art-2701 batch3, wear, HAIKU first pass (8 rank variants)

Scope: hand-drawn Lined and Fine rank icons for four wearables, 64x64, Hearth Pop (hard pixels, 1 px ink #2b1c26, no semi-transparent, no pure black or white). Opus passes follow. Nothing in `game/` is touched.

Run any script: `/tmp/claude-0/ase/aseprite.AppImage --appimage-extract-and-run -b --script-param out=<dir>/ --script <abs path>/<name>.lua`
Shared helper: `_hb.lua` (fleece tufts, gold stitch dashes, body-only painting so the ink outline survives, HP.assertClean on save).

## Method
- Each rank icon loads a finished base PNG (read only) and hand-places pixels on top. Nothing is derived by recolour or overlay (no `derive_icons.py`).
- Lined: cream fleece (`#fff4d6 / #f0dcb0 / #d1b07e / #a0774f`) in curly tufts where the lining shows (cuff tops, mouth, flap edge, hem).
- Fine: gold ramp (`#ffe38a / #f5b82e / #d98322 / #8f4a1f`) for trim and embroidered stitch, one cream sparkle per icon as the gleam.
- Each variant keeps its base quirk.

## Base choice (read this before Opus)
The game's current icons for these names are the cut-a silhouettes, so the flood-boots, work-gloves and trail-pack variants start from the game's own `ph/*.png` (cut a). The travel-cloak variant starts from the finished Opus `art-2701-opus/wear/travel-cloak.png`, which is the same cut-a item and is the newer art. The Opus `-b` pieces (`flood-boots-b`, `work-gloves-b`, `trail-pack-b`) carry cut-b patches (gingham, ticking, pack-b details). Those are not copied into the rank variants.

## Files

| Name | Base | Rank | Design | Quirk kept |
|---|---|---|---|---|
| travel-cloak-lined | Opus travel-cloak.png | Lined | Cream fleece strips down both edges of the front V, hem edged in curly fleece tufts | autumn leaf on the hem |
| travel-cloak-fine | Opus travel-cloak.png | Fine | Gold trim on both V edges with embroidered dash lines outside, gold hem, toggle cast in gold, cream gleam on left shoulder | autumn leaf on the hem |
| flood-boots-lined | game flood-boots.png | Lined | Turned-down cuff tops in cream fleece on both boots, fleece lining at the right boot mouth | blue water splash at the toe |
| flood-boots-fine | game flood-boots.png | Fine | Gold cuff tops, gold stitch under each cuff, gold dashed stitch down the left shaft, gold seam along the sole, cream gleam on the shaft | blue water splash at the toe |
| work-gloves-lined | game work-gloves.png | Lined | Fleece lining rolls out of each cuff mouth, above the stitch line | cream stitch row on the cuffs |
| work-gloves-fine | game work-gloves.png | Fine | Cuff stitches run in gold, gold trim on each cuff's lower edge, cream gleam on the left index finger | cream-to-gold stitch row on the cuffs |
| trail-pack-lined | game trail-pack.png | Lined | Cream fleece at the pack mouth under the blanket roll, tufts along the flap's lower edge | lavender sprig on the roll |
| trail-pack-fine | game trail-pack.png | Fine | Gold stitch along the mouth, gold trim on the flap's lower edge, buckle lit gold on top, cream gleam on the flap | lavender sprig on the roll |

Each name has `<name>.lua`, `<name>.aseprite` and `<name>.png` (64x64).

## Checks run
- `HP.assertClean` passed on all 8 (0 semi-transparent, 0 pure black or white).
- Compared against the base and game versions at 5x on one sheet. The same item reads at each rank.

## Known weak spots (for Opus)
- Lined is subtle on the flood boots and the trail pack at 100%. The fleece reads on the cuffs and the mouth, but a bolder lining band may be needed.
- Fine gold on the work-gloves uses only a few pixels per cuff, so it reads at 50% but is thin at 25%.
- The gleam on each Fine variant is a single 2x1 cream mark; the Opus pass may want a second glint on the glossy items.
- Flood boots: the lined fleece at the right boot mouth is only one row and needs checking against the game's rig layer order if it is ever shown on the gnome.
