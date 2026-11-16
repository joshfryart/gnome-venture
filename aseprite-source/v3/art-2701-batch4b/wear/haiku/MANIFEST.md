# art-2701 batch4b, wear, HAIKU first pass (11 icons, 64x64)

Scope: the 11 cut-b wearable icons with the rank treatment (Lined or Fine). Hearth Pop: hard pixels, 1 px ink #2b1c26, no semi-transparent, no pure black or white. Opus passes follow. Nothing in `game/` is changed; the scarf base is read only.

Run any script: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<this dir>/ --script <abs path>/<name>.lua`
Helper: `_hb.lua` (batch4 helper plus `H.swap` for recolouring inside a box). Paints body pixels only, so the ink outline survives. `HP.assertClean` runs on every save.

## Output (each has `.lua`, `.aseprite`, `.png`)

| Name | Base (read only) | Rank treatment | Cut-b patch | Quirk kept |
|---|---|---|---|---|
| flood-boots-b-lined | art-2701-opus/wear/flood-boots-b.png | Cream fleece over both boot-top cuffs, tufts over the lower edge | gingham, kept | splash at the toe |
| flood-boots-b-fine | same | Gold 2-on-1-off stitch on both cuffs, leather strap with a gold buckle, cream gleam on the back shaft | gingham, kept | splash at the toe |
| work-gloves-b-lined | art-2701-opus/wear/work-gloves-b.png | Cream fleece at both wrist openings, tufts under the front cuff | ticking, kept | loose red thread on the front cuff |
| work-gloves-b-fine | same | Both cream stitch rows turned to gold thread, gold trim on both wrists, gold snap on the back cuff | ticking, kept | loose red thread on the front cuff |
| trail-pack-b-lined | art-2701-next8/opus3/trail-pack-b.png | Cream fleece along the pack mouth under the roll, tufts over the edge | blue patch and buckle, kept | lavender sprig on the roll |
| trail-pack-b-fine | same | Gold stitch along the pack mouth, gold rivets on the top corners, cream gleam on the left body | blue patch and buckle, kept | lavender sprig on the roll |
| travel-cloak-b-lined | art-2701-next8/opus3/travel-cloak-b.png | Cream fleece round the collar (the neck opening), tufts into the front V | shoulder patch and bee, kept | orange leaf on the hem |
| travel-cloak-b-fine | same | Gold stitch along the collar, the tan front cord turned to gold, cream gleam on the cord | shoulder patch and bee, kept | orange leaf on the hem |
| wayfarers-hat-b-lined | art-2701-rest/opus3/wayfarers-hat-b.png | Cream fleece tufts along the brim's lower edge (the lining turning out) | crown patch, kept | blue feather, red band |
| wayfarers-hat-b-fine | same | Gold dashed embroidery along the brim's lower edge, cream gleam on the crown | crown patch, kept | blue feather, red band |
| yarn-scarf-fine | game/assets/img/ph/yarn-scarf.png (cut a, read only) | Gold stitch across both tail ends, gold bead at the loop crossing | **none, see gap** | loose tails with fringe |

## Gap: no yarn-scarf cut-b on disk
No `yarn-scarf-b` base exists in the batch folders or in `game/assets/img/ph/`. So `yarn-scarf-fine` is built on the plain cut-a scarf and has no stitched patch. Decide before Opus: either draw a yarn-scarf-b patch first and then re-base this Fine, or accept the cut-a base. The Lined rank of the yarn scarf is not in this batch.

## Checks run
- All 11 saved through `HP.assertClean` with no error. Each run reported semi=0 and blackWhite=0.
- Distinct colours per icon: flood-boots-b-lined 41, flood-boots-b-fine 42, work-gloves-b-lined 28, work-gloves-b-fine 29, trail-pack-b-lined 55, trail-pack-b-fine 54, travel-cloak-b-lined 46, travel-cloak-b-fine 44, wayfarers-hat-b-lined 36, wayfarers-hat-b-fine 33, yarn-scarf-fine 17.
- Read at 4x and 8x on a dark background. Lined and Fine differ at a glance on all ten cut-b pairs: white fleece against gold stitch and gold hardware.
- The cut-b patch and the quirk of each base were left untouched.

## Weak spots for Opus
- Lined cuffs: the fleece covers the top three rows only. The lower cuff stays tan, so the fleece reads as a thin band at 16 px. A full-cuff fleece pass would help.
- Gold on the boots and cloak is one-pixel thin at 16 px. Fine is clear at 32 px and above.
- Trail-pack Fine: the gold stitch and the gleam are small. Consider a gold clasp or a gold patch border.
