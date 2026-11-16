# art-2701 batch4b, wear, OPUS richness pass (opus3, 11 icons, 64x64)

These are the same 11 slugs as `../opus2/`. Each script loads its opus2 PNG read only and hand-places pixels on top. Every icon uses hard pixels and a 1 px ink `#2b1c26` outline, with no semi-transparent pixels and no pure black or white. `HP.assertClean` runs in `O.save4` on every save, and all 11 pass (semi=0, blackWhite=0). Nothing in `game/`, `../opus2/`, `../haiku/` or any sibling folder was changed.

Re-run: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<this dir>/ --script <this dir>/<slug>.lua`

## Helpers
- `_o5.lua` reuses `../opus2/_o4.lua` and points the output at this folder. It adds:
  - `O.ramp` and `O.step` for hue-shifted ramp steps.
  - `O.rimbounce`: lit rim on upper-left edges, bounce colour on lower-right edges.
  - `O.texture` and `O.nap`: per-pixel weave, grain and felt nap from a fixed hash, so results repeat.
  - `O.dist`: distance to the silhouette.
- `_boots.lua`, `_gloves.lua` and `_pack.lua` hold the richness both ranks of an item share, so each Lined/Fine pair stays siblings.

## What changed
| Name | Added | Quirk |
|---|---|---|
| travel-cloak-b-lined | Fleece lining turned out at the bottom edge of the top layer, the middle layer and the hem, so it reads as cream bands on green at 16 px. The collar roll is 4 rows deep. Wool twill on all layers, a lit rim, and a teal bounce on the lower right. | A wooden toggle on twine at the V. Kept: moth, nibbled hole, leaf. |
| travel-cloak-b-fine | Twisted gold piping on the same edges, and the hem piping now runs the full width with an umber contact row, so it reads as gold bands on green. A 9x9 brooch with a 4x4 faceted garnet, a glint and a sparkle. Same twill, rim and bounce. | A gold tassel on the drawstring end, hanging past the hem. |
| wayfarers-hat-b-lined | The fleece brim rim is 3-4 px deep at the front (cut-a Lined match). Felt nap, a crown rim light, a lilac bounce, and a crown pinch crease. | An acorn tucked into the band, in the spot where the Fine has its buckle. |
| wayfarers-hat-b-fine | The gold brim is 3 rings deep at the front (cord plus band plus umber), as on the cut-a Fine. Felt nap, rim and bounce. Sparkle on the buckle. | A gold-thread star on the brim front. |
| flood-boots-b-lined | Rubber crinkle rows, a long gloss streak and glint on the front shaft, and tread grain on the soles (shared). | A snail climbing the back boot's instep. |
| flood-boots-b-fine | The strap over the back boot is unpicked, so it no longer reads as a second cuff band (an opus2 weakness). Shared rubber and sole work. Pale-gold sparkle on the front cuff. | Rain bead kept. |
| work-gloves-b-lined | Leather grain: creases and pale pores (shared). Cream running stitch down the back glove. | Worn fingertip and red loose thread kept. |
| work-gloves-b-fine | The cut-a Fine's gold-thread oak leaf is re-sewn on the back glove, clear of the patch. The Fine now reads at 16 px by the leaf plus the cuff bands (an opus2 weakness), and it is a clearer sibling of the cut-a. Shared grain. Sparkle on the lit knuckle. | Gold thumb ring kept. |
| trail-pack-b-lined | Leather-bound base in a hue-shifted leather ramp, with a lit edge and a cream saddle stitch. A leather compression strap on the left pocket with a pewter buckle (shared). | Mushroom and lavender kept. |
| trail-pack-b-fine | Same base and strap, with a gold side buckle. Pale-gold sparkle on the main buckle. | Pocket-watch kept. |
| yarn-scarf-fine | Stocking-stitch rib on the red and teal ramps (7 tones each), a lit rim, and a plum bounce. The knot pin is now a 7x7 gold ring brooch with a teal enamel boss, a glint and a sparkle (it was 3x3). | Loose yarn curl kept. |

All cut-b patches (gingham with dog-ear, ticking, denim arrow, tartan with moth, crown print) were masked off and are untouched. Lined pieces have fleece and no new gold. Fine pieces have gold and no fleece.

## Checks
- Viewed at 4-7x on grey and dark, and as 32 px and 16 px box-downscales.
- Lined and Fine differ clearly at 32 px on all five pairs, and still differ at 16 px: cream bands, rims or cuffs against gold bands, a garnet, a leaf or a navy flap.
- Silhouettes are unchanged, apart from the hat's fleece lumps, the tassel and the snail.

## Weaknesses
- travel-cloak-b: the cream and gold bands are regular, close to stripes. The tassel is 3 px wide.
- wayfarers-hat-b-fine: at 64 px the widened gold reads as a double rim, not one solid band. The brim star is small.
- yarn-scarf-fine: the knit rib reads as grain more than as knit "v"s, because the scarf runs diagonally.
- flood-boots-b-fine: at 16 px the gold is still mostly the cuff edge lines.
