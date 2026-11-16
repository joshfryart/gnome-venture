# art-2701 batch4, wear, OPUS richness pass (opus3, 8 icons)

Built on `../opus2/`, with its scripts copied here and reworked. Same items, same layouts. All icons are 64x64 Hearth Pop: hard pixels, a 1 px ink `#2b1c26` outline, no semi-transparent pixels, no pure black or white, nothing on the canvas edge. `HP.assertClean` runs in `W.save` on all 8 and passes; a separate PIL check also passed. Nothing outside this folder was touched.

Re-run: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<this dir>/ --script <this dir>/<name>.lua`

Helpers:
- `_w.lua` is the opus2 helper plus `W.rimb`, which adds a rim light on lit free edges and a bounce line on shade free edges. It also has `W.idx` and a new curly fleece (3x3 bobbles lit from the upper-left), with a cooler fleece deep tone.
- `_hat.lua` draws all three hat ranks from one function.
- `_scarf.lua` draws both scarf ranks from one function.

The ranks share the same cut, so each set reads as one item.

Rank rules:
- **Lined** has cream fleece at the openings and no gold.
- **Fine** has gold trim and embroidery and a gleam, and no fleece.

At 32 px they differ clearly: the Lined hat has a cream ring all round the brim, the Fine hat a gold braid. Both still read at 16 px.

| Name | Changes vs opus2 (fixes the opus2 weaknesses) | Quirk |
|---|---|---|
| flood-boots | Hue-shifted tan cuffs with canvas twill, a lit top roll, a cream saddle stitch and a brass rivet, so they are no longer flat brown. Both feet have a domed toe instead of a square block, plus a moulded toe-cap seam. Rubber has a rim light and a bounce line. | The rubber duck in the back boot, with a lit rim |
| work-gloves | The palms have pebbled grain and a darker reinforcing patch with a cream running stitch. Rim light and bounce on the leather and cuffs. The worm is now about 3 px thick and readable at 32 px. | The pink earthworm draped over the back glove's little finger |
| trail-pack | The canvas weave is now a calm, sparse plain-weave grid (it was busy before). The mug's wire handle is a bright 2-tone wire. Rim light on the body and bedroll. | The blue enamel mug with a chip, hanging off the right pocket |
| yarn-scarf | Slimmer tubes like the game base, and narrower stripes. Real knit: 2 px stitch columns with grooves, each stitch lit from the upper-left. The knot is rounded and tied, with wrap folds (it was a band). The tails are asymmetric: the left is longer and swings out. Rim light and bounce. | The knitting needle, ball end and working yarn through the right tail |
| yarn-scarf-lined | Same drawing as yarn-scarf. Fleece on the neck-opening rim is now 3 px, with a fold shade on the knit, and the curly fleece cuffs bulge past the knit. | The darned pink heart patch, now cross-stitched |
| wayfarers-hat | Hue-shifted felt (violet deep, honey light). The brim tips curl up, so the left end is no longer blunt. Brushed felt streaks, a lit brim lip, and rim light on the crown, brim and feather, with a bounce under the brim. The flat knot is now a hand-drawn ribbon bow with two loops, fold holes and swallowtail tails. | A bigger ladybird (9x7, ink head, cream eye, spots), readable at 32 px |
| wayfarers-hat-lined | Same hat. Fleece is turned out round the whole brim edge: lumpy curls under the front lip and fleece peeking over the far edge on both sides of the crown, so it is a full cream ring. A fleece sweatband shows under the band. | A fat fleece tuft (ink-edged) snagged on the blue feather vane, with a wisp; no longer lost against the quill |
| wayfarers-hat-fine | Same hat. Gold twisted braid on the brim edge, gold edging on the band, and two gold embroidered diamonds (calmer than the old zig-zag). A gold ring sits over the bow knot, the tails have gold aglets, and a gold clasp pins the feather. Gleam: a cream four-point star off the clasp. | A bigger gold acorn charm on a short chain from the ring knot |

All 8 were checked at 4x, 6x and 8x on grey and dark, and as 32 px and 16 px box downscales.

Remaining weaknesses:
- The scarf knit is a little mottled at 100%.
- The boot toe-cap seam is subtle.
- The two glove palm patches match each other (they are a pair).
