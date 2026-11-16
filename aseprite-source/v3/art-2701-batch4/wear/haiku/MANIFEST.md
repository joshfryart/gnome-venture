# art-2701 batch4, wear, HAIKU first pass (8 of 19 missing slugs)

Scope: hand-drawn wearable icons, 64x64, Hearth Pop (hard pixels, 1 px ink #2b1c26, no semi-transparent, no pure black or white). Nothing in `game/` is touched. Opus passes follow.

Run any script: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<dir>/ --script <abs path>/<name>.lua`
Shared helper: `_hb.lua` (copy of the batch3 helper: body-only painting so the ink outline survives, fleece tufts, gold dashes, HP.assertClean on save).

## Missing slugs (checked on disk, 2026-11-15)
The brief listed a few; the disk shows 19 of the 33 `wear_items()` slugs with no Opus art. Opus art on disk now (14): `travel-cloak`, `travel-cloak-lined`, `travel-cloak-fine`, `travel-cloak-b`, `flood-boots-lined`, `flood-boots-fine`, `flood-boots-b`, `work-gloves-lined`, `work-gloves-fine`, `work-gloves-b`, `trail-pack-lined`, `trail-pack-fine`, `trail-pack-b`, `wayfarers-hat-b`.

Drawn in this batch (8): `flood-boots`, `work-gloves`, `trail-pack`, `yarn-scarf`, `wayfarers-hat`, `wayfarers-hat-lined`, `wayfarers-hat-fine`, `yarn-scarf-lined`.

NOT drawn (11), for Opus or a later Haiku pass:
- `flood-boots-b-lined`
- `flood-boots-b-fine`
- `wayfarers-hat-b-lined`
- `wayfarers-hat-b-fine`
- `work-gloves-b-lined`
- `work-gloves-b-fine`
- `travel-cloak-b-lined`
- `travel-cloak-b-fine`
- `trail-pack-b-lined`
- `trail-pack-b-fine`
- `yarn-scarf-fine`

## Files
Each name has `<name>.lua`, `<name>.aseprite` and `<name>.png` (64x64). The base is always the game's `ph/<base>.png` (cut a, read only).

| Name | Rank | Design | Quirk kept |
|---|---|---|---|
| flood-boots | Common | Two deep-green scuffs on the shafts (wear cue only) | blue water splash at the toe |
| work-gloves | Common | Two dark-tan knuckle creases on the backs (wear cue only) | cream stitch row on the cuffs |
| trail-pack | Common | Rubbed patch on the flap, worn lower corner (wear cue only) | lavender sprig on the roll |
| yarn-scarf | Common | Pale sheen pixels on the teal stripes (wear cue only) | loose tails with fringe |
| wayfarers-hat | Common | Two pinch creases on the crown (wear cue only) | blue feather, red band |
| wayfarers-hat-lined | Lined | Cream fleece tufts along the brim's lower edge, where the lining turns out | blue feather, red band |
| wayfarers-hat-fine | Fine | Gold dashed embroidery along the brim's lower edge, cream gleam on the crown | blue feather, red band |
| yarn-scarf-lined | Lined | Cream fleece at both tail ends and on the inner rim of the loop (the openings) | loose tails with fringe |

## Checks run
- `HP.assertClean` passed on all 8 (0 semi-transparent, 0 pure black or white).
- Viewed on one 4x sheet against the game bases.

## Known weak spots (for Opus)
- The five Commons are close to the game base. Each has only a small wear cue, so they read as the base at 1x. Opus should redraw them, not polish these.
- Lined fleece on `yarn-scarf-lined` is thin (a few pixels per tail). It reads at 4x, but is faint at 1x.
- Fine gleam on `wayfarers-hat-fine` is 2 pixels. Opus may want a second glint.
- The game's current `wayfarers-hat-lined` and `wayfarers-hat-fine` icons already carry gold on the brim. This batch starts the Lined and Fine ranks from the plain cut a base, so the three hat icons do not share a base with the game's rank icons.
