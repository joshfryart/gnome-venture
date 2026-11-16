# art-2701 batch3, wear, OPUS richness pass (opus3, 8 rank variants)

These are the same 8 Lined and Fine icons as `../opus2/`, at 64x64. Each script loads its opus2 PNG read-only (the Lined cloak re-runs the opus2 recipe on the Opus `art-2701-opus/wear/travel-cloak.png`) and hand-places pixels on top. Every icon uses hard pixels and a 1 px ink `#2b1c26` outline, with no semi-transparent pixels and no pure black or white. `HP.assertClean` passes on all 8 (it runs in O.save). Nothing in `game/`, `../opus2/` or `../haiku/` was touched.

Re-run: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<this dir>/ --script <this dir>/<name>.lua`

`_o3.lua` reuses `../opus2/_o2.lua` and points the output at this folder. It adds:
- `O.FLEECE`: a 5-tone fleece with a cooler deep.
- `O.GOLD6`: a 6-tone gold (pale, hi, base, shade, deep, umber).
- `O.rim`: rim or bounce pixels along one side of the silhouette.
- `O.each`: a per-pixel pass.
- `O.gloveLeather`: shared leather pores, rim light and bounce for both glove ranks.

## What is the same on all four items
- Light comes from the upper left. Each item has a rim light on its lit left edge and a cool bounce line on the lower right: teal on the wool, sea blue from the puddle on the boots, lilac on the leather, slate on the canvas.
- The Lined and Fine versions of each item share the same material texture: twill fleck on the cloak, pores on the gloves, a gloss stripe and pull-loop on the boots, weave on the pack. This keeps each pair as siblings.
- Lined has fleece and no gold. Fine has gold and no fleece. Each icon keeps the base quirk and adds one small rank-specific quirk that only shows close up.

| Name | Richness added | Quirk added | Remaining weaknesses |
|---|---|---|---|
| travel-cloak-lined | The neck ruff is hand-placed, with a lumpy outer edge, top tufts, a shaded far lip and a lit near lip, and two tufts over the toggle. It replaces the regular ring. The facings are 2 px from the top and widen to 4 px at the hem (opus2 started at 1 px). Brown blanket-stitch runs over the fold line every 3 rows. | A darned patch (cross-hatch in paler thread) low on the left skirt. | The ruff interior is a little flat. The blanket-stitch is busy at 100%. |
| travel-cloak-fine | The 9x7 cast gold brooch has a 3x3 faceted garnet in 4 tones with a cream glint (opus2 had a 2x2 dot). Gold filigree spirals are embroidered either side of the V above the hem. | A gold-thread bee on the shaded right shoulder. | The bee is about 4x3 and only shows close up, as intended. The hood carries no gold. |
| flood-boots-lined | The fleece is cooler-toned. Two-row tufts hang from the back cuff over its mouth row (opus2 had 1 px), and the brown holes under the back cuff are gone. There is a rubber rim light, a gloss stripe and glint on the back shaft, an ankle crinkle, a lit sole welt, puddle-blue bounce under the toe, and a pull-loop on the back heel. | A fleece wisp snagged on the pull-loop. | The fleece curl pattern is still quite regular. |
| flood-boots-fine | The strap has 4 rows with grain and a contact shadow. The buckle is a 9x7 centre-bar gold buckle with dark openings, so it reads as a buckle (opus2: 6x6). The cuffs have polished streaks and grain flecks. There is gold welt piping on the front sole, plus the same rim, gloss and bounce as Lined, and a pull-loop with a gold rivet. | A rain bead on the polished front cuff. | The pull-loop rivet is 1 px. |
| work-gloves-lined | Leather pores, a pale rim light on every lit edge, lilac bounce on the back glove, cooler fleece, and an extra tuft row on the back glove's band. | The middle fingertip is worn through, with fleece peeking out of the hole. | The back band is still partly behind the front one (by composition). The hole is 2x2. |
| work-gloves-fine | The filled gold diamond is unpicked (base leather restored) and replaced by a gold-thread oak leaf. The leaf is open line-work (outline, midrib and veins) and each stitch casts a 1 px leather shadow, so it reads as raised embroidery, not a gem. The snap is a 3x3 dome with a dimple and glint. Same pores, rim and bounce as Lined. | A gold ring worn over the glove's thumb. | The leaf reads as embroidery but is a generic leaf shape. At 16 px the Fine gloves rely on the gold cuff bands. |
| trail-pack-lined | The canvas contact shadow under the collar and the hem band is darker, lifting the cream off the oat. The fleece deep is cooler. There is brown blanket-stitch over the hem band, grain on the strap, rim light on the left panel, and slate bounce on the lower right. | A red-capped mushroom tucked into the left side pocket, poking past the silhouette. | Cream on oat is still the softest pairing, but it now reads as a white band against the navy Fine. |
| trail-pack-fine | **16 px fix:** the flap is dyed navy waxed canvas (a 6-tone hue-shifted ramp that keeps the weave). It has a lit left edge, a deep hem edge and a contact shadow, so Fine reads as "dark flap and gold" and Lined as "white collar". The wheat-like ferns are replaced by an open fern frond (alternate pinnae) and a fiddlehead spiral in gold thread. | A gold pocket-watch on its chain spilling from the right side pocket. | The navy flap is a fairly flat rectangle (there is no curved flap edge). It moves furthest from the oat base, but the silhouette is unchanged. |

All 8 were checked at 64 px and as 32 px and 16 px box-downscales on grey and dark. Each icon reads as the same item as opus2. Lined and Fine differ at 32 px on all four, and still differ at 16 px: white fleece against gold or a dark flap.
