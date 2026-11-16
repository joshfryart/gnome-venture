# art-2701 batch4b, wear, OPUS second pass (opus2, 11 icons, 64x64)

Same 11 slugs as `../haiku/`. Hearth Pop: hard pixels, 1 px ink `#2b1c26`, no semi-transparent, no pure black or white. `HP.assertClean` runs on every save (`O.save4`); all 11 report semi=0, blackWhite=0. Nothing in `game/`, `../haiku/` or any sibling folder was changed; bases are read only.

Re-run: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<this dir>/ --script <this dir>/<name>.lua`
Helper `_o4.lua` reuses `art-2701-batch3/wear/opus2/_o2.lua` and adds `O.graft(rank, cutb, base)`: start from the finished cut-a rank icon (batch3 opus3), then copy in every pixel where the finished cut-b icon differs from the plain game base. That diff is exactly the patch, its stitches and its contact shadow, so the patch always wins and fleece or gold can never cover it.

## What changed from Haiku
Haiku painted thin fleece stripes and small gold dashes over the cut-b base. The cut-a siblings carry much richer rank work, so boots, gloves and pack are now rebuilt as **cut-a Lined/Fine plus the grafted cut-b patch**. They are the same family pixel for pixel: full fleece cuffs with lumpy silhouettes, 6-tone gold, pores, rim light and bounce. The cloak, hat and scarf have no matching base, so they are hand-drawn on their own bases.

| Name | Built from | Changes |
|---|---|---|
| flood-boots-b-lined | opus3 flood-boots-lined + gingham patch | Full fleece cuffs with hanging tufts, a wisp on the pull-loop, rubber gloss and bounce. No conflicts. |
| flood-boots-b-fine | opus3 flood-boots-fine + gingham patch | The cut-a strap and buckle sat on the patch rows. The strap moved up to rows 22-25 across both boots and the buckle was re-cut to 9x6. One green row now separates it from the patch stitches. The old strap rows went back to shared shaft texture. |
| work-gloves-b-lined | opus3 work-gloves-lined + ticking patch | Fleece wrist cuffs on both gloves, the worn fingertip with fleece showing, pores and rim. |
| work-gloves-b-fine | opus3 work-gloves-fine + ticking patch | The gold oak leaf on the palm clashed with the patch and left stray gold specks above it, so it was unpicked back to leather. Kept: gold cuff bands, snap and thumb ring. The red loose thread is kept. |
| trail-pack-b-lined | opus3 trail-pack-lined + denim arrow patch | Fleece collar under the roll, fleece hem band, a mushroom in the side pocket. |
| trail-pack-b-fine | opus3 trail-pack-fine + denim arrow patch | Navy waxed flap with gold fern and fiddlehead. The pocket-watch hung where the patch is, so only chain links poked out. It is re-hung 3 px right on the side pocket, with its chain clearing the patch corner. |
| travel-cloak-b-lined | next8 opus3 travel-cloak-b (folded) | The cut-a Lined ruff and cream V facings, moved onto the fold. The top roll is a 3-row fleece with flat-topped lumps that break the silhouette (Haiku's ring was 1 px). The tan drawstring V is now 2 px cream fleece facings. |
| travel-cloak-b-fine | same | The drawstring V is a twisted gold cord, doubled to a 2 px gold welt on the top edge. The wooden bead is a 7x7 gold brooch with a 3x3 garnet and a cream glint. Gold twisted piping runs along the hem, with two gold filigree curls either side of the V (as on the cut-a Fine). |
| wayfarers-hat-b-lined | rest opus3 wayfarers-hat-b | A fleece rim 2-3 px wide along the whole lower brim, tip to tip, with lumps past the outline. Haiku had a single dotted row. |
| wayfarers-hat-b-fine | same | A 2 px twisted gold cord piped round the front brim edge, lit above and shaded under. A cast gold buckle on the red band and a pale-gold rim on the crown. |
| yarn-scarf-fine | game ph/yarn-scarf.png (cut a only, so no patch) | Two-row gold-thread knit bands on teal stripes (gold on red goes muddy). Gold beads on the fringe tips, skipping the loose curl. An inked round gold pin on the knot with a cream glint. |

Rank rule check: every Lined has fleece and no gold beyond the patch's own stitches or tartan. Every Fine has gold and no fleece. All cut-b patches and quirks are intact: dog-ear, ticking thread, trail-blaze arrow and loose thread, moth and nibbled hole, the crown patch print, the lavender, the splash, the leaf.

## Checks
- Every icon viewed at 6-8x on grey and dark, and as 32 px and 16 px box-downscales.
- Lined and Fine differ clearly at 32 px on all five pairs: cream against gold. At 16 px they still differ, with white cuffs, rims or collars against gold bands, a navy flap or a gold brim.
- Distinct colours: boots L 43 / F 51, gloves L 34 / F 36, pack L 63 / F 63, cloak L 47 / F 50, hat L 38 / F 39, scarf F 19.

## Weaknesses
- travel-cloak-b: the folded cloak is a different drawing from the hanging cut-a cloak, so the family link is only in the treatment (ruff, V facings, brooch). At 16 px this is the weakest Lined/Fine pair: cream V against gold V and brooch.
- work-gloves-b-fine: without the oak leaf, the Fine reads at 16 px mainly by its gold cuff bands.
- flood-boots-b-fine: the strap now sits right under the cuffs and reads partly as a second cuff band. The buckle is 9x6.
- trail-pack-b-fine: the re-hung watch is 4x3 and only shows close up, as intended for a quirk.
- yarn-scarf-fine: the knot pin is 3x3 inside its ink ring, small at 32 px. No yarn-scarf-b exists, so there is no patch. The yarn-scarf Lined is not in this batch.
- wayfarers-hat-b-lined: the fleece lumps are 1 row deep, so the woolly edge is subtle at 16 px. The cream rim itself carries the read.
